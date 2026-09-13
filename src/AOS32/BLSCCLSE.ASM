         TITLE 'BLSCCLSE -- IPCS DATA ACCESS SERVICES CLOSE EXECUTOR   *00001000
                        '                                               00002000
*     /* CHANGE ACTIVITY                                                00003000
*    THIS MODULE IS WRITTEN FOR @G57LPSR                                00004000
BLSCCLSE CSECT ,                                                   0002 00005000
@MAINENT DS    0H                                                  0002 00006000
         USING *,@15                                               0002 00007000
         B     @PROLOG                                             0002 00008000
         DC    AL1(16)                                             0002 00009000
         DC    C'BLSCCLSE  79.283'                              DSKC086 00010000
         DROP  @15                                                      00011000
@PROLOG  STM   @14,@12,12(@13)                                     0002 00012000
         BALR  @12,0                                               0002 00013000
@PSTART  DS    0H                                                  0002 00014000
         USING @PSTART,@12                                         0002 00015000
         L     @00,@SIZDATD                                        0002 00016000
         BLSCGETS R,LV=(0)                                              00017000
         LR    @11,@01                                             0002 00018000
         USING @DATD,@11                                           0002 00019000
         ST    @13,@SA00001+4                                      0002 00020000
         LM    @00,@01,20(@13)                                     0002 00021000
         ST    @11,8(,@13)                                         0002 00022000
         LR    @13,@11                                             0002 00023000
*   CBPTR=GPR01P;                   /* GET ADDRESSABILITY TO THE DMCB*/ 00024000
         LR    @05,@01                                          DSKC086 00025000
*   RFY                                                            0016 00026000
*     GPR01P UNRSTD;                                               0016 00027000
*   MODNAME=LMODNMC;                /* MARK AUTOMATIC AREA           */ 00028000
         MVC   MODNAME(8),@CC00339                                 0017 00029000
*   DMCBRTC=F0C;                    /* INIT THE RETURN CODE          */ 00030000
         SLR   @10,@10                                             0018 00031000
         ST    @10,DMCBRTC(,@05)                                DSKC086 00032000
*   DMCBREJ=F0C;                    /* REJECT REASON                 */ 00033000
         MVI   DMCBREJ(@05),X'00'                               DSKC086 00034000
*   DMCBACBE=F0C;                   /* ACB ERROR REASON FIELD        */ 00035000
         ST    @10,DMCBACBE(,@05)                               DSKC086 00036000
*   DMCBOPTS=LHEX0C;                /* CLOSE DOESNT USE THE OPTIONS     00037000
*                                      SO RESET THEM                 */ 00038000
         MVI   DMCBOPTS(@05),X'00'                              DSKC086 00039000
         LA    @06,DMCBRPL(,@05)                                DSKC086 00039010
*   IF DMCBOPN^=LHEX0C THEN         /* ONLY CLOSE THE DMCB IF IT IS     00040000
*                                      OPEN                          */ 00041000
         CLI   DMCBOPN(@05),X'00'                               DSKC086 00042000
         BE    @RF00022                                            0022 00043000
*     DO;                           /* DATA SET IS OPEN              */ 00044000
*       DMCBCPC=F0C;                /* CLEAR THE ABEND COMPLETION  0024 00045000
*                                      CODE                          */ 00046000
*                                                                  0024 00047000
         ST    @10,DMCBCPC(,@05)                                DSKC086 00048000
*       /*************************************************************/ 00049000
*       /*                                                           */ 00050000
*       /* DETERMINE WHICH CLOSE LIST TO USE                         */ 00051000
*       /*                                                           */ 00052000
*       /*************************************************************/ 00053000
*                                                                  0025 00054000
*       IF DMCBRM6=ON THEN          /* REWIND OR REREAD              */ 00055000
         TM    DMCBRM6(@05),B'01000000'                         DSKC086 00056000
         BNO   @RF00025                                            0025 00057000
*         DO;                       /* REWIND OR REREAD              */ 00058000
*           IF DMCBRM5=ON THEN                                     0027 00059000
         TM    DMCBRM5(@05),B'00100000'                         DSKC086 00060000
         BNO   @RF00027                                            0027 00061000
*             CLOSELST=CLOSERRD;    /* REREAD                        */ 00062000
         L     @10,CLOSERRD                                        0028 00063000
         ST    @10,CLOSELST                                        0028 00064000
