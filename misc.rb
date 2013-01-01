
# Run a script and yield with procces return and process output
def run_script text
	out = ""
	ret = IO.popen('sh', 'r+') do |f|
		f.puts(text)
		f.close_write
		out = f.read
		yield $?, out if block_given?
	end
	out
end

# Run an apple script
def run_apple_script text
	# Cleanup the script text
	[
		[/\\/,"\\"],
		[/\n+\s*/, "\n"],
		[/\n+/,"\n"],
		[/\"/,"\\\""]
	].each {|src| text.gsub!(src[0],src[1])}

	# Execute the script
	args = "osascript" + text.split("\n").map{|l| " -e \"#{l}\""}.join
	out = run_script args do |proc_ret, proc_out|
		yield proc_ret, proc_out if block_given?
	end
	out
end

# Find out if an app is installed or not
def is_installed app_id
script = <<-eos
try
  tell application "Finder"
    return name of application file id "#{app_id}"
  end tell
on error err_msg number err_num
  return null
end try
	eos

	ret = run_apple_script(script).gsub(/\s+$/,"")
	ret != "null"
end


