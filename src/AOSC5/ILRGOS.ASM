         TITLE 'ILRGOS - GROUP OPERATIONS STARTER                      *00001000
                        '                                               00002000
ILRGOS   CSECT ,                                                   0001 00003000
@MAINENT DS    0H                                                  0001 00004000
         USING *,R15                                            DSK1133 00005000
         B     @PROLOG                                             0001 00006000
         DC    AL2(@EP00001-@MAINENT)                                   00007000
         DC    AL1(22)                                          DSK1133 00008000
         DC    C'ILRGOS 78297  UZ21112 '                        DSK1133 00009000
         DC    X'F2'                         !!! SOURCE COMPARE FIX !!! 00010000
ILRFRELG DC    0H'0'                                            DSK1133 00010000
         USING *,R15                                            DSK1133 00011000
         B     @PROLOG                                             0001 00012000
         DC    AL2(@EP00711-ILRFRELG)                                   00013000
         ENTRY ILRFRELG                                                 00014000
         DROP  R15                                              DSK1133 00015000
@PROLOG  STM   R14,R12,12(R13)                                  DSK1133 00016000
         BALR  R6,0                                             DSK1133 00017000
@PSTART  DS    0H                                                  0001 00018000
         USING @PSTART,R6                                       DSK1133 00019000
         AH    R15,4(,R15)                                      DSK1133 00020000
         BR    R15                                              DSK1133 00021000
@EP00001 DS    0H                                                  0002 00022000
         USING @DATD,R8                                         DSK1133 00023000
*   ACAPTR=R1;                      /* OBTAIN ADDRESSIBILITY TO THE     00024000
*                                      ACA                           */ 00025000
         LR    R9,R1                                            DSK1133 00026000
*   RFY                                                            0059 00027000
*     R1 UNRSTD;                                                   0059 00028000
*   IF ACAASID^=PSAAOLD->ASCBASID THEN                             0060 00029000
         L     R14,PSAAOLD-PSA                                  DSK1133 00030000
         LH    R14,ASCBASID-ASCB(,R14)                          DSK1133 00031000
         N     R14,@CF01812                                     DSK1133 00032000
         CH    R14,ACAASID-ACA(,R9)                             DSK1133 00033000
         BE    @RF00060                                            0060 00034000
*     RETURN CODE(CODE04);          /* REQUEST NOT FOR THIS ADDRESS     00035000
*                                      SPACE, GET OUT IMMEDIATELY    */ 00036000
         LA    R15,4                                            DSK1133 00037000
         L     R14,12(,R13)                                     DSK1133 00038000
         LM    R0,R12,20(R13)                                   DSK1133 00039000
         BR    R14                                              DSK1133 00040000
*   ASMVTPTR=CVTASMVT;              /* OBTAIN ADDRESS OF ASMVT       */ 00041000
@RF00060 L     R14,CVTPTR                                       DSK1133 00042000
         L     R3,CVTASMVT-CVT(,R14)                            DSK1133 00043000
*                                                                  0063 00044000
*   /*****************************************************************/ 00045000
*   /*                                                               */ 00046000
*   /* SAVE OR ACTIVATE REQUEST, LOCAL LOCK IS NOT HELD, GETMAIN     */ 00047000
*   /* WORK-SAVE AREA, AND ESTABLISH ESTAE RECOVERY                  */ 00048000
*   /*                                                               */ 00049000
*   /*****************************************************************/ 00050000
*                                                                  0063 00051000
*   IF ACAOP=ACESVLGN×ACAOP=ACEACT THEN                            0063 00052000
         CLI   ACAOP-ACA(R9),ACESVLGN                           DSK1133 00053000
         BE    @RT00063                                            0063 00054000
         CLI   ACAOP-ACA(R9),ACEACT                             DSK1133 00055000
         BNE   @RF00063                                            0063 00056000
@RT00063 DS    0H                                                  0064 00057000
*     DO;                           /* SAVE OR ACTIVATE REQ.         */ 00058000
*       IF ASMSTGXA=ZERO×(ACAOP=ACESVLGN&ASMNOSAV=ON) THEN         0065 00059000
         L     R14,ASMSTGXA-ASMVT(,R3)                          DSK1133 00060000
         LTR   R14,R14                                          DSK1133 00061000
         BZ    @RT00065                                            0065 00062000
         CLI   ACAOP-ACA(R9),ACESVLGN                           DSK1133 00063000
         BNE   @RF00065                                            0065 00064000
         TM    ASMFLAG2-ASMVT(R3),ASMNOSAV                      DSK1133 00065000
         BNO   @RF00065                                            0065 00066000
@RT00065 DS    0H                                                  0066 00067000
*         RETURN CODE(CODE20);      /* NO ACB FOR STORAGE INDEX, OR     00068000
*                                      SAVE REQUEST AND STORAGE INDEX   00069000
*                                      UNAVAILABLE THEN CODE20,    0066 00070000
*                                      UNABLE TO USE STGINDEX        */ 00071000
*                                                                  0066 00072000
         LA    R15,20                                           DSK1133 00073000
         L     R14,12(,R13)                                     DSK1133 00074000
         LM    R0,R12,20(R13)                                   DSK1133 00075000
         BR    R14                                              DSK1133 00076000
*       /*************************************************************/ 00077000
*       /*                                                           */ 00078000
*       /* OBTAIN A WORK-SAVE AREA, BUFFER CONTROL AREA, ATA AND     */ 00079000
*       /* EPATH                                                     */ 00080000
*       /*                                                           */ 00081000
*       /*************************************************************/ 00082000
*                                                                  0067 00083000
*       RFY                                                        0067 00084000
*        (R10,                                                     0067 00085000
*         R11,                                                     0067 00086000
*         R1AREA) RSTD;                                            0067 00087000
@RF00065 DS    0H                                                  0068 00088000
*       R10=LENGTH(WKAREA);         /* OBTAIN LENGTH TO BE GETMAINED */ 00089000
         LA    R10,256                                             0068 00090000
*       GEN SETS(R1AREA,R15) REFS(WKSAV@);                         0069 00091000
*                                  /* GET SQA SPACE FROM SUBPOOL 245*/  00092000
        GETMAIN RC,LV=(R10),SP=245                                      00093000
*       IF R15^=CODE00 THEN                                        0070 00094000
         LTR   R15,R15                                             0070 00095000
         BZ    @RF00070                                            0070 00096000
*         RETURN CODE(CODE28);      /* NO STORAGE AVAILABLE          */ 00097000
         LA    R15,28                                           DSK1133 00098000
         L     R14,12(,R13)                                     DSK1133 00099000
         LM    R0,R12,20(R13)                                   DSK1133 00100000
         BR    R14                                              DSK1133 00101000
*       WKSAV@=R1AREA;              /* ADDRESSIBILITY TO WORK AREA   */ 00102000
@RF00070 LR    R8,R1                                            DSK1133 00103000
*       WKAREA=''B;                 /* CLEAR THE WORK-SAVE AREA      */ 00104000
         XC    WKAREA(256,R8),WKAREA(R8)                        DSK1133 00105000
*       ATAPTR=ADDR(WKATA);         /* ATA IN WORK SAVE AREA ON    0074 00106000
*                                      UNLOCKED PATHS                */ 00107000
         LA    R4,WKATA                                         DSK1133 00108000
*       R11=ADDR(ILRCGOSE);         /* ADDR ESTAE RECOVERY ROUTINE   */ 00109000
         L     R11,@CV01708                                        0075 00110000
*       GEN REFS(R11,ATAPTR);                                      0076 00111000
         ESTAE (11),PARAM=(4),MF=(E,ESTAELST),TERM=YES,         DSK1133*00113010
               PURGE=HALT,ASYNCH=NO                             DSK1133 00113020
*       IF R15^=CODE00 THEN                                        0077 00114000
         LTR   R15,R15                                             0077 00115000
         BZ    @RF00077                                            0077 00116000
*         DO;                       /* ESTAE ERROR                   */ 00117000
*           GEN REFS(R10,WKSAV@);                                  0079 00118000
*                     /* FREE WORK AREA JUST GETMAINED */               00119000
         FREEMAIN RC,LV=(R10),A=(R8),SP=245                     DSK1133 00120000
*           RETURN CODE(CODE44);    /* INDETERMINENT ERROR           */ 00121000
         LA    R15,44                                           DSK1133 00122000
         L     R14,12(,R13)                                     DSK1133 00123000
         LM    R0,R12,20(R13)                                   DSK1133 00124000
         BR    R14                                              DSK1133 00125000
*         END;                      /* END ESTAE ERROR DO            */ 00126000
*       RFY                                                        0082 00127000
*        (R10,                                                     0082 00128000
*         R11,                                                     0082 00129000
*         R15) UNRSTD;                                             0082 00130000
@RF00077 DS    0H                                                  0083 00131000
*     END;                          /* END SAVE OR ACTIVATE DO       */ 00132000
*                                                                  0084 00133000
*   /*****************************************************************/ 00134000
*   /*                                                               */ 00135000
*   /* RELEASE OR ASSIGN REQUEST, LOCAL LOCK IS HELD, OBTAIN         */ 00136000
*   /* WORK-SAVE AREA VIA ILRGMA MACRO, AND ESTABLISH FRR RECOVERY   */ 00137000
*   /*                                                               */ 00138000
*   /*****************************************************************/ 00139000
*                                                                  0084 00140000
*   ELSE                                                           0084 00141000
*     DO;                           /* RELEASE OR ASSIGN REQUEST OR     00142000
*                                      INVALID OPERATION TYPE        */ 00143000
         B     @RC00063                                            0084 00144000
@RF00063 DS    0H                                                  0085 00145000
*       IF ACAOP^=ASSIGN&ACAOP^=ACERELLG THEN                      0085 00146000
         CLI   ACAOP-ACA(R9),ACEASGLG                           DSK1133 00147000
         BE    @RF00085                                            0085 00148000
         CLI   ACAOP-ACA(R9),ACERELLG                           DSK1133 00149000
         BE    @RF00085                                            0085 00150000
*         RETURN CODE(CODE32);      /* INVALID OPERATION TYPE        */ 00151000
*                                                                  0086 00152000
         LA    R15,32                                           DSK1133 00153000
         L     R14,12(,R13)                                     DSK1133 00154000
         LM    R0,R12,20(R13)                                   DSK1133 00155000
         BR    R14                                              DSK1133 00156000
*       /*************************************************************/ 00157000
*       /*                                                           */ 00158000
*       /* ASSIGN OR RELEASE REQUEST BEGIN ILRGMA MACRO EXPANSION    */ 00159000
*       /*                                                           */ 00160000
*       /*************************************************************/ 00161000
*                                                                  0087 00162000
*       DO;                         /* ILRGMA GET                  0087 00163000
*                                      CELL(BWK)WORKREGS(R11,R12)    */ 00164000
@RF00085 DS    0H                                                  0088 00165000
*         DECLARE                   /* ASMVT VECTOR TO ILRPEX        */ 00166000
*           ILRPEX ENTRY BASED(ASMPEX) VALRG(0);                   0088 00167000
*         DECLARE                   /* MAP FOR CELL CONTROL WORDS    */ 00168000
*           1 GMACELL BASED BDY(WORD),                             0089 00169000
*            2 GMANEXT PTR(31);     /* PTR NEXT FREE CELL            */ 00170000
*         RESPECIFY                                                0090 00171000
*          (R0,                                                    0090 00172000
*           R1,                                                    0090 00173000
*           R11,                                                   0090 00174000
*           R12,                                                   0090 00175000
*           R14,                                                   0090 00176000
*           R15) RESTRICTED;                                       0090 00177000
*         RESPECIFY                                                0091 00178000
*           ASMPOOLS BASED(R11);                                   0091 00179000
*         RESPECIFY                                                0092 00180000
*           GMACELL BASED(R14);                                    0092 00181000
*         R11=ADDR(ASMBWKPC);                                      0093 00182000
         LA    R11,ASMBWKPC-ASMVT(,R3)                          DSK1133 00183000
*         LM(R14,R15,ASMCPAVQ);     /* GET ADDR OF 1ST CELL          */ 00184000
         LM    R14,R15,ASMCPAVQ-ASMPOOLS(R11)                   DSK1133 00185000
*GMA00010:                                                         0095 00186000
*         IF R14^=0 THEN            /* TEST CELL POOL                */ 00187000
GMA00010 LTR   R14,R14                                             0095 00188000
         BZ    @RF00095                                            0095 00189000
*           DO;                     /* CELL AVAILABLE, REMOVE CELL   */ 00190000
*             R0=GMANEXT;                                          0097 00191000
         L     R0,GMANEXT(,R14)                                    0097 00192000
*             R1=R15-1;                                            0098 00193000
         LR    R1,R15                                              0098 00194000
         BCTR  R1,0                                                0098 00195000
*             CDS(R14,R0,ASMCPAVQ);                                0099 00196000
         CDS   R14,R0,ASMCPAVQ-ASMPOOLS(R11)                    DSK1133 00197000
*             BC(7,GMA00010);                                      0100 00198000
         BC    7,GMA00010                                          0100 00199000
*             R1=R14;                                              0101 00200000
         LR    R1,R14                                              0101 00201000
*           END;                                                   0102 00202000
*         ELSE                                                     0103 00203000
*           DO;                     /* CELL POOL EMPTY               */ 00204000
         B     @RC00095                                            0103 00205000
@RF00095 DS    0H                                                  0104 00206000
*             R1=R11;               /* PREPARE TO CALL PEX           */ 00207000
         LR    R1,R11                                              0104 00208000
*             CALL ILRPEX;          /* EXTEND THE POOL               */ 00209000
         L     R15,ASMPEX-ASMVT(,R3)                            DSK1133 00210000
         BALR  R14,R15                                          DSK1133 00211000
*           END;                                                   0106 00212000
*         RESPECIFY                                                0107 00213000
*          (R0,                                                    0107 00214000
*           R1,                                                    0107 00215000
*           R11,                                                   0107 00216000
*           R12,                                                   0107 00217000
*           R14,                                                   0107 00218000
*           R15) UNRESTRICTED;                                     0107 00219000
@RC00095 DS    0H                                                  0108 00220000
*       END;                        /* ILRGMA GET                  0108 00221000
*                                      CELL(BWK)WORKREGS(R11,R12)    */ 00222000
*                                                                  0108 00223000
*       /*************************************************************/ 00224000
*       /*                                                           */ 00225000
*       /* END ILRGMA MACRO EXPANSION                                */ 00226000
*       /*                                                           */ 00227000
*       /*************************************************************/ 00228000
*                                                                  0109 00229000
*       IF R1AREA=ZERO THEN                                        0109 00230000
         LTR   R1,R1                                            DSK1133 00231000
         BNZ   @RF00109                                            0109 00232000
*         RETURN CODE(CODE28);      /* GMA UNSUCCESSFUL, NOT ENOUGH     00233000
*                                      STORAGE                       */ 00234000
         LA    R15,28                                           DSK1133 00235000
         L     R14,12(,R13)                                     DSK1133 00236000
         LM    R0,R12,20(R13)                                   DSK1133 00237000
         BR    R14                                              DSK1133 00238000
*       WKSAV@=R1AREA;              /* OBTAIN ADDRESSIBILITY TO WORK    00239000
*                                      AREA                          */ 00240000
@RF00109 LR    R8,R1                                            DSK1133 00241000
*       WKAREA=''B;                 /* CLEAR THE WORK-SAVE AREA      */ 00242000
         XC    WKAREA(256,R8),WKAREA(R8)                        DSK1133 00243000
*       R1=ADDR(ILRGOS01);          /* OBTAIN FUNCTIONAL RECOVERY  0113 00244000
*                                      ROUTINE ADDR                  */ 00245000
         L     R1,@CV01709                                         0113 00246000
*       GEN REFS(R1) SETS(ATAPTR,R11,R12);                         0114 00247000
         SETFRR A,FRRAD=(R1),PARMAD=(R4),WRKREGS=(R11,R12),     DSK1133~00248000
               RELATED=(SETFRR,ILRGOS)                          DSK1133 00249000
*     END;                          /* END ASSIGN, RELEASE, OR     0115 00250000
*                                      INVALID TYPE                  */ 00251000
*   RFY                                                            0116 00252000
*    (R1AREA,                                                      0116 00253000
*     R10) UNRSTD;                                                 0116 00254000
@RC00063 DS    0H                                                  0117 00255000
*                                                                  0117 00256000
*   /*****************************************************************/ 00257000
*   /*                                                               */ 00258000
*   /* COMMON PROCESSING FOR ALL REQUESTS DETERMINED TO BE VALID AND */ 00259000
*   /* FOR WHICH A WORK-SAVE AREA HAS BEEN OBTAINED AND A RECOVERY   */ 00260000
*   /* ROUTINE ESTABLISHED                                           */ 00261000
*   /*                                                               */ 00262000
*   /*****************************************************************/ 00263000
*                                                                  0117 00264000
*   GEN REFS(R13) SETS(R11);                                       0117 00265000
*                        /* SET SAVE AREA LINKAGE */                    00266000
       LA   R11,SAVAREA         GET ADDR OF SAVE AREA                   00267000
       ST   R13,4(R11)          STORE ADDR CALLERS SAVE AREA            00268000
*   RFY                                                            0118 00270000
*     R13 UNRSTD;                                                  0118 00271000
*   ATAMODID=ATAMGOS;               /* RRR-SET MODID IN ATA-RRR      */ 00272000
         MVI   ATAMODID(R4),ATAMGOS                             DSK1133 00273000
*   ATAEPATH=ADDR(EPATH);           /* RRR-SET EPATH ADDR IN ATA-RRR */ 00274000
         LA    R12,EPATH                                        DSK1133 00275000
         ST    R12,ATAEPATH(,R4)                                DSK1133 00276000
*   ATAWORKA=WKSAV@;                /* RRR-SET WORK SAVE AREA ADDR IN   00277000
*                                      ATA-RRR                       */ 00278000
         ST    R8,ATAWORKA(,R4)                                 DSK1133 00279000
*   RSMHDPTR=PSAAOLD->ASCBRSM;      /* OBTAIN RSM HEADER ADDR WHICH     00280000
*                                      ALSO GIVES ADDRESSIBILITY TO     00281000
*                                      THE ASM HEADER                */ 00282000
         L     R12,PSAAOLD-PSA                                  DSK1133 00283000
         L     R2,ASCBRSM-ASCB(,R12)                            DSK1133 00284000
*   RTNCODE=CODE00;                 /* CLEAR RETURN CODE             */ 00285000
         SLR   R12,R12                                          DSK1133 00286000
         ST    R12,RTNCODE                                      DSK1133 00287000
*                                                                  0124 00288000
*   /*****************************************************************/ 00289000
*   /*                                                               */ 00290000
*   /* ASSIGN REQUEST PROCESSING, DETERMINE THE SLOTS NEEDED TO BACK */ 00291000
*   /* THIS REQUEST AND CALL THE ASSIGN SUBROUTINE TO BUILD A LGE, AN*/ 00292000
*   /* ASPCT, AND OBTAIN A LGN. THE LGE IS THEN QUEUED TO THE ASM    */ 00293000
*   /* HEADER LGE Q.                                                 */ 00294000
*   /*                                                               */ 00295000
*   /*****************************************************************/ 00296000
*                                                                  0124 00297000
*   IF ACAOP=ASSIGN THEN                                           0124 00298000
         CLI   ACAOP-ACA(R9),ACEASGLG                           DSK1133 00299000
         BNE   @RF00124                                            0124 00300000
*     DO;                           /* ASSIGN REQUEST                */ 00301000
*       EPAACASR=ON;                /* RRR-INDICATE ASSIGN OR      0126 00302000
*                                      ACTIVATE REQUEST-RRR          */ 00303000
         OI    EPAACASR,B'00001000'                                0126 00304000
*       IF ACAMAXPN<INVLDRPN THEN                                  0127 00305000
         L     R15,ACATOLP-ACA(,R9)                             DSK1133 00306000
         C     R15,@CF01675                                     DSK1133 00307000
         BNL   @RF00127                                            0127 00308000
*         DO;                       /* PAGE NUMBER IS VALID          */ 00309000
*           IF SLOTV=ZERO THEN                                     0129 00310000
         L     R1,ASMSLOTV-ASMVT(,R3)                           DSK1133 00311000
         C     R12,SLOTV(,R1)                                   DSK1133 00312000
         BNE   @RF00129                                            0129 00313000
*             SLOTS=ACAMAXPN;       /* DEFAULTS SLOTS TO MAX. VALUE  */ 00314000
         ST    R15,SLOTS                                        DSK1133 00315000
*           ELSE                                                   0131 00316000
*             SLOTS=ACAMAXPN/SLOTV; /* OBTAIN SLOTS NEEDED TO BACK 0131 00317000
*                                      THIS LG                       */ 00318000
         B     @RC00129                                            0131 00319000
@RF00129 L     R12,ASMSLOTV-ASMVT(,R3)                          DSK1133 00320000
         L     R0,ACATOLP-ACA(,R9)                              DSK1133 00321000
         SRDA  R0,32                                            DSK1133 00322000
         D     R0,SLOTV(,R12)                                   DSK1133 00323000
         ST    R1,SLOTS                                         DSK1133 00324000
*           RFY                                                    0132 00325000
*            (R0,                                                  0132 00326000
*             R1) RSTD;                                            0132 00327000
@RC00129 DS    0H                                                  0133 00328000
*           R0=ASMBKSLT;            /* GET ASMVT BACKING SLOT COUNT  */ 00329000
         L     R0,ASMBKSLT-ASMVT(,R3)                           DSK1133 00330000
*UPDATSLT:                                                         0134 00331000
*           IF R0>=SLOTS THEN                                      0134 00332000
UPDATSLT L     R12,SLOTS                                        DSK1133 00333000
         CR    R0,R12                                           DSK1133 00334000
         BL    @RF00134                                            0134 00335000
*             DO;                   /* ENOUGH SLOTS AVAILABLE        */ 00336000
*               R1=R0-SLOTS;        /* DECR COUNT                    */ 00337000
         LCR   R12,R12                                          DSK1133 00338000
         ALR   R12,R0                                           DSK1133 00339000
         LR    R1,R12                                           DSK1133 00340000
*               CS(R0,R1,ASMBKSLT); /* PUT COUNT IN ASMVT            */ 00341000
         CS    R0,R1,ASMBKSLT-ASMVT(R3)                         DSK1133 00342000
*               BC(NE,UPDATSLT);    /* NOT SUCCESSFUL, TRY AGAIN     */ 00343000
         BC    7,UPDATSLT                                          0138 00344000
*               RFY                                                0139 00345000
*                (R0,                                              0139 00346000
*                 R1) UNRSTD;                                      0139 00347000
*               EPABKSLT=SLOTS;     /* RRR-TRACK SLOTS NEEDED IN   0140 00348000
*                                      EPATH-RRR                     */ 00349000
         L     R12,SLOTS                                        DSK1133 00350000
         ST    R12,EPABKSLT                                     DSK1133 00351000
*               EPAASGN=ON;         /* RRR-INDICATE BACKING SLOTS HAS   00352000
*                                      BEEN UPDATED-RRR              */ 00353000
         OI    EPAASGN,B'00000100'                                 0141 00354000
*               REQASPCT=ON;        /* INDICATE ASPCT NEEDED         */ 00355000
         OI    REQASPCT,B'10000000'                                0142 00356000
*               CALL ASSIGNLG;      /* ASSIGN AN LGN AND BUILD A LGE    00357000
*                                      AND AN ASPCT                  */ 00358000
         BAL   R14,ASSIGNLG                                     DSK1133 00359000
*               RFY                                                0144 00360000
*                 ASPCTPTR RSTD;                                   0144 00361000
*               IF RTNCODE=ZERO THEN                               0145 00362000
         L     R15,RTNCODE                                      DSK1133 00363000
         LTR   R15,R15                                          DSK1133 00364000
         BNZ   @RF00145                                            0145 00365000
*                 DO;               /* ASSIGN SUBROUTINE SUCCESSFUL  */ 00366000
*                   ASPCTPTR=SAVASPCT;/* RESTORE ASPCT ADDR OBTAINED    00367000
*                                      IN ASSIGN                     */ 00368000
         L     R12,SAVASPCT                                     DSK1133 00369000
