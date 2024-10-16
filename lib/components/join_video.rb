# frozen_string_literal: true

module Venus
  class JoinVideo
    def self.join_video(input_file1, input_file2, output_file, path: nil)
      [input_file1, input_file2].each do |file|
        unless File.exist?(file)
          puts "File not found: #{file}"
          exit 1
        end
      end

      output_file = "#{output_file}.mp4" unless output_file.end_with?('.mp4')
      output_path = path ? File.join(path, output_file) : File.join(Dir.pwd, output_file)

      temp_file = Tempfile.new('input_list')
      temp_file.puts("file '#{File.absolute_path(input_file1)}'")
      temp_file.puts("file '#{File.absolute_path(input_file2)}'")
      temp_file.close

      command = "ffmpeg -f concat -safe 0 -i #{temp_file.path} -c copy #{output_path}"
      execute_command(command)

      temp_file.unlink
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
      if args.length != 3
        puts 'Usage: ruby main.rb <input_file1> <input_file2> <output_file>'
        exit 1
      end

      args
    end
  end
end
