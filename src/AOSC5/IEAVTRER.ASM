         TITLE '        IEAVTRER  RECORDING REQUEST FACILITY           *00001000
                        '                                               00002000
IEAVTRER CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK1193 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(24)                                          DSK1193 00007000
         DC    C'IEAVTRER 81279  UZ53001 '                      DSK1193 00008000
         DROP  R15                                              DSK1193 00009000
@PROLOG  STM   R14,R12,12(R13)                                  DSK1193 00010000
         BALR  R8,0                                             DSK1193 00011000
@PSTART  DS    0H                                                  0001 00012000
         USING @PSTART,R8                                       DSK1193 00013000
HALFREG EQU 16                     /* BITS FOR SHIFT                 */ 00014000
R2DISP  EQU 28                     /* DISPLACEMENT IN SAVEAREA       */ 00015000
ZIP     EQU  0                     /* ZERO DISPLACEMENT              */ 00016000
BYTE1   EQU  4                     /* BYTE ONE IN REG                */ 00017000
*   IF CVTRTMCT=0 THEN              /* IF RTCT NOT INIT      @YM33344*/ 00018000
         L     R14,CVTPTR                                       DSK1193 00019000
         L     R14,CVTRTMCT-CVTMAP(,R14)                        DSK1193 00020000
         LTR   R14,R14                                          DSK1193 00021000
         BNZ   @RF00109                                            0109 00022000
*     DO;                           /* DONT HANDLE REQUEST   @YM33344*/ 00023000
*       R15=RCTWENTY;               /* IND RECORD INACTIVE   @YM33344*/ 00024000
         LA    R15,20                                              0111 00025000
*     END;                          /* END NOT INIT GROUP    @YM33344*/ 00026000
*   ELSE                            /* IF RTCT INIT PROCESS  @YM33344*/ 00027000
*     DO;                           /* AS NORMAL             @YM33344*/ 00028000
         B     @RC00109                                            0113 00029000
@RF00109 DS    0H                                                  0114 00030000
*       IF EMERREQ=YES THEN         /* IF THIS IS AN EMERGENCY     0114 00031000
*                                      REQUEST FROM THE SYSTEM     0114 00032000
*                                      TERMINATION FACILITY          */ 00033000
         TM    EMERREQ(R13),B'10000000'                            0114 00034000
         BNO   @RF00114                                            0114 00035000
*/********************************************************************/ 00036000
*/*                                                                  */ 00037000
*/* THE PURPOSE OF THE EMERPROC SEGMENT IS TO HANDLE TERMINATION     */ 00038000
*/* REQUESTS. THE RECORDING FACILITY MUST RETURN THE ADDRESS AND     */ 00039000
*/* LENGTH OF UNWRITTEN LOGREC RECORDS. STF WILL ATTEMPT TO WRITE    */ 00040000
*/* THESE RECORDS BEFORE ENTERING WAIT STATE.                        */ 00041000
*/*                                                                  */ 00042000
*/********************************************************************/ 00043000
*                                                                  0115 00044000
*         DO;                       /* EMERGENCY PROCESSING          */ 00045000
*           R15=LOOPCODE;           /* USED FOR LOOP CONTROL         */ 00046000
         LA    R15,1                                               0116 00047000
*           RESPECIFY               /* RESTRICT REGISTER FOR         */ 00048000
*             R4 RESTRICTED;        /* ADDRESS TO STORE SYSTEM MASK  */ 00049000
*           R4=ADDR(SMASK);         /* OBTAIN ADDRESS FOR STNSM      */ 00050000
         LA    R4,SMASK(,R13)                                      0118 00051000
*           GEN(STNSM ZIP(R4),X'FF');/* STORE SYSTEM MASK AND      0119 00052000
*                                      PRESERVE ITS ORIGINAL VALUE   */ 00053000
         STNSM ZIP(R4),X'FF'                                            00054000
*           RESPECIFY               /* RELEASE REGISTER FROM         */ 00055000
*             R4 UNRESTRICTED;      /* ADDRESS TO STORE SYSTEM MASK  */ 00056000
*           IF DATBIT=YES THEN      /* IF DYNAMIC ADDRESS TRANSLATION   00057000
*                                      IS ACTIVE, REQUESTOR NOT STF  */ 00058000
         TM    DATBIT(R13),B'00000100'                             0121 00059000
         BNO   @RF00121                                            0121 00060000
*             R15=RC6TEEN;          /* REQUEST NOT HONORED           */ 00061000
         LA    R15,16                                              0122 00062000
*           ELSE                    /* IF DAT NOT ACTIVE CONTINUE  0123 00063000
*                                      WITH                          */ 00064000
*             DO;                   /* EMERGENCY PROCESSING          */ 00065000
*                                                                  0123 00066000
         B     @RC00114                                         DSK1193 00067000
@RF00121 DS    0H                                                  0124 00068000
*               /*****************************************************/ 00069000
*               /*                                                   */ 00070000
*               /* CONVERT NECESSARY VIRTUAL ADDRESSES TO REAL       */ 00071000
*               /* ADDRESSES.                                        */ 00072000
*               /*                                                   */ 00073000
*               /*****************************************************/ 00074000
*                                                                  0124 00075000
*               RFY                                                0124 00076000
*                (R3) RSTD;                                        0124 00077000
*               R3=CVTRTMCT;        /* VIRTUAL RTCT ADDRESS          */ 00078000
         L     R14,CVTPTR                                       DSK1193 00079000
         L     R3,CVTRTMCT-CVTMAP(,R14)                         DSK1193 00080000
*               GEN(LRA R3,ZIP(R3));/* MAKE IT REAL ADDR             */ 00081000
         LRA R3,ZIP(R3)                                                 00082000
*               R3->RTCTRPER=YES;   /* TURN OFF RECORDING TO OBVIATE    00083000
*                                      RCB SERIALIZATION             */ 00084000
         OI    RTCTRFLG-RTCT(R3),RTCTRPER                       DSK1193 00085000
*               R12=R3->RTCTRCB;    /* GET VIRTUAL RCB ADDRESS       */ 00086000
         L     R12,RTCTRCB-RTCT(,R3)                            DSK1193 00087000
*               GEN(LRA R12,ZIP(R12));/* MAKE IT REAL                */ 00088000
         LRA R12,ZIP(R12)                                               00089000
*               IF R3->RTCTRSTF=NO THEN/* FIRST STF ENTRY ...        */ 00090000
         TM    RTCTRFLG-RTCT(R3),RTCTRSTF                       DSK1193 00091000
         BNZ   @RF00130                                            0130 00092000
*                 DO;               /* -YES , DO ONE-TIME VIRT TO  0131 00093000
*                                      REAL TRANSLATION OF RCB ADDR  */ 00094000
*                   R3->RTCTRSTF=YES;/* SHOW ADDRS TRANSLATED        */ 00095000
         OI    RTCTRFLG-RTCT(R3),RTCTRSTF                       DSK1193 00096000
*                   R3=RCBBUFB;                                    0133 00097000
         L     R3,RCBBUFB(,R12)                                    0133 00098000
*                   GEN(LRA R3,ZIP(R3));/* REAL BUFFER START         */ 00099000
         LRA R3,ZIP(R3)                                                 00100000
*                   RCBBUFB=R3;     /* UPDATE THE RCB                */ 00101000
         ST    R3,RCBBUFB(,R12)                                    0135 00102000
*                   R3=RCBBUFE-1;   /* BUFFEREND MINUS ONE TO INSURE    00103000
*                                      SAME PAGE             @YM04220*/ 00104000
         L     R3,RCBBUFE(,R12)                                    0136 00105000
         BCTR  R3,0                                                0136 00106000
*                   GEN(LRA R3,ZIP(R3));/* REAL BUFFER END           */ 00107000
         LRA R3,ZIP(R3)                                                 00108000
*                   RCBBUFE=R3+1;   /* UPDATE THE RCB        @YM04220*/ 00109000
         LA    R14,1                                            DSK1193 00110000
         ALR   R14,R3                                           DSK1193 00111000
         ST    R14,RCBBUFE(,R12)                                DSK1193 00112000
*                   R3=RCBFREE;                                    0139 00113000
         L     R3,RCBFREE(,R12)                                    0139 00114000
*                   GEN(LRA R3,ZIP(R3));/* REAL FREE PTR             */ 00115000
         LRA R3,ZIP(R3)                                                 00116000
*                   RCBFREE=R3;     /* UPDATE THE RCB                */ 00117000
         ST    R3,RCBFREE(,R12)                                    0141 00118000
*                 END;              /* END V - R TRANSLATION         */ 00119000
*               RFY                                                0143 00120000
*                (R3) UNRSTD;                                      0143 00121000
@RF00130 DS    0H                                                  0144 00122000
*               IF RCBFLNG=RCBTLNG THEN/* IF THERE ARE NO UNWRITTEN     00123000
*                                      RECORD                        */ 00124000
         CLC   RCBFLNG(2,R12),RCBTLNG(R12)                         0144 00125000
         BNE   @RF00144                                            0144 00126000
*                 R15=RCFOUR;       /* NOTIFY SYSTEM TERMINATION     */ 00127000
         LA    R15,4                                               0145 00128000
*               ELSE                /* IF THERE ARE UNWRITTEN RECORDS   00129000
*                                      SEARCH UNTIL A LOGREC RECORD     00130000
*                                      OR NO RECORDS REMAIN          */ 00131000
*                 DO WHILE(R15=LOOPCODE);                          0146 00132000
         B     @RC00114                                         DSK1193 00133000
@RF00144 B     @DE00146                                            0146 00134000
@DL00146 DS    0H                                                  0147 00135000
*                   RESPECIFY       /* RESTRICT REGISTER FOR         */ 00136000
*                    (R3,           /* POINTER TO OLDEST RECORD      */ 00137000
*                     R1,           /* ADDRESS OF THE DATA TO WRITE  */ 00138000
*                     R0) RESTRICTED;/* LENGTH OF THE DATA TO WRITE  */ 00139000
*                   R3=RCBFREE+RCBFLNG;/* FIND ADDRESS OF OLDEST     */ 00140000
         LH    R3,RCBFLNG(,R12)                                    0148 00141000
         N     R3,@CF02089                                         0148 00142000
         AL    R3,RCBFREE(,R12)                                    0148 00143000
*/*  DUMMY ALLOCATION CODE NO LONGER NEEDED SINCE THE SPACE AT THE END  00144000
*    OF THE BUFFER WILL CONTAIN THE BEGINNING OF A WRAPPED HEADER  0149 00145000
*                                                             @ZA19199  00146000
*                                                                    */ 00147000
*                                                                  0149 00148000
*                   IF R3>=RCBBUFE THEN/* IF RCBBUFRS HAS BEEN     0149 00149000
*                                      WRAPPED AROUND, UPDATE THE  0149 00150000
*                                      RECORD POINTER                */ 00151000
         C     R3,RCBBUFE(,R12)                                    0149 00152000
         BL    @RF00149                                            0149 00153000
*                     R3=R3-RCBTLNG;                               0150 00154000
         LH    R14,RCBTLNG(,R12)                                DSK1193 00155000
         N     R14,@CF02089                                     DSK1193 00156000
         SLR   R3,R14                                           DSK1193 00157000
*                   RESPECIFY       /* BASE THIS BUFFER ENTRY ON     */ 00158000
*                    (RCBBUF) BASED(R3);/* THE CALCULATED ADDRESS    */ 00159000
@RF00149 DS    0H                                                  0152 00160000
*                   IF RCBBWRAP=YES×/* IS THIS A WRAPPED OR WTO      */ 00161000
*                       RCBBWTO=YES THEN/* RECORD                    */ 00162000
         TM    RCBBWRAP(R3),B'10100000'                            0152 00163000
         BZ    @RF00152                                            0152 00164000
*/********************************************************************/ 00165000
*/*                                                                  */ 00166000
*/* THE PURPOSE OF THE FREEREC SEGMENT IS TO FREE A RECORD IN THE RCB*/ 00167000
*/* AND MAKE AVAILABLE THE SPACE ALLOCATED TO IT                     */ 00168000
*/*                                                                  */ 00169000
*/********************************************************************/ 00170000
*                                                                  0153 00171000
*                     DO;           /* FREE THE RECORD               */ 00172000
*                       IF RCBBNBFR=NO THEN/* IF IT WAS BUFFERED THE */ 00173000
         TM    RCBBNBFR(R3),B'00001000'                            0154 00174000
         BNZ   @RF00154                                            0154 00175000
*                         RCBFLNG=RCBFLNG+/* LENGTH TO FREE IS THE   */ 00176000
*                             (RCBBLEN+/* DATA LENGTH PLUS           */ 00177000
*                             CONTLEN+/* CONTROL INFO LENGTH         */ 00178000
*                             SEVEN&/* ROUNDED TO DOUBLE WORD        */ 00179000
*                             'FFF8'X);                            0155 00180000
         LA    R14,23                                           DSK1193 00181000
         LH    R9,RCBBLEN(,R3)                                  DSK1193 00182000
         N     R9,@CF02089                                      DSK1193 00183000
         ALR   R14,R9                                           DSK1193 00184000
         N     R14,@CF01992                                     DSK1193 00185000
         LH    R9,RCBFLNG(,R12)                                 DSK1193 00186000
         N     R9,@CF02089                                      DSK1193 00187000
         ALR   R14,R9                                           DSK1193 00188000
         STH   R14,RCBFLNG(,R12)                                DSK1193 00189000
*                       ELSE                                       0156 00190000
*                         DO;       /* IF NOT BUFFERED       @G17EP5W*/ 00191000
         B     @RC00152                                         DSK1193 00192000
@RF00154 DS    0H                                                  0157 00193000
*                           RFY                                    0157 00194000
*                             R5 RSTD;/* RESTRICT REGISTER FOR ERROR    00195000
*                                      ID LENGTH             @G17EP5W*/ 00196000
*                           IF RCBBERFG=YES THEN/* IF ERRORID      0158 00197000
*                                      APPENDED IN RCB       @G17EP5W*/ 00198000
         TM    RCBBERFG(R3),B'00000010'                            0158 00199000
         BNO   @RF00158                                            0158 00200000
*                             R5=LENGTH(RCBBERID);/* THEN INCLUDE ITS   00201000
*                                      LENGTH FOR FREEING    @G17EP5W*/ 00202000
         LA    R5,10                                               0159 00203000
*                           ELSE                                   0160 00204000
*                             R5=ZERO;/* OTHERWISE FREE NO ADDITIONAL   00205000
*                                      SPACE                 @G17EP5W*/ 00206000
         B     @RC00158                                            0160 00207000
@RF00158 L     R5,ZERO                                             0160 00208000
*                           RCBFLNG=RCBFLNG+/* IF IT WAS NOT BUFFERED   00209000
*                                      THE                           */ 00210000
*                               (NBFRLEN+/* LENGTH IS (16 CONTROL +  */ 00211000
*                               R5+ /* LENGTH OF ERROR ID IF PRESENT    00212000
*                                      OR ZERO               @G17EP5W*/ 00213000
*                               SEVEN&/* 4 FOR DATA PTR) ROUNDED TO  */ 00214000
*                               'FFF8'X);/* DOUBLE WORD              */ 00215000
@RC00158 LA    R14,27                                           DSK1193 00216000
         ALR   R14,R5                                           DSK1193 00217000
         N     R14,@CF01992                                     DSK1193 00218000
         LH    R9,RCBFLNG(,R12)                                 DSK1193 00219000
         N     R9,@CF02089                                      DSK1193 00220000
         ALR   R14,R9                                           DSK1193 00221000
         STH   R14,RCBFLNG(,R12)                                DSK1193 00222000
*                           RFY                                    0162 00223000
*                             R5 UNRSTD;/* RELEASE LENGTH REGISTER 0162 00224000
*                                                            @G17EP5W*/ 00225000
*                         END;      /* END NON BUFFERED RECORD     0163 00226000
*                                                            @G17EP5W*/ 00227000
*                     END;          /* END FREE RECORD               */ 00228000
*                   ELSE            /* IF NOT WTO OR DUMMY ALLOC     */ 00229000
*                     DO;           /* AND NOT WRAPPED PROCESS LOGREC   00230000
*                                      RECORD                        */ 00231000
         B     @RC00152                                            0165 00232000
@RF00152 DS    0H                                                  0166 00233000
*                       IF RCBBNBFR=YES THEN/* IF NOT BUFFERED IN RCB*/ 00234000
         TM    RCBBNBFR(R3),B'00001000'                            0166 00235000
         BNO   @RF00166                                            0166 00236000
*                         DO;                                      0167 00237000
*                           R1=NBFRDATA;/* GET DATA ADDRESS FROM BUF */ 00238000
         L     R1,NBFRDATA+16(,R3)                                 0168 00239000
*                           GEN(LRA R1,ZIP(R1));/* INSURE REAL ADDR  */ 00240000
         LRA R1,ZIP(R1)                                                 00241000
*                         END;                                     0170 00242000
*                       ELSE        /* IF BUFFERED GET ADDRESS       */ 00243000
*                         R1=ADDR(RCBBDATA);/* OF DATA IN BUFFER     */ 00244000
         B     @RC00166                                            0171 00245000
@RF00166 LA    R1,RCBBDATA(,R3)                                    0171 00246000
*                       R0=RCBBLEN; /* OBTAIN LENGTH OF RECORD       */ 00247000
@RC00166 LH    R14,RCBBLEN(,R3)                                 DSK1193 00248000
         N     R14,@CF02089                                     DSK1193 00249000
         LR    R0,R14                                           DSK1193 00250000
*                       R15=RCZERO; /* INDICATE TO STF LOGREC RECORD    00251000
*                                      ADDR & LENGTH IN REGISTERS    */ 00252000
         SLR   R15,R15                                             0173 00253000
*/********************************************************************/ 00254000
*/*                                                                  */ 00255000
*/* THE PURPOSE OF THE FREEREC SEGMENT IS TO FREE A RECORD IN THE RCB*/ 00256000
*/* AND MAKE AVAILABLE THE SPACE ALLOCATED TO IT                     */ 00257000
*/*                                                                  */ 00258000
*/********************************************************************/ 00259000
*                                                                  0174 00260000
*                       DO;         /* FREE THE RECORD               */ 00261000
*                         IF RCBBNBFR=NO THEN/* IF IT WAS BUFFERED 0175 00262000
*                                      THE                           */ 00263000
         TM    RCBBNBFR(R3),B'00001000'                            0175 00264000
         BNZ   @RF00175                                            0175 00265000
*                           RCBFLNG=RCBFLNG+/* LENGTH TO FREE IS THE */ 00266000
*                               (RCBBLEN+/* DATA LENGTH PLUS         */ 00267000
*                               CONTLEN+/* CONTROL INFO LENGTH       */ 00268000
*                               SEVEN&/* ROUNDED TO DOUBLE WORD      */ 00269000
*                               'FFF8'X);                          0176 00270000
         AL    R14,@CF02073                                     DSK1193 00271000
         N     R14,@CF01992                                     DSK1193 00272000
         LH    R9,RCBFLNG(,R12)                                 DSK1193 00273000
         N     R9,@CF02089                                      DSK1193 00274000
         ALR   R14,R9                                           DSK1193 00275000
         STH   R14,RCBFLNG(,R12)                                DSK1193 00276000
*                         ELSE                                     0177 00277000
*                           DO;     /* IF NOT BUFFERED       @G17EP5W*/ 00278000
         B     @RC00175                                            0177 00279000
@RF00175 DS    0H                                                  0178 00280000
*                             RFY                                  0178 00281000
*                               R5 RSTD;/* RESTRICT REGISTER FOR   0178 00282000
*                                      ERROR ID LENGTH       @G17EP5W*/ 00283000
*                             IF RCBBERFG=YES THEN/* IF ERRORID    0179 00284000
*                                      APPENDED IN RCB       @G17EP5W*/ 00285000
         TM    RCBBERFG(R3),B'00000010'                            0179 00286000
         BNO   @RF00179                                            0179 00287000
*                               R5=LENGTH(RCBBERID);/* THEN INCLUDE     00288000
*                                      ITS LENGTH FOR FREEING      0180 00289000
*                                                            @G17EP5W*/ 00290000
         LA    R5,10                                               0180 00291000
*                             ELSE                                 0181 00292000
*                               R5=ZERO;/* OTHERWISE FREE NO       0181 00293000
*                                      ADDITIONAL SPACE      @G17EP5W*/ 00294000
         B     @RC00179                                            0181 00295000
@RF00179 L     R5,ZERO                                             0181 00296000
*                             RCBFLNG=RCBFLNG+/* IF IT WAS NOT     0182 00297000
*                                      BUFFERED THE                  */ 00298000
*                                 (NBFRLEN+/* LENGTH IS (16 CONTROL +*/ 00299000
*                                 R5+/* LENGTH OF ERROR ID IF PRESENT   00300000
*                                      OR ZERO               @G17EP5W*/ 00301000
*                                 SEVEN&/* 4 FOR DATA PTR) ROUNDED TO*/ 00302000
*                                 'FFF8'X);/* DOUBLE WORD            */ 00303000
@RC00179 LA    R14,27                                           DSK1193 00304000
         ALR   R14,R5                                           DSK1193 00305000
         N     R14,@CF01992                                     DSK1193 00306000
         LH    R9,RCBFLNG(,R12)                                 DSK1193 00307000
         N     R9,@CF02089                                      DSK1193 00308000
         ALR   R14,R9                                           DSK1193 00309000
         STH   R14,RCBFLNG(,R12)                                DSK1193 00310000
*                             RFY                                  0183 00311000
*                               R5 UNRSTD;/* RELEASE LENGTH REGISTER    00312000
*                                                            @G17EP5W*/ 00313000
*                           END;    /* END NON BUFFERED RECORD     0184 00314000
*                                                            @G17EP5W*/ 00315000
*                       END;        /* END FREE RECORD               */ 00316000
@RC00175 DS    0H                                                  0186 00317000
*                     END;          /* END LOGREC PROCESSING         */ 00318000
*                   IF RCBFLNG=RCBTLNG&/* IF THERE ARE NO RECORDS AND*/ 00319000
*                       R15^=RCZERO THEN/* ONE WAS NOT FOUND THIS  0187 00320000
*                                      PASS                          */ 00321000
@RC00152 CLC   RCBFLNG(2,R12),RCBTLNG(R12)                         0187 00322000
         BNE   @RF00187                                            0187 00323000
         LTR   R15,R15                                             0187 00324000
         BZ    @RF00187                                            0187 00325000
*                     R15=RCFOUR;   /* NOTIFY STF NO RECORDS         */ 00326000
         LA    R15,4                                               0188 00327000
