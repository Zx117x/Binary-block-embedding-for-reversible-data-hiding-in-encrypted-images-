%% ���ݿ�����ݣ��ó�cb��label+structure��
%�����BBE��һ�������Ľ���������ԭblock���ͣ��ṹ��Ϣ����blcok�ı�ʾ
function [cb,output]=typeWithStructure(binaryimage)
% labelbitlength=[2,2,2,3,3];
% label=[0,0,0;1,1,0;1,0,0;0,1,1;0,1,0]; %label��i�� ��ǰlabelbitlength(i)��ֵ���������ı�ʾ����
s=size(binaryimage,1);
n=s*s;
output=zeros(1,n);            %����һά����,����reshape�õ�label+structure.
n0order=find(binaryimage'==0);  %��Ϊmatlab����˳�����ȴ��ϵ��£�Ȼ������ң�����������ȡ����ʱ��Ҫ��ת��
n1order=find(binaryimage'==1);
n0=length(n0order); n1=length(n1order);
m=min(n0,n1);                          %�����ͼ���m,��n0��n1�н�С��ֵ��
q=zeros(1,m);
t=zeros(1,m);
[na,p]=getNaWithP(s);
%��һ�����жϺû���
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
%�ڶ�����������־λ
if (type==0)     %����־λ�����cb�����bad block��ǰ��������
    cb=-2;
    output(1:2)=[0,0];
elseif (type==1 || type==2) %����־λ�����cb��û��m
    cb=n-2;
    if(type == 1)
        output(1:2)=[1,1];
    else
        output(1:2)=[1,0];
    end
elseif(type==3 || type==4)  %����־λ�����cb��ͬʱ��m����Ľṹ��ϢҲд����С�
    if(type == 3)
        output(1:3)=[0,1,1];
    else
        output(1:3)=[0,1,0];
    end
    %��������Ƕ��ṹ��Ϣ��λ����Ϣ������3��4���ͣ�
    output(3+1:3+p)=bitget(m,p:-1:1); %%pΪm��λ�����Ӹߵ���ȡpλ
    presumindexlength=0;
    for i=1:m
        if i==1
            q(1)=ceil(log2(n+1)); %q1Ϊ�洢����ֵz1��λ����ceil�����������ȡ����
            t(1)=z(1);
            output(3+p+1:3+p+q(1))=bitget(z(1),q(1):-1:1);%��z1��ֵǶ��
        else
            presumindexlength = presumindexlength+q(i-1);
            q(i)=ceil(log2(n+1-z(i-1)));
            t(i)=z(i)-z(i-1);
            output(3+p+presumindexlength+1:3+p+presumindexlength+q(i))=bitget(t(i),q(i):-1:1);
        end
    end
    cb=n-3-p-sum(q);
end
%���һ�������output
output=reshape(output,s,s);%��1��n��output�����s��s�ľ���
output=output'; %��Ϊreshape���к��У�����Ҫת��
if(type==0) % ����
    output=binaryimage;
    output(1,1)=0;
    output(1,2)=0;
end