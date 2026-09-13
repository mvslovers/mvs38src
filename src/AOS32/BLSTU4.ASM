TU4      TITLE 'BLSTU4  --IPCS SERVICE ROUTINE TO DISPLAY AREA DATA    *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPLK                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSTU4   CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(16)                                             0002 00010000
         DC    C'BLSTU4    78.059'                                 0002 00011000
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
*   MU4B=MU4S;                      /* MESSAGE MU4 LITERAL TEXT      */ 00028000
         MVC   MU4B(72),MU4S                                       0138 00029000
*   MDB=MDS;                        /* MESSAGE MD LITERAL TEXT       */ 00030000
         MVC   MDB(72),MDS                                         0139 00031000
*   LINEADDR=ESPALAD+ESPADOF;       /* DUMP ADDRESS OF DATA LINE     */ 00032000
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
*   IF LINELEN>LENGTH(BUF) THEN                                    0145 00052000
         LA    @14,16                                              0145 00053000
         CR    LINELEN,@14                                         0145 00054000
         BNH   @RF00145                                            0145 00055000
*     LINELEN=LENGTH(BUF)-(LINEADDR&BUFMASK2);/* ALIGN DISPLAY LINES */ 00056000
         LR    LINELEN,LINEADDR                                    0146 00057000
         N     LINELEN,@CF01130                                    0146 00058000
         SLR   @14,LINELEN                                         0146 00059000
         LR    LINELEN,@14                                         0146 00060000
*   ELSE                                                           0147 00061000
*     FLAGL='1'B;                   /* LEFT-JUSTIFY LINE             */ 00062000
         B     @RC00145                                            0147 00063000
@RF00145 OI    FLAGL,B'00010000'                                   0147 00064000
*   DUPLEN=0;                       /* LENGTH OF REPETITIVE AREA     */ 00065000
@RC00145 SLR   DUPLEN,DUPLEN                                       0148 00066000
*   RETC=ZZZFLAGI;                  /* RETURN CODE                   */ 00067000
*                                                                  0149 00068000
         SLR   RETC,RETC                                           0149 00069000
*   /*****************************************************************/ 00070000
*   /*                                                               */ 00071000
*   /* ITERATIVELY RETRIEVE AND DISPLAY DUMP DATA UNTIL THE REQUEST  */ 00072000
*   /* IS PROCESSED. STOP IF INTERRUPTED BY ATTN                     */ 00073000
*   /*                                                               */ 00074000
*   /*****************************************************************/ 00075000
*                                                                  0150 00076000
*   DO WHILE(FLAGEND='0'B);         /* LOOP PROCESSING THE DATA      */ 00077000
         B     @DE00150                                            0150 00078000
@DL00150 DS    0H                                                  0151 00079000
*     DO;                           /* BLRCNVPC(LINEADDR) FROM(POINTE   00080000
*                                      R)TO(CHARACTER)SET(MU4BT10)REM   00081000
*                                      ARK(OUTPUT LINE             0151 00082000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00083000
*                                                                  0151 00084000
*       /*************************************************************/ 00085000
*       /*                                                           */ 00086000
*       /* OUTPUT LINE ADDRESS                                       */ 00087000
*       /*                                                           */ 00088000
*       /*************************************************************/ 00089000
*                                                                  0152 00090000
*       PTRPTR=LINEADDR;            /* SOURCE TO BIT/POINTER       0152 00091000
*                                      INTERMEDIATE                  */ 00092000
         ST    LINEADDR,PTRPTR                                     0152 00093000
*       UNPK(MU4BT10(1:LENGTH(MU4BT10)-1),PTRBIT);/* BIT=>ZONED    0153 00094000
*                                      HEXADECIMAL                   */ 00095000
         UNPK  MU4BT10(5),PTRBIT(4)                                0153 00096000
*       MU4BT10(LENGTH(MU4BT10):LENGTH(MU4BT10))=PTRBIT(25:32);/*  0154 00097000
*                                      FINAL ZONED HEXADECIMAL DIGIT */ 00098000
         MVC   MU4BT10+5(1),PTRBIT+3                               0154 00099000
*       TR(MU4BT10,ZZ1TRHEX);       /* ZONED HEXADECIMAL=>EBCDIC     */ 00100000
         L     @14,ZZ2ZZ1P(,R9)                                    0155 00101000
         TR    MU4BT10(6),ZZ1TRHEX(@14)                            0155 00102000
*     END;                          /* BLRCNVPC(LINEADDR) FROM(POINTE   00103000
*                                      R)TO(CHARACTER)SET(MU4BT10)REM   00104000
*                                      ARK(OUTPUT LINE             0156 00105000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00106000
*     MVCLD2L=LINELEN;              /* DATA BYTES IN THIS LINE       */ 00107000
         STCM  LINELEN,7,MVCLD2L                                   0157 00108000
*     IF LINELEN=LENGTH(BUF) THEN                                  0158 00109000
*                                                                  0158 00110000
         C     LINELEN,@CF00061                                    0158 00111000
         BNE   @RF00158                                            0158 00112000
*       /*************************************************************/ 00113000
*       /*                                                           */ 00114000
*       /* FULL DATA LINE                                            */ 00115000
*       /*                                                           */ 00116000
*       /*************************************************************/ 00117000
*                                                                  0159 00118000
*       DO;                         /* FULL DATA LINE                */ 00119000
*         IF FLAGF='1'B THEN                                       0160 00120000
*                                                                  0160 00121000
         TM    FLAGF,B'00100000'                                   0160 00122000
         BNO   @RF00160                                            0160 00123000
*           /*********************************************************/ 00124000
*           /*                                                       */ 00125000
*           /* LOCAL BUFFER FULL                                     */ 00126000
*           /*                                                       */ 00127000
*           /*********************************************************/ 00128000
*                                                                  0161 00129000
*           DO;                     /* LOCAL BUFFER FULL             */ 00130000
*             RESPECIFY             /* BEFORE CLCL                   */ 00131000
*              (R0,                 /* ->BUF                         */ 00132000
*               R1,                 /* LENGTH(BUF)                   */ 00133000
*               RE) RESTRICTED;     /* ->PARAMETER BUFFER            */ 00134000
*             LM(RE,R1,MVCLD);      /* DESCRIBE TARGET DATA LINE     */ 00135000
         LM    RE,R1,MVCLD                                         0163 00136000
*             RF=R1;                /* DESCRIBE SOURCE DATA LINE     */ 00137000
         LR    RF,R1                                               0164 00138000
*             CLCL(R0,RE);          /* CHECK FOR REPETITIVE LINE     */ 00139000
         CLCL  R0,RE                                               0165 00140000
*             RESPECIFY             /* AFTER CLCL                    */ 00141000
*              (R0,                 /* DESTROYED                     */ 00142000
*               R1,                 /* DESTROYED                     */ 00143000
*               RE) UNRESTRICTED;   /* DESTROYED                     */ 00144000
*             BC(8,L010);           /* REPETITIVE LINE               */ 00145000
         BC    8,L010                                              0167 00146000
*             FLAGN='1'B;           /* NEW DATA                      */ 00147000
         OI    FLAGN,B'00001000'                                   0168 00148000
*             GO TO L020;           /* COMMON PROCESSING PATH        */ 00149000
         B     L020                                                0169 00150000
*L010:                              /* REPETITIVE LINE               */ 00151000
*             IF FLAGD='0'B THEN                                   0170 00152000
*                                                                  0170 00153000
L010     TM    FLAGD,B'10000000'                                   0170 00154000
         BNZ   @RF00170                                            0170 00155000
*               /*****************************************************/ 00156000
*               /*                                                   */ 00157000
*               /* FIRST LINE OF REPETITIVE DATA                     */ 00158000
*               /*                                                   */ 00159000
*               /*****************************************************/ 00160000
*                                                                  0171 00161000
*               DO;                 /* FIRST LINE OF REPETITIVE DATA */ 00162000
*                 CALL E100;        /* BEGIN REPETITIVE DATA         */ 00163000
         BAL   @14,E100                                            0172 00164000
*                 MDBT5=TD;         /* LITERAL TEXT                  */ 00165000
         MVI   MDBT5+13,C' '                                       0173 00166000
         MVC   MDBT5+14(22),MDBT5+13                               0173 00167000
         MVC   MDBT5(13),TD                                        0173 00168000
*                 MDBL=LENGTH(MDB)-LENGTH(MDBT5)+LENGTH(TD);/* LENGTH*/ 00169000
         MVC   MDBL(2),@CH01172                                    0174 00170000
*               END;                                               0175 00171000
*             ELSE                                                 0176 00172000
*               DUPLEN=DUPLEN+LINELEN;/* LENGTH OF REPETITIVE AREA   */ 00173000
         B     @RC00170                                            0176 00174000
