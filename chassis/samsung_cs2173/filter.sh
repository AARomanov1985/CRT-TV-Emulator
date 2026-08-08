# Samsung CS-2173 (KS1A one-chip, ~1991, PAL/SECAM D/K)
# Tube: 21" shadow mask, budget-mid Korean. One-chip TDA935-style jungle
# TV: works, vaguely hot, slightly over-saturated, soft in the shadows.
# Everything here is the price class - loose mask, lifted gamma, deep
# vignette from the cheap plastic dome.
# Sound: mono, thin, 22050 band like every Korean budget set.

CH_BLUR="boxblur=0.55:1:0:0"
CH_EQ="eq=saturation=1.06:brightness=0.005:contrast=1.05:gamma=1.06"
CH_GRID="drawgrid=w=768:h=2:c=black@0.13:t=1"
CH_CURVES="curves=m='0/0.07 0.5/0.5 1/0.9'"
CH_VIGNETTE="vignette=angle=PI/6"

AUDIO_HIGHPASS=120
AUDIO_LOWPASS=9000
AUDIO_EQ="equalizer=f=1800:width_type=h:width=180:g=2,equalizer=f=400:width_type=h:width=100:g=0.5"
AUDIO_RATE=22050
BG_WEIGHT=0.1