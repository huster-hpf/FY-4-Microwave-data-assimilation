function [uv_inside_pi,V_inside_pi] = UV_inside_pi(uv_sample,uv_sample_pi,V)
%   函数功能：从uv采样点平面内选择在[-pi,pi]范围内*****************************
%             因为输入亮温图像按照DFT变换的最高频率归一化后就是[-pi,pi]，
%               超出的属于频率混叠范围，对仿真有负影响
%  
%   输入参数:
%    uv_sample      ：uv平面采样点坐标,单位：波长         
%    uv_sample_pi   ：uv平面采样点对[-pi,pi]范围归一化后的坐标，无量纲
%    V              ：可见度函数值  

%   输出参数：
%   uv_inside_pi    : [-pi,pi]范围内的uv平面采样点，单位：波长 
%   V_inside_pi     : [-pi,pi]范围内的可见度函数值
%   by 陈柯 2016.06.24  ******************************************************
num_uv = length(uv_sample);
count =1;
for k =1:num_uv
    if abs(real(uv_sample_pi(k)))<=pi && abs(imag(uv_sample_pi(k)))<=pi
       uv_inside_pi(1,count) = uv_sample(k);
       V_inside_pi(1,count) =  V(k);
       count = count+1;
    end
end