% This script calculates surface_emiss&refl from surface_inp the structure

% surface_inp is a structure whos details are listed as below:
%
%            surftype: [549x469 logical]
%                 tsk: [549x469 double]
%              wind_U: [549x469 double]
%              wind_V: [549x469 double]
%              angles: [0 10 20 30 40 50 60 70 80 90]
%     num_surf_angles: 10

% surface_inp = zeros(rolDim,colDim,num_surf_angles,3);
%[emissstokes,reflectstokes] = calcemis(freq_ghz,zenith,azimuth,surftype,skin,wind);

freq_ghz = instr_spec(1);
angles = surface_inp.angles;
surface_inp_temp = zeros(rowDim,colDim,num_surf_angles,3);


%fastem_5 = [3.0 5.0 15.0 0.1 0.3]; % Default

%fastem_5 = [2.3 1.9 21.8 0.0 0.5]; % Summer bare soil

%Now fastem_5 is set in get_simulation_plan  ---- Ligongwei 20160707




for ang_id=1:num_surf_angles
    theta=angles(ang_id);
    parfor m=1:rowDim
        for n=1:colDim
            wind = [surface_inp.wind_U(m,n) surface_inp.wind_V(m,n)];
            [emissstokes,reflectstokes] = calcemis(freq_ghz,...
                theta,0,surface_inp.surftype(m,n),...
                [surface_inp.tsk(m,n) fastem_5],wind,salinity(m,n));
%             surface_inp_temp(m,n,ang_id,1) = theta ;   %zenith angle
%             surface_inp_temp(m,n,ang_id,2) = reflectstokes(1);% surface reflectivity in v polarization
%             surface_inp_temp(m,n,ang_id,3) = reflectstokes(2);% surface reflectivity in h polarization
            surface_inp_temp(m,n,ang_id,:) = [theta reflectstokes(1) reflectstokes(2)];
            if n==1
                clc
                disp('Now calculating surface reflectivities using Fastem5...')
                disp(['----',num2str(((ang_id-1)*rowDim+m)*100/(rowDim*num_surf_angles)),'%------'])
                disp(['Now calculating channel',num2str(channel_index)])
            end
        end
    end
    
end

%surface_inp = surface_inp_temp;
