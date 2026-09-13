         TITLE 'IKJEFF50 - STATUS INITIALIZATION ROUTINE               *00001000
                        '                                               00002000
IKJEFF50 CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,@15                                               0001 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL1(16)                                             0001 00007000
         DC    C'IKJEFF50  85.176'                              DSKK040 00008000
         DROP  @15                                                      00009000
@PROLOG  ST    @14,12(,@13)                                        0001 00010000
         STM   @00,@12,20(@13)                                     0001 00011000
         BALR  @12,0                                               0001 00012000
@PSTART  DS    0H                                                  0001 00013000
         USING @PSTART,@12                                         0001 00014000
         L     @00,@SIZDATD                                        0001 00015000
         GETMAIN R,LV=(0)                                               00016000
         LR    @11,@01                                             0001 00017000
         USING @DATD,@11                                           0001 00018000
         ST    @13,@SA00001+4                                      0001 00019000
         LM    @00,@01,20(@13)                                     0001 00020000
         ST    @11,8(,@13)                                         0001 00021000
         LR    @13,@11                                             0001 00022000
         MVC   @PC00001(4),0(@01)                                  0001 00023000
DUMMYLBL DS    0H                                                  0003 00024000
*                                                                    */ 00025000
*                                                                  0069 00026000
*   /*****************************************************************/ 00027000
*   /*                                                               */ 00028000
*   /* INITIALIZE LOCAL POINTERS AND SWITCHES                        */ 00029000
*   /*                                                               */ 00030000
*   /*****************************************************************/ 00031000
*                                                                  0069 00032000
*   SWITCHES=0;                     /* CLEAR THE SWITCH TABLE        */ 00033000
         SLR   @04,@04                                          DSKK040 00034000
         STC   @04,SWITCHES                                     DSKK040 00035000
*   SAVELIST=0;                     /* CLEAR STORAGE AREA            */ 00036000
         SLR   @07,@07                                          DSKK040 00037000
*   FIBCMPTR=ADDR(FIBPARML);        /* USE LOCAL PTR TO FIBCPARM FOR    00039000
*                                      EFFICIENCY                    */ 00040000
*                                                                  0071 00041000
         L     @05,@PC00001                                     DSKK040 00042000
*   /*****************************************************************/ 00043000
*   /*                                                               */ 00044000
*   /* INITIALIZE THE MESSAGE TABLE INTERFACE HERE -- SO THAT IF     */ 00045000
*   /* THERE IS AN ERROR FROM PARSE THE MESSAGE TABLE WILL ALREADY BE*/ 00046000
*   /* INITIALIZED. ALSO SERVES AS INTERFACE FOR THE REST OF THE     */ 00047000
*   /* STATUS PACKAGE                                                */ 00048000
*   /*                                                               */ 00049000
*   /*****************************************************************/ 00050000
*                                                                  0072 00051000
*   MSGTABLE=MSGTABLE&&MSGTABLE;    /* CLEAR THE MESSAGE AREA        */ 00052000
         XC    MSGTABLE(64),MSGTABLE                               0072 00053000
*   CPECB=0;                        /* ZERO COMMUNICATIONS ECB       */ 00054000
         SLR   @09,@09                                          DSKK040 00055000
*   LISTPTR=ADDR(MSGCSECT);         /* PICK UP ADDR OF PTR TO MESSAGE   00056000
*                                      CSECT                         */ 00057000
         ST    @09,CPECB                                        DSKK040 00058000
         LA    @10,MSGCSECT                                     DSKK040 00058010
         ST    @10,LISTPTR                                      DSKK040 00059000
*   ECBPTR=ADDR(CPECB);             /* PICK UP ADDR OF COMMUNICATIONS   00060000
*                                      ECB                           */ 00061000
         LA    @09,CPECB                                        DSKK040 00062000
         ST    @09,ECBPTR                                       DSKK040 00063000
*   MSGCSECT=ADDR(IKJEFF55);        /* ADDR OF MESSAGES              */ 00064000
         L     @10,@CV00064                                     DSKK040 00065000
         ST    @10,MSGCSECT                                     DSKK040 00066000
*   MSGPTR=ADDR(MSGTABLE);          /* SAVE ADDR OF PARMLIST TO MSG     00067000
*                                      ROUTINE                       */ 00068000
         LA    @09,MSGTABLE                                     DSKK040 00069000
         ST    @09,MSGPTR                                       DSKK040 00070000
*   MSGRTNPT=ADDR(IKJEFF02);        /* PICK UP ADDR OF IKJEFF02 FOR     00071000
*                                      CANCEL/STATUS PARMLIST        */ 00072000
         L     @10,@CV00063                                     DSKK040 00073000
         ST    @10,MSGRTNPT                                     DSKK040 00074000
*   MTCPPL=ADDR(FIBCPPLC);          /* PICK UP PTR TO CPPL           */ 00075000
         LA    @09,FIBCPPLC(,@05)                               DSKK040 00076000
         ST    @09,MTCPPL                                       DSKK040 00077000
*   MTPUTLSW='1'B;                  /* INDICATE WANT PUTLINE-NO    0080 00078000
*                                      STATUS MESSAGES USE PROMPTING    00079000
*                                      OTHER THAN IKJ56208A IN     0080 00080000
*                                      IKJEFF51                      */ 00081000
         OI    MTPUTLSW,B'01000000'                                0080 00082000
*   MTHIGH='1'B;                    /* FOR STANDARD LINKAGE          */ 00083000
         OI    MTHIGH,B'10000000'                                  0081 00084000
*   SWITCHES=SWITCHES&&SWITCHES;    /* ZERO SWITCHES                 */ 00085000
         LR    @10,@04                                          DSKK040 00086000
         XR    @10,@04                                          DSKK040 00087000
         STC   @10,SWITCHES                                     DSKK040 00088000
*   IF FIBECTNO^='1'B THEN          /* IF STATUS CMND WITH OPERANDS  */ 00089000
         TM    FIBECTNO(@05),B'10000000'                        DSKK040 00090000
         BO    @RF00083                                            0083 00091000
*STATOP:                                                           0084 00092000
*     DO;                           /* CHECK TO SEE IF STATUS WAS  0084 00093000
*                                      ENTERED WITH NO OPERANDS==IF     00094000
*                                      YES THEN BRANCH TO BUILD AN 0084 00095000
*                                      AUTOMATIC LIST==IF NO THEN  0084 00096000
*                                      FALL THROUGH                  */ 00097000
STATOP   DS    0H                                                  0085 00098000
*       STATUSSW='1'B;              /* TURN ON STATUS SWITCH IN-   0085 00099000
*                                      DICATING THE COMMAND STATUS 0085 00100000
*                                      WAS ENTERED                 0085 00101000
*                                                                    */ 00102000
         OI    STATUSSW,B'01000000'                                0085 00103000
*                                                                  0086 00104000
*       /*************************************************************/ 00105000
*       /*                                                           */ 00106000
*       /* STATUS COMMAND WITH OPERAND -- INITIALIZE THE PARSE       */ 00107000
*       /* INTERFACE TABLE                                           */ 00108000
*       /*                                                           */ 00109000
*       /*************************************************************/ 00110000
*                                                                  0086 00111000
*       PPLPTR=ADDR(PPLLN);         /* GET PPL SOME STORAGE          */ 00112000
         LA    @04,PPLLN                                        DSKK040 00113000
