T05      TITLE 'BLST05  --IPCS SERVICE ROUTINE TO DISPLAY FIXED DATA   *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPLK                           */ 00004000
*/*------------------------------------------------------------------*/ 00005000
BLST05   CSECT ,                                                   0002 00006000
@MAINENT DS    0H                                                  0002 00007000
         USING *,@15                                               0002 00008000
         B     @PROLOG                                             0002 00009000
         DC    AL1(16)                                             0002 00010000
         DC    C'BLST05    78.059'                                 0002 00011000
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
         XC    @ZTEMPS(@ZLEN),@ZTEMPS                                   00025000
         MVC   @PC00001(32),0(@01)                                 0002 00026000
*   RETC=ZZZFLAGI;                  /* INITIALIZE RETURN CODE        */ 00027000
         SLR   RETC,RETC                                           0136 00028000
*   FLAG='00'X;                                                    0137 00029000
         MVI   FLAG,X'00'                                          0137 00030000
*   MFB=MFS;                                                       0138 00031000
         MVC   MFB(81),MFS                                         0138 00032000
*   MAB=MFS;                                                       0139 00033000
         MVC   MAB(81),MFS                                         0139 00034000
*   DATAPTR=ADDR(BLK);                                             0140 00035000
         L     DATAPTR,@PC00001+8                                  0140 00036000
*   LINEADDR=ESPALAD+ESPADOF;                                      0141 00037000
         L     @14,@PC00001+4                                      0141 00038000
         L     LINEADDR,ESPALAD(,@14)                              0141 00039000
         AL    LINEADDR,ESPADOF(,@14)                              0141 00040000
*   ITEMS=MAX(ESPADIM,1);                                          0142 00041000
         LA    @10,1                                               0142 00042000
         L     @08,ESPADIM(,@14)                                   0142 00043000
         CLR   @08,@10                                             0142 00044000
         BNL   *+6                                                      00045000
         LR    @08,@10                                             0142 00046000
         ST    @08,ITEMS                                           0142 00047000
*   IF(ITEMS>PERLINE)&((LINEADDR&MASK1)^=0)&((LINEADDR&MASK2)=0) THEN   00048000
         L     @05,@PC00001+12                                     0143 00049000
         C     @08,PERLINE(,@05)                                   0143 00050000
         BNH   @RF00143                                            0143 00051000
         SLR   @08,@08                                             0143 00052000
         L     @05,@PC00001+16                                     0143 00053000
         LR    @07,LINEADDR                                        0143 00054000
         N     @07,MASK1(,@05)                                     0143 00055000
         CLR   @07,@08                                             0143 00056000
         BE    @RF00143                                            0143 00057000
         L     @05,@PC00001+20                                     0143 00058000
         LR    @06,LINEADDR                                        0143 00059000
         N     @06,MASK2(,@05)                                     0143 00060000
         CLR   @06,@08                                             0143 00061000
         BNE   @RF00143                                            0143 00062000
*     FIRST=(LINEADDR&MASK1)/ESPADLE+1;/* INDENT LINE 1 OF BODY      */ 00063000
         SLR   @06,@06                                             0144 00064000
         D     @06,ESPADLE(,@14)                                   0144 00065000
         ALR   @07,@10                                             0144 00066000
         ST    @07,FIRST                                           0144 00067000
*   ELSE                                                           0145 00068000
*     FIRST=1;                      /* START LINE 1 AT LEFT MARGIN   */ 00069000
         B     @RC00143                                            0145 00070000
@RF00143 MVC   FIRST(4),@CF00060                                   0145 00071000
*   DO;                             /* BLRCNVPC(LINEADDR) FROM(POINTE   00072000
*                                      R)TO(CHARACTER)SET(MABT10)REMA   00073000
*                                      RK(ADDRESS IN               0146 00074000
*                                      DUMP)TR(ZZ1TRHEX)             */ 00075000
*                                                                  0146 00076000
@RC00143 DS    0H                                                  0147 00077000
*     /***************************************************************/ 00078000
*     /*                                                             */ 00079000
*     /* ADDRESS IN DUMP                                             */ 00080000
*     /*                                                             */ 00081000
*     /***************************************************************/ 00082000
*                                                                  0147 00083000
*     PTRPTR=LINEADDR;              /* SOURCE TO BIT/POINTER       0147 00084000
*                                      INTERMEDIATE                  */ 00085000
         ST    LINEADDR,PTRPTR                                     0147 00086000
*     UNPK(MABT10(1:LENGTH(MABT10)-1),PTRBIT);/* BIT=>ZONED        0148 00087000
*                                      HEXADECIMAL                   */ 00088000
         UNPK  MABT10(5),PTRBIT(4)                                 0148 00089000
*     MABT10(LENGTH(MABT10):LENGTH(MABT10))=PTRBIT(25:32);/* FINAL 0149 00090000
*                                      ZONED HEXADECIMAL DIGIT       */ 00091000
         MVC   MABT10+5(1),PTRBIT+3                                0149 00092000
*     TR(MABT10,ZZ1TRHEX);          /* ZONED HEXADECIMAL=>EBCDIC     */ 00093000
         L     @14,ZZ2ZZ1P(,R9)                                    0150 00094000
         TR    MABT10(6),ZZ1TRHEX(@14)                             0150 00095000
*   END;                            /* BLRCNVPC(LINEADDR) FROM(POINTE   00096000
*                                      R)TO(CHARACTER)SET(MABT10)REMA   00097000
*                                      RK(ADDRESS IN               0151 00098000
*                                      DUMP)TR(ZZ1TRHEX)             */ 00099000
*   CALL FMTX(ZZ2,DATA,FIRST,ITEMS,MABT3,VAL1);                    0152 00100000
         ST    R9,@AL00001                                         0152 00101000
         ST    DATAPTR,@AL00001+4                                  0152 00102000
         LA    @14,FIRST                                           0152 00103000
         ST    @14,@AL00001+8                                      0152 00104000
         LA    @14,ITEMS                                           0152 00105000
         ST    @14,@AL00001+12                                     0152 00106000
         LA    @14,MABT3                                           0152 00107000
         ST    @14,@AL00001+16                                     0152 00108000
         LA    @14,VAL1                                            0152 00109000
         ST    @14,@AL00001+20                                     0152 00110000
         L     @10,@PC00001+24                                     0152 00111000
         L     @15,FMTPTR(,@10)                                    0152 00112000
         LA    @01,@AL00001                                        0152 00113000
         BALR  @14,@15                                             0152 00114000
*   FLAGA='1'B;                     /* INDICATE THAT MAB IS VALID    */ 00115000
         OI    FLAGA,B'00100000'                                   0153 00116000
*   FIRST=FIRST-1;                                                 0154 00117000
         L     @14,FIRST                                           0154 00118000
         BCTR  @14,0                                               0154 00119000
         ST    @14,FIRST                                           0154 00120000
*   LINEADDR=LINEADDR+(PERLINE-FIRST)*ESPADLE;/* ADDRESS IN DUMP     */ 00121000
         L     @10,@PC00001+12                                     0155 00122000
         L     @10,PERLINE(,@10)                                   0155 00123000
         LR    @01,@10                                             0155 00124000
         SLR   @01,@14                                             0155 00125000
         L     @08,@PC00001+4                                      0155 00126000
         M     @00,ESPADLE(,@08)                                   0155 00127000
         ALR   LINEADDR,@01                                        0155 00128000
