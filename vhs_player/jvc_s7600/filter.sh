# JVC HR-S7600: late-90s hi-end VCR with a full frame TBC. Transport
# steady, no wander, dropout concealed. The TBC is modeled as a gentle
# denoise + fixed tracking, not as adding anything — hiss stays at the
# cassette's own floor (DECK_AMP falls through to DEG/TAPE when unset).

DECK_WAND=""
DECK_DTC=""
DECK_DENOISE="spp=quality=4"
DECK_NOISE=0
DECK_AMP=0.0009
DECK_HIGHPASS=110
DECK_LOWPASS=9500
