load('Earth_TA_q0_183.mat');
        TA2=flipud(TA);
%         TA2= (inv_T);
        row_pix = size(TA2,1); 
        col_pix = size(TA2,2);
       
        for p = 1:row_pix
        for q = 1:col_pix
            if TA2(p,q)<184
              
               TA2(p,q)=NaN;
              
           
            end
        end
        end
        
       
        figure();imagesc(TA2);