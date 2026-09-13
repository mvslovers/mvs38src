         TITLE ' IEAVEQV1:  PROC   OPTIONS(NOSAVEAREA  REENTRANT CODERE*00001000
               EG(12)   '                                               00002000
IEAVEQV1 CSECT ,                                                01S0001 00003000
@MAINENT DS    0H                                               01S0001 00004000
         USING *,R15                                            DSK1171 00005000
         B     @PROLOG                                          01S0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
IEAVEQV2 DS    0H                                               01S0001 00008000
         USING *,R15                                            DSK1171 00009000
         B     @PROLOG                                          01S0001 00010000
         DC    AL2(@EP00062-IEAVEQV2)                                   00011000
         ENTRY IEAVEQV2                                                 00012000
IEAVEQV3 DS    0H                                               01S0001 00013000
         USING *,R15                                            DSK1171 00014000
         B     @PROLOG                                          01S0001 00015000
         DC    AL2(@EP00065-IEAVEQV3)                                   00016000
         ENTRY IEAVEQV3                                                 00017000
         DROP  R15                                              DSK1171 00018000
@PROLOG  STM   R14,R12,12(R13)                                  DSK1171 00019000
         BALR  R12,0                                            DSK1171 00020000
@PSTART  DS    0H                                               01S0001 00021000
         USING @PSTART,R12                                      DSK1171 00022000
         AH    R15,4(,R15)                                      DSK1171 00023000
         BR    R15                                              DSK1171 00024000
@EP00001 DS    0H                                               01S0002 00025000
         B     BEGIN                                            DSK1171 00025010
         DC    CL26'IEAVEQV1 UZ30998 04/17/80-'                 DSK1171 00025020
BEGIN    DS    0H                                               DSK1171 00025030
*   WRKREG=1;                       /* SINGLE-THREAD Q               */ 00026000
         LA    R3,1                                             DSK1171 00027000
*   GO TO COMMON;                   /* PROCEED TO COMMON PROC        */ 00028000
         B     COMMON                                           01S0061 00029000
*/********************************************************************/ 00030000
*/* THIS ENTRY POINT IS USED FOR TYPE-2 QUEUES. THAT IS,             */ 00031000
*/* SINGLE-THREADED QUEUES WITH A HEADER AND TRAILER.                */ 00032000
*/********************************************************************/ 00033000
*                                                               01S0062 00034000
*IEAVEQV2:                                                      01S0062 00035000
*   ENTRY;                                                      01S0062 00036000
@EP00062 DS    0H                                               01S0063 00037000
*   WRKREG=2;                       /* SINGLE-THREAD W/TRAILER       */ 00038000
         LA    R3,2                                             DSK1171 00039000
*   GO TO COMMON;                                               01S0064 00040000
*                                                               01S0064 00041000
         B     COMMON                                           01S0064 00042000
*   /*****************************************************************/ 00043000
*   /*                                                               */ 00044000
*   /* THIS ENTRY POINT IS USED FOR TYPE-3 QUEUES. THAT IS,          */ 00045000
*   /* DOUBLE-THREADED QUEUES.                                       */ 00046000
*   /*                                                               */ 00047000
*   /*****************************************************************/ 00048000
*                                                               01S0065 00049000
*IEAVEQV3:                                                      01S0065 00050000
*   ENTRY;                                                      01S0065 00051000
@EP00065 DS    0H                                               01S0066 00052000
*   WRKREG=3;                       /* DOUBLE THREAD                 */ 00053000
         LA    R3,3                                             DSK1171 00054000
*   GO TO COMMON;                                               01S0067 00055000
*                                                               01S0067 00056000
         B     COMMON                                           01S0067 00057000
*/********************************************************************/ 00058000
*/* COMMON PROCESSING FOR ALL TYPES OF QUEUES.                       */ 00059000
*/********************************************************************/ 00060000
*                                                               01S0068 00061000
*                                                               02S0068 00062000
*/********************************************************************/ 00063000
*/* COMMON                                                           */ 00064000
*/*  THIS IS THE MAINLINE SEGMENT THAT PERFORMS COMMON PROCESSING    */ 00065000
*/*  FOR ALL TYPES OF QUEUES.                                        */ 00066000
*/*      INPUT-                                                      */ 00067000
*/*       SAME AS ON ENTRY, WITH THE FOLLOWING EXCEPTION             */ 00068000
*/*        WRKREG (R3) = 1, IF THIS IS A TYPE 1 QUEUE                */ 00069000
*/*                    =2 , IF THIS IS A TYPE 2 QUEUE                */ 00070000
*/*                    = 3, IF THIS IS A TYPE 3 QUEUE                */ 00071000
*/********************************************************************/ 00072000
*                                                               02S0068 00073000
*COMMON:                                                        02S0068 00074000
*   ;                                                           02S0068 00075000
*                                                               02S0068 00076000
COMMON   DS    0H                                               02S0069 00077000
*/********************************************************************/ 00078000
*/* VALIDITY CHECK THE PARAMETER LIST.                               */ 00079000
*/********************************************************************/ 00080000
*                                                               02S0069 00081000
*                                                               03S0069 00082000
*/*  VALCHK -                                                        */ 00083000
*/*  THIS SEGMENT VALIDITY CHECKS THE CALLERS INPUT             03S0069 00084000
*    PARAMETERS.    IT INSURES THAT FIELDS DO NOT CONTAIN       03S0069 00085000
*    OBVIOUSLY BAD INFORMATION.  IT ALSO INSURES THAT RESERVED  03S0069 00086000
*    FIELDS ARE ZERO.                                                */ 00087000
*                                                               03S0069 00088000
*   S15=0;                          /* INIT RETURN CODE REG          */ 00089000
         SLR   R10,R10                                          DSK1171 00090000
         ST    R10,S15(,R13)                                    DSK1171 00091000
*   IF QVPLEVR=0                    /* NO EVR SPECIFIED              */ 00092000
*       ×QVPLWKA=0                  /* NO WORK AREA SPECIFIED        */ 00093000
*       ×QVPLHDR=0                  /* NO HEADER SPECIFIED           */ 00094000
*       ×QVPLRES1^='0000000'B       /* RESERVED BITS NOT ZERO        */ 00095000
*       ×'00000000'X^=(QVPLFPTR&ROUND4)/* FWD PTR NOT WORD OFFSET    */ 00096000
*       ×QVPLRES2^='0000000'B       /* RESERVED BITS NOT ZERO        */ 00097000
*       ×(WRKREG>1                  /* QUEUE HAS TRAILER             */ 00098000
*       &(QVPLTRLR=0×QVPLRES3^='0000000'B))/* TRAILER NOT SPEC OR       00099000
*                                      RESV                          */ 00100000
*       ×                           /* BITS NOT SET                  */ 00101000
*       (WRKREG=3                   /* DOUBLE THREAD                 */ 00102000
*       &(QVPLRES4^='0000000'B      /* RSVD NOT SET                  */ 00103000
*       ×'00000000'X^=(QVPLBPTR&ROUND4))/* BACK PTR NOT WORD OFFSET  */ 00104000
*       ) THEN                                                  03S0070 00105000
         L     R8,QVPLPTR(,R13)                                 DSK1171 00106000
         C     R10,QVPLEVR-QVPL(,R8)                            DSK1171 00107000
         BE    @RT00070                                         03S0070 00108000
         C     R10,QVPLWKA-QVPL(,R8)                            DSK1171 00109000
         BE    @RT00070                                         03S0070 00110000
         C     R10,QVPLHDR-QVPL(,R8)                            DSK1171 00111000
         BE    @RT00070                                         03S0070 00112000
         TM    QVPLFLGH-QVPL(R8),QVPLRES1                       DSK1171 00113000
         BNZ   @RT00070                                         03S0070 00114000
         LH    R0,QVPLFPTR-QVPL(,R8)                            DSK1171 00115000
         N     R0,@CF00152                                      DSK1171 00116000
         LTR   R0,R0                                            DSK1171 00117000
         BNZ   @RT00070                                         03S0070 00118000
         TM    QVPLFLGF-QVPL(R8),QVPLRES2                       DSK1171 00119000
         BNZ   @RT00070                                         03S0070 00120000
         C     R3,@CF00081                                      DSK1171 00121000
         BNH   @GL00001                                         03S0070 00122000
         C     R10,QVPLTRLR-QVPL(,R8)                           DSK1171 00123000
         BE    @RT00070                                         03S0070 00124000
         TM    QVPLFLGT-QVPL(R8),QVPLRES3                       DSK1171 00125000
         BNZ   @RT00070                                         03S0070 00126000
@GL00001 C     R3,@CF00160                                      DSK1171 00127000
         BNE   @RF00070                                         03S0070 00128000
         L     R10,QVPLPTR(,R13)                                DSK1171 00129000
         TM    QVPLFLGB-QVPL(R10),QVPLRES4                      DSK1171 00130000
         BNZ   @RT00070                                         03S0070 00131000
         LH    R10,QVPLBPTR-QVPL(,R10)                          DSK1171 00132000
         N     R10,@CF00152                                     DSK1171 00133000
         LTR   R10,R10                                          DSK1171 00134000
         BZ    @RF00070                                         03S0070 00135000
@RT00070 DS    0H                                               03S0071 00136000
*     S15=24;                       /* INDICATE ERROR                */ 00137000
*                                                               03S0071 00138000
         MVC   S15(4,R13),@CF00087                              03S0071 00139000
*   /*****************************************************************/ 00140000
*   /*                                                               */ 00141000
*   /* THE PARAMTERS SEEM TO BE VALID.                               */ 00142000
*   /*                                                               */ 00143000
*   /*****************************************************************/ 00144000
*                                                               03S0072 00145000
*   ELSE                                                        03S0072 00146000
*     DO;                                                       03S0072 00147000
*                                                               03S0072 00148000
         B     @RC00070                                         03S0072 00149000
@RF00070 DS    0H                                               03S0073 00150000
*       /*************************************************************/ 00151000
*       /*                                                           */ 00152000
*       /* THE PARAMETERS ARE REFERENCED TO INSURE THAT IF THEY ARE  */ 00153000
*       /* INVALID, ANY PROGRAM CHECKS WILL OCCUR BEFORE QUEUE       */ 00154000
*       /* VERIFIER BEGINS ITS PROCESSING.                           */ 00155000
*       /*                                                           */ 00156000
*       /*************************************************************/ 00157000
*                                                               03S0073 00158000
*       R15=QVPL(1);                /* REFERENCE FIRST BYTE          */ 00159000
         L     R10,QVPLPTR(,R13)                                DSK1171 00160000
         SLR   R15,R15                                          03S0073 00161000
         IC    R15,QVPL-QVPL(,R10)                              DSK1171 00162000
*       IF WRKREG=1                 /* IF TYPE 1 QUEUE               */ 00163000
*         THEN                      /* REFERENCE PARM LIST           */ 00164000
         C     R3,@CF00081                                      DSK1171 00165000
         BNE   @RF00074                                         03S0074 00166000
*         R15=QVPLTYP1(LENGTH(QVPLTYP1));/* REFERENCE LAST BYTE      */ 00167000
         SLR   R15,R15                                          03S0075 00168000
         IC    R15,QVPLTYP1+27-QVPL(,R10)                       DSK1171 00169000
*       ELSE                                                    03S0076 00170000
*         IF WRKREG=2               /* IF TYPE 2                     */ 00171000
*           THEN                                                03S0076 00172000
         B     @RC00074                                         03S0076 00173000
@RF00074 C     R3,@CF00111                                      DSK1171 00174000
         BNE   @RF00076                                         03S0076 00175000
*           R15=QVPL(LENGTH(QVPLTYP2));/* REFERNCE LAST BYTE         */ 00176000
         L     R10,QVPLPTR(,R13)                                DSK1171 00177000
         SLR   R15,R15                                          03S0077 00178000
         IC    R15,QVPL+32-QVPL(,R10)                           DSK1171 00179000
*         ELSE                                                  03S0078 00180000
*           R15=QVPL(LENGTH(QVPLTYP3));/* REFERENCE LAST BYTE        */ 00181000
*                                                               03S0078 00182000
         B     @RC00076                                         03S0078 00183000
@RF00076 L     R10,QVPLPTR(,R13)                                DSK1171 00184000
         SLR   R15,R15                                          03S0078 00185000
         IC    R15,QVPL+39-QVPL(,R10)                           DSK1171 00186000
*       /*************************************************************/ 00187000
*       /*                                                           */ 00188000
*       /* REFERENCE OUTPUT DATA AREA                                */ 00189000
*       /*                                                           */ 00190000
*       /*************************************************************/ 00191000
*                                                               03S0079 00192000
*       IF QVPLODA^=0 THEN                                      03S0079 00193000
@RC00076 DS    0H                                               03S0079 00194000
@RC00074 L     R10,QVPLPTR(,R13)                                DSK1171 00195000
         L     R10,QVPLODA-QVPL(,R10)                           DSK1171 00196000
         LTR   R10,R10                                          DSK1171 00197000
         BZ    @RF00079                                         03S0079 00198000
*         DO;                                                   03S0080 00199000
*           R15PTR8=ODA(1);         /* REFERENCE FIRST BYTE          */ 00200000
         SLR   R15,R15                                          DSK1171 00201000
         IC    R15,ODA(,R10)                                    DSK1171 00202000
*           R15PTR8=ODA(4+QVODSIZE);/* REFERENCE LAST BYTE           */ 00203000
         SLR   R8,R8                                            DSK1171 00204000
         IC    R8,QVODSIZE-QVODHDR(,R10)                        DSK1171 00205000
         SLR   R15,R15                                          DSK1171 00206000
         IC    R15,ODA+3(R8,R10)                                DSK1171 00207000
*         END;                                                  03S0083 00208000
*     END;                                                      03S0084 00209000
@RF00079 DS    0H                                               03S0085 00210000
*   IF S15^=24                      /* IF VALID                      */ 00211000
*     THEN                                                      02S0085 00212000
@RC00070 CLC   S15(4,R13),@CF00087                              02S0085 00213000
         BE    @PB00002                                         DSK1171 00214000
*     DO;                                                       02S0086 00215000
*                                                               02S0086 00216000
*       /*************************************************************/ 00217000
*       /*                                                           */ 00218000
*       /* PERFORM INITIALIZATION                                    */ 00219000
*       /*                                                           */ 00220000
*       /*************************************************************/ 00221000
*                                                               02S0087 00222000
*                                                               03S0087 00223000
*/********************************************************************/ 00224000
*/*  INIT - THIS SEGMENT PERFORMS BASIC INITIALIZATION               */ 00225000
*/*      IT FIRST CLEARS THE WORK AREA, AND THEN FILLS               */ 00226000
*/*      IN INDICATORS, DEPENDING ON THE TYPE OF QUEUE AND           */ 00227000
*/*      ON THE VALUES IN THE QUEUE HEADER AND TRAILER.              */ 00228000
*/*      INPUT:                                                      */ 00229000
*/*        WRKREG (R3)                                               */ 00230000
*/*          =1, FOR A TYPE 1 QUEUE                                  */ 00231000
*/*          =2, FOR A TYPE 2 QUEUE                                  */ 00232000
*/*          =3, FOR A TYPE 3 QUEUE                                  */ 00233000
*/*        R13 = ADDRESS OF 72 BYTE REGISTER SAVE AREA.              */ 00234000
*/********************************************************************/ 00235000
*                                                               03S0087 00236000
*       WAPTR=QVPLWKA;              /* GET ADDR OF WORK AREA         */ 00237000
         L     R10,QVPLPTR(,R13)                                DSK1171 00238000
         L     R2,QVPLWKA-QVPL(,R10)                            DSK1171 00239000
*       WKA='0'B;                   /* ZERO ENTIRE WORK AREA         */ 00240000
         XC    WKA+1(35,R2),WKA+1(R2)                           DSK1171 00241000
         MVI   WKA(R2),B'00000000'                              DSK1171 00242000
*       QTYPE=WRKREG;               /* INDICATE TYPE OF QUEUE        */ 00243000
         STC   R3,QTYPE(,R2)                                    DSK1171 00244000
*       RESPECIFY                                               03S0090 00245000
*         WRKREG UNRSTD;                                        03S0090 00246000
*                                                               03S0090 00247000
*       /*************************************************************/ 00248000
*       /*                                                           */ 00249000
*       /* SET HN TO 1 IF THE HEADER INDICATES NO ELEMENTS           */ 00250000
*       /*                                                           */ 00251000
*       /*************************************************************/ 00252000
*                                                               03S0091 00253000
*       IF((QVPLHDR->PTR31)=QVPLNOEL×(QVPLHD3=YES&QVPLHDR->PTR24=NOELM3 00254000
*           ))                      /* IF NO ELEMENTS                */ 00255000
*         THEN                                                  03S0091 00256000
         L     R8,QVPLHDR-QVPL(,R10)                            DSK1171 00257000
         CLC   PTR31(4,R8),QVPLNOEL-QVPL(R10)                   DSK1171 00258000
         BE    @RT00091                                         03S0091 00259000
         TM    QVPLFLGH-QVPL(R10),QVPLHD3                       DSK1171 00260000
         BNO   @RF00091                                         03S0091 00261000
         CLC   PTR24(3,R8),QVPLNOEL+1-QVPL(R10)                 DSK1171 00262000
         BNE   @RF00091                                         03S0091 00263000
@RT00091 DS    0H                                               03S0092 00264000
*         HN=YES;                   /* SET SWITCH                    */ 00265000
         OI    HN(R2),B'01000000'                               DSK1171 00266000
*       ELSE                                                    03S0093 00267000
*                                                               03S0093 00268000
*         /***********************************************************/ 00269000
*         /*                                                         */ 00270000
*         /* SET HQ TO 1 IF THE HEADER CONTAINS THE ADDRESS OF A     */ 00271000
*         /* QUEUE ELEMENT.                                          */ 00272000
*         /*                                                         */ 00273000
*         /***********************************************************/ 00274000
*                                                               03S0093 00275000
*         DO;                                                   03S0093 00276000
*                                                               03S0093 00277000
         B     @RC00091                                         03S0093 00278000
@RF00091 DS    0H                                               03S0094 00279000
*           /*********************************************************/ 00280000
*           /*                                                       */ 00281000
*           /* VERIFY CONTENTS OF HEADER                             */ 00282000
*           /*                                                       */ 00283000
*           /*********************************************************/ 00284000
*                                                               03S0094 00285000
*           RESPECIFY                                           03S0094 00286000
*             R0 RSTD;                                          03S0094 00287000
*           R0=QVPLHDR->PTR31;                                  03S0095 00288000
         L     R10,QVPLPTR(,R13)                                DSK1171 00289000
         L     R8,QVPLHDR-QVPL(,R10)                            DSK1171 00290000
         L     R0,PTR31(,R8)                                    DSK1171 00291000
