##! /bin/ksh
#! /bin/bash  
#tc_post.sh

test_name='maria_2018070806_DOTLRT_TA_5db'

track_root_dir='/g3/hanwei/hpf/Typhoon/'
track_dir=$track_root_dir$test_name/RUNDIR
echo $track_dir


track_file=$track_dir/tc_track.fcst
echo $track_file
mkdir $test_name
cd $test_name

awk -F " " '{print $9}' $track_file >  lat.txt
sed -i 's/N//g' lat.txt

awk -F " " '{print $10}' $track_file > lon.txt
sed -i 's/E//g' lon.txt

awk -F " " '{print $11}' $track_file > pres.txt
sed -i 's/HPA//g' pres.txt

awk -F " " '{print $12}' $track_file > windspeed.txt
