function TA_noiseless = Antenna_conv(TB,angle_x,angle_y,sample_width_x,sample_width_y,N_x,N_y,Ba,illumination_taper)
%   函数功能：用RMSE实现对两个相同范围的亮温图像的误差比较**********************************
%            如果图像像素点数不一致，则将低分辨率图像插值到高分辨率图像
%  
%   输入参数:
%    TB             : 场景高分辨率亮温图像
%   angle_x         : x轴方向角度范围
%   angle_y         ：y轴方向角度范围
%    Nx             ：TA图像在x轴像素个数
%    Ny             ：TA图像在y轴像素个数
% sample_width_x    : x轴采样间距
% sample_width_y    : y轴采样间距
% Ba                ：天线方向图计算函数
% illumination_taper:  天线方向图照射锥度
%   输出参数：
% TA_noiseless      : 天线扫描输出的观测亮温 
%   by 陈柯 2016.12.22  ******************************************************  

N_TA_Lat = round(angle_x/sample_width_y);                   %纬度方向辐射计天线扫描点数  
N_TA_Long = round(angle_y/sample_width_x);                %经度方向辐射计天线扫描点数  
%计算天线每次扫描波束指向角对应的输入图像行、列编号
row_TA_Lat = zeros(1,N_TA_Lat);                                 %天线每次扫描波束指向角对应的输入图像行编号
col_TA_Long = zeros(1,N_TA_Long);                               %天线每次扫描波束指向角对应的输入图像列编号
for i = 1:N_TA_Lat  %行编号
    delta_angle=(i-1)*(sample_width_y);
    row_TA_Lat(i) = min(round(delta_angle/angle_x*N_y)+1,N_y);    
end
for i = 1:N_TA_Long  %列编号
    delta_angle=(i-1)*(sample_width_x);
    col_TA_Long(i) = min(round(delta_angle/angle_y*N_x)+1,N_x);    
end
%%%%%%%%%%%%%%%%计算模拟观测亮温TA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d_Long = angle_y/(N_x);                  %亮温图像经度方向最小间距，即角度分辨率  
d_Lat = angle_x/(N_y);                     %亮温图像纬度方向最小间距，即角度分辨率 
AP_Coordinate_Long = linspace(-angle_y,angle_y-d_Long,2*N_x);
AP_Coordinate_Lat = linspace(-angle_x,angle_x-d_Lat,2*N_y);
Antenna_Pattern_Full = Antenna_Pattern_calc(AP_Coordinate_Long,AP_Coordinate_Lat,Ba,illumination_taper);
%初始化观测后的输出亮温图像TA
TA_noiseless=zeros(N_TA_Lat,N_TA_Long);  
% matlabpool open ;
parfor sample_num_Lat=1:N_TA_Lat
     for sample_num_Long=1:N_TA_Long
         %利用天线方向图平移与输入亮温进行卷积，计算模拟每个像素的观测亮温TA  
         row_current=row_TA_Lat(sample_num_Lat);
         col_current=col_TA_Long(sample_num_Long);
         Antenna_Pattern_current = Antenna_Pattern_Full(N_y+1-row_current+1:2*N_y+1-row_current,N_x+1-col_current+1:2*N_x+1-col_current) 
         Antenna_Pattern_current = Antenna_Pattern_current/sum(sum(Antenna_Pattern_current));
         TA_noiseless(sample_num_Lat,sample_num_Long)=sum(sum(TB.* Antenna_Pattern_current));        
    end
end
% matlabpool close ;