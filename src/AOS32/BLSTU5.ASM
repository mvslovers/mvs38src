TU5      TITLE 'BLSTU5  --IPCS SERVICE ROUTINE TO DISPLAY AREA DATA    *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPLK                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLSTU5   CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(16)                                             0002 00010000
         DC    C'BLSTU5    78.059'                                 0002 00011000
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
*   MU5B=MU5S;                      /* MESSAGE MU5 LITERAL TEXT      */ 00028000
         MVC   MU5B(125),MU5S                                      0138 00029000
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
         LA    @14,32                                              0145 00053000
         CR    LINELEN,@14                                         0145 00054000
         BNH   @RF00145                                            0145 00055000
*     LINELEN=LENGTH(BUF)-(LINEADDR&BUFMASK2);/* ALIGN DISPLAY LINES */ 00056000
         LR    LINELEN,LINEADDR                                    0146 00057000
         N     LINELEN,@CF01158                                    0146 00058000
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
*                                      R)TO(CHARACTER)SET(MU5BT10)REM   00081000
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
*       UNPK(MU5BT10(1:LENGTH(MU5BT10)-1),PTRBIT);/* BIT=>ZONED    0153 00094000
*                                      HEXADECIMAL                   */ 00095000
         UNPK  MU5BT10(5),PTRBIT(4)                                0153 00096000
*       MU5BT10(LENGTH(MU5BT10):LENGTH(MU5BT10))=PTRBIT(25:32);/*  0154 00097000
*                                      FINAL ZONED HEXADECIMAL DIGIT */ 00098000
         MVC   MU5BT10+5(1),PTRBIT+3                               0154 00099000
*       TR(MU5BT10,ZZ1TRHEX);       /* ZONED HEXADECIMAL=>EBCDIC     */ 00100000
         L     @14,ZZ2ZZ1P(,R9)                                    0155 00101000
         TR    MU5BT10(6),ZZ1TRHEX(@14)                            0155 00102000
*     END;                          /* BLRCNVPC(LINEADDR) FROM(POINTE   00103000
*                                      R)TO(CHARACTER)SET(MU5BT10)REM   00104000
*                                      ARK(OUTPUT LINE             0156 00105000
*                                      ADDRESS)TR(ZZ1TRHEX)          */ 00106000
*     MVCLD2L=LINELEN;              /* DATA BYTES IN THIS LINE       */ 00107000
         STCM  LINELEN,7,MVCLD2L                                   0157 00108000
