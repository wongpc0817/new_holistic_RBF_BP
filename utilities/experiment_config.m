% Configurations that remain unchanged
selection={'SGD'};
mom = [0];
beta1=[0.9];
beta2 = [0.999];
% lr = [1e-3];

alg='SGD';
a=1.2;
b=0.8;
config.a=a;
config.b=b;
saveRecord = true;
features.mode= alg;
config.alg=  alg;
config.layers =layer{1};
% config.afunc = afunc;
% config.centers = center;
features.layers = config.layers;
features.lr=lr;
features.mom = mom;
config.lr=lr;
config.sigma = sigma;
config.mom=mom;
config.epoch = Epochs;
config.beta1=beta1;
config.beta2=beta2;