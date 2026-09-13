PGTE     TITLE 'BLSSPGTE--FIND PAGE TABLE (PGT)                        *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPRW                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSSPGTE CSECT ,                                                01S0002 00006000
@MAINENT DS    0H                                               01S0002 00007000
         USING *,@15                                            01S0002 00008000
         B     @PROLOG                                          01S0002 00009000
         DC    AL1(23)                                          DSKC098 00010000
         DC    C'BLSSPGTE 79325 UZ29043 '                       DSKC098 00011000
         DROP  @15                                                      00012000
@PROLOG  STM   @14,@12,12(@13)                                  01S0002 00013000
         BALR  @12,0                                            01S0002 00014000
@PSTART  DS    0H                                               01S0002 00015000
         USING @PSTART,@12                                      01S0002 00016000
         L     @00,@SIZDATD                                     01S0002 00017000
         BLSUALLS R,LV=(0)                                              00018000
         LR    @11,@01                                          01S0002 00019000
         USING @DATD,@11                                        01S0002 00020000
         ST    @13,@SA00001+4                                   01S0002 00021000
         LM    @00,@01,20(@13)                                  01S0002 00022000
         ST    @11,8(,@13)                                      01S0002 00023000
         LR    @13,@11                                          01S0002 00024000
         MVC   @PC00001(8),0(@01)                               01S0002 00025000
         SLR   @06,@06                                          DSKC098 00025010
*   RETC=ZZZFLAGS;                  /* RETURN CODE                   */ 00026000
         LA    @15,12                                           DSKC098 00027000
*   R8=ADDR(ESPA);                  /* ->ESBA (ALIAS FOR ESPA)       */ 00028000
         L     @08,@PC00001+4                                   DSKC098 00029000
*   RA=ADDR(ZZ1);                   /* ->ZZ1 (MACRO BLSUZZ1)         */ 00030000
         L     @10,ZZ2ZZ1P(,@09)                                DSKC098 00031000
*   RESPECIFY                                                   01S0150 00032000
*     ZZ1 BASED(RA);                /* ZZ1--IPCS COMMON AREA         */ 00033000
*   IF SYMBA^='PGT'×ESBASYM(LENGTH(SYMB)+1:LENGTH(ESBASYM))^=BLANKSUF   00034000
*     THEN                          /* INVALID SYMBOL                */ 00035000
         CLC   SYMBA(3,@08),@CC01272                            DSKC098 00036000
         BNE   EXIT                                             DSKC098 00037000
         CLC   ESBASYM+8(23,@08),BLANKSUF                       DSKC098 00038000
         BNE   EXIT                                             DSKC098 00039000
*     GO TO EXIT;                   /* COMMON EXIT PATH              */ 00040000
*   DO J1=1 TO LENGTH(SYMBB) WHILE(SYMBB(J1:J1)>='0'&SYMBB(J1:J1)<='9') 00041000
*         ;                                                     01S0153 00042000
         LA    @02,1                                            DSKC098 00043000
@DL00153 LR    @03,@08                                          DSKC098 00044000
         ALR   @03,@02                                          DSKC098 00045000
         CLI   SYMBB-1(@03),C'0'                                DSKC098 00046000
         BL    @DC00153                                         01S0153 00047000
         LR    @07,@08                                          DSKC098 00048000
         ALR   @07,@02                                          DSKC098 00049000
         CLI   SYMBB-1(@07),C'9'                                DSKC098 00050000
         BH    @DC00153                                         01S0153 00051000
*   END;                                                        01S0154 00052000
         AH    @02,@CH00046                                     DSKC098 00053000
         CH    @02,@CH00156                                     DSKC098 00054000
         BNH   @DL00153                                         01S0154 00055000
@DC00153 DS    0H                                               01S0155 00056000
*   IF J1<=LENGTH(SYMBB) THEN       /* NON-NUMERIC CODE              */ 00057000
         CH    @02,@CH00156                                     DSKC098 00058000
         BNH   EXIT                                             DSKC098 00059000
