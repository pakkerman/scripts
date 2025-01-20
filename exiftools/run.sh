#!/bin/bash

[[ ! -d "$1" ]] && echo "Invalid directory" && exit 1
input_dir="$(cd "$1" && pwd -P)/"
root=$(dirname "$0")

clear

function menu() {

  [[ ! -d "$1" ]] && echo "Invalid directory" && exit 1
  dir=$1

  while true; do

    echo -e "\n --- Generated Image Toolkit --- \n"
    echo -e "   Current target: $dir"
    echo -e "   Pick an operation:"
    echo -e "\t1) Convert Images"
    echo -e "\t2) Rename Images"
    echo -e "\t3) Post-porcess Images"
    echo -e "\t4) Sort Images"
    echo -e "\t5) Target subdirectory"
    echo -e "\t6) Add watermark"
    echo -e "\t7) Crop images to 1:2 ratio"
    echo -e "\t8) Translate Civitai metadata\n"
    read -rp "   Enter a number: " option

    clear

    case $option in
    1)
      echo "Selected convert images"
      "$root"/../exiftool_v2/convert_tensorart.sh "$dir"
      ;;
    2)
      echo "Selected rename images"
      dir=$("$root"/rename.sh "$dir")
      dir=$(echo "$dir" | tail -n 1)
      ;;
    3)
      echo "Selected image processing"
      "$root"/image_processing.sh "$dir"
      ;;
    4)
      echo "Sort images (with text-similarity)"
      read -rp "choose K: (default 3) " K
      bun "$HOME"/git/prompt-similarity-grouping/src/index.ts -p "$dir" -c "${K:-3}"

      ;;
    5)
      subdirs=$(find "$input_dir" -type d)
      choice=$(echo "$subdirs" | fzf)

      clear

      echo -e "\n you have chosen $choice as the target"
      menu "$choice"

      break
      ;;

    6)
      echo "Add watermark"
      "$root"/add_watermark.sh "$dir"
      ;;

    7)
      echo "Crop to 1:2 ratio"
      "$root"/crop.sh "$dir"
      ;;

    8)
      echo "Translate Civitai metadata"
      parallel "$root"/civitai-translator.sh {} ::: "$dir"/*
      ;;

    *)

      echo "Invalid option. Please enter a number"
      ;;
    esac

  done
}

menu "$input_dir"
