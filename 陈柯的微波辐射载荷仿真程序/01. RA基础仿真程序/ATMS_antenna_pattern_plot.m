load('ATMS_form_2.2.mat'); 
figure;plot(ATMS_form(:,1),ATMS_form(:,2));
num_angle = size(ATMS_form,1);
angle_coordinate = ATMS_form((num_angle-1)/2+1:num_angle,1);
Antenna_Patter = 10.^(ATMS_form((num_angle-1)/2+1:num_angle,2)/10);
Antenna_Patter = Antenna_Patter/sum(Antenna_Patter); 
Antenna_Patter=Antenna_Patter/max(Antenna_Patter); 
figure;plot(angle_coordinate,Antenna_Patter);
