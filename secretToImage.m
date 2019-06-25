%% ����������ĵ�����������������ܹ���
% E -- Fig.4 �ĵ�һ����ͼ�Ľ��
% D -- Fig.4�ĵڶ�����ͼ�Ľ�������E��������������
% k -- ��k+1 �� 8 λ��LSB����ǰk��MSB��
% u -- �������ݵĳ���
% KIhat -- ����������
% KDhat -- ����������
% KShat -- ����������
% image -- Ҫ���ܵ�ͼ
% p -- Ҫ���ܵ�����
% s -- block�Ĵ�С��һ��Ϊ5
% KI -- �ַ�������ta����H(KI)
% KD -- �ַ�����ͬ�ϣ�һ��Կ��
% KS -- һ����Կ
% �÷�ʵ��
% image=imread('lena490.jpeg');
% p=[0 0 0 1 1 1 0 1 0 1 0 0 1 0 0 1];
% s=5;
% KI='12345';
% KD='23456';
% KS='34567';
% [E,D,k,u,KIhat,KDhat]=secretToImage(image,p,s,KI,KD);

% �����ǹ���
%����������Ƚ�LSBs���ݷ���MSBs��
%�Ѵ洢���ǲ���������ԭ����λ������Ϊ0��
%Ȼ������t�������
%�Ѵ洢���ǲ���������ԭ����λ������Ϊ0��
%Ȼ�����Cs
function [E,D,k,u,KIhat,KDhat,Cs]=secretToImage(image,p,s,KI,KD)
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
bitplaneofR=bitplaneofI;
bitplaneofE=bitplaneofI;
dst=zeros(M,N,8);     %dst ��������̬��ʵ��R��ƽ��ֽ�
%s=5;  %��ʾblock sizeΪ5*5
%�Ҷ�ͼ�ֽ�Ϊ�˸�λƽ��
for i=1:M
    for j=1:N
        result=bitget(I(i,j),8:-1:1);
        bitplaneofI(i,j,:)=result;
    end
end
dst=bitplaneofI;
%����ÿ��ƽ���������������
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
    Cs=sum(C(1:k)) %k����ƽ��ͼ��Ĵ洢������k��cb֮�ͣ�
end

payload = []; 
%����payload�����ݣ����������֣�һ������MSB�ϵ�badblock�����ݣ���һ������LSB�Ĳ������ݣ�Ҳ����Cs������

% badblock ��������BBE�㷨��ɣ��ʽ����´���ע�͵���ÿһ��ƽ����BBE�㷨�ж����ȴ洢�Լ���badblock��Ϣ��Ȼ���ٴ洢���ݡ�
% % �ȵõ� payload�� B���֣�B�洢��badblock�����ݣ�������������Ҫ
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

%�ٵõ�payload��M���֣���ȡ��ƽ���cs�����ݣ�
if Cs>0
    for i=k+1:8 %(8-k)����ƽ��
        content=bitplaneofI(:,:,i);
        content=content';
        content=content(:)';
        payload=[payload content];
    end
end
payload=payload(1:Cs);%��ƽ���cs�����ݸ�ֵ��payload

% payload = [b,payload];


%��cs������Ƕ�뵽MSB planesƽ����ȥ

for i=1:k
    if i==1
        payloaddata=payload(1:C(1));%��һ��λƽ���cb��
        pre=C(1);
    else
        payloaddata=payload(pre+1:pre+C(i));%��i��λƽ���cb��
        pre=pre+C(i);
    end
    dst(:,:,i)=BBE(bitplaneofI(:,:,i),s,payloaddata);
end

%payloadֻ����Cs�����ݣ���Щ����ԭ����λ��Ҫ���0
%(���Բ���0)
howmanyplanes=floor(Cs/(M*N)); %�����ж���λƽ�汻Ƕ�루floor����ȡ����
howmanyleft=Cs-M*N*howmanyplanes;
if howmanyplanes>0
    for i=k+1:k+howmanyplanes
        dst(:,:,i)=zeros(M,N); %��Щλƽ������
    end
end
if howmanyleft>0 %λƽ��������ʣ�����ص�
    mask=[zeros(1,howmanyleft) ones(1,M*N-howmanyleft)];%ʣ��λ���㣬����λ��1
    mask=reshape(mask,N,M);
    mask=mask';
    dst(:,:,k+howmanyplanes+1)=mask.*bitplaneofI(:,:,k+howmanyplanes+1);    %����LSB�����һЩ���ݲ��䣨�����ˣ�
end

%��������ͼƬ
for i=1:M
    for j=1:N
        R(i,j)=bin2dec_trans(dst(i,j,:));% �����ɵİ˸�λƽ�����ϳ�һ���Ҷ�ͼ��
    end
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
%payloadռ�õ�λ���ھ�����t�����֮������0��������½�����Ϊ0
%E1�ֳɰ˸�λƽ��
for i=1:M
    for j=1:N
        result=bitget(E1(i,j),8:-1:1);%R��E1��
        bitplaneofE(i,j,:)=result;
    end
end
%�������㣬����ͬ��
%(���Բ���0)
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
%������Cת����20λ���������У���ʹ��λ�滻����Ƕ�뵽ͼ��E��ǰ20�����ص�LSB�С�
%�����ڸ������������߿��Խ���������λǶ�뵽����ͼ��E�С�
%Csbit=bitget(Cs,20:-1:1);
%for i=1:20
 %   indexi=ceil(i/N);%������������
  %  indexj=i-(indexi-1)*M;%������������
   % bitplaneofE(indexi,indexj,8)=Csbit(i);%Ƕ�����ƽ��
%end
debug3=bitplaneofE;

%��������ͼƬ
for i=1:M
    for j=1:N
        E(i,j)=bin2dec_trans(bitplaneofE(i,j,:));  %�����E��E�ĵڶ�����̬
    end
end
r=Cs/(M*N)
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
if u>Cs
    disp   'u>Cs   wrong!!!';
end
[x0,y]=generateLSSParameter(KDhat);
x=LSS(x0,y,u);
phat=bitxor(round(x),p);


%֮ǰ��0����������Ҫ��Ϊp���ݵ�ռ����ˡ���������֮ǰ��anotherE����D������
%������������ƣ���phatǶ���ƽ��
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
%������Ϊu��������ռ�ĵط�һ�����Ὣǰ��Cs�����ݸ����ǵ���
if howmanyleft>0
    mask=[phat(M*N*howmanyplanes+1:end) ,zeros(1,M*N-howmanyleft)];
    mask=reshape(mask,N,M);
    mask=mask';
    bitplaneofD(:,:,k+howmanyplanes+1)=mask;
end

%�����anotherE����һ��ͼ��
for i=1:M
    for j=1:N
        D(i,j)=bin2dec_trans(bitplaneofD(i,j,:));%�����ɵİ˸�λƽ��D���ϳɻҶ�ͼD
    end
end
D=uint8(D);
%�����������ù�Կ���򣬴˴�������д��
% HE=[];
% KS=[];
% HKS=[];
% KShat=bitxor(HE,HKS);
% [x0,y]=generateLSSParameter(KShat);
% x=LSS(x0,y,M*N*8);


        
