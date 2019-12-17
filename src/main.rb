# frozen_string_literal: true

require 'trollop'
require 'open3'
require 'fileutils'
require 'parallel'
require 'tmpdir'

require './system.rb'
require './funny.rb'
require './funny_gif.rb'
require './funny_rest.rb'
require './command.rb'

start_time = Time.now

DEFAULT_OUTPUT_FILE_NAME = 'gif.mpg'

# define options, check we have everything
# we need, etc
opts = Trollop.options do
  opt :input, 'Input folder, where the GIFs are', type: :string
  opt :output, 'Output file path',
      type: :string, default: DEFAULT_OUTPUT_FILE_NAME
  opt :force_output, 'Force output override'
end

Trollop.die :input, 'No input folder' if opts[:input].nil?
Trollop.die :input, 'Cannot find input folder' unless File.exist?(opts[:input])
unless File.directory?(opts[:input])
  Trollop.die :input, "Input folder doesn't look like a folder!"
end

if !opts[:force_output] && File.exist?(opts[:output])

  print 'Output file already exists, override (y/n)? '
  answer = gets.chomp
  exit unless answer.downcase == 'y'
end

FileUtils.rm(opts[:output]) if File.exist?(opts[:output])

# creates a temp dir for us
temp = Dir.mktmpdir

funnies = System.new.get_funnies(opts[:input])

abort("Couldn't find funnies in the input folder") if funnies.empty?

puts "#{funnies.length} funnies found"

Parallel.map_with_index(funnies) do |funny_file, index|
  begin
    tmp_folder = "#{temp}/#{index}"
    FileUtils.mkdir(tmp_folder)

    f = Funny.get(funny_file, tmp_folder, index)
    f.process
  rescue StandardError => e
    puts "\tError processing #{funny_file}"
    puts "\t\t#{e.message}"
  end
end

puts 'Video time...'

Command.execute("mv #{temp}/*/*.mpg #{temp}/")

# This way of joining the videos is recommended
# by FFMPEG. In theory, the cat command alone should
# suffice, but I've seen Ubuntu's MoviePlayer having trouble
# with the output. The problem disappears doing a final encoding
# of the whole output by FFMPEF itself.
# So be it.

Command.execute("cat #{temp}/*.mpg > #{temp}/all.mpg")
Command.execute("ffmpeg -i #{temp}/all.mpg #{opts[:output]}")

puts 'Cleaning up, almost done...'

FileUtils.rm_rf(temp)

total_time = (Time.now - start_time)
formatted_time = Time.at(total_time).gmtime.strftime('%Hh:%Mm:%Ss')
puts "Finished (#{formatted_time})"
