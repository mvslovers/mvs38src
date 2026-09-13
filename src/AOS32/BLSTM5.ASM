TM5      TITLE 'BLSTM5  --IPCS SERVICE ROUTINE TO DISPLAY STRUCTURED DA*00001000
               ATA      '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPLK                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSTM5   CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(16)                                             0002 00010000
         DC    C'BLSTM5    78.059'                                 0002 00011000
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
*   MM5B=MM5S;                      /* MESSAGE MM5 LITERAL TEXT      */ 00028000
         MVC   MM5B(133),MM5S                                      0138 00029000
*   MDB=MDS;                        /* MESSAGE MD LITERAL TEXT       */ 00030000
         MVC   MDB(80),MDS                                         0139 00031000
*   LINEADDR=ESPALAD+ESPADOF;       /* DUMP ADDRESS OF DATA LINE     */ 00032000
         L     @14,@PC00001+4                                      0140 00033000
         L     @10,ESPADOF(,@14)                                   0140 00034000
         L     LINEADDR,ESPALAD(,@14)                              0140 00035000
         ALR   LINEADDR,@10                                        0140 00036000
*   LINEOFF=ESPADOF;                /* OFFSET OF DATA LINE           */ 00037000
         LR    LINEOFF,@10                                         0141 00038000
*   LINELEN=ESPADLE*MAX(ESPADIM,1); /* LENGTH OF DATA LINE           */ 00039000
         L     LINELEN,ESPADIM(,@14)                               0142 00040000
         LA    @10,1                                               0142 00041000
         CLR   LINELEN,@10                                         0142 00042000
         BNL   *+6                                                      00043000
         LR    LINELEN,@10                                         0142 00044000
         LR    @01,LINELEN                                         0142 00045000
         M     @00,ESPADLE(,@14)                                   0142 00046000
         LR    LINELEN,@01                                         0142 00047000
*   MVCLD=MVCLD&&MVCLD;             /* INITIALIZE MVCL DESCRIPTOR    */ 00048000
         XC    MVCLD(16),MVCLD                                     0143 00049000
*   MVCLD1P=ADDR(BLK);              /* ->PARAMETER DATA BUFFER       */ 00050000
         L     @14,@PC00001+8                                      0144 00051000
         ST    @14,MVCLD1P                                         0144 00052000
*   MVCLD1L=LINELEN;                /* LENGTH OF DATA BUFFER         */ 00053000
         STCM  LINELEN,7,MVCLD1L                                   0145 00054000
*   IF LINELEN>LENGTH(BUF) THEN     /* MULTIPLE-LINE DISPLAY REQUIRED*/ 00055000
         LA    @14,32                                              0146 00056000
         CR    LINELEN,@14                                         0146 00057000
         BNH   @RF00146                                            0146 00058000
*     LINELEN=LENGTH(BUF)-(LINEADDR&BUFMASK2);/* ALIGN DISPLAY LINES */ 00059000
         LR    LINELEN,LINEADDR                                    0147 00060000
         N     LINELEN,@CF01172                                    0147 00061000
         SLR   @14,LINELEN                                         0147 00062000
         LR    LINELEN,@14                                         0147 00063000
*   ELSE                            /* SINGLE-LINE DISPLAY           */ 00064000
*     FLAGL='1'B;                   /* LEFT-JUSTIFY LINE             */ 00065000
         B     @RC00146                                            0148 00066000
@RF00146 OI    FLAGL,B'00010000'                                   0148 00067000
*   DUPLEN=0;                       /* LENGTH OF REPETITIVE AREA     */ 00068000
@RC00146 SLR   DUPLEN,DUPLEN                                       0149 00069000
*   RETC=ZZZFLAGI;                  /* RETURN CODE                   */ 00070000
*                                                                  0150 00071000
         SLR   @14,@14                                             0150 00072000
         ST    @14,RETC                                            0150 00073000
*   /*****************************************************************/ 00074000
*   /*                                                               */ 00075000
*   /* ITERATIVELY RETRIEVE AND DISPLAY DUMP DATA UNTIL THE REQUEST  */ 00076000
*   /* IS PROCESSED. STOP IF INTERRUPTED BY ATTN                     */ 00077000
*   /*                                                               */ 00078000
*   /*****************************************************************/ 00079000
*                                                                  0151 00080000
*   DO WHILE(FLAGEND='0'B);         /* LOOP PROCESSING THE DATA      */ 00081000
         B     @DE00151                                            0151 00082000
@DL00151 DS    0H                                                  0152 00083000
*     DO;                           /* BLRCNVPC(LINEADDR) FROM(POINTE   00084000
*                                      R)TO(CHARACTER)SET(MM5BT120)RE   00085000
*                                      MARK(OUTPUT LINE            0152 00086000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00087000
*                                                                  0152 00088000
*       /*************************************************************/ 00089000
*       /*                                                           */ 00090000
*       /* OUTPUT LINE ADDRESS                                       */ 00091000
*       /*                                                           */ 00092000
*       /*************************************************************/ 00093000
*                                                                  0153 00094000
*       PTRPTR=LINEADDR;            /* SOURCE TO BIT/POINTER       0153 00095000
*                                      INTERMEDIATE                  */ 00096000
         ST    LINEADDR,PTRPTR                                     0153 00097000
*       UNPK(MM5BT120(1:LENGTH(MM5BT120)-1),PTRBIT);/* BIT=>ZONED  0154 00098000
*                                      HEXADECIMAL                   */ 00099000
         UNPK  MM5BT120(5),PTRBIT(4)                               0154 00100000
*       MM5BT120(LENGTH(MM5BT120):LENGTH(MM5BT120))=PTRBIT(25:32);/*    00101000
*                                      FINAL ZONED HEXADECIMAL DIGIT */ 00102000
         MVC   MM5BT120+5(1),PTRBIT+3                              0155 00103000
*       TR(MM5BT120,ZZ1TRHEX);      /* ZONED HEXADECIMAL=>EBCDIC     */ 00104000
         L     @14,ZZ2ZZ1P(,R9)                                    0156 00105000
         TR    MM5BT120(6),ZZ1TRHEX(@14)                           0156 00106000
*     END;                          /* BLRCNVPC(LINEADDR) FROM(POINTE   00107000
*                                      R)TO(CHARACTER)SET(MM5BT120)RE   00108000
*                                      MARK(OUTPUT LINE            0157 00109000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00110000
*     DO;                           /* BLRCNVOC(LINEOFF) FROM(OFFSET)   00111000
*                                      TO(CHARACTER)SET(MM5BT10)REMAR   00112000
*                                      K(OFFSET OF DATA            0158 00113000
*                                      LINE)TR(ZZ1TRHEX)             */ 00114000
*                                                                  0158 00115000
*       /*************************************************************/ 00116000
*       /*                                                           */ 00117000
*       /* OFFSET OF DATA LINE                                       */ 00118000
*       /*                                                           */ 00119000
*       /*************************************************************/ 00120000
*                                                                  0159 00121000
*       IF LINEOFF>=0 THEN                                         0159 00122000
*                                                                  0159 00123000
         LTR   LINEOFF,LINEOFF                                     0159 00124000
         BM    @RF00159                                            0159 00125000
*         /***********************************************************/ 00126000
*         /*                                                         */ 00127000
*         /* POSITIVE OFFSET                                         */ 00128000
*         /*                                                         */ 00129000
*         /***********************************************************/ 00130000
*                                                                  0160 00131000
*         DO;                       /* POSITIVE OFFSET               */ 00132000
*           MM5BT10(1:1)='+';       /* POSITIVE OFFSET               */ 00133000
         MVI   MM5BT10,C'+'                                        0161 00134000
*           PTRPTR=LINEOFF;         /* POINTER/BIT INTERMEDIATE      */ 00135000
         ST    LINEOFF,PTRPTR                                      0162 00136000
*         END;                                                     0163 00137000
*       ELSE                                                       0164 00138000
*                                                                  0164 00139000
*         /***********************************************************/ 00140000
*         /*                                                         */ 00141000
*         /* NEGATIVE OFFSET                                         */ 00142000
*         /*                                                         */ 00143000
*         /***********************************************************/ 00144000
*                                                                  0164 00145000
*         DO;                       /* NEGATIVE OFFSET               */ 00146000
         B     @RC00159                                            0164 00147000
@RF00159 DS    0H                                                  0165 00148000
*           MM5BT10(1:1)='-';       /* NEGATIVE OFFSET               */ 00149000
         MVI   MM5BT10,C'-'                                        0165 00150000
*           IF LINEOFF='80000000'X THEN                            0166 00151000
         L     @14,@CF00070                                        0166 00152000
         CLR   LINEOFF,@14                                         0166 00153000
         BNE   @RF00166                                            0166 00154000
*             PTRPTR='80000000'X;   /* POINTER/BIT INTERMEDIATE      */ 00155000
         ST    @14,PTRPTR                                          0167 00156000
*           ELSE                                                   0168 00157000
*             PTRPTR=-LINEOFF;      /* POINTER/BIT INTERMEDIATE      */ 00158000
         B     @RC00166                                            0168 00159000
@RF00166 LCR   @14,LINEOFF                                         0168 00160000
         ST    @14,PTRPTR                                          0168 00161000
*         END;                                                     0169 00162000
@RC00166 DS    0H                                                  0170 00163000
*       UNPK(MM5BT10(2:LENGTH(MM5BT10)-1),PTRBIT);/* BIT=>ZONED    0170 00164000
*                                      HEXADECIMAL                   */ 00165000
@RC00159 UNPK  MM5BT10+1(5),PTRBIT(4)                              0170 00166000
*       MM5BT10(LENGTH(MM5BT10):LENGTH(MM5BT10))=PTRBIT(25:32);/*  0171 00167000
*                                      FINAL ZONED HEXADECIMAL DIGIT */ 00168000
         MVC   MM5BT10+6(1),PTRBIT+3                               0171 00169000
*       TR(MM5BT10(2:LENGTH(MM5BT10)),ZZ1TRHEX);/* ZONED           0172 00170000
*                                      HEXADECIMAL=>EBCDIC           */ 00171000
         L     @14,ZZ2ZZ1P(,R9)                                    0172 00172000
         TR    MM5BT10+1(6),ZZ1TRHEX(@14)                          0172 00173000
*     END;                          /* BLRCNVOC(LINEOFF) FROM(OFFSET)   00174000
*                                      TO(CHARACTER)SET(MM5BT10)REMAR   00175000
*                                      K(OFFSET OF DATA            0173 00176000
*                                      LINE)TR(ZZ1TRHEX)             */ 00177000
*     MVCLD2L=LINELEN;              /* DATA BYTES IN THIS LINE       */ 00178000
         STCM  LINELEN,7,MVCLD2L                                   0174 00179000
