function [uv_sample,Num_U,Num_V] = UV_coorinadate_calc (P,Q,delta_u,delta_v,N_xi,N_eta)
%   函数功能：计算标准矩形网格uv平面采样点坐标，与matlab FFT函数坐标保持一致******
%             根据图像像素点奇偶区分，为了和DFT保持一致。   
%  
%   输入参数:
%    P              ：u轴方向最大基线，单位：波长         
%    Q              ：v轴方向最大基线，单位：波长
%    delta_u        ：u轴方向最小间距，单位：波长
%    delta_v        ：v轴方向最小间距，单位：波长
%    N_xi           ：输入亮温图像在ξ方向像素点数
%    N_eta          ：输入亮温图像在η方向像素点数

%   输出参数：
%    uv_sample      : 标准矩形网格uv平面采样点坐标，单位：波长
%    Num_U          ：u轴方向采样点个数
%    Num_V          ：v轴方向采样点个数
%   by 陈柯  2016.06.24  ******************************************************
  
    if mod(N_xi,2)==0
        u_index = -P:1:P-1;Num_U = 2*P;
    else
        u_index = -P:1:P;Num_U = 2*P+1;
    end
    if mod(N_eta,2)==0
        v_index = -Q:1:Q-1;Num_V = 2*Q;
    else
        v_index = -Q:1:Q;Num_V = 2*Q+1;
    end
    
    [u_coordinate,v_coordinate] = meshgrid(u_index*delta_u,v_index*delta_v);  
    uv_sample = u_coordinate+1i*v_coordinate;
    