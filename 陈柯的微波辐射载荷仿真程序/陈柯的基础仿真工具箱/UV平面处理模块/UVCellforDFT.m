function [uvsample,uv_ant_info]= UVCellforDFT(ant_pos)
%   函数功能：计算综合孔径阵列的uv采样点坐标*************************************
%              
%   输入参数:
%    ant_pos  :     归一化阵列天线位置，单位：波长
%                   如果ant_pos为二维矩阵，则代表旋转综合孔径阵列                    
%   
%    
%   输出参数：
%    uv_sample  :  阵列对应的uv平面采样点坐标，复数矩阵，实部u轴，虚部v轴
%                  如果是旋转综孔径阵列，则行数代表单次uv采样点个数，列数代表旋转次数
%    uv_ant_info:  每个uv采样点对应的综合孔径阵列阵元序号
%
%   by 陈柯 2016.06.24  ******************************************************

ant_num = size(ant_pos,2);  %阵列天线个数
index = 1;     
 
for p = 1:ant_num
    for q = 1:ant_num
        uvsample(index,:) = ant_pos(:,p) - ant_pos(:,q);
        uv_ant_info(index,:) = (p+1i*q)*ones(size(ant_pos,1),1);
        index = index+1;
    end
end








