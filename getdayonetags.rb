require "Thor"
require "pp"
require "PList"

def exec com_str
  %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
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
  end

  desc "get_tags", "Find all tags"
  def get_tags
    res = []

    find_entries.each do |e|
      pl = Plist::parse_xml(e)
      tags = pl["Entry Text"].split("\n").grep(%r{^.*(@[^\(\s]+)}) do |item|
        "Found #{$1}:\n#{item}"
      end
      res << tags if tags.size > 0
    end
    puts res.flatten
  end

end

Test.start