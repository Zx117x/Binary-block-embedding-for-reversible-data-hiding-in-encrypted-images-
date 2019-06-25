%% 这个便是论文第三章所讲的正向加密过程
% E -- Fig.4 的第一个框图的结果
% D -- Fig.4的第二个框图的结果，相比E加入了秘密数据
% k -- 把k+1 到 8 位的LSB放入前k个MSB中
% u -- 秘密数据的长度
% KIhat -- 如论文所述
% KDhat -- 如论文所述
% KShat -- 如论文所述
% image -- 要加密的图
% p -- 要加密的数据
% s -- block的大小，一般为5
% KI -- 字符串，由ta生成H(KI)
% KD -- 字符串，同上，一个钥匙
% KS -- 一个公钥
% 用法实例
% image=imread('lena490.jpeg');
% p=[0 0 0 1 1 1 0 1 0 1 0 0 1 0 0 1];
% s=5;
% KI='12345';
% KD='23456';
% KS='34567';
% [E,D,k,u,KIhat,KDhat]=secretToImage(image,p,s,KI,KD);

% 以下是过程
%这个过程是先将LSBs数据放入MSBs中
%把存储的那部分数据在原来的位置上置为0，
%然后将其与t进行异或
%把存储的那部分数据在原来的位置上置为0，
%然后存入Cs
function [E,D,k,u,KIhat,KDhat,Cs]=secretToImage(image,p,s,KI,KD)
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
bitplaneofR=bitplaneofI;
bitplaneofE=bitplaneofI;
dst=zeros(M,N,8);     %dst 的最终形态其实是R的平面分解
%s=5;  %表示block size为5*5
%灰度图分解为八个位平面
for i=1:M
    for j=1:N
        result=bitget(I(i,j),8:-1:1);
        bitplaneofI(i,j,:)=result;
    end
end
dst=bitplaneofI;
%计算每个平面的容纳数据能力
for i=1:8
    C(i)=getImageCapacity(bitplaneofI(:,:,i),s)
end
if (C(1)<=0)
    k=0;
else 
    k=argmaxC2(C,M*N)
end
if k==0
    Cs=0;
else
    Cs=sum(C(1:k)) %k个高平面图像的存储能力（k个cb之和）
end

payload = []; 
%生成payload的内容，包含两部分，一部分是MSB上的badblock的内容，另一部分是LSB的部分数据，也就是Cs个数据

% badblock 的内容由BBE算法完成，故将以下代码注释掉。每一个平面在BBE算法中都会先存储自己的badblock信息，然后再存储数据。
% % 先得到 payload的 B部分，B存储了badblock的内容，其索引并不重要
% b=[];
% for ii=1:k
%     for i=1:M/s
%         for j=1:N/s
%             eachplane=bitplaneofI(:,:,ii);
%             B{i,j}=eachplane((i-1)*s+1:i*s,(j-1)*s+1:j*s);
%             [~, extra]=getType(B{i,j});
%             b=[b,extra];
%         end
%     end
% end

%再得到payload的M部分（读取低平面的cs个数据）
if Cs>0
    for i=k+1:8 %(8-k)个低平面
        content=bitplaneofI(:,:,i);
        content=content';
        content=content(:)';
        payload=[payload content];
    end
end
payload=payload(1:Cs);%低平面的cs个数据赋值给payload

% payload = [b,payload];


%将cs个数据嵌入到MSB planes平面中去

for i=1:k
    if i==1
        payloaddata=payload(1:C(1));%第一个位平面的cb数
        pre=C(1);
    else
        payloaddata=payload(pre+1:pre+C(i));%第i个位平面的cb数
        pre=pre+C(i);
    end
    dst(:,:,i)=BBE(bitplaneofI(:,:,i),s,payloaddata);
end

%payload只用了Cs个数据，这些数据原来的位置要变成0
%(可以不置0)
howmanyplanes=floor(Cs/(M*N)); %计算有多少位平面被嵌入（floor向下取整）
howmanyleft=Cs-M*N*howmanyplanes;
if howmanyplanes>0
    for i=k+1:k+howmanyplanes
        dst(:,:,i)=zeros(M,N); %这些位平面置零
    end
