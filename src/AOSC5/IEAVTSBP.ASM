         TITLE 'SCB RESOURCE MANAGER'                                   00001000
IEAVTSBP CSECT ,                                                   0001 00002000
@MAINENT DS    0H                                                  0001 00003000
         USING *,R15                                            DSK1149 00004000
         B     @PROLOG                                             0001 00005000
         DC    AL1(24)                                          DSK1149 00006000
         DC    C'IEAVTSBP 81141  UZ37541 '                      DSK1149 00007000
         DROP  R15                                              DSK1149 00008000
@PROLOG  STM   R14,R12,12(R13)                                  DSK1149 00009000
         BALR  R12,0                                            DSK1149 00010000
@PSTART  DS    0H                                                  0001 00011000
         USING @PSTART,R12                                      DSK1149 00012000
*                                      MANAGEMENT (ASM) SRB DRIVEN 0077 00020000
*                                      I/O ROUTINES WORK/SAVE AREA 0077 00021000
*                                      (512 BYTES) (MDC305)  @Z40WP9A*/ 00022000
*   IF TCBPTR^=0                    /* CHECK FOR TCB PTR IMPUT IN  0078 00023000
*                                      REG4                          */ 00024000
*     THEN                                                         0078 00025000
         LTR   R4,R4                                            DSK1149 00026000
         BZ    @RF00078                                            0078 00027000
*     DO;                                                          0079 00028000
*                                                                  0079 00029000
*       /*************************************************************/ 00030000
*       /*                                                           */ 00031000
*       /* THE SCB RESOURCE MANAGER INPUT POINTERS (IN R0 AND R1) ARE*/ 00032000
*       /* SAVED IN 'OLDRB'(R6) AND 'NEWRB'(R5) RESPECIFELY. SETFRR  */ 00033000
*       /* IS ISSUED TO PROVIDE A RECOVERY ENVIRONMENT. THE FRR      */ 00034000
*       /* PARAMETER LIST IS INITIALIZED WITH THE RETRY CODE, REQUEST*/ 00035000
*       /* BLOCK POINTERS (OR ZERO), THE TCB PTR AND REGISTER SAVE   */ 00036000
*       /* AREA POINTER . CHECK INPUT PARAMETERS AND SET INDICATORS  */ 00037000
*       /* ACCORDINGLY.                                              */ 00038000
*       /*                                                           */ 00039000
*       /*************************************************************/ 00040000
*                                                                  0080 00041000
*       RESPECIFY                                                  0080 00042000
*        (R0,                                                      0080 00043000
*         R1,                                                      0080 00044000
*         R13) RESTRICTED;                                         0080 00045000
*       OLDRB=R0;                   /* OLDRB WILL HOLD INPUT FROM R0    00046000
*                                      WHICH IS POSSIBLY THE OLD RB     00047000
*                                      PTR IF ENTRY WAS FOR XCTL OR     00048000
*                                      RB TYPE PURGE                 */ 00049000
         LR    R6,R0                                            DSK1149 00050000
*       NEWRB=R1;                   /* SAVE POSSIBLE NEW RB PTR      */ 00051000
         LR    R5,R1                                            DSK1149 00052000
*       RESPECIFY                                                  0083 00053000
*        (R0,                                                      0083 00054000
*         R1) UNRESTRICTED;                                        0083 00055000
*       RESPECIFY                                                  0084 00056000
*         R8 RESTRICTED;                                           0084 00057000
*       R8=ADDR(TRRMFRR);           /* ADDRESS OF FRR                */ 00058000
         LA    R8,TRRMFRR                                          0085 00059000
*       GEN REFS(PSACSTK,FRRSCURR,FRRSLAST,PSALSFCC,FRRSELEN,FRRSFRRA,  00060000
*           FRRSPARM,FRRSEMP,FRRSCURR)                             0086 00061000
*           (SETFRR  A,FRRAD=(8),PARMAD=(3),WRKREGS=(1,2),CLEAR=N);     00062000
         SETFRR  A,FRRAD=(8),PARMAD=(3),WRKREGS=(1,2),CLEAR=N           00063000
*       RESPECIFY                                                  0087 00064000
*         R8 UNRESTRICTED;                                         0087 00065000
*       RETRYIND='00'X;             /* ASSUME TCB PURGE      @Z40FPXA*/ 00066000
         MVI   RETRYIND(R3),X'00'                               DSK1149 00067000
*       VALIDLST='00'X;             /* LIST NOT FILLED IN YET      0089 00068000
*                                                            @Z40FPXA*/ 00069000
         MVI   VALIDLST(R3),X'00'                               DSK1149 00070000
*       IF OLDRB^=0 THEN                                           0090 00071000
         SLR   R11,R11                                          DSK1149 00072000
         CR    R6,R11                                           DSK1149 00073000
         BE    @RF00090                                            0090 00074000
*         DO;                                                      0091 00075000
*           IF NEWRB=0 THEN                                        0092 00076000
         CR    R5,R11                                           DSK1149 00077000
         BNE   @RF00092                                            0092 00078000
*             DO;                                                  0093 00079000
*               RETRYIND='10'X;                                    0094 00080000
         MVI   RETRYIND(R3),X'10'                               DSK1149 00081000
*             END;                                                 0095 00082000
*           ELSE                                                   0096 00083000
*             DO;                                                  0096 00084000
         B     @RC00092                                            0096 00085000
@RF00092 DS    0H                                                  0097 00086000
*               RETRYIND='20'X;                                    0097 00087000
         MVI   RETRYIND(R3),X'20'                               DSK1149 00088000
*             END;                                                 0098 00089000
*         END;                                                     0099 00090000
@RC00092 DS    0H                                                  0100 00091000
*       RBOLDPTR=OLDRB;             /* SAVE INPUT OLD RB PTR         */ 00092000
@RF00090 ST    R6,RBOLDPTR(,R3)                                 DSK1149 00093000
*       RBNEWPTR=NEWRB;             /* SAVE INPUT NEW RB PTR         */ 00094000
         ST    R5,RBNEWPTR(,R3)                                 DSK1149 00095000
*       PTRTCB=TCBPTR;              /* SAVE INPUT TCB PTR            */ 00096000
         ST    R4,PTRTCB(,R3)                                   DSK1149 00097000
*       SAVEPTR=R13;                /* SAVE REG SAVE AREA PTR        */ 00098000
         ST    R13,SAVEPTR(,R3)                                 DSK1149 00099000
*       VALIDLST='0F'X;             /* INDICATE PARM LIST IS       0104 00100000
*                                      INITIALIZED                   */ 00101000
         MVI   VALIDLST(R3),X'0F'                               DSK1149 00102000
*       RESPECIFY                                                  0105 00103000
*         R13 UNRESTRICTED;                                        0105 00104000
*       ENDSCB=0;                   /* CLEAR INDICATOR FOR END OF  0106 00105000
*                                      SCB'S                         */ 00106000
         SLR   R2,R2                                            DSK1149 00107000
*       RBSAVE=OLDRB;               /* SAVE RB PTR FOR TURNING OFF RB   00108000
*                                      OWNS SCB BIT IF NECESSARY     */ 00109000
*                                                                  0107 00110000
         LR    R9,R6                                            DSK1149 00111000
*       /*************************************************************/ 00112000
*       /*                                                           */ 00113000
*       /* MODIFY INPUT REGS TO HANDLE BOTH TYPES OF TCB PURGE (I.E. */ 00114000
*       /* EXIT ON LAST REQUEST BLOCK AND FAILURE ON ATTACH. CHECK   */ 00115000
*       /* FOR OWNERSHIP OF SRB'S --- HANDLE TRANSFER OF ELIGIBLE    */ 00116000
*       /* SRB'S IF XCTL TYPE ENTRY --- OTHERWISE HANDLE SCB PURGE   */ 00117000
*       /*                                                           */ 00118000
*       /*************************************************************/ 00119000
*                                                                  0108 00120000
*       IF OLDRB=0×(NEWRB=0&OLDRB->RBLINKB=TCBPTR)/*          @YM4975   00121000
*                                      IF ATTACH FAILURE OR LAST RB     00122000
*                                      EXIT                          */ 00123000
*         THEN                                                     0108 00124000
         SLR   R11,R11                                          DSK1149 00125000
         CR    R6,R11                                           DSK1149 00126000
         BE    @RT00108                                            0108 00127000
         CR    R5,R11                                           DSK1149 00128000
         BNE   @RF00108                                            0108 00129000
         L     R11,RBLINKB-RBBASIC-1(,R6)                       DSK1149 00130000
         LA    R11,0(,R11)                                      DSK1149 00131000
         CR    R4,R11                                           DSK1149 00132000
         BNE   @RF00108                                            0108 00133000
@RT00108 DS    0H                                                  0109 00134000
*         DO;                                                      0109 00135000
*           ENDSCB=1;               /* SET INCICATION OF TCB PURGE   */ 00136000
         LA    R2,1                                             DSK1149 00137000
