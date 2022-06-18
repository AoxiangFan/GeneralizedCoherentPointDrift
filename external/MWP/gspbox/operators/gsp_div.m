function di = gsp_div(G,s)
%GSP_DIV Graph divergence
%   Usage: di = gsp_div(G,s)
%   
%   Input parameters:
%       G   : Graph structure
%       s   : Signal living on the edges
%   Output parameters:
%       di  : Divergence
%
%   The divergence operator is the adjoint of the gradient operator. For
%   graphs, the divergence of a signal residing on edges gives a signal
%   living on the nodes. The result should be such that:: 
%
%        gsp_div(G,gsp_grad(G,s)) = G.L * s,
%
%   Before using this function, you need to call the function:: 
%
%           G = gsp_adj2vec(G)
%
%   See also: gsp_grad gsp_adj2vec
%


% Author: Nathanael Perraudin, Vassilis Kalofolias
% Date  : 5 August 2014
% Testing: test_operators



if size(s,1) ~= G.Ne
    error('Signal size not equal to number of edges');
end

if ~isfield(G,'Diff')
    warning(['GSP_DIV: To optimize speed, please run',...
        ' G = gsp_adj2vec(G) before this function']);
    G = gsp_adj2vec(G);
end

di = G.Diff'*double(s);

if isa(s,'single')
   di = single(di); 
end

end


%% Old Vassilis comment


% Old Vassilis code
% k = size(s,2);
% 
% % What happens with loops? (diagonal elements of G, A)
% %
% % I think both div and grad is zero on the diagonal elements. But then is
% % it consistent with the Laplacian? (it has to be div(grad(s)) = 2*L*s) for
% % a signal s defined on the vertices.
% 
% div = zeros(G.N, k);
% 
% for ii = 1 : k
%     tmp = sparse(G.v_in, G.v_out, s(:,ii), G.N,G.N);
%     tmp = tril(tmp,1) - tril(tmp,1)';
% 
%     % the divergence 
%     div(:,ii) = sum(tmp.* sqrt(G.W), 2);
% end


% div = GRAPH_DIV(S, A, ki, kj)
%
%Divergence of signal residing on edges of a graph. The output resides on
%nodes. The result should be such that 
%   graph_div(graph_grad(s)) = L * s,
%where L is the graph Laplacian associated with the adjacency matrix A.
%
%OUTPUT:
%   div: divergence of columns of S defined on vertices
%
%INPUTS:
%   S: signal defined on edges e
%   A: adjacency matrix (weighted or not)
%   ki, kj: indices of edges by graph_adj2vec
%
%
% TODO: does not handle normalized Laplacian case!! 
%
%
%note that the norm of the operator is
%
% ||D||^2_2 = ||L||_2, where G is the divergence operator and L is the
% Laplacian used.
%
%
%see also: graph_grad, graph_adj2vec, sgwt_laplacian
%
%code author: Vassilis Kalofolias
%date: Aug 2013
