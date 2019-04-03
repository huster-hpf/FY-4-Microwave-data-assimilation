function [Coordinate_Long,Coordinate_Lat]=lat_lon_to_coordinate_long_coordinate_lat(TB_channel,LAT,LON,R,orbit_height,Long_Subsatellite,Lat_Subsatellite);
[row,col]=size(TB_channel);
TB_channel(isnan(TB_channel)) = 0;
% LAT_model=zeros(row,col);
% LON_model=zeros(row,col);
X=zeros(row,col);
Y=zeros(row,col);
Z=zeros(row,col);
for m=1:row
    for n=1:col
        if TB_channel(m,n)~=0
%             LAT_model(m,n)=LAT(m,n)-Lat_Subsatellite;
%             LON_model(m,n)=180-(LON(m,n)+Long_Subsatellite);
            X(m,n)=R*sind(LAT(m,n))*cosd(LON(m,n));
            Y(m,n)=R*sind(LAT(m,n))*sind(LON(m,n));
            Z(m,n)=R*cosd(LAT(m,n));
            Coordinate_Long(m,n)=atand(X(m,n)/(R+orbit_height-Y(m,n)));
            Coordinate_Lat(m,n)=atand(Z(m,n)/(R+orbit_height-Y(m,n)));
        else
            Coordinate_Long(m,n)=0/0;
            Coordinate_Lat(m,n)=0/0;
        end
    end
end