*           RETRYIND='00'X;         /* INDICATE TCB PURGE FOR FRR    */ 00138000
         MVI   RETRYIND(R3),X'00'                               DSK1149 00139000
*           RESPECIFY                                              0112 00140000
*             FRRPRMPT UNRESTRICTED;                               0112 00141000
*                                                                  0112 00142000
*           /*********************************************************/ 00143000
*           /*                                                       */ 00144000
*           /* COMBINATION OF OLDRB AND NEWRB BOTH EQUAL ZERO WILL   */ 00145000
*           /* CAUSE TCB TYPE PURGE PATH TO BE TAKEN                 */ 00146000
*           /*                                                       */ 00147000
*           /*********************************************************/ 00148000
*                                                                  0113 00149000
*           OLDRB=0;                                               0113 00150000
         SLR   R6,R6                                            DSK1149 00151000
*           NEWRB=0;                                               0114 00152000
         SLR   R5,R5                                            DSK1149 00153000
*         END;                                                     0115 00154000
*       SCBPTR=TCBSTABB;            /* SET PTR TO BEGINNING OF CHAIN */ 00155000
@RF00108 L     R10,TCBSTABB-TCB-1(,R4)                          DSK1149 00156000
         LA    R10,0(,R10)                                      DSK1149 00157000
*       PREVSCB=SCBPTR;             /* SAVE FOR RE-CHAINING          */ 00158000
         LR    R3,R10                                           DSK1149 00159000
*       DO WHILE(SCBPTR^=0&(OLDRB=0×SCBOWNRA=OLDRB));/* PROCESS ONLY    00160000
*                                      IF THERE ARE SCB'S TO PROCESS */ 00161000
         B     @DE00118                                            0118 00162000
@DL00118 DS    0H                                                  0119 00163000
*         IF SCBXCTL2='1'B&NEWRB^=0 /* CHECK FOR XCTL TYPE ENTRY   0119 00164000
*                                      ELIGIBLE SCB'S FOR TRANSFER   */ 00165000
*           THEN                                                   0119 00166000
         TM    SCBFLGS2-SCB(R10),SCBXCTL2                       DSK1149 00167000
         BNO   @RF00119                                            0119 00168000
         SLR   R11,R11                                          DSK1149 00169000
         CR    R5,R11                                           DSK1149 00170000
         BE    @RF00119                                            0119 00171000
*           DO;                                                    0120 00172000
*             PREVSCB=SCBPTR;       /* SAVE PTR FOR RECHAINING       */ 00173000
         LR    R3,R10                                           DSK1149 00174000
*             SCBOWNRA=NEWRB;       /* TRANSFER OWNERSHIP            */ 00175000
         STCM  R5,7,SCBOWNRA-SCB(R10)                           DSK1149 00176000
*             EVAL(OLDRB-LENGTH(RBPREFIX))->RBSCB='0'B;/* TURN OFF RB   00177000
*                                      OWNS SCB FLAG IN OLD RB       */ 00178000
         LA    R8,64                                            DSK1149 00179000
         LR    R7,R6                                            DSK1149 00180000
         SLR   R7,R8                                            DSK1149 00181000
         NI    RBFLAGS1-RBPREFIX(R7),255-RBSCB                  DSK1149 00182000
*             SCBPTR=SCBCHAIN;      /* UPDATE SCB CHAIN POINTER      */ 00183000
         L     R10,SCBCHAIN-SCB(,R10)                           DSK1149 00184000
*             EVAL(NEWRB-LENGTH(RBPREFIX))->RBSCB='1'B;/* INDICATE 0125 00185000
*                                      NEWRB NOW OWNS THE TRANSFERRED   00186000
*                                      SCB                           */ 00187000
         LCR   R8,R8                                            DSK1149 00188000
         ALR   R8,R5                                            DSK1149 00189000
         OI    RBFLAGS1-RBPREFIX(R8),RBSCB                      DSK1149 00190000
*             IF OLDRB=NEWRB&OLDRB^=0/* CHECK FOR SVRB ISSUING XCTL  */ 00191000
*               THEN                                               0126 00192000
         CR    R6,R5                                            DSK1149 00193000
         BNE   @RC00119                                         DSK1149 00194000
         CR    R6,R11                                           DSK1149 00195000
         BE    @RC00119                                         DSK1149 00196000
*               DO;                                                0127 00197000
*                 RBSAVE=0;         /* TO PREVENT TURNING OFF RBSCB     00198000
*                                      IN SVRB WHICH IS BEING RE-USED   00199000
*                                      BY XCTL                       */ 00200000
         SLR   R9,R9                                            DSK1149 00201000
*               END;                                               0129 00202000
*           END;                                                   0130 00203000
*         ELSE                      /* NOT AN XCTL TYPE ENTRY        */ 00204000
*           DO;                                                    0131 00205000
         B     @RC00119                                            0131 00206000
@RF00119 DS    0H                                                  0132 00207000
*             IF SCBPTR=TCBSTABB    /* IS THIS THE TOP SCB ?         */ 00208000
*               THEN                                               0132 00209000
         L     R11,TCBSTABB-TCB-1(,R4)                          DSK1149 00210000
         LA    R11,0(,R11)                                      DSK1149 00211000
         CR    R10,R11                                          DSK1149 00212000
         BNE   @RF00132                                            0132 00213000
*               DO;                                                0133 00214000
*                 TCBSTABB=SCBCHAIN;/* CHANGE SCB CHAIN PTR IN TCB TO   00215000
*                                      EFFECTIVELY DELETE TOP SCB  0134 00216000
*                                      FROM CHAIN                    */ 00217000
         MVC   TCBSTABB-TCB(3,R4),SCBCHAIN+1-SCB(R10)           DSK1149 00218000
*               END;                                               0135 00219000
*             ELSE                  /* NOT TOP SCB ON QUEUE          */ 00220000
*               DO;                                                0136 00221000
         B     @RC00132                                            0136 00222000
@RF00132 DS    0H                                                  0137 00223000
*                 PREVSCB->SCBCHAIN=SCBCHAIN;/* TO DELETE THIS SCB 0137 00224000
*                                      (WHICH IS NOT THE TOP)      0137 00225000
*                                      RE-CHAIN FROM PREVIOUS SCB TO    00226000
*                                      NEXT.                         */ 00227000
         L     R11,SCBCHAIN-SCB(,R10)                           DSK1149 00228000
         ST    R11,SCBCHAIN-SCB(,R3)                            DSK1149 00229000
*               END;                                               0138 00230000
*             DO;                                                  0139 00231000
*                                                                  0139 00232000
@RC00132 DS    0H                                                  0140 00233000
*               /*****************************************************/ 00234000
*               /*                                                   */ 00235000
*               /* IF THE SCB WAS ACQUIRED VIA BRANCH ENTRY TO SVC   */ 00236000
*               /* 60, THEN THE SCB CORE WAS ACQUIRED ALONG WITH THE */ 00237000
*               /* RB IN THE SAME GETMAIN REQUEST. IN THIS CASE THE  */ 00238000
*               /* SCB WILL BE ZEROED BUT NOT FREED. IF THE SCB WAS  */ 00239000
*               /* CREATED BY THE NORMAL SVC ENTRY TO SVC 60 THEN THE*/ 00240000
*               /* CORE WILL BE FREED                                */ 00241000
*               /*                                                   */ 00242000
*               /*****************************************************/ 00243000
*                                                                  0140 00244000
*               RESPECIFY                                          0140 00245000
*                (R7,                                              0140 00246000
*                 R0,                                              0140 00247000
*                 R8) RESTRICTED;   /*                       @ZA11838*/ 00248000
*               IF SCBBRNTR='1'B    /* CHECK FOR BRANCH ENTRY SCB    */ 00249000
*                 THEN                                             0141 00250000
         TM    SCBFLGS3-SCB(R10),SCBBRNTR                       DSK1149 00251000
         BNO   @RF00141                                            0141 00252000
*                 DO;                                              0142 00253000
*                   R7=SCBPTR;      /* SAVE SCB PTR                  */ 00254000
         LR    R7,R10                                           DSK1149 00255000
*                   SCBPTR=SCBCHAIN;/* UPDATE SCB PTR REGISTER TO  0144 00256000
*                                      POINT TO NEXT SCB             */ 00257000
         L     R10,SCBCHAIN-SCB(,R10)                           DSK1149 00258000
*/* THE SCB MAY BE USED AGAIN, LEAVE THE RB OWNR AND ID FLDS @Z40FPXH*/ 00259000
*                                                                  0145 00260000
*                   R7->SCB(1:13)=''B;/* CLEAR THE SCB       @Z40FPXH*/ 00261000
         XC    SCB-SCB(13,R7),SCB-SCB(R7)                       DSK1149 00262000
*                 END;                                             0146 00263000
*               ELSE                /* SCB CREATED BY SVC ENTRY      */ 00264000
*                                                                  0147 00265000
*                 /***************************************************/ 00266000
*                 /*                                                 */ 00267000
*                 /* SCB WAS OBTAINED IN GETMAINED STORAGE. PLACE    */ 00268000
*                 /* SCB'S ON FREE SCB QUE                           */ 00269000
*                 /*                                                 */ 00270000
*                 /***************************************************/ 00271000
*                                                                  0147 00272000
*                 DO;               /*                       @Z30EPXH*/ 00273000
         B     @RC00141                                            0147 00274000
