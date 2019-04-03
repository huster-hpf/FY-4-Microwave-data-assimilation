function [HPBW,index_3dB,amp_3dB] = HPBW_of_AP(Antenna_Pattern,theta)
%   函数功能：计算一维天线方向图的3dB波束宽度**********************************
%  
%   输入参数:
%    Antenna_Pattern：一维方向图向量          
%    theta          ：方向图对应角度坐标向量
%   输出参数：
%    HPBW           ：3dB波束宽度，单位：角度 
%    index_3dB      ：3dB 束编号；
%    amp_3dB        ：半功率点的幅度
%   by 陈柯 2016.06.24  ****************************************************** 

   Antenna_Pattern_max = max(Antenna_Pattern);
   N = length(theta);
   diff = Antenna_Pattern_max/3;
   theta_3dB_plus = 0;
   theta_3dB_minus = 0;
   index_3dB = 0;
   amp_3dB = 0;
   for k = 1:round(N/2)
       if abs(Antenna_Pattern(k)-0.5*Antenna_Pattern_max) < diff
           diff = abs(Antenna_Pattern(k)-0.5*Antenna_Pattern_max);
           theta_3dB_minus = theta(k);
           index_3dB = k;
           amp_3dB = Antenna_Pattern(k);
       end
   end
   diff = Antenna_Pattern_max/3;
   for k = N:-1:round(N/2)
       if abs(Antenna_Pattern(k)-0.5*Antenna_Pattern_max) < diff
           diff = abs(Antenna_Pattern(k)-0.5*Antenna_Pattern_max);
           theta_3dB_plus = theta(k);
           index_3dB = k;
           amp_3dB = Antenna_Pattern(k);
       end
   end
   HPBW = abs(theta_3dB_plus-theta_3dB_minus);   
