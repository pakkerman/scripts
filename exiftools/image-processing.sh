#!/usr/bin/env bash

start=$(date +%s)

# Calculate the elapsed time
process_image() {
  [[ -z "$1" ]] && fatal "missing input"

  local input=$1
  local bname=${1%%\.*}
  local tmp="$bname.miff"
  local output="$bname.webp"

  magick "$input" -resize 2000x3000\> -unsharp 0x1+1+0.05 "$tmp"
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
  endpoints -l 0,5 -h 250,255 -c r "$tmp" "$tmp"
  endpoints -l 0,5 -h 250,255 -c b "$tmp" "$tmp"
  endpoints -l 5,0 -h 255,250 -c g "$tmp" "$tmp"

  # glowing pass
  # glow -a 1.2 -s 6 "$output" "$output"
  # endpoints -l 15,5 -h 245,250 -c all "$output" "$output"

  # less dense grain for smaller size image
  # filmgrain -a 50 -A 50 -d 50 -D 50 -c softlight -C softlight "$output" "$output"
  # filmgrain -a 75 -A 75 -d 75 -D 75 -c softlight -C softlight "$output" "$output"
  # more dense grain for large size image
  #
  filmgrain \
    -s $((RANDOM % 100)) \
    -S $((RANDOM % 200)) \
    -a 90 -A 90 -d 90 -D 90 -c softlight -C softlight \
    "$tmp" "$tmp"

  magick "$tmp" -quality 96 "$output"

  # local imageData
  # imageData=$(exiftool -b -Prompt "$input")
  # exiv2 -M"set Exif.Image.ImageDescription $imageData" "$output"
  # exiv2 -M"set Exif.Photo.UserComment embedding:lazypos, (from side), dutch angle, very awa, (two girls walking down stairs in an ancient ruin), fully naked women, (toned:0.6), tall, long legs, legs apart, (pussy), curly hair, medieval look, sunlight in hair, blond hair, backpack over one shoulder, walking down stairs, 2girls, elf, adult, russian girl, (mature oval face), sexy, cute face, large_eyes, (aegyo sal), slim figure, soft natural breasts, perky breasts, pink_nipples, pink_innie_pussy, thick_eyebrows, cape, pubic hair, chokers, armor, fully naked, body jewelry, body chain, woman only wearing flat very thin brown leather, (barefoot sandals with thin leather straps:1.3), outside a suburb villa, sunrise, backlight, (low angle, facing towards viewer:1.2), portrait, full body shot, random hairstyles, five fingers, five toes, (detailed barefoot sandals), dark background, atmospheric lighting, depth of field, dusk, , Semi-realism, zer0q, soft painterly rendering, vivid brush textures, moody lighting <lora:Semi-realism_illustrious:0.6> <lora:zeroq:0.6> <lora:Dramatic Lighting Slider:2.8> <lora:retro_scifi_artstyle_illustriousXL-000021:0.6> <lora:zeroq:0.3> Negative prompt: embedding:lazyneg, embedding:lazyhand, embedding:lazyloli, worst quality, low quality, bad anatomy, watermark, (Chinese, Asian, Korean), (lifeless, dead_eyes, empty_eyes:1.3), cum, pussy_juice, (thicc), (petite), (fat), (curvy), wide_hips, thick_thighs, (fake_breasts), (large_breast:0.8), (muscular:0.2), man, male, Steps: 24, Sampler: Euler a Karras, CFG scale: 5.5, Seed: 1046168308037614, Size: 832x1216, Model: amanesseWorks_v20, Lora hashes: "Semi-realism_illustrious: 3605105d76, zeroq: 4cacd9d6b1, Dramatic Lighting Slider: cad8e91066, retro_scifi_artstyle_illustriousXL-000021: 6f94cb871c"" "$output"

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

  mkdir -p "$backup_path"

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
