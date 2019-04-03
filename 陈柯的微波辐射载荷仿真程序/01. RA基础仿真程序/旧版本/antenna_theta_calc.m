function  angle = antenna_theta_calc(theta_axis,phi_axis,theta,phi)
%   函数功能：计算球坐标系下一个参考向量与一个向量矩阵之间的夹角**********************************
%            返回夹角矩阵
%  
%   输入参数:
%    theta_axis ：参考向量的天顶角
%    phi_axis   ：参考向量的方位角
%    theta      : 向量矩阵的天顶角
%    phi        : 向量矩阵的方位角
%   输出参数：
%    angle      : 夹角矩阵                                       
%   by 陈柯 2016.09.24  ******************************************************
theta1 = phi_axis ;
phi1 =90-theta_axis;
theta2 = phi;
phi2 = 90-theta; 

a = cosd(theta1);
b = cosd(theta2);
c = tand(phi1);
d = tand(phi2);
e = tand(theta1);
f = tand(theta2);
angle = acosd((1/a^2+1./b.^2+c^2+d.^2-(e-f).^2-(c-d).^2)./(2*sqrt((1/a^2+c^2)*(1./b.^2+d.^2))));



