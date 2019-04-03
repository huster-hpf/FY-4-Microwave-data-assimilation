function  MBE = AP_Main_Beam_efficiency_Gail(Ba,Null_theta,taper)
%   函数功能：计算综合孔径阵列方向图主波束效率**********************************
%            按照返回波束效率
%  
%   输入参数:
%    Ba           :天线电长度参数
%    taper        :孔径照度；
%    Null_BW      :零点波束宽度
%   输出参数：
%    MBE          :主波束效率                                      
%   by 陈柯 2016.06.24  ******************************************************

num_Full = 18000;
d_angle=180/num_Full;                %unit degree
theta_all=d_angle:d_angle:90-d_angle;%分母角度范围
theta_max = asind(10/Ba); 
theta=d_angle:d_angle:theta_max;     %分子角度范围

num_theta = length(theta_all);
num_beam_efficiency = length(theta);
beam_efficiency=zeros(1,num_beam_efficiency);
denominator = 0;
numerator = 0;

%计算分母  
for n=1:num_theta
    u=Ba*sind(theta_all(n));
    du=Ba*cosd(theta_all(n))*d_angle*pi/180;
    denominator=denominator+(besselj(taper+1,u))^2/u^(2*taper+1)/sqrt(1-(sind(theta_all(n)))^2)*du;
end
%计算分子
for m=1:num_beam_efficiency
    for n=1:m
        u=Ba*sind(theta(n));
        du=Ba*cosd(theta(n))*d_angle*pi/180;
        numerator=numerator+(besselj(taper+1,u))^2/u^(2*taper+1)/sqrt(1-(sind(theta(n)))^2)*du;
    end
    beam_efficiency(m)=numerator/denominator;
    numerator=0;        
end      
mark_Null =( abs(theta-Null_theta)==min(abs(theta-Null_theta)));
MBE = beam_efficiency(mark_Null)*100;


