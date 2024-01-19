#! /bin/bash
# This program will take in a path and make slides with the png files inside.

[ ! -d "$1" ] && echo "Invalid input path" && exit 1


dir=$(dirname "$1")
base=$(basename "$1")
input="$dir/$base/$base-%04d.jpg"
output="$dir/video-$base.mp4"

count=$(find "$1" -type f -name "*.jpg" | grep -c "")

# normal output
# ffmpeg -y -framerate 2 -i "$input" -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p "$output"

text="'%{eif\:trunc(n+1)\:d}\/$count'"
color="white"
size="48"
Y="th-10"
X="(w-text_w)-10"
# output with slide number
ffmpeg -y -framerate 2 -i "$input" \
-vf \
"
  drawtext=text=$text:
  fontcolor=$color:
  fontsize=$size:
  box=1:
  boxcolor=black@0.5:
  boxborderw=5:
  x=$X:
  y=$Y
" -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p "$output"

echo "count $count"
