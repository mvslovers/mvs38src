MONI     TITLE 'BLSUMONI--IPCS TERMINAL ATTENTION (STAX) EXIT          *00001000
                        '                                               00002000
*/* CHANGE ACTIVITY -------------------------------------------------*/ 00003000
*/*   THIS MODULE WAS WRITTEN FOR @G57LPJM                           */ 00004000
*/*   THIS MODULE WAS CHANGED FOR @ZA31999                   @ZA31999*/ 00005000
*/*------------------------------------------------------------------*/ 00006000
BLSUMONI CSECT ,                                                01S0002 00007000
@MAINENT DS    0H                                               01S0002 00008000
         USING *,@15                                            01S0002 00009000
         B     @PROLOG                                          01S0002 00010000
         DC    AL1(16)                                          01S0002 00011000
         DC    C'BLSUMONI  78.117'                              01S0002 00012000
         DROP  @15                                                      00013000
@PROLOG  STM   @14,@12,12(@13)                                  01S0002 00014000
         BALR  @12,0                                            01S0002 00015000
@PSTART  DS    0H                                               01S0002 00016000
         USING @PSTART,@12                                      01S0002 00017000
         L     @00,@SIZDATD                                     01S0002 00018000
         GETMAIN  R,LV=(0)                                              00019000
         LR    @11,@01                                          01S0002 00020000
         USING @DATD,@11                                        01S0002 00021000
         ST    @13,@SA00001+4                                   01S0002 00022000
         LM    @00,@01,20(@13)                                  01S0002 00023000
         ST    @11,8(,@13)                                      01S0002 00024000
         LR    @13,@11                                          01S0002 00025000
*   R9=PARMZZ2;                     /* ->ZZ2 (MACRO BLSUZZ2)         */ 00026000
         L     R9,PARMZZ2(,R1)                                  01S0086 00027000
*   RESPECIFY                                                   01S0087 00028000
*    (R1) UNRESTRICTED;             /* ->PARAMETER LIST              */ 00029000
*   RA=ZZ2ZZ1P;                     /* ->ZZ1 (MACRO BLSUZZ1)         */ 00030000
         L     RA,ZZ2ZZ1P(,R9)                                  01S0088 00031000
*                                                               02S0089 00032000
*/*------------------------------------------------------------------*/ 00033000
*/* BLSUMON1--MONITOR INITIALIZATION                                 */ 00034000
*/*------------------------------------------------------------------*/ 00035000
*                                                               02S0089 00036000
*   DO;                             /* MONITOR INITIALIZATION        */ 00037000
*     FLAG='00'X;                   /* PROCESSING CONTROL FLAGS      */ 00038000
         MVI   FLAG,X'00'                                       02S0090 00039000
*     IOPLUPT=ADDR(UPT);            /* ADDR OF USER PROFILE TABLE    */ 00040000
         MVC   IOPLUPT(4),CPPLUPT(R9)                           02S0091 00041000
*     IOPLECT=ADDR(ECT);            /* ADDR OF ENVIRONMENT CNTRL TBL */ 00042000
         MVC   IOPLECT(4),CPPLECT(R9)                           02S0092 00043000
*     CSPLOA=ADDR(CSOA);            /* ->COMMAND SCAN OUTPUT AREA    */ 00044000
         LA    @08,CSOA                                         02S0093 00045000
         ST    @08,CSPLOA                                       02S0093 00046000
*     GENERATE CODE(MVC   ADATA(ADATAEND-ADATA),SDATA);         02S0094 00047000
         MVC   ADATA(ADATAEND-ADATA),SDATA                              00048000
*     CMDP=ZZZNULL;                 /* NO COMMAND BUFFER             */ 00049000
         L     CMDP,@CF00058                                    02S0095 00050000
*   END;                            /* END OF BLSUMON1               */ 00051000
*   RESPECIFY                                                   01S0097 00052000
*     CMD BASED(CMDP);              /* COMMAND BUFFER                */ 00053000
*   RESPECIFY                                                   01S0098 00054000
*    (R0,                           /* TGET/TPUT INTERFACE REGISTER  */ 00055000
*     R1,                           /* TGET/TPUT INTERFACE REGISTER  */ 00056000
*     RF) RESTRICTED;               /* TGET/TPUT INTERFACE REGISTER  */ 00057000
*   IF ZZ2AFFS=ZZZ1 THEN            /* FULL SCREEN MODE      @ZA31999*/ 00058000
*                                                               01S0099 00059000
         TM    ZZ2AFFS(R9),B'00100000'                          01S0099 00060000
         BNO   @RF00099                                         01S0099 00061000
*     /***************************************************************/ 00062000
*     /*                                                             */ 00063000
*     /* FULL SCREEN MODE                                    @ZA31999*/ 00064000
*     /*                                                             */ 00065000
*     /***************************************************************/ 00066000
*                                                               01S0100 00067000
*     DO;                           /* FULL SCREEN MODE      @ZA31999*/ 00068000
*       FLAGFFS=ZZZ1;               /* SAVE FULL SCREEN INDICATOR    */ 00069000
         OI    FLAGFFS,B'00100000'                              01S0101 00070000
*       ZZ2AFFS=ZZZ0;               /* RESET FULL SCREEN INDICATOR   */ 00071000
         NI    ZZ2AFFS(R9),B'11011111'                          01S0102 00072000
*       LM(R0,R1,TPUTEXIT);         /* REGISTERS FOR TEXIT MESSAGE   */ 00073000
         LM    R0,R1,TPUTEXIT                                   01S0103 00074000
*       GENERATE CODE(TPUT  (1),(0),R);/* TRANSMIT TEXIT MESSAGE     */ 00075000
         TPUT  (1),(0),R                                                00076000
*       IF RF^=0 THEN               /* MESSAGE NOT TRANSMITTED       */ 00077000
*                                                               01S0105 00078000
         LTR   RF,RF                                            01S0105 00079000
         BZ    @RF00105                                         01S0105 00080000
*         /***********************************************************/ 00081000
*         /*                                                         */ 00082000
*         /* MESSAGE NOT TRANSMITTED                         @ZA31999*/ 00083000
*         /*                                                         */ 00084000
*         /***********************************************************/ 00085000
*                                                               01S0106 00086000
*         DO;                       /* MESSAGE NOT TRANSMITTED       */ 00087000
*           IF RF^=8 THEN           /* ATTENTION IS NOT AN ERROR     */ 00088000
         CH    RF,@CH00046                                      01S0107 00089000
         BE    @RF00107                                         01S0107 00090000
*             FLAGERR=ZZZ1;         /* MONITOR ERROR CONDITION       */ 00091000
         OI    FLAGERR,B'01000000'                              01S0108 00092000
*           GO TO EXIT;             /* COMMON EXIT PATH      @ZA31999*/ 00093000
         B     EXIT                                             01S0109 00094000
*         END;                      /* MESSAGE NOT TRANSMITTED       */ 00095000
*       IF                          /* STLINENO REQUIRED     @ZA31999*/ 00096000
*           ZZ1FACCM=ZZZ0×          /* ACCESS METHOD NOT DETERMINED  */ 00097000
*           ZZ1FTCAM=ZZZ0 THEN      /* VTAM/TIOC ACCESS METHOD       */ 00098000
*                                                               01S0111 00099000
@RF00105 TM    ZZ1FACCM(RA),B'11000000'                         01S0111 00100000
         BO    @RF00111                                         01S0111 00101000
