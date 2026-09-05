*                                                                               
* CONVERT THESE DSECT PREFIXS = MEANS SUBSTITUTE THIS VALUE FOR BASE            
* ORDER CAN MATTER SEE AMB/AMBL/AMBX                                            
* TODO: CATCH AND COMMENT = EQUATES FOR NOW IEZABPL=IEZABPL WORKS               
*                                                                               
ABP=IEZABPL                                                                     
AIA                                                                             
IEZABPL=IEZABPL                                                                 
AMBL=IDAAMBL                                                                    
IDAAMBL=IDAAMBL                                                                 
AMBX=IDAAMBXN                                                                   
IOMX=IDAAMBXN                                                                   
IDAIOMBX=IDAAMBXN                                                               
AMB=IDAAMB                                                                      
IDAAMB=IDAAMB                                                                   
AMD=IDAAMDSB                                                                    
IDAAMDSB=IDAAMDSB                                                               
ASCB                                                                            
ASM=ASMVT                                                                       
ASH=ASMHD                                                                       
ASVT                                                                            
ASXB                                                                            
CAT                                                                             
CCT                                                                             
CCC=CCT                                                                         
CCV=CCT                                                                         
CRCA                                                                            
CSD                                                                             
CVTPTR=0                                                                        
CVT                                                                             
CIW=CIWA                                                                        
DMDT                                                                            
*DCB=IHADCB                                                                     
*IHADCB                                                                         
DDR=DDRCOM                                                                      
EPAT                                                                            
EPDT                                                                            
RMEPB=EPDT                                                                      
EPST                                                                            
EWA                                                                             
EWD=EWAHDR                                                                      
FLC=PSA                                                                         
FRRS=FRRS                                                                       
JFCB=IEFJFCBN                                                                   
JSCB=IEZJSCB                                                                    
ICT                                                                             
ICC=ICT                                                                         
ICV=ICT                                                                         
IOS=IOSB                                                                        
IOC=IOCOM                                                                       
IRB                                                                             
IQE=IQESECT                                                                     
LCCA                                                                            
LRB                                                                             
MCT                                                                             
NVT                                                                             
OUCB                                                                            
OUSB                                                                            
PCBR                                                                            
PCB                                                                             
PCCAT00P=PCCAVT                                                                 
PCCAVT                                                                          
PCCA                                                                            
PFT=PFTE                                                                        
PGT=PGTPTE                                                                      
PRB                                                                             
PSA                                                                             
PVT                                                                             
PWA                                                                             
RB=RBBASIC                                                                      
RCA                                                                             
RMCA                                                                            
RMCB                                                                            
RMCT                                                                            
RMEX                                                                            
RMPL                                                                            
RMPT                                                                            
RMSB                                                                            
RMS=RMSPL                                                                       
RRPA                                                                            
RSM=RSMHD                                                                       
RTCT                                                                            
XSTAB=RBBASIC                                                                   
XRB=RBBASIC                                                                     
RPL=IFGRPL                                                                      
IFGRPL=IFGRPL                                                                   
RVT                                                                             
RWA                                                                             
SCB                                                                             
SIRB                                                                            
SVRB                                                                            
TIRB                                                                            
SDWA                                                                            
SRB=SRB                                                                         
TCB                                                                             
TQE                                                                             
XPT=XPTE                                                                        
UCBETI=UCBCMEXT                                                                 
UCBSTI=UCBCMEXT                                                                 
UCBDTI=UCBCMEXT                                                                 
UCBATI=UCBCMEXT                                                                 
UCBSNSCT=UCBCMEXT                                                               
UCBFLP1=UCBCMEXT                                                                
UCBRV041=UCBCMEXT                                                               
UCBCCWOF=UCBCMEXT                                                               
UCBPMSK=UCBCMEXT                                                                
UCBMFCNT=UCBCMEXT                                                               
UCBASID=UCBCMEXT                                                                
UCBMIHTI=UCBCMEXT                                                               
UCBWTOID=UCBCMEXT                                                               
UCBDDT=UCBCMEXT                                                                 
UCBMIHPB=UCBMIHTI                                                               
UCB3UREC=UCBTBYT3                                                               
UCBMIHSF=UCBMIHTI                                                               
UCB=UCB                                                                         
VSL                                                                             
*                                                                               
*    DON'T CONVERT THESE SYMBOLS AS THEY ARE                                    
*    NOT PART OF THEIR PREFIX DSECT                                             
*                                                                               
-AIAQUEUE                                                                       
-ASCBADR                                                                        
-ASMEXIT                                                                        
-ASMCALL                                                                        
-ASCBPTR                                                                        
-ASCBTEST                                                                       
-ASCBLOOP                                                                       
-ASCBFQUB                                                                       
-ASCBQFLG                                                                       
-ASCBSAVE                                                                       
-ASCBADD                                                                        
-ASMCK                                                                          
-ASMVTPTR                                                                       
-ASXBPTR                                                                        
-ASVTPTR                                                                        
-DDRCOMWK                                                                       
-DDRPTR                                                                         
-FRRSRMRT                                                                       
-FRRSALOC                                                                       
-FRRSAREA                                                                       
-FRRSAVE                                                                        
-FRRSQA                                                                         
-FRRSCDPT                                                                       
-FRRSALLC                                                                       
-FRRSRBPT                                                                       
-FRRSTNSM                                                                       
-FRRSTPRS                                                                       
-FRRSIGP                                                                        
-FRRSYMSK                                                                       
-FRRSUCB                                                                        
-FRRSAPTR                                                                       
-FRRSVR14                                                                       
-IOSGENSB                                                                       
-IOCX                                                                           
-IOCALFLG                                                                       
-IOCHAIN                                                                        
-IOQPTR                                                                         
-IOSBPTR                                                                        
-IOSBYTE                                                                        
-IOSCCHH                                                                        
-IOSVAIA                                                                        
-LCCAPTR                                                                        
-LRBPTR                                                                         
-LRBUCBDP                                                                       
-IRBTCBIN                                                                       
-OUCBACTW                                                                       
-OUCBPTR                                                                        
-OUXBPTR                                                                        
-PCBLOOP                                                                        
-PCBPREFR                                                                       
-PCBRLOOP                                                                       
-PCBRPTR                                                                        
-PCCAPTR                                                                        
-PFTENQ                                                                         
-PGTEADDR                                                                       
-PGTABLE                                                                        
-PVTCLOBR                                                                       
-PVTADDR                                                                        
-PWAPTR                                                                         
-RBNCALC                                                                        
-RBPPSB                                                                         
-RCACOPY                                                                        
-RCAPTR                                                                         
-RMSPLPTR                                                                       
-RMCAPEND                                                                       
-RMCTACQH                                                                       
-RMCTALAW                                                                       
-RPLIOERR                                                                       
-RPLYAREA                                                                       
-RPLYCHAR                                                                       
-RPLYOVER                                                                       
-RPLYRJTD                                                                       
-RPLCONT                                                                        
-RPLYMOD                                                                        
-RPLACR                                                                         
-RVTPTR                                                                         
-RVTCBTRM                                                                       
-RVTPTREC                                                                       
-RWAPTR                                                                         
-SIRBLEN                                                                        
-SDWAWHERE                                                                      
-SDWADDR                                                                        
-SDWAPTR                                                                        
-SRBEEDRP                                                                       
-SRBPARM2                                                                       
-SRBVFLGS                                                                       
-SRBAASID                                                                       
-SRBVSAM                                                                        
-SRBLBLS                                                                        
-SRBVFIX                                                                        
-SRBATCB                                                                        
-SRBECB                                                                         
-SRBPTR                                                                         
-SRBQV                                                                          
-TCBFIELD                                                                       
-TCBRBPX                                                                        
-TCBPTR                                                                         
-TQEVALLH                                                                       
-TQEPTR                                                                         
-UCBADTAB                                                                       
-UCBOBS06                                                                       
-UCBONLI#                                                                       
-UCBVHRS#                                                                       
-UCBBOX#                                                                        
-UCBADDR                                                                        
-UCBIOQ                                                                         
-UCBPTR                                                                         
-VSLLOOP                                                                        
-XPTCEPT                                                                        
*                                                                               
* SUBSTITUTE SECOND LABEL FOR THE FIRST LABEL AND                               
*  *** ENSURE LABELS WITH SIMILIAR NAMES ARE IN                                 
*  *** LONGER TO SHORTER ORDER                                                  
*  *** FOR EXAMPLE:                                                             
*  *** =ABCD=XXX    THIS MUST PRECEED THE FOLLOWING NAME                        
*  *** =ABC=XXX                                                                 
*  IF ONE 1 BIT IN SECOND OPERAND (B'00100000'                                  
*     (B'00100000' TM/OI OR B'11011111' NI)                                     
*  SECOND LABEL BECOMES SECOND OPERAND                                          
*  USUALLY IF NOT DEFINED HERE PRODUCES                                         
*     IFO213 COMPLEXLY RELOCATABLE EXPRESSION                                   
*                                                                               
=AIAPAGDS=AIAFLG1                                                               
=AIASWPFX=AIAFLG1                                                               
=AIAPRIV=AIAFLG1                                                                
=AIALSQA=AIAFLG1                                                                
=ASMDUPLX=ASMFLAG1                                                              
=ASMPLPAF=ASMFLAG1                                                              
=ASMCOMMF=ASMFLAG1                                                              
=ASMQUICK=ASMFLAG2                                                              
=ASMNOLCL=ASMFLAG1                                                              
=ASMNOTPT=ASMFLAG2                                                              
=ASCBVEQR=ASCBRSMF                                                              
=ASCBFAIL=ASCBDSP1                                                              
=ASCBABNT=ASCBFLG1                                                              
=ASCBTYP1=ASCBFLG1                                                              
=ASCB1LPU=ASCBRSMF                                                              
=ASCB2LPU=ASCBRSMF                                                              
=ASCBCEXT=ASCBFLG2                                                              
=ASCBTMNO=ASCBRCTF                                                              
=ASCBTOFF=ASCBFLG1                                                              
=ASCBNSWP=ASCBFLG1                                                              
=ASCBNOQ=ASCBDSP1                                                               
=ASCBS3S=ASCBFLG1                                                               
=ASCBS2S=ASCBFLG2                                                               
=CATNOP=CATFLG                                                                  
=CIWNOPST=CIWFLG1                                                               
=CIWFIXC=CIWFLG1                                                                
=CIWLONG=CIWOPFL1                                                               
=CIWIERR=CIWIFLG2                                                               
=CIWFIX=CIWOPFL1                                                                
=CRCADIAG=CRCAFLGS                                                              
=CSDMP=CSDFLAGS                                                                 
=MCTASM1=MCTOFLGS                                                               
=MCTSQA1=MCTSFLGS                                                               
=MCTSQA2=MCTSFLGS                                                               
=IOCOMPTR=CVTIXAVL                                                              
=OUCBJSFS=OUCBUFL                                                               
=OUCBRSWP=OUCBUFL                                                               
=OUCBTSWC=OUCBUFL                                                               
=OUCBTSWP=OUCBUFL                                                               
=OUCBASW=OUCBAFL                                                                
=OUCBATR=OUCBTFL                                                                
=OUCBBIB=OUCBSFL                                                                
=OUCBCIM=OUCBEFL                                                                
=OUCBCTI=OUCBSFL                                                                
=OUCBDTA=OUCBYFL                                                                
=OUCBINC=OUCBTFL                                                                
=OUCBINP=OUCBTFL                                                                
=OUCBJSR=OUCBAFL                                                                
=OUCBLOG=OUCBYFL                                                                
=OUCBLWT=OUCBEFL                                                                
=OUCBMNT=OUCBYFL                                                                
=OUCBNQF=OUCBEFL                                                                
=OUCBOWT=OUCBEFL                                                                
=OUCBPVL=OUCBSFL                                                                
=OUCBQSC=OUCBEFL                                                                
=OUCBQSS=OUCBEFL                                                                
=OUCBRSM=OUCBCFL                                                                
=OUCBSTR=OUCBTFL                                                                
=OUCBSTT=OUCBYFL                                                                
=OUCBTRM=OUCBEFL                                                                
=PCBLLHLD=PCBRFLAG                                                              
=PCBRFAIL=PCBRFLAG                                                              
=PCBSRBMD=PCBFL1                                                                
=PCBIOCMP=PCBFL1                                                                
=PCBSUPRS=PCBFL2                                                                
=PCBFREAL=PCBFL2                                                                
=PCBRESET=PCBFL2                                                                
=PCBIOERR=PCBFL2                                                                
=PCBNOREC=PCBFL3                                                                
=PCBSWPIN=PCBFL3                                                                
=PCBSWPS1=PCBFL3                                                                
=PCBSWPS2=PCBFL3                                                                
=PCBSWPLS=PCBFL3                                                                
=PCBDFRLS=PCBFL3                                                                
=PCBRETRY=PCBRFLAG                                                              
=PCBGFAD=PCBFL2                                                                 
=PCBVIO=PCBFL2                                                                  
=PCBPEX=PCBFL1                                                                  
=PCBIOI=PCBFL1                                                                  
=PCBRPB=PCBRFLAG                                                                
=RBATNXIT=RBSTAB1                                                               
=RBTCBNXT=RBSTAB2                                                               
=RBNOCELL=RBCDFLGS                                                              
=RBCDSYNC=RBCDFLGS                                                              
=RBIQETP=RBSTAB2                                                                
=RBFACTV=RBSTAB2                                                                
=RBFTPRB=RBSTAB1                                                                
=RBETXR=RBSTAB2                                                                 
=RBATTN=RBSTAB2                                                                 
=RBFDYN=RBSTAB2                                                                 
=RBFTP=RBSTAB1                                                                  
=RBSCB=RBFLAGS1                                                                 
=RCAABEND=RCAFLAGS                                                              
=RCADISP=RCAFLAGS                                                               
* =RCAFXLD=RCANAME1                                                             
* =RCAGFAD=RCANAME4                                                             
* =RCAFREE=RCANAME5                                                             
* =RCAREP1=RCANAME6                                                             
* =RCAPFTE=RCANAME2                                                             
* =RCAPRSB=RCANAME7                                                             
* =RCAPRSR=RCANAME7                                                             
* =RCAPRSS=RCANAME7                                                             
* =RCAINV=RCANAME1                                                              
* =RCAOUT=RCANAME2                                                              
* =RCAPCB=RCANAME2                                                              
* =RCAGFA=RCANAME1                                                              
* =RCAPIX=RCANAME3                                                              
* =RCAFXL=RCANAME6                                                              
=RCASAL=RCAFLAGS                                                                
=RCALL=RCAFLAGS                                                                 
=RMPLTERM=RMPLFLG1                                                              
=RMPLRBPP=RMPLFLG1                                                              
=RMSNIP=RMSCID                                                                  
=RMSVCPU=RMSCID                                                                 
=RMSMCH=RMSCID                                                                  
=RMSBLDL=RMSACT                                                                 
=RMSLOAD=RMSACT                                                                 
=RMSSINIT=RMSACT                                                                
=RMSALLOC=RMSACT                                                                
=RMSDALOC=RMSACT                                                                
=RMSREGI=RMSACT                                                                 
=RMSREGD=RMSACT                                                                 
=RSMGFADD=RSMFLG1                                                               
=RSMIOCPC=RSMFLG1                                                               
=RSMIOCPU=RSMFLG1                                                               
=RSMCPNC=RSMFLG1                                                                
=RSMGFAD=RSMFLG1                                                                
=RSMFAIL=RSMFLG1                                                                
=RSMCPNU=RSMFLG1                                                                
=TCBACTIV=TCBXSCT1                                                              
=TCBNONPR=TCBFLGS1                                                              
=TCBSTPPR=TCBTSFLG                                                              
=TCBPNDSP=TCBFLGS5                                                              
=TCBEOTFM=TCBFBYT1                                                              
=TCBFETXR=TCBFLGS2                                                              
=TCBSTPP=TCBNDSP2                                                               
=TCBATT=TCBTSFLG                                                                
=TCBEOT=TCBFBYT1                                                                
=TCBS3A=TCBXSCT1                                                                
=TCBFC=TCBFLGS5                                                                 
=RMCTMFA=RMCTFLGS                                                               
=RMCTSTW=RMCTFLGS                                                               
=RRPAENB=RRPAFLG                                                                
=RRPAIPS=RRPAFLG+1                                                              
=RRPAWAR=RRPAFLG+1                                                              
=CCTCPUOT=CCTFLG1                                                               
=CCTALL=CCTFLG1                                                                 
=AMBCREAT=AMBFLG1                                                               
=AMBLFIX=AMBLTYPE                                                               
=AMBLSR=AMBAFLG                                                                 
=AMBGSR=AMBAFLG                                                                 
=AMBICI=AMBAFLG                                                                 
=AMBCAT=AMBINFL                                                                 
=ASCBTERM=ASCBFLG1                                                              
=ASCBPER=ASCBSRBM                                                               
=ASVTAVAL=ASVTENTY                                                              
=ASVTAVAI=ASVTFRST                                                              
=CIWOUTKR=CIWFLG1                                                               
=CIWKEPRL=CIWOPFL2                                                              
=CVTNIP=CVTOPTA                                                                 
=CVTGSDAB=CVTGSDA                                                               
=DCB=IHADCB                                                                     
=DMDTBLK1=DMDTGOOU                                                              
=DMDTBLK2=DMDTOUTU                                                              
=EPSTWM3=RMEPBWM3                                                               
=EPSTCL3=RMEPBCL3                                                               
=EPSTIL3=RMEPBIL3                                                               
=EWABDSNS=EWAFLG1                                                               
=EWADDMSG=EWAFLG1                                                               
=EWANORTY=EWARGFG1                                                              
=EWAMDR=EWAFLG2                                                                 
=EWDHADEF=EWDHAFLG                                                              
=EWDASNS=EWDSNS                                                                 
=EWDCORR=EWDSNS2                                                                
=EWDEDAT=EWDSNS2                                                                
=EWDMDA1=EWDSNS2                                                                
=EWDOFLO=EWDSNS1                                                                
=EWDSKCK=EWDSNS0                                                                
=EWDZLOG=EWDSNS2                                                                
=EWDEQU=EWDSNS0                                                                 
=EWDINT=EWDSNS0                                                                 
=EWDTCC=EWDSNS0                                                                 
=FRRSNEST=FRRSFLG1                                                              
=FRRSRCUR=FRRSFLG1                                                              
=IOSDIESE=IOSFLB                                                                
=IOSEQCHK=IOSSNS                                                                
=IOSPCHKB=IOSTSB                                                                
=IOSPGDPX=IOSPKEY                                                               
=IOSSMDB=IOSFLA                                                                 
=IOSECB3=IOSCOD                                                                 
=IOSECB7=IOSCOD                                                                 
=IOSIDR=IOSPKEY                                                                 
=IOSMSG=IOSFLB                                                                  
=IOSERR=IOSFLA                                                                  
=IOSLOG=IOSFLB                                                                  
=IOSBYP=IOSOPT                                                                  
=IOSEX=IOSFLA                                                                   
=IOSFP=IOSSNS+1                                                                 
=IOSM=IOSEEK                                                                    
=LCCAPDAT=LCCAIHR1                                                              
=LCCACRIN=LCCACREX                                                              
=LCCACREF=LCCACREX                                                              
=LCCACRST=LCCACREX                                                              
=LCCACRLM=LCCACREX                                                              
=LCCACLMS=LCCACRFL                                                              
=LCCACRTM=LCCACRFL                                                              
=LCCACRRT=LCCACREX                                                              
=LCCACRLE=LCCACREX                                                              
=LCCAVARY=LCCACRFL                                                              
=LCCACRRM=LCCACREX                                                              
=LCCAEXSN=LCCASPN1                                                              
=LCCARSTR=LCCASPN1                                                              
=LCCAPTLB=LCCASPN1                                                              
=LCCASRBM=LCCADSF2                                                              
=LCCATSPN=LCCASPN1                                                              
=LCCATIMR=LCCADSF1                                                              
=LCCAACR=LCCADSF1                                                               
=LRBMITOD=LRBMINTM                                                              
=LRBMICKC=LRBMINTM                                                              
=LRBMICTM=LRBMINTM                                                              
=LRBMHSTO=LRBMHARD                                                              
=LRBMHSPF=LRBMHARD                                                              
=LRBMSEXD=LRBMSOFT                                                              
=LRBMHINV=LRBMHARD                                                              
=LRBMHIPD=LRBMHARD                                                              
=LRBMHHRD=LRBMHARD                                                              
=LRBMHSD=LRBMHARD                                                               
=LRBMCCF=LRBMEDC                                                                
=LRBMVED=LRBMCIC+3                                                              
=LRBMVST=LRBMCIC+3                                                              
=LRBMVFA=LRBMCIC+3                                                              
=LRBMVFP=LRBMCIC+3                                                              
=LRBMVGR=LRBMCIC+3                                                              
=LRBMVWP=LRBMCIC+2                                                              
=LRBMFSE=LRBMCIC+2                                                              
=LRBMFKE=LRBMCIC+2                                                              
=LRBMIBU=LRBMCIC+1                                                              
=LRBMIDY=LRBMCIC+1                                                              
=LRBMFPD=LRBMCIC                                                                
=LRBMFSD=LRBMCIC                                                                
=LRBMFCD=LRBMCIC                                                                
=LRBNCEM=LRBHSW2                                                                
=LRBNDEM=LRBHSW2                                                                
=OUCBAPG=OUCBAFL                                                                
=OUCBAXS=OUCBYFL                                                                
=OUCBCPL=OUCBAFL                                                                
=OUCBENQ=OUCBSFL                                                                
=OUCBGOB=OUCBQFL                                                                
=OUCBGOI=OUCBQFL                                                                
=OUCBGOO=OUCBQFL                                                                
=OUCBINV=OUCBSFL                                                                
=OUCBJSAS=OUCBUFL                                                               
=OUCBNSWI=OUCBSFL                                                               
=OUCBNSW=OUCBSFL                                                                
=OUCBOFF=OUCBQFL                                                                
=OUCBOUT=OUCBQFL                                                                
=OUCBPSTR=OUCBYFL                                                               
=OUCBRDY=OUCBCFL                                                                
=OUCBRMA=OUCBAFL                                                                
=OUCBSCN=OUCBSFL                                                                
=PCBROOT=PCBFL1                                                                 
=PCBRLPA=PCBFXC                                                                 
=PCBRLOAD=PCBRFLAG                                                              
=PCBRFECB=PCBRFLAG                                                              
=PCCACALT=PCCACHS2                                                              
=PCCACCHA=PCCACHBL                                                              
=PCCACCHV=PCCACHVA                                                              
=PCCACCMD=PCCACHVA                                                              
=PCCACCNT=PCCACHPF                                                              
=PCCACCPU=PCCACHBL                                                              
=PCCACCRA=PCCACHS2                                                              
=PCCACCUE=PCCACHBL                                                              
=PCCACDAV=PCCACHVA                                                              
=PCCACFRR=PCCACHS1                                                              
=PCCACF11=PCCACHF1                                                              
=PCCACF12=PCCACHF1                                                              
=PCCACF13=PCCACHF1                                                              
=PCCACF14=PCCACHF1                                                              
=PCCACF16=PCCACHF1                                                              
=PCCACF23=PCCACHF2                                                              
=PCCACF24=PCCACHF2                                                              
=PCCACF25=PCCACHF2                                                              
=PCCACF26=PCCACHF2                                                              
=PCCACF27=PCCACHF2                                                              
=PCCACF28=PCCACHF2                                                              
=PCCACHIB=PCCACHRB                                                              
=PCCACIBC=PCCACHS1                                                              
=PCCACINB=PCCACHRB                                                              
=PCCACINT=PCCACHPF                                                              
=PCCACIOR=PCCACHS2                                                              
=PCCACMOD=PCCACHS2                                                              
=PCCACNLG=PCCACHS2                                                              
=PCCACNLS=PCCACHS1                                                              
=PCCACNOR=PCCACHPF                                                              
=PCCACNRE=PCCACHS1                                                              
=PCCACSCU=PCCACHBL                                                              
=PCCACSIB=PCCACHRB                                                              
=PCCACSQV=PCCACHVA                                                              
=PCCACSTG=PCCACHBL                                                              
=PCCACTIB=PCCACHRB                                                              
=PCCACUCB=PCCACHS1                                                              
=PCCACUNS=PCCACHVA                                                              
=PCCACURC=PCCACHS2                                                              
=PCCAISRB=PCCACHF3                                                              
=PCCASYNC=PCCATMFL                                                              
=PCCASLCK=PCCACHF3                                                              
=PCCANUCC=PCCACCE                                                               
=PCCANUTD=PCCATODE                                                              
=PCCANFCC=PCCACCE                                                               
=PCCANFTD=PCCATODE                                                              
=PCCANFIN=PCCAINTE                                                              
=PCCAINIT=PCCATMFL                                                              
=PCCANUIN=PCCAINTE                                                              
=PCCAMINT=PCCATMFL                                                              
=PCCAVKIL=PCCATMFL                                                              
=PCCARMS=PCCARMSB                                                               
=PCCAMCC=PCCATMFL                                                               
=PCCAIO=PCCAATTR                                                                
=PFTBADPG=PFTFLAG1                                                              
=PFTDFRLS=PFTFLAG2                                                              
=PFTOFFLN=PFTFLAG2                                                              
=PFTOFINT=PFTFLAG1                                                              
=PFTONAVQ=PFTFLAG1                                                              
=PFTPCBSI=PFTFLAG1                                                              
=PFTVRPLT=PFTFLAG1                                                              
=PFTVRALC=PFTFLAG1                                                              
=PFTVRINT=PFTFLAG1                                                              
=PFTSTEAL=PFTFLAG2                                                              
=PFTPREF=PFTFLAG2                                                               
=PFTIRRG=PFTFLAG2                                                               
=PFTLSQA=PFTFLAG1                                                               
=PFTVR=PFTFLAG2                                                                 
=PGTPAM=PGTBITS                                                                 
=PGTPVM=PGTBITS                                                                 
=PSAIOSUP=PSASUP3                                                               
=PSAPSREG=PSASUP3                                                               
=PSAULCMS=PSASUP3                                                               
=PSALDWT=PSASUP4                                                                
=PSASLIP=PSASUP3                                                                
=PSAESTA=PSASUP3                                                                
=PSAPI2=PSASUP3                                                                 
=PSASPR=PSASUP3                                                                 
=PSAACR=PSASUP2                                                                 
=PSALCR=PSASUPER                                                                
=PSARTM=PSASUPER                                                                
=PVTSRBIU=PVTFLAG1                                                              
=PVTAPREF=PVTFLAG1                                                              
=PVTPCBLT=PVTFLAG1                                                              
=PVTRSMGM=PVTFLAG2                                                              
=PVTBGMS=PVTFLAG1                                                               
=PVTPMSG=PVTFLAG1                                                               
=PVTLSI=PVTFLAG1                                                                
=PVTSIT=PVTFLAG1                                                                
=PVTPTR=CVTPVTP                                                                 
=RMCTCPS1=RMCTFLGS                                                              
=RMEPBCAP=EPAT                                                                  
=RMEPBCTL=RMEX                                                                  
=RMEPRCR=RMEPFLG+3                                                              
=RMEPACN=RMEPFLG+3                                                              
=RMEPTMD=RMEPFLG+3                                                              
=RRPACTL=RRPAFLG+1                                                              
=RRPARFI=RRPAFLG+1                                                              
=RRPASVC=RRPAFLG                                                                
=RRPAOPT=RRPAFLG                                                                
=SDWACLUP=SDWAERRD                                                              
=SDWAERFL=SDWAERRD                                                              
=SDWADLST=SDWADPFS                                                              
=SDWAFLLK=SDWAACF4                                                              
=SDWAFREE=SDWAACF2                                                              
=SDWALDIS=SDWAERRB                                                              
=SDWAMCHK=SDWAERRA                                                              
=SDWAMCIV=SDWAERRD                                                              
=SDWAPCHK=SDWAERRA                                                              
=SDWAPERC=SDWAERRC                                                              
=SDWARCRD=SDWAACF2                                                              
=SDWARKEY=SDWAERRA                                                              
=SDWARPIV=SDWAERRD                                                              
=SDWASALL=SDWAACF3                                                              
=SDWASPIN=SDWAACF2                                                              
=SDWASRBM=SDWAERRB                                                              
=SDWASTAF=SDWAERRC                                                              
=SDWASVCE=SDWAERRA                                                              
=SDWATEXC=SDWAERRA                                                              
=SDWATYP1=SDWAERRB                                                              
=SDWAUPRG=SDWAACF2                                                              
=SDWADISP=SDWAACF3                                                              
=SDWACMS=SDWAACF4                                                               
=SDWAREQ=SDWACMPF                                                               
=SDWAEAS=SDWAERRC                                                               
=SDWAHEX=SDWADPVA                                                               
=SDWAIO2=SDWAEMK2                                                               
=SDWAEBC=SDWADPVA                                                               
=TCBABTRM=TCBFLGS3                                                              
=TCBFPRAP=TCBFBYT2                                                              
=TCBRTM2=TCBFBYT1                                                               
=TCBTQET=TCBTME                                                                 
=TCBABWF=TCBFLGS5                                                               
=TCBABGM=TCBFLGS3                                                               
=TCBLLH=TCBFBYT1                                                                
=TCBFX=TCBFLGS1                                                                 
=TQEXITSP=TQEFLGS                                                               
=TQEINCOM=TQEFLGS                                                               
=TQECOMP=TQEFLGS2                                                               
=TQEMIDN=TQEFLGS2                                                               
=TQEUSER=TQEFLGS2                                                               
=TQECRH=TQEFLGS2                                                                
=TQEDIE=TQEFLGS3                                                                
=TQEDUM=TQEFLGS2                                                                
=TQEOFF=TQEFLGS                                                                 
=TQEOPT=TQEFLGS2                                                                
=TQETYPE=TQEFLGS                                                                
=TQEMF1=TQEFLGS2                                                                
=TQELM=TQEFLGS2                                                                 
=UCBALTPH=UCBFL5                                                                
=UCBDDRSW=UCBFLC                                                                
=UCBIORST=UCBFLB                                                                
=UCBBUSYD=UCBFLA                                                                
=UCBMMSGP=UCBJBNR                                                               
=UCBVRDEV=UCBJBNR                                                               
=UCBMOUNT=UCBDMCT                                                               
=UCBMTPXP=UCBWGT                                                                
=UCBTICBT=UCBFLC                                                                
=UCBUSING=UCBFLA                                                                
=UCB3DACC=UCBTBYT3                                                              
=UCB3TAPE=UCBTBYT3                                                              
=UCB3DISP=UCBTBYT3                                                              
=UCBENVRD=UCBFL5                                                                
=UCB2OPT4=UCBTBYT2                                                              
=UCBRVDEV=UCBTBYT2                                                              
=UCBRESVH=UCBFLB                                                                
=UCBVORSN=UCBWGT                                                                
=UCBRESVP=UCBFL4                                                                
=UCBCRHRV=UCBFLB                                                                
=UCBONLI=UCBSTAT                                                                
=UCBPGFL=UCBSTAB                                                                
=UCBACTV=UCBFLA                                                                 
=UCBALOC=UCBSTAT                                                                
=UCBSYSR=UCBSTAT                                                                
=UCBUDE#=UCBFLC                                                                 
=UCBAMV#=UCBFL5                                                                 
=UCBSAP#=UCBFLA                                                                 
=UCBBOX=UCBJBNR                                                                 
=UCBDUC=UCBJBNR                                                                 
=UCBUDE=UCBFLC                                                                  
=UCBSAP=UCBFLA                                                                  
=UCBAMV=UCBFL5                                                                  
=UCBBSY=UCBFLA                                                                  
=UCBNRY=UCBFLA                                                                  
=UCBPST=UCBFLA                                                                  
=UCBRPS=UCBTBYT2                                                                
=UCBRRP=UCBFL4                                                                  
=UCBRR=UCBTBYT2                                                                 
=UCBMIHPB=UCBMIHTI                                                              
=UCB3UREC=UCBTBYT3                                                              
=UCBMIHSF=UCBMIHTI                                                              
=VSLFREE=VSLFLAG1                                                               
=XPTDEFER=XPTFLAGS                                                              
=XPTIOERR=XPTFLAG2                                                              
=XPTPOINP=XPTFLAG2                                                              
=XPTVALID=XPTFLAG2                                                              
=XPTVIOLP=XPTFLAGS                                                              
=XPTVIO=XPTFLAGS                                                                
=XPTXAV=XPTFLAGS                                                                
=XPTCKF=XPTFLAGS                                                                
*                                                                               
* DSECT DEFINITIONS INCLUDED ONLY WHEN THE PREFIX                               
* IN THE TRIGGERING COLUMN IS ENCOUNTERED                                       
* THOSE ENTRIES WITH NO PREFIX (LIKE RX ARE ALWAYS INSERTED)                    
*                                                                               
*         DSECT    OPERANDS                                    PREFIX           
*                                                                               
+         CVT      DSECT=YES,LIST=YES                          CVT              
+         EWAMAP   ,                                           EWA              
+         EWDMAP   ,                                           EWA              
+         IDAAMBL  ,                                           IDAAMBL          
+         IDAAMB   ,                                           IDAAMB           
+         IDAAMBXN ,                                           IDAAMBXN         
+         IDAAMDSB ,                                           IDAAMDSB         
+         IECDCAT  ,                                           CAT              
+         IECDCRCA ,                                           CRCA             
+         IECDIOCM ,                                           IOCOM            
+         IECDIOSB ,                                           IOSB             
+         IFGRPL   ,                                           IFGRPL           
+         IKJRB    ,                                           RBBASIC          
+RBIQENA  EQU      RBSTAB2                                     RBBASIC          
+         IKJTCB   LIST=YES                                    TCB              
+UCB      DSECT    ,                                           UCB              
+         IEFUCBOB LIST=YES                                    UCB              
+JFCB     DSECT    ,                                           JFCB             
+         IEFJFCBN ,                                           JFCB             
+         IEZJSCB  ,                                           JSCB             
+         IGFRWA   ,                                           RWA              
+         IGFPWA   ,                                           PWA              
+         IGFRMS   LIST=YES                                    RMSPL            
+         IHAASCB  ,                                           ASCB             
+         IHAASVT  ,                                           ASVT             
+         IHAASXB  ,                                           ASXB             
+         IHACSD   ,                                           CSD              
+         IEACIWA  ,                                           CIWA             
+         IHADDR   LIST=YES                                    DDR              
+         IHADQE   ,                                           DQE              
+         IHAFBQE  ,                                           FBQE             
+         IHAFOE   ,                                           FOE              
+         IHAFRRS  ,                                           FRRS             
+         IHAGDA   ,                                           GDA              
+         IHAGSDA  ,                                           GSDA             
+         IHAIQE   ,                                           IQE              
+         IHANVT   ,                                           NVT              
+         IHALCCA  ,                                           LCCA             
+         IHALRB   LIST=YES                                    LRB              
+         IHAOUXB  ,                                           OUXB             
+         IHAOUSB  ,                                           OUSB             
+         IHAPCBR  ,                                           PCBR             
+         IHAPCB   ,                                           PCB              
+         IHAPCCAT ,                                           PCCAVT           
+         IHAPCCA  ,                                           PCCA             
+         IHAPFTE  ,                                           PFTE             
+         IHAPGTE  ,                                           PGTPTE           
+         IHAPSA   ,                                           PSA              
+         IHAPVT   ,                                           PVT              
+         IHARCA   ,                                           RCA              
+         IHARMPL  ,                                           RMPL             
+         IHARTCT  ,                                           RTCT             
+         IHARVT   ,                                           RVT              
+         IHASCB   ,                                           SCB              
+         IHASDWA  ,                                           SDWA             
+         IHASRB   ,                                           SRB              
+         IHATQE   ,                                           TQE              
+         IHAXPTE  ,                                           XPTE             
+         ILRAIA   ,                                           AIA              
+         ILRASMHD ,                                           ASH              
+         ILRASMVT ,                                           ASMVT            
+         IEZBITS  ,                                           CCT              
+         IRACCT   ,                                           CCT              
+         IRADMDT  ,                                           DMDT             
+         IRAEPAT  ,                                           EPAT             
+         IRAEPDT  ,                                           EPDT             
+         IRAEPST  ,                                           EPST             
+         IRAICT   ,                                           ICT              
+         IRAMCT   ,                                           MCT              
+         IRAOUCB  ,                                           OUCB             
+         IRARMCA  ,                                           RMCA             
+         IRARMCB  ,                                           RMCB             
+         IRARMCT  ,                                           RMCT             
+         IRARMEP  ,                                           RMEP             
+         IRARMEX  ,                                           RMEX             
+         IRARMPT  ,                                           RMPT             
+         IRARMSB  ,                                           RMSB             
+         IRARRPA  ,                                           RRPA             
+         IHARSMHD ,                                           RSMHD            
+         IHAVSL   ,                                           VSL              
+R0       EQU   0                       REGISTER 0                              
+R1       EQU   1                       REGISTER 1                              
+R2       EQU   2                       REGISTER 2                              
+R3       EQU   3                       REGISTER 3                              
+R4       EQU   4                       REGISTER 4                              
+R5       EQU   5                       REGISTER 5                              
+R6       EQU   6                       REGISTER 6                              
+R7       EQU   7                       REGISTER 7                              
+R8       EQU   8                       REGISTER 8                              
+R9       EQU   9                       REGISTER 9                              
+R10      EQU   10                      REGISTER 10                             
+R11      EQU   11                      REGISTER 11                             
+R12      EQU   12                      REGISTER 12                             
+R13      EQU   13                      REGISTER 13                             
+R14      EQU   14                      REGISTER 14                             
+R15      EQU   15                      REGISTER 15                             
