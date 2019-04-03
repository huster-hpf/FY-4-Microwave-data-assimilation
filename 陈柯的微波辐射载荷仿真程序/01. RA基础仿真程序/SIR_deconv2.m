function [TB_SIR,optimal_iteration] = SIR_deconv2(TA,TB,pattern,row_TA_Lat,col_TA_Long,Num_iteration,sample_factor,flag_draw_iteration)
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
row_RE = sample_factor*row; col_RE = sample_factor*col;
num_TA = row*col; num_RE = row_RE*col_RE;
TA_1D = reshape(TA,num_TA,1);
gk = zeros(num_RE,1);
% h1 = zeros(num_RE,1);							 %第i个测量点的天线增益函数的矩阵
h2 = zeros(num_TA,1);                            %每个像素的关于每个测量点的天线增益函数的矩阵
qk = zeros(num_TA,1);
fk = zeros(num_TA,1);
dk = zeros(num_TA,1);
uk = zeros(num_TA,1);
pk = sum(TA_1D)/(num_TA)*ones(num_RE,1);              %用TA的平均值作为起始估计值
RMSE_array = zeros(Num_iteration,1);
for k =1:Num_iteration    
    for j = 1:num_RE
        for i = 1:num_TA 
            if mod(i,row) == 0
               m = row; n = i/row;
            else
               m = mod(i,row);  n = floor(i/row)+1;
            end 
            row_current=row_TA_Lat(m);     col_current=col_TA_Long(n);
            %获得每个测量点的天线增益函数矩阵
            h1 = shape(pattern(row_RE+1-row_current+1:2*row_RE+1-row_current,col_RE+1-col_current+1:2*col_RE+1-col_current),num_RE,1);
            qk(i) = sum(h1);
            fk(i) = sum(pk.* h1)/qk(i); 
            dk(i) = sqrt(TA_1D(i)/fk(i));
%           j_current = (x-1)*row_RE+y;                     
            if dk(i)<1
               uk(i) = 0.5*fk(i)*(1-dk(i))+pk(j)*dk(i);
            else 
               uk(i) = 1/(0.5/fk(i)*(1-1/dk(i))+1/(pk(j)*dk(i)));            
            end
            h2(i) = h1(j);                
         end
         gk(j) = sum(h2);	%h2(:,(n-1)*0.5*row+m)为第j个像素点的天线增益函数矩阵，该矩阵的元素包括从第一个测量点到最后一个测量点的天线增益函数
         pk(j) = sum(uk.* h2)/gk(j);       
    end
    TA_RE = reshape(pk,row_RE,col_RE);
    RMSE_array(k) = Root_Mean_Square_Error(TA_RE,TB,0,0);   
end
%计算最优迭代次数
optimal_iteration = find(RMSE_array == min(RMSE_array));                %找出MSE的最小值，即为最优化的R参数
if flag_draw_iteration ==1
      figure;bar(RMSE_array)
end
TB_SIR = TA_RE;