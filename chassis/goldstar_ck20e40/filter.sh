# GoldStar (LG) CK-20E40
# Tube: 20-inch (51cm) 4:3 shadow-mask CRT. Decoder: TDA8362 PAL/SECAM/NTSC single-chip unit.
# Sound: MC-64A / LA4225 amplifier driving internal 8-ohm speaker.

CH_BLUR="boxblur=0.4:1:0:0"
CH_EQ="eq=saturation=1.05:brightness=0.000:contrast=1.10:gamma=0.98"
CH_GRID="drawgrid=w=768:h=2:c=black@0.08:t=1"
CH_CURVES="curves=m='0/0.01 0.5/0.51 1/0.99'"
CH_VIGNETTE="vignette=angle=PI/7.8"

AUDIO_HIGHPASS=90
AUDIO_LOWPASS=13000
AUDIO_EQ="equalizer=f=3100:width_type=h:width=250:g=2,equalizer=f=320:width_type=h:width=100:g=1"
AUDIO_RATE=32000
BG_WEIGHT=0.002