@RF00141 DS    0H                                                  0148 00275000
*                   R7=WSALSTAE;    /* ADDRESS OF SVC60 WORK/SAVE  0148 00276000
*                                      AREA                  @Z30EPXH*/ 00277000
         L     R11,PSAAOLD-PSA                                  DSK1149 00278000
         L     R1,ASCBASXB-ASCB(,R11)                           DSK1149 00279000
         L     R1,ASXBSPSA-ASXB(,R1)                            DSK1149 00280000
         L     R7,WSALSTAE(,R1)                                 DSK1149 00281000
*                   R0=SCBCHAIN;    /* NEXT SCB POINTER      @Z30EPXH*/ 00282000
         L     R0,SCBCHAIN-SCB(,R10)                            DSK1149 00283000
*ADDCELL:                                                          0150 00284000
*                   R8=FREESCBQ;    /* TOP OF FREE CELL QUEUE      0150 00285000
*                                                            @Z40FPXA*/ 00286000
ADDCELL  L     R8,FREESCBQ(,R7)                                    0150 00287000
*                   SCBCHAIN=R8;    /* MAINTAIN CELL CHAIN   @Z40FPXA*/ 00288000
         ST    R8,SCBCHAIN-SCB(,R10)                            DSK1149 00289000
*                   RFY                                            0152 00290000
*                     R11 RSTD;     /*                       @ZA11838*/ 00291000
*                   R11=SCBPTR;     /* SAVE SCB ADDRESS      @Z40FPXA   00292000
*                                                            @ZA11838*/ 00293000
         LR    R11,R10                                          DSK1149 00294000
*                   CS(R8,R11,FREESCBQ);/* ADD CELL TO CHAIN @Z40FPXA   00295000
*                                                            @ZA11838*/ 00296000
         CS    R8,R11,FREESCBQ(R7)                              DSK1149 00297000
*                   BC(7,ADDCELL);  /* RETRY IF ADD FAILED   @Z40FPXA*/ 00298000
         BC    7,ADDCELL                                           0155 00299000
*                   RFY                                            0156 00300000
*                     R11 UNRSTD;   /*                       @ZA11838*/ 00301000
*                   SCBPTR=R0;      /* RESTORE SCB POINTER   @Z30EPXH*/ 00302000
         LR    R10,R0                                           DSK1149 00303000
*                 END;              /*                       @Z30EPXH*/ 00304000
*               RESPECIFY                                          0159 00305000
*                (R7,                                              0159 00306000
*                 R0,                                              0159 00307000
*                 R8) UNRESTRICTED; /*                       @ZA11838*/ 00308000
@RC00141 DS    0H                                                  0160 00309000
*             END;                                                 0160 00310000
*           END;                                                   0161 00311000
*       END;                                                       0162 00312000
@RC00119 DS    0H                                                  0162 00313000
@DE00118 SLR   R11,R11                                          DSK1149 00314000
         CR    R10,R11                                          DSK1149 00315000
         BE    @DC00118                                            0162 00316000
         CR    R6,R11                                           DSK1149 00317000
         BE    @DL00118                                            0162 00318000
         L     R11,SCBOWNRA-1-SCB(,R10)                         DSK1149 00319000
         LA    R11,0(,R11)                                      DSK1149 00320000
         CR    R6,R11                                           DSK1149 00321000
         BE    @DL00118                                            0162 00322000
@DC00118 DS    0H                                                  0163 00323000
*       IF RBSAVE^=0                /* RB INDICATE 'OWN AN SCB' ?    */ 00324000
*         THEN                      /* YES                           */ 00325000
         LTR   R9,R9                                            DSK1149 00326000
         BZ    @RF00163                                            0163 00327000
*         DO;                                                      0164 00328000
*           EVAL(RBSAVE-LENGTH(RBPREFIX))->RBSCB='0'B;/* SHOW RB HAS    00329000
*                                      NO SCB                        */ 00330000
         LR    R11,R9                                           DSK1149 00331000
         SL    R11,@CF00097                                     DSK1149 00332000
         NI    RBFLAGS1-RBPREFIX(R11),255-RBSCB                 DSK1149 00333000
*         END;                                                     0166 00334000
*       IF ENDSCB^=0                /* TCB TYPE PURGE                */ 00335000
*         THEN                      /* YES                           */ 00336000
@RF00163 SLR   R11,R11                                          DSK1149 00337000
         CR    R2,R11                                           DSK1149 00338000
         BE    @RF00167                                            0167 00339000
*         DO;                                                      0168 00340000
*           TCBSTABB=0;             /* SHOW TCB HAS NO SCB'S         */ 00341000
         STCM  R11,7,TCBSTABB-TCB(R4)                           DSK1149 00342000
*         END;                                                     0170 00343000
*       GEN SETS(R9,R3);                                           0171 00344000
@RF00167 DS    0H                                                  0171 00345000
     SETFRR D,WRKREGS=(9,3)       DELETE THIS FRR FORM STACK            00346000
*       RESPECIFY                                                  0172 00347000
*         RCODE RESTRICTED;                                        0172 00348000
*       RCODE=0;                    /* SET GOOD RETURN CODE          */ 00349000
         SLR   R15,R15                                          DSK1149 00350000
*     END;                                                         0174 00351000
*   ELSE                                                           0175 00352000
*     DO;                                                          0175 00353000
         B     @RC00078                                            0175 00354000
@RF00078 DS    0H                                                  0176 00355000
*       RESPECIFY                                                  0176 00356000
*         RCODE RESTRICTED;                                        0176 00357000
*       RCODE=4;                    /* SET FAILURE CODE -- BAD INPUT */ 00358000
         LA    R15,4                                            DSK1149 00359000
*     END;                                                         0178 00360000
*   RETURN CODE(RCODE);                                            0179 00361000
@RC00078 L     R14,12(,R13)                                     DSK1149 00362000
         LM    R0,R12,20(R13)                                   DSK1149 00363000
         BR    R14                                              DSK1149 00364000
*   RESPECIFY                                                      0180 00365000
*     RCODE UNRESTRICTED;                                          0180 00366000
*                                                                  0180 00367000
*   /*****************************************************************/ 00368000
*   /*                                                               */ 00369000
*   /* IF THE SDWAFMID IS NON ZERO, A MEMORY SWITCH HAS OCCURRED AND */ 00370000
*   /* NO PROCESSING WILL BE ATTEMPTED. OTHERWISE, THE SCB CHAIN IS  */ 00371000
*   /* TERMINATED AT THE TCB IF A LAST RB EXIT OR TCB TYPE (SCB)     */ 00372000
*   /* PURGE HAS BEEN REQUESTED OR COMPLETION CODE IS SYSTEM '0C4'.  */ 00373000
*   /* THE '0C4' INDICATES A PAGE OR SEGMENT EXCEPTION FROM          */ 00374000
*   /* REFERENCING THE SCB QUEUE, THEREFORE THE QUEUE IS ZEROED.     */ 00375000
*   /* (PROGRAM MANAGEMENT AND EXIT REFERENCE TCB AND RB ADDRESSES   */ 00376000
*   /* BEFORE GIVING CONTROL TO THIS FUNCTION--AND ---- IF THE       */ 00377000
*   /* PROBLEM WAS A BED KEY, THE RECOVERY WOULD NOT HAVE BEEN ABLE  */ 00378000
*   /* TO SET UP--- THEREFORE, ANY '0C4' IS ASSUMED TO BE A BAD SCB  */ 00379000
*   /* ADDRESS. TO PREVENT THE FRR FROM FAILING FROM THE SAME ERROR, */ 00380000
*   /* THE SCB QUEUE IS TERMINATED.) IF STORAGE ERRORS HAVE          */ 00381000
*   /* OCCURRED,THE SCB QUEUE IS TERMINATED IF ANY SCB IS LOCATED    */ 00382000
*   /* WITHIN THE RANGE OF ERROR. IF NO STORAGE ERRORS HAVE OCCURED  */ 00383000
*   /* AND THE RETRY CODE IS '10'X, SCBS OWNED BY THE OLDRB ARE      */ 00384000
*   /* DELETED FROM THE SCB CHAIN. IF THE RETRY CODE IS '20'X, SCBS  */ 00385000
*   /* OWNED BY BOTH NEW AND OLD RB'S ARE DELETED. REGISTERS 0-14 ARE*/ 00386000
*   /* RESTORED IN THE SDWA FROM THE SAVE AREA OF THE CALLER & THE   */ 00387000
*   /* FRR IS DELETED FROM THE STACK BEFORE GOING TO RETRY           */ 00388000
*   /* PROCESSING. RETRY SETS REG 15 TO '04'X AND BRANCHES ON REG 14.*/ 00389000
*   /*                                                               */ 00390000
*   /*****************************************************************/ 00391000
*                                                                  0181 00392000
*TRRMFRR:                                                          0181 00393000
*   GEN;                                                           0181 00394000
TRRMFRR  DS    0H                                                  0181 00395000
         BALR  R7,0                                             DSK1149 00396000
         USING *,R7                                             DSK1149 00397000
