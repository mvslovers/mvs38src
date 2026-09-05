         MACRO                                                          00000050
&LAB     OTHERWSE                                                       00000100
.*                                                                      00000150
.* THIS MACRO IS ONE OF A RELATED SET OF MACROS WHICH ENGINEER THE              
.* SELECTED EXECUTION OF CODE DEPENDING ON THE CONTENTS OF A FIELD.             
.*                                                                              
.* THE GENERAL STRUCTURE IS AS FOLLOWS -                                        
.*    EVALUATE OPCODE,OP1(,OP2.REP.TYPE.LTH)                                    
.*      WHEN   OP2REST,OP2REST                                                  
.*      WHEN   OP2REST-OP2REST,OP2REST                                          
.*      OTHERWSE                                                                
.*    ENDEVAL                                                                   
.*                                                                      00000500
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00000550
         GBLA  &ON(16)                                                  00000600
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00000650
         GBLA  &OE(16)                                                  00000700
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00000750
         GBLA  &OD                                                      00000800
.* OPTELSE INDICATOR FOR EACH POSSIBLE DEPTH                            00000850
         GBLB  &OELSE(16)                                               00000900
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00000950
         GBLB  &OPTN(16)                                                00001000
.*                                                                      00001050
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00001100
&LAB     EQU   *                                                        00001150
.END0    ANOP                                                           00001200
.IF0A    AIF   (&OD NE 0).END0A                                         00001250
         MNOTE 16,'OPTION MISSING'                                      00001300
         MEXIT                                                          00001350
.END0A   ANOP                                                           00001400
.IF1     AIF   (&OD LE 16).END1                                         00001450
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00001500
         MEXIT                                                          00001550
.END1    ANOP                                                           00001600
.* SET EXIT FOR PREVIOUS CODE                                           00001650
         BRU   @D&OD.E&OE(&OD)                                          00001700
.* SET LABEL FOR ENTRY                                                  00001750
@D&OD.N&ON(&OD) EQU   *                                                 00001800
.* INCREMENT LABEL GENERATION NUMBER                                    00001850
&ON(&OD) SETA  &ON(&OD)+1                                               00001900
.* SET OPTION INDICATOR OFF                                             00001950
&OPTN(&OD) SETB  (0)                                                    00002000
.IF1A    AIF   ((&OELSE(&OD)) EQ (0)).END1A                             00002050
         MNOTE 16,'DUPLICATE OTHERWSE'                                  00002100
         MEXIT                                                          00002150
.END1A   ANOP                                                           00002200
&OELSE(&OD) SETB (1)                                                    00002250
         MEND                                                           00002300
