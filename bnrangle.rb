#!/usr/bin/env ruby

# batch name wrangler

require 'pathname'
require 'CSV'

attr_accessor :file_list
attr_reader :command_list
attr_reader :config_file

file_list = Array.new
config_file = ".bnrangle"
files_in_progress = File.open(config_file).first

def load_state
	

def eval_cli_arguments
	add_files if ARGV[0] == "add"
end

def add_files

end