*           R1=S0;                                              03S0096 00292000
         L     R1,S0(,R13)                                      03S0096 00293000
*           CALL EVR;                                           03S0097 00294000
         L     R15,QVPLEVR-QVPL(,R10)                           DSK1171 00295000
         BALR  R14,R15                                          DSK1171 00296000
*           RESPECIFY                                           03S0098 00297000
*             R15 RSTD;                                         03S0098 00298000
*           RESPECIFY                                           03S0099 00299000
*             R0 UNRSTD;                                        03S0099 00300000
*           R1=S1;                                              03S0100 00301000
         L     R1,S1(,R13)                                      03S0100 00302000
*           WAPTR=QVPLWKA;          /* RESTORE R2                    */ 00303000
         L     R14,QVPLPTR(,R13)                                DSK1171 00304000
         L     R2,QVPLWKA-QVPL(,R14)                            DSK1171 00305000
*           IF R15^=8               /* IF VALID                      */ 00306000
*             THEN                                              03S0102 00307000
         C     R15,@CF00058                                     03S0102 00308000
         BE    @RF00102                                         03S0102 00309000
*             HQ=YES;               /* TURN ON SWITCH                */ 00310000
         OI    HQ(R2),B'10000000'                               DSK1171 00311000
*           RESPECIFY                                           03S0104 00312000
*             R15 UNRSTD;                                       03S0104 00313000
@RF00102 DS    0H                                               03S0105 00314000
*         END;                                                  03S0105 00315000
*       IF QTYPE>1                  /* IF QUEUE HAS TRAILER          */ 00316000
*         THEN                                                  03S0106 00317000
@RC00091 CLI   QTYPE(R2),1                                      DSK1171 00318000
         BNH   @RF00106                                         03S0106 00319000
*         DO;                                                   03S0107 00320000
*                                                               03S0107 00321000
*           /*********************************************************/ 00322000
*           /*                                                       */ 00323000
*           /* SET TN TO 1 IF THE QUEUE TRAILER INDICATES NO ELEMENTS*/ 00324000
*           /*                                                       */ 00325000
*           /*********************************************************/ 00326000
*                                                               03S0108 00327000
*           IF((QVPLTRLR->PTR31)=QVPLNOEL×(QVPLTR3=YES&QVPLTRLR->PTR24= 00328000
*               NOELM3))            /* IF NO ELEMENTS                */ 00329000
*             THEN                                              03S0108 00330000
         L     R10,QVPLPTR(,R13)                                DSK1171 00331000
         L     R8,QVPLTRLR-QVPL(,R10)                           DSK1171 00332000
         CLC   PTR31(4,R8),QVPLNOEL-QVPL(R10)                   DSK1171 00333000
         BE    @RT00108                                         03S0108 00334000
         TM    QVPLFLGT-QVPL(R10),QVPLTR3                       DSK1171 00335000
         BNO   @RF00108                                         03S0108 00336000
         CLC   PTR24(3,R8),QVPLNOEL+1-QVPL(R10)                 DSK1171 00337000
         BNE   @RF00108                                         03S0108 00338000
@RT00108 DS    0H                                               03S0109 00339000
*             TN=YES;               /* SET SWITCH                    */ 00340000
         OI    TN(R2),B'01000000'                               DSK1171 00341000
*           ELSE                                                03S0110 00342000
*                                                               03S0110 00343000
*             /*******************************************************/ 00344000
*             /*                                                     */ 00345000
*             /* SET TQ TO 1 IF THE TRAILER POINTS TO A QUEUE        */ 00346000
*             /* ELEMENT.                                            */ 00347000
*             /*                                                     */ 00348000
*             /*******************************************************/ 00349000
*                                                               03S0110 00350000
*             DO;                                               03S0110 00351000
*                                                               03S0110 00352000
         B     @RC00108                                         03S0110 00353000
@RF00108 DS    0H                                               03S0111 00354000
*               /*****************************************************/ 00355000
*               /*                                                   */ 00356000
*               /* VERIFY CONTENTS OF TRAILER                        */ 00357000
*               /*                                                   */ 00358000
*               /*****************************************************/ 00359000
*                                                               03S0111 00360000
*               RESPECIFY                                       03S0111 00361000
*                 R0 RSTD;                                      03S0111 00362000
*               R0=QVPLTRLR->PTR31; /* ADDR FOR VERIFICATION         */ 00363000
         L     R10,QVPLPTR(,R13)                                DSK1171 00364000
         L     R8,QVPLTRLR-QVPL(,R10)                           DSK1171 00365000
         L     R0,PTR31(,R8)                                    DSK1171 00366000
*               R1=S0;              /* SET UP PARM REGISTER          */ 00367000
         L     R1,S0(,R13)                                      03S0113 00368000
*               CALL EVR;           /* VERIFY ADDRESS                */ 00369000
         L     R15,QVPLEVR-QVPL(,R10)                           DSK1171 00370000
         BALR  R14,R15                                          DSK1171 00371000
*               RESPECIFY                                       03S0115 00372000
*                 R0 UNRSTD;                                    03S0115 00373000
*               RESPECIFY                                       03S0116 00374000
*                 R15 RSTD;                                     03S0116 00375000
*               R1=S1;              /* RESTORE PARM LIST ADDR        */ 00376000
         L     R1,S1(,R13)                                      03S0117 00377000
*               WAPTR=QVPLWKA;      /* RESTORE R2                    */ 00378000
         L     R14,QVPLPTR(,R13)                                DSK1171 00379000
         L     R2,QVPLWKA-QVPL(,R14)                            DSK1171 00380000
*               IF R15^=8           /* IF VALID                      */ 00381000
*                 THEN                                          03S0119 00382000
         C     R15,@CF00058                                     03S0119 00383000
         BE    @RF00119                                         03S0119 00384000
*                 TQ=YES;           /* SET SWITCH                    */ 00385000
         OI    TQ(R2),B'10000000'                               DSK1171 00386000
*               RESPECIFY                                       03S0121 00387000
*                 R15 UNRSTD;                                   03S0121 00388000
@RF00119 DS    0H                                               03S0122 00389000
*             END;                                              03S0122 00390000
*         END;                                                  03S0123 00391000
*                                                               03S0123 00392000
@RC00108 DS    0H                                               03S0124 00393000
*/********************************************************************/ 00394000
*/* END OF INIT                                                      */ 00395000
*/*      OUTPUT:                                                     */ 00396000
*/*       THE OUTPUT FROM THIS SEGMENT DEFINES THE STANDARD          */ 00397000
*/*       INPUTS TO ALL OTHER SEGMENTS.                              */ 00398000
*/*         WAPTR (R2) - CONTAINS THE ADDRESS OF THE WORK AREA.      */ 00399000
*/*         QTYPE = CONTAINS INDICATOR OF THE TYPE OF QUEUE.         */ 00400000
*/*               = 1, FOR A SINGLE-THREADED QUEUE WITH HEADER ONLY  */ 00401000
*/*               =2, FOR A SINGLE-THREADED QUEUE WITH HEADER AND    */ 00402000
*/*                 TRAILER.                                         */ 00403000
*/*               =3, FOR A DOUBLE-THREADED QUEUE.                   */ 00404000
*/*                                                                  */ 00405000
*/*        HQ=0, IF THE HEADER DOES NOT POINT TO AN ELEMENT.         */ 00406000
*/*          =1, IF THE HEADER POINTS TO A QUEUE ELEMENT.            */ 00407000
*/*                                                                  */ 00408000
*/*        HN =0, IF THE HEADER DOES NOT INDICATE NO ELEMENTS.       */ 00409000
*/*           =1, IF THE HEADER INDICATES THERE ARE NO ELEMENTS.     */ 00410000
*/*                                                                  */ 00411000
*/*        TN = 1, IF THE TRAILER INDICATES THERE ARE NO ELEMENTS.   */ 00412000
*/*           =0, IF IT DOES NOT INDICATE NO ELEMENTS.               */ 00413000
*/*                                                                  */ 00414000
*/*        TQ = 1, IF THE TRAILER POINTS TO A QUEUE ELEMENT.         */ 00415000
*/*           = 0, IF THE TRAILER DOES NOT POINT TO A QUEUE ELEMENT. */ 00416000
*/*                                                                  */ 00417000
*/*        R13 = CONTAINS THE ADDRESS OF THE 72-BYTE REGISTER SAVE   */ 00418000
*/*          AREA, WHICH CONTAINS THE REGISTERS ON ENTRY.            */ 00419000
*/*                                                                  */ 00420000
*/*      OTHER OUTPUT:                                               */ 00421000
*/*        R3-R7 = VOLATILE                                          */ 00422000
*/*        R0,R14,R15 = VOLATILE                                     */ 00423000
*/****************************************************************** */ 00424000
*                                                               03S0124 00425000
*       IF HN=YES                   /* IF HEADER SHOWS NO ELEMENTS   */ 00426000
*           &(QTYPE=1×TN=YES)       /* TRAILER SHOWS NO ELEMENTS OR     00427000
*                                      THERE IS NO TRAILER           */ 00428000
*         THEN                                                  02S0124 00429000
*                                                               02S0124 00430000
@RF00106 TM    HN(R2),B'01000000'                               DSK1171 00431000
         BNO   @RF00124                                         02S0124 00432000
         CLI   QTYPE(R2),1                                      DSK1171 00433000
         BE    @RT00124                                         02S0124 00434000
         TM    TN(R2),B'01000000'                               DSK1171 00435000
         BNO   @RF00124                                         02S0124 00436000
@RT00124 DS    0H                                               02S0125 00437000
*         /***********************************************************/ 00438000
*         /*                                                         */ 00439000
*         /* THE QUEUE IS EMPTY--NO ERRORS                           */ 00440000
*         /*                                                         */ 00441000
*         /***********************************************************/ 00442000
*                                                               02S0125 00443000
*         S15=0;                    /* INDICATE NO ERRORS            */ 00444000
         SLR   R10,R10                                          DSK1171 00445000
         ST    R10,S15(,R13)                                    DSK1171 00446000
*       ELSE                                                    02S0126 00447000
*                                                               02S0126 00448000
*         /***********************************************************/ 00449000
*         /*                                                         */ 00450000
*         /* THE QUEUE IS NOT EMPTY                                  */ 00451000
*         /*                                                         */ 00452000
*         /***********************************************************/ 00453000
*                                                               02S0126 00454000
*         DO;                                                   02S0126 00455000
         B     @RC00124                                         02S0126 00456000
@RF00124 DS    0H                                               02S0127 00457000
*           IF QTYPE>=2             /* QUEUE HAS TRAILER             */ 00458000
*             THEN                                              02S0127 00459000
         CLI   QTYPE(R2),2                                      DSK1171 00460000
         BL    @RF00127                                         02S0127 00461000
*             DO;                                               02S0128 00462000
*                                                               02S0128 00463000
*               /*****************************************************/ 00464000
*               /*                                                   */ 00465000
*               /* VALIDATE FORWARD CHAIN IN LAST ELEMENT            */ 00466000
*               /*                                                   */ 00467000
*               /*****************************************************/ 00468000
*                                                               02S0129 00469000
*                                                               03S0129 00470000
*/********************************************************************/ 00471000
*/*  FIXLAST -   THIS SEGMENT  VALIDATES AND CORRECTS THE FORWARD    */ 00472000
*/*  CHAIN FIELD OF THE QUEUE ELEMENT POINTED TO BY THE Q  TRAILER.  */ 00473000
*/*  IT WILL INSURE THAT THE  FORWARD CHAIN FIELD CONTAINS THE       */ 00474000
*/*  LAST-ELEMENT INDICATOR (QVPLLELM)                               */ 00475000
*/*      INPUT:                                                      */ 00476000
*/*        STANDARD INPUT (SEE SEGMENT INIT)                         */ 00477000
*/********************************************************************/ 00478000
*                                                               03S0129 00479000
*               IF TQ=YES           /* TRAILER GOOD                  */ 00480000
*                 THEN                                          03S0129 00481000
         TM    TQ(R2),B'10000000'                               DSK1171 00482000
         BNO   @RF00129                                         03S0129 00483000
*                 DO;                                           03S0130 00484000
*                   RESPECIFY                                   03S0131 00485000
*                     WRKREG RSTD;                              03S0131 00486000
*                   WRKREG=(QVPLTRLR->PTR24)+QVPLFPTR;/* GET ADDRESS    00487000
*                                      OF FORWARD CHAIN FIELD        */ 00488000
         L     R10,QVPLPTR(,R13)                                DSK1171 00489000
         L     R8,QVPLTRLR-QVPL(,R10)                           DSK1171 00490000
         L     R3,PTR24-1(,R8)                                  DSK1171 00491000
         LA    R3,0(,R3)                                        DSK1171 00492000
         AH    R3,QVPLFPTR-QVPL(,R10)                           DSK1171 00493000
*                   IF WRKREG->PTR24^=LASTELM3/* IF NOT THE LAST        00494000
*                                      INDICATOR                     */ 00495000
*                       ×(QVPLFP3=NO&WRKREG->PTR31^=QVPLLELM) THEN      00496000
*                                                               03S0133 00497000
         CLC   PTR24(3,R3),QVPLLELM+1-QVPL(R10)                 DSK1171 00498000
         BNE   @RT00133                                         03S0133 00499000
         TM    QVPLFLGF-QVPL(R10),QVPLFP3                       DSK1171 00500000
         BNZ   @RF00133                                         03S0133 00501000
         CLC   PTR31(4,R3),QVPLLELM-QVPL(R10)                   DSK1171 00502000
         BE    @RF00133                                         03S0133 00503000
@RT00133 DS    0H                                               03S0134 00504000
*                     /***********************************************/ 00505000
*                     /*                                             */ 00506000
*                     /* ERROR CONDITION - RECORD ERROR AND CORRECT  */ 00507000
*                     /* BY STORING QVPLLELM INTO THE FORWARD CHAIN. */ 00508000
*                     /*                                             */ 00509000
*                     /***********************************************/ 00510000
*                                                               03S0134 00511000
*                     DO;                                       03S0134 00512000
*                       RESPECIFY                               03S0135 00513000
*                         WRKREG UNRSTD;                        03S0135 00514000
*                       ERRPARM=BADLAST;/* INDIC ERROR               */ 00515000
         MVI   ERRPARM(R2),X'0A'                                DSK1171 00516000
*                       ERRELM=QVPLTRLR->PTR31;/* ADDR OF BAD ELEMENT*/ 00517000
         L     R10,QVPLPTR(,R13)                                DSK1171 00518000
         L     R8,QVPLTRLR-QVPL(,R10)                           DSK1171 00519000
         MVC   ERRELM(3,R2),PTR31+1(R8)                         DSK1171 00520000
*                       CORRECT=QVPLLELM;/* INDIC CORRECT VALUE      */ 00521000
         L     R10,QVPLLELM-QVPL(,R10)                          DSK1171 00522000
         ST    R10,CORRECT(,R2)                                 DSK1171 00523000
*                       CALL RECORD;/* RECORD AND CORRECT            */ 00524000
         BAL   R14,RECORD                                       DSK1171 00525000
*                     END;                                      03S0140 00526000
*                 END;                                          03S0141 00527000
*                                                               03S0141 00528000
@RF00133 DS    0H                                               03S0142 00529000
*/********************************************************************/ 00530000
*/* END OF FIXLAST                                                   */ 00531000
*/*      OUTPUT:                                                     */ 00532000
*/*        WRKREG (R3) - VOLATILE                                    */ 00533000
*/********************************************************************/ 00534000
*                                                               03S0142 00535000
*               IF QTYPE=3          /* IF DBL-THREAD                 */ 00536000
*                 THEN                                          02S0142 00537000
@RF00129 CLI   QTYPE(R2),3                                      DSK1171 00538000
         BNE   @RF00142                                         02S0142 00539000
*                 DO;                                           02S0143 00540000
*                                                               02S0143 00541000
*                   /*************************************************/ 00542000
*                   /*                                               */ 00543000
*                   /* CHECK OUT BACK CHAIN OF FIRST ELEMENT         */ 00544000
*                   /*                                               */ 00545000
*                   /*************************************************/ 00546000
*                                                               02S0144 00547000
*                                                               03S0144 00548000
*/********************************************************************/ 00549000
*/*   FIXFIRST -                                                     */ 00550000
*/*  THIS SEGMENT INSURES THAT THE BACKWARD CHAIN FIELD OF THE       */ 00551000
*/*  POINTED TO BY THE QUEUE HEADER CONTAINS THE FIRST-ELEMENT       */ 00552000
*/*  INDICATOR (QVPLFELM) .  IF IT DOES NOT, THE ERROR WILL BE       */ 00553000
*/*  RECORDED AND THE CHAIN FIELD WILL BE CORRECTED.                 */ 00554000
*/*      INPUT:                                                      */ 00555000
*/*        STANDARD INPUT  (SEE SEGMENT INIT)                        */ 00556000
*/********************************************************************/ 00557000
*                                                               03S0144 00558000
*                   IF HQ=YES       /* HEADER GOOD                   */ 00559000
*                     THEN                                      03S0144 00560000
         TM    HQ(R2),B'10000000'                               DSK1171 00561000
         BNO   @RF00144                                         03S0144 00562000
*                     DO;                                       03S0145 00563000
*                       RESPECIFY                               03S0146 00564000
*                         WRKREG RSTD;                          03S0146 00565000
*                       WRKREG=(QVPLHDR->PTR24)+QVPLBPTR;/* GET 03S0147 00566000
*                                      ADDRESS OF BACK CHAIN PTR OF     00567000
*                                      FIRST ELEMENT                 */ 00568000
         L     R10,QVPLPTR(,R13)                                DSK1171 00569000
         L     R8,QVPLHDR-QVPL(,R10)                            DSK1171 00570000
         L     R3,PTR24-1(,R8)                                  DSK1171 00571000
         LA    R3,0(,R3)                                        DSK1171 00572000
         AH    R3,QVPLBPTR-QVPL(,R10)                           DSK1171 00573000
