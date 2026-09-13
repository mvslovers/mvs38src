         TITLE 'IEAVEVRR-ASVT VERIFICATION AND RECONSTRUCTION ROUTINE  *00001000
                        '                                               00002000
IEAVEVRR CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK1009 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
         DC    AL1(16)                                             0001 00008000
         DC    C'IEAVEVRR  76.087'                                 0001 00009000
         DC    X'F0'                         !!! SOURCE COMPARE FIX !!! 00010000
IEAVVFRR DC    0H'0'                                            DSK1009 00010000
         USING *,R15                                            DSK1009 00011000
         B     @PROLOG                                             0001 00012000
         DC    AL2(@EP00109-IEAVVFRR)                                   00013000
         ENTRY IEAVVFRR                                                 00014000
ASCRVER  DS    0H                                                  0001 00015000
         USING *,R15                                            DSK1009 00016000
         B     @PROLOG                                             0001 00017000
         DC    AL2(@EP00169-ASCRVER)                                    00018000
         ENTRY ASCRVER                                                  00019000
         DROP  R15                                              DSK1009 00020000
@PROLOG  BALR  R7,0                                             DSK1009 00021000
@PSTART  DS    0H                                                  0001 00022000
         USING @PSTART,R7                                       DSK1009 00023000
         AH    R15,4(,R15)                                      DSK1009 00024000
         BR    R15                                              DSK1009 00025000
@EP00001 DS    0H                                                  0002 00026000
*                              /* DETERMINE IF DISP LOCK HELD */        00027000
         SETLOCK TEST,TYPE=DISP,BRANCH=(NOTHELD,EXIT)                   00028000
*   CVTREG=CVTPTR;                  /* ADDRESS OF CVT        @ZA04120*/ 00029000
         L     R9,CVTPTR                                        DSK1009 00030000
*   ASVTPTR=CVTASVT;                /* GET ASVT POINTER              */ 00031000
         L     R10,CVTASVT-CVT(,R9)                             DSK1009 00032000
*   RFY                                                            0068 00033000
*     CVTREG UNRSTD;                                               0068 00034000
*   ENDASVT=ASVTMAXU;               /* MAX NO ENTRIES IN ASVT      0069 00035000
*                                                            @ZA04120*/ 00036000
         L     R8,ASVTMAXU-ASVT(,R10)                           DSK1009 00037000
*   ENDASVT=ADDR(ASVTENTY(ENDASVT));/* ADDRESS END OF TABLE  @ZA04120*/ 00038000
         LR    R12,R8                                           DSK1009 00039000
         SLA   R12,2                                            DSK1009 00040000
         LA    R12,ASVTENTY-ASVT-4(R12,R10)                     DSK1009 00041000
         LR    R8,R12                                           DSK1009 00042000
*   TOPASVT=ADDR(ASVTENTY(1));      /* FIRST SLOT IN TABLE   @ZA04120*/ 00043000
         LA    R4,ASVTENTY-ASVT(,R10)                           DSK1009 00044000
*   ENTYPTR1=TOPASVT;               /* START AT TOP OF TABLE @ZA04120*/ 00045000
         LR    R5,R4                                            DSK1009 00046000
*   DO WHILE ENTYPTR1<=ENDASVT;     /* SCAN THRU ENTIRE TABLE      0073 00047000
*                                                            @ZA04120*/ 00048000
         B     @DE00073                                            0073 00049000
@DL00073 DS    0H                                                  0074 00050000
*     RFY                                                          0074 00051000
*      (ASCBPTR) RSTD;              /*                       @ZA04120*/ 00052000
*     ASCBPTR=ENTYPTR1->MENTRY;     /* CONTENTS SLOT IN ASVT @ZA04120*/ 00053000
         L     R3,MENTRY(,R5)                                   DSK1009 00054000
*     GENERATE REFS(UNASIGND);                                     0076 00055000
*                                   /* IF ENTRY IS ASSIGNED   @ZA04120* 00056000
         LTR  R3,R3     CHECK FOR VALID ASCB ADDRESS            DSK1009 00057000
        BM  UNASIGND               ASCB NOT ASSIGNED    @ZA04120        00058000
*ASSIGNED:                                                         0077 00059000
*     ;                                                            0077 00060000
ASSIGNED DS    0H                                                  0078 00061000
*     RFY                                                          0078 00062000
*      (WRKREG) RSTD;               /*                       @ZA04120*/ 00063000
*     GENERATE REFS(WRKREG,ASCBPTR);                               0079 00064000
*                                         /* ADDRESS SHOULD BE FIXED */ 00065000
         LRA R6,0(R3)                                           DSK1009 00066000
*     BC(TRANSERR,ERRCOND);         /* TRANSLATION ERROR ISSUE SETFRR*/ 00067000
         BC    7,ERRCOND                                           0080 00068000