*   DATAPTR=DATAPTR+(PERLINE-FIRST)*ESPADLE;/* ADDRESS IN BUFFER     */ 00129000
         ALR   DATAPTR,@01                                         0156 00130000
*   ITEMS=ITEMS-PERLINE+FIRST;      /* NUMBER OF ITEMS TO GO         */ 00131000
         LCR   @10,@10                                             0157 00132000
         AL    @10,ITEMS                                           0157 00133000
         ALR   @10,@14                                             0157 00134000
         ST    @10,ITEMS                                           0157 00135000
*   DO WHILE ITEMS>0;                                              0158 00136000
         B     @DE00158                                            0158 00137000
@DL00158 DS    0H                                                  0159 00138000
*     DO;                           /* BLRCNVPC(LINEADDR) FROM(POINTE   00139000
*                                      R)TO(CHARACTER)SET(MFBT10)REMA   00140000
*                                      RK(ADDRESS IN               0159 00141000
*                                      DUMP)TR(ZZ1TRHEX)             */ 00142000
*                                                                  0159 00143000
*       /*************************************************************/ 00144000
*       /*                                                           */ 00145000
*       /* ADDRESS IN DUMP                                           */ 00146000
*       /*                                                           */ 00147000
*       /*************************************************************/ 00148000
*                                                                  0160 00149000
*       PTRPTR=LINEADDR;            /* SOURCE TO BIT/POINTER       0160 00150000
*                                      INTERMEDIATE                  */ 00151000
         ST    LINEADDR,PTRPTR                                     0160 00152000
*       UNPK(MFBT10(1:LENGTH(MFBT10)-1),PTRBIT);/* BIT=>ZONED      0161 00153000
*                                      HEXADECIMAL                   */ 00154000
         UNPK  MFBT10(5),PTRBIT(4)                                 0161 00155000
*       MFBT10(LENGTH(MFBT10):LENGTH(MFBT10))=PTRBIT(25:32);/* FINAL    00156000
*                                      ZONED HEXADECIMAL DIGIT       */ 00157000
         MVC   MFBT10+5(1),PTRBIT+3                                0162 00158000
*       TR(MFBT10,ZZ1TRHEX);        /* ZONED HEXADECIMAL=>EBCDIC     */ 00159000
         L     @14,ZZ2ZZ1P(,R9)                                    0163 00160000
         TR    MFBT10(6),ZZ1TRHEX(@14)                             0163 00161000
*     END;                          /* BLRCNVPC(LINEADDR) FROM(POINTE   00162000
*                                      R)TO(CHARACTER)SET(MFBT10)REMA   00163000
*                                      RK(ADDRESS IN               0164 00164000
*                                      DUMP)TR(ZZ1TRHEX)             */ 00165000
*     MFBT3='';                                                    0165 00166000
         MVI   MFBT3,C' '                                          0165 00167000
         MVC   MFBT3+1(63),MFBT3                                   0165 00168000
*     CALL FMTX(ZZ2,DATA,1,ITEMS,MFBT3,VAL1);                      0166 00169000
         ST    R9,@AL00001                                         0166 00170000
         ST    DATAPTR,@AL00001+4                                  0166 00171000
         LA    @14,@CF00060                                        0166 00172000
         ST    @14,@AL00001+8                                      0166 00173000
         LA    @14,ITEMS                                           0166 00174000
         ST    @14,@AL00001+12                                     0166 00175000
         LA    @14,MFBT3                                           0166 00176000
         ST    @14,@AL00001+16                                     0166 00177000
         LA    @14,VAL1                                            0166 00178000
         ST    @14,@AL00001+20                                     0166 00179000
         L     @10,@PC00001+24                                     0166 00180000
         L     @15,FMTPTR(,@10)                                    0166 00181000
         LA    @01,@AL00001                                        0166 00182000
         BALR  @14,@15                                             0166 00183000
*     IF FLAGD='1'B THEN                                           0167 00184000
         TM    FLAGD,B'10000000'                                   0167 00185000
         BNO   @RF00167                                            0167 00186000
*       DO;                         /* PROCESSING REPETITIVE DATA    */ 00187000
*         IF MFBT3=MABT3 THEN                                      0169 00188000
         CLC   MFBT3(64),MABT3                                     0169 00189000
         BNE   @RF00169                                            0169 00190000
*           DO;                                                    0170 00191000
*             CALL CKX(ZZ2,DATA);                                  0171 00192000
         ST    R9,@AL00001                                         0171 00193000
         ST    DATAPTR,@AL00001+4                                  0171 00194000
         L     @10,@PC00001+28                                     0171 00195000
         L     @15,CKPTR(,@10)                                     0171 00196000
         LA    @01,@AL00001                                        0171 00197000
         BALR  @14,@15                                             0171 00198000
*             IF RF^=0 THEN                                        0172 00199000
         LTR   RF,RF                                               0172 00200000
         BZ    @RF00172                                            0172 00201000
*               FLAGD1='0'B;        /* ALL VALUES NOT THE SAME       */ 00202000
         NI    FLAGD1,B'10111111'                                  0173 00203000
*             DUPCNT=DUPCNT+PERLINE;/* THIS LINE A DUP ALSO          */ 00204000
@RF00172 L     @14,@PC00001+12                                     0174 00205000
         L     @10,DUPCNT                                          0174 00206000
         AL    @10,PERLINE(,@14)                                   0174 00207000
         ST    @10,DUPCNT                                          0174 00208000
*           END;                                                   0175 00209000
*         ELSE                                                     0176 00210000
*           DO;                     /* THIS LINE DIFFERENT -- DISPLAY   00211000
*                                      SUMMARY                       */ 00212000
         B     @RC00169                                            0176 00213000
@RF00169 DS    0H                                                  0177 00214000
*             CALL SUMUP;                                          0177 00215000
         BAL   @14,SUMUP                                           0177 00216000
*           END;                                                   0178 00217000
*       END;                                                       0179 00218000
*     ELSE                                                         0180 00219000
*       DO;                         /* PROCESSING NONREPETITIVE DATA */ 00220000
         B     @RC00167                                            0180 00221000
@RF00167 DS    0H                                                  0181 00222000
*         IF MFBT3=MABT3 THEN                                      0181 00223000
         CLC   MFBT3(64),MABT3                                     0181 00224000
         BNE   @RF00181                                            0181 00225000
*           DO;                     /* FIRST REPETITIVE LINE         */ 00226000
*             FLAGD='1'B;                                          0183 00227000
         OI    FLAGD,B'10000000'                                   0183 00228000
*             DUPVAL=VAL1;                                         0184 00229000
         MVC   DUPVAL(16),VAL1                                     0184 00230000
*             CALL CKX(ZZ2,DATA);                                  0185 00231000
         ST    R9,@AL00001                                         0185 00232000
         ST    DATAPTR,@AL00001+4                                  0185 00233000
         L     @10,@PC00001+28                                     0185 00234000
         L     @15,CKPTR(,@10)                                     0185 00235000
         LA    @01,@AL00001                                        0185 00236000
         BALR  @14,@15                                             0185 00237000
*             IF RF=0 THEN                                         0186 00238000
         LTR   RF,RF                                               0186 00239000
         BNZ   @RF00186                                            0186 00240000
*               DO;                                                0187 00241000
*                 FLAGD1='1'B;      /* ALL VALUES ON LINE SAME TOO   */ 00242000
         OI    FLAGD1,B'01000000'                                  0188 00243000
*                 STARTA=MABT10;    /* START ADDRESS                 */ 00244000
         MVC   STARTA(6),MABT10                                    0189 00245000
