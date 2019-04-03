function V = ASR_DFT_2D_parallel_rorate_back(Tb,Fov_xi,Fov_eta,d_xi,d_eta,uv_sample,G,flag_FringWashing,FringWashing_factor,number)
%   函数功能：根据综合孔径公式从亮温图像计算可见度函数*****************************
%             并行计算版本
%  
%   输入参数:
%    T              ：输入场景亮温分布         
%    Fov_xi         ：亮温图像每点的ξ坐标 
%    Fov_eta        ：亮温图像每点的η坐标
%    d_xi           ：亮温图像每个像素的ξ坐标间距
%    d_eta          ：亮温图像每个像素的η坐标间距
%    uv_sample      ：uv平面采样点坐标
%    G              :单元天线方向图
%    rorate_mode    :背景场动态标志位，非零则为动态
%   输出参数：
%    V              : uv平面采样点对应的每点可见度函数                                       
%   by 陈柯 2016.06.24  ******************************************************
if number == 60               %根据输入图像序列数确定扫描参数
    t = 5;
else if number ==30
        t = 10;
    end
end

if  flag_FringWashing == 1  %计算可见度函数的时候包括消条纹函数项
    matlabpool open;
    [N1,N2]=size(uv_sample); 
    V=zeros(N1,N2);
    parfor j=1:N2
        n=floor((j-1)/t)+1;                %背景图片设置参数，10或者5
        T=Tb(:,:,n);
        for k=1:N1
           u = real(uv_sample(k,j));
           v = imag(uv_sample(k,j));
           FringWashing = sinc(-1*FringWashing_factor*(u*Fov_xi+v*Fov_eta));
           V(k,j)=sum(sum(((T.*G.*FringWashing).*exp(-1i*2*pi*(u*Fov_xi+v*Fov_eta)))))*d_xi*d_eta;
        end;
    end;
    matlabpool close
else
    matlabpool open ;
    [N1,N2]=size(uv_sample); 
    V=zeros(N1,N2);
    parfor j=1:N2
        n=floor((j-1)/t)+1;                %背景图片设置参数，10或者5
        T=Tb(:,:,n);
        for k=1:N1
           u = real(uv_sample(k,j));
           v = imag(uv_sample(k,j));
           V(k,j)=sum(sum(((T.*G).*exp(-1i*2*pi*(u*Fov_xi+v*Fov_eta)))))*d_xi*d_eta;
        end;
    end;
    matlabpool close
end