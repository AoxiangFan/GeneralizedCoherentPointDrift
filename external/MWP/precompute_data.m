function shape=precompute_data(filename,num_eigs)
% read file
[V,F]=readOFF(filename);
shape.X=V(:,1);
shape.Y=V(:,2);
shape.Z=V(:,3);
shape.TRIV=F;

%compute laplacian and eigen-decompostion
W=cotmatrix(V,F);
W=-W;
A=massmatrix(V,F,'barycentric');

[evecs,evals]=eigs(W,A,num_eigs,'sm');
evals=diag(evals);
[evals,idx]=sort(evals);
evecs=evecs(:,idx);

shape.evecs=evecs;
shape.evals=evals;
shape.area=sum(full(diag(A)));