*                       IF WRKREG->PTR24^=FRSTELM3/* IF NOT THE FIRST   00574000
*                                      ELEMENT INDICATOR             */ 00575000
*                           ×(QVPLBP3=NO&WRKREG->PTR31^=QVPLFELM) THEN  00576000
*                                                               03S0148 00577000
         CLC   PTR24(3,R3),QVPLFELM+1-QVPL(R10)                 DSK1171 00578000
         BNE   @RT00148                                         03S0148 00579000
         TM    QVPLFLGB-QVPL(R10),QVPLBP3                       DSK1171 00580000
         BNZ   @RF00148                                         03S0148 00581000
         CLC   PTR31(4,R3),QVPLFELM-QVPL(R10)                   DSK1171 00582000
         BE    @RF00148                                         03S0148 00583000
@RT00148 DS    0H                                               03S0149 00584000
*                         /*******************************************/ 00585000
*                         /*                                         */ 00586000
*                         /* ERROR CONDITION - RECORD AND CORRECT THE*/ 00587000
*                         /* BACKWARD CHAIN FIELD OF THE FIRST       */ 00588000
*                         /* ELEMENT.                                */ 00589000
*                         /*                                         */ 00590000
*                         /*******************************************/ 00591000
*                                                               03S0149 00592000
*                         DO;                                   03S0149 00593000
*                           RESPECIFY                           03S0150 00594000
*                             WRKREG UNRSTD;                    03S0150 00595000
*                           ERRPARM=BADFRST;/* INDIC ERROR           */ 00596000
         MVI   ERRPARM(R2),X'0B'                                DSK1171 00597000
*                           ERRELM=QVPLHDR->PTR31;/* ADDR OF BAD        00598000
*                                      ELEMENT                       */ 00599000
         L     R10,QVPLPTR(,R13)                                DSK1171 00600000
         L     R8,QVPLHDR-QVPL(,R10)                            DSK1171 00601000
         MVC   ERRELM(3,R2),PTR31+1(R8)                         DSK1171 00602000
*                           CORRECT=QVPLFELM;/* INDIC CORRECT VALUE  */ 00603000
         L     R10,QVPLFELM-QVPL(,R10)                          DSK1171 00604000
         ST    R10,CORRECT(,R2)                                 DSK1171 00605000
*                           CALL RECORD;/* RECORD AND CORRECT        */ 00606000
         BAL   R14,RECORD                                       DSK1171 00607000
*                         END;                                  03S0155 00608000
*                     END;                                      03S0156 00609000
*                                                               03S0156 00610000
@RF00148 DS    0H                                               03S0157 00611000
*/********************************************************************/ 00612000
*/*  END OF FIXFIRST                                                 */ 00613000
*/*      OUTPUT:                                                     */ 00614000
*/*       WRKREG (R3) - VOLATILE                                     */ 00615000
*/********************************************************************/ 00616000
*                                                               03S0157 00617000
*                 END;                                          02S0157 00618000
@RF00144 DS    0H                                               02S0158 00619000
*             END;                                              02S0158 00620000
*                                                               02S0158 00621000
@RF00142 DS    0H                                               02S0159 00622000
*           /*********************************************************/ 00623000
*           /*                                                       */ 00624000
*           /* INDICATE FORWARD SCAN                                 */ 00625000
*           /*                                                       */ 00626000
*           /*********************************************************/ 00627000
*                                                               02S0159 00628000
*           DIR=FORWARD;                                        02S0159 00629000
@RF00127 MVI   DIR(R2),X'01'                                    DSK1171 00630000
*           NDIR=BACKWARD;                                      02S0160 00631000
*                                                               02S0160 00632000
         MVI   NDIR(R2),X'02'                                   DSK1171 00633000
*           /*********************************************************/ 00634000
*           /*                                                       */ 00635000
*           /* DO A FORWARD SCAN                                     */ 00636000
*           /*                                                       */ 00637000
*           /*********************************************************/ 00638000
*                                                               02S0161 00639000
*           CALL SCAN;                                          02S0161 00640000
*                                                               02S0161 00641000
         BAL   R14,SCAN                                         DSK1171 00642000
*           /*********************************************************/ 00643000
*           /*                                                       */ 00644000
*           /* THE QUEUE HAS NOW BEEN SCANNED GOING FORWARD. IF AN   */ 00645000
*           /* ERROR HAS BEEN FOUND ON THE SCAN, ERRVAL1 WILL BE     */ 00646000
*           /* NON-ZERO.                                             */ 00647000
*           /*                                                       */ 00648000
*           /*********************************************************/ 00649000
*                                                               02S0162 00650000
*           IF QTYPE^=1             /* QUEUE HAS TRAILER             */ 00651000
*               &ERRVAL1=0          /* NO ERRORS FOUND ON SCAN       */ 00652000
*               &TQ=YES             /* TRAILER POINTS TO ELEMENT     */ 00653000
*               &LASTFWD^=QVPLTRLR->PTR24/* TRAILER DOES NOT POINT TO   00654000
*                                      THE LAST FOUND                */ 00655000
*             THEN                                              02S0162 00656000
*                                                               02S0162 00657000
         CLI   QTYPE(R2),1                                      DSK1171 00658000
         BE    @RF00162                                         02S0162 00659000
         CLI   ERRVAL1(R2),0                                    DSK1171 00660000
         BNE   @RF00162                                         02S0162 00661000
         TM    TQ(R2),B'10000000'                               DSK1171 00662000
         BNO   @RF00162                                         02S0162 00663000
         L     R10,QVPLPTR(,R13)                                DSK1171 00664000
         L     R10,QVPLTRLR-QVPL(,R10)                          DSK1171 00665000
         CLC   LASTFWD(3,R2),PTR24(R10)                         DSK1171 00666000
         BE    @RF00162                                         02S0162 00667000
*             /*******************************************************/ 00668000
*             /*                                                     */ 00669000
*             /* ALTHOUGH THE FORWARD SCAN SHOWED NO ERRORS, THE LAST*/ 00670000
*             /* ELEMENT ON THE SCAN WAS NOT THE ONE POINTED TO BY   */ 00671000
*             /* THE QUEUE TRAILER. ASSUME THAT THE FORWARD CHAIN    */ 00672000
*             /* POINTER OF THE LAST ELEMENT ON THE FORWARD SCAN IS  */ 00673000
*             /* IN ERROR.                                           */ 00674000
*             /*                                                     */ 00675000
*             /*******************************************************/ 00676000
*                                                               02S0163 00677000
*             ERRVAL1=BADFCHN;      /* INDICATE ERROR                */ 00678000
         MVI   ERRVAL1(R2),X'04'                                DSK1171 00679000
*           IF TQ=NO                /* IF TRAILER NO GOOD            */ 00680000
*               &                   /* AND                           */ 00681000
*               QTYPE>1             /* QUEUE HAS A TRAILER           */ 00682000
*             THEN                                              02S0164 00683000
@RF00162 TM    TQ(R2),B'10000000'                               DSK1171 00684000
         BNZ   @RF00164                                         02S0164 00685000
         CLI   QTYPE(R2),1                                      DSK1171 00686000
         BNH   @RF00164                                         02S0164 00687000
*             ERRVAL2=BADTAIL;      /* INDICATE ERROR                */ 00688000
*                                                               02S0165 00689000
         MVI   ERRVAL2(R2),X'03'                                DSK1171 00690000
*           /*********************************************************/ 00691000
*           /*                                                       */ 00692000
*           /* IF NO ERRORS HAVE BEEN FOUND BY NOW, THEN THE QUEUE   */ 00693000
*           /* STRUCTURE IS VALID. OTHERWISE VALIDATION MUST         */ 00694000
*           /* CONTINUE.                                             */ 00695000
*           /*                                                       */ 00696000
*           /*********************************************************/ 00697000
*                                                               02S0166 00698000
*           IF ERRVAL1^=0×ERRVAL2^=0/* IF AN ERROR FOUND             */ 00699000
*             THEN                                              02S0166 00700000
*                                                               02S0166 00701000
@RF00164 CLI   ERRVAL1(R2),0                                    DSK1171 00702000
         BNE   @RT00166                                         02S0166 00703000
         CLI   ERRVAL2(R2),0                                    DSK1171 00704000
         BE    @RF00166                                         02S0166 00705000
@RT00166 DS    0H                                               02S0167 00706000
*             /*******************************************************/ 00707000
*             /*                                                     */ 00708000
*             /* AN ERROR HAS BEEN FOUND                             */ 00709000
*             /*                                                     */ 00710000
*             /*******************************************************/ 00711000
*                                                               02S0167 00712000
*             DO;                                               02S0167 00713000
*               IF QTYPE=3          /* IF A DOUBLE-THREAD            */ 00714000
*                 THEN                                          02S0168 00715000
         CLI   QTYPE(R2),3                                      DSK1171 00716000
         BNE   @RF00168                                         02S0168 00717000
*                 DO;                                           02S0169 00718000
*                                                               02S0169 00719000
*                   /*************************************************/ 00720000
*                   /*                                               */ 00721000
*                   /* DO A BACKWARD SCAN                            */ 00722000
*                   /*                                               */ 00723000
*                   /*************************************************/ 00724000
*                                                               02S0170 00725000
*                   DIR=BACKWARD;                               02S0170 00726000
         MVI   DIR(R2),X'02'                                    DSK1171 00727000
*                   NDIR=FORWARD;                               02S0171 00728000
         MVI   NDIR(R2),X'01'                                   DSK1171 00729000
*                   CALL SCAN;                                  02S0172 00730000
*                                                               02S0172 00731000
         BAL   R14,SCAN                                         DSK1171 00732000
*                   /*************************************************/ 00733000
*                   /*                                               */ 00734000
*                   /* THE QUEUE HAS NOW BEEN SCANNED BACKWARD. IF AN*/ 00735000
*                   /* ERROR IN THE BACKWARD CHAIN WAS FOUND, ERRVAL2*/ 00736000
*                   /* WILL BE NON-ZERO.                             */ 00737000
*                   /*                                               */ 00738000
*                   /*************************************************/ 00739000
*                                                               02S0173 00740000
*                   IF ERRVAL2=0    /* IF NO ERRORS ON SCAN          */ 00741000
*                       &HQ=YES     /* HEADER POINTS TO ELEMENT      */ 00742000
*                     THEN                                      02S0173 00743000
         CLI   ERRVAL2(R2),0                                    DSK1171 00744000
         BNE   @RF00173                                         02S0173 00745000
         TM    HQ(R2),B'10000000'                               DSK1171 00746000
         BNO   @RF00173                                         02S0173 00747000
*                     IF LASTBAK^=QVPLHDR->PTR24/* HEADER DOES NOT      00748000
*                                      POINT TO LAST FOUND GOING        00749000
*                                      BACKWARDS                     */ 00750000
*                       THEN                                    02S0174 00751000
*                                                               02S0174 00752000
         L     R10,QVPLPTR(,R13)                                DSK1171 00753000
         L     R10,QVPLHDR-QVPL(,R10)                           DSK1171 00754000
         CLC   LASTBAK(3,R2),PTR24(R10)                         DSK1171 00755000
         BE    @RF00174                                         02S0174 00756000
*                       /*********************************************/ 00757000
*                       /*                                           */ 00758000
*                       /* ALTHOUGH NO ERRORS WERE FOUND ON THE      */ 00759000
*                       /* BACKWARD CHAIN, THE BACKWARD CHAIN DOES   */ 00760000
*                       /* NOT MEET THE ELEMENT POINTED TO BY THE    */ 00761000
*                       /* QUEUE HEADER. ASSUME THAT THE BACKWARD    */ 00762000
*                       /* CHAIN POINTER IS BAD.                     */ 00763000
*                       /*                                           */ 00764000
*                       /*********************************************/ 00765000
*                                                               02S0175 00766000
*                       ERRVAL2=BADBCHN;/* INDICATE ERROR            */ 00767000
         MVI   ERRVAL2(R2),X'05'                                DSK1171 00768000
*                     ELSE                                      02S0176 00769000
*                                                               02S0176 00770000
*                       /*********************************************/ 00771000
*                       /*                                           */ 00772000
*                       /* THE BACKWARD CHAIN IS COMPLETE. IF THERE  */ 00773000
*                       /* HAD BEEN ANY ERROS IN THE FORWARD CHAIN   */ 00774000
*                       /* POINTERS, THEN THEY WOULD HAVE BEEN       */ 00775000
*                       /* CORRECTED BY THE FIXNEXT SEGMENT INVOKED  */ 00776000
*                       /* DURING THE BACKWARD SCAN. THEREFORE,      */ 00777000
*                       /* NULLIFY THE FORWARD CHAIN ERROR.          */ 00778000
*                       /*                                           */ 00779000
*                       /*********************************************/ 00780000
*                                                               02S0176 00781000
*                       ERRVAL1=0;  /* ALL FORWARD CHAIN ERRORS HAVE    00782000
*                                      BEEN CORRECTED.               */ 00783000
         B     @RC00174                                         02S0176 00784000
@RF00174 MVI   ERRVAL1(R2),X'00'                                DSK1171 00785000
*                 END;                                          02S0177 00786000
@RC00174 DS    0H                                               02S0177 00787000
@RF00173 DS    0H                                               02S0178 00788000
*               IF ERRVAL1^=0×ERRVAL2^=0/* IF THERE ARE ANY     02S0178 00789000
*                                      OUTSTANDING ERRORS            */ 00790000
*                 THEN                                          02S0178 00791000
@RF00168 CLI   ERRVAL1(R2),0                                    DSK1171 00792000
         BNE   @RT00178                                         02S0178 00793000
         CLI   ERRVAL2(R2),0                                    DSK1171 00794000
         BE    @RF00178                                         02S0178 00795000
@RT00178 DS    0H                                               02S0179 00796000
*                 DO;                                           02S0179 00797000
*                                                               02S0179 00798000
*                   /*************************************************/ 00799000
*                   /*                                               */ 00800000
*                   /* REPAIR THE QUEUE                              */ 00801000
*                   /*                                               */ 00802000
*                   /*************************************************/ 00803000
*                                                               02S0180 00804000
*                                                               03S0180 00805000
*/********************************************************************/ 00806000
*/*         FIXQ                                                     */ 00807000
*/*     IF AN ERROR IN THE QUEUE STRUCTURE IS DETECTED, THIS         */ 00808000
*/*  SEGMENT ANALYZES THE  ERROR AND ATTEMPTS TO RECONSTRUCT THE     */ 00809000
*/* QUEUE IF POSSIBLE.                                               */ 00810000
*/*      INPUT:                                                      */ 00811000
*/*        STANDARD INPUT (SEE SEGMENT INIT)                         */ 00812000
*/*        LASTBAK = ADDRESS OF LAST ELEMENT FOUND                   */ 00813000
*/*          ON A BACKWARDS ON A DOUBLE-THREADED QUEUE.              */ 00814000
*/*        LASTFWD = ADDRESS OF THE LAST ELEMENT FOUND               */ 00815000
*/*             GOING FORWARD ON THE QUEUE.                          */ 00816000
*/*        ERRVAL1 = A CODE INDICATING THE TYPE OF ERROR             */ 00817000
*/*           FOUND ON A FORWARD SCAN. ZERO IF NO ERRORS             */ 00818000
*/*        ERRVAL2 = A CODE INDICATING THE TYPE OF ERROR             */ 00819000
*/*          FOUND ON A BACKWARD SCAN OF THE QUEUE. ZERO             */ 00820000
*/*          IF THERE ARE NO ERRORS.                                 */ 00821000
*/********************************************************************/ 00822000
*/*                                                                  */ 00823000
*                                                               03S0180 00824000
*                   IF QTYPE=2&TQ=YES/* IF TYPE 2 AND GOOD TRAILER   */ 00825000
*                     THEN                                      03S0180 00826000
         CLI   QTYPE(R2),2                                      DSK1171 00827000
         BNE   @RF00180                                         03S0180 00828000
         TM    TQ(R2),B'10000000'                               DSK1171 00829000
         BNO   @RF00180                                         03S0180 00830000
*                     LASTBAK=QVPLTRLR->PTR31;/* INITIALIZE VARIABLE */ 00831000
         L     R10,QVPLPTR(,R13)                                DSK1171 00832000
         L     R10,QVPLTRLR-QVPL(,R10)                          DSK1171 00833000
         MVC   LASTBAK(3,R2),PTR31+1(R10)                       DSK1171 00834000
*                   IF HQ=NO        /* THE HEADER IS BAD             */ 00835000
*                     THEN                                      03S0182 00836000
*                                                               03S0182 00837000
@RF00180 TM    HQ(R2),B'10000000'                               DSK1171 00838000
         BNZ   @RF00182                                         03S0182 00839000
*                     /***********************************************/ 00840000
*                     /*                                             */ 00841000
*                     /* THE HEADER IS BAD. FIX IT BY STORING        */ 00842000
*                     /* QVPLNOEL INTO IT OR STORING THE ADDRESS OF  */ 00843000
*                     /* THE LAST ELEMENT FOUND GOING BACKWARDS.     */ 00844000
*                     /*                                             */ 00845000
*                     /***********************************************/ 00846000
*                                                               03S0183 00847000
*                     DO;                                       03S0183 00848000
*                       IF(QTYPE=1×TQ=NO)/* IF Q HAS NO TRAILER OR      00849000
*                                      TRAILER IS BAD                */ 00850000
*                         THEN                                  03S0184 00851000
         CLI   QTYPE(R2),1                                      DSK1171 00852000
         BE    @RT00184                                         03S0184 00853000
         TM    TQ(R2),B'10000000'                               DSK1171 00854000
         BNZ   @RF00184                                         03S0184 00855000
@RT00184 DS    0H                                               03S0185 00856000
*                         CORRECT=QVPLNOEL;/* INDICATE NO ELEMENTS   */ 00857000
         L     R10,QVPLPTR(,R13)                                DSK1171 00858000
         L     R10,QVPLNOEL-QVPL(,R10)                          DSK1171 00859000
         ST    R10,CORRECT(,R2)                                 DSK1171 00860000
*                       ELSE                                    03S0186 00861000
*                         CORRECT=LASTBAK;/* POINT TO LAST FOUND        00862000
*                                      GOING BACKWARDS               */ 00863000
         B     @RC00184                                         03S0186 00864000
@RF00184 SLR   R10,R10                                          DSK1171 00865000
         ICM   R10,7,LASTBAK(R2)                                DSK1171 00866000
         ST    R10,CORRECT(,R2)                                 DSK1171 00867000
*                       ERRPARM=BADHEAD;/* INDICATE BAD HEADER       */ 00868000
@RC00184 MVI   ERRPARM(R2),X'02'                                DSK1171 00869000
*                       CALL RECORD;/* RECORD AND REPAIR             */ 00870000
         BAL   R14,RECORD                                       DSK1171 00871000
