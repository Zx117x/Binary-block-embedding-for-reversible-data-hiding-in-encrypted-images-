function [sumcb]=getImageCapacity(img,s)
[i1,i2]=size(img);
sumcb=0;
for i=1:i1/s
    for j=1:i2/s
        B{i,j}=img((i-1)*s+1:i*s,(j-1)*s+1:j*s);
        % 得到第一步包含cb以及结构信息的output
        [cb,~]=typeWithStructure(B{i,j});
        sumcb=sumcb+cb;
    end
end