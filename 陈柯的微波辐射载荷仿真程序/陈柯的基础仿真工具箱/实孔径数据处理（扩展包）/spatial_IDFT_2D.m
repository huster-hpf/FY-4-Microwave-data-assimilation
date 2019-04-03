function  T = spatial_IDFT_2D(spectrum,radian_x,radian_y,d_f_x,d_f_y,cordinate_f_x,cordinate_f_y)
 %本函数实现空间图像二维离散逆傅里叶变换功能
 %T：输入空间图像；d_f_x,d_f_y：空间频率两维上的分辨率，单位Hz/rad；radian_x,radian_y：空间两维上的坐标，单位rad；cordinate_f_x,cordinate_f_y：空间频率坐标矩阵
   [N_y,N_x] = size(spectrum);
   T = zeros(N_y,N_x);
   matlabpool open ;
   parfor y =1:N_y
         for x=1:N_x
             T(y,x) = real(sum(sum(spectrum.*exp(1i*2*pi*(radian_x(x)*cordinate_f_x+radian_y(y)*cordinate_f_y))))*d_f_x*d_f_y);              
         end
   end
   matlabpool close;