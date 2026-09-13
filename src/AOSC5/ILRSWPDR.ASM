         TITLE 'ILRSWPDR,ASM SWAP DRIVER                               *00001000
                        '                                               00002000
ILRSWPDR CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK1034 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'ILRSWPDR  76.087'                                 0001 00008000
         DROP  R15                                              DSK1034 00009000
@PROLOG  BALR  R12,0                                            DSK1034 00010000
@PSTART  DS    0H                                                  0001 00011000
         USING @PSTART,R12                                      DSK1034 00012000
*                                                                  0129 00013000
*   /*****************************************************************/ 00014000
*   /*                                                               */ 00015000
*   /* LOAD THE ASMVT POINTER AND SET FRR.                           */ 00016000
*   /*                                                               */ 00017000
*   /*****************************************************************/ 00018000
*                                                                  0129 00019000
*   ASMVTPTR=CVTASMVT;              /* LOAD POINTER TO ASMVT         */ 00020000
         L     R8,CVTPTR                                        DSK1034 00021000
         L     R3,CVTASMVT-CVT(,R8)                             DSK1034 00022000
*   RWORK=0;                        /* RESET VALUE                   */ 00023000
         SLR   R10,R10                                          DSK1034 00024000
*   RWORK1=1;                       /* SCHEDULED VALUE               */ 00025000
         LA    R11,1                                            DSK1034 00026000
*   CS(RWORK1,RWORK,SARSRBCT);      /* RESET SCHEDULED COUNT         */ 00027000
         L     R8,ASMSART-ASMVT(,R3)                            DSK1034 00028000
         CS    R11,R10,SARSRBCT-SART(R8)                        DSK1034 00029000
*   FADDR=ASMPIOFR;                 /* GET RECOVERY MODULE ADDRESS   */ 00030000
         L     R4,ASMPIOFR-ASMVT(,R3)                           DSK1034 00031000
*   GENERATE REFS(FADDR) SETS(R10,R11);                            0134 00032000
         SETFRR A,FRRAD=(R4),PARMAD=(R4),WRKREGS=(R10,R11)      DSK1034 00033000
*   ATAMODID=ATAMSWPD;              /* SET MODID FOR RECOVERY        */ 00034000
         MVI   ATAMODID(R4),ATAMSWPD                            DSK1034 00035000
*   ATASWPDR='1'B;                  /* SWAP DRIVER IN CONTROL        */ 00036000
         OI    ATASWPDR(R4),B'00100000'                         DSK1034 00037000
*   INDEXREG=0;                     /* INITIALIZE INDEX              */ 00038000
         SLR   R9,R9                                            DSK1034 00039000
*   WKAPTR=WSACASMS;                /* LOAD WORKAREA POINTER         */ 00040000
         L     R8,PSALCCAV-PSA                                  DSK1034 00041000
         L     R8,LCCACPUS-LCCA(,R8)                            DSK1034 00042000
         L     R13,WSACASMS-WSAC(,R8)                           DSK1034 00043000
*                                                                  0139 00044000
*   /*****************************************************************/ 00045000
*   /*                                                               */ 00046000
*   /* LOOP THROUGH ALL SART ENTRIES LOOKING FOR WORK TO PROCESS. IF */ 00047000
*   /* THERE IS WORK TO DO (SCCW ON SRE) LOCK THE ENTRY AND SEND THE */ 00048000
*   /* REQUEST TO IOS VIA THE SIO MACRO.                             */ 00049000
*   /*                                                               */ 00050000
*   /*****************************************************************/ 00051000
*                                                                  0139 00052000
*   DO WHILE INDEXREG<SARUSE;       /* LOOP THROUGH ALL ENTRIES      */ 00053000
         B     @DE00139                                            0139 00054000
@DL00139 DS    0H                                                  0140 00055000
*     RFY                                                          0140 00056000
*      (SCCWPTR) RSTD;                                             0140 00057000
*     SAREPTR=ADDR(SARENTS(INDEXREG+1));/* GET SARTE POINTER         */ 00058000
         LR    R2,R9                                            DSK1034 00059000
         MH    R2,@CH00190                                      DSK1034 00060000
         L     R5,ASMSART-ASMVT(,R3)                            DSK1034 00061000
         LA    R5,SARENTS-SART(R2,R5)                           DSK1034 00062000
