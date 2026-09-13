         TITLE 'ILRFRSLT, ASM FREE SLOT ROUTINES                       *00001000
                        '                                               00002000
ILRFRSLT CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK1029 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
         DC    AL1(16)                                             0001 00008000
         DC    C'ILRFRSLT  76.087'                                 0001 00009000
         DC    X'F0'                         !!! SOURCE COMPARE FIX !!! 00010000
ILRFRSL1 DS    0H                                                  0001 00010000
         USING *,R15                                            DSK1029 00011000
         B     @PROLOG                                             0001 00012000
         DC    AL2(@EP00098-ILRFRSL1)                                   00013000
         ENTRY ILRFRSL1                                                 00014000
ILRFRSW1 DS    0H                                                  0001 00015000
         USING *,R15                                            DSK1029 00016000
         B     @PROLOG                                             0001 00017000
         DC    AL2(@EP00101-ILRFRSW1)                                   00018000
         ENTRY ILRFRSW1                                                 00019000
         DROP  R15                                              DSK1029 00020000
@PROLOG  STM   R14,R12,12(R13)                                  DSK1029 00021000
         BALR  R12,0                                            DSK1029 00022000
@PSTART  DS    0H                                                  0001 00023000
         USING @PSTART,R12                                      DSK1029 00024000
         AH    R15,4(,R15)                                      DSK1029 00025000
         BR    R15                                              DSK1029 00026000
@EP00001 DS    0H                                                  0002 00027000
*   XPTEPTR=R1;                     /* GET XPTE POINTER FROM PARM REG*/ 00028000
         LR    R5,R1                                            DSK1029 00029000
*   IF XPTVALID='1'B THEN           /* IF THE XPTE IS VALID          */ 00030000
         TM    XPTFLAG2-XPTE(R5),XPTVALID                       DSK1029 00031000
         BNO   @RF00072                                            0072 00032000
*     DO;                                                          0073 00033000
*       ASMVTPTR=CVTASMVT;          /* GET ASMVT POINTER             */ 00034000
         L     R15,CVTPTR                                       DSK1029 00035000
         L     R3,CVTASMVT-CVT(,R15)                            DSK1029 00036000
*       IF R0^=0 THEN               /* IF THIS IS A PRIVATE AREA PAGE*/ 00037000
         LTR   R0,R0                                               0075 00038000
         BZ    @RF00075                                            0075 00039000
*         DO;                                                      0076 00040000
*           ASCBNVSC=ASCBNVSC-1;    /* CORRECT THE ALLOCATION COUNT  */ 00041000
         L     R15,RSMASCB-RSMHD(,R2)                           DSK1029 00042000
         LH    R14,ASCBNVSC-ASCB(,R15)                          DSK1029 00043000
         BCTR  R14,0                                            DSK1029 00044000
         STH   R14,ASCBNVSC-ASCB(,R15)                          DSK1029 00045000
*           ASMNVSC=ASMNVSC-1;      /* CORRECT THE GLOBAL COUNT      */ 00046000
         L     R15,ASMNVSC-ASMVT(,R3)                           DSK1029 00047000
         BCTR  R15,0                                            DSK1029 00048000
         ST    R15,ASMNVSC-ASMVT(,R3)                           DSK1029 00049000
*         END;                                                     0079 00050000
*       IF XPTIOERR='0'B THEN       /* IF THERE WAS NO PERMANENT I/O    00051000
*                                      ERROR                         */ 00052000
@RF00075 TM    XPTFLAG2-XPTE(R5),XPTIOERR                       DSK1029 00053000
         BNZ   @RF00080                                            0080 00054000
*         DO;                       /* FREE THE SLOT                 */ 00055000
*           IF R0=0 THEN            /* IF THIS IS A COMMON AREA PAGE */ 00056000
         SLR   R15,R15                                          DSK1029 00057000
         CR    R0,R15                                           DSK1029 00058000
         BNE   @RF00082                                            0082 00059000
*             DO;                                                  0083 00060000
*               LSIDREG=XPTLSID2;   /* GET THE SECOND LSID           */ 00061000
         L     R1,XPTLSID2-XPTE(,R5)                            DSK1029 00062000
*               IF LSIDREG^=0 THEN  /* IF THERE IS A SECOND COPY     */ 00063000
         CR    R1,R15                                           DSK1029 00064000
         BE    @RF00085                                            0085 00065000
*                 CALL FREESLOT;    /* CALL TO RESET THE PAT BIT     */ 00066000
         BAL   R14,FREESLOT                                     DSK1029 00067000
