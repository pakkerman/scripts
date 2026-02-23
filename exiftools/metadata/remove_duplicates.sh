#!/usr/bin/env bash

change_count=0

remove_duplicate() {

	input=$(exiftool -b -UserComment "$1")
	json=$(echo "$input" | grep -o "\[.*\]$")
	array=($(echo "$json" | jq -c .[]))
	out=""
	seen=()
	for item in "${array[@]}"; do
		id=$(echo "$item" | jq -r '.modelVersionId')
		if ! ((seen["$id"])); then
			out+="$item,"
			seen["$id"]=1
		fi
	done

	out=$(echo "$out" | sed 's/\,$//')
	output=$(echo "$input" | sed "s/\[.*\]$/[${out}]/g")

	outpath="$1"
	original="$json"
	change="[$out]"
	if [[ "$original" != "$change" ]]; then
		((change_count++))
		exiv2 -M "set Exif.Photo.UserComment $output" "$outpath"
	fi

}

[[ ! -d $1 ]] && echo "invalid directory" && exit
[[ -n $2 ]] && echo "enter something to remove"

echo -e "--- Remove duplicates --- \n"

bak_path="$1/bak"
mkdir -p "$bak_path"

files=("$1"/*.jpg)

for file in "${files[@]}"; do
	basename "$file"
	cp "$file" "$bak_path/$(basename "$file")"

	remove_duplicate "$file"
done

echo -e "\n--- Done ---"
echo -e "Files changed: $change_count / ${#files[@]}"