*                     END;                                      03S0189 00872000
*                   IF TQ=NO&QTYPE>1/* IF TRAILER IS BAD             */ 00873000
*                     THEN                                      03S0190 00874000
*                                                               03S0190 00875000
@RF00182 TM    TQ(R2),B'10000000'                               DSK1171 00876000
         BNZ   @RF00190                                         03S0190 00877000
         CLI   QTYPE(R2),1                                      DSK1171 00878000
         BNH   @RF00190                                         03S0190 00879000
*                     /***********************************************/ 00880000
*                     /*                                             */ 00881000
*                     /* THE TRAILER IS BAD. FIX IT TO QVPLNOEL OR TO*/ 00882000
*                     /* THE ADDRESS OF THE LAST ELEMENT FOUND ON THE*/ 00883000
*                     /* FORWARD CHAIN.                              */ 00884000
*                     /*                                             */ 00885000
*                     /***********************************************/ 00886000
*                                                               03S0191 00887000
*                     DO;                                       03S0191 00888000
*                       IF HQ=YES   /* IF HEADER GOOD                */ 00889000
*                         THEN                                  03S0192 00890000
         TM    HQ(R2),B'10000000'                               DSK1171 00891000
         BNO   @RF00192                                         03S0192 00892000
*                         CORRECT=LASTFWD;/* SET TRLR TO LAST ELEM      00893000
*                                      FOUND GOING FORWARD           */ 00894000
         SLR   R10,R10                                          DSK1171 00895000
         ICM   R10,7,LASTFWD(R2)                                DSK1171 00896000
         ST    R10,CORRECT(,R2)                                 DSK1171 00897000
*                       ELSE                                    03S0194 00898000
*                         CORRECT=QVPLNOEL;/* SET TRAILER TO NONE    */ 00899000
         B     @RC00192                                         03S0194 00900000
@RF00192 L     R10,QVPLPTR(,R13)                                DSK1171 00901000
         L     R10,QVPLNOEL-QVPL(,R10)                          DSK1171 00902000
         ST    R10,CORRECT(,R2)                                 DSK1171 00903000
*                       ERRPARM=BADTAIL;/* SET ERROR CODE            */ 00904000
@RC00192 MVI   ERRPARM(R2),X'03'                                DSK1171 00905000
*                       CALL RECORD;/* RECORD/REPAIR                 */ 00906000
         BAL   R14,RECORD                                       DSK1171 00907000
*                     END;                                      03S0197 00908000
*                   IF ERRVAL1>BADTAIL/* IF ERROR IN FORWARD CHAIN   */ 00909000
*                     THEN                                      03S0198 00910000
*                                                               03S0198 00911000
@RF00190 CLI   ERRVAL1(R2),3                                    DSK1171 00912000
         BNH   @RF00198                                         03S0198 00913000
*                     /***********************************************/ 00914000
*                     /*                                             */ 00915000
*                     /* THE FORWARD CHAIN IS BAD. CHANGE THE CHAIN  */ 00916000
*                     /* POINTER OF THE LAST ELEMENT FOUND ON THAT   */ 00917000
*                     /* CHAIN TO EITHER QVPLLELM OR TO THE ADDRESS  */ 00918000
*                     /* OF THE LAST ELEMENT FOUND ON THE BACKWARD   */ 00919000
*                     /* CHAIN.                                      */ 00920000
*                     /*                                             */ 00921000
*                     /***********************************************/ 00922000
*                                                               03S0199 00923000
*                     DO;                                       03S0199 00924000
*                       IF TQ=YES   /* IF TRLR GOOD                  */ 00925000
*                         THEN                                  03S0200 00926000
         TM    TQ(R2),B'10000000'                               DSK1171 00927000
         BNO   @RF00200                                         03S0200 00928000
*                         CORRECT=LASTBAK;/* POINT ELEM TO LAST FOUND   00929000
*                                      BACKWARDS                     */ 00930000
         SLR   R10,R10                                          DSK1171 00931000
         ICM   R10,7,LASTBAK(R2)                                DSK1171 00932000
         ST    R10,CORRECT(,R2)                                 DSK1171 00933000
*                       ELSE        /* NO TRLR OR BAD TRLR           */ 00934000
*                         CORRECT=QVPLLELM;/* MAKE IT THE LAST ONE   */ 00935000
         B     @RC00200                                         03S0202 00936000
@RF00200 L     R10,QVPLPTR(,R13)                                DSK1171 00937000
         L     R10,QVPLLELM-QVPL(,R10)                          DSK1171 00938000
         ST    R10,CORRECT(,R2)                                 DSK1171 00939000
*                       ERRPARM=ERRVAL1;/* SET ERROR CODE            */ 00940000
@RC00200 IC    R10,ERRVAL1(,R2)                                 DSK1171 00941000
         STC   R10,ERRPARM(,R2)                                 DSK1171 00942000
*                       ERRELM=LASTFWD;/* GIVE BAD ELEMENT           */ 00943000
         MVC   ERRELM(3,R2),LASTFWD(R2)                         DSK1171 00944000
*                       CALL RECORD;/* RECORD/REPAIR                 */ 00945000
         BAL   R14,RECORD                                       DSK1171 00946000
*                     END;                                      03S0206 00947000
*                   IF ERRVAL2>BADTAIL/* ERROR IN BACKWARD CHAIN     */ 00948000
*                     THEN                                      03S0207 00949000
*                                                               03S0207 00950000
@RF00198 CLI   ERRVAL2(R2),3                                    DSK1171 00951000
         BNH   @RF00207                                         03S0207 00952000
*                     /***********************************************/ 00953000
*                     /*                                             */ 00954000
*                     /* THE BACKWARD CHAIN IS BAD. CHANGE THE       */ 00955000
*                     /* BACKWARD CHAIN POINTER OF THE LAST ELEMENT  */ 00956000
*                     /* FOUND ON THAT CHAIN TO EITHER QVPLFELM OR TO*/ 00957000
*                     /* THE ADDRESS OF THE LAST ELEMENT FOUND ON THE*/ 00958000
*                     /* FORWARD CHAIN.                              */ 00959000
*                     /*                                             */ 00960000
*                     /***********************************************/ 00961000
*                                                               03S0208 00962000
*                     DO;                                       03S0208 00963000
*                       IF HQ=YES   /* IF HEADER GOOD                */ 00964000
*                         THEN                                  03S0209 00965000
         TM    HQ(R2),B'10000000'                               DSK1171 00966000
         BNO   @RF00209                                         03S0209 00967000
*                         CORRECT=LASTFWD;/* SET CHAIN PTR TO ADDR OF   00968000
*                                      LAST ON FORWARD SCAN          */ 00969000
         SLR   R10,R10                                          DSK1171 00970000
         ICM   R10,7,LASTFWD(R2)                                DSK1171 00971000
         ST    R10,CORRECT(,R2)                                 DSK1171 00972000
*                       ELSE        /* HEADER BAD                    */ 00973000
*                         CORRECT=QVPLFELM;/* MAKE IT FIRST ELEMENT  */ 00974000
         B     @RC00209                                         03S0211 00975000
@RF00209 L     R10,QVPLPTR(,R13)                                DSK1171 00976000
         L     R10,QVPLFELM-QVPL(,R10)                          DSK1171 00977000
         ST    R10,CORRECT(,R2)                                 DSK1171 00978000
*                       ERRPARM=ERRVAL2;/* SET ERROR CODE            */ 00979000
@RC00209 IC    R10,ERRVAL2(,R2)                                 DSK1171 00980000
         STC   R10,ERRPARM(,R2)                                 DSK1171 00981000
*                       ERRELM=LASTBAK;/* SPEC ADDR OF BAD ELEM      */ 00982000
         MVC   ERRELM(3,R2),LASTBAK(R2)                         DSK1171 00983000
*                       CALL RECORD;/* RECORD/REPAIR                 */ 00984000
         BAL   R14,RECORD                                       DSK1171 00985000
*                     END;                                      03S0215 00986000
*                                                               03S0215 00987000
*/********************************************************************/ 00988000
*/* END OF FIXQ                                                      */ 00989000
*/********************************************************************/ 00990000
*                                                               03S0216 00991000
*                 END;                                          02S0216 00992000
@RF00207 DS    0H                                               02S0217 00993000
*             END;                                              02S0217 00994000
*                                                               02S0217 00995000
@RF00178 DS    0H                                               02S0218 00996000
*           /*********************************************************/ 00997000
*           /*                                                       */ 00998000
*           /* THE QUEUE STRUCTURE IS NOW VALID. REMOVE BAD ELEMENTS */ 00999000
*           /* FROM THE QUEUE                                        */ 01000000
*           /*                                                       */ 01001000
*           /*********************************************************/ 01002000
*                                                               02S0218 01003000
*                                                               03S0218 01004000
*/********************************************************************/ 01005000
*/*  RMVBAD -  THIS SEGMENT REMOVES ELEMENTS WITH BAD DATA FROM 03S0218 01006000
*     THE QUEUE.  PRIOR TO THIS THE QUEUE STRUCTURE HAS BEEN VALIDATED  01007000
*    AND/OR CORRECTED.  THE QUEUE WILL BE SCANNED, AND THE ELEMENT      01008000
*    VERIFICATION ROUTINE INVOKED FOR EACH ELEMENT.  IF A RETURN        01009000
*    CODE OF 4 IS PASSED BACK, THE ELEMENT IS REMOVED FROM THE QUEUE.   01010000
*    NOTE:  SINCE PRIOR  CHAIN VALIDATION HAS BEEN DONE, THERE SHOULD   01011000
*    BE NO RETURN CODES OF 8 PASSED BACK FROM THE EVR.               */ 01012000
*/********************************************************************/ 01013000
*                                                               03S0218 01014000
*           IF QVPLHDR->PTR24^=NOELM3/* IF THERE ARE ELEMENTS        */ 01015000
*               ×(QVPLHD3=NO&QVPLHDR->PTR31^=QVPLNOEL) THEN     03S0218 01016000
@RF00166 L     R10,QVPLPTR(,R13)                                DSK1171 01017000
         L     R8,QVPLHDR-QVPL(,R10)                            DSK1171 01018000
         CLC   PTR24(3,R8),QVPLNOEL+1-QVPL(R10)                 DSK1171 01019000
         BNE   @RT00218                                         03S0218 01020000
         TM    QVPLFLGH-QVPL(R10),QVPLHD3                       DSK1171 01021000
         BNZ   @RF00218                                         03S0218 01022000
         CLC   PTR31(4,R8),QVPLNOEL-QVPL(R10)                   DSK1171 01023000
         BE    @RF00218                                         03S0218 01024000
@RT00218 DS    0H                                               03S0219 01025000
*             DO;                                               03S0219 01026000
*               CURRENT=QVPLHDR->PTR24;/* GET ADDR OF FIRST  @ZA07522*/ 01027000
         L     R10,QVPLPTR(,R13)                                DSK1171 01028000
         L     R10,QVPLHDR-QVPL(,R10)                           DSK1171 01029000
         L     R10,PTR24-1(,R10)                                DSK1171 01030000
         LA    R10,0(,R10)                                      DSK1171 01031000
         ST    R10,CURRENT(,R2)                                 DSK1171 01032000
*               PREV=0;             /* INITIALIZE PREVIOUS           */ 01033000
         SLR   R11,R11                                          DSK1171 01034000
*               DO WHILE CURRENT^=0;/* WHILE THERE ARE ELEMENTS      */ 01035000
         B     @DE00222                                         03S0222 01036000
@DL00222 DS    0H                                               03S0223 01037000
*                 NEXT=(CURRENT+QVPLFPTR)->PTR24;/* NEXT ADDR   03S0223 01038000
*                                                            @ZA07522*/ 01039000
         L     R10,QVPLPTR(,R13)                                DSK1171 01040000
         LH    R8,QVPLFPTR-QVPL(,R10)                           DSK1171 01041000
         AL    R8,CURRENT(,R2)                                  DSK1171 01042000
         L     R8,PTR24-1(,R8)                                  DSK1171 01043000
         ST    R8,NEXT(,R2)                                     DSK1171 01045000
*                 IF NEXT=QVPLLELM  /* IF THIS IS LAST ELEMENT       */ 01046000
*                     ×(NEXT3=LASTELM3&QVPLFP3=YES) THEN        03S0224 01047000
         C     R8,QVPLLELM-QVPL(,R10)                           DSK1171 01048000
         BE    @RT00224                                         03S0224 01049000
         CLC   NEXT3(3,R2),QVPLLELM+1-QVPL(R10)                 DSK1171 01050000
         BNE   @RF00224                                         03S0224 01051000
         TM    QVPLFLGF-QVPL(R10),QVPLFP3                       DSK1171 01052000
         BNO   @RF00224                                         03S0224 01053000
@RT00224 DS    0H                                               03S0225 01054000
*                   NEXT=0;                                     03S0225 01055000
         SLR   R10,R10                                          DSK1171 01056000
         ST    R10,NEXT(,R2)                                    DSK1171 01057000
*                 RESPECIFY                                     03S0226 01058000
*                   R0 RSTD;                                    03S0226 01059000
@RF00224 DS    0H                                               03S0227 01060000
*                 R0=CURRENT3;                                  03S0227 01061000
         L     R0,CURRENT3-1(,R2)                               DSK1171 01062000
         ICM   R0,8,@CB00272                                    03S0227 01063000
*                 R1=S0;            /* SET UP PARM VALUE             */ 01064000
         L     R1,S0(,R13)                                      03S0228 01065000
*                 CALL EVR;                                     03S0229 01066000
         L     R10,QVPLPTR(,R13)                                DSK1171 01067000
         L     R15,QVPLEVR-QVPL(,R10)                           DSK1171 01068000
         BALR  R14,R15                                          DSK1171 01069000
*                 R1=S1;            /* RESTORE R1                    */ 01070000
         L     R1,S1(,R13)                                      03S0230 01071000
*                 WAPTR=QVPLWKA;    /* RESTORE R2                    */ 01072000
         L     R10,QVPLPTR(,R13)                                DSK1171 01073000
         L     R2,QVPLWKA-QVPL(,R10)                            DSK1171 01074000
*                 RESPECIFY                                     03S0232 01075000
*                   R15 RSTD;                                   03S0232 01076000
*                 RESPECIFY                                     03S0233 01077000
*                   R0 UNRSTD;                                  03S0233 01078000
*                 IF R15=4 THEN                                 03S0234 01079000
         C     R15,@CF00133                                     03S0234 01080000
         BNE   @RF00234                                         03S0234 01081000
*                   DO;                                         03S0235 01082000
*                     RESPECIFY                                 03S0236 01083000
*                       R15 UNRSTD;                             03S0236 01084000
*                                                               03S0236 01085000
*                     /***********************************************/ 01086000
*                     /*                                             */ 01087000
*                     /* DEQUEUE THE ELEMENT                         */ 01088000
*                     /*                                             */ 01089000
*                     /***********************************************/ 01090000
*                                                               03S0237 01091000
*                                                               04S0237 01092000
*/********************************************************************/ 01093000
*/*  DQELM                                                           */ 01094000
*/*  THIS SEGMENT  DEQUEUES AN ELEMENT FROM THE QUEUE.               */ 01095000
*/*  INPUT:                                                          */ 01096000
*/*       PREV       = CONTAINS EITHER 0 IF THIS IS THE TOP ELEMENT  */ 01097000
*/*           ON THE QUEUE, OR IF IT IS NOT THE TOP ELEMENT, IT      */ 01098000
*/*           CONTAINS THE ADDRESS OF THE PREVIOUS ELEMENT.          */ 01099000
*/*       NEXT       = CONTAINS EITHER THE ADDRESS OF THE NEXT       */ 01100000
*/*          ELEMENT ON THE QUEUE, OR ZERO IF THIS IS THE LAST       */ 01101000
*/*          ELEMENT.                                                */ 01102000
*/*      OTHER STANDARD INPUTS.                                      */ 01103000
*/********************************************************************/ 01104000
*                                                               04S0237 01105000
*                     RESPECIFY                                 04S0237 01106000
*                      (WRKREG,                                 04S0237 01107000
*                       WRKRG2) RSTD;                           04S0237 01108000
*                     IF PREV=0     /* FIRST ELEMENT                 */ 01109000
*                       THEN                                    04S0238 01110000
         SLR   R8,R8                                            DSK1171 01111000
         CR    R11,R8                                           DSK1171 01112000
         BNE   @RF00238                                         04S0238 01113000
*                       IF NEXT=0   /* LAST ELEMENT                  */ 01114000
*                         THEN                                  04S0239 01115000
*                                                               04S0239 01116000
         C     R8,NEXT(,R2)                                     DSK1171 01117000
         BNE   @RF00239                                         04S0239 01118000
*                         /*******************************************/ 01119000
*                         /*                                         */ 01120000
*                         /* THE ONLY ELEMENT ON THE QUEUE.          */ 01121000
*                         /*                                         */ 01122000
*                         /*******************************************/ 01123000
*                                                               04S0240 01124000
*                         DO;                                   04S0240 01125000
*                           WRKREG=QVPLNOEL;/* VALUE FOR HEADER      */ 01126000
         L     R10,QVPLNOEL-QVPL(,R10)                          DSK1171 01127000
         LR    R3,R10                                           DSK1171 01128000
*                           WRKRG2=QVPLNOEL;/* VALUE FOR TRAILER     */ 01129000
         LR    R4,R10                                           DSK1171 01130000
*                         END;                                  04S0243 01131000
*                       ELSE        /* NOT LAST                      */ 01132000
*                                                               04S0244 01133000
*                         /*******************************************/ 01134000
*                         /*                                         */ 01135000
*                         /* THE FIRST BUT NOT THE ONLY ELEMENT .    */ 01136000
*                         /*                                         */ 01137000
*                         /*******************************************/ 01138000
*                                                               04S0244 01139000
*                         DO;                                   04S0244 01140000
         B     @RC00238                                         DSK1171 01141000
@RF00239 DS    0H                                               04S0245 01142000
*                           WRKREG=NEXT;/* VALUE FOR HEADER          */ 01143000
         L     R3,NEXT(,R2)                                     DSK1171 01144000
*                           WRKRG2=QVPLFELM;/* VALUE FOR BACKWARD       01145000
*                                      CHAIN IN NEXT                 */ 01146000
         L     R10,QVPLPTR(,R13)                                DSK1171 01147000
         L     R4,QVPLFELM-QVPL(,R10)                           DSK1171 01148000