*     IF LINELEN=LENGTH(BUF) THEN                                  0158 00109000
*                                                                  0158 00110000
         C     LINELEN,@CF00069                                    0158 00111000
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
         MVC   MDBL(2),@CH01200                                    0174 00170000
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
         MVC   BUF+2(30),BUF+1                                     0185 00210000
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
         AL    @14,@CF00069                                        0188 00222000
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
         N     @14,@CF01210                                        0230 00383000
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
*                                      ACTER)SET(MU5BT300)REMARK(BIT    00413000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00414000
*                                                                  0236 00415000
*           /*********************************************************/ 00416000
*           /*                                                       */ 00417000
*           /* BIT STRING WORD 1                                     */ 00418000
*           /*                                                       */ 00419000
*           /*********************************************************/ 00420000
*                                                                  0237 00421000
*           UNPK(MU5BT300(1:LENGTH(MU5BT300)-1),BUF1);/* BIT=>ZONED     00422000
*                                      HEXADECIMAL                   */ 00423000
         UNPK  MU5BT300(7),BUF1(4)                                 0237 00424000
*           MU5BT300(LENGTH(MU5BT300):LENGTH(MU5BT300))=BUF1(LENGTH(    00425000
*               BUF1):LENGTH(BUF1));/* FINAL ZONED HEXADECIMAL DIGIT */ 00426000
         MVC   MU5BT300+7(1),BUF1+3                                0238 00427000
*           TR(MU5BT300,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00428000
         L     @14,ZZ2ZZ1P(,R9)                                    0239 00429000
         TR    MU5BT300(8),ZZ1TRHEX(@14)                           0239 00430000
*         END;                      /* BLRCNVXC(BUF1) FROM(BS)TO(CHAR   00431000
*                                      ACTER)SET(MU5BT300)REMARK(BIT    00432000
*                                      STRING WORD 1)TR(ZZ1TRHEX)    */ 00433000
*         DO;                       /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00434000
*                                      ACTER)SET(MU5BT310)REMARK(BIT    00435000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00436000
*                                                                  0241 00437000
*           /*********************************************************/ 00438000
*           /*                                                       */ 00439000
*           /* BIT STRING WORD 2                                     */ 00440000
*           /*                                                       */ 00441000
*           /*********************************************************/ 00442000
*                                                                  0242 00443000
*           UNPK(MU5BT310(1:LENGTH(MU5BT310)-1),BUF2);/* BIT=>ZONED     00444000
*                                      HEXADECIMAL                   */ 00445000
         UNPK  MU5BT310(7),BUF2(4)                                 0242 00446000
*           MU5BT310(LENGTH(MU5BT310):LENGTH(MU5BT310))=BUF2(LENGTH(    00447000
*               BUF2):LENGTH(BUF2));/* FINAL ZONED HEXADECIMAL DIGIT */ 00448000
         MVC   MU5BT310+7(1),BUF2+3                                0243 00449000
*           TR(MU5BT310,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00450000
         TR    MU5BT310(8),ZZ1TRHEX(@14)                           0244 00451000
*         END;                      /* BLRCNVXC(BUF2) FROM(BS)TO(CHAR   00452000
*                                      ACTER)SET(MU5BT310)REMARK(BIT    00453000
*                                      STRING WORD 2)TR(ZZ1TRHEX)    */ 00454000
*         DO;                       /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00455000
*                                      ACTER)SET(MU5BT320)REMARK(BIT    00456000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00457000
*                                                                  0246 00458000
*           /*********************************************************/ 00459000
*           /*                                                       */ 00460000
*           /* BIT STRING WORD 3                                     */ 00461000
*           /*                                                       */ 00462000
*           /*********************************************************/ 00463000
*                                                                  0247 00464000
*           UNPK(MU5BT320(1:LENGTH(MU5BT320)-1),BUF3);/* BIT=>ZONED     00465000
*                                      HEXADECIMAL                   */ 00466000
         UNPK  MU5BT320(7),BUF3(4)                                 0247 00467000
*           MU5BT320(LENGTH(MU5BT320):LENGTH(MU5BT320))=BUF3(LENGTH(    00468000
*               BUF3):LENGTH(BUF3));/* FINAL ZONED HEXADECIMAL DIGIT */ 00469000
         MVC   MU5BT320+7(1),BUF3+3                                0248 00470000
*           TR(MU5BT320,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00471000
         TR    MU5BT320(8),ZZ1TRHEX(@14)                           0249 00472000
*         END;                      /* BLRCNVXC(BUF3) FROM(BS)TO(CHAR   00473000
*                                      ACTER)SET(MU5BT320)REMARK(BIT    00474000
*                                      STRING WORD 3)TR(ZZ1TRHEX)    */ 00475000
*         DO;                       /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00476000
*                                      ACTER)SET(MU5BT330)REMARK(BIT    00477000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00478000
*                                                                  0251 00479000
*           /*********************************************************/ 00480000
*           /*                                                       */ 00481000
*           /* BIT STRING WORD 4                                     */ 00482000
*           /*                                                       */ 00483000
*           /*********************************************************/ 00484000
*                                                                  0252 00485000
*           UNPK(MU5BT330(1:LENGTH(MU5BT330)-1),BUF4);/* BIT=>ZONED     00486000
*                                      HEXADECIMAL                   */ 00487000
         UNPK  MU5BT330(7),BUF4(4)                                 0252 00488000
*           MU5BT330(LENGTH(MU5BT330):LENGTH(MU5BT330))=BUF4(LENGTH(    00489000
*               BUF4):LENGTH(BUF4));/* FINAL ZONED HEXADECIMAL DIGIT */ 00490000
         MVC   MU5BT330+7(1),BUF4+3                                0253 00491000
*           TR(MU5BT330,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00492000
         TR    MU5BT330(8),ZZ1TRHEX(@14)                           0254 00493000
*         END;                      /* BLRCNVXC(BUF4) FROM(BS)TO(CHAR   00494000
*                                      ACTER)SET(MU5BT330)REMARK(BIT    00495000
*                                      STRING WORD 4)TR(ZZ1TRHEX)    */ 00496000
*         DO;                       /* BLRCNVXC(BUF5) FROM(BS)TO(CHAR   00497000
*                                      ACTER)SET(MU5BT340)REMARK(BIT    00498000
*                                      STRING WORD 5)TR(ZZ1TRHEX)    */ 00499000
*                                                                  0256 00500000
*           /*********************************************************/ 00501000
*           /*                                                       */ 00502000
*           /* BIT STRING WORD 5                                     */ 00503000
*           /*                                                       */ 00504000
*           /*********************************************************/ 00505000
*                                                                  0257 00506000
*           UNPK(MU5BT340(1:LENGTH(MU5BT340)-1),BUF5);/* BIT=>ZONED     00507000
*                                      HEXADECIMAL                   */ 00508000
         UNPK  MU5BT340(7),BUF5(4)                                 0257 00509000
*           MU5BT340(LENGTH(MU5BT340):LENGTH(MU5BT340))=BUF5(LENGTH(    00510000
*               BUF5):LENGTH(BUF5));/* FINAL ZONED HEXADECIMAL DIGIT */ 00511000
         MVC   MU5BT340+7(1),BUF5+3                                0258 00512000
*           TR(MU5BT340,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00513000
         TR    MU5BT340(8),ZZ1TRHEX(@14)                           0259 00514000
*         END;                      /* BLRCNVXC(BUF5) FROM(BS)TO(CHAR   00515000
*                                      ACTER)SET(MU5BT340)REMARK(BIT    00516000
*                                      STRING WORD 5)TR(ZZ1TRHEX)    */ 00517000
*         DO;                       /* BLRCNVXC(BUF6) FROM(BS)TO(CHAR   00518000
*                                      ACTER)SET(MU5BT350)REMARK(BIT    00519000
*                                      STRING WORD 6)TR(ZZ1TRHEX)    */ 00520000
*                                                                  0261 00521000
*           /*********************************************************/ 00522000
*           /*                                                       */ 00523000
*           /* BIT STRING WORD 6                                     */ 00524000
*           /*                                                       */ 00525000
*           /*********************************************************/ 00526000
*                                                                  0262 00527000
*           UNPK(MU5BT350(1:LENGTH(MU5BT350)-1),BUF6);/* BIT=>ZONED     00528000
*                                      HEXADECIMAL                   */ 00529000
         UNPK  MU5BT350(7),BUF6(4)                                 0262 00530000
*           MU5BT350(LENGTH(MU5BT350):LENGTH(MU5BT350))=BUF6(LENGTH(    00531000
*               BUF6):LENGTH(BUF6));/* FINAL ZONED HEXADECIMAL DIGIT */ 00532000
         MVC   MU5BT350+7(1),BUF6+3                                0263 00533000
*           TR(MU5BT350,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00534000
         TR    MU5BT350(8),ZZ1TRHEX(@14)                           0264 00535000
*         END;                      /* BLRCNVXC(BUF6) FROM(BS)TO(CHAR   00536000
*                                      ACTER)SET(MU5BT350)REMARK(BIT    00537000
*                                      STRING WORD 6)TR(ZZ1TRHEX)    */ 00538000
*         DO;                       /* BLRCNVXC(BUF7) FROM(BS)TO(CHAR   00539000
*                                      ACTER)SET(MU5BT360)REMARK(BIT    00540000
*                                      STRING WORD 7)TR(ZZ1TRHEX)    */ 00541000
*                                                                  0266 00542000
*           /*********************************************************/ 00543000
*           /*                                                       */ 00544000
*           /* BIT STRING WORD 7                                     */ 00545000
*           /*                                                       */ 00546000
*           /*********************************************************/ 00547000
*                                                                  0267 00548000
*           UNPK(MU5BT360(1:LENGTH(MU5BT360)-1),BUF7);/* BIT=>ZONED     00549000
*                                      HEXADECIMAL                   */ 00550000
         UNPK  MU5BT360(7),BUF7(4)                                 0267 00551000
*           MU5BT360(LENGTH(MU5BT360):LENGTH(MU5BT360))=BUF7(LENGTH(    00552000
*               BUF7):LENGTH(BUF7));/* FINAL ZONED HEXADECIMAL DIGIT */ 00553000
         MVC   MU5BT360+7(1),BUF7+3                                0268 00554000
*           TR(MU5BT360,ZZ1TRHEX);  /* ZONED HEXADECIMAL=>EBCDIC     */ 00555000
         TR    MU5BT360(8),ZZ1TRHEX(@14)                           0269 00556000
*         END;                      /* BLRCNVXC(BUF7) FROM(BS)TO(CHAR   00557000
*                                      ACTER)SET(MU5BT360)REMARK(BIT    00558000
*                                      STRING WORD 7)TR(ZZ1TRHEX)    */ 00559000
*         DO;                       /* BLRCNVXC(BUF8) FROM(BS)TO(CHAR   00560000
*                                      ACTER)SET(MU5BT37)REMARK(BIT     00561000
*                                      STRING WORD 8)TR(ZZ1TRHEX)    */ 00562000
*                                                                  0271 00563000
*           /*********************************************************/ 00564000
*           /*                                                       */ 00565000
*           /* BIT STRING WORD 8                                     */ 00566000
*           /*                                                       */ 00567000
*           /*********************************************************/ 00568000
*                                                                  0272 00569000
*           UNPK(MU5BT37(1:LENGTH(MU5BT37)-1),BUF8);/* BIT=>ZONED  0272 00570000
*                                      HEXADECIMAL                   */ 00571000
         UNPK  MU5BT37(7),BUF8(4)                                  0272 00572000
*           MU5BT37(LENGTH(MU5BT37):LENGTH(MU5BT37))=BUF8(LENGTH(BUF8): 00573000
*               LENGTH(BUF8));      /* FINAL ZONED HEXADECIMAL DIGIT */ 00574000
         MVC   MU5BT37+7(1),BUF8+3                                 0273 00575000
*           TR(MU5BT37,ZZ1TRHEX);   /* ZONED HEXADECIMAL=>EBCDIC     */ 00576000
         TR    MU5BT37(8),ZZ1TRHEX(@14)                            0274 00577000
*         END;                      /* BLRCNVXC(BUF8) FROM(BS)TO(CHAR   00578000
*                                      ACTER)SET(MU5BT37)REMARK(BIT     00579000
*                                      STRING WORD 8)TR(ZZ1TRHEX)    */ 00580000
*         IF LINELEN<LENGTH(BUF) THEN                              0276 00581000
*                                                                  0276 00582000
         LA    @14,32                                              0276 00583000
         CR    LINELEN,@14                                         0276 00584000
         BNL   @RF00276                                            0276 00585000
*           /*********************************************************/ 00586000
*           /*                                                       */ 00587000
*           /* MORE BIT STRING DATA FORMATTED THAN REQUESTED. BLANK  */ 00588000
*           /* THAT OUTPUT FORMATTED BUT NOT REQUESTED.              */ 00589000
*           /*                                                       */ 00590000
*           /*********************************************************/ 00591000
*                                                                  0277 00592000
*           DO;                     /* BLANK IMPROPER OUTPUT         */ 00593000
*             J=LENGTH(BUF)-LINELEN;/* EXCESS BYTES FORMATTED        */ 00594000
         SLR   @14,LINELEN                                         0278 00595000
         LR    J,@14                                               0278 00596000
*             J=J*9/4+J/16;         /* BLANKS TO REINSERT            */ 00597000
         LR    @01,J                                               0279 00598000
         M     @00,@CF01187                                        0279 00599000
         D     @00,@CF00047                                        0279 00600000
         LR    @14,J                                               0279 00601000
         SRL   @14,4                                               0279 00602000
         ALR   @01,@14                                             0279 00603000
         LR    J,@01                                               0279 00604000
*             IF FLAGL='1'B THEN                                   0280 00605000
         TM    FLAGL,B'00010000'                                   0280 00606000
         BNO   @RF00280                                            0280 00607000
*               MU5BT3(LENGTH(MU5BT3)+1-J:LENGTH(MU5BT3))=MU5ST3(LENGTH 00608000
*                   (MU5BT3)+1-J:LENGTH(MU5BT3));/* TRAILING BLANKS  */ 00609000
         LA    @14,73                                              0281 00610000
         SLR   @14,J                                               0281 00611000
         LA    @03,MU5BT3-1(@14)                                   0281 00612000
         LA    @05,72                                              0281 00613000
         SLR   @05,@14                                             0281 00614000
         LA    @01,MU5ST3-1(@14)                                   0281 00615000
         EX    @05,@SM01211                                        0281 00616000
*             ELSE                                                 0282 00617000
*               MU5BT3(1:J)=MU5ST3(1:J);/* LEADING BLANKS            */ 00618000
         B     @RC00280                                            0282 00619000
@RF00280 LR    @14,J                                               0282 00620000
         BCTR  @14,0                                               0282 00621000
         EX    @14,@SM01213                                        0282 00622000
*           END;                                                   0283 00623000
*                                                                  0283 00624000
@RC00280 DS    0H                                                  0284 00625000
*         /***********************************************************/ 00626000
*         /*                                                         */ 00627000
*         /* DISPLAY DATA AS CHARACTER STRING AS WELL AS BIT STRING  */ 00628000
*         /*                                                         */ 00629000
*         /***********************************************************/ 00630000
*                                                                  0284 00631000
*         MU5BT5=BUF;               /* CHARACTER DATA                */ 00632000
@RF00276 MVC   MU5BT5(32),BUF                                      0284 00633000
*         TR(MU5BT5,ZZ1TREBC);      /* ELIMINATE NONGRAPHIC DATA     */ 00634000
         L     @14,ZZ2ZZ1P(,R9)                                    0285 00635000
         TR    MU5BT5(32),ZZ1TREBC(@14)                            0285 00636000
*         CALL BLSUPUTA(ZZ2,MU5B);  /* DISPLAY MESSAGE MU5           */ 00637000
         ST    R9,@AL00001                                         0286 00638000
         LA    @14,MU5B                                            0286 00639000
         ST    @14,@AL00001+4                                      0286 00640000
         L     @01,ZZ2BVTP(,R9)                                    0286 00641000
         L     @15,BVTPUTAP(,@01)                                  0286 00642000
         LA    @01,@AL00001                                        0286 00643000
         BALR  @14,@15                                             0286 00644000
*       END;                                                       0287 00645000
*     IF FLAGEND='0'B THEN                                         0288 00646000
*                                                                  0288 00647000
@RF00234 TM    FLAGEND,B'01000000'                                 0288 00648000
         BNZ   @RF00288                                            0288 00649000
*       /*************************************************************/ 00650000
*       /*                                                           */ 00651000
*       /* ANOTHER PASS WILL BE REQUIRED TO SATISFY THE REQUEST      */ 00652000
*       /*                                                           */ 00653000
*       /*************************************************************/ 00654000
*                                                                  0289 00655000
*       DO;                         /* ANOTHER PASS REQUIRED         */ 00656000
*         FLAGL='1'B;               /* LEFT-JUSTIFY DATA             */ 00657000
         OI    FLAGL,B'00010000'                                   0290 00658000
*         LINEADDR=LINEADDR+LINELEN;/* DUMP ADDRESS OF DATA LINE     */ 00659000
         ALR   LINEADDR,LINELEN                                    0291 00660000
*         LINELEN=MIN(MVCLD1L,LENGTH(BUF));/* LENGTH OF DATA LINE    */ 00661000
         L     LINELEN,MVCLD1L-1                                   0292 00662000
         LA    LINELEN,0(,LINELEN)                                 0292 00663000
         LA    @14,32                                              0292 00664000
         CR    LINELEN,@14                                         0292 00665000
         BNH   *+6                                                      00666000
         LR    LINELEN,@14                                         0292 00667000
*         IF ZZ1EVEP='1'B THEN                                     0293 00668000
*                                                                  0293 00669000
         L     @14,ZZ2ZZ1P(,R9)                                    0293 00670000
         TM    ZZ1EVEP(@14),B'01000000'                            0293 00671000
         BNO   @RF00293                                            0293 00672000
*           /*********************************************************/ 00673000
*           /*                                                       */ 00674000
*           /* ATTENTION INTERRUPTION--TERMINATE QUICKLY             */ 00675000
*           /*                                                       */ 00676000
*           /*********************************************************/ 00677000
*                                                                  0294 00678000
*           DO;                     /* ATTENTION INTERRUPTION        */ 00679000
*             RETC=MAX(RETC,ZZZFLAGS);/* SIGNAL INCOMPLETE           */ 00680000
         LA    @14,12                                              0295 00681000
         CR    RETC,@14                                            0295 00682000
         BNL   *+6                                                      00683000
         LR    RETC,@14                                            0295 00684000
*             FLAGEND='1'B;         /* TERMINATE QUICKLY             */ 00685000
         OI    FLAGEND,B'01000000'                                 0296 00686000
*           END;                                                   0297 00687000
*       END;                                                       0298 00688000
@RF00293 DS    0H                                                  0299 00689000
*   END;                                                           0299 00690000
@RF00288 DS    0H                                                  0299 00691000
@DE00150 TM    FLAGEND,B'01000000'                                 0299 00692000
         BZ    @DL00150                                            0299 00693000
*   RETURN CODE(RETC);                                             0300 00694000
*                                                                  0300 00695000
         L     @13,4(,@13)                                         0300 00696000
         L     @00,@SIZDATD                                        0300 00697000
         LR    @01,@11                                             0300 00698000
         BLSUFRES R,LV=(0),A=(1)                                        00699000
         LR    @15,@10                                             0300 00700000
         L     @14,12(,@13)                                        0300 00701000
         LM    @00,@12,20(@13)                                     0300 00702000
         BR    @14                                                 0300 00703000
*/********************************************************************/ 00704000
*/*                                                                  */ 00705000
*/* E100--BEGIN REDUNDANT DATA PROCESSING                            */ 00706000
*/*                                                                  */ 00707000
*/********************************************************************/ 00708000
*                                                                  0301 00709000
*E100:                              /* BEGIN REDUNDANT DATA          */ 00710000
*   PROCEDURE;                                                     0301 00711000
E100     STM   @14,@07,12(@13)                                     0301 00712000
         STM   @09,@12,56(@13)                                     0301 00713000
*   DUPLEN=LINELEN;                 /* LENGTH OF REPETITIVE AREA     */ 00714000
         LR    DUPLEN,LINELEN                                      0302 00715000
*   MDBT10=MU5BT10;                 /* REPETITIVE DATA ADDRESS       */ 00716000
         MVC   MDBT10(6),MU5BT10                                   0303 00717000
*   FLAGD='1'B;                     /* DUPLICATE DATA PROCESSING     */ 00718000
*   FLAGN='0'B;                     /* DATA LINE NOT NEW             */ 00719000
         OI    FLAGD,B'10000000'                                   0305 00720000
         NI    FLAGN,B'11110111'                                   0305 00721000
*   RETURN;                                                        0306 00722000
@EL00002 DS    0H                                                  0306 00723000
@EF00002 DS    0H                                                  0306 00724000
@ER00002 LM    @14,@07,12(@13)                                     0306 00725000
         LM    @09,@12,56(@13)                                     0306 00726000
         BR    @14                                                 0306 00727000
*   END E100;                                                      0307 00728000
*                                                                  0307 00729000
*/*BLSTPEND--DISPLAY FORMATTER                                       */ 00730000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00731000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00732000
*                                                                  0308 00733000
*   DECLARE                         /* DATA FOR AHB MACROS           */ 00734000
*     PTRBIT BIT(32) BOUNDARY(WORD),/* DATA CONVERSION WORK AREA FOR    00735000
*                                      POINTER DATA                  */ 00736000
*     PTRPTR POINTER DEFINED(PTRBIT),/* DATA CONVERSION WORK AREA FOR   00737000
*                                      POINTER DATA                  */ 00738000
*     PACKED BIT(64) BOUNDARY(DWORD);/* DATA CONVERSION WORK AREA    */ 00739000
*   DECLARE                         /* COMMON VARIABLES              */ 00740000
*     I256C CHAR(256) BASED,                                       0309 00741000
*     I031F FIXED(31) BASED,                                       0309 00742000
*     I031P PTR(31) BASED,                                         0309 00743000
*     I015F FIXED(15) BASED,                                       0309 00744000
*     I015P PTR(15) BASED,                                         0309 00745000
*     I008P PTR(8) BASED,                                          0309 00746000
*     I001C CHAR(1) BASED;                                         0309 00747000
*   GENERATE NODEFS NOREFS DATA;                                   0310 00748000
*   END BLSTU5                      /* BLRPEND(BLSTU5)               */ 00749000
*                                                                  0311 00750000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00751000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00752000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00753000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00754000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00755000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00756000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00757000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00758000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00759000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00760000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00761000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00762000
*                                                                  0311 00763000
*       ;                                                          0311 00764000
@EL00001 L     @13,4(,@13)                                         0311 00765000
@EF00001 L     @00,@SIZDATD                                        0311 00766000
         LR    @01,@11                                             0311 00767000
         BLSUFRES R,LV=(0),A=(1)                                        00768000
@ER00001 LM    @14,@12,12(@13)                                     0311 00769000
         BR    @14                                                 0311 00770000
@DATA    DS    0H                                                       00771000
@CH01200 DC    H'49'                                                    00772000
@CH00186 DC    H'59'                                                    00773000
@SM01211 MVC   0(0,@03),0(@01)                                          00774000
@SM01213 MVC   MU5BT3(0),MU5ST3                                         00775000
@DATD    DSECT                                                          00776000
         DS    0F                                                       00777000
@SA00001 DS    18F                                                      00778000
@PC00001 DS    3F                                                       00779000
@AL00001 DS    2A                                                       00780000
BLSTU5   CSECT                                                          00781000
         DS    0F                                                       00782000
@CF00050 DC    F'1'                                                     00783000
@CF00047 DC    F'4'                                                     00784000
@CF01187 DC    F'9'                                                     00785000
@CF00069 DC    F'32'                                                    00786000
@CF01158 DC    XL4'0000001F'                                            00787000
@CF01210 DC    XL4'0000FFFF'                                            00788000
@DATD    DSECT                                                          00789000
         DS    0D                                                       00790000
MVCLD    DS    CL16                                                     00791000
         ORG   MVCLD                                                    00792000
MVCLD1   DS    CL8                                                      00793000
         ORG   MVCLD1                                                   00794000
MVCLD1P  DS    AL4                                                      00795000
MVCLD12  DS    BL4                                                      00796000
         ORG   MVCLD12                                                  00797000
MVCLD1C  DS    CL1                                                      00798000
MVCLD1L  DS    FL3                                                      00799000
         ORG   MVCLD1+8                                                 00800000
MVCLD19  DS    0C                                                       00801000
         ORG   MVCLD+8                                                  00802000
MVCLD2   DS    CL8                                                      00803000
         ORG   MVCLD2                                                   00804000
MVCLD2P  DS    AL4                                                      00805000
MVCLD22  DS    BL4                                                      00806000
         ORG   MVCLD22                                                  00807000
MVCLD2C  DS    CL1                                                      00808000
MVCLD2L  DS    FL3                                                      00809000
         ORG   MVCLD2+8                                                 00810000
MVCLD29  DS    0C                                                       00811000
         ORG   MVCLD+16                                                 00812000
MVCLD99  DS    0C                                                       00813000
         ORG   MVCLD+16                                                 00814000
MU5B     DS    CL125                                                    00815000
         ORG   MU5B                                                     00816000
MU5BL    DS    FL2                                                      00817000
@NM00090 DS    BL2                                                      00818000
MU5BT    DS    CL121                                                    00819000
         ORG   MU5BT                                                    00820000
MU5BT0   DS    CL1                                                      00821000
MU5BT1   DS    CL7                                                      00822000
         ORG   MU5BT1                                                   00823000
MU5BT10  DS    CL6                                                      00824000
MU5BT11  DS    CL1                                                      00825000
         ORG   MU5BT+8                                                  00826000
MU5BT2   DS    CL3                                                      00827000
MU5BT3   DS    CL72                                                     00828000
         ORG   MU5BT3                                                   00829000
MU5BT30  DS    CL9                                                      00830000
         ORG   MU5BT30                                                  00831000
MU5BT300 DS    CL8                                                      00832000
MU5BT301 DS    CL1                                                      00833000
         ORG   MU5BT3+9                                                 00834000
MU5BT31  DS    CL9                                                      00835000
         ORG   MU5BT31                                                  00836000
MU5BT310 DS    CL8                                                      00837000
MU5BT311 DS    CL1                                                      00838000
         ORG   MU5BT3+18                                                00839000
MU5BT32  DS    CL9                                                      00840000
         ORG   MU5BT32                                                  00841000
MU5BT320 DS    CL8                                                      00842000
MU5BT321 DS    CL1                                                      00843000
         ORG   MU5BT3+27                                                00844000
MU5BT33  DS    CL10                                                     00845000
         ORG   MU5BT33                                                  00846000
MU5BT330 DS    CL8                                                      00847000
MU5BT331 DS    CL2                                                      00848000
         ORG   MU5BT3+37                                                00849000
MU5BT34  DS    CL9                                                      00850000
         ORG   MU5BT34                                                  00851000
MU5BT340 DS    CL8                                                      00852000
MU5BT341 DS    CL1                                                      00853000
         ORG   MU5BT3+46                                                00854000
MU5BT35  DS    CL9                                                      00855000
         ORG   MU5BT35                                                  00856000
MU5BT350 DS    CL8                                                      00857000
MU5BT351 DS    CL1                                                      00858000
         ORG   MU5BT3+55                                                00859000
MU5BT36  DS    CL9                                                      00860000
         ORG   MU5BT36                                                  00861000
MU5BT360 DS    CL8                                                      00862000
MU5BT361 DS    CL1                                                      00863000
         ORG   MU5BT3+64                                                00864000
MU5BT37  DS    CL8                                                      00865000
         ORG   MU5BT+83                                                 00866000
MU5BT4   DS    CL4                                                      00867000
MU5BT5   DS    CL32                                                     00868000
MU5BT6   DS    CL2                                                      00869000
         ORG   MU5B+125                                                 00870000
         DS    CL1                                                      00871000
MDB      DS    CL72                                                     00872000
         ORG   MDB                                                      00873000
MDBL     DS    FL2                                                      00874000
@NM00092 DS    BL2                                                      00875000
MDBT     DS    CL68                                                     00876000
         ORG   MDBT                                                     00877000
MDBT0    DS    CL1                                                      00878000
MDBT1    DS    CL7                                                      00879000
         ORG   MDBT1                                                    00880000
MDBT10   DS    CL6                                                      00881000
MDBT11   DS    CL1                                                      00882000
         ORG   MDBT+8                                                   00883000
MDBT2    DS    CL8                                                      00884000
MDBT3    DS    CL10                                                     00885000
MDBT4    DS    CL6                                                      00886000
MDBT5    DS    CL36                                                     00887000
         ORG   MDBT5                                                    00888000
MDBT50   DS    CL20                                                     00889000
MDBT51   DS    CL2                                                      00890000
MDBT52   DS    CL1                                                      00891000
MDBT53   DS    CL13                                                     00892000
         ORG   MDBT53                                                   00893000
MDBT530  DS    CL11                                                     00894000
MDBT531  DS    CL1                                                      00895000
MDBT532  DS    CL1                                                      00896000
         ORG   MDB+72                                                   00897000
BUF      DS    CL32                                                     00898000
         ORG   BUF                                                      00899000
BUF1     DS    CL4                                                      00900000
BUF2     DS    CL4                                                      00901000
BUF3     DS    CL4                                                      00902000
BUF4     DS    CL4                                                      00903000
BUF5     DS    CL4                                                      00904000
BUF6     DS    CL4                                                      00905000
BUF7     DS    CL4                                                      00906000
BUF8     DS    CL4                                                      00907000
         ORG   BUF+32                                                   00908000
FLAG     DS    BL1                                                      00909000
         ORG   FLAG                                                     00910000
FLAGD    DS    BL1                                                      00911000
FLAGEND  EQU   FLAG+0                                                   00912000
FLAGF    EQU   FLAG+0                                                   00913000
FLAGL    EQU   FLAG+0                                                   00914000
FLAGN    EQU   FLAG+0                                                   00915000
@NM00093 EQU   FLAG+0                                                   00916000
         ORG   FLAG+1                                                   00917000
         DS    CL1                                                      00918000
PTRBIT   DS    BL4                                                      00919000
         DS    CL4                                                      00920000
PACKED   DS    BL8                                                      00921000
BLSTU5   CSECT                                                          00922000
         DS    0F                                                       00923000
@SIZDATD DC    AL1(0)                                                   00924000
         DC    AL3(@ENDDATD-@DATD)                                      00925000
         DS    0D                                                       00926000
MU5S     DS    CL125                                                    00927000
         ORG   MU5S                                                     00928000
MU5SL    DC    AL2(125)                                                 00929000
@NM00089 DC    X'0000'                                                  00930000
MU5ST    DS    CL121                                                    00931000
         ORG   MU5ST                                                    00932000
MU5ST0   DC    CL1' '                                                   00933000
MU5ST1   DS    CL7                                                      00934000
         ORG   MU5ST1                                                   00935000
MU5ST10  DC    CL6'000000'                                              00936000
MU5ST11  DC    CL1'.'                                                   00937000
         ORG   MU5ST+8                                                  00938000
MU5ST2   DC    CL3' | '                                                 00939000
MU5ST3   DS    CL72                                                     00940000
         ORG   MU5ST3                                                   00941000
MU5ST30  DS    CL9                                                      00942000
         ORG   MU5ST30                                                  00943000
MU5ST300 DC    CL8' '                                                   00944000
MU5ST301 DC    CL1' '                                                   00945000
         ORG   MU5ST3+9                                                 00946000
MU5ST31  DS    CL9                                                      00947000
         ORG   MU5ST31                                                  00948000
MU5ST310 DC    CL8' '                                                   00949000
MU5ST311 DC    CL1' '                                                   00950000
         ORG   MU5ST3+18                                                00951000
MU5ST32  DS    CL9                                                      00952000
         ORG   MU5ST32                                                  00953000
MU5ST320 DC    CL8' '                                                   00954000
MU5ST321 DC    CL1' '                                                   00955000
         ORG   MU5ST3+27                                                00956000
MU5ST33  DS    CL10                                                     00957000
         ORG   MU5ST33                                                  00958000
MU5ST330 DC    CL8' '                                                   00959000
MU5ST331 DC    CL2' '                                                   00960000
         ORG   MU5ST3+37                                                00961000
MU5ST34  DS    CL9                                                      00962000
         ORG   MU5ST34                                                  00963000
MU5ST340 DC    CL8' '                                                   00964000
MU5ST341 DC    CL1' '                                                   00965000
         ORG   MU5ST3+46                                                00966000
MU5ST35  DS    CL9                                                      00967000
         ORG   MU5ST35                                                  00968000
MU5ST350 DC    CL8' '                                                   00969000
MU5ST351 DC    CL1' '                                                   00970000
         ORG   MU5ST3+55                                                00971000
MU5ST36  DS    CL9                                                      00972000
         ORG   MU5ST36                                                  00973000
MU5ST360 DC    CL8' '                                                   00974000
MU5ST361 DC    CL1' '                                                   00975000
         ORG   MU5ST3+64                                                00976000
MU5ST37  DC    CL8' '                                                   00977000
         ORG   MU5ST+83                                                 00978000
MU5ST4   DC    CL4' || '                                                00979000
MU5ST5   DC    CL32' '                                                  00980000
MU5ST6   DC    CL2' |'                                                  00981000
         ORG   MU5S+125                                                 00982000
TD       DS    CL13                                                     00983000
         ORG   TD                                                       00984000
TD1      DC    CL13'SAME AS ABOVE'                                      00985000
         ORG   TD+13                                                    00986000
MDS      DS    CL72                                                     00987000
         ORG   MDS                                                      00988000
MDSL     DC    AL2(72)                                                  00989000
@NM00091 DC    X'0000'                                                  00990000
MDST     DS    CL68                                                     00991000
         ORG   MDST                                                     00992000
MDST0    DC    CL1' '                                                   00993000
MDST1    DS    CL7                                                      00994000
         ORG   MDST1                                                    00995000
MDST10   DC    CL6'000000'                                              00996000
MDST11   DC    CL1'.'                                                   00997000
         ORG   MDST+8                                                   00998000
MDST2    DC    CL8' LENGTH('                                            00999000
MDST3    DC    X'40202020202020202120'                                  01000000
MDST4    DC    CL6') ==> '                                              01001000
MDST5    DS    CL36                                                     01002000
         ORG   MDST5                                                    01003000
MDST50   DC    CL20'ALL BYTES CONTAIN X'''                              01004000
MDST51   DC    CL2' '                                                   01005000
MDST52   DC    CL1''''                                                  01006000
MDST53   DS    CL13                                                     01007000
         ORG   MDST53                                                   01008000
MDST530  DC    CL11', EBCDIC C'''                                       01009000
MDST531  DC    CL1' '                                                   01010000
MDST532  DC    CL1''''                                                  01011000
         ORG   MDS+72                                                   01012000
@DATD    DSECT                                                          01013000
         SPACE 2                                                        01014000
*********************************************************************** 01015000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 01016000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 01017000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 01018000
*********************************************************************** 01019000
         SPACE                                                          01020000
BLSTU5   CSECT                                                          01021000
         ORG                                                            01022000
         DS    0D                                                       01023000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSTU5+19)/20+7)/8)CL8'BLSTU5'         01024000
@DATD    DSECT                                                          01025000
         DS    0H                                                       01026000
@DATD    DSECT                                                          01027000
         SPACE 2                                                        01028000
*********************************************************************** 01029000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 01030000
*********************************************************************** 01031000
         SPACE                                                          01032000
         DS    0D                                                       01033000
@DATD    DSECT                                                          01034000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                01035000
@ENDDATD EQU   *                                                        01036000
BLSTU5   CSECT                                                          01037000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       01038000
@01      EQU   01                                                       01039000
@02      EQU   02                                                       01040000
@03      EQU   03                                                       01041000
@04      EQU   04                                                       01042000
@05      EQU   05                                                       01043000
@06      EQU   06                                                       01044000
@07      EQU   07                                                       01045000
@08      EQU   08                                                       01046000
@09      EQU   09                                                       01047000
@10      EQU   10                                                       01048000
@11      EQU   11                                                       01049000
@12      EQU   12                                                       01050000
@13      EQU   13                                                       01051000
@14      EQU   14                                                       01052000
@15      EQU   15                                                       01053000
RETC     EQU   @10                                                      01054000
DUPLEN   EQU   @08                                                      01055000
LINELEN  EQU   @06                                                      01056000
LINEADDR EQU   @07                                                      01057000
J        EQU   @02                                                      01058000
R9       EQU   @09                                                      01059000
R0       EQU   @00                                                      01060000
R1       EQU   @01                                                      01061000
R2       EQU   @02                                                      01062000
R3       EQU   @03                                                      01063000
R4       EQU   @04                                                      01064000
R5       EQU   @05                                                      01065000
RB       EQU   @11                                                      01066000
RD       EQU   @13                                                      01067000
RE       EQU   @14                                                      01068000
RF       EQU   @15                                                      01069000
RA       EQU   @10                                                      01070000
RC       EQU   @12                                                      01071000
R6       EQU   @06                                                      01072000
R7       EQU   @07                                                      01073000
R8       EQU   @08                                                      01074000
ZZ1      EQU   0                                                        01075000
ZZ1ATTN  EQU   ZZ1+360                                                  01076000
ZZ1EVE   EQU   ZZ1ATTN+4                                                01077000
ZZ1EVEP  EQU   ZZ1EVE                                                   01078000
ZZ1F     EQU   ZZ1+368                                                  01079000
ZZ1TRHEX EQU   ZZ1+568                                                  01080000
ZZ1TREBC EQU   ZZ1+824                                                  01081000
ZZ1N     EQU   ZZ1+1116                                                 01082000
ZZ2      EQU   0                                                        01083000
ZZ2AMD   EQU   ZZ2                                                      01084000
@NM00025 EQU   ZZ2AMD+7                                                 01085000
ZZ2PRT   EQU   ZZ2+138                                                  01086000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 01087000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                01088000
ZZ2A     EQU   ZZ2+272                                                  01089000
ZZ2AF    EQU   ZZ2A+16                                                  01090000
ZZ2APID  EQU   ZZ2A+64                                                  01091000
ZZ2AD    EQU   ZZ2A+74                                                  01092000
ZZ2ADD   EQU   ZZ2AD                                                    01093000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 01094000
ZZ2ADM   EQU   ZZ2AD+46                                                 01095000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 01096000
ZZ2ADP   EQU   ZZ2AD+56                                                 01097000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 01098000
ZZ2AZZ6P EQU   ZZ2A+140                                                 01099000
ZZ2AQAS  EQU   ZZ2A+144                                                 01100000
ZZ2AQD   EQU   ZZ2A+160                                                 01101000
ZZ2AQDT  EQU   ZZ2AQD+10                                                01102000
ZZ2AQDF  EQU   ZZ2AQD+52                                                01103000
ZZ2STG   EQU   ZZ2+960                                                  01104000
ZZ2ALLOP EQU   ZZ2+992                                                  01105000
ZZ2FREEP EQU   ZZ2+996                                                  01106000
ZZ2FF19P EQU   ZZ2+1000                                                 01107000
ZZ2FRE1P EQU   ZZ2+1004                                                 01108000
ZZ2FF18P EQU   ZZ2+1008                                                 01109000
ZZ2DYNAP EQU   ZZ2+1012                                                 01110000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 01111000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 01112000
ZZ2STAIP EQU   ZZ2+1024                                                 01113000
ZZ2FF02P EQU   ZZ2+1028                                                 01114000
ZZ2GETLP EQU   ZZ2+1032                                                 01115000
ZZ2PARSP EQU   ZZ2+1036                                                 01116000
ZZ2PTGTP EQU   ZZ2+1040                                                 01117000
ZZ2PUTLP EQU   ZZ2+1044                                                 01118000
ZZ2SCANP EQU   ZZ2+1048                                                 01119000
ZZ2STCKP EQU   ZZ2+1052                                                 01120000
ZZ2TRMOP EQU   ZZ2+1064                                                 01121000
ZZ2TRMVP EQU   ZZ2+1068                                                 01122000
ZZ2PUTNP EQU   ZZ2+1084                                                 01123000
ZZ2TRMNP EQU   ZZ2+1088                                                 01124000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 01125000
ZZ2BVTP  EQU   ZZ2+1280                                                 01126000
ZZ2RVTP  EQU   ZZ2+1284                                                 01127000
ZZ2CPPL  EQU   ZZ2+1292                                                 01128000
ZZ2CPPLC EQU   ZZ2CPPL                                                  01129000
ZZ2ITR   EQU   ZZ2+2840                                                 01130000
ZZ2ITRE  EQU   ZZ2ITR+16                                                01131000
ZZ2ITSE  EQU   ZZ2+2864                                                 01132000
ZZ2ES    EQU   ZZ2+2872                                                 01133000
ZZ2AMDX  EQU   ZZ2+7160                                                 01134000
ZZ2AXO   EQU   ZZ2+7934                                                 01135000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 01136000
CMD      EQU   0                                                        01137000
CMDT     EQU   CMD+4                                                    01138000
PSCB     EQU   0                                                        01139000
PSCBATR1 EQU   PSCB+16                                                  01140000
ECT      EQU   0                                                        01141000
ECTSWS   EQU   ECT+28                                                   01142000
ECTSWS2  EQU   ECT+40                                                   01143000
ECTSWS21 EQU   ECTSWS2                                                  01144000
UPT      EQU   0                                                        01145000
UPTSWS   EQU   UPT+12                                                   01146000
SA       EQU   0                                                        01147000
SA1      EQU   SA                                                       01148000
SAR      EQU   SA+12                                                    01149000
SAR1     EQU   SAR+12                                                   01150000
BLSUMPK1 EQU   0                                                        01151000
BLSUPUTA EQU   0                                                        01152000
BVT      EQU   0                                                        01153000
BVTPUTLP EQU   BVT+4                                                    01154000
BVTPUTOP EQU   BVT+12                                                   01155000
BVTPUTTP EQU   BVT+16                                                   01156000
BVTPUTVP EQU   BVT+20                                                   01157000
BVTPUTAP EQU   BVT+24                                                   01158000
BVTPRTTP EQU   BVT+28                                                   01159000
BVTPRTAP EQU   BVT+32                                                   01160000
BVTPUTDP EQU   BVT+36                                                   01161000
BVTMONP  EQU   BVT+40                                                   01162000
BVTMON2P EQU   BVT+44                                                   01163000
BVTVSARP EQU   BVT+48                                                   01164000
BVTVSENP EQU   BVT+64                                                   01165000
BVTVSERP EQU   BVT+68                                                   01166000
BVTVSGEP EQU   BVT+72                                                   01167000
BVTVSGUP EQU   BVT+76                                                   01168000
BVTVSPOP EQU   BVT+80                                                   01169000
BVTVSPUP EQU   BVT+84                                                   01170000
BVTMPKNP EQU   BVT+104                                                  01171000
BVTMONLP EQU   BVT+108                                                  01172000
BVTPUTCP EQU   BVT+132                                                  01173000
BVTMPK1P EQU   BVT+136                                                  01174000
BVTZZ2RP EQU   BVT+140                                                  01175000
BVTPGMRP EQU   BVT+144                                                  01176000
BVTMONAP EQU   BVT+148                                                  01177000
BVTBLDDP EQU   BVT+152                                                  01178000
BVTBLDLP EQU   BVT+156                                                  01179000
BVTPGMCP EQU   BVT+160                                                  01180000
BVTPGMDP EQU   BVT+164                                                  01181000
BVTPGMLP EQU   BVT+168                                                  01182000
BVTMONCP EQU   BVT+180                                                  01183000
BVTMONDP EQU   BVT+184                                                  01184000
BVTMONTP EQU   BVT+188                                                  01185000
BVTPARIP EQU   BVT+192                                                  01186000
BVTPARUP EQU   BVT+196                                                  01187000
BVTPRTNP EQU   BVT+204                                                  01188000
BVTVSCRP EQU   BVT+208                                                  01189000
BVTVSMRP EQU   BVT+212                                                  01190000
BVTMONXP EQU   BVT+216                                                  01191000
BVTTRMAP EQU   BVT+228                                                  01192000
ZZ6      EQU   0                                                        01193000
ZZ6D     EQU   ZZ6+128                                                  01194000
ZZ6DD    EQU   ZZ6D+8                                                   01195000
ZZ6DDT   EQU   ZZ6DD+4                                                  01196000
ZZ6DQA   EQU   ZZ6D+68                                                  01197000
ZZ6DF    EQU   ZZ6D+92                                                  01198000
ZZ6B     EQU   ZZ6+768                                                  01199000
RVT      EQU   0                                                        01200000
RVTADDRP EQU   RVT                                                      01201000
RVTT01P  EQU   RVT+4                                                    01202000
RVTTAP   EQU   RVT+8                                                    01203000
RVTTBP   EQU   RVT+12                                                   01204000
RVTTCP   EQU   RVT+16                                                   01205000
RVTTFP   EQU   RVT+24                                                   01206000
RVTTYP   EQU   RVT+40                                                   01207000
RVTT02P  EQU   RVT+48                                                   01208000
RVTT03P  EQU   RVT+52                                                   01209000
RVTT04P  EQU   RVT+56                                                   01210000
RVTACCLP EQU   RVT+60                                                   01211000
RVTRACCP EQU   RVT+64                                                   01212000
RVTTLP   EQU   RVT+68                                                   01213000
RVTTMP   EQU   RVT+72                                                   01214000
RVTTUP   EQU   RVT+80                                                   01215000
RVTESGEP EQU   RVT+84                                                   01216000
RVTESGUP EQU   RVT+88                                                   01217000
RVTESARP EQU   RVT+92                                                   01218000
RVTRAARP EQU   RVT+96                                                   01219000
RVTRAGEP EQU   RVT+100                                                  01220000
RVTADDPP EQU   RVT+104                                                  01221000
RVTACCQP EQU   RVT+108                                                  01222000
RVTSAGUP EQU   RVT+124                                                  01223000
RVTSAGEP EQU   RVT+128                                                  01224000
RVTESCKP EQU   RVT+132                                                  01225000
RVTMSGAP EQU   RVT+136                                                  01226000
RVTMSGDP EQU   RVT+140                                                  01227000
RVTADDTP EQU   RVT+160                                                  01228000
RVTADDUP EQU   RVT+164                                                  01229000
RVTADD1P EQU   RVT+176                                                  01230000
RVTADD2P EQU   RVT+180                                                  01231000
RVTRSAGP EQU   RVT+184                                                  01232000
RVTMSGBP EQU   RVT+188                                                  01233000
RVTADDSP EQU   RVT+192                                                  01234000
RVTADD3P EQU   RVT+196                                                  01235000
RVTT05P  EQU   RVT+200                                                  01236000
RVTPADSP EQU   RVT+204                                                  01237000
RVTTRP   EQU   RVT+228                                                  01238000
RVTADD4P EQU   RVT+232                                                  01239000
RVTSAPCP EQU   RVT+236                                                  01240000
RVTSAARP EQU   RVT+240                                                  01241000
RVTSAGNP EQU   RVT+244                                                  01242000
RVTT06P  EQU   RVT+248                                                  01243000
RVTSAGCP EQU   RVT+252                                                  01244000
RVTSAGQP EQU   RVT+256                                                  01245000
RVTESGCP EQU   RVT+260                                                  01246000
RVTESGQP EQU   RVT+264                                                  01247000
RVTDUCKP EQU   RVT+276                                                  01248000
RVTDUCCP EQU   RVT+280                                                  01249000
I001C    EQU   0                                                        01250000
BLSRACC  EQU   0                                                        01251000
BLSRACCL EQU   0                                                        01252000
BLSRACCQ EQU   0                                                        01253000
BLSRADDP EQU   0                                                        01254000
BLSRADDR EQU   0                                                        01255000
BLSRADDS EQU   0                                                        01256000
BLSRADDT EQU   0                                                        01257000
BLSRADDU EQU   0                                                        01258000
BLSRADD1 EQU   0                                                        01259000
BLSRADD2 EQU   0                                                        01260000
BLSRADD3 EQU   0                                                        01261000
BLSRADD4 EQU   0                                                        01262000
BLSRDUCC EQU   0                                                        01263000
BLSRDUCK EQU   0                                                        01264000
BLSRESAR EQU   0                                                        01265000
BLSRESCK EQU   0                                                        01266000
BLSRESGC EQU   0                                                        01267000
BLSRESGE EQU   0                                                        01268000
BLSRESGQ EQU   0                                                        01269000
BLSRESGU EQU   0                                                        01270000
BLSRMSGA EQU   0                                                        01271000
BLSRMSGB EQU   0                                                        01272000
BLSRMSGD EQU   0                                                        01273000
BLSRPADS EQU   0                                                        01274000
BLSRRAAR EQU   0                                                        01275000
BLSRRAGE EQU   0                                                        01276000
BLSRSAAR EQU   0                                                        01277000
BLSRSAG  EQU   0                                                        01278000
BLSRSAGC EQU   0                                                        01279000
BLSRSAGE EQU   0                                                        01280000
BLSRSAGN EQU   0                                                        01281000
BLSRSAGQ EQU   0                                                        01282000
BLSRSAGU EQU   0                                                        01283000
BLSRSAPC EQU   0                                                        01284000
BLSTA    EQU   0                                                        01285000
BLSTB    EQU   0                                                        01286000
BLSTC    EQU   0                                                        01287000
BLSTF    EQU   0                                                        01288000
BLSTL    EQU   0                                                        01289000
BLSTM    EQU   0                                                        01290000
BLSTR    EQU   0                                                        01291000
BLSTU    EQU   0                                                        01292000
BLSTY    EQU   0                                                        01293000
BLST01   EQU   0                                                        01294000
BLST02   EQU   0                                                        01295000
BLST03   EQU   0                                                        01296000
BLST04   EQU   0                                                        01297000
BLST05   EQU   0                                                        01298000
BLST06   EQU   0                                                        01299000
BLSUALLO EQU   0                                                        01300000
BLSUBLDD EQU   0                                                        01301000
BLSUBLDL EQU   0                                                        01302000
BLSUDYNA EQU   0                                                        01303000
BLSUFREE EQU   0                                                        01304000
BLSUFRE1 EQU   0                                                        01305000
BLSUMON  EQU   0                                                        01306000
BLSUMONA EQU   0                                                        01307000
BLSUMONC EQU   0                                                        01308000
BLSUMOND EQU   0                                                        01309000
BLSUMONL EQU   0                                                        01310000
BLSUMONT EQU   0                                                        01311000
BLSUMONX EQU   0                                                        01312000
BLSUMON2 EQU   0                                                        01313000
BLSUMPKN EQU   0                                                        01314000
BLSUPARI EQU   0                                                        01315000
BLSUPARU EQU   0                                                        01316000
BLSUPGMC EQU   0                                                        01317000
BLSUPGMD EQU   0                                                        01318000
BLSUPGML EQU   0                                                        01319000
BLSUPGMR EQU   0                                                        01320000
BLSUPRTA EQU   0                                                        01321000
BLSUPRTN EQU   0                                                        01322000
BLSUPRTT EQU   0                                                        01323000
BLSUPUTC EQU   0                                                        01324000
BLSUPUTD EQU   0                                                        01325000
BLSUPUTL EQU   0                                                        01326000
BLSUPUTN EQU   0                                                        01327000
BLSUPUTO EQU   0                                                        01328000
BLSUPUTT EQU   0                                                        01329000
BLSUPUTV EQU   0                                                        01330000
BLSUSTAI EQU   0                                                        01331000
BLSUTRMA EQU   0                                                        01332000
BLSUTRMN EQU   0                                                        01333000
BLSUTRMO EQU   0                                                        01334000
BLSUTRMV EQU   0                                                        01335000
BLSUVSAR EQU   0                                                        01336000
BLSUVSCR EQU   0                                                        01337000
BLSUVSEN EQU   0                                                        01338000
BLSUVSER EQU   0                                                        01339000
BLSUVSGE EQU   0                                                        01340000
BLSUVSGU EQU   0                                                        01341000
BLSUVSMR EQU   0                                                        01342000
BLSUVSPO EQU   0                                                        01343000
BLSUVSPU EQU   0                                                        01344000
BLSUZZ2C EQU   0                                                        01345000
BLSUZZ2D EQU   0                                                        01346000
BLSUZZ2R EQU   0                                                        01347000
IKJEFF02 EQU   0                                                        01348000
IKJEFF18 EQU   0                                                        01349000
IKJEFF19 EQU   0                                                        01350000
IKJGETL  EQU   0                                                        01351000
IKJPARS  EQU   0                                                        01352000
IKJPTGT  EQU   0                                                        01353000
IKJPUTL  EQU   0                                                        01354000
IKJSCAN  EQU   0                                                        01355000
IKJSTCK  EQU   0                                                        01356000
I008P    EQU   0                                                        01357000
I015F    EQU   0                                                        01358000
I015P    EQU   0                                                        01359000
I031F    EQU   0                                                        01360000
I031P    EQU   0                                                        01361000
I256C    EQU   0                                                        01362000
PZ2      EQU   0                                                        01363000
ESPA     EQU   0                                                        01364000
ESPAAS   EQU   ESPA+60                                                  01365000
ESPALAD  EQU   ESPA+76                                                  01366000
ESPAD    EQU   ESPA+80                                                  01367000
ESPADOF  EQU   ESPAD                                                    01368000
ESPADLE  EQU   ESPAD+4                                                  01369000
ESPADT   EQU   ESPAD+10                                                 01370000
ESPADIM  EQU   ESPAD+44                                                 01371000
ESPADF   EQU   ESPAD+52                                                 01372000
ESPAF    EQU   ESPA+161                                                 01373000
ESPAFS   EQU   ESPAF                                                    01374000
ESPAFC   EQU   ESPAF+1                                                  01375000
ESPAR    EQU   ESPA+180                                                 01376000
ESPART   EQU   ESPAR+2                                                  01377000
BLK      EQU   0                                                        01378000
CPPL     EQU   ZZ2CPPL                                                  01379000
CPPLUPT  EQU   CPPL+4                                                   01380000
CPPLPSCB EQU   CPPL+8                                                   01381000
CPPLECT  EQU   CPPL+12                                                  01382000
PTRPTR   EQU   PTRBIT                                                   01383000
@RC00160 EQU   @RC00158                                                 01840000
@RC00170 EQU   @RC00160                                                 01841000
L020     EQU   @RC00160                                                 01842000
@ENDDATA EQU   *                                                        01843000
         END   BLSTU5                                           DSKC445 01844000
