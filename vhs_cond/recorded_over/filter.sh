# Recorded-over condition - degradation deltas on top of the model.
#
# Generations of overdubs and copies. The signature is the cross-ghost echo:
# a faint horizontal duplicate of the picture offset 6 px - the previous
# recording bleeding through a partially-erased tape - plus a heavier clamp,
# higher noise, and chroma under-crosstalk drift.
#
# DEG_WAND for this condition is an additive ghost: luma picks up 12% of the
# pixel 6 columns to the left, forming the double-image echo.

DEG_SMP="384:288"
DEG_BLURH=3
DEG_NOISE=14
DEG_CBH=1
DEG_CRH=-2
DEG_CBV=2
DEG_CRV=-1
DEG_WAND="1+0.12*(lum(X-6,Y)/max(lum(X,Y),0.001)-1)"
DEG_AMP=0.0038
DEG_LOWPASS=5800