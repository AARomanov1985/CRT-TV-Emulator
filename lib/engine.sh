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
#   gorizont_736      61LK3C         625/50     576 (2nd class hybrid, 66kg)
#   electron_51tc433d 51LK2B         625/50     576
#   photon_51tc408d   51LK2B         625/50     576
#   funai_tv2000mk7   20in color     625/50     576 (525 NTSC capable)
#   goldstar_ck20e40  20in color     625/50     576 (525 NTSC capable)
#   junost_402b       31LK4B 31cm mono  625/50  576 (no chroma decode)
#   junost_406        31LK4B 31cm mono  625/50  576 (no chroma decode, portable)
#   sony_kv_m2180     21in aperture grille  625/50  576 (Trinitron M)
#   samsung_cs2173    21in shadow mask      625/50  576 (KS1A one-chip)
#   philips_gr1ax     21in shadow mask      625/50  576 (GR1AX/G90)
#   daewoo_dtc20u1    20in shadow mask      625/50  576 (CP-002 import budget)
#
# The only chassis that behaves differently is junost_402b: its 31LK4B tube
# has no color decoder. Setting CH_LUMA drops the SIG_CHROMA stage entirely
# and folds the frame to luma-only, so no chroma work is ever faked for it.

# Fuse a cassette model (vhs/<model>) + condition deltas (vhs_cond/<cond>)
# into the final SIG_* variables that process_file() consumes.
#
# The model sets TAPE_* hardware params; the condition sets DEG_* deltas on
# top. The result is the model's character, degraded - never overwritten.
# DEG_WAND (if set) is a geq luminance modifier appended to SIG_PRE.

build_vhs_sig() {
  smp="${DEG_SMP:-$TAPE_SMP}"
  blurh=$(( TAPE_BLURH + ${DEG_BLURH:-0} ))
  lumblur=$(( TAPE_LUMAR + ${DEG_LUMAR:-0} ))

  SIG_PRE="scale=$smp,scale=768:576,boxblur=chroma_radius=$blurh:luma_radius=$lumblur"

  if [ -n "$DEG_LUM" ]; then
    SIG_PRE="${SIG_PRE},geq=lum='${DEG_LUM}':cb='cb(X,Y)':cr='cr(X,Y)'"
  elif [ -n "$DEG_WAND" ]; then
    SIG_PRE="${SIG_PRE},geq=lum='lum(X,Y)*(${DEG_WAND})':cb='cb(X,Y)':cr='cr(X,Y)'"
  fi

  SIG_NOISE="noise=alls=$(( TAPE_NOISE + ${DEG_NOISE:-0} )):allf=t+u"

  SIG_CHROMA="chromashift=cbh=$(( TAPE_CH_CBH + ${DEG_CBH:-0} )):crh=$(( TAPE_CH_CRH + ${DEG_CRH:-0} )):cbv=$(( TAPE_CH_CBV + ${DEG_CBV:-0} )):crv=$(( TAPE_CH_CRV + ${DEG_CRV:-0} ))"

  BG_COLOR=white
  BG_AMPLITUDE="${DEG_AMP:-$TAPE_AMP}"
  BG_HIGHPASS="${DEG_HIGHPASS:-$TAPE_HIGHPASS}"
  BG_LOWPASS="${DEG_LOWPASS:-$TAPE_LOWPASS}"
}

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