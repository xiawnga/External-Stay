# This is the command for generating tessalation with specific orientatations. Used together with "SampledRodrigues.m"
neper -T -n 1000 -crysym cubic \
-morpho "diameq:1,1-sphericity:lognormal(0.145,0.03)" \
-ori "file(sampledRodriguesVector.txt)" \
-reg 1 \
-o fromori
