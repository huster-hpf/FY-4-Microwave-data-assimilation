function T_inv = PPolar_IDFT_2D_debug(V,Tb,factor_PP,d_xi,d_eta)
%   函数功能：   利用共轭梯度迭代法实现伪极网格反演圆环阵列的综合孔径亮温图像**********************************
%               
%  
%   输入参数:
%   V               ：伪极网格上的可见度函数值，按照BV，BH分开排列，为2N*2N矩阵

%   输出参数：
%   T            ：   反演得到的亮温图像，尺寸为N*N

%画出插值后的伪极网格可见度模值和采样点分布
figure;imagesc(abs(V));colorbar;title('圆环网格插值计算的伪极网格可见度函数幅度');                    
%用一维FFT变换快速计算出伪极网格点上的可见度函数
V_FFT_PP = PPFFT(Tb,factor_PP,factor_PP)*d_xi*d_eta; 
figure;imagesc(abs(V_FFT_PP));colorbar;title('PPFFT变换计算的伪极网格可见度函数幅度'); 
%计算插值得到的伪极网格格点上的可见度函数幅值误差
MSE_VPP = Mean_Square_Error(abs(V_FFT_PP),abs(V),0,0); title('PPFFT与ASR伪极网格可见度函数幅度差值'); 
disp(['伪极网格可见度幅值插值误差=',num2str(MSE_VPP)]);     
%通过多次共轭梯度迭代，实现伪极网格反演得到亮温图像
T_inv = Pseudo_Polar_Inv(V)/(d_xi*d_eta);  %反演亮温 