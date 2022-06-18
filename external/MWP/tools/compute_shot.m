function desc = compute_shot(shape,params)
%
% desc = compute_shot(shape,params)
%    computes SHOT descriptors for the input shape according to the paper
%    "Tombari et al., Unique Signatures of Histograms for Local Surface Description, Proc. ECCV, pp. 356-369, 2010"
%
% inputs:
%    shape, struct containing the following fields:
%       X, Y, Z, coordinates
%       TRIV, triangular mesh connectivity
%    params, struct containing the following fields:
%       shot_bins,
%       max_radius,
%       shot_min_neighs,
%
% output:
%    desc, SHOT descriptor
%

if nargin < 2
    shot_bins = 10;%维度为352时，选用10,544时为16
    surface_area = compute_surface_area([shape.X,shape.Y,shape.Z],shape.TRIV);
    max_radius = 6 * sqrt(sum(surface_area)) / 100;% origin 6
    shot_min_neighs = 3;
else
    shot_bins = params.shot_bins;
    max_radius = params.max_radius;
    shot_min_neighs = params.shot_min_neighs;
end

tmp = calc_shot([shape.X,shape.Y,shape.Z]', shape.TRIV', 1:length(shape.X), shot_bins, max_radius, shot_min_neighs);
desc = tmp'; clear tmp;
