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
#   rassvet_307       40LK6B 40cm mono    625/50  576 (ULPT-40-III-1 hybrid, mono)
#   sony_kv_m2180     21in aperture grille  625/50  576 (Trinitron M)
#   samsung_cs2173    21in shadow mask      625/50  576 (KS1A one-chip)
#   philips_gr1ax     21in shadow mask      625/50  576 (GR1AX/G90)
#   daewoo_dtc20u1    20in shadow mask      625/50  576 (CP-002 import budget)
#
# The only chassis that behave differently are the monochrome sets
# (junost_402b, junost_406, rassvet_307): their tubes have no color decoder.
# Setting CH_LUMA drops the SIG_CHROMA stage entirely and folds the frame to
# luma-only, so no chroma work is ever faked for them.

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
  if [ -n "${DECK_WAND:-}" ]; then
    SIG_PRE="${SIG_PRE},geq=lum='lum(X,Y)*(${DECK_WAND})':cb='cb(X,Y)':cr='cr(X,Y)'"
  fi
  if [ -n "${DECK_DTC:-}" ]; then
    SIG_PRE="${SIG_PRE},geq=lum='${DECK_DTC}':cb='cb(X,Y)':cr='cr(X,Y)'"
  fi
  if [ -n "${DECK_DENOISE:-}" ]; then
    SIG_PRE="${SIG_PRE},${DECK_DENOISE}"
  fi

  SIG_NOISE="noise=alls=$(( TAPE_NOISE + ${DEG_NOISE:-0} + ${DECK_NOISE:-0} )):allf=t+u"

  SIG_CHROMA="chromashift=cbh=$(( TAPE_CH_CBH + ${DEG_CBH:-0} )):crh=$(( TAPE_CH_CRH + ${DEG_CRH:-0} )):cbv=$(( TAPE_CH_CBV + ${DEG_CBV:-0} )):crv=$(( TAPE_CH_CRV + ${DEG_CRV:-0} ))"

  BG_COLOR=white
  BG_WEIGHT="${DECK_AMP:-${DEG_AMP:-$TAPE_AMP}}"
  BG_HIGHPASS="${DECK_HIGHPASS:-${DEG_HIGHPASS:-$TAPE_HIGHPASS}}"
  BG_LOWPASS="${DECK_LOWPASS:-${DEG_LOWPASS:-$TAPE_LOWPASS}}"
}

# Fuse a DVD disc (dvd/<disc>) + player (dvd_player/<player>, which also
# carries the output connection character) into the final SIG_* variables.
# DISC_* is the disc baseline (near-transparent, digital), PL_* the decoder
# character, CONN_* the output path (composite smears, component stays clean).

build_dvd_sig() {
  sig_pre=""

  [ -n "${PL_RING:-}" ] && sig_pre="${sig_pre:+${sig_pre},}${PL_RING}"

  [ -n "${DISC_BLUR:-}" ] && sig_pre="${sig_pre:+${sig_pre},}boxblur=${DISC_BLUR}"

  [ -n "${PL_BAND:-}" ] && sig_pre="${sig_pre:+${sig_pre},}${PL_BAND}"

  if [ -n "${PL_BLOCK:-}" ]; then
    sig_pre="${sig_pre:+${sig_pre},}geq=lum='${PL_BLOCK}':cb='cb(X,Y)':cr='cr(X,Y)'"
  fi

  if [ -n "${CONN_BLUR:-}" ]; then
    sig_pre="${sig_pre:+${sig_pre},}boxblur=${CONN_BLUR}"
  fi

  SIG_PRE="$sig_pre"
  SIG_NOISE="noise=alls=$(( ${DISC_NOISE:-0} + ${PL_NOISE:-0} + ${CONN_NOISE:-0} )):allf=t+u"

  SIG_CHROMA="chromashift=cbh=0:crh=0:cbv=0:crv=0"
  if [ -n "${CONN_CHROMA:-}" ]; then
    SIG_CHROMA="$CONN_CHROMA"
  fi

  BG_COLOR="pink"
  BG_WEIGHT="${CONN_AMP:-0.0002}"
  BG_HIGHPASS="${CONN_HIGHPASS:-120}"
  BG_LOWPASS="${CONN_LOWPASS:-14000}"
}

process_file() {
  input="$1"
  output="$2"

  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$input" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')

  # Bounding the audio bed: to find the duration of the source video
  duration=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$input" | head -1)

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
    # Audio bed: the noise source runs at full scale; amix weights=1 ${BG_WEIGHT}
    # with default normalize makes BG_WEIGHT the exact output noise/signal
    # amplitude ratio (0.1 = -20 dB, 1.0 = equal, 2.0 = noise dominates).
    # It is set by the signal source (tv/<variant>, vhs/tape+condition+deck,
    # dvd/connection); the chassis value is only a fallback.
    # BG_HIGHPASS/BG_LOWPASS bound the WHOLE audio path - voice and noise
    # alike, since both share the set's amplifier/speaker. The chassis
    # AUDIO_HIGHPASS/AUDIO_LOWPASS only serve as fallback.
    filter_complex="${filter_complex}; \
      anoisesrc=color=${BG_COLOR}:sample_rate=${AUDIO_RATE}:duration=${duration},highpass=f=${BG_HIGHPASS:-${AUDIO_HIGHPASS}},lowpass=f=${BG_LOWPASS:-${AUDIO_LOWPASS}}[a_bg_raw]"
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
      # SIG_CRUSH (optional, set by the signal source) models AGC overload on
      # weak reception: compression plus hard clipping after voice+noise are
      # mixed, so the whole path distorts the way a real demodulator does.
      mix_chain="[a_mono$i][bg$i]amix=inputs=2:weights=1 ${BG_WEIGHT}"
      [ -n "${SIG_CRUSH:-}" ] && mix_chain="${mix_chain},${SIG_CRUSH}"
      filter_complex="${filter_complex}; ${mix_chain},atrim=duration=${duration}[a_out$i]"
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
    -b:v 2000k \
    $audio_settings \
    -c:s copy \
    -shortest \
    \"$output\""
}