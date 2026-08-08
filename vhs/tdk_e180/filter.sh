# TDK E-180 (PAL/SECAM) - base model fragment.
#
# Model fragments define the CASSETTE HARDWARE as parameters, NOT as final
# SIG_* variables. The engine's build_vhs_sig() combines these with the chosen
# vhs_cond/<condition> deltas to produce SIG_PRE/SIG_NOISE/SIG_CHROMA, so the
# model's character survives degradation (a worn TDK still plays like a TDK).
#
# TDK: 1990s EU/ex-USSR quality standard. 257 m E-180 (VHS SP ~2.339 cm/s).
# Dense oxide, modestly tight noise floor.
#
#   TAPE_SMP        undersample clamp target (luma loses HF before the collapse)
#   TAPE_BLURH      chroma-under collapse radius
#   TAPE_BLURL      luma box radius
#   TAPE_NOISE      FM noise floor strength
#   TAPE_CH_*       chroma-under phase offset
#   TAPE_AMP/HI/LO  hiss floor (amplitude / highpass / lowpass)

TAPE_SMP="512:384"
TAPE_BLURH=6
TAPE_LUMAR=1
TAPE_NOISE=4
TAPE_CH_CBH=1
TAPE_CH_CRH=-1
TAPE_CH_CBV=0
TAPE_CH_CRV=0
TAPE_AMP=0.0009
TAPE_HIGHPASS=110
TAPE_LOWPASS=9500