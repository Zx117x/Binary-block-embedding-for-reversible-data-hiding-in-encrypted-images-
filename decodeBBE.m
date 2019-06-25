%% ����ÿ��s1*s2��С��ͼ�Σ��õ�p��z��cb����Ϣ
%p�ǵ�blockΪ3��4��ʱ����3���������ڱ�ʾ���ͣ���p���������ڱ�ʾ覴õ�����m��ռ��λ����z��ÿ����ָ����ÿһ��覴õ��λ�á�
function [p,z,cb]=decodeBBE(img)    %% be sure that img belong to GOOD-III or GOOD-IV
s=size(img,1);
n=s*s; %���ﶼ��5*5��
a=img';
a=a(:);   %�������
% if(a(1:3)==[0,1,1])   %% GOOD-III
    [~,p]=getNaWithP(s);
    bin_m=a(3+1:3+p);
    m=bin2dec_trans(bin_m);
    q=zeros(1,m);
    t=zeros(1,m);
    z=zeros(1,m);
    presumindexlength=0;
    for i=1:m
        if i==1
            q(1)=ceil(log2(n+1));        %get bit length
            bin_t=a(3+p+1:3+p+q(1));    %get distance
            t(1)=bin2dec_trans(bin_t);
            z(1)=t(1);
        else
            presumindexlength = presumindexlength+q(i-1);
            q(i)=ceil(log2(n+1-z(i-1)));
            bin_t=a(3+p+presumindexlength+1:3+p+presumindexlength+q(i));
            t(i)=bin2dec_trans(bin_t);
            z(i)=sum(t);
        end
    end
    cb=n-3-p-sum(q);
% end 
    