         TITLE 'IEAVEEER -- STAGE 3 EXIT EFFECTOR RECOVERY ROUTINE     *00001000
                        '                                               00002000
IEAVEEER CSECT ,                                                01S0001 00003000
@MAINENT DS    0H                                               01S0001 00004000
         USING *,R15                                            DSK1005 00005000
         B     @PROLOG                                          01S0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
         DC    AL1(16)                                          01S0001 00008000
         DC    C'IEAVEEER  73.285'                              01S0001 00009000
         DC    X'E2'                         !!! SOURCE COMPARE FIX !!! 00010000
IQEVER   DC    0H'0'                                            DSK1005 00010000
         USING *,R15                                            DSK1005 00011000
         B     @PROLOG                                          01S0001 00012000
         DC    AL2(@EP00124-IQEVER)                                     00013000
         ENTRY IQEVER                                                   00014000
RQEVER   DS    0H                                               01S0001 00015000
         USING *,R15                                            DSK1005 00016000
         B     @PROLOG                                          01S0001 00017000
         DC    AL2(@EP00153-RQEVER)                                     00018000
         ENTRY RQEVER                                                   00019000
SRBVER   DS    0H                                               01S0001 00020000
         USING *,R15                                            DSK1005 00021000
         B     @PROLOG                                          01S0001 00022000
         DC    AL2(@EP00180-SRBVER)                                     00023000
         ENTRY SRBVER                                                   00024000
         DROP  R15                                              DSK1005 00025000
@PROLOG  BALR  R5,0                                             DSK1005 00026000
@PSTART  DS    0H                                               01S0001 00027000
         USING @PSTART,R5                                       DSK1005 00028000
         AH    R15,4(,R15)                                      DSK1005 00029000
         BR    R15                                              DSK1005 00030000
@EP00001 DS    0H                                               01S0002 00031000
*   RETADDR=R14;                    /* SAVE RETURN ADDRESS           */ 00039000
         LR    R6,R14                                           DSK1005 00040000
*   RFY                                                         02S0067 00041000
*     R14 UNRSTD;                                               02S0067 00042000
*   R7SAVE=R7;                      /* SAVE REG 7                    */ 00043000
         LR    R11,R7                                           DSK1005 00044000
*   RFY                                                         02S0069 00045000
*     R7 UNRSTD;                                                02S0069 00046000
*                                   /* INITIALIZATION FOR IEAVEEER   */ 00047000
*/********************************************************************/ 00048000
*/*                                                                  */ 00049000
*/*     PURPOSE = THIS SEGMENT PERFORMS INITIALIZATION FOR THE       */ 00050000
*/*           EXIT EFFECTOR RECOVERY MODULE.                         */ 00051000
*/*                                                                  */ 00052000
*/*     INPUT =                                                      */ 00053000
*/*           R0 = ADDRESS 200-BYTE WORK AREA                        */ 00054000
*/*           R1 = ADDRESS SDWA                                      */ 00055000
*/*           R5 = BASE REGISTER                                     */ 00056000
*/*                                                                  */ 00057000
*/*     OUTPUT =                                                     */ 00058000
*/*           R0 = ADDRESS SDWA                                      */ 00059000
*/*           R1 = ADDRESS QVPL                                      */ 00060000
*/*           R7 = ADDRESS OF SDWA                                   */ 00061000
*/*           R13= 72-BYTE REGISTER SAVE AREA                        */ 00062000
*/*                                                                  */ 00063000
*/********************************************************************/ 00064000
*                                                               02S0070 00065000
*   SDWAPTR=PARMREG1;               /* SAVE SDWA POINTER             */ 00066000
         LR    R7,R1                                            DSK1005 00067000
*   QVPLPTR=PARMREG0;               /* REG 1 = ADDR QVPL             */ 00068000
         LR    R1,R0                                            DSK1005 00069000
*   QVPL='00'X;                     /* ZERO THE QVPL                 */ 00070000
         XC    QVPL+1(39,R1),QVPL+1(R1)                         DSK1005 00071000
         MVI   QVPL(R1),X'00'                                   DSK1005 00072000
*   SDWAADR=SDWAPTR;                /* RESET REG 0 = ADDR SDWA       */ 00073000
         LR    R0,R7                                            DSK1005 00074000
*   QVPLODA=ADDR(SDWARA);           /* QUEUE VERIFY OUTPUT IN SDWA   */ 00075000
         LA    R15,SDWARA-SDWA(,R7)                             DSK1005 00076000
         ST    R15,QVPLODA(,R1)                                 DSK1005 00077000
*   QVPLWKA=QVPLPTR+LENGTH(QVPL);   /* ADDR QUEUE VERIFY WORK AREA   */ 00078000
         LA    R15,40                                           DSK1005 00079000
         LR    R14,R1                                           DSK1005 00080000
         ALR   R14,R15                                          DSK1005 00081000
         ST    R14,QVPLWKA(,R1)                                 DSK1005 00082000
*   SAVEPTR=QVPLWKA+40;             /* ADDR 72 BYTE REG SAVE AREA       00083000
*                                                                    */ 00084000
         ALR   R14,R15                                          DSK1005 00085000
         LR    R13,R14                                          DSK1005 00086000
*                                                               02S0077 00087000
*/********************************************************************/ 00088000
*/*                                                                  */ 00089000
*/*     PURPOSE = VERIFY IQE QUEUE AND STORE A WORD OF ZEROS IN THE  */ 00090000
*/*           SDWA RECORDING AREA TO MARK THE END OF IQE             */ 00091000
*/*           VERIFICATION.                                          */ 00092000
*/*                                                                  */ 00093000
*/*     INPUT =                                                      */ 00094000
*/*           R0 = ADDRESS SDWA                                      */ 00095000
*/*           R1 = ADDRESS QVPL                                      */ 00096000
*/*           R5 = BASE REGISTER                                     */ 00097000
*/*           R7 = ADDRESS SDWA                                      */ 00098000
*/*           R13= 72-BYTE REG SAVE AREA                             */ 00099000
*/*                                                                  */ 00100000
*/*     OUTPUT =                                                     */ 00101000
*/*           R2-R4 = VOLITILE                                       */ 00102000
*/*           R12 = ADDRESS ASXB                                     */ 00103000
*/*           R14-R15 = VOLITILE                                     */ 00104000
*/*           ALL OTHER REGISTERS UNCHANGED                          */ 00105000
*/*                                                                  */ 00106000
*/********************************************************************/ 00107000
*                                                               02S0077 00108000
*   ASXBPTR=PSAAOLD->ASCBASXB;      /* ADDRESSABILITY TO ASXB        */ 00109000
         L     R15,PSAAOLD-PSA                                  DSK1005 00110000
         L     R12,ASCBASXB-ASCB(,R15)                          DSK1005 00111000
