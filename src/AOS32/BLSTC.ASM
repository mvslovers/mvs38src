TC       TITLE 'BLSTC   --IPCS SERVICE ROUTINE TO DISPLAY CHARACTER DAT*00001000
               TA       '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPLK                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSTC    CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(16)                                             0002 00010000
         DC    C'BLSTC     78.059'                                 0002 00011000
         DROP  @15                                                      00012000
@PROLOG  STM   @14,@12,12(@13)                                     0002 00013000
         BALR  @12,0                                               0002 00014000
@PSTART  DS    0H                                                  0002 00015000
         USING @PSTART,@12                                         0002 00016000
         L     @00,@SIZDATD                                        0002 00017000
         BLSUALLS R,LV=(0)                                              00018000
         LR    @11,@01                                             0002 00019000
         USING @DATD,@11                                           0002 00020000
         ST    @13,@SA00001+4                                      0002 00021000
         LM    @00,@01,20(@13)                                     0002 00022000
         ST    @11,8(,@13)                                         0002 00023000
         LR    @13,@11                                             0002 00024000
         MVC   @PC00001(12),0(@01)                                 0002 00025000
*   FLAG='00'X;                     /* INITIALIZE PROCESSING FLAGS   */ 00026000
         MVI   FLAG,X'00'                                          0137 00027000
*   MCB=MCS;                        /* MESSAGE MC LITERAL TEXT       */ 00028000
         MVC   MCB(81),MCS                                         0138 00029000
*   MDB=MDS;                        /* MESSAGE MD LITERAL TEXT       */ 00030000
         MVC   MDB(72),MDS                                         0139 00031000
*   LINEADDR=ESPALAD+ESPADOF;       /* DUMP ADDRESS FOR DATA LINE    */ 00032000
         L     @14,@PC00001+4                                      0140 00033000
         L     LINEADDR,ESPALAD(,@14)                              0140 00034000
         AL    LINEADDR,ESPADOF(,@14)                              0140 00035000
*   LINELEN=ESPADLE*MAX(ESPADIM,1); /* LENGTH OF DATA LINE           */ 00036000
         L     LINELEN,ESPADIM(,@14)                               0141 00037000
         LA    @10,1                                               0141 00038000
         CLR   LINELEN,@10                                         0141 00039000
         BNL   *+6                                                      00040000
         LR    LINELEN,@10                                         0141 00041000
         LR    @01,LINELEN                                         0141 00042000
         M     @00,ESPADLE(,@14)                                   0141 00043000
         LR    LINELEN,@01                                         0141 00044000
*   MVCLD=MVCLD&&MVCLD;             /* INITIALIZE MVCL DESCRIPTOR    */ 00045000
         XC    MVCLD(16),MVCLD                                     0142 00046000
*   MVCLD1P=ADDR(BLK);              /* ->PARAMETER DATA BUFFER       */ 00047000
         L     @14,@PC00001+8                                      0143 00048000
         ST    @14,MVCLD1P                                         0143 00049000
*   MVCLD1L=LINELEN;                /* LENGTH OF DATA BUFFER         */ 00050000
         STCM  LINELEN,7,MVCLD1L                                   0144 00051000
*   IF LINELEN>LENGTH(BUFB) THEN    /* MULTIPLE DISPLAY LINES        */ 00052000
*                                                                  0145 00053000
         LA    @14,64                                              0145 00054000
         CR    LINELEN,@14                                         0145 00055000
         BNH   @RF00145                                            0145 00056000
*     /***************************************************************/ 00057000
*     /*                                                             */ 00058000
*     /* MULTIPLE DISPLAY LINES                                      */ 00059000
*     /*                                                             */ 00060000
*     /***************************************************************/ 00061000
*                                                                  0146 00062000
*     DO;                           /* MULTIPLE DISPLAY LINES        */ 00063000
*       LINELEN=LENGTH(BUFB)-(LINEADDR&BUFMASK2);/* ALIGN LINES      */ 00064000
         LR    LINELEN,LINEADDR                                    0147 00065000
         N     LINELEN,@CF01109                                    0147 00066000
         LCR   LINELEN,LINELEN                                     0147 00067000
         ALR   LINELEN,@14                                         0147 00068000
*       MVCLD2P=ADDR(BUFB)+LENGTH(BUFB)-LINELEN;/* ->FIRST BYTE OF 0148 00069000
*                                      TARGET                        */ 00070000
         LA    @10,BUFB                                            0148 00071000
         ALR   @10,@14                                             0148 00072000
         SLR   @10,LINELEN                                         0148 00073000
         ST    @10,MVCLD2P                                         0148 00074000
*     END;                                                         0149 00075000
*   ELSE                            /* ONE DISPLAY LINE              */ 00076000
*                                                                  0150 00077000
*     /***************************************************************/ 00078000
*     /*                                                             */ 00079000
*     /* ONE DISPLAY LINE                                            */ 00080000
*     /*                                                             */ 00081000
*     /***************************************************************/ 00082000
*                                                                  0150 00083000
*     DO;                           /* ONE DISPLAY LINE              */ 00084000
         B     @RC00145                                            0150 00085000
@RF00145 DS    0H                                                  0151 00086000
*       MVCLD2P=ADDR(BUFB);         /* ->FIRST BYTE OF TARGET        */ 00087000
         LA    @14,BUFB                                            0151 00088000
         ST    @14,MVCLD2P                                         0151 00089000
*       FLAGL='1'B;                 /* LEFT-JUSTIFY LINE             */ 00090000
         OI    FLAGL,B'00001000'                                   0152 00091000
*     END;                                                         0153 00092000
*   DUPLEN=0;                       /* LENGTH OF REDUNDANT AREA      */ 00093000
@RC00145 SLR   DUPLEN,DUPLEN                                       0154 00094000
*   RETC=ZZZFLAGI;                  /* RETURN CODE                   */ 00095000
*                                                                  0155 00096000
         SLR   RETC,RETC                                           0155 00097000
*   /*****************************************************************/ 00098000
*   /*                                                               */ 00099000
*   /* ITERATIVELY RETRIEVE AND DISPLAY DUMP DATA UNTIL THE REQUEST  */ 00100000
*   /* IS PROCESSED. STOP IF INTERRUPTED BY ATTN                     */ 00101000
*   /*                                                               */ 00102000
*   /*****************************************************************/ 00103000
*                                                                  0156 00104000
*   DO WHILE(FLAGEND='0'B);         /* LOOP PROCESSING THE DATA      */ 00105000
         B     @DE00156                                            0156 00106000
@DL00156 DS    0H                                                  0157 00107000
*     DO;                           /* BLRCNVPC(LINEADDR) FROM(POINTE   00108000
*                                      R)TO(CHARACTER)SET(MCBT10)REMA   00109000
*                                      RK(OUTPUT LINE              0157 00110000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00111000
*                                                                  0157 00112000
*       /*************************************************************/ 00113000
*       /*                                                           */ 00114000
*       /* OUTPUT LINE ADDRESS                                       */ 00115000
*       /*                                                           */ 00116000
*       /*************************************************************/ 00117000
*                                                                  0158 00118000
*       PTRPTR=LINEADDR;            /* SOURCE TO BIT/POINTER       0158 00119000
*                                      INTERMEDIATE                  */ 00120000
         ST    LINEADDR,PTRPTR                                     0158 00121000
*       UNPK(MCBT10(1:LENGTH(MCBT10)-1),PTRBIT);/* BIT=>ZONED      0159 00122000
*                                      HEXADECIMAL                   */ 00123000
         UNPK  MCBT10(5),PTRBIT(4)                                 0159 00124000
*       MCBT10(LENGTH(MCBT10):LENGTH(MCBT10))=PTRBIT(25:32);/* FINAL    00125000
*                                      ZONED HEXADECIMAL DIGIT       */ 00126000
         MVC   MCBT10+5(1),PTRBIT+3                                0160 00127000
