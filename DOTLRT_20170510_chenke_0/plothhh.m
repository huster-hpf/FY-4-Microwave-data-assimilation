
    max_Long = double((max(max(WRFlon))));
    min_Long = double((min(min(WRFlon))));
    max_Lat = double((max(max(WRFlat))));
    min_Lat = double((min(min(WRFlat))));
    
    
    figure;%按照miller平面投影画出地球陆地轮廓
    axesm('miller','MapLatLimit',[min_Lat max_Lat],'MapLonLimit',[min_Long max_Long]);framem;  mlabel on;  plabel on;  gridm on; 
    load coast;plotm(lat,long,'-k','LineWidth', 1.8);%画世界陆地界线
    ylabel('纬度(\circ)');xlabel('经度（\circ）');hold on; 
    title('165.5GHz');
%     ATMSTitleName=sprintf('ATMS-TB-%s-%s',frequency,ATMS_time);
    h=pcolorm(double(WRFlat), double(WRFlon), double(TbMap(:,:,1))); set(h,'edgecolor','none');colormap jet;colorbar;  %画出ATMS亮温   
%        caxis([T_min, T_max]) ;

