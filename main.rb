require 'trollop'
require 'open3'
require 'fileutils'
require 'parallel'

require './system.rb'
require './image.rb'
require './log.rb'

start_time = Time.now

DEFAULT_OUTPUT_FILE_NAME = "gif.mpg"

# define options, check we have everything
# we need, etc
opts = Trollop::options do
	opt :input, "Input folder, where the GIFs are", :type => :string
	opt :output, "Output file path", :type => :string, :default => DEFAULT_OUTPUT_FILE_NAME
	opt :force_output, "Force output override"
end

Trollop::die :input, "No input folder" if opts[:input] == nil
Trollop::die :input, "Cannot find input folder" if !File.exists?(opts[:input])
Trollop::die :input, "Input folder doesn't look like a folder!" if !File.directory?(opts[:input])

if !opts[:force_output] and File.exists?(opts[:output])

	print "Output file already exists, override (y/n)? "
	answer = gets.chomp
	exit unless answer.downcase == "y"
end

begin 
	FileUtils.rm("gif.mpg")
	FileUtils.rm("log.txt")
rescue
	# nothing to do here
end

	FileUtils.rm_rf("temp")
	FileUtils.mkdir("temp")


# we are good to go from here onwards!

system = System.new
images = system.get_images(opts[:input])

abort("Couldn't find images in the input folder") unless images.length > 0

puts "#{images.length} images found"

results = Parallel.map_with_index(images) do |image, x|

	begin
		image_dir = "temp/#{x}"
		FileUtils.mkdir(image_dir)

		i = Image.new(image)
		i.process(image_dir, x)
	rescue
		puts "Error processing #{image}"
	end
end

puts "Video time..."

system('mv temp/*/*.mpg temp/')

# This way of joining the videos is recommended
# by FFMPEG. In theory, the cat command alone should
# suffice, but I've seen Ubuntu's MoviePlayer having trouble 
# with the output. The problem disappears doing a final encoding
# of the whole output by FFMPEF itself.
# So be it.

system('cat temp/*.mpg > temp/all.mpg')
system('ffmpeg -i temp/all.mpg output/gif.mpg')

total_time = (Time.now - start_time)
formatted_time = Time.at(total_time).gmtime.strftime('%Hh:%Mm:%Ss')
puts "Finished (#{formatted_time})"