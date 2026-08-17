# Sony Trinitron M-series (KV-M2180, ~1990-91, PAL/SECAM D/K)
# Tube: 21" aperture grille Trinitron. The grille is what separates it:
# no hole-mask moire, bright and crisp, punchy color. Aperture grille also
# means tighter luma retention -> minimal blur, high contrast, near-flat
# vignette compared to shadow-mask sets.
# Sound: mono 6W European-market stage.

CH_BLUR="boxblur=0.4:1:0:0"
CH_EQ="eq=saturation=1.08:brightness=-0.01:contrast=1.15:gamma=1.0"
CH_GRID="drawgrid=w=768:h=2:c=black@0.08:t=1"
CH_CURVES="curves=m='0/0.02 0.5/0.48 1/0.98'"
CH_VIGNETTE="vignette=angle=PI/9"

AUDIO_HIGHPASS=90
AUDIO_LOWPASS=14000
AUDIO_EQ="equalizer=f=2800:width_type=h:width=250:g=2.5,equalizer=f=350:width_type=h:width=120:g=1"
AUDIO_RATE=32000
BG_WEIGHT=0.003