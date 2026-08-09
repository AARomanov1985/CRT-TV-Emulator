#!/bin/sh
# Regression: budget_funai DECK_DTC must NOT create vertical column stripes.
#
# Old bad expression keyed the "dropout" on trunc(X/13) — a 13px column
# stepping that rendered as static vertical bands (mean |col-col+13| ~0.40
# on a flat gray frame). The dropout is a horizontal band, so it must be
# keyed on Y and leave columns untouched.
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
echo "=== budget_funai vertical-stripe regression ==="

# Isolate the DECK_DTC geq (as build_vhs_sig wraps it) against flat gray.
. "$ROOT/vhs_player/budget_funai/filter.sh"
[ -n "$DECK_DTC" ] || { echo "SKIP: no DECK_DTC set"; exit 0; }

ffmpeg -y -loglevel error -f lavfi -i "color=c=gray:size=768x576:rate=25:duration=1" \
  -frames:v 1 -c:v png /tmp/vline_flat.png
ffmpeg -y -loglevel error -i /tmp/vline_flat.png \
  -vf "geq=lum='${DECK_DTC}':cb='cb(X,Y)':cr='cr(X,Y)',scale=768:1:flags=area" \
  -pix_fmt gray -f rawvideo /tmp/vline_col.bin
[ "$(wc -c < /tmp/vline_col.bin)" = "768" ] || { echo "FAIL: column dump wrong size"; exit 1; }

perl -e 'open F,"<","/tmp/vline_col.bin" or die; read F,$b,768;
  $sum=0;$n=0; for($i=0;$i+13<768;$i++){ $sum+=abs(ord(substr($b,$i,1))-ord(substr($b,$i+13,1))); $n++ }
  printf "%.3f\n", $sum/$n' > /tmp/vline_score

score=$(cat /tmp/vline_score)
echo "mean |col-col+13| on flat gray: $score"
ok=$(awk -v s="$score" 'BEGIN{print (s < 0.10) ? "ok" : "bad"}')
if [ "$ok" = "ok" ]; then
  echo "PASS: no vertical striping"
else
  echo "FAIL: vertical striping detected"
  exit 1
fi