*       TR(MCBT10,ZZ1TRHEX);        /* ZONED HEXADECIMAL=>EBCDIC     */ 00128000
         L     @14,ZZ2ZZ1P(,R9)                                    0161 00129000
         TR    MCBT10(6),ZZ1TRHEX(@14)                             0161 00130000
*     END;                          /* BLRCNVPC(LINEADDR) FROM(POINTE   00131000
*                                      R)TO(CHARACTER)SET(MCBT10)REMA   00132000
*                                      RK(OUTPUT LINE              0162 00133000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00134000
*     MVCLD2L=LINELEN;              /* DATA BYTES IN THIS LINE       */ 00135000
         STCM  LINELEN,7,MVCLD2L                                   0163 00136000
*     IF LINELEN<LENGTH(BUFB) THEN  /* PARTIAL OUTPUT LINE           */ 00137000
         C     LINELEN,@CF00199                                    0164 00138000
         BNL   @RF00164                                            0164 00139000
*       BUFB=BUFS;                  /* BLANK LOCAL BUFFER            */ 00140000
         MVC   BUFB(64),BUFS                                       0165 00141000
*     RESPECIFY                     /* BEFORE MVCL                   */ 00142000
*      (R0,                         /* ->LOCAL BUFFER                */ 00143000
*       R1,                         /* LENGTH OF LOCAL BUFFER        */ 00144000
*       RE) RESTRICTED;             /* ->PARAMETER BUFFER            */ 00145000
@RF00164 DS    0H                                                  0167 00146000
*     LM(RE,R1,MVCLD);              /* DESCRIBE MOVE OPERANDS        */ 00147000
         LM    RE,R1,MVCLD                                         0167 00148000
*     MVCL(R0,RE);                  /* MOVE DATA TO LOCAL BUFFER     */ 00149000
         MVCL  R0,RE                                               0168 00150000
*     BC(4,L010);                   /* REQUEST NOT YET SATISFIED     */ 00151000
         BC    4,L010                                              0169 00152000
*     FLAGEND='1'B;                 /* REQUEST HAS BEEN SATISFIED    */ 00153000
         OI    FLAGEND,B'00100000'                                 0170 00154000
*L010:                              /* REQUEST NOT YET SATISFIED     */ 00155000
*     STM(RE,RF,MVCLD1);            /* DESCRIBE DATA REMAINING       */ 00156000
L010     STM   RE,RF,MVCLD1                                        0171 00157000
*     RESPECIFY                     /* AFTER MVCL                    */ 00158000
*      (R0,                         /* DESTROYED                     */ 00159000
*       R1,                         /* DESTROYED                     */ 00160000
*       RE) UNRESTRICTED;           /* ->PARAMETER BUFFER+LINE LENGTH*/ 00161000
*     TR(BUFB,ZZ1TREBC);            /* ELIMINATE NON-GRAPHIC DATA    */ 00162000
         L     @14,ZZ2ZZ1P(,R9)                                    0173 00163000
         TR    BUFB(64),ZZ1TREBC(@14)                              0173 00164000
*     IF BUFB=MCBT3&                /* DATA APPEARS REDUNDANT        */ 00165000
*         (FLAGD1='1'B×             /* REDUNDANT VALUE RANGE         */ 00166000
*         (FLAGF='1'B&LINELEN=LENGTH(BUFB))) THEN/* REDUNDANT LINE   */ 00167000
*                                                                  0174 00168000
         CLC   BUFB(64),MCBT3                                      0174 00169000
         BNE   @RF00174                                            0174 00170000
         TM    FLAGD1,B'01000000'                                  0174 00171000
         BO    @RT00174                                            0174 00172000
         TM    FLAGF,B'00010000'                                   0174 00173000
         BNO   @RF00174                                            0174 00174000
         C     LINELEN,@CF00199                                    0174 00175000
         BNE   @RF00174                                            0174 00176000
@RT00174 DS    0H                                                  0175 00177000
*       /*************************************************************/ 00178000
*       /*                                                           */ 00179000
*       /* REDUNDANT DATA                                            */ 00180000
*       /*                                                           */ 00181000
*       /*************************************************************/ 00182000
*                                                                  0175 00183000
*       DO;                         /* REDUNDANT DATA                */ 00184000
*         IF FLAGD='0'B THEN        /* FIRST LINE OF REDUNDANT DATA  */ 00185000
*                                                                  0176 00186000
         TM    FLAGD,B'10000000'                                   0176 00187000
         BNZ   @RF00176                                            0176 00188000
*           /*********************************************************/ 00189000
*           /*                                                       */ 00190000
*           /* FIRST LINE OF REDUNDANT DATA                          */ 00191000
*           /*                                                       */ 00192000
*           /*********************************************************/ 00193000
*                                                                  0177 00194000
*           DO;                     /* FIRST LINE OF REDUNDANT DATA  */ 00195000
*             CALL E100;            /* BEGIN REDUNDANT DATA          */ 00196000
         BAL   @14,E100                                            0178 00197000
*             MDBT5=TDS;            /* LITERAL TEXT                  */ 00198000
         MVI   MDBT5+13,C' '                                       0179 00199000
         MVC   MDBT5+14(22),MDBT5+13                               0179 00200000
         MVC   MDBT5(13),TDS                                       0179 00201000
*             MDBL=LENGTH(MDB)-LENGTH(MDBT5)+LENGTH(TDS);          0180 00202000
         MVC   MDBL(2),@CH01148                                    0180 00203000
*           END;                                                   0181 00204000
*         ELSE                      /* 2ND, 3RD, ... REDUNDANT LINE  */ 00205000
*           DUPLEN=DUPLEN+LINELEN;  /* LENGTH OF REDUNDANT AREA      */ 00206000
         B     @RC00176                                            0182 00207000
@RF00176 ALR   DUPLEN,LINELEN                                      0182 00208000
*       END;                                                       0183 00209000
*     ELSE                          /* INTERESTING DATA              */ 00210000
*       FLAGN='1'B;                 /* NEW DATA LINE                 */ 00211000
         B     @RC00174                                            0184 00212000
@RF00174 OI    FLAGN,B'00000100'                                   0184 00213000
*     MCBT3=BUFB;                   /* CHARACTER DATA MESSAGE TEXT   */ 00214000
@RC00174 MVC   MCBT3(64),BUFB                                      0185 00215000
*     IF FLAGD='1'B&(FLAGN='1'B×FLAGEND='1'B) THEN                 0186 00216000
         TM    FLAGD,B'10000000'                                   0186 00217000
         BNO   @RF00186                                            0186 00218000
         TM    FLAGN,B'00100100'                                   0186 00219000
         BZ    @RF00186                                            0186 00220000
*       CALL E110;                  /* END OF REDUNDANT DATA         */ 00221000
         BAL   @14,E110                                            0187 00222000
*     IF FLAGN='1'B&                /* NEW DATA LINE                 */ 00223000
*         (BUFB=BUFS×MVCLD1L>1) THEN/* REDUNDANT VALUE TEST USEFUL   */ 00224000
*                                                                  0188 00225000
@RF00186 TM    FLAGN,B'00000100'                                   0188 00226000
         BNO   @RF00188                                            0188 00227000
         CLC   BUFB(64),BUFS                                       0188 00228000
         BE    @RT00188                                            0188 00229000
         CLC   MVCLD1L(3),@CF00050+1                               0188 00230000
         BNH   @RF00188                                            0188 00231000
@RT00188 DS    0H                                                  0189 00232000
*       /*************************************************************/ 00233000
*       /*                                                           */ 00234000
*       /* CHECK FOR REPETITION OF A SINGLE CHARACTER VALUE          */ 00235000
*       /*                                                           */ 00236000
*       /*************************************************************/ 00237000
*                                                                  0189 00238000
*       DO;                         /* CHECK FOR REDUNDANT VALUE     */ 00239000
*         RESPECIFY                 /* BEFORE CLCL                   */ 00240000
*          (R0,                     /* IGNORED                       */ 00241000
*           R1,                     /* INITIAL CHARACTER OF DATA     */ 00242000
*           RE) RESTRICTED;         /* ->LOCAL BUFFER                */ 00243000
*         LM(RE,RF,MVCLD2);         /* DESCRIBE CURRENT DATA LINE    */ 00244000
         LM    RE,RF,MVCLD2                                        0191 00245000
