         TITLE 'ISTZFMAA - VS/2 LOCAL ATTENTION HANDLER                *00001000
                        '                                               00002000
ISTZFMAA CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK1132 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'ISTZFMAA  81.236'                              DSK1132 00008000
         DROP  R15                                              DSK1132 00009000
@PROLOG  BALR  R12,0                                            DSK1132 00010000
@PSTART  DS    0H                                                  0001 00011000
         USING @PSTART,R12                                      DSK1132 00012000
* * * * * * * * * * * * * * * * *                                       00013000
* GENERATED CODE TO ENSURE THAT *                                       00014000
* THE COMMON ENTRY POINT IS     *                                       00015000
* IDENTIFIED                    *                                       00016000
ISTZFMAA CSECT                  *                                       00017000
         ENTRY ISTZFCAA         *                                       00018000
ISTZFCAA EQU   ISTZFMAA         *                                       00019000
* * * * * * * * * * * * * * * * *                                       00020000
*   REGIOSB=REG1;                   /* GET IOSB ADDRESS              */ 00021000
         LR    R7,R1                                            DSK1132 00022000
*/* SAVE REGISTERS IN THE IOSB                                       */ 00023000
*                                                                  0332 00024000
*   GEN SETS(ZATZSAV1,ZATZSAV2) REFS(REG0,REGIOSB,REG15);          0332 00025000
         STM   R2,R5,ZATZSAV1-IOSB(R7)       SAVE REGS 2 - 5    DSK1132 00026000
         STM   R13,R14,ZATZSAV2-IOSB(R7)     SAVE REGS 13 - 14  DSK1132 00027000
*   IF ATCLCPTR=0×                  /* IF VTAM NOT UP        @ZA13659*/ 00028000
*       ATCLCPTR->ATCACTIV='0'B×    /* IF VTAM INACTIVE      @ZA20827*/ 00029000
*       ATCLCPTR->ATCZLFVT=0 THEN   /* IF TPIOS MODULES HAVE NOT BEEN   00030000
*                                      LOADED                @ZA25876*/ 00031000
         L     R14,ATCLCPTR                                     DSK1132 00032000
         SLR   R10,R10                                          DSK1132 00033000
         CR    R14,R10                                          DSK1132 00034000
         BE    @RT00333                                            0333 00035000
         TM    ATCACTIV(R14),B'01000000'                        DSK1132 00036000
         BZ    @RT00333                                            0333 00037000
         C     R10,ATCZLFVT(,R14)                               DSK1132 00038000
         BE    @RT00333                                            0333 00039000
*     ;                                                            0334 00040000
*   ELSE                            /* EXIT, OTHERWISE       @ZA13659*/ 00041000
*     DO;                           /* CONTINUE              @ZA13659*/ 00042000
*/* OBTAIN LDNCB LOCK                                                */ 00043000
*                                                                  0336 00044000
*       DO;                         /* LISATCVT                    0336 00045000
*                                      CVTBASE(PAGEABLE,(ATCVTREG))  */ 00046000
*         ATCVTREG=ATCLCPTR;        /* SET UP ATCVT POINTER          */ 00047000
         L     R2,ATCLCPTR                                      DSK1132 00048000
*       END;                        /* LISATCVT ADDRESS CVT  @Y30APHZ*/ 00049000
*       UCBPTR=IOSUCB;              /* GET THE UCB ADDRESS           */ 00050000
         L     R6,IOSUCB-IOSB(,R7)                              DSK1132 00051000
*/*TPZLOCK  (OBTAIN,(UCBAD,ISTZFMAA(UNLOCK)),K0)   UCBAD             */ 00052000
*                                                                  0340 00053000
*       DO;                                                        0340 00054000
*                                                                  0340 00055000
*/* ATBUILD (ISTZFSAV,ISTZ19SV)                                      */ 00056000
*                                                                  0341 00057000
*/*  VS2 TPIOS FIXED SAVEAREA FORMAT (TPZLOCK) */                  0341 00058000
*DCL  1  ISTZFSAV BDY(WORD) BASED,                                 0341 00059000
*        3   ZSAFSVBC PTR(31),         /* SAVEAREA BACK CHAIN        */ 00060000
*        3   ZSAFSVFC PTR(31),         /* SAVEAREA FORWARD CHAIN     */ 00061000
*        3   ZSAFSVRR PTR(31),         /* RETURN REGISTER            */ 00062000
*        3   ZSAFSVVR (6) PTR(31),    /* VARIABLE REGS (9-14) SVEAREA*/ 00063000
*        3   ZSAFSVR2 PTR(31),        /* REGISTER 2 SAVEAREA         */ 00064000
*        3   ZSAFSV19 PTR(31);        /* ADDRESS OF 19 WORD SAVEAREA */ 00065000
*DCL ZSAFSVVA FIXED(8) CONSTANT(8);  /* DISPLACEMENT TO VARIABLE REGS*/ 00066000
*DCL ZSAFSVSZ FIXED(8) CONSTANT(44); /* LENGTH OF ISTZSAVE           */ 00067000
*/*  VS2 TPIOS 19 WORD FIXED SAVEAREA FORMAT (TPZLOCK) */          0344 00068000
*DCL  1  ISTZ19SV BDY(WORD) BASED,                                 0344 00069000
*        3  ZSAF19FG BIT(8),        /* FLAGS FIELD                  */  00070000
*           5  ZSAFLOCK BIT(1),     /* LOCK OWNERSHIP BIT           */  00071000
*           5  ZSAFRSVS BIT(7),     /* RESERVED                     */  00072000
*        3  ZSAF19RV CHAR(3),       /* RESERVED                     */  00073000
*        3  ZSAF19R1 PTR(31),       /* RPH REGISTER (R1) SAVEAREA   */  00074000
*        3  ZSAF19RD PTR(31),       /* SAVEAREA PTR (R13) SAVEAREA  */  00075000
*        3  ZSAF19IO (16) PTR(31);  /* 16 WORD SIO SAVEAREA         */  00076000
*                                                                  0345 00077000
*/* END OF ATBUILD                                                   */ 00078000
*                                                                  0345 00079000
*         DCL                                                      0345 00080000
*           1 FRWD0008 BDY(WORD) BASED,/* FRR PARM AREA              */ 00081000
*            2 WRD00008 PTR(31),    /* FIRST PARM WORD               */ 00082000
*            2 WRD10008 PTR(31),    /* 2ND PARM WORD                 */ 00083000
*            2 WRDS0008 CHAR(16);   /* OTHER PARM WORDS              */ 00084000
*         DCL                                                      0346 00085000
*           GPR01F FIXED(31) REG(01);                              0346 00086000
*         DCL                                                      0347 00087000
*           GPR01P PTR(31) REG(01);                                0347 00088000
*         DCL                                                      0348 00089000
*           GPR02F FIXED(31) REG(02);                              0348 00090000
*         DCL                                                      0349 00091000
*           GPR02P PTR(31) REG(02);                                0349 00092000
*         DCL                                                      0350 00093000
*           GPR03F FIXED(31) REG(03);                              0350 00094000
*         DCL                                                      0351 00095000
*           GPR03P PTR(31) REG(03);                                0351 00096000
*         DCL                                                      0352 00097000
*           GPR09F FIXED(31) REG(09);                              0352 00098000
*         DCL                                                      0353 00099000
*           GPR09P PTR(31) REG(09);                                0353 00100000
*         DCL                                                      0354 00101000
*           GPR10F FIXED(31) REG(10);                              0354 00102000
*         DCL                                                      0355 00103000
*           GPR10P PTR(31) REG(10);                                0355 00104000
*         DCL                                                      0356 00105000
*           GPR11F FIXED(31) REG(11);                              0356 00106000
*         DCL                                                      0357 00107000
*           GPR11P PTR(31) REG(11);                                0357 00108000
*         DCL                                                      0358 00109000
*           GPR12F FIXED(31) REG(12);                              0358 00110000
*         DCL                                                      0359 00111000
*           GPR12P PTR(31) REG(12);                                0359 00112000
*         DCL                                                      0360 00113000
*           GPR13F FIXED(31) REG(13);                              0360 00114000
*         DCL                                                      0361 00115000
*           GPR13P PTR(31) REG(13);                                0361 00116000
*         DCL                                                      0362 00117000
*           GPR14F FIXED(31) REG(14);                              0362 00118000
*         DCL                                                      0363 00119000
*           GPR14P PTR(31) REG(14);                                0363 00120000
*         DCL                                                      0364 00121000
*           GPR15F FIXED(31) REG(15);                              0364 00122000
*         DCL                                                      0365 00123000
*           GPR15P PTR(31) REG(15);                                0365 00124000
*         RFY                                                      0366 00125000
*          (GPR01P,                                                0366 00126000
*           GPR02P,                                                0366 00127000
*           GPR03P,                                                0366 00128000
*           GPR09P,                                                0366 00129000
*           GPR10P,                                                0366 00130000
*           GPR11P,                                                0366 00131000
*           GPR12P,                                                0366 00132000
*           GPR13P,                                                0366 00133000
*           GPR14P,                                                0366 00134000
*           GPR15P) RSTD;                                          0366 00135000
*         GPR15P=PSACPUPA;          /* GET CPU ADDRESS               */ 00136000
         LH    R15,PSACPUPA-PSA                                 DSK1132 00137000
*         SLL(GPR15P,2);            /* ADJUST FOR ADDRESSING         */ 00138000
         SLL   R15,2                                            DSK1132 00139000
*         GEN(L GPR15P,ATCTPCP0(GPR15P,GPR02P))                    0369 00140000
*         REFS(GPR02P,GPR15P,ATCTPCP0);/* DETERMINE PROPER SAVEAREA  */ 00141000
         L     R15,ATCAOSM+672(R15,R2)                          DSK1132 00142010
*         GEN SETS(ZSAFSVVR)(STM   9,14,ZSAFSVVR+0(15));/* SAVE REGS */ 00143000
         STM   R9,R14,ZSAFSVVR+0(R15)                           DSK1132 00144000
