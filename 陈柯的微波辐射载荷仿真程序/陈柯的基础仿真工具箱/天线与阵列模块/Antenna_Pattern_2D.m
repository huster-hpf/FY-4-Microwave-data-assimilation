function Antenna_norm_G = Antenna_Pattern_2D(antenna_type,antenna_size,angle_info)
%   %   函数功能：
%   根据天线的形状和尺寸，公式产生其在指定空间方向上的归一化(最大值为1)天线功率方向图
%  
%   输入参数: 
%     antenna_type   ：天线形状，有以下几种情况可选
%         'isotropic'  理想，各个方向均为1
%         'rectangle'   矩形口面
%         'circle'     圆形口面
%    antenna_size    ：天线尺寸，已经对波长归一化的电长度，单位：波长
%    angle_info      ：角度信息，即产生哪些角度的方向图，分以下3种情况
%
%         
%   输出参数：
%   Antenna_norm_G  : 指定角度的天线归一化方向图


%   版权所有：陈柯，电信学院，华中科技大学.
%   $版本号: 1.0 $  $Date: 2016/06/30 $
[row,col] = size(angle_info);
Antenna_G = zeros(row,col);
switch lower(antenna_type)
    case 'rectangle'      % 矩形口面
       lx = pi*antenna_size(1);
       ly = pi*antenna_size(2);            
       theta = real(angle_info);
       phy = imag(angle_info);
       for m = 1:row
           for n =1:col
               xi = sind(theta(m,n))*cosd(phy(m,n));
               eta = sind(theta(m,n))*sind(phy(m,n));
               Antenna_G = abs(sinc(lx*xi)*sinc(ly*eta))^2;
            end
       end
       Antenna_norm_G=Antenna_G/max(max(Antenna_G));
       %矩形天线结束

     case'isotropic'%理想，各个方向均为1
       Antenna_norm_G = ones(row,col);
            %理想天线结束

     case'circle'%圆形口面
       Ba = 2*pi*antenna_size;
       theta = real(angle_info);
       for m = 1:row
           for n =1:col   
                if(sind(theta(m,n))<=1e-5)  %避免分母为0时出错
                    Antenna_G(m,n) = Antenna_G(m-1,n);
                else
                    Antenna_G(m,n) = abs((2* factorial(1)*besselj(1,(Ba*sind(theta(m,n))))/((Ba*sind(theta(m,n)))^(1)))^2);                    
                end
           end
       end
       Antenna_norm_G=Antenna_G/max(max(Antenna_G));
            %圆形天线结束
end



