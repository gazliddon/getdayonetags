# getdayonetags : Day One -> Omnifocus
Hunts through Day One entries for stuff I've tagged and bungs them into Omnifocus

## Status
Doesn't work :)

## Detail
When I'm typing my journal I find all sorts of ideas or things to do bubbling up that I'd like to capture. I lose a lot of flow if I stop then and there and go and do the thing I'm thinking of so I like to tag a line with something I can search for later. Here's an example:

<code>
	@todo Can I get Andrescou slides for talk?
<code>

I find going through my Day One notes and fishing these out a bit tedious though and all I do is chuck them into my Omnifocus InBox for sorting and classifying anyway.

So this script goes:

* Traverseses all of my Day One documents
* Finds any tagged lines
* Have I:
	* Never seen this tag item before?
	* Or has it changed?
	* or Have I never sent it to OF before?
* If that's true send to OF inbox