*                   RESPECIFY       /* RELEASE REGISTERS FROM        */ 00328000
*                    (R3,           /* POINTER TO THE OLDEST RECORD  */ 00329000
*                     R1,           /* ADDRESS OF DATA TO WRITE      */ 00330000
*                     R0) UNRESTRICTED;/* LENGTH OF DATA TO WRITE    */ 00331000
@RF00187 DS    0H                                                  0190 00332000
*                 END;              /* END BUFFER SEARCH             */ 00333000
@DE00146 C     R15,@CF00045                                        0190 00334000
         BE    @DL00146                                            0190 00335000
*             END;                  /* END EMERGENCY PROCESSING      */ 00336000
*         END;                      /* END EMERPROC                  */ 00337000
*       ELSE                        /* IF NOT AN EMERGENCY REQUEST   */ 00338000
*         DO;                       /* CONTINUE RECORD PROCESSING    */ 00339000
         B     @RC00114                                            0193 00340000
@RF00114 DS    0H                                                  0194 00341000
*           R12=RTCTRCB;            /* SET UP ADDRESSIBILTY FOR RCB  */ 00342000
         L     R14,CVTPTR                                       DSK1193 00343000
         L     R14,CVTRTMCT-CVTMAP(,R14)                        DSK1193 00344000
         L     R12,RTCTRCB-RTCT(,R14)                           DSK1193 00345000
*/********************************************************************/ 00346000
*/*                                                                  */ 00347000
*/* THE PURPOSE OF THE ESTRCV SEGMENT IS TO ESTABLISH RECOVERY       */ 00348000
*/* FOR THE RECORDING REQUEST ROUTINE. RECOVERY IS ESTABLISHED       */ 00349000
*/* ACCORDING TO THE STATE OF THE CALLER. THIS IS DETERMINED BY      */ 00350000
*/* THE FLAGS SET IN REGISTER ZERO BY THE RECORD MACRO EXPANSION     */ 00351000
*/* AND THE KEYWORD SPECIFIED BY THE CALLER FOR RCVRY = ON THE       */ 00352000
*/* RECORD MACRO                                                     */ 00353000
*/*                                                                  */ 00354000
*/********************************************************************/ 00355000
*                                                                  0195 00356000
*           RESPECIFY               /* RESTRICT REGISTERS FOR        */ 00357000
*            (R1,                   /* RETURN OF GETMAINED AREA      */ 00358000
*             R2,                   /* ADDRESS OF RECOVERY ROUTINE   */ 00359000
*             R3,                   /* ADDRESS OF RECOVERY PARMLIST  */ 00360000
*             R4) RESTRICTED;       /* WORK REGISTER FOR SETFRR      */ 00361000
*           TRUNCFLG=NO;            /* INITIALIZE TRUNCATED FLAG   0196 00362000
*                                      (OFF)                         */ 00363000
*           OPTNOBUF=NO;            /* INITIALIZE NOBUF OFF (OPT)    */ 00364000
*           NOESTAE=YES;            /* INDICATES GETMAIN NOT       0198 00365000
*                                      SUCESSFUL RESET IF GETMAIN  0198 00366000
*                                      SUCESSFUL                     */ 00367000
*           UPACNT=NO;              /* INIT ACTIVE COUNT SWITCH OFF  */ 00368000
         OI    NOESTAE(R13),B'00100000'                            0199 00369000
         NI    TRUNCFLG(R13),B'00101111'                           0199 00370000
*           R2=ADDR(FRREP);         /* GET ADDRESS OF RECOVERY     0200 00371000
*                                      ROUTINE                       */ 00372000
         LA    R2,FRREP                                            0200 00373000
*           IF ESTAEREQ=YES THEN    /* THE CALLER REQUESTED RECOVERY */ 00374000
         TM    ESTAEREQ(R13),B'10000000'                           0201 00375000
         BNO   @RF00201                                            0201 00376000
*             DO;                   /* VIA ESTAE AS HE WAS NOT LOCKED   00377000
*                                      DISABLED OR IN SRB MODE       */ 00378000
*               DO;                 /* GETMAIN (RC)                0203 00379000
*                                      LV(LENGTH(GMSPACE)) SP(253)   */ 00380000
*                 RESPECIFY                                        0204 00381000
*                  (GPR01F,                                        0204 00382000
*                   GPR15F,                                        0204 00383000
*                   GPR00F) RESTRICTED;                            0204 00384000
*                 GPR01F=0;         /* REG 1 MUST BE ZERO            */ 00385000
         SLR   R1,R1                                            DSK1193 00386000
*                 GPR15F=0;         /* RC-TYPE GETMAIN               */ 00387000
         SLR   R15,R15                                          DSK1193 00388000
*                 GPR00F=LENGTH(GMSPACE);/* LENGTH REQUESTED         */ 00389000
         LA    R0,40                                            DSK1193 00390000
*                 GPR15F=GPR15F×((253)*256);/* SP IN BYTE 2          */ 00391000
         O     R15,@CF02076                                     DSK1193 00392000
*                 SVC(120);         /* RC/RU-FORM OF GETMAIN         */ 00393000
         SVC   120                                                 0209 00394000
*                 RESPECIFY                                        0210 00395000
*                  (GPR01F,                                        0210 00396000
*                   GPR15F,                                        0210 00397000
*                   GPR00F) UNRESTRICTED;                          0210 00398000
*               END;                /* GETMAIN (RC)                0211 00399000
*                                      LV(LENGTH(GMSPACE)) SP(253) 0211 00400000
*                                      GET SPACE FOR ESTAE LISTS     */ 00401000
*               IF R15=ZERO THEN    /* IF GETMAIN SUCESSFUL          */ 00402000
         C     R15,ZERO                                            0212 00403000
         BNE   @RF00212                                            0212 00404000
*                 DO;               /* PROCESS ESTAE                 */ 00405000
*                   GMAD=R1;        /* SAVE THE ADDRESS              */ 00406000
         ST    R1,GMAD(,R13)                                       0214 00407000
*                   NOESTAE=NO;     /* INDICATE GETMAIN SUCESSFUL    */ 00408000
         NI    NOESTAE(R13),B'11011111'                            0215 00409000
*                   SVC60LST=MFLESTAE;/* SET UP FOR E FORM ESTAE     */ 00410000
         L     R14,GMAD(,R13)                                   DSK1193 00411000
         MVC   SVC60LST(16,R14),MFLESTAE                        DSK1193 00412000
*                   R1=ADDR(SVC60LST);/* ADDRESS LSIT FORM ESTAE     */ 00413000
         LA    R1,SVC60LST(,R14)                                DSK1193 00414000
*                   R3=ADDR(RCVPLIST);/* ADDRESS ESTAE PARMLST       */ 00415000
         LR    R3,R14                                           DSK1193 00416000
*                   GEN(ESTAE PARAM=(R3),MF=(E,(1)));/* ISSUE ESTAE  */ 00417000
         ESTAE PARAM=(R3),MF=(E,(1))                                    00418000
*                 END;                                             0220 00419000
*               ELSE                                               0221 00420000
*                 GMAD=0;           /* NOTE NO WORKAREA AVAILABLE  0221 00421000
*                                                            @ZM40310   00422000
*                                                            @ZA19199*/ 00423000
         B     @RC00212                                            0221 00424000
@RF00212 SLR   R14,R14                                          DSK1193 00425000
         ST    R14,GMAD(,R13)                                   DSK1193 00426000
*             END;                                                 0222 00427000
@RC00212 DS    0H                                                  0223 00428000
*           IF FRRREQ=YES THEN      /* THE CALLER REQUESTED RECOVERY */ 00429000
@RF00201 TM    FRRREQ(R13),B'01000000'                             0223 00430000
         BNO   @RF00223                                            0223 00431000
*             DO;                   /* VIA SETFRR AS HE WAS IN ONE OF   00432000
*                                      THE ABOVE STATES              */ 00433000
*               GEN(SETFRR A,FRRAD=(R2),PARMAD=(R3),WRKREGS=(R3,R4));   00434000
         SETFRR A,FRRAD=(R2),PARMAD=(R3),WRKREGS=(R3,R4)                00435000
*               GMAD=R3;            /* CHECKPOINT THE PARAMETER AREA    00436000
*                                      ADDRESS               @ZM40310*/ 00437000
         ST    R3,GMAD(,R13)                                       0226 00438000
*             END;                                                 0227 00439000
*           IF FRRREQ=YES×NOESTAE=NO THEN/* IF ESTAE WAS DONE OR   0228 00440000
*                                      FRRREQ                        */ 00441000
@RF00223 TM    FRRREQ(R13),B'01000000'                             0228 00442000
         BO    @RT00228                                            0228 00443000
         TM    NOESTAE(R13),B'00100000'                            0228 00444000
         BNZ   @RF00228                                            0228 00445000
@RT00228 DS    0H                                                  0229 00446000
*             DO;                   /* INITIALIZE THE RECOVERY     0229 00447000
*                                      PARMLIST                      */ 00448000
*               RFY                                                0230 00449000
*                 GMSPACE BASED(R3);/* SET UP BASE FOR PARMLIST      */ 00450000
*               RETRY8=R8;          /* SAVE BASE REGISTER            */ 00451000
         ST    R8,RETRY8(,R3)                                      0231 00452000
*               RETRY13=R13;        /* SAVE POINTER TO SAVEAREA      */ 00453000
         ST    R13,RETRY13(,R3)                                    0232 00454000
*               RETRYADR=ADDR(RETRYRTN);/* SAVE ADDRESS OF RETRY   0233 00455000
*                                      ROUTINE                       */ 00456000
         LA    R14,RETRYRTN                                     DSK1193 00457000
         ST    R14,RETRYADR(,R3)                                DSK1193 00458000
*               RFY                                                0234 00459000
*                 GMSPACE BASED(GMAD);/* SET UP BASE FOR PARMLIST    */ 00460000
*               RESPECIFY           /* RELEASE REGISTERS FROM        */ 00461000
*                (R1,                                              0235 00462000
*                 R2,               /* RECOVERY ROUTINE ADDRESS      */ 00463000
*                 R3,               /* ADDRESS OF RECOVERY PARMLIST  */ 00464000
*                 R4) UNRESTRICTED; /* WORKREGISTER FOR SETFRR       */ 00465000
*             END;                                                 0236 00466000
*           IF RTCTRTER=YES×        /* IF ANY TEMPORARY OR PERMANENT */ 00467000
*               RTCTRPER=YES THEN   /* ERRORS HAVE BEEN SUFFERED     */ 00468000
@RF00228 L     R14,CVTPTR                                       DSK1193 00469000
         L     R14,CVTRTMCT-CVTMAP(,R14)                        DSK1193 00470000
         TM    RTCTRFLG-RTCT(R14),RTCTRTER+RTCTRPER             DSK1193 00471000
         BZ    A000316                                          DSK1193 00472010
*/********************************************************************/ 00473000
*/*                                                                  */ 00474000
*/* THE PURPOSE OF THE ERRPROC SEGMENT IS TO DETERMINE THE NATURE    */ 00475000
*/* OF A PREVIOUSLY SUFFERED ERROR AND TO NOTIFY THE REQUESTOR THE   */ 00476000
*/*  REASON HIS REQUEST WAS NOT HONORED                              */ 00477000
*/*                                                                  */ 00478000
*/********************************************************************/ 00479000
*                                                                  0238 00480000
*             DO;                                                  0238 00481000
*               IF RTCTRPER=YES THEN/* IF A PERMANENT ERROR RECORDING*/ 00482000
         TM    RTCTRFLG-RTCT(R14),RTCTRPER                      DSK1193 00483000
         BNO   @RF00239                                            0239 00484000
*                 R15=RCTWENTY;     /* IS INACTIVE. NOTIFY CALLER    */ 00485000
         LA    R15,20                                              0240 00486000
*               IF RTCTRTER=YES&    /* IF A TEMPORARY ERROR AND NO   */ 00487000
*                   RTCTRPER=NO THEN/* PERMANENT ERRORS              */ 00488000
@RF00239 L     R14,CVTPTR                                       DSK1193 00489000
         L     R14,CVTRTMCT-CVTMAP(,R14)                        DSK1193 00490000
         TM    RTCTRFLG-RTCT(R14),RTCTRTER                      DSK1193 00491000
         BNO   @RC00237                                         DSK1193 00492000
         TM    RTCTRFLG-RTCT(R14),RTCTRPER                      DSK1193 00493000
         BNZ   @RC00237                                         DSK1193 00494000
*                 DO;               /* POST TASK TO INITIATE CLEANUP */ 00495000
*/********************************************************************/ 00496000
*/*                                                                  */ 00497000
*/* THE PURPOSE OF THE SCHSRB SEGMENT IS TO SCHEULE THE RECORDING    */ 00498000
*/* SRB.  THE CODE THAT RUNS UNDER THIS SRB WILL POST THE RECORDING  */ 00499000
*/* TASK.                                                            */ 00500000
*/*                                                                  */ 00501000
*/********************************************************************/ 00502000
*                                                                  0243 00503000
*                   RESPECIFY       /* RESTRICT REGISTERS FOR        */ 00504000
*                    (R3,           /* SAVING SRB IN USE FIELD       */ 00505000
*                     R4) RESTRICTED;/* CHECK & SET OF IN USE FLAG   */ 00506000
*                   R3=RCBCS1;      /* SAVE SRB IN USE FLAG          */ 00507000
         L     R12,RTCTRCB-RTCT(,R14)                           DSK1193 00507010
         L     R3,RCBCS1(,R12)                                     0244 00508000
*TEST2:                             /* TO SEE IF SRB IN USE          */ 00509000
*                   R4=R3;          /* MAKE IT AVAILABLE TO SET      */ 00510000
TEST2    LR    R4,R3                                               0245 00511000
*                   GENERATE REFS(R4) FLOWS(NOSCHED2);             0246 00512000
          CLM  R4,4,INUSEMSK       /*IS SRB IN USE                  */  00513000
          BNL NOSCHED2            /* IF YES SKIP SCHEDULE           */  00514000
*                   R4=R4×INUSEON;  /* IF NOT IN USE SET IN USE      */ 00515000
         O     R4,@CF00165                                         0247 00516000
*                   CS(R3,R4,RCBCS1);/* PUT UPDATED FLAG IN THE RCB  */ 00517000
         CS    R3,R4,RCBCS1(R12)                                DSK1193 00518000
*                   BC(4,TEST2);    /* IF RCB NOT ALTERED            */ 00519000
         BC    4,TEST2                                             0249 00520000
*                   RESPECIFY       /* RESTRICT REGISTER FOR         */ 00521000
*                    (R5,                                          0250 00522000
*                     R7) RESTRICTED;/* ADDRESS OF SRB AND SAVE RCODE*/ 00523000
*                   R7=R15;         /* SAVE RETURN CODE AROUND     0251 00524000
*                                      SCHEDULE                      */ 00525000
         LR    R7,R15                                              0251 00526000
*                   R5=ADDR(RCBSRB);/* GET ADDRESS OF SRB            */ 00527000
         LA    R5,RCBSRB(,R12)                                     0252 00528000
         LA    R14,A000A68                                      DSK1193 00528010
         ST    R14,SRBEP-SRB(,R5)                               DSK1193 00528020
         ST    R8,SRBPARM-SRB(,R5)                              DSK1193 00528030
*                   GEN(SCHEDULE SRB=(R5),SCOPE=GLOBAL);/* SCHEDULE     00529000
*                                      THE SRB                       */ 00530000
         SCHEDULE SRB=(R5),SCOPE=GLOBAL                                 00531000
*                   R15=R7;         /* RESTORE RETURN CODE           */ 00532000
         LR    R15,R7                                              0254 00533000
*NOSCHED2:                          /* SRB WAS IN USE AND NOT      0255 00534000
*                                      SCHEDULED                     */ 00535000
*                   RESPECIFY       /* RELEASE REGISTERS FROM        */ 00536000
*                    (R3,           /* SAVING THE SRB IN USE FLAG    */ 00537000
*                     R4,           /* CHECK & SET OF IN USE FLAG    */ 00538000
*                     R7,           /* SAVING RETURN CODE            */ 00539000
*                     R5) UNRESTRICTED;/* ADDRESS OF SRB             */ 00540000
NOSCHED2 DS    0H                                                  0256 00541000
*                   R15=RC6TEEN;    /* INDICATE REQUEST NOT SCHEDULED   00542000
*                                      DUE TO A PROCESSING ERROR     */ 00543000
         LA    R15,16                                              0256 00544000
*                 END;              /* END TEMPORARY ERROR PROCESSING*/ 00545000
*             END;                  /* END ERROR PROCESSING          */ 00546000
*           ELSE                    /* IF NO PREVIOUS ERRORS BEING   */ 00547000
*             DO;                   /* PROCESSED CONTINUE WITH RECORD   00548000
*                                      PROCESSING                    */ 00549000
         B     @RC00237                                            0259 00550000
A000316  DS    0H                                               DSK1193 00550010
         TM    WTOREQ(R13),B'00100000'                          DSK1193 00550020
         BNO   @RF00237                                         DSK1193 00550030
         AL    R12,A000AD8                                      DSK1193 00550040
@RF00237 DS    0H                                                  0260 00551000
*/********************************************************************/ 00552000
*/*                                                                  */ 00553000
*/* THE PURPOSE OF THE INCACNT SEGMENT IS TO INCREMENT THE ACTIVE    */ 00554000
*/*  REQUEST COUNT. THIS COUNT IS USED TO INDICATE THE NUMBER OF     */ 00555000
*/*  REQUESTS CURRENTLY MANIPULATING THE RCB. IT IS USED BY THE TASK */ 00556000
*/*  TO DETERMINE WHEN TO INITIATE CLEANUP IN THE EVENT IT BECOMES   */ 00557000
*/*  NECESSARY                                                       */ 00558000
*/*                                                                  */ 00559000
*/********************************************************************/ 00560000
*                                                                  0260 00561000
*               RESPECIFY           /* RESTRICT REGISTERS FOR        */ 00562000
*                (R3,               /* SAVING THE ACTIVE COUNT       */ 00563000
*                 R4) RESTRICTED;   /* INCREMENTING THE ACTIVE COUNT */ 00564000
*               R3=RCBCS2;          /* SAVE CURRENT ACTIVE REQUEST 0261 00565000
*                                      COUNT                         */ 00566000
         L     R3,RCBCS2(,R12)                                     0261 00567000
*TRYCS2:                            /* RCBACNT WILL BE INCREMENTED 0262 00568000
*                                      VIA CS EFFECTING SERIALIZATION*/ 00569000
*               R4=R3;              /* MAKE AVAILABLE FOR          0262 00570000
*                                      INCREMENTING                  */ 00571000
TRYCS2   LR    R4,R3                                               0262 00572000
*               R4=R4+HIHALF1;      /* INCREMENT ACTIVE REQUEST CT.  */ 00573000
         AL    R4,HIHALF1                                          0263 00574000
*               CS(R3,R4,RCBCS2);   /* PUT UPDATED COUNT IN RCB      */ 00575000
         CS    R3,R4,RCBCS2(R12)                                DSK1193 00576000
*               BC(4,TRYCS2);       /* IF RCBACNT IS NOT ALTERED     */ 00577000
         BC    4,TRYCS2                                            0265 00578000
*               UPACNT=YES;         /* INDICATE ACTIVE COUNT UPDATED    00579000
*                                      FOR THIS REQUEST      @YM05488*/ 00580000
         OI    UPACNT(R13),B'00010000'                             0266 00581000
*               RESPECIFY           /* FREE REGISTERS FROM           */ 00582000
*                (R3,               /* SAVING ACTIVE COUNT           */ 00583000
*                 R4) UNRESTRICTED; /* INCREMENTING ACTIVE COUNT     */ 00584000
*/********************************************************************/ 00585000
*/*                                                                  */ 00586000
*/* THE PURPOSE OF THE FNDSPACE SEGMENT IS TO FIND AND ALLOCATE      */ 00587000
*/* REQUIRED SPACE IN THE RCB TO BUFFER THE CURRENTLY REQUESTED      */ 00588000
*/* RECORD. INCLUDED ARE SEGMENTS TO DETERMINE SPACE REQUIREMENTS,   */ 00589000
*/* TO PROCESS ALLOCATION IF SPACE IS AVAILABLE, AND TO RECALCULATE  */ 00590000
*/* SPACE REQUIREMENTS IF POSSIBLE AND NECESSARY                     */ 00591000
*/*                                                                  */ 00592000
*/********************************************************************/ 00593000
*                                                                  0268 00594000
*               RESPECIFY           /* RESTRICT REGISTERS FOR        */ 00595000
*                (R6,               /* CALCULATING SPACE REQUIREMENT */ 00596000
*                 R7) RESTRICTED;   /* MAINTAINING HEADER LENGTH     */ 00597000
*/********************************************************************/ 00598000
*/*                                                                  */ 00599000
*/* THE PURPOSE OF THE CALCSPCE SEGMENT IS TO DETERMINE THE SPACE    */ 00600000
*/* REQUIREMENT IN THE RCB FOR A PARTICULAR REQUEST. THE AMOUNT      */ 00601000
*/* IS BASED ON THE REQUIRED BUILD FUNCTIONS AS INDICATED BY THE     */ 00602000
*/* FLAG SETTINGS AND DATALENGTH IN REGISTER ZERO                    */ 00603000
*/*                                                                  */ 00604000
*/********************************************************************/ 00605000
*                                                                  0269 00606000
*               R6=CONTLEN;         /* ALL BUFFER ENTRIES INCLUDE THE   00607000
*                                      RECORD CONTROL INFORMATION    */ 00608000
         LA    R6,16                                               0269 00609000
*/* STATEMENT AT FLAGGED COMMENT BELOW MOVED FROM HERE. STATEMENT  0270 00610000
*   HERE CAUSED ERRORID TO BE CONSIDERED PART OF RECORD WHICH MUST BE   00611000
*   CONTIGUOUS, BUT ERRORID NEED NOT BE CONTIGUOUS WITH HEADER     0270 00612000
*                                                            @ZA16445*/ 00613000
*                                                                  0270 00614000
*               IF NBUFREQ=YES THEN /* IF NON BUFFERED REQUEST       */ 00615000
         TM    NBUFREQ(R13),B'00010000'                            0270 00616000
         BNO   @RF00270                                            0270 00617000
*                 DO;                                              0271 00618000
*                   R6=R6+(LENGTH(NBFRDATA));/* ADD FOUR BYTES FOR 0272 00619000
*                                      DATA ADDRESS                  */ 00620000
         AL    R6,@CF00039                                         0272 00621000
*                   R7=R6;          /* HEADER AND ENTRY ARE EQUAL    */ 00622000
         LR    R7,R6                                               0273 00623000
*                 END;              /* END NON BUFFERED CALCULATION  */ 00624000
*               ELSE                /* IF BUFFERING REQUESTED        */ 00625000
*                 DO;               /* ADDITIONAL SPACE REQUIRED AS     00626000
*                                      FOLLOWS                       */ 00627000
         B     @RC00270                                            0275 00628000
