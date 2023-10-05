addpath('../utilities')
addpath('../data')

dataname = 'winequality-white';
layers = {[50]};
LRs = 10.^[-3];


datatable = readtable('data/winequality-white/winequality-white.csv','FileType','text');
datatable.quality = double(categorical(datatable.quality));
data = table2array(datatable);
label = data(:,end)';
data = data(:,1:end-1)';
save('data/winequality-white/data.mat',"data");
save('data/winequality-white/label.mat',"label");



% exp_folder = sprintf('experiments/%s',dataname);

% para.delta=1e-1;
% T=10;
% ConfSig=5;
% parzen_ratio=3;
% para.T=T;
% Epochs = 1e4;
% to_syn=true;
% params_syn_samples.gamma=1.3;
% 
% disp("mHybrid, not to_syn")
% modelMethod="mHybrid";
% main
% 
% disp("Hybrid, not to_syn")
% modelMethod="Hybrid";
% main
% 
% to_syn=false;
% 
% disp("mHybrid, to_syn")
% modelMethod="mHybrid";
% main
% 
% disp("Hybrid, to_syn")
% modelMethod="Hybrid";
% main
% 
% 
% 
% 
% % for T=[1,50,200]
% %     for ConSig=[3,1,0.1]
% %         for parzen_ratio=[1,3,5]
% %             modelMethod="mHybrid";
% %             to_syn=true;
% %             para.T=T;
% %             main
% %             
% %             modelMethod="Hybrid";
% %             to_syn=false;
% %             
% %             main
% %         end
% %     end
% % end
% % 