*             END;                                                 0087 00068000
@RF00085 DS    0H                                                  0088 00069000
*           LSIDREG=XPTLSID;        /* GET THE LSID FOR FREESLOT     */ 00070000
@RF00082 L     R1,XPTLSID-XPTE(,R5)                             DSK1029 00071000
*           CALL FREESLOT;          /* CALL TO RESET PAT BIT         */ 00072000
         BAL   R14,FREESLOT                                     DSK1029 00073000
*         END;                                                     0090 00074000
*     END;                                                         0091 00075000
@RF00080 DS    0H                                                  0092 00076000
*   XPTVALID='0'B;                  /* INVALIDATE THE XPTE           */ 00077000
@RF00072 DS    0H                                                  0093 00078000
*   XPTIOERR='0'B;                  /* RESET ERROR FLAGS             */ 00079000
         NI    XPTFLAG2-XPTE(R5),B'01101111'                    DSK1029 00080000
*   XPTVIOLP='0'B;                  /* INVALIDATE IF A VIO XPTE      */ 00081000
         NI    XPTFLAGS-XPTE(R5),255-XPTVIOLP                   DSK1029 00082000
*   XPTLPID=''B;                    /* RESET THE LSID FIELDS         */ 00083000
*                                                                  0095 00084000
         XC    XPTLPID-XPTE(8,R5),XPTLPID-XPTE(R5)              DSK1029 00085000
*   /*****************************************************************/ 00086000
*   /*                                                               */ 00087000
*   /* RESTORE REGS AND RETURN TO THE CALLER.                        */ 00088000
*   /*                                                               */ 00089000
*   /*****************************************************************/ 00090000
*                                                                  0096 00091000
*   RETURN;                         /* RETURN TO CALLER              */ 00092000
@EL00001 DS    0H                                                  0096 00093000
@EF00001 DS    0H                                                  0096 00094000
@ER00001 LM    R14,R12,12(R13)                                  DSK1029 00095000
         BR    R14                                              DSK1029 00096000
*   RFY                                                            0097 00097000
*    (XPTEPTR) UNRSTD;                                             0097 00098000
*                                                                  0098 00099000
*   /*****************************************************************/ 00100000
*   /*                                                               */ 00101000
*   /* SECONDARY ENTRY POINT IRLFRSL1. USED BY ASM ROUTINES TO FREE A*/ 00102000
*   /* SLOT.                                                         */ 00103000
*   /*                                                               */ 00104000
*   /*****************************************************************/ 00105000
*                                                                  0098 00106000
*ILRFRSL1:                                                         0098 00107000
*   ENTRY;                          /* PLS ENTRY TO ILRFRSL1         */ 00108000
*                                                                  0098 00109000
@EP00098 DS    0H                                                  0099 00110000
*   /*****************************************************************/ 00111000
*   /*                                                               */ 00112000
*   /* CALL FREESLOT TO RESET THE PAT BIT AND MAINTAIN THE PROPER    */ 00113000
*   /* COUNTS. LSIDREG AND ASMVTPTR WERE SET BY THE CALLER.          */ 00114000
*   /*                                                               */ 00115000
*   /*****************************************************************/ 00116000
*                                                                  0099 00117000
*   CALL FREESLOT;                  /* CALL FREESLOT ROUTINE         */ 00118000
*                                                                  0099 00119000
         BAL   R14,FREESLOT                                     DSK1029 00120000
*   /*****************************************************************/ 00121000
*   /*                                                               */ 00122000
*   /* RESTORE REGS AND RETURN TO CALLER                             */ 00123000
*   /*                                                               */ 00124000
*   /*****************************************************************/ 00125000
*                                                                  0100 00126000
*   RETURN;                         /* RETURN TO CALLER              */ 00127000
         B     @EL00001                                            0100 00128000
