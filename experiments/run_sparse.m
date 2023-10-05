addpath('../utilities')
addpath('../data')
addpath('../data/sparse')
dataname = 'sparse';


exp_folder = sprintf('experiments/%s',dataname);
sparse_dim=10;
sparse_num=100;
layers = {[30]};
LRs = 10.^[-2];

para.delta=1e-5;
T=10;
ConfSig=3;
parzen_ratio=5;
Epochs = 1e3;
para.T=T;
to_syn=false;
normalise=false;

disp("mHybrid, not to_syn")
modelMethod="mHybrid";
main

disp("Hybrid, not to_syn")
modelMethod="Hybrid";
main


to_syn=true;

disp("mHybrid, to_syn")
modelMethod="mHybrid";
main

disp("Hybrid, to_syn")
modelMethod="Hybrid";
main




% for T=[1,50,200]
%     for ConSig=[3,1,0.1]
%         for parzen_ratio=[1,3,5]
%             modelMethod="mHybrid";
%             to_syn=true;
%             para.T=T;
%             main
%             
%             modelMethod="Hybrid";
%             to_syn=false;
%             
%             main
%         end
%     end
% end
% 
