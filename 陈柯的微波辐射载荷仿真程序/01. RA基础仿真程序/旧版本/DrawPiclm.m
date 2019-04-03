function DrawPiclm(T_mat,l,m,scene_row,scene_col,str )
%按照方向余弦l,m画出亮温分布
%   Detailed explanation goes here
lm_data1 = linspace(min(l),max(l),scene_col);
lm_data2 = linspace(min(m),max(m),scene_row);
mat = reshape(T_mat,scene_row,scene_col);
figure;
% surf(lm_data1,lm_data2,abs(mat),'EdgeColor','none');
imagesc(lm_data1,lm_data2,abs(mat));
axis ij; 
xlim([min(l), max(l)]);
ylim([min(m), max(m)]);
set(gca,'FontName','Times New Roman','FontSize',25);
title(str,'FontSize',25);
xlabel('\zeta = sincos','FontSize',25);
ylabel('\eta = sinsin','FontSize',25);
zlabel('亮温（K）');
colorbar('FontSize',25);
set(findall(gcf,'ViewStyle','datatip'),'fontsize',25);
end

