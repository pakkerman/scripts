#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR=$(cd -- "$SCRIPT_DIR/.." &>/dev/null && pwd)
source "$ROOT_DIR"/lib/tui.sh
source "$ROOT_DIR"/lib/utils.sh
source "$ROOT_DIR"/lib/ops/rename.sh
source "$ROOT_DIR"/lib/ops/image-processing.sh
source "$ROOT_DIR"/lib/ops/make-video.sh

main() {
  clear

  shopt -s globstar nullglob
  tui-init

  local target_dir=${1%/}
  local tools_dir="$ROOT_DIR/tools"

  while true; do

    echo -e "\n --- Image Toolkit --- \n"

    while [[ ! -d "$target_dir" ]]; do
      read -E -rp "Target directory: " target_dir
    done

    print-bottom-line "Current target: ~${target_dir/Users\/????\//}"
    echo -e "       Pick an operation:"
    echo -e "\t\t1) Encode video"
    echo -e "\t\t2) Rename Images"
    echo -e "\t\t3) Post-porcess Images"
    echo -e "\t\t4) Sort Images"
    echo -e "\t\t5) Target subdirectory"
    echo -e "\t\t6) Add watermark"
    echo -e "\t\t7) Crop images to 1:2 ratio"
    echo -e "\t\t8) Crop images to 9:16 ratio"
    echo -e "\t\t9) Translate Civitai metadata\n"
    read -E -rp "      Enter option: " option

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
      ;;
    6)
      echo "Add watermark"
      "$tools_dir"/add_watermark.sh "$target_dir"
      ;;
    *) echo "Invalid option. Please enter a number" ;;
    esac

  done
}

main "$@"
