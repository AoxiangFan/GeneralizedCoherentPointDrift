function T = callMWP(s1_name, s2_name, T0)

num_eigs = 100;
s1_shape = precompute_data(s1_name,num_eigs);
s2_shape = precompute_data(s2_name,num_eigs);

Nf = 5;
num_iters = 3; 
[T, C] = MWP(s1_shape,s2_shape,T0,Nf,num_iters);