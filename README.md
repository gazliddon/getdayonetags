# Day One -> Omnifocus
Scans through all of your DayOne journal entries looking for lines with an @of tag. If it finds one the line is sent to your Omnifocus Inbox. The tag is then changed to @of_sent.

## Usage

	./getdayonetags.rb
	
## Run as a daemon
This script currently runs as a daemon on my machine but is a bit horribly hardcoded.

That major horrible assumption is your ruby is running under rvm

This how it works on my machine. First you need to copy the below files to a bin sub-directory in your home directory.

<pre>
_rvmruby
getdayonetags.rb
com.liddon.getdayonetags.plist
</pre>
	
So if your user name is garyliidon these files need to be in /Users/garyliddon/bin

You'll need to edit com.liddon.getdayonetags.plist so the WorkingDirectory key points at your user directory. It's currently set to out to mine. Make sure you have the gems you need installed by running bundle

Once everything is in place you do:

<pre>
$ cd ~
$ lunchy install bin/com.liddon.getdayonetags.plist
</pre>

And everything should be work. Initially I had the script to trigger every 15 seconds but this proved to be too frequent. DayOne saves your progress on IoS very frequently during editing so the cycle was:

* Start editing a line on IOS with the @of tag at the start
* App autosaves during editing
* getdayonetags runs, finds tag, sends to OF, writes tag back out as @of_sent
* Changes isn't picked up by IoS DayOne, I carry on editing the same line and we loop back to the start

I ended up with a load of versions of the same task in Omnifcous. I've now changed plist so the script runs every 10 minutes. I could still have the same problem but it's less likely and the amount of duplicates will be a lot lower.

Still a good proof that the concept works. I was editing on my iPad, my home mac picked up the change, it sent the tasks to OF running on that machine and my iPad picked up the new tasks on OF after syncing.

Still an awful mess tough. I'll make a nice install task in the rakefile. At some point.




	


