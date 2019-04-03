%Forward TB to simulation POES TA
%by Ke Chen 2017.03.17 

clear;
close all;
tic;
%%***************************parameter setting**********************************************************
flag_L2 = 0;
flag_draw_TB = 1;                               %Plot TB  
flag_draw_pattern = 0;                          %Plot 
flag_save = 1;                                  %数据存储标志位
flag_Resolution_Enhancement  = 0;               %使用分辨率增强后处理标志位
Resolution_Enhancement_name = 'BG';             %可选算法有BG、WienerFilter、SIR、ODC
R = 6371;                                       %地球半径 unit:km
%**********************************************************************************************************************

%% ********************************************************part1：设置输入图像场景参数：空间坐标和亮温值********************************************
%设置待仿真的载荷亮温数据与正演亮温数据参数
observation_path = 'E:\百度云同步盘\08. 仿真亮温与观测亮温对比分析\2017.06.12-ATMS-HurricaneJoaquin_20151005\ATMS观测亮温';   %观测数据存储目录
file_path = 'E:\百度云同步盘\08. 仿真亮温与观测亮温对比分析\2017.06.12-ATMS-HurricaneJoaquin_20151005\TB-ATMS正演亮温';   %正演仿真亮温文件存储目录
satellite_payload = 'ATMS';                         %设置载荷名称
orbit_height = 824;                                 %设置载荷轨道高度, unit:km  ATMS：824km ， 风云三号：836km
observation_time = '2015-10-5-6：31：15-6：39：15'; %载荷观测亮温数据时间
scene_time = '2015-10-05-06：30：00';               %场景正演亮温数据时间
background_time = '2015-10-05-06：30：00';          %场景插值亮温数据时间
channel_start_index = 1;                            %设置亮温数据的频率通道编号起始
channel_end_index = 22;                             %设置亮温数据的频率通道编号终止 ATMS-22； FY3C_MWTS-13； FY3C-MWHTS-15；FY3B-MWTS-4；FY3B-MWHS-5
RT_model = 'DOTLRT';                                 %可以设置为‘DOTLRT’或'RTTOV'
%设置所有频率通道的仿真结果保存列表
num_channels = channel_end_index-channel_start_index+1;
POES_PayloadSpec_list = zeros(num_channels,5);
if  flag_Resolution_Enhancement == 1
    POES_result_list = zeros(num_channels,12);
else
    POES_result_list = zeros(num_channels,8);
end

