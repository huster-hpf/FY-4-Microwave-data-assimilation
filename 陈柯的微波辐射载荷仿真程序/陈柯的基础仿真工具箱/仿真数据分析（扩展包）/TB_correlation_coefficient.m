function [R] = TB_correlation_coefficient(TA1,TA2,offset)
%   函数功能：计算两个相同范围的亮温图像相关系数**********************************
%            如果图像像素点数不一致，则将低分辨率图像插值到高分辨率图像
%  
%   输入参数:
%    TA1            ：被比较的标准亮温图像1         
%    TA2            ：输入亮温图像2 
%    offset         ：可以选择比较的范围，offset代表去掉的行列数%   
%   输出参数：
%    R              : 两幅图像的相关系数，如果完全相同的图像，则为1 
%   
%   by 陈柯 2016.12.14  ******************************************************  

  [row1,col1] = size(TA1);   
  [row2,col2] = size(TA2);
  %把两幅图像的像素点数插值到相同
  if row1 == row2 && col1 == col2   %如果两幅图像像素点相同
     row = row1;
     col = col1;     
  elseif row1 > row2
     row = row1;
     col = col1;
     TA2 = interpolation(TA2,row,col);     
  else
     row = row2;
     col = col2; 
     TA1 = interpolation(TA1,row,col);     
  end
  X = TA1(1+offset:(row-offset),1+offset:(col-offset));
  Y = TA2(1+offset:(row-offset),1+offset:(col-offset));
  R = corr2(X,Y);
 
  



  
  