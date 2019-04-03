getpath
XLAT = ncread(wrfout,'XLAT');
XLA= XLAT(:,:,1);

XLONG = ncread(wrfout,'XLONG');
XLO = XLONG(:,:,1);

save('coord.mat','XLA','XLO')

% figure(1)
% for i=1:97
% XLAT = ncread(wrfout,'XLAT');
% XLA = XLAT(:,:,i);
% 
% XLONG = ncread(wrfout,'XLONG');
% XLO = XLONG(:,:,i);
% 
% plot(XLO,XLA,'*');
% pause(0.2)
% 
% end