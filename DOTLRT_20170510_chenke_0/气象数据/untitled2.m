% This program extracts atmospheric parameters from WRF output
% and sets surface and instrument parameters. Then it combines
% all parameters together and creates inputs arrays for DOTLRT run.
clear all;
close all;
clear classes;

% CoreNum=4; %设定机器CPU核心数量，我的机器是四核，所以CoreNum=4 
% if matlabpool('size')<=0 %判断并行计算环境是否已然启动 
% matlabpool('open','local',CoreNum); %若尚未启动，则启动并行环境 
% else
% disp('并行环境已经启动'); %说明并行环境已经启动 
% end

getpath


% get plan
get_simulation_plan
Timetab = ncread(wrfout,'Times')';
num_sb_freqs  = 1;    %included in everything






for sim_count=1:1
    timeIndex=timeseries(sim_count)
    %% Load specific files for specific time
    timesuffix = Timetab(timeIndex,:)
    load([mainpath,datapath,'everything',timesuffix,'.mat']);
    MWR_spec = MWR_spec_pool{sim_count};
    num_channel = size(MWR_spec,1);
    
    %% Now calculating at specific time for different frequency
    for channel_index = 1:1
        disp(['Now calculating channel',num2str(channel_index)])
        instr_spec = MWR_spec(channel_index,:);  %set channel specification
        
        
        for rowIndex = 1:1
            disp(['row ' int2str(rowIndex)]);
            % Cross sectional cut at col: 75, 120, 150
            for colIndex = 1:1
                %disp(['column ' int2str(colIndex)]);
                
                % DOTLRTv1.0    OUTPUT
                
                % Tb_inp(jpol) = brightness temperature for observation level at observation angle
                %        jpol  = 1 (horizontal), 2 (vertical)
                % tau(jud) = opacity for observation level at observation angle
                %     jud  = 1 (upwelling), 2 (downwelling)
                % Tb[jz,jpol] = brightness temperature profile at observation angle
                %    jz               = 1 ... nz    (first level at surface)
                %       jpol  = 1 (horizontal), 2 (vertical)
                % dTb_dT(jz,jpol)
                % dTb_dp(jz,jpol)
                % dTb_dq(jz,jpol)
                % dTb_dw(jz,jhyd,jpol) = Jacobians at observation level, at observation angle
                %        jz                    = 1, nz-1   at levels
                %           jhyd       = 1 ... rnum_hydro_phases
                %                jpol  = 1 (horizontal), 2 (vertical)
                % stream_angles( 1 ... num_streams )
                
                surfInputs = reshape(surface_inp(rowIndex, colIndex, :,:), num_surf_angles, 3);
                atmInputs  = reshape(atm_inp(rowIndex, colIndex, :,:), num_levels, 9);
                
                %atmInputs(:,1)
                %atmInputs(:,2)
                %atmInputs(:,4)
                %atmInputs(:,9)
                
                [Tb_inp,tau,Tb,dTb_dT,dTb_dp,dTb_dq,dTb_dw,stream_angles] = mex_matlab_mrt( inp_height, inp_theta, num_sb_freqs, instr_spec, num_streams, num_surf_angles, surfInputs, num_levels, atmInputs);

                
            end
        end
        
    end
end


%toc

%save('surfRadTemp.mat', 'surfRadTemp');
