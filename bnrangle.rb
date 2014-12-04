#!/usr/bin/env ruby

# batch name wrangler by Mehron Kugler
# version 0.0.1

# todo : deal with blank settings file
require 'fileutils'
require 'colored'

# .yellow is for help
# .green is for status/operational messages
# .red is for error messages
# .blue is for magic moments

def testing
  false #change to false when done testing
end

class SettingsFile

  attr_reader :fileLocation
  attr_accessor :savedFiles
  attr_accessor :savedSeriesActive
  attr_accessor :prepend
  attr_accessor :append
  attr_accessor :seriestxt

  def initialize
    @fileLocation = ".bnrangle"
    if readSettings[0].class == NilClass #blank line, new file
      tempLoad = Array.new
      @savedFiles = tempLoad
      @savedSeriesActive = false
      @prepend = ""
      @append = ""
      @seriestxt = ""
    else
      tempLoad = readSettings[0]#.gsub(/ /, '') # if (IO.readlines(@fileLocation) != "")
      @savedFiles = tempLoad.chomp.split(",") #loads as array automatically
      @savedSeriesActive = false
      @savedSeriesActive = true if format_seriestxt != "" # now depends on whether there is content in seriestxt
      @prepend = format_prepend
      @append = format_append
      @seriestxt = format_seriestxt
    end

  end

  def readSettings
    if !File.exist? @fileLocation
      puts "Didn't see .bnrangle file here, creating new file."
      FileUtils.touch(".bnrangle")
    end
    IO.readlines(@fileLocation)
  end

  def writeSettings(filestosave, seriesboolean, prepend_text, append_text, series_string)
    # receive an array joined by ',' -- needs to be string
      open(@fileLocation, "w") do |writefile|
        # scrub extra characters so it's only comma-separated values and no spaces, for easy reading
        puts "(writeSettings)".green + " Going to remember the following files: #{filestosave}" if testing
        writefile.puts filestosave
        writefile.puts "series active = " + "#{seriesboolean}"
        writefile.puts "prepend = #{prepend_text}"
        writefile.puts "append = #{append_text}"
        writefile.puts "seriestxt = #{series_string}"
      end
      if testing
        puts "(writeSettings) Contents of .bnrangle now:"
        puts `cat .bnrangle`
      end
  end

  def file_is_duplicate(filetocheck)
    true if @savedFiles.include? filetocheck
  end

  def clear_settings
    puts "(Clear settings)".green + " Making new .bnrangle file. Is this what you want? Type Y or N"
    answer = STDIN.gets.chomp
    if answer == "Y"
      FileUtils.touch(".bnrangle")
      writeSettings("", false, "", "", "")
    else
      puts "You typed: #{answer} -- Unless you type " + "Y".red + ", I won't clear settings."
    end
  end

  def format_prepend
    prepend = readSettings[2]
    prepend.slice!("prepend = ")
    prepend.chomp
  end

  def format_append
    append = readSettings[3]
    append.slice!("append = ")
    append.chomp
  end

  def format_seriestxt
    seriestxt = readSettings[4]
    seriestxt.slice!("seriestxt = ")
    seriestxt.chomp
  end

end

=begin

Begin all functions, etc.  

=end

def valid_commands
  ["add", "help", "series", "forget", "list", "clear", "prepend", "status", "append", "testrun", "rename"]
end

def command_parameter
  if !ARGV.first.nil?
    return ARGV.first
  else return "nil"
  end
end

def forgetting_files
  true if command_parameter == "forget" && ARGV.length > 1
end

def adding_files
  true if command_parameter == "add" && ARGV.length > 1
end

def changing_series
  true if command_parameter == "series" && ARGV.length == 2
end

def help_text
  puts "Batch Name Wrangler 0.0.1 by Mehron Kugler".green
  puts "This small program lets you rename a group of files in a list. Possible commands are are: \n"
  puts "add (followed by a list of files separated by spaces)".yellow + ": adds the specified files to your list for renaming."
  puts "forget (followed by files which you have already added):".yellow + " removes the specified files from your list."
  puts "clear".yellow + ": Wipes all settings. Use carefully."
  puts "prepend TEXT".yellow + ": Add the specified text to the beginning of each filename."
  puts "append TEXT".yellow + ": Put the specified text after each filename."
  puts "series TEXT".yellow + " (followed by a word or string of words in quotes): change all the *base filenames* of each file in your list to one description. E.g., base filename of \"EXAMPLE.jpg\" is EXAMPLE."
  #puts "- You can still prepend and append text if you have changed the names of all your files to one name."
  #puts "- series by itself will show the status of the SERIES variable."
  puts "status".yellow + ": Reminds you of the naming changes you want to make to your list of files."
  puts "testrun".yellow + ": Will do a test run of your filename changes."
  puts "help".yellow + ": this help text, which also shows up by running the program by itself."
end

def needs_help
  if command_parameter == "help" || ARGV.length == 0
    true
  else
    false
  end
end

def command_known
  valid_commands.include? command_parameter
