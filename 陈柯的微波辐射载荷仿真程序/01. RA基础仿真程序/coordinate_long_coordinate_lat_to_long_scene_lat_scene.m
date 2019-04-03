function [Long_scene,Lat_scene]=coordinate_long_coordinate_lat_to_long_scene_lat_scene(coordinate_lon,coordinate_lat)
% col=size(coordinate_lon);
% row=size(coordinate_lat);
Long_scene=zeros(251,251);
Lat_scene=zeros(251,251);
for m=1:251
    for n=1:251
        Long_scene(m,n)=coordinate_lon(n);
        Lat_scene(m,n)=coordinate_lat(m);
    end
end
