         TITLE '** IEAVCKEY-VS2/SU7 CHANGE STORAGE PROTECT KEY ROUTINE *00001000
                **      '                                               00002000
@DATD    DSECT ,                                                DSK0343 00002010
SAVEREGS DS    0A      000                                      DSK0343 00002020
REQUEST  DS    A       000                                      DSK0343 00002030
NEWKEY   EQU REQUEST   000                                      DSK0343 00002040
KEYANDFP EQU REQUEST+3 000+3                                    DSK0343 00002050
INR1     DS    A       004                                      DSK0343 00002060
         DS    A       008                                      DSK0343 00002070
         DS    A       012                                      DSK0343 00002080
         DS    A       016                                      DSK0343 00002090
         DS    A       020                                      DSK0343 00002100
         DS    A       024                                      DSK0343 00002110
         DS    A       028                                      DSK0343 00002120
         DS    A       032                                      DSK0343 00002130
         DS    A       036                                      DSK0343 00002140
         DS    A       040                                      DSK0343 00002150
         DS    A       044                                      DSK0343 00002160
         DS    A       048                                      DSK0343 00002170
         DS    A       052                                      DSK0343 00002180
         DS    A       056                                      DSK0343 00002190
RETAD1   DS    A       060                                      DSK0343 00002200
RETAD2   DS    A       064                                      DSK0343 00002210
DATD68   DS    A       068                                      DSK0343 00002220
PTEPTR   DS    A       072                                      DSK0343 00002230
XPTEPTR  DS    A       076                                      DSK0343 00002240
PARMPTR  DS    A       080                                      DSK0343 00002250
ELTAD    DS    A       084                                      DSK0343 00002260
LPC      DS    A       088                                      DSK0343 00002270
PGAD     DS    A       092                                      DSK0343 00002280
SEG      EQU PGAD+2    094+2                                    DSK0343 00002290
LPG      DS    A       096                                      DSK0343 00002300
RCSAVE   DS    A       100                                      DSK0343 00002310
ERROR    DS    0X      104                                      DSK0343 00002320
SAVEKEY  DS    0X      104                                      DSK0343 00002330
COND1    DS    0X      104                                      DSK0343 00002340
COND2    DS    0X      104                                      DSK0343 00002350
FLAGS    DS    X       104                                      DSK0343 00002360
OLDKEYFP DS    X       105                                      DSK0343 00002370
CKEYBASE EQU   0                                                DSK0343 00002390
INRCV    EQU   4                                                DSK0343 00002400
FPA      EQU   1                                                DSK0343 00002420
LASTELT  EQU   4                                                DSK0343 00002430
LPA      EQU   5                                                DSK0343 00002440
IEAVCKEY CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK0343 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
         DC    AL1(16)                                             0001 00008000
         DC    C'IEAVCKEY  76.239'                                 0001 00009000
CKEYRTRY DC    0H'0'                                            DSK0343 00010000
         USING *,R15                                            DSK0343 00011000
         B     @PROLOG                                             0001 00012000
         DC    AL2(@EP00241-CKEYRTRY)                                   00013000
         ENTRY CKEYRTRY                                                 00014000
         DROP  R15                                              DSK0343 00015000
@PROLOG  AH    R15,4(,R15)                                      DSK0343 00016000
         BR    R15                                              DSK0343 00017000
@EP00001 DS    0H                                                  0002 00018000
*                                     /*ENTRY LINKAGE                   00019000
         USING PSA,0                  ADDRESS LOW STORAGE               00020000
         L     R15,PSAAOLD            ADDRESS                   DSK0343 00021000
         USING ASCB,R15                 CURRENT ASCB            DSK0343 00022000
         L     R15,ASCBLDA            ADDRESS                   DSK0343 00023000
         USING LDA,R15                  LDA                     DSK0343 00024000
         LA    R15,CFAPWKAR           TEMP ADDRESSABILITY       DSK0343 00025000
         USING @DATD,R15                FOR WORK/SAVE AREA      DSK0343 00026000
*                                                                       00027000
*        THE 75-WORD AREA, CFAPWKAR, IN THE LDA IS USED AS A WORK/SAVE  00028000
*        AREA TO ACHIEVE REENTRANT ATTRIBUTE.                           00029000
*                                                                       00030000
         STM   R0,R14,SAVEREGS       SAVE CALLER'S REGS         DSK0343 00031000
*                                                                       00032000
*        IF THE CALLING PGM IS NOT PSW KEY 0, A PGM CHECK WILL RESULT   00033000
*        FROM EXECUTION OF THIS INSTRUCTION.                            00034000
*                                                                       00035000
         DROP  R15                                              DSK0343 00036000
         LR    R9,R15                DATAREG                    DSK0343 00037000
         USING @DATD,R9              ADDRESS WORK/SAVE AREA     DSK0343 00038000
         BALR  R10,0                  CODEREG                   DSK0343 00039000
         USING *,R10                  ADDRESSABILITY FOR MODULE DSK0343 00040000
FRRON   SETFRR A,FRRAD=CKFRR,PARMAD=PARMPTR,WRKREGS=(R3,R4),RELATED=(FR~00041000
               R,CKEY(FRROFF,FRROFF2))                          DSK0343 00041001
*   CKEYBASE=REG10;                 /* INITIALIZE FRR PARM AREA      */ 00043000
         L     R12,PARMPTR                                      DSK0343 00044000
         ST    R10,CKEYBASE(,R12)                               DSK0343 00045000
*   IF REQUEST=LTYPE THEN           /* DETERMINE INTERFACE USED      */ 00046000
         CLI   REQUEST,128                                         0043 00047000
         BNE   @RF00043                                            0043 00048000
*     CALL LISTPROC;                /* PROCESS L-TYPE REQUESTS       */ 00049000
         BAL   R14,LISTPROC                                     DSK0343 00050000
*   ELSE                                                           0045 00051000
*     CALL REGPROC;                 /* PROCESS R-TYPE REQUESTS       */ 00052000
         B     @RC00043                                            0045 00053000
@RF00043 BAL   R14,REGPROC                                      DSK0343 00054000
*   GEN SETS(REG03,REG04);                                         0046 00055000
@RC00043 DS    0H                                                  0046 00056000
*                       /*                                              00057000
FRROFF   SETFRR D,WRKREGS=(R3,R4),RELATED=(FRR,CKEY(FRRON))     DSK0343 00058000
*   IF RETCODE^=0 THEN              /* TEST RETURN CODE              */ 00059000
         LTR   R15,R15                                          DSK0343 00060000
         BZ    @RF00047                                            0047 00061000
