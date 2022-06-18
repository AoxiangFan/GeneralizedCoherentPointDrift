%{

Zoomout Algorithm with different options for pointwise conversion

Inputs: 

T12: Initial map from Source to Target
B1_all: Source Basis functions (number of points x number of eigenvectors)
B2_all: Target Basis Function  (number of points x number of eigenvectors)
numiterAlgo: number of Zoomout iterations (aliter, you can change the
parameters on line onwards.
type: 'nn' or 'sinkhorn'

Outputs:
T12: p2p from Source to Target
T21: p2p from Target to Source

%}
function [T12,T21] = zoomout_refine(B1_all, B2_all, T12, numiterAlgo, type)

%% Default Parameters
para.num_samples = 5e2;
para.k_init = 20;
para.k_final = 100;
para.k_step = round((para.k_final - para.k_init)/(numiterAlgo));


%% Zoomout
if nargout > 2, all_T12 = {}; all_C21 = {}; end

for k = para.k_init : para.k_step : para.k_final
    
    B1 = B1_all(:, 1:k);
    B2 = B2_all(:, 1:k);
    C21 = B1\B2(T12,:);
    switch type
        
        case 'nn'
            
            T12 = knnsearch(B2*C21', B1);
            T21 = knnsearch(B1, B2*C21');
            
        case 'sinkhorn'
            
            [~,T12,T21] = fast_sinkhorn_filter(B2*C21', B1);
            
    end
            
    if nargout > 2, all_T12{end+1} = T12; all_C21{end+1} = C21;end

end

end