*         /***********************************************************/ 00102000
*         /*                                                         */ 00103000
*         /* STLINENO REQUIRED                               @ZA31999*/ 00104000
*         /*                                                         */ 00105000
*         /***********************************************************/ 00106000
*                                                               01S0112 00107000
*         DO;                       /* STLINENO REQUIRED     @ZA31999*/ 00108000
*           LM(R0,R1,STLINENO);     /* REGISTERS FOR STLINENO        */ 00109000
         LM    R0,R1,STLINENO                                   01S0113 00110000
*           SVC(94);                /* STLINENO LINE=2,MODE=OFF      */ 00111000
         SVC   94                                               01S0114 00112000
*           IF RF=0 THEN            /* VTAM/TIOC ACCESS METHOD       */ 00113000
*                                                               01S0115 00114000
         LTR   RF,RF                                            01S0115 00115000
         BNZ   @RF00115                                         01S0115 00116000
*             /*******************************************************/ 00117000
*             /*                                                     */ 00118000
*             /* VTAM/TIOC ACCESS METHOD                     @ZA31999*/ 00119000
*             /*                                                     */ 00120000
*             /*******************************************************/ 00121000
*                                                               01S0116 00122000
*             DO;                   /* VTAM/TIOC ACCESS METHOD       */ 00123000
*               ZZ1FACCM=ZZZ1;      /* ACCESS METHOD DETERMINED      */ 00124000
*               ZZ1FTCAM=ZZZ0;      /* VTAM/TIOC ACCESS METHOD       */ 00125000
         OI    ZZ1FACCM(RA),B'10000000'                         01S0118 00126000
         NI    ZZ1FTCAM(RA),B'10111111'                         01S0118 00127000
*             END;                  /* VTAM/TIOC ACCESS METHOD       */ 00128000
*           ELSE                    /* STLINENO NOT SUCCESSFUL       */ 00129000
*             IF RF=8 THEN          /* TCAM/TIOC ACCESS METHOD       */ 00130000
*                                                               01S0120 00131000
         B     @RC00115                                         01S0120 00132000
@RF00115 CH    RF,@CH00046                                      01S0120 00133000
         BNE   @RF00120                                         01S0120 00134000
*               /*****************************************************/ 00135000
*               /*                                                   */ 00136000
*               /* TCAM/TIOC ACCESS METHOD                   @ZA31999*/ 00137000
*               /*                                                   */ 00138000
*               /*****************************************************/ 00139000
*                                                               01S0121 00140000
*               DO;                 /* TCAM/TIOC ACCESS METHOD       */ 00141000
*                 ZZ1FACCM=ZZZ1;    /* ACCESS METHOD DETERMINED      */ 00142000
*                 ZZ1FTCAM=ZZZ1;    /* TCAM/TIOC ACCESS METHOD       */ 00143000
         OI    ZZ1FACCM(RA),B'11000000'                         01S0123 00144000
*               END;                /* TCAM/TIOC ACCESS METHOD       */ 00145000
*             ELSE                  /* STLINENO ERROR        @ZA31999*/ 00146000
*                                                               01S0125 00147000
*               /*****************************************************/ 00148000
*               /*                                                   */ 00149000
*               /* STLINENO ERROR                            @ZA31999*/ 00150000
*               /*                                                   */ 00151000
*               /*****************************************************/ 00152000
*                                                               01S0125 00153000
*               DO;                 /* STLINENO ERROR        @ZA31999*/ 00154000
         B     @RC00120                                         01S0125 00155000
@RF00120 DS    0H                                               01S0126 00156000
*                 FLAGERR=ZZZ1;     /* MONITOR ERROR CONDITION       */ 00157000
         OI    FLAGERR,B'01000000'                              01S0126 00158000
*                 GO TO EXIT;       /* COMMON EXIT PATH      @ZA31999*/ 00159000
         B     EXIT                                             01S0127 00160000
*               END;                /* STLINENO ERROR        @ZA31999*/ 00161000
*         END;                      /* STLINENO REQUIRED     @ZA31999*/ 00162000
@RC00120 DS    0H                                               01S0129 00163000
@RC00115 DS    0H                                               01S0130 00164000
*     END;                          /* FULL SCREEN MODE      @ZA31999*/ 00165000
@RF00111 DS    0H                                               01S0131 00166000
*   LM(R0,R1,TPUTMODE);             /* REGISTERS FOR MODE MESSAGE    */ 00167000
@RF00099 LM    R0,R1,TPUTMODE                                   01S0131 00168000
*   GENERATE CODE(TPUT  (1),(0),R); /* TRANSMIT MODE MESSAGE @ZA31999*/ 00169000
         TPUT  (1),(0),R                                                00170000
*   IF RF^=0 THEN                   /* MESSAGE NOT TRANSMITTED       */ 00171000
         LTR   RF,RF                                            01S0133 00172000
         BNZ   @RT00133                                         01S0133 00173000
*     GO TO EXIT;                   /* COMMON EXIT PATH      @ZA31999*/ 00174000
*   LM(R0,R1,TGETRESP);             /* REGISTERS FOR RESPONSE        */ 00175000
         LM    R0,R1,TGETRESP                                   01S0135 00176000
*   R1=R1×ADDR(TGETBUF);            /* ->DUMMY INPUT BUFFER  @ZA31999*/ 00177000
         LA    @14,TGETBUF                                      01S0136 00178000
         OR    R1,@14                                           01S0136 00179000
*   GENERATE CODE(TGET  (1),(0),R); /* VERIFY NON-NULL RESPONSE      */ 00180000
         TGET  (1),(0),R                                                00181000
*   IF RF^=12 THEN                  /* NULL OR ERROR RESPONSE        */ 00182000
*                                                               01S0138 00183000
         CH    RF,@CH00033                                      01S0138 00184000
         BE    @RF00138                                         01S0138 00185000
*     /***************************************************************/ 00186000
*     /*                                                             */ 00187000
*     /* NULL OR ERROR RESPONSE                              @ZA31999*/ 00188000
*     /*                                                             */ 00189000
*     /***************************************************************/ 00190000
*                                                               01S0139 00191000
*     DO;                           /* NULL OR ERROR RESPONSE        */ 00192000
*       IF RF=0 THEN                /* NULL LINE REQUIRES TCLEARQ    */ 00193000
         LTR   RF,RF                                            01S0140 00194000
         BNZ   @RF00140                                         01S0140 00195000
*         GENERATE CODE(TCLEARQ INPUT);/* ELIMINATE RESIDUAL INPUT   */ 00196000
         TCLEARQ INPUT                                                  00197000
*       ELSE                        /* MONITOR ERROR CONDITION       */ 00198000
*         IF RF^=8 THEN             /* ATTENTION IS NOT AN ERROR     */ 00199000
         B     @RC00140                                         01S0142 00200000
@RF00140 CH    RF,@CH00046                                      01S0142 00201000
         BE    @RF00142                                         01S0142 00202000
*           FLAGERR=ZZZ1;           /* MONITOR ERROR CONDITION       */ 00203000
         OI    FLAGERR,B'01000000'                              01S0143 00204000
*       GO TO EXIT;                 /* COMMON EXIT PATH      @ZA31999*/ 00205000
         B     EXIT                                             01S0144 00206000
*     END;                          /* NULL OR ERROR RESPONSE        */ 00207000
*   RESPECIFY                       /*                       @ZA31999*/ 00208000
*    (R0,                           /* TGET/TPUT INTERFACE REGISTER  */ 00209000
*     R1,                           /* TGET/TPUT INTERFACE REGISTER  */ 00210000
*     RF) UNRESTRICTED;             /* TGET/TPUT INTERFACE REGISTER  */ 00211000
@RF00138 DS    0H                                               01S0147 00212000
*/*------------------------------------------------------------------*/ 00213000
*/* ITERATIVELY GET LOGICAL LINES FROM THE TERMINAL UNTIL A          */ 00214000
*/* WELL-FORMED REQUEST IS DETECTED                                  */ 00215000
*/*------------------------------------------------------------------*/ 00216000
*                                                               01S0147 00217000
*   DO WHILE(FLAGEND=ZZZ0);         /* ITERATIVELY GET COMMANDS      */ 00218000
         B     @DE00147                                         01S0147 00219000
