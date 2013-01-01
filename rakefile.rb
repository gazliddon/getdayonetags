task :default do
	sh "ruby getdayonetags.rb -t @of -j out/testjournal.dayone"
end

task :copy do
	sh "rm -rf out && mkdir out"
	sh "cp -r testdata/* out"
end

task :live do
	file = "~/Dropbox/Apps/Day One/Journal.dayone"
	file = File.expand_path file
	sh %Q(cp -r "#{file}" out)
	sh "ruby getdayonetags.rb -t @of -j out/Journal.dayone"

#	sh "ruby getdayonetags.rb -i out"
end