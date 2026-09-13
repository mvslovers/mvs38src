         TITLE 'IGG0CLBI - VSAM CATALOG GET/RECOVERY SUBFUNCTIONS      *00001000
                        '                                               00002000
IGG0CLBI CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSKL014 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'IGG0CLBI  81.076'                              DSKL014 00008000
         DROP  R15                                              DSKL014 00009000
@PROLOG  DS    0H                                                  0002 00010000
         USING @MAINENT,R15                                     DSKL014 00011000
         DS 0F                                                          00013000
         DC CL8'IGGPUCRS'                                               00014000
         EJECT                                                          00015000
         BR    R14                                              DSKL014 00016000
IGGPUCRS DS    0H                                                  0172 00017000
         ENTRY IGGPUCRS                                                 00018000
         DROP  R15                                              DSKL014 00019000
Z003     DS    0H                                                  0174 00020000
Z003UCRS DS    0H                                                  0175 00021000
         BALR 12,0                                                      00022000
IGGSEGST DS 0H                                                          00023000
         USING IGGSEGST,R12                                     DSKL014 00024000
         LA    R10,4095(,R12)                                   DSKL014 00024010
         USING IGGSEGST+4095,R10                                DSKL014 00024020
*   IF CTGFUNC^=CTGLOC THEN         /* NOT LOCATE FUNCTION           */ 00025000
         L     R5,CCACPL(,R11)                                  DSKL014 00026000
         TM    CTGFUNC(R5),B'00100000'                          DSKL014 00027000
         BNO   @RT00180                                            0180 00028000
         TM    CTGFUNC(R5),B'11000000'                          DSKL014 00029000
         BZ    @RF00180                                            0180 00030000
@RT00180 DS    0H                                                  0181 00031000
*     DO;                                                          0181 00032000
*       R13=R13-TWELVE;             /* POP PUSH-DOWN POINTER LIST    */ 00033000
         SH    R13,@CH00072                                        0182 00034000
*       CALL EXIT;                  /* RETURN TO 4TH PREVIOUS CALLER    00035000
*                                      IGGPRCU(IGG0CLC9) INSTEAD OF     00036000
*                                      IGGPACDV(IGG0CLAB)            */ 00037000
         BAL   R14,EXIT                                         DSKL014 00038000
*     END;                                                         0184 00039000
*   ELSE                                                           0185 00040000
*     ;                             /* LOCATE FUNCTION               */ 00041000
@RF00180 DS    0H                                                  0186 00042000
*   CCAUCRA=ON;                     /* INDICATE GET CI FROM CRA      */ 00043000
         OI    CCAUCRA(R11),B'00001000'                            0186 00044000
*   CCAACB=CBSCRACA                 /* GET CATALOG ACB ADDRESS       */ 00045000
*       ->CAXACB;                                                  0187 00046000
         L     R5,CVTPTR                                        DSKL014 00047000
         L     R5,CVTCBSP(,R5)                                  DSKL014 00048000
         L     R5,CBSCRACA(,R5)                                 DSKL014 00049000
         MVC   CCAACB(4,R11),CAXACB(R5)                         DSKL014 00050000
*   IF CTGNAME=ON THEN              /* TRUE NAME GET INDICATED       */ 00051000
         L     R5,CCACPL(,R11)                                  DSKL014 00052000
         TM    CTGNAME(R5),B'00000100'                          DSKL014 00053000
         BNO   @RF00188                                            0188 00054000
*     DO;                                                          0189 00055000
*       IF CTGVMNT=ON THEN          /* VOLUME MOUNT IS CALLER        */ 00056000
         TM    CTGVMNT(R5),B'00100000'                          DSKL014 00057000
         BNO   @RF00190                                            0190 00058000
*         DO;                                                      0191 00059000
*           CCASRCH=CTGENT          /* PUT VOLSER IN SEARCH          */ 00060000
*               ->TNAM;             /* ARGUMENT FIELD                */ 00061000
         L     R5,CTGENT(,R5)                                   DSKL014 00062000
         MVC   CCASRCH(44,R11),TNAM(R5)                         DSKL014 00063000
*Z004UCVT:                                                         0193 00064000
*           CALL IGGPUCVT;          /* GET TIMESTAMP OF VOLUME       */ 00065000
Z004UCVT BAL   R14,IGGPUCVT                                     DSKL014 00066000
*         END;                                                     0194 00067000
*       ELSE                        /* CALLER IS NOT VOLUME MOUNT    */ 00068000
*         CCASRCIN=CBSCRACA         /* GET CI NUMBER FROM CRA ACCESS */ 00069000
*             ->CAXSCHWA->ACCDSNCI; /* PARAMETER LIST                */ 00070000
         B     @RC00188                                         DSKL014 00071000
@RF00190 L     R5,CVTPTR                                        DSKL014 00072000
         L     R5,CVTCBSP(,R5)                                  DSKL014 00073000
         L     R5,CBSCRACA(,R5)                                 DSKL014 00074000
         L     R5,CAXSCHWA(,R5)                                 DSKL014 00075000
         MVC   CCASRCIN(3,R11),ACCDSNCI(R5)                     DSKL014 00076000
*     END;                                                         0196 00077000
*   ELSE                            /* GET BY CI NUMBER              */ 00078000
*     CCASRCIN=CTGENT->CI;          /* SET NUMBER OF CI TO GET       */ 00079000
         B     @RC00188                                            0197 00080000
@RF00188 L     R5,CCACPL(,R11)                                  DSKL014 00081000
         L     R5,CTGENT(,R5)                                   DSKL014 00082000
         MVC   CCASRCIN(3,R11),CI(R5)                           DSKL014 00083000
*   CCAROREQ=ON;                    /* READ ONLY REQUEST             */ 00084000
@RC00188 OI    CCAROREQ(R11),B'00000100'                           0198 00085000
*   CCARPLK=ONE;                    /* SET RPL COUNT TO 1            */ 00086000
         MVI   CCARPLK(R11),X'01'                                  0199 00087000
*   CCARPL1=CAXRPL;                 /* POINT TO RPL TO USE           */ 00088000
         L     R5,CCAACB(,R11)                                  DSKL014 00089000
         L     R5,ACBUAPTR(,R5)                                 DSKL014 00090000
         L     R5,CAXRPL(,R5)                                   DSKL014 00091000
         ST    R5,CCARPL1(,R11)                                 DSKL014 00092000
*   RFY                                                            0201 00093000
*     IFGRPL BASED(CCARPL1);        /* MAP THE RPL TO USE            */ 00094000
*   RPLUPD=OFF;                     /* NOT UPDATE                    */ 00095000
         NI    RPLUPD(R5),B'11111101'                           DSKL014 00096000
*   RPLARG=ADDR(CCASRCH);           /* SET SEARCH ARGUMENT ADDRESS   */ 00097000
         LA    R15,CCASRCH(,R11)                                DSKL014 00098000
         ST    R15,RPLARG(,R5)                                  DSKL014 00099000
*   DO;                                                            0204 00100000
*     CCAF1KEY=OFF;                 /* GET BY CI NO.                 */ 00101000
*     CCAF1KGE=OFF;                 /* NOT GET NEXT                  */ 00102000
         NI    CCAF1KEY(R11),B'11100111'                           0206 00103000
*Z006GET:                                                          0207 00104000
*     CALL IGGPGET;                 /* GET RECORD                    */ 00105000
Z006GET  BAL   R14,IGGPGET                                      DSKL014 00106000
*   END;                            /* GET RECORD BY CI NUMBER       */ 00107000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 00108000
         BAL   R14,EXIT                                         DSKL014 00109000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 00110000
         DS 0F                                                          00111000
*   GEN(DC CL8'IGGPGET');           /* NAME OF FOLLOWING PROCEDURE   */ 00112000
         DC CL8'IGGPGET'                                                00113000
*   END;                            /* END OF INNER PROCEDURE        */ 00114000
@EL00002 DS    0H                                                  0212 00115000
@EF00002 DS    0H                                                  0212 00116000
@ER00002 BR    R14                                              DSKL014 00117000
@PB00002 DS    0H                                                  0213 00118000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 00119000
         EJECT                                                          00120000
*                                                                  0214 00121000
*/********************************************************************/ 00122000
*/*                                                                  */ 00123000
*/*        IGGPGET  -  PROCEDURE  EXTERNALLY  CALLED  NESTED         */ 00124000
*/*                                                                  */ 00125000
*/********************************************************************/ 00126000
*                                                                  0214 00127000
*IGGPGET:                                                          0214 00128000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 00129000
IGGPGET  DS    0H                                                  0215 00131000
*   GEN(ENTRY IGGPGET );            /* IDENTIFY ENTRY-POINT SYMBOL   */ 00132000
         ENTRY IGGPGET                                                  00133000
