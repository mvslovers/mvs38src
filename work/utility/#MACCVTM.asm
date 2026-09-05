*  NUCLEUS FIXUP                                                                
IDAPLHD                                                                         
IDAPLH                                                                          
AMBL=IDAAMBL                                                                    
GSPL                                                                            
LSPL                                                                            
PCBR                                                                            
SPCT                                                                            
WSAC                                                                            
WSAG                                                                            
WSAL                                                                            
ACA                                                                             
AIA                                                                             
DEB                                                                             
EDT                                                                             
IOB                                                                             
PCB                                                                             
SGT                                                                             
SPL                                                                             
VCB                                                                             
IOMX=IDAIOMBX                                                                   
IOM=IOMB                                                                        
IDAIOMBX=IOMX                                                                   
LDA                                                                             
IDAAMBL=IDAAMBL                                                                 
AMBX=IDAAMBXN                                                                   
AMB=IDAAMB                                                                      
IDAAMB=IDAAMB                                                                   
PLHID=IDAPLHDR                                                                  
PLHCNT=IDAPLHDR                                                                 
PLHELTH=IDAPLHDR                                                                
PLHDRREQ=IDAPLHDR                                                               
PLHDRMAX=IDAPLHDR                                                               
PLHDRCUR=IDAPLHDR                                                               
PLHIOSDQ=IDAPLHDR                                                               
PLH=IDAPLHD                                                                     
=IOMEEXIT=IOMFL+1                                                               
=IOMEOVW=IOMSTIND                                                               
=IOMIRBSW=IOMFL+1                                                               
=IOMNE=IOMFL                                                                    
=IOMPGFIX=IOMFL                                                                 
=IOMSRBM=IOMSTIND                                                               
=IOMSR=IOMSTIND                                                                 
=IOMXEOVW=IOMXFLGS                                                              
=PLHASYRQ=PLHFLG1                                                               
LVSMFLAG=LDA                                                                    
PASCBSV=LDA                                                                     
ASDPQE=LDA                                                                      
GMFMWKAR=LDA                                                                    
BRANCHSV=LDA                                                                    
SAVEREG2=LDA                                                                    
BSAVE=LDA                                                                       
FSAVE=LDA                                                                       
G4KSAVE=LDA                                                                     
FBQSAVE=LDA                                                                     
GMREPSAV=LDA                                                                    
GFRESAVE=LDA                                                                    
OBFRSAVE=LDA                                                                    
CSAVE=LDA                                                                       
CFAPWKAR=LDA                                                                    
LSQAPTR=LDA                                                                     
VVREGSZ=LDA                                                                     
CURRGNTP=LDA                                                                    
-IOMBADR                                                                        
-RCACOPY                                                                        
-RCAPTR                                                                         
=AMBCREAT=AMBFLG1                                                               
=AMBLFIX=AMBLTYPE                                                               
=AMBLSR=AMBAFLG                                                                 
=AMBGSR=AMBAFLG                                                                 
=AMBICI=AMBAFLG                                                                 
=AMBCAT=AMBINFL                                                                 
=RCAABEND=RCAFLAGS                                                              
=RCADISP=RCAFLAGS                                                               
=RCASAL=RCAFLAGS                                                                
=RCALL=RCAFLAGS                                                                 
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
+         IDAAMBXN ,                                           IDAAMBXN         
+         IDAAMBL  ,                                           IDAAMBL          
+         IDAAMB   ,                                           IDAAMB           
+         IDAIOMB  ,                                           IOMB             
+*        IDAIOMB  ,                                           IDAIOMBX         
+         IDAPLH   ,                                           IDAPLHDR         
+         IDAPLH   ,                                           IDAPLHD          
+         IEFAB421 ,                                           EDT              
+         IEZDEB   LIST=YES                                    DEB              
+         IEZIOB   ,                                           IOB              
+         IHALDA   DSECT=YES                                   LDA              
+         IHAPCB   ,                                           PCB              
+         IHAPCBR  ,                                           PCBR             
+         IHARCA   ,                                           RCA              
+         IHASGTE  ,                                           SGT              
+         IHASPCT  ,                                           SPCT             
+         IHASPL   ,                                           GSPL             
+         IHASPL   ,                                           LSPL             
+         IHASPL   ,                                           SPL              
+         IHAVCB   ,                                           VCB              
+         IHAWSAVT CLASS=CPU                                   WSAC             
+         IHAWSAVT CLASS=GLOBAL                                WSAG             
+         IHAWSAVT CLASS=LOCAL                                 WSAL             
+         ILRACA   ,                                           ACA              
+         ILRAIA   ,                                           AIA              
