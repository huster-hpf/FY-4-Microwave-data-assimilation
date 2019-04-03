function [PP_V,PP_uv] = PP_interp_debug(visibility,uvsample,num_radius,num_theta,N,Tb_modify,d_xi,d_eta,uv_to_DFT,uv_to_pi)
%   函数功能：   实现对均匀圆环阵列的圆形uv采样可见度函数插值到伪极网格分布**********************************
%               返回插值后的可见度函数值和伪极网格uv坐标 
%               分析调试版本，内部带有各种显示插值精度代码
%  
%   输入参数:
%   visibility      ：均匀圆环阵列可见度
%   uvsample       ： 均匀圆环阵列uv采样点坐标
%   N               : 伪极网格点数，插值后的伪极网格为2N*2N
%   Tb_modify       ：输入亮温图像的修正亮温
%   uv_to_DFT,      ：uv平面—DFT平面的坐标转换因子
%   uv_to_pi        ：uv平面—2pi归一化频率平面的坐标转换因子
%   d_xi,d_eta      : 图像的二维方向格点尺寸
%   输出参数：
%   PP_V            ：插值后的伪极网格可见度函数，按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵
%   PP_uv           ：伪极网格采样点uv坐标，按照-pi~pi范围归一化，也是按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵                          
%   by 陈柯 2016.06.24  ******************************************************  

% 圆形阵对应的uv平面是以[0 0]为中心的离散同心源

%画出插值前的输入可见度函数幅值分布%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V_draw1 = zeros(num_theta,num_radius+1);
V_draw1(:,1) = visibility(1);
V_draw1(:,2:num_radius+1) = reshape(visibility(2:length(visibility)),num_theta,num_radius);
uv_draw1 = zeros(num_theta,num_radius+1);
uv_draw1(:,1) = uvsample(1);
uv_draw1(:,2:num_radius+1) = reshape(uvsample(2:length(uvsample)),num_theta,num_radius);
X = real(uv_draw1);
Y = imag(uv_draw1);
figure;h = pcolor(X,Y,abs(V_draw1));set( h, 'linestyle', 'none');title('原始可见度幅值分布'); 

%%%%%%%%%% 角度插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 初始化角度插值后可见度与uv采样平面
PP_theta_interp_visibility = zeros(1,1+N*4*num_radius);
PP_theta_interp_visibility(1) = visibility(1);
PP_theta_interp_uvsample = zeros(1,1+N*4*num_radius);
PP_theta_interp_uvsample(1) = uvsample(1);
%角度插值误差数组
angle_interp_rmse = zeros(1,num_radius);
uv_radius = zeros(1,num_radius+1);
% 插值到同一个相位角上
for k = 1:num_radius
    index_old = (k-1)*num_theta+2:k*num_theta+1;
    v_old = visibility(index_old);
    uvsample_old = uvsample(index_old);
    [v_new,uvsample_new]= PP_theta_interp(v_old,uvsample_old,N); 
%%%%%%%%%%%%%%%%%%%%%%对比每一条同心圆上的角度插值与精确值的误差%%%%%%%%%%%%%%%
    uv_sample_DFT = real(uvsample_new)/real(uv_to_pi)*real(uv_to_DFT)+1i*imag(uvsample_new)/imag(uv_to_pi)*imag(uv_to_DFT); % 2pi--uv--DFT 坐标转换
    V_DFT = Brute_Force_Transform_DFT(Tb_modify,real(uv_sample_DFT),imag(uv_sample_DFT))*d_xi*d_eta;
%     figure;plot(abs(v_new),'-rs');hold on;plot(abs(V_DFT),'-b*'); title([num2str(k),'角度插值可见度与准确值对比']) ; 
    angle_interp_rmse(k) = sqrt(sum(((real(V_DFT-v_new)).^2)/length(v_new)))+1i*sqrt(sum(((imag(V_DFT-v_new)).^2)/length(v_new)));
    uv_radius(k+1) = mean(abs(real(uvsample_new)/real(uv_to_pi)+1i*imag(uvsample_new)/imag(uv_to_pi)));   %计算每一圈的基线半径大小
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    index_new = (k-1)*N*4+2:k*N*4+1;                %确定插值后的可见度序号 
    PP_theta_interp_visibility(index_new) = v_new;
    PP_theta_interp_uvsample(index_new) = uvsample_new;    
end
%画出不同半径圈上的角度插值误差
figure;semilogy(real(angle_interp_rmse),'-b*');hold on;semilogy(imag(angle_interp_rmse),'-ro');title('角度插值可见度模值误差'); 
figure;stem(uv_radius,'fill');title('基线排列');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 画出角度插值后的可见度函数模值分布%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V_draw1 = zeros(4*N,num_radius+1);
V_draw1(:,1) = PP_theta_interp_visibility(1);
V_draw1(:,2:num_radius+1) = reshape(PP_theta_interp_visibility(2:length(PP_theta_interp_visibility)),4*N,num_radius);
uv_draw1 = zeros(4*N,num_radius+1);
uv_draw1(:,1) = PP_theta_interp_uvsample(1);
uv_draw1(:,2:num_radius+1) = reshape(PP_theta_interp_uvsample(2:length(PP_theta_interp_uvsample)),4*N,num_radius);
X = real(uv_draw1);
Y = imag(uv_draw1);
figure;h = pcolor(X,Y,abs(V_draw1));set( h, 'linestyle', 'none');title('角度插值后原始可见度模值分布'); 

