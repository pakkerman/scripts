#!/usr/bin/env bash

# rename subdirectories
# get new subdirectories
# go into each subdirectories
# rename all files to temp
# get renamed files
# rename all files

SCRIPT_DIR=${BASH_SOURCE%/*}
source "$SCRIPT_DIR"/lib/utils.sh

rename_subdirs() {
  local dir="$1"
  local subdirs=("$dir"/*)
  rename_to_tmp "${subdirs[@]}"

  local idx=0 file_idx
  for subdir in "$dir"/*; do

    ((idx++))
    file_idx=$(printf '%02d' "$idx")
    dname=${subdir%/*}

    echo -e "\t\tdname: ${dname##*/}"
    echo -e "\t\tdname: $dname/${dname##*/}-$file_idx"

    mv "$subdir" "$dname/${dname##*/}-$file_idx"
  done

}

rename_to_tmp() {

  echo "> renaming to tmp..."

  for item in "$@"; do
    local dname=${item%/*}
    local bname=${item##*/}

    mv "$item" "$dname/tmp_$bname"

  done
}

rename_files() {
  echo "> renaming files..."
  local dir="$1"
  for subdir in "$dir"/*; do

    files=("$subdir"/*.webp)
    rename_to_tmp "${files[@]}"

    local prefix=${subdir##*/}
    local idx=0 file_idx dname bname
    for file in "$subdir"/*.webp; do
      ((idx++))
      file_idx=$(printf '%02d' "$idx")
      dname=${file%/*}
      bname=${file##*/tmp_}
      ext=${file##*.}

      mv "$file" "$dname/$prefix-$file_idx.$ext"

    done

  done

}

rename() {
  echo "Selected rename images"
  shopt -s extglob

  DIR="$1"
  [[ ! -d "$DIR" ]] && fatal "Invalid directory"

  rename_subdirs "$DIR"
  rename_files "$DIR"

}
