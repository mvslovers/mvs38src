         MACRO                                                          00000050
&LAB     WHEN                                                           00000100
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
.* OPCODE FOR EACH POSSIBLE DEPTH                                       00000550
         GBLC  &OP(16)                                                  00000600
.* COMPONENTS OF OPERAND 1 FOR EACH POSSIBLE DEPTH                      00000650
         GBLC  &OP1(16)                                                 00000700
.* OPERAND 2 (REP.TYPE.LENGTH) IF ANY - FOR EACH POSSIBLE DEPTH         00000800
         GBLC  &OP2(16)                                                 00000850
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00000900
         GBLA  &ON(16)                                                  00000950
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00001000
         GBLA  &OE(16)                                                  00001050
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00001100
         GBLA  &OD                                                      00001150
.* IMMEDIATE INDICATOR FOR EACH POSSIBLE DEPTH                          00001200
         GBLB  &OI(16)                                                  00001250
.* QUOTES INDICATOR FOR EACH POSSIBLE DEPTH                             00001300
         GBLB  &OQ(16)                                                  00001350
.* STATUS INDICATOR FOR EACH POSSIBLE DEPTH                             00001400
         GBLB  &OS(16)                                                  00001450
.* OPTELSE INDICATOR FOR EACH POSSIBLE DEPTH                            00001500
         GBLB  &OELSE(16)                                               00001550
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00001600
         GBLB  &OPTN(16)                                                00001650
.*                                                                      00001700
.* LOCAL WORK FIELDS                                                    00001750
         LCLA  &A,&B,&C,&D,&E,&U                                        00001800
         LCLC  &L1,&L2,&L3,&L4,&L5,&L6,&L7                              00001850
         LCLB  &H,&Z                                                    00001900
.*                                                                      00001950
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00002000
&LAB     EQU   *                                                        00002050
.END0    ANOP                                                           00002100
.IF0A    AIF   (&OD GT 0).END0A                                         00002150
         MNOTE 16,'OPTION MISSING'                                      00002200
         MEXIT                                                          00002250
.END0A   ANOP                                                           00002300
.IF1     AIF   (&OD LE 16).END1                                         00002350
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00002400
         MEXIT                                                          00002450
.END1    ANOP                                                           00002500
.* SET EXIT FOR PREVIOUS CODE                                           00002550
         BRU   @D&OD.E&OE(&OD)                                          00002600
.* SET LABEL FOR ENTRY                                                  00002650
@D&OD.N&ON(&OD) EQU   *                                                 00002700
.* INCREMENT LABEL GENERATION NUMBER                                    00002750
&ON(&OD) SETA  &ON(&OD)+1                                               00002800
.* SET OPTION INDICATOR OFF                                             00002850
&OPTN(&OD) SETB (0)                                                     00002900
.IF1AA   AIF   ((&OELSE(&OD)) EQ (0)).END1AA                            00002950
         MNOTE 16,'OPTELSE PRECEDES OPT'                                00003000
         MEXIT                                                          00003050
.END1AA  ANOP                                                           00003100
.* SAVE CURRENT LABEL GENERATION NUMBER FOR USER-CODE LABEL             00003150
&U       SETA  &ON(&OD)                                                 00003200
.* INCREMENT LABEL GENERATION NUMBER                                    00003250
&ON(&OD) SETA  &ON(&OD)+1                                               00003300
.IF1AB   AIF   ((&OS(&OD)) EQ (0)).END1AB                               00003350
         MNOTE 16,'OPTION STATEMENT ERROR'                              00003400
         MEXIT                                                          00003450
.END1AB  ANOP                                                           00003500
&A       SETA  N'&SYSLIST                                               00003550
.IF1B    AIF   (&A NE 0).END1B                                          00003600
         MNOTE 16,'NO OPT PARAMETERS'                                   00003650
         MEXIT                                                          00003700
