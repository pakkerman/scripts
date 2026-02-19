#!/usr/bin/env bash

file="$1"
jpg="${file%.*}out.png"
magick "$file" -strip -quality 90 "$jpg"

p=$(exiftool -Parameters -b "$file")
exiftool -Parameters="$p" "$jpg"
# exiv2 -M "set Exif.Photo.UserComment $p" "$jpg"
