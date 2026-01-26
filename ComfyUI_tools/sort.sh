#!/usr/bin/env bash

# sort files into dir name with the first 6 char
cd ~/Downloads/preview || exit 1

for f in *.mp4; do
  dir=$(echo "$f" | cut -c 1-6)
  mkdir "$dir" 2>/dev/null

  mv "$f" "$dir"

done
