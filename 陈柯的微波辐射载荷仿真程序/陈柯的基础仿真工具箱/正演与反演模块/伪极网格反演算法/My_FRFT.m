function y=My_FRFT(x,alpha)

%====================================================================
% My Fractional Fourier Transform, computing the transform
%               
%            y[n]=sum_{k=0}^{N-1} x(k)*exp(-i*2*pi*k*n*alpha)  n=0,1,2, ... ,N-1
% 
% So that for alpha=1/N we get the regular FFT, and for alpha=-1/N we get the regular 
% IFFT. 
%
% Synopsis: y=My_FRFT(x,alpha)
%
% Inputs -    x - an N-entry vector to be transformed
%                   alpha - the scaling factor (in the Pseudo-Polar it is in the range [-1/N,+1/N]
% 
% Outputs-  y - the transformed result as an N-entries vector
%
% Written by Michael Elad on March 20th, 2005.
%====================================================================

x=x(:);
N=length(x);

n=[0:1:N-1, -N:1:-1]';
Factor=exp(-i*pi*alpha*n.^2);

x_tilde=[x; zeros(N,1)];
x_tilde=x_tilde.*Factor;    

XX=fft(x_tilde);
YY=fft(conj(Factor));
y=ifft(XX.*YY);
y=y.*Factor;
y=y(1:N);

return;