*     RESPECIFY                                                    0081 00069000
*      (WRKREG) UNRSTD;                                            0081 00070000
*     IF ASCBASCB^=CHARASCB         /* ACRONYM SHOULD BE IN ASCB     */ 00071000
*       THEN                                                       0082 00072000
         CLC   ASCBASCB-ASCB(4,R3),@CC01579                     DSK1009 00073000
         BE    @RF00082                                            0082 00074000
*       DO;                         /* IF NOT, THEN ERROR CONDITION  */ 00075000
*ERRCOND:                                                          0084 00076000
*         ;                                                        0084 00077000
ERRCOND  DS    0H                                                  0085 00078000
*         IF PARMPTR=0              /* SETFRR ALREADY BEEN ISSUED    */ 00079000
*           THEN                                                   0085 00080000
         LTR   R1,R1                                            DSK1009 00081000
         BNZ   @RF00085                                            0085 00082000
*           DO;                     /* NO, ISSUE SETFRR              */ 00083000
*             RESPECIFY                                            0087 00084000
*              (WRKREG,                                            0087 00085000
*               WRKREG9) RSTD;                                     0087 00086000
*             WRKREG9=ADDR(IEAVLKRR);/* SET UP ADDRESS OF ROUTER   0088 00087000
*                                      ROUTINE                       */ 00088000
         L     R9,@CV01583                                      DSK1009 00089000
*             GENERATE REFS(WRKREG9,PARMPTR,WRKREG,PSACSTK,PSA,FRRS,    00090000
*                 FRRSCURR,FRRSLAST,PSALSFCC,FRRSELEN,FRRSFRRA,FRRSENTR 00091000
*                 ,FRRSPARM);                                      0089 00092000
          SETFRR A,FRRAD=(R9),PARMAD=(R1),WRKREGS=(R6,R1),RELATED=(IEAV~00093000
               VFRR,IEAVVFRR)                                   DSK1009 00093001
*           END;                                                   0090 00095000
*         RESPECIFY                                                0091 00096000
*          (WRKREG,                                                0091 00097000
*           WRKREG9) UNRSTD;                                       0091 00098000
@RF00085 DS    0H                                                  0092 00099000
*         RESPECIFY                                                0092 00100000
*           RRRA BASED(PARMPTR);                                   0092 00101000
*         RRRAASVT=BITON;           /* INDICATE ASVT RTN TO GET    0093 00102000
*                                      CONTROL                       */ 00103000
         OI    RRRAASVT(R1),B'01000000'                         DSK1009 00104000
*         ENTYPTR1->AVENTRY=BITON;  /* IND AVAILABLE ENTRY   @ZA04120*/ 00105000
         OI    AVENTRY(R5),B'10000000'                          DSK1009 00106000
*         GOTO CKNEXT;              /* GO CHECK NEXT SLOT    @ZA04120*/ 00107000
         B     CKNEXT                                              0095 00108000
*       END;                                                       0096 00109000
*     RFY                                                          0097 00110000
*      (ENTYPTR2) RSTD;             /* VALIDATE UNASSIGNED ENTRY   0097 00111000
*                                                            @ZA04120*/ 00112000
@RF00082 DS    0H                                                  0098 00113000
*UNASIGND:                                                         0098 00114000
*     ENTYPTR2=ASCBPTR&'7FFFFFFF'X; /* STRIP HIGH BIT        @ZA04120*/ 00115000
UNASIGND LR    R6,R3                                            DSK1009 00116000
         N     R6,@CF01623                                      DSK1009 00117000
*     IF ENTYPTR1>ENDASVT×ENTYPTR1<TOPASVT/* CHECK STILL IN TABLE  0099 00118000
*                                                            @ZA07757*/ 00119000
*       THEN                                                       0099 00120000
         CR    R5,R8                                            DSK1009 00121000
         BH    ERRCOND                                          DSK1009 00122000
         CR    R5,R4                                            DSK1009 00123000
         BL    ERRCOND                                          DSK1009 00124000
*       GOTO ERRCOND;               /* ERROR -- NOT IN TABLE @ZA04120*/ 00125000
*     RFY                                                          0101 00126000
*      (ENTYPTR2) UNRSTD;                                          0101 00127000
*CKNEXT:                                                           0102 00128000
*     ENTYPTR1=ENTYPTR1+LENGTH(ASVTENTY);/* CHECK NEXT SLOT  @ZA04120*/ 00129000
CKNEXT   AH    R5,@CH00044                                      DSK1009 00130000
*   END;                                                           0103 00131000
@DE00073 CR    R5,R8                                            DSK1009 00132000
         BNH   @DL00073                                            0103 00133000
*EXIT:                                                             0104 00134000
*   ;                                                              0104 00135000
EXIT     DS    0H                                                  0105 00136000
*   GENERATE REFS(REG0,REG15,SAVPTR);                              0105 00137000
*                                       /* RESTORE RTM'S REGISTERS */   00138000
         LM  R0,R15,0(R13)                                      DSK1009 00139000
