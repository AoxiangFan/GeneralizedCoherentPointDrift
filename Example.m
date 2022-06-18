clear,clc
close all
% This is a demo of our GCPD, which replicates the result presented in Fig.1 in our
% paper. Could take a few minutes due to the high-resolution of the shapes.
% Runnable on both Windows and Linux system. Tested with MATLAB 2016b on
% Windows and MATLAB 2018a on Linux.

addpath(genpath('./'));

file1 = './data/cat1.off';
file2 = './data/cat7.off';

%% Preprocessing of shapes, compute eigen-decomposition of Laplace-Beltrami Operator
k = 500;
S1 = MESH.preprocess(file1, 'IfComputeLB', true, 'numEigs', k);
S2 = MESH.preprocess(file2, 'IfComputeLB', true, 'numEigs', k);

% normalization
[S1, S2] = surfaceNorm(S1, S2);

% For high-resolution shapes, (optionally) setting multiscale to true will 
% activate sampling on the shape when establishing initial corresponces, which can 
% reduce time cost in descriptor matching. 
% For low-resolution shapes (e.g. below 5000 vertices), set it to false.

multiscale = false;
if multiscale
    samples_X = fps_euclidean([S1.surface.X, S1.surface.Y, S1.surface.Z], 5000, randi(S1.nv));
else
    samples_X = 1:size(S1.surface.VERT,1);
end
if multiscale
    samples_Y = fps_euclidean([S2.surface.X, S2.surface.Y, S2.surface.Z], 5000, randi(S2.nv));
else
    samples_Y = 1:size(S2.surface.VERT,1);
end

S1.area = sum(calc_tri_areas(S1.surface));
S2.area = sum(calc_tri_areas(S2.surface));

%% SHOT matching
opts.shot_num_bins = 10;
opts.shot_radius = 5;
shot1 = calc_shot(S1.surface.VERT', S1.surface.TRIV', 1:S1.nv, opts.shot_num_bins, opts.shot_radius*sqrt(S1.area)/100, 3)';
shot2 = calc_shot(S2.surface.VERT', S2.surface.TRIV', 1:S2.nv, opts.shot_num_bins, opts.shot_radius*sqrt(S2.area)/100, 3)';
matches = knnsearch(shot2, shot1, 'NSMethod','kdtree');

%% MWP matching
Nf = 5;
num_iters = 3; 
[~, C] = MWP2(S1, S2, 200, matches, Nf, num_iters);
k0 = size(C,1);
T12_0 = knnsearch(S2.evecs(samples_Y,1:k0)*C',S1.evecs(samples_X,1:k0));

% Visualize MWP matching result by color transfer.
if multiscale
    T12_0_full = knnsearch(S2.evecs(:,1:k0)*C',S1.evecs(:,1:k0));
else
    T12_0_full = T12_0;
end
[S1_col,S2_col]= get_mapped_face_color_withNaN(S1,S2,T12_0_full);
figure
subplot(1,2,1);
MESH.PLOT.render_mesh(S1,'MeshVtxCol',S1_col);
subplot(1,2,2);
MESH.PLOT.render_mesh(S2,'MeshVtxCol',S2_col);

%% GCPD matching with MWP initialization

X0 = S1.surface.VERT;
Y0 = S2.surface.VERT;
X = X0(samples_X,:);
Y = Y0(samples_Y,:);

% GCPD initial matching, handling outliers
conf = GCPD_initial_settings([]);
U = S1.evecs(samples_X, 1:k);
e = S1.evals(1:k);
[~, C, ~] = GCPD_initial(Y(T12_0,:), X, U, e, conf);

% GCPD full matching, refine results
conf = GCPD_settings([]);
U0 = S1.evecs(:, 1:k);
[T0, ~, ~] = GCPD(Y0, X0, U0, e, C, conf);
T12 = knnsearch(Y0, T0);

% Visualize GCPD transformed shape
figure
S1t = S1;
S1t.surface.VERT = [T0(:,1), T0(:,2), T0(:,3)];
MESH.PLOT.render_mesh(S1t,'MeshVtxCol',S1_col);
suptitle('Transformed Shape by GCPD');


% Visualize GCPD matching result by color transfer.
[S1_col,S2_col]= get_mapped_face_color_withNaN(S1,S2,T12);
figure
subplot(1,2,1);
MESH.PLOT.render_mesh(S1,'MeshVtxCol',S1_col);
subplot(1,2,2);
MESH.PLOT.render_mesh(S2,'MeshVtxCol',S2_col);



