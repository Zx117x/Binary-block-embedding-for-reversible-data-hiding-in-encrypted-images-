%% ������̣���Ƕ�����ݵ�ͼ����ԭ����ͼ��.(�����)
%B��Ϊ��ԭ���block�ļ���,phi��Ϊ���������payload

function [B,phi]=extractionWithRecover(img,s)
phi=[];
b=[];  %���ڱ�ʶ��Щ���Ĳ��ܴ���Ϣ��block��ͬʱ����ָ���Ϣʱ�����ҵ���Щblock
n=s*s;
[s1,s2]=size(img);

%% �ָ�goodblock.
for i=1:s1/s
    for j=1:s2/s
        %if i==8 && j==2
        %end
        B{i,j}=img((i-1)*s+1:i*s,(j-1)*s+1:j*s);
        a=(B{i,j}');   %n*1
        a=a(:)';             %1*n
        if(a(1:2)==[1,1])
            phi=[phi,a(3:n)];
            B{i,j}=ones(s);
        elseif(a(1:2)==[1,0])
            phi=[phi,a(3:n)];
            B{i,j}=zeros(s);
        elseif(a(1:2)==[0,1])
            [~,z,cb]=decodeBBE(B{i,j});
            phi=[phi,a(n-cb+1:n)];
            if(a(3)==1)
                B{i,j}=ones(s);
                B{i,j}(z)=0;
                B{i,j}=B{i,j}';
            else
                B{i,j}=zeros(s);
                B{i,j}(z)=1;
                B{i,j}=B{i,j}';
            end
        else
            b=[b,[i,j]];%b�а���badblockλ�õ�����
        end
    end
end
%% ��badblock��ǰ��λ�ָ�
for sizeofBadblock=1:length(b)/2     %b�а���badblock������
    i=b(2*sizeofBadblock-1); %�ҵ�badblock��λ��
    j=b(2*sizeofBadblock);
    B{i,j}(1,1)=phi(1);%payload��ǰ����Ԫ�ؼ��ǻ����ԭʼ����
    B{i,j}(1,2)=phi(2);
    phi=phi(3:end);%payloadʣ�µ�Ԫ�ؼ�Ϊm�������ݸ���phi
end



        