*         MVCLD2C=RE->I001C;        /* PADDING CHARACTER             */ 00246000
         MVC   MVCLD2C(1),I001C(RE)                                0192 00247000
*         MVCLD2L=0;                /* CONSIDER ONLY PADDING CHAR.   */ 00248000
         SLR   @05,@05                                             0193 00249000
         STCM  @05,7,MVCLD2L                                       0193 00250000
*         LM(R0,R1,MVCLD2);         /* DESCRIBE REDUNDANT VALUE      */ 00251000
         LM    R0,R1,MVCLD2                                        0194 00252000
*         CLCL(RE,R0);              /* CHECK FOR REDUNDANT VALUE     */ 00253000
         CLCL  RE,R0                                               0195 00254000
*         RESPECIFY                 /* AFTER CLCL                    */ 00255000
*          (R0,                     /* DESTROYED                     */ 00256000
*           R1,                     /* DESTROYED                     */ 00257000
*           RE) UNRESTRICTED;       /* DESTROYED                     */ 00258000
*         BC(7,L020);               /* NEW DATA LINE                 */ 00259000
         BC    7,L020                                              0197 00260000
*         CALL E100;                /* BEGIN REDUNDANT DATA          */ 00261000
         BAL   @14,E100                                            0198 00262000
*         FLAGD1='1'B;              /* REDUNDANT VALUE               */ 00263000
         OI    FLAGD1,B'01000000'                                  0199 00264000
*         IF MVCLD2C^=PERIOD THEN   /* REDUNDANT EBCDIC GRAPHIC      */ 00265000
*                                                                  0200 00266000
         CLI   MVCLD2C,C'.'                                        0200 00267000
         BE    @RF00200                                            0200 00268000
*           /*********************************************************/ 00269000
*           /*                                                       */ 00270000
*           /* REDUNDANT EBCDIC GRAPHIC                              */ 00271000
*           /*                                                       */ 00272000
*           /*********************************************************/ 00273000
*                                                                  0201 00274000
*           DO;                     /* REDUNDANT EBCDIC GRAPHIC      */ 00275000
*             MDBT5=MDST5;          /* REDUNDANT EBCDIC GRAPHIC      */ 00276000
         MVC   MDBT5(36),MDST5                                     0202 00277000
*             DO;                   /* BLRCNVXC(MVCLD2C) FROM(BS)TO(C   00278000
*                                      HARACTER)SET(MDBT51)REMARK(RED   00279000
*                                      UNDANT VALUE--HEXADECIMAL   0203 00280000
*                                      TRANSLATION)TR(ZZ1TRHEX)      */ 00281000
*                                                                  0203 00282000
*               /*****************************************************/ 00283000
*               /*                                                   */ 00284000
*               /* REDUNDANT VALUE--HEXADECIMAL TRANSLATION          */ 00285000
*               /*                                                   */ 00286000
*               /*****************************************************/ 00287000
*                                                                  0204 00288000
*               UNPK(MDBT51(1:LENGTH(MDBT51)-1),MVCLD2C);/*        0204 00289000
*                                      BIT=>ZONED HEXADECIMAL        */ 00290000
         UNPK  MDBT51(1),MVCLD2C(1)                                0204 00291000
*               MDBT51(LENGTH(MDBT51):LENGTH(MDBT51))=MVCLD2C(LENGTH(   00292000
*                   MVCLD2C):LENGTH(MVCLD2C));/* FINAL ZONED       0205 00293000
*                                      HEXADECIMAL DIGIT             */ 00294000
         MVC   MDBT51+1(1),MVCLD2C                                 0205 00295000
*               TR(MDBT51,ZZ1TRHEX);/* ZONED HEXADECIMAL=>EBCDIC     */ 00296000
         L     @14,ZZ2ZZ1P(,R9)                                    0206 00297000
         TR    MDBT51(2),ZZ1TRHEX(@14)                             0206 00298000
*             END;                  /* BLRCNVXC(MVCLD2C) FROM(BS)TO(C   00299000
*                                      HARACTER)SET(MDBT51)REMARK(RED   00300000
*                                      UNDANT VALUE--HEXADECIMAL   0207 00301000
*                                      TRANSLATION)TR(ZZ1TRHEX)      */ 00302000
*             MDBT531=MVCLD2C;      /* EBCDIC REDUNDANT VALUE        */ 00303000
         MVC   MDBT531(1),MVCLD2C                                  0208 00304000
*             MDBL=MDSL;            /* MESSAGE LENGTH                */ 00305000
         LH    @14,MDSL                                            0209 00306000
         N     @14,@CF01158                                        0209 00307000
         STH   @14,MDBL                                            0209 00308000
*           END;                                                   0210 00309000
*         ELSE                      /* PERIODS/EBCDIC NONGRAPHICS    */ 00310000
*                                                                  0211 00311000
*           /*********************************************************/ 00312000
*           /*                                                       */ 00313000
*           /* PERIODS AND/OR EBCDIC NONGRAPHICS                     */ 00314000
*           /*                                                       */ 00315000
*           /*********************************************************/ 00316000
*                                                                  0211 00317000
*           DO;                     /* PERIODS/EBCDIC NONGRAPHICS    */ 00318000
         B     @RC00200                                            0211 00319000
@RF00200 DS    0H                                                  0212 00320000
*             MDBT5=TDB;            /* PERIODS AND/OR NONGRAPHICS    */ 00321000
         MVI   MDBT5+26,C' '                                       0212 00322000
         MVC   MDBT5+27(9),MDBT5+26                                0212 00323000
         MVC   MDBT5(26),TDB                                       0212 00324000
*             MDBL=LENGTH(MDB)-LENGTH(MDBT5)+LENGTH(TDB);/* LENGTH   */ 00325000
         MVC   MDBL(2),@CH01149                                    0213 00326000
*           END;                                                   0214 00327000
*L020:                              /* COMMON PROCESSING PATH        */ 00328000
*         MVCLD2C='00'X;            /* RESET PADDING CHARACTER       */ 00329000
@RC00200 DS    0H                                                  0215 00330000
L020     MVI   MVCLD2C,X'00'                                       0215 00331000
*       END;                                                       0216 00332000
*     IF FLAGN='1'B THEN            /* INTERESTING DATA              */ 00333000
@RF00188 TM    FLAGN,B'00000100'                                   0217 00334000
         BNO   @RF00217                                            0217 00335000
*       CALL BLSUPUTA(ZZ2,MCB);     /* DISPLAY MESSAGE MC            */ 00336000
         ST    R9,@AL00001                                         0218 00337000
         LA    @14,MCB                                             0218 00338000
         ST    @14,@AL00001+4                                      0218 00339000
         L     @01,ZZ2BVTP(,R9)                                    0218 00340000
         L     @15,BVTPUTAP(,@01)                                  0218 00341000
         LA    @01,@AL00001                                        0218 00342000
         BALR  @14,@15                                             0218 00343000
*     ELSE                          /* REDUNDANT DATA                */ 00344000
*       IF FLAGD='1'B&FLAGEND='1'B THEN/* REDUNDANT TO THE END       */ 00345000
         B     @RC00217                                            0219 00346000
@RF00217 TM    FLAGD,B'10100000'                                   0219 00347000
         BNO   @RF00219                                            0219 00348000
*         CALL E110;                /* END OF REDUNDANT DATA         */ 00349000
         BAL   @14,E110                                            0220 00350000
*     IF FLAGEND='0'B THEN          /* ANOTHER PASS REQUIRED         */ 00351000
*                                                                  0221 00352000
@RF00219 DS    0H                                                  0221 00353000
@RC00217 TM    FLAGEND,B'00100000'                                 0221 00354000
         BNZ   @RF00221                                            0221 00355000
