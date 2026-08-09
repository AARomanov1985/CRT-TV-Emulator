# Cheap late-90s DVD deck out through composite: edge ringing on MPEG
# decode, rare block dropouts, and the composite encode smearing luma and
# chroma into each other, with hum on the audio path. The $50 experience.

PL_BLOCK="if(lt(mod(N,240),3)*gt(X,mod(N*7,700))*lt(X,mod(N*7,700)+32)*gt(Y,mod(N*11,520))*lt(Y,mod(N*11,520)+32),0,lum(X,Y))"
PL_BAND=""
PL_RING="unsharp=5:5:0.6:5:5:0.1"
PL_NOISE=1
CONN_BLUR="1:1:0:0"
CONN_CHROMA="chromashift=cbh=2:crh=-2:cbv=0:crv=0"
CONN_NOISE=3
CONN_AMP=0.0009
CONN_HIGHPASS=100
CONN_LOWPASS=9000
