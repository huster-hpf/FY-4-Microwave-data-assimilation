% %%%%%%%%方向图APN归一化
function inv_PSF = APN(inv_PSF,PSF)
     n = size(inv_PSF,1);
     A = inv_PSF*PSF;
%      UN_APN = sum(A(round(n/2),:))
     for i=1:n
         inv_PSF(i,:) = inv_PSF(i,:) / sum(A(i,:));
     end
    
%      A = inv_PSF*PSF;
%      APN = sum(A(round(n/2),:))