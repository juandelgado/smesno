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
				system('convert -coalesce ' + file + ' -resize 1024x768! -channel RGB ' + dir + '/frame_%05d.png');
				system('ffmpeg -i ' + dir + '/frame_%05d.png -qscale:v 5 ' + video)
			when JPG, JPEG, PNG
				converted_image = dir + '/' + name + '.png'
				system('convert ' + file  + ' -resize 1024x768! -channel RGB ' + converted_image)
				system('ffmpeg -loop 1 -f image2 -i ' + converted_image + ' -t 5 -qscale:v 5 ' + video)
		end

		i += 1
	end
end

# now stitch all videos together!

puts "Video time..."

Dir["temp/*"].each do |item|
	name = File.basename(item)
	FileUtils.mv("#{item}/#{name}.mpg", "temp/")
end

system('cat temp/*.mpg > temp/all.mpg')
system('ffmpeg -i temp/all.mpg output/gif.mpg')