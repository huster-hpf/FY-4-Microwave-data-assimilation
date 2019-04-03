function TA_SIR = split_deconv_SIR3(sample_factor,N,TA,Block_num,N_TA_Lat,N_TA_Long,Antenna_Pattern_SIR,row_TA_Lat,col_TA_Long,TA_real_SIR1)
%本函数将亮温TA分割成块分别进行解卷积处理
%输入参数：
%TA：观测亮温
%Block_num：列与行分块数
%N_TA_Lat：亮温TA行数目
%N_TA_Long：亮温TA行数目
        num = N_TA_Lat/Block_num;                                                                                         %分块的每块网格点数
        TA_SIR_Block = zeros(num,num,(N_TA_Lat/num)^2);                                                                   %网格储存矩阵
        for i = 1:N_TA_Lat/num
            for j = 1:N_TA_Long/num                                                                                       %对每块网格单独进行SIR处理
                    TA_SIR_Block(:,:,(i-1)*N_TA_Lat/num+j) = SIR_deconv3(sample_factor,N,TA((i-1)*num/sample_factor+1:i*num/sample_factor,(j-1)*num/sample_factor+1:j*num/sample_factor),Antenna_Pattern_SIR,row_TA_Lat,col_TA_Long,TA_real_SIR1((i-1)*num+1:i*num,(j-1)*num+1:j*num));
                    x=sprintf('第%d块区域--共%d块区域',(i-1)*N_TA_Lat/num+j,(N_TA_Lat/num)^2);
                    disp(x);
            end
        end
        TA_SIR = zeros(N_TA_Lat,N_TA_Long);
        for i = 1:N_TA_Lat/num
            for j = 1:N_TA_Long/num                                                                                        %将分块的区域恢复成整体的图像
                TA_SIR((i-1)*num+1:i*num,(j-1)*num+1:j*num)=TA_SIR_Block(:,:,(i-1)*300/num+j);
            end
        end
end
