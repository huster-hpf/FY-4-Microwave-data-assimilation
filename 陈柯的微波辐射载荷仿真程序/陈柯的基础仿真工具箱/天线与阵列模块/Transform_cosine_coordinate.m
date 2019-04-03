function angle_info = Transform_cosine_coordinate(xi,eta)
%   函数功能：空间坐标转换，将一个二维空间方位余弦坐标转换到角度坐标**********
%            
%  
%   输入参数:
%    xi             ：二维空间的每个像素的ξ坐标矩阵         
%    eta            ：二维空间的每个像素的η坐标矩阵
%   输出参数：
%    angle_info     : 转换后的二维空间每个像素的方位角φ和天底角θ ，以复数形式输出，θ+iφ                                     
%   by 陈柯 2016.06.24  ******************************************************  
[row,col] = size(xi);
angle_info = zeros(row,col);
theta = zeros(row,col);
phy = zeros(row,col);
for m=1:1:row
    for n=1:1:col
        theta(m,n)=asind(sqrt(xi(m,n)^2+eta(m,n)^2));
        phy(m,n) = angle(xi(m,n)+1i*eta(m,n))*180/pi;
        angle_info(m,n) = theta(m,n)+1i*phy(m,n);
    end
end