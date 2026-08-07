#!/bin/sh
mkdir -p out

has_files=0

for f in *.avi *.mp4 *.mkv *.webm; do
  [ -f "$f" ] || continue
  has_files=1
  
  # Count the number of audio streams in the current file
  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$f" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  # GoldStar (LG) CK-20E40 video and audio baseline pipeline
  # Tube: 20-inch (51cm) 4:3 shadow-mask CRT. Decoder: Integrated TDA8362 PAL/SECAM/NTSC single-chip unit.
  filter_complex="[0:v]scale=768:576:force_original_aspect_ratio=decrease, \
        pad=768:576:(ow-iw)/2:(oh-ih)/2, \
        noise=alls=4:allf=t+u, \
        chromashift=cbh=1:crh=0:cbv=0:crv=0, \
        boxblur=0.4:1:0:0, \
        eq=saturation=1.05:brightness=0.000:contrast=1.10:gamma=0.98, \
        drawgrid=w=768:h=2:c=black@0.08:t=1, \
        curves=m='0/0.01 0.5/0.51 1/0.99', \
        vignette=angle=PI/7.8 [v_crt]; \
    anoisesrc=color=pink:amplitude=0.0008:sample_rate=32000,highpass=f=90,lowpass=f=13000[a_bg_raw]"
  
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

  # GoldStar MC-64A sound path: LA4225 / TDA2006 audio amplifier driving internal 8-ohm speaker
  i=0
  while [ "$i" -lt "$audio_count" ]; do
    filter_complex="${filter_complex}; [0:a:$i]aformat=channel_layouts=mono,highpass=f=90,lowpass=f=13000,equalizer=f=3100:width_type=h:width=250:g=2,equalizer=f=320:width_type=h:width=100:g=1[a_mono$i]; [a_mono$i][bg$i]amix=inputs=2:weights=1 0.04[a_out$i]"
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