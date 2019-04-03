function yh=lagrange_interp(x,y,xh)
%   函数功能：  拉格朗日插值函数**********************************
%                   
%  
%   输入参数:
%   x               ：已有的数据坐标
%   y               ：已有的数据
%   xh              : 待插值的坐标
%   输出参数：
%   yh              ：插值得到的对应xh坐标的数据值%                          
%   by 陈柯 2016.06.24  ******************************************************
n = length(x);
m = length(xh);
x = x(:);
y = y(:);
xh = xh(:);
yh = zeros(m,1); 
c1 = ones(1,n-1);
c2 = ones(m,1);
for i=1:n,
  xp = x([1:i-1 i+1:n]);
  yh = yh + y(i) * prod((xh*c1-c2*xp')./(c2*(x(i)*c1-xp')),2);
end