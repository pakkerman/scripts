#!/usr/bin/env bash

[ ! -d "$1" ] && echo "Directory not found." && exit 1

working_dir="$(dirname "$0")"
target_dir="$1"

# check if pngs is already in the png folder, move it out
files=("$target_dir"/*.png)
[ ${#files[@]} -eq 1 ] &&
  for png in "$target_dir"/png/*.png; do
    mv "$png" "$target_dir"
  done

# rename files
echo "Renaming all files"
"$working_dir"/renamePNGs.sh "$1"

echo "Generate new metadata..."
files=("$target_dir"/*.png)
count=0
for png in "${files[@]}"; do
  [ ! -f "$png" ] && break
  ((count++))

  # convert to jpg and crop bottom 30px to get rid of the watermark
  jpg="${png%.*}.jpg"
  convert "$png" -gravity South -chop 0x15 -quality 95 "$jpg"
  # convert "$png" -quality 95 "$jpg"

  # Civitai.com API, model lookup
  models=$("$working_dir"/get-models.sh "$png")
  echo "processing $(basename "$png") ($count / ${#files[@]})"
  echo -e "$models" | jq -r '.[] | (.type | select(. == "Checkpoint") |= "CKPT") + "\t: " + .name' | awk '{ if (length($0) > 45) print substr($0, 1, 45) "..."; else print }'
  echo "-"

  # get comment
  json_string=$("$working_dir"/get-comment.sh "$png")

  # parse comment
  user_comment=$(
    echo "$json_string" |
      jq -r '
            .prompt, (.models[] | "<lora:\(.modelFileName) :\(.weight)>."),
            "Negative prompt:", .negativePrompt + ".",
            "Steps: " + (.steps | tostring) +
            ", Sampler: " + (.samplerName | tostring) +
            ", CFG scale: " + (.cfgScale | tostring) +
            ", Seed: " + (.seed | tostring) +
            ", Model: " + (.baseModel.modelFileName | tostring) +
            ", Clip Skip: " + (.clipSkip | tostring) + ", Civitai resources:"
    '
  )

  # set user comment
  parsedModelInfo=$(echo "$models" | jq -r -c '[.[] | select((.type == "LORA") or (.type == "Checkpoint")) | select(.poi == false) | {type, modelVersionId}]')

  exiv2 -M "set Exif.Photo.UserComment $user_comment $parsedModelInfo" "$jpg"

done

echo -e "\nAll ${#files[@]} files updated.\n"

# move jpg to another target_dir
# jpgs=("$target_dir"/*.jpg)
# mkdir "$target_dir"/jpg
# for jpg in "${jpgs[@]}"; do
#     mv "$jpg" "$target_dir"/jpg
# done

# make slides
# read -rp "make slides? (y/n)" confirm
# case "$confirm" in
#     [yy] | [yy][ee][ss] | "" ) echo "continuing (y)" ;;
#     [nn] | [nn][oo]) echo "canceled (n)" ; exit ;;
#     *) echo "invalid input."; exit ;;
# esac

# "$working_dir"/make-slides.sh "$1"

pngs=("$target_dir"/*.png)
mkdir "$target_dir"/png 2>/dev/null
for png in "${pngs[@]}"; do
  mv "$png" "$target_dir"/png
done