*       PPLPCL=ADDR(IKJEFF5A);      /* PICK UP PCL FOR PARSE         */ 00114000
         L     @06,@CV00065                                     DSKK040 00115000
         ST    @06,PPLPCL(,@04)                                 DSKK040 00116000
*       PPLUPT=FIBCPPLU;            /* PICK UP UPT ADDRESS           */ 00117000
         L     @10,FIBCPPLU(,@05)                               DSKK040 00118000
         ST    @10,PPLUPT(,@04)                                 DSKK040 00119000
*       PPLECT=FIBCPPLE;            /* PICK UP ECT ADDRESS           */ 00120000
         L     @09,FIBCPPLE(,@05)                               DSKK040 00121000
         ST    @09,PPLECT(,@04)                                 DSKK040 00122000
*       PPLECB=ADDR(CPECB);         /* PTR TO COMMUNICATIONS ECB     */ 00123000
         LA    @10,CPECB                                           0090 00124000
         ST    @10,PPLECB(,@04)                                 DSKK040 00125000
*       PERMPDLP=0;                 /* INIT PTR TO PDE TO ZERO       */ 00126000
         SLR   @06,@06                                          DSKK040 00127000
         ST    @06,PERMPDLP                                     DSKK040 00128000
*       PPLANS=ADDR(PERMPDLP);      /* WITHIN THIS AREA PARSE WILL 0092 00129000
*                                      PLACE A PTR TO PDL            */ 00130000
         LA    @09,PERMPDLP                                     DSKK040 00131000
         ST    @09,PPLANS(,@04)                                 DSKK040 00132000
*       PPLCBUF=FIBCPPLC;           /* POINT TO INPUT COMMAND BUFFER */ 00133000
         L     @09,FIBCPPLC(,@05)                               DSKK040 00134000
         ST    @09,PPLCBUF(,@04)                                DSKK040 00135000
*       PPLUWA=0;                   /* INITIALIZE PARSE WORK AREA    */ 00136000
*                                                                  0094 00137000
         ST    @06,PPLUWA(,@04)                                 DSKK040 00138000
*       /*************************************************************/ 00139000
*       /*                                                           */ 00140000
*       /* CALL PARSE TO SYNTAX CHECK THE COMMAND BUFFER             */ 00141000
*       /*                                                           */ 00142000
*       /*************************************************************/ 00143000
*                                                                  0095 00144000
*SETKEY0:                                                          0095 00145000
*       GEN(MODESET EXTKEY=SUPR,RELATED=(KEY0,IKJEFF50(SETKEY1)));/*    00146000
*                                      SEE SUBPOOL NOTES             */ 00147000
*       RFY                                                        0096 00149000
*        (R1,                                                      0096 00150000
*         R15) RSTD;                                               0096 00151000
*       R1=PPLPTR;                  /* PTR TO PARSE PARAM LIST       */ 00152000
         LR    @01,@04                                          DSKK040 00153000
*       DO;                         /* CALLTSSR EP(IKJPARS)          */ 00154000
*         RESPECIFY                                                0099 00155000
*           GPR01P RSTD;                                           0099 00156000
*         IF CVTPARS=0 THEN                                        0100 00157000
         L     @10,CVTPTR                                       DSKK040 00158000
         C     @06,CVTPARS(,@10)                                DSKK040 00159000
         BNZ   @RF00100                                            0100 00161000
*           GEN(LINK EP=IKJPARS);                                  0101 00162000
         LINK EP=IKJPARS                                                00163000
*         ELSE                                                     0102 00164000
*           CALL CVTPARS;                                          0102 00165000
         B     @RC00100                                            0102 00166000
@RF00100 L     @04,CVTPTR                                       DSKK040 00167000
         L     @15,CVTPARS(,@04)                                DSKK040 00168000
         BALR  @14,@15                                             0102 00169000
*         RESPECIFY                                                0103 00170000
*           GPR01P UNRSTD;                                         0103 00171000
@RC00100 DS    0H                                                  0104 00172000
*       END;                                                       0104 00173000
*       RETCODE=R15;                /* SAVE PARSE R.C.               */ 00174000
*       /*************************************************************/ 00187000
*       /*                                                           */ 00188000
*       /* CHECK PARSE'S RETURN CODE - IF O.K. GET CORE FOR JOBLIST  */ 00189000
*       /* TABLE                                                     */ 00190000
*       /*                                                           */ 00191000
*       /*************************************************************/ 00192000
*                                                                  0109 00193000
*       IF RETCODE=PARSER0 THEN                                    0109 00194000
         LR    @06,@15                                          DSKK040 00195000
         LTR   @06,@06                                          DSKK040 00196000
         BNZ   @RF00109                                            0109 00197000
*PARSRET:                                                          0110 00198000
*         DO;                       /* IF NO ERROR FROM PARSE CONT 0110 00199000
*                                      PROCESSING                    */ 00200000
PARSRET  DS    0H                                                  0111 00201000
*           TBLCOUNT=1;             /* INIT COUNT OF PDES TO ONE     */ 00202000
         MVC   TBLCOUNT(4),@CF00037                                0111 00203000
*           PDEPTR=PERMPDLP+HEADER; /* PICK UP PTR TO FIRST PDE      */ 00204000
         L     @03,PERMPDLP                                     DSKK040 00205000
         AL    @03,HEADER                                       DSKK040 00206000
*           DO WHILE CHAINPTR^=0;   /* FIND OUT HOW MANY PDES ARE  0113 00207000
*                                      PRESENT SO THAT WILL HAVE THE    00208000
*                                      NUMBER OF JOBS TO GET CORE FOR*/ 00209000
         B     @DE00113                                            0113 00210000
@DL00113 DS    0H                                                  0114 00211000
*             IF PRESENT='1'B THEN  /* IF JOBID PRESNT COUNT IT TOO  */ 00212000
         TM    PRESENT(@03),B'10000000'                         DSKK040 00213000
         BNO   @RF00114                                            0114 00214000
*               TBLCOUNT=TBLCOUNT+1;                               0115 00215000
         LA    @04,1                                            DSKK040 00216000
         AL    @04,TBLCOUNT                                     DSKK040 00217000
         ST    @04,TBLCOUNT                                     DSKK040 00218000
*             PDEPTR=LAST;          /* IF THIS IS NOT THE LAST PDE 0116 00219000
*                                      THEN POINT TO THE NEXT PDE IN    00220000
*                                      LIST                          */ 00221000
@RF00114 L     @03,LAST(,@03)                                   DSKK040 00222000
*             TBLCOUNT=TBLCOUNT+1;  /* UPDATE COUNT OF PDES          */ 00223000
         LA    @04,1                                            DSKK040 00224000
         AL    @04,TBLCOUNT                                     DSKK040 00225000
         ST    @04,TBLCOUNT                                     DSKK040 00226000
*           END;                                                   0118 00227000
@DE00113 L     @07,CHAINPTR-1(,@03)                             DSKK040 00228000
         LA    @07,0(,@07)                                      DSKK040 00229000
         LTR   @07,@07                                          DSKK040 00229010
         BNE   @DL00113                                         DSKK040 00229020
