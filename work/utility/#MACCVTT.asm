*                                                                               
* CONVERT THESE DSECT PREFIXS = MEANS SUBSTITUTE THIS VALUE FOR BASE            
* ORDER CAN MATTER SEE AMB/AMBL/AMBX                                            
* TODO: CATCH AND COMMENT = EQUATES FOR NOW IEZABPL=IEZABPL WORKS               
*                                                                               
AVT=IEDQAVTD                                                                    
TCX=IEDQTCX                                                                     
LCB=IEDQLCB                                                                     
REC=IEDQRECB                                                                    
TRM=IEDTRM                                                                      
*                                                                               
*    DON'T CONVERT THESE SYMBOLS AS THEY ARE                                    
*    NOT PART OF THEIR PREFIX DSECT                                             
*                                                                               
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
*                                                                               
* DSECT DEFINITIONS INCLUDED ONLY WHEN THE PREFIX                               
* IN THE TRIGGERING COLUMN IS ENCOUNTERED                                       
* THOSE ENTRIES WITH NO PREFIX (LIKE RX ARE ALWAYS INSERTED)                    
*                                                                               
*         DSECT    OPERANDS                                    PREFIX           
*                                                                               
+         TAVTD    ,                                           AVT              
+         TTCXD    ,                                           TCX              
+         TLCBD    ,                                           LCB              
+         TRECBD   ,                                           REC              
+         TTRMD    ,                                           TRM              