*                                                                  0101 00129000
*   /*****************************************************************/ 00130000
*   /*                                                               */ 00131000
*   /* SECONDARY ENTRY POINT ILRFRSW1. USED BY ASM ROUTINES TO FREE  */ 00132000
*   /* SWAP SETS AND MAINTAIN COUNTS.                                */ 00133000
*   /*                                                               */ 00134000
*   /*****************************************************************/ 00135000
*                                                                  0101 00136000
*ILRFRSW1:                                                         0101 00137000
*   ENTRY;                          /* PLS ENTRY TO ILRFRSW1         */ 00138000
@EP00101 DS    0H                                                  0102 00139000
*   RFY                                                            0102 00140000
*    (R8,                                                          0102 00141000
*     R9,                                                          0102 00142000
*     SARTPTR) RSTD;                                               0102 00143000
*                                                                  0102 00144000
*   /*****************************************************************/ 00145000
*   /*                                                               */ 00146000
*   /* SET UP REGISTERS NEEDED TO FIND SAT BIT, BASED ON LSID VALUE  */ 00147000
*   /*                                                               */ 00148000
*   /*****************************************************************/ 00149000
*                                                                  0103 00150000
*   GEN(LA     LSIDREG,0(LSIDREG)); /* CLEAR HIGH ORDER BYTE         */ 00151000
         LA    R1,0(R1)                                         DSK1029 00152000
*   SARTPTR=ASMSART;                /* GET SART POINTER              */ 00153000
         L     R7,ASMSART-ASMVT(,R3)                            DSK1029 00154000
*   R8=LSIDREG;                     /* PUT IN EVEV/ODD PAIR          */ 00155000
         LR    R8,R1                                            DSK1029 00156000
*   SRDL(R8,ISOLATEQ);              /* SHIFT TO GET NN AND QQQQ    0106 00157000
*                                      SEPERATED                     */ 00158000
         SRDL  R8,16                                               0106 00159000
*   SRL(R9,ADJUSTQ);                /* SHIFT QQQQ TO RIGHT JUSTIFY   */ 00160000
         SRL   R9,16                                               0107 00161000
*   RFY                                                            0108 00162000
*    (SAREPTR,                                                     0108 00163000
*     SATPTR,                                                      0108 00164000
*     SDCTEPTR) RSTD;                                              0108 00165000
*   SAREPTR=ADDR(SARENTS(R8+1));    /* GET ADDRESS OF SARTE BASED ON    00166000
*                                      INDEX VALUE (NN PORTION OF  0109 00167000
*                                      LSID)                         */ 00168000
         LR    R5,R8                                            DSK1029 00169000
         MH    R5,@CH00357                                      DSK1029 00170000
         LA    R14,SARENTS-SART(R5,R7)                          DSK1029 00171000
*   IF R8>=SARUSE×SRENUSE='1'B×SREDSBD='1'B THEN/* IF INDEX IS TOO 0110 00172000
*                                      LARGE, OR SRE IS NOT IN USE OR   00173000
*                                      BAD                           */ 00174000
         C     R8,SARUSE-SART(,R7)                              DSK1029 00175000
         BNL   @EL00001                                         DSK1029 00176000
         TM    SREFLG-SARTE(R14),SRENUSE+SREDSBD                DSK1029 00177000
         BNZ   @EL00001                                         DSK1029 00178000
*     RETURN;                       /* RETURN TO THE CALLER          */ 00179000
*   SATPTR=SRESAT;                  /* GET SAT POINTER               */ 00180000
         L     R6,SRESAT-SARTE(,R14)                            DSK1029 00181000
*   SDCTEPTR=SRESDCTE;              /* GET SDCT POINTER              */ 00182000
*                                                                  0113 00183000
         L     R2,SRESDCTE-SARTE(,R14)                          DSK1029 00184000
*   /*****************************************************************/ 00185000
*   /*                                                               */ 00186000
*   /* ROUND LSID (QQQQ) TO INSURE FIRST LSID OF A SWAP SET.         */ 00187000
*   /*                                                               */ 00188000
*   /*****************************************************************/ 00189000
*                                                                  0114 00190000
*   RFY                                                            0114 00191000
*    (R10,                                                         0114 00192000
*     R11) RSTD;                                                   0114 00193000
*   GENERATE;                                                      0115 00194000
         SR    R8,R8               CLEAR FOR DIVIDE                     00195000
         LH    R1,SDCCYLSZ(,R2) GET NO. OF SLOTS PER CYL        DSK1029 00196000
         DR    R8,R1               DIVIDE Q BY NO. SLOTS PER CYL        00197000
         SR    R10,R10             CLEAR FOR MULTIPLY                   00198000
         LR    R11,R9              LOAD CYLINDER NUMBER OBTAINED        00199000
         MR    R10,R1              CYL X SLOTS PER CYL                  00200000
         SRDL  R8,32               LOAD ODD REG AND ZERO EVEN REG       00201000
         D     R8,SARSETSZ-SART(,R7) DIVIDE SLOTS WITHIN CYL    DSK1029 00202000
         SR    R8,R8               CLEAR FOR MULTIPLY                   00203000
         M     R8,SARSETSZ-SART(,R7) ROUND BY DISCARDING REM    DSK1029 00204000
         AR    R9,R11              ROUNDED LSID (QQQQ)                  00205000
         LR    R1,R9          SAVE FOR LATER                    DSK1029 00206000
