function [originimg]=MarkedDecrypted(KIhat,k,s,u,scrambledimg,Cs)
unscrambledimg=scrambledimg; %���ڱ�ʾû��ʹ�ù�Կ�����������
D=unscrambledimg;   %��֮ǰͳһ����
originimg=zeros(size(D));
[M,N]=size(D);
E=zeros(size(D));
R=E;
bitplaneofD=zeros(M,N,8);
bitplaneofR=bitplaneofD;
bitplaneofI=bitplaneofD;
for i=1:M
    for j=1:N
        result=bitget(D(i,j),8:-1:1);
        bitplaneofD(i,j,:)=result;
    end
end
% debug=bitplaneofD;
bitplaneofE=bitplaneofD;
%Ȼ���ҳ�Cs
%Csbit=zeros(1,20);   %Csbit ��ʾCs�����Ƶ�ÿһλ
%for i=1:20
 %   indexi=ceil(i/N);
  %  indexj=i-(indexi-1)*M;
   % Csbit(i)=bitplaneofE(indexi,indexj,8);
    %bitplaneofE(indexi,indexj,8)=0;  %�洢Cs��С�����ƽ������
%end

%Cs=bin2dec_trans(Csbit);



%����CS���жϴ����ĸ�����,Ȼ���������ռ�õ�λ����0
phatdata=bitplaneofE(:,:,k+1);
phatdata=phatdata(1:u);
howmanyplanes=floor(Cs/(M*N));
howmanyleft=Cs-M*N*howmanyplanes;
if howmanyplanes > 0
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


%��0֮��ʼȥ��T��Ӱ��

for i=1:M
    for j=1:N
        E(i,j)=bin2dec_trans(bitplaneofE(i,j,:));  %��ʱ��E������ǹ�ʽ12��ߵ�E.
    end 
end

% debug=bitplaneofE;

[x0,y]=generateLSSParameter(KIhat);
x=LSS(x0,y,M*N);
t=round(mod(x*2^50,255));
t=reshape(t,N,M);
t=t';
for i=1:M
    for j=1:N
        R(i,j)=bitxor(E(i,j),t(i,j));
    end
end

%��ʱ��R�ʹ����˽�LSB���ݴ浽MSB�еĽ��
for i=1:M
    for j=1:N
        result=bitget(R(i,j),8:-1:1);
        bitplaneofR(i,j,:)=result;
    end
end


% debug=bitplaneofR;
%�Ƚ��洢��LSB��MSBƽ��ָ�����ȡLSB����,
LSBdata=[];
bitplaneofI=bitplaneofR;
for i=1:k %k����ƽ��ָ�
    [B,phi]=extractionWithRecover(bitplaneofR(:,:,i),s);
    bitplaneofI(:,:,i)=cell2mat(B);
    LSBdata=[LSBdata,phi];
end


%Ȼ���Ҫ�ָ�LSBƽ�棬��Ϊ���������е�LSB���ݶ��洢�����ˣ�������Ҫ�õ�ǰ���Cs
howmanyplanes=floor(Cs/(M*N));
howmanyleft=Cs-M*N*howmanyplanes;
if howmanyplanes > 0
  for i=k+1:k+howmanyplanes
       data=LSBdata((i-k-1)*M*N+1:(i-k)*M*N); %MN������
       data=reshape(data,N,M);
      data=data';
     bitplaneofI(:,:,i)=data;
   end
end
if howmanyleft>0
   mask1=[LSBdata(M*N*howmanyplanes+1:end),zeros(1,M*N-howmanyleft)];
   mask1=reshape(mask1,N,M);
   mask1=mask1';
   mask2=[zeros(1,howmanyleft),ones(1,M*N-howmanyleft)];
   mask2=reshape(mask2,N,M);
  mask2=mask2';
 bitplaneofI(:,:,k+howmanyplanes+1)=mask1+mask2.*bitplaneofR(:,:,k+howmanyplanes+1);%��һ�����û���洢������
 
 
%    for i=1:howmanyleft
%         indexi=ceil(i/N);
%         indexj=i-(indexi-1)*M;
%         bitplaneofI(indexi,indexj,k+howmanyplanes+1);
%     end
end
mask1=[phatdata(1:end),zeros(1,M*N-u)];
mask1=reshape(mask1,N,M);
mask1=mask1';
mask2=[zeros(1,u),ones(1,M*N-u)];
mask2=reshape(mask2,N,M);
mask2=mask2';
 bitplaneofI(:,:,k+1)=mask1+mask2.*bitplaneofI(:,:,k+1);

for i=1:M
    for j=1:N
        originimg(i,j)=bin2dec_trans(bitplaneofI(i,j,:));
    end
end
originimg=uint8(originimg);
