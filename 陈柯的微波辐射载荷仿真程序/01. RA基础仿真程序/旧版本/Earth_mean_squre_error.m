        clear
        tic
        load('Earth.mat');
        TA1= flipud(pic);
%         TA1=pic;

        load('Earth_TA_q0_60_HighResolution.mat');
        TA2=flipud(TA);
%         TA2= (inv_T);
        row_pix = size(pic,1); 
        col_pix = size(pic,2);
        sum=0;
        count=0;
        delta_TA=zeros(row_pix,col_pix);
        for p = 1:row_pix
        for q = 1:col_pix
            if TA2(p,q)<184
               TA1(p,q)=NaN;
               TA2(p,q)=NaN;
               delta_TA(p,q)=NaN;
            else
               delta_TA(p,q)=TA1(p,q)-TA2(p,q);
               sum=sum+delta_TA(p,q)^2;
               count=count+1;
            end
        end
        end
        
        figure();imagesc(TA1);
        figure();imagesc(TA2);
        figure();imagesc(delta_TA);
        MSE=sqrt(sum/(count-1))
        
%        