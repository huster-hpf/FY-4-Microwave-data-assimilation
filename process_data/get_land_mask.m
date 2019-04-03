GRBLAND=zeros(251,251);
LAT=LAT';
LON=LON';
LAND=LAND';
parfor m=1:251
    for n=1:251
        min_len=10;
        for i=1:1000
            for j=1:1000
                if(min_len>((LAT(i,j)-GRBLAT(m,n))^2+(LON(i,j)-GRBLON(m,n))^2))
                    min_len=(LAT(i,j)-GRBLAT(m,n))^2+(LON(i,j)-GRBLON(m,n))^2;
                    GRBLAND(m,n)=LAND(i,j);
                end
            end
        end
    end
end

                
          