*     GO TO EXIT;                   /* COMMON EXIT PATH              */ 00060000
*                                                               01S0156 00061000
*   /*****************************************************************/ 00062000
*   /*                                                               */ 00063000
*   /* DETERMINE SEGMENT NUMBER                                      */ 00064000
*   /*                                                               */ 00065000
*   /*****************************************************************/ 00066000
*                                                               01S0157 00067000
*   RESPECIFY                                                   01S0157 00068000
*    (R2) RESTRICTED;               /* TRT RESULT REGISTER           */ 00069000
*   R2=0;                           /* TRT RESULT REGISTER           */ 00070000
         SLR   @02,@02                                          DSKC098 00071000
*   SEGMENT=0;                      /* SEGMENT NUMBER                */ 00072000
         SLR   @05,@05                                          DSKC098 00073000
*   GENERATE REFS(SYMBC,ZZ1TRTAS) SETS(R1,R2) CODE              01S0160 00074000
*       (TRT   SYMBC(2,R8),ZZ1TRTAS(RA));                       01S0160 00075000
         TRT   SYMBC(2,@08),ZZ1TRTAS(@10)                       DSKC098 00076000
*   BC(2,L010);                     /* UPPER CASE AB-AZ              */ 00077000
         BC    2,L010                                           01S0161 00078000
*   BC(8,L020);                     /* UPPER CASE AA                 */ 00079000
         BC    8,L020                                           01S0162 00080000
*   SEGMENT=R2*ZZZALPSM;            /* SEGMENT NUMBER                */ 00081000
         LR    @05,@02                                          DSKC098 00082000
         MH    @05,@CH00183                                     DSKC098 00083000
*   IF SEGMENT>255 THEN             /* ABSURD SEGMENT NUMBER         */ 00084000
         CH    @05,@CH01322                                     DSKC098 00085000
         BH    EXIT                                             DSKC098 00086000
*     GO TO EXIT;                   /* COMMON EXIT PATH              */ 00087000
*   GENERATE REFS(SYMBC,ZZ1TRTAS) SETS(R1,R2) CODE              01S0166 00088000
*       (TRT   SYMBC+1(1,R8),ZZ1TRTAS(RA));                     01S0166 00089000
         TRT   SYMBC+1(1,@08),ZZ1TRTAS(@10)                     DSKC098 00090000
*   BC(8,L020);                     /* UPPER CASE BA, CA, ..., ZA    */ 00091000
         BC    8,L020                                           01S0167 00092000
*L010:                              /* UPPER CASE AB-AZ              */ 00093000
*   IF R2>=ZZZALPSM THEN            /* NON-ALPHABETIC CHARACTER      */ 00094000
L010     CH    @02,@CH00183                                     DSKC098 00095000
         BNL   EXIT                                             DSKC098 00096000
*     GO TO EXIT;                   /* COMMON EXIT PATH              */ 00097000
*   SEGMENT=SEGMENT+R2;             /* SEGMENT NUMBER                */ 00098000
         ALR   @05,@02                                          DSKC098 00099000
*   RESPECIFY                                                   01S0171 00100000
*    (R2) UNRESTRICTED;             /* TRT RESULT REGISTER           */ 00101000
*L020:                              /* AA, BA, ..., ZA               */ 00102000
*   IF SEGMENT>255 THEN             /* ABSURD SEGMENT NUMBER         */ 00103000
L020     CH    @05,@CH01322                                     DSKC098 00104000
         BH    EXIT                                             DSKC098 00105000
*     GO TO EXIT;                   /* COMMON EXIT PATH              */ 00106000
*                                                               01S0173 00107000
*   /*****************************************************************/ 00108000
*   /*                                                               */ 00109000
*   /* LOCATE SEGMENT TABLE FOR THE MEMORY                           */ 00110000
*   /*                                                               */ 00111000
*   /*****************************************************************/ 00112000
*                                                               01S0174 00113000
*   ESAUSYM=ESBASYM;                /* SYMBOL                        */ 00114000
         MVC   ESAUSYM(31),ESBASYM(@08)                         DSKC098 00115000
