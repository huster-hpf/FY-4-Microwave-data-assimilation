function [V_ASR_PP,uv_sample_PP,uv_area_rotate,uv_sample_rotate,redundancy] = PPolar_grid_interplation(V_ASR,uv_sample,N,Tb_modify,d_xi,d_eta,uv_to_DFT,uv_to_pi,ant_num,array_type,flag_debug_mode) 
%   函数功能：将同心圆环形状的uv平面采样插值到伪极网格格点的uv平面采样**********************************
%               
%   输入参数:
%    V_ASR          ：同心圆环形状的可见度函数          
%    uv_sample      ：同心圆环形状的uv采样点坐标，要求是对2pi已经归一化了的坐标
%    N              ：伪极网格点数，插值后的伪极网格为2N*2N
%   Tb_modify       ：输入亮温图像的修正亮温
%   uv_to_DFT,      ：uv平面—DFT平面的坐标转换因子
%   uv_to_pi        ：uv平面—2pi归一化频率平面的坐标转换因子
%   d_xi,d_eta      : 图像的二维方向格点尺寸
%   ant_num         ：阵列天线个数         
%   array_type      ：阵列类型，伪极网格插值只支持均匀圆环阵和旋转圆环阵 
%   flag_debug_mode ：调试模式标志位

%   输出参数：
%    V_ASR_PP       : 插值后的伪极网格可见度函数，按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵
%    uv_sample_PP   ：伪极网格采样点uv坐标，按照-pi~pi范围归一化，也是按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵 
%   by 陈柯 2016.06.24  ******************************************************   

if (strcmpi('O_Rotate_shape',array_type))
    if flag_debug_mode == 0
    %旋转圆环阵列的伪极网格插值
       [V_ASR_PP,uv_sample_PP,uv_area_rotate,uv_sample_rotate,redundancy] = PP_interp_for_Rotate(V_ASR,uv_sample,N,uv_to_pi); 
    else
    %旋转圆环阵列的伪极网格插值--调试版本
       [V_ASR_PP,uv_sample_PP,uv_area_rotate,uv_sample_rotate] = PP_interp_for_Rotate_debug(V_ASR,uv_sample,N,Tb_modify,d_xi,d_eta,uv_to_DFT,uv_to_pi);  
    end
else if (strcmpi('O_shape',array_type)) %均匀圆环阵列        
        %计算均匀圆环阵列uv采样平面的半径数与每圈采样点数
        if mod(ant_num,2) == 0   %偶数个天线
           num_radius = ant_num/2; num_theta = ant_num; %根据圆环阵元数计算UV采样点半径个数和每圈采样点数
        else                     %奇数个天线    
           num_radius = (ant_num-1)/2; num_theta = 2*ant_num;
        end
        if flag_debug_mode == 0
        %均匀圆环阵列的伪极网格插值
           [V_ASR_PP,uv_sample_PP] = PP_interp(V_ASR,uv_sample,num_radius,num_theta,N);
        else
        %均匀圆环阵列的伪极网格插值--调试版本
           [V_ASR_PP,uv_sample_PP] = PP_interp_debug(V_ASR,uv_sample,num_radius,num_theta,N,Tb_modify,d_xi,d_eta,uv_to_DFT,uv_to_pi);
        end
    else
        error([array_type,'阵列不能进行伪极网格插值']);        
    end
        
end