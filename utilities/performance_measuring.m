% Measuring performance after training
errorRecord = network.errorRecord;
class=zeros(size(outputs));
Rlabels=zeros(size(old_trainingLabel));
for i = 1:size(outputs,2)
    class(:,i) = saturate(outputs(:,i));
    [~,ind] = max(class(:,i));
    Rlabels(i) = ind-1;
end

clclass = cl(class);
cltarget = cl(old_trainingTarget);
[~,ind] = find(clclass-cltarget~=0);


%performance measures
disp('confusion matrix for the original dataset')
[~,cm,~,~]=confusion(old_trainingTarget,class);


tp = 0;
fp = 0;
fn = 0;
tn = 0;
accuracy = 0;
recall = 0;
precision = 0;
F1score = 0;
classes = size(cm,1);
for k = 1:classes
tp = cm(k,k);
fp = (sum(cm(:,k),'all') - cm(k,k));
fn = (sum(cm(k,:),'all')-cm(k,k));
tn = (sum(cm,'all')-tp-fp-fn);
accuracy = accuracy + (tp+tn)/(tp+fp+tn+fn)/classes;
if tp == 0
    recall = recall + 0;
    precision = precision + 0;
    F1score=  F1score + 0;
else
    recall = recall + tp/(tp+fn)/classes;
    precision = precision + tp/(tp+fp)/classes;
    F1score = F1score + 2*(tp/(tp+fn))*(tp/(tp+fp))...
        / ((tp/(tp+fn))+(tp/(tp+fp)))/classes;
end
end

Acc = Acc + accuracy/trial;
Re = Re + recall / trial;
Pr = Pr + precision/ trial;
F1 = F1 + F1score / trial;


disp('confusion matrix for the testing set')
class=zeros(size(test_outputs));
Rlabels=zeros(size(testingLabel));
for i = 1:size(test_outputs,2)
    class(:,i) = saturate(test_outputs(:,i));
    [~,ind] = max(class(:,i));
    Rlabels(i) = ind-1;
end
clclass = cl(class);
cltarget = cl(testingTarget);
[~,ind] = find(clclass-cltarget~=0);

[~,cm,~,~]=confusion(testingTarget,class);


tp = 0;
fp = 0;
fn = 0;
tn = 0;
test_accuracy = 0;
test_recall = 0;
test_precision = 0;
test_F1score = 0;
classes = size(cm,1);
for k = 1:classes
tp = cm(k,k);
fp = (sum(cm(:,k),'all') - cm(k,k));
fn = (sum(cm(k,:),'all')-cm(k,k));
tn = (sum(cm,'all')-tp-fp-fn);
test_accuracy = test_accuracy + (tp+tn)/(tp+fp+tn+fn)/classes;
if tp == 0
    test_recall = test_recall + 0;
    test_precision = test_precision + 0;
    test_F1score=  test_F1score + 0;
else
    test_recall = test_recall + tp/(tp+fn)/classes;
    test_precision = test_precision + tp/(tp+fp)/classes;
    test_F1score = test_F1score + 2*(tp/(tp+fn))*(tp/(tp+fp))...
        / ((tp/(tp+fn))+(tp/(tp+fp)))/classes;
end
end

test_Acc = test_Acc + test_accuracy/trial;
test_Re = test_Re + test_recall / trial;
test_Pr = test_Pr + test_precision/ trial;
test_1 = test_F1 + test_F1score / trial;



% if errorRecord(end) <= minError
if test_accuracy >= maxAcc
minRecord = errorRecord;
minlr = lr;
minsigma=sigma;
minbeta1=beta1;
minbeta2=beta2;
mincm = cm;
minmom = mom;
minT = T;
end

errors = 1-accuracy;



function Y = cl(X)
Y = zeros(1,size(X,2));
for i = 1:size(X,2)
    [~,ind]=max(X(:,i));
    Y(i) = ind;
end
end