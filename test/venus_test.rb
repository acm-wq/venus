# frozen_string_literal: true

require 'minitest/autorun'
require 'venus'

class VenusTest < Minitest::Test
  def setup
    @input_file = 'video.mp4'
    @split_output_prefix = 'split_video'
    @blur_output_file = 'blurred_video'
    @join_output_file = 'joined_video'
    @segment_duration = 10
    @blur_intensity = 20
  end

  def test_split_video
    puts "Starting test_split_video"
    Venus::SplitVideo.split_video(@input_file, @split_output_prefix, 'min', @segment_duration)
    assert Dir.glob("#{@split_output_prefix}_*.mp4").any?, 'Split video files were not created'
    puts "Finished test_split_video"
  end

  def test_blur_video
    puts "Starting test_blur_video"
    BlurVideo.blur_video(@input_file, @blur_output_file, blur_intensity: @blur_intensity)
    assert File.exist?("#{@blur_output_file}.mp4"), 'Blurred video file was not created'
    puts "Finished test_blur_video"
  end

  def test_join_video
    puts "Starting test_join_video"
    split_files = Dir.glob("#{@split_output_prefix}_*.mp4")
    if split_files.size >= 2
      Venus::JoinVideo.join_video(split_files[0], split_files[1], @join_output_file)
      assert File.exist?("#{@join_output_file}.mp4"), 'Joined video file was not created'
    else
      skip 'Not enough split files to test join video'
    end
    puts "Finished test_join_video"
  end

  def teardown
    Dir.glob("#{@split_output_prefix}_*.mp4").each { |file| File.delete(file) }
    File.delete("#{@blur_output_file}.mp4") if File.exist?("#{@blur_output_file}.mp4")
    File.delete("#{@join_output_file}.mp4") if File.exist?("#{@join_output_file}.mp4")
  end
end