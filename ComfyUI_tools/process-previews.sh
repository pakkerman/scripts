#!/usr/bin/env bash

# this scripts will periodically move and encode videos
# from ~/Downloads/comfy_downloads to ~/Downloads/preview/

TIMEOUT=180

function process-videos() {
  local vid_counter=0

  while true; do
    local targets=(/Users/pakk/Downloads/comfy_downloads/*.webm)
    [[ "${#targets[@]}" -ge 1 ]] && mv "${targets[@]}" ~/Downloads/preview

    local files=(./*.webm)
    ((vid_counter += "${#files[@]}"))

    parallel --jobs 1 ~/Downloads/scripts/encode_video.sh {} ::: *.webm

    [[ ! -d webm/ ]] && mkdir webm
    local webms=(./*.webm)
    [[ -n "${webms[*]}" ]] && mv ./*.webm webm/

    local timeout=$TIMEOUT
    while [[ "$timeout" -ge 0 ]]; do
      printf '\e[30;43;1;3m     %s video processed, re-run in %d seconds      \e[0m\r' $vid_counter $timeout
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

  echo "timeout: $TIMEOUT"

  cd ~/Downloads/preview/ || exit 1
  shopt -s nullglob
  process-videos
}

main "$@"
