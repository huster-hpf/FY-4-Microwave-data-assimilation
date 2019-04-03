function [Out]=Brute_Force_Transform_DFT(In,GridX,GridY)

%=====================================================================
% This function obtains a 2D discrete signal given on a cartesian grid, and 
% computes for it the Discrete Fourier Transform on a required grid defined by 
% [GridX,GridY].
%
% Synopsis: [Out]=Brute_Force_Transform(In,GridX,GridY)
%
% Input: 
%    In - The input discrete signal given on the Cartesian grid (spatial domain)
%    GridX,GridY - two 2D arrays containing the grid points for the output 
%               (frequency domain) 
%
% Output:
%    Out - The output array of transformed coefficients on the required grid
%
% Example:
%           [XC,YC]=Create_Grid('C',[64,64,-pi,pi,-pi,pi],'.c'); 
%           In=zeros(64,64);
%           In(14:40,12:41)=1;
%           Out=Brute_Force_Transform(In,XC,YC);
%           Ref=fft2(In);
%           Ref=fftshift(Ref);
%           disp(max(max(abs(Ref-Out))));
%     or 
%           [XC,YC]=Create_Grid('C',[64,64,0,2*pi,0,2*pi],'.'); 
%           In=zeros(64,64);
%           In(14:40,12:41)=1;
%           Out=Brute_Force_Transform(In,XC,YC);
%           Ref=fft2(In);
%           disp(max(max(abs(Ref-Out))));
%
% Note that this program alligns EXACTLY with F = FTUSF(In,XC,YC) by Donoho.
%
% Written by Michael Elad on March 20th, 2005.
%=====================================================================

% These instructions perform shift of the cyclic coordinates to [0,2pi]^2.
% GridX = (GridX>=0).*GridX+(GridX<0).*(GridX+2*pi);
% GridY = (GridY>=0).*GridY+(GridY<0).*(GridY+2*pi);

[N1,N2]=size(GridX);
[NN1,NN2]=size(In);
[XX,YY]=meshgrid(0:1:NN2-1,0:1:NN1-1);
ii=sqrt(-1);

Out=zeros(N1,N2);
% h=waitbar(0,'Please wait ...');

for k=1:1:N1,
%     waitbar(k/N1)
    for j=1:1:N2,
        Map=exp(-ii*2*pi*(GridX(k,j).*XX/NN2+GridY(k,j).*YY/NN1));
        Out(k,j)=sum(sum(Map.*In));
    end;
end;

% close(h);

return;