*         GPR09P=GPR15P;            /* SAVE SAVEAREA PTR ACROSS    0371 00145000
*                                      MACROS                        */ 00146000
         LR    R9,R15                                           DSK1132 00147000
*         GPR10P=GPR02P->ATCZR01;   /* GET FRR RTN ADDRESS           */ 00148000
         L     R10,ATCZR01(,R2)                                 DSK1132 00149000
*         GPR11P=ADDR(UCBLOCK);                                    0373 00150000
         LR    R11,R6                                           DSK1132 00151000
         AL    R11,@CF03687                                     DSK1132 00152000
*         GPR09P->ZSAFSV19->ZSAFLOCK='1'B;/* SET OWNERSHIP FLAG      */ 00153000
         L     R8,ZSAFSV19(,R9)                                 DSK1132 00154000
         OI    ZSAFLOCK(R8),B'10000000'                         DSK1132 00155000
*         GEN REFS(GPR11P,PSALITA,FLC);                            0375 00156000
         SETLOCK OBTAIN,TYPE=IOSUCB,ADDR=(11),MODE=UNCOND,             *00157000
               RELATED=(UCBAD,ISTZFMAA(UNLOCK))                         00158000
*         GEN REFS(GPR10P,GPR13P,GPR14P,PSACSTK,FRRSCURR,FRRSLAST,FRRS, 00159000
*             FRRSENTR,FRRSPARM,PSALSFCC,FRRSELEN,FRRSFRRA);       0376 00160000
*        SETFRR A,FRRAD=(GPR10P),PARMAD=(GPR14P),               DSK1132*00161000
               WRKREGS=(GPR13P,GPR14P)                                  00162000
         L     R13,PSACSTK-PSA(0,0)                             DSK1132 00162010
         L     R14,FRRSCURR-FRRS(0,R13)                         DSK1132 00162020
         C     R14,FRRSLAST-FRRS(0,R13)                         DSK1132 00162030
         BE    PSALSFCC-PSA(0,0)         S07D                   DSK1132 00162040
         A     R14,FRRSELEN-FRRS(0,R13)                         DSK1132 00162050
         ST    R14,FRRSCURR-FRRS(0,R13)                         DSK1132 00162060
         ST    R10,FRRSFRRA-FRRSENTR(0,R14)                     DSK1132 00162070
         XC    FRRSPARM-FRRSENTR(24,R14),FRRSPARM-FRRSENTR(R14) DSK1132 00162080
         LA    R14,FRRSPARM-FRRSENTR(0,R14)                     DSK1132 00162090
*         GPR14P->WRD00008=GPR11P;  /* SAVE LOCK WORD ADDR           */ 00163000
         ST    R11,WRD00008(,R14)                               DSK1132 00164000
*         GPR14P->WRD10008=GPR09P;  /* SAVE SAVEAREA ADDR            */ 00165000
         ST    R9,WRD10008(,R14)                                DSK1132 00166000
*         GPR15P=GPR09P;            /* KEEP ADDR OF SAVEAREA         */ 00167000
         LR    R15,R9                                           DSK1132 00168000
*         GEN REFS(ZSAFSVVR)(LM    9,14,ZSAFSVVR+0(15));/* RESTORE   */ 00169000
         LM    R9,R14,ZSAFSVVR+0(R15)                           DSK1132 00170000
*         GPR13P=GPR15P;            /* SET UP FIXED SAVEAREA PTR     */ 00171000
         LR    R13,R15                                          DSK1132 00172000
*         RFY                                                      0382 00173000
         L     R3,UCBLDNCB-UCB-1(,R6)                           DSK1132 00173010
         LA    R3,0(,R3)                                        DSK1132 00173020
*          (GPR01P,                                                0382 00174000
*           GPR02P,                                                0382 00175000
*           GPR03P,                                                0382 00176000
*           GPR09P,                                                0382 00177000
*           GPR10P,                                                0382 00178000
*           GPR11P,                                                0382 00179000
*           GPR12P,                                                0382 00180000
*           GPR13P,                                                0382 00181000
*           GPR14P,                                                0382 00182000
*           GPR15P) UNRSTD;                                        0382 00183000
*       END;                        /* *** END TPZLOCK ***           */ 00184000
*                                                                  0383 00185000
*       /*************************************************************/ 00186000
*       /*                                                           */ 00187000
*       /*                                                   @ZM32207*/ 00188000
*       /*                                                           */ 00189000
*       /*************************************************************/ 00190000
*                                                                  0384 00191000
*/* IF ATCLCPTR=0×  ** IF VTAM DOWN                @ZA08403, @ZA13659*/ 00192000
*                                                                  0384 00193000
*       IF UCBATI=0×                /* DEVICE DISCONNECTED OR      0384 00194000
*                                                            @Z40GKD9*/ 00195000
*           ATCABEN='1'B THEN                                      0384 00196000
         L     R14,UCBEXTPT-UCB(,R6)                            DSK1132 00197000
         CLI   UCBATI-UCBCMEXT(R14),0                           DSK1132 00198000
         BE    @RT00384                                            0384 00199000
         TM    ATCABEN(R2),B'10000000'                          DSK1132 00200000
         BO    @RT00384                                            0384 00201000
*         ;                         /* VTAM ABENDING         @RIUXXYQ*/ 00202000
*       ELSE                        /* PROCESS INTERRUPT     @Z40GKD9*/ 00203000
*         DO;                                                      0386 00204000
*           LDNCBREG=UCBLDNCB;      /* GET LDNCB ADDRESS FROM UCB    */ 00205000
*           IF LDNZF006=ON THEN     /* TEST MODE?                    */ 00208000
         TM    LDNZF006(R3),B'00001000'                         DSK1132 00209000
         BNO   @RF00388                                            0388 00210000
*             DO;                                                  0389 00211000
*                                                                  0389 00212000
*               /*****************************************************/ 00213000
*               /*                                                   */ 00214000
*               /* SEGMENT(TSTPRC)REQUEST                            */ 00215000
*               /*                                                   */ 00216000
*               /*****************************************************/ 00217000
*                                                                  0390 00218000
*               DO;                                                0390 00219000
*                 GOTO TSTPRC;                                     0391 00220000
         B     TSTPRC                                              0391 00221000
*TSTPRC#:                                                          0392 00222000
*               END;                                               0392 00223000
*               GO TO NCBOFFSA;                                    0393 00224000
         B     NCBOFFSA                                            0393 00225000
*             END;                                                 0394 00226000
*           ELSE                                                   0395 00227000
*             ;                                                    0395 00228000
@RF00388 DS    0H                                                  0396 00229000
*           IF(LDNZDSIC=ON)×(LDNZFF69=ON) THEN                     0396 00230000
         TM    LDNZDSIC(R3),B'10000000'                         DSK1132 00231000
         BO    @RT00396                                            0396 00232000
         TM    LDNZFF69(R3),B'00000001'                         DSK1132 00233000
         BO    @RT00396                                            0396 00234000
*             ;                     /* DEVICE SICK OR DEACT ON     0397 00235000
*                                                            @ZM32600*/ 00236000
*           ELSE                    /* OTHERWISE PROCESS STATUS      */ 00237000
*NODEVSIC:                                                         0398 00238000
*             DO;                   /* PROCESS STATUS        @YL02HNW*/ 00239000
NODEVSIC DS    0H                                                  0399 00240000
*               PTRRPH=ADDR(LDNRPH);/*                       @YL02HNW*/ 00241000
         LA    R1,LDNRPH(,R3)                                   DSK1132 00242000
*               IF LDNTPBIO=ON THEN /* TEST FLG                      */ 00243000
         TM    LDNTPBIO(R3),B'00000010'                         DSK1132 00244000
         BO    NCBOFFSA                                         DSK1132 00245000
*                 GO TO NCBOFFSA;                                  0401 00246000
*               ELSE                                               0402 00247000
*                 ;                                                0402 00248000
*                                                                  0402 00249000
*/*          IF CSWDE=ON THEN ** IF DEVICE END     @YL02HNW, @ZA18458*/ 00250000
*/*      *** ABOVE LINE DELETED BY...                        @ZA18458*/ 00251000
*                                                                  0403 00252000
*               IF CSWATTN=ON&CSWUC=ON THEN/* IF ATTN/UNIT CHECK   0403 00253000
*                                                            @ZA18458*/ 00254000
*                 GOTO NCBOFFSA;    /* GO BACK TO IOS        @ZA18458*/ 00259000
*               ELSE                                               0405 00260000
*                 ;                 /* NOT ATTN/UNIT CHK     @ZA18458*/ 00261000
*               IF CSWSTAT='04'X×   /* IF DEV END ONLY OR    @ZA18458*/ 00262000
*                   CSWSTAT='84'X THEN/* ATTN/DEVICE END     @ZA18458*/ 00263000
@RT00406 DS    0H                                                  0407 00268000
         TM    IOSTATUS-IOSB(R7),4                              DSK1132 00268010
         BNO   A00012A                                          DSK1132 00268020
         TM    LDNFLAG2(R3),X'20'                               DSK1132 00268030
         BNE   A00012A                                          DSK1132 00268040
*                 DO;                                              0407 00269000
*                   LDNZFF03=ON;    /* SET DEVICE END FLAG           */ 00270000
         L     R14,LDNZFF03-1(,R3)                              DSK1132 00271000
@GL00006 LR    R10,R14                                          DSK1132 00272000
         O     R10,@CF03689                                     DSK1132 00273000
         CS    R14,R10,LDNZFF03-1(R3)                           DSK1132 00274000
         BNE   @GL00006                                            0408 00275000