@DL00147 DS    0H                                               01S0148 00220000
*     IOPLECB=ADDR(0);              /* INITIALIZE IOPL               */ 00221000
         LA    @08,@CF00043                                     01S0148 00222000
         ST    @08,IOPLECB                                      01S0148 00223000
*     IOPLIOPB=ADDR(PGPB);          /* ->PUTGET PARAMETER BLOCK      */ 00224000
         LA    @08,PGPB                                         01S0149 00225000
         ST    @08,IOPLIOPB                                     01S0149 00226000
*                                                               02S0150 00227000
*/********************************************************************/ 00228000
*/*                                                                  */ 00229000
*/* BLSUMONO--PUT MODE MESSAGE, GET COMMAND                          */ 00230000
*/*                                                                  */ 00231000
*/********************************************************************/ 00232000
*                                                               02S0150 00233000
*   DO;                             /* BLSUMONO                      */ 00234000
*     RESPECIFY                                                 02S0151 00235000
*      (R1) RESTRICTED;             /* ->IOPL                        */ 00236000
*     R1=ADDR(IOPL);                /* ->IOPL                        */ 00237000
         LA    R1,IOPL                                          02S0152 00238000
*     RESPECIFY                                                 02S0153 00239000
*      (RF) RESTRICTED;             /* RETURN CODE                   */ 00240000
*     CALL IKJPTGT;                 /* PUTGET TSO SERVICE ROUTINE    */ 00241000
         L     @15,ZZ2PTGTP(,R9)                                02S0154 00242000
         BALR  @14,@15                                          02S0154 00243000
*     RESPECIFY                                                 02S0155 00244000
*      (R1) UNRESTRICTED;           /* ->IOPL                        */ 00245000
*     RETCPTGT=RF;                  /* IKJPTGT RETURN CODE           */ 00246000
         LR    RETCPTGT,RF                                      02S0156 00247000
*     RESPECIFY                                                 02S0157 00248000
*      (RF) UNRESTRICTED;           /* RETURN CODE                   */ 00249000
*     CMDP=PGPBIBUF;                /* ->COMMAND BUFFER              */ 00250000
         L     CMDP,PGPBIBUF                                    02S0158 00251000
*   END;                            /* END OF BLSUMONO               */ 00252000
*                                                               02S0160 00253000
*/*------------------------------------------------------------------*/ 00254000
*/* BLSUMONS--SCAN COMMAND BUFFER                                    */ 00255000
*/*------------------------------------------------------------------*/ 00256000
*                                                               02S0160 00257000
*   DO;                             /* BLSUMONS                      */ 00258000
*     FLAGSCAN='0'B;                /* ANTICIPATE INVALID COMMAND    */ 00259000
         NI    FLAGSCAN,B'11101111'                             02S0161 00260000
*     IF RETCPTGT>12 THEN           /* SERIOUS IKJPTGT ERROR         */ 00261000
*                                                               02S0162 00262000
         CH    RETCPTGT,@CH00033                                02S0162 00263000
         BNH   @RF00162                                         02S0162 00264000
*       /*************************************************************/ 00265000
*       /*                                                           */ 00266000
*       /* SERIOUS IKJPTGT ERROR                                     */ 00267000
*       /*                                                           */ 00268000
*       /*************************************************************/ 00269000
*                                                               02S0163 00270000
*       DO;                         /* SERIOUS IKJPTGT ERROR         */ 00271000
*         FLAGEND='1'B;             /* TERMINATE                     */ 00272000
*         FLAGERR='1'B;             /* ERROR                         */ 00273000
         OI    FLAGEND,B'11000000'                              02S0165 00274000
*       END;                        /* SERIOUS IKJPTGT ERROR         */ 00275000
*     IF RETCPTGT=12 THEN           /* 2ND LEVEL MSGS WILL NOT BE       00276000
*                                      AVAILABLE TO THE USER         */ 00277000
@RF00162 CH    RETCPTGT,@CH00033                                02S0167 00278000
         BNE   @RF00167                                         02S0167 00279000
*       ECTMSGF=ECTMSGF×'80'X;      /* SCHEDULE 2ND LEVEL MSG PURGE  */ 00280000
         L     @08,CPPLECT(,R9)                                 02S0168 00281000
         OI    ECTMSGF(@08),X'80'                               02S0168 00282000
*     IF RETCPTGT<8 THEN            /* COMMAND LINE OBTAINED         */ 00283000
*                                                               02S0169 00284000
@RF00167 CH    RETCPTGT,@CH00046                                02S0169 00285000
         BNL   @RF00169                                         02S0169 00286000
*       /*************************************************************/ 00287000
*       /*                                                           */ 00288000
*       /* PROCESS COMMAND THROUGH TSO COMMAND SCAN SERVICE ROUTINE  */ 00289000
*       /*                                                           */ 00290000
*       /*************************************************************/ 00291000
*                                                               02S0170 00292000
*       DO;                         /* COMMAND LINE OBTAINED         */ 00293000
*         CSPLCBUF=CMDP;            /* ->COMMAND BUFFER              */ 00294000
         ST    CMDP,CSPLCBUF                                    02S0171 00295000
*         CALL BLSUMON2(ZZ2,CSPL);  /* SCAN COMMAND BUFFER           */ 00296000
         ST    R9,@AL00001                                      02S0172 00297000
         LA    @08,CSPL                                         02S0172 00298000
         ST    @08,@AL00001+4                                   02S0172 00299000
         L     @08,ZZ2BVTP(,R9)                                 02S0172 00300000
         L     @15,BVTMON2P(,@08)                               02S0172 00301000
         LA    @01,@AL00001                                     02S0172 00302000
         BALR  @14,@15                                          02S0172 00303000
*         RESPECIFY                                             02S0173 00304000
*          (RF) RESTRICTED;         /* BLSUMON2 RETURN CODE          */ 00305000
*         IF RF=ZZZFLAGI THEN       /* VALID COMMAND SCAN RESULT     */ 00306000
         LTR   RF,RF                                            02S0174 00307000
         BNZ   @RF00174                                         02S0174 00308000
*           FLAGSCAN='1'B;          /* VALID COMMAND SCAN RESULT     */ 00309000
         OI    FLAGSCAN,B'00010000'                             02S0175 00310000
*         ELSE                      /* UNSUCCESSFUL COMMAND SCAN     */ 00311000
*           IF RF=ZZZFLAGT THEN     /* COMMAND SCAN ERROR            */ 00312000
*                                                               02S0176 00313000
         B     @RC00174                                         02S0176 00314000
@RF00174 CH    RF,@CH00049                                      02S0176 00315000
         BNE   @RF00176                                         02S0176 00316000
*             /*******************************************************/ 00317000
*             /*                                                     */ 00318000
*             /* COMMAND SCAN ERROR                                  */ 00319000
*             /*                                                     */ 00320000
*             /*******************************************************/ 00321000
*                                                               02S0177 00322000
*             DO;                   /* COMMAND SCAN ERROR            */ 00323000
*               FLAGEND='1'B;       /* TERMINATE                     */ 00324000
*               FLAGERR='1'B;       /* ERROR                         */ 00325000
         OI    FLAGEND,B'11000000'                              02S0179 00326000