@RF00170 ALR   DUPLEN,LINELEN                                      0176 00175000
*L020:                              /* COMMON PROCESSING PATH        */ 00176000
*           END;                                                   0177 00177000
*         ELSE                                                     0178 00178000
*                                                                  0178 00179000
*           /*********************************************************/ 00180000
*           /*                                                       */ 00181000
*           /* LOCAL BUFFER EMPTY OR PARTIALLY FILLED                */ 00182000
*           /*                                                       */ 00183000
*           /*********************************************************/ 00184000
*                                                                  0178 00185000
*           DO;                     /* EMPTY OR PARTIALLY FILLED     */ 00186000
         B     @RC00160                                            0178 00187000
@RF00160 DS    0H                                                  0179 00188000
*             MVCLD2P=ADDR(BUF);    /* ->INITIAL TARGET BYTE         */ 00189000
         LA    @14,BUF                                             0179 00190000
         ST    @14,MVCLD2P                                         0179 00191000
*             FLAGF='1'B;           /* FULL DATA LINE                */ 00192000
*             FLAGN='1'B;           /* NEW DATA LINE                 */ 00193000
         OI    FLAGF,B'00101000'                                   0181 00194000
*           END;                                                   0182 00195000
*       END;                                                       0183 00196000
*     ELSE                                                         0184 00197000
*                                                                  0184 00198000
*       /*************************************************************/ 00199000
*       /*                                                           */ 00200000
*       /* PARTIAL DATA LINE                                         */ 00201000
*       /*                                                           */ 00202000
*       /*************************************************************/ 00203000
*                                                                  0184 00204000
*       DO;                         /* PARTIAL DATA LINE             */ 00205000
         B     @RC00158                                            0184 00206000
@RF00158 DS    0H                                                  0185 00207000
*         BUF=' ';                  /* PAD WITH EBCDIC BLANKS        */ 00208000
         MVI   BUF+1,C' '                                          0185 00209000
         MVC   BUF+2(14),BUF+1                                     0185 00210000
         MVI   BUF,C' '                                            0185 00211000
*         IF FLAGL='1'B THEN                                       0186 00212000
         TM    FLAGL,B'00010000'                                   0186 00213000
         BNO   @RF00186                                            0186 00214000
*           MVCLD2P=ADDR(BUF);      /* LEFT-JUSTIFY DATA             */ 00215000
         LA    @14,BUF                                             0187 00216000
         ST    @14,MVCLD2P                                         0187 00217000
*         ELSE                                                     0188 00218000
*           MVCLD2P=ADDR(BUF)+LENGTH(BUF)-LINELEN;/* RIGHT-JUSTIFY   */ 00219000
         B     @RC00186                                            0188 00220000
@RF00186 LA    @14,BUF                                             0188 00221000
         AL    @14,@CF00061                                        0188 00222000
         SLR   @14,LINELEN                                         0188 00223000
         ST    @14,MVCLD2P                                         0188 00224000
*         FLAGN='1'B;               /* NEW DATA LINE                 */ 00225000
@RC00186 OI    FLAGN,B'00001000'                                   0189 00226000
*       END;                                                       0190 00227000
*     RESPECIFY                     /* BEFORE MVCL                   */ 00228000
*      (R0,                         /* ->BUF                         */ 00229000
*       R1,                         /* LENGTH(BUF)                   */ 00230000
*       RE) RESTRICTED;             /* ->PARAMETER BUFFER            */ 00231000
@RC00158 DS    0H                                                  0192 00232000
*     LM(RE,R1,MVCLD);              /* DESCRIBE SOURCE AND TARGET    */ 00233000
         LM    RE,R1,MVCLD                                         0192 00234000
*     MVCL(R0,RE);                  /* MOVE DATA FOR ONE LINE        */ 00235000
         MVCL  R0,RE                                               0193 00236000
*     BC(4,L030);                   /* REQUEST NOT YET SATISFIED     */ 00237000
         BC    4,L030                                              0194 00238000
*     FLAGEND='1'B;                 /* REQUEST HAS BEEN SATISFIED    */ 00239000
         OI    FLAGEND,B'01000000'                                 0195 00240000
*     GO TO L040;                   /* COMMON PROCESSING PATH        */ 00241000
         B     L040                                                0196 00242000
*L030:                              /* REQUEST NOT YET SATISFIED     */ 00243000
*     STM(RE,RF,MVCLD1);            /* DESCRIBE DATA REMAINING       */ 00244000
L030     STM   RE,RF,MVCLD1                                        0197 00245000
*     RESPECIFY                     /* AFTER MVCL                    */ 00246000
*      (R0,                         /* DESTROYED                     */ 00247000
*       R1,                         /* DESTROYED                     */ 00248000
*       RE) UNRESTRICTED;           /* ->PARAMETER BUFFER+LINE LENGTH*/ 00249000
*L040:                              /* COMMON PROCESSING PATH        */ 00250000
*     IF FLAGD='1'B&(FLAGN='1'B×FLAGEND='1'B) THEN                 0199 00251000
*                                                                  0199 00252000
L040     TM    FLAGD,B'10000000'                                   0199 00253000
         BNO   @RF00199                                            0199 00254000
         TM    FLAGN,B'01001000'                                   0199 00255000
         BZ    @RF00199                                            0199 00256000
*       /*************************************************************/ 00257000
*       /*                                                           */ 00258000
*       /* END OF REPETITIVE DATA--SUMMARIZE                         */ 00259000
*       /*                                                           */ 00260000
*       /*************************************************************/ 00261000
*                                                                  0200 00262000
*       DO;                         /* END OF REPETITIVE DATA        */ 00263000
*         DO;                       /* BLRCNVUC(DUPLEN) FROM(UNSIGNED   00264000
*                                      BINARY)TO(CHARACTER)SET(MDBT3)   00265000
*                                      PATTERN('40202020202020202120'   00266000
*                                      X)OPTIONS(PATTERN IN        0201 00267000
*                                      PLACE)REMARK(LENGTH OF      0201 00268000
*                                      REPETITIVE DATA)              */ 00269000
*                                                                  0201 00270000
*           /*********************************************************/ 00271000
*           /*                                                       */ 00272000
*           /* LENGTH OF REPETITIVE DATA                             */ 00273000
*           /*                                                       */ 00274000
*           /*********************************************************/ 00275000
*                                                                  0202 00276000
*           CVD(DUPLEN,PACKED);     /* UNSIGNED BINARY=>PACKED     0202 00277000
*                                      DECIMAL                       */ 00278000
         CVD   DUPLEN,PACKED                                       0202 00279000
*           ED(MDBT3,PACKED(25:64));/* PACKED DECIMAL=>EBCDIC        */ 00280000
         ED    MDBT3(10),PACKED+3                                  0203 00281000
*         END;                      /* BLRCNVUC(DUPLEN) FROM(UNSIGNED   00282000
*                                      BINARY)TO(CHARACTER)SET(MDBT3)   00283000
*                                      PATTERN('40202020202020202120'   00284000
*                                      X)OPTIONS(PATTERN IN        0204 00285000
*                                      PLACE)REMARK(LENGTH OF      0204 00286000
*                                      REPETITIVE DATA)              */ 00287000
*         CALL BLSUMPK1(ZZ2,MDB);   /* REMOVE EXTRANEOUS BLANKS      */ 00288000
         ST    R9,@AL00001                                         0205 00289000
         LA    @14,MDB                                             0205 00290000
         ST    @14,@AL00001+4                                      0205 00291000
         L     @01,ZZ2BVTP(,R9)                                    0205 00292000
         L     @15,BVTMPK1P(,@01)                                  0205 00293000
         LA    @01,@AL00001                                        0205 00294000
         BALR  @14,@15                                             0205 00295000
*         CALL BLSUPUTA(ZZ2,MDB);   /* DISPLAY MESSAGE MD            */ 00296000
         ST    R9,@AL00001                                         0206 00297000
         LA    @14,MDB                                             0206 00298000
         ST    @14,@AL00001+4                                      0206 00299000
         L     @01,ZZ2BVTP(,R9)                                    0206 00300000
         L     @15,BVTPUTAP(,@01)                                  0206 00301000
         LA    @01,@AL00001                                        0206 00302000
         BALR  @14,@15                                             0206 00303000
*         FLAGD='0'B;               /* END OF REPETITIVE DATA        */ 00304000
         NI    FLAGD,B'01111111'                                   0207 00305000
*         MDB=MDS;                  /* MESSAGE MD LITERAL TEXT       */ 00306000
         MVC   MDB(72),MDS                                         0208 00307000
*       END;                                                       0209 00308000
*     IF FLAGEND='0'B&FLAGN='1'B&LINELEN>1 THEN                    0210 00309000
*                                                                  0210 00310000
@RF00199 TM    FLAGN,B'00001000'                                   0210 00311000
         BNO   @RF00210                                            0210 00312000
         TM    FLAGEND,B'01000000'                                 0210 00313000
         BNZ   @RF00210                                            0210 00314000
         C     LINELEN,@CF00050                                    0210 00315000
         BNH   @RF00210                                            0210 00316000
