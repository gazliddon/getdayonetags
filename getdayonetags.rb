require "Thor"
require "pp"

require "./tagstore.rb"

class Test < Thor
  include Thor::Actions

  desc "tags", "Find all tags"
  method_option :filter, :type => :array, :required => false, :aliases => "-f"

  def tags
    filter = options[:filter]
    tag_ok = filter ? lambda {|x| filter.include? x} : lambda {|x| true}

    tag_store = Gaz::TagStore.new do |ts|
      find_journals.each {|journal| ts.add_journal(journal) }
    end

    if filter
      all_lines = filter.each do |tag|
        tag_store.get_lines_with_tag tag
      end.flatten.uniq
    else
      all_lines = tag_store.tagged_lines
    end

    pp all_lines

  end # def tags

private

  def exec com_str
    %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
  end

  def find_journals
    journals =  exec %q{mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"}
    lib_dir = File.expand_path "~/Library"
    journals.select {|j| !%r{^#{lib_dir}/.*$}}
  end

end

Test.start