function [uvsample,redundancy,uv_area] = Visibility2D_uvsample_nonredunt(uvsample_redunt,array_type,ant_pos,N)
%   函数功能：去除UV平面冗余采样点，得到冗余平均可见度和冗余参数**********************************% 
%             如果是均匀圆环阵列，还会计算每个uv采样格点的面积
%  
%   输入参数:
%    V_redunt       ：冗余的可见度函数 
%    uvsample_redunt：冗余的uv采样平面坐标
%    array_type     ：阵列类型
%    ant_pos        ：天线位置
%   输出参数：
%    V_nonredunt    : 冗余平均后的可见度函数 
%    uvsample       : 去冗余后的uv采样平面坐标，与V_nonredunt位置对应
%    redundancy_sum : 冗余系数，即每个采样点冗余度的倒数和 
%    uv_area        : 每个uv采样格点的面积，只对均匀圆环阵列有意义
%   by 陈柯 2016.06.24  ******************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%旋转圆环阵列使用角度插值后的uvsample
if (strcmpi('O_Rotate_shape',array_type))   
    %%%%%%%%%%对uv采样半径进行排序，从小到大取出相同半径的可见度和采样分布
    uvsample_radius=mean(abs(uvsample_redunt),2);             %uv采样同心圆的半径
    [num_radius,num_theta] = size(uvsample_redunt);           %半径数和每圈角度数，这里的半径数有冗余 
    uvsample_radius_sorted = zeros(num_radius,num_theta);
    [sorted_radius,radius_index]=sort(uvsample_radius);       %对半径排序
    for k=1:1:num_radius                                      %根据半径顺序，排序可见度和uv采样分布
        uvsample_radius_sorted(k,:)=uvsample_redunt(radius_index(k),:);
    end
    uvsample = uvsample_radius_sorted;
    %排序完成-
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 角度插值 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 初始化角度插值后可见度与uv采样平面
    PP_theta_interp_uvsample = zeros(num_radius,N*4);
    redundancy_zero = 0;                                             
    % 每一圈都插值到同样的角度上
    for k = 1:num_radius    
        uvsample_old = uvsample(k,:);    
        if abs(uvsample_old(1)==0)                                     %中心零点处       
           uvsample_new = zeros(1,N*4);
           redundancy_zero = redundancy_zero+num_theta;               %零基线的冗余度
        else    
           [uvsample_new] = PP_theta_uvsample(uvsample_old,N); %对每圈进行角度插值
        end   
       PP_theta_interp_uvsample(k,:) = uvsample_new;    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%对同一半径的相同角度的可见度函数值进行冗余平均，然后去掉一些挨得非常近的同心圆
    radius_redunt=sorted_radius;                        %排序后的uv采样半径
    uvlength=UV_unique(radius_redunt);                  %去冗余之后得到不同的半径大小
    num_radius_unique = length(uvlength)-1;             %不同半径的数量
    uv_radius_unique = zeros(num_radius_unique+1,N*4);  
    redundancy_unique = zeros(num_radius_unique+1,N*4);
    for k =1:1:(num_radius_unique+1)                    %对同一半径的同心圆采样点进行平均，因为角度值相同
        index_number=[abs(radius_redunt-uvlength(k))<1e-4];
        uv_radius_unique(k,:) = mean(PP_theta_interp_uvsample(index_number,:),1);
        redundancy_unique(k,:) = sum(index_number)*ones(1,N*4);
    end
    %根据门限，去掉一些靠的非常近的基线
    radius_unique = mean(abs(uv_radius_unique),2);
    radius_threshold = 0.2;     %基线半径门限阈值，小于该值的多条基线将只保留一条,单位：波长
    uv_radius_nonredunt = [uv_radius_unique(1,:)];
    redundancy  = [redundancy_zero];
    for k =1:1:(num_radius_unique)                               %去掉一些挨得非常近的同心圆      
        if radius_unique(k+1)-radius_unique(k)>radius_threshold  %半径阀值          
            uv_radius_nonredunt = [uv_radius_nonredunt;uv_radius_unique(k+1,:)];
            redundancy = [redundancy,redundancy_unique(k+1,:)];
        end    
    end
    % baseline_radius = real(uv_radius_nonredunt(:,1))/real(uv_to_pi)+1i*imag(uv_radius_nonredunt(:,1))/imag(uv_to_pi); 
    % % figure;stem(abs(baseline_radius),'fill');title('去冗余后的基线排列');
    %半径去冗余完成-------------------------------------------------------------
    %对角度插值后的同心圆uv采样计算每个采样点的面积，用于计算旋转圆环阵列的等效天线方向图
    [uv_area,uvsample] = uv_area_rotate_calc(uv_radius_nonredunt);    
    
%%%%%%%%%%%%%%%%%%%%%%%%%圆环阵列去冗余采样点及可见度函冗余平均
else if (strcmpi('O_shape',array_type))     
        [uvsample,uv_area] = UVCellforCDFT(ant_pos);
        num_redunt = size(uvsample_redunt);
        redundancy = zeros(1,length(uvsample));    
        threshold = 1e-6;    
        for k = 1:1:num_redunt
            u = real(uvsample_redunt(k));
            v = imag(uvsample_redunt(k));
            position = find(abs(real(uvsample)-u)<threshold & abs(imag(uvsample)-v)<threshold);
            redundancy(position) = redundancy(position)+1;
        end                    
     
%%%%%%%%%%%%%%%%%%%%%%%%%其它均匀网格采样阵列去冗余采样点及可见度函冗余平均        
    else                                     
        uvsample=UV_unique(uvsample_redunt);
        num_redunt = size(uvsample_redunt);
        redundancy = zeros(1,length(uvsample));    
        threshold = 1e-6;    
        for k = 1:1:num_redunt
            u = real(uvsample_redunt(k));
            v = imag(uvsample_redunt(k));
            position = find(abs(real(uvsample)-u)<threshold & abs(imag(uvsample)-v)<threshold);
            redundancy(position) = redundancy(position)+1;            
        end                                   
     end
end





