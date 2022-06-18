function [M,N]=truncate_evecs(M,N)
min_evals=min([M.evals(end),N.evals(end)]);
r1=sum(M.evals<=min_evals);
M.evals=M.evals(1:r1);
M.evecs=M.evecs(:,1:r1);

r2=sum(N.evals<=min_evals);
N.evals=N.evals(1:r2);
N.evecs=N.evecs(:,1:r2);