*                   ASPMAXPN=ACAMAXPN;/* SET MAX PG NUMBER IN ASPCT  */ 00370000
         L     R15,ACATOLP-ACA(,R9)                             DSK1133 00371000
         ST    R15,ASPMAXPN(,R12)                               DSK1133 00372000
*                   ASPBKSLT=SLOTS; /* SET NUMBER OF SLOTS REMOVED 0149 00373000
*                                      FOR THIS LG                   */ 00374000
         L     R15,SLOTS                                        DSK1133 00375000
         ST    R15,ASPBKSLT(,R12)                               DSK1133 00376000
*                   RFY                                            0150 00377000
*                     ASPCTPTR UNRSTD;                             0150 00378000
*                   ACALGID=LGELGID;/* LGN ASSIGNED IS RETURNED VIA     00379000
*                                      THE ACA                       */ 00380000
         L     R12,LGELGID(,R5)                                 DSK1133 00381000
         ST    R12,ACALGID-ACA(,R9)                             DSK1133 00382000
*                 END;              /* END DO FOR SUCCESSFUL ASSIGN  */ 00383000
*               ELSE                                               0153 00384000
*                 DO;               /* ASSIGN SUBROUTINE           0153 00385000
*                                      UNSUCCESSFUL, NOT ENOUGH    0153 00386000
*                                      STORAGE AVAILABLE             */ 00387000
         B     @RC00124                                         DSK1133 00388000
@RF00145 DS    0H                                                  0154 00389000
*                   RFY                                            0154 00390000
*                    (R0,                                          0154 00391000
*                     R1) RSTD;                                    0154 00392000
*                   R0=ASMBKSLT;    /* GET ASMVT BACKING SLOT COUNT  */ 00393000
         L     R0,ASMBKSLT-ASMVT(,R3)                           DSK1133 00394000
*RESTRSLT:                                                         0156 00395000
*                   R1=R0+SLOTS;    /* RESTORE COUNT                 */ 00396000
RESTRSLT LR    R1,R0                                               0156 00397000
         AL    R1,SLOTS                                            0156 00398000
*                   CS(R0,R1,ASMBKSLT);/* PUT COUNT IN ASMVT         */ 00399000
         CS    R0,R1,ASMBKSLT-ASMVT(R3)                         DSK1133 00400000
*                   BC(NE,RESTRSLT);/* NOT SUCCESSFUL, TRY AGAIN     */ 00401000
         BC    7,RESTRSLT                                          0158 00402000
*                   EPAASGN=OFF;    /* RRR-BACKING SLOTS HAS BEEN  0159 00403000
*                                      RESTORED-RRR                  */ 00404000
         NI    EPAASGN,B'11111011'                                 0159 00405000
*                   RFY                                            0160 00406000
*                    (R0,                                          0160 00407000
*                     R1) UNRSTD;                                  0160 00408000
*                 END;              /* END UNSUCCESSFUL ASSIGN       */ 00409000
*             END;                  /* END ENOUGH SLOTS AVAILABLE    */ 00410000
*           ELSE                                                   0163 00411000
*             RTNCODE=CODE28;       /* NOT ENOUGH STORAGE AVAILABLE  */ 00412000
         B     @RC00124                                         DSK1133 00413000
@RF00134 MVC   RTNCODE(4),@CF00438                                 0163 00414000
*         END;                      /* END PROCESSING FOR VALID PAGE    00415000
*                                      NUMBER                        */ 00416000
*       ELSE                                                       0165 00417000
*         RTNCODE=CODE28;           /* MAX PAGE NUMBER IS TOO LARGE  */ 00418000
         B     @RC00124                                         DSK1133 00419000
@RF00127 MVC   RTNCODE(4),@CF00438                                 0165 00420000
*     END;                          /* END ASSIGN PROCESSING         */ 00421000
*                                                                  0167 00422000
*   /*****************************************************************/ 00423000
*   /*                                                               */ 00424000
*   /* NOT AN ASSIGN REQUEST, OBTAIN AND INITIALIZE AN ACE           */ 00425000
*   /*                                                               */ 00426000
*   /*****************************************************************/ 00427000
*                                                                  0167 00428000
*   ELSE                                                           0167 00429000
*     DO;                           /* RELEASE, ACTIVATE, SAVE COMMON   00430000
*                                      PROCESSING                    */ 00431000
         B     @RC00124                                            0167 00432000
@RF00124 DS    0H                                                  0168 00433000
*       RFY                                                        0168 00434000
*         R1AREA RSTD;                                             0168 00435000
*                                                                  0168 00436000
*       /*************************************************************/ 00437000
*       /*                                                           */ 00438000
*       /* BEGIN ILRGMA MACRO EXPANSION                              */ 00439000
*       /*                                                           */ 00440000
*       /*************************************************************/ 00441000
*                                                                  0169 00442000
*       DO;                         /* ILRGMA GET                  0169 00443000
*                                      CELL(ACE)WORKREGS(R11,R12)    */ 00444000
*         RESPECIFY                                                0170 00445000
*          (R0,                                                    0170 00446000
*           R1,                                                    0170 00447000
*           R11,                                                   0170 00448000
*           R12,                                                   0170 00449000
*           R14,                                                   0170 00450000
*           R15) RESTRICTED;                                       0170 00451000
*         RESPECIFY                                                0171 00452000
*           ASMPOOLS BASED(R11);                                   0171 00453000
*         RESPECIFY                                                0172 00454000
*           GMACELL BASED(R14);                                    0172 00455000
*         R11=ADDR(ASMACEPC);                                      0173 00456000
         LA    R11,ASMACEPC-ASMVT(,R3)                          DSK1133 00457000
*         LM(R14,R15,ASMCPAVQ);     /* GET ADDR OF 1ST CELL          */ 00458000
         LM    R14,R15,ASMCPAVQ-ASMPOOLS(R11)                   DSK1133 00459000
*GMA00020:                                                         0175 00460000
*         IF R14^=0 THEN            /* TEST CELL POOL                */ 00461000
GMA00020 LTR   R14,R14                                             0175 00462000
         BZ    @RF00175                                            0175 00463000
*           DO;                     /* CELL AVAILABLE, REMOVE CELL   */ 00464000
*             R0=GMANEXT;                                          0177 00465000
         L     R0,GMANEXT(,R14)                                    0177 00466000
*             R1=R15-1;                                            0178 00467000
         LR    R1,R15                                              0178 00468000
         BCTR  R1,0                                                0178 00469000
*             CDS(R14,R0,ASMCPAVQ);                                0179 00470000
         CDS   R14,R0,ASMCPAVQ-ASMPOOLS(R11)                    DSK1133 00471000
*             BC(7,GMA00020);                                      0180 00472000
         BC    7,GMA00020                                          0180 00473000
*             R1=R14;                                              0181 00474000
         LR    R1,R14                                              0181 00475000
*           END;                                                   0182 00476000
*         ELSE                                                     0183 00477000
*           DO;                     /* CELL POOL EMPTY               */ 00478000
         B     @RC00175                                            0183 00479000
@RF00175 DS    0H                                                  0184 00480000
*             R1=R11;               /* PREPARE TO CALL PEX           */ 00481000
         LR    R1,R11                                              0184 00482000
*             CALL ILRPEX;          /* EXTEND THE POOL               */ 00483000
         L     R15,ASMPEX-ASMVT(,R3)                            DSK1133 00484000
         BALR  R14,R15                                          DSK1133 00485000
*           END;                                                   0186 00486000
*         RESPECIFY                                                0187 00487000
*          (R0,                                                    0187 00488000
*           R1,                                                    0187 00489000
*           R11,                                                   0187 00490000
*           R12,                                                   0187 00491000
*           R14,                                                   0187 00492000
*           R15) UNRESTRICTED;                                     0187 00493000
@RC00175 DS    0H                                                  0188 00494000
*       END;                        /* ILRGMA GET                  0188 00495000
*                                      CELL(ACE)WORKREGS(R11,R12)    */ 00496000
*                                                                  0188 00497000
*       /*************************************************************/ 00498000
*       /*                                                           */ 00499000
*       /* END ILRGMA MACRO EXPANSION                                */ 00500000
*       /*                                                           */ 00501000
*       /*************************************************************/ 00502000
*                                                                  0189 00503000
*       IF R1AREA=ZERO THEN                                        0189 00504000
         LTR   R1,R1                                            DSK1133 00505000
         BNZ   @RF00189                                            0189 00506000
*         RTNCODE=CODE28;           /* STORAGE UNAVAILABLE           */ 00507000
         MVC   RTNCODE(4),@CF00438                                 0190 00508000
*       ELSE                                                       0191 00509000
*         DO;                       /* ILRGMA GET SUCCESSFUL, CLEAR     00510000
*                                      AND INITALIZE THE ACE, PROCESS   00511000
*                                      THE REQUEST                   */ 00512000
         B     @RC00189                                            0191 00513000
@RF00189 DS    0H                                                  0192 00514000
*           ACEPTR=R1AREA;          /* OBTAIN ADDRESSIBILITY TO ACE  */ 00515000
         LR    R7,R1                                            DSK1133 00516000
*           ACE=''B;                /* CLEAR THE ACE                 */ 00517000
         XC    ACE(40,R7),ACE(R7)                               DSK1133 00518000
*           EPAACE=ACEPTR;          /* RRR-CHECKPOINT THE ACE IN THE    00519000
*                                      EPATH-RRR                     */ 00520000
         ST    R7,EPAACE                                        DSK1133 00521000
*           ACEOP=ACAOP;            /* PROPAGATE OP CODE             */ 00522000
         IC    R12,ACAOP-ACA(,R9)                               DSK1133 00523000
         STC   R12,ACEOP(,R7)                                   DSK1133 00524000
*           ACELGN=ACALGN;          /* PROPAGATE THE LOGICAL GROUP 0196 00525000
*                                      NUMBER                        */ 00526000
         MVC   ACELGN(8,R7),ACALGN-ACA(R9)                      DSK1133 00527000
*           ACESYM=ACASYM;          /* PROPAGATE THE 'S' SYMBOL      */ 00528000
         MVC   ACESYM(8,R7),ACASYM-ACA(R9)                      DSK1133 00529000
*           ACEGRPRQ=ON;            /* INDICATE A GROUP OP REQUEST   */ 00530000
         OI    ACEGRPRQ(R7),B'10000000'                         DSK1133 00531000
*           IF ACAOP=ACERELLG&ACAFSYM=ON THEN                      0199 00532000
         CLI   ACAOP-ACA(R9),ACERELLG                           DSK1133 00533000
         BNE   @RF00199                                            0199 00534000
         TM    ACAFLG1-ACA(R9),ACAFSYM                          DSK1133 00535000
         BNO   @RF00199                                            0199 00536000
*             ACEUSYM=ON;           /* INDICATES 'S' SYMBOL        0200 00537000
*                                      IDENTIFIES THE LOGICAL GROUP     00538000
*                                      BEING RELEASED                */ 00539000
         OI    ACEUSYM(R7),B'10000000'                          DSK1133 00540000
*                                                                  0201 00541000
*           /*********************************************************/ 00542000
*           /*                                                       */ 00543000
*           /* INPUT WAS DETERMINED TO BE A SAVE OR RELEASE REQUEST, */ 00544000
*           /* DETERMINES IF A RELEASE 'S' SYMBOL AND FINDS LGID IF  */ 00545000
*           /* ONE EXISTS FOR THIS REQUEST                           */ 00546000
*           /*                                                       */ 00547000
*           /*********************************************************/ 00548000
*                                                                  0201 00549000
*           IF ACEOP^=ACEACT THEN                                  0201 00550000
@RF00199 CLI   ACEOP(R7),ACEACT                                 DSK1133 00551000
         BE    @RF00201                                            0201 00552000
*             DO;                   /* NOT AN ACTIVATE REQUEST,    0202 00553000
*                                      PROCESSING FOR SAVE AND     0202 00554000
*                                      RELEASE                       */ 00555000
*               CALL GETLOCK;       /* OBTAIN THE ASM CLASS LOCK     */ 00556000
         BAL   R14,GETLOCK                                      DSK1133 00557000
*               IDEXISTS=ON;        /* INTERNAL FLAG, INITIALIZED ON    00558000
*                                      INDICATING THE LGID EXISTS FOR   00559000
*                                      THE REQUEST                   */ 00560000
         OI    IDEXISTS,B'01000000'                                0204 00561000
*               IF ACEUSYM=ON THEN                                 0205 00562000
         TM    ACEUSYM(R7),B'10000000'                          DSK1133 00563000
         BNO   @RF00205                                            0205 00564000
*                 DO;               /* RELEASE 'S' SYMBOL            */ 00565000
*                   IDEXISTS=OFF;   /* TURN FLAG OFF UNTIL THE LGE IS   00566000
*                                      FOUND ON THE LGE Q            */ 00567000
         NI    IDEXISTS,B'10111111'                                0207 00568000
*                   IF ASHLGEQ^=ZERO THEN                          0208 00569000
         L     R12,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 00570000
         LTR   R12,R12                                          DSK1133 00571000
         BZ    @RC00205                                         DSK1133 00572000
*                     DO;           /* ASMH LGE Q IS NOT EMPTY       */ 00573000
*                       LGEPTR=ASHLGEQ;/* OBTAIN ADDR FIRST ELEMENT     00574000
*                                      ON Q                          */ 00575000
*                                                                  0210 00576000
         LR    R5,R12                                           DSK1133 00577000
*                       /*********************************************/ 00578000
*                       /*                                           */ 00579000
*                       /* SEARCH THE LGE Q FOR THE LGE OF ASPCT WITH*/ 00580000
*                       /* 'S' SYMBOL TO BE RELEASED                 */ 00581000
*                       /*                                           */ 00582000
*                       /*********************************************/ 00583000
*                                                                  0211 00584000
*                       DO UNTIL LGEPTR=ZERO×IDEXISTS=ON;/* UNTIL  0211 00585000
*                                      THERE ARE NO MORE LGES OR THE    00586000
*                                      LGE WITH THE CORRECT 'S'    0211 00587000
*                                      SYMBOL HAS BEEN FOUND         */ 00588000
@DL00211 DS    0H                                                  0212 00589000
*                         IF LGEASPCT=ZERO×LGEASPCT->ASPSSYM^=ACESYM    00590000
*                           THEN                                   0212 00591000
         L     R12,LGEASPCT(,R5)                                DSK1133 00592000
         LTR   R12,R12                                          DSK1133 00593000
         BZ    @RT00212                                            0212 00594000
         CLC   ASPSSYM(8,R12),ACESYM(R7)                        DSK1133 00595000
         BE    @RF00212                                            0212 00596000
@RT00212 DS    0H                                                  0213 00597000
*                           LGEPTR=LGENEXT;/* ASPCT DOES NOT EXIST OR   00598000
*                                      THE 'S' OF THE ASPCT IS NOT 0213 00599000
*                                      THE CORRECT ONE               */ 00600000
         L     R5,LGENEXT(,R5)                                  DSK1133 00601000
*                         ELSE                                     0214 00602000
*                           DO;     /* 'S' SYMBOL TO BE RELEASED WAS    00603000
*                                      FOUND                         */ 00604000
         B     @RC00212                                            0214 00605000
@RF00212 DS    0H                                                  0215 00606000
*                             ACELGID=LGELGID;/* MOVE THE LGID OF THE   00607000
*                                      LG TO BE RELEASED TO THE ACE  */ 00608000
         L     R12,LGELGID(,R5)                                 DSK1133 00609000
         ST    R12,ACELGID(,R7)                                 DSK1133 00610000
*                             IDEXISTS=ON;/* INDICATE LOOP TO END, LG   00611000
*                                      TO BE RELEASED WAS FOUND      */ 00612000
         OI    IDEXISTS,B'01000000'                                0216 00613000
*                           END;    /* END DO FOR 'S' FOUND          */ 00614000
*                       END;        /* END LOOP THRU LGES            */ 00615000
@RC00212 DS    0H                                                  0218 00616000
@DE00211 LTR   R5,R5                                            DSK1133 00617000
         BZ    @DC00211                                            0218 00618000
         TM    IDEXISTS,B'01000000'                                0218 00619000
         BNO   @DL00211                                            0218 00620000
@DC00211 DS    0H                                                  0219 00621000
*                     END;          /* END DO FOR NON-EMPTY ASMH LGE    00622000
*                                      Q                             */ 00623000
*                 END;              /* END RELEASE 'S' REQUEST       */ 00624000
*                                                                  0221 00625000
*               /*****************************************************/ 00626000
*               /*                                                   */ 00627000
*               /* RELEASE LG AND SAVE REQUEST COMMON PROCESSING     */ 00628000
*               /* CHECKS FOR INVALID LGN AND INVALID IDENTIFIER     */ 00629000
*               /* TYPE, ACTIVATE AND RELEASE 'S' REQUESTS WILL NOT  */ 00630000
*               /* COME HERE                                         */ 00631000
*               /*                                                   */ 00632000
*               /*****************************************************/ 00633000
*                                                                  0221 00634000
*               ELSE                                               0221 00635000
*                 DO;               /* RELEASE LG OR SAVE REQUEST  0221 00636000
*                                      PROCESSING                    */ 00637000
         B     @RC00205                                            0221 00638000
@RF00205 DS    0H                                                  0222 00639000
*                   RFY                                            0222 00640000
*                     LGVTPTR RSTD;                                0222 00641000
*                   LGVTPTR=ASMLGVT;/* OBTAIN ADDR OF THE LGVT       */ 00642000
         L     R11,ASMLGVT-ASMVT(,R3)                           DSK1133 00643000
*                   IF ACELGID>LGVMAXLG THEN                       0224 00644000
         L     R12,ACELGID(,R7)                                 DSK1133 00645000
         C     R12,LGVMAXLG(,R11)                               DSK1133 00646000
         BNH   @RF00224                                            0224 00647000
*                     DO;           /* LGN VALUE NOT IN LGVT         */ 00648000
*                       RTNCODE=CODE04;/* LGN INVALID                */ 00649000
         MVC   RTNCODE(4),@CF00051                                 0226 00650000
*                       CALL FREELOCK;/* FREE THE ASM CLASS LOCK     */ 00651000
         BAL   R14,FREELOCK                                     DSK1133 00652000
*                       GO TO FREEACE;/* GET OUT IMMEDIATELY         */ 00653000
         B     FREEACE                                             0228 00654000
*                     END;                                         0229 00655000
*                   RFY                                            0230 00656000
*                     LGVTEPTR RSTD;                               0230 00657000
@RF00224 DS    0H                                                  0231 00658000
*                   LGVTEPTR=ADDR(LGVENTRS(ACELGID+ONE));/* LGID   0231 00659000
*                                      GIVES OFFSET INTO LGVT ENTRIES   00660000
*                                      FOR PROPER LGVTE              */ 00661000
         L     R12,ACELGID(,R7)                                 DSK1133 00662000
         LR    R15,R12                                          DSK1133 00663000
         SLA   R15,3                                            DSK1133 00664000
         LA    R10,LGVENTRS(R15,R11)                            DSK1133 00665000
*                   IF LGVELGID=ACELGID THEN                       0232 00666000
         C     R12,LGVELGID(,R10)                               DSK1133 00667000
         BNE   @RF00232                                            0232 00668000
*                     DO;           /* LGID NOT ASSIGNED             */ 00669000
*                       RTNCODE=CODE04;/* INVALID LGN                */ 00670000
         MVC   RTNCODE(4),@CF00051                                 0234 00671000
*                       CALL FREELOCK;/* FREE THE ASM CLASS LOCK     */ 00672000
         BAL   R14,FREELOCK                                     DSK1133 00673000
*                       GO TO FREEACE;/* GET OUT IMMEDIATELY         */ 00674000
         B     FREEACE                                             0236 00675000
*                     END;                                         0237 00676000
*                   LGEPTR=LGVELGEP;/* OBTAIN LGE ADDR               */ 00677000
@RF00232 L     R5,LGVELGEP(,R10)                                DSK1133 00678000
*                   RFY                                            0239 00679000
*                    (LGVTPTR,                                     0239 00680000
*                     LGVTEPTR) UNRSTD;                            0239 00681000
*                   IF ACEOP=ACERELLG&LGEASPCT->ASPSSYM^=DOUBLE00 THEN  00682000
         CLI   ACEOP(R7),ACERELLG                               DSK1133 00683000
         BNE   @RF00240                                            0240 00684000
         L     R12,LGEASPCT(,R5)                                DSK1133 00685000
         CLC   ASPSSYM(8,R12),@CB01681                          DSK1133 00686000
         BE    @RF00240                                            0240 00687000
*                     DO;           /* RELEASE REQUESTED AND 'S'   0241 00688000
*                                      SYMBOL NEEDED BUT IT WAS NOT     00689000
*                                      SUPPLIED IN THE ACE AS      0241 00690000
*                                      INDICATED BY ACEUSYM          */ 00691000
*                       RTNCODE=CODE40;/* INVALID INDENTIFIER TYPE   */ 00692000
         MVC   RTNCODE(4),@CF00507                                 0242 00693000
*                       CALL FREELOCK;/* FREE THE ASM CLASS LOCK     */ 00694000
         BAL   R14,FREELOCK                                     DSK1133 00695000
*                       GOTO FREEACE;/* GET OUT IMMEDITATELY         */ 00696000
         B     FREEACE                                             0244 00697000
*                     END;                                         0245 00698000
*                 END;              /* END RELEASE LG AND SAVE       */ 00699000
@RF00240 DS    0H                                                  0247 00700000
*                                                                  0247 00701000
*               /*****************************************************/ 00702000
*               /*                                                   */ 00703000
*               /* RELEASE 'S' SYMBOL PROCESSING FOR WHICH THE LGID  */ 00704000
*               /* HAS BEEN FOUND AND SAVE AND RELEASE LG PROCESSING */ 00705000
*               /* COMES HERE                                        */ 00706000
*               /*                                                   */ 00707000
*               /*****************************************************/ 00708000
*                                                                  0247 00709000
*               IF IDEXISTS=ON THEN                                0247 00710000
@RC00205 TM    IDEXISTS,B'01000000'                                0247 00711000
         BNO   @RF00247                                            0247 00712000
*                 DO;               /* SAVE & RELEASE PROCESSING FOR    00713000
*                                      EXISTING LG                   */ 00714000
*                   IF LGERELLG=ON THEN                            0249 00715000
         TM    LGERELLG(R5),B'00100000'                         DSK1133 00716000
         BNO   @RF00249                                            0249 00717000
*                     DO;           /* RELEASE HAS ALREADY BEEN    0250 00718000
*                                      REQUESTED FOR THE LG          */ 00719000
*                       RTNCODE=CODE04;/* LGN NOT VALID FOR REQUEST  */ 00720000
         MVC   RTNCODE(4),@CF00051                                 0251 00721000
*                       CALL FREELOCK;/* FREE THE ASM CLASS LOCK     */ 00722000
         BAL   R14,FREELOCK                                     DSK1133 00723000
*                       GOTO FREEACE;/* GET OUT IMMEDIATELY          */ 00724000
         B     FREEACE                                             0253 00725000
*                     END;                                         0254 00726000
*                   IF ACEOP=ACERELLG THEN                         0255 00727000
@RF00249 CLI   ACEOP(R7),ACERELLG                               DSK1133 00728000
         BNE   @RF00255                                            0255 00729000
*                     LGERELLG=ON;  /* INIDCATE RELEASE REQUESTED FOR   00730000
*                                      LG                            */ 00731000
         OI    LGERELLG(R5),B'00100000'                         DSK1133 00732000
*                   ELSE                                           0257 00733000
*                     DO;           /* SAVE REQUEST                  */ 00734000
         B     @RC00201                                         DSK1133 00735000
@RF00255 DS    0H                                                  0258 00736000
*                       RFY                                        0258 00737000
*                         ASPCTPTR RSTD;                           0258 00738000
*                       ASPCTPTR=LGEASPCT;/* OBTAIN ADDR ASPCT       */ 00739000
         L     R12,LGEASPCT(,R5)                                DSK1133 00740000