*     SCCWPTR=SRESCCW;              /* GET SCCW POINTER              */ 00063000
         L     R8,SRESCCW-SARTE(,R5)                            DSK1034 00064000
*     IF SCCWPTR^=0 THEN            /* IF SCCW TO PROCESS            */ 00065000
         SLR   R2,R2                                            DSK1034 00066000
         CR    R8,R2                                            DSK1034 00067000
         BE    @RF00143                                            0143 00068000
*       DO;                         /*                               */ 00069000
*         RWORK=SRELOCK;            /* GET SRE LOCK WORD             */ 00070000
         L     R10,SRELOCK-SARTE(,R5)                           DSK1034 00071000
*         IF RWORK=0 THEN           /* IF SRE IS NOT LOCKED          */ 00072000
         CR    R10,R2                                           DSK1034 00073000
         BNE   @RF00146                                            0146 00074000
*           DO;                     /* TRY TO LOCK IT                */ 00075000
*             RWORK1=1;             /* SET UP TO LOCK                */ 00076000
         LA    R11,1                                            DSK1034 00077000
*             CS(RWORK,RWORK1,SRELOCK);/* LOCK IT                    */ 00078000
         CS    R10,R11,SRELOCK-SARTE(R5)                        DSK1034 00079000
*             BC(NE,GETNEXT);       /* IF OTHER CPU BEAT THIS ONE-TRY   00080000
*                                      NEXT ENTRY                    */ 00081000
         BC    7,GETNEXT                                           0150 00082000
*             ATASARTE=SAREPTR;     /* SAVE FOR RECOVERY             */ 00083000
         ST    R5,ATASARTE(,R4)                                 DSK1034 00084000
*             RFY                                                  0152 00085000
*              (IORBPTR) RSTD;                                     0152 00086000
*             IORBPTR=SREIORB;      /* GET IORB POINTER              */ 00087000
         L     R6,SREIORB-SARTE(,R5)                            DSK1034 00088000
*             IF IORBPTR=0 THEN     /* IF IORB WAS LOST              */ 00089000
         LTR   R6,R6                                            DSK1034 00090000
         BNZ   @RF00154                                            0154 00091000
*               DO;                 /* PREPARE TO ABEND              */ 00092000
*                 ATARCODE=CODE12;  /* SET ABEND REASON CODE         */ 00093000
         MVI   ATARCODE(R4),X'0C'                               DSK1034 00094000
*                 GEN(ABEND X'084',,,SYSTEM);/* ABEND-NO IORB      0157 00095000
*                                                            @ZM43062*/ 00096000
         ABEND X'084',,,SYSTEM                                          00097000
*               END;                                               0158 00098000
*             ELSE                  /* IF IORB IS AVAILABLE          */ 00099000
*               DO;                 /* PROCESS                       */ 00100000
         B     @RC00154                                            0159 00101000
@RF00154 DS    0H                                                  0160 00102000
*                 DO WHILE IORFUSE='1'B;/* IF IORB IS IN USE         */ 00103000
         B     @DE00160                                            0160 00104000
@DL00160 DS    0H                                                  0161 00105000
*                   IORBPTR=IORIORB;/* GET NEXT IORB                 */ 00106000
         L     R6,IORIORB-IORB(,R6)                             DSK1034 00107000
*                   IF IORBPTR=0 THEN/* IF NO IORB'S AVAILABLE       */ 00108000
         LTR   R6,R6                                            DSK1034 00109000
         BZ    UNLOCK                                           DSK1034 00110000
*                     GOTO UNLOCK;  /* CAN'T PROCESS THIS ENTRY      */ 00111000
*                 END;                                             0164 00112000
@DE00160 TM    IORFLGS-IORB(R6),IORFUSE                         DSK1034 00113000
         BO    @DL00160                                            0164 00114000
*                 SCCWPTR=SRESCCW;  /* GET SCCW POINTER              */ 00115000
         L     R8,SRESCCW-SARTE(,R5)                            DSK1034 00116000
*                 IF SCCWPTR^=0 THEN/* IF SCCW'S WEREN'T PROCESSED BY   00117000
*                                      OTHER CPU                     */ 00118000
         LTR   R8,R8                                            DSK1034 00119000
         BZ    @RF00166                                            0166 00120000