*   RESPECIFY                                                      0182 00398000
*    (ENDSCB,                                                      0182 00399000
*     PREVSCB,                                                     0182 00400000
*     FRRPRMPT,                                                    0182 00401000
*     RBSAVE) UNRESTRICTED;                                        0182 00402000
*   RESPECIFY                                                      0183 00403000
*    (SDWAPTR,                                                     0183 00404000
*     R13,                                                         0183 00405000
*     R14) RESTRICTED;                                             0183 00406000
*   RESPECIFY                                                      0184 00407000
*     FRRPARM BASED(SDWAPARM);      /* BASE FRR PARM LIST ON PTR IN     00408000
*                                      THE SDWA                      */ 00409000
*   SDWAMODN='IEAVTSBP';            /* MODULE INVOLVED IN ERROR      */ 00410000
         MVC   SDWAMODN-SDWA(8,R1),@CC02642                     DSK1149 00411000
*   SDWACSCT='IEAVTSBP';            /* CSECT INVOLVED IN ERROR       */ 00412000
         MVC   SDWACSCT-SDWA(8,R1),@CC02642                     DSK1149 00413000
*   SDWAREXN='IEAVTSBP';            /* NAME OF RECOVERY ROUTINE      */ 00414000
         MVC   SDWAREXN-SDWA(8,R1),@CC02642                     DSK1149 00415000
*   IF SDWAFMID^=0×VALIDLST^='0F'X  /* CHECK FOR MEMORY SWITCH OR  0188 00416000
*                                      INCOMPLETE FRR PARM LIST      */ 00417000
*     THEN                          /* GET OUT - NOTHING CAN BE DONE */ 00418000
         LH    R15,SDWAFMID-SDWA(,R1)                           DSK1149 00419000
         N     R15,@CF02674                                     DSK1149 00420000
         LTR   R15,R15                                          DSK1149 00421000
         BNZ   @RT00188                                            0188 00422000
         L     R15,SDWAPARM-SDWA(,R1)                           DSK1149 00423000
         CLI   VALIDLST(R15),X'0F'                              DSK1149 00424000
         BE    @RF00188                                            0188 00425000
@RT00188 DS    0H                                                  0189 00426000
*     DO;                                                          0189 00427000
*       DO;                         /* SETRP RC(0)                   */ 00428000
*         RESPECIFY                                                0191 00429000
*          (GPR00P,                                                0191 00430000
*           GPR01P,                                                0191 00431000
*           GPR14P,                                                0191 00432000
*           GPR15P) RSTD;                                          0191 00433000
*         GPR01P->SDWARCDE=0;       /* SAVE RC VALUE                 */ 00434000
         MVI   SDWARCDE-SDWA(R1),X'00'                          DSK1149 00435000
*         RESPECIFY                                                0193 00436000
*          (GPR00P,                                                0193 00437000
*           GPR01P,                                                0193 00438000
*           GPR14P,                                                0193 00439000
*           GPR15P) UNRSTD;                                        0193 00440000
*       END;                        /* SET INDICATOR TO TASK RECOVERY   00441000
*                                      TO PERCOLATE                  */ 00442000
*       GOTO R14->OUT;              /* NO PROCESSING CAN BE DONE     */ 00443000
         BR    R14                                                 0195 00444000
*     END;                                                         0196 00445000
*   TCBPTR=PTRTCB;                                                 0197 00446000
@RF00188 L     R15,SDWAPARM-SDWA(,R1)                           DSK1149 00447000
         L     R4,PTRTCB(,R15)                                  DSK1149 00448000
*   SCBPTR=TCBSTABB;                /* INITIALIZE SCB QUEUE PTR      */ 00449000
         L     R10,TCBSTABB-TCB-1(,R4)                          DSK1149 00450000
         LA    R10,0(,R10)                                      DSK1149 00451000
*   IF RETRYIND='00'X×              /* TCB PURGE REQUESTED ? OR      */ 00452000
*       SDWACMPC='0C4000'X          /* PAGE OR SEGMENT EXCEPTION ? 0199 00453000
*                                                            @YM04280*/ 00454000
*     THEN                          /* YES                           */ 00455000
         CLI   RETRYIND(R15),X'00'                              DSK1149 00456000
         BE    @RT00199                                            0199 00457000
         CLC   SDWACMPC-SDWA(3,R1),@CB02647                     DSK1149 00458000
         BNE   @RF00199                                            0199 00459000
@RT00199 DS    0H                                                  0200 00460000
*     DO;                                                          0200 00461000
*       TCBSTABB=0;                 /* TERMINATE SCB QUEUE PTR IN TCB*/ 00462000
         SLR   R15,R15                                          DSK1149 00463000
         STCM  R15,7,TCBSTABB-TCB(R4)                           DSK1149 00464000
*     END;                                                         0202 00465000
*   ELSE                            /* ANY STORAGE CHECKS ?          */ 00466000
*     DO;                                                          0203 00467000
         B     @RC00199                                            0203 00468000
@RF00199 DS    0H                                                  0204 00469000
*       IF SDWASKYF^='0'B×SDWASCK^='0'B/* STOR. KEY OR DATA FAILURE ?*/ 00470000
*         THEN                      /* YES                           */ 00471000
         TM    SDWAMCHD-SDWA(R1),SDWASKYF+SDWASCK               DSK1149 00472000
         BZ    @RF00204                                            0204 00473000
*         DO;                                                      0205 00474000
*           IF SDWASRVL='1'B        /* VALID ADDRESSES OF STORAGE  0206 00475000
*                                      ERROR AVAILIBLE ?             */ 00476000
*             THEN                  /* YES                           */ 00477000
         TM    SDWAMCHS-SDWA(R1),SDWASRVL                       DSK1149 00478000
         BNO   @RF00206                                            0206 00479000
*             DO;                                                  0207 00480000
*               DO WHILE(SCBPTR^=0);/* CHECK ALL SCB'S ON QUEUE      */ 00481000
*                                                                  0208 00482000
         B     @DE00208                                            0208 00483000
@DL00208 DS    0H                                                  0209 00484000
*                 /***************************************************/ 00485000
*                 /*                                                 */ 00486000
*                 /* SEE IF ANY SCB'S ARE WITHIN THE RANGE OF STORAGE*/ 00487000
*                 /* ERROR                                           */ 00488000
*                 /*                                                 */ 00489000
*                 /***************************************************/ 00490000
*                                                                  0209 00491000
*                 IF(SCBPTR>=SDWASCKB&SCBPTR<=SDWASCKE)×(SCBPTR+(LENGTH 00492000
*                     (SCB)-1)>=SDWASCKB&SCBPTR+(LENGTH(SCB)-1)<=  0209 00493000
*                     SDWASCKE) THEN/* YES                           */ 00494000
         C     R10,SDWASCKB-SDWA(,R1)                           DSK1149 00495000
         BL    @GL00009                                            0209 00496000
         C     R10,SDWASCKE-SDWA(,R1)                           DSK1149 00497000
         BNH   @RT00209                                            0209 00498000
@GL00009 LA    R15,19                                           DSK1149 00499000
         ALR   R15,R10                                          DSK1149 00500000
         C     R15,SDWASCKB-SDWA(,R1)                           DSK1149 00501000
         BL    @RF00209                                            0209 00502000
         C     R15,SDWASCKE-SDWA(,R1)                           DSK1149 00503000
         BH    @RF00209                                            0209 00504000
@RT00209 DS    0H                                                  0210 00505000
*                   DO;                                            0210 00506000
*                     TCBSTABB=0;   /* TERMINATE SCB QUEUE BY ZEROING   00507000
*                                      PTR IN TCB                    */ 00508000
         SLR   R15,R15                                          DSK1149 00509000
         STCM  R15,7,TCBSTABB-TCB(R4)                           DSK1149 00510000
*                     SCBPTR=0;     /* ZERO BASE PTR FOR SCB         */ 00511000
         SLR   R10,R10                                          DSK1149 00512000
*                   END;                                           0213 00513000
*                 ELSE                                             0214 00514000
*                   DO;                                            0214 00515000
         B     @RC00209                                            0214 00516000
@RF00209 DS    0H                                                  0215 00517000
*                     SCBPTR=SCBCHAIN;                             0215 00518000
         L     R10,SCBCHAIN-SCB(,R10)                           DSK1149 00519000
*                   END;                                           0216 00520000
*               END;                                               0217 00521000
@RC00209 DS    0H                                                  0217 00522000
@DE00208 LTR   R10,R10                                          DSK1149 00523000
         BNZ   @DL00208                                            0217 00524000
