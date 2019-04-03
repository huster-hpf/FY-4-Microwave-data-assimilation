function [TA_RE,min_R,TA_PDF_RE] = Backus_Gilbert_deconv(TA,TB,angle_x,angle_y,Ba,illumination_taper,NEDT,num_R,max_R,RMSE_offset,flag_PDF_calc,TA_PDF)
%   函数功能： 对带有观测噪声的亮温图像TA进行BG解卷积处理，提升图像分辨率和精度****************
%              返回BG法重建后的亮温图像
%  
%   输入参数:
%    TA           ：待重建的低分辨率亮温图像TA
%    TB           : 场景高分辨率亮温图像
% angle_x         :x轴方向角度范围
% angle_y         ：y轴方向角度范围
% Nx              ：TA图像在x轴像素个数
% Ny              ：TA图像在y轴像素个数
% Ba              ：天线方向图计算函数
% illumination_taper :  天线方向图照射锥度
% NEDT            : 辐射计接收机灵敏度
% num_R           :  %r值测试点数
% RMSE_offset     ： %观测图像与原始图像对比时图像边缘去掉的行或列数

%   输出参数：
%    TA_RE        : BG分辨率增强后的亮温图像 
%    min_R        : 实现BG最佳效果时的R值
%   by 陈柯 2016.12.22  ******************************************************

  %r值试探点数 
[Ny,Nx] = size(TA);  
d_x = angle_x/(Nx);
d_y = angle_y/(Ny);
BG_Coordinate_Long = linspace(-angle_x,angle_x-d_x,2*Nx);
BG_Coordinate_Lat = linspace(-angle_y,angle_y-d_y,2*Ny);
Antenna_Pattern_BG = Antenna_Pattern_calc(BG_Coordinate_Long,BG_Coordinate_Lat,Ba,illumination_taper);
RMSE_array = zeros(1,num_R);                                           
TA_RE_array = zeros(Ny,Nx,num_R);
R = linspace(max_R/num_R,max_R,num_R);
for i = 1:num_R                                                     %对N_r个r值进行试探
    TA_RE = BG_deconv_real(TA,Antenna_Pattern_BG,NEDT,R(i));
    [RMSE_array(i),~] = Mean_Square_Error(TB,TA_RE,RMSE_offset,0);
    TA_RE_array(:,:,i) = TA_RE;                                %将每一个r值的图像储存
end
index_min = find(RMSE_array == min(RMSE_array));                %找出MSE的最小值，即为最优化的R参数
TA_RE = TA_RE_array(:,:,index_min);                             %取出MSE最小的图像
min_R = R(index_min);
%显示不同R参数时候观测RMSE的变化曲线
% figure;stem(R,RMSE_array,'fill','r-.');xlabel('R'); ylabel('MSE');title('不同R值下的BG反卷积图像的MSE'); 
%这是只取某一参数R时的BG反演
% TA_real_BG = BG_deconv_real(TA_real,Antenna_Pattern_BG,T_rec,bandwith,integral_time,0.3);
if flag_PDF_calc == 1
   TA_PDF_RE = BG_deconv_real(TA_PDF,Antenna_Pattern_BG,NEDT,min_R);
end
%计算无噪声TA的BG重建图像
% TA_BG = BG_deconv(TA,Antenna_Pattern_BG);
