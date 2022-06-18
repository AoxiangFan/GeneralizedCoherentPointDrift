function [G] = gsp_compute_fourier_basis(G,param)
%GSP_COMPUTE_FOURIER_BASIS Compute the fourier basis of the graph G
%   Usage:  G = gsp_compute_fourier_basis(G);
%           G = gsp_compute_fourier_basis(G,param);
%
%   Input parameters:
%         G          : Graph structure (or cell array of graph structure) 
%         param      : structure of optional parameters
%   Output parameters:
%         G          : Graph structure (or cell array of graph structure)
%
%   'gsp_compute_fourier_basis(G)' computes a full eigendecomposition of the graph
%   Laplacian G.L:
%
%      L = U Lambda U* 
%
%   where Lambda is a diagonal matrix of the Laplacian eigenvalues. 
%   G.e is a column vector of length G.N containing the Laplacian
%   eigenvalues. The function will store the basis U, the eigenvalues
%   e, the maximum eigenvalue lmax and G.mu the coherence of the
%   Fourier basis into the structure G.
% 
%   Example:
%
%       N = 50;
%       G = gsp_sensor(N);
%       G = gsp_compute_fourier_basis(G);
%       gsp_plot_signal(G,G.U(:,2));
% 
%   References:
%     F. R. K. Chung. Spectral Graph Theory. Vol. 92 of the CBMS Regional
%     Conference Series in Mathematics, American Mathematical Society, 1997.
%     

% Author : David I Shuman, Nathanael Perraudin, Li Fan
% Testing: test_operators

if nargin < 2
    param = struct;
end


if numel(G)>1
    Ng = numel(G);
    for ii = 1:Ng
       G{ii} = gsp_compute_fourier_basis(G{ii}, param);
    end     
    return;
end

if ~isfield(param,'verbose'), param.verbose = 1; end
if ~isfield(param,'force_svd'), param.force_svd = 0; end




if gsp_check_fourier(G)
    if param.verbose
        warning(['Laplacian eigenvalues or eigenvectors ',...
            'are already associated with this graph']);
    end
end

if G.N > 15000
    if param.verbose
        error('Too big matrix to perform full eigenvalue decomposition.'); 
    end
end

if G.N > 3000
    if param.verbose
        warning(['Performing full eigendecomposition ',...
            'of a large matrix may take some time...']); 
    end
end
    
if isfield(G,'type') &&  strcmp(G.type,'ring')==1 % && mod(G.N,2)==0 
    U = dftmtx(G.N)/sqrt(G.N);
    E = (2-2*cos(2*pi*(0:G.N-1)'/G.N));
    inds = gsp_classic2graph_eig_order( G.N );
%     [G.E, inds]=sort(E,'ascend');
    G.e = E(inds);
    if strcmp(G.lap_type,'normalized')
        G.e = G.e/2;
    end
    
    G.U = U(:,inds);
else
    if ~isfield(G,'L')
        error('Graph Laplacian is not provided.');
    end
    [G.U, G.e] = gsp_full_eigen(G.L,param);
end

G.lmax=max(G.e);

if isfield(G,'Gm')
    G = gsp_compute_oose_fourier_basis(G);
end



G.mu = max(abs(G.U(:)));

end


function [U,E] = gsp_full_eigen(L, param) 
%GSP_FULL_EIGEN Compute and order the eigen decomposition of L

    % Compute and all eigenvalues and eigenvectors
    if param.force_svd
        [eigenvectors,eigenvalues,~]=svd(full(L+L')/2);
    else   
        try
            [eigenvectors,eigenvalues]=eig(full(L+L')/2);
        catch
            [eigenvectors,eigenvalues,~]=svd(full(L+L')/2);
        end
    end

    % Sort eigenvectors and eigenvalues
    [E,inds] = sort(diag(eigenvalues),'ascend');
    eigenvectors=eigenvectors(:,inds);
    
    % Set first component of each eigenvector to be nonnegative
    signs=sign(eigenvectors(1,:));
    signs(signs==0)=1;
    U = eigenvectors*diag(signs);
end

function D = dftmtx(n)

n = signal.internal.sigcasttofloat(n,'double','dftmtx','N',...
  'allownumeric');

D = fft(eye(n));

end

