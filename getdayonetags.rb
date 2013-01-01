require "Thor"
require "pp"
require "Plist"

# ---------------------------------------------------------------------------------------------------------------------
# A DayOne Entry
class TaggedLine

  attr_accessor :tags, :line

  def initialize str
    @tags = str.scan( %r{@[^(\s\:]+} ).uniq
      @line = str
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
    save_plist _file
  end

  def collect_tagged_lines!
    modified = false

    @tagged_lines = @tagged_lines.collect do |l|

      old_line = l.line
      new_line = yield old_line

      @dirty = true if old_line != new_line

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
  method_option :exclude, :type => :array, :required => false, :default=> [], :aliases => "-f"
  method_option :match, :type => :array, :required => false, :default=> [], :aliases => "-m"
  method_option :seen, :type => :string, :required => false, :default=> "@omnifocus", :aliases => "-s"
  method_option :journal, :type => :string, :required => false, :aliases => "-j"

  def tags
    filter = options[:exclude]
    seen = options[:seen]

    journals = if options[:journal]
      [options[:journal]]
    else
      find_journals
    end

    @allentries = journals.collect do |j|
      puts "Opening journal #{j}"
      Dir["#{j}/**/*.doentry"].collect { |j| DayOneEntry.new j }
    end.flatten

    @allentries.each do |entry|

      entry.collect_tagged_lines! do |line|
        line + " @omnifocus"
      end

      if entry.dirty
        puts "Writing #{entry}"
        entry.write
      end
    end

  end # def tags

 
  private

  # Syntactic sugar - all methods in the below block are
  # class methods
  class << self

    def exec com_str
      %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
    end

    def find_journals
      journals =  exec %q{mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"}
      lib_dir = File.expand_path "~/Library"
      journals.select {|j| !%r{^#{lib_dir}/.*$}}
    end

  end

end



Test.start