*                   DO;             /* THIS ONE CAN PROCESS          */ 00121000
*                     RWORK=0;      /* SET UP TO C&S                 */ 00122000
         SLR   R10,R10                                          DSK1034 00123000
*CSRTRY:                                                           0169 00124000
*                     CS(SCCWPTR,RWORK,SRESCCW);/* GET QUE           */ 00125000
CSRTRY   CS    R8,R10,SRESCCW-SARTE(R5)                         DSK1034 00126000
*                     BC(NE,CSRTRY);/* IF OTHER CPU IS ADDING TO   0170 00127000
*                                      QUEUE, TRY AGAIN              */ 00128000
         BC    7,CSRTRY                                            0170 00129000
*                                                                  0171 00130000
*                     /***********************************************/ 00131000
*                     /*                                             */ 00132000
*                     /* PROCESS ALL SCCW'S FOR THIS ENTRY. IF MORE  */ 00133000
*                     /* THAN ONE SCCW TO PROCESS TRY TO DO MULTIPLE */ 00134000
*                     /* SIO'S. IF, HOWEVER, NOT ENOUGH IORB'S ARE   */ 00135000
*                     /* AVAILABLE, ALL SCCW'S REMAINING WILL BE SENT*/ 00136000
*                     /* TO IOS ON ONE IORB.                         */ 00137000
*                     /*                                             */ 00138000
*                     /***********************************************/ 00139000
*                                                                  0171 00140000
*                     RFY                                          0171 00141000
*                      (IOSBPTR) RSTD;                             0171 00142000
*                     DO UNTIL SREDRIVE='0'B;/* LOOP UNTIL ALL SCCW'S   00143000
*                                      ARE PROCESSED                 */ 00144000
@DL00172 DS    0H                                                  0173 00145000
*                       SREDRIVE='0'B;/* INITIALIZE                  */ 00146000
         NI    SREFLG-SARTE(R5),255-SREDRIVE                    DSK1034 00147000
*                       ATASCCW=SCCWPTR;/* SAVE SCCW POINTER FOR RCV */ 00148000
         ST    R8,ATASCCW(,R4)                                  DSK1034 00149000
*                       IORFUSE='1'B;/* IORB IS NOW IN USE           */ 00150000
         OI    IORFLGS-IORB(R6),IORFUSE                         DSK1034 00151000
*                       ATAIORB=IORBPTR;/* SAVE FOR RECOVERY         */ 00152000
         ST    R6,ATAIORB(,R4)                                  DSK1034 00153000
*                       IOSBPTR=IORIOSB;/* GET IOSB POINTER          */ 00154000
         L     R7,IORIOSB-IORB(,R6)                             DSK1034 00155000
*                       IORSCCW=SCCWPTR;/* CHAIN SCCW TO IORB        */ 00156000
         ST    R8,IORSCCW-IORB(,R6)                             DSK1034 00157000
*                       IORAPND=''B;/* RESET APPENDAGE FLAGS         */ 00158000
         NI    IORFLGS-IORB(R6),255-IORAPND-IORFNE-IORFAE       DSK1034 00159000
*                       IORERR=0;   /* RESET ERROR POINTER           */ 00160000
         SLR   R2,R2                                            DSK1034 00161000
         ST    R2,IORERR-IORB(,R6)                              DSK1034 00162000
*                       SCCWIORB=IORBPTR;/* POINT TO IORB            */ 00163000
         ST    R6,SCCWIORB(,R8)                                 DSK1034 00164000
*                       ATASCCW=SCCWSCCW;/* SAVE NEXT SCCW FOR RCV   */ 00165000
         L     R15,SCCWSCCW(,R8)                                DSK1034 00166000
         ST    R15,ATASCCW(,R4)                                 DSK1034 00167000
*                       IF ATASCCW^=0 THEN/* IF MORE SCCW'S TO     0183 00168000
*                                      PROCESS                       */ 00169000
         CR    R15,R2                                           DSK1034 00170000
         BE    @RF00183                                            0183 00171000
*                         DO;                                      0184 00172000
*                           TEMPIORB=IORIORB;/* GET NEXT IORB        */ 00173000
         L     R2,IORIORB-IORB(,R6)                             DSK1034 00174000
         ST    R2,TEMPIORB(,R13)                                DSK1034 00175000
