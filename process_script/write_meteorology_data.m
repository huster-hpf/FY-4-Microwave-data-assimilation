%edit by hongpengfei
%2018.10.31
function write_meteorology_data( dir_name,lat_num,lon_num,layer,time )
FormatString=repmat('%f ',1,lon_num);

%处理Qv
Qvfile=sprintf('%s\\qv.txt',dir_name);
fid=fopen(Qvfile);
GRAPESQv=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQv(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQv(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQv=GRAPESQv(1:251,501:751,:);

%处理Qg
Qgfile=sprintf('%s\\qg.txt',dir_name);
fid=fopen(Qgfile);
GRAPESQg=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQg(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQg(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQg=GRAPESQg(1:251,501:751,:);

%处理Qi
Qifile=sprintf('%s\\qi.txt',dir_name);
fid=fopen(Qifile);
GRAPESQi=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQi(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQi(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQi=GRAPESQi(1:251,501:751,:);

%处理Qc
Qcfile=sprintf('%s\\qc.txt',dir_name);
fid=fopen(Qcfile);
GRAPESQc=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQc(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQc(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQc=GRAPESQc(1:251,501:751,:);

%处理Qr
Qrfile=sprintf('%s\\qr.txt',dir_name);
fid=fopen(Qrfile);
GRAPESQr=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQr(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQr(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQr=GRAPESQr(1:251,501:751,:);

%处理Qs
Qsfile=sprintf('%s\\qs.txt',dir_name);
fid=fopen(Qsfile);
GRAPESQs=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQs(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQs(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQs=GRAPESQs(1:251,501:751,:);

%处理T
tfile=sprintf('%s\\t.txt',dir_name);
fid=fopen(tfile);
GRAPEST=zeros(lat_num,lon_num,layer);
line=1;
GRAPEST(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPEST(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPEST=GRAPEST(1:251,501:751,:);

%处理H
hfile=sprintf('%s\\h.txt',dir_name);
fid=fopen(hfile);
GRAPESheight=zeros(lat_num,lon_num,layer);
line=1;
GRAPESheight(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESheight(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESheight=GRAPESheight(1:251,501:751,:);

%处理TSK
tsfile=sprintf('%s\\ts.txt',dir_name);
fid=fopen(tsfile);
GRAPESTSK=zeros(lat_num,lon_num);
GRAPESTSK(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESTSK=GRAPESTSK(1:251,501:751);

%处理u10
u10file=sprintf('%s\\u10.txt',dir_name);
fid=fopen(u10file);
GRAPESU10=zeros(lat_num,lon_num);
GRAPESU10(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESU10=GRAPESU10(1:251,501:751);

%处理v10
v10file=sprintf('%s\\v10.txt',dir_name);
fid=fopen(v10file);
GRAPESV10=zeros(lat_num,lon_num);
GRAPESV10(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESV10=GRAPESV10(1:251,501:751);

%处理经度信息
lat=linspace(15,65,lat_num)';
GRAPESlat=repmat(lat,1,lon_num);
GRAPESlat=GRAPESlat(1:251,501:751);

%处理纬度信息
lon=linspace(70,145,lon_num);
GRAPESlon=repmat(lon,lat_num,1);
GRAPESlon=GRAPESlon(1:251,501:751);


%处理压强信息
every_layer_P=[1000.000,975.0000,950.0000,925.0000,900.0000,850.0000,800.0000,750.0000,700.0000,650.0000,600.0000,...
               550.0000,500.0000,450.0000,400.0000,350.0000,300.0000,250.0000,200.0000,150.0000,100.0000,70.00000,...
               50.00000,30.00000,20.00000,10.00000];
GRAPESP=zeros(lat_num,lon_num,layer);
for row=1:lat_num
    for col=1:lon_num
        for i=1:layer
            GRAPESP(row,col,i)=every_layer_P(i);
        end
    end
end 
GRAPESP=GRAPESP(1:251,501:751,:);

%处理格点观测角
load('F:\matlab\maliya_观测角_陆地海洋flag\THETA.mat');

%处理陆地海洋标志信息
load('F:\matlab\maliya_观测角_陆地海洋flag\GRAPESLAND.mat');
GRAPESLAND=flip(GRAPESLAND);

% %处理RH信息
% load('/home/zl/Desktop/RH/meteorology_data.mat');
% GRAPESP=GRAPESP*100;
% [m,n,l]=size(GRAPESP);
% GRAPESP=reshape(GRAPESP,m*n*l,1);
% GRAPEST=reshape(GRAPEST,m*n*l,1);
% GRAPESQV=reshape(GRAPESQv,m*n*l,1);
% save GRAPESP.txt GRAPESP -ascii -double
% save GRAPEST.txt  GRAPEST -ascii -double
% save GRAPESQV.txt GRAPESQV -ascii -double
% command=['ncl m=',num2str(m),' n=',num2str(n),' l=',num2str(l),' /home/zl/Desktop/RH/rh_wrf_ncl.ncl'];
% system(command);
% RH=load('modelRHumidity.txt');
% GRAPESRH=reshape(RH,m,n,l);

outdir=sprintf('C:\\Users\\hust\\Desktop\\maliya_data\\%s',time);
mkdir(outdir);
outfile=sprintf('%s\\meteorology_data',outdir);
save(outfile,'GRAPESQv','GRAPESQg',...
             'GRAPESQi','GRAPESQc','GRAPESQr','GRAPESQs','GRAPEST',...
             'GRAPESheight','GRAPESTSK','GRAPESU10',...
             'GRAPESV10','GRAPESlat','GRAPESlon',...
             'GRAPESP','GRAPES_angles','GRAPESLAND');

    

