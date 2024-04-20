#!/bin/bash

# dir="$1"
# [[ ! -d "$dir" ]] && echo "invalid dir path" && exit 1

# TODO: Add lora name and weights into prompt
# BUG:  Find out why EMBED is marked as textural inversion
# BUG:  Apparently some images will just be missing Generation Data to begin with, so there is nothing to parse and fail
dir="$HOME/downloads/test/"
# ./fetch_models.sh "$dir"

mv "$dir/png"/*.png "$dir"
files=($(echo "$dir"*.png | tr " " "\n"))
models=$(cat ./cache/models.json)

embed_data=$(jq --null-input '{
    "EMBED: FastNegativeV2": "A7465E7CC2A2A27571EE020053F307B5AF54E6B60A0B0235D773F6BD55F7D078",
    "EMBED: BadDream": "758AAC44351557CCFAE2FC6BDF3A29670464E4E4EABB61F08C5B8531C221649C",
    "EMBED: UnrealisticDream": "A77451E7EA075C7F72D488D2B740B3D3970C671C0AC39DD3155F3C3B129DF959",
    "EMBED: Asian-Less-Neg": "22D2F003E76F94DCF891B821A3F447F25C73B2E0542F089427B33FF344070A96",
    "EMBED: bad-hands-5": "22D2F003E76F94DCF891B821A3F447F25C73B2E0542F089427B33FF344070A96"
  }')

count=0
error=0
error_files=()
for file in "${files[@]}"; do
	((count++))

	json=$(exiftool "$file" | grep "Generation data" | sed "s/.*{\"models\"/{\"models\"/" | jq -r .)
	prompt=$(echo "$json" | jq -r .prompt | sed -E "s/\\n//g")
	negative=$(echo "$json" | jq -r .negativePrompt)
	sampler=$(echo "$json" | jq -r .samplerName)
	clipskip=$(echo "$json" | jq -r .clipSkip)
	seed=$(echo "$json" | jq -r .seed)
	CFG=$(echo "$json" | jq -r .cfgScale)
	steps=$(echo "$json" | jq -r .steps)
	model_data=$(echo "$json" | jq '.baseModel' | jq -r '{name: .modelFileName, hash: .hash}')
	lora_data=$(echo "$json" | jq 'try [.models[], .adetailer.args[0].models[]] | map({type: .type, name: .modelFileName, hash: .hash})')

	hashes=$(
		jq --null-input -c \
			--argjson model_hash "$model_data" \
			--argjson lora_hashes "$lora_data" \
			--argjson embed_data "$embed_data" \
			'. + { "model": $model_hash.hash } +
	        reduce $lora_hashes[] as $item ({}; .["\($item.type):\($item.name)"] = $item.hash) +
	        ($embed_data | with_entries(.key |= tostring))'
	)

	if [[ "$?" != 0 ]]; then
		((error++))
		error_files+=("$(basename "$file")")
	fi

	jpg=$(echo "$file" | sed 's/.png/.jpg/g')
	convert "$file" -gravity South -chop 0x15 -quality 95 "$jpg"

	metadata="$prompt. Negative prompt: $negative. \nSteps: $steps, Sampler: $sampler, CFG scale: $CFG, Seed: $seed, Model: $(echo "$model_data" | jq -r '.name'), Clip Skip: $clipskip, Hashes: $hashes"
	exiv2 -M "set Exif.Photo.UserComment $metadata" "$jpg"

	echo -ne "\r\033[K processing $(basename "$file") ($count / ${#files[@]})"
done

echo -e "\nThere was $error errors occurred with following files:"
echo -e "${error_files[@]}"

mkdir "$dir/png" 2>/dev/null
mv "$dir"/*.png "$dir/png"

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
