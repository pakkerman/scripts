#!/usr/bin/env bash

x_pad=20
y_pad=40
corner=$((RANDOM % 3))

case "$corner" in
0)
  overlay_x="W-w-$x_pad"
  overlay_y="$y_pad"
  ;;
1)
  overlay_x="$x_pad"
  overlay_y="H-h-$y_pad"
  ;;
2)
  overlay_x="W-w-$x_pad"
  overlay_y="H-h-$y_pad"
  ;;
esac

grain=18
gaussian_blur=0.4

ffmpeg \
  -y \
  -i "$1" \
  -i "$HOME/Documents/assets/watermark.png" \
  -loglevel info \
  -filter_complex "
  [0:v]scale=1080:1920:force_original_aspect_ratio=increase:flags=lanczos,
  crop=1080:1920,
  setsar=1,
  hqdn3d=3:3:6:6,
  unsharp=luma_msize_x=3:luma_msize_y=3:luma_amount=1:chroma_msize_x=3:chroma_msize_y=3:chroma_amount=1,
  vignette=angle=PI/8,
  noise=c0s=$grain:c0f=t+u,
  gblur=sigma=$gaussian_blur,
  rgbashift=rh=-0.4:gh=0.4[v0];
  [v0][1:v]overlay=$overlay_x:$overlay_y,
  format=yuv420p[v]
  " \
  -map "[v]" \
  -c:v libx265 \
  -crf 26 \
  -preset slow \
  -tune grain \
  -pix_fmt yuv420p \
  -tag:v hvc1 \
  -level 4.1 \
  -shortest \
  -movflags +faststart \
  "${1%.*}"_output.mp4
