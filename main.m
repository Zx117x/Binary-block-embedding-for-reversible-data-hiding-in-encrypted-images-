clear all;
close all; clc;
% 加密过程
image1=imread('FJNU3.jpg');
image=imresize(image1,[512,512]);
% image=imread('lena512color.tiff');    %现在是114.jpg这张图片
% figure;
% imshow(image);
% title('原图');
image=rgb2gray(image);
figure;
imshow(image);
title('原图的灰度图');
p=[0 0 0 1 1 1 0 1 0 1 0 0 1 0 0 1 1 0 1];
%p=randint(1,2000,2);
s=8;
KI='12345';
KD='23456';
%KS='34567';
[E,D,k,u,KIhat,KDhat,Cs]=secretToImage(image,p,s,KI,KD);

figure;
imshow(D);
title('加密图');

%解密数据过程
p=dataextraction(D,u,KDhat,k);
disp '恢复的数据'
p

%恢复原图过程
originimg=imageRecover(KIhat,k,s,u,D,Cs);
figure;
imshow(originimg);
title('复原图');
% cba=originimg-image;
% figure;
% imshow(cba);
% title('恢复图与原图之差');
% figure;
% imhist(image,256);
% title('原图的直方图');
% figure;
% imhist(originimg,256);
% title('恢复图的直方图');