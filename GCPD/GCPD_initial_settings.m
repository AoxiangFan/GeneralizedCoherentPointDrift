function conf = GCPD_initial_settings(conf)

if ~isfield(conf,'MaxIter'), conf.MaxIter = 20; end;
if ~isfield(conf,'gamma'), conf.gamma = 0.9; end;
if ~isfield(conf,'beta'), conf.beta = 0; end;
if ~isfield(conf,'lambda'), conf.lambda = 10; end;
if ~isfield(conf,'theta'), conf.theta = 0.75; end;
if ~isfield(conf,'a'), conf.a = 0.05; end;
if ~isfield(conf,'ecr'), conf.ecr = 1e-5; end;
if ~isfield(conf,'minP'), conf.minP = 1e-5; end;