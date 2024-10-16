## Hi! What's that?

Venus is a Ruby-gem that allows you to work with video using ffmpeg. At the moment it can split video into separate parts by specified time and format it!

### Prerequisites

Before installing the gem, make sure you have `ffmpeg` installed on your system.

```bash
# Ubuntu
sudo apt-get install ffmpeg
# Arch 
sudo pacman -S ffmpeg
```

## Installation

```bash
gem install venus_video
```

## Usage

```ruby
# split_video consists of the following arguments: 
# <input_file> <output_prefix> <format_segment> <segment_duration> [path] -> nil [format_video] -> nil
# input_file accepts video
# output_prefix specifies the names of the created videos with the addition of _00N.mp4
# segment_duration takes minutes, seconds or hours depending on format_segment
# format_segment accepts minutes (min) hours (hour) and seconds (sek)
# segment_duration takes minutes, seconds or hours depending on format_segment
# path takes the path to the directory where the videos will be saved, by default it saves them in the folder where you are located
# format_video initially gives us all the files, but can also give us only the first part, the last part, and the range

require  "venus"

# split the video into 20-minute chunks and save the results 
my_video = Venus::SplitVideo.process_arguments("name_video.mp4 name_result min 20")
Venus::SplitVideo.split_video(*my_video)

# will split the video into 5 minute chunks and save them all in the specified directory
my_video = Venus::SplitVideo.process_arguments("name_video.mp4 name_result min 5")
Venus::SplitVideo.split_video(*my_video, path: "/path/to/folder") 

# to split the video into 2 hour chunks and save only the first chunk
my_video = Venus::SplitVideo.process_arguments("name_video.mp4 name_result hour 2")
Venus::SplitVideo.split_video(*my_video, format_video: "first") 

# to split video into 300 second chunks and save chunks 1 through 3
my_video = Venus::SplitVideo.process_arguments("name_video.mp4 name_result sek 300")
Venus::SplitVideo.split_video(*my_video, format_video: "1..3")

# blur video
my_video = Venus::BlurVideo.process_arguments("name_video.mp4 name_result")
Venus::BlurVideo.blur_video(*my_video)

# join video
my_video = Venus::JoinVideo.process_arguments("video.mp4 video.mp4 output_file")
Venus::JoinVideo.join_video(*my_video)

```
