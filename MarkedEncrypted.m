function [D,k,u,r,KIhat,KDhat,Cs]=MarkedEncrypted(image,p,s,KI,KD);
I=image;
if ndims(I)==3
    I=rgb2gray(I);
end
[M,N]=size(I);
bitplaneofI=zeros(M,N,8); %��ʾһ��ͼ��8��bit plane
C=zeros(1,8);          %C��ÿһ��bitplane �Ĵ洢����
R=zeros(size(I));
E1=zeros(size(I));
E=zeros(size(I));      %E�ǰ�LSB��ֵ�洢��MSBs�еĽ��
D=E;                   %D�ǰ�secret data��ֵ�洢��E�еĽ��
dst=zeros(M,N,8);     %dst ��������̬��ʵ��R��ƽ��ֽ�
%s=5;  %��ʾblock sizeΪ5*5
%�Ҷ�ͼ�ֽ�Ϊ�˸�λƽ��
for i=1:M
    for j=1:N
        result=bitget(I(i,j),8:-1:1);
        bitplaneofI(i,j,:)=result;
    end
end

%����ÿ��ƽ���������������
for i=1:8
    C(i)=getImageCapacity(bitplaneofI(:,:,i),s);
end
if (C(1)<=0)
    k=0;
else 
    k=argmaxC2(C,M*N);
end
if k==0
    Cs=0;
else
    Cs=sum(C(1:k)); %k����ƽ��ͼ��Ĵ洢������k��cb֮�ͣ�
end

%����Ҫxor������
%��ʼ���õ�KIhat��KIhat=bitxor(H(I),H(KI));
% KI='12345';
HI=hash(I,'SHA-1');%HI=getSHA1(I);%
HI=hex2dec(HI);
HI=dec2bin(HI,160);
HI=logical(HI-48);
HKI=hash(KI,'SHA-1');%HKI=getSHA1(KI);%
HKI=hex2dec(HKI);
HKI=dec2bin(HKI,160);
HKI=logical(HKI-48);
KIhat=bitxor(HI,HKI);
E=uint8(E);

% marked encrypted image
% p=[0 0 0 1 1 1 0 1 0 1 0 0 1 0 0 1]; % �����secret data������Ϊu
Hp=hash(p,'SHA-1');%Hp=getSHA1(p);%  һ������SHA-1�㷨��160λ����������
Hp=hex2dec(Hp);
Hp=dec2bin(Hp,160);
Hp=logical(Hp-48);

% KD='23456';
HKD=hash(KD,'SHA-1'); % HKD=getSHA1(KD);%һ������SHA-1�㷨��160λ����������
HKD=hex2dec(HKD);
HKD=dec2bin(HKD,160);
HKD=logical(HKD-48);

KDhat=bitxor(Hp,HKD);

u=length(p);% u ����С��Cs
r=u/(M*N);
if u>Cs
    disp   'u>Cs   wrong!!!';
end
[x0,y]=generateLSSParameter(KDhat);
x=LSS(x0,y,u);
phat=bitxor(round(x),p);
bitplaneofD=bitplaneofI;
howmanyplanes=floor(u/(M*N));
howmanyleft=u-M*N*howmanyplanes;
if howmanyplanes>0
    for i=k+1:k+howmanyplanes
        if i==k+1
            phatdata=phat(1:M*N);
            pre=M*N;
        else
            phatdata=phat(pre+1,pre+M*N);
        phatdata=reshape(phatdata,N,M);
        phatdata=phatdata';
        bitplaneofD(:,:,i)=phatdata;
        end
    end
end
%������Ϊu��������ռ�ĵط�һ�����Ὣǰ��Cs�����ݸ����ǵ���
if howmanyleft>0
   mask1=[phat(M*N*howmanyplanes+1:end),zeros(1,M*N-howmanyleft)];
   mask1=reshape(mask1,N,M);
   mask1=mask1';
   mask2=[zeros(1,howmanyleft),ones(1,M*N-howmanyleft)];
   mask2=reshape(mask2,N,M);
  mask2=mask2';
 bitplaneofD(:,:,k+howmanyplanes+1)=mask1+mask2.*bitplaneofI(:,:,k+howmanyplanes+1);%��һ�����û���洢������
end
%�����anotherE����һ��ͼ��
for i=1:M
    for j=1:N
        D(i,j)=bin2dec_trans(bitplaneofD(i,j,:));%�����ɵİ˸�λƽ��D���ϳɻҶ�ͼD
    end
end
D=uint8(D);

