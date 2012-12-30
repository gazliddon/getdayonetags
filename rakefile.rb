# Rakefile
task :default do
	puts "Either:"
	puts "\trake filter_tags"
	puts "\trake all_tags"
end

task :filter_tags do
	 sh "ruby getdayonetags.rb tags -f @testag"
end

task :all_tags do
	 sh "ruby getdayonetags.rb tags"
end