*             END;                                                 0218 00525000
*           ELSE                    /* ENCOUNTERED STORAGE CHECK BUT    00526000
*                                      NO VALID ADDRESS OF ERROR   0219 00527000
*                                      AVAILIBLE                     */ 00528000
*             DO;                                                  0219 00529000
         B     @RC00206                                            0219 00530000
@RF00206 DS    0H                                                  0220 00531000
*               TCBSTABB=0;         /* TERMINATE SCB QUEUE BY ZEROING   00532000
*                                      QUEUE PTR IN TCB              */ 00533000
         SLR   R15,R15                                          DSK1149 00534000
         STCM  R15,7,TCBSTABB-TCB(R4)                           DSK1149 00535000
*             END;                                                 0221 00536000
*         END;                                                     0222 00537000
@RC00206 DS    0H                                                  0223 00538000
*     END;                                                         0223 00539000
*                                                                  0223 00540000
@RF00204 DS    0H                                                  0224 00541000
*   /*****************************************************************/ 00542000
*   /*                                                               */ 00543000
*   /* PROCESS FOR THE REMAINING TYPE ENTRY CONDITIONS (RB OR XCTL   */ 00544000
*   /* TYPE)                                                         */ 00545000
*   /*                                                               */ 00546000
*   /*****************************************************************/ 00547000
*                                                                  0224 00548000
*   SCBPTR=TCBSTABB;                /* REINITIALIZE SCBPTR TO      0224 00549000
*                                      BEGINNING OF SCB QUEUE        */ 00550000
@RC00199 L     R10,TCBSTABB-TCB-1(,R4)                          DSK1149 00551000
         LA    R10,0(,R10)                                      DSK1149 00552000
*   IF SCBPTR^=0                    /* ANY SCB'S ?                   */ 00553000
*     THEN                                                         0225 00554000
         LTR   R10,R10                                          DSK1149 00555000
         BZ    @RF00225                                            0225 00556000
*     DO;                                                          0226 00557000
*       OLDRB=RBOLDPTR;             /* RETRIEVE POSSIBLE PTR TO OLDRB*/ 00558000
         L     R15,SDWAPARM-SDWA(,R1)                           DSK1149 00559000
         L     R6,RBOLDPTR(,R15)                                DSK1149 00560000
*       NEWRB=RBNEWPTR;             /* RETRIEVE POSSIBLE PTR TO NEWRB*/ 00561000
         L     R5,RBNEWPTR(,R15)                                DSK1149 00562000
*       IF RETRYIND='10'X           /* RB TYPE PURGE                 */ 00563000
*         THEN                                                     0229 00564000
         CLI   RETRYIND(R15),X'10'                              DSK1149 00565000
         BNE   @RF00229                                            0229 00566000
*         DO WHILE(SCBPTR^=0&SCBOWNRA=OLDRB);                      0230 00567000
         B     @DE00230                                            0230 00568000
@DL00230 DS    0H                                                  0231 00569000
*           TCBSTABB=SCBCHAIN;      /* DELETE THIS SCB FROM CHAIN    */ 00570000
         L     R15,SCBCHAIN-SCB(,R10)                           DSK1149 00571000
         STCM  R15,7,TCBSTABB-TCB(R4)                           DSK1149 00572000
*           SCBPTR=SCBCHAIN;        /* POINT TO NEXT SCB             */ 00573000
         LR    R10,R15                                          DSK1149 00574000
*         END;                                                     0233 00575000
@DE00230 LTR   R10,R10                                          DSK1149 00576000
         BZ    @DC00230                                            0233 00577000
         L     R15,SCBOWNRA-1-SCB(,R10)                         DSK1149 00578000
         LA    R15,0(,R15)                                      DSK1149 00579000
         CR    R6,R15                                           DSK1149 00580000
         BE    @DL00230                                            0233 00581000
@DC00230 DS    0H                                                  0234 00582000
*       ELSE                                                       0234 00583000
*         DO WHILE(SCBPTR^=0&(SCBOWNRA=OLDRB×SCBOWNRA=NEWRB));     0234 00584000
         B     @RC00229                                            0234 00585000
@RF00229 B     @DE00234                                            0234 00586000
@DL00234 DS    0H                                                  0235 00587000
*           TCBSTABB=SCBCHAIN;      /* DELETE THIS SCB FROM CHAIN    */ 00588000
         L     R15,SCBCHAIN-SCB(,R10)                           DSK1149 00589000
         STCM  R15,7,TCBSTABB-TCB(R4)                           DSK1149 00590000
*           SCBPTR=SCBCHAIN;        /* POINT TO NEXT SCB             */ 00591000
         LR    R10,R15                                          DSK1149 00592000
*         END;                                                     0237 00593000
@DE00234 LTR   R10,R10                                          DSK1149 00594000
         BZ    @DC00234                                            0237 00595000
         L     R15,SCBOWNRA-1-SCB(,R10)                         DSK1149 00596000
         LA    R15,0(,R15)                                      DSK1149 00597000
         CR    R15,R6                                           DSK1149 00598000
         BE    @DL00234                                            0237 00599000
         CR    R15,R5                                           DSK1149 00600000
         BE    @DL00234                                            0237 00601000
@DC00234 DS    0H                                                  0238 00602000
*     END;                                                         0238 00603000
*                                                                  0238 00604000
@RC00229 DS    0H                                                  0239 00605000
*   /*****************************************************************/ 00606000
*   /*                                                               */ 00607000
*   /* RESTORE REGISTERS IN SDWA FROM SAVE AREA                      */ 00608000
*   /*                                                               */ 00609000
*   /*****************************************************************/ 00610000
*                                                                  0239 00611000
*   RESPECIFY                                                      0239 00612000
*     R13 RESTRICTED;                                              0239 00613000
@RF00225 DS    0H                                                  0240 00614000
*   R13=SAVEPTR;                    /* RETREIVE SAVE AREA PTR        */ 00615000
         L     R15,SDWAPARM-SDWA(,R1)                           DSK1149 00616000
         L     R13,SAVEPTR(,R15)                                DSK1149 00617000
*   RESPECIFY                                                      0241 00618000
*     R9 RESTRICTED;                                               0241 00619000
*   R9=ADDR(SDWASRSV);              /* POINT TO SAVE AREA IN SDWA    */ 00620000
         LA    R9,SDWASRSV-SDWA(,R1)                            DSK1149 00621000
*   GEN REFS(R9,R13,R3);                                           0243 00622000
         MVC   56(4,R9),12(R13)          /*  RESTORE R14        DSK1149 00623000
         ST    R13,52(R9)                /*  RESTORE R13        DSK1149 00624000
  MVC    0(52,R9),20(R13)          /*  RESTORE R0-R12                */ 00625000
     SETFRR D,WRKREGS=(9,3)                                             00626000
*   DO;                             /* SETRP RETADDR(TRMRETRY)RETREGS   00627000
*                                      (YES)RC(4)                    */ 00628000
*     RESPECIFY                                                    0245 00629000
*      (GPR00P,                                                    0245 00630000
*       GPR01P,                                                    0245 00631000
*       GPR14P,                                                    0245 00632000
*       GPR15P) RSTD;                                              0245 00633000
*     GPR01P->SDWARCDE=4;           /* STORE RC INTO SDWA            */ 00634000
         MVI   SDWARCDE-SDWA(R1),X'04'                          DSK1149 00635000
*     GPR01P->SDWARTYA=ADDR(TRMRETRY);/* SAVE RETRY ADDRESS          */ 00636000
         LA    R11,TRMRETRY                                     DSK1149 00637000
         ST    R11,SDWARTYA-SDWA(,R1)                           DSK1149 00638000
*     GPR01P->SDWAUPRG='1'B;        /* TURN ON RETREGS INDICATOR     */ 00639000
         OI    SDWAACF2-SDWA(R1),SDWAUPRG                       DSK1149 00640000
*     RESPECIFY                                                    0249 00641000
*      (GPR00P,                                                    0249 00642000
*       GPR01P,                                                    0249 00643000
*       GPR14P,                                                    0249 00644000
*       GPR15P) UNRSTD;                                            0249 00645000
*   END;                            /* GO RETRY                      */ 00646000
*   GOTO R14->OUT;                                                 0251 00647000
         BR    R14                                                 0251 00648000
*TRMRETRY:                                                         0252 00649000
*   RESPECIFY                                                      0252 00650000
*     RCODE RESTRICTED;                                            0252 00651000
TRMRETRY DS    0H                                                  0253 00652000
*   RCODE=4;                        /* INDICATE FAILURE              */ 00653000
         LA    R15,4                                            DSK1149 00654000
*   GOTO R14->OUT;                  /* RETURN TO CALLER              */ 00655000
         BR    R14                                                 0254 00656000
*   RESPECIFY                                                      0255 00657000
*     RCODE UNRESTRICTED;                                          0255 00658000
*ESTAEFRR:                                                         0256 00659000
*   GEN(BALR  8,0);                 /* ESTABLISH ADDRESSABILITY    0256 00660000
*                                                            @Z40FPXA*/ 00661000
ESTAEFRR BALR  R8,0                                             DSK1149 00662000
*   GEN(USING *,8);                 /* BASE REGISTER                 */ 00663000
         USING *,R8                                             DSK1149 00664000