*       /*************************************************************/ 00356000
*       /*                                                           */ 00357000
*       /* ANOTHER PASS REQUIRED TO SATISFY THE REQUEST              */ 00358000
*       /*                                                           */ 00359000
*       /*************************************************************/ 00360000
*                                                                  0222 00361000
*       DO;                         /* ANOTHER PASS REQUIRED         */ 00362000
*         IF LINELEN=LENGTH(BUFB) THEN/* FULL DATA LINE              */ 00363000
         C     LINELEN,@CF00199                                    0223 00364000
         BNE   @RF00223                                            0223 00365000
*           FLAGF='1'B;             /* LOCAL BUFFER FULL             */ 00366000
         OI    FLAGF,B'00010000'                                   0224 00367000
*         ELSE                      /* PARTIAL DATA LINE             */ 00368000
*                                                                  0225 00369000
*           /*********************************************************/ 00370000
*           /*                                                       */ 00371000
*           /* PARTIAL DATA LINE                                     */ 00372000
*           /*                                                       */ 00373000
*           /*********************************************************/ 00374000
*                                                                  0225 00375000
*           DO;                     /* PARTIAL DATA LINE             */ 00376000
         B     @RC00223                                            0225 00377000
@RF00223 DS    0H                                                  0226 00378000
*             FLAGL='1'B;           /* LEFT-JUSTIFY NEXT DATA LINE   */ 00379000
         OI    FLAGL,B'00001000'                                   0226 00380000
*             MVCLD2P=ADDR(BUFB);   /* ->FIRST BYTE OF TARGET        */ 00381000
         LA    @14,BUFB                                            0227 00382000
         ST    @14,MVCLD2P                                         0227 00383000
*           END;                                                   0228 00384000
*         LINEADDR=LINEADDR+LINELEN;/* DUMP ADDRESS FOR DATA LINE    */ 00385000
@RC00223 ALR   LINEADDR,LINELEN                                    0229 00386000
*         LINELEN=MIN(MVCLD1L,LENGTH(BUFB));/* LENGTH OF DATA LINE   */ 00387000
         L     LINELEN,MVCLD1L-1                                   0230 00388000
         LA    LINELEN,0(,LINELEN)                                 0230 00389000
         LA    @14,64                                              0230 00390000
         CR    LINELEN,@14                                         0230 00391000
         BNH   *+6                                                      00392000
         LR    LINELEN,@14                                         0230 00393000
*         IF ZZ1EVEP='1'B THEN      /* ATTENTION INTERRUPTION        */ 00394000
*                                                                  0231 00395000
         L     @14,ZZ2ZZ1P(,R9)                                    0231 00396000
         TM    ZZ1EVEP(@14),B'01000000'                            0231 00397000
         BNO   @RF00231                                            0231 00398000
*           /*********************************************************/ 00399000
*           /*                                                       */ 00400000
*           /* ATTENTION INTERRUPTION--TERMINATE QUICKLY             */ 00401000
*           /*                                                       */ 00402000
*           /*********************************************************/ 00403000
*                                                                  0232 00404000
*           DO;                     /* ATTENTION INTERRUPTION        */ 00405000
*             RETC=MAX(RETC,ZZZFLAGS);/* SIGNAL INCOMPLETE PROCESSING*/ 00406000
         LA    @14,12                                              0233 00407000
         CR    RETC,@14                                            0233 00408000
         BNL   *+6                                                      00409000
         LR    RETC,@14                                            0233 00410000
*             FLAGEND='1'B;         /* TERMINATE QUICKLY             */ 00411000
         OI    FLAGEND,B'00100000'                                 0234 00412000
*           END;                                                   0235 00413000
*       END;                                                       0236 00414000
@RF00231 DS    0H                                                  0237 00415000
*   END;                                                           0237 00416000
@RF00221 DS    0H                                                  0237 00417000
@DE00156 TM    FLAGEND,B'00100000'                                 0237 00418000
         BZ    @DL00156                                            0237 00419000
*   RETURN CODE(RETC);                                             0238 00420000
*                                                                  0238 00421000
         L     @13,4(,@13)                                         0238 00422000
         L     @00,@SIZDATD                                        0238 00423000
         LR    @01,@11                                             0238 00424000
         BLSUFRES R,LV=(0),A=(1)                                        00425000
         LR    @15,@10                                             0238 00426000
         L     @14,12(,@13)                                        0238 00427000
         LM    @00,@12,20(@13)                                     0238 00428000
         BR    @14                                                 0238 00429000
*/********************************************************************/ 00430000
*/*                                                                  */ 00431000
*/* E100--BEGIN REDUNDANT DATA PROCESSING                            */ 00432000
*/*                                                                  */ 00433000
*/********************************************************************/ 00434000
*                                                                  0239 00435000
*E100:                              /* BEGIN REDUNDANT DATA          */ 00436000
*   PROCEDURE;                                                     0239 00437000
E100     STM   @14,@07,@SA00002                                    0239 00438000
         STM   @09,@12,@SA00002+40                                 0239 00439000
*   DUPLEN=LINELEN;                 /* LENGTH OF REDUNDANT AREA      */ 00440000
         LR    DUPLEN,LINELEN                                      0240 00441000
*   MDBT10=MCBT10;                  /* REDUNDANT DATA ADDRESS        */ 00442000
         MVC   MDBT10(6),MCBT10                                    0241 00443000
*   FLAGD='1'B;                     /* DUPLICATE DATA PROCESSING     */ 00444000
*   FLAGN='0'B;                     /* DATA LINE NOT NEW             */ 00445000
         OI    FLAGD,B'10000000'                                   0243 00446000
         NI    FLAGN,B'11111011'                                   0243 00447000
*   RETURN;                                                        0244 00448000
*                                                                  0244 00449000
@EL00002 DS    0H                                                  0244 00450000
@EF00002 DS    0H                                                  0244 00451000
@ER00002 LM    @14,@07,@SA00002                                    0244 00452000
         LM    @09,@12,@SA00002+40                                 0244 00453000
         BR    @14                                                 0244 00454000
*/********************************************************************/ 00455000
*/*                                                                  */ 00456000
*/* E110--END OF REDUNDANT DATA--SUMMARIZE                           */ 00457000
*/*                                                                  */ 00458000
*/********************************************************************/ 00459000
*                                                                  0245 00460000
*E110:                              /* END OF REDUNDANT DATA         */ 00461000
*   ENTRY;                                                         0245 00462000
E110     STM   @14,@07,@SA00002                                    0245 00463000
         STM   @09,@12,@SA00002+40                                 0245 00464000
*   DO;                             /* BLRCNVUC(DUPLEN) FROM(UNSIGNED   00465000
*                                      BINARY)TO(CHARACTER)SET(MDBT3)   00466000
*                                      PATTERN('40202020202020202120'   00467000
*                                      X)OPTIONS(PATTERN IN        0246 00468000
*                                      PLACE)REMARK(LENGTH OF      0246 00469000
*                                      REDUNDANT DATA)               */ 00470000
*                                                                  0246 00471000
*     /***************************************************************/ 00472000
*     /*                                                             */ 00473000
*     /* LENGTH OF REDUNDANT DATA                                    */ 00474000
*     /*                                                             */ 00475000
*     /***************************************************************/ 00476000
*                                                                  0247 00477000
*     CVD(DUPLEN,PACKED);           /* UNSIGNED BINARY=>PACKED     0247 00478000
*                                      DECIMAL                       */ 00479000
         CVD   DUPLEN,PACKED                                       0247 00480000
*     ED(MDBT3,PACKED(25:64));      /* PACKED DECIMAL=>EBCDIC        */ 00481000
         ED    MDBT3(10),PACKED+3                                  0248 00482000
