# Recorded-over condition: the tape that has survived line after line of
# overdubs, generations, and copies.
#
# Real mechanics: every re-record writes a fresh FM luma signal over a less
# fully erased previous one; the old signal bleeds through as cross-ghosts,
# the sync/tracking quality drops generation to generation, and chroma
# under-crosstalk shifts. Modeled as a heavier resample clamp + wider wander
# + visible bleeding in the gray-mid tones.
#
# Overrides the model baseline with the "generations-deep" set.

SIG_PRE="scale=352:264,scale=768:576,boxblur=chroma_radius=9:luma_radius=1.8,geq=lum='clip(lum(X,Y)*0.85+lum(X-6,Y)*0.15,0,255)*if(lt(abs(Y-mod(N*0.1,540)),6),0.92,1)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=alls=18:allf=t+u"
SIG_CHROMA="chromashift=cbh=4:crh=-3:cbv=2:crv=-2"
BG_COLOR=white
BG_AMPLITUDE=0.004
BG_HIGHPASS=95
BG_LOWPASS=5600