% if interplot_to_ATMS_coords_at_differentangles == 1
%     interplotting_wrf_to_ATMS.m
% end

%% Load  ATMS_data
load([mainpath,datapath,ATMS_data]);
% Acquired parameters:
% ATMS_FileName,freq_index_tab
% Lat,Long,data_TB,SateZenith_angle

rowDim = size(data_TB,2);    % unstaggered longitude
colDim = size(data_TB,3);    % unstaggered latitude


%% Get  WRF_coordinates
XLO=ncread([mainpath,datapath,wrfout],'XLONG',[1,1,1], [Inf, Inf, 1]);
XLO_max=max(max(XLO));
XLO_min=min(min(XLO));
XLA=ncread([mainpath,datapath,wrfout],'XLAT',[1,1,1], [Inf, Inf, 1]);
XLA_max=max(max(XLA));
XLA_min=min(min(XLA));

%% Cut ATMS_data because some elements of ATMS is not in WRF area!!!!!!!!
%% A new matrix called validation_matrix is formed
validation_matrix=ones(rowDim,colDim);% if valid(in wrf area),set to 1, else 0;
for i=1:rowDim
    for j=1:colDim
        if Lat(i,j)>XLA_max||Lat(i,j)<XLA_min||Long(i,j)>XLO_max||Long(i,j)<XLO_min
            validation_matrix(i,j)=0;
        end
    end
end




%% interpolate and override everything


%  save([mainpath,datapath,'everything',timesuffix,'.mat'], 'rowDim', 'colDim', 'surface_inp', 'num_surf_angles', ...
%         'atm_inp','num_levels', 'inp_height', 'inp_theta', 'num_streams'...,
%         ,'num_surf_angles', 'num_levels'...
%         ,'dTb_dTCut', 'dTb_dpCut', 'dTb_dqCut', 'dTb_dClCut', 'dTb_dRnCut', 'dTb_dIceCut'...
%         ,'dTb_dSnowCut', 'dTb_dGrpCut','zDim','validation_matrix','salinity');

%% Interplotting surface_inp
if surfemis_model == 1
    %     surface_inp.surftype
    %     surface_inp.tsk
    %     surface_inp.wind_U
    %     surface_inp.wind_V
    %     surface_inp.angles = angles;
    %     surface_inp.num_surf_angles = num_surf_angles;
    F = griddedInterpolant(XLA',XLO',(double(surface_inp.surftype))');
    surftype_interp = F(Lat,Long).*validation_matrix;
    surface_inp.surftype = (surftype_interp>0.2);
    clear surftype_interp
    
    F = griddedInterpolant(XLA',XLO',(surface_inp.tsk)');
    tsk_interp = F(Lat,Long).*validation_matrix;
    surface_inp.tsk = tsk_interp;
    clear tsk_interp
    
    F = griddedInterpolant(XLA',XLO',(surface_inp.wind_U)');
    wind_U_interp = F(Lat,Long).*validation_matrix;
    surface_inp.wind_U = wind_U_interp;
    clear wind_U_interp
    
    F = griddedInterpolant(XLA',XLO',(surface_inp.wind_V)');
    wind_V_interp = F(Lat,Long).*validation_matrix;
    surface_inp.wind_V = wind_V_interp;
    clear wind_V_interp
    
elseif surfemis_model==0
    [~,~,C,D]=size(surface_inp);
    surface_inp_interp = zeros(rowDim,colDim,C,D);
    for h=1:rowDim
        for k=1:colDim
            surface_inp_interp(h,k,:,1) = surface_inp(1,1,:,1);
        end
    end
    
    for i=1:C
        for j=2:D
            F = griddedInterpolant(XLA',XLO',surface_inp(:,:,i,j)');
            surface_inp_interp(:,:,i,j) = F(Lat,Long).*validation_matrix;
        end
    end
    surface_inp = surface_inp_interp;
    clear surface_inp_interp
end






%% Interplotting atm_inp
[~,~,C,D]=size(atm_inp);
atm_inp_interp = zeros(rowDim,colDim,C,D);

for i=1:C
    for j=1:D
        F = griddedInterpolant(XLA',XLO',atm_inp(:,:,i,j)');
        atm_inp_interp(:,:,i,j) = F(Lat,Long).*validation_matrix;
    end
end

atm_inp = atm_inp_interp;
clear atm_inp_interp

%% Interplotting salinity
F = griddedInterpolant(XLA',XLO',salinity');
salinity_interp = F(Lat,Long).*validation_matrix;

salinity = salinity_interp;
clear salinity_interp

%% Overriding inp_theta
inp_theta = double(SateZenith_angle);


%% Overriding  OUTPUT arrays
TbMap = zeros(rowDim, colDim, 2);
dTb_dTCut = zeros(rowDim, colDim,zDim, 2);
dTb_dpCut = zeros(rowDim, colDim,zDim, 2);
dTb_dqCut = zeros(rowDim, colDim,zDim, 2);
dTb_dClCut = zeros(rowDim,colDim, zDim, 2);
dTb_dRnCut = zeros(rowDim,colDim, zDim, 2);
dTb_dIceCut = zeros(rowDim,colDim, zDim, 2);
dTb_dSnowCut = zeros(rowDim, colDim, zDim, 2);
dTb_dGrpCut = zeros(rowDim, colDim,zDim, 2);
surfRadTemp = zeros(rowDim, colDim, 2); % at smallest quadrature angle


