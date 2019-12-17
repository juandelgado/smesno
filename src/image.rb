class Image

	IMAGE_PARAMS = "-resize 1024x768! -depth 8 -type TrueColor"

	GIF = '.gif'
	JPG = '.jpg'
	JPEG = '.jpeg'
	PNG = '.png'
	VALID_IMAGES = [GIF, JPG, JPEG, PNG]
	MIN_FRAMES = 24 * 5 # that should be 5 seconds

	def self.valid_image(file)
		VALID_IMAGES.include? File.extname(file).downcase
	end

	def initialize (path)
		@path = path
	end

	def process(process_path, index)

		ext = File.extname(@path).downcase
		name = File.basename(@path, ext)
		dir = process_path
		video = "#{dir}/#{index}.mpg"

		puts "Processing #{@path}\n"

		case ext

			when GIF

				# In theory, a single call to convert could do both GIF extraction
				# and resizing, but was giving weird results in several cases.
				# 2 different calls seem to deal with those cases much better.
				# Most likely an issue of my own!

				# First extract all frames
				Command.execute("convert -coalesce \"#{@path}\" #{dir}/frame_%05d.png")

				# Now resize them
				Command.execute("mogrify #{IMAGE_PARAMS} #{dir}/*.png")

				# For GIFs shorter than MIN_FRAMES we basically duplicate
				# them, otherwise they would quickly flash and would be
				# very hard to notice in the final output.

				frames = Dir["#{dir}/*"].sort
				total_frames = current_frame = frames.length

				if total_frames < MIN_FRAMES

					while true

						frames.each do |frame|

							FileUtils.cp(frame, dir + '/frame_' + ("%05d" % current_frame) + '.png')
							current_frame += 1
						end

						if current_frame >= MIN_FRAMES
							break
						end
					end
				end

				# Now generate video
				Command.execute("ffmpeg -i #{dir}/frame_%05d.png -qscale:v 5 #{video}")
			else

				converted_image = "#{dir}/#{name}.png"

				#  Resize...
				Command.execute("convert \"#{@path}\" #{IMAGE_PARAMS} \"#{converted_image}\"")

				# ...then video
				Command.execute("ffmpeg -loop 1 -f image2 -i \"#{converted_image}\" -t 5 -qscale:v 5 \"#{video}\"")
		end
	end
end
