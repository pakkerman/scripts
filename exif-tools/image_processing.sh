#!/bin/bash

start=$(date +%s)

# Calculate the elapsed time
process() {
	[[ -z "$1" ]] && echo "missing input" && exit 1
	[[ -z "$2" ]] && echo "missing output" && exit 1

	input=$1
	output=$2

	convert "$input" -unsharp 0x1+1+0 "$output"
	endpoints -l 5,15 -h 250,245 -c all "$output" "$output" 1>/dev/null
	# filmgrain -a 75 -A 75 "$output" "$output"
	# filmgrain -a 50 -A 33 -n multiplicative "$output" "$output"
	filmgrain -a 100 -A 80 -d 100 -D 100 -c softlight -C softlight "$output" "$output"

	convert "$output" -quality 90 "$output"
	echo "$(basename "$1") processed"
}

[[ ! -d $1 ]] && echo "invalid directory" && exit
[[ -n $2 ]] && echo "enter something to process"

echo -e "--- Post Processing Images --- \n"

bak_path="$1/bak"
mkdir -p "$bak_path"

mv "$bak_path"/*.jpg "$1"
cp "$1"/*.jpg "$bak_path"

files=("$1"/*.jpg)
count=0

for file in "${files[@]}"; do
	process "$file" "$file"
done

end=$(date +%s)
elapsed=$((end - start))

echo -e "Files processed: ${#files[@]}, finished in $elapsed seconds"