*       /*************************************************************/ 00317000
*       /*                                                           */ 00318000
*       /* CHECK FOR REPETITION OF A SINGLE CHARACTER VALUE          */ 00319000
*       /*                                                           */ 00320000
*       /*************************************************************/ 00321000
*                                                                  0211 00322000
*       DO;                         /* CHECK FOR REPETITION          */ 00323000
*         RESPECIFY                 /* BEFORE CLCL                   */ 00324000
*          (R0,                     /* IGNORED                       */ 00325000
*           R1,                     /* INITIAL CHARACTER OF DATA     */ 00326000
*           RE) RESTRICTED;         /* ->BUF                         */ 00327000
*         LM(RE,RF,MVCLD2);         /* DESCRIBE CURRENT DATA LINE    */ 00328000
         LM    RE,RF,MVCLD2                                        0213 00329000
*         MVCLD2C=RE->I001C;        /* PADDING CHARACTER             */ 00330000
         MVC   MVCLD2C(1),I001C(RE)                                0214 00331000
*         MVCLD2L=0;                /* CONSIDER ONLY PADDING CHAR.   */ 00332000
         SLR   @05,@05                                             0215 00333000
         STCM  @05,7,MVCLD2L                                       0215 00334000
*         LM(R0,R1,MVCLD2);         /* DESCRIBE REPETITIVE VALUE     */ 00335000
         LM    R0,R1,MVCLD2                                        0216 00336000
*         CLCL(RE,R0);              /* CHECK FOR REPETITIVE VALUE    */ 00337000
         CLCL  RE,R0                                               0217 00338000
*         RESPECIFY                 /* AFTER CLCL                    */ 00339000
*          (R0,                     /* DESTROYED                     */ 00340000
*           R1,                     /* DESTROYED                     */ 00341000
*           RE) UNRESTRICTED;       /* DESTROYED                     */ 00342000
*         BC(7,L050);               /* NEW DATA LINE                 */ 00343000
         BC    7,L050                                              0219 00344000
*         CALL E100;                /* BEGIN REPETITIVE DATA         */ 00345000
         BAL   @14,E100                                            0220 00346000
*         MDBT5=MDST5;              /* LITERAL TEXT                  */ 00347000
         MVC   MDBT5(36),MDST5                                     0221 00348000
*         DO;                       /* BLRCNVXC(MVCLD2C) FROM(BS)TO(C   00349000
*                                      HARACTER)SET(MDBT51)REMARK(REP   00350000
*                                      ETITIVE VALUE--HEXADECIMAL  0222 00351000
*                                      TRANSLATION)TR(ZZ1TRHEX)      */ 00352000
*                                                                  0222 00353000
*           /*********************************************************/ 00354000
*           /*                                                       */ 00355000
*           /* REPETITIVE VALUE--HEXADECIMAL TRANSLATION             */ 00356000
*           /*                                                       */ 00357000
*           /*********************************************************/ 00358000
*                                                                  0223 00359000
*           UNPK(MDBT51(1:LENGTH(MDBT51)-1),MVCLD2C);/* BIT=>ZONED 0223 00360000
*                                      HEXADECIMAL                   */ 00361000
         UNPK  MDBT51(1),MVCLD2C(1)                                0223 00362000
*           MDBT51(LENGTH(MDBT51):LENGTH(MDBT51))=MVCLD2C(LENGTH(  0224 00363000
*               MVCLD2C):LENGTH(MVCLD2C));/* FINAL ZONED HEXADECIMAL    00364000
*                                      DIGIT                         */ 00365000
         MVC   MDBT51+1(1),MVCLD2C                                 0224 00366000
*           TR(MDBT51,ZZ1TRHEX);    /* ZONED HEXADECIMAL=>EBCDIC     */ 00367000
         L     @14,ZZ2ZZ1P(,R9)                                    0225 00368000
         TR    MDBT51(2),ZZ1TRHEX(@14)                             0225 00369000
*         END;                      /* BLRCNVXC(MVCLD2C) FROM(BS)TO(C   00370000
*                                      HARACTER)SET(MDBT51)REMARK(REP   00371000
*                                      ETITIVE VALUE--HEXADECIMAL  0226 00372000
*                                      TRANSLATION)TR(ZZ1TRHEX)      */ 00373000
*         MDBT531=MVCLD2C;          /* EBCDIC REPETITIVE VALUE       */ 00374000
         MVC   MDBT531(1),MVCLD2C                                  0227 00375000
*         TR(MDBT531,ZZ1TREBC);     /* NONGRAPHIC==>BLANK            */ 00376000
         TR    MDBT531(1),ZZ1TREBC(@14)                            0228 00377000
*         IF MDBT531=MVCLD2C THEN                                  0229 00378000
         CLC   MDBT531(1),MVCLD2C                                  0229 00379000
         BNE   @RF00229                                            0229 00380000
*           MDBL=MDSL;              /* MESSAGE LENGTH                */ 00381000
         LH    @14,MDSL                                            0230 00382000
         N     @14,@CF01182                                        0230 00383000
         STH   @14,MDBL                                            0230 00384000
*         ELSE                                                     0231 00385000
*           MDBL=LENGTH(MDB)-LENGTH(MDBT53);/* MESSAGE LENGTH        */ 00386000
         B     @RC00229                                            0231 00387000
@RF00229 MVC   MDBL(2),@CH00186                                    0231 00388000
*L050:                              /* COMMON PROCESSING PATH        */ 00389000
*         MVCLD2C='00'X;            /* RESET PADDING CHARACTER       */ 00390000
@RC00229 DS    0H                                                  0232 00391000
L050     MVI   MVCLD2C,X'00'                                       0232 00392000
*       END;                                                       0233 00393000
*     IF FLAGN='1'B THEN                                           0234 00394000
*                                                                  0234 00395000
@RF00210 TM    FLAGN,B'00001000'                                   0234 00396000
         BNO   @RF00234                                            0234 00397000
*       /*************************************************************/ 00398000
*       /*                                                           */ 00399000
*       /* NON-REPETITIVE DATA. DISPLAY IT                           */ 00400000
*       /*                                                           */ 00401000
*       /*************************************************************/ 00402000
*                                                                  0235 00403000
*       DO;                         /* NEW BLOCK OBTAINED            */ 00404000
*                                                                  0235 00405000
*         /***********************************************************/ 00406000
*         /*                                                         */ 00407000
*         /* DISPLAY DATA AS BIT STRING                              */ 00408000
*         /*                                                         */ 00409000
*         /***********************************************************/ 00410000
*                                                                  0236 00411000
*         DO;                       /* BLRCNVXC(BUF1) FROM(BS)TO(CHAR   00412000
*                                      ACTER)SET(MU4BT300)REMARK(BIT    00413000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00414000
*                                                                  0236 00415000
*           /*********************************************************/ 00416000
*           /*                                                       */ 00417000
*           /* BIT STRING WORD 1                                     */ 00418000
*           /*                                                       */ 00419000
*           /*********************************************************/ 00420000
*                                                                  0237 00421000
*           UNPK(MU4BT300(1:LENGTH(MU4BT300)-1),BUF1);/* BIT=>ZONED     00422000
*                                      HEXADECIMAL                   */ 00423000
         UNPK  MU4BT300(7),BUF1(4)                                 0237 00424000
*           MU4BT300(LENGTH(MU4BT300):LENGTH(MU4BT300))=BUF1(LENGTH(    00425000
*               BUF1):LENGTH(BUF1));/* FINAL ZONED HEXADECIMAL DIGIT */ 00426000
         MVC   MU4BT300+7(1),BUF1+3                                0238 00427000
