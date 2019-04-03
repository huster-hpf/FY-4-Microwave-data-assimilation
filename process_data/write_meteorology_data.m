%edit by hongpengfei
%2018.10.31
function write_meteorology_data( dir_name,lat_num,lon_num,layer,time )
FormatString=repmat('%f ',1,lon_num);


%����Qv
Qvfile=sprintf('%s/%s/Qv.txt',dir_name,time);
fid=fopen(Qvfile);
GRAPESQv=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQv(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQv(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQv=GRAPESQv(1:251,451:701,:);

%����Qg
Qgfile=sprintf('%s/%s/Qg.txt',dir_name,time);
fid=fopen(Qgfile);
GRAPESQg=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQg(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQg(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQg=GRAPESQg(1:251,451:701,:);

%����Qi
Qifile=sprintf('%s/%s/Qi.txt',dir_name,time);
fid=fopen(Qifile);
GRAPESQi=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQi(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQi(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQi=GRAPESQi(1:251,451:701,:);

%����Qc
Qcfile=sprintf('%s/%s/Qc.txt',dir_name,time);
fid=fopen(Qcfile);
GRAPESQc=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQc(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQc(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQc=GRAPESQc(1:251,451:701,:);

%����Qr
Qrfile=sprintf('%s/%s/Qr.txt',dir_name,time);
fid=fopen(Qrfile);
GRAPESQr=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQr(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQr(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQr=GRAPESQr(1:251,451:701,:);

%����Qs
Qsfile=sprintf('%s/%s/Qs.txt',dir_name,time);
fid=fopen(Qsfile);
GRAPESQs=zeros(lat_num,lon_num,layer);
line=1;
GRAPESQs(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESQs(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESQs=GRAPESQs(1:251,451:701,:);

%����T
tfile=sprintf('%s/%s/t.txt',dir_name,time);
fid=fopen(tfile);
GRAPEST=zeros(lat_num,lon_num,layer);
line=1;
GRAPEST(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPEST(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPEST=GRAPEST(1:251,451:701,:);

%����H
hfile=sprintf('%s/%s/h.txt',dir_name,time);
fid=fopen(hfile);
GRAPESheight=zeros(lat_num,lon_num,layer);
line=1;
GRAPESheight(:,:,1)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line));
for i=2:layer
    GRAPESheight(:,:,i)=cell2mat(textscan(fid,FormatString,lat_num,'headerlines',line+2));
end
fclose(fid);
GRAPESheight=GRAPESheight(1:251,451:701,:);

%����TS
tsfile=sprintf('%s/%s/ts.txt',dir_name,time);
fid=fopen(tsfile);
GRAPESTSK=zeros(lat_num,lon_num);
GRAPESTSK(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESTSK=GRAPESTSK(1:251,451:701);

%����u10
u10file=sprintf('%s/%s/u10.txt',dir_name,time);
fid=fopen(u10file);
GRAPESU10=zeros(lat_num,lon_num);
GRAPESU10(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESU10=GRAPESU10(1:251,451:701);

%����v10
v10file=sprintf('%s/%s/v10.txt',dir_name,time);
fid=fopen(v10file);
GRAPESV10=zeros(lat_num,lon_num);
GRAPESV10(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESV10=GRAPESV10(1:251,451:701);



zsfile=sprintf('%s/%s/zs.txt',dir_name,time);
fid=fopen(zsfile);
GRAPESZS=zeros(lat_num,lon_num);
GRAPESZS(:,:)=cell2mat(textscan(fid,FormatString,501,'headerlines',1));
fclose(fid);
GRAPESZS=GRAPESZS(1:251,451:701);



%���?����Ϣ
lat=linspace(15,65,lat_num)';
GRAPESlat=repmat(lat,1,lon_num);
GRAPESlat=GRAPESlat(1:251,451:701);

%����γ����Ϣ
lon=linspace(70,145,lon_num);
GRAPESlon=repmat(lon,lat_num,1);
GRAPESlon=GRAPESlon(1:251,451:701);


%����ѹǿ��Ϣ
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
GRAPESP=GRAPESP(1:251,451:701,:);

%�����
load('/g3/wanghao/hpf/process_data/shanzhu/THETA.mat');

%����½�غ����־��Ϣ
load('/g3/wanghao/hpf/process_data/shanzhu/GRAPESLAND.mat');

%����RH��Ϣ
%load('/home/zl/Desktop/RH/meteorology_data.mat');
GRAPESRH=read_rh(GRAPESP,GRAPEST,GRAPESQv);

outdir=sprintf('/g3/wanghao/hpf/meteo_file/shanzhu/%s',time);
mkdir(outdir);
outfile=sprintf('%s/meteorology_data',outdir);
save(outfile,'GRAPESQv','GRAPESQg',...
             'GRAPESQi','GRAPESQc','GRAPESQr','GRAPESQs','GRAPEST',...
             'GRAPESheight','GRAPESTSK','GRAPESU10',...
             'GRAPESV10','GRAPESZS','GRAPESlat','GRAPESlon',...
             'GRAPESP','GRAPES_angles','GRAPESLAND','GRAPESRH');

    