%%%%%%%%%% 径向插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PP_visibility = zeros(1,4*N*N);     % 初始化插值后可见度
PP_uv_sample = zeros(1,4*N*N);      % 初始化插值后uv采样平面
radius_interp_rmse = zeros(4*N,N);  % 径向插值误差数组
% 按照半径插值
for k = 1:4*N
    index_old = 1+(0:num_radius-1)*4*N+k;
    v_old = PP_theta_interp_visibility(index_old);
    uvsample_old = PP_theta_interp_uvsample(index_old);
    [v_new,uvsample_new]= PP_radius_interp(v_old,uvsample_old,N,visibility(1));
    %径向插值点的uv采样点坐标和精确可见度值，然后和插值可见度值对比，得到插值误差%%%%%%%%%%
    uv_sample_DFT = real(uvsample_new)/real(uv_to_pi)*real(uv_to_DFT)+1i*imag(uvsample_new)/imag(uv_to_pi)*imag(uv_to_DFT); % 2pi--uv--DFT 坐标转换
    V_DFT = Brute_Force_Transform_DFT(Tb_modify,real(uv_sample_DFT),imag(uv_sample_DFT))*d_xi*d_eta;
%         figure;plot(abs(uvsample_new(2:N)),real(v_new(2:N)),'-rs');hold on;plot(abs(uvsample_new(2:N)),real(V_DFT(2:N)),'-b*');hold on;
%         plot(abs(uvsample_old),real(v_old),'-go');title([num2str(k),'射线径向插值可见度与精确值实部']);
%         figure;plot(abs(uvsample_new(2:N)),imag(v_new(2:N)),'-rs');hold on;plot(abs(uvsample_new(2:N)),imag(V_DFT(2:N)),'-b*');
%         plot(abs(uvsample_old),imag(v_old),'-go');title([num2str(k),'射线径向插值可见度与精确值虚部']);      
    if k<=2*N
        radius_interp_rmse(k,:) =v_new-V_DFT; %         
    else
        radius_interp_rmse(k,2:N) =v_new(1:N-1)-V_DFT(1:N-1); %         
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    index_new = (k-1)*N+1:k*N;  %确定插值后的可见度序号    
    PP_visibility(index_new) = v_new;
    PP_uv_sample(index_new) = uvsample_new;   
end 
%画出伪极网格不同矩形方格上的径向插值误差
realpart = abs(real(radius_interp_rmse));imagpart = abs(imag(radius_interp_rmse));
mrealpart = mean(realpart,1);mimagpart = mean(imagpart,1);
figure;semilogy(mrealpart,'-b*');hold on;semilogy(mimagpart,'-ro');title('径向插值可见度实部与虚部误差');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%画出径向插值后的可见度函数模值分布
V_resample = reshape(PP_visibility,N,4*N);
uv_resample = reshape(PP_uv_sample,N,4*N);
V_draw = zeros(4*N,N);
uv_draw = zeros(4*N,N);
V_draw(1:2*N,1:N) = V_resample(1:N,1:2*N).';
uv_draw(1:2*N,1:N) = uv_resample(1:N,1:2*N).';
V_draw(2*N+1:4*N,2:N) = V_resample(1:N-1,2*N+1:4*N).';
uv_draw(2*N+1:4*N,2:N) = uv_resample(1:N-1,2*N+1:4*N).';  
V_draw(2*N+1:4*N,1) = V_resample(1,1:2*N).';
X = real(uv_draw);
Y = imag(uv_draw);
figure;h = pcolor(X,Y,abs(V_draw));set( h, 'linestyle', 'none');title('径向插值后原始可见度模值分布'); 

%将可见度函数调整为BV和BH分开排列%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BV = zeros(2*N,N);
BH = zeros(2*N,N);
BV_uv =  zeros(2*N,N);
BH_uv = zeros(2*N,N);

for k = 1:N
     BH(N:-1:1,k) = PP_visibility((k-1)*N+1+2*N*N:k*N+2*N*N);          %垂直极化点，与张成2007年文献上是反过来的，与 Create_Oversampled_Grid 函数算法保持一致
     BH_uv(N:-1:1,k) = PP_uv_sample((k-1)*N+1+2*N*N:k*N+2*N*N);
     BH(N+1:N+N,k) = PP_visibility((k-1)*N+1:k*N);
     BH_uv(N+1:N+N,k) = PP_uv_sample((k-1)*N+1:k*N); 
     BV(N:-1:1,k) =   PP_visibility((k-1)*N+1+3*N*N:k*N+3*N*N);  %水平极化点，与张成2007年文献上是反过来的，与 Create_Oversampled_Grid 函数算法保持一致
     BV_uv(N:-1:1,k) = PP_uv_sample((k-1)*N+1+3*N*N:k*N+3*N*N);
     BV(N+1:N+N,k) = PP_visibility((k-1)*N+1+N*N:k*N+N*N);
     BV_uv(N+1:N+N,k) = PP_uv_sample((k-1)*N+1+N*N:k*N+N*N);      
end

PP_V = [BV,BH];
PP_uv = [BV_uv,BH_uv];

