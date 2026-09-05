         MACRO                                                          00000050
&LAB     EVALUATE &OPCODE,&OPER1,&OPER2                                 00000100
.*                                                                      00000150
.* THIS MACRO IS ONE OF A RELATED SET OF MACROS WHICH ENGINEER THE      00000300
.* SELECTED EXECUTION OF CODE DEPENDING ON THE CONTENTS OF A FIELD.     00000350
.*                                                                      00000500
.* THE GENERAL STRUCTURE IS AS FOLLOWS -                                00000550
.*    EVALUATE OPCODE,OP1(,OP2.REP.TYPE.LTH)                            00000600
.*      WHEN   OP2REST,OP2REST                                          00000650
.*      WHEN   OP2REST-OP2REST,OP2REST                                  00000700
.*      OTHERWSE                                                        00000750
.*    ENDEVAL                                                           00000800
.*                                                                      00000850
.* OPCODE FOR EACH POSSIBLE TYPE                                        00000900
         GBLC  &OP(16)                                                  00000950
.*                                                                      00000850
.* COMPONENTS OF OP1 FOR EACH POSSIBLE DEPTH                            00001000
         GBLC  &OP1(16)                                                 00001050
.*                                                                      00000850
.* OP2.REP.TYPE.LTH FOR EACH POSSIBLE DEPTH                             00001150
         GBLC  &OP2(16)                                                 00001200
.*                                                                      00000850
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00001250
         GBLA  &ON(16)                                                  00001300
.*                                                                      00000850
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00001350
         GBLA  &OE(16)                                                  00001400
.*                                                                      00000850
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00001450
         GBLA  &OD                                                      00001500
.*                                                                      00000850
.* IMMEDIATE INDICATOR FOR EACH POSSIBLE DEPTH                          00001550
         GBLB  &OI(16)                                                  00001600
.*                                                                      00000850
.* QUOTES INDICATOR FOR EACH POSSIBLE DEPTH                             00001650
         GBLB  &OQ(16)                                                  00001700
.*                                                                      00000850
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00001750
         GBLB  &OPTN(16)                                                00001800
.*                                                                      00000850
.* STATUS INDICATOR FOR EACH POSSIBLE DEPTH                             00001850
         GBLB  &OS(16)                                                  00001900
.*                                                                      00001950
.* LOCAL WORK FIELDS                                                    00002000
         LCLA  &A                                                       00002050
         LCLC  &C1,&C2,&C3,&C4,&C5,&C6,&C7,&C8                          00002100
.*                                                                      00002150
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00002200
&LAB     EQU   *                                                        00002250
.END0    ANOP                                                           00002300
.IF0A    AIF   (&OD EQ 0).END0A                                         00002350
.IF0B    AIF   ((&OPTN(&OD)) EQ (0)).END0B                              00002400
         MNOTE 16,'DUPLICATE OPTION'                                    00002450
&OS(&OD) SETB  (1)                                                      00002500
         MEXIT                                                          00002550
.END0B   ANOP                                                           00002600
.END0A   ANOP                                                           00002650
.* INCREMENT COUNT OF DEPTH OF NESTING                                  00002700
&OD      SETA  &OD+1                                                    00002750
.IF1     AIF   (&OD LE 16).END1                                         00002800
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00002850
         MEXIT                                                          00002900
