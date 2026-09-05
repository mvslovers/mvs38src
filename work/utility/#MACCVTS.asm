* SADLY IN CASE OF EQUATE STYLE CODING WE END UP WITH LABEL-PREFIX              
* SO WE MUST EDIT OUT THE -PREFIX                                               
ATT                                                                             
HMASMATT=ATT                                                                    
CCA                                                                             
HMASMCCA=CCA                                                                    
CRP                                                                             
HMASMCRP=CRP                                                                    
GTP                                                                             
HMASMGTP=GTP                                                                    
MCB                                                                             
HMASMMCB=MCB                                                                    
ICT                                                                             
HMASMICT=ICT                                                                    
IOP                                                                             
HMASMIOP=IOP                                                                    
LIST=LPR                                                                        
PRL                                                                             
HMASMPRL=PRL                                                                    
RVA                                                                             
HMASMRVA=RVA                                                                    
SCP                                                                             
HMASMSCP=SCP                                                                    
TBLX                                                                            
TBL=TBLX                                                                        
TSL                                                                             
+         HMASMCCA TYPE=EQU                                    CCA              
+         HMASMCRP TYPE=EQU                                    CRP              
+         HMASMGTP TYPE=EQU                                    GTP              
+         HMASMLPR TYPE=EQU                                    LPR              
+         COPY  HMASMICT                                       ICT              
+         HMASMIOP TYPE=EQU                                    IOP              
+         COPY  HMASMMCB                                       MCB              
+         HMASMPRL TYPE=EQU                                    PRL              
+         COPY  HMASMRVA                                       RVA              
+         HMASMSCP TYPE=EQU                                    SCP              
+         HMASMTBX TYPE=EQU                                    TBLX             
+         HMASMTSL TYPE=EQU                                    TSL              
+ATT      DSECT ,                                              ATT              
+         HMASMATT ,                                           ATT              
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
