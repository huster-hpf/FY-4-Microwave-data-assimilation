function [Long_observation,Lat_observation] = GOES_observation_coordinate_calc(angle_Long,angle_Lat,sample_width_Long,sample_width_Lat,Long_scene,Lat_scene)
%   函数功能：计算观测采样点经纬度坐标**********************************
%             
%  输入参数:
%   angle_Lat       : 场景纬度方向角度范围
%   angle_Long      ：场景经度方向角度范围
% sample_width_Long : 经度方向采样角度间距
% sample_width_Lat  : 纬度方向采样角度间距
% Lat_scene         ：场景纬度坐标
% Long_scene        : 场景经度坐标
%  输出参数：
% Long_observation  : 观测点经度坐标
% Lat_observation   ：观测点纬度坐标 
%   by 陈柯 2016.12.22  ******************************************************  
[N_y,N_x] = size(Long_scene);
N_TA_Lat = round(angle_Lat/sample_width_Lat);                   %纬度方向辐射计天线扫描点数  
N_TA_Long = round(angle_Long/sample_width_Long);                %经度方向辐射计天线扫描点数  
%计算天线每次扫描波束指向角对应的输入图像行、列编号
row_TA_Lat = zeros(1,N_TA_Lat);                                 %天线每次扫描波束指向角对应的输入图像行编号
col_TA_Long = zeros(1,N_TA_Long);                               %天线每次扫描波束指向角对应的输入图像列编号
for k = 1:N_TA_Lat  %行编号
    delta_angle=(k-1)*(sample_width_Lat);
    row_TA_Lat(k) = min(round(delta_angle/angle_Lat*N_y)+1,N_y);    
end
for k = 1:N_TA_Long  %列编号
    delta_angle=(k-1)*(sample_width_Long);
    col_TA_Long(k) = min(round(delta_angle/angle_Long*N_x)+1,N_x);    
end
Long_observation = zeros(N_TA_Lat,N_TA_Long);
Lat_observation = zeros(N_TA_Lat,N_TA_Long);
for m = 1:N_TA_Lat
    for n = 1:1:N_TA_Long
        Long_observation(m,n) = Long_scene(row_TA_Lat(m),col_TA_Long(n));
        Lat_observation(m,n)  = Lat_scene(row_TA_Lat(m),col_TA_Long(n));
    end
end

