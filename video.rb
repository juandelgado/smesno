require 'open3'
require 'fileutils'

GIF = '.gif'
JPG = '.jpg'
JPEG = '.jpeg'
PNG = '.png'
VALID_IMAGES = [GIF, JPG, JPEG, PNG]

def valid_image(file)
	VALID_IMAGES.include? File.extname(file).downcase
end

puts "Clearing up temp folder"

FileUtils.rm("output/gif.mpg")
FileUtils.rm_rf("temp")
FileUtils.mkdir("temp")

# process input folder
# we pick up valid images,
# resize them and set them to RGB

files = Dir["input/*"]

puts "Processing #{files.length} files"

i = 0
files.each do |file|
	
	if valid_image(file)
		
		dir = "temp/#{i}"

		FileUtils.mkdir(dir)

		ext = File.extname(file).downcase
		name = File.basename(file, ext)
		video = "#{dir}/#{i}.mpg"

		case ext
			when GIF

				# In theory, a single call to convert could do both GIF extraction
				# and resizing, but was giving weird results in several cases.
				# 2 different calls seem to deal with those cases much better
				# most likely an issue of my own!
				
				# TODO, if less than 48 frames, let's loop the sequence, otherwise
				# can't almost see it
				system('convert -coalesce ' + file + ' ' + dir + '/frame_%05d.png')
				system('mogrify -resize 1024x768! -depth 8 -type TrueColor ' + dir + '/*.png')
				system('ffmpeg -i ' + dir + '/frame_%05d.png -qscale:v 5 ' + video)
			
			when JPG, JPEG, PNG
				converted_image = dir + '/' + name + '.png'
				system('convert ' + file  + ' -resize 1024x768! -depth 8 -type TrueColor ' + converted_image)
				system('ffmpeg -loop 1 -f image2 -i ' + converted_image + ' -t 5 -qscale:v 5 ' + video)
		end

		i += 1
	end
end

puts "Video time..."

system('mv temp/*/*.mpg temp/')

# This way of joining the videos is recommended
# by FFMPEG. In theory, the cat command alone should
# suffice, but I've seen MoviePlayer having trouble with the
# output. The problem disappears doing a final encoding
# by FFMPEF itself.
system('cat temp/*.mpg > temp/all.mpg')
system('ffmpeg -i temp/all.mpg output/gif.mpg')