*                 DUPCNT=PERLINE*2;                                0190 00246000
         L     @14,@PC00001+12                                     0190 00247000
         L     @14,PERLINE(,@14)                                   0190 00248000
         ALR   @14,@14                                             0190 00249000
         ST    @14,DUPCNT                                          0190 00250000
*               END;                                               0191 00251000
*             ELSE                                                 0192 00252000
*               DO;                                                0192 00253000
         B     @RC00186                                            0192 00254000
@RF00186 DS    0H                                                  0193 00255000
*                 CALL BLSUPUTA(ZZ2,MAB);                          0193 00256000
         ST    R9,@AL00001                                         0193 00257000
         LA    @14,MAB                                             0193 00258000
         ST    @14,@AL00001+4                                      0193 00259000
         L     @10,ZZ2BVTP(,R9)                                    0193 00260000
         L     @15,BVTPUTAP(,@10)                                  0193 00261000
         LA    @01,@AL00001                                        0193 00262000
         BALR  @14,@15                                             0193 00263000
*                 STARTA=MFBT10;                                   0194 00264000
         MVC   STARTA(6),MFBT10                                    0194 00265000
*                 DUPCNT=PERLINE;                                  0195 00266000
         L     @14,@PC00001+12                                     0195 00267000
         MVC   DUPCNT(4),PERLINE(@14)                              0195 00268000
*               END;                                               0196 00269000
*             FLAGA='0'B;                                          0197 00270000
@RC00186 NI    FLAGA,B'11011111'                                   0197 00271000
*           END;                                                   0198 00272000
*         ELSE                                                     0199 00273000
*           DO;                     /* STILL DIFFERENT               */ 00274000
         B     @RC00181                                            0199 00275000
@RF00181 DS    0H                                                  0200 00276000
*             IF FLAGA='1'B THEN                                   0200 00277000
         TM    FLAGA,B'00100000'                                   0200 00278000
         BNO   @RF00200                                            0200 00279000
*               CALL BLSUPUTA(ZZ2,MAB);                            0201 00280000
         ST    R9,@AL00001                                         0201 00281000
         LA    @14,MAB                                             0201 00282000
         ST    @14,@AL00001+4                                      0201 00283000
         L     @10,ZZ2BVTP(,R9)                                    0201 00284000
         L     @15,BVTPUTAP(,@10)                                  0201 00285000
         LA    @01,@AL00001                                        0201 00286000
         BALR  @14,@15                                             0201 00287000
*             MAB=MFB;                                             0202 00288000
@RF00200 MVC   MAB(81),MFB                                         0202 00289000
*             FLAGA='1'B;           /* DATA IN MA VALID              */ 00290000
         OI    FLAGA,B'00100000'                                   0203 00291000
*           END;                                                   0204 00292000
*       END;                                                       0205 00293000
@RC00181 DS    0H                                                  0206 00294000
*     IF ZZ1EVEP='1'B THEN                                         0206 00295000
@RC00167 L     @14,ZZ2ZZ1P(,R9)                                    0206 00296000
         TM    ZZ1EVEP(@14),B'01000000'                            0206 00297000
         BNO   @RF00206                                            0206 00298000
*       DO;                         /* ATTENTION INTERRUPT -- GET OUT*/ 00299000
*         RETC=MAX(ZZZFLAGS,RETC);                                 0208 00300000
         LA    @14,12                                              0208 00301000
         CR    RETC,@14                                            0208 00302000
         BNL   *+6                                                      00303000
         LR    RETC,@14                                            0208 00304000
*         GOTO EXITD;                                              0209 00305000
         B     EXITD                                               0209 00306000
*       END;                                                       0210 00307000
*     LINEADDR=LINEADDR+PERLINE*ESPADLE;/* ADDRESS IN DUMP           */ 00308000
@RF00206 L     @14,@PC00001+12                                     0211 00309000
         L     @14,PERLINE(,@14)                                   0211 00310000
         L     @10,@PC00001+4                                      0211 00311000
         LR    @01,@14                                             0211 00312000
         M     @00,ESPADLE(,@10)                                   0211 00313000
         ALR   LINEADDR,@01                                        0211 00314000
*     DATAPTR=DATAPTR+PERLINE*ESPADLE;/* ADDRESS IN BUFFER           */ 00315000
         ALR   DATAPTR,@01                                         0212 00316000
*     ITEMS=ITEMS-PERLINE;          /* NUMBER OF ITEMS TO GO         */ 00317000
         LCR   @14,@14                                             0213 00318000
         AL    @14,ITEMS                                           0213 00319000
         ST    @14,ITEMS                                           0213 00320000
*   END;                                                           0214 00321000
@DE00158 L     @14,ITEMS                                           0214 00322000
         LTR   @14,@14                                             0214 00323000
         BP    @DL00158                                            0214 00324000
*EXITD:                                                            0215 00325000
*   IF FLAGA='1'B THEN                                             0215 00326000
EXITD    TM    FLAGA,B'00100000'                                   0215 00327000
         BNO   @RF00215                                            0215 00328000
*     CALL BLSUPUTA(ZZ2,MAB);                                      0216 00329000
         ST    R9,@AL00001                                         0216 00330000
         LA    @14,MAB                                             0216 00331000
         ST    @14,@AL00001+4                                      0216 00332000
         L     @10,ZZ2BVTP(,R9)                                    0216 00333000
         L     @15,BVTPUTAP(,@10)                                  0216 00334000
         LA    @01,@AL00001                                        0216 00335000
         BALR  @14,@15                                             0216 00336000
*   ELSE                                                           0217 00337000
*     IF FLAGD='1'B THEN                                           0217 00338000
         B     @RC00215                                            0217 00339000
@RF00215 TM    FLAGD,B'10000000'                                   0217 00340000
         BNO   @RF00217                                            0217 00341000
*       CALL SUMUP;                                                0218 00342000
         BAL   @14,SUMUP                                           0218 00343000
*   RETURN CODE(RETC);                                             0219 00344000
@RF00217 DS    0H                                                  0219 00345000
@RC00215 L     @13,4(,@13)                                         0219 00346000
         L     @00,@SIZDATD                                        0219 00347000
         LR    @01,@11                                             0219 00348000
         BLSUFRES R,LV=(0),A=(1)                                        00349000
         LR    @15,@04                                             0219 00350000
         L     @14,12(,@13)                                        0219 00351000
         LM    @00,@12,20(@13)                                     0219 00352000
         BR    @14                                                 0219 00353000
*                                                                  0220 00354000
*   /*****************************************************************/ 00355000
*   /*                                                               */ 00356000
*   /* DISPLAY SUMMARY OF REPETITIVE LINES                           */ 00357000
*   /*                                                               */ 00358000
*   /*****************************************************************/ 00359000
*                                                                  0220 00360000
*SUMUP:                                                            0220 00361000
*   PROCEDURE;                                                     0220 00362000
SUMUP    STM   @14,@12,@SA00002                                    0220 00363000
*   MDB=MDS;                                                       0221 00364000
         MVC   MDB(86),MDS                                         0221 00365000
*   MDBT10=STARTA;                                                 0222 00366000
         MVC   MDBT10(6),STARTA                                    0222 00367000
