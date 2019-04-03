%dit by hongpengfei
%2018.11.10


input_dir='/g3/hanwei/hpf/DOTLRT_TB/maria_new/fy4';     %������������λ��
%input_dir='/g3/hanwei/hpf/DOTLRT_TA/maria_new/fy4_3db';     %������������λ��
%input_meteo_dir='D:\����ʹ�ҿ���\����\maliya\�������';      %д�۲����ϱ�Ҫ�Ĵ�����������
%output_dir='/g3/hanwei/hpf/DOTLRT_obs_file/maria_new/fy4/TA';     %д�۲����ϵ�����ļ���
output_dir='/g3/hanwei/hpf/DOTLRT_obs_file/maria_new/fy4/TB';     %д�۲����ϵ�����ļ���
input_all_the_file_dir='/g3/hanwei/hpf/DOTLRT_TB/maria_new/fy4/all_the_same_file';    %д�۲����ϱ�Ҫ�Ĵ����еĴ�����������

scene_YYYY_MM='201807';   %��������
scene_name='Maria';      %��������
simu_day=1;
simu_hour=48;
num_lat=51;      %��������С
num_lon=51;      
chan=42;           %�����ܵ�Ƶ������������ͨ���������ЩƵ��û��ģ������£��Ǹ�Ƶ������ȫ������Ϊ�㡣
obs_point=num_lat*num_lon;    %������������Ŀ
intput_need_file=sprintf('%s/all_the_same_file.mat',input_all_the_file_dir);   %д�۲���������Ҫ�Ĺ�ͬ�ı����ļ�
load(intput_need_file);        
satazen_single=reshape(GRAPES_angles(1:5:251,1:5:251),obs_point,1);
satazen=repmat(satazen_single,1,chan);
satazi=zeros(obs_point,chan);
solazen=zeros(obs_point,chan);
solazi=zeros(obs_point,chan);
lat_range=linspace(15,40,num_lat)';
lat_single=reshape(repmat(lat_range,1,num_lon),obs_point,1);
lat=repmat(lat_single,1,chan);
lon_range=linspace(120,145,num_lon);
lon_single=reshape(repmat(lon_range,num_lon,1),obs_point,1);
lon=repmat(lon_single,1,chan);
zs_single=reshape(GRAPESZS(1:5:251,1:5:251),obs_point,1);
zs=repmat(zs_single,1,chan);
GRAPESLAND=~GRAPESLAND;
isurf_type=repmat(reshape((2*GRAPESLAND(1:5:251,1:5:251)),obs_point,1),1,chan);

str_time=char('0000','0030','0100','0130','0200','0230','0300','0330','0400','0430','0500','0530',...
              '0600','0630','0700','0730','0800','0830','0900','0930','1000','1030','1100','1130',...
              '1200','1230','1300','1330','1400','1430','1500','1530','1600','1630','1700','1730',...
              '1800','1830','1900','1930','2000','2030','2100','2130','2200','2230','2300','2330');
str_day=char('08','09','10','11');   %��������


%���������춥��
%���ļ�
satazen_file=sprintf('%s/satazen.txt',output_dir);
fid=fopen(satazen_file,'w');
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',satazen(i,j));   
    end
    fprintf(fid,'\n'); 
end
fclose(fid);


%�������Ƿ�λ��
%���ļ�
satazi_file=sprintf('%s/satazi.txt',output_dir);
fid=fopen(satazi_file,'w'); 
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',satazi(i,j));    
    end
    fprintf(fid,'\n');
end
fclose(fid);


%����̫���춥��
%���ļ�
solzen_file=sprintf('%s/solazen.txt',output_dir);
fid=fopen(solzen_file,'w'); 
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',solazen(i,j));    
    end
    fprintf(fid,'\n');
end
fclose(fid);


%����̫����λ��
%���ļ�
solzen_file=sprintf('%s/solazi.txt',output_dir);
fid=fopen(solzen_file,'w'); 
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',solazi(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%����γ����Ϣ
%���ļ�
lat_file=sprintf('%s/lat.txt',output_dir);
fid=fopen(lat_file,'w');  
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',lat(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%���?����Ϣ
%���ļ�
lon_file=sprintf('%s/lon.txt',output_dir);
fid=fopen(lon_file,'w');
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',lon(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);



%����ر�߶���Ϣ
%���ļ�
isurf_height_file=sprintf('%s/surf_height.txt',output_dir);
fid=fopen(isurf_height_file,'w');
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',zs(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%����ر�������Ϣ
%���ļ�
isurf_type_file=sprintf('%s/surf_type.txt',output_dir);
fid=fopen(isurf_type_file,'w');
%ѭ��д�����
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',isurf_type(i,j));    
    end
    fprintf(fid,'\n');
end
fclose(fid);

%���?ͬʱ���Ĵ������
parfor i=1:simu_day
    for j=1:simu_hour
        a=str_time(j,:);
        b=str_day(i,:);
        time=sprintf('%s%s%s',scene_YYYY_MM,b,a);
        time
%        write_TA_obs_Ruralizate_fy4(time,num_lat,num_lon,obs_point,chan,input_dir,output_dir,scene_name);
        write_TB_obs_Ruralizate_fy4(time,num_lat,num_lon,obs_point,chan,input_dir,output_dir,scene_name);
    end
end







cd 
