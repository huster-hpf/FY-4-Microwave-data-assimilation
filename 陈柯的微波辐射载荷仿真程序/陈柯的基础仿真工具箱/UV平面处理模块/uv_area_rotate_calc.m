function [uv_area,uv_sample]= uv_area_rotate_calc(uvsample)

%   函数功能：计算旋转圆环阵列的每个采样点的面积***********
%             
%  
%   输入参数:
%    uvsample   :     归一化阵列天线位置，单位：波长
%   输出参数：
%    uv_area    :   每个采样点对应的uv网格面积    

%   by 陈柯 2016.09.01  ******************************************************
[num_radius,num_theta] = size(uvsample);

radius = abs(uvsample(:,1));                             %同心圆每个半径长度
theta = angle(uvsample(2,:));

theta_area = zeros(1,num_theta);
theta_area(1) =  (wrapToPi(abs(theta(1)-theta(num_theta)))+wrapToPi(abs(theta(2)-theta(1))))/2/(2*pi);
theta_area(num_theta) =  (wrapToPi(abs(theta(num_theta)-theta(num_theta-1)))+wrapToPi(abs(theta(1)-theta(num_theta))))/2/(2*pi);
for n = 2:(num_theta-1)
    theta_area(n) = (wrapToPi(abs(theta(n)-theta(n-1)))+wrapToPi(abs(theta(n+1)-theta(n))))/2/(2*pi);
end


% 初始化uv_sample 和 uvarea 
uv_sample = 0;                                           %采样中心[0 0]点
uv_area = pi*(radius(2)/2)^2;                            %采样中心[0 0]点对应的网格面积

%按照同心圆顺序计算每个圆上的uv采样点坐标并按照角度排序
for k = 2:num_radius
    %计算每个uv采样点对应的网格面积
    if k == 2
       area = (pi*((radius(k+1) + radius(k))/2)^2 - pi*(radius(k)/2)^2).*theta_area;                   %计算第一圈同心圆格点面积
    elseif k == num_radius
       area = (pi*((3*radius(k) - radius(k-1))/2)^2 - pi*((radius(k) + radius(k-1))/2)^2).*theta_area; %计算最后一圈同心圆格点面积
    else
       area = (pi*((radius(k+1) + radius(k))/2)^2 - pi*((radius(k) + radius(k-1))/2)^2).*theta_area;   %计算中间圈同心圆格点面积
    end
    %将每一圈的uv坐标和网格面积存到uv_sample 和 uv_area中
    uv_sample = [uv_sample uvsample(k,:)];    
    uv_area =  [uv_area area];   
end

