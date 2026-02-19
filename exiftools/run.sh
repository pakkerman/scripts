#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}
source "$SCRIPT_DIR"/lib/tui.sh
source "$SCRIPT_DIR"/lib/utils.sh
source "$SCRIPT_DIR"/rename.sh
source "$SCRIPT_DIR"/image-processing.sh
source "$SCRIPT_DIR"/make-video.sh

main() {
  shopt -s globstar nullglob
  tui-init

  local target_dir=${1%/}
  local script_dir="${0%/*}"

  while true; do

    echo -e "\n --- Image Toolkit --- \n"

    if [[ ! -d "$target_dir" ]]; then
      read -rp $"Target directory: " target_dir
    fi

    local files=(./*.*)

    print-bottom-line "Current target: ${#files[@]} files in ~${target_dir/Users\/????\//} " 0
    echo -e "\tPick an operation:"
    echo -e "\t\t1) Encode video"
    echo -e "\t\t2) Rename Images"
    echo -e "\t\t3) Post-porcess Images"
    echo -e "\t\t4) Sort Images"
    echo -e "\t\t5) Target subdirectory"
    echo -e "\t\t6) Add watermark"
    echo -e "\t\t7) Crop images to 1:2 ratio"
    echo -e "\t\t8) Crop images to 9:16 ratio"
    echo -e "\t\t9) Translate Civitai metadata\n"
    read -rp "        Enter option: " option

    # clear

    case $option in
    1)
      make_video "$target_dir"
      ;;
    2)
      rename "$target_dir"
      ;;
    3)
      image-processing "$target_dir"
      ;;
    4)
      echo "Sort images (with text-similarity)"
      read -rp "choose K: (default 3) " K
      bun "$HOME"/git/prompt-similarity-grouping/src/index.ts -p "$target_dir" -c "${K:-3}"
      ;;
    5)
      subdirs=$(find "$target_dir" -type d)
      choice=$(echo "$subdirs" | fzf)

      echo -e "\n you have chosen $choice as the target"
      main "$choice"
      break
      ;;
    6)
      echo "Add watermark"
      "$script_dir"/add_watermark.sh "$target_dir"
      ;;
    7)
      echo "Crop to 1:2 ratio"
      "$script_dir"/crop1to2.sh "$target_dir"
      ;;
    8)
      echo "Crop to 9:16 ratio"
      "$script_dir"/crop9to16.sh "$target_dir"
      ;;
    *) echo "Invalid option. Please enter a number" ;;
    esac

  done
}

# clear
main "$@"
