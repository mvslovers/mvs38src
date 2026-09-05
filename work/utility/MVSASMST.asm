         MACRO                                                          00010003
&LBL     $TRC                                                           00020003
&LBL     DS    0H                                                       00030003
           STM   R0,R15,TRCRGS         SAVE REGISTERS                   00040003
           LA    R15,=CL8'&LBL'        PASS LABEL                       00050003
           BAL   R14,DIAGTRC           TRACE                            00060003
           LM    R0,R15,TRCRGS         RESTORE REGISTERS                00070003
         MEND                                                           00080003
*********************************************************************** 00090000
*                                                                     * 00100000
* MODULE NAME                                                         * 00110000
*    MVSASMST                                                         * 00120000
*                                                                     * 00130000
* ATTRIBUTES                                                          * 00140000
*    NONE                                                             * 00150000
*                                                                     * 00160000
* AUTHOR                                                              * 00170000
*    DAVE KREISS                                                      * 00180000
*                                                                     * 00190000
* FUNCTION                                                            * 00200000
*    STRIP ASSEMBLY OF IRRELEVANT LINES SO IT IS EASIER TO COMPARE    * 00210000
*    TWO SETS OF LISTINGS.                                            * 00220000
*                                                                     * 00230000
*********************************************************************** 00240000
*                                                                     * 00250000
* SAMPLE JCL                                                          * 00260000
*    //STRIP   EXEC PGM=MVSASMST PARM='DEBUG'                         * 00270000
*    //STEPLIB  DD  DSN=MVSSRC.BLD.UTILITY.LOAD,DISP=SHR              * 00280000
*    //SYSUT1   DD  DSN=LIST,DISP=SHR                                 * 00290000
*    //SYSUT2   DD  DSN=STRIPPED.LIST,DISP=SHR                        * 00300000
*                                                                     * 00310000
* DD STATEMENTS                                                       * 00320000
*    STEPLIB       LOAD LIBRARY AINING THE MODULE MVSLKDST.           * 00330000
*    SYSUT1        ONTAINING AN ASSEMBLY LISTING LRECL=133            * 00340000
*    SYSUT2        CONTAINING PARED DOWN LISTING LRECL=133            * 00350000
*                                                                     * 00360000
* RETURN CODES                                                        * 00370000
*    0             ALWAYS ISSUES RETURN CODE 0                        * 00380000
*                                                                     * 00390000
*********************************************************************** 00400000
*                                                                     * 00410000
* PARAMETERS                                                          * 00420000
*    ALL PARAMETERS ARE SEPERATED BY COMMAS.                          * 00430000
*    DEBUG          SKIPPED LINES PRINTED WITH > IN CARRIAGE CONTROL  * 00440000
*    NODS0H         SKIP DS WITH A REPLICATION OF 0                   * 00450003
*                                                                     * 00460000
*********************************************************************** 00470000
*                                                                     * 00480000
* CHANGE LOG:                                                         * 00490000
*   DATE     AAA VV.VV DESCRIPTION                                    * 00500000
* 11/17/2015 DSK 01.01 CREATED                                        * 00510000
* 01/04/2019 DSK 01.02 SKIP CSECT STATEMENTS                          * 00520002
         LCLC   &VER                                                    00530000