*                       IF ASPSSYM=DOUBLE00 THEN/* ASPCT HAS NOT BEEN   00741000
*                                      PREVIOUSLY SAVED              */ 00742000
         CLC   ASPSSYM(8,R12),@CB01681                          DSK1133 00743000
         BNE   @RC00201                                         DSK1133 00744000
*                         DO;       /* GENERATE 'S' SYMBOL FOR THE 0261 00745000
*                                      ASPCT, USE CS                 */ 00746000
*                           RFY                                    0262 00747000
*                            (R0,                                  0262 00748000
*                             R1,                                  0262 00749000
*                             R14,                                 0262 00750000
*                             R15) RSTD;                           0262 00751000
*                           LM(R14,R15,ASMLSAI);/* OBTAIN THE ASM  0263 00752000
*                                      LOCATOR SYMBOL                */ 00753000
         LM    R14,R15,ASMLSAI-ASMVT(R3)                        DSK1133 00754000
*TRYAGAIN:                                                         0264 00755000
*                           R0=R14+ONE;/* INCR LOW PART OF LOC SYMBOL*/ 00756000
TRYAGAIN LA    R0,1                                                0264 00757000
         ALR   R0,R14                                              0264 00758000
*                           IF R0>ASMCINV THEN                     0265 00759000
         C     R0,ASMCINV-ASMVT(,R3)                            DSK1133 00760000
         BNH   @RF00265                                            0265 00761000
*                             DO;   /* IF MAX. NUMBER CONTROL      0266 00762000
*                                      INTERVALS REACHED             */ 00763000
*                               R0=ZERO;/* RESET LOW PART OF LOC   0267 00764000
*                                      SYMBOL                        */ 00765000
         SLR   R0,R0                                               0267 00766000
*                               R1=R15-ONE;/* DECR HIGH PART OF LOC     00767000
*                                      SYMBOL                        */ 00768000
         LR    R1,R15                                              0268 00769000
         BCTR  R1,0                                                0268 00770000
*                             END;                                 0269 00771000
*                           ELSE                                   0270 00772000
*                             R1=R15;/* OBTAIN THE HIGH PART OF LOC     00773000
*                                      SYMBOL                        */ 00774000
         B     @RC00265                                            0270 00775000
@RF00265 LR    R1,R15                                              0270 00776000
*                           CDS(R14,R0,ASMLSAI);/* STORE LOC SYMBOL  */ 00777000
@RC00265 CDS   R14,R0,ASMLSAI-ASMVT(R3)                         DSK1133 00778000
*                           BC(NE,TRYAGAIN);/* NOT SUCCESSFUL, TRY 0272 00779000
*                                      AGAIN                         */ 00780000
         BC    7,TRYAGAIN                                          0272 00781000
*                           STM(R0,R1,ASPSSYM);/* STORE SYMBOL     0273 00782000
*                                      ASSIGNED IN THE ASPCT         */ 00783000
         STM   R0,R1,ASPSSYM(R12)                               DSK1133 00784000
*                           RFY                                    0274 00785000
*                            (ASPCTPTR,                            0274 00786000
*                             R0,                                  0274 00787000
*                             R1,                                  0274 00788000
*                             R14,                                 0274 00789000
*                             R15) UNRSTD;                         0274 00790000
*                         END;      /* END DO FOR ASSIGNING 'S'    0275 00791000
*                                      SYMBOL                        */ 00792000
*                     END;          /* END SAVE REQUEST              */ 00793000
*                 END;              /* END IDEXISTS DO               */ 00794000
*               ELSE                                               0278 00795000
*                 CALL FREELOCK;    /* RELEASE 'S' SYMBOL AND LGID 0278 00796000
*                                      NOT FOUND, RELEASE THE ASM  0278 00797000
*                                      CLASS LOCK                    */ 00798000
         B     @RC00201                                         DSK1133 00799000
@RF00247 BAL   R14,FREELOCK                                     DSK1133 00800000
*             END;                  /* END DO FOR NOT AN ACTIVATE  0279 00801000
*                                      REQUEST                       */ 00802000
*                                                                  0280 00803000
*           /*********************************************************/ 00804000
*           /*                                                       */ 00805000
*           /* RELEASE 'S' REQUESTS FOR WHICH THE LGID COULD NOT BE  */ 00806000
*           /* FOUND AND ACTIVATE REQUESTS ARE PROCESSED BY CALLING  */ 00807000
*           /* THE ASSIGN SUBROUTINE TO ASSIGN AN LG AND BUILD AN    */ 00808000
*           /* LGE, THE LGE IS THEN QUEUED TO THE ASM HEADER LGE     */ 00809000
*           /* QUEUE                                                 */ 00810000
*           /*                                                       */ 00811000
*           /*********************************************************/ 00812000
*                                                                  0280 00813000
*           ELSE                                                   0280 00814000
*             EPAACASR=ON;          /* RRR-INDICATE ASSIGN OR      0280 00815000
*                                      ACTIVATE PROCESSING-RRR       */ 00816000
         B     @RC00201                                            0280 00817000
@RF00201 OI    EPAACASR,B'00001000'                                0280 00818000
*           IF ACEOP=ACEACT×IDEXISTS=OFF THEN                      0281 00819000
@RC00201 CLI   ACEOP(R7),ACEACT                                 DSK1133 00820000
         BE    @RT00281                                            0281 00821000
         TM    IDEXISTS,B'01000000'                                0281 00822000
         BNZ   @RF00281                                            0281 00823000
@RT00281 DS    0H                                                  0282 00824000
*             DO;                   /* ACTIVATE REQUEST OR LGID DOES    00825000
*                                      NOT EXIST                     */ 00826000
*               REQASPCT=OFF;       /* NO ASPCT NEEDED, TAKEN CARE OF   00827000
*                                      BY GROUP OPERATOR             */ 00828000
         NI    REQASPCT,B'01111111'                                0283 00829000
*               CALL ASSIGNLG;      /* BUILD LGE AND ASSIGN A LGN    */ 00830000
         BAL   R14,ASSIGNLG                                     DSK1133 00831000
*               IF RTNCODE=ZERO THEN                               0285 00832000
         L     R12,RTNCODE                                      DSK1133 00833000
         LTR   R12,R12                                          DSK1133 00834000
         BNZ   FREEACE                                          DSK1133 00835000
*                 DO;               /* ASSIGN SUBROUTINE SUCCESSFUL  */ 00836000
*                   RFY                                            0287 00837000
*                     R15 UNRSTD;                                  0287 00838000
*                   CALL GETLOCK;   /* OBTAIN THE ASM CLASS LOCK     */ 00839000
         BAL   R14,GETLOCK                                      DSK1133 00840000
*                   ACELGID=LGELGID;/* PLACE THE LGN ASSIGNED IN THE    00841000
*                                      ACE                           */ 00842000
         L     R12,LGELGID(,R5)                                 DSK1133 00843000
         ST    R12,ACELGID(,R7)                                 DSK1133 00844000
*                   IF ACEOP=ACERELLG THEN                         0290 00845000
         CLI   ACEOP(R7),ACERELLG                               DSK1133 00846000
         BNE   @RC00285                                         DSK1133 00847000
*                     LGERELLG=ON;  /* INDICATE RELEASE REQUEST FOR     00848000
*                                      LG                            */ 00849000
         OI    LGERELLG(R5),B'00100000'                         DSK1133 00850000
*                 END;              /* END SUCCESSFUL ASSIGN       0292 00851000
*                                      SUBROUTINE                    */ 00852000
*               ELSE                                               0293 00853000
*                 GOTO FREEACE;     /* ASSIGN UNSUCCESSFUL, RETURN 0293 00854000
*                                      ACE AND GET OUT IMMEDIATELY   */ 00855000
*             END;                  /* END ACTIVATE, LGID DOES NOT 0294 00856000
*                                      EXIST                         */ 00857000
@RC00285 DS    0H                                                  0295 00858000
*                                                                  0295 00859000
*           /*********************************************************/ 00860000
*           /*                                                       */ 00861000
*           /* QUEUE THE ACE TO THE LGE PROCESS Q, ALL VALID REQUESTS*/ 00862000
*           /* EXCEPT THAT FOR ASSIGN COME HERE                      */ 00863000
*           /*                                                       */ 00864000
*           /*********************************************************/ 00865000
*                                                                  0295 00866000
*           ACELGE=LGEPTR;          /* STORE THE LGE ADDR IN THE ACE */ 00867000
@RF00281 ST    R5,ACELGE(,R7)                                   DSK1133 00868000
*           IF LGEPROCF=ZERO THEN                                  0296 00869000
         L     R12,LGEPROCF(,R5)                                DSK1133 00870000
         LTR   R12,R12                                          DSK1133 00871000
         BNZ   @RF00296                                            0296 00872000
*             DO;                   /* NOTHING ON THE LGE PROCESS  0297 00873000
*                                      QUEUE                         */ 00874000
*               LGEPROCF=ACEPTR;    /* SET FIRST AND LAST QUEUE      */ 00875000
         ST    R7,LGEPROCF(,R5)                                 DSK1133 00876000
*               LGEPROCL=ACEPTR;    /* POINTERS TO ACE ADDR          */ 00877000
         ST    R7,LGEPROCL(,R5)                                 DSK1133 00878000
*               LGEGRINP=ON;        /* SET GROUP OP IN PROGRESS FLAG */ 00879000
         OI    LGEGRINP(R5),B'01000000'                         DSK1133 00880000
*               CALL FREELOCK;      /* FREE THE ASM CLASS LOCK       */ 00881000
         BAL   R14,FREELOCK                                     DSK1133 00882000
*               IF ACEOP=ACERELLG THEN                             0302 00883000
         CLI   ACEOP(R7),ACERELLG                               DSK1133 00884000
         BNE   @RC00296                                         DSK1133 00885000
*                 DO;               /* RELEASE REQUEST, Q EMPTY      */ 00886000
*                   LGESLTCT=ZERO;  /* CLEAR THE SLOT COUNT FOR    0304 00887000
*                                      RETURN BY RELEASE GROUP OP    */ 00888000
         SLR   R12,R12                                          DSK1133 00889000
         STH   R12,LGESLTCT(,R5)                                DSK1133 00890000
*                   RFY                                            0305 00891000
*                    (R1,                                          0305 00892000
*                     R15,                                         0305 00893000
*                     R13) RSTD;                                   0305 00894000
*                   R4SAVE=ATAPTR;  /* SAVE R4, GROUP OPERATOR CANNOT   00895000
*                                      USE ATA                       */ 00896000
         ST    R4,R4SAVE                                        DSK1133 00897000
*                   R4=ADDR(EPATH); /* SET EPATH ADDR FOR GROUP    0307 00898000
*                                      OPERATOR                      */ 00899000
         LA    R4,EPATH                                         DSK1133 00900000
*                   R13=ADDR(SAVAREA);/* ADDR SAVE AREA FOR RELEASE     00901000
*                                      GROUP OP                      */ 00902000
         LA    R13,SAVAREA                                         0308 00903000
*                   R1=ACEPTR;      /* ADDR ACE CONTAINING LGID TO BE   00904000
*                                      RELEASED                      */ 00905000
         LR    R1,R7                                            DSK1133 00906000
*                   CALL ILRRLG;    /* RELEASE GROUP OPERATOR WILL 0310 00907000
*                                      RELEASE THE LG                */ 00908000
         L     R15,ASMPRLG-ASMVT(,R3)                           DSK1133 00909000
         BALR  R14,R15                                          DSK1133 00910000
*                   ATAPTR=R4SAVE;  /* RESTORE ATA ADDR              */ 00911000
         L     R4,R4SAVE                                        DSK1133 00912000
*                   RTNCODE=R15;    /* SAVE THE RETURN CODE          */ 00913000
         ST    R15,RTNCODE                                         0312 00914000
*                   RFY                                            0313 00915000
*                    (R1,                                          0313 00916000
*                     R15,                                         0313 00917000
*                     R13) UNRSTD;                                 0313 00918000
*                 END;              /* END RELEASE REQUEST, Q EMPTY  */ 00919000
*             END;                  /* END LGE PROCESS Q EMPTY       */ 00920000
*           ELSE                                                   0316 00921000
*             DO;                   /* LGE PROCESS Q NOT EMPTY       */ 00922000
         B     @RC00296                                            0316 00923000
@RF00296 DS    0H                                                  0317 00924000
*               LGEPROCL->ACEFQPA=ACEPTR;/* Q ACE TO LAST ACE ON Q   */ 00925000
         L     R12,LGEPROCL(,R5)                                DSK1133 00926000
         ST    R7,ACEFQPA(,R12)                                 DSK1133 00927000
*               ACEBQPA=LGEPROCL;   /* POINT BACK TO PREVIOUS ACE ON    00928000
*                                      Q                             */ 00929000
         ST    R12,ACEBQPA(,R7)                                 DSK1133 00930000
*               LGEPROCL=ACEPTR;    /* MAKE LAST Q ELEMENT THE ACE   */ 00931000
         ST    R7,LGEPROCL(,R5)                                 DSK1133 00932000
*               LGEWRKPD=ON;        /* WORK PENDING FOR THIS LG      */ 00933000
         OI    LGEWRKPD(R5),B'10000000'                         DSK1133 00934000
*               CALL FREELOCK;      /* FREE THE ASM CLASS LOCK       */ 00935000
         BAL   R14,FREELOCK                                     DSK1133 00936000
*                                                                  0322 00937000
*               /*****************************************************/ 00938000
*               /*                                                   */ 00939000
*               /* REQUEST MUST BE FOR SAVE OR RELEASE, SINCE AN LGE */ 00940000
*               /* HAS JUST BEEN ASSIGNED ON AN ACTIVATE REQUEST,    */ 00941000
*               /* THUS ITS PROCESS Q IS EMPTY                       */ 00942000
*               /*                                                   */ 00943000
*               /*****************************************************/ 00944000
*                                                                  0322 00945000
*               IF ACEOP=ACESVLGN THEN                             0322 00946000
         CLI   ACEOP(R7),ACESVLGN                               DSK1133 00947000
         BNE   @RF00322                                            0322 00948000
*                 DO;               /* SAVE REQUEST, Q NOT EMPTY     */ 00949000
*                   LGESAVRQ=ON;    /* SET SAVE REQUEST FLAG IN LGE  */ 00950000
         OI    LGESAVRQ(R5),B'00010000'                         DSK1133 00951000
*                   RFY                                            0325 00952000
*                     ECBPTR RSTD;                                 0325 00953000
*                   ECBPTR=ADDR(ACEECB);/* ADDR ECB TO BE WAITED ON  */ 00954000
         LA    R11,ACEECB(,R7)                                  DSK1133 00955000
*                   GEN REFS(ECBPTR);                              0327 00956000
         WAIT  ECB=(R11)  POSTED BY SRB CONTROLLER              DSK1133 00957000
*                   RFY                                            0328 00958000
*                     ECBPTR UNRSTD;                               0328 00959000
*                   ACEECB=''B;     /* CLEAR THE ACEECB, POSTED BY 0329 00960000
*                                      SRBC                          */ 00961000
         SLR   R12,R12                                          DSK1133 00962000
         ST    R12,ACEECB(,R7)                                  DSK1133 00963000
*                 END;              /* END SAVE REQUEST, Q NOT EMPTY */ 00964000
*             END;                  /* LGE PROCESS Q NOT EMPTY       */ 00965000
@RF00322 DS    0H                                                  0332 00966000
*                                                                  0332 00967000
*           /*********************************************************/ 00968000
*           /*                                                       */ 00969000
*           /* ALL SAVE OR ACTIVATE REQUESTS COME HERE, THE ASMVT    */ 00970000
*           /* BUFFER COUNT IS DECREMENTED OR A BUFFER CONTROL BLOCK */ 00971000
*           /* IS BUILT AND QUEUED TO THE ASMVT VSAM BUFFER WAITING Q*/ 00972000
*           /*                                                       */ 00973000
*           /*********************************************************/ 00974000
*                                                                  0332 00975000
*           IF ACAOP^=ACERELLG THEN                                0332 00976000
@RC00296 CLI   ACAOP-ACA(R9),ACERELLG                           DSK1133 00977000
         BE    @RF00332                                            0332 00978000
*             DO;                   /* SAVE OR ACTIVATE REQUEST      */ 00979000
*               RFY                                                0334 00980000
*                (R11,                                             0334 00981000
*                 R12) RSTD;                                       0334 00982000
*               R12=ASMREQCT;       /* OBTAIN VSAM BUFFER REQUEST  0335 00983000
*                                      COUNT                         */ 00984000
         L     R12,ASMREQCT-ASMVT(,R3)                          DSK1133 00985000
*REDOIT:                                                           0336 00986000
*               IF R12=ZERO THEN                                   0336 00987000
REDOIT   LTR   R12,R12                                             0336 00988000
         BNZ   @RF00336                                            0336 00989000
*                 DO;               /* NO VSAM BUFFERS AVAILABLE     */ 00990000
*                   BUFPTR=ADDR(WKBUFCON);/* OBTAIN THE ADDR OF THE     00991000
*                                      BUFFER CONTROL BLOCK TO BE  0338 00992000
*                                      BUILT IN WORK-SAVE AREA       */ 00993000
         LA    R12,WKBUFCON                                     DSK1133 00994000
*                   BUFASCB=PSAAOLD;/* PUT ADDR THIS ASCB IN CONTROL    00995000
*                                      BLOCK                         */ 00996000
         L     R10,PSAAOLD-PSA                                  DSK1133 00997000
         ST    R10,BUFASCB(,R12)                                DSK1133 00998000
*                   BUFACE=ACEPTR;  /* PUT ADDR THIS ACE IN CONTROL     00999000
*                                      BLOCK                         */ 01000000
         ST    R7,BUFACE(,R12)                                  DSK1133 01001000
*                   RFY                                            0341 01002000
*                     R0 RSTD;                                     0341 01003000
*                   R0=ASMGOSWT;    /* ADDR OF THE VSAM BUFFER     0342 01004000
*                                      WAITING Q                     */ 01005000
         L     R0,ASMGOSWT-ASMVT(,R3)                           DSK1133 01006000
*AGAIN:                                                            0343 01007000
*                   BUFCHAIN=R0;    /* CHAIN WAITING Q TO THE CONTROL   01008000
*                                      BLOCK                         */ 01009000
AGAIN    ST    R0,BUFCHAIN(,R12)                                DSK1133 01010000
*                   CS(R0,BUFPTR,ASMGOSWT);/* MAKE CONTROL BLOCK   0344 01011000
*                                      FIRST ELEMENT ON WAITING Q    */ 01012000
         CS    R0,R12,ASMGOSWT-ASMVT(R3)                        DSK1133 01013000
*                   BC(NE,AGAIN);   /* NOT SUCCESSFUL, TRY AGAIN     */ 01014000
         BC    7,AGAIN                                             0345 01015000
*                   RFY                                            0346 01016000
*                     R0 UNRSTD;                                   0346 01017000
*                   RFY                                            0347 01018000
*                     ECBPTR RSTD;                                 0347 01019000
*                   ECBPTR=ADDR(ACEECB);/* ADDRESS ECB TO BE WAITED     01020000
*                                      ON                            */ 01021000
         LA    R11,ACEECB(,R7)                                  DSK1133 01022000
*                   GEN REFS(ECBPTR);                              0349 01023000
         WAIT  ECB=(R11)  XMPOSTED BY GOS                       DSK1133 01024000
*                   ACEECB=''B;     /* CLEAR ACEECB POSTED BY GOS    */ 01025000
         SLR   R10,R10                                          DSK1133 01026000
         ST    R10,ACEECB(,R7)                                  DSK1133 01027000
*                 END;              /* NO VSAM BUFFER                */ 01028000
*               ELSE                                               0352 01029000
*                 DO;               /* VSAM BUFFERS AVAILABLE        */ 01030000
         B     @RC00336                                            0352 01031000
@RF00336 DS    0H                                                  0353 01032000
*                   R11=R12-ONE;    /* DECR VSAM BUFFER COUNT        */ 01033000
         LR    R11,R12                                             0353 01034000
         BCTR  R11,0                                               0353 01035000
*                   CS(R12,R11,ASMREQCT);/* STORE DECREMENTED COUNT,    01036000
*                                      IF POSSIBLE                   */ 01037000
         CS    R12,R11,ASMREQCT-ASMVT(R3)                       DSK1133 01038000
*                   BC(NE,REDOIT);  /* NOT SUCCESSFUL, TRY AGAIN     */ 01039000
         BC    7,REDOIT                                            0355 01040000
*                   RFY                                            0356 01041000
*                    (R11,                                         0356 01042000
*                     R12) UNRSTD;                                 0356 01043000
*                 END;              /* VSAM BUFFERS AVAILABLE        */ 01044000
*                                                                  0358 01045000
*               /*****************************************************/ 01046000
*               /*                                                   */ 01047000
*               /* THE SLOT COUNT IS CLEARED, THE PROPER OPERATOR IS */ 01048000
*               /* CALLED, AND THE PROPER BUFFER CONTROL FUNCTIONS   */ 01049000
*               /* PERFORMED                                         */ 01050000
*               /*                                                   */ 01051000
*               /*****************************************************/ 01052000
*                                                                  0358 01053000
*               LGESLTCT=ZERO;      /* CLEAR THE SLOT COUNT FOR THE     01054000
*                                      GROUP OPERATOR                */ 01055000
@RC00336 SLR   R12,R12                                          DSK1133 01056000
         STH   R12,LGESLTCT(,R5)                                DSK1133 01057000
*               RFY                                                0359 01058000
*                (R1,                                              0359 01059000
*                 R13,                                             0359 01060000
*                 R15) RSTD;                                       0359 01061000
*               R4SAVE=ATAPTR;      /* SAVE R4, GROUP OPERATOR CANNOT   01062000
*                                      USE ATA                       */ 01063000
         ST    R4,R4SAVE                                        DSK1133 01064000
*               R4=ADDR(EPATH);     /* SET EPATH ADDR FOR GROUP    0361 01065000
*                                      OPERATOR                      */ 01066000
         LA    R4,EPATH                                         DSK1133 01067000
*               R13=ADDR(SAVAREA);  /* ADDR SAVE AREA FOR GROUP    0362 01068000
*                                      OPERATOR                      */ 01069000
         LA    R13,SAVAREA                                         0362 01070000
*               R1=ACEPTR;          /* ADDR ACE CONTAINING SAVE,   0363 01071000
*                                      ACTIVATE REQUEST              */ 01072000
         LR    R1,R7                                            DSK1133 01073000
*               IF ACEOP=ACEACT THEN                               0364 01074000
         CLI   ACEOP(R7),ACEACT                                 DSK1133 01075000
         BNE   @RF00364                                            0364 01076000
*                 CALL ILRACT;      /* ACTIVATE GROUP OPERATOR NEEDED*/ 01077000
         L     R15,ASMPACT-ASMVT(,R3)                           DSK1133 01078000
         BALR  R14,R15                                          DSK1133 01079000
*               ELSE                                               0366 01080000
*                 CALL ILRSAV;      /* SAVE GROUP OPERATOR NEEDED    */ 01081000
         B     @RC00364                                            0366 01082000
@RF00364 L     R15,ASMPSAV-ASMVT(,R3)                           DSK1133 01083000
         BALR  R14,R15                                          DSK1133 01084000
*               ATAPTR=R4SAVE;      /* RESTORE ATA ADDR              */ 01085000
@RC00364 L     R4,R4SAVE                                        DSK1133 01086000
*               RTNCODE=R15;        /* SAVE GROUP OPERATOR           */ 01087000
         ST    R15,RTNCODE                                         0368 01088000
*               RFY                                                0369 01089000
*                 R13 UNRSTD;                                      0369 01090000
*               RFY                                                0370 01091000
*                (R0,                                              0370 01092000
*                 R11,                                             0370 01093000
*                 R12,                                             0370 01094000
*                 R14) RSTD;                                       0370 01095000
*LOOP:                                                             0371 01096000
*               LM(R14,R15,ASMGOSQS);/* OBTAIN THE WAITING AND WORK     01097000
*                                      QUEUES RESPECTIVELY           */ 01098000
LOOP     LM    R14,R15,ASMGOSQS-ASMVT(R3)                       DSK1133 01099000
*REPEAT:                                                           0372 01100000
*               IF R15=ZERO&R14=ZERO THEN                          0372 01101000
REPEAT   SLR   R10,R10                                          DSK1133 01102000
         CR    R15,R10                                          DSK1133 01103000
         BNE   @RF00372                                            0372 01104000
         CR    R14,R10                                          DSK1133 01105000
         BNE   @RF00372                                            0372 01106000
