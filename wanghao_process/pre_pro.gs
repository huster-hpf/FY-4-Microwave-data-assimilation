function pre_pro(args)
'reinit'
inputfile=subwrd(args,1)
linenum=subwrd(args,2)
format=subwrd(args,3)
layer=subwrd(args,4)
outfile=subwrd(args,5)

'open 'inputfile''


*处理Qv
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd Qv'
write(''outfile'/Qv.txt',result)
i=i+1
endwhile


*处理Qg
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd Qg'
write(''outfile'/Qg.txt',result)
i=i+1
endwhile

*处理Qi
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd Qi'
write(''outfile'/Qi.txt',result)
i=i+1
endwhile

*处理Qc
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd Qc'
write(''outfile'/Qc.txt',result)
i=i+1
endwhile

*处理Qr
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd Qr'
write(''outfile'/Qr.txt',result)
i=i+1
endwhile

*处理Qs
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd Qs'
write(''outfile'/Qs.txt',result)
i=i+1
endwhile

*处理t
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd t'
write(''outfile'/t.txt',result)
i=i+1
endwhile

*处理h
i=1
while(i<=layer)
'set gxout print' 
'set prnopts 'format' 'linenum''
'set z 'i''
'd h'
write(''outfile'/h.txt',result)
i=i+1
endwhile

*处理TSK
'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd ts'
write(''outfile'/ts.txt',result)


*处理u10
'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd u10m'
write(''outfile'/u10.txt',result)


*处理v10
'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd v10m'
write(''outfile'/v10.txt',result)


*处理zs
'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd zs'
write(''outfile'/zs.txt',result)

*´¦ÀQ2kg
'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd q2m'
write(''outfile'/q2.txt',result)

*´¦Àt2m
'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd t2m'
write(''outfile'/t2.txt',result)

'set gxout print'
'set prnopts 'format' 'linenum''
'set z 'i''
'd psl'
write(''outfile'/p2.txt',result)

colse(inputfile)
