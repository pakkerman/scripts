#!/usr/bin/env bash

rename_files() {
  # rename files to clip-##.mp4, with '_r' if matched in filename

  local dir=$1
  local tmp_path="$dir"/tmp

  mkdir "$tmp_path" 2>/dev/null
  mv "$dir"/*.mp4 "$tmp_path"

  local idx=0 file
  for file in "$tmp_path"/*.mp4; do
    ((idx++))
    new_filename="$idx"
    new_filename="clip-$(printf '%02d' "$idx")"
    [[ "$file" =~ _r.mp4$ ]] && new_filename="$new_filename"_r

    mv "$file" "$new_filename".mp4
    mv "$new_filename".mp4 "$dir"
  done

  rm -r "$tmp_path"
}

trim_clips() {
  # trim all clips to length, output to tmp directory
  local dir=$1
  local trimmed_path="$dir"/trimmed

  mkdir "$trimmed_path" 2>/dev/null

  local files=("$dir"/*.mp4)
  local num_of_videos="${#files[@]}"

  local idx=0
  for file in "$dir"/*.mp4; do
    ((idx++))
    local total_length=28
    local trim_start=0.4

    local length
    length=$(
      echo "scale=1; $total_length / $num_of_videos" |
        bc |
        awk '{if ($1 <= 1.5) $1 = 1.5; else if ($1 > 2.2) $1 = 2.2; print $1}'
    )

    local filter="null"
    if [[ "$file" =~ _r.mp4 ]]; then
      # trim_start=$(echo "scale=1; 3 - $length" | bc)
      trim_start=$(printf "%.1f" "$(echo "scale=1; 3 - $length" | bc)")
      filter="reverse"
      echo "$file is reversed"
    fi

    # random flip
    local flip_random=$((RANDOM % 2))
    if [ "$flip_random" -eq 1 ]; then
      filter="$filter,hflip"
    fi

    # first video is full length and not reversed
    if [ "$idx" -le 1 ]; then
      trim_start=0.4
      filter="null"
      length=2.5
    fi

    ffmpeg \
      -loglevel panic \
      -i "$file" \
      -ss "$trim_start" \
      -t "$length" \
      -vf "$filter" \
      -c:v libx264 -crf 16 \
      -preset medium \
      "$trimmed_path/$idx.mp4"

    echo "starting: $trim_start, length: $length ( $idx of $num_of_videos )"
  done
}

combine_clips() {
  local dir=$1
  local trimmed_path="$dir"/trimmed
  local clips_list="$trimmed_path"/clips.txt
  local input="$dir"/_input.mp4
  local output="$dir"/_output.mp4

  command ls "$trimmed_path"/*.mp4 | awk '{print "file \x27"$0"\x27"}' >"$clips_list"

  ffmpeg \
    -loglevel panic \
    -f concat -safe 0 \
    -i "$clips_list" \
    -c copy -an \
    "$input"

  rm mylist.txt

  # add watermark
  watermark="$HOME/Documents/assets/watermark.png"

  ffmpeg \
    -i "$input" \
    -i "$watermark" \
    -f lavfi -i anullsrc=cl=stereo:r=48000 \
    -loglevel info \
    -filter_complex "
  [0:v]scale=1080:1920:flags=spline,
  hqdn3d=3:3:6:6,
  unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=1.5:chroma_msize_x=5:chroma_msize_y=5:chroma_amount=1.5,
  noise=allf=t:alls=6, 
  vignette=angle=PI/8[v0];
  [v0][1:v]overlay=W-w-30:H-h-75,format=yuv420p[v]
  " \
    -map "[v]" \
    -map 2:a \
    -c:v libx265 \
    -crf 23 \
    -preset medium \
    -tune grain \
    -pix_fmt yuv420p \
    -tag:v hvc1 \
    -level 4.1 \
    -r 30 -g 60 -keyint_min 60 \
    -c:a aac -b:a 160k -ar 48000 -ac 2 \
    -shortest \
    -movflags +faststart \
    "$output"

  # clean up
  rm -r "$trimmed_path"
  rm "$input"
}

make_video() {
  local dir=$1
  [[ -d "$dir" ]] || fatal "invalid path"

  rm "$dir"/_input.mp4 2>/dev/null
  rm "$dir"/_output.mp4 2>/dev/null
  rm -r "$dir"/trimmed 2>/dev/null

  rename_files "$dir"
  trim_clips "$dir"
  combine_clips "$dir"

}
