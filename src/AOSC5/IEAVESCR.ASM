         TITLE 'IEAVESCR -- SCHEDULE RECOVERY ROUTINE                  *00001000
                       '                                                00002000
IEAVESCR CSECT ,                                                01S0001 00003000
@MAINENT DS    0H                                               01S0001 00004000
         USING *,R15                                            DSK1008 00005000
         B     @PROLOG                                          01S0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
         DC    AL1(16)                                          01S0001 00008000
         DC    C'IEAVESCR  73.263'                              01S0001 00009000
         DC    X'18'                         !!! SOURCE COMPARE FIX !!! 00010000
IEAVESQV DC    0H'0'                                            DSK1008 00010000
         USING *,R15                                            DSK1008 00011000
         B     @PROLOG                                          01S0001 00012000
         DC    AL2(@EP00056-IEAVESQV)                                   00013000
         ENTRY IEAVESQV                                                 00014000
         DROP  R15                                              DSK1008 00015000
@PROLOG  BALR  R12,0                                            DSK1008 00016000
@PSTART  DS    0H                                               01S0001 00017000
         USING @PSTART,R12                                      DSK1008 00018000
         AH    R15,4(,R15)                                      DSK1008 00019000
         BR    R15                                              DSK1008 00020000
@EP00001 DS    0H                                               01S0002 00021000
*                                                               01S0056 00022000
*/********************************************************************/ 00023000
*/*                                                                  */ 00024000
*/*     PURPOSE =                                                    */ 00025000
*/*           THIS SEGMENT CONTAINS THE TWO ENTRY POINTS TO THE      */ 00026000
*/*           MODULE.  THE RETURN ADDRESS IS SAVED, AND THE INTERNAL */ 00027000
*/*           SUBROUTINE, SRBQV, WHICH WILL HANDLE THE VERIFICATION  */ 00028000
*/*           OF THE SRB QUEUES, IS INVOKED.                         */ 00029000
*/*                                                                  */ 00030000
*/*     ENTRY POINT =                                                */ 00031000
*/*           IEAVESCR = MAIN ENTRY POINT                            */ 00032000
*/*           IEAVESQV = ENTRY USED BY THE PURGE DQ FRR              */ 00033000
*/*                                                                  */ 00034000
*/*     INPUT = (FOR BOTH ENTRIES)                                   */ 00035000
*/*          R0 = ADDRESS 200-BYTE WORK AREA                         */ 00036000
*/*          R1= ADDRESS SDWA                                        */ 00037000
*/*          R14= RETURN ADDRESS TO CALLER                           */ 00038000
*/*          R15= ENTRY POINT ADDRESS                                */ 00039000
*/*                                                                  */ 00040000
*/*     OUTPUT = (FOR BOTH ENTRIES)                                  */ 00041000
*/*          R2 = RETURN ADDRESS TO CALLER                           */ 00042000
*/*          ALL OTHER REGISTERS UNCHANGED                           */ 00043000
*/*                                                                  */ 00044000
*/********************************************************************/ 00045000
*                                                               01S0056 00046000
*IEAVESQV:                                                      01S0056 00047000
*   ENTRY;                          /* ENTRY FOR PURGE DQ FRR        */ 00048000
@EP00056 DS    0H                                               01S0057 00049000
*   RFY                                                         01S0057 00050000
*     RETADDR RSTD;                                             01S0057 00051000
*   R14SAV=RETADDR;                 /* SAVE RETURN ADDRESS           */ 00052000
         LR    R2,R14                                           DSK1008 00053000
*   RFY                                                         01S0059 00054000
*     RETADDR UNRSTD;                                           01S0059 00055000
*   CALL SRBQV;                     /* VERIFY ALL SYSTEM SRB QUEUES  */ 00056000
         BAL   R14,SRBQV                                        DSK1008 00057000
*SRBQV:                                                         01S0061 00058000
*   PROC OPTIONS(NOSAVE);                                       01S0061 00059000
*                                                               01S0061 00060000
         B     @EL00001                                         DSK1008 00061000
