function T = Pseudo_Polar_Inv(V) 
%   函数功能：   利用共轭梯度迭代法实现伪极网格反演圆环阵列的综合孔径亮温图像**********************************
%               
%  
%   输入参数:
%   V               ：伪极网格上的可见度函数值，按照BV，BH分开排列，为2N*2N矩阵

%   输出参数：
%   T            ：   反演得到的亮温图像，尺寸为N*N
  
N=length(V)/2;      %  V是伪极网格矩阵，通常是2N*2N大小
D=sqrt(abs(-N:1:N-1)/2)/N; 
D(N+1)=sqrt(1/8)/N;
D=ones(2*N,1)*D;      % D是预置系数矩阵，用于迭代加速
X=zeros(N,N);         % 迭代初始值，通常设为零 
Delta=1;              % 每次迭代的差值
accuracy = 1e-10;     % 迭代精度阈值
count=0;
mu=1/N;               %控制因子，控制迭代过程

while Delta>accuracy,    % accuracy是预设精度
    V_int = PPFFT(X).';
    Err=D.*(V_int-V.');  % PPFFT是伪极网格FFT变换，（即水平和垂直两组数据分别变换后的叠加）
    AD=APPFFT(D.*Err).'; % APPFFT是伪极网格FFT变换的伴随矩阵，类似于PPFFT的逆过程（同样是横竖两组数据变换后的叠加）
    Delta=norm(AD);
    X_New=X-mu*AD; 
    X=X_New;
    count=count+1;       % 迭代次数 
end;
disp(['伪极网格反演迭代次数=',num2str(count)]);  
T=X;                      %反演的亮温图像