@RF00270 DS    0H                                                  0276 00629000
*                   IF HDRREQ=YES THEN/* IF AR149 HEADER REQUESTED   */ 00630000
         TM    HDRREQ(R13),B'00001000'                             0276 00631000
         BNO   @RF00276                                            0276 00632000
*                     DO;           /* ADD LENGTH OF HEADER          */ 00633000
*                       R6=R6+(LENGTH(HDR));                       0278 00634000
         AL    R6,@CF00111                                         0278 00635000
*                       IF JOBNMREQ=YES THEN/* IF JOBNAME REQUESTED  */ 00636000
         TM    JOBNMREQ(R13),B'00000100'                           0279 00637000
         BNO   @RF00279                                            0279 00638000
*                         R6=R6+(LENGTH(RCBBJOBN));/* ADD 8 BYTES  0280 00639000
*                                      REQUIRED FOR JOBNAME          */ 00640000
         AL    R6,@CF00032                                         0280 00641000
*                     END;          /* END HEADER PROCESSING         */ 00642000
@RF00279 DS    0H                                                  0282 00643000
*                   R7=R6;          /* HEADER LENGTH BEFORE ADDING 0282 00644000
*                                      DATA                          */ 00645000
@RF00276 LR    R7,R6                                               0282 00646000
*                   R6=R6+DATLEN;   /* ADD LENGTH OF DATA TO BUFFER  */ 00647000
         LH    R14,DATLEN(,R13)                                 DSK1193 00648000
         N     R14,@CF02089                                     DSK1193 00649000
         ALR   R6,R14                                           DSK1193 00650000
*                 END;              /* END BUFFERED CALCULATION      */ 00651000
*/* FOLLOWING STATEMENT MOVED FROM FLAGGED COMMENT ABOVE     @ZA16445*/ 00652000
*                                                                  0285 00653000
*               IF ERRIDREQ=YES THEN/* IF AN ERROR ID WAS REQUESTED     00654000
*                                                            @G17EP5W*/ 00655000
@RC00270 TM    ERRIDREQ(R13),B'00000001'                           0285 00656000
         BNO   @RF00285                                            0285 00657000
*                 R6=R6+            /* THEN ADD ITS LENGTH IN WITH 0286 00658000
*                                      THE                           */ 00659000
*                     LENGTH(RCBBERID);/* SPACE REQUIREMENTS @G17EP5W*/ 00660000
         AL    R6,@CF00105                                         0286 00661000
*               RESPECIFY           /* RESTRICT REGISTERS FOR        */ 00662000
*                (R2,               /* SAVING FREE POINTER,          */ 00663000
*                 R3,               /* FREE LENGTH & DUMMY         0287 00664000
*                                      DISPLACEMENT                  */ 00665000
*                 R4,               /* UPDATING FREE POINTER,        */ 00666000
*                 R5,               /* FREE LENGTH & DUMMY         0287 00667000
*                                      DISPLACEMENT                  */ 00668000
*                 R10,              /* CALCULATING NEW FREE LENGTH   */ 00669000
*                 R9) RESTRICTED;   /* SWITCH FOR LOOP CONTROL       */ 00670000
@RF00285 DS    0H                                                  0288 00671000
*               R15=RCZERO;         /* PRIME THE RETURN CODE         */ 00672000
         SLR   R15,R15                                             0288 00673000
*               R9=LOOPCODE;        /* SET SWITCH FOR LOOP CONTROL   */ 00674000
         LA    R9,1                                                0289 00675000
*               DO WHILE(R9=LOOPCODE);/* DETERMINE IF SPACE AVAILABLE   00676000
*                                      AND ALLOCATE IT OR RECALCULATE   00677000
*                                      SPACE AND RECHECK FOR       0290 00678000
*                                      AVAILABILITY                  */ 00679000
         B     @DE00290                                            0290 00680000
@DL00290 DS    0H                                                  0291 00681000
*                 RESPECIFY         /* RESTRICT REGISTER FOR         */ 00682000
*                  (R11) RESTRICTED;/* ADDRESS OF FIELDS FOR LOAD    */ 00683000
*                 R11=ADDR(RCBCDS); /* OBTAIN ADDRESS OF DOUBLE WORD    00684000
*                                      CONTAINING FREE PTR,FREE    0292 00685000
*                                      LENGTH AND DUMMY DISPLACENENT */ 00686000
         LA    R11,RCBCDS(,R12)                                    0292 00687000
*                 GEN(LM R2,R3,ZIP(R11));/* SAVE FIELDS IN REGISTERS */ 00688000
         LM R2,R3,ZIP(R11)                                              00689000
*                 RESPECIFY         /* RELEASE REGISTER FROM         */ 00690000
*                  (R11) UNRESTRICTED;/* ADDRESS OF FIELDS FOR LOAD  */ 00691000
*                 R4=R2;            /* MAKE FREE POINTER AVAILABLE TO   00692000
*                                      UPDATE                        */ 00693000
         LR    R4,R2                                               0295 00694000
*                 R5=R3;            /* MAKE FREE LENGTH AND DUMMY  0296 00695000
*                                      DISPLACEMENT AVAILABLE TO   0296 00696000
*                                      UPDATE                        */ 00697000
         LR    R5,R3                                               0296 00698000
*                 R10=R5;           /* PUT FREE LEN & DUM IN UNIQ  0297 00699000
*                                      REGS                          */ 00700000
         LR    R10,R5                                              0297 00701000
*                 GENERATE REFS(R5,R10);                           0298 00702000
          SLL   R5,HALFREG        /* ZERO HIGH ORDER TWO BYTES       */ 00703000
          SRL   R5,HALFREG        /*  OF REG OF DUMMY DISPLACEMENT   */ 00704000
          SRL   R10,HALFREG       /* MOVE FREE LENGTH TO LOW HALF REG*/ 00705000
*                 IF R10>=R6 THEN   /* SPACE AVAILABLE FOR THIS    0299 00706000
*                                      RECORD?                       */ 00707000
         CR    R10,R6                                              0299 00708000
         BL    @RF00299                                            0299 00709000
*/********************************************************************/ 00710000
*/*                                                                  */ 00711000
*/* IF SPACE IS AVAILABLE FOR THE RECORD, THE SPACE IS ALLOCATED.    */ 00712000
*/*  (THE CHECK FOR CONTIGUOUS HEADER SPACE IS NO LONGER NEEDED      */ 00713000
*/*   BECAUSE THE HEADER CAN NOW WRAP ALSO)                          */ 00714000
*/*                                                           @ZA19199  00715000
*                                                                    */ 00716000
*/********************************************************************/ 00717000
*                                                                  0300 00718000
*                   DO;                                            0300 00719000
*                     R10=R10-(R6+  /* NEW FREE LENGTH IS MINUS THIS */ 00720000
*                         SEVEN&'FFFFFFF8'X);/* RECORD ROUNDED TO DBL   00721000
*                                      WORD                          */ 00722000
         LA    R14,7                                            DSK1193 00723000
         ALR   R14,R6                                           DSK1193 00724000
         N     R14,@CF02011                                     DSK1193 00725000
         SLR   R10,R14                                          DSK1193 00726000
*                     R4=R4+(R6+    /* NEW FREE PTR IS PLUS THIS REC */ 00727000
*                         SEVEN&'FFFFFFF8'X);/* ROUNDED TO DBL WORD  */ 00728000
         ALR   R4,R14                                           DSK1193 00729000
*                     IF R4>=RCBBUFE THEN/* DOES THIS RECORD WRAP  0303 00730000
*                                      BUFFER                        */ 00731000
         C     R4,RCBBUFE(,R12)                                    0303 00732000
         BL    @RF00303                                            0303 00733000
*                       R4=R4-RCBTLNG;/* IF SO UPDATE FREE POINTER   */ 00734000
         LH    R14,RCBTLNG(,R12)                                DSK1193 00735000
         N     R14,@CF02089                                     DSK1193 00736000
         SLR   R4,R14                                           DSK1193 00737000
*                     GEN(SLL R10,HALFREG);/* MOVE FREE LENGTH TO  0305 00738000
*                                      HIGH HALF OF REGISTER         */ 00739000
@RF00303 DS    0H                                                  0305 00740000
         SLL R10,HALFREG                                                00741000
*                     R5=R5×R10;    /* PUT IN REG WITH DUMMY DISP    */ 00742000
         OR    R5,R10                                              0306 00743000
*                     CDS(R2,R4,RCBCDS);/* PUT UPDATED VALUES IN RCB    00744000
*                                      IF                            */ 00745000
         CDS   R2,R4,RCBCDS(R12)                                   0307 00746000
*                     BC(4,SKPRESET);/* RCB HASN'T BEEN ALTERED      */ 00747000
         BC    4,SKPRESET                                          0308 00748000
*                     R9=NOLOOP;    /* SPACE ALLOCATED - GET OUT     */ 00749000
         SLR   R9,R9                                               0309 00750000
*SKPRESET:                          /* RCB HAS BEEN ALTERED TRY AGAIN*/ 00751000
*                   END;            /* END REC SPACE AVAIL PROCESSING*/ 00752000
*                 ELSE              /* SPACE NOT AVAILABLE           */ 00753000
*/********************************************************************/ 00754000
*/*                                                                  */ 00755000
*/* IF SPACE FOR RECORD NOT AVAILABLE,REQUIRED SPACE IS RECALCULATED */ 00756000
*/* IF POSSIBLE. POSSIBLE RECALCULATIONS ARE FOR A NON BUFFERED OPT  */ 00757000
*/* REQUEST OR A TRUNCATED LOGREC REQUEST                            */ 00758000
*/*                                                                  */ 00759000
*/********************************************************************/ 00760000
*                                                                  0311 00761000
*                   DO;                                            0311 00762000
         B     @RC00299                                            0311 00763000
@RF00299 DS    0H                                                  0312 00764000
*                     IF BUFREQ=NO&NBUFREQ=NO THEN/* IF BUFFERING WAS   00765000
*                                      OPTIONAL                      */ 00766000
         TM    BUFREQ(R13),B'00110000'                             0312 00767000
         BNZ   @RF00312                                            0312 00768000
*                       DO;         /* PROCESS BUFFERING TO        0313 00769000
*                                      NO-BUF'ING                    */ 00770000
*                         NBUFREQ=YES;/* INDICATE NO BUFFERING       */ 00771000
         OI    NBUFREQ(R13),B'00010000'                            0314 00772000
*/********************************************************************/ 00773000
*/*                                                                  */ 00774000
*/* THE PURPOSE OF THE CALCSPCE SEGMENT IS TO DETERMINE THE SPACE    */ 00775000
*/* REQUIREMENT IN THE RCB FOR A PARTICULAR REQUEST. THE AMOUNT      */ 00776000
*/* IS BASED ON THE REQUIRED BUILD FUNCTIONS AS INDICATED BY THE     */ 00777000
*/* FLAG SETTINGS AND DATALENGTH IN REGISTER ZERO                    */ 00778000
*/*                                                                  */ 00779000
*/********************************************************************/ 00780000
*                                                                  0315 00781000
*                         R6=CONTLEN;/* ALL BUFFER ENTRIES INCLUDE 0315 00782000
*                                      THE RECORD CONTROL INFORMATION*/ 00783000
         LA    R6,16                                               0315 00784000
*/* STATEMENT AT FLAGGED COMMENT BELOW MOVED FROM HERE. STATEMENT  0316 00785000
*   HERE CAUSED ERRORID TO BE CONSIDERED PART OF RECORD WHICH MUST BE   00786000
*   CONTIGUOUS, BUT ERRORID NEED NOT BE CONTIGUOUS WITH HEADER     0316 00787000
*                                                            @ZA16445*/ 00788000
*                                                                  0316 00789000
*                         IF NBUFREQ=YES THEN/* IF NON BUFFERED    0316 00790000
*                                      REQUEST                       */ 00791000
         TM    NBUFREQ(R13),B'00010000'                            0316 00792000
         BNO   @RF00316                                            0316 00793000
*                           DO;                                    0317 00794000
*                             R6=R6+(LENGTH(NBFRDATA));/* ADD FOUR 0318 00795000
*                                      BYTES FOR DATA ADDRESS        */ 00796000
         AL    R6,@CF00039                                         0318 00797000
*                             R7=R6;/* HEADER AND ENTRY ARE EQUAL    */ 00798000
         LR    R7,R6                                               0319 00799000
*                           END;    /* END NON BUFFERED CALCULATION  */ 00800000
*                         ELSE      /* IF BUFFERING REQUESTED        */ 00801000
*                           DO;     /* ADDITIONAL SPACE REQUIRED AS     00802000
*                                      FOLLOWS                       */ 00803000
         B     @RC00316                                            0321 00804000
@RF00316 DS    0H                                                  0322 00805000
*                             IF HDRREQ=YES THEN/* IF AR149 HEADER 0322 00806000
*                                      REQUESTED                     */ 00807000
         TM    HDRREQ(R13),B'00001000'                             0322 00808000
         BNO   @RF00322                                            0322 00809000
*                               DO; /* ADD LENGTH OF HEADER          */ 00810000
*                                 R6=R6+(LENGTH(HDR));             0324 00811000
         AL    R6,@CF00111                                         0324 00812000
*                                 IF JOBNMREQ=YES THEN/* IF JOBNAME     00813000
*                                      REQUESTED                     */ 00814000
         TM    JOBNMREQ(R13),B'00000100'                           0325 00815000
         BNO   @RF00325                                            0325 00816000
*                                   R6=R6+(LENGTH(RCBBJOBN));/* ADD 8   00817000
*                                      BYTES REQUIRED FOR JOBNAME    */ 00818000
         AL    R6,@CF00032                                         0326 00819000
*                               END;/* END HEADER PROCESSING         */ 00820000
@RF00325 DS    0H                                                  0328 00821000
*                             R7=R6;/* HEADER LENGTH BEFORE ADDING 0328 00822000
*                                      DATA                          */ 00823000
@RF00322 LR    R7,R6                                               0328 00824000
*                             R6=R6+DATLEN;/* ADD LENGTH OF DATA TO     00825000
*                                      BUFFER                        */ 00826000
         LH    R14,DATLEN(,R13)                                 DSK1193 00827000
         N     R14,@CF02089                                     DSK1193 00828000
         ALR   R6,R14                                           DSK1193 00829000
*                           END;    /* END BUFFERED CALCULATION      */ 00830000
*/* FOLLOWING STATEMENT MOVED FROM FLAGGED COMMENT ABOVE     @ZA16445*/ 00831000
*                                                                  0331 00832000
*                         IF ERRIDREQ=YES THEN/* IF AN ERROR ID WAS     00833000
*                                      REQUESTED             @G17EP5W*/ 00834000
@RC00316 TM    ERRIDREQ(R13),B'00000001'                           0331 00835000
         BNO   @RF00331                                            0331 00836000
*                           R6=R6+  /* THEN ADD ITS LENGTH IN WITH 0332 00837000
*                                      THE                           */ 00838000
*                               LENGTH(RCBBERID);/* SPACE          0332 00839000
*                                      REQUIREMENTS          @G17EP5W*/ 00840000
         AL    R6,@CF00105                                         0332 00841000
*                         R15=RCFOUR;/* NOTIFY REQUESTOR BUFFERING 0333 00842000
*                                      NOT DONE                      */ 00843000
@RF00331 LA    R15,4                                               0333 00844000
*                         OPTNOBUF=YES;/* REMEMBER WE DIDN'T BUFFER  */ 00845000
         OI    OPTNOBUF(R13),B'01000000'                           0334 00846000
*                       END;        /* END PROC BUF TO NO BUF        */ 00847000
*                     ELSE          /* IF BUFFERING NOT OPTIONAL     */ 00848000
*                       DO;         /* CHECK FOR                     */ 00849000
         B     @RC00312                                            0336 00850000
@RF00312 DS    0H                                                  0337 00851000
*                         IF LOGRREQ=YES&RCBFLNG>=(R7+LENGTH(RCBBERID)+ 00852000
*                             4)    /* IF /* LOGREC REQUEST AND AT 0337 00853000
*                                      LEAST /* ROOM FOR HEADER AND     00854000
*                                      ERRORID IF /* PRESENT AND 4 0337 00855000
*                                      BYTES OF DATA /*      @G17EP5W   00856000
*                                                            @ZA16445   00857000
*                                                            @ZA10810*/ 00858000
*                             &R15<=RCFOUR THEN/* TRUNCATION STILL 0337 00859000
*                                      UNTRIED                       */ 00860000
         TM    LOGRREQ(R13),B'01000000'                            0337 00861000
         BNO   @RF00337                                            0337 00862000
         C     R15,@CF00039                                     DSK1193 00862010
         BH    @RF00337                                         DSK1193 00862020
         TM    ERRIDREQ(R13),B'00000001'                        DSK1193 00862030
         BNO   A00045E                                          DSK1193 00862040
         LA    R14,14                                           DSK1193 00863000
         ALR   R14,R7                                           DSK1193 00864000
         CR    R10,R14                                          DSK1193 00870010
         BNL   A000472                                          DSK1193 00870020
A00045E  DS    0H                                               DSK1193 00870030
         TM    ERRIDREQ(R13),B'00000001'                        DSK1193 00870040
         BNE   @RF00337                                         DSK1193 00870050
         LA    R14,4                                            DSK1193 00870060
         ALR   R14,R7                                           DSK1193 00870070
         CR    R10,R14                                          DSK1193 00870080
         BL    @RF00337                                         DSK1193 00870090
*                           DO;     /* CALCULATE TRUNCATED LENGTH    */ 00871000
*                             R6=R10;/* THE REMAINING FREE SPACE IS     00872000
*                                      USED                          */ 00873000
A000472  DS    0H                                               DSK1193 00873010
         LR    R6,R10                                              0339 00874000
*                             DATLEN=R6-R7;/* THE DATA RECORDED WILL    00875000
*                                      BE AVAIL SPACE MINUS REQUIRED    00876000
*                                      HEADER                        */ 00877000
         LR    R14,R6                                           DSK1193 00878000
         SLR   R14,R7                                           DSK1193 00879000
         STH   R14,DATLEN(,R13)                                 DSK1193 00880000
*                             IF ERRIDREQ=YES THEN/* IF THE ERRID IS    00881000
*                                      NEEDED AT THE END OF THE    0341 00882000
*                                      TRUNCATED RECORD, THE DATA  0341 00883000
*                                      MOVED MUST BE ERRID LENGTH  0341 00884000
*                                      LESS                  @ZA19981*/ 00885000
         TM    ERRIDREQ(R13),B'00000001'                           0341 00886000
         BNO   @RF00341                                            0341 00887000
*                               DATLEN=DATLEN-LENGTH(RCBBERID);/*  0342 00888000
*                                      LEAVE ENOUGH ROOM FOR THE   0342 00889000
*                                      ERRID AT RECORD END   @ZA19981*/ 00890000
         SL    R14,@CF00105                                     DSK1193 00891000
         STH   R14,DATLEN(,R13)                                 DSK1193 00892000
*                             ELSE                                 0343 00893000
*                               ;   /* NO ERRID - DATA CAN FILL UP 0343 00894000
*                                      SPACE IN BUFFER       @ZA19981*/ 00895000
@RF00341 DS    0H                                                  0344 00896000
*                             R15=RCEIGHT;/* NOTIFY REQUESTOR REC  0344 00897000
*                                      TRUNCATED                     */ 00898000
         LA    R15,8                                               0344 00899000
*                             TRUNCFLG=YES;/* REMEMBER WE TRUNCATED  */ 00900000
         OI    TRUNCFLG(R13),B'10000000'                           0345 00901000
*                           END;    /* END TRUNCATE PROCESSING       */ 00902000
*                         ELSE      /* IF TRUNCATION NOT AVAILABLE   */ 00903000
*                           DO;     /* RECORD LOST                   */ 00904000
         B     @RC00337                                            0347 00905000
@RF00337 DS    0H                                                  0348 00906000
*                             R15=RCTWELVE;/* NOTIFY REQUESTOR       */ 00907000
         LA    R15,12                                              0348 00908000
*                             OPTNOBUF=NO;/* NON BUFFERED REC WOULD     00909000
*                                      NOT FIT                       */ 00910000
*                             TRUNCFLG=NO;/* TRUNCATION COULD NOT BE    00911000
*                                      DONE                          */ 00912000
         NI    OPTNOBUF(R13),B'00111111'                           0350 00913000
*                             R9=NOLOOP;/* CANT DO IT GET OUT        */ 00914000
         SLR   R9,R9                                               0351 00915000
*                           END;    /* END CANT TRUNCATE             */ 00916000
*                       END;        /* END BUF NOT OPTIONAL          */ 00917000
@RC00337 DS    0H                                                  0354 00918000
*                   END;            /* END RECALCSP                  */ 00919000
@RC00312 DS    0H                                                  0355 00920000
*               END;                                               0355 00921000
@RC00299 DS    0H                                                  0355 00922000
@DE00290 C     R9,@CF00045                                         0355 00923000
         BE    @DL00290                                            0355 00924000
*               RESPECIFY           /* RELEASE REGISTERS FROM        */ 00925000
*                (R3,               /* SAVING FREE LEN & DUMMY DISP  */ 00926000
*                 R4,               /* UPDATING FREE POINTER,        */ 00927000
*                 R5,               /* FREE LEN & DUMMY DISPLACEMENT */ 00928000
*                 R10,              /* CALCULATING NEW FREE LENGTH   */ 00929000
*                 R9) UNRESTRICTED; /* SWITCH FOR LOOP CONTROL       */ 00930000
*               IF TRUNCFLG=YES THEN/* NOTIFY USER WE TRUNCATED THE  */ 00931000
         TM    TRUNCFLG(R13),B'10000000'                           0357 00932000
         BNO   @RF00357                                            0357 00933000
*                 R15=RCEIGHT;      /* RECORD                        */ 00934000
         LA    R15,8                                               0358 00935000
*               IF OPTNOBUF=YES THEN/* NOTIFY USER WE DIDNT BUFFER 0359 00936000
*                                      HIS                           */ 00937000
@RF00357 TM    OPTNOBUF(R13),B'01000000'                           0359 00938000
         BNO   @RF00359                                            0359 00939000
*                 R15=RCFOUR;       /* OPTIONAL REQUEST              */ 00940000
         LA    R15,4                                               0360 00941000
*/* NOTE: SAVFREE,HDRLEN AND SPACE WERE RESTRICTED AND NOT UNRESTRICT*/ 00942000
*/*       IN THIS SEGMENT AS THEIR CURRENT VALUES ARE INPUT TO BUILD */ 00943000
*/*       RECORD SEGMENT                                             */ 00944000
*/********************************************************************/ 00945000
*/*                                                                  */ 00946000
*/* THE PURPOSE OF THE BUILDREC SEGMENT IS TO DETERMINE IF SPACE WAS */ 00947000
*/* ALOCATED, IF SO THE RECORD IS BUILT IN THE ALLOCATED SPACE.      */ 00948000
*/* THE RECORD IS BUILT TO CALLERS REQUIREMENT AS DETERMINED BY INPUT*/ 00949000
*/* PARAMETER SPECIFICATIONS                                         */ 00950000
*/*                                                                  */ 00951000
*/********************************************************************/ 00952000
*                                                                  0361 00953000
*               IF R15^=RCTWELVE THEN/* IF SPACE WAS ALLOCATED FOR 0361 00954000
*                                      THIS                          */ 00955000
@RF00359 C     R15,@CF00135                                        0361 00956000
         BE    A00081E                                          DSK1193 00957010
