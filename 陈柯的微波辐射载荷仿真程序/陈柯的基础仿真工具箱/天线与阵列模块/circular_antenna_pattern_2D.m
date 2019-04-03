function  Antenna_G = circular_antenna_pattern_2D(Fov_scope,N_y,N_x,Ba,taper)
%本函数实现圆形口径天线的归一化二维方向图计算
%Fov_scope：要计算的方向图范围，单位：角度；N_y,N_x：两维计算的方向图点数；Ba：天线参数pi*口径/波长；taper：口径照射系数
   
   Antenna_G = zeros(N_y,N_x);
   pix_angle_y = linspace(Fov_scope(1,1),Fov_scope(1,2),N_y);   %纬度空间坐标，单位：角度
   pix_angle_x = linspace(Fov_scope(2,1),Fov_scope(2,2),N_x);   %经度空间坐标，单位：角度
   
   for num_row = 1:N_y
        for num_col = 1: N_x
            %点的位置
            pix_point = pix_angle_x(num_col)+1i*pix_angle_y(num_row);
            if (abs(pix_point/90)<=1)
                theta = abs(pix_point);
                %计算指向对应方位的视场范围内的辐射计天线方向图 
               if(sind(theta)<=1e-6)  %避免分母为0时出错
                   Antenna_G(num_row,num_col) = 1;
               else
                   Antenna_G(num_row,num_col) = abs((2^(taper+1)* factorial(taper+1)*besselj(taper+1,(Ba*sind(abs(theta))))/((Ba*sind(abs(theta)))^(taper+1)))^2);
               end
            end
        end
   end
   
   Antenna_G=Antenna_G/sum(sum(Antenna_G));