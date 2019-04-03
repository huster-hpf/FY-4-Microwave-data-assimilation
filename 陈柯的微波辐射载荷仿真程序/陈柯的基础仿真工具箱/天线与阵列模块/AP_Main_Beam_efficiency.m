function  MBE = AP_Main_Beam_efficiency(Ba,Null_BW,taper)
%   函数功能：计算综合孔径阵列方向图主波束效率**********************************
%            返回波束效率
%  
%   输入参数:
%    Ba           :天线电长度参数
%    taper        :孔径照度；
%    Null_BW      :零点波束宽度
%   输出参数：
%    MBE          :主波束效率                                      
%   by 陈柯 2016.06.24  ******************************************************

Main_lobe = 0;
Full_lobe = 0;
num_Full = 10000;
theta_x = linspace(-90,90,num_Full);        %x坐标向量
theta_y = linspace(-90,90,num_Full);        %y坐标向量
AP_MBE = zeros(num_Full,num_Full);
matlabpool open;
parfor x = 1:num_Full
    for y = 1:num_Full 
    %点的位置
    pix_point = theta_x(x)+1i*theta_y(y);
    if (abs(pix_point/90)<=1)
        theta = abs(pix_point);
    %计算指向对应方位的视场范围内的辐射计天线方向图 
        if(sind(theta)<=1e-6)  %避免分母为0时出错
           AP_MBE(y,x) = 1;
        else
           AP_MBE(y,x) = abs((2^(taper+1)* factorial(taper+1)*besselj(taper+1,(Ba*sind(abs(theta))))/((Ba*sind(abs(theta)))^(taper+1)))^2);
        end
        if theta <= Null_BW
            Main_lobe = Main_lobe+AP_MBE(y,x);             
        end
        Full_lobe = Full_lobe+AP_MBE(y,x) ;
     end      
    end
 end
matlabpool close;
MBE = Main_lobe/Full_lobe*100;