*                           DO WHILE TEMPIORB^=0&TEMPIORB->IORFUSE='1'B 00176000
*                                 ;                                0186 00177000
         B     @DE00186                                            0186 00178000
@DL00186 DS    0H                                                  0187 00179000
*                             TEMPIORB=TEMPIORB->IORIORB;/* GET NEXT */ 00180000
         L     R2,TEMPIORB(,R13)                                DSK1034 00181000
         L     R2,IORIORB-IORB(,R2)                             DSK1034 00182000
         ST    R2,TEMPIORB(,R13)                                DSK1034 00183000
*                           END;                                   0188 00184000
@DE00186 L     R2,TEMPIORB(,R13)                                DSK1034 00185000
         LTR   R2,R2                                            DSK1034 00186000
         BZ    @DC00186                                            0188 00187000
         TM    IORFLGS-IORB(R2),IORFUSE                         DSK1034 00188000
         BO    @DL00186                                            0188 00189000
@DC00186 DS    0H                                                  0189 00190000
*                           IF TEMPIORB^=0 THEN/* IF LOOP ENDED    0189 00191000
*                                      BECAUSE AN AVAILABLE IORB WAS    00192000
*                                      FOUND                         */ 00193000
         SLR   R2,R2                                            DSK1034 00194000
         C     R2,TEMPIORB(,R13)                                DSK1034 00195000
         BE    @RF00189                                            0189 00196000
*                             DO;   /* PREPARE FOR NEXT TIME         */ 00197000
*                               SREDRIVE='1'B;/* REDRIVE AFTER SIO   */ 00198000
         OI    SREFLG-SARTE(R5),SREDRIVE                        DSK1034 00199000
*                               SCCWSCCW=0;/* TRUNCATE QUEUE         */ 00200000
         ST    R2,SCCWSCCW(,R8)                                 DSK1034 00201000
*                             END;                                 0193 00202000
*                                                                  0194 00203000
*                           /*****************************************/ 00204000
*                           /*                                       */ 00205000
*                           /* ALL REMAINING SCCW'S ON THIS SART     */ 00206000
*                           /* ENTRY MUST BE CHAINED TO ONE IORB     */ 00207000
*                           /* SINCE ONLY ONE IS FREE. ONE SIO WILL  */ 00208000
*                           /* BE ISSUED TO IOS. THE CCW CHAINS IN   */ 00209000
*                           /* THE INDIVIDUAL SCCW'S MUST BE CHAINED */ 00210000
*                           /* TOGETHER AT THIS TIME.                */ 00211000
*                           /*                                       */ 00212000
*                           /*****************************************/ 00213000
*                                                                  0194 00214000
*                           ELSE    /* IF LOOP ENDED BECAUSE ONLY ONE   00215000
*                                      IORB IS FREE                  */ 00216000
*                             DO WHILE ATASCCW^=0;/* PROCESS ALL   0194 00217000
*                                      SCCW'S                        */ 00218000
         B     @RC00189                                            0194 00219000
@RF00189 B     @DE00194                                            0194 00220000
@DL00194 DS    0H                                                  0195 00221000
*                               CCWPTR=SCCWLCCW;/* GET SCCW POINTER  */ 00222000
         L     R10,SCCWLCCW(,R8)                                DSK1034 00223000
*                               CCWPTR->LASTRWFL=CHAINOP;/* SET CHAIN   00224000
*                                      BIT IN CCW                    */ 00225000
         MVI   LASTRWFL(R10),X'40'                              DSK1034 00226000
*                               CCWPTR=CCWPTR+8;/* UPDATE            */ 00227000
         AL    R10,@CF00036                                     DSK1034 00228000
*                               CCWPTR->LASTSROP=TICOP;/* SET TO TIC */ 00229000
         MVI   LASTSROP(R10),X'08'                              DSK1034 00230000
*                               CCWPTR->LASTSRAD=ADDR(ATASCCW->SCCWSEEK 00231000
*                                   );/* CHAIN TO NEXT CCW           */ 00232000
         L     R2,ATASCCW(,R4)                                  DSK1034 00233000
         LA    R15,SCCWSEEK(,R2)                                DSK1034 00234000
         STCM  R15,7,LASTSRAD(R10)                              DSK1034 00235000
