#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}
source "$SCRIPT_DIR"/lib/utils.sh

rename_subdirs() {
  local tmp_dir="$1"/__tmp
  mkdir "$tmp_dir"

  subdirs=("$1"/*/)

  mv "${subdirs[@]}" "$tmp_dir"

  local idx=0 file_idx
  for subdir in "$tmp_dir"/*/; do
    [[ "$subdir" =~ "posted_" ]] && continue

    ((idx++))
    file_idx=$(printf '%02d' "$idx")
    bname=${1##*/}

    mv "$subdir" "$1/$bname-$file_idx"
  done

  rm -r "$tmp_dir"
}

rename_images_in_subdirs() {
  for subdir in "$1"/*/; do
    [[ "$subdir" =~ "posted_" ]] && continue

    local tmp_dir="$subdir/__tmp"
    mkdir "$tmp_dir"

    echo "> renaming files in $subdir"

    local files=("$subdir"/*.jpg "$subdir"/*.jpeg "$subdir"/*.webp "$subdir"/*.png)
    mv "${files[@]}" "$tmp_dir"

    local idx=0 file_idx
    for file in "$tmp_dir"/*.*; do
      echo "$file"
      ((idx++))
      file_idx=$(printf '%02d' "$idx")
      ext=${file##*.}

      local subdir_trimmed=${subdir:0:-1}
      mv "$file" "$subdir/${subdir_trimmed##*/}-$file_idx.$ext" | tr " " '\n'

    done

    rm -r "$tmp_dir"
  done

}

rename() {
  DIR="$1"

  echo "Rename images"
  shopt -s extglob

  [[ ! -d "$DIR" ]] && fatal "Invalid directory"

  rename_subdirs "$DIR"
  rename_images_in_subdirs "$DIR"
}
