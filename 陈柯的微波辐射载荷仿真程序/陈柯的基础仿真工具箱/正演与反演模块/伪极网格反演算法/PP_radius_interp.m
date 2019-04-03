function [v_radius_interp,uv_radius_interp]= PP_radius_interp(visibility,uvsample,N,v0)
%   函数功能：   伪极网格半径插值函数**********************************
%               将uv平面同一角度的一条半径采样点插值到伪极网格对应的均匀半径采样点上          
%  
%   输入参数:
%   visibility      ：待半径插值的可见度函数
%   uvsample        ：待半径插值的uv采样平面，应该是同一角度的一条半径上的采样点，注意：该采样点是对2pi归一化后的坐标值
%   N               : 要插值的伪极网格点数
%   v0              ：零点处的可见度函数值
%   输出参数：
%   v_radius_interp ：半径插值后的可见度函数值，长度为N
%   uv_radius_interp：半径插值后的uv采样平面，长度为N                         
%   by 陈柯 2016.06.24  ******************************************************

uv_theta = mean(angle(uvsample)); %当前半径的角度值
num_radius = length(visibility);  %当前半径上采样点个数
uv_radius = abs(uvsample);        %每个采样点的半径值
% 判断该角度所在范围
switch floor(4*abs(uv_theta)/pi)
    case {0}
        uv_theta_mod = abs(uv_theta);
    case {1}
        uv_theta_mod = pi/2 - abs(uv_theta);
    case {2}
        uv_theta_mod = abs(uv_theta)-pi/2;
    case {3,4}
        uv_theta_mod = pi-abs(uv_theta);
end        
% % 根据圆形网格最大半径计算伪极网格最大半径
reference_radius = pi;          %伪极网格的范围为[-pi~pi]
max_radius = max(uv_radius);    %当前uv采样点最大半径，同样归一化到[-pi~pi]
reference_radius_max = reference_radius/abs(cos(uv_theta_mod)); %当前角度对应的伪极网格最大半径值
%如果输入可见度半径小于伪极网格对应半径的最大值，那么则对当前输入采样点外围补零，补到伪极网格半径
if max_radius<reference_radius_max
    extend_num =ceil((reference_radius_max-max_radius)/max_radius*num_radius); 
    uv_radius_extend = max_radius+(1:extend_num+2)*(reference_radius_max-max_radius)/extend_num;
    radius_extend = [uv_radius uv_radius_extend];
    v_extend = ones(1,extend_num+2)*0;
    visibility_extend = [visibility v_extend];
else
    radius_extend = uv_radius;
    visibility_extend = visibility;    
end
%计算径向插值后的uv平面采样点坐标
% 伪极网格格点的半径值
if uv_theta>(-pi/4+1e-6) && uv_theta<=(3*pi/4+1e-6)
    radius_interp =  reference_radius_max*[0:N-1]/N;   
else
    radius_interp =  reference_radius_max*[1:N]/N;
end
% 径向插值后的uv平面采样点坐标（角度不变）
uv_radius_interp = radius_interp*exp(1i*uv_theta);

visibility = [v0 visibility_extend];   %加上零点值
uv_radius = [0 radius_extend];   
v_radius_interp = zeros(1,N);   

%三次样条插值 
% v_interp = interp1(uv_radius,real(visibility),radius_interp,'spline')+1i* interp1(uv_radius,imag(visibility),radius_interp,'spline');

%拉格朗日插值
window_length = 7;
flag_same_position = 0;
flag_radius_beyond = 0;
for i = 1:N
    radius_current=radius_interp(i);            %当前被插值点的半径值 
    %  如果伪极网格点的半径与输入可见度采样某点的半径相同，则直接用改点的输入可见度函数值，不需要插值。
    if min(abs(uv_radius-radius_current))<=1e-6
        v_radius_interp(i) = visibility(abs(uv_radius-radius_current)==min(abs(uv_radius-radius_current)));
        flag_same_position = 1;
    end
    %如果当前伪极网格点的半径已经大于输入可见度的最大半径，则赋予标志位
    if radius_current>max_radius
        flag_radius_beyond =1;
    end
    %设定进行拉格朗日插值的可见度数据窗口
    index_min = find(abs(radius_current-uv_radius) == min(abs(radius_current-uv_radius)) , 1 );%找出与被插值的伪极网格点最接近的输入uv采样点
    if flag_same_position ==0 && flag_radius_beyond==0      
       if index_min>window_length && (index_min+window_length)<=length(uv_radius)
            uv_radius_Lag = uv_radius((index_min-window_length):(index_min+window_length));
            visibility_Lag = visibility((index_min-window_length):(index_min+window_length));%  
        else if index_min<=window_length
            uv_radius_Lag = uv_radius(1:(index_min+window_length));
            visibility_Lag = visibility(1:(index_min+window_length));% 
            else
            uv_radius_Lag = uv_radius((index_min-window_length):length(uv_radius));
            visibility_Lag = visibility((index_min-window_length):length(uv_radius));%     
            end
            
        end
        v_radius_interp(i)=lagrange_interp(uv_radius_Lag,real(visibility_Lag),radius_current)+1i*lagrange_interp(uv_radius_Lag,imag(visibility_Lag),radius_current);
    else if flag_radius_beyond == 1
        v_radius_interp(i) = visibility(index_min);
         end
    end
    flag_radius_beyond = 0;
    flag_same_position = 0;    
end

