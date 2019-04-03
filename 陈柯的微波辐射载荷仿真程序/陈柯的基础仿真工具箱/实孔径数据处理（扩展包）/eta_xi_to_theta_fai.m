function [THETA,FAI]=eta_xi_to_theta_fai(TB_channel,ETA,XI);
tic;
[row,col]=size(TB_channel);
x0=[0,0];
TB_channel(isnan(TB_channel)) = 0;
parfor m=1:row
    for n=1:col
        if TB_channel(m,n)~=0
            X=fsolve(@(x)theta_fai(x,ETA(m,n),XI(m,n)),x0);
            FAI(m,n)=X(1);
            THETA(m,n)=X(2);
        else
            THETA(m,n)=0/0;
            FAI(m,n)=0/0;
        end
    end
end
toc;