

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Based on the file below%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%Surface Boundry Condition Calculation%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Ke Chen2014.5.15
%%%% +++++++Goodwillie Lee 2015,9,23

%%% ��������������������ĵ��淴����
%%% ++++++ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%% Ҫȷ��һ���ļ�����
%%% angles.mat Clay2.mat SSS2.mat wrfout_d01.nc
%%% angles.mat ��Ҫ����ķ����ʵķ��򣬰����±���
%%%            �����б�angles(1,num_surf_angles),�б��Ԫ�ظ���num_surf_angles
%%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%%% �������
%%% ����WRF�����
%%% Soil_Moisture    ����ʪ�ȷֲ�����
%%% Soil_Temperture  ���������¶ȷֲ�����
%%% SST              �����¶ȷֲ�����
%%% Land_Mask        ½����Ĥ����1Ϊ½�أ�0Ϊ����
%%% �ⲿ��ݣ�
%%% Clay             ����ճ����������ֲ�����
%%% SSS              �����ζȷֲ����� sss salinity [psu]
%%% theta            �۲�Ƕ� zenith angle of target of sensor direction [deg]
%%% �������
%%% fresnelH          ˮƽ�����������ϵ��ֲ�����
%%% fresnelV          ��ֱ�����������ϵ��ֲ�����
%%% TBH               �����ڹ۲�Ƕ��ϵ��Է���ˮƽ�������·ֲ����� matrix of emission TB contribution [K]
%%% TBV               �����ڹ۲�Ƕ��ϵ��Է��䴹ֱ�������·ֲ�����
%%% +++++++++++++++++++++++
%%% angles            �����б�
%%% num_surf_angles   �����б��Ԫ�ظ���
%%% +++++++++++++++++++++++
clc;
clear;
getpath            %++++++++++����·��

Data_Preprocessing_interp
load ([mainpath,datapath,Clayfile]);                                         %�ⲿ����½�ر��������ճ����������ֲ����������ΪClay
load ([mainpath,datapath,SSSfile]); 


get_simulation_plan
Timetab = ncread(wrfout,'Times')';