*   DO;                             /* BLRCNVUC(DUPCNT*PERLINE)    0223 00368000
*                                      FROM(UNSIGNED FIXED BINARY)TO(   00369000
*                                      CHARACTER)OPTIONS(OVERFLOW,PAT   00370000
*                                      TERN IN PLACE)PATTERN('4020202   00371000
*                                      0202020202120'X)SET(MDBT3)REMA   00372000
*                                      RK(LENGTH OF REPLICATED AREA) */ 00373000
*                                                                  0223 00374000
*     /***************************************************************/ 00375000
*     /*                                                             */ 00376000
*     /* LENGTH OF REPLICATED AREA                                   */ 00377000
*     /*                                                             */ 00378000
*     /***************************************************************/ 00379000
*                                                                  0224 00380000
*     U0000001=DUPCNT*PERLINE;      /* SOURCE EXPRESSION             */ 00381000
         L     @14,@PC00001+12                                     0224 00382000
         L     @01,DUPCNT                                          0224 00383000
         M     @00,PERLINE(,@14)                                   0224 00384000
         LR    U0000001,@01                                        0224 00385000
*     IF U0000001>999999999 THEN                                   0225 00386000
         C     U0000001,@CF01123                                   0225 00387000
         BNH   @RF00225                                            0225 00388000
*       MDBT3='**********';         /* OVERFLOW                      */ 00389000
         MVC   MDBT3(10),@CC01124                                  0226 00390000
*     ELSE                                                         0227 00391000
*       DO;                         /* FORMAT RESULT                 */ 00392000
         B     @RC00225                                            0227 00393000
@RF00225 DS    0H                                                  0228 00394000
*         CVD(U0000001,PACKED);     /* UNSIGNED BINARY=>PACKED     0228 00395000
*                                      DECIMAL                       */ 00396000
         CVD   U0000001,PACKED                                     0228 00397000
*         ED(MDBT3,PACKED(25:64));  /* PACKED DECIMAL=>EBCDIC        */ 00398000
         ED    MDBT3(10),PACKED+3                                  0229 00399000
*       END;                                                       0230 00400000
*   END;                            /* BLRCNVUC(DUPCNT*PERLINE)    0231 00401000
*                                      FROM(UNSIGNED FIXED BINARY)TO(   00402000
*                                      CHARACTER)OPTIONS(OVERFLOW,PAT   00403000
*                                      TERN IN PLACE)PATTERN('4020202   00404000
*                                      0202020202120'X)SET(MDBT3)REMA   00405000
*                                      RK(LENGTH OF REPLICATED AREA) */ 00406000
@RC00225 DS    0H                                                  0232 00407000
*   DO;                             /* BLRCNVUC(DUPCNT) FROM(UNSIGNED   00408000
*                                      FIXED BINARY)TO(CHARACTER)OPTI   00409000
*                                      ONS(OVERFLOW,PATTERN IN PLACE)   00410000
*                                      PATTERN('40202020202020202120'   00411000
*                                      X)SET(MDBT6)REMARK(NUMBER OF     00412000
*                                      ITEMS SKIPPED)                */ 00413000
*                                                                  0232 00414000
*     /***************************************************************/ 00415000
*     /*                                                             */ 00416000
*     /* NUMBER OF ITEMS SKIPPED                                     */ 00417000
*     /*                                                             */ 00418000
*     /***************************************************************/ 00419000
*                                                                  0233 00420000
*     IF DUPCNT>999999999 THEN                                     0233 00421000
         CLC   DUPCNT(4),@CF01123                                  0233 00422000
         BNH   @RF00233                                            0233 00423000
*       MDBT6='**********';         /* OVERFLOW                      */ 00424000
         MVC   MDBT6(10),@CC01124                                  0234 00425000
*     ELSE                                                         0235 00426000
*       DO;                         /* FORMAT RESULT                 */ 00427000
         B     @RC00233                                            0235 00428000
@RF00233 DS    0H                                                  0236 00429000
*         CVD(DUPCNT,PACKED);       /* UNSIGNED BINARY=>PACKED     0236 00430000
*                                      DECIMAL                       */ 00431000
         L     @14,DUPCNT                                          0236 00432000
         CVD   @14,PACKED                                          0236 00433000
*         ED(MDBT6,PACKED(25:64));  /* PACKED DECIMAL=>EBCDIC        */ 00434000
         ED    MDBT6(10),PACKED+3                                  0237 00435000
*       END;                                                       0238 00436000
*   END;                            /* BLRCNVUC(DUPCNT) FROM(UNSIGNED   00437000
*                                      FIXED BINARY)TO(CHARACTER)OPTI   00438000
*                                      ONS(OVERFLOW,PATTERN IN PLACE)   00439000
*                                      PATTERN('40202020202020202120'   00440000
*                                      X)SET(MDBT6)REMARK(NUMBER OF     00441000
*                                      ITEMS SKIPPED)                */ 00442000
@RC00233 DS    0H                                                  0240 00443000
*   IF FLAGD1='1'B THEN             /* ALL ITEMS ARE THE SAME TOO    */ 00444000
         TM    FLAGD1,B'01000000'                                  0240 00445000
         BNO   @RF00240                                            0240 00446000
*     MDBT91=DUPVAL;                                               0241 00447000
         MVC   MDBT91(16),DUPVAL                                   0241 00448000
*   ELSE                                                           0242 00449000
*     MDBT9=SAME;                                                  0242 00450000
         B     @RC00240                                            0242 00451000
@RF00240 MVC   MDBT9(35),SAME                                      0242 00452000
*   CALL BLSUMPK1(ZZ2,MDB);         /* REMOVE EXTRA BLANKS           */ 00453000
@RC00240 ST    R9,@AL00001                                         0243 00454000
         LA    @14,MDB                                             0243 00455000
         ST    @14,@AL00001+4                                      0243 00456000
         L     @10,ZZ2BVTP(,R9)                                    0243 00457000
         L     @15,BVTMPK1P(,@10)                                  0243 00458000
         LA    @01,@AL00001                                        0243 00459000
         BALR  @14,@15                                             0243 00460000
*   CALL BLSUPUTA(ZZ2,MDB);         /* DISPLAY SUMMARY               */ 00461000
         ST    R9,@AL00001                                         0244 00462000
         LA    @14,MDB                                             0244 00463000
         ST    @14,@AL00001+4                                      0244 00464000
         L     @10,ZZ2BVTP(,R9)                                    0244 00465000
         L     @15,BVTPUTAP(,@10)                                  0244 00466000
         LA    @01,@AL00001                                        0244 00467000
         BALR  @14,@15                                             0244 00468000
*   FLAGD='0'B;                     /* ENTER NONREPETITIVE MODE      */ 00469000
*   FLAGD1='0'B;                    /* ENTER NONDUPLICATE MODE       */ 00470000
         NI    FLAGD,B'00111111'                                   0246 00471000
*   MAB=MFB;                                                       0247 00472000
         MVC   MAB(81),MFB                                         0247 00473000
*   FLAGA='1'B;                                                    0248 00474000
         OI    FLAGA,B'00100000'                                   0248 00475000
*   RETURN CODE(ZZZFLAGI);                                         0249 00476000
         SLR   @15,@15                                             0249 00477000
         L     @14,@SA00002                                        0249 00478000
         LM    @00,@12,@SA00002+8                                  0249 00479000
         BR    @14                                                 0249 00480000
