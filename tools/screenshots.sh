#!/bin/sh
# Regenerate the screenshot gallery (chassis/ and tv/) from a source clip.
#
# Usage: ./tools/screenshots.sh <source_video> [timestamp]
#
# Every screenshot is one frame of the source pushed through the same filter
# chain lib/engine.sh builds for a full transcode, so a picture in the README
# is exactly what convert.sh would output for that signal + chassis.
#
# The frame is pulled with an INPUT seek (-ss before -i). That matters: with
# an input seek ffmpeg decodes only from the seek point, so the noise filter's
# frame counter restarts at the requested timestamp. An output seek keeps the
# counter running from the start of the file and yields a different noise
# field. The gallery was built with the input-seek form; keep it that way or
# every image changes.
#
# Each render runs in its own subshell. chassis/<set>/filter.sh are plain
# variable assignments, and CH_LUMA (set only by the monochrome sets) would
# otherwise survive into the next set and fold a colour tube to grey.
#
# Options:
#   -s, --signal <name>   only render this signal variant
#   -c, --chassis <name>  only render this chassis
#   -t, --time <sec>      timestamp of the frame to grab (default 3)
#   -h, --help            this text

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/engine.sh"

SIGNAL_FILTER=""
CHASSIS_FILTER=""
TIMESTAMP="3"
SOURCE=""

usage() {
  sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--signal)  SIGNAL_FILTER="${2:-}"; shift 2 ;;
    -c|--chassis) CHASSIS_FILTER="${2:-}"; shift 2 ;;
    -t|--time)    TIMESTAMP="${2:-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    -*)           echo "Critical error: unknown option: $1" >&2; exit 1 ;;
    *)            SOURCE="$1"; shift ;;
  esac
done

if [ -z "$SOURCE" ]; then
  echo "Critical error: no source video given." >&2
  usage >&2
  exit 1
fi
if [ ! -e "$SOURCE" ]; then
  echo "Critical error: path not found: $SOURCE" >&2
  exit 1
fi
command -v ffmpeg >/dev/null || { echo "Critical error: ffmpeg not found" >&2; exit 1; }

# Render one signal + chassis pair to a PNG.
#
# usage: render <signal> <chassis> <outfile>
render() {
  r_signal="$1"
  r_chassis="$2"
  r_outfile="$3"

  r_signal_dir="$ROOT/tv/$r_signal"
  r_chassis_dir="$ROOT/chassis/$r_chassis"
  if [ ! -d "$r_signal_dir" ]; then
    echo "Critical error: unknown signal: $r_signal" >&2
    exit 1
  fi
  if [ ! -d "$r_chassis_dir" ]; then
    echo "Critical error: unknown chassis: $r_chassis" >&2
    exit 1
  fi

  # Subshell: the sourced filter.sh files must not leak into each other.
  (
    # shellcheck disable=SC1090
    . "$r_chassis_dir/filter.sh"
    # shellcheck disable=SC1090
    . "$r_signal_dir/filter.sh"

    ffmpeg -nostdin -y -ss "$TIMESTAMP" -i "$SOURCE" \
      -vf "$(build_video_chain)" -frames:v 1 -update 1 "$r_outfile"
  )
}

# The clear reference: the source frame on the 768x576 canvas, no signal and
# no chassis applied.
#
# usage: render_clear <outfile>
render_clear() {
  ffmpeg -nostdin -y -ss "$TIMESTAMP" -i "$SOURCE" \
    -vf "scale=768:576:force_original_aspect_ratio=decrease,pad=768:576:(ow-iw)/2:(oh-ih)/2" \
    -frames:v 1 -update 1 "$1"
}

count=0

# The chassis gallery: every picture each set ships, regenerated in place.
for chassis_dir in "$ROOT"/chassis/*/; do
  chassis_name=$(basename "$chassis_dir")
  [ -n "$CHASSIS_FILTER" ] && [ "$CHASSIS_FILTER" != "$chassis_name" ] && continue
  for outfile in "$chassis_dir"*.png; do
    [ -f "$outfile" ] || continue
    signal_name=$(basename "$outfile" .png)
    [ -n "$SIGNAL_FILTER" ] && [ "$SIGNAL_FILTER" != "$signal_name" ] && continue
    printf 'chassis  %-20s %-20s\n' "$chassis_name" "$signal_name"
    render "$signal_name" "$chassis_name" "$outfile"
    count=$((count + 1))
  done
done

# The tv/ gallery: one picture per signal variant showing how a chassis
# responds to that signal, plus the clear reference frame.
for signal_dir in "$ROOT"/tv/*/; do
  signal_name=$(basename "$signal_dir")
  [ -n "$SIGNAL_FILTER" ] && [ "$SIGNAL_FILTER" != "$signal_name" ] && continue

  for outfile in "$signal_dir"*.png; do
    [ -f "$outfile" ] || continue
    chassis_name=$(basename "$outfile" .png)
    if [ "$chassis_name" = "clear_signal" ]; then
      printf 'tv       %-20s %-20s\n' "$signal_name" "clear_signal"
      render_clear "$outfile"
    else
      [ -n "$CHASSIS_FILTER" ] && [ "$CHASSIS_FILTER" != "$chassis_name" ] && continue
      printf 'tv       %-20s %-20s\n' "$signal_name" "$chassis_name"
      render "$signal_name" "$chassis_name" "$outfile"
    fi
    count=$((count + 1))
  done
done

echo "Done. $count screenshots rendered."
