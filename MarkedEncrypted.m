function [D,k,u,r,KIhat,KDhat,Cs]=MarkedEncrypted(image,p,s,KI,KD);
I=image;
if ndims(I)==3
    I=rgb2gray(I);
end
[M,N]=size(I);
bitplaneofI=zeros(M,N,8); %表示一个图的8个bit plane
C=zeros(1,8);          %C是每一个bitplane 的存储能力
R=zeros(size(I));
E1=zeros(size(I));
E=zeros(size(I));      %E是把LSB的值存储在MSBs中的结果
D=E;                   %D是把secret data的值存储在E中的结果
dst=zeros(M,N,8);     %dst 的最终形态其实是R的平面分解
%s=5;  %表示block size为5*5
%灰度图分解为八个位平面
for i=1:M
    for j=1:N
        result=bitget(I(i,j),8:-1:1);
        bitplaneofI(i,j,:)=result;
    end
end

%计算每个平面的容纳数据能力
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
    Cs=sum(C(1:k)); %k个高平面图像的存储能力（k个cb之和）
end

%生成要xor的数据
%初始化用的KIhat，KIhat=bitxor(H(I),H(KI));
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
% p=[0 0 0 1 1 1 0 1 0 1 0 0 1 0 0 1]; % 这个是secret data，长度为u
Hp=hash(p,'SHA-1');%Hp=getSHA1(p);%  一个经过SHA-1算法的160位二进制数字
Hp=hex2dec(Hp);
Hp=dec2bin(Hp,160);
Hp=logical(Hp-48);

% KD='23456';
HKD=hash(KD,'SHA-1'); % HKD=getSHA1(KD);%一个经过SHA-1算法的160位二进制数字
HKD=hex2dec(HKD);
HKD=dec2bin(HKD,160);
HKD=logical(HKD-48);

KDhat=bitxor(Hp,HKD);

u=length(p);% u 必须小于Cs
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
%这里认为u个数据所占的地方一定不会将前面Cs的数据给覆盖掉。
if howmanyleft>0
   mask1=[phat(M*N*howmanyplanes+1:end),zeros(1,M*N-howmanyleft)];
   mask1=reshape(mask1,N,M);
   mask1=mask1';
   mask2=[zeros(1,howmanyleft),ones(1,M*N-howmanyleft)];
   mask2=reshape(mask2,N,M);
  mask2=mask2';
 bitplaneofD(:,:,k+howmanyplanes+1)=mask1+mask2.*bitplaneofI(:,:,k+howmanyplanes+1);%后一项保留了没被存储的数据
end
%把这个anotherE生成一幅图像
for i=1:M
    for j=1:N
        D(i,j)=bin2dec_trans(bitplaneofD(i,j,:));%将生成的八个位平面D整合成灰度图D
    end
end
D=uint8(D);

