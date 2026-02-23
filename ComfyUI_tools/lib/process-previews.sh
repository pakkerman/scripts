#!/usr/bin/env bash

# this scripts will periodically move and encode videos
# from ~/Downloads/comfy_downloads to ~/Downloads/preview/

TIMEOUT=180
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT=$(dirname "$SCRIPT_DIR")

function process-videos() {
  local vid_counter=0

  while true; do
    local targets=(/Users/pakk/Downloads/comfy_downloads/*.webm)
    [[ "${#targets[@]}" -ge 1 ]] && mv "${targets[@]}" ~/Downloads/preview

    local files=(./*.webm)
    ((vid_counter += "${#files[@]}"))

    parallel --jobs 1 "$ROOT"/lib/encode_video.sh {} ::: *.webm

    [[ ! -d webm/ ]] && mkdir webm
    local webms=(./*.webm)
    [[ -n "${webms[*]}" ]] && mv ./*.webm webm/

    local timeout=$TIMEOUT
    while [[ "$timeout" -ge 0 ]]; do
      msg="$vid_counter vidoes processed, re-run in $timeout seconds"

      printf '\e[s'
      printf '\e[%dB' $LINES
      printf '\e[30;43;1;3m     %s      \e[0m\r' "$msg"
      printf '\e[u'

      sleep 1
      ((timeout--))
    done
  done
}

function main() {
  local OPTARG OPTIND opt
  while getopts 't:' opt; do
    case "$opt" in
    t) TIMEOUT=$OPTARG ;;
    *) ;;
    esac
  done

  cd ~/Downloads/preview/ || exit 1
  shopt -s nullglob
  process-videos
}

main "$@"
