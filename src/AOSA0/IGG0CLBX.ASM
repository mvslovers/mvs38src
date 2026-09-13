         TITLE 'IGG0CLBX - VSAM CMS DEFINE - 4TH MODULE                *00001000
                        '                                               00002000
IGG0CLBX CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSKL013 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'IGG0CLBX  81.030'                              DSKL013 00008000
         DROP  R15                                              DSKL013 00009000
@PROLOG  DS    0H                                                  0002 00010000
         USING @MAINENT,R15                                     DSKL013 00011000
         USING @DATD-(CCATEMPS-IGGCCA),R11                              00012000
         DC    0F'0'                                            DSKL013 00013000
         DC    CL8'IGGPDSPC'                                    DSKL013 00014000
         BR    R14                                              DSKL013 00016000
IGGPDSPC DS    0H                                                  0168 00017000
         ENTRY IGGPDSPC                                                 00018000
         DROP  R15                                              DSKL013 00019000
         STM   R12,R14,12(R13)                                  DSKL013 00022000
         LA    R13,12(R13)                                      DSKL013 00023000
         BALR  R12,0                                            DSKL013 00024000
IGGSEGST DS    0H                                               DSKL013 00025000
         USING *,R12                                            DSKL013 00026000
*                                                                  0177 00027000
*/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  */ 00028000
*/*                                                                  */ 00029000
*/* IGGPDSPC - VSAM CMS DEFINE - 4TH SEGMENT AND MODULE OF DEFINE    */ 00030000
*/*                                                                  */ 00031000
*/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  */ 00032000
*                                                                  0177 00033000
*   /*****************************************************************/ 00034000
*   /*                                                               */ 00035000
*   /* REGULAR CLUSTER SIZE PARAMETER CALCULATIONS                   */ 00036000
*   /*                                                               */ 00037000
*   /*****************************************************************/ 00038000
*                                                                  0177 00039000
*   DCWABASE=ADDR(CMSDSPTB(1));     /* SET ADDRESS OF DATA ELEMENT OF   00040000
*                                      DEVICE CHARACTERISTICS AND  0177 00041000
*                                      WORK VALUES ARRAY             */ 00042000
         L     R4,CCACMSWA(,R11)                                DSKL013 00043000
         LA    R4,CMSDSPTB(,R4)                                 DSKL013 00044000
*   CTGFVTBS=CTGFVDCH;              /* SET BASE ADDRESS OF DATA FVT  */ 00045000
         L     R5,CCACPL(,R11)                                  DSKL013 00046000
         L     R10,CTGFVT(,R5)                                  DSKL013 00047000
         L     R5,CTGFVDCH(,R10)                                DSKL013 00048000
         LR    R3,R5                                            DSKL013 00049000
*   CCAFLPT=CTGFVDCH->CTGFVATR;     /* PNT TO ATTRIBUTES       Y02020*/ 00050000
*                                                                  0179 00051000
         MVC   CCAFLPT(4,R11),CTGFVATR(R5)                      DSKL013 00052000
*   /*****************************************************************/ 00053000
*   /*                                                               */ 00054000
*   /* CALL DEVICE CHARACTERISTICS ESTABLISHMENT SEGMENT FOR DATA    */ 00055000
*   /* ELEMENT                                               @Y30SSSG*/ 00056000
*   /*                                                               */ 00057000
*   /*****************************************************************/ 00058000
*                                                                  0180 00059000
*Z004DDCE:                                                         0180 00060000
*   CALL IGGPDDCE;                  /* GET DEV CHAR OF DATA  @Y30SSSG*/ 00061000
         BAL   R14,IGGPDDCE                                     DSKL013 00062000
*   IF CCACD1=RCS THEN              /* RETURN CODE ZERO      @Y30SSSG*/ 00063000
         CLI   CCACD1(R11),0                                       0181 00064000
         BNE   @RF00181                                            0181 00065000
*     IF CTGFVICH^=N THEN           /* INDEXED CLUSTER               */ 00066000
         L     R10,CCACPL(,R11)                                 DSKL013 00067000
         L     R5,CTGFVT(,R10)                                  DSKL013 00068000
         L     R10,CTGFVICH(,R5)                                DSKL013 00069000
         LTR   R10,R10                                          DSKL013 00070000
         BZ    @RF00182                                            0182 00071000
*       DO;                         /* YES                   @Y30SSSG*/ 00072000
*         DCWABASE=ADDR(CMSDSPTB(2));/* SET ADDRESS OF INDEX ELEMENT    00073000
*                                      OF DEVICE CHARACTERISTICS WORK   00074000
*                                      VALUES ARRAY                  */ 00075000
         L     R4,CCACMSWA(,R11)                                DSKL013 00076000
         LA    R4,CMSDSPTB+32(,R4)                              DSKL013 00077000
*         CTGFVTBS=CTGFVICH;        /* SET BASE ADDRESS OF INDEX FVT */ 00078000
*                                                                  0185 00079000
         LR    R3,R10                                           DSKL013 00080000
*         /***********************************************************/ 00081000
*         /*                                                         */ 00082000
*         /* CALL DEVICE CHARACTERISTICS ESTABLISHMENT SEGMENT OF    */ 00083000
*         /* INDEX                                           @Y30SSSG*/ 00084000
*         /*                                                         */ 00085000
*         /***********************************************************/ 00086000
*                                                                  0186 00087000
*Z005DDCE:                                                         0186 00088000
*         CALL IGGPDDCE;            /* GET INDEX DEV CHAR    @Y30SSSG*/ 00089000
         BAL   R14,IGGPDDCE                                     DSKL013 00090000
*       END;                                                       0187 00091000
*     ELSE                                                         0188 00092000
*       ;                                                          0188 00093000
@RF00182 DS    0H                                                  0189 00094000
*   ELSE                                                           0189 00095000
*     ;                                                            0189 00096000
*                                                                  0189 00097000
@RF00181 DS    0H                                                  0190 00098000
*   /*****************************************************************/ 00099000
*   /*                                                               */ 00100000
*   /* IF RETURN CODE ZERO CALL CONSISTANCY CHECK            @Y30SSSG*/ 00101000
*   /* OF INPUT PARMS                                        @Y30SSSG*/ 00102000
*   /*                                                               */ 00103000
*   /*****************************************************************/ 00104000
*                                                                  0190 00105000
*   IF CCACD1=RCS THEN              /* RC=0                  @Y30SSSG*/ 00106000
         CLI   CCACD1(R11),0                                       0190 00107000
         BNE   @RF00190                                            0190 00108000
*Z006DCCC:                                                         0191 00109000
*     CALL IGGPDCCC;                /* CHECK INPUT PARMS     @Y30SSSG*/ 00110000
         BAL   R14,IGGPDCCC                                     DSKL013 00111000
*   ELSE                                                           0192 00112000
*     ;                                                            0192 00113000
*                                                                  0192 00114000
@RF00190 DS    0H                                                  0193 00115000
*   /*****************************************************************/ 00116000
*   /*                                                               */ 00117000
*   /* IF RC=0 CALCULATE CHAR OF DATA AND INDEX OBJECTS      @Y30SSSG*/ 00118000
*   /*                                                               */ 00119000
*   /*****************************************************************/ 00120000
*                                                                  0193 00121000
*   IF CCACD1=RCS THEN              /* RC=0                  @Y30SSSG*/ 00122000
*                                                                  0193 00123000
         CLI   CCACD1(R11),0                                       0193 00124000
         BNE   @RF00193                                            0193 00125000
*     /***************************************************************/ 00126000
*     /*                                                             */ 00127000
*     /* CALL TO MODULE IGG0CLB0                                     */ 00128000
*     /*                                                             */ 00129000
*     /***************************************************************/ 00130000
*                                                                  0194 00131000
*Z007DCCO:                                                         0194 00132000
*     CALL IGGPDCCO;                /* CALC CHAR OF OBJECTS  @Y30SSSG*/ 00133000
         L     R15,@CV00037                                     DSKL013 00134000
         BALR  R14,R15                                          DSKL013 00135000
*   ELSE                                                           0195 00136000
*     ;                             /*                       @Y30SSSG*/ 00137000
*                                                                  0195 00138000
@RF00193 DS    0H                                                  0196 00139000
*   /*****************************************************************/ 00140000
*   /*                                                               */ 00141000
*   /* END OF IGGPDSPC                                               */ 00142000
*   /*                                                               */ 00143000
*   /*****************************************************************/ 00144000
*                                                                  0196 00145000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 00146000
         BAL   R14,EXIT                                         DSKL013 00147000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 00148000
         DC    X'95E4'                       !!! SOURCE COMPARE FIX !!! 00149000
         DC    0F'0'                                            DSKL013 00149000
*   GEN(DC CL8'IGGPDDCE');          /* NAME OF FOLLOWING PROCEDURE   */ 00150000
         DC    CL8'IGGPDDCE'                                    DSKL013 00151000
*   END;                            /* END OF INNER PROCEDURE        */ 00152000
         BR    R14                                              DSKL013 00155000
