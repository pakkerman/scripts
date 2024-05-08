#!/bin/bash

dir="$HOME/Documents/.generation"
mp4files=$(fd mp4 "$dir")

vlc --rate 0.25 $mp4files