*           ELSE                                                   0029 00065000
*             CLOSELST=CLOSERWD;    /* REWIND                        */ 00066000
         B     @RC00027                                            0029 00067000
@RF00027 L     @10,CLOSERWD                                        0029 00068000
         ST    @10,CLOSELST                                        0029 00069000
*         END;                      /* REWIND OR REREAD              */ 00070000
*       ELSE                                                       0031 00071000
*         DO;                       /* LEAVE OR DISP                 */ 00072000
         B     @RC00025                                            0031 00073000
@RF00025 DS    0H                                                  0032 00074000
*           IF DMCBRM5=ON THEN                                     0032 00075000
         TM    DMCBRM5(@05),B'00100000'                         DSKC086 00076000
         BNO   @RF00032                                            0032 00077000
*             CLOSELST=CLOSELVE;    /* LEAVE                         */ 00078000
         L     @10,CLOSELVE                                        0033 00079000
         ST    @10,CLOSELST                                        0033 00080000
*           ELSE                                                   0034 00081000
*             CLOSELST=CLOSEDSP;    /* DISP                          */ 00082000
         B     @RC00032                                            0034 00083000
@RF00032 L     @10,CLOSEDSP                                        0034 00084000
         ST    @10,CLOSELST                                        0034 00085000
*         END;                      /* LEAVE OR DISP                 */ 00086000
*                                                                  0035 00087000
@RC00032 DS    0H                                                  0036 00088000
*       /*************************************************************/ 00089000
*       /*                                                           */ 00090000
*       /* IF VSAM FILE, ISSUE ENDREQ AND IGNORE ERRORS              */ 00091000
*       /*                                                           */ 00092000
*       /*************************************************************/ 00093000
*                                                                  0036 00094000
*       IF DMCBVSF=ON THEN          /* CHECK VSAM BIT OF FTY         */ 00095000
@RC00025 TM    DMCBVSF(@05),B'00000001'                         DSKC086 00096000
         BNO   @RF00036                                            0036 00097000
*         DO;                       /* VSAM FILE, ISSUE ENDREQ MACRO */ 00098000
*           RFY                                                    0038 00099000
*            (GPR01P,                                              0038 00100000
*             GPR15F) RSTD;                                        0038 00101000
*           GPR01P=ADDR(DMCBRPL);                                  0039 00102000
         LA    @01,DMCBRPL(,@05)                                DSKC086 00103000
*           GEN REFS(GPR01P) SETS(GPR15F)(ENDREQ RPL=(1));         0040 00104000
         ENDREQ RPL=(1)                                                 00105000
         LA    @02,DMCBACB(,@05)                                DSKC086 00105010
         TM    DMCBOUT(@05),B'10000000'                         DSKC086 00105020
         BNO   A00010E                                          DSKC086 00105030
         CLOSE ((@02)),MF=(E,CLOSELST),TYPE=T                   DSKC086 00105040
         B     A000124                                          DSKC086 00105050
A00010E  CLOSE ((@02)),MF=(E,CLOSELST)                          DSKC086 00105060
         MVI   DMCBOPN(@05),X'00'                               DSKC086 00105070
A000124  ST    @15,DMCBSUBC(,@05)                               DSKC086 00105080
         L     @10,DMCBSUBC(,@05)                               DSKC086 00105090
         LTR   @10,@10                                          DSKC086 00105100
         BE    A000148                                          DSKC086 00105110
         MVC   DMCBMODN(8,@05),MODNAME                          DSKC086 00105120
         MVC   DMCBRTC(4,@05),@CF00037                          DSKC086 00105130
         SLR   @10,@10                                          DSKC086 00105140
         IC    @10,ACBERFLG+492(,@05)                           DSKC086 00105150
         ST    @10,DMCBACBE(,@05)                               DSKC086 00105160
A000148  TM    DMCBOUT(@05),B'10000000'                         DSKC086 00105170
         BNE   @RF00081                                         DSKC086 00105180
         CLI   DMCBACCM(@05),1                                  DSKC086 00105190
         BE    A000160                                          DSKC086 00105200
         CLI   DMCBACCM(@05),4                                  DSKC086 00105210
         BNE   @RF00081                                         DSKC086 00105220
