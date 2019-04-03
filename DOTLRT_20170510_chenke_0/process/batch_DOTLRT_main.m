%edited by HPF
%2018.11.07

str_time=char('0000','0030','0100','0130','0200','0230','0300','0330','0400','0430','0500','0530',...
              '0600','0630','0700','0730','0800','0830','0900','0930','1000','1030','1100','1130',...
              '1200','1230','1300','1330','1400','1430','1500','1530','1600','1630','1700','1730',...
              '1800','1830','1900','1930','2000','2030','2100','2130','2200','2230','2300','2330');
str_time_saved=char('00_30','00_30','01_00','01_30','02_00','02_30','03_00','03_30','04_00','04_30','05_00','05_30',...
              '06_00','06_30','07_00','07_30','08_00','08_30','09_00','09_30','10_00','10_30','11_00','11_30',...
              '12_00','12_30','13_00','13_30','14_00','14_30','15_00','15_30','16_00','16_30','17_00','17_30',...
              '18_00','18_30','19_00','19_30','20_00','20_30','21_00','21_30','22_00','22_30','23_00','23_30');
str_day=char('08','09','10','11');
for i=1:4
    for j=1:48
            a=str_time(j,:);
            b=str_day(i,:);
            c=str_time_saved(i,:);
            time=sprintf('201707%s%s',b,a);
            time
            SOURCE_PATH=sprintf('/g3/wanghao/hpf/process_data/outfile/%s',time);                  %源文件目录  
            DST_PATH=sprintf('/g3/wanghao/hpf/DOTLRT_20170510_chenke_0/data_sq/%s/',intime);         %目的文件目录
            filename=sprintf('%s/meteorology_data.mat',SOURCE_PATH_t);
            movefile(filename,DST_PATH_t);
            DOTLRT_main 
            saved_dir=sprintf('/g3/wanghao/hpf/oudata_TB/%s',time);
            mkdir(saved_dir);
            out_PATH='/g3/wanghao/hpf/DOTLRT_20170510_chenke_0/data_sq/special';
            outfile=sprintf('%s/WRFTbMap-50.3.mat',out_PATH);
            savedfile=sprintf('%s/C1_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-51.76.mat',out_PATH);
            savedfile=sprintf('%s/C2_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-52.8.mat',out_PATH);
            savedfile=sprintf('%s/C3_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-5.596.mat',out_PATH);
            savedfile=sprintf('%s/C4_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-54.4.mat',out_PATH);
            savedfile=sprintf('%s/C5_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-54.94.mat',out_PATH);
            savedfile=sprintf('%s/C6_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-55.5.mat',out_PATH);
            savedfile=sprintf('%s/C7_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
            outfile=sprintf('%s/WRFTbMap-57.2.mat',out_PATH);
            savedfile=sprintf('%s/C8_2018-07-%s_%s_00',saved_dir,b,c);
            movefile(outfile,avedfile);
    end 
end