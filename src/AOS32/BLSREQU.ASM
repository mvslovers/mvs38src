EQU      TITLE 'BLSREQU--IPCS EQUATE SUBCOMMAND                        *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPGW                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSREQU  CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(22)                                          DSKC058 00010000
         DC    C'BLSREQU 79331 UZ28623 '                        DSKC058 00011000
         DROP  @15                                                      00012000
@PROLOG  STM   @14,@12,12(@13)                                     0002 00013000
         BALR  @12,0                                               0002 00014000
@PSTART  DS    0H                                                  0002 00015000
         USING @PSTART,@12                                         0002 00016000
         L     @00,@SIZDATD                                        0002 00017000
         BLSUALLR R,LV=(0)                                              00018000
         LR    @11,@01                                             0002 00019000
         USING @DATD,@11                                           0002 00020000
         ST    @13,@SA00001+4                                      0002 00021000
         LM    @00,@01,20(@13)                                     0002 00022000
         ST    @11,8(,@13)                                         0002 00023000
         LR    @13,@11                                             0002 00024000
*BLREXTRN - IDENTIFY EXTERNAL REFERENCES                                00025000
         EXTRN BLSRVPAD                                                 00026000
         EXTRN BLSUVP31                                                 00027000
         EXTRN BLSUVP32                                                 00028000
         EXTRN BLSRVPCP                                                 00029000
         EXTRN BLSRVPAS                                                 00030000
*   RETC=0;                         /* RETURN CODE                   */ 00031000
*                                                                  0241 00033000
*   /*****************************************************************/ 00034000
*   /*                                                               */ 00035000
*   /* CALL IKJPARS AND EXAMINE OPERANDS                             */ 00036000
*   /*                                                               */ 00037000
*   /*****************************************************************/ 00038000
*                                                                  0241 00039000
*   DO;                             /* BLSRPARS MF(EXECUTE,PX)       */ 00040000
*     DO;                           /* BLSRPARD CSECT()DSECT(PD)EQUAT   00041000
*                                      E(ESAU)EXIT(EXITRLSA,)MF(EXECU   00042000
*                                      TE,PX)                        */ 00043000
*       DO;                         /* BLSUPARS CSECT(PC)DSECT(PD)EXI   00044000
*                                      T(EXITRLSA,)MF(EXECUTE,PX)    */ 00045000
*         CALL BLSUPARI(ZZ2,PCCSECT,PDAPTR);/* PARSE OPERANDS        */ 00046000
         ST    R9,@AL00001                                         0244 00047000
         L     @08,PCPTR                                        DSKC058 00048000
         ST    @08,@AL00001+4                                   DSKC058 00049000
         LA    @10,PDAPTR                                       DSKC058 00050000
         ST    @10,@AL00001+8                                   DSKC058 00051000
         L     @04,ZZ2BVTP(,R9)                                 DSKC058 00052000
         SLR   RETC,RETC                                        DSKC058 00052010
         L     @15,BVTPARIP(,@04)                               DSKC058 00053000
         LA    @01,@AL00001                                        0244 00054000
         BALR  @14,@15                                             0244 00055000
*         RESPECIFY                                                0245 00056000
*          (GPR15F) RESTRICTED;                                    0245 00057000
*         IF GPR15F^=ZZZFLAGI THEN                                 0246 00058000
*                                                                  0246 00059000
         LTR   GPR15F,GPR15F                                       0246 00060000
         BZ    @RF00246                                            0246 00061000
*           /*********************************************************/ 00062000
*           /*                                                       */ 00063000
*           /* UNABLE TO PARSE                                       */ 00064000
*           /*                                                       */ 00065000
*           /*********************************************************/ 00066000
*                                                                  0247 00067000
*           DO;                     /* UNABLE TO PARSE               */ 00068000
*             RETC=GPR15F;          /* RETURN CODE                   */ 00069000
         LR    RETC,GPR15F                                         0248 00070000
*             GO TO EXITNORL;       /* EXIT WITHOUT PDL              */ 00071000
         B     EXITNORL                                            0249 00072000