A000160  DS    0H                                               DSKC086 00105230
*        DEQ   (@CC00322,DMCBDSN(,@05),44,SYSTEMS),             DSKC086 00105240
*              MF=(E,ILIST)                                     DSKC086 00105241
         XC    ILIST(20),ILIST                                  DSKC086 00105250
         MVI   ILIST+4,X'C0'                                    DSKC086 00105260
         MVI   ILIST+5,44                                       DSKC086 00105270
         MVI   ILIST+6,X'49'                                    DSKC086 00105280
         LA    @10,@CC00322                                     DSKC086 00105290
         ST    @10,ILIST+8                                      DSKC086 00105300
         LA    @10,DMCBDSN(,@05)                                DSKC086 00105310
         ST    @10,ILIST+12                                     DSKC086 00105320
         LA    @01,ILIST+4                                      DSKC086 00105330
         SVC   48                                               DSKC086 00105340
         B     @RF00081                                         DSKC086 00105350
*           RFY                                                    0041 00106000
*            (GPR01P,                                              0041 00107000
*             GPR15F) UNRSTD;                                      0041 00108000
*         END;                      /* VSAM FILE, ISSUE ENDREQ MACRO */ 00109000
*                                                                  0042 00110000
*       /*************************************************************/ 00111000
*       /*                                                           */ 00112000
*       /* SET AN ESTAE ROUTINE TO COVER ANY POSSIBILITY OF ABEND    */ 00113000
*       /*                                                           */ 00114000
*       /*************************************************************/ 00115000
*                                                                  0043 00116000
*       ESTAEPRM=ESTAELST;                                         0043 00117000
@RF00036 MVC   ESTAEPRM(16),ESTAELST                               0043 00118000
*       RFY                                                        0044 00119000
*        (GPR02P,                                                  0044 00120000
*         GPR03P,                                                  0044 00121000
*         GPR04P) RSTD;                                            0044 00122000
*       GPR02P=ADDR(ESTAEPRM);      /* POINT TO ESTAE PARM LIST      */ 00123000
         LA    @02,ESTAEPRM                                     DSKC086 00124000
*       GPR03P=ADDR(BLSCRECV);      /* ADDRESS ESTAE EXIT ROUTINE    */ 00125000
         L     @03,@CV00308                                     DSKC086 00126000
*       GPR04P=CBPTR;               /* DMCB WILL BE PARM LIST FOR  0047 00127000
*                                      ESTAE                         */ 00128000
         LR    @04,@05                                          DSKC086 00129000
*       GEN REFS(GPR02P,GPR03P,GPR04P)                             0048 00130000
*           (ESTAE (GPR03P),PARAM=(GPR04P),MF=(E,(GPR02P)));       0048 00131000
         ESTAE (@03),PARAM=(@04),MF=(E,(@02))                   DSKC086 00132000
*       RFY                                                        0049 00133000
*        (GPR02P,                                                  0049 00134000
*         GPR03P,                                                  0049 00135000
*         GPR04P) UNRSTD;                                          0049 00136000
*       DMCBARC=PERMER;             /* SET THE RETURN CODE SHOULD THE   00137000
*                                      CLOSE REQUEST ABEND           */ 00138000
*                                                                  0050 00139000
         MVC   DMCBARC(4,@05),@CF00037                          DSKC086 00140000
*       /*************************************************************/ 00141000
*       /*                                                           */ 00142000
*       /* DETERMINE WHETHER THE ACCESS METHOD IS VSAM OR QSAM AND   */ 00143000
*       /* POINT AT THE PROPER CONTROL BLOCK                         */ 00144000
*       /*                                                           */ 00145000
*       /*************************************************************/ 00146000
*                                                                  0051 00147000
*       RFY                                                        0051 00148000
*         GPR02P RSTD;                                             0051 00149000
*       IF DMCBVSF=ON THEN          /* CHECK VSAM BIT OF FTY         */ 00150000
*         GPR02P=ADDR(DMCBACB);     /* VSAM SO POINT AT ACB          */ 00153000
*       ELSE                                                       0054 00155000
*         GPR02P=ADDR(DMCBDCB);     /* QSAM SO POINT AT DCB          */ 00156000
*                                                                  0054 00157000
*       /*************************************************************/ 00160000
*       /*                                                           */ 00161000
*       /* DO THE PROPER FORM OF CLOSE DEPENDING ON TEMP OPTION      */ 00162000
*       /*                                                           */ 00163000
*       /*************************************************************/ 00164000
*                                                                  0055 00165000
*       IF DMCBTMP=ON THEN          /* CHECK TEMP BIT OF RMOD        */ 00166000
*         DO;                       /* TEMPORARY CLOSE               */ 00169000
*           DMCBRET=ADDR(RECOV1);   /* SET RECOVERY ADDRESS          */ 00170000
         LA    @10,A000216                                      DSKC086 00171000
         ST    @10,DMCBRET(,@05)                                DSKC086 00172000
         MVI   DMCBRES7+4(@05),X'80'                            DSKC086 00172010
         LA    @02,DMCBDCB(,@05)                                DSKC086 00172020