*   IQEPTR=ASXBFIQE;                /* FIRST IQE ON CHAIN            */ 00112000
         L     R4,ASXBFIQE-ASXB(,R12)                           DSK1005 00113000
*   QVPLHDR=ADDR(ASXBFIQE);         /* HEADER IQE CHAIN              */ 00114000
         LA    R15,ASXBFIQE-ASXB(,R12)                          DSK1005 00115000
         ST    R15,QVPLHDR(,R1)                                 DSK1005 00116000
*   QVPLTRLR=ADDR(ASXBLIQE);        /* TRAILER IQE CHAIN             */ 00117000
         LA    R15,ASXBLIQE-ASXB(,R12)                          DSK1005 00118000
         ST    R15,QVPLTRLR(,R1)                                DSK1005 00119000
*   QVPLFPTR=ADDR(IQELNK)-ADDR(IQESECT);/* OFFSET OF FORWARD POINTER */ 00120000
         LR    R15,R4                                           DSK1005 00121000
         SLR   R15,R4                                           DSK1005 00122000
         STH   R15,QVPLFPTR(,R1)                                DSK1005 00123000
*   QVPLFP3='1'B;                   /* FWD PTR = 3 BYTE FIELD        */ 00124000
         OI    QVPLFP3(R1),B'10000000'                          DSK1005 00125000
*   QVPLEVR=ADDR(IQEVER);           /* ADDR IQE VERIFICATION RTN     */ 00126000
         L     R15,@CA01630                                     DSK1005 00127000
         ST    R15,QVPLEVR(,R1)                                 DSK1005 00128000
*   CALL IEAVEQV2;                  /* QUEUE VERIFICATION ROUTINE    */ 00129000
         L     R15,@CV01625                                     DSK1005 00130000
         BALR  R14,R15                                          DSK1005 00131000
*   RFY                                                         02S0085 00132000
*     TEMPREG RSTD;                                             02S0085 00133000
*   TEMPREG=SDWAURAL;               /* GET USED BYTE COUNT           */ 00134000
         SLR   R3,R3                                            DSK1005 00135000
         IC    R3,SDWAURAL-SDWA(,R7)                            DSK1005 00136000
*   TEMPREG=TEMPREG+4;              /* UPDATE COUNT BY FOUR          */ 00137000
         AH    R3,@CH00070                                      DSK1005 00138000
*   IF TEMPREG<=SDWAVRAL            /* CHECK IF SPACE IN RECORD STORE   00139000
*                                      A WORD OF ZEROS TO MARK END OF   00140000
*                                      IQE VERIFICAT'N               */ 00141000
*     THEN                          /* INCREMENT USED BYTE COUNT     */ 00142000
         SLR   R2,R2                                            DSK1005 00143000
         ICM   R2,3,SDWAVRAL-SDWA(R7)                           DSK1005 00144000
         CR    R3,R2                                            DSK1005 00145000
         BH    @RF00088                                         02S0088 00146000
*     SDWAURAL=TEMPREG;             /* UPDATE SDWAURAL               */ 00147000
         STC   R3,SDWAURAL-SDWA(,R7)                            DSK1005 00148000
*   RFY                                                         02S0090 00149000
*     TEMPREG UNRSTD;                                           02S0090 00150000
@RF00088 DS    0H                                               02S0091 00151000
*                                                               02S0091 00152000
*/********************************************************************/ 00153000
*/*                                                                  */ 00154000
*/*     PURPOSE = VERIFY RQE QUEUE AND STORE A WORD OF ZEROS IN THE  */ 00155000
*/*           SDWA RECORDING AREA TO MARK THE END OF RQE             */ 00156000
*/*           VERIFICATION.                                          */ 00157000
*/*                                                                  */ 00158000
*/*     INPUT =                                                      */ 00159000
*/*           R0 = ADDRESS SDWA                                      */ 00160000
*/*           R1 = ADDRESS QVPL                                      */ 00161000
*/*           R5 = BASE REGISTER                                     */ 00162000
*/*           R7 = ADDRESS SDWA                                      */ 00163000
*/*           R12= ADDRESS ASXB                                      */ 00164000
*/*           R13= 72-BYTE REG SAVE AREA                             */ 00165000
*/*                                                                  */ 00166000
*/*     OUTPUT =                                                     */ 00167000
*/*           R2-R4 = VOLITILE                                       */ 00168000
*/*           R14-R15 = VOLITILE                                     */ 00169000
*/*           ALL OTHER REGISTERS UNCHANGED                          */ 00170000
*/*                                                                  */ 00171000
*/********************************************************************/ 00172000
*                                                               02S0091 00173000
*   RQEPTR=ASXBFRQE;                /* FIRST RQE ON CHAIN            */ 00174000
         L     R4,ASXBFRQE-ASXB(,R12)                           DSK1005 00175000
*   QVPLHDR=ADDR(ASXBFRQE);         /* HEADER RQE CHAIN              */ 00176000
         LA    R15,ASXBFRQE-ASXB(,R12)                          DSK1005 00177000
         ST    R15,QVPLHDR(,R1)                                 DSK1005 00178000
*   QVPLTRLR=ADDR(ASXBLRQE);        /* TRAILER RQE CHAIN             */ 00179000
         LA    R15,ASXBLRQE-ASXB(,R12)                          DSK1005 00180000
         ST    R15,QVPLTRLR(,R1)                                DSK1005 00181000
