function [TB_SIR,k] = SIR_deconv(TA,TB,pattern,row_TA_Lat,col_TA_Long,N,sample_factor)
%   函数功能： 对没有观测噪声的亮温图像TA进行SIR解卷积处理，提升图像分辨率和精度****************
%              返回SIR法重建后的亮温图像
%  
%   输入参数:
%    TA           ：待重建的输入亮温图像TA
%    pattern      ：天线方向图矩阵
%   输出参数：
%    TB           : SIR重建后的亮温图像（在这里若TA图像大小为N*N，则重建图像的大小为0.5N*0.5N）  
%   N:迭代次数
%   by 张勇 2017.3.31  ******************************************************
%[row,col]=size(TA);
[row,col]=size(TA);
RMSE = zeros(N,1);
pk = zeros(sample_factor*row,sample_factor*col);
gk = zeros(sample_factor*row,sample_factor*col);
h1 = zeros(sample_factor*row,sample_factor*col);									%第i个测量点的天线增益函数的矩阵
h2 = zeros(row*col,(sample_factor^2)*col*row);                               %每个像素的关于每个测量点的天线增益函数的矩阵
qk = zeros(row,col);
fk = zeros(row,col);
dk = zeros(row,col);
uk = zeros(row*col,(sample_factor^2)*col*row);
pk = sum(sum(TA))/(row*col)*ones(sample_factor*row,sample_factor*col);              %用TA的平均值作为起始估计值
% for i=1:row
%     for j=1:col
%         pk(2*i-1,2*j-1)=TA(i,j);
%         pk(2*i-1,2*j)=TA(i,j);
%         pk(2*i,2*j-1)=TA(i,j);
%         pk(2*i,2*j)=TA(i,j);
%     end
% end
for k =1:N
    for i=1:row
            for j=1:col
                row_current=row_TA_Lat(i);
                col_current=col_TA_Long(j);
                h1 = pattern(sample_factor*row+1-row_current+1:2*sample_factor*row+1-row_current,sample_factor*col+1-col_current+1:2*sample_factor*col+1-col_current);  %获得每个测量点的天线增益函数矩阵
                qk(i,j) = sum(sum(h1));
                fk(i,j) = sum(sum(pk.* h1))/qk(i,j); 
                dk(i,j) = sqrt(TA(i,j)/fk(i,j));
                for TB_num=1:(sample_factor^2)*col*row    
                    if dk(i,j)<1
                        uk((j-1)*row+i,TB_num) = 0.5*fk(i,j)*(1-dk(i,j))+pk(TB_num)*dk(i,j);
                     else 
                        uk((j-1)*row+i,TB_num) = 1/(0.5/fk(i,j)*(1-1/dk(i,j))+1/(pk(TB_num)*dk(i,j)));            
                    end
                    h2((j-1)*row+i,TB_num) = h1(TB_num);
                end
            end
        end

        for m=1:sample_factor*row
            for n=1:sample_factor*col      
                gk(m,n) = sum(h2(:,(n-1)*sample_factor*row+m));		%h2(:,(n-1)*0.5*row+m)为第j个像素点的天线增益函数矩阵，该矩阵的元素包括从第一个测量点到最后一个测量点的天线增益函数
                pk(m,n) = sum(h2(:,(n-1)*sample_factor*row+m).*uk(:,(n-1)*sample_factor*row+m))/gk(m,n);
            end
        end
        
%         [RMSE(k),~] = Root_Mean_Square_Error(pk,TB,0,0);
%         if k>1 && RMSE(k)>RMSE(k-1)
%             break
%         end
%         k = k+1;
    % 	x=sprintf('第%d次迭代',k);
    %   disp(x);
end
TB_SIR = pk;