*                                                                  0116 00207000
*   /*****************************************************************/ 00208000
*   /*                                                               */ 00209000
*   /* FIND PROPER SAT BIT AND RESET. THE PROPER SAT BIT IS RESET    */ 00210000
*   /* BASED ON INFORMATION IN THE SAT, SART, AND SDCT. THE LSID IS  */ 00211000
*   /* USED TO INDEX INTO THE VARIOUS CONTROL BLOCKS.                */ 00212000
*   /*                                                               */ 00213000
*   /*****************************************************************/ 00214000
*                                                                  0116 00215000
*   RFY                                                            0116 00216000
*    (MAPPTR) RSTD;                                                0116 00217000
*   GENERATE;                                                      0117 00218000
*         /*                                                            00219000
         SR    R8,R8               CLEAR REG FOR DIVIDE                 00220000
         LH    R11,SDCCYLSZ(,R2)  GET NUMBER OF SLOTS PER CYL   DSK1029 00221000
         DR    R8,R11              DIV QQQQ BY NUMBER OF SLOTS/CYL      00222000
*                                  TO GET CYLINDER NUMBER               00223000
         LH    R11,SATBYTCL(,R6) GET SHIFT VALUE                DSK1029 00224000
         SLL   R9,0(R11)            ADJUST FOR MULTI BYTE MAPS          00225000
*                                  (TO GET BYTE NUMBER WITHIN CYL)      00226000
         LR    R11,R8              LOAD SLOT WITHIN CYL                 00227000
         SR    R10,R10             CLEAR FOR DIVIDE                     00228000
         D     R10,SARSETSZ-SART(,R7) FIND SET WITHIN CYLINDER, DSK1029 00229000
*                                  R8 WAS REMAINDER FROM PREV DIVIDE    00230000
         LR    R10,R11             PUT SET NUM IN EVEN/ODD PAIR         00231000
         SR    R11,R11             CLEAR                                00232000
         SRDL  R10,3               DETERMINE BYTE IN MAP                00233000
*                                  R10 = BYTE NUMBER (MULTI-BYTE MAPS)  00234000
*                                  R11 = SHIFTED BIT NUMBER (SET NUM)   00235000
*                                                                       00236000
         LA    R9,0(R10,R9)    GET MAP BYTE OFFSET              DSK1029 00237000
         LA    R9,SATMAPS(R9,R6) GET ACTUAL MAP BYTE ADDR       DSK1029 00238000
         SR    R10,R10             CLEAR                                00239000
         SLDL  R10,3               RETURN BIT NUM (RE-JUSTIFY SET #)    00240000
*                                                                       00241000
         LA    R8,128               X'80'                       DSK1029 00242000
         SRL   R8,0(R10)           SHIFT MASK BIT BY BIT NUMBER         00243000
         STC   R8,SATMASK(R6)  SAVE MASK FOR NEXT ALLOCATION    DSK1029 00244000
*                                                                       00245000
         SR    R11,R11             CLEAR                                00246000
         IC    R11,0(R9)       GET MAP BYTE                     DSK1029 00247000
         NR    R11,R8              AND BIT TO SEE IF SET                00248000
         BZ    NOTON               IF BIT WAS NOT ON, DO NOT COUNT      00249000
         IC    R11,0(,R9)      GET MAP BYTE                     DSK1029 00250000
         XR    R11,R8              RESET BIT                            00251000
         STC   R11,0(,R9)      STORE UPDATED MAP                DSK1029 00252000
*   RFY                                                            0118 00253000
*    (R8,                                                          0118 00254000
*     R9,                                                          0118 00255000
*     R10,                                                         0118 00256000
*     R11,                                                         0118 00257000
*     SDCTEPTR) UNRSTD;                                            0118 00258000
*                                                                  0119 00259000
*   /*****************************************************************/ 00260000
*   /*                                                               */ 00261000
*   /* UPDATE SLOT ALLOCATION COUNTS, AND STORE VALUES TO BE USED BY */ 00262000
*   /* THE NEXT ALLOCATION.                                          */ 00263000
*   /*                                                               */ 00264000
*   /*****************************************************************/ 00265000
*                                                                  0119 00266000
*   SREAVLSL=SREAVLSL+1;            /* RETURN SLOT TO AVAILABLE POOL */ 00267000
         LA    R15,1                                            DSK1029 00268000
         L     R8,SREAVLSL-SARTE(,R14)                          DSK1029 00269000
         ALR   R8,R15                                           DSK1029 00270000
         ST    R8,SREAVLSL-SARTE(,R14)                          DSK1029 00271000