*                         END;                                  04S0247 01149000
*                     ELSE          /* NOT FIRST ELEMENT             */ 01150000
*                       IF NEXT=0   /* IF LAST ELEMENT               */ 01151000
*                         THEN                                  04S0248 01152000
*                                                               04S0248 01153000
         B     @RC00238                                         04S0248 01154000
@RF00238 L     R10,NEXT(,R2)                                    DSK1171 01155000
         LTR   R10,R10                                          DSK1171 01156000
         BNZ   @RF00248                                         04S0248 01157000
*                         /*******************************************/ 01158000
*                         /*                                         */ 01159000
*                         /* THE LAST ELEMENT BUT NOT THE FIRST.     */ 01160000
*                         /*                                         */ 01161000
*                         /*******************************************/ 01162000
*                                                               04S0249 01163000
*                         DO;                                   04S0249 01164000
*                           WRKREG=QVPLLELM;/* VALUE FOR FORWARD        01165000
*                                      CHAIN OF PREVIOUS ELEMENT     */ 01166000
         L     R10,QVPLPTR(,R13)                                DSK1171 01167000
         L     R3,QVPLLELM-QVPL(,R10)                           DSK1171 01168000
*                           WRKRG2=PREV;/* VALUE FOR TRAILER         */ 01169000
         LR    R4,R11                                           DSK1171 01170000
*                         END;                                  04S0252 01171000
*                       ELSE        /* NOT LAST ELEMENT              */ 01172000
*                                                               04S0253 01173000
*                         /*******************************************/ 01174000
*                         /*                                         */ 01175000
*                         /* NEITHER THE FIRST NOR THE LAST ELEMENT. */ 01176000
*                         /*                                         */ 01177000
*                         /*******************************************/ 01178000
*                                                               04S0253 01179000
*                         DO;                                   04S0253 01180000
         B     @RC00248                                         04S0253 01181000
@RF00248 DS    0H                                               04S0254 01182000
*                           WRKREG=NEXT;/* VALUE FOR FORWARD CHAIN IN   01183000
*                                      PREVIOUS                      */ 01184000
         L     R3,NEXT(,R2)                                     DSK1171 01185000
*                           WRKRG2=PREV;/* VALUE FOR BACKWARD CHAIN     01186000
*                                      IN NEXT                       */ 01187000
         LR    R4,R11                                           DSK1171 01188000
*                         END;                                  04S0256 01189000
*                     IF PREV=0     /* TOP ELEMENT                   */ 01190000
*                       THEN                                    04S0257 01191000
*                                                               04S0257 01192000
@RC00248 DS    0H                                               04S0257 01193000
@RC00238 LTR   R11,R11                                          DSK1171 01194000
         BNZ   @RF00257                                         04S0257 01195000
*                       /*********************************************/ 01196000
*                       /*                                           */ 01197000
*                       /* FIRST ELEMENT - UPDATE THE HEADER.        */ 01198000
*                       /*                                           */ 01199000
*                       /*********************************************/ 01200000
*                                                               04S0258 01201000
*                       IF QVPLHD3=YES/* IF 3-BYTE FIELD             */ 01202000
*                         THEN                                  04S0258 01203000
         L     R10,QVPLPTR(,R13)                                DSK1171 01204000
         TM    QVPLFLGH-QVPL(R10),QVPLHD3                       DSK1171 01205000
         BNO   @RF00258                                         04S0258 01206000
*                         QVPLHDR->PTR24=WRKREG;                04S0259 01207000
         L     R10,QVPLHDR-QVPL(,R10)                           DSK1171 01208000
         STCM  R3,7,PTR24(R10)                                  DSK1171 01209000
*                       ELSE                                    04S0260 01210000
*                         QVPLHDR->PTR31=WRKREG;                04S0260 01211000
         B     @RC00257                                         DSK1171 01212000
@RF00258 L     R10,QVPLPTR(,R13)                                DSK1171 01213000
         L     R10,QVPLHDR-QVPL(,R10)                           DSK1171 01214000
         ST    R3,PTR31(,R10)                                   DSK1171 01215000
*                     ELSE          /* NOT TOP ELEMENT               */ 01216000
*                                                               04S0261 01217000
*                       /*********************************************/ 01218000
*                       /*                                           */ 01219000
*                       /* NOT THE FIRST ELEMENT- UPDATE THE FORWARD */ 01220000
*                       /* CHAIN OF PREVIOUS                         */ 01221000
*                       /*                                           */ 01222000
*                       /*********************************************/ 01223000
*                                                               04S0261 01224000
*                       IF QVPLFP3=YES THEN                     04S0261 01225000
         B     @RC00257                                         04S0261 01226000
@RF00257 L     R10,QVPLPTR(,R13)                                DSK1171 01227000
         TM    QVPLFLGF-QVPL(R10),QVPLFP3                       DSK1171 01228000
         BNO   @RF00261                                         04S0261 01229000
*                         EVAL(PREV+QVPLFPTR)->PTR24=WRKREG;/* CHANGE   01230000
*                                      3-BYTE CHAIN                  */ 01231000
         LR    R8,R11                                           DSK1171 01232000
         AH    R8,QVPLFPTR-QVPL(,R10)                           DSK1171 01233000
         STCM  R3,7,PTR24(R8)                                   DSK1171 01234000
*                       ELSE                                    04S0263 01235000
*                         EVAL(PREV+QVPLFPTR)->PTR31=WRKREG;/* CHANGE   01236000
*                                      4-BYTE CHAIN                  */ 01237000
         B     @RC00261                                         04S0263 01238000
@RF00261 L     R10,QVPLPTR(,R13)                                DSK1171 01239000
         LR    R8,R11                                           DSK1171 01240000
         AH    R8,QVPLFPTR-QVPL(,R10)                           DSK1171 01241000
         ST    R3,PTR31(,R8)                                    DSK1171 01242000
*                     IF NEXT=0     /* BOTTOM ELEMENT                */ 01243000
*                         &QTYPE>=2 /* QUEUE HAS TRAILER             */ 01244000
*                       THEN                                    04S0264 01245000
*                                                               04S0264 01246000
@RC00261 DS    0H                                               04S0264 01247000
@RC00257 L     R10,NEXT(,R2)                                    DSK1171 01248000
         LTR   R10,R10                                          DSK1171 01249000
         BNZ   @RF00264                                         04S0264 01250000
         CLI   QTYPE(R2),2                                      DSK1171 01251000
         BL    @RF00264                                         04S0264 01252000
*                       /*********************************************/ 01253000
*                       /*                                           */ 01254000
*                       /* LAST ELEMENT - UPDATE THE TRAILER.        */ 01255000
*                       /*                                           */ 01256000
*                       /*********************************************/ 01257000
*                                                               04S0265 01258000
*                       IF QVPLTR3=YES THEN                     04S0265 01259000
         L     R10,QVPLPTR(,R13)                                DSK1171 01260000
         TM    QVPLFLGT-QVPL(R10),QVPLTR3                       DSK1171 01261000
         BNO   @RF00265                                         04S0265 01262000
*                         QVPLTRLR->PTR24=WRKRG2;/* CHANGE 3-BYTE       01263000
*                                      TRAILER                       */ 01264000
         L     R10,QVPLTRLR-QVPL(,R10)                          DSK1171 01265000
         STCM  R4,7,PTR24(R10)                                  DSK1171 01266000
*                       ELSE                                    04S0267 01267000
*                         QVPLTRLR->PTR31=WRKRG2;/* CHANGE 4-BYTE       01268000
*                                      TRAILER                       */ 01269000
         B     @RC00265                                         04S0267 01270000
@RF00265 L     R10,QVPLPTR(,R13)                                DSK1171 01271000
         L     R10,QVPLTRLR-QVPL(,R10)                          DSK1171 01272000
         ST    R4,PTR31(,R10)                                   DSK1171 01273000
*                     IF NEXT^=0    /* IF NOT THE BOTTOM ELEM        */ 01274000
*                         &QTYPE=3  /* DOUBLE THREAD QUEUE           */ 01275000
*                       THEN                                    04S0268 01276000
*                                                               04S0268 01277000
@RC00265 DS    0H                                               04S0268 01278000
@RF00264 L     R10,NEXT(,R2)                                    DSK1171 01279000
         LTR   R10,R10                                          DSK1171 01280000
         BZ    @RF00268                                         04S0268 01281000
         CLI   QTYPE(R2),3                                      DSK1171 01282000
         BNE   @RF00268                                         04S0268 01283000
*                       /*********************************************/ 01284000
*                       /*                                           */ 01285000
*                       /* NOT THE LAST - UPDATE THE BACKWARD CHAIN  */ 01286000
*                       /* OF THE NEXT ELEMENT.                      */ 01287000
*                       /*                                           */ 01288000
*                       /*********************************************/ 01289000
*                                                               04S0269 01290000
*                       DO;                                     04S0269 01291000
*                         IF QVPLBP3=YES/* IF 3-BYTE BACK CHAIN      */ 01292000
*                           THEN                                04S0270 01293000
         L     R8,QVPLPTR(,R13)                                 DSK1171 01294000
         TM    QVPLFLGB-QVPL(R8),QVPLBP3                        DSK1171 01295000
         BNO   @RF00270                                         04S0270 01296000
*                           EVAL(NEXT+QVPLBPTR)->PTR24=WRKRG2;/*        01297000
*                                      UPDATE 3-BYTE CHAIN           */ 01298000
         AH    R10,QVPLBPTR-QVPL(,R8)                           DSK1171 01299000
         STCM  R4,7,PTR24(R10)                                  DSK1171 01300000
*                         ELSE                                  04S0272 01301000
*                           EVAL(NEXT+QVPLBPTR)->PTR31=WRKRG2;/*        01302000
*                                      UPDATE 4-BYTE CHAIN           */ 01303000
         B     @RC00270                                         04S0272 01304000
@RF00270 L     R10,QVPLPTR(,R13)                                DSK1171 01305000
         LH    R10,QVPLBPTR-QVPL(,R10)                          DSK1171 01306000
         AL    R10,NEXT(,R2)                                    DSK1171 01307000
         ST    R4,PTR31(,R10)                                   DSK1171 01308000
*                       END;                                    04S0273 01309000
@RC00270 DS    0H                                               04S0274 01310000
*                     RESPECIFY                                 04S0274 01311000
*                      (WRKREG,                                 04S0274 01312000
*                       WRKRG2) UNRSTD;                         04S0274 01313000
*                                                               04S0274 01314000
@RF00268 DS    0H                                               04S0275 01315000
*/********************************************************************/ 01316000
*/*  END OF DQELM                                                    */ 01317000
*/*      OUTPUT -                                                    */ 01318000
*/*        WRKREG (R3) - VOLATILE                                    */ 01319000
*/*        WRKRG2 (R4) - VOLATILE                                    */ 01320000
*/********************************************************************/ 01321000
*                                                               04S0275 01322000
*                     ERRPARM=BADDATA;                          03S0275 01323000
         MVI   ERRPARM(R2),X'01'                                DSK1171 01324000
*                     ERRELM=CURRENT;                           03S0276 01325000
         MVC   ERRELM(3,R2),CURRENT+1(R2)                       DSK1171 01326000
*                     CALL RECORD;  /* RECORD THE ERROR              */ 01327000
         BAL   R14,RECORD                                       DSK1171 01328000
*                   END;                                        03S0278 01329000
*                 ELSE                                          03S0279 01330000
*                   PREV=CURRENT;                               03S0279 01331000
         B     @RC00234                                         03S0279 01332000
@RF00234 L     R11,CURRENT(,R2)                                 DSK1171 01333000
*                 CURRENT=NEXT;                                 03S0280 01334000
@RC00234 L     R10,NEXT(,R2)                                    DSK1171 01335000
         ST    R10,CURRENT(,R2)                                 DSK1171 01336000
*               END;                                            03S0281 01337000
@DE00222 L     R10,CURRENT(,R2)                                 DSK1171 01338000
         LTR   R10,R10                                          DSK1171 01339000
         BNZ   @DL00222                                         03S0281 01340000
*             END;                                              03S0282 01341000
*         END;                                                  02S0283 01342000
*                                                               02S0283 01343000
@RF00218 DS    0H                                               02S0284 01344000
*       /*************************************************************/ 01345000
*       /*                                                           */ 01346000
*       /* ALL QUEUE VALIDATION HAS NOW BEEN DONE. THE REMAINING CODE*/ 01347000
*       /* FINISHES RECORDING.                                       */ 01348000
*       /*                                                           */ 01349000
*       /*************************************************************/ 01350000
*                                                               02S0284 01351000
*       IF QVPLODA^=0               /* THERE IS AN ODA               */ 01352000
*           &QVODSIZE-QVODUSED>=4   /* THERE IS ROOM TO RECORD       */ 01353000
*           &ERRCODE^=0             /* THERE IS AN ERROR             */ 01354000
*         THEN                                                  02S0284 01355000
@RC00124 L     R10,QVPLPTR(,R13)                                DSK1171 01356000
         L     R10,QVPLODA-QVPL(,R10)                           DSK1171 01357000
         LTR   R10,R10                                          DSK1171 01358000
         BZ    @PB00002                                         DSK1171 01359000
         LA    R8,4                                             DSK1171 01360000
         SLR   R3,R3                                            DSK1171 01361000
         IC    R3,QVODUSED-QVODHDR(,R10)                        DSK1171 01362000
         SLR   R0,R0                                            DSK1171 01363000
         IC    R0,QVODSIZE-QVODHDR(,R10)                        DSK1171 01364000
         SLR   R0,R3                                            DSK1171 01365000
         CR    R0,R8                                            DSK1171 01366000
         BL    @PB00002                                         DSK1171 01367000
         CLI   ERRCODE(R13),0                                   02S0284 01368000
         BE    @PB00002                                         DSK1171 01369000
*         DO;                                                   02S0285 01370000
*           QVODR15=ERRR15;         /* RECORD REG 15                 */ 01371000
         LR    R15,R10                                          DSK1171 01372000
         ALR   R15,R8                                           DSK1171 01373000
         ALR   R15,R3                                           DSK1171 01374000
         MVC   QVODR15-QVODCMMN(4,R15),ERRR15(R13)              DSK1171 01375000
*           QVODUSED=QVODUSED+      /* INCREMENT BYTES USED          */ 01376000
*               LENGTH(QVODCMMN)+NREC*LENGTH(QVODENT);          02S0287 01377000
         ALR   R3,R8                                            DSK1171 01378000
         SLR   R8,R8                                            DSK1171 01379000
         IC    R8,NREC(,R13)                                    DSK1171 01380000
         SLA   R8,4                                             DSK1171 01381000
         ALR   R3,R8                                            DSK1171 01382000
         STC   R3,QVODUSED-QVODHDR(,R10)                        DSK1171 01383000
*         END;                                                  02S0288 01384000
*     END;                                                      02S0289 01385000
*                                                               01S0290 01386000
*/********************************************************************/ 01387000
*/*  INCLUDED HERE ARE THE INTERNAL PROCEDURES                       */ 01388000
*/********************************************************************/ 01389000
*                                                               01S0290 01390000
*   RESPECIFY                                                   01S0290 01391000
*    (SAVERET1,                                                 01S0290 01392000
*     SAVERET2) RSTD;                                           01S0290 01393000
*                                                               02S0291 01394000
*/********************************************************************/ 01395000
*/*      SCAN -                                                      */ 01396000
*/* THIS SEGMENT WILL SCAN A CHAIN, EITHER FORWARD OR BACKWARD       */ 01397000
*/* AND WILL INDICATE IF THE CHAIN IS BROKEN AT SOME POINT.          */ 01398000
*/* THE CHAIN IS BROKEN IF IT IS CIRCULAR OR IF THE LAST QUEUE       */ 01399000
*/* ELEMENT FOUND DOES NOT CONTAIN THE PROPER 'LAST-ELEMENT'         */ 01400000
*/* INDICATION.                                                      */ 01401000
*/********************************************************************/ 01402000
*                                                               02S0291 01403000
*   RESPECIFY                                                   02S0291 01404000
*     R14 RSTD;                                                 02S0291 01405000
*SCAN:                                                          02S0292 01406000
*   PROC OPTIONS(NOSAVE NOSAVEAREA);                            02S0292 01407000
@EL00001 DS    0H                                               02S0292 01408000
@EF00001 DS    0H                                               02S0292 01409000
@ER00001 LM    R14,R12,12(R13)                                  DSK1171 01410000
         BR    R14                                              DSK1171 01411000
SCAN     DS    0H                                               02S0293 01412000
*   SAVERET1=R14;                   /* SAVE RETURN REGISTER          */ 01413000
         LR    R8,R14                                           DSK1171 01414000
*   RESPECIFY                                                   02S0294 01415000
*     R14 UNRSTD;                                               02S0294 01416000
*   ERRREG=0;                                                   02S0295 01417000
         SLR   R9,R9                                            DSK1171 01418000
*   CURRENT=0;                                                  02S0296 01419000
         SLR   R3,R3                                            DSK1171 01420000
         ST    R3,CURRENT(,R2)                                  DSK1171 01421000
*   IF HTQ(DIR)=YES                 /* IF HEADER(TRAILER) POINTS TO A   01422000
*                                      QUEUE ELEMENT                 */ 01423000
*     THEN                                                      02S0297 01424000
         SLR   R3,R3                                            DSK1171 01425000
         IC    R3,DIR(,R2)                                      DSK1171 01426000
         LR    R15,R3                                           DSK1171 01427000
         MH    R15,@CH00163                                     DSK1171 01428000
         ALR   R15,R2                                           DSK1171 01429000
         AL    R15,@CF00273                                     DSK1171 01430000
         TM    HTQ(R15),B'10000000'                             DSK1171 01431000
         BNO   @RF00297                                         02S0297 01432000
*     DO;                                                       02S0298 01433000
*       CURRENT=HDRTLR(DIR)->PTR24; /* GET ADDR OF FIRST ELEM        */ 01434000
         MH    R3,@CH00032                                      DSK1171 01435000
         L     R15,QVPLPTR(,R13)                                DSK1171 01436000
         L     R14,QVPLHDR-QVPLNOEL(R3,R15)                     DSK1171 01437000
         L     R0,PTR24-1(,R14)                                 DSK1171 01438000
         ICM   R0,8,@CB00272                                    DSK1171 01439000
         ST    R0,CURRENT(,R2)                                  DSK1171 01440000
*       NEXT=(CURRENT+FBOFFSET(DIR))->PTR31;/* GET NEXT ELEMENT      */ 01441000
         LH    R3,QVPLFPTR-QVPLNOEL(R3,R15)                     DSK1171 01442000
         N     R3,@CF00274                                      DSK1171 01443000
         ALR   R0,R3                                            DSK1171 01444000
         LR    R3,R0                                            DSK1171 01445000
         L     R3,PTR31(,R3)                                    DSK1171 01446000
         ST    R3,NEXT(,R2)                                     DSK1171 01447000
