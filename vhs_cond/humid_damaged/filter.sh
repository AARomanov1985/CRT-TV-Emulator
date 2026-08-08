# Sticky-shed / humidity damaged tape: chroma melt, heavy softness, dropouts.
#
# Real mechanics: hydrolysis makes the oxide stick to deck parts, so the FM
# luma carrier loses SNR catastrophically (moisture drift -> gain pumping),
# chroma-under collapses, and the deck's servo drops tracking all over the
# frame — playback shows wobble bands that dart around, dropout blotches, and
# the whole picture shimmers. Aggressive undersampling + a full 4:1:0 chroma
# collapse + a fast darting tracking band.

SIG_PRE="scale=320:240,scale=768:576,format=yuv410p,format=yuv420p,boxblur=chroma_radius=10:luma_radius=2,geq=lum='lum(X,Y)*if(lt(abs(Y-mod(N*7,540)),10),0.62,if(lt(abs(Y-mod(N*7+70,540)),6),1.25,1))':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=alls=24:allf=t+u"
SIG_CHROMA="chromashift=cbh=4:crh=-4:cbv=2:crv=-2"
BG_COLOR=white
BG_AMPLITUDE=0.0045
BG_HIGHPASS=90
BG_LOWPASS=4800