*           IF PRESENT='1'B THEN    /* IF LAST PDE CONTAINED A JOBID    00230000
*                                      WILL NOT BE ABLE TO TELL IT SO   00231000
*                                      UPDATE PDECOUNT IF ONE PRESENT*/ 00232000
         TM    PRESENT(@03),B'10000000'                         DSKK040 00233000
         BNO   @RF00119                                            0119 00234000
*             TBLCOUNT=TBLCOUNT+1;                                 0120 00235000
         LA    @10,1                                               0120 00236000
         AL    @10,TBLCOUNT                                        0120 00237000
         ST    @10,TBLCOUNT                                        0120 00238000
*           RFY                                                    0121 00239000
*            (R0,                                                  0121 00240000
*             R1) RSTD;                                            0121 00241000
@RF00119 DS    0H                                                  0122 00242000
*           R0=TBLCOUNT*LEN;        /* NOW KNOW HOW MANY NAMES & IDS    00243000
*                                      WERE ENTERED SO MULTIPLY BY 0122 00244000
*                                      NINE IN ORDER TO GET STOR- AGE   00245000
*                                      FOR JOBNAMES(JOBIDS)          */ 00246000
         L     @15,TBLCOUNT                                     DSKK040 00247000
         M     @14,LEN                                          DSKK040 00248000
         LR    @00,@15                                          DSKK040 00249000
         LR    @08,@00                                          DSKK040 00249010
*           SAVECTR=R0;             /* SAVE AMT OF CORE FOR LATER  0123 00250000
*                                      FREEMAIN                      */ 00251000
*           GEN(GETMAIN R,LV=(0));  /* GET THE CORE                  */ 00253000
         GETMAIN R,LV=(0)                                               00254000
*           JOBLISTP=R1;            /* PLACE PTR TO CORE IN JOB LIST    00255000
*                                      PTR                           */ 00256000
         ST    R1,JOBLISTP                                         0125 00257000
*           SAVELIST=R1;            /* SAVE THE ADDR OF THE TOP OF 0126 00258000
*                                      THE JOB NAME LIST             */ 00259000
         LR    @07,@01                                          DSKK040 00260000
*           RFY                                                    0127 00261000
*            (R0,                                                  0127 00262000
*             R1) UNRSTD;                                          0127 00263000
*           PDEPTR=PERMPDLP+HEADER; /* RESET PDE PTR TO PT TO BE-  0128 00264000
*                                      GINNING OF PDE CHAIN          */ 00265000
*                                                                  0128 00266000
         L     @03,PERMPDLP                                     DSKK040 00267000
         AL    @03,HEADER                                       DSKK040 00268000
*           /*********************************************************/ 00269000
*           /*                                                       */ 00270000
*           /* THE FOLLOWING CODE PLACES THE JOBNAME BEING POINTED TO*/ 00271000
*           /* FROM THE PDE INTO A JOB LIST TABLE                    */ 00272000
*           /*                                                       */ 00273000
*           /*********************************************************/ 00274000
*                                                                  0129 00275000
*           DO K=1 TO TBLCOUNT;     /* INITIALIZE TABLE              */ 00276000
         LA    @02,1                                            DSKK040 00277000
         B     @DE00129                                            0129 00278000
@DL00129 DS    0H                                                  0130 00279000
*             JOBNMID(K)=JOBNAME(1:NAMELEN);                       0130 00280000
         L     @04,JOBLISTP                                     DSKK040 00281000
         LA    @09,9                                            DSKK040 00282000
         LR    @01,@02                                          DSKK040 00283000
         MR    @00,@09                                          DSKK040 00284000
         ST    @01,@TF00001                                        0130 00285000
         ALR   @01,@04                                          DSKK040 00286000
         AL    @01,@CF00878                                        0130 00287000
         MVI   JOBNMID(@01),C' '                                   0130 00288000
         MVC   JOBNMID+1(6,@01),JOBNMID(@01)                       0130 00289000
         LH    @10,NAMELEN(,@03)                                DSKK040 00290000
         BCTR  @10,0                                            DSKK040 00291000
         L     @14,JOBNAMEP(,@03)                               DSKK040 00292000
         EX    @10,@SM00879                                     DSKK040 00293000
*             LEN1(K)='00'X;        /* INITIALLY ZERO SW BIT         */ 00294000
         LR    @10,@04                                          DSKK040 00295000
         AL    @10,@TF00001                                     DSKK040 00296000
         AL    @10,@CF00881                                     DSKK040 00297000
         MVI   LEN1(@10),X'00'                                  DSKK040 00298000
*             IF PRESENT='1'B THEN  /* IF A JOBID WAS ENTERED CONT   */ 00299000
         TM    PRESENT(@03),B'10000000'                         DSKK040 00300000
         BNO   @RF00132                                            0132 00301000
*               DO;                                                0133 00302000
*                 LEN1(K)=IDJOBID;  /* SW INDCATR THAT JOBID IS NEXT    00303000
*                                      IN LIST                       */ 00304000
         LR    @10,@04                                          DSKK040 00305000
         AL    @10,@TF00001                                     DSKK040 00306000
         AL    @10,@CF00881                                     DSKK040 00307000
         MVI   LEN1(@10),X'44'                                  DSKK040 00308000
*                 JOBNMID(K+1)=JOBID(1:JOBIDLN);/* PICK UP JOBID     */ 00309000
         LR    @10,@04                                          DSKK040 00310000
         AL    @10,@TF00001                                     DSKK040 00311000
         MVI   JOBNMID+1(@10),C' '                              DSKK040 00312000
         MVC   JOBNMID+2(6,@10),JOBNMID+1(@10)                  DSKK040 00313000
         LH    @14,JOBIDLN(,@03)                                DSKK040 00314000
         BCTR  @14,0                                            DSKK040 00315000
         L     @01,JOBIDP(,@03)                                 DSKK040 00316000
         EX    @14,@SM00882                                     DSKK040 00317000
*                 K=K+1;                                           0136 00318000
         AL    @02,@CF00037                                     DSKK040 00319000
*                 LEN1(K)=IDJOBNM;                                 0137 00320000
         LR    @15,@09                                          DSKK040 00321000
         MR    @14,@02                                          DSKK040 00322000
         ALR   @04,@15                                          DSKK040 00323000
         AL    @04,@CF00881                                     DSKK040 00324000
         MVI   LEN1(@04),X'00'                                  DSKK040 00325000
*               END;                                               0138 00326000
*             PDEPTR=CHAINPTR;      /* UPDATE PDEPTR TO NEXT PDE     */ 00327000
@RF00132 L     @04,CHAINPTR-1(,@03)                             DSKK040 00328000
         LA    @04,0(,@04)                                      DSKK040 00329000
         LR    @03,@04                                          DSKK040 00330000
*           END;                                                   0140 00331000
         AL    @02,@CF00037                                     DSKK040 00332000
@DE00129 C     @02,TBLCOUNT                                     DSKK040 00333000
         BNH   @DL00129                                            0140 00334000