*                 DO;               /* REQUEST                       */ 00958000
*                   RESPECIFY       /* BASE THE BUFFER ENTRY MAPPING    00959000
*                                      ON                            */ 00960000
*                     RCBBUF BASED(R2);/* THE POINTER TO ALLOTED   0363 00961000
*                                      SPACE                         */ 00962000
*                   DBLWORD=DBLWORD&&DBLWORD;/* CLEAR RECORD CONTROL    00963000
*                                      FLAG BITS             @ZA19199*/ 00964000
         XC    DBLWORD(8,R2),DBLWORD(R2)                           0364 00965000
*                   RFY                                            0365 00966000
*                     R5 RSTD;      /* PTR TO THE NEXT DBLWORD IN THE   00967000
*                                      RCB WHICH IS THE RCBBECB    0365 00968000
*                                                            @ZA19199*/ 00969000
*                   RFY                                            0366 00970000
*                     DBLWORD BASED(R5);/* GET THE NEXT DOUBLE WORD     00971000
*                                      TO INITIALIZE         @ZA19199*/ 00972000
*                   R5=ADDR(RCBBECB);/* POINT TO NEXT DBLWORD      0367 00973000
*                                                            @ZA19199*/ 00974000
         LA    R5,RCBBECB(,R2)                                     0367 00975000
*                   IF R5>=RCBBUFE THEN/* DOES THE HEADER WRAP     0368 00976000
*                                                            @ZA19199*/ 00977000
         C     R5,RCBBUFE(,R12)                                    0368 00978000
         BL    @RF00368                                            0368 00979000
*                     DO;           /* IT DOES WRAP          @ZA19199*/ 00980000
*                       R5=R5-RCBTLNG;/* UPDATE PTR IN BUFFER      0370 00981000
*                                                            @ZA19199*/ 00982000
         LH    R14,RCBTLNG(,R12)                                DSK1193 00983000
         N     R14,@CF02089                                     DSK1193 00984000
         SLR   R5,R14                                           DSK1193 00985000
*                       RCBBWRAP=YES;/* INDICATE A WRAPPED RECORD  0371 00986000
*                                                            @ZA19199*/ 00987000
         OI    RCBBWRAP(R2),B'10000000'                            0371 00988000
*                     END;          /* END HEADER DOES WRAP  @ZA19199*/ 00989000
*                   ELSE                                           0373 00990000
*                     ;             /* HEADER DOES NOT WRAP  @ZA19199*/ 00991000
@RF00368 DS    0H                                                  0374 00992000
*                   DBLWORD=DBLWORD&&DBLWORD;/* CLEAR RECORD CONTROL    00993000
*                                      ECB AND RESV AREAS    @ZA19199*/ 00994000
         XC    DBLWORD(8,R5),DBLWORD(R5)                           0374 00995000
*                   RFY                                            0375 00996000
*                     R5 UNRSTD;    /* FREE NEXT DBLWORD PTR @ZA19199*/ 00997000
*                   RFY                                            0376 00998000
*                     DBLWORD BASED(ADDR(RCBBUF));/* REBASE BACK   0376 00999000
*                                                            @ZA19199*/ 01000000
*                   RESPECIFY       /* RESTRICT REGISTER FOR POINTER    01001000
*                                      TO                            */ 01002000
*                    (R10,          /* DATA - IF IN PARMLIST OR NOT  */ 01003000
*                     R9,           /* PARMLIST                      */ 01004000
*                     R3,           /* ERRORID PARAMETER POINTER   0377 01005000
*                                                            @G17EP5W*/ 01006000
*                     R4) RESTRICTED;/* NEXT SPACE FOR BUILDING      */ 01007000
*                   IF LOGRREQ=YES THEN/* IF A LOGREC REQUEST      0378 01008000
*                                      INDICATE                      */ 01009000
         TM    LOGRREQ(R13),B'01000000'                            0378 01010000
         BNO   @RF00378                                            0378 01011000
*                     RCBBLREC=YES; /* IN BUFFER ENTRY               */ 01012000
         OI    RCBBLREC(R2),B'01000000'                            0379 01013000
*                   IF WTOREQ=YES THEN/* IF A WTO REQUEST INDICATE   */ 01014000
@RF00378 TM    WTOREQ(R13),B'00100000'                             0380 01015000
         BNO   @RF00380                                            0380 01016000
*                     RCBBWTO=YES;  /* IN BUFFER ENTRY               */ 01017000
         OI    RCBBWTO(R2),B'00100000'                             0381 01018000
*                   IF NBUFREQ=YES THEN/* IF IT IS A NON BUFFERED  0382 01019000
*                                      RECORD                        */ 01020000
@RF00380 TM    NBUFREQ(R13),B'00010000'                            0382 01021000
         BNO   @RF00382                                            0382 01022000
*                     RCBBLEN=DATLEN;/* RECORD LENGTH IS THE LENGTH     01023000
*                                      FROM THE REQUESTOR            */ 01024000
         LH    R14,DATLEN(,R13)                                 DSK1193 01025000
         N     R14,@CF02089                                     DSK1193 01026000
         STH   R14,RCBBLEN(,R2)                                 DSK1193 01027000
*                   ELSE            /* BUFFERED RECORD...            */ 01028000
*                     RCBBLEN=R6-CONTLEN;/* RECORD LENGTH IS SPACE 0384 01029000
*                                      ALLOTED MINUS RECORD CONTROL     01030000
*                                      INFO                          */ 01031000
         B     @RC00382                                            0384 01032000
@RF00382 LR    R14,R6                                           DSK1193 01033000
         SL    R14,@CF00062                                     DSK1193 01034000
         STH   R14,RCBBLEN(,R2)                                 DSK1193 01035000
*                   R4=R2+CONTLEN;  /* POINT TO SPACE FOR RECORD     */ 01036000
@RC00382 LA    R4,16                                               0385 01037000
         ALR   R4,R2                                               0385 01038000
*                   IF R4>=RCBBUFE THEN/* DOES HEADER WRAP THE BUFFER   01039000
*                                                            @ZA19199*/ 01040000
         C     R4,RCBBUFE(,R12)                                    0386 01041000
         BL    @RF00386                                            0386 01042000
*                     DO;           /* YES - IT DOES         @ZA19199*/ 01043000
*                       R4=R4-RCBTLNG;/* RESET THE POINTER   @ZA19199*/ 01044000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01045000
         N     R14,@CF02089                                     DSK1193 01046000
         SLR   R4,R14                                           DSK1193 01047000
*                       RCBBWRAP=YES;/* TURN ON THE WRAP INDICATOR 0389 01048000
*                                                            @ZA19199*/ 01049000
         OI    RCBBWRAP(R2),B'10000000'                            0389 01050000
*                     END;          /* END HEADER WRAPS THE BUFFER 0390 01051000
*                                                            @ZA19199*/ 01052000
*                   ELSE                                           0391 01053000
*                     ;             /* HEADER DOES NOT WRAP  @ZA19199*/ 01054000
@RF00386 DS    0H                                                  0392 01055000
*                   IF DATAIND=YES THEN/* IF CALLER SPECIFIED DATAADR*/ 01056000
         TM    DATAIND(R13),B'10000000'                            0392 01057000
         BNO   @RF00392                                            0392 01058000
*                     R10=-SAVEONE; /* SAVE POINTER TO DATA          */ 01059000
         L     R10,SAVEONE(,R13)                                   0393 01060000
         LCR   R10,R10                                             0393 01061000
*                   ELSE            /* IF NOT DATA ADDRESS PROCESS 0394 01062000
*                                      THE                           */ 01063000
*                     DO;           /* PARAMETER LIST                */ 01064000
*                                                                  0394 01065000
         B     @RC00392                                            0394 01066000
@RF00392 DS    0H                                                  0395 01067000
*                       /*********************************************/ 01068000
*                       /*                                           */ 01069000
*                       /* IN EACH BUILD SEGMENT THE POINTERS ARE    */ 01070000
*                       /* UPDATED AS FOLLOWS THE PARAMETER LIST     */ 01071000
*                       /* POINTER IS UPDATED TO POINT TO THE NEXT   */ 01072000
*                       /* ENTRY IN THE LIST A POINTER TO THE RECORD */ 01073000
*                       /* PORTION OF THE BUFFER ENTRY IS UPDATED TO */ 01074000
*                       /* POINT TO THE AVAILABLE SPACE              */ 01075000
*                       /*                                           */ 01076000
*                       /*********************************************/ 01077000
*                                                                  0395 01078000
*                       R9=DATAAD;  /* POINT TO THE PARMLIST         */ 01079000
         L     R9,DATAAD(,R13)                                     0395 01080000
*                       RFY                                        0396 01081000
*                         HDR BASED(R4);/* REBASE HDR IN CASE OF WRAP   01082000
*                                                            @ZA19199*/ 01083000
*                       IF HDRREQ=YES THEN/* IF BUILD OF AR149     0397 01084000
*                                      REQUESTED                     */ 01085000
         TM    HDRREQ(R13),B'00001000'                             0397 01086000
         BNO   @RF00397                                            0397 01087000
*/********************************************************************/ 01088000
*/*                                                                  */ 01089000
*/* THE PURPOSE OF THE BLDAR149 SEGMENT IS TO BUILD THE AR149 HEADER */ 01090000
*/* INTO THE BUFFER ALLOCATED FOR THIS REQUEST. INFORMATION FOR THE  */ 01091000
*/* HEADER IS IN PARMLIST                                            */ 01092000
*/*                                                                  */ 01093000
*/********************************************************************/ 01094000
*                                                                  0398 01095000
*                         DO;                                      0398 01096000
*                           HDRTYP=PARMTYPE;/* PUT RECORD TYPE FROM     01097000
*                                      PARMLIST                      */ 01098000
         MVC   HDRTYP(1,R4),PARMTYPE(R9)                           0399 01099000
*/* IF GETMAINED WORKAREA IS NOT AVAILABLE, THE RELEASE NUMBER IS NOT   01100000
*   PUT INTO RECORD                                          @ZM40310*/ 01101000
*                                                                  0400 01102000
*                           IF GMAD^=0 THEN                        0400 01103000
         L     R14,GMAD(,R13)                                   DSK1193 01104000
         LTR   R14,R14                                          DSK1193 01105000
         BZ    @RF00400                                            0400 01106000
*                             DO;   /* IF WORKAREA AVAILABLE @ZM40310*/ 01107000
*                               PKDWORD=PKDWORD&&PKDWORD;/* CLEAR OUT   01108000
*                                      WORKAREA              @Z40CPXH*/ 01109000
         XC    PKDWORD(8,R14),PKDWORD(R14)                      DSK1193 01110000
*                               PACK(PKDWORD(7:8),CVTNUMB);/* PICK UP   01111000
*                                      REL NO FROM CVT       @Z40CPXH*/ 01112000
         L     R11,CVTPTR                                       DSK1193 01113000
         AL    R11,@CF02093                                     DSK1193 01114000
         PACK  PKDWORD+6(2,R14),CVTRELNO-CVTRELNO(2,R11)        DSK1193 01115000
*                               RFY                                0404 01116000
*                                (R11,                             0404 01117000
*                                 R14) RSTD;/*               @Z40CPXH*/ 01118000
*                               R14=ADDR(PKDWORD);/* SET UP FOR CVB     01119000
*                                                            @Z40CPXH*/ 01120000
         L     R5,GMAD(,R13)                                    DSK1193 01121000
         LA    R14,PKDWORD(,R5)                                 DSK1193 01122000
*                               GEN;                               0406 01123000
*                                 /* CONVERT RELEASE NUMBER  @Z40CPXH*/ 01124000
   CVB   R11,0(R14)                                           Z40CPXH   01125000
*                               HDROPRN=R11;/* SAVE RELEASE IN HDR 0407 01126000
*                                                            @Z40CPXH*/ 01127000
         STC   R11,HDROPRN(,R4)                                    0407 01128000
*                               RFY                                0408 01129000
*                                (R11,                             0408 01130000
*                                 R14) UNRSTD;/*             @Z40CPXH*/ 01131000
*                               HDROPSYS=SYSVS2;/* SYSTEM IS VS2   0409 01132000
*                                                            @Z40CPXH*/ 01133000
         NI    HDROPSYS(R4),B'10011111'                            0409 01134000
         OI    HDROPSYS(R4),B'10000000'                            0409 01135000
*                             END;  /*                       @ZM40310*/ 01136000
*                           HDRIS='40'X;/* INDICATE STORE TOD CLOCK     01137000
*                                      USED                          */ 01138000
@RF00400 MVI   HDRIS(R4),X'40'                                     0411 01139000
*                           HDRDS=PARMSWTS;/* DEPENDENT SWITCHES FROM   01140000
*                                      PARMLIST                      */ 01141000
         MVC   HDRDS(3,R4),PARMSWTS(R9)                            0412 01142000
*                           HDRCNT=ZERO;/* NO MULTIPLE PHYSICAL    0413 01143000
*                                      RECORDS                       */ 01144000
         L     R14,ZERO                                         DSK1193 01145000
         STC   R14,HDRCNT(,R4)                                  DSK1193 01146000
*                           RESPECIFY/* RESTRICT REGISTER FOR        */ 01147000
*                            (R5) RESTRICTED;/* ARE TO STORE (CLOCK &   01148000
*                                      CPUID)                        */ 01149000
*                           R5=ADDR(HDRTM);/* POINT TO AREA FOR TIME    01150000
*                                      IN AR149                      */ 01151000
         LA    R5,HDRTM(,R4)                                       0415 01152000
*                           IF R5>=RCBBUFE THEN/* IS HDR TIME WRAPPED   01153000
*                                      IN THE BUFFER         @ZA19199*/ 01154000
         C     R5,RCBBUFE(,R12)                                    0416 01155000
         BL    @RF00416                                            0416 01156000
*                             DO;   /* YES IT WRAPS - RESET PTR    0417 01157000
*                                                            @ZA19199*/ 01158000
*                               R5=R5-RCBTLNG;/* PROPER ADDR AFTER 0418 01159000
*                                      WRAP                  @ZA19199*/ 01160000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01161000
         N     R14,@CF02089                                     DSK1193 01162000
         SLR   R5,R14                                           DSK1193 01163000
*                               RCBBWRAP=YES;/* INDICATE HEADER WRAPS   01164000
*                                                            @ZA19199*/ 01165000
         OI    RCBBWRAP(R2),B'10000000'                            0419 01166000
*                             END;  /* END HEADER WRAPS BUFFER     0420 01167000
*                                                            @ZA19199*/ 01168000
*                           ELSE                                   0421 01169000
*                             ;     /* HEADER DOES NOT WRAP  @ZA19199*/ 01170000
@RF00416 DS    0H                                                  0422 01171000
*                           GEN(STCK ZIP(R5));/* STORE TOD CLOCK   0422 01172000
*                                      VALUE IN AR149                */ 01173000
         STCK ZIP(R5)                                                   01174000
*                           LCLTM=LCLTM+CVTTZ;/* ADJ GMT TO LOCAL  0423 01175000
*                                                            @YM06396*/ 01176000
         ICM   R14,15,LCLTM(R5)                                 DSK1193 01177000
         L     R11,CVTPTR                                       DSK1193 01178000
         AL    R14,CVTTZ-CVTMAP(,R11)                           DSK1193 01179000
         STCM  R14,15,LCLTM(R5)                                 DSK1193 01180000
*                           R5=ADDR(HDRCPID);/* POINT TO AREA FOR  0424 01181000
*                                      CPUID IN AR149                */ 01182000
         LA    R5,HDRCPID(,R4)                                     0424 01183000
*                           IF R5>=RCBBUFE THEN/* IS HDR CPUID     0425 01184000
*                                      WRAPPED IN THE BUFFER @ZA19199*/ 01185000
         C     R5,RCBBUFE(,R12)                                    0425 01186000
         BL    @RF00425                                            0425 01187000
*                             DO;   /* YES IT WRAPS - RESET PTR    0426 01188000
*                                                            @ZA19199*/ 01189000
*                               R5=R5-RCBTLNG;/* PROPER ADDR AFTER 0427 01190000
*                                      WRAP                  @ZA19199*/ 01191000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01192000
         N     R14,@CF02089                                     DSK1193 01193000
         SLR   R5,R14                                           DSK1193 01194000
*                               RCBBWRAP=YES;/* INDICATE HEADER WRAPS   01195000
*                                                            @ZA19199*/ 01196000
         OI    RCBBWRAP(R2),B'10000000'                            0428 01197000
*                             END;  /* END HEADER WRAPS BUFFER     0429 01198000
*                                                            @ZA19199*/ 01199000
*                           ELSE                                   0430 01200000
*                             ;     /* HEADER DOES NOT WRAP  @ZA19199*/ 01201000
@RF00425 DS    0H                                                  0431 01202000
*                           GEN(STIDP ZIP(R5));/* STORE CPUID IN   0431 01203000
*                                      AR149                         */ 01204000
         STIDP ZIP(R5)                                                  01205000
*                           RESPECIFY/* RELEASE REGISTER FROM        */ 01206000
*                            (R5) UNRESTRICTED;/* AREA TO STORE    0432 01207000
*                                      (CLOCK & CPUID)               */ 01208000
*                           R9=R9+  /* POINT TO NEXT ENTRY IN      0433 01209000
*                                      PARMLIST                      */ 01210000
*                               (LENGTH(PARMHDR));                 0433 01211000
         AL    R9,@CF00039                                         0433 01212000
*                           R4=R4+(LENGTH(HDR));/* POINT TO FREE AREA   01213000
*                                      IN ALLOCATED BUFFER SPACE     */ 01214000
         AL    R4,@CF00111                                         0434 01215000
*                           IF R4>=RCBBUFE THEN/* CHECK IF THE NEXT     01216000
*                                      ADDR CAUSES THE BUFFER TO WRAP   01217000
*                                                            @ZA19199*/ 01218000
         C     R4,RCBBUFE(,R12)                                    0435 01219000
         BL    @RF00435                                            0435 01220000
*                             DO;   /* YES - RESET POINTER   @ZA19199*/ 01221000
*                               R4=R4-RCBTLNG;/* READJUST THE ADDR 0437 01222000
*                                                            @ZA19199*/ 01223000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01224000
         N     R14,@CF02089                                     DSK1193 01225000
         SLR   R4,R14                                           DSK1193 01226000
*                               RCBBWRAP=YES;/* INDICATE HEADER WRAPS   01227000
*                                                            @ZA19199*/ 01228000
         OI    RCBBWRAP(R2),B'10000000'                            0438 01229000
*                             END;  /* END NEXT ADDRESS CAUSES BUFFER   01230000
*                                      TO WRAP               @ZA19199*/ 01231000
*                           ELSE                                   0440 01232000
*                             ;     /* NEXT ADDRESS DOES NOT CAUSE A    01233000
*                                      BUFFER WRAP           @ZA19199*/ 01234000
@RF00435 DS    0H                                                  0441 01235000
*                         END;                                     0441 01236000
*                       RFY                                        0442 01237000
*                         HDR BASED(ADDR(AR149HDR));/* REBASE BACK 0442 01238000
*                                                            @ZA19199*/ 01239000
@RF00397 DS    0H                                                  0443 01240000
*                       IF JOBNMREQ=YES THEN/* IF JOBNAME REQUESTED  */ 01241000
         TM    JOBNMREQ(R13),B'00000100'                           0443 01242000
         BNO   @RF00443                                            0443 01243000
*                         DO;                                      0444 01244000
*                           RCBBJOBN=PARMJOBN;/* MOVE JOBNAME TO   0445 01245000
*                                      SPACE FOLLOWING HEADER        */ 01246000
         MVC   RCBBJOBN(8,R4),PARMJOBN(R9)                         0445 01247000
*                           R4=R4+  /* POINT TO NEXT FREE SPACE      */ 01248000
*                               (LENGTH(RCBBJOBN));                0446 01249000
         AL    R4,@CF00032                                         0446 01250000
*                           IF R4>=RCBBUFE THEN/* CHECK IF THE NEXT     01251000
*                                      ADDR CAUSES THE BUFFER TO WRAP   01252000
*                                                            @ZA19199*/ 01253000
         C     R4,RCBBUFE(,R12)                                    0447 01254000
         BL    @RF00447                                            0447 01255000
*                             DO;   /* YES - RESET POINTER   @ZA19199*/ 01256000
*                               R4=R4-RCBTLNG;/* READJUST THE ADDR 0449 01257000
*                                                            @ZA19199*/ 01258000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01259000
         N     R14,@CF02089                                     DSK1193 01260000
         SLR   R4,R14                                           DSK1193 01261000
*                               RCBBWRAP=YES;/* INDICATE HEADER WRAPS   01262000
*                                                            @ZA19199*/ 01263000
         OI    RCBBWRAP(R2),B'10000000'                            0450 01264000
*                             END;  /* END NEXT ADDRESS CAUSES BUFFER   01265000
*                                      TO WRAP               @ZA19199*/ 01266000
*                           ELSE                                   0452 01267000
*                             ;     /* NEXT ADDRESS DOES NOT CAUSE A    01268000
*                                      BUFFER WRAP           @ZA19199*/ 01269000
@RF00447 DS    0H                                                  0453 01270000
*                           R9=R9+  /* POINT TO NEXT PARM LIST ENTRY */ 01271000
*                               (LENGTH(PARMJOBN));                0453 01272000
         AL    R9,@CF00032                                         0453 01273000
*                         END;                                     0454 01274000
*                       IF ERRIDREQ=YES THEN/* IF ERROR ID IN PARM 0455 01275000
*                                      LIST                  @G17EP5W*/ 01276000
@RF00443 TM    ERRIDREQ(R13),B'00000001'                           0455 01277000
         BNO   @RF00455                                            0455 01278000
*                         DO;       /* THEN PROCESS IT       @G17EP5W*/ 01279000
*                           R3=R9;  /* SAVE ERRORID ADDRESS  @G17EP5W*/ 01280000
         LR    R3,R9                                               0457 01281000
*                           R9=R9+  /* GET ADDR OF NEXT PARAM      0458 01282000
*                                                            @G17EP5W*/ 01283000
*                               LENGTH(PARMERID);                  0458 01284000
         AL    R9,@CF00135                                         0458 01285000