end

def add_files
    addSession = SettingsFile.new
    #ARGV.drop(1) # remove the command parameter from the rest of the arguments

    ARGV.drop(1).each do |addfile| 
      if File.file?(addfile)
        if !addSession.file_is_duplicate(addfile)
          addSession.savedFiles << addfile
          # puts "Added #{addfile} to the files_in_progress array."
        else
          puts "(Add)".red + " Attention: That file, #{addfile}, already exists in the list, I won't add it."
        end
      else
        puts "(Add)".red + " I couldn't add \"#{addfile}\", did you type its location/name correctly?"
      end
    end
    # pass a string so it can be written in one line to the text file
    addSession.savedFiles.join(',')
end

def list_files
  addSession = SettingsFile.new
  puts "(List)".green + " The LIST command was requested." if testing
  puts "(List)".green + " List of files BNRangle will work on: #{addSession.savedFiles}"
end

def forget_files
  addSession = SettingsFile.new
  ARGV.drop(1).each do |remfile|
    if addSession.savedFiles.include? remfile
      puts "Forgetting ".green + remfile
      addSession.savedFiles.delete(remfile)
    else
      puts "(Forget)".red + " I couldn't find #{remfile} in the list of files to be modified, did you type it correctly or already remove it?"
    end
  end
  puts "(Forget)".green + " Finished forgetting, new list to be saved to file is: #{addSession.savedFiles}" if testing
  addSession.savedFiles.join(',')
end

def change_series
  addSession = SettingsFile.new
  if changing_series
    addSession.savedSeriesActive = true if ARGV[1] != "" # not blank, then changing series"
    addSession.savedSeriesActive = false if ARGV[1] == ""
    puts "(series)".green + " All filenames will be changed to: \"#{ARGV[1]}\""
    puts "(series)".green + " Based on what you typed, I will change all filenames: #{addSession.savedSeriesActive}"
    addSession.writeSettings(addSession.savedFiles.join(','), addSession.savedSeriesActive, addSession.prepend, addSession.append, ARGV[1])
  else
    # puts "(series) You want to change the basename of every file: #{addSession.savedSeriesActive}"
    puts "(series)".yellow + " You want to change all base filenames to: #{addSession.seriestxt}" if addSession.savedSeriesActive
    puts "(series)".yellow + " Use series to change all base filenames, not including appended or prepended text or file extension."
    puts "(series)".yellow + " Use series followed by \"\" to keep existing base names of files."
  end
end

def changing_prepend
  true if command_parameter == "prepend" && ARGV.length == 2
end

def change_prepend
  addSession = SettingsFile.new 
  if changing_prepend
    new_prepend_string = ARGV[1]
    puts "(prepend)".green + " Going to put \"#{new_prepend_string}\" in front of all filenames."
    puts "(prepend)".green + " Example filename will look like: \"#{new_prepend_string}DSC8478#{addSession.append}.jpg\""
    puts "(prepend)".yellow + " For readability, use an underscore mark \"_\" at the end of your PREPEND text."
    puts "(prepend)".yellow + " prepend \"\"\ will clear the prefix."
    addSession.writeSettings(addSession.savedFiles.join(','), addSession.savedSeriesActive, new_prepend_string, addSession.append, addSession.seriestxt)
  else
    puts "(prepend)".green + " I will put \"#{addSession.prepend}\" in front of all filenames." if addSession.prepend != ""
    puts "(prepend)".yellow + " Use \"prepend TEXT\" to place TEXT in front of all filenames." if addSession.prepend == ""
  end
end

def changing_append
  true if command_parameter == "append" && ARGV.length == 2
end

def change_append
  addSession = SettingsFile.new
  if changing_append
    new_append_string = ARGV[1]
    puts "(append)".green + " Going to put \"#{new_append_string}\" after all filenames."
    puts "(append)".green + " Example filename will look like \"#{addSession.prepend}DSC8478#{new_append_string}.jpg\""
    puts "(append)".yellow + " For readability, use an underscore mark \"_\" at the beginning of your APPEND text."
    puts "(append)".yellow + " append \"\" will clear the appended text."
    addSession.writeSettings(addSession.savedFiles.join(','), addSession.savedSeriesActive, addSession.prepend, new_append_string, addSession.seriestxt)
  else
    puts "(append)".green + " I will put \"#{addSession.append}\" after all filenames, but before file extensions." if addSession.append != ""
    puts "(append)".yellow + " Use \"append TEXT\" to place TEXT after all filenames, but before file extensions." if addSession.append == ""
  end
end

def show_status
  test = SettingsFile.new
  puts "(status)".green + " I will rename #{test.savedFiles.length} files: #{test.savedFiles}"
  # puts "(current settings) Series is: #{test.savedSeriesActive}"
  # puts "(status) I won't replace all base names of files using the series command." if !test.savedSeriesActive
  puts "(status)".green + " No numbers will be added after the filenames." if !test.savedSeriesActive
  puts "(status)".green + " Numbers starting at 1 will be added after filenames." if test.savedSeriesActive
  puts "(status)".green + " Prepended text: " + "#{test.prepend}".yellow
  puts "(status)".green + " Appended text: " + "#{test.append}".yellow
  puts "(status)".green + " All base filenames will be changed to: " + "#{test.seriestxt}".yellow if test.savedSeriesActive
  puts "(status)".green + " Final result: For example " + "#{example_changed_filename_string}".yellow
