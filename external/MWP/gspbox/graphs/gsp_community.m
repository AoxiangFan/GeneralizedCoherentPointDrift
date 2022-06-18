function [G] = gsp_community(n, param)
%GSP_COMMUNITY Create a community graph
%   Usage: G = gsp_community(N);
%          G = gsp_community();
%          G = gsp_community(N, param );
%
%   Input parameters
%       N     : Number of nodes (default 256)
%       param : Structure of optional parameters
%   Output parameters
%       G     : Graph
%
%   This function create a 2 dimentional random sensor graph. All the
%   coordonates are between 0 and 1.
%   
%   *param* is an optional structure with the following fields
%
%   * *param.Nc* : Number of communities (default round(sqrt(N)/2) )
%   * *param.verbose*: display parameter - 0 no log - 1 display the errors
%     (default 1) 
%   * *param.com_sizes* : size of the communities. The sum of the sizes has
%     to be equal to $N$. Leave this field empty if you want random sizes.
%   * *param.min_comm* : Minimum size of the community 
%     (default: round(N / param.Nc / 3) )
%   * *param.min_deg*: Minimum degree of each nodes (default:
%     round(param.min_comm / 2)) (NOT WORKING YET!)
%   * *param.size_ratio*: ratio between radius of world and radius of
%     communities (default 1)
%   * *param.world_density*  probability of a random edge between any pair
%     of nodes (default 1/N)
%
%
%   Example:::
%
%          G = gsp_community();
%          paramplot.show_edges = 1;
%          gsp_plot_graph(G,paramplot);
%
%

% Author: Vassilis Kalofolias, Nathanael Perraudin, Johan Paratte
% Date: March 2014
% Testing: test_graphs


% TODO: This function has to be revisited

if nargin < 2
   param = struct;
end
if nargin < 1
   n = 256; 
end

if isfield(param, 'com_sizes')
    if sum(param.com_sizes) ~= n
        error(['GSP_COMMUNITY: The sum of the community sizes has ',...
            'to be equal to N']);
    end
    param.Nc = numel(param.com_sizes);
else
    if ~isfield(param, 'Nc'), param.Nc = round(sqrt(n)/2); end
    param.com_sizes = []; 
end
if ~isfield(param, 'min_comm'), param.min_comm = round(n / param.Nc / 3); end
if ~isfield(param, 'min_deg'), param.min_deg = round(param.min_comm/2); end
if ~isfield(param, 'verbose'), param.verbose = 1; end
if ~isfield(param, 'param.size_ratio'), param.size_ratio = 1; end     
if ~isfield(param, 'world_density'), param.world_density = 1/n; end     



if isempty(param.com_sizes)
    com_lims = sort(randperm(n - (param.min_comm-1) * param.Nc - 1, param.Nc-1), 'ascend');
    com_lims = com_lims + cumsum((param.min_comm-1) * ones(size(com_lims)));
    com_lims = [0, com_lims, n];
    param.com_sizes = diff(com_lims);
else
    com_lims = [0, cumsum(param.com_sizes)];
end

if param.verbose > 2
    X = zeros(10000, param.Nc + 1);
    %pick randomly param.Nc-1 points to cut the rows in communtities:
    for ii=1:10000
        com_lims_temp = sort(randperm(n - (param.min_comm-1) * param.Nc - 1, param.Nc-1), 'ascend');
        com_lims_temp = com_lims_temp + cumsum((param.min_comm-1) * ones(size(com_lims_temp)));
        X(ii,:) = [0, com_lims_temp, n];
    end
    dX = diff(X')';
    for ii=1:param.Nc; figure;hist(dX(:,ii), 100); title('histogram of row community size'); end
    clear X com_lims_temp
end


rad_world = param.size_ratio * sqrt(n);
com_coords = rad_world * [-cos(2*pi*(1:param.Nc)/param.Nc)', sin(2*pi*(1:param.Nc)/param.Nc)'];

G.coords = ones(n, 2);

% create uniformly random points in the unit disc
for ii = 1:n
    % use rejection sampling to sample from a unit disc (probability = pi/4)
    while norm(G.coords(ii, :)) >= 1/2
        % sample from the square and reject anything outside the circle
        G.coords(ii, :) = [rand-.5, rand-.5];
    end
end

% add the offset for each node depending on which community it belongs to
info.node_com = zeros(n, 1);
for ii = 1:(param.Nc)
    com_size = param.com_sizes(ii);
    rad_com = sqrt(com_size);

    node_ind = (com_lims(ii) + 1) : com_lims(ii+1);
    G.coords(node_ind, :) = bsxfun(@plus, rad_com * G.coords(node_ind, :), com_coords(ii, :));
    info.node_com(node_ind) = ii;
end
    


% TODO: this can (and should to prevent overlap) be done for each community separately!
% D = gsp_distanz(G.coords');
% %R = rmse_mv(G.coords')*sqrt(2);
% %W = graph_k_NN(exp(-D.^2), param.min_deg);
% W = exp(-D.^2);
% W(W<1e-3) = 0;

%TODO: this could be more sophisticated (e.g. one sigma for communities,
%one sigma for inter-community connections, exp(-d^2/sigma) weights!
% W = W + abs(sprandsym(N, param.world_density));
% W = double(abs(W) > 0);
% G.W = sparse(W);

% % Fast (and scalable) implementation of the above
% kdt = KDTreeSearcher(G.coords, 'distance', 'euclidean');
% epsilon = sqrt(-log(1e-3));
% [NN, D] = rangesearch(kdt, G.coords, epsilon, 'distance', 'euclidean' );
% 
% %Counting non-zero elements
% count = 0;
% for ii = 1:N
%    count = count + length(NN{ii}) - 1; 
% end
% 
% spi = zeros(count,1);
% spj = zeros(count,1);
% spv = ones(count,1);
% start = 1;
% 
% 
% % Fill the 3-col values with [i, j, exp(-d(i,j)^2 / sigma)]
% for ii = 1:N
%     len = length(NN{ii}) - 1;
%     spi(start:start+len-1) = repmat(ii, len, 1);
%     spj(start:start+len-1) = NN{ii}(2:end)';
% %     spv(start:start+len-1) = exp(-D{ii}(2:end).^2);
%     start = start + len;
% end
% 
% W = sparse(spi, spj, spv, N, N);

paramnn.rescale = 0;
paramnn.center = 0;
paramnn.type = 'radius';
epsilon = sqrt(-log(1e-3));
paramnn.epsilon = epsilon;

[spi, spj] = gsp_nn_distanz(G.coords',G.coords',paramnn);
W = sparse(spi, spj, ones(size(spi)), n, n);
W = (W+W')/2;
% Adding the sparse rand connections
W = W + abs(sprandsym(n, param.world_density));
W = double(abs(W) > 0);

% get rid of self loops:
W(1:n+1:end) = 0;

G.W = W;

G.type = 'community';

% return additional info about the communities
info.com_lims = com_lims;
info.com_coords = com_coords;
info.com_sizes = param.com_sizes;

G.info = info;
G = gsp_graph_default_parameters( G );


end





