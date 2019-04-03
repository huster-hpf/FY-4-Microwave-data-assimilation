% 图像解卷积函数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [TB_deconv,Antenna_Gs] = deconvolution(TA,PSF_Long,PSF_Lat,k_Long,k_Lat)
%PSF_Long，PSF_Lat：两维的PSF函数;k_Long,k_Lat:正则化参数；flag_draw_AP：画出反卷积后的PSF的标志位；TA：输入图像
%返回TB_deconv：反卷积处理后的图像，Antenna_Gs：反卷积之后的等效方向图
       num_Latitude = size(PSF_Lat,1);
       col_pix = size(PSF_Long,2);
       row_pix = size(PSF_Lat,2);       
       TB_Long_deconv = zeros(num_Latitude,col_pix);
       TB_deconv = zeros(row_pix,col_pix);       
       inv_PSF_Long = PSF_inversion(PSF_Long,k_Long);
       inv_PSF_Lat = PSF_inversion(PSF_Lat,k_Lat);
       for index_Lat=1:num_Latitude    
           TB_Long_deconv(index_Lat,:) = (inv_PSF_Long*TA(index_Lat,:).').';
       end
       for index_Long=1:col_pix
           TB_deconv(:,index_Long) = (inv_PSF_Lat*TB_Long_deconv(:,index_Long));
       end
       
       A = inv_PSF_Lat*PSF_Lat;   %反卷积之后的等效方向图
       Antenna_Gs = A(round(row_pix/2),:)/max(A(round(row_pix/2),:));
       