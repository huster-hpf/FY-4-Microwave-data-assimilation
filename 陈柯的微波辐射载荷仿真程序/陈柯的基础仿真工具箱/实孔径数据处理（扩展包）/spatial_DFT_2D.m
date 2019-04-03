function  spectrum = spatial_DFT_2D(T,f_x,f_y,d_radian_x,d_radian_y,cordinate_x,cordinate_y)
 %本函数实现空间图像二维离散傅里叶变换功能，输入参数中
 %T：输入空间图像；f_x,f_y：空间频率两维坐标，单位Hz/rad；d_radian_x,d_radian_y：空间两维上的分辨率，单位rad；cordinate_x,cordinate_y：空间坐标矩阵，单位rad
   [N_y,N_x] = size(T);
   spectrum = zeros(N_y,N_x);
   matlabpool open ;
   parfor y =1:N_y
         for x=1:N_x
             spectrum(y,x) = sum(sum(T.*exp(-1i*2*pi*(f_x(x)*cordinate_x+f_y(y)*cordinate_y))))*d_radian_x*d_radian_y; 
         end
   end
   matlabpool close;