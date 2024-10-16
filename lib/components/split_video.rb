# frozen_string_literal: true

module Venus
  class SplitVideo
    def self.split_video(input_file, output_prefix, format_segment, segment_duration, path: nil, format_video: nil)
      segment_duration = convert_duration(format_segment, segment_duration)
      return unless segment_duration

      output_path = path ? File.join(path, "#{output_prefix}_%03d.mp4") : "#{output_prefix}_%03d.mp4"

      command = build_command(input_file, output_path, segment_duration, format_video, path, output_prefix)
      execute_command(command)

      handle_format_video(format_video, output_prefix, segment_duration, path) if format_video
    end

    def self.convert_duration(format_segment, segment_duration)
      case format_segment
      when 'min'
        segment_duration.to_i * 60
      when 'hour'
        segment_duration.to_i * 3600
      when 'sek'
        segment_duration.to_i
      else
        puts "Invalid format. Use 'min', 'hour' or 'sek'."
        nil
      end
    end

    def self.build_command(input_file, output_path, segment_duration, format_video, path, output_prefix)
      if format_video == 'first'
        output_path = path ? File.join(path, "#{output_prefix}_001.mp4") : "#{output_prefix}_001.mp4"
        "ffmpeg -i #{input_file} -c copy -map 0 -t #{segment_duration} #{output_path}"
      else
        "ffmpeg -i #{input_file} -c copy -map 0 -segment_time #{segment_duration} -f segment -reset_timestamps 1 #{output_path}"
      end
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

    def self.handle_format_video(format_video, output_prefix, _segment_duration, _path)
      parts = Dir.glob("#{output_prefix}_*.mp4").sort
      case format_video
      when 'end'
        File.delete(*parts[0...-1]) if parts.length > 1
      else
        range = eval(format_video)
        parts.each_with_index { |part, index| File.delete(part) unless range.include?(index + 1) }
      end
    end

    def self.process_arguments(args_string)
      args = args_string.split
      if args.length < 4 || args.length > 6
        puts 'Usage: ruby main.rb <input_file> <output_prefix> <format_segment> <segment_duration> [path] [format_video]'
        exit 1
      end
      args
    end
  end
end
