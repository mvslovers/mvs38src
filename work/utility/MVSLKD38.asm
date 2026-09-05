*********************************************************************** 00000100
*                                                                     * 00000200
* MODULE NAME                                                         * 00000300
*    MVSLKD38                                                         * 00000400
*                                                                     * 00000500
* ATTRIBUTES                                                          * 00000600
*    NONE                                                             * 00000700
*                                                                     * 00000800
* AUTHOR                                                              * 00000900
*    DAVE KREISS                                                      * 00001000
*                                                                     * 00001100
* FUNCTION                                                            * 00001200
*    CREATE INDIVIDUAL LISTING MEMBER FROM SMP APPLY/ACCEPT OUTPUT    * 00001300
*    FOR LINKEDITS PERFORMED BY SMP RUN.                              * 00001400
*                                                                     * 00001500
* JCL                                                                 * 00001600
*    //GENLIST EXEC PGM=MVSLKD38,PARM='PARAMETERS'                    * 00001700
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00001800
*    //SYSPRINT DD  SYSOUT=*                                          * 00001900
*    //SYSIN    DD  DSN=OUTPUT FROM APPLY/ACCEPT DATA SET             * 00002000
*    //LIST     DD  DSN=DATA SET CONTAINING INDIVIDUAL LINKEDITS      * 00002100
*                                                                     * 00002200
* DD STATEMENTS                                                       * 00002300
*    STEPLIB       LOAD LIBRARY AINING THE MODULE MVSLKD38.           * 00002400
*    SYSPRINT      CONTAINS VARIOUS STATUS INFORMATION                * 00002500
*    SYSIN         INPUT DATA SET CONTAINING OUTPUT FROM A SMP        * 00002600
*                  APPLY OR ACCEPT RUN.                               * 00002700
*    LIST          OUTPUT PDS WHICH IS USED TO CREATE MEMBERS         * 00002800
*                  CONTAINING INDIVIDUAL LOAD MODULE LINKEDITS.       * 00002900
*                                                                     * 00003000
* PARAMETERS                                                          * 00003100
*    ALL PARAMETERS ARE SEPERATED BY COMMAS.                          * 00003200
*    LOG            LOGS MODULES DETECTED                             * 00003300
*    LIST           LISTS ERROR MESSAGES IF SELECTED (SEE STATUS=(X)) * 00003400
*    DEBUG          PRODUCES DEBUGGING INFO                           * 00003500
*    STATUS(X)      LINKEDIT STATUS OF W OR E USED TO SELECT          * 00003600
*    SKIP(NNNN,..)  LINK EDIT MESSAGE NUMBERS TO SKIP                 * 00003700
*    ERRORS         PRODUCES MEMBERS ONLY IF ERRORS ARE DETECTED      * 00003800
*                                                                     * 00003900
* SAMPLE JCL                                                          * 00004000
*    //GENLST  EXEC PGM=MVSLKD38,PARM='LOG'                           * 00004100
*    //STEPLIB  DD  DSN=HERC01.LOAD,DISP=SHR                          * 00004200
*    //SYSPRINT DD  SYSOUT=*                                          * 00004300
*    //SYSIN    DD  DSN=MVSSRC.BLD.SMPOUT,DISP=SHR                    * 00004400
*    //         DD  DSN=MVSSRC.BLD.ASMPRINT,DISP=SHR                  * 00004500
*    //LIST     DD  DSN=MVSSRC.BLD.APPLY.LINKLIST,DISP=SHR            * 00004600
*                                                                     * 00004700
*********************************************************************** 00004800
*                                                                     * 00004900
* CHANGE LOG:                                                         * 00004910
*   DATE     AAA VV.VV DESCRIPTION                                    * 00004920
* 10/09/2014 DSK 01.01 Created                                        * 00005100
         LCLC   &VER                                                    00005200