*                         END;                                     0459 01286000
*                       IF POSTREQ=YES THEN/* IF POSTING REQUESTED   */ 01287000
@RF00455 TM    POSTREQ(R13),B'00000001'                            0460 01288000
         BNO   @RF00460                                            0460 01289000
*                         DO;       /* INDICATE                      */ 01290000
*                           RCBBPOST=YES;/* IN BUFFER ENTRY          */ 01291000
         OI    RCBBPOST(R2),B'00000100'                            0462 01292000
*                           RFY                                    0463 01293000
*                             R5 RSTD;/* POINTER TO THE ECB TO BE  0463 01294000
*                                      POSTED                @ZA19199*/ 01295000
*                           R5=ADDR(RCBBECB);/* GET ADDR OF THE ECB     01296000
*                                      FIELD                 @ZA19199*/ 01297000
         LA    R5,RCBBECB(,R2)                                     0464 01298000
*                           IF R5>=RCBBUFE THEN/* DOES THIS ADDR WRAP   01299000
*                                                            @ZA19199*/ 01300000
         C     R5,RCBBUFE(,R12)                                    0465 01301000
         BL    @RF00465                                            0465 01302000
*                             DO;   /* YES - RESET ADDR      @ZA19199*/ 01303000
*                               R5=R5-RCBTLNG;/* RE-ADJUST THE     0467 01304000
*                                      POINTER TO THE ECB    @ZA19199*/ 01305000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01306000
         N     R14,@CF02089                                     DSK1193 01307000
         SLR   R5,R14                                           DSK1193 01308000
*                               RCBBWRAP=YES;/* INDICATE RECORD WRAPS   01309000
*                                                            @ZA19199*/ 01310000
         OI    RCBBWRAP(R2),B'10000000'                            0468 01311000
*                             END;  /* END ADDR WRAPS        @ZA19199*/ 01312000
*                           ELSE                                   0470 01313000
*                             ;     /* ADDR DOES NOT WRAP    @ZA19199*/ 01314000
@RF00465 DS    0H                                                  0471 01315000
*                           BECB=PARMECB;/* MOVE ECB ADDR INTO BUFFER   01316000
*                                                            @ZA19199*/ 01317000
         MVC   BECB(4,R5),PARMECB(R9)                              0471 01318000
*                           RFY                                    0472 01319000
*                             R5 UNRSTD;/* FREE ECB POINTER  @ZA19199*/ 01320000
*                           R9=R9+  /* POINT TO NEXT PARMLIST ENT    */ 01321000
*                               (LENGTH(PARMECB));                 0473 01322000
         LA    R14,4                                            DSK1193 01323000
         ALR   R9,R14                                           DSK1193 01324000
*                           RCBBASID=PARMASID;/* MOVE ASID TO BUFFER */ 01325000
         MVC   RCBBASID(2,R2),PARMASID+2(R9)                       0474 01326000
*                           R9=R9+  /* POINT TO NEXT PARMLIST ENTRY  */ 01327000
*                               (LENGTH(PARMASID));                0475 01328000
         ALR   R9,R14                                           DSK1193 01329000
*                         END;                                     0476 01330000
*                       IF TIMEREQ=YES THEN/* IF TIME WAS REQUESTED  */ 01331000
@RF00460 TM    TIMEREQ(R13),B'00000010'                            0477 01332000
         BNO   @RF00477                                            0477 01333000
*                         DO;                                      0478 01334000
*                           IF HDRREQ=YES THEN                     0479 01335000
         TM    HDRREQ(R13),B'00001000'                             0479 01336000
         BNO   @RF00479                                            0479 01337000
*                             DO;   /* SET UP PTR TO HANDLE WRAPPED     01338000
*                                      HEADERS               @ZA19199*/ 01339000
*                               RFY                                0481 01340000
*                                 R5 RSTD;/* POINTER TO THE TIME   0481 01341000
*                                      FIELD IN HDR          @ZA19199*/ 01342000
*                               R5=ADDR(HDRTM);/* GET ADDR OF THE  0482 01343000
*                                      TIME FIELD            @ZA19199*/ 01344000
         LA    R5,HDRTM+16(,R2)                                    0482 01345000
*                               IF R5>=RCBBUFE THEN/* DOES THIS ADDR    01346000
*                                      WRAP                  @ZA19199*/ 01347000
         C     R5,RCBBUFE(,R12)                                    0483 01348000
         BL    @RF00483                                            0483 01349000
*                                 R5=R5-RCBTLNG;/* RE-ADJUST THE   0484 01350000
*                                      POINTER TO THE TIME FIELD   0484 01351000
*                                                            @ZA19199*/ 01352000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01353000
         N     R14,@CF02089                                     DSK1193 01354000
         SLR   R5,R14                                           DSK1193 01355000
*                               ELSE                               0485 01356000
*                                 ; /* ADDR DOES NOT WRAP    @ZA19199*/ 01357000
@RF00483 DS    0H                                                  0486 01358000
*                               TIMESLOT=TIMEHDR;/* RETURN TIME STAMP   01359000
*                                      FROM HDR              @ZA19199*/ 01360000
         L     R14,PARMTIME(,R9)                                DSK1193 01361000
         MVC   TIMESLOT(8,R14),TIMEHDR(R5)                      DSK1193 01362000
*                               RFY                                0487 01363000
*                                 R5 UNRSTD;/* FREE TIME FIELD PTR 0487 01364000
*                                                            @ZA19199*/ 01365000
*                             END;  /* END HDR WAS REQUIRED  @ZA19199*/ 01366000
*                           ELSE                                   0489 01367000
*                             TIMESLOT=EVAL(R9+LENGTH(PARMTIME))-> 0489 01368000
*                                 PARMDATA->HDRTM;/* OR FROM       0489 01369000
*                                      REQUESTORS BUFFER             */ 01370000
         B     @RC00479                                            0489 01371000
@RF00479 L     R14,PARMTIME(,R9)                                DSK1193 01372000
         LA    R11,4                                            DSK1193 01373000
         ALR   R11,R9                                           DSK1193 01374000
         L     R11,PARMDATA(,R11)                               DSK1193 01375000
         MVC   TIMESLOT(8,R14),HDRTM(R11)                       DSK1193 01376000
*                           R9=R9+  /* POINT TO NEXT ENTRY IN        */ 01377000
*                               (LENGTH(PARMTIME));/* PARMLIST       */ 01378000
@RC00479 AL    R9,@CF00039                                         0490 01379000
*                         END;                                     0491 01380000
*                       R10=PARMDATA;/* GET POINTER TO DATA FROM   0492 01381000
*                                      PARMLIST                      */ 01382000
@RF00477 L     R10,PARMDATA(,R9)                                   0492 01383000
*                     END;          /* END PARMLIST PROCESSING       */ 01384000
*                   IF R15=RCEIGHT THEN/* IF A TRUNCATED RECORD      */ 01385000
@RC00392 C     R15,@CF00032                                        0494 01386000
         BNE   @RF00494                                            0494 01387000
*                     DO;           /* SET UP PTR TO HANDLE WRAPPED     01388000
*                                      HEADERS               @ZA19199*/ 01389000
*                       RFY                                        0496 01390000
*                         R5 RSTD;  /* PTR TO THE HDR SECTION OF   0496 01391000
*                                      RECORD                @ZA19199*/ 01392000
*                       R5=ADDR(HDR);/* SET THE POINTER      @ZA19199*/ 01393000
         LA    R5,16                                               0497 01394000
         ALR   R5,R2                                               0497 01395000
*                       RFY                                        0498 01396000
*                         HDR BASED(R5);/* BASE CONTROL BLOCK ON   0498 01397000
*                                      POINTER               @ZA19199*/ 01398000
*                       IF R5>=RCBBUFE THEN/* DOES THE HEADER WRAP 0499 01399000
*                                                            @ZA19199*/ 01400000
         C     R5,RCBBUFE(,R12)                                    0499 01401000
         BL    @RF00499                                            0499 01402000
*                         R5=R5-RCBTLNG;/* YES - RESET ADDRESS     0500 01403000
*                                                            @ZA19199*/ 01404000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01405000
         N     R14,@CF02089                                     DSK1193 01406000
         SLR   R5,R14                                           DSK1193 01407000
*                       ELSE                                       0501 01408000
*                         ;         /* THE HEADER DID NOT WRAP     0501 01409000
*                                                            @ZA19199*/ 01410000
@RF00499 DS    0H                                                  0502 01411000
*                       HDRTRUNC=YES;/* INDICATE TRUNCATED RECORD IN    01412000
*                                      AR149                 @ZA19199*/ 01413000
         OI    HDRTRUNC(R5),B'00100000'                            0502 01414000
         OI    HDRDS(R5),X'40'                                  DSK1193 01414010
         TM    HDRREQ(R13),B'00001000'                          DSK1193 01414020
         BNE   @RF00494                                         DSK1193 01414030
         TM    DATAIND(R13),B'10000000'                         DSK1193 01414040
         BNO   @RF00494                                         DSK1193 01414050
         OI    HDRIS(R10),X'20'                                 DSK1193 01414060
         OI    HDRDS(R10),X'40'                                 DSK1193 01414070
*                       RFY                                        0503 01415000
*                         HDR BASED(ADDR(AR149HDR));/* REBASE BACK 0503 01416000
*                                                            @ZA19199*/ 01417000
*                       RFY                                        0504 01418000
*                         R5 UNRSTD;/* FREE HDR POINTER      @ZA19199*/ 01419000
*                     END;          /* END A TRUNCATED RECORD      0505 01420000
*                                                            @ZA19199*/ 01421000
*                   IF NBUFREQ=YES THEN/* IF IT IS A UNBUFFERED    0506 01422000
*                                      REQUEST                       */ 01423000
@RF00494 TM    NBUFREQ(R13),B'00010000'                            0506 01424000
         BNO   @RF00506                                            0506 01425000
*                     DO;           /* OR FORCED BY FIND SPACE       */ 01426000
*                       RCBBNBFR=YES;/* INDICATE IT IN BUFFER ENTRY  */ 01427000
         OI    RCBBNBFR(R2),B'00001000'                            0508 01428000
*                       RFY                                        0509 01429000
*                         NBFREC BASED(R4);/* POINTER IN BUFFER WHERE   01430000
*                                      DATA SHOULD BE PLACED @ZA19199*/ 01431000
*                       NBFRDATA=R10;/* PUT THE ADDRESS IN THE BUFFER*/ 01432000
         ST    R10,NBFRDATA(,R4)                                   0510 01433000
*                       IF ERRIDREQ=YES THEN/* IF ERROR ID REQUESTED    01434000
*                                                            @G17EP5W*/ 01435000
         TM    ERRIDREQ(R13),B'00000001'                           0511 01436000
         BNO   @RC00506                                         DSK1193 01437000
*                         DO;                                      0512 01438000
*                           RCBBERFG=YES;/* SET ERROR ID FLAG IN RCB    01439000
*                                                            @G17EP5W*/ 01440000
         OI    RCBBERFG(R2),B'00000010'                            0513 01441000
*                           RFY                                    0514 01442000
*                            (R5,                                  0514 01443000
*                             R11) RSTD;                           0514 01444000
*                           R4=ADDR(NBFRERID);/* ADR OF ERRORID IN 0515 01445000
*                                      RCB                   @ZA16445*/ 01446000
         LA    R14,NBFRERID(,R4)                                DSK1193 01447000
         LR    R4,R14                                           DSK1193 01448000
*                           RFY                                    0516 01449000
*                             NBFREC BASED(ADDR(RCBBDATA));/* REBASE    01450000
*                                      BACK                  @ZA19199*/ 01451000
*                           R10=ADDR(PARMERID);/* ADR OF ERRORID IN     01452000
*                                      PLIST                 @ZA16445*/ 01453000
         LR    R10,R3                                              0517 01454000
*                           R11=LENGTH(RCBBERID);/* LENGTH OF ERRORID   01455000
*                                                            @ZA16445*/ 01456000
         LA    R11,10                                              0518 01457000
*                           IF RCBBUFE-R4<R11 THEN/* WILL RECORD   0519 01458000
*                                      WRAP?                 @ZA16445*/ 01459000
         L     R14,RCBBUFE(,R12)                                DSK1193 01460000
         SLR   R14,R4                                           DSK1193 01461000
         CR    R14,R11                                          DSK1193 01462000
         BNL   @RF00519                                            0519 01463000
*                             DO;   /*                       @ZA16445*/ 01464000
*                               RCBBWRAP=YES;/* INDICATE WRAPPED   0521 01465000
*                                      RECORD                @ZA16445*/ 01466000
         OI    RCBBWRAP(R2),B'10000000'                            0521 01467000
*                               R5=RCBBUFE-R4;/* FILL TO END OF    0522 01468000
*                                      BUFFER                @ZA16445*/ 01469000
         LR    R5,R14                                           DSK1193 01470000
*                             END;  /*                       @ZA16445*/ 01471000
*                           ELSE    /* ERRORID WILL NOT WRAP @ZA16445*/ 01472000
*                             R5=R11;/* MOVE ENTIRE ERRORID  @ZA16445*/ 01473000
         B     @RC00519                                            0524 01474000
@RF00519 LR    R5,R11                                              0524 01475000
*                           GEN(MVCL R4,R10);/* MOVE THE DATA      0525 01476000
*                                                            @ZA16445*/ 01477000
@RC00519 DS    0H                                                  0525 01478000
         MVCL R4,R10                                                    01479000
*                           IF R11^=ZERO THEN/* MORE DATA TO MOVE? 0526 01480000
*                                                            @ZA16445*/ 01481000
         C     R11,ZERO                                            0526 01482000
         BE    @RF00526                                            0526 01483000
*                             DO;   /*                       @ZA16445*/ 01484000
*                               R4=RCBBUFB;/* MOVE REST OF ERRORID TO   01485000
*                                      BEGINNING OF BUFFER   @ZA16445*/ 01486000
         L     R4,RCBBUFB(,R12)                                    0528 01487000
*                               R5=R11;/* REST OF ERRORID    @ZA16445*/ 01488000
         LR    R5,R11                                              0529 01489000
*                               GEN(MVCL R4,R10);/* MOVE THE DATA  0530 01490000
*                                                            @ZA16445*/ 01491000
         MVCL R4,R10                                                    01492000
*                             END;  /*                       @ZA16445*/ 01493000
*                           RFY                                    0532 01494000
*                            (R5,                                  0532 01495000
*                             R11) UNRSTD;                         0532 01496000
@RF00526 DS    0H                                                  0533 01497000
*                         END;      /* END ERROR ID PROCESSING     0533 01498000
*                                                            @G17EP5W*/ 01499000
*                     END;                                         0534 01500000
*                   ELSE            /* IF DATA TO BE BUFFERED        */ 01501000
*                     DO;                                          0535 01502000
*                                                                  0535 01503000
         B     @RC00506                                            0535 01504000
@RF00506 DS    0H                                                  0536 01505000
*/********************************************************************/ 01506000
*/*                                                                  */ 01507000
*/* THE PURPOSE OF THE MOVEDATA SEGMENT IS TO MOVE THE DATA FOR      */ 01508000
*/* RECORDING FROM THE CALLERS AREA TO THE RCB. ALLOWANCE IS MADE    */ 01509000
*/* FOR WRAPPING THE RCB BUFFER AREA. IF THIS OCCURS THE BUFFER ENTRY*/ 01510000
*/* HEADER IS MARKED TO INDICATE IT (RCBBWRAP = YES)                 */ 01511000
*/*                                                                  */ 01512000
*/********************************************************************/ 01513000
*                                                                  0536 01514000
*                       RESPECIFY   /* RESTRICT REGISTERS FOR        */ 01515000
*                        (R11,      /* LENGTH OF DATA TO BE MOVED    */ 01516000
*                         R5) RESTRICTED;/* LENGTH OF AREA TO MOVE IT   01517000
*                                      TO                            */ 01518000
*                       R11=DATLEN; /* PICK OF LENGTH OF DATA TO MOVE*/ 01519000
         LH    R11,DATLEN(,R13)                                    0537 01520000
         N     R11,@CF02089                                        0537 01521000
*                       DO WHILE(R11^=ZERO);/* MOVE DATA UNTIL IT IS    01522000
*                                      ALL MOVED                     */ 01523000
         B     @DE00538                                            0538 01524000
@DL00538 DS    0H                                                  0539 01525000
*                         IF RCBBUFE-R4<R11 THEN/* WILL THIS RECORD     01526000
*                                      WRAP                          */ 01527000
         L     R14,RCBBUFE(,R12)                                DSK1193 01528000
         SLR   R14,R4                                           DSK1193 01529000
         CR    R14,R11                                          DSK1193 01530000
         BNL   @RF00539                                            0539 01531000
*                           DO;     /* THE RCB                       */ 01532000
*                             RCBBWRAP=YES;/* INDICATE WRAPPED RECORD*/ 01533000
         OI    RCBBWRAP(R2),B'10000000'                            0541 01534000
*                             R5=RCBBUFE-R4;/* MOVE DATA TO FILL   0542 01535000
*                                      REMAINING SPACE TO END OF   0542 01536000
*                                      BUFFER                        */ 01537000
         LR    R5,R14                                           DSK1193 01538000
*                           END;    /* END OF WRAPPED PROCESS        */ 01539000
*                         ELSE      /* RECORD DOESNT WRAP            */ 01540000
*                           R5=R11; /* MOVE ALL THE DATA             */ 01541000
         B     @RC00539                                            0544 01542000
@RF00539 LR    R5,R11                                              0544 01543000
*                         GEN(MVCL R4,R10);/* MOVE THE DATA          */ 01544000
@RC00539 DS    0H                                                  0545 01545000
         MVCL R4,R10                                                    01546000
*                         IF R11^=ZERO THEN/* IF THERE IS MORE DATA     01547000
*                                      TO MOVE               @G17EP5W*/ 01548000
         C     R11,ZERO                                            0546 01549000
         BE    @RF00546                                            0546 01550000
*                           DO;                                    0547 01551000
*                             R4=RCBBUFB;/* WRAP TO BEGINNING OF   0548 01552000
*                                      BUFFER                        */ 01553000
         L     R4,RCBBUFB(,R12)                                    0548 01554000
*                             R5=R11;/* PICK UP LENGTH REMAINING TO     01555000
*                                      MOVE                          */ 01556000
         LR    R5,R11                                              0549 01557000
*                           END;                                   0550 01558000
*                       END;                                       0551 01559000
@RF00546 DS    0H                                                  0551 01560000
@DE00538 C     R11,ZERO                                            0551 01561000
         BNE   @DL00538                                            0551 01562000
*                       RESPECIFY                                  0552 01563000
*                        (R5,                                      0552 01564000
*                         R11) UNRESTRICTED;                       0552 01565000
*                       IF ERRIDREQ=YES THEN/* IF ERRORID TO BE    0553 01566000
*                                      APPENDED              @G17EP5W*/ 01567000
         TM    ERRIDREQ(R13),B'00000001'                           0553 01568000
         BNO   @RF00553                                            0553 01569000
*                         DO;       /* THEN ADD ERRORID      @G17EP5W*/ 01570000
*                           RCBBERFG=YES;/* SET ERROR ID FLAG IN RCB    01571000
*                                                            @G17EP5W*/ 01572000
         OI    RCBBERFG(R2),B'00000010'                            0555 01573000
*                           RFY                                    0556 01574000
*                            (R5,                                  0556 01575000
*                             R11) RSTD;                           0556 01576000
*                           R10=ADDR(PARMERID);/* ADR OF ERRORID IN     01577000
*                                      PLIST                 @ZA16445*/ 01578000
         LR    R10,R3                                              0557 01579000
*                           R11=LENGTH(RCBBERID);/* LENGTH OF ERRORID   01580000
*                                                            @ZA16445*/ 01581000
         LA    R11,10                                              0558 01582000
*                           IF RCBBUFE-R4<R11 THEN/* WILL RECORD   0559 01583000
*                                      WRAP?                 @ZA16445*/ 01584000
         L     R14,RCBBUFE(,R12)                                DSK1193 01585000
         SLR   R14,R4                                           DSK1193 01586000
         CR    R14,R11                                          DSK1193 01587000
         BNL   @RF00559                                            0559 01588000
*                             DO;   /*                       @ZA16445*/ 01589000
*                               RCBBWRAP=YES;/* INDICATE WRAPPED   0561 01590000
*                                      RECORD                @ZA16445*/ 01591000
         OI    RCBBWRAP(R2),B'10000000'                            0561 01592000
*                               R5=RCBBUFE-R4;/* FILL TO END OF    0562 01593000
*                                      BUFFER                @ZA16445*/ 01594000
         LR    R5,R14                                           DSK1193 01595000
*                             END;  /*                       @ZA16445*/ 01596000
*                           ELSE    /* ERRORID WILL NOT WRAP @ZA16445*/ 01597000
*                             R5=R11;/* MOVE ENTIRE ERRORID  @ZA16445*/ 01598000
         B     @RC00559                                            0564 01599000
@RF00559 LR    R5,R11                                              0564 01600000
*                           GEN(MVCL R4,R10);/* MOVE THE DATA      0565 01601000
*                                                            @ZA16445*/ 01602000
@RC00559 DS    0H                                                  0565 01603000
         MVCL R4,R10                                                    01604000
*                           IF R11^=ZERO THEN/* MORE DATA TO MOVE? 0566 01605000
*                                                            @ZA16445*/ 01606000
         C     R11,ZERO                                            0566 01607000
         BE    @RF00566                                            0566 01608000
*                             DO;   /*                       @ZA16445*/ 01609000
*                               R4=RCBBUFB;/* MOVE REST OF ERRORID TO   01610000
*                                      BEGINNING OF BUFFER   @ZA16445*/ 01611000
         L     R4,RCBBUFB(,R12)                                    0568 01612000
*                               R5=R11;/* REST OF ERRORID    @ZA16445*/ 01613000
         LR    R5,R11                                              0569 01614000
*                               GEN(MVCL R4,R10);/* MOVE THE DATA  0570 01615000
*                                                            @ZA16445*/ 01616000
         MVCL R4,R10                                                    01617000
*                             END;  /*                       @ZA16445*/ 01618000
*                           RFY                                    0572 01619000
*                            (R5,                                  0572 01620000
*                             R11) UNRSTD;                         0572 01621000
@RF00566 DS    0H                                                  0573 01622000
*                           RFY                                    0573 01623000
*                             R5 RSTD;/* POINTER FOR THE HDR TO    0573 01624000
*                                      HANDLE WRAPPED HEADERS      0573 01625000
*                                                            @ZA19199*/ 01626000
*                           R5=ADDR(HDR);/* SET UP THE POINTER     0574 01627000
*                                                            @ZA19199*/ 01628000
         LA    R5,16                                               0574 01629000
         ALR   R5,R2                                               0574 01630000
