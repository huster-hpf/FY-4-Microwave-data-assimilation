function [uvsample,Num_angle,Num_radius,d_radius] = UV_Uniform_Circle(Tb,xi_max,eta_max,factor_delta_uv,Num_angle,factor_max_radius)
%   函数功能：在uv采样平面上产生一个角度和半径都均匀间隔的理想UV圆环采样平面，并计算其uv采样点坐标**********************************
%            附加功能是根据要仿真的亮温图像，使该圆环采样完全覆盖图像的最高采样频率*factor_max_radius
%   输入参数:
%    Tb             ：要仿真的亮温图像         
%    xi_max         ：%亮温图像ξ方向（即经度方向）的最大值,图像空间范围为-ξmax--ξmax 
%    eta_max        ：%亮温图像η方向（即纬度方向）的最大值,图像空间范围为-ηmax--ηmax
%    factor_delta_uv：最小间距倍数因子，默认半径最小间距应该等于1/2*xi_max，而实际半径最小间距为标准间距/factor_delta_uv
%    Num_angle      ：每一个圆环上的uv采样点数
%    factor_max_radius ：最大半径倍数因子，默认最大半径为图像最高采样频率，实际最大半径为默认半径*factor_max_radius
%   输出参数：
%    uvsample       : 均匀间隔的UV圆环采样平面所有采样点坐标，从内圈开始按圈排序
%    Num_angle      ：每一个圆环上的uv采样点数
%    Num_radius     ：半径个数，即同心圆环个数
%    d_radius       ：半径间距                单位：波长
                                    
%   by 陈柯 2016.06.24  ******************************************************

   % 根据图像采样频率产生一个半径均匀间隔的UV圆环采样阵列
   d_angle = (2*pi/Num_angle);
   angle = linspace(-pi,pi-d_angle,Num_angle);
   
   radius_extend = 1;
   [N_eta,N_xi] = size(Tb);
   if mod(N_xi,2)==0
      u = ceil((N_xi/2)/(2*xi_max)/cos(pi/4))+radius_extend;
   else
      u = ceil((N_xi-1)/2/(2*xi_max)/cos(pi/4))+radius_extend;
   end
   if mod(N_eta,2)==0
      v = ceil((N_eta/2)/(2*eta_max)/cos(pi/4))+radius_extend;
   else
      v = ceil((N_eta-1)/2/(2*eta_max)/cos(pi/4))+radius_extend;
   end
   disp(u);disp(v);
   delta_u = 1/(factor_delta_uv*2*xi_max);delta_v =1/(factor_delta_uv*2*eta_max);
   d_radius = min(delta_u,delta_v);max_radius = max(u,v)*factor_max_radius;
   Num_radius = ceil(max_radius/d_radius);
   uvsample = 0;
   for k = 1:1:Num_radius
       current_radius = k*d_radius; 
       uv_single_circle =  current_radius*exp(1i*angle);
       uvsample = [uvsample uv_single_circle];
   end
   
   
   
   