*   RFY                                                            0258 00665000
*    (R8,                                                          0258 00666000
*     R9,                                                          0258 00667000
*     R14) RSTD;                                                   0258 00668000
*                                                                  0258 00669000
*   /*****************************************************************/ 00670000
*   /*                                                               */ 00671000
*   /* THIS IS RECOVERY ROUTINE FOR ESTAE PROCESSOR, SCAN SCB QUEUE, */ 00672000
*   /* AND FREESCB QUEUE AND TRUNCATE IF ANY ERRORS ARE FOUND IN     */ 00673000
*   /* QUEUE                                                         */ 00674000
*   /*                                                               */ 00675000
*   /*****************************************************************/ 00676000
*                                                                  0259 00677000
*   SDWACSCT='IEAVTSBP';            /* CSECT NAME            @Z40FPXA*/ 00678000
         MVC   SDWACSCT-SDWA(8,R1),@CC02642                     DSK1149 00679000
*   SDWAREXN='ESTAEFRR';            /* RECOVERY NAME         @Z40FPXA*/ 00680000
         MVC   SDWAREXN-SDWA(8,R1),@CC02652                     DSK1149 00681000
*   SDWAMODN='IGC00060';            /* MODULE NAME           @Z40FPXA*/ 00682000
*                                                                  0261 00683000
         MVC   SDWAMODN-SDWA(8,R1),@CC02653                     DSK1149 00684000
*   /*****************************************************************/ 00685000
*   /*                                                               */ 00686000
*   /* RESET SUPER BITS, AND ESTAE IN PROGRESS INDICATORS    @Z40FPXA*/ 00687000
*   /*                                                               */ 00688000
*   /*****************************************************************/ 00689000
*                                                                  0262 00690000
*   PSAESTA='0'B;                   /* RESET SUPER BIT       @Z40FPXA*/ 00691000
         NI    PSASUP3-PSA,255-PSAESTA                          DSK1149 00692000
*   TCBPTR=PSATOLD;                 /* PICK UP TCB POINTER           */ 00693000
         L     R4,PSATOLD-PSA                                   DSK1149 00694000
         ST    R4,SDWASRSV-SDWA+4*4(,R1)                        DSK1149 00695000
*                                                            @Z40FPXA*/ 00696000
         L     R9,TCBSTAWA-TCB(,R4)                             DSK1149 00697000
*   IF TCBSTAFX='1'B THEN           /* ALLOW FOR             @ZA24347*/ 00698000
*     DO;                           /* ASYNCRONOUS           @ZA24347*/ 00701000
*       TCBFX='0'B;                 /* INTERRUPTS.           @ZA24347*/ 00702000
*       TCBSTAFX='0'B;              /*                       @ZA24347*/ 00704000
*     END;                          /*                       @ZA24347*/ 00706000
*   ELSE                                                           0270 00707000
*     ;                             /*                       @ZA24347*/ 00708000
@RF00265 DS    0H                                                  0271 00709000
*   TCBSTAWA=0;                     /* CLEAR FLAG            @Z40FPXA*/ 00710000
*   SDWAGR09=R9;                    /* WORK REG FOR RETRY    @Z40FPXA*/ 00713000
         ST    R9,SDWASRSV-SDWA+9*4(,R1)                        DSK1149 00714010
         SLR   R15,R15                                          DSK1149 00714020
         ST    R15,TCBSTAWA-TCB(,R4)                            DSK1149 00714030
         TM    TCBESTRM-TCB(R4),TCBSTAFX                        DSK1149 00714040
         BNO   A00037A                                          DSK1149 00714050
         NI    TCBESTRM-TCB(R4),255-TCBSTAFX                    DSK1149 00714060
         NI    TCBFLGS1-TCB(R4),255-TCBFX                       DSK1149 00714070
*   R6=0;                           /* CLEAR WORK REGISTER   @Z40FPXA*/ 00715000
A00037A  DS    0H                                               DSK1149 00715010
         SLR   R6,R6                                               0273 00716000
*   SCBPTR=TCBSTABB;                /* POINT TO TOP OF SCB QUEUE   0274 00717000
*                                                            @Z40FPXA*/ 00718000
*                                                                  0274 00719000
         L     R10,TCBSTABB-TCB-1(,R4)                          DSK1149 00720000
         LA    R10,0(,R10)                                      DSK1149 00721000
*   /*****************************************************************/ 00722000
*   /*                                                               */ 00723000
*   /* SCAN TCB SCB QUEUE, AND VERIFY ALL ADDRESS ARE VALID          */ 00724000
*   /*                                                               */ 00725000
*   /*****************************************************************/ 00726000
*                                                                  0275 00727000
*   DO WHILE(SCBPTR^=0);            /* SCAN TO END OF QUEUE  @Z40FPXA*/ 00728000
         B     @DE00275                                            0275 00729000
@DL00275 DS    0H                                                  0276 00730000
*     GEN(LRA R0,0(SCBPTR));        /* VERIFY VALID ADDRESS  @Z40FPXA*/ 00731000
         LRA   R0,0(R10)                                        DSK1149 00732000
*     BC(7,BADADD1);                /* EXIT IF INVALID ADDRESS     0277 00733000
*                                                            @Z40FPXA*/ 00734000
*                                                                  0277 00735000
         BC    7,BADADD1                                           0277 00736000
*     /***************************************************************/ 00737000
*     /*                                                             */ 00738000
*     /* INSURE THAT BLOCK POINTED TO IS AN SCB                      */ 00739000
*     /*                                                             */ 00740000
*     /***************************************************************/ 00741000
*                                                                  0278 00742000
*     IF SCBID^='BD'X THEN          /* IS BLOCK AN SCB?      @Z40FPXA*/ 00743000
         CLI   SCBID-SCB(R10),X'DB'                             DSK1149 00744010
         BNE   BADADD1                                          DSK1149 00745000
*       GOTO BADADD1;               /* NO... TRUNCATE QUEUE  @Z40FPXA*/ 00746000
*     R6=SCBPTR;                    /* SAVE LAST SCB ADDRESS @Z40FPXA*/ 00747000
         LR    R6,R10                                           DSK1149 00748000
*     SCBPTR=SCBCHAIN;              /* ADDRESS OF NEXT SCB   @Z40FPXA*/ 00749000
         L     R10,SCBCHAIN-SCB(,R10)                           DSK1149 00750000
*   END;                            /* END OF SCAN LOOP      @Z40FPXA*/ 00751000
*                                                                  0282 00752000
@DE00275 LTR   R10,R10                                          DSK1149 00753000
         BNZ   @DL00275                                            0282 00754000
*   /*****************************************************************/ 00755000
*   /*                                                               */ 00756000
*   /* CONTROL REACHES HERE EITHER BECAUSE OF END OF QUEUE OR BAD    */ 00757000
*   /* ADDRESS/SCB IN QUEUE                                          */ 00758000
*   /*                                                               */ 00759000
*   /*****************************************************************/ 00760000
*                                                                  0283 00761000
*BADADD1:                                                          0283 00762000
*   IF SCBPTR^=0 THEN               /* IF NOT ZERO, ERROR FOUND    0283 00763000
*                                                            @Z40FPXA*/ 00764000
BADADD1  SLR   R15,R15                                          DSK1149 00765000
         CR    R10,R15                                          DSK1149 00766000
         BE    @RF00283                                            0283 00767000
*     IF R6=0 THEN                  /* FIRST SCB BAD?        @Z40FPXA*/ 00768000
         CR    R6,R15                                           DSK1149 00769000
         BNE   @RF00284                                            0284 00770000
*       TCBSTABB=0;                 /* TRUNCATE QUEUE AT TCB @Z40FPXA*/ 00771000
         STCM  R15,7,TCBSTABB-TCB(R4)                           DSK1149 00772000
*     ELSE                                                         0286 00773000
*       R6->SCBCHAIN=0;             /* TRUNCATE QUEUE AT LAST SCB  0286 00774000
*                                                            @Z40FPXA*/ 00775000
*                                                                  0286 00776000
         B     @RC00284                                            0286 00777000
@RF00284 SLR   R15,R15                                          DSK1149 00778000
         ST    R15,SCBCHAIN-SCB(,R6)                            DSK1149 00779000
*   /*****************************************************************/ 00780000
*   /*                                                               */ 00781000
*   /* SCAN FREE SCB QUEUE TO INSURE QUEUE IS INTACT                 */ 00782000
*   /*                                                               */ 00783000
*   /*****************************************************************/ 00784000
*                                                                  0287 00785000
*   RFY                                                            0287 00786000
*    (R7) RSTD;                     /* RESTRICT REGISTER     @Z40FPXA   00787000
*                                                            @ZA11838*/ 00788000
@RC00284 DS    0H                                                  0287 00789000
@RF00283 DS    0H                                                  0288 00790000
*   R7=WSALSTAE;                    /* POINT TO FREE QUEUE   @Z40FPXA*/ 00791000
         L     R15,PSAAOLD-PSA                                  DSK1149 00792000
         L     R15,ASCBASXB-ASCB(,R15)                          DSK1149 00793000
         L     R15,ASXBSPSA-ASXB(,R15)                          DSK1149 00794000
         L     R7,WSALSTAE(,R15)                                DSK1149 00795000
         ST    R7,SDWASRSV-SDWA+7*4(,R1)                        DSK1149 00795010