*RECOV1:                                                           0059 00176000
*         END;                      /* TEMPORARY CLOSE               */ 00177000
*       ELSE                                                       0060 00178000
*         DO;                       /* PERMANENT CLOSE               */ 00179000
@RF00055 DS    0H                                                  0061 00181000
*           DMCBRET=ADDR(RECOV2);   /* SET RECOVERY ADDRESS          */ 00182000
*           GEN(CLOSE ((GPR02P)),MF=(E,CLOSELST))                  0062 00185000
*           REFS(GPR02P,CLOSELST);                                 0062 00186000
         CLOSE ((@02)),MF=(E,CLOSELST)                          DSKC086 00187000
*           DMCBOPN=LHEX0C;         /* INDICATE THAT DMCB IS CLOSED  */ 00188000
         L     @10,RPLCCHAR-IFGRPL(,@06)                        DSKC086 00188010
         LR    @07,@10                                          DSKC086 00188020
         SRL   @07,1                                            DSKC086 00188030
         ALR   @07,@07                                          DSKC086 00188040
         CR    @07,@10                                          DSKC086 00188050
         BNE   A000216                                          DSKC086 00188060
         LA    @02,DMCBDCB(,@05)                                DSKC086 00188070
         FREEPOOL (@02)                                         DSKC786 00188080
A000216  MVI   DMCBOPN(@05),X'00'                               DSKC086 00189000
*RECOV2:                                                           0064 00190000
*         END;                      /* PERMANENT CLOSE               */ 00191000
RECOV2   DS    0H                                                  0065 00192000
*       RFY                                                        0065 00193000
*         GPR02P UNRSTD;                                           0065 00194000
@RC00055 DS    0H                                                  0066 00195000
*       RFY                                                        0066 00196000
*         GPR15F RSTD;                                             0066 00197000
*       DMCBSUBC=GPR15F;            /* SAVE THE RETCODE              */ 00198000
*       RFY                                                        0068 00200000
*         GPR15F UNRSTD;                                           0068 00201000
*                                                                  0068 00202000
*       /*************************************************************/ 00203000
*       /*                                                           */ 00204000
*       /* TEST FOR CLOSE ERROR                                      */ 00205000
*       /*                                                           */ 00206000
*       /*************************************************************/ 00207000
*                                                                  0069 00208000
*       IF DMCBSUBC^=F0C THEN       /* TEST FOR CLOSE FAILURE        */ 00209000
*         DO;                       /* CLOSE ERROR                   */ 00213000
*           DMCBMODN=MODNAME;       /* PASS MODULE NAME TO BLSCANLE  */ 00214000
*           DMCBRTC=PERMER;         /* SET FAILURE RETURN CODE       */ 00216000
*           IF DMCBVSF=ON THEN      /* TEST FOR VSAM                 */ 00218000
*             DMCBACBE=ACBERFLG;    /* SAVE THE CLOSE REASON CODE    */ 00221000
*         END;                      /* CLOSE ERROR                   */ 00225000
*                                                                  0075 00226000
@RF00073 DS    0H                                                  0076 00227000
*       /*************************************************************/ 00228000
*       /*                                                           */ 00229000
*       /* CANCEL THE ESTAE                                          */ 00230000
*       /*                                                           */ 00231000
*       /*************************************************************/ 00232000
*                                                                  0076 00233000
*       ESTAEPRM=ESTAELST;                                         0076 00234000
*       RFY                                                        0077 00236000
*         GPR02P RSTD;                                             0077 00237000
*       GPR02P=ADDR(ESTAEPRM);      /* ADDRESS ESTAE PARM LIST       */ 00238000
*       GEN REFS(GPR02P)(ESTAE 0,MF=(E,(GPR02P)));                 0079 00240000
*       RFY                                                        0080 00242000
*         GPR02P UNRSTD;                                           0080 00243000
*                                                                  0080 00244000
*       /*************************************************************/ 00245000
*       /*                                                           */ 00246000
*       /* ISSUE DEQUEUE IF REQUIRED                                 */ 00247000
*       /*                                                           */ 00248000
*       /*************************************************************/ 00249000
*                                                                  0081 00250000
*       IF DMCBVSF=ON&              /* IF VSAM DATA SET              */ 00251000
*           DMCBRTC=F0C&            /* AND CLOSE IS SUCCESSFUL       */ 00252000
*           DMCBTMP=OFF&            /* AND PERMANENT CLOSE           */ 00253000
*           (DMCBACCM=F1C×DMCBACCM=F4C) THEN/* AND HIGH CONTENTION 0081 00254000
*                                      DATA SET                      */ 00255000
@RT00081 DS    0H                                                  0082 00267000
*         DO;                       /* DEQ (QNAME,DMCBDSN,LENGTH(DMCB   00268000
*                                      DSN),SYSTEMS)                 */ 00269000
*           I048(1:20)=I048(1:20)&&I048(1:20);                     0083 00270000
*           RFY                                                    0084 00272000
*             GPR01F RESTRICTED;                                   0084 00273000
*           I04804(1)='11000000'B;  /* LISTEND BYTE                  */ 00274000
*           I04805(1)=LENGTH(DMCBDSN);/* SET LENGTH                  */ 00276000
*           I04806(1)='01001000'B;  /* OPTIONS                       */ 00278000
*           I04807(1)=ADDR(QNAME);  /* QNAME ADDRESS                 */ 00280000
*           I04808(1)=ADDR(DMCBDSN);/* RNAME ADDRESS                 */ 00283000
*           GPR01F=ADDR(I04802);                                   0090 00286000
*           SVC(48);                                               0091 00288000
         L     @10,DMCBRTC(,@05)                                DSKC086 00289010
         LTR   @10,@10                                          DSKC086 00289020
         BE    A000230                                          DSKC086 00289030
         MVC   DMCBMODN(8,@05),MODNAME                          DSKC086 00289040
         MVC   DMCBRTC(4,@05),@CF00037                          DSKC086 00289050
