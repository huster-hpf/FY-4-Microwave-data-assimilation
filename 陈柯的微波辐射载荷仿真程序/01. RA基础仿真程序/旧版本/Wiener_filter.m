clc
clear
close all

% Consider two very different images -- the cameraman and house.
cam = im2double(imread('cameraman.tif'));
house_url = 'http://blogs.mathworks.com/images/steve/180/house.tif';
house = im2double(imread(house_url));
figure;
subplot(1,2,1)
imshow(cam)
colormap(gray(256))
title('cameraman')
subplot(1,2,2)
imshow(house)
title('house')
% We show the actual (log) spectrum for these two images.
cf = abs(fft2(cam)).^2;
hf = abs(fft2(house)).^2;
figure;
subplot(1,2,1)
surf([-127:128]/128,[-127:128]/128,log(fftshift(cf)+1e-6))
shading interp, colormap gray
title('cameraman power spectrum')
subplot(1,2,2)
surf([-127:128]/128,[-127:128]/128,log(fftshift(hf)+1e-6))
shading interp, colormap gray
title('house power spectrum')
% Let's see what happens if we restore the cameraman with the actual power spectrum.
h = fspecial('disk',4);
cam_blur = imfilter(cam,h,'circular');
% 40 dB PSNR
sigma_u = 10^(-40/20)*abs(1-0);
cam_blur_noise = cam_blur + sigma_u*randn(size(cam_blur));
figure;
subplot(1,2,1)
imshow(cam_blur_noise)
cam_wnr = deconvwnr(cam_blur_noise,h,numel(cam)*sigma_u^2./cf);
subplot(1,2,2)
imshow(cam_wnr)
colormap(gray(256))
title('restored image with exact spectrum')
% For comparison purposes, we restore the cameraman using the power spectrum obtained from the house image.

cam_wnr2 = deconvwnr(cam_blur_noise,h,numel(cam)*sigma_u^2./hf);
figure;
imshow(cam_wnr2)
colormap(gray(256))
title('restored image with house spectrum')
% Visually, the two are very similar in quality. In terms of mean-square error (MSE), the former is better (lower), as the theory predicts:
format short e
mse1 = mean((cam(:)-cam_wnr(:)).^2)
mse2 = mean((cam(:)-cam_wnr2(:)).^2)

% We calculate these parameters for the cameraman, averaging over horizontal and vertical shifts to get a single parameter for the correlation coefficient. Then we calculate an autocorrelation function.
sigma2_x = var(cam(:))
mean_x = mean(cam(:))
cam_r = circshift(cam,[1 0]);
cam_c = circshift(cam,[0 1]);
rho_mat = corrcoef([cam(:); cam(:)],[cam_r(:); cam_c(:)])
rho = rho_mat(1,2);
[rr,cc] = ndgrid([-128:127],[-128:127]);
r_x = sigma2_x*rho.^sqrt(rr.^2+cc.^2) + mean_x^2;

surf([-128:127],[-128:127],r_x)
axis tight
shading interp, camlight, colormap jet
title('image autocorrelation model approximation')
% From this we calculate another restored image:
cam_wnr3 = deconvwnr(cam_blur_noise,h,sigma_u^2,r_x);
imshow(cam_wnr3)
colormap(gray(256))
title('restored image using correlation model')
mse3 = mean((cam(:)-cam_wnr3(:)).^2)



