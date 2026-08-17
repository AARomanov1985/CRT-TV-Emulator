# Gorizont 736/D
# Tube: 61LK3C 61cm color CRT, ULPCTI-61-II family (2nd class hybrid).
# Decoder: BC-3 chroma unit (PAL/SECAM), BRC-3 RF stage, SVP-4 touch program.
# Same Minsk house look as the 51TC-412 but on the big glass: slightly
# softer OCT, gentler tweaks, subtler vignette - a 61cm set you sit further
# from. Audio is the flagship part: 2.5W, two drivers (2GD-36 + 3GD-38E),
# full 63..12600 Hz band.

CH_BLUR="boxblur=0.9:1:0:0"
CH_EQ="eq=saturation=0.97:brightness=-0.002:contrast=1.06:gamma=1.02"
CH_GRID="drawgrid=w=768:h=2:c=black@0.10:t=1"
CH_CURVES="curves=m='0/0.03 0.5/0.5 1/0.95'"
CH_VIGNETTE="vignette=angle=PI/6.8"

AUDIO_HIGHPASS=65
AUDIO_LOWPASS=12600
AUDIO_EQ="equalizer=f=3000:width_type=h:width=250:g=2,equalizer=f=300:width_type=h:width=120:g=1"
AUDIO_RATE=44100
BG_WEIGHT=0.003