function TB = BG_deconv_real(TA,pattern,NEDT,R)
%   函数功能： 对带有观测噪声的亮温图像TA进行BG解卷积处理，提升图像分辨率和精度****************
%              返回BG法重建后的亮温图像
%  
%   输入参数:
%    TA           ：待重建的输入亮温图像TA
%    pattern      ：天线方向图矩阵
%    T_rec        : 辐射计接收机温度
%    bandwith     : 辐射计带宽
%    integral_time: 辐射计积分时间
%    R            : BG参数
%   输出参数：
%    TB           : BG重建后的亮温图像                                       
%   by 梁若尘 2016.10.19  ******************************************************

[row,col]=size(TA);
TB = zeros(row,col);                                                                                        %初始化BG重建后的亮温矩阵
n = 1;                                                                                                      %BG重建的亮温像素个数
m = (2*n+1)^2;                                                                                              %BG重建用到的相邻像素个数
r = pi/2*R;                                                                                                 %R取值为0-1
w = 0.001; 
Var_noise =NEDT^2 *4;                                                   %图像的噪声
T_var = eye(m)*Var_noise;

% matlabpool open 
parfor row_number = 1+n:row-n
    for col_number = 1+n:col-n        
        u = zeros(m,1);                                                                                     %初始化u矢量
        v = zeros(m,1);                                                                                     %初始化v矢量
        G = zeros(m,m);                                                                                     %初始化G矩阵
        pattern_zeros = zeros(row,col);                     
        Antenna_pattern = zeros(row,col,m);                                                                 %初始化一个三维矩阵存放m个方向图
        Ta = zeros(1,m);                                                                                    %初始化Ta向量，用于存放周围m个TA的值
        %对指向位置生成矩阵pattern_zeros
        for range_row = -n:n
            for range_col = -n:n
                pattern_zeros(row_number+range_row,col_number+range_col) = 1/m;
            end
        end
        for range_row = -n:n
            for range_col = -n:n
                Col_number = col_number+range_col;                                                          %当前位置的列坐标
                Row_number = row_number+range_row;                                                          %当前位置的行坐标
                col_start = col+1-Col_number+1;                                                             %截取方向图的列起始值
                col_end = 2*col+1-Col_number;                                                               %截取方向图的列终止值
                row_start = row+1-Row_number+1;                                                             %截取方向图的行起始值
                row_end = 2*row+1-Row_number;                                                               %截取方向图的行终止值
                Antenna_pattern_t = pattern(row_start:row_end,col_start:col_end);                           %截取方向图
                Antenna_pattern_t = Antenna_pattern_t/sum(sum(Antenna_pattern_t));                          %方向图归一化
                Antenna_pattern(:,:,(range_row+n)*(2*n+1)+range_col+n+1) = Antenna_pattern_t;               %将截取的方向图存入三维矩阵中。用于计算G矩阵
                u((range_row+n)*(2*n+1)+range_col+n+1) = sum(sum(Antenna_pattern_t));                       %计算u矢量
                v((range_row+n)*(2*n+1)+range_col+n+1) = sum(sum(Antenna_pattern_t.*pattern_zeros));        %计算v矢量
                Ta(1,(range_row+n)*(2*n+1)+range_col+n+1) = TA(row_number+range_row,col_number+range_col);  %将周围的亮温依次存入Ta中          
            end
        end
        for i = 1:m
            for j = 1:m
                G(i,j) = sum(sum(Antenna_pattern(:,:,i).*Antenna_pattern(:,:,j)));                          %计算G矩阵       
            end 
        end
        R = G*cos(r)+(T_var)*w*sin(r);                                                      
        q = pinv(R)*(v*cos(r)+(1-u'*pinv(R)*v*cos(r))/(u'*pinv(R)*u)*u);                                    %计算权值矩阵q
        TB(row_number,col_number) = Ta*q;                                                                   %由权值q与周围亮温得到反卷积的亮温TB 
    end
end
% matlabpool close
%BG重建不能处理边缘行列的像素，用原图的值代替
TB(1:n,:) = TA(1:n,:);
TB(row-n+1:row,:) = TA(row-n+1:row,:);
TB(:,1:n) = TA(:,1:n);
TB(:,col-n+1:col) = TA(:,col-n+1:col);


