%% 根据块的内容，得出cb，label+structure。
%这个是BBE第一步出来的结果，完成了原block类型，结构信息在新blcok的表示
function [cb,output]=typeWithStructure(binaryimage)
% labelbitlength=[2,2,2,3,3];
% label=[0,0,0;1,1,0;1,0,0;0,1,1;0,1,0]; %label第i行 的前labelbitlength(i)个值代表了它的表示方法
s=size(binaryimage,1);
n=s*s;
output=zeros(1,n);            %生成一维数组,将其reshape得到label+structure.
n0order=find(binaryimage'==0);  %因为matlab计数顺序是先从上到下，然后从左到右，所以这里提取索引时候要先转置
n1order=find(binaryimage'==1);
n0=length(n0order); n1=length(n1order);
m=min(n0,n1);                          %计算出图像的m,即n0和n1中较小的值。
q=zeros(1,m);
t=zeros(1,m);
[na,p]=getNaWithP(s);
%第一步，判断好坏块
if m>na
    type = 0;
elseif (m==n0 && n0==0)
    type = 1;   
elseif (m==n1 && n1==0)
    type = 2;  
elseif n1>n0
    type = 3;
    z=n0order;
else
    type = 4;
    z=n1order;
end
%第二步，判填充标志位
if (type==0)     %填充标志位，获得cb，获得bad block的前两个数字
    cb=-2;
    output(1:2)=[0,0];
elseif (type==1 || type==2) %填充标志位，获得cb，没有m
    cb=n-2;
    if(type == 1)
        output(1:2)=[1,1];
    else
        output(1:2)=[1,0];
    end
elseif(type==3 || type==4)  %填充标志位，获得cb，同时将m个点的结构信息也写入块中。
    if(type == 3)
        output(1:3)=[0,1,1];
    else
        output(1:3)=[0,1,0];
    end
    %第三步，嵌入结构信息与位置信息（对于3，4类型）
    output(3+1:3+p)=bitget(m,p:-1:1); %%p为m的位数，从高到低取p位
    presumindexlength=0;
    for i=1:m
        if i==1
            q(1)=ceil(log2(n+1)); %q1为存储索引值z1的位数，ceil，趋于无穷大取整；
            t(1)=z(1);
            output(3+p+1:3+p+q(1))=bitget(z(1),q(1):-1:1);%将z1的值嵌入
        else
            presumindexlength = presumindexlength+q(i-1);
            q(i)=ceil(log2(n+1-z(i-1)));
            t(i)=z(i)-z(i-1);
            output(3+p+presumindexlength+1:3+p+presumindexlength+q(i))=bitget(t(i),q(i):-1:1);
        end
    end
    cb=n-3-p-sum(q);
end
%最后一步，输出output
output=reshape(output,s,s);%将1＊n的output重组成s＊s的矩阵
output=output'; %因为reshape先列后行，所以要转置
if(type==0) % 坏块
    output=binaryimage;
    output(1,1)=0;
    output(1,2)=0;
end