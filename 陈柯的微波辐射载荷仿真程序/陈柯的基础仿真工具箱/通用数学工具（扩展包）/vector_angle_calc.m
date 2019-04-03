function  angle = vector_angle_calc(theta_axis,phi_axis,theta,phi)
%   函数功能：计算球坐标系下一个参考向量与一个向量矩阵之间的夹角**********************************
%            返回夹角矩阵
%  
%   输入参数:
%    theta_axis ：参考向量的天顶角
%    phi_axis   ：参考向量的方位角
%    theta      : 向量矩阵的天顶角
%    phi        : 向量矩阵的方位角
%   输出参数：
%    angle      : 夹角矩阵                                       
%   by 陈柯 2016.09.24  ******************************************************
[num_row,num_col] = size(theta);
angle = zeros(num_row,num_col);
axis = [sind(theta_axis)*cosd(phi_axis);sind(theta_axis)*sind(phi_axis);cosd(theta_axis)];
x = sind(theta).*cosd(phi);
y = sind(theta).*sind(phi);
z = cosd(theta);
for row = 1:num_row
    for col = 1:num_col
        if isnan(theta(row,col))
            angle(row,col) = NaN;
        else
            coordinate = [x(row,col);y(row,col);z(row,col)]; 
            dot_product = dot(axis,coordinate);
            if dot_product>1
               dot_product =1; 
            end
            angle(row,col) = acosd(dot_product);  
        end
    end
end




