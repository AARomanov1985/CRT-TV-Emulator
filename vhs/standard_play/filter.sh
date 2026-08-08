# Healthy SP tape on a decent deck.
#
# Real mechanics: VHS stores luma on an FM carrier (~2.6-3 MHz -> ~240 TVL)
# with chroma UNDER it (color-under, ~640 kHz -> roughly 1/4 luma's
# horizontal detail). Nothing in SP play is ever broadcast-sharp; the tape
# loses bandwidth to FM/subcarrier noise, not to a blur filter. Modeled as a
# genuine resample clamp (undersampling) plus a chroma-only collapse - the
# "melted color" 800-kHz color-under signature.
#
# A modest wandering tracking band sits at the head-switch zone: the deck's
# head-switch is a couple of lines; when in servo lock the frame stays
# centered, so the band slowly drifts and wraps while staying nearly aligned.

SIG_PRE="scale=480:360,scale=768:576,boxblur=chroma_radius=6:luma_radius=1,geq=lum='lum(X,Y)*if(lt(abs(Y-mod(N*2,540)),6),0.82,1)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=alls=5:allf=t+u"
SIG_CHROMA="chromashift=cbh=1:crh=-1:cbv=0:crv=0"
BG_COLOR=white
BG_AMPLITUDE=0.001
BG_HIGHPASS=100
BG_LOWPASS=9000