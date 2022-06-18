function [Pt1, P1, PX, E] = figtreeRecoveryDistribution(X, Y, sigma2, outlier)

[N, D] = size(X);
M = size(Y,1);
ksig = -2.0*sigma2;
outlier_tmp = (outlier*M*(-ksig*pi)^(D/2))/((1-outlier)*N);

h = sqrt(2.0*sigma2);
sp = figtree( Y', h, ones(M,1), X', 1e-6, 4);
sp = sp + outlier_tmp;
Pt1 = (1 - outlier_tmp./sp);
P1 = figtree( X', h, 1./sp, Y', 1e-6, 4);
PX = figtree( X', h, X./repmat(sp,[1,D]), Y', 1e-6, 4);
E = sum(-log(sp)) + D*N*log(sigma2)/2;
end

        
        
