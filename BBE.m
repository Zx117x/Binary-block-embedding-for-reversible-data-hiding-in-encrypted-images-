%% 将要嵌入的图像生成另一种结果 （已完成）
%dst即为block+payload之后的结果
function dst=BBE(img,s,payload) %注意这里的oayload只有M部分
img=uint8(img);
dst=zeros(size(img));
b=[];
[i1,i2]=size(img);
n=s*s;
%% 先得到 payload的 B部分
for i=1:i1/s
    for j=1:i2/s
        B{i,j}=img((i-1)*s+1:i*s,(j-1)*s+1:j*s);
        [~, extra]=getType(B{i,j});
        b=[b,extra];
    end
end

%% payload = B + M
payload=[b,payload];

%% 开始将数据嵌入
predatalength=0;
for i=1:i1/s
    for j=1:i2/s
        B{i,j}=img((i-1)*s+1:i*s,(j-1)*s+1:j*s);

        % 得到第一步包含cb以及结构信息的output
        [cb,output]=typeWithStructure(B{i,j});
        
        % 第二步，将信息嵌入output中
        if cb>0
            %根据payload的大小不同,可能出现payload不足以覆盖整个画面的情况.
            if length(payload)<predatalength  %根据之前数据的长度，判断是否需要继续存储。
                data=zeros(1,cb);
            elseif length(payload)<predatalength+cb
                data=payload(predatalength+1:end);
                data=[data,zeros(1,predatalength+cb-length(payload))];
            else
                data=payload(predatalength+1:predatalength+cb);   %matlab 代码自己能控制这个cb为负值时，data为空。
            end
            output=output';
            output=output(:); %将output的所有元素按顺序排成一列
            output(n-cb+1:n)=data;%将data数据赋值给output的cb位上
            output=reshape(output,s,s);
            output=output';
            predatalength = predatalength+cb;
        end
        %第三步，整合到最终的图像上
        dst((i-1)*s+1:i*s,(j-1)*s+1:j*s)=output;
    end
end