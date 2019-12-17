# frozen_string_literal: true

# This class hides away the details of going from a funny
# (gif, static image or video) to a "normalized" video.
class Funny
  IMAGE_PARAMS = '-resize 1024x768! -depth 8 -type TrueColor'
  GIF = '.gif'
  JPG = '.jpg'
  JPEG = '.jpeg'
  PNG = '.png'
  VALID_FILES = [GIF, JPG, JPEG, PNG].freeze
  MIN_FRAMES = 24 * 5 # that should be 5 seconds

  def self.get(funny_file, process_path, index)
    case File.extname(funny_file).downcase
    when GIF
      FunnyGif.new(funny_file, process_path, index)
    else
      FunnyRest.new(funny_file, process_path, index)
    end
  end

  def self.valid_file(file)
    VALID_FILES.include? File.extname(file).downcase
  end

  def initialize(funny_file, process_path, index)
    @funny_file = funny_file
    @process_path = process_path
    @index = index
    @ext = File.extname(@funny_file).downcase
    @name = File.basename(@funny_file, @ext)
    @output_video = "#{@process_path}/#{@index}.mpg"
  end

  def process
    puts "Processing #{@funny_file}"
  end
end