*     DO;                           /* ABEND(O8F) SYSTEM             */ 00062000
*       RESPECIFY                                                  0049 00063000
*        (GPR01F) RESTRICTED;                                      0049 00064000
*       GPR01F=((O8F)&'00000FFF'X)*4096;/* COMP CODE IN BITS 8-19    */ 00065000
         LA    R1,143                                           DSK0343 00066000
         N     R1,@CF01514                                      DSK0343 00067000
         SLA   R1,12                                            DSK0343 00068000
*       SVC(13);                    /* ISSUE ABEND SVC               */ 00069000
         SVC   13                                                  0051 00070000
*       RESPECIFY                                                  0052 00071000
*        (GPR01F) UNRESTRICTED;                                    0052 00072000
*     END;                          /* ABEND(O8F) SYSTEM NOT ZERO: 0053 00073000
*                                      CHANGE KEY FAILED             */ 00074000
*   REG00=OLDKEYFP;                 /* ZERO: CHANGE KEY SUCCESSFUL.     00075000
*                                      RETURN ORIGINAL STORAGE KEY   */ 00076000
@RF00047 SLR   R0,R0                                            DSK0343 00077000
         IC    R0,OLDKEYFP                                      DSK0343 00078000
*   GEN REFS(SAVEREGS);                                            0055 00079000
*                             /*                                        00080000
         LM    R1,R14,INR1           RESTORE CALLER'S REGS      DSK0343 00081000
*   RETURN;                         /* RETURN TO CALLING PGM         */ 00082000
@EL00001 DS    0H                                                  0056 00083000
@EF00001 DS    0H                                                  0056 00084000
@ER00001 BR    R14                                              DSK0343 00085000
*                                                                  0057 00086000
*   /*****************************************************************/ 00087000
*   /*                                                               */ 00088000
*   /* ROUTINE TO PROCESS R-TYPE REQUESTS                            */ 00089000
*   /*                                                               */ 00090000
*   /*****************************************************************/ 00091000
*                                                                  0057 00092000
*REGPROC:                                                          0057 00093000
*   PROC OPTIONS(NOSAVE);                                          0057 00094000
REGPROC  DS    0H                                                  0058 00095000
*   RETAD1=REG14;                   /* SAVE RETURN ADDRESS           */ 00096000
         ST    R14,RETAD1                                       DSK0343 00097000
*   FLAGS=0;                        /* INTERNAL INDICATORS OFF       */ 00098000
         MVI   FLAGS,X'00'                                         0059 00099000
*   ELTAD=ADDR(INR1);               /* ONE VA RANGE GIVEN BY INPUT R1   00100000
*                                      AND R2                        */ 00101000
*                                                                  0060 00102000
         LA    R12,INR1                                         DSK0343 00103000
         ST    R12,ELTAD                                        DSK0343 00104000
*   /*****************************************************************/ 00105000
*   /*                                                               */ 00106000
*   /* VALIDITY CHECK INPUT PARAMETERS: STORAGE DEFINED BY VA RANGE  */ 00107000
*   /* MUST BE IN PROBLEM PROGRAM SUBPOOLS                           */ 00108000
*   /*                                                               */ 00109000
*   /*****************************************************************/ 00110000
*                                                                  0061 00111000
*   CALL PAGEVCK;                   /* VALIDITY CHECK: STORAGE IN  0061 00112000
*                                      PROBLEM PROGRAM SUBPOOLS      */ 00113000
         BAL   R14,PAGEVCK                                      DSK0343 00114000
*   IF RETCODE=0 THEN               /* TEST RETURN CODE              */ 00115000
         LTR   R15,R15                                          DSK0343 00116000
         BNZ   @RF00062                                            0062 00117000
*     DO;                           /* RC ZERO: VA RANGE VALID       */ 00118000
*       SAVEKEY=YES;                /* SAVE ORIGINAL KEY             */ 00119000
         OI    SAVEKEY,B'10000000'                                 0064 00120000
*       GEN REFS(PSALITA,FLC) SETS(REG11,REG12,REG13);             0065 00121000
*                                                   /*OBTAIN SALLOC     00122000
LOCKON   SETLOCK OBTAIN,TYPE=SALLOC,MODE=UNCOND,                      --00123000
               RELATED=(PAGES,CKEY(LOCKOFF))                            00124000
*       LPC=NONE;                   /* NO KEY FOR ANY PAGE CHANGED   */ 00125000
*                                                                  0066 00126000
         SLR   R12,R12                                          DSK0343 00127000
         ST    R12,LPC                                          DSK0343 00128000
*       /*************************************************************/ 00129000
*       /*                                                           */ 00130000
*       /* CHANGE STORAGE KEY: THE XPTPROT FIELD IN THE XPTE AND THE */ 00131000
*       /* HARDWARE KEY FOR EACH PAGE IS CHANGED                     */ 00132000
*       /*                                                           */ 00133000
*       /*************************************************************/ 00134000
*                                                                  0067 00135000
*       CALL ELTPROC;               /* CHANGE STORAGE KEY FOR RANGE  */ 00136000
         BAL   R14,ELTPROC                                      DSK0343 00137000
*       IF RETCODE^=0 THEN          /* TEST RETURN CODE              */ 00138000
         LTR   R15,R15                                          DSK0343 00139000
         BZ    @RF00068                                            0068 00140000
*         CALL RECOVER;             /* RC NOT ZERO: CHANGE         0069 00141000
*                                      INCOMPLETE, RESTORE ORIGINAL     00142000
*                                      KEY                           */ 00143000
         BAL   R14,RECOVER                                      DSK0343 00144000
*       ELSE                                                       0070 00145000
*         ;                         /* RC ZERO: KEY CHANGED          */ 00146000
@RF00068 DS    0H                                                  0071 00147000
*       GEN REFS(PSALITA,FLC) SETS(REG11,REG12,REG13);             0071 00148000
*                                                  /*RELEASE SALLOC     00149000
LOCKOFF  SETLOCK RELEASE,TYPE=SALLOC,                                 --00150000
               RELATED=(PAGES,CKEY(LOCKON))                             00151000
*     END;                                                         0072 00152000
*   ELSE                                                           0073 00153000
*     ;                             /* RC NOT ZERO: VA RANGE INVALID    00154000
*                                      , KEY NOT CHANGED             */ 00155000
@RF00062 DS    0H                                                  0074 00156000
*   REG14=RETAD1;                   /* RESTORE RETURN ADDRESS        */ 00157000
         L     R14,RETAD1                                       DSK0343 00158000