*     IF LINELEN=LENGTH(BUF) THEN   /* FULL DATA LINE                */ 00180000
*                                                                  0175 00181000
         C     LINELEN,@CF00069                                    0175 00182000
         BNE   @RF00175                                            0175 00183000
*       /*************************************************************/ 00184000
*       /*                                                           */ 00185000
*       /* FULL DATA LINE                                            */ 00186000
*       /*                                                           */ 00187000
*       /*************************************************************/ 00188000
*                                                                  0176 00189000
*       DO;                         /* FULL DATA LINE                */ 00190000
*         IF FLAGF='1'B THEN        /* LOCAL BUFFER FULL             */ 00191000
*                                                                  0177 00192000
         TM    FLAGF,B'00100000'                                   0177 00193000
         BNO   @RF00177                                            0177 00194000
*           /*********************************************************/ 00195000
*           /*                                                       */ 00196000
*           /* LOCAL BUFFER FULL                                     */ 00197000
*           /*                                                       */ 00198000
*           /*********************************************************/ 00199000
*                                                                  0178 00200000
*           DO;                     /* LOCAL BUFFER FULL             */ 00201000
*             RESPECIFY             /* BEFORE CLCL                   */ 00202000
*              (R0,                 /* ->BUF                         */ 00203000
*               R1,                 /* LENGTH(BUF)                   */ 00204000
*               RE) RESTRICTED;     /* ->PARAMETER BUFFER            */ 00205000
*             LM(RE,R1,MVCLD);      /* DESCRIBE TARGET DATA LINE     */ 00206000
         LM    RE,R1,MVCLD                                         0180 00207000
*             RF=R1;                /* DESCRIBE SOURCE DATA LINE     */ 00208000
         LR    RF,R1                                               0181 00209000
*             CLCL(R0,RE);          /* CHECK FOR REPETITIVE LINE     */ 00210000
         CLCL  R0,RE                                               0182 00211000
*             RESPECIFY             /* AFTER CLCL                    */ 00212000
*              (R0,                 /* DESTROYED                     */ 00213000
*               R1,                 /* DESTROYED                     */ 00214000
*               RE) UNRESTRICTED;   /* DESTROYED                     */ 00215000
*             BC(8,L010);           /* REPETITIVE LINE               */ 00216000
         BC    8,L010                                              0184 00217000
*             FLAGN='1'B;           /* NEW DATA                      */ 00218000
         OI    FLAGN,B'00001000'                                   0185 00219000
*             GO TO L020;           /* COMMON PROCESSING PATH        */ 00220000
         B     L020                                                0186 00221000
*L010:                              /* REPETITIVE LINE               */ 00222000
*             IF FLAGD='0'B THEN    /* FIRST LINE OF REPETITIVE DATA */ 00223000
*                                                                  0187 00224000
L010     TM    FLAGD,B'10000000'                                   0187 00225000
         BNZ   @RF00187                                            0187 00226000
*               /*****************************************************/ 00227000
*               /*                                                   */ 00228000
*               /* FIRST LINE OF REPETITIVE DATA                     */ 00229000
*               /*                                                   */ 00230000
*               /*****************************************************/ 00231000
*                                                                  0188 00232000
*               DO;                 /* FIRST LINE OF REPETITIVE DATA */ 00233000
*                 CALL E100;        /* BEGIN REPETITIVE DATA         */ 00234000
         BAL   @14,E100                                            0189 00235000
*                 MDBT5=TD;         /* LITERAL TEXT                  */ 00236000
         MVI   MDBT5+13,C' '                                       0190 00237000
         MVC   MDBT5+14(22),MDBT5+13                               0190 00238000
         MVC   MDBT5(13),TD                                        0190 00239000
*                 MDBL=LENGTH(MDB)-LENGTH(MDBT5)+LENGTH(TD);/* LENGTH*/ 00240000
         MVC   MDBL(2),@CH01216                                    0191 00241000
*               END;                                               0192 00242000
*             ELSE                  /* 2ND, 3RD, ... REPETITIVE LINE */ 00243000
*               DUPLEN=DUPLEN+LINELEN;/* LENGTH OF REPETITIVE AREA   */ 00244000
         B     @RC00187                                            0193 00245000
@RF00187 ALR   DUPLEN,LINELEN                                      0193 00246000
*L020:                              /* COMMON PROCESSING PATH        */ 00247000
*           END;                                                   0194 00248000
*         ELSE                      /* EMPTY OR PARTIALLY FILLED     */ 00249000
*                                                                  0195 00250000
*           /*********************************************************/ 00251000
*           /*                                                       */ 00252000
*           /* LOCAL BUFFER EMPTY OR PARTIALLY FILLED                */ 00253000
*           /*                                                       */ 00254000
*           /*********************************************************/ 00255000
*                                                                  0195 00256000
*           DO;                     /* EMPTY OR PARTIALLY FILLED     */ 00257000
         B     @RC00177                                            0195 00258000
@RF00177 DS    0H                                                  0196 00259000
*             MVCLD2P=ADDR(BUF);    /* ->INITIAL TARGET BYTE         */ 00260000
         LA    @14,BUF                                             0196 00261000
         ST    @14,MVCLD2P                                         0196 00262000
*             FLAGF='1'B;           /* FULL DATA LINE                */ 00263000
*             FLAGN='1'B;           /* NEW DATA LINE                 */ 00264000
         OI    FLAGF,B'00101000'                                   0198 00265000
*           END;                                                   0199 00266000
*       END;                                                       0200 00267000
*     ELSE                          /* PARTIAL DATA LINE             */ 00268000
*                                                                  0201 00269000
*       /*************************************************************/ 00270000
*       /*                                                           */ 00271000
*       /* PARTIAL DATA LINE                                         */ 00272000
*       /*                                                           */ 00273000
*       /*************************************************************/ 00274000
*                                                                  0201 00275000
*       DO;                         /* PARTIAL DATA LINE             */ 00276000
         B     @RC00175                                            0201 00277000
@RF00175 DS    0H                                                  0202 00278000
*         BUF=' ';                  /* PAD WITH EBCDIC BLANKS        */ 00279000
         MVI   BUF+1,C' '                                          0202 00280000
         MVC   BUF+2(30),BUF+1                                     0202 00281000
         MVI   BUF,C' '                                            0202 00282000
*         IF FLAGL='1'B THEN        /* LEFT-JUSTIFY DATA             */ 00283000
         TM    FLAGL,B'00010000'                                   0203 00284000
         BNO   @RF00203                                            0203 00285000
*           MVCLD2P=ADDR(BUF);      /* ->TARGET                      */ 00286000
         LA    @14,BUF                                             0204 00287000
         ST    @14,MVCLD2P                                         0204 00288000
*         ELSE                      /* RIGHT-JUSTIFY DATA            */ 00289000
*           MVCLD2P=ADDR(BUF)+LENGTH(BUF)-LINELEN;/* ->TARGET        */ 00290000
         B     @RC00203                                            0205 00291000
@RF00203 LA    @14,BUF                                             0205 00292000
         AL    @14,@CF00069                                        0205 00293000
         SLR   @14,LINELEN                                         0205 00294000
         ST    @14,MVCLD2P                                         0205 00295000
*         FLAGN='1'B;               /* NEW DATA LINE                 */ 00296000
@RC00203 OI    FLAGN,B'00001000'                                   0206 00297000
*       END;                                                       0207 00298000
*     RESPECIFY                     /* BEFORE MVCL                   */ 00299000
*      (R0,                         /* ->BUF                         */ 00300000
*       R1,                         /* LENGTH(BUF)                   */ 00301000
*       RE) RESTRICTED;             /* ->PARAMETER BUFFER            */ 00302000
@RC00175 DS    0H                                                  0209 00303000
*     LM(RE,R1,MVCLD);              /* DESCRIBE SOURCE AND TARGET    */ 00304000
         LM    RE,R1,MVCLD                                         0209 00305000
*     MVCL(R0,RE);                  /* MOVE DATA FOR ONE LINE        */ 00306000
         MVCL  R0,RE                                               0210 00307000
*     BC(4,L030);                   /* REQUEST NOT YET SATISFIED     */ 00308000
         BC    4,L030                                              0211 00309000
*     FLAGEND='1'B;                 /* REQUEST HAS BEEN SATISFIED    */ 00310000
         OI    FLAGEND,B'01000000'                                 0212 00311000
*     GO TO L040;                   /* COMMON PROCESSING PATH        */ 00312000
         B     L040                                                0213 00313000
*L030:                              /* REQUEST NOT YET SATISFIED     */ 00314000
*     STM(RE,RF,MVCLD1);            /* DESCRIBE DATA REMAINING       */ 00315000
L030     STM   RE,RF,MVCLD1                                        0214 00316000
*     RESPECIFY                     /* AFTER MVCL                    */ 00317000
*      (R0,                         /* DESTROYED                     */ 00318000
*       R1,                         /* DESTROYED                     */ 00319000
*       RE) UNRESTRICTED;           /* ->PARAMETER BUFFER+LINE LENGTH*/ 00320000
*L040:                              /* COMMON PROCESSING PATH        */ 00321000
*     IF FLAGD='1'B&(FLAGN='1'B×FLAGEND='1'B) THEN                 0216 00322000
*                                                                  0216 00323000
L040     TM    FLAGD,B'10000000'                                   0216 00324000
         BNO   @RF00216                                            0216 00325000
         TM    FLAGN,B'01001000'                                   0216 00326000
         BZ    @RF00216                                            0216 00327000
*       /*************************************************************/ 00328000
*       /*                                                           */ 00329000
*       /* END OF REPETITIVE DATA--SUMMARIZE                         */ 00330000
*       /*                                                           */ 00331000
*       /*************************************************************/ 00332000
*                                                                  0217 00333000
*       DO;                         /* END OF REPETITIVE DATA        */ 00334000
*         DO;                       /* BLRCNVUC(DUPLEN) FROM(UNSIGNED   00335000
*                                      BINARY)TO(CHARACTER)SET(MDBT3)   00336000
*                                      PATTERN('40202020202020202120'   00337000
*                                      X)OPTIONS(PATTERN IN        0218 00338000
*                                      PLACE)REMARK(LENGTH OF      0218 00339000
*                                      REPETITIVE DATA)              */ 00340000
*                                                                  0218 00341000
*           /*********************************************************/ 00342000
*           /*                                                       */ 00343000
*           /* LENGTH OF REPETITIVE DATA                             */ 00344000
*           /*                                                       */ 00345000
*           /*********************************************************/ 00346000
*                                                                  0219 00347000
*           CVD(DUPLEN,PACKED);     /* UNSIGNED BINARY=>PACKED     0219 00348000
*                                      DECIMAL                       */ 00349000
         CVD   DUPLEN,PACKED                                       0219 00350000
*           ED(MDBT3,PACKED(25:64));/* PACKED DECIMAL=>EBCDIC        */ 00351000
         ED    MDBT3(10),PACKED+3                                  0220 00352000
