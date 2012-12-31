# ---------------------------------------------------------------------------------------------------------------------

require "PList"
require "./cache.rb"
require "./tagdatabase.rb"
require 'digest/md5'

module Gaz

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

end # class TaggedLine

# ---------------------------------------------------------------------------------------------------------------------
# A DayOne Entry
class DayOneEntry

  attr_accessor :tagged_lines, :tags, :md5, :file

  def initialize plist_file, file_data
    @tagged_lines = []
    @tags = {}
    @plist = nil

      # Turn the plist file into a DayOneEntry
      # It's the original entry plus some information about
      # tags

      @plist = Plist::parse_xml file_data
      @md5 = Digest::MD5.hexdigest(file_data)

      @file = plist_file

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
  @@tagdb = TagDatabase.new

  def initialize
    @tags = {}
    @tagged_lines = []
    yield self if block_given?
  end

  def has_this_file_changed? day_one_entry
    md5 = day_one_entry.md5
    file = day_one_entry.file
    !@@tagdb.in_database?(file, md5)
  end

  def add_to_database day_one_entry
    md5 = day_one_entry.md5
    file = day_one_entry.file

    # was there an old version of the same file?
    old_file = @@tagdb.find_file file

    if old_file
      # cycle through the lines we've previously sent to
      # OF
      old_file[:tagged_lines].each do |line|
        text = line[]
      end
    end

    # was there an old version of the same file?

    db_entry = @@tagdb.add_to_database(file, md5)

    day_one_entry
  end

  def add_journal journal
    # Add all of tags from this journal's entries to the tag store
    entries_to_scan_for_tags = []

    Dir["#{journal}/**/*.doentry"].each do |entry_file|
      day_one_entry = get_entry entry_file

      if has_this_file_changed? day_one_entry
        entries_to_scan_for_tags << day_one_entry
      end
    end

    entries_to_scan_for_tags.each do |entry|

        @tagged_lines.concat(entry.tagged_lines)
        @tags.merge!(entry.tags) { |key, v1, v2| v1 + v2}
        
        db_entry = add_to_database entry

        puts "Added #{entry.file}"
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