*   RETURN CODE(RETCODE);           /* RETURN TO TOP ROUTINE         */ 00159000
@EL00002 DS    0H                                                  0075 00160000
@EF00002 DS    0H                                                  0075 00161000
@ER00002 BR    R14                                              DSK0343 00162000
*   END REGPROC;                                                   0076 00163000
*                                                                  0077 00164000
*   /*****************************************************************/ 00165000
*   /*                                                               */ 00166000
*   /* ROUTINE TO PROCESS L-TYPE REQUESTS                            */ 00167000
*   /*                                                               */ 00168000
*   /*****************************************************************/ 00169000
*                                                                  0077 00170000
*LISTPROC:                                                         0077 00171000
*   PROC OPTIONS(NOSAVE);                                          0077 00172000
LISTPROC DS    0H                                                  0078 00173000
*   RETAD1=REG14;                   /* SAVE RETURN ADDRESS           */ 00174000
         ST    R14,RETAD1                                       DSK0343 00175000
*   FLAGS=0;                        /* INTERNAL INDICATORS OFF       */ 00176000
         MVI   FLAGS,X'00'                                         0079 00177000
*   LPC=NONE;                       /* NO KEY FOR ANY PAGE CHANGED   */ 00178000
         SLR   R12,R12                                          DSK0343 00179000
         ST    R12,LPC                                          DSK0343 00180000
*   ELTAD=INR1-LENGTH(LISTELT);     /* ADDRESS-8 OF FIRST ELEMENT IN    00181000
*                                      LIST                          */ 00182000
         L     R12,INR1                                         DSK0343 00183000
         SL    R12,@CF00068                                     DSK0343 00184000
         ST    R12,ELTAD                                        DSK0343 00185000
*   GEN REFS(PSALITA,FLC) SETS(REG11,REG12,REG13);                 0082 00186000
*                                                                  0082 00187000
*                                                   /*OBTAIN SALLOC     00188000
LOCKON2  SETLOCK OBTAIN,TYPE=SALLOC,MODE=UNCOND,                      --00189000
               RELATED=(PAGES,CKEY(LOCKOFF2))                           00190000
*   /*****************************************************************/ 00191000
*   /*                                                               */ 00192000
*   /* VALIDITY CHECK INPUT PARAMETERS: PARAMETER LIST MUST BE IN    */ 00193000
*   /* FIXED STORAGE. STORAGE DEFINED BY EACH ELEMENT IN LIST MUST BE*/ 00194000
*   /* IN PROBLEM PROGRAM SUBPOOLS                                   */ 00195000
*   /*                                                               */ 00196000
*   /*****************************************************************/ 00197000
*                                                                  0083 00198000
*   DO UNTIL(ERROR=YES×LASTELT=YES);/* CHECK EACH ELT IN LIST OR   0083 00199000
*                                      UNTIL ERROR IS DETECTED       */ 00200000
@DL00083 DS    0H                                                  0084 00201000
*     ELTAD=ELTAD+LENGTH(LISTELT);  /* LIST ELEMENT ADDRESS          */ 00202000
         LA    R12,8                                            DSK0343 00203000
         AL    R12,ELTAD                                        DSK0343 00204000
         ST    R12,ELTAD                                        DSK0343 00205000
*     CALL ELTVCK;                  /* VALIDITY CHECK: ELT IN FIXED     00206000
*                                      STORAGE                       */ 00207000
         BAL   R14,ELTVCK                                       DSK0343 00208000
*     IF RETCODE=0 THEN             /* TEST RETURN CODE              */ 00209000
         LTR   R15,R15                                          DSK0343 00210000
         BNZ   @RF00086                                            0086 00211000
*       DO;                         /* RC ZERO: ELEMENT VALID        */ 00212000
*         CALL PAGEVCK;             /* VALIDITY CHECK: VA RANGE IN 0088 00213000
*                                      PROBLEM PGM SUBPOOLS          */ 00214000
         BAL   R14,PAGEVCK                                      DSK0343 00215000
*         IF RETCODE^=0 THEN        /* TEST RETURN CODE              */ 00216000
         LTR   R15,R15                                          DSK0343 00217000
         BZ    @RF00089                                            0089 00218000
*           ERROR=YES;              /* RC NOT ZERO: RANGE INVALID    */ 00219000
         OI    ERROR,B'01000000'                                   0090 00220000
*         ELSE                                                     0091 00221000
*           ;                       /* RC ZERO:RANGE VALID           */ 00222000
@RF00089 DS    0H                                                  0092 00223000
*       END;                                                       0092 00224000
*     ELSE                          /* RC NOT ZERO: ELT INVALID      */ 00225000
*       ERROR=YES;                  /* INDICATE ERROR CONDITION      */ 00226000
         B     @RC00086                                            0093 00227000
@RF00086 OI    ERROR,B'01000000'                                   0093 00228000
*   END;                                                           0094 00229000
*                                                                  0094 00230000
@RC00086 DS    0H                                                  0094 00231000
@DE00083 TM    ERROR,B'01000000'                                   0094 00232000
         BO    @DC00083                                            0094 00233000
         L     R12,ELTAD                                        DSK0343 00234000
         TM    LASTELT(R12),B'10000000'                         DSK0343 00235000
         BNO   @DL00083                                            0094 00236000
@DC00083 DS    0H                                                  0095 00237000
*   /*****************************************************************/ 00238000
*   /*                                                               */ 00239000
*   /* CHANGE STORAGE KEY: THE FIELD XPTPROT IN THE XPTE AND THE     */ 00240000
*   /* HARDWARE KEY FOR EACH PAGE IS CHANGED                         */ 00241000
*   /*                                                               */ 00242000
*   /*****************************************************************/ 00243000
*                                                                  0095 00244000
*   IF ERROR=NO THEN                /* WAS AN ERROR DETECTED ?       */ 00245000
         TM    ERROR,B'01000000'                                   0095 00246000
         BNZ   @RF00095                                            0095 00247000
*     DO;                           /* NO: CONTINUE KEY PROCESSING   */ 00248000
*       ELTAD=INR1-LENGTH(LISTELT); /* ADDRESS-8 OF FIRST ELT IN LIST*/ 00249000
         L     R12,INR1                                         DSK0343 00250000
         SL    R12,@CF00068                                     DSK0343 00251000
         ST    R12,ELTAD                                        DSK0343 00252000
*       SAVEKEY=YES;                /* SAVE ORIGINAL KEY             */ 00253000
         OI    SAVEKEY,B'10000000'                                 0098 00254000
*       DO UNTIL(LASTELT=YES×ERROR=YES);/* CHANGE KEY OF ALL RANGES     00255000
*                                      OR UNTIL ERROR IS DETECTED    */ 00256000
A000182  DS    0H                                               DSK0343 00256010
@DL00099 DS    0H                                                  0100 00257000
*         ELTAD=ELTAD+LENGTH(LISTELT);/* LIST ELEMENT ADDRESS        */ 00258000
         LA    R12,8                                            DSK0343 00259000
         AL    R12,ELTAD                                        DSK0343 00260000
         ST    R12,ELTAD                                        DSK0343 00261000
