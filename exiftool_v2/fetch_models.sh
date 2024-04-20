#!/usr/local/bin/bash
# input [path]
# output models.json

echo -e "\nFetching models\n"

dir="$1"
[[ ! -d "$dir" ]] && echo "invalid dir path" && exit 1

files=("$dir"/*.*)

cwd=$(dirname "$0")
mkdir "$cwd/cache" 2>/dev/null

echo '{}' >"$cwd/cache/models.json"

# get all the hashes
declare -A hash_list
count=0
for file in "${files[@]}"; do
	((count++))
	echo -ne "\r\033[KParsing metadata: $(basename "$file") ($count / ${#files[@]})"
	json=$(exiftool "$file" | grep "Generation data" | sed "s/.*{\"models\"/{\"models\"/" | jq -r .)
	hashes=$(echo "$json" | jq 'try [.models[], .adetailer.args[0].models[]]' | jq -r .[].hash | tr ' ' '\n')

	IFS=$'\n'
	for hash in $hashes; do
		hash_list[$hash]=$hash
	done
done

echo -ne "\r\033[KParsed $count of ${#files[@]} files"
echo -e "\n\nFetching models...\n"

IFS=$'\n'
for item in "${hash_list[@]}"; do
	model=$(curl -s "https://civitai.com/api/v1/model-versions/by-hash/$item")

	model_info=$(echo "$model" | jq -c '{ modelId: .modelId, name: .model.name, type: .model.type, nsfw: .model.nsfw, poi: .model.poi }')

	name=$(echo "$model_info" | jq -r .name)
	echo "${name:0:$(tput cols)-12}..."

	jq . "$cwd/cache/models.json" | jq --arg key "$item" --argjson value "$model_info" '.[$key] = $value' | sponge "$cwd/cache/models.json"

done

echo -ne "\r\n${#hash_list[@]} models fetched."
