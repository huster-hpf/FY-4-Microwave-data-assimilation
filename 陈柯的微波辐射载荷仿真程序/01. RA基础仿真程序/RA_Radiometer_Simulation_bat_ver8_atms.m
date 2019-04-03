%本程序模拟实孔径辐射计载荷观测亮温
%by 陈柯 2015.11.10 --updated 2016.10.19 

% clear;
close all;
tic
%%***************************以下部分是设置标志位和轨道参数***************************************************************************************************
flag_draw_TB = 0;                               %画出输入亮温TB 
flag_draw_TA = 0;                               %画出观测亮温TA 
flag_draw_pattern = 0;                          %画天线方向图标志位
flag_save =   1;                               %数据存储标志位
flag_Resolution_Enhancement  = 0;               %使用分辨率增强后处理标志位
Resolution_Enhancement_name = 'BG';             %可选算法有BG、WienerFilter、SIR、ODC
RMSE_offset  =0;                                %观测图像与原始图像对比时图像边缘去掉的行或列数
R = 6371;                                       %地球半径 unit:km
orbit_height = 35786;                           %轨道高度（当前为地球静止轨道）, unit:km
%************************************************************************************************************************************************************

%% ********************************************************part1：设置输入图像场景参数：空间坐标和亮温值********************************************
%根据选择模拟亮温场景读取对应频段的模拟亮温图像
% file_path = 'F:\myfile\WeChat Files\hpf950409\Files';   %文件存储录
% file_path1='F:\myfile\WeChat Files\hpf950409\Files';
%计算场景在经度和纬度方向的观测角范围
% scene_time='2018-03-07_00_00_00';
scene_time=sprintf('%s-%s-%s_%s_%s_00',time(1:4),time(5:6),time(7:8),time(9:10),time(11:12));
% scene_name = 'TyphoonMaria_08_12';
scene_name=sprintf('Typhoon%s_%s_%s_%s',typhoon_name,time(7:8),time(9:10),time(11:12));
Payload_name = 'ATMS';
channel_start_index = 1;
channel_end_index = 22;
channel_num = channel_end_index-channel_end_index+1;
coordinate_filename = sprintf('%s/coords.mat', file_path1);
[angle_Long,angle_Lat] = Image_Long_Lat_calc(coordinate_filename,R,orbit_height);


%定义仿真结束后要全部显示的仿真结果
   RMSE_list  = zeros(channel_num,1);   Corr_coefficient_list =zeros(channel_num,1); ground_resolution_list = zeros(channel_num,1);
   NEDT_list  = zeros(channel_num,1);   HPBW_list = zeros(channel_num,1);   SLL_list = zeros(channel_num,1);  MBE_list =zeros(channel_num,1); 
   if  flag_Resolution_Enhancement == 1
       RMSE_RE_list = zeros(channel_num,1);   Corr_coefficient_RE_list = zeros(channel_num,1);   factor_opt_list = zeros(channel_num,1);
   end

% 批量文件仿真
% file_path = 'D:\正在处理的程序\2012.10.29 Hurricansandy1500-NAM时间序列';