*           END;                                                   0250 00073000
*         RESPECIFY                                                0251 00074000
*          (GPR15F) UNRESTRICTED;                                  0251 00075000
@RF00246 DS    0H                                                  0252 00076000
*         RESPECIFY                                                0252 00077000
*          (PDRPTR) RESTRICTED;                                    0252 00078000
*         PDRPTR=PDAPTR;            /* ->PDL                         */ 00079000
         L     PDRPTR,PDAPTR                                       0253 00080000
*         GENERATE REFS(PD,PDRPTR) CODE(USING PD,PDRPTR);          0254 00081000
         USING PD,PDRPTR                                                00082000
*         IF PXTEST=PXTEST1 THEN                                   0255 00083000
         CLC   PXTEST(2),@CH00043                                  0255 00084000
         BNE   @RF00255                                            0255 00085000
*           ZZ2AFX=ZZZ1;            /* TEST                          */ 00086000
         OI    ZZ2AFX(R9),B'10000000'                              0256 00087000
*         ELSE                                                     0257 00088000
*           IF PXTEST=PXTEST0 THEN                                 0257 00089000
         B     @RC00255                                            0257 00090000
@RF00255 CLC   PXTEST(2),@CH00068                                  0257 00091000
         BNE   @RF00257                                            0257 00092000
*             ZZ2AFX=ZZZ0;          /* NOTEST                        */ 00093000
         NI    ZZ2AFX(R9),B'01111111'                              0258 00094000
*       END;                        /* BLSUPARS CSECT(PC)DSECT(PD)EXI   00095000
*                                      T(EXITRLSA,)MF(EXECUTE,PX)    */ 00096000
@RF00257 DS    0H                                                  0259 00097000
@RC00255 DS    0H                                                  0260 00098000
*     END;                          /* BLSRPARD CSECT()DSECT(PD)EQUAT   00099000
*                                      E(ESAU)EXIT(EXITRLSA,)MF(EXECU   00100000
*                                      TE,PX)                        */ 00101000
*   END;                            /* BLSRPARS MF(EXECUTE,PX)       */ 00102000
*                                                                  0262 00103000
*   /*****************************************************************/ 00104000
*   /*                                                               */ 00105000
*   /* RESOLVE ADDRESS AND UPDATE SYMBOL TABLE                       */ 00106000
*   /*                                                               */ 00107000
*   /*****************************************************************/ 00108000
*                                                                  0262 00109000
*   CALL BLSRADDR(ZZ2,ESAU,PD,PXAO,PDAD);/* RESOLVE ADDRESS          */ 00110000
         ST    R9,@AL00001                                         0262 00111000
         LA    @14,ESAU                                            0262 00112000
         ST    @14,@AL00001+4                                      0262 00113000
         LA    @04,PD                                           DSKC058 00114000
         ST    @04,@AL00001+8                                   DSKC058 00115000
         LA    @08,PXAO-2                                       DSKC058 00116000
         ST    @08,@AL00001+12                                  DSKC058 00117000
         LA    @14,PDAD                                            0262 00118000
         ST    @14,@AL00001+16                                     0262 00119000
         L     @04,ZZ2RVTP(,R9)                                 DSKC058 00120000
         LA    @01,@AL00001                                     DSKC058 00121000
         L     @15,RVTADDRP(,@04)                               DSKC058 00122000
         BALR  @14,@15                                             0262 00123000
*   RETC=MAX(RETC,RF);              /* RETURN CODE                   */ 00124000
         CR    RETC,RF                                             0263 00125000
         BNL   *+6                                                      00126000
         LR    RETC,RF                                             0263 00127000
*   IF RF>=ZZZFLAGS THEN                                           0264 00128000
         CH    RF,A000190                                       DSKC058 00129000
         BNL   @RT00264                                            0264 00130000
*     GO TO EXITRLSA;               /* EXIT WITH PDL                 */ 00131000
*   ESAUSYM='';                     /* INITIALIZE SYMBOL FIELD       */ 00132000
         MVI   ESAUSYM,C' '                                        0266 00133000
         MVC   ESAUSYM+1(30),ESAUSYM                               0266 00134000
*   ESAUSYM(1:PDSYMIL)=PDSYMI(1:PDSYMIL);/* MOVE SYMBOL TO RECORD    */ 00135000
         LH    @04,PDSYMIL                                      DSKC058 00136000
         BCTR  @04,0                                            DSKC058 00137000
         L     @08,PDSYMIP                                         0267 00138000
         EX    @04,@SM01291                                     DSKC058 00139000