*   SCBPTR=FREESCBQ;                /* POINT TO TOP OF FREE CELL   0289 00796000
*                                      QUEUE                 @Z40FPXA*/ 00797000
         L     R10,FREESCBQ(,R7)                                DSK1149 00798000
*   R6=0;                           /* CLEAR WORK REGISTER   @Z40FPXA*/ 00799000
         SLR   R6,R6                                               0290 00800000
*   DO WHILE(SCBPTR^=0);            /* SCAN TO END OF QUEUE  @Z40FPXA*/ 00801000
         B     @DE00291                                            0291 00802000
@DL00291 DS    0H                                                  0292 00803000
*     GEN(LRA  R0,0(SCBPTR));       /* CHECK FOR VALID ADDRESS     0292 00804000
*                                                            @Z40FPXA*/ 00805000
         LRA   R0,0(R10)                                        DSK1149 00806000
*     BC(7,BADADD2);                /* EXIT IF INVALID ADDRESS     0293 00807000
*                                                            @Z40FPXA*/ 00808000
         BC    7,BADADD2                                           0293 00809000
*     R6=SCBPTR;                    /* SAVE LAST GOOD CELL ADDRESS 0294 00810000
*                                                            @Z40FPXA*/ 00811000
         LR    R6,R10                                           DSK1149 00812000
*     SCBPTR=SCBCHAIN;              /* PICK UP NEXT CELL ADDRESS   0295 00813000
*                                                            @Z40FPXA*/ 00814000
         L     R10,SCBCHAIN-SCB(,R10)                           DSK1149 00815000
*   END;                            /* END OF QUEUE SEARCH   @Z40FPXA*/ 00816000
@DE00291 LTR   R10,R10                                          DSK1149 00817000
         BNZ   @DL00291                                            0296 00818000
*BADADD2:                                                          0297 00819000
*   IF SCBPTR^=0 THEN               /* IF NON ZERO A ERROR WAS FOUND    00820000
*                                                            @Z40FPXA*/ 00821000
BADADD2  SLR   R15,R15                                          DSK1149 00822000
         CR    R10,R15                                          DSK1149 00823000
         BE    @RF00297                                            0297 00824000
*     IF R6^=0 THEN                 /* FIRST CELL IN ERROR?  @Z40FPXA*/ 00825000
         CR    R6,R15                                           DSK1149 00826000
         BNE   @RF00298                                         DSK1149 00827010
*       FREESCBQ=0;                 /* TRUNCATE FREE CELL QUEUE AT 0299 00828000
*                                      TOP                   @Z40FPXA*/ 00829000
         ST    R15,FREESCBQ(,R7)                                DSK1149 00830000
*     ELSE                                                         0300 00831000
*       R6->SCBCHAIN=0;             /* TRUNCATE AT LAST VALID CELL 0300 00832000
*                                                            @Z40FPXA*/ 00833000
*                                                                  0300 00834000
         B     @RC00298                                            0300 00835000
@RF00298 SLR   R15,R15                                          DSK1149 00836000
         ST    R15,SCBCHAIN-SCB(,R6)                            DSK1149 00837000
*   /*****************************************************************/ 00838000
*   /*                                                               */ 00839000
*   /* BOTH SCB CELL CHAINS HAVE BEEN VERIFIED, RETURN TO STA0'S     */ 00840000
*   /* CALLER WITH RETURN CODE 16 INDICATING UNEXPECTED ERROR        */ 00841000
*   /*                                                               */ 00842000
*   /*****************************************************************/ 00843000
*                                                                  0301 00844000
*   RETCOD=16;                      /* SET ERROR RETURN CODE         */ 00845000
@RC00298 DS    0H                                                  0301 00846000
@RF00297 MVI   RETCOD(R9),X'10'                                    0301 00847000
*   SDWARTYA=ADDR(ESTARETY);        /* RETRY ADDRESS         @Z40FPXA*/ 00848000
         LA    R15,ESTARETY                                     DSK1149 00849000
         ST    R15,SDWARTYA-SDWA(,R1)                           DSK1149 00850000
         OI    SDWAACF2-SDWA(R1),SDWARCRD                       DSK1149 00850010
*   SDWARCDE=4;                     /* INDICATE RETRY TO RTM @Z40FPXA*/ 00851000
         MVI   SDWARCDE-SDWA(R1),X'04'                          DSK1149 00852000
*   GEN(SETFRR D,WRKREGS=(R2,R3));  /* DELETE FRR            @Z40FPXA*/ 00853000
         SETFRR D,WRKREGS=(R2,R3)                                       00854000
*   GEN(BR   R14);                  /* RETURN TO RTM WITH RETRY CODE    00855000
*                                                            @Z40FPXA*/ 00856000
         BR   R14                                                       00857000
*                                                                  0306 00858000
*   /*****************************************************************/ 00859000
*   /*                                                               */ 00860000
*   /* RETRY POINT FROM ESTAE FRR. ROUTINE WILL ENABLE THE CURRENT   */ 00861000
*   /* PSW, AND BRANCH TO THE ESTAE RETRY POINT                      */ 00862000
*   /*                                                               */ 00863000
*   /*****************************************************************/ 00864000
*                                                                  0306 00865000
*ESTARETY:                          /* ESTAE RETRY POINT             */ 00866000
*   GENERATE;                                                      0306 00867000
ESTARETY DS    0H                                                  0306 00868000
        ENTRY  ESTARETY              ENTRY POINT FOR RETRY              00869000
         USING *,R15                 ADDRESSABILITY             DSK1149 00870000
        STOSM  SBPBYTE,X'07'         ENABLE FOR RETURN TO CALLER        00871000
         L     R14,FLCCVT-PSA                                   DSK1149 00872000
        L      R14,CVTSV60-CVT(R14)  ADDRESS OF ESTAE BRANCH ENTRY PT   00873000
         LA    R10,10(,R14)                                     DSK1149 00873010
        SL     R14,FOURCON           RETRY POINT IS 4 BEFORE ENTRY      00874000
        LR     R15,R14               COPY INTO REG 15                   00875000
        BR     R15                   ENTER ESTAE FOR RETURN TO CALLER   00876000
        DS     0F                                                       00877000
FOURCON DC    F'4'                   CONSTANT FOR DECREMENTING PTR      00878000
SBPBYTE DC    X'00'                                                     00879000
*                                                                  0307 00880000
*   /*****************************************************************/ 00881000
*   /*                                                               */ 00882000
*   /* ESTAECHK ROUTINE IS ENTERED FROM IEAVTRTM TO DETERMINE IF THE */ 00883000
*   /* CURRENT ERROR OCCURED WHILE THE ESTAE SERVICE ROUTINE WAS IN  */ 00884000
*   /* CONTROL, IF SO A FRR IS ADDED TO THE CURRENT STACK, AND A     */ 00885000
*   /* SUPER BIT IS SET TO INSURE THAT ESTAE'S FRR WILL GAIN CONTROL */ 00886000
*   /* FIRST                                                         */ 00887000
*   /*                                                               */ 00888000
*   /*****************************************************************/ 00889000
*                                                                  0307 00890000
*ESTAECHK:                          /* CHECK IF ESTAE WAS IN CONTROL    00891000
*                                                            @Z40FPXA*/ 00892000
*   GENERATE;                                                      0307 00893000
         DC    X'CC'                         !!! SOURCE COMPARE FIX !!! 00894000
ESTAECHK DC    0H'0'                                            DSK1149 00894000
*                     /* GET ADDRESSABILITY TO SAVE AREA @Z40FPXA*/     00895000
      ENTRY ESTAECHK                                                    00896000
      L     R15,PSALCCAV-PSA          ADDRESS OF MY LCCA                00897000
      L     R15,LCCACPUS-LCCA(R15)    CPU RELATED SAVE AREA             00898000
      L     R15,WSACRRSA-WSAC(R15)    REFRESH SAVE AREA                 00899000
      STM   R0,R14,0(R15)             SAVE REGISTERS                    00900000
      BALR  R8,0                      SET UP BASE REG                   00901000
*   GEN REFS(PSALCCAV,PSA,LCCACPUS,LCCA,WSACRRSA,WSAC,CVTSV60,CVT) 0308 00902000
*       (USING  *,8);               /* SET UP ADDRESSABILITY @Z40FPXA*/ 00903000
         USING *,R8                                             DSK1149 00904000
