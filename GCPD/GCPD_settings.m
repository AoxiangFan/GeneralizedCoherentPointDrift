function conf = GCPD_settings(conf)

if ~isfield(conf,'MaxIter'), conf.MaxIter = 30; end;
if ~isfield(conf,'tol'), conf.tol = 1e-5; end;
if ~isfield(conf,'outliers'), conf.outliers = 0.1; end;
if ~isfield(conf,'lambda'), conf.lambda = 10; end;
