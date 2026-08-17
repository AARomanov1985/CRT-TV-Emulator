# Moderate reception forced to black-and-white: desaturate + heavy noise
# and a luma ghost. Chroma noise survives the desaturation stage, reading
# as color-carrier interference sparkle on the mono set.
# The whole audio path (voice and noise alike) is narrowed to 100-2000 Hz,
# like a signal that lost its bandwidth before reaching the set.

SIG_PRE="hue=s=0,geq=lum='0.9*lum(X,Y)+0.1*lum(X+6,Y)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=c0s=20:c0f=t+u:c1s=45:c1f=t+u:c2s=45:c2f=t+u"
SIG_CHROMA="chromashift=cbh=2:crh=2:cbv=2:crv=2"
BG_COLOR=pink
BG_WEIGHT=0.008
BG_HIGHPASS=100
BG_LOWPASS=2000
SIG_CRUSH="acompressor=threshold=0.15:ratio=4:attack=5:release=80,volume=3,compand=attacks=0:decays=0:points=-80/-80|-4.5/-4.5|-0.1/-4.5"