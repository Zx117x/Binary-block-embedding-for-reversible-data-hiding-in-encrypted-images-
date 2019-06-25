function x=LSS(x0,y,N)
x=zeros(1,N);
for i=1:N
    if i==1
        x(i)=mod((y*x0*(1-x0))+(4-y)*sin(pi*x0)/4,1);
    else
        x(i)=mod((y*x(i-1)*(1-x(i-1)))+(4-y)*sin(pi*x(i-1))/4,1);
    end
end