*                 DO;               /* VSAM BUFFER QUES EMPTY        */ 01107000
*                   RFY                                            0374 01108000
*                    (R11,                                         0374 01109000
*                     R12) RSTD;                                   0374 01110000
*                   R12=ASMREQCT;   /* VSAM BUFFER REQUEST COUNT     */ 01111000
         L     R12,ASMREQCT-ASMVT(,R3)                          DSK1133 01112000
*                   R11=R12+ONE;    /* INCR REQUEST COUNT            */ 01113000
         LA    R11,1                                               0376 01114000
         ALR   R11,R12                                             0376 01115000
*                   CS(R12,R11,ASMREQCT);/* STORE INCREMENTED COUNT,    01116000
*                                      IF POSSIBLE                   */ 01117000
         CS    R12,R11,ASMREQCT-ASMVT(R3)                       DSK1133 01118000
*                   BC(NE,LOOP);    /* NOT SUCCESSFUL, TRY AGAIN     */ 01119000
         BC    7,LOOP                                              0378 01120000
*                 END;              /* VSAM BUFFER Q'S EMPTY         */ 01121000
*               ELSE                                               0380 01122000
*                 DO;               /* BUFFER QUEUES NOT EMPTY       */ 01123000
         B     @RC00372                                            0380 01124000
@RF00372 DS    0H                                                  0381 01125000
*                   IF R15=ZERO THEN                               0381 01126000
         LTR   R15,R15                                             0381 01127000
         BNZ   @RF00381                                            0381 01128000
*                     DO;           /* WORK Q EMPTY, WAITING Q NOT 0382 01129000
*                                      EMPTY                         */ 01130000
*                                                                  0382 01131000
*                       /*********************************************/ 01132000
*                       /*                                           */ 01133000
*                       /* COMPARE AND SWAP THE BUFFER WAITING Q TO  */ 01134000
*                       /* THE BUFFER WORK Q                         */ 01135000
*                       /*                                           */ 01136000
*                       /*********************************************/ 01137000
*                                                                  0383 01138000
*                       RFY                                        0383 01139000
*                        (R0,                                      0383 01140000
*                         R14) RSTD;                               0383 01141000
*                       R1=R14;     /* TO MOVE WAITING Q TO WORK Q   */ 01142000
         LR    R1,R14                                              0384 01143000
*                       R0=ZERO;    /* TO ZERO THE WAITING Q         */ 01144000
         SLR   R0,R0                                               0385 01145000
*                       CDS(R14,R0,ASMGOSQS);/* MOVE WAITING Q TO  0386 01146000
*                                      WORK Q                        */ 01147000
         CDS   R14,R0,ASMGOSQS-ASMVT(R3)                        DSK1133 01148000
*                       BC(NE,REPEAT);/* NOT SUCCESSFUL, TRY AGAIN   */ 01149000
         BC    7,REPEAT                                            0387 01150000
*                       R15=R1;     /* OBTAIN NEW WORK QUEUE ADDR    */ 01151000
         LR    R15,R1                                              0388 01152000
*                     END;          /* END WAITING Q TO WORK Q       */ 01153000
*                                                                  0389 01154000
*                   /*************************************************/ 01155000
*                   /*                                               */ 01156000
*                   /* COMPARE AND SWAP THE FIRST ELEMENT OFF THE    */ 01157000
*                   /* BUFFER WORK Q                                 */ 01158000
*                   /*                                               */ 01159000
*                   /*************************************************/ 01160000
*                                                                  0390 01161000
*                   BUFPTR=R15;     /* ADDR OF THE FIRST ELEMENT ON     01162000
*                                      THE VSAM BUFFER WORK Q        */ 01163000
@RF00381 LR    R12,R15                                          DSK1133 01164000
*                   R0=BUFCHAIN;    /* OBTAIN NEXT BUFFER WORK Q   0391 01165000
*                                      ELEMENT                       */ 01166000
         L     R0,BUFCHAIN(,R12)                                DSK1133 01167000
*                   CS(BUFPTR,R0,ASMGOSWK);/* UPDATE WORK Q TO NEXT     01168000
*                                      ELEMENT ON Q                  */ 01169000
         CS    R12,R0,ASMGOSWK-ASMVT(R3)                        DSK1133 01170000
*                   BC(NE,LOOP);    /* NOT SUCCESSFUL, TRY AGAIN     */ 01171000
         BC    7,LOOP                                              0393 01172000
*                   RFY                                            0394 01173000
*                    (R0,                                          0394 01174000
*                     R1,                                          0394 01175000
*                     R14,                                         0394 01176000
*                     R15) UNRSTD;                                 0394 01177000
*                   RFY                                            0395 01178000
*                     ASCBPTR RSTD;                                0395 01179000
*                   ECBPTR=ADDR(BUFACE->ACEECB);/* OBTAIN ECB TO BE     01180000
*                                      POSTED                        */ 01181000
         L     R11,BUFACE(,R12)                                 DSK1133 01182000
         LA    R11,ACEECB(,R11)                                 DSK1133 01183000
*                   ASCBPTR=BUFASCB;/* OBTAIN ASCB OF WAITING ADDRESS   01184000
*                                      SPACE                         */ 01185000
         L     R10,BUFASCB(,R12)                                DSK1133 01186000
*                   R12=ADDR(CVTBRET);/* ADDR ROUTINE GIVEN CONTROL     01187000
*                                      ON POST ERROR                 */ 01188000
         L     R12,CVTPTR                                       DSK1133 01189000
         LA    R12,CVTBRET-CVT(,R12)                            DSK1133 01190000
*                   GEN REFS(ASCBPTR,ECBPTR);                      0399 01191000
*                         /* POST ECB WAITED ON IN ANOTHER              01192000
*    ADDRESS SPACE, XMPOST THE ACEECB */                                01193000
         POST  (R11),ASCB=(R10),ERRET=(R12),MF=(E,POSTLIST)     DSK1133 01194000
*                   RFY                                            0400 01195000
*                    (R11,                                         0400 01196000
*                     ASCBPTR,                                     0400 01197000
*                     R12) UNRSTD;                                 0400 01198000
*                 END;              /* BUFFER QUEUES NOT EMPTY       */ 01199000
*             END;                  /* SAVE OR ACTIVATE REQUEST      */ 01200000
@RC00372 DS    0H                                                  0403 01201000
*                                                                  0403 01202000
*           /*********************************************************/ 01203000
*           /*                                                       */ 01204000
*           /* COMMON BACKEND PROCESSING FOR SAVE OR ACTIVATE        */ 01205000
*           /* REQUESTS, OR A RELEASE REQUEST WITH RETURN CODE OF 28 */ 01206000
*           /*                                                       */ 01207000
*           /*********************************************************/ 01208000
*                                                                  0403 01209000
*           IF ACAOP^=ACERELLG×RTNCODE=CODE28 THEN                 0403 01210000
@RF00332 CLI   ACAOP-ACA(R9),ACERELLG                           DSK1133 01211000
         BNE   @RT00403                                            0403 01212000
         CLC   RTNCODE(4),@CF00438                                 0403 01213000
         BNE   @RF00403                                            0403 01214000
@RT00403 DS    0H                                                  0404 01215000
*             DO;                   /* SAVE OR ACTIVATE, OR RELEASE     01216000
*                                      CODE28 REQUESTS               */ 01217000
*               CALL GETLOCK;       /* OBTAIN THE ASM CLASS LOCK     */ 01218000
*                                                                  0405 01219000
         BAL   R14,GETLOCK                                      DSK1133 01220000
*               /*****************************************************/ 01221000
*               /*                                                   */ 01222000
*               /* DEQUEUE THE ACE FROM THE LGE PROCESS QUEUE        */ 01223000
*               /*                                                   */ 01224000
*               /*****************************************************/ 01225000
*                                                                  0406 01226000
*               IF ACEPTR=LGEPROCF&ACEPTR=LGEPROCL THEN            0406 01227000
         C     R7,LGEPROCF(,R5)                                 DSK1133 01228000
         BNE   @RF00406                                            0406 01229000
         C     R7,LGEPROCL(,R5)                                 DSK1133 01230000
         BNE   @RF00406                                            0406 01231000
*                 DO;               /* ACE IS BOTH FIRST AND LAST ON    01232000
*                                      THE QUEUE                     */ 01233000
*                   LGEPROCF=ZERO;  /* ZERO FIRST ACE ADDR           */ 01234000
         SLR   R12,R12                                          DSK1133 01235000
         ST    R12,LGEPROCF(,R5)                                DSK1133 01236000
*                   LGEPROCL=ZERO;  /* ZERO LAST ACE ADDR            */ 01237000
         ST    R12,LGEPROCL(,R5)                                DSK1133 01238000
*                 END;                                             0410 01239000
*               ELSE                                               0411 01240000
*                 IF ACEPTR=LGEPROCF THEN                          0411 01241000
         B     @RC00406                                            0411 01242000
@RF00406 C     R7,LGEPROCF(,R5)                                 DSK1133 01243000
         BNE   @RF00411                                            0411 01244000
*                   DO;             /* ACE IS FIRST ON Q BUT NOT THE    01245000
*                                      ONLY QUEUE ELEMENT            */ 01246000
*                     LGEPROCF=ACEFQPA;/* SET FIRST ACE ADDR TO NEXT    01247000
*                                      ACE ON QUEUE                  */ 01248000
         L     R12,ACEFQPA(,R7)                                 DSK1133 01249000
         ST    R12,LGEPROCF(,R5)                                DSK1133 01250000
*                     ACEFQPA->ACEBQPA=ZERO;/* CLEAR BACK POINTER OF    01251000
*                                      NEXT ACE                      */ 01252000
         SLR   R10,R10                                          DSK1133 01253000
         ST    R10,ACEBQPA(,R12)                                DSK1133 01254000
*                   END;                                           0415 01255000
*                 ELSE                                             0416 01256000
*                   DO;             /* ACE WAS NOT FIRST             */ 01257000
*                                                                  0416 01258000
         B     @RC00411                                            0416 01259000
@RF00411 DS    0H                                                  0417 01260000
*                     /***********************************************/ 01261000
*                     /*                                             */ 01262000
*                     /* AN IMPOSSIBLE SITUATION EXISTS, ERROR MUST  */ 01263000
*                     /* BE RECORDED, ACE POINTER CLEARED, AND RETURN*/ 01264000
*                     /* CODE SET                                    */ 01265000
*                     /*                                             */ 01266000
*                     /***********************************************/ 01267000
*                                                                  0417 01268000
*                     CALL FREELOCK;/* FREE THE ASM CLASS LOCK       */ 01269000
         BAL   R14,FREELOCK                                     DSK1133 01270000
*                     ATARCODE=REACOD12;/* REASON CODE FOR C0D ABEND */ 01271000
         MVI   ATARCODE(R4),X'0C'                               DSK1133 01272000
*                     EPARTYRG=ADDR(RTRYRGSV);/* ADDR RETRY REGISTERS*/ 01273000
         LA    R12,RTRYRGSV                                     DSK1133 01274000
         ST    R12,EPARTYRG                                     DSK1133 01275000
*                     STM(R0,R14,RTRYRGSV);/* SAVE RETRY REGS        */ 01276000
         STM   R0,R14,RTRYRGSV                                     0420 01277000
*                     GEN(ABEND    X'C0D',,,SYSTEM);/* ISSUE C0D   0421 01278000
*                                      RECORD ONLY ABEND             */ 01279000
         ABEND    X'C0D',,,SYSTEM                                       01280000
*                     ACEPTR=ZERO;  /* CLEAR THE ACE POINTER         */ 01281000
         SLR   R7,R7                                            DSK1133 01282000
*                     RTNCODE=CODE44;/* INDETERMINENT ERROR, ACE NOT    01283000
*                                      FIRST ON Q                    */ 01284000
         MVC   RTNCODE(4),@CF01405                                 0423 01285000
*                     GO TO FREEWK; /* FREE THE WORK-SAVE AREA AND 0424 01286000
*                                      GET OUT IMMEDIATELY           */ 01287000
         B     FREEWK                                              0424 01288000
*                   END;            /* ACE WAS NOT FIRST             */ 01289000
*                                                                  0426 01290000
*               /*****************************************************/ 01291000
*               /*                                                   */ 01292000
*               /* PROCESSING FOR A RELEASE REQUEST FOR WHICH ILRRLG */ 01293000
*               /* HAS RETURNED WITH A CODE28, NO STORAGE AVAILABLE. */ 01294000
*               /* THE LGE IS FREED IF THERE IS NO ASPCT, ELSE PROPER*/ 01295000
*               /* LGE FLAGS ARE RESET.                              */ 01296000
*               /*                                                   */ 01297000
*               /*****************************************************/ 01298000
*                                                                  0426 01299000
*               IF ACEOP=ACERELLG THEN                             0426 01300000
@RC00411 DS    0H                                                  0426 01301000
@RC00406 CLI   ACEOP(R7),ACERELLG                               DSK1133 01302000
         BNE   @RF00426                                            0426 01303000
*                 DO;               /* RELEASE, CODE28               */ 01304000
*                   IF LGEASPCT=ZERO THEN/* AN ASPCT DOES NOT EXIST     01305000
*                                      FOR THIS LG                   */ 01306000
*                                                                  0428 01307000
         L     R12,LGEASPCT(,R5)                                DSK1133 01308000
         LTR   R12,R12                                          DSK1133 01309000
         BNZ   @RF00428                                            0428 01310000
*                     /***********************************************/ 01311000
*                     /*                                             */ 01312000
*                     /* THE ADDR OF THE LGE TO BE FREED IS IN       */ 01313000
*                     /* LGEPTR. FRELG WILL RELEASE THE ASM CLASS    */ 01314000
*                     /* LOCK.                                       */ 01315000
*                     /*                                             */ 01316000
*                     /***********************************************/ 01317000
*                                                                  0429 01318000
*                     CALL FRELG;   /* DEQUEUES AND FREES THE LGE, 0429 01319000
*                                      AND PUTS THE LGVTE BACK ON THE   01320000
*                                      AVAILABLE QUEUE               */ 01321000
         BAL   R14,FRELG                                        DSK1133 01322000
*                   ELSE                                           0430 01323000
*                     DO;           /* ASPCT DOES EXIST              */ 01324000
         B     @RC00426                                         DSK1133 01325000
@RF00428 DS    0H                                                  0431 01326000
*                       LGERELLG=OFF;/* RESET RELEASE LG REQUEST FLAG*/ 01327000
*                       LGEGRINP=OFF;/* RESET GROUP OP IN PROGRESS 0432 01328000
*                                      FLAG                          */ 01329000
         NI    LGERELLG(R5),B'10011111'                         DSK1133 01330000
*                       CALL FREELOCK;/* FREE THE ASM CLASS LOCK     */ 01331000
         BAL   R14,FREELOCK                                     DSK1133 01332000
*                     END;          /* ASPCT DOES EXIST              */ 01333000
*                 END;              /* RELEASE, CODE28               */ 01334000
*                                                                  0436 01335000
*               /*****************************************************/ 01336000
*               /*                                                   */ 01337000
*               /* PROCESSING FOR SAVES AND ACTIVATES, THE VIO SLOT  */ 01338000
*               /* COUNT IS UPDATED, GROUP OP IN PROGRESS FLAG RESET,*/ 01339000
*               /* AND THE SRB CONTROLLER SCHEDULED IF WORK IS       */ 01340000
*               /* PENDING. ALSO, FOR SAVES, THE SAVE REQUEST FLAG IS*/ 01341000
*               /* RESET IF NO OTHER SAVE REQUESTS ARE ON THE QUEUE. */ 01342000
*               /*                                                   */ 01343000
*               /*****************************************************/ 01344000
*                                                                  0436 01345000
*               ELSE                                               0436 01346000
*                 DO;               /* SAVE OR ACTIVATE BACKEND      */ 01347000
         B     @RC00426                                            0436 01348000
@RF00426 DS    0H                                                  0437 01349000
*                   IF ACEOP=ACESVLGN THEN                         0437 01350000
         CLI   ACEOP(R7),ACESVLGN                               DSK1133 01351000
         BNE   @RF00437                                            0437 01352000
*                     DO;           /* SAVE LGN REQUEST              */ 01353000
*                       LGESAVRQ=OFF;/* RESET SAVE REQUEST FLAG      */ 01354000
         NI    LGESAVRQ(R5),B'11101111'                         DSK1133 01355000
*                       RFY                                        0440 01356000
*                         FOUNDACE RSTD;                           0440 01357000
*                       FOUNDACE=LGEPROCF;/* OBTAIN ADDR FIRST ACE ON   01358000
*                                      PROCESS Q                     */ 01359000
         L     R10,LGEPROCF(,R5)                                DSK1133 01360000
*                       DO WHILE FOUNDACE^=ZERO&FOUNDACE->ACEOP^=  0442 01361000
*                             ACESVLGN;/* SEARCH FOR A SAVE REQUEST     01362000
*                                      ACE                           */ 01363000
         B     @DE00442                                            0442 01364000
@DL00442 DS    0H                                                  0443 01365000
*                         FOUNDACE=FOUNDACE->ACEFQPA;/* OBTAIN ADDR     01366000
*                                      NEXT ACE ON PROCESS QUEUE     */ 01367000
         L     R10,ACEFQPA(,R10)                                DSK1133 01368000
*                       END;                                       0444 01369000
@DE00442 LTR   R10,R10                                          DSK1133 01370000
         BZ    @DC00442                                            0444 01371000
         CLI   ACEOP(R10),ACESVLGN                              DSK1133 01372000
         BNE   @DL00442                                            0444 01373000
@DC00442 DS    0H                                                  0445 01374000
*                       IF FOUNDACE^=ZERO THEN                     0445 01375000
         LTR   R10,R10                                          DSK1133 01376000
         BZ    @RF00445                                            0445 01377000
*                         LGESAVRQ=ON;/* IF A SAVE REQUEST ACE IS  0446 01378000
*                                      FOUND TURN THE FLAG BACK ON   */ 01379000
         OI    LGESAVRQ(R5),B'00010000'                         DSK1133 01380000
*                       RFY                                        0447 01381000
*                         FOUNDACE UNRSTD;                         0447 01382000
@RF00445 DS    0H                                                  0448 01383000
*                     END;          /* SAVE LGN REQUEST              */ 01384000
*                   LGEGRINP=OFF;   /* RESET GROUP-OP IN PROGRESS  0449 01385000
*                                      FLAG                          */ 01386000
@RF00437 NI    LGEGRINP(R5),B'10111111'                         DSK1133 01387000
*                   IF LGEWRKPD=ON THEN                            0450 01388000
         TM    LGEWRKPD(R5),B'10000000'                         DSK1133 01389000
         BNO   @RF00450                                            0450 01390000
*                     IF ASHSCHED=OFF THEN                         0451 01391000
         TM    ASHFLAG2-ASMHD+RSMASMHD-RSMHD(R2),ASHSCHED       DSK1133 01392000
         BNZ   @RF00451                                            0451 01393000
*                       DO;         /* SCHEDULE THE SRB CONTROLLER 0452 01394000
*                                      SINCE WORK IS PENDING AND SRBC   01395000
*                                      HAS NOT BEEN SCHEDULED        */ 01396000
*                         RFY                                      0453 01397000
*                           R10 RSTD;                              0453 01398000
*                         R10=ASHVSRBP;/* ADDR SRB TO BE SCHEDULED   */ 01399000
         L     R10,ASHVSRBP-ASMHD+RSMASMHD-RSMHD(,R2)           DSK1133 01400000
*                         GEN REFS(R10);                           0455 01401000
      SCHEDULE SRB=(10),SCOPE=GLOBAL    SCHEDULES SRB CONTROLLER        01402000
*                         ASHSCHED=ON;/* SET SRB SCHEDULED FLAG      */ 01403000
         OI    ASHFLAG2-ASMHD+RSMASMHD-RSMHD(R2),ASHSCHED       DSK1133 01404000
*                       END;        /* END SCHEDULE SRBC             */ 01405000
*                   ASCBPTR=PSAAOLD;/* OBTAIN ADDR ASCB              */ 01406000
@RF00451 DS    0H                                                  0458 01407000
@RF00450 L     R10,PSAAOLD-PSA                                  DSK1133 01408000
*                   ASCBVSC=ASCBVSC+LGESLTCT;/* UPDATE THE VIO SLOT     01409000
*                                      COUNT BY THE SLOT COUNT     0459 01410000
*                                      RETURNED BY THE GROUP OPERATOR*/ 01411000
         LH    R12,ASCBVSC-ASCB(,R10)                           DSK1133 01412000
         AH    R12,LGESLTCT(,R5)                                DSK1133 01413000
         STH   R12,ASCBVSC-ASCB(,R10)                           DSK1133 01414000
*                   RFY                                            0460 01415000
*                     R10 UNRSTD;                                  0460 01416000
*                   IF RTNCODE=CODE00 THEN                         0461 01417000
         L     R12,RTNCODE                                      DSK1133 01418000
         LTR   R12,R12                                          DSK1133 01419000
         BNZ   @RF00461                                            0461 01420000
*                     CALL FREELOCK;/* GOOD RETURN FROM SAVE OR    0462 01421000
*                                      ACTIVATE, FREE THE ASM CLASS     01422000
*                                      LOCK                          */ 01423000
         BAL   R14,FREELOCK                                     DSK1133 01424000
*                   ELSE                                           0463 01425000
*                     DO;           /* ERROR RETURN FROM SAVE OR   0463 01426000
*                                      ACTIVATE                      */ 01427000
         B     @RC00461                                            0463 01428000
@RF00461 DS    0H                                                  0464 01429000
*                       IF ACEOP=ACEACT THEN                       0464 01430000
         CLI   ACEOP(R7),ACEACT                                 DSK1133 01431000
         BNE   @RF00464                                            0464 01432000
*                         DO;       /* ACTIVATE ERROR                */ 01433000
*                           ACELGID=FOXES;/* INVALIDATE THE LGID FOR    01434000
*                                      VBP                           */ 01435000
         MVC   ACELGID(4,R7),@CF01677                           DSK1133 01436000
*                           EPALGEP=ZERO;/* RRR-STOP TRACKING LGE TO    01437000
*                                      BE FREED-RRR                  */ 01438000
*                                                                  0467 01439000
         SLR   R12,R12                                          DSK1133 01440000
         ST    R12,EPALGEP                                      DSK1133 01441000
*                           /*****************************************/ 01442000
*                           /*                                       */ 01443000
*                           /* THE ADDR OF THE LGE TO BE FREED IS IN */ 01444000
*                           /* LGEPTR. FRELG WILL RELEASE THE ASM    */ 01445000
*                           /* CLASS LOCK.                           */ 01446000
*                           /*                                       */ 01447000
*                           /*****************************************/ 01448000
*                                                                  0468 01449000
*                           CALL FRELG;/* DEQUEUE AND FREE THE LGE,     01450000
*                                      MAKE LGVTE AVAILIABLE         */ 01451000
         BAL   R14,FRELG                                        DSK1133 01452000
*                         END;      /* ACTIVATE ERROR                */ 01453000
*                       ELSE                                       0470 01454000
*                         DO;       /* SAVE ERROR                    */ 01455000
         B     @RC00464                                            0470 01456000
@RF00464 DS    0H                                                  0471 01457000
*                           LGEASPCT->ASPSSYM=''B;/* CLEAR 'S' SYMBOL   01458000
*                                      IN ASPCT                      */ 01459000
         L     R12,LGEASPCT(,R5)                                DSK1133 01460000
         XC    ASPSSYM(8,R12),ASPSSYM(R12)                      DSK1133 01461000
*                           ACESYM=''B;/* CLEAR 'S' SYMBOL IN ACE    */ 01462000
         XC    ACESYM(8,R7),ACESYM(R7)                          DSK1133 01463000
