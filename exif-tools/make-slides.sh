#! /bin/bash
# This program will take in a path and make slides with the png files inside.

[ ! -d "$1" ] && echo "Invalid input path" && exit 1

dir=$(dirname "$1")
base=$(basename "$1")
input="$dir/$base/$base-%04d.jpg"
output="$dir/video-$base.mp4"

count=$(find "$1" -type f -name "*.jpg" | grep -c "")

# normal output
ffmpeg -y \
	-framerate 2 \
	-i "$input" -c:v libx264 \
	-preset slow -crf 22 \
	-pix_fmt yuv420p \
	-vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
	"$output"

# output with slide number
# ffmpeg -y -framerate 2 -i "$input" \
# -vf \
# "
#   drawtext=text='%{eif\:trunc(n+1)\:d}\/$count'
#   :fontcolor=#FED7AA
#   :fontfile=/Users/pakk/Library/Fonts/RobotoMono-Light.ttf
#   :fontsize=48
#   :box=1
#   :boxcolor=black@0.6
#   :boxborderw=10
#   :x=(w-text_w)-50
#   :y=th
# " -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p "$output"

# a box indicator
# ffmpeg -y -framerate 2 -i "$input" \
# -vf \
# "
# drawgrid=width=in_w:height=in_h:thickness=40:color=red@0.5
# " -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p "$output"

echo "count $count"