*   SYMAA(1:1)='S';                 /* CHANGE PGT=>SGT               */ 00116000
         MVI   SYMAA,C'S'                                       01S0175 00117000
*   SYMAC=' ';                      /* NO SEGMENT NUMBER SUFFIX      */ 00118000
         MVI   SYMAC,C' '                                       DSKC098 00119000
         MVI   SYMAC+1,C' '                                     DSKC098 00120000
*   ESAUDT=DATCT;                   /* DATA TYPE                     */ 00121000
         MVC   ESAUDT(34),DATCT                                 01S0177 00122000
*   CALL BLSRESGU(ZZ2,ESAU);        /* LOCATE SEGMENT TABLE          */ 00123000
         ST    @09,@AL00001                                     DSKC098 00124000
         LA    @07,ESAU                                         DSKC098 00125000
         ST    @07,@AL00001+4                                   DSKC098 00126000
         L     @04,ZZ2RVTP(,@09)                                DSKC098 00127000
         LA    @01,@AL00001                                     DSKC098 00128000
         L     @15,RVTESGUP(,@04)                               DSKC098 00129000
         BALR  @14,@15                                          01S0178 00130000
*   RETC=RF;                        /* RETURN CODE                   */ 00131000
*   IF RF>ZZZFLAGE THEN             /* SEGMENT TABLE NOT FOUND       */ 00133000
         CH    @15,@CH00054                                     DSKC098 00134000
         BH    EXIT                                             DSKC098 00135000
*     GO TO EXIT;                   /* COMMON EXIT PATH              */ 00136000
*                                                               01S0181 00137000
*   /*****************************************************************/ 00138000
*   /*                                                               */ 00139000
*   /* RETRIEVE SEGMENT TABLE ENTRY                                  */ 00140000
*   /*                                                               */ 00141000
*   /*****************************************************************/ 00142000
*                                                               01S0182 00143000
*   ESAUD=DATC;                     /* STORAGE ATTRIBUTES            */ 00144000
         MVC   ESAUD(60),DATC                                   01S0182 00145000
*   ESAUDOF=SEGMENT*LENGTH(SGTSTE); /* OFFSET                        */ 00146000
         LR    @03,@05                                          DSKC098 00147000
         SLA   @03,2                                            DSKC098 00148000
         ST    @03,ESAUDOF                                      DSKC098 00149000
*   ESAUDIL=SEGMENT;                /* SEGMENT NUMBER                */ 00150000
         ST    @05,ESAUDIL                                      DSKC098 00151000
*   STEPTR=ADDR(BUF);               /* ->SEGMENT TABLE ENTRY         */ 00152000
         LA    @02,BUF                                          DSKC098 00153000
*   CALL BLSRACC(ZZ2,ESAU,SGTSTE);  /* RETRIEVE SEGMENT TABLE IMAGE  */ 00154000
         ST    @09,@AL00001                                     DSKC098 00155000
         LA    @03,ESAU                                         DSKC098 00156000
         ST    @03,@AL00001+4                                   DSKC098 00157000
         ST    @02,@AL00001+8                                   DSKC098 00158000
         L     @07,ZZ2RVTP(,@09)                                DSKC098 00159000
         LA    @01,@AL00001                                     DSKC098 00160000
         L     @15,RVTRACCP(,@07)                               DSKC098 00161000
         BALR  @14,@15                                          01S0186 00162000
*   IF RF>ZZZFLAGI×SGTPAM='1'B×SGTPTL^='F'X THEN                01S0187 00163000
*                                                               01S0187 00164000
         LTR   @15,@15                                          DSKC098 00165000
         BP    @RT00187                                         01S0187 00166000
         TM    SGTPAM(@02),B'00000001'                          DSKC098 00167000
         BO    @RT00187                                         01S0187 00168000
         TM    SGTPTL(@02),B'11110000'                          DSKC098 00169000
         BO    @RF00187                                         01S0187 00170000
