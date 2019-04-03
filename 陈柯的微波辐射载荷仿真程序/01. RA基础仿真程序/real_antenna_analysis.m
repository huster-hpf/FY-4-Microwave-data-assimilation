%%%%%%%%%%%本程序对圆形口径的实孔径天线进行仿真分析，可以计算绘制不同孔径照度下的天线主波束效率%%%%%%%%%%%%%%
tic;
clear;
close all;

freq = 50.3e9;                       %系统中心频率，单位:Hz
c=3e8;                               %光速
wavelength=c/freq; 
antenna_diameter=3.7;                %辐射计载荷天线直径（参考GEM，采用2米）
Ba = pi*antenna_diameter/wavelength;  %%%计算什么东西？？？
num_taper=5;                         %天线amplitued taper

num_Full = 18000;
d_angle=180/num_Full;                %unit degree
theta_all=d_angle:d_angle:90-d_angle;%分母角度范围
theta_max = asind(10/Ba); 
theta=d_angle:d_angle:theta_max;     %分子角度范围
theta_ant_max = 180/Ba*10;
theta_ant = -theta_ant_max:d_angle:theta_ant_max;

num_theta = length(theta_all);
num_beam_efficiency = length(theta);
beam_efficiency=zeros(num_taper,num_beam_efficiency);
coordinate=zeros(1,num_beam_efficiency);
Antenna_pattern=zeros(1,length(theta_ant));
denominator = 0;
numerator = 0;
mark_Null = zeros(1,num_taper);
mark_3dB = zeros(1,num_taper);

for q=0:1:num_taper-1
    %计算分母  
    for n=1:num_theta
        u=Ba*sind(theta_all(n));
        du=Ba*cosd(theta_all(n))*d_angle*pi/180;
        denominator=denominator+(besselj(q+1,u))^2/u^(2*q+1)/sqrt(1-(sind(theta_all(n)))^2)*du;
    end
%计算分子
    for m=1:num_beam_efficiency
        for n=1:m
            u=Ba*sind(theta(n));
            du=Ba*cosd(theta(n))*d_angle*pi/180;
            numerator=numerator+(besselj(q+1,u))^2/u^(2*q+1)/sqrt(1-(sind(theta(n)))^2)*du;
        end
        beam_efficiency(q+1,m)=numerator/denominator;
        numerator=0;
        coordinate(m)=Ba*sind(theta(m));
    end

    %calculating antenna pattern
    for n=1:length(theta_ant)
        if(sind(abs(theta_ant(n)))<=0.00001)  %避免分母为0时出错    
           Antenna_pattern(n) = Antenna_pattern(n-1);     
        else
           Antenna_pattern(n) = abs((2^(q+1)* factorial(q+1)*besselj(q+1,(Ba*sind(abs(theta_ant(n)))))/((Ba*sind(abs(theta_ant(n))))^(q+1)))^2);  
        end
    end
    Antenna_pattern=Antenna_pattern/max(Antenna_pattern);
    Antenna_pattern_dB=10*log10(abs(Antenna_pattern));
    [HPBW,mark_3] = HPBW_of_AP(Antenna_pattern,theta_ant);     
    [~,~,Null_BW_half] = SLL_of_AP(Antenna_pattern_dB,theta_ant);     %计算天线方向图的零点波束宽度、第一副瓣电平，并返回第一副瓣位置
    disp(Null_BW_half)
    mark_3dB(q+1) = find(abs(theta-HPBW/2)==min(abs(theta-HPBW/2)));
    mark_Null(q+1) = find(abs(theta-Null_BW_half)==min(abs(theta-Null_BW_half)));
    MBE = beam_efficiency(q+1,mark_Null(q+1));
    disp(q);disp(MBE);
    denominator = 0;
end

% 画出天线效率
figure;
plot(coordinate,beam_efficiency(1,:),'-b','LineWidth',2) ;hold on;
plot(coordinate(mark_Null(1)),beam_efficiency(1,mark_Null(1)),'k.','MarkerSize',24);hold on;
plot(coordinate(mark_3dB(1)),beam_efficiency(1,mark_3dB(1)),'kx','MarkerSize',10);hold on;

plot(coordinate,beam_efficiency(2,:),'-c','LineWidth',2);hold on;
plot(coordinate(mark_Null(2)),beam_efficiency(2,mark_Null(2)),'k.','MarkerSize',24);hold on;
plot(coordinate(mark_3dB(2)),beam_efficiency(2,mark_3dB(2)),'kx','MarkerSize',10);hold on;

plot(coordinate,beam_efficiency(3,:),'-r','LineWidth',3);hold on;
plot(coordinate(mark_Null(3)),beam_efficiency(3,mark_Null(3)),'k.','MarkerSize',24);hold on;
plot(coordinate(mark_3dB(3)),beam_efficiency(3,mark_3dB(3)),'kx','MarkerSize',10);hold on;

plot(coordinate,beam_efficiency(4,:),'-g','LineWidth',2);hold on;
plot(coordinate(mark_Null(4)),beam_efficiency(4,mark_Null(4)),'k.','MarkerSize',24);hold on;
plot(coordinate(mark_3dB(4)),beam_efficiency(4,mark_3dB(4)),'kx','MarkerSize',10);hold on;

plot(coordinate,beam_efficiency(5,:),'-y','LineWidth',2);hold on;
plot(coordinate(mark_Null(5)),beam_efficiency(5,mark_Null(5)),'k.','MarkerSize',24);hold on;
plot(coordinate(mark_3dB(5)),beam_efficiency(5,mark_3dB(5)),'kx','MarkerSize',10);hold on;

axis([0,10,0.4,1]);
grid on;
toc;