A000230  MVI   DMCBRES7+4(@05),X'91'                            DSKC086 00289060
         MVC   ESTAEPRM(16),ESTAELST                            DSKC086 00289070
         LA    @02,ESTAEPRM                                     DSKC086 00289080
         ESTAE 0,MF=(E,(@02))                                   DSKC086 00289090
*           RFY                                                    0092 00290000
*             GPR01F UNRESTRICTED;                                 0092 00291000
*         END;                      /* DEQ (QNAME,DMCBDSN,LENGTH(DMCB   00292000
*                                      DSN),SYSTEMS) ISSUE DEQUEUE   */ 00293000
*     END;                          /* DATA SET IS OPEN              */ 00294000
@RF00081 DS    0H                                                  0095 00295000
*   RETURN CODE(DMCBRTC);                                          0095 00296000
@RF00022 L     @10,DMCBRTC(,@05)                                DSKC086 00297000
         L     @13,4(,@13)                                         0095 00298000
         L     @00,@SIZDATD                                        0095 00299000
         LR    @01,@11                                             0095 00300000
         BLSCFRES R,LV=(0),A=(1)                                        00301000
         LR    @15,@10                                             0095 00302000
         L     @14,12(,@13)                                        0095 00303000
         LM    @00,@12,20(@13)                                     0095 00304000
         BR    @14                                                 0095 00305000
         EJECT                                                          00306000