*   QVPLFPTR=ADDR(RQENRQE)-ADDR(RQE);/* OFFSET OF FORWARD POINTER    */ 00182000
         LA    R15,RQENRQE(,R4)                                 DSK1005 00183000
         SLR   R15,R4                                           DSK1005 00184000
         STH   R15,QVPLFPTR(,R1)                                DSK1005 00185000
*   QVPLFP3='0'B;                   /* FWD PTR = 4 BYTE FIELD        */ 00186000
         NI    QVPLFP3(R1),B'01111111'                          DSK1005 00187000
*   QVPLEVR=ADDR(RQEVER);           /* ADDR RQE VERIFICATION RTN     */ 00188000
         L     R15,@CA01632                                     DSK1005 00189000
         ST    R15,QVPLEVR(,R1)                                 DSK1005 00190000
*   CALL IEAVEQV2;                  /* QUEUE VERIFICATION ROUTINE    */ 00191000
         L     R15,@CV01625                                     DSK1005 00192000
         BALR  R14,R15                                          DSK1005 00193000
*   RFY                                                         02S0098 00194000
*     TEMPREG RSTD;                                             02S0098 00195000
*   TEMPREG=SDWAURAL;               /* GET USED BYTE COUNT           */ 00196000
         SLR   R3,R3                                            DSK1005 00197000
         IC    R3,SDWAURAL-SDWA(,R7)                            DSK1005 00198000
*   TEMPREG=TEMPREG+4;              /* UPDATE COUNT BY FOUR          */ 00199000
         AH    R3,@CH00070                                      DSK1005 00200000
*   IF TEMPREG<=SDWAVRAL            /* CHECK IF SPACE IN RECORD STORE   00201000
*                                      A WORD OF ZEROS TO MARK END OF   00202000
*                                      RQE VERIFICAT'N               */ 00203000
*     THEN                          /* INCREMENT USED BYTE COUNT     */ 00204000
         SLR   R2,R2                                            DSK1005 00205000
         ICM   R2,3,SDWAVRAL-SDWA(R7)                           DSK1005 00206000
         CR    R3,R2                                            DSK1005 00207000
         BH    @RF00101                                         02S0101 00208000
*     SDWAURAL=TEMPREG;             /* UPDATE SDWAURAL               */ 00209000
         STC   R3,SDWAURAL-SDWA(,R7)                            DSK1005 00210000
*   RFY                                                         02S0103 00211000
*     TEMPREG UNRSTD;                                           02S0103 00212000
@RF00101 DS    0H                                               02S0104 00213000
*                                                               02S0104 00214000
*/********************************************************************/ 00215000
*/*                                                                  */ 00216000
*/*     PURPOSE = VERIFY SRB QUEUE AND STORE A WORD OF ZEROS IN THE  */ 00217000
*/*           SDWA RECORDING AREA TO MARK THE END OF SRB             */ 00218000
*/*           VERIFICATION.                                          */ 00219000
*/*                                                                  */ 00220000
*/*     INPUT =                                                      */ 00221000
*/*           R0 = ADDRESS SDWA                                      */ 00222000
*/*           R1 = ADDRESS QVPL                                      */ 00223000
*/*           R5 = BASE REGISTER                                     */ 00224000
*/*           R7 = ADDRESS SDWA                                      */ 00225000
*/*           R12= ADDRESS ASXB                                      */ 00226000
*/*           R13= 72-BYTE REG SAVE AREA                             */ 00227000
*/*                                                                  */ 00228000
*/*                                                                  */ 00229000
*/*     OUTPUT =                                                     */ 00230000
*/*           R2-R4 = VOLITILE                                       */ 00231000
*/*           R14-R15 = VOLITILE                                     */ 00232000
*/*           ALL OTHERS UNCHANGED                                   */ 00233000
*/*                                                                  */ 00234000
*/********************************************************************/ 00235000
*                                                               02S0104 00236000
*   SRBPTR=ASXBFSRB;                /* FIRST SRB ON CHAIN            */ 00237000
         L     R4,ASXBFSRB-ASXB(,R12)                           DSK1005 00238000
*   QVPLHDR=ADDR(ASXBFSRB);         /* HEADER SRB CHAIN              */ 00239000
         LA    R15,ASXBFSRB-ASXB(,R12)                          DSK1005 00240000
         ST    R15,QVPLHDR(,R1)                                 DSK1005 00241000
*   QVPLTRLR=ADDR(ASXBLSRB);        /* TRAILER SRB CHAIN             */ 00242000
         LA    R15,ASXBLSRB-ASXB(,R12)                          DSK1005 00243000
         ST    R15,QVPLTRLR(,R1)                                DSK1005 00244000
*   QVPLFPTR=ADDR(SRBFLNK)-ADDR(SRB);/* OFFSET OF FORWARD POINTER    */ 00245000
         LA    R15,SRBFLNK-SRB(,R4)                             DSK1005 00246000
         SLR   R15,R4                                           DSK1005 00247000
         STH   R15,QVPLFPTR(,R1)                                DSK1005 00248000
*   QVPLFP3='0'B;                   /* FWD PTR = 4 BYTE FIELD        */ 00249000
         NI    QVPLFP3(R1),B'01111111'                          DSK1005 00250000
*   QVPLEVR=ADDR(SRBVER);           /* ADDR SRB VERIFICATION RTN     */ 00251000
         L     R15,@CA01633                                     DSK1005 00252000
         ST    R15,QVPLEVR(,R1)                                 DSK1005 00253000
*   CALL IEAVEQV2;                  /* QUEUE VERIFICATION ROUTINE    */ 00254000
         L     R15,@CV01625                                     DSK1005 00255000
         BALR  R14,R15                                          DSK1005 00256000
*   RFY                                                         02S0111 00257000
*     TEMPREG RSTD;                                             02S0111 00258000
*   TEMPREG=SDWAURAL;               /* GET USED BYTE COUNT           */ 00259000
         SLR   R3,R3                                            DSK1005 00260000
         IC    R3,SDWAURAL-SDWA(,R7)                            DSK1005 00261000
*   TEMPREG=TEMPREG+4;              /* UPDATE COUNT BY FOUR          */ 00262000
         AH    R3,@CH00070                                      DSK1005 00263000
