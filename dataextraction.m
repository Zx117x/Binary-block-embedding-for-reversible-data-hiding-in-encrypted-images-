%% �Ӽ���ͼ���и���ԭʼͼ��KDhat����Ϣ��ȡ���ܽ�ȥ������
% p -- ֮ǰ���ܽ�ȥ������
% originalimg -- ԭʼͼ��
% scrabledimg -- ��������ܲ�����D
% kshat -- û�ã������
% u -- �������ݳ���
% KDhat --��Կ
% ʹ��ʾ��
% p=dataextraction(image,D,'12',16,KDhat)

% ���ڲ���ʹ�ù�Կ���������scrabledimg����ǰ���D��kshatҲûʲô����,u����Ҫ��֤��Ҫ��Cs������ݸ��ǵ���Ҳ����u�����ݲ�Ҫ�������һ��ƽ����ȥ
function p=dataextraction(scrabledimg,u,KDhat,k)
 %I=(originalimg);
 %if ndims(I)==3
  %  I=rgb2gray(I);
 %end
%[M,N]=size(I);
%bitplane=zeros(M,N,8); %��ʾһ��ԭͼ��8��bit plane
%bitplaneofD=zeros(M,N,8);
 %C=zeros(1,8);
%E=zeros(size(I));
s=5;  %��ʾblock sizeΪ5*5

%�ֳɰ˸�λƽ��
%for i=1:M
 %   for j=1:N
  %       result=bitget(I(i,j),8:-1:1);
  %       bitplane(i,j,:)=result;
  %   end
 %end

%����ÿ��ƽ���������������,ͬʱ�õ�k
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

%����ԭͼ�Ϳ���֪������������Dͼ������ݵ�λ�����������.....blabla�͸���KShat��ԭ����D.������ֱ���ҵ�D�Ĵ洢���������ǲ��־�����
%�������ǿ��Ը���ԭͼ֪�����ݴ洢�ĵ�һ������ǵ�D�ĵ�k+1����
D=scrabledimg;
[M,N]=size(D);
bitplaneofD=zeros(M,N,8);%�����ʡȥ�˽��ܹ�Կ�Ĺ���
%D�ֳɰ˸�λƽ��
for i=1:M
    for j=1:N
        result=bitget(D(i,j),8:-1:1);
        bitplaneofD(i,j,:)=result;
    end
end

%����u���ж���Щ����(��ʵ��phat)�����ĸ�����
phat=[];
howmanyplanes=floor(u/(M*N));
howmanyleft=u-M*N*howmanyplanes;
if howmanyplanes > 0
    for i=k+1:k+howmanyplanes
        planei=bitplaneofD(:,:,i);
        planei=planei';
        data=planei(:);
        data=data';  %���ھ�����������
        phat=[phat,data];
    end
end
if howmanyleft>0
    planei=bitplaneofD(:,:,k+1+howmanyplanes);
    planei=planei';
    data=planei(1:howmanyleft);%���ھ�����������
    phat=[phat,data];
end


%����Ҫ���� KDhat��phat����ԭp��
[x0,y]=generateLSSParameter(KDhat);
x=LSS(x0,y,u);
%x1=round(x);
p=bitxor(round(x),phat);

