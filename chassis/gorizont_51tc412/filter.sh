# Gorizont 51TC-412 / 51TC-510
# Tube: 51LK2B / planar 51cm 4:3 CRT. Decoder: MCR-403 / TDA3561A PAL/SECAM unit.
# Sound: K174UN14 amplifier driving 3GDSH-1 speaker.

CH_BLUR="boxblur=0.7:1:0:0"
CH_EQ="eq=saturation=0.96:brightness=-0.002:contrast=1.10:gamma=1.02"
CH_GRID="drawgrid=w=768:h=2:c=black@0.12:t=1"
CH_CURVES="curves=m='0/0.03 0.5/0.49 1/0.96'"
CH_VIGNETTE="vignette=angle=PI/7.0"

AUDIO_HIGHPASS=120
AUDIO_LOWPASS=11500
AUDIO_EQ="equalizer=f=3000:width_type=h:width=250:g=3,equalizer=f=350:width_type=h:width=120:g=1.5"
AUDIO_RATE=32000
BG_WEIGHT=0.08