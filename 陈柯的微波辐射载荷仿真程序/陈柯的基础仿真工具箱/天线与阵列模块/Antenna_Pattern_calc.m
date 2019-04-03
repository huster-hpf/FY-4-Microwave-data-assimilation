function  AP = Antenna_Pattern_calc(Coordinate_x,Coordinate_y,Ba,taper)
%   函数功能：根据二维坐标画出圆形卡塞格伦实孔径天线方向图**********************************
%            返回3dB波束宽度、零点波束宽度、波束效率、第一旁瓣电平等天线图参数
%  
%   输入参数:
%    Coordinate_x ：x轴方向坐标，单位：角度
%    Coordinate_y ：y轴方向坐标，单位：角度
%    Ba           :天线电长度参数
%    taper        :孔径照度；
%   输出参数：
%    AP           : 天线归一化功率方向图                                       
%   by 陈柯 2016.09.24  ******************************************************


num_row = length(Coordinate_y);
num_col = length(Coordinate_x);
AP = zeros(num_row,num_col);
parfor x = 1:num_col
    for y = 1: num_row
            %点的位置
            pix_point = Coordinate_x(x)+1i*Coordinate_y(y);
            if (abs(pix_point/90)<=1)
                theta = abs(pix_point);
                %计算指向对应方位的视场范围内的辐射计天线方向图 
               if(sind(theta)<=1e-6)  %避免分母为0时出错
                   AP(y,x) = 1;
               else
                   AP(y,x) = abs((2^(taper+1)* factorial(taper+1)*besselj(taper+1,(Ba*sind(abs(theta))))/((Ba*sind(abs(theta)))^(taper+1)))^2);
               end
            end
     end
end
AP=AP/sum(sum(AP));      %天线方向图归一化