*   IF PKDROP=PNNODROP THEN                                        0268 00140000
         CLC   PKDROP(2),@CH00068                                  0268 00141000
         BNE   @RF00268                                            0268 00142000
*     ESAUFCD='1'B;                 /* NODROP OPTION                 */ 00143000
         OI    ESAUFCD,B'10000000'                                 0269 00144000
*   ELSE                                                           0270 00145000
*     ESAUFCD='0'B;                 /* DROP OPTION OR DEFAULT        */ 00146000
         B     @RC00268                                            0270 00147000
@RF00268 NI    ESAUFCD,B'01111111'                                 0270 00148000
*   CALL BLSRESAR(ZZ2,ESAU);        /* ADD/REPLACE EQUATE SYM. RCD.  */ 00149000
@RC00268 ST    R9,@AL00001                                         0271 00150000
         LA    @14,ESAU                                            0271 00151000
         ST    @14,@AL00001+4                                      0271 00152000
         L     @04,ZZ2RVTP(,R9)                                 DSKC058 00153000
         LA    @01,@AL00001                                     DSKC058 00154000
         L     @15,RVTESARP(,@04)                               DSKC058 00155000
         BALR  @14,@15                                             0271 00156000
*   RETC=MAX(RETC,RF);              /* RETURN CODE                   */ 00157000
         CR    RETC,RF                                             0272 00158000
         BNL   *+6                                                      00159000
         LR    RETC,RF                                             0272 00160000
*                                                                  0273 00161000
*   /*****************************************************************/ 00162000
*   /*                                                               */ 00163000
*   /* PROGRAM EXIT                                                  */ 00164000
*   /*                                                               */ 00165000
*   /*****************************************************************/ 00166000
*                                                                  0273 00167000
*EXITRLSA:                                                         0273 00168000
*   DO WHILE(PDAPTR^=0);            /* BLRRLSA MF(E,PD)              */ 00169000
EXITRLSA B     @DE00273                                            0273 00170000
@DL00273 DS    0H                                                  0274 00171000
*     PDRPTR=PDAPTR;                                               0274 00172000
         L     PDRPTR,PDAPTR                                       0274 00173000
*     PDAPTR=PDXP;                                                 0275 00174000
         SLR   @14,@14                                          DSKC058 00175000
         ICM   @14,7,PDXP(PDRPTR)                               DSKC058 00176000
         ST    @14,PDAPTR                                          0275 00177000
*     DO;                           /* FREEMAIN(R)                 0276 00178000
*                                      LV(PDL)SP(1)A(PDDSECT)        */ 00179000
*       RESPECIFY                                                  0277 00180000
*        (GPR01F,                                                  0277 00181000
*         GPR00F) RESTRICTED;                                      0277 00182000
*       GPR00F=PDL;                 /* LENGTH REQUESTED              */ 00183000
         SLR   @00,@00                                          DSKC058 00184000
         ICM   @00,7,PDL(PDRPTR)                                DSKC058 00185000
*       GPR01F=1;                   /* SP IN REG 1                   */ 00186000
         LA    GPR01F,1                                            0279 00187000
*       GEN(SLL   GPR01F,24)                                       0280 00188000
*       NODEFS NOREFS NOSETS NOEXIT NOFLOWS SEQFLOW;               0280 00189000
         SLL   GPR01F,24                                                00190000
*       GPR00F=GPR00F×GPR01F;       /* SP IN HI BYTE                 */ 00191000
         OR    GPR00F,GPR01F                                       0281 00192000
*       GPR01F=ADDR(PDDSECT);       /* SET REGISTER ONE              */ 00193000
         LR    GPR01F,PDRPTR                                       0282 00194000
*       SVC(10);                    /* R-FORM OF GETMAIN             */ 00195000
         SVC   10                                                  0283 00196000
*       RESPECIFY                                                  0284 00197000
*        (GPR01F,                                                  0284 00198000
*         GPR00F) UNRESTRICTED;                                    0284 00199000
*     END;                          /* FREEMAIN(R)                 0285 00200000
*                                      LV(PDL)SP(1)A(PDDSECT)        */ 00201000
*   END;                            /* BLRRLSA MF(E,PD)              */ 00202000
@DE00273 ICM   @04,15,PDAPTR                                    DSKC058 00203000
         BNZ   @DL00273                                            0286 00205000