*             END;                  /* COMMAND SCAN ERROR            */ 00327000
*         RESPECIFY                                             02S0181 00328000
*          (RF) UNRESTRICTED;       /* BLSUMON2 RETURN CODE          */ 00329000
@RF00176 DS    0H                                               02S0181 00330000
@RC00174 DS    0H                                               02S0182 00331000
*       END;                        /* COMMAND LINE OBTAINED         */ 00332000
*     ELSE                          /* ATTENTION INTERRUPTED IKJPTGT */ 00333000
*       CMDP=ZZZNULL;               /* NO SUBCOMMAND BUFFER          */ 00334000
         B     @RC00169                                         02S0183 00335000
@RF00169 L     CMDP,@CF00058                                    02S0183 00336000
*   END;                            /* END OF BLSUMONS               */ 00337000
@RC00169 DS    0H                                               02S0185 00338000
*     IF FLAGSCAN=ZZZ1 THEN         /* COMMAND LINE OBTAINED         */ 00339000
*                                                               01S0185 00340000
         TM    FLAGSCAN,B'00010000'                             01S0185 00341000
         BNO   @RF00185                                         01S0185 00342000
*       /*************************************************************/ 00343000
*       /*                                                           */ 00344000
*       /* COMMAND LINE OBTAINED                                     */ 00345000
*       /*                                                           */ 00346000
*       /*************************************************************/ 00347000
*                                                               01S0186 00348000
*       DO;                         /* COMMAND LINE OBTAINED         */ 00349000
*         IF CSOANOC=ZZZ0 THEN      /* IS IT A NON-NULL LINE?        */ 00350000
*                                                               01S0187 00351000
         TM    CSOANOC,B'00010000'                              01S0187 00352000
         BNZ   @RF00187                                         01S0187 00353000
*           /*********************************************************/ 00354000
*           /*                                                       */ 00355000
*           /* NON-NULL LINE                                         */ 00356000
*           /*                                                       */ 00357000
*           /*********************************************************/ 00358000
*                                                               01S0188 00359000
*           DO;                     /* NON-NULL LINE                 */ 00360000
*             IF                    /* TIME COMMAND                  */ 00361000
*                 CSOAEXEC=ZZZ0&    /* NOT PREFIXED BY PERCENT SIGN  */ 00362000
*                 CSOALNM=LENGTH('ABEND')&CSOACN(1:LENGTH('ABEND'))=    00363000
*                 'ABEND' THEN      /* ABEND COMMAND                 */ 00364000
*                                                               01S0189 00365000
         TM    CSOAEXEC,B'00000100'                             01S0189 00366000
         BNZ   @RF00189                                         01S0189 00367000
         CLC   CSOALNM(2),@CH00090                              01S0189 00368000
         BNE   @RF00189                                         01S0189 00369000
         L     @08,CSOACNM                                      01S0189 00370000
         CLC   CSOACN(5,@08),@CC00803                           01S0189 00371000
         BNE   @RF00189                                         01S0189 00372000
*               /*****************************************************/ 00373000
*               /*                                                   */ 00374000
*               /* ABEND COMMAND                                     */ 00375000
*               /*                                                   */ 00376000
*               /*****************************************************/ 00377000
*                                                               01S0190 00378000
*               DO;                 /* ABEND COMMAND                 */ 00379000
*                 ZZ1FM='0'B;       /* MONITOR NO LONGER READY       */ 00380000
         NI    ZZ1FM(RA),B'11011111'                            01S0191 00381000
*                  DO; /*ABEND(114) DUMP */                     01S0192 00382000
*                  RESPECIFY (GPR01F) RESTRICTED;               01S0193 00383000
*                  GPR01F = 114; /*COMP CODE IN REG 1*/         01S0194 00384000
         LA    GPR01F,114                                       01S0194 00385000
*                  GPR01F = GPR01F × '80000000'X; /*DUMP/STEP/DUMPOPTS  00386000
*LAG*/             SVC (13);/*ISSUE ABEND SVC*/                 01S0195 00387000
         O     GPR01F,@CF00058                                  01S0195 00388000
         SVC   13                                               01S0196 00389000
*                  RESPECIFY (GPR01F) UNRESTRICTED;             01S0197 00390000
*                  END; /*ABEND(114) DUMP */                    01S0198 00391000
*               END;                /* ABEND COMMAND                 */ 00392000
*             IF                    /* TIME COMMAND                  */ 00393000
*                 CSOAEXEC=ZZZ0&    /* NOT PREFIXED BY PERCENT SIGN  */ 00394000
*                 CSOALNM=LENGTH('TIME')&CSOACN(1:LENGTH('TIME'))='TIME 00395000
*               THEN                /* TIME COMMAND                  */ 00396000
@RF00189 TM    CSOAEXEC,B'00000100'                             01S0200 00397000
         BNZ   @RF00200                                         01S0200 00398000
         CLC   CSOALNM(2),@CH00036                              01S0200 00399000
         BNE   @RF00200                                         01S0200 00400000
         L     @08,CSOACNM                                      01S0200 00401000
         CLC   CSOACN(4,@08),@CC00806                           01S0200 00402000
         BNE   @RF00200                                         01S0200 00403000
*               CALL IKJEFT25(CMD,UPT,PSCB,ECT);/* DISPLAY TIME DATA */ 00404000
         ST    CMDP,@AL00001                                    01S0201 00405000
         L     @08,CPPLUPT(,R9)                                 01S0201 00406000
         ST    @08,@AL00001+4                                   01S0201 00407000
         L     @08,CPPLPSCB(,R9)                                01S0201 00408000
         ST    @08,@AL00001+8                                   01S0201 00409000
         L     @08,CPPLECT(,R9)                                 01S0201 00410000
         ST    @08,@AL00001+12                                  01S0201 00411000
         L     @15,ZZ2FT25P(,R9)                                01S0201 00412000
         LA    @01,@AL00001                                     01S0201 00413000
         BALR  @14,@15                                          01S0201 00414000
*             ELSE                  /* NOT A TIME COMMAND            */ 00415000
*                                                               01S0202 00416000
*               /*****************************************************/ 00417000
*               /*                                                   */ 00418000
*               /* NOT A TIME COMMAND                                */ 00419000
*               /*                                                   */ 00420000
*               /*****************************************************/ 00421000
*                                                               01S0202 00422000
*               DO;                 /* NOT A TIME COMMAND            */ 00423000
         B     @RC00200                                         01S0202 00424000
@RF00200 DS    0H                                               01S0203 00425000
*                 CMDO=0;           /* MONITOR WILL RESCAN COMMAND   */ 00426000
         SLR   @08,@08                                          01S0203 00427000
         STH   @08,CMDO(,CMDP)                                  01S0203 00428000
*                 CMDP=ZZZNULL;     /* NO COMMAND BUFFER             */ 00429000
         L     @08,@CF00058                                     01S0204 00430000
         LR    CMDP,@08                                         01S0204 00431000
*                 RESPECIFY                                     01S0205 00432000
*                  (R0,             /* UPDATE VALUE REGISTER PAIR    */ 00433000
*                   R1,                                         01S0205 00434000
*                   R2,             /* COMPARATOR REGISTER PAIR      */ 00435000
*                   R3) RESTRICTED;                             01S0205 00436000
*                 R0=ZZZNULL;       /* PRIME UPDATE REGISTER PAIR    */ 00437000
         LR    R0,@08                                           01S0206 00438000
*                 R1=0;                                         01S0207 00439000
         SLR   R1,R1                                            01S0207 00440000
*                 R2=R0;            /* PRIME COMPARATOR REGISTER PAIR*/ 00441000
         LR    R2,R0                                            01S0208 00442000
*                 R3=0;                                         01S0209 00443000
*                                                               01S0209 00444000
         SLR   R3,R3                                            01S0209 00445000