*   END;                            /* BLRCNVUC(DUPLEN) FROM(UNSIGNED   00483000
*                                      BINARY)TO(CHARACTER)SET(MDBT3)   00484000
*                                      PATTERN('40202020202020202120'   00485000
*                                      X)OPTIONS(PATTERN IN        0249 00486000
*                                      PLACE)REMARK(LENGTH OF      0249 00487000
*                                      REDUNDANT DATA)               */ 00488000
*   CALL BLSUMPK1(ZZ2,MDB);         /* REMOVE EXTRA BLANKS           */ 00489000
         ST    R9,@AL00001                                         0250 00490000
         LA    @14,MDB                                             0250 00491000
         ST    @14,@AL00001+4                                      0250 00492000
         L     @10,ZZ2BVTP(,R9)                                    0250 00493000
         L     @15,BVTMPK1P(,@10)                                  0250 00494000
         LA    @01,@AL00001                                        0250 00495000
         BALR  @14,@15                                             0250 00496000
*   CALL BLSUPUTA(ZZ2,MDB);         /* DISPLAY MESSAGE MD            */ 00497000
         ST    R9,@AL00001                                         0251 00498000
         LA    @14,MDB                                             0251 00499000
         ST    @14,@AL00001+4                                      0251 00500000
         L     @10,ZZ2BVTP(,R9)                                    0251 00501000
         L     @15,BVTPUTAP(,@10)                                  0251 00502000
         LA    @01,@AL00001                                        0251 00503000
         BALR  @14,@15                                             0251 00504000
*   MDB=MDS;                        /* MESSAGE MD LITERAL TEXT       */ 00505000
         MVC   MDB(72),MDS                                         0252 00506000
*   FLAGD='0'B;                     /* END OF REDUNDANT LINES        */ 00507000
*   FLAGD1='0'B;                    /* END OF REDUNDANT VALUE        */ 00508000
         NI    FLAGD,B'00111111'                                   0254 00509000
*   RETURN;                                                        0255 00510000
         B     @EL00002                                            0255 00511000
*   END E100;                                                      0256 00512000
*                                                                  0256 00513000
*/*BLSTPEND--DISPLAY FORMATTER                                       */ 00514000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00515000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00516000
*                                                                  0257 00517000
*   DECLARE                         /* DATA FOR AHB MACROS           */ 00518000
*     PTRBIT BIT(32) BOUNDARY(WORD),/* DATA CONVERSION WORK AREA FOR    00519000
*                                      POINTER DATA                  */ 00520000
*     PTRPTR POINTER DEFINED(PTRBIT),/* DATA CONVERSION WORK AREA FOR   00521000
*                                      POINTER DATA                  */ 00522000
*     PACKED BIT(64) BOUNDARY(DWORD);/* DATA CONVERSION WORK AREA    */ 00523000
*   DECLARE                         /* COMMON VARIABLES              */ 00524000
*     I256C CHAR(256) BASED,                                       0258 00525000
*     I031F FIXED(31) BASED,                                       0258 00526000
*     I031P PTR(31) BASED,                                         0258 00527000
*     I015F FIXED(15) BASED,                                       0258 00528000
*     I015P PTR(15) BASED,                                         0258 00529000
*     I008P PTR(8) BASED,                                          0258 00530000
*     I001C CHAR(1) BASED;                                         0258 00531000
*   GENERATE NODEFS NOREFS DATA;                                   0259 00532000
*   END BLSTC                       /* BLRPEND(BLSTC)                */ 00533000
*                                                                  0260 00534000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00535000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00536000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00537000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00538000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00539000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00540000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00541000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00542000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00543000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00544000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00545000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00546000
*                                                                  0260 00547000
*       ;                                                          0260 00548000
@EL00001 L     @13,4(,@13)                                         0260 00549000
@EF00001 L     @00,@SIZDATD                                        0260 00550000
         LR    @01,@11                                             0260 00551000
         BLSUFRES R,LV=(0),A=(1)                                        00552000
@ER00001 LM    @14,@12,12(@13)                                     0260 00553000
         BR    @14                                                 0260 00554000
@DATA    DS    0H                                                       00555000
@CH01148 DC    H'49'                                                    00556000
@CH01149 DC    H'62'                                                    00557000
@DATD    DSECT                                                          00558000
         DS    0F                                                       00559000
@SA00001 DS    18F                                                      00560000
@PC00001 DS    3F                                                       00561000
@SA00002 DS    14F                                                      00562000
@AL00001 DS    2A                                                       00563000
BLSTC    CSECT                                                          00564000
         DS    0F                                                       00565000
@CF00050 DC    F'1'                                                     00566000
@CF00199 DC    F'64'                                                    00567000
@CF01109 DC    XL4'0000003F'                                            00568000
@CF01158 DC    XL4'0000FFFF'                                            00569000
@DATD    DSECT                                                          00570000
         DS    0D                                                       00571000
MVCLD    DS    CL16                                                     00572000
         ORG   MVCLD                                                    00573000
MVCLD1   DS    CL8                                                      00574000
         ORG   MVCLD1                                                   00575000
MVCLD1P  DS    AL4                                                      00576000
MVCLD12  DS    BL4                                                      00577000
         ORG   MVCLD12                                                  00578000
MVCLD1C  DS    CL1                                                      00579000
MVCLD1L  DS    FL3                                                      00580000
         ORG   MVCLD1+8                                                 00581000
MVCLD19  DS    0C                                                       00582000
         ORG   MVCLD+8                                                  00583000
MVCLD2   DS    CL8                                                      00584000
         ORG   MVCLD2                                                   00585000
MVCLD2P  DS    AL4                                                      00586000
MVCLD22  DS    BL4                                                      00587000
         ORG   MVCLD22                                                  00588000
MVCLD2C  DS    CL1                                                      00589000
MVCLD2L  DS    FL3                                                      00590000
         ORG   MVCLD2+8                                                 00591000
MVCLD29  DS    0C                                                       00592000
         ORG   MVCLD+16                                                 00593000
MVCLD99  DS    0C                                                       00594000
         ORG   MVCLD+16                                                 00595000
MCB      DS    CL81                                                     00596000
         ORG   MCB                                                      00597000
MCBL     DS    FL2                                                      00598000
@NM00090 DS    BL2                                                      00599000
MCBT     DS    CL77                                                     00600000
         ORG   MCBT                                                     00601000
MCBT0    DS    CL1                                                      00602000
MCBT1    DS    CL7                                                      00603000
         ORG   MCBT1                                                    00604000
MCBT10   DS    CL6                                                      00605000
MCBT11   DS    CL1                                                      00606000
         ORG   MCBT+8                                                   00607000
MCBT2    DS    CL3                                                      00608000
MCBT3    DS    CL64                                                     00609000
MCBT4    DS    CL2                                                      00610000
         ORG   MCB+81                                                   00611000
         DS    CL1                                                      00612000
MDB      DS    CL72                                                     00613000
         ORG   MDB                                                      00614000
MDBL     DS    FL2                                                      00615000
@NM00092 DS    BL2                                                      00616000
MDBT     DS    CL68                                                     00617000
         ORG   MDBT                                                     00618000
MDBT0    DS    CL1                                                      00619000
MDBT1    DS    CL7                                                      00620000
         ORG   MDBT1                                                    00621000
MDBT10   DS    CL6                                                      00622000
MDBT11   DS    CL1                                                      00623000
         ORG   MDBT+8                                                   00624000
MDBT2    DS    CL8                                                      00625000
MDBT3    DS    CL10                                                     00626000
MDBT4    DS    CL6                                                      00627000
MDBT5    DS    CL36                                                     00628000
         ORG   MDBT5                                                    00629000
MDBT50   DS    CL20                                                     00630000
MDBT51   DS    CL2                                                      00631000
MDBT52   DS    CL1                                                      00632000
MDBT53   DS    CL13                                                     00633000
         ORG   MDBT53                                                   00634000
MDBT530  DS    CL11                                                     00635000
MDBT531  DS    CL1                                                      00636000
MDBT532  DS    CL1                                                      00637000
         ORG   MDB+72                                                   00638000
