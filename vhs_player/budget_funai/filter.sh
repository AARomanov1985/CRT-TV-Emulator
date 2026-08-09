# Budget Funai tier: the corner-store deck everyone was once lent. No TBC:
# video heads drift slowly, the tracking wanders, dropout chatters on the
# head-switch band, FM noise rides old heads. Mono audio on a loud hiss bed.

DECK_WAND="if(lt(abs(Y-mod(N*0.4,540)),9),0.86,1)"
DECK_DTC="if(lt(abs(Y-mod(N*1.7,540)),5),lum(X,Y)*0.4,lum(X,Y))"
DECK_NOISE=5
DECK_AMP=0.0025
DECK_HIGHPASS=140
DECK_LOWPASS=5200
