#!/usr/bin/env bash

# run save-image server and preview processing script

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT=$(dirname "$SCRIPT_DIR")

PYTHON_PID=0
MONITOR_PID=0

function cleanup() {
  echo -ne "\nTerminating..."

  if [[ $PYTHON_PID -ne 0 ]]; then
    kill "$PYTHON_PID" 2>/dev/null
  fi

  if [[ $MONITOR_PID -ne 0 ]]; then
    kill "$MONITOR_PID" 2>/dev/null
  fi
  echo "Done."
  exit 0
}

function monitor() {
  # caffeinate if there are files, and refresh if already caffeinate

  shopt -s nullglob

  local CAFFEINATE_PID=0
  while true; do
    local files
    files=(~/Downloads/comfy_downloads/*.webm)
    if [[ "${#files[@]}" -gt 0 ]]; then
      if [[ 0 -ne "$CAFFEINATE_PID" ]]; then
        kill "$CAFFEINATE_PID"
        CAFFEINATE_PID=0
      fi

      caffeinate -d -t 900 &
      CAFFEINATE_PID=$!
      echo "caffeinate for 15 mins"
    fi

    sleep 60
  done
}

function main() {
  clear

  trap cleanup SIGINT SIGTERM

  monitor &
  MONITOR_PID=$!

  python3 "$ROOT"/server/save_image.py &
  PYTHON_PID=$!

  "$ROOT"/lib/process-previews.sh -t 60
}

main "$@"