SRBQV    DS    0H                                               01S0062 00062000
*/********************************************************************/ 00063000
*/*                                                                  */ 00064000
*/*     PURPOSE = THIS SEGMENT INITIALIZES THE PARAMETER LIST FOR    */ 00065000
*/*          CALLS TO THE QUEUE VERIFIER.                            */ 00066000
*/*                                                                  */ 00067000
*/*     INPUT =                                                      */ 00068000
*/*           R0 = 200-BYTE WORK AREA                                */ 00069000
*/*           R1 = ADDRESS SDWA                                      */ 00070000
*/*           R2 = CALLER'S RETURN ADDRESS                           */ 00071000
*/*           R12= BASE REGISTER                                     */ 00072000
*/*                                                                  */ 00073000
*/*     OUTPUT =                                                     */ 00074000
*/*          R0 = ADDRESS SDWA                                       */ 00075000
*/*          R1 = ADDRESS QVPL                                       */ 00076000
*/*          R2 = RETURN ADDRESS TO CALLER                           */ 00077000
*/*          R5 = VOLITILE                                           */ 00078000
*/*          R11= IEAVESCR REG SAVE AREA (20 BYTES)                  */ 00079000
*/*          R13= ADDRESS 72-BYTE REGISTER SAVE AREA                 */ 00080000
*/*                                                                  */ 00081000
*/********************************************************************/ 00082000
*                                                               01S0062 00083000
*   RFY                                                         01S0062 00084000
*     RETADDR UNRSTD;                                           01S0062 00085000
*   RFY                                                         01S0063 00086000
*    (TEMPREG,                                                  01S0063 00087000
*     R14SAV,                                                   01S0063 00088000
*     R7,                                                       01S0063 00089000
*     R8,                                                       01S0063 00090000
*     R9,                                                       01S0063 00091000
*     R10,                                                      01S0063 00092000
*     PARMREG0,                                                 01S0063 00093000
*     PARMREG1,                                                 01S0063 00094000
*     SDWAPTR)RSTD;                 /* INITIALIZATION FOR IEAVEEER   */ 00095000
*   SDWAPTR=PARMREG1;               /* SAVE SDWA POINTER             */ 00096000
         LR    R5,R1                                            DSK1008 00097000
*   QVPLPTR=PARMREG0;               /* REG 1 = ADDR QVPL             */ 00098000
         LR    R1,R0                                            DSK1008 00099000
*   QVPL='00'X;                     /* ZERO THE QVPL                 */ 00100000
         XC    QVPL+1-QVPL(39,R1),QVPL+1-QVPL(R1)               DSK1008 00101000
         MVI   QVPL-QVPL(R1),X'00'                              DSK1008 00102000
*   SDWAADR=SDWAPTR;                /* RESET REG 0 = ADDR SDWA       */ 00103000
         LR    R0,R5                                            DSK1008 00104000
*   RFY                                                         01S0068 00105000
*     TEMPREG UNRSTD;                                           01S0068 00106000
*   QVPLODA=ADDR(SDWARA);           /* ADDR QUEUE VERIFY WORK AREA   */ 00107000
         LA    R6,SDWARA-SDWA(,R5)                              DSK1008 00108000
         ST    R6,QVPLODA-QVPL(,R1)                             DSK1008 00109000
*   QVPLWKA=QVPLPTR+LENGTH(QVPL);   /* SET UP WORK AREA AT END QVPL  */ 00110000
         LA    R6,40                                            DSK1008 00111000
         LR    R4,R1                                            DSK1008 00112000
         AR    R4,R6                                            DSK1008 00113000
         ST    R4,QVPLWKA-QVPL(,R1)                             DSK1008 00114000
*   QVSAPTR=QVPLWKA+40;             /* ADDR 72 BYTE REG SAVE AREA    */ 00115000
         AR    R4,R6                                            DSK1008 00116000
         LR    R13,R4                                           DSK1008 00117000
*   SAVEPTR=QVSAPTR+72;             /* IEAVESCR SAVE AREA            */ 00118000
         LA    R11,72                                           DSK1008 00119000
         AR    R11,R13                                          DSK1008 00120000
*   SCRR14=R14SAV;                  /* SAVE RETURN ADDRESS           */ 00121000
         ST    R2,SCRR14(,R11)                                  DSK1008 00122000
*   RFY                                                         01S0074 00123000
*     R14SAV UNRSTD;                                            01S0074 00124000
*   SCRR7=R7;                       /* SAVE REG 7                    */ 00125000
         ST    R7,SCRR7(,R11)                                   DSK1008 00126000
*   SCRR8=R8;                       /* SAVE REG 8                    */ 00127000
         ST    R8,SCRR8(,R11)                                   DSK1008 00128000
*   SCRR9=R9;                       /* SAVE REG 9                    */ 00129000
         ST    R9,SCRR9(,R11)                                   DSK1008 00130000
*   SCRR10=R10;                     /* SAVE REG 10                   */ 00131000
         ST    R10,SCRR10(,R11)                                 DSK1008 00132000
*   RFY                                                         01S0079 00133000
*    (SDWAPTR,                                                  01S0079 00134000
*     R7,                                                       01S0079 00135000
*     R8,                                                       01S0079 00136000
*     R9,                                                       01S0079 00137000
*     R10,                                                      01S0079 00138000
*     PARMREG0,                                                 01S0079 00139000
*     PARMREG1)UNRSTD;                                          01S0079 00140000
*   QVPLEVR=ADDR(IEAVESRB);         /* SRB ELEMENT VERIFICAT'N RTN   */ 00141000
         L     R10,@CA01703                                     DSK1008 00142000
         ST    R10,QVPLEVR-QVPL(,R1)                            DSK1008 00143000
