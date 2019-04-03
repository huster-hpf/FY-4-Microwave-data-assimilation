get_simulation_plan

if surfemis_model == 0
    Chen_ke_model
elseif surfemis_model == 1
    Fastem_5_model_data_prepare  % Only data needed by Fastem5 is saved.
    % Since fastem5 is frequency dependent, it is better to calculate the 
    % emissivities just right before DOTLRT runs.
end