BUFB     DS    CL64                                                     00639000
         ORG   BUFB                                                     00640000
BUFB1    DS    CL64                                                     00641000
         ORG   BUFB+64                                                  00642000
FLAG     DS    BL1                                                      00643000
         ORG   FLAG                                                     00644000
FLAGD    DS    BL1                                                      00645000
FLAGD1   EQU   FLAG+0                                                   00646000
FLAGEND  EQU   FLAG+0                                                   00647000
FLAGF    EQU   FLAG+0                                                   00648000
FLAGL    EQU   FLAG+0                                                   00649000
FLAGN    EQU   FLAG+0                                                   00650000
@NM00093 EQU   FLAG+0                                                   00651000
         ORG   FLAG+1                                                   00652000
         DS    CL1                                                      00653000
PTRBIT   DS    BL4                                                      00654000
PACKED   DS    BL8                                                      00655000
BLSTC    CSECT                                                          00656000
         DS    0F                                                       00657000
@SIZDATD DC    AL1(0)                                                   00658000
         DC    AL3(@ENDDATD-@DATD)                                      00659000
         DS    0D                                                       00660000
MCS      DS    CL81                                                     00661000
         ORG   MCS                                                      00662000
MCSL     DC    AL2(81)                                                  00663000
@NM00089 DC    X'0000'                                                  00664000
MCST     DS    CL77                                                     00665000
         ORG   MCST                                                     00666000
MCST0    DC    CL1' '                                                   00667000
MCST1    DS    CL7                                                      00668000
         ORG   MCST1                                                    00669000
MCST10   DC    CL6'000000'                                              00670000
MCST11   DC    CL1'.'                                                   00671000
         ORG   MCST+8                                                   00672000
MCST2    DC    CL3' | '                                                 00673000
MCST3    DC    CL64' '                                                  00674000
MCST4    DC    CL2' |'                                                  00675000
         ORG   MCS+81                                                   00676000
TDB      DS    CL26                                                     00677000
         ORG   TDB                                                      00678000
TDB1     DC    CL26'PERIODS AND/OR NONGRAPHICS'                         00679000
         ORG   TDB+26                                                   00680000
TDS      DS    CL13                                                     00681000
         ORG   TDS                                                      00682000
TDS1     DC    CL13'SAME AS ABOVE'                                      00683000
         ORG   TDS+13                                                   00684000
MDS      DS    CL72                                                     00685000
         ORG   MDS                                                      00686000
MDSL     DC    AL2(72)                                                  00687000
@NM00091 DC    X'0000'                                                  00688000
MDST     DS    CL68                                                     00689000
         ORG   MDST                                                     00690000
MDST0    DC    CL1' '                                                   00691000
MDST1    DS    CL7                                                      00692000
         ORG   MDST1                                                    00693000
MDST10   DC    CL6'000000'                                              00694000
MDST11   DC    CL1'.'                                                   00695000
         ORG   MDST+8                                                   00696000
MDST2    DC    CL8' LENGTH('                                            00697000
MDST3    DC    X'40202020202020202120'                                  00698000
MDST4    DC    CL6') ==> '                                              00699000
MDST5    DS    CL36                                                     00700000
         ORG   MDST5                                                    00701000
