%%%% +++++++Goodwillie Lee 20160328
%% This script packs data needed by Fastem5 into a series of structs named surface_inp.



clc;
clear;
getpath            %

get_simulation_plan

load([mainpath,surfacepath,'angles.mat']);
num_surf_angles = size(angles,2);

load([mainpath,datapath_sequence,'meteorology_data','.mat']);

% WRF_Output_filename = [mainpath,datapath,wrfout];
Land_Mask_3Dvar = GRAPESLAND;  % 1 for land,0 for sea
TSK_3Dvar = GRAPESTSK;
U10 = GRAPESU10;
V10 = GRAPESV10;

%%%%%%%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%%%%%%%
for timeIndex=timeseries(1:size(timeseries,2))
    
    
    %% [emissstokes,reflectstokes] = calcemis(freq_ghz,zenith,azimuth,surftype,skin,wind)
    
    surface_inp.surftype = Land_Mask_3Dvar(:,:,timeIndex);
    surface_inp.tsk = TSK_3Dvar(:,:,timeIndex);
    surface_inp.wind_U = U10(:,:,timeIndex);
    surface_inp.wind_V = V10(:,:,timeIndex);

    surface_inp.angles = angles;
    surface_inp.num_surf_angles = num_surf_angles;
    
    timesuffix = timetab(timeIndex,:);
    save([mainpath,datapath,'surface_input',timesuffix,'.mat'],'surface_inp');
    
end
clear






%

