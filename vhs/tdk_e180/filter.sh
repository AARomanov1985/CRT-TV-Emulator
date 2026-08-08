# TDK E-180 (PAL/SECAM) - base model fragment.
#
# TDK was the most common quality cassette in 1990s Europe / ex-USSR: 180
# minutes SP on a 257 m tape (about 14-15 um base), VHS SP ~2.339 cm/s. Its
# oxide is denser than the bazaar cheapies, so the FM luma carrier holds
# detail well (close to the format's ~240 TVL ceiling) and the chroma-under
# band stays tidy.
#
# This fragment is the *model*: a factory-fresh, never-recorded tape. It sets
# the hardware baseline. Conditions (vhs_cond/*) override these variables on
# top to degrade playback (rental wear, humidity, generations, etc).
#
#   SIG_PRE      input conditioning (undersample clamp + chroma collapse;
#                a properly functioning deck shows no wander band on fresh
#                tape, so the model carries none - conditions add theirs)
#   SIG_NOISE    playback FM noise
#   SIG_CHROMA   chroma-under phase offset

SIG_PRE="scale=512:384,scale=768:576,boxblur=chroma_radius=6:luma_radius=1"
SIG_NOISE="noise=alls=4:allf=t+u"
SIG_CHROMA="chromashift=cbh=1:crh=-1:cbv=0:crv=0"
BG_COLOR=white
BG_AMPLITUDE=0.0009
BG_HIGHPASS=110
BG_LOWPASS=9500
