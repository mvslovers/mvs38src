./   ADD   NAME=DO       SS=0101120252120261211342001E001E0000DSK       ********
         MACRO                                                          00010000
         DO    &P1,&FROM=,&TO=,&BY=,&UNTIL=,&WHILE=                     00020000
         LCLA  &POSNO                                                   00030000
         PUSHNEST DO                                                    00040000
.* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  00050000
.*                                                                   *  00060000
.*  THE FOLLOWING SECTION HAS BEEN ADDED TO PREVENT MORE THAN ONE    *  00070000
.*  CONDITION FROM BEING SPECIFIED ON A "DO UNTIL" OR A "DO WHILE" . *  00080000
.*  THE MACRO ONLY EXPECTS ONE CONDITION, BUT DOES NOT REJECT        *  00090000
.*  MULTIPLE CONDITIONS.                                             *  00100000
.*                                                                   *  00110000
.* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  00120000
.*                                                                      00130000
         AIF   (T'&P1 EQ 'O').CHKPOS    IF NO POSITIONAL PARAMETER      00140000
         AIF   ('&P1' EQ 'INF').EXPAND  IF PARAMETER VALID              00150000
         MNOTE 50,'INVALID PARAMETER "&P1"'                             00160000
         MNOTE 50,'DO MACRO - EXPANSION TERMINATED'                     00170000
         MEXIT                                                          00180000
.*                                                                      00190000
.CHKPOS  ANOP                                                           00200000
&POSNO   SETA  N'&SYSLIST            NUMBER OF POSITIONAL PARMS         00210000
         AIF   (&POSNO EQ 0).EXPAND                                     00220000
         MNOTE 50,'TOO MANY POSITIONAL PARAMETERS SPECIFIED'            00230000
         MNOTE 50,'DO MACRO - EXPANSION TERMINATED'                     00240000
         MEXIT                                                          00250000
.*                                                                      00260000
.EXPAND  ANOP                                                           00270000
.* * * * *  E N D   O F   A D D E D   S E C T I O N  * * * * * * * * *  00280000
         DOPROC &FROM,&TO,&BY,&UNTIL,&WHILE,&P1                         00290000
         MEND                                                           00300000
./   ADD   NAME=DOEXIT   SS=0101120252120261211345002B002B0000DSK       ********
  MACRO                                                                 00010000
  DOEXIT   &P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,                   /00020000
               &P11,&P12,&P13,&P14,&P15,&P16,&P17,&P18,&P19,&P20,      /00030000
               &P21,&P22,&P23,&P24,&P25,&P26,&P27,&P28,&P29,&P30,      /00040000
               &P31,&P32,&P33,&P34,&P35,&P36,&P37,&P38,&P39,&P40,      /00050000
               &P41,&P42,&P43,&P44,&P45,&P46,&P47,&P48,&P49,&P50,&CC=   00060000
 GBLA &CCVAL                                                            00070000
 GBLA &CTR                                                              00080000
 GBLA &SEQ                                                              00090000
 GBLA &AI                                                               00100000
 GBLA &CI                                                               00110000
 GBLA &II                                                               00120000
 GBLA &LI                                                               00130000
 GBLA &NI                                                               00140000
 GBLA &AIND(50)                                                         00150000
 GBLA &CIND1(200)                                                       00160000
 GBLA &MULT(50)                                                         00170000
 GBLA &ST(51)                                                           00180000
 GBLC &CIND2(200)                                                       00190000
 GBLC &IIND1(100)                                                       00200000
 GBLC &IIND2(100)                                                       00210000
 GBLC &I22(100)                                                         00220000
 GBLC &I23(100)                                                         00230000
 GBLC &I24(100)                                                         00240000
 GBLC &IIND3(100)                                                       00250000
 GBLC &I32(100)                                                         00260000
 GBLC &I33(100)                                                         00270000
 GBLC &I34(100)                                                         00280000
 GBLC &IIND4(100)                                                       00290000
 GBLC &I42(100)                                                         00300000
 GBLC &I43(100)                                                         00310000
 GBLC &IIND5(100)                                                       00320000
 GBLC &LIND(101)                                                        00330000
 GBLC &NEST(50)                                                         00340000
 GBLC &RIND(50)                                                         00350000
 PUSHLAB                                                                00360000
&NEST(&NI) SETC '&NEST(&NI)'(1,4)'DO'                                   00370000
 IFPROC &CC,&P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,                  /00380000
               &P11,&P12,&P13,&P14,&P15,&P16,&P17,&P18,&P19,&P20,      /00390000
               &P21,&P22,&P23,&P24,&P25,&P26,&P27,&P28,&P29,&P30,      /00400000
               &P31,&P32,&P33,&P34,&P35,&P36,&P37,&P38,&P39,&P40,      /00410000
               &P41,&P42,&P43,&P44,&P45,&P46,&P47,&P48,&P49,&P50        00420000
  MEND                                                                  00430000
./   ADD   NAME=DOPROC   SS=0101120252120261211349009D009D0000DSK       ********
  MACRO                                                                 00010000
  DOPROC &FROM,&TO,&BY,&UNTIL,&WHILE,&P1                                00020000
  GBLA  &CCVAL   COND CODE VARIABLE                                     00030000
  GBLA  &CTR   MACRO PARAMETER COUNTER                                  00040000
  GBLA  &SEQ   LABEL NUMBER GENERATOR                                   00050000
  GBLA  &AI   INDEX FOR TOTAL NO. CASES STK                             00060000
  GBLA  &CI   INDEX FOR CASE AND LBL NO. STKS                           00070000
  GBLA  &II   PTR TO INST STKS                                          00080000
  GBLA  &LI   INDEX FOR LABEL NUMBER STK                                00090000
  GBLA  &NI   PTR TO NEST STK                                           00100000
  GBLA  &AIND(50)  TOTAL CASES STK                                      00110000
  GBLA  &CIND1(200)  CASE NUMBER STK                                    00120000
  GBLA  &MULT(50)  CASE NUMBER MULTIPLIER                               00130000
  GBLA  &ST(51)   INST STK INCREASE AT EACH LEVEL                       00140000
  GBLC  &CIND2(200)  LABEL NUMBER STK FOR CASES                         00150000
  GBLC  &IIND1(100)  INSTRUCTION STK 1                                  00160000
  GBLC  &IIND2(100)  INSTRUCTION STK 2                                  00170000
  GBLC  &I22(100)  INSTRUCTION STK 2, 2ND PART                          00180000
  GBLC  &I23(100)  INSTRUCTION STK 2, 3RD PART                          00190000
  GBLC  &I24(100)  INSTRUCTION STK 2, 4TH PART                          00200000
  GBLC  &IIND3(100)  INSTRUCTION STK 3                                  00210000
  GBLC  &I32(100)  INSTRUCTION STK 3, 2ND PART                          00220000
  GBLC  &I33(100)  INSTRUCTION STK 3, 3RD PART                          00230000
  GBLC  &I34(100)  INSTRUCTION STK 3, 4TH PART                          00240000
  GBLC  &IIND4(100)  INSTRUCTION STK 4                                  00250000
  GBLC  &I42(100)  INSTRUCTION STK 4, 2ND PART                          00260000
  GBLC  &I43(100)  INSTRUCTION STK 4, 3RD PART                          00270000
  GBLC  &IIND5(100)  INSTRUCTION NAME STACK                             00280000
  GBLC  &LIND(101)  LABEL NUMBER STK                                    00290000
  GBLC  &NEST(50)  NESTING STK                                          00300000
  GBLC  &RIND(50)  REG STK FOR CASENTRY MACRO                           00310000
  LCLA  &I                                                              00320000
  LCLC  &LCLWK1                                                         00330000
    PUSHLAB                                                             00340000
    PUSHINS (EQU,*,,,,&LIND(&LI))                                       00350000
&ST(&NI)   SETA    &II+1                                                00360000
    PUSHLAB                                                             00370000
    AIF  (T'&FROM EQ 'O').NOIND                                         00380000
  AIF   ('&FROM(3)' EQ '').INCR                                         00390000
    LA &FROM(3),&LIND(&LI)                                              00400000
.INCR  ANOP                                                             00410000
&I  SETA  &I+1                                                          00420000
  AIF   ('&SYSLIST(&I,2)' EQ '').TEST                                   00430000
    AIF ('&SYSLIST(&I,2)'(1,1) EQ '(').GENLR                            00440000
      AIF ('&SYSLIST(&I,2)' EQ '0').GENSR                               00450000
        AIF ('&SYSLIST(&I,2)'(1,1) EQ '-').NEGVAL                       00460000
   AIF (T'&SYSLIST(&I,2) EQ 'N').POSVAL                                 00470000
     LA  &SYSLIST(&I,1),&SYSLIST(&I,2)                                  00480000
     AGO .TEST                                                          00490000
.POSVAL   AIF (&SYSLIST(&I,2) GE 4096).TSTMAG                           00500000
     LA  &SYSLIST(&I,1),&SYSLIST(&I,2)                                  00510000
     AGO .TEST                                                          00520000
.TSTMAG   AIF (&SYSLIST(&I,2) GE 32768).FULLIT                          00530000
     AGO .HALFLIT                                                       00540000
.NEGVAL        ANOP                                                     00550000
&LCLWK1   SETC '&SYSLIST(&I,2)'(2,7)                                    00560000
   AIF (&LCLWK1 GE 32768).FULLIT                                        00570000
.HALFLIT       LHI &SYSLIST(&I,1),&SYSLIST(&I,2)                        00580000
   AGO .TEST                                                            00590000
.FULLIT        L &SYSLIST(&I,1),=F'&SYSLIST(&I,2)'                      00600000
   AGO .TEST                                                            00610000
.GENSR      SR &SYSLIST(&I,1),&SYSLIST(&I,1)                            00620000
        AGO .TEST                                                       00630000
.GENLR    LR &SYSLIST(&I,1),&SYSLIST(&I,2)                              00640000
.TEST  AIF   (&I LT 3).INCR                                             00650000
    AIF  (T'&UNTIL NE 'O').ERRMG2                                       00660000
.CKWHILE     AIF   (T'&WHILE NE 'O').COMPGEN                            00670000
&LIND(&LI) EQU  *                                                       00680000
.POSTIND   AIF  (T'&P1 EQ 'O').GETIND                                   00690000
      AIF   (T'&BY NE 'O').PFB                                          00700000
        AIF   (T'&TO NE 'O').PFT                                        00710000
   AIF   ('&FROM(3)' NE '').BCTRZ                                       00720000
     PUSHINS (BRCT,&FROM(1),&LIND(&LI))                                 00730000
   AGO   .ERRMG                                                         00740000
.BCTRZ   PUSHINS (BCTR,&FROM(1),&FROM(3))                               00750000
        AGO     .ERRMG                                                  00760000
.PFT        PUSHINS (&P1,&FROM(1),&TO(1),&LIND(&LI))                    00770000
      MEXIT                                                             00780000
.PFB      PUSHINS (&P1,&FROM(1),&BY(1),&LIND(&LI))                      00790000
    MEXIT                                                               00800000
.GETIND    AIF  ('&FROM(3)' EQ '').BCTR1                                00810000
      PUSHINS (BCTR,&FROM(1),&FROM(3))                                  00820000
    MEXIT                                                               00830000
.BCTR1    AIF  (T'&BY NE 'O').FB                                        00840000
      AIF   (T'&TO EQ 'O').FONLY                                        00850000
        PUSHINS (BXLE,&FROM(1),&TO(1),&LIND(&LI))                       00860000
      MEXIT                                                             00870000
.FONLY      PUSHINS (BRCT,&FROM(1),&LIND(&LI))                          00880000
    MEXIT                                                               00890000
.FB    AIF  (T'&TO NE 'O').FTB                                          00900000
      AIF   ('&BY(2)' EQ '').GENBXLE                                    00910000
      AIF   ('&BY(2)'(1,1) NE '-').GENBXLE                              00920000
    AGO  .GENBXH                                                        00930000
.FTB    AIF  ('&TO(2)' EQ '' OR '&FROM(2)' EQ '').GENBXLE               00940000
      AIF   ('&FROM(2)'(1,1) EQ '(').GENBXLE                            00950000
      AIF   ('&FROM(2)'(1,1) EQ '-').TRYTNEG                            00960000
      AIF   (T'&FROM(2) NE 'N').GENBXLE                                 00970000
      AIF   ('&TO(2)'(1,1) EQ '(').GENBXLE                              00980000
      AIF   ('&TO(2)'(1,1) EQ '-').GENBXH                               00990000
      AIF   (T'&TO(2) NE 'N').GENBXLE                                   01000000
      AIF   (&FROM(2) GT &TO(2)).GENBXH                                 01010000
.GENBXLE   PUSHINS (BXLE,&FROM(1),&BY(1),&LIND(&LI))                    01020000
    MEXIT                                                               01030000
.TRYTNEG   AIF  ('&TO(2)'(1,1) NE '-').GENBXLE                          01040000
    AIF  ('&FROM(2)'(2,7) GE '&TO(2)'(2,7)).GENBXLE                     01050000
.GENBXH    PUSHINS (BXH,&FROM(1),&BY(1),&LIND(&LI))                     01060000
    MEXIT                                                               01070000
.NOIND      AIF   (T'&WHILE EQ 'O').NOWHILE                             01080000
        AIF   (T'&UNTIL NE 'O').COMPGEN                                 01090000
.* BC    15,&LIND(&LI)                                                  01100000
   BRC   15,&LIND(&LI)                                                  01110000
   PUSHLAB                                                              01120000
&LI   SETA &LI-1                                                        01130000
&LIND(&LI+1)  EQU  *                                                    01140000
   AIF   ('&WHILE(6)' EQ '').OKSUBL                                     01150000
     STKINS &WHILE                                                      01160000
     MEXIT                                                              01170000
.OKSUBL   STKINS (&WHILE(1),&WHILE(2),&WHILE(3),&WHILE(4),      X       01180000
        &WHILE(5),&LIND(&LI))                                           01190000
   AIF   ('&WHILE(2)' EQ '').LABEL                                      01200000
     PUSHINS (BRC,&CCVAL,&LIND(&LI+1))                                  01210000
     MEXIT                                                              01220000
.LABEL   PUSHINS   (BRC,&CCVAL,&LIND(&LI+1),,,&LIND(&LI))               01230000
   MEXIT                                                                01240000
.NOWHILE     AIF   (T'&UNTIL EQ 'O').TRYINF                             01250000
&LIND(&LI)   EQU   *                                                    01260000
.UNT        STKINS &UNTIL                                               01270000
        PUSHINS (BRC,15-&CCVAL,&LIND(&LI))                              01280000
      MEXIT                                                             01290000
.TRYINF        AIF   ('&P1' NE 'INF').ERRMG1                            01300000
&LIND(&LI)  EQU *                                                       01310000
   PUSHINS (BRC,15,&LIND(&LI))                                          01320000
        MEXIT                                                           01330000
.COMPGEN     AIF   ('&WHILE(6)' EQ '').OK                               01340000
        STKINS &WHILE                                                   01350000
        AGO   .BCHINST                                                  01360000
.OK      STKINS (&WHILE(1),&WHILE(2),&WHILE(3),&WHILE(4),        X      01370000
        &WHILE(5),&LIND(&LI))                                           01380000
      AIF   (N'&WHILE GT 1).ENDCOMP                                     01390000
&LIND(&LI)     BC    15-&CCVAL,&LIND(&LI-1)                             01400000
*&LIND(&LI)     BRC   15-&CCVAL,&LIND(&LI-1)                            01410000
        AGO   .FLAGEQU                                                  01420000
.ENDCOMP     ANOP                                                       01430000
&ST(&NI+1)   SETA  &II                                                  01440000
      POPINS &ST(&NI+1)                                                 01450000
.BCHINST     BC    15-&CCVAL,&LIND(&LI-1)                               01460000
*.BCHINST     BRC   15-&CCVAL,&LIND(&LI-1)                              01470000
.FLAGEQU     ANOP                                                       01480000
&NEST(&NI)   SETC  '   Y'.'&NEST(&NI)'(5,4)                             01490000
      AIF   (T'&FROM NE 'O').POSTIND                                    01500000
    AGO  .UNT                                                           01510000
.ERRMG  MNOTE 4,'POSITIONAL PARAMETER IGNORED. BCT/BCTR LOOP END USED'  01520000
  MEXIT                                                                 01530000
.ERRMG2  MNOTE 4,'UNTIL KEYWORD INVALID WITH INDEXING GROUP. IGNORED'   01540000
  AGO   .CKWHILE                                                        01550000
.ERRMG1  MNOTE 4,'NO WHILE,UNTIL,OR INDEXING PARAMETERS ON DO MACRO.'   01560000
  MEND                                                                  01570000
./   ADD   NAME=ELSE     SS=0101120252120261211355000C000C0000DSK       ********
  MACRO                                                                 00010000
  ELSE                                                                  00020000
        COPY GBLVARS                                                    00030000
  GBLC  &LASTIF                                                         00040000
  IFTEST ELSE                                                           00050000
&LIND(&LI+1) SETC '&LIND(&LI)'                                          00060000
&LI  SETA &LI-1                                                         00070000
  PUSHLAB                                                               00080000
.*BC    15,&LIND(&LI)                                                   00090000
  BRC   15,&LIND(&LI)                                                   00100000
&LIND(&LI+1)   EQU   *                                                  00110000
        MEND                                                            00120000
./   ADD   NAME=ELSEIF   SS=0101120252120261211357001500150000DSK       ********
 MACRO                                                                  00010000
 ELSEIF  &P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,                     /00020000
               &P11,&P12,&P13,&P14,&P15,&P16,&P17,&P18,&P19,&P20,      /00030000
               &P21,&P22,&P23,&P24,&P25,&P26,&P27,&P28,&P29,&P30,      /00040000
               &P31,&P32,&P33,&P34,&P35,&P36,&P37,&P38,&P39,&P40,      /00050000
               &P41,&P42,&P43,&P44,&P45,&P46,&P47,&P48,&P49,&P50,&CC=   00060000
  COPY GBLVARS                                                          00070000
  GBLC  &LASTIF                                                         00080000
  IFTEST ELSEIF                                                         00090000
&LIND(&LI+1) SETC '&LIND(&LI)'                                          00100000
&LI  SETA  &LI-1                                                        00110000
  PUSHLAB                                                               00120000
.*BC   15,&LIND(&LI-1)                                                  00130000
  BRC  15,&LIND(&LI-1)                                                  00140000
&LIND(&LI+1) EQU   *                                                    00150000
  IFPROC &CC,&P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,                 /00160000
               &P11,&P12,&P13,&P14,&P15,&P16,&P17,&P18,&P19,&P20,      /00170000
               &P21,&P22,&P23,&P24,&P25,&P26,&P27,&P28,&P29,&P30,      /00180000
               &P31,&P32,&P33,&P34,&P35,&P36,&P37,&P38,&P39,&P40,      /00190000
               &P41,&P42,&P43,&P44,&P45,&P46,&P47,&P48,&P49,&P50        00200000
 MEND                                                                   00210000
./   ADD   NAME=ENDDO    SS=0101120252120261211400000800080000DSK       ********
  MACRO                                                                 00010000
  ENDDO                                                                 00020000
  GBLA &ST(51),&NI,&LI,&II                                              00030000
  POPINS &ST(&NI)                                                       00040000
&II  SETA &II-1                                                         00050000
  POPNEST DO                                                            00060000
&LI  SETA &LI-2                                                         00070000
  MEND                                                                  00080000
./   ADD   NAME=ENDEVAL  SS=0101120252120261211402003300330000DSK       ********
         MACRO                                                          00010000
&LAB     ENDEVAL                                                        00020000
.*                                                                      00030000
.* THIS MACRO IS ONE OF A RELATED SET OF MACROS WHICH ENGINEER THE      00040000
.* SELECTED EXECUTION OF CODE DEPENDING ON THE CONTENTS OF A FIELD.     00050000
.*                                                                      00060000
.* THE GENERAL STRUCTURE IS AS FOLLOWS -                                00070000
.*    EVALUATE OPCODE,OP1(,OP2.REP.TYPE.LTH)                            00080000
.*      WHEN   OP2REST,OP2REST                                          00090000
.*      WHEN   OP2REST-OP2REST,OP2REST                                  00100000
.*      OTHERWSE                                                        00110000
.*    ENDEVAL                                                           00120000
.*                                                                      00130000
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00140000
         GBLA  &ON(16)                                                  00150000
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00160000
         GBLA  &OE(16)                                                  00170000
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00180000
         GBLA  &OD                                                      00190000
.* OPTELSE INDICATOR FOR EACH POSSIBLE DEPTH                            00200000
         GBLB  &OELSE(16)                                               00210000
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00220000
         GBLB  &OPTN(16)                                                00230000
.* OPT INDICATOR FOR EACH POSSIBLE DEPTH                                00240000
         GBLB  &OPTI(16)                                                00250000
.*                                                                      00260000
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00270000
&LAB     EQU   *                                                        00280000
.END0    ANOP                                                           00290000
.IF0A    AIF   (&OD NE 0).END0A                                         00300000
         MNOTE 16,'UNMATCHED ENDOPT'                                    00310000
         MEXIT                                                          00320000
.END0A   ANOP                                                           00330000
.IF1     AIF   (&OD LE 16).END1                                         00340000
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00350000
         AGO   .REDUCE                                                  00360000
.END1    ANOP                                                           00370000
.* SET OPTION INDICATOR OFF                                             00380000
&OPTN(&OD) SETB (0)                                                     00390000
.IF3     AIF   ((&OELSE(&OD)) EQ (1)).END3                              00400000
.* WHEN NO OPTELSE CLAUSE NEED CURRENT GENERATION NUMBER LABEL          00410000
@D&OD.N&ON(&OD) EQU   *                                                 00420000
.END3    ANOP                                                           00430000
&OELSE(&OD) SETB (0)                                                    00440000
&OPTI(&OD) SETB (0)                                                     00450000
.* SET LABEL FOR STRAIGHT END EXIT                                      00460000
@D&OD.E&OE(&OD) EQU   *                                                 00470000
.REDUCE  ANOP                                                           00480000
.* REDUCE DEPTH COUNT                                                   00490000
&OD      SETA  &OD-1                                                    00500000
         MEND                                                           00510000
./   ADD   NAME=ENDIF    SS=0101120252120261211405000A000A0000DSK       ********
  MACRO                                                                 00010000
  ENDIF                                                                 00020000
        COPY GBLVARS                                                    00030000
  GBLC  &LASTIF                                                         00040000
  IFTEST ENDIF                                                          00050000
  POPNEST IF                                                            00060000
&LIND(&LI) EQU *                                                        00070000
&LIND(&LI-1) EQU *                                                      00080000
&LI  SETA &LI-2                                                         00090000
  MEND                                                                  00100000
./   ADD   NAME=EVALUATE SS=0101120252120261211409011F011F0000DSK       ********
         MACRO                                                          00010000
&LAB     EVALUATE &OPCODE,&OPER1,&OPER2                                 00020000
.*                                                                      00030000
.* THIS MACRO IS ONE OF A RELATED SET OF MACROS WHICH ENGINEER THE      00040000
.* SELECTED EXECUTION OF CODE DEPENDING ON THE CONTENTS OF A FIELD.     00050000
.*                                                                      00060000
.* THE GENERAL STRUCTURE IS AS FOLLOWS -                                00070000
.*    EVALUATE OPCODE,OP1(,OP2.REP.TYPE.LTH)                            00080000
.*      WHEN   OP2REST,OP2REST                                          00090000
.*      WHEN   OP2REST-OP2REST,OP2REST                                  00100000
.*      OTHERWSE                                                        00110000
.*    ENDEVAL                                                           00120000
.*                                                                      00130000
.* OPCODE FOR EACH POSSIBLE TYPE                                        00140000
         GBLC  &OP(16)                                                  00150000
.*                                                                      00160000
.* COMPONENTS OF OP1 FOR EACH POSSIBLE DEPTH                            00170000
         GBLC  &OP1(16)                                                 00180000
.*                                                                      00190000
.* OP2.REP.TYPE.LTH FOR EACH POSSIBLE DEPTH                             00200000
         GBLC  &OP2(16)                                                 00210000
.*                                                                      00220000
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00230000
         GBLA  &ON(16)                                                  00240000
.*                                                                      00250000
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00260000
         GBLA  &OE(16)                                                  00270000
.*                                                                      00280000
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00290000
         GBLA  &OD                                                      00300000
.*                                                                      00310000
.* IMMEDIATE INDICATOR FOR EACH POSSIBLE DEPTH                          00320000
         GBLB  &OI(16)                                                  00330000
.*                                                                      00340000
.* QUOTES INDICATOR FOR EACH POSSIBLE DEPTH                             00350000
         GBLB  &OQ(16)                                                  00360000
.*                                                                      00370000
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00380000
         GBLB  &OPTN(16)                                                00390000
.*                                                                      00400000
.* STATUS INDICATOR FOR EACH POSSIBLE DEPTH                             00410000
         GBLB  &OS(16)                                                  00420000
.*                                                                      00430000
.* LOCAL WORK FIELDS                                                    00440000
         LCLA  &A                                                       00450000
         LCLC  &C1,&C2,&C3,&C4,&C5,&C6,&C7,&C8                          00460000
.*                                                                      00470000
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00480000
&LAB     EQU   *                                                        00490000
.END0    ANOP                                                           00500000
.IF0A    AIF   (&OD EQ 0).END0A                                         00510000
.IF0B    AIF   ((&OPTN(&OD)) EQ (0)).END0B                              00520000
         MNOTE 16,'DUPLICATE OPTION'                                    00530000
&OS(&OD) SETB  (1)                                                      00540000
         MEXIT                                                          00550000
.END0B   ANOP                                                           00560000
.END0A   ANOP                                                           00570000
.* INCREMENT COUNT OF DEPTH OF NESTING                                  00580000
&OD      SETA  &OD+1                                                    00590000
.IF1     AIF   (&OD LE 16).END1                                         00600000
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00610000
         MEXIT                                                          00620000
.END1    ANOP                                                           00630000
.* SET OPTION INDICATOR FOR THIS DEPTH (1= OPTION MACRO LAST MET)       00640000
&OPTN(&OD) SETB (1)                                                     00650000
.* ZEROISE STATUS INDICATOR FOR THIS DEPTH (1= OPTION STATEMENT ERROR)  00660000
&OS(&OD) SETB  (0)                                                      00670000
.* ZEROISE IMMEDIATE INDICATOR FOR THIS DEPTH (1= CLI OPCODE)           00680000
&OI(&OD) SETB  (0)                                                      00690000
.* ZEROISE QUOTES INDICATOR FOR THIS DEPTH (1= QUOTES EXPECTED)         00700000
&OQ(&OD) SETB  (0)                                                      00710000
.* INCREMENT LABEL GENERATION NUMBER FOR THIS DEPTH                     00720000
&ON(&OD) SETA  &ON(&OD)+1                                               00730000
.* SAVE LABEL GENERATION NUMBER FOR END LABEL FOR THIS DEPTH            00740000
&OE(&OD) SETA  &ON(&OD)                                                 00750000
.* INCREMENT LABEL GENERATION NUMBER FOR THIS DEPTH                     00760000
&ON(&OD) SETA  &ON(&OD)+1                                               00770000
.IF2A    AIF  (K'&OPCODE GT 0).END2A                                    00780000
         MNOTE 16,'NO OPCODE SPECIFIED'                                 00790000
&OS(&OD) SETB  (1)                                                      00800000
         AGO   .MEND                                                    00810000
.END2A   ANOP                                                           00820000
.OKOLTH  AIF   ('&OPCODE'(1,1) EQ 'C').OKC                              00830000
         MNOTE 16,'INVALID OPCODE'                                      00840000
&OS(&OD) SETB  (1)                                                      00850000
         AGO   .MEND                                                    00860000
.OKC     AIF   ('&OPCODE' NE 'CLI').END2AA                              00870000
&OI(&OD) SETB  (1)                                                      00880000
.END2AA  ANOP                                                           00890000
&OP(&OD) SETC  '&OPCODE'                                                00900000
.IF2B    AIF   (T'&OPER1 NE 'O').END2B                                  00910000
         MNOTE 16,'NO FIRST OPERAND SPECIFIED'                          00920000
&OS(&OD) SETB  (1)                                                      00930000
         AGO   .MEND                                                    00940000
.END2B   ANOP                                                           00950000
&OP1(&OD) SETC '&OPER1'                                                 00960000
.IF3     AIF   (T'&OPER2 NE 'O').ELS3                                   00970000
&OQ(&OD) SETB  (0)                                                      00980000
&OP2(&OD) SETC ''                                                       00990000
         AGO   .END3                                                    01000000
.ELS3    ANOP                                                           01010000
.IF3A    AIF   (K'&OPER2 LE 8).END3A                                    01020000
         MNOTE 16,'THIRD PARAMETER OVERLONG'                            01030000
&OS(&OD) SETB  (1)                                                      01040000
         AGO   .MEND                                                    01050000
.END3A   ANOP                                                           01060000
         AIF   ('&OPER2'(1,1) NE '=').TRYI                              01070000
         AIF   ((&OI(&OD)) EQ (0)).TRYSOLO                              01080000
         MNOTE 16,'ILLEGAL IMMEDIATE OPERAND'                           01090000
&OS(&OD) SETB  (1)                                                      01100000
         AGO   .MEND                                                    01110000
.TRYSOLO AIF   (K'&OPER2 NE 1).OKOP2                                    01120000
&OQ(&OD) SETB  (0)                                                      01130000
&OP2(&OD) SETC '&OPER2'                                                 01140000
         AGO   .END3                                                    01150000
.TRYI    AIF   ((&OI(&OD)) EQ (1)).OKOP2                                01160000
         MNOTE 16,'ILLEGAL LITERAL'                                     01170000
&OS(&OD) SETB  (1)                                                      01180000
         AGO   .MEND                                                    01190000
.OKOP2   ANOP                                                           01200000
&OQ(&OD) SETB  (1)                                                      01210000
&OP2(&OD) SETC '&OPER2'                                                 01220000
.END3    ANOP                                                           01230000
.MEND    ANOP                                                           01240000
         BRU   @D&OD.N&ON(&OD)                                          01250000
         MEXIT                                                          01260000
.*                                                                      01270000
.*  EXAMPLES OF USING EVALUATE                                          01280000
.*                                                                      01290000
.*  EVALUATE                                                            01300000
.*                                                                      01310000
.*  EVALUATE is used to select which of several pieces of code is to    01320000
.*  be executed when that selection depends upon the value of a         01330000
.*  particular field.  In such cases, EVALUATE is more elegant, more    01340000
.*  readable, and more logical than the overused ELSEIF.                01350000
.*  The general format is:                                              01360000
.*                                                                      01370000
.*               EVALUATE opcode,op1(,op2)                              01380000
.*                 WHEN op2value                                        01390000
.*                   code                                               01400000
.*                 WHEN op2value1-op2value2                             01410000
.*                   code                                               01420000
.*                 WHEN op2value1-op2value2,op2value                    01430000
.*                   code                                               01440000
.*                 OTHERWSE                                             01450000
.*                   code                                               01460000
.*               ENDOPT                                                 01470000
.*                                                                      01480000
.*  where: 'opcode' is one of - CLC, CLI, CP, CH, C, CLR, CL, CR;       01490000
.*         'op1' is the address of the determinant field;               01500000
.*         'op2' is the constant type and length (if this is common     01510000
.*               to all the WHEN values).                               01520000
.*                                                                      01530000
.*  The EVALUATE macro declares the type of comparison to be done on    01540000
.*  the determinant field.  It is followed by a series of WHEN clauses, 01550000
.*  each of which specifies a list of values and/or ranges, and heads   01560000
.*  the lines of code to be executed if that WHEN is selected. Only     01570000
.*  one WHEN clause, the first to satisfy the test, will be executed.   01580000
.*  OPTELSE, if coded, should follow the final WHEN (and will often     01590000
.*  head a 'value not found' error procedure).  The OTHERWSE code will  01600000
.*  be executed if none of the WHEN values matches the determinant;     01610000
.*  if there is no match and no OTHERWSE clause, processing continues   01620000
.*  normally, without any of the WHEN clauses having been executed.     01630000
.*  ENDOPT terminates the EVALUATE block.                               01640000
.*                                                                      01650000
.*  Processing will be most efficient when the WHEN clauses are written 01660000
.*  in order of decreasing probability of selection, and when the       01670000
.*  values within each WHEN are in order of decreasing probability of   01680000
.*  occurrence.                                                         01690000
.*  EVALUATE blocks can be nested to a maximum depth of 16.             01700000
.*  No registers are corrupted by OPTION.                               01710000
.*                                                                      01720000
.*  The following examples illustrate OPTION's commoner modes of use.   01730000
.*                                                                      01740000
.*  1.  EVALUATE CP,COUNT,=P                                            01750000
.*        WHEN '1'                                                      01760000
.*          code                                                        01770000
.*        WHEN '2'                                                      01780000
.*          code                                                        01790000
.*        WHEN '3','4','5'                                              01800000
.*          code                                                        01810000
.*        WHEN '6'-'99'                                                 01820000
.*          code                                                        01830000
.*        OTHERWSE                                                      01840000
.*          code                                                        01850000
.*      ENDOPT                                                          01860000
.*                                                                      01870000
.*  2.  EVALUATE CP,TAX(3)                                              01880000
.*        WHEN =P'0'                                                    01890000
.*          code                                                        01900000
.*        WHEN =P'1',=P'1000'                                           01910000
.*          code                                                        01920000
.*        WHEN PFLDA(3)-PFLDB(5),0(5,R6)                                01930000
.*          code                                                        01940000
.*        WHEN PHIGH                                                    01950000
.*          code                                                        01960000
.*      ENDOPT                                                          01970000
.*                                                                      01980000
.*  3.  EVALUATE CLI,BDETCRR3,C                                         01990000
.*        WHEN 'A'                                                      02000000
.*          ZAP ACUSELDS,=P'-5'                                         02010000
.*        WHEN 'B'                                                      02020000
.*          ZAP ACUSELDS,=P'-4'                                         02030000
.*        WHEN 'D'                                                      02040000
.*          ZAP ACUSELDS,=P'-2'                                         02050000
.*        WHEN 'E'                                                      02060000
.*          ZAP ACUSELDS,=P'-1'                                         02070000
.*        OTHERWSE                                                      02080000
.*          PERFORM ERRSCORE                                            02090000
.*      ENDOPT                                                          02100000
.*                                                                      02110000
.*  4.  EVALUATE CLI,BDETDKCN,X           SELECT BY COMPANY             02120000
.*        WHEN '53'                       COUNTRY GARDEN                02130000
.*          PERFORM CGPOST                                              02140000
.*        WHEN '26'                       SHOWCASE                      02150000
.*          MVI OSNOPPCH,C'0'             NOT YET CHARGED               02160000
.*          ZAP OSNOPANP,=P'150'          POST AND PACK CHARGE          02170000
.*        WHEN '63'                       SHOPPING SENSE                02180000
.*          MVI OSNOPPCH,C'0'             NOT YET CHARGED               02190000
.*          ZAP OSNOPANP,=P'195'          POST AND PACK CHARGE          02200000
.*        OTHERWSE                                                      02210000
.*          IF (CLC,CUSTNO(3),E,=C'184')  BARGAIN BASEMENT              02220000
.*            MVI OSNOPPCH,C'0'           NOT YET CHARGED               02230000
.*            ZAP OSNOPANP,=P'200'        POST AND PACK CHARGE          02240000
.*          ELSE                                                        02250000
.*            IF (CLC,CUSTNO(3),E,=C'183')  NEW HORIZONS                02260000
.*              PERFORM NHPOST                                          02270000
.*            ENDIF                                                     02280000
.*          ENDIF                                                       02290000
.*      ENDOPT                                                          02300000
.*                                                                      02310000
.*  5.  EVALUATE CH,R2,=H                                               02320000
.*        WHEN '0'                                                      02330000
.*          PERFORM READPBDF                                            02340000
.*        WHEN '4'                                                      02350000
.*          L R5,0(R1)                                                  02360000
.*          ST R5,PARMADDR                                              02370000
.*          .                                                           02380000
.*          .                                                           02390000
.*          .                                                           02400000
.*        WHEN '12'                                                     02410000
.*          IF (CLI,FIRSTSW,E,C'Y')                                     02420000
.*            MVI FIRSTSW,C'N'                                          02430000
.*          ENDIF                                                       02440000
.*          PERFORM READPBCF                                            02450000
.*      ENDOPT                                                          02460000
.*                                                                      02470000
.*  6.  EVALUATE CLC,ACUSCLUS,=CL2                                      02480000
.*        WHEN '04','13','14','27'                                      02490000
.*          MVC C200PRCI,=C'20'                                         02500000
.*        WHEN '19','24'-'26'                                           02510000
.*          MVC C200PRCI,=C'30'                                         02520000
.*        WHEN '10','11','16'-'18','22','29'                            02530000
.*          MVC C200PRCI,=C'40'                                         02540000
.*        WHEN '01','03','07','08','12'                                 02550000
.*          MVC C200PRCI,=C'50'                                         02560000
.*        WHEN '05','06','09','15','20','21','23','28','30'             02570000
.*          MVC C200PRCI,=C'60'                                         02580000
.*        OTHERWSE                                                      02590000
.*          MVC C200PRCI,=C'70'                                         02600000
.*      ENDOPT                                                          02610000
.*                                                                      02620000
.*  In the above example, since the implicit length of ACUSCLUS is      02630000
.*  two bytes, 'OPTION CLC,ACUSCLUS,=C' could have been coded;          02640000
.*  or even 'OPTION CLC,ACUSCLUS' with 'OPT =C'04',=C'13'...'.          02650000
.*                                                                      02660000
.*  7.  EVALUATE C,R2                                                   02670000
.*        WHEN =F'0',0(R3)                                              02680000
.*          code                                                        02690000
.*        WHEN 4(R3)-8(R3)                                              02700000
.*          code                                                        02710000
.*        WHEN FWORD1-FWORD2                                            02720000
.*          code                                                        02730000
.*        WHEN =F'4000'-FWORD3                                          02740000
.*          code                                                        02750000
.*        WHEN =4X'FF'                                                  02760000
.*          code                                                        02770000
.*      ENDOPT                                                          02780000
.*                                                                      02790000
.*  8.  EVALUATE CR,R2                                                  02800000
.*        WHEN R6-R7,R8                                                 02810000
.*          code                                                        02820000
.*        WHEN R9                                                       02830000
.*          code                                                        02840000
.*      ENDOPT                                                          02850000
.*                                                                      02860000
         MEND                                                           02870000
./   ADD   NAME=GBLVARS  SS=0101120252120261211412001F001F0000DSK       ********
   GBLA &CCVAL        COND CODE VARIABLE                                00010000
   GBLA &CTR        MACRO PARAMETER COUNTER                             00020000
   GBLA &SEQ        LABEL NUMBER GENERATOR                              00030000
   GBLA &AI        INDEX FOR TOTAL NO. CASES STK                        00040000
   GBLA &CI        INDEX FOR CASE AND LBL NO. STKS                      00050000
   GBLA &II        PTR TO INST STKS                                     00060000
   GBLA &LI        INDEX FOR LABEL NUMBER STK                           00070000
   GBLA &NI        PTR TO NEXT STK                                      00080000
   GBLA &AIND(50)       TOTAL CASES STK                                 00090000
   GBLA &CIND1(200)       CASE NUMBER STK                               00100000
   GBLA &MULT(50)       CASE NUMBER MULTIPLIER                          00110000
   GBLA &ST(51)        INST STK INCREASE AT EACH LEVEL                  00120000
   GBLC &CIND2(200)       LABEL NUMBER STK FOR CASES                    00130000
   GBLC &IIND1(100)       INSTRUCTION STK 1                             00140000
   GBLC &IIND2(100)       INSTRUCTION STK 2                             00150000
   GBLC &I22(100)       INSTRUCTION STK 2,2ND PART                      00160000
   GBLC &I23(100)       INSTRUCTION STK 2,3RD PART                      00170000
   GBLC &I24(100)       INSTRUCTION STK 2,4TH PART                      00180000
   GBLC &IIND3(100)       INSTRUCTION STK 3                             00190000
   GBLC &I32(100)       INSTRUCTION STK 3,2ND PART                      00200000
   GBLC &I33(100)       INSTRUCTION STK 3,3RD PART                      00210000
   GBLC &I34(100)       INSTRUCTION STK 3,4TH PART                      00220000
   GBLC &IIND4(100)       INSTRUCTION STK 4                             00230000
   GBLC &I42(100)       INSTRUCTION STK 4,2ND PART                      00240000
   GBLC &I43(100)       INSTRUCTION STK 4,3RD PART                      00250000
   GBLC &IIND5(100)       INSTRUCTION NAME STACK                        00260000
   GBLC &LIND(101)       LABEL NUMBER STK                               00270000
   GBLC &NEST(50)       NESTING STK                                     00280000
   GBLC &RIND(50)       REG STK FOR CASENTRY MACRO                      00290000
   GBLC &SEGNAME       SEGMENT NAME                                     00300000
   GBLC &SEGSTRT       SEGMENT START                                    00310000
./   ADD   NAME=IF       SS=0101120252120261211415001200120000DSK       ********
      MACRO                                                             00010000
      IF &P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,                     /00020000
               &P11,&P12,&P13,&P14,&P15,&P16,&P17,&P18,&P19,&P20,      /00030000
               &P21,&P22,&P23,&P24,&P25,&P26,&P27,&P28,&P29,&P30,      /00040000
               &P31,&P32,&P33,&P34,&P35,&P36,&P37,&P38,&P39,&P40,      /00050000
               &P41,&P42,&P43,&P44,&P45,&P46,&P47,&P48,&P49,&P50,&CC=   00060000
      COPY  GBLVARS                                                     00070000
      GBLC  &LASTIF                                                     00080000
      IFTEST IF                                                         00090000
      PUSHNEST IF                                                       00100000
      PUSHLAB                                                           00110000
      PUSHLAB                                                           00120000
      IFPROC &CC,&P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9,&P10,             /00130000
               &P11,&P12,&P13,&P14,&P15,&P16,&P17,&P18,&P19,&P20,      /00140000
               &P21,&P22,&P23,&P24,&P25,&P26,&P27,&P28,&P29,&P30,      /00150000
               &P31,&P32,&P33,&P34,&P35,&P36,&P37,&P38,&P39,&P40,      /00160000
               &P41,&P42,&P43,&P44,&P45,&P46,&P47,&P48,&P49,&P50        00170000
      MEND                                                              00180000
./   ADD   NAME=IFPROC   SS=0101120252120261211422006100610000DSK       ********
    MACRO                                                               00010000
    IFPROC                                                              00020000
  GBLA  &CCVAL   COND CODE VARIABLE                                     00030000
  GBLA  &CTR   MACRO PARAMETER COUNTER                                  00040000
  GBLA  &SEQ   LABEL NUMBER GENERATOR                                   00050000
  GBLA  &AI   INDEX FOR TOTAL NO. CASES STK                             00060000
  GBLA  &CI   INDEX FOR CASE AND LBL NO. STKS                           00070000
  GBLA  &II   PTR TO INST STKS                                          00080000
  GBLA  &LI   INDEX FOR LABEL NUMBER STK                                00090000
  GBLA  &NI   PTR TO NEST STK                                           00100000
  GBLA  &AIND(50)  TOTAL CASES STK                                      00110000
  GBLA  &CIND1(200)  CASE NUMBER STK                                    00120000
  GBLA  &MULT(50)  CASE NUMBER MULTIPLIER                               00130000
  GBLA  &ST(51)   INST STK INCREASE AT EACH LEVEL                       00140000
  GBLC  &CIND2(200)  LABEL NUMBER STK FOR CASES                         00150000
  GBLC  &IIND1(100)  INSTRUCTION STK 1                                  00160000
  GBLC  &IIND2(100)  INSTRUCTION STK 2                                  00170000
  GBLC  &I22(100)  INSTRUCTION STK 2, 2ND PART                          00180000
  GBLC  &I23(100)  INSTRUCTION STK 2, 3RD PART                          00190000
  GBLC  &I24(100)  INSTRUCTION STK 2, 4TH PART                          00200000
  GBLC  &IIND3(100)  INSTRUCTION STK 3                                  00210000
  GBLC  &I32(100)  INSTRUCTION STK 3, 2ND PART                          00220000
  GBLC  &I33(100)  INSTRUCTION STK 3, 3RD PART                          00230000
  GBLC  &I34(100)  INSTRUCTION STK 3, 4TH PART                          00240000
  GBLC  &IIND4(100)  INSTRUCTION STK 4                                  00250000
  GBLC  &I42(100)  INSTRUCTION STK 4, 2ND PART                          00260000
  GBLC  &I43(100)  INSTRUCTION STK 4, 3RD PART                          00270000
  GBLC  &IIND5(100)  INSTRUCTION NAME STACK                             00280000
  GBLC  &LIND(101)  LABEL NUMBER STK                                    00290000
  GBLC  &NEST(50)  NESTING STK                                          00300000
  GBLC  &RIND(50)  REG STK FOR CASENTRY MACRO                           00310000
    LCLB &ANDIND,&ORIND                                                 00320000
    PUSHLAB                                                             00330000
&CTR    SETA 2                                                          00340000
&ST(&NI+1) SETA &II+1                                                   00350000
&NEST(&NI) SETC '  R'.'&NEST(&NI)'(4,5)                                 00360000
    AIF (T'&SYSLIST(1) EQ 'O').LOOP                                     00370000
    AIF (&SYSLIST(1) LE 0 OR &SYSLIST(1) GE 15).INVALCC                 00380000
&CCVAL      SETA &SYSLIST(1)                                            00390000
      AIF ('&SYSLIST(2)' EQ '').ENDBOOL                                 00400000
  MNOTE 4,'CC KEYWORD USED. OTHER PARAMETERS IGNORED'                   00410000
  AGO .ENDBOOL                                                          00420000
.INVALCC MNOTE 4,'CC OUTSIDE VALID RANGE OF 1 TO 14. NOP GENERATED'     00430000
&CCVAL  SETA  15                                                        00440000
    AGO .ENDBOOL                                                        00450000
.LOOP    STKINS &SYSLIST(&CTR),&SYSLIST(&CTR+1),&SYSLIST(&CTR+2),      /00460000
               &SYSLIST(&CTR+3),&SYSLIST(&CTR+4)                        00470000
    AIF ('&SYSLIST(&CTR+1)' EQ 'AND').ANDPROC                           00480000
    AIF ('&SYSLIST(&CTR+1)' NE 'ANDIF').TESTOR                          00490000
.ANDPROC     PUSHINS (BRC,15-&CCVAL,&LIND(&LI-1))                       00500000
&ANDIND      SETB 1                                                     00510000
      AIF ('&SYSLIST(&CTR+1)' NE 'ANDIF' OR NOT &ORIND).TESTLP          00520000
        POPINS &ST(&NI+1)                                               00530000
&LIND(&LI)     EQU *                                                    00540000
&ORIND        SETB 0                                                    00550000
&LI        SETA &LI-1                                                   00560000
        PUSHLAB                                                         00570000
      AGO .TESTLP                                                       00580000
.TESTOR    AIF ('&SYSLIST(&CTR+1)' EQ 'OR').ORPROC                      00590000
    AIF ('&SYSLIST(&CTR+1)' NE 'ORIF').TESTLP                           00600000
.ORPROC      PUSHINS (BRC,&CCVAL,&LIND(&LI))                            00610000
&ORIND      SETB 1                                                      00620000
      AIF ('&SYSLIST(&CTR+1)' NE 'ORIF' OR NOT &ANDIND).TESTLP          00630000
        PUSHINS (EQU,*,,,,&LIND(&LI-1))                                 00640000
&ANDIND        SETB 0                                                   00650000
        PUSHLAB                                                         00660000
&LI        SETA &LI-1                                                   00670000
&LIND(&LI-1)   SETC '&LIND(&LI+1)'                                      00680000
.TESTLP    ANOP                                                         00690000
&CTR    SETA &CTR+2                                                     00700000
    AIF ('&SYSLIST(&CTR-1)' NE '').LOOP                                 00710000
.ENDBOOL     AIF ('&NEST(&NI)'(5,4) EQ 'DO').DOEND                      00720000
      POPINS &ST(&NI+1)                                                 00730000
.*    BC   15-&CCVAL,&LIND(&LI-1)                                       00740000
      BRC  15-&CCVAL,&LIND(&LI-1)                                       00750000
      AIF (NOT &ORIND).POPLBL                                           00760000
&LIND(&LI)     EQU *                                                    00770000
.POPLBL      ANOP                                                       00780000
&LI      SETA &LI-1                                                     00790000
    MEXIT                                                               00800000
.DOEND    ANOP                                                          00810000
&CTR    SETA  &ST(&NI+1)                                                00820000
    AGO  .ENDLBL                                                        00830000
.NXTLBL    AIF  ('&IIND3(&CTR)' NE '&LIND(&LI)').INCTR                  00840000
&IIND3(&CTR) SETC  '&LIND(&LI-3)'                                       00850000
.INCTR    ANOP                                                          00860000
&CTR    SETA  &CTR+1                                                    00870000
.ENDLBL    AIF  (&CTR LE &II).NXTLBL                                    00880000
    POPINS &ST(&NI+1)                                                   00890000
.*  BC   &CCVAL,&LIND(&LI-3)                                            00900000
    BRC  &CCVAL,&LIND(&LI-3)                                            00910000
    AIF  (NOT &ANDIND).POP2LBL                                          00920000
&LIND(&LI-1) EQU  *                                                     00930000
.POP2LBL   ANOP                                                         00940000
&LI    SETA   &LI-2                                                     00950000
&NEST(&NI) SETC  '   Y'.'&NEST(&NI)'(5,4)                               00960000
    MEND                                                                00970000
./   ADD   NAME=IFTEST   SS=0101120252120261211424001600160000DSK       ********
  MACRO                                                                 00010000
  IFTEST &THISIF                                                        00020000
  GBLC  &LASTIF                                                         00030000
  COPY  GBLVARS                                                         00040000
.*                                                                      00050000
.*   THIS MACRO ENSURES THAT THE 'IF' MACROS HAVE BEEN CODED            00060000
.*   IN A SYNTACTICALLY CORRECT SEQUENCE.                               00070000
.*                                                                      00080000
  AIF   ('&LASTIF' EQ '').OK                                            00090000
  AIF   ('&LASTIF' EQ 'ENDIF').OK                                       00100000
  AIF   ('&THISIF' EQ 'ENDIF').OK                                       00110000
  AIF   ('&THISIF' EQ 'IF').OK                                          00120000
  AIF   ('&THISIF' EQ 'ELSEIF' AND '&LASTIF' EQ 'ELSEIF').OK            00130000
  AIF   ('&THISIF' EQ 'ELSEIF' AND '&LASTIF' EQ 'IF').OK                00140000
  AIF   ('&THISIF' EQ 'ELSE' AND '&LASTIF' EQ 'ELSEIF').OK              00150000
  AIF   ('&THISIF' EQ 'ELSE' AND '&LASTIF' EQ 'IF').OK                  00160000
 MNOTE 8,'ERROR - ''&THISIF'' MACRO INVALID AFTER ''&LASTIF''.'         00170000
  MEXIT                                                                 00180000
.*                                                                      00190000
.OK  ANOP                                                               00200000
&LASTIF  SETC  '&THISIF'                                                00210000
  MEND                                                                  00220000
./   ADD   NAME=OTHERWSE SS=0101120252120261211428003100310000DSK       ********
         MACRO                                                          00010000
&LAB     OTHERWSE                                                       00020000
.*                                                                      00030000
.* THIS MACRO IS ONE OF A RELATED SET OF MACROS WHICH ENGINEER THE      00040000
.* SELECTED EXECUTION OF CODE DEPENDING ON THE CONTENTS OF A FIELD.     00050000
.*                                                                      00060000
.* THE GENERAL STRUCTURE IS AS FOLLOWS -                                00070000
.*    EVALUATE OPCODE,OP1(,OP2.REP.TYPE.LTH)                            00080000
.*      WHEN   OP2REST,OP2REST                                          00090000
.*      WHEN   OP2REST-OP2REST,OP2REST                                  00100000
.*      OTHERWSE                                                        00110000
.*    ENDEVAL                                                           00120000
.*                                                                      00130000
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00140000
         GBLA  &ON(16)                                                  00150000
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00160000
         GBLA  &OE(16)                                                  00170000
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00180000
         GBLA  &OD                                                      00190000
.* OPTELSE INDICATOR FOR EACH POSSIBLE DEPTH                            00200000
         GBLB  &OELSE(16)                                               00210000
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00220000
         GBLB  &OPTN(16)                                                00230000
.*                                                                      00240000
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00250000
&LAB     EQU   *                                                        00260000
.END0    ANOP                                                           00270000
.IF0A    AIF   (&OD NE 0).END0A                                         00280000
         MNOTE 16,'OPTION MISSING'                                      00290000
         MEXIT                                                          00300000
.END0A   ANOP                                                           00310000
.IF1     AIF   (&OD LE 16).END1                                         00320000
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00330000
         MEXIT                                                          00340000
.END1    ANOP                                                           00350000
.* SET EXIT FOR PREVIOUS CODE                                           00360000
         BRU   @D&OD.E&OE(&OD)                                          00370000
.* SET LABEL FOR ENTRY                                                  00380000
@D&OD.N&ON(&OD) EQU   *                                                 00390000
.* INCREMENT LABEL GENERATION NUMBER                                    00400000
&ON(&OD) SETA  &ON(&OD)+1                                               00410000
.* SET OPTION INDICATOR OFF                                             00420000
&OPTN(&OD) SETB  (0)                                                    00430000
.IF1A    AIF   ((&OELSE(&OD)) EQ (0)).END1A                             00440000
         MNOTE 16,'DUPLICATE OTHERWSE'                                  00450000
         MEXIT                                                          00460000
.END1A   ANOP                                                           00470000
&OELSE(&OD) SETB (1)                                                    00480000
         MEND                                                           00490000
./   ADD   NAME=POPINS   SS=0101120252120261211430003600360000DSK       ********
  MACRO                                                                 00010000
  POPINS &P                                                             00020000
  GBLA  &CCVAL   COND CODE VARIABLE                                     00030000
  GBLA  &CTR   MACRO PARAMETER COUNTER                                  00040000
  GBLA  &SEQ   LABEL NUMBER GENERATOR                                   00050000
  GBLA  &AI   INDEX FOR TOTAL NO. CASES STK                             00060000
  GBLA  &CI   INDEX FOR CASE AND LBL NO. STKS                           00070000
  GBLA  &II   PTR TO INST STKS                                          00080000
  GBLA  &LI   INDEX FOR LABEL NUMBER STK                                00090000
  GBLA  &NI   PTR TO NEST STK                                           00100000
  GBLA  &AIND(50)  TOTAL CASES STK                                      00110000
  GBLA  &CIND1(200)  CASE NUMBER STK                                    00120000
  GBLA  &MULT(50)  CASE NUMBER MULTIPLIER                               00130000
  GBLA  &ST(51)   INST STK INCREASE AT EACH LEVEL                       00140000
  GBLC  &CIND2(200)  LABEL NUMBER STK FOR CASES                         00150000
  GBLC  &IIND1(100)  INSTRUCTION STK 1                                  00160000
  GBLC  &IIND2(100)  INSTRUCTION STK 2                                  00170000
  GBLC  &I22(100)  INSTRUCTION STK 2, 2ND PART                          00180000
  GBLC  &I23(100)  INSTRUCTION STK 2, 3RD PART                          00190000
  GBLC  &I24(100)  INSTRUCTION STK 2, 4TH PART                          00200000
  GBLC  &IIND3(100)  INSTRUCTION STK 3                                  00210000
  GBLC  &I32(100)  INSTRUCTION STK 3, 2ND PART                          00220000
  GBLC  &I33(100)  INSTRUCTION STK 3, 3RD PART                          00230000
  GBLC  &I34(100)  INSTRUCTION STK 3, 4TH PART                          00240000
  GBLC  &IIND4(100)  INSTRUCTION STK 4                                  00250000
  GBLC  &I42(100)  INSTRUCTION STK 4, 2ND PART                          00260000
  GBLC  &I43(100)  INSTRUCTION STK 4, 3RD PART                          00270000
  GBLC  &IIND5(100)  INSTRUCTION NAME STACK                             00280000
  GBLC  &LIND(101)  LABEL NUMBER STK                                    00290000
  GBLC  &NEST(50)  NESTING STK                                          00300000
  GBLC  &RIND(50)  REG STK FOR CASENTRY MACRO                           00310000
  LCLA &W                                                               00320000
&W  SETA &P                                                             00330000
  AGO .TEST                                                             00340000
.UNSTACK   AIF ('&IIND3(&W)' EQ '').ONEOP                               00350000
      AIF ('&IIND4(&W)' NE '').THREEOP                                  00360000
&IIND5(&W)     &IIND1(&W) &IIND2(&W)&I22(&W)&I23(&W)&I24(&W),&IIND3(&W)/00370000
               &I32(&W)&I33(&W)&I34(&W)                                 00380000
      AGO .INCTR                                                        00390000
.THREEOP       ANOP                                                     00400000
&IIND5(&W)     &IIND1(&W) &IIND2(&W)&I22(&W)&I23(&W)&I24(&W),&IIND3(&W)/00410000
               &I32(&W)&I33(&W)&I34(&W),&IIND4(&W)&I42(&W)&I43(&W)      00420000
      AGO .INCTR                                                        00430000
.ONEOP    ANOP                                                          00440000
&IIND5(&W)     &IIND1(&W) &IIND2(&W)&I22(&W)&I23(&W)&I24(&W)            00450000
.INCTR    ANOP                                                          00460000
&W    SETA  &W+1                                                        00470000
.TEST  AIF (&W LE &II).UNSTACK                                          00480000
&II  SETA &P-1                                                          00490000
  AIF ('&NEST(&NI)'(3,1) NE ' ' OR '&NEST(&NI)'(4,1) EQ ' ').NEQ        00500000
&IIND5(&II) &IIND1(&II) &IIND2(&II)                                     00510000
.NEQ  AIF (&II GT 0 OR (&II EQ 0 AND '&NEST(&NI)'(5,4) EQ 'IF')).END    00520000
  MNOTE 8,'NEGATIVE INSTRUCTION STACK PTR. EXPANSION INVALID.'          00530000
.END  MEND                                                              00540000
./   ADD   NAME=POPNEST  SS=0101120252120261211433002900290000DSK       ********
  MACRO                                                                 00010000
 POPNEST &P1                                                            00020000
 GBLA &CCVAL       COND CODE VARIABLE                                   00030000
 GBLA &CTR       MACRO PARAMETER COUNTER                                00040000
 GBLA &SEQ       LABEL NUMBER GENERATOR                                 00050000
 GBLA &AI       INDEX FOR TOTAL NO. CASES STK                           00060000
 GBLA &CI       INDEX FOR CASE AND LBL NO. STKS                         00070000
 GBLA &II       PTR TO INST STKS                                        00080000
 GBLA &LI       INDEX FOR LABEL NUMBER STK                              00090000
 GBLA &NI       PTR TO NEST STK                                         00100000
 GBLA &AIND(50)       TOTAL CASES STK                                   00110000
 GBLA &CIND1(200)      CASE NUMBER STK                                  00120000
 GBLA &MULT(50)       CASE NUMBER MULTIPLIER                            00130000
 GBLA &ST(51)       INST STK INCREASE AT EACH LEVEL                     00140000
 GBLC &CIND2(200)      LABEL NUMBER STK FOR CASES                       00150000
 GBLC &IIND1(100)      INSTRUCTION STK 1                                00160000
 GBLC &IIND2(100)      INSTRUCTION STK 2                                00170000
 GBLC &I22(100)       INSTRUCTION STK 2, 2ND PART                       00180000
 GBLC &I23(100)       INSTRUCTION STK 2, 3RD PART                       00190000
 GBLC &I24(100)       INSTRUCTION STK 2, 4TH PART                       00200000
 GBLC &IIND3(100)      INSTRUCTION STK 3                                00210000
 GBLC &I32(100)       INSTRUCTION STK 3, 2ND PART                       00220000
 GBLC &I33(100)       INSTRUCTION STK 3, 3RD PART                       00230000
 GBLC &I34(100)       INSTRUCTION STK 3, 4TH PART                       00240000
 GBLC &IIND4(100)      INSTRUCTION STK 4                                00250000
 GBLC &I42(100)       INSTRUCTION STK 4, 2ND PART                       00260000
 GBLC &I43(100)       INSTRUCTION STK 4, 3RD PART                       00270000
 GBLC &IIND5(100)      INSTRUCTION NAME STACK                           00280000
 GBLC &LIND(101)      LABEL NUMBER STK                                  00290000
 GBLC &NEST(50)       NESTING STK                                       00300000
 GBLC &RIND(50)       REG STK FOR CASENTRY MACRO                        00310000
 LCLC &SUFFIX                                                           00320000
&SUFFIX  SETC  '&NEST(&NI)'(5,4)                                        00330000
  AIF   ('&NEST(&NI)'(5,4) EQ '&P1').GOOD                               00340000
  MNOTE 8,'&SUFFIX MACRO AT SAME LEVEL AS &P1 TERMINATOR.'              00350000
.GOOD  ANOP                                                             00360000
&NI  SETA  &NI-1                                                        00370000
  AIF   (&NI GE 0).OK                                                   00380000
  MNOTE 8,'NEGATIVE NEST STACK POINTER. CHECK NUMBER OF ENDS.'          00390000
.OK  ANOP                                                               00400000
  MEND                                                                  00410000
./   ADD   NAME=PUSHINS  SS=0101120252120261211437007100710000DSK       ********
      MACRO                                                             00010000
      PUSHINS &PAM                                                      00020000
  GBLA  &CCVAL   COND CODE VARIABLE                                     00030000
  GBLA  &CTR   MACRO PARAMETER COUNTER                                  00040000
  GBLA  &SEQ   LABEL NUMBER GENERATOR                                   00050000
  GBLA  &AI   INDEX FOR TOTAL NO. CASES STK                             00060000
  GBLA  &CI   INDEX FOR CASE AND LBL NO. STKS                           00070000
  GBLA  &II   PTR TO INST STKS                                          00080000
  GBLA  &LI   INDEX FOR LABEL NUMBER STK                                00090000
  GBLA  &NI   PTR TO NEST STK                                           00100000
  GBLA  &AIND(50)  TOTAL CASES STK                                      00110000
  GBLA  &CIND1(200)  CASE NUMBER STK                                    00120000
  GBLA  &MULT(50)  CASE NUMBER MULTIPLIER                               00130000
  GBLA  &ST(51)   INST STK INCREASE AT EACH LEVEL                       00140000
  GBLC  &CIND2(200)  LABEL NUMBER STK FOR CASES                         00150000
  GBLC  &IIND1(100)  INSTRUCTION STK 1                                  00160000
  GBLC  &IIND2(100)  INSTRUCTION STK 2                                  00170000
  GBLC  &I22(100)  INSTRUCTION STK 2, 2ND PART                          00180000
  GBLC  &I23(100)  INSTRUCTION STK 2, 3RD PART                          00190000
  GBLC  &I24(100)  INSTRUCTION STK 2, 4TH PART                          00200000
  GBLC  &IIND3(100)  INSTRUCTION STK 3                                  00210000
  GBLC  &I32(100)  INSTRUCTION STK 3, 2ND PART                          00220000
  GBLC  &I33(100)  INSTRUCTION STK 3, 3RD PART                          00230000
  GBLC  &I34(100)  INSTRUCTION STK 3, 4TH PART                          00240000
  GBLC  &IIND4(100)  INSTRUCTION STK 4                                  00250000
  GBLC  &I42(100)  INSTRUCTION STK 4, 2ND PART                          00260000
  GBLC  &I43(100)  INSTRUCTION STK 4, 3RD PART                          00270000
  GBLC  &IIND5(100)  INSTRUCTION NAME STACK                             00280000
  GBLC  &LIND(101)  LABEL NUMBER STK                                    00290000
  GBLC  &NEST(50)  NESTING STK                                          00300000
  GBLC  &RIND(50)  REG STK FOR CASENTRY MACRO                           00310000
      LCLA &WK,&I,&J,&K                                                 00320000
&I      SETA  3                                                         00330000
&J      SETA  4                                                         00340000
&K      SETA  4                                                         00350000
      AIF ('&PAM(1)'(1,1) EQ 'B' OR '&PAM(1)' EQ 'EQU').BCH             00360000
        AIF ('&PAM(5)' EQ '').TWOPERS                                   00370000
   AIF ('&PAM(1)'(1,1) EQ 'C').SETK                                     00380000
&J     SETA  5                                                          00390000
   AGO .GETCOND                                                         00400000
.TWOPERS       AIF ('&PAM(1)'(1,1) NE 'C').SETK                         00410000
&I        SETA  4                                                       00420000
&J        SETA  3                                                       00430000
.SETK        ANOP                                                       00440000
&K        SETA  5                                                       00450000
.GETCOND  GETCC &PAM(&J)                                                00460000
.BCH      AIF   (&II GE 100).OVERI                                      00470000
&II        SETA  &II+1                                                  00480000
&IIND1(&II)    SETC '&PAM(1)'                                           00490000
&IIND2(&II)    SETC '&PAM(2)'(1,8)                                      00500000
&WK    SETA K'&SYSLIST(1,2)                                             00510000
    AIF (&WK GE 25).LD24                                                00520000
&I24(&II)    SETC ''                                                    00530000
      AIF (&WK GE 17).LD23                                              00540000
&I23(&II)      SETC ''                                                  00550000
        AIF (&WK GE 9).LD22                                             00560000
&I22(&II)  SETC ''                                                      00570000
   AGO .PAM3                                                            00580000
.LD24        ANOP                                                       00590000
.* &I24(&II)   SETC '&PAM(2)'(25,8)   *** OLD STATEMENT                 00600000
.* CHANGE SO THAT OPERAND 2 IS NOT TRUNCATED TO 32 CHARACTERS (TSDER)   00610000
&I24(&II)      SETC '&PAM(2)'(25,&WK)                                   00620000
.LD23      ANOP                                                         00630000
&I23(&II)    SETC '&PAM(2)'(17,8)                                       00640000
.LD22    ANOP                                                           00650000
&I22(&II)  SETC  '&PAM(2)'(9,8)                                         00660000
.PAM3    AIF ('&PAM(&I)' NE '').LD31                                    00670000
&IIND3(&II)  SETC ''                                                    00680000
      AGO  .BLKOUT3                                                     00690000
.LD31    ANOP                                                           00700000
&IIND3(&II)    SETC '&PAM(&I)'(1,8)                                     00710000
.BLKOUT3   ANOP                                                         00720000
&WK    SETA K'&SYSLIST(1,&I)                                            00730000
    AIF (&WK GE 25).LD34                                                00740000
&I34(&II)    SETC ''                                                    00750000
      AIF (&WK GE 17).LD33                                              00760000
&I33(&II)      SETC ''                                                  00770000
        AIF (&WK GE 9).LD32                                             00780000
&I32(&II)  SETC ''                                                      00790000
   AGO .PAM4                                                            00800000
.LD34        ANOP                                                       00810000
.* &I34(&II)   SETC '&PAM(&I)'(25,8)    *** OLD STATEMENT               00820000
.* CHANGE SO THAT OPERAND 4 IS NOT TRUNCATED TO 32 CHARACTERS (TSDER)   00830000
&I34(&II)      SETC '&PAM(&I)'(25,&WK)                                  00840000
.LD33      ANOP                                                         00850000
&I33(&II)    SETC '&PAM(&I)'(17,8)                                      00860000
.LD32    ANOP                                                           00870000
&I32(&II)  SETC  '&PAM(&I)'(9,8)                                        00880000
.PAM4    AIF ('&PAM(&K)' NE '').LD41                                    00890000
&IIND4(&II)  SETC ''                                                    00900000
      AGO  .BLKOUT4                                                     00910000
.LD41    ANOP                                                           00920000
&IIND4(&II)  SETC '&PAM(&K)'(1,8)                                       00930000
.BLKOUT4   ANOP                                                         00940000
&WK    SETA K'&SYSLIST(1,&K)                                            00950000
    AIF (&WK GE 17).LD43                                                00960000
&I43(&II)    SETC ''                                                    00970000
      AIF (&WK GE 9).LD42                                               00980000
&I42(&II)      SETC ''                                                  00990000
        AGO .PAM5                                                       01000000
.LD43      ANOP                                                         01010000
&I43(&II)    SETC '&PAM(&K)'(17,8)                                      01020000
.LD42    ANOP                                                           01030000
&I42(&II)  SETC '&PAM(&K)'(9,8)                                         01040000
.PAM5    AIF ('&PAM(6)' EQ '').BLKOUT5                                  01050000
      AIF ('&PAM(6)'(1,4) NE '#@LB').BLKOUT5                            01060000
&IIND5(&II)    SETC '&PAM(6)'                                           01070000
      MEXIT                                                             01080000
.BLKOUT5   ANOP                                                         01090000
&IIND5(&II)  SETC ''                                                    01100000
    MEXIT                                                               01110000
.OVERI  MNOTE 8,'INSTRN STK SIZE EXCEEDED. FURTHER EXPANSIONS INVALID'  01120000
  MEND                                                                  01130000
./   ADD   NAME=PUSHLAB  SS=0101120252120261211439002600260000DSK       ********
  MACRO                                                                 00010000
  PUSHLAB                                                               00020000
  GBLA  &CCVAL   COND CODE VARIABLE                                     00030000
  GBLA  &CTR   MACRO PARAMETER COUNTER                                  00040000
  GBLA  &SEQ   LABEL NUMBER GENERATOR                                   00050000
  GBLA  &AI   INDEX FOR TOTAL NO. CASES STK                             00060000
  GBLA  &CI   INDEX FOR CASE AND LBL NO. STKS                           00070000
  GBLA  &II   PTR TO INST STKS                                          00080000
  GBLA  &LI   INDEX FOR LABEL NUMBER STK                                00090000
  GBLA  &NI   PTR TO NEST STK                                           00100000
  GBLA  &AIND(50)  TOTAL CASES STK                                      00110000
  GBLA  &CIND1(200)  CASE NUMBER STK                                    00120000
  GBLA  &MULT(50)  CASE NUMBER MULTIPLIER                               00130000
  GBLA  &ST(51)   INST STK INCREASE AT EACH LEVEL                       00140000
  GBLC  &CIND2(200)  LABEL NUMBER STK FOR CASES                         00150000
  GBLC  &IIND1(100)  INSTRUCTION STK 1                                  00160000
  GBLC  &IIND2(100)  INSTRUCTION STK 2                                  00170000
  GBLC  &I22(100)  INSTRUCTION STK 2, 2ND PART                          00180000
  GBLC  &I23(100)  INSTRUCTION STK 2, 3RD PART                          00190000
  GBLC  &I24(100)  INSTRUCTION STK 2, 4TH PART                          00200000
  GBLC  &IIND3(100)  INSTRUCTION STK 3                                  00210000
  GBLC  &I32(100)  INSTRUCTION STK 3, 2ND PART                          00220000
  GBLC  &I33(100)  INSTRUCTION STK 3, 3RD PART                          00230000
  GBLC  &I34(100)  INSTRUCTION STK 3, 4TH PART                          00240000
  GBLC  &IIND4(100)  INSTRUCTION STK 4                                  00250000
  GBLC  &I42(100)  INSTRUCTION STK 4, 2ND PART                          00260000
  GBLC  &I43(100)  INSTRUCTION STK 4, 3RD PART                          00270000
  GBLC  &IIND5(100)  INSTRUCTION NAME STACK                             00280000
  GBLC  &LIND(101)  LABEL NUMBER STK                                    00290000
  GBLC  &NEST(50)  NESTING STK                                          00300000
  GBLC  &RIND(50)  REG STK FOR CASENTRY MACRO                           00310000
  AIF   (&LI GE 100).OVER                                               00320000
&SEQ    SETA  &SEQ+1                                                    00330000
&LI    SETA  &LI+1                                                      00340000
&LIND(&LI) SETC '#@LB&SEQ'                                              00350000
  MEXIT                                                                 00360000
.OVER  MNOTE 8,' LABEL STK SIZE EXCEEDED. FURTHER EXPANSIONS INVALID'   00370000
    MEND                                                                00380000
./   ADD   NAME=PUSHNEST SS=0101120252120261211441002600260000DSK       ********
  MACRO                                                                 00010000
 PUSHNEST &P1                                                           00020000
 GBLA &CCVAL       COND CODE VARIABLE                                   00030000
 GBLA &CTR       MACRO PARAMETER COUNTER                                00040000
 GBLA &SEQ       LABEL NUMBER GENERATOR                                 00050000
 GBLA &AI       INDEX FOR TOTAL NO> CASES STK                           00060000
 GBLA &CI       INDEX FOR CASE AND LBL NO. STKS                         00070000
 GBLA &II       PTR TO INST STKS                                        00080000
 GBLA &LI       INDEX FOR LABEL NUMBER STK                              00090000
 GBLA &NI       PTR TO NEST STK                                         00100000
 GBLA &AIND(50)       TOTAL CASES STK                                   00110000
 GBLA &CIND1(200)      CASE NUMBER STK                                  00120000
 GBLA &MULT(50)       CASE NUMBER MULTIPLIER                            00130000
 GBLA &ST(51)       INST STK INCREASE AT EACH LEVEL                     00140000
 GBLC &CIND2(200)      LABEL NUMBER STK FOR CASES                       00150000
 GBLC &IIND1(100)      INSTRUCTION STK 1                                00160000
 GBLC &IIND2(100)      INSTRUCTION STK 2                                00170000
 GBLC &I22(100)       INSTRUCTION STK 2, 2ND PART                       00180000
 GBLC &I23(100)       INSTRUCTION STK 2, 3RD PART                       00190000
 GBLC &I24(100)       INSTRUCTION STK 2, 4TH PART                       00200000
 GBLC &IIND3(100)      INSTRUCTION STK 3                                00210000
 GBLC &I32(100)       INSTRUCTION STK 3, 2ND PART                       00220000
 GBLC &I33(100)       INSTRUCTION STK 3, 3RD PART                       00230000
 GBLC &I34(100)       INSTRUCTION STK 3, 4TH PART                       00240000
 GBLC &IIND4(100)      INSTRUCTION STK 4                                00250000
 GBLC &I42(100)       INSTRUCTION STK 4, 2ND PART                       00260000
 GBLC &I43(100)       INSTRUCTION STK 4, 3RD PART                       00270000
 GBLC &IIND5(100)      INSTRUCTION NAME STACK                           00280000
 GBLC &LIND(101)      LABEL NUMBER STK                                  00290000
 GBLC &NEST(50)       NESTING STK                                       00300000
 GBLC &RIND(50)       REG STK FOR CASENTRY MACRO                        00310000
&NI  SETA  &NI+1                                                        00320000
  AIF   (&NI GE 50).OVER                                                00330000
&NEST(&NI) SETC '    &P1'                                               00340000
  MEXIT                                                                 00350000
.OVER  ANOP                                                             00360000
  MNOTE 8,'NEST STACK SIZE EXCEEDED. FURTHER EXPANSIONS INVALID'        00370000
  MEND                                                                  00380000
./   ADD   NAME=WHEN     SS=010112025212026121144400AB00AB0000DSK       ********
         MACRO                                                          00010000
&LAB     WHEN                                                           00020000
.*                                                                      00030000
.* THIS MACRO IS ONE OF A RELATED SET OF MACROS WHICH ENGINEER THE      00040000
.* SELECTED EXECUTION OF CODE DEPENDING ON THE CONTENTS OF A FIELD.     00050000
.*                                                                      00060000
.* THE GENERAL STRUCTURE IS AS FOLLOWS -                                00070000
.*    EVALUATE OPCODE,OP1(,OP2.REP.TYPE.LTH)                            00080000
.*      WHEN   OP2REST,OP2REST                                          00090000
.*      WHEN   OP2REST-OP2REST,OP2REST                                  00100000
.*      OTHERWSE                                                        00110000
.*    ENDEVAL                                                           00120000
.*                                                                      00130000
.* OPCODE FOR EACH POSSIBLE DEPTH                                       00140000
         GBLC  &OP(16)                                                  00150000
.* COMPONENTS OF OPERAND 1 FOR EACH POSSIBLE DEPTH                      00160000
         GBLC  &OP1(16)                                                 00170000
.* OPERAND 2 (REP.TYPE.LENGTH) IF ANY - FOR EACH POSSIBLE DEPTH         00180000
         GBLC  &OP2(16)                                                 00190000
.* CURRENT LABEL GENERATION NUMBER FOR EACH POSSIBLE DEPTH              00200000
         GBLA  &ON(16)                                                  00210000
.* CURRENT END LABEL NUMBER FOR EACH POSSIBLE DEPTH                     00220000
         GBLA  &OE(16)                                                  00230000
.* CURRENT DEPTH OF OPTION NESTING (1 TO 16)                            00240000
         GBLA  &OD                                                      00250000
.* IMMEDIATE INDICATOR FOR EACH POSSIBLE DEPTH                          00260000
         GBLB  &OI(16)                                                  00270000
.* QUOTES INDICATOR FOR EACH POSSIBLE DEPTH                             00280000
         GBLB  &OQ(16)                                                  00290000
.* STATUS INDICATOR FOR EACH POSSIBLE DEPTH                             00300000
         GBLB  &OS(16)                                                  00310000
.* OPTELSE INDICATOR FOR EACH POSSIBLE DEPTH                            00320000
         GBLB  &OELSE(16)                                               00330000
.* OPTION INDICATOR FOR EACH POSSIBLE DEPTH                             00340000
         GBLB  &OPTN(16)                                                00350000
.*                                                                      00360000
.* LOCAL WORK FIELDS                                                    00370000
         LCLA  &A,&B,&C,&D,&E,&U                                        00380000
         LCLC  &L1,&L2,&L3,&L4,&L5,&L6,&L7                              00390000
         LCLB  &H,&Z                                                    00400000
.*                                                                      00410000
.IF0     AIF   (T'&LAB EQ 'O').END0                                     00420000
&LAB     EQU   *                                                        00430000
.END0    ANOP                                                           00440000
.IF0A    AIF   (&OD GT 0).END0A                                         00450000
         MNOTE 16,'OPTION MISSING'                                      00460000
         MEXIT                                                          00470000
.END0A   ANOP                                                           00480000
.IF1     AIF   (&OD LE 16).END1                                         00490000
         MNOTE 16,'MAX OPTION NESTING OF 16 EXCEEDED'                   00500000
         MEXIT                                                          00510000
.END1    ANOP                                                           00520000
.* SET EXIT FOR PREVIOUS CODE                                           00530000
         BRU   @D&OD.E&OE(&OD)                                          00540000
.* SET LABEL FOR ENTRY                                                  00550000
@D&OD.N&ON(&OD) EQU   *                                                 00560000
.* INCREMENT LABEL GENERATION NUMBER                                    00570000
&ON(&OD) SETA  &ON(&OD)+1                                               00580000
.* SET OPTION INDICATOR OFF                                             00590000
&OPTN(&OD) SETB (0)                                                     00600000
.IF1AA   AIF   ((&OELSE(&OD)) EQ (0)).END1AA                            00610000
         MNOTE 16,'OPTELSE PRECEDES OPT'                                00620000
         MEXIT                                                          00630000
.END1AA  ANOP                                                           00640000
.* SAVE CURRENT LABEL GENERATION NUMBER FOR USER-CODE LABEL             00650000
&U       SETA  &ON(&OD)                                                 00660000
.* INCREMENT LABEL GENERATION NUMBER                                    00670000
&ON(&OD) SETA  &ON(&OD)+1                                               00680000
.IF1AB   AIF   ((&OS(&OD)) EQ (0)).END1AB                               00690000
         MNOTE 16,'OPTION STATEMENT ERROR'                              00700000
         MEXIT                                                          00710000
.END1AB  ANOP                                                           00720000
&A       SETA  N'&SYSLIST                                               00730000
.IF1B    AIF   (&A NE 0).END1B                                          00740000
         MNOTE 16,'NO OPT PARAMETERS'                                   00750000
         MEXIT                                                          00760000
.END1B   ANOP                                                           00770000
&B       SETA  0                                                        00780000
.DO1     AIF   (&A EQ &B).NDO1                                          00790000
.* DO FOR EACH PARAMETER OF OPT                                         00800000
&B       SETA  &B+1                                                     00810000
&C       SETA  K'&SYSLIST(&B)                                           00820000
.IF2     AIF   ((&OQ(&OD)) EQ (0)).ELS2                                 00830000
         AIF   ('&SYSLIST(&B)'(1,1) NE '''').QMN                        00840000
         AIF   ('&SYSLIST(&B)'(&C,1) EQ '''').OKQ                       00850000
.QMN     MNOTE 16,'UNQUOTED OPT PARAMETER'                              00860000
         MEXIT                                                          00870000
.OKQ     AIF   (&C GT 2).END2                                           00880000
         MNOTE 16,'NULL QUOTES OPT PARAMETER'                           00890000
         MEXIT                                                          00900000
.ELS2    AIF   ('&SYSLIST(&B)'(1,1) NE '''').END2                       00910000
         MNOTE 16,'MISQUOTED OPT PARAMETER'                             00920000
         MEXIT                                                          00930000
.END2    ANOP                                                           00940000
.* FIND IF THERE IS A RANGE                                             00950000
&D       SETA  0                                                        00960000
&H       SETB  (0)                                                      00970000
.DO2     AIF   (&C EQ &D).NDO2                                          00980000
.* DO FOR EACH CHARACTER OF PARAMETER                                   00990000
&D       SETA  &D+1                                                     01000000
         AIF   ('&SYSLIST(&B)'(&D,1) NE '-').ADO2                       01010000
.IF4     AIF   ((&OQ(&OD)) EQ (0)).ELS4                                 01020000
         AIF   ('&SYSLIST(&B)'(&D-1,1) NE '''').ADO2                    01030000
         AIF   ('&SYSLIST(&B)'(&D+1,1) NE '''').ADO2                    01040000
         AIF   (&D EQ 2).ADO2                                           01050000
.* HAVE FOUND A HYPHEN (BETWEEN QUOTES BECAUSE QUOTES ARE CURRENT)      01060000
&H       SETB  (1)                                                      01070000
         AGO   .NDO2                                                    01080000
.ELS4    ANOP                                                           01090000
.* HAVE FOUND A HYPHEN                                                  01100000
&H       SETB  (1)                                                      01110000
         AGO   .NDO2                                                    01120000
.END4    ANOP                                                           01130000
.ADO2    AGO   .DO2                                                     01140000
.NDO2    ANOP                                                           01150000
&L1      SETC  '&OP(&OD)'                                               01160000
&L2      SETC  '&OP1(&OD)'                                              01170000
&L3      SETC  '&OP2(&OD)'                                              01180000
.*                                                                      01190000
.* GENERATE LABEL FOR COMPARE CLAUSE IF NOT 1ST AND RANGE NOT PREVIOUS  01200000
.IF5     AIF   (&B EQ 1).END5                                           01210000
         AIF   ((&Z) EQ (0)).END5                                       01220000
@D&OD.N&ON(&OD) EQU *                                                   01230000
.* INCREMENT LABEL GENERATION COUNT                                     01240000
&ON(&OD) SETA  &ON(&OD)+1                                               01250000
.END5    ANOP                                                           01260000
.* GENERATE COMPARE CLAUSE LOGIC                                        01270000
.IF6     AIF   ((&H) EQ (0)).ELS6                                       01280000
.* WHEN A RANGE  &H IS 1 AND &D WILL HOLD HYPHEN OFFSET                 01290000
&E       SETA  &D-1                                                     01300000
&L4      SETC  '&SYSLIST(&B)'(1,&E)                                     01310000
         &L1   &L2,&L3&L4                                               01320000
         JL    @D&OD.N&ON(&OD)                                          01330000
&E       SETA  &C-&D                                                    01340000
&L5      SETC  '&SYSLIST(&B)'(&D+1,&E)                                  01350000
         &L1   &L2,&L3&L5                                               01360000
.IF7     AIF   (&B EQ &A).ELS7                                          01370000
.* WHEN NOT LAST CLAUSE GENERATE BRANCH DIRECT TO USER-CODE             01380000
         JNH   @D&OD.N&U                                                01390000
         AGO   .END7                                                    01400000
.ELS7    ANOP                                                           01410000
.* FOR LAST CLAUSE GENERATE BRANCH TO NEXT OPTION                       01420000
         JH    @D&OD.N&ON(&OD)                                          01430000
.IF7A    AIF   (&A EQ 1).END7A                                          01440000
.* GENERATE USER-CODE ENTRY LABEL WHEN MORE THAN A SINGLE PARAMETER     01450000
@D&OD.N&U EQU  *                                                        01460000
.END7A   ANOP                                                           01470000
.END7    ANOP                                                           01480000
&Z       SETB  (1)                                                      01490000
         AGO   .END6                                                    01500000
.ELS6    ANOP                                                           01510000
.* HAVE SIMPLE CLAUSE WITH SINGLE TERM                                  01520000
&L6      SETC  '&SYSLIST(&B)'(1,&C)                                     01530000
         &L1   &L2,&L3&L6                                               01540000
.IF8     AIF   (&B EQ &A).ELS8                                          01550000
.* WHEN NOT LAST CLAUSE GENERATE BRANCH DIRECT TO USER-CODE             01560000
         JE    @D&OD.N&U                                                01570000
         AGO   .END8                                                    01580000
.ELS8    ANOP                                                           01590000
.* FOR LAST CLAUSE GENERATE BRANCH TO NEXT OPTION                       01600000
         JNE   @D&OD.N&ON(&OD)                                          01610000
.IF9     AIF   (&A EQ 1).END9                                           01620000
.* GENERATE USER-CODE ENTRY LABEL WHEN MORE THAN A SINGLE PARAMETER     01630000
@D&OD.N&U EQU  *                                                        01640000
.END9    ANOP                                                           01650000
.END8    ANOP                                                           01660000
&Z       SETB  (0)                                                      01670000
.END6    ANOP                                                           01680000
.ADO1    AGO   .DO1                                                     01690000
.NDO1    ANOP                                                           01700000
         MEND                                                           01710000
./   ENDUP                                                              ********