*         CALL ELTPROC;             /* CHANGE KEY OF SINGLE RANGE    */ 00262000
         BAL   R14,ELTPROC                                      DSK0343 00263000
*         IF RETCODE^=0 THEN        /* TEST RETURN CODE              */ 00264000
         LTR   R15,R15                                          DSK0343 00265000
         BZ    @RF00102                                            0102 00266000
*           DO;                                                    0103 00267000
*             ERROR=YES;            /* INDICATE ERROR CONDITION      */ 00268000
         OI    ERROR,B'01000000'                                   0104 00269000
*             CALL RECOVER;         /* RESTORE ORIGINAL KEY          */ 00270000
         BAL   R14,RECOVER                                      DSK0343 00271000
*           END;                                                   0106 00272000
*         ELSE                                                     0107 00273000
*           ;                       /* RC ZERO: KEY CHANGED          */ 00274000
@RF00102 DS    0H                                                  0108 00275000
*       END;                                                       0108 00276000
@DE00099 L     R12,ELTAD                                        DSK0343 00277000
         TM    LASTELT(R12),B'10000000'                         DSK0343 00278000
         BO    @DC00099                                            0108 00279000
         TM    ERROR,B'01000000'                                   0108 00280000
         BNO   @DL00099                                            0108 00281000
@DC00099 DS    0H                                                  0109 00282000
*     END;                                                         0109 00283000
*   ELSE                                                           0110 00284000
*     ;                             /* YES: KEY UNCHANGED            */ 00285000
@RF00095 DS    0H                                                  0111 00286000
*   GEN REFS(PSALITA,FLC) SETS(REG11,REG12,REG13);                 0111 00287000
*                                                /*RELEASE SALLOC       00288000
LOCKOFF2 SETLOCK RELEASE,TYPE=SALLOC,                                 --00289000
               RELATED=(PAGES,CKEY(LOCKON2))                            00290000
*   REG14=RETAD1;                   /* RESTORE RETURN ADDRESS        */ 00291000
         L     R14,RETAD1                                       DSK0343 00292000
*   RETURN CODE(RETCODE);           /* RETURN TO TOP ROUTINE         */ 00293000
@EL00003 DS    0H                                                  0113 00294000
@EF00003 DS    0H                                                  0113 00295000
@ER00003 BR    R14                                              DSK0343 00296000
*   END LISTPROC;                                                  0114 00297000
*                                                                  0115 00298000
*   /*****************************************************************/ 00299000
*   /*                                                               */ 00300000
*   /* ROUTINE TO CHANGE THE KEY OF THE STORAGE AREA DEFINED BY ONE  */ 00301000
*   /* VA RANGE                                                      */ 00302000
*   /*                                                               */ 00303000
*   /*****************************************************************/ 00304000
*                                                                  0115 00305000
*ELTPROC:                                                          0115 00306000
*   PROC OPTIONS(NOSAVE);                                          0115 00307000
ELTPROC  DS    0H                                                  0116 00308000
*   RETAD2=REG14;                   /* SAVE RETURN ADDRESS           */ 00309000
         ST    R14,RETAD2                                       DSK0343 00310000
*   PGAD=FPA;                       /* FIRST PAGE PROCESSED          */ 00311000
*                                                                  0117 00312000
         L     R12,ELTAD                                        DSK0343 00313000
         L     R12,FPA-1(,R12)                                  DSK0343 00314000
         LA    R12,0(,R12)                                      DSK0343 00315000
         ST    R12,PGAD                                         DSK0343 00316000
*   /*****************************************************************/ 00317000
*   /*                                                               */ 00318000
*   /* STORAGE KEY CHANGED BY CHANGING THE PROTECT KEY FOR EACH PAGE */ 00319000
*   /* IN THE VA RANGE. PROCESSING IS NOT COMPLETED IF A PAGE IN THE */ 00320000
*   /* VA RANGE IS FOUND THAT HAS NOT BEEN GETMAINED.                */ 00321000
*   /*                                                               */ 00322000
*   /*****************************************************************/ 00323000
*                                                                  0118 00324000
*NEWSEG:                            /* REPEATED FOR EACH PAGE IN A 0118 00325000
*                                      NEW SEGMENT                   */ 00326000
*   RESPECIFY                                                      0118 00327000
*    (REG01,                                                       0118 00328000
*     REG02,                                                       0118 00329000
*     REG03) RSTD;                  /* REGS USED BY FINDPAGE         */ 00330000
@RT00166 DS    0H                                               DSK0343 00330010
NEWSEG   DS    0H                                                  0119 00331000
*   REG01=PGAD;                     /* PAGE ADDRESS                  */ 00332000
         L     R1,PGAD                                          DSK0343 00333000
*   REG02=RSMHDPTR;                 /* RSMHD ADDRESS                 */ 00334000
         L     R12,PSAAOLD-PSA                                  DSK0343 00335000
         L     R2,ASCBRSM-ASCB(,R12)                            DSK0343 00336000
*   REG03=PVTPTR;                   /* PVT ADDRESS                   */ 00337000
         L     R12,CVTPTR                                       DSK0343 00338000
         L     R12,CVTPVTP-CVT(,R12)                            DSK0343 00339000
         LR    R3,R12                                           DSK0343 00340000
*   CALL IEAVFP2;                   /* GET PGTE,XPTE FOR PAGE        */ 00341000
         L     R15,PVTPFP2-PVT(,R12)  FIND PAGE                 DSK0343 00342000
         BALR  R14,R15                                          DSK0343 00343000
*   PTEPTR=REG00;                   /* ADDRESS PGTE                  */ 00344000
         ST    R0,PTEPTR                                        DSK0343 00345000
*   XPTEPTR=REG01;                  /* ADDRESS XPTE                  */ 00346000
         ST    R1,XPTEPTR                                       DSK0343 00347000
*   RESPECIFY                                                      0125 00348000
*    (REG01,                                                       0125 00349000
*     REG02,                                                       0125 00350000
*     REG03) UNRSTD;                                               0125 00351000
*   IF RETCODE=0 THEN               /* TEST RETURN CODE              */ 00352000
         LTR   R15,R15                                          DSK0343 00353000
         BNZ   @RF00126                                            0126 00354000
*SAMESEG:                                                          0127 00355000
*     DO;                           /* RC ZERO: PGTE,XPTE FOUND.   0127 00356000
*                                      REPEATED FOR EACH PAGE IN THE    00357000
*                                      SAME SEGMENT.                 */ 00358000
@RT00163 DS    0H                                               DSK0343 00358010
SAMESEG  DS    0H                                                  0128 00359000
*       IF PGTPAM=YES THEN          /* PAGE GM ASSIGNED ?            */ 00360000
         L     R12,PTEPTR                                       DSK0343 00361000
         TM    PGTBITS-PGTPTE(R12),PGTPAM                       DSK0343 00362000
         BNO   @RF00128                                            0128 00363000
