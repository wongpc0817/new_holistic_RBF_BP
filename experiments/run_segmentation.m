addpath('../utilities')
addpath('../data')

dataname = 'segmentation';
layers = {[30]};
LRs = 10.^[-2];

%  
% datatable = readtable('data/segmentation/segmentation.data','FileType','text');
% datatable.REGION_CENTROID_COL = double(categorical(datatable.REGION_CENTROID_COL));
% data = table2array(datatable);
% label = data(:,1)';
% data = data(:,2:end)';
% save('data/segmentation/data.mat',"data");
% save('data/segmentation/label.mat',"label");

normalise=false;

exp_folder = sprintf('experiments/%s',dataname);

para.delta=1e-3;
T=20;
ConfSig=3;
parzen_ratio=3;
para.T=T;
params_syn_samples.gamma=1.3;

to_syn=false;

Epochs = 1e5;
disp("mHybrid, not to_syn")
modelMethod="mHybrid";
main

disp("Hybrid, not to_syn")
modelMethod="Hybrid";
main


% to_syn=true;
% 
% disp("mHybrid, to_syn")
% modelMethod="mHybrid";
% main
% 
% disp("Hybrid, to_syn")
% modelMethod="Hybrid";
% main

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

