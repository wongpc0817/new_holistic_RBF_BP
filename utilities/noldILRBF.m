%Suppose L is the number of BP hidden layers
%We have features and labels, of the same configurations in centers.m
function network = noldILRBF(features,labels,trainingTarget,config)
%layers = [l1,l2,...,ln] is the layers structure
%W = [W1,W2,...,Wn] is the weight tensor:
%   each Wi is a weight matrix from BP hidden layer i-1 to i
%   defined by output = Wi * input vector
a=config.a;
b=config.b;
lr=config.lr;
mom=0;
network.model = "Hybrid";
mode=  config.alg;
network.mode=  mode;
layers=config.layers;
% first = true;
errorCount=1;
label = unique(labels);
ninput=size(features,2);
logbook=config.logbook;
syn_errorRecord=[];

noutput=size(label,2); %also number of classes
target = trainingTarget;
C=config.rbf_centers;
sigma=config.spreads;
network.numC = size(C,2);
t = randperm(size(features,2));
network.numC = size(C,2);
%Defining the network structure by 'layer'
for i = 1:(size(layers,2)+1)
    if i == 1
        layer(i,1) = layers(1);
        layer(i,2) = size(C,2);
    elseif i == size(layers,2)+1
        layer(i,1) = noutput;
        layer(i,2) = layer(i-1,1);
    else
        layer(i,1) = layers(i);
        layer(i,2) = layer(i-1,1);
    end
end

bound = max(layers);
bound = max([bound,noutput,size(C,2)]);
W = 2*rand(bound,bound,size(layer,1))-1;
delW=zeros(size(W));
del=zeros(bound,size(layer,1));
while true
    error = 0;
    for ix = 1:size(features,2)
        %L1 is the layer right after RBF
        L1 = RBF(features(:,ix),C,sigma);
        %Propagate BP
        input = zeros(bound,size(layer,1));
        input(1:size(L1,1),1) = 2*L1-1;
        for k = 1:size(layer,1)
            next = layer(k,1); current = layer(k,2);
            outputs(1:next,k) = W(1:next,1:current,k) * input(1:current,k);
            input(1:next,k+1)= a * tanh(b*outputs(1:next,k));
        end
        class(1:noutput,ix)=input(1:next,end);
        e = target(:,ix) - input(1:next,end);
        error = error + sum(e.^2)/2/ninput;
        %Back-propagate BP
        Delta = zeros(bound,size(layer,1));
        for k = size(layer,1):-1:1
            next = layer(k,1); current=layer(k,2);
            if k == size(layer,1)
                Delta(1:next,k) = e .* a.*b.* tanh1(b*outputs(1:next,k));
                for i =1:current
                    del(i,1)= dot(Delta(1:next,k),W(1:next,i,k));
                end
            elseif k == 1
                Delta(1:next,k)= a*b*tanh1(b*outputs(1:next,k)).* del(1:next,1);
            else
                Delta(1:next,k) = a*b*tanh1(b*outputs(1:next,k)).* del(1:next,1);
                for i =1:current
                    del(i,1)= sum(Delta(1:next,k).*W(1:next,i,k));
                end
            end
        end
        for k = 1:size(layer,1)
            next=layer(k,1);current =layer(k,2);
            delW(1:next,1:current,k) = delW(1:next,1:current,k)*mom + ...
                lr * Delta(1:next,k)*input(1:current,k)';
        end
        for l = 1:size(C,2)
            cDelta(1:size(features,1),l) = lr*2*dot(Delta(1:layer(1,1),1),W(1:layer(1,1),l,1))...
            *2.*L1(l,1)./sigma(l)^2 .*(features(:,ix)-C(:,l));
            sDelta(l) = lr* 2*dot(Delta(1:layer(1,1),1),W(1:layer(1,1),l,1))...
                *2.*L1(l,1)*distance(features(:,ix),C(:,l)).^2/sigma(l)^3;
        end
        W = W + delW;
        C = C + cDelta;
        sigma = sigma + sDelta;
            
    end
    errorRecord(errorCount)=error;
    errorCount=errorCount+1;
%     fprintf('error of round %d is %f \n',errorCount,error);
    if mod(errorCount,1)==0
        logbook.write("Error of round %d : %f \n",errorCount,error);
        fprintf('error of round %d is %f \n',errorCount,error);
        [~,cm,~,~]=confusion(target,class)
    end
    if config.to_syn
        network.W =W;
        network.layer=layer;
        network.C=C;
        network.bound=bound;
        network.sigma=sigma;
        network.a=a;
        network.b=b;
        outputs = newILRBFapplynetwork(config.old_trainingSet,network);
        syn_error = sum((config.old_trainingTarget-outputs).^2)/2/size(config.old_trainingSet,2);
        syn_errorRecord=[syn_errorRecord,syn_error];
    end
    
    if errorCount == config.epoch
            break
    end
    if errorCount > 10
        if abs(errorRecord(end)-errorRecord(end-1)) <= 5e-10 
            break
        end
        if error<0.0001
            break
        end
    end
end
network.W =W;
network.layer=layer;
network.C=C;
network.bound=bound;
network.sigma=sigma;
network.a=a;
network.b=b;
network.errorRecord=errorRecord;
network.random_seed=config.random_seed;
network.syn_errorRecord=syn_errorRecord;

end

%% Other Functions

function Y = RBF(x,C,sigma)
Y = zeros(size(C,2),1);
for i = 1:size(C,2)
    Y(i) = gaussian(x,C(:,i),sigma(i));
end
end
function y = gaussian(x,mean,sigma)
y = exp(-1/2 /sigma^2 *distance(x,mean)^2);
end
function y = tanh1(x)
y = sech(x).^2;
end
function d = distance(x1,x2)
d=norm(x1-x2,2);
end
function s =rbfpara(x,C)
clusters = size(C,2);
if clusters==0
    pause
end
id = zeros(1,size(x,2));
num=zeros(1,clusters);
spread=zeros(1,clusters);
for i = 1:size(x,2)
    temp = distance(x(:,i),C(:,1));
    id(i)=1;
    for j = 2:size(C,2)
        if temp > distance(x(:,i),C(:,j))
            temp = distance(x(:,i),C(:,j));
            id(i) = j;
        end
    end
end


for i = 1:size(x,2)
    for j=1:clusters
        if id(i)==j
            spread(1,j)=spread(1,j)+distance(x(:,i),C(:,j));
            num(j)=num(j)+1;
        end
    end
end
spread = spread./num+1e-8;
s=spread;
end