for freq_channel = channel_start_index:channel_end_index %循环仿真每个频点的观测亮温                           
    
    %%%%%%%%读取低轨卫星载荷观测亮温数据     
    observation_filename =  sprintf('%s-c%d-%s', satellite_payload,freq_channel,observation_time);%观测亮温数据文件名
    observation_matfile = sprintf('%s\\%s.mat', observation_path,observation_filename);
    load(observation_matfile);                                          %读取观测亮温数据，包含Long、Lat、TB三个矩阵
    %载荷观测数据的经纬度坐标范围
    max_Long = double((max(max(Long))));min_Long = double((min(min(Long))));
    max_Lat = double((max(max(Lat))));min_Lat = double((min(min(Lat))));   
    Long_observation = Long;Lat_observation = Lat;      %观测数据格点经纬度坐标         
    TA_observation = double(TB);                                %观测亮温
    [num_Long,num_Lat] = size(Lat_observation);  num_observation =num_Long*num_Lat;       
    Long_Subsatellite = zeros(num_Lat,1);               %极轨卫星星下点经度坐标向量
    Lat_Subsatellite = zeros(num_Lat,1);                %极轨卫星星下点纬度坐标向量
    %取观测数据中心点为卫星星下点轨迹
    for k = 1:num_Lat
        Long_Subsatellite(k) = (Long_observation(num_Long/2,k)+Long_observation(num_Long/2+1,k))/2;
        Lat_Subsatellite(k) = (Lat_observation(num_Long/2,k)+Lat_observation(num_Long/2+1,k))/2;
    end
    if  flag_draw_TB == 1; %画出POES载荷观测亮温   
        figure;axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on;    
        ylabel('纬度(\circ)');xlabel('经度（\circ）'); 
        ObsTitleName=sprintf('%s-TA-CH%d-%s',satellite_payload,freq_channel,observation_time);title(ObsTitleName);
        h=pcolorm(double(Lat_observation), double(Long_observation), double(TA_observation)); set(h,'edgecolor','none');colorbar; 
        load coast;plotm(lat,long,'-k','LineWidth', 1.8);%画世界陆地界线        
    end  

    %%%%%%%%根据选择模拟亮温场景读取对应频段的模拟亮温图像    
    if flag_L2 ==1
       TB_filename =  sprintf('%s-L2-C%d-%s',satellite_payload,freq_channel,scene_time);%观测亮温数据文件名
       TB_matfile = sprintf('%s\\%s.mat', file_path,TB_filename);
       load(TB_matfile);TB=TbMap(:,:,1);
    else
       TB_filename =  sprintf('C%d_%s',freq_channel,scene_time);%观测亮温数据文件名
       TB_matfile = sprintf('%s\\%s.mat', file_path,TB_filename);
       load(TB_matfile);TB=flipud(TbMap(:,:,1).'); 
    end
       
        
%     load(TB_matfile);TB=flipud(Tb(:,:,1).'); 
    %决定画图的colorbar范围
    if freq_channel<10 || freq_channel>15
        T_max=max(max(TA_observation));T_min=min(min(TA_observation));
    else
        T_max=max(max(TB));T_min=min(min(TB));
    end
    %读取场景的经度和纬度坐标
    if flag_L2 ==1
        Long_scene = Long;Lat_scene = Lat;
    else
        coordinate_filename = sprintf('%s\\coords.mat', file_path);
        load(coordinate_filename);Long_scene =flipud(XLO.');Lat_scene = flipud(XLA.');
    end
    if  flag_draw_TB == 1; %画出输入正演亮温图像   
        figure;axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on; 
        load coast;plotm(lat,long,'-k','LineWidth', 1.8);ylabel('纬度(\circ)');xlabel('经度（\circ）');hold on; 
        TBTitleName=sprintf('%s-TB-CH%d-%s',RT_model,freq_channel,scene_time);title(TBTitleName);
        h=pcolorm(double(Lat_scene), double(Long_scene), double(TB)); set(h,'edgecolor','none');colorbar;caxis([T_min, T_max]);     
    end    
    %%%%%%%%读取对应频段的背景插值亮温图像
    if flag_L2 ==1
        TA_Background = TB;
    else
        Background_filename =  sprintf('Simu2-c%d_%s',freq_channel,background_time);%背景插值亮温数据文件名
        Background_matfile = sprintf('%s\\%s.mat', file_path,Background_filename);
        load(Background_matfile);TA_Background=TbMap(:,:,1);
    end
     %%计算插值观测亮温TA_Background与观测亮温TA_obs的RMSE和相关系数
    OB_RMSE = Root_Mean_Square_Error(TA_Background,TA_observation,0,0);
    OB_Corr_coe = TB_correlation_coefficient(TA_Background,TA_observation,0);
    delta_OB = reshape(TA_observation-TA_Background,num_observation,1);
    OB_mean = mean(delta_OB);  OB_std = std(delta_OB);
%part1：end**************************************************************************************************************************************************

%% ********************************************************part2：辐射计载荷参数设置**************************************************************
%% 以下是每个频点都不一样的辐射计载荷参数
    if (strcmpi('ATMS',satellite_payload)) 
        switch freq_channel%中心频率,     %带宽, 单位:Hz       %噪声系数,单位:dB   %天线口径，单位：米
             case 1, freq= 23.8e9;   bandwith = 270e6;    noise_figure= 4.5;antenna_diameter = 0.175; 
             case 2, freq= 31.4e9;   bandwith = 180e6;    noise_figure= 5;  antenna_diameter = 0.135; 
             case 3, freq= 50.3e9;   bandwith = 180e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 4, freq= 51.76e9;  bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 5, freq= 52.8e9;   bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 6, freq= 53.596e9; bandwith = 2*170e6;  noise_figure= 6;  antenna_diameter = 0.185; 
             case 7, freq= 54.4e9;   bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 8, freq= 54.94e9;  bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 9, freq= 55.5e9;   bandwith = 330e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 10,freq= 57.29e9;  bandwith = 2*155e6;  noise_figure= 6;  antenna_diameter = 0.185; 
             case 11,freq= 57.507e9; bandwith = 2*78e6;   noise_figure= 6;  antenna_diameter = 0.185; 
             case 12,freq= 57.66e9;  bandwith = 2*36e6;   noise_figure= 6;  antenna_diameter = 0.185; 
             case 13,freq= 57.63e9;  bandwith = 2*16e6;   noise_figure= 6;  antenna_diameter = 0.185; 
             case 14,freq= 57.62e9;  bandwith = 2*8e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 15,freq= 57.617e9; bandwith = 2*3e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 16,freq= 88.2e9;   bandwith = 2000e6;   noise_figure= 9;  antenna_diameter = 0.11; 
             case 17,freq= 165.5e9;  bandwith = 2*1150e6; noise_figure= 12; antenna_diameter = 0.11;
             case 18,freq= 190.31e9; bandwith = 2*2000e6; noise_figure= 12; antenna_diameter = 0.11;
             case 19,freq= 187.81e9; bandwith = 2*2000e6; noise_figure= 12; antenna_diameter = 0.11;
             case 20,freq= 186.31e9; bandwith = 2*1000e6; noise_figure= 12; antenna_diameter = 0.11;
             case 21,freq= 185.11e9; bandwith = 2*1000e6; noise_figure= 12; antenna_diameter = 0.11;
             case 22,freq= 184.31e9; bandwith = 2*500e6;  noise_figure= 12; antenna_diameter = 0.11;   
        end
    end
    if (strcmpi('FY3C-MWTS',satellite_payload)) 
        switch freq_channel%中心频率,     %带宽, 单位:Hz       %噪声系数,单位:dB   %天线口径，单位：米
             case 1, freq= 50.3e9;   bandwith = 180e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 2, freq= 51.76e9;  bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 3, freq= 52.8e9;   bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 4, freq= 53.596e9; bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 5, freq= 54.4e9;   bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 6, freq= 54.94e9;  bandwith = 400e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 7, freq= 55.5e9;   bandwith = 330e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 8, freq= 57.29e9;  bandwith = 330e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 9, freq= 57.507e9; bandwith = 2*78e6;   noise_figure= 6;  antenna_diameter = 0.185; 
             case 10,freq= 57.66e9;  bandwith = 2*36e6;   noise_figure= 6;  antenna_diameter = 0.185; 
             case 11,freq= 57.63e9;  bandwith = 2*16e6;   noise_figure= 6;  antenna_diameter = 0.185; 
             case 12,freq= 57.62e9;  bandwith = 2*8e6;    noise_figure= 6;  antenna_diameter = 0.185; 
             case 13,freq= 57.617e9; bandwith = 2*3e6;    noise_figure= 6;  antenna_diameter = 0.185;              
        end
    end
    if (strcmpi('FY3C-MWHTS',satellite_payload)) 
        switch freq_channel%中心频率,     %带宽, 单位:Hz       %噪声系数,单位:dB   %天线口径，单位：米
             case 1, freq= 89e9;     bandwith = 1500e6;    noise_figure= 11;  antenna_diameter = 0.12; 
             case 2, freq= 118.83e9; bandwith = 2*20e6;    noise_figure= 11;  antenna_diameter = 0.09; 
             case 3, freq= 118.95e9; bandwith = 2*100e6;   noise_figure= 11;  antenna_diameter = 0.09; 
             case 4, freq= 119.05e9; bandwith = 2*165e6;   noise_figure= 11;  antenna_diameter = 0.09; 
             case 5, freq= 119.55e9; bandwith = 2*200e6;   noise_figure= 11;  antenna_diameter = 0.09; 
             case 6, freq= 119.85e9; bandwith = 2*200e6;   noise_figure= 11;  antenna_diameter = 0.09; 
             case 7, freq= 121.25e9; bandwith = 2*200e6;   noise_figure= 11;  antenna_diameter = 0.09; 
             case 8, freq= 121.75e9; bandwith = 2*1000e6;  noise_figure= 11;  antenna_diameter = 0.09; 
             case 9, freq= 123.75e9; bandwith = 2*2000e6;  noise_figure= 11;  antenna_diameter = 0.09; 
             case 10,freq= 150e9;    bandwith = 1500e6;    noise_figure= 12;  antenna_diameter = 0.11; 
             case 11,freq= 184.31e9; bandwith = 2*500e6;   noise_figure= 12;  antenna_diameter = 0.11; 
             case 12,freq= 185.11e9; bandwith = 2*700e6;   noise_figure= 12;  antenna_diameter = 0.11; 
             case 13,freq= 186.31e9; bandwith = 2*1000e6;  noise_figure= 12;  antenna_diameter = 0.11;
             case 14,freq= 187.81e9; bandwith = 2*2000e6;  noise_figure= 12;  antenna_diameter = 0.11; 
             case 15,freq= 190.31e9; bandwith = 2*2000e6;  noise_figure= 12;  antenna_diameter = 0.11;   
        end
    end 
%% 以下是每个频点都相同的辐射计载荷参数
    c=3e8;                                                      %光速 unit m/s
    wavelength = c/freq;                                        %波长 unit:m
    integral_time = 18*10^(-3);                                 %积分时间, unit:S                                           
    T_rec=290*(10^(noise_figure/10)-1);                         %辐射计等效噪声温度, unit:K
    NEDT = (T_rec+250)/sqrt(bandwith*integral_time);            %辐射计灵敏度，单位：K
    Ba = pi*antenna_diameter/wavelength;                        %天线电长度参数
    illumination_taper = 1;                                     %the illumination taper //by thesis of G.M.Skofronick

%% ********************************************************part3：模拟辐射计天线扫描观测成像过程，计算观测后的输出亮温图像TA**************************************
    %计算系统天线方向图及其指标参数
    angle = 30;                                                                        %天线图作图的视场范围，单位：度
    num_antenna_pix = 500;                                                             %天线图作图点数
    d_angle = angle/(num_antenna_pix);                                                 %天线方向图作图的最小间距，即角度分辨率                      
    Coordinate_antenna_pattern = linspace(-angle/2,angle/2-d_angle,num_antenna_pix);   %空间坐标向量
    %画出天线方向图，并计算3dB波束宽度、副瓣电平、主波束效率、地面分辨率
    [Antenna_Pattern,HPBW,SLL,MBE] = RA_antenna_pattern_2D(Ba,Coordinate_antenna_pattern,Coordinate_antenna_pattern,angle,angle,illumination_taper,freq_channel,flag_draw_pattern);
    ground_resolution = HPBW/180*pi*orbit_height;                                      %计算地面分辨率

    %计算一个角度密集的载荷天线方向图
    angle_coordinate = linspace(0,180,180000);
    Antenna_Patter = Antenna_Pattern_angle_calc(angle_coordinate,Ba,illumination_taper);
    %模拟天线扫描方式获得观测亮温TA
    TA_noiseless = Satellite_POES_conv(TB,Long_scene,Lat_scene,Long_observation,Lat_observation,Long_Subsatellite,Lat_Subsatellite,R,orbit_height,Antenna_Patter,angle_coordinate);
    %%%%给模拟观测亮温TA加上系统噪声
    [TA] = add_image_noise(TA_noiseless,bandwith,integral_time,noise_figure);
    %画出卫星数据的观测亮温
    figure;axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on; 
    load coast;plotm(lat,long,'-k','LineWidth', 1.8);ylabel('纬度(\circ)');xlabel('经度（\circ）');hold on; 
    TATitleName=sprintf('%s-%s-TA-CH%d',RT_model,satellite_payload,freq_channel);title(TATitleName);
    h=pcolorm(double(Lat_observation), double(Long_observation), double(TA)); set(h,'edgecolor','none');colorbar; caxis([T_min, T_max]) 

    %%计算成像精度，用模拟观测亮温TA与观测亮温TA_obs的RMSE和相关系数来衡量
    OA_RMSE = Root_Mean_Square_Error(TA,TA_observation,0,0);
    OA_Corr_coe = TB_correlation_coefficient(TA,TA_observation,0);
    delta_OA = reshape(TA_observation-TA,num_observation,1);
    OA_mean = mean(delta_OA);  OA_std = std(delta_OA);
    %画出观测亮温与模拟亮温的残差图像
    figure;axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on; 
    load coast;plotm(lat,long,'-k','LineWidth', 1.8);ylabel('纬度(\circ)');xlabel('经度（\circ）');hold on; 
    DiffTitleName=sprintf('%s-OMA-CH%d',satellite_payload,freq_channel);title(DiffTitleName);
    h=pcolorm(double(Lat_observation), double(Long_observation), double(TA_observation-TA)); set(h,'edgecolor','none');colorbar;
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
        figure;axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on; 
        load coast;plotm(lat,long,'-k','LineWidth', 1.8);ylabel('纬度(\circ)');xlabel('经度（\circ）');hold on; 
        RETitleName=sprintf('ResolutionEnhancement-%s-TA-CH%d@%s',satellite_payload,freq_channel,Resolution_Enhancement_name);title(RETitleName);
        h=pcolorm(double(Lat_observation), double(Long_observation), double(TA_RE)); set(h,'edgecolor','none');colorbar; caxis([T_min, T_max])  
        %%计算分辨率增强后的观测精度，用重建观测亮温TA与观测亮温TA_obs的RMSE和相关系数来衡量
        OA_RMSE_RE = Root_Mean_Square_Error(TA_RE,TA_observation,0,0);
        OA_Corr_coe_RE = TB_correlation_coefficient(TA_RE,TA_observation,0); 
        delta_OA_RE = reshape(TA_observation-TA_RE,num_observation,1);
        OA_mean_RE = mean(delta_OA_RE);  OA_std_RE = std(delta_OA_RE);
    end
%part4：end*****************************************************************************************************************************************

%% ********************************************************part5：显示仿真指标并存储仿真数据************************************************
%%显示单个频率通道的系统指标和精度结果%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp([satellite_payload,'--Ch.',num2str(freq_channel),'--',num2str(freq/1e9),'GHz']);
    disp(['3dB波束宽度=',num2str(roundn(HPBW,-3)),'゜，地面分辨率=',num2str(roundn(ground_resolution,-1)),'公里,第一副瓣电平=',num2str(roundn(SLL,-1)),'dB']);
    disp(['灵敏度=',num2str(roundn(NEDT,-2)),'K,主波束效率MBE=',num2str(roundn(MBE,-1)),'%']);  
    disp(['OA的RMSE=',num2str(roundn(OA_RMSE,-2)),'K，OA的相关系数=',num2str(roundn(OA_Corr_coe,-3))]);
    disp(['OB的RMSE=',num2str(roundn(OB_RMSE,-2)),'K，OB的相关系数=',num2str(roundn(OB_Corr_coe,-3))]);
    disp(['OA的误差均值=',num2str(roundn(OA_mean,-2)),'K，OA的误差标准差=',num2str(roundn(OA_std,-2)),'K']);
    disp(['OB的误差均值=',num2str(roundn(OB_mean,-2)),'K，OB的误差标准差=',num2str(roundn(OB_std,-2)),'K']);
    if  flag_Resolution_Enhancement == 1;
        disp(['分辨率增强后OA的RMSE=',num2str(roundn(OA_RMSE_RE,-2)),'K@',num2str(factor_opt)]);
        disp(['分辨率增强后OA的相关系数=',num2str(roundn(OA_Corr_coe_RE,-3)),'@',num2str(factor_opt)]);
        disp(['RE后的误差均值=',num2str(roundn(OA_mean_RE,-2)),'K，RE后的误差标准差=',num2str(roundn(OA_std_RE,-2)),'K']);
    end
%%保存单个频率通道的仿真结果%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if flag_save == 1
        FileName = sprintf('POES-%s-C%d-%s',satellite_payload,freq_channel,observation_time);
        if flag_Resolution_Enhancement == 1;
            FileName = sprintf('%s-%s', FileName,Resolution_Enhancement_name);
        end
        MatFileName = sprintf('%s.mat', FileName);
        save(['..\05. RA仿真结果\' MatFileName],'TA_noiseless','TA','Antenna_Pattern','NEDT','HPBW','SLL','MBE','ground_resolution','OA_RMSE','OA_Corr_coe','OB_RMSE','OB_Corr_coe');
        save(['..\05. RA仿真结果\' MatFileName],'TA_observation','Long_observation','Lat_observation','TA_Background','OB_mean','OB_std','OA_mean','OA_std','-append');
        if  flag_Resolution_Enhancement == 1;
            save(['..\05. RA仿真结果\' MatFileName],'TA_RE','OA_RMSE_RE','OA_Corr_coe_RE','factor_opt','-append'); 
        end
    end
    POES_PayloadSpec_list(freq_channel,1) = NEDT;   POES_PayloadSpec_list(freq_channel,2) = HPBW;    POES_PayloadSpec_list(freq_channel,3) = ground_resolution;
    POES_PayloadSpec_list(freq_channel,4) = SLL;    POES_PayloadSpec_list(freq_channel,5) = MBE;  
    POES_result_list(freq_channel,1) = OB_RMSE;     POES_result_list(freq_channel,2) = OB_Corr_coe;
    POES_result_list(freq_channel,3) = OB_mean;     POES_result_list(freq_channel,4) = OB_std;
    POES_result_list(freq_channel,5) = OA_RMSE;     POES_result_list(freq_channel,6) = OA_Corr_coe;
    POES_result_list(freq_channel,7) = OA_mean;     POES_result_list(freq_channel,8) = OA_std;
    if  flag_Resolution_Enhancement == 1;
    POES_result_list(freq_channel,9) = OA_RMSE_RE;  POES_result_list(freq_channel,10) = OA_Corr_coe_RE;
    POES_result_list(freq_channel,11) = OA_mean_RE; POES_result_list(freq_channel,12) = OA_std_RE; 
    end
end

%%显示所有频率通道的系统指标和精度结果%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([satellite_payload,'辐射计载荷仿真性能指标']);
disp('灵敏度(K) , 3dB波束宽度(゜)，地面分辨率(km)，副瓣电平(dB)，主波束效率(%)')
disp(roundn(POES_PayloadSpec_list,-2));
disp('------------------------------------------------------------------------')
disp([satellite_payload,'辐射计载荷模拟观测精度分析']);
if  flag_Resolution_Enhancement == 1;
    disp('OB_RMSE(K),OB相关系数,OB均值(K),OB标准差(K),OA_RMSE(K),OA相关系数,OA均值(K),OA标准差(K),RE_RMSE(K),RE相关系数,RE均值(K),RE标准差(K)')
else
    disp('OB_RMSE(K),OB相关系数,OB均值(K),OB标准差(K),OA_RMSE(K),OA相关系数,OA均值(K),OA标准差(K)')
end
disp(roundn(POES_result_list,-3));
%%保存所有频率通道的仿真结果%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_save == 1;
   FileName = sprintf('POES-%s-%s',satellite_payload,observation_time);
   if flag_Resolution_Enhancement == 1;
      FileName = sprintf('%s-%s', FileName,Resolution_Enhancement_name);
   end
   ListMatFileName = sprintf('%s_result_list.mat', FileName);
   save(['..\05. RA仿真结果\' ListMatFileName],'POES_result_list','POES_PayloadSpec_list');   
end
%part5：end**************************************************************************************************************************************************

toc;