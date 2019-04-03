%本程序用正则化法对实孔径辐射计观测图像进行反卷积复原
%by 陈柯 2015.11.10
clear;
close all;
tic;

%%***************************以下部分是设置标志位***********************************************************
flag_draw_TB = 1;                 %画出原始亮温TB 
flag_draw_deconv_pattern = 1;     %画出反卷积后的等效方向图
flag_opt = 0;                     %是否进行最优化正则化参数搜索
flag_save = 0;                    %数据存储标志位

%*********************************************************************************************************

%%***************************以下部分是设置实孔径辐射计载荷参数*********************************************
freq =50.3e9;                                      %instrment center frequency，unit:Hz
freq_highest=425e9;
c=3e8;                                              %speed of light unit m/s
wavelength=c/freq;                                  %wave length unit:m
wavelength_highest=c/freq_highest;  

R = 6371;                                           %earth radius unit:km
orbit_height = 35786;                               %geostationary orbit heigth, unit:km

antenna_diameter=2;                                 %antenna diameter（refer to GEM, 2m Cassegrain）
q=0;                                                % the illumination taper //by thesis of G.M.Skofronick
beam_width=1.02*wavelength/antenna_diameter*180/pi;  %antenna 3dB beam width
beam_width_highest=1.02*wavelength_highest/antenna_diameter*180/pi;
sample_density=2;                                  % sample number @ each beam width
Ba = pi*antenna_diameter/wavelength; 

bandwith = 180*10^6;                                % radiometer receiver band width, unit:Hz
noise_figure= 5;
integral_time = 20*10^(-3);                          % radiometer integration time, unit:S
%*********************************************************************************************************

%%***************************以下部分是导入被反卷积的图像信息*********************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算图像在经度和纬度方向的角度天顶角范围
WRFfile_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\WRF仿真和文件';   %Wrfout文件存储目录 
WRF_Output_filename = sprintf('%s\\wrfout_d01.nc', WRFfile_path);
[angle_Longitude,angle_Latitude] = Image_Long_Lat_cal(WRF_Output_filename,R,orbit_height);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%读取原始亮温图像
TBmat_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\仿真亮温数据\2012.10.29 Hurricansandy1500-NAM'; 
TBmatfile = sprintf('%s\\HurricanSandy_50_3_H_LGW.mat', TBmat_path);
load(TBmatfile);
%%读取观测亮温图像，即待反卷积处理的图像，此图像是无噪声的。
TAmat_path = 'D:\功率级仿真系统阶段整理2012.11.29——陈柯修改版本\实孔径辐射计仿真-陈柯\仿真结果'; 
TAmatfile = sprintf('%s\\RA_HurricanSandy_50_3_H_LGW_TA_q0_2_425_noiseless',TAmat_path);
load(TAmatfile);
TA=add_image_noise(flipud(TA),bandwith,integral_time,noise_figure);%给图像增加辐射计观测噪声

TB=flipud(pic);
T_max=max(max(pic));
T_min=min(min(pic));
[row_pix,col_pix] = size(TB);
num_pix = row_pix*col_pix;   %原始图像像素点数
if  flag_draw_TB == 1;  %画出原始亮温图像
    figure() ; imagesc(TB,[T_min T_max]);axis equal; xlim([1,col_pix]);ylim([1,row_pix]);colorbar('eastoutside');
%     figure() ; imagesc(TA,[T_min T_max]);axis equal;colorbar('eastoutside');
end
%*********************************************************************************************************

%**********************以下部分进行反卷积处理**************************************************************
d_Longitude = angle_Longitude/col_pix; %原始亮温图像格点角度
d_Latitude = angle_Latitude/row_pix;
d_sample_Latitude = max(beam_width_highest/sample_density,d_Latitude); %观测采样格点角度
d_sample_Longitude = max(beam_width_highest/sample_density,d_Longitude);
num_Latitude = min(round(angle_Latitude/d_sample_Latitude)+1,row_pix);     % sample pixels number measured by radiometer in latitude dirction  
num_Longitude = min(round(angle_Longitude/d_sample_Longitude)+1,col_pix);    % sample pixels number measured by radiometer in longitude dirction  