*/* TPSCHED (ADDR(LDNZPAB1)) UNCOND DIS                              */ 00276000
*/*                          CMZVER = OS/VS2                         */ 00277000
*                                                                  0409 00278000
*                   DO;                                            0409 00279000
*                     DCL                                          0410 00280000
*                       GPR00F FIXED(31) REG(00);                  0410 00281000
*                     DCL                                          0411 00282000
*                       GPR00P PTR(31) REG(00);                    0411 00283000
*                     DCL                                          0412 00284000
*                       GPR05F FIXED(31) REG(05);                  0412 00285000
*                     DCL                                          0413 00286000
*                       GPR05P PTR(31) REG(05);                    0413 00287000
*                     RFY                                          0414 00288000
*                      (GPR00P,                                    0414 00289000
*                       GPR01P,                                    0414 00290000
*                       GPR05P) RSTD;                              0414 00291000
*                     DCL                                          0415 00292000
*                       GPR08F FIXED(31) REG(08);                  0415 00293000
*                     DCL                                          0416 00294000
*                       GPR08P PTR(31) REG(08);                    0416 00295000
*                     GEN REFS(GPR01P) SETS(RPHWORK)               0417 00296000
*                         (STM   GPR02P,GPR08P,RPHWORK(GPR01P));   0417 00297000
         STM   R2,R8,RPHWORK(R1)                                DSK1132 00298000
*                     GPR00P=0;                                    0418 00299000
         SLR   R0,R0                                            DSK1132 00300000
*                     GPR05P=ADDR(LDNZPAB1);                       0419 00301000
         LA    R5,LDNZPAB1(,R3)                                 DSK1132 00302000
*                     CALL ATCLCPTR->ATCAP38->ISTAPC38;            0420 00303000
         L     R10,ATCLCPTR                                     DSK1132 00304000
         L     R15,ATCAP38(,R10)                                DSK1132 00305000
         BALR  R14,R15                                          DSK1132 00306000
*                     GEN(NOPR 3)                                  0421 00307000
*                     NOSETS NOREFS;                               0421 00308000
         NOPR 3                                                         00309000
*                     RFY                                          0422 00310000
*                      (GPR00P,                                    0422 00311000
*                       GPR01P,                                    0422 00312000
*                       GPR05P) UNRSTD;                            0422 00313000
*                   END;            /* **** END TPSCHED      @ZM32953*/ 00314000
*                   IF CSWATTN=ON THEN                             0424 00315000
*                     ;             /* IF ATTN CONTINUE      @ZA18458*/ 00318000
*                   ELSE                                           0426 00319000
*                     GOTO NCBOFFSA;/* NO ATTN -- GET OUT    @ZA18458*/ 00320000
*                 END;                                             0427 00321000
*               ELSE                /*                       @YL02HNW*/ 00322000
*NOTDE:                                                            0428 00323000
*                 DO;               /*                       @YL02HNW*/ 00324000
@RF00406 DS    0H                                                  0428 00326000
A00012A  CLI   IOSTATUS-IOSB(R7),4                              DSK1132 00326010
         BE    NCBOFFSA                                         DSK1132 00326020
         TM    LDNFLAG2(R3),X'20'                               DSK1132 00326030
         BO    NCBOFFSA                                         DSK1132 00326040
         TM    IOSTATUS-IOSB(R7),X'80'                          DSK1132 00326050
         BE    NCBOFFSA                                         DSK1132 00326060
NOTDE    DS    0H                                                  0429 00327000
*                   IF LDNZATTP=ON THEN                            0429 00328000
         TM    LDNZATTP(R3),B'00100000'                         DSK1132 00329000
         BO    @RT00429                                            0429 00330000
*                     ;             /* IF ATTENTION IN PROGRESS      */ 00331000
*                   ELSE            /* OTHERWISE             @YL02HNW*/ 00332000
*NOATTN:                                                           0431 00333000
*                     DO;           /* INITIATE ATTENTION PROCESS    */ 00334000
NOATTN   DS    0H                                                  0432 00335000
*                       LDNZATTP=ON;/* SET ATTENTION FLAG    @YL02HNW*/ 00336000
         L     R14,LDNZATTP(,R3)                                DSK1132 00337000
@GL00007 LR    R10,R14                                          DSK1132 00338000
         O     R10,@CF03692                                     DSK1132 00339000
         CS    R14,R10,LDNZATTP(R3)                             DSK1132 00340000
         BNE   @GL00007                                            0432 00341000
*                       IF LDNZERLK=ON THEN/* IF ERROR LOCK ON     0433 00342000
*                                                            @YL02HNW*/ 00343000
         TM    LDNZERLK(R3),B'01000000'                         DSK1132 00344000
         BNO   @RF00433                                            0433 00345000
*                         LDNZATLK=ON;/* SET ATTENTION W/ERROR LOCK  */ 00346000
         L     R14,LDNZATLK(,R3)                                DSK1132 00347000
@GL00008 LR    R10,R14                                          DSK1132 00348000
         O     R10,@CF03695                                     DSK1132 00349000
         CS    R14,R10,LDNZATLK(R3)                             DSK1132 00350000
         BNE   @GL00008                                            0434 00351000
*                       ELSE        /* OTHERWISE             @YL02HNW*/ 00352000
*                         DO;       /* SCHEDULE I/O          @YL02HNW   00353000
*                                      ADDRESS RPH           @YL02HNW*/ 00354000
         B     @RC00433                                            0435 00355000
@RF00433 DS    0H                                                  0436 00356000
*                           RFY                                    0436 00357000
*                            (REG0,                                0436 00358000
*                             REG15) RSTD;/*                 @YL02HNW   00359000
*                                      I/O INIT PARAMETER, RETURN    */ 00360000
*                           REG0=IOIATRD;/* FLAG ATTENTION READ    0437 00361000
*                                      REQUEST                       */ 00362000
         LA    R0,2                                             DSK1132 00363000
*                           CALL ATCZLFVT->ZLFZEMAA;/*       @YL02HNW   00364000
*                                      CALL I/O INIT         @YL02HNW*/ 00365000
         L     R10,ATCZLFVT(,R2)                                DSK1132 00366000
         L     R15,ZLFZEMAA(,R10)                               DSK1132 00367000
         BALR  R14,R15                                          DSK1132 00368000
*                           IF REG15=0 THEN/* IF I/O TO BE STARTED   */ 00369000
         LTR   R15,R15                                          DSK1132 00370000
         BNZ   @RF00439                                            0439 00371000
*                             DO;   /* START I/O             @YL02HNW*/ 00372000
*                               CALL ATCZLFVT->ZLFZFMFA;/*   @YL02HNW   00373000
*                                      CALL I/O SCHED                */ 00374000
         L     R10,ATCZLFVT(,R2)                                DSK1132 00375000
         L     R15,ZLFZFMFA(,R10)                               DSK1132 00376000
         BALR  R14,R15                                          DSK1132 00377000
*                               RFY                                0442 00378000
*                                (REG0,                            0442 00379000
*                                 REG15) UNRSTD;/*           @YL02HNW*/ 00380000
*                             END;  /*                       @YL02HNW*/ 00381000
*                           ELSE                                   0444 00382000
*                             ;     /*                       @YL02HNW*/ 00383000
@RF00439 DS    0H                                                  0445 00384000
*                         END;                                     0445 00385000
*                     END NOATTN;   /*                       @YL02HNW*/ 00386000
@RC00433 DS    0H                                                  0447 00387000
*                 END NOTDE;        /*                       @YL02HNW*/ 00388000
@RT00429 DS    0H                                                  0448 00389000
*             END NODEVSIC;         /*                       @YL02HNW*/ 00390000
@RC00406 DS    0H                                                  0449 00391000
*         END;                      /* END UCBATI NOT ZERO   @Z40GKD9*/ 00392000
@RT00396 DS    0H                                                  0450 00393000
*/*                                                                  */ 00394000
*                                                                  0450 00395000
*NCBOFFSA:                          /*                       @ZA18458*/ 00396000
*/* RELEASE LDNCB LOCK                                               */ 00397000
*                                                                  0450 00398000
*       UCBPTR=IOSUCB;              /* OBTAIN UCB POINTER    @Z40GKD9*/ 00399000
@RT00384 DS    0H                                                  0450 00400000
NCBOFFSA DS    0H                                               DSK1132 00400010
         TM    LDNFLAG2(R3),X'20'                               DSK1132 00400020
         BNO   A0001C4                                          DSK1132 00400030
         TM    IOSTATUS-IOSB(R7),X'80'                          DSK1132 00400040
         BNO   A0001BA                                          DSK1132 00400050
         L     R10,LDNZATTP(,R3)                                DSK1132 00400060
A0001AC  LR    R4,R10                                           DSK1132 00400070
         O     R4,@CF03692                                      DSK1132 00400080
         CS    R10,R4,LDNZATTP(R3)                              DSK1132 00400090
         BNE   A0001AC                                          DSK1132 00400100
A0001BA  L     R10,ATCZLFVT(,R2)                                DSK1132 00400110
         L     R15,ZLFZFMFA(,R10)                               DSK1132 00400120
         BALR  R14,R15                                          DSK1132 00400130
A0001C4  NI    LDNFLAG2(R3),X'DF'                               DSK1132 00400140
         L     R6,IOSUCB-IOSB(,R7)                              DSK1132 00401010
*/*TPZLOCK  (RELEASE,(UCBAD,ISTFMAA(LOCK)),K0,)   UCBAD              */ 00402000
*                                                                  0451 00403000
*       DO;                                                        0451 00404000
*                                                                  0451 00405000
*/* ATBUILD (ISTZFSAV,ISTZ19SV)                                      */ 00406000
*/* END OF ATBUILD                                                   */ 00407000
*                                                                  0452 00408000
*         RFY                                                      0452 00409000
*          (GPR01P,                                                0452 00410000
*           GPR02P,                                                0452 00411000
*           GPR03P,                                                0452 00412000
*           GPR09P,                                                0452 00413000
*           GPR10P,                                                0452 00414000
*           GPR11P,                                                0452 00415000
*           GPR12P,                                                0452 00416000
*           GPR13P,                                                0452 00417000
*           GPR14P,                                                0452 00418000
*           GPR15P) RSTD;                                          0452 00419000
*         GEN SETS(ZSAFSVVR)(STM   9,14,ZSAFSVVR+0(13));/* SAVE REGS */ 00420000
         STM   R9,R14,ZSAFSVVR+0(R13)                           DSK1132 00421000
