% Pre-training Setup
% Normalisation
Mn=zeros(size(trainingSet,1),1);
Sd = zeros(size(trainingSet,1),1);
for i = 1:size(trainingSet,1)
    Mn(i,1) = mean(trainingSet(i,:));
    Sd(i,1) = std(trainingSet(i,:));
    if Sd(i,1)==0
        Sd(i,1)=1;
    end
end
if normalise
    trainingSet= (trainingSet-Mn)./Sd;
    old_trainingSet = (old_trainingSet-Mn)./Sd;
    testingSet = (testingSet-Mn)./Sd;
    config.Mn = Mn;
    config.Sd = Sd;
end
Lab = unique(trainingLabel);
trainingTarget = [];
old_trainingTarget=[];
testingTarget=[];
for i = Lab
    trainingTarget = [trainingTarget;trainingLabel==i];
    old_trainingTarget=[old_trainingTarget;old_trainingLabel==i];
    testingTarget = [testingTarget; testingLabel==i];
end
features.trainingInput=  trainingSet;
features.trainingTarget = trainingTarget;
minError=inf;
maxAcc=0;
first=true;
% completion = size(trainingSet,1);
% logbook.write("Progress: %d / %d\n",trialCount,completion);
trialCount = trialCount+1;
features.T = T;
features.sigma = sigma;
features.epoch = Epochs;