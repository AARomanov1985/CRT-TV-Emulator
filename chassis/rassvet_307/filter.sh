# Rassvet-307
# Tube: 40LK6B 40cm monochrome CRT, ULPT-40-III-1 unified hybrid
# (lamp-semiconductor), Krasnoyarsk TV plant, from 1975.
# No color decoder: CH_LUMA folds the frame to luma-only, SIG_CHROMA skipped.
# Tabletop, 140W, 24kg. Sound: 0.5W single dynamic stage, soft lamp-driver highs.

CH_LUMA="format=gray"
CH_BLUR="boxblur=1.1:1:0:0"
CH_EQ="eq=brightness=-0.005:contrast=1.1:gamma=1.05"
CH_GRID="drawgrid=w=768:h=2:c=black@0.14:t=1"
CH_CURVES="curves=m='0/0.05 0.5/0.47 1/0.93'"
CH_VIGNETTE="vignette=angle=PI/6"

AUDIO_HIGHPASS=150
AUDIO_LOWPASS=8000
AUDIO_EQ="equalizer=f=1600:width_type=h:width=200:g=3.5,equalizer=f=400:width_type=h:width=120:g=1.5"
AUDIO_RATE=22050
BG_WEIGHT=0.009