*                           CALL FREELOCK;/* FREE THE ASM CLASS LOCK */ 01464000
         BAL   R14,FREELOCK                                     DSK1133 01465000
*                         END;      /* END SAVE ERROR                */ 01466000
*                     END;          /* END ERROR RETURN FROM SAVE OR    01467000
*                                      ACTIVATE                      */ 01468000
*                                                                  0475 01469000
@RC00464 DS    0H                                                  0476 01470000
*                   /*************************************************/ 01471000
*                   /*                                               */ 01472000
*                   /* THE ACA IS IN USER'S STORAGE AND THUS MAY BE  */ 01473000
*                   /* PAGEABLE SO THE ACA CANNOT BE REFERENCED WHILE*/ 01474000
*                   /* HOLDING THE ASM CLASS LOCK                    */ 01475000
*                   /*                                               */ 01476000
*                   /*************************************************/ 01477000
*                                                                  0476 01478000
*                   IF ACEOP=ACEACT THEN                           0476 01479000
@RC00461 CLI   ACEOP(R7),ACEACT                                 DSK1133 01480000
         BNE   @RF00476                                            0476 01481000
*                     ACALGN=ACELGN;/* ACTIVATE, MOVE THE LGN TO THE    01482000
*                                      ACA                           */ 01483000
         MVC   ACALGN-ACA(8,R9),ACELGN(R7)                      DSK1133 01484000
*                   ELSE                                           0478 01485000
*                     ACASYM=ACESYM;/* SAVE, MOVE THE 'S' SYMBOL TO     01486000
*                                      THE ACA                       */ 01487000
         B     @RC00476                                            0478 01488000
@RF00476 MVC   ACASYM-ACA(8,R9),ACESYM(R7)                      DSK1133 01489000
*                 END;              /* SAVE OR ACTIVATE BACKEND      */ 01490000
@RC00476 DS    0H                                                  0480 01491000
*                                                                  0480 01492000
*               /*****************************************************/ 01493000
*               /*                                                   */ 01494000
*               /* AT THIS POINT THE ACE IS FREED VIA THE ILRGMA     */ 01495000
*               /* MACRO. ALL REQUESTS FOR WHICH AN ACE WAS OBTAINED */ 01496000
*               /* COME HERE, EXCEPT A VALID RELEASE REQUEST FOR     */ 01497000
*               /* WHICH THE RELEASE GROUP OPERATOR WAS NOT CALLED OR*/ 01498000
*               /* FOR WHICH THE RELEASE GROUP OPERATOR WAS CALLED   */ 01499000
*               /* AND A RETURN CODE OF 28 WAS NOT RECEIVED.         */ 01500000
*               /*                                                   */ 01501000
*               /*****************************************************/ 01502000
*                                                                  0480 01503000
*               RFY                                                0480 01504000
*                 R1AREA RSTD;                                     0480 01505000
@RC00426 DS    0H                                                  0481 01506000
*FREEACE:                                                          0481 01507000
*               R1AREA=ACEPTR;      /* OBTAIN ADDR ACE TO BE FREED   */ 01508000
FREEACE  LR    R1,R7                                            DSK1133 01509000
*               EPAACE=ZERO;        /* RRR-CLEAR THE ACE ADDR TRACKED   01510000
*                                      IN EPATH-RRR                  */ 01511000
*                                                                  0482 01512000
         SLR   R12,R12                                          DSK1133 01513000
         ST    R12,EPAACE                                       DSK1133 01514000
*               /*****************************************************/ 01515000
*               /*                                                   */ 01516000
*               /* BEGIN ILRGMA MACRO EXPANSION                      */ 01517000
*               /*                                                   */ 01518000
*               /*****************************************************/ 01519000
*                                                                  0483 01520000
*               DO;                 /* ILRGMA FREE                 0483 01521000
*                                      CELL(ACE)WORKREGS(R11,R12)    */ 01522000
*                 RESPECIFY                                        0484 01523000
*                  (R0,                                            0484 01524000
*                   R1,                                            0484 01525000
*                   R11,                                           0484 01526000
*                   R12,                                           0484 01527000
*                   R14,                                           0484 01528000
*                   R15) RESTRICTED;                               0484 01529000
*                 RESPECIFY                                        0485 01530000
*                   ASMPOOLS BASED(R11);                           0485 01531000
*                 RESPECIFY                                        0486 01532000
*                   GMACELL BASED(R1);                             0486 01533000
*                 R11=ADDR(ASMACEPC);                              0487 01534000
         LA    R11,ASMACEPC-ASMVT(,R3)                          DSK1133 01535000
*                 LM(R14,R15,ASMCPRSQ);/* GET CONTENTS OF Q          */ 01536000
         LM    R14,R15,ASMCPRSQ-ASMPOOLS(R11)                   DSK1133 01537000
*GMA00031:                                                         0489 01538000
*                 IF R14^=0 THEN    /* TEST RESERVE Q                */ 01539000
GMA00031 LTR   R14,R14                                             0489 01540000
         BZ    @RF00489                                            0489 01541000
*                   DO;             /* REPLENISH ACE RESERVE Q       */ 01542000
*                     R0=R14-1;     /* SET UP FOR COMPARE AND SWAP   */ 01543000
         LR    R0,R14                                              0491 01544000
         BCTR  R0,0                                                0491 01545000
*                     GMANEXT=R15;  /* CELL TO FREE IN R1            */ 01546000
         ST    R15,GMANEXT(,R1)                                    0492 01547000
*                     CDS(R14,R0,ASMCPRSQ);/* ADD CELL TO RESERVE Q  */ 01548000
         CDS   R14,R0,ASMCPRSQ-ASMPOOLS(R11)                    DSK1133 01549000
*                     BC(7,GMA00031);                              0494 01550000
         BC    7,GMA00031                                          0494 01551000
*                   END;                                           0495 01552000
*                 ELSE                                             0496 01553000
*                   DO;             /* RETURN ACE TO NORMAL Q        */ 01554000
         B     @RC00489                                            0496 01555000
@RF00489 DS    0H                                                  0497 01556000
*                     R14=ASMCPAVL;                                0497 01557000
         L     R14,ASMCPAVL-ASMPOOLS(,R11)                      DSK1133 01558000
*GMA00032:                                                         0498 01559000
*                     GMANEXT=R14;  /* PUT ADDR CURRENT FIRST IN   0498 01560000
*                                      INPUT CELL                    */ 01561000
GMA00032 ST    R14,GMANEXT(,R1)                                    0498 01562000
*                     CS(R14,R1,ASMCPAVL);/* ADD INPUT CELL TO POOL  */ 01563000
         CS    R14,R1,ASMCPAVL-ASMPOOLS(R11)                    DSK1133 01564000
*                     BC(7,GMA00032);                              0500 01565000
         BC    7,GMA00032                                          0500 01566000
*                   END;            /* ACE RETURNED TO NORMAL Q      */ 01567000
*                 RESPECIFY                                        0502 01568000
*                  (R0,                                            0502 01569000
*                   R1,                                            0502 01570000
*                   R11,                                           0502 01571000
*                   R12,                                           0502 01572000
*                   R14,                                           0502 01573000
*                   R15) UNRESTRICTED;                             0502 01574000
@RC00489 DS    0H                                                  0503 01575000
*               END;                /* ILRGMA FREE                 0503 01576000
*                                      CELL(ACE)WORKREGS(R11,R12)    */ 01577000
*                                                                  0503 01578000
*               /*****************************************************/ 01579000
*               /*                                                   */ 01580000
*               /* END ILRGMA MACRO EXPANSION                        */ 01581000
*               /*                                                   */ 01582000
*               /*****************************************************/ 01583000
*                                                                  0504 01584000
*             END;                  /* SAVE OR ACTIVATE, OR RELEASE     01585000
*                                      CODE 28 REQUESTS              */ 01586000
*         END;                      /* ILRGMA GET SUCCESSFUL         */ 01587000
@RF00403 DS    0H                                                  0506 01588000
*     END;                          /* RELEASE, ACTIVATE, SAVE     0506 01589000
*                                      PROCESSING                    */ 01590000
@RC00189 DS    0H                                                  0507 01591000
*                                                                  0507 01592000
*   /*****************************************************************/ 01593000
*   /*                                                               */ 01594000
*   /* ALL PROCESSING FOR WHICH A WORK-SAVE AREA WAS OBTAINED COMES  */ 01595000
*   /* HERE, EXCEPT FOR AN ESTAE ERROR IN WHICH CASE THE WORK-SAVE   */ 01596000
*   /* AREA HAS ALREADY BEEN DELETED.                                */ 01597000
*   /*                                                               */ 01598000
*   /*****************************************************************/ 01599000
*                                                                  0507 01600000
*   RFY                                                            0507 01601000
*     R13 RSTD;                                                    0507 01602000
@RC00124 DS    0H                                                  0508 01603000
*FREEWK:                                                           0508 01604000
*   GEN SETS(R11,R13);                                             0508 01605000
FREEWK   DS    0H                                                  0508 01606000
*                          /* RESTORE THE CALLERS SAVE AREA ADDR */     01607000
       LA    R11,SAVAREA        ADDR SAVE AREA                          01608000
       L     R13,4(R11)         RESTORE ADDR CALLERS SAVE AREA          01609000
       MVC   16(4,R13),RTNCODE  SET RETURN CODE IN CALLERS SAVE AREA    01610000
*   IF ACAOP=ASSIGN×ACAOP=ACERELLG THEN                            0509 01611000
         CLI   ACAOP-ACA(R9),ACEASGLG                           DSK1133 01612000
         BE    @RT00509                                            0509 01613000
         CLI   ACAOP-ACA(R9),ACERELLG                           DSK1133 01614000
         BNE   @RF00509                                            0509 01615000
@RT00509 DS    0H                                                  0510 01616000
*     DO;                           /* DELETE RECOVERY AND FREE    0510 01617000
*                                      WORK-SAVE AREA FOR LOCKED   0510 01618000
*                                      PATHS                         */ 01619000
*       GEN REFS(R11,R12);                                         0511 01620000
     SETFRR D,WRKREGS=(R11,R12),RELATED=(SETFRR,ILRGOS)                 01621000
*       R1AREA=WKSAV@;              /* OBTAIN ADDR WORK AREA TO BE 0512 01622000
*                                      FREED                         */ 01623000
*                                                                  0512 01624000
         LR    R1,R8                                            DSK1133 01625000
*       /*************************************************************/ 01626000
*       /*                                                           */ 01627000
*       /* BEGIN ILRGMA MACRO EXPANSION                              */ 01628000
*       /*                                                           */ 01629000
*       /*************************************************************/ 01630000
*                                                                  0513 01631000
*       DO;                         /* ILRGMA FREE                 0513 01632000
*                                      CELL(BWK)WORKREGS(R11,R12)    */ 01633000
*         RESPECIFY                                                0514 01634000
*          (R0,                                                    0514 01635000
*           R1,                                                    0514 01636000
*           R11,                                                   0514 01637000
*           R12,                                                   0514 01638000
*           R14,                                                   0514 01639000
*           R15) RESTRICTED;                                       0514 01640000
*         RESPECIFY                                                0515 01641000
*           ASMPOOLS BASED(R11);                                   0515 01642000
*         RESPECIFY                                                0516 01643000
*           GMACELL BASED(R1);                                     0516 01644000
*         R11=ADDR(ASMBWKPC);                                      0517 01645000
         LA    R11,ASMBWKPC-ASMVT(,R3)                          DSK1133 01646000
*         R14=ASMCPAVL;                                            0518 01647000
         L     R14,ASMCPAVL-ASMPOOLS(,R11)                      DSK1133 01648000
*GMA00042:                                                         0519 01649000
*         GMANEXT=R14;              /* PUT ADDR CURRENT FIRST IN   0519 01650000
*                                      INPUT CELL                    */ 01651000
GMA00042 ST    R14,GMANEXT(,R1)                                    0519 01652000
*         CS(R14,R1,ASMCPAVL);      /* ADD INPUT CELL TO POOL        */ 01653000
         CS    R14,R1,ASMCPAVL-ASMPOOLS(R11)                    DSK1133 01654000
*         BC(7,GMA00042);                                          0521 01655000
         BC    7,GMA00042                                          0521 01656000
*         RESPECIFY                                                0522 01657000
*          (R0,                                                    0522 01658000
*           R1,                                                    0522 01659000
*           R11,                                                   0522 01660000
*           R12,                                                   0522 01661000
*           R14,                                                   0522 01662000
*           R15) UNRESTRICTED;                                     0522 01663000
*       END;                        /* ILRGMA FREE                 0523 01664000
*                                      CELL(BWK)WORKREGS(R11,R12)    */ 01665000
*                                                                  0523 01666000
*       /*************************************************************/ 01667000
*       /*                                                           */ 01668000
*       /* END ILRGMA MACRO EXPANSION                                */ 01669000
*       /*                                                           */ 01670000
*       /*************************************************************/ 01671000
*                                                                  0524 01672000
*     END;                          /* END LOCKED PATHS EXITING      */ 01673000
*   ELSE                                                           0525 01674000
*     DO;                           /* DELETE REOCVERY AND FREE    0525 01675000
*                                      WORK-SAVE AREA FOR UNLOCKED 0525 01676000
*                                      PATHS                         */ 01677000
         B     @EL00001                                         DSK1133 01678000
@RF00509 DS    0H                                                  0526 01679000
*       RFY                                                        0526 01680000
*         R11 RSTD;                                                0526 01681000
*       R11=LENGTH(WKAREA);         /* OBTAIN LENGTH AREA TO BE FREED*/ 01682000
         LA    R11,256                                             0527 01683000
*       GEN REFS(R11,WKSAV@) SETS(R1);                             0528 01684000
*                              /* CANCEL ESTAE AND FREE WORK AREA */    01685000
         ESTAE 0        CANCEL ESTAE                                    01686000
         FREEMAIN RC,LV=(R11),A=(R8),SP=245                     DSK1133 01687000
*     END;                          /* END UNLOCKED PATHS EXITING    */ 01688000
*GOSEND:                                                           0530 01689000
*   RETURN;                         /* RESTORE REGS AND RETURN TO  0530 01690000
*                                      CALLER                        */ 01691000
@EL00001 DS    0H                                                  0530 01692000
@EF00001 DS    0H                                                  0530 01693000
@ER00001 LM    R14,R12,12(R13)                                  DSK1133 01694000
         BR    R14                                              DSK1133 01695000
*                                                                  0531 01696000
*   /*****************************************************************/ 01697000
*   /*                                                               */ 01698000
*   /* GETLOCK WILL OBTAIN THE ASM CLASS LOCK UNCONDITIONALLY.       */ 01699000
*   /* REGISTERS R2-R4 ARE STANDARD AS UNDER MAPPING MACRO POINTERS. */ 01700000
*   /* R14 CONTAINS THE RETURN ADDR.                                 */ 01701000
*   /*                                                               */ 01702000
*   /*****************************************************************/ 01703000
*                                                                  0531 01704000
*GETLOCK:                                                          0531 01705000
*   PROCEDURE OPTIONS(NOSAVE,NOSAVEAREA);                          0531 01706000
GETLOCK  DS    0H                                                  0532 01707000
*   RFY                                                            0532 01708000
*    (R11,                                                         0532 01709000
*     R10,                                                         0532 01710000
*     R14) RSTD;                                                   0532 01711000
*   R10=R14;                        /* MAINTAIN RETURN ADDR          */ 01712000
         LR    R10,R14                                             0533 01713000
*   R11=ADDR(ASHLOCK);              /* OBTAIN ADDR ASM LOCKWORD      */ 01714000
         LA    R11,ASHLOCK-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 01715000
*   GEN REFS(R11);                                                 0535 01716000
GETASM1  SETLOCK OBTAIN,TYPE=ASM,ADDR=(11),MODE=UNCOND,               **01717000
               RELATED=(VIO,ILRGOS(FREASM1))                            01718000
*   R14=R10;                        /* RESTORE RETURN ADDR           */ 01719000
         LR    R14,R10                                             0536 01720000
*   RFY                                                            0537 01721000
*    (R11,                                                         0537 01722000
*     R10) UNRSTD;                                                 0537 01723000
*   END GETLOCK;                                                   0538 01724000
@EL00002 DS    0H                                                  0538 01725000
@EF00002 DS    0H                                                  0538 01726000
@ER00002 BR    R14                                              DSK1133 01727000
*                                                                  0539 01728000
*   /*****************************************************************/ 01729000
*   /*                                                               */ 01730000
*   /* FREELOCK WILL FREE THE ASM CLASS LOCK. REGISTERS R2-R4 ARE    */ 01731000
*   /* STANDARD AS UNDER MAPPING MACRO POINTERS. R14 CONTAINS THE    */ 01732000
*   /* RETURN ADDR.                                                  */ 01733000
*   /*                                                               */ 01734000
*   /*****************************************************************/ 01735000
*                                                                  0539 01736000
*FREELOCK:                                                         0539 01737000
*   PROCEDURE OPTIONS(NOSAVE,NOSAVEAREA);                          0539 01738000
FREELOCK DS    0H                                                  0540 01739000
*   RFY                                                            0540 01740000
*    (R11,                                                         0540 01741000
*     R10,                                                         0540 01742000
*     R14) RSTD;                                                   0540 01743000
*   R10=R14;                        /* MAINTAIN RETURN ADDR          */ 01744000
         LR    R10,R14                                             0541 01745000
*   R11=ADDR(ASHLOCK);              /* OBTAIN ADDR ASM LOCKWORD      */ 01746000
         LA    R11,ASHLOCK-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 01747000
*   GEN REFS(R11);                                                 0543 01748000
FREASM1  SETLOCK RELEASE,TYPE=ASM,ADDR=(11),                          **01749000
               RELATED=(VIO,ILRGOS(GETASM1))                            01750000
*   R14=R10;                        /* RESTORE RETURN ADDR           */ 01751000
         LR    R14,R10                                             0544 01752000
*   RFY                                                            0545 01753000
*    (R11,                                                         0545 01754000
*     R10) UNRSTD;                                                 0545 01755000
*   END FREELOCK;                                                  0546 01756000
@EL00003 DS    0H                                                  0546 01757000
@EF00003 DS    0H                                                  0546 01758000
@ER00003 BR    R14                                              DSK1133 01759000
*ASSIGNLG:                                                         0547 01760000
*   PROCEDURE OPTIONS(NOSAVE,NOSAVEAREA);                          0547 01761000
*                                                                  0547 01762000
ASSIGNLG DS    0H                                                  0548 01763000
*/********************************************************************/ 01764000
*/*                                                                  */ 01765000
*/* THE ASSIGNLG ROUTINE WILL OBTAIN STORAGE FOR AND BUILD AN LGE    */ 01766000
*/* AND ASSIGN AN LGID. IT WILL ALSO OBTAIN STORAGE FOR AND BUILD A  */ 01767000
*/* LGVT IF NEEDED AND AN ASPCT IF REQUESTED. ALSO IF AN SRB DOES    */ 01768000
*/* NOT EXIST FOR THIS ADDRESS SPACE, IT WILL BUILD ONE.             */ 01769000
*/*                                                                  */ 01770000
*/* INPUT: R2 THRU R4 STANDARD, REQASPCT TO INDICATE WHETHER AN ASPCT*/ 01771000
*/*        SHOULD BE BUILT OR NOT.                                   */ 01772000
*/*                                                                  */ 01773000
*/* OUTPUT: THE PROPER CONTROL BLOCKS ARE BUILT AND INITIALIZED AS   */ 01774000
*/*         DESCRIBED ABOVE. THE LGID ASSIGNED IS PLACED IN THE      */ 01775000
*/*         LGELGID AND THE LGE IS RETURNED TO THE MAINLINE OF GOS.  */ 01776000
*/*                                                                  */ 01777000
*/********************************************************************/ 01778000
*/********************************************************************/ 01779000
*/*ASSIGNLG: CHART (AREF)                                            */ 01780000
*/*        HEADER                                                  0548 01781000
*/*        ILRGOS                                                  0548 01782000
*/* ASSIGNLG - ASSIGN LGN, BUILD LGE ROUTINE                         */ 01783000
*/*ASSIGNLG: E ENTRY                                                 */ 01784000
*/*        P SAVE RETURN ADDRESS                                     */ 01785000
*/*        P MAINTAIN ASMVT PTR AND ASM HDR PTR                      */ 01786000
*/*        L SETLOCK:   UNCONDITIONAL OBTAIN SALLOC LOCK             */ 01787000
*/*        P INITIALIZE GETMAIN SIZE TO THE LGE LENGTH               */ 01788000
*/*        D (N,,Y,%GOS62) ANY AVAILIABLE LGVT ENTRIES               */ 01789000
*/*        P INCR GET MAIN SIZE BY LGVSIZE + EXPANSION INCR          */ 01790000
*/*%GOS62: D (N,,Y,%GOS63) SRB EXISTS (ASHSRBP)                      */ 01791000
*/*        P INCREMENT GETMAIN SIZE BY SRB LENGTH                    */ 01792000
*/*%GOS63: P INITIALIZE REGS FOR GETMAIN                             */ 01793000
*/*        L GETMAIN: OBTAIN SQA SPACE FOR LGE, SRB AND LGVT         */ 01794000
*/*        D (N,,Y,%GOS65) RETURN CODE = 0                           */ 01795000
*/*        P (,%GOS73) SAVE RETURN CODE                              */ 01796000
*/*%GOS65: P CHECKPOINT CONTROL BLOCKS IN EPATH                      */ 01797000
*/*        P SAVE ADDR SPACE OBTAINED IN SQALEFT                     */ 01798000
*/*        P ZERO SQA SPACE                                          */ 01799000
*/*        D (Y,,N,%GOS67) ASPCT REQUIRED (REQASPCT)                 */ 01800000
*/*        P INITIALIZE REGS FOR GETMAIN                             */ 01801000
*/*        L GETMAIN: OBTAIN LSQA SPACE FOR ASPCT                    */ 01802000
*/*        D (N,,Y,%GOS66) RETURN CODE = 0                           */ 01803000
*/*        P SAVE RETURN CODE                                        */ 01804000
*/*        P INITIALIZE REGS FOR FREEMAIN                            */ 01805000
*/*        L (,%GOS73) FREEMAIN: FREE SQA SPACE OBTAINED EARLIER     */ 01806000
*/*%GOS66: P ZERO LSQA SPACE                                         */ 01807000
*/*        P ASPCT PTR = ADDR LSQA SPACE                             */ 01808000
*/*%GOS67: D (Y,,N,%GOS70) LGVT TO BE EXPANDED (LGVLGVEP)            */ 01809000
*/*        P MOVE LGVT INTO SQA SPACE OBTAINED                       */ 01810000
*/*        P FIRST AVAILABLE LGVTE (LGVLGVEP) = LGVT ADDR + LGVSIZE  */ 01811000
*/*        P LGVTE ADDR = FIRST AVAILABLE LGVTE                      */ 01812000
*/*        P LGVTE LGID (LGVELGID) = MAX LGN (LGVMAXLG) + 1          */ 01813000
*/*%GOS68: D (Y,,N,%GOS69) LGID < NUMBER LGVTES IN EXPANDED LGVT     */ 01814000
*/*        P LGVENEXT = LGVTE ADDR + LGVTE LENGTH                    */ 01815000
*/*        P INCR LGVELGID IN LGVENEXT                               */ 01816000
*/*        P (,%GOS68) LGVTE ADDR = LGVENEXT                         */ 01817000
*/*%GOS69: P LGVENEXT = 0, INDICATES LAST LGVTE                      */ 01818000
*/*        P INCR MAX LGN (LGVMAXLG) BY NUMBER LGVTES IN AN EXPANSION*/ 01819000
*/*        P INCR LGVT SIZE (LGVSIZE) BY EXPANSION SIZE              */ 01820000
*/*        P LGVT ADDR (ASMLGVTP) = ADDR SQA GETMAINED               */ 01821000
*/*        P INITIALIZE REGS. FOR FREEMAIN                           */ 01822000
*/*        P ZERO LGVT PTR, E PATH, IN ATA                           */ 01823000
*/*        L FREEMAIN: FREE OLD LGVT                                 */ 01824000
*/*        P INCR SQALEFT BY LGVT SIZE (LGVSIZE)                     */ 01825000
*/*%GOS70: P SET LGVTE ADDR = FIRST AVAILABLE LGVTE (LGVLGVEP)       */ 01826000
*/*        P FIRST AVAILABLE LGVTE = NEXT LGVTE (LGVNEXT)            */ 01827000
*/*        D (N,,Y,%GOS71) SRB EXISTS (ASHSRBP)                      */ 01828000
*/*        P SRBPTR = SQALEFT + LENGTH OF THE LGE                    */ 01829000
*/*        P INITIALIZE SRB FIELDS: ASCB, ASID, EP, ID, RTMR         */ 01830000
*/*        P ADDR SRB (ASHVSRBP) = SRBPTR                            */ 01831000
*/*%GOS71: D (Y,,N,%GOS72) ASPCT REQUIRED (REQASPCT)                 */ 01832000
*/*        P INITIALIZE ASPCT FIELDS: IDENT, LGID, LGE, ASCB         */ 01833000
*/*        P LGEASPCT = ASPCT PTR                                    */ 01834000
*/*%GOS72: L SETLOCK: UNCONDITIONAL OBTAIN ASM LOCK                  */ 01835000
*/*        P LGEPTR = SQALEFT                                        */ 01836000
*/*        P LGELGID = LGVELGID                                      */ 01837000
*/*        P LGVTE LGE PTR (LGVELGEP) = LGE PTR                      */ 01838000
*/*        P LGVEASCB = CURRENT ASCB                                 */ 01839000
*/*        N Q THE LGE TO THE ASMHD LGE Q                            */ 01840000
*/*        P LGENEXT = ASHLGEQ                                       */ 01841000
*/*        P ASHLGEQ = ADDR LGE OBTAINED                             */ 01842000
*/*        L SETLOCK: RELEASE THE ASM CLASS LOCK                     */ 01843000
*/*%GOS73: L SETLOCK: RELEASE THE SALLOC LOCK                        */ 01844000
*/*        R RETURN                                                  */ 01845000
*/*ASSIGNLG: END                                                     */ 01846000
*/********************************************************************/ 01847000
*                                                                  0548 01848000
*                                                                  0548 01849000
*   /*****************************************************************/ 01850000
*   /*                                                               */ 01851000
*   /* THE SALLOC LOCK IS OBTAINED, SQA CONTROL BLOCKS NEEDED ARE    */ 01852000
*   /* DETERMINED, THE GETMAIN SIZE IS SET ACCORDINGLY, AND THE      */ 01853000
*   /* STORAGE OBTAINED                                              */ 01854000
*   /*                                                               */ 01855000
*   /*****************************************************************/ 01856000
*                                                                  0548 01857000
*   RFY                                                            0548 01858000
*     R14 RSTD;                                                    0548 01859000
*   RTNADDR=R14;                    /* MAINTAIN THE RETURN ADDR      */ 01860000
         ST    R14,RTNADDR                                         0549 01861000