*         DO;                       /* YES: KEY WILL BE CHANGED      */ 00364000
*           IF SAVEKEY=YES THEN     /* SAVE KEY OF THIS PAGE ?       */ 00365000
         TM    SAVEKEY,B'10000000'                                 0130 00366000
         BNO   @RF00130                                            0130 00367000
*             DO;                   /* YES: XPTPROT IS SAVED         */ 00368000
*               OLDKEYFP=XPTPROT;   /* ORIGINAL STORAGE KEY          */ 00369000
         L     R12,XPTEPTR                                      DSK0343 00370000
         IC    R11,XPTPROT-XPTE(,R12)                           DSK0343 00371000
         STC   R11,OLDKEYFP                                     DSK0343 00372000
*               SAVEKEY=NO;         /* NO OTHER KEY IS SAVED         */ 00373000
         NI    SAVEKEY,B'01111111'                                 0133 00374000
*             END;                                                 0134 00375000
*           ELSE                                                   0135 00376000
*             ;                     /* NO: CONTINUE                  */ 00377000
@RF00130 DS    0H                                                  0136 00378000
*           LPC=PGAD;               /* PAGE ADDRESS BEING PROCESSED  */ 00379000
         L     R12,PGAD                                         DSK0343 00380000
         ST    R12,LPC                                          DSK0343 00381000
*           CALL KEYCHG;            /* CHANGE KEY OF PAGE            */ 00382000
         BAL   R14,KEYCHG                                       DSK0343 00383000
*           PGAD=PGAD+C4K;          /* NEXT PAGE ADDRESS IN RANGE    */ 00384000
         L     R12,@CF00106                                     DSK0343 00385000
         AL    R12,PGAD                                         DSK0343 00386000
         ST    R12,PGAD                                         DSK0343 00387000
*           COND1=NO;                                              0139 00388000
*           COND2=NO;                                              0140 00389000
         NI    COND1,B'11001111'                                   0140 00390000
*           IF PGAD<=LPA THEN       /* ALL PAGES PROCESSED ?         */ 00391000
         L     R11,ELTAD                                        DSK0343 00392000
         L     R11,LPA-1(,R11)                                  DSK0343 00393000
         LA    R11,0(,R11)                                      DSK0343 00394000
         CR    R12,R11                                          DSK0343 00395000
         BH    @RF00141                                            0141 00396000
*             DO;                   /* NO: CONTINUE WITH NEXT PAGE   */ 00397000
*               COND1=YES;          /* INDICATE PAGE EXISTS          */ 00398000
         OI    COND1,B'00100000'                                   0143 00399000
*               IF SEG^=NEW THEN    /* PAGE IN SAME SEGMENT ?        */ 00400000
         TM    SEG,B'11110000'                                     0144 00401000
         BZ    @RF00144                                            0144 00402000
*                 DO;               /* YES: PGTE,XPTE BY INCREMENTING   00403000
*                                      DOWN TABLES                   */ 00404000
*                   PTEPTR=PTEPTR+LENGTH(PGTPTE);/* NEXT PGTE ADDRESS*/ 00405000
         LA    R12,2                                            DSK0343 00406000
         AL    R12,PTEPTR                                       DSK0343 00407000
         ST    R12,PTEPTR                                       DSK0343 00408000
*                   XPTEPTR=XPTEPTR+LENGTH(XPTE);/* NEXT XPTE ADDRESS*/ 00409000
         LA    R12,12                                           DSK0343 00410000
         AL    R12,XPTEPTR                                      DSK0343 00411000
         ST    R12,XPTEPTR                                      DSK0343 00412000
*                   COND2=YES;      /* INDICATE SAME SEGMENT         */ 00413000
         OI    COND2,B'00010000'                                   0148 00414000
*                 END;                                             0149 00415000
*               ELSE                                               0150 00416000
*                 ;                 /* NO: PGTE,XPTE BY FINDPAGE     */ 00417000
@RF00144 DS    0H                                                  0151 00418000
*             END;                                                 0151 00419000
*           ELSE                                                   0152 00420000
*             ;                     /* YES: END PROCESSING           */ 00421000
@RF00141 DS    0H                                                  0153 00422000
*         END;                                                     0153 00423000
*       ELSE                        /* NO: ERROR CONDITION           */ 00424000
*         DO;                                                      0154 00425000
         B     @RC00128                                            0154 00426000
@RF00128 DS    0H                                                  0155 00427000
*           RETCODE=8;              /* IDENTIFY ERROR                */ 00428000
         LA    R15,8                                            DSK0343 00429000
*           ERROR=YES;              /* INDICATE ERROR DETECTED       */ 00430000
         OI    ERROR,B'01000000'                                   0156 00431000
*         END;                                                     0157 00432000
*     END;                                                         0158 00433000
*   ELSE                            /* RC NOT ZERO: NO PGTE,XPTE     */ 00434000
*     DO;                                                          0159 00435000
         B     @RC00126                                            0159 00436000
@RF00126 DS    0H                                                  0160 00437000
*       RETCODE=16;                 /* IDENTIFY ERROR                */ 00438000
         LA    R15,16                                           DSK0343 00439000
*       ERROR=YES;                  /* INDICATE ERROR DETECTED       */ 00440000
         OI    ERROR,B'01000000'                                   0161 00441000
*     END;                                                         0162 00442000
*   IF COND2=YES&ERROR=NO THEN      /* SAME SEG AND NO ERROR ?       */ 00443000
@RC00128 DS    0H                                               DSK0343 00443010
@RC00126 TM    COND2,B'00010000'                                   0163 00444000
         BNO   @RF00163                                            0163 00445000
         TM    ERROR,B'01000000'                                   0163 00446000
         BZ    @RT00163                                            0163 00447000
*     GOTO SAMESEG;                 /* YES: REPEAT SAMESEG           */ 00448000
*   ELSE                                                           0165 00449000
*     ;                             /* NO: CONTINUE                  */ 00450000
@RF00163 DS    0H                                                  0166 00451000
*   IF COND1=YES&ERROR=NO THEN      /* NEW SEG AND NO ERROR ?        */ 00452000
         TM    COND1,B'00100000'                                   0166 00453000
         BNO   @RF00166                                            0166 00454000
         TM    ERROR,B'01000000'                                   0166 00455000
         BZ    @RT00166                                            0166 00456000
*     GOTO NEWSEG;                  /* YES: REPEAT NEWSEG            */ 00457000
*   ELSE                                                           0168 00458000
*     ;                             /* NO: ALL PAGES ARE PROCESSED OR   00459000
*                                      ERROR HAS BEEN DETECTED       */ 00460000
@RF00166 DS    0H                                                  0169 00461000
*   REG14=RETAD2;                   /* RESTORE RETURN ADDRESS        */ 00462000
         L     R14,RETAD2                                       DSK0343 00463000