*         GPR09P=GPR13P;            /* SAVE SAVEAREA PTR ACROSS    0454 00422000
*                                      MACROS                        */ 00423000
         LR    R9,R13                                           DSK1132 00424000
*         GEN REFS(GPR13P,GPR14P,PSACSTK,FRRSCURR,FRRS,FRRSEMP,FRRSELEN 00425000
*             ,PSA);                                               0455 00426000
*        SETFRR D,WRKREGS=(R13,R14)                             DSK1132 00427000
         L     R13,PSACSTK-PSA(0,0)      ADDRESS OF CURRENT     DSK1132 00427010
         L     R14,FRRSCURR-FRRS(0,R13)                         DSK1132 00427020
         C     R14,FRRSEMP-FRRS(0,R13)                          DSK1132 00427030
         BE    *+12                         YES, DO NOT DELETE  DSK1132 00427040
         S     R14,FRRSELEN-FRRS(0,R13)                         DSK1132 00427050
         ST    R14,FRRSCURR-FRRS(0,R13)                         DSK1132 00427060
*         IF GPR09P->ZSAFSV19->ZSAFLOCK='1'B/* CHECK OWNRSHIP FLG    */ 00428000
*           THEN                                                   0456 00429000
         L     R8,ZSAFSV19(,R9)                                 DSK1132 00430000
         TM    ZSAFLOCK(R8),B'10000000'                         DSK1132 00431000
         BNO   @RF00456                                            0456 00432000
*           DO;                     /* UCB LOCK OWNED - RELEASE IT   */ 00433000
*             GPR11P=ADDR(UCBLOCK);                                0458 00434000
         LR    R11,R6                                           DSK1132 00435000
         AL    R11,@CF03687                                     DSK1132 00436000
*             GEN REFS(GPR11P,PSALITA,FLC);                        0459 00437000
         SETLOCK RELEASE,TYPE=IOSUCB,ADDR=(11),                        *00438000
               RELATED=(UCBAD,ISTFMAA(LOCK))                            00439000
*             GPR09P->ZSAFSV19->ZSAFLOCK='0'B;/* RESET OWNERSHIP FLAG*/ 00440000
         L     R8,ZSAFSV19(,R9)                                 DSK1132 00441000
         NI    ZSAFLOCK(R8),B'01111111'                         DSK1132 00442000
*           END;                    /* END RELEASE LOCK              */ 00443000
*         ELSE                                                     0462 00444000
*           ;                       /* LOCK NOT OWNED                */ 00445000
@RF00456 DS    0H                                                  0463 00446000
*         GEN REFS(ZSAFSVVR)(LM    9,14,ZSAFSVVR+0(9));/* RESTORE    */ 00447000
         LM    R9,R14,ZSAFSVVR+0(R9)                            DSK1132 00448000
*         RFY                                                      0464 00449000
*          (GPR01P,                                                0464 00450000
*           GPR02P,                                                0464 00451000
*           GPR03P,                                                0464 00452000
*           GPR09P,                                                0464 00453000
*           GPR10P,                                                0464 00454000
*           GPR11P,                                                0464 00455000
*           GPR12P,                                                0464 00456000
*           GPR13P,                                                0464 00457000
*           GPR14P,                                                0464 00458000
*           GPR15P) UNRSTD;                                        0464 00459000
*       END;                        /* *** END TPZLOCK ***           */ 00460000
*                                                                  0465 00461000
*       /*************************************************************/ 00462000
*       /*                                                           */ 00463000
*       /*                                                   @Z40GKD9*/ 00464000
*       /*                                                           */ 00465000
*       /*************************************************************/ 00466000
*                                                                  0466 00467000
*/*                                                                  */ 00468000
*                                                                  0466 00469000
*     END;                          /* END ATCVT PTR NOT ZERO      0466 00470000
*                                                            @ZA13659*/ 00471000
*   GEN SETS(REG0,REG15) REFS(REGIOSB,ZATZSAV1,ZATZSAV2);          0467 00472000
*                                                                  0467 00473000
@RT00333 DS    0H                                                  0467 00474000
         LM    R13,R14,ZATZSAV2-IOSB(R7)  RESTORE R13 AND R14   DSK1132 00475000
         LM    R2,R5,ZATZSAV1-IOSB(R7)   RESTORE R2 TO R5       DSK1132 00476000
*/*  SEGMENT(TSTPRC)START                                            */ 00477000
*                                                                  0468 00478000
*   DO;                                                            0468 00479000
*     GOTO TSTPRC@;                                                0469 00480000
         B     TSTPRC@                                             0469 00481000
*TSTPRC:                                                           0470 00482000
*   END;                                                           0470 00483000
TSTPRC   DS    0H                                                  0471 00484000
*   PTRRPH=ADDR(LDNRPH);            /* GET RPH PTR                   */ 00485000
         LA    R1,LDNRPH(,R3)                                   DSK1132 00486000
*/*  REQSTORE FXBUF(ZLBHDSIZ+ZLBCPOFS)HSIZE(ZLBHDSIZ)CLEAR(YES)      */ 00487000
*                                                                  0472 00488000
*   DO;                                                            0472 00489000
*                                                                  0472 00490000
*/* ATBUILD (ISTDYPAB,ISTATCVT,ISTRPH)                               */ 00491000
*/* END OF ATBUILD                                                   */ 00492000
*                                                                  0473 00493000
*     DCL                                                          0473 00494000
*       GPR04F FIXED(31) REG(04);                                  0473 00495000
*     DCL                                                          0474 00496000
*       GPR04P PTR(31) REG(04);                                    0474 00497000
*     DCL                                                          0475 00498000
*       GPR06F FIXED(31) REG(06);                                  0475 00499000
*     DCL                                                          0476 00500000
*       GPR06P PTR(31) REG(06);                                    0476 00501000
*     DCL                                                          0477 00502000
*       GPR07F FIXED(31) REG(07);                                  0477 00503000
*     DCL                                                          0478 00504000
*       GPR07P PTR(31) REG(07);                                    0478 00505000
*     RFY                                                          0479 00506000
*      (GPR02P,                                                    0479 00507000
*       GPR03P,                                                    0479 00508000
*       GPR04P,                                                    0479 00509000
*       GPR15P) RSTD;                                              0479 00510000
*     RFY                                                          0480 00511000
*      (GPR01P,                                                    0480 00512000
*       GPR13P) RSTD;                                              0480 00513000
*     GENERATE REFS(GPR01P,GPR02P,GPR13P) SETS(RPHWORK);           0481 00514000
         STM   R2,R13,RPHWORK(R1)                               DSK1132 00515000
*     RFY                                                          0482 00516000
*      (GPR01P,                                                    0482 00517000
*       GPR13P) UNRSTD;                                            0482 00518000
*     DO;                           /* LISATCVT                    0483 00519000
*                                      CVTBASE(PAGEABLE,(GPR15P))    */ 00520000
*       GPR15P=ATCLCPTR;            /* SET UP ATCVT POINTER          */ 00521000
         L     R15,ATCLCPTR                                     DSK1132 00522000
*     END;                          /* LISATCVT                      */ 00523000
*     RFY                                                          0486 00524000
*       ISTBPENT;                                                  0486 00525000
*     RFY                                                          0487 00526000
*       ISTBPDTY;                                                  0487 00527000
*     GPR02P=GPR15P->ATCBPDA->BPDCHPCB;                            0488 00528000
         L     R14,ATCBPDA(,R15)                                DSK1132 00529000
         L     R2,BPDCHPCB(,R14)                                DSK1132 00530000
*     DCL                                                          0489 00531000
*       1 FMZA0024 FIXED(31) STATIC LOCAL,                         0489 00532000
*        2 * FIXED(8) INIT(136),                                   0489 00533000
*        2 * PTR(24) INIT(0);                                      0489 00534000
*     GPR03F=(ZLBHDSIZ&'0000FFFF'X)×FMZA0024;                      0490 00535000
         L     R3,FMZA0024                                      DSK1132 00536000
         O     R3,@CF03475                                      DSK1132 00537000
*     GPR04F=ZLBHDSIZ+ZLBCPOFS;                                    0491 00538000
         LA    R4,32                                            DSK1132 00539000
*     GPR15P=GPR15P->ATCSMRQ;                                      0492 00540000
         L     R15,ATCSMRQ(,R15)                                DSK1132 00541000
*     DCL                                                          0493 00542000
*       FMZL0024 BASED(GPR15P) LABEL VALUERANGE(*);                0493 00543000
*     CALL FMZL0024;                                               0494 00544000
         BALR  R14,R15                                          DSK1132 00545000
*     RFY                                                          0495 00546000
*      (GPR13P) RSTD;                                              0495 00547000
*     GENERATE REFS(GPR01P,RPHWORK) SETS(GPR02P,GPR13P);           0496 00548000
         LM    R2,R13,RPHWORK(R1)                               DSK1132 00549000
*     RFY                                                          0497 00550000
*      (GPR13P) UNRSTD;                                            0497 00551000
*     RFY                                                          0498 00552000
*      (GPR02P,                                                    0498 00553000
*       GPR03P,                                                    0498 00554000
*       GPR04P,                                                    0498 00555000
*       GPR15P) UNRSTD;                                            0498 00556000
*   END;                            /* ******** END OF REQSTORE    0499 00557000
*                                      EXPANSION                     */ 00558000
*                                                                  0499 00559000
*   /*****************************************************************/ 00560000
*   /*                                                               */ 00561000
*   /* GET FIXED BUFFER                                              */ 00562000
*   /*                                                               */ 00563000
*   /*****************************************************************/ 00564000
*                                                                  0500 00565000
*   RFY                                                            0500 00566000
*     REG15 RSTD;                                                  0500 00567000
*   IF REG15<8 THEN                 /* BUFFER GOTTEN                 */ 00568000
         C     R15,@CF00047                                     DSK1132 00569000
         BNL   @RF00501                                            0501 00570000
