clear all;
close all; clc;
% ���ܹ���
image1=imread('FJNU3.jpg');
image=imresize(image1,[512,512]);
% image=imread('lena512color.tiff');    %������114.jpg����ͼƬ
% figure;
% imshow(image);
% title('ԭͼ');
image=rgb2gray(image);
figure;
imshow(image);
title('ԭͼ�ĻҶ�ͼ');
p=[0 0 0 1 1 1 0 1 0 1 0 0 1 0 0 1 1 0 1];
%p=randint(1,2000,2);
s=8;
KI='12345';
KD='23456';
%KS='34567';
[E,D,k,u,KIhat,KDhat,Cs]=secretToImage(image,p,s,KI,KD);

figure;
imshow(D);
title('����ͼ');

%�������ݹ���
p=dataextraction(D,u,KDhat,k);
disp '�ָ�������'
p

%�ָ�ԭͼ����
originimg=imageRecover(KIhat,k,s,u,D,Cs);
figure;
imshow(originimg);
title('��ԭͼ');
% cba=originimg-image;
% figure;
% imshow(cba);
% title('�ָ�ͼ��ԭͼ֮��');
% figure;
% imhist(image,256);
% title('ԭͼ��ֱ��ͼ');
% figure;
% imhist(originimg,256);
% title('�ָ�ͼ��ֱ��ͼ');