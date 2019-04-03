function [w] = Visibility2D_window_calc(uvsample,window_name)
%   函数功能：对二维可见度函数加窗功能**********************************
%             支持“rectwin”，“bartlett”，“blackman”，"hamming","hanning", 'circle blackman'六种窗类型
%  
%   输入参数:
%    uv             ：uv平面采样点坐标，对波长归一化          
%    window_name    ：窗函数名称
%   输出参数：
%    w              : 窗系数                                       
%   by 陈柯 2016.06.24  ******************************************************
   
   [num_v,num_u] = size(uvsample);               %可见度样本行列数
   p_V = sqrt(real(uvsample).^2+imag(uvsample).^2);    %uv平面每个采样点到原点的距离
   w = zeros(num_v,num_u);                 %初始化窗函数 
   pmax = max(max(abs(uvsample),[],1));          %uv采样最大半径
   pmax_circle_blackman = pmax/sqrt(3);    %'circle blackman'窗设置的最大半径
   for n = 1:num_u
       for m= 1:num_v
           p = p_V(m,n);             
           switch lower(window_name)% 可见度函数加窗
             case 'rectwin'  % 矩形窗
                   w(m,n)=1; 
             case 'gauss'    % 高斯窗                   
%                  w(m,n)=exp(-6.5*((p/pmax)^2));
                   alpha = 2.25;
                   w(m,n)=exp(-0.5*((alpha*p/pmax)^2));
             case 'blackman' % blackman窗
                   w(m,n)=0.42+0.5*cos(pi*p/pmax)+0.08*cos(2*pi*p/pmax); 
             case 'bartlett' % 巴莱特窗
                   w(m,n)=1-(p/pmax);
             case 'hamming'  % 汉明窗
                   w(m,n)=0.54+0.46*cos(pi*p/pmax); 
             case 'hanning'  % 汉宁窗
                   w(m,n)=0.5+0.5*cos(pi*p/pmax);
             case 'circle_blackman'     % 圆形blackman窗，见corbella 2012 年GRSL文章Reduction of secondary lobes in aperture synthesis radiometry
                  if p> pmax_circle_blackman
                     w(m,n)=0;
%                      plot(real(uvsample(m,n)),imag(uvsample(m,n)),'bo');hold on;
                  else
                     w(m,n)=0.42+0.5*cos(pi*p/pmax_circle_blackman)+0.08*cos(2*pi*p/pmax_circle_blackman);
%                      plot(real(uvsample(m,n)),imag(uvsample(m,n)),'ro');hold on;
                  end
           end   
        end
   end
  
   
