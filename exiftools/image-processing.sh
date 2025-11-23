#!/usr/bin/env bash

start=$(date +%s)

# Calculate the elapsed time
process_image() {
  [[ -z "$1" ]] && fatal "missing input"

  local input=$1
  local output=${1%\.*}.jpg

  magick "$input" -resize 2000x3000\> -unsharp 0x1+1+0.05 -quality 97 "$output"
  # magick "$output" -resize 1500x3000\> -quality 100 "$output"
  # saturation 1.1 "$output" "$output"
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
  endpoints -l 0,5 -h 250,255 -c r "$output" "$output"
  endpoints -l 0,5 -h 250,255 -c b "$output" "$output"
  endpoints -l 5,0 -h 255,250 -c g "$output" "$output"

  # glowing pass
  # glow -a 1.2 -s 6 "$output" "$output"
  # endpoints -l 15,5 -h 245,250 -c all "$output" "$output"

  # less dense grain for smaller size image
  # filmgrain -a 50 -A 50 -d 50 -D 50 -c softlight -C softlight "$output" "$output"
  # filmgrain -a 75 -A 75 -d 75 -D 75 -c softlight -C softlight "$output" "$output"
  # more dense grain for large size image
  filmgrain \
    -s $((RANDOM % 100)) \
    -S $((RANDOM % 200)) \
    -a 85 -A 85 -d 85 -D 85 -c softlight -C softlight \
    "$output" "$output"

  magick "$output" -quality 95 "${output%\.*}.webp"
} 1>/dev/null 2>/dev/null

image-processing() {
  [[ -d $dir ]] && fatal "invalid directory"

  echo "Selected image processing"
  local dir="$1"
  local backup_path="$dir"/image_backups
  local clips_path="$dir"/clips

  echo -e "\n --- Image Post-Processing --- \n"

  mkdir -p "$backup_path"

  mv "$backup_path"/*.* "$dir" 2>/dev/null
  cp "$dir"/*.* "$backup_path"

  local files=("$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.webp "$dir"/*.png)

  # Use parallel batch process images
  export -f process_image
  parallel \
    --bar \
    --jobs 3 \
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