*EXITNORL:                          /* EXIT WITH NO PDL              */ 00206000
*   RETURN CODE(RETC);              /* MODULE EXIT                   */ 00207000
EXITNORL L     @13,4(,@13)                                         0287 00208000
         L     @00,@SIZDATD                                        0287 00209000
         LR    @01,@11                                             0287 00210000
         BLSUFRER R,LV=(0),A=(1)                                        00211000
         LR    @15,@05                                             0287 00212000
         L     @14,12(,@13)                                        0287 00213000
         LM    @00,@12,20(@13)                                     0287 00214000
         BR    @14                                                 0287 00215000
*                                                                  0288 00216000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00217000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00218000
*                                                                  0288 00219000
*   DECLARE                         /* GENERAL PURPOSE REGISTERS     */ 00220000
*     GPR00F FIXED(31) REG(0),                                     0288 00221000
*     GPR01F FIXED(31) REG(1),                                     0288 00222000
*     GPR15F FIXED(31) REG(15);                                    0288 00223000
*   DECLARE                         /* COMMON VARIABLES              */ 00224000
*     I256C CHAR(256) BASED,                                       0289 00225000
*     I031F FIXED(31) BASED,                                       0289 00226000
*     I031P PTR(31) BASED,                                         0289 00227000
*     I015F FIXED(15) BASED,                                       0289 00228000
*     I015P PTR(15) BASED,                                         0289 00229000
*     I008P PTR(8) BASED,                                          0289 00230000
*     I001C CHAR(1) BASED;                                         0289 00231000
*   GENERATE NODEFS NOREFS DATA;                                   0290 00232000
*   END BLSREQU                     /* BLRPEND(BLSREQU)              */ 00233000
*                                                                  0291 00234000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00235000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00236000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00237000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00238000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00239000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00240000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00241000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00242000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00243000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00244000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00245000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00246000
*                                                                  0291 00247000
*       ;                                                          0291 00248000
@EL00001 L     @13,4(,@13)                                         0291 00249000
@EF00001 L     @00,@SIZDATD                                        0291 00250000
         LR    @01,@11                                             0291 00251000
         BLSUFRER R,LV=(0),A=(1)                                        00252000
@ER00001 LM    @14,@12,12(@13)                                     0291 00253000
         BR    @14                                                 0291 00254000
@DATA    DS    0H                                                       00255000
@CH00043 DC    H'1'                                                     00256000
@CH00068 DC    H'2'                                                     00257000
A000190  DC    H'12'                                            DSKC058 00257010
@SM01291 MVC   ESAUSYM(0),PDSYMI(@08)                                   00258000
@DATD    DSECT                                                          00259000
         DS    0F                                                       00260000
@SA00001 DS    18F                                                      00261000
@AL00001 DS    5A                                                       00262000
BLSREQU  CSECT                                                          00263000
         DS    0F                                                       00264000
@DATD    DSECT                                                          00266000
         DS    0D                                                       00267000
PDAPTR   DS    A                                                        00268000
         DS    CL4                                                      00269000
ESAU     DS    CL694                                                    00270000
         ORG   ESAU                                                     00271000
ESAURID  DS    CL2                                                      00272000
@NM00089 DS    BL6                                                      00273000
@NM00090 DS    CL8                                                      00274000
@NM00091 DS    BL8                                                      00275000
ESAURDX  DS    FL4                                                      00276000
ESAUSYM  DS    CL31                                                     00277000
ESAUELK  DS    0C                                                       00278000
ESAURV1  DS    CL1                                                      00279000
ESAUAS   DS    CL16                                                     00280000
         ORG   ESAUAS                                                   00281000
ESAUAS0  DS    0C                                                       00282000
ESAUAST  DS    CL2                                                      00283000
@NM00092 DS    BL2                                                      00284000
ESAUAS1  DS    FL4                                                      00285000
ESAUAS2  DS    FL4                                                      00286000
@NM00093 DS    BL4                                                      00287000
ESAUAS9  DS    0C                                                       00288000
         ORG   ESAU+76                                                  00289000
ESAULAD  DS    AL4                                                      00290000
ESAUD    DS    CL60                                                     00291000
         ORG   ESAUD                                                    00292000