*   RETURN;                         /* RETURN TO RTM                 */ 00140000
@EL00001 DS    0H                                                  0106 00141000
@EF00001 DS    0H                                                  0106 00142000
@ER00001 BR    R14                                              DSK1009 00143000
*   RFY                                                            0107 00144000
*    (ASID,                                                        0107 00145000
*     ASVTPTR) UNRSTD;                                             0107 00146000
*   RFY                                                            0108 00147000
*    (ASVT) BASED(ASVTPTR);                                        0108 00148000
*                                                                  0109 00149000
*/*IEAVVFRR: E ASVT RECONSTRUCTION ROUTINE                           */ 00150000
*/*                                                                  */ 00151000
*/*            ASVT RECONSTRUCTION ROUTINE                           */ 00152000
*/*                                                                  */ 00153000
*                                                                  0109 00154000
*IEAVVFRR:                                                         0109 00155000
*   ENTRY;                          /* ASVT RECONSTRUCTION ROUTINE 0109 00156000
*                                      FRR                           */ 00157000
@EP00109 DS    0H                                                  0110 00158000
*/* D (NO,FRREXIT,YES,) IS DISPATCHER LOCK HELD?                     */ 00159000
*                                                                  0110 00160000
*   GENERATE REFS(FRREXIT);                                        0110 00161000
*                                                                  0110 00162000
*                         /* DETERMINE IF DISP LOCK HELD */             00163000
         SETLOCK TEST,TYPE=DISP,BRANCH=(NOTHELD,FRREXIT)                00164000
*/* P SET UP PARAMETER LIST FOR QUEUE VERIFICATION                   */ 00165000
*                                                                  0111 00166000
*   RFY                                                            0111 00167000
*    (R14,                                                         0111 00168000
*     R14SAVE,                                                     0111 00169000
*     QVPLPTR,                                                     0111 00170000
*     REG0,                                                        0111 00171000
*     SDWAPTR) RSTD;                                               0111 00172000
*   R14SAVE=R14;                    /* SAVE RETURN ADDRESS TO RTM  0112 00173000
*                                                            @ZA06218*/ 00174000
         LR    R2,R14                                           DSK1009 00175000
*   RFY                                                            0113 00176000
*    (R14) UNRSTD;                                                 0113 00177000
*   RFY                                                            0114 00178000
*    (ASVTPTR,                                                     0114 00179000
*     PARMPTR,                                                     0114 00180000
*     CVTREG) RSTD;                                                0114 00181000
*   SDWAPTR=PARMPTR;                /* ADDRESSABILITY TO SDWA      0115 00182000
*                                                            @ZA04120*/ 00183000
         LR    R5,R1                                            DSK1009 00184000
*   QVPLPTR=REG0;                   /* USE SDWA WORK AREA AS QVPL  0116 00185000
*                                                            @ZA04120*/ 00186000
         LR    R1,R0                                            DSK1009 00187000
*   QVPL=''B;                       /* ZERO THE QVPL         @ZA04120*/ 00188000
         XC    QVPL(40,R1),QVPL(R1)                             DSK1009 00189000
*   QVPLEVR=ADDR(ASCRVER);          /* ADDR ASCR VERIFICATION RTN  0118 00190000
*                                                            @ZA04120*/ 00191000
         L     R12,@CA01634                                     DSK1009 00192000
         ST    R12,QVPLEVR(,R1)                                 DSK1009 00193000
*   QVPLWKA=QVPLPTR+LENGTH(QVPL);   /* 40 BYTE WORK AREA     @ZA04120*/ 00194000
         LA    R12,40                                           DSK1009 00195000
         LR    R11,R1                                           DSK1009 00196000
         ALR   R11,R12                                          DSK1009 00197000
         ST    R11,QVPLWKA(,R1)                                 DSK1009 00198000
*   QVPLODA=ADDR(SDWAVRA);          /* OUTPUT DATA AREA      @ZA04120*/ 00199000
         LA    R6,SDWAVRA-SDWA(,R5)                             DSK1009 00200000
         ST    R6,QVPLODA(,R1)                                  DSK1009 00201000
*   SAVPTR=QVPLWKA+40;              /* 72 BYTE REG SAVE AREA @ZA04120*/ 00202000
         ALR   R11,R12                                          DSK1009 00203000
         LR    R13,R11                                          DSK1009 00204000
*   QVPLBPTR=4;                     /* OFFSET BACKWARD PTR   @ZA04120*/ 00205000
         MVC   QVPLBPTR(2,R1),@CH00044                          DSK1009 00206000
*   CVTREG=CVTPTR;                  /* ADDRESS OF CVT        @ZA04120*/ 00207000
         L     R9,CVTPTR                                        DSK1009 00208000
