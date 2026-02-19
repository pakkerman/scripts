#!/usr/bin/env bash

# this script is for getting model info from civitai api, using the hashes from the image
# https://github.com/civitai/civitai/wiki/REST-API-Reference#get-apiv1models-versionsby-hashhash

file="$1"
[ ! -f "$file" ] && echo "Invalid file" && exit 1

# Get the directory path of the script
dir=$(dirname "$0")
mkdir -p "$dir/cache"
json_file="$dir/cache/models.json"

# getting metadata from png
json_string=$("$dir"/get-comment.sh "$file")

# get hashes from metadata
json=$(echo "$json_string" | jq '{
    "baseModel": {
        "hash": .baseModel.hash
    },
    "lora": [
        .models[] | {
            "hash": .hash,
            "weight": .weight
        }
    ]
}')

ADtailer=$(echo "$json_string" | jq '{"lora": [.adetailer.args[] | .models[] | {"hash": .hash, "weight": .weight}]}')
# echo $ADtailer > ~/temp/log

# parse hashes into array
hash_values=($(echo "$json" | jq -r '.baseModel.hash, .lora[].hash'))
hash_values+=($(echo $ADtailer | jq -r '.lora[].hash'))
json_array=()

for hash_value in "${hash_values[@]}"; do
	select=$(cat "$json_file" | jq --arg hash "$hash_value" 'select(.hash == $hash)')
	if [[ -z "$select" ]]; then
		# new
		response=$(curl -X GET "https://civitai.com/api/v1/model-versions/by-hash/$hash_value" | jq '.')
		[[ $response == '{"error":"Model not found"}' ]] && continue

		echo "$response" | jq '{name: .model.name, version: .name, hash: .files.[] | .hashes.SHA256, modelVersionId: .id, type: .model.type, poi: .model.poi}' | tee -a "$json_file"
	fi

	json_array+=($(cat "$json_file" | jq --arg hash "$hash_value" 'select(.hash == $hash)'))
done

echo "${json_array[@]}" | jq -s -c '.'