end
if howmanyleft>0 %位平面置零后的剩余像素点
    mask=[zeros(1,howmanyleft) ones(1,M*N-howmanyleft)];%剩余位置零，其余位置1
    mask=reshape(mask,N,M);
    mask=mask';
    dst(:,:,k+howmanyplanes+1)=mask.*bitplaneofI(:,:,k+howmanyplanes+1);    %控制LSB的最后一些数据不变（矩阵点乘）
end

%重新生成图片
for i=1:M
    for j=1:N
        R(i,j)=bin2dec_trans(dst(i,j,:));% 将生成的八个位平面整合成一个灰度图。
    end
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
[x0,y]=generateLSSParameter(KIhat);
x=LSS(x0,y,M*N);
t=round(mod(x*2^50,255));
t=reshape(t,N,M);
t=t';

for i=1:M
    for j=1:N
        E1(i,j)=bitxor(R(i,j),t(i,j));
    end
end
%payload占用的位置在经过与t的异或之后不再是0，这里，重新将其置为0
%E1分成八个位平面
for i=1:M
    for j=1:N
        result=bitget(E1(i,j),8:-1:1);%R改E1；
        bitplaneofE(i,j,:)=result;
    end
end
%重新置零，步骤同上
%(可以不置0)
debug1=bitplaneofE;

howmanyplanes=floor(Cs/(M*N));
howmanyleft=Cs-M*N*howmanyplanes;
if howmanyplanes>0
    for i=k+1:k+howmanyplanes
        bitplaneofE(:,:,i)=zeros(M,N);
    end
end
if howmanyleft>0
    mask=[zeros(1,howmanyleft) ones(1,M*N-howmanyleft)];
    mask=reshape(mask,N,M);
    mask=mask';
    bitplaneofE(:,:,k+howmanyplanes+1)=mask.*bitplaneofE(:,:,k+howmanyplanes+1);
end
debug2=bitplaneofE;
%将容量C转换成20位二进制序列，并使用位替换将其嵌入到图像E的前20个像素的LSB中。
%这用于告诉数据隐藏者可以将多少秘密位嵌入到加密图像E中。
%Csbit=bitget(Cs,20:-1:1);
%for i=1:20
 %   indexi=ceil(i/N);%计算所需行数
  %  indexj=i-(indexi-1)*M;%计算所需列数
   % bitplaneofE(indexi,indexj,8)=Csbit(i);%嵌入最低平面
%end
debug3=bitplaneofE;

%重新生成图片
for i=1:M
    for j=1:N
        E(i,j)=bin2dec_trans(bitplaneofE(i,j,:));  %这里的E是E的第二个形态
    end
end
r=Cs/(M*N)
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
if u>Cs
    disp   'u>Cs   wrong!!!';
end
[x0,y]=generateLSSParameter(KDhat);
x=LSS(x0,y,u);
phat=bitxor(round(x),p);


%之前清0的数据现在要成为p数据的占领地了。还是利用之前的anotherE来做D的生成
%和置零操作类似，将phat嵌入低平面
bitplaneofD=bitplaneofE;
howmanyplanes=floor(u/(M*N));
howmanyleft=u-M*N*howmanyplanes;
if howmanyplanes>0
    for i=k+1:k+howmanyplanes
        if i==k+1
            phatdata=phat(1:M*N);
             phatdata=reshape(phatdata,N,M);
        phatdata=phatdata';
        bitplaneofD(:,:,i)=phatdata;
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
    mask=[phat(M*N*howmanyplanes+1:end) ,zeros(1,M*N-howmanyleft)];
    mask=reshape(mask,N,M);
    mask=mask';
    bitplaneofD(:,:,k+howmanyplanes+1)=mask;
end

%把这个anotherE生成一幅图像
for i=1:M
    for j=1:N
        D(i,j)=bin2dec_trans(bitplaneofD(i,j,:));%将生成的八个位平面D整合成灰度图D
    end
end
D=uint8(D);
%接下来是利用公钥乱序，此处不再书写。
% HE=[];
% KS=[];
% HKS=[];
% KShat=bitxor(HE,HKS);
% [x0,y]=generateLSSParameter(KShat);
% x=LSS(x0,y,M*N*8);


        
