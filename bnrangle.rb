#!/usr/bin/env ruby

# batch name wrangler by Mehron Kugler
# version 0.0.1

# todo : deal with blank settings file
require 'fileutils'

def testing
  true #change to false when done testing
end

class SettingsFile

  attr_reader :fileLocation
  attr_accessor :savedFiles
  attr_accessor :savedSeries
  attr_accessor :prepend

  def initialize
    @fileLocation = ".bnrangle"
    if readSettings[0].class == NilClass #blank line, new file
      tempLoad = Array.new
      @savedFiles = tempLoad
      @savedSeries = false
      @prepend = ""
    else
      tempLoad = readSettings[0].gsub(/ /, '') # if (IO.readlines(@fileLocation) != "")
      @savedFiles = tempLoad.chomp.split(",") #loads as array automatically
      @savedSeries = false
      @savedSeries = true if (readSettings[1].include? "on")
      @prepend = format_prepend
    end

  end

  def readSettings
    if !File.exist? @fileLocation
      puts "Didn't see .bnrangle file here, creating new file."
      FileUtils.touch(".bnrangle")
    end
    IO.readlines(@fileLocation)
  end

  def writeSettings(filestosave, series, prepend)
    # receive an array joined by ',' -- needs to be string
      open(@fileLocation, "w") do |writefile|
        # scrub extra characters so it's only comma-separated values and no spaces, for easy reading
        puts "Going to write: #{filestosave}" if testing
        writefile.puts filestosave
        writefile.puts "series active = " + "#{series}"
        writefile.puts "prepend = #{prepend}"
      end
      if testing
        puts "Contents of .bnrangle now:"
        puts `cat .bnrangle`
      end
  end

  def file_is_duplicate(filetocheck)
    true if @savedFiles.include? filetocheck
  end

  def clear_settings
    puts "(Clear settings) Making new .bnrangle file. Is this what you want? Type Y or N"
    answer = STDIN.gets.chomp
    if answer == "Y"
      FileUtils.touch(".bnrangle")
      writeSettings("", false, "")
    else
      puts "You typed: #{answer} -- Unless you type Y, I won't clear settings."
    end
  end

  def format_prepend
    prepend = readSettings[2]
    prepend.slice!("prepend = ")
    prepend.chomp
  end


end


def valid_commands
  ["add", "help", "series", "forget", "list", "clear", "prepend", "status"]
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
  puts "Batch Name Wrangler 0.0.1 by Mehron Kugler\n"
  puts "Possible command-line arguments are: "
  puts "series (followed by \"on\" or \"off\"): request that all filenames stored by the program end in a series of numbers going up from 1."
  puts "series by itself will show the status of the SERIES variable."
  puts "add (followed by a list of files separated by spaces): adds the specified files to the Wrangler's memory for renaming."
  puts "forget (followed by files which you have already added): removes the specified files from BNWrangler's memory."
  puts "clear: Wipes all settings. Use carefully."
  puts "prepend: Add the specified text to the beginning of each filename to be modified."
  puts "help: this help text, which also shows up by running the program without arguments."
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
          puts "(Add) Attention: That file, #{addfile}, already exists in the list, I won't add it."
        end
      else
        puts "(Add) I couldn't add \"#{addfile}\", did you type its location/name correctly?"
      end
    end
    # pass a string so it can be written in one line to the text file
    addSession.savedFiles.join(',')
end



def list_files
  addSession = SettingsFile.new
  puts "(List) The LIST command was requested." if testing
  puts "(List) List of files BNRangle will work on: #{addSession.savedFiles}"
end

def forget_files
  addSession = SettingsFile.new

  ARGV.drop(1).each do |remfile|
    if addSession.savedFiles.include? remfile
      puts "Forgetting " + remfile
      addSession.savedFiles.delete(remfile)
    else
      puts "(Forget) I couldn't find #{remfile} in the list of files to be modified, did you type it correctly or already remove it?"
    end
  end
  puts "(Forget) Finished forgetting, new list to be saved to file is: #{addSession.savedFiles}" if testing
  addSession.savedFiles.join(',')
end

def change_series
  addSession = SettingsFile.new
  if changing_series
    addSession.savedSeries = true if ARGV[1].include? "true"
    addSession.savedSeries = false if ARGV[1].include? "false"
    puts "(Series) Going to save series as: #{addSession.savedSeries}"
    addSession.writeSettings(addSession.savedFiles.join(','), addSession.savedSeries)
  else
    puts "(Series) The SERIES variable is set to: #{addSession.savedSeries} (will/will not add numbers starting at to all files.)"
  end
end

def changing_prepend
  true if command_parameter == "prepend" && ARGV.length == 2
end

def change_prepend
  addSession = SettingsFile.new
  new_prepend_string = ARGV[1]
  puts "(prepend) Going to put \"#{new_prepend_string}\" in front of all filenames."
  puts "(prepend) Example filename will look like: \"#{new_prepend_string}DSC8478.jpg\""
  puts "(prepend) Remember to use quotes if you want to put a space between the prefix and the filename itself."
  addSession.writeSettings(addSession.savedFiles.join(','), addSession.savedSeries, new_prepend_string)
end

#
# TESTING

test = SettingsFile.new

puts "(test input) Command parameter (first argument you typed) is \"#{command_parameter}\"" if testing
puts "(test valid_commands): is what you typed in the array valid_commands? #{command_known}" if testing
# puts "SettingsFile.savedFiles.class: #{test.savedFiles.class}" if testing
# puts "SettingsFile.savedFiles.join(\",\").class: #{test.savedFiles.join(",").class}" if testing
# puts "(testing Clear) You requested to CLEAR the .bnrangle file." if command_parameter == "clear"

puts "(current settings) File list: #{test.savedFiles}"
puts "(current settings) Series is: #{test.savedSeries}"
puts "(current settings) Prepend is: \"#{test.prepend}\""

#
# WORKING

puts "(ready) You wanted to add files, but didn't specify any." if command_parameter == "add" && ARGV.length == 1
test.writeSettings(add_files, test.savedSeries, test.prepend) if adding_files         # WORKS

puts "(ready) You wanted to forget files, but didn't specify any." if command_parameter == "forget"
test.writeSettings(forget_files, test.savedSeries, test.prepend) if forgetting_files  # WORKS

help_text if needs_help                                                 # WORKS

change_series if command_parameter == "series"                          # WORKS

list_files if command_parameter == "list"                               # WORKS

test.clear_settings if command_parameter == "clear"                     # WORKS

change_prepend if changing_prepend                                      # ?

=begin

clear_all_settings if command_parameter == "clear"
set_prepend if command_parameter == "prepend"
set_append if command_parameter == "append"
set_filename if command_parameter == "rename"

=end