*           LEN1(TBLCOUNT)=IDLASTJB;/* INDICATE END OF LIST          */ 00335000
         L     @09,TBLCOUNT                                     DSKK040 00336000
         MH    @09,@CH00754                                     DSKK040 00337000
         L     @10,JOBLISTP                                     DSKK040 00338000
         ALR   @10,@09                                          DSKK040 00339000
         AL    @10,@CF00881                                     DSKK040 00340000
         MVI   LEN1(@10),X'80'                                  DSKK040 00341000
*           GEN(IKJRLSA PERMPDLP);  /* FREE THE PDE CHAIN            */ 00342000
         IKJRLSA PERMPDLP                                               00343000
*         END PARSRET;                                             0143 00344000
*                                                                  0144 00345000
*       /*************************************************************/ 00346000
*       /*                                                           */ 00347000
*       /* ERROR FROM PARSE                                          */ 00348000
*       /*                                                           */ 00349000
*       /*************************************************************/ 00350000
*                                                                  0144 00351000
*       ELSE                                                       0144 00352000
*         DO;                                                      0144 00353000
         B     @RC00109                                            0144 00354000
@RF00109 DS    0H                                                  0145 00355000
*           QUIT=ON;                /* ERROR FROM PARSE SO TURN ON 0145 00356000
*                                      QUIT BIT                      */ 00357000
*                                                                  0145 00358000
         OI    QUIT,B'00001000'                                    0145 00359000
*           /*********************************************************/ 00360000
*           /*                                                       */ 00361000
*           /* CALL IKJEFF19 (GENLFAIL) TO ISSUE PARSE ERROR MESSAGE */ 00362000
*           /*                                                       */ 00363000
*           /*********************************************************/ 00364000
*                                                                  0146 00365000
*           GFPARMS=GFPARMS&&GFPARMS;/* ZERO OUT PARAMETER LIST      */ 00366000
         XC    GFPARMS(44),GFPARMS                                 0146 00367000
*           GFCALLID=GFPARSE;       /* NO MSGS PUT OUT FOR PARSE   0147 00368000
*                                      RETURN CODES 4 AND 20, R.C.4 =   00369000
*                                      PARSE UNABLE TO PROMPT USER 0147 00370000
*                                      (ISSUES MESSAGE), R.C.20 =  0147 00371000
*                                      VALIDITY CHECK EXIT TERMINATED   00372000
*                                      (N/A)                         */ 00373000
         MVC   GFCALLID(2),@CH00744                                0147 00374000
*           GFRCODE=RETCODE;        /* NEED REGISTER 15 CODE FROM  0148 00375000
*                                      PARSE                         */ 00376000
         ST    @06,GFRCODE                                      DSKK040 00377000
         L     @06,MSGRTNPT                                     DSKK040 00378000
*           GFKEYN08=ON;            /* TELL IKJEFF19 TO ISSUE MESSAGE   00379000
*                                      IN KEY 0                      */ 00380000
         ST    @06,GF02PTR                                      DSKK040 00381000
*           GF02PTR=MSGRTNPT;       /* POINT TO IKJEFF02, SINCE    0150 00382000
*                                      ALREADY LOADED                */ 00383000
         L     @10,MTCPPL                                       DSKK040 00384000
         ST    @10,GFCPPLP                                      DSKK040 00385000
*           GFCPPLP=MTCPPL;         /* CPPL NEEDED WHEN ISSUE PUTLINE*/ 00386000
         L     @06,ECBPTR                                       DSKK040 00387000
         ST    @06,GFECBP                                       DSKK040 00388000
*           GFECBP=ECBPTR;          /* ECB FOR PUTLINE               */ 00389000
*                                                                  0152 00390000
*           /*********************************************************/ 00393000
*           /*                                                       */ 00394000
*           /* CALL GENLFAIL                                         */ 00395000
*           /*                                                       */ 00396000
*           /*********************************************************/ 00397000
*                                                                  0153 00398000
*           RFY                                                    0153 00399000
*             R0 RSTD;                                             0153 00400000
*           GEN(LOAD EP=IKJEFF19);                                 0154 00401000
         LOAD EP=IKJEFF19                                               00402000
*           CALL IKJEFF19(GFPARMS); /* CALL GENLFAIL SERVICE ROUTINE */ 00403000
         LA    @09,GFPARMS                                      DSKK040 00404000
         ST    @09,@AL00001                                     DSKK040 00405000
         LR    @15,R0                                              0155 00406000
         LA    @01,@AL00001                                        0155 00407000
         BALR  @14,@15                                             0155 00408000
*           GEN(DELETE EP=IKJEFF19);                               0156 00409000
         DELETE EP=IKJEFF19                                             00410000
*           RFY                                                    0157 00411000
*             R0 UNRSTD;                                           0157 00412000
*           RETCODE=CMDRC12;        /* INDICATE ERROR OCCURRED       */ 00413000
         LA    @06,12                                           DSKK040 00414000
*         END;                                                     0159 00415000
*     END STATOP;                                                  0160 00416000
*                                                                  0161 00417000
*   /*****************************************************************/ 00418000
*   /*                                                               */ 00419000
*   /* STATUS WITH NO OPERANDS -- PUT USERID IN JOBLIST              */ 00420000
*   /*                                                               */ 00421000
*   /*****************************************************************/ 00422000
*                                                                  0161 00423000
*   ELSE                                                           0161 00424000
*STATLIST:                          /* LABEL FOR DO/END GROUP        */ 00425000
*     DO;                                                          0161 00426000
         B     @RC00083                                            0161 00427000
@RF00083 DS    0H                                                  0161 00428000
STATLIST DS    0H                                                  0162 00429000
*       STATAUTO='1'B;              /* THE USER ENTERED STATUS WITH     00430000
*                                      NO OPERANDS SO TURN ON THE  0162 00431000
*                                      'CREATE AN AUTOMATIC LIST' BIT*/ 00432000
         OI    STATAUTO,B'00100000'                                0162 00433000
*       MTKEY1SW='1'B;              /* INDICATE IN KEY 1 (SCHEDULER)    00434000
*                                      - SEE SUBPOOL NOTES           */ 00435000
*       RFY                                                        0164 00437000
*        (R0,                                                      0164 00438000
*         R1) RSTD;                                                0164 00439000
*       R0=AUTOCTR*LEN;             /* DETERMINE AMT OF CORE TO GET  */ 00440000
         L     @03,AUTOCTR                                         0165 00441000
         M     @02,LEN                                             0165 00442000
         LR    R0,@03                                              0165 00443000
*       SAVECTR=R0;                 /* SAVE AMT OF CORE FOR LATER  0166 00444000
*                                      FREEMAIN                      */ 00445000
         LR    @08,@00                                          DSKK040 00446000
*       GEN(GETMAIN R,LV=(0));      /* GETMAIN THE NECESSARY AMOUNT     00447000
*                                      OF CORE                       */ 00448000
         GETMAIN R,LV=(0)                                               00449000
*       JOBLISTP=R1;                /* PLACE THE POINTER TO THE CORE    00450000
*                                      IN THE JOBNAMELIST FIELD      */ 00451000
         ST    R1,JOBLISTP                                         0168 00452000
*       SAVELIST=R1;                /* SAVE THE POINTER TO THE HEAD     00453000
*                                      OF THE JOB NAME LIST          */ 00454000
         LR    @07,@01                                          DSKK040 00455000