*   IF TEMPREG<=SDWAVRAL            /* CHECK IF SPACE IN RECORD STORE   00264000
*                                      A WORD OF ZEROS TO MARK END OF   00265000
*                                      IQE VERIFICAT'N               */ 00266000
*     THEN                          /* INCREMENT USED BYTE COUNT     */ 00267000
         SLR   R2,R2                                            DSK1005 00268000
         ICM   R2,3,SDWAVRAL-SDWA(R7)                           DSK1005 00269000
         CR    R3,R2                                            DSK1005 00270000
         BH    @RF00114                                         02S0114 00271000
*     SDWAURAL=TEMPREG;             /* UPDATE SDWAURAL               */ 00272000
         STC   R3,SDWAURAL-SDWA(,R7)                            DSK1005 00273000
*   RFY                                                         02S0116 00274000
*     TEMPREG UNRSTD;                                           02S0116 00275000
@RF00114 DS    0H                                               02S0117 00276000
*                                                               02S0117 00277000
*/********************************************************************/ 00278000
*/*                                                                  */ 00279000
*/*     PURPOSE = RESTORE REGISTERS 0, 1 7-10 TO THEIR CONTENTS      */ 00280000
*/*           AS THE MODULE WAS ORIGINALLY ENTERED, AND RETURN       */ 00281000
*/*           TO THE CALLER.                                         */ 00282000
*/*                                                                  */ 00283000
*/*     INPUT =                                                      */ 00284000
*/*           R0 = ADDRESS SDWA                                      */ 00285000
*/*           R1 = ADDRESS QVPL                                      */ 00286000
*/*           R5 = BASE REGISTER                                     */ 00287000
*/*           R6 = RETURN ADDRESS TO CALLER                          */ 00288000
*/*           R7 = ADDRESS SDWA                                      */ 00289000
*/*           R8-R10 = UNCHANGED FROM WHEN MODULE WAS ENTERED        */ 00290000
*/*           R11= ORIGINAL CONTENTS R7                              */ 00291000
*/*                                                                  */ 00292000
*/*     OUTPUT =                                                     */ 00293000
*/*           R0 = ADDRESS 200 BYTE WORK AREA                        */ 00294000
*/*           R1 = ADDRESS SDWA                                      */ 00295000
*/*           R7-R10 = ORIGINAL CONTENTS AS UPON ENTRY               */ 00296000
*/*           R14= RETURN ADDRESS TO CALLER                          */ 00297000
*/*           ALL OTHER REGISTERS UNCHANGED                          */ 00298000
*/*                                                                  */ 00299000
*/********************************************************************/ 00300000
*                                                               02S0117 00301000
*   RFY                                                         02S0117 00302000
*    (R7,                                                       02S0117 00303000
*     R14,                                                      02S0117 00304000
*     PARMREG0,                                                 02S0117 00305000
*     PARMREG1) RSTD;                                           02S0117 00306000
*   PARMREG0=QVPLPTR;               /* RESTORE REG 0 AS ENTERED      */ 00307000
         LR    R0,R1                                            DSK1005 00308000
*   PARMREG1=SDWAPTR;               /* RESTORE REG 1 AS ENTERED      */ 00309000
         LR    R1,R7                                            DSK1005 00310000
*   R7=R7SAVE;                      /* RESTORE REG 7 AS ENTERED      */ 00311000
         LR    R7,R11                                           DSK1005 00312000
*   R14=RETADDR;                    /* PLACE RETURN ADDRESS IN R14   */ 00313000
         LR    R14,R6                                           DSK1005 00314000
*   RFY                                                         02S0122 00315000
*    (R7,                                                       02S0122 00316000
*     R14,                                                      02S0122 00317000
*     PARMREG0,                                                 02S0122 00318000
*     PARMREG1) UNRSTD;                                         02S0122 00319000
*   RETURN;                         /* RETURN TO CALLER         02S0123 00320000
*                                                                    */ 00321000
@EL00001 DS    0H                                               02S0123 00322000
@EF00001 DS    0H                                               02S0123 00323000
@ER00001 BR    R14                                              DSK1005 00324000
*                                                               02S0124 00325000
*/********************************************************************/ 00326000
*/*                                                                  */ 00327000
*/*     PURPOSE = IQE VERIFICATION SUBROUTINE.  IT'S FUNCTION IS TO  */ 00328000
*/*           DETERMINE WHETHER A PIECE OF STORAGE IS REALLY AN IQE  */ 00329000
*/*           OR NOT.  IT IS ENTERED AS A SUBROUTINE OF QUEUE VERI-  */ 00330000
*/*           FIER, WHEN IT IS THE PROCESS OF VERIFYING THE IQE QUEUE*/ 00331000
*/*                                                                  */ 00332000
*/*     INPUT =                                                      */ 00333000
*/*           R0 = THE VIRTUAL STORAGE ADDRESS TO BE VERIFIED        */ 00334000
*/*           R1 = THE ADDRESS OF THE SDWA                           */ 00335000
*/*           R14= RETURN ADDRESS TO CALLER                          */ 00336000
*/*           R15= ENTRY POINT ADDRESS OF RQEVER                     */ 00337000
*/*                                                                  */ 00338000
*/*      OUTPUT =                                                    */ 00339000
*/*           R0,R1,R8-R14 = UNCHANGED                               */ 00340000
*/*           R2-R7 = VOLITILE                                       */ 00341000
*/*           R15 = CONTAINS A RETURN CODE AS FOLLOWS:               */ 00342000
*/*                 0 = THE STORAGE IS AN IQE WITH GOOD DATA         */ 00343000
*/*                 8 = THE STORAGE DOES NOT CONTAIN AN IQE          */ 00344000
*/*                                                                  */ 00345000
*/********************************************************************/ 00346000
*                                                               02S0124 00347000
*IQEVER:                                                        02S0124 00348000
*   ENTRY;                                                      02S0124 00349000
@EP00124 DS    0H                                               02S0125 00350000
*   RFY                                                         02S0125 00351000
*     ASXBPTR UNRSTD;                                           02S0125 00352000
*   RFY                                                         02S0126 00353000
*    (ADDREG,                                                   02S0126 00354000
*     RETCODE,                                                  02S0126 00355000
*     R14) RSTD;                    /* IQE VERIFICATION ROUTINE      */ 00356000
*   RETADDR=R14;                    /* SAVE RETURN ADDRESS           */ 00357000
         LR    R6,R14                                           DSK1005 00358000
