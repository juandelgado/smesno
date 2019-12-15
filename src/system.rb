class System

	def get_images(input)

		images = []
		files = Dir["#{input}/*"]
		
		files.each do |file|
			if Image.valid_image(file)
				images << file
			end
		end

		images
	end
end