*       RFY                                                        0170 00456000
*        (R0,                                                      0170 00457000
*         R1) UNRSTD;                                              0170 00458000
*       TBLCOUNT=AUTOCTR;           /* SET THE COUNT TO INDICATE A 0171 00459000
*                                      TABLE OF 1 ENTRY WAS BUILT    */ 00460000
         L     @09,AUTOCTR                                      DSKK040 00461000
         ST    @09,TBLCOUNT                                     DSKK040 00462000
*       LEN1(TBLCOUNT)=FIBPSCBL;    /* INDICATE LENGTH OF USERID     */ 00463000
         L     @10,JOBLISTP                                     DSKK040 00464000
         MH    @09,@CH00754                                     DSKK040 00465000
         SLR   @04,@04                                             0172 00466000
         IC    @04,FIBPSCBL(,@05)                               DSKK040 00467000
         LA    @01,0(@09,@10)                                   DSKK040 00468000
         AL    @01,@CF00881                                        0172 00469000
         STC   @04,LEN1(,@01)                                      0172 00470000
*       JOBNMID(TBLCOUNT)=FIBPSCBU(1:FIBPSCBL);/* SAVE USERID IN JOB    00471000
*                                      LIST - IF STATAUTO IS ON    0173 00472000
*                                      IKJEFF52 WILL PASS THE USERID    00473000
*                                      TO THE JOB ENTRY SUBSYSTEM, 0173 00474000
*                                      WHICH WILL RETURN STATUS FOR     00475000
*                                      JOBNAMES = USERID + 1 CHAR    */ 00476000
         ALR   @10,@09                                          DSKK040 00477000
         AL    @10,@CF00878                                     DSKK040 00478000
         MVI   JOBNMID(@10),C' '                                DSKK040 00479000
         MVC   JOBNMID+1(6,@10),JOBNMID(@10)                    DSKK040 00480000
         BCTR  @04,0                                               0173 00481000
         EX    @04,@SM00885                                        0173 00482000
*     END STATLIST;                 /* END OF BUILD 39-LIST JOB NAME    00483000
*                                      SECTION                     0174 00484000
*                                                                    */ 00485000
*   IF QUIT^='1'B THEN              /* IF NO ERRORS HAVE OCCURRED TO    00486000
*                                      THIS POINT THEN CONTINUE    0175 00487000
*                                      PROCESSING                    */ 00488000
@RC00083 TM    QUIT,B'00001000'                                    0175 00489000
         BO    @RF00175                                            0175 00490000
*NOERR:                             /* CALL NEXT MODULE IF NO ERROR     00491000
*                                      SO FAR                        */ 00492000
*     DO;                                                          0176 00493000
*                                                                  0176 00494000
NOERR    DS    0H                                                  0177 00495000
*       /*************************************************************/ 00496000
*       /*                                                           */ 00497000
*       /* SET UP PARAMETERS TO PASS INTO IKJEFF51                   */ 00498000
*       /*                                                           */ 00499000
*       /*************************************************************/ 00500000
*                                                                  0177 00501000
*       CSPTR1=ADDR(FIBCPARM);      /* R1 -> CSPTR1 -> FIBCPARM      */ 00502000
         ST    @05,CSPTR1                                       DSKK040 00503000
*       CSPTR2=ADDR(PARMLIST);      /* PASS A POINTER TO           0178 00504000
*                                      CANCEL/STATUS PARAMETER LIST,    00505000
*                                      ALSO                          */ 00506000
         LA    @06,PARMLIST                 033A 41A0 B0AC      DSKK040 00507000
         ST    @06,CSPTR2                   033E 50A0 B07C      DSKK040 00508000
*       CSHIGH='1'B;                /* STANDARD LINKAGE CONVENTION   */ 00509000
*                                                                  0179 00510000
         OI    CSHIGH,B'10000000'                                  0179 00511000
*       /*************************************************************/ 00512000
*       /*                                                           */ 00513000
*       /* INITIALIZE PARAMETER LIST BEING POINTED TO BY CSPTR2      */ 00514000
*       /*                                                           */ 00515000
*       /*************************************************************/ 00516000
*                                                                  0180 00517000
*       JOBLISTP=SAVELIST;          /* RESTORE POINTER TO TOP OF JOB    00518000
*                                      NAME LIST                     */ 00519000
         ST    @07,JOBLISTP                 0346 5060 B0AC      DSKK040 00520000
*       NUMJOBSP=ADDR(TBLCOUNT);    /* INDICATE NO. OF JOB NAMES TO     00521000
*                                      BE PROCESSED                  */ 00522000
         LA    @09,TBLCOUNT                 034A 41A0 B05C      DSKK040 00523000
         ST    @09,NUMJOBSP                 034E 50A0 B0B0      DSKK040 00524000
*       SWITPTR=ADDR(SWITCHES);     /* PICK ADDR OF SWITCH TABLE-  0182 00525000
*                                      WHICH WILL INDICATE WHAT    0182 00526000
*                                      COMMAND WAS ENTERED           */ 00527000
         LA    @10,SWITCHES                                        0182 00528000
         ST    @10,SWITPTR                                         0182 00529000
*       PTHIGH='1'B;                /* INDICATE END OF CANCEL/STATUS    00530000
*                                      PARMLIST                      */ 00531000
         OI    PTHIGH,B'10000000'                                  0183 00532000
*       RFY                                                        0184 00533000
*        (R0,                                                      0184 00534000
*         R1,                                                      0184 00535000
*         R15) RSTD;                                               0184 00536000
*       R1=ADDR(CSPTRS);            /* SET UP REG ONE AS CONVEYOR OF    00537000
*                                      PARAMETERS                    */ 00538000
         MVI   B000118,0                                        DSKK040 00538010
         MVI   B000118+1,0                                      DSKK040 00538020
         MVI   B000118+2,0                                      DSKK040 00538030
         MVI   B000118+3,X'0C'                                  DSKK040 00538040
         MODESET MF=(E,B000118)                                 DSKK040 00538050
         LA    R1,CSPTRS                                           0185 00539000
*       GENERATE;                                                  0186 00540000
*                                    /* LINK TO IKJEFF51 */             00541000
            LINK  EP=IKJEFF51        CALL THE COMMAND CHECK RTN CANCEL  00542000
*       RETCODE=R15;                /* SAVE RETURN CODE FROM IKJEFF51*/ 00543000
         LR    @06,@15                                          DSKK040 00544000
         MVI   B000118,0                                        DSKK040 00544010
         MVI   B000118+1,0                                      DSKK040 00544020
         MVI   B000118+2,0                                      DSKK040 00544030
         MVI   B000118+3,X'04'                                  DSKK040 00544040
         MODESET MF=(E,B000118)                                 DSKK040 00544050
*     END NOERR;                                                   0188 00545000
*                                                                  0189 00546000
*   /*****************************************************************/ 00547000
*   /*                                                               */ 00548000
*   /* CLEAN-UP CODE AFTER ERROR OR RETURN FROM IKJEFF51             */ 00549000
*   /*                                                               */ 00550000
*   /*****************************************************************/ 00551000
*                                                                  0189 00552000
*   IF SAVELIST^=0 THEN             /* IF ANY CORE WAS OBTAINED THEN    00553000
*                                      FREE IT                       */ 00554000
@RF00175 LTR   @07,@07                                          DSKK040 00555000
         BZ    @RF00189                                            0189 00556000
