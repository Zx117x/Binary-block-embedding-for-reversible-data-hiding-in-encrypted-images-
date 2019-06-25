%% 根据block的大小来计算na以及m所占的位数
function [na,p]=getNaWithP(s)
switch s
    case 3
      na=1;
      p=1;
    case 4
      na=1;
      p=1;
    case 5
      na=3;
      p=2;
    case 6
      na=5;
      p=3;
    case 7
      na=7;
      p=3;
    case 8
      na=9;
      p=4;
    otherwise
      na=0;
      p=0;
end