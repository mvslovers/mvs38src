TM4      TITLE 'BLSTM4  --IPCS SERVICE ROUTINE TO DISPLAY STRUCTURED DA*00001000
               ATA      '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPLK                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSTM4   CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(16)                                             0002 00010000
         DC    C'BLSTM4    78.059'                                 0002 00011000
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
*   MM4B=MM4S;                      /* MESSAGE MM4 LITERAL TEXT      */ 00028000
         MVC   MM4B(80),MM4S                                       0138 00029000
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
*   IF LINELEN>LENGTH(BUF) THEN     /* MULTIPLE DISPLAY LINES        */ 00055000
         LA    @14,16                                              0146 00056000
         CR    LINELEN,@14                                         0146 00057000
         BNH   @RF00146                                            0146 00058000
*     LINELEN=LENGTH(BUF)-(LINEADDR&BUFMASK2);/* ALIGN DISPLAY LINES */ 00059000
         LR    LINELEN,LINEADDR                                    0147 00060000
         N     LINELEN,@CF01138                                    0147 00061000
         SLR   @14,LINELEN                                         0147 00062000
         LR    LINELEN,@14                                         0147 00063000
*   ELSE                            /* SINGLE DISPLAY LINE           */ 00064000
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
*                                      R)TO(CHARACTER)SET(MM4BT120)RE   00085000
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
*       UNPK(MM4BT120(1:LENGTH(MM4BT120)-1),PTRBIT);/* BIT=>ZONED  0154 00098000
*                                      HEXADECIMAL                   */ 00099000
         UNPK  MM4BT120(5),PTRBIT(4)                               0154 00100000
*       MM4BT120(LENGTH(MM4BT120):LENGTH(MM4BT120))=PTRBIT(25:32);/*    00101000
*                                      FINAL ZONED HEXADECIMAL DIGIT */ 00102000
         MVC   MM4BT120+5(1),PTRBIT+3                              0155 00103000
*       TR(MM4BT120,ZZ1TRHEX);      /* ZONED HEXADECIMAL=>EBCDIC     */ 00104000
         L     @14,ZZ2ZZ1P(,R9)                                    0156 00105000
         TR    MM4BT120(6),ZZ1TRHEX(@14)                           0156 00106000
*     END;                          /* BLRCNVPC(LINEADDR) FROM(POINTE   00107000
*                                      R)TO(CHARACTER)SET(MM4BT120)RE   00108000
*                                      MARK(OUTPUT LINE            0157 00109000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00110000
*     DO;                           /* BLRCNVOC(LINEOFF) FROM(OFFSET)   00111000
*                                      TO(CHARACTER)SET(MM4BT10)REMAR   00112000
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
*           MM4BT10(1:1)='+';       /* POSITIVE OFFSET               */ 00133000
         MVI   MM4BT10,C'+'                                        0161 00134000
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
*           MM4BT10(1:1)='-';       /* NEGATIVE OFFSET               */ 00149000
         MVI   MM4BT10,C'-'                                        0165 00150000
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
*       UNPK(MM4BT10(2:LENGTH(MM4BT10)-1),PTRBIT);/* BIT=>ZONED    0170 00164000
*                                      HEXADECIMAL                   */ 00165000
@RC00159 UNPK  MM4BT10+1(5),PTRBIT(4)                              0170 00166000
*       MM4BT10(LENGTH(MM4BT10):LENGTH(MM4BT10))=PTRBIT(25:32);/*  0171 00167000
*                                      FINAL ZONED HEXADECIMAL DIGIT */ 00168000
         MVC   MM4BT10+6(1),PTRBIT+3                               0171 00169000
*       TR(MM4BT10(2:LENGTH(MM4BT10)),ZZ1TRHEX);/* ZONED           0172 00170000
*                                      HEXADECIMAL=>EBCDIC           */ 00171000
         L     @14,ZZ2ZZ1P(,R9)                                    0172 00172000
         TR    MM4BT10+1(6),ZZ1TRHEX(@14)                          0172 00173000
*     END;                          /* BLRCNVOC(LINEOFF) FROM(OFFSET)   00174000
*                                      TO(CHARACTER)SET(MM4BT10)REMAR   00175000
*                                      K(OFFSET OF DATA            0173 00176000
*                                      LINE)TR(ZZ1TRHEX)             */ 00177000
*     MVCLD2L=LINELEN;              /* DATA BYTES IN THIS LINE       */ 00178000
         STCM  LINELEN,7,MVCLD2L                                   0174 00179000
*     IF LINELEN=LENGTH(BUF) THEN   /* FULL DATA LINE                */ 00180000
*                                                                  0175 00181000
         C     LINELEN,@CF00061                                    0175 00182000
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
         MVC   MDBL(2),@CH01182                                    0191 00241000
*               END;                                               0192 00242000
*             ELSE                                                 0193 00243000
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
         MVC   BUF+2(14),BUF+1                                     0202 00281000
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
         AL    @14,@CF00061                                        0205 00293000
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
         N     @14,@CF01193                                        0247 00454000
         STH   @14,MDBL                                            0247 00455000
*         ELSE                      /* NON-GRAPHIC                   */ 00456000
*           MDBL=LENGTH(MDB)-LENGTH(MDBT53);/* MESSAGE LENGTH        */ 00457000
         B     @RC00246                                            0248 00458000