*                                                                  0096 00307000
*   /*****************************************************************/ 00308000
*   /*                                                               */ 00309000
*   /* END OF EXECUTABLE PROCEDURE STATEMENTS                        */ 00310000
*   /*                                                               */ 00311000
*   /*****************************************************************/ 00312000
*                                                                  0096 00313000
*   DECLARE                         /* GENERAL PURPOSE REGISTERS     */ 00314000
*     GPR01F FIXED(31) REG(1),                                     0096 00315000
*     GPR15F FIXED(31) REG(15),                                    0096 00316000
*     GPR01P PTR(31) REG(1),                                       0096 00317000
*     GPR02P PTR(31) REG(2),                                       0096 00318000
*     GPR03P PTR(31) REG(3),                                       0096 00319000
*     GPR04P PTR(31) REG(4);                                       0096 00320000
*   DCL                                                            0097 00321000
*     1 I048 DEF(ILIST) CHAR(32767) BDY(WORD),                     0097 00322000
*       3 I04801 PTR(31),           /* TCB ADDR                      */ 00323000
*       3 I04802(*) CHAR(12) BDY(WORD),                            0097 00324000
*         5 I04803 PTR(31),         /* UCB @ IN LAST ENTRY           */ 00325000
*           7 I04804 BIT(8),        /* FLAGS                         */ 00326000
*           7 I04805 PTR(8),        /* MINOR RESOURCE NAME LENGTH    */ 00327000
*           7 I04806 BIT(8),        /* FLAGS                         */ 00328000
*           7 * CHAR(1),            /* CONTROL PROGRAM USE           */ 00329000
*         5 I04807 PTR(31),         /* MAJOR RESOURCE NAME @         */ 00330000
*         5 I04808 PTR(31);         /* MINOR RESOURCE NAME @         */ 00331000
*   DECLARE                                                        0098 00332000
*     ILIST CHAR(20) BDY(DWORD);    /* STANDARD LIST                 */ 00333000
*   DECLARE                         /* COMMON VARIABLES              */ 00334000
*     I256C CHAR(256) BASED,                                       0099 00335000
*     I031F FIXED(31) BASED,                                       0099 00336000
*     I031P PTR(31) BASED,                                         0099 00337000
*     I015F FIXED(15) BASED,                                       0099 00338000
*     I015P PTR(15) BASED,                                         0099 00339000
*     I008P PTR(8) BASED,                                          0099 00340000
*     I001C CHAR(1) BASED;                                         0099 00341000
*   DCL                                                            0100 00342000
*     1 DASPATCH LOCAL BDY(DWORD),  /* PATCH AREA                    */ 00343000
*      2 DASPATA(DASPATLN) PTR INIT((DASPATLN)0);                  0100 00344000
*   END BLSCCLSE                                                   0101 00345000
*                                                                  0101 00346000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 00347000
*/*%INCLUDE SYSLIB  (IFGACB  )                                       */ 00348000
*                                                                  0101 00349000
*       ;                                                          0101 00350000
@DATA    DS    0H                                                       00351000
@DATD    DSECT                                                          00352000
         DS    0F                                                       00353000
@SA00001 DS    18F                                                      00354000
BLSCCLSE CSECT                                                          00355000
         DC    0F'0'                                            DSKC086 00356000
@CF00037 DC    F'4'                                                     00357000
@DATD    DSECT                                                          00358000
         DS    0D                                                       00359000
CLOSELST DS    F                                                        00360000
         DS    CL4                                                      00361000
ESTAEPRM DS    CL16                                                     00362000
MODSTAT  DS    CL8                                                      00363000
         ORG   MODSTAT                                                  00364000
MODNAME  DS    CL8                                                      00365000
         ORG   MODSTAT+8                                                00366000
ILIST    DS    CL20                                                     00367000
BLSCCLSE CSECT                                                          00368000
         DC    0F'0'                                            DSKC086 00369000
@SIZDATD DC    AL1(0)                                                   00370000
         DC    AL3(@ENDDATD-@DATD)                                      00371000
@CV00308 DC    V(BLSCRECV)                                              00372000
         DC    X'B1F850F0'                   !!! SOURCE COMPARE FIX !!! 00373000
         DC    0D'0'                                            DSKC086 00373000
@CC00322 DC    C'SYSBLSDS'                                              00374000
@CC00339 DC    C'BLSCCLSE'                                              00375000
DASPATCH DS    CL80                                                     00376000
         ORG   DASPATCH                                                 00377000
DASPATA  DC    20A(0)                                                   00378000
         ORG   DASPATCH+80                                              00379000
BLSCCLSE CSECT                                                          00380000
CLOSEDSP CLOSE (,DISP),MF=L                                             00381000
CLOSERRD CLOSE (,REREAD),MF=L                                           00382000
CLOSELVE CLOSE (,LEAVE),MF=L                                            00383000
CLOSERWD CLOSE (,REWIND),MF=L                                           00384000
ESTAELST ESTAE 0,MF=L                                                   00385000
@DATD    DSECT                                                          00386000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                00387000
@ENDDATD EQU   *                                                        00388000
BLSCCLSE CSECT                                                          00389000
         BLSDMCB  ,                                             DSKC086 00389010
         IFGRPL   ,                                             DSKC086 00389020
