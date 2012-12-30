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

    @tag_store = Test::get_tag_store

    all_lines = @tag_store.tagged_lines

    if filter
      all_lines.collect! do |tl|
        tl if tl.has_tag filter
      end.uniq!
    end

    pp @tag_store.tags.keys


  end # def tags

  private

  def self.exec com_str
    %x{#{com_str}}.split("\n").collect { |item| item.rstrip}
  end

  def self.find_journals
    journals =  exec %q{mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"}
    lib_dir = File.expand_path "~/Library"
    journals.select {|j| !%r{^#{lib_dir}/.*$}}
  end

  def self.get_tag_store
    journals = find_journals

    tag_store = Gaz::TagStore.new do |ts|
      find_journals.each {|journal| ts.add_journal(journal) }
    end

    tag_store

  end

end

Test.start