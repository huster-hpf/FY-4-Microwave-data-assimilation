function  [MBE] = ASR_Main_Beam_efficiency(array_type,uv_sample,uv_area,A,w,antenna_G,num,Null_BW,xi_max,eta_max)
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
AF = zeros(num,num);
G = interpolation(antenna_G,num,num);
d_xi=2*xi_max/num;
d_eta=2*eta_max/num;
xi = linspace(-xi_max,xi_max-d_xi,num);        %ξ坐标向量
eta = linspace(-eta_max,eta_max-d_eta,num);   %η坐标向量
Main_lobe = 0;
Full_lobe = 0;

if (~strcmpi('O_Rotate_shape',array_type)) && (~strcmpi('O_shape',array_type))
   matlabpool open;
   parfor m = 1:num
       for n = 1:num      
           if (sqrt(xi(n)^2+eta(m)^2))<=1            
               AF(m,n)=real(A*sum(w.*exp(1i*2*pi*(real(uv_sample)*xi(n)+imag(uv_sample)*eta(m)))));               
           else
               AF(m,n)=0;
           end     
        end
   end
   matlabpool close;
else
   matlabpool open;
   parfor m = 1:num
       for n = 1:num       
           if (sqrt(xi(n)^2+eta(m)^2))<=1            
               AF(m,n)=real(sum(w.*uv_area.*exp(1i*2*pi*(real(uv_sample)*xi(n)+imag(uv_sample)*eta(m)))));               
           else
               AF(m,n)=0;
           end     
        end
   end
   matlabpool close;
end
ASR_Pattern = AF.*G;                                    %综合孔径方向图等于综合孔径阵列因子点乘单元天线方向图
ASR_Pattern=ASR_Pattern/sum(sum(ASR_Pattern));         %综合孔径方向图归一化
ASR_Pattern_norm=ASR_Pattern/max(max(ASR_Pattern));   %综合孔径方向图最大值归一化
ASR_Pattern_dB=10*log10(abs(ASR_Pattern_norm));       %dB综合孔径方向图
for m = 1:num
    for n = 1:num 
        Full_lobe = Full_lobe+abs(ASR_Pattern_norm(m,n));
        if asind(sqrt(xi(n)^2+eta(m)^2))<=Null_BW            
            Main_lobe = Main_lobe+abs(ASR_Pattern_norm(m,n));             
        end     
    end
 end
figure;imagesc(xi,eta,ASR_Pattern_norm);axis equal;xlim([-xi_max,xi_max]);ylim([-eta_max,eta_max]);xlabel('\xi');ylabel('\eta');title([array_type,'综合孔径功率方向图-平面']);
figure;imagesc(xi,eta,ASR_Pattern_dB);axis equal;xlim([-xi_max,xi_max]);ylim([-eta_max,eta_max]);xlabel('\xi');ylabel('\eta');title([array_type,'综合孔径功率方向图-平面dB']);
MBE = Main_lobe/Full_lobe*100;