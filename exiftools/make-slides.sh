#!/usr/bin/env bash
# This program will take in a path and make slides with the png files inside.

[[ ! -d "$1" ]] && echo "Invalid input path" && exit 1

dir=$(dirname "$1")
base=$(basename "$1")
input="$dir/$base/$base-%04d.jpg"
output="$dir/slides-$base.mp4"

count=$(find "$1" -type f -name "*.jpg" | grep -c "")

# normal output
ffmpeg \
  -loglevel warning \
  -y \
  -framerate 1.5 \
  -i "$input" -c:v libx264 \
  -preset slow -crf 16 \
  -pix_fmt yuv420p \
  -vf "scale='min(2560,iw)':'min(2560,ih)':force_original_aspect_ratio=decrease,pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  "$output"

echo "count $count"