&VER     SETC   '01.01'                                                 00005300
*                                                                     * 00005400
*********************************************************************** 00005500
****************************************************************        00005510
*                                                              *        00005520
*   PROGRAM INITIALIZATION                                     *        00005530
*                                                              *        00005540
****************************************************************        00005550
MVSLKD38 CSECT ,                                                        00005600
         USING MVSLKD38,R15                                             00005700
         B     MAINBGN                                                  00005800
         DROP  R15                                                      00005900
         DC    AL1(L'MAINID)                                            00006000
MAINID   DC    C'MVSLKD38 - &VER &SYSDATE &SYSTIME'                     00006100
MAINBGN  DC    0H'+0'                                                   00006200
         STM   R14,R12,12(R13)                                          00006300
         LR    R11,R15                                                  00006400
         LA    R12,2048(,R11)                                           00006500
         LA    R12,2048(,R12)                                           00006600
         USING MVSLKD38,R11,R12                                         00006700
         L     R10,=A(W#SA)                                             00006800
         USING W#,R10                                                   00006900
         ST    R13,4(,R10)                                              00007000
         ST    R10,8(,R13)                                              00007100
         LR    R13,R10                                                  00007200
         L     R2,0(,R1)                                                00007300
         ST    R2,W#PARMAD                                              00007400
         OPEN  (W#PRTDD,(OUTPUT),SYSIN,(INPUT))                         00007500
         TM    W#PRTDD+48,16                                            00007600
         BE    MAINQUIT                                                 00007700
         TM    SYSIN+48,16                                              00007800
         BE    MAINQUIT                                                 00007900
         TIME  BIN                     GET CURRENT DATE AND TIME        00008000
         ST    R1,W#CURDTE             SAVE DATE                        00008100
         SRDL  R0,32                   GET DOUBLE WORD TIME             00008200
         D     R0,=F'+6000'            GET MINUTES                      00008300
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00008400
         SLR   R0,R0                   CLEAR                            00008500
         D     R0,=F'+60'              GET HOURS / MINS                 00008600
         MH    R0,=H'+10000'           GET MINUTES                      00008700
         AR    R15,R0                  ADD TO GET MM:SS.TH              00008800
         M     R0,=F'+1000000'         GET HOURS                        00008900
         AR    R1,R15                  GET HH:MM:SS.TH                  00009000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              00009100
         MVC   W#TMWK4,=X'402021207A20207A20204B2020'                   00009200
         ED    W#TMWK4,W#DWORD+3       EDIT TIME                        00009300
         MVC   W#HD1TOD(8),W#TMWK4+2   MOVE TIME                        00009400
         ZAP   JULWRK2,W#CURDTE+2(2)   GET JULIAN DATE                  00009500
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    00009600
         ZAP   JULWRK6,=P'+28'         FEB = 28                         00009700
         MVO   W#DWORD,W#CURDTE+1(1)   SIGN YEAR                        00009800
         DP    W#DWORD,=P'+4'          DIVIDE BY 4                      00009900
         CP    W#DWORD+7(1),=P'+0'     IS IT A LEAP YEAR ?              00010000
         BNZ   MAINJC2                  NO                              00010100
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    00010200
         ZAP   JULWRK6,=P'+29'         FEB = 29                         00010300
MAINJC2  DS    0H                                                       00010400
         LA    R1,JULTBL1              POINT TO JANUARY                 00010500
         SLR   R2,R2                   SET COUNTER                      00010600
MAINJC4  DS    0H                                                       00010700
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              00010800
         BNP   MAINJC6                 IF EQUAL OR LESS THAN 0, BRANCH  00010900
         BCTR  R1,0                    POINT TO NEXT MONTH              00011000
         BCTR  R1,0                    POINT TO NEXT MONTH              00011100
         LA    R2,3(,R2)               UP INDEX                         00011200
         B     MAINJC4                 LOOP                             00011300
MAINJC6  DS    0H                                                       00011400
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                00011500
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    00011600
         MVC   W#HD1DTE(3),0(R2)       MOVE MONTH                       00011700
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     00011800
         UNPK  W#HD1DTE+4(2),JULWRK2   GET DAYS                         00011900
         CLI   W#HD1DTE+4,C'0'         FIRST 9 DAYS ?                   00012000
         LA    R1,W#HD1DTE+6           SET POINTER                      00012100
         BNE   MAINJC7                  NO                              00012200
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 MOVE UNITS DIGIT                00012300
         BCTR  R1,0                    DROP POINTER                     00012400
MAINJC7  DS    0H                                                       00012500
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  00012600
         TM    W#CURDTE,1              YEAR 2000?                       00012700
         BNO   MAINJC8                  NO, CONTINUE                    00012800
         MVC   2(2,R1),=C'20'          Y2K                              00012900
MAINJC8  DS    0H                                                       00013000
         UNPK  W#DWORD(3),W#CURDTE+1(2) UNPACK YEAR                     00013100
         MVC   4(2,R1),W#DWORD         GET YEAR                         00013200
         MVC   W#LINE+1(8),=C'Version='                                 00013300
         MVC   W#LINE+9(L'MAINID),MAINID                                00013400
         BAL   R14,MAINPRT                                              00013500
         L     R9,W#PARMAD                                              00013600
         MVC   W#LINE+1(5),=C'Parm='                                    00013700
         CLI   1(R9),0                                                  00013800
         BE    MAINPRPA                                                 00013900
         LH    R1,0(,R9)                                                00014000
         BCTR  R1,0                                                     00014100
         EX    R1,MAINPRMV                                              00014200
         B     MAINPRPA                                                 00014300
MAINPRMV MVC   W#LINE+6(0),2(R9)                                        00014400
MAINPRPA DS    0H                                                       00014500
         BAL   R14,MAINPRT                                              00014600
         LH    R2,0(,R9)                                                00014700
         LA    R9,2(,R9)                                                00014800
MAINPRSC DS    0H                                                       00014900
         LTR   R2,R2                                                    00015000
         BE    MAINPRZ                                                  00015100
         CLI   0(R9),C','                                               00015200
         BNE   MAINPRCK                                                 00015300
MAINPRCO DS    0H                                                       00015400
         LA    R9,1(,R9)                                                00015500
         BCTR  R2,0                                                     00015600
         B     MAINPRSC                                                 00015700
MAINPRCK DS    0H                                                       00015800
         CH    R2,=H'+3'                                                00015900
         BL    MAINPRER                                                 00016000
         CLC   =C'LOG',0(R9)                                            00016100
         BE    MAINPRLG                                                 00016200
         CH    R2,=H'+4'                                                00016300
         BL    MAINPRER                                                 00016400
         CLC   =C'LIST',0(R9)                                           00016500
         BE    MAINPRLI                                                 00016600
         CH    R2,=H'+5'                                                00016700
         BL    MAINPRER                                                 00016800
         CLC   =C'DEBUG',0(R9)                                          00016900
         BE    MAINPRDB                                                 00017000
         CH    R2,=H'+6'                                                00017100
         BL    MAINPRER                                                 00017200
         CLC   =C'STATUS',0(R9)                                         00017300
         BE    MAINPRST                                                 00017400
         CLC   =C'SKIP(',0(R9)                                          00017500
         BE    MAINPRSK                                                 00017600
         CLC   =C'ERRORS',0(R9)                                         00017700
         BE    MAINPRRR                                                 00017800
         B     MAINPRER                                                 00017900
MAINPRLG DS    0H                                                       00018000
         OI    W#FLAG2,W#FL2LG                                          00018100
         LA    R9,3(,R9)                                                00018200
         SH    R2,=H'+3'                                                00018300
         CH    R2,=H'+2'                                                00018400
         BL    MAINPRSC                                                 00018500
         CLI   0(R9),C'('                                               00018600
         BNE   MAINPRSC                                                 00018700
         CLI   2(R9),C')'                                               00018800
         BNE   MAINPRSC                                                 00018900
         CLI   1(R9),C'W'                                               00019000
         BNE   MAINPRLE                                                 00019100
         OI    W#FLAG2,W#FL2LGW                                         00019200
         LA    R9,3(,R9)                                                00019300
         SH    R2,=H'+3'                                                00019400
         B     MAINPRSC                                                 00019500
MAINPRLE DS    0H                                                       00019600
         CLI   1(R9),C'E'                                               00019700
         BNE   MAINPRSC                                                 00019800
         OI    W#FLAG2,W#FL2LGE                                         00019900
         LA    R9,3(,R9)                                                00020000
         SH    R2,=H'+3'                                                00020100
         B     MAINPRSC                                                 00020200
MAINPRDB DS    0H                                                       00020300
         OI    W#FLAG2,W#FL2DBG                                         00020400
         LA    R9,5(,R9)                                                00020500
         SH    R2,=H'+5'                                                00020600
         B     MAINPRSC                                                 00020700
MAINPRST DS    0H                                                       00020800
         OI    W#FLAG2,W#FL2STA                                         00020900
         LA    R9,6(,R9)                                                00021000
         SH    R2,=H'+6'                                                00021100
         B     MAINPRSC                                                 00021200
MAINPRRR DS    0H                                                       00021300
         OI    W#FLAG2,W#FL2ERR                                         00021400
         LA    R9,6(,R9)                                                00021500
         SH    R2,=H'+6'                                                00021600
         B     MAINPRSC                                                 00021700
MAINPRLI DS    0H                                                       00021800
         OI    W#FLAG2,W#FL2LST                                         00021900
         LA    R9,4(,R9)                                                00022000
         SH    R2,=H'+4'                                                00022100
         B     MAINPRSC                                                 00022200
MAINPRSK DS    0H                                                       00022300
         OI    W#FLAG2,W#FLG2SK                                         00022400
         LA    R9,5(,R9)                                                00022500
         SH    R2,=H'+5'                                                00022600
         LA    R1,W$SKP                                                 00022700
         LA    R0,W$SKPZ                                                00022800
         MVI   W$SKP,C' '                                               00022900
         MVC   W$SKP(W$SKPZ-W$SKP-1),W$SKP                              00023000
MAINPRSL DS    0H                                                       00023100
         CH    R2,=H'+5'                                                00023200
         BL    MAINPRER                                                 00023300
         CLI   0(R9),C'0'                                               00023400
         BL    MAINPRER                                                 00023500
         CLI   1(R9),C'0'                                               00023600
         BL    MAINPRER                                                 00023700
         CLI   2(R9),C'0'                                               00023800
         BL    MAINPRER                                                 00023900
         CLI   3(R9),C'0'                                               00024000
         BL    MAINPRER                                                 00024100
         CR    R1,R0                                                    00024200
         BNL   MAINPRER                                                 00024300
         MVC   0(4,R1),0(R9)                                            00024400
         LA    R1,4(,R1)                                                00024500
         LA    R9,4(,R9)                                                00024600
         SH    R2,=H'+4'                                                00024700
         CLI   0(R9),C','                                               00024800
         BNE   MAINPRSM                                                 00024900
         LA    R9,1(,R9)                                                00025000
         SH    R2,=H'+1'                                                00025100
         B     MAINPRSL                                                 00025200
MAINPRSM DS    0H                                                       00025300
         CLI   0(R9),C')'                                               00025400
         BNE   MAINPRER                                                 00025500
         LA    R9,1(,R9)                                                00025600
         SH    R2,=H'+1'                                                00025700
         B     MAINPRSC                                                 00025800
MAINPRZ  DS    0H                                                       00025900
         BAL   R14,MAINPRT                                           xx 00025910
         TM    W#FLAG2,W#FL2LG                                          00026000
         BNO   MAINPRZ1                                                 00026100
         MVC   W#LINE+1(33),=C'Begin LinkEdit Listing processing'       00026200
         BAL   R14,MAINPRT                                              00026300
MAINPRZ1 DS    0H                                                       00026400
         TM    W#FLAG2,W#FL2STA                                         00026500
         BO    MAINLINE                                                 00026600
         OPEN  (OUTDCB,(OUTPUT))                                        00026700
         TM    OUTDCB+48,16                                             00026800
         BZ    MAINQUIT                                                 00026900
         LA    R9,W$BUF                                                 00027000
MAINLINE DS    0H                                                       00027100
         BAL   R14,MAINRD                                               00027200
         CLC   =C' F64-LEVEL LINKAGE EDITOR',W$REC+1                    00027300
         BNE   MAINLINE                                                 00027400
MAINL00A DS    0H                                                       00027500
         TM    W#FLAG2,W#FL2DBG                                         00027600
         BNO   MAINLND1                                                 00027700
         MVC   W#LINE+2(7),=C'**Begin'                                  00027800
         BAL   R14,MAINPRT                                              00027900
MAINLND1 DS    0H                                                       00028000
         ZAP   W$CSCT,=P'+0'                                            00028100
         MVI   W$LKSEV,C'I'                                             00028200
         MVC   W$LKMOD(8),=CL8' '                                       00028300
         LA    R0,W#LINE+60                                             00028400
         ST    R0,W$MSGPTR                                              00028500
         MVC   W$SAVOPT,W$REC                                           00028600
MAINL000 DS    0H                                                       00028700
         BAL   R14,MAINWR                                               00028800
         BAL   R14,MAINRD                                               00028900
         CLC   =C'****',W$REC+1                                         00029000
         BNE   MAINL000                                                 00029100
         CLC   =C'DOES NOT EXIST ',W$REC+15                             00029200
         BE    MAINL005                                                 00029300
         CLC   =C'NOW REPLACED IN DATA SET',W$REC+15                    00029400
         BNE   MAINL000                                                 00029500
MAINL005 DS    0H                                                       00029600
         TM    W#FLAG2,W#FL2DBG                                         00029700
         BNO   MAINLND3                                                 00029800
         MVC   W#LINE+2(7),=C'**Found'                                  00029900
         MVC   W#LINE+11(8),W$REC+5                                     00030000
         BAL   R14,MAINPRT                                              00030100
MAINLND3 DS    0H                                                       00030200
         MVC   W$LKMOD(8),W$REC+5                                       00030300
         AP    W$MODCT,=P'+1'                                           00030400
MAINL010 DS    0H                                                       00030500
         BAL   R14,MAINWR                                               00030600
         BAL   R14,MAINRD                                               00030700
         CLC   =C'IEW0000',W$REC+1                                      00030800
         BE    MAINL050                                                 00030900
         CLC   =C' F64-LEVEL LINKAGE EDITOR',W$REC+1                    00031000
         BE    MAINL045                                                 00031100
         CLC   =C'   IEW',W$REC+1                                       00031200
         BNE   MAINL010                                                 00031300
         CLI   W$REC+7,C'0'                                             00031400
         BL    MAINL010                                                 00031500
         CLI   W$REC+8,C'0'                                             00031600
         BL    MAINL010                                                 00031700
         CLI   W$REC+9,C'0'                                             00031800
         BL    MAINL010                                                 00031900
         CLI   W$REC+10,C'0'                                            00032000
         BL    MAINL010                                                 00032100
         CLC   =C' WARNING - ',W$REC+11                                 00032200
         BE    MAINL020                                                 00032300
         CLC   =C' ERROR - ',W$REC+11                                   00032400
         BE    MAINL040                                                 00032500
         B     MAINMSE                                                  00032600
MAINL020 DS    0H                                                       00032700
         CLI   W$LKSEV,C'I'                                             00032800
         BNE   MAINL030                                                 00032900
         MVI   W$LKSEV,C'W'                                             00033000
MAINL030 DS    0H                                                       00033100
         L     R1,W#WMSGA                                               00033200
         L     R0,=A(W#WMSGND)                                          00033300
         BAL   R14,LINKMSG                                              00033400
         B     MAINL010                                                 00033500
MAINL040 DS    0H                                                       00033600
         MVI   W$LKSEV,C'E'                                             00033700
         L     R1,W#EMSGA                                               00033800
         L     R0,=A(W#EMSGND)                                          00033900
         BAL   R14,LINKMSG                                              00034000
         B     MAINL010                                                 00034100
MAINL045 DS    0H                                                       00034200
         MVC   W$SAVOPT,W$REC                                           00034300
MAINL050 DS    0H                                                       00034400
         TM    W#FLAG2,W#FL2DBG                                         00034500
         BNO   MAINLND2                                                 00034600
         MVC   W#LINE+2(5),=C'**End'                                    00034700
         BAL   R14,MAINPRT                                              00034800
MAINLND2 DS    0H                                                       00034900
         CLI   W$LKSEV,C'I'                                             00035000
         BE    MAINL080                                                 00035100
         CLI   W$LKSEV,C'W'                                             00035200
         BE    MAINL060                                                 00035300
         CLI   W$LKSEV,C'E'                                             00035400
         BE    MAINL070                                                 00035500
         AP    W$XCT,=P'+1'                                             00035600
         B     MAINL080                                                 00035700
MAINL060 DS    0H                                                       00035800
         AP    W$WCT,=P'+1'                                             00035900
         B     MAINL080                                                 00036000
MAINL070 DS    0H                                                       00036100
         AP    W$ECT,=P'+1'                                             00036200
MAINL080 DS    0H                                                       00036300
         TM    W#FLAG2,W#FL2LG                                          00036400
         BNO   MAINL150                                                 00036500
         MVC   W#LINE+2(15),=C'Load Module--->'                         00036600
         MVC   W#LINE+17(8),W$LKMOD                                     00036700
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00036800
         ED    W#LINE+30(12),W$CSCT                                     00036900
         MVC   W#LINE+43(3),=C'RC='                                     00037000
         MVC   W#LINE+46(1),W$LKSEV                                     00037100
         NI    W#FLAG3,255-W#FLG3SE                                     00037200
         TM    W#FLAG2,W#FL2ERR                                         00037300
         BNO   MAINL090                                                 00037400
         CLI   W$LKSEV,C'E'                                             00037500
         BNE   MAINL130                                                 00037600
         MVC   W#LINE+50(8),=C'Selected'                                00037700
         OI    W#FLAG3,W#FLG3SE                                         00037800
         B     MAINL130                                                 00037900
MAINL090 DS    0H                                                       00038000
         TM    W#FLAG2,W#FL2LGW                                         00038100
         BNO   MAINL110                                                 00038200
         CLI   W$LKSEV,C'W'                                             00038300
         BE    MAINL100                                                 00038400
         CLI   W$LKSEV,C'E'                                             00038500
         BNE   MAINL130                                                 00038600
MAINL100 DS    0H                                                       00038700
         MVC   W#LINE+50(8),=C'Selected'                                00038800
         OI    W#FLAG3,W#FLG3SE                                         00038900
         B     MAINL130                                                 00039000
MAINL110 DS    0H                                                       00039100
         TM    W#FLAG2,W#FL2LGE                                         00039200
         BNO   MAINL120                                                 00039300
         CLI   W$LKSEV,C'E'                                             00039400
         BNE   MAINL130                                                 00039500
         MVC   W#LINE+50(8),=C'Selected'                                00039600
         OI    W#FLAG3,W#FLG3SE                                         00039700
         B     MAINL130                                                 00039800
MAINL120 DS    0H                                                       00039900
         MVC   W#LINE+50(8),=C'Selected'                                00040000
         OI    W#FLAG3,W#FLG3SE                                         00040100
MAINL130 DS    0H                                                       00040200
         TM    W#FLAG2,W#FL2STA                                         00040300
         BNO   MAINL140                                                 00040400
         TM    W#FLAG3,W#FLG3SE                                         00040500
         BNO   MAINL150                                                 00040600
         MVC   W#LINE+50(8),=C'        '                                00040700
         BAL   R14,MAINPRT                                              00040800
         B     MAINL150                                                 00040900
MAINL140 DS    0H                                                       00041000
         BAL   R14,MAINPRT                                              00041100
MAINL150 DS    0H                                                       00041200
         TM    W#FLAG2,W#FL2STA                                         00041300
         BNE   MAINL170                                                 00041400
         C     R9,=A(W$BUF)                                             00041500
         BE    MAINL160                                                 00041600
         LR    R0,R9                                                    00041700
         S     R0,=A(W$BUF)                                             00041800
         LH    R2,OUTDCB+62                                             00041900
         STH   R0,OUTDCB+62                                             00042000
         WRITE OUTDECB1,SF,OUTDCB,W$BUF                                 00042100
         CHECK OUTDECB1                                                 00042200
         STH   R2,OUTDCB+62                                             00042300
         LA    R9,W$BUF                                                 00042400
MAINL160 DS    0H                                                       00042500
         BAL   R14,MAINST                                               00042600
MAINL170 DS    0H                                                       00042700
         CLC   =C' F64-LEVEL LINKAGE EDITOR',W$REC+1                    00042800
         BE    MAINL00A                                                 00042900
         MVC   W$SAVREC,W$REC                                           00043000
         MVC   W$REC,W$SAVOPT                                           00043100
         BAL   R14,MAINWR                                               00043200
         MVC   W$REC,W$SAVREC                                           00043300
         B     MAINL00A                                                 00043400
*                                                                       00043500
*                                                                       00043600
*                                                                       00043700
MAINEOF  DS    0H                                                       00043800
         BAL   R14,MAINST                                               00043900
MAINE000 DS    0H                                                       00044000
         CLOSE (SYSIN)                                                  00044100
         FREEPOOL SYSIN                                                 00044200
MAINE010 DS    0H                                                       00044300
         TM    W#FLAG2,W#FL2STA                                         00044400
         BO    MAINE020                                                 00044500
         CLOSE (OUTDCB)                                                 00044600
MAINE020 DS    0H                                                       00044700
         BAL   R14,MAINPRT                                              00044800
         L     R2,W#WMSGA                                               00044900
         L     R3,=A(W#WMSGND)                                          00045000
MAINE030 DS    0H                                                       00045100
         CLI   0(R2),0                                                  00045200
         BE    MAINE040                                                 00045300
         MVC   W#LINE+14(8),=C'IEWXXXX '                                00045400
         MVC   W#LINE+17(4),0(R2)                                       00045500
         MVC   W#LINE+23(100),4(R2)                                     00045600
         BAL   R14,MAINPRT                                              00045700
         LA    R2,L'W#WMSG(,R2)                                         00045800
         CR    R2,R3                                                    00045900
         BL    MAINE030                                                 00046000
MAINE040 DS    0H                                                       00046100
         MVC   W#LINE+3(18),=C'Link error level W'                      00046200
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00046300
         ED    W#LINE+30(12),W$WCT                                      00046400
         BAL   R14,MAINPRT                                              00046500
         L     R2,W#EMSGA                                               00046600
         L     R3,=A(W#EMSGND)                                          00046700
MAINE050 DS    0H                                                       00046800
         CLI   0(R2),0                                                  00046900
         BE    MAINE060                                                 00047000
         MVC   W#LINE+14(8),=C'IEWXXXX '                                00047100
         MVC   W#LINE+17(4),0(R2)                                       00047200
         MVC   W#LINE+23(100),4(R2)                                     00047300
         BAL   R14,MAINPRT                                              00047400
         LA    R2,L'W#EMSG(,R2)                                         00047500
         CR    R2,R3                                                    00047600
         BL    MAINE050                                                 00047700
MAINE060 DS    0H                                                       00047800
         MVC   W#LINE+3(18),=C'Link error level E'                      00047900
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00048000
         ED    W#LINE+30(12),W$ECT                                      00048100
         BAL   R14,MAINPRT                                              00048200
         CP    W$XCT,=P'+0'                                             00048300
         BE    MAINE070                                                 00048400
         MVC   W#LINE+3(17),=C'Link error level ?'                      00048500
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00048600
         ED    W#LINE+30(12),W$XCT                                      00048700
         BAL   R14,MAINPRT                                              00048800
MAINE070 DS    0H                                                       00048900
         BAL   R14,MAINPRT                                              00049000
         MVC   W#LINE+2(16),=C'Modules detected'                        00049100
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00049200
         ED    W#LINE+30(12),W$MODCT                                    00049300
         BAL   R14,MAINPRT                                              00049400
         MVC   W#LINE+2(13),=C'Print records'                           00049500
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00049600
         ED    W#LINE+30(12),W#INCT                                     00049700
         BAL   R14,MAINPRT                                              00049800
         MVC   W#LINE+2(21),=C'LinkEdit list records'                   00049900
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00050000
         ED    W#LINE+30(12),W$OTCT                                     00050100
         BAL   R14,MAINPRT                                              00050200
         CP    W$DUPCT,=P'+0'                                           00050300
         BE    MAINE080                                                 00050400
         MVC   W#LINE+2(22),=C'Duplicate list members'                  00050500
         MVC   W#LINE+30(12),=XL12'402020206B2020206B202120'            00050600
         ED    W#LINE+30(12),W$DUPCT                                    00050700
         BAL   R14,MAINPRT                                              00050800
MAINE080 DS    0H                                                       00050900
         MVC   W#LINE+1(20),=C'End processing RC=X'''                   00051000
         UNPK  W#LINE+21(9),W#RC(5)                                     00051100
         TR    W#LINE+21(8),W#HX2CHR-240                                00051200
         MVI   W#LINE+29,C''''                                          00051300
         BAL   R14,MAINPRT                                              00051400
         CLOSE (W#PRTDD)                                                00051500
         FREEPOOL W#PRTDD                                               00051600
         L     R2,W#RC                                                  00051700
         L     R13,4(,R13)                                              00051800
         L     R14,12(,R13)                                             00051900
         LR    R15,R2                                                   00052000
         LM    R0,R12,20(R13)                                           00052100
         BR    R14                                                      00052200
MAINPRER DS    0H                                                       00052300
         S     R9,W#PARMAD                                              00052400
         LA    R9,W#LINE+4(R9)                                          00052500
         C     R9,=A(W#LINE+L'W#LINE-1)                                 00052600
         BNH   MAINP131                                                 00052700
         MVI   W#LINE+5,C'?'                                            00052800
         B     MAINP133                                                 00052900
MAINP131 DS    0H                                                       00053000
         MVI   0(R9),C'*'                                               00053100
MAINP133 DS    0H                                                       00053200
         BAL   R14,MAINPRT                                              00053300
         MVC   W#LINE+1(33),=C'PARM= contained invalid parameter'       00053400
         B     MAINQUIT                                                 00053500
MAINMSE  DS    0H                                                       00053600
         MVC   W#LINE+1(23),=C'Unknown message level -'                 00053700
         MVC   W#LINE+25(100),W$REC+1                                   00053800
         B     MAINQUIT                                                 00053900
*                                                                       00054000
*                                                                       00054100
*                                                                       00054200
MAINQUIT DS    0H                                                       00054300
         BAL   R14,MAINPRT                                              00054400
         CLC   W#RC,=A(8)                                               00054500
         BNL   MAINE010                                                 00054600
         MVC   W#RC,=A(8)                                               00054700
         B     MAINE010                                                 00054800
*                                                                       00054900
*                                                                       00055000
*                                                                       00055100
LINKMSG  DS    0H                                                       00055200
         ST    R14,W$MSG14                                              00055300
*                                                                       00055400
         TM    W#FLAG2,W#FLG2SK                                         00055500
         BNO   LINKMSGD                                                 00055600
         LA    R14,W$SKP                                                00055700
         LA    R15,W$SKPZ                                               00055800
LINKMSGA DS    0H                                                       00055900
         CLC   0(4,R14),W$REC+7                                         00056000
         BNE   LINKMSGC                                                 00056100
         CLC   =A(W#LINE+60),W$MSGPTR                                   00056200
         BNE   LINKMSGB                                                 00056300
         MVI   W$LKSEV,C'I'                                             00056400
LINKMSGB DS    0H                                                       00056500
         B     LINKMSGX                                                 00056600
LINKMSGC DS    0H                                                       00056700
         LA    R14,4(,R14)                                              00056800
         CR    R14,R15                                                  00056900
         BL    LINKMSGA                                                 00057000
LINKMSGD DS    0H                                                       00057100
*                                                                       00057200
LINKM010 DS    0H                                                       00057300
         CLI   0(R1),0                                                  00057400
         BNE   LINKM020                                                 00057500
         MVC   0(4,R1),W$REC+7                                          00057600
         MVC   4(100,R1),W$REC+12                                       00057700
         B     LINKM030                                                 00057800
LINKM020 DS    0H                                                       00057900
         CLC   0(4,R1),W$REC+7                                          00058000
         BE    LINKM030                                                 00058100
         LA    R1,L'W#EMSG(,R1)                                         00058200
         CR    R1,R0                                                    00058300
         BL    LINKM010                                                 00058400
LINKM030 DS    0H                                                       00058500
*                                                                       00058600
         L     R1,W$MSGPTR                                              00058700
         LA    R0,W#LINE+L'W#LINE-6                                     00058800
         CR    R1,R0                                                    00058900
         BNL   LINKM070                                                 00059000
         LA    R15,W#LINE+60                                            00059100
         B     LINKM050                                                 00059200
LINKM040 DS    0H                                                       00059300
         CLC   W$REC+7(4),0(R15)                                        00059400
         BE    LINKM060                                                 00059500
         LA    R15,6(,R15)                                              00059600
LINKM050 DS    0H                                                       00059700
         CR    R15,R1                                                   00059800
         BNH   LINKM040                                                 00059900
LINKM060 DS    0H                                                       00060000
         CLI   0(R15),C' '                                              00060100
         BNE   LINKM070                                                 00060200
         MVC   0(4,R1),W$REC+7                                          00060300
         LA    R1,6(,R1)                                                00060400
         ST    R1,W$MSGPTR                                              00060500
LINKM070 DS    0H                                                       00060600
*                                                                       00060700
         LA    R15,0                                                    00060800
         TM    W#FLAG2,W#FL2LST                                         00060900
         BNO   LINKMSGX                                                 00061000
         TM    W#FLAG2,W#FL2LGW                                         00061100
         BNO   LINKM100                                                 00061200
         CLI   W$LKSEV,C'W'                                             00061300
         BE    LINKM080                                                 00061400
         CLI   W$LKSEV,C'E'                                             00061500
         BNE   LINKM090                                                 00061600
LINKM080 DS    0H                                                       00061700
         LA    R15,4                                                    00061800
LINKM090 DS    0H                                                       00061900
         B     LINKM110                                                 00062000
LINKM100 DS    0H                                                       00062100
         TM    W#FLAG2,W#FL2LGE                                         00062200
         BNO   LINKM110                                                 00062300
         CLI   W$LKSEV,C'E'                                             00062400
         BNE   LINKM110                                                 00062500
         LA    R15,4                                                    00062600
LINKM110 DS    0H                                                       00062700
         LTR   R15,R15                                                  00062800
         BE    LINKMSGX                                                 00062900
         MVC   W#SAVLIN,W#LINE                                          00063000
         MVI   W#LINE,C' '                                              00063100
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              00063200
         MVC   W#LINE+10(120),W$REC+1                                   00063300
         BAL   R14,MAINPRT                                              00063400
         MVC   W#LINE,W#SAVLIN                                          00063500
LINKMSGX DS    0H                                                       00063600
         L     R14,W$MSG14                                              00063700
         BR    R14                                                      00063800
*                                                                       00063900
*                                                                       00064000
*                                                                       00064100
MAINPRT  DS    0H                                                       00064200
         ST    R14,W$PRT14                                              00064300
         L     R15,=A(PRINT)                                            00064400
         BALR  R14,R15                                                  00064500
         L     R14,W$PRT14                                              00064600
         BR    R14                                                      00064700
*                                                                       00064800
*                                                                       00064900
*                                                                       00065000
MAINRD   DS    0H                                                       00065100
         ST    R14,W$RD14                                               00065200
         GET   SYSIN,W$REC                                              00065300
         AP    W#INCT,=P'+1'                                            00065400
         TM    W#FLAG2,W#FL2DBG                                         00065500
         BNO   MAINRD1                                                  00065600
         MVC   W#LINE+2(7),=C'Read-->'                                  00065700
         MVC   W#LINE+9(80),W$REC+1                                     00065800
         BAL   R14,MAINPRT                                              00065900
MAINRD1  DS    0H                                                       00066000
         L     R14,W$RD14                                               00066100
         BR    R14                                                      00066200
*                                                                       00066300
*                                                                       00066400
*                                                                       00066500
MAINWR   DS    0H                                                       00066600
         ST    R14,W$WR14                                               00066700
         AP    W$OTCT,=P'+1'                                            00066800
         AP    W$CSCT,=P'+1'                                            00066900
         TM    W#FLAG2,W#FL2STA                                         00067000
         BO    MAINWR1                                                  00067100
         MVC   0(121,R9),W$REC                                          00067200
         MVI   0(R9),C' '                                               00067300
         LA    R9,121(,R9)                                              00067400
         C     R9,=A(W$BUFND)                                           00067500
         BL    MAINWR1                                                  00067600
         WRITE OUTDECB2,SF,OUTDCB,W$BUF                                 00067700
         CHECK OUTDECB2                                                 00067800
         LA    R9,W$BUF                                                 00067900
MAINWR1  DS    0H                                                       00068000
         L     R14,W$WR14                                               00068100
         BR    R14                                                      00068200
*                                                                       00068300
*                                                                       00068400
*                                                                       00068500
MAINST   DS    0H                                                       00068600
         ST    R14,W$ST14                                               00068700
         MVC   W$STOWMB,W$LKMOD                                         00068800
         TM    W#FLAG3,W#FLG3SE                                         00068900
         BO    MAINST00                                                 00069000
         MVC   W$STOWMB,=C'TEMPNAME'                                    00069100
MAINST00 DS    0H                                                       00069200
         STOW  OUTDCB,W$STOWLS,R                                        00069300
         CH    R15,=H'+8'   Member didn't exist                         00069400
         BE    MAINST10                                                 00069500
         CH    R15,=H'+0'                                               00069600
         BNE   MAINST20                                                 00069700
         CLC   W$STOWMB,=C'TEMPNAME' Replaced TEMPNAME                  00069800
         BE    MAINST10                                                 00069900
         AP    W$DUPCT,=P'+1'                                           00070000
         MVC   W#LINE+17(25),=C'Duplicate (last one kept)'              00070100
         BAL   R14,MAINPRT                                              00070200
MAINST10 DS    0H                                                       00070300
         TM    W#FLAG2,W#FL2DBG                                         00070400
         BNO   MAINLND4                                                 00070500
         MVC   W#LINE+2(6),=C'**STOW'                                   00070600
         MVC   W#LINE+11(8),W$STOWMB                                    00070700
         BAL   R14,MAINPRT                                              00070800
MAINLND4 DS    0H                                                       00070900
         L     R14,W$ST14                                               00071000
         BR    R14                                                      00071100
*                                                                       00071200
*                                                                       00071300
*                                                                       00071400
MAINST20 DS    0H                                                       00071500
         MVC   W#LINE+1(15),=C'STOW failed for'                         00071600
         MVC   W#LINE+17(8),W$STOWMB                                    00071700
         MVC   W#LINE+26(6),=C'R15=X'''                                 00071800
         ST    R15,W#DWORD                                              00071900
         UNPK  W#LINE+32(9),W#DWORD(5)                                  00072000
         TR    W#LINE+32(8),W#HX2CHR-240                                00072100
         MVI   W#LINE+40,C''''                                          00072200
         MVC   W#LINE+42(5),=C'R0=X'''                                  00072300
         ST    R15,W#DWORD                                              00072400
         UNPK  W#LINE+47(9),W#DWORD(5)                                  00072500
         TR    W#LINE+47(8),W#HX2CHR-240                                00072600
         MVI   W#LINE+55,C''''                                          00072700
         BAL   R14,MAINPRT                                              00072800
         CLC   W#RC,=A(8)                                               00072900
         BNL   MAINE000                                                 00073000
         MVC   W#RC,=A(8)                                               00073100
         B     MAINE000                                                 00073200
*                                                                       00073300
*                                                                       00073400
*                                                                       00073500
         LTORG ,                                                        00073600
*                                                                       00073700
JULWRK2  DC    A(0)                                                     00073800
JULWRK4  DC    P'+365'                                                  00073900
         DC    P'+01'                                                   00074000
         DC    P'+31'                                                   00074100
         DC    P'+30'                                                   00074200
         DC    P'+31'                                                   00074300
         DC    P'+30'                                                   00074400
         DC    P'+31'                                                   00074500
         DC    P'+31'                                                   00074600
         DC    P'+30'                                                   00074700
         DC    P'+31'                                                   00074800
         DC    P'+30'                                                   00074900
         DC    P'+31'                                                   00075000
JULWRK6  DC    P'+28'                                                   00075100
JULTBL1  DC    P'+31'                                                   00075200
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  00075300
SYSIN    DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=MAINEOF             00075400
OUTDCB   DCB   DDNAME=LIST,DSORG=PO,MACRF=W,                           *00075500
               RECFM=FBA,LRECL=121,BLKSIZE=231*121 27951 (3390 1/2 TRK) 00075600
W$STOWLS DC    0A(0)                   List of member names for STOW    00075700
W$STOWMB DC    CL8' '                  Name of member                   00075800
         DC    XL3'0'                  TTR of first record              00075900
*                                      (created by STOW)                00076000
         DC    X'00'                   C byte, no user TTRNs,           00076100
*                                      no user data                     00076200
*                                                                       00076300
W$PRT14  DC    A(0)                                                     00076400
W$RD14   DC    A(0)                                                     00076500
W$WR14   DC    A(0)                                                     00076600
W$ST14   DC    A(0)                                                     00076700
W$MSG14  DC    A(0)                                                     00076800
W$MSGPTR DC    A(0)                                                     00076900
W#INCT   DC    PL5'+0'                                                  00077000
W$OTCT   DC    PL5'+0'                                                  00077100
W$CSCT   DC    PL5'+0'                                                  00077200
W$MODCT  DC    PL5'+0'                                                  00077300
W$WCT    DC    PL5'+0'                                                  00077400
W$ECT    DC    PL5'+0'                                                  00077500
W$XCT    DC    PL5'+0'                                                  00077600
W$DUPCT  DC    PL5'+0'                                                  00077700
W$LKSEV  DC    C'I'                                                     00077800
W$LKMOD  DC    CL8' '                                                   00077900
W$REC    DC    CL121' '                                                 00078000
W$SAVREC DC    CL121' '                                                 00078100
W$SAVOPT DC    CL121' '                                                 00078200
W$SKP    DC    20CL4' '                                                 00078300
W$SKPZ   EQU   *                                                        00078400
W$BUF    DS    231CL121                                                 00078500
W$BUFND  EQU   *                                                        00078600
*                                                                       00078700
*        Common area                                                    00078800
*                                                                       00078900
W#       CSECT                                                          00079000
W#SA     DC    18A(0)                                                   00079100
W#SA1    DC    18A(0)                                                   00079200
W#SA2    DC    18A(0)                                                   00079300
W#SA3    DC    18A(0)                                                   00079400
W#SA4    DC    18A(0)                                                   00079500
W#SA5    DC    18A(0)                                                   00079600
W#SA6    DC    18A(0)                                                   00079700
W#SA7    DC    18A(0)                                                   00079800
W#DWORD  DC    D'+0'                                                    00079900
W#RC     DC    A(0)                                                     00080000
W#CURDTE DC    A(0)                                                     00080100
W#TMWK4  DC    X'402021204B20204B20204B2020'                            00080200
W#HX2CHR DC    C'0123456789ABCDEF'                                      00080300
W#PARMAD DC    A(0)                                                     00080400
W#FLAG2  DC    AL1(0)                                                   00080500
W#FL2LG  EQU   X'80'                                                    00080600
W#FL2DBG EQU   X'40'                                                    00080700
W#FL2STA EQU   X'20'                                                    00080800
W#FL2ERR EQU   X'10'                                                    00080900
W#FL2LGW EQU   X'08'                                                    00081000
W#FL2LGE EQU   X'04'                                                    00081100
W#FLG2SK EQU   X'02'                                                    00081200
W#FL2LST EQU   X'01'                                                    00081300
W#FLAG3  DC    AL1(0)                                                   00081400
W#FLG3SE EQU   X'01'                                                    00081500
W#LNCT   DC    PL2'+99'                                                 00081600
W#PGCT   DC    PL2'+0'                                                  00081700
W#LINE   DC    CL133' '                                                 00081800
W#SAVLIN DC    CL133' '                                                 00081900
W#HD1    DC    CL133'1'                                                 00082000
         ORG   W#HD1+1                                                  00082100
W#HD1DTE DC    C'            '                                          00082200
         DC    C' '                                                     00082300
W#HD1TOD DC    C'HH:MM:SS'                                              00082400
         DC    C'  '                                                    00082500
W#HD1RPT DC    C'                '                                      00082600
         ORG   W#HD1+66-(30/2)                                          00082700
W#HD1TTL DC    C'SMP LinkEdit Listing Extractor'                        00082800
         ORG   W#HD1+L'W#HD1-4-4                                        00082900
W#HD1PG  DC    C'Page'                                                  00083000
W#HD1PGC DC    C' 123'                                                  00083100
W#HD2    DC    CL133' '                                                 00083200
W#PRTDD  DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X00083300
               RECFM=FBA,LRECL=133                                      00083400
W#WMSGA  DC    A(W#WMSG)                                                00083500
W#EMSGA  DC    A(W#EMSG)                                                00083600
W#WMSG   DC    20XL104'0'                                               00083700
W#WMSGND EQU   *                                                        00083800
W#EMSG   DC    20XL104'0'                                               00083900
W#EMSGND EQU   *                                                        00084000
         DC    CL8'<-----W#'                                            00084100
         DROP  ,                                                        00084200
**********************************************************************  00084300
*                                                                       00084400
*            WRITE PRINT LINE                                           00084500
*                                                                       00084600
**********************************************************************  00084700
PRINT    CSECT                                                          00084800
         USING PRINT,R15                                                00084900
         B     PRINTBGN                                                 00085000
         DROP  R15                                                      00085100
         DC    AL1(L'PRINTID)                                           00085200
PRINTID  DC    C'PRINT &SYSDATE &SYSTIME'                               00085300
PRINTBGN DS    0H                                                       00085400
         STM   R14,R12,12(R13)         SAVE CALLERS REGS                00085500
         LR    R12,R15                 TRANSFER BASE REG                00085600
         USING PRINT,R12                                                00085700
         USING W#,R10                                                   00085800
         LA    R14,18*4(,R13)                                           00085900
         ST    R13,4(,R14)                                              00086000
         ST    R14,8(,R13)                                              00086100
         LR    R13,R14                                                  00086200
         CP    W#LNCT,=P'+60'          END OF PAGE                      00086300
         BL    PRINTCHK                 NO, CHECK IF LINE FIT IN PAGE   00086400
PRINTHDS DS    0H                                                       00086500
         AP    W#PGCT,=P'+1'           COUNT PAGES                      00086600
         MVC   W#HD1PGC,=X'40202120'   PAGE COUNT MASK                  00086700
         ED    W#HD1PGC,W#PGCT         EDIT PAGE COUNT                  00086800
         PUT   W#PRTDD,W#HD1           PRINT HEADING 1                  00086900
         PUT   W#PRTDD,W#HD2           PRINT HEADING 1                  00087000
         ZAP   W#LNCT,=P'+2'           INIT LINE COUNT                  00087100
         MVI   W#LINE,C'0'             SKIP AFTER HEADING               00087200
PRINTCHK DS    0H                                                       00087300
         CLI   W#LINE,C'+'             OVERPRINT ?                      00087400
         BE    PRINTLN                  YES, DON'T COUNT                00087500
         CLI   W#LINE,C'1'             NEW LINE ?                       00087600
         BE    PRINTHDS                 YES, PRINT HEADER               00087700
         CLI   W#LINE,C' '             WRITE AFTER ADVANCING 1?         00087800
         BE    PRINTLN1                 YES, GO CHECK IF FIT            00087900
         CLI   W#LINE,C'0'             WRITE AFTER ADVANCING 1?         00088000
         BE    PRINTLN2                 YES, GO CHECK IF FIT            00088100
         CLI   W#LINE,C'-'             WRITE AFTER ADVANCING 1?         00088200
         BE    PRINTLN3                 YES, GO CHECK IF FIT            00088300
         B     PRINTLN                 IGNORE ANY OTHER CTL CHARS       00088400
PRINTLN1 DS    0H                                                       00088500
         AP    W#LNCT,=P'+1'           ADD TO LINE COUNT                00088600
         B     PRINTVFY                GO SEE IF IT WILL FIT            00088700
PRINTLN2 DS    0H                                                       00088800
         AP    W#LNCT,=P'+2'           ADD TO LINE COUNT                00088900
         B     PRINTVFY                GO SEE IF IT WILL FIT            00089000
PRINTLN3 DS    0H                                                       00089100
         AP    W#LNCT,=P'+3'           ADD TO LINE COUNT                00089200
PRINTVFY DS    0H                                                       00089300
         CP    W#LNCT,=P'+60'          OVERFLOW ?                       00089400
         BH    PRINTHDS                 YES, FORCE HEADER               00089500
PRINTLN  DS    0H                                                       00089600
         CLC   =C'Begin ',W#LINE+1                                      00089700
         BE    PRINTLNT                                                 00089800
         CLC   =C'End ',W#LINE+1                                        00089900
         BNE   PRINTLNP                                                 00090000
PRINTLNT DS    0H                                                       00090100
         MVC   PRTSAV,W#LINE                                            00090200
         TIME  BIN                     GET CURRENT DATE AND TIME        00090300
         ST    R1,W#CURDTE             SAVE DATE                        00090400
         SRDL  R0,32                   GET DOUBLE WORD TIME             00090500
         D     R0,=F'+6000'            GET MINUTES                      00090600
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00090700
         SLR   R0,R0                   CLEAR                            00090800
         D     R0,=F'+60'              GET HOURS / MINS                 00090900
         MH    R0,=H'+10000'           GET MINUTES                      00091000
         AR    R15,R0                  ADD TO GET MM:SS.TH              00091100
         M     R0,=F'+1000000'         GET HOURS                        00091200
         AR    R1,R15                  GET HH:MM:SS.TH                  00091300
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              00091400
         MVC   W#TMWK4,=X'402120207A20207A20204B2020'                   00091500
         ED    W#TMWK4,W#DWORD+3       EDIT TIME                        00091600
         MVC   W#LINE+1(11),W#TMWK4+2  MOVE TIME                        00091700
         MVI   W#LINE+12,C' '                                           00091800
         MVC   W#LINE+13(132-12),PRTSAV+1                               00091900
PRINTLNP DS    0H                                                       00092000
         PUT   W#PRTDD,W#LINE          PRINT A LINE                     00092100
         MVI   W#LINE,C' '             CLEAR CONTROL CHARACTER          00092200
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              00092300
         L     R13,4(,R13)             POINT TO CALLERS SAVE            00092400
         L     R14,R12(,R13)           SET RETURN ADDRESS               00092500
         LA    R15,0                   SET RETURN CODE                  00092600
         LM    R14,12,12(R13)          RESTORE REGS                     00092700
         BR    R14                     RETURN TO CALLER                 00092800
         LTORG ,                                                        00092900
PRTSAV   DC    CL133' '                                                 00093000
*                                                                       00093100
*                                                                       00093200
*                                                                       00093300
R0       EQU   0                                                        00093400
R1       EQU   1                                                        00093500
R2       EQU   2                                                        00093600
R3       EQU   3                                                        00093700
R4       EQU   4                                                        00093800
R5       EQU   5                                                        00093900
R6       EQU   6                                                        00094000
R7       EQU   7                                                        00094100
R8       EQU   8                                                        00094200
R9       EQU   9                                                        00094300
R10      EQU   10                                                       00094400
R11      EQU   11                                                       00094500
R12      EQU   12                                                       00094600
R13      EQU   13                                                       00094700
R14      EQU   14                                                       00094800
R15      EQU   15                                                       00094900
         END   MVSLKD38                                                 00095000