*   QVPLFPTR=ADDR(SRBFLNK)-ADDR(SRB);/* OFFSET IN SRB OF CHAIN FIELD */ 00144000
         LA    R10,SRBFLNK-SRB(,R1)                             DSK1008 00145000
         SR    R10,R1                                           DSK1008 00146000
         STH   R10,QVPLFPTR-QVPL(,R1)                           DSK1008 00147000
*   RFY                                                         01S0082 00148000
*     R14SAV UNRSTD;                                            01S0082 00149000
*                                                               01S0083 00150000
*/********************************************************************/ 00151000
*/*                                                                  */ 00152000
*/*     PURPOSE = TO VERIFY ANY SRB'S ON THE LCCA JOURNAL QUEUE BY   */ 00153000
*/*           INVOKING THE QUEUE VERIFICATION ROUTINE, AND TO        */ 00154000
*/*           RESCHEDULE ANY SRB'S REMAINING ON THE QUEUE.           */ 00155000
*/*                                                                  */ 00156000
*/*     INPUT =                                                      */ 00157000
*/*           R0 = ADDRESS 200-BYTE WORK AREA                        */ 00158000
*/*           R1 = ADDRESS SDWA                                      */ 00159000
*/*           R6 = ADDRESS LCCA                                      */ 00160000
*/*           R12= BASE REGISTER                                     */ 00161000
*/*                                                                  */ 00162000
*/*     OUTPUT =                                                     */ 00163000
*/*           R6-R8,R10,R14 AND R15 = VOLITILE                       */ 00164000
*/*           ALL OTHERS UNCHANGED                                   */ 00165000
*/*                                                                  */ 00166000
*/********************************************************************/ 00167000
*                                                               01S0083 00168000
*   RFY                                                         01S0083 00169000
*     LCCAPTR RSTD;                                             01S0083 00170000
*   LCCAPTR=PSALCCAV;               /* ESTABLISH BASE TO LCCA        */ 00171000
         L     R6,PSALCCAV-PSA                                  DSK1008 00172000
*   QVPLHDR=ADDR(LCCASMQJ);         /* SET HEADER = SRB JOURNAL      */ 00173000
         LA    R10,LCCASMQJ-LCCA(,R6)                           DSK1008 00174000
         ST    R10,QVPLHDR-QVPL(,R1)                            DSK1008 00175000
*   CALL IEAVEQV1;                  /* VERIFY THE SRB JOURNAL QUEUE  */ 00176000
         L     R15,@CV01700                                     DSK1008 00177000
         BALR  R14,R15                                          DSK1008 00178000
*                                   /* RESCHEDULE ANY SRBS ON QUEUE  */ 00179000
*   RFY                                                         01S0087 00180000
*    (R0SAVE,                                                   01S0087 00181000
*     R1SAVE,                                                   01S0087 00182000
*     SRBPTR,                                                   01S0087 00183000
*     R1,                                                       01S0087 00184000
*     R0,                                                       01S0087 00185000
*     LCCAPTR)RSTD;                                             01S0087 00186000
*   R0SAVE=R0;                      /* SAVE REG 0 AND REG 1 AS THEY  */ 00187000
         LR    R7,R0                                            DSK1008 00188000
*   R1SAVE=R1;                      /* ARE DESTROYED IN SCHEDULE     */ 00189000
         LR    R8,R1                                            DSK1008 00190000
*   DO WHILE LCCASMQJ^=0;           /* IF ANY SRBS ON JOURNAL QUEUE  */ 00191000
         B     @DE00090                                         01S0090 00192000
@DL00090 DS    0H                                               01S0091 00193000
*     SRBPTR=LCCASMQJ;              /* SCHEDULE TOP SRB IN JOURNAL   */ 00194000
         L     R1,LCCASMQJ-LCCA(,R6)                            DSK1008 00195000
*     LCCASMQJ=SRBFLNK;             /* GET NEXT SRB IN CHAIN AND     */ 00196000
         MVC   LCCASMQJ-LCCA(4,R6),SRBFLNK-SRB(R1)              DSK1008 00197000
*     GEN(SCHEDULE SRB=(1),SCOPE=LOCAL)                         01S0093 00198000
*     REFS(CVTPTR,CVT,SRBFLNK,SRBSECT,CVTLSMQ);/* ENTER IN JOURNAL AS   00199000
*                                      TOP SRB                       */ 00200000
         SCHEDULE SRB=(1),SCOPE=LOCAL                                   00201000
