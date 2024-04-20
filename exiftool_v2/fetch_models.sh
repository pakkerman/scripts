#!/bin/bash

# input [path]
# output models.json

dir=$(dirname "$1")
dir="/Users/pakk/Downloads/new"
files=("$dir"/*.*)

cwd=$(dirname "$0")
mkdir "$cwd/cache" 2>/dev/null

echo '{}' >"$cwd/cache/models.json"

# get all the hashes
declare -A hash_list
for file in "${files[@]}"; do
	json=$(exiftool "$file" | grep "Generation data" | sed "s/.*{\"models\"/{\"models\"/" | jq -r .)
	hashes=$(echo "$json" | jq 'try [.models[], .adetailer.args[0].models[]]' | jq -r .[].hash | tr ' ' '\n')

	IFS=$'\n'
	for hash in $hashes; do
		hash_list[$hash]=$hash
	done
done

echo -e "\nFetching models..."

IFS=$'\n'
for item in "${hash_list[@]}"; do
	model=$(curl -s "https://civitai.com/api/v1/model-versions/by-hash/$item")

	model_info=$(echo "$model" | jq -c '{ modelId: .modelId, name: .model.name, type: .model.type, nsfw: .model.nsfw, poi: .model.poi}')

	echo "$model_info" | jq .name
	jq . "$cwd/cache/models.json" | jq --arg key "$item" --argjson value "$model_info" '.[$key] = $value' | sponge "$cwd/cache/models.json"
done

echo "${#hash_list[@]} models fetched."
