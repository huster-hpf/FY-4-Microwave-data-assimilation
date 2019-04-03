%% ����ļ�ר�����Դ�����
clear
figure(1)
load('Clay.mat')
h=pcolor(Clay);set(h,'linestyle','none');colorbar;
caxis([0 0.7])

figure(2)
load('Clay2.mat')
h=pcolor(Clay);set(h,'linestyle','none');colorbar;
caxis([0 0.7])


% WRF_Output_filename = 'wrfout_d01.nc';    % WRF����ļ���  WRF output filename
% % Longitude_3Dvar = ncread(WRF_Output_filename,'XLONG');  
% % Longitude = Longitude_3Dvar(:,1,1);
% % Latitude_3Dvar = ncread(WRF_Output_filename,'XLAT');
% % Latitude = Latitude_3Dvar(1,:,1).';
% Soil_Moisture_4Dvar = ncread(WRF_Output_filename,'U'); % ��WRF����ļ������������ʪ�ȱ�����Ϊ4D����
% Soil_Moisture = Soil_Moisture_4Dvar(:,:,1,1).';            % ½�ر��������ʪ�ȷֲ�����
% Soil_Temperture_4Dvar = ncread(WRF_Output_filename,'TSLB');% ��WRF����ļ�����������������¶ȱ�����Ϊ4D����
% Soil_Temperture = Soil_Temperture_4Dvar(:,:,1,1).';        % ½�ر���������¶ȷֲ�����
% SST_3Dvar = ncread(WRF_Output_filename,'SST');             % ��WRF����ļ�������������¶ȱ�����Ϊ3D����
% SST = SST_3Dvar(:,:,1).'; % ע�⣬SST������ת�ã���ΪCLAY��299x239��----------- % �����¶ȷֲ�����
% Land_Mask_3Dvar = ncread(WRF_Output_filename,'LANDMASK');  % ��WRF����ļ��������½����Ĥ������Ϊ3D����
% Land_Mask = Land_Mask_3Dvar(:,:,1).';                      % ½����Ĥ�ֲ�����
% load ('Clay2.mat');                                         %�ⲿ����½�ر��������ճ����������ֲ����������ΪClay
% load ('SSS2.mat');      
% 
% figure(1)
% h=pcolor(SSS);
% set(h,'linestyle','none');
% figure(2)
% h=pcolor(Clay);
% set(h,'linestyle','none');
% figure(3)
% h=pcolor(double(Land_Mask'));
% set(h,'linestyle','none');
% 
% 
% for i=1:19
% figure(i)
% h=pcolor((abs(surface_inp(:,:,i,3))).^2);
% set(h,'linestyle','none');
% end




% surface_angles
% RT_SURFACE_input