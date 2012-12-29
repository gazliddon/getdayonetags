# ---------------------------------------------------------------------------------------------------------------------

require "PList"
require "cache"

# ---------------------------------------------------------------------------------------------------------------------

def get_tags_from_str str_with_tags
  {
    :tags => str_with_tags.scan( %r{@[^(\s]+} ),
    :text  => str_with_tags
  }
end


# ---------------------------------------------------------------------------------------------------------------------
class TaggedLine

  attr_accessor :tags

  def self.contains_tags? _str
    contains_tag_regex = %r{.*@\S+.*}
    return _str.match contains_tag_regex
  end

  def initialize str
    @tags = str_with_tags.scan( %r{@[^(\s]+} )
    @line = str
  end

end # claa TaggedLine

# ---------------------------------------------------------------------------------------------------------------------
class DayOneEntry
  
  attr_accessor :tagged_lines, :tags

  @tagged_lines = []
  @tags = {}            # Tag text -> TaggedLine has
  @plist = nil

  def initialize plist_file

      # Turn the plist file into a DayOneEntry
      # It's the original entry plus some information about
      # tags

      @plist = PList::parse_xml plist_file
      @plist["File"] plist_file
      @plist["Modification Time"] = File.mtime(plist_file)

      @plist["Entry Text"].split("\n").each do |line|
        @tagged_lines << TaggedLine.new(line) if TaggedLine.contains_tags line
      end

      # Add what's need to @tags (Tag -> TaggedLine hash)
      @taggged_lines.each do |tagged_line|
        tagged_line.tags.each do |tag|
          @tags[tag] |= []
          @tags << tagged_line
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

  @all_tagged_lines = []

  @@plist_cache = Cache do |plist_file|
    DayOneEntry.new plist_entry
  end

  def initialize
    yield self if block_given?
  end

  def add_journal journal
    Dir["#{journal}/**/*.doentry"] do |entry_file|
      day_one_entry =  @@plist_cache.get entry_file
    end
  end

end # class TagStore

# ---------------------------------------------------------------------------------------------------------------------
# ends