*   SARSETCT=SARSETCT+1;            /* ADJUST TOTAL SETS AVAILABLE 0120 00272000
*                                      COUNT                         */ 00273000
         AL    R15,SARSETCT-SART(,R7)                           DSK1029 00274000
         ST    R15,SARSETCT-SART(,R7)                           DSK1029 00275000
*NOTON:                                                            0121 00276000
*   SATSLTNO=LSIDREG;               /* SAVE QQQQ OF LSID FOR NEXT  0121 00277000
*                                      ASSIGNMENT BY SWAP            */ 00278000
NOTON    ST    R1,SATSLTNO(,R6)                                 DSK1029 00279000
*   SATASGN=MAPPTR;                 /* SAVE BYTE ADDRESS FOR NEXT  0122 00280000
*                                      ALLOCATION                    */ 00281000
         ST    R9,SATASGN(,R6)                                  DSK1029 00282000
*   RFY                                                            0123 00283000
*    (SAREPTR,                                                     0123 00284000
*     SARTPTR,                                                     0123 00285000
*     SATPTR,                                                      0123 00286000
*     MAPPTR) UNRSTD;                                              0123 00287000
*   RETURN;                         /* RETURN TO CALLER              */ 00288000
         B     @EL00001                                            0124 00289000
*FREESLOT:                                                         0125 00290000
*   PROC OPTIONS(NOSAVE,NOSAVEAREA,RETREG);                        0125 00291000
*                                                                  0125 00292000
FREESLOT DS    0H                                                  0126 00293000
*   /*****************************************************************/ 00294000
*   /*                                                               */ 00295000
*   /* FREESLOT SUBROUTINE COMMON TO ALL SLOT FREEING ROUTINES. THIS */ 00296000
*   /* ROUTINE RESETS THE PROPER PAT BIT BASED ON THE LSID SUPPLIED  */ 00297000
*   /* BY THE CALLER.                                                */ 00298000
*   /*                                                               */ 00299000
*   /*****************************************************************/ 00300000
*                                                                  0126 00301000
*   RFY                                                            0126 00302000
*    (XPTEPTR,                                                     0126 00303000
*     PAREPTR,                                                     0126 00304000
*     R8,                                                          0126 00305000
*     R9,                                                          0126 00306000
*     PARTPTR,                                                     0126 00307000
*     PATPTR,                                                      0126 00308000
*     R14) RSTD;                                                   0126 00309000
*   GEN(LA LSIDREG,0(LSIDREG));     /* CLEAR HIGH BYTE               */ 00310000
         LA    R1,0(R1)                                         DSK1029 00311000
*   IF LSIDREG=0 THEN               /* LSID ZERO IS QSR - DO NOT FREE*/ 00312000
         LTR   R1,R1                                            DSK1029 00313000
         BNZ   @RF00128                                            0128 00314000
*     GOTO R14;                     /* RETURN TO THE CALLER          */ 00315000
         BR    R14                                                 0129 00316000
*   PARTPTR=ASMPART;                /* GET PART POINTER              */ 00317000
@RF00128 L     R7,ASMPART-ASMVT(,R3)                            DSK1029 00318000
*   R8=LSIDREG;                     /* PUT LSID IN EVEN ODD PAIR     */ 00319000
         LR    R8,R1                                            DSK1029 00320000
*   SRDL(R8,ISOLATEQ);              /* ISOLATE NN AND QQQQ OF LSID   */ 00321000
         SRDL  R8,16                                               0132 00322000
*   SRL(R9,ADJUSTQ);                /* RIGHT JUSTIFY QQQQ FOR DIVIDE */ 00323000
         SRL   R9,16                                               0133 00324000
*   IF R8>=PARTEUSE THEN            /* IF INVALID PART ENTRY         */ 00325000
         C     R8,PARTEUSE-PART(,R7)                            DSK1029 00326000
         BL    @RF00134                                            0134 00327000
*     GOTO R14;                     /* RETURN TO CALLER              */ 00328000
         BR    R14                                                 0135 00329000