*           TR(MU4BT300,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00428000
         L     @14,ZZ2ZZ1P(,R9)                                    0239 00429000
         TR    MU4BT300(8),ZZ1TRHEX(@14)                           0239 00430000
*         END;                      /* BLRCNVXC(BUF1) FROM(BS)TO(CHAR   00431000
*                                      ACTER)SET(MU4BT300)REMARK(BIT    00432000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00433000
*         DO;                       /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00434000
*                                      ACTER)SET(MU4BT310)REMARK(BIT    00435000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00436000
*                                                                  0241 00437000
*           /*********************************************************/ 00438000
*           /*                                                       */ 00439000
*           /* BIT STRING WORD 2                                     */ 00440000
*           /*                                                       */ 00441000
*           /*********************************************************/ 00442000
*                                                                  0242 00443000
*           UNPK(MU4BT310(1:LENGTH(MU4BT310)-1),BUF2);/* BIT=>ZONED     00444000
*                                      HEXADECIMAL                   */ 00445000
         UNPK  MU4BT310(7),BUF2(4)                                 0242 00446000
*           MU4BT310(LENGTH(MU4BT310):LENGTH(MU4BT310))=BUF2(LENGTH(    00447000
*               BUF2):LENGTH(BUF2));/* FINAL ZONED HEXADECIMAL DIGIT */ 00448000
         MVC   MU4BT310+7(1),BUF2+3                                0243 00449000
*           TR(MU4BT310,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00450000
         TR    MU4BT310(8),ZZ1TRHEX(@14)                           0244 00451000
*         END;                      /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00452000
*                                      ACTER)SET(MU4BT310)REMARK(BIT    00453000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00454000
*         DO;                       /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00455000
*                                      ACTER)SET(MU4BT320)REMARK(BIT    00456000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00457000
*                                                                  0246 00458000
*           /*********************************************************/ 00459000
*           /*                                                       */ 00460000
*           /* BIT STRING WORD 3                                     */ 00461000
*           /*                                                       */ 00462000
*           /*********************************************************/ 00463000
*                                                                  0247 00464000
*           UNPK(MU4BT320(1:LENGTH(MU4BT320)-1),BUF3);/* BIT=>ZONED     00465000
*                                      HEXADECIMAL                   */ 00466000
         UNPK  MU4BT320(7),BUF3(4)                                 0247 00467000
*           MU4BT320(LENGTH(MU4BT320):LENGTH(MU4BT320))=BUF3(LENGTH(    00468000
*               BUF3):LENGTH(BUF3));/* FINAL ZONED HEXADECIMAL DIGIT */ 00469000
         MVC   MU4BT320+7(1),BUF3+3                                0248 00470000
*           TR(MU4BT320,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00471000
         TR    MU4BT320(8),ZZ1TRHEX(@14)                           0249 00472000
*         END;                      /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00473000
*                                      ACTER)SET(MU4BT320)REMARK(BIT    00474000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00475000
*         DO;                       /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00476000
*                                      ACTER)SET(MU4BT33)REMARK(BIT     00477000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00478000
*                                                                  0251 00479000
*           /*********************************************************/ 00480000
*           /*                                                       */ 00481000
*           /* BIT STRING WORD 4                                     */ 00482000
*           /*                                                       */ 00483000
*           /*********************************************************/ 00484000
*                                                                  0252 00485000
*           UNPK(MU4BT33(1:LENGTH(MU4BT33)-1),BUF4);/* BIT=>ZONED  0252 00486000
*                                      HEXADECIMAL                   */ 00487000
         UNPK  MU4BT33(7),BUF4(4)                                  0252 00488000
*           MU4BT33(LENGTH(MU4BT33):LENGTH(MU4BT33))=BUF4(LENGTH(BUF4): 00489000
*               LENGTH(BUF4));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00490000
         MVC   MU4BT33+7(1),BUF4+3                                 0253 00491000
*           TR(MU4BT33,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00492000
         TR    MU4BT33(8),ZZ1TRHEX(@14)                            0254 00493000
*         END;                      /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00494000
*                                      ACTER)SET(MU4BT33)REMARK(BIT     00495000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00496000
*         IF LINELEN<LENGTH(BUF) THEN                              0256 00497000
*                                                                  0256 00498000
         LA    @14,16                                              0256 00499000
         CR    LINELEN,@14                                         0256 00500000
         BNL   @RF00256                                            0256 00501000
*           /*********************************************************/ 00502000
*           /*                                                       */ 00503000
*           /* MORE BIT STRING DATA FORMATTED THAN REQUESTED. BLANK  */ 00504000
*           /* THAT OUTPUT FORMATTED BUT NOT REQUESTED.              */ 00505000
*           /*                                                       */ 00506000
*           /*********************************************************/ 00507000
*                                                                  0257 00508000
*           DO;                     /* BLANK IMPROPER OUTPUT         */ 00509000
*             J=((LENGTH(BUF)-LINELEN)/* EXCESS BYTES FORMATTED      */ 00510000
*                 *9)/4;            /* BLANKS TO REINSERT            */ 00511000
         LR    @00,@14                                             0258 00512000
         SLR   @00,LINELEN                                         0258 00513000
         LR    @03,@00                                             0258 00514000
         M     J,@CF01159                                          0258 00515000
         D     J,@CF00047                                          0258 00516000
         LR    J,@03                                               0258 00517000
*             IF FLAGL='1'B THEN                                   0259 00518000
         TM    FLAGL,B'00010000'                                   0259 00519000
         BNO   @RF00259                                            0259 00520000
*               MU4BT3(LENGTH(MU4BT3)+1-J:LENGTH(MU4BT3))=MU4ST3(LENGTH 00521000
*                   (MU4BT3)+1-J:LENGTH(MU4BT3));/* TRAILING BLANKS  */ 00522000
         LA    @14,36                                              0260 00523000
         SLR   @14,J                                               0260 00524000
         LA    @03,MU4BT3-1(@14)                                   0260 00525000
         LA    @05,35                                              0260 00526000
         SLR   @05,@14                                             0260 00527000
         LA    @04,MU4ST3-1(@14)                                   0260 00528000
         EX    @05,@SM01183                                        0260 00529000
*             ELSE                                                 0261 00530000
*               MU4BT3(1:J)=MU4ST3(1:J);/* LEADING BLANKS            */ 00531000
         B     @RC00259                                            0261 00532000
@RF00259 LR    @14,J                                               0261 00533000
         BCTR  @14,0                                               0261 00534000
         EX    @14,@SM01185                                        0261 00535000
*           END;                                                   0262 00536000
*                                                                  0262 00537000
@RC00259 DS    0H                                                  0263 00538000
*         /***********************************************************/ 00539000
*         /*                                                         */ 00540000
*         /* DISPLAY DATA AS CHARACTER STRING AS WELL AS BIT STRING  */ 00541000
*         /*                                                         */ 00542000
*         /***********************************************************/ 00543000
*                                                                  0263 00544000
*         MU4BT5=BUF;               /* CHARACTER DATA                */ 00545000
@RF00256 MVC   MU4BT5(16),BUF                                      0263 00546000
*         TR(MU4BT5,ZZ1TREBC);      /* ELIMINATE NONGRAPHIC DATA     */ 00547000
         L     @14,ZZ2ZZ1P(,R9)                                    0264 00548000
         TR    MU4BT5(16),ZZ1TREBC(@14)                            0264 00549000
*         CALL BLSUPUTA(ZZ2,MU4B);  /* DISPLAY MESSAGE MU4           */ 00550000
         ST    R9,@AL00001                                         0265 00551000
         LA    @14,MU4B                                            0265 00552000
         ST    @14,@AL00001+4                                      0265 00553000
         L     @14,ZZ2BVTP(,R9)                                    0265 00554000
         L     @15,BVTPUTAP(,@14)                                  0265 00555000
         LA    @01,@AL00001                                        0265 00556000
         BALR  @14,@15                                             0265 00557000
*       END;                                                       0266 00558000
*     IF FLAGEND='0'B THEN                                         0267 00559000
*                                                                  0267 00560000
@RF00234 TM    FLAGEND,B'01000000'                                 0267 00561000
         BNZ   @RF00267                                            0267 00562000
*       /*************************************************************/ 00563000
*       /*                                                           */ 00564000
*       /* ANOTHER PASS WILL BE REQUIRED TO SATISFY THE REQUEST      */ 00565000
*       /*                                                           */ 00566000
*       /*************************************************************/ 00567000
*                                                                  0268 00568000
*       DO;                         /* ANOTHER PASS REQUIRED         */ 00569000
*         FLAGL='1'B;               /* LEFT-JUSTIFY DATA             */ 00570000
         OI    FLAGL,B'00010000'                                   0269 00571000
*         LINEADDR=LINEADDR+LINELEN;/* DUMP ADDRESS OF DATA LINE     */ 00572000
         ALR   LINEADDR,LINELEN                                    0270 00573000
*         LINELEN=MIN(MVCLD1L,LENGTH(BUF));/* LENGTH OF DATA LINE    */ 00574000
         L     LINELEN,MVCLD1L-1                                   0271 00575000
         LA    LINELEN,0(,LINELEN)                                 0271 00576000
         LA    @14,16                                              0271 00577000
         CR    LINELEN,@14                                         0271 00578000
         BNH   *+6                                                      00579000
         LR    LINELEN,@14                                         0271 00580000
*         IF ZZ1EVEP='1'B THEN                                     0272 00581000
*                                                                  0272 00582000
         L     @14,ZZ2ZZ1P(,R9)                                    0272 00583000
         TM    ZZ1EVEP(@14),B'01000000'                            0272 00584000
         BNO   @RF00272                                            0272 00585000
*           /*********************************************************/ 00586000
*           /*                                                       */ 00587000
*           /* ATTENTION INTERRUPTION--TERMINATE QUICKLY             */ 00588000
*           /*                                                       */ 00589000
*           /*********************************************************/ 00590000
*                                                                  0273 00591000
*           DO;                     /* ATTENTION INTERRUPTION        */ 00592000
*             RETC=MAX(RETC,ZZZFLAGS);/* SIGNAL INCOMPLETE           */ 00593000
         LA    @14,12                                              0274 00594000
         CR    RETC,@14                                            0274 00595000
         BNL   *+6                                                      00596000
         LR    RETC,@14                                            0274 00597000
*             FLAGEND='1'B;         /* TERMINATE QUICKLY             */ 00598000
         OI    FLAGEND,B'01000000'                                 0275 00599000
*           END;                                                   0276 00600000
*       END;                                                       0277 00601000
@RF00272 DS    0H                                                  0278 00602000
*   END;                                                           0278 00603000
@RF00267 DS    0H                                                  0278 00604000
@DE00150 TM    FLAGEND,B'01000000'                                 0278 00605000
         BZ    @DL00150                                            0278 00606000
*   RETURN CODE(RETC);                                             0279 00607000
*                                                                  0279 00608000
         L     @13,4(,@13)                                         0279 00609000
         L     @00,@SIZDATD                                        0279 00610000
         LR    @01,@11                                             0279 00611000
         BLSUFRES R,LV=(0),A=(1)                                        00612000
         LR    @15,@10                                             0279 00613000
         L     @14,12(,@13)                                        0279 00614000
         LM    @00,@12,20(@13)                                     0279 00615000
         BR    @14                                                 0279 00616000
*/********************************************************************/ 00617000
*/*                                                                  */ 00618000
*/* E100--BEGIN REDUNDANT DATA PROCESSING                            */ 00619000
*/*                                                                  */ 00620000
*/********************************************************************/ 00621000
*                                                                  0280 00622000
*E100:                              /* BEGIN REDUNDANT DATA          */ 00623000
*   PROCEDURE;                                                     0280 00624000
E100     STM   @14,@07,12(@13)                                     0280 00625000
         STM   @09,@12,56(@13)                                     0280 00626000
*   DUPLEN=LINELEN;                 /* LENGTH OF REPETITIVE AREA     */ 00627000
         LR    DUPLEN,LINELEN                                      0281 00628000
*   MDBT10=MU4BT10;                 /* REPETITIVE DATA ADDRESS       */ 00629000
         MVC   MDBT10(6),MU4BT10                                   0282 00630000
*   FLAGD='1'B;                     /* DUPLICATE DATA PROCESSING     */ 00631000
*   FLAGN='0'B;                     /* DATA LINE NOT NEW             */ 00632000
         OI    FLAGD,B'10000000'                                   0284 00633000
         NI    FLAGN,B'11110111'                                   0284 00634000
*   RETURN;                                                        0285 00635000
@EL00002 DS    0H                                                  0285 00636000
@EF00002 DS    0H                                                  0285 00637000
@ER00002 LM    @14,@07,12(@13)                                     0285 00638000
         LM    @09,@12,56(@13)                                     0285 00639000
         BR    @14                                                 0285 00640000
*   END E100;                                                      0286 00641000
*                                                                  0286 00642000
*/*BLSTPEND--DISPLAY FORMATTER                                       */ 00643000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00644000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00645000
*                                                                  0287 00646000
*   DECLARE                         /* DATA FOR AHB MACROS           */ 00647000
*     PTRBIT BIT(32) BOUNDARY(WORD),/* DATA CONVERSION WORK AREA FOR    00648000
*                                      POINTER DATA                  */ 00649000
*     PTRPTR POINTER DEFINED(PTRBIT),/* DATA CONVERSION WORK AREA FOR   00650000
*                                      POINTER DATA                  */ 00651000
*     PACKED BIT(64) BOUNDARY(DWORD);/* DATA CONVERSION WORK AREA    */ 00652000
*   DECLARE                         /* COMMON VARIABLES              */ 00653000
*     I256C CHAR(256) BASED,                                       0288 00654000
*     I031F FIXED(31) BASED,                                       0288 00655000
*     I031P PTR(31) BASED,                                         0288 00656000
*     I015F FIXED(15) BASED,                                       0288 00657000
*     I015P PTR(15) BASED,                                         0288 00658000
*     I008P PTR(8) BASED,                                          0288 00659000
*     I001C CHAR(1) BASED;                                         0288 00660000
*   GENERATE NODEFS NOREFS DATA;                                   0289 00661000
*   END BLSTU4                      /* BLRPEND(BLSTU4)               */ 00662000
*                                                                  0290 00663000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00664000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00665000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00666000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00667000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00668000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00669000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00670000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00671000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00672000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00673000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00674000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00675000
*                                                                  0290 00676000
*       ;                                                          0290 00677000
@EL00001 L     @13,4(,@13)                                         0290 00678000
@EF00001 L     @00,@SIZDATD                                        0290 00679000
         LR    @01,@11                                             0290 00680000
         BLSUFRES R,LV=(0),A=(1)                                        00681000
@ER00001 LM    @14,@12,12(@13)                                     0290 00682000
         BR    @14                                                 0290 00683000
@DATA    DS    0H                                                       00684000
@CH01172 DC    H'49'                                                    00685000
@CH00186 DC    H'59'                                                    00686000
@SM01183 MVC   0(0,@03),0(@04)                                          00687000
@SM01185 MVC   MU4BT3(0),MU4ST3                                         00688000
@DATD    DSECT                                                          00689000
         DS    0F                                                       00690000
@SA00001 DS    18F                                                      00691000
@PC00001 DS    3F                                                       00692000
@AL00001 DS    2A                                                       00693000
BLSTU4   CSECT                                                          00694000
         DS    0F                                                       00695000
@CF00050 DC    F'1'                                                     00696000
@CF00047 DC    F'4'                                                     00697000
@CF01159 DC    F'9'                                                     00698000
@CF00061 DC    F'16'                                                    00699000
@CF01130 DC    XL4'0000000F'                                            00700000
@CF01182 DC    XL4'0000FFFF'                                            00701000
@DATD    DSECT                                                          00702000
         DS    0D                                                       00703000
MVCLD    DS    CL16                                                     00704000
         ORG   MVCLD                                                    00705000
MVCLD1   DS    CL8                                                      00706000
         ORG   MVCLD1                                                   00707000
MVCLD1P  DS    AL4                                                      00708000
MVCLD12  DS    BL4                                                      00709000
         ORG   MVCLD12                                                  00710000
MVCLD1C  DS    CL1                                                      00711000
MVCLD1L  DS    FL3                                                      00712000
         ORG   MVCLD1+8                                                 00713000
MVCLD19  DS    0C                                                       00714000
         ORG   MVCLD+8                                                  00715000
MVCLD2   DS    CL8                                                      00716000
         ORG   MVCLD2                                                   00717000
MVCLD2P  DS    AL4                                                      00718000
MVCLD22  DS    BL4                                                      00719000
         ORG   MVCLD22                                                  00720000
MVCLD2C  DS    CL1                                                      00721000
MVCLD2L  DS    FL3                                                      00722000
         ORG   MVCLD2+8                                                 00723000
MVCLD29  DS    0C                                                       00724000
         ORG   MVCLD+16                                                 00725000
MVCLD99  DS    0C                                                       00726000
         ORG   MVCLD+16                                                 00727000
MU4B     DS    CL72                                                     00728000
         ORG   MU4B                                                     00729000
MU4BL    DS    FL2                                                      00730000
@NM00090 DS    BL2                                                      00731000
MU4BT    DS    CL68                                                     00732000
         ORG   MU4BT                                                    00733000
MU4BT0   DS    CL1                                                      00734000
MU4BT1   DS    CL7                                                      00735000
         ORG   MU4BT1                                                   00736000
MU4BT10  DS    CL6                                                      00737000
MU4BT11  DS    CL1                                                      00738000
         ORG   MU4BT+8                                                  00739000
MU4BT2   DS    CL3                                                      00740000
MU4BT3   DS    CL35                                                     00741000
         ORG   MU4BT3                                                   00742000
MU4BT30  DS    CL9                                                      00743000
         ORG   MU4BT30                                                  00744000
MU4BT300 DS    CL8                                                      00745000
MU4BT301 DS    CL1                                                      00746000
         ORG   MU4BT3+9                                                 00747000
MU4BT31  DS    CL9                                                      00748000
         ORG   MU4BT31                                                  00749000
MU4BT310 DS    CL8                                                      00750000
MU4BT311 DS    CL1                                                      00751000
         ORG   MU4BT3+18                                                00752000
MU4BT32  DS    CL9                                                      00753000
         ORG   MU4BT32                                                  00754000
MU4BT320 DS    CL8                                                      00755000
MU4BT321 DS    CL1                                                      00756000
         ORG   MU4BT3+27                                                00757000
MU4BT33  DS    CL8                                                      00758000
         ORG   MU4BT+46                                                 00759000
MU4BT4   DS    CL4                                                      00760000
MU4BT5   DS    CL16                                                     00761000
MU4BT6   DS    CL2                                                      00762000
         ORG   MU4B+72                                                  00763000
MDB      DS    CL72                                                     00764000
         ORG   MDB                                                      00765000
MDBL     DS    FL2                                                      00766000
@NM00092 DS    BL2                                                      00767000
MDBT     DS    CL68                                                     00768000
         ORG   MDBT                                                     00769000
MDBT0    DS    CL1                                                      00770000
MDBT1    DS    CL7                                                      00771000
         ORG   MDBT1                                                    00772000
MDBT10   DS    CL6                                                      00773000
MDBT11   DS    CL1                                                      00774000
         ORG   MDBT+8                                                   00775000
MDBT2    DS    CL8                                                      00776000
MDBT3    DS    CL10                                                     00777000
MDBT4    DS    CL6                                                      00778000
MDBT5    DS    CL36                                                     00779000
         ORG   MDBT5                                                    00780000
MDBT50   DS    CL20                                                     00781000
MDBT51   DS    CL2                                                      00782000
MDBT52   DS    CL1                                                      00783000
MDBT53   DS    CL13                                                     00784000
         ORG   MDBT53                                                   00785000
MDBT530  DS    CL11                                                     00786000
MDBT531  DS    CL1                                                      00787000
MDBT532  DS    CL1                                                      00788000
         ORG   MDB+72                                                   00789000
BUF      DS    CL16                                                     00790000
         ORG   BUF                                                      00791000
BUF1     DS    CL4                                                      00792000
BUF2     DS    CL4                                                      00793000
BUF3     DS    CL4                                                      00794000
BUF4     DS    CL4                                                      00795000
         ORG   BUF+16                                                   00796000
FLAG     DS    BL1                                                      00797000
         ORG   FLAG                                                     00798000
FLAGD    DS    BL1                                                      00799000
FLAGEND  EQU   FLAG+0                                                   00800000
FLAGF    EQU   FLAG+0                                                   00801000
FLAGL    EQU   FLAG+0                                                   00802000
FLAGN    EQU   FLAG+0                                                   00803000
@NM00093 EQU   FLAG+0                                                   00804000
         ORG   FLAG+1                                                   00805000
         DS    CL3                                                      00806000
PTRBIT   DS    BL4                                                      00807000
PACKED   DS    BL8                                                      00808000
BLSTU4   CSECT                                                          00809000
         DS    0F                                                       00810000
@SIZDATD DC    AL1(0)                                                   00811000
         DC    AL3(@ENDDATD-@DATD)                                      00812000
         DS    0D                                                       00813000
MU4S     DS    CL72                                                     00814000
         ORG   MU4S                                                     00815000
MU4SL    DC    AL2(72)                                                  00816000
@NM00089 DC    X'0000'                                                  00817000
MU4ST    DS    CL68                                                     00818000
         ORG   MU4ST                                                    00819000
MU4ST0   DC    CL1' '                                                   00820000
MU4ST1   DS    CL7                                                      00821000
         ORG   MU4ST1                                                   00822000
MU4ST10  DC    CL6'000000'                                              00823000
MU4ST11  DC    CL1'.'                                                   00824000
         ORG   MU4ST+8                                                  00825000
MU4ST2   DC    CL3' | '                                                 00826000
MU4ST3   DS    CL35                                                     00827000
         ORG   MU4ST3                                                   00828000
MU4ST30  DS    CL9                                                      00829000
         ORG   MU4ST30                                                  00830000
MU4ST300 DC    CL8' '                                                   00831000
MU4ST301 DC    CL1' '                                                   00832000
         ORG   MU4ST3+9                                                 00833000
MU4ST31  DS    CL9                                                      00834000
         ORG   MU4ST31                                                  00835000
MU4ST310 DC    CL8' '                                                   00836000
MU4ST311 DC    CL1' '                                                   00837000
         ORG   MU4ST3+18                                                00838000
MU4ST32  DS    CL9                                                      00839000
         ORG   MU4ST32                                                  00840000
MU4ST320 DC    CL8' '                                                   00841000
MU4ST321 DC    CL1' '                                                   00842000
         ORG   MU4ST3+27                                                00843000
MU4ST33  DC    CL8' '                                                   00844000
         ORG   MU4ST+46                                                 00845000
MU4ST4   DC    CL4' || '                                                00846000
MU4ST5   DC    CL16' '                                                  00847000
MU4ST6   DC    CL2' |'                                                  00848000
         ORG   MU4S+72                                                  00849000
TD       DS    CL13                                                     00850000
         ORG   TD                                                       00851000
TD1      DC    CL13'SAME AS ABOVE'                                      00852000
         ORG   TD+13                                                    00853000
         DS    CL1                                                      00854000
MDS      DS    CL72                                                     00855000
         ORG   MDS                                                      00856000
MDSL     DC    AL2(72)                                                  00857000
@NM00091 DC    X'0000'                                                  00858000
MDST     DS    CL68                                                     00859000
         ORG   MDST                                                     00860000
MDST0    DC    CL1' '                                                   00861000
MDST1    DS    CL7                                                      00862000
         ORG   MDST1                                                    00863000
MDST10   DC    CL6'000000'                                              00864000
MDST11   DC    CL1'.'                                                   00865000
         ORG   MDST+8                                                   00866000
MDST2    DC    CL8' LENGTH('                                            00867000
MDST3    DC    X'40202020202020202120'                                  00868000
MDST4    DC    CL6') ==> '                                              00869000
MDST5    DS    CL36                                                     00870000
         ORG   MDST5                                                    00871000
MDST50   DC    CL20'ALL BYTES CONTAIN X'''                              00872000
MDST51   DC    CL2' '                                                   00873000
MDST52   DC    CL1''''                                                  00874000
MDST53   DS    CL13                                                     00875000
         ORG   MDST53                                                   00876000
MDST530  DC    CL11', EBCDIC C'''                                       00877000
MDST531  DC    CL1' '                                                   00878000
MDST532  DC    CL1''''                                                  00879000
         ORG   MDS+72                                                   00880000
@DATD    DSECT                                                          00881000
         SPACE 2                                                        00882000
*********************************************************************** 00883000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00884000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00885000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00886000
*********************************************************************** 00887000
         SPACE                                                          00888000
BLSTU4   CSECT                                                          00889000
         ORG                                                            00890000
         DS    0D                                                       00891000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSTU4+19)/20+7)/8)CL8'BLSTU4'         00892000
@DATD    DSECT                                                          00893000
         DS    0H                                                       00894000
@DATD    DSECT                                                          00895000
         SPACE 2                                                        00896000
*********************************************************************** 00897000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00898000
*********************************************************************** 00899000
         SPACE                                                          00900000
         DS    0D                                                       00901000
@DATD    DSECT                                                          00902000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00903000
@ENDDATD EQU   *                                                        00904000
BLSTU4   CSECT                                                          00905000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00906000
@01      EQU   01                                                       00907000
@02      EQU   02                                                       00908000
@03      EQU   03                                                       00909000
@04      EQU   04                                                       00910000
@05      EQU   05                                                       00911000
@06      EQU   06                                                       00912000
@07      EQU   07                                                       00913000
@08      EQU   08                                                       00914000
@09      EQU   09                                                       00915000
@10      EQU   10                                                       00916000
@11      EQU   11                                                       00917000
@12      EQU   12                                                       00918000
@13      EQU   13                                                       00919000
@14      EQU   14                                                       00920000
@15      EQU   15                                                       00921000
RETC     EQU   @10                                                      00922000
DUPLEN   EQU   @08                                                      00923000
LINELEN  EQU   @06                                                      00924000
LINEADDR EQU   @07                                                      00925000
J        EQU   @02                                                      00926000
R9       EQU   @09                                                      00927000
R0       EQU   @00                                                      00928000
R1       EQU   @01                                                      00929000
R2       EQU   @02                                                      00930000
R3       EQU   @03                                                      00931000
R4       EQU   @04                                                      00932000
R5       EQU   @05                                                      00933000
RB       EQU   @11                                                      00934000
RD       EQU   @13                                                      00935000
RE       EQU   @14                                                      00936000
RF       EQU   @15                                                      00937000
RA       EQU   @10                                                      00938000
RC       EQU   @12                                                      00939000
R6       EQU   @06                                                      00940000
R7       EQU   @07                                                      00941000
R8       EQU   @08                                                      00942000
ZZ1      EQU   0                                                        00943000
ZZ1ATTN  EQU   ZZ1+360                                                  00944000
ZZ1EVE   EQU   ZZ1ATTN+4                                                00945000
ZZ1EVEP  EQU   ZZ1EVE                                                   00946000
ZZ1F     EQU   ZZ1+368                                                  00947000
ZZ1TRHEX EQU   ZZ1+568                                                  00948000
ZZ1TREBC EQU   ZZ1+824                                                  00949000
ZZ1N     EQU   ZZ1+1116                                                 00950000
ZZ2      EQU   0                                                        00951000
ZZ2AMD   EQU   ZZ2                                                      00952000
@NM00025 EQU   ZZ2AMD+7                                                 00953000
ZZ2PRT   EQU   ZZ2+138                                                  00954000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 00955000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                00956000
ZZ2A     EQU   ZZ2+272                                                  00957000
ZZ2AF    EQU   ZZ2A+16                                                  00958000
ZZ2APID  EQU   ZZ2A+64                                                  00959000
ZZ2AD    EQU   ZZ2A+74                                                  00960000
ZZ2ADD   EQU   ZZ2AD                                                    00961000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 00962000
ZZ2ADM   EQU   ZZ2AD+46                                                 00963000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 00964000
ZZ2ADP   EQU   ZZ2AD+56                                                 00965000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 00966000
ZZ2AZZ6P EQU   ZZ2A+140                                                 00967000
ZZ2AQAS  EQU   ZZ2A+144                                                 00968000
ZZ2AQD   EQU   ZZ2A+160                                                 00969000
ZZ2AQDT  EQU   ZZ2AQD+10                                                00970000
ZZ2AQDF  EQU   ZZ2AQD+52                                                00971000
ZZ2STG   EQU   ZZ2+960                                                  00972000
ZZ2ALLOP EQU   ZZ2+992                                                  00973000
ZZ2FREEP EQU   ZZ2+996                                                  00974000
ZZ2FF19P EQU   ZZ2+1000                                                 00975000
ZZ2FRE1P EQU   ZZ2+1004                                                 00976000
ZZ2FF18P EQU   ZZ2+1008                                                 00977000
ZZ2DYNAP EQU   ZZ2+1012                                                 00978000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 00979000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 00980000
ZZ2STAIP EQU   ZZ2+1024                                                 00981000
ZZ2FF02P EQU   ZZ2+1028                                                 00982000
ZZ2GETLP EQU   ZZ2+1032                                                 00983000
ZZ2PARSP EQU   ZZ2+1036                                                 00984000
ZZ2PTGTP EQU   ZZ2+1040                                                 00985000
ZZ2PUTLP EQU   ZZ2+1044                                                 00986000
ZZ2SCANP EQU   ZZ2+1048                                                 00987000
ZZ2STCKP EQU   ZZ2+1052                                                 00988000
ZZ2TRMOP EQU   ZZ2+1064                                                 00989000
ZZ2TRMVP EQU   ZZ2+1068                                                 00990000
ZZ2PUTNP EQU   ZZ2+1084                                                 00991000
ZZ2TRMNP EQU   ZZ2+1088                                                 00992000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 00993000
ZZ2BVTP  EQU   ZZ2+1280                                                 00994000
ZZ2RVTP  EQU   ZZ2+1284                                                 00995000
ZZ2CPPL  EQU   ZZ2+1292                                                 00996000
ZZ2CPPLC EQU   ZZ2CPPL                                                  00997000
ZZ2ITR   EQU   ZZ2+2840                                                 00998000
ZZ2ITRE  EQU   ZZ2ITR+16                                                00999000
ZZ2ITSE  EQU   ZZ2+2864                                                 01000000
ZZ2ES    EQU   ZZ2+2872                                                 01001000
ZZ2AMDX  EQU   ZZ2+7160                                                 01002000
ZZ2AXO   EQU   ZZ2+7934                                                 01003000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 01004000
CMD      EQU   0                                                        01005000
CMDT     EQU   CMD+4                                                    01006000
PSCB     EQU   0                                                        01007000
PSCBATR1 EQU   PSCB+16                                                  01008000
ECT      EQU   0                                                        01009000
ECTSWS   EQU   ECT+28                                                   01010000
ECTSWS2  EQU   ECT+40                                                   01011000
ECTSWS21 EQU   ECTSWS2                                                  01012000
UPT      EQU   0                                                        01013000
UPTSWS   EQU   UPT+12                                                   01014000
SA       EQU   0                                                        01015000
SA1      EQU   SA                                                       01016000
SAR      EQU   SA+12                                                    01017000
SAR1     EQU   SAR+12                                                   01018000
BLSUMPK1 EQU   0                                                        01019000
BLSUPUTA EQU   0                                                        01020000
BVT      EQU   0                                                        01021000
BVTPUTLP EQU   BVT+4                                                    01022000
BVTPUTOP EQU   BVT+12                                                   01023000
BVTPUTTP EQU   BVT+16                                                   01024000
BVTPUTVP EQU   BVT+20                                                   01025000
BVTPUTAP EQU   BVT+24                                                   01026000
BVTPRTTP EQU   BVT+28                                                   01027000
BVTPRTAP EQU   BVT+32                                                   01028000
BVTPUTDP EQU   BVT+36                                                   01029000
BVTMONP  EQU   BVT+40                                                   01030000
BVTMON2P EQU   BVT+44                                                   01031000
BVTVSARP EQU   BVT+48                                                   01032000
BVTVSENP EQU   BVT+64                                                   01033000
BVTVSERP EQU   BVT+68                                                   01034000
BVTVSGEP EQU   BVT+72                                                   01035000
BVTVSGUP EQU   BVT+76                                                   01036000
BVTVSPOP EQU   BVT+80                                                   01037000
BVTVSPUP EQU   BVT+84                                                   01038000
BVTMPKNP EQU   BVT+104                                                  01039000
BVTMONLP EQU   BVT+108                                                  01040000
BVTPUTCP EQU   BVT+132                                                  01041000
BVTMPK1P EQU   BVT+136                                                  01042000
BVTZZ2RP EQU   BVT+140                                                  01043000
BVTPGMRP EQU   BVT+144                                                  01044000
BVTMONAP EQU   BVT+148                                                  01045000
BVTBLDDP EQU   BVT+152                                                  01046000
BVTBLDLP EQU   BVT+156                                                  01047000
BVTPGMCP EQU   BVT+160                                                  01048000
BVTPGMDP EQU   BVT+164                                                  01049000
BVTPGMLP EQU   BVT+168                                                  01050000
BVTMONCP EQU   BVT+180                                                  01051000
BVTMONDP EQU   BVT+184                                                  01052000
BVTMONTP EQU   BVT+188                                                  01053000
BVTPARIP EQU   BVT+192                                                  01054000
BVTPARUP EQU   BVT+196                                                  01055000
BVTPRTNP EQU   BVT+204                                                  01056000
BVTVSCRP EQU   BVT+208                                                  01057000
BVTVSMRP EQU   BVT+212                                                  01058000
BVTMONXP EQU   BVT+216                                                  01059000
BVTTRMAP EQU   BVT+228                                                  01060000
ZZ6      EQU   0                                                        01061000
ZZ6D     EQU   ZZ6+128                                                  01062000
ZZ6DD    EQU   ZZ6D+8                                                   01063000
ZZ6DDT   EQU   ZZ6DD+4                                                  01064000
ZZ6DQA   EQU   ZZ6D+68                                                  01065000
ZZ6DF    EQU   ZZ6D+92                                                  01066000
ZZ6B     EQU   ZZ6+768                                                  01067000
RVT      EQU   0                                                        01068000
RVTADDRP EQU   RVT                                                      01069000
RVTT01P  EQU   RVT+4                                                    01070000
RVTTAP   EQU   RVT+8                                                    01071000
RVTTBP   EQU   RVT+12                                                   01072000
RVTTCP   EQU   RVT+16                                                   01073000
RVTTFP   EQU   RVT+24                                                   01074000
RVTTYP   EQU   RVT+40                                                   01075000
RVTT02P  EQU   RVT+48                                                   01076000
RVTT03P  EQU   RVT+52                                                   01077000
RVTT04P  EQU   RVT+56                                                   01078000
RVTACCLP EQU   RVT+60                                                   01079000
RVTRACCP EQU   RVT+64                                                   01080000
RVTTLP   EQU   RVT+68                                                   01081000
RVTTMP   EQU   RVT+72                                                   01082000
RVTTUP   EQU   RVT+80                                                   01083000
RVTESGEP EQU   RVT+84                                                   01084000
RVTESGUP EQU   RVT+88                                                   01085000
RVTESARP EQU   RVT+92                                                   01086000
RVTRAARP EQU   RVT+96                                                   01087000
RVTRAGEP EQU   RVT+100                                                  01088000
RVTADDPP EQU   RVT+104                                                  01089000
RVTACCQP EQU   RVT+108                                                  01090000
RVTSAGUP EQU   RVT+124                                                  01091000
RVTSAGEP EQU   RVT+128                                                  01092000
RVTESCKP EQU   RVT+132                                                  01093000
RVTMSGAP EQU   RVT+136                                                  01094000
RVTMSGDP EQU   RVT+140                                                  01095000
RVTADDTP EQU   RVT+160                                                  01096000
RVTADDUP EQU   RVT+164                                                  01097000
RVTADD1P EQU   RVT+176                                                  01098000
RVTADD2P EQU   RVT+180                                                  01099000
RVTRSAGP EQU   RVT+184                                                  01100000
RVTMSGBP EQU   RVT+188                                                  01101000
RVTADDSP EQU   RVT+192                                                  01102000
RVTADD3P EQU   RVT+196                                                  01103000
RVTT05P  EQU   RVT+200                                                  01104000
RVTPADSP EQU   RVT+204                                                  01105000
RVTTRP   EQU   RVT+228                                                  01106000
RVTADD4P EQU   RVT+232                                                  01107000
RVTSAPCP EQU   RVT+236                                                  01108000
RVTSAARP EQU   RVT+240                                                  01109000
RVTSAGNP EQU   RVT+244                                                  01110000
RVTT06P  EQU   RVT+248                                                  01111000
RVTSAGCP EQU   RVT+252                                                  01112000
RVTSAGQP EQU   RVT+256                                                  01113000
RVTESGCP EQU   RVT+260                                                  01114000
RVTESGQP EQU   RVT+264                                                  01115000
RVTDUCKP EQU   RVT+276                                                  01116000
RVTDUCCP EQU   RVT+280                                                  01117000
I001C    EQU   0                                                        01118000
BLSRACC  EQU   0                                                        01119000
BLSRACCL EQU   0                                                        01120000
BLSRACCQ EQU   0                                                        01121000
BLSRADDP EQU   0                                                        01122000
BLSRADDR EQU   0                                                        01123000
BLSRADDS EQU   0                                                        01124000
BLSRADDT EQU   0                                                        01125000
BLSRADDU EQU   0                                                        01126000
BLSRADD1 EQU   0                                                        01127000
BLSRADD2 EQU   0                                                        01128000
BLSRADD3 EQU   0                                                        01129000
BLSRADD4 EQU   0                                                        01130000
BLSRDUCC EQU   0                                                        01131000
BLSRDUCK EQU   0                                                        01132000
BLSRESAR EQU   0                                                        01133000
BLSRESCK EQU   0                                                        01134000
BLSRESGC EQU   0                                                        01135000
BLSRESGE EQU   0                                                        01136000
BLSRESGQ EQU   0                                                        01137000
BLSRESGU EQU   0                                                        01138000
BLSRMSGA EQU   0                                                        01139000
BLSRMSGB EQU   0                                                        01140000
BLSRMSGD EQU   0                                                        01141000
BLSRPADS EQU   0                                                        01142000
BLSRRAAR EQU   0                                                        01143000
BLSRRAGE EQU   0                                                        01144000
BLSRSAAR EQU   0                                                        01145000
BLSRSAG  EQU   0                                                        01146000
BLSRSAGC EQU   0                                                        01147000
BLSRSAGE EQU   0                                                        01148000
BLSRSAGN EQU   0                                                        01149000
BLSRSAGQ EQU   0                                                        01150000
BLSRSAGU EQU   0                                                        01151000
BLSRSAPC EQU   0                                                        01152000
BLSTA    EQU   0                                                        01153000
BLSTB    EQU   0                                                        01154000
BLSTC    EQU   0                                                        01155000
BLSTF    EQU   0                                                        01156000
BLSTL    EQU   0                                                        01157000
BLSTM    EQU   0                                                        01158000
BLSTR    EQU   0                                                        01159000
BLSTU    EQU   0                                                        01160000
BLSTY    EQU   0                                                        01161000
BLST01   EQU   0                                                        01162000
BLST02   EQU   0                                                        01163000
BLST03   EQU   0                                                        01164000
BLST04   EQU   0                                                        01165000
BLST05   EQU   0                                                        01166000
BLST06   EQU   0                                                        01167000
BLSUALLO EQU   0                                                        01168000
BLSUBLDD EQU   0                                                        01169000
BLSUBLDL EQU   0                                                        01170000
BLSUDYNA EQU   0                                                        01171000
BLSUFREE EQU   0                                                        01172000
BLSUFRE1 EQU   0                                                        01173000
BLSUMON  EQU   0                                                        01174000
BLSUMONA EQU   0                                                        01175000
BLSUMONC EQU   0                                                        01176000
BLSUMOND EQU   0                                                        01177000
BLSUMONL EQU   0                                                        01178000
BLSUMONT EQU   0                                                        01179000
BLSUMONX EQU   0                                                        01180000
BLSUMON2 EQU   0                                                        01181000
BLSUMPKN EQU   0                                                        01182000
BLSUPARI EQU   0                                                        01183000
BLSUPARU EQU   0                                                        01184000
BLSUPGMC EQU   0                                                        01185000
BLSUPGMD EQU   0                                                        01186000
BLSUPGML EQU   0                                                        01187000
BLSUPGMR EQU   0                                                        01188000
BLSUPRTA EQU   0                                                        01189000
BLSUPRTN EQU   0                                                        01190000
BLSUPRTT EQU   0                                                        01191000
BLSUPUTC EQU   0                                                        01192000
BLSUPUTD EQU   0                                                        01193000
BLSUPUTL EQU   0                                                        01194000
BLSUPUTN EQU   0                                                        01195000
BLSUPUTO EQU   0                                                        01196000
BLSUPUTT EQU   0                                                        01197000
BLSUPUTV EQU   0                                                        01198000
BLSUSTAI EQU   0                                                        01199000
BLSUTRMA EQU   0                                                        01200000
BLSUTRMN EQU   0                                                        01201000
BLSUTRMO EQU   0                                                        01202000
BLSUTRMV EQU   0                                                        01203000
BLSUVSAR EQU   0                                                        01204000
BLSUVSCR EQU   0                                                        01205000
BLSUVSEN EQU   0                                                        01206000
BLSUVSER EQU   0                                                        01207000
BLSUVSGE EQU   0                                                        01208000
BLSUVSGU EQU   0                                                        01209000
BLSUVSMR EQU   0                                                        01210000
BLSUVSPO EQU   0                                                        01211000
BLSUVSPU EQU   0                                                        01212000
BLSUZZ2C EQU   0                                                        01213000
BLSUZZ2D EQU   0                                                        01214000
BLSUZZ2R EQU   0                                                        01215000
IKJEFF02 EQU   0                                                        01216000
IKJEFF18 EQU   0                                                        01217000
IKJEFF19 EQU   0                                                        01218000
IKJGETL  EQU   0                                                        01219000
IKJPARS  EQU   0                                                        01220000
IKJPTGT  EQU   0                                                        01221000
IKJPUTL  EQU   0                                                        01222000
IKJSCAN  EQU   0                                                        01223000
IKJSTCK  EQU   0                                                        01224000
I008P    EQU   0                                                        01225000
I015F    EQU   0                                                        01226000
I015P    EQU   0                                                        01227000
I031F    EQU   0                                                        01228000
I031P    EQU   0                                                        01229000
I256C    EQU   0                                                        01230000
PZ2      EQU   0                                                        01231000
ESPA     EQU   0                                                        01232000
ESPAAS   EQU   ESPA+60                                                  01233000
ESPALAD  EQU   ESPA+76                                                  01234000
ESPAD    EQU   ESPA+80                                                  01235000
ESPADOF  EQU   ESPAD                                                    01236000
ESPADLE  EQU   ESPAD+4                                                  01237000
ESPADT   EQU   ESPAD+10                                                 01238000
ESPADIM  EQU   ESPAD+44                                                 01239000
ESPADF   EQU   ESPAD+52                                                 01240000
ESPAF    EQU   ESPA+161                                                 01241000
ESPAFS   EQU   ESPAF                                                    01242000
ESPAFC   EQU   ESPAF+1                                                  01243000
ESPAR    EQU   ESPA+180                                                 01244000
ESPART   EQU   ESPAR+2                                                  01245000
BLK      EQU   0                                                        01246000
CPPL     EQU   ZZ2CPPL                                                  01247000
CPPLUPT  EQU   CPPL+4                                                   01248000
CPPLPSCB EQU   CPPL+8                                                   01249000
CPPLECT  EQU   CPPL+12                                                  01250000
PTRPTR   EQU   PTRBIT                                                   01251000
@RC00160 EQU   @RC00158                                                 01708000
@RC00170 EQU   @RC00160                                                 01709000
L020     EQU   @RC00160                                                 01710000
@ENDDATA EQU   *                                                        01711000
         END   BLSTU4                                           DSKC444 01712000
