#!/bin/sh
# Regression: the generic_composite PL_BLOCK must NOT produce a whole-frame
# flicker on a 60-frame period (N%60==0 blackout of ~30% of pixels).
#
# Old bad expression:
#   if(lt(mod(N,60),1)*lt(mod(X*Y*3973,101),30),0,lum(X,Y))
# fires every 60th frame (1.2s at 50fps), dropping adjacent-pair SSIM to ~0.57.
#
# A healthy composite player keeps all adjacent-frame SSIM > 0.9; a true
# decoder error is rare and localized, not a full-frame burst.
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
echo "=== generic_composite flicker regression ==="
echo "Building 50fps source..."
ffmpeg -loglevel error -f lavfi -i testsrc2=duration=4:size=320x240:rate=50 \
  -c:v libx264 -pix_fmt yuv420p /tmp/flick_src.mp4 -y

printf '3\n1\n1\n13\n/tmp/flick_src.mp4\n' | "$ROOT/convert.sh" >/dev/null 2>&1
render=/tmp/out/flick_src_pressed_generic_composite_sony_kv_m2180.mkv
[ -f "$render" ] || { echo "FAIL: render missing"; exit 1; }

fails=0
check() {
  pair="$1"
  set -- $pair
  all=$(ffmpeg -i "$render" -i "$render" \
    -filter_complex "[0:v]select='eq(n,$1)'[a];[1:v]select='eq(n,$2)'[b];[a][b]ssim" \
    -f null - 2>&1 | grep -oE "All:[0-9.]+" | tail -1 | cut -d: -f2)
  ok=$(awk -v a="$all" 'BEGIN{print (a > 0.90) ? "ok" : "bad"}')
  if [ "$ok" = "ok" ]; then
    echo "ok: frames $1-$2 All=$all"
  else
    echo "FAIL: frames $1-$2 All=$all (flicker)"
    fails=$((fails + 1))
  fi
}

echo "Checking frame boundaries around the old 60-period defect..."
check "59 60"
check "60 61"
check "119 120"
check "120 121"
check "179 180"
check "180 181"

echo "Checking a normal pair (must be well above threshold)..."
check "30 31"

if [ "$fails" -eq 0 ]; then
  echo "PASS: no flicker"
else
  echo "FAIL: $fails boundary pairs flickered"
  exit 1
fi