         TITLE 'IKJEFF02 - TSO MESSAGE ISSUER SERVICE ROUTINE          *00001000
                        '                                               00002000
IKJEFF02 CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSKC193 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'IKJEFF02  85.284'                              DSKC193 00008000
         DROP  R15                                              DSKC193 00009000
@PROLOG  STM   R14,R12,12(R13)                                  DSKC193 00010000
         BALR  R11,0                                            DSKC193 00011000
@PSTART  LA    R12,4095(,R11)                                   DSKC193 00012000
         USING @PSTART,R11                                      DSKC193 00013000
         USING @PSTART+4095,R12                                 DSKC193 00014000
         L     R0,@SIZDATD                                      DSKC193 00015000
         GETMAIN  R,LV=(0)                                              00016000
         LR    R10,R1                                           DSKC193 00017000
         USING @DATD,R10                                        DSKC193 00018000
         ST    R13,@SA00001+4                                   DSKC193 00019000
         LM    R0,R1,20(R13)                                    DSKC193 00020000
         ST    R10,8(,R13)                                      DSKC193 00021000
         LR    R13,R10                                          DSKC193 00022000
         MVC   @PC00001(12),0(R1)                               DSKC193 00024000
DUMYLBL1 DS    0H                                                  0003 00025000
*                                                                  0116 00026000
*   /*****************************************************************/ 00027000
*   /*                                                               */ 00028000
*   /* INITIALIZE AND CHECK FOR PARAMETER LIST ERRORS                */ 00029000
*   /*                                                               */ 00030000
*   /*****************************************************************/ 00031000
*                                                                  0116 00032000
*   ERRORSWS=''X;                   /* ZERO OUT ERROR SWITCH AREA    */ 00033000
         XC    ERRORSWS(2),ERRORSWS                                0116 00034000
*   INTSWS=''X;                     /* TURN OFF SWITCHES USED IN   0117 00035000
*                                      INTERNAL PROCESSING           */ 00036000
         SLR   R8,R8                                            DSKC193 00037000
         STH   R8,INTSWS                                        DSKC193 00038000
*   RETCODE=0;                      /* INITIALIZE TO GOOD RETURN CODE   00039000
*                                      FROM IKJEFF02                 */ 00040000
         SLR   R8,R8                                            DSKC193 00041000
         ST    R8,RETCODE                                       DSKC193 00042000
*   PARMPTR1=ADDR(PARM1);           /* SET POINTER TO THE FIRST OF 0119 00043000
*                                      THE INPUT PARAMETERS          */ 00044000
         L     R9,@PC00001                                      DSKC193 00045000
*   RFY                                                            0120 00046000
*     REG1 RSTD;                                                   0120 00047000
*   IF REG1=0×PARMPTR1=0 THEN       /* NEED TO ISSUE ERROR MESSAGE IF   00048000
*                                      BAD PARAMETER LIST POINTER    */ 00049000
         CR    R1,R8                                            DSKC193 00050000
         BE    @RT00121                                            0121 00051000
         CR    R9,R8                                            DSKC193 00052000
         BNE   @RF00121                                            0121 00053000
@RT00121 DS    0H                                                  0122 00054000
*     DO;                                                          0122 00055000
*       PTRPLER=ON;                                                0123 00056000
         OI    PTRPLER,B'10000000'                                 0123 00057000
*       CALL EMSGPROC;              /* ISSUE ERROR MESSAGE           */ 00058000
         BAL   R14,EMSGPROC                                     DSKC193 00059000
*       GO TO ERRRET;               /* TAKE ERROR EXIT               */ 00060000
         B     ERRRET                                              0125 00061000
*     END;                                                         0126 00062000
*   RFY                                                            0127 00063000
*     REG1 UNRSTD;                                                 0127 00064000
@RF00121 DS    0H                                                  0128 00065000
*   LOOPCT=0;                       /* COUNT OF MESSAGES CHAINED,  0128 00066000
*                                      MAX=20 TO PREVENT INFINITE  0128 00067000
*                                      LOOPS                         */ 00068000
         SLR   R6,R6                                            DSKC193 00069000
         ST    R6,LOOPCT                                        DSKC193 00070000
*   OUTADDR='FF000000'X;            /* INIT POINTER TO 2ND LEVEL MSG    00071000
*                                      (PUTLINE USED THIS VALUE)     */ 00072000
         MVC   OUTADDR(4),@CF00519                                 0129 00073000
*   PRETXTP=PRETXTP&'FF000000'X;    /* INITIALIZE THE POINTER TO THE    00074000
*                                      RETURNED MESSAGE TO ZERO, BUT    00075000
*                                      PRESERVE THE HIGH ORDER BYTE     00076000
*                                      CONTAINING THE SWITCHES       */ 00077000
         NC    PRETXTP(4,R9),@CB00519                           DSKC193 00078000
*   VARLISTP=ADDR(PINSRTS);         /* VARIABLE LIST POINTER TO POINT   00079000
*                                      TO FIRST VARIABLE      @Y02668*/ 00080000
         LA    R7,PINSRTS(,R9)                                  DSKC193 00081000
*   TMSGID=PMSGID;                  /* SET SEARCH ARGUMENT FOR     0132 00082000
*                                      MESSAGE SEARCH ROUTINE FROM 0132 00083000
*                                      PARAMETER LIST                */ 00084000
         MVC   TMSGID(4),PMSGID(R9)                             DSKC193 00085000
*   PPARMP=ADDR(SAVEPAR);           /* FOR LIST FORM OF MACRO      0133 00086000
*                                                            @Z40NQKJ*/ 00087000
         LA    R8,SAVEPAR                                       DSKC193 00088000
         ST    R8,PPARMP                                        DSKC193 00089000
*   IF PEXTRLEN^=0 THEN             /* SEE IF EXTRACT WANTED @Z40NQKJ*/ 00090000
         CLI   PEXTRLEN(R9),0                                   DSKC193 00091000
         BE    @RF00134                                            0134 00092000
*     DO;                                                          0135 00093000
*       SWEXTRCT='1'B;              /* IF EXTRACT BUFFER LENGTH GIVEN   00094000
*                                      THEN TURN EXTRACT SW ON     0136 00095000
*                                                            @Z40NQKJ*/ 00096000
         OI    SWEXTRCT,B'00001000'                                0136 00097000
*       IF PEXTRBUF=0 THEN                                         0137 00098000
*                                                                  0137 00099000
         SLR   R6,R6                                            DSKC193 00100000
         ICM   R6,7,PEXTRBUF(R9)                                DSKC193 00101000
         LTR   R6,R6                                            DSKC193 00102000
         BNZ   @RF00137                                            0137 00103000
*         /***********************************************************/ 00104000
*         /*                                                         */ 00105000
*         /* LENGTH GIVEN BUT NO BUFFER CONSTITUTES A FATAL FLAW     */ 00106000
*         /*                                                 @Z40NQKJ*/ 00107000
*         /*                                                         */ 00108000
*         /***********************************************************/ 00109000
*                                                                  0138 00110000
*         DO;                                                      0138 00111000
*           EXTRCTER=ON;            /* SET FIRST BUFFER      @Z40GQKU   00112000
*                                      MISSING ERROR CODE    @Z40GQKU*/ 00113000
         OI    EXTRCTER,B'10000000'                                0139 00114000
*           GO TO RETLABEL;                                        0140 00115000
         B     RETLABEL                                            0140 00116000
*         END;                                                     0141 00117000
*       IF PEXTRLN2^=0 THEN         /* SEE IF SECOND LEVEL   @Z40GQKU*/ 00118000
@RF00137 CLI   PEXTRLN2(R9),0                                   DSKC193 00119000
         BE    @RC00134                                         DSKC193 00120000
*         DO;                       /* MSG EXTRACT WANTED.   @Z40GQKU*/ 00121000
*           SWEXTRC2='1'B;          /* IF SO SET SWITCH TO   @Z40GQKU*/ 00122000
         OI    SWEXTRC2,B'00000100'                                0144 00123000
*           IF PEXTRBF2=0 THEN      /* YES. CHECK FOR BFR    @Z40GQKU*/ 00124000
         SLR   R8,R8                                            DSKC193 00125000
         ICM   R8,7,PEXTRBF2(R9)                                DSKC193 00126000
         LTR   R8,R8                                            DSKC193 00127000
         BNZ   @RC00134                                         DSKC193 00128000
*             DO;                   /* ADDRESS. IF NO BUFFER @Z40GQKU*/ 00129000
*               EXTRCTR2=ON;        /* SET SECOND BUFFER     @Z40GQKU   00130000
*                                      MISSING ERROR CODE,   @Z40GQKU*/ 00131000
         OI    EXTRCTR2,B'01000000'                                0147 00132000
*               GO TO RETLABEL;     /* SAY ERROR AND GO GET  @Z40GQKU*/ 00133000
         B     RETLABEL                                            0148 00134000
*             END;                  /* READY TO PUT OUT ERROR@Z40GQKU*/ 00135000
*         END;                      /* MSG, CLEANUP AND EXIT.@Z40GQKU*/ 00136000
*     END;                          /*                       @Z40GQKU*/ 00137000
*   ELSE                            /* CHECK IF ONLY SECOND  @Z40GQKU   00138000
*                                      EXTRACT REQUESTED     @Z40GQKU*/ 00139000
*     IF PEXTRLN2^=0 THEN           /* IF SECOND LEVEL       @Z40GQKU   00140000
*                                      ONLY REQUESTED, ERROR @Z40GQKU*/ 00141000
         B     @RC00134                                            0152 00142000
@RF00134 CLI   PEXTRLN2(R9),0                                   DSKC193 00143000
         BE    @RF00152                                            0152 00144000
*       DO;                         /*                       @Z40GQKU*/ 00145000
*         EXTRCTR3=ON;              /* SET REQUESTED ONLY    @Z40GQKU   00146000
*                                      SECOND LEVEL EXTRACT, @Z40GQKU*/ 00147000
         OI    EXTRCTR3,B'00100000'                                0154 00148000
*         GO TO RETLABEL;           /* THEN GO TO EXIT       @Z40GQKU*/ 00149000
         B     RETLABEL                                            0155 00150000
*       END;                        /*                       @Z40GQKU*/ 00151000
*   IF PWTPSW=OFF&PWTOSW=OFF THEN   /* SPECIAL INITIALIZATION FOR TSO   00152000
*                                      PUTGET, PUTLINE MESSAGES      */ 00153000
@RF00152 DS    0H                                                  0157 00154000
@RC00134 TM    PWTPSW(R9),B'00100010'                           DSKC193 00155000
         BNZ   @RF00157                                            0157 00156000
*     DO;                                                          0158 00157000
*       IF ADDR(COMECB)=0 THEN      /* SUPPLY ECB IF CALLER NEEDS ONE*/ 00158000
         SLR   R6,R6                                            DSKC193 00159000
         L     R8,@PC00001+8                                    DSKC193 00160000
         CR    R8,R6                                            DSKC193 00161000
         BNE   @RF00159                                            0159 00162000
*         DO;                                                      0160 00163000
*           LOCALECB=0;                                            0161 00164000
         ST    R6,LOCALECB                                      DSKC193 00165000
*           PECBP=ADDR(LOCALECB);                                  0162 00166000
         LA    R6,LOCALECB                                      DSKC193 00167000
         ST    R6,PECBP                                         DSKC193 00168000
*         END;                                                     0163 00169000
*       ELSE                        /* ELSE USE CALLER'S ECB         */ 00170000
*         PECBP=ADDR(COMECB);                                      0164 00171000
         B     @RC00159                                            0164 00172000
@RF00159 L     R8,@PC00001+8                                    DSKC193 00173000
         ST    R8,PECBP                                         DSKC193 00174000
*       CPPLPTR=ADDR(TMCT);         /* CPPL ADDRESS IS AN INPUT    0165 00175000
*                                      PARAMETER                     */ 00176000
@RC00159 L     R2,@PC00001+4                                    DSKC193 00177000
*       IF CPPLPTR=0 THEN           /* WILL ISSUE ERROR MESSAGE IF 0166 00178000
*                                      HAVE ZERO CPPL POINTER        */ 00179000
         LTR   R2,R2                                            DSKC193 00180000
         BNZ   @RF00166                                            0166 00181000
*         IF^(SWEXTRCT='1'B&PEXTRCON='0'B) THEN/* UNLESS DOING     0167 00182000
*                                      EXTRACT WITH NO CONTINUE    0167 00183000
*                                                            @Z40NQKJ*/ 00184000
         TM    SWEXTRCT,B'00001000'                                0167 00185000
         BNO   @RT00167                                            0167 00186000
         TM    PEXTRCON(R9),B'00000100'                         DSKC193 00187000
         BZ    @RF00167                                            0167 00188000
@RT00167 DS    0H                                                  0168 00189000
*           DO;                                                    0168 00190000
*             PCPPLER=ON;           /* REMEMBER TO ISSUE ERROR     0169 00191000
*                                      MESSAGE BEFORE RETURN TO    0169 00192000
*                                      CALLER                        */ 00193000
*             WTPOVERR=ON;          /* ISSUE MESSAGES AS WTP - CAN'T    00194000
*                                      ISSUE AS PUTGET OR PUTLINE    */ 00195000
         OI    PCPPLER,B'00100001'                                 0170 00196000
*           END;                                                   0171 00197000
*         ELSE                                                     0172 00198000
*           ;                                                      0172 00199000
@RF00167 DS    0H                                                  0173 00200000
*       ELSE                        /* IF NO ERROR                   */ 00201000
*         DO;                                                      0173 00202000
         B     @RC00166                                            0173 00203000
@RF00166 DS    0H                                                  0174 00204000
*           PUPTP=CPPLUPT;          /* POINT TO TSO CONTROL BLOCKS   */ 00205000
         L     R6,CPPLUPT(,R2)                                  DSKC193 00206000
         ST    R6,PUPTP                                         DSKC193 00207000
*           PECTP=CPPLECT;                                         0175 00208000
         L     R3,CPPLECT(,R2)                                  DSKC193 00209000
         ST    R3,PECTP                                         DSKC193 00210000
*         END;                                                     0176 00211000
*     END;                          /* END OF PUTGET/PUTLINE SET UP  */ 00212000
@RC00166 DS    0H                                                  0178 00213000
*   IF PCSECTP=0 THEN               /* ISSUE ERROR MESSAGE IF HAVE 0178 00214000
*                                      ZERO POINTER TO CALLER'S    0178 00215000
*                                      MESSAGE CSECT                 */ 00216000
@RF00157 L     R6,PCSECTP(,R9)                                  DSKC193 00217000
         LTR   R6,R6                                            DSKC193 00218000
         BNZ   @RF00178                                            0178 00219000
*     DO;                                                          0179 00220000
*       MCPLER=ON;                                                 0180 00221000
         OI    MCPLER,B'01000000'                                  0180 00222000
*       CALL EMSGPROC;              /* GO ISSUE ERROR MESSAGE        */ 00223000
         BAL   R14,EMSGPROC                                     DSKC193 00224000
*       GO TO ERRRET;               /* TERMINATE BECAUSE OF ERROR    */ 00225000
         B     ERRRET                                              0182 00226000
*     END;                                                         0183 00227000
*                                                                  0184 00228000
*   /*****************************************************************/ 00229000
*   /*                                                               */ 00230000
*   /* BUILD A MESSAGE IN BUFFER (NOTE--PUTLINE SECOND LEVEL MESSAGE */ 00231000
*   /* AND STACKED PUTGET LEVEL MESSAGES ARE ALSO BUILT BY MSGSRCH)  */ 00232000
*   /*                                                               */ 00233000
*   /*****************************************************************/ 00234000
*                                                                  0184 00235000
*MSGSRCH:                                                          0184 00236000
*   MSGAD=PCSECTP;                  /* 'MSGID' AND 'PCSECTP' ARE USED   00237000
*                                      AS INPUT PARAMETERS POINT TO     00238000
*                                      FIRST MESSAGE IN THE MESSAGE     00239000
*                                      CSECT                         */ 00240000
@RF00178 DS    0H                                                  0184 00241000
MSGSRCH  L     R4,PCSECTP(,R9)                                  DSKC193 00242000
*   BLDLEN=LENGTH(BLDHDR);          /* INITIALIZE LENGTH OF BUILD  0185 00243000
*                                      BUFFER                        */ 00244000
         LA    R5,4                                             DSKC193 00245000
         STH   R5,BLDLEN                                        DSKC193 00246000
*   LSTLEN=BLDLEN;                  /* INITIALIZE LENGTH OF BUILD  0186 00247000
*                                      BUFFER FOR COMPUTATIONS       */ 00248000
         LR    R6,R5                                            DSKC193 00249000
*   BLDOFF=0;                       /* SET OFFSET FIELD OF BUILD   0187 00250000
*                                      BUFFER                        */ 00251000
         SLR   R8,R8                                            DSKC193 00252000
         STH   R8,BLDOFF                                        DSKC193 00253000
*   NBPART=0;                       /* SET NUMBER OF PARTS TO ZERO 0188 00254000
*                                      FOR STARTERS                  */ 00255000
*                                                                  0188 00256000
         STCM  R8,15,NBPART                                     DSKC193 00257000
*   /*****************************************************************/ 00260000
*   /*                                                               */ 00261000
*   /* LOOP THRU MESSAGE CSECT, SEARCHING FOR MATCH WITH MESSAGE ID  */ 00262000
*   /*                                                               */ 00263000
*   /*****************************************************************/ 00264000
*                                                                  0189 00265000
*IDSEARCH:                                                         0189 00266000
*   IF CMSGID='    ' THEN           /* IF AT END OF CSECT FOR      0189 00267000
*                                      MESSAGES WITHOUT FINDING ID 0189 00268000
*                                      WANTED                        */ 00269000
IDSEARCH CLC   CMSGID(4,R4),@CC00525                            DSKC193 00270000
         BNE   @RF00189                                            0189 00271000
*     DO;                                                          0190 00272000
*       MIDPLER=ON;                                                0191 00273000
         OI    MIDPLER,B'00010000'                                 0191 00274000
*       CALL EMSGPROC;              /* GO ISSUE ERROR MESSAGE        */ 00275000
         BAL   R14,EMSGPROC                                     DSKC193 00276000
*       GO TO ERRRET;               /* AND TAKE ERROR EXIT           */ 00277000
         B     ERRRET                                              0193 00278000
*     END;                                                         0194 00279000
*   IF CMSGID^=TMSGID THEN          /* IF MESSAGE IDS NOT THE SAME   */ 00280000
@RF00189 CLC   CMSGID(4,R4),TMSGID                              DSKC193 00281000
         BE    @RF00195                                            0195 00282000
*     DO;                                                          0196 00283000
*       MSGAD=MSGAD+CMSGLEN;        /* INCREMENT TO NEXT MESSAGE     */ 00284000
         SLR   R5,R5                                            DSKC193 00285000
         ICM   R5,3,CMSGLEN(R4)                                 DSKC193 00285010
         ALR   R4,R5                                            DSKC193 00286000
*       GOTO IDSEARCH;              /* CONTINUE SEARCH               */ 00287000
         B     IDSEARCH                                            0198 00288000
*     END;                                                         0199 00289000
*                                                                  0199 00290000
*   /*****************************************************************/ 00291000
*   /*                                                               */ 00292000
*   /* CHECK FOR PUTGET MESSAGE LEVEL LIMIT                          */ 00293000
*   /*                                                               */ 00294000
*   /*****************************************************************/ 00295000
*                                                                  0200 00296000
*   LOOPCT=LOOPCT+1;                /* INCREASE COUNT OF NUMBER OF 0200 00297000
*                                      MESSAGES                      */ 00298000
@RF00195 LA    R8,1                                             DSKC193 00299000
         AL    R8,LOOPCT                                        DSKC193 00300000
         ST    R8,LOOPCT                                        DSKC193 00301000
*   IF LOOPCT>20 THEN                                              0201 00302000
         C     R8,@CF00527                                      DSKC193 00303000
         BNH   @RF00201                                            0201 00304000
*     DO;                           /* IF THE COUNT OF MESSAGES IS 0202 00305000
*                                      NOW GREATER THAN 20, THEN PUT    00306000
*                                      OUT WHAT WE HAVE AND QUIT     */ 00307000
*       IF PREVERSW='1'B THEN                                      0203 00308000
         TM    PREVERSW(R9),B'01000000'                         DSKC193 00309000
         BO    PUT2LINE                                         DSKC193 00310000
*         GO TO PUT2LINE;           /* GO TO PUTLINE IF REVERSE IS 0204 00311000
*                                      ON, OTHERWISE GO TO PUTGET    */ 00312000
*       GO TO PTGTMSG;                                             0205 00313000
         B     PTGTMSG                                             0205 00314000
*     END;                                                         0206 00315000
*   CSECTP=MSGAD+11;                /* INITIALIZE POINTER USED TO  0207 00316000
*                                      SCAN MESSAG MACRO EXPANSIONS.    00317000
*                                      NOTE: ADDING 11 MAKES THIS  0207 00318000
*                                      POINTER POINT TO THE FIRST  0207 00319000
*                                      PART LENGTH FIELD -- IT WILL     00320000
*                                      BE ZERO IF A VARIABLE GOES IN    00321000
*                                      THIS POSITION                 */ 00322000
@RF00201 LA    R5,11                                            DSKC193 00323000
         ALR   R5,R4                                            DSKC193 00324000
*                                                                  0208 00325000
*   /*****************************************************************/ 00326000
*   /*                                                               */ 00327000
*   /* LOOP TO MOVE FIXED AND VARIABLE (INSERTED) PARTS OF THIS      */ 00328000
*   /* MESSAGE INTO MESSAGE BUILD AREA                               */ 00329000
*   /*                                                               */ 00330000
*   /*****************************************************************/ 00331000
*                                                                  0208 00332000
*BLDLOOP:                                                          0208 00333000
*   IF CPARTLEN^='00'X THEN         /* IF THE PART LENGTH FIELD IS 0208 00334000
*                                      NON-ZERO IT INDICATES A     0208 00335000
*                                      MESSAGE SEGMENT FOLLOWS       */ 00336000
BLDLOOP  CLI   CPARTLEN(R5),X'00'                               DSKC193 00337000
         BNE   SEGMOVE                                          DSKC193 00338000
*     GOTO SEGMOVE;                 /* GO TO MOVE THE SEGMENT INTO 0209 00339000
*                                      THE BUILD BUFFER OTHERWISE A     00340000
*                                      VARIABLE IS TO BE INSERTED    */ 00341000
*VARLOOP:                                                          0210 00342000
*   LLENGTH=PLENGTH;                /* LOCAL COPY OF INSERT LENGTH 0210 00343000
*                                                             @Y02668*/ 00344000
VARLOOP  IC    R3,PLENGTH(,R7)                                  DSKC193 00345000
         STC   R3,LLENGTH                                       DSKC193 00346000
*   LVARPTR=PVARPTR;                /* USE LOCAL COPY OF PTR TO THE     00347000
*                                      INSERT VARIABLE        @Y02668*/ 00348000
         SLR   R2,R2                                            DSKC193 00349000
         ICM   R2,7,PVARPTR(R7)                                 DSKC193 00350000
*   IF LLENGTH=0×LVARPTR=0×LLENGTH='80'X THEN/* IF HAVE NO INSERT    */ 00351000
         CLI   LLENGTH,0                                           0212 00352000
         BE    SKIPUP                                           DSKC193 00353000
         SLR   R3,R3                                            DSKC193 00354000
         CR    R2,R3                                            DSKC193 00355000
         BE    SKIPUP                                           DSKC193 00356000
         CLI   LLENGTH,128                                         0212 00357000
         BE    SKIPUP                                           DSKC193 00358000
*     GO TO SKIPUP;                 /* GO BUILD NEXT PART OF MESSAGE */ 00359000
*                                                                  0213 00360000
*   /*****************************************************************/ 00361000
*   /*                                                               */ 00362000
*   /* CHECK WHETHER CONVERT HEX INSERT TO PRINTABLE                 */ 00363000
*   /*                                                               */ 00364000
*   /*****************************************************************/ 00365000
*                                                                  0214 00366000
*   IF PCONVRT='1'B THEN            /* HEX CONVERSION INDICATED      */ 00367000
         TM    PCONVRT(R7),B'10000000'                          DSKC193 00368000
         BNO   @RF00214                                            0214 00369000
*     DO;                                                          0215 00370000
*       LCONVRT='0'B;               /* TURN OFF THIS BIT BEFORE USE     00371000
*                                      LLENGTH                       */ 00372000
*                                                                  0216 00373000
         NI    LCONVRT,B'01111111'                                 0216 00374000
*       /*************************************************************/ 00375000
*       /*                                                           */ 00376000
*       /* COPY THE ONE-TO-FOUR BYTE CODE INTO A WORK AREA           */ 00377000
*       /*                                                           */ 00378000
*       /*************************************************************/ 00379000
*                                                                  0217 00380000
*       SAVCODE=0;                  /* ZERO ENTIRE AREA              */ 00381000
         ST    R3,SAVCODE                                       DSKC193 00382000
*       IF LLENGTH=1 THEN           /* COPY ONE-BYTE CODE            */ 00383000
         CLI   LLENGTH,1                                           0218 00384000
         BNE   @RF00218                                            0218 00385000
