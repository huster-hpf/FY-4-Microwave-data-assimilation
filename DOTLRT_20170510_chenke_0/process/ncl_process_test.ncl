load "/usr/share/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/share/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
path = "/media/lee/LAB/DOTLRT_expriment/data/"
inputfile = "wrfout_d01.nc"  ; NCL无法处理路径过长的文件,有时候要用ln -s大法
a = addfile(path+inputfile,"r")

t=0
count=1

do while(t.le.count-1)
  
  time = wrf_user_getvar(a,"Times",t)    ; calculate relative_humidity

  xlong = wrf_user_getvar(a,"XLONG",t)    ; calculate xlong
  ascii_output = path+"modellongtitude"+time+".txt"
  asciiwrite(ascii_output, xlong)
  delete(xlong)
  
  t= t+1  
end do

end