*       COUNT=2;                    /* INITIALIZE THE CIRCULARITY       01448000
*                                      COUNT                         */ 01449000
         MVC   COUNT(3,R2),@CF00111+1                           DSK1171 01450000
*     END;                                                      02S0302 01451000
*   ELSE                                                        02S0303 01452000
*                                                               02S0303 01453000
*     /***************************************************************/ 01454000
*     /*                                                             */ 01455000
*     /* THE HEADER(TRAILER DOES NOT POINT TO A QUEUE ELEMENT. IT IS */ 01456000
*     /* ASSUMED TO BE BAD SINCE EMPTY QUEUES HAVE BEEN HANDLED      */ 01457000
*     /* EARLIER.                                                    */ 01458000
*     /*                                                             */ 01459000
*     /***************************************************************/ 01460000
*                                                               02S0303 01461000
*     ERRREG=BADHEAD;               /* INDICATE BAD HEADER OR TRAILER*/ 01462000
*                                                               02S0303 01463000
         B     @RC00297                                         02S0303 01464000
@RF00297 LA    R9,2                                             DSK1171 01465000
*   /*****************************************************************/ 01466000
*   /*                                                               */ 01467000
*   /* CONTINUE TO SCAN THROUGH THE QUEUE UNTIL AN ERROR IS FOUND OR */ 01468000
*   /* UNTIL THE END OF THE CHAIN IS REACHED.                        */ 01469000
*   /*                                                               */ 01470000
*   /*****************************************************************/ 01471000
*                                                               02S0304 01472000
*   DO WHILE ERRREG=0               /* ERROR NOT YET DETECTED        */ 01473000
*         &                         /* AND                           */ 01474000
*         (NEXT3^=LASTFST3(DIR)     /* THIS IS NOT THE LAST ELEMENT     01475000
*                                      OR                            */ 01476000
*         ×(FB3(DIR)=NO             /* THE CHAIN POINTER IS 4 BYTES     01477000
*                                      AND                           */ 01478000
*         &NEXT^=LASTFST(DIR)))     /* THIS IS NOT THE LAST          */ 01479000
*         ;                                                     02S0304 01480000
@RC00297 B     @DE00304                                         02S0304 01481000
@DL00304 DS    0H                                               02S0305 01482000
*     IF NEXT3^=0                   /* IF THE CHAIN FIELD IS NOT ZERO*/ 01483000
*       THEN                                                    02S0305 01484000
         L     R3,NEXT3-1(,R2)                                  DSK1171 01485000
         LA    R3,0(,R3)                                        DSK1171 01486000
         LTR   R3,R3                                            DSK1171 01487000
         BZ    @RF00305                                         02S0305 01488000
*       DO;                                                     02S0306 01489000
*         RESPECIFY                                             02S0307 01490000
*           R0 RSTD;                                            02S0307 01491000
*                                                               02S0307 01492000
*         /***********************************************************/ 01493000
*         /*                                                         */ 01494000
*         /* INVOKE THE USERS ELEMENT VERIFICATION ROUTINE AND CHECK */ 01495000
*         /* FOR A RETURN CODE OF 8,MEANING THAT THE ADDRESS DOES NOT*/ 01496000
*         /* CONTAIN A QUEUE ELEMENT.                                */ 01497000
*         /*                                                         */ 01498000
*         /***********************************************************/ 01499000
*                                                               02S0308 01500000
*         R1=S0;                    /* INIT PARAMETER REGISTER       */ 01501000
         L     R1,S0(,R13)                                      02S0308 01502000
*         R0=NEXT3;                 /* PASS ADDR TO BE VERIFIED      */ 01503000
         LR    R0,R3                                            DSK1171 01504000
*         CALL EVR;                 /* VERIFY ADDRESS                */ 01505000
         L     R3,QVPLPTR(,R13)                                 DSK1171 01506000
         L     R15,QVPLEVR-QVPL(,R3)                            DSK1171 01507000
         BALR  R14,R15                                          DSK1171 01508000
*         RESPECIFY                                             02S0311 01509000
*           R15 RSTD;                                           02S0311 01510000
*         RESPECIFY                                             02S0312 01511000
*           R0 UNRSTD;                                          02S0312 01512000
*         R1=S1;                    /* RESTORE R1                    */ 01513000
         L     R1,S1(,R13)                                      02S0313 01514000
*         WAPTR=QVPLWKA;            /* RESTORE R2                    */ 01515000
         L     R14,QVPLPTR(,R13)                                DSK1171 01516000
         L     R2,QVPLWKA-QVPL(,R14)                            DSK1171 01517000
*         IF R15^=8                 /* IF IT IS A QUEUE ELEMENT      */ 01518000
*           THEN                                                02S0315 01519000
         C     R15,@CF00058                                     02S0315 01520000
         BE    @RF00315                                         02S0315 01521000
*           DO;                                                 02S0316 01522000
*             RESPECIFY                                         02S0317 01523000
*               R15 UNRSTD;                                     02S0317 01524000
*                                                               02S0317 01525000
*             /*******************************************************/ 01526000
*             /*                                                     */ 01527000
*             /* CHECK FOR CIRCULARITY                               */ 01528000
*             /*                                                     */ 01529000
*             /*******************************************************/ 01530000
*                                                               02S0318 01531000
*                                                               03S0318 01532000
*/********************************************************************/ 01533000
*/* CIRCCHEK                                                         */ 01534000
*/*  THIS SEGMENT INSURES THAT THE  QUEUE IS NOT CIRCULAR. IT        */ 01535000
*/*  SCANS THE QUEUE IN THE DIRECTION INDICATED BY THE DIR VALUE.    */ 01536000
*/*  IF THE ELEMENT INDICATED BY THE 'NEXT' VALUE (R10) IS FOUND,    */ 01537000
*/*  IT IS CHECKED TO SEE  THAT IT IS IN THE POSITION ON THE QUEUE   */ 01538000
*/*  INDICATED BY THE 'COUNT' VALUE.  IF IT IS NOT,  THE QUEUE       */ 01539000
*/*  IS CIRCULAR.                                                    */ 01540000
*/*      INPUT:                                                      */ 01541000
*/*       NEXT = CONTAINS THE ADDRESS OF THE NEXT ELEMENT ON         */ 01542000
*/*          THE QUEUE. THE QUEUE WILL BE SCANNED UP TO THIS ELEMENT */ 01543000
*/*       COUNT  = NUMBER REPRESENTING THE POSITION ON THE QUEUE THAT*/ 01544000
*/*         THE NEXT ELEMENT SHOULD BE AT.                           */ 01545000
*/*       DIR = 1, IF THIS IS A FORWARD SEARCH OF THE QUEUE.         */ 01546000
*/*           = 2, IF THIS IS A BACKWARD SEARCH OF THE QUEUE.        */ 01547000
*/*       OTHER STANDARD INPUTS.                                03S0318 01548000
*/********************************************************************/ 01549000
*                                                               03S0318 01550000
*             RESPECIFY                                         03S0318 01551000
*              (WRKREG,                                         03S0318 01552000
*               WRKRG2) RSTD;                                   03S0318 01553000
*             WRKRG2=1;             /* INITIALIZE COUNT              */ 01554000
         LA    R4,1                                             DSK1171 01555000
*             WRKREG=HDRTLR(DIR)->PTR24;/* GET CONTENTS OF HEADER OR    01556000
*                                      TRAILER                       */ 01557000
         SLR   R5,R5                                            DSK1171 01558000
         IC    R5,DIR(,R2)                                      DSK1171 01559000
         MH    R5,@CH00032                                      DSK1171 01560000
         L     R5,QVPLHDR-QVPLNOEL(R5,R14)                      DSK1171 01561000
         L     R3,PTR24-1(,R5)                                  DSK1171 01562000
         LA    R3,0(,R3)                                        DSK1171 01563000
*             DO WHILE(WRKREG^=NEXT3);/* LOOP WHILE NEXT HAS NOT BEEN   01564000
*                                      FOUND                         */ 01565000
         B     @DE00321                                         03S0321 01566000
@DL00321 DS    0H                                               03S0322 01567000
*               WRKREG=(WRKREG+FBOFFSET(DIR))->PTR24;/* GET NEXT        01568000
*                                      ELEMENT                       */ 01569000
         SLR   R5,R5                                            DSK1171 01570000
         IC    R5,DIR(,R2)                                      DSK1171 01571000
         MH    R5,@CH00032                                      DSK1171 01572000
         L     R15,QVPLPTR(,R13)                                DSK1171 01573000
         LR    R14,R3                                           DSK1171 01574000
         LH    R5,QVPLFPTR-QVPLNOEL(R5,R15)                     DSK1171 01575000
         N     R5,@CF00274                                      DSK1171 01576000
         ALR   R14,R5                                           DSK1171 01577000
         L     R5,PTR24-1(,R14)                                 DSK1171 01578000
         LA    R5,0(,R5)                                        DSK1171 01579000
         LR    R3,R5                                            DSK1171 01580000
*               WRKRG2=WRKRG2+1;    /* BUMP COUNT                    */ 01581000
         AL    R4,@CF00081                                      DSK1171 01582000
*             END;                                              03S0324 01583000
@DE00321 L     R5,NEXT3-1(,R2)                                  DSK1171 01584000
         LA    R5,0(,R5)                                        DSK1171 01585000
         CR    R3,R5                                            DSK1171 01586000
         BNE   @DL00321                                         03S0324 01587000
*             IF WRKRG2^=COUNT THEN                             03S0325 01588000
         L     R5,COUNT-1(,R2)                                  DSK1171 01589000
         LA    R5,0(,R5)                                        DSK1171 01590000
         CR    R4,R5                                            DSK1171 01591000
         BE    @RF00325                                         03S0325 01592000
*               ERRREG=CIRCFCHN;    /* INDICATE CIRCULAR CHAIN       */ 01593000
         LA    R9,6                                             DSK1171 01594000
*             RESPECIFY                                         03S0327 01595000
*              (WRKREG,                                         03S0327 01596000
*               WRKRG2) UNRSTD;                                 03S0327 01597000
*                                                               03S0327 01598000
@RF00325 DS    0H                                               03S0328 01599000
*/********************************************************************/ 01600000
*/* END OF CIRCHEK -                                                 */ 01601000
*/*      OUTPUT -                                                    */ 01602000
*/*       WRKRG2 (R4) - VOLATILE                                     */ 01603000
*/*       WRKREG (R3) - VOLATILE                                     */ 01604000
*/*       ERRREG (R9) - 6, IF THE QUEUE IS CIRCULAR.                 */ 01605000
*/********************************************************************/ 01606000
*                                                               03S0328 01607000
*                                                               02S0328 01608000
*             /*******************************************************/ 01609000
*             /*                                                     */ 01610000
*             /* IF THE QUEUE IS CIRCULAR, ERRREG WILL CONTAIN THE   */ 01611000
*             /* VALUE 6.                                            */ 01612000
*             /*                                                     */ 01613000
*             /*******************************************************/ 01614000
*                                                               02S0328 01615000
*             IF ERRREG=0           /* IF NOT CIRCULAR               */ 01616000
*               THEN                                            02S0328 01617000
         LTR   R9,R9                                            DSK1171 01618000
         BNZ   @RC00305                                         DSK1171 01619000
*               DO;                                             02S0329 01620000
*                 IF QTYPE=3        /* IF DOUBLE-THREADED            */ 01621000
*                   THEN                                        02S0330 01622000
         CLI   QTYPE(R2),3                                      DSK1171 01623000
         BNE   @RF00330                                         02S0330 01624000
*                   DO;                                         02S0331 01625000
*                                                               02S0331 01626000
*                     /***********************************************/ 01627000
*                     /*                                             */ 01628000
*                     /* FIX THE NEXT ELEMENT ON THE QUEUE           */ 01629000
*                     /*                                             */ 01630000
*                     /***********************************************/ 01631000
*                                                               02S0332 01632000
*                                                               03S0332 01633000
*/*  FIXNEXT - THIS SEGMENT INSURES THAT ON A DOUBLE-THREADED   03S0332 01634000
*    QUEUE THE NEXT ELEMENT ON THE QUEUE  POINTS BACK TO THE    03S0332 01635000
*    CURRENT ELEMENT ON THE QUEUE.  IF THIS IS A FORWARD SCAN,  03S0332 01636000
*    IT WILL INSURE THAT THE BACKWARD POINTER OF THE NEXT       03S0332 01637000
*    ELEMENT POINTS TO THE CURRENT.  IF THIS IS A BACKWARD      03S0332 01638000
*    SCAN, IT WILL INSURE THAT THE FORWARD POINTER OF THE       03S0332 01639000
*    PREVIOUS ELEMENT POINTS TO THE CURRENT.                         */ 01640000
*                                                               03S0332 01641000
*                     IF(NEXT+FBOFFSET(NDIR))->PTR24^=CURRENT3/* IF     01642000
*                                      THE NEXT ELEMENT DOES NOT        01643000
*                                      POINT BACK TO THE CURRENT     */ 01644000
*                       THEN                                    03S0332 01645000
         SLR   R3,R3                                            DSK1171 01646000
         IC    R3,NDIR(,R2)                                     DSK1171 01647000
         MH    R3,@CH00032                                      DSK1171 01648000
         L     R15,QVPLPTR(,R13)                                DSK1171 01649000
         LH    R3,QVPLFPTR-QVPLNOEL(R3,R15)                     DSK1171 01650000
         N     R3,@CF00274                                      DSK1171 01651000
         AL    R3,NEXT(,R2)                                     DSK1171 01652000
         CLC   PTR24(3,R3),CURRENT3(R2)                         DSK1171 01653000
         BE    @RF00332                                         03S0332 01654000
*                       DO;                                     03S0333 01655000
*                         ERRPARM=BADNEXT+(DIR-1);/* INDICATE CHAIN     01656000
*                                      IN NEXT OR PREVIOUS IS BAD    */ 01657000
         LA    R3,7                                             DSK1171 01658000
         SLR   R0,R0                                            DSK1171 01659000
         IC    R0,DIR(,R2)                                      DSK1171 01660000
         ALR   R3,R0                                            DSK1171 01661000
         STC   R3,ERRPARM(,R2)                                  DSK1171 01662000
*                         CORRECT=CURRENT3;/* CORRECT CHAIN TO POINT    01663000
*                                      TO THE CURRENT                */ 01664000
         L     R3,CURRENT3-1(,R2)                               DSK1171 01665000
         LA    R3,0(,R3)                                        DSK1171 01666000
         ST    R3,CORRECT(,R2)                                  DSK1171 01667000
*                         ERRELM=NEXT3;/* INDICATE ADDRESS OF ELEMENT   01668000
*                                      WITH ERROR                    */ 01669000
         MVC   ERRELM(3,R2),NEXT3(R2)                           DSK1171 01670000
*                         CALL RECORD;/* RECORD AND REPAIR ERROR     */ 01671000
         BAL   R14,RECORD                                       DSK1171 01672000
*                       END;                                    03S0338 01673000
*                   END;                                        02S0339 01674000
*                                                               02S0339 01675000
@RF00332 DS    0H                                               02S0340 01676000
*                 /***************************************************/ 01677000
*                 /*                                                 */ 01678000
*                 /* MOVE TO NEXT ELEMENT                            */ 01679000
*                 /*                                                 */ 01680000
*                 /***************************************************/ 01681000
*                                                               02S0340 01682000
*                 CURRENT=NEXT;                                 02S0340 01683000
@RF00330 L     R3,NEXT(,R2)                                     DSK1171 01684000
         ST    R3,CURRENT(,R2)                                  DSK1171 01685000
*                 NEXT=(CURRENT+FBOFFSET(DIR))->PTR31;          02S0341 01686000
         SLR   R15,R15                                          DSK1171 01687000
         IC    R15,DIR(,R2)                                     DSK1171 01688000
         MH    R15,@CH00032                                     DSK1171 01689000
         L     R14,QVPLPTR(,R13)                                DSK1171 01690000
         LH    R15,QVPLFPTR-QVPLNOEL(R15,R14)                   DSK1171 01691000
         N     R15,@CF00274                                     DSK1171 01692000
         ALR   R3,R15                                           DSK1171 01693000
         L     R3,PTR31(,R3)                                    DSK1171 01694000
         ST    R3,NEXT(,R2)                                     DSK1171 01695000
*                 COUNT=COUNT+1;    /* INCREMENT COUNT OF ELEMENTS.     01696000
*                                      THIS COUNT IS USED WHEN  02S0342 01697000
*                                      CHECKING FOR CIRCULARITY.     */ 01698000
         LA    R3,1                                             DSK1171 01699000
         L     R0,COUNT-1(,R2)                                  DSK1171 01700000
         ICM   R0,8,@CB00272                                    DSK1171 01701000
         ALR   R3,R0                                            DSK1171 01702000
         STCM  R3,7,COUNT(R2)                                   DSK1171 01703000
*               END;                                            02S0343 01704000
*           END;                                                02S0344 01705000
*         ELSE                      /* A BAD CHAIN- A RETURN CODE OF    01706000
*                                      8 FROM THE EVR                */ 01707000
*           ERRREG=BADFCHN;                                     02S0345 01708000
         B     @RC00305                                         DSK1171 01709000
@RF00315 LA    R9,4                                             DSK1171 01710000
*       END;                                                    02S0346 01711000
*     ELSE                          /* CHAIN IS ZERO AND IT SHOULD      01712000
*                                      NOT BE                        */ 01713000
*       ERRREG=BADFCHN;                                         02S0347 01714000
         B     @RC00305                                         02S0347 01715000