*   RFY                                                         02S0128 00359000
*     R14 UNRSTD;                                               02S0128 00360000
*   IQEPTR=PARMREG0;                /* SET UP BASE FOR IQE           */ 00361000
         LR    R4,R0                                            DSK1005 00362000
*   ADDREG=PARMREG0;                /* REG 2 = IQE ADDRESS           */ 00363000
         LR    R2,R0                                            DSK1005 00364000
*   LENREG=LENGTH(IQESECT);         /* REG 0 = LENGTH IQE            */ 00365000
         LA    R0,24                                            DSK1005 00366000
*   CALL IEAVEADV;                  /* ADDRESS VERIFICATION RTN      */ 00367000
         L     R15,@CV01626                                     DSK1005 00368000
         BALR  R14,R15                                          DSK1005 00369000
*   IF RETCODE=0                    /* CHECK RETURN CODE             */ 00370000
*     THEN                          /* IQE ADDRESS IS VALID          */ 00371000
         LTR   R15,R15                                          DSK1005 00372000
         BNZ   @RF00133                                         02S0133 00373000
*     DO;                           /* VERIFY ADDR IN IQETCB FIELD   */ 00374000
*       LENREG=LENGTH(TCB);         /* REG 0 = LENGTH TCB            */ 00375000
         LA    R0,296                                           DSK1005 00376000
*       RFY                                                     02S0136 00377000
*        (TCBPTR,                                               02S0136 00378000
*         RBSECPTR,                                             02S0136 00379000
*         RETCODE) RSTD;                                        02S0136 00380000
*       TCBPTR=IQETCB;              /* REG 2 = IQETCB                */ 00381000
         L     R2,IQETCB(,R4)                                   DSK1005 00382000
*       CALL IEAVEADV;              /* ADDFRESS VERIFICATION RTN     */ 00383000
         L     R15,@CV01626                                     DSK1005 00384000
         BALR  R14,R15                                          DSK1005 00385000
*       IF RETCODE=0                /* CHECK RETURN CODE             */ 00386000
*         THEN                      /* TCB ADDRESS IS VALID          */ 00387000
         LTR   R15,R15                                          DSK1005 00388000
         BNZ   @RC00133                                         DSK1005 00389000
*         DO;                       /* VERIFY ADDRESS OF IRB         */ 00390000
*           LENREG=ADDR(IRBLEN)-ADDR(RBPRFLNA);/* REG 0 = LENGTH IRB */ 00391000
         LA    R0,IRBLEN                                        DSK1005 00392000
         LA    R14,RBPRFXND-RBPRFXST                            DSK1005 00393000
         SLR   R0,R14                                           DSK1005 00394000
*           RBSECPTR=IQEIRBA;       /* REG 2 = CONTENTS IQEIRBA      */ 00395000
         SLR   R2,R2                                            DSK1005 00396000
         ICM   R2,7,IQEIRBA(R4)                                 DSK1005 00397000
*           CALL IEAVEADV;          /* ADDRESS VERIFICATION RTN      */ 00398000
         L     R15,@CV01626                                     DSK1005 00399000
         BALR  R14,R15                                          DSK1005 00400000
*         END;                                                  02S0144 00401000
*     END;                                                      02S0145 00402000
*   ELSE                                                        02S0146 00403000
*     ;                             /* ORIGINAL ADDRESS INVALID OR   */ 00404000
@RF00133 DS    0H                                               02S0147 00405000
*   IF RETCODE>0                    /* IF ANY FIELDS INVALID         */ 00406000
*     THEN                          /* SET RETURN CODE = 8 TO        */ 00407000
@RC00133 LTR   R15,R15                                          DSK1005 00408000
         BNP   @RF00147                                         02S0147 00409000
*     RETCODE=8;                    /* INDICATE STORAGE NOT AN IQE   */ 00410000
         LA    R15,8                                            DSK1005 00411000
*   PARMREG0=IQEPTR;                /* RESTORE REG 0 AS ENTERED      */ 00412000
@RF00147 LR    R0,R4                                            DSK1005 00413000
*   RFY                                                         02S0150 00414000
*     R14 RSTD;                                                 02S0150 00415000
*   R14=RETADDR;                    /* RESTORE RETURN ADDRESS        */ 00416000
         LR    R14,R6                                           DSK1005 00417000
*   RETURN;                         /* RETURN TO QUEUE VERIFY RTN       00418000
*                                                                    */ 00419000
         B     @EL00001                                         02S0152 00420000
*                                                               02S0153 00421000
*/********************************************************************/ 00422000
*/*                                                                  */ 00423000
*/*     PURPOSE = RQE VERIFICATION SUBROUTINE.  IT'S FUNCTION IS TO  */ 00424000
*/*           DETERMINE WHETHER A PIECE OF STORAGE IS REALLY AN RQE  */ 00425000
*/*           OR NOT.  IT IS ENTERED AS A SUBROUTINE OF QUEUE VERI-  */ 00426000
*/*           FIER, WHEN IT IS THE PROCESS OF VERIFYING THE RQE QUEUE*/ 00427000
*/*                                                                  */ 00428000
*/*     INPUT =                                                      */ 00429000
*/*           R0 = THE VIRTUAL STORAGE ADDRESS TO BE VERIFIED        */ 00430000
*/*           R1 = THE ADDRESS OF THE SDWA                           */ 00431000
*/*           R14= RETURN ADDRESS TO CALLER                          */ 00432000
*/*           R15= ENTRY POINT ADDRESS OF RQEVER                     */ 00433000
*/*                                                                  */ 00434000
*/*      OUTPUT =                                                    */ 00435000
*/*           R0,R1,R8-R14 = UNCHANGED                               */ 00436000
*/*           R2-R7 = VOLITILE                                       */ 00437000
*/*           R15 = CONTAINS A RETURN CODE AS FOLLOWS:               */ 00438000
*/*                 0 = THE STORAGE IS AN RQE WITH GOOD DATA         */ 00439000
*/*                 8 = THE STORAGE DOES NOT CONTAIN AN RQE          */ 00440000
*/*                                                                  */ 00441000
*/********************************************************************/ 00442000
*                                                               02S0153 00443000
*RQEVER:                                                        02S0153 00444000
*   ENTRY;                          /* RQE VERIFICATION ROUTINE      */ 00445000
@EP00153 DS    0H                                               02S0154 00446000
*   RETADDR=R14;                    /* SAVE RETURN ADDRESS           */ 00447000
         LR    R6,R14                                           DSK1005 00448000
