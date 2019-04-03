clear;
close all;

TAmat_path = 'E:\百度云同步盘\陈柯的微波辐射载荷仿真程序\RA仿真结果';
scene_name = 'HurricanRainbow_03_06';
scenario = '台风彩虹';
antenna_diameter = 2400;
integral_time = 0.04; 
sample_interval = 12;
%读取WienerFilter算法处理结果
Resolution_Enhancement_name = 'WienerFilter';
TA_filename = sprintf('RA_%s_D%d_τ%s_sample%d_%s', scene_name,antenna_diameter,num2str(integral_time),sample_interval,Resolution_Enhancement_name); %亮温图像文件名
TAMatFileName = sprintf('%s_result_list.mat', TA_filename);   
TAMatFileName = sprintf('%s\\%s',TAmat_path,TAMatFileName);
load(TAMatFileName);
RMSE_RE_list_1 = RMSE_RE_list;
Corr_coefficient_RE_list_1 = Corr_coefficient_RE_list;
%读取BG算法处理结果
Resolution_Enhancement_name = 'BG';
TA_filename = sprintf('RA_%s_D%d_τ%s_sample%d_%s', scene_name,antenna_diameter,num2str(integral_time),sample_interval,Resolution_Enhancement_name); %亮温图像文件名
TAMatFileName = sprintf('%s_result_list.mat', TA_filename);   
TAMatFileName = sprintf('%s\\%s',TAmat_path,TAMatFileName);
load(TAMatFileName);
RMSE_RE_list_2 = RMSE_RE_list;
Corr_coefficient_RE_list_2 = Corr_coefficient_RE_list;

channel_start_index =1;
channel_end_index =37;
Corr_coefficient_min = min(min(Corr_coefficient_list))-0.01;
color=[1 0.5 0;0.2 0.8 0];
color2=[0 0.7 1;1 0.5 0;0.2 0.8 0];
BarWidth = 0.7;
i=channel_start_index:1:channel_end_index;
%%不同天线照射锥度观测
figure;
subplot(2,1,1);
set(gcf,'color','white');
h1 = bar([RMSE_list(i,1),RMSE_list(i,2)],BarWidth);
set(h1(1),'FaceColor',color(1,:))
set(h1(2),'FaceColor',color(2,:))
set(gca,'xtick',1:1:37)
xlabel('频率通道');
ylabel('RMSE(K)');
title(['不同天线照射锥度观测亮温RMSE对比----',scenario]);
legend('taper=0','taper=1');
subplot(2,1,2);
set(gcf,'color','white');
h2=bar([Corr_coefficient_list(i,1),Corr_coefficient_list(i,2)],BarWidth);
set(h2(1),'FaceColor',color(1,:))
set(h2(2),'FaceColor',color(2,:))
set(gca,'xtick',1:1:37)
xlabel('频率通道');
ylabel('相关系数');
ylim([Corr_coefficient_min,1]);
title(['不同天线照射锥度观测亮温相关系数对比----',scenario]);
legend('taper=0','taper=1');


%%taper = 0时图像增强效果
figure;
BarWidth = 0.7;

i=channel_start_index:1:channel_end_index;
subplot(2,1,1);
set(gcf,'color','white');
h1 = bar([RMSE_list(i,1),RMSE_RE_list_1(i,1),RMSE_RE_list_2(i,1)],BarWidth);
set(h1(1),'FaceColor',color2(1,:))
set(h1(2),'FaceColor',color2(2,:))
set(h1(3),'FaceColor',color2(3,:))
set(gca,'xtick',1:1:37)
xlabel('频率通道');
ylabel('RMSE(K)');
title(['taper=0时分辨率增强后观测亮温RMSE对比----',scenario]);
legend('原始观测','WienerFilter增强','BG增强');
subplot(2,1,2);
set(gcf,'color','white');
h2 = bar([Corr_coefficient_list(i,1),Corr_coefficient_RE_list_1(i,1),Corr_coefficient_RE_list_2(i,1)],BarWidth);
set(h2(1),'FaceColor',color2(1,:))
set(h2(2),'FaceColor',color2(2,:))
set(h2(3),'FaceColor',color2(3,:))
set(gca,'xtick',1:1:37)
xlabel('频率通道');
ylabel('相关系数');
ylim([Corr_coefficient_min,1]);
title(['taper=0时分辨率增强后观测亮温RMSE对比----',scenario]);
legend('原始观测','WienerFilter增强','BG增强');

%%taper = 1时图像增强效果
figure;
BarWidth = 0.7;

i=channel_start_index:1:channel_end_index;
subplot(2,1,1);
set(gcf,'color','white');
h1 = bar([RMSE_list(i,2),RMSE_RE_list_1(i,2),RMSE_RE_list_2(i,2)],BarWidth);
set(h1(1),'FaceColor',color2(1,:))
set(h1(2),'FaceColor',color2(2,:))
set(h1(3),'FaceColor',color2(3,:))
set(gca,'xtick',1:1:37)
xlabel('频率通道');
ylabel('RMSE(K)');
title(['taper=1时分辨率增强后观测亮温RMSE对比----',scenario]);
legend('原始观测','WienerFilter增强','BG增强');
subplot(2,1,2);
set(gcf,'color','white');
h2 = bar([Corr_coefficient_list(i,2),Corr_coefficient_RE_list_1(i,2),Corr_coefficient_RE_list_2(i,2)],BarWidth);
set(h2(1),'FaceColor',color2(1,:))
set(h2(2),'FaceColor',color2(2,:))
set(h2(3),'FaceColor',color2(3,:))
set(gca,'xtick',1:1:37)
xlabel('频率通道');
ylabel('相关系数');
ylim([Corr_coefficient_min,1]);
title(['taper=1时分辨率增强后观测亮温RMSE对比----',scenario]);
legend('原始观测','WienerFilter增强','BG增强');

