function  AP = Antenna_Pattern_interp(antenna_pattern_angle,Antenna_Patter,angle)
%   函数功能：利用插值法计算指定角度值的圆形卡塞格伦实孔径天线方向图**********************************
%             返回方向图权值%  
%   输入参数:
%   antenna_pattern_angle        ：与天线主轴的夹角
%   Antenna_Patter               : 圆形卡塞格伦实孔径天线方向图
%   angle                        : 天线方向图的角度坐标
%   输出参数：
%   AP                           : 天线归一化功率方向图                                       
%   by 陈柯 2017.03.20  ******************************************************
AP = interp1(angle,Antenna_Patter,antenna_pattern_angle);%插值得到指定角度的天线方向图
AP(isnan(AP)) = 0;            %将方向图中的NaN值变为零
AP=AP/sum(sum(AP));           %天线方向图归一化