*                               SCCWPTR=ATASCCW;/* GET NEXT SCCW     */ 00236000
         LR    R8,R2                                            DSK1034 00237000
*                               ATASCCW=SCCWSCCW;/* SAVE NEXT POINTER   00238000
*                                      FOR RCV AND LOOP CNTL         */ 00239000
         L     R2,SCCWSCCW(,R8)                                 DSK1034 00240000
         ST    R2,ATASCCW(,R4)                                  DSK1034 00241000
*                             END;                                 0202 00242000
@DE00194 L     R2,ATASCCW(,R4)                                  DSK1034 00243000
         LTR   R2,R2                                            DSK1034 00244000
         BNZ   @DL00194                                            0202 00245000
*                         END;                                     0203 00246000
@RC00189 DS    0H                                                  0204 00247000
*                                                                  0204 00248000
*                       /*********************************************/ 00249000
*                       /*                                           */ 00250000
*                       /* PREPARE TO ISSUE SIO TO IOS. AFTER SIO IS */ 00251000
*                       /* ISSUED CHECK SREDRIVE FLAG TO SEE IF      */ 00252000
*                       /* ANOTHER SIO MUST BE ISSUED FOR THIS ENTRY */ 00253000
*                       /* (DO UNTIL).                               */ 00254000
*                       /*                                           */ 00255000
*                       /*********************************************/ 00256000
*                                                                  0204 00257000
*                       IOSUCB=SREUCB;/* FILL IN UCB POINTER         */ 00258000
@RF00183 L     R2,SREUCB-SARTE(,R5)                             DSK1034 00259000
         ST    R2,IOSUCB-IOSB(,R7)                              DSK1034 00260000
*                       IOSCCHN='1'B;/* INDICATE COMMAND CHAINING    */ 00261000
         OI    IOSFLA-IOSB(R7),IOSCCHN                          DSK1034 00262000
*                       IOSPROC=0;  /* CLEAR                         */ 00263000
         MVI   IOSPROC-IOSB(R7),X'00'                           DSK1034 00264000
*                       IOSERP=0;   /* CLEAR                         */ 00265000
         SLR   R2,R2                                            DSK1034 00266000
         ST    R2,IOSERP-IOSB(,R7)                              DSK1034 00267000
*                       IOSIPIB=0;  /* CLEAR                         */ 00268000
         ST    R2,IOSIPIB-IOSB(,R7)                             DSK1034 00269000
*                       RFY                                        0209 00270000
*                        (R1) RSTD;                                0209 00271000
*                       R1=IOSSRB;  /* GET SRB POINTER               */ 00272000
         L     R1,IOSSRB-IOSB(,R7)                              DSK1034 00273000
*                       IOSEEK=IORSCCW->SCCWSK;/* SEEK ADDRESS       */ 00274000
         L     R15,IORSCCW-IORB(,R6)                            DSK1034 00275000
         MVC   IOSEEK-IOSB(8,R7),SCCWSK(R15)                    DSK1034 00276000
*                       IOSEEKA=IOSEEK;/* SET DYNAMIC ADDR EQUAL     */ 00277000
         MVC   IOSEEKA-IOSB(8,R7),IOSEEK-IOSB(R7)               DSK1034 00278000
*                       IOSRST=ADDR(IORSCCW->SCCWSSEC);/* SET SECTOR    00279000
*                                      ADDRESS                       */ 00280000
         LA    R0,SCCWSSEC(,R15)                                DSK1034 00281000
         ST    R0,IOSRST-IOSB(,R7)                              DSK1034 00282000
*                       IOSVST=IOSRST;/* VIRTUAL = REAL              */ 00283000
         ST    R0,IOSVST-IOSB(,R7)                              DSK1034 00284000
*                       ATAIORB=0;  /* CLEAR FOR RECOVERY            */ 00285000
         ST    R2,ATAIORB(,R4)                                  DSK1034 00286000
*                       STM(R0,R15,SWPDRSAV);/* SAVE REGS ACROSS SIO */ 00287000
         STM   R0,R15,SWPDRSAV(R13)                             DSK1034 00288000
