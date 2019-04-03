function [TB_out,surfheight_out,surftype_out,lat_out,lon_out]=process_tb(file_dir,chan,row,col,out_dir)
%editd by HPF
%2018.11.09
%file_dir 文件存放的位置


lat_file=sprintf('%s\\lat.txt',file_dir);
lon_file=sprintf('%s\\lon.txt',file_dir);
latlon_file=sprintf('%s\\latlon\\coords',out_dir);
Xbtb_file=sprintf('%s\\Xbtb.txt',file_dir);
surfheight_file=sprintf('%s\\surfheight.txt',file_dir);
surftype_file=sprintf('%s\\surftype.txt',file_dir);

lat=load(lat_file);
lon=load(lon_file);
Xbtb=load(Xbtb_file);
surfheight=load(surfheight_file);
surftype=load(surftype_file);


TB_out=zeros(row,col,chan);
surfheight_out=zeros(row,col,chan);
surftype_out=zeros(row,col,chan);
lat_out=zeros(row,col,chan);
lon_out=zeros(row,col,chan);
[nobs,chan_simu]=size(Xbtb);

for i=1:chan
    for j=1:nobs
        if (Xbtb(j,i)==0)
            break;
        end
        row_tb=round((lat(j,i)-15)/0.1+1);
        col_tb=round((lon(j,i)-120)/0.1+1);
        TB_out(row_tb,col_tb,i)=Xbtb(j,i);
        lat_out(row_tb,col_tb,i)=lat(j,i);
        lon_out(row_tb,col_tb,i)=lon(j,i);
        surfheight_out(row_tb,col_tb,i)=surfheight(j,i);
        surftype_out(row_tb,col_tb,i)=surftype(j,i);
    end
end


for i=1:chan
    TbMap=TB_out(:,:,i);
    XLA=lat_out(:,:,i);
    XLO=lon_out(:,:,i);
    Tb_file=sprintf('%s\\C%d_2018-03-07_00_00_00',out_dir,i);
    save(Tb_file,'TbMap');
    save(latlon_file,'XLA','XLO');
end







