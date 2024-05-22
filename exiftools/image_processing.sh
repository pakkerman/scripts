#!/bin/bash

start=$(date +%s)

# Calculate the elapsed time
process() {
	[[ -z "$1" ]] && echo "missing input" && exit 1
	[[ -z "$2" ]] && echo "missing output" && exit 1

	input=$1
	output=$2

	# convert "$input" -unsharp 0x1+0.5+0 "$output"
	endpoints -l 5,15 -h 250,245 -c all "$input" "$output" 1>/dev/null
	filmgrain -a 95 -A 95 -d 95 -D 95 -c softlight -C softlight "$output" "$output"
	# filmgrain -a 75 -A 75 "$output" "$output"
	# filmgrain -a 50 -A 33 -n multiplicative "$output" "$output"

	convert "$output" -quality 92 "$output"
}

dir=$(dirname "$1")/$(basename "$1")/
[[ ! -d $dir ]] && echo "invalid directory" && exit
[[ -n $2 ]] && echo "enter something to process"

echo -e "\n --- Image Post Processing --- \n"

bak_path="$dir/bak"
mkdir -p "$bak_path"

mv "$bak_path"/*.jpg "$dir" 2>/dev/null
cp "$dir"/*.jpg "$bak_path"

files=("$dir"/*.jpg)
count=0

for file in "${files[@]}"; do
	((count++))
	echo -ne "\r\033[K Processing $(basename "$file") ($count / ${#files[@]})"
	process "$file" "$file"
done

end=$(date +%s)
elapsed=$((end - start))

echo -ne "\r\033[K Done in $elapsed seconds\n"
echo -e " Files processed: ${#files[@]}"
