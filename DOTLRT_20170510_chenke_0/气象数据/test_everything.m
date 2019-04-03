


clear
clc

getpath  

filetab=dir([mainpath,datapath]);
% filters out those files whose name contains 'TbMap'
count=size(filetab,1);
i=1;
while i<=count
    temp=strfind(filetab(i).name,'everything');
    if(isempty(temp))
        filetab(i)=[];
        count=count-1;
    else i=i+1;
    end
end



while 1
for i=1:count
    file=filetab(i).name;
    load([mainpath,datapath,file])
    figure(1)
    title(file)
    x=atm_inp(:,:,10,5);%+TbMap(:,:,1);
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
    %saveas(h,[mainpath,picpath,name,'_',date,'_计算结果'],'fig')
    pause(1)
end
i=1
end