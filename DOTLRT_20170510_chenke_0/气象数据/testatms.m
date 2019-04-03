load('TbMap-183.31-2012-10-29_06_12_00.mat');
A=TbMap;
load('TbMap-183.31-2012-10-29_06_12_00_interp.mat');
ATMS_=Tbmap(:,:,1);

load('angles_coords.mat')
load('validitymatrix.mat')

C=A.*validation_matrix;
h=pcolor(XLO',XLA',x');
        colorbar;

        axis image
        set(h,'linestyle','none')
        title(file)