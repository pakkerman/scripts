#!/usr/bin/env bash

declare -A workflows prompts

load_workflows() {
  [[ ! -d "$1" ]] && fatal "Workflows directory missing..."

  workflow_files=("$1"/*.*)

  local i file workflow_data
  for file in "${workflow_files[@]}"; do
    [[ ! -f "$file" ]] && continue

    ((i++))
    echo -ne "\rLoading workflows... \t( $i / ${#workflow_files[@]} )"

    key="${file##*/}"

    workflow_data=$(exiftool -b -ImageDescription "$file")
    if [[ -z "$workflow_data" ]]; then
      echo -e "\twarning: workflow is empty"
      continue
    fi

    workflows[${key%\.*}]="$workflow_data"

  done

  echo -ne "\rLoading workflows... \tdone               "
  echo
}

load_prompts() {
  [[ ! -d "$1" ]] && fatal "Prompts directory missing..."

  prompt_files=("$1"/*.*)
  local i file
  for file in "${prompt_files[@]}"; do
    [[ ! -f "$file" ]] && continue

    ((i++))
    echo -ne "\rLoading prompts... \t( $i / ${#prompt_files[@]} )"

    key="${file##*/}"
    prompts[${key%\.*}]=$(exiftool -b -UserComment "$file")
  done

  echo -ne "\rLoading prompts... \tdone               "
  echo
}

write_data() {
  [[ -d "$1" ]] || fatal "target directory missing..."

  targets=("$1"/*.webp)
  local i target target_bname
  for target in "${targets[@]}"; do
    ((i++))

    target_bname=${target##*/}
    target_bname=${target_bname%\.*}

    local key prompt_value workflow_value
    for key in "${!prompts[@]}"; do
      # if [[ "$key" =~ $target_bname ]]; then
      #   prompt_value="${prompts[$key]}"
      # fi
      if [[ $target_bname =~ $key ]]; then

        prompt_value="${prompts[$key]}"
      fi
    done

    for key in "${!workflows[@]}"; do
      # if [[ "$key" =~ $target_bname ]]; then
      #   workflow_value="${workflows[$key]}"
      # fi
      if [[ $target_bname =~ $key ]]; then
        workflow_value="${workflows[$key]}"
      fi
    done

    exiftool -ImageDescription="$workflow_value" -overwrite_original "$target" 1>/dev/null
    exiv2 -M"set Exif.Photo.UserComment charset=Ascii $prompt_value" "$target" 1>/dev/null

  done

  echo -ne "\rWriting to files... \tdone               "
  echo
}

fatal() {
  echo '[fatal]' "$@" >&2
  exit 1
}

main() {

  shopt -s globstar

  local OPTIND OPTARG opt dir
  while getopts 'd:' opt; do
    case "$opt" in
    d) dir=$OPTARG ;;
    *) fatal "No dir provided" ;;
    esac
  done

  echo "processing files in: $dir"
  load_workflows "$dir"/og_workflow
  load_prompts "$dir"/og_prompt

  [[ ! -d "$dir"/prompt_restored ]] && mkdir "$dir"/prompt_restored
  cp "$dir"/out/* "$dir"/prompt_restored
  write_data "$dir"/prompt_restored

}

main "$@"