*                           RFY                                    0575 01631000
*                             HDR BASED(R5);/* REBASE THE HDR      0575 01632000
*                                                            @ZA19199*/ 01633000
*                           IF R5>=RCBBUFE THEN/* DID THE HDR WRAP 0576 01634000
*                                                            @ZA19199*/ 01635000
         C     R5,RCBBUFE(,R12)                                    0576 01636000
         BL    @RF00576                                            0576 01637000
*                             R5=R5-RCBTLNG;/* YES - RESET POINTER 0577 01638000
*                                                            @ZA19199*/ 01639000
         LH    R14,RCBTLNG(,R12)                                DSK1193 01640000
         N     R14,@CF02089                                     DSK1193 01641000
         SLR   R5,R14                                           DSK1193 01642000
*                           ELSE                                   0578 01643000
*                             ;     /* NO - POINTER OK       @ZA19199*/ 01644000
@RF00576 DS    0H                                                  0579 01645000
*                           IF HDRTYP=LRBHMCH THEN/* IF THIS IS A  0579 01646000
*                                      HARDWARE RECORD       @G17EP5W*/ 01647000
         CLI   HDRTYP(R5),X'13'                                    0579 01648000
         BNE   @RF00579                                            0579 01649000
*                             HDRDS13=YES;/* INDICATE ERRORID PRESENT   01650000
*                                                            @G17EP5W*/ 01651000
         OI    HDRDS13(R5),B'00010000'                             0580 01652000
*                           ELSE    /* OTHERWISE IT IS A SOFTWARE  0581 01653000
*                                      RECORD                @G17EP5W*/ 01654000
*                             HDRDS12=YES;/* INDICATE ERRORID PRESENT   01655000
*                                                            @G17EP5W*/ 01656000
         B     @RC00579                                            0581 01657000
@RF00579 OI    HDRDS12(R5),B'00100000'                             0581 01658000
*                           RFY                                    0582 01659000
*                             HDR BASED(ADDR(AR149HDR));/* REBASE  0582 01660000
*                                      BACK                  @ZA19199*/ 01661000
@RC00579 DS    0H                                                  0583 01662000
*                           RFY                                    0583 01663000
*                             R5 UNRSTD;/* FREE HDR POINTER  @ZA19199*/ 01664000
*                         END;      /* END ADD ERRORID       @G17EP5W*/ 01665000
*                     END;                                         0585 01666000
@RF00553 DS    0H                                                  0586 01667000
*                   RCBBRDY=YES;    /* MARK THE RECORD READY         */ 01668000
@RC00506 OI    RCBBRDY(R2),B'00000001'                             0586 01669000
A00081E  DS    0H                                               DSK1193 01669010
         L     R14,CVTPTR                                       DSK1193 01669020
         L     R14,CVTRTMCT-CVTMAP(,R14)                        DSK1193 01669030
         L     R12,RTCTRCB-RTCT(,R14)                           DSK1193 01669040
*                 END;              /* END SPACE ALLOTED PROCESSING  */ 01670000
*               RESPECIFY           /* RELEASE REGISTERS FROM        */ 01671000
*                (R7,               /* MAINTAINING HEADER LENGTH     */ 01672000
*                 R6,               /* CALCULATING SPACE REQUIREMENT */ 01673000
*                 R2,               /* POINTER TO ALLOTED SPACE      */ 01674000
*                 R10,              /* POINTER TO DATA               */ 01675000
*                 R9,               /* POINTER TO PARMLIST           */ 01676000
*                 R3,               /* POINTER TO PARAM ERRORID    0588 01677000
*                                                            @G17EP5W*/ 01678000
*                 R4) UNRESTRICTED; /* POINTER TO NEXT SPACE TO BUILD*/ 01679000
@RF00361 DS    0H                                                  0589 01680000
*SCHEDRTN:                          /* RETRY POINT IF ERROR SUFFERED    01681000
*                                      IN RER AND ESTAE/FRR IN EFFECT*/ 01682000
*/********************************************************************/ 01683000
*/*                                                                  */ 01684000
*/* THE PURPOSE OF THE SCHSRB SEGMENT IS TO SCHEULE THE RECORDING    */ 01685000
*/* SRB.  THE CODE THAT RUNS UNDER THIS SRB WILL POST THE RECORDING  */ 01686000
*/* TASK.                                                            */ 01687000
*/*                                                                  */ 01688000
*/********************************************************************/ 01689000
*                                                                  0589 01690000
*               RESPECIFY           /* RESTRICT REGISTERS FOR        */ 01691000
*                (R3,               /* SAVING SRB IN USE FIELD       */ 01692000
*                 R4) RESTRICTED;   /* CHECK & SET OF IN USE FLAG    */ 01693000
SCHEDRTN DS    0H                                                  0590 01694000
*               R3=RCBCS1;          /* SAVE SRB IN USE FLAG          */ 01695000
         L     R3,RCBCS1(,R12)                                     0590 01696000
*TEST1:                             /* TO SEE IF SRB IN USE          */ 01697000
*               R4=R3;              /* MAKE IT AVAILABLE TO SET      */ 01698000
TEST1    LR    R4,R3                                               0591 01699000
*               GENERATE REFS(R4) FLOWS(NOSCHED1);                 0592 01700000
          CLM  R4,4,INUSEMSK       /*IS SRB IN USE                  */  01701000
         BNL   A000872                                          DSK1193 01702010
*               R4=R4×INUSEON;      /* IF NOT IN USE SET IN USE      */ 01703000
         O     R4,@CF00165                                         0593 01704000
*               CS(R3,R4,RCBCS1);   /* PUT UPDATED FLAG IN THE RCB   */ 01705000
         CS    R3,R4,RCBCS1(R12)                                DSK1193 01706000
*               BC(4,TEST1);        /* IF RCB NOT ALTERED            */ 01707000
         BC    4,TEST1                                             0595 01708000
*               RESPECIFY           /* RESTRICT REGISTER FOR         */ 01709000
*                (R5,                                              0596 01710000
*                 R7) RESTRICTED;   /* ADDRESS OF SRB AND SAVE RCODE */ 01711000
*               R7=R15;             /* SAVE RETURN CODE AROUND     0597 01712000
*                                      SCHEDULE                      */ 01713000
         LR    R7,R15                                              0597 01714000
*               R5=ADDR(RCBSRB);    /* GET ADDRESS OF SRB            */ 01715000
         LA    R5,RCBSRB(,R12)                                     0598 01716000
         LA    R14,A000A68                                      DSK1193 01716010
         ST    R14,SRBEP-SRB(,R5)                               DSK1193 01716020
         ST    R8,SRBPARM-SRB(,R5)                              DSK1193 01716030
*               GEN(SCHEDULE SRB=(R5),SCOPE=GLOBAL);/* SCHEDULE THE     01717000
*                                      SRB                           */ 01718000
         SCHEDULE SRB=(R5),SCOPE=GLOBAL                                 01719000
*               R15=R7;             /* RESTORE RETURN CODE           */ 01720000
         LR    R15,R7                                              0600 01721000
A000872  DS    0H                                               DSK1193 01721010
         TM    WTOREQ(R13),B'00100000'                          DSK1193 01721020
         BNO   NOSCHED1                                         DSK1193 01721030
         AL    R12,A000AD8                                      DSK1193 01721040
*NOSCHED1:                          /* SRB WAS IN USE AND NOT      0601 01722000
*                                      SCHEDULED                     */ 01723000
*               RESPECIFY           /* RELEASE REGISTERS FROM        */ 01724000
*                (R3,               /* SAVING THE SRB IN USE FLAG    */ 01725000
*                 R4,               /* CHECK & SET OF IN USE FLAG    */ 01726000
*                 R7,               /* SAVING RETURN CODE            */ 01727000
*                 R5) UNRESTRICTED; /* ADDRESS OF SRB                */ 01728000
NOSCHED1 DS    0H                                                  0602 01729000
*/********************************************************************/ 01730000
*/*                                                                  */ 01731000
*/* THE PURPOSE OF THE DCRACNT SEGMENT IS TO DECREMENT THE ACTIVE    */ 01732000
*/*  REQUEST COUNT. THIS COUNT IS USED TO INDICATE THE NUMBER OF     */ 01733000
*/*  REQUESTS CURRENTLY MANIPULATING THE RCB. IT IS DECREMENTED AS   */ 01734000
*/* THE CURRENT RECORD IS IN THE BUFFER AND RCBBUFRS MANIPULATION    */ 01735000
*/* COMPLETE.                                                        */ 01736000
*/*                                                                  */ 01737000
*/********************************************************************/ 01738000
*                                                                  0602 01739000
*               RESPECIFY           /* RESTRICT REGISTERS FOR        */ 01740000
*                (R3,               /* SAVING THE ACTIVE COUNT       */ 01741000
*                 R4) RESTRICTED;   /* DECREMENTING THE ACTIVE COUNT */ 01742000
*               R3=RCBCS2;          /* SAVE CURRENT ACTIVE REQUEST 0603 01743000
*                                      COUNT                         */ 01744000
         L     R3,RCBCS2(,R12)                                     0603 01745000
*TRCS4:                             /* RCBACNT WILL BE DECREMENTED 0604 01746000
*                                      VIA CS EFFECTING SERIALIZATION*/ 01747000
*               R4=R3;              /* MAKE AVAILABLE FOR          0604 01748000
*                                      DECREMENTING                  */ 01749000
TRCS4    LR    R4,R3                                               0604 01750000
*               R4=R4-HIHALF1;      /* DECREMENT ACTIVE REQUEST CT.  */ 01751000
         SL    R4,HIHALF1                                          0605 01752000
*               CS(R3,R4,RCBCS2);   /* PUT UPDATED COUNT IN RCB      */ 01753000
         CS    R3,R4,RCBCS2(R12)                                DSK1193 01754000
*               BC(4,TRCS4);        /* IF RCBACNT IS NOT ALTERED     */ 01755000
         BC    4,TRCS4                                             0607 01756000
*               UPACNT=NO;          /* INDICATE ACTIVE COUNT       0608 01757000
*                                      DECREMENTED FOR THIS REQUEST     01758000
*                                                            @YM05488*/ 01759000
         NI    UPACNT(R13),B'11101111'                             0608 01760000
*               RESPECIFY           /* FREE REGISTERS FROM           */ 01761000
*                (R3,               /* SAVING ACTIVE COUNT           */ 01762000
*                 R4) UNRESTRICTED; /* DECREMENTING ACTIVE COUNT     */ 01763000
*               IF(R15=RCTWELVE×    /* IF RETURN CODE INDICATES NOT  */ 01764000
*                   R15=RC6TEEN)&   /* ENOUGH SPACE OR PROCESSING  0610 01765000
*                                      ERROR                         */ 01766000
*                   LOGRREQ=YES THEN/* AND THE REQUEST WAS FOR LOGREC*/ 01767000
         C     R15,@CF00135                                        0610 01768000
         BE    @GL00005                                            0610 01769000
         C     R15,@CF00062                                        0610 01770000
         BNE   @RF00610                                            0610 01771000
@GL00005 TM    LOGRREQ(R13),B'01000000'                            0610 01772000
         BNO   @RF00610                                            0610 01773000
*/********************************************************************/ 01774000
*/*                                                                  */ 01775000
*/* THE PURPOSE OF THE INCLCNT SEGMENT IS TO INCREMENT THE LOST      */ 01776000
*/* RECORD COUNT FOR NOT SCHEDULED LOGREC REQUESTS                   */ 01777000
*/*                                                                  */ 01778000
*/********************************************************************/ 01779000
*                                                                  0611 01780000
*                 DO;                                              0611 01781000
*                   RESPECIFY       /* RESTRICT REGISTERS FOR        */ 01782000
*                    (R3,           /* SAVING LOST RECORD COUNT      */ 01783000
*                     R4) RESTRICTED;/* INCREMENTING LOST REC CT     */ 01784000
*                   R3=RCBCS1;      /* SAVE CURRENT LOST RECORD COUNT*/ 01785000
         L     R3,RCBCS1(,R12)                                     0613 01786000
*TRYCS1:                            /* RCBLCNT WILL BE INCREMENTED 0614 01787000
*                                      VIA CS EFFECTING SERIALIZATION*/ 01788000
*                   R4=R3;          /* MAKE COUNT AVAILABLE FOR    0614 01789000
*                                      INCREMENTING                  */ 01790000
TRYCS1   LR    R4,R3                                               0614 01791000
*                   R4=R4+HIBYTE1;  /* INCREMENT BY ONE              */ 01792000
         AL    R4,HIBYTE1                                          0615 01793000
*                   CS(R3,R4,RCBCS1);/* PLACE UPDATED COUNT IN THE 0616 01794000
*                                      RCB                           */ 01795000
         CS    R3,R4,RCBCS1(R12)                                DSK1193 01796000
*                   BC(4,TRYCS1);   /* IF THE RCB NOT ALTERED        */ 01797000
         BC    4,TRYCS1                                            0617 01798000
*                   RESPECIFY       /* RELEASE REGISTERS FROM        */ 01799000
*                    (R3,           /* SAVING LOST RECORD COUNT      */ 01800000
*                     R4) UNRESTRICTED;/* INCREMENTING LOST RECORD 0618 01801000
*                                      COUNT                         */ 01802000
*                 END;              /* END INCLCNT                   */ 01803000
*             END;                  /* END NO PREVIOUS ERROR RECORD     01804000
*                                      PROCESSING                    */ 01805000
@RF00610 DS    0H                                                  0621 01806000
*/********************************************************************/ 01807000
*/*                                                                  */ 01808000
*/* THE PURPOSE OF THE REMRCV SEGMENT IS TO DELETE RECOVERY SET UP   */ 01809000
*/* BY THE ESTRCV SEGMENT                                            */ 01810000
*/*                                                                  */ 01811000
*/********************************************************************/ 01812000
*                                                                  0621 01813000
*           RESPECIFY               /* RESTRICT REGISTERS FOR        */ 01814000
*            (R3,                   /* SET FRR WORKREG               */ 01815000
*             R4,                   /* SET FRR WORKREG               */ 01816000
*             R7) RESTRICTED;       /* PRESERVING RETURN CODE        */ 01817000
@RC00237 DS    0H                                                  0622 01818000
*           R7=R15;                 /* SAVE REGISTER CLOBBERED BY  0622 01819000
*                                      ESTAE                         */ 01820000
         LR    R7,R15                                              0622 01821000
*           IF ESTAEREQ=YES&        /* IF RECOVERY BY ESTAE          */ 01822000
*               NOESTAE=NO THEN     /* IF ESTAE WAS ESTABLISHED      */ 01823000
         TM    ESTAEREQ(R13),B'10000000'                           0623 01824000
         BNO   @RF00623                                            0623 01825000
         TM    NOESTAE(R13),B'00100000'                            0623 01826000
         BNZ   @RF00623                                            0623 01827000
*             DO;                                                  0624 01828000
*               DO;                 /* FREEMAIN(RC) LV(LENGTH(GMSPACE   01829000
*                                      ))A(GMAD->GMSPACE) SP(253)    */ 01830000
*                 RESPECIFY                                        0626 01831000
*                  (GPR01F,                                        0626 01832000
*                   GPR15F,                                        0626 01833000
*                   GPR00F) RESTRICTED;                            0626 01834000
*                 GPR01F=0;         /* REG 1 MUST BE ZERO            */ 01835000
         SLR   R1,R1                                            DSK1193 01836000
*                 GPR15F=1;         /* SET TYPE                      */ 01837000
         LA    R15,1                                            DSK1193 01838000
*                 GPR00F=LENGTH(GMSPACE);/* LENGTH REQUESTED         */ 01839000
         LA    R0,40                                            DSK1193 01840000
*                 GPR01F=ADDR(GMAD->GMSPACE);/* SET REGISTER ONE     */ 01841000
         L     R1,GMAD(,R13)                                    DSK1193 01842000
*                 GPR15F=GPR15F+((253)*256);/* SUBPOOL VALUE         */ 01843000
         AL    R15,@CF02076                                     DSK1193 01844000
*                 SVC(120);         /* RC/RU-FORM OF GETMAIN         */ 01845000
         SVC   120                                                 0632 01846000
*                 RESPECIFY                                        0633 01847000
*                  (GPR01F,                                        0633 01848000
*                   GPR15F,                                        0633 01849000
*                   GPR00F) UNRESTRICTED;                          0633 01850000
*               END;                /* FREEMAIN(RC) LV(LENGTH(GMSPACE   01851000
*                                      ))A(GMAD->GMSPACE) SP(253)    */ 01852000
*               GEN(ESTAE 0);       /* DELETE IT                     */ 01853000
         ESTAE 0                                                        01854000
*             END;                                                 0636 01855000
*           IF FRRREQ=YES THEN      /* IF RECOVERY BY SETFRR         */ 01856000
@RF00623 TM    FRRREQ(R13),B'01000000'                             0637 01857000
         BNO   @RF00637                                            0637 01858000
*             DO;                                                  0638 01859000
*               GEN(SETFRR D,WRKREGS=(R3,R4));/* DELETE IT           */ 01860000
         SETFRR D,WRKREGS=(R3,R4)                                       01861000
*             END;                                                 0640 01862000
*           R15=R7;                 /* RESTORE REG CLOBBERED BY ESTAE*/ 01863000
@RF00637 LR    R15,R7                                              0641 01864000
*           RESPECIFY               /* RELEASE REGISTER FROM         */ 01865000
*            (R3,                   /* SETFRR WRKREG                 */ 01866000
*             R4,                   /* SETFRR WRKREG                 */ 01867000
*             R7) UNRESTRICTED;     /* PRESERVING RETURN CODE        */ 01868000
*         END;                      /* END NON EMERGENCY PROCESSING  */ 01869000
*     END;                          /* END RTCT INIT PROCESS @YM33344*/ 01870000
@RC00114 DS    0H                                                  0645 01871000
*   RESPECIFY                       /* RESTRICT REGISTER FOR         */ 01872000
*     R14 RESTRICTED;               /* USE FOR RETURN                */ 01873000
@RC00109 DS    0H                                                  0646 01874000
*   R14=SAVE14;                     /* RESTORE REGISTER 14           */ 01875000
         L     R14,SAVE14(,R13)                                    0646 01876000
*   RESPECIFY                       /* RELEASE REGISTER FROM         */ 01877000
*     R14 UNRESTRICTED;             /* USE FOR RETURN                */ 01878000
*   GEN;                                                           0648 01879000
*                                                                  0648 01880000
          LM    R2,R12,R2DISP(R13)      /* RESTORE REGISTERS 2-12    */ 01881000
          BR    R14                     /* RETURN TO CALLER          */ 01882000
*/********************************************************************/ 01883000
*/*                                                                  */ 01884000
*/* THE  RCDRCVR SEGMENT GETS CONTROL WHEN AN ERROR IS SUFFERED IN   */ 01885000
*/* IEAVTRER NO CORRECTIVE ACTION IS TAKEN A BIT IT SET TO NOTIFY THE*/ 01886000
*/* TASK TO QUIESCE AND CLEANUP.  FURTHER RECORDING IS PROHIBITED TIL*/ 01887000
*/*  THE RCB REINITIALIZATION IS COMPLETE.                           */ 01888000
*/*                                                                  */ 01889000
*/********************************************************************/ 01890000
*                                                                  0649 01891000
*RCDRCVR:                                                          0649 01892000
*   PROCEDURE OPTIONS(NOSAVE,NOSAVEAREA);                          0649 01893000
         B     @PB00002                                            0649 01894000
RCDRCVR  DS    0H                                                  0650 01895000
*   RFY                                                            0650 01896000
*    (R14,                                                         0650 01897000
*     R1,                                                          0650 01898000
*     R2,                                                          0650 01899000
*     R7,                                                          0650 01900000
*     R1) RSTD;                                                    0650 01901000
*   DO;                             /* ENTESTAE (8)ERREXIT(NORTCA)   */ 01902000
*/*  ENTRY CODE FOR ESTAE ROUTINE.                                   */ 01903000
*/*  IF RTCA ALLOCATED THEN RESTORE CODE AND                         */ 01904000
*/*  DATA REGS FROM START OF USERS PARM LIST,                        */ 01905000
*/*  AND ESTABLISH ADDR TO ESTAE SAVE AREA                           */ 01906000
*/*  IF REQUIRED.                                                    */ 01907000
*/*  IF NO RTCA AVAILABLE THEN BRANCH TO ERROR                       */ 01908000
*/*  CODE AFTER ESTABLISHING ADDRESSABILITY                          */ 01909000
*                                                                  0652 01910000
*     GEN(USING *,GPR15P);                                         0652 01911000
         USING *,R15                                            DSK1193 01912000
*     GEN(CH    GPR00F,*+18);       /* CHECK IF RTCA ALLOC FAILED    */ 01913000
         CH    R0,*+18                                          DSK1193 01914000
*     GEN(BNE   *+16);              /* NO,SAVE RTM REGS              */ 01915000
         BNE   *+16                                                     01916000
*     GEN(DROP  GPR15P);            /* DROP LOCAL ADDR               */ 01917000
         DROP  R15                                              DSK1193 01918000
*     GEN(LR    GPR15P,GPR02P);     /* PTR TO USER PARM LIST         */ 01919000
         LR    R15,R2                                           DSK1193 01920000
*     GEN(L     8,00(GPR15P));                                     0657 01921000
         L     R8,0(R15)                                        DSK1193 01922000
*     GEN(B     NORTCA);            /* BRANCH TO ERROR EXIT          */ 01923000
         B     NORTCA                                                   01924000
*     GEN(DC    H'12');             /* NO RTCA AVAIL RC              */ 01925000
         DC    H'12'                                                    01926000
*     GEN(STM   GPR14P,GPR12F,12(GPR13P));/* GOOD R13, SAVE RTM'S  0660 01927000
*                                      REGS                          */ 01928000
         STM   R14,R12,12(R13)                                  DSK1193 01929000
*     GEN(L     GPR15P,0(GPR01P));  /* PTR TO USER PARM LIST         */ 01930000
         L     R15,0(R1)                                        DSK1193 01931000
*     GEN(L     8,00(GPR15P));                                     0662 01932000
         L     R8,0(R15)                                        DSK1193 01933000
*   END;                            /* ENTESTAE (8)ERREXIT(NORTCA)   */ 01934000
*   RFY                                                            0664 01935000
*     SDWA BASED(R1);               /* POINT TO SDWA FROM RTM        */ 01936000
*FRREP:                             /* ENTRY POINT IF RECOVERY IS FRR*/ 01937000
*   R2=SDWAPARM;                    /* PICK UP THE POINTER TO      0665 01938000
*                                      PARMLIST FROM THE SDWA        */ 01939000
FRREP    L     R2,SDWAPARM-SDWA(,R1)                            DSK1193 01940000
*   SDWASR01=R2;                    /* SAVE PARMLIST ADDRESS FOR   0666 01941000
*                                      RETRY ROUTINE (ONLY IF FRR) IF   01942000
*                                      ESTAE SETRP WILL HANDLE REG 2 */ 01943000
         ST    R2,SDWASR01-SDWA(,R1)                            DSK1193 01944000