*     DO;                                                          0190 00557000
*       R0=SAVECTR;                 /* INDICATE LENGTH OF CORE TO  0191 00558000
*                                      FREE                          */ 00559000
         LR    @00,@08                                          DSKK040 00560000
*       R1=SAVELIST;                /* POINT TO WHERE CORE EXISTS    */ 00561000
         LR    @01,@07                                          DSKK040 00562000
*       GEN(FREEMAIN R,LV=(0),A=(1));/* FREE THE CORE                */ 00563000
         FREEMAIN R,LV=(0),A=(1)                                        00564000
*     END;                                                         0194 00565000
*   RFY                                                            0195 00566000
*    (R0,                                                          0195 00567000
*     R1,                                                          0195 00568000
*     R15) UNRSTD;                                                 0195 00569000
@RF00189 DS    0H                                                  0196 00570000
*   RETURN CODE(RETCODE);           /* RETURN WITH APPROPRIATE CODE     00571000
*                                                                    */ 00572000
         L     @13,4(,@13)                                      DSKK040 00573000
         L     @00,@SIZDATD                                        0196 00575000
         LR    @01,@11                                             0196 00576000
         FREEMAIN R,LV=(0),A=(1)                                        00577000
         LR    @15,@06                                          DSKK040 00578000
         L     @14,12(,@13)                                        0196 00579000
         LM    @00,@12,20(@13)                                     0196 00580000
         BR    @14                                                 0196 00581000
*                                                                  0197 00582000
*/****************************************************************** */ 00583000
*/*                                                                  */ 00584000
*/*    PCL/PCE MACROS DESCRIBING SYNTAX OF STATUS COMMAND TO PARSE   */ 00585000
*/*                                                                  */ 00586000
*/*    - ONE POSITIONAL PARAMETER (JOBNAME OR JOBNAME LIST)          */ 00587000
*/*        JOBNAME CAN BE IN THE FORM JOBNAME(JOBID) OR JOBNAME ONLY */ 00588000
*/*    - IF PARSE FINDS A SYNTAX ERROR IT WILL INSERT THE PROMPT=    */ 00589000
*/*        INFO INTO ITS PROMPT MESSAGE    'ENTER <TEXT> -'          */ 00590000
*/*    - THE HELP= TEXT IS USED AS A SECOND LEVEL MESSAGE            */ 00591000
*/*        'ENTER <TEXT>' FOR PARSE PROMPT MESSAGES                  */ 00592000
*/*    - NOTE: THE PARSE JOBNAME RTN WILL CHECK JOBNAME AND JOBID    */ 00593000
*/*            FOR ALPHA-NUMERIC, 1ST CHARACTER ALPHA, MAX 8 CHARS.  */ 00594000
*/*    - NOTE: THE MAXIMUM LENGTH FOR HELP= TEXT IS 255 CHARACTERS   */ 00595000
*/*                                                                  */ 00596000
*/********************************************************************/ 00597000
*                                                                  0197 00598000
*   GENERATE;                                                      0197 00599000
IKJEFF5A IKJPARM                                                        00600000
IKJP1    IKJPOSIT JOBNAME,                                             X00601000
               LIST,                                                   X00602000
               PROMPT='JOBNAME OR JOBNAME(JOBID)',                     X00603000
               HELP='ALPHANUMERIC NAME(S), WITH FIRST CHARACTER ALPHABEX00604000
               TIC AND MAXIMUM OF 8 CHARACTERS.  JOBNAME IS THE NAME ONX00605000
                THE JOB CARD AND JOBID IS THE ID ASSIGNED BY THE JOB ENX00606000
               TRY SUBSYSTEM AT THE TIME THE JOB WAS SUBMITTED.'        00607000
         IKJENDP                                                        00608000
IKJEFF50 CSECT                                                          00609000
*   END IKJEFF50                                                   0198 00610000
*                                                                  0198 00611000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00612000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 00613000
*/*%INCLUDE SYSLIB  (IKJEFFB2)                                       */ 00614000
*/*%INCLUDE SYSLIB  (IKJEFFGF)                                       */ 00615000
*/*%INCLUDE SYSLIB  (IKJEFFPT)                                       */ 00616000
*/*%INCLUDE SYSLIB  (IKJEFFMT)                                       */ 00617000
*/*%INCLUDE SYSLIB  (IKJPPL  )                                       */ 00618000
*                                                                  0198 00619000
*       ;                                                          0198 00620000
@EL00001 L     @13,4(,@13)                                         0198 00621000
@EF00001 L     @00,@SIZDATD                                        0198 00622000
         LR    @01,@11                                             0198 00623000
         FREEMAIN R,LV=(0),A=(1)                                        00624000
@ER00001 L     @14,12(,@13)                                        0198 00625000
         LM    @00,@12,20(@13)                                     0198 00626000
         BR    @14                                                 0198 00627000
@DATA    DS    0H                                                       00628000
@CH00754 DC    H'9'                                                     00629000
@CH00744 DC    H'21'                                                    00630000
@SM00879 MVC   JOBNMID-1(0,@01),JOBNAME(@14)                    DSKK040 00631000
@SM00882 MVC   JOBNMID(0,@10),JOBID(@01)                        DSKK040 00632000
@SM00885 MVC   JOBNMID-1(0,@10),FIBPSCBU(@05)                   DSKK040 00633000
@DATD    DSECT                                                          00634000
         DS    0F                                                       00635000
@SA00001 DS    18F                                                      00636000
@PC00001 DS    1F                                                       00637000
@AL00001 DS    1A                                                       00638000
@TF00001 DS    F                                                        00639000
IKJEFF50 CSECT                                                          00640000
         DC    X'E008'                       !!! SOURCE COMPARE FIX !!! 00641000
         DC    0F'0'                                            DSKK040 00641000
@CF00037 DC    F'1'                                                     00642000
@CF00881 DC    F'-9'                                                    00645000
@CF00878 DC    F'-8'                                                    00646000
@DATD    DSECT                                                          00647000
         DS    0D                                                       00648000
TBLCOUNT DS    A                                                        00650000
PERMPDLP DS    A                                                        00651000
CPECB    DS    F                                                        00652000
I        DS    A                                                        00653000
LOOP     DS    F                                                        00654000
REGHOLD  DS    A                                                        00655000
SWITCHES DS    AL1                                                      00657000
         ORG   SWITCHES                                                 00658000
CANCELSW DS    BL1                                                      00659000
STATUSSW EQU   SWITCHES+0                                               00660000
STATAUTO EQU   SWITCHES+0                                               00661000
JOBIDSW  EQU   SWITCHES+0                                               00662000
QUIT     EQU   SWITCHES+0                                               00663000
PTPURGSW EQU   SWITCHES+0                                               00664000
@NM00010 EQU   SWITCHES+0                                               00665000
         ORG   SWITCHES+1                                               00666000
         DS    0A                                               DSKK040 00667000
CSPTRS   DS    CL8                                                      00668000
         ORG   CSPTRS                                                   00669000
