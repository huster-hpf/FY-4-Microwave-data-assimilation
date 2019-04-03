%edit by hongpengfei
%2018.11.10


% input_dir='D:\科研使我快乐\科研\maliya\DOTLRT_TB';     %输入正演亮温位置
input_dir='D:\科研使我快乐\科研\maliya\DOTLRT_TA';     %输入正演亮温位置
%input_meteo_dir='D:\科研使我快乐\科研\maliya\大气参数';      %写观测资料必要的大气参数变量。
% output_dir='D:\\科研使我快乐\\科研\\maliya\\DOTLRT_obs_file\\TB';     %写观测资料的输出文件夹
output_dir='D:\\科研使我快乐\\科研\\maliya\\DOTLRT_obs_file\\TA';     %写观测资料的输出文件夹
input_all_the_fiel_dir='D:\科研使我快乐\科研\maliya\all_the_same_file';    %写观测资料必要的大气共有的大气参数变量。

scene_YYYY_MM='201807';   %场景年月
scene_name='Maria';      %场景名字
simu_day=4;
simu_hour=48;
num_lat=251;      %仿真网格大小
num_lon=251;      
chan=22;           %仿真总的频点个数（仿真的最大通道数），如果有些频点没有模拟出亮温，那该频点亮温全部复制为零。
% obs_point=num_lat*num_lon;    %仿真区域格点数目
obs_point=num_lat*num_lon;
intput_need_file=sprintf('%s\\all_the_same_file.mat',input_all_the_fiel_dir);   %写观测资料所需要的共同的变量文件
load(intput_need_file);   
GRAPES_angles=GRAPES_angles(1:num_lat,1:num_lon);
satazen_single=reshape(flipud(GRAPES_angles)',obs_point,1);
satazen=repmat(satazen_single,1,chan);
satazi=zeros(obs_point,chan);
solazen=zeros(obs_point,chan);
solazi=zeros(obs_point,chan);
lat_range=linspace(15,40,251);
lat_single=reshape(repmat(lat_range,251,1),obs_point,1);
lat=repmat(lat_single,1,chan);
lon_range=linspace(120,145,251)';
lon_single=reshape(repmat(lon_range,1,251),obs_point,1);
lon=repmat(lon_single,1,chan);
GRAPESheight=GRAPESheight(1:num_lat,1:num_lon);
isurf_height=repmat(reshape(GRAPESheight(:,:,1)',obs_point,1),1,chan);
GRAPESLAND=GRAPESLAND(1:num_lat,1:num_lon);
isurf_type=repmat(reshape((2*GRAPESLAND)',obs_point,1),1,chan);

str_time=char('0000','0030','0100','0130','0200','0230','0300','0330','0400','0430','0500','0530',...
              '0600','0630','0700','0730','0800','0830','0900','0930','1000','1030','1100','1130',...
              '1200','1230','1300','1330','1400','1430','1500','1530','1600','1630','1700','1730',...
              '1800','1830','1900','1930','2000','2030','2100','2130','2200','2230','2300','2330');
str_day=char('08','09','10','11');   %仿真日期


%处理卫星天顶角
%打开文件
satazen_file=sprintf('%s\\satazen.txt',output_dir);
fid=fopen(satazen_file,'w');
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',satazen(i,j));   
    end
    fprintf(fid,'\n'); 
end
fclose(fid);


%处理卫星方位角
%打开文件
satazi_file=sprintf('%s\\satazi.txt',output_dir);
fid=fopen(satazi_file,'w'); 
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',satazi(i,j));    
    end
    fprintf(fid,'\n');
end
fclose(fid);


%处理太阳天顶角
%打开文件
solzen_file=sprintf('%s\\solazen.txt',output_dir);
fid=fopen(solzen_file,'w'); 
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',solazen(i,j));    
    end
    fprintf(fid,'\n');
end
fclose(fid);


%处理太阳方位角
%打开文件
solzen_file=sprintf('%s\\solazi.txt',output_dir);
fid=fopen(solzen_file,'w'); 
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',solazi(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%处理纬度信息
%打开文件
lat_file=sprintf('%s\\lat.txt',output_dir);
fid=fopen(lat_file,'w');  
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',lat(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%处理经度信息
%打开文件
lon_file=sprintf('%s\\lon.txt',output_dir);
fid=fopen(lon_file,'w');
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',lon(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%处理地表高度信息
%打开文件
isurf_height_file=sprintf('%s\\surf_height.txt',output_dir);
fid=fopen(isurf_height_file,'w');
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',isurf_height(i,j));   
    end
    fprintf(fid,'\n');
end
fclose(fid);


%处理地表类型信息
%打开文件
isurf_type_file=sprintf('%s\\surf_type.txt',output_dir);
fid=fopen(isurf_type_file,'w');
%循环写入数据
for i=1:obs_point
    for j=1:chan
        fprintf(fid,'%8.2f\t',isurf_type(i,j));    
    end
    fprintf(fid,'\n');
end
fclose(fid);

parpool('local',1)
%处理不同时间点的大气参数
parfor i=1:4
    for j=1:48
        a=str_time(j,:);
        b=str_day(i,:);
        time=sprintf('%s%s%s',scene_YYYY_MM,b,a);
        time
%         write_TB_obs(time,num_lat,num_lon,obs_point,chan,input_dir,output_dir,scene_name);
        write_TA_obs_test(time,num_lat,num_lon,obs_point,chan,input_dir,output_dir,scene_name);
    end
end
