function [PP_V,PP_uv,uv_area_rotate,uv_sample_rotate] = PP_interp_for_Rotate_debug(visibility,uvsample,N,Tb_modify,d_xi,d_eta,uv_to_DFT,uv_to_pi)
%   函数功能：   实现对旋转圆环阵列的圆形uv采样可见度函数插值到伪极网格分布**********************************
%               返回插值后的可见度函数值和伪极网格uv坐标 
%               debug调试版本，内部带有各种显示插值精度代码
%  
%   输入参数:
%   visibility      ：去冗余前的旋转圆环阵列可见度
%   uvsample       ：去冗余前的旋转圆环阵列uv采样点坐标,按照半径从小到大排列，行为角度，列为半径，
%   N               : 伪极网格点数，插值后的伪极网格为2N*2N
%   Tb_modify       ：输入亮温图像的修正亮温
%   uv_to_DFT,      ：uv平面—DFT平面的坐标转换因子
%   uv_to_pi        ：uv平面—2pi归一化频率平面的坐标转换因子
%   d_xi,d_eta      : 图像的二维方向格点尺寸
%   输出参数：
%   PP_V            ：插值后的伪极网格可见度函数，按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵
%   PP_uv           ：伪极网格采样点uv坐标，按照-pi~pi范围归一化，也是按照PPFFT函数定义的顺序BV、BH分开排列，构成2N*2N矩阵                          
%   by 陈柯 2016.06.24  ******************************************************  

% 圆形阵对应的uv平面是以[0 0]为中心的离散同心圆

%%%%%%%%%%对uv采样半径进行排序，从小到大取出相同半径的可见度和采样分布
uvsample_radius=abs(uvsample(:,1));                       %uv采样同心圆的半径
[num_radius,num_theta] = size(uvsample);                  %半径数和每圈角度数，这里的半径数有冗余 
visibility_radius_sorted = zeros(num_radius,num_theta);   %初始化排序后的可见度和uv采样平面
uvsample_radius_sorted = zeros(num_radius,num_theta);
[sorted_radius,radius_index]=sort(uvsample_radius);       %对半径排序
for k=1:1:num_radius                                      %根据半径顺序，排序可见度和uv采样分布
        uvsample_radius_sorted(k,:)=uvsample(radius_index(k),:);
        visibility_radius_sorted(k,:)=visibility(radius_index(k),:);
end
visibility = visibility_radius_sorted;
uvsample = uvsample_radius_sorted;
%排序完成------------------------------------------------------------------

%%%%%%%%%% 角度插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 初始化角度插值后可见度与uv采样平面
PP_theta_interp_visibility = zeros(num_radius,N*4);
PP_theta_interp_uvsample = zeros(num_radius,N*4);
redundancy_zero = 0;                                             
% 插值到同一个相位角上
for k = 1:num_radius
    v_old = visibility(k,:);
    uvsample_old = uvsample(k,:);    
    if abs(uvsample_old(1)==0)
       v_new =  v_old(1).*ones(1,N*4);
       uvsample_new = uvsample_old(1).*ones(1,N*4);
       redundancy_zero = redundancy_zero+num_theta;                        %零基线的冗余度
    else    
     [v_new,uvsample_new] = PP_theta_interp(v_old,uvsample_old,N); 
    end    
%%%%%%%%%%%%对比每一条同心圆上的角度插值与精确值的误差%%%%%%%%%%%%%%%%%%%%%%%%
%     uv_sample_DFT = real(uvsample_new)/real(uv_to_pi)*real(uv_to_DFT)+1i*imag(uvsample_new)/imag(uv_to_pi)*imag(uv_to_DFT); % 2pi--uv--DFT 坐标转换
%     V_DFT = Brute_Force_Transform_DFT(Tb_modify,real(uv_sample_DFT),imag(uv_sample_DFT))*d_xi*d_eta;
%     figure;plot(abs(v_new),'-rs');hold on;plot(abs(V_DFT),'-b*'); title([num2str(k),'角度插值可见度与准确值对比']) ;      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PP_theta_interp_visibility(k,:) = v_new;
    PP_theta_interp_uvsample(k,:) = uvsample_new;    
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%对同一半径的同心圆进行平均，然后去掉一些挨得非常近的同心圆%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
radius_redunt=sorted_radius;                        %排序后的uv采样半径
uvlength=UV_unique(radius_redunt);                 %去冗余之后得到不同的半径大小
num_radius_unique = length(uvlength)-1;             %不同半径的数量
uv_radius_unique = zeros(num_radius_unique+1,N*4);  
v_radius_unique = zeros(num_radius_unique+1,N*4);
redundancy_unique = zeros(num_radius_unique+1,N*4);
%角度插值点的uv采样点坐标和精确可见度值，以及存储插值误差的数组
uv_sample_DFT = zeros(num_radius_unique+1,N*4);
V_DFT = zeros(num_radius_unique+1,N*4);
angle_rmse = zeros(num_radius_unique+1,1);
for k =1:1:(num_radius_unique+1)                    %对同一半径的同心圆采样点进行平均，因为角度值相同
    index_number=[radius_redunt==uvlength(k)];
    uv_radius_unique(k,:) = mean(PP_theta_interp_uvsample(index_number,:),1);
    v_radius_unique(k,:) = mean(PP_theta_interp_visibility(index_number,:),1); 
    redundancy_unique(k,:) = sum(index_number)*ones(1,N*4);
    %角度插值点的uv采样点坐标和精确可见度值，然后和插值可见度值对比，得到插值误差%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uv_sample_DFT(k,:) = real(uv_radius_unique(k,:))/real(uv_to_pi)*real(uv_to_DFT)+1i*imag(uv_radius_unique(k,:))/imag(uv_to_pi)*imag(uv_to_DFT); % 2pi--uv--DFT 坐标转换
    V_DFT(k,:) = Brute_Force_Transform_DFT(Tb_modify,real(uv_sample_DFT(k,:)),imag(uv_sample_DFT(k,:)))*d_xi*d_eta; 
    angle_rmse(k) = sqrt(sum(((real(V_DFT(k,:)-v_radius_unique(k,:))).^2)/(N*4)))+1i*sqrt(sum(((imag(V_DFT(k,:)-v_radius_unique(k,:))).^2)/(N*4))); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%画出不同半径圈上的角度插值误差