MDST50   DC    CL20'ALL BYTES CONTAIN X'''                              00702000
MDST51   DC    CL2' '                                                   00703000
MDST52   DC    CL1''''                                                  00704000
MDST53   DS    CL13                                                     00705000
         ORG   MDST53                                                   00706000
MDST530  DC    CL11', EBCDIC C'''                                       00707000
MDST531  DC    CL1' '                                                   00708000
MDST532  DC    CL1''''                                                  00709000
         ORG   MDS+72                                                   00710000
BUFS     DS    CL64                                                     00711000
         ORG   BUFS                                                     00712000
BUFS1    DC    CL64' '                                                  00713000
         ORG   BUFS+64                                                  00714000
@DATD    DSECT                                                          00715000
         SPACE 2                                                        00716000
*********************************************************************** 00717000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00718000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00719000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00720000
*********************************************************************** 00721000
         SPACE                                                          00722000
BLSTC    CSECT                                                          00723000
         ORG                                                            00724000
         DS    0D                                                       00725000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSTC+19)/20+7)/8)CL8'BLSTC'           00726000
@DATD    DSECT                                                          00727000
         DS    0H                                                       00728000
@DATD    DSECT                                                          00729000
         SPACE 2                                                        00730000
*********************************************************************** 00731000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00732000
*********************************************************************** 00733000
         SPACE                                                          00734000
         DS    0D                                                       00735000
@DATD    DSECT                                                          00736000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00737000
@ENDDATD EQU   *                                                        00738000
BLSTC    CSECT                                                          00739000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00740000
@01      EQU   01                                                       00741000
@02      EQU   02                                                       00742000
@03      EQU   03                                                       00743000
@04      EQU   04                                                       00744000
@05      EQU   05                                                       00745000
@06      EQU   06                                                       00746000
@07      EQU   07                                                       00747000
@08      EQU   08                                                       00748000
@09      EQU   09                                                       00749000
@10      EQU   10                                                       00750000
@11      EQU   11                                                       00751000
@12      EQU   12                                                       00752000
@13      EQU   13                                                       00753000
@14      EQU   14                                                       00754000
@15      EQU   15                                                       00755000
RETC     EQU   @10                                                      00756000
DUPLEN   EQU   @08                                                      00757000
LINELEN  EQU   @06                                                      00758000
LINEADDR EQU   @07                                                      00759000
R9       EQU   @09                                                      00760000
R0       EQU   @00                                                      00761000
R1       EQU   @01                                                      00762000
R2       EQU   @02                                                      00763000
R3       EQU   @03                                                      00764000
R4       EQU   @04                                                      00765000
R5       EQU   @05                                                      00766000
RB       EQU   @11                                                      00767000
RD       EQU   @13                                                      00768000
RE       EQU   @14                                                      00769000
RF       EQU   @15                                                      00770000
RA       EQU   @10                                                      00771000
RC       EQU   @12                                                      00772000
R6       EQU   @06                                                      00773000
R7       EQU   @07                                                      00774000
R8       EQU   @08                                                      00775000
ZZ1      EQU   0                                                        00776000
ZZ1ATTN  EQU   ZZ1+360                                                  00777000
ZZ1EVE   EQU   ZZ1ATTN+4                                                00778000
ZZ1EVEP  EQU   ZZ1EVE                                                   00779000
ZZ1F     EQU   ZZ1+368                                                  00780000
ZZ1TRHEX EQU   ZZ1+568                                                  00781000
ZZ1TREBC EQU   ZZ1+824                                                  00782000
ZZ1N     EQU   ZZ1+1116                                                 00783000
ZZ2      EQU   0                                                        00784000
ZZ2AMD   EQU   ZZ2                                                      00785000
@NM00025 EQU   ZZ2AMD+7                                                 00786000
ZZ2PRT   EQU   ZZ2+138                                                  00787000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 00788000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                00789000
ZZ2A     EQU   ZZ2+272                                                  00790000
ZZ2AF    EQU   ZZ2A+16                                                  00791000
ZZ2APID  EQU   ZZ2A+64                                                  00792000
ZZ2AD    EQU   ZZ2A+74                                                  00793000
ZZ2ADD   EQU   ZZ2AD                                                    00794000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 00795000
ZZ2ADM   EQU   ZZ2AD+46                                                 00796000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 00797000
ZZ2ADP   EQU   ZZ2AD+56                                                 00798000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 00799000
ZZ2AZZ6P EQU   ZZ2A+140                                                 00800000
ZZ2AQAS  EQU   ZZ2A+144                                                 00801000
ZZ2AQD   EQU   ZZ2A+160                                                 00802000
ZZ2AQDT  EQU   ZZ2AQD+10                                                00803000
ZZ2AQDF  EQU   ZZ2AQD+52                                                00804000
ZZ2STG   EQU   ZZ2+960                                                  00805000
ZZ2ALLOP EQU   ZZ2+992                                                  00806000
ZZ2FREEP EQU   ZZ2+996                                                  00807000
ZZ2FF19P EQU   ZZ2+1000                                                 00808000
ZZ2FRE1P EQU   ZZ2+1004                                                 00809000
ZZ2FF18P EQU   ZZ2+1008                                                 00810000
ZZ2DYNAP EQU   ZZ2+1012                                                 00811000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 00812000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 00813000
ZZ2STAIP EQU   ZZ2+1024                                                 00814000
ZZ2FF02P EQU   ZZ2+1028                                                 00815000
ZZ2GETLP EQU   ZZ2+1032                                                 00816000
ZZ2PARSP EQU   ZZ2+1036                                                 00817000
ZZ2PTGTP EQU   ZZ2+1040                                                 00818000
ZZ2PUTLP EQU   ZZ2+1044                                                 00819000
ZZ2SCANP EQU   ZZ2+1048                                                 00820000
ZZ2STCKP EQU   ZZ2+1052                                                 00821000
ZZ2TRMOP EQU   ZZ2+1064                                                 00822000
ZZ2TRMVP EQU   ZZ2+1068                                                 00823000
ZZ2PUTNP EQU   ZZ2+1084                                                 00824000
ZZ2TRMNP EQU   ZZ2+1088                                                 00825000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 00826000
ZZ2BVTP  EQU   ZZ2+1280                                                 00827000
ZZ2RVTP  EQU   ZZ2+1284                                                 00828000
ZZ2CPPL  EQU   ZZ2+1292                                                 00829000
ZZ2CPPLC EQU   ZZ2CPPL                                                  00830000
ZZ2ITR   EQU   ZZ2+2840                                                 00831000
ZZ2ITRE  EQU   ZZ2ITR+16                                                00832000
ZZ2ITSE  EQU   ZZ2+2864                                                 00833000
ZZ2ES    EQU   ZZ2+2872                                                 00834000
ZZ2AMDX  EQU   ZZ2+7160                                                 00835000
ZZ2AXO   EQU   ZZ2+7934                                                 00836000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 00837000
CMD      EQU   0                                                        00838000
CMDT     EQU   CMD+4                                                    00839000
PSCB     EQU   0                                                        00840000
PSCBATR1 EQU   PSCB+16                                                  00841000
ECT      EQU   0                                                        00842000
ECTSWS   EQU   ECT+28                                                   00843000
ECTSWS2  EQU   ECT+40                                                   00844000
ECTSWS21 EQU   ECTSWS2                                                  00845000
UPT      EQU   0                                                        00846000
UPTSWS   EQU   UPT+12                                                   00847000
SA       EQU   0                                                        00848000
SA1      EQU   SA                                                       00849000
SAR      EQU   SA+12                                                    00850000
SAR1     EQU   SAR+12                                                   00851000
BLSUMPK1 EQU   0                                                        00852000
BLSUPUTA EQU   0                                                        00853000
BVT      EQU   0                                                        00854000
BVTPUTLP EQU   BVT+4                                                    00855000
BVTPUTOP EQU   BVT+12                                                   00856000
BVTPUTTP EQU   BVT+16                                                   00857000
BVTPUTVP EQU   BVT+20                                                   00858000
BVTPUTAP EQU   BVT+24                                                   00859000
BVTPRTTP EQU   BVT+28                                                   00860000
BVTPRTAP EQU   BVT+32                                                   00861000
BVTPUTDP EQU   BVT+36                                                   00862000
BVTMONP  EQU   BVT+40                                                   00863000
BVTMON2P EQU   BVT+44                                                   00864000
BVTVSARP EQU   BVT+48                                                   00865000
BVTVSENP EQU   BVT+64                                                   00866000
BVTVSERP EQU   BVT+68                                                   00867000
BVTVSGEP EQU   BVT+72                                                   00868000
BVTVSGUP EQU   BVT+76                                                   00869000
BVTVSPOP EQU   BVT+80                                                   00870000
BVTVSPUP EQU   BVT+84                                                   00871000
BVTMPKNP EQU   BVT+104                                                  00872000
BVTMONLP EQU   BVT+108                                                  00873000
BVTPUTCP EQU   BVT+132                                                  00874000
BVTMPK1P EQU   BVT+136                                                  00875000
BVTZZ2RP EQU   BVT+140                                                  00876000
BVTPGMRP EQU   BVT+144                                                  00877000
BVTMONAP EQU   BVT+148                                                  00878000
BVTBLDDP EQU   BVT+152                                                  00879000
BVTBLDLP EQU   BVT+156                                                  00880000
BVTPGMCP EQU   BVT+160                                                  00881000
BVTPGMDP EQU   BVT+164                                                  00882000
BVTPGMLP EQU   BVT+168                                                  00883000
BVTMONCP EQU   BVT+180                                                  00884000
BVTMONDP EQU   BVT+184                                                  00885000
BVTMONTP EQU   BVT+188                                                  00886000
BVTPARIP EQU   BVT+192                                                  00887000
BVTPARUP EQU   BVT+196                                                  00888000
BVTPRTNP EQU   BVT+204                                                  00889000
BVTVSCRP EQU   BVT+208                                                  00890000
BVTVSMRP EQU   BVT+212                                                  00891000
BVTMONXP EQU   BVT+216                                                  00892000
BVTTRMAP EQU   BVT+228                                                  00893000
ZZ6      EQU   0                                                        00894000
ZZ6D     EQU   ZZ6+128                                                  00895000
ZZ6DD    EQU   ZZ6D+8                                                   00896000
ZZ6DDT   EQU   ZZ6DD+4                                                  00897000
ZZ6DQA   EQU   ZZ6D+68                                                  00898000
ZZ6DF    EQU   ZZ6D+92                                                  00899000
ZZ6B     EQU   ZZ6+768                                                  00900000
RVT      EQU   0                                                        00901000
RVTADDRP EQU   RVT                                                      00902000
RVTT01P  EQU   RVT+4                                                    00903000
RVTTAP   EQU   RVT+8                                                    00904000
RVTTBP   EQU   RVT+12                                                   00905000
RVTTFP   EQU   RVT+24                                                   00906000
RVTTYP   EQU   RVT+40                                                   00907000
RVTT02P  EQU   RVT+48                                                   00908000
RVTT03P  EQU   RVT+52                                                   00909000
RVTT04P  EQU   RVT+56                                                   00910000
RVTACCLP EQU   RVT+60                                                   00911000
RVTRACCP EQU   RVT+64                                                   00912000
RVTTLP   EQU   RVT+68                                                   00913000
RVTTMP   EQU   RVT+72                                                   00914000
RVTTUP   EQU   RVT+80                                                   00915000
RVTESGEP EQU   RVT+84                                                   00916000
RVTESGUP EQU   RVT+88                                                   00917000
RVTESARP EQU   RVT+92                                                   00918000
RVTRAARP EQU   RVT+96                                                   00919000
RVTRAGEP EQU   RVT+100                                                  00920000
RVTADDPP EQU   RVT+104                                                  00921000
RVTACCQP EQU   RVT+108                                                  00922000
RVTSAGUP EQU   RVT+124                                                  00923000
RVTSAGEP EQU   RVT+128                                                  00924000
RVTESCKP EQU   RVT+132                                                  00925000
RVTMSGAP EQU   RVT+136                                                  00926000
RVTMSGDP EQU   RVT+140                                                  00927000
RVTADDTP EQU   RVT+160                                                  00928000
RVTADDUP EQU   RVT+164                                                  00929000
RVTADD1P EQU   RVT+176                                                  00930000
RVTADD2P EQU   RVT+180                                                  00931000
RVTRSAGP EQU   RVT+184                                                  00932000
RVTMSGBP EQU   RVT+188                                                  00933000
RVTADDSP EQU   RVT+192                                                  00934000
RVTADD3P EQU   RVT+196                                                  00935000
RVTT05P  EQU   RVT+200                                                  00936000
RVTPADSP EQU   RVT+204                                                  00937000
RVTTRP   EQU   RVT+228                                                  00938000
RVTADD4P EQU   RVT+232                                                  00939000
RVTSAPCP EQU   RVT+236                                                  00940000
RVTSAARP EQU   RVT+240                                                  00941000
RVTSAGNP EQU   RVT+244                                                  00942000
RVTT06P  EQU   RVT+248                                                  00943000
RVTSAGCP EQU   RVT+252                                                  00944000
RVTSAGQP EQU   RVT+256                                                  00945000
RVTESGCP EQU   RVT+260                                                  00946000
RVTESGQP EQU   RVT+264                                                  00947000
RVTDUCKP EQU   RVT+276                                                  00948000
RVTDUCCP EQU   RVT+280                                                  00949000
I001C    EQU   0                                                        00950000
BLSRACC  EQU   0                                                        00951000
BLSRACCL EQU   0                                                        00952000
BLSRACCQ EQU   0                                                        00953000
BLSRADDP EQU   0                                                        00954000
BLSRADDR EQU   0                                                        00955000
BLSRADDS EQU   0                                                        00956000
BLSRADDT EQU   0                                                        00957000
BLSRADDU EQU   0                                                        00958000
BLSRADD1 EQU   0                                                        00959000
BLSRADD2 EQU   0                                                        00960000
BLSRADD3 EQU   0                                                        00961000
BLSRADD4 EQU   0                                                        00962000
BLSRDUCC EQU   0                                                        00963000
BLSRDUCK EQU   0                                                        00964000
BLSRESAR EQU   0                                                        00965000
BLSRESCK EQU   0                                                        00966000
BLSRESGC EQU   0                                                        00967000
BLSRESGE EQU   0                                                        00968000
BLSRESGQ EQU   0                                                        00969000
BLSRESGU EQU   0                                                        00970000
BLSRMSGA EQU   0                                                        00971000
BLSRMSGB EQU   0                                                        00972000
BLSRMSGD EQU   0                                                        00973000
BLSRPADS EQU   0                                                        00974000
BLSRRAAR EQU   0                                                        00975000
BLSRRAGE EQU   0                                                        00976000
BLSRSAAR EQU   0                                                        00977000
BLSRSAG  EQU   0                                                        00978000
BLSRSAGC EQU   0                                                        00979000
BLSRSAGE EQU   0                                                        00980000
BLSRSAGN EQU   0                                                        00981000
BLSRSAGQ EQU   0                                                        00982000
BLSRSAGU EQU   0                                                        00983000
BLSRSAPC EQU   0                                                        00984000
BLSTA    EQU   0                                                        00985000
BLSTB    EQU   0                                                        00986000
BLSTF    EQU   0                                                        00987000
BLSTL    EQU   0                                                        00988000
BLSTM    EQU   0                                                        00989000
BLSTR    EQU   0                                                        00990000
BLSTU    EQU   0                                                        00991000
BLSTY    EQU   0                                                        00992000
BLST01   EQU   0                                                        00993000
BLST02   EQU   0                                                        00994000
BLST03   EQU   0                                                        00995000
BLST04   EQU   0                                                        00996000
BLST05   EQU   0                                                        00997000
BLST06   EQU   0                                                        00998000
BLSUALLO EQU   0                                                        00999000
BLSUBLDD EQU   0                                                        01000000
BLSUBLDL EQU   0                                                        01001000
BLSUDYNA EQU   0                                                        01002000
BLSUFREE EQU   0                                                        01003000
BLSUFRE1 EQU   0                                                        01004000
BLSUMON  EQU   0                                                        01005000
BLSUMONA EQU   0                                                        01006000
BLSUMONC EQU   0                                                        01007000
BLSUMOND EQU   0                                                        01008000
BLSUMONL EQU   0                                                        01009000
BLSUMONT EQU   0                                                        01010000
BLSUMONX EQU   0                                                        01011000
BLSUMON2 EQU   0                                                        01012000
BLSUMPKN EQU   0                                                        01013000
BLSUPARI EQU   0                                                        01014000
BLSUPARU EQU   0                                                        01015000
BLSUPGMC EQU   0                                                        01016000
BLSUPGMD EQU   0                                                        01017000
BLSUPGML EQU   0                                                        01018000
BLSUPGMR EQU   0                                                        01019000
BLSUPRTA EQU   0                                                        01020000
BLSUPRTN EQU   0                                                        01021000
BLSUPRTT EQU   0                                                        01022000
BLSUPUTC EQU   0                                                        01023000
BLSUPUTD EQU   0                                                        01024000
BLSUPUTL EQU   0                                                        01025000
BLSUPUTN EQU   0                                                        01026000
BLSUPUTO EQU   0                                                        01027000
BLSUPUTT EQU   0                                                        01028000
BLSUPUTV EQU   0                                                        01029000
BLSUSTAI EQU   0                                                        01030000
BLSUTRMA EQU   0                                                        01031000
BLSUTRMN EQU   0                                                        01032000
BLSUTRMO EQU   0                                                        01033000
BLSUTRMV EQU   0                                                        01034000
BLSUVSAR EQU   0                                                        01035000
BLSUVSCR EQU   0                                                        01036000
BLSUVSEN EQU   0                                                        01037000
BLSUVSER EQU   0                                                        01038000
BLSUVSGE EQU   0                                                        01039000
BLSUVSGU EQU   0                                                        01040000
BLSUVSMR EQU   0                                                        01041000
BLSUVSPO EQU   0                                                        01042000
BLSUVSPU EQU   0                                                        01043000
BLSUZZ2C EQU   0                                                        01044000
BLSUZZ2D EQU   0                                                        01045000
BLSUZZ2R EQU   0                                                        01046000
IKJEFF02 EQU   0                                                        01047000
IKJEFF18 EQU   0                                                        01048000
IKJEFF19 EQU   0                                                        01049000
IKJGETL  EQU   0                                                        01050000
IKJPARS  EQU   0                                                        01051000
IKJPTGT  EQU   0                                                        01052000
IKJPUTL  EQU   0                                                        01053000
IKJSCAN  EQU   0                                                        01054000
IKJSTCK  EQU   0                                                        01055000
I008P    EQU   0                                                        01056000
I015F    EQU   0                                                        01057000
I015P    EQU   0                                                        01058000
I031F    EQU   0                                                        01059000
I031P    EQU   0                                                        01060000
I256C    EQU   0                                                        01061000
PZ2      EQU   0                                                        01062000
ESPA     EQU   0                                                        01063000
ESPAAS   EQU   ESPA+60                                                  01064000
ESPALAD  EQU   ESPA+76                                                  01065000
ESPAD    EQU   ESPA+80                                                  01066000
ESPADOF  EQU   ESPAD                                                    01067000
ESPADLE  EQU   ESPAD+4                                                  01068000
ESPADT   EQU   ESPAD+10                                                 01069000
ESPADIM  EQU   ESPAD+44                                                 01070000
ESPADF   EQU   ESPAD+52                                                 01071000
ESPAF    EQU   ESPA+161                                                 01072000
ESPAFS   EQU   ESPAF                                                    01073000
ESPAFC   EQU   ESPAF+1                                                  01074000
ESPAR    EQU   ESPA+180                                                 01075000
ESPART   EQU   ESPAR+2                                                  01076000
BLK      EQU   0                                                        01077000
CPPL     EQU   ZZ2CPPL                                                  01078000
CPPLUPT  EQU   CPPL+4                                                   01079000
CPPLPSCB EQU   CPPL+8                                                   01080000
CPPLECT  EQU   CPPL+12                                                  01081000
PTRPTR   EQU   PTRBIT                                                   01082000
@RC00176 EQU   @RC00174                                                 01540000
@ENDDATA EQU   *                                                        01541000
         END   BLSTC                                            DSKC437 01542000