@RF00305 LA    R9,4                                             DSK1171 01716000
*   END;                                                        02S0348 01717000
@RC00305 DS    0H                                               02S0348 01718000
@DE00304 LTR   R9,R9                                            DSK1171 01719000
         BNZ   @DC00304                                         02S0348 01720000
         SLR   R3,R3                                            DSK1171 01721000
         IC    R3,DIR(,R2)                                      DSK1171 01722000
         MH    R3,@CH00032                                      DSK1171 01723000
         L     R15,QVPLPTR(,R13)                                DSK1171 01724000
         ALR   R3,R15                                           DSK1171 01725000
         CLC   NEXT3(3,R2),QVPLLELM+1-QVPLNOEL(R3)              DSK1171 01726000
         BNE   @DL00304                                         02S0348 01727000
         SLR   R3,R3                                            DSK1171 01728000
         IC    R3,DIR(,R2)                                      DSK1171 01729000
         MH    R3,@CH00032                                      DSK1171 01730000
         ALR   R3,R15                                           DSK1171 01731000
         TM    QVPLFLGF-QVPLNOEL(R3),QVPLFP3                    DSK1171 01732000
         BNZ   @DC00304                                         02S0348 01733000
         SLR   R3,R3                                            DSK1171 01734000
         IC    R3,DIR(,R2)                                      DSK1171 01735000
         MH    R3,@CH00032                                      DSK1171 01736000
         L     R0,NEXT(,R2)                                     DSK1171 01737000
         C     R0,QVPLLELM-QVPLNOEL(R3,R15)                     DSK1171 01738000
         BNE   @DL00304                                         02S0348 01739000
@DC00304 DS    0H                                               02S0349 01740000
*   LSTFOUND(DIR)=CURRENT;          /* INDICATE ADDRESS OF LAST 02S0349 01741000
*                                      ELEMENT FOUND ON THE SCAN     */ 01742000
         LA    R3,5                                             DSK1171 01743000
         SLR   R5,R5                                            DSK1171 01744000
         IC    R5,DIR(,R2)                                      DSK1171 01745000
         MR    R4,R3                                            DSK1171 01746000
         L     R0,CURRENT(,R2)                                  DSK1171 01747000
         ALR   R5,R2                                            DSK1171 01748000
         AL    R5,@CF00275                                      DSK1171 01749000
         STCM  R0,7,LSTFOUND-2(R5)                              DSK1171 01750000
*   IF ERRREG^=0                    /* IF ERROR ON SCAN              */ 01751000
*     THEN                                                      02S0350 01752000
         LTR   R9,R9                                            DSK1171 01753000
         BZ    @RF00350                                         02S0350 01754000
*     ERRVAL(DIR)=ERRREG+DIR-1;     /* CONVERT ERROR CODE            */ 01755000
         SLR   R15,R15                                          DSK1171 01756000
         IC    R15,DIR(,R2)                                     DSK1171 01757000
         LR    R5,R3                                            DSK1171 01758000
         MR    R4,R15                                           DSK1171 01759000
         ALR   R15,R9                                           DSK1171 01760000
         BCTR  R15,0                                            DSK1171 01761000
         AL    R5,@CF00276                                      DSK1171 01762000
         STC   R15,ERRVAL-1(R5,R2)                              DSK1171 01763000
*   RESPECIFY                                                   02S0352 01764000
*     R14 RSTD;                                                 02S0352 01765000
@RF00350 DS    0H                                               02S0353 01766000
*   R14=SAVERET1;                   /* RESTORE RETURN REGISTER       */ 01767000
         LR    R14,R8                                           DSK1171 01768000
*   END SCAN;                                                   02S0354 01769000
@EL00002 DS    0H                                               02S0354 01770000
@EF00002 DS    0H                                               02S0354 01771000
@ER00002 BR    R14                                              DSK1171 01772000
*   RESPECIFY                                                   02S0355 01773000
*     R14 UNRSTD;                                               02S0355 01774000
*                                                               02S0356 01775000
*/****************************************************************** */ 01776000
*/*     RECORD -                                                     */ 01777000
*/*  THIS SUBROUTINE HANDLES RECORDING OF ERRORS AS WELL AS          */ 01778000
*/* CORRECTION OF ANY ERRORS IN  THE CHAIN INFORMATION.              */ 01779000
*/* IT WILL INCREMENT THE COUNT OF ERRORS DETECTED, AND IF           */ 01780000
*/* RECORDING IS DONE, WILL INCREMENT THE COUNT OF RECORDED ERRORS.  */ 01781000
*/* IT WILL ALSO UPDATE THE RETURN CODE VALUE TO INDICATE THE HIGHEST*/ 01782000
*/* SEVERITY ERROR DETECTED SO FAR.                                  */ 01783000
*/*      INPUT:                                                      */ 01784000
*/*       ERRPARM = CONTAINS A CODE INDICATING THE SPECIFIC          */ 01785000
*/*         ERROR.                                                   */ 01786000
*/*        OTHER STANDARD INPUT (SEE SEGMENT INIT)                   */ 01787000
*/*                                                                  */ 01788000
*/*       IF THIS IS AN ERROR IN THE FORWARD OR BACKWARD CHAIN       */ 01789000
*/*        FIELD, THEN ERRELM CONTAINS THE ADDRESS OF THE BAD        */ 01790000
*/*        ELEMENT AND CORRECT CONTAINS THE VALUE THAT THE           */ 01791000
*/*        CHAIN FIELD SHOULD CONTAIN.                               */ 01792000
*/*                                                                  */ 01793000
*/*      IF THE QUEUE HEADER IS BAD OR THE QUEUE TRAILER IS BAD,     */ 01794000
*/*      THEN CORRECT CONTAINS THE VALUE THAT SHOULD BE IN THAT FIELD.  01795000
*                                                                    */ 01796000
*/********************************************************************/ 01797000
*                                                               02S0356 01798000
*RECORD:                                                        02S0356 01799000
*   PROC OPTIONS(NOSAVE NOSAVEAREA);                            02S0356 01800000
RECORD   DS    0H                                               02S0357 01801000
*   RESPECIFY                                                   02S0357 01802000
*     R14 RSTD;                                                 02S0357 01803000
*   SAVERET2=R14;                   /* SAVE RETURN REGISTER          */ 01804000
         LR    R10,R14                                          DSK1171 01805000
*   RESPECIFY                                                   02S0359 01806000
*     R14 UNRSTD;                                               02S0359 01807000
*   NDET=NDET+1;                    /* BUMP CT OF DETECTED ERRORS    */ 01808000
*                                                               02S0360 01809000
         LA    R3,1                                             DSK1171 01810000
         SLR   R0,R0                                            DSK1171 01811000
         IC    R0,NDET(,R13)                                    DSK1171 01812000
         ALR   R3,R0                                            DSK1171 01813000
         STC   R3,NDET(,R13)                                    DSK1171 01814000
*   /*****************************************************************/ 01815000
*   /*                                                               */ 01816000
*   /* UPDATE THE ERROR SVERITY INDICATION FOR OUTPUT REGISTER 15.   */ 01817000
*   /*                                                               */ 01818000
*   /*****************************************************************/ 01819000
*                                                               02S0361 01820000
*   IF ERRPARM>BADDATA              /* IF ERROR MORE SEVERE THAN BAD    01821000
*                                      DATA                          */ 01822000
*     THEN                                                      02S0361 01823000
         CLI   ERRPARM(R2),1                                    DSK1171 01824000
         BNH   @RF00361                                         02S0361 01825000
*     ERRCODE=8;                                                02S0362 01826000
         MVI   ERRCODE(R13),X'08'                               02S0362 01827000
*   ELSE                                                        02S0363 01828000
*     IF ERRCODE^=8                 /* IF HIGHER SEVERITY NOT YET       01829000
*                                      FOUND                         */ 01830000
*       THEN                                                    02S0363 01831000
         B     @RC00361                                         02S0363 01832000
@RF00361 CLI   ERRCODE(R13),8                                   02S0363 01833000
         BE    @RF00363                                         02S0363 01834000
*       ERRCODE=4;                  /* INDICATE DATA ERROR           */ 01835000
*                                                               02S0364 01836000
         MVI   ERRCODE(R13),X'04'                               02S0364 01837000
*   /*****************************************************************/ 01838000
*   /*                                                               */ 01839000
*   /* TEST FOR OVERFLOW OF RECORDING AREA.                          */ 01840000
*   /*                                                               */ 01841000
*   /*****************************************************************/ 01842000
*                                                               02S0365 01843000
*   IF QVPLODA=0×LENGTH(QVODENT)>QVODSIZE-(LENGTH(QVODCMMN)+QVODUSED+   01844000
*       LENGTH(QVODENT)*NREC)       /* IF THERE IS NO SPACE TO RECORD*/ 01845000
*     THEN                                                      02S0365 01846000
@RF00363 DS    0H                                               02S0365 01847000
@RC00361 L     R3,QVPLPTR(,R13)                                 DSK1171 01848000
         L     R3,QVPLODA-QVPL(,R3)                             DSK1171 01849000
         LTR   R3,R3                                            DSK1171 01850000
         BZ    @RT00365                                         02S0365 01851000
         LA    R0,4                                             DSK1171 01852000
         SLR   R15,R15                                          DSK1171 01853000
         IC    R15,QVODUSED-QVODHDR(,R3)                        DSK1171 01854000
         ALR   R0,R15                                           DSK1171 01855000
         SLR   R15,R15                                          DSK1171 01856000
         IC    R15,NREC(,R13)                                   DSK1171 01857000
         SLA   R15,4                                            DSK1171 01858000
         ALR   R0,R15                                           DSK1171 01859000
         LCR   R0,R0                                            DSK1171 01860000
         SLR   R15,R15                                          DSK1171 01861000
         IC    R15,QVODSIZE-QVODHDR(,R3)                        DSK1171 01862000
         ALR   R0,R15                                           DSK1171 01863000
         C     R0,@CF00127                                      DSK1171 01864000
         BNL   @RF00365                                         02S0365 01865000
@RT00365 DS    0H                                               02S0366 01866000
*     ERR2MANY=YES;                 /* INDICATE OVERFLOW             */ 01867000
         OI    ERR2MANY(R13),B'10000000'                        02S0366 01868000
*   ELSE                            /* ROOM TO RECORD                */ 01869000
*     DO;                                                       02S0367 01870000
         B     @RC00365                                         02S0367 01871000
@RF00365 DS    0H                                               02S0368 01872000
*       NREC=NREC+1;                /* BUMP RECORDED COUNT FOR OUTPUT   01873000
*                                      REGISTER 15.                  */ 01874000
         LA    R3,1                                             DSK1171 01875000
         SLR   R0,R0                                            DSK1171 01876000
         IC    R0,NREC(,R13)                                    DSK1171 01877000
         ALR   R3,R0                                            DSK1171 01878000
         STC   R3,NREC(,R13)                                    DSK1171 01879000
*       QVODCDAT(NREC)=CDAT(ERRPARM);/* RECORD CONSTANT DATA         */ 01880000
         SLA   R3,4                                             DSK1171 01881000
         L     R15,QVPLPTR(,R13)                                DSK1171 01882000
         L     R15,QVPLODA-QVPL(,R15)                           DSK1171 01883000
         LA    R14,4                                            DSK1171 01884000
         ALR   R14,R15                                          DSK1171 01885000
         SLR   R7,R7                                            DSK1171 01886000
         IC    R7,QVODUSED-QVODHDR(,R15)                        DSK1171 01887000
         ALR   R14,R7                                           DSK1171 01888000
         ALR   R14,R3                                           DSK1171 01889000
         AL    R14,@CF00277                                     DSK1171 01890000
         SLR   R3,R3                                            DSK1171 01891000
         IC    R3,ERRPARM(,R2)                                  DSK1171 01892000
         SLA   R3,2                                             DSK1171 01893000
         LA    R15,CDAT-4(R3)                                   DSK1171 01894000
         MVC   QVODCDAT-QVODCDAT(4,R14),0(R15)                  DSK1171 01895000
*     END;                                                      02S0370 01896000
*   RESPECIFY                                                   02S0371 01897000
*     WRKREG RSTD;                                              02S0371 01898000
@RC00365 DS    0H                                               02S0372 01899000
*   IF ERRC(ERRPARM)=8              /* IF HEADER BAD                 */ 01900000
*     THEN                                                      02S0372 01901000
*                                                               02S0372 01902000
         SLR   R15,R15                                          DSK1171 01903000
         IC    R15,ERRPARM(,R2)                                 DSK1171 01904000
         SLA   R15,2                                            DSK1171 01905000
         SLR   R0,R0                                            DSK1171 01906000
         IC    R0,ERRC-4(R15)                                   DSK1171 01907000
         C     R0,@CF00058                                      DSK1171 01908000
         BNE   @RF00372                                         02S0372 01909000
*     /***************************************************************/ 01910000
*     /*                                                             */ 01911000
*     /* A BAD HEADER                                                */ 01912000
*     /*                                                             */ 01913000
*     /***************************************************************/ 01914000
*                                                               02S0373 01915000
*     DO;                                                       02S0373 01916000
*       ERRELM=QVPLHDR;             /* SET ADDR OF HEADER            */ 01917000
         L     R15,QVPLPTR(,R13)                                DSK1171 01918000
         L     R0,QVPLHDR-QVPL(,R15)                            DSK1171 01919000
         STCM  R0,7,ERRELM(R2)                                  DSK1171 01920000
*       LEN3BYTE=QVPLFLGH;          /* SET LENGTH INDIC              */ 01921000
         MVC   LEN3BYTE(1,R2),QVPLFLGH-QVPL(R15)                DSK1171 01922000
*       WRKREG=ERRELM;              /* SET PTR TO BAD FIELD          */ 01923000
         LR    R3,R0                                            DSK1171 01924000
*     END;                                                      02S0377 01925000
*   ELSE                                                        02S0378 01926000
*     IF ERRC(ERRPARM)=12           /* IF BAD TRAILER                */ 01927000
*       THEN                                                    02S0378 01928000
*                                                               02S0378 01929000
         B     @RC00372                                         02S0378 01930000
@RF00372 SLR   R15,R15                                          DSK1171 01931000
         IC    R15,ERRPARM(,R2)                                 DSK1171 01932000
         SLA   R15,2                                            DSK1171 01933000
         SLR   R0,R0                                            DSK1171 01934000
         IC    R0,ERRC-4(R15)                                   DSK1171 01935000
         C     R0,@CF00032                                      DSK1171 01936000
         BNE   @RF00378                                         02S0378 01937000
*       /*************************************************************/ 01938000
*       /*                                                           */ 01939000
*       /* A BAD TRAILER                                             */ 01940000
*       /*                                                           */ 01941000
*       /*************************************************************/ 01942000
*                                                               02S0379 01943000
*       DO;                                                     02S0379 01944000
*         ERRELM=QVPLTRLR;          /* SET ADDR OF TRAILER           */ 01945000
         L     R15,QVPLPTR(,R13)                                DSK1171 01946000
         L     R0,QVPLTRLR-QVPL(,R15)                           DSK1171 01947000
         STCM  R0,7,ERRELM(R2)                                  DSK1171 01948000
*         WRKREG=ERRELM;            /* SET ADDR OF BAD FIELD         */ 01949000
         LR    R3,R0                                            DSK1171 01950000
*         LEN3BYTE=QVPLFLGT;        /* SET LENGTH INDIC              */ 01951000
         MVC   LEN3BYTE(1,R2),QVPLFLGT-QVPL(R15)                DSK1171 01952000
*       END;                                                    02S0383 01953000
*     ELSE                                                      02S0384 01954000
*       IF ERRC(ERRPARM)=16         /* IF BAD FORWARD CHAIN          */ 01955000
*         THEN                                                  02S0384 01956000
*                                                               02S0384 01957000
         B     @RC00378                                         02S0384 01958000
@RF00378 SLR   R15,R15                                          DSK1171 01959000
         IC    R15,ERRPARM(,R2)                                 DSK1171 01960000
         SLA   R15,2                                            DSK1171 01961000
         SLR   R0,R0                                            DSK1171 01962000
         IC    R0,ERRC-4(R15)                                   DSK1171 01963000
         C     R0,@CF00127                                      DSK1171 01964000
         BNE   @RF00384                                         02S0384 01965000
*         /***********************************************************/ 01966000
*         /*                                                         */ 01967000
*         /* A BAD FORWARD CHAIN                                     */ 01968000
*         /*                                                         */ 01969000
*         /***********************************************************/ 01970000
*                                                               02S0385 01971000
*         DO;                                                   02S0385 01972000
*           LEN3BYTE=QVPLFLGF;      /* SET LENGTH INDIC              */ 01973000
         L     R15,QVPLPTR(,R13)                                DSK1171 01974000
         MVC   LEN3BYTE(1,R2),QVPLFLGF-QVPL(R15)                DSK1171 01975000
*           WRKREG=ERRELM+QVPLFPTR; /* SET ADDR OF BAD FIELD         */ 01976000
         L     R3,ERRELM-1(,R2)                                 DSK1171 01977000
         LA    R3,0(,R3)                                        DSK1171 01978000
         AH    R3,QVPLFPTR-QVPL(,R15)                           DSK1171 01979000
*         END;                                                  02S0388 01980000
*       ELSE                                                    02S0389 01981000
*         IF ERRC(ERRPARM)=20       /* IF BAD BACK CHAIN             */ 01982000
*           THEN                                                02S0389 01983000
         B     @RC00384                                         02S0389 01984000
@RF00384 SLR   R15,R15                                          DSK1171 01985000
         IC    R15,ERRPARM(,R2)                                 DSK1171 01986000
         SLA   R15,2                                            DSK1171 01987000
         SLR   R0,R0                                            DSK1171 01988000
         IC    R0,ERRC-4(R15)                                   DSK1171 01989000
         C     R0,@CF00267                                      DSK1171 01990000
         BNE   @RF00389                                         02S0389 01991000
*           DO;                                                 02S0390 01992000
*                                                               02S0390 01993000
*             /*******************************************************/ 01994000
*             /*                                                     */ 01995000
*             /* A BAD BACKWARD CHAIN                                */ 01996000
*             /*                                                     */ 01997000
*             /*******************************************************/ 01998000
*                                                               02S0391 01999000
*             LEN3BYTE=QVPLFLGB;    /* SET LENGTH                    */ 02000000
         L     R15,QVPLPTR(,R13)                                DSK1171 02001000
         MVC   LEN3BYTE(1,R2),QVPLFLGB-QVPL(R15)                DSK1171 02002000
*             WRKREG=ERRELM+QVPLBPTR;/* SET ADDR OF                  */ 02003000
         L     R3,ERRELM-1(,R2)                                 DSK1171 02004000
         LA    R3,0(,R3)                                        DSK1171 02005000
         AH    R3,QVPLBPTR-QVPL(,R15)                           DSK1171 02006000