*   RFY                                                            0667 01945000
*     GMSPACE BASED(R2);            /* MAP WITH PARMLIST DECLARED    */ 01946000
*   R8=RETRY8;                      /* ENSURE ADDRESSABILITY (FRR)   */ 01947000
         L     R8,RETRY8(,R2)                                      0668 01948000
*   R7=R14;                         /* SAVE THE RETURN ADDRESS TO RTM*/ 01949000
         LR    R7,R14                                              0669 01950000
*   R13=RETRY13;                    /* RESTORE SAVEAREA POINTER    0670 01951000
*                                                            @YM05488*/ 01952000
         L     R13,RETRY13(,R2)                                    0670 01953000
*   R12=RTCTRCB;                    /* RESTORE RCB POINTER   @YM05488*/ 01954000
         L     R9,CVTPTR                                        DSK1193 01955000
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 01956000
         L     R12,RTCTRCB-RTCT(,R9)                            DSK1193 01957000
*   IF SDWACMPC=CHARLIE2×           /* IF ERROR WAS PRIV OP EXCP     */ 01958000
*       SDWACMPC=CHARLIE4 THEN      /* OR PROTECTION CHECK           */ 01959000
         CLC   SDWACMPC-SDWA(3,R1),CHARLIE2                     DSK1193 01960000
         BE    @RT00672                                            0672 01961000
         CLC   SDWACMPC-SDWA(3,R1),A000B10                      DSK1193 01962010
         BNE   @RF00672                                            0672 01963000
@RT00672 DS    0H                                                  0673 01964000
*     DO;                           /* CONTINUE WITH TERMINATION     */ 01965000
*       IF UPACNT=YES THEN          /* IF RCB HAS BE UPDATED @YM05488*/ 01966000
         TM    UPACNT(R13),B'00010000'                             0674 01967000
         BNO   @RF00674                                            0674 01968000
*         DO;                                                      0675 01969000
*           RTCTRTER=YES;           /* INDICATE TO TASK TO CLEANUP   */ 01970000
         L     R9,CVTPTR                                        DSK1193 01971000
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 01972000
         OI    RTCTRFLG-RTCT(R9),RTCTRTER                       DSK1193 01973000
         TM    WTOREQ(R13),B'00100000'                          DSK1193 01973010
         BNO   A00098C                                          DSK1193 01973020
         AL    R12,A000AD8                                      DSK1193 01973030
*/********************************************************************/ 01974000
*/*                                                                  */ 01975000
*/* THE PURPOSE OF THE DCRACNT SEGMENT IS TO DECREMENT THE ACTIVE    */ 01976000
*/*  REQUEST COUNT. THIS COUNT IS USED TO INDICATE THE NUMBER OF     */ 01977000
*/*  REQUESTS CURRENTLY MANIPULATING THE RCB. IT IS DECREMENTED AS   */ 01978000
*/* THE CURRENT RECORD IS IN THE BUFFER AND RCBBUFRS MANIPULATION    */ 01979000
*/* COMPLETE.                                                        */ 01980000
*/*                                                                  */ 01981000
*/********************************************************************/ 01982000
*                                                                  0677 01983000
*           RESPECIFY               /* RESTRICT REGISTERS FOR        */ 01984000
*            (R3,                   /* SAVING THE ACTIVE COUNT       */ 01985000
*             R4) RESTRICTED;       /* DECREMENTING THE ACTIVE COUNT */ 01986000
*           R3=RCBCS2;              /* SAVE CURRENT ACTIVE REQUEST 0678 01987000
*                                      COUNT                         */ 01988000
A00098C  DS    0H                                               DSL1193 01988010
         L     R3,RCBCS2(,R12)                                     0678 01989000
*RCVCS:                             /* RCBACNT WILL BE DECREMENTED 0679 01990000
*                                      VIA CS EFFECTING SERIALIZATION*/ 01991000
*           R4=R3;                  /* MAKE AVAILABLE FOR          0679 01992000
*                                      DECREMENTING                  */ 01993000
RCVCS    LR    R4,R3                                               0679 01994000
*           R4=R4-HIHALF1;          /* DECREMENT ACTIVE REQUEST CT.  */ 01995000
         SL    R4,HIHALF1                                          0680 01996000
*           CS(R3,R4,RCBCS2);       /* PUT UPDATED COUNT IN RCB      */ 01997000
         CS    R3,R4,RCBCS2(R12)                                DSK1193 01998000
*           BC(4,RCVCS);            /* IF RCBACNT IS NOT ALTERED     */ 01999000
         BC    4,RCVCS                                             0682 02000000
*           UPACNT=NO;              /* INDICATE ACTIVE COUNT       0683 02001000
*                                      DECREMENTED FOR THIS REQUEST     02002000
*                                                            @YM05488*/ 02003000
         NI    UPACNT(R13),B'11101111'                             0683 02004000
*           RESPECIFY               /* FREE REGISTERS FROM           */ 02005000
*            (R3,                   /* SAVING ACTIVE COUNT           */ 02006000
*             R4) UNRESTRICTED;     /* DECREMENTING ACTIVE COUNT     */ 02007000
*         END;                                                     0685 02008000
*       DO;                         /* SETRP RECORD(NO)RC(0)         */ 02009000
@RF00674 DS    0H                                                  0687 02010000
*         RESPECIFY                                                0687 02011000
*          (GPR00P,                                                0687 02012000
*           GPR01P,                                                0687 02013000
*           GPR14P,                                                0687 02014000
*           GPR15P) RSTD;                                          0687 02015000
*         GPR01P->SDWARCDE=0;       /* SAVE RC VALUE                 */ 02016000
         MVI   SDWARCDE-SDWA(R1),X'00'                          DSK1193 02017000
*         GPR01P->SDWARCRD='0'B;    /* TURN OFF RECORD INDICATOR     */ 02018000
         NI    SDWAACF2-SDWA(R1),255-SDWARCRD                   DSK1193 02019000
*         RESPECIFY                                                0690 02020000
*          (GPR00P,                                                0690 02021000
*           GPR01P,                                                0690 02022000
*           GPR14P,                                                0690 02023000
*           GPR15P) UNRSTD;                                        0690 02024000
*       END;                                                       0691 02025000
*     END;                                                         0692 02026000
*   ELSE                            /* IF NONE OF THE ABOVE ERRORS   */ 02027000
*     DO;                           /* RETRY IS EFFECTED IN IEAVTRER    02028000
*                                      AT THE POINT WHERE THE      0693 02029000
*                                      RECORDING TASK IS POSTED AND     02030000
*                                      RETURN WILL BE MADE TO CALLER    02031000
*                                      WITH THE APPROPRIATE RETURN 0693 02032000
*                                      CODE                          */ 02033000
         B     @RC00672                                            0693 02034000
@RF00672 DS    0H                                                  0694 02035000
*       RTCTRTER=YES;               /* NOTIFY THE TASK TO CLEANUP    */ 02036000
         L     R9,CVTPTR                                        DSK1193 02037000
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 02038000
         OI    RTCTRFLG-RTCT(R9),RTCTRTER                       DSK1193 02039000
*       DO;                         /* SETRP RETADDR(RETPOINT)FRESDWA   02040000
*                                      (YES)RC(4)RECORD(NO)          */ 02041000
*         RESPECIFY                                                0696 02042000
*          (GPR00P,                                                0696 02043000
*           GPR01P,                                                0696 02044000
*           GPR14P,                                                0696 02045000
*           GPR15P) RSTD;                                          0696 02046000
*         GPR01P->SDWARCDE=4;       /* STORE RC INTO SDWA            */ 02047000
         MVI   SDWARCDE-SDWA(R1),X'04'                          DSK1193 02048000
*         GPR01P->SDWARTYA=ADDR(RETPOINT);/* SAVE RETRY ADDRESS      */ 02049000
         L     R9,RETRYADR(,R2)                                 DSK1193 02050000
         ST    R9,SDWARTYA-SDWA(,R1)                            DSK1193 02051000
*         GPR01P->SDWAFREE='1'B;    /* SET FLAG TO FREE SDWA         */ 02052000
*         GPR01P->SDWARCRD='0'B;    /* TURN OFF RECORD INDICATOR     */ 02053000
         OI    SDWAACF2-SDWA(R1),SDWAFREE                       DSK1193 02054000
         NI    SDWAACF2-SDWA(R1),255-SDWARCRD                   DSK1193 02055000
*         RESPECIFY                                                0701 02056000
*          (GPR00P,                                                0701 02057000
*           GPR01P,                                                0701 02058000
*           GPR14P,                                                0701 02059000
*           GPR15P) UNRSTD;                                        0701 02060000
*       END;                                                       0702 02061000
*     END;                                                         0703 02062000
*   R14=R7;                         /* RESTORE RTM RETURN POINT      */ 02063000
@RC00672 LR    R14,R7                                              0704 02064000
*   GOTO R14;                       /* RETURN TO THE RTM             */ 02065000
         BR    R14                                                 0705 02066000
*NORTCA:                            /* IF RTCA/SDWA NOT OBTAINED     */ 02067000
*   RFY                                                            0706 02068000
*     GMSPACE BASED(R2);                                           0706 02069000
NORTCA   DS    0H                                                  0707 02070000
*   R13=RETRY13;                    /* RESTORE SAVEAREA POINTER    0707 02071000
*                                                            @YM05488*/ 02072000
         L     R13,RETRY13(,R2)                                    0707 02073000
*   R12=RTCTRCB;                    /* RESTORE RCB POINTER   @YM05488*/ 02074000
         L     R9,CVTPTR                                        DSK1193 02075000
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 02076000
         L     R12,RTCTRCB-RTCT(,R9)                            DSK1193 02077000
*   IF R1=CHARLIE2×                 /* IF ERROR WAS PRIV OP EXCP     */ 02078000
*       R1=CHARLIE4 THEN            /* OR PROTECTION CHECK           */ 02079000
         SLR   R9,R9                                            DSK1193 02080000
         ICM   R9,7,CHARLIE2                                    DSK1193 02081000
         CR    R1,R9                                            DSK1193 02082000
         BE    @RT00709                                            0709 02083000
         SLR   R9,R9                                            DSK1193 02084000
         ICM   R9,7,A000B10                                     DSK1193 02085010
         CR    R1,R9                                            DSK1193 02086000
         BNE   @RF00709                                            0709 02087000
@RT00709 DS    0H                                                  0710 02088000
*     DO;                           /* CONTINUE WITH TERMINATION     */ 02089000
*       IF UPACNT=YES THEN          /* IF RCB HAS BE UPDATED @YM05488*/ 02090000
         TM    UPACNT(R13),B'00010000'                             0711 02091000
         BNO   @RF00711                                            0711 02092000
*         DO;                                                      0712 02093000
*           RTCTRTER=YES;           /* INDICATE TO TASK TO CLEANUP   */ 02094000
         L     R9,CVTPTR                                        DSK1193 02095000
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 02096000
         OI    RTCTRFLG-RTCT(R9),RTCTRTER                       DSK1193 02097000
         TM    WTOREQ(R13),B'00100000'                          DSK1193 02097010
         BNO   A000A1A                                          DSK1193 02097020
         AL    R12,A000AD8                                      DSK1193 02097030
*/********************************************************************/ 02098000
*/*                                                                  */ 02099000
*/* THE PURPOSE OF THE DCRACNT SEGMENT IS TO DECREMENT THE ACTIVE    */ 02100000
*/*  REQUEST COUNT. THIS COUNT IS USED TO INDICATE THE NUMBER OF     */ 02101000
*/*  REQUESTS CURRENTLY MANIPULATING THE RCB. IT IS DECREMENTED AS   */ 02102000
*/* THE CURRENT RECORD IS IN THE BUFFER AND RCBBUFRS MANIPULATION    */ 02103000
*/* COMPLETE.                                                        */ 02104000
*/*                                                                  */ 02105000
*/********************************************************************/ 02106000
*                                                                  0714 02107000
*           RESPECIFY               /* RESTRICT REGISTERS FOR        */ 02108000
*            (R3,                   /* SAVING THE ACTIVE COUNT       */ 02109000
*             R4) RESTRICTED;       /* DECREMENTING THE ACTIVE COUNT */ 02110000
*           R3=RCBCS2;              /* SAVE CURRENT ACTIVE REQUEST 0715 02111000
*                                      COUNT                         */ 02112000
A000A1A  DS    0H                                               DSK1193 02112010
         L     R3,RCBCS2(,R12)                                     0715 02113000
*RCVCS1:                            /* RCBACNT WILL BE DECREMENTED 0716 02114000
*                                      VIA CS EFFECTING SERIALIZATION*/ 02115000
*           R4=R3;                  /* MAKE AVAILABLE FOR          0716 02116000
*                                      DECREMENTING                  */ 02117000
RCVCS1   LR    R4,R3                                               0716 02118000
*           R4=R4-HIHALF1;          /* DECREMENT ACTIVE REQUEST CT.  */ 02119000
         SL    R4,HIHALF1                                          0717 02120000
*           CS(R3,R4,RCBCS2);       /* PUT UPDATED COUNT IN RCB      */ 02121000
         CS    R3,R4,RCBCS2(R12)                                DSK1193 02122000
*           BC(4,RCVCS1);           /* IF RCBACNT IS NOT ALTERED     */ 02123000
         BC    4,RCVCS1                                            0719 02124000
*           UPACNT=NO;              /* INDICATE ACTIVE COUNT       0720 02125000
*                                      DECREMENTED FOR THIS REQUEST     02126000
*                                                            @YM05488*/ 02127000
         NI    UPACNT(R13),B'11101111'                             0720 02128000
*           RESPECIFY               /* FREE REGISTERS FROM           */ 02129000
*            (R3,                   /* SAVING ACTIVE COUNT           */ 02130000
*             R4) UNRESTRICTED;     /* DECREMENTING ACTIVE COUNT     */ 02131000
*         END;                                                     0722 02132000
*       R15=RCZERO;                 /* INDICATE TO RTM TERMINATE     */ 02133000
@RF00711 SLR   R15,R15                                             0723 02134000
*     END;                                                         0724 02135000
*   ELSE                            /* IF NONE OF THE ABOVE RETRY    */ 02136000
*     DO;                           /* IN IEAVTRER AT SCHED OF SRB   */ 02137000
         B     @RC00709                                            0725 02138000
@RF00709 DS    0H                                                  0726 02139000
*       RFY                                                        0726 02140000
*         R0 RSTD;                                                 0726 02141000
*       R15=RCFOUR;                 /* INDICATE RETRY                */ 02142000
         LA    R15,4                                               0727 02143000
*       R0=RETRYADR;                /* RETURN TO RTM THE RETRY ADDR  */ 02144000
         L     R0,RETRYADR(,R2)                                    0728 02145000
*       RTCTRTER=YES;               /* INDICATE TO TASK TO CLEANUP   */ 02146000
         L     R9,CVTPTR                                        DSK1193 02147000
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 02148000
         OI    RTCTRFLG-RTCT(R9),RTCTRTER                       DSK1193 02149000
*       RFY                                                        0730 02150000
*         R0 UNRSTD;                                               0730 02151000
*     END;                                                         0731 02152000
*   GOTO R14;                       /* RETURN TO RTM                 */ 02153000
@RC00709 BR    R14                                                 0732 02154000
*   RFY                                                            0733 02155000
*    (R14,                                                         0733 02156000
*     R1,                                                          0733 02157000
*     R2,                                                          0733 02158000
*     R7,                                                          0733 02159000
*     R1) UNRSTD;                                                  0733 02160000
*   END RCDRCVR;                                                   0734 02161000
*                                                                  0734 02162000
@PB00002 DS    0H                                                  0734 02163000
*/********************************************************************/ 02164000
*/*                                                                  */ 02165000
*/* IF THE RECOVERY EXIT GETS CONTOL RETRY IS EFFECTED AT THIS POINT */ 02166000
*/* SO THE RETURN CODE IN REGISTER 15 MAY BE SET AND ADDRESSIBILITY  */ 02167000
*/* CAN BE ESTABLISHED PRIOR TO RETRYING IN THE MAINLINE             */ 02168000
*/*                                                                  */ 02169000
*/********************************************************************/ 02170000
*                                                                  0735 02171000
*RETRYRTN:                          /* COMMON RETRY CODE FROM RCDRCVR*/ 02172000
*   DO;                                                            0735 02173000
RETRYRTN DS    0H                                                  0736 02174000
*     RFY                                                          0736 02175000
*       R1 RSTD;                                                   0736 02176000
*     RFY                                                          0737 02177000
*       GMSPACE BASED(R1);                                         0737 02178000
*     R8=RETRY8;                    /* RESET BASE REGISTER FOR RER   */ 02179000
         L     R8,RETRY8(,R1)                                      0738 02180000
*     R13=RETRY13;                  /* RESTORE PTR TO CALLERS      0739 02181000
*                                      SAVEAREA                      */ 02182000
         L     R13,RETRY13(,R1)                                    0739 02183000
*     R12=RTCTRCB;                  /* REFRESH RCB BASE              */ 02184000
         L     R14,CVTPTR                                       DSK1193 02185000
         L     R14,CVTRTMCT-CVTMAP(,R14)                        DSK1193 02186000
         L     R12,RTCTRCB-RTCT(,R14)                           DSK1193 02187000
*     R15=RC6TEEN;                  /* SHOW TEMPORARY ERROR          */ 02188000
         LA    R15,16                                              0741 02189000
*     GOTO SCHEDRTN;                /* RETRY AT SCHEDULE OF SRB TO 0742 02190000
*                                      POST THE RECORDING TASK       */ 02191000
         B     A00081E                                          DSK1193 02192010
A000A68  DS    0H                                               DSK1193 02192020
         LR    R6,R14                                           DSK1193 02192030
         LR    R8,R1                                            DSK1193 02192040
         SETLOCK OBTAIN,TYPE=LOCAL,MODE=UNCOND,RELATED=RELEASE  DSK1193 02192050
         SLR   R10,R10                                          DSK1193 02192060
         L     R14,CVTPTR                                       DSK1193 02192070
         L     R11,CVTRTMCT-CVTMAP(,R14)                        DSK1193 02192080
         LA    R11,RTCTRECB-RTCT(,R11)                          DSK1193 02192090
         L     R15,CVT0PT01-CVTMAP(,R14)                        DSK1193 02192100
         BALR  R14,R15                                          DSK1193 02192110
         SETLOCK RELEASE,TYPE=LOCAL,RELATED=OBTAIN              DSK1193 02192120
         L     R9,CVTPTR                                        DSK1193 02192130
         L     R9,CVTRTMCT-CVTMAP(,R9)                          DSK1193 02192140
         L     R12,RTCTRCB-RTCT(,R9)                            DSK1193 02192150
         L     R3,RCBCS1(,R12)                                  DSK1193 02192160
A000AA4  DS    0H                                               DSK1193 02192170
         LR    R4,R3                                            DSK1193 02192180
         N     R4,A000AEC                                       DSK1193 02192190
         CS    R3,R4,RCBCS1(R12)                                DSK1193 02192200
         BL    A000AA4                                          DSK1193 02192210
         LR    R14,R6                                           DSK1193 02192220
         BR    R14                                              DSK1193 02192230
*     RFY                                                          0743 02193000
*       R1 UNRSTD;                                                 0743 02194000
*   END;                                                           0744 02195000
*   DECLARE                         /* GENERAL PURPOSE REGISTERS     */ 02196000
*     GPR00F FIXED(31) REG(0),                                     0745 02197000
*     GPR01F FIXED(31) REG(1),                                     0745 02198000
*     GPR12F FIXED(31) REG(12),                                    0745 02199000
*     GPR15F FIXED(31) REG(15),                                    0745 02200000
*     GPR00P PTR(31) REG(0),                                       0745 02201000
*     GPR01P PTR(31) REG(1),                                       0745 02202000
*     GPR02P PTR(31) REG(2),                                       0745 02203000
*     GPR13P PTR(31) REG(13),                                      0745 02204000
*     GPR14P PTR(31) REG(14),                                      0745 02205000
*     GPR15P PTR(31) REG(15);                                      0745 02206000
*   DECLARE                         /* COMMON VARIABLES              */ 02207000
*     I256C CHAR(256) BASED,                                       0746 02208000
*     I031F FIXED(31) BASED,                                       0746 02209000
*     I031P PTR(31) BASED,                                         0746 02210000
*     I015F FIXED(15) BASED,                                       0746 02211000
*     I015P PTR(15) BASED,                                         0746 02212000
*     I008P PTR(8) BASED,                                          0746 02213000
*     I001C CHAR(1) BASED;                                         0746 02214000
*   END IEAVTRER                    /* END OF IEAVTRER               */ 02215000
*                                                                  0747 02216000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 02217000
*/*%INCLUDE SYSLIB  (RERSPEC )                                       */ 02218000
*/*%INCLUDE SYSLIB  (RERDCL  )                                       */ 02219000
*/*%INCLUDE SYSLIB  (IHAESTA )                                       */ 02220000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 02221000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 02222000
*/*%INCLUDE SYSLIB  (IHARTCT )                                       */ 02223000
*/*%INCLUDE SYSLIB  (IHASRB  )                                       */ 02224000
*/*%INCLUDE SYSLIB  (IHAHDR  )                                       */ 02225000
*/*%INCLUDE SYSLIB  (RTMRCB  )                                       */ 02226000
*/*%INCLUDE SYSLIB  (IHALRB  )                                       */ 02227000
*/*%INCLUDE SYSLIB  (IHAFRRS )                                       */ 02228000
*/*%INCLUDE SYSLIB  (IHASDWA )                                       */ 02229000
*/*%INCLUDE SYSLIB  (EMERPROC)                                       */ 02230000
*/*%INCLUDE SYSLIB  (FREEREC )                                       */ 02231000
*/*%INCLUDE SYSLIB  (FREEREC )                                       */ 02232000
*/*%INCLUDE SYSLIB  (ESTRCV  )                                       */ 02233000
*/*%INCLUDE SYSLIB  (ERRPROC )                                       */ 02234000
*/*%INCLUDE SYSLIB  (SCHSRB  )                                       */ 02235000
*/*%INCLUDE SYSLIB  (SCHSRB  )                                       */ 02236000
*/*%INCLUDE SYSLIB  (INCACNT )                                       */ 02237000
*/*%INCLUDE SYSLIB  (FNDSPACE)                                       */ 02238000
*/*%INCLUDE SYSLIB  (CALCSPCE)                                       */ 02239000
*/*%INCLUDE SYSLIB  (CALCSPCE)                                       */ 02240000
*/*%INCLUDE SYSLIB  (SPCAVAIL)                                       */ 02241000
*/*%INCLUDE SYSLIB  (RECALCSP)                                       */ 02242000
*/*%INCLUDE SYSLIB  (BUILDREC)                                       */ 02243000
*/*%INCLUDE SYSLIB  (BLDAR149)                                       */ 02244000
*/*%INCLUDE SYSLIB  (MOVEDATA)                                       */ 02245000
*/*%INCLUDE SYSLIB  (DCRACNT )                                       */ 02246000
*/*%INCLUDE SYSLIB  (DCRACNT )                                       */ 02247000
*/*%INCLUDE SYSLIB  (DCRACNT )                                       */ 02248000
*/*%INCLUDE SYSLIB  (INCLCNT )                                       */ 02249000
*/*%INCLUDE SYSLIB  (REMRCV  )                                       */ 02250000
*/*%INCLUDE SYSLIB  (RCDRCVR )                                       */ 02251000
*/*%INCLUDE SYSLIB  (RETRYRTN)                                       */ 02252000
*                                                                  0747 02253000
*       ;                                                          0747 02254000
         DC    X'7B'                         !!! SOURCE COMPARE FIX !!! 02255000