*   QVPLTRLR=ADDR(CVTASCRL);        /* ASCR TRAILER          @ZA04120*/ 00209000
         LA    R12,CVTASCRL-CVT(,R9)                            DSK1009 00210000
         ST    R12,QVPLTRLR(,R1)                                DSK1009 00211000
*   REG0=CVTASVT;                   /* ADDRESS OF ASVT       @ZA04120*/ 00212000
         L     R0,CVTASVT-CVT(,R9)                              DSK1009 00213000
*/*QVHEADER: L QUEUE VERIFIER-- PASS ASCR QUEUE                      */ 00214000
*                                                                  0126 00215000
*QVHEADER:                                                         0126 00216000
*   QVPLHDR=ADDR(CVTASCRF);         /* CREATED ASCB QUEUE HEADER   0126 00217000
*                                                            @ZA04120*/ 00218000
QVHEADER LA    R12,CVTASCRF-CVT(,R9)                            DSK1009 00219000
         ST    R12,QVPLHDR(,R1)                                 DSK1009 00220000
*   CALL IEAVEQV3;                  /* INVOKE QUEUE VERIFIER @ZA04120*/ 00221000
         L     R15,@CV01589                                     DSK1009 00222000
         BALR  R14,R15                                          DSK1009 00223000
*   RFY                                                            0128 00224000
*    (QVPLPTR,                                                     0128 00225000
*     PARMPTR) UNRSTD;                                             0128 00226000
*                                                                  0128 00227000
*/* D (NO,CHAINUP,YES,) ASCR QUEUE HEADER EMPTY?                     */ 00228000
*                                                                  0129 00229000
*   RFY                                                            0129 00230000
*    (ASVTPTR,                                                     0129 00231000
*     ENTYPTR1,                                                    0129 00232000
*     ENTYPTR2,                                                    0129 00233000
*     ENDASVT) RSTD;                                               0129 00234000
*   ASVTPTR=REG0;                   /* ADDRESSABILITY TO ASVT      0130 00235000
*                                                            @ZA04120*/ 00236000
         LR    R10,R0                                           DSK1009 00237000
*   ENDASVT=ADDR(ASVTENTY(ASVTMAXU));/* FIND END OF ASVT     @ZA04120*/ 00238000
         L     R12,ASVTMAXU-ASVT(,R10)                          DSK1009 00239000
         SLA   R12,2                                            DSK1009 00240000
         LA    R8,ASVTENTY-ASVT-4(R12,R10)                      DSK1009 00241000
*   IF CVTASCRF=NULL                /* IF ASCR QUEUE IS EMPTY, TRY TO   00242000
*                                      FIND AN ELEMENT       @ZA04120*/ 00243000
*     THEN                                                         0132 00244000
         ICM   R12,15,CVTASCRF-CVT(R9)                          DSK1009 00245000
         BNZ   @RF00132                                            0132 00246000
*     DO;                           /* TRY TO FIND QUEUE     @ZA04120*/ 00247000
*/* P FIND ASCR OF FIRST VALID ASCB IN ASVT                          */ 00248000
*                                                                  0134 00249000
*       ENTYPTR1=ADDR(ASVTENTY(2)); /* START AT TOP OF TABLE @ZA04120*/ 00250000
         LA    R5,ASVTENTY-ASVT+4(,R10)                         DSK1009 00251000
*       DO WHILE ENDASVT>=ENTYPTR1; /* SEARCH ENTIRE TABLE   @ZA04120*/ 00252000
         B     @DE00135                                            0135 00253000
@DL00135 DS    0H                                                  0136 00254000
*         ASCRPTR=ENTYPTR1->MENTRY; /* PICK NEXT SLOT        @ZA04120*/ 00255000
         L     R3,MENTRY(,R5)                                   DSK1009 00256000
*         IF ASCRPTR>NULL THEN      /* CHECK ENTRY IN USE    @ZA04120*/ 00257000
         LTR   R3,R3                                            DSK1009 00258000
         BNP   @RF00137                                            0137 00259000
*           DO;                     /* FIND ASSOC. ASCR ELEMENT    0138 00260000
*                                                            @ZA04120*/ 00261000
*             ASCRPTR=ASCRPTR+(LENGTH(ASCB)+LENGTH(LSPL));/*       0139 00262000
*                                      CALCULATE ASCR ADDRESS      0139 00263000
*                                                            @ZA04120*/ 00264000
         AH    R3,@CH01649                                      DSK1009 00265000