*         END;                      /* BLRCNVUC(DUPLEN) FROM(UNSIGNED   00353000
*                                      BINARY)TO(CHARACTER)SET(MDBT3)   00354000
*                                      PATTERN('40202020202020202120'   00355000
*                                      X)OPTIONS(PATTERN IN        0221 00356000
*                                      PLACE)REMARK(LENGTH OF      0221 00357000
*                                      REPETITIVE DATA)              */ 00358000
*         CALL BLSUMPK1(ZZ2,MDB);   /* REMOVE EXTRANEOUS BLANKS      */ 00359000
         ST    R9,@AL00001                                         0222 00360000
         LA    @14,MDB                                             0222 00361000
         ST    @14,@AL00001+4                                      0222 00362000
         L     @01,ZZ2BVTP(,R9)                                    0222 00363000
         L     @15,BVTMPK1P(,@01)                                  0222 00364000
         LA    @01,@AL00001                                        0222 00365000
         BALR  @14,@15                                             0222 00366000
*         CALL BLSUPUTA(ZZ2,MDB);   /* DISPLAY MESSAGE MD            */ 00367000
         ST    R9,@AL00001                                         0223 00368000
         LA    @14,MDB                                             0223 00369000
         ST    @14,@AL00001+4                                      0223 00370000
         L     @01,ZZ2BVTP(,R9)                                    0223 00371000
         L     @15,BVTPUTAP(,@01)                                  0223 00372000
         LA    @01,@AL00001                                        0223 00373000
         BALR  @14,@15                                             0223 00374000
*         FLAGD='0'B;               /* END OF REPETITIVE DATA        */ 00375000
         NI    FLAGD,B'01111111'                                   0224 00376000
*         MDB=MDS;                  /* MESSAGE MD LITERAL TEXT       */ 00377000
         MVC   MDB(80),MDS                                         0225 00378000
*       END;                                                       0226 00379000
*     IF FLAGEND='0'B&FLAGN='1'B&LINELEN>1 THEN                    0227 00380000
*                                                                  0227 00381000
@RF00216 TM    FLAGN,B'00001000'                                   0227 00382000
         BNO   @RF00227                                            0227 00383000
         TM    FLAGEND,B'01000000'                                 0227 00384000
         BNZ   @RF00227                                            0227 00385000
         C     LINELEN,@CF00050                                    0227 00386000
         BNH   @RF00227                                            0227 00387000
*       /*************************************************************/ 00388000
*       /*                                                           */ 00389000
*       /* CHECK FOR REPETITION OF A SINGLE CHARACTER VALUE          */ 00390000
*       /*                                                           */ 00391000
*       /*************************************************************/ 00392000
*                                                                  0228 00393000
*       DO;                         /* CHECK FOR REPETITION          */ 00394000
*         RESPECIFY                 /* BEFORE CLCL                   */ 00395000
*          (R0,                     /* IGNORED                       */ 00396000
*           R1,                     /* INITIAL CHARACTER OF DATA     */ 00397000
*           RE) RESTRICTED;         /* ->BUF                         */ 00398000
*         LM(RE,RF,MVCLD2);         /* DESCRIBE CURRENT DATA LINE    */ 00399000
         LM    RE,RF,MVCLD2                                        0230 00400000
*         MVCLD2C=RE->I001C;        /* PADDING CHARACTER             */ 00401000
         MVC   MVCLD2C(1),I001C(RE)                                0231 00402000
*         MVCLD2L=0;                /* CONSIDER ONLY PADDING CHAR.   */ 00403000
         SLR   @05,@05                                             0232 00404000
         STCM  @05,7,MVCLD2L                                       0232 00405000
*         LM(R0,R1,MVCLD2);         /* DESCRIBE REPETITIVE VALUE     */ 00406000
         LM    R0,R1,MVCLD2                                        0233 00407000
*         CLCL(RE,R0);              /* CHECK FOR REPETITIVE VALUE    */ 00408000
         CLCL  RE,R0                                               0234 00409000
*         RESPECIFY                 /* AFTER CLCL                    */ 00410000
*          (R0,                     /* DESTROYED                     */ 00411000
*           R1,                     /* DESTROYED                     */ 00412000
*           RE) UNRESTRICTED;       /* DESTROYED                     */ 00413000
*         BC(7,L050);               /* NEW DATA LINE                 */ 00414000
         BC    7,L050                                              0236 00415000
*         CALL E100;                /* BEGIN REPETITIVE DATA         */ 00416000
         BAL   @14,E100                                            0237 00417000
*         MDBT5=MDST5;              /* LITERAL TEXT                  */ 00418000
         MVC   MDBT5(36),MDST5                                     0238 00419000
*         DO;                       /* BLRCNVXC(MVCLD2C) FROM(BS)TO(C   00420000
*                                      HARACTER)SET(MDBT51)REMARK(REP   00421000
*                                      ETITIVE VALUE--HEXADECIMAL  0239 00422000
*                                      TRANSLATION)TR(ZZ1TRHEX)      */ 00423000
*                                                                  0239 00424000
*           /*********************************************************/ 00425000
*           /*                                                       */ 00426000
*           /* REPETITIVE VALUE--HEXADECIMAL TRANSLATION             */ 00427000
*           /*                                                       */ 00428000
*           /*********************************************************/ 00429000
*                                                                  0240 00430000
*           UNPK(MDBT51(1:LENGTH(MDBT51)-1),MVCLD2C);/* BIT=>ZONED 0240 00431000
*                                      HEXADECIMAL                   */ 00432000
         UNPK  MDBT51(1),MVCLD2C(1)                                0240 00433000
*           MDBT51(LENGTH(MDBT51):LENGTH(MDBT51))=MVCLD2C(LENGTH(  0241 00434000
*               MVCLD2C):LENGTH(MVCLD2C));/* FINAL ZONED HEXADECIMAL    00435000
*                                      DIGIT                         */ 00436000
         MVC   MDBT51+1(1),MVCLD2C                                 0241 00437000
*           TR(MDBT51,ZZ1TRHEX);    /* ZONED HEXADECIMAL=>EBCDIC     */ 00438000
         L     @14,ZZ2ZZ1P(,R9)                                    0242 00439000
         TR    MDBT51(2),ZZ1TRHEX(@14)                             0242 00440000
*         END;                      /* BLRCNVXC(MVCLD2C) FROM(BS)TO(C   00441000
*                                      HARACTER)SET(MDBT51)REMARK(REP   00442000
*                                      ETITIVE VALUE--HEXADECIMAL  0243 00443000
*                                      TRANSLATION)TR(ZZ1TRHEX)      */ 00444000
*         MDBT531=MVCLD2C;          /* EBCDIC REPETITIVE VALUE       */ 00445000
         MVC   MDBT531(1),MVCLD2C                                  0244 00446000
*         TR(MDBT531,ZZ1TREBC);     /* NONGRAPHIC==>BLANK            */ 00447000
         TR    MDBT531(1),ZZ1TREBC(@14)                            0245 00448000
*         IF MDBT531=MVCLD2C THEN   /* EBCDIC GRAPHIC                */ 00449000
         CLC   MDBT531(1),MVCLD2C                                  0246 00450000
         BNE   @RF00246                                            0246 00451000
*           MDBL=MDSL;              /* MESSAGE LENGTH                */ 00452000
         LH    @14,MDSL                                            0247 00453000
         N     @14,@CF01228                                        0247 00454000
         STH   @14,MDBL                                            0247 00455000
*         ELSE                      /* NONGRAPHIC                    */ 00456000
*           MDBL=LENGTH(MDB)-LENGTH(MDBT53);/* MESSAGE LENGTH        */ 00457000
         B     @RC00246                                            0248 00458000
@RF00246 MVC   MDBL(2),@CH01217                                    0248 00459000
*L050:                              /* COMMON PROCESSING PATH        */ 00460000
*         MVCLD2C='00'X;            /* RESET PADDING CHARACTER       */ 00461000
@RC00246 DS    0H                                                  0249 00462000
L050     MVI   MVCLD2C,X'00'                                       0249 00463000
*       END;                                                       0250 00464000
*     IF FLAGN='1'B THEN            /* NON-REPETITIVE DATA           */ 00465000
*                                                                  0251 00466000
@RF00227 TM    FLAGN,B'00001000'                                   0251 00467000
         BNO   @RF00251                                            0251 00468000
*       /*************************************************************/ 00469000
*       /*                                                           */ 00470000
*       /* NON-REPETITIVE DATA. DISPLAY IT                           */ 00471000
*       /*                                                           */ 00472000
*       /*************************************************************/ 00473000
*                                                                  0252 00474000
*       DO;                         /* NON-REPETITIVE DATA           */ 00475000
*                                                                  0252 00476000
*         /***********************************************************/ 00477000
*         /*                                                         */ 00478000
*         /* DISPLAY DATA AS BIT STRING                              */ 00479000
*         /*                                                         */ 00480000
*         /***********************************************************/ 00481000
*                                                                  0253 00482000
*         DO;                       /* BLRCNVXC(BUF1) FROM(BS)TO(CHAR   00483000
*                                      ACTER)SET(MM5BT300)REMARK(BIT    00484000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00485000
*                                                                  0253 00486000
*           /*********************************************************/ 00487000
*           /*                                                       */ 00488000
*           /* BIT STRING WORD 1                                     */ 00489000
*           /*                                                       */ 00490000
*           /*********************************************************/ 00491000
*                                                                  0254 00492000
*           UNPK(MM5BT300(1:LENGTH(MM5BT300)-1),BUF1);/* BIT=>ZONED     00493000
*                                      HEXADECIMAL                   */ 00494000
         UNPK  MM5BT300(7),BUF1(4)                                 0254 00495000
*           MM5BT300(LENGTH(MM5BT300):LENGTH(MM5BT300))=BUF1(LENGTH(    00496000
*               BUF1):LENGTH(BUF1));/* FINAL ZONED HEXADECIMAL DIGIT */ 00497000
         MVC   MM5BT300+7(1),BUF1+3                                0255 00498000
