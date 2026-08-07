#!/bin/sh
mkdir -p out

has_files=0

for f in *.avi *.mp4 *.mkv *.webm; do
  [ -f "$f" ] || continue
  has_files=1
  
  # Count the number of audio streams in the current file
  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$f" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  # Photon 51TC-408D video and audio baseline pipeline
  # Tube: 51LK2B 51cm 4:3 CRT. Decoder: MCR-402 / PAL-SECAM modular unit.
  filter_complex="[0:v]scale=768:576:force_original_aspect_ratio=decrease, \
        pad=768:576:(ow-iw)/2:(oh-ih)/2, \
        noise=alls=11:allf=t+u, \
        chromashift=cbh=3:crh=-2:cbv=1:crv=-1, \
        boxblur=1.1:1:0:0, \
        eq=saturation=0.91:brightness=-0.005:contrast=1.07:gamma=1.04, \
        drawgrid=w=768:h=2:c=black@0.14:t=1, \
        curves=m='0/0.05 0.5/0.48 1/0.94', \
        vignette=angle=PI/6.6 [v_crt]; \
    anoisesrc=color=pink:amplitude=0.0028:sample_rate=22050,highpass=f=145,lowpass=f=9200[a_bg_raw]"
  
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

  # Photon 51TC internal sound path: K174UN7 amplifier driving 3GD-38 / 2GD-40 dynamic speaker
  i=0
  while [ "$i" -lt "$audio_count" ]; do
    filter_complex="${filter_complex}; [0:a:$i]aformat=channel_layouts=mono,highpass=f=145,lowpass=f=9200,equalizer=f=2700:width_type=h:width=200:g=3.8,equalizer=f=390:width_type=h:width=100:g=2[a_mono$i]; [a_mono$i][bg$i]amix=inputs=2:weights=1 0.13[a_out$i]"
    maps="$maps -map [a_out$i]"
    audio_settings="$audio_settings -c:a:$i aac -ar:a:$i 22050 -ac:a:$i 1"
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