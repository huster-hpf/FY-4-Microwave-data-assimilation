%%%%%%%%%%%%%%%%%%%%%%%%%%%%%角度误差修正仿真%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%标志位设置%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_save=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%参数设置%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freq =50.3e9;                                       %instrment center frequency，unit:Hz
freq_highest=183.3e9;
c=3e8;                                              %speed of light unit m/s

wavelength=c/freq;                                  %wave length unit:m
wavelength_highest=c/freq_highest;  

R = 6371;                                           %earth radius unit:km
height_orbit = 824;                                 %orbit high：km
antenna_diameter=0.146;                             %antenna diameter（refer to GEM, 2m Cassegrain）
q=0;                                                % the illumination taper //by thesis of G.M.Skofronick

bandwith = 1000*10^6;                               % radiometer receiver band width, unit:Hz
integral_time = 20*10^(-3);                         % radiometer integration time, unit:S
noise_figure= 5;                                    % radiometer receiver noise figure, unit:dB
T_rec=290*(10^(noise_figure/10)-1);                 % radiometer receiver noise temperature, unit:K
sampling_num = floor(bandwith*integral_time);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%读取wlf图像与经纬度信息%%%%%%%%%%%%%%%%%%%%%%%%%
worf_latlon_path = 'F:\实孔径辐射计仿真-陈柯（2）\新建文件夹';     
matfile = sprintf('%s\\other_data.mat',worf_latlon_path);                       %other_data包含亮温tb每一个亮温的经纬度信息，分别为XLAT,XLONG
load(matfile);
matfile = sprintf('%s\\TbMap-50.3-2012-10-29_06_10_00.mat',worf_latlon_path);   %读取wlf图像Tbmap
load(matfile);
Tb = TbMap(:,:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%读取ATMS实际扫描位置与角度%%%%%%%%%%%%%%%%%%%%%%%
worf_latlon_path = 'F:\实孔径辐射计仿真-陈柯（2）\新建文件夹';     
matfile = sprintf('%s\\atms_data.mat',worf_latlon_path);                        %Lat,Long为扫描经纬度，SateZenith_angle为该位置的扫描角度，该角度为扫描波束方向与垂线之间的夹角
load(matfile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%初始化%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[TA_num_Latitude,TA_num_Longitude] = size(Long);                                %TA坐标
[num_Latitude,num_Longitude] = size(XLONG);                                     %TB坐标
TA=zeros(TA_num_Latitude,TA_num_Longitude);                                     %初始化TA
error_matrix = zeros(TA_num_Latitude,TA_num_Longitude);                         %初始化观测误差矩阵
var_matrix= zeros(TA_num_Latitude,TA_num_Longitude);  
Ba = pi*antenna_diameter/wavelength;                                            %天线电长度参数
factor=50.3e9/freq*2/antenna_diameter;

switch q
    case 0
    null_beam_width=0.187*factor;
    case 1
    null_beam_width=0.251*factor;
    case 2
    null_beam_width=0.312*factor;
    case 3
    null_beam_width=0.371*factor;
    case 4
    null_beam_width=0.428*factor;
end

matlabpool open 3;
parfor num_sample_Latitude=1:TA_num_Latitude
    for num_sample_Longitude=1:TA_num_Longitude  

pattern = zeros(num_Latitude,num_Longitude);                                                                %初始化方向图
a = SateZenith_angle(num_sample_Latitude,num_sample_Longitude)*pi/180;                                      %指定经纬度的卫星扫描角度
b = 0;                                                                                                      %波束指向与卫星行进方向的夹角，交轨扫描方式下此处为0
Latitude_start = Lat(num_sample_Latitude,num_sample_Longitude);                                             %获取亮温TA经度信息
Longitude_start= Long(num_sample_Latitude,num_sample_Longitude);                                            %获取亮温TA纬度信息
if (min(min(Lat))<Latitude_start)&& (Latitude_start<max(max(Lat))) && (min(min(Long))<Longitude_start)&&(Longitude_start<max(max(Long))      %取TB与扫描经纬度共区域的点进行计算
for num_row = 1:num_Latitude
        for num_col = 1: num_Longitude
            Latitude_end   = XLAT(num_row,num_col);                                                         %获取亮温TB的经度信息
            Longitude_end  = XLONG(num_row,num_col);                                                        %获取亮温TB的纬度信息

            X1 = R*acos(sind(Latitude_start)*sind(Latitude_start) + cosd(Latitude_start)*cosd(Latitude_start)*cosd(Longitude_start-Longitude_end));     %将经纬度转换为距离
            Y1 = R*acos(sind(Latitude_start)*sind(Latitude_end) + cosd(Latitude_start)*cosd(Latitude_end)*cosd(Longitude_start-Longitude_start));       

            angle_Longitude = X1/height_orbit*180/pi;                                                       
            angle_Latitude =  Y1/height_orbit*180/pi;
                        
            Xs = height_orbit*tan(a)*cos(b);                                                                %转换为距离
            Ys = height_orbit*tan(a)*sin(b);
%坐标转换%            
            Xp = ((X1*Ys-Xs*Y1)*sin(b)+X1*height_orbit*cot(a))/((Xs-X1)*cos(b)+(Ys-Y1)*sin(b)+height_orbit*cot(a));
            Yp = ((Xs*Y1-X1*Ys)*cos(b)+Y1*height_orbit*cot(a))/((Xs-X1)*cos(b)+(Ys-Y1)*sin(b)+height_orbit*cot(a));
            Zp = -(height_orbit*X1*cos(b)+Y1*height_orbit*sin(b))/((Xs-X1)*cos(b)+(Ys-Y1)*sin(b)+height_orbit*cot(a));
            r = sqrt(Xp^2+Yp^2+Zp^2);
            theta = acot(height_orbit/r)*180/pi;                                                            %转换为观测角
            
           if theta<(3*null_beam_width) 
                if(sind(theta)<=0.00001)  %避免分母为0时出错
                pattern(num_row,num_col) = 1;
                else
                pattern(num_row,num_col) = abs((2^(q+1)* factorial(q+1)*besselj(q+1,(Ba*sind(abs(theta))))/((Ba*sind(abs(theta)))^(q+1)))^2);
                end
           end
        end
end
end

 Antenna_pattern=pattern/sum(sum(pattern));
 
 TA(num_sample_Latitude,num_sample_Longitude)=sum(sum(Tb.* Antenna_pattern));
    end
end
matlabpool close;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%添加观测噪声%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for m=1:TA_num_Latitude
    for n=1:TA_num_Longitude  
    var_matrix(m,n)=(TA(m,n)+T_rec)^2/sampling_num;
    error_matrix(m,n) = randn(1,1)*sqrt(var_matrix(m,n));
    end
end
TA_real=TA+error_matrix;

figure;imagesc(TA);axis equal;xlabel('经度方向'); ylabel('纬度方向');title(['角度修正后的观测图像TA']);colorbar;

FileName1 = sprintf('angle_correct_result');
MatFileName1 = sprintf('%s.mat', FileName1);
if flag_save==1
   save (MatFileName1, 'TA', 'TA_real')
end
toc;