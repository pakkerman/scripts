#!/bin/bash

[[ ! -d $1 ]] && echo "invalid directory" && exit
[[ -n $2 ]] && echo "enter something to remove"

echo "$1"
echo "removing $2"

files=("$1"/*.jpg)

for file in "${files[@]}"; do
	echo -e "\n--------------$file----------------\n"
	removed=$(exiftool -b -UserComment "$file" | sed "s/$2//g")
	echo "$removed"
	exiv2 -M "set Exif.Photo.UserComment $removed" "$file"
done
