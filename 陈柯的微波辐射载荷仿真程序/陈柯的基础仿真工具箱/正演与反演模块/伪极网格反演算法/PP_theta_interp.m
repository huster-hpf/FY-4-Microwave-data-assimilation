function [v_theta_interp,uv_theta_interp]= PP_theta_interp(visibility,uvsample,N)
%   函数功能：   伪极网格角度插值函数**********************************
%               将uv平面一圆圈上的角度均匀间距的采样点插值到伪极网格对应的等斜率角度上          
%  
%   输入参数:
%   visibility      ：待角度插值的可见度函数
%   uvsample        ：待角度插值的uv采样平面，应该是同一圆环上的角度均匀间距的采样点
%   N               : 要插值的伪极网格点数
%   输出参数：
%   v_theta_interp  ：角度插值后的可见度函数值，长度为4N
%   uv_theta_interp ：角度插值后的uv采样平面，长度为4N                         
%   by 陈柯 2016.06.24  ******************************************************

M = length(visibility)/2;        %目前插值公式要求样本数为偶数 
uv_radius = mean(abs(uvsample)); %当前被插值uv圆环的半径
uv_theta = angle(uvsample);      %当前被插值uv圆环上所有采样点的角度
% 插值后的伪极网格点角度，分成四个象限分别计算
PP_theta = zeros(1,4*N);
PP_theta(1,1:N) = atan((-N/2+1:1:(N/2))/(N/2));
PP_theta(1,N+1:2*N) = pi/2+atan((-N/2+1:1:(N/2))/(N/2));
PP_theta(1,2*N+1:3*N) = pi+atan((-N/2+1:1:(N/2))/(N/2));
PP_theta(1,3*N+1:4*N) = 3*pi/2+atan((-N/2+1:1:(N/2))/(N/2));
%将角度范围投影到-pi——pi之间
PP_theta = wrapToPi(PP_theta);
uv_theta = wrapToPi(uv_theta);

% 根据伪极网格点角度可以计算得到插值后的uv采样点的坐标（半径不变）
uv_theta_interp = uv_radius*exp(1i*PP_theta);
v_theta_interp = zeros(1,4*N);
interp_coeffcient = zeros(1,2*M); %插值系数
%角度插值，插值公式来源于张成博士论文公式（3-65）
for i = 1:4*N
    theta = PP_theta(i);             %当前要被插值的伪极网格角度
    del_theta = abs(theta-uv_theta); %被插值点与现在所有采样点的角度距离 
    %如果被插值点与现有的某采样点重合，则不需要插值，直接采用现有采样点上的可见度函数值
    
    if min(del_theta)<1e-6 
       v_theta_interp(i) = visibility(del_theta==min(del_theta));       
    elseif abs(max(del_theta)-2*pi)<1e-6
       v_theta_interp(i) = visibility(del_theta==max(del_theta));      
    else       
       for k = 1:2*M
           interp_coeffcient(k) = sin(1/2*(2*M-1)*(theta-uv_theta(k)))/(2*M*sin(1/2*(theta-uv_theta(k))));                      
       end
       v_theta_interp(i) = sum(visibility.*interp_coeffcient);  %角度插值后的可见度函数值
       %  v_theta_interp(i) = interp1(uv_theta,real(visibility),theta,'spline')+1i*interp1(uv_theta,imag(visibility),theta,'spline');三次样条插值 
    end
end
    