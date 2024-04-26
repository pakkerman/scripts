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

i=0
base=$(basename "$1")
for dir in "$1"*/; do

	[[ "$dir" =~ -posted$ ]] && continue

	((i++))
	mv "$dir" "$1/$base-$(printf "%02d" $i)"
done

for dir in "$1"*/; do

	RENAME "$dir"

done

for dir in "$1"*/; do

	./make-slides.sh "$dir"

done