*                                                                  0201 00159000
*/********************************************************************/ 00160000
*/*                                                                  */ 00161000
*/*        IGGPDDCE  -  PROCEDURE  INTERNALLY  CALLED  NESTED        */ 00162000
*/*                                                                  */ 00163000
*/********************************************************************/ 00164000
*                                                                  0201 00165000
*IGGPDDCE:                                                         0201 00166000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 00167000
IGGPDDCE DS    0H                                                  0202 00169000
*Z008:                              /* LABEL FOR PROCEDURE TRACKING  */ 00170000
*Z008DDCE:                          /* LABEL FOR PROCEDURE TRACKING  */ 00171000
*   RFY                                                            0202 00172000
*    (R5,                                                          0202 00173000
*     R6,                                                          0202 00174000
*     R7,                                                          0202 00175000
*     R8,                                                          0202 00176000
*     R9,                                                          0202 00177000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 00178000
*   RFY                                                            0203 00181000
*    (R2,                                                          0203 00182000
*     R3,                                                          0203 00183000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 00184000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 00185000
         STM   R12,R14,12(R13)                                  DSKL013 00186000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 00187000
*                                                                  0205 00188000
         LA    R13,12(R13)                                      DSKL013 00189000
*   /*****************************************************************/ 00190000
*   /*                                                               */ 00191000
*   /* DEVICE CHARACTERISTICS ESTABLISHMENT SEGMENT                  */ 00192000
*   /*                                                               */ 00193000
*   /*****************************************************************/ 00194000
*                                                                  0206 00195000
*   IF CTGFVTBS->CTGFVIND^=N&(CTGFVTBS->CTGFVATR->CTGFLPT(1)->CTGDSUNQ= 00196000
*       DSUNQ×(CTGTYPE=CTGTMCAT×CTGTYPE=CTGTUCAT)) THEN/* STATEMENT     00197000
*                                      NAME EXIST            @Y30SSSG   00198000
*                                      AND UNIQUE OR MASTER  @Y30SSSG   00199000
*                                      OR USER CAT DEFINE    @Y30SSSG*/ 00200000
         ICM   R5,15,CTGFVIND(R3)                               DSKL013 00201000
         BZ    @RF00206                                            0206 00202000
         L     R10,CTGFVATR(,R3)                                DSKL013 00203000
         L     R5,CTGFLPT(,R10)                                 DSKL013 00204000
         TM    CTGDSUNQ(R5),B'01000000'                         DSKL013 00205000
         BO    @RT00206                                            0206 00206000
         L     R10,CCACPL(,R11)                                 DSKL013 00207000
         CLI   CTGTYPE(R10),C'M'                                DSKL013 00208000
         BE    @RT00206                                            0206 00209000
         CLI   CTGTYPE(R10),C'U'                                DSKL013 00210000
         BNE   @RF00206                                            0206 00211000
@RT00206 DS    0H                                                  0207 00212000
*     DO;                           /* YES                   @Y30SSSG*/ 00213000
*       RFY                                                        0208 00214000
*         DEVCHARS BASED(ADDR(DSDEVCHA));/* ESTABLISH ADDRESSABILITY    00215000
*                                      FOR DEVICE CHARACTERISTICS  0208 00216000
*                                      MAPPING STRUCTURE USE DNAME 0208 00217000
*                                      AND DEVTYPE MACRO TO GET    0208 00218000
*                                      DEVICE CHARACTERISTICS      0208 00219000
*                                                            @Y30SSSG*/ 00220000
*       DEVTYPEA=ADDR(DEVCHARS);    /* SET ADDRESS OF RETURN AREA FOR   00221000
*                                      DEVICE CHARACTERISTICS        */ 00222000
         LR    R2,R4                                            DSKL013 00223000
*       DDNAMELC=CTGFVTBS->CTGFVIND;/* SET ADDRESS OF DNAME IN FVT   */ 00224000
         L     R3,CTGFVIND(,R3)                                 DSKL013 00225000
*       RFY                                                        0211 00226000
*        (R15) RSTD;                                               0211 00227000
*       GEN REFS(DDNAMELC,DEVTYPEA,CCALBCYL)                       0212 00228000
*           (DEVTYPE (DDNAMELC),(DEVTYPEA),DEVTAB);/*          Y02020*/ 00229000
         DEVTYPE (R3),(R2),DEVTAB                               DSKL013 00230000
*       IF R15^=N THEN              /* NOT SUCCESSFUL ?      @Y30SSSG*/ 00231000
*                                                                  0213 00232000
         LTR   R15,R15                                             0213 00233000
         BZ    @RF00213                                            0213 00234000
*         /***********************************************************/ 00235000
*         /*                                                         */ 00236000
*         /* SET CCAMODID='BX', CCAREASN=RSN4, CCARETRN=RCINDER      */ 00237000
*         /*                                                         */ 00238000
*         /***********************************************************/ 00239000
*                                                                  0214 00240000
*         CCAPROB=IGGSEGID+(RSN4*K256)+RCINDER;/* MISSING 'IN' DD  0214 00241000
*                                                            @Y30SSSG   00242000
*                                      CARD IN JCL OR        @Y30SSSG   00243000
*                                      INVALID NAME          @Y30SSSG   00244000
*                                      ADDRESS               @Y30SSSG*/ 00245000
         MVC   CCAPROB(4,R11),@CF03472                             0214 00246000
*       ELSE                                                       0215 00247000
*         ;                                                        0215 00248000
@RF00213 DS    0H                                                  0216 00249000
*       RFY                                                        0216 00250000
*        (R15) UNRSTD;                                             0216 00251000
*     END;                                                         0217 00252000
*   ELSE                            /* JCL STATEMENT NAME    @Y30SSSG   00253000
*                                      MISSING               @Y30SSSG*/ 00254000
*     DO;                                                          0218 00255000
         B     @RC00206                                            0218 00256000
@RF00206 DS    0H                                                  0219 00257000
*       CCASRCH=CCASRCH&&CCASRCH;   /* CLEAR SRCH ARG FLD            */ 00258000
         XC    CCASRCH(44,R11),CCASRCH(R11)                        0219 00259000
*       CCASRCH(1:6)=CTGFVTBS->CTGFVVLT->LTVOLSER(1);/* GET VOLUME 0220 00260000
*                                      SERIAL NUMBER FOR GET OF    0220 00261000
*                                      VOLUME ENTRY                  */ 00262000
         L     R5,CTGFVVLT(,R3)                                 DSKL013 00263000
         MVC   CCASRCH(6,R11),LTVOLSER(R5)                      DSKL013 00264000
*       DO;                                                        0221 00265000
*         CCAF1KEY=ON;              /* TRUE NAME GET                 */ 00266000
*         CCAF1KGE=OFF;             /* NOT GET NEXT                  */ 00267000
*         CCAF1UP=OFF;              /* NOT GET UPD                   */ 00268000
         OI    CCAF1KEY(R11),B'00010000'                           0224 00269000
         NI    CCAF1KGE(R11),B'11110101'                           0224 00270000
*         CCAURAB=ADDR(CCARAB1);    /* SET RAB PTR                   */ 00271000
*                                                                  0225 00272000
         LA    R10,CCARAB1(,R11)                                DSKL013 00273000
         ST    R10,CCAURAB(,R11)                                DSKL013 00274000
*         /***********************************************************/ 00275000
*         /*                                                         */ 00276000
*         /* CALL TO MODULE IGG0CLBI                                 */ 00277000
*         /*                                                         */ 00278000
*         /***********************************************************/ 00279000
*                                                                  0226 00280000
*Z011GET:                                                          0226 00281000
*         CALL IGGPGET;             /* GET RECORD                    */ 00282000
         L     R15,@CV00036                                     DSKL013 00283000
         BALR  R14,R15                                          DSKL013 00284000
*       END;                                                       0227 00285000
*       IF CCACD1=RCS THEN          /* VOLUME ENTRY FOUND            */ 00286000
         CLI   CCACD1(R11),0                                       0228 00287000
         BNE   @RF00228                                            0228 00288000
*         DSDEVCHA=CTVDVCHR;        /* MOVE DEVICE CHARACTERISTICS 0229 00289000
*                                      FROM VOLUME ENTRY TO WORKAREA */ 00290000
         L     R5,CCAURAB(,R11)                                 DSKL013 00291000
         L     R10,CCACPE1(,R5)                                 DSKL013 00292000
         MVC   DSDEVCHA(20,R4),CTVDVCHR+48(R10)                 DSKL013 00293000
*       ELSE                                                       0230 00294000
*         IF CCACD1=RCENT THEN      /* IF ENTRY DOES NOT     @Y30SSSG   00295000
*                                      EXIST THEN SET ERR    @Y30SSSG*/ 00296000
*                                                                  0230 00297000
         B     @RC00228                                            0230 00298000
@RF00228 CLI   CCACD1(R11),8                                       0230 00299000
         BNE   @RF00230                                            0230 00300000
*           /*********************************************************/ 00301000
*           /*                                                       */ 00302000
*           /* SET CCAMODID='BX', CCAREASN=RSN0, CCARETRN=RCVOLENT   */ 00303000
*           /*                                                       */ 00304000
*           /*********************************************************/ 00305000
*                                                                  0231 00306000
*           CCAPROB=IGGSEGID+(RSN0*K256)+RCVOLENT;/*         @Y30SSSG*/ 00307000
         MVC   CCAPROB(4,R11),@CF03473                             0231 00308000
*         ELSE                                                     0232 00309000
*           ;                                                      0232 00310000
@RF00230 DS    0H                                                  0233 00311000
*     END;                                                         0233 00312000
@RC00228 DS    0H                                                  0234 00313000
*   IF CCACD1=RCS THEN              /*                        @XM4334*/ 00314000
@RC00206 CLI   CCACD1(R11),0                                       0234 00315000
         BNE   @RF00234                                            0234 00316000
*     DO;                           /*                        @XM4334*/ 00317000
*                                                                  0235 00318000
*       /*************************************************************/ 00319000
*       /*                                                           */ 00320000
*       /* CHECK VALIDITY OF DEVICE CLASS                     @XM4334*/ 00321000
*       /*                                                           */ 00322000
*       /*************************************************************/ 00323000
*                                                                  0236 00324000
*       IF RTCLSTYP(1:1)^=DADEVCLS THEN/* NOT DA DEVICE       @XM4334*/ 00325000
*                                                                  0236 00326000
         CLI   RTCLSTYP(R4),32                                  DSKL013 00327000
         BE    @RF00236                                            0236 00328000
*         /***********************************************************/ 00329000
*         /*                                                         */ 00330000
*         /* SET CCAMODID='BX', CCAREASN=RSN2, CCARETRN=RCINVDTY     */ 00331000
*         /*                                                         */ 00332000
*         /***********************************************************/ 00333000
*                                                                  0237 00334000
*         CCAPROB=IGGSEGID+(RSN2*K256)+RCINVDTY;/* INVALID DEVICE  0237 00335000
*                                                            @Y30SSSG   00336000
*                                      TYPE FROM DDNAME       @XM4334*/ 00337000
         MVC   CCAPROB(4,R11),@CF03475                             0237 00338000
*       ELSE                                                       0238 00339000
*         ;                         /*                        @XM4334*/ 00340000
@RF00236 DS    0H                                                  0239 00341000
*     END;                          /*                        @XM4334*/ 00342000
*   ELSE                                                           0240 00343000
*     ;                             /*                        @XM4334*/ 00344000
@RF00234 DS    0H                                                  0241 00345000
*   IF CCACD1=RCS THEN              /* SUCCESSFUL            @Y30SSSG*/ 00346000
         CLI   CCACD1(R11),0                                       0241 00347000
         BNE   @RF00241                                            0241 00348000
*     DO;                           /* YES                   @Y30SSSG*/ 00349000
*       RTDEVUCB(2)=RTDEVUCB(2)&'DC'X;/* CLEAR SYSTEM BITS   @XM01568*/ 00350000
         MVC   @TS00001(1),RTDEVUCB+1(R4)                       DSKL013 00351000
         NI    @TS00001,X'DC'                                      0243 00352000
         MVC   RTDEVUCB+1(1,R4),@TS00001                        DSKL013 00353000
*       IF RTCLSTYP=D3340 THEN      /* CHECK FOR 3340 DEV    @YM07013*/ 00354000
         CLC   RTCLSTYP(2,R4),@CB03341 =X'200A' 3340            DSKL013 00355000
         BNE   @RF00244                                            0244 00356000
*         RTDEVUCB(2)=RTDEVUCB(2)&'EF'X;/* TURN OFF RPS BIT  @YM07013*/ 00357000
         MVC   @TS00001(1),RTDEVUCB+1(R4)                       DSKL013 00358000
         NI    @TS00001,X'EF'                                      0245 00359000
         MVC   RTDEVUCB+1(1,R4),@TS00001                        DSKL013 00360000
*       ELSE                                                       0246 00361000
*         ;                                                        0246 00362000
*                                                                  0246 00363000
@RF00244 DS    0H                                                  0247 00364000
*       /*************************************************************/ 00365000
*       /*                                                           */ 00366000
*       /* IF SWAPSPACE ON A 2314 DEVICE THEN SET ERROR CODE         */ 00367000
*       /*                                                           */ 00368000
*       /*************************************************************/ 00369000
*                                                                  0247 00370000
*       IF RTDEVUCB=DEV2314T&CTGSWAP=ON THEN/* SWAPSPACE     @Z40WSSG   00371000
*                                      AND 2314 DEVICE       @Z40WSSG*/ 00372000
*                                                                  0247 00373000
         CLC   RTDEVUCB(4,R4),@CB03329 =X'30C02008' 2314        DSKL013 00374000
         BNE   @RF00247                                            0247 00375000
         L     R5,CCACPL(,R11)                                  DSKL013 00376000
         TM    CTGSWAP(R5),B'00100000'                          DSKL013 00377000
         BNO   @RF00247                                            0247 00378000
*         /***********************************************************/ 00379000
*         /*                                                         */ 00380000
*         /* SET CCAMODID='BX', CCAREASN=RSN2, CCARETRN=RCINVDTY     */ 00381000
*         /*                                                         */ 00382000
*         /***********************************************************/ 00383000
*                                                                  0248 00384000
*         CCAPROB=IGGSEGID+(RSN2*K256)+RCINVDTY;/* INVALID DEVICE  0248 00385000
*                                                            @Z40WSSG   00386000
*                                      ELSE; /* NOT SWAPSPACE & 2314    00387000
*                                                            @Z40WSSG*/ 00388000
*                                                                  0248 00389000
         MVC   CCAPROB(4,R11),@CF03475                             0248 00390000
*       /*************************************************************/ 00391000
*       /*                                                           */ 00392000
*       /* SET MAXIMUM PHYSICAL BLOCK SIZE FOR THIS DEVICE TYPE      */ 00393000
*       /*                                                           */ 00394000
*       /*************************************************************/ 00395000
*                                                                  0249 00396000
*       IF RTDEVUCB=DEV2314T&CTGTRKOV=OFF THEN                     0249 00397000
@RF00247 CLC   RTDEVUCB(4,R4),@CB03329 =X'30C02008' 2314        DSKL013 00398000
         BNE   @RF00249                                            0249 00399000
         L     R10,CCAFLPT(,R11)                                DSKL013 00400000
         L     R5,CTGFLPT(,R10)                                 DSKL013 00401000
         TM    CTGTRKOV(R5),B'00000001'                         DSKL013 00402000
         BNZ   @RF00249                                            0249 00403000
*         DO;                                                      0250 00404000
*           DSNPHYBS=DIM(PHYBLKS)-ONE;/* SET NUMBER OF ALLOWABLE   0251 00405000
*                                      PHYSICAL BLOCK SIZES FOR THIS    00406000
*                                      DEVICE TYPE                   */ 00407000
         MVC   DSNPHYBS(2,R4),@CH00421 =H'3'                    DSKL013 00408000
*           DSMPHYBS=MB2314;        /* SET MAXIMUM PHYSICAL BLOCK  0252 00409000
*                                      SIZE FOR 2314 DEVICE TYPE     */ 00410000
         MVC   DSMPHYBS(2,R4),@CH03333 =H'2048'                 DSKL013 00411000
*         END;                                                     0253 00412000
*       ELSE                                                       0254 00413000
*         DO;                                                      0254 00414000
         B     @RC00249                                            0254 00415000
@RF00249 DS    0H                                                  0255 00416000
*           DSNPHYBS=DIM(PHYBLKS);  /* SET NUMBER OF ALLOWABLE     0255 00417000
*                                      PHYSICAL BLOCK SIZES FOR THIS    00418000
*                                      DEVICE TYPE                   */ 00419000
         MVC   DSNPHYBS(2,R4),@CH00062 =H'4'                    DSKL013 00420000
*           DSMPHYBS=MBN2314;       /* SET MAXIMUM PHYSICAL BLOCK  0256 00421000
*                                      SIZE FOR NON-2314 DEVICE TYPE */ 00422000
         MVC   DSMPHYBS(2,R4),@CH03335 =H'4096'                 DSKL013 00423000
*         END;                                                     0257 00424000
*                                                                  0257 00425000
*       /*************************************************************/ 00426000
*       /*                                                           */ 00427000
*       /* CALCULATE THE NUMBER OF PHYSICAL BLOCKS PER TRACK AND THE */ 00428000
*       /* REMAINING AVAILABLE BYTES FOR EACH OF THE PHYSICAL BLOCK  */ 00429000
*       /* SIZES - 512, 1024, 2048, AND 4096 CALCULATE BLOCKS PER    */ 00430000
*       /* TRACK                                                     */ 00431000
*       /*                                                           */ 00432000
*       /*************************************************************/ 00433000
@RC00249 DS    0H                                                  0259 00437000
         L     R1,CCAR1REC(,R11)       TRKCALC PARAMETER ADDR   DSKL013 00450010
         XC    0(12,R1),0(R1)          CLEAR TRKCALC PARAMETERS DSKL013 00450020
         MVC   3(1,R1),3(R4)           DEVICE TYPE FOR TRAKCALC DSKL013 00450030
         MVI   8(R1),X'01'             RECORD=1 FOR TRAKCALC    DSKL013 00450040
         LH    R3,DSNPHYBS(,R4)                                 DSKL013 00450050
         B     @DE00275                                         DSKL013 00451000
@DL00262 DS    0H                                                  0263 00452000
*             /*******************************************************/ 00453000
*             /*                                                     */ 00454000
*             /* CALCULATE BLOCKS PER TRACK                          */ 00455000
*             /*                                                     */ 00456000
*             /*******************************************************/ 00457000
*                                                                  0263 00458000
*             EFFBLKS(PHYBLKI)=PHYBLKS(PHYBLKI);/*             Y02020*/ 00459000
         LR    R8,R3                                            DSKL013 00460000
         ALR   R8,R8                                            DSKL013 00461000
         LH    R8,PHYBLKS-2(R8)                                 DSKL013 00462000
         STH   R8,10(,R1)       DATA LENGTH FOR TRKCALC         DSKL013 00511000
         LR    R5,R11           SAVE R11 OVER TRKCALC           DSKL013 00598010
         MVI   4(R1),X'86'      TRKCALC FUNCTN=TRKCAP           DSKL013 00598020
         L     R15,16           ADDRESS OF CVT                  DSKL013 00598030
         L     R15,232(,R15)    ADDRESS OF SECTOR CONV. RTN     DSKL013 00598040
         BAL   R14,12(,R15)     USE STAR ENTRY ON CALL          DSKL013 00598050
         LR    R11,R5           RESTORE R11                     DSKL013 00598060
         L     R1,CCAR1REC(,R11)                                DSKL013 00598070
         LR    R8,R3                                            DSKL013 00598080
         ALR   R8,R8                                            DSKL013 00598090
         STH   R0,DSPHYBPT-2(R8,R4) TRKCAP FROM TRKCALC         DSKL013 00602000
         BCTR  R3,0                                             DSKL013 00604000
@DE00275 LTR   R3,R3                                            DSKL013 00605000
         BP    @DL00262                                         DSKL013 00606000
@RF00241 DS    0H                                                  0288 00611000
*   RFY                                                            0288 00612000
*    (OVHD) UNRSTD;                 /*                         Y02020*/ 00613000
*                                                                  0288 00614000
*   /*****************************************************************/ 00616000
*   /*                                                               */ 00617000
*   /* END OF IGGPDDCE                                               */ 00618000
*   /*                                                               */ 00619000
*   /*****************************************************************/ 00620000
*                                                                  0289 00621000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 00622000
         BAL   R14,EXIT                                         DSKL013 00623000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 00624000
         DC    0F'0'                                            DSKL013 00625000
*   GEN(DC CL8'IGGPDCCC');          /* NAME OF FOLLOWING PROCEDURE   */ 00626000
         DC    CL8'IGGPDCCC'                                    DSKL013 00627000
*   END;                            /* END OF INNER PROCEDURE        */ 00628000
         BR    R14                                              DSKL013 00631000
*                                                                  0294 00635000
*/********************************************************************/ 00636000
*/*                                                                  */ 00637000
*/*        IGGPDCCC  -  PROCEDURE  INTERNALLY  CALLED  NESTED        */ 00638000
*/*                                                                  */ 00639000
*/********************************************************************/ 00640000
*                                                                  0294 00641000
*IGGPDCCC:                                                         0294 00642000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 00643000
IGGPDCCC DS    0H                                                  0295 00645000
*Z015:                              /* LABEL FOR PROCEDURE TRACKING  */ 00646000
*Z015DCCC:                          /* LABEL FOR PROCEDURE TRACKING  */ 00647000
*   RFY                                                            0295 00648000
*    (R5,                                                          0295 00649000
*     R6,                                                          0295 00650000
*     R7,                                                          0295 00651000
*     R8,                                                          0295 00652000
*     R9,                                                          0295 00653000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 00654000
*   RFY                                                            0296 00657000
*    (R2,                                                          0296 00658000
*     R3,                                                          0296 00659000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 00660000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 00661000
         STM   R12,R14,12(R13)                                  DSKL013 00662000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 00663000
*                                                                  0298 00664000
         LA    R13,12(R13)                                      DSKL013 00665000
*   /*****************************************************************/ 00666000
*   /*                                                               */ 00667000
*   /* ***CONSISTENCY CHECK OF CONTROLLING INPUT PARAMETERS***       */ 00668000
*   /*                                                               */ 00669000
*   /*****************************************************************/ 00670000
*                                                                  0299 00671000
*   AMDSBDAB=CTGFVDCH->CTGFVAMD->CTGFLPT(1);/* SET BASE ADDRESS OF 0299 00672000
*                                      DATA AMDSB                    */ 00673000
         L     R10,CCACPL(,R11)                                 DSKL013 00674000
         L     R5,CTGFVT(,R10)                                  DSKL013 00675000
         L     R5,CTGFVDCH(,R5)                                 DSKL013 00676000
         L     R5,CTGFVAMD(,R5)                                 DSKL013 00676010
         L     R2,CTGFLPT(,R5)                                  DSKL013 00678000
*   RFY                                                            0300 00679000
*     IDAAMDSB BASED(AMDSBDAB);     /* ESTABLISH ADDRESSABILITY OF 0300 00680000
*                                      AMDSB MAPPING STRUCTURE FOR 0300 00681000
*                                      DATA AMDSB                    */ 00682000
*   IF CTGTYPE=CTGTPGSP THEN        /* PAGE OR SWAPSPACE     @Z40WSSG*/ 00683000
         CLI   CTGTYPE(R10),C'P'                                DSKL013 00684000
         BNE   @RF00301                                            0301 00685000
*     DO;                           /*                         Y02020*/ 00686000
*       AMDCINV=PAGESIZ;            /* SET CI SIZE STNDRD      Y02020*/ 00687000
         MVC   AMDCINV(4,R2),@CF03335                           DSKL013 00688000
*       IF CTGTRKOV=ON&CTGSWAP=ON THEN/* TRACK OVERFLOW      @Z40WSSG   00689000
*                                      AND SWAPSPACE DEFINE  @Z40WSSG*/ 00690000
*                                                                  0304 00691000
         L     R5,CCAFLPT(,R11)                                 DSKL013 00692000
         L     R5,CTGFLPT(,R5)                                  DSKL013 00693000
         TM    CTGTRKOV(R5),B'00000001'                         DSKL013 00694000
         BNO   @RF00304                                            0304 00695000
         TM    CTGSWAP(R10),B'00100000'                         DSKL013 00696000
         BNO   @RF00304                                            0304 00697000
*         /***********************************************************/ 00698000
*         /*                                                         */ 00699000
*         /* SET CCAMODID='BX', CCAREASN=RSN34, CCARETRN=RCINCNPM    */ 00700000
*         /*                                                         */ 00701000
*         /***********************************************************/ 00702000
*                                                                  0305 00703000
*         CCAPROB=IGGSEGID+(RSN34*K256)+RCINCNPM;/* TRACK OVERFLOW 0305 00704000
*                                      ONLY SUPPORTED FOR PAGE SPACE    00705000
*                                      DATA SET. Y02020              */ 00706000
         MVC   CCAPROB(4,R11),@CF03478                             0305 00707000
*       ELSE                                                       0306 00708000
*         ;                         /* ERROR                   Y02020*/ 00709000
@RF00304 DS    0H                                                  0307 00710000
*       CALL EXIT;                  /*                         Y02020*/ 00711000
         BAL   R14,EXIT                                         DSKL013 00712000
*     END;                          /*                         Y02020*/ 00713000
*   ELSE                            /* NOT PAGE,SWAPSPACE    @Z40WSSG*/ 00714000
*     IF AMDSPAN=OFF&AMDLRECL+DRECOVHD>DCIMAXSZ THEN               0309 00715000
*                                                                  0309 00716000
         B     @RC00301                                            0309 00717000
@RF00301 TM    AMDSPAN(R2),B'00000001'                          DSKL013 00718000
         BNZ   @RF00309                                            0309 00719000
         LA    R10,7                                            DSKL013 00720000
         AL    R10,AMDLRECL(,R2)                                DSKL013 00721000
         C     R10,@CF03331                                     DSKL013 00722000
         BNH   @RF00309                                            0309 00723000
*       /*************************************************************/ 00724000
*       /*                                                           */ 00725000
*       /* SET CCAMODID='BX', CCAREASN=RSN0, CCARETRN=RCMLRSZ        */ 00726000
*       /*                                                           */ 00727000
*       /*************************************************************/ 00728000
*                                                                  0310 00729000
*       CCAPROB=IGGSEGID+(RSN0*K256)+RCMLRSZ;/* MAXIMUM LOGICAL RCD     00730000
*                                                            @Y30SSSG   00731000
*                                      SIZE SPECIFIED EXCEEDS      0310 00732000
*                                                            @Y30SSSG   00733000
*                                      ALLOWABLE MAXIMUM     @Y30SSSG*/ 00734000
         MVC   CCAPROB(4,R11),@CF03479                             0310 00735000
*     ELSE                                                         0311 00736000
*                                                                  0311 00737000
*       /*************************************************************/ 00738000
*       /*                                                           */ 00739000
*       /* IF CISIZE SPECIFIED FOR DATA CHECK IT AGAINST MAXIMUM     */ 00740000
*       /* VALUES                                            @Y30SSSG*/ 00741000
*       /*                                                           */ 00742000
*       /*************************************************************/ 00743000
*                                                                  0311 00744000
*       IF AMDCINV^=N THEN          /* CI SIZE SPECIFIED     @Y30SSSG   00745000
*                                      FOR DATA              @Y30SSSG*/ 00746000
         B     @RC00309                                            0311 00747000
@RF00309 L     R5,AMDCINV(,R2)                                  DSKL013 00748000
         LTR   R5,R5                                            DSKL013 00749000
         BZ    @RF00311                                            0311 00750000
*         DO;                       /* YES                   @Y30SSSG*/ 00751000
*                                                                  0312 00752000
*           /*********************************************************/ 00753000
*           /*                                                       */ 00754000
*           /* INSURE DATA CI SIZE VALUE IS INTEGER MULTIPLE OF      */ 00755000
*           /* MINIMUM PHYSICAL BLOCK SIZE CALL CONVERT TO INTEGER   */ 00756000
*           /* MULTIPLE OF MINIMUM PHYSICAL BLOCK SIZE SEGEMENT      */ 00757000
*           /*                                                       */ 00758000
*           /*********************************************************/ 00759000
*                                                                  0313 00760000
*           DCONV=AMDCINV;          /* GET DATA CI SIZE      @Y30SSSG*/ 00761000
         LR    R4,R5                                            DSKL013 00762000
*Z018DCIM:                                                         0314 00763000
*           CALL IGGPDCIM;          /* CONVERT CI SIZE       @Y30SSSG*/ 00764000
         BAL   R14,IGGPDCIM                                     DSKL013 00765000
*           AMDCINV=DCONV;          /* RESET ORIG CI SIZE    @Y30SSSG*/ 00766000
         ST    R4,AMDCINV(,R2)                                  DSKL013 00767000
*           IF AMDCINV>DCIMAXSZ THEN/* CI SIZE GT MAX        @Y30SSSG*/ 00768000
*                                                                  0316 00769000
         L     R10,AMDCINV(,R2)                                 DSKL013 00770000
         C     R10,@CF03331                                     DSKL013 00771000
         BNH   @RF00316                                            0316 00772000
*             /*******************************************************/ 00773000
*             /*                                                     */ 00774000
*             /* SET CCAMODID='BX', CCAREASN=RSN0, CCARETRN=RCMCISZD */ 00775000
*             /*                                                     */ 00776000
*             /*******************************************************/ 00777000
*                                                                  0317 00778000
*             CCAPROB=IGGSEGID+(RSN0*K256)+RCMCISZD;/* CISIZE GT MAX    00779000
*                                                            @Y30SSSG*/ 00780000
         MVC   CCAPROB(4,R11),@CF03480                             0317 00781000
*           ELSE                    /* CI SIZE SPEC NOT GT MAX     0318 00782000
*                                                            @Y30SSSG*/ 00783000
*             IF AMDSPAN=OFF&AMDCINV<AMDLRECL+DRECOVHD THEN/*      0318 00784000
*                                                            @Y30SSSG   00785000
*                                      IF NOT SPANNED        @Y30SSSG   00786000
*                                      AND DATA CI LESS THAN @Y30SSSG   00787000
*                                      LARGEST LRECL PLUS    @Y30SSSG   00788000
*                                      OVERHEAD              @Y30SSSG*/ 00789000
         B     @RC00311                                         DSKL013 00790000
@RF00316 TM    AMDSPAN(R2),B'00000001'                          DSKL013 00791000
         BNZ   @RC00311                                         DSKL013 00792000
         LA    R5,7                                             DSKL013 00793000
         AL    R5,AMDLRECL(,R2)                                 DSKL013 00794000
         C     R5,AMDCINV(,R2)                                  DSKL013 00795000
         BNH   @RC00311                                         DSKL013 00796000
*               DO;                 /* YES                   @Y30SSSG*/ 00797000
*                 DCONV=AMDLRECL+DRECOVHD;/* USE LARGEST     @Y30SSSG   00798000
*                                      LRECL PLUS OVERHEAD   @Y30SSSG*/ 00799000
         LR    R4,R5                                            DSKL013 00800000
*Z020DCIM:                                                         0321 00801000
*                 CALL IGGPDCIM;    /* CONVERT CI SIZE       @Y30SSSG*/ 00802000
         BAL   R14,IGGPDCIM                                     DSKL013 00803000
*                 AMDCINV=DCONV;    /* RESET ORIG CI SIZE    @Y30SSSG*/ 00804000
         ST    R4,AMDCINV(,R2)                                  DSKL013 00805000
*               END;                /*                       @Y30SSSG*/ 00806000
*         END;                                                     0324 00807000
*       ELSE                                                       0325 00808000
*         ;                         /* DATA CI SIZE NOT SPEC @Y30SSSG*/ 00809000
*                                                                  0325 00810000
@RF00311 DS    0H                                                  0326 00811000
*   /*****************************************************************/ 00812000
*   /*                                                               */ 00813000
*   /* IF RETURN CODE IS ZERO AND INDEXED CLUSTER THEN       @Y30SSSG*/ 00814000
*   /* PROCESS INDEX CI SIZE.                                @Y30SSSG*/ 00815000
*   /*                                                               */ 00816000
*   /*****************************************************************/ 00817000
*                                                                  0326 00818000
*   IF CCACD1=RCS THEN                                             0326 00819000
*                                                                  0326 00820000
@RC00311 DS    0H                                                  0326 00821000
@RC00309 DS    0H                                                  0326 00822000
@RC00301 CLI   CCACD1(R11),0                                       0326 00823000
         BNE   @RF00326                                            0326 00824000
*     /***************************************************************/ 00825000
*     /*                                                             */ 00826000
*     /* CHECK CISIZE FOR INDEX IF INDEXED CLUSTER                   */ 00827000
*     /*                                                             */ 00828000
*     /***************************************************************/ 00829000
*                                                                  0327 00830000
*     IF CTGFVICH^=N THEN           /* INDEXED CLUSTER               */ 00831000
         SLR   R10,R10                                          DSKL013 00832000
         L     R5,CCACPL(,R11)                                  DSKL013 00833000
         L     R5,CTGFVT(,R5)                                   DSKL013 00834000
         L     R5,CTGFVICH(,R5)                                 DSKL013 00835000
         CR    R5,R10                                           DSKL013 00836000
         BE    @RF00327                                            0327 00837000
*       DO;                                                        0328 00838000
*         AMDSBIXB=CTGFVICH->CTGFVAMD->CTGFLPT(1);/* SET BASE ADDRESS   00839000
*                                      OF INDEX AMDSB                */ 00840000
         L     R5,CTGFVAMD(,R5)                                 DSKL013 00841000
         L     R3,CTGFLPT(,R5)                                  DSKL013 00842000
*         IF AMDSBIXB->AMDCINV^=N THEN/* INDEX CI SIZE       @Y30SSSG   00843000
*                                      SPECIFIED?            @Y30SSSG*/ 00844000
         L     R5,AMDCINV(,R3)                                  DSKL013 00845000
         CR    R5,R10                                           DSKL013 00846000
         BE    @RF00330                                            0330 00847000
*           DO;                     /* YES                   @Y30SSSG*/ 00848000
*                                                                  0331 00849000
*             /*******************************************************/ 00850000
*             /*                                                     */ 00851000
*             /* INSURE INDEX CI SIZE VALUE IS A POWER OF 2 TIMES    */ 00852000
*             /* MINIMUM PHYSICAL BLOCK SIZE                         */ 00853000
*             /*                                                     */ 00854000
*             /*******************************************************/ 00855000
*                                                                  0332 00856000
*             DCONV=AMDSBIXB->AMDCINV;/* GET INDEX CI SIZE   @Y30SSSG*/ 00857000
*                                                                  0332 00858000
         LR    R4,R5                                            DSKL013 00859000
*             /*******************************************************/ 00860000
*             /*                                                     */ 00861000
*             /* CALL CONVERT TO A POWER OF 2 EQUAL OR GREATER THAN  */ 00862000
*             /* MINIMUM PHYSICAL BLOCK SIZE SEGMENT                 */ 00863000
*             /*                                                     */ 00864000
*             /*******************************************************/ 00865000
*                                                                  0333 00866000
*Z021DCPT:                                                         0333 00867000
*             CALL IGGPDCPT;                                       0333 00868000
         BAL   R14,IGGPDCPT                                     DSKL013 00869000
*             AMDSBIXB->AMDCINV=DCONV;/* NEW INDEX CI SIZE   @Y30SSSG*/ 00870000
         ST    R4,AMDCINV(,R3)                                  DSKL013 00871000
*             DCWABASE=ADDR(CMSDSPTB(2));/* SET ADDRESS OF INDEX   0335 00872000
*                                      ELEMENT OF DEVICE           0335 00873000
*                                      CHARACTERISTICS AND WORK    0335 00874000
*                                      VALUES ARRAY                  */ 00875000
         L     R4,CCACMSWA(,R11)                                DSKL013 00876000
         LA    R4,CMSDSPTB+32(,R4)                              DSKL013 00877000
*             IF AMDSBIXB->AMDCINV>DSMPHYBS THEN/* CI>MAX    @Y30SSSG*/ 00878000
*                                                                  0336 00879000
         L     R5,AMDCINV(,R3)                                  DSKL013 00880000
         CH    R5,DSMPHYBS(,R4)                                 DSKL013 00881000
         BNH   @RF00336                                            0336 00882000
*               /*****************************************************/ 00883000
*               /*                                                   */ 00884000
*               /* SET CCAMODID='BX', CCAREASN=RSN0,                 */ 00885000
*               /* CCARETRN=RCMCISZI                                 */ 00886000
*               /*                                                   */ 00887000
*               /*****************************************************/ 00888000
*                                                                  0337 00889000
*               CCAPROB=IGGSEGID+(RSN0*K256)+RCMCISZI;/* CISIZE SPEC    00890000
*                                                            @Y30SSSG   00891000
*                                      GT ALLOWABLE MAX      @Y30SSSG   00892000
*                                      FOR INDEX DEVICE      @Y30SSSG*/ 00893000
         MVC   CCAPROB(4,R11),@CF03481                             0337 00894000
*             ELSE                                                 0338 00895000
*               ;                                                  0338 00896000
@RF00336 DS    0H                                                  0339 00897000
*           END;                                                   0339 00898000
*         ELSE                                                     0340 00899000
*           ;                       /* NO INDEX CISIZE SPECIFIED     */ 00900000
*                                                                  0340 00901000
@RF00330 DS    0H                                                  0341 00902000
*         /***********************************************************/ 00903000
*         /*                                                         */ 00904000
*         /* CHECK KEY POSITION AND LENGTH AGAINST MAXIMUM LOGICAL   */ 00905000
*         /* RECORD SIZE                                             */ 00906000
*         /*                                                         */ 00907000
*         /***********************************************************/ 00908000
*                                                                  0341 00909000
*         IF CCACD1=RCS THEN        /* RETURN CODE ZERO      @Y30SSSG*/ 00910000
         CLI   CCACD1(R11),0                                       0341 00911000
         BNE   @RF00341                                            0341 00912000
*           IF AMDLRECL<AMDRKP+AMDKEYLN THEN/* KEY GT RCD    @Y30SSSG*/ 00913000
*                                                                  0342 00914000
         LH    R10,AMDRKP(,R2)                                  DSKL013 00915000
         AH    R10,AMDKEYLN(,R2)                                DSKL013 00916000
         C     R10,AMDLRECL(,R2)                                DSKL013 00917000
         BNH   @RF00342                                            0342 00918000
*             /*******************************************************/ 00919000
*             /*                                                     */ 00920000
*             /* SET CCAMODID='BX', CCAREASN=RSN0, CCARETRN=RCKEYINC */ 00921000
*             /*                                                     */ 00922000
*             /*******************************************************/ 00923000
*                                                                  0343 00924000
*             CCAPROB=IGGSEGID+(RSN0*K256)+RCKEYINC;/* KEY EXTENDS 0343 00925000
*                                                            @Y30SSSG   00926000
*                                      BEYOND END OF         @Y30SSSG   00927000
*                                      MAXIMUM LOGICAL       @Y30SSSG   00928000
*                                      RECORD                @Y30SSSG*/ 00929000
         MVC   CCAPROB(4,R11),@CF03482                             0343 00930000
*           ELSE                                                   0344 00931000
*             ;                                                    0344 00932000
@RF00342 DS    0H                                                  0345 00933000
*         ELSE                                                     0345 00934000
*           ;                                                      0345 00935000
@RF00341 DS    0H                                                  0346 00936000
*       END;                                                       0346 00937000
*     ELSE                                                         0347 00938000
*       ;                                                          0347 00939000
@RF00327 DS    0H                                                  0348 00940000
*   ELSE                                                           0348 00941000
*     ;                                                            0348 00942000
*                                                                  0348 00943000
@RF00326 DS    0H                                                  0349 00944000
*   /*****************************************************************/ 00945000
*   /*                                                               */ 00946000
*   /* IF BUFFER SIZE SPECIFIED THEN CHECK DATA AND          @Y30SSSG*/ 00947000
*   /* INDEX CI SIZE AGAINST BUFFER SIZE AND ALTER           @Y30SSSG*/ 00948000
*   /* DATA AND OR INDEX CI SIZE IF NECESSARY.               @Y30SSSG*/ 00949000
*   /*                                                               */ 00950000
*   /*****************************************************************/ 00951000
*                                                                  0349 00952000
*   IF CCACD1=RCS THEN              /* RC=0                  @Y30SSSG*/ 00953000
         CLI   CCACD1(R11),0                                       0349 00954000
         BNE   @RF00349                                            0349 00955000
*     IF CTGFVDCH->CTGFVBUF^=N THEN /* BUFFER SIZE SPECIFIED         */ 00956000
         SLR   R5,R5                                            DSKL013 00957000
         L     R10,CCACPL(,R11)                                 DSKL013 00958000
         L     R10,CTGFVT(,R10)                                 DSKL013 00959000
         L     R1,CTGFVDCH(,R10)                                DSKL013 00960000
         L     R6,CTGFVBUF(,R1)                                 DSKL013 00961000
         CR    R6,R5                                            DSKL013 00962000
         BE    @RF00350                                            0350 00963000
*       IF AMDCINV^=N THEN          /* CI SIZE SPECIFIED - DATA      */ 00964000
         L     R7,AMDCINV(,R2)                                  DSKL013 00965000
         CR    R7,R5                                            DSKL013 00966000
         BE    @RF00351                                            0351 00967000
*         IF CTGFVICH^=N THEN       /* INDEXED CLUSTER               */ 00968000
         C     R5,CTGFVICH(,R10)                                DSKL013 00969000
         BE    @RF00352                                            0352 00970000
*           IF AMDSBIXB->AMDCINV^=N THEN/* CI SIZE SPECIFIED FOR   0353 00971000
*                                      INDEX                         */ 00972000
         L     R10,AMDCINV(,R3)                                 DSKL013 00973000
         CR    R10,R5                                           DSKL013 00974000
         BE    @RF00353                                            0353 00975000
*             IF CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE<(AMDCINV*R)+   00976000
*                 AMDSBIXB->AMDCINV THEN/* BUFFER            @Y30SSSG   00977000
*                                      SIZE LESS THAN TWO    @Y30SSSG   00978000
*                                      DATA CI SIZE PLUS     @Y30SSSG   00979000
*                                      INDEX CI SIZE         @Y30SSSG*/ 00980000
*                                                                  0354 00981000
         L     R5,CTGFLPT(,R6)                                  DSKL013 00982000
         ALR   R7,R7                                            DSKL013 00983000
         ALR   R7,R10                                           DSKL013 00984000
         C     R7,BUFSIZE(,R5)                                  DSKL013 00985000
         BNH   @RF00354                                            0354 00986000
*               /*****************************************************/ 00987000
*               /*                                                   */ 00988000
*               /* SET CCAMODID='BX', CCAREASN=RSN0,                 */ 00989000
*               /* CCARETRN=RCBUFSIZ                                 */ 00990000
*               /*                                                   */ 00991000
*               /*****************************************************/ 00992000
*                                                                  0355 00993000
*               CCAPROB=IGGSEGID+(RSN0*K256)+RCBUFSIZ;/* BUFFER SIZE    00994000
*                                                            @Y30SSSG   00995000
*                                      TOO SMALL FOR MIN     @Y30SSSG   00996000
*                                      NUMBER OF CI'S        @Y30SSSG*/ 00997000
         MVC   CCAPROB(4,R11),@CF03483                             0355 00998000
*             ELSE                                                 0356 00999000
*               ;                                                  0356 01000000
@RF00354 DS    0H                                                  0357 01001000
*           ELSE                    /* CI SIZE NOT SPECIFIED FOR   0357 01002000
*                                      INDEX                         */ 01003000
*                                                                  0357 01004000
*             /*******************************************************/ 01005000
*             /*                                                     */ 01006000
*             /* ATTEMPT TO ESTABLISH DEFAULT VALUE FOR INDEX CI SIZE*/ 01007000
*             /* AND CHECK IT AGAINST BUFFER SIZE                    */ 01008000
*             /*                                                     */ 01009000
*             /*******************************************************/ 01010000
*                                                                  0357 01011000
*             IF AMDCINV/R<MPB THEN /* ATTEMPT TO USE RATIO OF DATA     01012000
*                                      CI SIZE FOR INDEX CI SIZE     */ 01013000
         B     @RC00349                                         DSKL013 01014000
@RF00353 LA    R10,512                                          DSKL013 01015000
         L     R5,AMDCINV(,R2)                                  DSKL013 01016000
         LR    R6,R5                                            DSKL013 01017000
         SRDA  R6,32                                            DSKL013 01018000
         D     R6,@CF00059                                      DSKL013 01019000
         CR    R7,R10                                           DSKL013 01020000
         BNL   @RF00357                                            0357 01021000
*               IF CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE<(AMDCINV*R)+ 01022000
*                   MPB THEN                                       0358 01023000
*                                                                  0358 01024000
         L     R1,CCACPL(,R11)                                  DSKL013 01025000
         L     R1,CTGFVT(,R1)                                   DSKL013 01026000
         L     R1,CTGFVDCH(,R1)                                 DSKL013 01027000
         L     R1,CTGFVBUF(,R1)                                 DSKL013 01028000
         L     R1,CTGFLPT(,R1)                                  DSKL013 01029000
         ALR   R5,R5                                            DSKL013 01030000
         ALR   R5,R10                                           DSKL013 01031000
         C     R5,BUFSIZE(,R1)                                  DSKL013 01032000
         BNH   @RF00358                                            0358 01033000
*                 /***************************************************/ 01034000
*                 /*                                                 */ 01035000
*                 /* SET CCAMODID='BX', CCAREASN=RSN0,               */ 01036000
*                 /* CCARETRN=RCBUFSIZ                               */ 01037000
*                 /*                                                 */ 01038000
*                 /***************************************************/ 01039000
*                                                                  0359 01040000
*                 CCAPROB=IGGSEGID+(RSN0*K256)+RCBUFSIZ;/* BUFFER  0359 01041000
*                                      SIZE                  @Y30SSSG   01042000
*                                      TOO SMALL FOR MIN     @Y30SSSG   01043000
*                                      NUMBER OF CI'S        @Y30SSSG*/ 01044000
         MVC   CCAPROB(4,R11),@CF03483                             0359 01045000
*               ELSE                                               0360 01046000
*                 AMDSBIXB->AMDCINV=MPB;/* SET DEFAULT MINIMUM INDEX    01047000
*                                      CI SIZE VALUE                 */ 01048000
         B     @RC00349                                         DSKL013 01049000
@RF00358 MVC   AMDCINV(4,R3),@CF01078                           DSKL013 01050000
*             ELSE                                                 0361 01051000
*               DO;                 /*                       @ZA17182*/ 01052000
*                                                                  0361 01053000
         B     @RC00349                                         DSKL013 01054000
@RF00357 DS    0H                                                  0362 01055000
*                 /***************************************************/ 01056000
*                 /*                                                 */ 01057000
*                 /* CHECK DEFAULT INDEX CI RATIO AGAINST    @ZA10635*/ 01058000
*                 /* MAX CI SIZE FOR INDEX AND BUFSIZE       @ZA10635*/ 01059000
*                 /*                                                 */ 01060000
*                 /***************************************************/ 01061000
*                                                                  0362 01062000
*                 DCWABASE=ADDR(CMSDSPTB(2));/* SET ADDRESS OF DEVICE   01063000
*                                      CHARACTERISTICS ARRAY @ZA17182*/ 01064000
         L     R4,CCACMSWA(,R11)                                DSKL013 01065000
         LA    R4,CMSDSPTB+32(,R4)                              DSKL013 01066000
*                 IF AMDCINV/R>DSMPHYBS THEN/* GT MAX INDX CI SZ   0363 01067000
*                                                            @ZA10635*/ 01068000
         L     R5,AMDCINV(,R2)                                  DSKL013 01069000
         LR    R8,R5                                            DSKL013 01070000
         SRDA  R8,32                                            DSKL013 01071000
         D     R8,@CF00059                                      DSKL013 01072000
         LH    R10,DSMPHYBS(,R4)                                DSKL013 01073000
         CR    R9,R10                                           DSKL013 01074000
         BNH   @RF00363                                            0363 01075000
*                   IF CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE<(AMDCINV 01076000
*                       *R)+DSMPHYBS THEN/* GT BUFSIZE       @ZA10635*/ 01077000
         L     R1,CCACPL(,R11)                                  DSKL013 01078000
         L     R1,CTGFVT(,R1)                                   DSKL013 01079000
         L     R1,CTGFVDCH(,R1)                                 DSKL013 01080000
         L     R1,CTGFVBUF(,R1)                                 DSKL013 01081000
         L     R1,CTGFLPT(,R1)                                  DSKL013 01082000
         ALR   R5,R5                                            DSKL013 01083000
         ALR   R5,R10                                           DSKL013 01084000
         C     R5,BUFSIZE(,R1)                                  DSKL013 01085000
         BNH   @RF00364                                            0364 01086000
*                     AMDSBIXB->AMDCINV=MPB;/* YES,SET MIN CISIZE  0365 01087000
*                                                            @ZA10635*/ 01088000
         MVC   AMDCINV(4,R3),@CF01078                           DSKL013 01089000
*                   ELSE            /* NO SET MAX CI SIZE    @ZA10635*/ 01090000
*                     AMDSBIXB->AMDCINV=DSMPHYBS;/* FOR INDEX      0366 01091000
*                                                            @ZA10635*/ 01092000
         B     @RC00349                                         DSKL013 01093000
@RF00364 LH    R5,DSMPHYBS(,R4)                                 DSKL013 01094000
         ST    R5,AMDCINV(,R3)                                  DSKL013 01095000
*                 ELSE              /* 1/2 DATA CI <= MAX CI @ZA10635*/ 01096000
*                   DO;             /* SET INDEX CI SIZE     @Y30SSSG*/ 01097000
         B     @RC00349                                         DSKL013 01098000
@RF00363 DS    0H                                                  0368 01099000
*                     DCONV=AMDCINV/R;/* TO 1/2 DATA CI SIZE @Y30SSSG*/ 01100000
*                                                                  0368 01101000
         L     R14,AMDCINV(,R2)                                 DSKL013 01102000
         SRDA  R14,32                                           DSKL013 01103000
         D     R14,@CF00059                                     DSKL013 01104000
         LR    R4,R15                                           DSKL013 01105000
*                     /***********************************************/ 01106000
*                     /*                                             */ 01107000
*                     /* CALL CONVERT TO A POWER OF 2 EQUAL OR       */ 01108000
*                     /* GREATER THAN MINIMUM PHYSICAL BLOCK SIZE    */ 01109000
*                     /* SEGMENT                                     */ 01110000
*                     /*                                             */ 01111000
*                     /***********************************************/ 01112000
*                                                                  0369 01113000
*Z026DCPT:                                                         0369 01114000
*                     CALL IGGPDCPT;                               0369 01115000
         BAL   R14,IGGPDCPT                                     DSKL013 01116000
*                     IF CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE<( 0370 01117000
*                         AMDCINV*R)+DCONV THEN                    0370 01118000
*                                                                  0370 01119000
         L     R10,CCACPL(,R11)                                 DSKL013 01120000
         L     R5,CTGFVT(,R10)                                  DSKL013 01121000
         L     R10,CTGFVDCH(,R5)                                DSKL013 01122000
         L     R5,CTGFVBUF(,R10)                                DSKL013 01123000
         L     R10,CTGFLPT(,R5)                                 DSKL013 01124000
         L     R5,AMDCINV(,R2)                                  DSKL013 01125000
         ALR   R5,R5                                            DSKL013 01126000
         ALR   R5,R4                                            DSKL013 01127000
         C     R5,BUFSIZE(,R10)                                 DSKL013 01128000
         BNH   @RF00370                                            0370 01129000
*                       /*********************************************/ 01130000
*                       /*                                           */ 01131000
*                       /* SET CCAMODID='BX', CCAREASN=RSN0,         */ 01132000
*                       /* CCARETRN=RCBUFSIZ                         */ 01133000
*                       /*                                           */ 01134000
*                       /*********************************************/ 01135000
*                                                                  0371 01136000
*                       CCAPROB=IGGSEGID+(RSN0*K256)+RCBUFSIZ;/*   0371 01137000
*                                      BUFFER SIZE           @Y30SSSG   01138000
*                                      TOO SMALL FOR MIN     @Y30SSSG   01139000
*                                      NUMBER OF CI'S        @Y30SSSG*/ 01140000
         MVC   CCAPROB(4,R11),@CF03483                             0371 01141000
*                     ELSE                                         0372 01142000
*                       AMDSBIXB->AMDCINV=DCONV;/* SET DEFAULT INDEX    01143000
*                                      CI SIZE TO SEE SET BY RATIO OF   01144000
*                                      DATA AND INDEX                */ 01145000
         B     @RC00349                                         DSKL013 01146000
@RF00370 ST    R4,AMDCINV(,R3)                                  DSKL013 01147000
*                   END;                                           0373 01148000
*               END;                /*                       @ZA17182*/ 01149000
*         ELSE                      /* ENTRY-SEQUENCED CLUSTER       */ 01150000
*           IF CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE<(AMDCINV*R) THEN 01151000
*                                                                  0375 01152000
         B     @RC00349                                         DSKL013 01153000
@RF00352 L     R10,CCACPL(,R11)                                 DSKL013 01154000
         L     R5,CTGFVT(,R10)                                  DSKL013 01155000
         L     R10,CTGFVDCH(,R5)                                DSKL013 01156000
         L     R5,CTGFVBUF(,R10)                                DSKL013 01157000
         L     R10,CTGFLPT(,R5)                                 DSKL013 01158000
         L     R5,AMDCINV(,R2)                                  DSKL013 01159000
         ALR   R5,R5                                            DSKL013 01160000
         C     R5,BUFSIZE(,R10)                                 DSKL013 01161000
         BNH   @RF00375                                            0375 01162000
*             /*******************************************************/ 01163000
*             /*                                                     */ 01164000
*             /* SET CCAMODID='BX', CCAREASN=RSN0, CCARETRN=RCBUFSIZ */ 01165000
*             /*                                                     */ 01166000
*             /*******************************************************/ 01167000
*                                                                  0376 01168000
*             CCAPROB=IGGSEGID+(RSN0*K256)+RCBUFSIZ;/* BUFFER SIZE 0376 01169000
*                                                            @Y30SSSG   01170000
*                                      TOO SMALL FOR MIN     @Y30SSSG   01171000
*                                      NUMBER OF CI'S        @Y30SSSG*/ 01172000
         MVC   CCAPROB(4,R11),@CF03483                             0376 01173000
*           ELSE                                                   0377 01174000
*             ;                                                    0377 01175000
@RF00375 DS    0H                                                  0378 01176000
*       ELSE                                                       0378 01177000
*         ;                         /* CI SIZE NOT SPECIFIED FOR DATA*/ 01178000
@RF00351 DS    0H                                                  0379 01179000
*     ELSE                                                         0379 01180000
*       ;                           /* BUFFER SIZE NOT SPECIFIED     */ 01181000
@RF00350 DS    0H                                                  0380 01182000
*   ELSE                                                           0380 01183000
*     ;                                                            0380 01184000
*                                                                  0380 01185000
@RF00349 DS    0H                                                  0381 01186000
*   /*****************************************************************/ 01187000
*   /*                                                               */ 01188000
*   /* SET AND OR ADJUST DATA CI SIZE                        @Y30SSSG*/ 01189000
*   /*                                                               */ 01190000
*   /*****************************************************************/ 01191000
*                                                                  0381 01192000
*   RFY                                                            0381 01193000
*     R0 RSTD;                                                     0381 01194000
@RC00349 DS    0H                                                  0382 01195000
*   R0=N;                           /* CLEAR DEFAULT INDICATOR       */ 01196000
         SLR   R0,R0                                               0382 01197000
*   IF CCACD1=RCS THEN              /* SUCCESSFUL            @Y30SSSG*/ 01198000
         CLI   CCACD1(R11),0                                       0383 01199000
         BNE   @RF00383                                            0383 01200000
*     DO;                           /* YES                   @Y30SSSG*/ 01201000
*       IF AMDCINV=N THEN           /* WAS A DATA CI SIZE SPECIFIED  */ 01202000
         ICM   R1,15,AMDCINV(R2)                                DSKL013 01203000
         BNZ   @RF00385                                            0385 01204000
*         DO;                       /* NO                            */ 01205000
*                                                                  0386 01206000
*           /*********************************************************/ 01207000
*           /*                                                       */ 01208000
*           /* COMPUTE DEFAULT FOR DATA CI SIZE              @Y30SSSG*/ 01209000
*           /*                                                       */ 01210000
*           /*********************************************************/ 01211000
*                                                                  0387 01212000
*Z029DCID:                                                         0387 01213000
*           CALL IGGPDCID;          /* GET DEFAULT DATA      @X04SVSG   01214000
*                                      CI SIZE               @Y30SSSG*/ 01215000
         BAL   R14,IGGPDCID                                     DSKL013 01216000
*           R0=ONE;                 /* SHOW DEFAULT WAS SELECTED FOR    01217000
*                                      DATA CI SIZE                  */ 01218000
         LA    R0,1                                                0388 01219000
*           IF CTGFVICH^=N THEN     /* CLUSTER INDEXED       @Y30SSSG*/ 01220000
         L     R1,CCACPL(,R11)                                  DSKL013 01221000
         L     R1,CTGFVT(,R1)                                   DSKL013 01222000
         L     R5,CTGFVICH(,R1)                                 DSKL013 01223000
         LTR   R5,R5                                            DSKL013 01224000
         BZ    @RF00389                                            0389 01225000
*             AMDSBIXB=CTGFVICH->CTGFVAMD->CTGFLPT(1);/*     @Y30SSSG   01226000
*                                      SET INDEX AMDSB ADDR  @Y30SSSG*/ 01227000
         L     R1,CTGFVAMD(,R5)                                 DSKL013 01228000
         L     R3,CTGFLPT(,R1)                                  DSKL013 01229000
*           ELSE                                                   0391 01230000
*             ;                     /*                       @Y30SSSG*/ 01231000
@RF00389 DS    0H                                                  0392 01232000
*         END;                                                     0392 01233000
*       ELSE                                                       0393 01234000
*         ;                         /* YES DATA CI SPECIFIED         */ 01235000
@RF00385 DS    0H                                                  0394 01236000
*       IF CTGFVICH=N THEN          /* IS CLUSTER INDEXED            */ 01237000
         SLR   R5,R5                                            DSKL013 01238000
         L     R1,CCACPL(,R11)                                  DSKL013 01239000
         L     R10,CTGFVT(,R1)                                  DSKL013 01240000
         C     R5,CTGFVICH(,R10)                                DSKL013 01241000
         BNE   @RF00394                                            0394 01242000
*         DO;                       /* NO                            */ 01243000
*           IF CTGFVDCH->CTGFVBUF^=N THEN/* WAS BUFFER SPACE       0396 01244000
*                                      SPECIFIED                     */ 01245000
         L     R1,CTGFVDCH(,R10)                                DSKL013 01246000
         C     R5,CTGFVBUF(,R1)                                 DSKL013 01247000
         BE    @RF00396                                            0396 01248000
*             DO WHILE((AMDCINV*TWO>/* YES                           */ 01249000
*                   (CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE))&(CCACD1= 01250000
*                   RCS));                                         0397 01251000
*                                                                  0397 01252000
         B     @DE00397                                            0397 01253000
@DL00397 DS    0H                                                  0398 01254000
*               /*****************************************************/ 01255000
*               /*                                                   */ 01256000
*               /* CALL TO MODULE IGG0CLB0                           */ 01257000
*               /*                                                   */ 01258000
*               /*****************************************************/ 01259000
*                                                                  0398 01260000
*Z030ITER:                                                         0398 01261000
*               CALL IGGPITER;      /* DECR DATA CI SIZE     @Y30SSSG*/ 01262000
         L     R15,@CV00039                                     DSKL013 01263000
         BALR  R14,R15                                          DSKL013 01264000
*             END;                                                 0399 01265000
@DE00397 L     R1,AMDCINV(,R2)                                  DSKL013 01266000
         ALR   R1,R1                                            DSKL013 01267000
         L     R5,CCACPL(,R11)                                  DSKL013 01268000
         L     R10,CTGFVT(,R5)                                  DSKL013 01269000
         L     R5,CTGFVDCH(,R10)                                DSKL013 01270000
         L     R10,CTGFVBUF(,R5)                                DSKL013 01271000
         L     R5,CTGFLPT(,R10)                                 DSKL013 01272000
         C     R1,BUFSIZE(,R5)                                  DSKL013 01273000
         BNH   @DC00397                                            0399 01274000
         CLI   CCACD1(R11),0                                       0399 01275000
         BE    @DL00397                                            0399 01276000
@DC00397 DS    0H                                                  0400 01277000
*           ELSE                                                   0400 01278000
*             ;                                                    0400 01279000
@RF00396 DS    0H                                                  0401 01280000
*         END;                                                     0401 01281000
*       ELSE                        /* INDEXED CLUSTER               */ 01282000
*         DO;                                                      0402 01283000
         B     @RC00383                                         DSKL013 01284000
@RF00394 DS    0H                                                  0403 01285000
*           IF AMDSBIXB->AMDCINV=N THEN/* WAS INDEX CI SIZE SPECIFIED*/ 01286000
         ICM   R10,15,AMDCINV(R3)                               DSKL013 01287000
         BNZ   @RF00403                                            0403 01288000
*             DO;                   /* NO                            */ 01289000
*               AMDSBIXB->AMDCINV=MPB;/* SET DEFAULT VALUE           */ 01290000
         MVC   AMDCINV(4,R3),@CF01078                           DSKL013 01291000
*               R0=R0+TWO;          /* SHOW DEFAULT VALUE GIVEN FOR     01292000
*                                      INDEX CI                      */ 01293000
         AL    R0,@CF00059                                         0406 01294000
*             END;                                                 0407 01295000
*           ELSE                                                   0408 01296000
*             ;                                                    0408 01297000
@RF00403 DS    0H                                                  0409 01298000
*           IF CTGFVDCH->CTGFVBUF^=N THEN/* WAS BUFFER SPACE       0409 01299000
*                                      SPECIFIED                     */ 01300000
         L     R1,CCACPL(,R11)                                  DSKL013 01301000
         L     R1,CTGFVT(,R1)                                   DSKL013 01302000
         L     R1,CTGFVDCH(,R1)                                 DSKL013 01303000
         ICM   R5,15,CTGFVBUF(R1)                               DSKL013 01304000
         BZ    @RF00409                                            0409 01305000
*             DO WHILE((((AMDCINV*TWO)+/* YES                        */ 01306000
*                   (AMDSBIXB->AMDCINV))>(CTGFVDCH->CTGFVBUF->CTGFLPT(1 01307000
*                   )->BUFSIZE))&(CCACD1=RCS));                    0410 01308000
*                                                                  0410 01309000
         B     @DE00410                                            0410 01310000
@DL00410 DS    0H                                                  0411 01311000
*               /*****************************************************/ 01312000
*               /*                                                   */ 01313000
*               /* CALL TO MODULE IGG0CLB0                           */ 01314000
*               /*                                                   */ 01315000
*               /*****************************************************/ 01316000
*                                                                  0411 01317000
*Z031ITER:                                                         0411 01318000
*               CALL IGGPITER;      /* DECR DATA CI SIZE     @Y30SSSG*/ 01319000
         L     R15,@CV00039                                     DSKL013 01320000
         BALR  R14,R15                                          DSKL013 01321000
*             END;                                                 0412 01322000
@DE00410 L     R1,AMDCINV(,R2)                                  DSKL013 01323000
         ALR   R1,R1                                            DSKL013 01324000
         AL    R1,AMDCINV(,R3)                                  DSKL013 01325000
         L     R5,CCACPL(,R11)                                  DSKL013 01326000
         L     R10,CTGFVT(,R5)                                  DSKL013 01327000
         L     R5,CTGFVDCH(,R10)                                DSKL013 01328000
         L     R10,CTGFVBUF(,R5)                                DSKL013 01329000
         L     R5,CTGFLPT(,R10)                                 DSKL013 01330000
         C     R1,BUFSIZE(,R5)                                  DSKL013 01331000
         BNH   @DC00410                                            0412 01332000
         CLI   CCACD1(R11),0                                       0412 01333000
         BE    @DL00410                                            0412 01334000
@DC00410 DS    0H                                                  0413 01335000
*           ELSE                                                   0413 01336000
*             ;                                                    0413 01337000
@RF00409 DS    0H                                                  0414 01338000
*           IF CCACD1=RCS&AMDSPAN=ON THEN/* SPANNED RECORDS  @OZ02294*/ 01339000
         CLI   CCACD1(R11),0                                       0414 01340000
         BNE   @RF00414                                            0414 01341000
         TM    AMDSPAN(R2),B'00000001'                          DSKL013 01342000
         BNO   @RF00414                                            0414 01343000
*             DO;                   /* NO                    @Y30SSSG*/ 01344000
*               IF AMDRKP+AMDKEYLN+SRECOVHD>AMDCINV THEN/*   @Y30SSSG   01345000
*                                      KEY POSITION PLUS     @Y30SSSG   01346000
*                                      LENGTH PLUS OVHD      @Y30SSSG   01347000
*                                      GREATER THAN CI SIZE  @Y30SSSG*/ 01348000
*                                                                  0416 01349000
         LH    R10,AMDRKP(,R2)                                  DSKL013 01350000
         AH    R10,AMDKEYLN(,R2)                                DSKL013 01351000
         AH    R10,@CH00260                                     DSKL013 01352000
         C     R10,AMDCINV(,R2)                                 DSKL013 01353000
         BNH   @RF00416                                            0416 01354000
*                 /***************************************************/ 01355000
*                 /*                                                 */ 01356000
*                 /* SET CCAMODID='BX', CCAREASN=RSN0,               */ 01357000
*                 /* CCARETRN=RCSPANCK                               */ 01358000
*                 /*                                                 */ 01359000
*                 /***************************************************/ 01360000
*                                                                  0417 01361000
*                 CCAPROB=IGGSEGID+(RSN0*K256)+RCSPANCK;/* SET ERROR    01362000
*                                                            @Y30SSSG*/ 01363000
         MVC   CCAPROB(4,R11),@CF03484                             0417 01364000
*               ELSE                                               0418 01365000
*                 ;                 /* NO ERROR              @Y30SSSG*/ 01366000
@RF00416 DS    0H                                                  0419 01367000
*             END;                  /*                       @Y30SSSG*/ 01368000
*           ELSE                                                   0420 01369000
*             ;                     /* NONSPANNED OR NO ERR  @Y30SSSG*/ 01370000
@RF00414 DS    0H                                                  0421 01371000
*         END;                                                     0421 01372000
*     END;                                                         0422 01373000
*   ELSE                                                           0423 01374000
*     ;                                                            0423 01375000
@RF00383 DS    0H                                                  0424 01376000
*   RFY                                                            0424 01377000
*     R0 UNRSTD;                                                   0424 01378000
*                                                                  0424 01379000
@RC00383 DS    0H                                                  0425 01380000
*   /*****************************************************************/ 01381000
*   /*                                                               */ 01382000
*   /* * * * * * * * * * * * * * * * * * * * * * * * * * * * *       */ 01383000
*   /* DETERMINE CONTROL AREA SIZE BASED UPON - UNIQUE ATTRIBUTE OF  */ 01384000
*   /* DATA = CA OF A CYLINDER - UNIT OF ALLOCATION OF CYLINDER = CA */ 01385000
*   /* OF A CYLINDER - SIZE OF SMALLER OF PRIMARY AND SECONDARY      */ 01386000
*   /* ALLOCATION QUANTITY (INCREASED BY 1 IF SEQUENCE SET WITH DATA)*/ 01387000
*   /* IF EQUAL OR GREATER THAN CYLINDER = CA OF A CYLINDER IF LESS  */ 01388000
*   /* THAN CYLINDER = CA OF THIS SIZE                               */ 01389000
*   /*                                                               */ 01390000
*   /*****************************************************************/ 01391000
*                                                                  0425 01392000
*   IF CCACD1=RCS&CTGTRKOV=OFF THEN /*                         Y02020*/ 01393000
         CLI   CCACD1(R11),0                                       0425 01394000
         BNE   @RF00425                                            0425 01395000
         L     R5,CCAFLPT(,R11)                                 DSKL013 01396000
         L     R10,CTGFLPT(,R5)                                 DSKL013 01397000
         TM    CTGTRKOV(R10),B'00000001'                        DSKL013 01398000
         BNZ   @RF00425                                            0425 01399000
*     DO;                                                          0426 01400000
*       DCWABASE=ADDR(CMSDSPTB(1)); /* SET ADDRESS OF DATA ELEMENT OF   01401000
*                                      DEVICE CHARACTERISTICS AND  0427 01402000
*                                      WORK VALUES ARRAY             */ 01403000
         L     R10,CCACMSWA(,R11)                               DSKL013 01404000
         LA    R4,CMSDSPTB(,R10)                                DSKL013 01405000
*       RFY                                                        0428 01406000
*         DEVCHARS BASED(ADDR(DSDEVCHA));/* ESTABLISH ADDRESSABILITY    01407000
*                                      FOR DEVICE CHARACTERISTICS  0428 01408000
*                                      MAPPING STRUCTURE             */ 01409000
*                                                                  0428 01410000
*       /*************************************************************/ 01411000
*       /*                                                           */ 01412000
*       /* IF DATA IS UNIQUE THEN SET CA SIZE TO A CYLINDER          */ 01413000
*       /*                                                           */ 01414000
*       /*************************************************************/ 01415000
*                                                                  0429 01416000
*       IF CTGFVDCH->CTGFVATR->CTGFLPT(1)->CTGDSUNQ=DSUNQ THEN/* DATA   01417000
*                                      IS UNIQUE TYPE                */ 01418000
         L     R5,CCACPL(,R11)                                  DSKL013 01419000
         L     R5,CTGFVT(,R5)                                   DSKL013 01420000
         L     R5,CTGFVDCH(,R5)                                 DSKL013 01421000
         L     R5,CTGFVATR(,R5)                                 DSKL013 01422000
         L     R5,CTGFLPT(,R5)                                  DSKL013 01423000
         TM    CTGDSUNQ(R5),B'01000000'                         DSKL013 01424000
         BNO   @RF00429                                            0429 01425000
*         CMTRKPCA(1)=RTNOTRKS;     /* SET CA SIZE TO CYLINDER       */ 01426000
         MVC   CMTRKPCA(2,R10),RTNOTRKS(R4)                     DSKL013 01427000
*       ELSE                        /* DATA NOT UNIQUE       @Y30SSSG*/ 01428000
*         DO;                                                      0431 01429000
         B     @RC00429                                            0431 01430000
@RF00429 DS    0H                                                  0432 01431000
*           IF CTGFVSPC^=N THEN     /* SPACE PARAMETERS ON CLUSTER   */ 01432000
         L     R10,CCACPL(,R11)                                 DSKL013 01433000
         L     R5,CTGFVT(,R10)                                  DSKL013 01434000
         L     R10,CTGFVSPC(,R5)                                DSKL013 01435000
         LTR   R10,R10                                          DSKL013 01436000
         BZ    @RF00432                                            0432 01437000
*             SPCPMBAS=CTGFVSPC->CTGFLPT(1);/* SET ADDRESS OF SPACE     01438000
*                                      PARAMETERS FROM CLUSTER       */ 01439000
         L     R2,CTGFLPT(,R10)                                 DSKL013 01440000
*           ELSE                                                   0434 01441000
*             SPCPMBAS=CTGFVDCH->CTGFVSPC->CTGFLPT(1);/* SET ADDRESS    01442000
*                                      OF SPACE PARAMETERS FROM DATA */ 01443000
         B     @RC00432                                            0434 01444000
@RF00432 L     R5,CCACPL(,R11)                                  DSKL013 01445000
         L     R10,CTGFVT(,R5)                                  DSKL013 01446000
         L     R5,CTGFVDCH(,R10)                                DSKL013 01447000
         L     R10,CTGFVSPC(,R5)                                DSKL013 01448000
         L     R2,CTGFLPT(,R10)                                 DSKL013 01449000
*           RFY                                                    0435 01450000
*             SPACEPRM BASED(SPCPMBAS);/* ESTABLISH ADDRESSABILITY 0435 01451000
*                                      FOR SPACE PARAMETERS MAPPING     01452000
*                                      STRUCTURE                     */ 01453000
@RC00432 DS    0H                                                  0436 01454000
*           IF SPCRQTYP=CMSALCYL THEN/* CYLINDER UNIT OF ALLOCATION  */ 01455000
         TM    SPCRQTYP(R2),B'11000000'                         DSKL013 01456000
         BNO   @RF00436                                            0436 01457000
*             CMTRKPCA(1)=RTNOTRKS; /* SET CA SIZE TO CYLINDER       */ 01458000
         L     R5,CCACMSWA(,R11)                                DSKL013 01459000
         MVC   CMTRKPCA(2,R5),RTNOTRKS(R4)                      DSKL013 01460000
*           ELSE                    /* CYL NOT UNIT OF       @Y30SSSG   01461000
*                                      ALLOCATION            @Y30SSSG*/ 01462000
*             DO;                                                  0438 01463000
         B     @RC00436                                            0438 01464000
@RF00436 DS    0H                                                  0439 01465000
*               IF SPCSECDQ=N THEN  /* NO SECONDARY QUANTITY OF    0439 01466000
*                                      ALLOCATION                    */ 01467000
         ICM   R10,7,SPCSECDQ(R2)                               DSKL013 01468000
         BNZ   @RF00439                                            0439 01469000
*                 SPCQTY=SPCPRIMQ;  /* SET TO PRIMARY QUANTITY       */ 01470000
         SLR   R3,R3                                            DSKL013 01471000
         ICM   R3,7,SPCPRIMQ(R2)                                DSKL013 01472000
*               ELSE                                               0441 01473000
*                 IF SPCPRIMQ>SPCSECDQ THEN/* PRIMARY ALLOC  @Y30SSSG   01474000
*                                      GREATER THAN SECONDARY        */ 01475000
         B     @RC00439                                            0441 01476000
@RF00439 CLC   SPCPRIMQ(3,R2),SPCSECDQ(R2)                      DSKL013 01477000
         BNH   @RF00441                                            0441 01478000
*                   SPCQTY=SPCSECDQ;/* SET TO SMALLER OF PRIMARY AND    01479000
*                                      SECONDARY QUANTITY            */ 01480000
         SLR   R3,R3                                            DSKL013 01481000
         ICM   R3,7,SPCSECDQ(R2)                                DSKL013 01482000
*                 ELSE                                             0443 01483000
*                   SPCQTY=SPCPRIMQ;/* SET ALLOCATION TO PRIMARY     */ 01484000
         B     @RC00441                                            0443 01485000
@RF00441 SLR   R3,R3                                            DSKL013 01486000
         ICM   R3,7,SPCPRIMQ(R2)                                DSKL013 01487000
*               IF SPCRQTYP=CMSALREC THEN/* RECORD UNIT OF ALLOCATION*/ 01488000
@RC00441 DS    0H                                                  0444 01489000
@RC00439 TM    SPCRQTYP(R2),B'01000000'                         DSKL013 01490000
         BNO   A000862                                          DSKL013 01491000
         TM    SPCRQTYP(R2),B'10000000'                         DSKL013 01492000
         BNZ   A000862                                          DSKL013 01493000
*                 DO;                                              0445 01494000
*                   CMDCONV=CTGFVDCH->CTGFVAMD->CTGFLPT(1)->AMDCINV;    01495000
         L     R5,CCACMSWA(,R11)                                DSKL013 01496000
         L     R10,CCACPL(,R11)                                 DSKL013 01497000
         L     R10,CTGFVT(,R10)                                 DSKL013 01498000
         L     R10,CTGFVDCH(,R10)                               DSKL013 01499000
         L     R10,CTGFVAMD(,R10)                               DSKL013 01500000
         L     R10,CTGFLPT(,R10)                                DSKL013 01501000
         MVC   CMDCONV(4,R5),AMDCINV(R10)                       DSKL013 01502000
*                                   /* GET DATA CI SIZE              */ 01503000
*                                                                  0447 01504000
*                   /*************************************************/ 01505000
*                   /*                                               */ 01506000
*                   /* CALL SEGMENT TO DETERMINE PHYSICAL BLOCK SIZE */ 01507000
*                   /* AND NUMBER OF BLOCKS PER TRACK INDEX VALUE FOR*/ 01508000
*                   /* DATA CI SIZE                                  */ 01509000
*                   /*                                               */ 01510000
*                   /*************************************************/ 01511000
*                                                                  0447 01512000
*                   DCWABASE=ADDR(CMSDSPTB(1));/* SET ADDR OF      0447 01513000
*                                                            @ZA05929   01514000
*                                      DATA ELEMENT OF DEV   @ZA05929   01515000
*                                      CHAR ARRAY            @ZA05929*/ 01516000
*                                                                  0447 01517000
         LA    R4,CMSDSPTB(,R5)                                 DSKL013 01518000
*                   /*************************************************/ 01519000
*                   /*                                               */ 01520000
*                   /* CALL TO MODULE IGG0CLB0                       */ 01521000
*                   /*                                               */ 01522000
*                   /*************************************************/ 01523000
*                                                                  0448 01524000
*Z033DPBI:                                                         0448 01525000
*                   CALL IGGPDPBI;  /* GET ARRAY ELEMENT     @Y30SSSG   01526000
*                                      IN CMPBI              @Y30SSSG*/ 01527000
*                                                                  0448 01528000
         L     R15,@CV00038                                     DSKL013 01529000
         BALR  R14,R15                                          DSKL013 01530000
*                   /*************************************************/ 01531000
*                   /*                                               */ 01532000
*                   /* DETERMINE NUMBER OF TRACKS REQUIRED FOR THIS  */ 01533000
*                   /* ALLOCATION : NUMBER OF RECORDS TIMES AVERAGE  */ 01534000
*                   /* LOGICAL RECORD SIZE ALL DIVIDED BY PHYSICAL   */ 01535000
*                   /* BLOCK SIZE TIMES NUMBER OF BLOCKS PER CI      */ 01536000
*                   /*                                               */ 01537000
*                   /*************************************************/ 01538000
*                                                                  0449 01539000
*                   AMDSBDAB=CTGFVDCH->CTGFVAMD->CTGFLPT(1);/*     0449 01540000
*                                                            @Y30SSSG   01541000
*                                      BASE DATA AMDSB       @Y30SSSG*/ 01542000
         L     R5,CCACPL(,R11)                                  DSKL013 01543000
         L     R10,CTGFVT(,R5)                                  DSKL013 01544000
         L     R5,CTGFVDCH(,R10)                                DSKL013 01545000
         L     R10,CTGFVAMD(,R5)                                DSKL013 01546000
         L     R2,CTGFLPT(,R10)                                 DSKL013 01547000
*                   RFY                                            0450 01548000
*                     RCDOVHD RSTD; /* RESTRICT THE REGISTER @Y30SSSG*/ 01549000
*                   IF AMDSPAN=ON THEN/* SPANNED DATA SET    @Y30SSSG*/ 01550000
         TM    AMDSPAN(R2),B'00000001'                          DSKL013 01551000
         BNO   A0006F0                                          DSKL013 01552000
*                     RCDOVHD=SRECOVHD;/* SET SPANNED OVERHEAD     0452 01553000
*                                                            @Y30SSSG*/ 01554000
         LA    R6,10                                            DSKL013 01555000
*                   ELSE            /* NOT SPANNED           @Y30SSSG*/ 01556000
*                     RCDOVHD=DRECOVHD;/* SET RECORD OVERHEAD      0453 01557000
*                                                            @Y30SSSG*/ 01558000
         B     A000704                                          DSKL013 01559000
A0006F0  TM    AMDRRDS(R2),X'02'                                DSKL013 01559010
         BNO   @RF00451                                         DSKL013 01559020
         LA    R6,4                                             DSKL013 01559030
         B     A000704                                          DSKL013 01559040
@RF00451 LA    R6,7                                             DSKL013 01560000
A000704  TM    AMDSPAN(R2),X'01'                                DSKL013 01560010
         BNO   @RF00444                                         DSKL013 01560020
         L     R7,AMDCINV(,R2)                                  DSKL013 01560030
         SLR   R7,R6                                            DSKL013 01560040
*                   IF(SPCQTY*(CTGFVDCH->CTGFVLRS->CTGFLPT(1)->LRECL+   01561000
*                       RCDOVHD))//(PHYBLKS(CMPBI)*DSPHYBPT(CMPBI))^=N  01562000
*                     THEN                                         0454 01563000
         L     R10,CCACPL(,R11)                                 DSKL013 01564000
         L     R10,CTGFVT(,R10)                                 DSKL013 01565000
         L     R10,CTGFVDCH(,R10)                               DSKL013 01566000
         L     R10,CTGFVLRS(,R10)                               DSKL013 01567000
         L     R10,CTGFLPT(,R10)                                DSKL013 01568000
         L     R10,LRECL(,R10)                                  DSKL013 01569000
         CR    R7,R10                                           DSKL013 01570000
         BNL   @RF00444                                         DSKL013 01571000
         LR    R0,R10                                           DSKL013 01577000
         SRDA  R0,32                                            DSKL013 01578000
         DR    R0,R7                                            DSKL013 01579000
         LTR   R0,R0                                            DSKL013 01580000
         BZ    @RF00454                                            0454 01581000
*                     SPCQTY=((SPCQTY*(CTGFVDCH->CTGFVLRS->CTGFLPT(1)-> 01582000
*                         LRECL+RCDOVHD))/(PHYBLKS(CMPBI)*DSPHYBPT(     01583000
*                         CMPBI)))+ONE;                            0455 01584000
         LR    R9,R10                                           DSKL013 01585000
         SLR   R8,R8                                            DSKL013 01586000
         DR    R8,R7                                            DSKL013 01587000
         AH    R9,@CH00041                                      DSKL013 01588000
         LR    R5,R9                                            DSKL013 01589000
*                   ELSE                                           0456 01590000
*                     SPCQTY=(SPCQTY*(CTGFVDCH->CTGFVLRS->CTGFLPT(1)->  01591000
*                         LRECL+RCDOVHD))/(PHYBLKS(CMPBI)*DSPHYBPT(     01592000
*                         CMPBI));                                 0456 01593000
         B     A000772                                          DSKL013 01594000
@RF00454 L     R7,CCACPL(,R11)                                  DSKL013 01595000
         L     R10,CTGFVT(,R7)                                  DSKL013 01596000
         L     R7,CTGFVDCH(,R10)                                DSKL013 01597000
         L     R10,CTGFVLRS(,R7)                                DSKL013 01598000
         L     R7,CTGFLPT(,R10)                                 DSKL013 01599000
         L     R5,AMDCINV(,R2)                                  DSKL013 01600000
         SLR   R5,R6                                            DSKL013 01601000
         L     R15,LRECL(,R7)                                   DSKL013 01602000
         SLR   R14,R14                                          DSKL013 01609000
         DR    R14,R5                                           DSKL013 01610000
         LR    R5,R15                                           DSKL013 01611000
A000772  LR    R1,R5                                            DSKL013 01611010
         MR    R0,R3                                            DSKL013 01611020
         LR    R3,R1                                            DSKL013 01611030
*                   RFY                                            0457 01612000
*                     RCDOVHD UNRSTD;/* RELEASE THE REGISTER @Y30SSSG*/ 01613000
*                 END;                                             0458 01615000
*               ELSE                                               0459 01616000
*                 IF SPCRQTYP^=CMSALTRK THEN/* IS TRK UNIT OF ALLOC  */ 01617000
*                                                                  0459 01618000
         B     A000804                                          DSKL013 01619000
@RF00444 TM    AMDRRDS(R2),X'02'                                DSKL013 01620000
         BNO   A0007B4                                          DSKL013 01621000
         L     R5,AMDCINV(,R2)                                  DSKL013 01622000
         SLR   R5,R6                                            DSKL013 01623000
         L     R7,CCACPL(,R11)                                  DSKL013 01623010
         L     R10,CTGFVT(,R7)                                  DSKL013 01623020
         L     R7,CTGFVDCH(,R10)                                DSKL013 01623030
         L     R10,CTGFVLRS(,R7)                                DSKL013 01623040
         L     R7,CTGFLPT(,R10)                                 DSKL013 01623050
         LA    R10,3                                            DSKL013 01623060
         AL    R10,LRECL(,R7)                                   DSKL013 01623070
         LR    R8,R5                                            DSKL013 01623080
         SRDA  R8,32                                            DSKL013 01623090
         DR    R8,R10                                           DSKL013 01623100
         LR    R5,R9                                            DSKL013 01623110
         B     A0007DA                                          DSKL013 01623120
A0007B4  L     R5,AMDCINV(,R2)                                  DSKL013 01623130
         SLR   R5,R6                                            DSKL013 01623140
         L     R7,CCACPL(,R11)                                  DSKL013 01623150
         L     R10,CTGFVT(,R7)                                  DSKL013 01623160
         L     R7,CTGFVDCH(,R10)                                DSKL013 01623170
         L     R10,CTGFVLRS(,R7)                                DSKL013 01623180
         L     R7,CTGFLPT(,R10)                                 DSKL013 01623190
         LR    R14,R5                                           DSKL013 01623200
         SRDA  R14,32                                           DSKL013 01623210
         D     R14,LRECL(,R7)                                   DSKL013 01623220
         LR    R5,R15                                           DSKL013 01623230
A0007DA  LR    R0,R3                                            DSKL013 01623240
         SRDA  R0,32                                            DSKL013 01623250
         DR    R0,R5                                            DSKL013 01623260
         LTR   R0,R0                                            DSKL013 01623270
         BZ    A0007FA                                          DSKL013 01623280
         LR    R8,R3                                            DSKL013 01623290
         SRDA  R8,32                                            DSKL013 01623300
         DR    R8,R5                                            DSKL013 01623310
         AH    R9,@CH00041                                      DSKL013 01623320
         LR    R3,R9                                            DSKL013 01623330
         B     A000804                                          DSKL013 01623340
A0007FA  LR    R14,R3                                           DSKL013 01623350
         SRDA  R14,32                                           DSKL013 01623360
         DR    R14,R5                                           DSKL013 01623370
         LR    R3,R15                                           DSKL013 01623380
A000804  LR    R1,R3                                            DSKL013 01623390
         M     R0,AMDCINV(,R2)                                  DSKL013 01623400
         L     R10,CCACMSWA(,R11)                               DSKL013 01623410
         L     R7,CMPBI(,R10)                                   DSKL013 01623420
         ALR   R7,R7                                            DSKL013 01623430
         LH    R10,PHYBLKS-2(R7)                                DSKL013 01623440
         MH    R10,DSPHYBPT-2(R7,R4)                            DSKL013 01623450
         LR    R8,R1                                            DSKL013 01623460
         SRDA  R8,32                                            DSKL013 01623470
         DR    R8,R10                                           DSKL013 01623480
         LTR   R8,R8                                            DSKL013 01623490
         BZ    A00083C                                          DSKL013 01623500
         LR    R14,R1                                           DSKL013 01623510
         SRDA  R14,32                                           DSKL013 01623520
         DR    R14,R10                                          DSKL013 01623530
         AH    R15,@CH00041                                     DSKL013 01623540
         LR    R3,R15                                           DSKL013 01623550
         B     A00085E                                          DSKL013 01623560
A00083C  LR    R1,R3                                            DSKL013 01623570
         M     R0,AMDCINV(,R2)                                  DSKL013 01623580
         L     R7,CCACMSWA(,R11)                                DSKL013 01623590
         L     R10,CMPBI(,R7)                                   DSKL013 01623600
         ALR   R10,R10                                          DSKL013 01623610
         LH    R7,PHYBLKS-2(R10)                                DSKL013 01623620
         MH    R7,DSPHYBPT-2(R10,R4)                            DSKL013 01623630
         LR    R8,R1                                            DSKL013 01623640
         SRDA  R8,32                                            DSKL013 01623650
         DR    R8,R7                                            DSKL013 01623660
         LR    R3,R9                                            DSKL013 01623670
A00085E  B     @RF00459                                         DSKL013 01623680
A000862  TM    SPCRQTYP(R2),B'10000000'                         DSKL013 01623690
         BNO   @RT00459                                         DSKL013 01623700
         TM    SPCRQTYP(R2),B'01000000'                         DSKL013 01623710
         BZ    @RC00444                                         DSKL013 01623720
@RT00459 DS    0H                                                  0460 01624000
*                   /*************************************************/ 01625000
*                   /*                                               */ 01626000
*                   /* SET CCAMODID='BX', CCAREASN=RSN34,            */ 01627000
*                   /* CCARETRN=RCINCNPM                             */ 01628000
*                   /*                                               */ 01629000
*                   /*************************************************/ 01630000
*                                                                  0460 01631000
*                   CCAPROB=IGGSEGID+(RSN34*K256)+RCINCNPM;/* INV  0460 01632000
*                                      SPACE                 @Y30SSSG   01633000
*                                      REQUEST TYPE ON       @Y30SSSG   01634000
*                                      REGULAR DEFINE        @Y30SSSG*/ 01635000
         MVC   CCAPROB(4,R11),@CF03478                             0460 01636000
*                 ELSE                                             0461 01637000
*                   ;                                              0461 01638000
@RF00459 DS    0H                                                  0462 01639000
*               AMDSBDAB=CTGFVDCH->CTGFVAMD->CTGFLPT(1);/* SET BASE     01640000
*                                      FOR DATA AMDSB                */ 01641000
@RC00444 L     R10,CCACPL(,R11)                                 DSKL013 01642000
         L     R5,CTGFVT(,R10)                                  DSKL013 01643000
         L     R10,CTGFVDCH(,R5)                                DSKL013 01644000
         L     R5,CTGFVAMD(,R10)                                DSKL013 01645000
         L     R2,CTGFLPT(,R5)                                  DSKL013 01646000
*               IF AMDSDT=ON THEN   /* SEQUENCE SET OF INDEX WITH  0463 01647000
*                                      DATA                          */ 01648000
         TM    AMDSDT(R2),B'00100000'                           DSKL013 01649000
         BNO   @RF00463                                            0463 01650000
*                 SPCQTY=SPCQTY+ONE;/* ADD ONE TRACK FOR SEQUENCE SET*/ 01651000
         AH    R3,@CH00041                                      DSKL013 01652000
*               ELSE                                               0465 01653000
*                 ;                                                0465 01654000
@RF00463 DS    0H                                                  0466 01655000
*               IF SPCQTY>=RTNOTRKS THEN/* SIZE OF SMALLER QUANTITY     01656000
*                                      OF ALLOCATION GREATER OR EQUAL   01657000
*                                      CYLINDER SIZE                 */ 01658000
         LH    R5,RTNOTRKS(,R4)                                 DSKL013 01659000
         CR    R3,R5                                            DSKL013 01660000
         BL    @RF00466                                            0466 01661000
*                 CMTRKPCA(1)=RTNOTRKS;/* SET CA SIZE TO CYLINDER    */ 01662000
         L     R10,CCACMSWA(,R11)                               DSKL013 01663000
         STH   R5,CMTRKPCA(,R10)                                DSKL013 01664000
*               ELSE                                               0468 01665000
*                 CMTRKPCA(1)=SPCQTY;/* SET CA SIZE TO A VALUE LESS     01666000
*                                      THAN A CYLINDER               */ 01667000
         B     @RC00466                                            0468 01668000
@RF00466 L     R5,CCACMSWA(,R11)                                DSKL013 01669000
         STH   R3,CMTRKPCA(,R5)                                 DSKL013 01670000
*             END;                                                 0469 01671000
@RC00466 DS    0H                                                  0470 01672000
*         END;                                                     0470 01673000
*                                                                  0470 01674000
@RC00436 DS    0H                                                  0471 01675000
*       /*************************************************************/ 01676000
*       /*                                                           */ 01677000
*       /* IF RRDS THEN CHECK IF MAX AND AVERAGE             @Y30SSSG*/ 01678000
*       /* RECORD SIZE THE SAME                              @Y30SSSG*/ 01679000
*       /*                                                           */ 01680000
*       /*************************************************************/ 01681000
*                                                                  0471 01682000
*       AMDSBDAB=CTGFVDCH->CTGFVAMD->CTGFLPT(1);/* SET       @Y30SSSG   01683000
*                                      BASE FOR DATA AMDSB   @Y30SSSG*/ 01684000
@RC00429 L     R10,CCACPL(,R11)                                 DSKL013 01685000
         L     R5,CTGFVT(,R10)                                  DSKL013 01686000
         L     R10,CTGFVDCH(,R5)                                DSKL013 01687000
         L     R5,CTGFVAMD(,R10)                                DSKL013 01688000
         L     R2,CTGFLPT(,R5)                                  DSKL013 01689000
*       IF AMDRRDS=ON THEN          /* RRDS                  @Y30SSSG*/ 01690000
         TM    AMDRRDS(R2),B'00000010'                          DSKL013 01691000
         BNO   @RF00472                                            0472 01692000
*         DO;                       /* YES                   @Y30SSSG*/ 01693000
*           IF AMDLRECL^=CTGFVDCH->CTGFVLRS->CTGFLPT(1)->LRECL THEN/*   01694000
*                                      MAX LRECL=AVG LRECL   @Y30SSSG*/ 01695000
         L     R5,CTGFVLRS(,R10)                                DSKL013 01696000
         L     R10,CTGFLPT(,R5)                                 DSKL013 01697000
         CLC   AMDLRECL(4,R2),LRECL(R10)                        DSKL013 01698000
         BE    @RF00474                                            0474 01699000
*             DO;                   /* NO                    @Y30SSSG*/ 01700000
*                                                                  0475 01701000
*               /*****************************************************/ 01702000
*               /*                                                   */ 01703000
*               /* SET CCAMODID='BX', CCAREASN=RSN44,                */ 01704000
*               /* CCARETRN=RCINCNPM                                 */ 01705000
*               /*                                                   */ 01706000
*               /*****************************************************/ 01707000
*                                                                  0476 01708000
*               CCAPROB=IGGSEGID+(RSN44*K256)+RCINCNPM;/* MAX      0476 01709000
*                                                            @Y30SSSG   01710000
*                                      LRECL DOES NOT EQUAL  @Y30SSSG   01711000
*                                      AVERAGE LRECL         @Y30SSSG*/ 01712000
         MVC   CCAPROB(4,R11),@CF03487                             0476 01713000
*             END;                  /*                       @Y30SSSG*/ 01714000
*           ELSE                                                   0478 01715000
*             ;                     /* MAX LRECL = AVG LRECL @Y30SSSG*/ 01716000
@RF00474 DS    0H                                                  0479 01717000
*         END;                      /*                       @Y30SSSG*/ 01718000
*       ELSE                                                       0480 01719000
*         ;                         /* NOT RRDS              @Y30SSSG*/ 01720000
@RF00472 DS    0H                                                  0481 01721000
*     END;                          /*                       @Y30SSSG*/ 01722000
*   ELSE                                                           0482 01723000
*     ;                                                            0482 01724000
*                                                                  0482 01725000
@RF00425 DS    0H                                                  0483 01726000
*   /*****************************************************************/ 01727000
*   /*                                                               */ 01728000
*   /* END OF IGGPDCCC                                       @Y30SSSG*/ 01729000
*   /*                                                               */ 01730000
*   /*****************************************************************/ 01731000
*                                                                  0483 01732000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01733000
         BAL   R14,EXIT                                         DSKL013 01734000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 01735000
         DC    0F'0'                                            DSKL013 01736000
*   GEN(DC CL8'IGGPDCIM');          /* NAME OF FOLLOWING PROCEDURE   */ 01737000
         DC    CL8'IGGPDCIM'                                    DSKL013 01738000
*   END;                            /* END OF INNER PROCEDURE        */ 01739000
         BR    R14                                              DSKL013 01742000
*                                                                  0488 01746000
*/********************************************************************/ 01747000
*/*                                                                  */ 01748000
*/*        IGGPDCIM  -  PROCEDURE  EXTERNALLY  CALLED  NESTED        */ 01749000
*/*                                                                  */ 01750000
*/********************************************************************/ 01751000
*                                                                  0488 01752000
*IGGPDCIM:                                                         0488 01753000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01754000
IGGPDCIM DS    0H                                                  0489 01756000
*   GEN(ENTRY IGGPDCIM );           /* IDENTIFY ENTRY-POINT SYMBOL   */ 01757000
         ENTRY IGGPDCIM                                                 01758000
*Z036:                              /* LABEL FOR PROCEDURE TRACKING  */ 01759000
*Z036DCIM:                          /* LABEL FOR PROCEDURE TRACKING  */ 01760000
*   RFY                                                            0490 01761000
*    (R5,                                                          0490 01762000
*     R6,                                                          0490 01763000
*     R7,                                                          0490 01764000
*     R8,                                                          0490 01765000
*     R9,                                                          0490 01766000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 01767000
*   RFY                                                            0491 01770000
*    (R2,                                                          0491 01771000
*     R3,                                                          0491 01772000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 01773000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 01774000
         STM   R12,R14,12(R13)                                  DSKL013 01775000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 01776000
         LA    R13,12(R13)                                      DSKL013 01777000
*   GEN(BALR 12,0);                 /* ESTABLISH ADDRESSABILITY      */ 01778000
         BALR  R12,0                                            DSKL013 01779000
*   GEN(LA 15,*-IGGSEGST(0,0));     /* COMPUTE MODULE BASE           */ 01780000
         LA    R15,*-IGGSEGST                                   DSKL013 01781000
*   GEN(SR 12,15);                  /* SET BASE TO MODULE BASE       */ 01782000
*                                                                  0496 01783000
         SR    R12,R15                                          DSKL013 01784000
*   /*****************************************************************/ 01785000
*   /*                                                               */ 01786000
*   /*                                                       @Y30SSSG*/ 01787000
*   /* CONVERT VALUE TO INTEGER MULTIPLE OF MINIMUM BLOCK SIZE OR IF */ 01788000
*   /* GREATER THEN 8K A MULTIPLE OF 2K. INPUT               @Y30SSSG*/ 01789000
*   /* VALUE AND OUTPUT VALUE IS IN DCONV.                   @Y30SSSG*/ 01790000
*   /*                                                               */ 01791000
*   /*****************************************************************/ 01792000
*                                                                  0497 01793000
*   RFY                                                            0497 01794000
*     R0 RSTD;                                                     0497 01795000
*   IF DCONV<=AK                    /* IF LESS THAN 8K               */ 01796000
*     THEN                                                         0498 01797000
         CH    R4,@CH03352                                      DSKL013 01798000
         BH    @RF00498                                            0498 01799000
*     DCONV=((DCONV+MPB-ONE)/MPB)*MPB;/* SET TO FIT WITHIN MULTIPLE     01800000
*                                      OF MPB                        */ 01801000
         LR    R14,R4                                           DSKL013 01802000
         SH    R14,@CH03488                                     DSKL013 01803000
         SRDA  R14,32                                           DSKL013 01804000
         D     R14,@CF01078                                     DSKL013 01805000
         SLA   R15,9                                            DSKL013 01806000
         LR    R4,R15                                           DSKL013 01807000
*   ELSE                                                           0500 01808000
*     DCONV=((DCONV+TWOK-ONE)/TWOK)*TWOK;/* IF GREATER THEN 8K FIT 0500 01809000
*                                      WITHIN MULTI 8K               */ 01810000
*                                                                  0500 01811000
         B     @RC00498                                            0500 01812000
@RF00498 LR    R6,R4                                            DSKL013 01813000
         SH    R6,@CH03489                                      DSKL013 01814000
         SRDA  R6,32                                            DSKL013 01815000
         D     R6,@CF03333                                      DSKL013 01816000
         SLA   R7,11                                            DSKL013 01817000
         LR    R4,R7                                            DSKL013 01818000
*   /*****************************************************************/ 01819000
*   /*                                                               */ 01820000
*   /* END OF IGGPDCIM                                               */ 01821000
*   /*                                                               */ 01822000
*   /*****************************************************************/ 01823000
*                                                                  0501 01824000
*   RFY                                                            0501 01825000
*     R0 UNRSTD;                                                   0501 01826000
@RC00498 DS    0H                                                  0502 01827000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01828000
         BAL   R14,EXIT                                         DSKL013 01829000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 01830000
         DC    0F'0'                                            DSKL013 01831000
*   GEN(DC CL8'IGGPDCID');          /* NAME OF FOLLOWING PROCEDURE   */ 01832000
         DC    CL8'IGGPDCID'                                    DSKL013 01833000
*   END;                            /* END OF INNER PROCEDURE        */ 01834000
         BR    R14                                              DSKL013 01837000
*                                                                  0507 01841000
*/********************************************************************/ 01842000
*/*                                                                  */ 01843000
*/*        IGGPDCID  -  PROCEDURE  INTERNALLY  CALLED  NESTED        */ 01844000
*/*                                                                  */ 01845000
*/********************************************************************/ 01846000
*                                                                  0507 01847000
*IGGPDCID:                                                         0507 01848000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01849000
IGGPDCID DS    0H                                                  0508 01851000
*Z037:                              /* LABEL FOR PROCEDURE TRACKING  */ 01852000
*Z037DCID:                          /* LABEL FOR PROCEDURE TRACKING  */ 01853000
*   RFY                                                            0508 01854000
*    (R5,                                                          0508 01855000
*     R6,                                                          0508 01856000
*     R7,                                                          0508 01857000
*     R8,                                                          0508 01858000
*     R9,                                                          0508 01859000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 01860000
*   RFY                                                            0509 01863000
*    (R2,                                                          0509 01864000
*     R3,                                                          0509 01865000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 01866000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 01867000
         STM   R12,R14,12(R13)                                  DSKL013 01868000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 01869000
*                                                                  0511 01870000
         LA    R13,12(R13)                                      DSKL013 01871000
*   /*****************************************************************/ 01872000
*   /*                                                               */ 01873000
*   /*                                                       @Y30SSSG*/ 01874000
*   /* DEFAULT DATA CI CALCULATION PROCEDURE                 @Y30SSSG*/ 01875000
*   /*                                                               */ 01876000
*   /*****************************************************************/ 01877000
*                                                                  0512 01878000
*   CCAURAB=ADDR(CCARAB5);          /* POINT TO WORK AREA    @Y30SSSG*/ 01879000
*                                                                  0512 01880000
         LA    R5,CCARAB5(,R11)                                 DSKL013 01881000
         ST    R5,CCAURAB(,R11)                                 DSKL013 01882000
*   /*****************************************************************/ 01883000
*   /*                                                               */ 01884000
*   /* ZERO WORK AREA IN RAB5                                @ZA05929*/ 01885000
*   /*                                                               */ 01886000
*   /*****************************************************************/ 01887000
*                                                                  0513 01888000
*   CATRECRD(1,1:256)=CATRECRD(1,1:256)&&CATRECRD(1,1:256);        0513 01889000
         L     R10,CCACPE1(,R5)                                 DSKL013 01890000
         XC    CATRECRD(256,R10),CATRECRD(R10)                  DSKL013 01891000
*   CATRECRD(2,1:256)=CATRECRD(2,1:256)&&CATRECRD(2,1:256);        0514 01892000
         XC    CATRECRD+256(256,R10),CATRECRD+256(R10)          DSKL013 01893000
         LA    R5,CCARAB4(,R11)                                 DSKL013 01893010
         ST    R5,CCAURAB(,R11)                                 DSKL013 01893020
         L     R10,CCACPE1(,R5)                                 DSKL013 01893030
         XC    CATRECRD(256,R10),CATRECRD(R10)                  DSKL013 01893040
         XC    CATRECRD+256(256,R10),CATRECRD+256(R10)          DSKL013 01893050
*   RESPECIFY                                                      0515 01894000
*     DSPTBL BASED(DCWREG);         /* REBASE DEV CHAR       @Y30SSSG*/ 01895000
*                                                                  0515 01896000
*   /*****************************************************************/ 01897000
*   /*                                                               */ 01898000
*   /* CALCULATE UPPER LIMIT OF DATA CI SIZE                 @Y30SSSG*/ 01899000
*   /*                                                               */ 01900000
*   /*****************************************************************/ 01901000
*                                                                  0516 01902000
*   CMDCONV=MBN2314;                /* INPUT FOR TRACK CALC  @ZA05929*/ 01903000
         L     R5,CCACMSWA(,R11)                                DSKL013 01904000
         MVC   CMDCONV(4,R5),@CF03335                           DSKL013 01905000
*   DCWABASE=ADDR(CMSDSPTB(1));     /* SET ADDR OF           @ZA05929   01906000
*                                      DATA ELEMENT OF DEV   @ZA05929   01907000
*                                      CHAR ARRAY            @ZA05929*/ 01908000
*                                                                  0517 01909000
         LA    R4,CMSDSPTB(,R5)                                 DSKL013 01910000
*   /*****************************************************************/ 01911000
*   /*                                                               */ 01912000
*   /* CALL TO MODULE IGG0CLB0                                       */ 01913000
*   /*                                                               */ 01914000
*   /*****************************************************************/ 01915000
*                                                                  0518 01916000
*Z038DPBI:                                                         0518 01917000
*   CALL IGGPDPBI;                  /* GET ARRAY ELEMENT     @ZA05929*/ 01918000
         L     R15,@CV00038                                     DSKL013 01919000
         BALR  R14,R15                                          DSKL013 01920000
*   IF CTGFVDCH->CTGFVBUF=N THEN    /* BUFFERSPACE NOT       @ZA05929   01921000
*                                      SPECIFIED             @ZA05929*/ 01922000
         L     R5,CCACPL(,R11)                                  DSKL013 01923000
         L     R10,CTGFVT(,R5)                                  DSKL013 01924000
         L     R5,CTGFVDCH(,R10)                                DSKL013 01925000
         ICM   R10,15,CTGFVBUF(R5)                              DSKL013 01926000
         BNZ   @RF00519                                            0519 01927000
*     CILIMIT=BLKV(CMPBI);          /* SET UPPER LIMIT       @ZA05929   01928000
*                                      TO TRACK CAPACITY     @ZA05929*/ 01929000
         L     R5,CCAURAB(,R11)                                 DSKL013 01930000
         L     R10,CCACPE1(,R5)                                 DSKL013 01931000
         L     R5,CCACMSWA(,R11)                                DSKL013 01932000
         L     R5,CMPBI(,R5)                                    DSKL013 01933000
         SLA   R5,2                                             DSKL013 01934000
         L     R5,BLKV-4(R5,R10)                                DSKL013 01935000
         ST    R5,CILIMIT(,R10)                                 DSKL013 01936000
*   ELSE                            /* CALCULATE UPPER LIMIT#Y30SSSG    01937000
*                                      OF DATA CI SIZE       #Y30SSSG*/ 01938000
*     DO;                           /*                       @ZA05929*/ 01939000
         B     A000AB6                                          DSKL013 01940000
@RF00519 DS    0H                                                  0522 01941000
*       IF CTGFVICH=N THEN          /* ESDS DATA SET         @ZA05929*/ 01942000
         L     R10,CCACPL(,R11)                                 DSKL013 01943000
         L     R5,CTGFVT(,R10)                                  DSKL013 01944000
         ICM   R10,15,CTGFVICH(R5)                              DSKL013 01945000
         BNZ   @RF00522                                            0522 01946000
*         CILIMIT=MIN((CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE/TWO),    01947000
*             BLKV(CMPBI));         /* GET MIN OF TRK SIZE AND     0523 01948000
*                                      BUFFERSIZE LIMIT      @ZA05929*/ 01949000
         L     R10,CCAURAB(,R11)                                DSKL013 01950000
         L     R10,CCACPE1(,R10)                                DSKL013 01951000
         L     R5,CTGFVDCH(,R5)                                 DSKL013 01952000
         L     R5,CTGFVBUF(,R5)                                 DSKL013 01953000
         L     R5,CTGFLPT(,R5)                                  DSKL013 01954000
         L     R5,BUFSIZE(,R5)                                  DSKL013 01955000
         SRL   R5,1                                             DSKL013 01956000
         L     R1,CCACMSWA(,R11)                                DSKL013 01957000
         L     R6,CMPBI(,R1)                                    DSKL013 01958000
         SLA   R6,2                                             DSKL013 01959000
         L     R7,BLKV-4(R6,R10)                                DSKL013 01960000
         CR    R5,R7                                            DSKL013 01961000
         BNH   *+6                                                      01962000
         LR    R5,R7                                            DSKL013 01963000
         ST    R5,CILIMIT(,R10)                                 DSKL013 01964000
*       ELSE                        /* KSDS DATA SET         @ZA05929*/ 01965000
*         DO;                       /* DETERMINE MAX SIZE    @ZA05929*/ 01966000
         B     A000AB6                                          DSKL013 01967000
@RF00522 DS    0H                                                  0525 01968000
*           IF AMDSBIXB->AMDCINV=N THEN/* INDEX CI SIZE      @ZA05929   01969000
*                                      SPECIFIED             @ZA05929*/ 01970000
         ICM   R10,15,AMDCINV(R3)                               DSKL013 01971000
         BNZ   @RF00525                                            0525 01972000
*             DO;                   /* NO,USE DEFAULT        @ZA05929*/ 01973000
*               CILIMIT=MIN(((CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE-  01974000
*                   MPB)/TWO),BLKV(CMPBI));/* IN CALCULATIONS      0527 01975000
*                                                            @ZA05929*/ 01976000
         L     R5,CCAURAB(,R11)                                 DSKL013 01977000
         L     R10,CCACPE1(,R5)                                 DSKL013 01978000
         L     R5,CCACPL(,R11)                                  DSKL013 01979000
         L     R5,CTGFVT(,R5)                                   DSKL013 01980000
         L     R5,CTGFVDCH(,R5)                                 DSKL013 01981000
         L     R5,CTGFVBUF(,R5)                                 DSKL013 01982000
         L     R5,CTGFLPT(,R5)                                  DSKL013 01983000
         L     R8,BUFSIZE(,R5)                                  DSKL013 01984000
         SL    R8,@CF01078                                      DSKL013 01985000
         SRDA  R8,32                                            DSKL013 01986000
         D     R8,@CF00059                                      DSKL013 01987000
         L     R5,CCACMSWA(,R11)                                DSKL013 01988000
         L     R5,CMPBI(,R5)                                    DSKL013 01989000
         SLA   R5,2                                             DSKL013 01990000
         L     R5,BLKV-4(R5,R10)                                DSKL013 01991000
         CR    R9,R5                                            DSKL013 01992000
         BNH   *+6                                                      01993000
         LR    R9,R5                                            DSKL013 01994000
         ST    R9,CILIMIT(,R10)                                 DSKL013 01995000
*             END;                  /*                       @ZA05929*/ 01996000
*           ELSE                    /* YES,USE IT IN CALC    @ZA05929*/ 01997000
*             DO;                   /* CALCULATE UPPER LIMIT @ZA05929*/ 01998000
         B     A000AB6                                          DSKL013 01999000
@RF00525 DS    0H                                                  0530 02000000
*               CILIMIT=MIN(((CTGFVDCH->CTGFVBUF->CTGFLPT(1)->BUFSIZE-  02001000
*                   AMDSBIXB->AMDCINV)/TWO),BLKV(CMPBI));/*  @ZA05929   02002000
*                                      OF DATA CI SIZE       @ZA05929*/ 02003000
         L     R10,CCAURAB(,R11)                                DSKL013 02004000
         L     R5,CCACPE1(,R10)                                 DSKL013 02005000
         L     R10,CCACPL(,R11)                                 DSKL013 02006000
         L     R10,CTGFVT(,R10)                                 DSKL013 02007000
         L     R10,CTGFVDCH(,R10)                               DSKL013 02008000
         L     R10,CTGFVBUF(,R10)                               DSKL013 02009000
         L     R10,CTGFLPT(,R10)                                DSKL013 02010000
         L     R14,BUFSIZE(,R10)                                DSKL013 02011000
         SL    R14,AMDCINV(,R3)                                 DSKL013 02012000
         SRDA  R14,32                                           DSKL013 02013000
         D     R14,@CF00059                                     DSKL013 02014000
         L     R10,CCACMSWA(,R11)                               DSKL013 02015000
         L     R10,CMPBI(,R10)                                  DSKL013 02016000
         SLA   R10,2                                            DSKL013 02017000
         L     R10,BLKV-4(R10,R5)                               DSKL013 02018000
         CR    R15,R10                                          DSKL013 02019000
         BNH   *+6                                                      02020000
         LR    R15,R10                                          DSKL013 02021000
         ST    R15,CILIMIT(,R5)                                 DSKL013 02022000
A000AB6  L     R5,@CF03331                                      DSKL013 02022010
         L     R10,CCAURAB(,R11)                                DSKL013 02022020
         L     R10,CCACPE1(,R10)                                DSKL013 02022030
         C     R5,CILIMIT(,R10)                                 DSKL013 02022040
         BNL   @RC00519                                         DSKL013 02022050
         ST    R5,CILIMIT(,R10)                                 DSKL013 02022060
*             END;                  /*                       @ZA05929*/ 02023000
*         END;                      /*                       @ZA05929*/ 02024000
*     END;                          /*                       @ZA05929*/ 02026000
*                                                                  0533 02027000
*   /*****************************************************************/ 02029000
*   /*                                                               */ 02030000
*   /* CALCULATE LOWER LIMIT OF DATA CI SIZE.                #Y30SSSG*/ 02031000
*   /*                                                               */ 02032000
*   /*****************************************************************/ 02033000
*                                                                  0534 02034000
*   IF AMDSPAN=ON THEN              /* SPANNED               #Y30SSSG*/ 02035000
@RC00519 TM    AMDSPAN(R2),B'00000001'                          DSKL013 02036000
         BNO   A000AE4                                          DSKL013 02037000
         L     R5,CCAURAB(,R11)                                 DSKL013 02037010
         L     R10,CCACPE1(,R5)                                 DSKL013 02037020
         MVC   CILIMIT(4,R10),@CF03331 =F'32768'                DSKL013 02037030
A000AE4  TM    AMDSPAN(R2),X'01'                                DSKL013 02037040
         BNO   @RF00534                                         DSKL013 02037050
*     DO;                           /* YES,USE SPAN OVHD     #Y30SSSG*/ 02038000
*       DCONV=MAX(AMDRKP+AMDKEYLN+SRECOVHD,CTGFVDCH->CTGFVLRS->CTGFLPT( 02039000
*           1)->LRECL+SRECOVHD);    /* PLUS AVERAGE RCDSIZE  #Y30SSSG*/ 02040000
         LA    R10,10                                           DSKL013 02041000
         LH    R4,AMDRKP(,R2)                                   DSKL013 02042000
         AH    R4,AMDKEYLN(,R2)                                 DSKL013 02043000
         ALR   R4,R10                                           DSKL013 02044000
         L     R1,CCACPL(,R11)                                  DSKL013 02045000
         L     R1,CTGFVT(,R1)                                   DSKL013 02046000
         L     R1,CTGFVDCH(,R1)                                 DSKL013 02047000
         L     R1,CTGFVLRS(,R1)                                 DSKL013 02048000
         L     R1,CTGFLPT(,R1)                                  DSKL013 02049000
         AL    R10,LRECL(,R1)                                   DSKL013 02050000
         CR    R4,R10                                           DSKL013 02051000
         BNL   *+6                                                      02052000
         LR    R4,R10                                           DSKL013 02053000
*     END;                          /*                       #Y30SSSG*/ 02054000
*   ELSE                                                           0538 02055000
*     DCONV=AMDLRECL+DRECOVHD;      /* GET MAXIMUM RCD       #Y30SSSG   02056000
*                                      SIZE PLUS OVHD        #Y30SSSG*/ 02057000
*                                                                  0538 02058000
         B     @RC00534                                            0538 02059000
@RF00534 LA    R4,7                                             DSKL013 02060000
         AL    R4,AMDLRECL(,R2)                                 DSKL013 02061000
*   /*****************************************************************/ 02062000
*   /*                                                               */ 02063000
*   /* GET SMALLEST MULTIPLE OF 512                          #Y30SSSG*/ 02064000
*   /*                                                               */ 02065000
*   /*****************************************************************/ 02066000
*                                                                  0539 02067000
*Z039DCIM:                                                         0539 02068000
*   CALL IGGPDCIM;                  /* CONVERT DCONV         #Y30SSSG*/ 02069000
@RC00534 DS    0H                                                  0539 02070000
         BAL   R14,IGGPDCIM                                     DSKL013 02071000
*   AMDCINV=DCONV;                  /* SET MIN CI SIZE       #Y30SSSG*/ 02072000
*                                                                  0540 02073000
         ST    R4,AMDCINV(,R2)                                  DSKL013 02074000
*   /*****************************************************************/ 02075000
*   /*                                                               */ 02076000
*   /* CHECK IF CI SIZE PROCESSING SHOULD CONTINE OR         #Y30SSSG*/ 02077000
*   /* DEFAULT AND EXIT.                                     #Y30SSSG*/ 02078000
*   /*                                                               */ 02079000
*   /*****************************************************************/ 02080000
*                                                                  0541 02081000
*   IF AMDCINV=>CILIMIT THEN        /* CI SIZE EQ OR GT      #Y30SSSG   02082000
*                                      HIGH LIMIT            #Y30SSSG*/ 02083000
         L     R5,AMDCINV(,R2)                                  DSKL013 02084000
         L     R10,CCAURAB(,R11)                                DSKL013 02085000
         L     R10,CCACPE1(,R10)                                DSKL013 02086000
         C     R5,CILIMIT(,R10)                                 DSKL013 02087000
         BL    @RF00541                                            0541 02088000
*     DO;                           /* YES                   #Y30SSSG*/ 02089000
*       IF AMDSPAN=OFF THEN         /* NOT SPANNED           #Y30SSSG*/ 02090000
         TM    AMDSPAN(R2),B'00000001'                          DSKL013 02091000
         BNZ   @RF00543                                            0543 02092000
*         CALL EXIT;                /* GIVE CALLER DEFAULT   #Y30SSSG   02093000
*                                      OF CI SIZE THAT WILL  #Y30SSSG   02094000
*                                      CONTAIN LARGEST REC   #Y30SSSG*/ 02095000
         BAL   R14,EXIT                                         DSKL013 02096000
*       ELSE                        /* SPANNED               #Y30SSSG*/ 02097000
*         DO;                       /* SET CISIZE TO TRACKSIZE     0545 02098000
*                                                            @ZA05929*/ 02099000
         B     @RC00543                                            0545 02100000
@RF00543 DS    0H                                                  0546 02101000
*           IF AMDCINV<=DCIMAXSZ THEN/* IF CI SIZE LT        #Y30SSSG   02102000
*                                      OR EQ TO MAX CISIZE   #Y30SSSG   02103000
*                                      THEN SET CISIZE TO    #Y30SSSG   02104000
*                                      CONTAIN AVE RCDSIZE   #Y30SSSG*/ 02105000
         L     R5,AMDCINV(,R2)                                  DSKL013 02106000
         C     R5,@CF03331                                      DSKL013 02107000
         BH    @RF00546                                            0546 02108000
*             CALL EXIT;            /* RETURN                #Y30SSSG*/ 02109000
         BAL   R14,EXIT                                         DSKL013 02110000
*           ELSE                    /* CI SIZE EXCEEDS MAX   #Y30SSSG*/ 02111000
*             DO;                   /*                       #Y30SSSG*/ 02112000
         B     @RC00546                                            0548 02113000
@RF00546 DS    0H                                                  0549 02114000
*               CMDCONV=MBN2314;    /* SET INPUT CISIZE      @ZA05929*/ 02115000
         L     R10,CCACMSWA(,R11)                               DSKL013 02116000
         MVC   CMDCONV(4,R10),@CF03335                          DSKL013 02117000
*               DCWABASE=ADDR(CMSDSPTB(1));/* SET ADDR OF    @ZA05929   02118000
*                                      DATA ELEMENT OF DEV   @ZA05929   02119000
*                                      CHAR ARRAY            @ZA05929*/ 02120000
*                                                                  0550 02121000
         LA    R4,CMSDSPTB(,R10)                                DSKL013 02122000
*               /*****************************************************/ 02123000
*               /*                                                   */ 02124000
*               /* CALL TO MODULE IGG0CLB0                           */ 02125000
*               /*                                                   */ 02126000
*               /*****************************************************/ 02127000
*                                                                  0551 02128000
*Z040DPBI:                                                         0551 02129000
*               CALL IGGPDPBI;      /* GET ARRAY ELEMENT     @ZA05929*/ 02130000
         L     R15,@CV00038                                     DSKL013 02131000
         BALR  R14,R15                                          DSKL013 02132000
*               AMDCINV=BLKV(CMPBI);/* SET CI SIZE           @Y30SSSG*/ 02133000
         L     R5,CCACMSWA(,R11)                                DSKL013 02134000
         L     R10,CMPBI(,R5)                                   DSKL013 02135000
         SLA   R10,2                                            DSKL013 02136000
         L     R5,CCAURAB(,R11)                                 DSKL013 02137000
         L     R5,CCACPE1(,R5)                                  DSKL013 02138000
         L     R10,BLKV-4(R10,R5)                               DSKL013 02139000
         ST    R10,AMDCINV(,R2)                                 DSKL013 02140000
*               CALL EXIT;          /* RETURN TO CALLER      @Y30SSSG*/ 02141000
         BAL   R14,EXIT                                         DSKL013 02142000
*             END;                  /*                       @Y30SSSG*/ 02143000
*         END;                      /*                       @Y30SSSG*/ 02144000
@RC00546 DS    0H                                                  0556 02145000
*     END;                          /*                       @Y30SSSG*/ 02146000
@RC00543 DS    0H                                                  0557 02147000
*   IF DCONV>TWOK THEN              /* AVE RCD SIZE GT 2K    @Y30SSSG*/ 02148000
@RF00541 CH    R4,@CH03333                                      DSKL013 02149000
         BNH   @RF00557                                            0557 02150000
*     DELTA=CTGFVDCH->CTGFVLRS->CTGFLPT(1)->LRECL+THREE;/* YES,SET 0558 02151000
*                                      DELTA TO AVE          @Y30SSSG   02152000
*                                      RECORD SIZE PLUS OVHD @Y30SSSG*/ 02153000
         L     R5,CCAURAB(,R11)                                 DSKL013 02154000
         L     R10,CCACPE1(,R5)                                 DSKL013 02155000
         L     R5,CCACPL(,R11)                                  DSKL013 02156000
         L     R5,CTGFVT(,R5)                                   DSKL013 02157000
         L     R5,CTGFVDCH(,R5)                                 DSKL013 02158000
         L     R5,CTGFVLRS(,R5)                                 DSKL013 02159000
         L     R5,CTGFLPT(,R5)                                  DSKL013 02160000
         LA    R6,3                                             DSKL013 02161000
         AL    R6,LRECL(,R5)                                    DSKL013 02162000
         ST    R6,DELTA(,R10)                                   DSKL013 02163000
*   ELSE                            /* AVE RCD SIZE LT 2K    @Y30SSSG*/ 02164000
*     DELTA=MNCIS;                  /* SET DELTA TO 512      @Y30SSSG*/ 02165000
         B     @RC00557                                            0559 02166000
@RF00557 L     R10,CCAURAB(,R11)                                DSKL013 02167000
         L     R5,CCACPE1(,R10)                                 DSKL013 02168000
         MVC   DELTA(4,R5),@CF01078                             DSKL013 02169000
*   ALRECL=CTGFVDCH->CTGFVLRS->CTGFLPT(1)->LRECL;/*          @Y30SSSG   02170000
*                                      GET AVE RCD SIZE      @Y30SSSG*/ 02171000
*                                                                  0560 02172000
@RC00557 L     R10,CCAURAB(,R11)                                DSKL013 02173000
         L     R5,CCACPE1(,R10)                                 DSKL013 02174000
         L     R10,CCACPL(,R11)                                 DSKL013 02175000
         L     R10,CTGFVT(,R10)                                 DSKL013 02176000
         L     R10,CTGFVDCH(,R10)                               DSKL013 02177000
         L     R10,CTGFVLRS(,R10)                               DSKL013 02178000
         L     R10,CTGFLPT(,R10)                                DSKL013 02179000
         MVC   ALRECL(4,R5),LRECL(R10)                          DSKL013 02180000
*   /*****************************************************************/ 02181000
*   /*                                                               */ 02182000
*   /* EXECUTE MAIN DO LOOP TO INSERT AN ENTRY INTO THE CI TABLE     */ 02183000
*   /*                                                               */ 02184000
*   /*****************************************************************/ 02185000
*                                                                  0561 02186000
*   J=N;                            /* ZERO INDEX VALUE      @Y30SSSG*/ 02187000
         SLR   R3,R3                                            DSKL013 02188000
*   DO WHILE J<CILIMIT/MPB;         /* BUILD TABLE UNTIL     @Y30SSSG   02189000
*                                      LIMIT IS REACHED      @Y30SSSG*/ 02190000
         B     @DE00562                                            0562 02191000
@DL00562 DS    0H                                                  0563 02192000
*     CMDCONV=AMDCINV;              /* SET INPUT CISIZE      @ZA05929*/ 02193000
         L     R5,CCACMSWA(,R11)                                DSKL013 02194000
         MVC   CMDCONV(4,R5),AMDCINV(R2)                        DSKL013 02195000
*     DCWABASE=ADDR(CMSDSPTB(1));   /* SET ADDR OF           @ZA05929   02196000
*                                      DATA ELEMENT OF DEV   @ZA05929   02197000
*                                      CHAR ARRAY            @ZA05929*/ 02198000
*                                                                  0564 02199000
         LA    R4,CMSDSPTB(,R5)                                 DSKL013 02200000
*     /***************************************************************/ 02201000
*     /*                                                             */ 02202000
*     /* CALL TO MODULE IGG0CLB0                                     */ 02203000
*     /*                                                             */ 02204000
*     /***************************************************************/ 02205000
*                                                                  0565 02206000
*Z041DPBI:                                                         0565 02207000
*     CALL IGGPDPBI;                /* GET ARRAY ELEMENT     @ZA05929*/ 02208000
*                                                                  0565 02209000
         L     R15,@CV00038                                     DSKL013 02210000
         BALR  R14,R15                                          DSKL013 02211000
*     /***************************************************************/ 02212000
*     /*                                                             */ 02213000
*     /* COMPUTE USEABLE CI SPACE BY DIVIDING CI SIZE        @Y30SSSG*/ 02214000
*     /* MINUS 4 BY AVERAGE RECORD SIZE PLUS 3 AND           @Y30SSSG*/ 02215000
*     /* MULTIPLYING THE RESULT WITHOUT REMAINDER BY         @Y30SSSG*/ 02216000
*     /* AVERAGE RECORD SIZE PLUS 3.                         @Y30SSSG*/ 02217000
*     /*                                                             */ 02218000
*     /***************************************************************/ 02219000
*                                                                  0566 02220000
*     UCISPACE=(ALRECL+THREE)*((AMDCINV-FOUR)/(ALRECL+THREE));/*   0566 02221000
*                                      COMPUTE USEABLE       @Y30SSSG   02222000
*                                      CI SPACE              @Y30SSSG*/ 02223000
         L     R5,CCAURAB(,R11)                                 DSKL013 02224000
         L     R10,CCACPE1(,R5)                                 DSKL013 02225000
         LA    R5,3                                             DSKL013 02226000
         AL    R5,ALRECL(,R10)                                  DSKL013 02227000
         L     R6,AMDCINV(,R2)                                  DSKL013 02228000
         LR    R7,R6                                            DSKL013 02229000
         SH    R7,@CH00062                                      DSKL013 02230000
         LR    R0,R7                                            DSKL013 02230010
         SRDA  R0,32                                            DSKL013 02231000
         DR    R0,R5                                            DSKL013 02232000
         LR    R9,R5                                            DSKL013 02233000
         MR    R8,R1                                            DSKL013 02234000
         ST    R9,UCISPACE(,R10)                                DSKL013 02235000
*     J=AMDCINV/MPB;                /* COMPUTE INDEX IN CI   @Y30SSSG   02236000
*                                      TABLE BASED ON CISIZE @Y30SSSG*/ 02237000
*                                                                  0567 02238000
         LR    R14,R6                                           DSKL013 02240000
         SRDA  R14,32                                           DSKL013 02241000
         D     R14,@CF01078                                     DSKL013 02242000
         LR    R3,R15                                           DSKL013 02243000
*     /***************************************************************/ 02244000
*     /*                                                             */ 02245000
*     /* COMPUTE USEABLE CI SPACE PER TRACK BY               @Y30SSSG*/ 02246000
*     /* MULTIPLYING USEABLE CI SPACE TIMES PHYSICAL         @Y30SSSG*/ 02247000
*     /* BLOCKS PER TRACK TIMES PHYSICAL BLOCKSIZE AND       @Y30SSSG*/ 02248000
*     /* DIVIDING THE RESULT BY CI SIZE.                     @Y30SSSG*/ 02249000
*     /*                                                             */ 02250000
*     /***************************************************************/ 02251000
*                                                                  0568 02252000
*     CISPPTK(J)=UCISPACE*DSPHYBPT(CMPBI)*PHYBLKS(CMPBI)/AMDCINV;/*     02253000
*                                      COMPUTE USEABLE CI    @Y30SSSG   02254000
*                                      SPACE PER TRACK       @Y30SSSG*/ 02255000
         LR    R5,R3                                            DSKL013 02256000
         SLA   R5,3                                             DSKL013 02257000
         L     R1,CCACMSWA(,R11)                                DSKL013 02258000
         L     R8,CMPBI(,R1)                                    DSKL013 02259000
         ALR   R8,R8                                            DSKL013 02260000
         L     R1,DCWREG(,R10)                                  DSKL013 02261000
         MH    R9,DSPHYBPT-2(R8,R1)                             DSKL013 02262000
         LH    R8,PHYBLKS-2(R8)                                 DSKL013 02263000
         LR    R1,R9                                            DSKL013 02263010
         MR    R0,R8                                            DSKL013 02264000
         LR    R14,R1                                           DSKL013 02265000
         SRDA  R14,32                                           DSKL013 02266000
         DR    R14,R6                                           DSKL013 02267000
         ST    R15,CISPPTK-8(R5,R10)                            DSKL013 02268000
*     CIBLKSZ(J)=PHYBLKS(CMPBI);    /* SAVE BLOCKSIZE USED   @Y30SSSG*/ 02269000
*                                                                  0569 02270000
         ST    R8,CIBLKSZ-8(R5,R10)                             DSKL013 02271000
*     /***************************************************************/ 02272000
*     /*                                                             */ 02273000
*     /* CHECK IF CI SIZE HAS REACHED OR EXCEEDED UPPER LIMIT        */ 02274000
*     /*                                                             */ 02275000
*     /***************************************************************/ 02276000
*                                                                  0570 02277000
*     IF AMDCINV^=CILIMIT THEN      /* CI SIZE EQUAL UPPER LIMIT     */ 02278000
         L     R7,CILIMIT(,R10)                                 DSKL013 02279000
         CR    R6,R7                                            DSKL013 02280000
         BE    @RF00570                                            0570 02281000
*       DO;                         /* NO                    @Y30SSSG*/ 02282000
*         IF AMDCINV>CILIMIT THEN   /* CI SIZE EXCEED UPPER LIMIT    */ 02283000
         CR    R6,R7                                            DSKL013 02284000
         BNH   @RF00572                                            0572 02285000
*           DO;                     /* YES                   @Y30SSSG*/ 02286000
*             CISPPTK(J)=N;         /* ZERO ENTRY            @Y30SSSG*/ 02287000
         SLR   R8,R8                                            DSKL013 02288000
         ST    R8,CISPPTK-8(R5,R10)                             DSKL013 02289000
*           END;                    /*                       @Y30SSSG*/ 02290000
*         ELSE                                                     0576 02291000
*           ;                       /* CI SIZE OK            @Y30SSSG*/ 02292000
*                                                                  0576 02293000
@RF00572 DS    0H                                                  0577 02294000
*         /***********************************************************/ 02295000
*         /*                                                         */ 02296000
*         /* BUMP CI SIZE AND CHECK SIZE. IF LESS THAN 8K USE DELTA, */ 02297000
*         /* IF 8K THEN SET DELTA TO 2K AND CONTINUE                 */ 02298000
*         /*                                                         */ 02299000
*         /***********************************************************/ 02300000
*                                                                  0577 02301000
*         IF AMDCINV+DELTA<AK THEN  /* CI SIZE PLUS DELTA LT 8K      */ 02302000
         L     R10,CCAURAB(,R11)                                DSKL013 02303000
         L     R5,CCACPE1(,R10)                                 DSKL013 02304000
         L     R10,AMDCINV(,R2)                                 DSKL013 02305000
         AL    R10,DELTA(,R5)                                   DSKL013 02306000
         CH    R10,@CH03352                                     DSKL013 02307000
         BNL   @RF00577                                            0577 02308000
*           DO;                     /* YES                   @Y30SSSG*/ 02309000
*             DCONV=AMDCINV+DELTA;  /* BUMP BY DELTA         @Y30SSSG*/ 02310000
         LR    R4,R10                                           DSKL013 02311000
*Z042DCIM:                                                         0580 02312000
*             CALL IGGPDCIM;        /* FORCE TO MULTIPLE OF 512      */ 02313000
         BAL   R14,IGGPDCIM                                     DSKL013 02314000
*             AMDCINV=DCONV;        /* SET AMDCINV           @Y30SSSG*/ 02315000
         ST    R4,AMDCINV(,R2)                                  DSKL013 02316000
*           END;                    /*                       @Y30SSSG*/ 02317000
*         ELSE                      /* CI SIZE PLUS DELTA EQ OR GT 8K*/ 02318000
*           DO;                     /*                       @Y30SSSG*/ 02319000
         B     @RC00577                                            0583 02320000
@RF00577 DS    0H                                                  0584 02321000
*             IF AMDCINV>=AK THEN   /* CI SIZE >= 8K THEN    @ZA24340*/ 02322000
         L     R5,AMDCINV(,R2)                                  DSKL013 02323000
         CH    R5,@CH03352                                      DSKL013 02324000
         BL    @RF00584                                            0584 02325000
*               DELTA=TWOK;         /* SET DELTA TO 2K       @ZA24340*/ 02326000
         L     R10,CCAURAB(,R11)                                DSKL013 02327000
         L     R5,CCACPE1(,R10)                                 DSKL013 02328000
         MVC   DELTA(4,R5),@CF03333                             DSKL013 02329000
*             ELSE                                                 0586 02330000
*               ;                   /*                       @Y30SSSG*/ 02331000
@RF00584 DS    0H                                                  0587 02332000
*             IF AMDCINV<AK THEN    /* IF CI SIZE LESS THAN 8K THEN  */ 02333000
         LH    R10,@CH03352                                     DSKL013 02334000
         C     R10,AMDCINV(,R2)                                 DSKL013 02335000
         BNH   @RF00587                                            0587 02336000
*               AMDCINV=AK;         /* SET IT TO 8K          @Y30SSSG*/ 02337000
         ST    R10,AMDCINV(,R2)                                 DSKL013 02338000
*             ELSE                  /* CI SIZE GT 8K         @Y30SSSG*/ 02339000
*               AMDCINV=AMDCINV+DELTA;/* INCR CI SIZE BY 2K          */ 02340000
         B     @RC00587                                            0589 02341000
@RF00587 L     R5,CCAURAB(,R11)                                 DSKL013 02342000
         L     R10,CCACPE1(,R5)                                 DSKL013 02343000
         L     R5,AMDCINV(,R2)                                  DSKL013 02344000
         AL    R5,DELTA(,R10)                                   DSKL013 02345000
         ST    R5,AMDCINV(,R2)                                  DSKL013 02346000
*           END;                    /*                       @Y30SSSG*/ 02347000
@RC00587 DS    0H                                                  0591 02348000
*       END;                        /*                       @Y30SSSG*/ 02349000
@RC00577 DS    0H                                                  0592 02350000
*   END;                            /* END OF MAJOR LOOP     @Y30SSSG*/ 02351000
*                                                                  0592 02352000
@RF00570 DS    0H                                                  0592 02353000
@DE00562 L     R10,CCAURAB(,R11)                                DSKL013 02354000
         L     R5,CCACPE1(,R10)                                 DSKL013 02355000
         L     R0,CILIMIT(,R5)                                  DSKL013 02356000
         SRDA  R0,32                                            DSKL013 02357000
         D     R0,@CF01078                                      DSKL013 02358000
         CR    R3,R1                                            DSKL013 02359000
         BL    @DL00562                                            0592 02360000
*   /*****************************************************************/ 02361000
*   /*                                                               */ 02362000
*   /* GET INDEX OF LARGEST CI SPACE PER TRACK VALUE         @Y30SSSG*/ 02363000
*   /*                                                               */ 02364000
*   /*****************************************************************/ 02365000
*                                                                  0593 02366000
*   CMPBI=ONE;                      /* SET FIRST INDEX       @Y30SSSG*/ 02367000
         L     R10,CCACMSWA(,R11)                               DSKL013 02368000
         MVC   CMPBI(4,R10),@CF00041                            DSKL013 02369000
*   CMPBIX=TWO;                     /* SET SECOND INDEX      @Y30SSSG*/ 02370000
         MVC   CMPBIX(4,R10),@CF00059                           DSKL013 02371000
*   DO UNTIL CMPBIX>DIM(CILIST);    /* LOOP TO PROCESS       @ZA32672*/ 02372000
@DL00595 DS    0H                                                  0596 02373000
*     IF CISPPTK(CMPBI)<CISPPTK(CMPBIX) THEN/* IF 2ND VAL GT         */ 02374000
         L     R5,CCACMSWA(,R11)                                DSKL013 02375000
         L     R10,CMPBI(,R5)                                   DSKL013 02376000
         SLA   R10,3                                            DSKL013 02377000
         L     R1,CCAURAB(,R11)                                 DSKL013 02378000
         L     R6,CCACPE1(,R1)                                  DSKL013 02379000
         L     R7,CMPBIX(,R5)                                   DSKL013 02380000
         LR    R8,R7                                            DSKL013 02381000
         SLA   R8,3                                             DSKL013 02382000
         L     R10,CISPPTK-8(R10,R6)                            DSKL013 02383000
         C     R10,CISPPTK-8(R8,R6)                             DSKL013 02384000
         BNL   @RF00596                                            0596 02385000
*       CMPBI=CMPBIX;               /* FIRST VALUE THEN UPDATE 1ST 0597 02386000
*                                      INDEX WITH VALUE OF SECOND    */ 02387000
         ST    R7,CMPBI(,R5)                                    DSKL013 02388000
*     ELSE                                                         0598 02389000
*       ;                           /* OTHERWISE INCR INDEX TO       */ 02390000
@RF00596 DS    0H                                                  0599 02391000
*     CMPBIX=CMPBIX+ONE;            /* COMPARE NEXT VALUE    @Y30SSSG*/ 02392000
         L     R5,CCACMSWA(,R11)                                DSKL013 02393000
         LA    R10,1                                            DSKL013 02394000
         AL    R10,CMPBIX(,R5)                                  DSKL013 02395000
         ST    R10,CMPBIX(,R5)                                  DSKL013 02396000
         CH    R10,A000EAA                                      DSKL013 02396010
         BNH   @DL00595                                         DSKL013 02396020
*   END;                            /*                       @Y30SSSG*/ 02397000
*                                                                  0600 02398000
         L     R5,CCACMSWA(,R11)                                DSKL013 02399000
*   /*****************************************************************/ 02403000
*   /*                                                               */ 02404000
*   /* SET BEST CI SIZE AND BLOCKSIZE FOR DEVICE AND EXIT            */ 02405000
*   /*                                                               */ 02406000
*   /*****************************************************************/ 02407000
*                                                                  0601 02408000
*   AMDCINV=CMPBI*MPB;              /* SET BEST CI SIZE      @Y30SSSG*/ 02409000
         L     R10,CMPBI(,R5)                                   DSKL013 02410000
         LR    R14,R10                                          DSKL013 02411000
         SLA   R14,9                                            DSKL013 02412000
         ST    R14,AMDCINV(,R2)                                 DSKL013 02413000
*   CMPHYBLK(1)=CIBLKSZ(CMPBI);     /* SET BLKSIZE FOR       @Y30SSSG   02414000
*                                      SELECTED CI & DEVICE  @Y30SSSG*/ 02415000
         SLA   R10,3                                            DSKL013 02416000
         L     R1,CCAURAB(,R11)                                 DSKL013 02417000
         L     R1,CCACPE1(,R1)                                  DSKL013 02418000
         L     R10,CIBLKSZ-8(R10,R1)                            DSKL013 02419000
         ST    R10,CMPHYBLK(,R5)                                DSKL013 02420000
*   RESPECIFY                                                      0603 02421000
*     DSPTBL BASED(DCWABASE);       /* BASE DEV CHAR         @Y30SSSG*/ 02422000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 02423000
         BAL   R14,EXIT                                         DSKL013 02424000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 02425000
         DC    0F'0'                                            DSKL013 02426000
*   GEN(DC CL8'IGGPDCPT');          /* NAME OF FOLLOWING PROCEDURE   */ 02427000
         DC    CL8'IGGPDCPT'                                    DSKL013 02428000
*   END;                            /* END OF INNER PROCEDURE        */ 02429000
         BR    R14                                              DSKL013 02432000
*                                                                  0609 02436000
*/********************************************************************/ 02437000
*/*                                                                  */ 02438000
*/*        IGGPDCPT  -  PROCEDURE  INTERNALLY  CALLED  NESTED        */ 02439000
*/*                                                                  */ 02440000
*/********************************************************************/ 02441000
*                                                                  0609 02442000
*IGGPDCPT:                                                         0609 02443000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 02444000
IGGPDCPT DS    0H                                                  0610 02446000
*Z043:                              /* LABEL FOR PROCEDURE TRACKING  */ 02447000
*Z043DCPT:                          /* LABEL FOR PROCEDURE TRACKING  */ 02448000
*   RFY                                                            0610 02449000
*    (R5,                                                          0610 02450000
*     R6,                                                          0610 02451000
*     R7,                                                          0610 02452000
*     R8,                                                          0610 02453000
*     R9,                                                          0610 02454000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 02455000
*   RFY                                                            0611 02458000
*    (R2,                                                          0611 02459000
*     R3,                                                          0611 02460000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 02461000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 02462000
         STM   R12,R14,12(R13)                                  DSKL013 02463000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 02464000
*                                                                  0613 02465000
         LA    R13,12(R13)                                      DSKL013 02466000
*   /*****************************************************************/ 02467000
*   /*                                                               */ 02468000
*   /*                                                       @Y30SSSG*/ 02469000
*   /*                                                       @Y30SSSG*/ 02470000
*   /* CONVERT VALUE TO A POWER OF TWO EQUAL OR GREATER THAN THE     */ 02471000
*   /* MINIMUM PHYSICAL BLOCK SIZE INPUT VALUE IN DCONV OUTPUT VALUE */ 02472000
*   /* IN DCONV                                                      */ 02473000
*   /*                                                               */ 02474000
*   /*****************************************************************/ 02475000
*                                                                  0614 02476000
*   CMPROC=ON;                      /* ALLOW PROCESSING TO BEGIN     */ 02477000
         L     R5,CCACMSWA(,R11)                                DSKL013 02478000
         OI    CMPROC(R5),B'00100000'                           DSKL013 02479000
*   CMPOT=ONE;                      /* SET INITIAL MULTIPLIER VALUE  */ 02480000
         MVC   CMPOT(4,R5),@CF00041                             DSKL013 02481000
*   DO WHILE CMPROC=ON;                                            0616 02482000
         B     @DE00616                                            0616 02483000
@DL00616 DS    0H                                                  0617 02484000
*     IF DCONV<=MPB*CMPOT THEN      /* MINIMUM PHYSICAL BLOCK SIZE 0617 02485000
*                                      MULTIPLIED BY A POWER OF 2  0617 02486000
*                                      EQUAL OR JUST GREATER FOUND   */ 02487000
         L     R10,CCACMSWA(,R11)                               DSKL013 02488000
         L     R5,CMPOT(,R10)                                   DSKL013 02489000
         SLA   R5,9                                             DSKL013 02490000
         CR    R4,R5                                            DSKL013 02491000
         BH    @RF00617                                            0617 02492000
*       DO;                                                        0618 02493000
*         DCONV=MPB*CMPOT;                                         0619 02494000
         LR    R4,R5                                            DSKL013 02495000
*         CMPROC=OFF;               /* DISCONTINUE PROCESSING - VALUE   02496000
*                                      FOUND                         */ 02497000
         NI    CMPROC(R10),B'11011111'                          DSKL013 02498000
*       END;                                                       0621 02499000
*     ELSE                                                         0622 02500000
*       CMPOT=CMPOT*TWO;            /* SET MULTIPLIER TO NEXT POWER     02501000
*                                      OF 2                          */ 02502000
         B     @RC00617                                            0622 02503000
@RF00617 L     R10,CCACMSWA(,R11)                               DSKL013 02504000
         L     R5,CMPOT(,R10)                                   DSKL013 02505000
         ALR   R5,R5                                            DSKL013 02506000
         ST    R5,CMPOT(,R10)                                   DSKL013 02507000
*   END;                                                           0623 02508000
*                                                                  0623 02509000
@RC00617 DS    0H                                                  0623 02510000
@DE00616 L     R10,CCACMSWA(,R11)                               DSKL013 02511000
         TM    CMPROC(R10),B'00100000'                          DSKL013 02512000
         BO    @DL00616                                            0623 02513000
*   /*****************************************************************/ 02514000
*   /*                                                               */ 02515000
*   /* END OF IGGPDCPT                                               */ 02516000
*   /*                                                               */ 02517000
*   /*****************************************************************/ 02518000
*                                                                  0624 02519000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 02520000
         BAL   R14,EXIT                                         DSKL013 02521000
*   END;                            /* END OF INNER PROCEDURE        */ 02522000
         BR    R14                                              DSKL013 02525000
*                                                                  0627 02529000
*/********************************************************************/ 02530000
*/*                                                                  */ 02531000
*/*         RETURN-TO-CALLER  PROCEDURE-EXITING  SUBFUNCTION         */ 02532000
*/*                                                                  */ 02533000
*/********************************************************************/ 02534000
*                                                                  0627 02535000
*EXIT:                                                             0627 02536000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 02537000
EXIT     DS    0H                                                  0628 02539000
*   GEN(LM 12,14,0(13));            /* RESTORE REGISTERS OF CALLER   */ 02540000
         LM    R12,R14,0(R13)                                   DSKL013 02541000
*   GEN(MVI 12(13),255);            /* MARK END OF PDL               */ 02542000
         MVI   12(R13),255                                      DSKL013 02543000
*   GEN(BR 14);                     /* RETURN TO CALLER              */ 02544000
         BR    R14                                              DSKL013 02545000
*PATCH:                                                            0631 02546000
*   GEN(DC (12+((*+139-@MAINENT)/140))A(0));/* PATCH AREA            */ 02547000
PATCH    DC    (12+((*+139-@MAINENT)/140))A(0)                  DSKL013 02548000
*   END;                            /* END OF EXIT PROCEDURE         */ 02549000
         L     R15,A000F0C                                      DSKL013 02552010
         BALR  R14,R15                                          DSKL013 02552020
         BR    R14                                              DSKL013 02552030
*   END                             /*                       @Y30SSSG*/ 02553000
*                                                                  0633 02554000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 02555000
*/*%INCLUDE SYSLIB  (IGGMCDCL)                                       */ 02556000
*/*%INCLUDE SYSLIB  (IGGMCTRC)                                       */ 02557000
*/*%INCLUDE SYSLIB  (IGGCCA  )                                       */ 02558000
*/*%INCLUDE SYSLIB  (IEZCTGPL)                                       */ 02559000
*/*%INCLUDE SYSLIB  (IEZCTGFL)                                       */ 02560000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 02561000
*/*%INCLUDE SYSLIB  (IKJTCB  )                                       */ 02562000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 02563000
*/*%INCLUDE SYSLIB  (IFGACB  )                                       */ 02564000
*/*%INCLUDE SYSLIB  (AMCBS   )                                       */ 02565000
*/*%INCLUDE SYSLIB  (IGGCAXWA)                                       */ 02566000
*/*%INCLUDE SYSLIB  (IEZCTGFV)                                       */ 02567000
*/*%INCLUDE SYSLIB  (IEZCTGWA)                                       */ 02568000
*/*%INCLUDE SYSLIB  (IEZCTGVL)                                       */ 02569000
*/*%INCLUDE SYSLIB  (IEZCTGCV)                                       */ 02570000
*/*%INCLUDE SYSLIB  (ICHACHKL)                                       */ 02571000
*/*%INCLUDE SYSLIB  (ICHRDDFL)                                       */ 02572000
*/*%INCLUDE SYSLIB  (IGGMCMDM)                                       */ 02573000
*/*%INCLUDE SYSLIB  (IGGMCMWA)                                       */ 02574000
*/*%INCLUDE SYSLIB  (IDAAMDSB)                                       */ 02575000
*/*%INCLUDE SYSLIB  (IGGMVEDC)                                       */ 02576000
*                                                                  0633 02577000
*       ;                                                          0633 02578000
@DATA    DC    0H'0'                                            DSKL013 02582000
@CH00421 DC    H'3'                                                     02583000
@CH00062 DC    H'4'                                                     02584000
@CH00260 DC    H'10'                                                    02585000
A000EAA  DC    H'64'                                            DSKL013 02586000
@CH03352 DC    H'8192'                                                  02587000
@CH03489 DC    H'-2047'                                                 02588000
@CH03488 DC    H'-511'                                                  02589000
@CF00041 DC    F'1'                                                     02594000
@CH00041 EQU   @CF00041+2                                               02595000
@CF00059 DC    F'2'                                                     02596000
@CF01078 DC    F'512'                                                   02597000
@CF03333 DC    F'2048'                                                  02598000
@CH03333 EQU   @CF03333+2                                               02599000
@CF03335 DC    F'4096'                                                  02600000
@CH03335 EQU   @CF03335+2                                               02601000
@CF03331 DC    F'32768'                                                 02602000
@CF03484 DC    F'-1025048480'                                           02603000
@CF03479 DC    F'-1025048384'                                           02604000
@CF03480 DC    F'-1025048380'                                           02605000
@CF03481 DC    F'-1025048376'                                           02606000
@CF03482 DC    F'-1025048372'                                           02607000
@CF03483 DC    F'-1025048368'                                           02608000
@CF03473 DC    F'-1025048328'                                           02609000
@CF03475 DC    F'-1025047896'                                           02610000
@CF03472 DC    F'-1025047312'                                           02611000
@CF03478 DC    F'-1025039732'                                           02612000
@CF03487 DC    F'-1025037172'                                           02613000
@DATD    DSECT                                                          02614000
@TS00001 DS    CL1                                                      02616000
EFFBLKS  DS    4H                                                       02618000
         DS    0D                                               DSKL013 02618010
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                02619000
@ENDDATD EQU   *                                                        02620000
IGG0CLBX CSECT                                                          02621000
         DC    0F'0'                                            DSKL013 02622000
@SIZDATD DC    AL1(0)                                                   02623000
         DC    AL3(@ENDDATD-@DATD)                                      02624000
@CV00036 DC    V(IGGPGET)                                               02625000
@CV00037 DC    V(IGGPDCCO)                                              02626000
@CV00038 DC    V(IGGPDPBI)                                              02627000
@CV00039 DC    V(IGGPITER)                                              02628000
A000F0C  DC    V(IGGPDUMP)                                      DSKL013 02629000
@CB03329 DC    X'30C02008'                                              02630000
@CB03341 DC    X'200A'                                                  02631000
PHYBLKS  DC    H'512'                                                   02632000
         DC    H'1024'                                                  02633000
         DC    H'2048'                                                  02634000
         DC    H'4096'                                                  02635000
         DC    0D'0'                                            DSKL013 02635010
R0       EQU   0                       REGISTER 0               DSKL013 02636000
R1       EQU   1                       REGISTER 1               DSKL013 02637000
R2       EQU   2                       REGISTER 2               DSKL013 02638000
R3       EQU   3                       REGISTER 3               DSKL013 02639000
R4       EQU   4                       REGISTER 4               DSKL013 02640000
R5       EQU   5                       REGISTER 5               DSKL013 02641000
R6       EQU   6                       REGISTER 6               DSKL013 02642000
R7       EQU   7                       REGISTER 7               DSKL013 02643000
R8       EQU   8                       REGISTER 8               DSKL013 02644000
R9       EQU   9                       REGISTER 9               DSKL013 02645000
R10      EQU   10                      REGISTER 10              DSKL013 02646000
R11      EQU   11                      REGISTER 11              DSKL013 02647000
R12      EQU   12                      REGISTER 12              DSKL013 02648000
R13      EQU   13                      REGISTER 13              DSKL013 02649000
R14      EQU   14                      REGISTER 14              DSKL013 02650000
R15      EQU   15                      REGISTER 15              DSKL013 02651000
IGGCCA   EQU   0                                                        02733000
CCAPROB  EQU   IGGCCA+4                                                 02734000
CCAERRCD EQU   CCAPROB+2                                                02735000
CCAREASN EQU   CCAERRCD                                                 02736000
CCARETRN EQU   CCAERRCD+1                                               02737000
CCACD1   EQU   CCARETRN                                                 02738000
CCAFLG1  EQU   IGGCCA+14                                                02739000
CCAF1KEY EQU   CCAFLG1                                                  02740000
CCAF1KGE EQU   CCAFLG1                                                  02741000
CCAF1UP  EQU   CCAFLG1                                                  02742000
CCAFLG2  EQU   IGGCCA+15                                                02743000
CCAF2COB EQU   CCAFLG2                                                  02744000
CCAFLG3  EQU   IGGCCA+16                                                02745000
CCAFLG4  EQU   IGGCCA+17                                                02746000
CCAFLG5  EQU   IGGCCA+18                                                02747000
CCAFLG6  EQU   IGGCCA+19                                                02748000
CCATCB   EQU   IGGCCA+20                                                02749000
CCALBCYL EQU   CCATCB                                                   02750000
CCARB    EQU   IGGCCA+24                                                02751000
CCACPL   EQU   IGGCCA+28                                                02752000
CCAACB   EQU   IGGCCA+32                                                02753000
CCAURAB  EQU   IGGCCA+40                                                02754000
CCASRCH  EQU   IGGCCA+44                                                02755000
CCASRID  EQU   CCASRCH                                                  02756000
CCARAB0  EQU   IGGCCA+88                                                02757000
CCAR0FLG EQU   CCARAB0                                                  02758000
CCAR0SEG EQU   CCARAB0+8                                                02759000
CCARAB1  EQU   IGGCCA+108                                               02760000
CCAR1FLG EQU   CCARAB1                                                  02761000
CCAR1REC EQU   CCARAB1+4                                        DSKL013 02761010
CCAR1SEG EQU   CCARAB1+8                                                02762000
CCARAB2  EQU   IGGCCA+128                                               02763000
CCAR2FLG EQU   CCARAB2                                                  02764000
CCAR2SEG EQU   CCARAB2+8                                                02765000
CCARAB3  EQU   IGGCCA+148                                               02766000
CCAR3FLG EQU   CCARAB3                                                  02767000
CCAR3SEG EQU   CCARAB3+8                                                02768000
CCARAB4  EQU   IGGCCA+168                                               02769000
CCAR4FLG EQU   CCARAB4                                                  02770000
CCAR4SEG EQU   CCARAB4+8                                                02771000
CCARAB5  EQU   IGGCCA+188                                               02772000
CCAR5FLG EQU   CCARAB5                                                  02773000
CCAR5SEG EQU   CCARAB5+8                                                02774000
CCATIQRN EQU   IGGCCA+212                                               02775000
CCADESA  EQU   IGGCCA+224                                               02776000
CCAEXTDE EQU   CCADESA+4                                                02777000
CCAEXTAD EQU   CCAEXTDE+2                                               02778000
CCAEQDQ  EQU   IGGCCA+280                                               02779000
CCAEDOPT EQU   CCAEQDQ+2                                                02780000
CCAMSSPL EQU   IGGCCA+300                                               02781000
CCACMS   EQU   IGGCCA+316                                               02782000
CCACMSWA EQU   CCACMS                                                   02783000
CCACPE5  EQU   IGGCCA+324                                               02784000
CCACPE6  EQU   IGGCCA+340                                               02785000
CCACPE61 EQU   IGGCCA+344                                               02786000
CCACPE7  EQU   IGGCCA+348                                               02787000
CCAFLPT  EQU   IGGCCA+364                                               02788000
CCADICT  EQU   IGGCCA+372                                               02789000
CCAXCPL  EQU   IGGCCA+376                                               02790000
CCALREL  EQU   IGGCCA+396                                               02791000
CCASN    EQU   IGGCCA+398                                               02792000
CCARBA   EQU   IGGCCA+448                                               02793000
CCACRAVL EQU   CCARBA                                                   02794000
CCACRADT EQU   CCARBA+6                                                 02795000
CCATLNG  EQU   IGGCCA+468                                               02796000
CCAIDPT3 EQU   IGGCCA+480                                               02797000
CCAGRGC  EQU   IGGCCA+493                                               02798000
CCAGRHI  EQU   IGGCCA+494                                               02799000
CCASSEQ  EQU   CCAGRHI                                                  02800000
CCAFLG7  EQU   IGGCCA+552                                               02801000
CCAFLG8  EQU   IGGCCA+553                                               02802000
CCAFLG9  EQU   IGGCCA+554                                               02803000
CCASMFLG EQU   IGGCCA+562                                               02804000
CCASMFG1 EQU   CCASMFLG                                                 02805000
CCASMFUC EQU   CCASMFG1                                                 02806000
CCASMFSR EQU   CCASMFG1                                                 02807000
CCABMINP EQU   IGGCCA+684                                               02808000
CCABMFLG EQU   CCABMINP+6                                               02809000
CCABMOUT EQU   IGGCCA+692                                               02810000
CCABMOFG EQU   CCABMOUT+4                                               02811000
CCATEMPS EQU   IGGCCA+744                                               02812000
CCAMNCAT EQU   IGGCCA+784                                               02813000
CCAMNAT  EQU   CCAMNCAT                                                 02814000
MNATTOP  EQU   CCAMNAT                                                  02815000
MNATFLGS EQU   CCAMNAT+240                                              02816000
CCAARFWA EQU   IGGCCA+1040                                              02817000
ARFGMLEN EQU   CCAARFWA                                                 02818000
CCARVFG1 EQU   IGGCCA+1056                                              02819000
CCAFLG11 EQU   IGGCCA+1059                                              02820000
CCAREGS  EQU   IGGCCA+1060                                              02821000
CCABZSAV EQU   IGGCCA+1408                                              02822000
CCACUMPL EQU   IGGCCA+1412                                              02823000
CCARALSA EQU   IGGCCA+1440                                              02824000
CCAFLG10 EQU   IGGCCA+1444                                              02825000
CCASMFP  EQU   IGGCCA+1480                                              02826000
CCAPROBX EQU   IGGCCA+1484                                              02827000
CCAERCDX EQU   CCAPROBX+2                                               02828000
CCADGDGA EQU   IGGCCA+1488                                              02829000
CCAREQDQ EQU   IGGCCA+1492                                              02830000
CCAREDOP EQU   CCAREQDQ+2                                               02831000
CTGPL    EQU   0                                                        02832000
CTGOPTN1 EQU   CTGPL                                                    02833000
CTGOPTN2 EQU   CTGPL+1                                                  02834000
CTGEXT   EQU   CTGOPTN2                                                 02835000
CTGERASE EQU   CTGOPTN2                                                 02836000
CTGSMF   EQU   CTGERASE                                                 02837000
CTGREL   EQU   CTGSMF                                                   02838000
CTGPURG  EQU   CTGOPTN2                                                 02839000
CTGVMNT  EQU   CTGPURG                                                  02840000
CTGRCATN EQU   CTGVMNT                                                  02841000
CTGSWAP  EQU   CTGRCATN                                                 02842000
CTGOPTN3 EQU   CTGPL+2                                                  02843000
CTGOPTN4 EQU   CTGPL+3                                                  02844000
CTGENT   EQU   CTGPL+4                                                  02845000
CTGFVT   EQU   CTGENT                                                   02846000
CTGCAT   EQU   CTGPL+8                                                  02847000
CTGCVOL  EQU   CTGCAT                                                   02848000
CTGWKA   EQU   CTGPL+12                                                 02849000
CTGDSORG EQU   CTGPL+16                                                 02850000
CTGTYPE  EQU   CTGPL+18                                                 02851000
CTGDDNM  EQU   CTGPL+20                                                 02852000
CTGNEWNM EQU   CTGDDNM                                                  02853000
CTGFBFLG EQU   CTGNEWNM+2                                               02854000
CTGJSCB  EQU   CTGPL+24                                                 02855000
CTGFL    EQU   0                                                        02856000
CTGFLDGC EQU   CTGFL+2                                                  02857000
CTGFLDRE EQU   CTGFL+3                                                  02858000
CTGFLDWA EQU   CTGFL+4                                                  02859000
CTGFLDNM EQU   CTGFL+8                                                  02860000
CTGFLDAT EQU   CTGFL+16                                                 02861000
CTGFLPT  EQU   CTGFLDAT+4                                               02862000
USERWKA  EQU   0                                                        02863000
WKA      EQU   USERWKA+4                                                02864000
ENTNAMES EQU   WKA                                                      02865000
DICTENT  EQU   0                                                        02866000
DICTFLGS EQU   DICTENT                                                  02867000
DIC2ENT  EQU   0                                                        02868000
DIC2FLGS EQU   DIC2ENT                                                  02869000
CCARAB   EQU   0                                                        02870000
CCARABFL EQU   CCARAB                                                   02871000
CCACPE1  EQU   CCARAB+4                                                 02872000
CCACPE2  EQU   CCARAB+8                                                 02873000
CATGOPT  EQU   0                                                        02874000
CATGOCI  EQU   CATGOPT                                                  02875000
CATGOFLG EQU   CATGOCI                                                  02876000
CATGOGC1 EQU   CATGOPT+3                                                02877000
CATGOSEQ EQU   CATGOPT+4                                                02878000
CATRCD   EQU   0                                                        02879000
RCDSECF  EQU   CATRCD+26                                                02880000
NREPLF   EQU   CATRCD+48                                                02881000
REPCNTRL EQU   0                                                        02882000
EXTRCDPT EQU   REPCNTRL                                                 02883000
VARFIELD EQU   0                                                        02884000
CNTRLINF EQU   0                                                        02885000
LENFIX   EQU   CNTRLINF+1                                               02886000
IFGACB   EQU   0                                                        03016000
ACBCOMN  EQU   IFGACB                                                   03017000
ACBLENG  EQU   ACBCOMN+2                                                03018000
ACBLENG2 EQU   ACBLENG                                                  03019000
ACBAMBL  EQU   ACBCOMN+4                                                03020000
ACBJWA   EQU   ACBAMBL                                                  03021000
ACBMACRF EQU   ACBCOMN+12                                               03022000
ACBMACR1 EQU   ACBMACRF                                                 03023000
ACBADR   EQU   ACBMACR1                                                 03024000
ACBCNV   EQU   ACBMACR1                                                 03025000
ACBMACR2 EQU   ACBMACRF+1                                               03026000
ACBBUFPL EQU   ACBCOMN+20                                               03027000
ACBMACR3 EQU   ACBBUFPL                                                 03028000
ACBRECFM EQU   ACBCOMN+24                                               03029000
ACBCCTYP EQU   ACBCOMN+25                                               03030000
ACBOPT   EQU   ACBCOMN+26                                               03031000
ACBDSORG EQU   ACBOPT                                                   03032000
ACBCROPS EQU   ACBDSORG                                                 03033000
ACBDVIND EQU   ACBDSORG                                                 03034000
ACBEXLST EQU   ACBCOMN+36                                               03035000
ACBDDNM  EQU   ACBCOMN+40                                               03036000
ACBAMETH EQU   ACBDDNM+3                                                03037000
ACBOFLGS EQU   ACBCOMN+48                                               03038000
ACBEXFG  EQU   ACBOFLGS                                                 03039000
ACBIOSFG EQU   ACBOFLGS                                                 03040000
ACBINFLG EQU   ACBCOMN+50                                               03041000
ACBINFL1 EQU   ACBINFLG                                                 03042000
ACBVVIC  EQU   ACBINFL1                                                 03043000
ACBINFL2 EQU   ACBINFLG+1                                               03044000
ACBUJFCB EQU   ACBCOMN+52                                               03045000
ACBBLKSZ EQU   ACBCOMN+60                                               03046000
ACBUAPTR EQU   ACBCOMN+64                                               03047000
AMCBS    EQU   0                                                        03048000
CBSCMP   EQU   AMCBS+16                                                 03049000
CBSVSRT  EQU   AMCBS+32                                                 03050000
NOBASE   EQU   0                                                        03051000
IGGCAXWA EQU   0                                                        03052000
CAXFLGS  EQU   IGGCAXWA+8                                               03053000
CAXFLG2  EQU   IGGCAXWA+9                                               03054000
CAXFLG3  EQU   IGGCAXWA+10                                              03055000
CAXCCR   EQU   IGGCAXWA+32                                              03056000
CAXCNAM  EQU   IGGCAXWA+52                                              03057000
CAXOPLST EQU   IGGCAXWA+96                                              03058000
COPTS    EQU   CAXOPLST                                                 03059000
CAXCCA   EQU   IGGCAXWA+104                                             03060000
CAXECB   EQU   IGGCAXWA+120                                             03061000
CAXECBHB EQU   CAXECB                                                   03062000
CAXHRPLW EQU   IGGCAXWA+128                                             03063000
CTGFV    EQU   0                                                        03064000
CTGFVPRO EQU   CTGFV+1                                                  03065000
CTGFVDCH EQU   CTGFV+4                                                  03066000
CTGFVICH EQU   CTGFV+8                                                  03067000
CTGFVIND EQU   CTGFV+16                                                 03068000
CTGFVVLT EQU   CTGFV+40                                                 03069000
CTGFVSPC EQU   CTGFV+52                                                 03070000
CTGFVAMD EQU   CTGFV+56                                                 03071000
CTGFVATR EQU   CTGFV+60                                                 03072000
CTGFVBUF EQU   CTGFV+64                                                 03073000
CTGFVLRS EQU   CTGFV+68                                                 03074000
CTGFVLMT EQU   CTGFV+72                                                 03075000
CTGFVGAT EQU   CTGFV+76                                                 03076000
CTGFVPWD EQU   CTGFV+84                                                 03077000
CTGWA    EQU   0                                                        03078000
CTGWAVL  EQU   CTGWA                                                    03079000
CTGVL    EQU   0                                                        03080000
CTGVLX   EQU   0                                                        03081000
CTGCV    EQU   0                                                        03082000
CTGCVDSN EQU   CTGCV+6                                                  03083000
ACHKLIST EQU   0                                                        03084000
ACHKINSW EQU   ACHKLIST                                                 03085000
ACHKENTW EQU   ACHKLIST+4                                               03086000
ACHKFLG1 EQU   ACHKENTW                                                 03087000
ACHKENT  EQU   ACHKENTW+1                                               03088000
ACHKCLNW EQU   ACHKLIST+8                                               03089000
ACHKFLG2 EQU   ACHKCLNW                                                 03090000
ACHKVOLW EQU   ACHKLIST+12                                              03091000
ACHKFLG3 EQU   ACHKVOLW                                                 03092000
RDDFLIST EQU   0                                                        03093000
RDDFINSW EQU   RDDFLIST                                                 03094000
RDDFENTW EQU   RDDFLIST+4                                               03095000
RDDFFLGS EQU   RDDFENTW                                                 03096000
RDDFOVOL EQU   RDDFLIST+8                                               03097000
MWA      EQU   0                                                        03098000
VLST     EQU   MWA+2                                                    03099000
CVOLIND  EQU   MWA+252                                                  03100000
CATRECRD EQU   0                                                        03101000
ASGO     EQU   1                                                        03102000
PASSGO   EQU   1                                                        03103000
PASSWORD EQU   PASSGO                                                   03104000
USERAREC EQU   PASSGO+50                                                03105000
USERLIST EQU   0                                                        03106000
LTENTRY  EQU   USERLIST+2                                               03107000
LTRETCOD EQU   LTENTRY                                                  03108000
LTVOLSER EQU   LTENTRY+2                                                03109000
SPACEPRM EQU   0                                                        03110000
SPCPRIMQ EQU   SPACEPRM                                                 03111000
SPCSECDQ EQU   SPACEPRM+3                                               03112000
SPCOPTNS EQU   SPACEPRM+6                                               03113000
SPCRQTYP EQU   SPCOPTNS                                                 03114000
CTGDSATR EQU   0                                                        03115000
CTGATR1  EQU   CTGDSATR                                                 03116000
CTGDSUNQ EQU   CTGATR1                                                  03117000
CTGTRKOV EQU   CTGATR1                                                  03118000
CTGATR2  EQU   CTGDSATR+1                                               03119000
RGATTRFL EQU   0                                                        03120000
RGATTR1  EQU   RGATTRFL                                                 03121000
RGATTSG1 EQU   RGATTRFL+1                                               03122000
BUFSIZE  EQU   0                                                        03123000
LRECL    EQU   0                                                        03124000
DEVCHARS EQU   0                                                        03125000
RTDEVUCB EQU   DEVCHARS                                                 03126000
RTCLSTYP EQU   RTDEVUCB+2                                               03127000
RTNOTRKS EQU   DEVCHARS+10                                              03128000
RTTRKSIZ EQU   DEVCHARS+12                                              03129000
RTBOKAB  EQU   DEVCHARS+14                                              03130000
RTBOKNLB EQU   RTBOKAB                                                  03131000
RTBOKLB  EQU   RTBOKAB+1                                                03132000
RTBONK   EQU   DEVCHARS+16                                              03133000
RTDVFLGS EQU   DEVCHARS+17                                              03134000
RTKABFLG EQU   RTDVFLGS                                                 03135000
RTTOLFLG EQU   RTDVFLGS                                                 03136000
RTTOLFCT EQU   DEVCHARS+18                                              03137000
DSPTBL   EQU   0                                                        03138000
DSDEVCHA EQU   DSPTBL                                                   03139000
DSMPHYBS EQU   DSPTBL+20                                                03140000
DSPHYBPT EQU   DSPTBL+22                                                03141000
DSNPHYBS EQU   DSPTBL+30                                                03142000
CMSWA    EQU   0                                                        03143000
CMWFLAGS EQU   CMSWA                                                    03144000
CMPROC   EQU   CMWFLAGS                                                 03145000
CMCISUSE EQU   CMSWA+2                                                  03146000
CMWRKATR EQU   CMCISUSE                                                 03147000
CMCPLFVT EQU   CMSWA+20                                                 03148000
CMNRMEXT EQU   CMSWA+24                                                 03149000
CMLDTFPL EQU   CMNRMEXT                                                 03150000
CMSSEXTS EQU   CMSWA+28                                                 03151000
CMHDTFPL EQU   CMSSEXTS                                                 03152000
CMCANVOL EQU   CMSWA+32                                                 03153000
CMHIXFPL EQU   CMCANVOL                                                 03154000
CMRNGCTR EQU   CMSWA+40                                                 03155000
CMVOLCTR EQU   CMSWA+42                                                 03156000
CMSDFSPC EQU   CMSWA+48                                                 03157000
CMVLLIST EQU   CMSWA+64                                                 03158000
CMVLRTCD EQU   CMVLLIST+2                                               03159000
CMSPCATR EQU   CMSWA+76                                                 03160000
CMPHYBLK EQU   CMSPCATR                                                 03161000
CMTRKPCA EQU   CMSPCATR+10                                              03162000
CMWASTOR EQU   CMSWA+132                                                03163000
CMPOT    EQU   CMWASTOR                                                 03164000
CMDCONV  EQU   CMPOT                                                    03165000
CMIXFANO EQU   CMDCONV                                                  03166000
CMPOTX   EQU   CMWASTOR+4                                               03167000
CMPBI    EQU   CMPOTX                                                   03168000
CMIXFANS EQU   CMPBI                                                    03169000
CMWABYTB EQU   CMSWA+140                                                03170000
CMPBIX   EQU   CMWABYTB                                                 03171000
CMNEST   EQU   CMPBIX                                                   03172000
CMFANT   EQU   CMNEST                                                   03173000
CMSPCQTY EQU   CMFANT                                                   03174000
CMWGENAM EQU   CMSWA+144                                                03175000
CMWDATE  EQU   CMWGENAM+12                                              03176000
CMWTIME  EQU   CMWGENAM+17                                              03177000
DCWPLSPS EQU   CMSWA+200                                                03178000
DCWPLSPL EQU   DCWPLSPS                                                 03179000
DCWPLBFS EQU   CMSWA+232                                                03180000
DCWPLBFL EQU   DCWPLBFS                                                 03181000
DCWPLEDS EQU   CMSWA+260                                                03182000
DCWPLEDL EQU   DCWPLEDS                                                 03183000
DCWPLARS EQU   CMSWA+288                                                03184000
DCWPLARL EQU   DCWPLARS                                                 03185000
DCWPLCDS EQU   CMSWA+316                                                03186000
DCWPLCDL EQU   DCWPLCDS                                                 03187000
CMSDSPTB EQU   CMSWA+344                                                03188000
CMUCATCI EQU   CMSWA+410                                                03189000
CMSRAC   EQU   CMSWA+516                                                03190000
CMSROBJA EQU   CMSRAC+32                                                03191000
CMSROBJN EQU   CMSROBJA                                                 03192000
CUMPLWA  EQU   0                                                        03193000
CUMPL    EQU   CUMPLWA                                                  03194000
CUMIN    EQU   CUMPL                                                    03195000
CUMOUT   EQU   CUMPL+1                                                  03196000
CUMWA    EQU   CUMPLWA+8                                                03197000
CUMFLAG  EQU   CUMWA                                                    03198000
CUMWASS2 EQU   CUMWA+48                                                 03199000
CUMWASS  EQU   CUMWASS2+2                                               03200000
CUMWTYP  EQU   CUMWASS                                                  03201000
IDAAMDSB EQU   0                                                        03202000
AMDATTR  EQU   IDAAMDSB+1                                               03203000
AMDSDT   EQU   AMDATTR                                                  03204000
AMDRRDS  EQU   AMDATTR                                                  03205000
AMDSPAN  EQU   AMDATTR                                                  03206000
AMDNEST  EQU   IDAAMDSB+4                                               03207000
AMDRKP   EQU   IDAAMDSB+6                                               03208000
AMDKEYLN EQU   IDAAMDSB+8                                               03209000
AMDCINV  EQU   IDAAMDSB+20                                              03210000
AMDLRECL EQU   IDAAMDSB+24                                              03211000
AMDHLRBA EQU   IDAAMDSB+28                                              03212000
AMDSSRBA EQU   IDAAMDSB+32                                              03213000
AMDATTR3 EQU   IDAAMDSB+40                                              03214000
AMDSTAT  EQU   IDAAMDSB+48                                              03215000
CTVOLRCD EQU   1                                                        03216000
CTVDVCHR EQU   CTVOLRCD+52                                              03217000
CTVBOKAB EQU   CTVDVCHR+14                                              03218000
CTVDVFLG EQU   CTVDVCHR+17                                              03219000
CTVSPHDR EQU   0                                                        03220000
CTVSPFLG EQU   CTVSPHDR+15                                              03221000
CTVDESGP EQU   0                                                        03222000
CTVEXTST EQU   CTVDESGP+4                                               03223000
CTVSTDES EQU   CTVEXTST                                                 03224000
CTVDSGRP EQU   0                                                        03225000
CTVDSDFL EQU   CTVDSGRP+6                                               03226000
CTVDSDIR EQU   CTVDSGRP+9                                               03227000
CTVGOPT  EQU   0                                                        03228000
CTVGOCI  EQU   CTVGOPT                                                  03229000
CTVGOGCI EQU   CTVGOPT+3                                                03230000
CTVRCTRL EQU   0                                                        03231000
CTVEXRPT EQU   CTVRCTRL                                                 03232000
CTVSPMAP EQU   0                                                        03233000
CTVSMSN  EQU   CTVSPMAP                                                 03234000
CTVDSPAC EQU   0                                                        03235000
CTVDSPSN EQU   CTVDSPAC                                                 03236000
CTVDSPFG EQU   CTVDSPAC+15                                              03237000
CTVSPEXT EQU   CTVDSPAC+21                                              03238000
CTVEXTNT EQU   CTVSPEXT                                                 03239000
CTVDIR   EQU   0                                                        03240000
CTVDSDSN EQU   CTVDIR                                                   03241000
CTVDEXTN EQU   0                                                        03242000
DCIDWKA  EQU   0                                                        03243000
DELTA    EQU   DCIDWKA                                                  03244000
CILIMIT  EQU   DCIDWKA+4                                                03245000
UCISPACE EQU   DCIDWKA+8                                                03246000
DCWREG   EQU   DCIDWKA+12                                               03247000
ALRECL   EQU   DCIDWKA+16                                               03248000
BLKV     EQU   DCIDWKA+20                                               03249000
CILIST   EQU   DCIDWKA+36                                               03250000
CISPPTK  EQU   CILIST                                                   03251000
CIBLKSZ  EQU   CILIST+4                                                 03252000
TRKREM   EQU   0                                                        03253000
CATSN    EQU   0                                                        03254000
CI       EQU   0                                                        03255000
CTGVLDSP EQU   0                                                        03256000
DATEFLD  EQU   0                                                        03257000
DVCLSTYP EQU   0                                                        03258000
ENTRYNAM EQU   0                                                        03259000
EXCPNAME EQU   0                                                        03260000
FIELDNM  EQU   0                                                        03261000
OWNIDFLD EQU   0                                                        03262000
TNAM     EQU   0                                                        03263000
@NM00038 EQU   CTGDDNM                                                  03264000
CTGPROB  EQU   @NM00038                                                 03265000
CTGREASN EQU   CTGPROB+2                                                03266000
CTGRBASE EQU   NREPLF+1                                                 03285000
CATTR    EQU   CTGRBASE+58                                              03286000
CATTR1   EQU   CATTR                                                    03287000
CATTR2   EQU   CATTR+1                                                  03288000
COPEN    EQU   CTGRBASE+60                                              03289000
CSPACPRM EQU   CTGRBASE+65                                              03290000
@NM00116 EQU   CATTR1                                                   03291000
CCATTR   EQU   @NM00116                                                 03292000
@NM00119 EQU   CATTR1                                                   03294000
CRGATTR  EQU   @NM00119                                                 03295000
CUPG     EQU   CRGATTR                                                  03296000
ACHKPROF EQU   ACHKENT                                                  03297000
BLKVOVLY EQU   BLKV                                                     03298000
@ENDDATA EQU   *                                                        05524000
         END   IGG0CLBX                                         DSKL013 05525000
