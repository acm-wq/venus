# frozen_string_literal: true

module Venus
  class BlurVideo
    def self.blur_video(input_file, output_file, path: nil, blur_intensity: 20)
      unless File.exist?(input_file)
        puts "File not found: #{input_file}"
        exit 1
      end

      unless blur_intensity.is_a?(Numeric) && blur_intensity >= 0
        puts 'Invalid blur intensity. It should be a non-negative number.'
        exit 1
      end

      output_file = "#{output_file}.mp4" unless output_file.end_with?('.mp4')
      output_path = path ? File.join(path, output_file) : File.join(Dir.pwd, output_file)

      command = "ffmpeg -i #{input_file} -vf 'boxblur=#{blur_intensity}:1' -c:a copy #{output_path}"
      execute_command(command)
    end

    def self.execute_command(command)
      Open3.popen3(command) do |_stdin, _stdout, stderr, wait_thr|
        while (line = stderr.gets)
          puts line
        end

        exit_status = wait_thr.value
        unless exit_status.success?
          puts "Error executing command: #{command}"
          exit 1
        end
      end
    end

    def self.process_arguments(args_string)
      args = args_string.split

      if args.length < 2 || args.length > 4
        puts 'Usage: ruby main.rb <input_file> <output_file> [path] [blur_intensity]'
        exit 1
      end

      args
    end
  end
end