function V_noise = Visibility2D_add_noise(V,uv_ant_info,T_noise_rec,T_noise_B,bandwidth,integral_time)
%   函数功能：对可见度函数添加综合孔径阵列系统热噪声**********************************%             
%  
%   输入参数:
%    V              ：无噪声的精确可见度函数 
%    uv_ant_info    ：每个可见度对应的一对阵元在阵列中的编号，为一复数，实部为阵元1，虚部为阵元2
%    T_noise_rec    ：每个阵元对应的接收机通道等效热噪声温度，为一数组 ，单位：K
%    T_noise_B      ：场景平均热噪声温度，单位：K
%    bandwidth      ：接收机通道的带宽 
%    integral_time  ：系统积分时间
%   输出参数：
%    V_noise       : 加噪之后的可见度函数                                       
%   by 陈柯 2016.06.24  ******************************************************

[num_row,num_col] = size(V);                 %可见度函数行列数
delta_V = zeros(num_row,num_col);            %初始化每个可见度函数的噪声标准差

noise_factor = sqrt(1/2/bandwidth/integral_time) ; 
TB = T_noise_B;

ant_num = length(T_noise_rec);
V_autocorrelation = zeros(1,ant_num);
for n =1:ant_num
    V_autocorrelation(n) = V((n-1)*ant_num+n);
end
%计算每个可见度函数的噪声标准差，算法来源于Ruf 1988年文章‘Interferometric synthetic aperture
%microwave radiometry for the remote sensing of the Earth’公式（12）（13）
for m = 1:num_row
    for n= 1:num_col
        Vi = V_autocorrelation(real(uv_ant_info(m,n)));
        Vk = V_autocorrelation(imag(uv_ant_info(m,n)));
        delta_V(m,n) = noise_factor*(sqrt(Vi*Vk+real(V(m,n))^2-imag(V(m,n))^2)+1i*sqrt(Vi*Vk+imag(V(m,n))^2-real(V(m,n))^2));
    end
end
noise_matrix = randn(num_row,num_col).*delta_V;  %所有可见度函数的噪声矩阵
V_noise = V+noise_matrix;                        %加噪



