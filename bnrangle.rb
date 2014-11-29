#!/usr/bin/env ruby

# batch name wrangler

#require 'pathname'
require 'CSV'
#files_in_progress = CSV.parse(config_file.read)

# from https://stackoverflow.com/questions/6760883/reading-specific-lines-from-an-external-file-in-ruby-io


class SettingsFile

  attr_reader :fileLocation
  attr_reader :savedFiles
  attr_reader :savedSeries

  def initialize
    @fileLocation = ".bnrangle"
    @savedFiles = readSettings[0]
    @savedSeries = false
    @savedSeries = true if (readSettings[1].include? "true")
  end

  def readSettings
    IO.readlines(@fileLocation)
  end


  def writeSettings(*args)
    if args[0] != ""
      open('#{fileLocation}', "w") do |writefile|
        writefile << args[0].gsub(%r{\"}, '').gsub(%r{\[}, '').gsub(%r{\]}, '') #array of files in progress
        writefile << "series active = " + args[1] + ""
      end
    else
      puts "writeSettings: Tried to write settings to file but didn't give actual data (empty arguments)."
    end
  end

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
  true if command_parameter == "series" && ARGV.length == 2
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

def parameter_known
  if command_parameter == "help" || command_parameter == "add" || command_parameter == "series"
    true
  else
    false
  end
end

def add_files
  addSession = SettingsFile.new
  files_to_append = Array.new
    #ARGV.drop(1) # remove the command parameter from the rest of the arguments

    ARGV.drop(1).each do |addfile| 
      if File.file?(addfile)
        files_to_append << addfile
        # puts "Added #{addfile} to the files_in_progress array."
      else
        puts "I couldn't add \"#{addfile}\", did you type its location/name correctly?"
      end
    end
    puts "(testing add_files): The list of files to be added is: #{files_to_append}"

end

=begin
def add_files
  addSession = SettingsSession.new

  #ARGV.shift # remove the command parameter from the rest of the arguments
  if ARGV.length > 0
    ARGV.drop(1).each do |addfile| 
      if File.file?(addfile)
        addSession.files_in_progress << addfile
        puts "Added #{addfile} to the files_in_progress array."
      else
        puts "\"#{addfile}\" wasn't found to be an existing file, did you type it correctly?"
      end
    end
    addSession.files_in_progress
  end
  nil
end
=end

# evaluate the command paramenter

test = SettingsFile.new
=begin
puts "Command parameter (first argument you typed) is \"#{command_parameter}\""
puts "(test settingsFile class): fileLocation: #{test.fileLocation}"
puts "(test settingsFile class): saved array of files: #{test.savedFiles}"
puts "(test settingsFile class): saved series boolean: #{test.savedSeries}"

puts "(test parameter_unknown): is what you typed (\"#{command_parameter}\") a known command? \"#{parameter_known}\""
=end

puts "SettingsFile.savedFiles.class: #{test.savedFiles.class}"
puts "SettingsFile.savedFiles.split(\",\").class: #{test.savedFiles.split(",").class}"
puts ""



puts "Adding files was triggered (command parameter is \"#{command_parameter}\")" if adding_files
puts "A change of the \"series\" variable was REQUESTED (command parameter is \"#{command_parameter}\")" if command_parameter == "series"
puts "The \"series\" variable was (theoretically) CHANGED to \"#{ARGV[1]}\"." if changing_series 
puts "The HELP TEXT was requested (command paramemter is \"help\" or \"nil\")\n" if needs_help
help_text if needs_help
puts ""


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

