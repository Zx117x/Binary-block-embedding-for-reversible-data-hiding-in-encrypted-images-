%% �������0��1�����飬����ת��Ϊʮ��������
%����decodeʱ���ݷ���.
function m=bin2dec_trans(bin_m)
    p=length(bin_m);
    m=0;
    for i=p-1:-1:0
        m=m+bin_m(p-i)*2^i;
    end
end