PSF_Long = PSF_generate(angle_Longitude,col_pix,num_Longitude,d_sample_Longitude,Ba,q); %计算经度方向的点响应函数
PSF_Lat = PSF_generate(angle_Latitude,row_pix,num_Latitude,d_sample_Latitude,Ba,q);     %计算纬度方向的点响应函数
 
k_Long = 0.058;  %经度方向的正则化参数
k_Lat = 0.06;    %纬度方向的正则化参数

%搜索最优化的正则化参数
if flag_opt == 1;  
   d_k_Long=0.001;  %搜索步长
   d_k_Lat=0.01;
   k_Long_index = 8000*d_k_Long:d_k_Long:8100*d_k_Long;
   k_Lat_index = 800*d_k_Lat:d_k_Lat:810*d_k_Lat;
   num_k_Long = length(k_Long_index);  
   num_k_Lat = length(k_Lat_index);
   MSE_index = zeros(num_k_Long,num_k_Lat);
   matlabpool open ;
   parfor m=1:num_k_Long
       for n=1:num_k_Lat
           k_Long = k_Long_index(m);
           k_Lat = k_Lat_index(n);      
           TB_deconv = deconvolution(TA,PSF_Long,PSF_Lat,k_Long,k_Lat);
           MSE_index(m,n) = Mean_Square_Error(TB,TB_deconv,0,0);            
       end
   end
   matlabpool close ;
   [k_Long_opt,k_Lat_opt] = find(MSE_index==min(min(MSE_index)));%找出范围内RMSE的谷值，即为最优化的正则化参数
   k_Long = k_Long_index(k_Long_opt)
   k_Lat = k_Lat_index(k_Lat_opt)
end

[TB_deconv,Antenna_Gs] = deconvolution(TA,PSF_Long,PSF_Lat,k_Long,k_Lat); %反卷积处理
% figure() ; imagesc(TA,[T_min T_max]);axis equal; xlim([1,num_Longitude]);ylim([1,num_Latitude]);colorbar('eastoutside');
figure() ; imagesc(TB_deconv,[T_min T_max]); axis equal; xlim([1,col_pix]);ylim([1,row_pix]);colorbar('eastoutside');
MSE_deconv = Mean_Square_Error(TB,TB_deconv,0,1)  %反卷积后的图像与原始图像的RMSE
MSE_conv = Mean_Square_Error(TB,TA,0,0)
pecent = (MSE_conv-MSE_deconv)/MSE_conv

if flag_draw_deconv_pattern == 1  %画出反卷积后的天线方向图并根据其3dB波束宽度计算分辨率
   N_ant = 8001;
   theta_x = linspace(-angle_Latitude/2,angle_Latitude/2,row_pix) ;
   theta = linspace(-angle_Latitude/2,angle_Latitude/2,N_ant) ;
   Antenna_Gsi=interp1(theta_x,Antenna_Gs,theta,'spline');   %把反卷积后的天线方向图插值成点数更高  
   [HPBW,k_3dB] = HPBW_of_AP(Antenna_Gsi,theta);     %计算反卷积因子的3dB波束宽度
   ground_resolution = HPBW/180*pi*orbit_height    
   mark_3dB = round(N_ant-1)/2+abs(round(N_ant/2)-k_3dB); %3dB点的位置
   figure;hPlot=plot(theta,Antenna_Gsi,'LineWidth',2); makedatatip(hPlot,mark_3dB);xlim([theta(1),theta(N_ant)]);xlabel('\theta');title('归一化反卷积天线方向图');grid on;   
end
%*********************************************************************************************************


if flag_save==1  %存储反卷积之后的数据结果
   dirstr=textscan(matfile,'%s', 'delimiter', '\\');
   dirstr=dirstr{1,1};
   filename_str = dirstr(size(dirstr,1),1); 
   filename_str = filename_str{1,1};
   tempstr = textscan(filename_str,'%s', 'delimiter', '.');
   tempstr = tempstr{1,1};
   sourcefilename = tempstr{1,1};

   FileName = sprintf('RA_%s_TB_deconv_q%d_%d_%d', sourcefilename,q,antenna_diameter,round(freq_highest/1e9));
   MatFileName = sprintf('%s.mat', FileName);
   save (MatFileName, 'TB_deconv') 
end

toc;