*   RFY                                                         02S0155 00449000
*     R14 UNRSTD;                                               02S0155 00450000
*   RQEPTR=PARMREG0;                /* SET UP BASE FOR RQE           */ 00451000
         LR    R4,R0                                            DSK1005 00452000
*   ADDREG=PARMREG0;                /* REG 2 = IQE ADDRESS           */ 00453000
         LR    R2,R0                                            DSK1005 00454000
*   LENREG=LENGTH(RQE);             /* REG 0 = LENGTH RQE            */ 00455000
         LA    R0,40                                            DSK1005 00456000
*   CALL IEAVEADV;                  /* ADDRESS VERIFICATION RTN      */ 00457000
         L     R15,@CV01626                                     DSK1005 00458000
         BALR  R14,R15                                          DSK1005 00459000
*   IF RETCODE=0                    /* CHECK RETURN CODE             */ 00460000
*     THEN                          /* RQE ADDRESS IS VALID          */ 00461000
         LTR   R15,R15                                          DSK1005 00462000
         BNZ   @RF00160                                         02S0160 00463000
*     DO;                           /* VERIFY ADDR IN RQETCB FIELD   */ 00464000
*       LENREG=LENGTH(TCB);         /* REG 0 = LENGTH TCB            */ 00465000
         LA    R0,296                                           DSK1005 00466000
*       TCBPTR=RQETCB;              /* REG 2 = CONTENTS RQETCB       */ 00467000
         L     R2,RQETCB(,R4)                                   DSK1005 00468000
*       CALL IEAVEADV;              /* ADDRESS VERIFICATION RTN      */ 00469000
         L     R15,@CV01626                                     DSK1005 00470000
         BALR  R14,R15                                          DSK1005 00471000
*       IF RETCODE=0                /* CHECK RETURN CODE             */ 00472000
*         THEN                      /* TCB ADDRESS IS VALID          */ 00473000
         LTR   R15,R15                                          DSK1005 00474000
         BNZ   @RF00165                                         02S0165 00475000
*         DO;                       /* VERIFY THE IRB ADDRESS        */ 00476000
*           LENREG=ADDR(IRBLEN)-ADDR(RBPRFLNA);/* REG 0 = LENGTH IRB */ 00477000
         LA    R0,IRBLEN                                        DSK1005 00478000
         LA    R14,RBPRFXND-RBPRFXST                            DSK1005 00479000
         SLR   R0,R14                                           DSK1005 00480000
*           RBSECPTR=RQERRQ;        /* REG 2 = RQERRQ                */ 00481000
         L     R2,RQERRQ(,R4)                                   DSK1005 00482000
*           CALL IEAVEADV;          /* ADDRESS VERIFICATION ROUTINE  */ 00483000
         L     R15,@CV01626                                     DSK1005 00484000
         BALR  R14,R15                                          DSK1005 00485000
*         END;                                                  02S0170 00486000
*       ELSE                                                    02S0171 00487000
*         ;                         /* ORIGINAL ADDRESS INVALID      */ 00488000
@RF00165 DS    0H                                               02S0172 00489000
*     END;                                                      02S0172 00490000
*   ELSE                                                        02S0173 00491000
*     ;                             /* OR RQETCB FIELD INVALID       */ 00492000
@RF00160 DS    0H                                               02S0174 00493000
*   IF RETCODE>0                    /* OR RQERRQ FIELD INVALID       */ 00494000
*     THEN                          /* SET RETURN CODE TO 8 TO       */ 00495000
         LTR   R15,R15                                          DSK1005 00496000
         BNP   @RF00174                                         02S0174 00497000
*     RETCODE=8;                    /* INDICATE STORAGE NOT AN RQE   */ 00498000
         LA    R15,8                                            DSK1005 00499000
*   PARMREG0=RQEPTR;                /* RESTORE REG 0 AS ENTERED      */ 00500000
@RF00174 LR    R0,R4                                            DSK1005 00501000
*   RFY                                                         02S0177 00502000
*     R14 RSTD;                                                 02S0177 00503000
*   R14=RETADDR;                    /* RESTORE RETURN ADDRESS        */ 00504000
         LR    R14,R6                                           DSK1005 00505000
*   RETURN;                         /* RETURN TO QUEUE VERIFY RTN       00506000
*                                                                    */ 00507000
         B     @EL00001                                         02S0179 00508000