*   RFY                                                            0550 01862000
*     R14 UNRSTD;                                                  0550 01863000
*   GEN;                                                           0551 01864000
*    /* OBTAIN THE SALLOC LOCK */                                       01865000
GETSAL1   SETLOCK  OBTAIN,TYPE=SALLOC,MODE=UNCOND,                    **01866000
               RELATED=(VIO,ILRGOS(FRESAL1))                            01867000
*   RFY                                                            0552 01868000
*     GETSIZE RSTD;                                                0552 01869000
*   GETSIZE=LENGTH(LGE);            /* INITIALIZED TO LGE LENGTH     */ 01870000
         LA    R12,24                                           DSK1133 01871000
*   RFY                                                            0554 01872000
*     LGVTPTR RSTD;                                                0554 01873000
*   LGVTPTR=ASMLGVT;                /* OBTAIN ADDR OF THE LGVT       */ 01874000
         L     R11,ASMLGVT-ASMVT(,R3)                           DSK1133 01875000
*   IF LGVLGVEP=ZERO THEN                                          0556 01876000
         L     R10,LGVLGVEP(,R11)                               DSK1133 01877000
         LTR   R10,R10                                          DSK1133 01878000
         BNZ   @RF00556                                            0556 01879000
*     GETSIZE=GETSIZE+LGVSIZE+EXPSIZE;/* IF NO AVAILABLE LGVTES INCR    01880000
*                                      SIZE BY CURRENT LGVT SIZE AND    01881000
*                                      EXPANSION INCREMENT           */ 01882000
         LR    R10,R12                                          DSK1133 01883000
         AL    R10,LGVSIZE(,R11)                                DSK1133 01884000
         AL    R10,@CF01282                                     DSK1133 01885000
         LR    R12,R10                                          DSK1133 01886000
*   IF ASHVSRBP=ZERO THEN                                          0558 01887000
@RF00556 L     R10,ASHVSRBP-ASMHD+RSMASMHD-RSMHD(,R2)           DSK1133 01888000
         LTR   R10,R10                                          DSK1133 01889000
         BNZ   @RF00558                                            0558 01890000
*     GETSIZE=GETSIZE+LENGTH(SRB);  /* INCR SIZE BY THE SRB SIZE, NO    01891000
*                                      SRB FOR THIS ADDRESS SPACE    */ 01892000
         AL    R12,@CF01405                                     DSK1133 01893000
*   R4SAVE=R4;                      /* STORE R4, DESTROYED IN GETMAIN*/ 01894000
@RF00558 ST    R4,R4SAVE                                           0560 01895000
*   RFY                                                            0561 01896000
*    (R15,                                                         0561 01897000
*     R1AREA) RSTD;                                                0561 01898000
*   GEN REFS(GETSIZE,R3,R4) SETS(R1AREA,R15);                      0562 01899000
*                                         /* OBTAIN SPACE FOR           01900000
*      LGE AND/OR SRB, LGVT */                                          01901000
         GETMAIN RC,LV=(R12),SP=245,BRANCH=(YES,GLOBAL)         DSK1133 01902000
*   ASMVTPTR=CVTASMVT;              /* RESTORE R3, DESTROYED IN    0563 01903000
*                                      GETMAIN                       */ 01904000
         L     R14,CVTPTR                                       DSK1133 01905000
         L     R3,CVTASMVT-CVT(,R14)                            DSK1133 01906000
*   R4=R4SAVE;                      /* RESTORE R4, DESTROYED IN    0564 01907000
*                                      GETMAIN                       */ 01908000
         L     R4,R4SAVE                                           0564 01909000
*   IF R15^=ZERO THEN                                              0565 01910000
         LTR   R15,R15                                             0565 01911000
         BZ    @RF00565                                            0565 01912000
*     DO;                           /* GETMAIN UNSUCCESSFUL, RETURN     01913000
*                                      TO CALLER                     */ 01914000
*       RTNCODE=CODE28;             /* INDICATE NOT ENOUGH STORAGE   */ 01915000
         MVC   RTNCODE(4),@CF00438                                 0567 01916000
*       RFY                                                        0568 01917000
*         R15 UNRSTD;                                              0568 01918000
*     END;                          /* UNSUCCESSFUL SQA GETMAIN      */ 01919000
*                                                                  0570 01920000
*   /*****************************************************************/ 01921000
*   /*                                                               */ 01922000
*   /* GETMAIN SUCCESSFUL, CLEAR THE STORAGE OBTAINED, DETERMINE IF  */ 01923000
*   /* AN ASPCT NEEDED AND OBTAIN AND CLEAR ITS STORAGE IF NECESSARY.*/ 01924000
*   /* ALSO CHEKPOINT CONTROL BLOCKS AND THEIR LENGTHS IN THE EPATH  */ 01925000
*   /* IF NEEDED.                                                    */ 01926000
*   /*                                                               */ 01927000
*   /*****************************************************************/ 01928000
*                                                                  0570 01929000
*   ELSE                                                           0570 01930000
*     DO;                           /* SQA GETMAIN SUCCESSFUL        */ 01931000
         B     @RC00565                                            0570 01932000
@RF00565 DS    0H                                                  0571 01933000
*       IF LGVLGVEP=ZERO THEN                                      0571 01934000
         L     R10,LGVLGVEP(,R11)                               DSK1133 01935000
         LTR   R10,R10                                          DSK1133 01936000
         BNZ   @RF00571                                            0571 01937000
*         DO;                       /* CHECKPOINT NEW LGVT, ITS SIZE    01938000
*                                      AND THE LGE IN EPATH          */ 01939000
*           EPALGVTP=R1AREA;        /* RRR-CHECKPOINT LGVT-RRR       */ 01940000
         ST    R1,EPALGVTP                                      DSK1133 01941000
*           EPALSIZE=LGVSIZE+EXPSIZE;/* RRR-CHECKPOINT LGVT SIZE-RRR */ 01942000
         LA    R10,512                                          DSK1133 01943000
         AL    R10,LGVSIZE(,R11)                                DSK1133 01944000
         STH   R10,EPALSIZE                                     DSK1133 01945000
*           EPALGEP=R1AREA+EPALSIZE;/* RRR-CHECKPOINT LGE-RRR        */ 01946000
         ALR   R10,R1                                           DSK1133 01947000
         ST    R10,EPALGEP                                      DSK1133 01948000
*         END;                                                     0576 01949000
*       ELSE                                                       0577 01950000
*         EPALGEP=R1AREA;           /* RRR-CHECKPOINT LGE, NO LGVT 0577 01951000
*                                      NEEDED-RRR                    */ 01952000
         B     @RC00571                                            0577 01953000
@RF00571 ST    R1,EPALGEP                                       DSK1133 01954000
*       IF ASHVSRBP=ZERO THEN                                      0578 01955000
@RC00571 L     R10,ASHVSRBP-ASMHD+RSMASMHD-RSMHD(,R2)           DSK1133 01956000
         LTR   R10,R10                                          DSK1133 01957000
         BNZ   @RF00578                                            0578 01958000
*         EPASRB=EPALGEP+LENGTH(LGE);/* RRR-CHECK POINT THE SRB ADDR    01959000
*                                      IN THE EPATH-RRR              */ 01960000
         LA    R10,24                                           DSK1133 01961000
         AL    R10,EPALGEP                                      DSK1133 01962000
         ST    R10,EPASRB                                       DSK1133 01963000
*       SQALEFT=R1AREA;             /* SAVE ADDR OF SQA SPACE      0580 01964000
*                                      OBTAINED                      */ 01965000
*                                                                  0580 01966000
@RF00578 ST    R1,SQALEFT                                       DSK1133 01967000
*       /*************************************************************/ 01968000
*       /*                                                           */ 01969000
*       /* CLEAR THE SQA SPACE OBTAINED                              */ 01970000
*       /*                                                           */ 01971000
*       /*************************************************************/ 01972000
*                                                                  0581 01973000
*       RFY                                                        0581 01974000
*        (R0,                                                      0581 01975000
*         R14,                                                     0581 01976000
*         R15) RSTD;                                               0581 01977000
*       R0=R1AREA;                  /* ADDR AREA TO BE CLEARED       */ 01978000
         LR    R0,R1                                            DSK1133 01979000
*       R1=GETSIZE;                 /* LENGTH AREA TO BE CLEARED     */ 01980000
         LR    R1,R12                                           DSK1133 01981000
*       R15=ZERO;                   /* ZERO PADDING CHARACTER AND  0584 01982000
*                                      FROM LENGTH                   */ 01983000
         SLR   R15,R15                                             0584 01984000
*       MVCL(R0,R14);               /* CLEAR THE SQA SPACE OBTAINED  */ 01985000
         MVCL  R0,R14                                              0585 01986000
*       RFY                                                        0586 01987000
*        (R14,                                                     0586 01988000
*         R0) UNRSTD;                                              0586 01989000
*                                                                  0587 01990000
*       /*************************************************************/ 01991000
*       /*                                                           */ 01992000
*       /* AN ASPCT WAS REQUESTED OBTAIN AND CLEAR LSQA STORAGE FOR  */ 01993000
*       /* IT                                                        */ 01994000
*       /*                                                           */ 01995000
*       /*************************************************************/ 01996000
*                                                                  0587 01997000
*       IF REQASPCT=ON THEN                                        0587 01998000
         TM    REQASPCT,B'10000000'                                0587 01999000
         BNO   @RF00587                                            0587 02000000
*         DO;                       /* STORAGE FOR AN ASPCT IS NEEDED*/ 02001000
*           RFY                                                    0589 02002000
*             R10 RSTD;                                            0589 02003000
*           R10=LENGTH(ASPCT);      /* OBTAIN THE LENGTH FOR GETMAIN */ 02004000
         LA    R10,1088                                            0590 02005000
*           R4SAVE=R4;              /* STORE R4, USED IN GETMAIN     */ 02006000
         ST    R4,R4SAVE                                           0591 02007000
*           R7SAVE=R7;              /* STORE R7, USED IN GETMAIN     */ 02008000
         ST    R7,R7SAVE                                           0592 02009000
*           R4=PSATOLD;             /* LOAD TCB ADDR                 */ 02010000
         L     R4,PSATOLD-PSA                                   DSK1133 02011000
*           R7=PSAAOLD;             /* LOAD ASCB ADDR                */ 02012000
         L     R7,PSAAOLD-PSA                                   DSK1133 02013000
*           GEN REFS(R10,R4,R7) SETS(R1AREA,R15,R3);               0595 02014000
*                                         /* OBTAIN SPACE FOR ASPCT */  02015000
    GETMAIN RC,LV=(R10),SP=255,BRANCH=YES     GET LSQA SPACE            02016000
*           ASMVTPTR=CVTASMVT;      /* RESTORE R3, DESTROYED IN    0596 02017000
*                                      GETMAIN                       */ 02018000
         L     R14,CVTPTR                                       DSK1133 02019000
         L     R3,CVTASMVT-CVT(,R14)                            DSK1133 02020000
*           R4=R4SAVE;              /* RESTORE R4, DESTROYED IN    0597 02021000
*                                      GETMAIN                       */ 02022000
         L     R4,R4SAVE                                           0597 02023000
*           R7=R7SAVE;              /* RESTORE R7, DESTROYED IN    0598 02024000
*                                      GETMAIN                       */ 02025000
         L     R7,R7SAVE                                           0598 02026000
*           IF R15^=ZERO THEN                                      0599 02027000
         SLR   R14,R14                                          DSK1133 02028000
         CR    R15,R14                                          DSK1133 02029000
         BE    @RF00599                                            0599 02030000
*             DO;                   /* GETMAIN UNSUCCESSFUL, FREE SQA   02031000
*                                      AND RETURN                    */ 02032000
*               RTNCODE=CODE28;     /* INDICATE NOT ENOUGH STORAGE   */ 02033000
         MVC   RTNCODE(4),@CF00438                                 0601 02034000
*               R1AREA=SQALEFT;     /* ADDRESS AREA TO BE FREED      */ 02035000
         L     R1,SQALEFT                                       DSK1133 02036000
*               R4SAVE=R4;          /* STORE R4, DESTROYED IN      0603 02037000
*                                      FREEMAIN                      */ 02038000
         ST    R4,R4SAVE                                           0603 02039000
*               EPASRB=ZERO;        /* RRR-STOP TRACKING SRB ADDR IN    02040000
*                                      EPATH-RRR                     */ 02041000
         ST    R14,EPASRB                                       DSK1133 02042000
*               EPALGVTP=ZERO;      /* RRR-CLEAR LGVT ADDR IN      0605 02043000
*                                      EPATH-RRR                     */ 02044000
         ST    R14,EPALGVTP                                     DSK1133 02045000
*               EPALSIZE=ZERO;      /* RRR-CLEAR LGVT SIZE IN      0606 02046000
*                                      EPATH-RRR                     */ 02047000
         STH   R14,EPALSIZE                                     DSK1133 02048000
*               EPALGEP=ZERO;       /* RRR-CLEAR LGE ADDR IN       0607 02049000
*                                      EPATH-RRR                     */ 02050000
         ST    R14,EPALGEP                                      DSK1133 02051000
*               GEN REFS(GETSIZE,R1AREA);                          0608 02052000
*                         /* FREE SQA OBTAINED EARLIER */               02053000
         FREEMAIN RC,LV=(R12),SP=245,A=(R1),BRANCH=(YES,GLOBAL) DSK1133 02054000
*               RFY                                                0609 02055000
*                 GETSIZE UNRSTD;                                  0609 02056000
*               ASMVTPTR=CVTASMVT;  /* RESTORE R3, DESTROYED IN    0610 02057000
*                                      FREEMAIN                      */ 02058000
         L     R14,CVTPTR                                       DSK1133 02059000
         L     R3,CVTASMVT-CVT(,R14)                            DSK1133 02060000
*               R4=R4SAVE;          /* RESTORE R4, DESTROYED IN    0611 02061000
*                                      FREEMAIN                      */ 02062000
         L     R4,R4SAVE                                           0611 02063000
*             END;                  /* LSQA GETMAIN UNSUCCESSFUL     */ 02064000
*           ELSE                                                   0613 02065000
*             DO;                   /* LSQA GETMAIN SUCCESSFUL       */ 02066000
         B     @RC00599                                            0613 02067000
@RF00599 DS    0H                                                  0614 02068000
*               EPARBASP=R1AREA;    /* RRR-TRACK ASPCT IN EPATH-RRR  */ 02069000
         ST    R1,EPARBASP                                      DSK1133 02070000
*               EPARSIZE=LENGTH(ASPCT);/* RRR-TRACK ASPCT SIZE IN  0615 02071000
*                                      EPATH-RRR                     */ 02072000
         MVC   EPARSIZE(2),@CH01810                                0615 02073000
*               SAVASPCT=R1AREA;    /* SAVE ADDR ASPCT TO BE BUILT   */ 02074000
         ST    R1,SAVASPCT                                      DSK1133 02075000
*               RFY                                                0617 02076000
*                (R0,                                              0617 02077000
*                 R14) RSTD;                                       0617 02078000
*               R0=R1AREA;          /* ADDR AREA TO BE CLEARED       */ 02079000
         LR    R0,R1                                            DSK1133 02080000
*               R1=R10;             /* LENGTH AREA TO BE CLEARED     */ 02081000
         LR    R1,R10                                              0619 02082000
*               R15=ZERO;           /* ZERO PADDING CHARACTER AND  0620 02083000
*                                      FROM LENGTH                   */ 02084000
         SLR   R15,R15                                             0620 02085000
*               MVCL(R0,R14);       /* CLEAR THE LSQA OBTAINED       */ 02086000
         MVCL  R0,R14                                              0621 02087000
*               RFY                                                0622 02088000
*                (R0,                                              0622 02089000
*                 R1,                                              0622 02090000
*                 R14,                                             0622 02091000
*                 R15) UNRSTD;                                     0622 02092000
*             END;                  /* LSQA GETMAIN SUCCESSFUL       */ 02093000
*         END;                      /* ASPCT NEEDED                  */ 02094000
@RC00599 DS    0H                                                  0625 02095000
*     END;                          /* SQA GETMAIN SUCCESSFUL        */ 02096000
@RF00587 DS    0H                                                  0626 02097000
*                                                                  0626 02098000
*   /*****************************************************************/ 02099000
*   /*                                                               */ 02100000
*   /* IF GETMAIN(S) ARE SUCCESSFUL PROCESSING COMES HERE WHERE THE  */ 02101000
*   /* LGVT IS EXPANDED IF NECESSARY AND A LGVTE OBTAINED            */ 02102000
*   /*                                                               */ 02103000
*   /*****************************************************************/ 02104000
*                                                                  0626 02105000
*   IF RTNCODE=ZERO THEN                                           0626 02106000
@RC00565 SLR   R12,R12                                          DSK1133 02107000
         C     R12,RTNCODE                                      DSK1133 02108000
         BNE   @RF00626                                            0626 02109000
*     DO;                           /* NO GETMAIN ERRORS             */ 02110000
*       IF LGVLGVEP=ZERO THEN                                      0628 02111000
         C     R12,LGVLGVEP(,R11)                               DSK1133 02112000
         BNE   @RF00628                                            0628 02113000
*         DO;                       /* EXPAND THE LGVT               */ 02114000
*           RFY                                                    0630 02115000
*            (R0,                                                  0630 02116000
*             R1,                                                  0630 02117000
*             R14,                                                 0630 02118000
*             R15) RSTD;                                           0630 02119000
*           R0=SQALEFT;             /* MOVE TO ADDR                  */ 02120000
         L     R0,SQALEFT                                          0631 02121000
*           R1=LGVSIZE;             /* MOVE TO LENGTH                */ 02122000
         L     R12,LGVSIZE(,R11)                                DSK1133 02123000
         LR    R1,R12                                           DSK1133 02124000
*           R14=LGVTPTR;            /* MOVE FROM ADDR                */ 02125000
         LR    R14,R11                                          DSK1133 02126000
*           R15=LGVSIZE;            /* MOVE FROM LENGTH              */ 02127000
         LR    R15,R12                                          DSK1133 02128000
*           MVCL(R0,R14);           /* MOVE THE LGVT TO NEW AREA   0635 02129000
*                                      GETMAINED                     */ 02130000
         MVCL  R0,R14                                              0635 02131000
*           RFY                                                    0636 02132000
*            (R0,                                                  0636 02133000
*             R1,                                                  0636 02134000
*             R14,                                                 0636 02135000
*             R15) UNRSTD;                                         0636 02136000
*           LGVTPTR=SQALEFT;        /* ADDR NEW LGVT                 */ 02137000
         L     R11,SQALEFT                                      DSK1133 02138000
*           LGVLGVEP=LGVTPTR+LGVSIZE;/* SET FIRST AVAILABLE LGVTE  0638 02139000
*                                      ADDR IN LGVT AVAILABLE QUEUE  */ 02140000
         LR    R12,R11                                          DSK1133 02141000
         AL    R12,LGVSIZE(,R11)                                DSK1133 02142000
         ST    R12,LGVLGVEP(,R11)                               DSK1133 02143000
*           RFY                                                    0639 02144000
*             LGVTEPTR RSTD;                                       0639 02145000
*           LGVTEPTR=LGVLGVEP;      /* OBTAIN ADDRESSIBILITY TO FIRST   02146000
*                                      LGVTE                         */ 02147000
         LR    R10,R12                                          DSK1133 02148000
*           RFY                                                    0641 02149000
*             ENTRYCNT RSTD;                                       0641 02150000
*           ENTRYCNT=ONE;           /* COUNT OF LGVT ENTRIES QUEUED  */ 02151000
*                                                                  0642 02152000
         LA    R12,1                                            DSK1133 02153000
*           /*********************************************************/ 02154000
*           /*                                                       */ 02155000
*           /* SET THE LGID IN EACH LGVTE AND CHAIN THE ENTRIES      */ 02156000
*           /* TOGETHER FOR THE AVAILABLE QUEUE                      */ 02157000
*           /*                                                       */ 02158000
*           /*********************************************************/ 02159000
*                                                                  0643 02160000
*           DO WHILE ENTRYCNT<EXPENTRS;/* FOR EVERY LGVTE EXCEPT THE    02161000
*                                      LAST                          */ 02162000
         B     @DE00643                                            0643 02163000
@DL00643 DS    0H                                                  0644 02164000
*             LGVENEXT=LGVTEPTR+LENGTH(LGVTE);/* Q NEXT LGVTE TO   0644 02165000
*                                      AVAILABLE QUEUE               */ 02166000
         LA    R0,8                                             DSK1133 02167000
         ALR   R0,R10                                           DSK1133 02168000
         ST    R0,LGVENEXT(,R10)                                DSK1133 02169000
*             LGVELGID=LGVMAXLG+ENTRYCNT;/* INCR LGID IN NEXT LGVTE  */ 02170000
         LR    R15,R12                                          DSK1133 02171000
         AL    R15,LGVMAXLG(,R11)                               DSK1133 02172000
         ST    R15,LGVELGID(,R10)                               DSK1133 02173000
*             LGVTEPTR=LGVENEXT;    /* UPDATE THE LGVTE ADDR         */ 02174000
         LR    R10,R0                                           DSK1133 02175000
*             ENTRYCNT=ENTRYCNT+ONE;/* INCR COUNT OF LGVTES QUEUED   */ 02176000
         AL    R12,@CF00040                                     DSK1133 02177000