%%%%%%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%%%%%%%
%theta = 30; %  �۲�Ƕ� zenith angle of target of sensor direction [deg]
%++++++++++++  ����ǶȲ���
load([mainpath,surfacepath,'angles.mat']);
%%%%%%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%%%%%%%
for timeIndex=timeseries(1:size(timeseries,2))
    
    timesuffix = Timetab(timeIndex,:)
    
    
    WRF_Output_filename = [mainpath,datapath,wrfout];    % % WRF����ļ���  WRF output filename
    % Longitude_3Dvar = ncread(WRF_Output_filename,'XLONG');
    % Longitude = Longitude_3Dvar(:,1,1);
    % Latitude_3Dvar = ncread(WRF_Output_filename,'XLAT');
    % Latitude = Latitude_3Dvar(1,:,1).';
    Soil_Moisture_4Dvar = ncread(WRF_Output_filename,'SMOIS'); % ��WRF����ļ������������ʪ�ȱ�����Ϊ4D����
    Soil_Moisture = Soil_Moisture_4Dvar(:,:,1,timeIndex).';            % ½�ر��������ʪ�ȷֲ�����
    Soil_Temperture_4Dvar = ncread(WRF_Output_filename,'TSLB');% ��WRF����ļ�����������������¶ȱ�����Ϊ4D����
    Soil_Temperture = Soil_Temperture_4Dvar(:,:,1,timeIndex).';        % ½�ر���������¶ȷֲ�����
    SST_3Dvar = ncread(WRF_Output_filename,'SST');             % ��WRF����ļ�������������¶ȱ�����Ϊ3D����
    SST = SST_3Dvar(:,:,timeIndex).';                                  % �����¶ȷֲ�����
    Land_Mask_3Dvar = ncread(WRF_Output_filename,'LANDMASK');  % ��WRF����ļ��������½����Ĥ������Ϊ3D����
    Land_Mask = Land_Mask_3Dvar(:,:,timeIndex).';
    % ½����Ĥ�ֲ�����
                                         %�ⲿ���뺣����ζȷֲ�����, �����ΪSSS
    %++++++++++++  'Clay2.mat'��'SSS2.mat'����299x239�ľ���
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%��������糣��dielectric_constant%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dielectric_constant=zeros(size(Land_Mask,1),size(Land_Mask,2));    % �����糣��ֲ�����
    for m=1:size(Land_Mask,1)
        for n=1:size(Land_Mask,2)
            if (Land_Mask(m,n)==1)                                                               %  �ж���½�ػ��Ǻ���
                dielectric_constant(m,n) = Land_Dielectric_Constant(Clay(m,n),Soil_Moisture(m,n));   %   ����������糣��
            else
                dielectric_constant(m,n) = Sea_Dielectric_Constant(SSS(m,n),SST(m,n));               %   ���㺣���糣��
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%����Fresnel����ϵ��H,V��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    surface_inp = zeros(size(Land_Mask,2),size(Land_Mask,1),num_surf_angles,3);
    fresnelH = zeros(size(Land_Mask,1),size(Land_Mask,2));
    fresnelV = zeros(size(Land_Mask,1),size(Land_Mask,2));
    
    for ang_id=1:num_surf_angles
        theta=angles(ang_id);
        for m=1:size(Land_Mask,1)
            for n=1:size(Land_Mask,2)
                costheta = cosd(theta);
                sintheta = sind(theta);
                sintheta2 = sintheta^2;
                sq = sqrt(dielectric_constant(m,n)-sintheta2);
                
                denom_1 = costheta + sq;
                denom_2 = dielectric_constant(m,n)*costheta + sq;
                
                if ((real(denom_1)==0 && imag(denom_1)==0)||(real(denom_2)==0 && imag(denom_2)==0))
                    disp('�������');
                end
                
                %����ˮƽ�������򣬴�ֱ��������ĵ�Fresnelϵ��
                %++++++++++++++++++++++����ϵ��������������ͬ�ĸ�������ʶ����ȶ��ԣ��Ƿ����ʵ�ģ��ƽ��
                fresnelH (m,n)= abs((costheta - sq)/denom_1);
                fresnelH (m,n)= fresnelH(m,n)^2;
                fresnelV (m,n)= abs((dielectric_constant(m,n)*costheta - sq)/denom_2);
                fresnelV (m,n)= fresnelV(m,n)^2;
                %fresnelH (m,n) = (costheta - sq)/denom_1;
                %fresnelV (m,n) = (dielectric_constant(m,n)*costheta - sq)/denom_2;
            end
        end
        surface_inp(:,:,ang_id,1) = theta ;   %�Ƕ�
        surface_inp(:,:,ang_id,2) = fresnelV' ;%V����������
        surface_inp(:,:,ang_id,3) = fresnelH';%H����������
    end
    save([mainpath,datapath,'surface_input',timesuffix,'.mat'],'surface_inp');
    
end
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%The rest is not needed%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%��������Է�������¹���TB%%%%%%%%%%%%%%%%%%%%
% TBH = zeros(size(Land_Mask,1),size(Land_Mask,2));
% TBV = zeros(size(Land_Mask,1),size(Land_Mask,2));
%
% for m=1:size(Land_Mask,1)
%     for n=1:size(Land_Mask,2)
%
% if (Land_Mask(m,n)==1)
% TBH(m,n) =double(Soil_Temperture(m,n)) * (1 - fresnelH(m,n));
% TBV(m,n) =double(Soil_Temperture(m,n)) * (1 - fresnelV(m,n));
% else
% TBH(m,n) = double(SST(m,n)) * (1 - fresnelH(m,n));
% TBV(m,n) = double(SST(m,n)) * (1 - fresnelV(m,n));
% end
%     end
% end
%
% figure();colormap;h=pcolor(TBH);set( h, 'linestyle', 'none')
% figure();colormap;h=pcolor(TBV);set( h, 'linestyle', 'none')





%

