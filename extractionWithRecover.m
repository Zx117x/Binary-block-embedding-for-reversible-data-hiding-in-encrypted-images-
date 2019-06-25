%% 解码过程，将嵌入数据的图像变成原来的图像.(已完成)
%B即为复原后的block的集合,phi即为解码出来的payload

function [B,phi]=extractionWithRecover(img,s)
phi=[];
b=[];  %用于标识那些坏的不能存信息的block，同时方便恢复信息时快速找到这些block
n=s*s;
[s1,s2]=size(img);

%% 恢复goodblock.
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
            b=[b,[i,j]];%b中包含badblock位置的索引
        end
    end
end
%% 将badblock的前两位恢复
for sizeofBadblock=1:length(b)/2     %b中包含badblock的索引
    i=b(2*sizeofBadblock-1); %找到badblock的位置
    j=b(2*sizeofBadblock);
    B{i,j}(1,1)=phi(1);%payload的前两个元素即是坏快的原始像素
    B{i,j}(1,2)=phi(2);
    phi=phi(3:end);%payload剩下的元素即为m秘密数据赋给phi
end



        