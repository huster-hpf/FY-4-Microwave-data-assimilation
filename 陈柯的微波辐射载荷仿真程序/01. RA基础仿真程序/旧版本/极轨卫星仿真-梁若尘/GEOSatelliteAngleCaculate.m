function [ theta,phi ] = GEOSatelliteAngleCaculate( Coordinate_Long,Coordinate_Lat,satellite_longtitude,satellite_latititude,R,orbit_height )
% 输入静止轨道卫星与观测位置的地理信息，计算卫星对应的观测角度
r = (R+orbit_height)/R;
[a,b] = size(Coordinate_Lat);
theta = zeros(a,b);
phi = zeros(a,b);

for lat_num = 1:a
    for lon_num =1:b

        phi_E = abs(Coordinate_Lat(lat_num,lon_num)-satellite_latititude);
        theta_E = abs(Coordinate_Long(lat_num,lon_num)-satellite_longtitude);
%         phi_S = atand((sqrt(r^2-2*r*sind(theta_E)*cosd(phi_E)+(sind(theta_E))^2))/cosd(theta_E));
        phi_S = atand(sind(phi_E)/sqrt((r-cosd(phi_E)*sind(theta_E))^2+(cosd(phi_E)*sind(theta_E))^2));
        theta_S = atand(sind(theta_E)*cosd(phi_E)/(r-cosd(theta_E)*cosd(phi_E)));
        theta (lat_num,lon_num) = theta_S;
        phi (lat_num,lon_num) = phi_S;
    end
end

end

