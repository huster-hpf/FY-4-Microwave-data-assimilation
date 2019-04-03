% wrf_file_list={'wrfout_d01_2015-10-04_00_00_00';...
%    'wrfout_d01_2015-10-08_00_00_00'};

file_list = dir([mainpath,datapath_sequence]);
wrf_file_list = {};
for temp_0828=1:length(file_list)
    name = file_list(temp_0828).name;
    if ~isempty(strfind(name,wrf_id_str)) % wrf_id_str tells which files are selected in data_sq
        wrf_file_list = [wrf_file_list,[file_list(temp_0828).name]];
    end
end
clear temp_0828 file_list name