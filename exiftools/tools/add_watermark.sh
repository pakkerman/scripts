#!/usr/bin/env bash
# This program add watermark to videos in a directory

[[ ! -d "$1" ]] && echo "Invalid input path" && exit 1

dir=$(dirname "$1")
base=$(basename "$1")
input="$dir/$base/$base-%04d.jpg"
watermark="$HOME/Documents/assets/watermark.png"
output="$dir/video-$base.mp4"

for video in "$dir/$base"/*.mp4; do

    if [[ "$video" == *"watermark"* ]]; then
        continue
    fi

    original="${video%.mp4}.mp4"
    temp="${video%.mp4}_watermarked.mp4"

    ffmpeg \
        -loglevel warning \
        -y \
        -i "$video" \
        -i "$watermark" \
        -filter_complex "overlay=W-w-10:H-h-10" \
        -c:v libx264 \
        -crf 16 \
        -preset slow \
        -c:a copy \
        "$temp"

    rm "$original"
    mv "$temp" "$original"
done
