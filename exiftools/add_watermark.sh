#!/bin/bash
# This program add watermark to videos in a directory

[[ ! -d "$1" ]] && echo "Invalid input path" && exit 1

dir=$(dirname "$1")
base=$(basename "$1")
input="$dir/$base/$base-%04d.jpg"
watermark="$HOME/Documents/.generation/watermark.png"
output="$dir/video-$base.mp4"

# count=$(find "$1" -type f -name "*.jpg" | grep -c "")

# normal output
# ffmpeg \
# 	-i "$input" -c:v libx264 \
# 	-i "$watermark" \
# 	-filter_complex "overlay=W-w-10:H-h-10" \
# 	"$output"
#
# echo "count $count"

for video in "$dir/$base"/*.mp4; do
	ffmpeg \
		-loglevel warning \
		-i "$video" \
		-i "$watermark" \
		-filter_complex "overlay=W-w-10:H-h-10" \
		"${video%.mp4}_watermarked.mp4"
done
