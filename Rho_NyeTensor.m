%% Step 0: Define Constants and Inputs

% Disorientation angle and axis
Delta_h = 1;  % Disorientation angle in degrees
r = [-0.346908182,	0.577615007,	0.738928695
];  % Disorientation axis as a unit vector in sample system

Delta_h =deg2rad(Delta_h);

% Cell size (in meters)
cell_size = 0.7e-6;  % Convert µm to m

% Euler angles (in degrees)
phi1 = 97;  
Phi  = 4;
phi2 = 34;

% Define the three possible tube axes in the crystal system
tube_axes_crystal = [
    1 0 0;  % [100] direction
    0 1 0;  % [010] direction
    0 0 1   % [001] direction
];

% Define Burgers vectors (FCC <110> directions)
burgers_vectors = [
    0  1  -1;
    0  1   1;
    1  0   1;
    1 -1   0;
    1  1   0;
   -1  0   1
];

% Define edge line vectors (FCC edge dislocation)
edge_line_vectors = [
    2  -1  -1;
    2   1   1;
   -2   1  -1;
    2   1  -1;
   -1   2   1;
   -1  -2   1;
   -1  -1   2;
    1   1   2;
    1  -1   2;
    1  -1  -2;
   -1   2  -1;
    1   2   1
];

% Define screw dislocation line vectors (same as Burgers vectors)
screw_line_vectors = burgers_vectors;

% Define lattice parameter (in meters)
a = 3.6e-10;  % 316L

% Convert degrees to radians
phi1 = deg2rad(phi1);
Phi  = deg2rad(Phi);
phi2 = deg2rad(phi2);
Delta_h = deg2rad(Delta_h);

%% Step 1: Compute Disorientation Vector
D_h = Delta_h * r(:);  % Ensure column vector
disp('Disorientation vector (Dh):');
disp(D_h);

%% Step 2: Compute Lattice Curvatures

% Compute the orientation matrix g (Bunge convention)
g = [
    cos(phi1)*cos(phi2) - sin(phi1)*sin(phi2)*cos(Phi), -cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(Phi), sin(phi1)*sin(Phi);
    sin(phi1)*cos(phi2) + cos(phi1)*sin(phi2)*cos(Phi), -sin(phi1)*sin(phi2) + cos(phi1)*cos(phi2)*cos(Phi), -cos(phi1)*sin(Phi);
    sin(phi2)*sin(Phi), cos(phi2)*sin(Phi), cos(Phi)
];

% Initialize storage for rho_total values
rho_total_all = zeros(3,1);  % Store rho_total for each tube axis

% Loop over the three tube axes
for idx = 1:3
    %% Step 3: Compute Cell Spacing
    tube_axis_crystal = tube_axes_crystal(idx, :)';  % Select current tube axis

    % Transform tube axis to the sample coordinate system
    tube_axis_sample = g * tube_axis_crystal;

    % Compute delta_d as the projected spacing on the three sample axes
    Delta_d = cell_size * abs(tube_axis_sample);  % Take absolute values
    
    %% Step 4: Compute Dislocation Density Tensor
    % Compute lattice curvature components
    kappa = D_h ./ Delta_d';  % Broadcasting division

    % Compute dislocation density tensor α_ij
    alpha_matrix = [
        -kappa(2,2) - kappa(3,3), kappa(2,1), kappa(3,1);
        kappa(1,2), -kappa(1,1) - kappa(3,3), kappa(3,2);
        kappa(1,3), kappa(2,3), -kappa(1,1) - kappa(2,2)
    ];

    %% Step 5: Construct the Linear System A * q = alpha
    alpha_vector = alpha_matrix(:);  % Convert 3x3 matrix to 9x1 column vector

    % Scale Burgers vectors
    burgers_vectors_scaled = (a/2) * burgers_vectors;  

    % Convert Burgers and Line vectors to Sample Coordinate System
    burgers_vectors_sample = (g * burgers_vectors_scaled')';  
    screw_line_vectors_sample = (g * screw_line_vectors')';  
    edge_line_vectors_sample = (g * edge_line_vectors')';  

    % Normalize line vectors to make them unit vectors
    screw_line_vectors_sample = screw_line_vectors_sample ./ vecnorm(screw_line_vectors_sample, 2, 2);
    edge_line_vectors_sample = edge_line_vectors_sample ./ vecnorm(edge_line_vectors_sample, 2, 2);

    % Construct the coefficient matrix A (9x18)
    A = zeros(9, 18);
    for t = 1:6  % Loop over 6 unique Burgers vectors
        for i = 1:3
            for j = 1:3
                % Assign screw dislocation components (columns 1-6)
                A((i-1)*3 + j, t) = burgers_vectors_sample(t, i) * screw_line_vectors_sample(t, j);

                % Assign the first set of edge dislocations (columns 7-12)
                A((i-1)*3 + j, t+6) = burgers_vectors_sample(t, i) * edge_line_vectors_sample(2*t-1, j);

                % Assign the second set of edge dislocations (columns 13-18)
                A((i-1)*3 + j, t+12) = burgers_vectors_sample(t, i) * edge_line_vectors_sample(2*t, j);
            end
        end
    end

    %% Step 6: Solve A * q = alpha

%     % Define lower bound (q must be positive)
% %     lb = zeros(size(A,2), 1);  % q >= 0
%     lb = [];  % 
%     ub = [];  % No upper bound
% 
%     % Solve using lsqlin
%     q_L2 = lsqlin(A, alpha_vector, [], [], [], [], lb, ub);
% 
%     % Display results
%     disp('L2 norm solution with q >= 0 constraint:');
%     disp(q_L2);

    % Define number of variables
    n = size(A, 2);

    % Initial guess: least-squares solution
    q0 = pinv(A) * alpha_vector;  

    % Objective function: L1 norm approximation
    objFun = @(q) sum(abs(A * q - alpha_vector));

    % Constraint: q >= 0
    lb = [];  
    ub = [];  % No upper bound

    % Solve using fmincon
    options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'Display', 'iter');
    q_opt = fmincon(objFun, q0, [], [], [], [], lb, ub, [], options);

%     q0 = pinv(A) * alpha_vector


    % Compute total dislocation density
    rho_total = sum(abs(q_opt));  % Sum all elements in q_opt

    % Store the result
    rho_total_all(idx) = rho_total;
end

% Compute average total dislocation density
rho_total_avg = mean(rho_total_all);

% Display the final averaged dislocation density
disp('Total Dislocation Density for Each Tube Axis:');
disp(rho_total_all);

disp('Final Averaged Total Dislocation Density:');
disp(rho_total_avg);
