function Y=APPFFT(X)%====================================================================% This function performs a Recto (Pseudo) Polar ADJOINT transform on a 2D signal X % given on the PP-coordinate system. If X is 2N*2N, the output will have N by N values. % The algorithm applied here uses the Fast Fractional Fourier Transform. %   % Synopsis: Y=APPFFT(X)%% Inputs -    X     2N*2N matrix in pseudo-polar grid, (N is assumed to be even)           % Outputs - Y      N*N matrix (Cartesian grid)%% Example: % %   The following is a way to verify that this works as an adjoint -%   choosing random X and Y, one must obtain that <y,Ax> = <x,adj(A)y>'%  %   N=16; X=randn(N)+sqrt(-1)*randn(N); Y=randn(2*N)+sqrt(-1)*randn(2*N);%   AX=PPFFT(X);%   AtY=APPFFT(Y);%   disp(abs( sum(sum(Y'.*AX)) -conj(sum(sum(X'.*AtY)))));       % % Written on March 20th, 2005 by Michael Elad.%====================================================================% preliminary checks of the input size[N,m2]=size(X); if N~=m2,    disp('Non Square input array');    return;elseif floor(N/4)-N/4~=0,    disp('Size of the input array is not an integer mul. by 4');    return;end;N=N/2;  Y=zeros(N,N);Temp1=zeros(N,2*N);for l=-N:N-1,    Xvec=X(N:-1:1,l+N+1);    alpha=-l/N^2;    OneLine=My_FRFT(Xvec,alpha);    OneLine=(OneLine.').*exp(-1i*pi*l*(0:1:N-1)/N);    Temp1(:,l+N+1)=OneLine.';end;Temp_Array=2*N*ifft(Temp1,[],2);Temp_Array=Temp_Array(:,1:N)*diag((-1).^(0:N-1));Y=Temp_Array.';Temp2=zeros(N,2*N);for l=-N:N-1,    Xvec=X(2*N:-1:N+1,l+N+1);    alpha=l/N^2;    OneCol=My_FRFT(Xvec,alpha);    OneCol=OneCol.*(exp(i*pi*l*(0:1:N-1)/N).');    Temp2(:,l+N+1)=OneCol;end;Temp_Array=2*N*ifft(Temp2,[],2);Y=Y+Temp_Array(:,1:N)*diag((-1).^(0:N-1));Y=Y.';return;