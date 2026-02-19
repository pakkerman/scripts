#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}
source "$SCRIPT_DIR"/lib/utils.sh

rename_subdirs() {
  local posted_dirs=("$1"/posted_*/)
  echo "${posted_dirs[@]}" | tr " " "\n"

  subdirs=("$1"/*/)

  local tmp_dir="$1"/__tmp
  mkdir "$tmp_dir"
  mv "${subdirs[@]}" "$tmp_dir"

  local idx=0 file_idx
  [[ -n ${#posted_dirs[@]} ]] && idx=${#posted_dirs[@]}
  for subdir in "$tmp_dir"/*/; do
    [[ "$subdir" =~ "posted_" ]] && continue
    [[ "$subdir" =~ "unsort_" ]] && continue

    ((idx++))
    file_idx=$(printf '%02d' "$idx")
    bname=${1##*/}

    mv "$subdir" "$1/$bname-$file_idx"
  done

  mv "$tmp_dir"/* "$1"
  rm -r "$tmp_dir"
}

rename_images_in_subdirs() {
  shopt -s nocaseglob

  for subdir in "$1"/*/; do
    [[ "$subdir" =~ "posted_" ]] && continue
    [[ "$subdir" =~ "unsort_" ]] && continue

    echo "> Renaming files in $subdir"

    local idx=0
    local dir_name=$(basename "$subdir")

    for file in "$subdir"*.{jpg,jpeg,webp,png}; do
      [[ -f "$file" ]] || continue

      ((idx++))

      local ext="${file##*.}"
      local file_idx=$(printf '%02d' "$idx")

      mv -n "$file" "$subdir/.tmp_$file_idx.$ext"
    done

    idx=0
    for file in "$subdir"*.mp4; do
      [[ -f "$file" ]] || continue

      ((idx++))

      local ext="${file##*.}"
      local file_idx=$(printf '%02d' "$idx")

      mv -n "$file" "$subdir/.tmp_$file_idx.$ext"
    done

    for tmpfile in "$subdir".tmp_*; do
      [[ -f "$tmpfile" ]] || continue

      mv "$tmpfile" "${tmpfile//.tmp_/$dir_name-}"
    done
  done
}

# rename_images_in_subdirs() {
#   for subdir in "$1"/*/; do
#     [[ "$subdir" =~ "posted_" ]] && continue
#
#     local tmp_dir="$subdir/__tmp"
#     mkdir "$tmp_dir"
#
#     echo "> renaming files in $subdir"
#
#     local files=("$subdir"/*.jpg "$subdir"/*.jpeg "$subdir"/*.webp "$subdir"/*.png)
#     mv "${files[@]}" "$tmp_dir"
#
#     local idx=0 file_idx
#     for file in "$tmp_dir"/*.*; do
#       echo "$file"
#       ((idx++))
#       file_idx=$(printf '%02d' "$idx")
#       ext=${file##*.}
#
#       local subdir_trimmed=${subdir:0:-1}
#       mv "$file" "$subdir/${subdir_trimmed##*/}-$file_idx.$ext" | tr " " '\n'
#
#     done
#
#     rm -r "$tmp_dir"
#   done
#
# }

rename() {
  DIR="$1"

  echo "Rename images"
  shopt -s extglob

  [[ ! -d "$DIR" ]] && fatal "Invalid directory"

  rename_subdirs "$DIR"
  rename_images_in_subdirs "$DIR"
}