*   END SUMUP;                                                     0250 00481000
*                                                                  0250 00482000
*/*BLSTPEND--DISPLAY FORMATTER                                       */ 00483000
*/*BLSRPEND--DEBUGGING MODULE                                        */ 00484000
*/*BLSUPEND--MVS IPCS MODULE                                         */ 00485000
*                                                                  0251 00486000
*   DECLARE                         /* DATA FOR AHB MACROS           */ 00487000
*     PTRBIT BIT(32) BOUNDARY(WORD),/* DATA CONVERSION WORK AREA FOR    00488000
*                                      POINTER DATA                  */ 00489000
*     PTRPTR POINTER DEFINED(PTRBIT),/* DATA CONVERSION WORK AREA FOR   00490000
*                                      POINTER DATA                  */ 00491000
*     U0000001 UNSIGNED BINARY(31), /* DATA CONVERSION EXPRESSION  0251 00492000
*                                      HOLDER                        */ 00493000
*     PACKED BIT(64) BOUNDARY(DWORD);/* DATA CONVERSION WORK AREA    */ 00494000
*   DECLARE                         /* COMMON VARIABLES              */ 00495000
*     I256C CHAR(256) BASED,                                       0252 00496000
*     I031F FIXED(31) BASED,                                       0252 00497000
*     I031P PTR(31) BASED,                                         0252 00498000
*     I015F FIXED(15) BASED,                                       0252 00499000
*     I015P PTR(15) BASED,                                         0252 00500000
*     I008P PTR(8) BASED,                                          0252 00501000
*     I001C CHAR(1) BASED;                                         0252 00502000
*   GENERATE NODEFS NOREFS DATA;                                   0253 00503000
*   END BLST05                      /* BLRPEND(BLST05)               */ 00504000
*                                                                  0254 00505000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00506000
*/*%INCLUDE SYSLIB  (BLSRZZZ )                                       */ 00507000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                       */ 00508000
*/*%INCLUDE SYSLIB  (BLRFULL )                                       */ 00509000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 00510000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                       */ 00511000
*/*%INCLUDE SYSLIB  (IKJECT  )                                       */ 00512000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                       */ 00513000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                       */ 00514000
*/*%INCLUDE SYSLIB  (BLRSERV )                                       */ 00515000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                       */ 00516000
*/*%INCLUDE SYSLIB  (BLSRSERV)                                       */ 00517000
*                                                                  0254 00518000
*       ;                                                          0254 00519000
@EL00001 L     @13,4(,@13)                                         0254 00520000
@EF00001 L     @00,@SIZDATD                                        0254 00521000
         LR    @01,@11                                             0254 00522000
         BLSUFRES R,LV=(0),A=(1)                                        00523000
@ER00001 LM    @14,@12,12(@13)                                     0254 00524000
         BR    @14                                                 0254 00525000
@DATA    DS    0H                                                       00526000
@DATD    DSECT                                                          00527000
         DS    0F                                                       00528000
@SA00001 DS    18F                                                      00529000
@PC00001 DS    8F                                                       00530000
@SA00002 DS    15F                                                      00531000
@AL00001 DS    6A                                                       00532000
@ZTEMPS  DS    C                                                        00533000
@ZTEMPND EQU   *                                                        00534000
@ZLEN    EQU   @ZTEMPND-@ZTEMPS                                         00535000
BLST05   CSECT                                                          00536000
         DS    0F                                                       00537000
@CF00060 DC    F'1'                                                     00538000
@CF01123 DC    F'999999999'                                             00539000
@DATD    DSECT                                                          00540000
         DS    0D                                                       00541000
FIRST    DS    F                                                        00542000
ITEMS    DS    F                                                        00543000
DUPCNT   DS    F                                                        00544000
MFB      DS    CL81                                                     00545000
         ORG   MFB                                                      00546000
MFBL     DS    FL2                                                      00547000
@NM00090 DS    BL2                                                      00548000
MFBT     DS    CL77                                                     00549000
         ORG   MFBT                                                     00550000
MFBT0    DS    CL1                                                      00551000
MFBT1    DS    CL7                                                      00552000
         ORG   MFBT1                                                    00553000
MFBT10   DS    CL6                                                      00554000
MFBT11   DS    CL1                                                      00555000
         ORG   MFBT+8                                                   00556000
MFBT2    DS    CL3                                                      00557000
MFBT3    DS    CL64                                                     00558000
MFBT4    DS    CL2                                                      00559000
         ORG   MFB+81                                                   00560000
         DS    CL1                                                      00561000
MAB      DS    CL81                                                     00562000
         ORG   MAB                                                      00563000
MABL     DS    FL2                                                      00564000
@NM00091 DS    BL2                                                      00565000
MABT     DS    CL77                                                     00566000
         ORG   MABT                                                     00567000
MABT0    DS    CL1                                                      00568000
MABT1    DS    CL7                                                      00569000
         ORG   MABT1                                                    00570000
MABT10   DS    CL6                                                      00571000
MABT11   DS    CL1                                                      00572000
         ORG   MABT+8                                                   00573000
MABT2    DS    CL3                                                      00574000
MABT3    DS    CL64                                                     00575000
MABT4    DS    CL2                                                      00576000
         ORG   MAB+81                                                   00577000
         DS    CL1                                                      00578000
MDB      DS    CL86                                                     00579000
         ORG   MDB                                                      00580000
MDBL     DS    FL2                                                      00581000
@NM00093 DS    BL2                                                      00582000
MDBT     DS    CL82                                                     00583000
         ORG   MDBT                                                     00584000
MDBT0    DS    CL1                                                      00585000
MDBT1    DS    CL7                                                      00586000
         ORG   MDBT1                                                    00587000
MDBT10   DS    CL6                                                      00588000
MDBT11   DS    CL1                                                      00589000
         ORG   MDBT+8                                                   00590000
MDBT2    DS    CL8                                                      00591000
MDBT3    DS    CL10                                                     00592000
MDBT4    DS    CL1                                                      00593000
MDBT5    DS    CL3                                                      00594000
MDBT6    DS    CL10                                                     00595000
MDBT7    DS    CL6                                                      00596000
MDBT8    DS    CL1                                                      00597000
MDBT9    DS    CL35                                                     00598000
         ORG   MDBT9                                                    00599000
MDBT90   DS    CL18                                                     00600000
MDBT91   DS    CL16                                                     00601000
MDBT92   DS    CL1                                                      00602000
         ORG   MDB+86                                                   00603000
FLAG     DS    BL1                                                      00604000
         ORG   FLAG                                                     00605000
FLAGD    DS    BL1                                                      00606000
FLAGD1   EQU   FLAG+0                                                   00607000
FLAGA    EQU   FLAG+0                                                   00608000
@NM00094 EQU   FLAG+0                                                   00609000
         ORG   FLAG+1                                                   00610000
DUPVAL   DS    CL16                                                     00611000
VAL1     DS    CL16                                                     00612000
STARTA   DS    CL6                                                      00613000
         DS    CL3                                                      00614000
PTRBIT   DS    BL4                                                      00615000
         DS    CL4                                                      00616000
PACKED   DS    BL8                                                      00617000
BLST05   CSECT                                                          00618000
         DS    0F                                                       00619000
@SIZDATD DC    AL1(0)                                                   00620000
         DC    AL3(@ENDDATD-@DATD)                                      00621000
         DS    0D                                                       00622000
@CC01124 DC    C'**********'                                            00623000
MFS      DS    CL81                                                     00624000
         ORG   MFS                                                      00625000
MFSL     DC    AL2(81)                                                  00626000
@NM00089 DC    X'0000'                                                  00627000
MFST     DS    CL77                                                     00628000
         ORG   MFST                                                     00629000
MFST0    DC    CL1' '                                                   00630000
MFST1    DS    CL7                                                      00631000
         ORG   MFST1                                                    00632000
MFST10   DC    CL6'000000'                                              00633000
MFST11   DC    CL1'.'                                                   00634000
         ORG   MFST+8                                                   00635000
