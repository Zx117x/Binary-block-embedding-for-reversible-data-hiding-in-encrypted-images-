%% 用于得到block的类型，同时如果这个block是bad block，就提取前两个元素保存起来，用于payload的补充。
%所以这个函数 适合在获取完整的payload时使用
function [type, extra]=getType(img)
extra=[];  %用于保存bad block的前两个元素
% labelbitlength=[2,2,2,3,3];
% label=[0,0,0;1,1,0;1,0,0;0,1,1;0,1,0]; %label第i行 的前labelbitlength(i)个值代表了它的表示方法
s=size(img,1);
n=s*s;
% output=zeros(1,n);            %生成一维数组,将其reshape得到label+structure.
n0order=find(img'==0);  %因为matlab计数顺序是先从上到下，然后从左到右，所以这里提取索引时候要先转置
n1order=find(img'==1);
n0=length(n0order); n1=length(n1order);
m=min(n0,n1);                          %计算出图像的m,即n0和n1中较小的值。
q=zeros(1,m);
t=zeros(1,m);
[na,p]=getNaWithP(s);
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
if type==0
    extra=img(1,1:2);
end
