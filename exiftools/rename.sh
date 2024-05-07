#!/bin/bash
# This script will take a dir and serialize all sub-dir jpg files

[[ ! -d $1 ]] && echo "Valid path to directory required." && exit 1

target_path=$1
# target_path=/users/pakk/downloads/test/

echo -e "\n----- Renaming -----\n\n"
read -rp "Use original name? (enter new name or leave empty): " name

if [[ "$name" == '' ]]; then
	name=$(basename "$target_path")
	echo -e "continuing with: $name\n"
fi

rename_path=$(dirname "$target_path")/$name
mv "$target_path" "$rename_path" 2>/dev/null
target_path=$rename_path

RENAME() {
	target=$1
	echo "Rename contents of $target"

	i=0
	for item in "$target"/*; do
		((i++))

		unset ext
		if [[ -f $item ]]; then
			ext=${item##*.}
		fi

		to="$(dirname "$item")/temp-$(printf "%04d" $i)${ext:+.$ext}"
		mv "$item" "$to"
	done

	i=0
	for item in "$target"/*; do
		((i++))

		indexing=$(printf "%02d" $i)
		unset ext
		if [[ -f $item ]]; then
			indexing=$(printf "%04d" $i)
			ext=${item##*.}
		fi

		dir=$(dirname "$item")
		prefix=$(basename "$(dirname "$item")")
		to="$dir/$prefix-$indexing${ext:+.$ext}"
		mv "$item" "$to"
	done
}

RENAME "$target_path"

echo "$target_path/*"

for dir in "$target_path"/*; do

	[[ "$dir" =~ -posted$ ]] && continue

	RENAME "$dir"

done

for dir in "$target_path"/*; do

	./make-slides.sh "$dir" &

done