*                                                               02S0180 00509000
*/********************************************************************/ 00510000
*/*                                                                  */ 00511000
*/*     PURPOSE = SRB VERIFICATION SUBROUTINE.  IT'S FUNCTION IS TO  */ 00512000
*/*           DETERMINE WHETHER A PIECE OF STORAGE IS REALLY AN SRB  */ 00513000
*/*           OR NOT.  IT IS ENTERED AS A SUBROUTINE OF QUEUE VERI-  */ 00514000
*/*           FIER, WHEN IT IS THE PROCESS OF VERIFYING THE SRB QUEUE*/ 00515000
*/*                                                                  */ 00516000
*/*     INPUT =                                                      */ 00517000
*/*           R0 = THE VIRTUAL STORAGE ADDRESS TO BE VERIFIED        */ 00518000
*/*           R1 = THE ADDRESS OF THE SDWA                           */ 00519000
*/*           R14= RETURN ADDRESS TO CALLER                          */ 00520000
*/*           R15= ENTRY POINT ADDRESS OF SRBVER                     */ 00521000
*/*                                                                  */ 00522000
*/*      OUTPUT =                                                    */ 00523000
*/*           R0,R1,R8-R14 = UNCHANGED                               */ 00524000
*/*           R2-R7 = VOLITILE                                       */ 00525000
*/*           R15 = CONTAINS A RETURN CODE AS FOLLOWS:               */ 00526000
*/*                 0 = THE STORAGE IS AN SRB                        */ 00527000
*/*                 8 = THE STORAGE DOES NOT CONTAIN AN SRB          */ 00528000
*/*                                                                  */ 00529000
*/********************************************************************/ 00530000
*                                                               02S0180 00531000
*SRBVER:                                                        02S0180 00532000
*   ENTRY;                          /* SRB VERIFICATION ROUTINE      */ 00533000
@EP00180 DS    0H                                               02S0181 00534000
*   RETADDR=R14;                    /* SAVE RETURN ADDRESS           */ 00535000
         LR    R6,R14                                           DSK1005 00536000
*   RFY                                                         02S0182 00537000
*     R14 UNRSTD;                                               02S0182 00538000
*   SRBPTR=PARMREG0;                /* SET UP BASE FOR SRB           */ 00539000
         LR    R4,R0                                            DSK1005 00540000
*   ADDREG=PARMREG0;                /* REG 2 = SRB ADDRESS           */ 00541000
         LR    R2,R0                                            DSK1005 00542000
*   LENREG=LENGTH(SRB);             /* REG 0 = LENGTH SRB            */ 00543000
         LA    R0,44                                            DSK1005 00544000
*   CALL IEAVEADV;                  /* ADDRESS VERIFICATION RTN      */ 00545000
         L     R15,@CV01626                                     DSK1005 00546000
         BALR  R14,R15                                          DSK1005 00547000
*   IF RETCODE>0                    /* CHECK RETURN CODE             */ 00548000
*     THEN                          /* ORIGINAL ADDRESS INVALID      */ 00549000
         LTR   R15,R15                                          DSK1005 00550000
         BNP   @RF00187                                         02S0187 00551000
*     RETCODE=8;                    /* INDICATE STORAGE NOT AN SRB   */ 00552000
         LA    R15,8                                            DSK1005 00553000
*   PARMREG0=SRBPTR;                /* RESTORE REG 0 AS ENTERED      */ 00554000
@RF00187 LR    R0,R4                                            DSK1005 00555000
*   RFY                                                         02S0190 00556000
*     R14 RSTD;                                                 02S0190 00557000
*   R14=RETADDR;                    /* RESTORE RETURN ADDRESS        */ 00558000
         LR    R14,R6                                           DSK1005 00559000
*   RETURN;                         /* RETURN TO QUEUE VERIFY RTN    */ 00560000
         B     @EL00001                                         02S0192 00561000
*   END IEAVEEER                                                02S0193 00562000
*                                                               02S0193 00563000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00564000
*/*%INCLUDE SYSUT5  (PROLOG  )                                       */ 00565000
*/*%INCLUDE SYSUT5  (EERFL1  )                                       */ 00566000
*/*%INCLUDE SYSLIB  (IHARB   )                                       */ 00567000
*/*%INCLUDE SYSLIB  (IEZXRB  )                                       */ 00568000
*/*%INCLUDE SYSLIB  (IKJRB   )                                       */ 00569000
*/*%INCLUDE SYSLIB  (IKJTCB  )                                       */ 00570000
*/*%INCLUDE SYSLIB  (IHAIQE  )                                       */ 00571000
*/*%INCLUDE SYSLIB  (IHASDWA )                                       */ 00572000
*/*%INCLUDE SYSLIB  (IECDRQE )                                       */ 00573000
*/*%INCLUDE SYSLIB  (IHASRB  )                                       */ 00574000
*/*%INCLUDE SYSLIB  (IHAASXB )                                       */ 00575000
*/*%INCLUDE SYSLIB  (IHAASCB )                                       */ 00576000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00577000
*/*%INCLUDE SYSLIB  (IHAQVPL )                                       */ 00578000
*/*%INCLUDE SYSUT5  (DCLEER  )                                       */ 00579000
*/*%INCLUDE SYSUT5  (INITR   )                                       */ 00580000
*                                                               02S0193 00581000
*       ;                                                       02S0193 00582000
@DATA    DS    0H                                                       00583000
@CH00070 DC    H'4'                                                     00584000
@DATD    DSECT                                                          00585000
         DS    0F                                                       00586000
IEAVEEER CSECT                                                          00587000
         DC    X'C6E2'                       !!! SOURCE COMPARE FIX !!! 00588000
         DC    0F'0'                                            DSK1005 00588000
@DATD    DSECT                                                          00589000
         DS    0D                                                       00590000
@ENDDATD EQU   *                                                        00591000
IEAVEEER CSECT                                                          00592000
         NOPR  ((@ENDDATD-@DATD)*16)                                    00593000
         DC    X'E2C2'                       !!! SOURCE COMPARE FIX !!! 00594000
         DC    0F'0'                                            DSK1005 00594000
@SIZDATD DC    AL1(0)                                                   00595000
         DC    AL3(@ENDDATD-@DATD)                                      00596000
@CA01630 DC    A(IQEVER)                                                00597000
@CA01632 DC    A(RQEVER)                                                00598000
@CA01633 DC    A(SRBVER)                                        DSK1005 00599000
@CV01625 DC    V(IEAVEQV2)                                              00600000
@CV01626 DC    V(IEAVEADV)                                              00601000
         DS    0D                                                       00602000
         CVT      DSECT=YES,LIST=YES                            DSK1005 00603000
         IKJRB    ,                                             DSK1005 00603001
RBIQENA  EQU      RBSTAB2                                       DSK1005 00603002
         IHAASCB  ,                                             DSK1005 00603003
         IHAASXB  ,                                             DSK1005 00603004
         IHAPSA   ,                                             DSK1005 00603005
         IHASDWA  ,                                             DSK1005 00603006
         IHASRB   ,                                             DSK1005 00603007
