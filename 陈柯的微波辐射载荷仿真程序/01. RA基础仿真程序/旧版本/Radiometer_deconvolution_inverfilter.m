%本程序用频域逆滤波法对实孔径辐射计观测图像进行反卷积复原
%by 陈柯 2015.11.10
clear
% close all
tic;

%%***************************以下部分是设置标志位***********************************************************
flag_draw_TB = 0;                 %画出原始亮温TB 
flag_draw_TA = 0;                 %画出观测亮温TA
flag_noise = 0;                   %是否加入观测噪声的标志位
flag_antenna_cal = 0;             %计算天线方向图及其频谱的标志位
flag_TA_cal = 0;                  %计算观测亮温频谱的标志位
%*********************************************************************************************************
freq =36.5e9;                                       %instrment center frequency，unit:Hz
c=3e8;                                              %speed of light unit m/s
wavelength=c/freq;                                  %wave length unit:m
antenna_diameter=2;                                 %antenna diameter（refer to GEM, 2m Cassegrain）
Ba = pi*antenna_diameter/wavelength;  
x=0; 
%天线照射taper    
R = 6371;                                           %earth radius unit:km
orbit_height = 35786;                               %geostationary orbit heigth, unit:km

bandwith = 400*10^6;                                % radiometer receiver band width, unit:Hz
integral_time = 20*10^(-3);                          % radiometer integration time, unit:S
noise_figure= 5;
%%**********************读取亮温图像数据并插值处理************************************
%读取原始高分辨率亮温图像
TBmat_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\仿真亮温数据\2012.10.29 Hurricansandy1500-NAM'; 
matfile = sprintf('%s\\HurricanSandy_36_5_H.mat', TBmat_path);
load(matfile);
TB=pic;
T_max=max(max(TB));
T_min=min(min(TB));
[N_y_1,N_x_1]=size(pic);
if flag_draw_TB == 1 %显示原始亮温图像
   figure() ; imagesc(flipud(TB),[T_min T_max]);axis equal; xlim([1,N_x_1]);ylim([1,N_y_1]);colorbar('eastoutside');
end
%读取天线方向图卷积后的低分辨率亮温图像
TAmat_path = 'D:\功率级仿真系统阶段整理2012.11.29——陈柯修改版本\实孔径辐射计仿真-陈柯\数据分析'; 
matfile = sprintf('%s\\RA_HurricanSandy_36_5_H_TA_q0_2_425_noiseless.mat', TAmat_path);
load(matfile);
%以下部分代码负责加噪声，根据辐射计参数对无噪图像添加系统噪声
TA_noiseless=TA;
if flag_noise == 1
   [TA,Noise]=add_image_noise(TA,bandwith,integral_time,noise_figure);
   Noise = interpolation(Noise,N_y_1,N_x_1);
end 
%以下部分代码负责插值，将测量低分辨率图像插为原始高分辨率图像，保持和原始图像像素一致
TA = interpolation(TA,N_y_1,N_x_1);
if flag_draw_TA == 1
   figure();imagesc(flipud(TA),[T_min T_max]);axis equal; xlim([1,N_x_1]);ylim([1,N_y_1]);colorbar('eastoutside');
end
%%************************************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算图像在经度和纬度方向的角度范围%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算图像在经度和纬度方向的角度范围
WRFfile_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\WRF仿真和文件'; 
WRF_Output_filename = sprintf('%s\\wrfout_d01.nc', WRFfile_path);
[angle_Longitude,angle_Latitude] = Image_Long_Lat_cal(WRF_Output_filename,R,orbit_height);
Fov_scope = [-angle_Latitude/2 angle_Latitude/2;-angle_Longitude/2 angle_Longitude/2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d_f_x = 1/(angle_Longitude/180*pi);  %经度方向的空间频率网格，单位：Hz/rad
d_f_y = 1/(angle_Latitude/180*pi);   %纬度方向的空间频率网格，单位：Hz/rad
d_radian_x = (angle_Longitude/180*pi)/N_x_1;  %经度方向的空间网格，单位：rad
d_radian_y = (angle_Latitude/180*pi)/N_y_1;   %纬度方向的空间网格，单位：rad
radian_x = linspace(Fov_scope(2,1)/180*pi,Fov_scope(2,2)/180*pi,N_x_1).';   %经度空间坐标，单位：rad
radian_y = linspace(Fov_scope(1,1)/180*pi,Fov_scope(1,2)/180*pi,N_y_1).';    %纬度空间坐标，单位：rad
[cordinate_x,cordinate_y] = meshgrid(radian_x,radian_y);    %空间二维坐标，DFT反演需要用到
f_x = -round((N_x_1-1)/2)*d_f_x:d_f_x:round((N_x_1-1)/2)*d_f_x;
f_y = round((N_y_1-1)/2)*d_f_y:-d_f_y:-round((N_y_1-1)/2)*d_f_y;
[cordinate_f_x,cordinate_f_y] = meshgrid(f_x,f_y);    %空间二维坐标，DFT反演需要用到

load('deconv.mat');    %读取以前存储的亮温图像和天线方向图的频谱

if flag_antenna_cal == 1; 
   Antenna_G = circular_antenna_pattern_2D(Fov_scope,N_y_1,N_x_1,Ba,x); %计算天线方向图
   figure() ; imagesc(Antenna_G);axis equal; xlim([1,N_x_1]);ylim([1,N_y_1]);colorbar('eastoutside'); 

   f_G = spatial_DFT_2D(Antenna_G,f_x,f_y,d_radian_x,d_radian_y,cordinate_x,cordinate_y);%计算天线方向图的傅里叶变换谱
   f_G=f_G/max(max(f_G)); 
end
if flag_TA_cal == 1
   f_TA = spatial_DFT_2D(TA,f_x,f_y,d_radian_x,d_radian_y,cordinate_x,cordinate_y);%计算待反卷积图像的傅里叶变换谱
end
if flag_noise == 1
   f_N = spatial_DFT_2D(Noise,f_x,f_y,d_radian_x,d_radian_y,cordinate_x,cordinate_y);%计算噪声的傅里叶变换谱
end
% save deconv.mat Antenna_G f_G f_TA

I = ones(N_y_1,N_x_1);
W = I./(I+I./(10*real(f_G)));%计算权矩阵
% W = I./(I+(abs(f_N).^2)./(abs(f_TA).^2));
% W = I;

% Antenna_Gs = spatial_IDFT_2D(W,radian_x,radian_y,d_f_x,d_f_y,cordinate_f_x,cordinate_f_y);
% figure() ; imagesc(Antenna_Gs);axis equal; xlim([1,N_x_1]);ylim([1,N_y_1]);colorbar('eastoutside'); 
% figure() ; mesh(Antenna_Gs);
% Antenna_Gs = Antenna_Gs/max(max(Antenna_Gs));
% figure() ; plot(Antenna_Gs(round(N_y_1/2),:));


f_TB_deconv = W.*f_TA./f_G;  %逆滤波计算反卷积之后图像的谱
TB_deconv = spatial_IDFT_2D(f_TB_deconv,radian_x,radian_y,d_f_x,d_f_y,cordinate_f_x,cordinate_f_y);%对谱进行逆傅里叶变换得到反卷积图像
figure() ; imagesc(flipud(TB_deconv),[T_min T_max]);axis equal; xlim([1,N_x_1]);ylim([1,N_y_1]);colorbar('eastoutside');

offset = 15;
MSE = Mean_Square_Error(TB,TB_deconv,offset,1)%计算反卷积之后图像与原始亮温图像的RMSE
toc;
