function [MSE,PSNR] = Mean_Square_Error(TA1,TA2,offset,flag_draw)
%   函数功能：用RMSE实现对两个相同范围的亮温图像的误差比较**********************************
%            如果图像像素点数不一致，则将低分辨率图像插值到高分辨率图像
%  
%   输入参数:
%    TA1            ：被比较的标准亮温图像1         
%    TA2            ：输入亮温图像2 
%    offset         ：可以选择比较的范围，offset代表去掉的行列数
%    flag_draw      ：画图标准位，1：画出两幅图像的差值图像
%   输出参数：
%    MSE            : 两幅图像的RMSE值，即均方根误差                                       
%   by 陈柯 2016.06.24  ******************************************************  

  [row1,col1] = size(TA1);   
  [row2,col2] = size(TA2);
  
  if row1 == row2 && col1 == col2   %如果两幅图像像素点相同
     row = row1;
     col = col1;
     num_pix=(row-2*offset)*(col-2*offset)-1;
     delta_T=(TA1-TA2).^2;
     delta_T=delta_T(1+offset:(row-offset),1+offset:(col-offset));
     MSE = sqrt(sum(sum(delta_T,1),2)/(num_pix-1));
     delta_T = sqrt(delta_T);
  elseif row1 > row2
     row = row1;
     col = col1;
     TA2 = interpolation(TA2,row,col);
     num_pix=(row-2*offset)*(col-2*offset)-1;
     delta_T=(TA1-TA2).^2;
     delta_T=delta_T(1+offset:(row-offset),1+offset:(col-offset));
     MSE = sqrt(sum(sum(delta_T,1),2)/(num_pix-1));
     delta_T = sqrt(delta_T);
  else
     row = row2;
     col = col2; 
     TA1 = interpolation(TA1,row,col);
     num_pix=(row-2*offset)*(col-2*offset)-1;
     delta_T=(TA1-TA2).^2;
     delta_T=delta_T(1+offset:(row-offset),1+offset:(col-offset));
     MSE = sqrt(sum(sum(delta_T,1),2)/(num_pix-1));
     delta_T = sqrt(delta_T);
  end
  
  MAX = max(max(TA1));
  PSNR = 10*log10((MAX^2)/MSE);
  
  if flag_draw == 1
      figure() ; imagesc(delta_T);axis equal; xlim([1,col-2*offset]);ylim([1,row-2*offset]);colorbar('eastoutside');title('残差图像')
  end


  
  