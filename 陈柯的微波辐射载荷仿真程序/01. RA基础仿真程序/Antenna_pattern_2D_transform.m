function  [Antenna_Pattern] = Antenna_pattern_2D_transform(Antenna_Pattern_old,Coordinate_x_old,Coordinate_y_old,Coordinate_x,Coordinate_y)

[Fov_x,Fov_y] = meshgrid(Coordinate_x,Coordinate_y);
[Fov_x_old,Fov_y_old] = meshgrid(Coordinate_x_old,Coordinate_y_old);
Antenna_Pattern = griddata(double(Fov_y_old),double(Fov_x_old),double(Antenna_Pattern_old),double(Fov_y),double(Fov_x));  
% figure;mesh(Antenna_Pattern_804);
% figure;mesh(Antenna_Pattern);
%对Antenna_Pattern中的NaN值进行补值处理
[num_row,num_col] = size(Antenna_Pattern);
for m = 1:1:num_row
    for n =  1:1:num_col
        if isnan(Antenna_Pattern(m,n))  
           Antenna_Pattern(m,n) = 7*1e-7;
        end
    end
end
% center_row = round(num_row/2); center_col = round(num_col/2);  
% for m = center_row:-1:1
%     for n = center_col:-1:1
%         if isnan(Antenna_Pattern(m,n))
%            if ~isnan(Antenna_Pattern(m,n+1))
%                Antenna_Pattern(m,n) = Antenna_Pattern(m,n+1);               
%            else
%                Antenna_Pattern(m,n) = Antenna_Pattern(m+1,n);
%            end
%         end
%     end
% end
% for m = center_row:-1:1
%     for n = center_col+1:1:num_col
%         if isnan(Antenna_Pattern(m,n))
%            if ~isnan(Antenna_Pattern(m,n-1))
%                Antenna_Pattern(m,n) = Antenna_Pattern(m,n-1);               
%            else
%                Antenna_Pattern(m,n) = Antenna_Pattern(m+1,n);
%            end
%         end
%     end
% end
% for m = center_row+1:1:num_row
%     for n = center_col:-1:1
%         if isnan(Antenna_Pattern(m,n))
%            if ~isnan(Antenna_Pattern(m,n+1))
%                Antenna_Pattern(m,n) = Antenna_Pattern(m,n+1);               
%            else
%                Antenna_Pattern(m,n) = Antenna_Pattern(m-1,n);
%            end
%         end
%     end
% end
% for m = center_row+1:1:num_row
%     for n = center_col+1:1:num_col
%         if isnan(Antenna_Pattern(m,n))
%            if ~isnan(Antenna_Pattern(m,n-1))
%                Antenna_Pattern(m,n) = Antenna_Pattern(m,n-1);               
%            else
%                Antenna_Pattern(m,n) = Antenna_Pattern(m-1,n);
%            end
%         end
%     end
% end


