# Junost 402B
# Tube: 31LK4B 31cm 4:3 monochrome CRT. Signal: B/W luminance amplifier stage.
# Sound: transistor power stage driving a 0.5GD-30 dynamic speaker.

CH_BLUR="boxblur=1.4:1:0:0"
CH_EQ="eq=saturation=0:brightness=-0.01:contrast=1.12:gamma=1.08"
CH_GRID="drawgrid=w=768:h=2:c=black@0.18:t=1"
CH_CURVES="curves=m='0/0.06 0.5/0.46 1/0.92'"
CH_VIGNETTE="vignette=angle=PI/5.5"

AUDIO_HIGHPASS=220
AUDIO_LOWPASS=6800
AUDIO_EQ="equalizer=f=1800:width_type=h:width=180:g=4,equalizer=f=450:width_type=h:width=100:g=2.5"
AUDIO_RATE=22050
BG_WEIGHT=0.22