*         SAVCODE1=VARIABLE(1:1);                                  0219 00386000
         MVC   SAVCODE1(1),VARIABLE(R2)                         DSKC193 00387000
*       ELSE                        /* NOT ONE-BYTE                  */ 00388000
*         IF LLENGTH=2 THEN         /* COPY TWO-BYTE CODE            */ 00389000
         B     @RC00218                                            0220 00390000
@RF00218 CLI   LLENGTH,2                                           0220 00391000
         BNE   @RF00220                                            0220 00392000
*           SAVCODE2=VARIABLE(1:2);                                0221 00393000
         MVC   SAVCODE2(2),VARIABLE(R2)                         DSKC193 00394000
*         ELSE                      /* NOT ONE OR TWO BYTE           */ 00395000
*           IF LLENGTH=3 THEN       /* COPY THREE-BYTE CODE          */ 00396000
         B     @RC00220                                            0222 00397000
@RF00220 CLI   LLENGTH,3                                           0222 00398000
         BNE   @RF00222                                            0222 00399000
*             SAVCODE3=VARIABLE(1:3);                              0223 00400000
         MVC   SAVCODE3(3),VARIABLE(R2)                         DSKC193 00401000
*           ELSE                    /* DEFAULT IS FOUR-BYTE          */ 00402000
*             SAVCODE=VARIABLE(1:4);                               0224 00403000
         B     @RC00222                                            0224 00404000
@RF00222 MVC   SAVCODE(4),VARIABLE(R2)                          DSKC193 00405000
*       UNPK=UNPK&&UNPK;            /* ZERO THE WORK AREA            */ 00406000
@RC00222 DS    0H                                                  0225 00407000
@RC00220 DS    0H                                                  0225 00408000
@RC00218 XC    UNPK(16),UNPK                                       0225 00409000
*                                                                  0226 00410000
*       /*************************************************************/ 00411000
*       /*                                                           */ 00412000
*       /* CONVERT TO PRINTABLE HEX, IF NEEDED                       */ 00413000
*       /*                                                           */ 00414000
*       /*************************************************************/ 00415000
*                                                                  0226 00416000
*       IF PHEXSW=ON×(PNHEXSW=OFF&HEXCODE>'FFFF'X) THEN/* HEXCODE IS    00417000
*                                      SAME AS SAVCODE               */ 00418000
         TM    PHEXSW(R9),B'00010000'                           DSKC193 00419000
         BO    @RT00226                                            0226 00420000
         TM    PNHEXSW(R9),B'00000001'                          DSKC193 00421000
         BNZ   @RF00226                                            0226 00422000
         CLC   SAVCODE(4),@CF00538                              DSKC193 00423000
         BNH   @RF00226                                            0226 00424000
@RT00226 DS    0H                                                  0227 00425000
*         DO;                                                      0227 00426000
*           SWHAVHEX=ON;            /* REMEMBER HEX CONVERSION, FOR     00427000
*                                      LATER USE                     */ 00428000
         OI    SWHAVHEX,B'00010000'                                0228 00429000
*           RESPECIFY                                              0229 00430000
*            (REG8) RESTRICTED;     /* FOR CONVERSIONS ONLY          */ 00431000
*           GENERATE;                                              0230 00432000
         UNPK  UNPK(9),SAVCODE(5)     UNPACK THE INSERT CODE            00433000
         TR    UNPK(8),ALPHA-240                                        00434000
*           LVARPTR=ADDR(UNPK)+4;   /* RESET THE VARIABLE POINTER  0231 00435000
*                                      (USE LOCAL POINTER)    @Y02668*/ 00436000
         LA    R2,UNPK                                          DSKC193 00437000
         AL    R2,@CF00225                                      DSKC193 00438000
*         END;                                                     0232 00439000
*                                                                  0232 00440000
*       /*************************************************************/ 00441000
*       /*                                                           */ 00442000
*       /* OTHERWISE CONVERT TO PRINTABLE DECIMAL                    */ 00443000
*       /*                                                           */ 00444000
*       /*************************************************************/ 00445000
*                                                                  0233 00446000
*       ELSE                        /* CONVERSION TO DECIMAL         */ 00447000
*         DO;                                                      0233 00448000
         B     @RC00226                                            0233 00449000
@RF00226 DS    0H                                                  0234 00450000
*           REG8=SAVCODE;           /* PUT RETURN CODE IN REGISTER   */ 00451000
         L     R8,SAVCODE                                       DSKC193 00452000
*           GENERATE;                                              0235 00453000
         CVD   R8,UNPK                                          DSKC193 00454000
         UNPK  UNPK(15),UNPK(8)                                         00455000
         OI    UNPK+14,C'0'                                             00456000
*           LVARPTR=ADDR(UNPK)+11;  /* RESET THE VARIABLE POINTER  0236 00457000
*                                      (USE LOCAL POINTER)    @Y02668*/ 00458000
         LA    R2,UNPK                                          DSKC193 00459000
         AL    R2,@CF00036                                      DSKC193 00460000
*         END;                                                     0237 00461000
*                                                                  0237 00462000
*       /*************************************************************/ 00463000
*       /*                                                           */ 00464000
*       /* COMMON CONVERSION CODE                                    */ 00465000
*       /*                                                           */ 00466000
*       /*************************************************************/ 00467000
*                                                                  0238 00468000
*       TEMP=2*LLENGTH;             /* SAVE HEX EXPECTED LENGTH, FOR    00469000
*                                      USE IN LOOP TO TRUNCATE     0238 00470000
*                                      LEADING ZEROS                 */ 00471000
@RC00226 SLR   R3,R3                                            DSKC193 00472000
         IC    R3,LLENGTH                                       DSKC193 00473000
         ALR   R3,R3                                            DSKC193 00474000
         ST    R3,TEMP                                          DSKC193 00475000
*       IF SWHAVHEX=ON THEN         /* IF CONVERTING TO PRINTABLE HEX*/ 00476000
         TM    SWHAVHEX,B'00010000'                                0239 00477000
         BNO   @RF00239                                            0239 00478000
*         DO;                                                      0240 00479000
*           LVARPTR=ADDR(UNPK);     /* BACK UP POINTER               */ 00480000
         LA    R2,UNPK                                          DSKC193 00481000
*           LLENGTH='08'X;          /* SET MAXIMUM LENGTH OF VARIABLE*/ 00482000
         MVI   LLENGTH,X'08'                                       0242 00483000
*         END;                                                     0243 00484000
*       ELSE                        /* FOR PRINTABLE DECIMAL         */ 00485000
*         LLENGTH='04'X;            /* RESET LENGTH OF VARIABLE    0244 00486000
*                                                             @Y02668*/ 00487000
         B     @RC00239                                            0244 00488000
@RF00239 MVI   LLENGTH,X'04'                                       0244 00489000
*       DO REG8=1 TO 11;            /* IF PUTTING OUT ONLY 4       0245 00490000
*                                      CHARACTERS WOULD CUT OFF NON     00491000
*                                      ZERO DIGITS THEN PUT THE    0245 00492000
*                                      DIGITS                        */ 00493000
@RC00239 LA    R8,1                                             DSKC193 00494000
@DL00245 DS    0H                                                  0246 00495000
*         IF UNPK(REG8)^='F0'X THEN /* NON ZERO DIGIT                */ 00496000
         LA    R3,UNPK-1(R8)                                    DSKC193 00497000
         CLI   0(R3),X'F0'                                      DSKC193 00498000
         BE    @RF00246                                            0246 00499000
*           DO;                                                    0247 00500000
*             IF SWHAVHEX='0'B THEN /* DECIMAL NUMBER                */ 00501000
         TM    SWHAVHEX,B'00010000'                                0248 00502000
         BNZ   @RF00248                                            0248 00503000
*               DO;                                                0249 00504000
*                 LVARPTR=ADDR(UNPK);/* PUT OUT WHOLE NUMBER (USE  0250 00505000
*                                      LOCAL POINTER)         @Y02668*/ 00506000
         LA    R2,UNPK                                          DSKC193 00507000
*                 LLENGTH='0F'X;    /* MAXIMUM LENGTH         @Y02668*/ 00508000
         MVI   LLENGTH,X'0F'                                       0251 00509000
*               END;                                               0252 00510000
*             ELSE                  /* HEX NUMBER                    */ 00511000
*               DO;                                                0253 00512000
         B     @RC00248                                            0253 00513000
@RF00248 DS    0H                                                  0254 00514000
*                 IF REG8<5 THEN                                   0254 00515000
         C     R8,@CF00210                                      DSKC193 00516000
         BNL   @RF00254                                            0254 00517000
*                   DO;                                            0255 00518000
*                     LVARPTR=ADDR(UNPK);/* PUT OUT WHOLE NUMBER (USE   00519000
*                                      LOCAL POINTER)         @Y02668*/ 00520000
         LA    R2,UNPK                                          DSKC193 00521000
*                     LLENGTH='08'X;/* MAXIMUM LENGTH         @Y02668*/ 00522000
         MVI   LLENGTH,X'08'                                       0257 00523000
*                   END;                                           0258 00524000
*               END;                                               0259 00525000
@RF00254 DS    0H                                                  0260 00526000
*           END;                                                   0260 00527000
@RC00248 DS    0H                                                  0261 00528000
*       END;                                                       0261 00529000
*                                                                  0261 00530000
@RF00246 AL    R8,@CF00035                                      DSKC193 00531000
         C     R8,@CF00036                                      DSKC193 00532000
         BNH   @DL00245                                            0261 00533000
*       /*************************************************************/ 00534000
*       /*                                                           */ 00535000
*       /* LOOP TO DROP ALL LEADING ZEROS, IF DECIMAL, AND ALL ZEROS */ 00536000
*       /* LEFT OF 2*PLENGTH, IF HEX                                 */ 00537000
*       /*                                                           */ 00538000
*       /*************************************************************/ 00539000
*                                                                  0262 00540000
*       DO WHILE(TEMP>0&LLENGTH>1);                                0262 00541000
         B     @DE00262                                            0262 00542000
@DL00262 DS    0H                                                  0263 00543000
*         IF^(SWHAVHEX=ON&LLENGTH<=TEMP) THEN/* IF DECIMAL OR HAVEN'T   00544000
*                                      REACHED END OF HEX            */ 00545000
         TM    SWHAVHEX,B'00010000'                                0263 00546000
         BNO   @RT00263                                            0263 00547000
         SLR   R3,R3                                            DSKC193 00548000
         IC    R3,LLENGTH                                       DSKC193 00549000
         C     R3,TEMP                                          DSKC193 00550000
         BNH   @RF00263                                            0263 00551000
@RT00263 DS    0H                                                  0264 00552000
*           DO;                                                    0264 00553000
*             IF VARIABLE(1)='0' THEN/* IF FIRST CHARACTER OF INSERT    00554000
*                                      IS X'F0', I.E., CHARACTER ZERO*/ 00555000
         CLI   VARIABLE(R2),C'0'                                DSKC193 00556000
         BNE   @RF00265                                            0265 00557000
*               DO;                                                0266 00558000
*                 LVARPTR=LVARPTR+1;/* DROP THE ZERO CHARACTER       */ 00559000
         AL    R2,@CF00035                                      DSKC193 00560000
*                 LLENGTH=LLENGTH-1;                               0268 00561000
         SLR   R3,R3                                            DSKC193 00562000
         IC    R3,LLENGTH                                       DSKC193 00563000
         BCTR  R3,0                                             DSKC193 00564000
         STC   R3,LLENGTH                                       DSKC193 00565000
*               END;                                               0269 00566000
*             ELSE                  /* STOP LOOP IF FIND NON-ZERO  0270 00567000
*                                      LEADING CHARACTER             */ 00568000
*               TEMP=0;                                            0270 00569000
         B     @RC00263                                         DSKC193 00570000
@RF00265 SLR   R3,R3                                            DSKC193 00571000
         ST    R3,TEMP                                          DSKC193 00572000
*           END;                                                   0271 00573000
*         ELSE                      /* STOP LOOP IF HAVE PRINTABLE 0272 00574000
*                                      HEX WITH LLENGTH = 2*PLENGTH  */ 00575000
*           TEMP=0;                 /* COULD HAVE X'04' NOW X'F0F4'  */ 00576000
         B     @RC00263                                            0272 00577000
@RF00263 SLR   R3,R3                                            DSKC193 00578000
         ST    R3,TEMP                                          DSKC193 00579000
*       END;                        /* ALSO STOP LOOP IF REACH LAST     00580000
*                                      CHARACTER OF INSERT (LAST   0273 00581000
*                                      CHARACTER IS ALLOWED TO BE  0273 00582000
*                                      ZERO)                         */ 00583000
*                                                                  0273 00584000
@RC00263 DS    0H                                                  0273 00585000
@DE00262 L     R3,TEMP                                          DSKC193 00586000
         LTR   R3,R3                                            DSKC193 00587000
         BNP   @DC00262                                            0273 00588000
         CLI   LLENGTH,1                                           0273 00589000
         BH    @DL00262                                            0273 00590000
@DC00262 DS    0H                                                  0274 00591000
*       /*************************************************************/ 00592000
*       /*                                                           */ 00593000
*       /* PLACE PRINTABLE HEX VALUE IN FORMAT X'HEXVALUE', AS       */ 00594000
*       /* DEFAULT                                                   */ 00595000
*       /*                                                           */ 00596000
*       /*************************************************************/ 00597000
*                                                                  0274 00598000
*       IF SWHAVHEX=ON&PNOXQSW=OFF THEN                            0274 00599000
         TM    SWHAVHEX,B'00010000'                                0274 00600000
         BNO   @RF00274                                            0274 00601000
         TM    PNOXQSW(R9),B'00100000'                          DSKC193 00602000
         BNZ   @RF00274                                            0274 00603000
*         DO;                                                      0275 00604000
*           LLENGTH=LLENGTH+1;      /* USE IN NEXT STATEMENT         */ 00605000
         SLR   R3,R3                                            DSKC193 00606000
         IC    R3,LLENGTH                                       DSKC193 00607000
         LA    R3,1(,R3)                                        DSKC193 00608000
         STC   R3,LLENGTH                                       DSKC193 00609000
