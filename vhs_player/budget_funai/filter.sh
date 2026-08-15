# Budget Funai tier: the corner-store deck everyone was once lent. No TBC:
# video heads drift slowly, the tracking wanders, dropout chatters on the
# head-switch band, FM noise rides old heads. Mono audio on a loud hiss bed.

DECK_WAND="1-0.12*exp(-pow((Y-mod(N*0.4,540)+3*(random(1)-0.5))/6,2))*(0.7+0.3*random(2))"
DECK_DTC="lum(X,Y)*(1-0.25*exp(-pow((Y-(566+4*random(5)))/3,2)))+exp(-pow((Y-(566+4*random(5)))/3,2))*random(7)*90"
DECK_NOISE=5
DECK_AMP=0.0025
DECK_HIGHPASS=140
DECK_LOWPASS=5200