*   RFY                                                            0309 00905000
*    (R8,                                                          0309 00906000
*     R15) RSTD;                                                   0309 00907000
*                                                                  0309 00908000
*   /*****************************************************************/ 00909000
*   /*                                                               */ 00910000
*   /* CHECK IF ESTAE SERVICE ROUTINE WAS IN CONTROL AT TIME OF      */ 00911000
*   /* ERROR,                                                        */ 00912000
*   /*                                                               */ 00913000
*   /*****************************************************************/ 00914000
*                                                                  0310 00915000
*   IF PSATOLD^=0&PSATOLD->TCBSTAWA^=0 THEN/* ESTAE IN CONTROL?      */ 00916000
         L     R11,PSATOLD-PSA                                  DSK1149 00917000
         SLR   R3,R3                                            DSK1149 00918000
         CR    R11,R3                                           DSK1149 00919000
         BE    @RF00310                                            0310 00920000
         C     R3,TCBSTAWA-TCB(,R11)                            DSK1149 00921000
         BE    @RF00310                                            0310 00922000
*     DO;                           /* SET UP FRR FOR ESTAE RECOVERY    00923000
*                                                            @Z40FPXA*/ 00924000
*       GEN(SETFRR A,FRRAD=ESTFRR,WRKREGS=(13,14));/* SET UP FRR   0312 00925000
*                                                            @Z40FPXA*/ 00926000
         SETFRR A,FRRAD=ESTFRR,WRKREGS=(13,14)                          00927000
*       PSAESTA='1'B;               /* SET SUPER BIT         @Z40FPXA*/ 00928000
         OI    PSASUP3-PSA,PSAESTA                              DSK1149 00929000
*     END;                                                         0314 00930000
*   GENERATE;                                                      0315 00931000
@RF00310 DS    0H                                                  0315 00932000
*             /* RELOAD REGS AND RETURN TO CALLER */                    00933000
       LM   R0,R14,0(R15)                                               00934000
       BR   R14                                                         00935000
ESTFRR DC   A(ESTAEFRR)                                                 00936000
*   DECLARE                         /* GENERAL PURPOSE REGISTERS     */ 00937000
*     GPR00P PTR(31) REG(0),                                       0316 00938000
*     GPR01P PTR(31) REG(1),                                       0316 00939000
*     GPR14P PTR(31) REG(14),                                      0316 00940000
*     GPR15P PTR(31) REG(15);                                      0316 00941000
*   DECLARE                         /* COMMON VARIABLES              */ 00942000
*     I256C CHAR(256) BASED,                                       0317 00943000
*     I031F FIXED(31) BASED,                                       0317 00944000
*     I031P PTR(31) BASED,                                         0317 00945000
*     I015F FIXED(15) BASED,                                       0317 00946000
*     I015P PTR(15) BASED,                                         0317 00947000
*     I008P PTR(8) BASED,                                          0317 00948000
*     I001C CHAR(1) BASED;                                         0317 00949000
*   END IEAVTSBP                                                   0318 00950000
*                                                                  0318 00951000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00952000
*/*%INCLUDE SYSUT5  (TRMSPEC )                                       */ 00953000
*/*%INCLUDE SYSUT5  (TRMDCL  )                                       */ 00954000
*/*%INCLUDE SYSLIB  (IHAASCB )                                       */ 00955000
*/*%INCLUDE SYSLIB  (IHAASXB )                                       */ 00956000
*/*%INCLUDE SYSLIB  (IHALCCA )                                       */ 00957000
*/*%INCLUDE SYSLIB  (IHASDWA )                                       */ 00958000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00959000
*/*%INCLUDE SYSLIB  (IKJTCB  )                                       */ 00960000
*/*%INCLUDE SYSLIB  (IHASCB  )                                       */ 00961000
*/*%INCLUDE SYSLIB  (IHARB   )                                       */ 00962000
*/*%INCLUDE SYSLIB  (IKJRB   )                                       */ 00963000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 00964000
*/*%INCLUDE SYSLIB  (IHAFRRS )                                       */ 00965000
*/*%INCLUDE SYSLIB  (IHAWSAVT)                                       */ 00966000
*/*%INCLUDE SYSUT5  (TRMSETUP)                                       */ 00967000
*/*%INCLUDE SYSUT5  (TRMPROCS)                                       */ 00968000
*/*%INCLUDE SYSUT5  (TRMFREE )                                       */ 00969000
*/*%INCLUDE SYSUT5  (TRRMFRR )                                       */ 00970000
*/*%INCLUDE SYSUT5  (ESTAEFRR)                                       */ 00971000
*                                                                  0318 00972000
*       ;                                                          0318 00973000
@EL00001 DS    0H                                                  0318 00974000
@EF00001 DS    0H                                                  0318 00975000
@ER00001 LM    R14,R12,12(R13)                                  DSK1149 00976000
         BR    R14                                              DSK1149 00977000
         DC    X'180B'                       !!! SOURCE COMPARE FIX !!! 00978000
@DATA    DC    0H'0'                                            DSK1149 00978000
@DATD    DSECT                                                          00979000
         DS    0F                                                       00980000
IEAVTSBP CSECT                                                          00981000
         DC    0F'0'                                            DSK1149 00982000
@CF00097 DC    F'64'                                                    00983000
@CF02674 DC    XL4'0000FFFF'                                            00984000
@DATD    DSECT                                                          00985000
         DS    0D                                                       00986000
@ENDDATD EQU   *                                                        00987000
IEAVTSBP CSECT                                                          00988000
         NOPR  ((@ENDDATD-@DATD)*16)                                    00989000
         DC    X'4006'                       !!! SOURCE COMPARE FIX !!! 00990000
         DC    0F'0'                                            DSK1149 00990000
@SIZDATD DC    AL1(0)                                                   00991000
         DC    AL3(@ENDDATD-@DATD)                                      00992000
         DC    0D'0'                                            DSK1149 00993000
@CC02642 DC    C'IEAVTSBP'                                              00994000
@CC02652 DC    C'ESTAEFRR'                                              00995000
@CC02653 DC    C'IGC00060'                                              00996000
@CB02647 DC    X'0C4000'                                                00997000
         CVT      DSECT=YES,LIST=YES                            DSK1149 00998000
         IKJRB    ,                                             DSK1149 00998001
RBIQENA  EQU      RBSTAB2                                       DSK1149 00998002
         IKJTCB   LIST=YES                                      DSK1149 00998003
         IHAASXB  ,                                             DSK1149 00998004
         IHAASCB  ,                                             DSK1149 00998005
         IHAFRRS  ,                                             DSK1149 00998006
         IHALCCA  ,                                             DSK1149 00998007
         IHAPSA   ,                                             DSK1149 00998008
         IHASDWA  ,                                             DSK1149 00998009
         IHASCB   ,                                             DSK1149 00998010
R0       EQU   0                       REGISTER 0               DSK1149 00998011
R1       EQU   1                       REGISTER 1               DSK1149 00998012
R2       EQU   2                       REGISTER 2               DSK1149 00998013
R3       EQU   3                       REGISTER 3               DSK1149 00998014
R4       EQU   4                       REGISTER 4               DSK1149 00998015
R5       EQU   5                       REGISTER 5               DSK1149 00998016
R6       EQU   6                       REGISTER 6               DSK1149 00998017
R7       EQU   7                       REGISTER 7               DSK1149 00998018
R8       EQU   8                       REGISTER 8               DSK1149 00998019
R9       EQU   9                       REGISTER 9               DSK1149 00998020
R10      EQU   10                      REGISTER 10              DSK1149 00998021
R11      EQU   11                      REGISTER 11              DSK1149 00998022
R12      EQU   12                      REGISTER 12              DSK1149 00998023
R13      EQU   13                      REGISTER 13              DSK1149 00998024
R14      EQU   14                      REGISTER 14              DSK1149 00998025
R15      EQU   15                      REGISTER 15              DSK1149 00998026
OUT      EQU   0                                                        01076000
FRREPTR  EQU   0                                                        01079000
FRRPARM  EQU   0                                                        01080000
RETRYIND EQU   FRRPARM                                                  01081000
RBOLDPTR EQU   FRRPARM+4                                                01082000
RBNEWPTR EQU   FRRPARM+8                                                01083000
PTRTCB   EQU   FRRPARM+12                                               01084000
SAVEPTR  EQU   FRRPARM+16                                               01085000
VALIDLST EQU   FRRPARM+20                                               01086000
FREESCBQ EQU   108                                              DSK1149 01088000
RETCOD   EQU   12                                               DSK1149 01090000
WSAL     EQU   0                                                        01440000
WSALSTAE EQU   WSAL+44                                                  01441000
WSAG     EQU   0                                                        01442000
WSAC     EQU   0                                                        01443000
WSACRRSA EQU   WSAC+48                                                  01444000
I001C    EQU   0                                                        01445000
I008P    EQU   0                                                        01446000
I015F    EQU   0                                                        01447000
I015P    EQU   0                                                        01448000
I031F    EQU   0                                                        01449000
I031P    EQU   0                                                        01450000
I256C    EQU   0                                                        01451000
@ENDDATA EQU   *                                                        03562000
         END   IEAVTSBP                                         DSK1149 03563000
