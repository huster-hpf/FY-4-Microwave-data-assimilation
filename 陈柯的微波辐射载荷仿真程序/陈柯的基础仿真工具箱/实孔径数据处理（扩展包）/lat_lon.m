function F=lat_lon(x,R,orbit_height,eta,xi)
F(1) = (R*cos(x(1)))-eta*sqrt((R+orbit_height-R*sin(x(1))*sin(x(2)))^2+R^2*(sin(x(1)))^2*(cos(x(2)))^2+R^2*(cos(x(1)))^2);
F(2) = (R*sin(x(1))*cos(x(2)))-xi*sqrt((R+orbit_height-R*sin(x(1))*sin(x(2)))^2+R^2*(sin(x(1)))^2*(cos(x(2)))^2+R^2*(cos(x(1)))^2);