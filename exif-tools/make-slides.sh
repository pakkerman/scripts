#! /bin/bash

[ ! -d "$1" ] && echo "please input path" && exit 1

dir=$(dirname "$1")
base=$(basename "$1")
input="$dir/$base/$base-%04d.png"
output="$dir/video-$base.mp4"


ffmpeg -y -framerate 1.5 -i "$input" -vf "crop=in_w:in_h-30:0:0" -c:v libx264 -preset slow -crf 22 -pix_fmt yuv420p "$output"



