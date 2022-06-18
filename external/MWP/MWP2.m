function [T,C]=MWP2(s1_shape,s2_shape,k,T0,Nf,num_iters)
% matching: s1_shape --> s2_shape
s1_shape.evecs = s1_shape.evecs(:,1:k);
s1_shape.evals = s1_shape.evals(1:k);
s2_shape.evecs = s2_shape.evecs(:,1:k);
s2_shape.evals = s2_shape.evals(1:k);

% prepare filters, functions from gspbox:https://github.com/epfl-lts2/gspbox 
g=gsp_design_meyer(s1_shape.evals(end),Nf);
ref_g=gsp_design_meyer(s2_shape.evals(end),Nf);

% g=gsp_design_simple_tf(s1_shape.evals(end),Nf);
% ref_g=gsp_design_simple_tf(s2_shape.evals(end),Nf);

ref_k=size(s2_shape.evals,1);
k=size(s1_shape.evals,1);

T=T0;

for it=1:num_iters
    C=0;
    % C_fmap=s1_shape.evecs'*s1_shape.A*s2_shape.evecs(T,:);
    C_fmap=s1_shape.evecs\s2_shape.evecs(T,:);
    
    for s=1:Nf
        ref_fs=sparse(1:ref_k,1:ref_k,ref_g{s}(s2_shape.evals));
        fs=sparse(1:k,1:k,g{s}(s1_shape.evals));
        C=C+fs*C_fmap*ref_fs;
        %     figure;imagesc(C);
    end
    
    T=knnsearch(s2_shape.evecs*C',s1_shape.evecs);% cpu version
    
    % gpu knnsearch
    % T=knnsearch(gpuArray(s2_shape.evecs*C'),gpuArray(s1_shape.evecs));%
    
    T=gather(T);
    T=T(:); 
    
end