*           VARIABLE(LLENGTH)=QUOTE;/* INSERT TRAILING QUOTE         */ 00610000
         ALR   R3,R2                                            DSKC193 00611000
         BCTR  R3,0                                             DSKC193 00612000
         MVI   VARIABLE(R3),C''''                               DSKC193 00613000
*           LVARPTR=LVARPTR-2;      /* BACK UP POINTER TO VARIABLE 0278 00614000
*                                      (HAVE TWO EXTRA BYTES DECLARED   00615000
*                                      IN FRONT OF UNPK AREA)        */ 00616000
         LA    R3,2                                             DSKC193 00617000
         SLR   R2,R3                                            DSKC193 00618000
*           LLENGTH=LLENGTH+2;      /* LENGTH OF INSERT              */ 00619000
         SLR   R14,R14                                          DSKC193 00620000
         IC    R14,LLENGTH                                      DSKC193 00621000
         ALR   R14,R3                                           DSKC193 00622000
         STC   R14,LLENGTH                                      DSKC193 00623000
*           VARIABLE(1:2)=XQUOTE;   /* INSERT LEADING X'             */ 00624000
         MVC   VARIABLE(2,R2),@CC00051                          DSKC193 00625000
*         END;                                                     0281 00626000
*     END;                                                         0282 00627000
@RF00274 DS    0H                                                  0283 00628000
*                                                                  0283 00629000
*   /*****************************************************************/ 00630000
*   /*                                                               */ 00631000
*   /* PROCESS ALL INSERTS HERE                                      */ 00632000
*   /*                                                               */ 00633000
*   /*****************************************************************/ 00634000
*                                                                  0283 00635000
*   BYTELEN=LLENGTH;                /* SAVE INSERT LENGTH     @Y02668*/ 00636000
*                                                                  0283 00637000
@RF00214 SLR   R3,R3                                            DSKC193 00638000
         IC    R3,LLENGTH                                       DSKC193 00639000
*   /*****************************************************************/ 00640000
*   /*                                                               */ 00641000
*   /* COMPRESS BLANKS OUT OF JOBNAME,JOBID FIELDS WHEN VARIABLE IS  */ 00642000
*   /* JOBNAME(JOBID)                                                */ 00643000
*   /*                                                               */ 00644000
*   /*****************************************************************/ 00645000
*                                                                  0284 00646000
*   IF PJOBISW='1'B&VARIABLE(BYTELEN)=')' THEN/* SPECIAL CODE FOR  0284 00647000
*                                      JOBNAME(JOBID)         @Y02668*/ 00648000
         TM    PJOBISW(R9),B'00000100'                          DSKC193 00649000
         BNO   @RF00284                                            0284 00650000
         LR    R1,R2                                            DSKC193 00651000
         ALR   R1,R3                                            DSKC193 00652000
         BCTR  R1,0                                             DSKC193 00653000
         CLI   VARIABLE(R1),C')'                                DSKC193 00654000
         BNE   @RF00284                                            0284 00655000
*     DO;                           /*                        @Y02668*/ 00656000
*       PARENSW='1'B;               /* BIT FOR (JOBID) CASE   @Y02668*/ 00657000
         OI    PARENSW,B'10000000'                                 0286 00658000
*       BYTELEN=BYTELEN-1;          /* POINT TO END CHAR. OF  @Y02668   00659000
*                                      JOBID - WILL COMPRESS  @Y02668   00660000
*                                      IT NOW                 @Y02668*/ 00661000
         BCTR  R3,0                                             DSKC193 00662000
*     END;                          /* END OF (JOBID) CODE    @Y02668*/ 00663000
*   ELSE                            /*                        @Y02668*/ 00664000
*     PARENSW='0'B;                 /* ENSURE SWITCH OFF      @Y02668*/ 00665000
*                                                                  0289 00666000
         B     @RC00284                                            0289 00667000
@RF00284 NI    PARENSW,B'01111111'                                 0289 00668000
*   /*****************************************************************/ 00669000
*   /*                                                               */ 00670000
*   /* COMPRESS INSERT (REMOVE ANY BLANKS FROM END)                  */ 00671000
*   /*                                                               */ 00672000
*   /*****************************************************************/ 00673000
*                                                                  0290 00674000
*   RFY                                                            0290 00675000
*     CMPRSCTR RSTD;                                               0290 00676000
@RC00284 DS    0H                                                  0291 00677000
*   DO CMPRSCTR=BYTELEN TO 1 BY-1;  /* DO WHILE BLANKS LEFT          */ 00678000
         LR    R8,R3                                            DSKC193 00679000
         B     @DE00291                                            0291 00680000
@DL00291 DS    0H                                                  0292 00681000
*     IF VARIABLE(CMPRSCTR)^=' ' THEN                              0292 00682000
         LR    R1,R2                                            DSKC193 00683000
         ALR   R1,R8                                            DSKC193 00684000
         BCTR  R1,0                                             DSKC193 00685000
         CLI   VARIABLE(R1),C' '                                DSKC193 00686000
         BNE   NOBLANKS                                         DSKC193 00687000
*       GOTO NOBLANKS;              /* EXIT FROM SCAN OF INSERT HERE */ 00688000
*   END;                                                           0294 00689000
         BCTR  R8,0                                             DSKC193 00690000
@DE00291 LTR   R8,R8                                            DSKC193 00691000
         BP    @DL00291                                            0294 00692000
*   GO TO SKIPUP;                   /* IF REACH HERE INSERT IS ALL 0295 00693000
*                                      BLANKS - DON'T PUT INTO THE 0295 00694000
*                                      MESSAGE                       */ 00695000
*                                                                  0295 00696000
         B     SKIPUP                                              0295 00697000
*   /*****************************************************************/ 00698000
*   /*                                                               */ 00699000
*   /* SPECIAL LOGIC TO COMPRESS BLANKS OUT OF JOBNAME(JOBID)        */ 00700000
*   /*                                                               */ 00701000
*   /*****************************************************************/ 00702000
*                                                                  0296 00703000
*NOBLANKS:                                                         0296 00704000
*   IF PARENSW='1'B THEN            /* BIT FOR (JOBID) CASE   @Y02668*/ 00705000
NOBLANKS TM    PARENSW,B'10000000'                                 0296 00706000
         BNO   @RF00296                                            0296 00707000
*     DO;                           /*                        @Y02668*/ 00708000
*       JOBIDEND=CMPRSCTR;          /* SAVE OFFSET TO RIGHT-  @Y02668   00709000
*                                      MOST CHARACTER OF      @Y02668   00710000
*                                      COMPRESSED JOBID       @Y02668*/ 00711000
         ST    R8,JOBIDEND                                      DSKC193 00712000
*       DO CMPRSCTR=CMPRSCTR TO 2 BY-1;/* NOW SCAN            @Y02668   00713000
*                                      FOR LEFT PAREN         @Y02668*/ 00714000
         B     @DE00299                                            0299 00715000
@DL00299 DS    0H                                                  0300 00716000
*         IF VARIABLE(CMPRSCTR)='(' THEN/*                    @Y02668*/ 00717000
         LR    R1,R2                                            DSKC193 00718000
         ALR   R1,R8                                            DSKC193 00719000
         BCTR  R1,0                                             DSKC193 00720000
         CLI   VARIABLE(R1),C'('                                DSKC193 00721000
         BE    HAVELPRN                                         DSKC193 00722000
*           GO TO HAVELPRN;         /* EXIT FROM SCAN HERE    @Y02668*/ 00723000
*       END;                        /* END OF SCAN FOR (      @Y02668*/ 00724000
         BCTR  R8,0                                             DSKC193 00725000
@DE00299 C     R8,@CF00050                                      DSKC193 00726000
         BNL   @DL00299                                            0302 00727000
*       GO TO BADPRN;               /* SPECIAL ERROR CASE     @Y02668   00728000
*                                      - NO JOBNAME OR NO     @Y02668   00729000
*                                      LEFT PARENTHESIS       @Y02668*/ 00730000
         B     BADPRN                                              0303 00731000
*HAVELPRN:                          /*                        @Y02668*/ 00732000
*       LFTPAREN=CMPRSCTR;          /* SAVE LEFT PAREN OFFSET @Y02668*/ 00733000
HAVELPRN ST    R8,LFTPAREN                                      DSKC193 00734000
*       CMPRSCTR=CMPRSCTR-1;        /* WILL COMPRESS JOBNAME  @Y02668*/ 00735000
         BCTR  R8,0                                             DSKC193 00736000
*       DO CMPRSCTR=CMPRSCTR TO 1 BY-1;/*                     @Y02668*/ 00737000
         B     @DE00306                                            0306 00738000
@DL00306 DS    0H                                                  0307 00739000
*         IF VARIABLE(CMPRSCTR)^=' ' THEN/* EXIT IF           @Y02668*/ 00740000
         LR    R1,R2                                            DSKC193 00741000
         ALR   R1,R8                                            DSKC193 00742000
         BCTR  R1,0                                             DSKC193 00743000
         CLI   VARIABLE(R1),C' '                                DSKC193 00744000
         BNE   ENDCMPRS                                         DSKC193 00745000
*           GO TO ENDCMPRS;         /* FOUND NON-BLANK CHAR.  @Y02668*/ 00746000
*       END;                        /* END OF COMPRESS LOOP   @Y02668*/ 00747000
         BCTR  R8,0                                             DSKC193 00748000
@DE00306 LTR   R8,R8                                            DSKC193 00749000
         BP    @DL00306                                            0309 00750000
*       GO TO BADPRN;               /* SPECIAL ERROR CASE     @Y02668   00751000
*                                      - NO JOBNAME           @Y02668*/ 00752000
         B     BADPRN                                              0310 00753000
*ENDCMPRS:                          /*                        @Y02668*/ 00754000
*       JOBINSRT(1:CMPRSCTR)=VARIABLE(1:CMPRSCTR);/*          @Y02668   00755000
*                                      SAVE THE COMPRESSED    @Y02668   00756000
*                                      JOBNAME                @Y02668*/ 00757000
ENDCMPRS DS    0H                                               DSKC193 00758000
         C     R8,A001034                                       DSKC193 00758010
         BNL   A000436                                          DSKC193 00758020
         LR    R3,R8                                            DSKC193 00758030
         B     A00043E                                          DSKC193 00758040
A000436  LA    R3,252                                           DSKC193 00758050
         OI    A0000C1,X'80'                                    DSKC193 00758060
A00043E  LR    R14,R3                                           DSKC193 00758070
         BCTR  R14,0                                            DSKC193 00759000
         EX    R14,@SM00632                                     DSKC193 00760000
*       CMPRSCTR=CMPRSCTR+1;        /* POINT TO NEXT SPACE    @Y02668   00761000
*                                      IN COMPRESS AREA       @Y02668*/ 00762000
         LA    R8,1(,R8)                                        DSKC193 00763000
         L     R3,JOBIDEND                                      DSKC193 00763010
         LR    R14,R3                                           DSKC193 00764000
*       JOBIDIN=CMPRSCTR+           /* NEXT SPACE PLUS        @Y02668*/ 00765000
*           (JOBIDEND-LFTPAREN);    /* (JOBID LENGTH           Y02668*/ 00766000
         SL    R14,LFTPAREN                                     DSKC193 00767000
         ALR   R14,R8                                           DSKC193 00770000
         ST    R14,A0000A8                                      DSKC193 00770010
         TM    A0000C1,X'80'                                    DSKC193 00770020
         BNE   A000A9C                                          DSKC193 00770030
         C     R14,A001034                                      DSKC193 00770040
         BH    A000A76                                          DSKC193 00770050
         ST    R14,A0000AC                                      DSKC193 00770060
         L     R3,JOBIDEND                                      DSKC193 00770070
         B     A000486                                          DSKC193 00770080
A000A76  LA    R14,252                                          DSKC193 00770090
         ST    R14,A0000AC                                      DSKC193 00770100
         SLR   R14,R8                                           DSKC193 00770110
         AL    R14,LFTPAREN                                     DSKC193 00770120
         LR    R3,R14                                           DSKC193 00770130
*       JOBINSRT(CMPRSCTR:JOBIDIN)= /* MOVE (JOBID            @Y02668*/ 00771000
*           VARIABLE(LFTPAREN:JOBIDEND);/*                    @Y02668*/ 00772000
A000486  LA    R1,JOBINSRT-1(R8)                                DSKC193 00773000
         L     R14,A0000AC                                      DSKC193 00774000
         SLR   R14,R8                                           DSKC193 00775000
         LR    R15,R2                                           DSKC193 00775010
         AL    R15,LFTPAREN                                     DSKC193 00776000
         BCTR  R15,0                                            DSKC193 00777000
         EX    R14,@SM00634                                     DSKC193 00779000
*       CMPRSCTR=JOBIDIN+1;         /* GET OFFSET TO END )    @Y02668*/ 00780000
A000A9C  L     R1,A0000A8                                       DSKC193 00781000
         LA    R1,1(,R1)                                        DSKC193 00782000
         LR    R8,R1                                            DSKC193 00782010
         C     R8,A001034                                       DSKC193 00783000
         BH    A0004BA                                          DSKC193 00783010
*       JOBINSRT(CMPRSCTR)=')';     /* NOW HAVE COMPRESSED    @Y02668   00784000
*                                      JOBNAME(JOBID)         @Y02668*/ 00785000
         LA    R1,JOBINSRT-1(R8)                                DSKC193 00786000
         MVI   0(R1),C')'                                       DSKC193 00787000
         B     A0004BE                                          DSKC193 00787010
A0004BA  LA    R8,252                                           DSKC193 00787020
*       LVARPTR=ADDR(JOBINSRT);     /* NEW INSERT FOR MSG     @Y02668*/ 00788000
A0004BE  LA    R2,JOBINSRT                                      DSKC193 00789000
*     END;                          /* END JOBNM(JOBID) CODE  @Y02668*/ 00790000
*   BYTELEN=CMPRSCTR;               /* GET NUMBER OF CHARACTERS LEFT    00791000
*                                      IN THE INSERT                 */ 00792000
@RF00296 LR    R3,R8                                            DSKC193 00793000
*   RFY                                                            0320 00794000
*    (REG8,                                                        0320 00795000
*     CMPRSCTR) UNRSTD;                                            0320 00796000
*BADPRN:                            /* JOBNAME(JOBID) ERROR   @Y02668*/ 00797000
*                                                                  0321 00798000
*   /*****************************************************************/ 00799000
*   /*                                                               */ 00800000
*   /* MOVE THE INSERT INTO THE MESSAGE BUILD AREA                   */ 00801000
*   /*                                                               */ 00802000
*   /*****************************************************************/ 00803000
*                                                                  0321 00804000
*   BLDLEN=BLDLEN+BYTELEN;          /* LENGTH OF BUILD AREA INCLUDING   00805000
*                                      THE VARIABLE                  */ 00806000
BADPRN   LR    R8,R3                                            DSKC193 00807000
         AH    R8,BLDLEN                                        DSKC193 00808000
         STH   R8,BLDLEN                                        DSKC193 00809000
*   IF BLDLEN>LENGTH(BLDAREA) THEN  /* TRUNCATE IF MESSAGE IS TOO  0322 00810000
*                                      LONG FOR BLDBUF               */ 00811000
         LA    R14,260                                          DSKC193 00812000
         CR    R8,R14                                           DSKC193 00813000
         BNH   @RF00322                                            0322 00814000
*     DO;                                                          0323 00815000
*       BLDLEN=LENGTH(BLDAREA);     /* SET TOTAL LENGTH TO MAXIMUM 0324 00816000
*                                      FOR BLDBUF                    */ 00817000
         STH   R14,BLDLEN                                       DSKC193 00818000
*       BYTELEN=BLDLEN-LSTLEN;      /* SET LENGTH OF VARIABLE        */ 00819000
         SLR   R14,R6                                           DSKC193 00820000
         LR    R3,R14                                           DSKC193 00821000
*     END;                                                         0326 00822000
*   BLDBUF(LSTLEN+1:BLDLEN)=VARIABLE(1:BYTELEN);/* MOVE VARIABLE INTO   00823000
*                                      MESSAGE BUILT AREA            */ 00824000
@RF00322 LA    R8,BLDBUF(R6)                                    DSKC193 00825000
         LH    R14,BLDLEN                                       DSKC193 00826000
         SLR   R14,R6                                           DSKC193 00827000
         BCTR  R14,0                                            DSKC193 00828000
         EX    R14,@SM00636                                     DSKC193 00829000
*SKIPUP:                                                           0328 00830000
*   VARLISTP=VARLISTP+4;            /* INCREMENT VARIABLE POINTER TO    00831000
*                                      NEXT ONE                      */ 00832000
SKIPUP   AL    R7,@CF00225                                      DSKC193 00833000
*   CSECTP=CSECTP+1;                /* THE 1 IS THE LENGTH OF THE  0329 00834000
*                                      PART LENGTH FIELD IN THE    0329 00835000
*                                      MESSAGE MACRO                 */ 00836000
         AL    R5,@CF00035                                      DSKC193 00837000
         NI    SWHAVHEX,B'11101111'                             DSKC193 00837010
*   GO TO LOOPCHK;                  /* GO TO CHECK ON NUMBER OF PARTS   00838000
*                                      LEFT                          */ 00839000
*                                                                  0330 00840000
         B     LOOPCHK                                             0330 00841000
*   /*****************************************************************/ 00842000
*   /*                                                               */ 00843000
*   /* MOVE FIXED TEXT SEGMENT INTO THE MESSAGE BUILD AREA           */ 00844000
*   /*                                                               */ 00845000
*   /*****************************************************************/ 00846000
*                                                                  0331 00847000
*SEGMOVE:                                                          0331 00848000
*   BYTELEN=CPARTLEN;                                              0331 00849000
SEGMOVE  SLR   R8,R8                                            DSKC193 00850000
         IC    R8,CPARTLEN(,R5)                                 DSKC193 00851000
         LR    R3,R8                                            DSKC193 00852000
*   BLDLEN=BLDLEN+CPARTLEN;         /* LENGTH OF BUILD AREA INCLUDING   00853000
*                                      THE FIXED SEGMENT             */ 00854000
         AH    R8,BLDLEN                                        DSKC193 00855000
         STH   R8,BLDLEN                                        DSKC193 00856000
*   IF BLDLEN>LENGTH(BLDAREA) THEN  /* TRUNCATE MESSAGE IF IT WON'T     00857000
*                                      FIT IN BLDBUF                 */ 00858000
         LA    R2,260                                           DSKC193 00859000
         CR    R8,R2                                            DSKC193 00860000
         BNH   @RF00333                                            0333 00861000
*     DO;                                                          0334 00862000
*       BLDLEN=LENGTH(BLDAREA);     /* NEW LENGTH OF MESSAGE         */ 00863000
         STH   R2,BLDLEN                                        DSKC193 00864000
*       BYTELEN=BLDLEN-LSTLEN;                                     0336 00865000
         SLR   R2,R6                                            DSKC193 00866000
         LR    R3,R2                                            DSKC193 00867000
*     END;                                                         0337 00868000
*   BLDBUF(LSTLEN+1:BLDLEN)=CMSGPART(1:BYTELEN);/* MOVE FIXED SEGMENT   00869000
*                                      INTO MESSAGE BUILD AREA       */ 00870000
@RF00333 LA    R8,BLDBUF(R6)                                    DSKC193 00871000
         LH    R2,BLDLEN                                        DSKC193 00872000
         SLR   R2,R6                                            DSKC193 00873000
         BCTR  R2,0                                             DSKC193 00874000
         EX    R2,@SM00638                                      DSKC193 00875000
*   CSECTP=CSECTP+CPARTLEN+1;       /* 1 IS THE LENGTH OF THE PART 0339 00876000
*                                      LENGTH FIELD. POINT TO THE  0339 00877000
*                                      NEXT LENGTH BYTE IN THE     0339 00878000
*                                      IKJTSMSG MACRO BEING PROCESSED*/ 00879000
*                                                                  0339 00880000
         LR    R6,R5                                            DSKC193 00881000
         SLR   R8,R8                                            DSKC193 00882000
         IC    R8,CPARTLEN(,R5)                                 DSKC193 00883000
         ALR   R6,R8                                            DSKC193 00883010
         AL    R6,@CF00035                                      DSKC193 00884000
         LR    R5,R6                                            DSKC193 00885000
*   /*****************************************************************/ 00886000
*   /*                                                               */ 00887000
*   /* CONTINUE LOOPING UNTIL MESSAGE IS COMPLETELY BUILT            */ 00888000
*   /*                                                               */ 00889000
*   /*****************************************************************/ 00890000
*                                                                  0340 00891000
*LOOPCHK:                                                          0340 00892000
*   LSTLEN=BLDLEN;                  /* LSTLEN IS NOW LENGTH OF     0340 00893000
*                                      MESSAGE BUILT                 */ 00894000
LOOPCHK  LH    R8,BLDLEN                                        DSKC193 00895000
         LR    R6,R8                                            DSKC193 00896000
*   NBPART=NBPART+1;                /* INCREMENT NUMBER OF PARTS   0341 00897000
*                                      MOVED INTO MESSAGE BUILT      */ 00898000
         ICM   R14,15,NBPART                                    DSKC193 00899000
         AL    R14,@CF00035                                     DSKC193 00901000
         STCM  R14,15,NBPART                                    DSKC193 00902000
*   IF BLDLEN<LENGTH(BLDAREA) THEN  /* IS MESSAGE AT THE MAXIMUM   0342 00904000
*                                      LENGTH?                       */ 00905000
         C     R8,@CF00609                                      DSKC193 00906000
         BNL   @RF00342                                            0342 00907000
*     IF NBPARTS<CNBPARTS THEN      /* ARE ALL THE PARTS MOVED INTO     00908000
*                                      THE MESSAGE BUFFER ?          */ 00909000
         CLC   NBPARTS(1),CNBPARTS(R4)                          DSKC193 00910000
         BL    BLDLOOP                                          DSKC193 00911000
*       GO TO BLDLOOP;              /* NO, GO BACK AND REPEAT PROCESS*/ 00912000
*                                                                  0345 00913000
*   /*****************************************************************/ 00914000
*   /*                                                               */ 00915000
*   /* COME HERE AFTER BUILD A LINE OF THE MESSAGE                   */ 00916000
*   /*                                                               */ 00917000
*   /*****************************************************************/ 00918000
*                                                                  0345 00919000
*/*  *****************************************************************/ 00920000
*/*         EXTRACT CHECKING AND HANDLING IS PERFORMED       @Z40GQKU*/ 00921000
*/*         IN THIS SEGMENT                                  @Z40GQKU*/ 00922000
*/*  *****************************************************************/ 00923000
*                                                                  0345 00924000
*   IF SWEXTRCT=ON&                 /* EXTRACT WANTED AND NOT@Z40GQKU*/ 00925000
*       (SWEXTONE=OFF×SWEXTTWO=OFF) THEN/* COMPLETED         @Z40GQKU*/ 00926000
*                                                                  0345 00927000
@RF00342 TM    SWEXTRCT,B'00001000'                                0345 00928000
         BNO   @RF00345                                            0345 00929000
         TM    SWEXTONE,B'00000011'                                0345 00930000
         BO    @RF00345                                            0345 00931000
*     /***************************************************************/ 00932000
*     /*                                                             */ 00933000
*     /* HANDLE SINGLE MESSAGE, DATA MSG OR SPECIAL CASE     @Z40GQKU*/ 00934000
*     /*                                                             */ 00935000
*     /***************************************************************/ 00936000
*                                                                  0346 00937000
*     DO;                           /* GO THRU HERE. FIRST   @Z40GQKU*/ 00938000
*       IF(CREPLYID='    '×         /* CHECK IF ONLY ONE     @Z40GQKU*/ 00939000
*           PDATASW=ON×             /* MSG OR DATA MSG OR    @Z40GQKU*/ 00940000
*           PWTOSW=ON)&             /* WRITE TO OPERATOR MSG.@Z40GQKU*/ 00941000
*           SWEXTONE=OFF&           /* IF NOT COPIED YET     @Z40GQKU*/ 00942000
*           SWEXTTWO=OFF THEN       /* THEN                  @Z40GQKU*/ 00943000
         CLC   CREPLYID(4,R4),@CC00525                          DSKC193 00944000
         BE    @GL00012                                            0347 00945000
         TM    PDATASW(R9),B'10100000'                          DSKC193 00946000
         BZ    @RF00347                                            0347 00947000
@GL00012 TM    SWEXTONE,B'00000011'                                0347 00948000
         BNZ   @RF00347                                            0347 00949000
*         DO;                       /* GO EXTRACT            @Z40GQKU*/ 00950000
*           CALL COPYONE;           /* MESSAGE.              @Z40GQKU*/ 00951000
         BAL   R14,COPYONE                                      DSKC193 00952000
*           IF P2OLDSW=ON&          /* BUT CHECK IF PREMADE  @Z40GQKU*/ 00953000
*               SWEXTRC2=ON THEN    /* MSG AND EXTRACT ASKED @Z40GQKU*/ 00954000
         TM    P2OLDSW(R9),B'10000000'                          DSKC193 00955000
         BNO   @RF00350                                            0350 00956000
         TM    SWEXTRC2,B'00000100'                                0350 00957000
         BNO   @RF00350                                            0350 00958000
*             DO;                   /* MESSAGE EXISTS. IF    @Z40GQKU*/ 00959000
*               IF OLDNSEG=1 THEN   /* ONLY PRIMARY SEGMENT, @Z40GQKU*/ 00960000
         L     R5,POLDPTR(,R9)                                  DSKC193 00961000
         CLC   OLDNSEG(4,R5),@CF00035                           DSKC193 00962000
         BNE   @RF00352                                            0352 00963000
*                 CALL COPYSPCL;    /* COPY IT. BUT IF       @Z40GQKU*/ 00964000
         BAL   R14,COPYSPCL                                     DSKC193 00965000
*               ELSE                /* MULTI-SEGMENTS TO     @Z40GQKU*/ 00966000
*                 BUFLEN=0;         /* SAY NO SECOND LEVEL   @Z40GQKU   00967000
*                                      MSG AVAILABLE FOR EXTRCT    0354 00968000
*                                                            @Z40GQKU*/ 00969000
         B     @RC00350                                         DSKC193 00970000
@RF00352 DS    0H                                               DSKC193 00971000
         SLR   R6,R6                                            DSKC193 00971010
         ICM   R6,7,PEXTRBF2(R9)                                DSKC193 00971020
         SLR   R8,R8                                            DSKC193 00972000
         STCM  R8,3,EXTRBF2(R6)                                 DSKC193 00973000
*             END;                  /* MESSAGE.              @Z40GQKU*/ 00975000
*           ELSE                    /* BUT IF EXTRACT WANTED @Z40GQKU*/ 00976000
*             IF SWEXTRC2=ON THEN   /* AND NOT AVAILABLE     @Z40GQKU*/ 00977000
         B     @RC00350                                            0356 00978000
@RF00350 TM    SWEXTRC2,B'00000100'                                0356 00979000
         BNO   @RF00356                                            0356 00980000
*               BUFLEN=0;           /* SAY NO SECOND LEVEL   @Z40GQKU   00981000
*                                      MSG AVAILABLE FOR EXTRCT    0357 00982000
*                                                            @Z40GQKU*/ 00983000
         SLR   R5,R5                                            DSKC193 00984000
         ICM   R5,7,PEXTRBF2(R9)                                DSKC193 00984010
         SLR   R6,R6                                            DSKC193 00985000
         STCM  R6,3,EXTRBF2(R5)                                 DSKC193 00986000
*           IF PEXTRCON=OFF THEN    /* NOW CHECK, IF ONLY    @Z40GQKU*/ 00988000
@RF00356 DS    0H                                                  0358 00989000
@RC00350 TM    PEXTRCON(R9),B'00000100'                         DSKC193 00990000
         BZ    RETLABEL                                         DSKC193 00991000
*             GO TO RETLABEL;       /* EXTRACT WANTED, EXIT. @Z40GQKU*/ 00992000
*           ELSE                    /* OTHERWISE, JUST       @Z40GQKU*/ 00993000
*             SWEXTTWO=ON;          /* TURN OFF SECOND       @Z40GQKU*/ 00994000
         OI    SWEXTTWO,B'00000001'                                0360 00995000
*         END;                      /* EXTRACT SWITCH.       @Z40GQKU*/ 00996000
*       ELSE                        /* IF TWO LEVEL MESSAGE  @Z40GQKU*/ 00997000
*                                                                  0362 00998000
*         /***********************************************************/ 00999000
*         /*                                                         */ 01000000
*         /* HERE CHECK FOR MULTI-LEVEL PUTLINE TYPE MESSAGE @Z40GQKU*/ 01001000
*         /*                                                         */ 01002000
*         /***********************************************************/ 01003000
*                                                                  0362 01004000
*         IF PREVERSW=ON×           /* IF EITHER PUTLINE OR  @Z40GQKU*/ 01005000
*             PWTPSW=ON THEN        /* WRITE TO PROGRAMMER   @Z40GQKU*/ 01006000
         B     @RC00347                                            0362 01007000
@RF00347 TM    PREVERSW(R9),B'01000010'                         DSKC193 01008000
         BZ    @RF00362                                            0362 01009000
*           DO;                     /* THEN GO THIS WAY      @Z40GQKU*/ 01010000
*             IF SWEXTRC2=ON THEN   /* IF SECOND EXTRACT     @Z40GQKU*/ 01011000
         TM    SWEXTRC2,B'00000100'                                0364 01012000
         BNO   @RF00364                                            0364 01013000
*               DO;                 /* WANTED THEN           @Z40GQKU*/ 01014000
*                 IF SWEXTTWO=OFF THEN/* IF WANT SECOND MSG@Z40GQKU  */ 01015000
         TM    SWEXTTWO,B'00000001'                                0366 01016000
         BNZ   @RF00366                                            0366 01017000
*                   CALL COPYTWO;   /* EXTRACT IT,           @Z40GQKU*/ 01018000
         BAL   R14,COPYTWO                                      DSKC193 01019000
*                 ELSE              /* UNLESS ALREADY DONE,  @Z40GQKU*/ 01020000
*                   CALL COPYONE;   /* THEN EXTRACT FIRST    @Z40GQKU   01021000
*                                      END OF PUTLINE TYPE   @Z40GQKU*/ 01022000
         B     @RC00362                                         DSKC193 01023000
@RF00366 BAL   R14,COPYONE                                      DSKC193 01024000
*               END;                /* TWO LEVEL EXTRACTION.@Z40GQKU */ 01025000
*             ELSE                  /* NOW HANDLE            @Z40GQKU   01026000
*                                      ONE LEVEL EXTRACTION  @Z40GQKU*/ 01027000
*               DO;                 /* FOR TWO LEVEL MESSAGE @Z40GQKU*/ 01028000
         B     @RC00362                                         DSKC193 01029000
@RF00364 DS    0H                                                  0371 01030000
*                 IF SWEXTTWO=ON THEN/* IF THIS IS           @Z40GQKU   01031000
*                                      SECOND TIME THROUGH   @Z40GQKU*/ 01032000
         TM    SWEXTTWO,B'00000001'                                0371 01033000
         BNO   @RF00371                                            0371 01034000
*                   CALL COPYONE;   /* COPY FIRST LEVEL MSG.@Z40GQKU */ 01035000
         BAL   R14,COPYONE                                      DSKC193 01036000
*                 ELSE              /* IF FIRST TIME THROUGH@Z40GQKU */ 01037000
*                   SWEXTTWO=ON;    /* TURN SECOND COPY      @Z40GQKU*/ 01038000
         B     @RC00362                                         DSKC193 01039000
@RF00371 OI    SWEXTTWO,B'00000001'                                0373 01040000
*               END;                /* SWITCH ON. EXIT       @Z40GQKU*/ 01041000
*                                                                  0374 01042000
*             /*******************************************************/ 01043000
*             /*                                                     */ 01044000
*             /* END OF PUTLINE TYPE                         @Z40GQKU*/ 01045000
*             /*                                                     */ 01046000
*             /*******************************************************/ 01047000
*                                                                  0375 01048000
*           END;                    /* HANDLING              @Z40GQKU*/ 01049000
*         ELSE                      /* ARRIVE HERE FOR       @Z40GQKU*/ 01050000
*                                                                  0376 01051000
*           /*********************************************************/ 01052000
*           /*                                                       */ 01053000
*           /* MULTI-LEVEL PUTGET                            @Z40GQKU*/ 01054000
*           /*                                                       */ 01055000
*           /*********************************************************/ 01056000
*                                                                  0376 01057000
*           DO;                     /* IF THIS IS FIRST TIME @Z40GQKU*/ 01058000
         B     @RC00362                                            0376 01059000
@RF00362 DS    0H                                                  0377 01060000
*             IF SWEXTONE=OFF THEN  /* THROUGH THEN          @Z40GQKU*/ 01061000
         TM    SWEXTONE,B'00000010'                                0377 01062000
         BNZ   @RF00377                                            0377 01063000
*               CALL COPYONE;       /* EXTRACT FIRST LEVEL.  @Z40GQKU*/ 01064000
         BAL   R14,COPYONE                                      DSKC193 01065000
*             ELSE                  /* BUT IF SECOND TIME    @Z40GQKU*/ 01066000
*               IF SWEXTRC2=ON THEN /* THROUGH AND           @Z40GQKU   01067000
*                                      WANT SECOND LEVEL     @Z40GQKU*/ 01068000
         B     @RC00377                                            0379 01069000
@RF00377 TM    SWEXTRC2,B'00000100'                                0379 01070000
         BNO   @RF00379                                            0379 01071000
*                 CALL COPYTWO;     /* THEN EXTRACT IT.      @Z40GQKU*/ 01072000
         BAL   R14,COPYTWO                                      DSKC193 01073000
*               ELSE                /* OTHERWISE JUST TURN   @Z40GQKU*/ 01074000
*                 SWEXTTWO=ON;      /* SECOND LEVEL SWITCH ON@Z40GQKU   01075000
*                                      END OF PUTGET TYPE    @Z40GQKU*/ 01076000
         B     @RC00379                                            0381 01077000
@RF00379 OI    SWEXTTWO,B'00000001'                                0381 01078000
*           END;                    /* HANDLING.             @Z40GQKU*/ 01079000
@RC00379 DS    0H                                                  0382 01080000
@RC00377 DS    0H                                                  0383 01081000
*     END;                          /*                       @Z40GQKU*/ 01082000
*                                                                  0383 01083000
@RC00362 DS    0H                                                  0383 01084000
@RC00347 DS    0H                                                  0384 01085000
*   /*****************************************************************/ 01086000
*   /*                                                               */ 01087000
*   /* END OF MESSAGE EXTRACT CODE                           @Z40GQKU*/ 01088000
*   /*                                                               */ 01089000
*   /*****************************************************************/ 01090000
*                                                                  0384 01091000
*   IF PWTOSW=ON×((PWTPSW=ON×WTPOVERR=ON)&SWLSTMSG=ON) THEN/*      0384 01092000
*                                      PARAMETER LIST AND/OR SWITCHES   01093000
*                                      INDICATE A WTO OR WTP MESSAGE    01094000
*                                      READY TO BE PUT OUT           */ 01095000
@RF00345 TM    PWTOSW(R9),B'00100000'                           DSKC193 01096000
         BO    @RT00384                                            0384 01097000
         TM    PWTPSW(R9),B'00000010'                           DSKC193 01098000
         BO    @GL00016                                            0384 01099000
         TM    WTPOVERR,B'00000001'                                0384 01100000
         BNO   @RF00384                                            0384 01101000
@GL00016 TM    SWLSTMSG,B'00100000'                                0384 01102000
         BNO   @RF00384                                            0384 01103000
@RT00384 DS    0H                                                  0385 01104000
*     DO;                                                          0385 01105000
*                                                                  0385 01106000
*       /*************************************************************/ 01107000
*       /*                                                           */ 01108000
*       /* ISSUE WTO OR WRITE TO PROGRAMMER                          */ 01109000
*       /*                                                           */ 01110000
*       /*************************************************************/ 01111000
*                                                                  0386 01112000
*WTPMSG:                            /* COME HERE IF PUTLINE FAILED   */ 01113000
*       WPLPTR=ADDR(BLDBUF);        /* GET ADDRESS OF MESSAGE AREA -    01114000
*                                      SAME FORMAT FOR WTO OR PUTLINE*/ 01115000
WTPMSG   LA    R2,BLDBUF                                        DSKC193 01116000
*       WPLMCSF='8000'X;            /* MCS FLAG INDICATES THAT     0387 01117000
*                                      ROUTING/DESCRIPTOR CODES    0387 01118000
*                                      FOLLOW MESSAGE TEXT           */ 01119000
         MVC   WPLMCSF(2,R2),@CB00565                           DSKC193 01120000
*       WPLPTR=WPLPTR+WPLLGH;       /* POINT TO WPLFLGS, WHICH FOLLOW   01121000
*                                      MESSAGE TEXT                  */ 01122000
         AH    R2,WPLLGH(,R2)                                   DSKC193 01123000
*       IF PWTOSW=ON THEN           /* SET UP TO ISSUE WTO           */ 01124000
         TM    PWTOSW(R9),B'00100000'                           DSKC193 01125000
         BNO   @RF00389                                            0389 01126000
*         DO;                                                      0390 01127000
*           IF WPLLGH>MAXWTOLN+4 THEN/* IF TOO-LONG WTO MESSAGE PLUS    01128000
*                                      HEADER, TRUNCATE THE MESSAGE  */ 01129000
         LA    R3,128                                           DSKC193 01130000
         CH    R3,WPLLGH(,R2)                                   DSKC193 01131000
         BNL   @RF00391                                            0391 01132000
*             WPLLGH=MAXWTOLN+4;                                   0392 01133000
         STH   R3,WPLLGH(,R2)                                   DSKC193 01134000
*           WPLFLGS='10004000'X;    /* SET DESCRIPTOR CODE = 4     0393 01135000
*                                      (SYSTEM STATUS), AND ROUTCDE =   01136000
*                                      2 (MAIN CONSOLE)              */ 01137000
@RF00391 XC    WPLFLGS+4(4,R2),WPLFLGS+4(R2)                    DSKC193 01138000
         MVC   WPLFLGS(4,R2),@CB00566                           DSKC193 01139000
*         END;                                                     0394 01140000
*       ELSE                        /* SET UP TO ISSUE WTP - WRITE TO   01141000
*                                      PROGRAMMER                    */ 01142000
*         WPLFLGS(1:4)='02000020'X; /* SET DESCRIPTOR CODE = 7     0395 01143000
*                                      (APPLICATION                0395 01144000
*                                      PROGRAM/PROCESSOR), AND     0395 01145000
*                                      ROUTCDE=11 (WTP) - ELEVENTH 0395 01146000
*                                      BIT ON IN SECOND HALFWORD     */ 01147000
         B     @RC00389                                            0395 01148000
@RF00389 MVC   WPLFLGS(4,R2),@CB00567                           DSKC193 01149000
*       RFY                                                        0396 01150000
*         REG8 RSTD;                                               0396 01151000
@RC00389 DS    0H                                                  0397 01152000
*       REG8=ADDR(BLDBUF);          /* POINT TO MESSAGE AREA         */ 01153000
         LA    R8,BLDBUF                                        DSKC193 01154000
*       RFY                                                        0398 01155000
*         WPL BASED(REG8);                                         0398 01156000
*       CALL WTODOMP;               /* DO COMMON PROCESSING TO ISSUE    01157000
*                                      THE MESSAGE                   */ 01158000
         BAL   R14,WTODOMP                                      DSKC193 01159000
*                                                                  0400 01160000
*       /*************************************************************/ 01161000
*       /*                                                           */ 01162000
*       /* ISSUE WRITE TO PROGRAMMER FOR SECOND LEVEL MESSAGE, IF    */ 01163000
*       /* HAVE ONE                                                  */ 01164000
*       /*                                                           */ 01165000
*       /*************************************************************/ 01166000
*                                                                  0400 01167000
*       IF(PWTPSW=ON×WTPOVERR=ON)&SWMULTLV=ON&PGRCER=OFF THEN      0400 01168000
         TM    PWTPSW(R9),B'00000010'                           DSKC193 01169000
         BO    @GL00019                                            0400 01170000
         TM    WTPOVERR,B'00000001'                                0400 01171000
         BNO   RETLABEL                                         DSKC193 01172000
@GL00019 TM    SWMULTLV,B'10000000'                                0400 01173000
         BNO   RETLABEL                                         DSKC193 01174000
         TM    PGRCER,B'00000100'                                  0400 01175000
         BNZ   RETLABEL                                         DSKC193 01176000
*         DO;                                                      0401 01177000
*           RFY                                                    0402 01178000
*             WPL BASED(WPLPTR);                                   0402 01179000
*           WPLPTR=ADDR(COREMSG);   /* ADDRESS OF O.L.D.BUFFER FOR 0403 01180000
*                                      SECOND LEVEL MESSAGE          */ 01181000
         L     R2,COREGOTP                                      DSKC193 01182000
         LA    R1,COREMSG(,R2)                                  DSKC193 01183000
         LR    R2,R1                                            DSKC193 01184000
*           WPLMCSF='8000'X;        /* SAY HAVE CODES SET=MCS        */ 01185000
         MVC   WPLMCSF(2,R2),@CB00565                           DSKC193 01186000
*           WPLPTR=WPLPTR+WPLLGH;   /* POINT TO WPLFLGS, WHICH FOLLOW   01187000
*                                      MESSAGE TEXT                  */ 01188000
         AH    R2,WPLLGH(,R2)                                   DSKC193 01189000
*           WPLFLGS(1:4)='02000020'X;/* SEE COMMENTS ON FIRST WTP    */ 01190000
         MVC   WPLFLGS(4,R2),@CB00567                           DSKC193 01191000
*           REG8=ADDR(COREMSG);                                    0407 01192000
         LR    R8,R1                                            DSKC193 01193000
*           RFY                                                    0408 01194000
*             WPL BASED(REG8);                                     0408 01195000
*           CALL WTODOMP;           /* DO COMMON PROCESSING (WTO AND    01196000
*                                      MAYBE DOM) TO ISSUE THE     0409 01197000
*                                      MESSAGE                       */ 01198000
         BAL   R14,WTODOMP                                      DSKC193 01199000
*           RFY                                                    0410 01200000
*             REG8 UNRSTD;                                         0410 01201000
*         END;                                                     0411 01202000
*       GO TO RETLABEL;             /* RETURN TO CALLER WITH RETURN     01203000
*                                      CODE=0                        */ 01204000
         B     RETLABEL                                            0412 01205000
*     END;                                                         0413 01206000
*                                                                  0414 01207000
*   /*****************************************************************/ 01208000
*   /*                                                               */ 01209000
*   /* COMMON PROCESSING FOR MESSAGES                                */ 01210000
*   /*                                                               */ 01211000
*   /*****************************************************************/ 01212000
*                                                                  0414 01213000
*   RESPECIFY                                                      0414 01214000
*    (REG3) RESTRICTED;                                            0414 01215000
@RF00384 DS    0H                                                  0415 01216000
*   TMSGID=CREPLYID;                /* GET NEXT MESSAGE ID FROM THE     01217000
*                                      REPLY ID IN THE CSECT         */ 01218000
         MVC   TMSGID(4),CREPLYID(R4)                           DSKC193 01219000
*   IF TMSGID^='    ' THEN          /* IF NEXT MESSAGE ID IN CSECT 0416 01220000
*                                      ENTRY ISN'T BLANK             */ 01221000
         CLC   TMSGID(4),@CC00525                                  0416 01222000
         BE    @RF00416                                            0416 01223000
*     DO;                                                          0417 01224000
*       SWMULTLV='1'B;              /* IF THE FIRST REPLY IS NOT   0418 01225000
*                                      BLANKS, THEN THE MESSAGE IS 0418 01226000
*                                      MULTI-LEVEL                   */ 01227000
         OI    SWMULTLV,B'10000000'                                0418 01228000
*       GO TO SKIPSW;               /* NOT LAST MESSAGE - MUST FORMAT   01229000
*                                      NEXT                          */ 01230000
         B     SKIPSW                                              0419 01231000
*     END;                          /*                       @Z40NQKJ*/ 01232000
*   ELSE                            /* WHEN NO MSG POINTED TO BY MSG    01233000
*                                      IN CSECT               @Y02668*/ 01234000
*     IF P2OLDSW='1'B THEN          /* IF HAVE PRE-FORMATTED SECOND     01235000
*                                      LEVEL (PUTLINE OUTPUT LINE  0421 01236000
*                                      DESCRIPTOR = OLD)      @Y02668*/ 01237000
@RF00416 TM    P2OLDSW(R9),B'10000000'                          DSKC193 01238000
         BNO   @RF00421                                            0421 01239000
*       SWMULTLV='1'B;              /* MULTI-LEVEL MESSAGE AND ALSO     01240000
*                                      LAST MESSAGE           @Y02668*/ 01241000
         OI    SWMULTLV,B'10000000'                                0422 01242000
*   SWLSTMSG='1'B;                  /* THE MESSAGE JUST CONSTRUCTED     01243000
*                                      IS THE LAST                   */ 01244000
@RF00421 OI    SWLSTMSG,B'00100000'                                0423 01245000
*SKIPSW:                                                           0424 01246000
*   IF(PWTPSW=ON×WTPOVERR=ON)&SWLSTMSG=ON THEN/* ISSUE WTP AFTER   0424 01247000
*                                      FIRST AND SECOND LEVELS ARE 0424 01248000
*                                      PROCESSED                     */ 01249000
SKIPSW   TM    PWTPSW(R9),B'00000010'                           DSKC193 01250000
         BO    @GL00021                                            0424 01251000
         TM    WTPOVERR,B'00000001'                                0424 01252000
         BNO   @RF00424                                            0424 01253000
@GL00021 TM    SWLSTMSG,B'00100000'                                0424 01254000
         BO    WTPMSG                                           DSKC193 01255000
*     GO TO WTPMSG;                 /* GO ISSUE WTP                  */ 01256000
*   IF PDATASW='1'B THEN            /* DATA TO BE PUT OUT, ASSUME  0426 01257000
*                                      SINGLE LEVEL                  */ 01258000
@RF00424 TM    PDATASW(R9),B'10000000'                          DSKC193 01259000
         BO    PUTLINE                                          DSKC193 01260000
*     GO TO PUTLINE;                                               0427 01261000
*   RFY                                                            0428 01262000
*    (REG0,                                                        0428 01263000
*     REG1,                                                        0428 01264000
*     REG15) RSTD;                                                 0428 01265000
*   IF SWMULTLV='0'B THEN           /* A SINGLE LEVEL MESSAGE IS PUT    01266000
*                                      OUT                           */ 01267000
         TM    SWMULTLV,B'10000000'                                0429 01268000
         BNZ   @RF00429                                            0429 01269000
*     DO;                                                          0430 01270000
*       PUTLEN=1;                                                  0431 01271000
         MVC   PUTLEN(4),@CF00035                                  0431 01272000
*       PUTADDR=ADDR(BLDBUF);                                      0432 01273000
         LA    R2,BLDBUF                                        DSKC193 01274000
         ST    R2,PUTADDR                                       DSKC193 01275000
*                                                                  0433 01276000
*       /*************************************************************/ 01277000
*       /*                                                           */ 01278000
*       /* COMMON PUTLINE LOGIC                                      */ 01279000
*       /*                                                           */ 01280000
*       /*************************************************************/ 01281000
*                                                                  0433 01282000
*PUTLINE:                           /* ENTER HERE IF DATA MESSAGE OR    01283000
*                                      TWO LEVELS                    */ 01284000
*       SAVEPAR(1:LENGTH(PUTLL))=PUTLL;/* MOVE LIST FORM OF PUTLINE     01285000
*                                      MACRO TO REENTRANT CORE     0433 01286000
*                                                            @Z40NQKJ*/ 01287000
*                                                                  0433 01288000
PUTLINE  MVC   SAVEPAR(12),PUTLL                                   0433 01289000
*       /*************************************************************/ 01290000
*       /*                                                           */ 01291000
*       /* CHANGE KEY IF NECESSARY                                   */ 01292000
*       /*                                                           */ 01293000
*       /*************************************************************/ 01294000
*                                                                  0434 01295000
*       IF PKEY1SW='1'B THEN        /* NEED TO BE IN KEY 0 OR @Y02656*/ 01296000
         TM    PKEY1SW(R9),B'00001000'                          DSKC193 01297000
         BNO   @RF00434                                            0434 01298000
*         GEN;                                                     0435 01299000
*                                   /* 8 TO ISSUE 2-LEVEL MSG @Y02656*/ 01300000
TOKEY0A  MODESET EXTKEY=SUPR,RELATED=(KEY0,IKJEFF02(TOKEY1A))   @Y02656 01301000
*                                   CHANGE TO KEY 0             @Y02656 01302000
*         REG15=REG0;                                              0436 01303000
*                                                                  0436 01304000
@RF00434 LR    R15,R0                                           DSKC193 01305000
*       /*************************************************************/ 01306000
*       /*                                                           */ 01307000
*       /* PROCESS PUTLINE FOR DATA                                  */ 01308000
*       /*                                                           */ 01309000
*       /*************************************************************/ 01310000
*                                                                  0437 01311000
*       IF PDATASW='1'B THEN                                       0437 01312000
         TM    PDATASW(R9),B'10000000'                          DSKC193 01313000
         BNO   @RF00437                                            0437 01314000
*         DO;                                                      0438 01315000
*           GENERATE;                                              0439 01316000
*                                   /* PUTLINE SINGLE LINE OF DATA   */ 01317000
         PUTLINE   OUTPUT=(BLDBUF,DATA),                               X01318000
               MF=(E,PUTPTRS)       LINK TO PUTLINE                     01319000
*           GO TO PUTDONE;                                         0440 01320000
         B     PUTDONE                                             0440 01321000
*         END;                                                     0441 01322000
*                                                                  0441 01323000
*       /*************************************************************/ 01324000
*       /*                                                           */ 01325000
*       /* PROCESS TWO-LEVEL PUTLINE MESSAGE                         */ 01326000
*       /*                                                           */ 01327000
*       /*************************************************************/ 01328000
*                                                                  0442 01329000
*       IF SWMULTLV='1'B THEN                                      0442 01330000
@RF00437 TM    SWMULTLV,B'10000000'                                0442 01331000
         BNO   @RF00442                                            0442 01332000
*         DO;                                                      0443 01333000
*           GENERATE;                                              0444 01334000
*                                   /* PUTLINE TWO-LINE MESSAGE      */ 01335000
         PUTLINE OUTPUT=((R3),MULTLVL),                         DSKC193X01336000
               MF=(E,PUTPTRS)                                           01337000
*           GO TO PUTDONE;                                         0445 01338000
         B     PUTDONE                                             0445 01339000
*         END;                                                     0446 01340000
*                                                                  0446 01341000
*       /*************************************************************/ 01342000
*       /*                                                           */ 01343000
*       /* PROCESS SINGLE-LEVEL PUTGET MESSAGE                       */ 01344000
*       /*                                                           */ 01345000
*       /*************************************************************/ 01346000
*                                                                  0447 01347000
*       IF PREVERSW=OFF&PGRCER=OFF THEN/*                    @Z40NQKJ*/ 01348000
@RF00442 TM    PREVERSW(R9),B'01000000'                         DSKC193 01349000
         BNZ   @RF00447                                            0447 01350000
         TM    PGRCER,B'00000100'                                  0447 01351000
         BNZ   @RF00447                                            0447 01352000
*         DO;                                                      0448 01353000
*           SAVEPAR(1:LENGTH(PUTGETLL))=PUTGETLL;/* GET REENTRANT  0449 01354000
*                                      LIST FORM OF MACRO    @Z40NQKJ*/ 01355000
         MVC   SAVEPAR(16),PUTGETLL                                0449 01356000
*           GEN;                                                   0450 01357000
*                                  /*                       @Z40NQKJ*/  01358000
         PUTGET OUTPUT=(PUTPARM),MF=(E,PUTPTRS)                 DSKC193 01359000
*         END;                      /*                       @Z40NQKJ*/ 01360000
*       ELSE                        /* IF NOT PUTGET         @Z40NQKJ*/ 01361000
*                                                                  0452 01362000
*         /***********************************************************/ 01363000
*         /*                                                         */ 01364000
*         /* PROCESS SINGLE-LEVEL PUTLINE MESSAGE                    */ 01365000
*         /*                                                         */ 01366000
*         /***********************************************************/ 01367000
*                                                                  0452 01368000
*         GENERATE;                                                0452 01369000
         B     @RC00447                                            0452 01370000
@RF00447 DS    0H                                                  0452 01371000
*                                   /* PUTLINE ONE-LINE MESSAGE      */ 01372000
         PUTLINE   OUTPUT=(PUTPARM),                                   X01373000
               MF=(E,PUTPTRS)       LINK TO PUTLINE                     01374000
*PUTDONE:                                                          0453 01375000
*         RETCODE=REG15;            /* SAVE PUTLINE'S RETURN CODE    */ 01376000
*                                                                  0453 01377000
@RC00447 DS    0H                                                  0453 01378000
PUTDONE  ST    R15,RETCODE                                      DSKC193 01379000
*       /*************************************************************/ 01380000
*       /*                                                           */ 01381000
*       /* CHANGE KEY BACK IF NECESSARY                              */ 01382000
*       /*                                                           */ 01383000
*       /*************************************************************/ 01384000
*                                                                  0454 01385000
*       IF PKEY1SW='1'B THEN        /* CHANGE BACK TO KEY 1   @Y02656*/ 01386000
         TM    PKEY1SW(R9),B'00001000'                          DSKC193 01387000
         BNO   @RF00454                                            0454 01388000
*         GEN;                                                     0455 01389000
*                                                                  0455 01390000
*                                   /* (AFTER ISSUE PUTLINE)  @Y02656*/ 01391000
TOKEY1A  MODESET EXTKEY=SCHED,RELATED=(KEY1,IKJEFF02(TOKEY0A))  @Y02656 01392000
*                                   CHANGE FROM KEY 0 TO KEY 1  @Y02656 01393000
*         /***********************************************************/ 01394000
*         /*                                                         */ 01395000
*         /* CHECK FOR PUTGET ERROR                                  */ 01396000
*         /*                                                         */ 01397000
*         /***********************************************************/ 01398000
*                                                                  0456 01399000
*         IF RETCODE^=0&PREVERSW=OFF&PGRCER=OFF THEN/* IF JUST GOT 0456 01400000
*                                      PUTGET ERROR          @Z40NQKJ*/ 01401000
@RF00454 L     R6,RETCODE                                       DSKC193 01402000
         LTR   R6,R6                                            DSKC193 01403000
         BNZ   @RF00456                                         DSKC193 01404000
         TM    PREVERSW(R9),B'01000000'                         DSKC193 01405000
         BNZ   @RF00456                                            0456 01406000
         TM    PGRCER,B'00000100'                                  0456 01407000
         BZ    @RF00526                                         DSKC193 01408000
@RF00456 L     R8,RETCODE                                       DSKC193 01408010
         LTR   R8,R8                                            DSKC193 01408020
         BE    A00090A                                          DSKC193 01408030
         TM    PREVERSW(R9),B'01000000'                         DSKC193 01408040
         BNE   A00090A                                          DSKC193 01408050
         TM    PGRCER,B'00000100'                               DSKC193 01408060
         BNE   A00090A                                          DSKC193 01408070
*           DO;                     /*                       @Z40NQKJ*/ 01409000
*             IF PPGMSW=ON THEN     /* IF WANT ERROR MESSAGE @Z40NQKJ*/ 01410000
         TM    PPGMSW(R9),B'00001000'                           DSKC193 01411000
         BNO   RETLABEL                                         DSKC193 01412000
*               DO;                 /*                       @Z40NQKJ*/ 01413000
*                 PGRCER=ON;        /* REMEMBER PUTGET ERROR @Z40NQKJ*/ 01414000
         OI    PGRCER,B'00000100'                                  0460 01415000
*                 PGRETCD=RETCODE;  /* SAVE RETURN CODE      @Z40NQKJ*/ 01416000
         ST    R8,PGRETCD                                       DSKC193 01417000
*                 GO TO SKIPSW;     /* ISSUE TEXT AS PUTLINE @Z40NQKJ*/ 01418000
         B     SKIPSW                                              0462 01419000
*               END;                /*                       @Z40NQKJ*/ 01420000
*             ELSE                  /* IF NO MESSAGE WANTED  @Z40NQKJ*/ 01421000
*               GO TO RETLABEL;     /* JUST RETURN           @Z40NQKJ*/ 01422000
*           END;                    /*                       @Z40NQKJ*/ 01423000
*                                                                  0465 01424000
*       /*************************************************************/ 01425000
*       /*                                                           */ 01426000
*       /* CHECK FOR PUTLINE ERROR                                   */ 01427000
*       /*                                                           */ 01428000
*       /*************************************************************/ 01429000
*                                                                  0466 01430000
*       IF RETCODE^=0&PNPLMSW=OFF THEN/* WILL ISSUE THE MESSAGE AS 0466 01431000
*                                      WRITE-TO-PROGRAMMER, PLUS TWO    01432000
*                                      ERROR MESSAGES, UNLESS CALLER    01433000
*                                      SAID NOT TO                   */ 01434000
A00090A  CLC   RETCODE,@CF00225                                 DSKC193 01436000
         BNH   RETLABEL                                         DSKC193 01437000
         TM    PNPLMSW(R9),B'00010000'                          DSKC193 01438000
         BNZ   RETLABEL                                         DSKC193 01439000
*         DO;                                                      0467 01440000
*           PLRCER=ON;              /* REMEMBER TO ISSUE ERROR     0468 01441000
*                                      MESSAGES BEFORE EXIT          */ 01442000
*           WTPOVERR=ON;            /* CAN'T ISSUE PUTLINE MESSAGE   */ 01443000
         OI    PLRCER,B'00001001'                                  0469 01444000
*           GO TO WTPMSG;           /* ISSUE AS WRITE-TO-PROGRAMMER  */ 01445000
         B     WTPMSG                                              0470 01446000
*         END;                                                     0471 01447000
*       GO TO RETLABEL;             /* GO TO CLEAN-UP CODE           */ 01448000
         B     RETLABEL                                            0472 01449000
*     END;                                                         0473 01450000
*                                                                  0473 01451000
*   /*****************************************************************/ 01452000
*   /*                                                               */ 01453000
*   /* GET PUTLINE/PUTGET OUTPUT LINE DESCRIPTOR (O.L.D.) BUFFER IF  */ 01454000
*   /* HAVE MORE THAN SINGLE-LEVEL MESSAGE                           */ 01455000
*   /*                                                               */ 01456000
*   /*****************************************************************/ 01457000
*                                                                  0474 01458000
*   REG0=BLDLEN+LENGTH(COREHDR)+LENGTH(CORERTCD);/* AMOUNT OF GOTTEN    01459000
*                                      CORE=LENGTH OF BUFFER       0474 01460000
*                                      BUILT+LENGTH OF POINTERS FOR     01461000
*                                      PUTLINE AND PUTGET (AND WTP)  */ 01462000
@RF00429 LA    R0,16                                            DSKC193 01463000
         AH    R0,BLDLEN                                        DSKC193 01464000
*   GENERATE;                                                      0475 01465000
*                                   /* GET OUTPUT LINE DESCRIPTOR */    01466000
         GETMAIN  R,LV=(0)                                              01467000
*   COREGOTP=REG1;                  /* SAVE ADDRESS OF GOTTEN CORE   */ 01468000
         ST    R1,COREGOTP                                      DSKC193 01469000
*   COREMSG(1:BLDLEN)=BLDBUF(1:BLDLEN);/* MOVE BUFFER INTO CORE    0477 01470000
*                                      GOTTEN                        */ 01471000
         L     R2,COREGOTP                                      DSKC193 01472000
         LH    R6,BLDLEN                                        DSKC193 01473000
         BCTR  R6,0                                             DSKC193 01474000
         EX    R6,@SM00641                                      DSKC193 01475000
*   CORENOW=ADDR(COREMSG);          /* MOVE NEW ADDRESS OF BUFFER  0478 01476000
*                                      INTO CORE GOTTEN              */ 01477000
         LA    R8,COREMSG(,R2)                                  DSKC193 01478000
         ST    R8,CORENOW(,R2)                                  DSKC193 01479000
*   CORESW='00000001'X;             /* SIGNIFY MESSAGE IS IN ONE   0479 01480000
*                                      SEGMENT ONLY                  */ 01481000
*                                                                  0479 01482000
         MVC   CORESW(4,R2),@CB00578                            DSKC193 01483000
*   /*****************************************************************/ 01484000
*   /*                                                               */ 01485000
*   /* SPECIAL LOGIC FOR MULTILEVEL PUTLINE OR WTP                   */ 01486000
*   /*                                                               */ 01487000
*   /*****************************************************************/ 01488000
*                                                                  0480 01489000
*   IF PREVERSW=ON×WTPOVERR=ON×PWTPSW=ON THEN/* ISSUE PUTLINE IF   0480 01490000
*                                      REVERSE MESSAGE SWITCH ON   0480 01491000
*                                      (CODE ALSO USED FOR WTP WITH     01492000
*                                      SECOND LEVEL MESSAGE)         */ 01493000
         TM    PREVERSW(R9),B'01000000'                         DSKC193 01494000
         BO    @RT00480                                            0480 01495000
         TM    WTPOVERR,B'00000001'                                0480 01496000
         BO    @RT00480                                            0480 01497000
         TM    PWTPSW(R9),B'00000010'                           DSKC193 01498000
         BNO   @RF00480                                            0480 01499000
@RT00480 DS    0H                                                  0481 01500000
*     DO;                                                          0481 01501000
*                                                                  0481 01502000
*       /*************************************************************/ 01503000
*       /*                                                           */ 01504000
*       /* SPECIAL PROCESSING IF THE PUTLINE SECOND LEVEL MESSAGE    */ 01505000
*       /* O.L.D. WAS BUILT BY THE CALLER                            */ 01506000
*       /*                                                           */ 01507000
*       /*************************************************************/ 01508000
*                                                                  0482 01509000
*       IF P2OLDSW='1'B&SWLSTMSG='1'B THEN/*                  @Y02668*/ 01510000
         TM    P2OLDSW(R9),B'10000000'                          DSKC193 01511000
         BNO   @RF00482                                            0482 01512000
         TM    SWLSTMSG,B'00100000'                                0482 01513000
         BNO   @RF00482                                            0482 01514000
*         DO;                                                      0483 01515000
*           IF POLDPTR=0 THEN       /* CHECK FOR ZERO O.L.D. POINTER    01516000
*                                      (PARAMETER LIST ERROR) FIRST  */ 01517000
         L     R14,POLDPTR(,R9)                                 DSKC193 01518000
         LTR   R14,R14                                          DSKC193 01519000
         BNZ   @RF00484                                            0484 01520000
*             DO;                                                  0485 01521000
*               OLDPLER=ON;         /* REMEMBER TO ISSUE ERROR MSG   */ 01522000
         OI    OLDPLER,B'00000010'                                 0486 01523000
*               SWMULTLV=OFF;       /* CAN'T ISSUE SECOND LEVEL MSG  */ 01524000
         NI    SWMULTLV,B'01111111'                                0487 01525000
*               GO TO SKIPSW;       /* GO ISSUE FIRST LEVEL MSG      */ 01526000
         B     SKIPSW                                              0488 01527000
*             END;                                                 0489 01528000
*           ELSE                    /* IF PARAMETER LIST O.K.        */ 01529000
*             DO;                                                  0490 01530000
@RF00484 DS    0H                                                  0491 01531000
*               IF OLDNSEG>0        /* IF AT LEAST ONE MSG SEGMENT   */ 01532000
*                   &OSEGLEN>14 THEN/* AND HAVE ROOM FOR THE IKJ   0491 01533000
*                                      MESSAGE ID             @Y02668*/ 01534000
         L     R2,POLDPTR(,R9)                                  DSKC193 01535000
         L     R6,OLDNSEG(,R2)                                  DSKC193 01536000
         LTR   R6,R6                                            DSKC193 01537000
         BNP   @RF00491                                            0491 01538000
         L     R8,OLDSEGP(,R2)                                  DSKC193 01539000
         LH    R14,OSEGLEN(,R8)                                 DSKC193 01540000
         C     R14,@CF00579                                     DSKC193 01541000
         BNH   @RF00491                                            0491 01542000
*                 OSEGTEXT(1:10)=CORETEXT(1:10);/* COPY IKJ MESSAGE     01543000
*                                      ID FROM FIRST LEVEL TO SECOND    01544000
*                                      LEVEL MSG              @Y02668*/ 01545000
         L     R2,COREGOTP                                      DSKC193 01546000
         MVC   OSEGTEXT(10,R8),CORETEXT(R2)                     DSKC193 01547000
*               CORELAST=POLDPTR;   /* POINT THE FIRST LEVEL MSG'S 0493 01548000
*                                      O.L.D. TO THE 2ND LEVEL MSG'S    01549000
*                                      PREFORMATTED O.L.D.    @Y02668*/ 01550000
@RF00491 L     R8,POLDPTR(,R9)                                  DSKC193 01551000
         L     R14,COREGOTP                                     DSKC193 01552000
         ST    R8,CORELAST(,R14)                                DSKC193 01553000
*             END;                                                 0494 01554000
*         END;                                                     0495 01555000
*       ELSE                        /* OTHERWISE IKJEFF02 BUILDS   0496 01556000
*                                      OLD'S FOR BOTH MESSAGES Y02668*/ 01557000
*         CORELAST=OUTADDR;         /* MOVE THE ADDRESS OF PREVIOUS     01558000
*                                      (SECOND LEVEL) CORE GOTTEN  0496 01559000
*                                      INTO THE FIRST LEVEL OUTPUT 0496 01560000
*                                      AREA OR IF IT IS THE SECOND 0496 01561000
*                                      LEVEL MOVE IN 'FF000000'X     */ 01562000
         B     @RC00482                                            0496 01563000
@RF00482 L     R6,OUTADDR                                       DSKC193 01564000
         L     R8,COREGOTP                                      DSKC193 01565000
         ST    R6,CORELAST(,R8)                                 DSKC193 01566000
*       OUTADDR=COREGOTP;           /* SAVE ADDRESS OF LAST GOTTEN 0497 01567000
*                                      CORE FOR EXECUTE FORM OF    0497 01568000
*                                      PUTLINE                       */ 01569000
*                                                                  0497 01570000
@RC00482 L     R2,COREGOTP                                      DSKC193 01571000
         ST    R2,OUTADDR                                       DSKC193 01572000
*       /*************************************************************/ 01573000
*       /*                                                           */ 01574000
*       /* CONTINUE LOOPING IF SECOND LEVEL MESSAGE NOT BUILT YET    */ 01575000
*       /*                                                           */ 01576000
*       /*************************************************************/ 01577000
*                                                                  0498 01578000
*       IF SWLSTMSG='0'B THEN       /* IF A NEXT ID IS FOUND, GO   0498 01579000
*                                      BUILD THAT MESSAGE            */ 01580000
         TM    SWLSTMSG,B'00100000'                                0498 01581000
         BZ    MSGSRCH                                          DSKC193 01582000
*         GO TO MSGSRCH;            /* NOTE - WTP (WRITE TO        0499 01583000
*                                      PROGRAMMER) LOGIC WILL TAKE 0499 01584000
*                                      THIS PATH                     */ 01585000
*PUT2LINE:                                                         0500 01586000
*       REG3=OUTADDR;               /* SET ADDRESS OF OUTPUT LINES 0500 01587000
*                                      FOR PUTLINE                   */ 01588000
PUT2LINE L     R3,OUTADDR                                       DSKC193 01589000
*       GO TO PUTLINE;                                             0501 01590000
         B     PUTLINE                                             0501 01591000
*     END;                                                         0502 01592000
*   RFY                                                            0503 01593000
*    (REG0,                                                        0503 01594000
*     REG1,                                                        0503 01595000
*     REG15) UNRSTD;                                               0503 01596000
@RF00480 DS    0H                                                  0504 01597000
*                                                                  0504 01598000
*   /*****************************************************************/ 01599000
*   /*                                                               */ 01600000
*   /* SPECIAL LOGIC FOR MULTILEVEL PUTGET                           */ 01601000
*   /*                                                               */ 01602000
*   /*****************************************************************/ 01603000
*                                                                  0504 01604000
*   COREGOT(1:4)='FF000000'X;       /* PUT 'FF000000'X INTO FIRST 4     01605000
*                                      BYTES OF LAST CORE GOTTEN TO     01606000
*                                      SHOW IT IS THE LAST CORE    0504 01607000
*                                      GOTTEN - USED IN THE        0504 01608000
*                                      PROCESSING BELOW              */ 01609000
         L     R6,COREGOTP                                      DSKC193 01610000
         MVC   COREGOT(4,R6),@CB00519                           DSKC193 01611000
*   IF SWNFIRST='0'B THEN           /* THIS IS THE FIRST MESSAGE     */ 01612000
         TM    SWNFIRST,B'01000000'                                0505 01613000
         BNZ   @RF00505                                            0505 01614000
*     DO;                                                          0506 01615000
*       SWNFIRST='1'B;              /* THE NEXT MESSAGE WILL NOT BE     01616000
*                                      THE FIRST                     */ 01617000
         OI    SWNFIRST,B'01000000'                                0507 01618000
*       OUTADDR=COREGOTP;           /* SAVE ADDRESS OF FIRST O.L.D.     01619000
*                                      FOR PUTLINE AND PUTGET EXECUTE   01620000
*                                      FORM OF MACRO                 */ 01621000
         ST    R6,OUTADDR                                       DSKC193 01622000
*       CORESAVE=COREGOTP;          /* SAVE THE ADDRESS OF THE LAST     01623000
*                                      GOTTEN CORE, TO USE IN      0509 01624000
*                                      CHAINING THE NEXT ONE         */ 01625000
         ST    R6,CORESAVE                                      DSKC193 01626000
*       GO TO MSGSRCH;              /* LOOK FOR NEXT MESSAGE ID      */ 01627000
         B     MSGSRCH                                             0510 01628000
*     END;                                                         0511 01629000
*   CORESAVE->CORELAST=COREGOTP;                                   0512 01630000
@RF00505 L     R8,COREGOTP                                      DSKC193 01631000
         L     R2,CORESAVE                                      DSKC193 01632000
         ST    R8,CORELAST(,R2)                                 DSKC193 01633000
*   CORESAVE=COREGOTP;              /* GO TO LAST MESSAGE BUILT - PUT   01634000
*                                      ITS ADDRESS IN THE FIRST 4  0513 01635000
*                                      BYTES OF THE PREVIOUS MESSAGE */ 01636000
*                                                                  0513 01637000
         ST    R8,CORESAVE                                      DSKC193 01638000
*   /*****************************************************************/ 01639000
*   /*                                                               */ 01640000
*   /* CONTINUE PROCESSING LEVELS OF MESSAGES UNTIL MESSAGE          */ 01641000
*   /* COMPLETELY BUILT                                              */ 01642000
*   /*                                                               */ 01643000
*   /*****************************************************************/ 01644000
*                                                                  0514 01645000
*   IF SWLSTMSG='0'B THEN           /* IF THIS IS NOT LAST, GO BUILD    01646000
*                                      NEXT                          */ 01647000
         TM    SWLSTMSG,B'00100000'                                0514 01648000
         BZ    MSGSRCH                                          DSKC193 01649000
*     GO TO MSGSRCH;                                               0515 01650000
*                                                                  0515 01651000
*   /*****************************************************************/ 01652000
*   /*                                                               */ 01653000
*   /* ISSUE PUTGET                                                  */ 01654000
*   /*                                                               */ 01655000
*   /*****************************************************************/ 01656000
*                                                                  0516 01657000
*PTGTMSG:                                                          0516 01658000
*   SAVEPAR(1:16)=PUTGETLL;         /* PUT LIST FORM OF PUTGET MACRO    01659000
*                                      IN PARAMETER LIST FOR EXECUTE    01660000
*                                      FORM                          */ 01661000
PTGTMSG  MVC   SAVEPAR(16),PUTGETLL                                0516 01662000
*   REG3=OUTADDR;                   /* POINT TO FIRST-LEVEL O.L.D.   */ 01663000
         L     R3,OUTADDR                                       DSKC193 01664000
*                                                                  0518 01665000
*   /*****************************************************************/ 01666000
*   /*                                                               */ 01667000
*   /* CHANGE KEY IF NECESSARY                                       */ 01668000
*   /*                                                               */ 01669000
*   /*****************************************************************/ 01670000
*                                                                  0518 01671000
*   IF PKEY1SW='1'B THEN            /* NEED TO BE IN KEY 0 OR @Y02656*/ 01672000
         TM    PKEY1SW(R9),B'00001000'                          DSKC193 01673000
         BNO   @RF00518                                            0518 01674000
*     GEN;                                                         0519 01675000
*                                   /* 8 TO ISSUE 2-LEVEL MSG @Y02656*/ 01676000
TOKEY0B  MODESET EXTKEY=SUPR,RELATED=(KEY0,IKJEFF02(TOKEY1B))   @Y02656 01677000
*                                   CHANGE TO KEY 0             @Y02656 01678000
*     GENERATE;                                                    0520 01679000
@RF00518 DS    0H                                                  0520 01680000
         PUTGET OUTPUT=((R3),MULTLVL),MF=(E,PUTPTRS)            DSKC193 01681000
*     RFY                                                          0521 01682000
*       REG15 RSTD;                                                0521 01683000
*   RETCODE=REG15;                  /* SAVE RETURN CODE              */ 01684000
         ST    R15,RETCODE                                      DSKC193 01685000
*   RFY                                                            0523 01686000
*     REG15 UNRSTD;                                                0523 01687000
*   IF PKEY1SW='1'B THEN            /* CHANGE BACK TO KEY 1   @Y02656*/ 01688000
         TM    PKEY1SW(R9),B'00001000'                          DSKC193 01689000
         BNO   @RF00524                                            0524 01690000
*     GEN;                                                         0525 01691000
*                                                                  0525 01692000
*                                   /* (AFTER ISSUE PUTGET)   @Y02656*/ 01693000
TOKEY1B  MODESET EXTKEY=SCHED,RELATED=(KEY1,IKJEFF02(TOKEY0B))  @Y02656 01694000
*                                   CHANGE FROM KEY 0 TO KEY 1  @Y02656 01695000
*     /***************************************************************/ 01696000
*     /*                                                             */ 01697000
*     /* CHECK FOR PUTGET ERROR                                      */ 01698000
*     /*                                                             */ 01699000
*     /***************************************************************/ 01700000
*                                                                  0526 01701000
*     IF RETCODE^=0 THEN                                           0526 01702000
@RF00524 L     R6,RETCODE                                       DSKC193 01703000
         LTR   R6,R6                                            DSKC193 01704000
         BZ    @RF00526                                            0526 01705000
*       DO;                                                        0527 01706000
*         IF PPGMSW=OFF THEN        /* IF CALLER DOESN'T WANT A    0528 01707000
*                                      PUTGET ERROR MESSAGE          */ 01708000
         TM    PPGMSW(R9),B'00001000'                           DSKC193 01709000
         BZ    RETLABEL                                         DSKC193 01710000
*           GO TO RETLABEL;         /* WILL CLEAN-UP AND TERMINATE   */ 01711000
*         PGRCER=ON;                /* REMEMBER TO ISSUE ERROR     0530 01712000
*                                      MESSAGE AFTER ISSUE FIRST   0530 01713000
*                                      LEVEL OF PUTGET MESSAGE AS  0530 01714000
*                                      PUTLINE                       */ 01715000
         OI    PGRCER,B'00000100'                                  0530 01716000
*         PGRETCD=RETCODE;          /* SAVE PUTGET R.C. HERE (RETCODE   01717000
*                                      BECOMES PUTLINE R.C.)         */ 01718000
         ST    R6,PGRETCD                                       DSKC193 01719000
*         SWMULTLV=OFF;             /* WON'T ISSUE OTHER LEVELS      */ 01720000
         NI    SWMULTLV,B'01111111'                                0532 01721000
*         COREGOTP=OUTADDR;         /* POINT TO O.L.D. FOR FIRST   0533 01722000
*                                      LEVEL MESSAGE                 */ 01723000
         L     R8,OUTADDR                                       DSKC193 01724000
         ST    R8,COREGOTP                                      DSKC193 01725000
*         TEMP=LENGTH(BLDBUF)-(LENGTH(BLDAREA)-CORELEN);/* GET LENGTH   01726000
*                                      FOR MOVE INTO BLDBUF (DON'T 0534 01727000
*                                      MOVE CORERTCD)                */ 01728000
         LH    R2,CORELEN(,R8)                                  DSKC193 01729000
         SL    R2,@CF00609                                      DSKC193 01730000
         AL    R2,@CF00611                                      DSKC193 01731000
         ST    R2,TEMP                                          DSKC193 01732000
*         BLDBUF(1:TEMP)=COREMSG(1:TEMP);/* COPY FIRST LEVEL TEXT    */ 01733000
         BCTR  R2,0                                             DSKC193 01734000
         EX    R2,@SM00644                                      DSKC193 01735000
*         GO TO SKIPSW;             /* ISSUE FIRST LEVEL MESSAGE TEXT   01736000
*                                      AS PUTLINE AND DON'T RETURN   */ 01737000
         B     SKIPSW                                              0536 01738000
*       END;                                                       0537 01739000
*                                                                  0537 01740000
*   /*****************************************************************/ 01741000
*   /*                                                               */ 01742000
*   /* GET CORE FOR REPLY BUFFER IF PUTGET WAS SUCCESSFUL            */ 01743000
*   /*                                                               */ 01744000
*   /*****************************************************************/ 01745000
*                                                                  0538 01746000
*   RFY                                                            0538 01747000
*     REG7 RSTD;                                                   0538 01748000
@RF00526 DS    0H                                                  0539 01749000
*   REG3=INLEN;                     /* SAVE PUTGET BUFFER LENGTH     */ 01750000
         SLR   R6,R6                                            DSKC193 01751000
         ICM   R6,7,INBUFP                                      DSKC193 01751010
         LH    R3,INLEN(,R6)                                    DSKC193 01752000
*   REG7=REG3-2;                    /* SET SIZE TO GET FOR A BUFFER     01753000
*                                      TO BE RETURNED TO CALLER      */ 01754000
         LR    R7,R3                                            DSKC193 01755000
         BCTR  R7,0                                             DSKC193 01756000
         BCTR  R7,0                                             DSKC193 01757000
*   RFY                                                            0541 01758000
*    (REG0,                                                        0541 01759000
*     REG1) RSTD;                                                  0541 01760000
*   REG0=REG7;                                                     0542 01761000
         LR    R0,R7                                            DSKC193 01762000
*   GENERATE;                                                      0543 01763000
         GETMAIN  R,LV=(0)                                              01764000
*   PRETEXTP=REG1;                  /* SET ADDRESS OF TEXT RETURNED  */ 01765000
         STCM  R1,7,PRETEXTP(R9)                                DSKC193 01766000
*   PRELEN=REG7;                    /* SET LENGTH RETURNED           */ 01768000
         STH   R7,PRELEN(,R1)                                   DSKC193 01769000
*   REG7=REG7-2;                                                   0546 01770000
*                                                                  0546 01771000
         BCTR  R7,0                                             DSKC193 01772000
         BCTR  R7,0                                             DSKC193 01773000
*   /*****************************************************************/ 01774000
*   /*                                                               */ 01775000
*   /* COPY REPLY INFO FROM PUTGET BUFFER TO NEW BUFFER              */ 01776000
*   /*                                                               */ 01777000
*   /*****************************************************************/ 01778000
*                                                                  0547 01779000
*   IF REG7^=0                      /* IF THERE IS ANYTHING          */ 01780000
*     THEN                          /* TO MOVE THEN MOVE TO          */ 01781000
         LTR   R7,R7                                            DSKC193 01782000
         BZ    @RF00547                                            0547 01783000
*     DO;                           /* OUR OWN AREA                  */ 01784000
*       PRETEXT(1:REG7)=INTEXT(1:REG7);                            0549 01785000
*                                                                  0549 01786000
         LR    R8,R7                                            DSKC193 01787000
         BCTR  R8,0                                             DSKC193 01788000
         SLR   R2,R2                                            DSKC193 01789000
         ICM   R2,7,INBUFP                                      DSKC193 01789010
         EX    R8,@SM00646                                      DSKC193 01790000
*       /*************************************************************/ 01791000
*       /*                                                           */ 01792000
*       /* CONVERT REPLY TEXT TO UPPER CASE                          */ 01793000
*       /*                                                           */ 01794000
*       /*************************************************************/ 01795000
*                                                                  0550 01796000
*       DO REG7=REG7 TO 1 BY-1;                                    0550 01797000
         B     @DE00550                                            0550 01798000
@DL00550 DS    0H                                                  0551 01799000
*         PREHIGH='1'B;             /* SET 2ND BIT OF EACH CHARACTER */ 01800000
         OI    PREHIGH(R1),B'01000000'                          DSKC193 01801000
*         REG1=REG1+1;              /* ON TO CONVERT TO UPPER CASE   */ 01802000
         AL    R1,@CF00035                                      DSKC193 01803000
*       END;                                                       0553 01804000
         BCTR  R7,0                                             DSKC193 01805000
@DE00550 LTR   R7,R7                                            DSKC193 01806000
         BP    @DL00550                                            0553 01807000
*     END;                                                         0554 01808000
*   RFY                                                            0555 01809000
*     REG7 UNRSTD;                                                 0555 01810000
*                                                                  0555 01811000
@RF00547 DS    0H                                                  0556 01812000
*   /*****************************************************************/ 01813000
*   /*                                                               */ 01814000
*   /* FREE THE PUTGET BUFFER                                        */ 01815000
*   /*                                                               */ 01816000
*   /*****************************************************************/ 01817000
*                                                                  0556 01818000
*   REG1=INBUFP;                    /* SET ADDRESS OF AREA TO BE   0556 01819000
*                                      FREED                         */ 01820000
         SLR   R1,R1                                            DSKC193 01821000
         ICM   R1,7,INBUFP                                      DSKC193 01822000
*   REG0=REG3×'01000000'X;          /* SET LENGTH SET SUBPOOL TO 1   */ 01823000
         LR    R0,R3                                            DSKC193 01824000
         O     R0,@CF00583                                      DSKC193 01825000
*   GENERATE;                                                      0558 01826000
*                                                                  0558 01827000
         FREEMAIN  R,LV=(0),A=(1)                                       01828000
*   /*****************************************************************/ 01829000
*   /*                                                               */ 01830000
*   /* CLEAN UP AND RETURN TO CALLER                                 */ 01831000
*   /*                                                               */ 01832000
*   /*****************************************************************/ 01833000
*                                                                  0559 01834000
*RETLABEL:                          /* FREE O.L.D.'S HERE            */ 01835000
*   REG1=OUTADDR;                                                  0559 01836000
RETLABEL L     R1,OUTADDR                                       DSKC193 01837000
*   GEN(LA 1,0(1));                 /* ZERO OUT HIGH-ORDER BYTE      */ 01838000
*                                                                  0560 01839000
         LA    R1,0(R1)                                         DSKC193 01840000
*   /*****************************************************************/ 01841000
*   /*                                                               */ 01842000
*   /* FREE O.L.D. CONTROL BLOCKS, IF NECESSARY                      */ 01843000
*   /*                                                               */ 01844000
*   /*****************************************************************/ 01845000
*                                                                  0561 01846000
*   IF REG1^=0 THEN                                                0561 01847000
         LTR   R1,R1                                            DSKC193 01848000
         BZ    @RF00561                                            0561 01849000
*     DO;                                                          0562 01850000
*       REG0=REG1->CORELEN+LENGTH(COREHDR)+LENGTH(CORERTCD);/* FREE     01851000
*                                      AMOUNT OF CORE FOR GETMAIN OF    01852000
*                                      O.L.D.                        */ 01853000
         LA    R0,16                                            DSKC193 01854000
         AH    R0,CORELEN(,R1)                                  DSKC193 01855000
*       OUTADDR=REG1->CORELAST;                                    0564 01856000
         L     R8,CORELAST(,R1)                                 DSKC193 01857000
         ST    R8,OUTADDR                                       DSKC193 01858000
*       GEN(FREEMAIN R,LV=(0),A=(1));/* FREE O.L.D. FOR FIRST LEVEL     01859000
*                                      MESSAGE                       */ 01860000
         FREEMAIN R,LV=(0),A=(1)                                        01861000
*       IF P2OLDSW='1'B THEN        /* DON'T FREE SECOND LEVEL MSG 0566 01862000
*                                      O.L.D. IF SUPPLIED BY CALLER -   01863000
*                                                             @Y02668*/ 01864000
         TM    P2OLDSW(R9),B'10000000'                          DSKC193 01865000
         BNO   RETLABEL                                         DSKC193 01866000
*         OUTADDR=0;                                               0567 01867000
         SLR   R2,R2                                            DSKC193 01868000
         ST    R2,OUTADDR                                       DSKC193 01869000
*       GO TO RETLABEL;             /* CONTINUE LOOP                 */ 01870000
         B     RETLABEL                                            0568 01871000
*     END;                                                         0569 01872000
*   RFY                                                            0570 01873000
*    (REG0,                                                        0570 01874000
*     REG1) UNRSTD;                                                0570 01875000
*                                                                  0570 01876000
@RF00561 DS    0H                                                  0571 01877000
*   /*****************************************************************/ 01878000
*   /*                                                               */ 01879000
*   /* ISSUE PARAMETER LIST OR I/O ERROR MESSAGE, IF NEEDED          */ 01880000
*   /*                                                               */ 01881000
*   /*****************************************************************/ 01882000
*                                                                  0571 01883000
*   IF ERRORSWS^='0000000000000000'B THEN                          0571 01884000
         CLC   ERRORSWS(2),@CB00585                                0571 01885000
         BE    @RF00571                                            0571 01886000
*     CALL EMSGPROC;                /* SET UP AND ISSUE ERROR MESSAGE*/ 01887000
         BAL   R14,EMSGPROC                                     DSKC193 01888000
*ERRRET:                            /* RETURN HERE AFTER CALL      0573 01889000
*                                      EMSGPROC                      */ 01890000
*   RETURN CODE(RETCODE);           /* RETURN TO CALLER WITH       0573 01891000
*                                      APPROPRIATE RETURN CODE       */ 01892000
@RF00571 DS    0H                                                  0573 01893000
ERRRET   L     R2,RETCODE                                       DSKC193 01894000
         L     R13,4(,R13)                                      DSKC193 01895000
         L     R0,@SIZDATD                                      DSKC193 01896000
         LR    R1,R10                                           DSKC193 01897000
         FREEMAIN R,LV=(0),A=(1)                                        01898000
         LR    R15,R2                                           DSKC193 01899000
         L     R14,12(,R13)                                     DSKC193 01900000
         LM    R0,R12,20(R13)                                   DSKC193 01901000
         BR    R14                                              DSKC193 01902000
*                                                                  0574 01903000
*/********************************************************************/ 01904000
*/*                                                                  */ 01905000
*/*  EMSGPROC INTERNAL PROCEDURE                                     */ 01906000
*/*    - SETS UP IKJEFFMT PARAMETER LIST FOR THE FOLLOWING CASES:    */ 01907000
*/*        PTRPLER, BAD POINTER TO PARMLIST                  MSG 02A */ 01908000
*/*        PCPPLER, ZERO CPPL POINTER IF PUTLINE/PUTGET      MSG 02A */ 01909000
*/*        MCPLER,  ZERO POINTER TO MESSAGE CSECT            MSG 02A */ 01910000
*/*        MIDPLER, NO MATCH FOR MESSAGE ID IN MESSAGE CSECT MSG 02A */ 01911000
*/*        OLDPLER, ZERO O.L.D. POINTER WHEN P2OLDSW ON      MSG 02A */ 01912000
*/*        PLRCER,  PUTLINE RETURNED AN ERROR CODE           MSG 02A */ 01913000
*/*        PGRCER,  PUTGET RETURNED AN ERROR CODE            MSG 02B */ 01914000
*/*        EXTRCTER, NO FIRST EXTRACT BUFFER FROM CALLER     MSG 02C */ 01915000
*/*        EXTRCTR2, NO SECOND EXTRACT BUFFER FROM CALLER    MSG 02C */ 01916000
*/*        EXTRCTR3, ONLY SECOND EXTRACT REQUESTED           MSG 02C */ 01917000
*/*    - CALLS IKJEFF02 TO ISSUE EACH ERROR MESSAGE.                 */ 01918000
*/*    - FOR PLRCER, ALSO CALLS IKJEFF19 TO ISSUE FAILURE MESSAGE.   */ 01919000
*/*    - RETURNS TO CALLER, WHICH SHOULD THEN GO TO ERRRET LABEL.    */ 01920000
*/*                                                                  */ 01921000
*/********************************************************************/ 01922000
*                                                                  0574 01923000
*EMSGPROC:                                                         0574 01924000
*   PROC;                                                          0574 01925000
EMSGPROC STM   R14,R12,@SA00002                                 DSKC193 01932000
*   IF PLRCER=OFF&PGRCER=OFF THEN   /* IF NOT PUTLINE OR PUTGET ERROR   01933000
*                                      CASE                          */ 01934000
         TM    PLRCER,B'00001100'                                  0575 01935000
         BNZ   @RF00575                                            0575 01936000
*     RETCODE=76;                   /* PASS CALLER THE CODE FOR    0576 01937000
*                                      PARAMETER LIST ERROR          */ 01938000
*                                                                  0576 01939000
         MVC   RETCODE(4),@CF00591                                 0576 01940000
*   /*****************************************************************/ 01941000
*   /*                                                               */ 01942000
*   /* INITIALIZE IKJEFFMT PARAMETER LIST                            */ 01943000
*   /*                                                               */ 01944000
*   /*****************************************************************/ 01945000
*                                                                  0577 01946000
*   MSGTABLE=''X;                   /* ZERO OUT OWN PARMLIST FOR   0577 01947000
*                                      IKJEFF02 (DON'T CHANGE      0577 01948000
*                                      CALLER'S                      */ 01949000
@RF00575 XC    MSGTABLE(56),MSGTABLE                               0577 01950000
*   LISTPTR=ADDR(MSGCSECT);                                        0578 01951000
         LA    R8,MSGCSECT                                      DSKC193 01952000
         ST    R8,LISTPTR                                       DSKC193 01953000
*   MTCPPL=ADDR(TMCT);              /* COPY INFO FROM CALLER PARMLIST*/ 01954000
         L     R2,@PC00001+4                                    DSKC193 01955000
         ST    R2,MTCPPL                                        DSKC193 01956000
*   ECBPTR=ADDR(COMECB);                                           0580 01957000
         L     R8,@PC00001+8                                    DSKC193 01958000
         ST    R8,ECBPTR                                        DSKC193 01959000
*   MTHIGH=ON;                                                     0581 01960000
         OI    MTHIGH,B'10000000'                                  0581 01961000
*   MSGCSECT=ADDR(IKJEFF2M);        /* POINT TO IKJEFF02'S OWN     0582 01962000
*                                      MESSAGE CSECT                 */ 01963000
         L     R2,@CV00072                                      DSKC193 01964000
         ST    R2,MSGCSECT                                      DSKC193 01965000
*   IF PTRPLER=OFF&PWTOSW=OFF&PWTPSW=OFF&PCPPLER=OFF&PLRCER=OFF THEN    01966000
         TM    PTRPLER,B'10000000'                                 0583 01967000
         BNZ   @RF00583                                            0583 01968000
         TM    PWTOSW(R9),B'00100010'                           DSKC193 01969000
         BNZ   @RF00583                                            0583 01970000
         TM    PCPPLER,B'00101000'                                 0583 01971000
         BNZ   @RF00583                                            0583 01972000
*                                   /* CHECK WHETHER ISSUE PUTLINE   */ 01973000
*     DO;                                                          0584 01974000
*       MTPUTLSW=ON;                                               0585 01975000
         OI    MTPUTLSW,B'01000000'                                0585 01976000
*       IF PKEY1SW=ON THEN          /* KEEP SAME KEY SETTING AS    0586 01977000
*                                      CALLER HAD IN PARMLIST        */ 01978000
         TM    PKEY1SW(R9),B'00001000'                          DSKC193 01979000
         BNO   @RC00583                                         DSKC193 01980000
*         MTKEY1SW=ON;                                             0587 01981000
         OI    MTKEY1SW,B'00001000'                                0587 01982000
*     END;                                                         0588 01983000
*   ELSE                            /* ELSE DO WRITE-TO-PROGRAMMER   */ 01984000
*     DO;                                                          0589 01985000
         B     @RC00583                                            0589 01986000
@RF00583 DS    0H                                                  0590 01987000
*       MTWTPSW=ON;                                                0590 01988000
         OI    MTWTPSW,B'00000010'                                 0590 01989000
*       MTDOMSW=ON;                 /* DON'T KEEP MESSAGE ON TUBE    */ 01990000
         OI    MTDOMSW,B'01000000'                                 0591 01991000
*     END;                                                         0592 01992000
*   MTHEXSW=ON;                     /* MIGHT CONVERT MESSAGE ID TO 0593 01993000
*                                      PRINTABLE HEX                 */ 01994000
@RC00583 OI    MTHEXSW,B'00010000'                                 0593 01995000
*   MSGID='M02D';                   /* SET UP GENERAL ERROR  @Z40GQKU   01996000
*                                      MESSAGE               @Z40GQKU*/ 01997000
         MVC   MSGID(4),@CC00592                                   0594 01998000
*   RFY                                                            0595 01999000
*     REG1 RSTD;                                                   0595 02000000
*   REG1=ADDR(MSGTABLE);            /* STANDARD LINKAGE              */ 02001000
         LA    R1,MSGTABLE                                      DSKC193 02002000
*   CALL IKJEFF02;                  /*                       @Z40GQKU*/ 02003000
         L     R15,@CA00028                                     DSKC193 02004000
         BALR  R14,R15                                          DSKC193 02005000
*   MSGID='M02A';                   /* RESET GENERAL ERROR   @Z40GQKU   02006000
*                                      MESSAGE               @Z40GQKU*/ 02007000
*                                                                  0598 02008000
         MVC   MSGID(4),@CC00593                                   0598 02009000
*   /*****************************************************************/ 02010000
*   /*                                                               */ 02011000
*   /* SET UP THE APPROPRIATE MESSAGE TEXT FOR EACH PARAMETER LIST   */ 02012000
*   /* ERROR, AND ISSUE APPROPRIATE MESSAGE(S)                       */ 02013000
*   /*                                                               */ 02014000
*   /*****************************************************************/ 02015000
*                                                                  0599 02016000
*   MTLEN(2)=LENGTH(TMSGID);        /* <INSERT MESSAGE ID>           */ 02017000
         MVI   MTLEN+4,X'04'                                       0599 02018000
*   MTADDR(2)=ADDR(PMSGID);                                        0600 02019000
         LA    R0,PMSGID(,R9)                                   DSKC193 02020000
         STCM  R0,7,MTADDR+4                                    DSKC193 02021000
*   IF PMSGID(1)<'C1'X THEN         /* CONVERT MESSAGE ID TO       0601 02023000
*                                      PRINTABLE HEX IF IT DOESN'T 0601 02024000
*                                      START WITH CHARACTER OR NUMBER*/ 02025000
         CLI   PMSGID(R9),X'C1'                                 DSKC193 02026000
         BNL   @RF00601                                            0601 02027000
*     MTHIGHL(2)=ON;                                               0602 02028000
         OI    MTHIGHL+4,B'10000000'                               0602 02029000
*   IF MCPLER=ON×MIDPLER=ON THEN    /* THESE MESSAGE ID ERRORS ARE 0603 02030000
*                                      MUTUALLY EXCLUSIVE            */ 02031000
@RF00601 TM    MCPLER,B'01010000'                                  0603 02032000
         BZ    @RF00603                                            0603 02033000
*     DO;                                                          0604 02034000
*       MTLEN(1)=LENGTH(IN02A1A);   /* UNABLE TO ISSUE MESSAGE       */ 02035000
         MVI   MTLEN,X'07'                                         0605 02036000
*       MTADDR(1)=ADDR(IN02A1A);    /* 'WITH ID'                     */ 02037000
         LA    R2,IN02A1A                                       DSKC193 02038000
         STCM  R2,7,MTADDR                                      DSKC193 02039000
*       IF MCPLER=ON THEN           /* 'ZERO POINTER TO MSG CSECT'   */ 02041000
         TM    MCPLER,B'01000000'                                  0607 02042000
         BNO   @RF00607                                            0607 02043000
*         DO;                                                      0608 02044000
*           MTLEN(3)=LENGTH(IN02A3B);                              0609 02045000
         MVI   MTLEN+8,X'1D'                                       0609 02046000
*           MTADDR(3)=ADDR(IN02A3B);                               0610 02047000
         LA    R0,IN02A3B                                       DSKC193 02048000
         STCM  R0,7,MTADDR+8                                    DSKC193 02049000
*         END;                                                     0611 02051000
*       ELSE                        /* MUST BE MIDPLER ON            */ 02052000
*         DO;                       /* 'ID NOT FOUND IN MSG CSECT'   */ 02053000
         B     @RC00607                                            0612 02054000
@RF00607 DS    0H                                                  0613 02055000
*           MTLEN(3)=LENGTH(IN02A3D);                              0613 02056000
         MVI   MTLEN+8,X'1D'                                       0613 02057000
*           MTADDR(3)=ADDR(IN02A3D);                               0614 02058000
         LA    R2,IN02A3D                                       DSKC193 02059000
         STCM  R2,7,MTADDR+8                                    DSKC193 02060000
*         END;                                                     0615 02062000
*       CALL IKJEFF02;              /* ISSUE THIS ERROR MESSAGE      */ 02063000
@RC00607 L     R15,@CA00028                                     DSKC193 02064000
         BALR  R14,R15                                          DSKC193 02065000
*     END;                                                         0617 02066000
*                                                                  0617 02067000
*   /*****************************************************************/ 02068000
*   /*                                                               */ 02069000
*   /* EXTRACT ERROR MESSAGE HANDLING                        @Z40GQKU*/ 02070000
*   /*                                                               */ 02071000
*   /*****************************************************************/ 02072000
*                                                                  0618 02073000
*   IF EXTRCTER=ON×                 /* IF EITHER BUFFER      @Z40GQKU*/ 02074000
*       EXTRCTR2=ON×                /* MISSING OR ONLY SEC   @Z40GQKU*/ 02075000
*       EXTRCTR3=ON THEN            /* BFR EXTRACT THE       @Z40GQKU   02076000
*                                      REQUESTED, THEN ERROR @Z40GQKU*/ 02077000
@RF00603 TM    EXTRCTER,B'11100000'                                0618 02078000
         BZ    @RF00618                                            0618 02079000
*     DO;                                                          0619 02080000
*       MSGID='M02C';               /* SET POINTER TO        @Z40GQKU   02081000
*                                      MESSAGE TO PUT OUT    @Z40GQKU*/ 02082000
         MVC   MSGID(4),@CC00595                                   0620 02083000
*       IF EXTRCTER=ON THEN         /* IF FIRST BUFFER       @Z40GQKU   02084000
*                                      MISSING               @Z40GQKU*/ 02085000
         TM    EXTRCTER,B'10000000'                                0621 02086000
         BNO   @RF00621                                            0621 02087000
*         DO;                       /* THEN                  @Z40GQKU*/ 02088000
*           MTLEN(1)=LENGTH(IN02A3H);/* SET LENGTH AND PTR TO      0623 02089000
*                                                            @Z40GQKU*/ 02090000
         MVI   MTLEN,X'1A'                                         0623 02091000
*           MTADDR(1)=ADDR(IN02A3H);/* FIRST BFR ERR MSG     @Z40GQKU*/ 02092000
         LA    R0,IN02A3H                                       DSKC193 02093000
         STCM  R0,7,MTADDR                                      DSKC193 02094000
*         END;                      /*                       @Z40GQKU*/ 02096000
*       ELSE                        /* HOWEVER, IF NOT FIRST @Z40GQKU   02097000
*                                      THEN TRY FOR SECOND   @Z40GQKU*/ 02098000
*         IF EXTRCTR2=ON THEN       /* IF SEC BUFFER NOT     @Z40GQKU   02099000
*                                      THERE SET THOSE PTRS  @Z40GQKU*/ 02100000
         B     @RC00621                                            0626 02101000
@RF00621 TM    EXTRCTR2,B'01000000'                                0626 02102000
         BNO   @RF00626                                            0626 02103000
*           DO;                     /*                       @Z40GQKU*/ 02104000
*             MTLEN(1)=LENGTH(IN02A3J);/* POINT TO ERROR     @Z40GQKU*/ 02105000
         MVI   MTLEN,X'1B'                                         0628 02106000
*             MTADDR(1)=ADDR(IN02A3J);/* MESSAGE INSERTS     @Z40GQKU*/ 02107000
         LA    R2,IN02A3J                                       DSKC193 02108000
         STCM  R2,7,MTADDR                                      DSKC193 02109000
*           END;                    /*                       @Z40GQKU*/ 02111000
*         ELSE                      /* IF NEITHER ONE OF THE @Z40GQKU   02112000
*                                      ABOVE, REQUEST ERROR  @Z40GQKU*/ 02113000
*           DO;                     /* THEN                  @Z40GQKU*/ 02114000
         B     @RC00626                                            0631 02115000
@RF00626 DS    0H                                                  0632 02116000
*             MTLEN(1)=LENGTH(IN02A3K);/* POINT TO ONLY SEC  @Z40GQKU*/ 02117000
         MVI   MTLEN,X'19'                                         0632 02118000
*             MTADDR(1)=ADDR(IN02A3K);/* LEVEL REQUEST ERR   @Z40GQKU*/ 02119000
         LA    R0,IN02A3K                                       DSKC193 02120000
         STCM  R0,7,MTADDR                                      DSKC193 02121000
*           END;                    /*                       @Z40GQKU*/ 02123000
*       CALL IKJEFF02;              /* PUT OUT MESSAGE       @Z40GQKU*/ 02124000
@RC00626 DS    0H                                                  0635 02125000
@RC00621 L     R15,@CA00028                                     DSKC193 02126000
         BALR  R14,R15                                          DSKC193 02127000
*       MSGID='M02A';               /* RESET MESSAGE PTR     @Z40GQKU*/ 02128000
         MVC   MSGID(4),@CC00593                                   0636 02129000
*     END;                          /*                       @Z40GQKU*/ 02130000
*   IF OLDPLER=ON THEN              /* 'INCOMPATIBLE PARAMETERS'     */ 02131000
@RF00618 TM    OLDPLER,B'00000010'                                 0638 02132000
         BNO   @RF00638                                            0638 02133000
*     DO;                                                          0639 02134000
*       MTLEN(1)=LENGTH(IN02A1D);   /* UNABLE TO ISSUE MESSAGE       */ 02135000
         MVI   MTLEN,X'13'                                         0640 02136000
*       MTADDR(1)=ADDR(IN02A1D);    /* 'WITH A SECOND LEVEL'         */ 02137000
         LA    R0,IN02A1D                                       DSKC193 02138000
         STCM  R0,7,MTADDR                                      DSKC193 02139000
*       MTLEN(3)=LENGTH(IN02A3F);                                  0642 02141000
         MVI   MTLEN+8,X'40'                                       0642 02142000
*       MTADDR(3)=ADDR(IN02A3F);                                   0643 02143000
         LA    R2,IN02A3F                                       DSKC193 02144000
         STCM  R2,7,MTADDR+8                                    DSKC193 02145000
*       CALL IKJEFF02;              /* ISSUE THIS ERROR MESSAGE      */ 02147000
         L     R15,@CA00028                                     DSKC193 02148000
         BALR  R14,R15                                          DSKC193 02149000
*     END;                                                         0645 02150000
*   IF PCPPLER=ON THEN              /* IF ZERO CPPL PTR WHEN PUTLINE */ 02151000
@RF00638 TM    PCPPLER,B'00100000'                                 0646 02152000
         BNO   @RF00646                                            0646 02153000
*     DO;                                                          0647 02154000
*       MTLEN(1)=LENGTH(IN02A1B);   /* UNABLE TO ISSUE MESSAGE       */ 02155000
         MVI   MTLEN,X'0B'                                         0648 02156000
*       MTADDR(1)=ADDR(IN02A1B);    /* 'TO TERMINAL'                 */ 02157000
         LA    R0,IN02A1B                                       DSKC193 02158000
         STCM  R0,7,MTADDR                                      DSKC193 02159000
*       MTLEN(3)=LENGTH(IN02A3C);   /* ERROR DESCRIPTION             */ 02161000
         MVI   MTLEN+8,X'25'                                       0650 02162000
*       MTADDR(3)=ADDR(IN02A3C);                                   0651 02163000
         LA    R2,IN02A3C                                       DSKC193 02164000
         STCM  R2,7,MTADDR+8                                    DSKC193 02165000
*       CALL IKJEFF02;              /* REENTER 02 TO PROCESS MESSAGE */ 02167000
         L     R15,@CA00028                                     DSKC193 02168000
         BALR  R14,R15                                          DSKC193 02169000
*     END;                          /* (NOTE OTHER ERRORS COULD HAVE    02170000
*                                      BEEN DETECTED, SO DON'T HAVE     02171000
*                                      AN ELSE STATEMENT)            */ 02172000
*   IF PTRPLER=ON THEN              /* 'UNABLE TO ISSUE MESSAGE'     */ 02173000
@RF00646 TM    PTRPLER,B'10000000'                                 0654 02174000
         BNO   @RF00654                                            0654 02175000
*     DO;                           /* BECAUSE                       */ 02176000
*       MTLEN(3)=LENGTH(IN02A3A);   /* 'ZERO PARAMETER LIST PTR'     */ 02177000
         MVI   MTLEN+8,X'32'                                       0656 02178000
*       MTADDR(3)=ADDR(IN02A3A);                                   0657 02179000
         LA    R0,IN02A3A                                       DSKC193 02180000
         STCM  R0,7,MTADDR+8                                    DSKC193 02181000
*       CALL IKJEFF02;              /* ISSUE THIS ERROR MESSAGE      */ 02183000
         L     R15,@CA00028                                     DSKC193 02184000
         BALR  R14,R15                                          DSKC193 02185000
*     END;                                                         0659 02186000
*                                                                  0659 02187000
*   /*****************************************************************/ 02188000
*   /*                                                               */ 02189000
*   /* SET UP AND ISSUE PUTGET ERROR MESSAGES                        */ 02190000
*   /*                                                               */ 02191000
*   /*****************************************************************/ 02192000
*                                                                  0660 02193000
*   IF PGRCER=ON THEN               /* 'UNABLE TO ISSUE MESSAGE      */ 02194000
@RF00654 TM    PGRCER,B'00000100'                                  0660 02195000
         BNO   @RF00660                                            0660 02196000
*     DO;                           /* WITH PROMPT FOR REPLY+'       */ 02197000
*       MSGID='M02B';                                              0662 02198000
         MVC   MSGID(4),@CC00596                                   0662 02199000
*       MTLEN(1)=LENGTH(PGRETCD);   /* INSERT PUTGET RETURN CODE     */ 02200000
         MVI   MTLEN,X'04'                                         0663 02201000
*       MTADDR(1)=ADDR(PGRETCD);                                   0664 02202000
         LA    R0,PGRETCD                                       DSKC193 02203000
         STCM  R0,7,MTADDR                                      DSKC193 02204000
*       MTHIGHL(1)=ON;                                             0665 02206000
         OI    MTHIGHL,B'10000000'                                 0665 02207000
*       CALL IKJEFF02;              /* ISSUE THIS ERROR MESSAGE      */ 02208000
         L     R15,@CA00028                                     DSKC193 02209000
         BALR  R14,R15                                          DSKC193 02210000
*       MSGID='M02A';               /* CHANGE ID BACK, IN CASE HAD 0667 02211000
*                                      PUTLINE ERROR, TOO            */ 02212000
         MVC   MSGID(4),@CC00593                                   0667 02213000
*     END;                                                         0668 02214000
*                                                                  0668 02215000
*   /*****************************************************************/ 02216000
*   /*                                                               */ 02217000
*   /* SET UP AND ISSUE PUTLINE ERROR MESSAGE                        */ 02218000
*   /*                                                               */ 02219000
*   /*****************************************************************/ 02220000
*                                                                  0669 02221000
*   IF PLRCER=ON THEN               /* UNABLE TO ISSUE MESSAGE       */ 02222000
@RF00660 TM    PLRCER,B'00001000'                                  0669 02223000
         BNO   @RF00669                                            0669 02224000
*     DO;                                                          0670 02225000
*       MTLEN(1)=LENGTH(IN02A1B);   /* 'TO TERMINAL'                 */ 02226000
         MVI   MTLEN,X'0B'                                         0671 02227000
*       MTADDR(1)=ADDR(IN02A1B);    /* BECAUSE                       */ 02228000
         LA    R0,IN02A1B                                       DSKC193 02229000
         STCM  R0,7,MTADDR                                      DSKC193 02230000
*       MTLEN(3)=LENGTH(IN02A3E);   /* 'PUTLINE WAS UNSUCCESSFUL'    */ 02232000
         MVI   MTLEN+8,X'18'                                       0673 02233000
*       MTADDR(3)=ADDR(IN02A3E);                                   0674 02234000
         LA    R2,IN02A3E                                       DSKC193 02235000
         STCM  R2,7,MTADDR+8                                    DSKC193 02236000
*       CALL IKJEFF02;              /* ISSUE THIS ERROR MESSAGE      */ 02238000
*                                                                  0675 02239000
         L     R15,@CA00028                                     DSKC193 02240000
         BALR  R14,R15                                          DSKC193 02241000
*       /*************************************************************/ 02242000
*       /*                                                           */ 02243000
*       /* ALSO CALL IKJEFF19 TO ISSUE PUTLINE FAILURE MESSAGE       */ 02244000
*       /*                                                           */ 02245000
*       /*************************************************************/ 02246000
*                                                                  0676 02247000
*       GFPARMS=''X;                /* ZERO THE PARAMETER LIST TO  0676 02248000
*                                      IKJEFF19 GNRLFAIL ROUTINE     */ 02249000
         XC    GFPARMS(44),GFPARMS                                 0676 02250000
*       GFCALLID=GFPUTL;            /* HAVE IKJEFF19 ISSUE FAILURE 0677 02251000
*                                      MESSAGE ANALYZING BAD PUTLINE    02252000
*                                      RETURN CODE                   */ 02253000
         MVC   GFCALLID(2),@CH00235                                0677 02254000
*       GFRCODE=RETCODE;            /* PASS THE RETURN CODE AS A   0678 02255000
*                                      PARAMETER                     */ 02256000
         L     R2,RETCODE                                       DSKC193 02257000
         ST    R2,GFRCODE                                       DSKC193 02258000
*       GFWTPSW=ON;                 /* CAN'T ISSUE THE MESSAGE AS A     02259000
*                                      PUTLINE, SO ISSUE WRITE TO  0679 02260000
*                                      PROGRAMMER (DON'T NEED GFCPPLP   02261000
*                                      OR GFKEYNO8 SET)              */ 02262000
         OI    GFWTPSW,B'00100000'                                 0679 02263000
*       GFPGMNL=LENGTH(NAME02);     /* WILL INSERT 'IKJEFF02'        */ 02264000
         MVC   GFPGMNL(2),@CH00078                                 0680 02265000
*       GFPGMNP=ADDR(NAME02);                                      0681 02266000
         LA    R0,NAME02                                        DSKC193 02267000
         ST    R0,GFPGMNP                                       DSKC193 02268000
*       GF02PTR=ADDR(IKJEFF02);     /* PASS OWN ADDRESS              */ 02269000
         L     R2,@CA00028                                      DSKC193 02270000
         ST    R2,GF02PTR                                       DSKC193 02271000
*       TEMP=ADDR(GFPARMS);         /* STANDARD LINKAGE              */ 02272000
         LA    R0,GFPARMS                                       DSKC193 02273000
         ST    R0,TEMP                                          DSKC193 02274000
*       REG1=ADDR(TEMP);                                           0684 02275000
         LA    R1,TEMP                                          DSKC193 02276000
*       GEN(LINK EP=IKJEFF19);      /* IKJEFF19 GNRLFAIL ROUTINE WILL   02277000
*                                      ISSUE FAILURE MESSAGE GIVING     02278000
*                                      MEANING OF THE BAD PUTLINE  0685 02279000
*                                      R.C.                          */ 02280000
         LINK EP=IKJEFF19                                               02281000
*     END;                          /* DON'T USE IKJEFF19 R.C.       */ 02282000
*   RFY                                                            0687 02283000
*     REG1 UNRSTD;                                                 0687 02284000
@RF00669 DS    0H                                                  0688 02285000
*   IF PGRCER=ON THEN               /* RETURN PUTGET ERROR CODE, NOT    02286000
*                                      PUTLINE'S                     */ 02287000
         TM    PGRCER,B'00000100'                                  0688 02288000
         BNO   @EL00002                                         DSKC193 02289000
*     RETCODE=PGRETCD;                                             0689 02290000
         L     R2,PGRETCD                                       DSKC193 02291000
         ST    R2,RETCODE                                       DSKC193 02292000
*   END EMSGPROC;                                                  0690 02293000
@EL00002 DS    0H                                                  0690 02294000
@EF00002 DS    0H                                                  0690 02295000
@ER00002 LM    R14,R12,@SA00002                                 DSKC193 02296000
         BR    R14                                              DSKC193 02297000
*COPYONE:                                                          0691 02298000
*   PROC OPTIONS(NOSAVEAREA,RETREG,SAVE(REG14));/*           @Z40GQKU*/ 02299000
*                                                                  0691 02300000
COPYONE  ST    R14,12(,R13)                                     DSKC193 02301000
*   /*****************************************************************/ 02302000
*   /*                                                               */ 02303000
*   /* THIS INTERNAL PROCEDURE EXTRACTS                      @Z40GQKU*/ 02304000
*   /* FIRST LEVEL MESSAGE TO USERS BUFFER                   @Z40GQKU*/ 02305000
*   /* CHECK IF FIRST BUFFER BIGGER THAN MESSAGE             @Z40GQKU*/ 02306000
*   /*                                                               */ 02307000
*   /*****************************************************************/ 02308000
*                                                                  0692 02309000
*   IF PEXTRLEN>=BLDLEN THEN        /* COPY WHOSE MSG IF BFR @Z40GQKU*/ 02310000
         LH    R5,BLDLEN                                        DSKC193 02311000
         SLR   R6,R6                                            DSKC193 02312000
         IC    R6,PEXTRLEN(,R9)                                 DSKC193 02313000
         CR    R5,R6                                            DSKC193 02313010
         BH    @RF00692                                            0692 02314000
*     EXTRBUF(1:BLDLEN)=BLDBUF(1:BLDLEN);/* LARGE ENOUGH     @Z40GQKU*/ 02315000
         SLR   R8,R8                                            DSKC193 02316000
         ICM   R8,7,PEXTRBUF(R9)                                DSKC193 02316010
         BCTR  R5,0                                             DSKC193 02317000
         EX    R5,@SM00648                                      DSKC193 02318000
*   ELSE                            /* OTHERWISE             @Z40GQKU*/ 02319000
*     DO;                           /* TURN ON TRUNCATED MSG @Z40GQKU*/ 02320000
         B     @RC00692                                            0694 02321000
@RF00692 DS    0H                                                  0695 02322000
*       EXTRBUF(1:PEXTRLEN)=BLDBUF(1:PEXTRLEN);/* AS POSSIBLE@Z40GQKU*/ 02323000
         SLR   R2,R2                                            DSKC193 02324000
         ICM   R2,7,PEXTRBUF(R9)                                DSKC193 02324010
         SLR   R5,R5                                            DSKC193 02325000
         IC    R5,PEXTRLEN(,R9)                                 DSKC193 02326000
         BCTR  R5,0                                             DSKC193 02327000
         EX    R5,@SM00650                                      DSKC193 02328000
*     END;                          /* TO BFR                @Z40GQKU*/ 02329000
*   SWEXTONE=ON;                    /* SAY FIRST BFR COPIED  @Z40GQKU*/ 02330000
@RC00692 OI    SWEXTONE,B'00000010'                                0697 02331000
*   IF PEXTRCON=OFF&                /* ONLY EXTRACT AND            0698 02332000
*                                      SECOND@Z40GQKU                */ 02333000
*       (SWEXTRC2=OFF×SWEXTTWO=ON) THEN/* COPIED THEN        @Z40GQKU*/ 02334000
         TM    PEXTRCON(R9),B'00000100'                         DSKC193 02335000
         BNZ   @EL00003                                         DSKC193 02336000
         TM    SWEXTTWO,B'00000001'                                0698 02337000
         BNZ   @RT00698                                            0698 02338000
         TM    SWEXTRC2,B'00000100'                                0698 02339000
         BO    @EL00003                                         DSKC193 02340000
@RT00698 DS    0H                                                  0699 02341000
*     RETURN TO RETLABEL;           /* EXIT MODULE           @Z40GQKU*/ 02342000
         LA    R14,RETLABEL                                     DSKC193 02343000
         BR    R14                                              DSKC193 02344000
*   END;                            /* OTHERWISE GO BACK     @Z40GQKU*/ 02345000
@EL00003 DS    0H                                                  0700 02346000
@EF00003 DS    0H                                                  0700 02347000
@ER00003 L     R14,12(,R13)                                     DSKC193 02348000
         BR    R14                                              DSKC193 02349000
*COPYTWO:                                                          0701 02350000
*   PROC OPTIONS(NOSAVEAREA,RETREG,SAVE(REG14));/*           @Z40GQKU*/ 02351000
*                                                                  0701 02352000
COPYTWO  ST    R14,12(,R13)                                     DSKC193 02353000
*   /*****************************************************************/ 02354000
*   /*                                                               */ 02355000
*   /* THIS INTERNAL PROCEDURE EXTRACTS                      @Z40GQKU*/ 02356000
*   /* SECOND LEVEL MESSAGE TO USERS BUFFER                  @Z40GQKU*/ 02357000
*   /* CHECK IF SECOND BUFFER BIGGER THAN MESSAGE@Z40GQKU            */ 02358000
*   /*                                                               */ 02359000
*   /*****************************************************************/ 02360000
*                                                                  0702 02361000
*   IF PEXTRLN2>=BLDLEN THEN        /* IF BFR LONG ENOUGH          0702 02362000
*                                      COPY@Z40GQKU                  */ 02363000
         LH    R2,BLDLEN                                        DSKC193 02364000
         SLR   R5,R5                                            DSKC193 02365000
         IC    R5,PEXTRLN2(,R9)                                 DSKC193 02366000
         CR    R2,R5                                            DSKC193 02366010
         BH    @RF00702                                            0702 02367000
*     EXTRBF2(1:BLDLEN)=BLDBUF(1:BLDLEN);/* MESSAGE WHOLE    @Z40GQKU*/ 02368000
         SLR   R6,R6                                            DSKC193 02369000
         ICM   R6,7,PEXTRBF2(R9)                                DSKC193 02369010
         BCTR  R2,0                                             DSKC193 02370000
         EX    R2,@SM00652                                      DSKC193 02371000
*   ELSE                            /* IF NOT THEN ONLY COPY @Z40GQKU*/ 02372000
*     DO;                           /* AS MUCH AS FITS IN    @Z40GQKU*/ 02373000
         B     @RC00702                                            0704 02374000
@RF00702 DS    0H                                                  0705 02375000
*       EXTRBF2(1:PEXTRLN2)=BLDBUF(1:PEXTRLN2);/* FLAG FOR   @Z40GQKU*/ 02376000
         SLR   R8,R8                                            DSKC193 02377000
         ICM   R8,7,PEXTRBF2(R9)                                DSKC193 02377010
         SLR   R2,R2                                            DSKC193 02378000
         IC    R2,PEXTRLN2(,R9)                                 DSKC193 02379000
         BCTR  R2,0                                             DSKC193 02380000
         EX    R2,@SM00654                                      DSKC193 02381000
*     END;                          /* LATER. EITHER CASE    @Z40GQKU*/ 02382000
*   SWEXTTWO=ON;                    /* SAY SEC BFR COPIED    @Z40GQKU*/ 02383000
@RC00702 OI    SWEXTTWO,B'00000001'                                0707 02384000
*   IF PEXTRCON=OFF&                /* ONLY EXTRACT AND FIRST      0708 02385000
*                                                            @Z40GQKU*/ 02386000
*       SWEXTONE=ON THEN            /* ALSO DONE THEN        @Z40GQKU*/ 02387000
         TM    PEXTRCON(R9),B'00000100'                         DSKC193 02388000
         BNZ   @EL00004                                         DSKC193 02389000
         TM    SWEXTONE,B'00000010'                                0708 02390000
         BNO   @EL00004                                         DSKC193 02391000
*     RETURN TO RETLABEL;           /* GET OUT OF MODULE     @Z40GQKU*/ 02392000
         LA    R14,RETLABEL                                     DSKC193 02393000
         BR    R14                                              DSKC193 02394000
*   END;                            /* OTHERWISE RETURN      @Z40GQKU*/ 02395000
@EL00004 DS    0H                                                  0710 02396000
@EF00004 DS    0H                                                  0710 02397000
@ER00004 L     R14,12(,R13)                                     DSKC193 02398000
         BR    R14                                              DSKC193 02399000
*COPYSPCL:                                                         0711 02400000
*   PROC OPTIONS(NOSAVEAREA,RETREG,SAVE(REG14));/*           @Z40GQKU*/ 02401000
*                                                                  0711 02402000
COPYSPCL ST    R14,12(,R13)                                     DSKC193 02403000
*   /*****************************************************************/ 02404000
*   /*                                                               */ 02405000
*   /* THIS INTERNAL PROCEDURE HANDLES SPECIAL CASE          @Z40GQKU*/ 02406000
*   /* SECOND LEVEL MESSAGE. MESSAGE ALREADY SET UP          @Z40GQKU*/ 02407000
*   /* IN O.L.D. AND HAS ONLY A PRIMARY SEGMENT.             @Z40GQKU*/ 02408000
*   /*                                                               */ 02409000
*   /*****************************************************************/ 02410000
*                                                                  0712 02411000
*   IF PEXTRLN2>=OSEGLEN THEN       /* BIG ENOUGH THEN       @Z40GQKU*/ 02412000
         L     R2,POLDPTR(,R9)                                  DSKC193 02413000
         L     R5,OLDSEGP(,R2)                                  DSKC193 02414000
         LH    R6,OSEGLEN(,R5)                                  DSKC193 02415000
         SLR   R8,R8                                            DSKC193 02416000
         IC    R8,PEXTRLN2(,R9)                                 DSKC193 02417000
         CR    R6,R8                                            DSKC193 02417010
         BH    @RF00712                                            0712 02418000
*     EXTRBF2(1:OSEGLEN)=OLDMSEG(1:OSEGLEN);/* MOVE IT       @Z40GQKU*/ 02419000
         SLR   R2,R2                                            DSKC193 02420000
         ICM   R2,7,PEXTRBF2(R9)                                DSKC193 02420010
         BCTR  R6,0                                             DSKC193 02421000
         EX    R6,@SM00656                                      DSKC193 02422000
*   ELSE                            /* OR IF BFR SMALL       @Z40GQKU*/ 02423000
*     DO;                           /* THEN ONLY MOVE        @Z40GQKU*/ 02424000
         B     @RC00712                                            0714 02425000
@RF00712 DS    0H                                                  0715 02426000
*       EXTRBF2(1:PEXTRLN2)=OLDMSEG(1:PEXTRLN2);/* ENOUGH    @Z40GQKU*/ 02427000
         SLR   R5,R5                                            DSKC193 02428000
         ICM   R5,7,PEXTRBF2(R9)                                DSKC193 02428010
         SLR   R6,R6                                            DSKC193 02429000
         IC    R6,PEXTRLN2(,R9)                                 DSKC193 02430000
         BCTR  R6,0                                             DSKC193 02431000
         L     R8,POLDPTR(,R9)                                  DSKC193 02432000
         L     R2,OLDSEGP(,R8)                                  DSKC193 02433000
         EX    R6,@SM00658                                      DSKC193 02434000
*     END;                          /*                       @Z40GQKU*/ 02435000
*   IF OSEGLEN>14&PEXTRLN2>14 THEN  /* IF MSG WILL HOLD      @Z40GQKU*/ 02436000
@RC00712 L     R5,POLDPTR(,R9)                                  DSKC193 02437000
         L     R6,OLDSEGP(,R5)                                  DSKC193 02438000
         LH    R8,OSEGLEN(,R6)                                  DSKC193 02439000
         C     R8,@CF00579                                      DSKC193 02440000
         BNH   @RF00717                                            0717 02441000
         CLI   PEXTRLN2(R9),14                                  DSKC193 02442000
         BNH   @RF00717                                            0717 02443000
*     EXTRBF2(5:14)=BLDMSG(1:10);   /* MSG ID, MOVE IT IN    @Z40GQKU*/ 02444000
         SLR   R2,R2                                            DSKC193 02445000
         ICM   R2,7,PEXTRBF2(R9)                                DSKC193 02445010
         MVC   EXTRBF2+4(10,R2),BLDMSG                          DSKC193 02446000
*   SWEXTTWO=ON;                    /*                       @Z40GQKU*/ 02447000
@RF00717 OI    SWEXTTWO,B'00000001'                                0719 02448000
*   END;                            /*                       @Z40GQKU*/ 02449000
@EL00005 DS    0H                                                  0720 02450000
@EF00005 DS    0H                                                  0720 02451000
@ER00005 L     R14,12(,R13)                                     DSKC193 02452000
         BR    R14                                              DSKC193 02453000
*                                                                  0721 02454000
*/********************************************************************/ 02455000
*/*                                                                  */ 02456000
*/* WTODOMP INTERNAL PROCEDURE                                       */ 02457000
*/*   - COMMON CODE TO ISSUE WTO (COULD HAVE WRITE TO PROGRAMMER     */ 02458000
*/*       ROUTCDE) AND DOM (IF REQUESTED).                           */ 02459000
*/*   - REGISTER 8 MUST BE SET BEFORE CALL WTODOMP, AND WPL MUST BE  */ 02460000
*/*       BASED(REG8).                                               */ 02461000
*/*                                                                  */ 02462000
*/********************************************************************/ 02463000
*                                                                  0721 02464000
*WTODOMP:                                                          0721 02465000
*   PROC OPTIONS(SAVE(REG14),RETREG,NOSAVEAREA);                   0721 02466000
WTODOMP  ST    R14,12(,R13)                                     DSKC193 02467000
*   RFY                                                            0722 02468000
*    (REG1,                                                        0722 02469000
*     REG8) RSTD;                   /* REGISTER 8 POINTS TO WPL (WTO    02470000
*                                      PARAMETER LIST)               */ 02471000
*                                                                  0722 02472000
*   /*****************************************************************/ 02473000
*   /*                                                               */ 02474000
*   /* ISSUE THE WTO (AND DOM) - LOOP IF MESSAGE WON'T FIT ON ONE WTO*/ 02475000
*   /* LINE                                                          */ 02476000
*   /*                                                               */ 02477000
*   /*****************************************************************/ 02478000
*                                                                  0723 02479000
*   LVARPTR=REG8+WPLLGH;            /* POINT TO ROUTING AND        0723 02480000
*                                      DESCRIPTOR CODES, WHICH FOLLOW   02481000
*                                      THE MESSAGE TEXT              */ 02482000
         LR    R2,R8                                            DSKC193 02483000
         AH    R2,WPLLGH(,R8)                                   DSKC193 02484000
*   BLDRTDEC=VARIABLE(1:4);         /* SAVE CODES HERE IN CASE     0724 02485000
*                                      TOO-LONG MESSAGE              */ 02486000
         MVC   BLDRTDEC(4),VARIABLE(R2)                         DSKC193 02487000
*   TEMP=1;                         /* TEMP IS WTO LOOP CONTROLLER   */ 02488000
         MVC   TEMP(4),@CF00035                                    0725 02489000
*   DO WHILE TEMP^=0;               /* LOOP TO ISSUE WTO('S)/DOM('S) */ 02490000
         B     @DE00726                                            0726 02491000
@DL00726 DS    0H                                                  0727 02492000
*     IF WPLLGH>MAXWTOLN+4 THEN     /* IF TOO-LONG MESSAGE PLUS    0727 02493000
*                                      HEADER THEN MUST ISSUE AS   0727 02494000
*                                      SEVERAL WTP'S (WTO MESSAGES 0727 02495000
*                                      ARE TRUNCATED)                */ 02496000
         LA    R4,128                                           DSKC193 02497000
         LH    R5,WPLLGH(,R8)                                   DSKC193 02498000
         CR    R5,R4                                            DSKC193 02499000
         BNH   @RF00727                                            0727 02500000
*       DO;                                                        0728 02501000
*         TEMP=WPLLGH-MAXWTOLN;     /* REMEMBER HOW MUCH TEXT MUST BE   02502000
*                                      ISSUED IN LATER WTO('S)       */ 02503000
         SL    R5,@CF00054                                      DSKC193 02504000
         ST    R5,TEMP                                          DSKC193 02505000
*         WPLLGH=MAXWTOLN+4;        /* WILL ISSUE THIS WTO FOR     0730 02506000
*                                      MAXIMUM LENGTH (4 BYTES IS FOR   02507000
*                                      HEADER)                       */ 02508000
         STH   R4,WPLLGH(,R8)                                   DSKC193 02509000
*         LVARPTR=REG8+WPLLGH;      /* POINT TO END OF CURRENT     0731 02510000
*                                      MESSAGE LINE                  */ 02511000
         ALR   R4,R8                                            DSKC193 02512000
         LR    R2,R4                                            DSKC193 02513000
*         SAVETEXT=VARIABLE(1:4);   /* SAVE TEXT THAT WILL BE      0732 02514000
*                                      REPLACED WITH BLDRTDEC        */ 02515000
         MVC   SAVETEXT(4),VARIABLE(R2)                         DSKC193 02516000
*         VARIABLE(1:4)=BLDRTDEC;   /* WTO TEXT MUST BE FOLLOWED BY     02517000
*                                      ROUTING AND DESCR. CODES      */ 02518000
         MVC   VARIABLE(4,R2),BLDRTDEC                          DSKC193 02519000
*       END;                                                       0734 02520000
*     ELSE                          /* ZEROING TEMP CAUSES EXIT FROM    02521000
*                                      LOOP AFTER ISSUE THE WTO      */ 02522000
*       TEMP=0;                                                    0735 02523000
         B     @RC00727                                            0735 02524000
@RF00727 SLR   R0,R0                                            DSKC193 02525000
         ST    R0,TEMP                                          DSKC193 02526000
*     GEN(WTO   MF=(E,(REG8)));     /* ISSUE WRITE TO OPERATOR MACRO */ 02527000
@RC00727 DS    0H                                                  0736 02528000
         WTO   MF=(E,(R8))                                      DSKC193 02529000
*     IF PDOMSW=ON×WTPOVERR=ON THEN                                0737 02530000
         TM    PDOMSW(R9),B'01000000'                           DSKC193 02531000
         BO    @RT00737                                            0737 02532000
         TM    WTPOVERR,B'00000001'                                0737 02533000
         BNO   @RF00737                                            0737 02534000
@RT00737 DS    0H                                                  0738 02535000
*       GEN(DOM   MSG=(1));         /* DELETE OPERATOR MESSAGE MACRO    02536000
*                                      (USE TO ERASE WTP FROM      0738 02537000
*                                      OPERATOR'S DISPLAY TUBE) -  0738 02538000
*                                      REG1 HAS ID OF MESSAGE FROM 0738 02539000
*                                      WTO                           */ 02540000
*                                                                  0738 02541000
         DOM   MSG=(1)                                                  02542000
*     /***************************************************************/ 02543000
*     /*                                                             */ 02544000
*     /* IF MUST ISSUE ANOTHER WTO LINE, THEN SHIFT THE REMAINING    */ 02545000
*     /* TEXT OVER IN BUFFER (IF THE MAXIMUM MESSAGE LENGTH CHANGES  */ 02546000
*     /* FROM 256, WHERE 256=LENGTH(BLDMSG), THEN MUST CHANGE TO MOVE*/ 02547000
*     /* LONG)                                                       */ 02548000
*     /*                                                             */ 02549000
*     /***************************************************************/ 02550000
*                                                                  0739 02551000
*     IF TEMP>0 THEN                                               0739 02552000
@RF00737 L     R4,TEMP                                          DSKC193 02553000
         LTR   R4,R4                                            DSKC193 02554000
         BNP   @RF00739                                            0739 02555000
*       DO;                                                        0740 02556000
*         VARIABLE(1:4)=SAVETEXT;   /* LVARPTR POINTS TO END OF LAST    02557000
*                                      WTO LINE - NOW REPLACE CODES     02558000
*                                      WITH SAVED TEXT               */ 02559000
         MVC   VARIABLE(4,R2),SAVETEXT                          DSKC193 02560000
         L     R5,TEMP                                          DSKC193 02560010
*         WPLLGH=TEMP;              /* GET REMAINING LENGTH (USE THIS   02561000
*                                      LENGTH FOR MOVE - HAS 4 BYTES    02562000
*                                      FOR HEADER, BUT USE THE 4   0742 02563000
*                                      BYTES TO MOVE ROUTINE + DESC.    02564000
*                                      CODES, WHICH ARE NEEDED FOR 0742 02565000
*                                      LAST WTO)                     */ 02566000
         STH   R5,WPLLGH(,R8)                                   DSKC193 02567000
*         LVARPTR=ADDR(WPLTXT);     /* POINT TO BEGINNING OF WTO TEXT*/ 02568000
         LA    R2,WPLTXT(,R8)                                   DSKC193 02569000
*         WORKPTR=LVARPTR+MAXWTOLN; /* POINT TO UNISSUED TEXT        */ 02570000
         LA    R4,124                                           DSKC193 02571000
         ALR   R4,R2                                            DSKC193 02572000
*         LVARPTR->VARIABLE(1:TEMP)=WORKPTR->VARIABLE(1:TEMP);/* MOVE   02573000
*                                      REST OF TEXT OVER IN BUFFER   */ 02574000
         BCTR  R5,0                                             DSKC193 02575000
         EX    R5,@SM00660                                      DSKC193 02576000
*       END;                                                       0746 02577000
*   END;                            /* END OF DO WHILE LOOP OF WTO'S */ 02578000
@RF00739 DS    0H                                                  0747 02579000
@DE00726 L     R0,TEMP                                          DSKC193 02580000
         LTR   R0,R0                                            DSKC193 02581000
         BNZ   @DL00726                                            0747 02582000
*   RFY                                                            0748 02583000
*    (REG1,                                                        0748 02584000
*     REG8) UNRSTD;                                                0748 02585000
*   END WTODOMP;                                                   0749 02586000
@EL00006 DS    0H                                                  0749 02587000
@EF00006 DS    0H                                                  0749 02588000
@ER00006 L     R14,12(,R13)                                     DSKC193 02589000
         BR    R14                                              DSKC193 02590000
*   END IKJEFF02                                                   0750 02591000
*                                                                  0750 02592000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 02593000
*/*%INCLUDE SYSLIB  (IEZWPL  )                                       */ 02594000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                       */ 02595000
*/*%INCLUDE SYSLIB  (IKJEFFGF)                                       */ 02596000
*/*%INCLUDE SYSLIB  (IKJEFFMT)                                       */ 02597000
*                                                                  0750 02598000
*       ;                                                          0750 02599000
@DATA    DS    0H                                                       02600000
@CH00078 DC    H'8'                                                     02601000
@CH00235 DC    H'22'                                                    02602000
@SM00632 MVC   JOBINSRT(0),VARIABLE(R2)                         DSKC193 02603000
@SM00634 MVC   0(0,R1),VARIABLE(R15)                            DSKC193 02604000
@SM00636 MVC   0(0,R8),VARIABLE(R2)                             DSKC193 02605000
@SM00638 MVC   0(0,R8),CMSGPART(R5)                             DSKC193 02606000
@SM00641 MVC   COREMSG(0,R2),BLDBUF                             DSKC193 02607000
@SM00644 MVC   BLDBUF(0),COREMSG(R8)                            DSKC193 02608000
@SM00646 MVC   PRETEXT(0,R1),INTEXT(R2)                         DSKC193 02609000
@SM00648 MVC   EXTRBUF(0,R8),BLDBUF                             DSKC193 02610000
@SM00650 MVC   EXTRBUF(0,R2),BLDBUF                             DSKC193 02611000
@SM00652 MVC   EXTRBF2(0,R6),BLDBUF                             DSKC193 02612000
@SM00654 MVC   EXTRBF2(0,R8),BLDBUF                             DSKC193 02613000
@SM00656 MVC   EXTRBF2(0,R2),OLDMSEG(R5)                        DSKC193 02614000
@SM00658 MVC   EXTRBF2(0,R5),OLDMSEG(R2)                        DSKC193 02615000
@SM00660 MVC   VARIABLE(0,R2),VARIABLE(R4)                      DSKC193 02616000
@DATD    DSECT                                                          02617000
         DS    0F                                                       02618000
@SA00001 DS    18F                                                      02619000
@PC00001 DS    3F                                                       02620000
@SA00002 DS    15F                                                      02621000
IKJEFF02 CSECT                                                          02628000
@CF00035 DC    F'1'                                                     02630000
@CF00050 DC    F'2'                                                     02631000
@CF00225 DC    F'4'                                                     02632000
@CF00210 DC    F'5'                                                     02633000
@CF00036 DC    F'11'                                                    02634000
@CF00579 DC    F'14'                                                    02635000
@CF00527 DC    F'20'                                                    02636000
@CF00591 DC    F'76'                                                    02637000
@CF00054 DC    F'124'                                                   02638000
A001034  DC    F'252'                                           DSKC193 02638010
@CF00609 DC    F'260'                                                   02639000
@CF00611 DC    F'264'                                                   02640000
@CF00519 DC    XL4'FF000000'                                            02641000
@CF00583 DC    XL4'01000000'                                            02642000
@CF00538 DC    XL4'FFFF'                                                02643000
@DATD    DSECT                                                          02644000
         DS    0D                                                       02645000
RETCODE  DS    A                                                        02646000
PGRETCD  DS    A                                                        02647000
TEMP     DS    A                                                        02648000
LOCALECB DS    A                                                        02649000
JOBIDEND DS    A                                                        02650000
LFTPAREN DS    A                                                        02651000
A0000A8  DS    A                                                DSKC193 02651010
A0000AC  DS    A                                                DSKC193 02651020
OUTADDR  DS    A                                                        02652000
COREGOTP DS    A                                                        02653000
CORESAVE DS    A                                                        02654000
LOOPCT   DS    F                                                        02655000
INTSWS   DS    0AL1                                             DSKC193 02660000
SWMULTLV DS    BL1                                              DSKC193 02662000
SWNFIRST EQU   INTSWS+0                                         DSKC193 02663000
SWLSTMSG EQU   INTSWS+0                                         DSKC193 02664000
SWHAVHEX EQU   INTSWS+0                                         DSKC193 02665000
SWEXTRCT EQU   INTSWS+0                                         DSKC193 02666000
SWEXTRC2 EQU   INTSWS+0                                         DSKC193 02667000
SWEXTONE EQU   INTSWS+0                                         DSKC193 02668000
SWEXTTWO EQU   INTSWS+0                                         DSKC193 02669000
A0000C1  DS    AL1                                              DSKC193 02670000
LLENGTH  DS    0AL1                                             DSKC193 02670010
LCONVRT  DS    BL1                                              DSKC193 02670020
         DS    0A                                               DSKC193 02671000
GFPARMS  DS    CL44                                                     02672000
         ORG   GFPARMS                                                  02673000
GFCBPTR  DS    AL4                                                      02674000
GFRCODE  DS    FL4                                                      02675000
GF02PTR  DS    AL4                                                      02676000
GFCALLID DS    FL2                                                      02677000
GFBITS   DS    BL1                                                      02678000
         ORG   GFBITS                                                   02679000
GFKEYN08 DS    BL1                                                      02680000
GFSUBSYS EQU   GFBITS+0                                                 02681000
GFWTPSW  EQU   GFBITS+0                                                 02682000
         ORG   GFPARMS+15                                               02684000
         DS    AL1                                              DSKC193 02685000
GFCPPLP  DS    AL4                                                      02686000
GFECBP   DS    AL4                                                      02687000
GFDSNLEN DS    FL2                                                      02688000
GFPGMNL  DS    FL2                                                      02689000
GFDSNP   DS    AL4                                                      02690000
GFPGMNP  DS    AL4                                                      02691000
         DS    AL4                                              DSKC193 02692000
         DS    AL4                                              DSKC193 02693000
         ORG   GFPARMS+44                                               02694000
MSGTABLE DS    CL56                                                     02695000
         ORG   MSGTABLE                                                 02696000
LISTPTR  DS    AL4                                                      02697000
TMCTPTR  DS    AL4                                                      02698000
         ORG   TMCTPTR                                                  02699000
MTCPPL   DS    AL4                                                      02700000
         ORG   MSGTABLE+8                                               02701000
ECBPTR   DS    AL4                                                      02702000
MTHIGH   DS    BL1                                                      02705000
         ORG   MSGTABLE+16                                              02706000
MSGCSECT DS    AL4                                                      02707000
SW       DS    AL1                                                      02708000
         ORG   SW                                                       02709000
MTNOIDSW DS    BL1                                                      02710000
MTPUTLSW EQU   SW+0                                                     02711000
MTWTOSW  EQU   SW+0                                                     02712000
MTHEXSW  EQU   SW+0                                                     02713000
MTKEY1SW EQU   SW+0                                                     02714000
MTJOBISW EQU   SW+0                                                     02715000
MTWTPSW  EQU   SW+0                                                     02716000
MTNHEXSW EQU   SW+0                                                     02717000
         ORG   MSGTABLE+21                                              02718000
RETMSG   DS    AL3                                                      02719000
SW2      DS    AL1                                                      02720000
         ORG   SW2                                                      02721000
MT2OLDSW DS    BL1                                                      02722000
MTDOMSW  EQU   SW2+0                                                    02723000
MTNOXQSW EQU   SW2+0                                                    02724000
MTNPLMSW EQU   SW2+0                                                    02725000
MTPGMSW  EQU   SW2+0                                                    02726000
         ORG   MSGTABLE+25                                              02728000
         DS    AL3                                              DSKC193 02729000
MTOLDPTR DS    AL4                                                      02730000
         DS    AL4                                              DSKC193 02731000
         DS    AL4                                              DSKC193 02732000
MSGID    DS    CL4                                                      02733000
MTINSRTS DS    CL12                                                     02734000
         ORG   MTINSRTS                                                 02735000
MTINSRT  DS    CL4                                                      02736000
         ORG   MTINSRT+0                                                02737000
MTLEN    DS    AL1                                                      02738000
         ORG   MTLEN+0                                                  02739000
MTHIGHL  DS    BL1                                                      02740000
         ORG   MTINSRT+1                                                02741000
MTADDR   DS    AL3                                                      02742000
         ORG   MSGTABLE+56                                              02743000
SAVETEXT DS    CL4                                                      02744000
BLDBUF   DS    CL264                                                    02745000
         ORG   BLDBUF                                                   02746000
BLDAREA  DS    CL260                                                    02747000
         ORG   BLDAREA                                                  02748000
BLDHDR   DS    CL4                                                      02749000
         ORG   BLDHDR                                                   02750000
BLDLEN   DS    FL2                                                      02751000
BLDOFF   DS    FL2                                                      02752000
         ORG   BLDAREA+4                                                02753000
BLDMSG   DS    CL256                                                    02754000
         ORG   BLDBUF+260                                               02755000
BLDRTDEC DS    CL4                                                      02756000
         ORG   BLDBUF+264                                               02757000
TMSGID   DS    CL4                                                      02758000
NBPART   DS    CL4                                                      02759000
         ORG   NBPART                                                   02760000
         DS    BL3                                              DSKC193 02761000
NBPARTS  DS    BL1                                                      02762000
         ORG   NBPART+4                                                 02763000
SAVCODE  DS    CL4                                                      02764000
         ORG   SAVCODE                                                  02765000
         DS    CL1                                              DSKC193 02766000
SAVCODE3 DS    CL3                                                      02767000
         ORG   SAVCODE3                                                 02768000
         DS    CL1                                              DSKC193 02769000
SAVCODE2 DS    CL2                                                      02770000
         ORG   SAVCODE2                                                 02771000
         DS    CL1                                              DSKC193 02772000
SAVCODE1 DS    CL1                                                      02773000
         ORG   SAVCODE+4                                                02774000
         DS    A,H                                              DSKC193 02775000
UNPKAREA DS    CL18                                                     02776000
         ORG   UNPKAREA                                                 02777000
UNPKHDR  DS    CL2                                                      02778000
UNPK     DS    CL16                                                     02779000
JOBINSRT DS    CL18                                                     02781000
A00026A  DS    CL234                                            DSKC193 02781010
PARENSW  DS    BL1                                                      02782000
         DS    0A                                               DSKC193 02783000
SAVEPAR  DS    CL16                                                     02784000
         ORG   SAVEPAR                                                  02785000
         DS    CL12                                             DSKC193 02786000
RTNPTR   DS    AL4                                                      02787000
         ORG   RTNPTR                                                   02788000
FILLER   DS    BL1                                                      02789000
INBUFP   DS    AL3                                                      02790000
         ORG   SAVEPAR+16                                               02791000
PUTPTRS  DS    CL16                                                     02792000
         ORG   PUTPTRS                                                  02793000
PUPTP    DS    AL4                                                      02794000
PECTP    DS    AL4                                                      02795000
PECBP    DS    AL4                                                      02796000
PPARMP   DS    AL4                                                      02797000
         ORG   PUTPTRS+16                                               02798000
PUTPARM  DS    CL8                                                      02799000
         ORG   PUTPARM                                                  02800000
PUTLEN   DS    FL4                                                      02801000
PUTADDR  DS    AL4                                                      02802000
         ORG   PUTPARM+8                                                02803000
ERRORSWS DS    BL2                                                      02804000
         ORG   ERRORSWS                                                 02805000
PTRPLER  DS    BL1                                                      02806000
MCPLER   EQU   ERRORSWS+0                                               02807000
PCPPLER  EQU   ERRORSWS+0                                               02808000
MIDPLER  EQU   ERRORSWS+0                                               02809000
PLRCER   EQU   ERRORSWS+0                                               02810000
PGRCER   EQU   ERRORSWS+0                                               02811000
OLDPLER  EQU   ERRORSWS+0                                               02812000
WTPOVERR EQU   ERRORSWS+0                                               02813000
EXTRCTER DS    BL1                                                      02814000
EXTRCTR2 EQU   ERRORSWS+1                                               02815000
EXTRCTR3 EQU   ERRORSWS+1                                               02816000
         ORG   ERRORSWS+2                                               02818000
IKJEFF02 CSECT                                                          02819000
         DS    0F                                                       02820000
@SIZDATD DC    AL1(1)                                                   02821000
         DC    AL3(@ENDDATD-@DATD)                                      02822000
@CA00028 DC    A(IKJEFF02)                                              02823000
@CV00072 DC    V(IKJEFF2M)                                              02824000
         DS    0D                                                       02825000
@CC00525 DC    C'    '                                                  02826000
@CC00592 DC    C'M02D'                                                  02827000
@CC00593 DC    C'M02A'                                                  02828000
@CC00595 DC    C'M02C'                                                  02829000
@CC00596 DC    C'M02B'                                                  02830000
@CC00051 DC    C'X'''                                                   02831000
@CB00519 DC    X'FF000000'                                              02832000
@CB00566 DC    X'10004000'                                              02833000
@CB00567 DC    X'02000020'                                              02834000
@CB00578 DC    X'00000001'                                              02835000
@CB00565 DC    X'8000'                                                  02836000
@CB00585 DC    B'0000000000000000'                                      02837000
ALPHA    DC    CL16'0123456789ABCDEF'                                   02838000
IN02A1A  DC    CL7'WITH ID'                                             02839000
IN02A1B  DC    CL11'TO TERMINAL'                                        02840000
IN02A1D  DC    CL19'WITH A SECOND LEVEL'                                02841000
INSTDASH DC    CL1'-'                                                   02842000
IN02A3A  DC    CL50'ZERO PARAMETER LIST PTR (REG. 1 OR PTR TO MSGLIST)' 02843000
IN02A3B  DC    CL29'ZERO POINTER TO MESSAGE CSECT'                      02844000
IN02A3C  DC    CL37'ZERO CPPL POINTER WHEN PUTLINE/PUTGET'              02845000
IN02A3D  DC    CL29'ID NOT FOUND IN MESSAGE CSECT'                      02846000
IN02A3E  DC    CL24'PUTLINE WAS UNSUCCESSFUL'                           02847000
IN02A3F  DC    CL64'INCOMPATIBLE PARAMETERS (NEED MTOLDPTR NONZERO WHENC02848000
                MT2OLDSW ON)'                                           02849000
