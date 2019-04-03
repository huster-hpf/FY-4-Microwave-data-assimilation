##! /bin/ksh
#! /bin/bash  
#tc_post.sh

test_name='real'   ###修改这里即可

track_root_dir='/g3/hanwei/hpf/Typhoon/'
track_dir=$track_root_dir/all_typhoon_track
echo $track_dir


track_file=$track_dir/tc_report.sum
echo $track_file

mkdir $test_name
cd $test_name

sed -n '38,50p'  $track_file > track_file_tf.txt


awk -F " " '{print $10}' track_file_tf.txt >  lat.txt
sed -i 's/N//g' lat.txt

awk -F " " '{print $11}' track_file_tf.txt > lon.txt
sed -i 's/E//g' lon.txt

awk -F " " '{print $12}' track_file_tf.txt > pres.txt
sed -i 's/HPA//g' pres.txt

awk -F " " '{print $13}' track_file_tf.txt > windspeed.txt