*           END;                    /* BAD FIELD                     */ 02007000
*   IF ERRC(ERRPARM)^=4             /* IF NOT A DATA ERROR           */ 02008000
*     THEN                                                      02S0394 02009000
*                                                               02S0394 02010000
@RF00389 DS    0H                                               02S0394 02011000
@RC00384 DS    0H                                               02S0394 02012000
@RC00378 DS    0H                                               02S0394 02013000
@RC00372 LA    R15,4                                            DSK1171 02014000
         SLR   R14,R14                                          DSK1171 02015000
         IC    R14,ERRPARM(,R2)                                 DSK1171 02016000
         SLA   R14,2                                            DSK1171 02017000
         SLR   R0,R0                                            DSK1171 02018000
         IC    R0,ERRC-4(R14)                                   DSK1171 02019000
         CR    R15,R0                                           DSK1171 02020000
         BE    @RF00394                                         02S0394 02021000
*     /***************************************************************/ 02022000
*     /*                                                             */ 02023000
*     /* THIS IS NOT A DATA ERROR- I.E., THE CHAIN IS BAD AT SOME    */ 02024000
*     /* POINT. THIS IS NOT A DEQUEUEING OPERATION.                  */ 02025000
*     /*                                                             */ 02026000
*     /***************************************************************/ 02027000
*                                                               02S0395 02028000
*     DO;                                                       02S0395 02029000
*       IF ERR2MANY=NO              /* IF THERE IS SPACE             */ 02030000
*         THEN                                                  02S0396 02031000
         TM    ERR2MANY(R13),B'10000000'                        02S0396 02032000
         BNZ   @RF00396                                         02S0396 02033000
*         DO;                                                   02S0397 02034000
*                                                               02S0397 02035000
*           /*********************************************************/ 02036000
*           /*                                                       */ 02037000
*           /* RECORD IN THE ERROR ENTRY (A) THE ADDRESS OF THE BAD  */ 02038000
*           /* HEADER ,TRAILER, OR QUEUE ELEMENT AND (B) THE INVALID */ 02039000
*           /* CONTENTS.                                             */ 02040000
*           /*                                                       */ 02041000
*           /*********************************************************/ 02042000
*                                                               02S0398 02043000
*           QVODVW1(NREC)=ERRELM;   /* RECORD ADDR OF BAD ELEM       */ 02044000
         SLR   R14,R14                                          DSK1171 02045000
         IC    R14,NREC(,R13)                                   DSK1171 02046000
         SLA   R14,4                                            DSK1171 02047000
         L     R7,QVPLPTR(,R13)                                 DSK1171 02048000
         L     R7,QVPLODA-QVPL(,R7)                             DSK1171 02049000
         ALR   R15,R7                                           DSK1171 02050000
         SLR   R6,R6                                            DSK1171 02051000
         IC    R6,QVODUSED-QVODHDR(,R7)                         DSK1171 02052000
         ALR   R15,R6                                           DSK1171 02053000
         L     R0,ERRELM-1(,R2)                                 DSK1171 02054000
         ICM   R0,8,@CB00272                                    DSK1171 02055000
         LA    R7,0(R14,R15)                                    DSK1171 02056000
         AL    R7,@CF00278                                      DSK1171 02057000
         ST    R0,QVODVW1-QVODVW1(,R7)                          DSK1171 02058000
*           QVODVW2(NREC)=WRKREG->PTR31;/* RECORD BAD VALUE          */ 02059000
         L     R0,PTR31(,R3)                                    DSK1171 02060000
         AL    R15,@CF00276                                     DSK1171 02061000
         ST    R0,QVODVW2-QVODVW2(R14,R15)                      DSK1171 02062000
*         END;                                                  02S0400 02063000
*                                                               02S0400 02064000
*       /*************************************************************/ 02065000
*       /*                                                           */ 02066000
*       /* CORRECT THE BAD FIELD                                     */ 02067000
*       /*                                                           */ 02068000
*       /*************************************************************/ 02069000
*                                                               02S0401 02070000
*       IF LEN3=YES                 /* IF 3-BYTE LENGTH              */ 02071000
*         THEN                                                  02S0401 02072000
@RF00396 TM    LEN3(R2),B'10000000'                             DSK1171 02073000
         BNO   @RF00401                                         02S0401 02074000
*         WRKREG->PTR24=CORRECT;    /* FIX 3 BYTES                   */ 02075000
         MVC   PTR24(3,R3),CORRECT+1(R2)                        DSK1171 02076000
*       ELSE                                                    02S0403 02077000
*         WRKREG->PTR31=CORRECT;    /* FIX 4 BYTES                   */ 02078000
         B     @RC00401                                         02S0403 02079000
@RF00401 L     R0,CORRECT(,R2)                                  DSK1171 02080000
         ST    R0,PTR31(,R3)                                    DSK1171 02081000
*       IF ERR2MANY=NO              /* IF SPACE AVAILABLE            */ 02082000
*         THEN                                                  02S0404 02083000
@RC00401 TM    ERR2MANY(R13),B'10000000'                        02S0404 02084000
         BNZ   @RC00394                                         DSK1171 02085000
*         DO;                                                   02S0405 02086000
*                                                               02S0405 02087000
*           /*********************************************************/ 02088000
*           /*                                                       */ 02089000
*           /* RECORD THE NEW VALUE                                  */ 02090000
*           /*                                                       */ 02091000
*           /*********************************************************/ 02092000
*                                                               02S0406 02093000
*           QVODVW3(NREC)=WRKREG->PTR31;/* RECORD NEW VALUE          */ 02094000
         SLR   R15,R15                                          DSK1171 02095000
         IC    R15,NREC(,R13)                                   DSK1171 02096000
         SLA   R15,4                                            DSK1171 02097000
         L     R14,QVPLPTR(,R13)                                DSK1171 02098000
         L     R14,QVPLODA-QVPL(,R14)                           DSK1171 02099000
         LA    R7,4                                             DSK1171 02100000
         ALR   R7,R14                                           DSK1171 02101000
         SLR   R6,R6                                            DSK1171 02102000
         IC    R6,QVODUSED-QVODHDR(,R14)                        DSK1171 02103000
         ALR   R7,R6                                            DSK1171 02104000
         L     R0,PTR31(,R3)                                    DSK1171 02105000
         ST    R0,QVODVW3-QVODVW3(R15,R7)                       DSK1171 02106000
*           RESPECIFY                                           02S0407 02107000
*             WRKREG UNRSTD;                                    02S0407 02108000
*         END;                                                  02S0408 02109000
*     END;                                                      02S0409 02110000
*   ELSE                            /* THIS IS A DATA ERROR          */ 02111000
*                                                               02S0410 02112000
*     /***************************************************************/ 02113000
*     /*                                                             */ 02114000
*     /* THIS IS A DATA ERROR (ERROR CODE EQUAL TO 4). AN ELEMENT HAS*/ 02115000
*     /* BEEN DEQUEUED.                                              */ 02116000
*     /*                                                             */ 02117000
*     /***************************************************************/ 02118000
*                                                               02S0410 02119000
*     IF ERR2MANY=NO                /* IF SPACE TO RECORD            */ 02120000
*       THEN                                                    02S0410 02121000
         B     @RC00394                                         02S0410 02122000
@RF00394 TM    ERR2MANY(R13),B'10000000'                        02S0410 02123000
         BNZ   @RF00410                                         02S0410 02124000
*       DO;                                                     02S0411 02125000
*                                                               02S0411 02126000
*         /***********************************************************/ 02127000
*         /*                                                         */ 02128000
*         /* RECORD THE ADDRESS OF THE DEQUEUED ELEMENT, THE ADDRESS */ 02129000
*         /* OF THE PREVIOUS ELEMENT, AND THE ADDRESS OF THE NEXT    */ 02130000
*         /* ELEMENT.                                                */ 02131000
*         /*                                                         */ 02132000
*         /***********************************************************/ 02133000
*                                                               02S0412 02134000
*         QVODVW1(NREC)=ERRELM;     /* RECORD ADDR OF ELEM           */ 02135000
         SLR   R3,R3                                            DSK1171 02136000
         IC    R3,NREC(,R13)                                    DSK1171 02137000
         SLA   R3,4                                             DSK1171 02138000
         L     R15,QVPLPTR(,R13)                                DSK1171 02139000
         L     R15,QVPLODA-QVPL(,R15)                           DSK1171 02140000
         LA    R14,4                                            DSK1171 02141000
         ALR   R14,R15                                          DSK1171 02142000
         SLR   R7,R7                                            DSK1171 02143000
         IC    R7,QVODUSED-QVODHDR(,R15)                        DSK1171 02144000
         ALR   R14,R7                                           DSK1171 02145000
         L     R0,ERRELM-1(,R2)                                 DSK1171 02146000
         ICM   R0,8,@CB00272                                    DSK1171 02147000
         LA    R15,0(R3,R14)                                    DSK1171 02148000
         AL    R15,@CF00278                                     DSK1171 02149000
         ST    R0,QVODVW1-QVODVW1(,R15)                         DSK1171 02150000
*         QVODVW2(NREC)=PREV;       /* RECORD ADDR OF PREVIOUS       */ 02151000
         LA    R15,0(R3,R14)                                    DSK1171 02152000
         AL    R15,@CF00276                                     DSK1171 02153000
         ST    R11,QVODVW2-QVODVW2(,R15)                        DSK1171 02154000
*         QVODVW3(NREC)=NEXT;       /* RECORD ADDR OF NEXT           */ 02155000
         L     R0,NEXT(,R2)                                     DSK1171 02156000
         ST    R0,QVODVW3-QVODVW3(R3,R14)                       DSK1171 02157000
*       END;                                                    02S0415 02158000
*   RESPECIFY                                                   02S0416 02159000
*     R14 RSTD;                                                 02S0416 02160000
@RF00410 DS    0H                                               02S0416 02161000
@RC00394 DS    0H                                               02S0417 02162000
*   R14=SAVERET2;                   /* RESTORE RETURN REG            */ 02163000
         LR    R14,R10                                          DSK1171 02164000
*   END RECORD;                                                 02S0418 02165000
@EL00003 DS    0H                                               02S0418 02166000
@EF00003 DS    0H                                               02S0418 02167000
@ER00003 BR    R14                                              DSK1171 02168000
*   RESPECIFY                                                   02S0419 02169000
*     R14 UNRSTD;                                               02S0419 02170000
*   END IEAVEQV1                                                01S0420 02171000
*                                                               01S0420 02172000
*/********************************************************************/ 02173000
*                                                               01S0420 02174000
*                                                               01S0420 02175000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 02176000
*/*%INCLUDE SYSUT5  (PROLOG  )                                       */ 02177000
*/*%INCLUDE SYSUT5  (DECLARES)                                       */ 02178000
*/*%INCLUDE SYSLIB  (IHAQVPL )                                       */ 02179000
*/*%INCLUDE SYSLIB  (IHAQVOD )                                       */ 02180000
*/*%INCLUDE SYSUT5  (COMMON  )                                       */ 02181000
*/*%INCLUDE SYSUT5  (VALCHK  )                                       */ 02182000
*/*%INCLUDE SYSUT5  (INIT    )                                       */ 02183000
*/*%INCLUDE SYSUT5  (FIXLAST )                                       */ 02184000
*/*%INCLUDE SYSUT5  (FIXFIRST)                                       */ 02185000
*/*%INCLUDE SYSUT5  (FIXQ    )                                       */ 02186000
*/*%INCLUDE SYSUT5  (RMVBAD  )                                       */ 02187000
*/*%INCLUDE SYSUT5  (DQELM   )                                       */ 02188000
*/*%INCLUDE SYSUT5  (SCAN    )                                       */ 02189000
*/*%INCLUDE SYSUT5  (CIRCCHEK)                                       */ 02190000
*/*%INCLUDE SYSUT5  (FIXNEXT )                                       */ 02191000
*/*%INCLUDE SYSUT5  (RECORD  )                                       */ 02192000
*                                                               01S0420 02193000
*       ;                                                       01S0420 02194000
@DATA    DS    0H                                                       02195000
@CH00163 DC    H'5'                                                     02196000
@DATD    DSECT                                                          02197000
         DS    0F                                                       02198000
IEAVEQV1 CSECT                                                          02199000
         DC    X'0313'                       !!! SOURCE COMPARE FIX !!! 02200000
         DC    0F'0'                                            DSK1171 02200000
@CF00081 DC    F'1'                                                     02201000
@CF00111 DC    F'2'                                                     02202000
@CF00160 DC    F'3'                                                     02203000
@CF00133 DC    F'4'                                                     02204000
@CF00058 DC    F'8'                                                     02205000
@CF00032 DC    F'12'                                                    02206000
@CH00032 EQU   @CF00032+2                                               02207000
@CF00127 DC    F'16'                                                    02208000
@CF00267 DC    F'20'                                                    02209000
@CF00087 DC    F'24'                                                    02210000
@CF00277 DC    F'-12'                                                   02211000
@CF00278 DC    F'-8'                                                    02212000
@CF00273 DC    F'-5'                                                    02213000
@CF00276 DC    F'-4'                                                    02214000
@CF00275 DC    F'-3'                                                    02215000
@CF00152 DC    XL4'00000003'                                            02216000
@CF00274 DC    XL4'0000FFFF'                                            02217000
@DATD    DSECT                                                          02218000
         DS    0D                                                       02219000
@ENDDATD EQU   *                                                        02220000
IEAVEQV1 CSECT                                                          02221000
         NOPR  ((@ENDDATD-@DATD)*16)                                    02222000
         DC    0F'0'                                            DSK1171 02223000
@SIZDATD DC    AL1(0)                                                   02224000
         DC    AL3(@ENDDATD-@DATD)                                      02225000
         DS    0D                                                       02226000
@CB00272 DC    X'00'                                                    02227000
CDAT     DC    X'04040000'                                              02228000
         ORG   CDAT+0                                                   02229000
ERRC     DS    AL1                                                      02230000
ERRX     DS    AL1                                                      02231000
@NM00013 DS    CL2                                                      02232000
         ORG   CDAT+4                                                   02233000
         DC    X'08080000'                                              02234000
         ORG   CDAT+8                                                   02235000
         DC    X'0C0C0000'                                              02236000
         ORG   CDAT+12                                                  02237000
         DC    X'10100000'                                              02238000
         ORG   CDAT+16                                                  02239000
         DC    X'14140000'                                              02240000
         ORG   CDAT+20                                                  02241000
         DC    X'10180000'                                              02242000
         ORG   CDAT+24                                                  02243000
         DC    X'141C0000'                                              02244000
         ORG   CDAT+28                                                  02245000
         DC    X'14200000'                                              02246000
         ORG   CDAT+32                                                  02247000
         DC    X'10240000'                                              02248000
         ORG   CDAT+36                                                  02249000
         DC    X'10280000'                                              02250000
         ORG   CDAT+40                                                  02251000
         DC    X'142C0000'                                              02252000
         ORG   CDAT+44                                                  02253000
         CVT      DSECT=YES,LIST=YES                            DSK1171 02254000
         IHAQVPL ,                                              DSK1171 02254001
         IHAQVOD ,                                              DSK1171 02254002
R0       EQU   0                       REGISTER 0               DSK1171 02254003
R1       EQU   1                       REGISTER 1               DSK1171 02254004
R2       EQU   2                       REGISTER 2               DSK1171 02254005
R3       EQU   3                       REGISTER 3               DSK1171 02254006
R4       EQU   4                       REGISTER 4               DSK1171 02254007
R5       EQU   5                       REGISTER 5               DSK1171 02254008
R6       EQU   6                       REGISTER 6               DSK1171 02254009
R7       EQU   7                       REGISTER 7               DSK1171 02254010
R8       EQU   8                       REGISTER 8               DSK1171 02254011
R9       EQU   9                       REGISTER 9               DSK1171 02254012
R10      EQU   10                      REGISTER 10              DSK1171 02254013
R11      EQU   11                      REGISTER 11              DSK1171 02254014
R12      EQU   12                      REGISTER 12              DSK1171 02254015
R13      EQU   13                      REGISTER 13              DSK1171 02254016
R14      EQU   14                      REGISTER 14              DSK1171 02254017
R15      EQU   15                      REGISTER 15              DSK1171 02254018
SA       EQU   0                                                        02294000
S15      EQU   SA+16                                                    02295000
S0       EQU   SA+20                                                    02296000
S1       EQU   SA+24                                                    02297000
WKA      EQU   0                                                        02298000
FBDES    EQU   WKA                                                      02299000
FWDDES   EQU   FBDES                                                    02300000
@NM00002 EQU   FWDDES                                                   02301000
HQ       EQU   @NM00002                                                 02302000
HN       EQU   @NM00002                                                 02303000
ERRVAL1  EQU   FWDDES+1                                                 02304000
LASTFWD  EQU   FWDDES+2                                                 02305000
BWDDES   EQU   FBDES+5                                                  02306000
@NM00004 EQU   BWDDES                                                   02307000
TQ       EQU   @NM00004                                                 02308000
TN       EQU   @NM00004                                                 02309000
ERRVAL2  EQU   BWDDES+1                                                 02310000
LASTBAK  EQU   BWDDES+2                                                 02311000
QTYPE    EQU   WKA+10                                                   02312000
DIR      EQU   WKA+11                                                   02313000
NDIR     EQU   WKA+12                                                   02314000
COUNT    EQU   WKA+13                                                   02315000
ERRPARM  EQU   WKA+16                                                   02316000
LEN3BYTE EQU   WKA+17                                                   02317000
LEN3     EQU   LEN3BYTE                                                 02318000
CORRECT  EQU   WKA+20                                                   02319000
ERRELM   EQU   WKA+25                                                   02320000
CURRENT  EQU   WKA+28                                                   02321000
CURRENT3 EQU   CURRENT+1                                                02322000
NEXT     EQU   WKA+32                                                   02323000
NEXT3    EQU   NEXT+1                                                   02324000
ODA      EQU   0                                                        02366000
PTR31    EQU   0                                                        02367000
PTR24    EQU   PTR31+1                                                  02368000
EVR      EQU   0                                                        02369000
WKAFB    EQU   FBDES                                                    02370000
@NM00008 EQU   WKAFB                                                    02371000
HTQ      EQU   @NM00008                                                 02372000
ERRVAL   EQU   WKAFB+1                                                  02373000
LSTFOUND EQU   WKAFB+2                                                  02374000
QVPLPTR  EQU   S1                                                       02383000
ERRR15   EQU   S15                                                      02384000
ERR2MANY EQU   ERRR15                                                   02385000
NREC     EQU   ERRR15+1                                                 02386000
NDET     EQU   ERRR15+2                                                 02387000
ERRCODE  EQU   ERRR15+3                                                 02388000
@PB00003 EQU   @EL00001                                                 02431000
@PB00002 EQU   @PB00003                                                 02433000
@ENDDATA EQU   *                                                        02436000
         END   IEAVEQV1                                         DSK1171 02437000