IN02A3H  DC    CL26'FIRST BUFFER NOT SUPPLIED,'                         02850000
IN02A3J  DC    CL27'SECOND BUFFER NOT SUPPLIED,'                        02851000
IN02A3K  DC    CL25'FIRST BUFFER LENGTH ZERO,'                          02852000
NAME02   DC    CL8'IKJEFF02'                                            02853000
PATCH    DC    17CL3'ZAP'                                               02854000
         DC    X'F321'                       !!! SOURCE COMPARE FIX !!! 02855000
         DC    0F'0'                                            DSKC193 02855000
*                                       /* NON-REENTRANT DC'S        */ 02856000
PUTGETLL PUTGET  MF=L                  LIST FORMAT OF PUTGET            02857000
PUTLL    PUTLINE MF=L                  LIST FORMAT OF PUTLINE           02858000
IKJEFF2M CSECT                                                          02861000
**                                                                      02863000
**  MESSAGE   DETECTED   ISSUED     LOCATED    PROGRAM                  02864000
**    ID         IN        BY         IN                                02865000
**                                                                      02866000
**  IKJ56284I IKJEFF02   IKJEFF02   IKJEFF02   SUBMIT                   02867000
**                                                                      02868000
**            UNABLE TO ISSUE MESSAGE <WITH ID <XXXX>>                  02869000
**                                    <TO TERMINAL <->>                 02870000
**                                    <AS PUTGET <->>                   02871000
**                                    <WITH A SECOND LEVEL <->>         02872000
**            <ERRORDESCRIPTION><+>                                     02873000
**              USER HAS PROFILE NOPROMPT OR CLIST IN NOPROMPT          02874000
**              MODE (PUTGET R.C. IS <NNNN>)                            02875000
**                                                                      02876000
**    EXPLANATION-                                                      02877000
**      IKJEFF02 TSO MESSAGE ISSUER SERVICE ROUTINE HAS DETECTED AN     02878000
**      ERROR IN ITS INPUT PARAMETER LIST (MAPPED BY IKJEFFMT MACRO)    02879000
**      OR AN ERROR RETURN CODE FROM A CALL OF PUTGET OR PUTLINE        02880000
**      SERVICE ROUTINE.  IT ISSUES THE REQUESTED MESSAGE FIRST, IF     02881000
**      POSSIBLE.                                                       02882000
**                                                                      02883000
**      THE SECOND LEVEL MESSAGE IS ONLY ISSUED FOR A PUTGET FAILURE.   02884000
**                                                                      02885000
**      IF A PUTLINE HAS FAILED IKJEFF19 GNRLFAIL SERVICE ROUTINE IS    02886000
**      ALSO CALLED TO DIAGNOSE THE PUTLINE ERROR AND ISSUE A MESSAGE.  02887000
**                                                                      02888000
**      IF THERE IS A PUTGET ERROR THE MESSAGE IS ISSUED AS A           02889000
**      PUTLINE.  IF THERE IS A PUTLINE ERROR THE MESSAGE IS            02890000
**      ISSUED AS A WRITE TO PROGRAMMER.                                02891000
**                                                                      02892000
**      SEE THE OS/VS2 TSO GUIDE TO WRITING A TMP OR A CP               02893000
**      (GC28-0648-0) FOR DETAILED DESCRIPTIONS OF PUTGET AND           02894000
**      PUTLINE ERROR CODES.                                            02895000
**                                                                      02896000
**    SYSTEM ACTION-                                                    02897000
**      IKJEFF02 RETURNS AN ERROR CODE TO ITS CALLER (76 IF             02898000
**      PARAMETER LIST ERROR, OTHERWISE THE PUTGET OR PUTLINE           02899000
**      ERROR CODE).  THE CALLER SHOULD THEN TAKE AN ERROR              02900000
**      TERMINATION.                                                    02901000
**                                                                      02902000
**    USER ACTION-                                                      02903000
**      CORRECT THE ERROR, IF POSSIBLE.  OTHERWISE CALL YOUR            02904000
**      SYSTEM PROGRAMMER.                                              02905000
**                                                                      02906000
**                                                                      02907000
M02A   IKJTSMSG ('IKJ56284I UNABLE TO ISSUE MESSAGE ',,' ',,' BECAUSE '+02909000
               ,),M02A                                        @Z40NQKJ  02910000