*/*                                                                  */ 00266000
*/* P CHAIN BACK THROUGH ASCR QUEUE TO HEADER                        */ 00267000
*/*                                                                  */ 00268000
*                                                                  0140 00269000
*             DO UNTIL ASCRPTR->ASCRBWDP=NULL;/* CHECK FOR FIRST ASCR   00270000
*                                      ELT                   @ZA04120*/ 00271000
@DL00140 DS    0H                                                  0141 00272000
*               ASCRPTR=ASCRPTR->ASCRBWDP;/* IF NOT FIRST,GET      0141 00273000
*                                      PREVIOUS ELEMENT      @ZA04120*/ 00274000
         L     R3,ASCRBWDP(,R3)                                 DSK1009 00275000
*             END;                                                 0142 00276000
*                                                                  0142 00277000
@DE00140 ICM   R12,15,ASCRBWDP(R3)                              DSK1009 00278000
         BNZ   @DL00140                                            0142 00279000
*/* P (,QVHEADER) CORRECT ASCR HEADER                                */ 00280000
*                                                                  0143 00281000
*             CVTASCRF=ASCRPTR;     /* REFRESH HEADER IN CVT @ZA04120*/ 00282000
         ST    R3,CVTASCRF-CVT(,R9)                             DSK1009 00283000
*             CALL IEAVEQV3;        /* TRY QUEUE VERIF. AGAIN      0144 00284000
*                                                            @ZA04120*/ 00285000
         L     R15,@CV01589                                     DSK1009 00286000
         BALR  R14,R15                                          DSK1009 00287000
*             GOTO CHAINUP;         /* CHAIN AVAILABLE SLOTS @ZA04120*/ 00288000
         B     CHAINUP                                             0145 00289000
*           END;                                                   0146 00290000
*         ELSE                                                     0147 00291000
*           ENTYPTR1=ENTYPTR1+LENGTH(ASVTENTY);/* SLOT AVAILABLE TRY    00292000
*                                      NEXT SLOT             @ZA04120*/ 00293000
@RF00137 AH    R5,@CH00044                                      DSK1009 00294000
*       END;                                                       0148 00295000
@DE00135 CR    R8,R5                                            DSK1009 00296000
         BNL   @DL00135                                            0148 00297000
*     END;                                                         0149 00298000
*   RFY                                                            0150 00299000
*     CVTREG UNRSTD;                                               0150 00300000
@RF00132 DS    0H                                                  0151 00301000
*   RFY                                                            0151 00302000
*    (REG0) UNRSTD;                                                0151 00303000
*                                                                  0151 00304000
*/*                                                                  */ 00305000
*/*CHAINUP: P RESET MASTER SLOT IN ASVT                              */ 00306000
*/*                                                                  */ 00307000
*                                                                  0152 00308000
*CHAINUP:                                                          0152 00309000
*   ASVTENTY(1)=ADDR(IEAMASCB);     /* RESET MASTER MEMORY   @ZA04120*/ 00310000
CHAINUP  L     R12,@CV01588                                     DSK1009 00311000
         ST    R12,ASVTENTY-ASVT(,R10)                          DSK1009 00312000
*/*                                                                  */ 00313000
*/* P START WITH ASVTFRST                                            */ 00314000
*/*                                                                  */ 00315000
*                                                                  0153 00316000
*   ENTYPTR1=ADDR(ASVTFRST);        /* CHAIN UP AVAILABLE ASID'S     */ 00317000
         LA    R5,ASVTFRST-ASVT(,R10)                           DSK1009 00318000
*   ENTYPTR2=ADDR(ASVTENTY(2));     /* START WITH FIRST SLOT @ZA04120*/ 00319000
         LA    R6,ASVTENTY-ASVT+4(,R10)                         DSK1009 00320000
*/*                                                                  */ 00321000
*/*CHAINLP: D (YES,,NO,VFRR6) STILL WITHIN TABLE?                    */ 00322000
*/*                                                                  */ 00323000
*                                                                  0155 00324000
*   DO WHILE ENDASVT>=ENTYPTR2;     /* SCAN ENTIRE ASVT      @ZA04120*/ 00325000
         B     @DE00155                                            0155 00326000
@DL00155 DS    0H                                                  0156 00327000
*/*                                                                  */ 00328000
*/* D (YES,,NO,VFRR5) ENTRY UNASSIGNED?                              */ 00329000
*/*                                                                  */ 00330000
*                                                                  0156 00331000
*     WRKREG9=ENTYPTR2->MENTRY;     /* GET ASVT ENTRY        @ZA04120*/ 00332000
         L     R9,MENTRY(,R6)                                   DSK1009 00333000
*     GENERATE REFS(VFRR5);                                        0157 00334000
*                                                                  0157 00335000
*                                /* IF ENTRY IS UNASSIGNED    @ZA04120* 00336000
        LTR  R9,R9    THEN CHAIN ENTRY TO AVAILABLE QUEUE       DSK1009 00337000
        BP  VFRR5                                                       00338000
*/*                                                                  */ 00339000
*/* P CHAIN ASVTENTY TO AVAILABLE QUEUE                              */ 00340000
*/*                                                                  */ 00341000
*                                                                  0158 00342000
*     ENTYPTR1->MENTRY=ENTYPTR2;    /* POINT TO NEXT AVAILABLE       */ 00343000
         ST    R6,MENTRY(,R5)                                   DSK1009 00344000
