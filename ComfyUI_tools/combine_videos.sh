#!/usr/bin/env bash

# this script will start from a directory
# goes into each sub-directory and combine all mp4s

for d in "$(pwd)"/*/; do
  cd "$d" || exit 1

  [[ "$d" == *"posted_"* ]] && continue

  name=$(basename "$d")
  output_name="$name"_output

  rm ./*"_output"*.mp4

  if [[ -d "$d"/clips ]]; then
    mv "$d"/clips/*.mp4 "$d"
  fi

  clips=("$d"/*.mp4)

  printf "file '$PWD/%s'\n" *.mp4 >list.txt
  ffmpeg -f concat -safe 0 -i list.txt -c copy "$output_name".mp4

  ffmpeg -f concat -safe 0 -i list.txt \
    -filter_complex "[0:v]scale=1080:1920:flags=spline,setpts=0.8*PTS,fps=30[v]" \
    -map "[v]" \
    -c:v libx265 \
    -crf 24 \
    -preset medium \
    -x265-params "repeat-headers=1" \
    -tune grain \
    -pix_fmt yuv420p \
    -tag:v hvc1 \
    -level 4.1 \
    -c:a aac -b:a 160k -ar 48000 -ac 2 \
    -shortest \
    -movflags +faststart \
    "$output_name"_30.mp4

  rm list.txt

  [[ ! -d "$d"/clips ]] && mkdir "$d"/clips
  mv "${clips[@]}" "$d"/clips
  exit
done

cd ..
