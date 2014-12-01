#!/usr/bin/env ruby

# batch name wrangler

#require 'pathname'
require 'CSV'
#files_in_progress = CSV.parse(config_file.read)

# from https://stackoverflow.com/questions/6760883/reading-specific-lines-from-an-external-file-in-ruby-io


class SettingsFile

  attr_reader :fileLocation
  attr_accessor :savedFiles
  attr_accessor :savedSeries

  def initialize
    @fileLocation = ".bnrangle"
    tempLoad = readSettings[0].gsub(/ /, '')
    @savedFiles = tempLoad.chomp.split(",") #loads as array automatically
    @savedSeries = false
    @savedSeries = true if (readSettings[1].include? "on")
  end

  def readSettings
    IO.readlines(@fileLocation)
  end

  def writeSettings(filestosave)
    # receive an array joined by ','
      open(@fileLocation, "w") do |writefile|
        # scrub extra characters so it's only comma-separated values and no spaces, for easy reading
        puts "Going to write: #{filestosave}"
        writefile.puts filestosave
        writefile.puts "series active = " + "#{@savedSeries}"
      end
      puts "Contents of .bnrangle now:"
      puts `cat .bnrangle`
  end

end


def valid_commands
  ["add", "help", "series"]
end

def command_parameter
  if !ARGV.first.nil?
    return ARGV.first
  else return "nil"
  end
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
  puts "\"help\": this help text, which also shows up by running the program without arguments."
end

def needs_help
  if command_parameter == "help" || command_parameter.nil?
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

def test_add_files
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
 puts "addSession.savedFiles: #{addSession.savedFiles}"
 puts "addSession.savedFiles.class should be array: it is #{addSession.savedFiles.class}"
 puts "Theoretically, the program would write to file: addSession.savedFiles.join(\',\'): #{addSession.savedFiles.join(',')}"
 puts "So will have to pass a joined array to the write function."
end

def change_series
  addSession = SettingsFile.new
  addSession.savedSeries = true if ARGV[1].include? "true"
  addSession.writeSettings(addSession.savedFiles, addSession.savedSeries)
end

def test_change_series
  addSession = SettingsFile.new
  puts "addSession class: #{addSession.class}"
  addSession.savedSeries = true if ARGV[1].include? "true" 
  puts "addSession.savedSeries value before writing: #{addSession.savedSeries}"
# evaluate the command paramenter
end

test = SettingsFile.new

puts "Command parameter (first argument you typed) is \"#{command_parameter}\""
puts "(test settingsFile class): fileLocation: #{test.fileLocation}"
puts "(test settingsFile class): saved array of files: #{test.savedFiles}"
puts "(test settingsFile class): saved series boolean: #{test.savedSeries}"

puts "(test valid_commands): is what you typed in the array valid_commands? #{command_known}"

puts "SettingsFile.savedFiles.class: #{test.savedFiles.class}"
puts "SettingsFile.savedFiles.join(\",\").class: #{test.savedFiles.join(",").class}"


puts "(testing input) Adding files was triggered (command parameter is \"#{command_parameter}\")" if adding_files
puts "(testing series) A change of the \"series\" variable was REQUESTED (command parameter is \"#{command_parameter}\")" if command_parameter == "series"
puts "(testing series) The \"series\" variable was (temporarily) CHANGED to \"#{ARGV[1]}\"." if changing_series 
puts "(testing help) The HELP TEXT was requested (command paramemter is \"help\" or \"nil\")\n" if needs_help
help_text if needs_help
test_change_series if changing_series
#test_add_files if adding_files
test.writeSettings(add_files) if adding_files

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

