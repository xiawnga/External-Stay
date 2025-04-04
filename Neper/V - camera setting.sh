# This is about changing the camera position when the coordinate system is confused.
neper -V B110.tess -pfpole 1:1:0 -space pf -pfdir -x:-y -cameracoo x-length*vx:y-length*vy:z+length*vz -print img1
