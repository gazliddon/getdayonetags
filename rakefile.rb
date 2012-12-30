# Rakefile
task :default do
	puts "Either:"
	puts "\trake tag_filter"
	puts "\trake all_tags"
end

task :filter_tags do
	 sh "ruby getdayonetags.rb tags -f @testag"
end

task :all_tags do
	 sh "ruby getdayonetags.rb tags"
end