@RT00187 DS    0H                                               01S0188 00171000
*     /***************************************************************/ 00172000
*     /*                                                             */ 00173000
*     /* ERROR PROCESSING SEGMENT TABLE ENTRY                        */ 00174000
*     /*                                                             */ 00175000
*     /***************************************************************/ 00176000
*                                                               01S0188 00177000
*     DO;                           /* ERROR PROCESSING SGTE         */ 00178000
*       RETC=MAX(RF,ZZZFLAGS);      /* RETURN CODE                   */ 00179000
         LA    @06,12                                           DSKC098 00180000
*       GO TO EXIT;                 /* COMMON EXIT PATH              */ 00184000
         B     EXIT                                             01S0190 00185000
*     END;                          /* ERROR PROCESSING SGTE         */ 00186000
*   ESBAAS=ESAUAS;                  /* ADDRESS SPACE                 */ 00187000
@RF00187 MVC   ESBAAS(16,@08),DATC99                            DSKC098 00188000
*   IF ESAUAST^=ZZZASTA&ESAUAST^=ZZZASTCR THEN                  01S0193 00189000
*                                                               01S0193 00190000
*     /***************************************************************/ 00195000
*     /*                                                             */ 00196000
*     /* PAGE TABLE EXISTS IN REAL STORAGE                           */ 00197000
*     /*                                                             */ 00198000
*     /***************************************************************/ 00199000
*                                                               01S0194 00200000
*     DO;                           /* PGT EXISTS IN REAL STORAGE    */ 00201000
*       ESBAAS=DATS;                /* REAL STORAGE                  */ 00202000
*       ESBAAS1=ZZ6DQA1;            /* PREFERRRED CPU ADDRESS        */ 00204000
*     END;                          /* PGT EXISTS IN REAL STORAGE    */ 00207000
*   ESBALAD=SGTSTE&'00FFFFF8'X;     /* ->PAGE TABLE                  */ 00208000
@RF00193 L     @07,SGTSTE(,@02)                                 DSKC098 00209000
         N     @07,@CF01327                                     DSKC098 00210000
         ST    @07,ESBALAD(,@08)                                DSKC098 00211000
*   CALL BLSRSAGU(ZZ2,SAAU,ESBA);   /* SCAN PAGE TABLE               */ 00212000
         ST    @09,@AL00001                                     DSKC098 00213000
         ST    @08,@AL00001+4                                   DSKC098 00215000
         L     @07,ZZ2RVTP(,@09)                                DSKC098 00217000
         LA    @01,@AL00001                                     DSKC098 00218000
         L     @15,RVT0078P(,@07)                               DSKC098 00219000
         BALR  @14,@15                                          01S0199 00220000
*   RETC=MAX(RETC,RF,SAAUSRC);      /* RETURN CODE                   */ 00221000
*   IF RETC<ZZZFLAGS THEN           /* NO SERIOUS ERROR(S) DETECTED  */ 00232000
*     RMKB=RMKS;                    /* REMARK                        */ 00235000
         MVC   RMKB(12,@08),RMKS                                DSKC098 00236000
EXIT     CR    @06,@15                                          DSKC098 00236010
         BNL   374(,@12)                                        DSKC098 00236020
         LR    @06,@15                                          DSKC098 00236030
*EXIT:                              /* COMMON EXIT PATH              */ 00237000
*   RETURN CODE(RETC);                                          01S0203 00238000
*                                                               01S0203 00239000
@RF00201 DS    0H                                               01S0203 00240000
         L     @13,4(,@13)                                      01S0203 00241000
         L     @00,@SIZDATD                                     01S0203 00242000
         LR    @01,@11                                          01S0203 00243000
         BLSUFRES R,LV=(0),A=(1)                                        00244000
         LR    @15,@06                                          DSKC098 00245000
         L     @14,12(,@13)                                     01S0203 00246000
         LM    @00,@12,20(@13)                                  01S0203 00247000
         BR    @14                                              01S0203 00248000
