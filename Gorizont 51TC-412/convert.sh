#!/bin/sh
mkdir -p out

has_files=0

for f in *.avi *.mp4 *.mkv *.webm; do
  [ -f "$f" ] || continue
  has_files=1
  
  # Count the number of audio streams in the current file
  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$f" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  # Gorizont 51TC-412 / 51TC-510 video and audio baseline pipeline
  # Tube: 51LK2B / planar 51cm 4:3 CRT. Decoder: MCR-403 / TDA3561A PAL/SECAM unit.
  filter_complex="[0:v]scale=768:576:force_original_aspect_ratio=decrease, \
        pad=768:576:(ow-iw)/2:(oh-ih)/2, \
        noise=alls=7:allf=t+u, \
        chromashift=cbh=2:crh=-1:cbv=0:crv=0, \
        boxblur=0.7:1:0:0, \
        eq=saturation=0.96:brightness=-0.002:contrast=1.10:gamma=1.02, \
        drawgrid=w=768:h=2:c=black@0.12:t=1, \
        curves=m='0/0.03 0.5/0.49 1/0.96', \
        vignette=angle=PI/7.0 [v_crt]; \
    anoisesrc=color=pink:amplitude=0.0015:sample_rate=32000,highpass=f=120,lowpass=f=11500[a_bg_raw]"
  
  # Split the background audio track into identical outputs for each input audio stream
  if [ "$audio_count" -gt 1 ]; then
    bg_split="; [a_bg_raw]asplit=outputs=$audio_count"
    i=0
    while [ "$i" -lt "$audio_count" ]; do
      bg_split="${bg_split}[bg$i]"
      i=$((i + 1))
    done
    filter_complex="${filter_complex}${bg_split}"
  else
    filter_complex="${filter_complex}; [a_bg_raw]anull[bg0]"
  fi

  maps="-map [v_crt]"
  audio_settings=""

  # Gorizont 51TC internal sound path: K174UN14 amplifier driving 3GDSH-1 speaker
  i=0
  while [ "$i" -lt "$audio_count" ]; do
    filter_complex="${filter_complex}; [0:a:$i]aformat=channel_layouts=mono,highpass=f=120,lowpass=f=11500,equalizer=f=3000:width_type=h:width=250:g=3,equalizer=f=350:width_type=h:width=120:g=1.5[a_mono$i]; [a_mono$i][bg$i]amix=inputs=2:weights=1 0.08[a_out$i]"
    maps="$maps -map [a_out$i]"
    audio_settings="$audio_settings -c:a:$i aac -ar:a:$i 32000 -ac:a:$i 1"
    i=$((i + 1))
  done

  # Execute full compilation matrix
  eval "ffmpeg -i \"\$f\" -filter_complex \"$filter_complex\" \
    $maps \
    -map 0:s? \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -b:v 2500k \
    $audio_settings \
    -c:s copy \
    -shortest out/\"\${f%.*}\".mkv"
done

if [ "$has_files" -eq 0 ]; then
  echo "Critical error: No video files found in directory $(pwd)."
  exit 1
fi