*   END;                                                        01S0094 00202000
@DE00090 ICM   R10,15,LCCASMQJ-LCCA(R6)                         DSK1008 00203000
         BNZ   @DL00090                                         01S0094 00204000
*   R0=R0SAVE;                      /* RESTORE REG 0 1ND REG 1       */ 00205000
         LR    R0,R7                                            DSK1008 00206000
*   R1=R1SAVE;                      /* DESTROYED DURING SCHEDULE     */ 00207000
         LR    R1,R8                                            DSK1008 00208000
*   RFY                                                         01S0097 00209000
*    (R0SAVE,                                                   01S0097 00210000
*     R1SAVE,                                                   01S0097 00211000
*     SRBPTR,                                                   01S0097 00212000
*     R1,                                                       01S0097 00213000
*     R0)UNRSTD;                                                01S0097 00214000
*                                                               01S0098 00215000
*/********************************************************************/ 00216000
*/*                                                                  */ 00217000
*/*     PURPOSE = VERIFY THE GLOBAL SPL FOR EACH ADDRESS SPACE       */ 00218000
*/*          FOR WHICH AN ASID IS ASSIGNED.                          */ 00219000
*/*                                                                  */ 00220000
*/*     INPUT =                                                      */ 00221000
*/*           R1 = QUEUE VERIFICATION PARM LIST                      */ 00222000
*/*           R12= BASE REGISTER                                     */ 00223000
*/*                                                                  */ 00224000
*/*     OUTPUT =                                                     */ 00225000
*/*           R2 = ADDRESS CVT                                       */ 00226000
*/*           R3, R10, R14 AND R15 = VOLITILE                        */ 00227000
*/*           ALL OTHER REGISTERS UNCHANGED                          */ 00228000
*/*                                                                  */ 00229000
*/********************************************************************/ 00230000
*                                                               01S0098 00231000
*   RFY                                                         01S0098 00232000
*     LCCAPTR UNRSTD;                                           01S0098 00233000
*   RFY                                                         01S0099 00234000
*     CVTMAP BASED(CVTBASE);                                    01S0099 00235000
*   RFY                                                         01S0100 00236000
*     CVTBASE RSTD;                                             01S0100 00237000
*   CVTBASE=CVTPTR;                 /* SET UP BASE TO CVT            */ 00238000
         L     R2,CVTPTR                                        DSK1008 00239000
*   DO QVPLHDR=CVTGSPL TO CVTGSPL+LENGTH(GSPL)-LENGTH(SPLENTRY)BY       00240000
*         LENGTH(SPLENTRY);         /* SET UP FOR GSPL QUEUE VERIFY  */ 00241000
         L     R10,CVTGSPL-CVT(,R2)                             DSK1008 00242000
         ST    R10,QVPLHDR-QVPL(,R1)                            DSK1008 00243000
         B     @DE00102                                         01S0102 00244000
@DL00102 DS    0H                                               01S0103 00245000
*     QVPLTRLR=QVPLHDR+4;           /* GLOBAL SPL TRAILER FIELD      */ 00246000
         LA    R10,4                                            DSK1008 00247000
         A     R10,QVPLHDR-QVPL(,R1)                            DSK1008 00248000
         ST    R10,QVPLTRLR-QVPL(,R1)                           DSK1008 00249000
*     CALL IEAVEQV2;                /* VERIFY GLOBAL SPL QUEUE       */ 00250000
         L     R15,@CV01701                                     DSK1008 00251000
         BALR  R14,R15                                          DSK1008 00252000
*                                   /* GET NEXT ENTRY IN GLOBAL SPL  */ 00253000
*   END;                                                        01S0105 00254000
         LA    R10,8                                            DSK1008 00255000
         A     R10,QVPLHDR-QVPL(,R1)                            DSK1008 00256000
         ST    R10,QVPLHDR-QVPL(,R1)                            DSK1008 00257000
@DE00102 L     R3,CVTGSPL-CVT(,R2)                              DSK1008 00258000
         SH    R3,@CH01727                                      DSK1008 00259000
         CR    R10,R3                                           DSK1008 00260000
         BNH   @DL00102                                         01S0105 00261000
*                                                               01S0106 00262000
*/********************************************************************/ 00263000
*/*                                                                  */ 00264000
*/*     PURPOSE = VERIFY THE LOCAL SPL FOR EACH ADDRESS SPACE        */ 00265000
*/*          FOR WHICH AN ASID IS ASSIGNED.                          */ 00266000
*/*                                                                  */ 00267000
*/*     INPUT =                                                      */ 00268000
*/*           R2 = ADDRESS CVT                                       */ 00269000
*/*           R12= BASE REGISTER                                     */ 00270000
*/*                                                                  */ 00271000
*/*     OUTPUT =                                                     */ 00272000
*/*           R2-R10, R14 AND R15 = VOLITILE                         */ 00273000
*/*           ALL OTHER REGISTERS UNCHANGED                          */ 00274000
*/*                                                                  */ 00275000
*/********************************************************************/ 00276000
*                                                               01S0106 00277000
*   RFY                                                         01S0106 00278000
*    (ASIDCTR,                                                  01S0106 00279000
*     ASVTPTR)RSTD;                                             01S0106 00280000
*   ASVTPTR=CVTASVT;                /* SET UP BASE TO ASVT           */ 00281000
         L     R9,CVTASVT-CVT(,R2)                              DSK1008 00282000
