%edit by hongpengfei
%2018.10.31
function run_DOTLRT_main(time)

SOURCE_PATH=sprintf('/g3/wanghao/hpf/process_data/outfile/%s',time);                  %源文件目录  
DST_PATH=sprintf('/g3/wanghao/hpf/DOTLRT_20170510_chenke_0/data_sq/%s/',time);         %目的文件目录
filename=sprintf('%s/meteorology_data.mat',SOURCE_PATH);
movefile(filename,DST_PATH_t);
DOTLRT_main 