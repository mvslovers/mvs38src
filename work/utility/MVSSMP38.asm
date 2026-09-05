*********************************************************************** 00010000
*                                                                     * 00020000
* Module Name                                                         * 00030000
*    MVSSMP38                                                         * 00040000
*                                                                     * 00050000
* Attributes                                                          * 00060000
*    None                                                             * 00070000
*                                                                     * 00080000
* Author                                                              * 00090000
*    Dave Kreiss                                                      * 00100000
*                                                                     * 00110000
* Function                                                            * 00120000
*    Report any SMP problems.                                         * 00130000
*                                                                     * 00140000
* JCL                                                                 * 00150000
*    //GENLIST EXEC PGM=MVSSMP38,PARM='PARAMETERS'                    * 00160000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00170000
*    //SYSPRINT DD  SYSOUT=*                                          * 00180000
*    //SYSIN    DD  DSN=OUTPUT FROM APPLY/ACCEPT SMPOUT               * 00190000
*                                                                     * 00200000
* DD Statements                                                       * 00210000
*    STEPLIB       Load library conaining this module                 * 00220000
*    SYSPRINT      Contains various status information                * 00230000
*    SYSIN         Input data set containing output from a smp        * 00240000
*                  APPLY or ACCEPT run                                * 00250000
*                                                                     * 00260000
* Parameters                                                          * 00270000
*    All parameters are seperated by commas.                          * 00280000
*    LOG            Log any SMP process status.                       * 00290000
*    LOG(SYSMOD)    Log any SYSMOD processing status.                 * 00300000
*    LOG(ALL)       Log each print line read.                         * 00310000
*    ASMRC=         Max acceptable assembler return code.             * 00320000
*                   RC= two digit return code.                        * 00330000
*    CPYRC=         Max acceptable copy return code.                  * 00340000
*                   RC= two digit return code.                        * 00350000
*    LKDRC=         Max acceptable linkedit return code.              * 00360000
*                   RC= two digit return code.                        * 00370000
*    UPDRC=         Max acceptable update return code.                * 00380000
*                   RC= two digit return code.                        * 00390000
*    SMPRC=         Max acceptable SMP return code.                   * 00400000
*                   RC= two digit return code.                        * 00410000
*                                                                     * 00420000
* Return codes                                                        * 00430000
*    0              No SMP process had an error return code           * 00440000
*    4              SMP process had an error return code              * 00450000
*    8              Parameter error                                   * 00460000
*                                                                     * 00470000
* SAMPLE JCL                                                          * 00480000
*    //CHKSMP  EXEC PGM=MVSSMP38,PARM='LOG,SMPRC=04'                  * 00480100
*    //STEPLIB  DD  DSN=MVSSRC.BLD.UTILITY.LOAD,DISP=SHR              * 00500000
*    //SYSPRINT DD  SYSOUT=*                                          * 00510000
*    //SYSIN    DD  DSN=MVSSRC.BLD.APPLY.LISTING(EAS1102),DISP=SHR    * 00520000
*                                                                     * 00530000
**********************************************************************  00540000
*                                                                    *  00550000
* CHANGE LOG:                                                        *  00560000
*   DATE     AAA VV.VV DESCRIPTION                                   *  00570000
* 04/14/2018 DSK 01.01 Created                                       *  00580000
* 04/16/2018 DSK 01.02 Show key FUNCTION completion                  *  00590000
* 04/18/2018 DSK 01.03 PARM=LOG(SYSMOD) and PARM error               *  00600000
* 04/19/2018 DSK 01.04 Add SYSMOD to error message                   *  00610000
* 04/21/2018 DSK 01.05 Added counters                                *  00620000
* 04/22/2018 DSK 01.06 Other errors                                  *  00630000
* 08/12/2018 DSK 01.07 Update failed module name incorrect           *  00630100
* 07/07/2022 DSK 01.08 Count UPDATE error as SMP error               *  00630200
         LCLC   &VER                                                    00640000
