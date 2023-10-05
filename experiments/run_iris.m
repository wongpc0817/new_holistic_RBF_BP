addpath('../utilities')
addpath('../data')

dataname = 'iris';
layers = {[30]};
LRs = 10.^[-2];


% datatable = readtable('data/iris/iris.data','FileType','text');
% datatable.Var5 = double(categorical(datatable.Var5));
% data = table2array(datatable);
% label = data(:,end)';
% data = data(:,1:end-1)';
% save('data/iris/data.mat',"data");
% save('data/iris/label.mat',"label");


exp_folder = sprintf('experiments/%s',dataname);

para.delta=1e-5;
T=10;
ConfSig=3;
parzen_ratio=1;
para.T=T;
normalise=false;

to_syn=true;

Epochs = 1e3;
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
