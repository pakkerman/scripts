#!/bin/bash

dir="$HOME/Documents/.generation"
mp4files=$(fd mp4 "$dir")

vlc \
	--video-filter "transform{type=270}" \
	--rate 0.25 $mp4files
