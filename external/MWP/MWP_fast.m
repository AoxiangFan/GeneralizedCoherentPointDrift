function [T,C]=MWP_fast(s1_shape,s2_shape,T0,Nf,num_iters,num_samples)
% default params:
% Nf=6;
% num_iters=5;
% num_samples=500;

% matching: s1_shape-->s2_shape;
% s1_shape: matlab struct with fields:
%           .X,.Y,.Z: 3d coordinates.
%           .TRIV: face connection
%           .evecs: [N,K], eigen-vectors
%           .evals: [K,1],eigen-values


% prepare filters, functions from gspbox:https://github.com/epfl-lts2/gspbox 
g1=gsp_design_meyer(s1_shape.evals(end),Nf);
g2=gsp_design_meyer(s2_shape.evals(end),Nf);

k1=size(s1_shape.evals,1);
k2=size(s2_shape.evals,1);

fs1=cell(Nf,1);
fs2=cell(Nf,1);

for s=1:Nf
    fs1{s}=sparse(1:k1,1:k1,g1{s}(s1_shape.evals));
    fs2{s}=sparse(1:k2,1:k2,g2{s}(s2_shape.evals));
end

% accelerate nearest neighbor search by flann lib:
%   https://github.com/flann-lib/flann
% how to compile it with MSVC: 
%   https://gist.github.com/UnaNancyOwen/1e3fced09e4430ad0b7b#file-flann1-9-1-md
% params for flann_search
params.algorithm='kdtree';
params.trees=8;
params.checks=64;
% params.cores=0; 
% setting the cores field to zero will automatically 
% use as many threads as cores available on the machine

samples1=euclidean_fps(s1_shape,num_samples);
samples2=euclidean_fps(s2_shape,num_samples);

V1=s1_shape.evecs(samples1,:);
V2=s2_shape.evecs(samples2,:);

C_fmap=s1_shape.evecs\s2_shape.evecs(T0,:);


for it=1:num_iters
    C=0;
    for s=1:Nf
        C=C+fs1{s}*C_fmap*fs2{s};
    end
%     figure;imagesc(C);
    if it<num_iters
%         T=knnsearch(V2*C',V1);
        T=flann_search(C*V2',V1',1,params);
        C_fmap=V1\V2(T,:);
    else
%         T=knnsearch(s2_shape.evecs*C',s1_shape.evecs);
        T=flann_search(C*s2_shape.evecs',s1_shape.evecs',1,params);
        T=T(:);
    end
end

end

% Euclidean farthest point sampling.
function idxs = euclidean_fps(surface,k,seed)

C = [surface.X surface.Y surface.Z];
nv = size(C,1);

if(nargin<3)
    idx = randi(nv,1);
else
    idx = seed;
end

dists = bsxfun(@minus,C,C(idx,:));
dists = sum(dists.^2,2);

idxs=zeros(k,1);

for i = 1:k
    maxi = find(dists == max(dists));
    maxi = maxi(1);
    idxs(i) = maxi;
    newdists = bsxfun(@minus,C,C(maxi,:));
    newdists = sum(newdists.^2,2);
    dists = min(dists,newdists);
end

% idx = idx(2:end);
end



