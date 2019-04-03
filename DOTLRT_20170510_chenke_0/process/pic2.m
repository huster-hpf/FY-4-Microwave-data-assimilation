
clear
clc

getpath
channeltab={'36.5';'50.3';'54.4';'57.29';'183.3';'88.2'};
channel_cue='T';%channeltab{1};

%% get coordinates
XLAT = ncread(wrfout,'XLAT');
XLA = XLAT(:,:,1);

XLONG = ncread(wrfout,'XLONG');
XLO = XLONG(:,:,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%




%% Pick files %%%
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

% filters out those files whose name contains channel_cue. '50.3' for
% example
i=1;
while i<=count
    temp=strfind(filetab(i).name,channel_cue);
    if(isempty(temp))
        filetab(i)=[];
        count=count-1;
    else i=i+1;
    end
end
%% loading data to a matrix called Tbmatrix

% Determine the dimensions of Tbmatrix
file=filetab(1).name;
load([mainpath,outputpath,file]);
[rowD,colD,~]=size(TbMap);
Tbmatrix=zeros(rowD,colD,count);

for i=1:count
    file=filetab(i).name;
    load([mainpath,outputpath,file])

    Tbmatrix(:,:,i)=TbMap(:,:,1);%+TbMap(:,:,1);
    
end


%while 1
%% Now setting caxis
figure(1)

x=Tbmatrix(:,:,1);
pcolor(XLO',XLA',x');
%v=caxis;
title({'Testing image';'for acquiring proper color limits of colormap'})

%% Business time now!
    for i=1:count
        file=filetab(i).name;
        file(file=='_')=' ';
        
        figure(1)
        title(file)
        x=Tbmatrix(:,:,i);%+TbMap(:,:,1);
        
        h=pcolor(XLO',XLA',x');
        colorbar;
        %caxis(v)
        axis image
        set(h,'linestyle','none')
        title(file)
        name=filetab(i).name;
        size_name=size(name,2);
        name(size_name-3:size_name)=[];
        name(1:23)=[];
        name(name=='.')=',';
        %saveas(h,[mainpath,picpath,name,'_',date,'_计算结果'],'fig')
        %pause(1)
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        frame=getframe(gcf);
        im=frame2im(frame);%制作gif文件，图像必须是index索引图像
        [I,map]=rgb2ind(im,256);
        
        if i == 1;
            imwrite(I,map,['test',channel_cue,'.gif'],'gif','LoopCount',Inf,'DelayTime',1);
        else
            imwrite(I,map,['test',channel_cue,'.gif'],'gif','WriteMode','append','DelayTime',1);
        end
        
        pause(1)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    i=1
%end