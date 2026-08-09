#!/bin/sh
# Minimal smoke: source the builders, assert the fused SIG_* vars.
ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/engine.sh"

TAPE_SMP="512:384"; TAPE_BLURH=6; TAPE_LUMAR=1; TAPE_NOISE=4
TAPE_CH_CBH=1; TAPE_CH_CRH=-1; TAPE_CH_CBV=0; TAPE_CH_CRV=0
TAPE_AMP=0.0009; TAPE_HIGHPASS=110; TAPE_LOWPASS=9500

DECK_WAND="if(lt(abs(Y-mod(N*0.5,540)),5),0.9,1)"
DECK_DTC="if(lt(mod(N,3),1),lum(X,Y)*0.5+30,lum(X,Y))"
DECK_NOISE=3
DECK_AMP=0.002
build_vhs_sig

echo "$SIG_PRE" | grep -q "geq" && echo "OK: vhs deck geq fused" || { echo "FAIL: deck geq missing"; exit 1; }
echo "$SIG_NOISE" | grep -q "alls=$((4+3))" && echo "OK: deck noise additive" || { echo "FAIL: deck noise"; exit 1; }

DISC_NOISE=1; PL_NOISE=2; CONN_NOISE=0
PL_RING="unsharp=5:5:0.5:5:5:0"
CONN_BLUR="1:1:0:0"
build_dvd_sig

echo "$SIG_NOISE" | grep -q "alls=$((1+2+0))" && echo "OK: dvd noise sum" || { echo "FAIL: dvd noise"; exit 1; }
echo "$SIG_PRE" | grep -q "unsharp" && echo "OK: dvd player stage" || { echo "FAIL: dvd player stage"; exit 1; }
echo "ALL SMOKE OK"
