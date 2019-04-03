function [V_nonredunt,uvsample,redundancy,uv_area] = Visibility2D_remove_redunt(V_redunt,uvsample_redunt,array_type,ant_pos)
%   函数功能：去除UV平面冗余采样点，得到冗余平均可见度和冗余参数**********************************% 
%             如果是均匀圆环阵列，还会计算每个uv采样格点的面积
%  
%   输入参数:
%    V_redunt       ：冗余的可见度函数 
%    uvsample_redunt：冗余的uv采样平面坐标
%    array_type     ：阵列类型
%    ant_pos        ：天线位置
%   输出参数：
%    V_nonredunt    : 冗余平均后的可见度函数 
%    uvsample       : 去冗余后的uv采样平面坐标，与V_nonredunt位置对应
%    redundancy_sum : 冗余系数，即每个采样点冗余度的倒数和 
%    uv_area        : 每个uv采样格点的面积，只对均匀圆环阵列有意义
%   by 陈柯 2016.06.24  ******************************************************

uv_area = 0;
redundancy = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%旋转圆环阵列不用去掉冗余基线，去冗余在后面反演过程中实现
if (strcmpi('O_Rotate_shape',array_type))   
        V_nonredunt = V_redunt;
        uvsample = uvsample_redunt;
%%%%%%%%%%%%%%%%%%%%%%%%%圆环阵列去冗余采样点及可见度函冗余平均
else if (strcmpi('O_shape',array_type))     
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
     
%%%%%%%%%%%%%%%%%%%%%%%%%其它均匀网格采样阵列去冗余采样点及可见度函冗余平均        
    else                                     
        uvsample=UV_unique(uvsample_redunt);
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
     end
end