*   PAREPTR=ADDR(PARTENTS(R8+1));   /* GET ADDRESS OF PROPER PARTE 0136 00330000
*                                      BASED ON INDEX VALUE (NN OF 0136 00331000
*                                      LSID)                         */ 00332000
@RF00134 LR    R15,R8                                           DSK1029 00333000
         SLA   R15,6                                            DSK1029 00334000
         LA    R15,PARTENTS-PART(R15,R7)                        DSK1029 00335000
         LR    R7,R15                                           DSK1029 00336000
*   PATPTR=PAREPATP;                /* GET ADDRESS OF PAT            */ 00337000
         L     R6,PAREPATP-PARTE(,R7)                           DSK1029 00338000
*   R8=0;                           /* CLEAR FOR DIVIDE              */ 00339000
         SLR   R8,R8                                               0138 00340000
*   RFY                                                            0139 00341000
*    (RWORK) RSTD;                                                 0139 00342000
*   RWORK=PATCYLSZ;                 /* GET NUMBER OF SLOTS PER CYL   */ 00343000
         LH    R10,PATCYLSZ(,R6)                                DSK1029 00344000
*   GEN(DR  R8,RWORK);              /* GET CYLINDER NUMBER           */ 00345000
         DR    R8,R10                                           DSK1029 00346000
*   R1=ADDR(PATCYLS(R9*PATCYLMW+1));/* GET ADDRESS OF PROPER MAP     */ 00347000
         LR    R15,R9                                           DSK1029 00348000
         MH    R15,PATCYLMW(,R6)                                DSK1029 00349000
         SLA   R15,2                                            DSK1029 00350000
         LA    R1,PATCYLS(R15,R6)                               DSK1029 00351000
*   RFY                                                            0143 00352000
*    (R15) RSTD;                                                   0143 00353000
*   R15=R8;                         /* SET UP FOR BITMM, BIT WITHIN     00354000
*                                      MAP                           */ 00355000
         LR    R15,R8                                              0144 00356000
*   RFY                                                            0145 00357000
*    (R8,                                                          0145 00358000
*     R9) UNRSTD;                                                  0145 00359000
*   IF R15>=WORDSIZE THEN           /* IF IN SECOND WORD             */ 00360000
         LA    R11,32                                           DSK1029 00361000
         CR    R15,R11                                          DSK1029 00362000
         BL    @RF00146                                            0146 00363000
*     DO;                           /* ADJUST PARMS FOR BITMM        */ 00364000
*       R15=R15-WORDSIZE;           /* SUBTRACT 32 BITS              */ 00365000
         SLR   R15,R11                                          DSK1029 00366000
*       R1=R1+FOURBYTE;             /* ADD ONE WORD TO ADDRESS       */ 00367000
         AL    R1,@CF00038                                         0149 00368000
*     END;                                                         0150 00369000
*   RWORK=R14;                      /* SAVE R14 ACROSS BITMM CALL    */ 00370000
@RF00146 LR    R10,R14                                          DSK1029 00371000
*                                                                  0152 00372000
*   /*****************************************************************/ 00373000
*   /*                                                               */ 00374000
*   /* USE MACRO ILRBITMM TO RESET THE APPROPRIATE PAT BIT.          */ 00375000
*   /*                                                               */ 00376000
*   /*****************************************************************/ 00377000
*                                                                  0152 00378000
*/*  ILRBITMM INVOCATION                                           0152 00379000
*      BITMAP(R1,ONEWORD)BIT(R15)SET(OFF,MP)TEST                     */ 00380000
*                                                                  0152 00381000
*   DCL                                                            0152 00382000
*     BITMMCB1 BIT(32) CONSTANT('80000000'X);                      0152 00383000
*   DCL                                                            0153 00384000
*     BITMMWRD FIXED(31) BDY(WORD) BASED(R1);                      0153 00385000
*   DCL                                                            0154 00386000
*     BITMSK31 FIXED(8) CONSTANT(31);                              0154 00387000
*   DCL                                                            0155 00388000
*     BITMMC32 FIXED(8) CONSTANT(32);                              0155 00389000
*   DO;                                                            0156 00390000
*     RFY                                                          0157 00391000
*      (R0,                                                        0157 00392000
*       R1,                                                        0157 00393000
*       R2,                                                        0157 00394000
*       R14,                                                       0157 00395000
*       R15) RSTD;                  /* RESTRICT WORK REGS    @Z40WPWG*/ 00396000
*     R14=BITMMCB1;                 /* BUILD MASK                    */ 00397000
         L     R14,@CF01017                                        0158 00398000
