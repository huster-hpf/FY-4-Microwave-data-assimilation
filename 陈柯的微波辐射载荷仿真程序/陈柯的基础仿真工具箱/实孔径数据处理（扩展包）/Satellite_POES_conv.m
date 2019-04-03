function TA = Satellite_POES_conv(TB,Long_scene,Lat_scene,Long_observation,Lat_observation,Long_Subsatellite,Lat_Subsatellite,R,orbit_height,Antenna_Patter,angle)
%   函数功能：实现极轨卫星载荷天线方向图像卷积观测过程**********************************
%  
%   输入参数:
%   TB              : 场景高分辨率亮温图像
%   Long_scene      : 场景经度坐标
%   Lat_scene       ：场景纬度坐标
%   Long_observation：卫星观测点经度坐标
%   Lat_observation ：卫星观测点纬度坐标
%   Long_Subsatellite:卫星星下点经度坐标
%   Lat_Subsatellite:卫星星下点纬度坐标
% % R               : 地球半径
%   orbit_height    ：卫星轨道高度
%   Ba              ：天线方向图计算电长度
% illumination_taper: 天线方向图照射锥度
%   输出参数：
%   TA      : 天线扫描输出的观测亮温 
%   by 陈柯 2016.12.22  ******************************************************  

%%%%%%%%%%%%%%%%计算模拟观测亮温TA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%初始化观测后的输出亮温图像TA
[num_Long,num_Lat] = size(Lat_observation);
TA=zeros(num_Long,num_Lat);   %初始化观测亮温
TB_nan = TB;                  %
TB(isnan(TB)) = 0;            %将TB中NaN值变为零
%模拟卫星载荷天线扫描过程，计算TA
% matlabpool open ;
parfor k =1:num_Lat  %计算每一行的观测亮温
     tic;
    current_Subsatellite_Long = Long_Subsatellite(k);   %当前行星下点经度坐标
    current_Subsatellite_Lat  = Lat_Subsatellite(k);    %当前行星下点纬度坐标
    current_observation_Long  = Long_observation(:,k);  %卫星采样点经度坐标
    current_observation_Lat   = Lat_observation(:,k);   %卫星采样点纬度坐标 
%   根据卫星轨道转换为相对卫星的角度坐标
    [theta_scene,phi_scene] = Satellite_Sphere_Coordinate_Calc(Long_scene,Lat_scene,current_Subsatellite_Long,current_Subsatellite_Lat,R,orbit_height);
    theta_scene(isnan(TB_nan)) = NaN;phi_scene(isnan(TB_nan)) = NaN;
    [theta_observation,phi_observation] = Satellite_Sphere_Coordinate_Calc(current_observation_Long,current_observation_Lat,current_Subsatellite_Long,current_Subsatellite_Lat,R,orbit_height);
%   按照每行的采样点逐个计算对应指向的天线方向图坐标，然后积分得到亮温。    
    for m =1:num_Long     
        antenna_pattern_angle = vector_angle_calc(theta_observation(m),phi_observation(m),theta_scene,phi_scene);
%         Antenna_Pattern_current = Antenna_Pattern_angle_calc(antenna_pattern_angle,Ba,illumination_taper)  ;  
        Antenna_Pattern_current = Antenna_Pattern_interp(antenna_pattern_angle,Antenna_Patter,angle); 
        TA(m,k)=sum(sum(TB.* Antenna_Pattern_current));       
    end
     toc;
end
% matlabpool close ;




