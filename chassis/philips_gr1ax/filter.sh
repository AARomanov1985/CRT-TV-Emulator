# Philips 21-class, ~1990, GR1AX / G90 chassis (PAL/SECAM D/K)
# The Dutch neutral: high detail, balanced color, no saturation theatrics.
# Shadow-mask glass, big effort into geometry and focus. Black line tube.
# One of the cleanest 21" monsters of the era.
# Sound: stereo-capable NICAM-ish stage, 2 speakers, wide band.

CH_BLUR="boxblur=0.5:1:0:0"
CH_EQ="eq=saturation=1.0:brightness=-0.005:contrast=1.1:gamma=1.0"
CH_GRID="drawgrid=w=768:h=2:c=black@0.10:t=1"
CH_CURVES="curves=m='0/0.03 0.5/0.5 1/0.95'"
CH_VIGNETTE="vignette=angle=PI/7"

AUDIO_HIGHPASS=80
AUDIO_LOWPASS=12500
AUDIO_EQ="equalizer=f=2600:width_type=h:width=250:g=2,equalizer=f=350:width_type=h:width=120:g=1"
AUDIO_RATE=32000
BG_WEIGHT=0.0035