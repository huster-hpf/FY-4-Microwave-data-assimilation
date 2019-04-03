begin

path = "/g3/wanghao/hpf/process_data/"

grapespfile=path+"GRAPESP.txt"
GRAPESP=asciiread(grapespfile,(/m*n*l,1/),"float")
grapestfile=path+"GRAPEST.txt"
GRAPEST=asciiread(grapestfile,(/m*n*l,1/),"float")
grapesqvfile=path+"GRAPESQV.txt"
GRAPESQV=asciiread(grapesqvfile,(/m*n*l,1/),"float")
  
  RH = wrf_rh(GRAPESQV,GRAPESP,GRAPEST)
  ascii_output = path+"modelRHumidity.txt"
  asciiwrite(ascii_output, RH)
end