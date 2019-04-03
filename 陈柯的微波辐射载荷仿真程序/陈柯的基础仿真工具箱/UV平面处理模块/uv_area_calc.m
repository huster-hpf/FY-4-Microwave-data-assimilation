function [uv_area,uv_sample]= uv_area_calc(uvsample)

%   函数功能：计算均匀圆环阵列的每个采样点的面积***********
%             
%  
%   输入参数:
%    uvsample   :     归一化阵列天线位置，单位：波长
%   输出参数：
%    uv_area    :   每个采样点对应的uv网格面积    

%   by 陈柯 2016.09.01  ******************************************************
[uvsample,uv_area] = UVCellforCDFT(ant_pos);
        num_redunt = size(uvsample_redunt);
        V_nonredunt = zeros(1,length(uvsample));
        redundancy = zeros(1,length(uvsample));    
        threshold = 1e-6;    
        for k = 1:1:num_redunt
            u = real(uvsample_redunt(k));
            v = imag(uvsample_redunt(k));
            position = find(abs(real(uvsample)-u)<threshold & abs(imag(uvsample)-v)<threshold);
            redundancy(position) = redundancy(position)+1;
            V_nonredunt(position) = V_nonredunt(position)+V_redunt(k);
        end
        for k = 1:length(uvsample)
            if 0 ~= redundancy(k)
               V_nonredunt(k) = V_nonredunt(k)/redundancy(k);
            end
        end                                  