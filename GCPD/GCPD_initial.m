function [T, C, index] = GCPD_initial(X, Y, U, e, conf)

% Initialization
gamma = conf.gamma;
lambda = conf.lambda;
theta = conf.theta;
a = conf.a;
MaxIter = conf.MaxIter;
ecr = conf.ecr;
minP = conf.minP;

K = spdiags(e, 0, length(e), length(e));

[N, D] = size(Y); 
k = size(U, 2);
C = zeros(k, 3);
P = speye(N);
T = Y;
iter = 1; tecr = 1; E = 1;
sigma2 = sum(sum((X - Y).^2))/(N*D);


while (iter < MaxIter) && (abs(tecr) > ecr) && (sigma2 > 1e-8) 
    % E-step.
    E_old = E;
    [P1, E] = get_P(X, T, sigma2 ,gamma, a);  
    P1 = max(P1, minP);
    P = spdiags(P1, 0, N, N);
    
    E = E + lambda/2*trace(C'*K*C);
    tecr = (E - E_old)/E;
    
    % M-step.
    C = (U'*P*U + lambda*sigma2*K)\(U'*P*X - U'*P*Y);
    
    
    T = Y + U*C;
    V = X - T;
    
    sigma2 = trace(V'*P*V)/(D*trace(P));
    numcorr = length(find(P > theta));
    gamma = numcorr/N;
    if gamma > 0.95, gamma = 0.95; end
    if gamma < 0.05, gamma = 0.05; end
    iter = iter + 1;
end
index = find(diag(P) > theta);

function [P, E]=get_P(X, Tx, sigma2 ,gamma, a)
% GET_P estimates the posterior probability and part of the energy.

D = size(X, 2);
temp1 = exp(-sum((X-Tx).^2,2)/(2*sigma2));
temp2 = (2*pi*sigma2)^(D/2)*(1-gamma)/(gamma*a);
P=temp1./(temp1+temp2);
E=P'*sum((X-Tx).^2,2)/(2*sigma2)+sum(P)*log(sigma2)*D/2 - log(gamma)*sum(P) - log(1-gamma)*sum(1-P);