*                                   /* ASIDCTR IS SET ONCE TO        */ 00283000
*                                   /* ASVTMAXU, AND DECREMENTED     */ 00284000
*                                   /* EACH TIME THROUGH THE LOOP.   */ 00285000
*                                   /* THUS, THE LOOP EXECUTES       */ 00286000
*                                   /* ASVTMAXU TIMES. THE ASVT      */ 00287000
*                                   /* BASE POINTER IS INCREMENTED   */ 00288000
*                                   /* BY THE LENGTH OF ASVTENTY     */ 00289000
*                                   /* AT EACH ITERATION, SO THAT    */ 00290000
*                                   /* ASVTENTY SUCCESSIVELY         */ 00291000
*                                   /* ASSUMES ALL VALUES FOR EACH   */ 00292000
*                                   /* POSSIBLE ASID. IT MAY NOT     */ 00293000
*                                   /* BE ASSUMED THAT THE ASVTPTR   */ 00294000
*                                   /* EQUALS THE BEGINNING OF THE   */ 00295000
*                                   /* ASVT.                         */ 00296000
*   RFY                                                         01S0108 00297000
*     CVTBASE UNRSTD;                                           01S0108 00298000
*   DO ASIDCTR=ASVTMAXU TO 1 BY-1;  /* LOOP CHECKS EACH ASVT ENTRY   */ 00299000
         L     R10,ASVTMAXU-ASVT(,R9)                           DSK1008 00300000
         B     @DE00109                                         01S0109 00301000
@DL00109 DS    0H                                               01S0110 00302000
*     IF ASVTAVAL='0'B              /* CHECK IF ASID IS ASSIGNED     */ 00303000
*       THEN                        /* ASID IS ASSIGNED              */ 00304000
         TM    ASVTENTY-ASVT(R9),ASVTAVAL                       DSK1008 00305000
         BNZ   @RF00110                                         01S0110 00306000
*       DO;                         /* VERIFY THE ASCB ADDRESS       */ 00307000
*         RFY                                                   01S0112 00308000
*           R1SAVE RSTD;                                        01S0112 00309000
*         R1SAVE=QVPLPTR;           /* SAVE THE QVPL PTR             */ 00310000
         LR    R8,R1                                            DSK1008 00311000
*         PARMREG1=SDWAADR;         /* REG 1 = ADDR OF SDWA          */ 00312000
         LR    R1,R0                                            DSK1008 00313000
*         PARMREG0=ASVTENTY;        /* REG 0 = ENTRY IN ASVT         */ 00314000
         L     R0,ASVTENTY-ASVT(,R9)                            DSK1008 00315000
*         RFY                                                   01S0116 00316000
*           RETCODE RSTD;                                       01S0116 00317000
*         CALL IEAVEGAS;            /* ASCB CONTRL BLOCK VERIFY RTN  */ 00318000
         L     R15,@CV01702                                     DSK1008 00319000
         BALR  R14,R15                                          DSK1008 00320000
*         RFY                                                   01S0118 00321000
*           ASCBPTR RSTD;                                       01S0118 00322000
*         ASCBPTR=PARMREG0;         /* ESTABLISH BASE TO ASCB        */ 00323000
         LR    R4,R0                                            DSK1008 00324000
*         SDWAADR=PARMREG1;         /* SET UP R1 FOR QUEUE VERIF'N   */ 00325000
         LR    R0,R1                                            DSK1008 00326000
*         QVPLPTR=R1SAVE;           /* REG 0 = ADDR OF QVPL          */ 00327000
         LR    R1,R8                                            DSK1008 00328000
*         RFY                                                   01S0122 00329000
*           R1SAVE UNRSTD;                                      01S0122 00330000
*         IF RETCODE=0              /* CHECK RETURN CODE             */ 00331000
*           THEN                    /* ASCB IS VALID                 */ 00332000
         LTR   R15,R15                                          DSK1008 00333000
         BNZ   @RF00123                                         01S0123 00334000
