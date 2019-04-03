%本程序实现二维亮温图像综合孔径定量反演仿真 
%本程序支持多个窗函数的亮温仿真
%版本号 Ver1.0 
%版权所有 by 陈柯 华中科技大学 电信学院 2016.10.25

tic;
close all
clear


%仿真静态参数设置
RMSE_offset = 20;  %观测图像与原始图像对比时图像边缘去掉的行或列数
R = 6371;                     %地球半径 unit:km
orbit_height = 35786;         %轨道高度（当前为地球静止轨道）, unit:km
flag_Resolution_Enhancement  = 1;               %使用分辨率增强后处理标志位
Resolution_Enhancement_name = 'BG';             %可选算法有BG、WienerFilter、SIR、ODC
flag_draw_TB = 0;                               %画出输入亮温TB 
flag_draw_TA = 0;                               %画出观测亮温TA 
flag_draw_TA_Enhancement = 1;
flag_draw_pattern = 1;



%% ********************************************************part1：设置输入图像场景参数：空间坐标和亮温值****************************************************
   %亮温图像文件目录
   TBmat_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\01. 仿真亮温数据\2016.09.30 飓风彩虹rainbow-GFS-20151002\亮温图像'; 
   %计算场景在经度和纬度方向的观测角范围
   coordinate_filename = sprintf('%s\\coords.mat', TBmat_path);
   [angle_Long,angle_Lat] = Image_Long_Lat_calc(coordinate_filename,R,orbit_height);
   TAmat_path = 'E:\百度云同步盘\陈柯的微波辐射载荷仿真程序\08. 新版GOES模拟亮温';    
   scene_name = 'HurricanRainbow_03_06';
   Payload_name = 'GEM5';
   channel_start_index = 1;
   channel_end_index = 37;
   
disp(['波束宽度 波束宽度RE 地面分辨率 地面分辨率RE 副瓣电平 副瓣电平RE 主波束效率 主波束效率RE']);
   
% 设置要批量仿真的通道编号
for freq_index = [[1:7],14,18,19,[21:26],28,[30:32],[38:41]]
% for freq_index = [[30:32],[38:41]]
% for freq_index = channel_start_index:channel_end_index  
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
             case 14,freq= 88.2e9;   bandwith = 2000e6;   noise_figure= 7;  antenna_diameter = 2.4;                      
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
             case 38,freq= 398.197e9;bandwith = 2*2000e6; noise_figure= 11; antenna_diameter = 2.4;
             case 39,freq= 389.197e9;bandwith = 2*2000e6; noise_figure= 11; antenna_diameter = 2.4;
             case 40,freq= 384.197e9;bandwith = 2*900e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 41,freq= 381.697e9;bandwith = 2*500e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 42,freq= 380.597e9;bandwith = 2*200e6;  noise_figure= 11; antenna_diameter = 2.4;
             case 43,freq= 380.242e9;bandwith = 2*30e6;   noise_figure= 11; antenna_diameter = 2.4;
             case 44,freq= 23.8e9;   bandwith = 270e6;    noise_figure= 4;  antenna_diameter = 5;
             case 45,freq= 31.4e9;   bandwith = 180e6;    noise_figure= 4;  antenna_diameter = 5;
                 
    end     
    
%% 以下是不需每个频点修改的辐射计参数
    c=3e8;                                                      %光速 unit m/s
    wavelength = c/freq;                                        %波长 unit:m
    integral_time = 40*10^(-3);                                 %积分时间, unit:S                                           
    T_rec = 290*(10^(noise_figure/10)-1);                         %辐射计等效噪声温度, unit:K
    T_A = 250;                                                  %假设平均输入天线亮温TA，单位：K
    NEDT = (T_rec+T_A)/sqrt(bandwith*integral_time);            %辐射计灵敏度，单位：K
    Ba = pi*antenna_diameter/wavelength;                        %天线电长度参数
    illumination_taper = 1;                                 %the illumination taper //by thesis of G.M.Skofronick

   %%%%%%%%%%导入外部亮温图像%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   %根据选择模拟亮温场景读取对应频段的模拟亮温图像
   TB_filename = sprintf('%s_C%s_H.mat', scene_name,num2str(freq_index));
   TB_matfile = sprintf('%s\\%s', TBmat_path,TB_filename);
   load(TB_matfile);   TB=(pic);
   T_max=max(max(TB)); T_min=min(min(TB));
   [N_Lat,N_Long] = size(TB);
   %计算图像空间角度坐标参数*********************************************
    %计算空间格点大小
    d_Long = angle_Long/(N_Long);                  %亮温图像经度方向最小间距，即角度分辨率  
    d_Lat = angle_Lat/(N_Lat);                     %亮温图像纬度方向最小间距，即角度分辨率 
    %计算图像的真实空间二维角度坐标值
    Coordinate_Long = linspace(-angle_Long/2,angle_Long/2-d_Long,N_Long);   %经度角度坐标向量
    Coordinate_Lat = linspace(-angle_Lat/2,angle_Lat/2-d_Lat,N_Lat);        %纬度角度坐标向量
    [Fov_Long,Fov_Lat] = meshgrid(Coordinate_Long,Coordinate_Lat);          %经度纬度方向二维坐标矩阵
    %画出输入亮温图像
    if  flag_draw_TB == 1;
        figure;imagesc(Coordinate_Long,Coordinate_Lat,TB,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
        xlabel('经度方向'); ylabel('纬度方向');title(['原始亮温图像TB@Ch.',num2str(freq_index)]);colorbar;
    end
   
   TA_filename = sprintf('GOES_%s_C%s_%s_%s.mat', Payload_name,num2str(freq_index),scene_name,Resolution_Enhancement_name);
   TA_matfile = sprintf('%s\\%s', TAmat_path,TA_filename);
   load(TA_matfile);
   if  flag_draw_TA == 1
        figure;imagesc(Coordinate_Long,Coordinate_Lat,TA,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
        xlabel('经度方向'); ylabel('纬度方向');title(['观测亮温图像TA@Ch.',num2str(freq_index),'@taper=',num2str(illumination_taper)]);colorbar;
   end
   if flag_draw_TA_Enhancement == 1;
       figure;imagesc(Coordinate_Long,Coordinate_Lat,TA_RE,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
       xlabel('经度方向'); ylabel('纬度方向');title([Resolution_Enhancement_name,'增强亮温图像TA@Ch.',num2str(freq_index),'@taper=',num2str(illumination_taper)]);colorbar;
   end
   [HPBW,SLL,MBE] = Antenna_Pattern_2D_parameter_calc(Antenna_Pattern,Coordinate_Long,Coordinate_Lat,angle_Long,angle_Lat,freq_index,flag_draw_pattern,Ba,illumination_taper);
    ground_resolution = HPBW/180*pi*orbit_height;  
   
   [HPBW_RE,SLL_RE,MBE_RE] = Antenna_Pattern_2D_parameter_calc(TA_PDF_RE,Coordinate_Long,Coordinate_Lat,angle_Long,angle_Lat,freq_index,flag_draw_pattern,Ba,illumination_taper);
    ground_resolution_RE = HPBW_RE/180*pi*orbit_height;
    disp([roundn(HPBW,-3);roundn(HPBW_RE,-3);roundn(ground_resolution,0);roundn(ground_resolution_RE,0);roundn(SLL,-1);roundn(SLL_RE,-1);roundn(MBE,-1);roundn(MBE_RE,-1)].');
end

toc;