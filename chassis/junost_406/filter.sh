# Junost 406
# Tube: 31LK4B 31cm 90-degree monochrome CRT (same tube as 402B, UPTI-31-IV-7/6).
# No color decoder: CH_LUMA folds the frame to luma-only, SIG_CHROMA skipped.
# Portable cabinet: contrast pushed, tight 90-degree mask you sit close to,
# vignette dies toward the corners earlier than a tabletop set.
# Sound: small 0.5W dynamic stage - brighter, narrower band than the 402B.

CH_LUMA="format=gray"
CH_BLUR="boxblur=1.4:1:0:0"
CH_EQ="eq=brightness=-0.02:contrast=1.15:gamma=0.95"
CH_GRID="drawgrid=w=768:h=2:c=black@0.16:t=1"
CH_CURVES="curves=m='0/0.08 0.5/0.48 1/0.9'"
CH_VIGNETTE="vignette=angle=PI/4.8"

AUDIO_HIGHPASS=250
AUDIO_LOWPASS=6500
AUDIO_EQ="equalizer=f=2200:width_type=h:width=180:g=5,equalizer=f=500:width_type=h:width=100:g=1.5"
AUDIO_RATE=22050
BG_WEIGHT=0.01