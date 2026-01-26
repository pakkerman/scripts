#!/usr/bin/env bash

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
  noise=c0s=24:c0f=t+u,
  gblur=sigma=0.6,
  rgbashift=rh=-0.6:gh=0.6[v0];
  [v0][1:v]overlay=W-w-30:H-h-75,
  format=yuv420p[v]
  " \
  -map "[v]" \
  -c:v libx265 \
  -crf 22 \
  -preset medium \
  -tune grain \
  -pix_fmt yuv420p \
  -tag:v hvc1 \
  -level 4.1 \
  -shortest \
  -movflags +faststart \
  "${1%.*}"_output.mp4

# -r 24 -g 48 -keyint_min 48 \#!/usr/bin/env bash

# ffmpeg \
#   -y \
#   -i "$1" \
#   -i "$HOME/Documents/assets/watermark.png" \
#   -f lavfi -i anullsrc=cl=stereo:r=48000 \
#   -loglevel info \
#   -filter_complex "
#   [0:v]scale=1080:1920:force_original_aspect_ratio=decrease:flags=spline,
#   hqdn3d=3:3:6:6,
#   unsharp=luma_msize_x=3:luma_msize_y=3:luma_amount=1:chroma_msize_x=3:chroma_msize_y=3:chroma_amount=1,
#   vignette=angle=PI/8,
#   noise=c0s=24:c0f=t+u,
#   gblur=sigma=0.6,
#   rgbashift=rh=-0.6:gh=0.6[v0];
#   [v0][1:v]overlay=W-w-30:H-h-75,format=yuv420p[v]
#   " \
#   -map "[v]" \
#   -map 2:a \
#   -c:v libx265 \
#   -crf 22 \
#   -preset medium \
#   -tune grain \
#   -pix_fmt yuv420p \
#   -tag:v hvc1 \
#   -level 4.1 \
#   -c:a aac -b:a 160k -ar 48000 -ac 2 \
#   -shortest \
#   -movflags +faststart \
#   "${1%.*}"_output.mp4
#
# # -r 24 -g 48 -keyint_min 48 \