&VER     SETC   '01.08'                                                 00640100
*                                                                    *  00660000
**********************************************************************  00670000
****************************************************************        00680000
*                                                              *        00690000
*   PROGRAM INITIALIZATION                                     *        00700000
*                                                              *        00710000
****************************************************************        00720000
MVSSMP38 CSECT                                                          00730000
         USING MVSSMP38,R15                                             00740000
         B     MAINBGN                                                  00750000
         DROP  R15                                                      00760000
         DC    AL1(L'MAINID)                                            00770000
MAINID   DC    C'MVSSMP38 - &VER &SYSDATE &SYSTIME'                     00780000
MAINBGN  DC    0H'+0'                                                   00790000
         STM   R14,R12,12(R13)                                          00800000
         LR    R12,R15                                                  00810000
         USING MVSSMP38,R12                                             00820000
         L     R10,=A(W#SA)                                             00830000
         USING W#SA,R10                                                 00840000
         ST    R13,4(,R10)                                              00850000
         ST    R10,8(,R13)                                              00860000
         LR    R13,R10                                                  00870000
         L     R2,0(,R1)                                                00880000
         ST    R2,W#PARMAD                                              00890000
         OPEN  (W#PRTDD,(OUTPUT),SYSIN,(INPUT))                         00900000
         TM    W#PRTDD+48,16                                            00910000
         BZ    MAINQUIT                                                 00920000
         TM    SYSIN+48,16                                              00930000
         BZ    MAINQUIT                                                 00940000
         TIME  BIN                     GET CURRENT DATE AND TIME        00950000
         ST    R1,W#CURDTE             SAVE DATE                        00960000
         SRDL  R0,32                   GET DOUBLE WORD TIME             00970000
         D     R0,=F'+6000'            GET MINUTES                      00980000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00990000
         SLR   R0,R0                   CLEAR                            01000000
         D     R0,=F'+60'              GET HOURS / MINS                 01010000
         MH    R0,=H'+10000'           GET MINUTES                      01020000
         AR    R15,R0                  ADD TO GET MM:SS.TH              01030000
         M     R0,=F'+1000000'         GET HOURS                        01040000
         AR    R1,R15                  GET HH:MM:SS.TH                  01050000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              01060000
         MVC   W#TMWK4,=X'402021207A20207A20204B2020'                   01070000
         ED    W#TMWK4,W#DWORD+3       EDIT TIME                        01080000
         MVC   W#HD1TOD(8),W#TMWK4+2   MOVE TIME                        01090000
         ZAP   JULWRK2,W#CURDTE+2(2)   GET JULIAN DATE                  01100000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    01110000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         01120000
         MVO   W#DWORD,W#CURDTE+1(1)   SIGN YEAR                        01130000
         DP    W#DWORD,=P'+4'          DIVIDE BY 4                      01140000
         CP    W#DWORD+7(1),=P'+0'     IS IT A LEAP YEAR ?              01150000
         BNZ   MAINJC2                  NO                              01160000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    01170000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         01180000
MAINJC2  DS    0H                                                       01190000
         LA    R1,JULTBL1              POINT TO JANUARY                 01200000
         SLR   R2,R2                   SET COUNTER                      01210000
MAINJC4  DS    0H                                                       01220000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              01230000
         BNP   MAINJC6                 IF EQUAL OR LESS THAN 0, BRANCH  01240000
         BCTR  R1,0                    POINT TO NEXT MONTH              01250000
         BCTR  R1,0                    POINT TO NEXT MONTH              01260000
         LA    R2,3(,R2)               UP INDEX                         01270000
         B     MAINJC4                 LOOP                             01280000
MAINJC6  DS    0H                                                       01290000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                01300000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    01310000
         MVC   W#HD1DTE(3),0(R2)       MOVE MONTH                       01320000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     01330000
         UNPK  W#HD1DTE+4(2),JULWRK2   GET DAYS                         01340000
         CLI   W#HD1DTE+4,C'0'         FIRST 9 DAYS ?                   01350000
         LA    R1,W#HD1DTE+6           SET POINTER                      01360000
         BNE   MAINJC7                  NO                              01370000
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 MOVE UNITS DIGIT                01380000
         BCTR  R1,0                    DROP POINTER                     01390000
MAINJC7  DS    0H                                                       01400000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  01410000
         TM    W#CURDTE,1              YEAR 2000?                       01420000
         BNO   MAINJC8                  NO, CONTINUE                    01430000
         MVC   2(2,R1),=C'20'          Y2K                              01440000
MAINJC8  DS    0H                                                       01450000
         UNPK  W#DWORD(3),W#CURDTE+1(2) UNPACK YEAR                     01460000
         MVC   4(2,R1),W#DWORD         GET YEAR                         01470000
         MVC   W#LINE+1(15),=C'Program version'                         01480000
         MVC   W#LINE+17(L'MAINID),MAINID                               01490000
         BAL   R14,MAINPRT                                              01500000
         L     R9,W#PARMAD                                              01510000
         MVC   W#LINE+1(5),=C'Parm='                                    01520000
         CLI   1(R9),0                                                  01530000
         BE    MAINPRPA                                                 01540000
         LH    R1,0(,R9)                                                01550000
         BCTR  R1,0                                                     01560000
         EX    R1,MAINPRMV                                              01570000
         B     MAINPRPA                                                 01580000
MAINPRMV MVC   W#LINE+6(0),2(R9)                                        01590000
MAINPRPA DS    0H                                                       01600000
         BAL   R14,MAINPRT                                              01610000
         LH    R2,0(,R9)                                                01620000
         LA    R9,2(,R9)                                                01630000
MAINPRSC DS    0H                                                       01640000
         LTR   R2,R2                                                    01650000
         BE    MAINPRZ                                                  01660000
         CLI   0(R9),C','                                               01670000
         BNE   MAINPRCK                                                 01680000
MAINPRCO DS    0H                                                       01690000
         LA    R9,1(,R9)                                                01700000
         BCTR  R2,0                                                     01710000
         B     MAINPRSC                                                 01720000
MAINPRCK DS    0H                                                       01730000
         CH    R2,=H'+3'                                                01740000
         BL    MAINPRER                                                 01750000
         CLC   =C'LOG',0(R9)                                            01760000
         BE    MAINPRLG                                                 01770000
         CH    R2,=H'+8'                                                01780000
         BL    MAINPRER                                                 01790000
         CLC   =C'ASMRC=',0(R9)                                         01800000
         BE    MAINPASM                                                 01810000
         CLC   =C'CPYRC=',0(R9)                                         01820000
         BE    MAINPCPY                                                 01830000
         CLC   =C'LKDRC=',0(R9)                                         01840000
         BE    MAINPLKD                                                 01850000
         CLC   =C'UPDRC=',0(R9)                                         01860000
         BE    MAINPUPD                                                 01870000
         CLC   =C'SMPRC=',0(R9)                                         01880000
         BE    MAINPSMP                                                 01890000
         B     MAINPRER                                                 01900000
MAINPRLG DS    0H                                                       01910000
         LA    R9,3(,R9)                                                01920000
         SH    R2,=H'+3'                                                01930000
         CH    R2,=H'+5'                                                01940000
         BL    MAINPRL                                                  01950000
         CLI   0(R9),C','                                               01960000
         BE    MAINPRLS                                                 01970000
         CLC   =C'(ALL)',0(R9)                                          01980000
         BNE   MAINPRLS                                                 01990000
         OI    W#FLAG,W#FLGLA                                           02000000
         OI    W#FLAG,W#FLGLG                                           02010000
         OI    W#FLAG,W#FLGLS                                           02020000
         LA    R9,5(,R9)                                                02030000
         SH    R2,=H'+5'                                                02040000
         B     MAINPRSC                                                 02050000
MAINPRL  DS    0H                                                       02060000
         OI    W#FLAG,W#FLGLG                                           02070000
         B     MAINPRSC                                                 02080000
MAINPRLS DS    0H                                                       02090000
         CH    R2,=H'+8'                                                02100000
         BL    MAINPRSC                                                 02110000
         CLC   =C'(SYSMOD)',0(R9)                                       02120000
         BNE   MAINPRSC                                                 02130000
         OI    W#FLAG,W#FLGLS                                           02140000
         LA    R9,8(,R9)                                                02150000
         SH    R2,=H'+8'                                                02160000
         B     MAINPRSC                                                 02170000
MAINPASM DS    0H                                                       02180000
         LA    R15,ASMRC                                                02190000
         B     MAINPRC                                                  02200000
MAINPCPY DS    0H                                                       02210000
         LA    R15,CPYRC                                                02220000
         B     MAINPRC                                                  02230000
MAINPLKD DS    0H                                                       02240000
         LA    R15,LKDRC                                                02250000
         B     MAINPRC                                                  02260000
MAINPUPD DS    0H                                                       02270000
         LA    R15,UPDRC                                                02280000
         B     MAINPRC                                                  02290000
MAINPSMP DS    0H                                                       02300000
         LA    R15,SMPRC                                                02310000
MAINPRC  DS    0H                                                       02320000
         CLI   6(R9),C'0'                                               02330000
         BL    MAINPRER                                                 02340000
         CLI   7(R9),C'0'                                               02350000
         BL    MAINPRER                                                 02360000
         MVC   0(2,R15),6(R9)                                           02370000
         LA    R9,8(,R9)                                                02380000
         SH    R2,=H'+8'                                                02390000
         B     MAINPRSC                                                 02400000
MAINPRNX DS    0H                                                       02410000
         LTR   R2,R2                                                    02420000
         BE    MAINPRZ                                                  02430000
         CLI   0(R9),C','                                               02440000
         BE    MAINPRCO                                                 02450000
         B     MAINPRER                                                 02460000
MAINPRZ  DS    0H                                                       02470000
         TM    W#FLAG,W#FLGLG                                           02480000
         BNO   MAINPRZ1                                                 02490000
         MVC   W#LINE+1(34),=C'Begin SMP SYSMOD Status processing'      02500000
         BAL   R14,MAINPRT                                              02510000
MAINPRZ1 DS    0H                                                       02520000
****************************************************************        02530000
*                                                              *        02540000
*   MAIN PROCESSING                                            *        02550000
*                                                              *        02560000
****************************************************************        02570000
MAINPROC DS    0H                                                       02580000
         BAL   R14,MAINRD                                               02590000
*0         1         2         3         4         5         6          02600000
*0123456789012345678901234567890123456789012345678901234567890123456    02610000
* HMA2400    ASSEMBLY SUCCESSFUL - MOD=IFNX1J - LIBRARY=                02620000
* HMA4180    INLINE JCLIN PROCESSING SUCCESSFUL FOR SYSMOD=EAS1102      02630000
* HMA4090    COPY SUCCESSFUL - SRC=IFNX1A - LIBRARY=MVSSRC - SYSMOD=    02640000
* HMA2391    LINK SUCCESSFUL - MOD=IFNX4V - LMOD=IFOX41 - LIBRARY=      02650000
* HMA2270    APPLY PROCESSING SUCCESSFULLY COMPLETED FOR SYSMOD EAS1102 02660000
* HMA2050    APPLY PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04     02670000
* HMA2050    ACCEPT PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04    02680000
* HMA2160    UPDATE SUCCESSFUL - MEMBER=EDSECT - LIBRARY=PVTMAC -       02690000
* HMA4012 ** SYSMOD DSK3002 SELECTED FOR ACCEPT NOT FOUND ON SMPPTS     02700000
*                                                                       02710000
         CLI   MAINREC+7,C'0'                                           02720000
         BL    MAINPROC                                                 02730000
         CLC   =C'HMA240',MAINREC+1   ASSEMBLY                          02740000
         BE    MAINASM0                                                 02750000
         CLC   =C'HMA409',MAINREC+1   COPY                              02760000
         BE    MAINCPY0                                                 02770000
         CLC   =C'HMA418',MAINREC+1   JCLIN                             02780000
         BE    MAINJCL0                                                 02790000
         CLC   =C'HMA239',MAINREC+1   LINK                              02800000
         BE    MAINLNK0                                                 02810000
         CLC   =C'HMA205',MAINREC+1   PROCESSING                        02820000
         BE    MAINSYS0                                                 02830000
         CLC   =C'HMA216',MAINREC+1   UPDATE                            02840000
         BE    MAINUPD0                                                 02850000
         CLC   =C'HMA227',MAINREC+1   APPLY/ACCEPT                      02860000
         BE    MAINFUN0                                                 02870000
         CLC   =C' ** ',MAINREC+8     SMP flagged errors                02880000
         BE    MAINERR0                                                 02890000
         B     MAINPROC                                                 02900000
*                                                                       02910000
*0         1         2         3         4         5         6          02920000
*0123456789012345678901234567890123456789012345678901234567890123456    02930000
* HMA2400    ASSEMBLY SUCCESSFUL - MOD=IFNX1J - LIBRARY=                02940000
*LIBRARY=MVSSRC - SYSMOD=DSK1000 - RETURN CODE=00                       02950000
*                                                                       02960000
MAINASM0 DS    0H                                                       02970000
         MVC   MODNAME,=CL8' '                                          02980000
         LA    R0,8                                                     02990000
         LA    R1,MAINREC+38                                            03000000
         LA    R15,MODNAME                                              03010000
MAINASM1 DS    0H                                                       03020000
         MVC   0(1,R15),0(R1)                                           03030000
         LA    R1,1(,R1)                                                03040000
         LA    R15,1(,R15)                                              03050000
         CLI   0(R1),C' '                                               03060000
         BE    MAINASM2                                                 03070000
         BCT   R0,MAINASM1                                              03080000
MAINASM2 DS    0H                                                       03090000
         BAL   R14,GETSYMD                                              03100000
         BAL   R14,GETRC                                                03110000
         AP    ASMCT,=P'+1'                                             03120000
         CLC   UTILRC,ASMRC                                             03130000
         BH    MAINASM3                                                 03140000
         TM    W#FLAG,W#FLGLG                                           03150000
         BNO   MAINASM4                                                 03160000
MAINASM3 DS    0H                                                       03170000
         MVC   W#LINE+1(12),=C'Assembly for'                            03180000
         MVC   W#LINE+14(8),MODNAME                                     03190000
         MVC   W#LINE+23(3),=C'RC='                                     03200000
         MVC   W#LINE+26(2),UTILRC                                      03210000
         MVC   W#LINE+29(7),=C'SYSMOD='                                 03220000
         MVC   W#LINE+36(7),UTILSYSM                                    03230000
         BAL   R14,MAINPRT                                              03240000
MAINASM4 DS    0H                                                       03250000
         CLC   UTILRC,ASMHIRC                                           03260000
         BNH   MAINASM5                                                 03270000
         MVC   ASMHIRC,UTILRC                                           03280000
MAINASM5 DS    0H                                                       03290000
         CLC   UTILRC,ASMRC                                             03300000
         BNH   MAINPROC                                                 03310000
         MVC   RC,=A(4)                                                 03320000
         B     MAINPROC                                                 03330000
*                                                                       03340000
*0         1         2         3         4         5         6          03350000
*0123456789012345678901234567890123456789012345678901234567890123456    03360000
* HMA4090    COPY SUCCESSFUL - SRC=IFNX1A - LIBRARY=MVSSRC - SYSMOD=    03370000
*SYSMOD=EAS1102 - RETURN CODE=00                                        03380000
*                                                                       03390000
MAINCPY0 DS    0H                                                       03400000
         MVC   MODNAME,=CL8' '                                          03410000
         LA    R0,8                                                     03420000
         LA    R1,MAINREC+34                                            03430000
         LA    R15,MODNAME                                              03440000
MAINCPY1 DS    0H                                                       03450000
         MVC   0(1,R15),0(R1)                                           03460000
         LA    R1,1(,R1)                                                03470000
         LA    R15,1(,R15)                                              03480000
         CLI   0(R1),C' '                                               03490000
         BE    MAINCPY2                                                 03500000
         BCT   R0,MAINCPY1                                              03510000
MAINCPY2 DS    0H                                                       03520000
         BAL   R14,GETSYMD                                              03530000
         BAL   R14,GETRC                                                03540000
         AP    CPYCT,=P'+1'                                             03550000
         CLC   UTILRC,CPYRC                                             03560000
         BH    MAINCPY3                                                 03570000
         TM    W#FLAG,W#FLGLG                                           03580000
         BNO   MAINCPY4                                                 03590000
MAINCPY3 DS    0H                                                       03600000
         MVC   W#LINE+1(8),=C'Copy for'                                 03610000
         MVC   W#LINE+10(8),MODNAME                                     03620000
         MVC   W#LINE+19(3),=C'RC='                                     03630000
         MVC   W#LINE+22(2),UTILRC                                      03640000
         MVC   W#LINE+25(7),=C'SYSMOD='                                 03650000
         MVC   W#LINE+32(7),UTILSYSM                                    03660000
         BAL   R14,MAINPRT                                              03670000
MAINCPY4 DS    0H                                                       03680000
         CLC   UTILRC,CPYHIRC                                           03690000
         BNH   MAINCPY5                                                 03700000
         MVC   CPYHIRC,UTILRC                                           03710000
MAINCPY5 DS    0H                                                       03720000
         CLC   UTILRC,CPYRC                                             03730000
         BNH   MAINPROC                                                 03740000
         MVC   RC,=A(4)                                                 03750000
         B     MAINPROC                                                 03760000
*                                                                       03770000
*0         1         2         3         4         5         6          03780000
*0123456789012345678901234567890123456789012345678901234567890123456    03790000
* HMA4180    INLINE JCLIN PROCESSING SUCCESSFUL FOR SYSMOD=EAS1102      03800000
*                                                                       03810000
MAINJCL0 DS    0H                                                       03820000
         TM    W#FLAG,W#FLGLG                                           03830000
         BNO   MAINJCL1                                                 03840000
         MVC   W#LINE+1(9),=C'JCLIN for'                                03850000
         MVC   W#LINE+11(7),MAINREC+58                                  03860000
         BAL   R14,MAINPRT                                              03870000
MAINJCL1 DS    0H                                                       03880000
         B     MAINPROC                                                 03890000
*                                                                       03900000
*0         1         2         3         4         5         6          03910000
*0123456789012345678901234567890123456789012345678901234567890123456    03920000
* HMA2391    LINK SUCCESSFUL - MOD=IFNX4V - LMOD=IFOX41 - LIBRARY=      03930000
*LIBRARY=LINKLIB - SYSMOD=DSK1000 - RETURN CODE=08                      03940000
*                                                                       03950000
MAINLNK0 DS    0H                                                       03960000
         MVC   MODNAME,=CL8' '                                          03970000
         LA    R0,8                                                     03980000
         LA    R1,MAINREC+34                                            03990000
         LA    R15,MODNAME                                              04000000
MAINLNK1 DS    0H                                                       04010000
         MVC   0(1,R15),0(R1)                                           04020000
         LA    R1,1(,R1)                                                04030000
         LA    R15,1(,R15)                                              04040000
         CLI   0(R1),C' '                                               04050000
         BE    MAINLNK2                                                 04060000
         BCT   R0,MAINLNK1                                              04070000
MAINLNK2 DS    0H                                                       04080000
         BAL   R14,GETSYMD                                              04090000
         BAL   R14,GETRC                                                04100000
         AP    LNKCT,=P'+1'                                             04110000
         CLC   UTILRC,LKDRC                                             04120000
         BH    MAINLNK3                                                 04130000
         TM    W#FLAG,W#FLGLG                                           04140000
         BNO   MAINLNK4                                                 04150000
MAINLNK3 DS    0H                                                       04160000
         MVC   W#LINE+1(8),=C'Link for'                                 04170000
         MVC   W#LINE+10(8),MODNAME                                     04180000
         MVC   W#LINE+19(3),=C'RC='                                     04190000
         MVC   W#LINE+22(2),UTILRC                                      04200000
         MVC   W#LINE+25(7),=C'SYSMOD='                                 04210000
         MVC   W#LINE+32(7),UTILSYSM                                    04220000
         BAL   R14,MAINPRT                                              04230000
MAINLNK4 DS    0H                                                       04240000
         CLC   UTILRC,LKDHIRC                                           04250000
         BNH   MAINLKD5                                                 04260000
         MVC   LKDHIRC,UTILRC                                           04270000
MAINLKD5 DS    0H                                                       04280000
         CLC   UTILRC,LKDRC                                             04290000
         BNH   MAINPROC                                                 04300000
         MVC   RC,=A(4)                                                 04310000
         B     MAINPROC                                                 04320000
*                                                                       04330000
*0         1         2         3         4         5         6          04340000
*0123456789012345678901234567890123456789012345678901234567890123456    04350000
* HMA2160    UPDATE SUCCESSFUL - MEMBER=EDSECT - LIBRARY=PVTMAC -       04360000
*- SYSMOD=DSK1000 - RETURN CODE=00                                      04370000
* HMA2162 ** UPDATE FAILED - MEMBER=IFDOLT99 - LIBRARY=MVSSRC -      07 04371000
*                                                                       04380000
MAINUPD0 DS    0H                                                       04390000
         MVC   MODNAME,=CL8' '                                          04400000
         LA    R0,8                                                     04410000
         LA    R1,MAINREC+39                                            04420000
         LA    R15,MODNAME                                              04430000
         CLI   MAINREC+19,C'S'                                       07 04431000
         BE    MAINUPD1                                              07 04432000
         LA    R1,MAINREC+35                                         07 04433000
         AP    SMPERCT,=P'+1'                                        08 04434000
MAINUPD1 DS    0H                                                       04440000
         MVC   0(1,R15),0(R1)                                           04450000
         LA    R1,1(,R1)                                                04460000
         LA    R15,1(,R15)                                              04470000
         CLI   0(R1),C' '                                               04480000
         BE    MAINUPD2                                                 04490000
         BCT   R0,MAINUPD1                                              04500000
MAINUPD2 DS    0H                                                       04510000
         BAL   R14,GETSYMD                                              04520000
         BAL   R14,GETRC                                                04530000
         AP    UPDCT,=P'+1'                                             04540000
         CLC   UTILRC,UPDRC                                             04550000
         BH    MAINUPD3                                                 04560000
         TM    W#FLAG,W#FLGLG                                           04570000
         BNO   MAINUPD4                                                 04580000
MAINUPD3 DS    0H                                                       04590000
         MVC   W#LINE+1(10),=C'Update for'                              04600000
         MVC   W#LINE+12(8),MODNAME                                     04610000
         MVC   W#LINE+21(3),=C'RC='                                     04620000
         MVC   W#LINE+24(2),UTILRC                                      04630000
         MVC   W#LINE+27(7),=C'SYSMOD='                                 04640000
         MVC   W#LINE+34(7),UTILSYSM                                    04650000
         BAL   R14,MAINPRT                                              04660000
MAINUPD4 DS    0H                                                       04670000
         CLC   UTILRC,UPDHIRC                                           04680000
         BNH   MAINUPD5                                                 04690000
         MVC   UPDHIRC,UTILRC                                           04700000
MAINUPD5 DS    0H                                                       04710000
         CLC   UTILRC,UPDRC                                             04720000
         BNH   MAINPROC                                                 04730000
         MVC   RC,=A(4)                                                 04740000
         B     MAINPROC                                                 04750000
*                                                                       04760000
*0         1         2         3         4         5         6          04770000
*0123456789012345678901234567890123456789012345678901234567890123456    04780000
* HMA2050    RECEIVE PROCESSING COMPLETED - HIGHEST RETURN CODE IS 00   04790000
* HMA2050    APPLY PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04     04800000
* HMA2050    ACCEPT PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04    04810000
* HMA2050    HMASMP PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04    04820000
*                                                                       04830000
MAINSYS0 DS    0H                                                       04840000
         CLC   =C'RECEIVE',MAINREC+12                                   04850000
         BE    MAINSYSR                                                 04860000
         CLC   =C'APPLY',MAINREC+12                                     04870000
         BE    MAINSYS1                                                 04880000
         CLC   =C'ACCEPT',MAINREC+12                                    04890000
         BE    MAINSYS2                                                 04900000
         CLC   =C'HMASMP',MAINREC+12                                    04910000
         BE    MAINSYS6                                                 04920000
         B     MAINERS1                                                 04930000
MAINSYSR DS    0H                                                       04940000
         MVC   UTILRC,MAINREC+66                                        04950000
         B     MAINSYS3                                                 04960000
MAINSYS1 DS    0H                                                       04970000
         MVC   UTILRC,MAINREC+64                                        04980000
         B     MAINSYS3                                                 04990000
MAINSYS2 DS    0H                                                       05000000
         MVC   UTILRC,MAINREC+65                                        05010000
MAINSYS3 DS    0H                                                       05020000
         CLC   UTILRC,=C'04'                                            05030000
         BH    MAINSYS4                                                 05040000
         TM    W#FLAG,W#FLGLS                                           05050000
         BO    MAINSYS4                                                 05060000
         TM    W#FLAG,W#FLGLG                                           05070000
         BNO   MAINSYS5                                                 05080000
MAINSYS4 DS    0H                                                       05090000
         MVC   W#LINE+1(6),MAINREC+12                                   05100000
         MVC   W#LINE+8(3),=C'RC='                                      05110000
         MVC   W#LINE+11(2),UTILRC                                      05120000
         BAL   R14,MAINPRT                                              05130000
MAINSYS5 DS    0H                                                       05140000
         B     MAINSYS8                                                 05150000
MAINSYS6 DS    0H                                                       05160000
         MVC   UTILRC,MAINREC+65                                        05170000
         CLC   UTILRC,SMPRC                                             05180000
         BH    MAINSYS7                                                 05190000
         TM    W#FLAG,W#FLGLS                                           05200000
         BO    MAINSYS7                                                 05210000
         TM    W#FLAG,W#FLGLG                                           05220000
         BNO   MAINSYS8                                                 05230000
MAINSYS7 DS    0H                                                       05240000
         MVC   W#LINE+1(7),=C'SMP RC='                                  05250000
         MVC   W#LINE+8(2),UTILRC                                       05260000
         BAL   R14,MAINPRT                                              05270000
MAINSYS8 DS    0H                                                       05280000
         CLC   UTILRC,SMPHIRC                                           05290000
         BNH   MAINSMP9                                                 05300000
         MVC   SMPHIRC,UTILRC                                           05310000
MAINSMP9 DS    0H                                                       05320000
         CLC   UTILRC,SMPRC                                             05330000
         BNH   MAINPROC                                                 05340000
         MVC   RC,=A(4)                                                 05350000
         B     MAINPROC                                                 05360000
*0         1         2         3         4         5         6          05370000
*0123456789012345678901234567890123456789012345678901234567890123456    05380000
* HMA2270    APPLY PROCESSING SUCCESSFULLY COMPLETED FOR SYSMOD EAS1102 05390000
*                                                                       05400000
MAINFUN0 DS    0H                                                       05410000
         CLC   =C'APPLY',MAINREC+12                                     05420000
         BE    MAINFUN1                                                 05430000
         CLC   =C'ACCEPT',MAINREC+12                                    05440000
         BE    MAINFUN2                                                 05450000
         B     MAINERS1                                                 05460000
MAINFUN1 DS    0H                                                       05470000
         CLC   =C'SUCCESSFULLY',MAINREC+29                              05480000
         BNE   MAINERS1                                                 05490000
         MVC   FUNNAM,MAINREC+63                                        05500000
         B     MAINFUN3                                                 05510000
MAINFUN2 DS    0H                                                       05520000
         CLC   =C'SUCCESSFULLY',MAINREC+30                              05530000
         BNE   MAINERS1                                                 05540000
         MVC   FUNNAM,MAINREC+64                                        05550000
MAINFUN3 DS    0H                                                       05560000
         LA    R1,FUNCTS                                                05570000
         LA    R0,FUNCTEND                                              05580000
MAINFUN4 DS    0H                                                       05590000
         CLC   FUNNAM,0(R1)                                             05600000
         BE    MAINFUN5                                                 05610000
         CR    R1,R0                                                    05620000
         BE    MAINFUN6                                                 05630000
         LA    R1,7(,R1)                                                05640000
         B     MAINFUN4                                                 05650000
MAINFUN5 DS    0H                                                       05660000
         AP    FUNCCT,=P'+1'                                            05670000
         TM    W#FLAG,W#FLGLS                                           05680000
         BNO   MAINPROC                                                 05690000
         MVC   W#LINE+1(8),=C'FUNCTION'                                 05700000
         MVC   W#LINE+10(7),FUNNAM                                      05710000
         MVC   W#LINE+18(10),=C'Successful'                             05720000
         MVC   W#LINE+29(6),MAINREC+12                                  05730000
         BAL   R14,MAINPRT                                              05740000
         B     MAINPROC                                                 05750000
MAINFUN6 DS    0H                                                       05760000
         AP    SYSMCT,=P'+1'                                            05770000
         TM    W#FLAG,W#FLGLS                                           05780000
         BNO   MAINPROC                                                 05790000
         MVC   W#LINE+1(6),=C'SYSMOD'                                   05800000
         MVC   W#LINE+8(7),FUNNAM                                       05810000
         MVC   W#LINE+16(10),=C'Successful'                             05820000
         MVC   W#LINE+27(6),MAINREC+12                                  05830000
         BAL   R14,MAINPRT                                              05840000
         B     MAINPROC                                                 05850000
*0         1         2         3         4         5         6          05860000
*0123456789012345678901234567890123456789012345678901234567890123456    05870000
* HMA4012 ** SYSMOD DSK3002 SELECTED FOR ACCEPT NOT FOUND ON SMPPTS     05880000
*                                                                       05890000
MAINERR0 DS    0H                                                       05900000
         AP    SMPERCT,=P'+1'                                           05910000
         MVC   W#LINE+1(121),MAINREC+1                                  05920000
         BAL   R14,MAINPRT                                              05930000
         B     MAINPROC                                                 05940000
****************************************************************        05950000
*                                                              *        05960000
*   TERMINATION                                                *        05970000
*                                                              *        05980000
****************************************************************        05990000
MAINEOF  DS    0H                                                       06000000
         CLOSE (SYSIN)                                                  06010000
         FREEPOOL SYSIN                                                 06020000
MAINEND  DS    0H                                                       06030000
         TM    W#FLAG,W#FLGLG                                           06040000
         BNO   MAINEND0                                                 06050000
         MVC   W#LINE+1(32),=C'End SMP SYSMOD Status processing'        06060000
         BAL   R14,MAINPRT                                              06070000
MAINEND0 DS    0H                                                       06080000
*                                                                       06090000
         BAL   R14,MAINPRT                                              06100000
*                                                                       06110000
         MVC   W#LINE+1(7),=C'Highest'                                  06120000
         MVC   W#LINE+9(7),=C'ASM RC='                                  06130000
         MVC   W#LINE+16(2),ASMHIRC                                     06140000
         MVC   W#LINE+22(7),=C'MAX RC='                                 06150000
         MVC   W#LINE+29(2),ASMRC                                       06160000
         BAL   R14,MAINPRT                                              06170000
*                                                                       06180000
         MVC   W#LINE+1(7),=C'Highest'                                  06190000
         MVC   W#LINE+9(8),=C'COPY RC='                                 06200000
         MVC   W#LINE+17(2),CPYHIRC                                     06210000
         MVC   W#LINE+22(7),=C'MAX RC='                                 06220000
         MVC   W#LINE+29(2),CPYRC                                       06230000
         BAL   R14,MAINPRT                                              06240000
*                                                                       06250000
         MVC   W#LINE+1(7),=C'Highest'                                  06260000
         MVC   W#LINE+9(9),=C'LINK RC='                                 06270000
         MVC   W#LINE+17(2),LKDHIRC                                     06280000
         MVC   W#LINE+22(7),=C'MAX RC='                                 06290000
         MVC   W#LINE+29(2),LKDRC                                       06300000
         BAL   R14,MAINPRT                                              06310000
*                                                                       06320000
         MVC   W#LINE+1(7),=C'Highest'                                  06330000
         MVC   W#LINE+9(10),=C'UPDATE RC='                              06340000
         MVC   W#LINE+19(2),UPDHIRC                                     06350000
         MVC   W#LINE+22(7),=C'MAX RC='                                 06360000
         MVC   W#LINE+29(2),UPDRC                                       06370000
         BAL   R14,MAINPRT                                              06380000
*                                                                       06390000
         MVC   W#LINE+1(7),=C'Highest'                                  06400000
         MVC   W#LINE+9(7),=C'SMP RC='                                  06410000
         MVC   W#LINE+16(2),SMPHIRC                                     06420000
         MVC   W#LINE+22(7),=C'MAX RC='                                 06430000
         MVC   W#LINE+29(2),SMPRC                                       06440000
         BAL   R14,MAINPRT                                              06450000
*                                                                       06510000
         BAL   R14,MAINPRT                                              06520000
*                                                                       06530000
         MVC   W#LINE+1(10),=C'Assemblies'                              06540000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06550000
         ED    W#LINE+30(12),ASMCT                                      06560000
         BAL   R14,MAINPRT                                              06570000
*                                                                       06580000
         MVC   W#LINE+1(6),=C'Copies'                                   06590000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06600000
         ED    W#LINE+30(12),CPYCT                                      06610000
         BAL   R14,MAINPRT                                              06620000
*                                                                       06630000
         MVC   W#LINE+1(5),=C'Links'                                    06640000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06650000
         ED    W#LINE+30(12),LNKCT                                      06660000
         BAL   R14,MAINPRT                                              06670000
*                                                                       06680000
         MVC   W#LINE+1(7),=C'Updates'                                  06690000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06700000
         ED    W#LINE+30(12),UPDCT                                      06710000
         BAL   R14,MAINPRT                                              06720000
*                                                                       06730000
         MVC   W#LINE+1(7),=C'SYSMODs'                                  06740000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06750000
         ED    W#LINE+30(12),SYSMCT                                     06760000
         BAL   R14,MAINPRT                                              06770000
*                                                                       06780000
         MVC   W#LINE+1(9),=C'FUNCTIONs'                                06790000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06800000
         ED    W#LINE+30(12),FUNCCT                                     06810000
         BAL   R14,MAINPRT                                              06820000
*                                                                       06821000
         MVC   W#LINE+1(19),=C'SMP errors detected'                     06822000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06823000
         ED    W#LINE+30(12),SMPERCT                                    06824000
         BAL   R14,MAINPRT                                              06825000
*                                                                       06830000
         TM    W#FLAG,W#FLGLG                                           06840000
         BNO   MAINEND1                                                 06850000
         MVC   W#LINE+1(13),=C'Print records'                           06860000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06870000
         ED    W#LINE+30(12),MAININCT                                   06880000
         BAL   R14,MAINPRT                                              06890000
MAINEND1 DS    0H                                                       06900000
*                                                                       06910000
         BAL   R14,MAINPRT                                              06920000
*                                                                       06930000
         ICM   R0,15,RC                                                 06940000
         BNZ   MAINEND2                                                 06950000
         MVC   W#LINE+1(22),=C'No SMP errors detected'                  06960000
         BAL   R14,MAINPRT                                              06970000
MAINEND2 DS    0H                                                       06980000
         MVC   W#LINE+1(12),=C'Return code='                            06990000
         UNPK  W#LINE+13(5),RC+2(3)                                     07000000
         TR    W#LINE+13(4),W#HX2CHR-240                                07010000
         MVI   W#LINE+13+4,C' '                                         07020000
         BAL   R14,MAINPRT                                              07030000
         L     R2,RC                                                    07040000
         CLOSE (W#PRTDD)                                                07050000
         FREEPOOL W#PRTDD                                               07060000
         L     R13,4(,R13)                                              07070000
         L     R14,12(,R13)                                             07080000
         LR    R15,R2                                                   07090000
         LM    R0,R12,20(R13)                                           07100000
         BR    R14                                                      07110000
*                                                                       07120000
*                                                                       07130000
*                                                                       07140000
GETRC    DS    0H                                                       07150000
         LA    R15,MAINREC+10                                           07160000
         LA    R0,MAINREC+L'MAINREC-14                                  07170000
         MVC   UTILRC,=C'??'                                            07180000
GETRC1   DS    0H                                                       07190000
         CLC   =C'RETURN CODE=',0(R15)                                  07200000
         BE    GETRC2                                                   07210000
         LA    R15,1(,R15)                                              07220000
         CR    R15,R0                                                   07230000
         BL    GETRC1                                                   07240000
         B     GETRC9                                                   07250000
GETRC2   DS    0H                                                       07260000
         MVC   UTILRC,12(R15)                                           07270000
GETRC9   DS    0H                                                       07280000
         BR    R14                                                      07290000
*                                                                       07300000
*                                                                       07310000
*                                                                       07320000
GETSYMD  DS    0H                                                       07330000
         LA    R15,MAINREC+10                                           07340000
         LA    R0,MAINREC+L'MAINREC-14                                  07350000
         MVC   UTILSYSM,=CL8' '                                         07360000
GETSYMD1 DS    0H                                                       07370000
         CLC   =C'SYSMOD=',0(R15)                                       07380000
         BE    GETSYMD2                                                 07390000
         LA    R15,1(,R15)                                              07400000
         CR    R15,R0                                                   07410000
         BL    GETSYMD1                                                 07420000
         B     MAINERS1                                                 07430000
GETSYMD2 DS    0H                                                       07440000
         MVC   UTILSYSM,7(R15)                                          07450000
         BR    R14                                                      07460000
*                                                                       07470000
*                                                                       07480000
*                                                                       07490000
MAINPRER DS    0H                                                       07500000
         S     R9,W#PARMAD                                              07510000
         LA    R9,W#LINE+4(R9)                                          07520000
         C     R9,=A(W#LINE+L'W#LINE-1)                                 07530000
         BNH   MAINP131                                                 07540000
         MVI   W#LINE+5,C'?'                                            07550000
         B     MAINP133                                                 07560000
MAINP131 DS    0H                                                       07570000
         MVI   0(R9),C'*'                                               07580000
MAINP133 DS    0H                                                       07590000
         BAL   R14,MAINPRT                                              07600000
         MVC   W#LINE+1(33),=C'PARM= contained invalid parameter'       07610000
         B     MAINQUIT                                                 07620000
*                                                                       07630000
*                                                                       07640000
*                                                                       07650000
MAINERS1 DS    0H                                                       07660000
         MVC   W#LINE+2(7),=C'Error->'                                  07670000
         MVC   W#LINE+9(80),MAINREC+1                                   07680000
         B     MAINQUIT                                                 07690000
*                                                                       07700000
*                                                                       07710000
*                                                                       07720000
MAINQUIT DS    0H                                                       07730000
         BAL   R14,MAINPRT                                              07740000
         MVC   RC,=A(8)                                                 07750000
         B     MAINEND2                                                 07760000
*                                                                       07770000
*                                                                       07780000
*                                                                       07790000
MAINPRT  DS    0H                                                       07800000
         ST    R14,MAINPR14                                             07810000
         L     R15,=A(PRINT)                                            07820000
         BALR  R14,R15                                                  07830000
         L     R14,MAINPR14                                             07840000
         BR    R14                                                      07850000
*                                                                       07860000
*                                                                       07870000
*                                                                       07880000
MAINRD   DS    0H                                                       07890000
         ST    R14,MAINRD14                                             07900000
         MVI   MAINREC,C' '                                             07910000
         MVC   MAINREC+1(L'MAINREC-1),MAINREC                           07920000
         GET   SYSIN,MAINREC                                            07930000
         AP    MAININCT,=P'+1'                                          07940000
         TM    W#FLAG,W#FLGLA                                           07950000
         BNO   MAINRD9                                                  07960000
         MVC   W#LINE+2(7),=C'Read-->'                                  07970000
         MVC   W#LINE+9(80),MAINREC+1                                   07980000
         BAL   R14,MAINPRT                                              07990000
MAINRD9  DS    0H                                                       08000000
         L     R14,MAINRD14                                             08010000
         BR    R14                                                      08020000
****************************************************************        08030000
*                                                              *        08040000
*            CONSTANTS AND WORK AREAS                          *        08050000
*                                                              *        08060000
****************************************************************        08070000
         LTORG ,                                                        08080000
JULWRK2  DC    A(0)                                                     08090000
JULWRK4  DC    P'+365'                                                  08100000
         DC    P'+01'                                                   08110000
         DC    P'+31'                                                   08120000
         DC    P'+30'                                                   08130000
         DC    P'+31'                                                   08140000
         DC    P'+30'                                                   08150000
         DC    P'+31'                                                   08160000
         DC    P'+31'                                                   08170000
         DC    P'+30'                                                   08180000
         DC    P'+31'                                                   08190000
         DC    P'+30'                                                   08200000
         DC    P'+31'                                                   08210000
JULWRK6  DC    P'+28'                                                   08220000
JULTBL1  DC    P'+31'                                                   08230000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  08240000
SYSIN    DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=MAINEOF             08250000
MAINPR14 DC    A(0)                                                     08260000
MAINRD14 DC    A(0)                                                     08270000
MAINWR14 DC    A(0)                                                     08280000
RC       DC    A(0)                                                     08290000
MAININCT DC    PL5'+0'                                                  08300000
ASMCT    DC    PL5'+0'                                                  08310000
CPYCT    DC    PL5'+0'                                                  08320000
LNKCT    DC    PL5'+0'                                                  08330000
UPDCT    DC    PL5'+0'                                                  08340000
SYSMCT   DC    PL5'+0'                                                  08350000
FUNCCT   DC    PL5'+0'                                                  08360000
SMPERCT  DC    PL5'+0'                                                  08370000
UTILRC   DC    CL2' '                                                   08380000
ASMRC    DC    CL2'04'                                                  08390000
CPYRC    DC    CL2'04'                                                  08400000
LKDRC    DC    CL2'12'                                                  08410000
UPDRC    DC    CL2'00'                                               07 08410100
SMPRC    DC    CL2'04'                                                  08430000
ASMHIRC  DC    CL2' '                                                   08440000
CPYHIRC  DC    CL2' '                                                   08450000
LKDHIRC  DC    CL2' '                                                   08460000
UPDHIRC  DC    CL2' '                                                   08470000
SMPHIRC  DC    CL2' '                                                   08480000
MODNAME  DC    CL8' '                                                   08490000
UTILSYSM DC    CL7' '                                                   08500000
FUNNAM   DC    CL7' '                                                   08510000
MAINREC  DC    CL121' '                                                 08520000
         DC    CL12' '  IN CASE LRECL=133                               08530000
FUNCTS   DC    C'EAS1102'                                               08540000
         DC    C'EBB1102'                                               08550000
         DC    C'EBT1102'                                               08560000
         DC    C'EDE1102'                                               08570000
         DC    C'EDM1102'                                               08580000
         DC    C'EDS1102'                                               08590000
         DC    C'EER1400'                                               08600000
         DC    C'EGA1102'                                               08610000
         DC    C'EIP1102'                                               08620000
         DC    C'EJE1103'                                               08630000
         DC    C'EMF1102'                                               08640000
         DC    C'EMI1102'                                               08650000
         DC    C'EML1102'                                               08660000
         DC    C'EMS1102'                                               08670000
         DC    C'EPM1102'                                               08680000
         DC    C'ESM1102'                                               08690000
         DC    C'EST1102'                                               08700000
         DC    C'ESU1102'                                               08710000
         DC    C'ESY1400'                                               08720000
         DC    C'ETC0108'                                               08730000
         DC    C'ETI1106'                                               08740000
         DC    C'ETV0108'                                               08750000
         DC    C'EUT1102'                                               08760000
         DC    C'EVT0108'                                               08770000
         DC    C'EXW1102'                                               08780000
         DC    C'FBB1221'                                               08790000
         DC    C'FDM1133'                                               08800000
         DC    C'FDS1122'                                               08810000
         DC    C'FDS1133'                                               08820000
         DC    C'FDZ1610'                                               08830000
FUNCTEND DC    C'FUT1133'                                               08840000
*                                                                       08850000
*        Common area                                                    08860000
*                                                                       08870000
W#       CSECT                                                          08880000
W#SA     DC    18A(0)                                                   08890000
W#SA1    DC    18A(0)                                                   08900000
W#SA2    DC    18A(0)                                                   08910000
W#SA3    DC    18A(0)                                                   08920000
W#SA4    DC    18A(0)                                                   08930000
W#SA5    DC    18A(0)                                                   08940000
W#SA6    DC    18A(0)                                                   08950000
W#SA7    DC    18A(0)                                                   08960000
W#DWORD  DC    D'+0'                                                    08970000
W#CURDTE DC    A(0)                                                     08980000
W#TMWK4  DC    X'402021204B20204B20204B2020'                            08990000
W#HX2CHR DC    C'0123456789ABCDEF'                                      09000000
W#PARMAD DC    A(0)                                                     09010000
W#FLAG   DC    AL1(0)                                                   09020000
W#FLGLG EQU    X'80'                                                    09030000
W#FLGLA EQU    X'40'                                                    09040000
W#FLGLS EQU    X'20'                                                    09050000
W#LNCT   DC    PL2'+99'                                                 09060000
W#PGCT   DC    PL2'+0'                                                  09070000
W#LINE   DC    CL133' '                                                 09080000
W#HD1    DC    CL133'1'                                                 09090000
         ORG   W#HD1+1                                                  09100000
W#HD1DTE DC    C'            '                                          09110000
         DC    C' '                                                     09120000
W#HD1TOD DC    C'HH:MM:SS'                                              09130000
         DC    C'  '                                                    09140000
W#HD1RPT DC    C'                '                                      09150000
         ORG   W#HD1+66-(28/2)                                          09160000
W#HD1TTL DC    C'SMP Processing Status Report'                          09170000
         ORG   W#HD1+L'W#HD1-4-4                                        09180000
W#HD1PG  DC    C'Page'                                                  09190000
W#HD1PCT DC    C' 123'                                                  09200000
W#HD2    DC    CL133' '                                                 09210000
W#PRTDD  DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X09220000
               RECFM=FBA,LRECL=133                                      09230000
         DC    CL8'<-----W#'                                            09240000
         DROP  ,                                                        09250000
****************************************************************        09260000
*                                                              *        09270000
*            WRITE PRINT LINE                                  *        09280000
*                                                              *        09290000
****************************************************************        09300000
PRINT    CSECT                                                          09310000
         USING PRINT,R15                                                09320000
         B     PRINTBGN                                                 09330000
         DROP  R15                                                      09340000
         DC    AL1(L'PRINTID)                                           09350000
PRINTID  DC    C'PRINT &SYSDATE &SYSTIME'                               09360000
PRINTBGN DS    0H                                                       09370000
         STM   R14,R12,12(R13)         SAVE CALLERS REGS                09380000
         LR    R12,R15                 TRANSFER BASE REG                09390000
         USING PRINT,R12                                                09400000
         USING W#,R10                                                   09410000
         LA    R14,18*4(,R13)                                           09420000
         ST    R13,4(,R14)                                              09430000
         ST    R14,8(,R13)                                              09440000
         LR    R13,R14                                                  09450000
         CP    W#LNCT,=P'+60'          END OF PAGE                      09460000
         BL    PRINTCHK                 NO, CHECK IF LINE FIT IN PAGE   09470000
PRINTHDS DS    0H                                                       09480000
         AP    W#PGCT,=P'+1'           COUNT PAGES                      09490000
         MVC   W#HD1PCT,=X'40202120'   PAGE COUNT MASK                  09500000
         ED    W#HD1PCT,W#PGCT         EDIT PAGE COUNT                  09510000
         PUT   W#PRTDD,W#HD1           PRINT HEADING 1                  09520000
         PUT   W#PRTDD,W#HD2           PRINT HEADING 1                  09530000
         ZAP   W#LNCT,=P'+2'           INIT LINE COUNT                  09540000
         MVI   W#LINE,C'0'             SKIP AFTER HEADING               09550000
PRINTCHK DS    0H                                                       09560000
         CLI   W#LINE,C'+'             OVERPRINT ?                      09570000
         BE    PRINTLN                  YES, DON'T COUNT                09580000
         CLI   W#LINE,C'1'             NEW LINE ?                       09590000
         BE    PRINTHDS                 YES, PRINT HEADER               09600000
         CLI   W#LINE,C' '             WRITE AFTER ADVANCING 1?         09610000
         BE    PRINTLN1                 YES, GO CHECK IF FIT            09620000
         CLI   W#LINE,C'0'             WRITE AFTER ADVANCING 1?         09630000
         BE    PRINTLN2                 YES, GO CHECK IF FIT            09640000
         CLI   W#LINE,C'-'             WRITE AFTER ADVANCING 1?         09650000
         BE    PRINTLN3                 YES, GO CHECK IF FIT            09660000
         B     PRINTLN1                IGNORE ANY OTHER CTL CHARS       09670000
PRINTLN1 DS    0H                                                       09680000
         AP    W#LNCT,=P'+1'           ADD TO LINE COUNT                09690000
         B     PRINTVFY                GO SEE IF IT WILL FIT            09700000
PRINTLN2 DS    0H                                                       09710000
         AP    W#LNCT,=P'+2'           ADD TO LINE COUNT                09720000
         B     PRINTVFY                GO SEE IF IT WILL FIT            09730000
PRINTLN3 DS    0H                                                       09740000
         AP    W#LNCT,=P'+3'           ADD TO LINE COUNT                09750000
PRINTVFY DS    0H                                                       09760000
         CP    W#LNCT,=P'+60'          OVERFLOW ?                       09770000
         BH    PRINTHDS                 YES, FORCE HEADER               09780000
PRINTLN  DS    0H                                                       09790000
         CLC   =C'Begin ',W#LINE+1                                      09800000
         BE    PRINTLN4                                                 09810000
         CLC   =C'End ',W#LINE+1                                        09820000
         BNE   PRINTLN5                                                 09830000
PRINTLN4 DS    0H                                                       09840000
         MVC   PRTSAV,W#LINE                                            09850000
         TIME  BIN                     GET CURRENT DATE AND TIME        09860000
         ST    R1,W#CURDTE             SAVE DATE                        09870000
         SRDL  R0,32                   GET DOUBLE WORD TIME             09880000
         D     R0,=F'+6000'            GET MINUTES                      09890000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     09900000
         SLR   R0,R0                   CLEAR                            09910000
         D     R0,=F'+60'              GET HOURS / MINS                 09920000
         MH    R0,=H'+10000'           GET MINUTES                      09930000
         AR    R15,R0                  ADD TO GET MM:SS.TH              09940000
         M     R0,=F'+1000000'         GET HOURS                        09950000
         AR    R1,R15                  GET HH:MM:SS.TH                  09960000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              09970000
         MVC   W#TMWK4,=X'402120207A20207A20204B2020'                   09980000
         ED    W#TMWK4,W#DWORD+3   EDIT TIME                            09990000
         MVC   W#LINE+1(11),W#TMWK4+2 MOVE TIME                         10000000
         MVI   W#LINE+12,C' '                                           10010000
         MVC   W#LINE+13(132-12),PRTSAV+1                               10020000
PRINTLN5 DS    0H                                                       10030000
         PUT   W#PRTDD,W#LINE          PRINT A LINE                     10040000
         MVI   W#LINE,C' '             CLEAR CONTROL CHARACTER          10050000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              10060000
         L     R13,4(,R13)             POINT TO CALLERS SAVE            10070000
         L     R14,R12(,R13)           SET RETURN ADDRESS               10080000
         LA    R15,0                   SET RETURN CODE                  10090000
         LM    R14,12,12(R13)          RESTORE REGS                     10100000
         BR    R14                     RETURN TO CALLER                 10110000
         LTORG ,                                                        10120000
PRTSAV   DC    CL133' '                                                 10130000
*                                                                       10140000
*                                                                       10150000
*                                                                       10160000
R0       EQU   0                                                        10170000
R1       EQU   1                                                        10180000
R2       EQU   2                                                        10190000
R3       EQU   3                                                        10200000
R4       EQU   4                                                        10210000
R5       EQU   5                                                        10220000
R6       EQU   6                                                        10230000
R7       EQU   7                                                        10240000
R8       EQU   8                                                        10250000
R9       EQU   9                                                        10260000
R10      EQU   10                                                       10270000
R11      EQU   11                                                       10280000
R12      EQU   12                                                       10290000
R13      EQU   13                                                       10300000
R14      EQU   14                                                       10310000
R15      EQU   15                                                       10320000
         END   MVSSMP38                                                 10330000
