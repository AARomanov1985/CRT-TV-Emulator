#!/bin/sh

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
. "$ROOT/lib/engine.sh"

choose_from() {
  base_dir="$1"
  prompt="$2"
  entries=""
  for d in "$base_dir"/*/; do
    [ -d "$d" ] || continue
    entries="${entries}$(basename "$d")
"
  done
  count=0
  [ -n "$entries" ] && count=$(printf '%s' "$entries" | grep -c .)
  if [ "$count" -eq 0 ]; then
    echo "Critical error: no filters found in $base_dir" >&2
    exit 1
  fi
  while :; do
    printf '%s\n' "$prompt" >&2
    printf '%s' "$entries" | grep . | awk '{ printf "  %d) %s\n", NR, $0 }' >&2
    printf 'Your choice: ' >&2
    read choice || exit 1
    printf '%s' "$choice" | grep -Eq '^[0-9]+$' || continue
    [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "$count" ] 2>/dev/null || continue
    printf '%s' "$entries" | grep . | sed -n "${choice}p"
    return
  done
}

echo "=== CRT Signal Emulator ==="

echo ""
echo "Choose signal source:"
while :; do
  echo "  1) TV broadcast signal"
  echo "  2) VHS cassette"
  printf 'Your choice: '
  read src_choice || exit 1
  case "$src_choice" in
    1) source_dir="$ROOT/tv"; break ;;
    2) source_dir="$ROOT/vhs"; break ;;
  esac
done

source_name="$(choose_from "$source_dir" "Choose signal:")"
echo "Selected source: $source_name"

chassis_name="$(choose_from "$ROOT/chassis" "Choose TV chassis:")"
echo "Selected chassis: $chassis_name"

. "$source_dir/$source_name/filter.sh"
. "$ROOT/chassis/$chassis_name/filter.sh"

input_path=""
if [ $# -ge 1 ]; then
  input_path="$1"
  [ -e "$input_path" ] || { echo "Critical error: path not found: $input_path" >&2; exit 1; }
else
  while :; do
    printf 'Path to the video file or directory to process: '
    read input_path || exit 1
    [ -n "$input_path" ] && [ -e "$input_path" ] && break
    echo "Critical error: path not found." >&2
  done
fi

if [ -d "$input_path" ]; then
  out_dir="$input_path/out"
else
  out_dir="$(dirname "$input_path")/out"
fi
mkdir -p "$out_dir"

has_files=0
if [ -d "$input_path" ]; then
  for f in "$input_path"/*.avi "$input_path"/*.mp4 "$input_path"/*.mkv "$input_path"/*.webm; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    process_file "$f" "$out_dir/${base%.*}_${source_name}_${chassis_name}.mkv"
    has_files=1
  done
else
  base="$(basename "$input_path")"
  process_file "$input_path" "$out_dir/${base%.*}_${source_name}_${chassis_name}.mkv"
  has_files=1
fi

[ "$has_files" -eq 1 ] && echo "Done. Output in $out_dir"
[ "$has_files" -eq 0 ] && echo "Critical error: no video files found in $input_path." >&2 && exit 1