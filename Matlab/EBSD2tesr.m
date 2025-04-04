% This is a Matlab file based on MTEX 6.0.0. 
% The function of this program is to convert EBSD data to .tesr file for Neper. 
% The involved MTEX function is calculating Rodrigues vectors from orientation data.

map_idx = 1; % Change this manually before each run

% Define the main output directory
outputDir = 'C:\Users\...';

% Define subdirectories
imageDir = fullfile(outputDir, 'images');
tesrDir = fullfile(outputDir, 'tesr');

% Ensure directories exist
if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
if ~exist(tesrDir, 'dir')
    mkdir(tesrDir);
end

% Define the expected image filename
check = fullfile(imageDir, sprintf('map%d.png', map_idx));

% Check if the file already exists
if exist(check, 'file')
    error('The file %s already exists. Stopping execution.', check);
end



stepsize = round(ebsd(2).x-ebsd(1).x,2);
X_max = round(ebsd(size(ebsd,1)).x / stepsize) +1 ;
Y_max = round(ebsd(size(ebsd,1)).y / stepsize) +1 ;


ebsd_selected = ebsd
%Rotate about x-axis 90 degree
% ebsd_selected = rotate(ebsd_selected,rotation.byAxisAngle(xvector,90*degree),'keepXY')

% Initialize Rodrigues vector array
rodriguesVectors = zeros(numel(ebsd_selected), 3); % Preallocate with [0, 0, 0]
grainsIdVectors = zeros(numel(ebsd_selected), 1);
defIdVectors = zeros(numel(ebsd_selected), 1);
[grains,ebsd_selected.grainId] = calcGrains(ebsd_selected,'angle',0.5*degree,'minPixel',50);



% Process each EBSD point
% Extract relevant data from ebsd_selected all at once
phaseMask = (ebsd_selected.phase == 1);  % Logical mask for phase 1

% Ensure orientations are stored correctly (handles single & multiple entries)
if any(phaseMask)
    orientations = [ebsd_selected(phaseMask).orientations]; % Force as array
    grainIds = [ebsd_selected(phaseMask).grainId]; % Ensure numeric array

    % Convert quaternion to Rodrigues vector in one go
    q = quaternion(vertcat(orientations.a), vertcat(orientations.b), ...
                   vertcat(orientations.c), vertcat(orientations.d)); % Batch processing

    v = Rodrigues(q);

    % Apply values only where phase == 1
    rodriguesVectors(phaseMask, :) = [v.x, v.y, v.z];
    grainsIdVectors(phaseMask) = grainIds;
    defIdVectors(phaseMask) = 1;
else
    % If no valid phase 1 data, keep zero arrays
    rodriguesVectors = zeros(numel(ebsd_selected), 3);
    grainsIdVectors = zeros(numel(ebsd_selected), 1);
    defIdVectors = zeros(numel(ebsd_selected), 1);
end


% Step 1: Create phase mask
% Step 2: Get grain IDs for EBSD points with phase == 1
grainIdsWithPhase1 = unique(ebsd_selected(phaseMask).grainId);
% Step 3: Ensure grainSizes is numeric and a column
grainSizes = double(grains.grainSize(:));  % Make sure it's a column vector
% Step 4: Create grainInfo for all grains
grainInfo = [(1:numel(grainSizes))', grainSizes];
% Step 5: Apply mask to keep only grains that appear in phase 1
grainInfo = grainInfo(ismember(grainInfo(:,1), grainIdsWithPhase1), :);

% Plot and save the orientation map
figure;
plot(ebsd_selected,ebsd_selected.orientations)
% overlay the grain boundaries
hold on
plot(grains.boundary,'linewidth',1)
hold off
mapName = sprintf('map%d.png', map_idx);
saveas(gcf, fullfile(imageDir, mapName));
close(gcf);  % Close figure to free memory

% Write the .tesr file
fileName = sprintf('map%d.tesr', map_idx);
filePath = fullfile(tesrDir, fileName);
fileID = fopen(filePath, 'w');

fprintf(fileID, '***tesr\n');
fprintf(fileID, '**format\n');
fprintf(fileID, '   %.1f\n', 2.1);
fprintf(fileID, '**general\n');
fprintf(fileID, '   %d\n', 2);
fprintf(fileID, '   %d %d\n', X_max, Y_max);
fprintf(fileID, '   %.12f %.12f\n', stepsize, stepsize);
fprintf(fileID, '**cell\n');
fprintf(fileID, '   %d\n', numel(grains));
fprintf(fileID, '*crysym\n');
fprintf(fileID, '   %s\n', 'cubic');
fprintf(fileID, '**data\n');
fprintf(fileID, '   ascii\n');
fprintf(fileID, '%d ', grainsIdVectors);
fprintf(fileID, '\n');
fprintf(fileID, '**oridata\n');
fprintf(fileID, '   rodrigues:active\n');
fprintf(fileID, '   ascii\n');
fprintf(fileID, '   %.12f %.12f %.12f\n', rodriguesVectors.');
fprintf(fileID, '**oridef\n');
fprintf(fileID, '   ascii\n');
fprintf(fileID, '%d ', defIdVectors);
fprintf(fileID, '\n');
fprintf(fileID, '***end\n');

fclose(fileID);  % Close the file

% Display confirmation
fprintf('File "%s" and plot "%s" generated.\n', fileName, mapName);

% clear;
