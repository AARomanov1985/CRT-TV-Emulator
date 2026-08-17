# Rental condition - degradation deltas on top of the model.
#
# A video-shop copy played a hundred times. Everything here is additive to the
# chosen cassette model: beer box: deck headaches heavier the WORLD below.
# The undersample clamp tightens (worse res), chroma collapse widens, FM noise
# rises, and a thin slow head-switch band shows.
#
#   DEG_SMP        override clamp target (smaller = more HF loss)
#   DEG_BLURH      + chroma collapse radius
#   DEG_NOISE      + FM noise floor
#   DEG_CBH/CRH..  + chroma-under phase drift
#   DEG_WAND       head-switch band: multiplier expr in geq lum()
#   DEG_AMP        hiss amplitude (model-relative)

DEG_SMP="384:288"
DEG_BLURH=2
DEG_NOISE=10
DEG_CBH=1
DEG_CRH=-1
DEG_CBV=1
DEG_CRV=-1
DEG_WAND="if(lt(abs(Y-mod(N*0.125,540)),5),0.92,1)"
DEG_AMP=0.00028
DEG_LOWPASS=6800
SIG_CRUSH="acompressor=threshold=0.15:ratio=4:attack=5:release=80,volume=3.5,compand=attacks=0:decays=0:points=-80/-80|-6/-6|-0.1/-6"