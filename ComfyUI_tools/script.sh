#!/bin/bash

rm "_input.mp4"
rm _output_*
rm "_output_x264.mp4"
rm -r trimmed/

# trim
mkdir trimmed
mkdir tmp

# rename files
mv ./*.mp4 tmp/

idx=0
for f in ./tmp/*.mp4; do
  new_filename="$((idx + 1))"
  new_filename="clip-$(printf %02d $((idx + 1)))"
  [[ "$f" =~ _r.mp4$ ]] && new_filename="$new_filename"_r

  mv "$f" "$new_filename".mp4
  mv "$new_filename".mp4 .

  idx=$((idx + 1))
done

rm -r tmp/

# trim files
num_of_videos=$(find . -maxdepth 1 -type f -name "*.mp4" | wc -l | tr -d " ")
idx=0

for f in *.mp4; do

  total_length=28
  trim_start=0.4
  length=$(echo "scale=1; $total_length / $num_of_videos" | bc)

  length=$(echo "$length" | awk '{if ($1 <= 1.5) $1 = 1.5; else if ($1 > 2.2) $1 = 2.2; print $1}')

  filter="null"
  flip_random=$((RANDOM % 2))

  if [[ "$f" =~ _r.mp4 ]]; then
    # trim_start=$(echo "scale=1; 3 - $length" | bc)
    trim_start=$(printf "%.1f" "$(echo "scale=1; 3 - $length" | bc)")
    filter="reverse"
    echo "$f is reversed"
  fi

  # random flip
  if [ "$flip_random" -eq 1 ]; then
    filter="$filter,hflip"
  fi

  # first video is full length and not reversed
  if [ "$idx" -lt 1 ]; then
    trim_start=0.4
    filter="null"
    length=2.5
  fi

  ffmpeg \
    -loglevel panic \
    -i "$f" \
    -ss "$trim_start" \
    -t "$length" \
    -vf "$filter" \
    -c:v libx264 -crf 23 \
    -preset medium \
    "trimmed/trimmed_$f"

  idx=$((idx + 1))
  # echo -ne "trimming videos: $idx of $num_of_videos\033[0K\r"
  echo "starting: $trim_start, length: $length ( $idx of $num_of_videos )"
done

# concat
command ls trimmed/*.mp4 | awk '{print "file \x27"$0"\x27"}' >mylist.txt

ffmpeg \
  -loglevel panic \
  -f concat -safe 0 \
  -i mylist.txt \
  -c copy -an \
  "_input.mp4"

rm mylist.txt

# add watermark
watermark="$HOME/Documents/assets/watermark.png"

# while true; do
#   read -rp "Continue to encode x265 video? [Y/n]: "
#   case "$user_input" in
#   [Nn]*)
#     echo "exit"
#     exit 1
#     ;;
#   *)
#     echo "Continuing..."
#     break
#     ;;
#   esac
# done

ffmpeg \
  -i "_input.mp4" \
  -i "$watermark" \
  -f lavfi -i anullsrc=cl=stereo:r=48000 \
  -loglevel info \
  -filter_complex "
  [0:v]scale=1080:1920:flags=spline,
  hqdn3d=3:3:6:6,
  unsharp=luma_msize_x=3:luma_msize_y=3:luma_amount=1.5:chroma_msize_x=3:chroma_msize_y=3:chroma_amount=1.5,
  noise=allf=t:alls=5, 
  vignette=angle=PI/8[v0];
  [v0][1:v]overlay=W-w-30:H-h-75,format=yuv420p[v]
  " \
  -map "[v]" \
  -map 2:a \
  -c:v libx265 \
  -crf 23 \
  -preset medium \
  -tune grain \
  -pix_fmt yuv420p \
  -tag:v hvc1 \
  -level 4.1 \
  -r 30 -g 60 -keyint_min 60 \
  -c:a aac -b:a 160k -ar 48000 -ac 2 \
  -shortest \
  -movflags +faststart \
  "_output_high.mp4"

# ffmpeg \
#   -i "_input.mp4" \
#   -i "$watermark" \
#   -f lavfi -i anullsrc=cl=stereo:r=48000 \
#   -loglevel info \
#   -filter_complex "
#   [0:v]scale=1080:1920:flags=spline,
#   hqdn3d=3:3:6:6,
#   unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=1.5:chroma_msize_x=5:chroma_msize_y=5:chroma_amount=1.5,
#   noise=allf=t:alls=3,
#   vignette=angle=PI/8[v0];
#   [v0][1:v]overlay=W-w-30:H-h-75,format=yuv420p[v]
#   " \
#   -map "[v]" \
#   -map 2:a \
#   -c:v libx265 \
#   -crf 25 \
#   -preset medium \
#   -tune grain \
#   -pix_fmt yuv420p \
#   -tag:v hvc1 \
#   -level 4.1 \
#   -r 30 -g 60 -keyint_min 60 \
#   -c:a aac -b:a 160k -ar 48000 -ac 2 \
#   -shortest \
#   -movflags +faststart \
#   "_output_low.mp4"

# clean up
rm -r trimmed/
rm "_input.mp4"