&VER     SETC   '01.02'                                                 00540000
MVSASMST CSECT                                                          00550000
         USING MVSASMST,R15                                             00560000
         B     BEGIN                                                    00570000
         DROP  R15                                                      00580000
         DC    AL1(L'PGMID)                                             00590000
PGMID    DC    C'MVSASMST - &VER &SYSDATE &SYSTIME'                     00600000
BEGIN    DC    0H'+0'                                                   00610000
*                                                                       00620000
*        INITIALIZATION                                                 00630000
*                                                                       00640000
         STM   R14,R12,12(R13)                                          00650000
         LR    R12,R15                                                  00660000
         USING MVSASMST,R12                                             00670000
         LA    R14,SAVEAREA                                             00680000
         ST    R13,4(,R14)                                              00690000
         ST    R14,8(,R13)                                              00700000
         LR    R13,R14                                                  00710000
         L     R9,0(,R1)                                                00720000
         OPEN  (SYSUT2,(OUTPUT),SYSUT1,(INPUT))                         00730000
         TM    SYSUT2+48,16                                             00740000
         BZ    QUIT                                                     00750000
         TM    SYSUT1+48,16                                             00760000
         BZ    QUIT                                                     00770000
         LH    R2,0(,R9)                                                00780003
         LA    R9,2(,R9)                                                00790003
INITPRSC DS    0H                                                       00800003
         LTR   R2,R2                                                    00810003
         BE    INITPRZ                                                  00820003
         CLI   0(R9),C','                                               00830003
         BNE   INITPRCK                                                 00840003
INITPRCO DS    0H                                                       00850003
         LA    R9,1(,R9)                                                00860003
         BCTR  R2,0                                                     00870003
         B     INITPRSC                                                 00880003
INITPRCK DS    0H                                                       00890003
         CH    R2,=H'+5'                                                00900003
         BL    INITPRER                                                 00910003
         CLC   =C'DEBUG',0(R9)         DEBUG REQUESTED                  00920003
         BE    INITPRDB                                                 00930003
         CH    R2,=H'+6'                                                00940003
         BL    INITPRER                                                 00950003
         CLC   =C'NODS0H',0(R9)        NODS0H REQUESTED                 00960003
         BE    INITPRN0                                                 00970003
         B     INITPRER                                                 00980003
INITPRDB DS    0H                                                       00990003
         MVI   DEBUG,C'Y'                                               01000003
         LA    R9,5(,R9)                                                01010003
         SH    R2,=H'+5'                                                01020003
         B     INITPRNX                                                 01030003
INITPRN0 DS    0H                                                       01040003
         MVI   NODS0H,C'Y'                                              01050003
         LA    R9,6(,R9)                                                01060003
         SH    R2,=H'+6'                                                01070003
         B     INITPRNX                                                 01080003
INITPRNX DS    0H                                                       01090003
         LTR   R2,R2                                                    01100003
         BZ    INITPRZ                                                  01110003
         CLI   0(R9),C','                                               01120003
         BE    INITPRCO                                                 01130003
INITPRER DS    0H                                                       01140003
         MVC   LINE+1(12),=C'INVALID PARM='                             01150003
         MVC   LINE+13(10),0(R9)                                        01160003
         PUT   SYSUT2,LINE                                              01170003
         B     QUIT                                                     01180003
INITPRZ  DS    0H                                                       01190003
*                                                                       01200000
*        PROCESS ASSEMBLY LISTING                                       01210000
*                                                                       01220000
PROC     DS    0H                                                       01230000
         MVI   LINE,C' '                                                01240003
         MVC   LINE+1(L'LINE-1),LINE                                    01250003
         GET   SYSUT1,LINE                                              01260000
*        SKIP COMMENTS                                                  01270000
         CLI   LINE+42,C'*'                                             01280000
         BE    SKIP                                                     01290000
         CLC   =C'.*',LINE+42                                           01300000
         BE    SKIP                                                     01310000
         CLC   =C'000',LINE+1          LOCATION=000XXX                  01320000
         BE    SELECT                                                   01330000
         CLC   =C'001',LINE+1          LOCATION=001XXX                  01340000
         BE    SELECT                                                   01350000
         CLC   =C'002',LINE+1          LOCATION=002XXX                  01360000
         BNE   SKIP                                                     01370000
SELECT   DS    0H                                                       01380000
*        DROP ORG STATEMENTS                                            01390000
         LA    R1,LINE+42                                               01400000
         LA    R0,40                                                    01410000
SELECT1  DS    0H                                                       01420000
         CLC   =C' ORG ',0(R1)                                          01430000
         BE    SKIP                                                     01440000
         CLI   0(R1),C' '                                               01450000
         BNE   SELECTC1                                              02 01460002
         LA    R1,1(,R1)                                                01470000
         BCT   R0,SELECT1                                               01480000
*        DROP CSECT STATEMENTS                                       02 01490002
SELECTC1 DS    0H                                                    02 01500002
         LA    R1,LINE+42                                            02 01510002
         LA    R0,40                                                 02 01520002
SELECTC2 DS    0H                                                    02 01530002
         CLI   0(R1),C' '                                            02 01540002
         BE    SELECTC3                                              02 01550002
         LA    R1,1(,R1)                                             02 01560002
         BCT   R0,SELECTC2                                           02 01570002
         B     SELECT2                                               02 01580002
SELECTC3 DS    0H                                                    02 01590002
         CLC   =C' CSECT ',0(R1)                                     02 01600002
         BE    SKIP                                                  02 01610002
         CLI   0(R1),C' '                                            02 01620002
         BNE   SELECT2                                               02 01630002
         LA    R1,1(,R1)                                             02 01640002
         BCT   R0,SELECTC2                                           02 01650002
SELECT2  DS    0H                                                       01660000
*        KEEP ANY CODE GENERATED                                        01670000
         CLC   =C'              ',LINE+8                                01680000
         BNE   KEEP                                                     01690000
*        KEEP LABEL DS AND DS NO LABEL UNLESS ZERO REPLICATION          01700000
         LA    R1,LINE+42                                               01710000
         LA    R0,70                                                    01720003
SELECT3  DS    0H                                                       01730000
         CLI   0(R1),C' '                                               01740000
         BE    SELECT4                                                  01750000
         LA    R1,1(,R1)                                                01760000
         BCT   R0,SELECT3                                               01770000
         B     SKIP                                                     01780000
SELECT4  DS    0H                                                       01790000
         CLC   =C' DS ',0(R1)                                           01800000
         BE    SELECT5                                                  01810000
         CLC   =C' DSECT ',0(R1)                                        01820000
         BE    SKIPDS                                                   01830000
         CLI   0(R1),C' '                                               01840000
         BNE   SKIP                                                     01850000
         LA    R1,1(,R1)                                                01860000
         BCT   R0,SELECT4                                               01870000
         B     SKIP                                                     01880000
SELECT5  DS    0H                                                       01890003
         LA    R1,4(,R1)                                                01900003
         SH    R0,=H'+4'                                                01910003
         BNH   KEEP                                                     01920003
SELECT5A DS    0H                                                       01930003
         CLI   0(R1),C' '                                               01940000
         BNE   SELECT6                                                  01950000
         LA    R1,1(,R1)                                                01960000
         BCT   R0,SELECT5A                                              01970003
         B     SKIP                                                     01980000
SELECT6  DS    0H                                                       01990003
         CLI   0(R1),C'0'                                               02000003
         BNE   KEEP                                                     02010003
SELECT7  DS    0H                                                       02020003
         CLI   0(R1),C'0'                                               02030003
         BH    KEEP                                                     02040003
         BL    SELECT8                                                  02050003
         LA    R1,1(,R1)                                                02060003
         BCT   R0,SELECT7                                               02070003
         B     KEEP                                                     02080003
SELECT8  DS    0H                                                       02090003
         CLI   NODS0H,C'Y'             DROP DS 0                        02100003
         BE    SKIP                                                     02110003
SELECT9  DS    0H                                                       02120003
KEEP     DS    0H                                                       02130000
         CLI   INDSECT,C'Y'            IN A DSECT                       02140000
         BE    SKIP                                                     02150000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          02160000
PUT      DS    0H                                                       02170000
         PUT   SYSUT2,LINE                                              02180000
         B     PROC                                                     02190000
SKIP     DS    0H                                                       02200000
         CLI   DEBUG,C'Y'                                               02210000
         BNE   PROC                                                     02220000
         MVI   LINE,C'>'                                                02230000
         B     PUT                                                      02240000
SKIPDS   DS    0H                                                       02250000
         MVI   INDSECT,C'Y'                                             02260000
         B     SKIP                                                     02270000
SKIPCS   DS    0H                                                       02280000
         MVI   INDSECT,C'N'                                             02290000
         B     KEEP                                                     02300000
*                                                                       02310000
*        TERMINATION                                                    02320000
*                                                                       02330000
EXIT     DS    0H                                                       02340000
         CLOSE (SYSUT2,,SYSUT1)                                         02350000
         L     R13,4(,R13)                                              02360000
         LM    R14,R12,12(R13)                                          02370000
         LA    R15,0                                                    02380000
         BR    R14                                                      02390000
QUIT     DS    0H                                                       02400000
         L     R13,4(,R13)                                              02410000
         LM    R14,R12,12(R13)                                          02420000
         LA    R15,16                                                   02430000
         BR    R14                                                      02440000
DIAGTRC  DS    0H                                                       02450003
         ST    R14,TRCR14              SAVE LINKAGE                     02460003
         MVC   LINE+132-8(8),0(R15)    MOVE LABEL TO PRINT              02470003
         PUT   SYSUT2,LINE             PRINT                            02480003
         L     R14,TRCR14              RESTORE LINKAGE                  02490003
         BR    R14                                                      02500003
SAVEAREA DC    18A(0)                                                   02510000
TRCR14   DC    A(0)                                                     02520003
TRCRGS   DC    15A(0)                                                   02530003
INDSECT  DC    C'N'                                                     02540000
DEBUG    DC    C'N'                                                     02550000
NODS0H   DC    C'N'                                                     02560003
SYSUT1   DCB   DDNAME=SYSUT1,MACRF=GM,DSORG=PS,EODAD=EXIT               02570000
SYSUT2   DCB   DDNAME=SYSUT2,MACRF=PM,DSORG=PS,                        *02580000
               RECFM=FBA,LRECL=133                                      02590000
LINE     DC    CL133' '                                                 02600000
R0       EQU   0                                                        02610000
R1       EQU   1                                                        02620000
R2       EQU   2                                                        02630000
R3       EQU   3                                                        02640000
R4       EQU   4                                                        02650000
R5       EQU   5                                                        02660000
R6       EQU   6                                                        02670000
R7       EQU   7                                                        02680000
R8       EQU   8                                                        02690000
R9       EQU   9                                                        02700000
R10      EQU   10                                                       02710000
R11      EQU   11                                                       02720000
R12      EQU   12                                                       02730000
R13      EQU   13                                                       02740000
R14      EQU   14                                                       02750000
R15      EQU   15                                                       02760000
         END                                                            02770000