*   RETURN CODE(RETCODE);           /* RETURN TO CALLING ROUTINE     */ 00464000
@EL00004 DS    0H                                                  0170 00465000
@EF00004 DS    0H                                                  0170 00466000
@ER00004 BR    R14                                              DSK0343 00467000
*   END ELTPROC;                                                   0171 00468000
*                                                                  0172 00469000
*   /*****************************************************************/ 00470000
*   /*                                                               */ 00471000
*   /* ROUTINE TO VERIFY THAT A PARAMETER LIST ELEMENT IS IN FIXED   */ 00472000
*   /* STORAGE AT THE TIME IEAVCKEY WAS INVOKED.                     */ 00473000
*   /*                                                               */ 00474000
*   /*****************************************************************/ 00475000
*                                                                  0172 00476000
*ELTVCK:                                                           0172 00477000
*   PROC OPTIONS(NOSAVE);                                          0172 00478000
ELTVCK   DS    0H                                                  0173 00479000
*   GEN REFS(ELTAD);                                               0173 00480000
*                 /*                                                    00481000
*         ELEMENT IS IN REAL STORAGE IF THE FIRST AND LAST BYTE OF      00482000
*         THE ELEMENT ARE IN REAL STORAGE                               00483000
         L     R15,ELTAD              ELEMENT VA                DSK0343 00484000
         LRA   R15,0(R15)             FIRST BYTE IN REAL STORAG DSK0343 00485000
         BNZ   ERR12                  NO: ERROR CONDITION               00486000
         L     R15,ELTAD              YES: ELEMENT ENDING       DSK0343 00487000
         LA    R15,7(R15)                  VIRTUAL ADDRESS      DSK0343 00488000
         LRA   R15,0(R15)             LAST BYTE IN REAL STORAGE DSK0343 00489000
         BNZ   ERR12                  NO: ERROR CONDITION               00490000
         SR    R15,R15                YES: ELT IN FIXED STORAGE DSK0343 00491000
         BR    R14                    RETURN TO LISTPROC        DSK0343 00492000
ERR12    LA    R15,12                 IDENTIFY ERROR            DSK0343 00493000
*   RETURN;                         /* RETURN TO LISTPROC            */ 00494000
@EL00005 DS    0H                                                  0174 00495000
@EF00005 DS    0H                                                  0174 00496000
@ER00005 BR    R14                                              DSK0343 00497000
*   END ELTVCK;                                                    0175 00498000
*                                                                  0176 00499000
*   /*****************************************************************/ 00500000
*   /*                                                               */ 00501000
*   /* ROUTINE TO VERIFY STORAGE DEFINED BY A VA RANGE IS FROM       */ 00502000
*   /* SUBPOOLS 0-127, 251, AND 252                                  */ 00503000
*   /*                                                               */ 00504000
*   /*****************************************************************/ 00505000
*                                                                  0176 00506000
*PAGEVCK:                                                          0176 00507000
*   PROC OPTIONS(NOSAVE);                                          0176 00508000
PAGEVCK  DS    0H                                                  0177 00509000
*   IF FPA<=LPA THEN                /* WRAP AROUND NOT PERMITTED     */ 00510000
         L     R12,ELTAD                                        DSK0343 00511000
         CLC   FPA(3,R12),LPA(R12)                              DSK0343 00512000
         BH    @RF00177                                            0177 00513000
*     DO;                                                          0178 00514000
*       IF FPA>=PASTRT THEN         /* STORAGE ABOVE PRIVATE AREA  0179 00515000
*                                      START ?                       */ 00516000
         L     R11,CVTPTR                                       DSK0343 00517000
         L     R1,CVTGDA-CVT(,R11)                              DSK0343 00518000
         L     R11,FPA-1(,R12)                                  DSK0343 00519000
         LA    R11,0(,R11)                                      DSK0343 00520000
         C     R11,PASTRT-GDA(,R1)                              DSK0343 00521000
         BL    @RF00179                                            0179 00522000
*         DO;                       /* YES: CONTINUE                 */ 00523000
*           IF LPA<CURRGNTP THEN    /* STORAGE BELOW CURRENT REGION     00524000
*                                      TOP ?                         */ 00525000
         L     R11,PSAAOLD-PSA                                  DSK0343 00526000
         L     R1,ASCBLDA-ASCB(,R11)                            DSK0343 00527000
         L     R12,LPA-1(,R12)                                  DSK0343 00528000
         LA    R12,0(,R12)                                      DSK0343 00529000
         C     R12,CURRGNTP-LDA(,R1)                            DSK0343 00530000
         BNL   @RF00181                                            0181 00531000
*             RETCODE=0;            /* YES: STORAGE RANGE VALID      */ 00532000
         SLR   R15,R15                                          DSK0343 00533000
*           ELSE                                                   0183 00534000
*             RETCODE=4;            /* NO: STORAGE RANGE INVALID     */ 00535000
         B     @RC00181                                            0183 00536000
@RF00181 LA    R15,4                                            DSK0343 00537000
*         END;                                                     0184 00538000
*       ELSE                                                       0185 00539000
*         RETCODE=4;                /* NO: STORAGE RANGE INVALID     */ 00540000
         B     @RC00179                                            0185 00541000
@RF00179 LA    R15,4                                            DSK0343 00542000
*     END;                                                         0186 00543000
*   ELSE                                                           0187 00544000
*     RETCODE=4;                                                   0187 00545000
         B     @RC00177                                            0187 00546000
@RF00177 LA    R15,4                                            DSK0343 00547000
*   RETURN CODE(RETCODE);           /* RETURN TO CALLING ROUTINE     */ 00548000
@RC00179 DS    0H                                               DSK0343 00548010
@RC00181 DS    0H                                               DSK0343 00548020
@RC00177 DS    0H                                                  0188 00549000
@EL00006 DS    0H                                                  0188 00550000
@EF00006 DS    0H                                                  0188 00551000
@ER00006 BR    R14                                              DSK0343 00552000
*   END PAGEVCK;                                                   0189 00553000
*                                                                  0190 00554000
*   /*****************************************************************/ 00555000
*   /*                                                               */ 00556000
*   /* ROUTINE TO CHANGE PROTECT KEY AND FETCH PROTECT FLAG OF A     */ 00557000
*   /* SINGLE PAGE-REFERENCE BIT IS PRESERVED-CHANGE BIT IS TURNED   */ 00558000
*   /* ON- THIS IS DONE TO PREVENT ANOTHER CPU FROM TURING IT ON     */ 00559000
*   /* WHILE THE KEY IS BEING CHANGED AND THUS LOSING THE CHANGE     */ 00560000
*   /*                                                               */ 00561000
*   /*****************************************************************/ 00562000
*                                                                  0190 00563000
*KEYCHG:                                                           0190 00564000
*   PROC OPTIONS(NOSAVE);                                          0190 00565000
KEYCHG   DS    0H                                                  0191 00566000
*   XPTPROT=KEYANDFP;               /* CHANGE KEY IN XPTE            */ 00567000
         L     R12,XPTEPTR                                      DSK0343 00568000
         IC    R11,KEYANDFP                                     DSK0343 00569000
         STC   R11,XPTPROT-XPTE(,R12)                           DSK0343 00570000
