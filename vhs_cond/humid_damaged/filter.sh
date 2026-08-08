# Humid-damaged condition - degradation deltas on top of the model.
#
# Sticky-shed / humidity damage: oxide shedding destroys the FM SNR, chroma
# bleeds hard, luma smears. Real signature: the transport JERKS as the tape
# sticks - a band tears luma sideways - and the FM carrier dropouts flicker
# white. That replaces the clean head-switch drift: this tape does not drift,
# it seizes.
#
# DEG_LUM is a full geq luma expression (not a *multiplier): it samples a
# shifted pixel for the tear, so it must override lum(X,Y) entirely.

DEG_SMP="320:240"
DEG_BLURH=4
DEG_LUMAR=1
DEG_NOISE=20
DEG_CBH=3
DEG_CRH=-3
DEG_CBV=2
DEG_CRV=-2
DEG_LUM="if(lt(abs(Y - mod(N*40,540)),2), lum(max(0,X-9),Y), lum(X,Y)) + if(lt(Y, mod(N*23,540)+26)*gt(Y, mod(N*23,540)), if(lt(mod(X*47+Y*23+N*13,13),2),255,0),0)"
DEG_AMP=0.0045
DEG_HIGHPASS=90
DEG_LOWPASS=4800