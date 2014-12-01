#!/usr/bin/env ruby

# batch name wrangler

#require 'pathname'
require 'CSV'
#files_in_progress = CSV.parse(config_file.read)

# from https://stackoverflow.com/questions/6760883/reading-specific-lines-from-an-external-file-in-ruby-io

def testing
  true #change to false when done testing
end

class SettingsFile

  attr_reader :fileLocation
  attr_accessor :savedFiles
  attr_accessor :savedSeries

  def initialize
    @fileLocation = ".bnrangle"
    tempLoad = readSettings[0].gsub(/ /, '') # if (IO.readlines(@fileLocation) != "")
    # tempLoad = Array.new if (IO.readlines(@fileLocation) == "")
    @savedFiles = tempLoad.chomp.split(",") #loads as array automatically
    @savedSeries = false
    @savedSeries = true if (readSettings[1].include? "on")
  end

  def readSettings
    IO.readlines(@fileLocation)
  end

  def writeSettings(filestosave, series)
    # receive an array joined by ','
      open(@fileLocation, "w") do |writefile|
        # scrub extra characters so it's only comma-separated values and no spaces, for easy reading
        puts "Going to write: #{filestosave}" if testing
        writefile.puts filestosave
        writefile.puts "series active = " + "#{series}"
      end
      if testing
        puts "Contents of .bnrangle now:"
        puts `cat .bnrangle`
      end
  end
end


def valid_commands
  ["add", "help", "series", "forget", "list"]
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
  true if command_parameter == "series" && ARGV.length == 2 && (ARGV[1] == "true" || ARGV[1] == "false")
end

def help_text
  puts "Batch Name Wrangler by Mehron Kugler"
  puts "Possible command-line arguments are: "
  puts "\"series\" followed by on or off: request that all filenames stored by the program end in a series of numbers going up from 1."
  puts "\"add\" followed by any number of files separated by spaces: adds the specified files to the Wrangler's memory for renaming."
  puts "\"forget\" followed by files which you have already added: removes the specified files from BNWrangler's memory."
  puts "\"help\": this help text, which also shows up by running the program without arguments."
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
        addSession.savedFiles << addfile
        # puts "Added #{addfile} to the files_in_progress array."
      else
        puts "I couldn't add \"#{addfile}\", did you type its location/name correctly?"
      end
    end
    # pass a string so it can be written in one line to the text file
    addSession.savedFiles.join(',')
end

def list_files
  addSession = SettingsFile.new
  puts "(testing list) The LIST command was requested." if testing
  puts "(test list) List of files BNRangle will work on: #{addSession.savedFiles}"
end

def forget_files
  addSession = SettingsFile.new

  ARGV.drop(1).each do |remfile|
    if addSession.savedFiles.include? remfile
      puts "Forgetting " + remfile
      addSession.savedFiles.delete(remfile)
    else
      puts "I couldn't find #{remfile} in the list of files to be modified, did you type it correctly?"
    end
  end
  puts "Finished forgetting, new list to be saved to file is: #{addSession.savedFiles}" if testing
  addSession.savedFiles.join(',')
end

def change_series
  addSession = SettingsFile.new
  if changing_series
    addSession.savedSeries = true if ARGV[1].include? "true"
    addSession.savedSeries = false if ARGV[1].include? "false"
    puts "Going to save series as: #{addSession.savedSeries}"
    addSession.writeSettings(addSession.savedFiles.join(','), addSession.savedSeries)
  else
    puts "The SERIES variable is set to: #{addSession.savedSeries} (will/will not add numbers starting at to all files.)"
  end
end

#
# TESTING

test = SettingsFile.new

puts "Command parameter (first argument you typed) is \"#{command_parameter}\"" if testing
puts "(test valid_commands): is what you typed in the array valid_commands? #{command_known}" if testing
puts "SettingsFile.savedFiles.class: #{test.savedFiles.class}" if testing
puts "SettingsFile.savedFiles.join(\",\").class: #{test.savedFiles.join(",").class}" if testing

#
# WORKING

puts "(ready) You wanted to add files, but didn't specify any." if command_parameter == "add"
test.writeSettings(add_files, test.savedSeries) if adding_files         # WORKS

puts "(ready) You wanted to forget files, but didn't specify any." if command_parameter == "forget"
test.writeSettings(forget_files, test.savedSeries) if forgetting_files  # WORKS

help_text if needs_help                                                 # WORKS

change_series if command_parameter == "series"                          # ?

list_files if command_parameter == "list"                               # WORKS


=begin


rem_files if command_parameter == "rem"
show_status if command_parameter == "status"
clear_all_settings if command_parameter == "clear"
set_prepend if command_parameter == "prepend"
set_append if command_parameter == "append"
set_filename if command_parameter == "rename"
list_files if command_parameter == "list"
config_series if command_parameter == "series"

save_progress
=end

