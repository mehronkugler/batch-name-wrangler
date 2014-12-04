batch-name-wrangler
===================

Small Ruby application to manage batch/bulk filename manipulation (work-in-progress).

This small program lets you rename a group of files in a list. Possible commands are are: 

add (followed by a list of files separated by spaces): adds the specified files to your list for renaming.
forget (followed by files which you have already added): removes the specified files from your list.
clear: Wipes all settings. Use carefully.
prepend TEXT: Add the specified text to the beginning of each filename.
append TEXT: Put the specified text after each filename.
series TEXT (followed by a word or string of words in quotes): change all the *base filenames* of each file in your list to one description. E.g., base filename of "EXAMPLE.jpg" is EXAMPLE.
status: Reminds you of the naming changes you want to make to your list of files.
testrun: Will do a test run of your filename changes.
rename: Renames your list of files based on your settings.
help: this help text, which also shows up by running the program by itself.

Using each command without any extra parameters will trigger extra help.