*   XPTCKF=YES;                     /* INDICATE KEY FOR PAGE WAS   0192 00571000
*                                      CHANGED                       */ 00572000
         OI    XPTFLAGS-XPTE(R12),XPTCKF                        DSK0343 00573000
*   GEN REFS(PGAD,RCBITS,INR1,CHANGBIT);                           0193 00574000
*                                    /*                                 00575000
*         CHANGE HARDWARE KEY IF PAGE IS ASSIGNED TO A FRAME IN REAL    00576000
*         STORAGE                                                       00577000
         L     R15,PGAD               PAGE VA                   DSK0343 00578000
         LRA   R15,0(R15)             PAGE IN REAL STORAGE ?    DSK0343 00579000
         BNZ   CHGEND                 NO:ROUTINE COMPLETE               00580000
         ISK   R0,R15                YES: HDW KEY FOR PAGE      DSK0343 00581000
         N     R0,RCBITS             SAVE REFERENCE BIT         DSK0343 00582000
         O     R0,CHANGBIT           TURN ON CHANGE BIT         DSK0343 00583000
         O     R0,NEWKEY             APPEND BITS TO NEW KEY     DSK0343 00584000
         SSK   R0,R15                CHANGE HDW KEY OF FIRST 2K DSK0343 00585000
         LA    R15,2048(R15)          ADDRESS OF SECOND 2K      DSK0343 00586000
         ISK   R0,R15                HDW KEY FOR HALF PAGE      DSK0343 00587000
         N     R0,RCBITS             SAVE REFERENCE BIT         DSK0343 00588000
         O     R0,CHANGBIT           TURN ON CHANGE BIT         DSK0343 00589000
         O     R0,NEWKEY             APPEND BITS TO NEW KEY     DSK0343 00590000
         SSK   R0,R15                CHANGE HDW KEY OF SECOND 2 DSK0343 00591000
CHGEND   EQU   *                                                        00592000
*   RETURN CODE(0);                 /* RETURN TO CALLING ROUTINE     */ 00593000
         SLR   R15,R15                                          DSK0343 00594000
@EL00007 DS    0H                                                  0194 00595000
@EF00007 DS    0H                                                  0194 00596000
@ER00007 BR    R14                                              DSK0343 00597000
*   END KEYCHG;                                                    0195 00598000
*                                                                  0196 00599000
*   /*****************************************************************/ 00600000
*   /*                                                               */ 00601000
*   /* ROUTINE TO RESTORE THE ORIGINAL STORAGE KEY FOR ALL PAGES     */ 00602000
*   /* WHOSE KEY HAS BEEN CHANGED. THE ROUTINE IS CALLED INTERNALLY  */ 00603000
*   /* WHEN AN INVALID PAGE HAS BEEN DETECTED IN THE VA RANGE        */ 00604000
*   /* REQUESTED DURING CHANGE KEY PROCESSING. IT IS ALSO A PART OF  */ 00605000
*   /* RETRY PROCESSING REQUESTED BY THE FRR FOR UNEXPECTED ERRORS.  */ 00606000
*   /*                                                               */ 00607000
*   /*****************************************************************/ 00608000
*                                                                  0196 00609000
*RECOVER:                                                          0196 00610000
*   PROC OPTIONS(NOSAVE);                                          0196 00611000
RECOVER  DS    0H                                                  0197 00612000
*   INRCV=YES;                      /* INDICATE ROUTINE ENTERED      */ 00613000
         L     R12,PARMPTR                                      DSK0343 00614000
         OI    INRCV(R12),B'10000000'                           DSK0343 00615000
*   RETAD2=REG14;                   /* SAVE RETURN ADDRESS           */ 00616000
         ST    R14,RETAD2                                       DSK0343 00617000
*   IF LPC^=NONE THEN               /* KEY FOR ANY PAGES CHANGED ?   */ 00618000
         L     R12,LPC                                          DSK0343 00619000
         LTR   R12,R12                                          DSK0343 00620000
         BZ    @RF00199                                            0199 00621000
*     DO;                           /* YES: RESTORE KEY              */ 00622000
*       RCSAVE=REG15;               /* SAVE RC OF CALLING ROUTINE    */ 00623000
         ST    R15,RCSAVE                                       DSK0343 00624000
*       KEYANDFP=OLDKEYFP;          /* ORIGINAL STORAGE KEY          */ 00625000
         IC    R12,OLDKEYFP                                     DSK0343 00626000
         STC   R12,KEYANDFP                                     DSK0343 00627000
*       IF REQUEST=LTYPE THEN       /* DETERMINE REQUEST TYPE        */ 00628000
         CLI   REQUEST,128                                         0203 00629000
         BNE   @RF00203                                            0203 00630000
*         DO;                       /* L-TYPE REQUEST                */ 00631000
*           ELTAD=INR1;             /* FIRST ELEMENT ADDRESS         */ 00632000
         L     R12,INR1                                         DSK0343 00633000
         ST    R12,ELTAD                                        DSK0343 00634000
*           DO UNTIL(LPG=LPC);      /* KEY FOR EACH RANGE CHANGED IS    00635000
*                                      RESTORED                      */ 00636000
@DL00206 DS    0H                                                  0207 00637000
*             IF FPA<=LPC&LPC<=LPA THEN/* LAST RANGE THAT KEY WAS  0207 00638000
*                                      CHANGED ?                     */ 00639000
         L     R12,LPC                                          DSK0343 00640000
         L     R11,ELTAD                                        DSK0343 00641000
         L     R8,FPA-1(,R11)                                   DSK0343 00642000
         LA    R8,0(,R8)                                        DSK0343 00643000
         CR    R12,R8                                           DSK0343 00644000
         BL    @RF00207                                            0207 00645000
         L     R11,LPA-1(,R11)                                  DSK0343 00646000
         LA    R11,0(,R11)                                      DSK0343 00647000
         CR    R12,R11                                          DSK0343 00648000
         BH    @RF00207                                            0207 00649000
*               LPG=LPC;            /* YES: RANGE ENDS WITH LAST PAGE   00650000
*                                      WHOSE KEY WAS CHANGED         */ 00651000
         ST    R12,LPG                                          DSK0343 00652000
