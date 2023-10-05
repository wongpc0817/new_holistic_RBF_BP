% Need to define the width (sigma) and distance weighting factor (T in potential),delta in icenters

function [C,sigmas,labelInd] = find_centers(features,labels,para)
lambda = para.lambda;
alpha = para.alpha;
delta = para.delta;
NEpoch = para.NEpoch;
beta = para.beta;
T= para.T;
sigmas = [];
C = []; 
labelInd = [];
Cclass = [];
for ix = unique(labels)
    sigma = para.sigma;
    smin = 0.000001;
    dmin = inf;
    Ind = (labels == ix);
    S = features(:,Ind);
    [mps, x] = maxpotential(S,T);
    ps = densities(S,T);
    M = para.M;
    Mcount = 0;
    while mps > delta      
        [X,Ind] = inside(features,labels,x,sigma,lambda);
        Mi = nnz(Ind==ix);
        Mj = size(Ind,2) - Mi;
        Xi = X(:,(Ind~=ix));        
        F = zeros(size(X,1),1);
        for k = 1:Mj
            F = F + force(alpha,Xi(:,k),x);
        end
        x = x + F;
        for k =1:Mj
            dmin = min([dmin,dist(x,Xi(:,k))/beta]);
        end
        [X,Ind] = inside(features,labels,x,sigma,lambda);
        Mi1 = nnz(Ind==ix);
        Mj1 = size(Ind,2) - Mi1;
        Xi = X(:,(Ind~=ix));
        while Mj1~=0 && Mcount <= NEpoch
            if Mi1 >= Mi && Mj1 <= Mj
                Mi = Mi1; 
                Mj = Mj1;
                F = 0;
                for k = 1:Mj
                    F = F + 1/M * force(alpha,Xi(:,k),x);
                end
                x = x + F;
                Mcount = Mcount+1;
                [X,Ind] = inside(features,labels,x,sigma,lambda);
                Mi1 = nnz(Ind==ix);
                Mj1 = size(Ind,2) - Mi1;
                Xi = X(:,(Ind~=ix));
            end
            [X,Ind] = inside(features,labels,x,sigma,lambda);
            Mi1 = nnz(Ind==ix);
            Mj1 = size(Ind,2) - Mi1;
            Xi = X(:,(Ind~=ix));
            if Mj1 ~= 0
                for k =1:Mj1
                    dmin = min([dmin,dist(x,Xi(:,k))/beta]);
                end
                sigma = max([dmin,smin]);
                break
            end
            break
            
        end
        C = [C x];
        labelInd=[labelInd ix];
        sigmas=[sigmas sigma];
        ps = newpotentials(S,mps,x,ps,sigmas(end));
        [mps,xt]= max(ps);
        x = S(:,xt);
    end
end
end

function [y,Ind] = inside(S,label,x,sigma,lambda)
y = [];
Ind = [];
for i = 1:size(S,2)
    if dist(x,S(:,i)) < sigma * lambda
        y = [y S(:,i)];
        Ind = [Ind label(1,i)];
    end
end
end

function f = force(alpha,x,mu)
f = exp(-alpha*dist(x,mu))*(x-mu)/(norm(x-mu,2));
end
function c = icenters(S,sigma,T)
%Find centers for each sample set of the same label.
%c is the set of centers [c1,c2,...,cn];
c = [];
counter = 1;
[mps,x] = maxpotential(S,T);
ps = densities(S,T);
delta = 0.1; %letter
% delta = 0.8;
% delta = 0.7;
% delta = 0.1; %sonar
% delta = 0.01;


first = true;
while true
    if mps > delta

        c = [c x];
    else
        break
    end
    % while true
    %     if first
    %         if mps > delta
    %             c=  [c x];
    %             first = false;
    %         else
    %             delta = delta*0.9;
    %             continue
    %         end
    %     else
    %         if mps > delta
    %             c = [c x];
    %         else
    %             break;
    %         end
    %     end
    ps = newpotentials(S,mps,x,ps,sigma);
    [mps,ind] = max(ps);
    x = S(:,ind);
end


end
function d = dist(x1,x2)
d=norm(x1-x2,2);
end
function gamma = potential(x1,x2,T)
gamma = 1/(1+T * dist(x1,x2)^2);
end
function y = gaussian(x,mean,sigma)
y = exp(-1/2 /sigma.^2 *dist(x,mean)^2);
end
function p = density(x,S,T)
%Column vector x is the baseline sample in S;
%S is the set of sample of the same label as x
%  configured by S = [x1 x2 ... xn];
p=0;
for i = 1:size(S,2)
    if x == S(:,i)
        continue
    end
    p = p + potential(x,S(:,i),T);
end
end
function ps = densities(S,T)
%ps is the set of densities of samples that belong to the same label.
ps = [];
for i =1:size(S,2)
    ps(1,i) = density(S(:,i),S,T);
end
end
function [mps,x] = maxpotential(S,T)
%gets the sample x out of the set of samples S with the maximum density
%mps.
[mps,index] = max(densities(S,T));
x = S(:,index);
end
function ps = newpotentials(S,mps,x,ps,sigma)
%x is the center of the sample set S, with the width sigma
%ps is the set of potentials after eliminating the central potential.
temp = zeros(1,size(S,2));
for i = 1:size(S,2)
    temp(1,i) = gaussian(S(:,i),x,sigma);
end
ps = ps - mps * temp;
end