.END1B   ANOP                                                           00003750
&B       SETA  0                                                        00003800
.DO1     AIF   (&A EQ &B).NDO1                                          00003850
.* DO FOR EACH PARAMETER OF OPT                                         00003900
&B       SETA  &B+1                                                     00003950
&C       SETA  K'&SYSLIST(&B)                                           00004000
.IF2     AIF   ((&OQ(&OD)) EQ (0)).ELS2                                 00004050
         AIF   ('&SYSLIST(&B)'(1,1) NE '''').QMN                        00004100
         AIF   ('&SYSLIST(&B)'(&C,1) EQ '''').OKQ                       00004150
.QMN     MNOTE 16,'UNQUOTED OPT PARAMETER'                              00004200
         MEXIT                                                          00004250
.OKQ     AIF   (&C GT 2).END2                                           00004300
         MNOTE 16,'NULL QUOTES OPT PARAMETER'                           00004350
         MEXIT                                                          00004400
.ELS2    AIF   ('&SYSLIST(&B)'(1,1) NE '''').END2                       00004450
         MNOTE 16,'MISQUOTED OPT PARAMETER'                             00004500
         MEXIT                                                          00004550
.END2    ANOP                                                           00004600
.* FIND IF THERE IS A RANGE                                             00004650
&D       SETA  0                                                        00004700
&H       SETB  (0)                                                      00004750
.DO2     AIF   (&C EQ &D).NDO2                                          00004800
.* DO FOR EACH CHARACTER OF PARAMETER                                   00004850
&D       SETA  &D+1                                                     00004900
         AIF   ('&SYSLIST(&B)'(&D,1) NE '-').ADO2                       00004950
.IF4     AIF   ((&OQ(&OD)) EQ (0)).ELS4                                 00005000
         AIF   ('&SYSLIST(&B)'(&D-1,1) NE '''').ADO2                    00005050
         AIF   ('&SYSLIST(&B)'(&D+1,1) NE '''').ADO2                    00005100
         AIF   (&D EQ 2).ADO2                                           00005150
.* HAVE FOUND A HYPHEN (BETWEEN QUOTES BECAUSE QUOTES ARE CURRENT)      00005200
&H       SETB  (1)                                                      00005250
         AGO   .NDO2                                                    00005300
.ELS4    ANOP                                                           00005350
.* HAVE FOUND A HYPHEN                                                  00005400
&H       SETB  (1)                                                      00005450
         AGO   .NDO2                                                    00005500
.END4    ANOP                                                           00005550
.ADO2    AGO   .DO2                                                     00005600
.NDO2    ANOP                                                           00005650
&L1      SETC  '&OP(&OD)'                                               00005700
&L2      SETC  '&OP1(&OD)'                                              00005750
&L3      SETC  '&OP2(&OD)'                                              00005850
.*                                                                      00005900
.* GENERATE LABEL FOR COMPARE CLAUSE IF NOT 1ST AND RANGE NOT PREVIOUS  00005950
.IF5     AIF   (&B EQ 1).END5                                           00006000
         AIF   ((&Z) EQ (0)).END5                                       00006050
@D&OD.N&ON(&OD) EQU *                                                   00006100
.* INCREMENT LABEL GENERATION COUNT                                     00006150
&ON(&OD) SETA  &ON(&OD)+1                                               00006200
.END5    ANOP                                                           00006250
.* GENERATE COMPARE CLAUSE LOGIC                                        00006300
.IF6     AIF   ((&H) EQ (0)).ELS6                                       00006350
.* WHEN A RANGE  &H IS 1 AND &D WILL HOLD HYPHEN OFFSET                 00006400
&E       SETA  &D-1                                                     00006450
&L4      SETC  '&SYSLIST(&B)'(1,&E)                                     00006500
         &L1   &L2,&L3&L4                                               00006550
         JL    @D&OD.N&ON(&OD)                                          00006600
&E       SETA  &C-&D                                                    00006650
&L5      SETC  '&SYSLIST(&B)'(&D+1,&E)                                  00006700
         &L1   &L2,&L3&L5                                               00006750
.IF7     AIF   (&B EQ &A).ELS7                                          00006800
.* WHEN NOT LAST CLAUSE GENERATE BRANCH DIRECT TO USER-CODE             00006850
         JNH   @D&OD.N&U                                                00006900
         AGO   .END7                                                    00006950
.ELS7    ANOP                                                           00007000
.* FOR LAST CLAUSE GENERATE BRANCH TO NEXT OPTION                       00007050
         JH    @D&OD.N&ON(&OD)                                          00007100
.IF7A    AIF   (&A EQ 1).END7A                                          00007150
.* GENERATE USER-CODE ENTRY LABEL WHEN MORE THAN A SINGLE PARAMETER     00007200
@D&OD.N&U EQU  *                                                        00007250
.END7A   ANOP                                                           00007300
.END7    ANOP                                                           00007350
&Z       SETB  (1)                                                      00007400
         AGO   .END6                                                    00007450
.ELS6    ANOP                                                           00007500
.* HAVE SIMPLE CLAUSE WITH SINGLE TERM                                  00007550
&L6      SETC  '&SYSLIST(&B)'(1,&C)                                     00007600
         &L1   &L2,&L3&L6                                               00007650
.IF8     AIF   (&B EQ &A).ELS8                                          00007700
.* WHEN NOT LAST CLAUSE GENERATE BRANCH DIRECT TO USER-CODE             00007750
         JE    @D&OD.N&U                                                00007800
         AGO   .END8                                                    00007850
.ELS8    ANOP                                                           00007900
.* FOR LAST CLAUSE GENERATE BRANCH TO NEXT OPTION                       00007950
         JNE   @D&OD.N&ON(&OD)                                          00008000
.IF9     AIF   (&A EQ 1).END9                                           00008050
.* GENERATE USER-CODE ENTRY LABEL WHEN MORE THAN A SINGLE PARAMETER     00008100
@D&OD.N&U EQU  *                                                        00008150
.END9    ANOP                                                           00008200
.END8    ANOP                                                           00008250
&Z       SETB  (0)                                                      00008300
.END6    ANOP                                                           00008350
.ADO1    AGO   .DO1                                                     00008400
.NDO1    ANOP                                                           00008450
         MEND                                                           00008500
