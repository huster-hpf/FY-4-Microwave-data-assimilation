function run_RA_Radiometer_Simulation_bat(in_dir,out_dir,time,typhoon_name)
%edit by hongpengfei
%2018.11.28


output_dir=sprintf('%s/%s',out_dir,time);
mkdir(output_dir);
file_path=sprintf('%s/%s',in_dir,time);
file_path1=sprintf('%s/latlon',in_dir);
RA_Radiometer_Simulation_bat_ver8
