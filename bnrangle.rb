#!/usr/bin/env ruby

# batch name wrangler

#require 'pathname'
require 'CSV'
#files_in_progress = CSV.parse(config_file.read)

# from https://stackoverflow.com/questions/6760883/reading-specific-lines-from-an-external-file-in-ruby-io

class SettingsSession
  attr_accessor :files_in_progress
  attr_accessor :settingsFile
  attr_accessor :series_active

  def initialize
    @files_in_progress = Array.new
    @series_active = false
  end

  def load
    @settingsFile = IO.readlines(".bnrangle")
    @files_in_progress = CSV.parse_line(settingsFile[0])
    # series_active_state = SettingsFile[1]
    @series_active = true if settingsFile[1].include? "true"
  end

end

def command_parameter
  if !ARGV.first.nil?
    return ARGV.first
  else return "nil"
  end
end

def add_files

end


def take_action
  add_files if command_parameter == "add"
  ARGV.shift # remove the command parameter from the rest of the arguments
  ARGV.each do |addfile|
    
  end

end

progress = SettingsSession.new
progress.load
puts "Files in progress #{ progress.files_in_progress}"
puts "Series is active: #{ progress.series_active}"
puts "Command parameter (first argument) is \"#{command_parameter}\""



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

