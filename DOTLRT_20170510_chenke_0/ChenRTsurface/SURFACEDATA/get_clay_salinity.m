%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%Data Preprocessing interplation%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Ke Chen��2014.5.15
clc;
clear;
getpath
% load([mainpath,datapath_sequence,'ATMS','.mat']);

% data_filename =[mainpath,datapath,'inputinformation.mat'];
% Longitude_3Dvar = ncread(data_filename,'XLONG');  %
% Longitude = Longitude_3Dvar(:,:,1).';
% Latitude_3Dvar = ncread(data_filename,'XLAT');
% Latitude = Latitude_3Dvar(:,:,1).';

Longitude = WRFlon';
Latitude = WRFlat';

load('Lon.mat');
load('Lat.mat');
load('PC_Clay.mat');

lon_start_num = find(abs(Lon(1,:)-Longitude(1,1))==min(abs(Lon(1,:)-Longitude(1,1))));
lon_end_num = find(abs(Lon(1,:)-Longitude(1,size(Longitude,2)))==min(abs(Lon(1,:)-Longitude(1,size(Longitude,2)))));
lat_start_num = find(abs(Lat(:,1)-Latitude(1,1))==min(abs(Lat(:,1)-Latitude(1,1))));
lat_end_num = find(abs(Lat(:,1)-Latitude(size(Latitude,1),1))==min(abs(Lat(:,1)-Latitude(size(Latitude,1),1))));

PC_Clay=flipud(PC_Clay);
Clay_origin = PC_Clay(lat_start_num:lat_end_num,lon_start_num:lon_end_num);
Clay = interp2(Lon(lat_start_num:lat_end_num,lon_start_num:lon_end_num),Lat(lat_start_num:lat_end_num,lon_start_num:lon_end_num),Clay_origin,Longitude,Latitude,'spline');
%Clay = interp2(Lon(lat_end_num:lat_start_num,lon_end_num:lon_start_num),Lat(lat_end_num:lat_start_num,lon_end_num:lon_start_num),Clay_origin,Longitude,Latitude,'spline');
Clay = Clay./100;
figure();colormap;h=pcolor(Clay_origin);set( h, 'linestyle', 'none') 
figure();colormap;h=pcolor(Clay);set( h, 'linestyle', 'none')

save([mainpath,datapath,'Clay.mat'], 'Clay');

load('SSS_global_0.5.mat')

Lon1 = linspace(-180,180,size(SSS,2));
Lon= zeros(size(SSS,1),size(SSS,2));
for n=1: size(SSS,1)
   Lon(n,:)=Lon1; 
end

Lat1 = linspace(-90,90,size(SSS,1));
Lat= zeros(size(SSS,1),size(SSS,2));
for n=1: size(SSS,2)
   Lat(:,n)=Lat1; 
end

lon_start_num = find(abs(Lon(1,:)-Longitude(1,1))==min(abs(Lon(1,:)-Longitude(1,1))));
lon_end_num = find(abs(Lon(1,:)-Longitude(1,size(Longitude,2)))==min(abs(Lon(1,:)-Longitude(1,size(Longitude,2)))));
lat_start_num = find(abs(Lat(:,1)-Latitude(1,1))==min(abs(Lat(:,1)-Latitude(1,1))));
lat_end_num = find(abs(Lat(:,1)-Latitude(size(Latitude,1),1))==min(abs(Lat(:,1)-Latitude(size(Latitude,1),1))));
%if (lat_start_num == lat_end_num)&&(lon_start_num==lon_end_num)
  %  SSS= ones(size(Latitude)).*SSS(lat_start_num,lon_start_num);
%else
    SSS_origin = SSS(lat_start_num:lat_end_num,lon_start_num:lon_end_num);
    SSS = interp2(Lon(lat_start_num:lat_end_num,lon_start_num:lon_end_num),Lat(lat_start_num:lat_end_num,lon_start_num:lon_end_num),SSS_origin,Longitude,Latitude,'spline');
%end
salinity = SSS;
save([mainpath,datapath,'SSS.mat'], 'salinity');











