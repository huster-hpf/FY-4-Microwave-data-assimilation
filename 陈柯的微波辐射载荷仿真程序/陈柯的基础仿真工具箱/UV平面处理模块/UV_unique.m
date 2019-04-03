function [uv_nonredunt]=UV_unique(uv_redunt)
%   函数功能：将包含冗余的一维数组中冗余值去掉，得到非冗余值*************************************
%             数组可以为实数或复数，通过放大因子，可以控制冗余值的精度 
%   输入参数:
%    array_redunt  :    包含冗余值的一维数组,可以为复数
%
%   输出参数：
%    array_nonredunt  : 去除掉冗余值之后的一维数组
%
%   by 陈柯 2016.06.24  ******************************************************
factor_gain = 1e5;
input_data(:,1)=real(uv_redunt);
input_data(:,2)=imag(uv_redunt);
gain_data=round(input_data*factor_gain);
[~,N_index]=unique(gain_data,'rows');
uv_nonredunt=input_data(N_index,:);
uv_nonredunt=uv_nonredunt(:,1)+1i*uv_nonredunt(:,2);
uv_nonredunt=uv_nonredunt.';
end