*     GEN(SRL   R14,0(R15));                                       0159 00399000
         SRL   R14,0(R15)                                               00400000
*     R0=BITMMWRD;                  /* MAP WRD TO REG                */ 00401000
         L     R0,BITMMWRD(,R1)                                    0160 00402000
*     R15=BITMMC32;                 /* PRESET RETURN CODE            */ 00403000
         LA    R15,32                                              0161 00404000
*     DO WHILE((R0×R14)=R0);        /* LOOP UNTIL BIT SET            */ 00405000
         B     @DE00162                                            0162 00406000
@DL00162 DS    0H                                                  0163 00407000
*       R15=0;                      /* SET SUCCESS RETURN CODE       */ 00408000
         SLR   R15,R15                                             0163 00409000
*       R2=R0&(-1&&R14);            /* TURN BIT OFF                  */ 00410000
         LR    R2,R14                                              0164 00411000
         X     R2,@CF01560                                         0164 00412000
         NR    R2,R0                                               0164 00413000
*       CS(R0,R2,BITMMWRD);         /* TRY TO SET BIT IN STG         */ 00414000
         CS    R0,R2,BITMMWRD(R1)                               DSK1029 00415000
*       BC(8,BITMMX01);             /* BRANCH ON CS SUCCESS          */ 00416000
         BC    8,BITMMX01                                          0166 00417000
*       R15=BITMMC32;               /* SET FAILURE RETURN CODE       */ 00418000
         LA    R15,32                                              0167 00419000
*     END;                          /* END LOOP TO SET BIT           */ 00420000
@DE00162 LR    R11,R0                                           DSK1029 00421000
         OR    R11,R14                                          DSK1029 00422000
         CR    R11,R0                                           DSK1029 00423000
         BE    @DL00162                                            0168 00424000
*BITMMX01:                                                         0169 00425000
*     RFY                                                          0169 00426000
*      (R0,                                                        0169 00427000
*       R1,                                                        0169 00428000
*       R2,                                                        0169 00429000
*       R14,                                                       0169 00430000
*       R15) UNRSTD;                /* RELEASE WRK REGS      @Z40WPWG*/ 00431000
BITMMX01 DS    0H                                                  0170 00432000
*   END;                            /* END OF ILRBITMM PROCESSING    */ 00433000
*                                                                  0171 00434000
*   /*****************************************************************/ 00435000
*   /*                                                               */ 00436000
*   /* TEST TO SEE IF BIT WAS PREVIOUSLY RESET. IF NOT, UPDATE       */ 00437000
*   /* AVAILABLE SET COUNT IN THE PART ENTRY.                        */ 00438000
*   /*                                                               */ 00439000
*   /*****************************************************************/ 00440000
*                                                                  0171 00441000
*   RFY                                                            0171 00442000
*    (R0,                                                          0171 00443000
*     R1,                                                          0171 00444000
*     R14,                                                         0171 00445000
*     R15) RSTD;                                                   0171 00446000
*   R14=RWORK;                      /* RESTORE THE RETURN POINTER    */ 00447000
         LR    R14,R10                                          DSK1029 00448000
*   IF R15=0 THEN                   /* IF BIT WAS SET                */ 00449000
         LTR   R15,R15                                             0173 00450000
         BNZ   @EL00002                                         DSK1029 00451000
*     DO;                           /* UPDATE THE COUNTS             */ 00452000
*       RWORK=PARESLTA;             /* LOAD FOR C&S                  */ 00453000
         L     R10,PARESLTA-PARTE(,R7)                          DSK1029 00454000
*FREELOOP:                                                         0176 00455000
*       R15=RWORK+1;                /* LOAD NEW VALUE                */ 00456000
FREELOOP LA    R15,1                                               0176 00457000
         ALR   R15,R10                                          DSK1029 00458000
*       CS(RWORK,R15,PARESLTA);                                    0177 00459000
         CS    R10,R15,PARESLTA-PARTE(R7)                       DSK1029 00460000
*       BC(PARNE,FREELOOP);         /* IF C&S FAILS, RETRY IT        */ 00461000
         BC    7,FREELOOP                                          0178 00462000
