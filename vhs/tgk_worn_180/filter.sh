# Heavily used E-180 tape (angles scratch, leaves shed on the deck).
#
# Real mechanics: 180-min tape runs thinner base + thinner oxide, so the FM
# luma envelope is noisier and head-switch tracking is visibly poor. Drums
# mounted on a doll bearing bind -> the head-switch band wanders noticeably
# across the picture and drops out abruptly at the wrong places. Modeled as:
# deeper undersampling + a wide-chroma collapse + a fast wandering tracking
# band + dropout-ish grain.

SIG_PRE="scale=384:288,scale=768:576,boxblur=chroma_radius=8:luma_radius=1.5,geq=lum='lum(X,Y)*if(lt(abs(Y-mod(N*3,540)),9),0.7,1)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=alls=16:allf=t+u"
SIG_CHROMA="chromashift=cbh=3:crh=-2:cbv=2:crv=-1"
BG_COLOR=white
BG_AMPLITUDE=0.003
BG_HIGHPASS=100
BG_LOWPASS=6500