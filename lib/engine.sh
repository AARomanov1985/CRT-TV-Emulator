#!/bin/sh

# Raster invariant: every chassis is a 625-line/50Hz set (SECAM/PAL D/K, or a
# multisystem set used in 625 mode), so the active raster is always 576 rows.
# 768 is the BT.601 square-pixel width for a 4:3 625-line picture. This canvas
# is NOT a per-tube resolution claim: the horizontal detail a 51cm shadow mask
# resolves (~450-600 TVL) is below 768, and that shortfall is modeled by the
# CH_BLUR/CH_GRID/CH_CURVES stages, not by changing the raster size.
#
#   chassis       tube               line std   raster rows
#   rubin_51tc    51LK2B/51LK1B      625/50     576
#   gorizont_51tc412  51LK2B         625/50     576
#   electron_51tc433d 51LK2B         625/50     576
#   photon_51tc408d   51LK2B         625/50     576
#   funai_tv2000mk7   20in color     625/50     576 (525 NTSC capable)
#   goldstar_ck20e40  20in color     625/50     576 (525 NTSC capable)
#   junost_402b       31LK4B 31cm mono  625/50  576 (no chroma decode)
#
# The only chassis that behaves differently is junost_402b: its 31LK4B tube
# has no color decoder. Setting CH_LUMA drops the SIG_CHROMA stage entirely
# and folds the frame to luma-only, so no chroma work is ever faked for it.

process_file() {
  input="$1"
  output="$2"

  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$input" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  video_chain="[0:v]scale=768:576:force_original_aspect_ratio=decrease, \
      pad=768:576:(ow-iw)/2:(oh-ih)/2"
  [ -n "${SIG_PRE}" ] && video_chain="${video_chain}, ${SIG_PRE}"
  video_chain="${video_chain}, ${SIG_NOISE}"
  if [ -n "${CH_LUMA}" ]; then
    video_chain="${video_chain}, ${CH_LUMA}"
  else
    video_chain="${video_chain}, ${SIG_CHROMA}"
  fi
  video_chain="${video_chain}, ${CH_BLUR}, ${CH_EQ}, ${CH_GRID}, ${CH_CURVES}, ${CH_VIGNETTE} [v_crt]"

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