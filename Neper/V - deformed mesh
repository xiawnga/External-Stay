# Deformed mesh (stress)
neper -V simulation.sim \
-simstep 1 \
-datanodecoo coo \
-dataelt1drad 0.004 \
-dataelt3dedgerad 0.0015 \
-datanodecoofact 10 \
-dataelt3dcol stress33 \
-dataeltscaletitle "stress 33 MPa" \
-dataeltscale 0:300 \
-showelt1d all \
-cameraangle 13.5 \
-imagesize 800:800 \
-print 1_s33_deform

# Deformed mesh (strain)
neper -V simulation.sim \
-simstep 2 \
-datanodecoo coo \
-dataelt1drad 0.004 \
-dataelt3dedgerad 0.0015 \
-datanodecoofact 10 \
-dataelt3dcol strain33 \
-dataeltscaletitle "strain 33 MPa" \
-dataeltscale 0.000:0.005:0.010:0.015:0.020 \
-showelt1d all \
-cameraangle 13.5 \
-imagesize 800:800 \
-print 1_e33_deform