CSPTR1   DS    AL4                                                      00670000
CSPTR2   DS    AL4                                                      00671000
         ORG   CSPTR2                                                   00672000
CSHIGH   DS    BL1                                                      00673000
         ORG   CSPTRS+8                                                 00674000
GFPARMS  DS    CL44                                                     00675000
         ORG   GFPARMS                                                  00676000
GFCBPTR  DS    AL4                                                      00677000
GFRCODE  DS    FL4                                                      00678000
GF02PTR  DS    AL4                                                      00679000
GFCALLID DS    FL2                                                      00680000
GFBITS   DS    BL1                                                      00681000
         ORG   GFBITS                                                   00682000
GFKEYN08 DS    BL1                                                      00683000
GFSUBSYS EQU   GFBITS+0                                                 00684000
GFWTPSW  EQU   GFBITS+0                                                 00685000
@NM00006 EQU   GFBITS+0                                                 00686000
         ORG   GFPARMS+15                                               00687000
@NM00007 DS    AL1                                                      00688000
GFCPPLP  DS    AL4                                                      00689000
GFECBP   DS    AL4                                                      00690000
GFDSNLEN DS    FL2                                                      00691000
GFPGMNL  DS    FL2                                                      00692000
GFDSNP   DS    AL4                                                      00693000
GFPGMNP  DS    AL4                                                      00694000
@NM00008 DS    AL4                                                      00695000
@NM00009 DS    AL4                                                      00696000
         ORG   GFPARMS+44                                               00697000
PARMLIST DS    CL20                                                     00698000
         ORG   PARMLIST                                                 00699000
JOBLISTP DS    AL4                                                      00700000
NUMJOBSP DS    AL4                                                      00701000
SWITPTR  DS    AL4                                                      00702000
MSGRTNPT DS    AL4                                                      00703000
MSGPTR   DS    AL4                                                      00704000
         ORG   MSGPTR                                                   00705000
PTHIGH   DS    BL1                                                      00706000
         ORG   PARMLIST+20                                              00707000
MSGTABLE DS    CL64                                                     00708000
         ORG   MSGTABLE                                                 00709000
LISTPTR  DS    AL4                                                      00710000
TMCTPTR  DS    AL4                                                      00711000
         ORG   TMCTPTR                                                  00712000
MTCPPL   DS    AL4                                                      00713000
         ORG   MSGTABLE+8                                               00714000
ECBPTR   DS    AL4                                                      00715000
@NM00011 DS    AL4                                                      00716000
         ORG   @NM00011                                                 00717000
MTHIGH   DS    BL1                                                      00718000
         ORG   MSGTABLE+16                                              00719000
MSGCSECT DS    AL4                                                      00720000
SW       DS    AL1                                                      00721000
         ORG   SW                                                       00722000
MTNOIDSW DS    BL1                                                      00723000
MTPUTLSW EQU   SW+0                                                     00724000
MTWTOSW  EQU   SW+0                                                     00725000
MTHEXSW  EQU   SW+0                                                     00726000
MTKEY1SW EQU   SW+0                                                     00727000
MTJOBISW EQU   SW+0                                                     00728000
MTWTPSW  EQU   SW+0                                                     00729000
MTNHEXSW EQU   SW+0                                                     00730000
         ORG   MSGTABLE+21                                              00731000
RETMSG   DS    AL3                                                      00732000
SW2      DS    AL1                                                      00733000
         ORG   SW2                                                      00734000
MT2OLDSW DS    BL1                                                      00735000
MTDOMSW  EQU   SW2+0                                                    00736000
@NM00012 EQU   SW2+0                                                    00737000
         ORG   MSGTABLE+25                                              00738000
@NM00013 DS    AL3                                                      00739000
MTOLDPTR DS    AL4                                                      00740000
@NM00014 DS    AL4                                                      00741000
@NM00015 DS    AL4                                                      00742000
MSGID    DS    CL4                                                      00743000
MTINSRTS DS    CL16                                                     00744000
         ORG   MTINSRTS                                                 00745000
L1       DS    AL1                                                      00746000
         ORG   L1                                                       00747000
HIGHL1   DS    BL1                                                      00748000
         ORG   MTINSRTS+1                                               00749000
VAR1     DS    AL3                                                      00750000
L2       DS    AL1                                                      00751000
         ORG   L2                                                       00752000
HIGHL2   DS    BL1                                                      00753000
         ORG   MTINSRTS+5                                               00754000
VAR2     DS    AL3                                                      00755000
L3       DS    AL1                                                      00756000
         ORG   L3                                                       00757000
HIGHL3   DS    BL1                                                      00758000
         ORG   MTINSRTS+9                                               00759000
VAR3     DS    AL3                                                      00760000
L4       DS    AL1                                                      00761000
         ORG   L4                                                       00762000
HIGHL4   DS    BL1                                                      00763000
         ORG   MTINSRTS+13                                              00764000
VAR4     DS    AL3                                                      00765000
         ORG   MSGTABLE+60                                              00766000
MSGRTN   DS    AL4                                                      00767000
         ORG   MSGTABLE+64                                              00768000
PPLLN    DS    CL28                                                     00769000
B000118  DS    A                                                DSKK040 00769010
         DS    0D                                               DSKK040 00769020
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00770000
@ENDDATD EQU   *                                                        00771000
IKJEFF50 CSECT                                                          00772000
         DS    0F                                                       00773000
@SIZDATD DC    AL1(0)                                                   00774000
         DC    AL3(@ENDDATD-@DATD)                                      00775000
@CV00063 DC    V(IKJEFF02)                                              00776000
@CV00064 DC    V(IKJEFF55)                                              00777000
@CV00065 DC    V(IKJEFF5A)                                              00778000
         DS    0D                                                       00779000
AUTOCTR  DC    A(1)                                                     00780000
LEN      DC    F'9'                                                     00781000
HEADER   DC    A(8)                                                     00782000
PATCH    DS    CL60                                                     00783000
         ORG   PATCH                                                    00784000
