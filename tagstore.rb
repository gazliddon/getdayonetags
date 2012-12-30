# ---------------------------------------------------------------------------------------------------------------------

require "PList"
require "./cache.rb"
require 'digest/md5'

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

  attr_accessor :tags, :file

  def self.contains_tags? _str
    contains_tag_regex = %r{.*@\S+.*}
    return _str.match contains_tag_regex
  end

  def initialize str
    @tags = str.scan( %r{@[^(\s\:]+} ).uniq
    @line = str
  end

  def has_tag _tag
    ret = false
    _tag = [_tag] if _tag.class != Array

    _tag.each do |t|
      if ret == false
        ret = tags.include?(t)
      end
    end

    ret
  end

end # claa TaggedLine

# ---------------------------------------------------------------------------------------------------------------------
# A DayOne Entry

class DayOneEntry

  attr_accessor :tagged_lines, :tags, :md5

  def initialize plist_file, file_data
    @tagged_lines = []
    @tags = {}
    @plist = nil

      # Turn the plist file into a DayOneEntry
      # It's the original entry plus some information about
      # tags

      @plist = Plist::parse_xml file_data
      @md5 = Digest::MD5.hexdigest(file_data)

      @plist["File"] = plist_file
      @plist["Modification Time"] = File.mtime(plist_file)

      @plist["Entry Text"].split("\n").each do |line|
        if TaggedLine::contains_tags? line
          tl = TaggedLine::new(line)
          @tagged_lines <<  tl
        end
      end

      # Add what's need to @tags (Tag -> TaggedLine hash)
      @tagged_lines.each do |tagged_line|
        tagged_line.tags.each do |tag|
          if tagged_line.has_tag tag
            @tags[tag] ||= []
            @tags[tag] << tagged_line
          end
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
  attr_accessor :tagged_lines
  attr_accessor :tags

  @@plist_cache = Cache.new

  def initialize
    @tags = {}
    @tagged_lines = []
    yield self if block_given?
  end

  def add_journal journal
    # Add all of tags from this journal's entries to the tag store
    Dir["#{journal}/**/*.doentry"].each do |entry_file|
      
      day_one_entry = get_entry entry_file

      @tagged_lines.concat(day_one_entry.tagged_lines)
      @tags.merge!(day_one_entry.tags) do |key, v1, v2|
        v1 + v2
      end
    end
  end

  def get_entry file_name
    file_data = File.read(file_name)

    day_one_entry =  @@plist_cache.get(Digest::MD5.hexdigest(file_data)) do
      DayOneEntry.new file_name, file_data
    end
  end

  def dump
    pp @tagged_lines
  end

end # class TagStore

end # module Gaz


# ---------------------------------------------------------------------------------------------------------------------
# ends
