# Weak reception forced to black-and-white: desaturate + the heaviest
# noise of the range and a stronger luma ghost. Chroma noise survives
# the desaturation stage, reading as color-carrier interference sparkle
# on the mono set.

SIG_PRE="hue=s=0,geq=lum='0.7*lum(X,Y)+0.3*lum(X+10,Y)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=c0s=45:c0f=t+u:c1s=50:c1f=t+u:c2s=50:c2f=t+u"
SIG_CHROMA="chromashift=cbh=3:crh=3:cbv=3:crv=4"
BG_COLOR=pink
BG_WEIGHT=0.03
BG_HIGHPASS=150
BG_LOWPASS=3500
SIG_CRUSH="acompressor=threshold=0.15:ratio=4:attack=5:release=80,volume=3.5,compand=attacks=0:decays=0:points=-80/-80|-6/-6|-0.1/-6"