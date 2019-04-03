% 图像解卷积，求系统响应函数PSF的逆矩阵%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function inv_PSF = PSF_inversion(PSF,regulation_para)
% PSF:系统响应函数；k:正则化参数
[U,s,V] = csvd(PSF);
param = size(PSF,1);
inv_PSF = V(:,1:param)*diag(s(1:param)./(s(1:param).^2+regulation_para.^2))*U(:,1:param)';
%inv_PSF = V(:,1:param)*diag(1./s(1:param_Long))*U(:,1:param_Long)'; 
inv_PSF = APN(inv_PSF,PSF);