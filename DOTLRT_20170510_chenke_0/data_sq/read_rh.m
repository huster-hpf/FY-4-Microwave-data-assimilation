load('/home/zl/Desktop/RH/meteorology_data.mat');
GRAPESP=GRAPESP*100;
[m,n,l]=size(GRAPESP);
GRAPESP=reshape(GRAPESP,m*n*l,1);
GRAPEST=reshape(GRAPEST,m*n*l,1);
GRAPESQV=reshape(GRAPESQv,m*n*l,1);
save GRAPESP.txt GRAPESP -ascii -double
save GRAPEST.txt  GRAPEST -ascii -double
save GRAPESQV.txt GRAPESQV -ascii -double

command=['ncl m=',num2str(m),' n=',num2str(n),' l=',num2str(l),' /home/zl/Desktop/RH/rh_wrf_ncl.ncl'];
system(command);
RH=load('modelRHumidity.txt');
GRAPESRH=reshape(RH,m,n,l);
