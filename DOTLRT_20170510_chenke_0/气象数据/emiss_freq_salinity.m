% [emissstokes,reflectstokes] = calcemis(freq_ghz,zenith,azimuth,surftype,skin,wind,salinity)

emis0=zeros(1,200);
emis35=zeros(1,200);
emis50=zeros(1,200);

zenith=0;
azimuth=0;
surftype=1;% 1 for sea surface, 0 for ground.
skin=[300,3.0 5.0 15.0 0.1 0.3]; % Skin temperature (K), 3.0 5.0 15.0 0.1 0.3 are fixed for ground surface.
wind=[0,0];% Wind U, Wind V (m/s)
%salinity (psu)
for f=1:200
    [a,~] = calcemis(f,zenith,azimuth,surftype,skin,wind,0);
    emis0(f)=a(2);
    [a,~] = calcemis(f,zenith,azimuth,surftype,skin,wind,35);
    emis35(f)=a(2);
    [a,~] = calcemis(f,zenith,azimuth,surftype,skin,wind,50);
    emis50(f)=a(2);
end

figure(1)

plot([emis0' emis35' emis50']);
legend('0','35','50')

figure(2)

plot([(emis0-emis35)' (emis50-emis35)']);
legend('0-35','50-35')