*           DO;                                                 01S0124 00335000
*             RFY                                               01S0125 00336000
*               RETCODE UNRSTD;                                 01S0125 00337000
*             DO QVPLHDR=ASCBSPL TO ASCBSPL+LENGTH(LSPL)-LENGTH(        00338000
*                   SPLENTRY)BY LENGTH(SPLENTRY);/* QVPLHDR STILL IN    00339000
*                                      LOCAL SPL                     */ 00340000
         L     R8,ASCBSPL-ASCB(,R4)                             DSK1008 00341000
         ST    R8,QVPLHDR-QVPL(,R1)                             DSK1008 00342000
         B     @DE00126                                         01S0126 00343000
@DL00126 DS    0H                                               01S0127 00344000
*               QVPLTRLR=QVPLHDR+4; /* SET UP TRAILER FIELD          */ 00345000
         LA    R8,4                                             DSK1008 00346000
         A     R8,QVPLHDR-QVPL(,R1)                             DSK1008 00347000
         ST    R8,QVPLTRLR-QVPL(,R1)                            DSK1008 00348000
*               CALL IEAVEQV2;      /* VERIFY LOCAL SPL              */ 00349000
         L     R15,@CV01701                                     DSK1008 00350000
         BALR  R14,R15                                          DSK1008 00351000
*                                   /* GET NEXT ENTRY IN LOCAL SPL   */ 00352000
*             END;                                              01S0129 00353000
         LA    R8,8                                             DSK1008 00354000
         A     R8,QVPLHDR-QVPL(,R1)                             DSK1008 00355000
         ST    R8,QVPLHDR-QVPL(,R1)                             DSK1008 00356000
@DE00126 L     R5,ASCBSPL-ASCB(,R4)                             DSK1008 00357000
         SH    R5,@CH01727                                      DSK1008 00358000
         CR    R8,R5                                            DSK1008 00359000
         BNH   @DL00126                                         01S0129 00360000
*           END;                                                01S0130 00361000
*         ELSE                                                  01S0131 00362000
*           ;                       /* ASCB INVALID- GET NEXT ASCB   */ 00363000
@RF00123 DS    0H                                               01S0132 00364000
*       END;                                                    01S0132 00365000
*     ELSE                                                      01S0133 00366000
*       ;                           /* THE ASID IS NOT ASSIGNED      */ 00367000
@RF00110 DS    0H                                               01S0134 00368000
*     ASVTPTR=ASVTPTR+LENGTH(ASVTENTY);/* INCREMENT ASVT POINTER     */ 00369000
         AH    R9,@CH00036                                      DSK1008 00370000
*   END;                                                        01S0135 00371000
         BCTR  R10,0                                            DSK1008 00372000
@DE00109 LTR   R10,R10                                          DSK1008 00373000
         BP    @DL00109                                         01S0135 00374000
*   RFY                                                         01S0136 00375000
*    (ASIDCTR,                                                  01S0136 00376000
*     ASVTPTR)UNRSTD;                                           01S0136 00377000
*                                                               01S0137 00378000
*/********************************************************************/ 00379000
*/*                                                                  */ 00380000
*/*     PURPOSE = RECORD A BOUNDARY OF ZEROES IN SDWA                */ 00381000
*/*                                                                  */ 00382000
*/*     INPUT =                                                      */ 00383000
*/*           R0 = ADDRESS SDWA                                      */ 00384000
*/*           R12= BASE REGISTER                                     */ 00385000
*/*                                                                  */ 00386000
*/*     OUTPUT =                                                     */ 00387000
*/*           R3 AND R10 = VOLITILE                                  */ 00388000
*/*           R5 = ADDRESS SDWA                                      */ 00389000
*/*           ALL OTHER REGISTERS UNCHANGED                          */ 00390000
*/*                                                                  */ 00391000
*/********************************************************************/ 00392000
*                                                               01S0137 00393000
*   RFY                                                         01S0137 00394000
*    (TEMPREG,                                                  01S0137 00395000
*     SDWAPTR)RSTD;                                             01S0137 00396000
*   SDWAPTR=SDWAADR;                /* SET ADDRESSABILITY TO SDWA    */ 00397000
         LR    R5,R0                                            DSK1008 00398000
*   TEMPREG=SDWAURAL;               /* UPDATE USED BYTE COUNT        */ 00399000
         SR    R3,R3                                            DSK1008 00400000
         IC    R3,SDWAURAL-SDWA(,R5)                            DSK1008 00401000
*   TEMPREG=TEMPREG+4;                                          01S0140 00402000
         AH    R3,@CH00036                                      DSK1008 00403000
*   IF TEMPREG<=SDWAVRAL            /* CHECK IF SPACE IN RECORD      */ 00404000
*                                   /* STORE A WORD OF ZEROS TO      */ 00405000
*     THEN                          /* MARK END OF RECORDING INFO    */ 00406000
         SR    R10,R10                                          DSK1008 00407000
         ICM   R10,3,SDWAVRAL-SDWA(R5)                          DSK1008 00408000
         CR    R3,R10                                           DSK1008 00409000
         BH    @RF00141                                         01S0141 00410000
