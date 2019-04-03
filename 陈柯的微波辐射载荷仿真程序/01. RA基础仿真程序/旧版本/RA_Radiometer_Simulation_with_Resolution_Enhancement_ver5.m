%本程序模拟实孔径辐射计载荷观测亮温
%by 陈柯 2015.11.10 --updated 2016.10.19 

clear;
close all;
tic;
%%***************************以下部分是设置标志位和轨道参数**********************************************************
flag_draw_TB = 1;                               %画原始亮温TB标志位  
flag_draw_pattern = 0;                          %画天线方向图标志位
flag_save = 0;                                  %数据存储标志位
flag_Resolution_Enhancement  = 1;               %使用分辨率增强后处理标志位
Resolution_Enhancement_name = 'BG';             %可选算法有BG、WienerFilter、SIR、ODC
RMSE_offset  = 20;                              %观测图像与原始图像对比时图像边缘去掉的行或列数
R = 6371;                                       %地球半径 unit:km
orbit_height = 35786;                           %轨道高度（当前为地球静止轨道）, unit:km
Longtitude_satellite = -99.5;                   %静止轨道卫星所处经度
Latititude_satellite = 0;                       %静止轨道卫星所处纬度
%*********************************************************************************************************

%% ********************************************************part1：设置输入图像场景参数：空间坐标和亮温值********************************************
%根据选择模拟亮温场景读取对应频段的模拟亮温图像
file_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\01. 仿真亮温数据\2016.10.09 飓风sandy-NAM-20121029\亮温图像';   %文件存储目录 
TB_filename = 'HurricanSandy_29_00_C1_H';     %亮温图像文件名，该场景范围为1500*1500公里
TB_matfile = sprintf('%s\\%s.mat', file_path,TB_filename);
load(TB_matfile);
TB=(pic);
T_max=max(max(TB));
T_min=min(min(TB));
% T_min=220;
[N_Lat,N_Long] = size(TB);
%读取场景的经度和纬度坐标,然后根据卫星轨道转换为相对卫星的角度坐标
coordinate_filename = sprintf('%s\\coords.mat', file_path);
load(coordinate_filename);
Longitude_scene =XLO.';
Latitude_scene = XLA.';
[theta_scene,phi_scene] = Satellite_Sphere_Coordinate_Calc(Longitude_scene,Latitude_scene,Longtitude_satellite,Latititude_satellite,R,orbit_height);
[angle_Long,angle_Lat] = Image_Long_Lat_calc(coordinate_filename,R,orbit_height);
%计算图像空间角度坐标参数*********************************************
%计算空间格点大小
d_Long = angle_Long/(N_Long);                  %亮温图像经度方向最小间距，即角度分辨率  
d_Lat = angle_Lat/(N_Lat);                     %亮温图像纬度方向最小间距，即角度分辨率 
%计算图像的真实空间二维角度坐标值
Coordinate_Long = linspace(-angle_Long/2,angle_Long/2-d_Long,N_Long);   %经度角度坐标向量
Coordinate_Lat = linspace(-angle_Lat/2,angle_Lat/2-d_Lat,N_Lat);        %纬度角度坐标向量


