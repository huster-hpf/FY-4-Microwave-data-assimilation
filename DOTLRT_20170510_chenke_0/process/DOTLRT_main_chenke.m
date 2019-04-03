%% ++++++++++++May keep updating this main process



%% =================Path setting ROUTINE
% !!! Caution:Almost every part of this program has its own pathsetting 
% subroutines. For the convenience of future mainteinence, this should be 
% fixed by integrating all these path-setting subroutines in to a single 
% script...
getpath
command=['cd ',mainpath];system(command);
command=['rm -rf ',mainpath,datapath,'*'];system(command); % Clear datapath directory
command=['rm -rf ',mainpath,outputpath,'*'];system(command); % Clear outputpath dir~

meteorology_data_prepare

file_index=1;
save([mainpath,datapath_sequence,'index.mat'],'file_index')
% while file_index<=length(wrf_file_list)
%     
%     command=['ln -s ',mainpath,datapath_sequence,wrf_file_list{file_index},' ',...
%         mainpath,datapath,'wrfout_d01.nc']; % link wrfout file from data_sequencepath to datapath
%     system(command)
%     getdetail


%% =================Plan making ROUTINE


%% ==============Set parameters ____see readme.txt
%get_clay_salinity
% ----------------Set surface_inp
% RT_SURFACE_input
Fastem_5_model_data_prepare 
% --------------Run ncl scripts----------------
% To get parameters that are not directly contained in wrfout.nc
% ....
get_simulation_plan
%% =============== Processing data===============

% ----------------Pre_processing and save to everything.mat
% Do this process to create and save everything needed to run DOTLRT- 
% FORTRAN code
Before_runningDOTLRT  

% ----------------Run DOTLRT on everything.mat
runDOTLRT_from_everything_on_different_frequency
% FORTRAN code on everything needed, and save the results.


% Output pictures on the results produced by DOTLRT and save them
%output_TBMAP 

getpath % runs get_file_list
get_simulation_plan

load([mainpath,datapath_sequence,'index.mat'])
%data_dir=[num2str(file_index)];
data_dir='/special/';
command=['mkdir -p ',mainpath,datapath_sequence,data_dir];system(command);
command=['mv -f ',mainpath,outputpath,'* ',...
    mainpath,datapath_sequence,data_dir];system(command);
command=['rm -rf ',mainpath,datapath,'*'];system(command); % Move output files to archive path
file_index=file_index+1;
save([mainpath,datapath_sequence,'index.mat'],'file_index')
% end
