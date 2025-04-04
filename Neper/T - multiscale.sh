# This is the command for generating multiscale tess. The morpho and ori for each scale can be changed.

neper -T -n "10::9::24" \
-crysym cubic \
-morpho "diameq:lognormal(1,0.1),1-sphericity:lognormal(0.1,0.03)::diameq:lognormal(1,0.1),1-sphericity:lognormal(0.1,0.03)::msfile(morpho_msfile)" \
-ori "random::random::cube:normal(thetam=1)" \
-reg 1 \
-o test
