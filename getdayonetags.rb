require "Thor"
require "pp"
require "PList"

def exec com_str
  %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
end

def get_tags_from_str str_with_tags, filter
  ret = {}
  x = str_with_tags.scan( %r{@[^(\s]+} )
    ret[:tags] = x.select {|t| filter.call t}
    ret[:text] = str_with_tags
    ret
  end


  class Test < Thor
    include Thor::Actions

    def find_journals
      journals =  exec %q{mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"}
      lib_dir = File.expand_path "~/Library"
      journals.select {|j| !%r{^#{lib_dir}/.*$}}
    end

    def find_entries
      journals = find_journals
      entries = journals.collect { |j| Dir["#{j}/**/*.doentry"]}.flatten

      return entries
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
        entry["File"] = e
        entry["Modification Time"] = File.mtime(e)

        new_taggged_lines = entry["Entry Text"].split("\n").grep(%r{.*@\S+.*}).collect do |item|
          tags_in_line = get_tags_from_str(item, fp)
          if tags_in_line[:tags].empty?
            nil
          else
            tags_in_line[:entry] = entry
            tags_in_line
          end
        end.compact

        res = res + new_taggged_lines
      end

      pp res

  end # def tags


end

Test.start