#!/usr/bin/env bash

start=$(date +%s)

# Calculate the elapsed time
process_image() {
  [[ -z "$1" ]] && fatal "missing input"

  local input=$1
  local bname=${1%%\.*}
  local tmp="$bname.miff"
  local output="$bname.webp"

  # magick "$input" -resize 2160x3840\> -unsharp 0x1+1+0.05 "$tmp"
  convert "$input" -resize 2160x3840\> "$tmp"
  # saturation 1.1 "$tmp" "$tmp"
  # convert "$input" -unsharp 0x1+0.5+0 "$output"
  #
  # less contrast
  # endpoints -l 5,15 -h 250,245 -c all "$output" "$output"

  # more desaturated
  # endpoints -l 5,15 -h 250,245 -c all "$output" "$output"
  # more contrast
  # endpoints -l 15,5 -h 245,250 -c all "$output" "$output"
  # Lot more contrast
  # endpoints -l 30,5 -h 225,250 "$output" "$output"

  # tinting pass
  endpoints -l 0,3 -h 252,255 -c r "$tmp" "$tmp"
  endpoints -l 0,3 -h 252,255 -c b "$tmp" "$tmp"
  endpoints -l 3,0 -h 255,252 -c g "$tmp" "$tmp"

  # glowing pass
  # glow -a 1.2 -s 6 "$tmp" "$tmp"
  # endpoints -l 15,5 -h 245,250 -c all "$tmp" "$tmp"

  # less dense grain for smaller size image
  # filmgrain -a 50 -A 50 -d 50 -D 50 -c softlight -C softlight "$output" "$output"
  # filmgrain -a 75 -A 75 -d 75 -D 75 -c softlight -C softlight "$output" "$output"
  # more dense grain for large size image
  #
  filmgrain \
    -s $((RANDOM % 100)) \
    -S $((RANDOM % 200)) \
    -a 96 -A 96 -d 96 -D 96 -c softlight -C softlight \
    "$tmp" "$tmp"

  convert "$tmp" -quality 94 "$output"

  rm "$tmp"
  # exiftool -ImageDescription="$image_description" -overwrite_original "$output" 1>/dev/null
}
#1>/dev/null 2>/dev/null

image-processing() {
  [[ -d $dir ]] && fatal "invalid directory"

  echo "Selected image processing"
  local dir="$1"
  local backup_path="$dir"/image_backups
  local clips_path="$dir"/clips

  echo -e "\n --- Image Post-Processing --- \n"

  mkdir -p "$backup_path" 2>/dev/null

  local files=("$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.webp "$dir"/*.png)

  mv "$backup_path"/*.* "$dir" 2>/dev/null
  cp "${files[@]}" "$backup_path"

  files=("$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.webp "$dir"/*.png)

  # Use parallel batch process images
  export -f process_image
  parallel \
    --bar \
    --jobs 2 \
    --delay 0.1 \
    process_image {} ::: "${files[@]}"

  local end elapsed
  end=$(date +%s)
  elapsed=$((end - start))

  echo -ne "\r\033[K Done in $elapsed seconds\n"
  echo -e " Files processed: ${#files[@]}"

  # move jpgs to clips for video
  mkdir "$clips_path"
  mv "$dir"/*.jpg "$clips_path"
}