*                       GEN REFS(R1)(STARTIO SRB=(1));/* START I/O TO   00289000
*                                      IOS                           */ 00290000
         STARTIO SRB=(1)                                                00291000
*                       LM(R0,R15,SWPDRSAV);/* RESTORE REGS          */ 00292000
         LM    R0,R15,SWPDRSAV(R13)                             DSK1034 00293000
*                       RFY                                        0219 00294000
*                        (R1) UNRSTD;                              0219 00295000
*                       SCCWPTR=ATASCCW;/* GET NEXT SCCW POINTER     */ 00296000
         L     R8,ATASCCW(,R4)                                  DSK1034 00297000
*                       IORBPTR=TEMPIORB;/* GET NEXT IORBPTR         */ 00298000
         L     R6,TEMPIORB(,R13)                                DSK1034 00299000
*                     END;          /* END DO UNTIL SREDRIVE =0      */ 00300000
@DE00172 TM    SREFLG-SARTE(R5),SREDRIVE                        DSK1034 00301000
         BNZ   @DL00172                                            0222 00302000
*                   END;            /* END SCCW TO PROCESS           */ 00303000
*                 RFY                                              0224 00304000
*                  (IOSBPTR) UNRSTD;                               0224 00305000
@RF00166 DS    0H                                                  0225 00306000
*UNLOCK:                                                           0225 00307000
*                 RWORK=0;          /* SETUP TO UNLOCK               */ 00308000
UNLOCK   SLR   R10,R10                                          DSK1034 00309000
*                 RWORK1=1;         /* SETUP TO UNLOCK               */ 00310000
         LA    R11,1                                            DSK1034 00311000
*                 CS(RWORK1,RWORK,SRELOCK);/* RESET LOCK             */ 00312000
         CS    R11,R10,SRELOCK-SARTE(R5)                        DSK1034 00313000
*                 ATASARTE=0;       /* RESET FOR RECOVERY            */ 00314000
         SLR   R7,R7                                            DSK1034 00315000
         ST    R7,ATASARTE(,R4)                                 DSK1034 00316000
*               END;                /* END IORB TO PROCESS           */ 00317000
*           END;                    /* END IF SRE NOT LOCKED         */ 00318000
@RC00154 DS    0H                                                  0231 00319000
*         RFY                                                      0231 00320000
*          (IORBPTR) UNRSTD;                                       0231 00321000
@RF00146 DS    0H                                                  0232 00322000
*       END;                        /* END IF SCCW TO PROCESS        */ 00323000
*GETNEXT:                                                          0233 00324000
*     INDEXREG=INDEXREG+1;          /* UPDATE INDEX                  */ 00325000
@RF00143 DS    0H                                                  0233 00326000
GETNEXT  AL    R9,@CF00038                                      DSK1034 00327000
*   END;                            /* END DO WHILE INDEXREG < SARUSE*/ 00328000
@DE00139 L     R8,ASMSART-ASMVT(,R3)                            DSK1034 00329000
         C     R9,SARUSE-SART(,R8)                              DSK1034 00330000
         BL    @DL00139                                            0234 00331000
*   GENERATE REFS(R10,R11);                                        0235 00332000
         SETFRR D,WRKREGS=(R10,R11)                                     00333000
*   RFY                                                            0236 00334000
*    (R14) RSTD;                                                   0236 00335000
*SWPDRTN:                                                          0237 00336000
*   R14=CVTSRBRT;                   /* GET RETURN ADDRESS            */ 00337000
SWPDRTN  L     R2,CVTPTR                                        DSK1034 00338000
         L     R14,CVTSRBRT-CVT(,R2)                            DSK1034 00339000
