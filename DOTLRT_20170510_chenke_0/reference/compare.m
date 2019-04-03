getpath
load([mainpath,referencepath,'TbMap-DOTLRT-AllPhases-54.4.mat'])
Tb_reference=rot90(TbMap(:,:,1),2);

load([mainpath,'3rd_data/','TbMap-DOTLRT-AllPhases-54.4.mat'])
Tb_lee_1=rot90(TbMap(:,:,1),2);

load([mainpath,'3rd_data/','TbMap-DOTLRT-AllPhases-54.4.mat'])
Tb_lee_2=rot90(TbMap(:,:,1),2);


    figure(1)
    
    subplot(4,2,1)
    h=pcolor(Tb_reference);
    colorbar;
    set(h,'linestyle','none')
    title('54.4G reference')
    
    subplot(4,2,2)
    h=pcolor(Tb_lee_1);
    colorbar;
    set(h,'linestyle','none')
    title('54.4G bandwith 400MHz')
    
    subplot(4,2,3)
    h=pcolor(Tb_lee_2);
    colorbar;
    set(h,'linestyle','none')
    title('54.4G bandwith 1000MHz')
    
    subplot(4,2,4)
    h=pcolor(abs(Tb_lee_2-Tb_lee_1));
    colorbar;
    set(h,'linestyle','none')
    title('error caused by bandwith')
    
    subplot(4,2,[5,6,7,8])
    h=pcolor(abs(Tb_reference-Tb_lee_1));
    colorbar;
    set(h,'linestyle','none')
    title('54.4G error between 400MHz & reference')