*           END;                    /* END DO FOR LGVTES             */ 02178000
@DE00643 LA    R15,64                                           DSK1133 02179000
         CR    R12,R15                                          DSK1133 02180000
         BL    @DL00643                                            0648 02181000
*           LGVELGID=LGVMAXLG+ENTRYCNT;/* SET LGID FOR LAST LGVTE, 0649 02182000
*                                      THE NEXT FIELD IS LEFT TO ZERO   02183000
*                                      INDICATING THE LAST LGVTE     */ 02184000
         L     R14,LGVMAXLG(,R11)                               DSK1133 02185000
         LR    R0,R12                                           DSK1133 02186000
         ALR   R0,R14                                           DSK1133 02187000
         ST    R0,LGVELGID(,R10)                                DSK1133 02188000
*           RFY                                                    0650 02189000
*             ENTRYCNT UNRSTD;                                     0650 02190000
*           LGVMAXLG=LGVMAXLG+EXPENTRS;/* INCR MAX LGID              */ 02191000
         ALR   R14,R15                                          DSK1133 02192000
         ST    R14,LGVMAXLG(,R11)                               DSK1133 02193000
*           R10=LGVSIZE;            /* SAVE SIZE OLD LGVT FOR      0652 02194000
*                                      FREEMAIN                      */ 02195000
         L     R12,LGVSIZE(,R11)                                DSK1133 02196000
         LR    R10,R12                                          DSK1133 02197000
*           LGVSIZE=LGVSIZE+EXPSIZE;/* INCR LGVT SIZE                */ 02198000
         AL    R12,@CF01282                                     DSK1133 02199000
         ST    R12,LGVSIZE(,R11)                                DSK1133 02200000
*           RFY                                                    0654 02201000
*             R1AREA RSTD;                                         0654 02202000
*           R1AREA=ASMLGVT;         /* SAVE ADDR OLD LGVT FOR      0655 02203000
*                                      FREEMAIN                      */ 02204000
         L     R1,ASMLGVT-ASMVT(,R3)                            DSK1133 02205000
*           EPALGVTP=ZERO;          /* RRR-STOP TRACKING LGVT-RRR    */ 02206000
         SLR   R12,R12                                          DSK1133 02207000
         ST    R12,EPALGVTP                                     DSK1133 02208000
*           EPALSIZE=ZERO;          /* RRR-STOP TRACKING LGVT      0657 02209000
*                                      SIZE-RRR                      */ 02210000
         STH   R12,EPALSIZE                                     DSK1133 02211000
*           ASMLGVT=LGVTPTR;        /* STORE ADDR NEW LGVT IN ASMVT  */ 02212000
         ST    R11,ASMLGVT-ASMVT(,R3)                           DSK1133 02213000
*           R4SAVE=R4;              /* SAVE R4, DESTROYED IN FREEMAIN*/ 02214000
         ST    R4,R4SAVE                                           0659 02215000
*           GEN REFS(R1AREA,R10,R3,R4);                            0660 02216000
*                           /* FREE OLD LGVT */                         02217000
         FREEMAIN RC,LV=(R10),SP=245,A=(R1),BRANCH=(YES,GLOBAL) DSK1133 02218000
*           ASMVTPTR=CVTASMVT;      /* RESTORE R3, DESTROYED IN    0661 02219000
*                                      GETMAIN                       */ 02220000
         L     R12,CVTPTR                                       DSK1133 02221000
         L     R3,CVTASMVT-CVT(,R12)                            DSK1133 02222000
*           R4=R4SAVE;              /* RESTORE R4, DESTROYED IN    0662 02223000
*                                      FREEMAIN                      */ 02224000
         L     R4,R4SAVE                                           0662 02225000
*           SQALEFT=SQALEFT+LGVSIZE;/* ADDR NEXT CONTROL BLOCK TO BE    02226000
*                                      BUILT                         */ 02227000
         L     R12,SQALEFT                                      DSK1133 02228000
         AL    R12,LGVSIZE(,R11)                                DSK1133 02229000
         ST    R12,SQALEFT                                      DSK1133 02230000
*         END;                      /* END EXPAND LGVT               */ 02231000
*                                                                  0664 02232000
*       /*************************************************************/ 02233000
*       /*                                                           */ 02234000
*       /* THE FIRST AVAILABLE LGVTE IS NOW OBTAINED                 */ 02235000
*       /*                                                           */ 02236000
*       /*************************************************************/ 02237000
*                                                                  0665 02238000
*       LGVTEPTR=LGVLGVEP;          /* OBTAIN ADDR FIRST AVAILABLE 0665 02239000
*                                      LGVTE                         */ 02240000
@RF00628 L     R10,LGVLGVEP(,R11)                               DSK1133 02241000
*       LGVLGVEP=LGVENEXT;          /* MAKE THE FIRST AVAILABLE LGVTE   02242000
*                                      THE NEXT LGVTE                */ 02243000
         L     R12,LGVENEXT(,R10)                               DSK1133 02244000
         ST    R12,LGVLGVEP(,R11)                               DSK1133 02245000
*                                                                  0667 02246000
*       /*************************************************************/ 02247000
*       /*                                                           */ 02248000
*       /* A SRB IS CREATED IF THERE IS NONE, THE LGE IS INITIALIZED */ 02249000
*       /* AND AN ASPCT IS CREATED IF REQUESTED                      */ 02250000
*       /*                                                           */ 02251000
*       /*************************************************************/ 02252000
*                                                                  0667 02253000
*       IF ASHVSRBP=ZERO THEN                                      0667 02254000
         SLR   R12,R12                                          DSK1133 02255000
         C     R12,ASHVSRBP-ASMHD+RSMASMHD-RSMHD(,R2)           DSK1133 02256000
         BNE   @RF00667                                            0667 02257000
*         DO;                       /* NO SRB FOR THIS ADDRESS SPACE */ 02258000
*           RFY                                                    0669 02259000
*             SRBPTR RSTD;                                         0669 02260000
*           SRBPTR=SQALEFT+LENGTH(LGE);/* OBTAIN ADDRESS OF THE SRB  */ 02261000
         LA    R11,24                                           DSK1133 02262000
         AL    R11,SQALEFT                                      DSK1133 02263000
*           SRBASCB=PSAAOLD;        /* STORE ASCB ADDR IN ASPCT      */ 02264000
         L     R15,PSAAOLD-PSA                                  DSK1133 02265000
         ST    R15,SRBASCB-SRB(,R11)                            DSK1133 02266000
*           SRBPASID=PSAAOLD->ASCBASID;/* ASID OF SRBRMTR            */ 02267000
         LH    R0,ASCBASID-ASCB(,R15)                           DSK1133 02268000
         N     R0,@CF01812                                      DSK1133 02269000
         STH   R0,SRBPASID-SRB(,R11)                            DSK1133 02270000
*           SRBEP=ASMPSRBC;         /* ADDR SRB CONTROLLER, GIVEN  0673 02271000
*                                      CONTROL WHEN SRB SCHEDULED    */ 02272000
         L     R0,ASMPSRBC-ASMVT(,R3)                           DSK1133 02273000
         ST    R0,SRBEP-SRB(,R11)                               DSK1133 02274000
*           SRBID=SRBK;             /* SET SRB ID IN SRB             */ 02275000
         MVC   SRBID-SRB(4,R11),@CC01689                        DSK1133 02276000
*           SRBRMTR=ASMVRMTR;       /* ADDR VIO RESOURCE MANAGER   0675 02277000
*                                      TERMINATION ROUTINE           */ 02278000
         L     R0,ASMVRMTR-ASMVT(,R3)                           DSK1133 02279000
         ST    R0,SRBRMTR-SRB(,R11)                             DSK1133 02280000
*           SRBPRIOR=NONQ;          /* MAKE SRB PRIORITY           0676 02281000
*                                      NON-QUIESCENT                 */ 02282000
         MVI   SRBPRIOR-SRB(R11),X'04'                          DSK1133 02283000
*           EPASRB=ZERO;            /* RRR-STOP TRACKING SRB ADDR IN    02284000
*                                      EPATH-RRR                     */ 02285000
         ST    R12,EPASRB                                       DSK1133 02286000
*           ASHVSRBP=SRBPTR;        /* PUT SRB ADDR IN THE ASM HEADER*/ 02287000
         ST    R11,ASHVSRBP-ASMHD+RSMASMHD-RSMHD(,R2)           DSK1133 02288000
*           RFY                                                    0679 02289000
*             SRBPTR UNRSTD;                                       0679 02290000
*         END;                      /* NO SRB                        */ 02291000
*       LGEPTR=SQALEFT;             /* OBTAIN ADDR OF THE LGE        */ 02292000
@RF00667 L     R5,SQALEFT                                       DSK1133 02293000
*       IF REQASPCT=ON THEN                                        0682 02294000
         TM    REQASPCT,B'10000000'                                0682 02295000
         BNO   @RF00682                                            0682 02296000
*         DO;                       /* ASPCT NEEDED                  */ 02297000
*           RFY                                                    0684 02298000
*             ASPCTPTR RSTD;                                       0684 02299000
*           ASPCTPTR=SAVASPCT;      /* OBTAIN ASPCT TO BE INITIALIZED*/ 02300000
         L     R12,SAVASPCT                                     DSK1133 02301000
*           ASPIDENT=ASPC;          /* PLACE ID IN ASPCT             */ 02302000
         MVC   ASPIDENT(4,R12),@CC01687                         DSK1133 02303000
*           ASPLGID=LGVELGID;       /* STORE LGID IN ASPCT           */ 02304000
         L     R0,LGVELGID(,R10)                                DSK1133 02305000
         ST    R0,ASPLGID(,R12)                                 DSK1133 02306000
*           ASPLGE=LGEPTR;          /* STORE LGE ADDR IN ASPCT       */ 02307000
         ST    R5,ASPLGE(,R12)                                  DSK1133 02308000
*           ASPASCB=PSAAOLD;        /* STORE ASCB ADDR IN ASPCT      */ 02309000
         L     R0,PSAAOLD-PSA                                   DSK1133 02310000
         ST    R0,ASPASCB(,R12)                                 DSK1133 02311000
*           EPARBASP=ZERO;          /* RRR-STOP TRACKING THE       0690 02312000
*                                      ASPCT-RRR                     */ 02313000
         SLR   R15,R15                                          DSK1133 02314000
         ST    R15,EPARBASP                                     DSK1133 02315000
*           EPARSIZE=ZERO;          /* RRR-STOP TRACKING ASPCT     0691 02316000
*                                      SIZE-RRR                      */ 02317000
         STH   R15,EPARSIZE                                     DSK1133 02318000
*           LGEASPCT=ASPCTPTR;      /* STORE ASPCT ADDR IN THE LGE   */ 02319000
         ST    R12,LGEASPCT(,R5)                                DSK1133 02320000
*         END;                      /* ASPCT NEEDED                  */ 02321000
*       SAVLGVTE=LGVTEPTR;          /* STORE ADDR OF THE LGVTE ACROSS   02322000
*                                      GETLOCK                       */ 02323000
@RF00682 ST    R10,SAVLGVTE                                     DSK1133 02324000
*       CALL GETLOCK;               /* GET THE ASM CLASS LOCK        */ 02325000
         BAL   R14,GETLOCK                                      DSK1133 02326000
*       LGVTEPTR=SAVLGVTE;          /* RESTORE THE ADDR OF THE LGVTE */ 02327000
         L     R10,SAVLGVTE                                     DSK1133 02328000
*       LGELGID=LGVELGID;           /* STORE THE LGID IN LGE         */ 02329000
         L     R0,LGVELGID(,R10)                                DSK1133 02330000
         ST    R0,LGELGID(,R5)                                  DSK1133 02331000
*       LGVELGEP=LGEPTR;            /* STORE LGE ADDR IN LGVTE       */ 02332000
         ST    R5,LGVELGEP(,R10)                                DSK1133 02333000
*       LGVEASCB=PSAAOLD;           /* STORE ASCB ADDR IN LGVTE,   0699 02334000
*                                      VALIDATES THE LGVTE           */ 02335000
         L     R0,PSAAOLD-PSA                                   DSK1133 02336000
         ST    R0,LGVEASCB(,R10)                                DSK1133 02337000
*       IF EPAACASR=OFF THEN                                       0700 02338000
         TM    EPAACASR,B'00001000'                                0700 02339000
         BNZ   @RF00700                                            0700 02340000
*         EPALGEP=ZERO;             /* RRR-CLEAR LGE ADDR IN EPATH ON   02341000
*                                      A RELEASE REQUEST-RRR         */ 02342000
         SLR   R0,R0                                            DSK1133 02343000
         ST    R0,EPALGEP                                       DSK1133 02344000
*                                                                  0702 02345000
*       /*************************************************************/ 02346000
*       /*                                                           */ 02347000
*       /* QUEUE THE LGE TO THE ASM HEADER LGE QUEUE, RELEASE THE ASM*/ 02348000
*       /* AND SALLOC LOCKS, AND RETURN TO THE CALLER                */ 02349000
*       /*                                                           */ 02350000
*       /*************************************************************/ 02351000
*                                                                  0702 02352000
*       LGENEXT=ASHLGEQ;            /* Q LGE Q TO LGE JUST OBTAINED  */ 02353000
@RF00700 L     R0,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)             DSK1133 02354000
         ST    R0,LGENEXT(,R5)                                  DSK1133 02355000
*       ASHLGEQ=LGEPTR;             /* MAKE LGE FIRST ELEMENT ON   0703 02356000
*                                      QUEUE                         */ 02357000
         ST    R5,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)             DSK1133 02358000
*       RFY                                                        0704 02359000
*        (LGVTPTR,                                                 0704 02360000
*         ASPCTPTR,                                                0704 02361000
*         LGVTEPTR) UNRSTD;                                        0704 02362000
*       CALL FREELOCK;              /* FREE THE ASM CLASS LOCK       */ 02363000
         BAL   R14,FREELOCK                                     DSK1133 02364000
*     END;                          /* NO GETMAIN ERRORS             */ 02365000
*   GEN;                                                           0707 02366000
@RF00626 DS    0H                                                  0707 02367000
*    /* RELEASE THE SALLOC LOCK */                                      02368000
FRESAL1   SETLOCK  RELEASE,TYPE=SALLOC,RELATED=(VIO,ILRGOS(GETSAL1))    02369000
*   RFY                                                            0708 02370000
*     R14 RSTD;                                                    0708 02371000
*   R14=RTNADDR;                    /* RESTORE RETURN ADDR           */ 02372000
         L     R14,RTNADDR                                         0709 02373000
*   END ASSIGNLG;                                                  0710 02374000
@EL00004 DS    0H                                                  0710 02375000
@EF00004 DS    0H                                                  0710 02376000
@ER00004 BR    R14                                              DSK1133 02377000
*ILRFRELG:                                                         0711 02378000
*   ENTRY;                                                         0711 02379000
*                                                                  0711 02380000
@EP00711 DS    0H                                                  0712 02381000
*/********************************************************************/ 02382000
*/*                                                                  */ 02383000
*/* FUNCTION: TO DEQUEUE THE LGE FROM THE ASM HEADER LGE QUEUE, FREE */ 02384000
*/*           THE LGE, AND MAKE THE LGVTE AVAILABLE AGAIN. TO UPDATE */ 02385000
*/*           THE ASCB VIO COUNT.                                    */ 02386000
*/*                                                                  */ 02387000
*/* INPUT: R1 - ADDR LGE TO BE FREED                                 */ 02388000
*/*        R3 - ASMVT ADDR                                           */ 02389000
*/*        R13 - ADDR CALLER'S SAVE AREA                             */ 02390000
*/*                                                                  */ 02391000
*/* OUTPUT: ASCBVSC UPDATED BY LGESLTCT                              */ 02392000
*/*         LGVTE AVAILABLE Q ANCHOR (LGVLGVEP) AND LGVENEXT RESET   */ 02393000
*/*                                                                  */ 02394000
*/********************************************************************/ 02395000
*/********************************************************************/ 02396000
*/*ILRFRELG: CHART (AREF)                                            */ 02397000
*/*        HEADER                                                  0712 02398000
*/*        ILRGOS                                                  0712 02399000
*/* ILRFRELG - ROUTINE TO DEQUEUE AND FREE A LGE                     */ 02400000
*/*ILRFRELG: E EXTERNAL ENTRY                                        */ 02401000
*/*        P SAVE CALLER'S REGS                                      */ 02402000
*/*        P ESTABLISH ADDRESSIBILITY                                */ 02403000
*/*        P MAINTAIN ASMHD PTR, ASMVT PTR, AND LGE PTR              */ 02404000
*/*        L SETLOCK: UNCONDITIONAL OBTAIN ASM CLASS LOCK            */ 02405000
*/*        P (,%GOS48) INCR ASCBVSC BY LGESLTCT                      */ 02406000
*/*FRELG:  E INTERNAL ENTRY                                          */ 02407000
*/*%GOS48: P SAVE RETURN ADDR                                        */ 02408000
*/*        N DEQUEUE THE LGE                                         */ 02409000
*/*        D (Y,,N,%GOS74) LGE TO BE FREED IS FIRST ON Q             */ 02410000
*/*        P (,%GOS49) LGE Q (ASHLGEQ) = NEXT LGE (LGENEXT)          */ 02411000
*/*%GOS74: P SEARCH LGE Q FOR LGE TO BE FREED (LGEPTR)               */ 02412000
*/*        P SAVE PREVIOUS LGE ADDR DURING SEARCH                    */ 02413000
*/*        D (Y,,N,%GOS76) LGE TO BE FREED WAS FOUND                 */ 02414000
*/*        P LGENEXT OF PREVIOUS LGE = LGENEXT OF LGEPTR             */ 02415000
*/*%GOS49: P CLEAR FIRST AND LAST AIA/ACE PTRS                       */ 02416000
*/*        L SETLOCK: UNCONDITIONAL RELEASE ASM CLASS LOCK           */ 02417000
*/*        L SETLOCK: UNCONDITIONAL OBTAIN SALLOC LOCK               */ 02418000
*/*        P CALCULATE THE LGVTE ADDR                                */ 02419000
*/*        P LGVELGID = LGELGID                                      */ 02420000
*/*        P LGVENEXT = FIRST AVAILABLE LGVTE (LGVLGVEP)             */ 02421000
*/*        P FIRST AVAILABLE LGVTE = LGVTE ADDR                      */ 02422000
*/*        P INITIALIZE REGS FOR FREEMAIN                            */ 02423000
*/*        L FREEMAIN: FREE SQA SPACE CONTAINING THE LGE             */ 02424000
*/*        L (,%GOS77) SETLOCK: RELEASE THE SALLOC LOCK              */ 02425000
*/*%GOS76: P SET RTN CODE = '04', INVALID LGN                        */ 02426000
*/*        L SETLOCK: UNCONDITIONAL RELEASE ASM CLASS LOCK           */ 02427000
*/*%GOS77: D (N,,Y,%GOS50) INTERNAL ENTRY                            */ 02428000
*/*        P RESTORE CALLER'S REGS                                   */ 02429000
*/*        R RETURN TO ILRRLG                                        */ 02430000
*/*%GOS50: P RESTORE RETURN ADDRESS                                  */ 02431000
*/*        R RETURN                                                  */ 02432000
*/*ILRFRELG: END                                                     */ 02433000
*/********************************************************************/ 02434000
*                                                                  0712 02435000
*                                                                  0712 02436000
*   /*****************************************************************/ 02437000
*   /*                                                               */ 02438000
*   /* ILRFRELG IS CALLED BY ILRRLG AND ILRGOS01. THE ASM CLASS LOCK */ 02439000
*   /* IS OBTAINED AND THE VIO SLOT COUNT UPDATED BY THE AMOUNT      */ 02440000
*   /* SPECIFIED BY THE CALLING ROUTINE. FRELG IS THEN CALLED TO     */ 02441000
*   /* PERFORM THE ACTUAL PROCESSING. SINCE ILRFRELG IS AN EXTERNAL  */ 02442000
*   /* ENTRY NEITHER IT OR THE SUBROUTINE FRELG CAN USE ILRGOS       */ 02443000
*   /* WORK-SAVE AREA.                                               */ 02444000
*   /*                                                               */ 02445000
*   /*****************************************************************/ 02446000
*                                                                  0712 02447000
*   RFY                                                            0712 02448000
*    (R1,                                                          0712 02449000
*     R11,                                                         0712 02450000
*     R13) RSTD;                                                   0712 02451000
*   R8=R13;                         /* SAVE ADDR CALLERS SAVE AREA   */ 02452000
         LR    R8,R13                                              0713 02453000
*   LGEPTR=R1;                      /* OBTAIN THE ADDR OF THE LGE TO    02454000
*                                      BE FREED                      */ 02455000
         LR    R5,R1                                            DSK1133 02456000
*   RFY                                                            0715 02457000
*     ASCBPTR RSTD;                                                0715 02458000
*   ASCBPTR=PSAAOLD;                /* OBTAIN ADDR ASCB              */ 02459000
         L     R10,PSAAOLD-PSA                                  DSK1133 02460000
*   RSMHDPTR=ASCBRSM;               /* OBTAIN ADDR RSM HEADER        */ 02461000
         L     R2,ASCBRSM-ASCB(,R10)                            DSK1133 02462000
*   R11=ADDR(ASHLOCK);              /* OBTAIN ASM LOCKWORD           */ 02463000
         LA    R11,ASHLOCK-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 02464000
*   GEN REFS(R11);                                                 0719 02465000
*              /* OBTAIN THE ASM CLASS LOCK */                          02466000
GETASM2  SETLOCK  OBTAIN,TYPE=ASM,ADDR=(11),MODE=UNCOND,              **02467000
               RELATED=(VIO,ILRGOS(FREASM2/3))                          02468000
*   RFY                                                            0720 02469000
*     R11 UNRSTD;                                                  0720 02470000
*   ASCBVSC=ASCBVSC+LGESLTCT;       /* UPDATE THE VIO SLOT COUNT BY     02471000
*                                      COUNT RETURNED BY THE RELEASE    02472000
*                                      GROUP OPERATOR                */ 02473000
         LH    R15,ASCBVSC-ASCB(,R10)                           DSK1133 02474000
         AH    R15,LGESLTCT(,R5)                                DSK1133 02475000
         STH   R15,ASCBVSC-ASCB(,R10)                           DSK1133 02476000
*   RFY                                                            0722 02477000
*     ASCBPTR UNRSTD;                                              0722 02478000
*   CALL FRELG;                     /* TO PREFORM ACTUAL FREE      0723 02479000
*                                      PROCESSING                    */ 02480000
         BAL   R14,FRELG                                        DSK1133 02481000
*FRELGEND:                                                         0724 02482000
*   R13=R8;                         /* RESTORE CALLERS SAVE AREA ADDR*/ 02483000
FRELGEND LR    R13,R8                                              0724 02484000
*   RFY                                                            0725 02485000
*     R15 RSTD;                                                    0725 02486000
*   RETURN CODE(R15);               /* RESTORE REGS AND RETURN TO  0726 02487000
*                                      CALLER                        */ 02488000
         L     R14,12(,R13)                                     DSK1133 02489000
         LM    R0,R12,20(R13)                                   DSK1133 02490000
         BR    R14                                              DSK1133 02491000
*   RFY                                                            0727 02492000
*     R15 UNRSTD;                                                  0727 02493000
*                                                                  0728 02494000
*   /*****************************************************************/ 02495000
*   /*                                                               */ 02496000
*   /* FRELG IS CALLED BY THE MAINLINE OF GOS AND ILRFRELG TO DEQUEUE*/ 02497000
*   /* AND FREE AN LGE AND TO REINITIALIZE THE LGVTE AND PUT IT BACK */ 02498000
*   /* ON THE AVAILABLE QUEUE.                                       */ 02499000
*   /*                                                               */ 02500000
*   /*****************************************************************/ 02501000
*                                                                  0728 02502000
*FRELG:                                                            0728 02503000
*   PROCEDURE OPTIONS(NOSAVE,NOSAVEAREA);                          0728 02504000
FRELG    DS    0H                                                  0729 02505000
*   RFY                                                            0729 02506000
*    (R14,                                                         0729 02507000
*     R15,                                                         0729 02508000
*     R10) RSTD;                                                   0729 02509000
*   R10=R14;                        /* SAVE RETURN ADDR              */ 02510000
         LR    R10,R14                                             0730 02511000
