%edited by HPF
%2018.11.28


str_time=char('0000','0030','0100','0130','0200','0230','0300','0330','0400','0430','0500','0530',...
              '0600','0630','0700','0730','0800','0830','0900','0930','1000','1030','1100','1130',...
              '1200','1230','1300','1330','1400','1430','1500','1530','1600','1630','1700','1730',...
              '1800','1830','1900','1930','2000','2030','2100','2130','2200','2230','2300','2330');
str_day=char('08','09','10','11');
TB_dir='/g3/hanwei/hpf/DOTLRT_TB/maria_new/fy4';
TA_dir='/g3/hanwei/hpf/DOTLRT_TA/maria_new/fy4';
typhoon_name='Maria';

for i=1:1
    for j=1:48
        a=str_time(j,:);
        b=str_day(i,:);
        time=sprintf('201807%s%s',b,a);
        time
        run_RA_Radiometer_Simulation_bat(TB_dir,TA_dir,time,typhoon_name);
    end 
end