*/*BLSSPEND--FIND EXIT                                               */ 00249000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00250000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00251000
*                                                               01S0204 00252000
*   DECLARE                         /* COMMON VARIABLES              */ 00253000
*     I256C CHAR(256) BASED,                                    01S0204 00254000
*     I031F FIXED(31) BASED,                                    01S0204 00255000
*     I031P PTR(31) BASED,                                      01S0204 00256000
*     I015F FIXED(15) BASED,                                    01S0204 00257000
*     I015P PTR(15) BASED,                                      01S0204 00258000
*     I008P PTR(8) BASED,                                       01S0204 00259000
*     I001C CHAR(1) BASED;                                      01S0204 00260000
*   GENERATE NODEFS NOREFS DATA;                                01S0205 00261000
*   END BLSSPGTE                    /* BLRPEND(BLSSPGTE)             */ 00262000
*                                                               01S0206 00263000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00264000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00265000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00266000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00267000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00268000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00269000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00270000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00271000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00272000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00273000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00274000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00275000
*/*%INCLUDE SYSLIB  (IHASGTE )                                       */ 00276000
*                                                               01S0206 00277000
*       ;                                                       01S0206 00278000
@EL00001 L     @13,4(,@13)                                      01S0206 00279000
@EF00001 L     @00,@SIZDATD                                     01S0206 00280000
         LR    @01,@11                                          01S0206 00281000
         BLSUFRES R,LV=(0),A=(1)                                        00282000
@ER00001 LM    @14,@12,12(@13)                                  01S0206 00283000
         BR    @14                                              01S0206 00284000
@DATA    DS    0H                                                       00285000
@CH00046 DC    H'1'                                                     00286000
@CH00156 DC    H'3'                                                     00287000
@CH00054 DC    H'8'                                                     00288000
@CH00183 DC    H'26'                                                    00290000
@CH01322 DC    H'255'                                                   00291000
@DATD    DSECT                                                          00292000
         DS    0F                                                       00293000
@SA00001 DS    18F                                                      00294000
@PC00001 DS    2F                                                       00295000
@AL00001 DS    3A                                                       00296000
BLSSPGTE CSECT                                                          00297000
         DS    0F                                                       00298000
@CF01327 DC    XL4'00FFFFF8'                                            00299000
@DATD    DSECT                                                          00300000
         DS    0D                                                       00301000
VSAMBUFR DS    CL694                                            DSKC098 00302000
BUF      DS    CL4                                                      00303000
BLSSPGTE CSECT                                                          00304000
         DS    0F                                                       00305000
@SIZDATD DC    AL1(0)                                                   00306000
         DC    AL3(@ENDDATD-@DATD)                                      00307000
         DC    F'12'                                            DSKC098 00308000
@CC01272 DC    C'PGT'                                                   00309000
         DC    X'10'                         !!! SOURCE COMPARE FIX !!! 00312000
         DC    0H'0'                                            DSKC098 00312000
RMKS     DS    CL12                                                     00313000
         ORG   RMKS                                                     00314000
RMKSL    DC    AL2(10)                                                  00315000
RMKST    DS    CL10                                                     00316000
         ORG   RMKST                                                    00317000
RMKSTA   DC    CL10'PAGE TABLE'                                         00318000
         ORG   RMKS+12                                                  00319000
DATC     DS    CL60                                                     00320000
         ORG   DATC                                                     00321000
DATC00   DS    0C                                                       00322000
DATCOF   DC    F'0'                                                     00323000
DATCLE   DC    AL4(4)                                                   00324000
DATCOB   DC    AL1(0)                                                   00325000
DATCLB   DC    AL1(0)                                                   00326000
DATCT    DS    CL34                                                     00327000
         ORG   DATCT                                                    00328000
DATCT0   DS    0C                                                       00329000
DATCTY   DC    CL1'M'                                                   00330000
@NM00128 DC    X'00'                                                    00331000
DATCTD   DC    CL31'SGTE'                                               00332000
DATCTE   DC    CL1' '                                                   00333000
DATCT9   DS    0C                                                       00334000
         ORG   DATC+44                                                  00335000
DATCIM   DC    AL4(1+1-1)                                               00336000
DATCIL   DC    F'1'                                                     00337000
DATCF    DC    X'80000000'                                              00338000
         ORG   DATCF                                                    00339000
