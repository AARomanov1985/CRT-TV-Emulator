# Noisy/drifting reception, color retained but unstable: luma ghost and
# heavy chromatic snow - the chroma planes carry more noise than luma,
# so the color field sparkles while the picture detail survives.

SIG_PRE="geq=lum='0.9*lum(X,Y)+0.1*lum(X+6,Y)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=c0s=20:c0f=t+u:c1s=45:c1f=t+u:c2s=45:c2f=t+u"
SIG_CHROMA="chromashift=cbh=2:crh=-2:cbv=1:crv=-1"
BG_COLOR=pink
BG_WEIGHT=0.006
BG_HIGHPASS=110
BG_LOWPASS=5500
SIG_CRUSH="acompressor=threshold=0.15:ratio=4:attack=5:release=80,volume=3,compand=attacks=0:decays=0:points=-80/-80|-4.5/-4.5|-0.1/-4.5"