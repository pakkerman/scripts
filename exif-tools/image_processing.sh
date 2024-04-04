#!/bin/bash

process() {
	[[ -z "$1" ]] && echo "missing input" && exit 1
	[[ -z "$2" ]] && echo "missing output" && exit 1

	input=$1
	output=$2

	convert "$input" -gravity South -chop 0x30 -quality 95 "$output"
	convert "$output" -unsharp 0x1+1+0 "$output"
	endpoints -l 15,15 -h 255,255 -c all "$output" "$output"
	filmgrain -a 75 -A 75 "$output" "$output"
}

[[ ! -d $1 ]] && echo "invalid directory" && exit
[[ -n $2 ]] && echo "enter something to process"

echo -e "--- Post Processing Images --- \n"

bak_path="$1/bak"
mkdir -p "$bak_path"

files=("$1"/*.jpg)

for file in "${files[@]}"; do
	basename "$file"
	cp "$file" "$bak_path/$(basename "$file")"

	process "$file" "$file" &
done

echo -e "\n--- Done ---"
echo -e "Files processed: ${#files[@]}"
