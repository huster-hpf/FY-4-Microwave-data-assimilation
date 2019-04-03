function renamed_TB( in_dir,out_dir,time,Typhoon_name,frequent_sq_1,frequent_sq_2,frequent_sq_3,frequent_sq_4,chan_sq )
%edit by hongpengfei
%2018.11.27

in_file_dir=sprintf('%s/%s',in_dir,time);
out_file_dir=sprintf('%s/%s',out_dir,time);
mkdir(out_file_dir);

[len,num]=size(chan_sq);
for i=1:len
    s1=frequent_sq_1(i,:);
    s2=frequent_sq_2(i,:);
    s3=frequent_sq_3(i,:);
    s4=frequent_sq_4(i,:);
    s1(find(isspace(s1)))=[];
    s2(find(isspace(s2)))=[];
    s3(find(isspace(s3)))=[];
    s4(find(isspace(s4)))=[];
	chan=chan_sq(i,:);
	chan(find(isspace(chan)))=[];
    input_file_1=sprintf('%s/WRFTbMap-%s.mat',in_file_dir,s1);
    input_file_2=sprintf('%s/WRFTbMap-%s.mat',in_file_dir,s2);
    input_file_3=sprintf('%s/WRFTbMap-%s.mat',in_file_dir,s3);
    input_file_4=sprintf('%s/WRFTbMap-%s.mat',in_file_dir,s4);
    if(exist(input_file_1,'file')&&exist(input_file_2,'file')&&exist(input_file_3,'file')&&exist(input_file_4,'file'))
        saved_file=sprintf('%s/Typhoon%s_%s_%s_%s_C%s_H.mat',out_file_dir,Typhoon_name,time(7:8),time(9:10),time(11:12),chan);
        load(input_file_1);
        TbMap_1=TbMap;
        load(input_file_2);
        TbMap_2=TbMap;
        load(input_file_3);
        TbMap_3=TbMap;
        load(input_file_4);
        TbMap_4=TbMap;
        TbMap=(TbMap_1(:,:,1)+TbMap_2(:,:,1)+TbMap_3(:,:,1)+TbMap_4(:,:,1))/4;
        save(saved_file,'TbMap');
    end
end

