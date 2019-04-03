function [uv_sample,uv_area]= UVCellforCDFT(ant_pos)

%   函数功能：按照圆周顺序计算均匀圆环阵列的uv采样点坐标和每个采样点的面积***********
%             均匀圆环阵列的uv采样分布是以[0 0]为中心的离散同心圆
%  
%   输入参数:
%    ant_pos  :     归一化阵列天线位置，单位：波长
%   输出参数：
%    uv_sample  :   均匀圆环阵列对应的uv平面采样点坐标，一维复数数值，实部u轴，虚部v轴，第一个元素为原点，然后按照圆周半径升序顺序存储
%    uv_area    :   每个采样点对应的uv网格面积    

%   by 陈柯 2016.06.24  ******************************************************
ant_num = size(ant_pos,2);  %阵列天线个数
if mod(ant_num,2) == 0   %偶数个天线
       num_radius = ant_num/2; num_theta = ant_num; %根据圆环阵元数计算UV采样点半径个数和每圈采样点数
else                     %奇数个天线    
       num_radius = (ant_num-1)/2; num_theta = 2*ant_num;
end
radius_index = 2:(num_radius+1) ;                        %计算半径的天线编号
radius = abs(ant_pos(radius_index)-ant_pos(1));          %同心圆每个半径长度
start_angle = angle(ant_pos(radius_index)-ant_pos(1));   %同心圆每圈起始位置

% 初始化uv_sample 和 uvarea 
uv_sample = 0;                                           %采样中心[0 0]点
uv_area = pi*(radius(1)/2)^2;                            %采样中心[0 0]点对应的网格面积
step_angle = (0:num_theta-1)*2*pi/num_theta;             %每一圈上的角度间距

%按照同心圆顺序计算每个圆上的uv采样点坐标并按照角度排序
for k = 1:num_radius
    current_radius = radius(k);                          %当前同心圆的半径              
    current_start_angle = start_angle(k);                %当前同心圆起始角
    %对每一圈UV采样点按照角度排序，从（-pi）--pi逆时针排序
    current_angle = wrapToPi(current_start_angle+step_angle);
    sorted_angle =  sort(current_angle,2,'ascend');     
    current_uv = current_radius*exp(1i*sorted_angle);    %当前同心圆uv坐标
    %计算每个uv采样点对应的网格面积
    if k == 1
       area = (pi*((radius(k+1) + radius(k))/2)^2 - pi*(radius(k)/2)^2)/num_theta;                   %计算第一圈同心圆格点面积
    elseif k == num_radius
       area = (pi*((3*radius(k) - radius(k-1))/2)^2 - pi*((radius(k) + radius(k-1))/2)^2)/num_theta; %计算最后一圈同心圆格点面积
    else
       area = (pi*((radius(k+1) + radius(k))/2)^2 - pi*((radius(k) + radius(k-1))/2)^2)/num_theta;   %计算中间圈同心圆格点面积
    end
    current_uvarea = area*ones(1,num_theta);
    %将每一圈的uv坐标和网格面积存到uv_sample 和 uvarea中
    uv_sample = [uv_sample current_uv];    
    uv_area =  [uv_area current_uvarea];   
end

