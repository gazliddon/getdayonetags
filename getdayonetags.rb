require "Thor"
require "pp"

require "tagstore.rb"

class Test < Thor
  include Thor::Actions

  desc "tags", "Find all tags"
  method_option :filter, :type => :array, :required => false, :aliases => "-f"

  def tags
    filter = options[:filter]
    fp = filter ? lambda {|x| filter.include? x} : lambda {|x| true}

    tag_store = TagStore.new do |ts|
      find_journals.each {|journal| ts.add_journal journal}
    end

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