FL2B   IKJTSMSG ('IKJ56284I UNABLE TO ISSUE MESSAGE WITH PROMPT FOR REP+02911000
               LY+'),FL2B                                               02912000
M02B   IKJTSMSG ('IKJ56284I USER HAS PROFILE NOPROMPT OR CLIST IN NOPRO+02913000
               MPT MODE (PUTGET R.C. IS ',,')'),M02B,FL2B               02914000
M02C   IKJTSMSG ('IKJ56285I ',,' MESSAGE NOT EXTRACTED FOR ID ',,' '),M+02915000
               02C                                             @Z40GQKU 02916000
M02D   IKJTSMSG ('IKJ56286I SYSTEM OR INSTALLATION ERROR.  REPORT THE F+02917000
               OLLOWING MESSAGE TO YOUR TSO ADMINISTRATOR'),M02D        02918000
*                                                              @Z40GQKU 02919000
LAST   IKJTSMSG                                                         02920000
@DATD    DSECT                                                          02922000
         DS    0D                                               DSKC193 02922010
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                02923000
@ENDDATD EQU   *                                                        02924000
IKJEFF02 CSECT                                                          02925000
R0       EQU   0                   EQUATES FOR REGISTERS 0-15   DSKC193 02926000
R1       EQU   1                                                DSKC193 02927000
R2       EQU   2                                                DSKC193 02928000
R3       EQU   3                                                DSKC193 02929000
R4       EQU   4                                                DSKC193 02930000
R5       EQU   5                                                DSKC193 02931000
R6       EQU   6                                                DSKC193 02932000
R7       EQU   7                                                DSKC193 02933000
R8       EQU   8                                                DSKC193 02934000
R9       EQU   9                                                DSKC193 02935000
R10      EQU   10                                               DSKC193 02936000
R11      EQU   11                                               DSKC193 02937000
R12      EQU   12                                               DSKC193 02938000
R13      EQU   13                                               DSKC193 02939000
R14      EQU   14                                               DSKC193 02940000
R15      EQU   15                                               DSKC193 02941000
WPLRF    EQU   0                                                        02961000
WPLRPTR  EQU   WPLRF                                                    02962000
WPL      EQU   0                                                        02963000
WPLLGH   EQU   WPL                                                      02964000
WPLMCSF  EQU   WPL+2                                                    02965000
WPLMCSF1 EQU   WPLMCSF                                                  02966000
WPLMCSF2 EQU   WPLMCSF+1                                                02967000
WPLTXT   EQU   WPL+4                                                    02968000
WPLFLGS  EQU   0                                                        02969000
WPLDESC  EQU   WPLFLGS                                                  02970000
WPLDESC1 EQU   WPLDESC                                                  02971000
WPLDESC2 EQU   WPLDESC+1                                                02972000
WPLROUT  EQU   WPLFLGS+2                                                02973000
WPLROUT1 EQU   WPLROUT                                                  02974000
WPLROUT2 EQU   WPLROUT+1                                                02975000
WPLMSGTY EQU   WPLFLGS+4                                                02976000
WPLMSGT1 EQU   WPLMSGTY                                                 02977000
WPLMSGT2 EQU   WPLMSGTY+1                                               02978000
WPLLS01  EQU   0                                                        02979000
WPLLTF   EQU   WPLLS01                                                  02980000
WPLLTF1  EQU   WPLLTF                                                   02981000
WPLML    EQU   0                                                        02982000
WPLMLLTF EQU   WPLML+2                                                  02983000
WPLMLLT1 EQU   WPLMLLTF                                                 02984000
CPPL     EQU   0                                                        02985000
CPPLUPT  EQU   CPPL+4                                                   02986000
CPPLECT  EQU   CPPL+12                                                  02987000
RET      EQU   0                                                        02988000
PMSGLIST EQU   0                                                        02989000
PCSECTP  EQU   PMSGLIST                                                 02990000
PRETXTP  EQU   PMSGLIST+4                                               02991000
PSWITCH  EQU   PRETXTP                                                  02992000
PDATASW  EQU   PSWITCH                                                  02993000
PREVERSW EQU   PSWITCH                                                  02994000
PWTOSW   EQU   PSWITCH                                                  02995000
PHEXSW   EQU   PSWITCH                                                  02996000
PKEY1SW  EQU   PSWITCH                                                  02997000
PJOBISW  EQU   PSWITCH                                                  02998000
PWTPSW   EQU   PSWITCH                                                  02999000
PNHEXSW  EQU   PSWITCH                                                  03000000
PRETEXTP EQU   PRETXTP+1                                                03001000
PSW2     EQU   PMSGLIST+8                                               03002000
P2OLDSW  EQU   PSW2                                                     03003000
PDOMSW   EQU   PSW2                                                     03004000
PNOXQSW  EQU   PSW2                                                     03005000
PNPLMSW  EQU   PSW2                                                     03006000
PPGMSW   EQU   PSW2                                                     03007000
PEXTRCON EQU   PSW2                                                     03008000
POLDPTR  EQU   PMSGLIST+12                                              03009000
PEXTRACT EQU   PMSGLIST+16                                              03010000
PEXTRLEN EQU   PEXTRACT                                                 03011000
PEXTRBUF EQU   PEXTRACT+1                                               03012000
PEXTRCT2 EQU   PMSGLIST+20                                              03013000
PEXTRLN2 EQU   PEXTRCT2                                                 03014000
PEXTRBF2 EQU   PEXTRCT2+1                                               03015000
PMSGID   EQU   PMSGLIST+24                                              03016000
PINSRTS  EQU   PMSGLIST+28                                              03017000
EXTRBUF  EQU   0                                                        03018000
EXTRBF2  EQU   0                                                        03019000
PVARFLD  EQU   0                                                        03020000
PLENGTH  EQU   PVARFLD                                                  03021000
PCONVRT  EQU   PLENGTH                                                  03022000
PVARPTR  EQU   PVARFLD+1                                                03023000
CMSGID   EQU   0                                                DSKC193 03025000
CREPLYID EQU   CMSGID+4                                         DSKC193 03026000
CMSGLEN  EQU   CMSGID+8                                         DSKC193 03027000
CNBPARTS EQU   CMSGID+10                                        DSKC193 03028000
CPARTLEN EQU   0                                                DSKC193 03030000
CMSGPART EQU   CPARTLEN+1                                       DSKC193 03031000
VARIABLE EQU   0                                                        03032000
PUTLOLD  EQU   0                                                        03033000
OLDNSEG  EQU   PUTLOLD+4                                                03034000
OLDSEGP  EQU   PUTLOLD+8                                                03035000
OLDMSEG  EQU   0                                                        03036000
OSEGLEN  EQU   OLDMSEG                                                  03037000
OSEGTEXT EQU   OLDMSEG+4                                                03038000
COREGOT  EQU   0                                                        03039000
COREHDR  EQU   COREGOT                                                  03040000
CORELAST EQU   COREHDR                                                  03041000
CORESW   EQU   COREHDR+4                                                03042000
CORENOW  EQU   COREHDR+8                                                03043000
COREMSG  EQU   COREGOT+12                                               03044000
CORELEN  EQU   COREMSG                                                  03045000
CORETEXT EQU   COREMSG+4                                                03046000
CORERTCD EQU   COREMSG+260                                              03047000
PREBUF   EQU   0                                                        03048000
PRELEN   EQU   PREBUF                                                   03049000
PRETEXT  EQU   PREBUF+2                                                 03050000
PRECHAR  EQU   2                                                DSKC193 03052000
PREHIGH  EQU   PRECHAR                                                  03053000
INBUF    EQU   0                                                        03054000
INLEN    EQU   INBUF                                                    03055000
INTEXT   EQU   INBUF+4                                                  03056000
MSGECB   EQU   0                                                        03057000
MSGTMCT  EQU   0                                                        03058000
PARM1    EQU   0                                                        03059000
TMCT     EQU   0                                                        03060000
COMECB   EQU   0                                                        03061000
@ENDDATA EQU   *                                                        03201000
         END   IKJEFF02                                         DSKC193 03202000
