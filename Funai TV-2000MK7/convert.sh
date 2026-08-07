#!/bin/sh
mkdir -p out

has_files=0

for f in *.avi *.mp4 *.mkv *.webm; do
  [ -f "$f" ] || continue
  has_files=1
  
  # Count the number of audio streams in the current file
  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$f" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  # Funai TV-2000MK7 video and audio baseline pipeline
  # Tube: 20-inch (51cm) 4:3 shadow-mask CRT. Decoder: Integrated single-chip PAL/SECAM/NTSC unit.
  filter_complex="[0:v]scale=768:576:force_original_aspect_ratio=decrease, \
        pad=768:576:(ow-iw)/2:(oh-ih)/2, \
        noise=alls=5:allf=t+u, \
        chromashift=cbh=1:crh=-1:cbv=0:crv=0, \
        boxblur=0.5:1:0:0, \
        eq=saturation=1.02:brightness=-0.001:contrast=1.12:gamma=1.00, \
        drawgrid=w=768:h=2:c=black@0.10:t=1, \
        curves=m='0/0.02 0.5/0.50 1/0.98', \
        vignette=angle=PI/7.5 [v_crt]; \
    anoisesrc=color=pink:amplitude=0.001:sample_rate=32000,highpass=f=100,lowpass=f=12500[a_bg_raw]"
  
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

  # Funai MK7 sound path: Integrated IC power amplifier driving an internal dynamic speaker
  i=0
  while [ "$i" -lt "$audio_count" ]; do
    filter_complex="${filter_complex}; [0:a:$i]aformat=channel_layouts=mono,highpass=f=100,lowpass=f=12500,equalizer=f=3200:width_type=h:width=300:g=2.5,equalizer=f=350:width_type=h:width=120:g=1[a_mono$i]; [a_mono$i][bg$i]amix=inputs=2:weights=1 0.05[a_out$i]"
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