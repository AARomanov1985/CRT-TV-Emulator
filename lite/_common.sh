# Lite chassis core. Sourced by lite/<chassis>.sh wrappers, which set CHASSIS.
# Sources chassis/<name>/filter.sh itself, so tone stays single-sourced.
# Every set is treated as fed by a moderate broadcast: the TV signal bed
# (BG_*/SIG_CRUSH) overrides the chassis fallback, same precedence as
# lib/engine.sh. Mono sets get the moderate BW bed, color sets the color one.
# Video is tone-only (LUMA?/EQ/TINT/CURVES).

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
. "$ROOT/chassis/${CHASSIS}/filter.sh"
if [ -n "${CH_LUMA:-}" ]; then
  . "$ROOT/tv/moderate_signal_bw/filter.sh"
else
  . "$ROOT/tv/moderate_signal_color/filter.sh"
fi

SUFFIX="_lite_${CHASSIS}_640"

lite_transcode() {
  input="$1"
  output="$2"

  VF="scale=640:-2"
  [ -n "${CH_LUMA:-}" ] && VF="${VF},${CH_LUMA}"
  VF="${VF},${CH_EQ}"
  [ -n "${CH_TINT:-}" ] && VF="${VF},${CH_TINT}"
  VF="${VF},${CH_CURVES}"

  audio_count=$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$input" | wc -l)
  audio_count=$(echo "$audio_count" | tr -d ' ')
  duration=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$input" | head -1)
  duration=${duration:-3600}

  filter_complex="[0:v]${VF} [v]"
  maps="-map [v]"
  audio_settings=""

  if [ "$audio_count" -gt 0 ]; then
    filter_complex="${filter_complex}; anoisesrc=color=${BG_COLOR:-pink}:sample_rate=${AUDIO_RATE}:duration=${duration},highpass=f=${BG_HIGHPASS},lowpass=f=${BG_LOWPASS} [a_bg]"
    if [ "$audio_count" -gt 1 ]; then
      bg_split="; [a_bg]asplit=outputs=$audio_count"
      i=0
      while [ "$i" -lt "$audio_count" ]; do
        bg_split="${bg_split}[bg$i]"
        i=$((i + 1))
      done
      filter_complex="${filter_complex}${bg_split}"
    else
      filter_complex="${filter_complex}; [a_bg]anull [bg0]"
    fi

    i=0
    while [ "$i" -lt "$audio_count" ]; do
      mono_chain="[0:a:$i]aformat=channel_layouts=mono,highpass=f=${BG_HIGHPASS},lowpass=f=${BG_LOWPASS},${AUDIO_EQ} [a_mono$i]"
      mix_chain="[a_mono$i][bg$i]amix=inputs=2:weights=1 ${BG_WEIGHT}"
      [ -n "${SIG_CRUSH:-}" ] && mix_chain="${mix_chain},${SIG_CRUSH}"
      mix_chain="${mix_chain},atrim=duration=${duration} [a_out$i]"
      filter_complex="${filter_complex}; ${mono_chain}; ${mix_chain}"
      maps="$maps -map [a_out$i]"
      audio_settings="$audio_settings -c:a:$i aac -ar:a:$i ${AUDIO_RATE} -ac:a:$i 1"
      i=$((i + 1))
    done
  fi

  eval "ffmpeg -nostdin -y -i \"$input\" -filter_complex \"$filter_complex\" \
    $maps \
    -map 0:s? \
    -pix_fmt yuv420p \
    -c:v libx264 \
    -b:v 1024k \
    $audio_settings \
    -c:s copy \
    -shortest \
    \"$output\""
}

lite_main() {
  if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_file_or_dir> [output_file_or_dir]" >&2
    exit 1
  fi
  INPUT="$1"
  [ -e "$INPUT" ] || { echo "Critical error: path not found: $INPUT" >&2; exit 1; }
  command -v ffmpeg >/dev/null || { echo "Critical error: ffmpeg not found" >&2; exit 1; }

  if [ -d "$INPUT" ]; then
    OUT_DIR="${2:-$INPUT/out}"
    mkdir -p "$OUT_DIR"
    found=0
    for f in "$INPUT"/*.avi "$INPUT"/*.mp4 "$INPUT"/*.mkv "$INPUT"/*.webm "$INPUT"/*.mov; do
      [ -f "$f" ] || continue
      base="$(basename "$f")"
      lite_transcode "$f" "$OUT_DIR/${base%.*}${SUFFIX}.mkv"
      found=1
    done
    [ "$found" -eq 1 ] || { echo "Critical error: no video files found in $INPUT" >&2; exit 1; }
    echo "Done. Output in $OUT_DIR"
  else
    if [ $# -ge 2 ]; then OUTPUT="$2"; else
      dir="$(dirname "$INPUT")"; base="$(basename "$INPUT")"
      OUTPUT="$dir/out/${base%.*}${SUFFIX}.mkv"
    fi
    if [ -d "$OUTPUT" ]; then
      base="$(basename "$INPUT")"
      OUTPUT="$OUTPUT/${base%.*}${SUFFIX}.mkv"
    fi
    lite_transcode "$INPUT" "$OUTPUT"
    echo "Done. Output: $OUTPUT"
  fi
}