*Z007:                              /* LABEL FOR PROCEDURE TRACKING  */ 00134000
*Z007GET:                           /* LABEL FOR PROCEDURE TRACKING  */ 00135000
*   RFY                                                            0216 00136000
*    (R5,                                                          0216 00137000
*     R6,                                                          0216 00138000
*     R7,                                                          0216 00139000
*     R8,                                                          0216 00140000
*     R9,                                                          0216 00141000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 00142000
Z007     DS    0H                                                  0216 00143000
Z007GET  DS    0H                                                  0217 00144000
         DROP  R12                                              DSKL014 00145000
         DROP  R10                                              DSKL014 00146000
         STM   R12,R14,12(R13)         SAVE REGISTERS OF CALLER DSKL014 00147000
         LA    R13,12(R13)             POINT TO NEXT SAVE AREA  DSKL014 00148000
         BALR  R12,0                   ESTABLISH ADDRESSABILITY DSKL014 00149000
A0000EC  DS    0H                                               DSKL014 00150000
         USING A0000EC,R12                                      DSKL014 00151000
         B     A0000F2                                          DSKL014 00152000
A0000F0  DC    AL2(A0000EC-IGGSEGST)                            DSKL014 00153000
A0000F2  SH    R12,A0000F0                                      DSKL014 00154000
         USING IGGSEGST,R12                                     DSKL014 00155000
         LA    R10,4095(,R12)                                   DSKL014 00156000
         USING IGGSEGST+4095,R10                                DSKL014 00157000
*/********************************************************************/ 00159000
*/*     EXTERNAL PROCEDURE TO RETRIEVE THE CI REQUESTED BY THE       */ 00160000
*/*     CALLER, PLACING IT INTO THE CALLER-SPECIFIED RECORD AREA     */ 00161000
*/********************************************************************/ 00162000
*                                                                  0223 00163000
*   RFY                                                            0223 00164000
*    (R0,                                                          0223 00165000
*     R1,                                                          0223 00166000
*     R13) RSTD;                                                   0223 00167000
*   GEN;                                                           0224 00168000
IGGPGETC EQU   IGGPGET               ALTERNATE ENTRY-POINT NAME         00169000
         ENTRY IGGPGETC                                                 00170000
*   IF(CCARAEOV=ON)&                /* END-OF-VOLUME FOR CRA         */ 00171000
*       (CCARAACB->ACBSCRA=ON)&     /* CATLG CNTRL BLK SYS AREA      */ 00172000
*       (CCASRCIN<HICATRCD)&        /* SELF-DESCRIBING CI            */ 00173000
*       (CCAF1KEY=OFF) THEN         /* NOT TRUE-NAME GET             */ 00174000
         TM    CCARAEOV(R11),B'01000000'                           0225 00175000
         BNO   @RF00225                                            0225 00176000
         L     R5,CCARAACB(,R11)                                DSKL014 00177000
         TM    ACBSCRA(R5),B'00001000'                          DSKL014 00178000
         BNO   @RF00225                                            0225 00179000
         CLC   CCASRCIN(3,R11),@CF02795+1                          0225 00180000
         BNL   @RF00225                                            0225 00181000
         TM    CCAF1KEY(R11),B'00010000'                           0225 00182000
         BNZ   @RF00225                                            0225 00183000
*     DO;                                                          0226 00184000
*                                                                  0226 00185000
*       /*************************************************************/ 00186000
*       /*                                                           */ 00187000
*       /* CALL TO MODULE IGG0CLBO                                   */ 00188000
*       /*                                                           */ 00189000
*       /*************************************************************/ 00190000
*                                                                  0227 00191000
*Z008RAG:                                                          0227 00192000
*       CALL IGGPRAG;               /* RECOVERY AREA GET ROUTINE     */ 00193000
Z008RAG  L     R15,@CV03237                                     DSKL014 00194000
         BALR  R14,R15                                          DSKL014 00195000
*       GOTO GETFNDEX;              /* SET RECORD POINTERS IN RAB    */ 00196000
         LA    R10,4095(,R12)                                   DSKL014 00196010
         B     GETFNDEX                                            0228 00197000
*     END;                                                         0229 00198000
*   ELSE                                                           0230 00199000
*     ;                             /* NORMAL GET PROCESSING         */ 00200000
@RF00225 DS    0H                                                  0231 00201000
*   CCAMLRET=R13;                   /* I/O ERR RETRN SV AR PTR       */ 00202000
         ST    R13,CCAMLRET(,R11)                                  0231 00203000
*   RFY                                                            0232 00204000
*     CATRCD BASED(R1);             /* SPECIFY BASE FOR RECORD       */ 00205000
*   RFY                                                            0233 00206000
*     CTENTREC BASED(R1);           /* SPECIFY BASE FOR RECORD       */ 00207000
*   CCAVRIND=OFF;                   /* CLEAR VOL BUFFER CHECK IND    */ 00208000
*   CCALPIND=OFF;                   /* CLEAR LOOP INDICATOR FLAG     */ 00209000
         NI    CCAVRIND(R11),B'11110011'                           0235 00210000
*/********************************************************************/ 00211000
*/*     RECOVERABLE  CATALOG  AND  NOT  CATALOG  OPEN  OR  BUILD     */ 00212000
*/********************************************************************/ 00213000
         L     R5,CCACPL(,R11)                                  DSKL014 00213010
         TM    CTGFUNC(R5),X'80'                                DSKL014 00213020
         BNO   A00015A                                          DSKL014 00213030
         TM    CTGFUNC(R5),X'60'                                DSKL014 00213040
         BNZ   A00015A                                          DSKL014 00213050
         TM    CTGOPTNS(R5),X'08'                               DSKL014 00213060
         BNO   @RF00236                                         DSKL014 00213070
         TM    CTGOPTNS(R5),X'F0'                               DSKL014 00213080
         BNZ   @RF00236                                         DSKL014 00213090
A00015A  DS    0H                                               DSKL014 00213100
*                                                                  0236 00214000
*   IF CAXF2REC=ON&                 /* RECOVERABLE CATALOG AND       */ 00215000
*       CCAF2COB='00'B THEN         /* NOT BUILD/OPEN                */ 00216000
         L     R5,CCAACB(,R11)                                  DSKL014 00217000
         L     R5,ACBUAPTR(,R5)                                 DSKL014 00218000
         TM    CAXF2REC(R5),B'00000010'                         DSKL014 00219000
         BNO   @RF00236                                            0236 00220000
         TM    CCAF2COB(R11),B'00000110'                           0236 00221000
         BNZ   @RF00236                                            0236 00222000
*     DO WHILE CCALPIND=OFF;        /* CHECK FOR BUFFERED RECS       */ 00223000
         B     @DE00237                                            0237 00224000
@DL00237 DS    0H                                                  0238 00225000
*       RFY                                                        0238 00226000
*        (R5,                                                      0238 00227000
*         R6) RSTD;                 /* NEED R5, R6 FOR POINTERS      */ 00228000
*       IF CCARANCA(1)^=ZERO&       /* NORMAL RECORD BUFFER CHAIN    */ 00229000
*           CCAVRIND=OFF THEN       /* AND NOT YET EXAMINED          */ 00230000
         L     R7,CCARANCA(,R11)                                DSKL014 00231000
         LTR   R7,R7                                            DSKL014 00232000
         BZ    @RF00239                                            0239 00233000
         TM    CCAVRIND(R11),B'00000100'                           0239 00234000
         BNZ   @RF00239                                            0239 00235000
*         DO;                       /* SET UP TO SCAN NORMAL CHN     */ 00236000
*           R1=CCARANCA(1);         /* POINT TO FIRST RECORD         */ 00237000
         LR    R1,R7                                            DSKL014 00238000
*           R6=ADDR(CCARANCA(1))    /* POINT TO PSEUDO PREVIOUS      */ 00239000
*               -LENGTH(BUFRECRD);  /* RECORD ON CHAIN               */ 00240000
         LA    R6,CCARANCA(,R11)                                   0242 00241000
         SH    R6,@CH03290                                         0242 00242000
*         END;                                                     0243 00243000
*       ELSE                        /* CHECK VOL RECORD CHAIN        */ 00244000
*         DO;                       /* CHECK FOR VOLUME RECORDS      */ 00245000
         B     @RC00239                                            0244 00246000
@RF00239 DS    0H                                                  0245 00247000
*           IF CCARAVCA(1)^=ZERO THEN/* VOL BUFFER CHAIN EXISTS      */ 00248000
         L     R7,CCARAVCA(,R11)                                DSKL014 00249000
         LTR   R7,R7                                            DSKL014 00250000
         BZ    @RF00245                                            0245 00251000
*             DO;                                                  0246 00252000
*               R1=CCARAVCA(1);     /* SET ADDRESS OF VOL REC CHN    */ 00253000
         LR    R1,R7                                            DSKL014 00254000
*               R6=ADDR(CCARAVCA(1))/* POINT TO PSEUDO               */ 00255000
*                   -LENGTH(BUFRECRD);/* PREVIOUS RECORD ON CHN      */ 00256000
         LA    R6,CCARAVCA(,R11)                                   0248 00257000
         SH    R6,@CH03290                                         0248 00258000
*               CCAVRIND=ON;        /* INDICATE VOL REC BUFFER CHAIN */ 00259000
         OI    CCAVRIND(R11),B'00000100'                           0249 00260000
*             END;                                                 0250 00261000
*           ELSE                    /* NO VOL RECORD BUFFER CHAIN    */ 00262000
*             CCALPIND=ON;          /* INDICATE END RECORD CHECK     */ 00263000
         B     @RC00245                                            0251 00264000
@RF00245 OI    CCALPIND(R11),B'00001000'                           0251 00265000
*         END;                                                     0252 00266000
@RC00245 DS    0H                                                  0253 00267000
*       DO WHILE(CCALPIND=OFF&R1^=0);/* CHECK FOR RECORD             */ 00268000
@RC00239 B     @DE00253                                            0253 00269000
@DL00253 DS    0H                                                  0254 00270000
*         IF(CCAF1KEY=ON&           /* KEYED REQUEST, FULL NAME      */ 00271000
*             CCASRCH=RCDNAME)×     /* RECORD FOUND IN CHAIN, CI     */ 00272000
*             (CCASRCIN=RCDCINO) THEN/* RECORD FOUND IN CHAIN        */ 00273000
         TM    CCAF1KEY(R11),B'00010000'                           0254 00274000
         BNO   @GL00006                                            0254 00275000
         CLC   CCASRCH(44,R11),RCDNAME(R1)                         0254 00276000
         BE    @RT00254                                            0254 00277000
@GL00006 CLC   CCASRCIN(3,R11),RCDCINO(R1)                         0254 00278000
         BNE   @RF00254                                            0254 00279000
@RT00254 DS    0H                                                  0255 00280000
*           DO;                     /* MOVE RECORD TO RA             */ 00281000
*             CCALPIND=ON;          /* SET LOOP END INDICATOR        */ 00282000
         OI    CCALPIND(R11),B'00001000'                           0256 00283000
*             R5=ADDR(BUFRECRD);    /* GET ADDR OF RECORD START      */ 00284000
         LR    R5,R1                                               0257 00285000
*             TORECAR(1:256)=R5->TORECAR(1:256);/* MOVE REC          */ 00286000
         L     R7,CCAURAB(,R11)                                 DSKL014 00287000
         L     R7,CCACPE1(,R7)                                  DSKL014 00288000
         MVC   TORECAR(256,R7),TORECAR(R5)                      DSKL014 00289000
*             TORECAR(257:508)=R5->TORECAR(257:508);               0259 00290000
         MVC   TORECAR+256(252,R7),TORECAR+256(R5)              DSKL014 00291000
         MVC   TORECAR+505(7,R7),A001449                        DSKL014 00291010
*             GOTO GETFNDEX;        /* SET UP CPE POINTERS           */ 00292000
         B     GETFNDEX                                            0260 00293000
*           END;                                                   0261 00294000
*         ELSE                      /* RECORD NOT FOUND ON CHAIN     */ 00295000
*           DO;                     /* CHECK NEXT RECORD ON CHAIN    */ 00296000
@RF00254 DS    0H                                                  0263 00297000
*             R6=R1;                /* SET PREVIOUS RECORD POINTER   */ 00298000
         LR    R6,R1                                               0263 00299000
*             R1=BUFNEXTB;          /* POINT TO NEXT RECORD ON CHAIN */ 00300000
         L     R1,BUFNEXTB(,R1)                                    0264 00301000
*           END;                                                   0265 00302000
*       END;                                                       0266 00303000
@DE00253 TM    CCALPIND(R11),B'00001000'                           0266 00304000
         BNZ   @DC00253                                            0266 00305000
         LTR   R1,R1                                               0266 00306000
         BNZ   @DL00253                                            0266 00307000
@DC00253 DS    0H                                                  0267 00308000
*       IF CCAVRIND=ON THEN         /* VOL RECORD CHAIN SCAN DONE    */ 00309000
         TM    CCAVRIND(R11),B'00000100'                           0267 00310000
         BNO   @RF00267                                            0267 00311000
*         CCALPIND=ON;              /* INDICATE CHAIN SCAN COMPLETE  */ 00312000
         OI    CCALPIND(R11),B'00001000'                           0268 00313000
*       ELSE                        /* INDICATE VOL RECORD CHAIN SCAN*/ 00314000
*         CCAVRIND=ON;              /* INDICATE CHAIN SCAN COMPLETE  */ 00315000
         B     @RC00267                                            0269 00316000
@RF00267 OI    CCAVRIND(R11),B'00000100'                           0269 00317000
*       RFY                                                        0270 00318000
*        (R5,                                                      0270 00319000
*         R6) UNRSTD;               /* FREE USE OF R5, R6            */ 00320000
@RC00267 DS    0H                                                  0271 00321000
*     END;                                                         0271 00322000
@DE00237 TM    CCALPIND(R11),B'00001000'                           0271 00323000
         BZ    @DL00237                                            0271 00324000
*   ELSE                                                           0272 00325000
*     ;                             /* NOT RECOVERABLE CATALOG OR NOT   00326000
*                                      OPEN/BUILD OF CATALOG         */ 00327000
@RF00236 DS    0H                                                  0273 00328000
*/********************************************************************/ 00329000
*/*               NOT  OPEN  OR  BUILD  OF  A  CATALOG               */ 00330000
*/********************************************************************/ 00331000
*                                                                  0273 00332000
*   RFY                                                            0273 00333000
*     CATRCD BASED(CCACPE1);        /* SPECIFY BASE FOR RECORD       */ 00334000
*   RFY                                                            0274 00335000
*     CTENTREC BASED(CCACPE1);      /* SPECIFY BASE FOR RECORD       */ 00336000
*   IF CCAF2COB='00'B THEN          /* IF NOT CATLG BUILD/OPEN,      */ 00337000
         TM    CCAF2COB(R11),B'00000110'                           0275 00338000
         BNZ   @RF00275                                            0275 00339000
*     DO;                           /* THEN DO NORMAL PROCESSING     */ 00340000
*       DO ONCE=ONCE WHILE(CCAF1KEY=ON);/* DO IF KEYED GET REQ       */ 00341000
         TM    CCAF1KEY(R11),B'00010000'                           0277 00342000
         BNO   @DC00277                                            0277 00343000
*         IF CCAF1KGE=ON THEN       /* IF GET NEXT REQUEST           */ 00344000
         TM    CCAF1KGE(R11),B'00001000'                           0278 00345000
         BNO   @RF00278                                            0278 00346000
*           DO;                                                    0279 00347000
*             XIOOPT=187;           /* GET OPTIONS                   */ 00348000
         MVI   XIOOPT(R11),X'BB'                                   0280 00349000
*Z009XIO:                                                          0281 00350000
*             CALL IGGPXIO;         /* GET NEXT (=>) TRUE NAME ENT 0281 00351000
*                                      OP=ARA-KEY-NUP-CHK-TNE-KGE    */ 00352000
Z009XIO  BAL   R14,IGGPXIO                                      DSKL014 00353000
*           END;                                                   0282 00354000
*         ELSE                      /* NOT GET-NEXT REQUEST          */ 00355000
*           DO;                                                    0283 00356000
         B     @RC00278                                            0283 00357000
@RF00278 DS    0H                                                  0284 00358000
*             XIOOPT=186;           /* GET OPTIONS                   */ 00359000
         MVI   XIOOPT(R11),X'BA'                                   0284 00360000
*Z010XIO:                                                          0285 00361000
*             CALL IGGPXIO;         /* GET TRUE NAME ENTRY         0285 00362000
*                                      OP=ARA-KEY-NUP-CHK-TNE-KEQ    */ 00363000
Z010XIO  BAL   R14,IGGPXIO                                      DSKL014 00364000
*           END;                                                   0286 00365000
*         CCASRID=ARATNCI;          /* EXTRACT CI # FROM TN ENTRY    */ 00366000
@RC00278 L     R5,CCAR0REC(,R11)                                DSKL014 00367000
         MVC   CCASRID(3,R11),ARATNCI(R5)                       DSKL014 00368000
*       END;                        /* END OF KEYED GET PROCESS START   00369000
*                                      OF CI GET PROCESS             */ 00370000
@DC00277 DS    0H                                                  0289 00371000
*       IF CCAUCRA=ON THEN          /* CRA GET REQUEST               */ 00372000
         TM    CCAUCRA(R11),B'00001000'                            0289 00373000
         BNO   @RF00289                                            0289 00374000
*         DO;                       /* PERFORM CI NO. TRANSLATION    */ 00375000
*Z011UCCT:                                                         0291 00376000
*           CALL IGGPUCCT;          /* DO CRA CI # TRANSLATION       */ 00377000
Z011UCCT BAL   R14,IGGPUCCT                                     DSKL014 00378000
*           IF CCACD1^=RCS THEN     /* CI TRANSLATION FAILED         */ 00379000
         CLI   CCACD1(R11),0                                       0292 00380000
         BE    @RF00292                                            0292 00381000
*             CALL EXIT;            /* RETURN TO CALLER              */ 00382000
         BAL   R14,EXIT                                         DSKL014 00383000
*           ELSE                                                   0294 00384000
*             ;                     /* CI TRANSLATION SUCCESSFUL     */ 00385000
@RF00292 DS    0H                                                  0295 00386000
*         END;                      /* END CI NO. TRANSLATION        */ 00387000
*       ELSE                                                       0296 00388000
*         ;                         /* NOT 'GET' FROM CRA            */ 00389000
@RF00289 DS    0H                                                  0297 00390000
*       CCADDDD=CCASRCIN*CILEN;     /* SET UP RBA FOR GET            */ 00391000
         SLR   R5,R5                                            DSKL014 00392000
         ICM   R5,7,CCASRCIN(R11)                               DSKL014 00393000
         SLA   R5,9                                             DSKL014 00394000
         ST    R5,CCADDDD(,R11)                                 DSKL014 00395000
*       IF CCAF1UP=ON&              /* GET FOR UPDATE                */ 00396000
*           CCAROREQ=OFF THEN       /* NOT READ-ONLY REQUEST TYPE    */ 00397000
         TM    CCAF1UP(R11),B'00000010'                            0298 00398000
         BNO   @RF00298                                            0298 00399000
         TM    CCAROREQ(R11),B'00000100'                           0298 00400000
         BNZ   @RF00298                                            0298 00401000
*         DO;                                                      0299 00402000
*           XIOOPT=132;             /* GET OPTIONS                   */ 00403000
         MVI   XIOOPT(R11),X'84'                                   0300 00404000
*Z012XIO:                                                          0301 00405000
*           CALL IGGPXIO;           /* GET ENTRY RECORD FOR UPDATE 0301 00406000
*                                      OP=URA-ADR-UPD-NCK-CIE----    */ 00407000
Z012XIO  BAL   R14,IGGPXIO                                      DSKL014 00408000
*         END;                      /*                       @ZA02285*/ 00409000
*       ELSE                        /* NOT GET FOR UPDATE            */ 00410000
*         DO;                                                      0303 00411000
         B     @RC00298                                            0303 00412000
@RF00298 DS    0H                                                  0304 00413000
*           XIOOPT=140;             /* GET OPTIONS                   */ 00414000
         MVI   XIOOPT(R11),X'8C'                                   0304 00415000
*Z013XIO:                                                          0305 00416000
*           CALL IGGPXIO;           /* GET ENTRY RCD         @ZA02285   00417000
*                                      OP=URA-ADR-NUP-NCK-CIE----    */ 00418000
Z013XIO  BAL   R14,IGGPXIO                                      DSKL014 00419000
*         END;                      /*                       @ZA02285*/ 00420000
*                                                                  0306 00421000
*       /*************************************************************/ 00422000
*       /*                                                           */ 00423000
*       /* * * * * * * * * * * * * * * * * * * * * * * * * * * * IF  */ 00424000
*       /* INVALID RBA RETURN, VERIFY THE CATALOG AND        @ZA02285*/ 00425000
*       /* RE-ISSUE THE GET WITH CHECK OPTION.               @ZA02285*/ 00426000
*       /* * * * * * * * * * * * * * * * * * * * * * * * * * * *     */ 00427000
*       /*                                                           */ 00428000
*       /*************************************************************/ 00429000
*                                                                  0307 00430000
*       IF RPLRTNCD^='00'X THEN     /* ERROR ?               @ZA02285*/ 00431000
@RC00298 L     R5,CCARPL1(,R11)                                 DSKL014 00432000
         CLI   RPLRTNCD(R5),0                                   DSKL014 00433000
         BE    @RF00307                                            0307 00434000
*         IF RPLRTNCD='08'X&        /* LOGICAL ERROR         @ZA02285*/ 00435000
*             RPLERRCD=RPLINRBA THEN/* AND INV RBA           @ZA02285*/ 00436000
         CLI   RPLRTNCD(R5),8                                   DSKL014 00437000
         BNE   @RF00308                                            0308 00438000
         CLI   RPLERRCD(R5),32                                  DSKL014 00439000
         BNE   @RF00308                                            0308 00440000
*           DO;                     /* YES, VERIFY           @ZA02285*/ 00441000
*             R1=ADDR(IFGRPL);      /* ADDR OF RPL           @ZA02285*/ 00442000
         LR    R1,R5                                            DSKL014 00443000
*             R13=R13+12;           /* ADJ SAVEAREA          @ZA02285*/ 00444000
         AH    R13,@CH00072                                        0311 00445000
*             GEN(VERIFY RPL=(1));  /* ISSUE VERIFY          @ZA02285*/ 00446000
         VERIFY RPL=(1)                                                 00447000
*             R13=R13-12;           /* ADJ SAVEAREA          @ZA02285*/ 00448000
         SH    R13,@CH00072                                        0313 00449000
*             IF RPLRTNCD^='00'X THEN/* ERROR?               @ZA02285*/ 00450000
         L     R5,CCARPL1(,R11)                                 DSKL014 00451000
         CLI   RPLRTNCD(R5),0                                   DSKL014 00452000
         BE    @RF00314                                            0314 00453000
*               CALL IGGPIORA;      /* I/O RC ANAL           @ZA02285*/ 00454000
         L     R15,@CV03236                                     DSKL014 00455000
         BALR  R14,R15                                          DSKL014 00456000
*             ELSE                                                 0316 00457000
*               ;                   /* NO ERROR              @ZA02285*/ 00458000
*                                                                  0316 00459000
@RF00314 DS    0H                                                  0317 00460000
*             /*******************************************************/ 00461000
*             /*                                                     */ 00462000
*             /* * * * * * * * * * * * * * * * * * * * * * * * * * * */ 00463000
*             /* * RE-ISSUE GET AFTER VERIFY WITH CHK OPT.   @ZA02285*/ 00464000
*             /* * * * * * * * * * * * * * * * * * * * * * * * * * * */ 00465000
*             /* * *                                                 */ 00466000
*             /*                                                     */ 00467000
*             /*******************************************************/ 00468000
*                                                                  0317 00469000
*             XIONCK=OFF;           /* RESET NO CHK FLG      @ZA02285*/ 00470000
         NI    XIONCK(R11),B'11111011'                             0317 00471000
*             CALL IGGPXIO;         /* OP=ADR-CHK-CIE        @ZA02285*/ 00472000
         BAL   R14,IGGPXIO                                      DSKL014 00473000
*           END;                    /* END OF INV RBA        @ZA02285*/ 00474000
*         ELSE                      /* NOT INV RBA           @ZA02285*/ 00475000
*           CALL IGGPIORA;          /* EXIT I/O RC ANAL      @ZA02285*/ 00476000
         B     @RC00275                                         DSKL014 00477000
@RF00308 L     R15,@CV03236                                     DSKL014 00478000
         BALR  R14,R15                                          DSKL014 00479000
*       ELSE                                                       0321 00480000
*         ;                         /*                       @ZA02285*/ 00481000
@RF00307 DS    0H                                                  0322 00482000
*     END;                          /* END 'DO' FOR NOT CAT        0322 00483000
*                                      BUILD/OPEN                    */ 00484000
*/********************************************************************/ 00485000
*/*                 OPEN  OR  BUILD  OF  A  CATALOG                  */ 00486000
*/********************************************************************/ 00487000
*                                                                  0323 00488000
*   ELSE                            /* IF CATALOG BUILD OR OPEN,     */ 00489000
*     DO;                           /* DO SPECIAL COB PROCESSING     */ 00490000
         B     @RC00275                                            0323 00491000
@RF00275 DS    0H                                                  0324 00492000
*       IF CCAF1KEY=ON THEN         /* IF GET BY KEY,                */ 00493000
         TM    CCAF1KEY(R11),B'00010000'                           0324 00494000
         BNO   @RF00324                                            0324 00495000
*         CCASRCIN=CATCLID;         /* THEN SET CATLG CLU CI NO.     */ 00496000
         MVC   CCASRCIN(3,R11),@CF00055+1                          0325 00497000
*       ELSE                                                       0326 00498000
*         ;                         /* NOT GET-BY-KEY REQUEST        */ 00499000
@RF00324 DS    0H                                                  0327 00500000
*       IF CCASRCIN>HICATRCD THEN   /* IF REQD REC NOT FOR CAT,      */ 00501000
         CLC   CCASRCIN(3,R11),@CF02795+1                          0327 00502000
         BNH   @RF00327                                            0327 00503000
*         DO;                       /* THEN ITS AN ERROR             */ 00504000
*                                                                  0328 00505000
*           /*********************************************************/ 00506000
*           /*                                                       */ 00507000
*           /* SET CCAMODID='BI', CCAREASN=RSN4, CCARETRN=RCINCI     */ 00508000
*           /*                                                       */ 00509000
*           /*********************************************************/ 00510000
*                                                                  0329 00511000
*           CCAPROB=IGGSEGID+(RSN4*K256)+RCINCI;/* ECD: INVALID CI 0329 00512000
*                                      NUMBER. RCD: RECORD IS NOT A     00513000
*                                      SELF-DEFINING RECORD (CI# > 9)   00514000
*                                      DURING CATALOG BUILD/OPEN.    */ 00515000
         MVC   CCAPROB(4,R11),@CF03435                             0329 00516000
*           CALL EXIT;              /* RETURN TO CALLER              */ 00517000
         BAL   R14,EXIT                                         DSKL014 00518000
*         END;                                                     0331 00519000
*       ELSE                                                       0332 00520000
*         ;                         /* SELF-DEFINING RECORD GOTTEN   */ 00521000
@RF00327 DS    0H                                                  0333 00522000
*       IF CCAF2CO=ON THEN          /* CATALOG OPEN (NON-BUILD)      */ 00523000
         TM    CCAF2CO(R11),B'00000100'                            0333 00524000
         BNO   @RF00333                                            0333 00525000
*         DO;                       /* USE EXCP TO OBTAIN ENTRY      */ 00526000
*           IF DRWR^=CCASRCIN+ONE THEN/* REQ RCD NOT IN DRWA         */ 00527000
         L     R5,CCAACB(,R11)                                  DSKL014 00528000
         L     R5,ACBUAPTR(,R5)                                 DSKL014 00529000
         L     R5,CAXDRWP(,R5)                                  DSKL014 00530000
         LA    R15,1                                            DSKL014 00531000
         SLR   R14,R14                                          DSKL014 00532000
         ICM   R14,7,CCASRCIN(R11)                              DSKL014 00533000
         ALR   R15,R14                                          DSKL014 00534000
         SLR   R14,R14                                          DSKL014 00535000
         IC    R14,DRWR(,R5)                                    DSKL014 00536000
         CR    R15,R14                                          DSKL014 00537000
         BE    @RF00335                                            0335 00538000
*             DO;                   /* USE EXCP                      */ 00539000
*               DRWR=CCASRCIN+ONE;  /* SET R OF MBBCCHAR             */ 00540000
         STC   R15,DRWR(,R5)                                    DSKL014 00541000
*               R1=ADDR(DRWIOB);    /* GET IOB PTR                   */ 00542000
         LA    R1,DRWIOB(,R5)                                   DSKL014 00543000
*               GEN(EXCP (1));      /* ISSUE EXCP                    */ 00544000
         EXCP (1)                                                       00545000
*               R1=ADDR(DRWECB);    /* GET ECB PTR                   */ 00546000
         L     R5,CCAACB(,R11)                                  DSKL014 00547000
         L     R5,ACBUAPTR(,R5)                                 DSKL014 00548000
         L     R1,CAXDRWP(,R5)                                  DSKL014 00549000
         LA    R1,DRWECB(,R1)                                      0340 00550000
*               GEN(WAIT ECB=(1));  /* ISSUE WAIT                    */ 00551000
         WAIT ECB=(1)                                                   00552000
*               IF DRWECMP^='7F'X THEN/* IF I/O ERROR                */ 00553000
         L     R5,CCAACB(,R11)                                  DSKL014 00554000
         L     R5,ACBUAPTR(,R5)                                 DSKL014 00555000
         L     R5,CAXDRWP(,R5)                                  DSKL014 00556000
         CLI   DRWECMP(R5),X'7F'                                DSKL014 00557000
         BE    @RF00342                                            0342 00558000
*                 DO;                                              0343 00559000
*                                                                  0343 00560000
*                   /*************************************************/ 00561000
*                   /*                                               */ 00562000
*                   /* SET CCAMODID='BI', CCAREASN=RSN4,             */ 00563000
*                   /* CCARETRN=RCIONL                               */ 00564000
*                   /*                                               */ 00565000
*                   /*************************************************/ 00566000
*                                                                  0344 00567000
*                   CCAPROB=IGGSEGID+(RSN4*K256)+RCIONL;/* ECD: I/O     00568000
*                                      ERROR. RCD: I/O ERROR DOING 0344 00569000
*                                      EXCP DURING A CATALOG OPEN    */ 00570000
         MVC   CCAPROB(4,R11),@CF03436                             0344 00571000
*                   GEN(BC 0,X'8F2'(0,12));/* H2-EXCP I/O ERROR      */ 00572000
         BC 0,X'8F2'(0,12)                                              00573000
*                   CALL EXIT;      /* RETURN TO CALLER              */ 00574000
         BAL   R14,EXIT                                         DSKL014 00575000
*                 END;                                             0347 00576000
*               ELSE                                               0348 00577000
*                 ;                 /* NO I/O ERROR OCCURRED         */ 00578000
@RF00342 DS    0H                                                  0349 00579000
*             END;                  /* END 'DO' FOR NO RECORD IN DRWA*/ 00580000
*           ELSE                                                   0350 00581000
*             ;                     /* REQUESTED RECORD IS IN DRWA   */ 00582000
@RF00335 DS    0H                                                  0351 00583000
*           TORECAR(1:255)=DRWRIA(1:255);/* MOVE FIRST HALF OF RECORD   00584000
*                                      TO RECORD AREA                */ 00585000
         L     R5,CCAURAB(,R11)                                 DSKL014 00586000
         L     R5,CCACPE1(,R5)                                  DSKL014 00587000
         L     R15,CCAACB(,R11)                                 DSKL014 00588000
         L     R15,ACBUAPTR(,R15)                               DSKL014 00589000
         L     R15,CAXDRWP(,R15)                                DSKL014 00590000
         MVC   TORECAR(255,R5),DRWRIA(R15)                      DSKL014 00591000
*           TORECAR(256:505)=DRWRIA(256:505);/* MOVE SECOND HALF OF     00592000
*                                      RECORD TO RECORD AREA         */ 00593000
         MVC   TORECAR+255(250,R5),DRWRIA+255(R15)              DSKL014 00594000
         MVC   TORECAR+505(7,R5),A001449                        DSKL014 00594010
*         END;                      /* END 'DO' FOR CATALOG OPEN     */ 00595000
*       ELSE                        /* CATALOG BUILD                 */ 00596000
*         DO;                       /* LOCATE AND MOVE REQD ENTRY    */ 00597000
         B     @RC00333                                            0354 00598000
@RF00333 DS    0H                                                  0355 00599000
*           R0=CCASRCIN+ONE;        /* INDEX TO REQUIRED CI          */ 00600000
         LA    R0,1                                                0355 00601000
         SLR   R5,R5                                            DSKL014 00602000
         ICM   R5,7,CCASRCIN(R11)                               DSKL014 00603000
         ALR   R0,R5                                            DSKL014 00604000
*           R1=CAXCCA;              /* POINT TO BUILD CCA            */ 00605000
         L     R5,CCAACB(,R11)                                  DSKL014 00606000
         L     R15,ACBUAPTR(,R5)                                DSKL014 00607000
         L     R1,CAXCCA(,R15)                                  DSKL014 00608000
*           RFY                                                    0357 00609000
*             IGGCCA BASED(R1);     /* BASE ON OLD CCA               */ 00610000
*           IF R11->CCAACB->ACBSCRA=OFF THEN/* NOT CRA BUILD REQUEST */ 00611000
         TM    ACBSCRA(R5),B'00001000'                          DSKL014 00612000
         BNZ   @RF00358                                            0358 00613000
*             R1=CMSCTREC(R0);      /* GET PTR TO CORE OF RECORD     */ 00614000
         LR    R5,R0                                            DSKL014 00615000
         SLA   R5,2                                             DSKL014 00616000
         L     R15,CCACMSWA(,R1)                                DSKL014 00617000
         L     R5,CMSCTREC-4(R5,R15)                            DSKL014 00618000
         LR    R1,R5                                            DSKL014 00619000
*           ELSE                    /* BUILD CRA AND CRA OPEN        */ 00620000
*             R1=DCRACIPT(R0);      /* GET CRA RECORD FROM STORGE    */ 00621000
         B     @RC00358                                            0360 00622000
@RF00358 LR    R5,R0                                            DSKL014 00623000
         SLA   R5,2                                             DSKL014 00624000
         L     R15,CCACRACI(,R1)                                DSKL014 00625000
         AL    R15,@CF03466                                     DSKL014 00626000
         L     R5,DCRACIPT(R5,R15)                              DSKL014 00627000
         LR    R1,R5                                            DSKL014 00628000
*           RFY                                                    0361 00629000
*             IGGCCA BASED(R11);    /* RESTORE TO NORMAL             */ 00630000
@RC00358 DS    0H                                                  0362 00631000
*           TORECAR(1:255)=CBRECAR(1:255);/* MOVE ENTRY TO           */ 00632000
         L     R5,CCAURAB(,R11)                                 DSKL014 00633000
         L     R5,CCACPE1(,R5)                                  DSKL014 00634000
         MVC   TORECAR(255,R5),CBRECAR(R1)                      DSKL014 00635000
*           TORECAR(256:505)=CBRECAR(256:505);/* RECORD AREA         */ 00636000
         MVC   TORECAR+255(250,R5),CBRECAR+255(R1)              DSKL014 00637000
         MVC   TORECAR+505(7,R5),A001449                        DSKL014 00637010
*         END;                      /* END 'DO' FOR CATLAOG BUILD    */ 00638000
*     END;                          /* END OF CAT BLD/OPEN PROC.     */ 00639000
@RC00333 DS    0H                                                  0366 00640000
*/********************************************************************/ 00641000
*/*                CHECK  VALIDITY  OF  GOTTEN  RECORD               */ 00642000
*/********************************************************************/ 00643000
*                                                                  0366 00644000
*   IF CCAF1UP=ON THEN              /* IF GET FOR UPDATE REQUEST     */ 00645000
@RC00275 TM    CCAF1UP(R11),B'00000010'                            0366 00646000
         BNO   @RF00366                                            0366 00647000
*     CCARBUPD=ON;                  /* SET RAB SET-UPD STATUS FLAG   */ 00648000
         L     R5,CCAURAB(,R11)                                 DSKL014 00649000
         OI    CCARBUPD(R5),B'00000001'                         DSKL014 00650000
*   ELSE                                                           0368 00651000
*     ;                             /* NOT GET-FOR-UPDATE REQUEST    */ 00652000
@RF00366 DS    0H                                                  0369 00653000
*   IF RCDKEYTY^=ZERO THEN          /* IF END OF LOW KEY             */ 00654000
         L     R5,CCAURAB(,R11)                                 DSKL014 00655000
         L     R5,CCACPE1(,R5)                                  DSKL014 00656000
         CLI   RCDKEYTY(R5),0                                   DSKL014 00657000
         BE    A00048C                                          DSKL014 00658000
*     DO;                           /* ERROR EXIT: NOT LOW KEY RANGE */ 00659000
*                                                                  0370 00660000
*       /*************************************************************/ 00661000
*       /*                                                           */ 00662000
*       /* SET CCAMODID='BI', CCAREASN=RSN0, CCARETRN=RCHIGH         */ 00663000
*       /*                                                           */ 00664000
*       /*************************************************************/ 00665000
*                                                                  0371 00666000
*       CCAPROB=IGGSEGID+(RSN0*K256)+RCHIGH;/* ECD: NOT LOW KEY RANGE   00667000
*                                      RECORD ON CI GET. RCD: KEY  0371 00668000
*                                      TYPE OF RETRIEVED RECORD NOT 0   00669000
*                                      FOR A CI GET.                 */ 00670000
         MVC   CCAPROB(4,R11),@CF03437                             0371 00671000
*       CALL EXIT;                  /* RETURN TO CALLER              */ 00672000
*     END;                          /* END OF EXCEED KEY RANGE       */ 00674000
*   ELSE                                                           0374 00675000
*     ;                             /* NOT END OF LOW KEY RANGE      */ 00676000
@RF00369 DS    0H                                                  0375 00677000
*   IF RCDID='F' THEN               /* IF FREE RECORD,               */ 00678000
*     DO;                           /* THEN REQUEST IS INVALID       */ 00683000
*                                                                  0376 00684000
*       /*************************************************************/ 00685000
*       /*                                                           */ 00686000
*       /* IF LISTCAT GET NEXT ,SET INVALID CI & PASS NAME BACK      */ 00687000
*       /*                                                           */ 00688000
*       /*************************************************************/ 00689000
*                                                                  0377 00690000
*       IF CTGFUNC=CTGCMS&CTGOPTNS=CTGLTCAT&CTGGTNXT=ON THEN       0377 00691000
         L     R5,CCACPL(,R11)                                  DSKL014 00692000
         TM    CTGFUNC(R5),B'10000000'                          DSKL014 00693000
         BNO   A000470                                          DSKL014 00694000
         TM    CTGFUNC(R5),B'01100000'                          DSKL014 00695000
         BNZ   A000470                                          DSKL014 00696000
         TM    CTGOPTNS(R5),X'18'                               DSKL014 00696010
         BNO   A000470                                          DSKL014 00696020
         TM    CTGOPTNS(R5),X'E0'                               DSKL014 00696030
         BZ    A000488                                          DSKL014 00696040
A000470  MVI   CCACRRP(R11),X'80'                               DSKL014 00696050
         L     R15,@CV03234                                     DSKL014 00696060
         BALR  R14,R15                                          DSKL014 00696070
         LA    R10,4095(,R12)                                   DSKL014 00696080
         L     R15,@CV03233                                     DSKL014 00696090
         BALR  R14,R15                                          DSKL014 00696100
         LA    R10,4095(,R12)                                   DSKL014 00696110
A000488  BAL   R14,EXIT                                         DSKL014 00696120
A00048C  L     R5,CCAURAB(,R11)                                 DSKL014 00696130
         L     R5,CCACPE1(,R5)                                  DSKL014 00696140
         CLI   RCDID(R5),C'F'                                   DSKL014 00696150
         BNE   @RF00375                                         DSKL014 00696160
         L     R5,CCACPL(,R11)                                  DSKL014 00696170
         TM    CTGFUNC(R5),X'80'                                DSKL014 00696180
         BNO   @RF00377                                         DSKL014 00696190
         TM    CTGFUNC(R5),X'60'                                DSKL014 00696200
         BNZ   @RF00377                                         DSKL014 00696210
         TM    CTGOPTNS(R5),X'20'                               DSKL014 00696220
         BNO   @RF00377                                         DSKL014 00696230
         TM    CTGOPTNS(R5),B'11011000'                         DSKL014 00697000
         BNZ   @RF00377                                         DSKL014 00698000
         TM    CTGGTNXT(R5),X'10'                               DSKL014 00698010
         BNO   @RF00377                                         DSKL014 00698020
*         DO;                       /* MOVE TRU NAM TO CPL   @ZA06148*/ 00703000
*           ENTRYNAM=ARAKEY;        /* TRUE NAME             @ZA06148*/ 00704000
*                                                                  0379 00705000
         L     R5,CTGENT(,R5)                                   DSKL014 00706000
         L     R15,CCAR0REC(,R11)                               DSKL014 00707000
         MVC   ENTRYNAM(44,R5),ARAKEY(R15)                      DSKL014 00708000
*           /*********************************************************/ 00709000
*           /*                                                       */ 00710000
*           /* SET CCAMODID='BI', CCAREASN=RSN10, CCARETRN=RCINCI    */ 00711000
*           /*                                                       */ 00712000
*           /*********************************************************/ 00713000
*                                                                  0380 00714000
*           CCAPROB=IGGSEGID+(RSN10*K256)+RCINCI;/* INVALID CI     0380 00715000
*                                                            @ZA06148*/ 00716000
         MVC   CCAPROB(4,R11),@CF03440                             0380 00717000
*         END;                                                     0381 00718000
*       ELSE                        /* NOT LISTCAT           @ZA06148*/ 00719000
*                                                                  0382 00720000
*         /***********************************************************/ 00721000
*         /*                                                         */ 00722000
*         /* SET CCAMODID='BI', CCAREASN=RSN4, CCARETRN=RCENT        */ 00723000
*         /*                                                         */ 00724000
*         /***********************************************************/ 00725000
*                                                                  0382 00726000
*         CCAPROB=IGGSEGID+(RSN4*K256)+RCENT;/* ECD: ENTRY DOES NOT     00727000
*                                      EXIST. RCD: GET FOR UPDATE  0382 00728000
*                                      FOUND A FREE RECORD INSTEAD OF   00729000
*                                      CORRECT RECORD.               */ 00730000
         B     @RC00377                                            0382 00731000
@RF00377 MVC   CCAPROB(4,R11),@CF03441                             0382 00732000
*       CALL EXIT;                  /* RETURN TO CALLER              */ 00733000
@RC00377 BAL   R14,EXIT                                         DSKL014 00734000
*     END;                                                         0384 00735000
*   ELSE                                                           0385 00736000
*     ;                             /* GOTTEN RECORD NOT TYPE 'F'    */ 00737000
@RF00375 DS    0H                                                  0386 00738000
*   IF RCDID='L' THEN               /* IF CCR RECORD                 */ 00739000
         L     R5,CCAURAB(,R11)                                 DSKL014 00740000
         L     R5,CCACPE1(,R5)                                  DSKL014 00741000
         CLI   RCDID(R5),C'L'                                   DSKL014 00742000
         BNE   @RF00386                                            0386 00743000
*     DO;                                                          0387 00744000
*       IF RCDCINO=CCRCINO THEN     /* IF ITS CI NO. 3               */ 00745000
*                                                                  0388 00746000
         CLC   RCDCINO(3,R5),@CF00414+1                         DSKL014 00747000
         BNE   @RF00388                                            0388 00748000
*         /***********************************************************/ 00749000
*         /*                                                         */ 00750000
*         /* SET CCAMODID='BI', CCAREASN=RSN6, CCARETRN=RCINCI       */ 00751000
*         /*                                                         */ 00752000
*         /***********************************************************/ 00753000
*                                                                  0389 00754000
*         CCAPROB=IGGSEGID+(RSN6*K256)+RCINCI;/* ECD: INVALID CI   0389 00755000
*                                      NUMBER. RCD: CCR ILLEGALLY  0389 00756000
*                                      RETRIEVED.                    */ 00757000
         MVC   CCAPROB(4,R11),@CF03444                             0389 00758000
*       ELSE                                                       0390 00759000
*         ;                         /* GOTTEN RECORD NOT CI 3        */ 00760000
@RF00388 DS    0H                                                  0391 00761000
*       CALL EXIT;                  /* RETURN TO CALLER              */ 00762000
         BAL   R14,EXIT                                         DSKL014 00763000
*     END;                                                         0392 00764000
*   ELSE                                                           0393 00765000
*     ;                             /* GOTTEN RECORD NOT TYPE 'L'    */ 00766000
@RF00386 DS    0H                                                  0394 00767000
*/********************************************************************/ 00768000
*/*          ESTABLISH  CATALOG  RECORD  SEGMENT  POINTERS           */ 00769000
*/********************************************************************/ 00770000
*                                                                  0394 00771000
*GETFNDEX:                                                         0394 00772000
*   ;                               /* RECORD FOUND EXIT POINT       */ 00773000
GETFNDEX DS    0H                                                  0395 00774000
*   R1=CCACPE1+NREPLF;              /* POINT TO FIRST VARIABLE FIELD */ 00775000
         L     R5,CCAURAB(,R11)                                 DSKL014 00776000
         L     R5,CCACPE1(,R5)                                  DSKL014 00777000
         SLR   R1,R1                                               0395 00778000
         IC    R1,NREPLF(,R5)                                   DSKL014 00779000
         ALR   R1,R5                                            DSKL014 00780000
*   DO LPINDX=1 TO NREPCV;          /* DO FOR ALL VAR FIELDS @XM01569*/ 00781000
         LA    R5,1                                             DSKL014 00782000
         B     @DE00396                                            0396 00783000
@DL00396 DS    0H                                                  0397 00784000
*     R1=R1+GCRVFL+TWO;             /* ADD VARIABLE FIELD LENGTH     */ 00785000
         LR    R5,R1                                            DSKL014 00786000
         AH    R5,GCRVFL(,R1)                                   DSKL014 00787000
         AL    R5,@CF00055                                      DSKL014 00788000
         LR    R1,R5                                            DSKL014 00789000
*   END;                                                           0398 00790000
         LA    R5,1                                             DSKL014 00791000
         SLR   R15,R15                                          DSKL014 00792000
         IC    R15,LPINDX(,R11)                                 DSKL014 00793000
         ALR   R5,R15                                           DSKL014 00794000
@DE00396 STC   R5,LPINDX(,R11)                                  DSKL014 00795000
         L     R15,CCAURAB(,R11)                                DSKL014 00796000
         L     R15,CCACPE1(,R15)                                DSKL014 00797000
         SLR   R14,R14                                          DSKL014 00798000
         IC    R14,NREPCV(,R15)                                 DSKL014 00799000
         CR    R5,R14                                           DSKL014 00800000
         BNH   @DL00396                                            0398 00801000
*   CCACPE2=R1;                     /* SET PTR TO REPEATING FIELDS 0399 00802000
*                                      CONTROL INFORMATION           */ 00803000
         L     R5,CCAURAB(,R11)                                 DSKL014 00804000
         ST    R1,CCACPE2(,R5)                                  DSKL014 00805000
*   LPSTOP=LENGTH(CATGOPT);         /* SET NORMAL ENTRY GOP LENGTH   */ 00806000
         MVI   LPSTOP(R11),X'05'                                   0400 00807000
*   DO LPINDX=1 TO(LENGTH(VOLTYPES)) WHILE(LPSTOP=LENGTH(CATGOPT));/*   00808000
*                                      CHECK FOR VOL ENTRY CLASS     */ 00809000
         LA    R5,1                                             DSKL014 00810000
         STC   R5,LPINDX(,R11)                                  DSKL014 00811000
@DL00401 CLI   LPSTOP(R11),5                                       0401 00812000
         BNE   @DC00401                                            0401 00813000
*     IF RCDID=VOLTYPES(LPINDX:LPINDX) THEN/* VOL ENT CLASS          */ 00814000
         L     R5,CCAURAB(,R11)                                 DSKL014 00815000
         L     R5,CCACPE1(,R5)                                  DSKL014 00816000
         SLR   R15,R15                                          DSKL014 00817000
         IC    R15,LPINDX(,R11)                                 DSKL014 00818000
         LA    R14,VOLTYPES-1(R15)                              DSKL014 00819000
         CLC   RCDID(1,R5),0(R14)                               DSKL014 00820000
         BNE   @RF00402                                            0402 00821000
*       LPSTOP=LENGTH(CTVGOPT);     /* SET VOL CLASS GOP LENGTH      */ 00822000
         MVI   LPSTOP(R11),X'06'                                   0403 00823000
*     ELSE                                                         0404 00824000
*       ;                           /* VOLUME RECORD TYPES UNEQUAL   */ 00825000
@RF00402 DS    0H                                                  0405 00826000
*   END;                            /* END VOLUME RECORD SEARCH      */ 00827000
         LA    R5,1                                             DSKL014 00828000
         SLR   R15,R15                                          DSKL014 00829000
         IC    R15,LPINDX(,R11)                                 DSKL014 00830000
         ALR   R5,R15                                           DSKL014 00831000
         STC   R5,LPINDX(,R11)                                  DSKL014 00832000
         CH    R5,@CH00055                                      DSKL014 00833000
         BNH   @DL00401                                            0405 00834000
@DC00401 DS    0H                                                  0406 00835000
*   CCACPE3=CCACPE2+REPCNT*LPSTOP   /* SET POINTER TO FIRST          */ 00836000
*       +LENGTH(EXTRCDPT)+LENGTH(REPCNT);/* GROUP OCCUR              */ 00837000
         L     R5,CCAURAB(,R11)                                 DSKL014 00838000
         L     R15,CCACPE2(,R5)                                 DSKL014 00839000
         SLR   R7,R7                                            DSKL014 00840000
         IC    R7,LPSTOP(,R11)                                  DSKL014 00841000
         SLR   R14,R14                                          DSKL014 00842000
         IC    R14,REPCNT(,R15)                                 DSKL014 00843000
         MR    R6,R14                                           DSKL014 00844000
         ALR   R15,R7                                           DSKL014 00845000
         AH    R15,@CH00051                                     DSKL014 00846000
         ST    R15,CCACPE3(,R5)                                 DSKL014 00847000
*   CCACPE4=CCACPE1+RCDSIZ;         /* SET POINTER TO END OF RECORD  */ 00848000
         L     R15,CCACPE1(,R5)                                 DSKL014 00849000
         LH    R14,RCDSIZ(,R15)                                 DSKL014 00850000
         ALR   R14,R15                                          DSKL014 00851000
         ST    R14,CCACPE4(,R5)                                 DSKL014 00852000
*   IF CAXF2REC=ON&RCDID=CTGTVOL THEN/* REC CAT AND VOL REC          */ 00853000
         L     R5,CCAACB(,R11)                                  DSKL014 00854000
         L     R5,ACBUAPTR(,R5)                                 DSKL014 00855000
         TM    CAXF2REC(R5),B'00000010'                         DSKL014 00856000
         BNO   @RF00408                                            0408 00857000
         CLI   RCDID(R15),C'V'                                  DSKL014 00858000
         BNE   @RF00408                                            0408 00859000
*     CCAVTS=CTVOLTIM;              /* SAVE VOLUME TIME STAMP        */ 00860000
         MVC   CCAVTS(8,R11),CTVOLTIM+48(R15)                   DSKL014 00861000
*   ELSE                                                           0410 00862000
*     ;                             /* NOT RECOV CAT OR NOT VOL REC  */ 00863000
@RF00408 DS    0H                                                  0411 00864000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 00865000
         BAL   R14,EXIT                                         DSKL014 00866000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 00867000
         DC    X'A02C'                       !!! SOURCE COMPARE FIX !!! 00868000
         DS 0F                                                          00868000
*   GEN(DC CL8'IGGPXIO');           /* NAME OF FOLLOWING PROCEDURE   */ 00869000
         DC CL8'IGGPXIO'                                                00870000
*   END;                            /* END OF INNER PROCEDURE        */ 00871000
@EL00003 DS    0H                                                  0414 00872000
@EF00003 DS    0H                                                  0414 00873000
@ER00003 BR    R14                                              DSKL014 00874000
@PB00003 DS    0H                                                  0415 00875000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 00876000
         EJECT                                                          00877000
*                                                                  0416 00878000
*/********************************************************************/ 00879000
*/*                                                                  */ 00880000
*/*        IGGPXIO  -  PROCEDURE  INTERNALLY  CALLED  NESTED         */ 00881000
*/*                                                                  */ 00882000
*/********************************************************************/ 00883000
*                                                                  0416 00884000
*IGGPXIO:                                                          0416 00885000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 00886000
IGGPXIO  DS    0H                                                  0417 00888000
*Z020:                              /* LABEL FOR PROCEDURE TRACKING  */ 00889000
*Z020XIO:                           /* LABEL FOR PROCEDURE TRACKING  */ 00890000
*   RFY                                                            0417 00891000
*    (R5,                                                          0417 00892000
*     R6,                                                          0417 00893000
*     R7,                                                          0417 00894000
*     R8,                                                          0417 00895000
*     R9,                                                          0417 00896000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 00897000
Z020     DS    0H                                                  0417 00898000
Z020XIO  DS    0H                                                  0418 00899000
*   RFY                                                            0418 00900000
*    (R2,                                                          0418 00901000
*     R3,                                                          0418 00902000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 00903000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 00904000
         STM   R12,R14,12(R13)         SAVE REGISTERS OF CALLER DSKL014 00905000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 00906000
         LA    R13,12(R13)             POINT TO NEXT SAVE AREA  DSKL014 00907000
*/********************************************************************/ 00908000
*/*        INTERNAL  PROCEDURE  TO  INTERFACE  TO  THE  VSAM         */ 00909000
*/*        GET,  PUT,  AND  ERASE  FUNCTIONS                         */ 00910000
*/********************************************************************/ 00911000
*                                                                  0421 00912000
*   IF XIOTNE=ON THEN               /* IF TRUE NAME ENTRY REQUEST    */ 00913000
         TM    XIOTNE(R11),B'00000010'                             0421 00914000
         BNO   @RF00421                                            0421 00915000
*     RPLRLEN=TNLEN;                /* SET TRUE NAME ENTRY LENGTH    */ 00916000
         L     R5,CCARPL1(,R11)                                 DSKL014 00917000
         MVC   RPLRLEN(4,R5),@CF03273                           DSKL014 00918000
*   ELSE                            /* NOT TRUE NAME ENTRY REQUEST   */ 00919000
*     RPLRLEN=CELEN;                /* SET NORMAL ENTRY LENGTH       */ 00920000
         B     @RC00421                                            0423 00921000
@RF00421 L     R5,CCARPL1(,R11)                                 DSKL014 00922000
         MVC   RPLRLEN(4,R5),@CF03276                           DSKL014 00923000
*   IF XIOARA=ON THEN               /* IF AUXILIARY RECORD AREA REQ. */ 00924000
@RC00421 TM    XIOARA(R11),B'00100000'                             0424 00925000
         BNO   @RF00424                                            0424 00926000
*     RPLAREA=CCAR0REC;             /* SET POINTER TO ARA            */ 00927000
         L     R5,CCARPL1(,R11)                                 DSKL014 00928000
         MVC   RPLAREA(4,R5),CCAR0REC(R11)                      DSKL014 00929000
*   ELSE                            /* NO AUXILIARY RECRD AREA NEEDED*/ 00930000
*     DO;                                                          0426 00931000
         B     @RC00424                                            0426 00932000
@RF00424 DS    0H                                                  0427 00933000
*       RPLAREA=CCACPE1;            /* SET PTR TO USER RECORD AREA   */ 00934000
         L     R5,CCARPL1(,R11)                                 DSKL014 00935000
         L     R15,CCAURAB(,R11)                                DSKL014 00936000
         MVC   RPLAREA(4,R5),CCACPE1(R15)                       DSKL014 00937000
*       CCARBUPD=OFF;               /* RESET GET-UPDATE STATUS FLAG  */ 00938000
         NI    CCARBUPD(R15),B'11111110'                        DSKL014 00939000
*     END;                                                         0429 00940000
*   RPLARG=ADDR(CCASRCH);           /* SET UP SEARCH ARGUMENT PTR    */ 00941000
@RC00424 L     R5,CCARPL1(,R11)                                 DSKL014 00942000
         LA    R15,CCASRCH(,R11)                                DSKL014 00943000
         ST    R15,RPLARG(,R5)                                  DSKL014 00944000
*   IF XIOGET=OFF&                  /* PUT REQUEST AND               */ 00945000
*       XIOSEQ=ON THEN              /* SEQUENTIAL REQUEST            */ 00946000
         TM    XIOSEQ(R11),B'00000001'                             0431 00947000
         BNO   @RF00431                                            0431 00948000
         TM    XIOGET(R11),B'10000000'                             0431 00949000
         BNZ   @RF00431                                            0431 00950000
*     DO;                                                          0432 00951000
*       RPLDIR=OFF;                 /* SET UP TO PERFORM             */ 00952000
*       RPLSEQ=ON;                  /* SEQUENTIAL OPERATION          */ 00953000
         OI    RPLSEQ(R5),B'00100000'                           DSKL014 00954000
         NI    RPLDIR(R5),B'10111111'                           DSKL014 00955000
*     END;                                                         0435 00956000
*   ELSE                            /* NOT PUT-SEQUENTIAL REQUEST    */ 00957000
*     DO;                                                          0436 00958000
         B     @RC00431                                            0436 00959000
@RF00431 DS    0H                                                  0437 00960000
*       RPLDIR=ON;                  /* SET UP TO PERFORM             */ 00961000
*       RPLSEQ=OFF;                 /* DIRECT OPERATION PROCESSING   */ 00962000
         L     R5,CCARPL1(,R11)                                 DSKL014 00963000
         OI    RPLDIR(R5),B'01000000'                           DSKL014 00964000
         NI    RPLSEQ(R5),B'11011111'                           DSKL014 00965000
*     END;                                                         0439 00966000
*   RPLKGE=OFF;                     /* CLEAR GT/EQ SEARCH KEY FLAG   */ 00967000
@RC00431 L     R5,CCARPL1(,R11)                                 DSKL014 00968000
         NI    RPLKGE(R5),B'11111011'                           DSKL014 00969000
*   RPLKEY=OFF;                     /* CLEAR KEYED-ACCESS FLAG       */ 00970000
*   RPLADR=OFF;                     /* CLEAR ACCESS-BY-LOCATION FLAG */ 00971000
*   RPLCNV=OFF;                     /* CLEAR CNV ACCESS FLAG         */ 00972000
*   RPLUPD=OFF;                     /* CLEAR UPDATE FLAG             */ 00973000
         NI    RPLKEY(R5),B'00011101'                           DSKL014 00974000
*   IF XIOKGE=ON THEN               /* IF GET NEXT REQUEST,          */ 00975000
         TM    XIOKGE(R11),B'00000001'                             0445 00976000
         BNO   @RF00445                                            0445 00977000
*     RPLKGE=ON;                    /* SET KEY GT/EQ BIT             */ 00978000
         OI    RPLKGE(R5),B'00000100'                           DSKL014 00979000
*   ELSE                                                           0447 00980000
*     ;                             /* NOT GET-NEXT REQUEST          */ 00981000
@RF00445 DS    0H                                                  0448 00982000
*   IF XIOKEY=ON THEN               /* IF KEYED REQUEST,             */ 00983000
         TM    XIOKEY(R11),B'00010000'                             0448 00984000
         BNO   @RF00448                                            0448 00985000
*     RPLKEY=ON;                    /* SET KEYED REQUEST BIT         */ 00986000
         L     R5,CCARPL1(,R11)                                 DSKL014 00987000
         OI    RPLKEY(R5),B'10000000'                           DSKL014 00988000
*   ELSE                            /* OTHERWISE, 512-BYTE CI REQ    */ 00989000
*     DO;                           /* CI PROCESSING                 */ 00990000
         B     @RC00448                                            0450 00991000
@RF00448 DS    0H                                                  0451 00992000
*       RPLRLEN=CILEN;              /* SET THE CI LENGTH             */ 00993000
         L     R5,CCARPL1(,R11)                                 DSKL014 00994000
         MVC   RPLRLEN(4,R5),@CF01046                           DSKL014 00995000
*       RPLCNV=ON;                  /* INDICATE CI PROCESSING        */ 00996000
         OI    RPLCNV(R5),B'00100000'                           DSKL014 00997000
*     END;                                                         0453 00998000
*   IF XIONUP=OFF THEN              /* IF UPDATE REQUEST,            */ 00999000
@RC00448 TM    XIONUP(R11),B'00001000'                             0454 01000000
         BNZ   @RF00454                                            0454 01001000
*     RPLUPD=ON;                    /* SET UPDATE BIT                */ 01002000
         L     R5,CCARPL1(,R11)                                 DSKL014 01003000
         OI    RPLUPD(R5),B'00000010'                           DSKL014 01004000
*   ELSE                                                           0456 01005000
*     ;                             /* NOT GET-FOR-UPDATE REQUEST    */ 01006000
@RF00454 DS    0H                                                  0457 01007000
*   R1=CCARPL1;                     /* SET POINTER TO RPL            */ 01008000
         L     R1,CCARPL1(,R11)                                    0457 01009000
*   R13=R13+TWELVE;                 /* PROVIDE RECD. MGMT. SAVE AREA */ 01010000
         AH    R13,@CH00072                                        0458 01011000
*   IF XIOGET=ON THEN               /* IF GET REQUEST,               */ 01012000
         TM    XIOGET(R11),B'10000000'                             0459 01013000
         BNO   A00086A                                          DSKL014 01014000
*     GEN(GET RPL=(1));             /* ISSUE GET MACRO               */ 01015000
         GET RPL=(1)                                                    01016000
*   ELSE                            /* NOT A GET REQUEST             */ 01017000
*     IF XIOERS=ON THEN             /* IF ERASE REQUEST,             */ 01018000
@RF00459 DS    0H                                               DSKL014 01020000
         L     R5,CCARPL1(,R11)                                 DSKL014 01021000
         CLI   RPLRTNCD(R5),0                                   DSKL014 01021010
         BNE   A000866                                          DSKL014 01021020
         L     R5,RPLAREA(,R5)                                  DSKL014 01021030
         CLI   RCDKEYTY(R5),X'00'                               DSKL014 01021040
         BNE   A000866                                          DSKL014 01021050
         CLI   RCDID(R5),C'F'                                   DSKL014 01021060
         BE    A00076C                                          DSKL014 01021070
         CLI   RCDID(R5),C'L'                                   DSKL014 01021080
         BE    A00076C                                          DSKL014 01021090
         LH    R15,RCDSIZ(,R5)                                  DSKL014 01021100
         CH    R15,@CF03276+2                                   DSKL014 01021110
         BNH   A00076C                                          DSKL014 01021120
         SH    R13,@CH00072                                     DSKL014 01021130
         SLR   R15,R15                                          DSKL014 01021140
         ICM   R15,7,RCDCINO(R5)                                DSKL014 01021150
         SLA   R15,9                                            DSKL014 01021160
         ST    R15,CCASRCH(,R11)                                DSKL014 01021170
         MVC   CCAPROB(4,R11),A00139C                           DSKL014 01021180
         MVI   CCACRRP(R11),X'80'                               DSKL014 01021190
         L     R15,@CV03234                                     DSKL014 01021200
         BALR  R14,R15                                          DSKL014 01021210
         LA    R10,4095(,R12)                                   DSKL014 01021220
         L     R15,@CV03233                                     DSKL014 01021230
         BALR  R14,R15                                          DSKL014 01021240
         LA    R10,4095(,R12)                                   DSKL014 01021250
         OI    CCAFLG11(R11),X'10'                              DSKL014 01021260
         L     R5,CCAPROB(,R11)                                 DSKL014 01021270
         LR    R15,R5                                           DSKL014 01021280
         XR    R15,R5                                           DSKL014 01021290
         ST    R15,CCAPROB(,R11)                                DSKL014 01021300
         AH    R13,@CH00072                                     DSKL014 01021310
A00076C  L     R5,CCARPL1(,R11)                                 DSKL014 01021320
         L     R5,RPLAREA(,R5)                                  DSKL014 01021330
         CLI   RCDID(R5),C'V'                                   DSKL014 01021340
         BE    A000784                                          DSKL014 01021350
         CLI   RCDID(R5),C'W'                                   DSKL014 01021360
         BNE   A0007E0                                          DSKL014 01021370
A000784  BAL   R14,IGGPVALD                                     DSKL014 01021380
         CLI   LPSTOP(R11),X'00'                                DSKL014 01021390
         BE    A0007E0                                          DSKL014 01021400
         SH    R13,@CH00072                                     DSKL014 01021410
         L     R5,CCARPL1(,R11)                                 DSKL014 01021420
         L     R5,RPLAREA(,R5)                                  DSKL014 01021430
         SLR   R15,R15                                          DSKL014 01021440
         ICM   R15,7,RCDCINO(R5)                                DSKL014 01021450
         SLA   R15,9                                            DSKL014 01021460
         ST    R15,CCASRCH(,R11)                                DSKL014 01021470
         MVI   XIOOPT(R11),X'80'                                DSKL014 01021480
         MVC   CCAPROB(4,R11),A00139C                           DSKL014 01021490
         MVI   CCACRRP(R11),X'80'                               DSKL014 01021500
         L     R15,@CV03234                                     DSKL014 01021510
         BALR  R14,R15                                          DSKL014 01021520
         LA    R10,4095(,R12)                                   DSKL014 01021530
         L     R15,@CV03233                                     DSKL014 01021540
         BALR  R14,R15                                          DSKL014 01021550
         LA    R10,4095(,R12)                                   DSKL014 01021560
         OI    CCAFLG11(R11),X'10'                              DSKL014 01021570
         L     R5,CCAPROB(,R11)                                 DSKL014 01021580
         LR    R15,R5                                           DSKL014 01021590
         XR    R15,R5                                           DSKL014 01021600
         ST    R15,CCAPROB(,R11)                                DSKL014 01021610
         AH    R13,@CH00072                                     DSKL014 01021620
A0007E0  MVI   LPSTOP(R11),X'00'                                DSKL014 01021630
         LA    R5,1                                             DSKL014 01021640
         STC   R5,XIOOPT(,R11)                                  DSKL014 01021650
A0007EC  CLI   LPSTOP(R11),X'00'                                DSKL014 01021660
         BNE   A00082C                                          DSKL014 01021670
         L     R5,CCARPL1(,R11)                                 DSKL014 01021680
         L     R5,RPLAREA(,R5)                                  DSKL014 01021690
         SLR   R15,R15                                          DSKL014 01021700
         IC    R15,XIOOPT(,R11)                                 DSKL014 01021710
         LA    R14,A00143C-1(R15)                               DSKL014 01021720
         CLC   RCDID(1,R5),0(R14)                               DSKL014 01021730
         BNE   A000814                                          DSKL014 01021740
         MVI   LPSTOP(R11),X'01'                                DSKL014 01021750
A000814  LA    R5,1                                             DSKL014 01021760
         SLR   R15,R15                                          DSKL014 01021770
         IC    R15,XIOOPT(,R11)                                 DSKL014 01021780
         ALR   R5,R15                                           DSKL014 01021790
         STC   R5,XIOOPT(,R11)                                  DSKL014 01021800
         CH    R5,A001340                                       DSKL014 01021810
         BNH   A0007EC                                          DSKL014 01021820
A00082C  CLI   LPSTOP(R11),X'00'                                DSKL014 01021830
         BE    A000858                                          DSKL014 01021840
         L     R5,CCARPL1(,R11)                                 DSKL014 01021850
         L     R5,RPLAREA(,R5)                                  DSKL014 01021860
         CLI   RCDID(R5),C'B'                                   DSKL014 01021870
         BNE   A00084C                                          DSKL014 01021880
         MVI   NREPCV(R5),1                                     DSKL014 01021890
         B     A000858                                          DSKL014 01021900
A00084C  L     R5,CCARPL1(,R11)                                 DSKL014 01021910
         L     R5,RPLAREA(,R5)                                  DSKL014 01021920
         MVI   NREPCV(R5),0                                     DSKL014 01021930
A000858  L     R5,CCARPL1(,R11)                                 DSKL014 01021940
         L     R5,RPLAREA(,R5)                                  DSKL014 01021950
         MVC   TORECAR+505(7,R5),A001449                        DSKL014 01021960
A000866  B     @RC00459                                         DSKL014 01021970
A00086A  TM    XIOOPT(R11),X'40'                                DSKL014 01021980
         BNO   @RF00461                                         DSKL014 01021990
         L     R5,CCARPL1(,R11)                                 DSKL014 01022000
         TM    RPLKEY(R5),B'10000000'                           DSKL014 01022010
         BZ    A000894                                          DSKL014 01022020
         L     R15,RPLAREA(,R5)                                 DSKL014 01022030
         CLI   RCDKEYTY(R15),0                                  DSKL014 01022040
         BE    A000894                                          DSKL014 01022050
         CLC   NREPLF(4,R5),@CF03273                            DSKL014 01022060
         BE    A0008A2                                          DSKL014 01022070
A000894  MVC   CCAPROB(4,R11),A0013A8                           DSKL014 01022080
         L     R13,CCAMLRET(,R11)                               DSKL014 01022090
         BAL   R14,EXIT                                         DSKL014 01022100
A0008A2  DS    0H                                               DSKL014 01022110
*       GEN(ERASE RPL=(1));            ISSUE ERASE MACRO        DSKL014 01022900
         ERASE RPL=(1)                                                  01023000
*     ELSE                          /* NOT AN ERASE REQUEST          */ 01024000
*       DO;                         /* PERFORM 'PUT' PROCESSING      */ 01025000
         B     @RC00461                                            0463 01026000
@RF00461 DS    0H                                                  0464 01027000
*         RFY                                                      0464 01028000
*           CTENTREC BASED(RPLAREA);                               0464 01029000
*         IF RCDKCI=CATDTACI&       /* IF PUTTING CI NO. 0 AND       */ 01030000
*             RCDNAME^=CATDTANM&    /* ITS NOT CATALOG DATA          */ 01031000
*             ACBSCRA^=ON THEN      /* NOT CRA DATA                  */ 01032000
         L     R5,CCARPL1(,R11)                                 DSKL014 01033000
         L     R15,RPLAREA(,R5)                                 DSKL014 01034000
         CLI   RCDKEYTY(R15),0                                  DSKL014 01034010
         BNE   @RF00465                                         DSKL014 01034020
         CLC   NREPLF(4,R5),@CF01046                            DSKL014 01034030
         BNE   A00091C                                          DSKL014 01034040
         CLC   TORECAR+505(7,R15),A001449                       DSKL014 01034050
         BE    A00091C                                          DSKL014 01034060
         SH    R13,@CH00072                                     DSKL014 01034070
         SLR   R5,R5                                            DSKL014 01034080
         ICM   R5,7,RCDCINO(R15)                                DSKL014 01034090
         SLA   R5,9                                             DSKL014 01034100
         ST    R5,CCASRCH(,R11)                                 DSKL014 01034110
         MVC   CCAPROB(4,R11),A001394                           DSKL014 01034120
         MVI   CCACRRP(R11),X'80'                               DSKL014 01034130
         L     R15,@CV03234                                     DSKL014 01034140
         BALR  R14,R15                                          DSKL014 01034150
         LA    R10,4095(,R12)                                   DSKL014 01034160
         L     R15,@CV03233                                     DSKL014 01034170
         BALR  R14,R15                                          DSKL014 01034180
         LA    R10,4095(,R12)                                   DSKL014 01034190
         TM    CCAFLG11(R11),16                                 DSKL014 01034200
         BNE   A000914                                          DSKL014 01034210
         BAL   R14,IGGPDUMP                                     DSKL014 01034220
A000914  L     R13,CCAMLRET(,R11)                               DSKL014 01034230
         BAL   R14,EXIT                                         DSKL014 01034240
A00091C  L     R5,CCAACB(,R11)                                  DSKL014 01034250
         TM    ACBINFLG(R5),8                                   DSKL014 01034260
         BO    A0009EC                                          DSKL014 01034270
         L     R5,CCARPL1(,R11)                                 DSKL014 01034280
         L     R5,RPLAREA(,R5)                                  DSKL014 01034290
         ICM   R15,15,RCDKCI(R5)                                DSKL014 01035000
         BNZ   A000942                                          DSKL014 01036000
         CLC   RCDNAME(44,R5),@CC03284                          DSKL014 01037000
         BNE   A00099C                                          DSKL014 01038000
A000942  L     R5,CCARPL1(,R11)                                 DSKL014 01038010
         L     R5,CCAACB(,R5)                                   DSKL014 01039000
         CLC   ACBCOMN(4,R5),A001358                            DSKL014 01040000
         BNE   A00095E                                          DSKL014 01040010
         CLC   49(44,R5),A001410                           ???  DSKL014 01040020
         BNE   A00099C                                          DSKL014 01040030
A00095E  L     R5,CCARPL1(,R11)                                 DSKL014 01040040
         L     R5,RPLAREA(,R5)                                  DSKL014 01040050
         CLC   0(4,R5),@CF00055                            ???  DSKL014 01040060
         BNE   A000982                                          DSKL014 01040070
         L     R15,CCAACB(,R11)                                 DSKL014 01040080
         L     R15,ACBUAPTR(,R15)                               DSKL014 01040090
         CLC   49(44,R5),CAXCNAM(R15)                           DSKL014 01041000
         BNE   A00099C                                          DSKL014 01041010
A000982  L     R5,CCARPL1(,R11)                                 DSKL014 01041020
         L     R5,RPLAREA(,R5)                                  DSKL014 01041030
         CLC   0(4,R5),@CF00414                            ???  DSKL014 01041040
         BNE   A0009EC                                          DSKL014 01041050
         CLI   RCDID(R5),C'L'                                   DSKL014 01041060
         BE    A0009EC                                          DSKL014 01041070
A00099C  SH    R13,@CH00072                                     DSKL014 01041080
         L     R5,CCARPL1(,R11)                                 DSKL014 01041090
         L     R5,RPLAREA(,R5)                                  DSKL014 01042000
         SLR   R15,R15                                          DSKL014 01042010
         ICM   R15,7,RCDCINO(R5)                                DSKL014 01042020
         SLA   R15,9                                            DSKL014 01042030
         ST    R15,CCASRCH(,R11)                                DSKL014 01042040
         MVC   CCAPROB(4,R11),A0013AC                           DSKL014 01042050
         MVI   CCACRRP(R11),X'80'                               DSKL014 01042060
         L     R15,@CV03234                                     DSKL014 01042070
         BALR  R14,R15                                          DSKL014 01042080
         LA    R10,4095(,R12)                                   DSKL014 01042090
         L     R15,@CV03233                                     DSKL014 01043000
         BALR  R14,R15                                          DSKL014 01043010
         LA    R10,4095(,R12)                                   DSKL014 01043020
         TM    CCAFLG11(R11),X'10'                              DSKL014 01043030
         BNE   A0009E0                                          DSKL014 01043040
         BAL   R14,IGGPDUMP                                     DSKL014 01043050
A0009E0  L     R13,CCAMLRET(,R11)                               DSKL014 01043060
         BAL   R14,EXIT                                         DSKL014 01043070
         B     @RF00465                                         DSKL014 01043080
A0009EC  MVI   LPSTOP(R11),0                                    DSKL014 01043090
         LA    R5,1                                             DSKL014 01044000
         STC   R5,XIOOPT(,R11)                                  DSKL014 01044010
A0009F8  CLI   LPSTOP(R11),0                                    DSKL014 01044020
         BNE   A000A38                                          DSKL014 01044030
         L     R5,CCARPL1(,R11)                                 DSKL014 01044040
         L     R5,RPLAREA(,R5)                                  DSKL014 01044050
         SLR   R15,R15                                          DSKL014 01044060
         IC    R15,XIOOPT(,R11)                                 DSKL014 01044070
         LA    R14,A00143C-1(R15)                               DSKL014 01044080
         CLC   RCDID(1,R5),0(R14)                               DSKL014 01044090
         BNE   A000A20                                          DSKL014 01045000
         MVI   LPSTOP(R11),1                                    DSKL014 01045010
A000A20  LA    R5,1                                             DSKL014 01045020
         SLR   R15,R15                                          DSKL014 01045030
         IC    R15,XIOOPT(,R11)                                 DSKL014 01045040
         ALR   R5,R15                                           DSKL014 01045050
         STC   R5,XIOOPT(,R11)                                  DSKL014 01045060
         CH    R5,A001340                                       DSKL014 01045070
         BC    13,A0009F8                                       DSKL014 01045080
A000A38  CLI   LPSTOP(R11),0                                    DSKL014 01045090
         BE    @RF00465                                         DSKL014 01046000
         L     R5,CCARPL1(,R11)                                 DSKL014 01046010
         L     R5,RPLAREA(,R5)                                  DSKL014 01046020
         CLI   RCDID(R5),C'B'                                   DSKL014 01046030
         BNE   A000A58                                          DSKL014 01046040
         CLI   NREPCV(R5),1                                     DSKL014 01046050
         BNE   A000A70                                          DSKL014 01046060
A000A58  L     R5,CCARPL1(,R11)                                 DSKL014 01046070
         L     R5,RPLAREA(,R5)                                  DSKL014 01046080
         CLI   RCDID(R5),C'B'                                   DSKL014 01046090
         BE    A000AC4                                          DSKL014 01047000
         CLI   NREPCV(R5),0                                     DSKL014 01047010
         BE    A000AC4                                          DSKL014 01047020
A000A70  SH    R13,@CH00072                                     DSKL014 01047030
         L     R5,CCARPL1(,R11)                                 DSKL014 01047040
         L     R5,RPLAREA(,R5)                                  DSKL014 01047050
         SLR   R15,R15                                          DSKL014 01047060
         ICM   R15,7,RCDCINO(R5)                                DSKL014 01047070
         SLA   R15,9                                            DSKL014 01047080
         ST    R15,CCASRCH(,R11)                                DSKL014 01047090
         MVI   XIOOPT(R11),0                                    DSKL014 01048000
         MVC   CCAPROB(4,R11),A001398                           DSKL014 01048010
         MVI   CCACRRP(R11),X'80'                               DSKL014 01048020
         L     R15,@CV03234                                     DSKL014 01048030
         BALR  R14,R15                                          DSKL014 01048040
         LA    R10,4095(,R12)                                   DSKL014 01048050
         L     R15,@CV03233                                     DSKL014 01048060
         BALR  R14,R15                                          DSKL014 01048070
         LA    R10,4095(,R12)                                   DSKL014 01048080
         TM    CCAFLG11(R11),16                                 DSKL014 01048090
         BNE   A000AB8                                          DSKL014 01049000
         BAL   R14,IGGPDUMP                                     DSKL014 01049010
A000AB8  L     R13,CCAMLRET(,R11)                               DSKL014 01049020
         BAL   R14,EXIT                                         DSKL014 01049030
         B     A000B30                                          DSKL014 01049040
A000AC4  L     R5,CCARPL1(,R11)                                 DSKL014 01049050
         L     R5,RPLAREA(,R5)                                  DSKL014 01049060
         CLI   RCDID(R5),C'F'                                   DSKL014 01049070
         BE    A000B30                                          DSKL014 01049080
         CLI   RCDID(R5),C'L'                                   DSKL014 01049090
         BE    A000B30                                          DSKL014 01050000
         TM    CCAFLG11(R11),X'10'                              DSKL014 01050010
         BNE   A000B30                                          DSKL014 01050020
         LH    R15,RCDSIZ(,R5)                                  DSKL014 01050030
         CH    R15,@CF03276+2                                   DSKL014 01050040
         BC    13,A000B30                                       DSKL014 01050050
         SH    R13,@CH00072                                     DSKL014 01050060
         SLR   R15,R15                                          DSKL014 01050070
         ICM   R15,7,RCDCINO(R5)                                DSKL014 01050080
         SLA   R15,9                                            DSKL014 01050090
         ST    R15,CCASRCH(,R11)                                DSKL014 01050100
         MVI   XIOOPT(R11),0                                    DSKL014 01050110
         MVC   CCAPROB(4,R11),A00139C                           DSKL014 01050120
         MVI   CCACRRP(R11),X'80'                               DSKL014 01050130
         L     R15,@CV03234                                     DSKL014 01050140
         BALR  R14,R15                                          DSKL014 01050150
         LA    R10,4095(,R12)                                   DSKL014 01050160
         L     R15,@CV03233                                     DSKL014 01050170
         BALR  R14,R15                                          DSKL014 01050180
         LA    R10,4095(,R12)                                   DSKL014 01050190
         BAL   R14,IGGPDUMP                                     DSKL014 01050200
         L     R13,CCAMLRET(,R11)                               DSKL014 01050210
         BAL   R14,EXIT                                         DSKL014 01050220
A000B30  TM    CCAFLG11(R11),X'10'                              DSKL014 01050230
         BNE   @RF00465                                         DSKL014 01050240
         L     R5,CCARPL1(,R11)                                 DSKL014 01050250
         L     R5,RPLAREA(,R5)                                  DSKL014 01050260
         CLI   RCDID(R5),C'V'                                   DSKL014 01050270
         BE    A000B50                                          DSKL014 01050280
         CLI   RCDID(R5),C'W'                                   DSKL014 01050290
         BNE   @RF00465                                         DSKL014 01050300
A000B50  BAL   R14,IGGPVALD                                     DSKL014 01050310
         CLI   LPSTOP(R11),0                                    DSKL014 01050320
         BE    @RF00465                                         DSKL014 01050330
         SH    R13,@CH00072                                     DSKL014 01050340
         L     R5,CCARPL1(,R11)                                 DSKL014 01050350
         L     R5,RPLAREA(,R5)                                  DSKL014 01050360
         SLR   R15,R15                                          DSKL014 01050370
         ICM   R15,7,RCDCINO(R5)                                DSKL014 01050380
         SLA   R15,9                                            DSKL014 01050390
         ST    R15,CCASRCH(,R11)                                DSKL014 01050400
         MVI   XIOOPT(R11),0                                    DSKL014 01050410
         MVC   CCAPROB(4,R11),A00139C                           DSKL014 01050420
         MVI   CCACRRP(R11),X'80'                               DSKL014 01050430
         L     R15,@CV03234                                     DSKL014 01050440
         BALR  R14,R15                                          DSKL014 01050450
         LA    R10,4095(,R12)                                   DSKL014 01050460
         L     R15,@CV03233                                     DSKL014 01050470
         BALR  R14,R15                                          DSKL014 01050480
         LA    R10,4095(,R12)                                   DSKL014 01050490
         BAL   R14,IGGPDUMP                                     DSKL014 01050500
         L     R13,CCAMLRET(,R11)                               DSKL014 01050510
         BAL   R14,EXIT                                         DSKL014 01050520
@RF00465 DS    0H                                                  0470 01051000
         PUT RPL=(1)                                                    01052000
*         RFY                                                      0471 01053000
*           CTENTREC BASED(CCACPE1);                               0471 01054000
@RC00465 DS    0H                                                  0472 01055000
*       END;                        /* END 'DO' FOR 'PUT' PROCESSING */ 01056000
*   R13=R13-TWELVE;                 /* RESTORE NORMAL SAVEAREA PTR   */ 01057000
@RC00461 DS    0H                                                  0473 01058000
@RC00459 SH    R13,@CH00072                                        0473 01059000
*   IF XIONCK=ON THEN               /* IF ERROR CHECK, BYPASS REQ.   */ 01060000
         TM    XIONCK(R11),B'00000100'                             0474 01061000
         BNO   @RF00474                                            0474 01062000
*     CALL EXIT;                    /* RETURN TO CALLER              */ 01063000
         BAL   R14,EXIT                                         DSKL014 01064000
*   ELSE                            /* NO ERROR CHECK REQUESTED      */ 01065000
*     IF RPLRTNCD^='00'X THEN       /* IF ERROR,                     */ 01066000
*                                                                  0476 01067000
         B     @RC00474                                            0476 01068000
@RF00474 L     R5,CCARPL1(,R11)                                 DSKL014 01069000
         CLI   RPLRTNCD(R5),0                                   DSKL014 01070000
         BE    @RF00476                                            0476 01071000
         CLI   RPLERRCD(R5),X'10'                               DSKL014 01071010
         BNE   Z021IORA                                         DSKL014 01071020
         L     R5,CCAURAB(,R11)                                 DSKL014 01071030
         L     R5,CCACPE1(,R5)                                  DSKL014 01071040
         CLI   RCDID(R5),C'D'                                   DSKL014 01071050
         BNE   A000BFE                                          DSKL014 01071060
         L     R5,CCAXCPL(,R11)                                 DSKL014 01071070
         LTR   R5,R5                                            DSKL014 01071080
         BE    A000BFE                                          DSKL014 01071090
         CLI   18(R5),C'P'                                 ???  DSKL014 01071100
         BE    A000C06                                          DSKL014 01071110
A000BFE  TM    CCARVFG1(R11),X'10'                              DSKL014 01071120
         BNO   Z021IORA                                         DSKL014 01071130
A000C06  TM    XIOOPT(R11),X'02'                                DSKL014 01071140
         BO    @RF00476                                         DSKL014 01071150
*       /*************************************************************/ 01072000
*       /*                                                           */ 01073000
*       /* CALL TO MODULE IGG0CLAG                                   */ 01074000
*       /*                                                           */ 01075000
*       /*************************************************************/ 01076000
*                                                                  0477 01077000
*Z021IORA:                                                         0477 01078000
*       CALL IGGPIORA;              /* EXIT TO ERROR ANALYSIS        */ 01079000
Z021IORA L     R15,@CV03236                                     DSKL014 01080000
         BALR  R14,R15                                          DSKL014 01081000
         LA    R10,4095(,R12)                                   DSKL014 01081010
*     ELSE                                                         0478 01082000
*       ;                           /* NO ERROR OCCURRED             */ 01083000
@RF00476 DS    0H                                                  0479 01084000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01085000
@RC00474 BAL   R14,EXIT                                         DSKL014 01086000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 01087000
         DS 0F                                                          01088000
*   GEN(DC CL8'IGGPTNXO');          /* NAME OF FOLLOWING PROCEDURE   */ 01089000
         DC CL8'IGGPTNXO'                                               01090000
*   END;                            /* END OF INNER PROCEDURE        */ 01091000
@EL00004 DS    0H                                                  0482 01092000
@EF00004 DS    0H                                                  0482 01093000
@ER00004 BR    R14                                              DSKL014 01094000
@PB00004 DS    0H                                                  0483 01095000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 01096000
         EJECT                                                          01097000
*                                                                  0484 01098000
*/********************************************************************/ 01099000
*/*                                                                  */ 01100000
*/*        IGGPTNXO  -  PROCEDURE  EXTERNALLY  CALLED  NESTED        */ 01101000
*/*                                                                  */ 01102000
*/********************************************************************/ 01103000
*                                                                  0484 01104000
*IGGPTNXO:                                                         0484 01105000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01106000
IGGPTNXO DS    0H                                                  0485 01108000
*   GEN(ENTRY IGGPTNXO );           /* IDENTIFY ENTRY-POINT SYMBOL   */ 01109000
         ENTRY IGGPTNXO                                                 01110000
*Z022:                              /* LABEL FOR PROCEDURE TRACKING  */ 01111000
*Z022TNXO:                          /* LABEL FOR PROCEDURE TRACKING  */ 01112000
*   RFY                                                            0486 01113000
*    (R5,                                                          0486 01114000
*     R6,                                                          0486 01115000
*     R7,                                                          0486 01116000
*     R8,                                                          0486 01117000
*     R9,                                                          0486 01118000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 01119000
Z022     DS    0H                                                  0486 01120000
Z022TNXO DS    0H                                                  0487 01121000
*   RFY                                                            0487 01122000
*    (R2,                                                          0487 01123000
*     R3,                                                          0487 01124000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 01125000
         STM   R12,R14,12(R13)                                  DSKL014 01126000
         LA    R13,12(R13)                                      DSKL014 01127000
         DROP  R12,R10                                          DSKL014 01128000
         BALR  R12,0                                            DSKL014 01129000
         USING *,R12                                            DSKL014 01130000
A000C30  B     A000C36                                          DSKL014 01131000
A000C34  DC    AL2(A000C30-IGGSEGST)                            DSKL014 01132000
A000C36  SH    R12,A000C34                                      DSKL014 01133000
         USING IGGSEGST,R12                                     DSKL014 01134000
         LA    R10,4095(,R12)                                   DSKL014 01135000
         USING IGGSEGST+4095,R10                                DSKL014 01135010
*/********************************************************************/ 01136000
*/*     EXTERNAL PROCEDURE TO COMPUTE THE SUM TT OF THE EXTENTS      */ 01137000
*/*     CONTAINED IN 'CCADESA'.                                      */ 01138000
*/*     INPUT = CCARABB: POINTER TO BASE VOLUME RECORD.              */ 01139000
*/*             CCADESA: DADSM EXTENT SAVEAREA.                      */ 01140000
*/********************************************************************/ 01141000
*                                                                  0493 01142000
*   CCASUMTT=ZERO;                  /* INITIALIZE TO ZERO            */ 01143000
         SLR   R5,R5                                            DSKL014 01144000
         STCM  R5,7,CCASUMTT(R11)                               DSKL014 01145000
*   RFY                                                            0494 01146000
*     R1 RSTD;                      /* RESTRICT USE OF R1            */ 01147000
*   RFY                                                            0495 01148000
*     CCARAB BASED(CCARABB);        /* BASE VOLUME RECORD            */ 01149000
*/********************************************************************/ 01150000
*/*           CALCULATE THE SUM TT OF ALL THE EXTENTS                */ 01151000
*/********************************************************************/ 01152000
*                                                                  0496 01153000
*   DO R1=1 TO CCANDEXT;            /* NUMBER OF EXTENTS             */ 01154000
         LA    R1,1                                                0496 01155000
         B     @DE00496                                            0496 01156000
@DL00496 DS    0H                                                  0497 01157000
*     CCASUMTT=((CCAEXTCC(R1)*CTVNOTRK)+CCAEXTHH(R1))+CCASUMTT;/* SUM   01158000
*                                      TT ALGORITHM                  */ 01159000
         LR    R5,R1                                            DSKL014 01160000
         SLA   R5,3                                             DSKL014 01161000
         L     R15,CCARABB(,R11)                                DSKL014 01162000
         L     R15,CCACPE1(,R15)                                DSKL014 01163000
         LH    R14,CCAEXTCC-8(R5,R11)                           DSKL014 01164000
         MH    R14,CTVNOTRK+48(,R15)                            DSKL014 01165000
         AH    R14,CCAEXTHH-8(R5,R11)                           DSKL014 01166000
         SLR   R5,R5                                            DSKL014 01167000
         ICM   R5,7,CCASUMTT(R11)                               DSKL014 01168000
         ALR   R14,R5                                           DSKL014 01169000
         STCM  R14,7,CCASUMTT(R11)                              DSKL014 01170000
*   END;                            /* END SUM TT CALC               */ 01171000
         AL    R1,A001358                                       DSKL014 01172000
@DE00496 SLR   R5,R5                                            DSKL014 01173000
         IC    R5,CCANDEXT(,R11)                                DSKL014 01174000
         CR    R1,R5                                            DSKL014 01175000
         BNH   @DL00496                                            0498 01176000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01177000
         BAL   R14,EXIT                                         DSKL014 01178000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 01179000
         DC    X'50E0'                       !!! SOURCE COMPARE FIX !!! 01180000
         DS 0F                                                          01180000
*   GEN(DC CL8'IGGPTXO');           /* NAME OF FOLLOWING PROCEDURE   */ 01181000
         DC CL8'IGGPTXO'                                                01182000
*   END;                            /* END OF INNER PROCEDURE        */ 01183000
@EL00005 DS    0H                                                  0502 01184000
@EF00005 DS    0H                                                  0502 01185000
@ER00005 BR    R14                                              DSKL014 01186000
@PB00005 DS    0H                                                  0503 01187000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 01188000
         EJECT                                                          01189000
*                                                                  0504 01190000
*/********************************************************************/ 01191000
*/*                                                                  */ 01192000
*/*        IGGPTXO  -  PROCEDURE  EXTERNALLY  CALLED  NESTED         */ 01193000
*/*                                                                  */ 01194000
*/********************************************************************/ 01195000
*                                                                  0504 01196000
*IGGPTXO:                                                          0504 01197000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01198000
IGGPTXO  DS    0H                                                  0505 01200000
*   GEN(ENTRY IGGPTXO );            /* IDENTIFY ENTRY-POINT SYMBOL   */ 01201000
         ENTRY IGGPTXO                                                  01202000
*Z023:                              /* LABEL FOR PROCEDURE TRACKING  */ 01203000
*Z023TXO:                           /* LABEL FOR PROCEDURE TRACKING  */ 01204000
*   RFY                                                            0506 01205000
*    (R5,                                                          0506 01206000
*     R6,                                                          0506 01207000
*     R7,                                                          0506 01208000
*     R8,                                                          0506 01209000
*     R9,                                                          0506 01210000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 01211000
Z023     DS    0H                                                  0506 01212000
Z023TXO  DS    0H                                                  0507 01213000
*   RFY                                                            0507 01214000
*    (R2,                                                          0507 01215000
*     R3,                                                          0507 01216000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 01217000
         STM   R12,R14,12(R13)                                  DSKL014 01218000
         LA    R13,12(R13)                                      DSKL014 01219000
         DROP  R12,R10                                          DSKL014 01220000
         BALR  R12,0                                            DSKL014 01221000
         USING *,R12                                            DSKL014 01222000
A000C9C  B     A000CA2                                          DSKL014 01223000
A000CA0  DC    AL2(A000C9C-IGGSEGST)                            DSKL014 01224000
A000CA2  SH    R12,A000CA0                                      DSKL014 01225000
         USING IGGSEGST,R12                                     DSKL014 01226000
         LA    R10,4095(,R12)                                   DSKL014 01227000
         USING IGGSEGST+4095,R10                                DSKL014 01227010
*/********************************************************************/ 01228000
*/*    EXTERNAL PROCEDURE TO UPDATE THE VOLUME DIRECTORY GROUP       */ 01229000
*/*    OCCURRENCE TO UPDATE THE EXTENT STARTING TRACK SUM TT         */ 01230000
*/*    FIELD.                                                        */ 01231000
*/*     INPUT:                                                       */ 01232000
*/*       CCARABB  - POINTER TO BASE VOLUME RECORD.                  */ 01233000
*/*       CCARABF  - POINTER TO FIRST RAB.                           */ 01234000
*/*       CCARABL  - POINTER TO LAST RAB.                            */ 01235000
*/*       CCASUMTT - SUM TT VALUE WITH WHICH TO UPDATE.              */ 01236000
*/*       CCARESUM - ON  = REPLACE.                                  */ 01237000
*/*                  OFF = INCREMENT.                                */ 01238000
*/*       CCASSVOL - DATA SET DIRECTORY SEQUENCE NUMBER.             */ 01239000
*/********************************************************************/ 01240000
*                                                                  0513 01241000
*   RFY                                                            0513 01242000
*     CCARAB BASED(CCARABB);        /* BASE VOLUME RECORD            */ 01243000
*/********************************************************************/ 01244000
*/*                CALCULATE LENGTH FOR GETMAIN                      */ 01245000
*/********************************************************************/ 01246000
*                                                                  0514 01247000
*   CCAMNLEN=CPLEN+(FPLEN*TWO)+FLDLEN24+LENGTH(EXTFLD)+LENGTH(SUMTTWKA) 01248000
*       ;                           /* 1 CPL + 2 FPLS + 2 DATA/LENGTH   01249000
*                                      PTRS FOR FPLS + ARRAY OF 2  0514 01250000
*                                      CTGFIELD PTRS FOR CPL + 2   0514 01251000
*                                      WORKAREAS                     */ 01252000
         LH    R5,FPLEN                                         DSKL014 01253000
         ALR   R5,R5                                            DSKL014 01254000
         AH    R5,CPLEN                                         DSKL014 01255000
         AH    R5,@CH00284                                      DSKL014 01256000
         STCM  R5,7,CCAMNLEN(R11)                               DSKL014 01257000
*   RFY                                                            0515 01258000
*    (R1,                                                          0515 01259000
*     R15) RSTD;                    /* REGS FOR GETMAIN              */ 01260000
*   R1=ADDR(CCAMSSPL);              /* POINT TO STRG MGMT P.L.       */ 01261000
         LA    R1,CCAMSSPL(,R11)                                   0516 01262000
*   CCAMNSPL=USUBPOOL;              /* STORE SUBPOOL VALUE           */ 01263000
*                                                                  0517 01264000
         MVI   CCAMNSPL(R11),X'FC'                                 0517 01265000
*   /*****************************************************************/ 01266000
*   /*                                                               */ 01267000
*   /* ALLOCATE MAIN STORAGE FROM USER SUBPOOL 252                   */ 01268000
*   /*                                                               */ 01269000
*   /*****************************************************************/ 01270000
*                                                                  0518 01271000
*   GEN(GETMAIN LC,MF=(E,(1)));     /* GET MAIN STORAGE SPACE        */ 01272000
         GETMAIN LC,MF=(E,(1))                                          01273000
*   GEN(LR R1,R15);                 /* PICK UP RETURN CODE           */ 01274000
         LR R1,R15                                                      01275000
*   IF R1^=NOGETMSE THEN            /* CHECK FOR ERROR RETURN        */ 01276000
*                                                                  0520 01277000
         LTR   R1,R1                                               0520 01278000
         BZ    @RF00520                                            0520 01279000
*     /***************************************************************/ 01280000
*     /*                                                             */ 01281000
*     /* SET CCAMODID='BI', CCAREASN=RSN2, CCARETRN=RCINSSWA         */ 01282000
*     /*                                                             */ 01283000
*     /***************************************************************/ 01284000
*                                                                  0521 01285000
*     CCAPROB=IGGSEGID+(RSN2*K256)+RCINSSWA;/* INSUFFICIENT CORE   0521 01286000
*                                      ERROR                         */ 01287000
         MVC   CCAPROB(4,R11),@CF03446                             0521 01288000
*   ELSE                            /* GETMAIN SUCCESSFUL            */ 01289000
*     DO;                                                          0522 01290000
         B     @RC00520                                            0522 01291000
@RF00520 DS    0H                                                  0523 01292000
*       DO;                                                        0523 01293000
*         IF MNATFULL=ON THEN       /* TRACKING TABLE FULL           */ 01294000
*                                                                  0524 01295000
         TM    MNATFULL(R11),B'10000000'                           0524 01296000
         BNO   @RF00524                                            0524 01297000
*           /*********************************************************/ 01298000
*           /*                                                       */ 01299000
*           /* CALL TO MODULE IGG0CLAT                               */ 01300000
*           /*                                                       */ 01301000
*           /*********************************************************/ 01302000
*                                                                  0525 01303000
*Z027ARFS:                                                         0525 01304000
*           CALL IGGPARFS;          /* YES,CALL SPILL ROUTINE        */ 01305000
Z027ARFS L     R15,@CV03235                                     DSKL014 01306000
         BALR  R14,R15                                          DSKL014 01307000
         LA    R10,4095(,R12)                                   DSKL014 01307010
*         GEN REFS(CCAMNAT)(MVC CCAMNAT(248,11),CCAMNAT+8(11));/*  0526 01308000
*                                      PUSH AND TRACK                */ 01309000
@RF00524 DS    0H                                                  0526 01310000
         MVC   CCAMNAT(248,R11),CCAMNAT+8(R11)                  DSKL014 01311000
*       END;                                                       0527 01312000
*     END;                          /* FREE WORK AREAS               */ 01313000
*   RFY                                                            0529 01314000
*    (R1,                                                          0529 01315000
*     R15) UNRSTD;                  /* RELEASE GETMAIN REGS          */ 01316000
@RC00520 DS    0H                                                  0530 01317000
*   CCAMNADR->WORK(ONE:CCAMNLEN)=CCAMNADR->WORK(ONE:CCAMNLEN)&&CCAMNADR 01318000
*       ->WORK(ONE:CCAMNLEN);       /* ZERO STOR                     */ 01319000
*                                                                  0530 01320000
         L     R5,CCAMNADR(,R11)                                DSKL014 01321000
         SLR   R1,R1                                            DSKL014 01322000
         ICM   R1,7,CCAMNLEN(R11)                               DSKL014 01323000
         LR    R15,R1                                           DSKL014 01324000
         BCTR  R15,0                                            DSKL014 01325000
         EX    R15,@SX03472                                     DSKL014 01326000
*   /*****************************************************************/ 01327000
*   /*                                                               */ 01328000
*   /* INITIALIZE ALL CONTROL BLOCKS AND POINTERS                    */ 01329000
*   /*                                                               */ 01330000
*   /*****************************************************************/ 01331000
*                                                                  0531 01332000
*   CCAXCPL=CCAMNADR;               /* CPL ADDRESS                   */ 01333000
         ST    R5,CCAXCPL(,R11)                                 DSKL014 01334000
*   EVAL(CCAXCPL+(CCAMNLEN-LENGTH(SUMTTWKA)))->SUMTTWKA(1:4)=CCAMNADR;  01335000
         SH    R1,@CH00250                                      DSKL014 01336000
         ALR   R1,R5                                            DSKL014 01337000
         ST    R5,SUMTTWKA(,R1)                                 DSKL014 01338000
*                                   /* SAVE GETMAIN ADDRESS          */ 01339000
*   RFY                                                            0533 01340000
*     CTGPL BASED(CCAXCPL);         /* BASE CPL ON NEW PTR           */ 01341000
*   CTGFIELD(ONE)=CCAXCPL+CPLEN+EIGHT;/* FIRST CTGFL ADDRESS         */ 01342000
         LA    R1,8                                             DSKL014 01343000
         LH    R15,CPLEN                                        DSKL014 01344000
         ALR   R15,R5                                           DSKL014 01345000
         ALR   R15,R1                                           DSKL014 01346000
         ST    R15,CTGFIELD(,R5)                                DSKL014 01347000
*   RFY                                                            0535 01348000
*     CTGFL BASED(CTGFIELD(ONE));   /* BASE FIRST CTGFL              */ 01349000
*   CTGFIELD(TWO)=CTGFIELD(ONE)+FPLEN+EIGHT;/* 2ND CTGFL ADDR        */ 01350000
         LH    R14,FPLEN                                        DSKL014 01351000
         ALR   R15,R14                                          DSKL014 01352000
         ALR   R15,R1                                           DSKL014 01353000
         ST    R15,CTGFIELD+4(,R5)                              DSKL014 01354000
*   CTGWKA=CTGFIELD(TWO)+FPLEN+EIGHT;/* EXTRACT WORK AREA ADDR       */ 01355000
         ALR   R14,R15                                          DSKL014 01356000
         ALR   R14,R1                                           DSKL014 01357000
         ST    R14,CTGWKA(,R5)                                  DSKL014 01358000
*   CTGNOFLD=ONE;                   /* SHOW ONE SET OF CTGFL POINTERS   01359000
*                                      FOR EXTRACT & MODIFY          */ 01360000
         MVI   CTGNOFLD(R5),X'01'                               DSKL014 01361000
*   CTGWKA->LEN=LENGTH(EXTFLD);     /* EXTRACT AREA LENGTH           */ 01362000
         MVC   LEN(2,R14),@CH00110                              DSKL014 01363000
*   CCAREUSE=OFF;                   /* NO RAB REUSE                  */ 01364000
         NI    CCAREUSE(R11),B'11111011'                           0540 01365000
*   CCAF2NVC=ON;                    /* SUPPRESS VALIDITY CHECK       */ 01366000
*                                                                  0541 01367000
         OI    CCAF2NVC(R11),B'01000000'                           0541 01368000
*   /*****************************************************************/ 01369000
*   /*                                                               */ 01370000
*   /* INITIALIZE PRIME CTGFL FOR EXTRACT                            */ 01371000
*   /*                                                               */ 01372000
*   /*****************************************************************/ 01373000
*                                                                  0542 01374000
*   CTGFLDNM=ADDR(CRADIRCT);        /* SUMTT FIELD NAME ADDR         */ 01375000
         L     R5,CTGFIELD(,R5)                                 DSKL014 01376000
         LA    R1,CRADIRCT                                      DSKL014 01377000
         ST    R1,CTGFLDNM(,R5)                                 DSKL014 01378000
*   CTGFLCHN=CTGFIELD(TWO);         /* CHAIN SECONDARY CTGFL         */ 01379000
*                                                                  0543 01380000
         ST    R15,CTGFLCHN(,R5)                                DSKL014 01381000
*   /*****************************************************************/ 01382000
*   /*                                                               */ 01383000
*   /* INITIALIZE SECONDARY CTGFL FOR EXTRACT                        */ 01384000
*   /*                                                               */ 01385000
*   /*****************************************************************/ 01386000
*                                                                  0544 01387000
*   RFY                                                            0544 01388000
*     CTGFL BASED(CTGFIELD(TWO));   /* BASE SECONDARY CTGFL          */ 01389000
*   CTGFLDCD=EQUAL;                 /* HAVE EXTRACT PERFORM TEST FOR    01390000
*                                      EQUAL CONDITION ON DATA SET 0545 01391000
*                                      SEQUENCE NUMBER AGAINST     0545 01392000
*                                      RELREPNO                      */ 01393000
         MVI   CTGFLDCD(R15),X'80'                              DSKL014 01394000
*   CTGFLDNO=ONE;                   /* ONE PAIR DATA/LENGTH PTRS     */ 01395000
         MVI   CTGFLDNO(R15),X'01'                              DSKL014 01396000
*   CTGFLDGC=EIGHT;                 /* GROUP CODE                    */ 01397000
         MVI   CTGFLDGC(R15),X'08'                              DSKL014 01398000
*   CTGFLDNM=ADDR(RELREPNO);        /* FIELD NAME                    */ 01399000
         LA    R5,RELREPNO                                      DSKL014 01400000
         ST    R5,CTGFLDNM(,R15)                                DSKL014 01401000
*   CTGFLNG(ONE)=TWO;               /* LENGTH OF DATA SET SEQ NUMBER */ 01402000
         MVC   CTGFLNG(4,R15),@CF00055                          DSKL014 01403000
*   CTGFLPT(ONE)=ADDR(CCASSVOL);    /* DATA SET SEQUENCE NUMBER ADDR */ 01404000
         LA    R5,CCASSVOL(,R11)                                DSKL014 01405000
         ST    R5,CTGFLPT(,R15)                                 DSKL014 01406000
*   RFY                                                            0551 01407000
*     CTGFL BASED(CTGFIELD(ONE));   /* BASE CTGFL ON PRIME           */ 01408000
*                                                                  0551 01409000
*   /*****************************************************************/ 01410000
*   /*                                                               */ 01411000
*   /* CALL TO MODULE IGG0CLAZ                                       */ 01412000
*   /*                                                               */ 01413000
*   /*****************************************************************/ 01414000
*                                                                  0552 01415000
*Z028EXT:                                                          0552 01416000
*   CALL IGGPEXT;                   /* EXTRACT FIELD INFORMATION     */ 01417000
*                                                                  0552 01418000
Z028EXT  L     R15,A0013DC                                      DSKL014 01419000
         BALR  R14,R15                                          DSKL014 01420000
         LA    R10,4095(,R12)                                   DSKL014 01420010
*   /*****************************************************************/ 01421000
*   /*                                                               */ 01422000
*   /* CHECK RESULTS FROM EXTRACT                                    */ 01423000
*   /*                                                               */ 01424000
*   /*****************************************************************/ 01425000
*                                                                  0553 01426000
*   RFY                                                            0553 01427000
*     CTVDIR BASED(CTGFLPT(ONE));   /* BASE EXTRACTED DATA           */ 01428000
*   IF CCACD1=RCS&                  /* NO ERROR IN EXTRACT           */ 01429000
*       CTGFLPT(ONE)^=ZERO&         /* DATA EXISTS                   */ 01430000
*       CTVDRSTT^=NULL THEN         /* SUMTT FIELD EXISTS            */ 01431000
         CLI   CCACD1(R11),0                                       0554 01432000
         BNE   @RF00554                                            0554 01433000
         L     R1,CCAXCPL(,R11)                                 DSKL014 01434000
         L     R1,CTGFIELD(,R1)                                 DSKL014 01435000
         L     R5,CTGFLPT(,R1)                                  DSKL014 01436000
         LTR   R5,R5                                            DSKL014 01437000
         BZ    @RF00554                                            0554 01438000
         AH    R5,@CH00053                                      DSKL014 01439000
         CLC   CTVDRSTT(3,R5),@CF03268+1                        DSKL014 01440000
         BE    @RF00554                                            0554 01441000
*     DO;                           /* ALL GO,PROCESS SUMTT          */ 01442000
*       IF CTVDRSTT=NEW×            /* EXTRACTED SUMTT ZERO          */ 01443000
*           CCARESUM=ON THEN        /* REPLACE SUMTT                 */ 01444000
         ICM   R1,7,CTVDRSTT(R5)                                DSKL014 01445000
         BZ    @RT00556                                            0556 01446000
         TM    CCARESUM(R11),B'00000001'                           0556 01447000
         BNO   @RF00556                                            0556 01448000
@RT00556 DS    0H                                                  0557 01449000
*         CTVDRSTT=CCASUMTT;        /* STORE NEW SUMTT VALUE         */ 01450000
         L     R1,CCAXCPL(,R11)                                 DSKL014 01451000
         L     R1,CTGFIELD(,R1)                                 DSKL014 01452000
         L     R1,CTGFLPT(,R1)                                  DSKL014 01453000
         MVC   CTVDRSTT+5(3,R1),CCASUMTT(R11)                   DSKL014 01454000
*       ELSE                        /* OLD SUM-TT EXISTS             */ 01455000
*         CTVDRSTT=CTVDRSTT+CCASUMTT;/* COMPUTE NEW SUM-TT           */ 01456000
         B     @RC00556                                            0558 01457000
@RF00556 L     R1,CCAXCPL(,R11)                                 DSKL014 01458000
         L     R1,CTGFIELD(,R1)                                 DSKL014 01459000
         LA    R5,5                                             DSKL014 01460000
         AL    R5,CTGFLPT(,R1)                                  DSKL014 01461000
         SLR   R1,R1                                            DSKL014 01462000
         ICM   R1,7,CTVDRSTT(R5)                                DSKL014 01463000
         SLR   R15,R15                                          DSKL014 01464000
         ICM   R15,7,CCASUMTT(R11)                              DSKL014 01465000
         ALR   R1,R15                                           DSKL014 01466000
         STCM  R1,7,CTVDRSTT(R5)                                DSKL014 01467000
*       CCAMODPA=OFF;               /* MODIFY WITH UPDATE            */ 01468000
*                                                                  0559 01469000
@RC00556 NI    CCAMODPA(R11),B'11101111'                           0559 01470000
*       /*************************************************************/ 01471000
*       /*                                                           */ 01472000
*       /* CALL TO MODULE IGG0CLAV                                   */ 01473000
*       /*                                                           */ 01474000
*       /*************************************************************/ 01475000
*                                                                  0560 01476000
*Z029MOD:                                                          0560 01477000
*       CALL IGGPMOD;               /* MODIFY CATALOG RECORD FIELD   */ 01478000
Z029MOD  L     R15,A0013D4                                      DSKL014 01479000
         BALR  R14,R15                                          DSKL014 01480000
         LA    R10,4095(,R12)                                   DSKL014 01480010
*     END;                          /* END SUMTT PROCESSING          */ 01481000
*   ELSE                                                           0562 01482000
*     ;                             /* ERROR OR MISSING FIELDS       */ 01483000
@RF00554 DS    0H                                                  0563 01484000
*   CCAMNLEN=CPLEN+(FPLEN*TWO)+FLDLEN24+LENGTH(EXTFLD)+LENGTH(SUMTTWKA) 01485000
*       ;                           /* CALC LENGTH FOR FREEMAIN      */ 01486000
         LH    R5,FPLEN                                         DSKL014 01487000
         ALR   R5,R5                                            DSKL014 01488000
         AH    R5,CPLEN                                         DSKL014 01489000
         AH    R5,@CH00284                                      DSKL014 01490000
         STCM  R5,7,CCAMNLEN(R11)                               DSKL014 01491000
*   CCAMNADR=EVAL(CTGWKA+LENGTH(EXTFLD))->SUMTTWKA(1:4);/* STORE ADDR   01492000
*                                      FOR FREEMAIN                  */ 01493000
         L     R1,CCAXCPL(,R11)                                 DSKL014 01494000
         LA    R5,20                                            DSKL014 01495000
         AL    R5,CTGWKA(,R1)                                   DSKL014 01496000
         MVC   CCAMNADR(4,R11),SUMTTWKA(R5)                     DSKL014 01497000
*/********************************************************************/ 01498000
*/*       FINISHED PROCESSING SUMTT, FREE ALL STORAGE ACQUIRED       */ 01499000
*/********************************************************************/ 01500000
*                                                                  0565 01501000
*   RFY                                                            0565 01502000
*     R1 RSTD;                      /* RESTRICT FOR FREEMAIN USAGE   */ 01503000
*   R1=ADDR(CCAMSSPL);              /* POINT TO STRG MGMT P.L.       */ 01504000
         LA    R1,CCAMSSPL(,R11)                                   0566 01505000
*   CCAMNSPL=USUBPOOL;              /* STORE SUBPOOL VALUE           */ 01506000
         MVI   CCAMNSPL(R11),X'FC'                                 0567 01507000
*   DO;                                                            0568 01508000
*     IF MNATFULL=ON THEN           /* TRACKING TABLE FULL           */ 01509000
*                                                                  0569 01510000
         TM    MNATFULL(R11),B'10000000'                           0569 01511000
         BNO   @RF00569                                            0569 01512000
*       /*************************************************************/ 01513000
*       /*                                                           */ 01514000
*       /* CALL TO MODULE IGG0CLAT                                   */ 01515000
*       /*                                                           */ 01516000
*       /*************************************************************/ 01517000
*                                                                  0570 01518000
*Z032ARFS:                                                         0570 01519000
*       CALL IGGPARFS;              /* YES,CALL SPILL ROUTINE        */ 01520000
Z032ARFS L     R15,@CV03235                                     DSKL014 01521000
         BALR  R14,R15                                          DSKL014 01522000
         LA    R10,4095(,R12)                                   DSKL014 01522010
*     GEN REFS(CCAMNAT)(MVC CCAMNAT(248,11),CCAMNAT+8(11));/* PUSH 0571 01523000
*                                      AND TRACK                     */ 01524000
@RF00569 DS    0H                                                  0571 01525000
         MVC   CCAMNAT(248,R11),CCAMNAT+8(R11)                  DSKL014 01526000
*   END;                                                           0572 01527000
*                                                                  0572 01528000
*   /*****************************************************************/ 01529000
*   /*                                                               */ 01530000
*   /* RELEASE MAIN STORAGE FROM USER SUBPOOL 252                    */ 01531000
*   /*                                                               */ 01532000
*   /*****************************************************************/ 01533000
*                                                                  0573 01534000
*   GEN(FREEMAIN L,MF=(E,(1))) ;    /* FREE ALL ACQUIRED STORAGE     */ 01535000
         FREEMAIN L,MF=(E,(1))                                          01536000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01537000
         BAL   R14,EXIT                                         DSKL014 01538000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 01539000
         DC    X'0604'                       !!! SOURCE COMPARE FIX !!! 01540000
         DS 0F                                                          01540000
*   GEN(DC CL8'IGGPUCCT');          /* NAME OF FOLLOWING PROCEDURE   */ 01541000
         DC CL8'IGGPUCCT'                                               01542000
*   END;                            /* END OF INNER PROCEDURE        */ 01543000
@EL00006 DS    0H                                                  0577 01544000
@EF00006 DS    0H                                                  0577 01545000
@ER00006 BR    R14                                              DSKL014 01546000
@PB00006 DS    0H                                                  0578 01547000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 01548000
         EJECT                                                          01549000
*                                                                  0579 01550000
*/********************************************************************/ 01551000
*/*                                                                  */ 01552000
*/*        IGGPUCCT  -  PROCEDURE  INTERNALLY  CALLED  NESTED        */ 01553000
*/*                                                                  */ 01554000
*/********************************************************************/ 01555000
*                                                                  0579 01556000
*IGGPUCCT:                                                         0579 01557000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01558000
IGGPUCCT DS    0H                                                  0580 01560000
*Z033:                              /* LABEL FOR PROCEDURE TRACKING  */ 01561000
*Z033UCCT:                          /* LABEL FOR PROCEDURE TRACKING  */ 01562000
*   RFY                                                            0580 01563000
*    (R5,                                                          0580 01564000
*     R6,                                                          0580 01565000
*     R7,                                                          0580 01566000
*     R8,                                                          0580 01567000
*     R9,                                                          0580 01568000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 01569000
Z033     DS    0H                                                  0580 01570000
Z033UCCT DS    0H                                                  0581 01571000
*   RFY                                                            0581 01572000
*    (R2,                                                          0581 01573000
*     R3,                                                          0581 01574000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 01575000
*   GEN(STM 12,14,12(13));          /* SAVE REGISTERS OF CALLER      */ 01576000
         STM 12,14,12(13)                                               01577000
*   GEN(LA 13,12(13));              /* POINT TO NEXT SAVE AREA       */ 01578000
         LA 13,12(13)                                                   01579000
*/********************************************************************/ 01580000
*/*     THIS PROCEDURE PERFORMS TRANSLATION OF THE CATALOG CI        */ 01581000
*/*     NUMBER TO THE CRA CI NUMBER.  THIS IS DONE BY SCANNING       */ 01582000
*/*     THE CI TRANSLATION TABLE USING THE VALUE IN 'CCASRCIN'       */ 01583000
*/*     AS THE SEARCH ARGUMENT.  WHEN A MATCH IS FOUND, THE CRA      */ 01584000
*/*     CI NUMBER IS COMPUTED BY USING THE INDEX INTO THE            */ 01585000
*/*     TRANSLATION TABLE.  THE CRA CI NUMBER IS PASSED TO THE       */ 01586000
*/*     CALLER VIA THE SAME 'CCASRCIN' FIELD.                        */ 01587000
*/********************************************************************/ 01588000
*/********************************************************************/ 01589000
*/*       ESTABLISH ADDRESSABILITY TO THE CI TRANSLATION TABLE       */ 01590000
*/********************************************************************/ 01591000
*                                                                  0584 01592000
*   RFY                                                            0584 01593000
*     CTT BASED(R2);                /* BASE FOR CI TRANSLATE TABLE   */ 01594000
*   RFY                                                            0585 01595000
*     R2 RSTD;                      /* NEED R2 FOR TRNSLTE TAB BASE  */ 01596000
*   R2=CBSCRACA                     /* GET ADDR OF CI TRANSLATE TABLE*/ 01597000
*       ->CAXSCHWA->ACCTRANT;                                      0586 01598000
*                                                                  0586 01599000
         L     R5,CVTPTR                                        DSKL014 01600000
         L     R5,CVTCBSP(,R5)                                  DSKL014 01601000
         L     R5,CBSCRACA(,R5)                                 DSKL014 01602000
         L     R5,CAXSCHWA(,R5)                                 DSKL014 01603000
         L     R2,ACCTRANT(,R5)                                 DSKL014 01604000
*/********************************************************************/ 01605000
*/*              SEARCH  CI  NUMBER  TRANSLATION  TABLE              */ 01606000
*/********************************************************************/ 01607000
*                                                                  0587 01608000
*   RFY                                                            0587 01609000
*     R1 RSTD;                      /* NEED R1 FOR TABLE INDEX       */ 01610000
*   R1=ONE;                         /* START WITH FIRST TABLE ENTRY  */ 01611000
         LA    R1,1                                                0588 01612000
*   DO WHILE((CCASRCIN^=CTTCATCI(R1))/* DO WHILE ENTRY NOT FOUND AND */ 01613000
*         &(R1<=CTTENTNO));         /* ANOTHER ENTRY EXISTS          */ 01614000
         B     @DE00589                                            0589 01615000
@DL00589 DS    0H                                                  0590 01616000
*     R1=R1+ONE;                    /* INCREMENT TABLE ENTRY INDEX   */ 01617000
         AL    R1,A001358                                       DSKL014 01618000
*   END;                            /* END TRANSLATE TABLE SEARCH    */ 01619000
@DE00589 LR    R5,R1                                            DSKL014 01620000
         SLA   R5,2                                             DSKL014 01621000
         ALR   R5,R2                                            DSKL014 01622000
         CLC   CCASRCIN(3,R11),CTTCATCI-4(R5)                   DSKL014 01623000
         BE    @DC00589                                            0591 01624000
         C     R1,CTTENTNO(,R2)                                    0591 01625000
         BNH   @DL00589                                            0591 01626000
@DC00589 DS    0H                                                  0592 01627000
*/********************************************************************/ 01628000
*/*            NO  MATCH  FOUND  IN  CI  TRANSLATE  TABLE            */ 01629000
*/********************************************************************/ 01630000
*                                                                  0592 01631000
*   IF R1>CTTENTNO THEN             /* INDEX GREATER THAN NUMBER OF     01632000
*                                      TABLE ENTRIES                 */ 01633000
*                                                                  0592 01634000
         C     R1,CTTENTNO(,R2)                                    0592 01635000
         BNH   @RF00592                                            0592 01636000
*     /***************************************************************/ 01637000
*     /*                                                             */ 01638000
*     /* SET CCAMODID='BI', CCAREASN=RSN26, CCARETRN=RCENT           */ 01639000
*     /*                                                             */ 01640000
*     /***************************************************************/ 01641000
*                                                                  0593 01642000
*     CCAPROB=IGGSEGID+(RSN26*K256)+RCENT;/* ECD: ENTRY NOT FOUND. 0593 01643000
*                                      RCD: NO MATCH FOUND IN CI   0593 01644000
*                                      TRANSLATE TABLE               */ 01645000
         MVC   CCAPROB(4,R11),@CF03449                             0593 01646000
*/********************************************************************/ 01647000
*/*               TRANSLATE  TABLE  SEARCH  SUCCESSFUL               */ 01648000
*/********************************************************************/ 01649000
*                                                                  0594 01650000
*   ELSE                                                           0594 01651000
*     CCASRCIN=R1+CITRN8;           /* RETURN CRA CI # TO CALLER     */ 01652000
         B     @RC00592                                            0594 01653000
@RF00592 LA    R5,8                                             DSKL014 01654000
         ALR   R5,R1                                            DSKL014 01655000
         STCM  R5,7,CCASRCIN(R11)                               DSKL014 01656000
*   RFY                                                            0595 01657000
*     R1 UNRSTD;                    /* FREE USE OF R1                */ 01658000
@RC00592 DS    0H                                                  0596 01659000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01660000
         BAL   R14,EXIT                                         DSKL014 01661000
*   GEN(DS 0F);                     /* FULLWORD BOUNDARY ALIGNMENT   */ 01662000
         DS 0F                                                          01663000
*   GEN(DC CL8'IGGPUCVT');          /* NAME OF FOLLOWING PROCEDURE   */ 01664000
         DC CL8'IGGPUCVT'                                               01665000
*   END;                            /* END OF INNER PROCEDURE        */ 01666000
@EL00007 DS    0H                                                  0599 01667000
@EF00007 DS    0H                                                  0599 01668000
@ER00007 BR    R14                                              DSKL014 01669000
@PB00007 DS    0H                                                  0600 01670000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 01671000
         EJECT                                                          01672000
*                                                                  0601 01673000
*/********************************************************************/ 01674000
*/*                                                                  */ 01675000
*/*        IGGPUCVT  -  PROCEDURE  INTERNALLY  CALLED  UNNESTED      */ 01676000
*/*                                                                  */ 01677000
*/********************************************************************/ 01678000
*                                                                  0601 01679000
*IGGPUCVT:                                                         0601 01680000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01681000
IGGPUCVT DS    0H                                                  0602 01683000
*Z035:                              /* LABEL FOR PROCEDURE TRACKING  */ 01684000
*Z035UCVT:                          /* LABEL FOR PROCEDURE TRACKING  */ 01685000
*   RFY                                                            0602 01686000
*    (R5,                                                          0602 01687000
*     R6,                                                          0602 01688000
*     R7,                                                          0602 01689000
*     R8,                                                          0602 01690000
*     R9,                                                          0602 01691000
*     R10) UNRSTD;                  /* PL/S COMPILER WORK REGISTERS  */ 01692000
Z035     DS    0H                                                  0602 01693000
Z035UCVT DS    0H                                                  0603 01694000
*   RFY                                                            0603 01695000
*    (R2,                                                          0603 01696000
*     R3,                                                          0603 01697000
*     R4) RSTD;                     /* RESTRICT LOCAL WORK REGISTERS */ 01698000
*/********************************************************************/ 01699000
*/*     THIS PROCEDURE SEARCHES THE VOLUME TIMESTAMP TABLE FOR       */ 01700000
*/*     THE TIMESTAMP ASSOCIATED WITH THE VOLSER PASSED IN           */ 01701000
*/*     'CCASRCH' AS THE SEARCH ARGUMENT.  THE FOUND TIMESTAMP       */ 01702000
*/*     IS PLACED IN THE 'LOCATE' WORKAREA, THE REQUIRED FPL         */ 01703000
*/*     UPDATING IS PERFORMED, AND CONTROL IS RETURNED TO THE        */ 01704000
*/*     FOURTH PREVIOUS LEVEL CALLER (IGGPRCU(IGG0CLC9)).            */ 01705000
*/********************************************************************/ 01706000
*/********************************************************************/ 01707000
*/*      ESTABLISH ADDRESSABILITY TO THE VOLUME TIMESTAMP TABLE      */ 01708000
*/********************************************************************/ 01709000
*                                                                  0604 01710000
*   RFY                                                            0604 01711000
*     VTT BASED(R2);                /* BASE FOR VOLUME TIMESTAMP TAB */ 01712000
*   RFY                                                            0605 01713000
*     R2 RSTD;                      /* NEED R2 FOR TIMESTMP TAB BASE */ 01714000
*   R2=CBSCRACA                     /* GET ADDR OF TIMESTAMP TABLE   */ 01715000
*       ->CAXSCHWA->ACCVOLTT;                                      0606 01716000
*                                                                  0606 01717000
         L     R5,CVTPTR                                        DSKL014 01718000
         L     R1,CVTCBSP(,R5)                                  DSKL014 01719000
         L     R1,CBSCRACA(,R1)                                 DSKL014 01720000
         L     R1,CAXSCHWA(,R1)                                 DSKL014 01721000
         L     R2,ACCVOLTT(,R1)                                 DSKL014 01722000
*/********************************************************************/ 01723000
*/*                 SEARCH  VOLUME  TIMESTAMP  TABLE                 */ 01724000
*/********************************************************************/ 01725000
*                                                                  0607 01726000
*   RFY                                                            0607 01727000
*     R1 RSTD;                      /* NEED R1 FOR TABLE INDEX       */ 01728000
*   R1=ONE;                         /* START WITH FIRST TABLE ENTRY  */ 01729000
         LA    R1,1                                                0608 01730000
*   DO WHILE((CCASRCH(1:6)^=VTTVOLSR(R1))/* DO WHILE ENTRY NOT FOUND */ 01731000
*         &(R1<=VTTENTNO));         /* AND ANOTHER ENTRY EXISTS      */ 01732000
         B     @DE00609                                            0609 01733000
@DL00609 DS    0H                                                  0610 01734000
*     R1=R1+ONE;                    /* INCREMENT TABLE ENTRY INDEX   */ 01735000
         AL    R1,A001358                                       DSKL014 01736000
*   END;                            /* END VOLUME TIMESTAMP SEARCH   */ 01737000
@DE00609 LR    R5,R1                                            DSKL014 01738000
         MH    R5,@CH00253                                      DSKL014 01739000
         ALR   R5,R2                                            DSKL014 01740000
         AL    R5,@CF03476                                      DSKL014 01741000
         CLC   CCASRCH(6,R11),VTTVOLSR-4(R5)                    DSKL014 01742000
         BE    @DC00609                                            0611 01743000
         C     R1,VTTENTNO(,R2)                                    0611 01744000
         BNH   @DL00609                                            0611 01745000
@DC00609 DS    0H                                                  0612 01746000
*/********************************************************************/ 01747000
*/*          NO  MATCH  FOUND  IN  VOLUME  TIMESTAMP  TABLE          */ 01748000
*/********************************************************************/ 01749000
*                                                                  0612 01750000
*   IF R1>VTTENTNO THEN             /* INDEX GREATER THAN NUMBER OF     01751000
*                                      TABLE ENTRIES                 */ 01752000
*                                                                  0612 01753000
         C     R1,VTTENTNO(,R2)                                    0612 01754000
         BNH   @RF00612                                            0612 01755000
*     /***************************************************************/ 01756000
*     /*                                                             */ 01757000
*     /* SET CCAMODID='BI', CCAREASN=RSN28, CCARETRN=RCENT           */ 01758000
*     /*                                                             */ 01759000
*     /***************************************************************/ 01760000
*                                                                  0613 01761000
*     CCAPROB=IGGSEGID+(RSN28*K256)+RCENT;/* ECD: ENTRY NOT FOUND. 0613 01762000
*                                      RCD: NO MATCH FOUND IN VOLUME    01763000
*                                      TIMESTAMP TABLE               */ 01764000
         MVC   CCAPROB(4,R11),@CF03452                             0613 01765000
*/********************************************************************/ 01766000
*/*           VOLUME  TIMESTAMP  TABLE  SEARCH  SUCCESSFUL           */ 01767000
*/********************************************************************/ 01768000
*                                                                  0614 01769000
*   ELSE                            /* CORRECT VOLSER ENTRY FOUND    */ 01770000
*     DO;                                                          0614 01771000
         B     @RC00612                                            0614 01772000
@RF00612 DS    0H                                                  0615 01773000
*       RFY                                                        0615 01774000
*         CTGPL BASED(CCACPL);      /* MAP THE CPL                   */ 01775000
*       IF WKALEN1>=(LENGTH(WKALEN1)+LENGTH(WKALEN2)/* BE SURE     0616 01776000
*                                      WORKAREA                      */ 01777000
*           +LENGTH(VOLTMSTP)) THEN /* LENGTH IS SUFFICIENT          */ 01778000
         L     R5,CCACPL(,R11)                                  DSKL014 01779000
         L     R15,CTGWKA(,R5)                                  DSKL014 01780000
         LH    R14,WKALEN1(,R15)                                DSKL014 01781000
         CH    R14,@CH00072                                     DSKL014 01782000
         BL    @RF00616                                            0616 01783000
*         DO;                                                      0617 01784000
*           VOLTMSTP=VTTTMSTP(R1);  /* MOVE TIMESTAMP TO 'LOCATE'  0618 01785000
*                                      WORKAREA                      */ 01786000
         LR    R14,R1                                           DSKL014 01787000
         MH    R14,@CH00253                                     DSKL014 01788000
         ALR   R14,R2                                           DSKL014 01789000
         AL    R14,@CF03466                                     DSKL014 01790000
         MVC   VOLTMSTP(8,R15),VTTTMSTP-10(R14)                 DSKL014 01791000
*           WKALEN2=LENGTH(VOLTMSTP);/* SET DATA LENGTH IN 'LOCATE'     01792000
*                                      WORKAREA                      */ 01793000
         LA    R14,8                                            DSKL014 01794000
         STH   R14,WKALEN2(,R15)                                DSKL014 01795000
*           RFY                                                    0620 01796000
*             CTGFL BASED(CTGFIELD(1));/* MAP THE FPL                */ 01797000
*           CTGFLNG(1)=LENGTH(VOLTMSTP);/* SET LENGTH OF DATA IN FPL */ 01798000
         L     R5,CTGFIELD(,R5)                                 DSKL014 01799000
         ST    R14,CTGFLNG(,R5)                                 DSKL014 01800000
*           CTGFLPT(1)=ADDR(VOLTMSTP);/* SET DATA ADDR IN FPL        */ 01801000
         LA    R15,VOLTMSTP(,R15)                               DSKL014 01802000
         ST    R15,CTGFLPT(,R5)                                 DSKL014 01803000
*         END;                                                     0623 01804000
*       ELSE                        /* 'LOCATE' WORKAREA TOO SHORT   */ 01805000
*                                                                  0624 01806000
*         /***********************************************************/ 01807000
*         /*                                                         */ 01808000
*         /* SET CCAMODID='BI', CCAREASN=RSN0, CCARETRN=RCVLSZ       */ 01809000
*         /*                                                         */ 01810000
*         /***********************************************************/ 01811000
*                                                                  0624 01812000
*         CCAPROB=IGGSEGID+(RSN0*K256)+RCVLSZ;/* ECD: WORKAREA TOO 0624 01813000
*                                      SMALL. RCD: DATA FEEDBACK AREA   01814000
*                                      TOO SMALL.                    */ 01815000
         B     @RC00616                                            0624 01816000
@RF00616 MVC   CCAPROB(4,R11),@CF03453                             0624 01817000
*     END;                                                         0625 01818000
@RC00616 DS    0H                                                  0626 01819000
*   R13=R13-TWELVE;                 /* POP THE PUSH-DOWN LIST OF   0626 01820000
*                                      RETURN POINTERS TO SET UP FOR    01821000
*                                      RETURN TO 4TH PREVIOUS LEVEL     01822000
*                                      CALLER                        */ 01823000
@RC00612 SH    R13,@CH00072                                        0626 01824000
*   CALL EXIT;                      /* RETURN TO CALLER              */ 01825000
         BAL   R14,EXIT                                         DSKL014 01826000
         DC    X'58E0'                       !!! SOURCE COMPARE FIX !!! 01826010
         DC    0F'0'                                            DSKL014 01826010
         DC    C'IGGPVALD'                                      DSKL014 01826020
*   END;                            /* END OF INNER PROCEDURE        */ 01827000
@EL00008 DS    0H                                                  0628 01828000
@EF00008 DS    0H                                                  0628 01829000
@ER00008 BR    R14                                              DSKL014 01830000
@PB00008 DS    0H                                                  0629 01831000
*   GEN(EJECT);                     /* GO TO A NEW PRINT PAGE        */ 01832000
         EJECT                                                          01833000
*                                                                  0630 01834000
*/********************************************************************/ 01835000
*/*                                                                  */ 01836000
*/*         RETURN-TO-CALLER  PROCEDURE-EXITING  SUBFUNCTION         */ 01837000
*/*                                                                  */ 01838000
*/********************************************************************/ 01839000
*                                                                  0630 01840000
*EXIT:                                                             0630 01841000
*   PROC OPTIONS(NOSAVEAREA,NOSAVE);/* SPECIFY PROCEDURE OPTIONS     */ 01842000
IGGPVALD STM   R12,R14,12(R13)                                  DSKL014 01843010
         LA    R13,12(R13)                                      DSKL014 01843020
         DROP  R12,R10                                          DSKL014 01843030
         BALR  R12,0                                            DSKL014 01843040
         USING *,R12                                            DSKL014 01843050
A000F84  B     A000F8A                                          DSKL014 01843060
A000F88  DC    AL2(A000F84-IGGSEGST)                            DSKL014 01843070
A000F8A  SH    R12,A000F88                                      DSKL014 01843080
         USING IGGSEGST,R12                                     DSKL014 01843090
         LA    R10,4095(,R12)                                   DSKL014 01843100
         USING IGGSEGST+4095,R10                                DSKL014 01843110
         MVI   LPSTOP(R11),0                                    DSKL014 01843120
         L     R15,CCARPL1(,R11)                                DSKL014 01843130
         L     R15,RPLAREA(,R15)                                DSKL014 01843140
         CLI   RCDID(R15),C'V'                                  DSKL014 01843150
         BNE   A0010D4                                          DSKL014 01843160
         MVI   LPSTOP(R11),6                                    DSKL014 01843170
         SLR   R14,R14                                          DSKL014 01843180
         LA    R6,133                                           DSKL014 01843190
         LR    R7,R15                                           DSKL014 01843200
         LR    R8,R7                                            DSKL014 01843210
         ALR   R8,R6                                            DSKL014 01843220
         LA    R15,1                                            DSKL014 01843230
         B     A000FEC                                          DSKL014 01843240
A000FBA  CR    R8,R7                                            DSKL014 01843250
         BC    13,A001008                                       DSKL014 01843260
         LR    R15,R7                                           DSKL014 01843270
         SH    R15,A00134E                                      DSKL014 01843280
         CR    R8,R15                                           DSKL014 01843290
         BC    11,A001008                                       DSKL014 01843300
         TM    3(R8),X'C0'                                 ???  DSKL014 01843310
         BNE   A000FD8                                          DSKL014 01843320
         AL    R14,A001358                                      DSKL014 01843330
A000FD8  SLR   R15,R15                                          DSKL014 01843340
         IC    R15,LPSTOP(,R11)                                 DSKL014 01843350
         ALR   R8,R15                                           DSKL014 01843360
         LA    R15,1                                            DSKL014 01843370
         SLR   R9,R9                                            DSKL014 01843380
         IC    R9,XIOOPT(,R11)                                  DSKL014 01843390
         ALR   R15,R9                                           DSKL014 01843400
A000FEC  STC   R15,XIOOPT(,R11)                                 DSKL014 01843410
         L     R9,CCARPL1(,R11)                                 DSKL014 01843420
         L     R9,RPLAREA(,R9)                                  DSKL014 01843430
         LA    R9,NREPLF(,R9)                                   DSKL014 01843440
         SLR   R5,R5                                            DSKL014 01843450
         IC    R5,84(,R9)                                  ???  DSKL014 01843460
         CR    R15,R5                                           DSKL014 01843470
         BC    13,A000FBA                                       DSKL014 01843480
A001008  LTR   R14,R14                                          DSKL014 01843490
         BE    A001090                                          DSKL014 01843500
         L     R15,CCARPL1(,R11)                                DSKL014 01843510
         L     R15,RPLAREA(,R15)                                DSKL014 01843520
         LA    R15,NREPLF(,R15)                                 DSKL014 01843530
         AH    R15,A001348                                      DSKL014 01843540
         CLC   XIOOPT(1,R11),5(R15)                        ???  DSKL014 01843550
         BC    13,A001090                                       DSKL014 01843560
         SLR   R9,R9                                            DSKL014 01843570
         IC    R9,5(,R15)                                  ???  DSKL014 01843580
         MH    R9,@CH00051                                      DSKL014 01843590
         ALR   R6,R9                                            DSKL014 01843600
         LR    R8,R7                                            DSKL014 01843610
         ALR   R8,R6                                            DSKL014 01843620
         LA    R15,1                                            DSKL014 01843630
         B     A001082                                          DSKL014 01843640
A001040  CR    R8,R7                                            DSKL014 01843650
         BC    13,A00108C                                       DSKL014 01843660
         LR    R15,R7                                           DSKL014 01843670
         SH    R15,A00134C                                      DSKL014 01843680
         CR    R8,R15                                           DSKL014 01843690
         BC    11,A00108C                                       DSKL014 01843700
         CLI   0(R8),0                                     ???  DSKL014 01843710
         BNE   A001066                                          DSKL014 01843720
         SLR   R15,R15                                          DSKL014 01843730
         IC    R15,1(,R8)                                  ???  DSKL014 01843740
         ALR   R6,R15                                           DSKL014 01843750
         B     A001072                                          DSKL014 01843760
A001066  LR    R15,R6                                           DSKL014 01843770
         AH    R15,2(,R8)                                  ???  DSKL014 01843780
         AH    R15,A001336                                      DSKL014 01843790
         LR    R6,R15                                           DSKL014 01843800
A001072  LR    R8,R7                                            DSKL014 01843810
         ALR   R8,R6                                            DSKL014 01843820
         LA    R15,1                                            DSKL014 01843830
         SLR   R9,R9                                            DSKL014 01843840
         IC    R9,XIOOPT(,R11)                                  DSKL014 01843850
         ALR   R15,R9                                           DSKL014 01843860
A001082  STC   R15,XIOOPT(,R11)                                 DSKL014 01843870
         CR    R15,R14                                          DSKL014 01843880
         BC    13,A001040                                       DSKL014 01843890
A00108C  B     A0010BC                                          DSKL014 01843900
A001090  LTR   R14,R14                                          DSKL014 01843910
         BNE   A0010BC                                          DSKL014 01843920
         L     R15,CCARPL1(,R11)                                DSKL014 01843930
         L     R15,RPLAREA(,R15)                                DSKL014 01843940
         LA    R15,NREPLF(,R15)                                 DSKL014 01843950
         AH    R15,A001348                                      DSKL014 01843960
         CLC   XIOOPT(1,R11),5(R15)                        ???  DSKL014 01843970
         BC    13,A0010BC                                       DSKL014 01843980
         SLR   R9,R9                                            DSKL014 01843990
         IC    R9,5(,R15)                                  ???  DSKL014 01844000
         MH    R9,@CH00051                                      DSKL014 01844010
         ALR   R6,R9                                            DSKL014 01844020
A0010BC  L     R15,CCARPL1(,R11)                                DSKL014 01844030
         L     R15,RPLAREA(,R15)                                DSKL014 01844040
         CH    R6,RCDSIZ(,R15)                                  DSKL014 01844050
         BNE   A0010D0                                          DSKL014 01844060
         MVI   LPSTOP(R11),0                                    DSKL014 01844070
A0010D0  B     A001210                                          DSKL014 01844080
A0010D4  L     R15,CCARPL1(,R11)                                DSKL014 01844090
         L     R15,RPLAREA(,R15)                                DSKL014 01844100
         CLI   RCDID(R15),C'W'                                  DSKL014 01844110
         BNE   A001210                                          DSKL014 01844120
         MVI   LPSTOP(R11),6                                    DSKL014 01844130
         SLR   R14,R14                                          DSKL014 01844140
         LA    R6,55                                            DSKL014 01844150
         LR    R7,R15                                           DSKL014 01844160
         LR    R8,R7                                            DSKL014 01844170
         ALR   R8,R6                                            DSKL014 01844180
         LA    R15,1                                            DSKL014 01844190
         B     A00112E                                          DSKL014 01844200
A0010FC  CR    R8,R7                                            DSKL014 01844210
         BC    13,A00114A                                       DSKL014 01844220
         LR    R15,R7                                           DSKL014 01844230
         SH    R15,A00134E                                      DSKL014 01844240
         CR    R8,R15                                           DSKL014 01844250
         BC    11,A00114A                                       DSKL014 01844260
         TM    3(R8),X'C0'                                 ???  DSKL014 01844270
         BNE   A00111A                                          DSKL014 01844280
         AL    R14,A001358                                      DSKL014 01844290
A00111A  SLR   R15,R15                                          DSKL014 01844300
         IC    R15,LPSTOP(,R11)                                 DSKL014 01844310
         ALR   R8,R15                                           DSKL014 01844320
         LA    R15,1                                            DSKL014 01844330
         SLR   R9,R9                                            DSKL014 01844340
         IC    R9,XIOOPT(,R11)                                  DSKL014 01844350
         ALR   R15,R9                                           DSKL014 01844360
A00112E  STC   R15,XIOOPT(,R11)                                 DSKL014 01844370
         L     R9,CCARPL1(,R11)                                 DSKL014 01844380
         L     R9,RPLAREA(,R9)                                  DSKL014 01844390
         LA    R9,NREPLF(,R9)                                   DSKL014 01844400
         SLR   R5,R5                                            DSKL014 01844410
         IC    R5,6(,R9)                                   ???  DSKL014 01844420
         CR    R15,R5                                           DSKL014 01844430
         BC    13,A0010FC                                       DSKL014 01844440
A00114A  LTR   R14,R14                                          DSKL014 01844450
         BE    A0011D0                                          DSKL014 01844460
         LA    R15,1                                            DSKL014 01844470
         L     R9,CCARPL1(,R11)                                 DSKL014 01844480
         L     R9,RPLAREA(,R9)                                  DSKL014 01844490
         LA    R9,NREPLF(,R9)                                   DSKL014 01844500
         ALR   R9,R15                                           DSKL014 01844510
         CLC   XIOOPT(1,R11),5(R9)                         ???  DSKL014 01844520
         BC    13,A0011D0                                       DSKL014 01844530
         SLR   R5,R5                                            DSKL014 01844540
         IC    R5,5(,R9)                                   ???  DSKL014 01844550
         MH    R5,@CH00051                                      DSKL014 01844560
         ALR   R6,R5                                            DSKL014 01844570
         LR    R8,R7                                            DSKL014 01844580
         ALR   R8,R6                                            DSKL014 01844590
         B     A0011C2                                          DSKL014 01844600
A001180  CR    R8,R7                                            DSKL014 01844610
         BC    13,A0011CC                                       DSKL014 01844620
         LR    R15,R7                                           DSKL014 01844630
         SH    R15,A00134C                                      DSKL014 01844640
         CR    R8,R15                                           DSKL014 01844650
         BC    11,A0011CC                                       DSKL014 01844660
         CLI   0(R8),0                                     ???  DSKL014 01844670
         BNE   A0011A6                                          DSKL014 01844680
         SLR   R15,R15                                          DSKL014 01844690
         IC    R15,1(,R8)                                  ???  DSKL014 01844700
         ALR   R6,R15                                           DSKL014 01844710
         B     A0011B2                                          DSKL014 01844720
A0011A6  LR    R15,R6                                           DSKL014 01844730
         AH    R15,2(,R8)                                  ???  DSKL014 01844740
         AH    R15,A001336                                      DSKL014 01844750
         LR    R6,R15                                           DSKL014 01844760
A0011B2  LR    R8,R7                                            DSKL014 01844770
         ALR   R8,R6                                            DSKL014 01844780
         LA    R15,1                                            DSKL014 01844790
         SLR   R9,R9                                            DSKL014 01844800
         IC    R9,XIOOPT(,R11)                                  DSKL014 01844810
         ALR   R15,R9                                           DSKL014 01844820
A0011C2  STC   R15,XIOOPT(,R11)                                 DSKL014 01844830
         CR    R15,R14                                          DSKL014 01844840
         BC    13,A001180                                       DSKL014 01844850
A0011CC  B     A0011FC                                          DSKL014 01844860
A0011D0  LTR   R14,R14                                          DSKL014 01844870
         BNE   A0011FC                                          DSKL014 01844880
         L     R15,CCARPL1(,R11)                                DSKL014 01844890
         L     R15,RPLAREA(,R15)                                DSKL014 01844900
         LA    R15,NREPLF(,R15)                                 DSKL014 01844910
         AL    R15,A001358                                      DSKL014 01844920
         CLC   XIOOPT(1,R11),5(R15)                        ???  DSKL014 01844930
         BC    13,A0011FC                                       DSKL014 01844940
         SLR   R9,R9                                            DSKL014 01844950
         IC    R9,5(,R15)                                  ???  DSKL014 01844960
         MH    R9,@CH00051                                      DSKL014 01844970
         ALR   R6,R9                                            DSKL014 01844980
A0011FC  L     R15,CCARPL1(,R11)                                DSKL014 01844990
         L     R15,RPLAREA(,R15)                                DSKL014 01845000
         CH    R6,RCDSIZ(,R15)                                  DSKL014 01845010
         BNE   A001210                                          DSKL014 01845020
         MVI   LPSTOP(R11),0                                    DSKL014 01845030
A001210  BAL   R14,EXIT                                         DSKL014 01845040
         DC    0F'0'                                            DSKL014 01845045
         DC    CL8'IGGPDUMP'                                    DSKL014 01845050
         BR    R14                                              DSKL014 01845060
IGGPDUMP STM   R12,R14,12(R13)                                  DSKL014 01845070
         LA    R13,12(R13)                                      DSKL014 01845080
         DROP  R12,R10                                          DSKL014 01845090
         BALR  R12,0                                            DSKL014 01845100
         USING *,R12                                            DSKL014 01845110
A001228  B     A00122E                                          DSKL014 01845120
A00122C  DC    AL2(A001228-IGGSEGST)                            DSKL014 01845130
A00122E  SH    R12,A00122C                                      DSKL014 01845140
         USING IGGSEGST,R12                                     DSKL014 01845150
         LA    R10,4095(,R12)                                   DSKL014 01845160
         USING IGGSEGST+4095,R10                                DSKL014 01845170
         LA    R15,CCAREGS(,R11)                                DSKL014 01845180
         LA    R14,204                                          DSKL014 01845190
         ALR   R14,R15                                          DSKL014 01845200
         CR    R13,R14                                          DSKL014 01845210
         BH    A001268                                          DSKL014 01845220
         AH    R15,A001350                                      DSKL014 01845230
         LR    R14,R15                                          DSKL014 01845240
         STM   R0,R9,72(R14)                               ???  DSKL014 01845250
         LR    R6,R14                                           DSKL014 01845260
         L     R15,A0013D8                                      DSKL014 01845270
         BALR  R14,R15                                          DSKL014 01845280
         LA    R10,4095(,R12)                                   DSKL014 01845290
         LA    R14,CCAREGS(,R11)                                DSKL014 01845300
         AH    R14,A001350                                      DSKL014 01845310
         LM    R0,R9,72(R14)                               ???  DSKL014 01845320
A001268  BAL   R14,EXIT                                         DSKL014 01845330
         BR    R14                                              DSKL014 01845340
EXIT     DS    0H                                               DSKL014 01845990
         LM 12,14,0(13)                                                 01846000
*   GEN(MVI 12(13),255);            /* MARK END OF PDL               */ 01847000
         MVI 12(13),255                                                 01848000
*   GEN(BR 14);                     /* RETURN TO CALLER              */ 01849000
         BR 14                                                          01850000
*PATCH:                                                            0634 01851000
*   GEN(DC (12+((*+139-@MAINENT)/140))A(0));/* PATCH AREA            */ 01852000
PATCH    DC (12+((*+139-@MAINENT)/140))A(0)                             01853000
*   END;                            /* END OF EXIT PROCEDURE         */ 01854000
@EL00009 DS    0H                                                  0635 01855000
@EF00009 DS    0H                                                  0635 01856000
@ER00009 BAL   R14,IGGPDUMP                                     DSKL014 01857000
         BR    R14                                              DSKL014 01857010
*   END                                                            0636 01858000
*                                                                  0636 01859000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 01860000
*/*%INCLUDE SYSLIB  (IGGMCDCL)                                       */ 01861000
*/*%INCLUDE SYSLIB  (IGGMCTRC)                                       */ 01862000
*/*%INCLUDE SYSLIB  (IGGCCA  )                                       */ 01863000
*/*%INCLUDE SYSLIB  (IEZCTGPL)                                       */ 01864000
*/*%INCLUDE SYSLIB  (IEZCTGFL)                                       */ 01865000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 01866000
*/*%INCLUDE SYSLIB  (IKJTCB  )                                       */ 01867000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 01868000
*/*%INCLUDE SYSLIB  (IFGACB  )                                       */ 01869000
*/*%INCLUDE SYSLIB  (AMCBS   )                                       */ 01870000
*/*%INCLUDE SYSLIB  (IGGCAXWA)                                       */ 01871000
*/*%INCLUDE SYSLIB  (IEZCTGFV)                                       */ 01872000
*/*%INCLUDE SYSLIB  (IEZCTGWA)                                       */ 01873000
*/*%INCLUDE SYSLIB  (IEZCTGVL)                                       */ 01874000
*/*%INCLUDE SYSLIB  (IEZCTGCV)                                       */ 01875000
*/*%INCLUDE SYSLIB  (IFGRPL  )                                       */ 01876000
*/*%INCLUDE SYSLIB  (IDARMRCD)                                       */ 01877000
*/*%INCLUDE SYSLIB  (IGGMVEDC)                                       */ 01878000
*/*%INCLUDE SYSLIB  (IGGMDRWA)                                       */ 01879000
*/*%INCLUDE SYSLIB  (IGGMCMWA)                                       */ 01880000
*/*%INCLUDE SYSLIB  (IDCDF60 )                                       */ 01881000
*                                                                  0636 01882000
*       ;                                                          0636 01883000
@DATA    DS    0H                                                       01887000
A001336  DC    H'4'                                             DSKL014 01888010
@CH00053 DC    H'5'                                                     01889000
@CH00051 DC    H'6'                                                     01890000
@CH00250 DC    H'10'                                                    01891000
@CH00072 DC    H'12'                                                    01892000
A001340  DC    H'13'                                            DSKL014 01892010
@CH00253 DC    H'14'                                                    01893000
@CH00110 DC    H'20'                                                    01894000
@CH00284 DC    H'54'                                                    01895000
A001348  DC    H'79'                                            DSKL014 01895010
@CH03290 DC    H'508'                                                   01896000
A00134C  DC    H'-501'                                          DSKL014 01896020
A00134E  DC    H'-500'                                          DSKL014 01896030
A001350  DC    H'228'                                           DSKL014 01896040
@SX03472 XC    WORK(0,R5),WORK(R5)                              DSKL014 01897000
A001358  DC    F'1'                                             DSKL014 01898000
@CF00055 DC    F'2'                                                     01902000
@CH00055 EQU   @CF00055+2                                               01903000
@CF00414 DC    F'3'                                                     01904000
@CF02795 DC    F'9'                                                     01905000
@CF03273 DC    F'47'                                                    01906000
@CF03276 DC    F'505'                                                   01907000
@CF01046 DC    F'512'                                                   01908000
@CF03453 DC    F'-1027014616'                                           01909000
@CF03437 DC    F'-1027014426'                                           01910000
@CF03446 DC    F'-1027013980'                                           01911000
@CF03441 DC    F'-1027013624'                                           01912000
@CF03436 DC    F'-1027013604'                                           01913000
@CF03435 DC    F'-1027013508'                                           01914000
@CF03444 DC    F'-1027012996'                                           01915000
@CF03440 DC    F'-1027011972'                                           01916000
A001394  DC    F'-1027010948'                                   DSKL014 01916010
A001398  DC    F'-1027010436'                                   DSKL014 01916020
A00139C  DC    F'-1027008900'                                   DSKL014 01916030
@CF03449 DC    F'-1027007992'                                           01917000
@CF03452 DC    F'-1027007480'                                           01918000
A0013A8  DC    F'-1027006416'                                   DSKL014 01918010
A0013AC  DC    F'-1027005904'                                   DSKL014 01918020
@CF03476 DC    F'-10'                                                   01919000
@CF03466 DC    F'-4'                                                    01920000
@CF03268 DC    XL4'FFFFFF'                                              01921000
         DC    F'1'                                             DSKL014 01927000
@CV03233 DC    V(IGGPARFS)                                              01930000
@CV03234 DC    V(IGGPIORA)                                              01931000
@CV03235 DC    V(IGGPRAG)                                               01932000
@CV03236 DC    V(IGGPMOD)                                               01933000
@CV03237 DC    V(IGGPEXT)                                               01934000
A0013D4  DC    V(IGGPMOD)                                       DSKL014 01935000
A0013D8  DC    V(IGGPPDO)                                       DSKL014 01935010
A0013DC  DC    V(IGGPEXT)                                       DSKL014 01935020
CPLEN    DC    AL2(28)                                                  01936000
FPLEN    DC    AL2(16)                                                  01937000
@CC03284 DC    C'VSAM.CATALOG.BASE.DATA.RECORD               '          01938000
A001410  DC    C'VSAM.CATALOG.BASE.INDEX.RECORD              '  DSKL014 01938010
A00143C  DC    C'CDIAVWEUXGRYB'                                 DSKL014 01938020
A001449  DC    X'0001F901F90000'                                DSKL014 01938030
VOLTYPES DC    CL2'VW'                                                  01939000
CRADIRCT DC    CL8'CRADIRCT'                                            01940000
RELREPNO DC    CL8'RELREPNO'                                            01941000
R0       EQU   0                                                DSKL014 01960000
R1       EQU   1                                                DSKL014 01961000
R2       EQU   2                                                DSKL014 01962000
R3       EQU   3                                                DSKL014 01963000
R4       EQU   4                                                DSKL014 01964000
R5       EQU   5                                                DSKL014 01965000
R6       EQU   6                                                DSKL014 01966000
R7       EQU   7                                                DSKL014 01967000
R8       EQU   8                                                DSKL014 01968000
R9       EQU   9                                                DSKL014 01969000
R10      EQU   10                                               DSKL014 01970000
R11      EQU   11                                               DSKL014 01971000
R12      EQU   12                                               DSKL014 01972000
R13      EQU   13                                               DSKL014 01973000
R14      EQU   14                                               DSKL014 01973010
R15      EQU   15                                               DSKL014 01974000
CVTPTR   EQU   16                                                       01992000
PSA      EQU   0                                                        01993000
FLCRNPSW EQU   PSA                                                      01994000
FLCROPSW EQU   PSA+8                                                    01995000
FLCICCW2 EQU   PSA+16                                                   01996000
PSAEEPSW EQU   PSA+132                                                  01997000
PSAESPSW EQU   PSA+136                                                  01998000
FLCSVILC EQU   PSAESPSW+1                                               01999000
PSAEPPSW EQU   PSA+140                                                  02000000
FLCPIILC EQU   PSAEPPSW+1                                               02001000
FLCPICOD EQU   PSAEPPSW+2                                               02002000
PSAPICOD EQU   FLCPICOD+1                                               02003000
FLCTEA   EQU   PSAEPPSW+4                                               02004000
FLCPER   EQU   PSA+152                                                  02005000
FLCMCLA  EQU   PSA+168                                                  02006000
FLCIOEL  EQU   FLCMCLA+4                                                02007000
FLCIOA   EQU   FLCMCLA+16                                               02008000
FLCFSA   EQU   FLCMCLA+80                                               02009000
PSASUPER EQU   PSA+552                                                  02010000
PSASUP1  EQU   PSASUPER                                                 02011000
PSASUP2  EQU   PSASUPER+1                                               02012000
PSASUP3  EQU   PSASUPER+2                                               02013000
PSASUP4  EQU   PSASUPER+3                                               02014000
PSACLHT  EQU   PSA+640                                                  02015000
PSALKSA  EQU   PSA+696                                                  02016000
PSAHLHI  EQU   PSA+760                                                  02017000
PSADSSFL EQU   PSA+836                                                  02018000
PSADSSF1 EQU   PSADSSFL                                                 02019000
PSADSSF3 EQU   PSADSSFL+2                                               02020000
PSADSSF4 EQU   PSADSSFL+3                                               02021000
PSARSVT  EQU   PSA+896                                                  02022000
IGGCCA   EQU   0                                                        02023000
CCAPROB  EQU   IGGCCA+4                                                 02024000
CCAERRCD EQU   CCAPROB+2                                                02025000
CCAREASN EQU   CCAERRCD                                                 02026000
CCARETRN EQU   CCAERRCD+1                                               02027000
CCACD1   EQU   CCARETRN                                                 02028000
CCAFLG1  EQU   IGGCCA+14                                                02029000
CCAF1KEY EQU   CCAFLG1                                                  02030000
CCAF1KGE EQU   CCAFLG1                                                  02031000
CCAF1UP  EQU   CCAFLG1                                                  02032000
CCAFLG2  EQU   IGGCCA+15                                                02033000
CCAF2NVC EQU   CCAFLG2                                                  02034000
CCAF2COB EQU   CCAFLG2                                                  02035000
CCAF2CO  EQU   CCAF2COB                                                 02036000
CCAFLG3  EQU   IGGCCA+16                                                02037000
CCAFLG4  EQU   IGGCCA+17                                                02038000
CCAFLG5  EQU   IGGCCA+18                                                02039000
CCAMODPA EQU   CCAFLG5                                                  02040000
CCAFLG6  EQU   IGGCCA+19                                                02041000
CCAREUSE EQU   CCAFLG6                                                  02042000
CCATCB   EQU   IGGCCA+20                                                02043000
CCARB    EQU   IGGCCA+24                                                02044000
CCACPL   EQU   IGGCCA+28                                                02045000
CCAACB   EQU   IGGCCA+32                                                02046000
CCAURAB  EQU   IGGCCA+40                                                02047000
CCASRCH  EQU   IGGCCA+44                                                02048000
CCASRID  EQU   CCASRCH                                                  02049000
CCASRCIN EQU   CCASRID                                                  02050000
CCARAB0  EQU   IGGCCA+88                                                02051000
CCAR0FLG EQU   CCARAB0                                                  02052000
CCAR0REC EQU   CCARAB0+4                                                02053000
CCAR0SEG EQU   CCARAB0+8                                                02054000
CCARAB1  EQU   IGGCCA+108                                               02055000
CCAR1FLG EQU   CCARAB1                                                  02056000
CCAR1SEG EQU   CCARAB1+8                                                02057000
CCARAB2  EQU   IGGCCA+128                                               02058000
CCAR2FLG EQU   CCARAB2                                                  02059000
CCAR2SEG EQU   CCARAB2+8                                                02060000
CCARAB3  EQU   IGGCCA+148                                               02061000
CCAR3FLG EQU   CCARAB3                                                  02062000
CCAR3SEG EQU   CCARAB3+8                                                02063000
CCARAB4  EQU   IGGCCA+168                                               02064000
CCAR4FLG EQU   CCARAB4                                                  02065000
CCAR4SEG EQU   CCARAB4+8                                                02066000
CCARAB5  EQU   IGGCCA+188                                               02067000
CCAR5FLG EQU   CCARAB5                                                  02068000
CCAR5SEG EQU   CCARAB5+8                                                02069000
CCARPLK  EQU   IGGCCA+208                                               02070000
CCARPLX  EQU   IGGCCA+210                                               02071000
CCARPLT  EQU   IGGCCA+211                                               02072000
CCATIQRN EQU   IGGCCA+212                                               02073000
CCARPL1  EQU   IGGCCA+220                                               02074000
CCADESA  EQU   IGGCCA+224                                               02075000
CCANDEXT EQU   CCADESA                                                  02076000
CCASSVOL EQU   CCADESA+2                                                02077000
CCAEXTDE EQU   CCADESA+4                                                02078000
CCAEXTAD EQU   CCAEXTDE+2                                               02079000
CCAEXTCC EQU   CCAEXTAD                                                 02080000
CCAEXTHH EQU   CCAEXTAD+2                                               02081000
CCAEQDQ  EQU   IGGCCA+280                                               02082000
CCAEDOPT EQU   CCAEQDQ+2                                                02083000
CCAMLRET EQU   IGGCCA+296                                               02084000
CCAMSSPL EQU   IGGCCA+300                                               02085000
CCAMNSPL EQU   CCAMSSPL+9                                               02086000
CCACMS   EQU   IGGCCA+316                                               02087000
CCACMSWA EQU   CCACMS                                                   02088000
CCACPE5  EQU   IGGCCA+324                                               02089000
CCACPE6  EQU   IGGCCA+340                                               02090000
CCACPE61 EQU   IGGCCA+344                                               02091000
CCACPE7  EQU   IGGCCA+348                                               02092000
CCAFLPT  EQU   IGGCCA+364                                               02093000
CCADICT  EQU   IGGCCA+372                                               02094000
CCAXCPL  EQU   IGGCCA+376                                               02095000
CCARABB  EQU   IGGCCA+380                                               02096000
CCALREL  EQU   IGGCCA+396                                               02097000
CCASN    EQU   IGGCCA+398                                               02098000
CCARBA   EQU   IGGCCA+448                                               02099000
CCACRAVL EQU   CCARBA                                                   02100000
CCACRADT EQU   CCARBA+6                                                 02101000
CCATLNG  EQU   IGGCCA+468                                               02102000
CCAIDPT3 EQU   IGGCCA+480                                               02103000
CCAGRGC  EQU   IGGCCA+493                                               02104000
CCAGRHI  EQU   IGGCCA+494                                               02105000
CCASSEQ  EQU   CCAGRHI                                                  02106000
CCAFLG7  EQU   IGGCCA+552                                               02107000
CCAROREQ EQU   CCAFLG7                                                  02108000
CCAFLG8  EQU   IGGCCA+553                                               02109000
CCALPIND EQU   CCAFLG8                                                  02110000
CCAVRIND EQU   CCAFLG8                                                  02111000
CCAFLG9  EQU   IGGCCA+554                                               02112000
CCARAEOV EQU   CCAFLG9                                                  02113000
CCAUCRA  EQU   CCAFLG9                                                  02114000
CCARESUM EQU   CCAFLG9                                                  02115000
CCASMFLG EQU   IGGCCA+562                                               02116000
CCASMFG1 EQU   CCASMFLG                                                 02117000
CCASMFUC EQU   CCASMFG1                                                 02118000
CCASMFSR EQU   CCASMFG1                                                 02119000
CCABMINP EQU   IGGCCA+684                                               02120000
CCABMFLG EQU   CCABMINP+6                                               02121000
CCABMOUT EQU   IGGCCA+692                                               02122000
CCABMOFG EQU   CCABMOUT+4                                               02123000
CCATEMPS EQU   IGGCCA+744                                               02124000
CCAMNCAT EQU   IGGCCA+784                                               02125000
CCAMNAT  EQU   CCAMNCAT                                                 02126000
MNATTOP  EQU   CCAMNAT                                                  02127000
MNATFULL EQU   MNATTOP                                                  02128000
MNATFLGS EQU   CCAMNAT+240                                              02129000
CCAMNLEN EQU   CCAMNCAT+249                                             02130000
CCAMNADR EQU   CCAMNCAT+252                                             02131000
CCAARFWA EQU   IGGCCA+1040                                              02132000
ARFGMLEN EQU   CCAARFWA                                                 02133000
CCARVFG1 EQU   IGGCCA+1056                                              02134000
CCAFLG11 EQU   IGGCCA+1059                                      DSKL014 02134010
CCAREGS  EQU   IGGCCA+1060                                              02135000
CCABZSAV EQU   IGGCCA+1408                                              02136000
CCACUMPL EQU   IGGCCA+1412                                              02137000
CCACRACI EQU   IGGCCA+1420                                              02138000
CCARAACB EQU   IGGCCA+1424                                              02139000
CCARALSA EQU   IGGCCA+1440                                              02140000
CCAFLG10 EQU   IGGCCA+1444                                              02141000
CCASUMTT EQU   IGGCCA+1445                                              02142000
CCARANCA EQU   IGGCCA+1452                                              02143000
CCARAVCA EQU   IGGCCA+1460                                              02144000
CCAVTS   EQU   IGGCCA+1468                                              02145000
CCASMFP  EQU   IGGCCA+1480                                              02146000
CCAPROBX EQU   IGGCCA+1484                                              02147000
CCAERCDX EQU   CCAPROBX+2                                               02148000
CTGPL    EQU   0                                                        02149000
CTGOPTN1 EQU   CTGPL                                                    02150000
CTGNAME  EQU   CTGOPTN1                                                 02151000
CTGOPTN2 EQU   CTGPL+1                                                  02152000
CTGEXT   EQU   CTGOPTN2                                                 02153000
CTGERASE EQU   CTGOPTN2                                                 02154000
CTGSMF   EQU   CTGERASE                                                 02155000
CTGREL   EQU   CTGSMF                                                   02156000
CTGPURG  EQU   CTGOPTN2                                                 02157000
CTGVMNT  EQU   CTGPURG                                                  02158000
CTGGTNXT EQU   CTGOPTN2                                                 02159000
CTGOPTN3 EQU   CTGPL+2                                                  02160000
CTGFUNC  EQU   CTGOPTN3                                                 02161000
CTGOPTN4 EQU   CTGPL+3                                                  02162000
CTGENT   EQU   CTGPL+4                                                  02163000
CTGFVT   EQU   CTGENT                                                   02164000
CTGCAT   EQU   CTGPL+8                                                  02165000
CTGCVOL  EQU   CTGCAT                                                   02166000
CTGWKA   EQU   CTGPL+12                                                 02167000
CTGDSORG EQU   CTGPL+16                                                 02168000
CTGOPTNS EQU   CTGDSORG                                                 02169000
CTGNOFLD EQU   CTGPL+19                                                 02170000
CTGDDNM  EQU   CTGPL+20                                                 02171000
CTGNEWNM EQU   CTGDDNM                                                  02172000
CTGFBFLG EQU   CTGNEWNM+2                                               02173000
CTGJSCB  EQU   CTGPL+24                                                 02174000
CTGFIELD EQU   CTGPL+28                                                 02175000
CTGFL    EQU   0                                                        02176000
CTGFLDNO EQU   CTGFL                                                    02177000
CTGFLDCD EQU   CTGFL+1                                                  02178000
CTGFLDGC EQU   CTGFL+2                                                  02179000
CTGFLDRE EQU   CTGFL+3                                                  02180000
CTGFLDWA EQU   CTGFL+4                                                  02181000
CTGFLDNM EQU   CTGFL+8                                                  02182000
CTGFLCHN EQU   CTGFL+12                                                 02183000
CTGFLDAT EQU   CTGFL+16                                                 02184000
CTGFLNG  EQU   CTGFLDAT                                                 02185000
CTGFLPT  EQU   CTGFLDAT+4                                               02186000
USERWKA  EQU   0                                                        02187000
WKALEN1  EQU   USERWKA                                                  02188000
WKALEN2  EQU   USERWKA+2                                                02189000
WKA      EQU   USERWKA+4                                                02190000
ENTNAMES EQU   WKA                                                      02191000
DICTENT  EQU   0                                                        02192000
DICTFLGS EQU   DICTENT                                                  02193000
DIC2ENT  EQU   0                                                        02194000
DIC2FLGS EQU   DIC2ENT                                                  02195000
CCARAB   EQU   0                                                        02196000
CCARABFL EQU   CCARAB                                                   02197000
CCARBUPD EQU   CCARABFL                                                 02198000
CCACPE1  EQU   CCARAB+4                                                 02199000
CCACPE2  EQU   CCARAB+8                                                 02200000
CCACPE3  EQU   CCARAB+12                                                02201000
CCACPE4  EQU   CCARAB+16                                                02202000
CATGOPT  EQU   0                                                        02203000
CATGOCI  EQU   CATGOPT                                                  02204000
CATGOFLG EQU   CATGOCI                                                  02205000
CATGOGC1 EQU   CATGOPT+3                                                02206000
CATGOSEQ EQU   CATGOPT+4                                                02207000
CATRCD   EQU   0                                                        02208000
RCDKEYTY EQU   CATRCD                                                   02209000
RCDCINO  EQU   CATRCD+1                                                 02210000
RCDID    EQU   CATRCD+44                                                02211000
RCDSIZ   EQU   CATRCD+45                                                02212000
NREPCV   EQU   CATRCD+47                                                02213000
NREPLF   EQU   CATRCD+48                                                02214000
REPCNTRL EQU   0                                                        02215000
EXTRCDPT EQU   REPCNTRL                                                 02216000
REPCNT   EQU   REPCNTRL+5                                               02217000
VARFIELD EQU   0                                                        02218000
CNTRLINF EQU   0                                                        02219000
CVTMAP   EQU   0                                                        02220000
CVTTCBP  EQU   CVTMAP                                                   02221000
CVTDAR   EQU   CVTMAP+72                                                02222000
CVTFLGS1 EQU   CVTDAR                                                   02223000
CVTDCB   EQU   CVTMAP+116                                               02224000
CVTIERLC EQU   CVTMAP+144                                               02225000
CVTOPTA  EQU   CVTMAP+182                                               02226000
CVTOPTB  EQU   CVTMAP+183                                               02227000
CVTGTF   EQU   CVTMAP+236                                               02228000
CVTGTFST EQU   CVTGTF                                                   02229000
CVTGTFS  EQU   CVTGTFST                                                 02230000
CVTSTATE EQU   CVTGTFST                                                 02231000
CVTTMODE EQU   CVTGTFST                                                 02232000
CVTFORM  EQU   CVTGTFST                                                 02233000
CVTAQAVT EQU   CVTMAP+240                                               02234000
CVTTCMFG EQU   CVTAQAVT                                                 02235000
CVTVOLM2 EQU   CVTMAP+244                                               02236000
CVTTATA  EQU   CVTVOLM2                                                 02237000
CVTTSKS  EQU   CVTTATA                                                  02238000
CVTVOLF2 EQU   CVTTSKS                                                  02239000
CVTTAT   EQU   CVTTATA+1                                                02240000
CVTATER  EQU   CVTMAP+248                                               02241000
CVTEXT1  EQU   CVTMAP+252                                               02242000
CVTCBSP  EQU   CVTMAP+256                                               02243000
CVTPURG  EQU   CVTMAP+260                                               02244000
CVTAMFF  EQU   CVTMAP+264                                               02245000
CVTQMSG  EQU   CVTMAP+268                                               02246000
CVTDMSR  EQU   CVTMAP+272                                               02247000
CVTRSV37 EQU   CVTDMSR                                                  02248000
CVTDMSRF EQU   CVTRSV37                                                 02249000
CVTERPV  EQU   CVTMAP+316                                               02250000
CVTINTLA EQU   CVTMAP+320                                               02251000
CVTAPF   EQU   CVTMAP+324                                               02252000
CVTEXT2  EQU   CVTMAP+328                                               02253000
CVTHJES  EQU   CVTMAP+332                                               02254000
CVTPGSIA EQU   CVTMAP+348                                               02255000
CVTA1F1  EQU   CVTMAP+356                                               02256000
CVTSYSK  EQU   CVTMAP+357                                               02257000
CVTVOLM1 EQU   CVTMAP+380                                               02258000
CVTVOLF1 EQU   CVTVOLM1                                                 02259000
CVTATMCT EQU   CVTMAP+388                                               02260000
CVTXTNT1 EQU   0                                                        02261000
CVTXTNT2 EQU   0                                                        02262000
CVTDSSV  EQU   CVTXTNT2                                                 02263000
CVTFLGBT EQU   CVTXTNT2+5                                               02264000
CVTQID   EQU   CVTXTNT2+24                                              02265000
CVTRV400 EQU   CVTXTNT2+52                                              02266000
CVTRV409 EQU   CVTXTNT2+53                                              02267000
CVTATCVT EQU   CVTXTNT2+64                                              02268000
CVTRV429 EQU   CVTXTNT2+84                                              02269000
CVTRV438 EQU   CVTXTNT2+85                                              02270000
CVTRV457 EQU   CVTXTNT2+112                                             02271000
CVTRV466 EQU   CVTXTNT2+113                                             02272000
CVTFIX   EQU   0                                                        02273000
CVTRELNO EQU   CVTFIX+252                                               02274000
TCBWORDS EQU   0                                                        02275000
TCBPTR   EQU   TCBWORDS+4                                               02276000
TCBFIX   EQU   0                                                        02277000
TCBFRS   EQU   TCBFIX                                                   02278000
TCB      EQU   0                                                        02279000
TCBPIE   EQU   TCB+4                                                    02280000
TCBPMASK EQU   TCBPIE                                                   02281000
TCBCMP   EQU   TCB+16                                                   02282000
TCBCMPF  EQU   TCBCMP                                                   02283000
TCBCPP   EQU   TCBCMPF                                                  02284000
TCBSTCC  EQU   TCBCMPF                                                  02285000
TCBCDBL  EQU   TCBCMPF                                                  02286000
TCBCWTO  EQU   TCBCMPF                                                  02287000
TCBCIND  EQU   TCBCMPF                                                  02288000
TCBCMSG  EQU   TCBCMPF                                                  02289000
TCBTRN   EQU   TCB+20                                                   02290000
TCBABF   EQU   TCBTRN                                                   02291000
TCBMSS   EQU   TCB+24                                                   02292000
TCBPKF   EQU   TCB+28                                                   02293000
TCBFLGS  EQU   TCB+29                                                   02294000
TCBFLGS1 EQU   TCBFLGS                                                  02295000
TCBFLGS2 EQU   TCBFLGS+1                                                02296000
TCBFLGS3 EQU   TCBFLGS+2                                                02297000
TCBFLGS4 EQU   TCBFLGS+3                                                02298000
TCBFLGS5 EQU   TCBFLGS+4                                                02299000
TCBABWF  EQU   TCBFLGS5                                                 02300000
TCBJPQ   EQU   TCB+44                                                   02301000
TCBPURGE EQU   TCBJPQ                                                   02302000
TCBGRS   EQU   TCB+48                                                   02303000
TCBFSA   EQU   TCB+112                                                  02304000
TCBTME   EQU   TCB+120                                                  02305000
TCBJSTCB EQU   TCB+124                                                  02306000
TCBTSFLG EQU   TCB+148                                                  02307000
TCBTSTSK EQU   TCBTSFLG                                                 02308000
TCBSTAB  EQU   TCB+160                                                  02309000
TCBNSTAE EQU   TCBSTAB                                                  02310000
TCBTCT   EQU   TCB+164                                                  02311000
TCBTCTGF EQU   TCBTCT                                                   02312000
TCBSCNDY EQU   TCB+172                                                  02313000
TCBNDSP  EQU   TCBSCNDY                                                 02314000
TCBNDSP1 EQU   TCBNDSP+1                                                02315000
TCBNDSP2 EQU   TCBNDSP+2                                                02316000
TCBNDSP3 EQU   TCBNDSP+3                                                02317000
TCBJSCB  EQU   TCB+180                                                  02318000
TCBRECDE EQU   TCBJSCB                                                  02319000
TCBEXT1  EQU   TCB+196                                                  02320000
TCBBITS  EQU   TCB+200                                                  02321000
TCBNDSP4 EQU   TCBBITS                                                  02322000
TCBNDSP5 EQU   TCBBITS+1                                                02323000
TCBFLGS6 EQU   TCBBITS+2                                                02324000
TCBFLGS7 EQU   TCBBITS+3                                                02325000
TCBDAR   EQU   TCB+204                                                  02326000
TCBDARC  EQU   TCBDAR                                                   02327000
TCBEXT2  EQU   TCB+208                                                  02328000
TCBFOE   EQU   TCB+244                                                  02329000
TCBESTAE EQU   TCB+264                                                  02330000
TCBESTRM EQU   TCBESTAE+1                                               02331000
TCBFBYT1 EQU   TCB+276                                                  02332000
TCBFBYT2 EQU   TCB+277                                                  02333000
TCBRV124 EQU   TCB+278                                                  02334000
TCBRV133 EQU   TCB+279                                                  02335000
TCBXTNT2 EQU   0                                                        02336000
TCBGTF   EQU   TCBXTNT2                                                 02337000
TCBTFLG  EQU   TCBGTF                                                   02338000
TCBRV146 EQU   TCBXTNT2+28                                              02339000
TCBRV155 EQU   TCBXTNT2+29                                              02340000
TCBRV164 EQU   TCBXTNT2+30                                              02341000
TCBRV173 EQU   TCBXTNT2+31                                              02342000
IFGACB   EQU   0                                                        02343000
ACBCOMN  EQU   IFGACB                                                   02344000
ACBLENG  EQU   ACBCOMN+2                                                02345000
ACBLENG2 EQU   ACBLENG                                                  02346000
ACBAMBL  EQU   ACBCOMN+4                                                02347000
ACBJWA   EQU   ACBAMBL                                                  02348000
ACBMACRF EQU   ACBCOMN+12                                               02349000
ACBMACR1 EQU   ACBMACRF                                                 02350000
ACBADR   EQU   ACBMACR1                                                 02351000
ACBCNV   EQU   ACBMACR1                                                 02352000
ACBMACR2 EQU   ACBMACRF+1                                               02353000
ACBBUFPL EQU   ACBCOMN+20                                               02354000
ACBMACR3 EQU   ACBBUFPL                                                 02355000
ACBRECFM EQU   ACBCOMN+24                                               02356000
ACBCCTYP EQU   ACBCOMN+25                                               02357000
ACBOPT   EQU   ACBCOMN+26                                               02358000
ACBDSORG EQU   ACBOPT                                                   02359000
ACBCROPS EQU   ACBDSORG                                                 02360000
ACBEXLST EQU   ACBCOMN+36                                               02361000
ACBDDNM  EQU   ACBCOMN+40                                               02362000
ACBAMETH EQU   ACBDDNM+3                                                02363000
ACBOFLGS EQU   ACBCOMN+48                                               02364000
ACBEXFG  EQU   ACBOFLGS                                                 02365000
ACBIOSFG EQU   ACBOFLGS                                                 02366000
ACBINFLG EQU   ACBCOMN+50                                               02367000
ACBSCRA  EQU   ACBINFLG                                                 02368000
ACBUJFCB EQU   ACBCOMN+52                                               02369000
ACBBLKSZ EQU   ACBCOMN+60                                               02370000
ACBUAPTR EQU   ACBCOMN+64                                               02371000
AMCBS    EQU   0                                                        02372000
CBSCMP   EQU   AMCBS+16                                                 02373000
CBSCRACA EQU   AMCBS+24                                                 02374000
CBSVSRT  EQU   AMCBS+32                                                 02375000
CI       EQU   0                                                        02376000
TNAM     EQU   0                                                        02377000
IGGCAXWA EQU   0                                                        02378000
CAXFLGS  EQU   IGGCAXWA+8                                               02379000
CAXFLG2  EQU   IGGCAXWA+9                                               02380000
CAXF2REC EQU   CAXFLG2                                                  02381000
CAXFLG3  EQU   IGGCAXWA+10                                              02382000
CAXSCHWA EQU   IGGCAXWA+16                                              02383000
CAXDRWP  EQU   IGGCAXWA+20                                              02384000
CAXACB   EQU   IGGCAXWA+24                                              02385000
CAXCCR   EQU   IGGCAXWA+32                                              02386000
CAXRPL   EQU   IGGCAXWA+48                                              02387000
CAXCNAM  EQU   IGGCAXWA+52                                              02388000
CAXOPLST EQU   IGGCAXWA+96                                              02389000
COPTS    EQU   CAXOPLST                                                 02390000
CAXCCA   EQU   IGGCAXWA+104                                             02391000
CTGFV    EQU   0                                                        02392000
CTGFVPRO EQU   CTGFV+1                                                  02393000
CTGFVSPC EQU   CTGFV+52                                                 02394000
CTGFVAMD EQU   CTGFV+56                                                 02395000
CTGFVLMT EQU   CTGFV+72                                                 02396000
CTGFVGAT EQU   CTGFV+76                                                 02397000
CTGWA    EQU   0                                                        02398000
CTGWAVL  EQU   CTGWA                                                    02399000
CTGVL    EQU   0                                                        02400000
CTGVLX   EQU   0                                                        02401000
CTGCV    EQU   0                                                        02402000
CTGCVDSN EQU   CTGCV+6                                                  02403000
MWA      EQU   0                                                        02404000
VLST     EQU   MWA+2                                                    02405000
CVOLIND  EQU   MWA+252                                                  02406000
IFGRPL   EQU   0                                                        02407000
RPLCOMN  EQU   IFGRPL                                                   02408000
RPLIDWD  EQU   RPLCOMN                                                  02409000
RPLLEN   EQU   RPLIDWD+3                                                02410000
RPLECB   EQU   RPLCOMN+8                                                02411000
RPLFDBWD EQU   RPLCOMN+12                                               02412000
RPLFDBK  EQU   RPLFDBWD+1                                               02413000
RPLRTNCD EQU   RPLFDBK                                                  02414000
RPLCNDCD EQU   RPLFDBK+1                                                02415000
RPLCMPON EQU   RPLCNDCD                                                 02416000
RPLFDB2  EQU   RPLCMPON                                                 02417000
RPLERRCD EQU   RPLCNDCD+1                                               02418000
RPLFDB3  EQU   RPLERRCD                                                 02419000
RPLKEYLE EQU   RPLCOMN+16                                               02420000
RPLAREA  EQU   RPLCOMN+32                                               02421000
RPLARG   EQU   RPLCOMN+36                                               02422000
RPLOPTCD EQU   RPLCOMN+40                                               02423000
RPLOPT1  EQU   RPLOPTCD                                                 02424000
RPLDIR   EQU   RPLOPT1                                                  02425000
RPLSEQ   EQU   RPLOPT1                                                  02426000
RPLKGE   EQU   RPLOPT1                                                  02427000
RPLECBSW EQU   RPLOPT1                                                  02428000
RPLOPT2  EQU   RPLOPTCD+1                                               02429000
RPLKEY   EQU   RPLOPT2                                                  02430000
RPLADR   EQU   RPLOPT2                                                  02431000
RPLCNV   EQU   RPLOPT2                                                  02432000
RPLUPD   EQU   RPLOPT2                                                  02433000
RPLOPT3  EQU   RPLOPTCD+2                                               02434000
RPLNXTRP EQU   RPLCOMN+44                                               02435000
RPLRLEN  EQU   RPLCOMN+48                                               02436000
RPLOPTC2 EQU   RPLCOMN+56                                               02437000
RPLOPT5  EQU   RPLOPTC2                                                 02438000
RPLWRTYP EQU   RPLOPT5                                                  02439000
RPLOPT6  EQU   RPLOPTC2+1                                               02440000
RPLUNTYP EQU   RPLOPT6                                                  02441000
RPLOPT7  EQU   RPLOPTC2+2                                               02442000
RPLCNOPT EQU   RPLOPT7                                                  02443000
RPLOPT8  EQU   RPLOPTC2+3                                               02444000
RPLRBAR  EQU   RPLCOMN+60                                               02445000
RPLAIXID EQU   RPLRBAR+2                                                02446000
RPLEXTDS EQU   RPLCOMN+68                                               02447000
RPLEXTD1 EQU   RPLEXTDS                                                 02448000
CTVOLRCD EQU   1                                                        02449000
CTVOLTIM EQU   CTVOLRCD+44                                              02450000
CTVDVCHR EQU   CTVOLRCD+52                                              02451000
CTVNOTRK EQU   CTVDVCHR+10                                              02452000
CTVDVFLG EQU   CTVDVCHR+17                                              02453000
CTVSPHDR EQU   0                                                        02454000
CTVSPFLG EQU   CTVSPHDR+15                                              02455000
CTVDESGP EQU   0                                                        02456000
CTVEXTST EQU   CTVDESGP+4                                               02457000
CTVSTDES EQU   CTVEXTST                                                 02458000
CTVDSGRP EQU   0                                                        02459000
CTVDSDFL EQU   CTVDSGRP+6                                               02460000
CTVDSDIR EQU   CTVDSGRP+9                                               02461000
CTVGOPT  EQU   0                                                        02462000
CTVGOCI  EQU   CTVGOPT                                                  02463000
CTVGOGCI EQU   CTVGOPT+3                                                02464000
CTVRCTRL EQU   0                                                        02465000
CTVEXRPT EQU   CTVRCTRL                                                 02466000
CTVSPMAP EQU   0                                                        02467000
CTVSMSN  EQU   CTVSPMAP                                                 02468000
CTVDSPAC EQU   0                                                        02469000
CTVDSPSN EQU   CTVDSPAC                                                 02470000
CTVDSPFG EQU   CTVDSPAC+15                                              02471000
CTVSPEXT EQU   CTVDSPAC+21                                              02472000
CTVEXTNT EQU   CTVSPEXT                                                 02473000
CTVDIR   EQU   0                                                        02474000
CTVDSDSN EQU   CTVDIR                                                   02475000
CTVDEXTN EQU   0                                                        02476000
CTVDRSTT EQU   CTVDEXTN+4                                               02477000
IGGMDRWA EQU   0                                                        02478000
DRWDEB   EQU   IGGMDRWA                                                 02479000
DRWECB   EQU   IGGMDRWA+52                                              02480000
DRWECMP  EQU   DRWECB                                                   02481000
DRWIOB   EQU   IGGMDRWA+56                                              02482000
DRWSEEK  EQU   IGGMDRWA+88                                              02483000
DRWCCW   EQU   IGGMDRWA+96                                              02484000
DRWRIA   EQU   IGGMDRWA+204                                             02485000
DSPTBL   EQU   0                                                        02486000
CMSWA    EQU   0                                                        02487000
CMWFLAGS EQU   CMSWA                                                    02488000
CMCISUSE EQU   CMSWA+2                                                  02489000
CMWRKATR EQU   CMCISUSE                                                 02490000
CMCPLFVT EQU   CMSWA+20                                                 02491000
CMNRMEXT EQU   CMSWA+24                                                 02492000
CMLDTFPL EQU   CMNRMEXT                                                 02493000
CMSSEXTS EQU   CMSWA+28                                                 02494000
CMHDTFPL EQU   CMSSEXTS                                                 02495000
CMCANVOL EQU   CMSWA+32                                                 02496000
CMHIXFPL EQU   CMCANVOL                                                 02497000
CMRNGCTR EQU   CMSWA+40                                                 02498000
CMVOLCTR EQU   CMSWA+42                                                 02499000
CMSDFSPC EQU   CMSWA+48                                                 02500000
CMVLLIST EQU   CMSWA+64                                                 02501000
CMVLRTCD EQU   CMVLLIST+2                                               02502000
CMSPCATR EQU   CMSWA+76                                                 02503000
CMWASTOR EQU   CMSWA+132                                                02504000
CMPOT    EQU   CMWASTOR                                                 02505000
CMDCONV  EQU   CMPOT                                                    02506000
CMIXFANO EQU   CMDCONV                                                  02507000
CMPOTX   EQU   CMWASTOR+4                                               02508000
CMPBI    EQU   CMPOTX                                                   02509000
CMIXFANS EQU   CMPBI                                                    02510000
CMWABYTB EQU   CMSWA+140                                                02511000
CMPBIX   EQU   CMWABYTB                                                 02512000
CMNEST   EQU   CMPBIX                                                   02513000
CMFANT   EQU   CMNEST                                                   02514000
CMSPCQTY EQU   CMFANT                                                   02515000
CMWGENAM EQU   CMSWA+144                                                02516000
CMWDATE  EQU   CMWGENAM+12                                              02517000
CMWTIME  EQU   CMWGENAM+17                                              02518000
DCWPLSPS EQU   CMSWA+200                                                02519000
DCWPLSPL EQU   DCWPLSPS                                                 02520000
DCWPLBFS EQU   CMSWA+232                                                02521000
DCWPLBFL EQU   DCWPLBFS                                                 02522000
DCWPLEDS EQU   CMSWA+260                                                02523000
DCWPLEDL EQU   DCWPLEDS                                                 02524000
DCWPLARS EQU   CMSWA+288                                                02525000
DCWPLARL EQU   DCWPLARS                                                 02526000
DCWPLCDS EQU   CMSWA+316                                                02527000
DCWPLCDL EQU   DCWPLCDS                                                 02528000
CMUCATCI EQU   CMSWA+410                                                02529000
CMSCTREC EQU   CMSWA+416                                                02530000
CUMPLWA  EQU   0                                                        02531000
CUMPL    EQU   CUMPLWA                                                  02532000
CUMIN    EQU   CUMPL                                                    02533000
CUMOUT   EQU   CUMPL+1                                                  02534000
CUMWA    EQU   CUMPLWA+8                                                02535000
CUMFLAG  EQU   CUMWA                                                    02536000
CUMWASS2 EQU   CUMWA+48                                                 02537000
CUMWASS  EQU   CUMWASS2+2                                               02538000
CUMWTYP  EQU   CUMWASS                                                  02539000
ACC      EQU   0                                                        02540000
ACCTRANT EQU   ACC                                                      02541000
ACCDSNCI EQU   ACC+5                                                    02542000
ACCVOLTT EQU   ACC+8                                                    02543000
CTT      EQU   0                                                        02544000
CTTENTNO EQU   CTT                                                      02545000
CTTENTRY EQU   CTT+4                                                    02546000
CTTCATCI EQU   CTTENTRY+1                                               02547000
VTT      EQU   0                                                        02548000
VTTENTNO EQU   VTT                                                      02549000
VTTENTRY EQU   VTT+4                                                    02550000
VTTVOLSR EQU   VTTENTRY                                                 02551000
VTTTMSTP EQU   VTTENTRY+6                                               02552000
CTENTREC EQU   0                                                        02553000
@NM00129 EQU   CTENTREC                                                 02554000
RCDKCI   EQU   @NM00129                                                 02555000
RCDNAME  EQU   CTENTREC+49                                              02556000
ARA      EQU   0                                                        02557000
ARASGA   EQU   ARA                                                      02558000
ARAKEY   EQU   ARASGA                                                   02559000
ARATNCI  EQU   ARASGA+44                                                02560000
BUFHDR   EQU   0                                                        02561000
BUFRECRD EQU   BUFHDR                                                   02562000
BUFNEXTB EQU   BUFHDR+508                                               02563000
DCRACIPT EQU   0                                                        02564000
EXTFLD   EQU   0                                                        02565000
LEN      EQU   EXTFLD                                                   02566000
GCRVFL   EQU   0                                                        02567000
SUMTTWKA EQU   0                                                        02568000
WORK     EQU   0                                                        02569000
ENTRYNAM EQU   0                                                        02570000
TORECAR  EQU   0                                                        02571000
CBRECAR  EQU   0                                                        02572000
CATSN    EQU   0                                                        02573000
CTGVLDSP EQU   0                                                        02574000
FIELDNM  EQU   0                                                        02575000
@NM00036 EQU   CTGDDNM                                                  02576000
CTGPROB  EQU   @NM00036                                                 02577000
CTGREASN EQU   CTGPROB+2                                                02578000
CVTS01   EQU   CVTPGSIA                                                 02579000
CVTLPDIA EQU   CVTS01+12                                                02580000
CVTDIRST EQU   CVTLPDIA                                                 02581000
CVTSLIDA EQU   CVTS01+24                                                02582000
CVTCTLFG EQU   CVTS01+50                                                02583000
CVTRV210 EQU   CVTS01+424                                               02584000
CVTRV219 EQU   CVTS01+425                                               02585000
CVTRV228 EQU   CVTS01+426                                               02586000
CVTRV237 EQU   CVTS01+427                                               02587000
CVTMFRTR EQU   CVTS01+452                                               02588000
CVTRV262 EQU   CVTS01+468                                               02589000
CVTRV271 EQU   CVTS01+469                                               02590000
CVTRV280 EQU   CVTS01+470                                               02591000
CVTRV289 EQU   CVTS01+471                                               02592000
CVTGSDA  EQU   CVTS01+600                                               02593000
PSARSVTE EQU   PSARSVT                                                  02594000
MCATDSTR EQU   CVTAMFF                                                  02595000
CVTAMF1  EQU   MCATDSTR                                                 02596000
XIOOPT   EQU   CCARPLX                                                  02597000
XIOGET   EQU   XIOOPT                                                   02598000
XIOERS   EQU   XIOOPT                                                   02599000
XIOARA   EQU   XIOOPT                                                   02600000
XIOKEY   EQU   XIOOPT                                                   02601000
XIONUP   EQU   XIOOPT                                                   02602000
XIONCK   EQU   XIOOPT                                                   02603000
XIOTNE   EQU   XIOOPT                                                   02604000
XIOKGE   EQU   XIOOPT                                                   02605000
XIOSEQ   EQU   XIOKGE                                                   02606000
CCADDDD  EQU   CCASRCH                                                  02607000
LPINDX   EQU   CCARPLX                                                  02608000
LPSTOP   EQU   CCARPLT                                                  02609000
ONCE     EQU   CCARPLT                                                  02610000
DRWR     EQU   DRWSEEK+7                                                02611000
VOLTMSTP EQU   WKA                                                      02612000
DRWDCB   EQU   DRWDEB+4                                                 02613000
FLC      EQU   PSA                                                      02614000
CCACRRP  EQU   IGGCCA+269                                               04363000
@ENDDATA EQU   *                                                        04736000
         END   IGG0CLBI                                         DSKL014 04737000
