%% ���ڵõ�block�����ͣ�ͬʱ������block��bad block������ȡǰ����Ԫ�ر�������������payload�Ĳ��䡣
%����������� �ʺ��ڻ�ȡ������payloadʱʹ��
function [type, extra]=getType(img)
extra=[];  %���ڱ���bad block��ǰ����Ԫ��
% labelbitlength=[2,2,2,3,3];
% label=[0,0,0;1,1,0;1,0,0;0,1,1;0,1,0]; %label��i�� ��ǰlabelbitlength(i)��ֵ���������ı�ʾ����
s=size(img,1);
n=s*s;
% output=zeros(1,n);            %����һά����,����reshape�õ�label+structure.
n0order=find(img'==0);  %��Ϊmatlab����˳�����ȴ��ϵ��£�Ȼ������ң�����������ȡ����ʱ��Ҫ��ת��
n1order=find(img'==1);
n0=length(n0order); n1=length(n1order);
m=min(n0,n1);                          %�����ͼ���m,��n0��n1�н�С��ֵ��
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
