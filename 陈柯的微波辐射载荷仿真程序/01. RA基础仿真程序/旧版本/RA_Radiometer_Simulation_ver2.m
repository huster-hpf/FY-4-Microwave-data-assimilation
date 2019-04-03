%本程序模拟实孔径辐射计载荷观测亮温
%by 陈柯 2015.11.10

clear;
close all;
tic;
%%***************************以下部分是设置标志位**********************************************************
flag_draw_TB = 1;                                           %画出原始亮温TB                     
flag_save = 0;                                              %数据存储标志位
%*********************************************************************************************************



%%********************************************************part1：辐射计载荷参数与扫描采样参数设置**************************************************************
%%***************************设置辐射计参数******************************
freq = 50.3e9;                                               %辐射计中心频率，单位:Hz
c=3e8;                                                      %光速 unit m/s
wavelength = c/freq;                                          %波长 unit:m
R = 6371;                                                   %地球半径 unit:km
orbit_height = 35786;                                       %轨道高度（当前为地球静止轨道）, unit:km
antenna_diameter = 3.7;                                       %天线口径 单位：米
illumination_taper = 0;                                     %the illumination taper //by thesis of G.M.Skofronick
bandwith = 180*10^6;                                        %辐射计带宽, unit:Hz
integral_time = 20*10^(-3);                                 %积分时间, unit:S
noise_figure= 5;                                            %辐射计噪声系数, unit:dB
T_rec=290*(10^(noise_figure/10)-1);                         %辐射计等效噪声温度, unit:K
T_A = 250;                                                  %假设平均输入天线亮温TA，单位：K
NEDT = (T_rec+T_A)/sqrt(bandwith*integral_time);            %辐射计灵敏度，单位：K
Ba = pi*antenna_diameter/wavelength;                        %天线电长度参数
%%***************************设置扫描采样角度间距设置*******************
%设置方案一：按照辐射计最高工作频段的波束宽度的某一倍数设置
sample_freq = 183.31e9;                                        %辐射计最高工作频段
sample_factor = 1;                                          %采样系数，为采样间隔与最高频段波束宽度之比
sample_wavelength = c/sample_freq;                          %辐射计最高工作频段的波长
sample_beam=1.02*sample_wavelength/antenna_diameter*180/pi; %辐射计最高工作频段对应波束宽度
sample_width = sample_factor*sample_beam;                   %载荷天线扫描间隔，单位：度
% %设置方案二：按照当前工作频段的波束宽度的某一倍数设置
% sample_factor = 0.5;                                      %采样系数，为采样间隔与当前频率波束宽度之比
% sample_width = sample_factor*beam_width;                  %载荷天线扫描间隔，单位：度
% %设置方案三：直接按照某一角度值设置
% sample_width = 0.01;                                      %载荷天线扫描间隔，单位：度
%part1：end**************************************************************************************************************************************************


