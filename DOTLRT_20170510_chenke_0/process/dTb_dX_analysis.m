% dTb_dClCut(rowIndex,colIndex ,:,:) = reshape(dTb_dw(:,1,:), zDim, 2);
% dTb_dRnCut(rowIndex, colIndex,:,:) = reshape(dTb_dw(:,2,:), zDim, 2);
% dTb_dIceCut(rowIndex,colIndex ,:,:) = reshape(dTb_dw(:,3,:), zDim, 2);
% dTb_dSnowCut(rowIndex, colIndex,:,:) = reshape(dTb_dw(:,4,:), zDim, 2);
% dTb_dGrpCut(rowIndex,colIndex, :,:) = reshape(dTb_dw(:,5,:), zDim, 2);
clear
getpath

%% 分析第一次实验数据
% 166GHz，单组
datadir=[mainpath,olddatapath,'原始/'];
data=dir(datadir);
load([datadir,data(3).name]);


figure(1)

subplot(2,1,1)
plot(dTb_dT(:,1));

subplot(2,1,2)
plot(dTb_dT(:,2));



%% 分析第二组数据
% 36.5 42.5 50.3X5 54.4X5 57.29X5 89 118.75 183.3X5 380 425
datadir=[mainpath,olddatapath,'5th_data/'];
data=dir(datadir);
count=size(data,1);

i=1;
while i<=count
    if isempty(strfind(data(i).name,'Cut'))
        data(i)=[];
        count=count-1;
    else i=i+1;
    end
end

% Loading data 
dTbCutmatrix36_5=
for i=1:count
    load([datadir,data(i).name]);
    figure(2)
    title(data(i).name)
    dot_num=5;
    for j=1:dot_num
        subplot(dot_num,1,j)
        x=dTb_dTCut(1,10*j,:,1);
        x=reshape(x,59,1);
        plot(x)
    end
    pause(1)
end

