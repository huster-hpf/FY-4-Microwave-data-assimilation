function F=theta_fai(x,eta,xi)
F(1) = sind(x(1))*sind(x(2))-xi;
F(2) = sind(x(1))*cosd(x(2))-eta;