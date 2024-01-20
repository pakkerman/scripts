#!/bin/bash
# This script will take a dir and serialize all subdir jpg files

echo -e "\n----- Running $0 -----\n"

[[ ! -d $1 ]] && echo "Valid path to directory required." && exit 1

RENAME(){
    dir=$1
    i=0
    for path in "$dir"/*.jpg; do
        [[ ! -f $path ]] && continue
        (( i++ ))
        mv "$path" "$(dirname "$path")/$(printf temp-%04d "$i").jpg"
    done
    
    i=0
    for path in "$dir"/*.jpg; do
        [[ ! -f $path ]] && continue
        
        (( i++ ))
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



