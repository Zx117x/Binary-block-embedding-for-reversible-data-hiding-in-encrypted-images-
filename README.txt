本项目为文献[1]的论文复现，采用matlab实现
[1]Yi S , Zhou Y . Binary-block embedding for reversible data hiding in encrypted images[J]. Signal Processing, 2017, 133:40-51.
论文链接https://doi.org/10.1016/j.sigpro.2016.10.017

使用示例在代码中有注释，整个过程分为以下三个函数


运行secretToImage   用于正向加密
运行imageRecover  用于逆向解密原图像
运行dataextraction   用于从加密图中提取之前存入的秘密数据



argmaxC   用于论文中计算C
BBE       实现了论文中的BBE算法
bin2dec_trans    用于将用矩阵表示的二进制数字转换为十进制的数字
dataextraction   用于从加密图中提取之前存入的秘密数据
decodeBBE 实现了论文中解密BBE的算法（主要针对GOOD-III 和 GOOD-IV）
extractWithRecover 实现解密各种类型的BBE算法（套用了decodeBBE方法）
generateLSSParameter  使用160位二进制数字生成LSS的初始参数
getImageCapacity  得到二值图像的容纳能力
getNaWithP
getType   根据block内的数据判断它是哪一类型的blcok
ifequal  用于调试验证正逆加密过程
imageRecover  用于逆向解密
LSS     LSS算法
secretToImage   用于正向加密
typeWithStructure   用于生成 不同类型的block尚未放入数据时的图，类似于Fig.1的 第二行图像
