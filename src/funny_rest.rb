# frozen_string_literal: true

# Processes all funnies except GIFs
class FunnyRest < Funny
  def process
    super
    converted_image = "#{@process_path}/#{@name}.png"

    #  Resize...
    Command.execute("convert \"#{@funny_file}\" \
                    #{IMAGE_PARAMS} \
                    \"#{converted_image}\"")

    # ...then video
    Command.execute("ffmpeg \
                    -loop 1 -f image2 \
                    -i \"#{converted_image}\" \
                    -t 5 -qscale:v 5 \
                    \"#{@output_video}\"")
  end
end
