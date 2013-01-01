# encoding: utf-8

require "Thor"
require "pp"
require "Plist"

# ---------------------------------------------------------------------------------------------------------------------
# Run a script and yield with procces return and process output
def run_script text
  out = ""
  ret = IO.popen('sh', 'r+') do |f|
    f.puts(text)
    f.close_write
    out = f.read
    yield $?, out if block_given?
  end
  out
end

# Run an apple script
def run_apple_script text
  # Cleanup the script text
  [
    [/\\/,"\\"],
    [/\n+\s*/, "\n"],
    [/\n+/,"\n"],
    [/\"/,"\\\""]
  ].each {|src| text.gsub!(src[0],src[1])}

  # Execute the script
  args = "osascript" + text.split("\n").map{|l| " -e \"#{l}\""}.join
  out = run_script args do |proc_ret, proc_out|
    yield proc_ret, proc_out if block_given?
  end
  out
end

# Find out if an app is installed or not
def is_installed app_id
script = <<-eos
try
  tell application "Finder"
    return name of application file id "#{app_id}"
  end tell
on error err_msg number err_num
  return null
end try
  eos

  ret = run_apple_script(script).gsub(/\s+$/,"")
  ret != "null"
end

# ---------------------------------------------------------------------------------------------------------------------
# Add a task to the OF inbox
def send_task_to_omnifocus_inbox name, note

  if !is_installed "com.omnigroup.OmniFocus"
    puts "you need to have omnifocus installed for this script to work"
    exit 10
  end

script = <<-eos

set OFName to "#{name}"
set OFNote to "#{note}"

tell application "OmniFocus"
  set theDoc to first document
  tell theDoc
    make new inbox task with properties {name:OFName, note:OFNote}
  end tell
end tell

  eos

  run_apple_script script
end

# ---------------------------------------------------------------------------------------------------------------------
# A DayOne Entry
class TaggedLine

  def self.get_tags str
    str.scan( %r{@[^(\s\:]+} ).uniq
  end

  attr_accessor :tags, :line

  def initialize str
    @line = str
    @tags = self.class.get_tags @line
  end

  def has_tags?
    @tags.size > 0
  end

end # class TaggedLine


class DayOneEntry
  include Plist::Emit

  attr_accessor :dirty

  def initialize plist_file
    @dirty = false
    @plist_file = plist_file
    @plist = Plist::parse_xml plist_file

    @lines = @plist["Entry Text"].split("\n").collect do |line|
      TaggedLine::new(line)
    end

    @tagged_lines = @lines.select { |l| l.has_tags? }
  end

  # Convert to plist myself - don't want nasty string indenting mucking up entries
  def to_plist_node
    content = []
    content << "<dict>\n"
    content << @plist.collect {|k,v| ["<key>#{k}</key>\n", Plist::Emit::plist_node(v)] }
    content << "</dict>\n"
    content.flatten.join
  end

  def write _file = @plist_file
    puts "Writing #{_file}"
    save_plist _file
  end

  def collect_tagged_lines!
    @tagged_lines.collect! do |l|
      
      new_line = yield l.line

      @dirty = true if l.line != new_line

      l.line = new_line

      l
    end

    @plist["Entry Text"] = @lines.collect {|l| l.line}.join("\n")
  end

end # class DayOneEntry


# ---------------------------------------------------------------------------------------------------------------------
# A DayOne Entry

class Test < Thor
  include Thor::Actions

  desc "tags", "Find all tags"
  default_task :tags
  method_option :oftag, :type => :string, :required => false, :default=> "@of", :aliases => "-t"
  method_option :journal, :type => :string, :required => false, :aliases => "-j"
  method_option :ignore_dirs, :type => :array, :required => false, :default=> [], :aliases => "-i"

  def tags
    @ignore_dirs = options[:ignore_dirs].collect {|d| File.expand_path d}
    @ignore_dirs << File.expand_path("~/Library")
    oftag = options[:oftag]

    journals = if options[:journal]
      [options[:journal]]
    else
      self.class.find_journals @ignore_dirs 
    end

    @allentries = journals.collect do |j|
      Dir["#{j}/**/*.doentry"].collect { |j| DayOneEntry.new j }
    end.flatten

    @allentries.collect! do |entry|
      entry.collect_tagged_lines! do |line|
        if TaggedLine::get_tags(line).include? oftag
          line = line.gsub(oftag, "#{oftag}_sent")
          send_task_to_omnifocus_inbox line, ""
        end
        line
      end
      entry
    end

    @allentries.select {|e| e.dirty}.each do |e|
      e.write
    end

  end # def tags


  private

  def send_to_omnifocus _line
    add_task_to_omnifocus_inbox _line, ""
  end

  # Syntactic sugar - all methods in the below block are
  # class methods
  class << self

    def exec com_str
      %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
    end

    def find_journals ignore_dirs
      journals =  exec %q{mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"}
      journals.select { |j| !(ignore_dirs.select{ |id| j =~ %r{^#{id}} }.size > 0) }
    end

  end

end



Test.start