*     SDWAURAL=TEMPREG;             /* UPDATE SDWAURAL               */ 00411000
         STC   R3,SDWAURAL-SDWA(,R5)                            DSK1008 00412000
*   RFY                                                         01S0143 00413000
*     TEMPREG UNRSTD;                                           01S0143 00414000
@RF00141 DS    0H                                               01S0144 00415000
*                                                               01S0144 00416000
*/********************************************************************/ 00417000
*/*                                                                  */ 00418000
*/*     PURPOSE = RESTORE REGS 0,1,7-10 AND 14, AND RETURN TO CALLER */ 00419000
*/*                                                                  */ 00420000
*/*     INPUT =                                                      */ 00421000
*/*           R5 = ADDRESS SDWA                                      */ 00422000
*/*           R11= ADDRESS INTERNAL SAVE AREA                        */ 00423000
*/*           R12= BASE REGISTER                                     */ 00424000
*/*                                                                  */ 00425000
*/*     OUTPUT =                                                     */ 00426000
*/*           R0, R1, R7-R10 = RESTORED AS ENTERED                   */ 00427000
*/*                                                                  */ 00428000
*/********************************************************************/ 00429000
*                                                               01S0144 00430000
*   RFY                                                         01S0144 00431000
*    (R7,                                                       01S0144 00432000
*     R8,                                                       01S0144 00433000
*     R9,                                                       01S0144 00434000
*     R10,                                                      01S0144 00435000
*     PARMREG0,                                                 01S0144 00436000
*     PARMREG1)RSTD;                                            01S0144 00437000
*   R8=SCRR8;                       /* RESTORE REG 8 AS ENTERED      */ 00438000
         L     R8,SCRR8(,R11)                                   DSK1008 00439000
*   R9=SCRR9;                       /* RESTORE REG 9 AS ENTERED      */ 00440000
         L     R9,SCRR9(,R11)                                   DSK1008 00441000
*   R10=SCRR10;                     /* RESTORE REG10 AS ENTERED      */ 00442000
         L     R10,SCRR10(,R11)                                 DSK1008 00443000
*   PARMREG0=QVPLPTR;               /* REG 0 AS ENTERED = W.A. ADDR  */ 00444000
         LR    R0,R1                                            DSK1008 00445000
*   PARMREG1=SDWAPTR;               /* REG 1 AS ENTERED = SDWA ADDR  */ 00446000
         LR    R1,R5                                            DSK1008 00447000
*   R7=SCRR7;                       /* RESTORE REG 7 AS ENTERED      */ 00448000
         L     R7,SCRR7(,R11)                                   DSK1008 00449000
*   RFY                                                         01S0151 00450000
*     RETADDR RSTD;                                             01S0151 00451000
*   RETADDR=SCRR14;                 /* RESTORE CALLER'S RETURN ADDR  */ 00452000
         L     R14,SCRR14(,R11)                                 DSK1008 00453000
*   RETURN;                         /* RETURN TO CALLER              */ 00454000
@EL00002 DS    0H                                               01S0153 00455000
@EF00002 DS    0H                                               01S0153 00456000
@ER00002 BR    R14                                              DSK1008 00457000
*   END SRBQV;                                                  01S0154 00458000
*   END IEAVESCR                                                01S0155 00459000
*                                                               01S0155 00460000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00461000
*/*%INCLUDE SYSLIB  (IHALCCA )                                       */ 00462000
*/*%INCLUDE SYSLIB  (IHASDWA )                                       */ 00463000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00464000
*/*%INCLUDE SYSLIB  (IHASPL  )                                       */ 00465000
*/*%INCLUDE SYSLIB  (IHAASVT )                                       */ 00466000
*/*%INCLUDE SYSLIB  (IHAASCB )                                       */ 00467000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00468000
*/*%INCLUDE SYSLIB  (IHAQVPL )                                       */ 00469000
*/*%INCLUDE SYSLIB  (IHASRB  )                                       */ 00470000
*/*%INCLUDE SYSUT5  (PROLOG  )                                       */ 00471000
*/*%INCLUDE SYSUT5  (SCRFL1  )                                       */ 00472000
*/*%INCLUDE SYSUT5  (INITPL  )                                       */ 00473000
*/*%INCLUDE SYSUT5  (SCHEDSRB)                                       */ 00474000
*                                                               01S0155 00475000
*       ;                                                       01S0155 00476000
@EL00001 DS    0H                                               01S0155 00477000
@EF00001 DS    0H                                               01S0155 00478000
@ER00001 BR    R14                                              DSK1008 00479000
@DATA    DS    0H                                                       00480000
@CH01727 DC    H'-8'                                                    00481000
@CH00036 DC    H'4'                                                     00482000
@DATD    DSECT                                                          00483000
         DS    0F                                                       00484000