*     ENTYPTR1->AVENTRY=BITON;      /* INDICATE UNASSIGNED           */ 00345000
         OI    AVENTRY(R5),B'10000000'                          DSK1009 00346000
*     ENTYPTR1=ENTYPTR2;                                           0160 00347000
*                                                                  0160 00348000
         LR    R5,R6                                            DSK1009 00349000
*/*VFRR5: P (,CHAINLP) GET NEXT SLOT IN ASVT                         */ 00350000
*                                                                  0161 00351000
*VFRR5:                                                            0161 00352000
*     ENTYPTR2=ENTYPTR2+LENGTH(ASVTENTY);/* GET NEXT SLOT    @ZA04120*/ 00353000
VFRR5    AH    R6,@CH00044                                      DSK1009 00354000
*   END;                                                           0162 00355000
*                                                                  0162 00356000
@DE00155 CR    R8,R6                                            DSK1009 00357000
         BNL   @DL00155                                            0162 00358000
*/*VFRR6: P INDICATE LAST AVAILABLE ENTRY                            */ 00359000
*                                                                  0163 00360000
*   ENTYPTR1->MENTRY=0;             /* LAST AVAILABLE ENTRY HAS 0  0163 00361000
*                                      POINTER                       */ 00362000
         SLR   R12,R12                                          DSK1009 00363000
         ST    R12,MENTRY(,R5)                                  DSK1009 00364000
*   ENTYPTR1->AVENTRY=BITON;        /* INDICATE ENTRY UNASSIGNED     */ 00365000
         OI    AVENTRY(R5),B'10000000'                          DSK1009 00366000
*/*FRREXIT: R RETURN TO RTM                                          */ 00367000
*                                                                  0165 00368000
*   RFY                                                            0165 00369000
*    (R14) RSTD;                                                   0165 00370000
*   R14=R14SAVE;                    /* RESTORE RETURN ADDR TO RTM  0166 00371000
*                                                            @ZA06218*/ 00372000
         LR    R14,R2                                           DSK1009 00373000
*FRREXIT:                                                          0167 00374000
*   RETURN;                         /* RETURN TO CALLER              */ 00375000
         B     @EL00001                                            0167 00376000
*   RFY                                                            0168 00377000
*    (R14SAVE,                                                     0168 00378000
*     ASCRPTR,                                                     0168 00379000
*     ENTYPTR1,                                                    0168 00380000
*     ENDASVT,                                                     0168 00381000
*     ENTYPTR2) UNRSTD;                                            0168 00382000
*                                                                  0169 00383000
*/*ASCRVER: E ASCR VERIFICATION RTN                                  */ 00384000
*/* P ENTRY REGS: REG0=ASCR ELEMENT ADDRESS REG1=ASVT ADDRESS        */ 00385000
*                                                                  0169 00386000
*ASCRVER:                                                          0169 00387000
*   ENTRY;                                                         0169 00388000
@EP00169 DS    0H                                                  0170 00389000
*   RFY                                                            0170 00390000
*    (R8,                                                          0170 00391000
*     R9,                                                          0170 00392000
*     R10,                                                         0170 00393000
*     R11,                                                         0170 00394000
*     R12,                                                         0170 00395000
*     R13,                                                         0170 00396000
*     R14,                                                         0170 00397000
*     REG0,                                                        0170 00398000
*     RETCODE,                                                     0170 00399000
*     ASCBPTR,                                                     0170 00400000
*     WRKREG,                                                      0170 00401000
*     PARMPTR) RSTD;                                               0170 00402000
*   RFY                                                            0171 00403000
*    (ASVT) BASED(PARMPTR);                                        0171 00404000
*                                                                  0171 00405000
*/* P OBTAIN ASCB ADDR FOR INPUT ASCR                                */ 00406000
*                                                                  0172 00407000
*   ASCBPTR=REG0-(LENGTH(ASCB)+LENGTH(LSPL));/* CALCULATE ASCB ADDR     00408000
*                                                            @ZA04120*/ 00409000
         LR    R3,R0                                            DSK1009 00410000
         SH    R3,@CH01649                                      DSK1009 00411000
*/* D (YES,,NO,BADELMT) IS IT A VALID ASCB?                          */ 00412000
*                                                                  0173 00413000
*   GENERATE REFS(WRKREG,ASCBPTR);                                 0173 00414000
*                                         /* ADDRESS SHOULD BE FIXED */ 00415000
         LRA R6,0(R3)                                           DSK1009 00416000
*                                   /* YA02554                       */ 00417000
*   BC(TRANSERR,BADELMT);           /* TRANSLATION ERROR BAD ELEMENT */ 00418000
         BC    7,BADELMT                                           0174 00419000