MFST2    DC    CL3' | '                                                 00636000
MFST3    DC    CL64' '                                                  00637000
MFST4    DC    CL2' |'                                                  00638000
         ORG   MFS+81                                                   00639000
         DS    CL1                                                      00640000
MDS      DS    CL86                                                     00641000
         ORG   MDS                                                      00642000
MDSL     DC    AL2(86)                                                  00643000
@NM00092 DC    X'0000'                                                  00644000
MDST     DS    CL82                                                     00645000
         ORG   MDST                                                     00646000
MDST0    DC    CL1' '                                                   00647000
MDST1    DS    CL7                                                      00648000
         ORG   MDST1                                                    00649000
MDST10   DC    CL6'000000'                                              00650000
MDST11   DC    CL1'.'                                                   00651000
         ORG   MDST+8                                                   00652000
MDST2    DC    CL8' LENGTH('                                            00653000
MDST3    DC    X'40202020202020202120'                                  00654000
MDST4    DC    CL1')'                                                   00655000
MDST5    DC    CL3'  ('                                                 00656000
MDST6    DC    X'40202020202020202120'                                  00657000
MDST7    DC    CL6' ITEMS'                                              00658000
MDST8    DC    CL1','                                                   00659000
MDST9    DS    CL35                                                     00660000
         ORG   MDST9                                                    00661000
MDST90   DC    CL18' ALL ITEMS CONTAIN'                                 00662000
MDST91   DC    CL16' '                                                  00663000
MDST92   DC    CL1')'                                                   00664000
         ORG   MDS+86                                                   00665000
SAME     DC    CL35'SAME AS ABOVE)'                                     00666000
@DATD    DSECT                                                          00667000
         SPACE 2                                                        00668000
*********************************************************************** 00669000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00670000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00671000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00672000
*********************************************************************** 00673000
         SPACE                                                          00674000
BLST05   CSECT                                                          00675000
         ORG                                                            00676000
         DS    0D                                                       00677000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLST05+19)/20+7)/8)CL8'BLST05'         00678000
@DATD    DSECT                                                          00679000
         DS    0H                                                       00680000
@DATD    DSECT                                                          00681000
         SPACE 2                                                        00682000
*********************************************************************** 00683000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00684000
*********************************************************************** 00685000
         SPACE                                                          00686000
         DS    0D                                                       00687000
