function V_window = Visibility2D_add_window(uv,V,window_name)
%   函数功能：对二维可见度函数加窗功能**********************************
%             支持“rectwin”，“bartlett”，“blackman”，"hamming","hanning", 'circle blackman'六种窗类型
%  
%   输入参数:
%    uv             ：uv平面采样点坐标，对波长归一化          
%    V              ：未加窗可见度函数 
%    window_name    ：窗函数名称
%   输出参数：
%    V_window       : 加窗之后的可见度函数                                       
%   by 陈柯 2016.06.24  ******************************************************
   
   [num_v,num_u] = size(V);                %可见度函数行列数
   p_V = sqrt(real(uv).^2+imag(uv).^2);    %uv平面每个采样点到原点的距离
   w = zeros(num_v,num_u);                 %初始化窗函数 
   pmax = max(max(abs(uv),[],1));          %uv采样最大半径
   pmax_circle_blackman = pmax/sqrt(3);    %'circle blackman'窗设置的最大半径
   for n = 1:num_u
       for m= 1:num_v
           p = p_V(m,n);             
           switch lower(window_name)% 可见度函数加窗
             case 'rectwin',  w(m,n)=1; % 矩形窗                   
             case 'blackman', w(m,n)=0.42+0.5*cos(pi*p/pmax)+0.08*cos(2*pi*p/pmax); 
             case 'bartlett', w(m,n)=1-(p/pmax);
             case 'hamming',  w(m,n)=0.54+0.46*cos(pi*p/pmax); 
             case 'hanning',  w(m,n)=0.5+0.5*cos(pi*p/pmax);
             case 'circle blackman'     % 圆形blackman窗，见corbella 2012 年GRSL文章Reduction of secondary lobes in aperture synthesis radiometry
                  if p> pmax_circle_blackman
                     w(m,n)=0;
                  else
                     w(m,n)=0.42+0.5*cos(pi*p/pmax)+0.08*cos(2*pi*p/pmax); 
                  end
           end   
        end
   end
   V_window=V.*w; 
