%% 用于按需要生成angles.mat文件，提供如下两个量
%%% angles(1，num_surf_angles)       高斯-勒让德求积公式的插值点
%%% num_surf_angles                  高斯-勒让德求积公式的插值点数目

%%% content
clc
clear
givepath
angles=[0:10:90];
num_surf_angles=size(angles,2);

save([mainpath,subpath,'angles.mat'],'angles','num_surf_angles');