end

def example_changed_filename_string
  test = SettingsFile.new
  seriesnum = "_1" if test.savedSeriesActive
  basename = "EXAMPLE" if test.savedFiles.length == 0
  basename = File.basename(test.savedFiles[0], File.extname(test.savedFiles[0])) if test.savedFiles.length > 0
  extension = ".jpg" if test.savedFiles.length == 0
  extension = File.extname(test.savedFiles[0]) if test.savedFiles.length > 0
  basename = test.seriestxt if test.savedSeriesActive
  # filename = test.savedFiles.
  "\"#{test.prepend}" + "#{basename}" + "#{test.append}" + "#{seriesnum}" + "#{extension}" + "\""
end

# This assumes that there are files in the savedFiles array.
def changed_filename_string(source_file, index)
  test = SettingsFile.new
  indexresult = ""
  indexresult = "_#{index + 1}" if test.savedSeriesActive
  basename = File.basename(source_file, File.extname(source_file)) # get name of file without extension
  extension = File.extname(source_file)
  basename = test.seriestxt if test.savedSeriesActive
  basename = "#{test.prepend}" + "#{basename}" + "#{test.append}" + "#{indexresult}" + "#{extension}"
end

def testrun
  test = SettingsFile.new
  puts "(testrun)".green + " Going to simulate renaming of #{test.savedFiles.length} files."
  test.savedFiles.each do |renamefile|
    # show original
    # show renamed
    filefolder = File.dirname(File.expand_path(renamefile))
    newfile = "#{filefolder}/#{changed_filename_string(renamefile, test.savedFiles.index(renamefile))}"
    puts "(testrun)".green + " Changed #{filefolder}/#{renamefile} to\n    " + "#{newfile}".yellow
  end
end

# the real deal
def rename_files
  test = SettingsFile.new
  puts "(rename)".green + "Going to rename files. Use " + "testrun".yellow + " if you just want to test things first."
  puts "(rename)".green + "Continue? Y or N"
    answer = STDIN.gets.chomp
    if answer == "Y"
      # do stuff
      test.savedFiles.each do |renamefile|
        filefolder = File.dirname(File.expand_path(renamefile))
        oldfile = "#{filefolder}/#{renamefile}"
        newfile = "#{filefolder}/#{changed_filename_string(renamefile, test.savedFiles.index(renamefile))}"
        puts "(rename)".green + " Changed #{filefolder}/#{renamefile} to\n    " + "#{newfile}".yellow
        FileUtils.mv(oldfile, newfile)
      end
        puts "(rename)".green + " Created new .bnrangle file, we're done here.".blue
        FileUtils.touch(".bnrangle")
        test.writeSettings("", false, "", "", "")
    else
      puts "You typed: #{answer} -- Unless you type " + "Y".red + ", I won't rename anything."
    end

end

#
# TESTING

test = SettingsFile.new

# puts "(test input) Command parameter (first argument you typed) is \"#{command_parameter}\"" if testing
# puts "(test valid_commands): is what you typed in the array valid_commands? #{command_known}" if testing
# puts "SettingsFile.savedFiles.class: #{test.savedFiles.class}" if testing
# puts "SettingsFile.savedFiles.join(\",\").class: #{test.savedFiles.join(",").class}" if testing
# puts "(testing Clear) You requested to CLEAR the .bnrangle file." if command_parameter == "clear"



#
# WORKING

puts "(add)".yellow + " You wanted to add files, but didn't specify any." if command_parameter == "add" && ARGV.length == 1
test.writeSettings(add_files, test.savedSeriesActive, test.prepend, test.append, test.seriestxt) if adding_files         # WORKS

puts "(forget)".yellow + " You will need to tell me what files you want to forget from your active list." if command_parameter == "forget" && ARGV.length == 1
test.writeSettings(forget_files, test.savedSeriesActive, test.prepend, test.append, test.seriestxt) if forgetting_files  # WORKS

help_text if needs_help                                                 # WORKS

change_series if command_parameter == "series"                          # WORKS

list_files if command_parameter == "list"                               # WORKS

test.clear_settings if command_parameter == "clear"                     # WORKS

change_prepend if command_parameter == "prepend"                        # WORKS

show_status if command_parameter == "status"                            # WORKS (keep updated)

change_append if command_parameter == "append"                          # WORKS

testrun if command_parameter == "testrun"                               # WORKS

rename_files if command_parameter == "rename"                           # ?
=begin

clear_all_settings if command_parameter == "clear"
set_prepend if command_parameter == "prepend"
set_append if command_parameter == "append"
set_filename if command_parameter == "rename"

=end

