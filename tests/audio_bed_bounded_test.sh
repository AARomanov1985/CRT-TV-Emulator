#!/bin/sh
# Regression: the background-noise audio bed must be explicitly bounded to the
# source duration. Why: anoisesrc without duration is an INFINITE lavfi source;
# amix defaults to duration=longest, so the audio output never EOFs. On FFmpeg
# 8.x -shortest cannot terminate lavfi-generated streams, so a 40-min episode
# muxed ~268 hours of audio (30M packets/stream -> 17.9GB file). The engine
# must emit a duration-bounded anoisesrc and an atrim so the audio output is
# finite even if -shortest misbehaves.
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/engine.sh"
. "$ROOT/tv/strong_signal_color/filter.sh"
. "$ROOT/chassis/goldstar_ck20e40/filter.sh"

SRC=/tmp/regress_cmd.mp4
FFMPEG_CAPTURE=/tmp/regress_cmd.txt
export FFMPEG_CAPTURE
# fake_ffmpeg.sh must shadow /usr/bin/ffmpeg during process_file only.
# Build the source with the real binary first.

rm -f "$SRC" "$FFMPEG_CAPTURE"
/usr/bin/ffmpeg -v error -y \
  -f lavfi -i testsrc=duration=60:size=352x176:rate=25 \
  -f lavfi -i "sine=frequency=440:duration=60:sample_rate=48000" \
  -f lavfi -i "sine=frequency=880:duration=60:sample_rate=48000" \
  -map 0:v -map 1:a -map 2:a -c:v mpeg4 -q:v 10 -c:a ac3 -ac 2 "$SRC"

# PATH now has /tmp first so `ffmpeg` resolves to the capture stub
PATH="/tmp:$PATH"
process_file "$SRC" /tmp/regress_cmd_out.mkv
rc=$?

# process_file calls ffprobe normally (we didn't shadow it) and "ffmpeg" stub
# captured the graph. Inspect the captured filter_complex.
grep -oE '\-filter_complex [^ ]+' "$FFMPEG_CAPTURE" > /dev/null 2>&1

filter_line=$(grep -A1 -F -- '-filter_complex' "$FFMPEG_CAPTURE" | tail -1)
[ -n "$filter_line" ] || { echo "FAIL: no -filter_complex captured"; exit 1; }

echo "=== captured graph (audio portion) ==="
echo "$filter_line" | tr ';' '\n' | grep -E 'anoisesrc|amix|atrim|asplit'

fail=0

if ! echo "$filter_line" | grep -q 'anoisesrc=.*duration='; then
  echo "FAIL: anoisesrc has no duration= bound (infinite audio bed)"
  fail=1
fi

if ! echo "$filter_line" | grep -qE ',\s*atrim|atrim='; then
  echo "FAIL: no atrim bound on audio output"
  fail=1
fi

if ! echo "$filter_line" | grep -q 'duration=60'; then
  echo "FAIL: noise duration not matched to source duration"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS: audio bed bounded to source duration"
rm -f "$SRC" "$FFMPEG_CAPTURE"
exit "$fail"