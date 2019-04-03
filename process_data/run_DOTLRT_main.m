%edit by hongpengfei
%2018.10.31
function run_DOTLRT_main(time)

SOURCE_PATH=sprintf('/g3/wanghao/hpf/meteo_file/maria_new/%s',time);                  %Դ�ļ�Ŀ¼  
DST_PATH=sprintf('/g3/hanwei/hpf/DOTLRT_20170510_chenke_0/data_sq/');         %Ŀ���ļ�Ŀ¼
filename=sprintf('%s/meteorology_data.mat',SOURCE_PATH);
copyfile(filename,DST_PATH);
DOTLRT_main 