%画出输入亮温图像
if  flag_draw_TB == 1;
    figure;imagesc(Coordinate_Long,Coordinate_Lat,TB,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
    xlabel('经度方向'); ylabel('纬度方向');title('原始亮温图像TB');colorbar;
end
%根据输入亮温文件读取文件中的频点编号
length_filename = length(TB_filename);
if strcmpi('C',TB_filename(length_filename-3))
     freq_index = str2double(TB_filename(length_filename-2));     
else
     freq_index = str2double([TB_filename(length_filename-3),TB_filename(length_filename-2)]);     
end
%part1：end**************************************************************************************************************************************************


%% ********************************************************part2：辐射计载荷参数与扫描采样参数设置**************************************************************
%%***************************设置辐射计参数******************************
%% 以下是每个频点需要修改的辐射计参数
switch freq_index   %中心频率,单位:Hz  %带宽, 单位:Hz     %噪声系数,单位:dB   %天线口径，单位：米
             case 1, freq= 50.3e9;   bandwith = 180e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 2, freq= 51.76e9;  bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 3, freq= 52.8e9;   bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 4, freq= 53.596e9; bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 5, freq= 54.4e9;   bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 6, freq= 54.94e9;  bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 7, freq= 55.5e9;   bandwith = 330e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 8, freq= 57.29e9;  bandwith = 330e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 9, freq= 57.507e9; bandwith = 2*78e6;   noise_figure= 5;  antenna_diameter = 5; 
             case 10,freq= 57.66e9;  bandwith = 4*36e6;   noise_figure= 5;  antenna_diameter = 5; 
             case 11,freq= 57.63e9;  bandwith = 4*16e6;   noise_figure= 5;  antenna_diameter = 5; 
             case 12,freq= 57.62e9;  bandwith = 4*8e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 13,freq= 57.617e9; bandwith = 4*3e6;    noise_figure= 5;  antenna_diameter = 5; 
             case 14,freq= 88.2e9;   bandwith = 2000e6;   noise_figure= 7;  antenna_diameter = 5; 
             case 15,freq= 118.83e9; bandwith = 2*20e6;   noise_figure= 8;  antenna_diameter = 2.4;
             case 16,freq= 118.95e9; bandwith = 2*100e6;  noise_figure= 8;  antenna_diameter = 2.4;
             case 17,freq= 119.05e9; bandwith = 2*165e6;  noise_figure= 8;  antenna_diameter = 2.4;
             case 18,freq= 119.55e9; bandwith = 2*200e6;  noise_figure= 8;  antenna_diameter = 2.4;
             case 19,freq= 119.85e9; bandwith = 2*200e6;  noise_figure= 8;  antenna_diameter = 2.4;
             case 20,freq= 121.25e9; bandwith = 2*200e6;  noise_figure= 8;  antenna_diameter = 2.4;
             case 21,freq= 121.75e9; bandwith = 2*1000e6; noise_figure= 8;  antenna_diameter = 2.4;
             case 22,freq= 123.75e9; bandwith = 2*2000e6; noise_figure= 8;  antenna_diameter = 2.4;
             case 23,freq= 165.5e9;  bandwith = 3000e6;   noise_figure= 9;  antenna_diameter = 2.4;
             case 24,freq= 190.31e9; bandwith = 2*2000e6; noise_figure= 9;  antenna_diameter = 2.4;
             case 25,freq= 187.81e9; bandwith = 2*2000e6; noise_figure= 9;  antenna_diameter = 2.4;
             case 26,freq= 186.31e9; bandwith = 2*1000e6; noise_figure= 9;  antenna_diameter = 2.4;
             case 27,freq= 185.11e9; bandwith = 2*1000e6; noise_figure= 9;  antenna_diameter = 2.4;
             case 28,freq= 184.31e9; bandwith = 2*500e6;  noise_figure= 9;  antenna_diameter = 2.4;
             case 29,freq= 380e9;    bandwith = 2*1000e6; noise_figure= 11; antenna_diameter = 2.4;
             case 30,freq= 428.763e9;bandwith = 2*1000e6; noise_figure= 11; antenna_diameter = 2.4;
             case 31,freq= 426.263e9;bandwith = 2*600e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 32,freq= 425.763e9;bandwith = 2*400e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 33,freq= 425.363e9;bandwith = 2*200e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 34,freq= 425.063e9;bandwith = 2*100e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 35,freq= 424.913e9;bandwith = 2*60e6;   noise_figure= 11; antenna_diameter = 2.4;
             case 36,freq= 424.833e9;bandwith = 2*20e6;   noise_figure= 11; antenna_diameter = 2.4;
             case 37,freq= 424.793e9;bandwith = 2*10e6;   noise_figure= 11; antenna_diameter = 2.4;
end     
% freq = 50.3e9;                                             %辐射计中心频率，单位:Hz
% bandwith = 180e6;                                          %辐射计带宽, unit:Hz
% noise_figure= 5;                                           %辐射计噪声系数, unit:dB
% antenna_diameter = 5;                                      %辐射计天线口径 单位：米
illumination_taper = 0;                                    %the illumination taper //by thesis of G.M.Skofronick
%% 以下是不需每个频点修改的辐射计参数
c=3e8;                                                      %光速 unit m/s
wavelength = c/freq;                                        %波长 unit:m
integral_time = 40*10^(-3);                                 %积分时间, unit:S                                           
T_rec=290*(10^(noise_figure/10)-1);                         %辐射计等效噪声温度, unit:K
TA_mean = mean(mean(TB));                                       %平均输入天线亮温TA，单位：K
NEDT = (T_rec+TA_mean)/sqrt(bandwith*integral_time);            %辐射计灵敏度，单位：K
Ba = pi*antenna_diameter/wavelength;                        %天线电长度参数
%%***************************设置扫描采样角度间距设置*******************
%设置方案一：按照辐射计最高工作频段的波束宽度的某一倍数设置
% sample_freq = 424.763e9;                                   %辐射计最高工作频段
% sample_factor = 1;                                         %采样系数，为采样间隔与最高频段波束宽度之比
% sample_wavelength = c/sample_freq;                         %辐射计最高工作频段的波长
% sample_antenna_diameter = 2.4;
% sample_beam=sample_wavelength/sample_antenna_diameter*180/pi;%辐射计最高工作频段对应波束宽度
% sample_width = sample_factor*sample_beam;                  %载荷天线扫描间隔，单位：度
% sample_width_Lat = max(sample_width,d_Lat);                %在纬度方向天线采样的格点角度
% sample_width_Long = max(sample_width,d_Long);              %在经度方向天线采样的格点角度
%设置方案二：按照当前输入图像的最小网格的倍数设置采样宽度
sample_factor = 2;
sample_width_Lat = sample_factor*d_Lat;                      %在纬度方向天线采样的格点角度
sample_width_Long = sample_factor*d_Long;                    %在经度方向天线采样的格点角度
sample_width = sample_width_Long;
%设置方案三：按照当前工作频段的波束宽度的某一倍数设置
% sample_factor = 0.5;                                       %采样系数，为采样间隔与当前频率波束宽度之比
% sample_width = sample_factor*beam_width;                   %载荷天线扫描间隔，单位：度
% sample_width_Lat = max(sample_width,d_Lat);                %在纬度方向天线采样的格点角度
% sample_width_Long = max(sample_width,d_Long);              %在经度方向天线采样的格点角度
%设置方案四：直接按照某一地面扫描间距设置
% sample_width = 0.01;                                       %载荷天线扫描间隔，单位：度
% sample_width_Lat = max(sample_width,d_Lat);                %在纬度方向天线采样的格点角度
% sample_width_Long = max(sample_width,d_Long);              %在经度方向天线采样的格点角度
%part2：end**************************************************************************************************************************************************



%% ********************************************************part3：模拟辐射计天线扫描观测成像过程，计算观测后的输出亮温图像TA**************************************
%计算系统天线方向图及其指标参数
[Antenna_Pattern,HPBW,SLL,MBE] = RA_antenna_pattern_2D(Ba,Coordinate_Long,Coordinate_Lat,angle_Long,angle_Lat,illumination_taper,freq_index,flag_draw_pattern);
ground_resolution = HPBW/180*pi*orbit_height;                  %计算地面分辨率
sample_density = HPBW/sample_width;                            %波束宽度与采样间隔的比值，代表每个波束范围内的采样个数

%模拟天线扫描方式获得观测亮温TA
% TA_noiseless = Antenna_conv(TB,angle_Lat,angle_Long,theta_scene,phi_scene,sample_width_Long,sample_width_Lat,N_Long,N_Lat,Ba,illumination_taper);
TA_noiseless = Satellite_antenna_conv(TB,angle_Lat,angle_Long,theta_scene,phi_scene,sample_width_Long,sample_width_Lat,N_Long,N_Lat,Ba,illumination_taper);

% %直接使用卷积函数计算观测亮温
% TA_noiseless = conv2(TB,Antenna_Pattern,'same');

%%%%给模拟观测亮温TA加上系统噪声
[TA] = add_image_noise(TA_noiseless,bandwith,integral_time,noise_figure);
figure;imagesc(Coordinate_Long,Coordinate_Lat,TA,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
xlabel('经度方向'); ylabel('纬度方向');title('观测亮温图像TA');colorbar;
%计算成像精度，用观测亮温TA与输入Tb的RMSE和相关系数来衡量
[RMSE] = Root_Mean_Square_Error(TB,TA,RMSE_offset,0);
Corr_coefficient = TB_correlation_coefficient(TB,TA,RMSE_offset);
%part3：end**************************************************************************************************************************************************


%% ********************************************************part4：解卷积分辨率增强处理*********************************************************************
if  flag_Resolution_Enhancement == 1;
    
    switch Resolution_Enhancement_name 
    % %可选算法有BG、Wiener Filter、SIR、ODC
    case 'BG'
        max_R = 0.02; 
        num_R = 4;
        [TA_RE,factor_opt] = Backus_Gilbert_deconv(TA_noiseless,TB,angle_Long,angle_Lat,Ba,illumination_taper,NEDT,num_R,max_R,RMSE_offset);
    case 'WienerFilter' 
        SNR_num = 100;
        [TA_RE,factor_opt] = Wiener_Filter_deconv(TA,TB,Antenna_Pattern,NEDT,SNR_num,RMSE_offset);
    case 'SIR'
         
    case 'ODC'
        
        
    end
    
    %画出分辨率增强处理后的亮温图像
    figure;imagesc(Coordinate_Long,Coordinate_Lat,TA_RE,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
    xlabel('经度方向'); ylabel('纬度方向');title([Resolution_Enhancement_name,'分辨率增强处理后的亮温图像TA_RE']);colorbar;
    %计算分辨率增强后的观测精度，用重建亮温TA_RE与输入TB的RMSE和相关系数来衡量
    [RMSE_RE] = Root_Mean_Square_Error(TB,TA_RE,RMSE_offset,0);
     Corr_coefficient_RE = TB_correlation_coefficient(TB,TA_RE,RMSE_offset);
end
%part4：end*****************************************************************************************************************************************


%% ********************************************************part5：显示仿真指标并存储仿真数据************************************************


%%%%%%%%%%显示仿真得到系统指标和成像精度%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Ch.',num2str(freq_index),'--',num2str(freq/1e9),'GHz频段，',num2str(antenna_diameter),'米口径的实孔径辐射计载荷（@taper=',num2str(illumination_taper),')']);
disp(['3dB波束宽度=',num2str(roundn(HPBW,-3)),'゜','，地面分辨率=',num2str(roundn(ground_resolution,-1)),'公里']);
disp(['天线扫描地面间距=',num2str(roundn(sample_width/180*pi*orbit_height,-1)),'公里,采样密度=',num2str(roundn(sample_density,-1))]);
disp(['第一副瓣电平=',num2str(roundn(SLL,-1)),'dB']);
disp(['主波束效率MBE=',num2str(roundn(MBE,-1)),'%']);
disp(['实孔径辐射计亮温灵敏度=',num2str(roundn(NEDT,-2)),'K']);  
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷观测亮温TA的RMSE=',num2str(roundn(RMSE,-2)),'K']);
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷观测图像TA与场景亮温TB的相关系数=',num2str(roundn(Corr_coefficient,-3))]);
if  flag_Resolution_Enhancement == 1;
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷分辨率增强亮温TA_RE的RMSE=',num2str(roundn(RMSE_RE,-2)),'K@',num2str(factor_opt)]);
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷分辨率增强亮温TA_RE与场景亮温TB的相关系数=',num2str(roundn(Corr_coefficient_RE,-3)),'@',num2str(factor_opt)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_save == 1
   FileName = sprintf('RA_%s_D%s_q%d_τ%s', TB_filename,num2str(round(antenna_diameter*1000)),illumination_taper,num2str(integral_time));
   if flag_Resolution_Enhancement == 1;
   FileName = sprintf('%s_%s', FileName,Resolution_Enhancement_name);
   end
   MatFileName = sprintf('%s.mat', FileName);
   save(['..\RA仿真结果\' MatFileName],'TA_noiseless','TA','Antenna_Pattern','HPBW','SLL','MBE','RMSE','Corr_coefficient','ground_resolution'); 
   if  flag_Resolution_Enhancement == 1;
   save(['..\RA仿真结果\' MatFileName],'TA_RE','RMSE_RE','Corr_coefficient_RE','factor_opt','-append'); 
   end
end
%part5：end**************************************************************************************************************************************************

toc;