.END1    ANOP                                                           00002950
.* SET OPTION INDICATOR FOR THIS DEPTH (1= OPTION MACRO LAST MET)       00003000
&OPTN(&OD) SETB (1)                                                     00003050
.* ZEROISE STATUS INDICATOR FOR THIS DEPTH (1= OPTION STATEMENT ERROR)  00003100
&OS(&OD) SETB  (0)                                                      00003150
.* ZEROISE IMMEDIATE INDICATOR FOR THIS DEPTH (1= CLI OPCODE)           00003200
&OI(&OD) SETB  (0)                                                      00003250
.* ZEROISE QUOTES INDICATOR FOR THIS DEPTH (1= QUOTES EXPECTED)         00003300
&OQ(&OD) SETB  (0)                                                      00003350
.* INCREMENT LABEL GENERATION NUMBER FOR THIS DEPTH                     00003400
&ON(&OD) SETA  &ON(&OD)+1                                               00003450
.* SAVE LABEL GENERATION NUMBER FOR END LABEL FOR THIS DEPTH            00003500
&OE(&OD) SETA  &ON(&OD)                                                 00003550
.* INCREMENT LABEL GENERATION NUMBER FOR THIS DEPTH                     00003600
&ON(&OD) SETA  &ON(&OD)+1                                               00003650
.IF2A    AIF  (K'&OPCODE GT 0).END2A                                    00003700
         MNOTE 16,'NO OPCODE SPECIFIED'                                 00003750
&OS(&OD) SETB  (1)                                                      00003800
         AGO   .MEND                                                    00003850
.END2A   ANOP                                                           00003900
.OKOLTH  AIF   ('&OPCODE'(1,1) EQ 'C').OKC                              00004150
         MNOTE 16,'INVALID OPCODE'                                      00004200
&OS(&OD) SETB  (1)                                                      00004250
         AGO   .MEND                                                    00004300
.OKC     AIF   ('&OPCODE' NE 'CLI').END2AA                              00004400
&OI(&OD) SETB  (1)                                                      00004450
.END2AA  ANOP                                                           00004500
&OP(&OD) SETC  '&OPCODE'                                                00004550
.IF2B    AIF   (T'&OPER1 NE 'O').END2B                                  00004600
         MNOTE 16,'NO FIRST OPERAND SPECIFIED'                          00004650
&OS(&OD) SETB  (1)                                                      00004700
         AGO   .MEND                                                    00004750
.END2B   ANOP                                                           00004800
&OP1(&OD) SETC '&OPER1'                                                 00005100
.IF3     AIF   (T'&OPER2 NE 'O').ELS3                                   00006200
&OQ(&OD) SETB  (0)                                                      00006250
&OP2(&OD) SETC ''                                                       00006300
         AGO   .END3                                                    00006350
.ELS3    ANOP                                                           00006400
.IF3A    AIF   (K'&OPER2 LE 8).END3A                                    00006450
         MNOTE 16,'THIRD PARAMETER OVERLONG'                            00006500
&OS(&OD) SETB  (1)                                                      00006550
         AGO   .MEND                                                    00006600
.END3A   ANOP                                                           00006650
         AIF   ('&OPER2'(1,1) NE '=').TRYI                              00006700
         AIF   ((&OI(&OD)) EQ (0)).TRYSOLO                              00006750
         MNOTE 16,'ILLEGAL IMMEDIATE OPERAND'                           00006800
&OS(&OD) SETB  (1)                                                      00006850
         AGO   .MEND                                                    00006900
.TRYSOLO AIF   (K'&OPER2 NE 1).OKOP2                                    00006950
&OQ(&OD) SETB  (0)                                                      00007000
&OP2(&OD) SETC '&OPER2'                                                 00007050
         AGO   .END3                                                    00007100
.TRYI    AIF   ((&OI(&OD)) EQ (1)).OKOP2                                00007150
         MNOTE 16,'ILLEGAL LITERAL'                                     00007200
&OS(&OD) SETB  (1)                                                      00007250
         AGO   .MEND                                                    00007300
.OKOP2   ANOP                                                           00007350
&OQ(&OD) SETB  (1)                                                      00007400
&OP2(&OD) SETC '&OPER2'                                                 00007450
.END3    ANOP                                                           00007500
.MEND    ANOP                                                           00007550
         BRU   @D&OD.N&ON(&OD)                                          00007600
         MEXIT                                                                  
.*                                                                              
.*  EXAMPLES OF USING EVALUATE                                                  
.*                                                                              
.*  EVALUATE                                                                    
.*                                                                              
.*  EVALUATE is used to select which of several pieces of code is to            
.*  be executed when that selection depends upon the value of a                 
.*  particular field.  In such cases, EVALUATE is more elegant, more            
.*  readable, and more logical than the overused ELSEIF.                        
.*  The general format is:                                                      
.*                                                                              
.*               EVALUATE opcode,op1(,op2)                                      
.*                 WHEN op2value                                                
.*                   code                                                       
.*                 WHEN op2value1-op2value2                                     
.*                   code                                                       
.*                 WHEN op2value1-op2value2,op2value                            
.*                   code                                                       
.*                 OTHERWSE                                                     
.*                   code                                                       
.*               ENDOPT                                                         
.*                                                                              
.*  where: 'opcode' is one of - CLC, CLI, CP, CH, C, CLR, CL, CR;               
.*         'op1' is the address of the determinant field;                       
.*         'op2' is the constant type and length (if this is common             
.*               to all the WHEN values).                                       
.*                                                                              
.*  The EVALUATE macro declares the type of comparison to be done on            
.*  the determinant field.  It is followed by a series of WHEN clauses,         
.*  each of which specifies a list of values and/or ranges, and heads           
.*  the lines of code to be executed if that WHEN is selected. Only             
.*  one WHEN clause, the first to satisfy the test, will be executed.           
.*  OPTELSE, if coded, should follow the final WHEN (and will often             
.*  head a 'value not found' error procedure).  The OTHERWSE code will          
.*  be executed if none of the WHEN values matches the determinant;             
.*  if there is no match and no OTHERWSE clause, processing continues           
.*  normally, without any of the WHEN clauses having been executed.             
.*  ENDOPT terminates the EVALUATE block.                                       
.*                                                                              
.*  Processing will be most efficient when the WHEN clauses are written         
.*  in order of decreasing probability of selection, and when the               
.*  values within each WHEN are in order of decreasing probability of           
.*  occurrence.                                                                 
.*  EVALUATE blocks can be nested to a maximum depth of 16.                     
.*  No registers are corrupted by OPTION.                                       
.*                                                                              
.*  The following examples illustrate OPTION's commoner modes of use.           
.*                                                                              
.*  1.  EVALUATE CP,COUNT,=P                                                    
.*        WHEN '1'                                                              
.*          code                                                                
.*        WHEN '2'                                                              
.*          code                                                                
.*        WHEN '3','4','5'                                                      
.*          code                                                                
.*        WHEN '6'-'99'                                                         
.*          code                                                                
.*        OTHERWSE                                                              
.*          code                                                                
.*      ENDOPT                                                                  
.*                                                                              
.*  2.  EVALUATE CP,TAX(3)                                                      
.*        WHEN =P'0'                                                            
.*          code                                                                
.*        WHEN =P'1',=P'1000'                                                   
.*          code                                                                
.*        WHEN PFLDA(3)-PFLDB(5),0(5,R6)                                        
.*          code                                                                
.*        WHEN PHIGH                                                            
.*          code                                                                
.*      ENDOPT                                                                  
.*                                                                              
.*  3.  EVALUATE CLI,BDETCRR3,C                                                 
.*        WHEN 'A'                                                              
.*          ZAP ACUSELDS,=P'-5'                                                 
.*        WHEN 'B'                                                              
.*          ZAP ACUSELDS,=P'-4'                                                 
.*        WHEN 'D'                                                              
.*          ZAP ACUSELDS,=P'-2'                                                 
.*        WHEN 'E'                                                              
.*          ZAP ACUSELDS,=P'-1'                                                 
.*        OTHERWSE                                                              
.*          PERFORM ERRSCORE                                                    
.*      ENDOPT                                                                  
.*                                                                              
.*  4.  EVALUATE CLI,BDETDKCN,X           SELECT BY COMPANY                     
.*        WHEN '53'                       COUNTRY GARDEN                        
.*          PERFORM CGPOST                                                      
.*        WHEN '26'                       SHOWCASE                              
.*          MVI OSNOPPCH,C'0'             NOT YET CHARGED                       
.*          ZAP OSNOPANP,=P'150'          POST AND PACK CHARGE                  
.*        WHEN '63'                       SHOPPING SENSE                        
.*          MVI OSNOPPCH,C'0'             NOT YET CHARGED                       
.*          ZAP OSNOPANP,=P'195'          POST AND PACK CHARGE                  
.*        OTHERWSE                                                              
.*          IF (CLC,CUSTNO(3),E,=C'184')  BARGAIN BASEMENT                      
.*            MVI OSNOPPCH,C'0'           NOT YET CHARGED                       
.*            ZAP OSNOPANP,=P'200'        POST AND PACK CHARGE                  
.*          ELSE                                                                
.*            IF (CLC,CUSTNO(3),E,=C'183')  NEW HORIZONS                        
.*              PERFORM NHPOST                                                  
.*            ENDIF                                                             
.*          ENDIF                                                               
.*      ENDOPT                                                                  
.*                                                                              
.*  5.  EVALUATE CH,R2,=H                                                       
.*        WHEN '0'                                                              
.*          PERFORM READPBDF                                                    
.*        WHEN '4'                                                              
.*          L R5,0(R1)                                                          
.*          ST R5,PARMADDR                                                      
.*          .                                                                   
.*          .                                                                   
.*          .                                                                   
.*        WHEN '12'                                                             
.*          IF (CLI,FIRSTSW,E,C'Y')                                             
.*            MVI FIRSTSW,C'N'                                                  
.*          ENDIF                                                               
.*          PERFORM READPBCF                                                    
.*      ENDOPT                                                                  
.*                                                                              
.*  6.  EVALUATE CLC,ACUSCLUS,=CL2                                              
.*        WHEN '04','13','14','27'                                              
.*          MVC C200PRCI,=C'20'                                                 
.*        WHEN '19','24'-'26'                                                   
.*          MVC C200PRCI,=C'30'                                                 
.*        WHEN '10','11','16'-'18','22','29'                                    
.*          MVC C200PRCI,=C'40'                                                 
.*        WHEN '01','03','07','08','12'                                         
.*          MVC C200PRCI,=C'50'                                                 
.*        WHEN '05','06','09','15','20','21','23','28','30'                     
.*          MVC C200PRCI,=C'60'                                                 
.*        OTHERWSE                                                              
.*          MVC C200PRCI,=C'70'                                                 
.*      ENDOPT                                                                  
.*                                                                              
.*  In the above example, since the implicit length of ACUSCLUS is              
.*  two bytes, 'OPTION CLC,ACUSCLUS,=C' could have been coded;                  
.*  or even 'OPTION CLC,ACUSCLUS' with 'OPT =C'04',=C'13'...'.                  
.*                                                                              
.*  7.  EVALUATE C,R2                                                           
.*        WHEN =F'0',0(R3)                                                      
.*          code                                                                
.*        WHEN 4(R3)-8(R3)                                                      
.*          code                                                                
.*        WHEN FWORD1-FWORD2                                                    
.*          code                                                                
.*        WHEN =F'4000'-FWORD3                                                  
.*          code                                                                
.*        WHEN =4X'FF'                                                          
.*          code                                                                
.*      ENDOPT                                                                  
.*                                                                              
.*  8.  EVALUATE CR,R2                                                          
.*        WHEN R6-R7,R8                                                         
.*          code                                                                
.*        WHEN R9                                                               
.*          code                                                                
.*      ENDOPT                                                                  
.*                                                                              
         MEND                                                           00007650
