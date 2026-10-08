#!/bin/bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <input_file_or_dir> [output_file_or_dir]" >&2
  exit 1
fi

INPUT="$1"
[ -e "$INPUT" ] || { echo "Critical error: path not found: $INPUT" >&2; exit 1; }

command -v ffmpeg >/dev/null || { echo "Critical error: ffmpeg not found" >&2; exit 1; }

VF="scale=640:-2,eq=contrast=1.1:brightness=-0.02:saturation=0.9,colorbalance=bs=0.08:bm=0.04:gs=0.05:gm=0.02"

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
    transcode "$f" "$OUT_DIR/${base%.*}_color640.mkv"
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
    OUTPUT="$dir/out/${base%.*}_color640.mkv"
  fi
  # Allow output to be an existing directory.
  if [ -d "$OUTPUT" ]; then
    base="$(basename "$INPUT")"
    OUTPUT="$OUTPUT/${base%.*}_color640.mkv"
  fi
  transcode "$INPUT" "$OUTPUT"
  echo "Done. Output: $OUTPUT"
fi