PTCHINIT DC    20CL3'ZAP'                                               00785000
         ORG   PATCH+60                                                 00786000
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00787000
@01      EQU   01                                                       00788000
@02      EQU   02                                                       00789000
@03      EQU   03                                                       00790000
@04      EQU   04                                                       00791000
@05      EQU   05                                                       00792000
@06      EQU   06                                                       00793000
@07      EQU   07                                                       00794000
@08      EQU   08                                                       00795000
@09      EQU   09                                                       00796000
@10      EQU   10                                                       00797000
@11      EQU   11                                                       00798000
@12      EQU   12                                                       00799000
@13      EQU   13                                                       00800000
@14      EQU   14                                                       00801000
@15      EQU   15                                                       00802000
K        EQU   @02                                                      00803000
SAVELIST EQU   @06                                                      00804000
PDEPTR   EQU   @03                                                      00805000
PPLPTR   EQU   @04                                                      00806000
FIBCMPTR EQU   @05                                                      00807000
R0       EQU   @00                                                      00808000
R1       EQU   @01                                                      00809000
R15      EQU   @15                                                      00810000
GPR01P   EQU   @01                                                      00811000
GPR00F   EQU   @00                                                      00812000
GPR00P   EQU   @00                                                      00813000
GPR01F   EQU   @01                                                      00814000
GPR14F   EQU   @14                                                      00815000
GPR14P   EQU   @14                                                      00816000
GPR15F   EQU   @15                                                      00817000
GPR15P   EQU   @15                                                      00818000
CVTPTR   EQU   16                                                       00819000
IKJEFF19 EQU   0                                                        00820000
CVTMAP   EQU   0                                                        00821000
CVTDAR   EQU   CVTMAP+72                                                00822000
CVTFLGS1 EQU   CVTDAR                                                   00823000
CVTDCB   EQU   CVTMAP+116                                               00824000
CVTIERLC EQU   CVTMAP+144                                               00825000
CVTOPTA  EQU   CVTMAP+182                                               00826000
CVTOPTB  EQU   CVTMAP+183                                               00827000
CVTGTF   EQU   CVTMAP+236                                               00828000
CVTGTFST EQU   CVTGTF                                                   00829000
CVTGTFS  EQU   CVTGTFST                                                 00830000
CVTSTATE EQU   CVTGTFST                                                 00831000
CVTTMODE EQU   CVTGTFST                                                 00832000
CVTFORM  EQU   CVTGTFST                                                 00833000
CVTUSR   EQU   CVTGTFST                                                 00834000
CVTAQAVT EQU   CVTMAP+240                                               00835000
CVTTCMFG EQU   CVTAQAVT                                                 00836000
CVTVOLM2 EQU   CVTMAP+244                                               00837000
CVTTATA  EQU   CVTVOLM2                                                 00838000
CVTTSKS  EQU   CVTTATA                                                  00839000
CVTVOLF2 EQU   CVTTSKS                                                  00840000
CVTTAT   EQU   CVTTATA+1                                                00841000
CVTATER  EQU   CVTMAP+248                                               00842000
CVTEXT1  EQU   CVTMAP+252                                               00843000
CVTPURG  EQU   CVTMAP+260                                               00844000
CVTQMSG  EQU   CVTMAP+268                                               00845000
CVTDMSR  EQU   CVTMAP+272                                               00846000
CVTERPV  EQU   CVTMAP+316                                               00847000
CVTINTLA EQU   CVTMAP+320                                               00848000
CVTAPF   EQU   CVTMAP+324                                               00849000
CVTEXT2  EQU   CVTMAP+328                                               00850000
CVTHJES  EQU   CVTMAP+332                                               00851000
CVTPGSIA EQU   CVTMAP+348                                               00852000
CVTA1F1  EQU   CVTMAP+356                                               00853000
CVTSYSK  EQU   CVTMAP+357                                               00854000
CVTVOLM1 EQU   CVTMAP+380                                               00855000
CVTVOLF1 EQU   CVTVOLM1                                                 00856000
CVTATMCT EQU   CVTMAP+388                                               00857000
CVTXTNT1 EQU   0                                                        00858000
CVTXTNT2 EQU   0                                                        00859000
CVTDSSV  EQU   CVTXTNT2                                                 00860000
CVTRSV90 EQU   CVTXTNT2+5                                               00861000
CVTQID   EQU   CVTXTNT2+24                                              00862000
CVTRV400 EQU   CVTXTNT2+52                                              00863000
CVTRV409 EQU   CVTXTNT2+53                                              00864000
CVTATCVT EQU   CVTXTNT2+64                                              00865000
CVTRV429 EQU   CVTXTNT2+84                                              00866000
CVTRV438 EQU   CVTXTNT2+85                                              00867000
CVTRV457 EQU   CVTXTNT2+112                                             00868000
CVTRV466 EQU   CVTXTNT2+113                                             00869000
CVTFIX   EQU   0                                                        00870000
CVTRELNO EQU   CVTFIX+252                                               00871000
FIBCPARM EQU   0                                                        00872000
FIBPSCBU EQU   FIBCPARM+4                                               00873000
FIBPSCBL EQU   FIBCPARM+11                                              00874000
FIBCPPLC EQU   FIBCPARM+12                                              00875000
FIBCPPLU EQU   FIBCPARM+16                                              00876000
FIBCPPLE EQU   FIBCPARM+24                                              00877000
FIBFLAGS EQU   FIBCPARM+36                                              00878000
FIBECTNO EQU   FIBFLAGS                                                 00879000
JOBLIST  EQU   0                                                        00880000
LEN1     EQU   JOBLIST                                                  00881000
JOBNMID  EQU   JOBLIST+1                                                00882000
RET      EQU   0                                                        00883000
PPL      EQU   0                                                        00884000
PPLUPT   EQU   PPL                                                      00885000
PPLECT   EQU   PPL+4                                                    00886000
PPLECB   EQU   PPL+8                                                    00887000
PPLPCL   EQU   PPL+12                                                   00888000
PPLANS   EQU   PPL+16                                                   00889000
PPLCBUF  EQU   PPL+20                                                   00890000
PPLUWA   EQU   PPL+24                                                   00891000
PDE      EQU   0                                                        00892000
JOBNAMEP EQU   PDE                                                      00893000
NAMELEN  EQU   PDE+4                                                    00894000
PARSESW  EQU   PDE+6                                                    00895000
JOBIDP   EQU   PDE+8                                                    00896000
JOBIDLN  EQU   PDE+12                                                   00897000
FLAG     EQU   PDE+14                                                   00898000
PRESENT  EQU   FLAG                                                     00899000
LAST     EQU   PDE+16                                                   00900000
CHAINPTR EQU   LAST+1                                                   00901000
JOBNAME  EQU   0                                                        00902000
JOBID    EQU   0                                                        00903000
IKEBC    EQU   0                                                        00904000
IKEBF15  EQU   0                                                        00905000
IKEBF31  EQU   0                                                        00906000
IKEBP15  EQU   0                                                        00907000
IKEBP31  EQU   0                                                        00908000
IKEBP8   EQU   0                                                        00909000
MSGECB   EQU   0                                                        00910000
MSGTMCT  EQU   0                                                        00911000
FIBPARML EQU   0                                                        00912000
CVTS01   EQU   CVTPGSIA                                                 00913000
CVTLPDIA EQU   CVTS01+12                                                00914000
CVTDIRST EQU   CVTLPDIA                                                 00915000
CVTSLIDA EQU   CVTS01+24                                                00916000
CVTCTLFG EQU   CVTS01+50                                                00917000
CVTPARS  EQU   CVTS01+176                                               00918000
CVTRV210 EQU   CVTS01+424                                               00919000
CVTRV219 EQU   CVTS01+425                                               00920000
CVTRV228 EQU   CVTS01+426                                               00921000
CVTRV237 EQU   CVTS01+427                                               00922000
CVTMFRTR EQU   CVTS01+452                                               00923000
CVTRV262 EQU   CVTS01+468                                               00924000
CVTRV271 EQU   CVTS01+469                                               00925000
CVTRV280 EQU   CVTS01+470                                               00926000
CVTRV289 EQU   CVTS01+471                                               00927000
CVTGSDA  EQU   CVTS01+600                                               00928000
@RC00109 EQU   @RC00083                                                 01488000
@ENDDATA EQU   *                                                        01489000
         END   IKJEFF50                                         DSKK040 01490000