DATCFA   DS    BL1                                                      00340000
@NM00129 EQU   DATCF+0                                                  00341000
         ORG   DATC+56                                                  00342000
@NM00130 DC    X'00'                                                    00343000
         DC    XL3'0'                                                   00344000
DATC99   DS    0C                                                       00345000
         ORG   DATC+60                                                  00346000
DATS     DS    CL16                                                     00347000
         ORG   DATS                                                     00348000
DATS0    DS    0C                                                       00349000
DATST    DC    CL2'A '                                          DSKC098 00350000
@NM00131 DC    X'0000'                                                  00351000
DATS1    DC    A(0)                                                     00352000
DATS2    DC    A(0)                                                     00353000
@NM00132 DC    X'00'                                                    00354000
         DC    XL3'0'                                                   00355000
DATS9    DS    0C                                                       00356000
         ORG   DATS+16                                                  00357000
BLANKSUF DC    CL23' '                                                  00358000
@DATD    DSECT                                                          00359000
         SPACE 2                                                        00360000
*********************************************************************** 00361000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00362000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00363000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00364000
*********************************************************************** 00365000
         SPACE                                                          00366000
BLSSPGTE CSECT                                                          00367000
         ORG                                                            00368000
         DS    0D                                                       00369000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSSPGTE+19)/20+7)/8)CL8'BLSSPGTE'     00370000
@DATD    DSECT                                                          00371000
         DS    0H                                                       00372000
@DATD    DSECT                                                          00373000
         SPACE 2                                                        00374000
*********************************************************************** 00375000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00376000
*********************************************************************** 00377000
         SPACE                                                          00378000
         DS    0D                                                       00379000
