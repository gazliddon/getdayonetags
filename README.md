# Day One -> Omnifocus
Scans through all of your DayOne journal entries looking for lines with an @of tag. If it finds one the line is sent to your Omnifocus Inbox. The tag is then changed to @of_sent.

## Usage

	./getdayonetags.rb
	
## Run as a daemon
This script currently runs as a daemon on my machine but is a bit horribly hardcoded.

That major horrible assumption is your ruby is running under rvm

This how it works on my machine. First you need to copy the below files to a bin sub-directory in your home directory.

		_rvmruby
		getdayonetags.rb
		com.liddon.getdayonetags.plist
	
So if your user name is garyliidon these files need to be in /Users/garyliddon/bin

You'll need to edit com.liddon.getdayonetags.plist so the WorkingDirectory key points at your user directory. It's currently set to out to mine. Make sure you have the gems you need installed by running bundle

Once everything is in place you do:

	cd ~
	lunchy install bin/com.liddon.getdayonetags.plist


And everything should be work, the script being run every 15 seconds.

What an awful mess. I'll make a nice install task in the rakefile. At some point.




	


