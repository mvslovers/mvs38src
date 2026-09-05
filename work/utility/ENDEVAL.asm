         MACRO                                                          00000050
&LAB     ENDEVAL                                                        00000100
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
.* OPT INDICATOR FOR EACH POSSIBLE DEPTH                                00001050
         GBLB  &OPTI(16)                                                00001100
.*                                                                      00001150
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00001200
&LAB     EQU   *                                                        00001250
.END0    ANOP                                                           00001300
.IF0A    AIF   (&OD NE 0).END0A                                         00001350
         MNOTE 16,'UNMATCHED ENDOPT'                                    00001400
         MEXIT                                                          00001450
.END0A   ANOP                                                           00001500
.IF1     AIF   (&OD LE 16).END1                                         00001550
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00001600
         AGO   .REDUCE                                                  00001650
.END1    ANOP                                                           00001700
.* SET OPTION INDICATOR OFF                                             00001750
&OPTN(&OD) SETB (0)                                                     00001800
.IF3     AIF   ((&OELSE(&OD)) EQ (1)).END3                              00001850
.* WHEN NO OPTELSE CLAUSE NEED CURRENT GENERATION NUMBER LABEL          00001900
@D&OD.N&ON(&OD) EQU   *                                                 00001950
.END3    ANOP                                                           00002000
&OELSE(&OD) SETB (0)                                                    00002050
&OPTI(&OD) SETB (0)                                                     00002100
.* SET LABEL FOR STRAIGHT END EXIT                                      00002150
@D&OD.E&OE(&OD) EQU   *                                                 00002200
.REDUCE  ANOP                                                           00002250
.* REDUCE DEPTH COUNT                                                   00002300
&OD      SETA  &OD-1                                                    00002350
         MEND                                                           00002400
