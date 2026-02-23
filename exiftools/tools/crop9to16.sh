#!/usr/bin/env bash

dir="$1"
bak_path="$dir"bak_crop

if [[ -d $bak_path ]]; then
  mv "$bak_path"/* "$dir"
else
  mkdir "$bak_path" 2>/dev/null
fi

files=("$dir"/*.jpg)
for file in "${files[@]}"; do

  cp "$file" "$bak_path"

  magick "$file" \
    -gravity Center -crop 9:16 \
    $(dirname "$file")/$(basename "$file")

done