ESAUD00  DS    0C                                                       00293000
ESAUDOF  DS    FL4                                                      00294000
ESAUDLE  DS    FL4                                                      00295000
ESAUDOB  DS    FL1                                                      00296000
ESAUDLB  DS    FL1                                                      00297000
ESAUDT   DS    CL34                                                     00298000
         ORG   ESAUDT                                                   00299000
ESAUDT0  DS    0C                                                       00300000
ESAUDTY  DS    CL1                                                      00301000
@NM00094 DS    BL1                                                      00302000
ESAUDTD  DS    CL31                                                     00303000
ESAUDTE  DS    CL1                                                      00304000
ESAUDT9  DS    0C                                                       00305000
         ORG   ESAUD+44                                                 00306000
ESAUDIM  DS    FL4                                                      00307000
ESAUDIL  DS    FL4                                                      00308000
ESAUDF   DS    BL4                                                      00309000
         ORG   ESAUDF                                                   00310000
ESAUDFA  DS    BL1                                                      00311000
@NM00095 EQU   ESAUDF+0                                                 00312000
         ORG   ESAUD+56                                                 00313000
@NM00096 DS    BL4                                                      00314000
ESAUD99  DS    0C                                                       00315000
         ORG   ESAU+140                                                 00316000
ESAUMAD  DS    AL4                                                      00317000
@NM00097 DS    BL16                                                     00318000
ESAUKEY  DS    BL1                                                      00319000
ESAUF    DS    BL3                                                      00320000
         ORG   ESAUF                                                    00321000
ESAUFS   DS    BL1                                                      00322000
         ORG   ESAUFS                                                   00323000
ESAUFSC  DS    BL1                                                      00324000
ESAUFS2  EQU   ESAUFS+0                                                 00325000
ESAUFSM  EQU   ESAUFS+0                                                 00326000
ESAUFSA  EQU   ESAUFS+0                                                 00327000
ESAUFSP  EQU   ESAUFS+0                                                 00328000
ESAUFSR  EQU   ESAUFS+0                                                 00329000
ESAUFSX  EQU   ESAUFS+0                                                 00330000
ESAUFSS  EQU   ESAUFS+0                                                 00331000
         ORG   ESAUF+1                                                  00332000
ESAUFC   DS    BL1                                                      00333000
         ORG   ESAUFC                                                   00334000
ESAUFCD  DS    BL1                                                      00335000
@NM00098 EQU   ESAUFC+0                                                 00336000
         ORG   ESAUF+2                                                  00337000
@NM00099 DS    BL1                                                      00338000
         ORG   ESAU+164                                                 00339000
ESAUABS  DS    FL4                                                      00340000
@NM00100 DS    BL12                                                     00341000
ESAUR    DS    CL514                                                    00342000
         ORG   ESAUR                                                    00343000
ESAURL   DS    FL2                                                      00344000
ESAURT   DS    CL512                                                    00345000
         ORG   ESAURT                                                   00346000
ESAURT1  DS    CL512                                                    00347000
         ORG   ESAU+694                                                 00348000
ESAU999  DS    0C                                                       00349000
         ORG   ESAU+694                                                 00350000
BLSREQU  CSECT                                                          00351000
         DS    0F                                                       00352000
@SIZDATD DC    AL1(0)                                                   00353000
         DC    AL3(@ENDDATD-@DATD)                                      00354000
         DC    X'40404040'                   !!! SOURCE COMPARE FIX !!! 00355000
         DC    0D'0'                                            DSKC058 00355000
PCPTR    DC    AL4(PC)                                                  00356000
@CB01293 DC    X'00'                                                    00357000
PXAO     DC    0H'0'                                            DSKC058 00359000
         DC    AL2(PXA1-PD)                                             00360000
         DC    AL2(PXA2-PD)                                             00361000
         DC    AL2(0)                                                   00362000
         DC    AL2(0)                                                   00363000
         DC    AL2(PXCPU-PD)                                            00364000
         DC    AL2(0)                                                   00365000
         DC    AL2(PXASI-PD)                                            00366000
         DC    AL2(0)                                                   00367000
         DC    AL2(0)                                                   00368000
         DC    AL2(PXDTYPE-PD)                                          00369000
         DC    AL2(0)                                                   00370000
         DC    AL2(PXLENGTH-PD)                                         00371000
         DC    AL2(PXMULT-PD)                                           00372000
         DC    AL2(PXRMK-PD)                                            00373000
         DC    AL2(PXDTD-PD)                                            00374000
         DC    AL2(PXLEN-PD)                                            00375000
         DC    AL2(PXDIM-PD)                                            00376000
         DC    AL2(PXREM-PD)                                            00377000
         DC    AL2(PXNTRY-PD)                                           00378000
         DC    AL2(PXNTR-PD)                                            00379000