*   RESPECIFY                                                      0175 00420000
*    (WRKREG) UNRSTD;                                              0175 00421000
*   IF ASCBASCB=CHARASCB            /* ACRONYM SHOULD BE IN ASCB   0176 00422000
*                                      YA02554                       */ 00423000
*     THEN                                                         0176 00424000
         CLC   ASCBASCB-ASCB(4,R3),@CC01579                     DSK1009 00425000
         BNE   @RF00176                                            0176 00426000
*     DO;                                                          0177 00427000
*       RFY                                                        0178 00428000
*        (ASID) RSTD;               /* YA02554                       */ 00429000
*       ASID=ASCBASID;              /* ASID THIS ASCR ELT    @ZA04120*/ 00430000
         SLR   R4,R4                                            DSK1009 00431000
         ICM   R4,3,ASCBASID-ASCB(R3)                           DSK1009 00432000
*/* D (YES,%SETRC,NO,) DOES ASVT ENTRY MATCH ASCB?                   */ 00433000
*                                                                  0180 00434000
*       IF ASVTENTY(ASID)^=ASCBPTR  /* CHECK THAT ASVT ENTRY CONTAINS   00435000
*                                      ASCB ADDR                     */ 00436000
*         THEN                      /* IF NOT, THEN                  */ 00437000
         LR    R6,R4                                            DSK1009 00438000
         SLA   R6,2                                             DSK1009 00439000
         C     R3,ASVTENTY-ASVT-4(R6,R1)                        DSK1009 00440000
         BE    @RF00180                                            0180 00441000
*/* P CORRECT ASVT                                                   */ 00442000
*                                                                  0181 00443000
*         DO;                                                      0181 00444000
*           ASVTENTY(ASID)=ASCBPTR; /* PUT ASCB ADDR IN ASVT ENTRY   */ 00445000
         ST    R3,ASVTENTY-ASVT-4(R6,R1)                        DSK1009 00446000
*           ASVTAVAL(ASID)=BITOFF;  /* INDICATE ENTRY ASSIGNED       */ 00447000
         ALR   R6,R1                                            DSK1009 00448000
         NI    ASVTENTY-ASVT-4(R6),255-ASVTAVAL                 DSK1009 00449000
*         END;                                                     0184 00450000
*                                                                  0184 00451000
*/*%SETRC: P (,%RET)  RETURN CODE = 0                                */ 00452000
*                                                                  0185 00453000
*       RETCODE=NULL;               /* SET RETURN CODE       @ZA04120*/ 00454000
@RF00180 SLR   R15,R15                                          DSK1009 00455000
*     END;                                                         0186 00456000
*   ELSE                                                           0187 00457000
*                                                                  0187 00458000
*/*BADELMT: P RETURN CODE = 8                                        */ 00459000
*                                                                  0187 00460000
*BADELMT:                                                          0187 00461000
*     RETCODE=8;                    /* FLAG BAD ELEMENT      @ZA04120*/ 00462000
         B     @EL00001                                         DSK1009 00463000
@RF00176 DS    0H                                                  0187 00464000
BADELMT  LA    R15,8                                            DSK1009 00465000
*   RFY                                                            0188 00466000
*    (ASCBPTR,                                                     0188 00467000
*     WRKREG,                                                      0188 00468000
*     ASID) UNRSTD;                                                0188 00469000
*                                                                  0188 00470000
*/*%RET: R RETURN TO QUEUE VERIFIER                                  */ 00471000
*                                                                  0189 00472000
*   RETURN;                         /* RETURN TO QUEUE VERIFIER      */ 00473000
         B     @EL00001                                            0189 00474000
*   END IEAVEVRR                                                   0190 00475000
*                                                                  0190 00476000
*/*IEAVEVRR: END ASVT RECONSTRUCT                                    */ 00477000
*/*                                                                  */ 00478000
*                                                                  0190 00479000
*                                                                  0190 00480000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00481000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00482000
*/*%INCLUDE SYSLIB  (IHAASVT )                                       */ 00483000
*/*%INCLUDE SYSLIB  (IHAASCB )                                       */ 00484000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00485000
*/*%INCLUDE SYSLIB  (IHASDWA )                                       */ 00486000
*/*%INCLUDE SYSLIB  (IHAFRRS )                                       */ 00487000
*/*%INCLUDE SYSLIB  (IHARRRA )                                       */ 00488000
*/*%INCLUDE SYSLIB  (IHASPL  )                                       */ 00489000
*/*%INCLUDE SYSLIB  (IHAQVPL )                                       */ 00490000
*                                                                  0190 00491000
*       ;                                                          0190 00492000
         B     @EL00001                                            0190 00493000