@DATD    DSECT                                                          00380000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00381000
@ENDDATD EQU   *                                                        00382000
BLSSPGTE CSECT                                                          00383000
         BLSBVT  ,                                              DSKC098 00383010
         BLSESBA ,                                              DSKC098 00383020
         BLSESPA ,                                              DSKC098 00383030
         BLSRVT  ,                                              DSKC098 00383040
         BLSZZ1  ,                                              DSKC098 00383050
         BLSZZ2  ,                                              DSKC098 00383060
         BLSZZ6  ,                                              DSKC098 00383070
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00384000
@01      EQU   01                                                       00385000
@02      EQU   02                                                       00386000
@03      EQU   03                                                       00387000
@04      EQU   04                                                       00388000
@05      EQU   05                                                       00389000
@06      EQU   06                                                       00390000
@07      EQU   07                                                       00391000
@08      EQU   08                                                       00392000
@09      EQU   09                                                       00393000
@10      EQU   10                                                       00394000
@11      EQU   11                                                       00395000
@12      EQU   12                                                       00396000
@13      EQU   13                                                       00397000
@14      EQU   14                                                       00398000
@15      EQU   15                                                       00399000
SEGMENT  EQU   @04                                                      00400000
J1       EQU   @02                                                      00401000
STEPTR   EQU   @02                                                      00402000
RETC     EQU   @05                                                      00403000
R8       EQU   @08                                                      00404000
R9       EQU   @09                                                      00405000
R0       EQU   @00                                                      00406000
R1       EQU   @01                                                      00407000
R2       EQU   @02                                                      00408000
R3       EQU   @03                                                      00409000
R4       EQU   @04                                                      00410000
R5       EQU   @05                                                      00411000
RA       EQU   @10                                                      00412000
RB       EQU   @11                                                      00413000
RD       EQU   @13                                                      00414000
RE       EQU   @14                                                      00415000
RF       EQU   @15                                                      00416000
RC       EQU   @12                                                      00417000
R6       EQU   @06                                                      00418000
R7       EQU   @07                                                      00419000
CMD      EQU   0                                                        00493000
CMDT     EQU   CMD+4                                                    00494000
PSCB     EQU   0                                                        00495000
PSCBATR1 EQU   PSCB+16                                                  00496000
ECT      EQU   0                                                        00497000
ECTSWS   EQU   ECT+28                                                   00498000
ECTSWS2  EQU   ECT+40                                                   00499000
ECTSWS21 EQU   ECTSWS2                                                  00500000
UPT      EQU   0                                                        00501000
UPTSWS   EQU   UPT+12                                                   00502000
SA       EQU   0                                                        00503000
SA1      EQU   SA                                                       00504000
SAR      EQU   SA+12                                                    00505000
SAR1     EQU   SAR+12                                                   00506000
SGTSTE   EQU   0                                                        00608000
SGTLK    EQU   SGTSTE                                                   00609000
SGTPTL   EQU   SGTLK                                                    00610000
SGTPTO   EQU   SGTSTE+1                                                 00611000
SGTBYTE  EQU   SGTPTO+2                                                 00612000
SGTPAM   EQU   SGTBYTE                                                  00613000
IKJEFF02 EQU   0                                                        00710000
IKJEFF18 EQU   0                                                        00711000
IKJEFF19 EQU   0                                                        00712000
IKJGETL  EQU   0                                                        00713000
IKJPARS  EQU   0                                                        00714000
IKJPTGT  EQU   0                                                        00715000
IKJPUTL  EQU   0                                                        00716000
IKJSCAN  EQU   0                                                        00717000
IKJSTCK  EQU   0                                                        00718000
I001C    EQU   0                                                        00719000
I008P    EQU   0                                                        00720000
I015F    EQU   0                                                        00721000
I015P    EQU   0                                                        00722000
I031F    EQU   0                                                        00723000
I031P    EQU   0                                                        00724000
I256C    EQU   0                                                        00725000
SGTEND   EQU   0                                                        00726000
PZ2      EQU   0                                                        00727000
ESAU     EQU   VSAMBUFR                                                 00738000
ESAUSYM  EQU   ESAU+28                                                  00739000
ESAUAS   EQU   ESAU+60                                                  00740000
ESAUAST  EQU   ESAUAS                                                   00741000
ESAUD    EQU   ESAU+80                                                  00742000
ESAUDOF  EQU   ESAUD                                                    00743000
ESAUDT   EQU   ESAUD+10                                                 00744000
ESAUDIL  EQU   ESAUD+48                                                 00745000
ESAUDF   EQU   ESAUD+52                                                 00746000
ESAUF    EQU   ESAU+161                                                 00747000
ESAUFS   EQU   ESAUF                                                    00748000
ESAUFC   EQU   ESAUF+1                                                  00749000
ESAUR    EQU   ESAU+180                                                 00750000
ESAURT   EQU   ESAUR+2                                                  00751000
SAAU     EQU   VSAMBUFR                                                 00752000
SAAUAS   EQU   SAAU+12                                                  00753000
SAAUDT   EQU   SAAU+32                                                  00754000
SAAUF    EQU   SAAU+68                                                  00755000
SAAUFT   EQU   SAAUF+10                                                 00756000
SAAUFF   EQU   SAAUF+52                                                 00757000
SAAUSF   EQU   SAAU+128                                                 00758000
SAAUSRC  EQU   SAAU+152                                                 00759000
SAAUC    EQU   SAAU+254                                                 00760000
SAAUCT   EQU   SAAUC+2                                                  00761000
CPPL     EQU   ZZ2CPPL                                                  00762000
CPPLUPT  EQU   CPPL+4                                                   00763000
CPPLPSCB EQU   CPPL+8                                                   00764000
CPPLECT  EQU   CPPL+12                                                  00765000
RMKB     EQU   ESBAR                                                    00766000
RMKBT    EQU   RMKB+2                                                   00767000
SYMA     EQU   ESAUSYM                                                  00768000
SYMAA    EQU   SYMA                                                     00769000
SYMAC    EQU   SYMA+6                                                   00770000
SYMB     EQU   ESBASYM                                                  00771000
SYMBA    EQU   SYMB                                                     00772000
SYMBB    EQU   SYMB+3                                                   00773000
SYMBC    EQU   SYMB+6                                                   00774000
@ENDDATA EQU   *                                                        01397000
         END   BLSSPGTE                                         DSKC098 01398000
