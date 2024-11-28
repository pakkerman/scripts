#!/bin/bash

# TODO: Add lora name and weights into prompt
# BUG:  Find out why EMBED is marked as textural inversion
# BUG:  Apparently some images will just be missing Generation Data to begin with, so there is nothing to parse and fail

dir=$(dirname "$1")/$(basename "$1")/
[[ ! -d "$dir" ]] && echo "invalid dir path" && exit 1

# dir="$HOME/downloads/test/"
echo "$dir"

# ./fetch_models.sh "$dir"
# models=$(cat ./cache/models.json)

echo -e "\n Processing images... \n"

mv "$dir/png"/*.png "$dir" 2>/dev/null

# files=($(echo "$dir"*.png | tr " " "\n"))
files=("$dir"/*.png)

embed_data=$(jq --null-input '{
    "EMBED: FastNegativeV2": "A7465E7CC2A2A27571EE020053F307B5AF54E6B60A0B0235D773F6BD55F7D078",
    "EMBED: BadDream": "758AAC44351557CCFAE2FC6BDF3A29670464E4E4EABB61F08C5B8531C221649C",
    "EMBED: UnrealisticDream": "A77451E7EA075C7F72D488D2B740B3D3970C671C0AC39DD3155F3C3B129DF959",
    "EMBED: Asian-Less-Neg": "22D2F003E76F94DCF891B821A3F447F25C73B2E0542F089427B33FF344070A96",
    "EMBED: bad-hands-5": "AA7651BE154C46A2F4868788EF84A92B3083B0C0C5C46F5012A56698BFD2A1BA"
  }')

count=0
error=0
error_list=()

function parallel_convert() {
	((count++))
	file="$1"

	json=$(exiftool "$file" | grep "Parameters")
	prompt=$(echo "$json" | sed "s/.*: \(.*\)\.Neg.*/\1/")
	negative=$(echo "$json" | sed "s/.*Negative prompt: \(.*\)\.Steps:.*/\1/")
	steps=$(echo "$json" | sed "s/.*\(Steps:...\),.*/\1/")
	seed=$(echo "$json" | sed "s/.*\(Seed: [0-9]*\).*/\1/")
	clip_skip=$(echo "$json" | sed "s/.*\(Clip skip: [0-9]*\),.*/\1/")
	ad_prompt=$(echo "$json" | sed "s/.*ADetailer prompt: \"\([^\"]*\)\".*/\1/" | sed "s/\\\n//g")

	if [[ "$?" != 0 ]]; then
		((error++))
		error_list+=("$(basename "$file")")
	fi

	jpg=$(echo "$file" | sed 's/.png/.jpg/g')
	magick "$file" \
		\
		-quality 96 \
		"$jpg" # -endian LSB \

	metadata="$prompt.$negative.$steps,$seed,$clip_skip, $ad_prompt"

	exiv2 -M "set Exif.Photo.UserComment $metadata" "$jpg"
}

export -f parallel_convert
time parallel \
	--progress \
	--jobs 8 \
	--delay 0 \
	parallel_convert {} ::: "${files[@]}"

if [[ $error != 0 ]]; then
	echo -e "\n\nThere was $error errors occurred with following files:"
	echo -e "${error_list[@]}" | tr ' ' '\n'
fi

mkdir "$dir/png" 2>/dev/null
mv "$dir"/*.png "$dir/png"
