#!/bin/bash

./fetch_models.sh

# echo -e "$file \n"
#
# json=$(exiftool "$file" | grep "Generation data" | sed "s/.*{\"models\"/{\"models\"/" | jq -r .)
# prompt=$(echo "$json" | jq -r .prompt | sed -E "s/\\n//g")
# negative=$(echo "$json" | jq -r .negativePrompt)
# clipskip=$(echo "$json" | jq -r .clipskip)
# CFG=$(echo "$json" | jq -r .cfgScale)
# stpes=$(echo "$json" | jq -r .steps)
# hashes=$(echo "$json" | grep "hash" | sed "s/ //g" | sed "s/[\"\:]//g" | sed "s/hash//g")
#
# echo "$prompt"
# echo "$negative"
# echo "$CFG"
# echo "$clip"
# echo "$hashes"
#
# IFS=$'\n'
# for hash in $hashes; do
# 	model=$(curl "https://civitai.com/api/v/model-versions/by-hash/$hash")
# 	echo "$model" | jq .model.name
#
# done

# comment=$(exiftool -b -Parameters $file)
# convert -gravity South -chop 0x30 -quality 95 "$file" "/Users/pakk/Downloads/new/out.jpg"
# exiv2 -M "set Exif.Photo.UserComment $comment" "/Users/pakk/Downloads/new/out.jpg"

# exiftool -UserComment "/Users/pakk/Downloads/new/out.jpg"
