%matching: s1-->s2
close all;
s1_name='cuts_dog_shape_12';
s2_name='dog';
mesh_dir=fullfile(pwd,'data');

% MWP params
num_eigs=128;
Nf=6;
num_iters=5; 
% if initialization is poor, more iterations are needed

% precompute data
% read file and compute laplacian matrix, eigen-decomposition
s1_shape=precompute_data(fullfile(mesh_dir,[s1_name,'.off']),num_eigs);
s2_shape=precompute_data(fullfile(mesh_dir,[s2_name,'.off']),num_eigs);

% compute shot descriptors to initialize
shot_bins = 10;
max_radius = 6; 
shot_min_neighs = 3;

s1_desc=calc_shot([s1_shape.X,s1_shape.Y,s1_shape.Z]', s1_shape.TRIV', 1:length(s1_shape.X), ...
    shot_bins, max_radius*sqrt(s2_shape.area)/100, shot_min_neighs);
s1_desc=s1_desc';

s2_desc=calc_shot([s2_shape.X,s2_shape.Y,s2_shape.Z]', s2_shape.TRIV', 1:length(s2_shape.X), ...
    shot_bins, max_radius*sqrt(s2_shape.area)/100, shot_min_neighs);
s2_desc=s2_desc';

T0=knnsearch(s2_desc,s1_desc);

rgb=coord2rgb([s2_shape.X,s2_shape.Y,s2_shape.Z]);
mplot_mesh_rgb([s2_shape.X,s2_shape.Y,s2_shape.Z],s2_shape.TRIV,rgb);title('Source')
mplot_mesh_rgb([s1_shape.X,s1_shape.Y,s1_shape.Z],s1_shape.TRIV,rgb(T0,:));title('Init')

% MWP refine
[s1_shape,s2_shape]=truncate_evecs(s1_shape,s2_shape); % for partial matching
tic;
[T,C]=MWP(s1_shape,s2_shape,T0,Nf,num_iters);
toc
figure;imagesc(C);title('MWP refine C');
mplot_mesh_rgb([s1_shape.X,s1_shape.Y,s1_shape.Z],s1_shape.TRIV,rgb(T,:));title('MWP refine')


% %MWP fast refine
% tic;
% [T,C]=MWP_fast(s1_shape,s2_shape,T0,Nf,num_iters,num_samples);
% toc
% figure;imagesc(C);title('MWP fast refine C');
% mplot_mesh_rgb([s1_shape.X,s1_shape.Y,s1_shape.Z],s1_shape.TRIV,rgb(T,:));title('MWP fast refine')



