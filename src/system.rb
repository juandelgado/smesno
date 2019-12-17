# frozen_string_literal: true

class System
  def get_images(input)
    images = []
    files = Dir["#{input}/*"]

    files.each do |file|
      images << file if Image.valid_image(file)
    end

    images
  end
end
