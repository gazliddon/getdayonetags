# ---------------------------------------------------------------------------------------------------------------------

require "PList"
require "./cache.rb"

module Gaz
# ---------------------------------------------------------------------------------------------------------------------

def get_tags_from_str str_with_tags
  {
    :tags => str_with_tags.scan( %r{@[^(\s]+} ),
      :text  => str_with_tags
    }
  end

# ---------------------------------------------------------------------------------------------------------------------
# A line containting some tags
class TaggedLine

  attr_accessor :tags

  def self.contains_tags? _str
    contains_tag_regex = %r{.*@\S+.*}
    return _str.match contains_tag_regex
  end

  def initialize str
    @tags = str.scan( %r{@[^(\s]+} ).uniq
    @line = str
  end

end # claa TaggedLine

# ---------------------------------------------------------------------------------------------------------------------
# A DayOne Entry

class DayOneEntry

  attr_accessor :tagged_lines, :tags

  def initialize plist_file
    @tagged_lines = []
    @tags = {}
    @plist = nil

      # Turn the plist file into a DayOneEntry
      # It's the original entry plus some information about
      # tags

      @plist = Plist::parse_xml plist_file
      @plist["File"] = plist_file
      @plist["Modification Time"] = File.mtime(plist_file)

      @plist["Entry Text"].split("\n").each do |line|
        @tagged_lines << TaggedLine.new(line) if TaggedLine.contains_tags? line
      end

      # Add what's need to @tags (Tag -> TaggedLine hash)

      @tagged_lines.each do |tagged_line|
        tagged_line.tags.each do |tag|
          @tags[tag] ||= []
          @tags[tag] << tagged_line
        end
      end
    end

    def has_tags?
      return !@tags.empty?
    end

end # class DayOneEntry

# ---------------------------------------------------------------------------------------------------------------------
# Stores a load of tags with pointers to the lines that contain them

class TagStore
  attr_accessor :all_tagged_lines


  @@plist_cache = Gaz::Cache.new do |plist_file|
    DayOneEntry.new plist_file
  end

  def initialize
    @all_tagged_lines = []
    yield self if block_given?
  end

  def add_journal journal
    Dir["#{journal}/**/*.doentry"].each do |entry_file|
      day_one_entry =  @@plist_cache.get entry_file
      @all_tagged_lines.concat(day_one_entry.tagged_lines)
    end
  end

  def dump
    pp @all_tagged_lines
  end

end # class TagStore

end # module Gaz


# ---------------------------------------------------------------------------------------------------------------------
# ends
