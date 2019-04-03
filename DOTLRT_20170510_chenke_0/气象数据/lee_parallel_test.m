mainpath='/media/lee/学习工作/Lee_s workshop/matlab/RTMODEL/DOTLRT_20150923第二次实验/';
testpath='test/';

matlabpool open
p=zeros(4,1000)
q=zeros(1,1000)
for z=1:4
    disp(['now z = ',num2str(z)])
    parfor i=1:1000
        disp(['with z = ',num2str(z)])
        disp(['running ',num2str(i)])
        q(i)=i+rand(1);
        pause(0.1)
    end
    save([mainpath,testpath,'q_z',num2str(z),'.mat'],'q');
end

matlabpool close