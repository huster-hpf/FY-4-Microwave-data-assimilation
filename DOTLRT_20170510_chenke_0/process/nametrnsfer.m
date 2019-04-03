% change ':' to '_' when copying file from linux to windows
getpath
filepath=[mainpath,outputpath];
filetab=dir(filepath);

count=size(filetab,1);

i=1;
while i<=count
    if isempty(findstr('TbMap',filetab(i).name))
        filetab(i)=[];
        count=count-1;
    else i=i+1;
    end
end
mkdir([filepath,'/tempdir/']);
for i=1:count
    temp=filetab(i).name;
    temp2=temp;
    temp2(temp==':')='_';
    disp([temp,' to ',temp2]);
    copyfile([filepath,temp],[filepath,'/tempdir/',temp2]);
    
end