# frozen_string_literal: true

# Class to interact with the file system
class System
  def get_funnies(input)
    funnies = []
    files = Dir["#{input}/*"]

    files.each do |file|
      funnies << file if Funny.valid_file(file)
    end

    funnies
  end
end
