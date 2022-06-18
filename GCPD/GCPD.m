function [T, C, P1] = GCPD(X, Y, U, e, C, conf)

max_it = conf.MaxIter;
tol = conf.tol;
outliers = conf.outliers;
lambda = conf.lambda;

[N, D] = size(X);[M, D] = size(Y);
% Initialization
T = Y + U*C;
sigma2 = 1e-4;

K = spdiags(e, 0, length(e), length(e));
iter = 0; ntol = tol + 10; L = 0;
while (iter < max_it) && (ntol > tol) && (sigma2 > 10*eps)
    L_old = L;
	% E-step
    [Pt1, P1, PX, L] = figtreeRecoveryDistribution(X, T, sigma2, outliers);
    ntol = abs((L - L_old)/L);
    dP = spdiags(P1, 0, M, M);
	% M-step
    C = (U'*dP*U + lambda*sigma2*K)\(U'*PX - U'*dP*Y);
    T = Y + U*C;
    Np = sum(P1);
    sigma2 = abs((sum(sum(X.^2.*repmat(Pt1,1,D)))+sum(sum(T.^2.*repmat(P1,1,D))) -2*trace(PX'*T)) /(Np*D));
    iter = iter + 1;
end



