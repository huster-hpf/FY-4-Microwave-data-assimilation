% This program extracts atmospheric parameters from WRF output
% and sets surface and instrument parameters. Then it combines
% all parameters together and creates inputs arrays for DOTLRT run.
clear all;
close all;
clear classes;


getpath%In this file, name of directoris are set


% get plan
get_simulation_plan %In this file,simulation time index and MWR parameters
%(saved in a cell array MWR_spec_pool) are set.


num_sb_freqs  = 1;    %included in everything



%%%%%+++++++++++++++++10_6 fix
% Run DOTLRT ...
%tic


for sim_count=1:size(timeseries,2)%%%%%%%%++++++++++++++++++10_6 fix
    tic
    timeIndex=timeseries(sim_count)
    %% Load specific files for specific time
    timesuffix = timetab(timeIndex,:)
    
    if interplot_to_ATMS_coords_at_differentangles == 1
        load([mainpath,datapath,'interp/','everything',timesuffix,'.mat']);
    else
        load([mainpath,datapath,'everything',timesuffix,'.mat']);
    end
    
    % override num_streams
    %num_streams=4;
    
    MWR_spec = MWR_spec_pool{sim_count};
    num_channel = size(MWR_spec,1);
    
    %% Now calculating at specific time for different frequency
    for channel_index = 1:num_channel
        disp(['Now calculating channel',num2str(channel_index)])
        instr_spec = MWR_spec(channel_index,:)  %set channel specification
        
        % -----If fastem-5 is applied,some calcs needs to be done 
        % here, because fastem-5 is channel frequency dependent,which is 
        % not the same with Chenke model. ----20160328
        if surfemis_model == 1 % 0 Chenke; 1 Fastem-5
            Fastem_5_model_calc;% calculates surface_inp_temp(4-D array) from surface_inp( 1x1 struct)
        else
            surface_inp_temp = surface_inp;%surface_inp is already 4-D array
        end
        % -----------------------------------------------------------
        
        
       parfor rowIndex = 1:rowDim
            disp(['row ' int2str(rowIndex)]);
            % Cross sectional cut at col: 75, 120, 150
            for colIndex = 1:colDim
                if validation_matrix(rowIndex, colIndex)==1
                    
                    surfInputs = reshape(surface_inp_temp(rowIndex, colIndex, :,:), num_surf_angles, 3);
                    atmInputs  = reshape(atm_inp(rowIndex, colIndex, :,:), num_levels, 9);
                    
                    if user_angle_flag==1
                        inp_theta_point = user_angle; % user specification overrides inp_theta;(nadir angle degrees)
                    else
                        inp_theta_point=inp_theta(rowIndex, colIndex);
                    end
                    
                    [Tb_inp,tau,Tb,dTb_dT,dTb_dp,dTb_dq,dTb_dw,stream_angles] = mex_matlab_mrt( inp_height, inp_theta_point, num_sb_freqs, instr_spec, num_streams, num_surf_angles, surfInputs, num_levels, atmInputs);
                    %为加快�?度，有时将num_streams设置�?
                    % collect outputs
                    TbMap(rowIndex, colIndex, :) = Tb_inp(:);
                    
                 
                                    dTb_dTCut(rowIndex,colIndex,:,:) = dTb_dT;
                                    dTb_dpCut(rowIndex,colIndex, :,:) = dTb_dp;
                                    dTb_dqCut(rowIndex, colIndex,:,:) = dTb_dq;
                                  dTb_dClCut(rowIndex,colIndex ,:,:) = reshape(dTb_dw(:,1,:), zDim, 2);
                                 dTb_dRnCut(rowIndex, colIndex,:,:) = reshape(dTb_dw(:,2,:), zDim, 2);
                                     dTb_dIceCut(rowIndex,colIndex ,:,:) = reshape(dTb_dw(:,3,:), zDim, 2);
                                     dTb_dSnowCut(rowIndex, colIndex,:,:) = reshape(dTb_dw(:,4,:), zDim, 2);
                                     dTb_dGrpCut(rowIndex,colIndex, :,:) = reshape(dTb_dw(:,5,:), zDim, 2);
                   
               %******************************here we test the jacobian
               %matrix
%                                  for m=1:59
%                                              order=10000;
%                                              racount=50;
%                                        atmtest1=atmInputs;
%                                        atmtest2=atmInputs;
%                  
%                                      scale=atmInputs(m+1,3)/order; 
%                                         T_cache=atmInputs(:,3); 
               %  deriv=zeros(racount,1); 
%                                    for count=1:racount 
%                                            fluct=rand*scale; 
%                                            T_cache(m)=atmInputs(m+1,3)+fluct;
%                                        atmtest1(m+1,3)=T_cache(m);
%                                        [f1,aa,bb,cc,dd,ee,ff,gg] = mex_matlab_mrt( inp_height, inp_theta_point, num_sb_freqs, instr_spec, num_streams, num_surf_angles, surfInputs, num_levels, atmtest1);
%                                               T_cache(m)=atmInputs(m+1,3)-fluct;
%                                               atmtest2(m+1,3)=T_cache(m);
%                                                  [f2,aa,bb,cc,dd,ee,ff,gg] = mex_matlab_mrt( inp_height, inp_theta_point, num_sb_freqs, instr_spec, num_streams, num_surf_angles, surfInputs, num_levels, atmtest2);
%                                                      deriv(count)=(f1(1)-f2(1))/fluct/2;
%                                    end
%                                                 J(m)=sum(deriv)/racount;
%                                  end
%                                               JT(rowIndex,colIndex, :)=J';
                                     
                                     
                                     
                                     
                else
                    TbMap(rowIndex, colIndex, :)=[0,0];
                end
            end
        end
        timesuffix(timesuffix==':')='_';
        if interplot_to_ATMS_coords_at_differentangles == 1
           save([mainpath,outputpath,'WRFTbMap-',num2str(MWR_spec(channel_index,1)),'-','_interp','.mat'], 'TbMap');
        else
%            save([mainpath,outputpath,'C-',num2str(channel_index),'.mat'], 'TbMap');
           save([mainpath,outputpath,'WRFTbMap-',num2str(MWR_spec(channel_index,1)),'.mat'], 'TbMap');
           
        end
      
        %% donnot save dbcut
        save([mainpath,outputpath,'WRFdTbCut-',num2str(MWR_spec(channel_index,1)),'.mat'], '*Cut');
        
        toc
    end
end