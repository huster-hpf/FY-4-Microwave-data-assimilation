function TA = Satellite_GOES_conv(TB,theta_scene,phi_scene,theta_observation,phi_observation,Ba,illumination_taper)
%   函数功能：实现静止轨道卫星载荷天线方向图像卷积观测过程**********************************
%             
%  输入参数:
%    TB             : 场景高分辨率亮温图像
%   theta_scene     : 场景格点在卫星球坐标系下天顶角坐标
%   angle_y         ：场景格点在卫星球坐标系下方位角坐标 
%theta_observation  ：观测采样点在卫星球坐标系下天顶角坐标
%phi_observation    ：观测采样点在卫星球坐标系下方位角坐标
% Ba                ：天线方向图计算函数
% illumination_taper: 天线方向图照射锥度
%  输出参数：
% TA                : 天线扫描输出的观测亮温 
%   by 陈柯 2017.03.22  ******************************************************  
%%%%%%%%%%%%%%%%计算模拟观测亮温TA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%初始化观测后的输出亮温图像TA
[N_TA_Lat,N_TA_Long] = size(theta_observation);
TA=zeros(N_TA_Lat,N_TA_Long); 
%计算一个角度密集的载荷天线方向图
angle = linspace(0,180,180000);
Antenna_Patter = Antenna_Pattern_angle_calc(angle,Ba,illumination_taper);
% matlabpool open ;
parfor m=1:N_TA_Lat
    tic;
     for n=1:N_TA_Long
         %按照采样点逐个计算对应指向的天线方向图坐标，然后积分得到亮温TA           
         antenna_pattern_angle = vector_angle_calc(theta_observation(m,n),phi_observation(m,n),theta_scene,phi_scene);
         Antenna_Pattern_current = Antenna_Pattern_interp(antenna_pattern_angle,Antenna_Patter,angle); 
%          Antenna_Pattern_current = Antenna_Pattern_angle_calc(antenna_pattern_angle,Ba,illumination_taper);          
         TA(m,n)=sum(sum(TB.* Antenna_Pattern_current));        
     end
    toc;
end
% matlabpool close ;