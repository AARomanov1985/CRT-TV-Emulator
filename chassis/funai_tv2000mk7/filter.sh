# Funai TV-2000MK7
# Tube: 20-inch (51cm) 4:3 shadow-mask CRT. Decoder: integrated single-chip PAL/SECAM/NTSC unit.
# Sound: integrated IC power amplifier driving an internal dynamic speaker.

CH_BLUR="boxblur=0.5:1:0:0"
CH_EQ="eq=saturation=1.02:brightness=-0.001:contrast=1.12:gamma=1.00"
CH_GRID="drawgrid=w=768:h=2:c=black@0.10:t=1"
CH_CURVES="curves=m='0/0.02 0.5/0.50 1/0.98'"
CH_VIGNETTE="vignette=angle=PI/7.5"

AUDIO_HIGHPASS=100
AUDIO_LOWPASS=12500
AUDIO_EQ="equalizer=f=3200:width_type=h:width=300:g=2.5,equalizer=f=350:width_type=h:width=120:g=1"
AUDIO_RATE=32000
BG_WEIGHT=0.0025