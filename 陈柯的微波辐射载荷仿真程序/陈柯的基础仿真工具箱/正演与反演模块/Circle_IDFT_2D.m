function T= Circle_IDFT_2D(V,xi,eta,uv_sample,uvarea)
%   函数功能：   均匀圆环阵的DFT反演算法**********************************
%               必须通过对圆环阵列非均匀uv采样点通按面积加权均匀化处理，才能应用的DFT算法%               
%  
%   输入参数:
%    V              ：输入可见度函数         
%    xi             ：反演图像每点的ξ坐标向量 
%    eta            ：亮温图像每点的η坐标向量
%    uv_sample      ：可见度函数对应的uv平面采样点坐标
%    uvarea         ：圆环阵每个可见度样本对应的uv网格面积，是个矩阵
%   输出参数：
%    T              : 反演得到的二维亮温图像                                       
%   by 陈柯 2016.06.24  ******************************************************  
   N_xi = length(xi);
   N_eta = length(eta);
   T=zeros(N_eta,N_xi);    %初始化重建后的二维DFT修正亮温 
   for p=1:N_xi
      for  q=1:N_eta
             T(q,p) =real(sum(sum(V.*exp(1i*2*pi*(real(uv_sample)*xi(p)+imag(uv_sample)*eta(q))).*uvarea)));
      end
   end   
   