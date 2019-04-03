function [TB_SIR,optimal_iteration] = SIR(TA,TB,pattern,row_TA_Lat,col_TA_Long,Num_iteration,sample_factor,flag_draw_iteration)
%   函数功能： 对没有观测噪声的亮温图像TA进行SIR解卷积处理，提升图像分辨率和精度****************
%              返回SIR法重建后的亮温图像
%  
%   输入参数:
%    TA           ：待重建的输入亮温图像TA
%    pattern      ：天线方向图矩阵
%   输出参数：
%    TB           : SIR重建后的亮温图像（在这里若TA图像大小为N*N，则重建图像的大小为0.5N*0.5N）  
%   N:迭代次数
%   by 陈柯 2017.3.31  ******************************************************
[row,col]=size(TA);
pk = zeros(sample_factor*row,sample_factor*col);
gk = zeros(sample_factor*row,sample_factor*col);
h1 = zeros(sample_factor*row,sample_factor*col);							 %第i个测量点的天线增益函数的矩阵
h2 = zeros(row*col,(sample_factor^2)*col*row);                               %每个像素的关于每个测量点的天线增益函数的矩阵
qk = zeros(row,col);
fk = zeros(row,col);
dk = zeros(row,col);
uk = zeros(row*col,(sample_factor^2)*col*row);
pk = sum(sum(TA))/(row*col)*ones(sample_factor*row,sample_factor*col);              %用TA的平均值作为起始估计值
RMSE_array = zeros(Num_iteration,1);
for k =1:Num_iteration
    for m=1:row
        for n=1:col
            row_current=row_TA_Lat(m);     col_current=col_TA_Long(n);
            %获得每个测量点的天线增益函数矩阵
            h1 = pattern(sample_factor*row+1-row_current+1:2*sample_factor*row+1-row_current,sample_factor*col+1-col_current+1:2*sample_factor*col+1-col_current);  
            qk(m,n) = sum(sum(h1));
            fk(m,n) = sum(sum(pk.* h1))/qk(m,n); 
            dk(m,n) = sqrt(TA(m,n)/fk(m,n));
            for TB_num=1:(sample_factor^2)*col*row    
                if dk(m,n)<1
                   uk((n-1)*row+m,TB_num) = 0.5*fk(m,n)*(1-dk(m,n))+pk(TB_num)*dk(m,n);
                else 
                   uk((n-1)*row+m,TB_num) = 1/(0.5/fk(m,n)*(1-1/dk(m,n))+1/(pk(TB_num)*dk(m,n)));            
                end
                h2((n-1)*row+m,TB_num) = h1(TB_num);
            end
        end
    end

    for m=1:sample_factor*row
        for n=1:sample_factor*col      
            gk(m,n) = sum(h2(:,(n-1)*sample_factor*row+m));	%h2(:,(n-1)*0.5*row+m)为第j个像素点的天线增益函数矩阵，该矩阵的元素包括从第一个测量点到最后一个测量点的天线增益函数
            pk(m,n) = sum(h2(:,(n-1)*sample_factor*row+m).*uk(:,(n-1)*sample_factor*row+m))/gk(m,n);
        end
     end
        
   RMSE_array(k) = Root_Mean_Square_Error(pk,TB,0,0);   
end
%计算最优迭代次数
optimal_iteration = find(RMSE_array == min(RMSE_array));                %找出MSE的最小值，即为最优化的R参数
if flag_draw_iteration ==1
      figure;bar(RMSE_array)
end
TB_SIR = pk;