*     END;                                                         0179 00463000
*   RFY                                                            0180 00464000
*    (R0,                                                          0180 00465000
*     XPTEPTR,                                                     0180 00466000
*     PARTPTR,                                                     0180 00467000
*     RWORK,                                                       0180 00468000
*     R14,                                                         0180 00469000
*     R15,                                                         0180 00470000
*     PAREPTR,                                                     0180 00471000
*     PATPTR) UNRSTD;                                              0180 00472000
*   END FREESLOT;                                                  0181 00473000
@EL00002 DS    0H                                                  0181 00474000
@EF00002 DS    0H                                                  0181 00475000
@ER00002 BR    R14                                              DSK1029 00476000
*   END ILRFRSLT                                                   0182 00477000
*                                                                  0182 00478000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00479000
*/*%INCLUDE SYSLIB  (IHAASCB )                                       */ 00480000
*/*%INCLUDE SYSLIB  (ILRASMHD)                                       */ 00481000
*/*%INCLUDE SYSLIB  (ILRASMVT)                                       */ 00482000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00483000
*/*%INCLUDE SYSLIB  (ILRPART )                                       */ 00484000
*/*%INCLUDE SYSLIB  (ILRPAT  )                                       */ 00485000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00486000
*/*%INCLUDE SYSLIB  (IHARSMHD)                                       */ 00487000
*/*%INCLUDE SYSLIB  (ILRSART )                                       */ 00488000
*/*%INCLUDE SYSLIB  (ILRSAT  )                                       */ 00489000
*/*%INCLUDE SYSLIB  (ILRSDCT )                                       */ 00490000
*/*%INCLUDE SYSLIB  (IHAXPTE )                                       */ 00491000
*                                                                  0182 00492000
*       ;                                                          0182 00493000
@DATA    DC    0H'0'                                            DSK1029 00494000
@CH00357 DC    H'48'                                                    00495000
@DATD    DSECT                                                          00496000
         DS    0F                                                       00497000
ILRFRSLT CSECT                                                          00498000
         DC    0F'0'                                            DSK1029 00499000
@CF00038 DC    F'4'                                                     00500000
@CF01560 DC    F'-1'                                                    00501000
@CF01017 DC    XL4'80000000'                                            00502000
@DATD    DSECT                                                          00503000
         DS    0D                                                       00504000
@ENDDATD EQU   *                                                        00505000
ILRFRSLT CSECT                                                          00506000
         NOPR  ((@ENDDATD-@DATD)*16)                                    00507000
         DC    X'4040'                       !!! SOURCE COMPARE FIX !!! 00508000
         DC    0F'0'                                            DSK1029 00508000
@SIZDATD DC    AL1(0)                                                   00509000
         DC    AL3(@ENDDATD-@DATD)                                      00510000
         DC    0D'0'                                            DSK1029 00511000
         CVT      DSECT=YES,LIST=YES                            DSK1029 00511994
         IHAASCB  ,                                             DSK1029 00511995
         IHAXPTE  ,                                             DSK1029 00511996
         ILRASMVT ,                                             DSK1029 00511997
         IHARSMHD ,                                             DSK1029 00511998
         ILRSART  ,                                             DSK1029 00511999
         ILRPART  ,                                             DSK1029 00512000
         ILRSAT   ,                                             DSK1029 00512001
         ILRSDCT  ,                                             DSK1029 00512002
         ILRATA   ,                                             DSK1029 00512003
         ILRPAT   ,                                             DSK1029 00512004
R0       EQU   0                       REGISTER 0               DSK1029 00512005
R1       EQU   1                       REGISTER 1               DSK1029 00512006
R2       EQU   2                       REGISTER 2               DSK1029 00512007
R3       EQU   3                       REGISTER 3               DSK1029 00512008
R4       EQU   4                       REGISTER 4               DSK1029 00512009
R5       EQU   5                       REGISTER 5               DSK1029 00512010
R6       EQU   6                       REGISTER 6               DSK1029 00512011
R7       EQU   7                       REGISTER 7               DSK1029 00512012
R8       EQU   8                       REGISTER 8               DSK1029 00512013
R9       EQU   9                       REGISTER 9               DSK1029 00512014
R10      EQU   10                      REGISTER 10              DSK1029 00512015
R11      EQU   11                      REGISTER 11              DSK1029 00512016
R12      EQU   12                      REGISTER 12              DSK1029 00512017
R13      EQU   13                      REGISTER 13              DSK1029 00512018
R14      EQU   14                      REGISTER 14              DSK1029 00512019
R15      EQU   15                      REGISTER 15              DSK1029 00512020
BITMMWRD EQU   0                                                        00734000
@ENDDATA EQU   *                                                        01992000
         END   ILRFRSLT                                         DSK1029 01993000
