function [TB_SIR,optimal_iteration] = SIR_deconv(TA,TB,pattern,row_TA_Lat,col_TA_Long,Num_iteration,sample_factor,flag_draw_iteration)
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
row_RE = sample_factor*row; 
col_RE = sample_factor*col;
num_RE = row_RE*col_RE;
pk = zeros(row_RE,col_RE);
gk = zeros(row_RE,col_RE);
h1 = zeros(row_RE,col_RE);							 %第i个测量点的天线增益函数的矩阵
h2 = zeros(row,col);                         %每个像素的关于每个测量点的天线增益函数的矩阵
qk = zeros(row,col);
fk = zeros(row,col);
dk = zeros(row,col);
uk = zeros(row,col);
pk = sum(sum(TA))/(row*col)*ones(sample_factor*row,sample_factor*col);              %用TA的平均值作为起始估计值
RMSE_array = zeros(Num_iteration,1);
for k =1:Num_iteration
    tic;
    for y = 1:row_RE
        for x = 1:col_RE            
            for m = 1:row
                for n = 1:col
                    row_current=row_TA_Lat(m);     col_current=col_TA_Long(n);
                    %获得每个测量点的天线增益函数矩阵
                    h1 = pattern(row_RE+1-row_current+1:2*row_RE+1-row_current,col_RE+1-col_current+1:2*col_RE+1-col_current);  
                    qk(m,n) = sum(sum(h1));
                    fk(m,n) = sum(sum(pk.* h1))/qk(m,n); 
                    dk(m,n) = sqrt(TA(m,n)/fk(m,n));
%                     j_current = (x-1)*row_RE+y;                     
                    if dk(m,n)<1
                        uk(m,n) = 0.5*fk(m,n)*(1-dk(m,n))+pk(y,x)*dk(m,n);
                    else 
                        uk(m,n) = 1/(0.5/fk(m,n)*(1-1/dk(m,n))+1/(pk(y,x)*dk(m,n)));            
                    end
                    h2(m,n) = h1(y,x);                    
                end
            end            
            gk(y,x) = sum(sum(h2));	%h2(:,(n-1)*0.5*row+m)为第j个像素点的天线增益函数矩阵，该矩阵的元素包括从第一个测量点到最后一个测量点的天线增益函数
            pk(y,x) = sum(sum(uk.* h2))/gk(y,x);
        end
    end 
    toc;
    RMSE_array(k) = Root_Mean_Square_Error(pk,TB,0,0);   
end
%计算最优迭代次数
optimal_iteration = find(RMSE_array == min(RMSE_array));                %找出MSE的最小值，即为最优化的R参数
if flag_draw_iteration ==1
      figure;bar(RMSE_array)
end
TB_SIR = pk;