function  [HPBW,SLL,MBE] = Antenna_Pattern_2D_parameter_calc(Antenna_Pattern,Coordinate_x,Coordinate_y,angle_x,angle_y,channel_index,flag_draw_pattern,Ba,taper)
%   函数功能：计算一个二维天线方向图指标**********************************
%            返回3dB波束宽度、零点波束位置、波束效率、第一旁瓣电平等天线图参数
%  
%   输入参数:
%    Coordinate_x ：x轴方向坐标，单位：角度
%    Coordinate_y ：y轴方向坐标，单位：角度
%    angle_x      : x轴角度范围
%    angle_y      : y轴角度范围
%    Ba           : 天线电长度参数
%    taper        : 孔径照度；
%   输出参数：
%    Antenna_Pattern : 天线归一化功率方向图  
%    HPBW            : 半功率波束宽度 
%    SLL             ：第一副瓣电平
%    MBE             ：主波束效率
%   by 陈柯 2016.06.24  ******************************************************

%计算归一化综合孔径功率方向图及其对数
row = length(Coordinate_y);col = length(Coordinate_x);
Antenna_Pattern = interpolation(Antenna_Pattern,row,col);
Antenna_Pattern_norm=Antenna_Pattern/max(max(Antenna_Pattern)); %天线方向图最大值归一化
Antenna_Pattern_dB=10*log10(abs(Antenna_Pattern_norm));         %dB天线方向图
[peak_row,~] =find(Antenna_Pattern_norm ==1) ;
%画出天线方向图

% if flag_draw_pattern == 1
% % figure;mesh(Coordinate_x,Coordinate_y,Antenna_Pattern_norm);xlim([-angle_x/2,angle_x/2]);ylim([-angle_y/2,angle_y/2]);
% % xlabel('x');ylabel('y');zlabel('AP');title('实孔径天线归一化功率方向图-三维');
% figure;imagesc(Coordinate_x,Coordinate_y,Antenna_Pattern_norm);axis equal;xlim([-angle_x/2,angle_x/2]);ylim([-angle_y/2,angle_y/2]);
% xlabel('x');ylabel('y');title(['实孔径天线归一化功率方向图-平面@Ch.',num2str(channel_index)]);
% figure;imagesc(Coordinate_x,Coordinate_y,Antenna_Pattern_dB);axis equal;xlim([-angle_x/2,angle_x/2]);ylim([-angle_y/2,angle_y/2]);
% xlabel('x');ylabel('y');title(['实孔径天线归一化功率方向图-平面dB@Ch.',num2str(channel_index)]);
% end
%画出phy角等于0度平面的一维方向图，并求出其3dB波束宽度
d_x =abs( Coordinate_x(2)-Coordinate_x(1));
num_col = length(Coordinate_x);
theta = Coordinate_x;
Antenna_Pattern_1D = Antenna_Pattern_norm(peak_row(1),:);
scale_factor = 5;                                                                   % 画一维方向图时点数的倍数因子
d_x_scale = d_x/scale_factor;
theta_scale = linspace(-angle_x/2,angle_x/2-d_x_scale,num_col*scale_factor);        %x坐标向量
Antenna_Pattern_1D_scale = interp1(theta,Antenna_Pattern_1D,theta_scale,'spline');      %采用样条插值，精度最高
Antenna_Pattern_1D_dB_scale = 10*log10(abs(Antenna_Pattern_1D_scale)); 
[HPBW,mark_3dB] = HPBW_of_AP(Antenna_Pattern_1D_scale,theta_scale);     %计算天线方向图的3dB波束宽度，并返回3dB点位置
[SLL,mark_SLL,Null_theta] = SLL_of_AP(Antenna_Pattern_1D_dB_scale,theta_scale);     %计算天线方向图的零点波束宽度、第一副瓣电平，并返回第一副瓣位置
MBE = AP_Main_Beam_efficiency_Gail(Ba,Null_theta,taper);
if flag_draw_pattern == 1
%画出η=0截面上的一维综合孔径方向图
figure;hPlot=plot(theta_scale,Antenna_Pattern_1D_scale,'LineWidth',3); makedatatip(hPlot,mark_3dB);xlim([-angle_x/2,angle_x/2]);
xlabel('\theta');ylabel('AP-norm');title(['实孔径天线方向图截面@y=0@Ch.',num2str(channel_index)]);grid on;
figure;hPlot=plot(theta_scale,Antenna_Pattern_1D_dB_scale,'LineWidth',3); makedatatip(hPlot,mark_SLL);xlim([-angle_x/2,angle_x/2]);
xlabel('\theta');ylabel('AP-norm-dB');title(['实孔径天线方向图截面dB@y=0@Ch.',num2str(channel_index)]);grid on;
end