# Rubin 51TC-402D / 460D
# Tube: 51LK2B/51LK1B 51cm 4:3 CRT. Decoder: PAL/SECAM (MUP-402 matrix).
# Sound: K174UN7 amplifier driving 3GD-38 / 2GD-40 dynamic speaker.

CH_BLUR="boxblur=1.2:1:0:0"
CH_EQ="eq=saturation=0.92:brightness=-0.005:contrast=1.08:gamma=1.05"
CH_GRID="drawgrid=w=768:h=2:c=black@0.14:t=1"
CH_CURVES="curves=m='0/0.05 0.5/0.48 1/0.94'"
CH_VIGNETTE="vignette=angle=PI/6.5"

AUDIO_HIGHPASS=150
AUDIO_LOWPASS=9500
AUDIO_EQ="equalizer=f=2500:width_type=h:width=200:g=4,equalizer=f=400:width_type=h:width=100:g=2"
AUDIO_RATE=22050
BG_WEIGHT=0.0075