% 一维综合孔径阵列因子
% 陈柯，2015-11-1
function [AF,HPBW,amplitude_3dB,main_beam_efficiency] = ArrayFactor1D(theta0, ksi, P, delta_u, window_name,range)

p = (-P:1:P).';
w = window(window_name, 2*P+1);
ksi0 = ones(1, length(ksi)) * sind(theta0);
AF = zeros(1,length(ksi));
AF_sum = 0;
% AF = real( w.' * exp(j*2*pi*delta_u*p.'*(ksi0-l)) ) / (2*P+1);
for i=1:length(ksi)
      AF(i)=real(delta_u*sum(w.*exp(1j*2*pi*delta_u*p*(ksi0(i)-ksi(i)))));%       
      AF_sum=AF_sum+ AF(i);     
end

AF_norm = AF/max(AF);
AF_dB=10*log10(abs(AF_norm));

AF_max = max(AF);
diff = AF_max/3;
ksi_3dB = 0;
k_3dB = 0;
amplitude_3dB = 0;
AF_all_beam = sum(abs(AF));
AF_main_beam = 0;
for k = 1:length(AF)
    if abs(AF(k)-0.5*AF_max) < diff
        diff = abs(AF(k)-0.5*AF_max);
        ksi_3dB = ksi(k);
        k_3dB = k;
        amplitude_3dB = AF_norm(k);
    end
end
theta_3dB = asind(ksi_3dB)-theta0;

HPBW = 2 * abs(theta_3dB)

k_center = find(AF==AF_max);

for k = k_center:-1:1
    if AF(k)>AF(k-1)
        AF_main_beam = AF_main_beam+abs(AF(k));
    else
        break;
    end
end
for k = k_center+1:1:length(AF)
    if AF(k)>AF(k+1)
        AF_main_beam = AF_main_beam+abs(AF(k));
    else
        break;
    end
end
main_beam_efficiency = AF_main_beam/AF_all_beam

k_HPBW = abs(k_center-k_3dB);
k_start = k_center-range*k_HPBW;
k_end = k_center+ range*k_HPBW;

mark_3dB = round(k_end-k_start)/2+k_HPBW+1;

theta = asind(ksi);

figure;hPlot=plot(theta(k_start:k_end),AF_norm(k_start:k_end),'LineWidth',2); makedatatip(hPlot,[mark_3dB]);xlim([theta(k_start),theta(k_end)]);xlabel('\theta(°)');title('归一化综合孔径阵列因子');grid on;
figure;hPlot=plot(theta(k_start:k_end),AF_dB(k_start:k_end),'LineWidth',2);makedatatip(hPlot,[mark_3dB]);xlim([theta(k_start),theta(k_end)]);xlabel('\theta(°)');title('归一化综合孔径阵列因子dB');grid on;
    

