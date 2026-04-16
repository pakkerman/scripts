#!/usr/bin/env bash

# this script will start from a directory
# goes into each sub-directory and combine all mp4s

# Trim this many seconds from the start of each clip before concat.
# Override with: TRIM_START=0.4 bash combine_videos.sh
TRIM_START=0.5

for d in "$(pwd)"/*/; do
  cd "$d" || exit 1

  [[ "$d" =~ "posted_" ]] && continue
  [[ "$d" =~ "unsort_" ]] && continue

  name=$(basename "$d")
  output_name="$name"_combined

  rm ./*"_combined"*.mp4

  if [[ -d "$d"/clips ]]; then
    mv "$d"/clips/*.mp4 "$d"
  fi

  clips=("$d"/*.mp4)

  # TODO: Trim videos
  # for f in *.mp4; do
  #   printf "file '$PWD/%s'\ninpoint 00:00:01.000\noutpoint 00:00:03.000\n" "$f"
  # done >list.txt
  #

  input_args=()
  filter=""
  for i in "${!clips[@]}"; do
    input_args+=(-i "${clips[$i]}")
    filter+="[$i:v]trim=start=${TRIM_START},scale=1080:1920:flags=spline,setsar=1,settb=AVTB,setpts=PTS-STARTPTS[v$i];"
  done

  for i in "${!clips[@]}"; do
    filter+="[v$i]"
  done

  filter+="concat=n=${#clips[@]}:v=1:a=0[v]"

  # echo "$filter"

  ffmpeg "${input_args[@]}" \
    -filter_complex "$filter" \
    -map "[v]" \
    -fps_mode vfr \
    -c:v libx265 \
    -crf 25 \
    -preset medium \
    -x265-params "repeat-headers=1" \
    -tune grain \
    -pix_fmt yuv420p \
    -tag:v hvc1 \
    -level 4.1 \
    -movflags +faststart \
    "$output_name".mp4

  [[ ! -d "$d"/clips ]] && mkdir "$d"/clips
  mv "${clips[@]}" "$d"/clips
done

cd ..
