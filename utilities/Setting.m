

logbook=Logger(sprintf("%s.txt",dataname));
logbook.newline();

if ~isequal(dataname,'sparse')
    filename_data = sprintf("../data/%s/data.mat",dataname);
    filename_label = sprintf("../data/%s/label.mat",dataname);
    trainingSet=importdata(filename_data);
    trainingLabel=importdata(filename_label);
    if ~exist(sprintf("%s",dataname),'dir')
        mkdir(sprintf("%s",dataname))
    end
else
    if ~exist('../data/sparse','dir')
        mkdir(sprintf('../data/sparse'))
    end
    if ~exist('sparse_num','var') || ~exist('sparse_dim','var')
        disp('Sparse variables not yet defined.')
        return 
    end
    filename_data= sprintf('../data/sparse/data_%d_%d.mat',sparse_num,sparse_dim);
    filename_label= sprintf('../data/sparse/label_%d_%d.mat',sparse_num,sparse_dim);
    if ~exist(filename_data,'file') || ~exist(filename_label,'file')
        [data,label]=gen_data(sparse_num,sparse_dim);
        save(filename_data,'data')
        save(filename_label,'label')
    end
    trainingSet = importdata(filename_data);
    trainingLabel = importdata(filename_label);
end
logbook.write("Finished extracted the data for %s",dataname);
logbook.write("Defining RBF clusters...")


% para.delta=delta;
% if to_syn
%     params_syn_samples=importdata(sprintf("params_syn_samples/param_syn_samples_%d_%d_%f_%f_%f.mat",dim,num,delta,T,parzen_ratio));
%     rbf_centers=params_syn_samples.rbf_centers;
%     spreads= params_syn_samples.spreads;
%     syn_samples=importdata(sprintf("syn_samples/syn_samples_%d_%d_%f_%f_%f.mat",dim,num,delta,T,parzen_ratio));
%     syn_classes=importdata(sprintf("syn_samples/syn_classes_%d_%d_%f_%f_%f.mat",dim,num,delta,T,parzen_ratio));
%     trainingSet = [trainingSet, syn_samples];
%     trainingLabel = [trainingLabel, syn_classes];
% 
% end
num_data = size(trainingSet,2);
n = floor(size(trainingSet,2)/10);
p = randperm(size(trainingSet,2));
trainingSet = trainingSet(:,p);
trainingLabel = trainingLabel(:,p);
testingSet = trainingSet(:,end-n:end);
testingLabel = trainingLabel(:,end-n:end);
trainingSet = trainingSet(:,1:end-n);
trainingLabel = trainingLabel(:,1:end-n);
fprintf("Original Size of Data: %d. Training: %d ; Testing: %d \n", num_data,...
    size(trainingLabel,2),size(testingLabel,2))
rng(1,'twister')



filename_rbf_center=sprintf("%s/centers_T%d_delta%d.mat",dataname,para.T,log10(para.delta));
filename_rbf_spreads=sprintf("%s/spreads_T%d_delta%d.mat",dataname,para.T,log10(para.delta));
filename_rbf_labelInd = sprintf("%s/labelId_T%d_delta%d.mat",dataname,para.T,log10(para.delta));
if exist(filename_rbf_center,'file') && exist(filename_rbf_spreads,'file')
    rbf_centers = importdata(filename_rbf_center);
    spreads = importdata(filename_rbf_spreads);
    labelInd = importdata(filename_rbf_labelInd);
else
    [rbf_centers,spreads,labelInd] = find_centers(trainingSet,trainingLabel,para);
    save(filename_rbf_labelInd,'labelInd')
    save(filename_rbf_spreads,'spreads')
    save(filename_rbf_center,'rbf_centers')

end

config.rbf_centers=rbf_centers;
config.spreads=spreads;
logbook.write("Finished finding the %d RBF clusters, with delta=%f, T=%f",size(rbf_centers,2),para.delta,para.T);
fprintf("Finished finding the %d RBF clusters, with delta=%f, T=%f\n",size(rbf_centers,2),para.delta,para.T)
old_trainingSet=trainingSet;
old_trainingLabel=trainingLabel;
output_syn_samples=0;
if ~exist(sprintf("%s",dataname),'dir')
    mkdir(sprintf("%s",dataname))
end
if to_syn
    params_syn_samples.rbf_centers=rbf_centers;
    params_syn_samples.spreads=spreads;
    params_syn_samples.labelInd=labelInd;
    syn_num=100;
    params_syn_samples.num_syn_samples=syn_num;
    
    logbook.write("Defining Parzen Window")
    params_syn_samples.parzen_windows=spreads./parzen_ratio;
    logbook.write("Generating synethetic samples")
    [syn_samples, syn_classes] = gen_syn_samples(trainingSet,trainingLabel, params_syn_samples);
    output_syn_samples=size(syn_samples,2);
    if ~exist(sprintf("../experiments/%s",dataname),'dir')
        mkdir(dataname)
    end
    save(sprintf('%s/samples_T%d_delta%d_ps%d.mat',dataname,log10(para.T),log10(para.delta),...
        parzen_ratio),'syn_samples');
    logbook.write("Finished generating %d synthetic samples",size(syn_samples,2));
    fprintf("RBF: %d, Syn:%d\n",size(rbf_centers,2),size(syn_samples,2));
    trainingSet = [trainingSet, syn_samples];
    trainingLabel = [trainingLabel, syn_classes];
end


% if dim==2 && toDraw
%     color={'red','blue'};
%     hold on
%     for i = [0,1]
%         ind=trainingLabel==i;
%         scatter(trainingSet(1,ind),trainingSet(2,ind),color{i+1})
%         if to_syn
%             ind=syn_classes==i;
%             if ~ind
%                 scatter(syn_samples(1,ind),syn_samples(2,ind),'*',color{i+1})
%             end
%         end
%     end
%     for i = 1:size(rbf_centers,2)
%         scatter(rbf_centers(1,:),rbf_centers(2,:),'square')
%         drawCir(rbf_centers(:,i),spreads(i))
%         if to_syn
%             drawCir(rbf_centers(:,i),params_syn_samples.parzen_windows(i),'green')
% 
%         end
%     end
%     hold off
% 
% %     pause
% end

