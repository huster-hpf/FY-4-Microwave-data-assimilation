function [angle_x,angle_y]=eta_xi_to_theta_fai(TB,ETA,XI);
tic;
[row,col]=size(TB);
TB(isnan(TB)) = 0;
angle_x=zeros(row,col);
angle_y=zeros(row,col);
parfor m=1:row
    for n=1:col
        if TB(m,n)~=0
            angle_x(m,n)=asind(ETA(m,n));
            angle_y(m,n)=asind(XI(m,n));
        else
            angle_x(m,n)=0/0;
            angle_y(m,n)=0/0;
        end
    end
end
toc;