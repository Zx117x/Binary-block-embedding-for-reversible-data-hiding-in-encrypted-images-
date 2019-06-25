%% 从加密图像中根据原始图和KDhat等信息获取加密进去的数据
% p -- 之前加密进去的数据
% originalimg -- 原始图像
% scrabledimg -- 由正向加密产生的D
% kshat -- 没用，随便填
% u -- 加密数据长度
% KDhat --密钥
% 使用示例
% p=dataextraction(image,D,'12',16,KDhat)

% 由于不再使用公钥乱序，这里的scrabledimg就是前面的D，kshat也没什么用了,u还是要保证不要把Cs这个数据覆盖掉，也就是u的数据不要存在最后一个平面上去
function p=dataextraction(scrabledimg,u,KDhat,k)
 %I=(originalimg);
 %if ndims(I)==3
  %  I=rgb2gray(I);
 %end
%[M,N]=size(I);
%bitplane=zeros(M,N,8); %表示一个原图的8个bit plane
%bitplaneofD=zeros(M,N,8);
 %C=zeros(1,8);
%E=zeros(size(I));
s=5;  %表示block size为5*5

%分成八个位平面
%for i=1:M
 %   for j=1:N
  %       result=bitget(I(i,j),8:-1:1);
  %       bitplane(i,j,:)=result;
  %   end
 %end

%计算每个平面的容纳数据能力,同时得到k
 %for i=1:8
   %  C(i)=getImageCapacity(bitplane(:,:,i),s);
 %end
 %if (C(1)<=0)
  %   k=0;
 %else
  %   k=argmaxC2(C,M*N);
 %end

 %if k==0
  %   Cs=0;
 %else
  %   Cs=sum(C(1:k));
 %end

%根据原图就可以知道存在论文中D图像的数据的位置在哪里，现在.....blabla就根据KShat还原出了D.那我们直接找到D的存储秘密数据那部分就行了
%现在我们可以根据原图知道数据存储的第一个面就是第D的第k+1个面
D=scrabledimg;
[M,N]=size(D);
bitplaneofD=zeros(M,N,8);%这里就省去了解密公钥的过程
%D分成八个位平面
for i=1:M
    for j=1:N
        result=bitget(D(i,j),8:-1:1);
        bitplaneofD(i,j,:)=result;
    end
end

%根据u来判断这些数据(其实是phat)存在哪个面上
phat=[];
howmanyplanes=floor(u/(M*N));
howmanyleft=u-M*N*howmanyplanes;
if howmanyplanes > 0
    for i=k+1:k+howmanyplanes
        planei=bitplaneofD(:,:,i);
        planei=planei';
        data=planei(:);
        data=data';  %现在就是行数据了
        phat=[phat,data];
    end
end
if howmanyleft>0
    planei=bitplaneofD(:,:,k+1+howmanyplanes);
    planei=planei';
    data=planei(1:howmanyleft);%现在就是行数据了
    phat=[phat,data];
end


%现在要根据 KDhat和phat来还原p了
[x0,y]=generateLSSParameter(KDhat);
x=LSS(x0,y,u);
%x1=round(x);
p=bitxor(round(x),phat);

