% This is a Matlab file based on MTEX 6.0.0. 
% This file is to uniformly pick 1000 data points from EBSD map. 
% The generated file can be read by Neper.

ebsdfcc = ebsd('Iron fcc');

%Rotate about z-axis 45 degree
%ebsdfcc = rotate(ebsdfcc,45*degree);

%Rotate about x-axis 90 degree
% ebsdfcc = rotate(ebsdfcc,rotation.byAxisAngle(xvector,90*degree),'keepXY')

% Initialize Rodrigues vector array
rodriguesVectors = zeros(numel(ebsdfcc), 3); % Preallocate with [0, 0, 0]

% Loop through each data point
for i = 1:numel(ebsdfcc)
    % Get the orientation for the current data point
    ori = ebsdfcc(i).orientations;
    q = quaternion(ori.a,ori.b,ori.c,ori.d);
    v = Rodrigues(q);
    rodriguesVectors(i, :) = [v.x, v.y, v.z];
end

% Define the number of samples you want
numSamples = 1000;

% Generate uniformly spaced indices
indices = round(linspace(1, size(rodriguesVectors, 1), numSamples));

% Extract the sampled rows
sampledRodriguesVector = rodriguesVectors(indices, :);

% Specify the file name
outputFileName = 'sampledRodriguesVector.txt';

% Write the array to the text file
writematrix(sampledRodriguesVector, outputFileName, 'Delimiter', ' ');

% Confirm the file is written
disp(['File written to ', outputFileName]);
