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
Dir["temp/*"].each do |file| 
	File.delete(file) 
end

puts "Processing images"
# process input folder
# we pick up valid images,
# resize them and set them to RGB
Dir["input/*"].each do |file|
	
	if valid_image(file)
		
		ext = File.extname(file).downcase
		name = File.basename(file, ext)

		case ext
			when GIF
				system('convert -coalesce ' + file + ' -resize 1024x768! -channel RGB temp/' + name + '_frame_%05d.png');
			when JPG, JPEG, PNG
				system('convert ' + file  + ' -resize 1024x768! -channel RGB temp/' + name + '.png')
		end
	end
end

puts "About to rename all frames..."
i = 0
Dir["temp/*"].sort.each do |file|
	name = 'frame_' + ("%09d" % i) + '.png'
	File.rename(file, "temp/#{name}")
	i += 1
end

puts "Video time..."
system('ffmpeg -i temp/frame_%09d.png -r 24 output/gif.avi')