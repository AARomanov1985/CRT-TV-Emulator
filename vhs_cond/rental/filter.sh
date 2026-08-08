# Rental condition: the video shop copy that has been played a hundred times.
#
# Real mechanics: rental stock racks up passes fast, so the oxide pretture
# degrades (higher FM noise), the head-switch band widens and wanders, and
# dropouts accumulate. Chroma-under bleeds from the worn surface.
#
# Overrides the tdk_e180 model baseline with the "abused by a rental deck" set.

SIG_PRE="scale=384:288,scale=768:576,boxblur=chroma_radius=8:luma_radius=1.5,geq=lum='lum(X,Y)*if(lt(abs(Y-mod(N*0.15,540)),6),0.85,1)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=alls=14:allf=t+u"
SIG_CHROMA="chromashift=cbh=3:crh=-2:cbv=2:crv=-1"
BG_COLOR=white
BG_AMPLITUDE=0.003
BG_HIGHPASS=100
BG_LOWPASS=6500