*                 /***************************************************/ 00446000
*                 /*                                                 */ 00447000
*                 /* DEQUEUE ATTENTION SUBCOMMANDS UNTIL THE POINTER */ 00448000
*                 /* TO SUCH SUBCOMMANDS INDICATES WE ARE PROCESSING */ 00449000
*                 /* THE MOST RECENT                                 */ 00450000
*                 /*                                                 */ 00451000
*                 /***************************************************/ 00452000
*                                                               01S0210 00453000
*                 DO UNTIL(R2=R0);  /* REPLACE ZZ1ATTN               */ 00454000
@DL00210 DS    0H                                               01S0211 00455000
*                   IF R2^=CMDP THEN/* ATTENTION SUBCOMMAND SELECTED */ 00456000
*                                                               01S0211 00457000
         CR    R2,CMDP                                          01S0211 00458000
         BE    @RF00211                                         01S0211 00459000
*                     /***********************************************/ 00460000
*                     /*                                             */ 00461000
*                     /* ATTENTION SUBCOMMAND SELECTED               */ 00462000
*                     /*                                             */ 00463000
*                     /***********************************************/ 00464000
*                                                               01S0212 00465000
*                     DO;           /* ATTENTION SUBCOMMAND SELECTED */ 00466000
*                       CALL BLSUMONF;/* FREE COMMAND BUFFER         */ 00467000
         BAL   @14,BLSUMONF                                     01S0213 00468000
*                       CMDP=R2;    /* ->COMMAND BUFFER              */ 00469000
         LR    CMDP,R2                                          01S0214 00470000
*                     END;          /* ATTENTION SUBCOMMAND SELECTED */ 00471000
*                   CDS(R2,R0,ZZ1ATTN);/* UPDATE ZZ1ATTN OR R2××R3   */ 00472000
@RF00211 CDS   R2,R0,ZZ1ATTN(RA)                                01S0216 00473000
*                   R1=R3;          /* DO NOT ZERO ZZ1EVE            */ 00474000
         LR    R1,R3                                            01S0217 00475000
*                 END;              /* REPLACE ZZ1ATTN               */ 00476000
@DE00210 CR    R2,R0                                            01S0218 00477000
         BNE   @DL00210                                         01S0218 00478000
*                 RESPECIFY                                     01S0219 00479000
*                  (R0,             /* UPDATE VALUE REGISTER PAIR    */ 00480000
*                   R1,                                         01S0219 00481000
*                   R2,             /* COMPARATOR REGISTER PAIR      */ 00482000
*                   R3) UNRESTRICTED;                           01S0219 00483000
*                 ZZ1ACMP=PGPBIBUF; /* ->NEW ATTN COMMAND            */ 00484000
         MVC   ZZ1ACMP(4,RA),PGPBIBUF                           01S0220 00485000
*                 FLAGEND=ZZZ1;     /* TERMINATE ATTENTION EXIT      */ 00486000
*                 FLAGFFS=ZZZ0;     /* DO NOT ENTER FULL SCREEN MODE */ 00487000
         OI    FLAGEND,B'10000000'                              01S0222 00488000
         NI    FLAGFFS,B'11011111'                              01S0222 00489000
*                  DO; /*POST (ZZ1EVE,ZZZFLAGW)*/               01S0223 00490000
*                    RESPECIFY (GPR00F,GPR01P) RESTRICTED;      01S0224 00491000
*                    GPR00F = ZZZFLAGW; /* POST CODE IN R0*/    01S0225 00492000
         LA    GPR00F,4                                         01S0225 00493000
*                    GPR01P = ADDR(ZZ1EVE); /*ECB ADDRESS*/     01S0226 00494000
         LA    GPR01P,ZZ1EVE(,RA)                               01S0226 00495000
*                    SVC (2); /*ISSUE POST SVC*/                01S0227 00496000
         SVC   2                                                01S0227 00497000
*                    RESPECIFY (GPR00F,GPR01P) UNRESTRICTED;    01S0228 00498000
*                  END; /*POST (ZZ1EVE,ZZZFLAGW)*/              01S0229 00499000
*               END;                /* NOT A TIME COMMAND            */ 00500000
*           END;                    /* NON-NULL LINE                 */ 00501000
*         ELSE                      /* NULL LINE                     */ 00502000
*           FLAGEND=ZZZ1;           /* TERMINATE ON NULL LINE        */ 00503000
         B     @RC00187                                         01S0232 00504000
@RF00187 OI    FLAGEND,B'10000000'                              01S0232 00505000
*       END;                        /* COMMAND LINE OBTAINED         */ 00506000
@RC00187 DS    0H                                               01S0234 00507000
*     CALL BLSUMONF;                /* FREE COMMAND BUFFER           */ 00508000
@RF00185 BAL   @14,BLSUMONF                                     01S0234 00509000
*     PGPBOPUT=ADDR(OIPCS);         /* PREPARE MODE MESSAGE DISPLAY  */ 00510000
         LA    @08,OIPCS                                        01S0235 00511000
         ST    @08,PGPBOPUT                                     01S0235 00512000
*   END;                            /* ITERATIVELY GET COMMANDS      */ 00513000
@DE00147 TM    FLAGEND,B'10000000'                              01S0236 00514000
         BZ    @DL00147                                         01S0236 00515000
*EXIT:                              /* COMMON EXIT PATH              */ 00516000
*   IF FLAGFFS=ZZZ1 THEN            /* REENTER FULL SCREEN MODE      */ 00517000
*                                                               01S0237 00518000
EXIT     TM    FLAGFFS,B'00100000'                              01S0237 00519000
         BNO   @RF00237                                         01S0237 00520000
*     /***************************************************************/ 00521000
*     /*                                                             */ 00522000
*     /* REENTER FULL SCREEN MODE                            @ZA31999*/ 00523000
*     /*                                                             */ 00524000
*     /***************************************************************/ 00525000
*                                                               01S0238 00526000
*     DO;                           /* REENTER FULL SCREEN MODE      */ 00527000
*       IF                          /* STFSMODE REQUIRED     @ZA31999*/ 00528000
*           ZZ1FACCM=ZZZ0×          /* ACCESS METHOD DETERMINED      */ 00529000
*           ZZ1FTCAM=ZZZ0 THEN      /* TCAM/TIOC ACCESS METHOD       */ 00530000
*                                                               01S0239 00531000
         TM    ZZ1FACCM(RA),B'11000000'                         01S0239 00532000
         BO    @RF00239                                         01S0239 00533000
*         /***********************************************************/ 00534000
*         /*                                                         */ 00535000
*         /* STFSMODE REQUIRED                               @ZA31999*/ 00536000
*         /*                                                         */ 00537000
*         /***********************************************************/ 00538000
*                                                               01S0240 00539000
*         DO;                       /* STFSMODE REQUIRED     @ZA31999*/ 00540000
*           LM(R0,R1,STFSMODE);     /* REGISTERS FOR STFSMODE        */ 00541000
         LM    R0,R1,STFSMODE                                   01S0241 00542000
*           SVC(94);                /* STFSMODE ON,INITIAL=YES       */ 00543000
         SVC   94                                               01S0242 00544000
*         END;                      /* STFSMODE REQUIRED     @ZA31999*/ 00545000
*       LM(R0,R1,TPUT3270);         /* REGISTERS FOR T3270 MESSAGE   */ 00546000
@RF00239 LM    R0,R1,TPUT3270                                   01S0244 00547000
*       GENERATE CODE(TPUT  (1),(0),R);/* TRANSMIT T3270 MESSAGE     */ 00548000
         TPUT  (1),(0),R                                                00549000