*     DO;                                                          0502 00571000
*       RFY                                                        0503 00572000
*         REG15 UNRSTD;                                            0503 00573000
*       DO;                         /* LISATCVT                    0504 00574000
*                                      CVTBASE(PAGEABLE,(REG2))      */ 00575000
*         REG2=ATCLCPTR;            /* SET UP ATCVT POINTER          */ 00576000
         L     R2,ATCLCPTR                                      DSK1132 00577000
*       END;                        /* LISATCVT                      */ 00578000
*       REG6=RPHSRPRM;              /* GET BUFFER ADDR               */ 00579000
         L     R6,RPHSRPRM(,R1)                                 DSK1132 00580000
*       FSBTYPE=FSTYPE;                                            0508 00581000
         LA    R10,16                                           DSK1132 00582000
         ALR   R10,R6                                           DSK1132 00583000
         MVI   FSBTYPE(R10),X'02'                               DSK1132 00584000
*       FSBLNGTH=LENGTH(ISTFSB);                                   0509 00585000
         MVI   FSBLNGTH(R10),X'2C'                              DSK1132 00586000
*       FDBDATAA=ADDR(ZLBTEXT1);                                   0510 00587000
         LA    R4,ZLBTEXT1(,R6)                                 DSK1132 00588000
         ST    R4,FDBDATAA(,R6)                                 DSK1132 00589000
*       FDBDATCT=LENGTH(ISTCSW)+4;  /*                       @ZM40666*/ 00590000
         MVC   FDBDATCT(2,R6),@CH00032                          DSK1132 00591000
*       ZLBCOMP=ZLBATTNR;           /* COMP CODE=TEST ATTN           */ 00592000
         MVI   ZLBCOMP(R6),X'34'                                DSK1132 00593000
*       ZLBTEXT1(2:8)=IOSCSW;       /* NOVE IN CSW                   */ 00594000
         MVC   ZLBTEXT1+1(7,R6),IOSCSW-IOSB(R7)                 DSK1132 00595000
*       FSBSAF=LDNTSAF;             /* SET SRC ADDR FLD              */ 00596000
         MVC   FSBSAF(2,R10),LDNTSAF(R3)                        DSK1132 00597000
*       FSBDAF=LDNCBREG->NCBDAF;    /* SET DEST ADDR FLD             */ 00598000
         MVC   FSBDAF(2,R10),NCBDAF(R3)                         DSK1132 00599000
*/*  TPQUE (ADDR(ZLBFSB),ADDR(ATCZPAB1)->DYPPAB) NORM DIS            */ 00600000
*/*                          CMZVER = OS/VS2                         */ 00601000
*                                                                  0516 00602000
*       DO;                                                        0516 00603000
*         RFY                                                      0517 00604000
*          (GPR00P,                                                0517 00605000
*           GPR01P,                                                0517 00606000
*           GPR04P,                                                0517 00607000
*           GPR05P,                                                0517 00608000
*           GPR15P) RSTD;                                          0517 00609000
*         GEN REFS(GPR01P) SETS(RPHWORK)                           0518 00610000
*             (STM GPR02P,GPR08P,RPHWORK(GPR01P));                 0518 00611000
         STM   R2,R8,RPHWORK(R1)                                DSK1132 00612000
*         GPR00P=0;                                                0519 00613000
         SLR   R0,R0                                            DSK1132 00614000
*         GPR15P=ADDR(ADDR(ATCZPAB1)->DYPPAB);/* HOLD PAB PTR        */ 00615000
         LA    R15,DYPPAB+1104(,R2)                             DSK1132 00616000
*         GPR04P=ADDR(ZLBFSB);      /* WORK ELE PTR                  */ 00617000
         LA    R4,ZLBFSB(,R6)                                   DSK1132 00618000
*         GPR05P=GPR15P;            /* PASS PAB PTR                  */ 00619000
         LR    R5,R15                                           DSK1132 00620000
*         CALL ATCLCPTR->ATCAP37->ISTAPC37;                        0523 00621000
         L     R10,ATCLCPTR                                     DSK1132 00622000
         L     R15,ATCAP37(,R10)                                DSK1132 00623000
         BALR  R14,R15                                          DSK1132 00624000
*         GEN(NOPR  2)                                             0524 00625000
*         NOSETS NOREFS;                                           0524 00626000
         NOPR  2                                                        00627000
*         RFY                                                      0525 00628000
*          (GPR00P,                                                0525 00629000
*           GPR01P,                                                0525 00630000
*           GPR04P,                                                0525 00631000
*           GPR05P,                                                0525 00632000
*           GPR15P) UNRSTD;                                        0525 00633000
*       END;                        /* *** END OF TPQUE GENERATION   */ 00634000
*     END;                                                         0527 00635000
*   ELSE                                                           0528 00636000
*     DO;                                                          0528 00637000
         B     @RC00501                                            0528 00638000
@RF00501 DS    0H                                                  0529 00639000
*       LDNZACSW(2)=REGIOSB->IOSCSW;/* SAVE CSW                      */ 00640000
         MVC   LDNZACSW+1(1,R3),IOSCSW-IOSB(R7)                 DSK1132 00641000
*       LDNZF005=ON;                /* TOLTEP ATTN FLAG              */ 00642000
         L     R10,LDNZF005-3(,R3)                              DSK1132 00643000
@GL00009 LR    R4,R10                                           DSK1132 00644000
         O     R4,@CF03699                                      DSK1132 00645000
         CS    R10,R4,LDNZF005-3(R3)                            DSK1132 00646000
         BNE   @GL00009                                            0530 00647000
*       IF LDNZFF69=OFF THEN        /* NOT DEACT ALREADY             */ 00648000
         TM    LDNZFF69(R3),B'00000001'                         DSK1132 00649000
         BNZ   @RF00531                                            0531 00650000
*         DO;                                                      0532 00651000
*           LDNZFF02=ON;            /* BUFFER ALLOC FLAG ON          */ 00652000
         L     R10,LDNZFF02-1(,R3)                              DSK1132 00653000
@GL00010 LR    R4,R10                                           DSK1132 00654000
         O     R4,@CF03702                                      DSK1132 00655000
         CS    R10,R4,LDNZFF02-1(R3)                            DSK1132 00656000
         BNE   @GL00010                                            0533 00657000
*           REG5=ADDR(LDNZPAB1);                                   0534 00658000
*                                                                  0534 00659000
         LA    R5,LDNZPAB1(,R3)                                 DSK1132 00660000
*/* TPSCHED (REG5) UNCOND DIS                                        */ 00661000
*/*                          CMZVER = OS/VS2                         */ 00662000
*                                                                  0535 00663000
*           DO;                                                    0535 00664000
*             RFY                                                  0536 00665000
*              (GPR00P,                                            0536 00666000
*               GPR01P,                                            0536 00667000
*               GPR05P) RSTD;                                      0536 00668000
*             GEN REFS(GPR01P) SETS(RPHWORK)                       0537 00669000
*                 (STM   GPR02P,GPR08P,RPHWORK(GPR01P));           0537 00670000
         STM   R2,R8,RPHWORK(R1)                                DSK1132 00671000
*             GPR00P=0;                                            0538 00672000
         SLR   R0,R0                                            DSK1132 00673000
*             GPR05P=REG5;                                         0539 00674000
*             CALL ATCLCPTR->ATCAP38->ISTAPC38;                    0540 00675000
         L     R10,ATCLCPTR                                     DSK1132 00676000
         L     R15,ATCAP38(,R10)                                DSK1132 00677000
         BALR  R14,R15                                          DSK1132 00678000
*             GEN(NOPR 3)                                          0541 00679000
*             NOSETS NOREFS;                                       0541 00680000
         NOPR 3                                                         00681000
*             RFY                                                  0542 00682000
*              (GPR00P,                                            0542 00683000
*               GPR01P,                                            0542 00684000
*               GPR05P) UNRSTD;                                    0542 00685000
*           END;                    /* **** END TPSCHED      @ZM32953*/ 00686000
*         END;                                                     0544 00687000
*       ELSE                                                       0545 00688000
*         ;                                                        0545 00689000
@RF00531 DS    0H                                                  0546 00690000
*     END;                                                         0546 00691000
*                                                                  0546 00692000
*/* SEGMENT(TSTPRC)FINISH                                            */ 00693000
*                                                                  0547 00694000
*   DO;                                                            0547 00695000
@RC00501 DS    0H                                                  0548 00696000
*     GOTO TSTPRC#;                                                0548 00697000
         B     TSTPRC#                                             0548 00698000
*TSTPRC@:                                                          0549 00699000
*   END;                                                           0549 00700000
*                                                                  0549 00701000
TSTPRC@  DS    0H                                                  0550 00702000
*/* TPEPILOG                                                         */ 00703000
*                                                                  0550 00704000
*   GEN(PRINT OFF);                                                0550 00705000
         PRINT OFF                                                      00706000
