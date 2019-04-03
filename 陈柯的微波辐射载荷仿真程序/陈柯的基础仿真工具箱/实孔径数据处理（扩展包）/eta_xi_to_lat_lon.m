%本函数将方位角坐标转换为仿真场景的经纬度范围
function [LAT,LON]=eta_xi_to_lat_lon(TB_channel,ETA,XI,R,orbit_height,Long_Subsatellite,Lat_Subsatellite);
[row,col]=size(TB_channel);
x0=[pi/2,pi/2];
TB_channel(isnan(TB_channel)) = 0;
parfor m=1:row
    for n=1:col
        if TB_channel(m,n)~=0
            X=fsolve(@(x)lat_lon(x,R,orbit_height,ETA(m,n),XI(m,n)),x0);
            LAT(m,n)=X(1)*180/pi;
            LON(m,n)=X(2)*180/pi;
        else
            LON(m,n)=0/0;
            LAT(m,n)=0/0;
        end
    end
end
            


