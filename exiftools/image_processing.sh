#!/bin/bash

start=$(date +%s)

# Calculate the elapsed time
process_image() {
	[[ -z "$1" ]] && echo "missing input" && exit 1

	input=$1
	output=$1

	magick "$input" -unsharp 0x1+0.5+0 "$output"
	# convert "$input" -unsharp 0x1+0.5+0 "$output"
	# less contrast
	# endpoints -l 5,15 -h 250,245 -c all "$output" "$output" 2>/dev/null

	# more desaturated
	endpoints -l 5,15 -h 250,245 -c all "$output" "$output" 1>/dev/null
	# more contrast
	# endpoints -l 15,5 -h 245,250 -c all "$output" "$output" 2>/dev/null

	# less dense grain for smaller size image
	filmgrain -a 75 -A 75 -d 75 -D 75 -c softlight -C softlight "$output" "$output" 2>/dev/null
	# more dense grain for large size image
	# filmgrain -a 95 -A 95 -d 95 -D 95 -c softlight -C softlight "$output" "$output" 2>/dev/null

	magick "$output" -quality 96 "$output" 2>/dev/null
}

dir=$(dirname "$1")/$(basename "$1")/
[[ ! -d $dir ]] && echo "invalid directory" && exit
[[ -n $2 ]] && echo "enter something to process"

echo -e "\n --- Image Post Processing --- \n"

bak_path="$dir"bak
mkdir -p "$bak_path"

# enable glob extension
shopt -s extglob

mv "$bak_path"/*.*(jpg|jpeg) "$dir" 2>/dev/null
cp "$dir"/*.*(jpg|jpeg) "$bak_path"

files=("$dir"/*.*(jpg|jpeg))

# Use parallel
export -f process_image
time parallel \
	--progress \
	--jobs 8 \
	--delay 0.1 \
	process_image {} ::: "${files[@]}"

end=$(date +%s)
elapsed=$((end - start))

echo -ne "\r\033[K Done in $elapsed seconds\n"
echo -e " Files processed: ${#files[@]}"
