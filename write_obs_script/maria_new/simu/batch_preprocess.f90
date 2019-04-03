PROGRAM preprocess
!----------------------
!hongpengfei
!----------------------


IMPLICIT NONE
  INTEGER    :: i,j
  CHARACTER(len=100) :: in_dir='/g3/hanwei/hpf/DOTLRT_obs_file/maria_new/fy4/TB/'
  CHARACTER(len=100) :: out_dir='/g3/hanwei/hpf/write_obs_script/maria_new/simu/output/'
  CHARACTER(len=4)  :: yyyy='2018'
  CHARACTER(len=2)  :: mm='07'
  CHARACTER(len=2)  :: dd
  CHARACTER(len=2)  :: hh
  CHARACTER(len=2)  :: mi
  CHARACTER(len=2)  :: ss='00'
  CHARACTER(len=40)  :: time

  CHARACTER(len=2)  :: ddsq(4)=(/'08','09','10','11'/)
 CHARACTER(len=4)  :: hhmisq(48)=(/'0000','0030','0100','0130','0200','0230', &
                                   '0300','0330','0400','0430','0500','0530', &
                                   '0600','0630','0700','0730','0800','0830', &
                                   '0900','0930','1000','1030','1100','1130', &
                                   '1200','1230','1300','1330','1400','1430', & 
                                   '1500','1530','1600','1630','1700','1730', &
                                   '1800','1830','1900','1930','2000','2030', & 
                                   '2100','2130','2200','2230','2300','2330'/)


DO i=1,1
  DO j=1,48
    time=yyyy//mm//ddsq(i)//hhmisq(j)//ss
    call  process(in_dir,out_dir,time)
  END DO
END DO

END



