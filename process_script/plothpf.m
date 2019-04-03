    max_Long = double((max(max(GRAPESlon))));
    min_Long = double((min(min(GRAPESlon))));
    max_Lat = double((max(max(GRAPESlat))));
    min_Lat = double((min(min(GRAPESlat))));
    
    
    figure;%按照miller平面投影画出地球陆地轮廓
    axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on; 
    load coast;plotm(lat,long,'-k','LineWidth', 1.8);%画世界陆地界线
    ylabel('纬度(\circ)');xlabel('经度（\circ）');hold on; 
%     title('ch27-183.31±3GHz');
%     ATMSTitleName=sprintf('ATMS-TB-%s-%s',frequency,ATMS_time);
    h=pcolorm(double(GRAPESlat), double(GRAPESlon), double((TA(:,:)))); set(h,'edgecolor','none');colormap jet;colorbar;  %画出ATMS亮温   
%        caxis([T_min, T_max]) ;