@DATA    DC    0H'0'                                            DSK1193 02255000
@DATD    DSECT                                                          02256000
         DS    0F                                                       02257000
IEAVTRER CSECT                                                          02258000
         DC    0F'0'                                            DSK1193 02259000
@CF00045 DC    F'1'                                                     02260000
@CF00039 DC    F'4'                                                     02261000
@CF00032 DC    F'8'                                                     02262000
@CF00105 DC    F'10'                                                    02263000
@CF00135 DC    F'12'                                                    02264000
@CF00062 DC    F'16'                                                    02265000
@CF02073 DC    F'23'                                                    02266000
@CF00111 DC    F'24'                                                    02267000
A000AD8  DC    F'04096'                                         DSK1193 02267010
@CF02076 DC    F'64768'                                                 02268000
@CF02093 DC    F'-4'                                                    02269000
@CF00165 DC    XL4'00800000'                                            02270000
@CF02011 DC    XL4'FFFFFFF8'                                            02271000
A000AEC  DC    X'FF7FFFFF'                                      DSK1193 02271010
@CF02089 DC    XL4'0000FFFF'                                            02272000
@CF01992 DC    XL4'FFF8'                                                02273000
@DATD    DSECT                                                          02274000
         DS    0D                                                       02275000
IEAVTRER CSECT                                                          02276000
         NOPR  ((@ENDDATD-@DATD)*16)                                    02277000
         DC    X'6002'                       !!! SOURCE COMPARE FIX !!! 02278000
         DC    0F'0'                                            DSK1193 02278000
@SIZDATD DC    AL1(0)                                                   02279000
         DC    AL3(@ENDDATD-@DATD)                                      02280000
         DC    0D'0'                                            DSK1193 02281000
HIHALF1  DC    XL4'00010000'                                            02282000
HIBYTE1  DC    XL4'01000000'                                            02283000
ZERO     DC    F'0'                                                     02284000
INUSEMSK DC    X'80'                                                    02285000
CHARLIE2 DC    X'0C2000'                                                02287000
A000B10  DC    X'0C4000FC'                                      DSK1193 02288010
         DC    0F'0'                                            DSK1193 02289000
MFLESTAE ESTAE RCDRCVR,MF=L       /* SET UP ESTAE LIST               */ 02290000
@DATD    DSECT                                                          02291000
@ENDDATD EQU   *                                                        02292000
IEAVTRER CSECT                                                          02293000
         CVT      DSECT=YES,LIST=YES,PREFIX=YES                 DSK1193 02294000
         IHAFRRS  ,                                             DSK1193 02294001
         IHAPSA   ,                                             DSK1193 02294002
         IHASDWA  ,                                             DSK1193 02294003
         IHASRB   ,                                             DSK1193 02294004
         IHARTCT  ,                                             DSK1193 02294005
R0       EQU   0                       REGISTER 0               DSK1193 02294006
R1       EQU   1                       REGISTER 1               DSK1193 02294007
R2       EQU   2                       REGISTER 2               DSK1193 02294008
R3       EQU   3                       REGISTER 3               DSK1193 02294009
R4       EQU   4                       REGISTER 4               DSK1193 02294010
R5       EQU   5                       REGISTER 5               DSK1193 02294011
R6       EQU   6                       REGISTER 6               DSK1193 02294012
R7       EQU   7                       REGISTER 7               DSK1193 02294013
R8       EQU   8                       REGISTER 8               DSK1193 02294014
R9       EQU   9                       REGISTER 9               DSK1193 02294015
R10      EQU   10                      REGISTER 10              DSK1193 02294016
R11      EQU   11                      REGISTER 11              DSK1193 02294017
R12      EQU   12                      REGISTER 12              DSK1193 02294018
R13      EQU   13                      REGISTER 13              DSK1193 02294019
R14      EQU   14                      REGISTER 14              DSK1193 02294020
R15      EQU   15                      REGISTER 15              DSK1193 02294021
REGSAVE  EQU   0                                                        02367000
GMAD     EQU   REGSAVE                                                  02368000
STOREWD  EQU   REGSAVE+8                                                02369000
SMASK    EQU   STOREWD                                                  02370000
DATBIT   EQU   SMASK                                                    02371000
SOMEFLAG EQU   STOREWD+1                                                02372000
RERFLGS  EQU   SOMEFLAG                                                 02373000
TRUNCFLG EQU   RERFLGS                                                  02374000
OPTNOBUF EQU   RERFLGS                                                  02375000
NOESTAE  EQU   RERFLGS                                                  02376000
UPACNT   EQU   RERFLGS                                                  02377000
SAVE14   EQU   REGSAVE+12                                               02378000
SAVEZERO EQU   REGSAVE+20                                               02379000
REQFLDS  EQU   SAVEZERO                                                 02380000
EMERREQ  EQU   REQFLDS                                                  02381000
LOGRREQ  EQU   REQFLDS                                                  02382000
WTOREQ   EQU   REQFLDS                                                  02383000
ERRIDREQ EQU   REQFLDS                                                  02384000
ESTAEREQ EQU   REQFLDS+1                                                02385000
FRRREQ   EQU   REQFLDS+1                                                02386000
BUFREQ   EQU   REQFLDS+1                                                02387000
NBUFREQ  EQU   REQFLDS+1                                                02388000
HDRREQ   EQU   REQFLDS+1                                                02389000
JOBNMREQ EQU   REQFLDS+1                                                02390000
TIMEREQ  EQU   REQFLDS+1                                                02391000
POSTREQ  EQU   REQFLDS+1                                                02392000
DATLEN   EQU   SAVEZERO+2                                               02393000
SAVEONE  EQU   REGSAVE+24                                               02394000
DATAAD   EQU   SAVEONE                                                  02395000
DATAIND  EQU   DATAAD                                                   02396000
RCBBUF   EQU   0                                                        02397000
RCBBLEN  EQU   RCBBUF                                                   02398000
RCBBFLGS EQU   RCBBUF+2                                                 02399000
RCBBFLG1 EQU   RCBBFLGS                                                 02400000
RCBBWRAP EQU   RCBBFLG1                                                 02401000
RCBBLREC EQU   RCBBFLG1                                                 02402000
RCBBWTO  EQU   RCBBFLG1                                                 02403000
RCBBFLG2 EQU   RCBBFLGS+1                                               02404000
RCBBNBFR EQU   RCBBFLG2                                                 02405000
RCBBPOST EQU   RCBBFLG2                                                 02406000
RCBBERFG EQU   RCBBFLG2                                                 02407000
RCBBRDY  EQU   RCBBFLG2                                                 02408000
RCBBASID EQU   RCBBUF+6                                                 02409000
RCBBECB  EQU   RCBBUF+8                                                 02410000
RCBBDATA EQU   RCBBUF+16                                                02411000
NBFREC   EQU   0                                                        02412000
NBFRDATA EQU   NBFREC                                                   02413000
NBFRERID EQU   NBFREC+4                                                 02414000
DBLWORD  EQU   0                                                        02415000
BECB     EQU   0                                                        02416000
TIMEHDR  EQU   0                                                        02417000
TIMESLOT EQU   0                                                        02418000
PARMTIME EQU   0                                                        02419000
PARMHDR  EQU   0                                                        02420000
PARMTYPE EQU   PARMHDR                                                  02421000
PARMSWTS EQU   PARMHDR+1                                                02422000
PARMJOBN EQU   0                                                        02423000
PARMERID EQU   0                                                        02424000
PARMECB  EQU   0                                                        02425000
PARMASID EQU   0                                                        02426000
PARMDATA EQU   0                                                        02427000
RCBBJOBN EQU   0                                                        02428000
RCBBERID EQU   0                                                        02429000
LCLTM    EQU   0                                                        02430000
ESTAPTR  EQU   0                                                        02431000
ESTA     EQU   0                                                        02432000
ESTAEXT  EQU   ESTA                                                     02433000
ESTAFLG1 EQU   ESTAEXT                                                  02434000
ESTAIO   EQU   ESTAFLG1                                                 02435000
ESTAFGRS EQU   ESTA+12                                                  02436000
ESTAFLG2 EQU   ESTAFGRS                                                 02437000
RETPOINT EQU   0                                                        02438000
GMSPACE  EQU   0                                                        02439000
RCVPLIST EQU   GMSPACE                                                  02440000
RETRY8   EQU   RCVPLIST                                                 02441000
RETRY13  EQU   RCVPLIST+4                                               02442000
RETRYADR EQU   RCVPLIST+8                                               02443000
PKDWORD  EQU   RCVPLIST+16                                              02444000
SVC60LST EQU   GMSPACE+24                                               02445000
SRBPTR   EQU   0                                                        02531000
HDR      EQU   0                                                        02535000
HDRTYP   EQU   HDR                                                      02536000
HDROPRN  EQU   HDR+1                                                    02537000
HDROPSYS EQU   HDROPRN                                                  02538000
HDRIS    EQU   HDR+2                                                    02539000
HDRTRUNC EQU   HDRIS                                                    02540000
HDRDS    EQU   HDR+3                                                    02541000
HDRDS1   EQU   HDRDS                                                    02542000
HDRDS12  EQU   HDRDS1                                                   02543000
HDRDS13  EQU   HDRDS1                                                   02544000
HDRCNT   EQU   HDR+6                                                    02545000
HDRTM    EQU   HDR+8                                                    02546000
HDRCPID  EQU   HDR+16                                                   02547000
RCB      EQU   0                                                        02548000
RCBCNTL  EQU   RCB                                                      02549000
RCBBUFB  EQU   RCBCNTL                                                  02550000
RCBBUFE  EQU   RCBCNTL+4                                                02551000
RCBCDS   EQU   RCBCNTL+8                                                02552000
RCBFREE  EQU   RCBCDS                                                   02553000
RCBFLNG  EQU   RCBCDS+4                                                 02554000
RCBSRB   EQU   RCBCNTL+16                                               02555000
RCBCS1   EQU   RCBCNTL+88                                               02556000
RCBFLGS  EQU   RCBCS1+1                                                 02557000
RCBFLG1  EQU   RCBFLGS                                                  02558000
RCBCS2   EQU   RCBCNTL+92                                               02559000
RCBTLNG  EQU   RCBCS2+2                                                 02560000
LRBPTR   EQU   0                                                        02561000
LRB      EQU   0                                                        02562000
LRBHREL  EQU   LRB+1                                                    02563000
LRBHSYS  EQU   LRBHREL                                                  02564000
LRBHSW0  EQU   LRB+2                                                    02565000
LRBHSW1  EQU   LRB+3                                                    02566000
LRBHSW2  EQU   LRB+4                                                    02567000
LRBMACT  EQU   LRBHSW2                                                  02568000
LRBHSW3  EQU   LRB+5                                                    02569000
LRBHCPID EQU   LRB+16                                                   02570000
LRBBASE  EQU   LRB+24                                                   02571000
LRBCVAR  EQU   0                                                        02572000
LRBCMP   EQU   LRBCVAR+8                                                02573000
FRREPTR  EQU   0                                                        02574000
I001C    EQU   0                                                        02653000
I008P    EQU   0                                                        02654000
I015F    EQU   0                                                        02655000
I015P    EQU   0                                                        02656000
I031F    EQU   0                                                        02657000
I031P    EQU   0                                                        02658000
I256C    EQU   0                                                        02659000
AR149HDR EQU   RCBBDATA                                                 02660000
LRBHRSW1 EQU   LRBHSW1                                                  02679000
LRBHCSW1 EQU   LRBHSW1                                                  02680000
LRBHMSW1 EQU   LRBHSW1                                                  02681000
LRBMMCH  EQU   LRBBASE                                                  02682000
LRBMCEIA EQU   LRBMMCH+8                                                02683000
LRBMTERM EQU   LRBMCEIA                                                 02684000
LRBMHARD EQU   LRBMCEIA+1                                               02685000
LRBMINTM EQU   LRBMCEIA+2                                               02686000
LRBMSOFT EQU   LRBMCEIA+3                                               02687000
LRBMPDAR EQU   LRBMMCH+12                                               02688000
LRBMRSR1 EQU   LRBMMCH+13                                               02689000
LRBMRSR2 EQU   LRBMMCH+14                                               02690000
LRBMFLO  EQU   LRBMMCH+24                                               02691000
LRBMCIC  EQU   LRBMFLO                                                  02692000
LRBRDDR  EQU   LRBBASE                                                  02698000
LRBCCCH  EQU   LRBBASE                                                  02699000
LRBCCUA  EQU   LRBCCCH+49                                               02700000
LRBDMDR  EQU   LRBBASE                                                  02701000
LRBNMIH  EQU   LRBBASE                                                  02702000
LRBTTER  EQU   LRBBASE                                                  02703000
*                                      START UNREFERENCED COMPONENTS    02705000
LRBTUSR  EQU   LRBTTER+8                                                02706000
LRBTWSC  EQU   LRBTTER+4                                                02707000
LRBTLNH  EQU   LRBTTER                                                  02708000
LRBNINT  EQU   LRBNMIH+24                                               02709000
LRBNDEVT EQU   LRBNMIH+20                                               02710000
LRBNVOL  EQU   LRBNMIH+14                                               02711000
LRBNCUA1 EQU   LRBNMIH+11                                               02712000
LRBNCUA2 EQU   LRBNMIH+8                                                02713000
LRBNJOB  EQU   LRBNMIH                                                  02714000
LRBDSENS EQU   LRBDMDR+8                                                02715000
LRBDVOL  EQU   LRBDMDR+2                                                02716000
LRBDCUA1 EQU   LRBDMDR                                                  02717000
LRBCCLOG EQU   LRBCCCH+56                                               02718000
LRBCLOGL EQU   LRBCCCH+54                                               02719000
LRBCHCUA EQU   LRBCCCH+52                                               02720000
LRBCCUA2 EQU   LRBCCUA+1                                                02721000
LRBCCHID EQU   LRBCCCH+48                                               02723000
LRBCDEVT EQU   LRBCCCH+44                                               02724000
LRBCECSW EQU   LRBCCCH+40                                               02725000
LRBCFCSW EQU   LRBCCCH+32                                               02726000
LRBCFCCW EQU   LRBCCCH+24                                               02727000
LRBCAIO  EQU   LRBCCCH+8                                                02728000
LRBCJOB  EQU   LRBCCCH                                                  02729000
LRBRDEV2 EQU   LRBRDDR+32                                               02730000
LRBRCUA2 EQU   LRBRDDR+29                                               02731000
LRBRPH2  EQU   LRBRDDR+28                                               02732000
LRBRDEV1 EQU   LRBRDDR+24                                               02733000
LRBRCUA1 EQU   LRBRDDR+21                                               02734000
LRBRPH1  EQU   LRBRDDR+20                                               02735000
LRBRVOL2 EQU   LRBRDDR+14                                               02736000
LRBRVOL1 EQU   LRBRDDR+8                                                02737000
LRBRJOB  EQU   LRBRDDR                                                  02738000
LRBMCEL  EQU   LRBMMCH+304                                              02739000
LRBMFSA  EQU   LRBMFLO+16                                               02741000
LRBMCELL EQU   LRBMCIC+6                                                02743000
LRBMMOSW EQU   LRBMMCH+16                                               02776000
LRBMPWL  EQU   LRBMMCH+15                                               02777000
LRBMVEQR EQU   LRBMRSR2                                                 02778000
LRBMPGFX EQU   LRBMRSR2                                                 02779000
LRBMLSQA EQU   LRBMRSR2                                                 02780000
LRBMFSQA EQU   LRBMRSR2                                                 02781000
LRBMNUCL EQU   LRBMRSR2                                                 02782000
LRBMSPER EQU   LRBMRSR2                                                 02783000
LRBMINTC EQU   LRBMRSR2                                                 02784000
LRBMOFLN EQU   LRBMRSR2                                                 02785000
LRBMCHNG EQU   LRBMRSR1                                                 02786000
LRBMSER  EQU   LRBMRSR1                                                 02787000
LRBMRSRF EQU   LRBMPDAR                                                 02790000
LRBMRSRC EQU   LRBMPDAR                                                 02791000
LRBMINVP EQU   LRBMPDAR                                                 02792000
LRBMSBUF EQU   LRBMSOFT                                                 02794000
LRBMSHIR EQU   LRBMSOFT                                                 02795000
LRBMSECC EQU   LRBMSOFT                                                 02796000
LRBMSEXD EQU   LRBMSOFT                                                 02797000
LRBMSSFT EQU   LRBMSOFT                                                 02799000
LRBMIL80 EQU   LRBMINTM                                                 02800000
LRBMICTM EQU   LRBMINTM                                                 02801000
LRBMICKC EQU   LRBMINTM                                                 02802000
LRBMITOD EQU   LRBMINTM                                                 02803000
LRBMHIPD EQU   LRBMHARD                                                 02805000
LRBMHSPF EQU   LRBMHARD                                                 02806000
LRBMHSTO EQU   LRBMHARD                                                 02807000
LRBMHINV EQU   LRBMHARD                                                 02808000
LRBMHHRD EQU   LRBMHARD                                                 02810000
LRBMTINV EQU   LRBMTERM                                                 02811000
LRBMTDMG EQU   LRBMTERM                                                 02812000
LRBMTWRN EQU   LRBMTERM                                                 02813000
LRBMTCKS EQU   LRBMTERM                                                 02814000
LRBMTSEC EQU   LRBMTERM                                                 02815000
LRBMWSC  EQU   LRBMMCH+4                                                02817000
LRBMLNH  EQU   LRBMMCH                                                  02818000
LRBMSYST EQU   LRBHMSW1                                                 02820000
LRBCERPP EQU   LRBHCSW1                                                 02823000
LRBCDATA EQU   LRBHCSW1                                                 02824000
LRBCICUA EQU   LRBHCSW1                                                 02825000
LRBCNOSP EQU   LRBHCSW1                                                 02826000
LRBCINCO EQU   LRBHCSW1                                                 02828000
LRBCMESG EQU   LRBHCSW1                                                 02829000
LRBRSYSI EQU   LRBHRSW1                                                 02831000
LRBROPER EQU   LRBHRSW1                                                 02832000
LRBRSEC  EQU   LRBHRSW1                                                 02833000
LRBRPRIM EQU   LRBHRSW1                                                 02834000
LRBCMPCS EQU   LRBCMP+2                                                 03416000
LRBCMPPA EQU   LRBCMP                                                   03417000
LRBCMPNO EQU   LRBCVAR+6                                                03418000
LRBCMPF2 EQU   LRBCVAR+5                                                03419000
LRBCMPF1 EQU   LRBCVAR+4                                                03420000
LRBCRESD EQU   LRBCVAR+2                                                03421000
LRBCFT   EQU   LRBCVAR                                                  03422000
LRBHMCEL EQU   LRBHCPID+6                                               03423000
LRBHMDL  EQU   LRBHCPID+4                                               03424000
LRBHCSER EQU   LRBHCPID+1                                               03425000
LRBHTIME EQU   LRB+12                                                   03427000
LRBHDATE EQU   LRB+8                                                    03428000
LRBHCNT  EQU   LRB+6                                                    03430000
LRBMCLB  EQU   LRBHSW3                                                  03431000
LRBNDEM  EQU   LRBMACT                                                  03432000
LRBNCEM  EQU   LRBMACT                                                  03433000
LRBHTMC  EQU   LRBHSW0                                                  03435000
LRBHNS   EQU   LRBHSW0                                                  03437000
LRBHMORE EQU   LRBHSW0                                                  03438000
LRBHSYSB EQU   LRBHSYS                                                  03440000
LRBHTYPE EQU   LRB                                                      03441000
RCBBUFRS EQU   RCB+96                                                   03442000
RCBACNT  EQU   RCBCS2                                                   03443000
RCBSRBIU EQU   RCBFLG1                                                  03446000
RCBLCNT  EQU   RCBCS1                                                   03447000
RCBLRHDR EQU   RCBCNTL+64                                               03448000
RCBDUM   EQU   RCBCDS+6                                                 03449000
HDRCNTT  EQU   HDRCNT                                                   03451000
HDRCNTS  EQU   HDRCNT                                                   03452000
HDRDS3   EQU   HDRDS+2                                                  03453000
HDRDS2   EQU   HDRDS+1                                                  03454000
HDRDS17  EQU   HDRDS1                                                   03455000
HDRDS16  EQU   HDRDS1                                                   03456000
HDRDS15  EQU   HDRDS1                                                   03457000
HDRDS14  EQU   HDRDS1                                                   03458000
HDRDS11  EQU   HDRDS1                                                   03459000
HDRDS10  EQU   HDRDS1                                                   03460000
HDRISEC  EQU   HDRIS                                                    03461000
HDRISR   EQU   HDRIS                                                    03462000
HDRISMP  EQU   HDRIS                                                    03463000
HDRISTM  EQU   HDRIS                                                    03464000
HDRISNS  EQU   HDRIS                                                    03466000
HDRISMR  EQU   HDRIS                                                    03467000
HDRRELN  EQU   HDROPRN                                                  03468000
ESTARSVI EQU   ESTAFGRS+1                                               03901000
ESTABRNT EQU   ESTAFLG2                                                 03903000
ESTAEREC EQU   ESTAFLG2                                                 03905000
ESTATERM EQU   ESTAFLG2                                                 03906000
ESTAOWNR EQU   ESTA+8                                                   03908000
ESTAPARM EQU   ESTA+4                                                   03909000
ESTAEXIT EQU   ESTAEXT+1                                                03910000
ESTAHALT EQU   ESTAIO                                                   03911000
ESTANOIO EQU   ESTAIO                                                   03912000
ESTASYNC EQU   ESTAFLG1                                                 03913000
ESTAESTA EQU   ESTAFLG1                                                 03915000
ESTASTAR EQU   ESTAFLG1                                                 03917000
ESTASTAI EQU   ESTAFLG1                                                 03918000
*                                      END UNREFERENCED COMPONENTS      04160000
SKPRESET EQU   @RC00299                                                 04165000
@ENDDATA EQU   *                                                        04167000
         END   IEAVTRER                                         DSK1193 04168000
