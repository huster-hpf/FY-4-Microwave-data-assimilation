function point_obs_angle=Lon_Lat_to_point_obs_angle(Longitude_scene,Latitude_scene,Longtitude_satellite,Latititude_satellite,R,orbit_height )
% 输入卫星与观测位置的地理信息，计算卫星对应的观测角度
%   输入参数:
%   Longitude_scene             : 场景格点经度坐标矩阵
%   Latitude_scene              : 场景格点纬度坐标矩阵
%   Longtitude_satellite        ：卫星星下点经度坐标
%   Latititude_satellite        ：卫星星下点纬度坐标
%   R                           ：地球半径
%   orbit_height                ：卫星轨道高度
%   输出参数：
%   theta                       : 场景格点在卫星球坐标系下天顶角坐标
%   phi                         : 场景格点在卫星球坐标系下方位角坐标
%   point_obs_angle                    : 格点观测角
% by 洪鹏飞 2018.10.12  ****************************************************** 
theta_E = 90-(Latitude_scene-Latititude_satellite);
phi_E = Longitude_scene-Longtitude_satellite;
AB = R*cosd(theta_E);
BC = R*sind(theta_E).*sind(phi_E);
SC = R+orbit_height-R*sind(theta_E).*cosd(phi_E);
SB = sqrt(BC.^2+SC.^2);
phi = atand(BC./SC);
theta = atand(SB./AB);
theta(theta<0) = 180+theta(theta<0);
[row,col]=size(theta);
point_obs_angle=zeros(row,col);
theta_scan=90-theta;
for m=1:row
    for n=1:col
        point_obs_angle(m,n)=asind(((R+orbit_height)/R)*sind(theta_scan(m,n)));
    end
end