SUBROUTINE process(in_dir,out_dir,time)

  IMPLICIT NONE
  CHARACTER(len=100),INTENT(IN) :: in_dir
  CHARACTER(len=100),INTENT(IN) :: out_dir
  CHARACTER(LEN=20),INTENT(IN) :: time

  TYPE type_rad1c
      INTEGER :: YYYY,mn,dd,hh,mm,ss=00
      INTEGER :: iscanlines,iscanpos
      REAL    :: rlat,rlon !lat/lon in degrees for Anfovs
      INTEGER :: isurf_height,isurf_type !height/type for Anfovs
      REAL    :: satzen,satazi,solzen,solazi !scan angles for Anfovs
      REAL    :: tbb(42) !bright temperatures
      INTEGER :: iavhrr(13),ihirsflag
      INTEGER :: iprepro(5)
      REAL    :: clfra ! Cloud cover (<1.0)
      REAL    :: ts ! Skin temperature
      REAL    :: tctop ! Cloud top temperature
  END TYPE type_rad1c

  INTEGER,PARAMETER  :: numchan   = 42

  REAL, PARAMETER :: RMDI = -999999.          ! general purpose real missing data indicator
  INTEGER, PARAMETER :: MDI = -999999         ! general purpose integer mdi
  REAL,PARAMETER  :: PI = 3.14159265358979

  INTEGER :: yyyy,mn,dd,hh,mm,ss


  !***  Defining an array corresponding to a scientific dataset ***
  INTEGER*4 ,PARAMETER :: nx=51,ny=51,nobs=nx*ny
  REAL*8               :: llRDMI=999999.9999

  INTEGER                        :: i,error
  REAL*4,DIMENSION(nobs,numchan) :: tbb,satazen,satazi,solazen,solazi
  INTEGER,DIMENSION(nobs,numchan)        :: isurf_height,isurf_type
  REAL*8,DIMENSION(nobs,numchan)         :: lat,lon
  !BYTE              :: cloudmask(nobs)

  TYPE(type_rad1c) :: rad(nobs)

  !*** Definning write parameter ***
  REAL*8               :: llRDMItemp=1000000
  INTEGER :: ui=98,num = 0
  INTEGER :: iobs
  INTEGER :: ioss

  CHARACTER(len=100):: TB_dir
  CHARACTER(len=100) :: file_name

  TB_dir=trim(in_dir)//time(1:12)
  !*** Extracting Tb_data *** 
  file_name=trim(TB_dir)//'/tb.txt'
  open(ui,file=file_name)
  !read(ui,*)     !!!跳过第一行表头
  DO i = 1, nobs
      read(ui,*) tbb(i,:)
  END DO
  CLOSE(ui)

  !*** Extracting angle data ***
  file_name=trim(in_dir)//'/satazen.txt'
  open(ui,file=file_name)
  !read(ui,*)     !!!跳过第一行表头
  DO i= 1, nobs
      read(ui,*) satazen(i,:)
  END DO
  CLOSE(ui)
  file_name=trim(in_dir)//'/satazi.txt'
  open(ui,file=file_name)
  !read(ui,*)     !!!跳过第一行表头
  DO i= 1, nobs
    read(ui,*) satazi(i,:)
  END DO
  CLOSE(ui)
  file_name=trim(in_dir)//'/solazen.txt'
  open(ui,file=file_name)
  !read(ui,*)     !!!跳过第一行表头
  DO i= 1, nobs
    read(ui,*) solazen(i,:)
  END DO
  CLOSE(ui)
  file_name=trim(in_dir)//'/solazi.txt'
  open(ui,file=file_name)
  !read(ui,*)     !!!跳过第一行表头
  DO i= 1, nobs
    read(ui,*) solazi(i,:)
  END DO
  CLOSE(ui)

  !*** read lat and lon ***
  file_name=trim(in_dir)//'/lat.txt'
  open(ui,file=file_name)
  DO i=1,nobs
      read(ui,*) lat(i,:)
  END DO
  CLOSE(ui)
  file_name=trim(in_dir)//'/lon.txt'
  open(ui,file=file_name)
  DO i=1,nobs
      read(ui,*) lon(i,:)
  END DO
  CLOSE(ui)

  file_name=trim(in_dir)//'/surf_height.txt'
  open(ui,file=file_name)
  DO i=1,nobs
      read(ui,*) isurf_height(i,:)
  END DO
  CLOSE(ui)
  file_name=trim(in_dir)//'/surf_type.txt'
  open(ui,file=file_name)
  DO i=1,nobs
      read(ui,*) isurf_type(i,:)
  END DO
  CLOSE(ui)

  !*** read cloudmask ***
  !open(ui,file='/g3/wanghao/hpf/write_obs_script/file/20180708000000/cloudmask.txt')
  !DO i=1,nobs
  !    read(ui,*) cloudmask(i)
  !END DO

  file_name=trim(TB_dir)//'/time.txt'
  open(ui,file=file_name)
  read(ui,*) yyyy,mn,dd,hh,mm
  CLOSE(ui)


  DO iobs=1,nobs
       rad(iobs)%yyyy          = yyyy
       rad(iobs)%mn            = mn
       rad(iobs)%dd            = dd
       rad(iobs)%hh            = hh
       rad(iobs)%mm            = mm
       rad(iobs)%ss            = ss
       rad(iobs)%iscanlines    = 15
       rad(iobs)%iscanpos      = 20
       rad(iobs)%rlat          = lat(iobs,1)
       rad(iobs)%rlon          = lon(iobs,1)
       rad(iobs)%isurf_height  = isurf_height(iobs,1)
       rad(iobs)%isurf_type    = isurf_type(iobs,1)
       rad(iobs)%satzen        = satazen(iobs,1)
       rad(iobs)%satazi        = satazi(iobs,1)
       rad(iobs)%solzen        = solazi(iobs,1)
       rad(iobs)%solazi        = solazi(iobs,1)
