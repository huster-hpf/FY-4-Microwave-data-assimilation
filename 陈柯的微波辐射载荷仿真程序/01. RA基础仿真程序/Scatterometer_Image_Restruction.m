function [TA_SIR,Iteration_optimal] = Scatterometer_Image_Restruction(TA,TB,Block_num,sample_width_Lat,sample_width_Long,sample_factor,Ba,illumination_taper,angle_Long,angle_Lat,d_Long,d_Lat)
%   函数功能： 对带有观测噪声的亮温图像TA进行SIR分辨率增强处理，提升图像分辨率和精度****************
%              返回SIR法重建后的亮温图像
%  
%   输入参数:
%    TA           ：待重建的低分辨率亮温图像TA
%    TB           : 场景高分辨率亮温图像
%Block_num        ：列与行分块数
%sample_width_Lat ：纬度方向采样角
%sample_width_Long：经度方向采样角
%sample_factor    ：采样系数
% angle_Long      : Long轴方向角度范围
% angle_Lat       ：Lat轴方向角度范围
% Nx              ：TA图像在x轴像素个数
% Ny              ：TA图像在y轴像素个数
% Ba              ：天线方向图计算函数
% illumination_taper :  天线方向图照射锥度
% d_Long,d_Lat    ：Long,Lat方向的扫描间隔

%   输出参数：
%    TA_SIR       : SIR分辨率增强后的亮温图像 
%    opt_factor   : 实现SIR最佳效果时的迭代次数
%   by 陈柯 2017.06.16  ******************************************************

%计算天线每次扫描波束指向角对应的输入图像行、列编号
 [N_Lat,N_Long] = size(TB);
 [N_TA_Lat,N_TA_Long] = size(TA);
 row_TA_Lat = zeros(1,N_TA_Lat);                                 %天线每次扫描波束指向角对应的输入图像行编号
 col_TA_Long = zeros(1,N_TA_Long);                               %天线每次扫描波束指向角对应的输入图像列编号
 for m = 1:N_TA_Lat  %行编号
    delta_angle=(m-1)*(sample_width_Lat);
	row_TA_Lat(m) = min(round(delta_angle/angle_Lat*N_Lat)+1,N_Lat); 
 end
 for m = 1:N_TA_Long  %列编号
	delta_angle=(m-1)*(sample_width_Long);
	col_TA_Long(m) = min(round(delta_angle/angle_Long*N_Long)+1,N_Long);    
 end
%  对图像进行分块处理
    num_TB_row = N_Lat/Block_num;  num_TB_col = N_Long/Block_num;                   %TB分块的每块网格点数 
    num_TA_row = N_TA_Lat/Block_num; num_TA_col = N_TA_Long/Block_num;              %TA分块的每块网格点数                                                                 
%     TA_SIR_Block = zeros(num_TB_row,num_TB_col,(Block_num)^2);                      %网格储存矩阵

%  计算天线方向图
    AP_Coordinate_Long = linspace(-angle_Long/Block_num,(angle_Long-d_Long)/Block_num,2*num_TB_row+1);         %块的方向图对应的坐标    
    AP_Coordinate_Lat = linspace(-angle_Lat/Block_num,(angle_Lat-d_Lat)/Block_num,2*num_TB_col+1);
    Antenna_Pattern_SIR =  Antenna_Pattern_calc(AP_Coordinate_Long,AP_Coordinate_Lat,Ba,illumination_taper);   %与网格尺寸一致的天线方向图  
    
%  计算最优化的迭代次数  
   m = 1; n = 1;
   Iteration_initial = 30;                                                                                                      %最大迭代次数
   TA_Block = TA((m-1)*num_TA_row+1:m*num_TA_row,(n-1)*num_TA_col+1:n*num_TA_col);
   TB_Block = TB((m-1)*num_TB_row+1:m*num_TB_row,(n-1)*num_TB_col+1:n*num_TB_col);   
  [~,Iteration_optimal] =  SIR_deconv(TA_Block,TB_Block,Antenna_Pattern_SIR,row_TA_Lat,col_TA_Long,Iteration_initial,sample_factor,1);
  
%  对每块网格单独进行SIR处理
   TA_SIR = zeros(N_Lat,N_Long);
%    Iteration_optimal = Iteration_optimal;
  for m = 1:Block_num
      for n = 1:Block_num                                                                                      
         TA_Block = TA((m-1)*num_TA_row+1:m*num_TA_row,(n-1)*num_TA_col+1:n*num_TA_col);
         TB_Block = TB((m-1)*num_TB_row+1:m*num_TB_row,(n-1)*num_TB_col+1:n*num_TB_col);  
         TA_SIR_Block = SIR(TA_Block,TB_Block,Antenna_Pattern_SIR,row_TA_Lat,col_TA_Long,Iteration_optimal,sample_factor,0);
         TA_SIR((m-1)*num_TB_row+1:m*num_TB_row,(n-1)*num_TB_col+1:n*num_TB_col)=TA_SIR_Block;
         x=sprintf('第%d块区域--共%d块区域',(m-1)*Block_num+n,(Block_num)^2);  disp(x);
      end
   end     
end

