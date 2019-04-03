% %% This file is basically used to test codes
% eastwest=ncread('wrfout.nc','XLONG');
% northsouth=ncread('wrfout.nc','XLAT');
% east=max(max(max(eastwest)))
% west=min(min(min(eastwest)))
% north=max(max(max(northsouth)))
% south=min(min(min(northsouth)))
getpath
times=ncread('wrfout_d01.nc','Times')'
% load modelHeight.txt;
% modelHeight = reshape(modelHeight, rowDim, colDim, zDim);
% clc
% clear
% 
% figure(1)
% load surface_input.mat
% pcolor((abs(surface_inp(:,:,8,2))).^2)
% 
% surfTemperature=ncread('wrfout_d01.nc','TSK');%This variable is chosen to 
%                                         %represent the surface temperature
% figure(2);pcolor(double(surfTemperature(:,:,1)'))
% 
% 
% surf=ncread('wrfout_d01.nc','LU_INDEX');%This variable is chosen to 
%                                         %represent the surface temperature
% figure(3);pcolor(double(surf(:,:,1)))
% TSK                
%            Size:       239x299x5
%            Dimensions: west_east,south_north,Time
%            Datatype:   single
%            Attributes:
%                        FieldType   = 104
%                        MemoryOrder = 'XY '
%                        description = 'SURFACE SKIN TEMPERATURE'
%                        units       = 'K'
%                        stagger     = ''
%                        coordinates = 'XLONG XLAT'
%                        
% TMN                
%            Size:       239x299x5
%            Dimensions: west_east,south_north,Time
%            Datatype:   single
%            Attributes:
%                        FieldType   = 104
%                        MemoryOrder = 'XY '
%                        description = 'SOIL TEMPERATURE AT LOWER BOUNDARY'
%                        units       = 'K'
%                        stagger     = ''
%                        coordinates = 'XLONG XLAT'
%                   
% TSLB               
%            Size:       239x299x4x5
%            Dimensions: west_east,south_north,soil_layers_stag,Time
%            Datatype:   single
%            Attributes:
%                        FieldType   = 104
%                        MemoryOrder = 'XYZ'
%                        description = 'SOIL TEMPERATURE'
%                        units       = 'K'
%                        stagger     = 'Z'
%                        coordinates = 'XLONG XLAT'
% SMOIS              
%            Size:       239x299x4x5
%            Dimensions: west_east,south_north,soil_layers_stag,Time
%            Datatype:   single
%            Attributes:
%                        FieldType   = 104
%                        MemoryOrder = 'XYZ'
%                        description = 'SOIL MOISTURE'
%                        units       = 'm3 m-3'
%                        stagger     = 'Z'
%                        coordinates = 'XLONG XLAT'
% SSTSK              
%            Size:       239x299x5
%            Dimensions: west_east,south_north,Time
%            Datatype:   single
%            Attributes:
%                        FieldType   = 104
%                        MemoryOrder = 'XY '
%                        description = 'SKIN SEA SURFACE TEMPERATURE'
%                        units       = 'K'
%                        stagger     = ''
%                        coordinates = 'XLONG XLAT'

% 'rowDim', 'colDim', 'surface_inp', 'num_surf_angles', ...
% 'atm_inp num_levels', 'inp_height', 'inp_theta', 'num_sb_freqs', 'instr_spec', 'num_streams'..., 
% ,'num_surf_angles', 'surfInputs', 'num_levels', 'atmInputs'...
% ,'dTb_dTCut', 'dTb_dpCut', 'dTb_dqCut', 'dTb_dClCut', 'dTb_dRnCut', 'dTb_dIceCut'...
% ,'dTb_dSnowCut', 'dTb_dGrpCut'
% save([mainpath,outputpath,'everything.mat'], 'rowDim', 'colDim', 'surface_inp', 'num_surf_angles', ...
% 'atm_inp','num_levels', 'inp_height', 'inp_theta', 'num_sb_freqs', 'MWR_spec', 'num_streams'..., 
% ,'num_surf_angles', 'num_levels'...
% ,'dTb_dTCut', 'dTb_dpCut', 'dTb_dqCut', 'dTb_dClCut', 'dTb_dRnCut', 'dTb_dIceCut'...
% ,'dTb_dSnowCut', 'dTb_dGrpCut','zDim');
% 
% 
% clear all;
% % close all;
% % clear classes;
% % 
% % % mainpath='/media/lee/学习工作/Lee_s workshop/matlab/RTMODEL/DOTLRT_20150923第二次实验/';
% % datapath='data/';
% % outputpath='output/';
% % wrfout = 'wrfout_d01.nc';
% % surfacefile='surface_input.mat';
% % 
% % %load everything.mat
% % 
% % % different time
% % Times = ncread(wrfout,'Times')'
% % timeDim = size(Times,1)
% 
% %初始化Matlab并行计算环境 
% CoreNum=4; %设定机器CPU核心数量，我的机器是四核，所以CoreNum=4 
% if matlabpool('size')<=0 %判断并行计算环境是否已然启动 
% matlabpool('open','local',CoreNum); %若尚未启动，则启动并行环境 
% else
% disp('并行环境已经启动'); %说明并行环境已经启动 
% end
% 
% matlabpool close 
                       