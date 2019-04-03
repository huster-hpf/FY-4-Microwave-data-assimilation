function [PP_V,PP_uv] = PP_interp(visibility,uvsample,num_radius,num_theta,N)
%   函数功能：   实现对均匀圆环阵列的圆形uv采样可见度函数插值到伪极网格分布**********************************
%               返回插值后的可见度函数值和伪极网格uv坐标 %               
%  
%   输入参数:
%   visibility      ：均匀圆环阵列可见度
%   uvsample       ： 均匀圆环阵列uv采样点坐标
%   N               : 伪极网格点数，插值后的伪极网格为2N*2N
%   输出参数：
%   PP_V            ：插值后的伪极网格可见度函数，按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵
%   PP_uv           ：伪极网格采样点uv坐标，按照-pi~pi范围归一化，也是按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵                          
%   by 陈柯 2016.06.24  ******************************************************  

% 圆形阵对应的uv平面是以[0 0]为中心的离散同心源

%%%%%%%%%% 角度插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 初始化角度插值后可见度与uv采样平面
PP_theta_interp_visibility = zeros(1,1+N*4*num_radius);
PP_theta_interp_visibility(1) = visibility(1);
PP_theta_interp_uvsample = zeros(1,1+N*4*num_radius);
PP_theta_interp_uvsample(1) = uvsample(1);
% 插值到同一个相位角上
for k = 1:num_radius
    index_old = (k-1)*num_theta+2:k*num_theta+1;
    v_old = visibility(index_old);
    uvsample_old = uvsample(index_old);
    [v_new,uvsample_new]= PP_theta_interp(v_old,uvsample_old,N); 
    index_new = (k-1)*N*4+2:k*N*4+1;                %确定插值后的可见度序号 
    PP_theta_interp_visibility(index_new) = v_new;
    PP_theta_interp_uvsample(index_new) = uvsample_new;    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% 径向插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PP_visibility = zeros(1,4*N*N);     % 初始化插值后可见度
PP_uv_sample = zeros(1,4*N*N);      % 初始化插值后uv采样平面
% 按照半径插值
for k = 1:4*N
    index_old = 1+(0:num_radius-1)*4*N+k;
    v_old = PP_theta_interp_visibility(index_old);
    uvsample_old = PP_theta_interp_uvsample(index_old);
    [v_new,uvsample_new]= PP_radius_interp(v_old,uvsample_old,N,visibility(1));
    index_new = (k-1)*N+1:k*N;  %确定插值后的可见度序号    
    PP_visibility(index_new) = v_new;
    PP_uv_sample(index_new) = uvsample_new;   
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%将可见度函数调整为BV和BH分开排列%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BV = zeros(2*N,N);
BH = zeros(2*N,N);
BV_uv =  zeros(2*N,N);
BH_uv = zeros(2*N,N);

for k = 1:N
     BH(N:-1:1,k) = PP_visibility((k-1)*N+1+2*N*N:k*N+2*N*N);          %垂直极化点，与张成2007年文献上是反过来的，与 Create_Oversampled_Grid 函数算法保持一致
     BH_uv(N:-1:1,k) = PP_uv_sample((k-1)*N+1+2*N*N:k*N+2*N*N);
     BH(N+1:N+N,k) = PP_visibility((k-1)*N+1:k*N);
     BH_uv(N+1:N+N,k) = PP_uv_sample((k-1)*N+1:k*N); 
     BV(N:-1:1,k) =   PP_visibility((k-1)*N+1+3*N*N:k*N+3*N*N);  %水平极化点，与张成2007年文献上是反过来的，与 Create_Oversampled_Grid 函数算法保持一致
     BV_uv(N:-1:1,k) = PP_uv_sample((k-1)*N+1+3*N*N:k*N+3*N*N);
     BV(N+1:N+N,k) = PP_visibility((k-1)*N+1+N*N:k*N+N*N);
     BV_uv(N+1:N+N,k) = PP_uv_sample((k-1)*N+1+N*N:k*N+N*N);      
end

PP_V = [BV,BH];
PP_uv = [BV_uv,BH_uv];

