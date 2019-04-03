function [uv_theta_interp]= PP_theta_uvsample(uvsample,N)
%   函数功能：   伪极网格角度插值可见度采样计算函数**********************************
%               将uv平面一圆圈上的角度均匀间距的采样点插值到伪极网格对应的等斜率角度上
%               计算其uv采样点坐标
%  
%   输入参数:
%   uvsample        ：待角度插值的uv采样平面，应该是同一圆环上的角度均匀间距的采样点
%   N               : 要插值的伪极网格点数
%   输出参数：
%   v_theta_interp  ：角度插值后的可见度函数值，长度为4N
%                      
%   by 陈柯 2016.06.24  ******************************************************

uv_radius = mean(abs(uvsample)); %当前被插值uv圆环的半径

% 插值后的伪极网格点角度，分成四个象限分别计算
PP_theta = zeros(1,4*N);
PP_theta(1,1:N) = atan((-N/2+1:1:(N/2))/(N/2));
PP_theta(1,N+1:2*N) = pi/2+atan((-N/2+1:1:(N/2))/(N/2));
PP_theta(1,2*N+1:3*N) = pi+atan((-N/2+1:1:(N/2))/(N/2));
PP_theta(1,3*N+1:4*N) = 3*pi/2+atan((-N/2+1:1:(N/2))/(N/2));
%将角度范围投影到-pi——pi之间
PP_theta = wrapToPi(PP_theta);

% 根据伪极网格点角度可以计算得到插值后的uv采样点的坐标（半径不变）
uv_theta_interp = uv_radius*exp(1i*PP_theta);

    