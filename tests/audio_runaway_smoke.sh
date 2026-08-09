#!/bin/sh
# Regression: the audio bed must not run unbounded. Previously the engine fed
# anoisesrc (no duration) into amix (duration=longest), producing INFINITE
# audio; -shortest on FFmpeg 8.x never terminates lavfi-generated streams, so
# a 40-min encode grew past 17GB of audio. With the fix the encode must:
#   1) finish within the hard timeout (no infinite mux loop)
#   2) audio stream duration bounded near the source duration
#   3) muxed audio bytes sane (< 20MB for a 60s 2-track mono encode)
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/engine.sh"
. "$ROOT/tv/strong_signal_color/filter.sh"
. "$ROOT/chassis/goldstar_ck20e40/filter.sh"

SRC=/tmp/regress_audio.mkv
OUT=/tmp/regress_audio_out.mkv
TIMEOUT_S=90

# Clean up stale artifacts from a previous run
rm -f "$SRC" "$OUT"

# Build: 60s, 2 audio tracks (mono, AC3 like real rips), small video
ffmpeg -v error -y \
  -f lavfi -i testsrc=duration=60:size=352x176:rate=25 \
  -f lavfi -i "sine=frequency=330:duration=60:sample_rate=48000" \
  -f lavfi -i "sine=frequency=660:duration=60:sample_rate=48000" \
  -map 0:v -map 1:a -map 2:a -c:v mpeg4 -q:v 10 -c:a ac3 -ac 2 "$SRC" || exit 2

t0=$(date +%s)
process_file "$SRC" "$OUT" > /tmp/regress_audio.log 2>&1
rc=$?
t1=$(date +%s)
elapsed=$((t1 - t0))

if [ $rc -ne 0 ]; then
  echo "FAIL: encode failed (rc=$rc)"
  tail -5 /tmp/regress_audio.log
  exit 1
fi

if [ "$elapsed" -ge "$TIMEOUT_S" ]; then
  echo "FAIL: encode did not finish within ${TIMEOUT_S}s (audio bed unbounded)"
  exit 1
fi

# Grab the muxer's audio+video byte tallies
audioki=$(grep -oE 'audio:[0-9]+KiB' /tmp/regress_audio.log | tail -1 | grep -oE '[0-9]+')
videoki=$(grep -oE 'video:[0-9]+KiB' /tmp/regress_audio.log | tail -1 | grep -oE '[0-9]+')

if [ -z "$audioki" ] || [ -z "$videoki" ]; then
  echo "FAIL: could not extract mux byte stats from log"
  exit 1
fi

# 60s at AAC 69kbps mono x2 ~= 1.1MB. Allow generous headroom, but 20MB cap
# catches the old runaway (which produced ~1000x that).
if [ "$audioki" -gt 20480 ]; then
  echo "FAIL: audio muxed ${audioki}KiB (>20MB cap) — unbounded audio bed"
  exit 1
fi

# Audio must be roughly as long as the video (within 3s)
src_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$SRC")
a_dur=$(ffprobe -v error -select_streams a:0 -show_entries stream=duration -of csv=p=0 "$OUT")
# stream duration can be "N/A" on mkv; fall back to format duration
[ "$a_dur" = "N/A" ] && a_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUT")

echo "src_dur=$src_dur out_dur=$a_dur audio=${audioki}KiB video=${videoki}KiB elapsed=${elapsed}s"
awk -v s="$src_dur" -v a="$a_dur" 'BEGIN {
  if (a > s + 3 || a < s - 3) { print "FAIL: audio dur " a " outside source " s " ±3s"; exit 1 }
  print "PASS: audio duration bounded"; exit 0
}'

rm -f "$SRC" "$OUT"