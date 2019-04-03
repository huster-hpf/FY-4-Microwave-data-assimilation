function wrf_angle=angle_to_angle(theta_scene,r,h)
wrf_angle=zeros(251,251);
for m=1:251
    for n=1:251
        wrf_angle(m,n)=asind(((r+h)/r)*sind(theta_scene(m,n)));
    end
end