figure;semilogy(real(angle_rmse),'-b*');hold on;semilogy(imag(angle_rmse),'-ro');title(' 角度插值可见度实部与虚部误差');
%计算原始基线半径大小，并画出原始基线排列
uv_sample_unique = real(uv_radius_unique)/real(uv_to_pi)+1i*imag(uv_radius_unique)/imag(uv_to_pi);  %2pi归一化频率平面—uv平面坐标转换
radius_unique = abs(uv_sample_unique(:,1));
figure;stem(radius_unique,'fill');title('原始基线排列');
%根据门限，去掉一些靠的非常近的基线
radius_threshold = 0.2;     %基线半径门限阈值，小于该值的多条基线将只保留一条,单位：波长
uv_radius_nonredunt = uv_radius_unique(1,:);
v_radius_nonredunt =  v_radius_unique(1,:);
redundancy  = [redundancy_zero];
for k =1:1:(num_radius_unique)                               %去掉一些挨得非常近的同心圆      
    if radius_unique(k+1)-radius_unique(k)>radius_threshold  %半径阀值        
        uv_radius_nonredunt = [uv_radius_nonredunt;uv_radius_unique(k+1,:)];
        v_radius_nonredunt = [v_radius_nonredunt;v_radius_unique(k+1,:)];  
        redundancy = [redundancy,redundancy_unique(k+1,:)];
    end    
end
num_radius_nonredunt = size(uv_radius_nonredunt,1)-1;
%得到去冗余后的基线半径大小并画出
baseline_radius = real(uv_radius_nonredunt(:,1))/real(uv_to_pi)+1i*imag(uv_radius_nonredunt(:,1))/imag(uv_to_pi); 
figure;stem(abs(baseline_radius),'fill');title('去冗余后的基线排列');
visibility = v_radius_nonredunt;    
uvsample = uv_radius_nonredunt;
%半径去冗余完成-------------------------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%对角度插值后的同心圆uv采样计算每个采样点的面积，用于计算旋转圆环阵列的等效天线方向图
uvsample_real = real(uvsample)/real(uv_to_pi)+1i*imag(uvsample)/imag(uv_to_pi);  %2pi归一化频率平面—uv平面坐标转换
[uv_area_rotate,uv_sample_rotate] = uv_area_rotate_calc(uvsample_real);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 画出角度插值后的可见度函数模值分布
X = real(uvsample.');
Y = imag(uvsample.');
figure;h = pcolor(X,Y,abs(visibility.'));set( h, 'linestyle', 'none');title('角度插值后原始可见度模值分布');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% 径向插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PP_visibility = zeros(1,4*N*N);% 初始化插值后可见度
PP_uv_sample = zeros(1,4*N*N); % 初始化插值后uv采样平面
interp_rmse = zeros(4*N,N);
% 按照半径插值
for k = 1:4*N
    v_old = visibility(2:num_radius_nonredunt,k).';
    uvsample_old = uvsample(2:num_radius_nonredunt,k).';
    [v_new,uvsample_new]= PP_radius_interp(v_old,uvsample_old,N,visibility(1,k)); 
    %径向插值点的uv采样点坐标和精确可见度值，然后和插值可见度值对比，得到插值误差%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uv_sample_DFT = real(uvsample_new)/real(uv_to_pi)*real(uv_to_DFT)+1i*imag(uvsample_new)/imag(uv_to_pi)*imag(uv_to_DFT);
    V_DFT = Brute_Force_Transform_DFT(Tb_modify,real(uv_sample_DFT),imag(uv_sample_DFT))*d_xi*d_eta;
%         figure;plot(abs(uvsample_new(2:N)),real(v_new(2:N)),'-rs');hold on;plot(abs(uvsample_new(2:N)),real(V_DFT(2:N)),'-b*');hold on;
%         plot(abs(uvsample_old),real(v_old),'-go');title([num2str(k),'射线径向插值可见度与精确值实部']);
%         figure;plot(abs(uvsample_new(2:N)),imag(v_new(2:N)),'-rs');hold on;plot(abs(uvsample_new(2:N)),imag(V_DFT(2:N)),'-b*');
%         plot(abs(uvsample_old),imag(v_old),'-go');title([num2str(k),'射线径向插值可见度与精确值虚部']);         
    if k<=2*N
        interp_rmse(k,:) =v_new-V_DFT; %         
    else
        interp_rmse(k,2:N) =v_new(1:N-1)-V_DFT(1:N-1); %         
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    index_new = (k-1)*N+1:k*N;  %确定插值后的可见度序号    
    PP_visibility(index_new) = v_new;
    PP_uv_sample(index_new) = uvsample_new;   
end 
%画出伪极网格不同矩形方格上的径向插值误差
realpart = abs(real(interp_rmse));imagpart = abs(imag(interp_rmse));
mrealpart = mean(realpart,1);mimagpart = mean(imagpart,1);
figure;semilogy(mrealpart,'-b*');hold on;semilogy(mimagpart,'-ro');title('径向插值可见度实部与虚部误差');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
