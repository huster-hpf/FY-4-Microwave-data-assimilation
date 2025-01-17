%edited by HPF
%2018.11.27

str_time=char('0000','0030','0100','0130','0200','0230','0300','0330','0400','0430','0500','0530',...
              '0600','0630','0700','0730','0800','0830','0900','0930','1000','1030','1100','1130',...
              '1200','1230','1300','1330','1400','1430','1500','1530','1600','1630','1700','1730',...
              '1800','1830','1900','1930','2000','2030','2100','2130','2200','2230','2300','2330');
str_day=char('08','09','10','11');



frequent_sq_1=char('23.8','31.4','50.3','51.76','52.8','53.618','54.4','54.94','55.5',...
				   '57.29','57.8292','57.6602','57.6342','57.6222','57.6167',...
				   '88.2','165.5','190.31','187.81','186.31','185.11','184.31');


frequent_sq_2=char('23.8','31.4','50.3','51.76','52.8','53.618','54.4','54.94','55.5',...
				   '57.29','57.3952','57.5642','57.5902','57.6022','57.6077',...
				   '88.2','165.5','190.31','187.81','186.31','185.11','184.31');


frequent_sq_3=char('23.8','31.4','50.3','51.76','52.8','53.574','54.4','54.94','55.5',...
				   '57.29','57.1848','57.0158','56.9898','56.9778','56.9723',...
				   '88.2','165.5','176.31','178.81','180.31','181.51','182.31');


frequent_sq_4=char('23.8','31.4','50.3','51.76','52.8','53.574','54.4','54.94','55.5',...
				   '57.29','56.7508','56.9198','56.9458','56.9578','56.9633',...
				   '88.2','165.5','176.31','178.81','180.31','181.51','182.31');




chan_sq=char('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15',...
		     '16','17','18','19','20','21','22');



typhoon_name='Maria';
TB_dir='/g3/hanwei/hpf/DOTLRT_outdata_TB/maria_new';
saved_dir='/g3/hanwei/hpf/DOTLRT_TB/maria_new';


for i=1:1
    for j=1:48
        a=str_time(j,:);
        b=str_day(i,:);
        time=sprintf('201807%s%s',b,a);
        time
        renamed_TB_22channel(TB_dir,saved_dir,time,typhoon_name,frequent_sq_1,frequent_sq_2,frequent_sq_3,frequent_sq_4,chan_sq);
    end 
end
