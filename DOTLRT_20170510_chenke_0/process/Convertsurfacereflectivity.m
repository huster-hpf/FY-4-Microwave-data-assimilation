%% 从菲涅尔反射系数转换到菲涅尔反射率
% 取模的平方而已
load surface_input_old.mat
[x,y,na,~]=size(surface_inp);
surface_inp(:,:,:,2)=(abs(surface_inp(:,:,:,2))).^2;
surface_inp(:,:,:,3)=(abs(surface_inp(:,:,:,3))).^2;
save('everything.mat','surface_inp','-append')
% 计算反射率的程序已经修正，不需要这个修正了
