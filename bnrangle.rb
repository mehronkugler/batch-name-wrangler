#!/usr/bin/env ruby

# batch name wrangler

#require 'pathname'
require 'CSV'
#files_in_progress = CSV.parse(config_file.read)

# from https://stackoverflow.com/questions/6760883/reading-specific-lines-from-an-external-file-in-ruby-io

class SettingsSession
  attr_accessor :files_in_progress
  attr_accessor :settingsRead
  attr_accessor :series_active
  attr_reader :settingsFile

  def initialize
    @settingsFile = ".bnrangle"
    @settingsRead = IO.readlines(@settingsFile)
    @files_in_progress = CSV.parse_line(@settingsRead[0])
    @series_active = false
    @series_active = true if @settingsRead[1].include? "true"
  end

  def save
    open(@settingsFile, "w") do |writefile|
      writefile << add_files
      writefile << "series_active = #{@series_active}"
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

# evaluate the command paramenter


progress = SettingsSession.new

puts "Command parameter (first argument) is \"#{command_parameter}\""
puts "Did not add any files." if adding_files == false
puts "Series is active: #{ progress.series_active}"
puts "Everything you typed: #{ARGV}"

if adding_files == true
  progress.files_in_progress << add_files if add_files != nil
  puts "Files in progress (adding files = #{adding_files}: #{ progress.files_in_progress}" if adding_files == true
end

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