*/* ***** POOL ENTRY  ***** */                                     0551 00707000
*/*  INITIAL LEVEL                                     001 12/20/74  */ 00708000
*DCL   1  ISTBPENT BDY(DWORD) BASED(BPEPTR),                       0551 00709000
*         2  BPEPID   CHAR(4),         /* POOL ID                    */ 00710000
*         2  BPEFLAGS BIT(16),         /* POOL FLAGS ZUP0589 @Z40GKDS*/ 00711000
*            3  BPEFM    BIT(1),       /* POOL FORMAT                */ 00712000
*            3  BPEDISP  BIT(1),       /* SHARED OR PRIVATE          */ 00713000
*            3  BPEFIXED BIT(1),       /* FIXED OR PAGEABLE          */ 00714000
*            3  BPENFCHP BIT(1),       /* NON-FETCH PROTECTION       */ 00715000
*            3  BPEAL48  BIT(1),       /* 4,8 ALIGNEMENT OF BUFFERS  */ 00716000
*            3  BPECBID  BIT(1),       /* CBID POOL                  */ 00717000
*            3  BPENWS   BIT(1),       /* NON-WORKING SET POOL       */ 00718000
*            3  BPERSV01 BIT(1),       /* RESERVED   ZUP0589 @Z40GKDS*/ 00719000
*            3  BPEUSRF  BIT(1),       /* USER REQUIRES FIXED BUF    */ 00720000
*            3  BPERSV02 BIT(7),       /* RESERVED   ZUP0589 @Z40GKDS*/ 00721000
*         2  BPEBFSIZ FIXED(15),       /* BUFFER SIZE IN BYTES       */ 00722000
*         2  BPEBPCB  PTR(31),         /* ADDRESS OF BPCB            */ 00723000
*         2  BPERSV03 CHAR(4);         /* RESERVED                   */ 00724000
*/* ***** POOL DIRECTORY  ***** */                                 0552 00725000
*/*  REVISIONS                                         002 03/20/75  */ 00726000
*DCL   1  ISTBPDTY BDY(DWORD) BASED(BPDPTR),                       0552 00727000
*         2  BPDHDR CHAR(144) BDY(WORD),/* DIRECTORY HEADER          */ 00728000
*            3  BPDBPENT FIXED(15),    /* CURRENT NUMBER OF ENTRIES  */ 00729000
*            3  BPDBPMAX FIXED(15),    /* MAXIMUN NUMBER OF ENTRIES  */ 00730000
*            3  BPDCHBNO FIXED(15),    /* NO. BUFFERS FOR CHPGM      */ 00731000
*            3  BPDCHBSZ FIXED(15),    /* BUFFER SIZE FOR CH PGM     */ 00732000
*            3  BPDCHPCB PTR(31),      /* BPCB ADDR FOR CHPGM        */ 00733000
*            3  BPDPGPCB PTR(31),      /* BPCB ADDR FOR PGBUF        */ 00734000
*            3  BPDADRS1 PTR(31),      /* BEGINNIG ADDR FOR POOLS    */ 00735000
*            3  BPDADRS2 PTR(31),      /* END ADDR FOR POOLS         */ 00736000
*            3  BPDFEXT  PTR(31),      /* ADDR OF 1ST FREE EXTENT    */ 00737000
*            3  BPDSMPCB PTR(31),      /* SMS WE BPCB ADDRESS        */ 00738000
*            3  BPDFBPE  PTR(31),      /* FIRST POOL ENTRY           */ 00739000
*            3  BPDATCVT PTR(31),      /* PTR BACK TO ATCVT          */ 00740000
*            3  BPDFLAG  FIXED(32),    /* FLAGS FIELD                */ 00741000
*               4 BPDGTR   BIT(1),     /* GTRACE REQUESTED           */ 00742000
*               4 BPDRSV01 BIT(31),    /* RESERVED                   */ 00743000
*            3  BPDREQCT FIXED(15),    /* COUNT OF REQSTORES         */ 00744000
*            3  BPDREQMX FIXED(15),    /* GTRACE REQ INTRVAL         */ 00745000
*            3  BPDPARM  CHAR(8) BDY(WORD),/* GTRACE PARM            */ 00746000
*               4 BPDTRLEN FIXED(15),  /* GTRACE DATA LENGTH         */ 00747000
*               4 *        CHAR(1),    /* RESERVED                   */ 00748000
*               4 BPDTRID  CHAR(1),    /* GTRACE FORMAT ID           */ 00749000
*               4 BPDTRADR PTR(31),    /* GTRACE DATA ADDR           */ 00750000
*            3  BPDTRACE (11) CHAR(8) BDY(WORD),/* GTRACE DATA       */ 00751000
*               4 BPDMUSE  FIXED(15),  /* MAX BUFFERS IN USE         */ 00752000
*               4 BPDMQUE  FIXED(15),  /* MAX REQUESTS QUEUED        */ 00753000
*               4 BPDAVNO  FIXED(15),  /* AVAIL NUMBER OF BUFFRS     */ 00754000
*               4 *        CHAR(2),    /* RESERVED                   */ 00755000
*         2  BPDENTRY (12)CHAR(LENGTH(ISTBPENT)), /* BEGIN POOL ENTRY*/ 00756000
*         2  BPDCBID  CHAR(*);         /* CBID TABLE SECTION         */ 00757000
*   DCL                                                            0553 00758000
*     ISTAPC38 ENTRY BASED(ATCAP38) VALRG(*);/* TPSCHED ROUTINE      */ 00759000
*   DCL                                                            0554 00760000
*     ISTAPC34 ENTRY BASED(ATCAP34) VALRG(*);/* RESET ROUTINE        */ 00761000
*   DCL                                                            0555 00762000
*     ISTAPC37 ENTRY BASED(ATCAP37) VALRG(*);/* TPQUE ROUTINE        */ 00763000
*   GEN(PRINT ON);                                                 0556 00764000
*                                                                  0556 00765000
         PRINT ON                                                       00766000
*/* END OF TPEPILOG                                                  */ 00767000
*                                                                  0557 00768000
*   END ISTZFMAA                    /* END VS/2 ATTN HANDLER         */ 00769000
*                                                                  0557 00770000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00771000
*/*%INCLUDE SYSLIB  (IEFUCBOB)                                       */ 00772000
*/*%INCLUDE SYSLIB  (IECDIOSB)                                       */ 00773000
*/*%INCLUDE SYSLIB  (IEZIOB  )                                       */ 00774000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00775000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00776000
*/*%INCLUDE SYSLIB  (IHASRB  )                                       */ 00777000
*/*%INCLUDE SYSLIB  (IHAFRRS )                                       */ 00778000
*                                                                  0557 00779000
*       ;                                                          0557 00780000
@EL00001 DS    0H                                                  0557 00781000
@EF00001 DS    0H                                                  0557 00782000
@ER00001 BR    R14                                              DSK1132 00783000
@DATA    DS    0H                                                       00784000
@CH00032 DC    H'12'                                                    00785000
@DATD    DSECT                                                          00786000
         DS    0F                                                       00787000
ISTZFMAA CSECT                                                          00788000
         DC    X'B028'                       !!! SOURCE COMPARE FIX !!! 00789000
         DC    0F'0'                                            DSK1132 00789000
@CF00047 DC    F'8'                                                     00790000
@CF03475 DC    F'28'                                                    00791000
@CF03687 DC    F'-8'                                                    00792000
@CF03689 DC    BL4'00000000000001000000000000000000'                    00793000
@CF03692 DC    BL4'00100000000000000000000000000000'                    00794000
@CF03695 DC    BL4'00001000000000000000000000000000'                    00795000
@CF03699 DC    BL4'00000000000000000000000000010000'                    00796000
@CF03702 DC    BL4'00000000000010000000000000000000'                    00797000
@DATD    DSECT                                                          00798000
         DS    0D                                                       00799000
IOSBPTR  DS    A                                                        00800000
IOBPRPTR DS    A                                                        00801000
IOBSTPTR DS    A                                                        00802000
MYCVTPTR DS    A                                                DSK1132 00803000
SRBPTR   DS    A                                                        00804000
FRRSPTR  DS    A                                                        00805000
FRREPTR  DS    A                                                        00806000
LDNCBPTR DS    A                                                        00807000
FSBPTR   DS    A                                                        00808000
BPEPTR   DS    A                                                        00809000
BPDPTR   DS    A                                                        00810000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00811000
@ENDDATD EQU   *                                                        00812000
ISTZFMAA CSECT                                                          00813000
         DC    0F'0'                                            DSK1132 00814000
@SIZDATD DC    AL1(0)                                                   00815000
         DC    AL3(@ENDDATD-@DATD)                                      00816000
         DC    0D'0'                                            DSK1132 00817000
FMZA0024 DS    FL4                                                      00818000
         ORG   FMZA0024                                                 00819000
@NM00068 DC    AL1(136)                                                 00820000
@NM00069 DC    AL3(0)                                                   00821000
         ORG   FMZA0024+4                                               00822000
         CVT      DSECT=YES,LIST=YES                            DSK1132 00823000
         IECDIOSB ,                                             DSK1132 00823001
UCB      DSECT    ,                                             DSK1132 00823002
         IEFUCBOB LIST=YES                                      DSK1132 00823003
         IHAFRRS  ,                                             DSK1132 00823004
         IHAPSA   ,                                             DSK1132 00823005