IEAVESCR CSECT                                                          00485000
         DC    X'E24B'                       !!! SOURCE COMPARE FIX !!! 00486000
         DC    0F'0'                                            DSK1008 00486000
@DATD    DSECT                                                          00487000
         DS    0D                                                       00488000
@ENDDATD EQU   *                                                        00489000
IEAVESCR CSECT                                                          00490000
         NOPR  ((@ENDDATD-@DATD)*16)                                    00491000
         DC    X'F1D9'                       !!! SOURCE COMPARE FIX !!! 00492000
         DC    0F'0'                                            DSK1008 00492000
@SIZDATD DC    AL1(0)                                                   00493000
         DC    AL3(@ENDDATD-@DATD)                                      00494000
@CV01700 DC    V(IEAVEQV1)                                              00495000
@CV01701 DC    V(IEAVEQV2)                                              00496000
@CV01702 DC    V(IEAVEGAS)                                              00497000
@CA01703 DC    A(IEAVESRB)                                              00498000
         DC    0D'0'                                            DSK1008 00499000
         CVT      DSECT=YES,LIST=YES                            DSK1008 00500000
         IHAASCB  ,                                             DSK1008 00500001
         IHAASVT  ,                                             DSK1008 00500002
         IHALCCA  ,                                             DSK1008 00500003
         IHAPSA   ,                                             DSK1008 00500004
         IHASDWA  ,                                             DSK1008 00500005
         IHASRB   ,                                             DSK1008 00500006
         IHAQVPL  ,                                             DSK1008 00500007
R0       EQU   0                       REGISTER 0               DSK1008 00500008
R1       EQU   1                       REGISTER 1               DSK1008 00500009
R2       EQU   2                       REGISTER 2               DSK1008 00500010
R3       EQU   3                       REGISTER 3               DSK1008 00500011
R4       EQU   4                       REGISTER 4               DSK1008 00500012
R5       EQU   5                       REGISTER 5               DSK1008 00500013
R6       EQU   6                       REGISTER 6               DSK1008 00500014
R7       EQU   7                       REGISTER 7               DSK1008 00500015
R8       EQU   8                       REGISTER 8               DSK1008 00500016
R9       EQU   9                       REGISTER 9               DSK1008 00500017
R10      EQU   10                      REGISTER 10              DSK1008 00500018
R11      EQU   11                      REGISTER 11              DSK1008 00500019
R12      EQU   12                      REGISTER 12              DSK1008 00500020
R13      EQU   13                      REGISTER 13              DSK1008 00500021
R14      EQU   14                      REGISTER 14              DSK1008 00500022
R15      EQU   15                      REGISTER 15              DSK1008 00500023
         EXTRN IEAVESRB                                                 00546000
SPLENTRY EQU   0                                                        00714000
GSPL     EQU   0                                                        00715000
GSPLNQ   EQU   GSPL                                                     00716000
GSPLSYS  EQU   GSPL+8                                                   00717000
LSPL     EQU   0                                                        00718000
LSPLNQ   EQU   LSPL                                                     00719000
LSPLSYS  EQU   LSPL+8                                                   00720000
SCRSA    EQU   0                                                        00753000
SCRR7    EQU   SCRSA                                                    00754000
SCRR8    EQU   SCRSA+4                                                  00755000
SCRR9    EQU   SCRSA+8                                                  00756000
SCRR10   EQU   SCRSA+12                                                 00757000
SCRR14   EQU   SCRSA+16                                                 00758000
*                                      START UNREFERENCED COMPONENTS    00780000
LSPLEND  EQU   LSPL+16                                                  01166000
LSPLSYSL EQU   LSPLSYS+4                                                01167000
LSPLSYSF EQU   LSPLSYS                                                  01168000
LSPLNQL  EQU   LSPLNQ+4                                                 01169000
LSPLNQF  EQU   LSPLNQ                                                   01170000
GSPLEND  EQU   GSPL+16                                                  01171000
GSPLSYSL EQU   GSPLSYS+4                                                01172000
GSPLSYSF EQU   GSPLSYS                                                  01173000
GSPLNQL  EQU   GSPLNQ+4                                                 01174000
GSPLNQF  EQU   GSPLNQ                                                   01175000
SPLLSRB  EQU   SPLENTRY+4                                               01176000
SPLFSRB  EQU   SPLENTRY                                                 01177000
*                                      END UNREFERENCED COMPONENTS      02157000
@ENDDATA EQU   *                                                        02159000
         END   IEAVESCR                                         DSK1008 02160000
