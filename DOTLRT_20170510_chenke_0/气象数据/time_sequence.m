clear
getpath
datafile=[mainpath,datapath,wrfout];

QVapor = double(ncread(wrfout, 'QVAPOR'));
[nrow,ncol,nz,nt]=size(QVapor);
load([mainpath,datapath,'timetab'])

figure(1)

for i=1:nt
    figure(1)
    
    ivw=sum(QVapor(:,:,:,i),3);
    h=pcolor(ivw);
    set(h,'linestyle','none');
    colorbar;
    drawnow
    title(timetab(i,:));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    frame=getframe(gcf);
    im=frame2im(frame);%制作gif文件，图像必须是index索引图像
    [I,map]=rgb2ind(im,256);
    
    if i == 1;
        imwrite(I,map,['test.gif'],'gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(I,map,['test.gif'],'gif','WriteMode','append','DelayTime',0.1);
    end
    
    %pause(1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end