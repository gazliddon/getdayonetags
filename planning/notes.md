# Notes

## Now Find Journal Entries



## Find DayOne docs

### Solved
<pre>mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"</pre>


### Notes

Need to get a list of all DayOne docs. Using spotlight seems a good idea.

* mdfind to find things from the command line
* mdls to dump meta data spotlight has on a file

Stuff is stored here in what I think is a document bundle:

	/Users/garyliddon/Dropbox/Apps/Day\ One/Journal.dayone
			File type Day One Journal

And this is an example entry:

	/Users/garyliddon/Dropbox/Apps/Day\ One/Journal.dayone/entries/0FB2CC5ABDD54C5B9B26B31C3843B7BE.doentry

* ** Entries have no meta data :( **   
* ** Journals do! :) **

Dump at the end of the file of DayOne Journal's metadata but the most interesting is:
<pre>
kMDItemFSName                  = "Journal.dayone"

kMDItemContentType             = "com.dayoneapp.journal"

kMDItemContentTypeTree         = ("com.dayoneapp.journal"
	""com.apple.package",
	"public.directory",
	"public.item",
	"public.composite-content",
	"public.content"
</pre>

### Success
I can find two Day One journals

Use <pre>mdfind "kMDItemKind == 'Day One Journal'"</pre>

Results are <pre>/Users/garyliddon/Library/Containers/com.dayoneapp.dayone
/Users/garyliddon/Dropbox/apps/Day One/Journal.dayone</pre>

I don't want the first one so this is what works:

<pre>mdfind "kMDItemKind == 'Day One Journal' && kMDItemDisplayName =='Journal.dayone'"</pre>


## mdls dump for DayOne Journal
<pre>
kMDItemContentCreationDate     = 2012-12-29 07:28:53 +0000
kMDItemContentModificationDate = 2012-12-29 07:28:57 +0000
kMDItemContentType             = "com.dayoneapp.journal"
kMDItemContentTypeTree         = (
    "com.dayoneapp.journal",
    "com.apple.package",
    "public.directory",
    "public.item",
    "public.composite-content",
    "public.content"
)
kMDItemDateAdded               = 2012-12-29 07:28:55 +0000
kMDItemDisplayName             = "Journal.dayone"
kMDItemFSContentChangeDate     = 2012-12-29 07:28:57 +0000
kMDItemFSCreationDate          = 2012-12-29 07:28:53 +0000
kMDItemFSCreatorCode           = ""
kMDItemFSFinderFlags           = 0
kMDItemFSHasCustomIcon         = 0
kMDItemFSInvisible             = 0
kMDItemFSIsExtensionHidden     = 0
kMDItemFSIsStationery          = 0
kMDItemFSLabel                 = 0
kMDItemFSName                  = "Journal.dayone"
kMDItemFSNodeCount             = 2
kMDItemFSOwnerGroupID          = 20
kMDItemFSOwnerUserID           = 501
kMDItemFSSize                  = 399238
kMDItemFSTypeCode              = ""
kMDItemKind                    = "Day One Journal"
kMDItemLastUsedDate            = 2012-12-29 11:00:23 +0000
kMDItemLogicalSize             = 399238
kMDItemPhysicalSize            = 606208
kMDItemUseCount                = 1
kMDItemUsedDates               = (
    "2012-12-29 00:00:00 +0000"
)
</pre>

