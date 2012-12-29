require "Thor"
require "pp"
require "PList"

def exec com_str
  %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
end

def get_tags_from_str str_with_tags
  ret = {}
  x = str_with_tags.scan( %r{@[^(\s]+} )
  ret[:tags] = x
  ret[:text] = str_with_tags
  ret
end


class Test < Thor

  include Thor::Actions

  desc "find_journals", "Find all journals"
  def find_journals
    journals =  exec %q{mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"}
    journals
  end

  desc "find_entries", "Find all journal entries"
  def find_entries
    journals = find_journals
    entries = journals.collect { |j| Dir["#{j}/**/*.doentry"]}.flatten
    uuid = {}

    entries = entries.select do |e|
      this_uuuid = e["UUID"]
      if uuid[this_uuuid]
        false
      else
        uuid[this_uuuid] = true
        true
      end
    end

    entries

  end

  desc "tags", "Find all tags"
  
  method_option :filter, :type => :array, :required => false, :aliases => "-f"

  def tags
    res = []
    filter = options[:filter]
    
    fp = filter ? lambda {|x| filter.include? x} : lambda {|x| true}

    find_entries.each do |e|

      entry = Plist::parse_xml(e)
      entry[:file] = e

      tags = entry["Entry Text"].split("\n").grep(%r{.*@\S+.*}) do |item|
        tags = get_tags_from_str(item)
        tags[:tags] = tags[:tags].select {|tag| fp.call tag}
        tags[:uuid] = entry["UUID"]
        entry[:tags] = tags unless tags[:tags].empty?
        res << entry unless tags[:tags].empty?
      end
    end


    res.each {|e| pp e[:tags]; puts}

  end # def tags


end

  Test.start