*       ZZ2AFFS=ZZZ1;               /* SET FULL SCREEN INDICATOR     */ 00550000
         OI    ZZ2AFFS(R9),B'00100000'                          01S0246 00551000
*     END;                          /* REENTER FULL SCREEN MODE      */ 00552000
*   IF FLAGERR=ZZZ0 THEN            /* NO ERROR(S) DETECTED          */ 00553000
@RF00237 TM    FLAGERR,B'01000000'                              01S0248 00554000
         BNZ   @RF00248                                         01S0248 00555000
*     RETC=ZZZFLAGI;                /* RETURN CODE                   */ 00556000
         SLR   RETC,RETC                                        01S0249 00557000
*   ELSE                            /* ERROR(S) DETECTED             */ 00558000
*     RETC=ZZZFLAGW;                /* RETURN CODE                   */ 00559000
         B     @RC00248                                         01S0250 00560000
@RF00248 LA    RETC,4                                           01S0250 00561000
*   RETURN CODE(RETC);                                          01S0251 00562000
@RC00248 L     @13,4(,@13)                                      01S0251 00563000
         L     @00,@SIZDATD                                     01S0251 00564000
         LR    @01,@11                                          01S0251 00565000
         FREEMAIN R,LV=(0),A=(1)                                        00566000
         LR    @15,@02                                          01S0251 00567000
         L     @14,12(,@13)                                     01S0251 00568000
         LM    @00,@12,20(@13)                                  01S0251 00569000
         BR    @14                                              01S0251 00570000
*                                                               02S0252 00571000
*/*------------------------------------------------------------------*/ 00572000
*/* BLSUMONF--FREE SUBCOMMAND BUFFER                                 */ 00573000
*/*------------------------------------------------------------------*/ 00574000
*                                                               02S0252 00575000
*BLSUMONF:                          /* FREE SUBCOMMAND BUFFER        */ 00576000
*   PROCEDURE OPTIONS(NOSAVEAREA);                              02S0252 00577000
BLSUMONF STM   @14,@12,12(@13)                                  02S0252 00578000
*   IF CMDP^=ZZZNULL THEN           /* SUBCOMMAND BUFFER EXISTS      */ 00579000
         CL    CMDP,@CF00058                                    02S0253 00580000
         BE    @RF00253                                         02S0253 00581000
*      DO; /*FREEMAIN(RU) LV(CMDP->CMDL)A(CMDP->CMD) SP(ZZZSPEXC)*/     00582000
*      RESPECIFY (GPR01F,GPR15F,GPR00F) RESTRICTED;             02S0255 00583000
*      GPR01F = 0; /* REG 1 MUST BE ZERO*/                      02S0256 00584000
         SLR   GPR01F,GPR01F                                    02S0256 00585000
*      GPR15F=3; /*SET TYPE*/                                   02S0257 00586000
         LA    GPR15F,3                                         02S0257 00587000
*      GPR00F = CMDP->CMDL; /* LENGTH REQUESTED*/               02S0258 00588000
         SLR   GPR00F,GPR00F                                    02S0258 00589000
         ICM   GPR00F,3,CMDL(CMDP)                              02S0258 00590000
*      GPR01F=ADDR(CMDP->CMD); /*SET REGISTER ONE*/             02S0259 00591000
         LR    GPR01F,CMDP                                      02S0259 00592000
*      GPR15F=GPR15F+((ZZZSPEXC)*256); /* SUBPOOL VALUE*/       02S0260 00593000
         AH    GPR15F,@CH00173                                  02S0260 00594000
*      SVC(120); /*RC/RU-FORM OF GETMAIN*/                      02S0261 00595000
         SVC   120                                              02S0261 00596000
*      RESPECIFY (GPR01F,GPR15F,GPR00F) UNRESTRICTED;           02S0262 00597000
*      END; /*FREEMAIN(RU) LV(CMDP->CMDL)A(CMDP->CMD) SP(ZZZSPEXC)*/    00598000
*   RETURN;                                                     02S0264 00599000
@EL00002 DS    0H                                               02S0264 00600000
@EF00002 DS    0H                                               02S0264 00601000
@ER00002 LM    @14,@12,12(@13)                                  02S0264 00602000
         BR    @14                                              02S0264 00603000
*   END BLSUMONF;                   /* END OF BLSUMONF               */ 00604000
         B     @EL00002                                         02S0265 00605000
