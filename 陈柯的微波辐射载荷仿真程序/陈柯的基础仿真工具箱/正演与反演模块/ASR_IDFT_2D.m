function T= ASR_IDFT_2D(V,xi,eta,uv_sample,A)
%   函数功能：根据综合孔径公式从可见度函数反演亮温图像**********************************
%               实际上就是离散傅里叶变换DFT
%  
%   输入参数:
%    V              ：输入可见度函数         
%    xi             ：反演图像每点的ξ坐标向量 
%    eta            ：亮温图像每点的η坐标向量
%    uv_sample      ：可见度函数对应的uv平面采样点坐标
%    A              ：每个可见度样本对应的uv网格面积，即d_xi*d_eta
%   输出参数：
%    T              : 反演得到的二维亮温图像                                       
%   by 陈柯 2016.06.24  ******************************************************

   N_xi = length(xi);
   N_eta = length(eta);
   T=zeros(N_eta,N_xi);    %初始化重建后的二维DFT修正亮温 
   for p=1:N_xi
      for  q=1:N_eta
             T(q,p) =real(sum(sum(V.*exp(1i*2*pi*(real(uv_sample)*xi(p)+imag(uv_sample)*eta(q)))))*A);
      end
   end   
 