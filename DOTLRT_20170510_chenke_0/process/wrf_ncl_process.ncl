load "/usr/local/ncl/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/local/ncl/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
path = "./data/"
inputfile = "wrfout_d01.nc"  ; NCL无法处理路径过长的文件,有时候要用ln -s大法
a = addfile(path+inputfile,"r")

t=t0

do while(t.le.t0+count-1)
  
  time = wrf_user_getvar(a,"Times",t)    ; calculate relative_humidity

  height = wrf_user_getvar(a,"z",t)    ; calculate height
  ascii_output = path+"modelHeight"+time+".txt"
  asciiwrite(ascii_output, height)
  delete(height)

  temperature = wrf_user_getvar(a,"tk",t)    ; calculate physical temperature in K
  ascii_output = path+"modelTemperature"+time+".txt"
  asciiwrite(ascii_output, temperature)
  delete(temperature)

  pressure = wrf_user_getvar(a,"pressure",t)    ; calculate pressure
  ascii_output = path+"modelPressure"+time+".txt"
  asciiwrite(ascii_output, pressure)
  delete(pressure)

  relative_humidity = wrf_user_getvar(a,"rh",t)    ; calculate relative_humidity
  ascii_output = path+"modelRHumidity"+time+".txt"
  asciiwrite(ascii_output, relative_humidity)
  delete(relative_humidity)
  
  t= t+1  
end do

end
