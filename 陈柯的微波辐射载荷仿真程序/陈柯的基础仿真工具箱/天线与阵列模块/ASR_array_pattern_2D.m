function  [HPBW,SLL,Null_BW,ASR_Pattern,MBE] = ASR_array_pattern_2D(array_type,xi,eta,xi_max,eta_max,uv_sample,uv_area,A,w,G,window_name,freq_index)
%   函数功能：画出综合孔径天线方向图**********************************
%            返回3dB波束宽度、波束效率、第一旁瓣等天线图参数
%  
%   输入参数:
%    array_type：阵列类型
%    xi        :ξ方向坐标向量；
%    eta       :η方向坐标向量；
%    xi_max    ：方向图在ξ方向的最大值,方向图空间范围为-ξmax--ξmax
%    eta_max   : 方向图在η方向的最大值,方向图空间范围为-ηmax--ηmax
%    uv_sample ：uv平面采样点坐标，对波长归一化          
%    uv_area   : 每个uv采样格点的面积，只对圆环阵列有意义
%    A         : 每个uv采样格点的面积
%    G         : 单元天线方向图
%   输出参数：
%    HPBW      : 方向图半功率波束宽度                                       
%   by 陈柯 2016.06.24  ******************************************************
num_row = length(eta);
num_col = length(xi);
AF = zeros(num_row,num_col);
G = interpolation(G,num_row,num_col);
d_xi=2*xi_max/num_col;
d_eta=2*eta_max/num_row;

if (~strcmpi('O_Rotate_shape',array_type)) && (~strcmpi('O_shape',array_type))
   matlabpool open;
   parfor m = 1:num_row
       for n = 1:num_col      
           if (sqrt(xi(n)^2+eta(m)^2))<=1            
               AF(m,n)=real(A*sum(w.*exp(1i*2*pi*(real(uv_sample)*xi(n)+imag(uv_sample)*eta(m)))));               
           else
               AF(m,n)=NaN;
           end     
        end
   end
   matlabpool close;
else
   matlabpool open;
   parfor m = 1:num_row
       for n = 1:num_col       
           if (sqrt(xi(n)^2+eta(m)^2))<=1            
               AF(m,n)=real(sum(w.*uv_area.*exp(1i*2*pi*(real(uv_sample)*xi(n)+imag(uv_sample)*eta(m)))));               
           else
               AF(m,n)=NaN;
           end     
        end
   end
   matlabpool close;
end
%计算归一化综合孔径功率方向图及其对数
ASR_Pattern = AF.*G;                                    %综合孔径方向图等于综合孔径阵列因子点乘单元天线方向图
% ASR_Pattern=ASR_Pattern/sum(sum(ASR_Pattern));      %综合孔径方向图归一化
ASR_Pattern_norm=ASR_Pattern/max(max(ASR_Pattern)); %综合孔径方向图最大值归一化
ASR_Pattern_dB=10*log10(abs(ASR_Pattern_norm));       %dB综合孔径方向图
[peak_row,~] =find(ASR_Pattern_norm ==1) ;
%画出天线方向图
% figure;mesh(xi,eta,ASR_Pattern_norm);xlim([-xi_max,xi_max]);ylim([-eta_max,eta_max]);
% xlabel('\xi');ylabel('\eta');zlabel('AP_syn');title([array_type,'ASR阵列方向图-三维@',window_name,'窗']);
figure;
subplot(2,2,1);imagesc(xi,eta,ASR_Pattern_norm);axis equal;xlim([-xi_max,xi_max]);ylim([-eta_max,eta_max]);
xlabel('\xi');ylabel('\eta');title([array_type,'ASR阵列方向图-平面@Ch.',num2str(freq_index),',@',window_name,'窗']);
subplot(2,2,2);imagesc(xi,eta,ASR_Pattern_dB);axis equal;xlim([-xi_max,xi_max]);ylim([-eta_max,eta_max]);
xlabel('\xi');ylabel('\eta');title([array_type,'ASR阵列方向图-平面dB@Ch.',num2str(freq_index),',@',window_name,'窗']);
%画出phy角等于0度平面的一维方向图，并求出其3dB波束宽度
theta = asind(xi);
ASR_Pattern_1D_eta = ASR_Pattern_norm(peak_row,:);
scale_factor = 5;                                                               % 画一维方向图时点数的倍数因子
d_xi_scale = d_xi/scale_factor;
theta_scale = asind(linspace(-xi_max,xi_max-d_xi_scale,num_col*scale_factor));        %ξ坐标向量
ASR_Pattern_1D_scale = interp1(theta,ASR_Pattern_1D_eta,theta_scale,'spline');  %采用样条插值，精度最高
ASR_Pattern_1D_dB_scale = 10*log10(abs(ASR_Pattern_1D_scale)); 
[HPBW,mark_3dB] = HPBW_of_AP(ASR_Pattern_1D_scale,theta_scale);     %计算天线方向图的3dB波束宽度，并返回3dB点位置
[SLL,mark_SLL,Null_BW] = SLL_of_AP(ASR_Pattern_1D_dB_scale,theta_scale);     %计算天线方向图的零点波束宽度、第一副瓣电平，并返回第一副瓣位置
%画出η=0截面上的一维综合孔径方向图
subplot(2,2,3);hPlot=plot(theta_scale,ASR_Pattern_1D_scale,'LineWidth',3); makedatatip(hPlot,mark_3dB);xlim([asind(-xi_max),asind(xi_max)]);
xlabel('\theta');ylabel('AP-syn-norm');title(['ASR阵列方向图截面@\eta=0@Ch.',num2str(freq_index),',@',window_name,'窗']);grid on;
subplot(2,2,4);hPlot=plot(theta_scale,ASR_Pattern_1D_dB_scale,'LineWidth',3); makedatatip(hPlot,mark_SLL);xlim([asind(-xi_max),asind(xi_max)]);
xlabel('\theta');ylabel('AP-syn-norm-dB');title(['ASR阵列方向图截面dB@\eta=0@Ch.',num2str(freq_index),',@',window_name,'窗']);grid on;

%计算主波束效率
Main_lobe = 0;
Full_lobe = 0;
for m = 1:num_row
    for n = 1:num_col      
        Full_lobe = Full_lobe+abs(ASR_Pattern_norm(m,n));
        if asind(sqrt(xi(n)^2+eta(m)^2))<=Null_BW            
            Main_lobe = Main_lobe+abs(ASR_Pattern_norm(m,n));             
        end     
    end
 end
MBE = Main_lobe/Full_lobe*100;



