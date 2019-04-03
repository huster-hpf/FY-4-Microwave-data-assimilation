clear
clc
getpath


filetab=dir([mainpath,outputpath]);
count=size(filetab,1);

for i=3:count
    file=filetab(i).name;
    load([mainpath,outputpath,file])
    figure(i-2)
    title(file)
    x=TbMap(:,:,1);%+TbMap(:,:,1);
    x=rot90(x,2);
    h=pcolor(x);
    colorbar;
    set(h,'linestyle','none')
    title(file)
end