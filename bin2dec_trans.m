%% 包含多个0或1的数组，将其转换为十进制数字
%用于decode时数据分析.
function m=bin2dec_trans(bin_m)
    p=length(bin_m);
    m=0;
    for i=p-1:-1:0
        m=m+bin_m(p-i)*2^i;
    end
end