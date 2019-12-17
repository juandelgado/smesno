# frozen_string_literal: true

# Wraps up calls to system commands
class Command
  def self.execute(command)
    stdin, stdout, stderr, wait_thr = Open3.popen3(command)

    # Adding this here because
    # otherwise calls to FFMPEG fail.
    # Would love to know WHY!
    out = stdout.read.chomp # rubocop:disable Lint/UselessAssignment

    stdin.close
    stdout.close
    stderr.close

    throw unless wait_thr.value.success?

    wait_thr.value
  end
end
