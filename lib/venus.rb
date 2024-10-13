require 'open3'

module Venus
  class SplitVideo
    def self.split_video(input_file, output_prefix, format_segment, segment_duration, path: nil, format_video: nil)
      if format_segment == "min"
        segment_duration = segment_duration.to_i * 60
      elsif format_segment == "hour"
        segment_duration = segment_duration.to_i * 3600
      elsif format_segment == "sek"
        segment_duration = segment_duration.to_i
      else
        puts "Invalid format. Use 'min', 'hour' or 'sek'."
        exit 1
      end

      output_path = path ? File.join(path, "#{output_prefix}_%03d.mp4") : "#{output_prefix}_%03d.mp4"

      if format_video
        case format_video
        when "first"
          output_path = path ? File.join(path, "#{output_prefix}_001.mp4") : "#{output_prefix}_001.mp4"
          command = "ffmpeg -i #{input_file} -c copy -map 0 -t #{segment_duration} #{output_path}"
        when "end"
          command = "ffmpeg -i #{input_file} -c copy -map 0 -segment_time #{segment_duration} -f segment -reset_timestamps 1 #{output_path}"
          Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
            while line = stderr.gets
              puts line
            end

            exit_status = wait_thr.value
            unless exit_status.success?
              puts "Error executing command: #{command}"
              exit 1
            end
          end
          parts = Dir.glob("#{output_prefix}_*.mp4")
          parts.sort!
          File.delete(*parts[0...-1]) if parts.length > 1
          return
        else
          range = eval(format_video)
          command = "ffmpeg -i #{input_file} -c copy -map 0 -segment_time #{segment_duration} -f segment -reset_timestamps 1 #{output_path}"
          Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
            while line = stderr.gets
              puts line
            end

            exit_status = wait_thr.value
            unless exit_status.success?
              puts "Error executing command: #{command}"
              exit 1
            end
          end
          parts = Dir.glob("#{output_prefix}_*.mp4")
          parts.sort!
          parts.each_with_index do |part, index|
            unless range.include?(index + 1)
              File.delete(part)
            end
          end
          return
        end
      else
        command = "ffmpeg -i #{input_file} -c copy -map 0 -segment_time #{segment_duration} -f segment -reset_timestamps 1 #{output_path}"
      end

      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        while line = stderr.gets
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
      if args.length < 4 || args.length > 6
        puts "Usage: ruby main.rb <input_file> <output_prefix> <format_segment> <segment_duration> [path] [format_video]"
        exit 1
      end
      args
    end
  end
end