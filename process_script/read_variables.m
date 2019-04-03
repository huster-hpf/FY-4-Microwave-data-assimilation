clc;
nc=ncgeodataset('C:\Users\ai\Desktop\maliya\rmf.gra.2018070800012.grb2')
variables_nums=nc.variables;

% 处理高度变量
GRBheight_geo=nc.geovariable('Geopotential_height_isobaric');
GRBheight_data=GRBheight_geo.data('1,:,:,:');
GRBheight=squeeze(GRBheight_data);
for n=1:30
    GRBHeight(:,:,n)=GRBheight(n,:,:);
end
GRBHeight=GRBHeight(251:501,501:751,:);
clear GRBheight_geo GRBheight_data GRBheight;

% 处理陆地海洋标志,有待改写
load D:\matlab\dotrt_bianliang\lan_ocean_maliya.mat;

% 处理纬度信息
GRBlat_geo=nc.geovariable('lat');
GRBlat_data=GRBlat_geo.data(':,1');
GRBlat=squeeze(GRBlat_data);
GRBLAT=repmat(GRBlat,1,751);
GRBLAT=GRBLAT(251:501,501:751);
clear GRBlat_geo GRBlat_data GRBlat;

%处理经度信息
GRBlon_geo=nc.geovariable('lon');
GRBlon_data=GRBlon_geo.data(':,1');
GRBlon=squeeze(GRBlon_data);
GRBLON=repmat(GRBlon,1,501);
GRBLON=GRBLON';
GRBLON=GRBLON(251:501,501:751);
clear GRBlon_geo GRBlon_data GRBlon;

%处理压强信息
GRBp=[1000,975,950,925,900,850,800,750,700,650,...
        600,550,500,450,400,350,300,275,250,225,...
        200,175,150,125,100,70,50,30,20,10]
for row=1:501
    for col=1:751
        for h=1:30
            GRBP(row,col,h)=GRBp(h);
        end
    end
end
clear GRBp;

%处理雹信息
GRBg_geo=nc.geovariable('Graupel_snow_pellets_isobaric');
GRBg_data=GRBg_geo.data('1,:,:,:');
GRBg=squeeze(GRBg_data);
for n=1:30
    GRBG(:,:,n)=GRBg(n,:,:);
end
GRBG=GRBG(251:501,501:751,:);
clear GRBg_geo GRBg_data GRBg;

%处理冰信息
GRBi_geo=nc.geovariable('Ice_water_mixing_ratio_isobaric');
GRBi_data=GRBi_geo.data('1,:,:,:');
GRBi=squeeze(GRBi_data);
for n=1:30
    GRBI(:,:,n)=GRBi(n,:,:);
end
GRBI=GRBI(251:501,501:751,:);
clear GRBi_geo GRBi_data GRBi;

%处理云水信息
GRBl_geo=nc.geovariable('Cloud_mixing_ratio_isobaric');
GRBl_data=GRBl_geo.data('1,:,:,:');
GRBl=squeeze(GRBl_data);
for n=1:30
    GRBL(:,:,n)=GRBl(n,:,:);
end
GRBL=GRBL(251:501,501:751,:);
clear GRBl_geo GRBl_data GRBl;

%处理雨水信息
GRBr_geo=nc.geovariable('Rain_mixing_ratio_isobaric');
GRBr_data=GRBr_geo.data('1,:,:,:');
GRBr=squeeze(GRBr_data);
for n=1:30
    GRBR(:,:,n)=GRBr(n,:,:);
end
GRBR=GRBR(251:501,501:751,:);
clear GRBr_geo GRBr_data GRBr;

%处理雪信息
GRBs_geo=nc.geovariable('Snow_mixing_ratio_isobaric');
GRBs_data=GRBs_geo.data('1,:,:,:');
GRBs=squeeze(GRBs_data);
for n=1:30
    GRBS(:,:,n)=GRBs(n,:,:);
end
GRBS=GRBS(251:501,501:751,:);
clear GRBs_geo GRBs_data GRBs

%处理比湿信息
GRBv_geo=nc.geovariable('Specific_humidity_isobaric');
GRBv_data=GRBv_geo.data('1,:,:,:');
GRBv=squeeze(GRBv_data);
for n=1:30
    GRBV(:,:,n)=GRBv(n,:,:);
end
GRBV=GRBV(251:501,501:751,:);
clear GRBv_geo GRBv_data GRBv

%处理水汽信息
GRBrh_geo=nc.geovariable('Relative_humidity_isobaric');
GRBrh_data=GRBrh_geo.data('1,:,:,:');
GRBrh=squeeze(GRBrh_data);
for n=1:30
    GRBRH(:,:,n)=GRBrh(n,:,:);
end
GRBRH=GRBRH(251:501,501:751,:);
clear GRBrh_geo GRBrh_data GRBrh

%处理温度信息
GRBt_geo=nc.geovariable('Temperature_isobaric');
GRBt_data=GRBt_geo.data('1,:,:,:');
GRBt=squeeze(GRBt_data);
for n=1:30
    GRBT(:,:,n)=GRBt(n,:,:);
end
GRBT=GRBT(251:501,501:751,:);
clear GRBt_geo GRBt_data GRBt

%处理TSK信息
GRBtsk_geo=nc.geovariable('Temperature_surface');
GRBtsk_data=GRBtsk_geo.data(':,:');
GRBTSK=squeeze(GRBtsk_data);
GRBTSK=GRBTSK(251:501,501:751);
clear GRBtsk_geo GRBtsk_data n

%处理地表风场信息
GRBu10_geo=nc.geovariable('u-component_of_wind_height_above_ground');
GRBu10_data=GRBu10_geo.data(':,:');
GRBU10=squeeze(GRBu10_data);
GRBU10=GRBU10(251:501,501:751);
clear GRBu10_geo GRBu10_data

GRBv10_geo=nc.geovariable('v-component_of_wind_height_above_ground');
GRBv10_data=GRBv10_geo.data(':,:');
GRBV10=squeeze(GRBv10_data);
GRBV10=GRBV10(251:501,501:751);
clear GRBv10_geo GRBv10_data














    