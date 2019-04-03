function  AP = Antenna_Pattern_angle_calc(angle,Ba,taper)
%   函数功能：计算指定角度值的圆形卡塞格伦实孔径天线方向图**********************************
%             返回方向图权值%  
%   输入参数:
%   angle        ：与天线主轴的夹角
%   Ba           : 天线电长度参数
%   taper        : 孔径照度；
%   输出参数：
%   AP           : 天线归一化功率方向图                                       
%   by 陈柯 2017.03.20  ******************************************************
[num_row,num_col] = size(angle);
AP = zeros(num_row,num_col);
for x = 1:num_col
    for y = 1: num_row
        if isnan(angle(y,x))  %判断是否角度值是否为NaN
           AP(y,x) = 0; 
        else
           theta = abs(angle(y,x));
        %计算指向对应方位的视场范围内的辐射计天线方向图 
           if(sind(theta)<=1e-6)  %避免分母为0时出错
              AP(y,x) = 1;
           else
              AP(y,x) = abs((2^(taper+1)* factorial(taper+1)*besselj(taper+1,(Ba*sind(abs(theta))))/((Ba*sind(abs(theta)))^(taper+1)))^2);
           end 
        end
     end
end
AP=AP/sum(sum(AP)); %天线方向图归一化