*             ELSE                                                 0209 00653000
*               LPG=LPA;            /* NO: KEY FOR ENTIRE RANGE WAS     00654000
*                                      CHANGED                       */ 00655000
         B     @RC00207                                            0209 00656000
@RF00207 L     R12,ELTAD                                        DSK0343 00657000
         L     R12,LPA-1(,R12)                                  DSK0343 00658000
         LA    R12,0(,R12)                                      DSK0343 00659000
         ST    R12,LPG                                          DSK0343 00660000
*             CALL KEYRSTR;         /* RESTORE KEY FOR RANGE         */ 00661000
@RC00207 BAL   R14,KEYRSTR                                      DSK0343 00662000
*             ELTAD=ELTAD+LENGTH(LISTELT);/* NEXT ELEMENT IN LIST    */ 00663000
         LA    R12,8                                            DSK0343 00664000
         AL    R12,ELTAD                                        DSK0343 00665000
         ST    R12,ELTAD                                        DSK0343 00700100
         CLC   LPG,LPC                                          DSK0343 00700200
         BNE   @DL00206                                         DSK0343 00700300
         B     A00041E                                          DSK0343 00700400
@RF00203 DS    0H                                               DSK0343 00700500
A00040A  LA    R12,INR1                                         DSK0343 00700600
         ST    R12,ELTAD                                        DSK0343 00700700
         L     R12,LPC                                          DSK0343 00700800
         ST    R12,LPG                                          DSK0343 00700900
         BAL   R14,A000428                                      DSK0343 00701000
@RF00199 DS    0H                                               DSK0343 00701100
A00041E  L     R14,RETAD2                                       DSK0343 00701200
         L     R15,RCSAVE                                       DSK0343 00701300
         BR    R14                                              DSK0343 00701400
KEYRSTR  DS    0H                                               DSK0343 00701500
A000428  ST    R14,DATD68                                       DSK0343 00701600
         L     R12,ELTAD                                        DSK0343 00701700
         L     R12,0(,R12)                                      DSK0343 00701800
         LA    R12,0(,R12)                                      DSK0343 00701900
         ST    R12,PGAD                                         DSK0343 00702000
A00043C  L     R1,PGAD                                          DSK0343 00702100
         L     R12,PSAAOLD-PSA                                  DSK0343 00702200
         L     R2,ASCBRSM-ASCB(,R12)                            DSK0343 00702300
         L     R12,CVTPTR                                       DSK0343 00702400
         L     R12,CVTPVTP-CVT(,R12)                            DSK0343 00702500
         LR    R3,R12                                           DSK0343 00702600
         L     R15,PVTPFP2-PVT(,R12)  FIND PAGE                 DSK0343 00702700
         BALR  R14,R15                                          DSK0343 00702800
         ST    R1,XPTEPTR                                       DSK0343 00702900
         BAL   R14,KEYCHG                                       DSK0343 00703000
         L     R12,@CF00106                                     DSK0343 00703100
         AL    R12,PGAD                                         DSK0343 00703200
         ST    R12,PGAD                                         DSK0343 00703300
         CLC   PGAD,LPG                                         DSK0343 00703400
         BNH   A00043C                                          DSK0343 00703500
         L     R14,DATD68                                       DSK0343 00703600
         BR    R14                                              DSK0343 00703700
@EP00241 DS    0H                                               DSK0343 00703800
A000480  DS    0H                                               DSK0343 00703900
         SETLOCK OBTAIN,TYPE=SALLOC,MODE=UNCOND,RELATED=RELEASE DSK0343 00704000
         BAL   R14,RECOVER                 PERFORM              DSK0343 00704100
         SETLOCK RELEASE,TYPE=SALLOC,RELATED=OBTAIN             DSK0343 00704200
         SETFRR D,WRKREGS=(R3,R4),RELATED=(FRR,CKEY(FRRON))     DSK0343 00704300
         LA    R15,20                                           DSK0343 00705200
         LA    R1,X'8F'                                         DSK0343 00705300
         N     R1,@CF01514                                      DSK0343 00705400
         SLA   R1,12                                            DSK0343 00705500
         SVC   13                                               DSK0343 00705600
         B     @ER00001                                         DSK0343 00705700
         DC    X'4040'                       !!! SOURCE COMPARE FIX !!! 00705800
         DC    0F'0'                                            DSK0343 00705800
@CF00068 DC    F'8'                                             DSK0343 00706000
@CF00106 DC    F'4096'                                          DSK0343 00706100
@CF01514 DC    X'00000FFF'                                      DSK0343 00706200
         DC    X'07004040'                                      DSK0343 00706300
         DC    X'0000006A'                                      DSK0343 00706400
         DC    V(IEAVCKRR)                                      DSK0343 00706500
         DC    X'0001003C'                                      DSK0343 00706600
CKFRR    DC    V(IEAVCKRR)                                      DSK0343 00706700
RCBITS   DC    X'00000005'                                      DSK0343 00706800
CHANGBIT DC    X'00000002'                                      DSK0343 00706900
R0       EQU   0                       REGISTER 0               DSK0343 00707000
R1       EQU   1                       REGISTER 1               DSK0343 00707100
R2       EQU   2                       REGISTER 2               DSK0343 00707200
R3       EQU   3                       REGISTER 3               DSK0343 00707300
R4       EQU   4                       REGISTER 4               DSK0343 00707400
R5       EQU   5                       REGISTER 5               DSK0343 00707500
R6       EQU   6                       REGISTER 6               DSK0343 00707600
R7       EQU   7                       REGISTER 7               DSK0343 00707700
R8       EQU   8                       REGISTER 8               DSK0343 00707800
R9       EQU   9                       REGISTER 9               DSK0343 00707900
R10      EQU   10                      REGISTER 10              DSK0343 00708000
R11      EQU   11                      REGISTER 11              DSK0343 00708100
R12      EQU   12                      REGISTER 12              DSK0343 00708200
R13      EQU   13                      REGISTER 13              DSK0343 00708300
R14      EQU   14                      REGISTER 14              DSK0343 00708400
R15      EQU   15                      REGISTER 15              DSK0343 00708500
         IHAPSA ,                                               DSK0343 00712000
         IHAASCB ,                                              DSK0343 00712200
         IHALDA ,                                               DSK0343 00712300
         CVT   DSECT=YES,LIST=YES                               DSK0343 00712400
         IHAFRRS ,                                              DSK0343 00712500
         IHAPVT ,                                               DSK0343 00712600
         IHAGDA ,                                               DSK0343 00712700
         IHAPGTE ,                                              DSK0343 00712800
         IHAXPTE ,                                              DSK0343 00712900
         END   ,                                                DSK0343 00713000