@RF00246 MVC   MDBL(2),@CH01183                                    0248 00459000
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
*                                      ACTER)SET(MM4BT30)REMARK(BIT     00484000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00485000
*                                                                  0253 00486000
*           /*********************************************************/ 00487000
*           /*                                                       */ 00488000
*           /* BIT STRING WORD 1                                     */ 00489000
*           /*                                                       */ 00490000
*           /*********************************************************/ 00491000
*                                                                  0254 00492000
*           UNPK(MM4BT30(1:LENGTH(MM4BT30)-1),BUF1);/* BIT=>ZONED  0254 00493000
*                                      HEXADECIMAL                   */ 00494000
         UNPK  MM4BT30(7),BUF1(4)                                  0254 00495000
*           MM4BT30(LENGTH(MM4BT30):LENGTH(MM4BT30))=BUF1(LENGTH(BUF1): 00496000
*               LENGTH(BUF1));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00497000
         MVC   MM4BT30+7(1),BUF1+3                                 0255 00498000
*           TR(MM4BT30,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00499000
         L     @14,ZZ2ZZ1P(,R9)                                    0256 00500000
         TR    MM4BT30(8),ZZ1TRHEX(@14)                            0256 00501000
*         END;                      /* BLRCNVXC(BUF1) FROM(BS)TO(CHAR   00502000
*                                      ACTER)SET(MM4BT30)REMARK(BIT     00503000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00504000
*         DO;                       /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00505000
*                                      ACTER)SET(MM4BT32)REMARK(BIT     00506000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00507000
*                                                                  0258 00508000
*           /*********************************************************/ 00509000
*           /*                                                       */ 00510000
*           /* BIT STRING WORD 2                                     */ 00511000
*           /*                                                       */ 00512000
*           /*********************************************************/ 00513000
*                                                                  0259 00514000
*           UNPK(MM4BT32(1:LENGTH(MM4BT32)-1),BUF2);/* BIT=>ZONED  0259 00515000
*                                      HEXADECIMAL                   */ 00516000
         UNPK  MM4BT32(7),BUF2(4)                                  0259 00517000
*           MM4BT32(LENGTH(MM4BT32):LENGTH(MM4BT32))=BUF2(LENGTH(BUF2): 00518000
*               LENGTH(BUF2));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00519000
         MVC   MM4BT32+7(1),BUF2+3                                 0260 00520000
*           TR(MM4BT32,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00521000
         TR    MM4BT32(8),ZZ1TRHEX(@14)                            0261 00522000
*         END;                      /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00523000
*                                      ACTER)SET(MM4BT32)REMARK(BIT     00524000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00525000
*         DO;                       /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00526000
*                                      ACTER)SET(MM4BT34)REMARK(BIT     00527000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00528000
*                                                                  0263 00529000
*           /*********************************************************/ 00530000
*           /*                                                       */ 00531000
*           /* BIT STRING WORD 3                                     */ 00532000
*           /*                                                       */ 00533000
*           /*********************************************************/ 00534000
*                                                                  0264 00535000
*           UNPK(MM4BT34(1:LENGTH(MM4BT34)-1),BUF3);/* BIT=>ZONED  0264 00536000
*                                      HEXADECIMAL                   */ 00537000
         UNPK  MM4BT34(7),BUF3(4)                                  0264 00538000
*           MM4BT34(LENGTH(MM4BT34):LENGTH(MM4BT34))=BUF3(LENGTH(BUF3): 00539000
*               LENGTH(BUF3));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00540000
         MVC   MM4BT34+7(1),BUF3+3                                 0265 00541000
*           TR(MM4BT34,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00542000
         TR    MM4BT34(8),ZZ1TRHEX(@14)                            0266 00543000
*         END;                      /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00544000
*                                      ACTER)SET(MM4BT34)REMARK(BIT     00545000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00546000
*         DO;                       /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00547000
*                                      ACTER)SET(MM4BT36)REMARK(BIT     00548000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00549000
*                                                                  0268 00550000
*           /*********************************************************/ 00551000
*           /*                                                       */ 00552000
*           /* BIT STRING WORD 4                                     */ 00553000
*           /*                                                       */ 00554000
*           /*********************************************************/ 00555000
*                                                                  0269 00556000
*           UNPK(MM4BT36(1:LENGTH(MM4BT36)-1),BUF4);/* BIT=>ZONED  0269 00557000
*                                      HEXADECIMAL                   */ 00558000
         UNPK  MM4BT36(7),BUF4(4)                                  0269 00559000
*           MM4BT36(LENGTH(MM4BT36):LENGTH(MM4BT36))=BUF4(LENGTH(BUF4): 00560000
*               LENGTH(BUF4));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00561000
         MVC   MM4BT36+7(1),BUF4+3                                 0270 00562000
*           TR(MM4BT36,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00563000
         TR    MM4BT36(8),ZZ1TRHEX(@14)                            0271 00564000
*         END;                      /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00565000
*                                      ACTER)SET(MM4BT36)REMARK(BIT     00566000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00567000
*         IF LINELEN<LENGTH(BUF) THEN/* BLANK IMPROPER OUTPUT        */ 00568000
*                                                                  0273 00569000
         LA    @14,16                                              0273 00570000
         CR    LINELEN,@14                                         0273 00571000
         BNL   @RF00273                                            0273 00572000
*           /*********************************************************/ 00573000
*           /*                                                       */ 00574000
*           /* MORE BIT STRING DATA FORMATTED THAN REQUESTED. BLANK  */ 00575000
*           /* THAT OUTPUT FORMATTED BUT NOT REQUESTED.              */ 00576000
*           /*                                                       */ 00577000
*           /*********************************************************/ 00578000
*                                                                  0274 00579000
*           DO;                     /* BLANK IMPROPER OUTPUT         */ 00580000
*             J=((LENGTH(BUF)-LINELEN)/* EXCESS BYTES FORMATTED      */ 00581000
*                 *9)/4;            /* BLANKS TO REINSERT            */ 00582000
         LR    @00,@14                                             0275 00583000
         SLR   @00,LINELEN                                         0275 00584000
         LR    @03,@00                                             0275 00585000
         M     J,@CF01169                                          0275 00586000
         D     J,@CF00047                                          0275 00587000
         LR    J,@03                                               0275 00588000
*             IF FLAGL='1'B THEN    /* LEFT-JUSTIFY DATA             */ 00589000
         TM    FLAGL,B'00010000'                                   0276 00590000
         BNO   @RF00276                                            0276 00591000
*               MM4BT3(LENGTH(MM4BT3)+1-J:LENGTH(MM4BT3))=MM4ST3(LENGTH 00592000
*                   (MM4BT3)+1-J:LENGTH(MM4BT3));/* TRAILING BLANKS  */ 00593000
         LA    @14,36                                              0277 00594000
         SLR   @14,J                                               0277 00595000
         LA    @03,MM4BT3-1(@14)                                   0277 00596000
         LA    @05,35                                              0277 00597000
         SLR   @05,@14                                             0277 00598000
         LA    @04,MM4ST3-1(@14)                                   0277 00599000
         EX    @05,@SM01194                                        0277 00600000
*             ELSE                  /* RIGHT-JUSTIFY DATA            */ 00601000
*               MM4BT3(1:J)=MM4ST3(1:J);/* LEADING BLANKS            */ 00602000
         B     @RC00276                                            0278 00603000
@RF00276 LR    @14,J                                               0278 00604000
         BCTR  @14,0                                               0278 00605000
         EX    @14,@SM01196                                        0278 00606000
*           END;                                                   0279 00607000
*                                                                  0279 00608000
@RC00276 DS    0H                                                  0280 00609000
*         /***********************************************************/ 00610000
*         /*                                                         */ 00611000
*         /* DISPLAY DATA AS CHARACTER STRING AS WELL AS BIT STRING  */ 00612000
*         /*                                                         */ 00613000
*         /***********************************************************/ 00614000
*                                                                  0280 00615000
*         MM4BT5=BUF;               /* CHARACTER DATA                */ 00616000
@RF00273 MVC   MM4BT5(16),BUF                                      0280 00617000
*         TR(MM4BT5,ZZ1TREBC);      /* ELIMINATE NONGRAPHIC DATA     */ 00618000
         L     @14,ZZ2ZZ1P(,R9)                                    0281 00619000
         TR    MM4BT5(16),ZZ1TREBC(@14)                            0281 00620000
*         CALL BLSUPUTA(ZZ2,MM4B);  /* DISPLAY MESSAGE MM4           */ 00621000
         ST    R9,@AL00001                                         0282 00622000
         LA    @14,MM4B                                            0282 00623000
         ST    @14,@AL00001+4                                      0282 00624000
         L     @14,ZZ2BVTP(,R9)                                    0282 00625000
         L     @15,BVTPUTAP(,@14)                                  0282 00626000
         LA    @01,@AL00001                                        0282 00627000
         BALR  @14,@15                                             0282 00628000
*       END;                                                       0283 00629000
*     IF FLAGEND='0'B THEN          /* ANOTHER PASS REQUIRED         */ 00630000
*                                                                  0284 00631000
@RF00251 TM    FLAGEND,B'01000000'                                 0284 00632000
         BNZ   @RF00284                                            0284 00633000
*       /*************************************************************/ 00634000
*       /*                                                           */ 00635000
*       /* ANOTHER PASS WILL BE REQUIRED TO SATISFY THE REQUEST      */ 00636000
*       /*                                                           */ 00637000
*       /*************************************************************/ 00638000
*                                                                  0285 00639000
*       DO;                         /* ANOTHER PASS REQUIRED         */ 00640000
*         FLAGL='1'B;               /* LEFT-JUSTIFY DATA             */ 00641000
         OI    FLAGL,B'00010000'                                   0286 00642000
*         LINEADDR=LINEADDR+LINELEN;/* DUMP ADDRESS OF DATA LINE     */ 00643000
         ALR   LINEADDR,LINELEN                                    0287 00644000
*         LINEOFF=LINEOFF+LINELEN;  /* OFFSET OF DATA LINE           */ 00645000
         ALR   LINEOFF,LINELEN                                     0288 00646000
*         LINELEN=MIN(MVCLD1L,LENGTH(BUF));/* LENGTH OF DATA LINE    */ 00647000
         L     LINELEN,MVCLD1L-1                                   0289 00648000
         LA    LINELEN,0(,LINELEN)                                 0289 00649000
         LA    @14,16                                              0289 00650000
         CR    LINELEN,@14                                         0289 00651000
         BNH   *+6                                                      00652000
         LR    LINELEN,@14                                         0289 00653000
*         IF ZZ1EVEP='1'B THEN      /* ATTENTION INTERRUPTION        */ 00654000
*                                                                  0290 00655000
         L     @14,ZZ2ZZ1P(,R9)                                    0290 00656000
         TM    ZZ1EVEP(@14),B'01000000'                            0290 00657000
         BNO   @RF00290                                            0290 00658000
*           /*********************************************************/ 00659000
*           /*                                                       */ 00660000
*           /* ATTENTION INTERRUPTION--TERMINATE QUICKLY             */ 00661000
*           /*                                                       */ 00662000
*           /*********************************************************/ 00663000
*                                                                  0291 00664000
*           DO;                     /* ATTENTION INTERRUPTION        */ 00665000
*             RETC=MAX(RETC,ZZZFLAGS);/* SIGNAL INCOMPLETE           */ 00666000
         L     @14,RETC                                            0292 00667000
         LA    @00,12                                              0292 00668000
         CR    @14,@00                                             0292 00669000
         BNL   *+6                                                      00670000
         LR    @14,@00                                             0292 00671000
         ST    @14,RETC                                            0292 00672000
*             FLAGEND='1'B;         /* TERMINATE QUICKLY             */ 00673000
         OI    FLAGEND,B'01000000'                                 0293 00674000
*           END;                                                   0294 00675000
*       END;                                                       0295 00676000
@RF00290 DS    0H                                                  0296 00677000
*   END;                                                           0296 00678000
@RF00284 DS    0H                                                  0296 00679000
@DE00151 TM    FLAGEND,B'01000000'                                 0296 00680000
         BZ    @DL00151                                            0296 00681000
*   RETURN CODE(RETC);                                             0297 00682000
*                                                                  0297 00683000
         L     @10,RETC                                            0297 00684000
         L     @13,4(,@13)                                         0297 00685000
         L     @00,@SIZDATD                                        0297 00686000
         LR    @01,@11                                             0297 00687000
         BLSUFRES R,LV=(0),A=(1)                                        00688000
         LR    @15,@10                                             0297 00689000
         L     @14,12(,@13)                                        0297 00690000
         LM    @00,@12,20(@13)                                     0297 00691000
         BR    @14                                                 0297 00692000
*/********************************************************************/ 00693000
*/*                                                                  */ 00694000
*/* E100--BEGIN REDUNDANT DATA PROCESSING                            */ 00695000
*/*                                                                  */ 00696000
*/********************************************************************/ 00697000
*                                                                  0298 00698000
*E100:                              /* BEGIN REDUNDANT DATA          */ 00699000
*   PROCEDURE;                                                     0298 00700000
E100     STM   @14,@09,12(@13)                                     0298 00701000
         STM   @11,@12,64(@13)                                     0298 00702000
*   DUPLEN=LINELEN;                 /* LENGTH OF REPETITIVE AREA     */ 00703000
         LR    DUPLEN,LINELEN                                      0299 00704000
*   MDBT10=MM4BT10;                 /* REPETITIVE DATA OFFSET        */ 00705000
         MVC   MDBT10(7),MM4BT10                                   0300 00706000
*   MDBT120=MM4BT120;               /* REPETITIVE DATA ADDRESS       */ 00707000
         MVC   MDBT120(6),MM4BT120                                 0301 00708000
*   FLAGD='1'B;                     /* DUPLICATE DATA PROCESSING     */ 00709000
*   FLAGN='0'B;                     /* DATA LINE NOT NEW             */ 00710000
         OI    FLAGD,B'10000000'                                   0303 00711000
         NI    FLAGN,B'11110111'                                   0303 00712000
*   RETURN;                                                        0304 00713000
@EL00002 DS    0H                                                  0304 00714000
@EF00002 DS    0H                                                  0304 00715000
@ER00002 LM    @14,@09,12(@13)                                     0304 00716000
         LM    @11,@12,64(@13)                                     0304 00717000
         BR    @14                                                 0304 00718000
*   END E100;                                                      0305 00719000
*                                                                  0305 00720000
*/*BLSTPEND--DISPLAY FORMATTER                                       */ 00721000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00722000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00723000
*                                                                  0306 00724000
*   DECLARE                         /* DATA FOR AHB MACROS           */ 00725000
*     PTRBIT BIT(32) BOUNDARY(WORD),/* DATA CONVERSION WORK AREA FOR    00726000
*                                      POINTER DATA                  */ 00727000
*     PTRPTR POINTER DEFINED(PTRBIT),/* DATA CONVERSION WORK AREA FOR   00728000
*                                      POINTER DATA                  */ 00729000
*     PACKED BIT(64) BOUNDARY(DWORD);/* DATA CONVERSION WORK AREA    */ 00730000
*   DECLARE                         /* COMMON VARIABLES              */ 00731000
*     I256C CHAR(256) BASED,                                       0307 00732000
*     I031F FIXED(31) BASED,                                       0307 00733000
*     I031P PTR(31) BASED,                                         0307 00734000
*     I015F FIXED(15) BASED,                                       0307 00735000
*     I015P PTR(15) BASED,                                         0307 00736000
*     I008P PTR(8) BASED,                                          0307 00737000
*     I001C CHAR(1) BASED;                                         0307 00738000
*   GENERATE NODEFS NOREFS DATA;                                   0308 00739000
*   END BLSTM4                      /* BLRPEND(BLSTM4)               */ 00740000
*                                                                  0309 00741000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00742000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00743000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00744000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00745000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00746000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00747000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00748000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00749000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00750000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00751000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00752000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00753000
*                                                                  0309 00754000
*       ;                                                          0309 00755000
@EL00001 L     @13,4(,@13)                                         0309 00756000
@EF00001 L     @00,@SIZDATD                                        0309 00757000
         LR    @01,@11                                             0309 00758000
         BLSUFRES R,LV=(0),A=(1)                                        00759000
@ER00001 LM    @14,@12,12(@13)                                     0309 00760000
         BR    @14                                                 0309 00761000
@DATA    DS    0H                                                       00762000
@CH01182 DC    H'57'                                                    00763000
@CH01183 DC    H'67'                                                    00764000
@SM01194 MVC   0(0,@03),0(@04)                                          00765000
@SM01196 MVC   MM4BT3(0),MM4ST3                                         00766000
@DATD    DSECT                                                          00767000
         DS    0F                                                       00768000
@SA00001 DS    18F                                                      00769000
@PC00001 DS    3F                                                       00770000
@AL00001 DS    2A                                                       00771000
BLSTM4   CSECT                                                          00772000
         DS    0F                                                       00773000
@CF00050 DC    F'1'                                                     00774000
@CF00047 DC    F'4'                                                     00775000
@CF01169 DC    F'9'                                                     00776000
@CF00061 DC    F'16'                                                    00777000
@CF00070 DC    XL4'80000000'                                            00778000
@CF01138 DC    XL4'0000000F'                                            00779000
@CF01193 DC    XL4'0000FFFF'                                            00780000
@DATD    DSECT                                                          00781000
         DS    0D                                                       00782000
RETC     DS    F                                                        00783000
MVCLD    DS    CL16                                                     00784000
         ORG   MVCLD                                                    00785000
MVCLD1   DS    CL8                                                      00786000
         ORG   MVCLD1                                                   00787000
MVCLD1P  DS    AL4                                                      00788000
MVCLD12  DS    BL4                                                      00789000
         ORG   MVCLD12                                                  00790000
MVCLD1C  DS    CL1                                                      00791000
MVCLD1L  DS    FL3                                                      00792000
         ORG   MVCLD1+8                                                 00793000
MVCLD19  DS    0C                                                       00794000
         ORG   MVCLD+8                                                  00795000
MVCLD2   DS    CL8                                                      00796000
         ORG   MVCLD2                                                   00797000
MVCLD2P  DS    AL4                                                      00798000
MVCLD22  DS    BL4                                                      00799000
         ORG   MVCLD22                                                  00800000
MVCLD2C  DS    CL1                                                      00801000
MVCLD2L  DS    FL3                                                      00802000
         ORG   MVCLD2+8                                                 00803000
MVCLD29  DS    0C                                                       00804000
         ORG   MVCLD+16                                                 00805000
MVCLD99  DS    0C                                                       00806000
         ORG   MVCLD+16                                                 00807000
MM4B     DS    CL80                                                     00808000
         ORG   MM4B                                                     00809000
MM4BL    DS    FL2                                                      00810000
@NM00090 DS    BL2                                                      00811000
MM4BT    DS    CL76                                                     00812000
         ORG   MM4BT                                                    00813000
MM4BT0   DS    CL1                                                      00814000
MM4BT1   DS    CL15                                                     00815000
         ORG   MM4BT1                                                   00816000
MM4BT10  DS    CL7                                                      00817000
MM4BT11  DS    CL1                                                      00818000
MM4BT12  DS    CL7                                                      00819000
         ORG   MM4BT12                                                  00820000
MM4BT120 DS    CL6                                                      00821000
MM4BT121 DS    CL1                                                      00822000
         ORG   MM4BT+16                                                 00823000
MM4BT2   DS    CL3                                                      00824000
MM4BT3   DS    CL35                                                     00825000
         ORG   MM4BT3                                                   00826000
MM4BT30  DS    CL8                                                      00827000
MM4BT31  DS    CL1                                                      00828000
MM4BT32  DS    CL8                                                      00829000
MM4BT33  DS    CL1                                                      00830000
MM4BT34  DS    CL8                                                      00831000
MM4BT35  DS    CL1                                                      00832000
MM4BT36  DS    CL8                                                      00833000
         ORG   MM4BT+54                                                 00834000
MM4BT4   DS    CL4                                                      00835000
MM4BT5   DS    CL16                                                     00836000
MM4BT6   DS    CL2                                                      00837000
         ORG   MM4B+80                                                  00838000
MDB      DS    CL80                                                     00839000
         ORG   MDB                                                      00840000
MDBL     DS    FL2                                                      00841000
@NM00092 DS    BL2                                                      00842000
MDBT     DS    CL76                                                     00843000
         ORG   MDBT                                                     00844000
MDBT0    DS    CL1                                                      00845000
MDBT1    DS    CL15                                                     00846000
         ORG   MDBT1                                                    00847000
MDBT10   DS    CL7                                                      00848000
MDBT11   DS    CL1                                                      00849000
MDBT12   DS    CL7                                                      00850000
         ORG   MDBT12                                                   00851000
MDBT120  DS    CL6                                                      00852000
MDBT121  DS    CL1                                                      00853000
         ORG   MDBT+16                                                  00854000
MDBT2    DS    CL8                                                      00855000
MDBT3    DS    CL10                                                     00856000
MDBT4    DS    CL6                                                      00857000
MDBT5    DS    CL36                                                     00858000
         ORG   MDBT5                                                    00859000
MDBT50   DS    CL20                                                     00860000
MDBT51   DS    CL2                                                      00861000
MDBT52   DS    CL1                                                      00862000
MDBT53   DS    CL13                                                     00863000
         ORG   MDBT53                                                   00864000
MDBT530  DS    CL11                                                     00865000
MDBT531  DS    CL1                                                      00866000
MDBT532  DS    CL1                                                      00867000
         ORG   MDB+80                                                   00868000
BUF      DS    CL16                                                     00869000
         ORG   BUF                                                      00870000
BUF1     DS    CL4                                                      00871000
BUF2     DS    CL4                                                      00872000
BUF3     DS    CL4                                                      00873000
BUF4     DS    CL4                                                      00874000
         ORG   BUF+16                                                   00875000
FLAG     DS    BL1                                                      00876000
         ORG   FLAG                                                     00877000
FLAGD    DS    BL1                                                      00878000
FLAGEND  EQU   FLAG+0                                                   00879000
FLAGF    EQU   FLAG+0                                                   00880000
FLAGL    EQU   FLAG+0                                                   00881000
FLAGN    EQU   FLAG+0                                                   00882000
@NM00093 EQU   FLAG+0                                                   00883000
         ORG   FLAG+1                                                   00884000
         DS    CL3                                                      00885000
PTRBIT   DS    BL4                                                      00886000
         DS    CL4                                                      00887000
PACKED   DS    BL8                                                      00888000
BLSTM4   CSECT                                                          00889000
         DS    0F                                                       00890000
@SIZDATD DC    AL1(0)                                                   00891000
         DC    AL3(@ENDDATD-@DATD)                                      00892000
         DS    0D                                                       00893000
MM4S     DS    CL80                                                     00894000
         ORG   MM4S                                                     00895000
MM4SL    DC    AL2(80)                                                  00896000
@NM00089 DC    X'0000'                                                  00897000
MM4ST    DS    CL76                                                     00898000
         ORG   MM4ST                                                    00899000
MM4ST0   DC    CL1' '                                                   00900000
MM4ST1   DS    CL15                                                     00901000
         ORG   MM4ST1                                                   00902000
MM4ST10  DC    CL7'+000000'                                             00903000
MM4ST11  DC    CL1' '                                                   00904000
MM4ST12  DS    CL7                                                      00905000
         ORG   MM4ST12                                                  00906000
MM4ST120 DC    CL6'000000'                                              00907000
MM4ST121 DC    CL1'.'                                                   00908000
         ORG   MM4ST+16                                                 00909000
MM4ST2   DC    CL3' | '                                                 00910000
MM4ST3   DS    CL35                                                     00911000
         ORG   MM4ST3                                                   00912000
MM4ST30  DC    CL8' '                                                   00913000
MM4ST31  DC    CL1' '                                                   00914000
MM4ST32  DC    CL8' '                                                   00915000
MM4ST33  DC    CL1' '                                                   00916000
MM4ST34  DC    CL8' '                                                   00917000
MM4ST35  DC    CL1' '                                                   00918000
MM4ST36  DC    CL8' '                                                   00919000
         ORG   MM4ST+54                                                 00920000
MM4ST4   DC    CL4' || '                                                00921000
MM4ST5   DC    CL16' '                                                  00922000
MM4ST6   DC    CL2' |'                                                  00923000
         ORG   MM4S+80                                                  00924000
TD       DS    CL13                                                     00925000
         ORG   TD                                                       00926000
TD1      DC    CL13'SAME AS ABOVE'                                      00927000
         ORG   TD+13                                                    00928000
         DS    CL1                                                      00929000
MDS      DS    CL80                                                     00930000
         ORG   MDS                                                      00931000
MDSL     DC    AL2(80)                                                  00932000
@NM00091 DC    X'0000'                                                  00933000
MDST     DS    CL76                                                     00934000
         ORG   MDST                                                     00935000
MDST0    DC    CL1' '                                                   00936000
MDST1    DS    CL15                                                     00937000
         ORG   MDST1                                                    00938000
MDST10   DC    CL7'+000000'                                             00939000
MDST11   DC    CL1' '                                                   00940000
MDST12   DS    CL7                                                      00941000
         ORG   MDST12                                                   00942000
MDST120  DC    CL6'000000'                                              00943000
MDST121  DC    CL1'.'                                                   00944000
         ORG   MDST+16                                                  00945000
MDST2    DC    CL8' LENGTH('                                            00946000
MDST3    DC    X'40202020202020202120'                                  00947000
MDST4    DC    CL6') ==> '                                              00948000
MDST5    DS    CL36                                                     00949000
         ORG   MDST5                                                    00950000
MDST50   DC    CL20'ALL BYTES CONTAIN X'''                              00951000
MDST51   DC    CL2' '                                                   00952000
MDST52   DC    CL1''''                                                  00953000
MDST53   DS    CL13                                                     00954000
         ORG   MDST53                                                   00955000
MDST530  DC    CL11', EBCDIC C'''                                       00956000
MDST531  DC    CL1' '                                                   00957000
MDST532  DC    CL1''''                                                  00958000
         ORG   MDS+80                                                   00959000
@DATD    DSECT                                                          00960000
         SPACE 2                                                        00961000
*********************************************************************** 00962000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00963000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00964000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00965000
*********************************************************************** 00966000
         SPACE                                                          00967000
BLSTM4   CSECT                                                          00968000
         ORG                                                            00969000
         DS    0D                                                       00970000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSTM4+19)/20+7)/8)CL8'BLSTM4'         00971000
@DATD    DSECT                                                          00972000
         DS    0H                                                       00973000
@DATD    DSECT                                                          00974000
         SPACE 2                                                        00975000
*********************************************************************** 00976000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00977000
*********************************************************************** 00978000
         SPACE                                                          00979000
         DS    0D                                                       00980000
@DATD    DSECT                                                          00981000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00982000
@ENDDATD EQU   *                                                        00983000
BLSTM4   CSECT                                                          00984000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00985000
@01      EQU   01                                                       00986000
@02      EQU   02                                                       00987000
@03      EQU   03                                                       00988000
@04      EQU   04                                                       00989000
@05      EQU   05                                                       00990000
@06      EQU   06                                                       00991000
@07      EQU   07                                                       00992000
@08      EQU   08                                                       00993000
@09      EQU   09                                                       00994000
@10      EQU   10                                                       00995000
@11      EQU   11                                                       00996000
@12      EQU   12                                                       00997000
@13      EQU   13                                                       00998000
@14      EQU   14                                                       00999000
@15      EQU   15                                                       01000000
DUPLEN   EQU   @10                                                      01001000
LINEOFF  EQU   @07                                                      01002000
LINELEN  EQU   @06                                                      01003000
LINEADDR EQU   @08                                                      01004000
J        EQU   @02                                                      01005000
R9       EQU   @09                                                      01006000
R0       EQU   @00                                                      01007000
R1       EQU   @01                                                      01008000
R2       EQU   @02                                                      01009000
R3       EQU   @03                                                      01010000
R4       EQU   @04                                                      01011000
R5       EQU   @05                                                      01012000
RB       EQU   @11                                                      01013000
RD       EQU   @13                                                      01014000
RE       EQU   @14                                                      01015000
RF       EQU   @15                                                      01016000
RA       EQU   @10                                                      01017000
RC       EQU   @12                                                      01018000
R6       EQU   @06                                                      01019000
R7       EQU   @07                                                      01020000
R8       EQU   @08                                                      01021000
ZZ1      EQU   0                                                        01022000
ZZ1ATTN  EQU   ZZ1+360                                                  01023000
ZZ1EVE   EQU   ZZ1ATTN+4                                                01024000
ZZ1EVEP  EQU   ZZ1EVE                                                   01025000
ZZ1F     EQU   ZZ1+368                                                  01026000
ZZ1TRHEX EQU   ZZ1+568                                                  01027000
ZZ1TREBC EQU   ZZ1+824                                                  01028000
ZZ1N     EQU   ZZ1+1116                                                 01029000
ZZ2      EQU   0                                                        01030000
ZZ2AMD   EQU   ZZ2                                                      01031000
@NM00025 EQU   ZZ2AMD+7                                                 01032000
ZZ2PRT   EQU   ZZ2+138                                                  01033000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 01034000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                01035000
ZZ2A     EQU   ZZ2+272                                                  01036000
ZZ2AF    EQU   ZZ2A+16                                                  01037000
ZZ2APID  EQU   ZZ2A+64                                                  01038000
ZZ2AD    EQU   ZZ2A+74                                                  01039000
ZZ2ADD   EQU   ZZ2AD                                                    01040000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 01041000
ZZ2ADM   EQU   ZZ2AD+46                                                 01042000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 01043000
ZZ2ADP   EQU   ZZ2AD+56                                                 01044000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 01045000
ZZ2AZZ6P EQU   ZZ2A+140                                                 01046000
ZZ2AQAS  EQU   ZZ2A+144                                                 01047000
ZZ2AQD   EQU   ZZ2A+160                                                 01048000
ZZ2AQDT  EQU   ZZ2AQD+10                                                01049000
ZZ2AQDF  EQU   ZZ2AQD+52                                                01050000
ZZ2STG   EQU   ZZ2+960                                                  01051000
ZZ2ALLOP EQU   ZZ2+992                                                  01052000
ZZ2FREEP EQU   ZZ2+996                                                  01053000
ZZ2FF19P EQU   ZZ2+1000                                                 01054000
ZZ2FRE1P EQU   ZZ2+1004                                                 01055000
ZZ2FF18P EQU   ZZ2+1008                                                 01056000
ZZ2DYNAP EQU   ZZ2+1012                                                 01057000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 01058000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 01059000
ZZ2STAIP EQU   ZZ2+1024                                                 01060000
ZZ2FF02P EQU   ZZ2+1028                                                 01061000
ZZ2GETLP EQU   ZZ2+1032                                                 01062000
ZZ2PARSP EQU   ZZ2+1036                                                 01063000
ZZ2PTGTP EQU   ZZ2+1040                                                 01064000
ZZ2PUTLP EQU   ZZ2+1044                                                 01065000
ZZ2SCANP EQU   ZZ2+1048                                                 01066000
ZZ2STCKP EQU   ZZ2+1052                                                 01067000
ZZ2TRMOP EQU   ZZ2+1064                                                 01068000
ZZ2TRMVP EQU   ZZ2+1068                                                 01069000
ZZ2PUTNP EQU   ZZ2+1084                                                 01070000
ZZ2TRMNP EQU   ZZ2+1088                                                 01071000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 01072000
ZZ2BVTP  EQU   ZZ2+1280                                                 01073000
ZZ2RVTP  EQU   ZZ2+1284                                                 01074000
ZZ2CPPL  EQU   ZZ2+1292                                                 01075000
ZZ2CPPLC EQU   ZZ2CPPL                                                  01076000
ZZ2ITR   EQU   ZZ2+2840                                                 01077000
ZZ2ITRE  EQU   ZZ2ITR+16                                                01078000
ZZ2ITSE  EQU   ZZ2+2864                                                 01079000
ZZ2ES    EQU   ZZ2+2872                                                 01080000
ZZ2AMDX  EQU   ZZ2+7160                                                 01081000
ZZ2AXO   EQU   ZZ2+7934                                                 01082000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 01083000
CMD      EQU   0                                                        01084000
CMDT     EQU   CMD+4                                                    01085000
PSCB     EQU   0                                                        01086000
PSCBATR1 EQU   PSCB+16                                                  01087000
ECT      EQU   0                                                        01088000
ECTSWS   EQU   ECT+28                                                   01089000
ECTSWS2  EQU   ECT+40                                                   01090000
ECTSWS21 EQU   ECTSWS2                                                  01091000
UPT      EQU   0                                                        01092000
UPTSWS   EQU   UPT+12                                                   01093000
SA       EQU   0                                                        01094000
SA1      EQU   SA                                                       01095000
SAR      EQU   SA+12                                                    01096000
SAR1     EQU   SAR+12                                                   01097000
BLSUMPK1 EQU   0                                                        01098000
BLSUPUTA EQU   0                                                        01099000
BVT      EQU   0                                                        01100000
BVTPUTLP EQU   BVT+4                                                    01101000
BVTPUTOP EQU   BVT+12                                                   01102000
BVTPUTTP EQU   BVT+16                                                   01103000
BVTPUTVP EQU   BVT+20                                                   01104000
BVTPUTAP EQU   BVT+24                                                   01105000
BVTPRTTP EQU   BVT+28                                                   01106000
BVTPRTAP EQU   BVT+32                                                   01107000
BVTPUTDP EQU   BVT+36                                                   01108000
BVTMONP  EQU   BVT+40                                                   01109000
BVTMON2P EQU   BVT+44                                                   01110000
BVTVSARP EQU   BVT+48                                                   01111000
BVTVSENP EQU   BVT+64                                                   01112000
BVTVSERP EQU   BVT+68                                                   01113000
BVTVSGEP EQU   BVT+72                                                   01114000
BVTVSGUP EQU   BVT+76                                                   01115000
BVTVSPOP EQU   BVT+80                                                   01116000
BVTVSPUP EQU   BVT+84                                                   01117000
BVTMPKNP EQU   BVT+104                                                  01118000
BVTMONLP EQU   BVT+108                                                  01119000
BVTPUTCP EQU   BVT+132                                                  01120000
BVTMPK1P EQU   BVT+136                                                  01121000
BVTZZ2RP EQU   BVT+140                                                  01122000
BVTPGMRP EQU   BVT+144                                                  01123000
BVTMONAP EQU   BVT+148                                                  01124000
BVTBLDDP EQU   BVT+152                                                  01125000
BVTBLDLP EQU   BVT+156                                                  01126000
BVTPGMCP EQU   BVT+160                                                  01127000
BVTPGMDP EQU   BVT+164                                                  01128000
BVTPGMLP EQU   BVT+168                                                  01129000
BVTMONCP EQU   BVT+180                                                  01130000
BVTMONDP EQU   BVT+184                                                  01131000
BVTMONTP EQU   BVT+188                                                  01132000
BVTPARIP EQU   BVT+192                                                  01133000
BVTPARUP EQU   BVT+196                                                  01134000
BVTPRTNP EQU   BVT+204                                                  01135000
BVTVSCRP EQU   BVT+208                                                  01136000
BVTVSMRP EQU   BVT+212                                                  01137000
BVTMONXP EQU   BVT+216                                                  01138000
BVTTRMAP EQU   BVT+228                                                  01139000
ZZ6      EQU   0                                                        01140000
ZZ6D     EQU   ZZ6+128                                                  01141000
ZZ6DD    EQU   ZZ6D+8                                                   01142000
ZZ6DDT   EQU   ZZ6DD+4                                                  01143000
ZZ6DQA   EQU   ZZ6D+68                                                  01144000
ZZ6DF    EQU   ZZ6D+92                                                  01145000
ZZ6B     EQU   ZZ6+768                                                  01146000
RVT      EQU   0                                                        01147000
RVTADDRP EQU   RVT                                                      01148000
RVTT01P  EQU   RVT+4                                                    01149000
RVTTAP   EQU   RVT+8                                                    01150000
RVTTBP   EQU   RVT+12                                                   01151000
RVTTCP   EQU   RVT+16                                                   01152000
RVTTFP   EQU   RVT+24                                                   01153000
RVTTYP   EQU   RVT+40                                                   01154000
RVTT02P  EQU   RVT+48                                                   01155000
RVTT03P  EQU   RVT+52                                                   01156000
RVTT04P  EQU   RVT+56                                                   01157000
RVTACCLP EQU   RVT+60                                                   01158000
RVTRACCP EQU   RVT+64                                                   01159000
RVTTLP   EQU   RVT+68                                                   01160000
RVTTMP   EQU   RVT+72                                                   01161000
RVTTUP   EQU   RVT+80                                                   01162000
RVTESGEP EQU   RVT+84                                                   01163000
RVTESGUP EQU   RVT+88                                                   01164000
RVTESARP EQU   RVT+92                                                   01165000
RVTRAARP EQU   RVT+96                                                   01166000
RVTRAGEP EQU   RVT+100                                                  01167000
RVTADDPP EQU   RVT+104                                                  01168000
RVTACCQP EQU   RVT+108                                                  01169000
RVTSAGUP EQU   RVT+124                                                  01170000
RVTSAGEP EQU   RVT+128                                                  01171000
RVTESCKP EQU   RVT+132                                                  01172000
RVTMSGAP EQU   RVT+136                                                  01173000
RVTMSGDP EQU   RVT+140                                                  01174000
RVTADDTP EQU   RVT+160                                                  01175000
RVTADDUP EQU   RVT+164                                                  01176000
RVTADD1P EQU   RVT+176                                                  01177000
RVTADD2P EQU   RVT+180                                                  01178000
RVTRSAGP EQU   RVT+184                                                  01179000
RVTMSGBP EQU   RVT+188                                                  01180000
RVTADDSP EQU   RVT+192                                                  01181000
RVTADD3P EQU   RVT+196                                                  01182000
RVTT05P  EQU   RVT+200                                                  01183000
RVTPADSP EQU   RVT+204                                                  01184000
RVTTRP   EQU   RVT+228                                                  01185000
RVTADD4P EQU   RVT+232                                                  01186000
RVTSAPCP EQU   RVT+236                                                  01187000
RVTSAARP EQU   RVT+240                                                  01188000
RVTSAGNP EQU   RVT+244                                                  01189000
RVTT06P  EQU   RVT+248                                                  01190000
RVTSAGCP EQU   RVT+252                                                  01191000
RVTSAGQP EQU   RVT+256                                                  01192000
RVTESGCP EQU   RVT+260                                                  01193000
RVTESGQP EQU   RVT+264                                                  01194000
RVTDUCKP EQU   RVT+276                                                  01195000
RVTDUCCP EQU   RVT+280                                                  01196000
I001C    EQU   0                                                        01197000
BLSRACC  EQU   0                                                        01198000
BLSRACCL EQU   0                                                        01199000
BLSRACCQ EQU   0                                                        01200000
BLSRADDP EQU   0                                                        01201000
BLSRADDR EQU   0                                                        01202000
BLSRADDS EQU   0                                                        01203000
BLSRADDT EQU   0                                                        01204000
BLSRADDU EQU   0                                                        01205000
BLSRADD1 EQU   0                                                        01206000
BLSRADD2 EQU   0                                                        01207000
BLSRADD3 EQU   0                                                        01208000
BLSRADD4 EQU   0                                                        01209000
BLSRDUCC EQU   0                                                        01210000
BLSRDUCK EQU   0                                                        01211000
BLSRESAR EQU   0                                                        01212000
BLSRESCK EQU   0                                                        01213000
BLSRESGC EQU   0                                                        01214000
BLSRESGE EQU   0                                                        01215000
BLSRESGQ EQU   0                                                        01216000
BLSRESGU EQU   0                                                        01217000
BLSRMSGA EQU   0                                                        01218000
BLSRMSGB EQU   0                                                        01219000
BLSRMSGD EQU   0                                                        01220000
BLSRPADS EQU   0                                                        01221000
BLSRRAAR EQU   0                                                        01222000
BLSRRAGE EQU   0                                                        01223000
BLSRSAAR EQU   0                                                        01224000
BLSRSAG  EQU   0                                                        01225000
BLSRSAGC EQU   0                                                        01226000
BLSRSAGE EQU   0                                                        01227000
BLSRSAGN EQU   0                                                        01228000
BLSRSAGQ EQU   0                                                        01229000
BLSRSAGU EQU   0                                                        01230000
BLSRSAPC EQU   0                                                        01231000
BLSTA    EQU   0                                                        01232000
BLSTB    EQU   0                                                        01233000
BLSTC    EQU   0                                                        01234000
BLSTF    EQU   0                                                        01235000
BLSTL    EQU   0                                                        01236000
BLSTM    EQU   0                                                        01237000
BLSTR    EQU   0                                                        01238000
BLSTU    EQU   0                                                        01239000
BLSTY    EQU   0                                                        01240000
BLST01   EQU   0                                                        01241000
BLST02   EQU   0                                                        01242000
BLST03   EQU   0                                                        01243000
BLST04   EQU   0                                                        01244000
BLST05   EQU   0                                                        01245000
BLST06   EQU   0                                                        01246000
BLSUALLO EQU   0                                                        01247000
BLSUBLDD EQU   0                                                        01248000
BLSUBLDL EQU   0                                                        01249000
BLSUDYNA EQU   0                                                        01250000
BLSUFREE EQU   0                                                        01251000
BLSUFRE1 EQU   0                                                        01252000
BLSUMON  EQU   0                                                        01253000
BLSUMONA EQU   0                                                        01254000
BLSUMONC EQU   0                                                        01255000
BLSUMOND EQU   0                                                        01256000
BLSUMONL EQU   0                                                        01257000
BLSUMONT EQU   0                                                        01258000
BLSUMONX EQU   0                                                        01259000
BLSUMON2 EQU   0                                                        01260000
BLSUMPKN EQU   0                                                        01261000
BLSUPARI EQU   0                                                        01262000
BLSUPARU EQU   0                                                        01263000
BLSUPGMC EQU   0                                                        01264000
BLSUPGMD EQU   0                                                        01265000
BLSUPGML EQU   0                                                        01266000
BLSUPGMR EQU   0                                                        01267000
BLSUPRTA EQU   0                                                        01268000
BLSUPRTN EQU   0                                                        01269000
BLSUPRTT EQU   0                                                        01270000
BLSUPUTC EQU   0                                                        01271000
BLSUPUTD EQU   0                                                        01272000
BLSUPUTL EQU   0                                                        01273000
BLSUPUTN EQU   0                                                        01274000
BLSUPUTO EQU   0                                                        01275000
BLSUPUTT EQU   0                                                        01276000
BLSUPUTV EQU   0                                                        01277000
BLSUSTAI EQU   0                                                        01278000
BLSUTRMA EQU   0                                                        01279000
BLSUTRMN EQU   0                                                        01280000
BLSUTRMO EQU   0                                                        01281000
BLSUTRMV EQU   0                                                        01282000
BLSUVSAR EQU   0                                                        01283000
BLSUVSCR EQU   0                                                        01284000
BLSUVSEN EQU   0                                                        01285000
BLSUVSER EQU   0                                                        01286000
BLSUVSGE EQU   0                                                        01287000
BLSUVSGU EQU   0                                                        01288000
BLSUVSMR EQU   0                                                        01289000
BLSUVSPO EQU   0                                                        01290000
BLSUVSPU EQU   0                                                        01291000
BLSUZZ2C EQU   0                                                        01292000
BLSUZZ2D EQU   0                                                        01293000
BLSUZZ2R EQU   0                                                        01294000
IKJEFF02 EQU   0                                                        01295000
IKJEFF18 EQU   0                                                        01296000
IKJEFF19 EQU   0                                                        01297000
IKJGETL  EQU   0                                                        01298000
IKJPARS  EQU   0                                                        01299000
IKJPTGT  EQU   0                                                        01300000
IKJPUTL  EQU   0                                                        01301000
IKJSCAN  EQU   0                                                        01302000
IKJSTCK  EQU   0                                                        01303000
I008P    EQU   0                                                        01304000
I015F    EQU   0                                                        01305000
I015P    EQU   0                                                        01306000
I031F    EQU   0                                                        01307000
I031P    EQU   0                                                        01308000
I256C    EQU   0                                                        01309000
PZ2      EQU   0                                                        01310000
ESPA     EQU   0                                                        01311000
ESPAAS   EQU   ESPA+60                                                  01312000
ESPALAD  EQU   ESPA+76                                                  01313000
ESPAD    EQU   ESPA+80                                                  01314000
ESPADOF  EQU   ESPAD                                                    01315000
ESPADLE  EQU   ESPAD+4                                                  01316000
ESPADT   EQU   ESPAD+10                                                 01317000
ESPADIM  EQU   ESPAD+44                                                 01318000
ESPADF   EQU   ESPAD+52                                                 01319000
ESPAF    EQU   ESPA+161                                                 01320000
ESPAFS   EQU   ESPAF                                                    01321000
ESPAFC   EQU   ESPAF+1                                                  01322000
ESPAR    EQU   ESPA+180                                                 01323000
ESPART   EQU   ESPAR+2                                                  01324000
BLK      EQU   0                                                        01325000
CPPL     EQU   ZZ2CPPL                                                  01326000
CPPLUPT  EQU   CPPL+4                                                   01327000
CPPLPSCB EQU   CPPL+8                                                   01328000
CPPLECT  EQU   CPPL+12                                                  01329000
PTRPTR   EQU   PTRBIT                                                   01330000
@RC00177 EQU   @RC00175                                                 01787000
@RC00187 EQU   @RC00177                                                 01788000
L020     EQU   @RC00177                                                 01789000
@ENDDATA EQU   *                                                        01790000
         END   BLSTM4                                           DSKC440 01791000
