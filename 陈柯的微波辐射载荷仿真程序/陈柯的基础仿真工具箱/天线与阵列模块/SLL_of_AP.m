  function [SLL,mark_SLL,Null_BW] = SLL_of_AP(Antenna_Pattern_dB,theta)
%   函数功能：计算一维天线方向图的第一副瓣电平**********************************
%  
%   输入参数:
%    Antenna_Pattern_dB：一维方向图向量          
%    theta          ：方向图对应角度坐标向量
%   输出参数：
%    SSL            ：第一副瓣电平，单位：dB 
%    mark_SSL       ：位置序号；
%   by 陈柯 2016.09.02  ****************************************************** 

   Antenna_Pattern_max = max(Antenna_Pattern_dB);
   N = length(theta);
   index_max = find(Antenna_Pattern_dB == Antenna_Pattern_max);
   for k = index_max:N-1
       if (Antenna_Pattern_dB(k+1)-Antenna_Pattern_dB(k)) > 0;
           Null_BW = theta(k);
           mark_Null = k;
           break;
       end       
   end
   SLL = max(Antenna_Pattern_dB(mark_Null:N));
   mark_SLL = find(Antenna_Pattern_dB == SLL);
   mark_SLL = mark_SLL(1);
   
%    for k = mark_Null:N-1
%        if (Antenna_Pattern_dB(k+1)-Antenna_Pattern_dB(k)) < 0;
%            SSL =Antenna_Pattern_dB(k);
%            mark_SSL = k;
%            break;
%        end       
%    end
  
   
     