@DATD    DSECT                                                          00380000
         SPACE 2                                                        00381000
*********************************************************************** 00382000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00383000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00384000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00385000
*********************************************************************** 00386000
         SPACE                                                          00387000
BLSREQU  CSECT                                                          00388000
         ORG                                                            00389000
         DS    0D                                                       00390000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSREQU+19)/20+7)/8)CL8'BLSREQU'       00391000
@DATD    DSECT                                                          00392000
         DS    0H                                                       00393000
@DATD    DSECT                                                          00394000
         SPACE 2                                                        00395000
*********************************************************************** 00396000
* IKJPARM--BEGIN MACROS SPECIFYING COMMAND SYNTAX                     * 00397000
*********************************************************************** 00398000
         SPACE                                                          00399000
BLSREQU  CSECT                                                          00400000
PC       IKJPARM DSECT=PD                                               00401000
PDSYM    IKJIDENT 'SYMBOL',DEFAULT='X',FIRST=ALPHA,MAXLNTH=31,OTHER=ALP*00404000
               HANUM                                                    00405000
PDAD     IKJPOSIT ADDRESS,,RANGE,DEFAULT='X',VALIDCK=BLSRVPAD           00408000
PKDROP   IKJKEYWD                                                       00411000
         IKJNAME 'DROP'                                                 00414000
         IKJNAME 'NODROP'                                               00417000
PXA1     IKJKEYWD                                                       00420000
         IKJNAME 'ABSOLUTE'                                             00423000
         IKJNAME 'CPU',SUBFLD=PXSUBFB                                   00426000
         IKJNAME 'HEADER'                                               00429000
         IKJNAME 'NOCPU'                                        DSKC058 00429010
PXA2     IKJKEYWD                                                       00432000
         IKJNAME 'ASID',SUBFLD=PXSUBFE                                  00435000
         IKJNAME 'REAL'                                                 00438000
         IKJNAME 'STATUS'                                               00441000
PXDTYPE  IKJKEYWD                                                       00444000
         IKJNAME 'AREA',SUBFLD=PXSUBFG                                  00447000
         IKJNAME 'B',ALIAS=('BIT','HEXADECIMAL','X')                    00450000
         IKJNAME 'C',ALIAS=('CHARACTER')                                00453000
         IKJNAME 'MODULE',SUBFLD=PXSUBFG                                00456000
         IKJNAME 'POINTER',ALIAS=('PTR')                                00459000
         IKJNAME 'F',ALIAS=('SIGNED')                                   00462000
         IKJNAME 'STRUCTURE',SUBFLD=PXSUBFG                             00465000
         IKJNAME 'UNSIGNED'                                             00468000
PXLENGTH IKJKEYWD                                                       00471000
         IKJNAME 'LENGTH',SUBFLD=PXSUBFL                                00474000
PXMULT   IKJKEYWD                                                       00477000
         IKJNAME 'DIMENSION',ALIAS=('MULTIPLE'),SUBFLD=PXSUBFI          00480000
         IKJNAME 'SCALAR'                                               00483000
PXNTRY   IKJKEYWD                                                       00486000
         IKJNAME 'ENTRY',ALIAS=('ENTRIES'),SUBFLD=PXSUBFN               00489000
PXRMK    IKJKEYWD                                                       00492000
         IKJNAME 'REMARK',SUBFLD=PXSUBFJ                                00495000
         IKJNAME 'NOREMARK'                                             00498000
PXTEST   IKJKEYWD                                                       00501000
         IKJNAME 'TEST'                                                 00504000
         IKJNAME 'NOTEST'                                               00507000
