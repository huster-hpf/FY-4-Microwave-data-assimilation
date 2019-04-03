scene = 'TyphoonRammasun-20140716';
Payload = 'ATMS';
L2Filename = [Payload,'-L2-',scene,'.mat'];
WRFFilename = ['WRF-',Payload,'-',scene,'.mat'];

load([mainpath,meteorology_data_path,L2Filename])
L2_Pressure    = WRFP;
L2_QGraupel    = WRFQG;
L2_QIce        = WRFQI;
L2_QLiquidWater = WRFQL;
L2_QRain       = WRFQR;
L2_QSnow       = WRFQS;
L2_QWaterVaper = WRFQV;
L2_Temprature  = WRFT;

load([mainpath,meteorology_data_path,WRFFilename])


save([mainpath,datapath_sequence,'meteorology_data.mat'], 'WRFLAND','WRFP', 'WRFQG', 'WRFQI', 'WRFQL', ...
'WRFQR','WRFQS', 'WRFQV', 'WRFRH', 'WRFT','WRFTSK','WRFU10', 'WRFV10', 'WRFheight', 'WRFlat','WRFlon');