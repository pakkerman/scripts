#!/bin/bash
# This script will take a dir and serialize all sub-dir jpg files

[[ ! -d $1 ]] && echo "Valid path to directory required." && exit 1

echo -e "\n----- Renaming $0 -----\n"

RENAME() {
	dir=$1
	i=0
	for path in "$dir"/*.jpg; do
		[[ ! -f $path ]] && continue
		((i++))
		mv "$path" "$(dirname "$path")/$(printf temp-%04d "$i").jpg"
	done

	i=0
	for path in "$dir"/*.jpg; do
		[[ ! -f $path ]] && continue

		((i++))
		from=$path
		to="$dir/$(basename "$dir")-$(printf %04d "$i").jpg"

		mv "$from" "$to"
	done
}

for d in "$1"/*; do
	[[ ! -d "$d" ]] && continue
	[[ "$d" =~ -posted$ ]] && continue
	echo "$d"
	RENAME "$d"
	$(dirname "$0")/make-slides.sh "$d"

done