R0       EQU   0                       REGISTER 0               DSK1005 00603008
R1       EQU   1                       REGISTER 1               DSK1005 00603009
R2       EQU   2                       REGISTER 2               DSK1005 00603010
R3       EQU   3                       REGISTER 3               DSK1005 00603011
R4       EQU   4                       REGISTER 4               DSK1005 00603012
R5       EQU   5                       REGISTER 5               DSK1005 00603013
R6       EQU   6                       REGISTER 6               DSK1005 00603014
R7       EQU   7                       REGISTER 7               DSK1005 00603015
R8       EQU   8                       REGISTER 8               DSK1005 00603016
R9       EQU   9                       REGISTER 9               DSK1005 00603017
R10      EQU   10                      REGISTER 10              DSK1005 00603018
R11      EQU   11                      REGISTER 11              DSK1005 00603019
R12      EQU   12                      REGISTER 12              DSK1005 00603020
R13      EQU   13                      REGISTER 13              DSK1005 00603021
R14      EQU   14                      REGISTER 14              DSK1005 00603022
R15      EQU   15                      REGISTER 15              DSK1005 00603023
IQESECT  EQU   0                                                        00807000
IQELNK   EQU   IQESECT                                                  00808000
IQEIRB   EQU   IQESECT+8                                                00809000
IQEFLAGS EQU   IQEIRB                                                   00810000
IQEIRBA  EQU   IQEIRB+1                                                 00811000
IQETCB   EQU   IQESECT+12                                               00812000
RQE      EQU   0                                                        00880000
RQETCB   EQU   RQE+12                                                   00881000
RQENRQE  EQU   RQE+20                                                   00882000
RQERRQ   EQU   RQE+24                                                   00883000
RQEPRT   EQU   RQE+36                                                   00884000
RQETYPE  EQU   RQE+37                                                   00885000
RQETYP3  EQU   RQETYPE                                                  00886000
RQEFLAG  EQU   RQE+38                                                   00887000
QVPL     EQU   0                                                        00907000
QVPLTYP3 EQU   QVPL                                                     00908000
QVPLTYP2 EQU   QVPLTYP3                                                 00909000
QVPLTYP1 EQU   QVPLTYP2                                                 00910000
QVPLEVR  EQU   QVPLTYP1                                                 00911000
QVPLODA  EQU   QVPLTYP1+4                                               00912000
QVPLWKA  EQU   QVPLTYP1+8                                               00913000
QVPLHDR  EQU   QVPLTYP1+16                                              00914000
QVPLHF   EQU   QVPLTYP1+20                                              00915000
QVPLFLGH EQU   QVPLHF                                                   00916000
QVPLFLGF EQU   QVPLHF+1                                                 00917000
QVPLFP3  EQU   QVPLFLGF                                                 00918000
QVPLFPTR EQU   QVPLHF+2                                                 00919000
QVPLTRLR EQU   QVPLTYP2+28                                              00920000
QVPLTB   EQU   QVPLTYP2+32                                              00921000
QVPLFLGT EQU   QVPLTB                                                   00922000
QVPLFLGB EQU   QVPLTB+1                                                 00923000
IQEEND   EQU   0                                                        00924000
ASCBPTR  EQU   PSAAOLD-PSA                                      DSK1005 00936000
*                                      START UNREFERENCED COMPONENTS    00939000
QVPLFELM EQU   QVPLTYP2+36                                              00974000
QVPLBPTR EQU   QVPLTB+2                                                 00975000
QVPLRES4 EQU   QVPLFLGB                                                 00976000
QVPLBP3  EQU   QVPLFLGB                                                 00977000
QVPLRES3 EQU   QVPLFLGT                                                 00978000
QVPLTR3  EQU   QVPLFLGT                                                 00979000
QVPLLELM EQU   QVPLTYP1+24                                              00980000
QVPLRES2 EQU   QVPLFLGF                                                 00981000
QVPLRES1 EQU   QVPLFLGH                                                 00982000
QVPLHD3  EQU   QVPLFLGH                                                 00983000
QVPLNOEL EQU   QVPLTYP1+12                                              00984000
RQEEND   EQU   RQE+40                                                   01122000
RQECHEAC EQU   RQEFLAG                                                  01124000
RQEPURGE EQU   RQEFLAG                                                  01125000
RQESRBS  EQU   RQEFLAG                                                  01126000
RQESTBL  EQU   RQEFLAG                                                  01127000
RQEFIXST EQU   RQEFLAG                                                  01128000
RQENOFRE EQU   RQEFLAG                                                  01129000
RQENOPST EQU   RQEFLAG                                                  01130000
RQERETRY EQU   RQEFLAG                                                  01131000
RQETYP1  EQU   RQETYP3                                                  01132000
RQETYP2  EQU   RQETYP3                                                  01133000
RQEVAM   EQU   RQETYPE                                                  01135000
RQE1TO1  EQU   RQETYPE                                                  01136000
RQEVIRT  EQU   RQETYPE                                                  01137000
RQE114   EQU   RQETYPE                                                  01138000
RQEPKEY  EQU   RQEPRT                                                   01140000
RQEIPIB  EQU   RQE+32                                                   01141000
RQESRB   EQU   RQE+28                                                   01142000
RQETCCW  EQU   RQE+16                                                   01143000
RQEDEB   EQU   RQE+8                                                    01144000
RQEIOB   EQU   RQE+4                                                    01145000
RQEUCB   EQU   RQE                                                      01146000
IQEOUTLM EQU   IQESECT+20                                               01427000
IQEDCB   EQU   IQESECT+16                                               01428000
IQETCBA  EQU   IQETCB+1                                                 01429000
IQESTAT2 EQU   IQETCB                                                   01430000
IQEPURGE EQU   IQEFLAGS                                                 01438000
IQEPARAM EQU   IQESECT+4                                                01439000
IQELNKA  EQU   IQELNK+1                                                 01440000
IQESTAT1 EQU   IQELNK                                                   01441000
*                                      END UNREFERENCED COMPONENTS      02164000
@ENDDATA EQU   *                                                        02166000
         END   IEAVEEER                                         DSK1005 02167000