*   END ILRSWPDR                                                   0238 00340000
*                                                                  0238 00341000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00342000
*/*%INCLUDE SYSLIB  (ILRASMVT)                                       */ 00343000
*/*%INCLUDE SYSLIB  (ILRATA  )                                       */ 00344000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00345000
*/*%INCLUDE SYSLIB  (IHAFRRS )                                       */ 00346000
*/*%INCLUDE SYSLIB  (IECDIOCM)                                       */ 00347000
*/*%INCLUDE SYSLIB  (ILRIORB )                                       */ 00348000
*/*%INCLUDE SYSLIB  (IECDIOSB)                                       */ 00349000
*/*%INCLUDE SYSLIB  (IHALCCA )                                       */ 00350000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00351000
*/*%INCLUDE SYSLIB  (ILRSART )                                       */ 00352000
*/*%INCLUDE SYSLIB  (ILRSCCW )                                       */ 00353000
*/*%INCLUDE SYSLIB  (IHASRB  )                                       */ 00354000
*/*%INCLUDE SYSLIB  (IHAWSAVT)                                       */ 00355000
*                                                                  0238 00356000
*       ;                                                          0238 00357000
@EL00001 DS    0H                                                  0238 00358000
@EF00001 DS    0H                                                  0238 00359000
@ER00001 BR    R14                                              DSK1034 00360000
@DATA    DC    0H'0'                                            DSK1034 00361000
@CH00190 DC    H'48'                                                    00362000
@DATD    DSECT                                                          00363000
         DS    0F                                                       00364000
ILRSWPDR CSECT                                                          00365000
         DC    X'4780'                       !!! SOURCE COMPARE FIX !!! 00366000
         DC    0F'0'                                            DSK1034 00366000
@CF00038 DC    F'1'                                                     00367000
@CF00036 DC    F'8'                                                     00368000
@DATD    DSECT                                                          00369000
         DS    0D                                                       00370000
@ENDDATD EQU   *                                                        00371000
ILRSWPDR CSECT                                                          00372000
         NOPR  ((@ENDDATD-@DATD)*16)                                    00373000
         DC    X'9610'                       !!! SOURCE COMPARE FIX !!! 00374000
         DC    0F'0'                                            DSK1034 00374000
@SIZDATD DC    AL1(0)                                                   00375000
         DC    AL3(@ENDDATD-@DATD)                                      00376000
         DC    0D'0'                                            DSK1034 00377000
         IECDIOCM ,                                             DSK1034 00377997
         IECDIOSB ,                                             DSK1034 00377998
         CVT      DSECT=YES,LIST=YES                            DSK1034 00377999
         IHAFRRS  ,                                             DSK1034 00378000
         IHALCCA  ,                                             DSK1034 00378001
         IHAPSA   ,                                             DSK1034 00378002
         ILRASMVT ,                                             DSK1034 00378003
         ILRIORB  ,                                             DSK1034 00378004
         ILRATA   ,                                             DSK1034 00378005
         ILRSART  ,                                             DSK1034 00378006
         ILRSCCW  ,                                             DSK1034 00378007
         IHAWSAVT CLASS=CPU                                     DSK1034 00378008
R0       EQU   0                       REGISTER 0               DSK1034 00378009
R1       EQU   1                       REGISTER 1               DSK1034 00378010
R2       EQU   2                       REGISTER 2               DSK1034 00378011
R3       EQU   3                       REGISTER 3               DSK1034 00378012
R4       EQU   4                       REGISTER 4               DSK1034 00378013
R5       EQU   5                       REGISTER 5               DSK1034 00378014
R6       EQU   6                       REGISTER 6               DSK1034 00378015
R7       EQU   7                       REGISTER 7               DSK1034 00378016
R8       EQU   8                       REGISTER 8               DSK1034 00378017
R9       EQU   9                       REGISTER 9               DSK1034 00378018
R10      EQU   10                      REGISTER 10              DSK1034 00378019
R11      EQU   11                      REGISTER 11              DSK1034 00378020
R12      EQU   12                      REGISTER 12              DSK1034 00378021
R13      EQU   13                      REGISTER 13              DSK1034 00378022
R14      EQU   14                      REGISTER 14              DSK1034 00378023
R15      EQU   15                      REGISTER 15              DSK1034 00378024
SWPDRWKA EQU   0                                                        00635000
TEMPIORB EQU   SWPDRWKA                                                 00636000
SWPDRSAV EQU   SWPDRWKA+4                                               00637000
LASTCCW  EQU   0                                                        00638000
LASTRWOP EQU   LASTCCW                                                  00639000
LASTSROP EQU   LASTRWOP                                                 00640000
LASTRWAD EQU   LASTCCW+1                                                00641000
LASTSRAD EQU   LASTRWAD                                                 00642000
LASTRWFL EQU   LASTCCW+4                                                00643000
@ENDDATA EQU   *                                                        02068000
         END   ILRSWPDR                                         DSK1034 02069000