R0       EQU   0                       REGISTER 0               DSK1132 00823006
R1       EQU   1                       REGISTER 1               DSK1132 00823007
R2       EQU   2                       REGISTER 2               DSK1132 00823008
R3       EQU   3                       REGISTER 3               DSK1132 00823009
R4       EQU   4                       REGISTER 4               DSK1132 00823010
R5       EQU   5                       REGISTER 5               DSK1132 00823011
R6       EQU   6                       REGISTER 6               DSK1132 00823012
R7       EQU   7                       REGISTER 7               DSK1132 00823013
R8       EQU   8                       REGISTER 8               DSK1132 00823014
R9       EQU   9                       REGISTER 9               DSK1132 00823015
R10      EQU   10                      REGISTER 10              DSK1132 00823016
R11      EQU   11                      REGISTER 11              DSK1132 00823017
R12      EQU   12                      REGISTER 12              DSK1132 00823018
R13      EQU   13                      REGISTER 13              DSK1132 00823019
R14      EQU   14                      REGISTER 14              DSK1132 00823020
R15      EQU   15                      REGISTER 15              DSK1132 00823021
ATCLCPTR EQU   1032                                                     00920000
IOBPREFX EQU   0                                                        00997000
IOBCFLG1 EQU   IOBPREFX                                                 00998000
IOBSTDRD EQU   0                                                        00999000
IOBFLAG1 EQU   IOBSTDRD                                                 01000000
IOBCYCCK EQU   IOBFLAG1                                                 01001000
IOBRSTRT EQU   IOBFLAG1                                                 01002000
IOBFLAG2 EQU   IOBSTDRD+1                                               01003000
IOBPURGE EQU   IOBFLAG2                                                 01004000
IOBRDHA0 EQU   IOBFLAG2                                                 01005000
IOBSENS0 EQU   IOBSTDRD+2                                               01006000
IOBS0B7  EQU   IOBSENS0                                                 01007000
IOBSENS1 EQU   IOBSTDRD+3                                               01008000
IOBECBPT EQU   IOBSTDRD+4                                               01009000
IOBFLAG3 EQU   IOBSTDRD+8                                               01010000
IOBFL3   EQU   IOBFLAG3                                                 01011000
IOBCNC   EQU   IOBFL3                                                   01012000
IOBICL   EQU   IOBFL3                                                   01013000
IOBCSW   EQU   IOBSTDRD+9                                               01014000
IOBIOCSW EQU   IOBCSW                                                   01015000
IOBSTBYT EQU   IOBIOCSW+3                                               01016000
IOBUSTAT EQU   IOBSTBYT                                                 01017000
IOBCSTAT EQU   IOBSTBYT+1                                               01018000
IOBSTART EQU   IOBSTDRD+16                                              01019000
IOBDCBPT EQU   IOBSTDRD+20                                              01020000
IOBFLAG4 EQU   IOBDCBPT                                                 01021000
IOBRESTR EQU   IOBSTDRD+24                                              01022000
IOBINCAM EQU   IOBSTDRD+28                                              01023000
IOBBTAMF EQU   IOBINCAM                                                 01024000
ISTDEVCH EQU   0                                                        01091000
DEVSHCH  EQU   ISTDEVCH                                                 01092000
DEVCHAR  EQU   DEVSHCH                                                  01093000
DEVTCODE EQU   ISTDEVCH+1                                               01094000
DEVFLAGS EQU   ISTDEVCH+3                                               01095000
DEVFCCTL EQU   DEVFLAGS                                                 01096000
DEVCHAR3 EQU   DEVFLAGS                                                 01097000
ISTNCB   EQU   0                                                        01098000
NCBDAF   EQU   ISTNCB+2                                                 01099000
NCBFLAGS EQU   ISTNCB+24                                                01100000
NCBFRAS  EQU   NCBFLAGS+1                                               01101000
NCBFTRIO EQU   NCBFRAS                                                  01102000
NCBFLAG1 EQU   NCBFLAGS+2                                               01103000
ISTPAB   EQU   0                                                        01104000
PABWQCHN EQU   ISTPAB                                                   01105000
PABWEQA  EQU   PABWQCHN                                                 01106000
PABCHAIN EQU   PABWQCHN+4                                               01107000
PABRPHFG EQU   ISTPAB+12                                                01108000
PABFLAGS EQU   PABRPHFG                                                 01109000
PABERLCK EQU   PABFLAGS                                                 01110000
PABERRLK EQU   PABERLCK                                                 01111000
ISTZLFVT EQU   0                                                        01112000
ZLFZEFAA EQU   ISTZLFVT+4                                               01113000
ZLFZEAAA EQU   ZLFZEFAA                                                 01114000
ZLFZEMAA EQU   ZLFZEAAA                                                 01115000
ZLFZFFFA EQU   ISTZLFVT+8                                               01116000
ZLFZFAFA EQU   ZLFZFFFA                                                 01117000
ZLFZFMFA EQU   ZLFZFAFA                                                 01118000
ZLFZEFTA EQU   ISTZLFVT+12                                              01119000
ZLFZEATA EQU   ZLFZEFTA                                                 01120000
ZLFZFFTA EQU   ISTZLFVT+16                                              01121000
ZLFZFATA EQU   ZLFZFFTA                                                 01122000
ZLFZEFFA EQU   ISTZLFVT+24                                              01123000
ZLFZEAFA EQU   ZLFZEFFA                                                 01124000
ZLFZEFCA EQU   ISTZLFVT+28                                              01125000
ZLFZEACA EQU   ZLFZEFCA                                                 01126000
ISTRPH   EQU   0                                                        01127000
RPHCNTL  EQU   ISTRPH                                                   01128000
RPHFLAGS EQU   RPHCNTL+2                                                01129000
RPHAPTYP EQU   RPHFLAGS                                                 01130000
RPHFSTLC EQU   RPHFLAGS                                                 01131000
RPHFLGB  EQU   RPHCNTL+3                                                01132000
RPHRPHA  EQU   ISTRPH+4                                                 01133000
RPHTSKID EQU   ISTRPH+8                                                 01134000
RPHRESMA EQU   ISTRPH+16                                                01135000
RPHWPFLG EQU   RPHRESMA                                                 01136000
RPHWEA   EQU   ISTRPH+24                                                01137000
RPHCSPA  EQU   RPHWEA                                                   01138000
RPHSRPRM EQU   ISTRPH+28                                                01139000
RPHPABQA EQU   ISTRPH+36                                                01140000
RPHWORK  EQU   ISTRPH+40                                                01141000
RPHSAVE1 EQU   RPHWORK                                                  01142000
RPHSBITS EQU   RPHSAVE1+1                                               01143000
ISTLOK   EQU   0                                                        01144000
LOKCHN   EQU   ISTLOK+1                                                 01145000
LOKCHNG  EQU   LOKCHN                                                   01146000
ISTLDNCB EQU   0                                                        01148000
LDNTSAF  EQU   ISTLDNCB+52                                              01149000
LDNCFLAG EQU   ISTLDNCB+54                                              01150000
LDNZACSW EQU   ISTLDNCB+76                                              01151000
LDNFLAGS EQU   ISTLDNCB+107                                             01152000
LDNZF005 EQU   LDNFLAGS                                                 01153000
LDNZF006 EQU   LDNFLAGS                                                 01154000
LDNZATTP EQU   LDNFLAGS+1                                               01155000
LDNZATLK EQU   LDNFLAGS+1                                               01156000
LDNZFF02 EQU   LDNFLAGS+2                                               01157000
LDNZFF03 EQU   LDNFLAGS+2                                               01158000
LDNTPBIO EQU   LDNFLAGS+2                                               01159000
LDNZFF69 EQU   LDNFLAGS+2                                               01160000
LDNFLAG2 EQU   ISTLDNCB+110                                             01161000
LDNZPAB1 EQU   ISTLDNCB+168                                             01162000
LDNZIOLK EQU   ISTLDNCB+184                                             01163000
LDNZDSIC EQU   LDNZIOLK                                                 01164000
LDNZERLK EQU   LDNZIOLK                                                 01165000
LDNZERPF EQU   ISTLDNCB+185                                             01166000
LDNZCPAN EQU   LDNZERPF                                                 01167000
LDNZEPIN EQU   LDNZERPF                                                 01168000
LDNZLPC  EQU   ISTLDNCB+186                                             01169000
LDNRPH   EQU   ISTLDNCB+192                                             01170000
LDNDCDEB EQU   ISTLDNCB+304                                             01171000
LDNZSAV3 EQU   ISTLDNCB+376                                             01172000
LDNZSAV4 EQU   LDNZSAV3+8                                               01173000
LDNZH003 EQU   ISTLDNCB+577                                             01174000
ISTDYPAB EQU   0                                                        01175000
DYPPAB   EQU   ISTDYPAB+16                                              01176000
ISTATCVT EQU   0                                                        01177000
ATCCOM   EQU   ISTATCVT                                                 01178000
ATCSTAT  EQU   ATCCOM                                                   01179000
ATCSTAT1 EQU   ATCSTAT                                                  01180000
ATCACTIV EQU   ATCSTAT1                                                 01181000
ATCSTFLG EQU   ATCSTAT+1                                                01182000
ATCPOFLG EQU   ATCSTAT+2                                                01183000
ATCSTAT4 EQU   ATCSTAT+3                                                01184000
ATCBPDA  EQU   ATCCOM+128                                               01185000
ATCIOTRC EQU   ATCCOM+140                                               01186000
ATCTHTRC EQU   ATCIOTRC                                                 01187000
ATCSMRQ  EQU   ATCCOM+180                                               01188000
ATCCSMR  EQU   ISTATCVT+296                                             01189000
ATCSHRFG EQU   ISTATCVT+316                                             01190000
ATCHPGM  EQU   ISTATCVT+384                                             01191000
ATCVLCNT EQU   ISTATCVT+772                                             01192000
ATCRNO   EQU   ISTATCVT+788                                             01193000
ATCSOPD  EQU   ISTATCVT+792                                             01194000
ATCSIPD  EQU   ISTATCVT+800                                             01195000
ATCSECST EQU   ISTATCVT+812                                             01196000
ATCSTAT2 EQU   ISTATCVT+818                                             01197000
ATCVTBAM EQU   ISTATCVT+908                                             01198000
ATCAOSM  EQU   ISTATCVT+912                                             01200000
ATCGSRBQ EQU   ATCAOSM+4                                                01201000
ATCGSRBG EQU   ATCGSRBQ                                                 01202000
ATCAP34  EQU   ATCAOSM+32                                               01203000
ATCICAPP EQU   ATCAOSM+100                                              01204000
ATCLDAPP EQU   ATCAOSM+120                                              01205000
ATCDAPVT EQU   ATCAOSM+140                                              01206000
ATCZLFVT EQU   ATCAOSM+188                                              01207000
ATCZPAB1 EQU   ATCAOSM+192                                              01208000
ATCAP37  EQU   ATCAOSM+264                                              01209000
ATCAP38  EQU   ATCAOSM+268                                              01210000
ATCCRA   EQU   ATCAOSM+280                                              01211000
ATCCRACN EQU   ATCCRA+4                                                 01212000
ATCSRB   EQU   ATCAOSM+288                                              01213000
ATCSRBCN EQU   ATCSRB+4                                                 01214000
ATCCRPL  EQU   ATCAOSM+296                                              01215000
ATCRPLCN EQU   ATCCRPL+4                                                01216000
ATCSQAFR EQU   ATCAOSM+304                                              01217000
ATCORTBC EQU   ATCSQAFR+4                                               01218000
ATCORSRB EQU   ATCORTBC                                                 01219000
ATCABEN  EQU   ATCAOSM+332                                      DSK1132 01221000
ATCVTFLG EQU   ATCAOSM+392                                              01222000
ATCZR01  EQU   ATCAOSM+572                                              01223000
ATCTPCP0 EQU   ATCAOSM+580                                              01224000
ATCZFLAG EQU   ATCAOSM+588                                              01225000
ISTCSW   EQU   0                                                        01226000
CSWSTAT  EQU   ISTCSW+4                                                 01227000
CSWUSTAT EQU   CSWSTAT                                                  01228000
CSWATTN  EQU   CSWUSTAT                                                 01229000
CSWUC    EQU   CSWUSTAT                                                 01230000
CSWCSTAT EQU   CSWSTAT+1                                                01231000
ISTFDB   EQU   0                                                        01232000
FDBDATAA EQU   ISTFDB+4                                                 01233000
FDBDATCT EQU   ISTFDB+8                                                 01234000
ISTFSB   EQU   0                                                        01235000
FSBFSB   EQU   ISTFSB                                                   01236000
FSBTYPE  EQU   FSBFSB                                                   01237000
FSBLNGTH EQU   FSBFSB+1                                                 01238000
FSBMNRCD EQU   FSBFSB+2                                                 01239000
FSBSFLGS EQU   FSBFSB+3                                                 01240000
FSBFSBA  EQU   FSBFSB+4                                                 01241000
FSBBTH   EQU   FSBFSB+8                                                 01242000
FSBCID   EQU   FSBBTH                                                   01243000
FSBSAF   EQU   FSBCID                                                   01244000
FSBDAF   EQU   FSBCID+2                                                 01245000
FSBRQTAG EQU   FSBBTH+4                                                 01246000
FSBSEQID EQU   FSBRQTAG                                                 01247000
FSBFLAGS EQU   FSBSEQID                                                 01248000
FSBSEQ   EQU   FSBSEQID+1                                               01249000
FSBCSWST EQU   FSBBTH+6                                                 01250000
FSBTHFLD EQU   FSBCSWST                                                 01251000
FSBTH1   EQU   FSBTHFLD                                                 01252000
FSBSYSRS EQU   FSBTH1                                                   01253000
FSBTH2   EQU   FSBTHFLD+1                                               01254000
FSBEXTRS EQU   FSBTH2                                                   01255000
FSBXFSTS EQU   FSBEXTRS                                                 01256000
FSBXCODE EQU   FSBEXTRS                                                 01257000
FSBNETRS EQU   FSBFSB+16                                                01258000
FSBSRCAT EQU   FSBNETRS                                                 01259000
FSBERC   EQU   FSBNETRS+1                                               01260000
FSBFBMI  EQU   FSBERC                                                   01261000
FSBDMGRS EQU   FSBFSB+18                                                01262000
FSBSS1   EQU   FSBDMGRS                                                 01263000
FSBSS2   EQU   FSBDMGRS+1                                               01264000
FSBLCPB  EQU   FSBFSB+20                                                01265000
FSBMSGID EQU   FSBLCPB                                                  01266000
FSBLCCWA EQU   FSBFSB+24                                                01267000
FSBRLSTS EQU   FSBLCCWA                                                 01268000
ISTZLBUF EQU   0                                                        01269000
ZLBFSM   EQU   ISTZLBUF+4                                               01270000
ISTZFSAV EQU   0                                                        01271000
ZSAFSVVR EQU   ISTZFSAV+12                                              01272000
ZSAFSV19 EQU   ISTZFSAV+40                                              01273000
ISTZ19SV EQU   0                                                        01274000
ZSAF19FG EQU   ISTZ19SV                                                 01275000
ZSAFLOCK EQU   ZSAF19FG                                                 01276000
FRWD0008 EQU   0                                                        01277000
WRD00008 EQU   FRWD0008                                                 01278000
WRD10008 EQU   FRWD0008+4                                               01279000
ISTAPC38 EQU   0                                                        01280000
ISTBPENT EQU   0                                                        01281000
BPEFLAGS EQU   ISTBPENT+4                                               01282000
ISTBPDTY EQU   0                                                        01283000
BPDHDR   EQU   ISTBPDTY                                                 01284000
BPDCHPCB EQU   BPDHDR+8                                                 01285000
BPDFLAG  EQU   BPDHDR+40                                                01286000
BPDPARM  EQU   BPDHDR+48                                                01287000
BPDTRACE EQU   BPDHDR+56                                                01288000
FMZL0024 EQU   0                                                        01289000
ISTAPC37 EQU   0                                                        01290000
ISTAPC34 EQU   0                                                        01291000
IOBORG01 EQU   IOBPREFX+8                                               01328000
IOBNIOBA EQU   IOBORG01                                                 01329000
IOBNFLG1 EQU   IOBNIOBA                                                 01330000
IOBPRTOV EQU   IOBNFLG1                                                 01331000
IOBORG02 EQU   IOBPREFX+8                                               01332000
IOBDQADA EQU   IOBORG02                                                 01333000
IOBDEQIN EQU   IOBDQADA                                                 01334000
IOBORG03 EQU   IOBPREFX+12                                              01335000
IOBORG04 EQU   IOBINCAM                                                 01336000
IOBORG12 EQU   IOBINCAM                                                 01337000
IOBFL4   EQU   IOBORG12                                                 01338000
IOBEXTEN EQU   IOBSTDRD+32                                              01339000
IOBSEEK  EQU   IOBEXTEN                                                 01340000
IOBBB    EQU   IOBSEEK+1                                                01341000
IOBCC    EQU   IOBSEEK+3                                                01342000
IOBHH    EQU   IOBSEEK+5                                                01343000
IOBORG05 EQU   IOBEXTEN                                                 01344000
IOBORG06 EQU   IOBEXTEN                                                 01345000
IOBNXTPT EQU   IOBORG06+4                                               01346000
IOBSTATA EQU   IOBNXTPT                                                 01347000
IOBORG07 EQU   IOBEXTEN+8                                               01348000
W1IEXTEN EQU   IOBORG07                                                 01349000
IOBORG08 EQU   IOBEXTEN+8                                               01350000
IOBINDCT EQU   IOBORG08+4                                               01351000
IOBUNSQR EQU   IOBORG08+5                                               01352000
IOBFCHAD EQU   IOBORG08+8                                               01353000
IOBORG09 EQU   IOBEXTEN+8                                               01354000
IOBDPLAD EQU   IOBORG09+4                                               01355000
IOBDTYPE EQU   IOBORG09+8                                               01356000
IOBDTYP2 EQU   IOBORG09+9                                               01357000
IOBDSTAT EQU   IOBORG09+10                                              01358000
IOBSTAT1 EQU   IOBDSTAT                                                 01359000
IOBORG10 EQU   IOBEXTEN+8                                               01360000
IOBSEEK2 EQU   IOBORG10                                                 01361000
IOBORG11 EQU   IOBEXTEN                                                 01362000
IOBERCT  EQU   IOBORG11                                                 01363000
IOBUCBXV EQU   IOBERCT                                                  01364000
IOBNAME  EQU   IOBORG11+4                                               01365000
IOBORG13 EQU   IOBEXTEN                                                 01366000
IOBSKADR EQU   IOBORG13                                                 01367000
ISTZATWA EQU   IOSATTSN                                                 01386000
ZATZSAV1 EQU   ISTZATWA                                                 01387000
ZATZSAV2 EQU   ISTZATWA+16                                              01388000
FSBCOMBN EQU   FSBNETRS                                                 01389000
FSBRHFLD EQU   FSBCOMBN+1                                               01390000
FSBRH3   EQU   FSBRHFLD+2                                               01391000
FSBLDFLG EQU   FSBRH3                                                   01392000
ZLBBTRAN EQU   ISTZLBUF                                                 01394000
ZLBFDBZ  EQU   ZLBBTRAN                                                 01395000
ZLBAIO   EQU   ZLBBTRAN+16                                              01396000
ZLBDTIO  EQU   ZLBFSM                                                   01397000
ZLBCCW1  EQU   ZLBDTIO                                                  01398000
ZLBCCW2  EQU   ZLBDTIO+8                                                01399000
ZLBCCW3  EQU   ZLBDTIO+16                                               01400000
ZLBSNS   EQU   ZLBDTIO+28                                               01401000
ZLBERC   EQU   ZLBDTIO+29                                               01402000
ZLBCOMP  EQU   ZLBDTIO+31                                               01403000
ZLBSAF   EQU   ZLBDTIO+48                                               01404000
ZLBSTAT  EQU   ZLBSAF                                                   01405000
ZLBDEVST EQU   ZLBSTAT                                                  01406000
ZLBRQTG  EQU   ZLBDTIO+50                                               01407000
ZLBRQFLG EQU   ZLBRQTG                                                  01408000
ZLBFLAGS EQU   ZLBDTIO+56                                               01409000
ZLBTEXTA EQU   ZLBCCW3                                                  01410000
ZLBTEXTB EQU   ZLBFLAGS                                                 01411000
ZLBTEXT1 EQU   ZLBTEXTB                                                 01412000
ZLBTEXTC EQU   ZLBFLAGS                                                 01413000
ZLBPPL   EQU   ZLBTEXTC                                                 01414000
ZLBFAIO  EQU   ZLBAIO                                                   01415000
ZLBFSB   EQU   ZLBFAIO                                                  01416000
TSTPRC#  EQU   NCBOFFSA                                                 03691000
@RT00403 EQU   NCBOFFSA                                                 03693000
@RF00424 EQU   NCBOFFSA                                                 03694000
@ENDDATA EQU   *                                                        03695000
         END   ISTZFMAA                                         DSK1132 03696000