*                                                               01S0266 00606000
*/*BLSUPEND--MVS IPCS MODULE*/                                  01S0266 00607000
*                                                               01S0266 00608000
*                                                               01S0266 00609000
*                                                               01S0266 00610000
*    DECLARE /*GENERAL PURPOSE REGISTERS */                     01S0266 00611000
*      GPR00F FIXED(31) REG(0),                                 01S0266 00612000
*      GPR01F FIXED(31) REG(1),                                 01S0266 00613000
*      GPR15F FIXED(31) REG(15),                                01S0266 00614000
*      GPR01P PTR(31) REG(1);                                   01S0266 00615000
*                                                               01S0266 00616000
*    DECLARE /* COMMON VARIABLES */                             01S0267 00617000
*      I256C CHAR(256) BASED,                                   01S0267 00618000
*      I031F FIXED(31) BASED,                                   01S0267 00619000
*      I031P PTR(31)   BASED,                                   01S0267 00620000
*      I015F FIXED(15) BASED,                                   01S0267 00621000
*      I015P PTR(15)   BASED,                                   01S0267 00622000
*      I008P PTR(8)    BASED,                                   01S0267 00623000
*      I001C CHAR(1)   BASED;                                   01S0267 00624000
*    GENERATE NODEFS NOREFS DATA;                               01S0268 00625000
*   END BLSUMONI /*BLRPEND(BLSUMONI) */                         01S0269 00626000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.      * 00627000
*/*%INCLUDE SYSLIB  (BLSUZZZ )                                        * 00628000
*/*%INCLUDE SYSLIB  (BLRFULL )                                        * 00629000
*/*%INCLUDE SYSLIB  (IKJCPPL )                                        * 00630000
*/*%INCLUDE SYSLIB  (IKJPSCB )                                        * 00631000
*/*%INCLUDE SYSLIB  (IKJECT  )                                        * 00632000
*/*%INCLUDE SYSLIB  (IKJUPT  )                                        * 00633000
*/*%INCLUDE SYSLIB  (BLSUSERV)                                        * 00634000
*/*%INCLUDE SYSLIB  (BLRSERV )                                        * 00635000
*/*%INCLUDE SYSLIB  (BLRSERVD)                                        * 00636000
*/*%INCLUDE SYSLIB  (IKJCSPL )                                        * 00637000
*/*%INCLUDE SYSLIB  (IKJIOPL )                                        * 00638000
*/*%INCLUDE SYSLIB  (IKJCSOA )                                        * 00639000
*/*%INCLUDE SYSLIB  (IKJPGPB )                                        * 00640000
*/*%INCLUDE SYSLIB  (BLSUMON1)                                        * 00641000
*/*%INCLUDE SYSLIB  (BLSUMONO)                                        * 00642000
*/*%INCLUDE SYSLIB  (BLSUMONS)                                        * 00643000
*/*%INCLUDE SYSLIB  (BLSUMONF)                                        * 00644000
*;                                                              01S0269 00645000
@EL00001 L     @13,4(,@13)                                      01S0269 00646000
@EF00001 L     @00,@SIZDATD                                     01S0269 00647000
         LR    @01,@11                                          01S0269 00648000
         FREEMAIN R,LV=(0),A=(1)                                        00649000
@ER00001 LM    @14,@12,12(@13)                                  01S0269 00650000
         BR    @14                                              01S0269 00651000
@DATA    DS    0H                                                       00652000
@CH00036 DC    H'4'                                                     00653000
@CH00090 DC    H'5'                                                     00654000
@CH00046 DC    H'8'                                                     00655000
@CH00033 DC    H'12'                                                    00656000
@CH00049 DC    H'16'                                                    00657000
@CH00173 DC    H'256'                                                   00658000
@DATD    DSECT                                                          00659000
         DS    0F                                                       00660000
@SA00001 DS    18F                                                      00661000
@AL00001 DS    4A                                                       00662000
BLSUMONI CSECT                                                          00663000
         DS    0F                                                       00664000
@CF00043 DC    F'0'                                                     00665000
@CF00058 DC    XL4'80000000'                                            00666000
@DATD    DSECT                                                          00667000
         DS    0D                                                       00668000
CSPL     DS    CL24                                                     00669000
         ORG   CSPL                                                     00670000
CSPLUPT  DS    AL4                                                      00671000
CSPLECT  DS    AL4                                                      00672000
CSPLECB  DS    AL4                                                      00673000
CSPLFLG  DS    AL4                                                      00674000
CSPLOA   DS    AL4                                                      00675000
CSPLCBUF DS    AL4                                                      00676000
         ORG   CSPL+24                                                  00677000
IOPL     DS    CL16                                                     00678000
         ORG   IOPL                                                     00679000
IOPLUPT  DS    AL4                                                      00680000
IOPLECT  DS    AL4                                                      00681000
IOPLECB  DS    AL4                                                      00682000
IOPLIOPB DS    AL4                                                      00683000
         ORG   IOPL+16                                                  00684000
CSOA     DS    CL8                                                      00685000
         ORG   CSOA                                                     00686000
CSOACNM  DS    AL4                                                      00687000
CSOALNM  DS    FL2                                                      00688000
CSOAFLG  DS    CL1                                                      00689000
         ORG   CSOAFLG                                                  00690000
CSOAVWP  DS    BL1                                                      00691000
CSOAVNP  EQU   CSOAFLG+0                                                00692000
CSOAQM   EQU   CSOAFLG+0                                                00693000
CSOANOC  EQU   CSOAFLG+0                                                00694000
CSOABAD  EQU   CSOAFLG+0                                                00695000
CSOAEXEC EQU   CSOAFLG+0                                                00696000
@NM00072 EQU   CSOAFLG+0                                                00697000
@NM00073 EQU   CSOAFLG+0                                                00698000
         ORG   CSOA+7                                                   00699000
@NM00074 DS    CL1                                                      00700000
         ORG   CSOA+8                                                   00701000
FLAG     DS    BL1                                                      00702000
         ORG   FLAG                                                     00703000
FLAGEND  DS    BL1                                                      00704000
FLAGERR  EQU   FLAG+0                                                   00705000
FLAGFFS  EQU   FLAG+0                                                   00706000
FLAGSCAN EQU   FLAG+0                                                   00707000
@NM00113 EQU   FLAG+0                                                   00708000
         ORG   FLAG+1                                                   00709000
TGETBUF  DS    CL1                                                      00710000
BLSUMONI CSECT                                                          00711000
         DS    0F                                                       00712000
@SIZDATD DC    AL1(1)                                                   00713000
         DC    AL3(@ENDDATD-@DATD)                                      00714000
         DS    0D                                                       00715000
@CC00803 DC    C'ABEND'                                                 00716000
@CC00806 DC    C'TIME'                                                  00717000
         DS    CL3                                                      00718000
OIPCS    DS    CL8                                                      00719000
         ORG   OIPCS                                                    00720000
OIPCSN   DC    A(1)                                                     00721000
OIPCSP   DC    AL4(MIPCS)                                               00722000
         ORG   OIPCS+8                                                  00723000
MIPCS    DS    CL9                                                      00724000
         ORG   MIPCS                                                    00725000
MIPCSL   DC    AL2(9)                                                   00726000
@NM00076 DC    X'0000'                                                  00727000
MIPCST   DS    CL5                                                      00728000
         ORG   MIPCST                                                   00729000
MIPCSTA  DC    CL1' '                                                   00730000
MIPCSTB  DC    CL4'IPCS'                                                00731000
         ORG   MIPCS+9                                                  00732000
TEXIT    DS    CL21                                                     00733000
         ORG   TEXIT                                                    00734000
TEXITA   DC    X'27F540'                                                00735000
TEXITB   DC    X'115D7E'                                                00736000
TEXITC   DC    X'11C150'                                                00737000
TEXITD   DC    X'114040'                                                00738000
TEXITE   DC    X'1DF8'                                                  00739000
TEXITF   DC    CL1'|'                                                   00740000
TEXITG   DC    X'1D40'                                                  00741000
TEXITH   DC    X'3C404000'                                              00742000
         ORG   TEXIT+21                                                 00743000
T3270    DS    CL15                                                     00744000
         ORG   T3270                                                    00745000
T3270A   DC    X'27F540'                                                00746000
T3270B   DC    X'115D7F'                                                00747000
T3270C   DC    X'114040'                                                00748000
T3270D   DC    X'1D40'                                                  00749000
T3270E   DC    X'3C404000'                                              00750000
         ORG   T3270+15                                                 00751000
         DS    CL3                                                      00752000
TPUTEXIT DS    CL8                                                      00753000
         ORG   TPUTEXIT                                                 00754000
@NM00077 DS    BL4                                                      00755000
         ORG   @NM00077                                                 00756000
@NM00078 DC    X'0000'                                                  00757000
@NM00079 DC    AL2(21)                                                  00758000
         ORG   TPUTEXIT+4                                               00759000
@NM00080 DS    BL4                                                      00760000
         ORG   @NM00080                                                 00761000
@NM00081 DC    X'0B'                                                    00762000
@NM00082 DC    AL3(TEXIT)                                               00763000
         ORG   TPUTEXIT+8                                               00764000
STLINENO DS    CL8                                                      00765000
         ORG   STLINENO                                                 00766000
@NM00083 DS    BL4                                                      00767000
         ORG   @NM00083                                                 00768000
@NM00084 DC    X'13'                                                    00769000
@NM00085 DC    X'000000'                                                00770000
         ORG   STLINENO+4                                               00771000
@NM00086 DS    BL4                                                      00772000
         ORG   @NM00086                                                 00773000
@NM00087 DC    X'00'                                                    00774000
@NM00088 DC    AL3(2)                                                   00775000
         ORG   STLINENO+8                                               00776000
TPUTMODE DS    CL8                                                      00777000
         ORG   TPUTMODE                                                 00778000
@NM00089 DS    BL4                                                      00779000
         ORG   @NM00089                                                 00780000
@NM00090 DC    X'0000'                                                  00781000
@NM00091 DC    AL2(4)                                                   00782000
         ORG   TPUTMODE+4                                               00783000
@NM00092 DS    BL4                                                      00784000
         ORG   @NM00092                                                 00785000
@NM00093 DC    X'00'                                                    00786000
@NM00094 DC    AL3(MIPCSTB)                                             00787000
         ORG   TPUTMODE+8                                               00788000
STFSMODE DS    CL8                                                      00789000
         ORG   STFSMODE                                                 00790000
@NM00095 DS    BL4                                                      00791000
         ORG   @NM00095                                                 00792000
@NM00096 DC    X'12'                                                    00793000
@NM00097 DC    X'000000'                                                00794000
         ORG   STFSMODE+4                                               00795000
@NM00098 DS    BL4                                                      00796000
         ORG   @NM00098                                                 00797000
@NM00099 DC    X'C0'                                                    00798000
@NM00100 DC    AL3(0)                                                   00799000
         ORG   STFSMODE+8                                               00800000
TPUT3270 DS    CL8                                                      00801000
         ORG   TPUT3270                                                 00802000
@NM00101 DS    BL4                                                      00803000
         ORG   @NM00101                                                 00804000
@NM00102 DC    X'0000'                                                  00805000
@NM00103 DC    AL2(15)                                                  00806000
         ORG   TPUT3270+4                                               00807000
@NM00104 DS    BL4                                                      00808000
         ORG   @NM00104                                                 00809000
@NM00105 DC    X'0B'                                                    00810000
@NM00106 DC    AL3(T3270)                                               00811000
         ORG   TPUT3270+8                                               00812000
TGETRESP DS    CL8                                                      00813000
         ORG   TGETRESP                                                 00814000
@NM00107 DS    BL4                                                      00815000
         ORG   @NM00107                                                 00816000
@NM00108 DC    X'0000'                                                  00817000
@NM00109 DC    AL2(0)                                                   00818000
         ORG   TGETRESP+4                                               00819000
@NM00110 DS    BL4                                                      00820000
         ORG   @NM00110                                                 00821000
@NM00111 DC    X'80'                                                    00822000
@NM00112 DC    AL3(0)                                                   00823000
         ORG   TGETRESP+8                                               00824000
@DATD    DSECT                                                          00825000
         SPACE 2                                                        00826000
*********************************************************************** 00827000
* THE FOLLOWING AREA, BLRPATCH, IS RESERVED FOR PATCH APPLICATION     * 00828000
* TO OBTAIN PATCH ROOM IN THE @DATD AUTOMATIC STORAGE AREA, MODIFY    * 00829000
* CONSTANT @SIZDATD TO REFLECT THE DESIRED @DATD SIZE                 * 00830000
*********************************************************************** 00831000
         SPACE                                                          00832000
BLSUMONI CSECT                                                          00833000
         ORG                                                            00834000
         DS    0D                                                       00835000
BLRPATCH DC    CL8'ZAPAREA',(((*-BLSUMONI+19)/20+7)/8)CL8'BLSUMONI'     00836000
@DATD    DSECT                                                          00837000
         SPACE                                                          00838000
*------- IMAGES OF PARAMETER LISTS -----------------------------------* 00839000
BLSUMONI CSECT                                                          00840000
SDATA    DS    0D                      STATIC STORAGE DATA              00841000
SPGPB    PUTGET OUTPUT=(0,TERM),MF=L                            DSKC047 00842000
SDATAEND DS    0F                      END OF SDATA                     00843000
         SPACE                                                          00844000
*------- PARAMETER LISTS ---------------------------------------------* 00845000
@DATD    DSECT                                                          00846000
ADATA    DS    0D                      AUTOMATIC STORAGE DATA           00847000
PGPB     PUTGET OUTPUT=(0,SINGLE,TERM),MF=L                             00848000
ADATAEND DS    0F                      END OF ADATA                     00849000
@DATD    DSECT                                                          00850000
         SPACE 2                                                        00851000
*********************************************************************** 00852000
* ALIGN END OF DATA ON A DOUBLEWORD BOUNDARY                          * 00853000
*********************************************************************** 00854000
         SPACE                                                          00855000
         DS    0D                                                       00856000
@DATD    DSECT                                                          00857000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00858000
@ENDDATD EQU   *                                                        00859000
BLSUMONI CSECT                                                          00860000
         BLSBVT  ,                                              DSKC047 00860010
         BLSZZ1  ,                                              DSKC047 00860020
         BLSZZ2  ,                                              DSKC047 00860030
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00861000
@01      EQU   01                                                       00862000
@02      EQU   02                                                       00863000
@03      EQU   03                                                       00864000
@04      EQU   04                                                       00865000
@05      EQU   05                                                       00866000
@06      EQU   06                                                       00867000
@07      EQU   07                                                       00868000
@08      EQU   08                                                       00869000
@09      EQU   09                                                       00870000
@10      EQU   10                                                       00871000
@11      EQU   11                                                       00872000
@12      EQU   12                                                       00873000
@13      EQU   13                                                       00874000
@14      EQU   14                                                       00875000
@15      EQU   15                                                       00876000
RETC     EQU   @02                                                      00877000
RETCPTGT EQU   @04                                                      00878000
CMDP     EQU   @06                                                      00879000
RA       EQU   @10                                                      00880000
R9       EQU   @09                                                      00881000
R0       EQU   @00                                                      00882000
R1       EQU   @01                                                      00883000
R2       EQU   @02                                                      00884000
R3       EQU   @03                                                      00885000
R4       EQU   @04                                                      00886000
R5       EQU   @05                                                      00887000
RB       EQU   @11                                                      00888000
RD       EQU   @13                                                      00889000
RE       EQU   @14                                                      00890000
RF       EQU   @15                                                      00891000
GPR01F   EQU   @01                                                      00892000
GPR00F   EQU   @00                                                      00893000
GPR01P   EQU   @01                                                      00894000
GPR15F   EQU   @15                                                      00895000
RC       EQU   @12                                                      00896000
R6       EQU   @06                                                      00897000
R7       EQU   @07                                                      00898000
R8       EQU   @08                                                      00899000
CMD      EQU   0                                                        00964000
CMDL     EQU   CMD                                                      00965000
CMDO     EQU   CMD+2                                                    00966000
CMDT     EQU   CMD+4                                                    00967000
PSCB     EQU   0                                                        00968000
PSCBATR1 EQU   PSCB+16                                                  00969000
ECT      EQU   0                                                        00970000
ECTMSGF  EQU   ECT+8                                                    00971000
ECTSWS   EQU   ECT+28                                                   00972000
ECTSWS2  EQU   ECT+40                                                   00973000
ECTSWS21 EQU   ECTSWS2                                                  00974000
UPT      EQU   0                                                        00975000
UPTSWS   EQU   UPT+12                                                   00976000
SA       EQU   0                                                        00977000
SA1      EQU   SA                                                       00978000
SAR      EQU   SA+12                                                    00979000
IKJPTGT  EQU   0                                                        00980000
PARM     EQU   0                                                        01022000
PARMZZ2  EQU   PARM+8                                                   01023000
IKJEFT25 EQU   0                                                        01024000
CSOACN   EQU   0                                                        01025000
IKJEFF02 EQU   0                                                        01075000
IKJEFF18 EQU   0                                                        01076000
IKJEFF19 EQU   0                                                        01077000
IKJGETL  EQU   0                                                        01078000
IKJPARS  EQU   0                                                        01079000
IKJPUTL  EQU   0                                                        01080000
IKJSCAN  EQU   0                                                        01081000
IKJSTCK  EQU   0                                                        01082000
I001C    EQU   0                                                        01083000
I008P    EQU   0                                                        01084000
I015F    EQU   0                                                        01085000
I015P    EQU   0                                                        01086000
I031F    EQU   0                                                        01087000
I031P    EQU   0                                                        01088000
I256C    EQU   0                                                        01089000
PGPBIBUF EQU   PGPB+12                                                  01090000
CPPL     EQU   ZZ2CPPL                                                  01091000
CPPLUPT  EQU   CPPL+4                                                   01092000
CPPLPSCB EQU   CPPL+8                                                   01093000
CPPLECT  EQU   CPPL+12                                                  01094000
PGPBOPUT EQU   PGPB+4                                                   01095000
@RF00107 EQU   EXIT                                                     01417000
@RT00133 EQU   EXIT                                                     01418000
@RF00142 EQU   EXIT                                                     01419000
@RC00140 EQU   EXIT                                                     01420000
@RC00200 EQU   @RC00187                                                 01421000
@RF00253 EQU   @EL00002                                                 01422000
@ENDDATA EQU   *                                                        01423000
         END   BLSUMONI                                         DSKC047 01424000
