# Weak reception, color retained but barely: stronger luma ghost and
# the heaviest chromatic snow - the chroma planes carry more noise than
# luma, so the color field sparkles while the picture detail survives.

SIG_PRE="geq=lum='0.7*lum(X,Y)+0.3*lum(X+6,Y)':cb='cb(X,Y)':cr='cr(X,Y)'"
SIG_NOISE="noise=c0s=30:c0f=t+u:c1s=45:c1f=t+u:c2s=45:c2f=t+u"
SIG_CHROMA="chromashift=cbh=3:crh=-3:cbv=1:crv=-1"
BG_COLOR=pink
BG_WEIGHT=0.02
BG_HIGHPASS=120
BG_LOWPASS=3500
SIG_CRUSH="acompressor=threshold=0.15:ratio=4:attack=5:release=80,volume=3.5,compand=attacks=0:decays=0:points=-80/-80|-6/-6|-0.1/-6"