% for freq_index = channel_start_index:channel_end_index    
for freq_index = [[1:22]],
     %TB_filename = sprintf('C%s_%s.mat', num2str(freq_index),scene_time); %亮温图像文件名
     TB_filename = sprintf('%s_C%s_H.mat',scene_name,num2str(freq_index));
     TB_matfile = sprintf('%s/%s', file_path,TB_filename);
     if(exist(TB_matfile,'file')~=2)
        continue;
     end
     load(TB_matfile); TB=(TbMap(:,:)'); 
%      [N_Lat1,N_Long1] = size(TB); 
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
%part1：end**************************************************************************************************************************************************


%% ********************************************************part2：辐射计载荷参数与扫描采样参数设置**************************************************************
%%***************************设置辐射计参数******************************
%% 以下是每个频点需要修改的辐射计参数
    switch freq_index   %中心频率,单位:Hz  %带宽, 单位:Hz     %噪声系数,单位:dB   %天线口径，单位：米
             case 1, freq= 23.8e9;   bandwith = 270e6;    noise_figure= 4.5;antenna_diameter = 0.175; integral_time = 18*10^(-3);  
             case 2, freq= 31.4e9;   bandwith = 180e6;    noise_figure= 5;  antenna_diameter = 0.135; integral_time = 18*10^(-3);  
             case 3, freq= 50.3e9;   bandwith = 180e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 4, freq= 51.76e9;  bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 5, freq= 52.8e9;   bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 6, freq= 53.596e9; bandwith = 2*170e6;  noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 7, freq= 54.4e9;   bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 8, freq= 54.94e9;  bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 9, freq= 55.5e9;   bandwith = 330e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 10,freq= 57.29e9;  bandwith = 2*155e6;  noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 11,freq= 57.507e9; bandwith = 2*78e6;   noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 12,freq= 57.66e9;  bandwith = 2*36e6;   noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 13,freq= 57.63e9;  bandwith = 2*16e6;   noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 14,freq= 57.62e9;  bandwith = 2*8e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 15,freq= 57.617e9; bandwith = 2*3e6;    noise_figure= 6;  antenna_diameter = 0.185; integral_time = 18*10^(-3);  
             case 16,freq= 88.2e9;   bandwith = 2000e6;   noise_figure= 9;  antenna_diameter = 0.11;  integral_time = 18*10^(-3);  
             case 17,freq= 165.5e9;  bandwith = 2*1150e6; noise_figure= 12; antenna_diameter = 0.11;  integral_time = 18*10^(-3);  
             case 18,freq= 190.31e9; bandwith = 2*2000e6; noise_figure= 12; antenna_diameter = 0.11;  integral_time = 18*10^(-3);  
             case 19,freq= 187.81e9; bandwith = 2*2000e6; noise_figure= 12; antenna_diameter = 0.11;  integral_time = 18*10^(-3);  
             case 20,freq= 186.31e9; bandwith = 2*1000e6; noise_figure= 12; antenna_diameter = 0.11;  integral_time = 18*10^(-3);  
             case 21,freq= 185.11e9; bandwith = 2*1000e6; noise_figure= 12; antenna_diameter = 0.11;  integral_time = 18*10^(-3);  
             case 22,freq= 184.31e9; bandwith = 2*500e6;  noise_figure= 12; antenna_diameter = 0.11;  integral_time = 18*10^(-3);
        
%              case 1, freq= 50.3e9;   bandwith = 180e6;    noise_figure= 5;  antenna_diameter = 5;                      
%              case 2, freq= 51.76e9;  bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5;                     
%              case 3, freq= 52.8e9;   bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5;                     
%              case 4, freq= 53.596e9; bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5;                     
%              case 5, freq= 54.4e9;   bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5;                     
%              case 6, freq= 54.94e9;  bandwith = 400e6;    noise_figure= 5;  antenna_diameter = 5;                      
%              case 7, freq= 55.5e9;   bandwith = 330e6;    noise_figure= 5;  antenna_diameter = 5;                     
%              case 8, freq= 57.29e9;  bandwith = 330e6;    noise_figure= 5;  antenna_diameter = 5; 
%              case 9, freq= 57.507e9; bandwith = 2*78e6;   noise_figure= 5;  antenna_diameter = 5; 
%              case 10,freq= 57.66e9;  bandwith = 4*36e6;   noise_figure= 5;  antenna_diameter = 5; 
%              case 11,freq= 57.63e9;  bandwith = 4*16e6;   noise_figure= 5;  antenna_diameter = 5; 
%              case 12,freq= 57.62e9;  bandwith = 4*8e6;    noise_figure= 5;  antenna_diameter = 5; 
%              case 13,freq= 57.617e9; bandwith = 4*3e6;    noise_figure= 5;  antenna_diameter = 5; 
%              case 14,freq= 88.2e9;   bandwith = 2000e6;   noise_figure= 7;  antenna_diameter = 5;                      
%              case 15,freq= 118.83e9; bandwith = 2*20e6;   noise_figure= 8;  antenna_diameter = 2.4;
%              case 16,freq= 118.95e9; bandwith = 2*100e6;  noise_figure= 8;  antenna_diameter = 2.4;
%              case 17,freq= 119.05e9; bandwith = 2*165e6;  noise_figure= 8;  antenna_diameter = 2.4;
%              case 18,freq= 119.55e9; bandwith = 2*200e6;  noise_figure= 8;  antenna_diameter = 2.4;                     
%              case 19,freq= 119.85e9; bandwith = 2*200e6;  noise_figure= 8;  antenna_diameter = 2.4;                     
%              case 20,freq= 121.25e9; bandwith = 2*200e6;  noise_figure= 8;  antenna_diameter = 2.4;                     
%              case 21,freq= 121.75e9; bandwith = 2*1000e6; noise_figure= 8;  antenna_diameter = 2.4;                     
%              case 22,freq= 123.75e9; bandwith = 2*2000e6; noise_figure= 8;  antenna_diameter = 2.4;                     
%              case 23,freq= 165.5e9;  bandwith = 3000e6;   noise_figure= 9;  antenna_diameter = 2.4;                    
%              case 24,freq= 190.31e9; bandwith = 2*2000e6; noise_figure= 9;  antenna_diameter = 2.4;                    
%              case 25,freq= 187.81e9; bandwith = 2*2000e6; noise_figure= 9;  antenna_diameter = 2.4;                    
%              case 26,freq= 186.31e9; bandwith = 2*1000e6; noise_figure= 9;  antenna_diameter = 2.4;                    
%              case 27,freq= 185.11e9; bandwith = 2*1000e6; noise_figure= 9;  antenna_diameter = 2.4;                     
%              case 28,freq= 184.31e9; bandwith = 2*500e6;  noise_figure= 9;  antenna_diameter = 2.4;                      
%              case 35,freq= 428.763e9;bandwith = 2*1000e6; noise_figure= 11; antenna_diameter = 2.4;                     
%              case 36,freq= 426.263e9;bandwith = 2*600e6;  noise_figure= 11; antenna_diameter = 2.4;                     
%              case 37,freq= 425.763e9;bandwith = 2*400e6;  noise_figure= 11; antenna_diameter = 2.4;                   
%              case 38,freq= 425.363e9;bandwith = 2*200e6;  noise_figure= 11; antenna_diameter = 2.4;                     
%              case 39,freq= 425.063e9;bandwith = 2*100e6;  noise_figure= 11; antenna_diameter = 2.4;
%              case 40,freq= 424.913e9;bandwith = 2*60e6;   noise_figure= 11; antenna_diameter = 2.4;
%              case 41,freq= 424.833e9;bandwith = 2*20e6;   noise_figure= 11; antenna_diameter = 2.4;
%              case 42,freq= 424.793e9;bandwith = 2*10e6;   noise_figure= 11; antenna_diameter = 2.4;
%              case 29,freq= 398.197e9;bandwith = 2*2000e6; noise_figure= 11; antenna_diameter = 2.4;
%              case 30,freq= 389.197e9;bandwith = 2*2000e6; noise_figure= 11; antenna_diameter = 2.4;
%              case 31,freq= 384.197e9;bandwith = 2*900e6;  noise_figure= 11; antenna_diameter = 2.4;
%              case 32,freq= 381.697e9;bandwith = 2*500e6;  noise_figure= 11; antenna_diameter = 2.4;
%              case 33,freq= 380.597e9;bandwith = 2*200e6;  noise_figure= 11; antenna_diameter = 2.4;
%              case 34,freq= 380.242e9;bandwith = 2*1000e6; noise_figure=11 ; antenna_diameter = 2.4;                
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
    sample_factor = 1;
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
    ground_resolution = HPBW/180*pi*orbit_height;
    sample_density = HPBW/sample_width;                           %波束宽度与采样间隔的比值，代表每个波束范围内的采样个数

%模拟天线扫描方式获得观测亮温TA
    TA_noiseless = Antenna_conv(TB,angle_Lat,angle_Long,sample_width_Long,sample_width_Lat,N_Long,N_Lat,Ba,illumination_taper);
% %直接使用卷积函数计算观测亮温
    % TA_noiseless = conv2(TB,Antenna_Pattern,'same');

%%%%给模拟观测亮温TA加上系统噪声
    TA = add_image_noise(TA_noiseless,bandwith,integral_time,noise_figure);
    if  flag_draw_TA == 1
        figure;imagesc(Coordinate_Long,Coordinate_Lat,TA,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
        xlabel('经度方向'); ylabel('纬度方向');title(['观测亮温图像TA@Ch.',num2str(freq_index),'@taper=',num2str(illumination_taper)]);colorbar;
    end
%part3：end**************************************************************************************************************************************************

%% ********************************************************part4：解卷积分辨率增强处理*********************************************************************
    if  flag_Resolution_Enhancement == 1;
        switch Resolution_Enhancement_name 
        % %可选算法有BG、Wiener Filter、SIR、ODC
          case 'BG'
            max_R = 0.1; 
            num_R = 5;
            [TA_RE,factor_opt] = Backus_Gilbert_deconv(TA_noiseless,TB,angle_Long,angle_Lat,Ba,illumination_taper,NEDT,num_R,max_R,RMSE_offset);
          case 'WienerFilter' 
            SNR_num = 100;
            [TA_RE,factor_opt] = Wiener_Filter_deconv(TA,TB,Antenna_Pattern,NEDT,SNR_num,RMSE_offset);
          case 'SIR'
            Block_num = 1;       %横纵分块数量
            [TA_RE,factor_opt] = Scatterometer_Image_Restruction(TA,TB,Block_num,sample_width_Lat,sample_width_Long,sample_factor,Ba,illumination_taper,angle_Long,angle_Lat,d_Long,d_Lat);
          case 'ODC'       
        end
    %画出分辨率增强处理后的亮温图像
        figure;imagesc(Coordinate_Long,Coordinate_Lat,TA_RE,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
        xlabel('经度方向'); ylabel('纬度方向');title([Resolution_Enhancement_name,'增强亮温图像TA@Ch.',num2str(freq_index),'@taper=',num2str(illumination_taper)]);colorbar;
    %计算分辨率增强后的观测精度，用重建亮温TA_RE与输入TB的RMSE和相关系数来衡量
        [RMSE_RE] = Root_Mean_Square_Error(TB,TA_RE,RMSE_offset,0);
        Corr_coefficient_RE = TB_correlation_coefficient(TB,TA_RE,RMSE_offset);
    end
%part4：end*****************************************************************************************************************************************


%% ********************************************************part5：显示仿真指标并存储仿真数据************************************************
%计算程序精度，用观测亮温TA与输入Tb的RMSE来衡量
    [RMSE] = Root_Mean_Square_Error(TB,TA,RMSE_offset,0);
    Corr_coefficient = TB_correlation_coefficient(TB,TA,RMSE_offset);
%%%%%%%%%%显示仿真得到系统指标和成像精度%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(['Ch.',num2str(freq_index),'--',num2str(freq/1e9),'GHz频段，',num2str(antenna_diameter),'米口径的实孔径辐射计载荷（@taper=',num2str(illumination_taper),')']);
% disp(['3dB波束宽度=',num2str(roundn(HPBW,-3)),'゜','，地面分辨率=',num2str(roundn(ground_resolution,-1)),'公里']);
% disp(['天线扫描地面间距=',num2str(roundn(sample_width/180*pi*orbit_height,-1)),'公里,采样密度=',num2str(roundn(sample_density,-1))]);
% disp(['第一副瓣电平=',num2str(roundn(SLL,-1)),'dB']);
% disp(['主波束效率MBE=',num2str(roundn(MBE,-1)),'%']);
% disp(['实孔径辐射计亮温灵敏度=',num2str(roundn(NEDT,-2)),'K']);  
% disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷观测亮温TA的RMSE=',num2str(roundn(RMSE,-2)),'K']);
% disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷观测图像TA与场景亮温TB的相关系数=',num2str(roundn(Corr_coefficient,-3))]);
% if  flag_Resolution_Enhancement == 1;
% disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷分辨率增强亮温TA_RE的RMSE=',num2str(roundn(RMSE_RE,-2)),'K@',num2str(factor_opt)]);
% disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷分辨率增强亮温TA_RE与场景亮温TB的相关系数=',num2str(roundn(Corr_coefficient_RE,-3)),'@',num2str(factor_opt)]);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if flag_save == 1
%        FileName = sprintf('GOES_%s_C%d_%s',Payload_name,freq_index,scene_name);
       FileName=sprintf('%s_C%s_H',scene_name,num2str(freq_index));
       if flag_Resolution_Enhancement == 1;
          FileName = sprintf('%s_%s', FileName,Resolution_Enhancement_name);
       end
       
%        save(['..\05. RA仿真结果\' MatFileName],'TA_noiseless','TA','Antenna_Pattern','NEDT','HPBW','SLL','MBE','RMSE','Corr_coefficient','ground_resolution');
       save([output_dir '//' FileName],'TA');
       if  flag_Resolution_Enhancement == 1;
%            save(['..\05. RA仿真结果\' MatFileName],'TA_RE','RMSE_RE','Corr_coefficient_RE','factor_opt','-append'); 
           save(['C:\Users\ai\Desktop\send_beijing\TB_WRF\output_noangle\' FileName],'TA_RE','RMSE_RE','Corr_coefficient_RE','factor_opt','-append');
       end
    end   
   %给所有channel仿真结果列表赋值
   RMSE_list(freq_index) = RMSE;   
   Corr_coefficient_list(freq_index) = Corr_coefficient; 
   NEDT_list(freq_index) = NEDT;  HPBW_list(freq_index) = HPBW;  SLL_list(freq_index) = SLL;MBE_list(freq_index) =MBE;
   ground_resolution_list(freq_index) = ground_resolution;  
   if  flag_Resolution_Enhancement == 1;
       RMSE_RE_list(freq_index) = RMSE_RE; factor_opt_list (freq_index) =factor_opt;Corr_coefficient_RE_list(freq_index) = Corr_coefficient_RE;
   end
%part5：end**************************************************************************************************************************************************
end

% disp([Payload_name,'载荷对',scene_name,'@',Resolution_Enhancement_name,'分辨率增强算法处理的','仿真结果']);
% disp('观测RMSE');
% disp(roundn(RMSE_list,-2));
% disp('----------------------------------------------')
% disp(['观测相关系数']);
% disp(roundn(Corr_coefficient_list,-3));
% disp('----------------------------------------------')
% disp(['灵敏度']);
% disp(roundn(NEDT_list,-2));
% disp('----------------------------------------------')
% disp(['3dB波束宽度']);
% disp(roundn(HPBW_list,-3));
% disp('----------------------------------------------')
% disp(['地面分辨率']); 
% disp(roundn(ground_resolution_list,0));
% disp('----------------------------------------------')
% disp(['副瓣电平']);
% disp(roundn(SLL_list,-1));
% disp('----------------------------------------------')
% disp(['主波束效率']);
% disp(roundn(MBE_list,-1));
% if  flag_Resolution_Enhancement == 1;
%     disp('----------------------------------------------')
%     disp('分辨率增强处理后的RMSE');
%     disp(roundn(RMSE_RE_list,-2));
%     disp('----------------------------------------------')
%     disp(['分辨率增强处理后的相关系数']);
%     disp(roundn(Corr_coefficient_RE_list,-3));
%     disp('----------------------------------------------')
%     disp(['分辨率增强最优参数值factor']);
%     disp(factor_opt_list);
% end
% 
% if flag_save == 1;
%    SaveFileName = sprintf('GOES-MW%s_C%d_%s',Payload_name,freq_index,scene_name);
%    if flag_Resolution_Enhancement == 1;
%       SaveFileName = sprintf('%s_%s', SaveFileName,Resolution_Enhancement_name);
%    end
%    SaveMatFileName = sprintf('%s_result_list.mat', SaveFileName);
%    %save(['C:\Users\ai\Desktop\send_beijing\TB_WRf\output_noangle\' SaveMatFileName],'RMSE_list','Corr_coefficient_list','NEDT_list','HPBW_list','ground_resolution_list','SLL_list','MBE_list');
%    if  flag_Resolution_Enhancement == 1;
%     save(['C:\Users\ai\Desktop\send_beijing\TB_WRF\output_noangle\' SaveMatFileName],'RMSE_RE_list','Corr_coefficient_RE_list','factor_opt_list','-append'); 
%    end    
% end
toc;
