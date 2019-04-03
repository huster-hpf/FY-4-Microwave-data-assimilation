clear
clc
% mainpath='/media/lee/学习工作/Lee_s workshop/matlab/RTMODEL/DOTLRT_20150923_3rd_expriment/';
% datapath='data/';
% outputpath='output/';
% picpath='pictures/';
% wrfout = 'wrfout_d01.nc';
% surfacefile='surface_input.mat';
getpath  %do all above

filetab=dir([mainpath,outputpath]);
% filters out those files whose name contains 'TbMap'
count=size(filetab,1);
i=1;
while i<=count
    temp=strfind(filetab(i).name,'TbMap');
    if(isempty(temp))
        filetab(i)=[];
        count=count-1;
    else i=i+1;
    end
end

for i=1:count
    file=filetab(i).name;
    load([mainpath,outputpath,file])
    figure(i)
    title(file)
    x=TbMap(:,:,1);%+TbMap(:,:,1);
    x=rot90(x,2);
    h=pcolor(x);
    colorbar;
    set(h,'linestyle','none')
    title(file)
    name=filetab(i).name;
    size_name=size(name,2);
    name(size_name-3:size_name)=[];
    name(1:23)=[];
    name(name=='.')=',';
    saveas(h,[mainpath,picpath,name,'_',date,'_计算结果'],'fig')
end