PXSUBFG  IKJSUBF                                                        00511000
PXDTD    IKJIDENT 'DATA NAME',FIRST=ALPHA,MAXLNTH=31,OTHER=ALPHANUM     00514000
PXSUBFL  IKJSUBF                                                        00518000
PXLEN    IKJIDENT 'LENGTH',INTEG,PROMPT='LENGTH',VALIDCK=BLSUVP31       00521000
PXSUBFI  IKJSUBF                                                        00525000
PXDIM    IKJIDENT 'DIMENSION',INTEG,PROMPT='DIMENSION',VALIDCK=BLSUVP31 00528000
PXSUBFN  IKJSUBF                                                        00532000
PXNTR    IKJIDENT 'ENTRY(IES)',INTEG,RANGE,PROMPT='ENTRY(IES)',VALIDCK=*00535000
               BLSUVP32                                                 00536000
PXSUBFJ  IKJSUBF                                                        00540000
PXREM    IKJPOSIT QSTRING,PROMPT='REMARK'                               00543000
PXSUBFB  IKJSUBF                                                        00547000
PXCPU    IKJIDENT 'CPU ADDRESS',INTEG,PROMPT='CPU ADDRESS',VALIDCK=BLSR*00550000
               VPCP                                                     00551000
PXSUBFE  IKJSUBF                                                        00555000
PXASI    IKJIDENT 'ASID',INTEG,PROMPT='ASID',VALIDCK=BLSRVPAS           00558000
         IKJENDP                                                        00563000
         SPACE 2                                                        00564000
*********************************************************************** 00565000
* IKJENDP--END SYNTAX DESCRIPTION                                     * 00566000
*********************************************************************** 00567000
         SPACE                                                          00568000
@DATD    DSECT                                                          00569000
         SPACE 2                                                        00570000
*********************************************************************** 00571000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00572000
*********************************************************************** 00573000
         SPACE                                                          00574000
         DS    0D                                                       00575000
