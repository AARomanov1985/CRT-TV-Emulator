#!/bin/bash
# Color + slight blue: cold color set / weak red gun / 9300K white point.
# libx264, 1024k, 640px wide, slightly desaturated, 90% brightness, blue push.
# Keeps ALL audio tracks and ALL subtitles.
# Usage: ./convert_color_blue.sh <input> [output]
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <input_file_or_dir> [output_file_or_dir]" >&2
  exit 1
fi

INPUT="$1"
[ -e "$INPUT" ] || { echo "Critical error: path not found: $INPUT" >&2; exit 1; }

command -v ffmpeg >/dev/null || { echo "Critical error: ffmpeg not found" >&2; exit 1; }

VF="scale=640:-2,hue=s=0.8,eq=contrast=1.2:brightness=-0.1,colorbalance=bs=0.2:bm=0.1:bh=0.05"

transcode() {
  in="$1"
  out="$2"
  mkdir -p "$(dirname "$out")"
  ffmpeg -y -i "$in" \
    -map 0 \
    -vf "$VF" \
    -pix_fmt yuv420p \
    -c:v libx264 -b:v 1024k \
    -c:a aac \
    -c:s copy \
    -shortest \
    "$out"
}

if [ -d "$INPUT" ]; then
  OUT_DIR="${2:-$INPUT/out}"
  mkdir -p "$OUT_DIR"
  found=0
  for f in "$INPUT"/*.avi "$INPUT"/*.mp4 "$INPUT"/*.mkv "$INPUT"/*.webm "$INPUT"/*.mov; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    transcode "$f" "$OUT_DIR/${base%.*}_colorblue640.mkv"
    found=1
  done
  [ "$found" -eq 1 ] || { echo "Critical error: no video files found in $INPUT" >&2; exit 1; }
  echo "Done. Output in $OUT_DIR"
else
  if [ $# -ge 2 ]; then
    OUTPUT="$2"
  else
    dir="$(dirname "$INPUT")"
    base="$(basename "$INPUT")"
    OUTPUT="$dir/out/${base%.*}_colorblue640.mkv"
  fi
  if [ -d "$OUTPUT" ]; then
    base="$(basename "$INPUT")"
    OUTPUT="$OUTPUT/${base%.*}_colorblue640.mkv"
  fi
  transcode "$INPUT" "$OUTPUT"
  echo "Done. Output: $OUTPUT"
fi