*   IF ASHLGEQ=ZERO THEN                                           0731 02512000
         L     R12,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 02513000
         LTR   R12,R12                                          DSK1133 02514000
         BNZ   @RF00731                                            0731 02515000
*     R15=CODE04;                   /* ASMHD LGE QUEUE EMPTY         */ 02516000
         LA    R15,4                                               0732 02517000
*   ELSE                                                           0733 02518000
*     DO;                           /* ASMHD LGE Q IS NOT EMPTY      */ 02519000
         B     @RC00731                                            0733 02520000
@RF00731 DS    0H                                                  0734 02521000
*       R15=CODE00;                 /* INTIALIZE RETURN CODE TO ZERO */ 02522000
         SLR   R15,R15                                             0734 02523000
*       IF ASHLGEQ=LGEPTR THEN                                     0735 02524000
         C     R5,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)             DSK1133 02525000
         BNE   @RF00735                                            0735 02526000
*         ASHLGEQ=LGENEXT;          /* IF THE LGE IS THE FIRST ON THE   02527000
*                                      Q SET THE Q ANCHOR TO THE NEXT   02528000
*                                      LGE                           */ 02529000
*                                                                  0736 02530000
         L     R12,LGENEXT(,R5)                                 DSK1133 02531000
         ST    R12,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 02532000
*       /*************************************************************/ 02533000
*       /*                                                           */ 02534000
*       /* SEARCH THE ASM HEADER QUEUE FOR THE LGE TO BE FREED       */ 02535000
*       /*                                                           */ 02536000
*       /*************************************************************/ 02537000
*                                                                  0737 02538000
*       ELSE                                                       0737 02539000
*         DO;                       /* LGE NOT FIRST ON Q            */ 02540000
         B     @RC00735                                            0737 02541000
@RF00735 DS    0H                                                  0738 02542000
*           RFY                                                    0738 02543000
*             FOUNDLGE RSTD;                                       0738 02544000
*           RFY                                                    0739 02545000
*             LGE BASED(FOUNDLGE);                                 0739 02546000
*           FOUNDLGE=ASHLGEQ;       /* OBTAIN ADDR FIRST ELEMENT ON Q*/ 02547000
         L     R12,ASHLGEQ-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 02548000
*           DO WHILE LGENEXT^=LGEPTR&LGENEXT^=ZERO;/* LOOP THRU THE     02549000
*                                      LGES UNTIL THE ONE TO BE    0741 02550000
*                                      RELEASED IS FOUND OR NONE ARE    02551000
*                                      LEFT                          */ 02552000
         B     @DE00741                                            0741 02553000
@DL00741 DS    0H                                                  0742 02554000
*             FOUNDLGE=LGENEXT;     /* OBTAIN ADDR NEXT LGE          */ 02555000
         L     R12,LGENEXT(,R12)                                DSK1133 02556000
*           END;                    /* LOOP THRU LGES                */ 02557000
@DE00741 L     R0,LGENEXT(,R12)                                 DSK1133 02558000
         CR    R0,R5                                            DSK1133 02559000
         BE    @DC00741                                            0743 02560000
         LTR   R0,R0                                            DSK1133 02561000
         BNZ   @DL00741                                            0743 02562000
@DC00741 DS    0H                                                  0744 02563000
*           IF LGENEXT^=ZERO THEN                                  0744 02564000
         L     R0,LGENEXT(,R12)                                 DSK1133 02565000
         LTR   R0,R0                                            DSK1133 02566000
         BZ    @RF00744                                            0744 02567000
*             LGENEXT=LGEPTR->LGENEXT;/* DEQUEUES THE LGE, SETS NEXT    02568000
*                                      OF PREVIOUS LGE TO NEXT OF LGE*/ 02569000
         L     R0,LGENEXT(,R5)                                  DSK1133 02570000
         ST    R0,LGENEXT(,R12)                                 DSK1133 02571000
*           ELSE                                                   0746 02572000
*             R15=CODE04;           /* LGE NOT FOUND                 */ 02573000
         B     @RC00744                                            0746 02574000
@RF00744 LA    R15,4                                               0746 02575000
*           RFY                                                    0747 02576000
*             FOUNDLGE UNRSTD;                                     0747 02577000
@RC00744 DS    0H                                                  0748 02578000
*         END;                      /* LGE NOT FIRST ON Q            */ 02579000
*     END;                          /* ASMHD LGE Q IS NOT EMPTY      */ 02580000
@RC00735 DS    0H                                                  0750 02581000
*   IF R15=CODE04 THEN                                             0750 02582000
@RC00731 C     R15,@CF00051                                        0750 02583000
         BNE   @RF00750                                            0750 02584000
*     DO;                           /* LGE NOT FOUND OR Q IS EMPTY   */ 02585000
*       RFY                                                        0752 02586000
*         R11 RSTD;                                                0752 02587000
*       R11=ADDR(ASHLOCK);          /* OBTAIN ASM LOCKWORD           */ 02588000
         LA    R11,ASHLOCK-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 02589000
*       GEN REFS(R11);                                             0754 02590000
*              /* FREE THE ASM CLASS LOCK */                            02591000
FREASM2  SETLOCK  RELEASE,TYPE=ASM,ADDR=(11),                         **02592000
               RELATED=(VIO,ILRGOS(GETASM1/2))                          02593000
*       RFY                                                        0755 02594000
*         R11 UNRSTD;                                              0755 02595000
*     END;                          /* END LGE NOT FOUND OR Q IS   0756 02596000
*                                      EMPTY                         */ 02597000
*                                                                  0757 02598000
*   /*****************************************************************/ 02599000
*   /*                                                               */ 02600000
*   /* THE LGE WAS FOUND AND DEQUEUED. THE SALLOC LOCK IS OBTAINED.  */ 02601000
*   /* THE LGVTE IS DETERMINED AND RESTORED TO THE LGVT AVAILABLE    */ 02602000
*   /* QUEUE. THE LGE IS THEN FREED.                                 */ 02603000
*   /*                                                               */ 02604000
*   /*****************************************************************/ 02605000
*                                                                  0757 02606000
*   ELSE                                                           0757 02607000
*     DO;                           /* LGE WAS FOUND                 */ 02608000
         B     @RC00750                                            0757 02609000
@RF00750 DS    0H                                                  0758 02610000
*       RFY                                                        0758 02611000
*         LGE BASED(LGEPTR);                                       0758 02612000
*       LGEPROCF=ZERO;              /* CLEAR THE FIRST AND           */ 02613000
         SLR   R12,R12                                          DSK1133 02614000
         ST    R12,LGEPROCF(,R5)                                DSK1133 02615000
*       LGEPROCL=ZERO;              /* LAST AIA POINTERS OF THE LGE  */ 02616000
*                                                                  0760 02617000
         ST    R12,LGEPROCL(,R5)                                DSK1133 02618000
*       /*************************************************************/ 02619000
*       /*                                                           */ 02620000
*       /* RELEASE THE ASM LOCK AND OBTAIN THE SALLOC LOCK. R13 WILL */ 02621000
*       /* INDICATE WHETHER THE SALLOC LOCK WAS OBTAINED HERE, OR    */ 02622000
*       /* HELD BY THE CALLER AS WHEN RECOVERY INVOKES THIS ROUTINE. */ 02623000
*       /*                                                           */ 02624000
*       /*************************************************************/ 02625000
*                                                                  0761 02626000
*       RFY                                                        0761 02627000
*        (R11,                                                     0761 02628000
*         R13) RSTD;                                               0761 02629000
*       R11=ADDR(ASHLOCK);          /* OBTAIN ADDR ASM LOCKWORD      */ 02630000
         LA    R11,ASHLOCK-ASMHD+RSMASMHD-RSMHD(,R2)            DSK1133 02631000
*       GEN REFS(R11);                                             0763 02632000
*              /* RELEASE ASM LOCK OBTAIN SALLOC LOCK */                02633000
FREASM3  SETLOCK  RELEASE,TYPE=ASM,ADDR=(11),                         **02634000
               RELATED=(VIO,ILRGOS(GETASM1/2))                          02635000
GETSAL2  SETLOCK  OBTAIN,TYPE=SALLOC,MODE=UNCOND,                     **02636000
               RELATED=(VIO,ILRGOS(FRESAL2))                            02637000
*       R14=R10;                    /* RESTORE RETURN ADDR           */ 02638000
         LR    R14,R10                                             0764 02639000
*       RFY                                                        0765 02640000
*        (LGVTPTR,                                                 0765 02641000
*         LGVTEPTR) RSTD;                                          0765 02642000
*                                                                  0765 02643000
*       /*************************************************************/ 02644000
*       /*                                                           */ 02645000
*       /* INITIALIZE THE LGVTE AND MAKE IT AVAILABLE AGAIN. FREE THE*/ 02646000
*       /* LGE AND RETURN TO THE CALLER.                             */ 02647000
*       /*                                                           */ 02648000
*       /*************************************************************/ 02649000
*                                                                  0766 02650000
*       LGVTPTR=ASMLGVT;            /* OBTAIN ADDR LGVT              */ 02651000
         L     R11,ASMLGVT-ASMVT(,R3)                           DSK1133 02652000
*       LGVTEPTR=ADDR(LGVENTRS(LGELGID+ONE));/* LGID GIVES OFFSET  0767 02653000
*                                      INTO LGVT                     */ 02654000
         L     R12,LGELGID(,R5)                                 DSK1133 02655000
         LR    R0,R12                                           DSK1133 02656000
         SLA   R0,3                                             DSK1133 02657000
         LR    R10,R0                                           DSK1133 02658000
         LA    R10,LGVENTRS(R10,R11)                            DSK1133 02659000
*       LGVELGID=LGELGID;           /* PUT THE LGID IN THE LGVTE     */ 02660000
         ST    R12,LGVELGID(,R10)                               DSK1133 02661000
*       LGVENEXT=LGVLGVEP;          /* Q THE AVAILABLE Q TO THE LGVTE*/ 02662000
         L     R12,LGVLGVEP(,R11)                               DSK1133 02663000
         ST    R12,LGVENEXT(,R10)                               DSK1133 02664000
*       LGVLGVEP=LGVTEPTR;          /* MAKE THE LGVTE THE FIRST    0770 02665000
*                                      ELEMENT ON THE AVAILABLE QUEUE*/ 02666000
         ST    R10,LGVLGVEP(,R11)                               DSK1133 02667000
*       RFY                                                        0771 02668000
*        (LGVTPTR,                                                 0771 02669000
*         LGVTEPTR) UNRSTD;                                        0771 02670000
*       RFY                                                        0772 02671000
*        (R1AREA,                                                  0772 02672000
*         R12) RSTD;                                               0772 02673000
*       R1AREA=LGEPTR;              /* ADDR AREA TO BE FREED         */ 02674000
         LR    R1,R5                                            DSK1133 02675000
*       R12=LENGTH(LGE);            /* OBTAIN LENGTH AREA TO BE FREED*/ 02676000
         LA    R12,24                                              0774 02677000
*       R10=R14;                    /* STORE RETURN ADDR ACROSS    0775 02678000
*                                      SETLOCK                       */ 02679000
         LR    R10,R14                                             0775 02680000
*       R11=R4;                     /* STORE R4, DESTROYED IN      0776 02681000
*                                      FREEMAIN                      */ 02682000
         LR    R11,R4                                              0776 02683000
*       GEN REFS(R1AREA,R12,R13) SETS(R3,R4);                      0777 02684000
*                                     /* FREE LGE AND RELEASE SALLOC *  02685000
         FREEMAIN RC,LV=(R12),A=(R1),SP=245,BRANCH=(YES,GLOBAL) DSK1133 02686000
         LR       R4,R11   RESTORE R4, DESTROYED IN FREEMAIN            02687000
         LTR      R13,R13  THE SALLOC LOCK IS ONLY RELEASED IF IT WAS   02688000
         BNZ      SKIPREL  OBTAINED IN THIS ROUTINE, INDICATED BY R13   02689000
FRESAL2  SETLOCK  RELEASE,TYPE=SALLOC,RELATED=(VIO,ILRGOS(GETSAL2))     02690000
SKIPREL  DS       0H                                                    02691000
*       RFY                                                        0778 02692000
*        (R1AREA,                                                  0778 02693000
*         R12,                                                     0778 02694000
*         R13) UNRSTD;                                             0778 02695000
*       ASMVTPTR=CVTASMVT;          /* RESTORE R3, DESTROYED IN    0779 02696000
*                                      FREEMAIN                      */ 02697000
         L     R12,CVTPTR                                       DSK1133 02698000
         L     R3,CVTASMVT-CVT(,R12)                            DSK1133 02699000
*       R15=CODE00;                 /* ZERO RETURN CODE              */ 02700000
         SLR   R15,R15                                             0780 02701000
*     END;                          /* LGE WAS FOUND                 */ 02702000
*   RFY                                                            0782 02703000
*     R14 RSTD;                                                    0782 02704000
@RC00750 DS    0H                                                  0783 02705000
*   R14=R10;                        /* RESTORE THE RETURN ADDR       */ 02706000
         LR    R14,R10                                             0783 02707000
*   END FRELG;                                                     0784 02708000
@EL00005 DS    0H                                                  0784 02709000
@EF00005 DS    0H                                                  0784 02710000
@ER00005 BR    R14                                              DSK1133 02711000
*   END ILRGOS                                                     0785 02712000
*                                                                  0785 02713000
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.     */ 02714000
*/*%INCLUDE SYSLIB  (ILRACA  )                                       */ 02715000
*/*%INCLUDE SYSLIB  (ILRACE  )                                       */ 02716000
*/*%INCLUDE SYSLIB  (IHAASCB )                                       */ 02717000
*/*%INCLUDE SYSLIB  (IHARSMHD)                                       */ 02718000
*/*%INCLUDE SYSLIB  (ILRASMHD)                                       */ 02719000
*/*%INCLUDE SYSLIB  (ILRASMVT)                                       */ 02720000
*/*%INCLUDE SYSLIB  (ILRASPCT)                                       */ 02721000
*/*%INCLUDE SYSLIB  (ILRATA  )                                       */ 02722000
*/*%INCLUDE SYSLIB  (CVT     )                                       */ 02723000
*/*%INCLUDE SYSLIB  (ILREPATH)                                       */ 02724000
*/*%INCLUDE SYSLIB  (IHAFRRS )                                       */ 02725000
*/*%INCLUDE SYSLIB  (ILRLGE  )                                       */ 02726000
*/*%INCLUDE SYSLIB  (ILRLGVT )                                       */ 02727000
*/*%INCLUDE SYSLIB  (IHAPSA  )                                       */ 02728000
*/*%INCLUDE SYSLIB  (IHASRB  )                                       */ 02729000
*/*%INCLUDE SYSLIB  (IHAWSAVT)                                       */ 02730000
*                                                                  0785 02731000
*       ;                                                          0785 02732000
         B     @EL00001                                            0785 02733000
@DATA    DC    0H'0'                                            DSK1133 02734000
@CH01810 DC    H'1088'                                                  02735000
@DATD    DSECT                                                          02736000
         DS    0F                                                       02737000
ILRGOS   CSECT                                                          02738000
         DC    0F'0'                                            DSK1133 02739000
@CF00040 DC    F'1'                                                     02740000
@CF00051 DC    F'4'                                                     02741000
@CF00438 DC    F'28'                                                    02742000
@CF00507 DC    F'40'                                                    02743000
@CF01405 DC    F'44'                                                    02744000
@CF01282 DC    F'512'                                                   02745000
@CF01675 DC    XL4'00040000'                                            02746000
@CF01677 DC    XL4'FFFFFFFF'                                            02747000
@CF01812 DC    XL4'0000FFFF'                                            02748000
@DATD    DSECT                                                          02749000
         DS    0D                                                       02750000
SLOTS    DS    F                                                        02751000
RTNADDR  DS    A                                                        02752000
RTNCODE  DS    F                                                        02753000
SAVASPCT DS    A                                                        02754000
SAVLGVTE DS    A                                                        02755000
SQALEFT  DS    A                                                        02756000
R4SAVE   DS    F                                                        02757000
R7SAVE   DS    F                                                        02758000
EPATH    DS    CL52                                                     02759000
         ORG   EPATH                                                    02760000
EPAVSAM  DS    CL52                                                     02761000
         ORG   EPAVSAM                                                  02762000
EPAOWKA  DS    AL4                                                      02763000
EPAVWKA  DS    AL4                                                      02764000
         ORG   EPAVWKA                                                  02765000
EPATMWKA DS    AL4                                                      02766000
         ORG   EPATMWKA                                                 02767000
EPASWKA  DS    AL4                                                      02768000
         ORG   EPAVSAM+8                                                02769000
EPAAASP  DS    AL4                                                      02770000
         ORG   EPAAASP                                                  02771000
EPADSLST DS    AL4                                                      02772000
         ORG   EPAVSAM+12                                               02773000
EPABASP  DS    AL4                                                      02774000
         ORG   EPABASP                                                  02775000
EPATMIBA DS    AL4                                                      02776000
         ORG   EPAVSAM+16                                               02777000
EPARASP  DS    AL4                                                      02778000
         ORG   EPARASP                                                  02779000
EPATMACB DS    AL4                                                      02780000
         ORG   EPAVSAM+20                                               02781000
EPARTYRG DS    AL4                                                      02782000
         ORG   EPARTYRG                                                 02783000
EPABKSLT DS    FL4                                                      02784000
         ORG   EPABKSLT                                                 02785000
EPATMISV DS    AL4                                                      02786000
         ORG   EPAVSAM+24                                               02787000
EPAFLAG1 DS    BL1                                                      02788000
         ORG   EPAFLAG1                                                 02789000
EPAVSAMI DS    BL1                                                      02790000
EPAGRPOP EQU   EPAFLAG1+0                                               02791000
         ORG   EPAGRPOP                                                 02792000
EPARLG   EQU   EPAGRPOP+0                                               02793000
EPASAVE  EQU   EPAGRPOP+0                                               02794000
EPAACT   EQU   EPAGRPOP+0                                               02795000
         ORG   EPAFLAG1+0                                               02796000
EPAACASR EQU   EPAFLAG1+0                                               02797000
EPAASGN  EQU   EPAFLAG1+0                                               02798000
EPAUNSAV EQU   EPAFLAG1+0                                               02799000
EPARPLB  EQU   EPAFLAG1+0                                               02800000
         ORG   EPAVSAM+25                                               02801000
EPAFLAG2 DS    BL1                                                      02802000
         ORG   EPAFLAG2                                                 02803000
EPATMXIT DS    BL1                                                      02804000
EPAWARM  EQU   EPAFLAG2+0                                               02805000
EPACOLD  EQU   EPAFLAG2+0                                               02806000
EPABUILD EQU   EPAFLAG2+0                                               02807000
EPAMAST  EQU   EPAFLAG2+0                                               02808000
EPATMI   EQU   EPAFLAG2+0                                               02809000
EPARECUR EQU   EPAFLAG2+0                                               02810000
         ORG   EPAVSAM+26                                               02812000
EPALSIZE DS    FL2                                                      02813000
EPALGVTP DS    AL4                                                      02814000
EPALGEP  DS    AL4                                                      02815000
EPASRB   DS    AL4                                                      02816000
EPAACE   DS    AL4                                                      02817000
EPARBASP DS    AL4                                                      02818000
EPARSIZE DS    FL2                                                      02819000
@NM00020 DS    FL2                                                      02820000
         ORG   EPATH+52                                                 02821000
SAVAREA  DS    CL72                                                     02822000
WKATA    DS    CL24                                                     02823000
WKBUFCON DS    CL12                                                     02824000
INTFLAG  DS    CL1                                                      02825000
         ORG   INTFLAG                                                  02826000
REQASPCT DS    BL1                                                      02827000
IDEXISTS EQU   INTFLAG+0                                                02828000
         ORG   INTFLAG+1                                                02830000
ILRGOS   CSECT                                                          02831000
         NOPR  ((@ENDDATD-@DATD)/257*16)                                02832000
         DC    0F'0'                                            DSK1133 02833000
@SIZDATD DC    AL1(0)                                                   02834000
         DC    AL3(@ENDDATD-@DATD)                                      02835000
@CV01708 DC    V(ILRCGOSE)                                              02836000
@CV01709 DC    V(ILRGOS01)                                              02837000
         DC    0D'0'                                            DSK1133 02838000
@CC01687 DC    C'ASPC'                                                  02839000
@CC01689 DC    C'SRB '                                                  02840000
@CB01681 DC    X'0000000000000000'                                      02841000
@DATD    DSECT                                                          02842000
ESTAELST ESTAE MF=L            LIST FORM OF ESTAE                       02843000
POSTLIST POST  MF=L            LIST FORM OF POST                        02844000
@DATD    DSECT                                                          02845000
         ORG   *+1-(*-@DATD)/(*-@DATD) INSURE DSECT DATA                02846000
@ENDDATD EQU   *                                                        02847000
ILRGOS   CSECT                                                          02848000
         CVT      DSECT=YES,LIST=YES                            DSK1133 02848993
         IHAASCB  ,                                             DSK1133 02848994
         IHAFRRS  ,                                             DSK1133 02848995
         IHAPSA   ,                                             DSK1133 02848996
         IHASRB   ,                                             DSK1133 02848997
         ILRASMVT ,                                             DSK1133 02848998
         ILRASMHD ,                                             DSK1133 02848999
         IRAEPAT  ,                                             DSK1133 02849000
IRACTMQE EQU   0                                                DSK1133 02849001
         IHARSMHD ,                                             DSK1133 02849002
         IHASPCT  ,                                             DSK1133 02849003
         ILRATA   ,                                             DSK1133 02849004
         IHAWSAVT CLASS=GLOBAL                                  DSK1133 02849005
         ILRACA   ,                                             DSK1133 02849006
         ILRACE   ,                                             DSK1133 02849007
         ILRLGVT  ,                                             DSK1133 02849008
         ILRLGE   ,                                             DSK1133 02849010
         ILRASPCT ,                                             DSK1133 02849011
R0       EQU   0                       REGISTER 0               DSK1133 02849012
R1       EQU   1                       REGISTER 1               DSK1133 02849013
R2       EQU   2                       REGISTER 2               DSK1133 02849014
R3       EQU   3                       REGISTER 3               DSK1133 02849015
R4       EQU   4                       REGISTER 4               DSK1133 02849016
R5       EQU   5                       REGISTER 5               DSK1133 02849017
R6       EQU   6                       REGISTER 6               DSK1133 02849018
R7       EQU   7                       REGISTER 7               DSK1133 02849019
R8       EQU   8                       REGISTER 8               DSK1133 02849020
R9       EQU   9                       REGISTER 9               DSK1133 02849021
R10      EQU   10                      REGISTER 10              DSK1133 02849022
R11      EQU   11                      REGISTER 11              DSK1133 02849023
R12      EQU   12                      REGISTER 12              DSK1133 02849024
R13      EQU   13                      REGISTER 13              DSK1133 02849025
R14      EQU   14                      REGISTER 14              DSK1133 02849026
R15      EQU   15                      REGISTER 15              DSK1133 02849027
ILRSAV   EQU   0                                                        03141000
ILRACT   EQU   0                                                        03142000
ILRRLG   EQU   0                                                        03143000
WKAREA   EQU   0                                                        03144000
BUFCONBK EQU   0                                                        03145000
BUFCHAIN EQU   BUFCONBK                                                 03146000
BUFASCB  EQU   BUFCONBK+4                                               03147000
BUFACE   EQU   BUFCONBK+8                                               03148000
SLOTV    EQU   0                                                        03149000
ILRPEX   EQU   0                                                        03150000
GMACELL  EQU   0                                                        03151000
GMANEXT  EQU   GMACELL                                                  03152000
RTRYRGSV EQU   SAVAREA+12                                               03192000
GOSEND   EQU   @EL00001                                                 04411000
@ENDDATA EQU   *                                                        04416000
         END   ILRGOS                                           DSK1133 04417000