*           TR(MM5BT300,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00499000
         L     @14,ZZ2ZZ1P(,R9)                                    0256 00500000
         TR    MM5BT300(8),ZZ1TRHEX(@14)                           0256 00501000
*         END;                      /* BLRCNVXC(BUF1) FROM(BS)TO(CHAR   00502000
*                                      ACTER)SET(MM5BT300)REMARK(BIT    00503000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00504000
*         DO;                       /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00505000
*                                      ACTER)SET(MM5BT310)REMARK(BIT    00506000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00507000
*                                                                  0258 00508000
*           /*********************************************************/ 00509000
*           /*                                                       */ 00510000
*           /* BIT STRING WORD 2                                     */ 00511000
*           /*                                                       */ 00512000
*           /*********************************************************/ 00513000
*                                                                  0259 00514000
*           UNPK(MM5BT310(1:LENGTH(MM5BT310)-1),BUF2);/* BIT=>ZONED     00515000
*                                      HEXADECIMAL                   */ 00516000
         UNPK  MM5BT310(7),BUF2(4)                                 0259 00517000
*           MM5BT310(LENGTH(MM5BT310):LENGTH(MM5BT310))=BUF2(LENGTH(    00518000
*               BUF2):LENGTH(BUF2));/* FINAL ZONED HEXADECIMAL DIGIT */ 00519000
         MVC   MM5BT310+7(1),BUF2+3                                0260 00520000
*           TR(MM5BT310,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00521000
         TR    MM5BT310(8),ZZ1TRHEX(@14)                           0261 00522000
*         END;                      /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00523000
*                                      ACTER)SET(MM5BT310)REMARK(BIT    00524000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00525000
*         DO;                       /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00526000
*                                      ACTER)SET(MM5BT320)REMARK(BIT    00527000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00528000
*                                                                  0263 00529000
*           /*********************************************************/ 00530000
*           /*                                                       */ 00531000
*           /* BIT STRING WORD 3                                     */ 00532000
*           /*                                                       */ 00533000
*           /*********************************************************/ 00534000
*                                                                  0264 00535000
*           UNPK(MM5BT320(1:LENGTH(MM5BT320)-1),BUF3);/* BIT=>ZONED     00536000
*                                      HEXADECIMAL                   */ 00537000
         UNPK  MM5BT320(7),BUF3(4)                                 0264 00538000
*           MM5BT320(LENGTH(MM5BT320):LENGTH(MM5BT320))=BUF3(LENGTH(    00539000
*               BUF3):LENGTH(BUF3));/* FINAL ZONED HEXADECIMAL DIGIT */ 00540000
         MVC   MM5BT320+7(1),BUF3+3                                0265 00541000
*           TR(MM5BT320,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00542000
         TR    MM5BT320(8),ZZ1TRHEX(@14)                           0266 00543000
*         END;                      /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00544000
*                                      ACTER)SET(MM5BT320)REMARK(BIT    00545000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00546000
*         DO;                       /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00547000
*                                      ACTER)SET(MM5BT330)REMARK(BIT    00548000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00549000
*                                                                  0268 00550000
*           /*********************************************************/ 00551000
*           /*                                                       */ 00552000
*           /* BIT STRING WORD 4                                     */ 00553000
*           /*                                                       */ 00554000
*           /*********************************************************/ 00555000
*                                                                  0269 00556000
*           UNPK(MM5BT330(1:LENGTH(MM5BT330)-1),BUF4);/* BIT=>ZONED     00557000
*                                      HEXADECIMAL                   */ 00558000
         UNPK  MM5BT330(7),BUF4(4)                                 0269 00559000
*           MM5BT330(LENGTH(MM5BT330):LENGTH(MM5BT330))=BUF4(LENGTH(    00560000
*               BUF4):LENGTH(BUF4));/* FINAL ZONED HEXADECIMAL DIGIT */ 00561000
         MVC   MM5BT330+7(1),BUF4+3                                0270 00562000
*           TR(MM5BT330,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00563000
         TR    MM5BT330(8),ZZ1TRHEX(@14)                           0271 00564000
*         END;                      /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00565000
*                                      ACTER)SET(MM5BT330)REMARK(BIT    00566000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00567000
*         DO;                       /* BLRCNVXC(BUF5) FROM(BS)TO(CHAR   00568000
*                                      ACTER)SET(MM5BT340)REMARK(BIT    00569000
*                                      STRING WORD 5)TR(ZZ1TRHEX)    */ 00570000
*                                                                  0273 00571000
*           /*********************************************************/ 00572000
*           /*                                                       */ 00573000
*           /* BIT STRING WORD 5                                     */ 00574000
*           /*                                                       */ 00575000
*           /*********************************************************/ 00576000
*                                                                  0274 00577000
*           UNPK(MM5BT340(1:LENGTH(MM5BT340)-1),BUF5);/* BIT=>ZONED     00578000
*                                      HEXADECIMAL                   */ 00579000
         UNPK  MM5BT340(7),BUF5(4)                                 0274 00580000
*           MM5BT340(LENGTH(MM5BT340):LENGTH(MM5BT340))=BUF5(LENGTH(    00581000
*               BUF5):LENGTH(BUF5));/* FINAL ZONED HEXADECIMAL DIGIT */ 00582000
         MVC   MM5BT340+7(1),BUF5+3                                0275 00583000
*           TR(MM5BT340,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00584000
         TR    MM5BT340(8),ZZ1TRHEX(@14)                           0276 00585000
*         END;                      /* BLRCNVXC(BUF5) FROM(BS)TO(CHAR   00586000
*                                      ACTER)SET(MM5BT340)REMARK(BIT    00587000
*                                      STRING WORD 5)TR(ZZ1TRHEX)    */ 00588000
*         DO;                       /* BLRCNVXC(BUF6) FROM(BS)TO(CHAR   00589000
*                                      ACTER)SET(MM5BT350)REMARK(BIT    00590000
*                                      STRING WORD 6)TR(ZZ1TRHEX)    */ 00591000
*                                                                  0278 00592000
*           /*********************************************************/ 00593000
*           /*                                                       */ 00594000
*           /* BIT STRING WORD 6                                     */ 00595000
*           /*                                                       */ 00596000
*           /*********************************************************/ 00597000
*                                                                  0279 00598000
*           UNPK(MM5BT350(1:LENGTH(MM5BT350)-1),BUF6);/* BIT=>ZONED     00599000
*                                      HEXADECIMAL                   */ 00600000
         UNPK  MM5BT350(7),BUF6(4)                                 0279 00601000
*           MM5BT350(LENGTH(MM5BT350):LENGTH(MM5BT350))=BUF6(LENGTH(    00602000
*               BUF6):LENGTH(BUF6));/* FINAL ZONED HEXADECIMAL DIGIT */ 00603000
         MVC   MM5BT350+7(1),BUF6+3                                0280 00604000
*           TR(MM5BT350,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00605000
         TR    MM5BT350(8),ZZ1TRHEX(@14)                           0281 00606000
*         END;                      /* BLRCNVXC(BUF6) FROM(BS)TO(CHAR   00607000
*                                      ACTER)SET(MM5BT350)REMARK(BIT    00608000
*                                      STRING WORD 6)TR(ZZ1TRHEX)    */ 00609000
*         DO;                       /* BLRCNVXC(BUF7) FROM(BS)TO(CHAR   00610000
*                                      ACTER)SET(MM5BT360)REMARK(BIT    00611000
*                                      STRING WORD 7)TR(ZZ1TRHEX)    */ 00612000
*                                                                  0283 00613000
*           /*********************************************************/ 00614000
*           /*                                                       */ 00615000
*           /* BIT STRING WORD 7                                     */ 00616000
*           /*                                                       */ 00617000
*           /*********************************************************/ 00618000
*                                                                  0284 00619000
*           UNPK(MM5BT360(1:LENGTH(MM5BT360)-1),BUF7);/* BIT=>ZONED     00620000
*                                      HEXADECIMAL                   */ 00621000
         UNPK  MM5BT360(7),BUF7(4)                                 0284 00622000
*           MM5BT360(LENGTH(MM5BT360):LENGTH(MM5BT360))=BUF7(LENGTH(    00623000
*               BUF7):LENGTH(BUF7));/* FINAL ZONED HEXADECIMAL DIGIT */ 00624000
         MVC   MM5BT360+7(1),BUF7+3                                0285 00625000
*           TR(MM5BT360,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00626000
         TR    MM5BT360(8),ZZ1TRHEX(@14)                           0286 00627000
*         END;                      /* BLRCNVXC(BUF7) FROM(BS)TO(CHAR   00628000
*                                      ACTER)SET(MM5BT360)REMARK(BIT    00629000
*                                      STRING WORD 7)TR(ZZ1TRHEX)    */ 00630000
*         DO;                       /* BLRCNVXC(BUF8) FROM(BS)TO(CHAR   00631000
*                                      ACTER)SET(MM5BT37)REMARK(BIT     00632000
*                                      STRING WORD 8)TR(ZZ1TRHEX)    */ 00633000
*                                                                  0288 00634000
*           /*********************************************************/ 00635000
*           /*                                                       */ 00636000
*           /* BIT STRING WORD 8                                     */ 00637000
*           /*                                                       */ 00638000
*           /*********************************************************/ 00639000
*                                                                  0289 00640000
*           UNPK(MM5BT37(1:LENGTH(MM5BT37)-1),BUF8);/* BIT=>ZONED  0289 00641000
*                                      HEXADECIMAL                   */ 00642000
         UNPK  MM5BT37(7),BUF8(4)                                  0289 00643000
*           MM5BT37(LENGTH(MM5BT37):LENGTH(MM5BT37))=BUF8(LENGTH(BUF8): 00644000
*               LENGTH(BUF8));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00645000
         MVC   MM5BT37+7(1),BUF8+3                                 0290 00646000
*           TR(MM5BT37,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00647000
         TR    MM5BT37(8),ZZ1TRHEX(@14)                            0291 00648000
*         END;                      /* BLRCNVXC(BUF8) FROM(BS)TO(CHAR   00649000
*                                      ACTER)SET(MM5BT37)REMARK(BIT     00650000
*                                      STRING WORD 8)TR(ZZ1TRHEX)    */ 00651000
*         IF LINELEN<LENGTH(BUF) THEN/* BLANK IMPROPER OUTPUT        */ 00652000
*                                                                  0293 00653000
         LA    @14,32                                              0293 00654000
         CR    LINELEN,@14                                         0293 00655000
         BNL   @RF00293                                            0293 00656000
*           /*********************************************************/ 00657000
*           /*                                                       */ 00658000
*           /* MORE BIT STRING DATA FORMATTED THAN REQUESTED. BLANK  */ 00659000
*           /* THAT OUTPUT FORMATTED BUT NOT REQUESTED.              */ 00660000
*           /*                                                       */ 00661000
*           /*********************************************************/ 00662000
*                                                                  0294 00663000
*           DO;                     /* BLANK IMPROPER OUTPUT         */ 00664000
*             J=LENGTH(BUF)-LINELEN;/* EXCESS BYTES FORMATTED        */ 00665000
         SLR   @14,LINELEN                                         0295 00666000
         LR    J,@14                                               0295 00667000
*             J=J*9/4+J/16;         /* BLANKS TO REINSERT            */ 00668000
         LR    @01,J                                               0296 00669000
         M     @00,@CF01203                                        0296 00670000
         D     @00,@CF00047                                        0296 00671000
         LR    @14,J                                               0296 00672000
         SRL   @14,4                                               0296 00673000
         ALR   @01,@14                                             0296 00674000
         LR    J,@01                                               0296 00675000
*             IF FLAGL='1'B THEN    /* LEFT-JUSTIFY DATA             */ 00676000
         TM    FLAGL,B'00010000'                                   0297 00677000
         BNO   @RF00297                                            0297 00678000
*               MM5BT3(LENGTH(MM5BT3)+1-J:LENGTH(MM5BT3))=MM5ST3(LENGTH 00679000
*                   (MM5BT3)+1-J:LENGTH(MM5BT3));/* TRAILING BLANKS  */ 00680000
         LA    @14,73                                              0298 00681000
         SLR   @14,J                                               0298 00682000
         LA    @03,MM5BT3-1(@14)                                   0298 00683000
         LA    @05,72                                              0298 00684000
         SLR   @05,@14                                             0298 00685000
         LA    @01,MM5ST3-1(@14)                                   0298 00686000
         EX    @05,@SM01229                                        0298 00687000
*             ELSE                  /* RIGHT-JUSTIFY DATA            */ 00688000
*               MM5BT3(1:J)=MM5ST3(1:J);/* LEADING BLANKS            */ 00689000
         B     @RC00297                                            0299 00690000
@RF00297 LR    @14,J                                               0299 00691000
         BCTR  @14,0                                               0299 00692000
         EX    @14,@SM01231                                        0299 00693000
*           END;                                                   0300 00694000
*                                                                  0300 00695000
@RC00297 DS    0H                                                  0301 00696000
*         /***********************************************************/ 00697000
*         /*                                                         */ 00698000
*         /* DISPLAY DATA AS CHARACTER STRING AS WELL AS BIT STRING  */ 00699000
*         /*                                                         */ 00700000
*         /***********************************************************/ 00701000
*                                                                  0301 00702000
*         MM5BT5=BUF;               /* CHARACTER DATA                */ 00703000
@RF00293 MVC   MM5BT5(32),BUF                                      0301 00704000
*         TR(MM5BT5,ZZ1TREBC);      /* ELIMINATE NONGRAPHIC DATA     */ 00705000
         L     @14,ZZ2ZZ1P(,R9)                                    0302 00706000
         TR    MM5BT5(32),ZZ1TREBC(@14)                            0302 00707000
*         CALL BLSUPUTA(ZZ2,MM5B);  /* DISPLAY MESSAGE MM5           */ 00708000
         ST    R9,@AL00001                                         0303 00709000
         LA    @14,MM5B                                            0303 00710000
         ST    @14,@AL00001+4                                      0303 00711000
         L     @01,ZZ2BVTP(,R9)                                    0303 00712000
         L     @15,BVTPUTAP(,@01)                                  0303 00713000
         LA    @01,@AL00001                                        0303 00714000
         BALR  @14,@15                                             0303 00715000
*       END;                                                       0304 00716000
*     IF FLAGEND='0'B THEN          /* ANOTHER PASS REQUIRED         */ 00717000
*                                                                  0305 00718000
@RF00251 TM    FLAGEND,B'01000000'                                 0305 00719000
         BNZ   @RF00305                                            0305 00720000
*       /*************************************************************/ 00721000
*       /*                                                           */ 00722000
*       /* ANOTHER PASS WILL BE REQUIRED TO SATISFY THE REQUEST      */ 00723000
*       /*                                                           */ 00724000
*       /*************************************************************/ 00725000
*                                                                  0306 00726000
*       DO;                         /* ANOTHER PASS REQUIRED         */ 00727000
*         FLAGL='1'B;               /* LEFT-JUSTIFY DATA             */ 00728000
         OI    FLAGL,B'00010000'                                   0307 00729000
*         LINEADDR=LINEADDR+LINELEN;/* DUMP ADDRESS OF DATA LINE     */ 00730000
         ALR   LINEADDR,LINELEN                                    0308 00731000
*         LINEOFF=LINEOFF+LINELEN;  /* OFFSET OF DATA LINE           */ 00732000
         ALR   LINEOFF,LINELEN                                     0309 00733000
*         LINELEN=MIN(MVCLD1L,LENGTH(BUF));/* LENGTH OF DATA LINE    */ 00734000
         L     LINELEN,MVCLD1L-1                                   0310 00735000
         LA    LINELEN,0(,LINELEN)                                 0310 00736000
         LA    @14,32                                              0310 00737000
         CR    LINELEN,@14                                         0310 00738000
         BNH   *+6                                                      00739000
         LR    LINELEN,@14                                         0310 00740000
*         IF ZZ1EVEP='1'B THEN      /* ATTENTION INTERRUPTION        */ 00741000
*                                                                  0311 00742000
         L     @14,ZZ2ZZ1P(,R9)                                    0311 00743000
         TM    ZZ1EVEP(@14),B'01000000'                            0311 00744000
         BNO   @RF00311                                            0311 00745000
*           /*********************************************************/ 00746000
*           /*                                                       */ 00747000
*           /* ATTENTION INTERRUPTION--TERMINATE QUICKLY             */ 00748000
*           /*                                                       */ 00749000
*           /*********************************************************/ 00750000
*                                                                  0312 00751000
*           DO;                     /* ATTENTION INTERRUPTION        */ 00752000
*             RETC=MAX(RETC,ZZZFLAGS);/* SIGNAL INCOMPLETE           */ 00753000
         L     @14,RETC                                            0313 00754000
         LA    @05,12                                              0313 00755000
         CR    @14,@05                                             0313 00756000
         BNL   *+6                                                      00757000
         LR    @14,@05                                             0313 00758000
         ST    @14,RETC                                            0313 00759000
*             FLAGEND='1'B;         /* TERMINATE QUICKLY             */ 00760000
         OI    FLAGEND,B'01000000'                                 0314 00761000
*           END;                                                   0315 00762000
*       END;                                                       0316 00763000
@RF00311 DS    0H                                                  0317 00764000
*   END;                                                           0317 00765000
@RF00305 DS    0H                                                  0317 00766000
@DE00151 TM    FLAGEND,B'01000000'                                 0317 00767000
         BZ    @DL00151                                            0317 00768000
*   RETURN CODE(RETC);                                             0318 00769000
*                                                                  0318 00770000
         L     @10,RETC                                            0318 00771000
         L     @13,4(,@13)                                         0318 00772000
         L     @00,@SIZDATD                                        0318 00773000
         LR    @01,@11                                             0318 00774000
         BLSUFRES R,LV=(0),A=(1)                                        00775000
         LR    @15,@10                                             0318 00776000
         L     @14,12(,@13)                                        0318 00777000
         LM    @00,@12,20(@13)                                     0318 00778000
         BR    @14                                                 0318 00779000
*/********************************************************************/ 00780000
*/*                                                                  */ 00781000
*/* E100--BEGIN REDUNDANT DATA PROCESSING                            */ 00782000
*/*                                                                  */ 00783000
*/********************************************************************/ 00784000
*                                                                  0319 00785000
*E100:                              /* BEGIN REDUNDANT DATA          */ 00786000
*   PROCEDURE;                                                     0319 00787000
E100     STM   @14,@09,12(@13)                                     0319 00788000
         STM   @11,@12,64(@13)                                     0319 00789000
*   DUPLEN=LINELEN;                 /* LENGTH OF REPETITIVE AREA     */ 00790000
         LR    DUPLEN,LINELEN                                      0320 00791000
*   MDBT10=MM5BT10;                 /* REPETITIVE DATA OFFSET        */ 00792000
         MVC   MDBT10(7),MM5BT10                                   0321 00793000
*   MDBT120=MM5BT120;               /* REPETITIVE DATA ADDRESS       */ 00794000
         MVC   MDBT120(6),MM5BT120                                 0322 00795000
*   FLAGD='1'B;                     /* DUPLICATE DATA PROCESSING     */ 00796000
*   FLAGN='0'B;                     /* DATA LINE NOT NEW             */ 00797000
         OI    FLAGD,B'10000000'                                   0324 00798000
         NI    FLAGN,B'11110111'                                   0324 00799000
*   RETURN;                                                        0325 00800000
@EL00002 DS    0H                                                  0325 00801000
@EF00002 DS    0H                                                  0325 00802000
@ER00002 LM    @14,@09,12(@13)                                     0325 00803000
         LM    @11,@12,64(@13)                                     0325 00804000
         BR    @14                                                 0325 00805000
*   END E100;                                                      0326 00806000
*                                                                  0326 00807000
*/*BLSTPEND--DISPLAY FORMATTER                                       */ 00808000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00809000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00810000
*                                                                  0327 00811000
*   DECLARE                         /* DATA FOR AHB MACROS           */ 00812000
*     PTRBIT BIT(32) BOUNDARY(WORD),/* DATA CONVERSION WORK AREA FOR    00813000
*                                      POINTER DATA                  */ 00814000
*     PTRPTR POINTER DEFINED(PTRBIT),/* DATA CONVERSION WORK AREA FOR   00815000
*                                      POINTER DATA                  */ 00816000
*     PACKED BIT(64) BOUNDARY(DWORD);/* DATA CONVERSION WORK AREA    */ 00817000
*   DECLARE                         /* COMMON VARIABLES              */ 00818000
*     I256C CHAR(256) BASED,                                       0328 00819000
*     I031F FIXED(31) BASED,                                       0328 00820000
*     I031P PTR(31) BASED,                                         0328 00821000
*     I015F FIXED(15) BASED,                                       0328 00822000
*     I015P PTR(15) BASED,                                         0328 00823000
*     I008P PTR(8) BASED,                                          0328 00824000
*     I001C CHAR(1) BASED;                                         0328 00825000
*   GENERATE NODEFS NOREFS DATA;                                   0329 00826000
*   END BLSTM5                      /* BLRPEND(BLSTM5)               */ 00827000
*                                                                  0330 00828000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00829000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00830000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00831000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00832000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00833000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00834000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00835000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00836000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00837000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00838000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00839000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00840000
*                                                                  0330 00841000
*       ;                                                          0330 00842000
@EL00001 L     @13,4(,@13)                                         0330 00843000
@EF00001 L     @00,@SIZDATD                                        0330 00844000
         LR    @01,@11                                             0330 00845000
         BLSUFRES R,LV=(0),A=(1)                                        00846000
@ER00001 LM    @14,@12,12(@13)                                     0330 00847000
         BR    @14                                                 0330 00848000
@DATA    DS    0H                                                       00849000
@CH01216 DC    H'57'                                                    00850000
@CH01217 DC    H'67'                                                    00851000
@SM01229 MVC   0(0,@03),0(@01)                                          00852000
@SM01231 MVC   MM5BT3(0),MM5ST3                                         00853000
@DATD    DSECT                                                          00854000
         DS    0F                                                       00855000
@SA00001 DS    18F                                                      00856000
@PC00001 DS    3F                                                       00857000
@AL00001 DS    2A                                                       00858000
BLSTM5   CSECT                                                          00859000
         DS    0F                                                       00860000
@CF00050 DC    F'1'                                                     00861000
@CF00047 DC    F'4'                                                     00862000
@CF01203 DC    F'9'                                                     00863000
@CF00069 DC    F'32'                                                    00864000
@CF00070 DC    XL4'80000000'                                            00865000
@CF01172 DC    XL4'0000001F'                                            00866000
@CF01228 DC    XL4'0000FFFF'                                            00867000
@DATD    DSECT                                                          00868000
         DS    0D                                                       00869000
RETC     DS    F                                                        00870000
MVCLD    DS    CL16                                                     00871000
         ORG   MVCLD                                                    00872000
MVCLD1   DS    CL8                                                      00873000
         ORG   MVCLD1                                                   00874000
MVCLD1P  DS    AL4                                                      00875000
MVCLD12  DS    BL4                                                      00876000
         ORG   MVCLD12                                                  00877000
MVCLD1C  DS    CL1                                                      00878000
MVCLD1L  DS    FL3                                                      00879000
         ORG   MVCLD1+8                                                 00880000
MVCLD19  DS    0C                                                       00881000
         ORG   MVCLD+8                                                  00882000
MVCLD2   DS    CL8                                                      00883000
         ORG   MVCLD2                                                   00884000
MVCLD2P  DS    AL4                                                      00885000
MVCLD22  DS    BL4                                                      00886000
         ORG   MVCLD22                                                  00887000
MVCLD2C  DS    CL1                                                      00888000
MVCLD2L  DS    FL3                                                      00889000
         ORG   MVCLD2+8                                                 00890000
MVCLD29  DS    0C                                                       00891000
         ORG   MVCLD+16                                                 00892000
MVCLD99  DS    0C                                                       00893000
         ORG   MVCLD+16                                                 00894000
MM5B     DS    CL133                                                    00895000
         ORG   MM5B                                                     00896000
MM5BL    DS    FL2                                                      00897000
@NM00090 DS    BL2                                                      00898000
MM5BT    DS    CL129                                                    00899000
         ORG   MM5BT                                                    00900000
MM5BT0   DS    CL1                                                      00901000
MM5BT1   DS    CL15                                                     00902000
         ORG   MM5BT1                                                   00903000
MM5BT10  DS    CL7                                                      00904000
MM5BT11  DS    CL1                                                      00905000
MM5BT12  DS    CL7                                                      00906000
         ORG   MM5BT12                                                  00907000
MM5BT120 DS    CL6                                                      00908000
MM5BT121 DS    CL1                                                      00909000
         ORG   MM5BT+16                                                 00910000
MM5BT2   DS    CL3                                                      00911000
MM5BT3   DS    CL72                                                     00912000
         ORG   MM5BT3                                                   00913000
MM5BT30  DS    CL9                                                      00914000
         ORG   MM5BT30                                                  00915000
MM5BT300 DS    CL8                                                      00916000
MM5BT301 DS    CL1                                                      00917000
         ORG   MM5BT3+9                                                 00918000
MM5BT31  DS    CL9                                                      00919000
         ORG   MM5BT31                                                  00920000
MM5BT310 DS    CL8                                                      00921000
MM5BT311 DS    CL1                                                      00922000
         ORG   MM5BT3+18                                                00923000
MM5BT32  DS    CL9                                                      00924000
         ORG   MM5BT32                                                  00925000
MM5BT320 DS    CL8                                                      00926000
MM5BT321 DS    CL1                                                      00927000
         ORG   MM5BT3+27                                                00928000
MM5BT33  DS    CL10                                                     00929000
         ORG   MM5BT33                                                  00930000
MM5BT330 DS    CL8                                                      00931000
MM5BT331 DS    CL2                                                      00932000
         ORG   MM5BT3+37                                                00933000
MM5BT34  DS    CL9                                                      00934000
         ORG   MM5BT34                                                  00935000
MM5BT340 DS    CL8                                                      00936000
MM5BT341 DS    CL1                                                      00937000
         ORG   MM5BT3+46                                                00938000
MM5BT35  DS    CL9                                                      00939000
         ORG   MM5BT35                                                  00940000
MM5BT350 DS    CL8                                                      00941000
MM5BT351 DS    CL1                                                      00942000
         ORG   MM5BT3+55                                                00943000
MM5BT36  DS    CL9                                                      00944000
         ORG   MM5BT36                                                  00945000
MM5BT360 DS    CL8                                                      00946000
MM5BT361 DS    CL1                                                      00947000
         ORG   MM5BT3+64                                                00948000
MM5BT37  DS    CL8                                                      00949000
         ORG   MM5BT+91                                                 00950000
MM5BT4   DS    CL4                                                      00951000
MM5BT5   DS    CL32                                                     00952000
MM5BT6   DS    CL2                                                      00953000
         ORG   MM5B+133                                                 00954000
         DS    CL1                                                      00955000
MDB      DS    CL80                                                     00956000
         ORG   MDB                                                      00957000
MDBL     DS    FL2                                                      00958000
@NM00092 DS    BL2                                                      00959000
MDBT     DS    CL76                                                     00960000
         ORG   MDBT                                                     00961000
MDBT0    DS    CL1                                                      00962000
MDBT1    DS    CL15                                                     00963000
         ORG   MDBT1                                                    00964000
MDBT10   DS    CL7                                                      00965000
MDBT11   DS    CL1                                                      00966000
MDBT12   DS    CL7                                                      00967000
         ORG   MDBT12                                                   00968000
MDBT120  DS    CL6                                                      00969000
MDBT121  DS    CL1                                                      00970000
         ORG   MDBT+16                                                  00971000
MDBT2    DS    CL8                                                      00972000
MDBT3    DS    CL10                                                     00973000
MDBT4    DS    CL6                                                      00974000
MDBT5    DS    CL36                                                     00975000
         ORG   MDBT5                                                    00976000
MDBT50   DS    CL20                                                     00977000
MDBT51   DS    CL2                                                      00978000
MDBT52   DS    CL1                                                      00979000
MDBT53   DS    CL13                                                     00980000
         ORG   MDBT53                                                   00981000
MDBT530  DS    CL11                                                     00982000
MDBT531  DS    CL1                                                      00983000
MDBT532  DS    CL1                                                      00984000
         ORG   MDB+80                                                   00985000
BUF      DS    CL32                                                     00986000
         ORG   BUF                                                      00987000
BUF1     DS    CL4                                                      00988000
BUF2     DS    CL4                                                      00989000
BUF3     DS    CL4                                                      00990000
BUF4     DS    CL4                                                      00991000
BUF5     DS    CL4                                                      00992000
BUF6     DS    CL4                                                      00993000
BUF7     DS    CL4                                                      00994000
BUF8     DS    CL4                                                      00995000
         ORG   BUF+32                                                   00996000
FLAG     DS    BL1                                                      00997000
         ORG   FLAG                                                     00998000
FLAGD    DS    BL1                                                      00999000
FLAGEND  EQU   FLAG+0                                                   01000000
FLAGF    EQU   FLAG+0                                                   01001000
FLAGL    EQU   FLAG+0                                                   01002000
FLAGN    EQU   FLAG+0                                                   01003000
@NM00093 EQU   FLAG+0                                                   01004000
         ORG   FLAG+1                                                   01005000
         DS    CL1                                                      01006000
PTRBIT   DS    BL4                                                      01007000
PACKED   DS    BL8                                                      01008000
BLSTM5   CSECT                                                          01009000
         DS    0F                                                       01010000
@SIZDATD DC    AL1(0)                                                   01011000
         DC    AL3(@ENDDATD-@DATD)                                      01012000
         DS    0D                                                       01013000
MM5S     DS    CL133                                                    01014000
         ORG   MM5S                                                     01015000
MM5SL    DC    AL2(133)                                                 01016000
@NM00089 DC    X'0000'                                                  01017000
MM5ST    DS    CL129                                                    01018000
         ORG   MM5ST                                                    01019000
MM5ST0   DC    CL1' '                                                   01020000
MM5ST1   DS    CL15                                                     01021000
         ORG   MM5ST1                                                   01022000
MM5ST10  DC    CL7'+000000'                                             01023000
MM5ST11  DC    CL1' '                                                   01024000
MM5ST12  DS    CL7                                                      01025000
         ORG   MM5ST12                                                  01026000
MM5ST120 DC    CL6'000000'                                              01027000
MM5ST121 DC    CL1'.'                                                   01028000
         ORG   MM5ST+16                                                 01029000
MM5ST2   DC    CL3' | '                                                 01030000
MM5ST3   DS    CL72                                                     01031000
         ORG   MM5ST3                                                   01032000
MM5ST30  DS    CL9                                                      01033000
         ORG   MM5ST30                                                  01034000
MM5ST300 DC    CL8' '                                                   01035000
MM5ST301 DC    CL1' '                                                   01036000
         ORG   MM5ST3+9                                                 01037000
MM5ST31  DS    CL9                                                      01038000
         ORG   MM5ST31                                                  01039000
MM5ST310 DC    CL8' '                                                   01040000
MM5ST311 DC    CL1' '                                                   01041000
         ORG   MM5ST3+18                                                01042000
MM5ST32  DS    CL9                                                      01043000
         ORG   MM5ST32                                                  01044000
MM5ST320 DC    CL8' '                                                   01045000
MM5ST321 DC    CL1' '                                                   01046000
         ORG   MM5ST3+27                                                01047000
MM5ST33  DS    CL10                                                     01048000
         ORG   MM5ST33                                                  01049000
MM5ST330 DC    CL8' '                                                   01050000
MM5ST331 DC    CL2' '                                                   01051000
         ORG   MM5ST3+37                                                01052000
MM5ST34  DS    CL9                                                      01053000
         ORG   MM5ST34                                                  01054000
MM5ST340 DC    CL8' '                                                   01055000
MM5ST341 DC    CL1' '                                                   01056000
         ORG   MM5ST3+46                                                01057000
MM5ST35  DS    CL9                                                      01058000
         ORG   MM5ST35                                                  01059000
MM5ST350 DC    CL8' '                                                   01060000
MM5ST351 DC    CL1' '                                                   01061000
         ORG   MM5ST3+55                                                01062000
MM5ST36  DS    CL9                                                      01063000
         ORG   MM5ST36                                                  01064000
MM5ST360 DC    CL8' '                                                   01065000
MM5ST361 DC    CL1' '                                                   01066000
         ORG   MM5ST3+64                                                01067000
MM5ST37  DC    CL8' '                                                   01068000
         ORG   MM5ST+91                                                 01069000
MM5ST4   DC    CL4' || '                                                01070000
MM5ST5   DC    CL32' '                                                  01071000
MM5ST6   DC    CL2' |'                                                  01072000
         ORG   MM5S+133                                                 01073000
TD       DS    CL13                                                     01074000
         ORG   TD                                                       01075000
TD1      DC    CL13'SAME AS ABOVE'                                      01076000
         ORG   TD+13                                                    01077000
MDS      DS    CL80                                                     01078000
         ORG   MDS                                                      01079000
MDSL     DC    AL2(80)                                                  01080000
@NM00091 DC    X'0000'                                                  01081000
MDST     DS    CL76                                                     01082000
         ORG   MDST                                                     01083000
MDST0    DC    CL1' '                                                   01084000
MDST1    DS    CL15                                                     01085000
         ORG   MDST1                                                    01086000
MDST10   DC    CL7'+000000'                                             01087000
MDST11   DC    CL1' '                                                   01088000
MDST12   DS    CL7                                                      01089000
         ORG   MDST12                                                   01090000
MDST120  DC    CL6'000000'                                              01091000
MDST121  DC    CL1'.'                                                   01092000
         ORG   MDST+16                                                  01093000
MDST2    DC    CL8' LENGTH('                                            01094000
MDST3    DC    X'40202020202020202120'                                  01095000
MDST4    DC    CL6') ==> '                                              01096000
MDST5    DS    CL36                                                     01097000
         ORG   MDST5                                                    01098000
MDST50   DC    CL20'ALL BYTES CONTAIN X'''                              01099000
MDST51   DC    CL2' '                                                   01100000
MDST52   DC    CL1''''                                                  01101000
MDST53   DS    CL13                                                     01102000
         ORG   MDST53                                                   01103000
MDST530  DC    CL11', EBCDIC C'''                                       01104000
MDST531  DC    CL1' '                                                   01105000
MDST532  DC    CL1''''                                                  01106000
         ORG   MDS+80                                                   01107000
@DATD    DSECT                                                          01108000
         SPACE 2                                                        01109000
*********************************************************************** 01110000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 01111000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 01112000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 01113000
*********************************************************************** 01114000
         SPACE                                                          01115000
BLSTM5   CSECT                                                          01116000
         ORG                                                            01117000
         DS    0D                                                       01118000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSTM5+19)/20+7)/8)CL8'BLSTM5'         01119000
@DATD    DSECT                                                          01120000
         DS    0H                                                       01121000
@DATD    DSECT                                                          01122000
         SPACE 2                                                        01123000
*********************************************************************** 01124000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 01125000
*********************************************************************** 01126000
         SPACE                                                          01127000
         DS    0D                                                       01128000
@DATD    DSECT                                                          01129000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                01130000
@ENDDATD EQU   *                                                        01131000
BLSTM5   CSECT                                                          01132000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       01133000
@01      EQU   01                                                       01134000
@02      EQU   02                                                       01135000
@03      EQU   03                                                       01136000
@04      EQU   04                                                       01137000
@05      EQU   05                                                       01138000
@06      EQU   06                                                       01139000
@07      EQU   07                                                       01140000
@08      EQU   08                                                       01141000
@09      EQU   09                                                       01142000
@10      EQU   10                                                       01143000
@11      EQU   11                                                       01144000
@12      EQU   12                                                       01145000
@13      EQU   13                                                       01146000
@14      EQU   14                                                       01147000
@15      EQU   15                                                       01148000
DUPLEN   EQU   @10                                                      01149000
LINEOFF  EQU   @07                                                      01150000
LINELEN  EQU   @06                                                      01151000
LINEADDR EQU   @08                                                      01152000
J        EQU   @02                                                      01153000
R9       EQU   @09                                                      01154000
R0       EQU   @00                                                      01155000
R1       EQU   @01                                                      01156000
R2       EQU   @02                                                      01157000
R3       EQU   @03                                                      01158000
R4       EQU   @04                                                      01159000
R5       EQU   @05                                                      01160000
RB       EQU   @11                                                      01161000
RD       EQU   @13                                                      01162000
RE       EQU   @14                                                      01163000
RF       EQU   @15                                                      01164000
RA       EQU   @10                                                      01165000
RC       EQU   @12                                                      01166000
R6       EQU   @06                                                      01167000
R7       EQU   @07                                                      01168000
R8       EQU   @08                                                      01169000
ZZ1      EQU   0                                                        01170000
ZZ1ATTN  EQU   ZZ1+360                                                  01171000
ZZ1EVE   EQU   ZZ1ATTN+4                                                01172000
ZZ1EVEP  EQU   ZZ1EVE                                                   01173000
ZZ1F     EQU   ZZ1+368                                                  01174000
ZZ1TRHEX EQU   ZZ1+568                                                  01175000
ZZ1TREBC EQU   ZZ1+824                                                  01176000
ZZ1N     EQU   ZZ1+1116                                                 01177000
ZZ2      EQU   0                                                        01178000
ZZ2AMD   EQU   ZZ2                                                      01179000
@NM00025 EQU   ZZ2AMD+7                                                 01180000
ZZ2PRT   EQU   ZZ2+138                                                  01181000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 01182000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                01183000
ZZ2A     EQU   ZZ2+272                                                  01184000
ZZ2AF    EQU   ZZ2A+16                                                  01185000
ZZ2APID  EQU   ZZ2A+64                                                  01186000
ZZ2AD    EQU   ZZ2A+74                                                  01187000
ZZ2ADD   EQU   ZZ2AD                                                    01188000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 01189000
ZZ2ADM   EQU   ZZ2AD+46                                                 01190000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 01191000
ZZ2ADP   EQU   ZZ2AD+56                                                 01192000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 01193000
ZZ2AZZ6P EQU   ZZ2A+140                                                 01194000
ZZ2AQAS  EQU   ZZ2A+144                                                 01195000
ZZ2AQD   EQU   ZZ2A+160                                                 01196000
ZZ2AQDT  EQU   ZZ2AQD+10                                                01197000
ZZ2AQDF  EQU   ZZ2AQD+52                                                01198000
ZZ2STG   EQU   ZZ2+960                                                  01199000
ZZ2ALLOP EQU   ZZ2+992                                                  01200000
ZZ2FREEP EQU   ZZ2+996                                                  01201000
ZZ2FF19P EQU   ZZ2+1000                                                 01202000
ZZ2FRE1P EQU   ZZ2+1004                                                 01203000
ZZ2FF18P EQU   ZZ2+1008                                                 01204000
ZZ2DYNAP EQU   ZZ2+1012                                                 01205000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 01206000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 01207000
ZZ2STAIP EQU   ZZ2+1024                                                 01208000
ZZ2FF02P EQU   ZZ2+1028                                                 01209000
ZZ2GETLP EQU   ZZ2+1032                                                 01210000
ZZ2PARSP EQU   ZZ2+1036                                                 01211000
ZZ2PTGTP EQU   ZZ2+1040                                                 01212000
ZZ2PUTLP EQU   ZZ2+1044                                                 01213000
ZZ2SCANP EQU   ZZ2+1048                                                 01214000
ZZ2STCKP EQU   ZZ2+1052                                                 01215000
ZZ2TRMOP EQU   ZZ2+1064                                                 01216000
ZZ2TRMVP EQU   ZZ2+1068                                                 01217000
ZZ2PUTNP EQU   ZZ2+1084                                                 01218000
ZZ2TRMNP EQU   ZZ2+1088                                                 01219000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 01220000
ZZ2BVTP  EQU   ZZ2+1280                                                 01221000
ZZ2RVTP  EQU   ZZ2+1284                                                 01222000
ZZ2CPPL  EQU   ZZ2+1292                                                 01223000
ZZ2CPPLC EQU   ZZ2CPPL                                                  01224000
ZZ2ITR   EQU   ZZ2+2840                                                 01225000
ZZ2ITRE  EQU   ZZ2ITR+16                                                01226000
ZZ2ITSE  EQU   ZZ2+2864                                                 01227000
ZZ2ES    EQU   ZZ2+2872                                                 01228000
ZZ2AMDX  EQU   ZZ2+7160                                                 01229000
ZZ2AXO   EQU   ZZ2+7934                                                 01230000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 01231000
CMD      EQU   0                                                        01232000
CMDT     EQU   CMD+4                                                    01233000
PSCB     EQU   0                                                        01234000
PSCBATR1 EQU   PSCB+16                                                  01235000
ECT      EQU   0                                                        01236000
ECTSWS   EQU   ECT+28                                                   01237000
ECTSWS2  EQU   ECT+40                                                   01238000
ECTSWS21 EQU   ECTSWS2                                                  01239000
UPT      EQU   0                                                        01240000
UPTSWS   EQU   UPT+12                                                   01241000
SA       EQU   0                                                        01242000
SA1      EQU   SA                                                       01243000
SAR      EQU   SA+12                                                    01244000
SAR1     EQU   SAR+12                                                   01245000
BLSUMPK1 EQU   0                                                        01246000
BLSUPUTA EQU   0                                                        01247000
BVT      EQU   0                                                        01248000
BVTPUTLP EQU   BVT+4                                                    01249000
BVTPUTOP EQU   BVT+12                                                   01250000
BVTPUTTP EQU   BVT+16                                                   01251000
BVTPUTVP EQU   BVT+20                                                   01252000
BVTPUTAP EQU   BVT+24                                                   01253000
BVTPRTTP EQU   BVT+28                                                   01254000
BVTPRTAP EQU   BVT+32                                                   01255000
BVTPUTDP EQU   BVT+36                                                   01256000
BVTMONP  EQU   BVT+40                                                   01257000
BVTMON2P EQU   BVT+44                                                   01258000
BVTVSARP EQU   BVT+48                                                   01259000
BVTVSENP EQU   BVT+64                                                   01260000
BVTVSERP EQU   BVT+68                                                   01261000
BVTVSGEP EQU   BVT+72                                                   01262000
BVTVSGUP EQU   BVT+76                                                   01263000
BVTVSPOP EQU   BVT+80                                                   01264000
BVTVSPUP EQU   BVT+84                                                   01265000
BVTMPKNP EQU   BVT+104                                                  01266000
BVTMONLP EQU   BVT+108                                                  01267000
BVTPUTCP EQU   BVT+132                                                  01268000
BVTMPK1P EQU   BVT+136                                                  01269000
BVTZZ2RP EQU   BVT+140                                                  01270000
BVTPGMRP EQU   BVT+144                                                  01271000
BVTMONAP EQU   BVT+148                                                  01272000
BVTBLDDP EQU   BVT+152                                                  01273000
BVTBLDLP EQU   BVT+156                                                  01274000
BVTPGMCP EQU   BVT+160                                                  01275000
BVTPGMDP EQU   BVT+164                                                  01276000
BVTPGMLP EQU   BVT+168                                                  01277000
BVTMONCP EQU   BVT+180                                                  01278000
BVTMONDP EQU   BVT+184                                                  01279000
BVTMONTP EQU   BVT+188                                                  01280000
BVTPARIP EQU   BVT+192                                                  01281000
BVTPARUP EQU   BVT+196                                                  01282000
BVTPRTNP EQU   BVT+204                                                  01283000
BVTVSCRP EQU   BVT+208                                                  01284000
BVTVSMRP EQU   BVT+212                                                  01285000
BVTMONXP EQU   BVT+216                                                  01286000
BVTTRMAP EQU   BVT+228                                                  01287000
ZZ6      EQU   0                                                        01288000
ZZ6D     EQU   ZZ6+128                                                  01289000
ZZ6DD    EQU   ZZ6D+8                                                   01290000
ZZ6DDT   EQU   ZZ6DD+4                                                  01291000
ZZ6DQA   EQU   ZZ6D+68                                                  01292000
ZZ6DF    EQU   ZZ6D+92                                                  01293000
ZZ6B     EQU   ZZ6+768                                                  01294000
RVT      EQU   0                                                        01295000
RVTADDRP EQU   RVT                                                      01296000
RVTT01P  EQU   RVT+4                                                    01297000
RVTTAP   EQU   RVT+8                                                    01298000
RVTTBP   EQU   RVT+12                                                   01299000
RVTTCP   EQU   RVT+16                                                   01300000
RVTTFP   EQU   RVT+24                                                   01301000
RVTTYP   EQU   RVT+40                                                   01302000
RVTT02P  EQU   RVT+48                                                   01303000
RVTT03P  EQU   RVT+52                                                   01304000
RVTT04P  EQU   RVT+56                                                   01305000
RVTACCLP EQU   RVT+60                                                   01306000
RVTRACCP EQU   RVT+64                                                   01307000
RVTTLP   EQU   RVT+68                                                   01308000
RVTTMP   EQU   RVT+72                                                   01309000
RVTTUP   EQU   RVT+80                                                   01310000
RVTESGEP EQU   RVT+84                                                   01311000
RVTESGUP EQU   RVT+88                                                   01312000
RVTESARP EQU   RVT+92                                                   01313000
RVTRAARP EQU   RVT+96                                                   01314000
RVTRAGEP EQU   RVT+100                                                  01315000
RVTADDPP EQU   RVT+104                                                  01316000
RVTACCQP EQU   RVT+108                                                  01317000
RVTSAGUP EQU   RVT+124                                                  01318000
RVTSAGEP EQU   RVT+128                                                  01319000
RVTESCKP EQU   RVT+132                                                  01320000
RVTMSGAP EQU   RVT+136                                                  01321000
RVTMSGDP EQU   RVT+140                                                  01322000
RVTADDTP EQU   RVT+160                                                  01323000
RVTADDUP EQU   RVT+164                                                  01324000
RVTADD1P EQU   RVT+176                                                  01325000
RVTADD2P EQU   RVT+180                                                  01326000
RVTRSAGP EQU   RVT+184                                                  01327000
RVTMSGBP EQU   RVT+188                                                  01328000
RVTADDSP EQU   RVT+192                                                  01329000
RVTADD3P EQU   RVT+196                                                  01330000
RVTT05P  EQU   RVT+200                                                  01331000
RVTPADSP EQU   RVT+204                                                  01332000
RVTTRP   EQU   RVT+228                                                  01333000
RVTADD4P EQU   RVT+232                                                  01334000
RVTSAPCP EQU   RVT+236                                                  01335000
RVTSAARP EQU   RVT+240                                                  01336000
RVTSAGNP EQU   RVT+244                                                  01337000
RVTT06P  EQU   RVT+248                                                  01338000
RVTSAGCP EQU   RVT+252                                                  01339000
RVTSAGQP EQU   RVT+256                                                  01340000
RVTESGCP EQU   RVT+260                                                  01341000
RVTESGQP EQU   RVT+264                                                  01342000
RVTDUCKP EQU   RVT+276                                                  01343000
RVTDUCCP EQU   RVT+280                                                  01344000
I001C    EQU   0                                                        01345000
BLSRACC  EQU   0                                                        01346000
BLSRACCL EQU   0                                                        01347000
BLSRACCQ EQU   0                                                        01348000
BLSRADDP EQU   0                                                        01349000
BLSRADDR EQU   0                                                        01350000
BLSRADDS EQU   0                                                        01351000
BLSRADDT EQU   0                                                        01352000
BLSRADDU EQU   0                                                        01353000
BLSRADD1 EQU   0                                                        01354000
BLSRADD2 EQU   0                                                        01355000
BLSRADD3 EQU   0                                                        01356000
BLSRADD4 EQU   0                                                        01357000
BLSRDUCC EQU   0                                                        01358000
BLSRDUCK EQU   0                                                        01359000
BLSRESAR EQU   0                                                        01360000
BLSRESCK EQU   0                                                        01361000
BLSRESGC EQU   0                                                        01362000
BLSRESGE EQU   0                                                        01363000
BLSRESGQ EQU   0                                                        01364000
BLSRESGU EQU   0                                                        01365000
BLSRMSGA EQU   0                                                        01366000
BLSRMSGB EQU   0                                                        01367000
BLSRMSGD EQU   0                                                        01368000
BLSRPADS EQU   0                                                        01369000
BLSRRAAR EQU   0                                                        01370000
BLSRRAGE EQU   0                                                        01371000
BLSRSAAR EQU   0                                                        01372000
BLSRSAG  EQU   0                                                        01373000
BLSRSAGC EQU   0                                                        01374000
BLSRSAGE EQU   0                                                        01375000
BLSRSAGN EQU   0                                                        01376000
BLSRSAGQ EQU   0                                                        01377000
BLSRSAGU EQU   0                                                        01378000
BLSRSAPC EQU   0                                                        01379000
BLSTA    EQU   0                                                        01380000
BLSTB    EQU   0                                                        01381000
BLSTC    EQU   0                                                        01382000
BLSTF    EQU   0                                                        01383000
BLSTL    EQU   0                                                        01384000
BLSTM    EQU   0                                                        01385000
BLSTR    EQU   0                                                        01386000
BLSTU    EQU   0                                                        01387000
BLSTY    EQU   0                                                        01388000
BLST01   EQU   0                                                        01389000
BLST02   EQU   0                                                        01390000
BLST03   EQU   0                                                        01391000
BLST04   EQU   0                                                        01392000
BLST05   EQU   0                                                        01393000
BLST06   EQU   0                                                        01394000
BLSUALLO EQU   0                                                        01395000
BLSUBLDD EQU   0                                                        01396000
BLSUBLDL EQU   0                                                        01397000
BLSUDYNA EQU   0                                                        01398000
BLSUFREE EQU   0                                                        01399000
BLSUFRE1 EQU   0                                                        01400000
BLSUMON  EQU   0                                                        01401000
BLSUMONA EQU   0                                                        01402000
BLSUMONC EQU   0                                                        01403000
BLSUMOND EQU   0                                                        01404000
BLSUMONL EQU   0                                                        01405000
BLSUMONT EQU   0                                                        01406000
BLSUMONX EQU   0                                                        01407000
BLSUMON2 EQU   0                                                        01408000
BLSUMPKN EQU   0                                                        01409000
BLSUPARI EQU   0                                                        01410000
BLSUPARU EQU   0                                                        01411000
BLSUPGMC EQU   0                                                        01412000
BLSUPGMD EQU   0                                                        01413000
BLSUPGML EQU   0                                                        01414000
BLSUPGMR EQU   0                                                        01415000
BLSUPRTA EQU   0                                                        01416000
BLSUPRTN EQU   0                                                        01417000
BLSUPRTT EQU   0                                                        01418000
BLSUPUTC EQU   0                                                        01419000
BLSUPUTD EQU   0                                                        01420000
BLSUPUTL EQU   0                                                        01421000
BLSUPUTN EQU   0                                                        01422000
BLSUPUTO EQU   0                                                        01423000
BLSUPUTT EQU   0                                                        01424000
BLSUPUTV EQU   0                                                        01425000
BLSUSTAI EQU   0                                                        01426000
BLSUTRMA EQU   0                                                        01427000
BLSUTRMN EQU   0                                                        01428000
BLSUTRMO EQU   0                                                        01429000
BLSUTRMV EQU   0                                                        01430000
BLSUVSAR EQU   0                                                        01431000
BLSUVSCR EQU   0                                                        01432000
BLSUVSEN EQU   0                                                        01433000
BLSUVSER EQU   0                                                        01434000
BLSUVSGE EQU   0                                                        01435000
BLSUVSGU EQU   0                                                        01436000
BLSUVSMR EQU   0                                                        01437000
BLSUVSPO EQU   0                                                        01438000
BLSUVSPU EQU   0                                                        01439000
BLSUZZ2C EQU   0                                                        01440000
BLSUZZ2D EQU   0                                                        01441000
BLSUZZ2R EQU   0                                                        01442000
IKJEFF02 EQU   0                                                        01443000
IKJEFF18 EQU   0                                                        01444000
IKJEFF19 EQU   0                                                        01445000
IKJGETL  EQU   0                                                        01446000
IKJPARS  EQU   0                                                        01447000
IKJPTGT  EQU   0                                                        01448000
IKJPUTL  EQU   0                                                        01449000
IKJSCAN  EQU   0                                                        01450000
IKJSTCK  EQU   0                                                        01451000
I008P    EQU   0                                                        01452000
I015F    EQU   0                                                        01453000
I015P    EQU   0                                                        01454000
I031F    EQU   0                                                        01455000
I031P    EQU   0                                                        01456000
I256C    EQU   0                                                        01457000
PZ2      EQU   0                                                        01458000
ESPA     EQU   0                                                        01459000
ESPAAS   EQU   ESPA+60                                                  01460000
ESPALAD  EQU   ESPA+76                                                  01461000
ESPAD    EQU   ESPA+80                                                  01462000
ESPADOF  EQU   ESPAD                                                    01463000
ESPADLE  EQU   ESPAD+4                                                  01464000
ESPADT   EQU   ESPAD+10                                                 01465000
ESPADIM  EQU   ESPAD+44                                                 01466000
ESPADF   EQU   ESPAD+52                                                 01467000
ESPAF    EQU   ESPA+161                                                 01468000
ESPAFS   EQU   ESPAF                                                    01469000
ESPAFC   EQU   ESPAF+1                                                  01470000
ESPAR    EQU   ESPA+180                                                 01471000
ESPART   EQU   ESPAR+2                                                  01472000
BLK      EQU   0                                                        01473000
CPPL     EQU   ZZ2CPPL                                                  01474000
CPPLUPT  EQU   CPPL+4                                                   01475000
CPPLPSCB EQU   CPPL+8                                                   01476000
CPPLECT  EQU   CPPL+12                                                  01477000
PTRPTR   EQU   PTRBIT                                                   01478000
@RC00177 EQU   @RC00175                                                 01935000
@RC00187 EQU   @RC00177                                                 01936000
L020     EQU   @RC00177                                                 01937000
@ENDDATA EQU   *                                                        01938000
         END   BLSTM5                                           DSKC441 01939000
