function [TA_SIR,opt_factor] = split_deconv_SIR(TA,TB,Block_num,sample_width_Lat,sample_width_Long,sample_factor,Ba,illumination_taper,angle_Long,angle_Lat,d_Long,d_Lat)
%本函数将亮温TA分割成块分别进行解卷积处理
%输入参数：
%
%TA：观测亮温
%TB: 原始亮温
%Block_num：列与行分块数
%sample_width_Lat：纬度方向采样角
%sample_width_Long：经度方向采样角
%sample_factor：采样系数
%Ba：天线电长度参数
%illumination_taper：照射系数
%
%
        [N_Lat,N_Long] = size(TB);
        [N_TA_Lat,N_TA_Long] = size(TA);
        row_TA_Lat = zeros(1,N_TA_Lat);                                 %天线每次扫描波束指向角对应的输入图像行编号
		col_TA_Long = zeros(1,N_TA_Long);                               %天线每次扫描波束指向角对应的输入图像列编号
        for i = 1:N_TA_Lat  %行编号
			delta_angle=(i-1)*(sample_width_Lat);
			row_TA_Lat(i) = min(round(delta_angle/angle_Lat*N_Lat)+1,N_Lat); 
        end
		for i = 1:N_TA_Long  %列编号
			delta_angle=(i-1)*(sample_width_Long);
			col_TA_Long(i) = min(round(delta_angle/angle_Long*N_Long)+1,N_Long);    
        end

        
        num_TB_row = N_Lat/Block_num;                                                                              %分块的每块网格点数
        num_TB_col = N_Long/Block_num;                                                                             %分块的每块网格点数       
        num_TA_row = N_TA_Lat/Block_num;  
        num_TA_col = N_TA_Long/Block_num;          
        TA_SIR_Block = zeros(num_TB_row,num_TB_col,(Block_num)^2);                                                               %网格储存矩阵

        AP_Coordinate_Long = linspace(-angle_Long/Block_num,(angle_Long-d_Long)/Block_num,2*num_TB_row+1);         %块的方向图对应的坐标    
        AP_Coordinate_Lat = linspace(-angle_Lat/Block_num,(angle_Lat-d_Lat)/Block_num,2*num_TB_col+1);
        Antenna_Pattern_SIR =  Antenna_Pattern_calc(AP_Coordinate_Long,AP_Coordinate_Lat,Ba,illumination_taper);   %与网格尺寸一致的天线方向图       
        
        
        i = 2; j = 2;
        N = 23;                                                                                                      %最大迭代次数
%         [~,N] =  N_cal(TA((i-1)*num_TA_row +1:i*num_TA_row,(j-1)*num_TA_col +1:j*num_TA_col),TB((i-1)*num_TB_row+1:i*num_TB_row,(j-1)*num_TB_col+1:j*num_TB_col),Antenna_Pattern_SIR,row_TA_Lat,col_TA_Long,N,sample_factor);
        for i = 1:Block_num
            for j = 1:Block_num                                                                                       %对每块网格单独进行SIR处理
                    [TA_SIR_Block(:,:,(i-1)*Block_num+j),opt_factor] = SIR_deconv(TA((i-1)*num_TA_row +1:i*num_TA_row,(j-1)*num_TA_col +1:j*num_TA_col),TB((i-1)*num_TB_row+1:i*num_TB_row,(j-1)*num_TB_col+1:j*num_TB_col),Antenna_Pattern_SIR,row_TA_Lat,col_TA_Long,N,sample_factor);
                    x=sprintf('第%d块区域--共%d块区域',(i-1)*Block_num+j,(Block_num)^2);
                    disp(x);
            end
        end
        TA_SIR = zeros(N_Lat,N_Long);
        for i = 1:Block_num
            for j = 1:Block_num                                                                                      %将分块的区域恢复成整体的图像
                TA_SIR((i-1)*num_TB_row+1:i*num_TB_row,(j-1)*num_TB_col+1:j*num_TB_col)=TA_SIR_Block(:,:,(i-1)*Block_num+j);
            end
        end
end