@DATA    DS    0H                                                       00494000
@CH00044 DC    H'4'                                                     00495000
@CH01649 DC    H'224'                                                   00496000
@DATD    DSECT                                                          00497000
         DS    0F                                                       00498000
IEAVEVRR CSECT                                                          00499000
         DC    0F'0'                                            DSK1009 00500000
@CF01623 DC    XL4'7FFFFFFF'                                            00501000
@DATD    DSECT                                                          00502000
         DS    0D                                                       00503000
FRRSPTR  DS    A                                                        00504000
FRREPTR  DS    A                                                        00505000
GSPLPTR  DS    A                                                        00506000
LSPLPTR  DS    A                                                        00507000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00508000
@ENDDATD EQU   *                                                        00509000
IEAVEVRR CSECT                                                          00510000
         DS    0F                                                       00511000
@SIZDATD DC    AL1(0)                                                   00512000
         DC    AL3(@ENDDATD-@DATD)                                      00513000
@CA01634 DC    A(ASCRVER)                                               00514000
@CV01583 DC    V(IEAVLKRR)                                              00515000
@CV01588 DC    V(IEAMASCB)                                              00516000
@CV01589 DC    V(IEAVEQV3)                                              00517000
         DS    0D                                                       00518000
@CC01579 DC    C'ASCB'                                                  00519000
         CVT      DSECT=YES,LIST=YES                            DSK1009 00520000
         IHAASCB  ,                                             DSK1009 00520001
         IHAASVT  ,                                             DSK1009 00520002
         IHAFRRS  ,                                             DSK1009 00520003
         IHAPSA   ,                                             DSK1009 00520004
         IHASDWA  ,                                             DSK1009 00520005
R0       EQU   0                       REGISTER 0               DSK1009 00520006
R1       EQU   1                       REGISTER 1               DSK1009 00520007
R2       EQU   2                       REGISTER 2               DSK1009 00520008
R3       EQU   3                       REGISTER 3               DSK1009 00520009
R4       EQU   4                       REGISTER 4               DSK1009 00520010
R5       EQU   5                       REGISTER 5               DSK1009 00520011
R6       EQU   6                       REGISTER 6               DSK1009 00520012
R7       EQU   7                       REGISTER 7               DSK1009 00520013
R8       EQU   8                       REGISTER 8               DSK1009 00520014
R9       EQU   9                       REGISTER 9               DSK1009 00520015
R10      EQU   10                      REGISTER 10              DSK1009 00520016
R11      EQU   11                      REGISTER 11              DSK1009 00520017
R12      EQU   12                      REGISTER 12              DSK1009 00520018
R13      EQU   13                      REGISTER 13              DSK1009 00520019
R14      EQU   14                      REGISTER 14              DSK1009 00520020
R15      EQU   15                      REGISTER 15              DSK1009 00520021
RRRA     EQU   0                                                        00743000
RRRASTAT EQU   RRRA                                                     00744000
RRRAFLG1 EQU   RRRASTAT                                                 00745000
RRRAASVT EQU   RRRAFLG1                                                 00746000
SPLENTRY EQU   0                                                        00747000
GSPL     EQU   0                                                        00748000
GSPLNQ   EQU   GSPL                                                     00749000
GSPLSYS  EQU   GSPL+8                                                   00750000
LSPL     EQU   0                                                        00751000
LSPLNQ   EQU   LSPL                                                     00752000
LSPLSYS  EQU   LSPL+8                                                   00753000
QVPL     EQU   0                                                        00754000
QVPLTYP3 EQU   QVPL                                                     00755000
QVPLTYP2 EQU   QVPLTYP3                                                 00756000
QVPLTYP1 EQU   QVPLTYP2                                                 00757000
QVPLEVR  EQU   QVPLTYP1                                                 00758000
QVPLODA  EQU   QVPLTYP1+4                                               00759000
QVPLWKA  EQU   QVPLTYP1+8                                               00760000
QVPLHDR  EQU   QVPLTYP1+16                                              00761000
QVPLHF   EQU   QVPLTYP1+20                                              00762000
QVPLFLGH EQU   QVPLHF                                                   00763000
QVPLFLGF EQU   QVPLHF+1                                                 00764000
QVPLTRLR EQU   QVPLTYP2+28                                              00765000
QVPLTB   EQU   QVPLTYP2+32                                              00766000
QVPLFLGT EQU   QVPLTB                                                   00767000
QVPLFLGB EQU   QVPLTB+1                                                 00768000
QVPLBPTR EQU   QVPLTB+2                                                 00769000
MENTRY   EQU   0                                                        00770000
AVENTRY  EQU   MENTRY                                                   00771000
ASCRLIST EQU   0                                                        00772000
ASCRBWDP EQU   ASCRLIST+4                                               00773000
FRREXIT  EQU   @EL00001                                                 02063000
@ENDDATA EQU   *                                                        02065000
         END   IEAVEVRR                                         DSK1009 02066000
