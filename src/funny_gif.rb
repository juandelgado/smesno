# frozen_string_literal: true

# Processes a funny gif
class FunnyGif < Funny
  def process
    super

    # In theory, a single call to `convert` could do both GIF extraction
    # and resizing, but was giving weird results in several cases.
    # 2 different calls seem to deal with those cases much better.
    # Most likely an issue of my own!
    extract
    resize

    # For GIFs shorter than MIN_FRAMES we basically duplicate
    # them, otherwise they would quickly flash and would be
    # very hard to notice in the final output.
    frames = Dir["#{@process_path}/*"].sort
    total_frames = current_frame = frames.length
    duplicate(frames, current_frame) if total_frames < MIN_FRAMES

    video
  end

  def extract
    Command.execute("convert -coalesce \
                     \"#{@funny_file}\" \
                     #{@process_path}/frame_%05d.png")
  end

  def duplicate(frames, current_frame)
    loop do
      frames.each do |frame|
        destination = @process_path + '/frame_' + \
                      format('%05<frame>d', frame: current_frame) \
                      + '.png'
        FileUtils.cp(frame, destination)
        current_frame += 1
      end

      break if current_frame >= MIN_FRAMES
    end
  end

  def resize
    Command.execute("mogrify #{IMAGE_PARAMS} #{@process_path}/*.png")
  end

  def video
    Command.execute("ffmpeg -i #{@process_path}/frame_%05d.png \
                    -qscale:v 5 #{@output_video}")
  end
end
