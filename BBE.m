%% ��ҪǶ���ͼ��������һ�ֽ�� ������ɣ�
%dst��Ϊblock+payload֮��Ľ��
function dst=BBE(img,s,payload) %ע�������oayloadֻ��M����
img=uint8(img);
dst=zeros(size(img));
b=[];
[i1,i2]=size(img);
n=s*s;
%% �ȵõ� payload�� B����
for i=1:i1/s
    for j=1:i2/s
        B{i,j}=img((i-1)*s+1:i*s,(j-1)*s+1:j*s);
        [~, extra]=getType(B{i,j});
        b=[b,extra];
    end
end

%% payload = B + M
payload=[b,payload];

%% ��ʼ������Ƕ��
predatalength=0;
for i=1:i1/s
    for j=1:i2/s
        B{i,j}=img((i-1)*s+1:i*s,(j-1)*s+1:j*s);

        % �õ���һ������cb�Լ��ṹ��Ϣ��output
        [cb,output]=typeWithStructure(B{i,j});
        
        % �ڶ���������ϢǶ��output��
        if cb>0
            %����payload�Ĵ�С��ͬ,���ܳ���payload�����Ը���������������.
            if length(payload)<predatalength  %����֮ǰ���ݵĳ��ȣ��ж��Ƿ���Ҫ�����洢��
                data=zeros(1,cb);
            elseif length(payload)<predatalength+cb
                data=payload(predatalength+1:end);
                data=[data,zeros(1,predatalength+cb-length(payload))];
            else
                data=payload(predatalength+1:predatalength+cb);   %matlab �����Լ��ܿ������cbΪ��ֵʱ��dataΪ�ա�
            end
            output=output';
            output=output(:); %��output������Ԫ�ذ�˳���ų�һ��
            output(n-cb+1:n)=data;%��data���ݸ�ֵ��output��cbλ��
            output=reshape(output,s,s);
            output=output';
            predatalength = predatalength+cb;
        end
        %�����������ϵ����յ�ͼ����
        dst((i-1)*s+1:i*s,(j-1)*s+1:j*s)=output;
    end
end