@00      EQU   00                      EQUATES FOR REGISTERS 0-15       00390000
@01      EQU   01                                                       00391000
@02      EQU   02                                                       00392000
@03      EQU   03                                                       00393000
@04      EQU   04                                                       00394000
@05      EQU   05                                                       00395000
@06      EQU   06                                                       00396000
@07      EQU   07                                                       00397000
@08      EQU   08                                                       00398000
@09      EQU   09                                                       00399000
@10      EQU   10                                                       00400000
@11      EQU   11                                                       00401000
@12      EQU   12                                                       00402000
@13      EQU   13                                                       00403000
@14      EQU   14                                                       00404000
@15      EQU   15                                                       00405000
CBPTR    EQU   @05                                                      00406000
GPR01P   EQU   @01                                                      00407000
GPR15F   EQU   @15                                                      00408000
GPR02P   EQU   @02                                                      00409000
GPR03P   EQU   @03                                                      00410000
GPR04P   EQU   @04                                                      00411000
GPR01F   EQU   @01                                                      00412000
IFGACB   EQU   0                                                        00443000
ACBCOMN  EQU   IFGACB                                                   00444000
ACBLENG  EQU   ACBCOMN+2                                                00445000
ACBLENG2 EQU   ACBLENG                                                  00446000
ACBAMBL  EQU   ACBCOMN+4                                                00447000
ACBJWA   EQU   ACBAMBL                                                  00448000
ACBMACRF EQU   ACBCOMN+12                                               00449000
ACBMACR1 EQU   ACBMACRF                                                 00450000
ACBADR   EQU   ACBMACR1                                                 00451000
ACBCNV   EQU   ACBMACR1                                                 00452000
ACBMACR2 EQU   ACBMACRF+1                                               00453000
ACBBUFPL EQU   ACBCOMN+20                                               00454000
ACBMACR3 EQU   ACBBUFPL                                                 00455000
ACBRECFM EQU   ACBCOMN+24                                               00456000
ACBCCTYP EQU   ACBCOMN+25                                               00457000
ACBOPT   EQU   ACBCOMN+26                                               00458000
ACBDSORG EQU   ACBOPT                                                   00459000
ACBCROPS EQU   ACBDSORG                                                 00460000
ACBDVIND EQU   ACBDSORG                                                 00461000
ACBEXLST EQU   ACBCOMN+36                                               00462000
ACBDDNM  EQU   ACBCOMN+40                                               00463000
ACBAMETH EQU   ACBDDNM+3                                                00464000
ACBOFLGS EQU   ACBCOMN+48                                               00465000
ACBEXFG  EQU   ACBOFLGS                                                 00466000
ACBIOSFG EQU   ACBOFLGS                                                 00467000
ACBERFLG EQU   ACBCOMN+49                                               00468000
ACBINFLG EQU   ACBCOMN+50                                               00469000
ACBVVIC  EQU   ACBINFLG                                                 00470000
ACBUJFCB EQU   ACBCOMN+52                                               00471000
ACBBLKSZ EQU   ACBCOMN+60                                               00472000
DMCBRQC  EQU   0                                                        00473000
I001C    EQU   0                                                        00474000
I008P    EQU   0                                                        00475000
I015F    EQU   0                                                        00476000
I015P    EQU   0                                                        00477000
I031F    EQU   0                                                        00478000
I031P    EQU   0                                                        00479000
I256C    EQU   0                                                        00480000
I048     EQU   ILIST                                                    00486000
I04802   EQU   I048+4                                                   00487000
I04803   EQU   I04802                                                   00488000
I04804   EQU   I04803                                                   00489000
I04805   EQU   I04803+1                                                 00490000
I04806   EQU   I04803+2                                                 00491000
I04807   EQU   I04802+4                                                 00492000
I04808   EQU   I04802+8                                                 00493000
@RC00027 EQU   @RC00025                                                 00662000
RECOV1   EQU   @RC00055                                                 00663000
@ENDDATA EQU   *                                                        00664000
         END   BLSCCLSE                                         DSKC086 00665000
