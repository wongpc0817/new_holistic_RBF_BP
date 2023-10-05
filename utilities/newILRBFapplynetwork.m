function outputs = newILRBFapplynetwork(features,network)
C=network.C;
W=network.W;
layer=network.layer;
bound=network.bound;
noutput=layer(end,1);
outputs=zeros(noutput,size(features,2));
sigma=network.sigma;
a=network.a;
b=network.b;
for ix = 1:size(features,2)
    %L1 is the layer right after RBF
    L1 = RBF(features(:,ix),C,sigma);
    %Propagate BP
    input = zeros(bound,size(layer,1));
    input(1:size(L1,1),1) = 2*L1-1;
    for k = 1:size(layer,1)
        next = layer(k,1);
        current = layer(k,2);
        Output(1:next,k) = W(1:next,1:current,k) * input(1:current,k);
        input(1:next,k+1)= a * tanh(b*Output(1:next,k));
    end
    outputs(:,ix)=input(1:noutput,end);
end
end

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