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
flag_draw_TB = 0;
flag_draw_TA = 0;
flag_draw_TA_Enhancement = 1;
flag_save = 0;


%% ********************************************************part1：设置输入图像场景参数：空间坐标和亮温值****************************************************
   %亮温图像文件目录
   TBmat_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\01. 仿真亮温数据\2016.09.30 飓风彩虹rainbow-GFS-20151002\亮温图像'; 
   %计算场景在经度和纬度方向的观测角范围,确定视场
   coordinate_filename = sprintf('%s\\coords.mat', TBmat_path);
   [angle_Long,angle_Lat] = Image_Long_Lat_calc(coordinate_filename,R,orbit_height);
   scene_name = 'HurricanRainbow_03_06';
   channel_start_index = 1;
   channel_end_index = 37;
   
   %定义仿真结束后要全部显示的仿真结果
   RMSE_list = [];
   Corr_coefficient_list =[];
   NEDT_list = [];  
   HPBW_list = [];
   ground_resolution_list = [];
   SLL_list = [];
   MBE_list =[]; 
   if  flag_Resolution_Enhancement == 1
   RMSE_RE_list = [];
   Corr_coefficient_RE_list =[];
   factor_opt_list = [];
   end
   
% 设置要批量仿真的通道编号
for freq_index = channel_start_index:channel_end_index    
   %%%%%%%%%%导入外部亮温图像%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   %根据选择模拟亮温场景读取对应频段的模拟亮温图像
   TB_filename = sprintf('%s_C%s_H.mat', scene_name,num2str(freq_index));
   TB_matfile = sprintf('%s\\%s', TBmat_path,TB_filename);
   load(TB_matfile);
   TB=(pic);
   T_max=max(max(TB));
   T_min=min(min(TB));
   [N_Lat,N_Long] = size(TB);
   
   switch freq_index   %中心频率,单位:Hz  %带宽, 单位:Hz     %噪声系数,单位:dB   %天线口径，单位：米
        case 1, T_min=220;
        case 2, T_min=235;
        case 3, T_min=235;
        case 4, T_min=240;
        case 5, T_min=239;
        case 6, T_min=231;
        case 7, T_min=220;
        case 14,T_min = 210;
        case 18, T_min=230;
        case 19, T_min=240;
        case 20, T_min=225;
        case 21, T_min=225;
        case 22, T_min=225;
        case 23, T_min=200;
        case 24, T_min=215;
        case 25, T_min =225;
        case 26, T_min=235;
        case 27, T_min=240;
        case 28, T_min=237;
        case 29, T_min=212;
        case 30, T_min=227;
        case 31, T_min =230; 
        case 32, T_min=220;
        case 33, T_min=205;           
   end
   
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
   
   
   TAmat_path = 'E:\百度云同步盘\陈柯的微波辐射载荷仿真程序\RA仿真结果';
   if freq_index<15
   antenna_diameter = 5000;
   else 
   antenna_diameter = 2400;    
   end
   sample_interval = 12;
   integral_time = 0.04; 
   illumination_taper_num = 2;
   
   %设置不同taper值时需要存储的变量
   RMSE_taper =zeros(1,illumination_taper_num) ;
   Corr_coefficient_taper=zeros(1,illumination_taper_num) ;
   NEDT_taper=zeros(1,illumination_taper_num) ;
   HPBW_taper=zeros(1,illumination_taper_num) ;
   ground_resolution_taper=zeros(1,illumination_taper_num) ;
   SLL_taper=zeros(1,illumination_taper_num) ;
   MBE_taper=zeros(1,illumination_taper_num) ;
   if  flag_Resolution_Enhancement == 1
   RMSE_RE_taper=zeros(1,illumination_taper_num) ;
   Corr_coefficient_RE_taper=zeros(1,illumination_taper_num) ;
   factor_opt_taper=zeros(1,illumination_taper_num) ;
   end 
   
   
 for illumination_taper = 0:illumination_taper_num-1
   
   TA_filename = sprintf('RA_%s_C%d_H_D%d_q%d_τ%s_sample%d', scene_name,freq_index,antenna_diameter,illumination_taper,num2str(integral_time),sample_interval); %亮温图像文件名
   if flag_Resolution_Enhancement == 1;
       TA_filename = sprintf('%s_%s', TA_filename,Resolution_Enhancement_name);
   end
    TA_filename = sprintf('%s.mat', TA_filename);
    TAMatFileName = sprintf('%s\\%s',TAmat_path,TA_filename);
    load(TAMatFileName);
    %画出观测亮温TA      
    if flag_draw_TA == 1
    figure;imagesc(Coordinate_Long,Coordinate_Lat,TA,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
    xlabel('经度方向'); ylabel('纬度方向');title(['观测亮温图像TA@Ch.',num2str(freq_index),'@taper=',num2str(illumination_taper)]);colorbar;
    end
    %画出分辨率增强处理后的观测亮温TA_RE 
    if flag_Resolution_Enhancement  == 1;
       if flag_draw_TA_Enhancement == 1
        figure;imagesc(Coordinate_Long,Coordinate_Lat,TA_RE,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
        xlabel('经度方向'); ylabel('纬度方向');title([Resolution_Enhancement_name,'增强亮温图像TA@Ch.',num2str(freq_index),'@taper=',num2str(illumination_taper)]);colorbar;
       end
    end
    
   %给每个channel所有taper值仿真结果列表赋值
   RMSE_taper(illumination_taper+1) = RMSE;
   Corr_coefficient_taper(illumination_taper+1) =Corr_coefficient;
   Corr_coefficient_RE_taper(illumination_taper+1) =Corr_coefficient_RE;
   NEDT_taper(illumination_taper+1) = NEDT;  
   HPBW_taper(illumination_taper+1) = HPBW;
   ground_resolution_taper(illumination_taper+1) = ground_resolution;
   SLL_taper(illumination_taper+1) = SLL;
   MBE_taper(illumination_taper+1) = MBE;
   if  flag_Resolution_Enhancement == 1
   RMSE_RE_taper(illumination_taper+1) = RMSE_RE;
   Corr_coefficient_RE_taper(illumination_taper+1) =Corr_coefficient_RE;
   factor_opt_taper(illumination_taper+1)=factor_opt;
   end 
 end
   %给所有channel仿真结果列表赋值
   RMSE_list = [RMSE_list;RMSE_taper];
   Corr_coefficient_list =[Corr_coefficient_list;Corr_coefficient_taper];
   NEDT_list = [NEDT_list;NEDT_taper];  
   HPBW_list = [HPBW_list;HPBW_taper];
   ground_resolution_list = [ground_resolution_list;ground_resolution_taper];
   SLL_list = [SLL_list;SLL_taper];
   MBE_list =[MBE_list;MBE_taper];
   if  flag_Resolution_Enhancement == 1
   RMSE_RE_list = [RMSE_RE_list;RMSE_RE_taper];
   Corr_coefficient_RE_list =[Corr_coefficient_RE_list;Corr_coefficient_RE_taper];
   factor_opt_list=[factor_opt_list;factor_opt_taper];
   end 
 end
  


%part1：end****************************************************************************************************************************************************************

disp(['实孔径辐射计载荷对天气场景—',scene_name,'@',Resolution_Enhancement_name,'分辨率增强算法处理的','仿真结果']);
disp('taper=0, taper=1')
disp('----------------------------------------------')
disp('观测RMSE');
disp(roundn(RMSE_list,-2));
if  flag_Resolution_Enhancement == 1
disp('----------------------------------------------')
disp('分辨率增强处理后的RMSE');
disp(roundn(RMSE_RE_list,-2));
end
disp('----------------------------------------------')
disp(['观测相关系数']);
disp(roundn(Corr_coefficient_list,-3));
if  flag_Resolution_Enhancement == 1
disp('----------------------------------------------')
disp(['分辨率增强处理后的相关系数']);
disp(roundn(Corr_coefficient_RE_list,-3));
disp('----------------------------------------------')
disp(['分辨率增强最优参数值factor']);
disp(factor_opt_list);
end
disp('----------------------------------------------')
disp(['灵敏度']);
disp(roundn(NEDT_list,-2));
disp('----------------------------------------------')
disp(['3dB波束宽度']);
disp(roundn(HPBW_list,-3));
disp('----------------------------------------------')
disp(['地面分辨率']); 
disp(roundn(ground_resolution_list,0));
disp('----------------------------------------------')
disp(['副瓣电平']);
disp(roundn(SLL_list,-1));
disp('----------------------------------------------')
disp(['主波束效率']);
disp(roundn(MBE_list,-1));


if flag_save == 1;
   SaveFileName = sprintf('RA_%s_D%d_τ%s_sample%d',scene_name,antenna_diameter,num2str(integral_time),sample_interval);
   if flag_Resolution_Enhancement == 1;
   SaveFileName = sprintf('%s_%s', SaveFileName,Resolution_Enhancement_name);
   end
   SaveMatFileName = sprintf('%s_result_list.mat', SaveFileName);
   save(['..\RA仿真结果\' SaveMatFileName],'RMSE_list','Corr_coefficient_list','NEDT_list','HPBW_list','ground_resolution_list','SLL_list','MBE_list');
   if  flag_Resolution_Enhancement == 1;
   save(['..\RA仿真结果\' SaveMatFileName],'RMSE_RE_list','Corr_coefficient_RE_list','factor_opt_list','-append'); 
   end    
end

toc;