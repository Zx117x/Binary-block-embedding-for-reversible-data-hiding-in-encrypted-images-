function k=argmaxC2(C,MN)
for i=1:8  
       sumC=sum(C(1:i));  
       
    if sumC<(8-i)*MN && C(i)>0
        k=i;
    else
        k1=i;
    end
end

%if i>6
    %k=4;
%else
 %   k=i-1;
%end