#!/bin/bash
# This script will take a dir and serialize all sub-dir jpg files

[[ ! -d $1 ]] && echo "Valid path to directory required." && exit 1

target_path=$1
target_base=$(basename "$target_path")

# target_path=/users/pakk/downloads/test/

echo -e "\n----- Renaming -----\n"
echo -e "Use original name ""$target_base""?"
read -rp "(enter new name or leave empty): " name

if [[ "$name" == '' ]]; then
	name=$(basename "$target_path")
	echo -e "continuing with: $name\n"
fi

if [[ $name != "$target_base" ]]; then
	echo "$name"
	destination=$(dirname "$target_path")/$name
	if [[ -d $destination ]]; then
		echo "destination dir alread exist."
		exit 1
	fi
	mv -n "$target_path" "$destination"
	target_path=$destination
fi

# Rename dirs to temp
i=0
for item in "$target_path"/*/; do
	((i++))

	to="$(dirname "$item")/temp-$(printf "%04d" $i)${ext:+.$ext}"

	if [[ $item =~ "posted" ]]; then
		to=$(echo "$to-posted")
	fi

	mv "$item" "$to"
done

# Rename dirs
i=0
for item in "$target_path"/*/; do
	((i++))

	to="$(dirname "$item")/$name-$(printf "%02d" $i)"
	if [[ $item =~ "posted" ]]; then
		to=$(echo "$to-posted")
	fi

	mv "$item" "$to"
done

# Rename files
i=0
for dir in "$target_path"/*/; do
	((i++))
	if [[ $dir =~ "posted" ]]; then
		continue
	fi

	k=0
	for item in "$dir"/*; do
		((k++))

		ext=${item##*.}
		to="$(dirname "$item")/temp-$(printf "%04d" $k)${ext:+.$ext}"
		mv "$item" "$to"
	done

	k=0
	for item in "$dir"/*; do
		((k++))

		ext=${item##*.}
		to="$(dirname "$item")/$(basename "$dir")-$(printf "%04d" $k)${ext:+.$ext}"
		mv "$item" "$to"
	done
done
