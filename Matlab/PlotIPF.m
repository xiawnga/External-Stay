% This is a Matlab file based on MTEX 6.0.0. 
% This file is to plot IPF using different reference directions. 
% The directions and grain boundary threshold can be changed.

ipfKey = ipfHSVKey(ebsd('Iron fcc'));

% set the reference direction to X
ipfKey.inversePoleFigureDirection = vector3d.Y;

% compute the colors
colors = ipfKey.orientation2color(ebsd('Iron fcc').orientations);

% plot the ebsd data together with the colors
plot(ebsd('Iron fcc'),colors)

lagb = 0.1*degree;
hagb = 0.2*degree;

% reconstruct grains
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',[hagb lagb],'minPixel',50);

% smooth grain boundaries
grains = smooth(grains,5);

hold on
plot(grains.boundary,'linewidth',1)
hold off