!       rad(iobs)%tbb           = 0
       rad(iobs)%tbb(1)        = tbb(iobs,1)
       rad(iobs)%tbb(2)        = tbb(iobs,2)
       rad(iobs)%tbb(3)        = tbb(iobs,3)-0.9941-0.025
       rad(iobs)%tbb(4)        = tbb(iobs,4)+9.4270-0.014
       rad(iobs)%tbb(5)        = tbb(iobs,5)-0.2168+0.0075
       rad(iobs)%tbb(6)        = tbb(iobs,6)+2.1168-0.0261
       rad(iobs)%tbb(7)        = tbb(iobs,7)+0.4015-0.0177
       rad(iobs)%tbb(8)        = tbb(iobs,8)+9.1665-0.1199
       rad(iobs)%tbb(9)        = tbb(iobs,9)
       rad(iobs)%tbb(10)        = tbb(iobs,10)
       rad(iobs)%tbb(11)        = tbb(iobs,11)
       rad(iobs)%tbb(12)        = tbb(iobs,12)
       rad(iobs)%tbb(13)        = tbb(iobs,13)
       rad(iobs)%tbb(14)        = tbb(iobs,14)
       rad(iobs)%tbb(15)        = tbb(iobs,15)+19
       rad(iobs)%tbb(16)        = tbb(iobs,16)+1.75
       rad(iobs)%tbb(17)        = tbb(iobs,17)-0.2
       rad(iobs)%tbb(18)        = tbb(iobs,18)+3
       rad(iobs)%tbb(19)        = tbb(iobs,19)+3
       rad(iobs)%tbb(20)        = tbb(iobs,20)-6
       rad(iobs)%tbb(21)        = tbb(iobs,21)-11
       rad(iobs)%tbb(22)        = tbb(iobs,22)-26
       rad(iobs)%tbb(23)        = tbb(iobs,23)
       rad(iobs)%tbb(24)        = tbb(iobs,24)+11
       rad(iobs)%tbb(25)        = tbb(iobs,25)+11
       rad(iobs)%tbb(26)        = tbb(iobs,26)+10
       rad(iobs)%tbb(27)        = tbb(iobs,27)+8
       rad(iobs)%tbb(28)        = tbb(iobs,28)+7
       rad(iobs)%tbb(29)        = tbb(iobs,29)+11
       rad(iobs)%tbb(30)        = tbb(iobs,30)+9
       rad(iobs)%tbb(31)        = tbb(iobs,31)+7
       rad(iobs)%tbb(32)        = tbb(iobs,32)+4.8
       rad(iobs)%tbb(33)        = tbb(iobs,33)+3.3
       rad(iobs)%tbb(34)        = tbb(iobs,34)-2.7
       rad(iobs)%tbb(35)        = tbb(iobs,35)+9
       rad(iobs)%tbb(36)        = tbb(iobs,36)+2.3
       rad(iobs)%tbb(37)        = tbb(iobs,37)-2
       rad(iobs)%tbb(38)        = tbb(iobs,38)+1.4
       rad(iobs)%tbb(39)        = tbb(iobs,39)+21.7
       rad(iobs)%tbb(40)        = tbb(iobs,40)-4.3
       rad(iobs)%tbb(41)        = tbb(iobs,41)-13.3
       rad(iobs)%tbb(42)        = tbb(iobs,42)-14.5
       rad(iobs)%iavhrr(1:13)  = MDI
       rad(iobs)%ihirsflag     = MDI
       rad(iobs)%iprepro(1:5)  = 0
       rad(iobs)%clfra         = RMDI     !clearsky_data(iobs)
       rad(iobs)%ts            = RMDI
       rad(iobs)%tctop         = RMDI
  END DO

  !*** write to outfiel ***
  file_name=trim(out_dir)//'fy4a_mwi'//trim(time(1:12))
  OPEN(UNIT=ui,FILE=TRIM(file_name),STATUS = "unknown",FORM="UNFORMATTED",IOSTAT = error, convert= "big_endian",ACCESS="sequential")
  !OPEN(ui,FILE=TRIM('/g3/wanghao/FY4A/SCRIPT/SRC/GRAPES_GFS/code_ceshi/file/outfile.txt'),FORM="unformatted",ACCESS="sequential")
  DO iobs=1,nobs
     IF(rad(iobs)%rlat /= llRDMItemp ) THEN
       print *, rad(iobs)%rlat
       WRITE(ui,IOSTAT = ioss) rad(iobs)%yyyy,rad(iobs)%mn,rad(iobs)%dd, &
                             rad(iobs)%hh,rad(iobs)%mm,rad(iobs)%ss, &
                             rad(iobs)%iscanlines,rad(iobs)%iscanpos, &
                             rad(iobs)%rlat,rad(iobs)%rlon, &
                             rad(iobs)%isurf_height,rad(iobs)%isurf_type, &
                             rad(iobs)%satzen,rad(iobs)%satazi,rad(iobs)%solzen,rad(iobs)%solazi, &
                             rad(iobs)%tbb, &
                             rad(iobs)%iavhrr,rad(iobs)%ihirsflag, &
                             rad(iobs)%iprepro, &
                             rad(iobs)%clfra, &
                             rad(iobs)%ts, &
                             rad(iobs)%tctop
     ENDIF
  ENDDO
  CLOSE(ui)

  !*** END preprocess
END SUBROUTINE process
