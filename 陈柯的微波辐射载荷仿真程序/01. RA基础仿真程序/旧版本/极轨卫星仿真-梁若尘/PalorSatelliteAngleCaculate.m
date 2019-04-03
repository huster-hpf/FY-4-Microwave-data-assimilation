function [ theta,phi ] = PalorSatelliteAngleCaculate( Coordinate_Long,Coordinate_Lat,satellite_longtitude,satellite_latititude,R,orbit_height )
% 输入极轨卫星与观测位置的地理信息，计算卫星对应的观测角度
% Coordinate_Long：需要计算的地面经度网格。
% Coordinate_Lat：需要计算的地面纬度网格。
% satellite_longtitude：卫星星下点的经度。
% satellite_latititude：卫星星下点的纬度。
% R：地球半径。
% orbit_height：轨道高度。

[a,b] = size(Coordinate_Lat);                                       %读取地面网格的维度
theta = zeros(a,b);                                                 %初始化方位角
phi = zeros(a,b);                                                   %初始化俯仰角

for lat_num = 1:a
    for lon_num =1:b

        Longitude_start = satellite_longtitude;         
        Longitude_end = Coordinate_Long(lat_num,lon_num);
        Latitude_start = satellite_latititude;
        Latitude_end = Coordinate_Lat(lat_num,lon_num);
        if Longitude_start>Longitude_end
        sign_Lo = 1;
        else
        sign_Lo = -1;
        end
        if Latitude_start>Latitude_end
        sign_La = 1;
        else
        sign_La = -1;
        end
        Length_Longitude = R*acos(sind(Latitude_start)*sind(Latitude_start) + cosd(Latitude_start)*cosd(Latitude_start)*cosd(Longitude_start-Longitude_end));  %  ground  longitude size of scene, unit:km
        Length_Latitude = R*acos(sind(Latitude_start)*sind(Latitude_end) + cosd(Latitude_start)*cosd(Latitude_end)*cosd(Longitude_start-Longitude_start));     %  ground  latitude size of scene, unit:km
        theta(lat_num,lon_num) = sign_Lo*atan(Length_Longitude/orbit_height)*180/pi;   
        phi(lat_num,lon_num) = sign_La*atan(Length_Latitude/orbit_height)*180/pi;    

    end
end

end

