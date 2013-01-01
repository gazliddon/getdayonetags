task :default do
	sh "ruby getdayonetags.rb -j out/testjournal.dayone"
end

task :copy do
	sh "rm -rf out && mkdir out"
	sh "cp -r testdata/* out"
end