@DATD    DSECT                                                          00576000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00577000
@ENDDATD EQU   *                                                        00578000
BLSREQU  CSECT                                                          00579000
         BLSBVT  ,                                              DSKC058 00579010
         BLSRVT  ,                                              DSKC058 00579020
         BLSZZ1  ,                                              DSKC058 00579030
         BLSZZ2  ,                                              DSKC058 00579040
         BLSZZ6  ,                                              DSKC058 00579050
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00580000
@01      EQU   01                                                       00581000
@02      EQU   02                                                       00582000
@03      EQU   03                                                       00583000
@04      EQU   04                                                       00584000
@05      EQU   05                                                       00585000
@06      EQU   06                                                       00586000
@07      EQU   07                                                       00587000
@08      EQU   08                                                       00588000
@09      EQU   09                                                       00589000
@10      EQU   10                                                       00590000
@11      EQU   11                                                       00591000
@12      EQU   12                                                       00592000
@13      EQU   13                                                       00593000
@14      EQU   14                                                       00594000
@15      EQU   15                                                       00595000
RETC     EQU   @05                                                      00596000
R9       EQU   @09                                                      00597000
R0       EQU   @00                                                      00598000
R1       EQU   @01                                                      00599000
R2       EQU   @02                                                      00600000
R3       EQU   @03                                                      00601000
R4       EQU   @04                                                      00602000
R5       EQU   @05                                                      00603000
RB       EQU   @11                                                      00604000
RD       EQU   @13                                                      00605000
RE       EQU   @14                                                      00606000
RF       EQU   @15                                                      00607000
PDRPTR   EQU   @10                                                      00608000
GPR15F   EQU   @15                                                      00609000
GPR01F   EQU   @01                                                      00610000
GPR00F   EQU   @00                                                      00611000
RA       EQU   @10                                                      00612000
RC       EQU   @12                                                      00613000
R6       EQU   @06                                                      00614000
R7       EQU   @07                                                      00615000
R8       EQU   @08                                                      00616000
CMD      EQU   0                                                        00677000
CMDT     EQU   CMD+4                                                    00678000
PSCB     EQU   0                                                        00679000
PSCBATR1 EQU   PSCB+16                                                  00680000
ECT      EQU   0                                                        00681000
ECTSWS   EQU   ECT+28                                                   00682000
ECTSWS2  EQU   ECT+40                                                   00683000
ECTSWS21 EQU   ECTSWS2                                                  00684000
UPT      EQU   0                                                        00685000
UPTSWS   EQU   UPT+12                                                   00686000
SA       EQU   0                                                        00687000
SA1      EQU   SA                                                       00688000
SAR      EQU   SA+12                                                    00689000
SAR1     EQU   SAR+12                                                   00690000
PCCSECT  EQU   0                                                        00791000
PDDSECT  EQU   0                                                        00792000
PDXP     EQU   PDDSECT+1                                                00793000
PDL      EQU   PDDSECT+5                                                00794000
PDSYMI   EQU   0                                                        00795000
PDADAE   EQU   0                                                        00796000
PDADAEAP EQU   PDADAE                                                   00797000
PDADAEF  EQU   PDADAE+8                                                 00798000
IKJEFF02 EQU   0                                                        00895000
IKJEFF18 EQU   0                                                        00896000
IKJEFF19 EQU   0                                                        00897000
IKJGETL  EQU   0                                                        00898000
IKJPARS  EQU   0                                                        00899000
IKJPTGT  EQU   0                                                        00900000
IKJPUTL  EQU   0                                                        00901000
IKJSCAN  EQU   0                                                        00902000
IKJSTCK  EQU   0                                                        00903000
I001C    EQU   0                                                        00904000
I008P    EQU   0                                                        00905000
I015F    EQU   0                                                        00906000
I015P    EQU   0                                                        00907000
I031F    EQU   0                                                        00908000
I031P    EQU   0                                                        00909000
I256C    EQU   0                                                        00910000
PDADAEA  EQU   0                                                        00911000
PDADA1   EQU   0                                                        00912000
PDADA2   EQU   0                                                        00913000
PDADE1   EQU   0                                                        00914000
PDADE2   EQU   0                                                        00915000
PDADM1   EQU   0                                                        00916000
PDADM2   EQU   0                                                        00917000
PXASII   EQU   0                                                        00918000
PXCPUI   EQU   0                                                        00919000
PXDIMI   EQU   0                                                        00920000
PXDTDI   EQU   0                                                        00921000
PXLENI   EQU   0                                                        00922000
PXNTRI1  EQU   0                                                        00923000
PXNTRI2  EQU   0                                                        00924000
PXREMQ   EQU   0                                                        00925000
PDSYMIP  EQU   PDSYM                                                    00926000
PDSYMIL  EQU   PDSYM+4                                                  00927000
PDSYMIF  EQU   PDSYM+6                                                  00928000
@NM00080 EQU   PDAD                                                     00929000
PDADMP   EQU   @NM00080                                                 00930000
PDADMF   EQU   @NM00080+6                                               00931000
PDADEP   EQU   @NM00080+8                                               00932000
PDADEF   EQU   @NM00080+14                                              00933000
PDADAP   EQU   @NM00080+16                                              00934000
PDADAF   EQU   @NM00080+22                                              00935000
PDADAT   EQU   @NM00080+24                                              00936000
PDADAEP  EQU   @NM00080+28                                              00937000
PXCPUIP  EQU   PXCPU                                                    00938000
PXCPUIF  EQU   PXCPU+6                                                  00939000
PXASIIP  EQU   PXASI                                                    00940000
PXASIIF  EQU   PXASI+6                                                  00941000
PXDTDIP  EQU   PXDTD                                                    00942000
PXDTDIF  EQU   PXDTD+6                                                  00943000
PXLENIP  EQU   PXLEN                                                    00944000
PXLENIF  EQU   PXLEN+6                                                  00945000
PXDIMIP  EQU   PXDIM                                                    00946000
PXDIMIF  EQU   PXDIM+6                                                  00947000
PXREMQP  EQU   PXREM                                                    00948000
PXREMQF  EQU   PXREM+6                                                  00949000
@NM00107 EQU   PXNTR                                                    00950000
PXNTRIP  EQU   @NM00107                                                 00951000
PXNTRIF  EQU   @NM00107+6                                               00952000
CPPL     EQU   ZZ2CPPL                                                  00953000
CPPLUPT  EQU   CPPL+4                                                   00954000
CPPLPSCB EQU   CPPL+8                                                   00955000
CPPLECT  EQU   CPPL+12                                                  00956000
@RT00264 EQU   EXITRLSA                                                 01506000
@ENDDATA EQU   *                                                        01507000
         END   BLSREQU                                          DSKC058 01508000
