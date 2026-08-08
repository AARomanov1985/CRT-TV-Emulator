#!/bin/sh

process_file() {
  input="$1"
  output="$2"

  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$input" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  video_chain="[0:v]scale=768:576:force_original_aspect_ratio=decrease, \
      pad=768:576:(ow-iw)/2:(oh-ih)/2"
  [ -n "${SIG_PRE}" ] && video_chain="${video_chain}, ${SIG_PRE}"
  video_chain="${video_chain}, ${SIG_NOISE}, ${SIG_CHROMA}, \
      ${CH_BLUR}, ${CH_EQ}, ${CH_GRID}, ${CH_CURVES}, ${CH_VIGNETTE} [v_crt]"

  filter_complex="$video_chain"

  maps="-map [v_crt]"
  audio_settings=""

  if [ "$audio_count" -gt 0 ]; then
    filter_complex="${filter_complex}; \
      anoisesrc=color=${BG_COLOR}:amplitude=${BG_AMPLITUDE}:sample_rate=${AUDIO_RATE},highpass=f=${BG_HIGHPASS},lowpass=f=${BG_LOWPASS}[a_bg_raw]"
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

    i=0
    while [ "$i" -lt "$audio_count" ]; do
      filter_complex="${filter_complex}; [0:a:$i]aformat=channel_layouts=mono,highpass=f=${AUDIO_HIGHPASS},lowpass=f=${AUDIO_LOWPASS},${AUDIO_EQ}[a_mono$i]; [a_mono$i][bg$i]amix=inputs=2:weights=1 ${BG_WEIGHT}[a_out$i]"
      maps="$maps -map [a_out$i]"
      audio_settings="$audio_settings -c:a:$i aac -ar:a:$i ${AUDIO_RATE} -ac:a:$i 1"
      i=$((i + 1))
    done
  fi

  eval "ffmpeg -y -i \"$input\" -filter_complex \"$filter_complex\" \
    $maps \
    -map 0:s? \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -b:v 2500k \
    $audio_settings \
    -c:s copy \
    -shortest \
    \"$output\""
}