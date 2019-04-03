%mainpath='/media/lee/LAB/DOTLRT_expriment/';lee 's computer
mainpath='/g3/hanwei/hpf/DOTLRT_20170510_chenke_0/'; %lab computer
datapath='data/';
datapath_sequence='data_sq/';
outputpath='output/';
picpath='pictures/';
olddatapath='old_data/';
sssdatapath='sss_data/';
meteorology_data_path = 'meteorology_data/';

% Reference folder
referencepath='reference/';
% reference_out_path='output/';

% Surface parameters calculating module
surfacepath = 'ChenRTsurface/';
surface_out_path = 'output/';


%% ========================
% wrfout = 'wrfout_d01.nc';
% wrf_id_str='d01_20';
% get_file_list
% =========================

SSSfile = 'SSS.mat';
Clayfile = 'Clay.mat';

surfacefile='surface_input';


%% Trying to Compare OUTPUT with ATMS Observation
% Interplot everything to ATMS cordinates
ATMS_data = 'atms_data.mat';
%wrf_data = 'everything2012-10-29_06:12:00.mat';
