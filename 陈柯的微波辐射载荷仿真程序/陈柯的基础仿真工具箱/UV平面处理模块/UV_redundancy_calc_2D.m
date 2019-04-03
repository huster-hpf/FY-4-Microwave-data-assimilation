function redundancy_sum = UV_redundancy_calc_2D(UVsample,ant_pos)
%   函数功能：计算可见度uv平面各个采样点的冗余度，并计算其倒数和**********************************
%            用于计算综合孔径辐射计灵敏度
%   输入参数:
%    UVsample       ：零冗余的uv采样点坐标         
%    ant_pos        ：天线阵列所有阵元位置 
%
%   输出参数：
%    redundancy_sum : 所有uv采样点冗余度的倒数和
%   by 陈柯 2016.06.24  ******************************************************


threshold = 1e-4;   % 用于判断是否冗余的极小数门限
ant_num = size(ant_pos,2);
redundancy=zeros(1,length(UVsample));
U_coordinate = real(UVsample);
V_coordinate = imag(UVsample);
redundancy_sum=0;

% 得到uv平面点的可见度分布
for p = 1:ant_num
    for q = 1:ant_num
        u =real(ant_pos(p)-ant_pos(q));
        v =imag(ant_pos(p)-ant_pos(q));
        position = find(abs(U_coordinate-u)<threshold & abs(V_coordinate-v)<threshold);
        redundancy(position) = redundancy(position)+1;
    end
end
% figure;stem(redundancy);  %画出基线的冗余度分布
% 计算各采样点冗余度倒数和
for k = 1:length(UVsample)
    if 0 ~= redundancy(k)
        redundancy_sum = redundancy_sum+1/redundancy(k);
    end
end