%%********************************************************part2：设置输入图像场景参数：空间坐标和亮温值********************************************
%根据选择模拟亮温场景读取对应频段的模拟亮温图像
file_path = 'D:\当前的工作\2015.03.21 基于资料同化的GEO仿真研究\仿真亮温数据\2016.10.09 飓风sandy-NAM-20121029\亮温图像';   %文件存储目录 
TB_filename = 'HurricanSandy_50-3_H_29_00.mat';     %亮温图像文件名，该场景范围为1500*1500公里
TB_matfile = sprintf('%s\\%s', file_path,TB_filename);
load(TB_matfile);
TB=(pic);
T_max=max(max(TB));
T_min=min(min(TB));
[N_Lat,N_Long] = size(TB);
%计算场景在经度和纬度方向的观测角范围
coordinate_filename = sprintf('%s\\coords.mat', file_path);
[angle_Long,angle_Lat] = Image_Long_Lat_calc(coordinate_filename,R,orbit_height);
%计算图像空间角度坐标参数*********************************************
%计算空间格点大小
d_Long = angle_Long/(N_Long);                  %亮温图像经度方向最小间距，即角度分辨率  
d_Lat = angle_Lat/(N_Lat);                     %亮温图像纬度方向最小间距，即角度分辨率 
%计算图像的真实空间二维角度坐标值
Coordinate_Long = linspace(-angle_Long/2,angle_Long/2-d_Long,N_Long);   %经度角度坐标向量
Coordinate_Lat = linspace(-angle_Lat/2,angle_Lat/2-d_Lat,N_Lat);        %纬度角度坐标向量
[Fov_Long,Fov_Lat] = meshgrid(Coordinate_Long,Coordinate_Lat);          %经度纬度方向二维坐标矩阵
AP_Coordinate_Long = linspace(-angle_Long,angle_Long-d_Long,2*N_Long);
AP_Coordinate_Lat = linspace(-angle_Lat,angle_Lat-d_Lat,2*N_Lat);
%画出输入亮温图像
if  flag_draw_TB == 1;
    figure;imagesc(Coordinate_Long,Coordinate_Lat,TB,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
    xlabel('经度方向'); ylabel('纬度方向');title('原始亮温图像TB');colorbar;
end
%part2：end**************************************************************************************************************************************************


%%********************************************************part3：模拟辐射计天线扫描观测成像过程，计算观测后的输出亮温图像TA**************************************
%计算系统天线方向图及其指标参数
[Antenna_Pattern,HPBW,SLL,MBE] = RA_antenna_pattern_2D(Ba,Coordinate_Long,Coordinate_Lat,angle_Long,angle_Lat,illumination_taper);
sample_density = HPBW/sample_width;                   %波束宽度与采样间隔的比值，代表每个波束范围内的采样个数

sample_width_Lat = max(sample_width,d_Lat);                    %在纬度方向天线采样的格点角度
sample_width_Long = max(sample_width,d_Long);                  %在经度方向天线采样的格点角度
N_TA_Lat = round(angle_Lat/sample_width_Lat);                   %纬度方向辐射计天线扫描点数  
N_TA_Long = round(angle_Long/sample_width_Long);                %经度方向辐射计天线扫描点数
Sample_Coordinate_Long = 0:sample_width:(N_TA_Long-1)*sample_width;
Sample_Coordinate_Lat = 0:sample_width:(N_TA_Lat-1)*sample_width;

%%%%%%%%%%%%%%%%计算模拟观测亮温TA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%计算大天线方向图
Antenna_Pattern_Full = Antenna_Pattern_calc(AP_Coordinate_Long,AP_Coordinate_Lat,Ba,illumination_taper);
[AP_2D_Long, AP_2D_Lat] = meshgrid(AP_Coordinate_Long,AP_Coordinate_Lat);  %大天线方向图网格的经纬度坐标
%未扫描的亮温图像经纬度坐标
original_Coordinate_Long = linspace(0,angle_Long-d_Long,N_Long);
original_Coordinate_Lat = linspace(0,angle_Lat-d_Lat,N_Lat);
%初始化观测后的输出亮温图像TA
TA=zeros(N_TA_Lat,N_TA_Long); 
matlabpool open ;
parfor sample_num_Lat=1:N_TA_Lat
     for sample_num_Long=1:N_TA_Long
         %利用天线方向图插值得到当前扫描指向的方向图与输入亮温进行卷积，计算模拟每个像素的观测亮温TA 
         %天线当前扫描指向的经纬度坐标
         current_center_Long = Sample_Coordinate_Long(sample_num_Long);
         current_center_Lat = Sample_Coordinate_Lat(sample_num_Lat);
         %将天线当前扫描指向作为新的坐标零点，所以原始坐标系要相对新的零点进行平移得到
         current_Coordinate_Long = original_Coordinate_Long - current_center_Long;
         current_Coordinate_Lat = original_Coordinate_Lat - current_center_Lat;
         [current_2D_Long, current_2D_Lat] = meshgrid(current_Coordinate_Long,current_Coordinate_Lat);
         %新的坐标下的方向图用对原始天线方向图插值得到。
         current_Antenna_Pattern = interp2(AP_2D_Long, AP_2D_Lat,Antenna_Pattern_Full,current_2D_Long, current_2D_Lat,'spline');  %采用样条插值，精度最高
         current_Antenna_Pattern = current_Antenna_Pattern/sum(sum(current_Antenna_Pattern));
         TA(sample_num_Lat,sample_num_Long)=sum(sum(TB.* current_Antenna_Pattern)); 
    end
end
matlabpool close ;
%%%%给模拟观测亮温TA加上系统噪声
TA_real = add_image_noise(TA,bandwith,integral_time,noise_figure);
figure;imagesc(Coordinate_Long,Coordinate_Lat,TA_real,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
xlabel('经度方向'); ylabel('纬度方向');title('观测亮温图像TA');colorbar;
%part3：end**************************************************************************************************************************************************

%%********************************************************part4：BG解卷积处理*********************************************************************
d_Long_TA = angle_Long/(N_TA_Long);
d_Lat_TA = angle_Lat/(N_TA_Lat);
BG_Coordinate_Long = linspace(-angle_Long,angle_Long-d_Long_TA,2*N_TA_Long);
BG_Coordinate_Lat = linspace(-angle_Lat,angle_Lat-d_Lat_TA,2*N_TA_Lat);
Antenna_Pattern_BG = Antenna_Pattern_calc(BG_Coordinate_Long,BG_Coordinate_Lat,Ba,illumination_taper);
TA_BG = BG_deconv(TA,Antenna_Pattern_BG,T_rec,bandwith,integral_time);
figure;imagesc(Coordinate_Long,Coordinate_Lat,TA_BG,[T_min T_max]);axis equal;xlim([-angle_Long/2,angle_Long/2]);ylim([-angle_Lat/2,angle_Lat/2]);
xlabel('经度方向'); ylabel('纬度方向');title('BG解卷积后的亮温图像');colorbar;
%part3：end*****************************************************************************************************************************************


%%********************************************************part5：显示仿真指标并存储仿真数据*********************************************************************
%计算程序精度，用观测亮温TA与输入Tb的RMSE来衡量
[MSE,PSNR] = Mean_Square_Error(TB,TA,10,0);
[MSE_BG,PSNR_BG] = Mean_Square_Error(TB,TA_BG,10,0);
[MSE_real,PSNR_real] = Mean_Square_Error(TB,TA_real,10,1);
%%%%%%%%%%显示仿真得到系统指标和成像精度%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([num2str(freq/1e9),'GHz频段，',num2str(antenna_diameter),'米口径的实孔径辐射计载荷（@taper=',num2str(illumination_taper),')']);
disp(['3dB波束宽度=',num2str(roundn(HPBW,-3)),'゜','，地面分辨率=',num2str(roundn(HPBW/180*pi*orbit_height,-1)),'公里']);
disp(['天线扫描间隔宽度=',num2str(roundn(sample_width,-3)),'゜',',天线扫描地面间距=',num2str(roundn(sample_width/180*pi*orbit_height,-1)),'公里,采样密度=',num2str(roundn(sample_density,-1))]);
disp(['第一副瓣电平=',num2str(roundn(SLL,-1)),'dB']);
disp(['主波束效率MBE=',num2str(roundn(MBE,-1)),'%']);
disp(['实孔径辐射计亮温灵敏度=',num2str(roundn(NEDT,-2)),'K']);  
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷成像误差=',num2str(roundn(MSE,-2)),'K，峰值信噪比=',num2str(roundn(PSNR,-1)),'dB']);
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷BG成像误差=',num2str(roundn(MSE_BG,-2)),'K，峰值信噪比=',num2str(roundn(PSNR_BG,-1)),'dB']);
disp([num2str(antenna_diameter),'米口径的实孔径辐射计载荷加噪成像误差=',num2str(roundn(MSE_real,-2)),'K，峰值信噪比=',num2str(roundn(PSNR_real,-1)),'dB']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_save == 1
   tempstr=textscan(TB_filename,'%s', 'delimiter', '.');
   tempstr=tempstr{1,1};
   Scene = tempstr{size(tempstr,1)-1,1};
   FileName = sprintf('RA_%s_D%s_q%d_τ%s_sample%s', Scene,num2str(round(antenna_diameter*1000)),illumination_taper,num2str(integral_time),num2str(roundn(sample_density,-1)));
   MatFileName = sprintf('%s.mat', FileName);
   save(['..\RA仿真结果\' MatFileName],'TA','TA_real','TA_BG','Antenna_Pattern','HPBW','SLL','MBE');    
end
%part5：end**************************************************************************************************************************************************

toc;