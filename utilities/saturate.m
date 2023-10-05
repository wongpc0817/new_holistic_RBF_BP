function Y=saturate(output)
Y=zeros(size(output))-1;
for i =1:size(output,2)
    x = output(:,i);
    [~,ind] = max(x);
    Y(ind(1),i)=1;
end
end