@DATD    DSECT                                                          00688000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00689000
@ENDDATD EQU   *                                                        00690000
BLST05   CSECT                                                          00691000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00692000
@01      EQU   01                                                       00693000
@02      EQU   02                                                       00694000
@03      EQU   03                                                       00695000
@04      EQU   04                                                       00696000
@05      EQU   05                                                       00697000
@06      EQU   06                                                       00698000
@07      EQU   07                                                       00699000
@08      EQU   08                                                       00700000
@09      EQU   09                                                       00701000
@10      EQU   10                                                       00702000
@11      EQU   11                                                       00703000
@12      EQU   12                                                       00704000
@13      EQU   13                                                       00705000
@14      EQU   14                                                       00706000
@15      EQU   15                                                       00707000
U0000001 EQU   @02                                                      00708000
DATAPTR  EQU   @03                                                      00709000
RETC     EQU   @04                                                      00710000
LINEADDR EQU   @02                                                      00711000
R9       EQU   @09                                                      00712000
R0       EQU   @00                                                      00713000
R1       EQU   @01                                                      00714000
R2       EQU   @02                                                      00715000
R3       EQU   @03                                                      00716000
R4       EQU   @04                                                      00717000
R5       EQU   @05                                                      00718000
RB       EQU   @11                                                      00719000
RD       EQU   @13                                                      00720000
RE       EQU   @14                                                      00721000
RF       EQU   @15                                                      00722000
RA       EQU   @10                                                      00723000
RC       EQU   @12                                                      00724000
R6       EQU   @06                                                      00725000
R7       EQU   @07                                                      00726000
R8       EQU   @08                                                      00727000
ZZ1      EQU   0                                                        00728000
ZZ1ATTN  EQU   ZZ1+360                                                  00729000
ZZ1EVE   EQU   ZZ1ATTN+4                                                00730000
ZZ1EVEP  EQU   ZZ1EVE                                                   00731000
ZZ1F     EQU   ZZ1+368                                                  00732000
ZZ1TRHEX EQU   ZZ1+568                                                  00733000
ZZ1N     EQU   ZZ1+1116                                                 00734000
ZZ2      EQU   0                                                        00735000
ZZ2AMD   EQU   ZZ2                                                      00736000
@NM00025 EQU   ZZ2AMD+7                                                 00737000
ZZ2PRT   EQU   ZZ2+138                                                  00738000
ZZ2PRTT  EQU   ZZ2PRT+4                                                 00739000
ZZ2PRTT1 EQU   ZZ2PRTT+1                                                00740000
ZZ2A     EQU   ZZ2+272                                                  00741000
ZZ2AF    EQU   ZZ2A+16                                                  00742000
ZZ2APID  EQU   ZZ2A+64                                                  00743000
ZZ2AD    EQU   ZZ2A+74                                                  00744000
ZZ2ADD   EQU   ZZ2AD                                                    00745000
ZZ2ADDT  EQU   ZZ2ADD+2                                                 00746000
ZZ2ADM   EQU   ZZ2AD+46                                                 00747000
ZZ2ADMT  EQU   ZZ2ADM+2                                                 00748000
ZZ2ADP   EQU   ZZ2AD+56                                                 00749000
ZZ2ADPT  EQU   ZZ2ADP+2                                                 00750000
ZZ2AZZ6P EQU   ZZ2A+140                                                 00751000
ZZ2AQAS  EQU   ZZ2A+144                                                 00752000
ZZ2AQD   EQU   ZZ2A+160                                                 00753000
ZZ2AQDT  EQU   ZZ2AQD+10                                                00754000
ZZ2AQDF  EQU   ZZ2AQD+52                                                00755000
ZZ2STG   EQU   ZZ2+960                                                  00756000
ZZ2ALLOP EQU   ZZ2+992                                                  00757000
ZZ2FREEP EQU   ZZ2+996                                                  00758000
ZZ2FF19P EQU   ZZ2+1000                                                 00759000
ZZ2FRE1P EQU   ZZ2+1004                                                 00760000
ZZ2FF18P EQU   ZZ2+1008                                                 00761000
ZZ2DYNAP EQU   ZZ2+1012                                                 00762000
ZZ2ZZ2CP EQU   ZZ2+1016                                                 00763000
ZZ2ZZ2DP EQU   ZZ2+1020                                                 00764000
ZZ2STAIP EQU   ZZ2+1024                                                 00765000
ZZ2FF02P EQU   ZZ2+1028                                                 00766000
ZZ2GETLP EQU   ZZ2+1032                                                 00767000
ZZ2PARSP EQU   ZZ2+1036                                                 00768000
ZZ2PTGTP EQU   ZZ2+1040                                                 00769000
ZZ2PUTLP EQU   ZZ2+1044                                                 00770000
ZZ2SCANP EQU   ZZ2+1048                                                 00771000
ZZ2STCKP EQU   ZZ2+1052                                                 00772000
ZZ2TRMOP EQU   ZZ2+1064                                                 00773000
ZZ2TRMVP EQU   ZZ2+1068                                                 00774000
ZZ2PUTNP EQU   ZZ2+1084                                                 00775000
ZZ2TRMNP EQU   ZZ2+1088                                                 00776000
ZZ2ZZ1P  EQU   ZZ2+1264                                                 00777000
ZZ2BVTP  EQU   ZZ2+1280                                                 00778000
ZZ2RVTP  EQU   ZZ2+1284                                                 00779000
ZZ2CPPL  EQU   ZZ2+1292                                                 00780000
ZZ2CPPLC EQU   ZZ2CPPL                                                  00781000
ZZ2ITR   EQU   ZZ2+2840                                                 00782000
ZZ2ITRE  EQU   ZZ2ITR+16                                                00783000
ZZ2ITSE  EQU   ZZ2+2864                                                 00784000
ZZ2ES    EQU   ZZ2+2872                                                 00785000
ZZ2AMDX  EQU   ZZ2+7160                                                 00786000
ZZ2AXO   EQU   ZZ2+7934                                                 00787000
ZZ2AXOT  EQU   ZZ2AXO+2                                                 00788000
CMD      EQU   0                                                        00789000
CMDT     EQU   CMD+4                                                    00790000
PSCB     EQU   0                                                        00791000
PSCBATR1 EQU   PSCB+16                                                  00792000
ECT      EQU   0                                                        00793000
ECTSWS   EQU   ECT+28                                                   00794000
ECTSWS2  EQU   ECT+40                                                   00795000
ECTSWS21 EQU   ECTSWS2                                                  00796000
UPT      EQU   0                                                        00797000
UPTSWS   EQU   UPT+12                                                   00798000
SA       EQU   0                                                        00799000
SA1      EQU   SA                                                       00800000
SAR      EQU   SA+12                                                    00801000
SAR1     EQU   SAR+12                                                   00802000
BLSUMPK1 EQU   0                                                        00803000
BLSUPUTA EQU   0                                                        00804000
BVT      EQU   0                                                        00805000
BVTPUTLP EQU   BVT+4                                                    00806000
BVTPUTOP EQU   BVT+12                                                   00807000
BVTPUTTP EQU   BVT+16                                                   00808000
BVTPUTVP EQU   BVT+20                                                   00809000
BVTPUTAP EQU   BVT+24                                                   00810000
BVTPRTTP EQU   BVT+28                                                   00811000
BVTPRTAP EQU   BVT+32                                                   00812000
BVTPUTDP EQU   BVT+36                                                   00813000
BVTMONP  EQU   BVT+40                                                   00814000
BVTMON2P EQU   BVT+44                                                   00815000
BVTVSARP EQU   BVT+48                                                   00816000
BVTVSENP EQU   BVT+64                                                   00817000
BVTVSERP EQU   BVT+68                                                   00818000
BVTVSGEP EQU   BVT+72                                                   00819000
BVTVSGUP EQU   BVT+76                                                   00820000
BVTVSPOP EQU   BVT+80                                                   00821000
BVTVSPUP EQU   BVT+84                                                   00822000
BVTMPKNP EQU   BVT+104                                                  00823000
BVTMONLP EQU   BVT+108                                                  00824000
BVTPUTCP EQU   BVT+132                                                  00825000
BVTMPK1P EQU   BVT+136                                                  00826000
BVTZZ2RP EQU   BVT+140                                                  00827000
BVTPGMRP EQU   BVT+144                                                  00828000
BVTMONAP EQU   BVT+148                                                  00829000
BVTBLDDP EQU   BVT+152                                                  00830000
BVTBLDLP EQU   BVT+156                                                  00831000
BVTPGMCP EQU   BVT+160                                                  00832000
BVTPGMDP EQU   BVT+164                                                  00833000
BVTPGMLP EQU   BVT+168                                                  00834000
BVTMONCP EQU   BVT+180                                                  00835000
BVTMONDP EQU   BVT+184                                                  00836000
BVTMONTP EQU   BVT+188                                                  00837000
BVTPARIP EQU   BVT+192                                                  00838000
BVTPARUP EQU   BVT+196                                                  00839000
BVTPRTNP EQU   BVT+204                                                  00840000
BVTVSCRP EQU   BVT+208                                                  00841000
BVTVSMRP EQU   BVT+212                                                  00842000
BVTMONXP EQU   BVT+216                                                  00843000
BVTTRMAP EQU   BVT+228                                                  00844000
ZZ6      EQU   0                                                        00845000
ZZ6D     EQU   ZZ6+128                                                  00846000
ZZ6DD    EQU   ZZ6D+8                                                   00847000
ZZ6DDT   EQU   ZZ6DD+4                                                  00848000
ZZ6DQA   EQU   ZZ6D+68                                                  00849000
ZZ6DF    EQU   ZZ6D+92                                                  00850000
ZZ6B     EQU   ZZ6+768                                                  00851000
RVT      EQU   0                                                        00852000
RVTADDRP EQU   RVT                                                      00853000
RVTT01P  EQU   RVT+4                                                    00854000
RVTTAP   EQU   RVT+8                                                    00855000
RVTTBP   EQU   RVT+12                                                   00856000
RVTTCP   EQU   RVT+16                                                   00857000
RVTTFP   EQU   RVT+24                                                   00858000
RVTTYP   EQU   RVT+40                                                   00859000
RVTT02P  EQU   RVT+48                                                   00860000
RVTT03P  EQU   RVT+52                                                   00861000
RVTT04P  EQU   RVT+56                                                   00862000
RVTACCLP EQU   RVT+60                                                   00863000
RVTRACCP EQU   RVT+64                                                   00864000
RVTTLP   EQU   RVT+68                                                   00865000
RVTTMP   EQU   RVT+72                                                   00866000
RVTTUP   EQU   RVT+80                                                   00867000
RVTESGEP EQU   RVT+84                                                   00868000
RVTESGUP EQU   RVT+88                                                   00869000
RVTESARP EQU   RVT+92                                                   00870000
RVTRAARP EQU   RVT+96                                                   00871000
RVTRAGEP EQU   RVT+100                                                  00872000
RVTADDPP EQU   RVT+104                                                  00873000
RVTACCQP EQU   RVT+108                                                  00874000
RVTSAGUP EQU   RVT+124                                                  00875000
RVTSAGEP EQU   RVT+128                                                  00876000
RVTESCKP EQU   RVT+132                                                  00877000
RVTMSGAP EQU   RVT+136                                                  00878000
RVTMSGDP EQU   RVT+140                                                  00879000
RVTADDTP EQU   RVT+160                                                  00880000
RVTADDUP EQU   RVT+164                                                  00881000
RVTADD1P EQU   RVT+176                                                  00882000
RVTADD2P EQU   RVT+180                                                  00883000
RVTRSAGP EQU   RVT+184                                                  00884000
RVTMSGBP EQU   RVT+188                                                  00885000
RVTADDSP EQU   RVT+192                                                  00886000
RVTADD3P EQU   RVT+196                                                  00887000
RVTPADSP EQU   RVT+204                                                  00888000
RVTTRP   EQU   RVT+228                                                  00889000
RVTADD4P EQU   RVT+232                                                  00890000
RVTSAPCP EQU   RVT+236                                                  00891000
RVTSAARP EQU   RVT+240                                                  00892000
RVTSAGNP EQU   RVT+244                                                  00893000
RVTT06P  EQU   RVT+248                                                  00894000
RVTSAGCP EQU   RVT+252                                                  00895000
RVTSAGQP EQU   RVT+256                                                  00896000
RVTESGCP EQU   RVT+260                                                  00897000
RVTESGQP EQU   RVT+264                                                  00898000
RVTDUCKP EQU   RVT+276                                                  00899000
RVTDUCCP EQU   RVT+280                                                  00900000
FMTX     EQU   0                                                        00901000
CKX      EQU   0                                                        00902000
DATA     EQU   0                                                        00903000
BLSRACC  EQU   0                                                        00904000
BLSRACCL EQU   0                                                        00905000
BLSRACCQ EQU   0                                                        00906000
BLSRADDP EQU   0                                                        00907000
BLSRADDR EQU   0                                                        00908000
BLSRADDS EQU   0                                                        00909000
BLSRADDT EQU   0                                                        00910000
BLSRADDU EQU   0                                                        00911000
BLSRADD1 EQU   0                                                        00912000
BLSRADD2 EQU   0                                                        00913000
BLSRADD3 EQU   0                                                        00914000
BLSRADD4 EQU   0                                                        00915000
BLSRDUCC EQU   0                                                        00916000
BLSRDUCK EQU   0                                                        00917000
BLSRESAR EQU   0                                                        00918000
BLSRESCK EQU   0                                                        00919000
BLSRESGC EQU   0                                                        00920000
BLSRESGE EQU   0                                                        00921000
BLSRESGQ EQU   0                                                        00922000
BLSRESGU EQU   0                                                        00923000
BLSRMSGA EQU   0                                                        00924000
BLSRMSGB EQU   0                                                        00925000
BLSRMSGD EQU   0                                                        00926000
BLSRPADS EQU   0                                                        00927000
BLSRRAAR EQU   0                                                        00928000
BLSRRAGE EQU   0                                                        00929000
BLSRSAAR EQU   0                                                        00930000
BLSRSAG  EQU   0                                                        00931000
BLSRSAGC EQU   0                                                        00932000
BLSRSAGE EQU   0                                                        00933000
BLSRSAGN EQU   0                                                        00934000
BLSRSAGQ EQU   0                                                        00935000
BLSRSAGU EQU   0                                                        00936000
BLSRSAPC EQU   0                                                        00937000
BLSTA    EQU   0                                                        00938000
BLSTB    EQU   0                                                        00939000
BLSTC    EQU   0                                                        00940000
BLSTF    EQU   0                                                        00941000
BLSTL    EQU   0                                                        00942000
BLSTM    EQU   0                                                        00943000
BLSTR    EQU   0                                                        00944000
BLSTU    EQU   0                                                        00945000
BLSTY    EQU   0                                                        00946000
BLST01   EQU   0                                                        00947000
BLST02   EQU   0                                                        00948000
BLST03   EQU   0                                                        00949000
BLST04   EQU   0                                                        00950000
BLST06   EQU   0                                                        00951000
BLSUALLO EQU   0                                                        00952000
BLSUBLDD EQU   0                                                        00953000
BLSUBLDL EQU   0                                                        00954000
BLSUDYNA EQU   0                                                        00955000
BLSUFREE EQU   0                                                        00956000
BLSUFRE1 EQU   0                                                        00957000
BLSUMON  EQU   0                                                        00958000
BLSUMONA EQU   0                                                        00959000
BLSUMONC EQU   0                                                        00960000
BLSUMOND EQU   0                                                        00961000
BLSUMONL EQU   0                                                        00962000
BLSUMONT EQU   0                                                        00963000
BLSUMONX EQU   0                                                        00964000
BLSUMON2 EQU   0                                                        00965000
BLSUMPKN EQU   0                                                        00966000
BLSUPARI EQU   0                                                        00967000
BLSUPARU EQU   0                                                        00968000
BLSUPGMC EQU   0                                                        00969000
BLSUPGMD EQU   0                                                        00970000
BLSUPGML EQU   0                                                        00971000
BLSUPGMR EQU   0                                                        00972000
BLSUPRTA EQU   0                                                        00973000
BLSUPRTN EQU   0                                                        00974000
BLSUPRTT EQU   0                                                        00975000
BLSUPUTC EQU   0                                                        00976000
BLSUPUTD EQU   0                                                        00977000
BLSUPUTL EQU   0                                                        00978000
BLSUPUTN EQU   0                                                        00979000
BLSUPUTO EQU   0                                                        00980000
BLSUPUTT EQU   0                                                        00981000
BLSUPUTV EQU   0                                                        00982000
BLSUSTAI EQU   0                                                        00983000
BLSUTRMA EQU   0                                                        00984000
BLSUTRMN EQU   0                                                        00985000
BLSUTRMO EQU   0                                                        00986000
BLSUTRMV EQU   0                                                        00987000
BLSUVSAR EQU   0                                                        00988000
BLSUVSCR EQU   0                                                        00989000
BLSUVSEN EQU   0                                                        00990000
BLSUVSER EQU   0                                                        00991000
BLSUVSGE EQU   0                                                        00992000
BLSUVSGU EQU   0                                                        00993000
BLSUVSMR EQU   0                                                        00994000
BLSUVSPO EQU   0                                                        00995000
BLSUVSPU EQU   0                                                        00996000
BLSUZZ2C EQU   0                                                        00997000
BLSUZZ2D EQU   0                                                        00998000
BLSUZZ2R EQU   0                                                        00999000
IKJEFF02 EQU   0                                                        01000000
IKJEFF18 EQU   0                                                        01001000
IKJEFF19 EQU   0                                                        01002000
IKJGETL  EQU   0                                                        01003000
IKJPARS  EQU   0                                                        01004000
IKJPTGT  EQU   0                                                        01005000
IKJPUTL  EQU   0                                                        01006000
IKJSCAN  EQU   0                                                        01007000
IKJSTCK  EQU   0                                                        01008000
I001C    EQU   0                                                        01009000
I008P    EQU   0                                                        01010000
I015F    EQU   0                                                        01011000
I015P    EQU   0                                                        01012000
I031F    EQU   0                                                        01013000
I031P    EQU   0                                                        01014000
I256C    EQU   0                                                        01015000
PZ2      EQU   0                                                        01016000
ESPA     EQU   0                                                        01017000
ESPAAS   EQU   ESPA+60                                                  01018000
ESPALAD  EQU   ESPA+76                                                  01019000
ESPAD    EQU   ESPA+80                                                  01020000
ESPADOF  EQU   ESPAD                                                    01021000
ESPADLE  EQU   ESPAD+4                                                  01022000
ESPADT   EQU   ESPAD+10                                                 01023000
ESPADIM  EQU   ESPAD+44                                                 01024000
ESPADF   EQU   ESPAD+52                                                 01025000
ESPAF    EQU   ESPA+161                                                 01026000
ESPAFS   EQU   ESPAF                                                    01027000
ESPAFC   EQU   ESPAF+1                                                  01028000
ESPAR    EQU   ESPA+180                                                 01029000
ESPART   EQU   ESPAR+2                                                  01030000
BLK      EQU   0                                                        01031000
PERLINE  EQU   0                                                        01032000
MASK1    EQU   0                                                        01033000
MASK2    EQU   0                                                        01034000
FMTPTR   EQU   0                                                        01035000
CKPTR    EQU   0                                                        01036000
CPPL     EQU   ZZ2CPPL                                                  01037000
CPPLUPT  EQU   CPPL+4                                                   01038000
CPPLPSCB EQU   CPPL+8                                                   01039000
CPPLECT  EQU   CPPL+12                                                  01040000
PTRPTR   EQU   PTRBIT                                                   01041000
@RC00169 EQU   @RC00167                                                 01500000
@ENDDATA EQU   *                                                        01501000
         END   BLST05                                           DSKC454 01502000
