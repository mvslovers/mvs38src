*********************************************************************** 00010039
*                                                                     * 00020039
*        Compare compressed Assembly Listing                          * 00030039
*                                                                     * 00040039
*********************************************************************** 00050000
*        Operand Table                                                * 00060026
*********************************************************************** 00070000
OPNDDS   DSECT ,                                                        00080010
OPNDKEY  DS    0XL6                                                     00090031
OPNDDIFS DS    XL1          0=no difference 1=negative 2=positive       00100031
OPNDDIF  DS    XL2          Displacement difference                     00110031
OPNDKEY1 DS    0XL3                                                     00120031
OPNDOBAS DS    XL1          Original base register                      00130031
OPNDDDD  DS    XL2          Corrected Displacement                      00140031
OPNDOBDD DS    CL4          Old base and displacement                   00150039
OPNDNBDD DS    CL4          New base and displacement                   00160039
OPNDDISP DS    CL5                                                      00170025
OPNDNUM  DS    XL2                                                      00180010
OPNDNSQ1 DS    CL8                                                      00190039
OPNDNSQ2 DS    CL8                                                      00200039
OPNDNSQ3 DS    CL8                                                      00210039
OPNDNSQ4 DS    CL8                                                      00220039
OPNDNSQ5 DS    CL8                                                      00230039
OPNDNSQ6 DS    CL8                                                      00240039
OPNDNSQ7 DS    CL8                                                      00250039
OPNDNSQ8 DS    CL8                                                      00260039
OPNDNXT  EQU   *                                                        00270010
OPND     EQU   OPNDDS,*-OPNDDS                                          00280010
MVSASMCM CSECT                                                          00290000
         USING MVSASMCM,R15                                             00300000
         B     BEGIN                                                    00310000
         DROP  R15                                                      00320000
         DC    AL1(L'PGMID)                                             00330000
PGMID    DC    C'MVSASMCM - &SYSDATE &SYSTIME'                          00340000
BEGIN    DC    0H'+0'                                                   00350000
*********************************************************************** 00360000
*        Initialize                                                   * 00370000
*********************************************************************** 00380000
         STM   R14,R12,12(R13)                                          00390000
         LR    R12,R15                                                  00400000
         LA    R11,2048(,R12)                                           00410001
         LA    R11,2048(,R11)                                           00420001
         USING MVSASMCM,R12,R11                                         00430001
         LA    R14,SAVEAREA                                             00440000
         ST    R13,4(,R14)                                              00450000
         ST    R14,8(,R13)                                              00460000
         LR    R13,R14                                                  00470000
         L     R9,0(,R1)                                                00480000
         OPEN  (SYSPRINT,(OUTPUT),                                     *00490001
               SYSUT1,(INPUT),                                         *00500001
               SYSUT2,(INPUT),                                         *00510001
               CHANGES,(OUTPUT))                                        00520001
         TM    SYSPRINT+48,16                                           00530000
         BNO   QUIT                                                     00540000
         TM    SYSUT1+48,16                                             00550000
         BNO   QUIT                                                     00560000
         TM    SYSUT2+48,16                                             00570000
         BNO   QUIT                                                     00580000
         TIME  BIN                     GET CURRENT DATE AND TIME        00590000
         ST    R1,CURDATE              SAVE DATE                        00600000
         SRDL  R0,32                   GET DOUBLE WORD TIME             00610000
         D     R0,=F'+6000'            GET MINUTES                      00620000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00630000
         SLR   R0,R0                   CLEAR                            00640000
         D     R0,=F'+60'              GET HOURS / MINS                 00650000
         MH    R0,=H'+10000'           GET MINUTES                      00660000
         AR    R15,R0                  ADD TO GET MM:SS.TH              00670000
         M     R0,=F'+1000000'         GET HOURS                        00680000
         AR    R1,R15                  GET HH:MM:SS.TH                  00690000
         CVD   R1,DWORD                GET TIME TO DECIMAL              00700000
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   00710000
         ED    TIMWRK4,DWORD+3         EDIT TIME                        00720000
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        00730000
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  00740000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    00750000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         00760000
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        00770000
         DP    DWORD,=P'+4'            DIVIDE BY 4                      00780000
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              00790000
         BNZ   JULCVT2                  NO                              00800000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    00810000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         00820000
JULCVT2  DS    0H                                                       00830000
         LA    R1,JULTBL1              POINT TO JANUARY                 00840000
         SLR   R2,R2                   SET COUNTER                      00850000
JULCVT4  DS    0H                                                       00860000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              00870000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  00880000
         BCTR  R1,0                    POINT TO NEXT MONTH              00890000
         BCTR  R1,0                    POINT TO NEXT MONTH              00900000
         LA    R2,3(,R2)               UP INDEX                         00910000
         B     JULCVT4                 LOOP                             00920000
JULCVT6  DS    0H                                                       00930000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                00940000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    00950000
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       00960000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     00970000
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         00980000
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   00990000
         LA    R1,HD1DATE+6            SET POINTER                      01000000
         BNE   JULCVT7                  NO                              01010000
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 01020000
         BCTR  R1,0                    DROP POINTER                     01030000
JULCVT7  DS    0H                                                       01040000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  01050000
         TM    CURDATE,1               YEAR 2000?                       01060000
         BNO   JULCVT8                  NO, CONTINUE                    01070000
         MVC   2(2,R1),=C'20'          Y2K                              01080000
JULCVT8  DS    0H                                                       01090000
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      01100000
         MVC   4(2,R1),DWORD           GET YEAR                         01110000
         MVC   LINE+1(16),=C'Program version='                          01120034
         MVC   LINE+17(L'PGMID),PGMID                                   01130034
         BAL   R14,PRT                                                  01140034
         MVC   LINE+1(5),=C'Parm='                                      01150000
         CLI   1(R9),0                                                  01160000
         BE    INITPRPA                                                 01170000
         LH    R1,0(,R9)                                                01180000
         BCTR  R1,0                                                     01190000
         EX    R1,INITPRMV                                              01200000
         B     INITPRPA                                                 01210000
INITPRMV MVC   LINE+6(0),2(R9)                                          01220000
INITPRPA DS    0H                                                       01230000
         BAL   R14,PRT                                                  01240000
         LH    R2,0(,R9)                                                01250000
         LA    R9,2(,R9)                                                01260000
INITPRSC DS    0H                                                       01270000
         LTR   R2,R2                                                    01280000
         BE    INITPRZ                                                  01290000
         CLI   0(R9),C','                                               01300000
         BNE   INITPRCK                                                 01310000
INITPRCO DS    0H                                                       01320000
         LA    R9,1(,R9)                                                01330000
         BCTR  R2,0                                                     01340000
         B     INITPRSC                                                 01350000
INITPRCK DS    0H                                                       01360000
         CH    R2,=H'+2'                                                01370000
         BL    INITPRER                                                 01380000
         CLC   =C'OP',0(R9)                                             01390000
         BE    INITPROP                                                 01400000
         CH    R2,=H'+3'                                                01410000
         BL    INITPRER                                                 01420000
         CLC   =C'REG',0(R9)                                            01430000
         BE    INITPRRG                                                 01440000
         CH    R2,=H'+5'                                                01450000
         BL    INITPRER                                                 01460000
         CLC   =C'DEBUG',0(R9)                                          01470000
         BE    INITPRDB                                                 01480000
         CH    R2,=H'+6'                                                01490033
         BL    INITPRER                                                 01500033
         CLC   =C'NEWINS',0(R9)                                         01510033
         BE    INITPRNI                                                 01520033
         CH    R2,=H'+7'                                                01530003
         BL    INITPRER                                                 01540003
         CLC   =C'VERBOSE',0(R9)                                        01550003
         BE    INITPRVR                                                 01560003
         CLC   =C'CHANGES',0(R9)                                        01570032
         BE    INITPRCH                                                 01580032
         CH    R2,=H'+8'                                                01590017
         BL    INITPRER                                                 01600017
         CLC   =C'NOHEXINS',0(R9)                                       01610017
         BE    INITPRNH                                                 01620017
         B     INITPRER                                                 01630000
INITPROP DS    0H                                                       01640000
         OI    FLAG,FLAGOP                                              01650000
         LA    R9,2(,R9)                                                01660000
         SH    R2,=H'+2'                                                01670000
         B     INITPRNX                                                 01680000
INITPRRG DS    0H                                                       01690000
         OI    FLAG,FLAGREG                                             01700000
         LA    R9,3(,R9)                                                01710000
         SH    R2,=H'+3'                                                01720000
         B     INITPRNX                                                 01730000
INITPRDB DS    0H                                                       01740000
         CH    R2,=H'+10'                                               01750007
         BL    INITPRDC                                                 01760007
         CLC   =C'DEBUG(REG)',0(R9)                                     01770007
         BNE   INITPRDC                                                 01780007
         OI    FLAG,FLAGDBR                                             01790007
         LA    R9,10(,R9)                                               01800007
         SH    R2,=H'+10'                                               01810007
         B     INITPRNX                                                 01820007
INITPRDC DS    0H                                                       01830007
         OI    FLAG,FLAGDBG                                             01840000
         LA    R9,5(,R9)                                                01850000
         SH    R2,=H'+5'                                                01860000
         B     INITPRNX                                                 01870000
INITPRVR DS    0H                                                       01880003
         OI    FLAG,FLAGVER                                             01890003
         LA    R9,7(,R9)                                                01900003
         SH    R2,=H'+7'                                                01910003
         B     INITPRNX                                                 01920003
INITPRCH DS    0H                                                       01930032
         OI    FLAG,FLAGCHGS                                            01940032
         LA    R9,7(,R9)                                                01950032
         SH    R2,=H'+7'                                                01960032
         B     INITPRNX                                                 01970032
INITPRNH DS    0H                                                       01980017
         OI    FLAG,FLAGNOHX                                            01990017
         LA    R9,8(,R9)                                                02000017
         SH    R2,=H'+8'                                                02010017
         B     INITPRNX                                                 02020017
INITPRNI DS    0H                                                       02030033
         OI    FLAG1,FLAG1NWI                                           02040033
         LA    R9,6(,R9)                                                02050033
         SH    R2,=H'+6'                                                02060033
         B     INITPRNX                                                 02070033
INITPRNX DS    0H                                                       02080000
         LTR   R2,R2                                                    02090000
         BZ    INITPRZ                                                  02100000
         CLI   0(R9),C','                                               02110000
         BE    INITPRCO                                                 02120000
INITPRER DS    0H                                                       02130000
         MVC   LINE+1(33),=C'PARM= contained invalid parameter'         02140000
         BAL   R14,PRT                                                  02150000
         B     QUIT                                                     02160000
INITPRZ  DS    0H                                                       02170000
*********************************************************************** 02180000
*        Mainline                                                     * 02190000
*********************************************************************** 02200000
PROC     DS    0H                                                       02210000
         BAL   R14,GETUT1                                               02220000
         BAL   R14,GETUT2                                               02230000
PROCMAT  DS    0H                                                       02240000
         TM    FLAG,FLAGDBG                                             02250000
         BNO   PROCMAT1                                                 02260000
         UNPK  LINE+1(9),UT1ADR(5)                                      02270006
         NC    LINE+1(8),=X'0F0F0F0F0F0F0F0F'                           02280006
         TR    LINE+1(8),=C'0123456789ABCDEF'                           02290006
         MVI   LINE+9,C' '                                              02300006
         UNPK  LINE+10(9),UT2ADR(5)                                     02310006
         NC    LINE+10(8),=X'0F0F0F0F0F0F0F0F'                          02320006
         TR    LINE+10(8),=C'0123456789ABCDEF'                          02330006
         MVI   LINE+18,C' '                                             02340006
         MVC   LINE+20(20),RECUT1+1                                     02350006
         MVC   LINE+42(20),RECUT2+1                                     02360006
         MVC   LINE+66(12),=C'<<matching>>'                             02370006
         BAL   R14,PRT                                                  02380006
PROCMAT1 DS    0H                                                       02390000
         CLC   UT1ADR,UT2ADR                                            02400000
         BE    PROCEQAD                                                 02410019
         BH    PROCHI                                                   02420000
         BAL   R14,GETUT1                                               02430000
         B     PROCMAT                                                  02440000
PROCHI   DS    0H                                                       02450000
         BAL   R14,GETUT2                                               02460000
         B     PROCMAT                                                  02470000
*                                                                       02480000
* Assembler output we look at                                           02490000
*                                                                       02500000
* 00001C 07FE                                                           02510000
* 000000 47F0 F016                                                      02520000
* 000264 D74F C2A7 C2A7 032C0 032C0                                     02530010
*                                                                       02540000
*          1         2         3                                        02550010
*0123456789012345678901234567890123                                     02560010
*                                                                       02570000
PROCEQAD DS    0H                                                       02580019
         NI    FLAG,255-FLAGCHG                                         02590007
         MVI   DIFLINE,C' '                                             02600002
         MVC   DIFLINE+1(L'DIFLINE-1),DIFLINE                           02610002
         MVC   CHGREC,RECUT1+41       Copy original rec to change rec   02620021
         MVC   CHGREC+64(7),=C'DSKZZZZ'                                 02630006
         TM    FLAG,FLAGREG                                             02640000
         BO    PROCRG                                                   02650000
* OPCODE                                                                02660002
         CLC   RECUT1+8(2),RECUT2+8                                     02670019
         BE    PROCOPB                                                  02680019
         AP    DIFCT,=P'+1'                                             02690019
         CLC   RECUT1+8(1),RECUT2+8                                     02700002
         BE    PROCOPA                                                  02710019
         MVI   DIFLINE+8,C'*'                                           02720002
PROCOPA  DS    0H                                                       02730019
         CLC   RECUT1+9(1),RECUT2+9                                     02740002
         BE    PROCOPB                                                  02750019
         MVI   DIFLINE+9,C'*'                                           02760002
PROCOPB  DS    0H                                                       02770019
         TM    FLAG,FLAGOP             Opcode compare only?             02780018
         BO    PROCOPZ                 Yes, done with comparing         02790018
* LEN/REGS/IMMEDIATE/MASK etc.                                          02800019
         CLC   RECUT1+10(1),RECUT2+10                                   02810002
         BE    PROCALC                                                  02820002
         MVI   DIFLINE+10,C'*'                                          02830002
         AP    DIFCT,=P'+1'                                             02840005
PROCALC  DS    0H                                                       02850002
         CLC   RECUT1+11(1),RECUT2+11                                   02860002
         BE    PROCALD                                                  02870002
         MVI   DIFLINE+11,C'*'                                          02880002
         AP    DIFCT,=P'+1'                                             02890005
PROCALD  DS    0H                                                       02900002
* OPERAND 1                                                             02910002
         CLC   RECUT1+13(1),RECUT2+13                                   02920002
         BE    PROCOP1A                                                 02930019
         MVI   DIFLINE+13,C'*'                                          02940002
         AP    DIFCT,=P'+1'                                             02950005
PROCOP1A DS    0H                                                       02960019
         CLC   RECUT1+14(1),RECUT2+14                                   02970002
         BE    PROCOP1B                                                 02980019
         MVI   DIFLINE+14,C'*'                                          02990002
         AP    DIFCT,=P'+1'                                             03000005
PROCOP1B DS    0H                                                       03010019
         CLC   RECUT1+15(1),RECUT2+15                                   03020002
         BE    PROCOP1C                                                 03030019
         MVI   DIFLINE+15,C'*'                                          03040002
         AP    DIFCT,=P'+1'                                             03050005
PROCOP1C DS    0H                                                       03060019
         CLC   RECUT1+16(1),RECUT2+16                                   03070002
         BE    PROCOP1D                                                 03080019
         MVI   DIFLINE+16,C'*'                                          03090002
         AP    DIFCT,=P'+1'                                             03100005
PROCOP1D DS    0H                                                       03110019
         CLC   RECUT1+13(4),RECUT2+13                                   03120010
         BE    PROCOP1H                                                 03130019
         LA    R2,2                                                     03140010
         LA    R1,RECUT2+13                                             03150018
         BAL   R14,HEXCVT                                               03160010
         LTR   R15,R15                                                  03170010
         BNZ   ERROP1                                                   03180010
         ST    R0,UT2OP1                                                03190010
         L     R15,OPNDTBA                                              03200010
PROCOP1E DS    0H                                                       03210019
         C     R15,OPNDEND                                              03220010
         BNL   PROCOP1F                                                 03230019
         USING OPND,R15                                                 03240010
         CLC   OPNDNBDD,RECUT1+13                                       03250026
         BE    PROCOP1G                                                 03260019
         LA    R15,OPNDNXT                                              03270010
         B     PROCOP1E                                                 03280019
PROCOP1F DS    0H                                                       03290019
         C     R15,OPNDMAX                                              03300010
         BNL   PROCOP1H                                                 03310019
         MVC   OPNDOBDD,RECUT2+13                                       03320026
         MVC   OPNDNBDD,RECUT1+13                                       03330026
         MVC   OPNDDISP,RECUT1+23                                       03340025
         MVC   OPNDNSQ1,=CL8' '                                         03350039
         MVC   OPNDNSQ2,=CL8' '                                         03360039
         MVC   OPNDNSQ3,=CL8' '                                         03370039
         MVC   OPNDNSQ4,=CL8' '                                         03380039
         MVC   OPNDNSQ5,=CL8' '                                         03390039
         MVC   OPNDNSQ6,=CL8' '                                         03400039
         MVC   OPNDNSQ7,=CL8' '                                         03410039
         MVC   OPNDNSQ8,=CL8' '                                         03420039
         XC    OPNDNUM,OPNDNUM                                          03430010
         BAL   R14,SRKY                                                 03440024
         LA    R14,OPNDNXT                                              03450010
         ST    R14,OPNDEND                                              03460010
         LH    R1,SRTNUM                                                03470010
         LA    R1,1(,R1)                                                03480010
         STH   R1,SRTNUM                                                03490010
PROCOP1G DS    0H                                                       03500019
         ICM   R1,3,OPNDNUM                                             03510010
         LA    R1,1(,R1)                                                03520010
         STCM  R1,3,OPNDNUM                                             03530010
         LA    R0,8                                                     03540039
         LA    R1,OPNDNSQ1                                              03550039
PROCOP1I DS    0H                                                       03560039
         CLI   0(R1),C' '                                               03570039
         BE    PROCOP1J                                                 03580039
         LA    R1,8(,R1)                                                03590039
         BCT   R0,PROCOP1I                                              03600039
         B     PROCOP1H                                                 03610039
PROCOP1J DS    0H                                                       03620039
         MVC   0(8,R1),RECUT1+41+72                                     03630039
PROCOP1H DS    0H                                                       03640019
         DROP  R15                                                      03650010
* OPERAND 2                                                             03660002
         CLC   RECUT1+18(1),RECUT2+18                                   03670002
         BE    PROCOP2A                                                 03680019
         MVI   DIFLINE+18,C'*'                                          03690002
         AP    DIFCT,=P'+1'                                             03700005
PROCOP2A DS    0H                                                       03710019
         CLC   RECUT1+19(1),RECUT2+19                                   03720002
         BE    PROCOP2B                                                 03730019
         MVI   DIFLINE+19,C'*'                                          03740002
         AP    DIFCT,=P'+1'                                             03750005
PROCOP2B DS    0H                                                       03760019
         CLC   RECUT1+20(1),RECUT2+20                                   03770002
         BE    PROCOP2C                                                 03780019
         MVI   DIFLINE+20,C'*'                                          03790002
         AP    DIFCT,=P'+1'                                             03800005
PROCOP2C DS    0H                                                       03810019
         CLC   RECUT1+21(1),RECUT2+21                                   03820002
         BE    PROCOP2D                                                 03830019
         MVI   DIFLINE+21,C'*'                                          03840002
         AP    DIFCT,=P'+1'                                             03850005
PROCOP2D DS    0H                                                       03860019
         CLC   RECUT1+18(4),RECUT2+18                                   03870010
         BE    PROCOP2H                                                 03880019
         LA    R2,2                                                     03890010
         LA    R1,RECUT2+30                                             03900010
         BAL   R14,HEXCVT                                               03910010
         LTR   R15,R15                                                  03920010
         BNZ   ERROP2                                                   03930010
         ST    R0,UT2OP2                                                03940010
         L     R15,OPNDTBA                                              03950010
PROCOP2E DS    0H                                                       03960019
         C     R15,OPNDEND                                              03970010
         BNL   PROCOP2F                                                 03980019
         USING OPND,R15                                                 03990010
         CLC   OPNDNBDD,RECUT1+18                                       04000026
         BE    PROCOP2G                                                 04010019
         LA    R15,OPNDNXT                                              04020010
         B     PROCOP2E                                                 04030019
PROCOP2F DS    0H                                                       04040019
         C     R15,OPNDMAX                                              04050010
         BNL   PROCOP2H                                                 04060019
         MVC   OPNDOBDD,RECUT2+18                                       04070026
         MVC   OPNDNBDD,RECUT1+18                                       04080026
         MVC   OPNDDISP,RECUT1+29                                       04090025
         MVC   OPNDNSQ1,=CL8' '                                         04100039
         MVC   OPNDNSQ2,=CL8' '                                         04110039
         MVC   OPNDNSQ3,=CL8' '                                         04120039
         MVC   OPNDNSQ4,=CL8' '                                         04130039
         MVC   OPNDNSQ5,=CL8' '                                         04140039
         MVC   OPNDNSQ6,=CL8' '                                         04150039
         MVC   OPNDNSQ7,=CL8' '                                         04160039
         MVC   OPNDNSQ8,=CL8' '                                         04170039
         XC    OPNDNUM,OPNDNUM                                          04180010
         BAL   R14,SRKY                                                 04190024
         LA    R14,OPNDNXT                                              04200010
         ST    R14,OPNDEND                                              04210010
         LH    R1,SRTNUM                                                04220010
         LA    R1,1(,R1)                                                04230010
         STH   R1,SRTNUM                                                04240010
PROCOP2G DS    0H                                                       04250019
         ICM   R1,3,OPNDNUM                                             04260010
         LA    R1,1(,R1)                                                04270010
         STCM  R1,3,OPNDNUM                                             04280010
         LA    R0,8                                                     04290039
         LA    R1,OPNDNSQ1                                              04300039
PROCOP2I DS    0H                                                       04310039
         CLI   0(R1),C' '                                               04320039
         BE    PROCOP2J                                                 04330039
         LA    R1,8(,R1)                                                04340039
         BCT   R0,PROCOP2I                                              04350039
         B     PROCOP2H                                                 04360039
PROCOP2J DS    0H                                                       04370039
         MVC   0(8,R1),RECUT1+41+72                                     04380039
PROCOP2H DS    0H                                                       04390019
         DROP  R15                                                      04400010
         CLC   DIFLINE+1(L'DIFLINE-1),DIFLINE                           04410002
         BE    SAME                                                     04420003
         B     DIFF                                                     04430002
PROCOPZ  DS    0H                                                       04440018
         CLC   DIFLINE+1(L'DIFLINE-1),DIFLINE                           04450018
         BE    SAME                                                     04460018
         OI    FLAG,FLAGCHG                                             04470018
         B     DIFF                                                     04480018
*                                                                       04490002
*                                                                       04500002
*                                                                       04510002
PROCRG   DS    0H                                                       04520000
*                                                                       04530006
* 00001C 07FE                                                           04540006
* 000000 47F0 F016                                                      04550006
* 000264 D202 8200 503C                                                 04560006
*                                                                       04570006
*          1         2                                                  04580006
*0123456789012345678901                                                 04590006
*                                                                       04600006
* OPCODE                                                                04610002
         CLC   RECUT1+8(1),RECUT2+8                                     04620002
         BE    PROCRGA                                                  04630002
         MVI   DIFLINE+8,C'*'                                           04640002
         AP    DIFCT,=P'+1'                                             04650005
PROCRGA  DS    0H                                                       04660002
         CLC   RECUT1+9(1),RECUT2+9                                     04670002
         BE    PROCRGB                                                  04680002
         MVI   DIFLINE+9,C'*'                                           04690002
         AP    DIFCT,=P'+1'                                             04700005
         B     PROCRGF                                                  04710006
PROCRGB  DS    0H                                                       04720002
         CLI   DIFLINE+8,C'*'                                           04730006
         BE    PROCRGF                                                  04740006
         LA    R9,CHGREC                                                04750006
PROCRGOA DS    0H                                                       04760006
*        SCAN FOR OPERAND 1                                             04770006
         CLI   0(R9),C' '                                               04780006
         BE    PROCRGOB                                                 04790006
         LA    R9,1(,R9)                                                04800006
         B     PROCRGOA                                                 04810006
PROCRGOB DS    0H                                                       04820006
*        FIND OPCODE                                                    04830006
         CLI   0(R9),C' '                                               04840006
         BNE   PROCRGOC                                                 04850006
         LA    R9,1(,R9)                                                04860006
         B     PROCRGOB                                                 04870006
PROCRGOC DS    0H                                                       04880006
*        HAVE OPCODE, FIND OPERAND 1                                    04890006
         CLI   0(R9),C' '                                               04900006
         BNE   PROCRGOD                                                 04910006
         LA    R9,1(,R9)                                                04920006
         B     PROCRGOC                                                 04930006
PROCRGOD DS    0H                                                       04940006
*        FOUND OPERAND 1                                                04950006
* LEN/REGS/IMMEDIATE                                                    04960002
         CLI   RECUT1+13,C' '            RR INSTR                       04970006
         BE    PROCRGBA                  YES                            04980006
         CLI   RECUT1+8,C'F'             HIGH HEX DIGIT                 04990006
         BNH   PROCRGD                   YES SKIP IT                    05000006
         CLI   RECUT1+8,C'9'             RS INSTR                       05010006
         BE    PROCRGBA                  YES                            05020006
         CLI   RECUT1+8,C'8'             RX INSTR                       05030022
         BH    PROCRGD                   NO                             05040006
* REGS IN SECOND BYTE                                                   05050006
PROCRGBA DS    0H                                                       05060006
         CLC   RECUT1+10(1),RECUT2+10                                   05070000
         BE    PROCRGC                                                  05080002
         MVI   DIFLINE+10,C'*'                                          05090002
         AP    DIFCT,=P'+1'                                             05100005
         LA    R1,RECUT2+10                                             05110021
         LA    R2,DIFLINE+10                                            05120006
         LA    R15,RECUT1+10                                            05130021
         BAL   R14,CHGREG                                               05140006
PROCRGC  DS    0H                                                       05150002
         CLC   RECUT1+11(1),RECUT2+11                                   05160000
         BE    PROCRGD                                                  05170002
         MVI   DIFLINE+11,C'*'                                          05180002
         AP    DIFCT,=P'+1'                                             05190005
         LA    R1,RECUT2+11                                             05200021
         LA    R2,DIFLINE+11                                            05210006
         LA    R15,RECUT1+11                                            05220021
         BAL   R14,CHGREG                                               05230006
PROCRGD  DS    0H                                                       05240002
* OPERAND 1 REG                                                         05250002
         CLI   RECUT1+13,C' '            RR INSTR                       05260006
         BE    PROCRGF                                                  05270006
         CLC   RECUT1+13(1),RECUT2+13                                   05280000
         BE    PROCRGE                                                  05290002
         MVI   DIFLINE+13,C'*'                                          05300002
         AP    DIFCT,=P'+1'                                             05310005
         LA    R1,RECUT2+13                                             05320021
         LA    R2,DIFLINE+13                                            05330006
         LA    R15,RECUT1+13                                            05340021
         BAL   R14,CHGREG                                               05350006
PROCRGE  DS    0H                                                       05360002
* OPERAND 2 REG                                                         05370002
         CLC   RECUT1+18(1),RECUT2+18                                   05380000
         BE    PROCRGF                                                  05390002
         MVI   DIFLINE+18,C'*'                                          05400002
         AP    DIFCT,=P'+1'                                             05410005
         LA    R1,RECUT2+18                                             05420021
         LA    R2,DIFLINE+18                                            05430006
         LA    R15,RECUT1+18                                            05440021
         BAL   R14,CHGREG                                               05450006
PROCRGF  DS    0H                                                       05460002
         CLC   DIFLINE+1(L'DIFLINE-1),DIFLINE                           05470002
         BE    SAME                                                     05480003
         B     DIFF                                                     05490003
* INSTRUCTIONS ARE EQUAL                                                05500003
SAME     DS    0H                                                       05510003
         TM    FLAG,FLAGVER                                             05520003
         BNO   PROC                                                     05530003
         MVC   LINE+1(132),RECUT1+1                                     05540003
         BAL   R14,PRT                                                  05550003
         MVC   LINE,DIFLINE                                             05560003
         BAL   R14,PRT                                                  05570003
         MVC   LINE+1(132),RECUT2+1                                     05580003
         BAL   R14,PRT                                                  05590003
         BAL   R14,PRT                                                  05600003
         B     PROC                                                     05610003
DIFF     DS    0H                                                       05620000
         CP    LNCT,=P'+58'            END OF PAGE NEAR                 05630019
         BL    DIFF05                   NO                              05640019
         MVI   LINE,C'1'                                                05650019
DIFF05   DS    0H                                                       05660019
         AP    LINDIFCT,=P'+1'                                          05670008
         MVC   LINE+1(132),RECUT1+1                                     05680000
         TM    FLAG1,FLAG1NWI                                           05690033
         BNO   DIFF07                                                   05700033
         CLI   LINE+88,C' '                                             05710033
         BNE   DIFF07                                                   05720033
         CLC   LINE+89(15),LINE+88                                      05730033
         BNE   DIFF07                                                   05740033
         MVC   LINE+88(15),RECUT2+8                                     05750033
DIFF07   DS    0H                                                       05760033
         BAL   R14,PRT                                                  05770000
         MVC   LINE,DIFLINE                                             05780002
         BAL   R14,PRT                                                  05790000
         MVC   LINE+1(132),RECUT2+1                                     05800000
DIFF10   DS    0H                                                       05810002
         TM    CHANGES+48,16                                            05820006
         BNO   DIFF90                                                   05830006
         TM    FLAG,FLAGCHGS                                            05840032
         BO    DIFF83                                                   05850032
         TM    FLAG,FLAGCHG                                             05860007
         BNO   DIFF90                                                   05870007
         TM    FLAG,FLAGNOHX                                            05880017
         BO    DIFF89                                                   05890017
* PLUGIN THE CORRECT INSTRUCTION AS WILL FIT                            05900006
         LA    R1,CHGREC+43                                             05910006
         LA    R15,RECUT1+3                                             05920006
         LA    R14,20-1                                                 05930006
DIFF80   DS    0H                                                       05940006
         CLI   0(R1),C' '                                               05950006
         BE    DIFF82                                                   05960006
         LA    R1,1(,R1)                                                05970006
         LA    R15,1(,R15)                                              05980006
         BCT   R14,DIFF80                                               05990006
         B     DIFF89                                                   06000006
DIFF81   MVC   1(,R1),0(R15)                                            06010006
DIFF82   DS    0H                                                       06020006
         EX    R14,DIFF81                                               06030006
         B     DIFF89                                                   06040032
DIFF83   DS    0H                                                       06050032
         MVC   CHGREC,RECUT2+41        Copy new rec to change rec       06060032
         MVC   CHGREC+64(7),=C'DSKZZZZ'                                 06070032
         MVC   CHGREC+72(8),RECUT1+113 copy old sequence number         06080032
DIFF89   DS    0H                                                       06090006
         PUT   CHANGES,CHGREC                                           06100006
DIFF90   DS    0H                                                       06110006
         BAL   R14,PRT                                                  06120000
         BAL   R14,PRT                                                  06130000
         B     PROC                                                     06140000
*********************************************************************** 06150000
*        Termination                                                  * 06160000
*********************************************************************** 06170000
ERROP1   DS    0H                                                       06180010
         MVC   LINE+1(132),RECUT2+1                                     06190035
         BAL   R14,PRT                                                  06200035
         MVC   LINE+13(24),=C'|||| Unmatched operand 1'                 06210035
         MVC   LINE+38(33),=C'- Instruction formats don''t match'       06220035
         B     ERROP                                                    06230010
ERROP2   DS    0H                                                       06240010
         MVC   LINE+1(132),RECUT2+1                                     06250035
         BAL   R14,PRT                                                  06260035
         MVC   LINE+18(24),=C'|||| Unmatched operand 2'                 06270035
         MVC   LINE+42(33),=C'- Instruction formats don''t match'       06280035
ERROP    DS    0H                                                       06290010
         BAL   R14,PRT                                                  06300010
         MVC   LINE+1(132),RECUT1+1                                     06310035
         BAL   R14,PRT                                                  06320010
         BAL   R14,PRT                                                  06330035
*        LA    R2,8                                                     06340035
         B     PROC                                                     06350035
EODUT1   DS    0H                                                       06360000
         TM    FLAG,FLAGDBG                                             06370036
         BNO   EODUT1A                                                  06380036
         MVC   LINE+1(15),=C'End file SYSUT1'                           06390036
         BAL   R14,PRT                                                  06400036
EODUT1A  DS    0H                                                       06410036
         LA    R2,0                                                     06420000
         B     EXIT                                                     06430000
EODUT2   DS    0H                                                       06440000
         TM    FLAG,FLAGDBG                                             06450036
         BNO   EODUT2A                                                  06460037
         MVC   LINE+1(15),=C'End file SYSUT2'                           06470036
         BAL   R14,PRT                                                  06480036
EODUT2A  DS    0H                                                       06490037
         LA    R2,0                                                     06500000
         B     EXIT                                                     06510000
EXIT     DS    0H                                                       06520000
         ICM   R0,3,SRTNUM                                              06530010
         BZ    EXITOPN9                                                 06540010
         TM    FLAG,FLAGDBG                                             06550028
         BNO   EXITNDTB                                                 06560028
         BAL   R14,PRT                                                  06570028
         MVC   LINE+1(21),=C'Dump of Operand Table'                     06580028
         BAL   R14,PRT                                                  06590028
         L     R3,OPNDTBA                                               06600028
         LH    R4,SRTNUM                                                06610028
EXITDTB  DS    0H                                                       06620028
         LR    R1,R3                                                    06630028
         LA    R0,L'OPND                                                06640028
         AR    R3,R0                                                    06650028
         BAL   R14,DMP                                                  06660028
         BCT   R4,EXITDTB                                               06670028
         BAL   R14,PRT                                                  06680028
EXITNDTB DS    0H                                                       06690028
         LA    R0,L'OPND                                                06700010
         STH   R0,SRTLEN                                                06710010
         LA    R0,L'OPNDKEY                                             06720010
         STH   R0,SRTKLN                                                06730010
         LA    R0,OPNDKEY-OPND                                          06740010
         STH   R0,SRTKOF                                                06750010
         L     R0,OPNDTBA                                               06760010
         LA    R1,SRTDSC                                                06770010
         STM   R0,R1,SRTPRM                                             06780010
         LA    R1,SRTPRM                                                06790010
         L     R15,=A(SORT)                                             06800010
         BALR  R14,R15                                                  06810013
         LTR   R15,R15                                                  06820010
         BNZ   EXITSRER                                                 06830038
         LR    R9,R2                                                    06840025
         MVI   LINE,C'1'                                                06850031
         MVC   LINE+12(26),=C'By Displacement Difference'               06860025
         BAL   R14,PRT                                                  06870025
         BAL   R14,RPT                                                  06880025
         BAL   R14,PRT                                                  06890025
         LH    R0,SRTNUM                                                06900010
         CVD   R0,DWORD                                                 06910010
         MVC   LINE+1(13),=C'Incorrect DDD'                             06920010
         MVC   LINE+14(7),=X'4B20206B202120'                            06930034
         ED    LINE+14(7),DWORD+5                                       06940034
         CVD   R4,DWORD                                                 06950010
         MVC   LINE+27(15),=C'Total incorrect'                          06960034
         MVC   LINE+42(7),=X'4B20206B202120'                            06970034
         ED    LINE+42(7),DWORD+5                                       06980034
         BAL   R14,PRT                                                  06990010
*                                                                       07000038
         LA    R0,L'OPNDKEY1                                            07010031
         STH   R0,SRTKLN                                                07020025
         LA    R0,OPNDKEY1-OPND                                         07030031
         STH   R0,SRTKOF                                                07040025
         LA    R1,SRTPRM                                                07050025
         L     R15,=A(SORT)                                             07060025
         BALR  R14,R15                                                  07070025
         LTR   R15,R15                                                  07080025
         BNZ   EXITSRER                                                 07090038
         MVI   LINE,C'1'                                                07100031
         MVC   LINE+12(15),=C'By Original DDD'                          07110028
         BAL   R14,PRT                                                  07120025
         BAL   R14,RPT                                                  07130025
         BAL   R14,PRT                                                  07140025
         LR    R2,R9                                                    07150023
         B     EXITOPN9                                                 07160038
EXITSRER DS    0H                                                       07170038
         STM   R15,R1,SRTRC                                             07180038
         MVC   LINE+1(11),=C'SORT failed'                               07190038
         UNPK  LINE+13(9),SRTRC(5)                                      07200038
         NC    LINE+13(8),=X'0F0F0F0F0F0F0F0F'                          07210038
         TR    LINE+13(8),=C'0123456789ABCDEF'                          07220038
         MVI   LINE+21,C' '                                             07230038
         UNPK  LINE+22(9),SRTRC+4(5)                                    07240038
         NC    LINE+22(8),=X'0F0F0F0F0F0F0F0F'                          07250038
         TR    LINE+22(8),=C'0123456789ABCDEF'                          07260038
         MVI   LINE+30,C' '                                             07270038
         UNPK  LINE+31(9),SRTRC+8(5)                                    07280038
         NC    LINE+31(8),=X'0F0F0F0F0F0F0F0F'                          07290038
         TR    LINE+31(8),=C'0123456789ABCDEF'                          07300038
         MVI   LINE+39,C' '                                             07310038
         BAL   R14,PRT                                                  07320038
         LA    R2,8                                                     07330038
EXITOPN9 DS    0H                                                       07340010
         BAL   R14,PRT                                                  07350010
         MVC   LINE+1(14),=C'SYSUT1 records'                            07360000
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07370000
         ED    LINE+20(12),UT1CT                                        07380000
         BAL   R14,PRT                                                  07390000
         MVC   LINE+1(14),=C'  instructions'                            07400003
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07410003
         ED    LINE+20(12),UT1INCT                                      07420003
         BAL   R14,PRT                                                  07430003
         MVC   LINE+1(14),=C'SYSUT2 records'                            07440000
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07450000
         ED    LINE+20(12),UT2CT                                        07460000
         BAL   R14,PRT                                                  07470000
         MVC   LINE+1(14),=C'  instructions'                            07480003
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07490003
         ED    LINE+20(12),UT2INCT                                      07500003
         BAL   R14,PRT                                                  07510003
         MVC   LINE+1(15),=C'Lines with diffs'                          07520008
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07530000
         ED    LINE+20(12),LINDIFCT                                     07540008
         BAL   R14,PRT                                                  07550000
         MVC   LINE+1(11),=C'Differences'                               07560008
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07570008
         ED    LINE+20(12),DIFCT                                        07580008
         BAL   R14,PRT                                                  07590008
         MVC   LINE+1(11),=C'Return code'                               07600000
         MVC   LINE+20(12),=X'402020206B2020206B202120'                 07610000
         CVD   R2,DWORD                                                 07620000
         ED    LINE+20(12),DWORD+3                                      07630000
         BAL   R14,PRT                                                  07640000
         CLOSE (SYSPRINT,,SYSUT1,,SYSUT2,,CHANGES)                      07650001
RETURN   DS    0H                                                       07660000
         L     R13,4(,R13)                                              07670000
         L     R14,12(,R13)                                             07680000
         LR    R15,R2                                                   07690000
         LM    R0,R12,20(R13)                                           07700000
         BR    R14                                                      07710000
QUIT     DS    0H                                                       07720000
         LA    R2,16                                                    07730000
         B     RETURN                                                   07740000
*********************************************************************** 07750000
*        Subroutines                                                  * 07760000
*********************************************************************** 07770000
*                                                                       07780000
*        Read SYSUT1 record                                             07790000
*                                                                       07800000
GETUT1   DS    0H                                                       07810000
         ST    R14,GETUT114                                             07820000
GETUT11  DS    0H                                                       07830000
         GET   SYSUT1,RECUT1                                            07840000
         AP    UT1CT,=P'+1'                                             07850000
         TM    FLAG,FLAGDBG                                             07860000
         BNO   GETUT12                                                  07870000
         MVC   LINE+1(8),=C'SYSUT1 -'                                   07880006
         MVC   LINE+10(120),RECUT1+1                                    07890006
         BAL   R14,PRT                                                  07900006
GETUT12  DS    0H                                                       07910000
         CLI   RECUT1+7,C' '                                            07920000
         BNE   ERRUT1IN                                                 07930000
         CLI   RECUT1+12,C' '                                           07940000
         BNE   ERRUT1IN                                                 07950000
         CLI   RECUT1+17,C' '                                           07960000
         BNE   ERRUT1IN                                                 07970000
         CLI   RECUT1+22,C' '                                           07980000
         BNE   ERRUT1IN                                                 07990000
         CLC   RECUT1+49(4),=C' DC '                                    08000001
         BE    ERRUT1IN                                                 08010004
         LA    R2,3                                                     08020000
         LA    R1,RECUT1+1                                              08030000
         BAL   R14,HEXCVT                                               08040000
         LTR   R15,R15                                                  08050000
         BNZ   ERRUT1A                                                  08060000
         ST    R0,UT1ADR                                                08070000
         LA    R1,RECUT1+8                                              08080000
         BAL   R14,HEXCVTD                                              08090000
         LTR   R15,R15                                                  08100000
         BNZ   ERRUT1O                                                  08110000
         STC   R0,UT1OPCD                                               08120000
         LA    R1,RECUT1+10                                             08130000
         BAL   R14,HEXCVTD                                              08140000
         LTR   R15,R15                                                  08150000
         BNZ   ERRUT1R                                                  08160000
         STC   R0,UT1RR                                                 08170000
         AP    UT1INCT,=P'+1'                                           08180003
         L     R14,GETUT114                                             08190000
         BR    R14                                                      08200000
ERRUT1IN DS    0H                                                       08210000
         TM    FLAG,FLAGDBG                                             08220000
         BNO   GETUT11                                                  08230000
         MVC   LINE+10(15),=C'Not instruction'                          08240006
         B     ERRUT1                                                   08250006
ERRUT1A  DS    0H                                                       08260000
         TM    FLAG,FLAGDBG                                             08270000
         BNO   GETUT11                                                  08280000
         MVC   LINE+10(15),=C'Invalid address'                          08290006
         B     ERRUT1                                                   08300006
ERRUT1O  DS    0H                                                       08310000
         TM    FLAG,FLAGDBG                                             08320000
         BNO   GETUT11                                                  08330000
         MVC   LINE+10(14),=C'Invalid opcode'                           08340006
         B     ERRUT1                                                   08350006
ERRUT1R  DS    0H                                                       08360000
         TM    FLAG,FLAGDBG                                             08370000
         BNO   GETUT11                                                  08380000
         MVC   LINE+10(20),=C'Invalid regs/imm/len'                     08390006
         B     ERRUT1                                                   08400006
ERRUT1   DS    0H                                                       08410000
         MVC   LINE+1(8),=C'SYSUT1 -'                                   08420006
         BAL   R14,PRT                                                  08430006
         B     GETUT11                                                  08440000
*                                                                       08450000
*        Read SYSUT2 record                                             08460000
*                                                                       08470000
GETUT2   DS    0H                                                       08480000
         ST    R14,GETUT214                                             08490000
GETUT21  DS    0H                                                       08500000
         GET   SYSUT2,RECUT2                                            08510000
         AP    UT2CT,=P'+1'                                             08520000
         TM    FLAG,FLAGDBG                                             08530000
         BNO   GETUT22                                                  08540000
         MVC   LINE+1(8),=C'SYSUT2 -'                                   08550006
         MVC   LINE+10(120),RECUT2+1                                    08560006
         BAL   R14,PRT                                                  08570006
GETUT22  DS    0H                                                       08580000
         CLI   RECUT2+7,C' '                                            08590000
         BNE   ERRUT2IN                                                 08600000
         CLI   RECUT2+12,C' '                                           08610000
         BNE   ERRUT2IN                                                 08620000
         CLI   RECUT2+17,C' '                                           08630000
         BNE   ERRUT2IN                                                 08640000
         CLI   RECUT2+22,C' '                                           08650000
         BNE   ERRUT2IN                                                 08660000
         CLC   RECUT2+49(4),=C' DC '                                    08670001
         BE    ERRUT2IN                                                 08680001
         LA    R2,3                                                     08690000
         LA    R1,RECUT2+1                                              08700000
         BAL   R14,HEXCVT                                               08710000
         LTR   R15,R15                                                  08720000
         BNZ   ERRUT2A                                                  08730000
         ST    R0,UT2ADR                                                08740000
         LA    R1,RECUT2+8                                              08750000
         BAL   R14,HEXCVTD                                              08760000
         LTR   R15,R15                                                  08770000
         BNZ   ERRUT2O                                                  08780000
         STC   R0,UT2OPCD                                               08790000
         LA    R1,RECUT2+10                                             08800000
         BAL   R14,HEXCVTD                                              08810000
         LTR   R15,R15                                                  08820000
         BNZ   ERRUT2R                                                  08830000
         STC   R0,UT2RR                                                 08840000
         AP    UT2INCT,=P'+1'                                           08850003
         L     R14,GETUT214                                             08860000
         BR    R14                                                      08870000
ERRUT2IN DS    0H                                                       08880000
         TM    FLAG,FLAGDBG                                             08890000
         BNO   GETUT21                                                  08900000
         MVC   LINE+10(15),=C'Not instruction'                          08910006
         B     ERRUT2                                                   08920006
ERRUT2A  DS    0H                                                       08930000
         TM    FLAG,FLAGDBG                                             08940000
         BNO   GETUT21                                                  08950000
         MVC   LINE+10(15),=C'Invalid address'                          08960006
         B     ERRUT2                                                   08970006
ERRUT2O  DS    0H                                                       08980000
         TM    FLAG,FLAGDBG                                             08990000
         BNO   GETUT21                                                  09000000
         MVC   LINE+10(14),=C'Invalid opcode'                           09010006
         B     ERRUT2                                                   09020006
ERRUT2R  DS    0H                                                       09030000
         TM    FLAG,FLAGDBG                                             09040000
         BNO   GETUT21                                                  09050000
         MVC   LINE+10(20),=C'Invalid regs/imm/len'                     09060006
         B     ERRUT2                                                   09070006
ERRUT2   DS    0H                                                       09080000
         MVC   LINE+1(8),=C'SYSUT2 -'                                   09090006
         BAL   R14,PRT                                                  09100006
         B     GETUT21                                                  09110000
*                                                                       09120000
*        Convert character to hex                                       09130000
*                                                                       09140030
*          R1=Display hex string                                        09150030
*          R2=Number of characters                                      09160030
*          r0=Hex value                                                 09170030
*          R15=0=Converted                                              09180030
*              8=Error in hex digits                                    09190030
*                                                                       09200030
HEXCVT   DS    0H                                                       09210000
         ST    R14,HEXCVT14                                             09220000
         ST    R3,HEXCVT3                                               09230011
         SLR   R3,R3                                                    09240000
HEXCVT1  DS    0H                                                       09250000
         BAL   R14,HEXCVTD                                              09260000
         LTR   R15,R15                                                  09270000
         BNZ   HEXCVT9                                                  09280000
         SLL   R3,8                                                     09290000
         AR    R3,R0                                                    09300000
         LA    R1,2(,R1)                                                09310000
         BCT   R2,HEXCVT1                                               09320000
         LR    R0,R3                                                    09330000
HEXCVT9  DS    0H                                                       09340000
         L     R3,HEXCVT3                                               09350011
         L     R14,HEXCVT14                                             09360011
         BR    R14                                                      09370000
*                                                                       09380000
*        Character to hex converter                                     09390039
*                                                                       09400000
HEXCVTD  DS    0H                                                       09410000
         IC    R15,0(,R1)                                               09420000
         N     R15,=A(X'0000000F')                                      09430010
         CLI   0(R1),C'9'                                               09440010
         BH    HEXCVTD9                                                 09450000
         CLI   0(R1),C'0'                                               09460010
         BNL   HEXCVTD1                                                 09470000
         CLI   0(R1),C'A'                                               09480010
         BL    HEXCVTD9                                                 09490000
         CLI   0(R1),C'F'                                               09500010
         BH    HEXCVTD9                                                 09510000
         LA    R15,9(,R15)                                              09520000
HEXCVTD1 DS    0H                                                       09530000
         LR    R0,R15                                                   09540000
         SLL   R0,4                                                     09550000
         IC    R15,1(,R1)                                               09560000
         N     R15,=A(X'0000000F')                                      09570010
         CLI   1(R1),C'9'                                               09580010
         BH    HEXCVTD9                                                 09590000
         CLI   1(R1),C'0'                                               09600010
         BNL   HEXCVTD2                                                 09610000
         CLI   1(R1),C'A'                                               09620010
         BL    HEXCVTD9                                                 09630000
         CLI   1(R1),C'F'                                               09640010
         BH    HEXCVTD9                                                 09650000
         LA    R15,9(,R15)                                              09660000
HEXCVTD2 DS    0H                                                       09670000
         AR    R0,R15                                                   09680000
         SR    R15,R15                                                  09690000
         BR    R14                                                      09700000
HEXCVTD9 DS    0H                                                       09710000
         LA    R15,8                                                    09720000
         BR    R14                                                      09730000
*********************************************************************** 09740024
*        SORT key                                                     * 09750024
*           +0,1=0=no offset difference                               * 09760028
*               =1=negative difference                                * 09770028
*               =2=positive difference                                * 09780028
*           +1,2=difference                                           * 09790028
*           +3,4=correct (original DDD) displacement                  * 09800028
*           +5=unused                                                 * 09810024
*********************************************************************** 09820024
         USING OPND,R15                                                 09830024
SRKY     DS    0H                                                       09840024
         ST    R14,SRKYR14                                              09850024
         ST    R15,SRKYR15                                              09860024
         XC    OPNDKEY,OPNDKEY                                          09870024
         MVC   OPNDOBAS,OPNDOBDD   Original base register               09880031
         CLI   OPNDOBAS,C'F'       Base A-F                             09890031
         BH    SRKY010             No                                   09900031
         IC    R14,OPNDOBAS        Get base reg                         09910031
         LA    R14,X'39'(,R14)     Make X'FA to X'FF'                   09920031
         STC   R14,OPNDOBAS                                             09930031
SRKY010  DS    0H                                                       09940031
         CLC   OPNDOBDD(1),OPNDNBDD                                     09950024
         BNE   SRKYXT                                                   09960024
         MVI   DWORD,C'0'                                               09970024
         MVC   DWORD+1(3),OPNDNBDD+1                                    09980024
         DROP  R15                                                      09990024
         LA    R2,2                                                     10000024
         LA    R1,DWORD                                                 10010024
         BAL   R14,HEXCVT                                               10020024
         LTR   R15,R15                                                  10030024
         BNZ   SRKYXT                                                   10040024
         ST    R0,DWORD+4                                               10050024
         MVI   DWORD,C'0'                                               10060024
         L     R15,SRKYR15                                              10070024
         USING OPND,R15                                                 10080024
         MVC   DWORD+1(3),OPNDOBDD+1                                    10090028
         DROP  R15                                                      10100024
         LA    R1,DWORD                                                 10110028
         LA    R2,2                                                     10120024
         BAL   R14,HEXCVT                                               10130024
         LTR   R15,R15                                                  10140024
         BNZ   SRKYXT                                                   10150024
         L     R15,SRKYR15                                              10160024
         USING OPND,R15                                                 10170024
         STCM  R0,3,OPNDDDD                                             10180025
         MVI   OPNDDIFS,2          Positive displacement sort last      10190025
         S     R0,DWORD+4                                               10200024
         BNM   SRKYPL                                                   10210024
         MVI   OPNDDIFS,1          Negative displacement sort early     10220025
SRKYPL   DS    0H                                                       10230024
         STCM  R0,3,OPNDDIF                                             10240028
SRKYXT   DS    0H                                                       10250024
         L     R14,SRKYR14                                              10260024
         BR    R14                                                      10270024
         DROP  R15                                                      10280024
*********************************************************************** 10290025
*        Report errors                                                * 10300025
*********************************************************************** 10310025
RPT      DS    0H                                                       10320025
         ST    R14,RPTR14                                               10330025
         MVC   LINE+1(26),=C'-Old--  Calc  ----New-----'                10340039
         BAL   R14,PRT                                                  10350025
         MVC   LINE+1(32),=C'Opernd Displ  Opernd Displ  Diff'          10360039
         MVC   LINE+35(71),=C'-------------------------- Sequence Numbe*10370039
               rs ---------------------------'                          10380039
         MVC   LINE+108(5),=C'Count'                                    10390039
         BAL   R14,PRT                                                  10400025
         L     R3,OPNDTBA                                               10410025
         SR    R4,R4                                                    10420025
RPT010   DS    0H                                                       10430025
         C     R3,OPNDEND                                               10440025
         BNL   RPTXT                                                    10450025
         USING OPND,R3                                                  10460025
*                                                                       10470025
         MVC   LINE+1(3),OPNDOBDD+1                                     10480025
         MVC   LINE+4(3),=C'( )'                                        10490025
         MVC   LINE+5(1),OPNDOBDD                                       10500025
*                                                                       10510025
         CLI   OPNDDISP,C' '                                            10520030
         BE    RPT015                                                   10530030
         LA    R1,OPNDDISP+1                                            10540030
         LA    R2,2                                                     10550030
         BAL   R14,HEXCVT                                               10560030
         LTR   R15,R15                                                  10570030
         BNZ   RPT015                                                   10580030
         MVC   DWORD(2),OPNDDIF                                         10590030
         AH    R0,DWORD                                                 10600030
         CLI   OPNDDIFS,2          Positive displacement                10610030
         BE    RPT014                                                   10620030
         CLI   OPNDDIFS,1          Negative displacement                10630030
         BNE   RPT015                                                   10640030
RPT014   DS    0H                                                       10650030
         ST    R0,DWORD                                                 10660030
         UNPK  LINE+7(7),DWORD+1(4)                                     10670030
         MVI   LINE+7,C' '                                              10680030
         NC    LINE+8(5),=X'0F0F0F0F0F0F0F0F'                           10690030
         TR    LINE+8(5),=C'0123456789ABCDEF'                           10700030
         MVI   LINE+13,C' '                                             10710030
RPT015   DS    0H                                                       10720030
*                                                                       10730030
         MVC   LINE+15(3),OPNDNBDD+1                                    10740029
         MVC   LINE+18(3),=C'( )'                                       10750029
         MVC   LINE+19(1),OPNDNBDD                                      10760029
*                                                                       10770025
         MVC   LINE+22(5),OPNDDISP                                      10780029
*                                                                       10790025
         MVC   LINE+35+(0*9)(8),OPNDNSQ1                                10800039
         MVC   LINE+35+(1*9)(8),OPNDNSQ2                                10810039
         MVC   LINE+35+(2*9)(8),OPNDNSQ3                                10820039
         MVC   LINE+35+(3*9)(8),OPNDNSQ4                                10830039
         MVC   LINE+35+(4*9)(8),OPNDNSQ5                                10840039
         MVC   LINE+35+(5*9)(8),OPNDNSQ6                                10850039
         MVC   LINE+35+(6*9)(8),OPNDNSQ7                                10860039
         MVC   LINE+35+(7*9)(8),OPNDNSQ8                                10870039
*                                                                       10880025
         SR    R0,R0                                                    10890025
         ICM   R0,3,OPNDNUM                                             10900025
         AR    R4,R0                                                    10910025
         CVD   R0,DWORD                                                 10920025
         MVC   LINE+106(7),=X'4020206B202120'                           10930039
         ED    LINE+106(7),DWORD+5                                      10940039
*                                                                       10950025
         CLC   OPNDOBDD(1),OPNDNBDD                                     10960025
         BE    RPT017                                                   10970030
         MVC   LINE+114(14),=C'Base different'                          10980039
         B     RPT030                                                   10990030
RPT017   DS    0H                                                       11000030
         MVI   DWORD,C'0'                                               11010025
         MVC   DWORD+1(3),OPNDNBDD+1                                    11020025
         LA    R2,2                                                     11030025
         LA    R1,DWORD                                                 11040025
         BAL   R14,HEXCVT                                               11050025
         LTR   R15,R15                                                  11060025
         BNZ   RPT030                                                   11070025
         ST    R0,DWORD+4                                               11080025
         MVI   DWORD,C'0'                                               11090025
         MVC   DWORD+1(3),OPNDOBDD+1                                    11100025
         LA    R2,2                                                     11110025
         LA    R1,DWORD                                                 11120025
         BAL   R14,HEXCVT                                               11130025
         LTR   R15,R15                                                  11140025
         BNZ   RPT030                                                   11150025
         MVI   LINE+28,C'+'                                             11160039
         S     R0,DWORD+4                                               11170025
         BNM   RPT020                                                   11180025
         MVI   LINE+28,C'-'                                             11190039
RPT020   DS    0H                                                       11200025
         LPR   R1,R0                                                    11210025
         ST    R1,DWORD                                                 11220025
         UNPK  LINE+29(5),DWORD+2(3)                                    11230039
         NC    LINE+29(4),=X'0F0F0F0F0F0F0F0F'                          11240039
         TR    LINE+29(4),=C'0123456789ABCDEF'                          11250039
         MVI   LINE+33,C' '                                             11260039
RPT030   DS    0H                                                       11270025
*                                                                       11280025
         BAL   R14,PRT                                                  11290025
         LA    R3,OPNDNXT                                               11300025
         B     RPT010                                                   11310025
RPTXT    DS    0H                                                       11320025
         L     R14,RPTR14                                               11330025
         BR    R14                                                      11340025
         DROP  R3                                                       11350025
*********************************************************************** 11360006
*        Change register (only @nn and Rn/R1n are changed)            * 11370014
*         R1=Correct record register address                          * 11380015
*         R2=Difference line position                                 * 11390006
*         R15=Original recird register address                        * 11400021
*         R9=Current change record address                            * 11410015
*********************************************************************** 11420006
CHGREG   DS    0H                                                       11430006
         ST    R14,CHGREG14                                             11440007
CHGREGA  DS    0H                                                       11450006
         LA    R0,CHGREC+70                                             11460022
         CR    R9,R0                                                    11470006
         BNL   CHGREGX                                                  11480006
         CLI   0(R9),C'@'                                               11490006
         BE    CHGREG@1                                                 11500015
         CLI   0(R9),C'R'                                               11510014
         BE    CHGREGR1                                                 11520015
CHGREGB  DS    0H                                                       11530006
         LA    R9,1(,R9)                                                11540006
         B     CHGREGA                                                  11550006
CHGREG@1 DS    0H                                                       11560015
         CLI   1(R9),C'0'                                               11570006
         BL    CHGREGB                                                  11580006
         CLI   2(R9),C'0'                                               11590006
         BL    CHGREGB                                                  11600006
         CLI   3(R9),C' '                                               11610006
         BE    CHGREG@2                                                 11620015
         CLI   3(R9),C','                                               11630006
         BE    CHGREG@2                                                 11640015
         CLI   3(R9),C')'                                               11650006
         BE    CHGREG@2                                                 11660015
         B     CHGREGB                                                  11670006
CHGREG@2 DS    0H                                                       11680015
         TM    FLAG,FLAGDBR                                             11690022
         BNO   CHGREG@A                                                 11700022
         STM   R14,R2,CHGREGRS                                          11710022
         MVC   LINE+1(20),=C'Found a  register at'                      11720022
         MVC   LINE+21(10),0(R9)                                        11730022
         MVC   LINE+31(3),=C'-->'                                       11740022
         MVC   LINE+34(1),0(R1)                                         11750022
         BAL   R14,PRT                                                  11760022
         LM    R14,R2,CHGREGRS                                          11770022
CHGREG@A DS    0H                                                       11780022
         IC    R0,0(,R15)                                               11790007
         N     R0,=A(X'0000000F')                                       11800007
         CLI   0(R15),C'F'                                              11810007
         BH    CHGREG@3                                                 11820015
         AH    R0,=H'+9'                                                11830007
CHGREG@3 DS    0H                                                       11840015
         CVD   R0,DWORD                                                 11850007
         OI    DWORD+7,X'0F'                                            11860007
         UNPK  DWORD(3),DWORD+6(2)                                      11870007
         CLC   1(2,R9),DWORD+1                                          11880007
         BNE   CHGREGB                                                  11890007
         TM    FLAG,FLAGDBR                                             11900007
         BNO   CHGREG@4                                                 11910015
         STM   R14,R2,CHGREGRS                                          11920007
         MVC   LINE+1(20),=C'Changing register at'                      11930007
         MVC   LINE+21(10),0(R9)                                        11940007
         MVC   LINE+31(3),=C'-->'                                       11950007
         MVC   LINE+34(1),0(R1)                                         11960007
         BAL   R14,PRT                                                  11970007
         LM    R14,R2,CHGREGRS                                          11980007
CHGREG@4 DS    0H                                                       11990015
         CLI   0(R1),C'F'                                               12000006
         BNH   CHGREG@5                                                 12010015
         MVI   1(R9),C'0'                                               12020006
         MVC   2(1,R9),0(R1)                                            12030006
         LA    R9,3(,R9)                                                12040006
         MVI   0(R2),C'!'                                               12050006
         OI    FLAG,FLAGCHG                                             12060007
         B     CHGREGZ                                                  12070006
CHGREG@5 DS    0H                                                       12080015
         MVI   1(R9),C'1'                                               12090006
         IC    R14,0(,R1)                                               12100006
         BCTR  R14,0                                                    12110006
         STC   R14,2(,R9)                                               12120006
         OI    2(R9),C'0'                                               12130006
         LA    R9,3(,R9)                                                12140006
         MVI   0(R2),C'!'                                               12150006
         OI    FLAG,FLAGCHG                                             12160007
         B     CHGREGZ                                                  12170006
CHGREGR1 DS    0H                                                       12180015
         CLI   1(R9),C'0'                                               12190014
         BL    CHGREGB                                                  12200014
         CLI   1(R9),C'1'                                               12210014
         BNE   CHGREGR2                                                 12220015
         CLI   2(R9),C'0'                                               12230014
         BL    CHGREGB                                                  12240014
         CLI   3(R9),C' '                                               12250014
         BE    CHGREGR3                                                 12260015
         CLI   3(R9),C','                                               12270014
         BE    CHGREGR3                                                 12280015
         CLI   3(R9),C')'                                               12290014
         BE    CHGREGR3                                                 12300015
         B     CHGREGB                                                  12310014
CHGREGR2 DS    0H                                                       12320015
         CLI   2(R9),C' '                                               12330014
         BE    CHGREGR3                                                 12340015
         CLI   2(R9),C','                                               12350014
         BE    CHGREGR3                                                 12360015
         CLI   2(R9),C')'                                               12370014
         BE    CHGREGR3                                                 12380015
         B     CHGREGB                                                  12390014
CHGREGR3 DS    0H                                                       12400015
         IC    R0,0(,R15)                                               12410014
         N     R0,=A(X'0000000F')                                       12420014
         CLI   0(R15),C'F'                                              12430014
         BH    CHGREGR4                                                 12440015
         AH    R0,=H'+9'                                                12450014
CHGREGR4 DS    0H                                                       12460015
         CVD   R0,DWORD                                                 12470014
         OI    DWORD+7,X'0F'                                            12480014
         UNPK  DWORD(3),DWORD+6(2)                                      12490014
         CLI   DWORD+1,C'1'                                             12500014
         BE    CHGREGR5                                                 12510015
         CLC   1(1,R9),DWORD+2                                          12520014
         BNE   CHGREGB                                                  12530014
         B     CHGREGR6                                                 12540015
CHGREGR5 DS    0H                                                       12550015
         CLC   1(2,R9),DWORD+1                                          12560014
         BNE   CHGREGB                                                  12570014
CHGREGR6 DS    0H                                                       12580015
         TM    FLAG,FLAGDBR                                             12590014
         BNO   CHGREGR7                                                 12600015
         STM   R14,R2,CHGREGRS                                          12610014
         MVC   LINE+1(20),=C'Changing register at'                      12620014
         MVC   LINE+21(10),0(R9)                                        12630014
         MVC   LINE+31(3),=C'-->'                                       12640014
         MVC   LINE+34(1),0(R1)                                         12650014
         BAL   R14,PRT                                                  12660014
         LM    R14,R2,CHGREGRS                                          12670014
CHGREGR7 DS    0H                                                       12680015
         CLI   0(R1),C'0'                                               12690015
         BL    CHGREGR8                                                 12700015
         MVC   1(1,R9),0(R1)                                            12710014
         CLI   2(R9),C' '                                               12720015
         BE    CHGREGRB                                                 12730015
         CLI   2(R9),C','                                               12740015
         BE    CHGREGRB                                                 12750015
         CLI   2(R9),C')'                                               12760016
         BE    CHGREGRB                                                 12770015
*        Rn replacing Rnn shift operands left one in CHGREC to blank    12780015
         LA    R1,2(,R9)                                                12790015
CHGREGRA DS    0H                                                       12800015
         MVC   0(1,R1),1(R1)                                            12810015
         LA    R1,1(,R1)                                                12820015
         CLI   0(R1),C' '                                               12830015
         BNE   CHGREGRA                                                 12840015
CHGREGRB DS    0H                                                       12850015
         LA    R9,2(,R9)                                                12860015
         MVI   0(R2),C'!'                                               12870014
         OI    FLAG,FLAGCHG                                             12880014
         B     CHGREGZ                                                  12890014
CHGREGR8 DS    0H                                                       12900015
         CLI   2(R9),C' '                                               12910015
         BE    CHGREGRC                                                 12920015
         CLI   2(R9),C','                                               12930015
         BE    CHGREGRC                                                 12940015
         CLI   2(R9),C')'                                               12950016
         BNE   CHGREGRE                                                 12960015
CHGREGRC DS    0H                                                       12970015
*        Rnn replacing Rn shift operands right one in CHGREC to blank   12980015
         LA    R14,2(,R9)                                               12990015
         IC    R15,0(,R14)                                              13000015
CHGREGRD DS    0H                                                       13010015
         IC    R0,1(,R14)                                               13020015
         LA    R14,1(,R14)                                              13030015
         STC   R15,0(,R14)                                              13040015
         LR    R15,R0                                                   13050015
         CLI   0(R14),C' '                                              13060015
         BNE   CHGREGRD                                                 13070015
CHGREGRE DS    0H                                                       13080015
         MVI   1(R9),C'1'                                               13090014
         IC    R14,0(,R1)                                               13100014
         BCTR  R14,0                                                    13110014
         STC   R14,2(,R9)                                               13120014
         OI    2(R9),C'0'                                               13130014
         LA    R9,3(,R9)                                                13140014
         MVI   0(R2),C'!'                                               13150014
         OI    FLAG,FLAGCHG                                             13160014
         B     CHGREGZ                                                  13170014
CHGREGX  DS    0H                                                       13180014
CHGREGZ  DS    0H                                                       13190006
         L     R14,CHGREG14                                             13200013
         BR    R14                                                      13210006
*********************************************************************** 13220039
*            WRITE PRINT LINE                                         * 13230039
*********************************************************************** 13240039
PRT      DS    0H                                                       13250000
         ST    R14,PRTR14                                               13260000
         CP    LNCT,=P'+60'            END OF PAGE                      13270000
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   13280000
PRTHDRS  DS    0H                                                       13290000
         AP    PGCT,=P'+1'             COUNT PAGES                      13300000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  13310000
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  13320000
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  13330000
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  13340000
         MVI   LINE,C' '               SKIP AFTER HEADING               13350034
PRTCHK   DS    0H                                                       13360000
         CLI   LINE,C'+'               OVERPRINT ?                      13370000
         BE    PRTLINE                  YES, DON'T COUNT                13380000
         CLI   LINE,C'1'               NEW LINE ?                       13390000
         BE    PRTHDRS                  YES, PRINT HEADER               13400000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         13410000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            13420000
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         13430000
         BE    PRTLINE2                 YES, GO CHECK IF FIT            13440000
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         13450000
         BE    PRTLINE3                 YES, GO CHECK IF FIT            13460000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       13470000
PRTLINE1 DS    0H                                                       13480000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                13490000
         B     PRTVFY                  GO SEE IF IT WILL FIT            13500000
PRTLINE2 DS    0H                                                       13510000
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                13520000
         B     PRTVFY                  GO SEE IF IT WILL FIT            13530000
PRTLINE3 DS    0H                                                       13540000
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                13550000
PRTVFY   DS    0H                                                       13560000
         CP    LNCT,=P'+60'            OVERFLOW ?                       13570000
         BH    PRTHDRS                  YES, FORCE HEADER               13580000
PRTLINE  DS    0H                                                       13590000
         PUT   SYSPRINT,LINE           PRINT A LINE                     13600000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          13610000
         MVC   LINE+1(L'LINE-1),LINE                                    13620000
         L     R14,PRTR14                                               13630000
         BR    R14                     RETURN TO CALLER                 13640000
*********************************************************************** 13650000
*        DUMP DATA                                                    * 13660000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 13670000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 13680000
*********************************************************************** 13690000
DMP      DS    0H                                                       13700000
         STM   R0,R15,DMPREGS          SAVE REGISTERS                   13710000
         LR    R3,R1                   GET ADDRESS TO DUMP              13720000
         LR    R4,R0                   GET LENGTH                       13730000
         XC    DMPOFF,DMPOFF           SAVE OFFSET FOR DUMP             13740000
         MVI   DMPFLAG,DMPFL1ST        FIRST LINE                       13750000
DMPDMPLP DS    0H                                                       13760000
         LTR   R4,R4                   ANY DATA TO DUMP ?               13770000
         BZ    DMPHEXXT                 YES, ALL DONE                   13780000
         TM    DMPFLAG,DMPFL1ST        FIRST LINE?                      13790000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   13800000
         LA    R0,32                   DEFAULT LENGTH                   13810000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          13820000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           13830000
         LR    R14,R3                  GET CURRENT INPUT AREA           13840000
         SR    R14,R0                  BACK TO PREVIOUS AREA            13850000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       13860000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            13870000
         SR    R4,R0                   REDUCE LENGTH TO DO              13880000
         TM    DMPFLAG,DMPFLDUP        DUPLICATE IN PROGRESS?           13890000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       13900000
         L     R14,DMPOFF              GET CURRENT OFFSET               13910000
         ST    R14,DMPFIRST            SAVE AS FIRST OFFSET             13920000
         OI    DMPFLAG,DMPFLDUP        SET DUPLICATE                    13930000
         B     DMPNXTLN                CONTINUE                         13940000
DMPDUPCK DS    0H                                                       13950000
         TM    DMPFLAG,DMPFLDUP        DUPLICATE IN PROGRESS?           13960000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      13970000
         MVC   LINE+7(5),=C'Lines'     MOVE LITERAL                     13980000
         LA    R2,LINE+13              OUTPUT AREA ADDRESS              13990000
         LA    R1,DMPFIRST+2           ADDRESS OF OFFSET TO DUMP        14000000
         LA    R15,2                   CONVERT 4 BYTES                  14010000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            14020000
         MVI   LINE+17,C'-'            THRU LITERAL                     14030000
         L     R1,DMPOFF               GET CURRENT OFFSET               14040000
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        14050000
         ST    R1,DMPFIRST             SAVE FOR DUMPING                 14060000
         LA    R2,LINE+18              OUTPUT AREA ADDRESS              14070000
         LA    R1,DMPFIRST+2           ADDRESS OF OFFSET TO DUMP        14080000
         LA    R15,2                   CONVERT 4 BYTES                  14090000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            14100000
         MVC   LINE+23(13),=C'Same as above' MOVE LITERAL               14110000
         BAL   R14,PRT                 PRINT A LINE                     14120000
         NI    DMPFLAG,255-DMPFLDUP    RESET DUPLICATE IN PROGRESS      14130000
DMPALIN  DS    0H                                                       14140000
         ST    R3,DMPADDR          Save address                         14150000
         LA    R2,LINE+1           Output area address                  14160000
         LA    R1,DMPADDR          Address of address                   14170000
         LA    R15,4               Convert 8 bytes                      14180000
         BAL   R14,DMPDSP          CONVERT IT TO DISPLAY                14190013
         LA    R2,1(,R2)           Skip 1 between address & offset      14200000
         LA    R1,DMPOFF+2             ADDRESS OF OFFSET TO DUMP        14210000
         LA    R15,2                   CONVERT 4 BYTES                  14220000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            14230000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     14240000
         LR    R1,R3                   ADDRESS OF DATA                  14250000
         LA    R5,32                   DEFAULT LENGTH                   14260000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          14270000
         BH    DMPDODMP                 YES, USE 32                     14280000
         LR    R5,R4                   USE WHAT IS LEFT                 14290000
DMPDODMP DS    0H                                                       14300000
         SR    R4,R5                   REDUCE AMOUNT TO DO              14310000
         MVI   LINE+89,C'*'            BOX IN DISPLAY PORTION           14320000
         BCTR  R5,0                    MAKE ZERO BASED                  14330000
         EX    R5,DMPMVC               DO MOVE                          14340000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          14350000
         LA    R5,1(,R5)               RESTORE LENGTH                   14360000
         MVI   LINE+122,C'*'           COMPLETE BOX                     14370000
DMPDMPHX DS    0H                                                       14380000
         LA    R15,4                   4 BYTES TO PROCESS               14390000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           14400000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               14410000
         LR    R15,R5                  USE LENGTH LEFT                  14420000
DMPDMPIT DS    0H                                                       14430000
         SR    R5,R15                  REDUCE AMOUNT TO DO              14440000
         BAL   R14,DMPDSP              CONVERT DATA                     14450000
         LA    R2,1(,R2)               SKIP 1 BYTE                      14460000
         LA    R0,LINE+43              HALFWAY POINT ADDRESS            14470000
         CR    R0,R2                   AT HALFWAY POINT?                14480000
         BNE   DMPDMPNX                 NO, CONTINUE                    14490000
         LA    R2,1(,R2)               SKIP 1 BYTE                      14500000
DMPDMPNX DS    0H                                                       14510000
         LTR   R5,R5                   ANY LEFT TO DO ?                 14520000
         BH    DMPDMPHX                 YES, GO DO IT                   14530000
         BAL   R14,PRT                 PRINT A LINE                     14540000
DMPNXTLN DS    0H                                                       14550000
         L     R1,DMPOFF               GET OFFSET IN RECORD             14560000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       14570000
         ST    R1,DMPOFF               SAVE OFFSET IN RECORD            14580000
         LA    R3,32(,R3)              NEXT INPUT AREA                  14590000
         NI    DMPFLAG,255-DMPFL1ST    NOT FIRST LINE                   14600000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             14610000
DMPHEXXT DS    0H                                                       14620000
         LM    R0,R15,DMPREGS          RESTORE CALLERS REGS             14630000
         BR    R14                     EXIT . . .                       14640000
DMPMVC   MVC   LINE+90(0),0(R1)        <<< EXECUTED >>>                 14650000
DMPTR    TR    LINE+90(0),DMPTBLCH     <<< EXECUTED >>>                 14660000
*                                                                       14670000
*                                                                       14680000
*                                                                       14690000
DMPDSP   DS    0H                                                       14700000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               14710000
         NI    0(R2),X'0F'             REMOVE ZONE                      14720000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             14730000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             14740000
         TR    0(2,R2),=C'0123456789ABCDEF' TRANSLATE TO HEX            14750000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        14760000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         14770000
         BCT   R15,DMPDSP              LOOP THRU DATA                   14780000
         BR    R14                     EXIT . . .                       14790000
*********************************************************************** 14800000
*        Constants                                                    * 14810010
*********************************************************************** 14820000
         LTORG ,                                                        14830010
DMPTBLCH DC    CL256' '                                                 14840000
         ORG   DMPTBLCH+X'4A' Cent                                      14850000
         DC    X'4A4B4C4D4E4F50' vert bar and ampersand                 14860000
         ORG   DMPTBLCH+X'5A' exclamation                               14870000
         DC    X'5A5B5C5D5E5F6061'                                      14880000
         ORG   DMPTBLCH+X'6A'                                           14890000
         DC    X'6A6B6C6D6E6F'                                          14900000
         ORG   DMPTBLCH+X'7A'                                           14910000
         DC    X'7A7B7C7D7E7F'                                          14920000
         ORG   DMPTBLCH+C'a'                                            14930000
         DC    C'abcdefghi'                                             14940000
         ORG   DMPTBLCH+C'j'                                            14950000
         DC    C'jklmnopqr'                                             14960000
         ORG   DMPTBLCH+C's'                                            14970000
         DC    C'stuvwxyz'                                              14980000
         ORG   DMPTBLCH+C'A'                                            14990000
         DC    C'ABCDEFGHI'                                             15000000
         ORG   DMPTBLCH+C'J'                                            15010000
         DC    C'JKLMNOPQR'                                             15020000
         ORG   DMPTBLCH+C'S'                                            15030000
         DC    C'STUVWXYZ'                                              15040000
         ORG   DMPTBLCH+C'0'                                            15050000
         DC    C'0123456789'                                            15060000
         ORG                                                            15070000
*********************************************************************** 15080010
*        Work areas                                                   * 15090010
*********************************************************************** 15100010
SAVEAREA DC    18A(0)                                                   15110000
DMPREGS  DC    16A(0)                                                   15120010
DMPOFF   DS    A                                                        15130010
DMPADDR  DS    A                                                        15140010
DMPFIRST DS    A                                                        15150010
DMPFLAG  DC    X'00'                                                    15160010
DMPFL1ST EQU   X'80'                                                    15170010
DMPFLDUP EQU   X'40'                                                    15180010
*                                                                       15190010
DWORD    DC    D'+0'                                                    15200000
PRTR14   DC    A(0)                                                     15210000
GETUT114 DC    A(0)                                                     15220000
GETUT214 DC    A(0)                                                     15230000
HEXCVT14 DC    A(0)                                                     15240000
HEXCVT3  DC    A(0)                                                     15250011
SRKYR14  DC    A(0)                                                     15260024
SRKYR15  DC    A(0)                                                     15270024
RPTR14   DC    A(0)                                                     15280025
LINE     DC    CL133' '                                                 15290000
DIFLINE  DC    CL133' '                                                 15300002
RECUT1   DC    CL133' '                                                 15310000
RECUT2   DC    CL133' '                                                 15320000
CHGREC   DC    CL80' '                                                  15330001
CURDATE  DC    A(0)                                                     15340000
JULWRK2  DC    A(0)                                                     15350000
JULWRK4  DC    P'+365'                                                  15360000
         DC    P'+01'                                                   15370000
         DC    P'+31'                                                   15380000
         DC    P'+30'                                                   15390000
         DC    P'+31'                                                   15400000
         DC    P'+30'                                                   15410000
         DC    P'+31'                                                   15420000
         DC    P'+31'                                                   15430000
         DC    P'+30'                                                   15440000
         DC    P'+31'                                                   15450000
         DC    P'+30'                                                   15460000
         DC    P'+31'                                                   15470000
JULWRK6  DC    P'+28'                                                   15480000
JULTBL1  DC    P'+31'                                                   15490000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  15500000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            15510000
LNCT     DC    PL2'+99'                                                 15520000
PGCT     DC    PL2'+0'                                                  15530000
HD1      DC    CL133'1'                                                 15540000
         ORG   HD1+1                                                    15550000
HD1DATE  DC    C'            '                                          15560000
         DC    C' '                                                     15570000
HD1TOD   DC    C'HH:MM:SS'                                              15580000
         ORG   HD1+66-(20/2)                                            15590013
HD1DATA  DC    C'Assembly List Compare'                                 15600000
         ORG   HD1+L'HD1-8                                              15610013
HD1PG    DC    C'Page'                                                  15620013
HD1PGCT  DC    C' 123'                                                  15630000
SYSUT1   DCB   DDNAME=SYSUT1,MACRF=GM,DSORG=PS,EODAD=EODUT1,           *15640000
               RECFM=FB,LRECL=133                                       15650000
SYSUT2   DCB   DDNAME=SYSUT2,MACRF=GM,DSORG=PS,EODAD=EODUT2,           *15660000
               RECFM=FB,LRECL=133                                       15670000
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      *15680000
               RECFM=FBA,LRECL=133                                      15690000
CHANGES  DCB   DDNAME=CHANGES,MACRF=PM,DSORG=PS,                       *15700001
               RECFM=FB,LRECL=80                                        15710001
UT1ADR   DC    A(0)                                                     15720000
UT2ADR   DC    A(0)                                                     15730000
CHGREG14 DC    A(0)                                                     15740007
CHGREGRS DC    5A(0)                                                    15750007
UT1OPCD  DC    X'00'                                                    15760000
UT2OPCD  DC    X'00'                                                    15770000
UT1RR    DC    X'00'                                                    15780000
UT2RR    DC    X'00'                                                    15790000
UT2OP1   DC    A(0)                                                     15800010
UT2OP2   DC    A(0)                                                     15810010
UT1CT    DC    PL5'+0'                                                  15820000
UT2CT    DC    PL5'+0'                                                  15830000
UT1INCT  DC    PL5'+0'                                                  15840003
UT2INCT  DC    PL5'+0'                                                  15850003
DIFCT    DC    PL5'+0'                                                  15860000
LINDIFCT DC    PL5'+0'                                                  15870008
FLAG     DC    X'00'                                                    15880000
FLAGOP   EQU   X'80'                                                    15890000
FLAGREG  EQU   X'40'                                                    15900000
FLAGVER  EQU   X'20'                                                    15910007
FLAGDBG  EQU   X'10'                                                    15920007
FLAGDBR  EQU   X'08'                                                    15930007
FLAGCHG  EQU   X'04'                                                    15940007
FLAGNOHX EQU   X'02'                                                    15950017
FLAGCHGS EQU   X'01'                                                    15960032
FLAG1    DC    X'00'                                                    15970033
FLAG1NWI EQU   X'80'                                                    15980033
SRTRC    DC    3A(0)                                                    15990010
SRTPRM   DC    2A(0)                   Parameters                       16000010
SRTDSC   DC    0A(0)                   SORT TABLE DESCRIPTION           16010010
SRTNUM   DC    AL2(0)                  NR OF ENTRIES                    16020010
SRTLEN   DC    AL2(0)                  ENTRY LENGTH                     16030010
SRTKLN   DC    AL2(0)                  KEY LENGTH                       16040010
SRTKOF   DC    AL2(0)                  KEY DISPLACEMENT                 16050010
SRTPARM  EQU   SRTDSC,*-SRTDSC                                          16060037
OPNDTBA  DC    A(OPNDTBL)                                               16070010
OPNDEND  DC    A(OPNDTBL-1)                                             16080010
OPNDMAX  DC    A(OPNDTBZ)                                               16090010
OPNDTBL  DC    0D'0'                                                    16100010
         DC    1000XL(L'OPND)'00'                                       16110010
OPNDTBZ  EQU   *                                                        16120010
*********************************************************************** 16130010
*********************************************************************** 16140010
**                                                                   ** 16150010
**       SORT                                                        ** 16160010
**                                                                   ** 16170010
**          PARAMETERS ARE THE TABLE ADDRESS AND TABLE DESCRIPTION   ** 16180010
**          SEE DSECT SRTD FOR DESCRIPTION OF TABLE DESCRIPTION      ** 16190010
**                                                                   ** 16200010
*********************************************************************** 16210010
*********************************************************************** 16220010
         DROP                                                           16230010
SORT     CSECT                                                          16240010
         USING SORT,R15                                                 16250010
         B     SORTBGN                                                  16260010
         DROP  R15                                                      16270010
         DC    AL1(L'SORTID)                                            16280010
SORTID   DC    C'SORT &SYSDATE &SYSTIME'                                16290010
SORTBGN  DS    0H                                                       16300010
         STM   R14,R12,12(R13)         SAVE CALLERS REGS                16310010
         LR    R3,R15                  TRANSFER BASE REG                16320010
         USING SORT,R3                                                  16330010
         LA    R0,SRTWKLEN             CORE REQUIRED FOR SAVE/WORK      16340010
         GETMAIN R,LV=(0)              GET WORK AREA                    16350010
         ST    R1,8(,R13)              CHAIN SAVE AREAS                 16360010
         ST    R13,4(,R1)                                               16370010
         LR    R2,R13                  SAVE CALLERS SAVE POINTER        16380010
         LR    R13,R1                  SET WORKAREA POINTER             16390010
         USING SRTWK,R13               ADDRESS WORK AREA                16400010
         LM    R0,R2,12+4*(R0+2-(R0+2)/16*16)(R2) RESTORE R0-R2         16410010
         MVC   SRTWKXCS,SORTINS        SWITCHING INSTRUCTIONS           16420010
         SR    R4,R4                   SET RETURN CODE EQ 0             16430010
         LM    R1,R2,0(R1)             PICK UP PARAMETERS               16440010
         USING SRTD,R2                                                  16450010
*                                                                       16460010
*  EDIT NUMBER OF ENTRIES                                               16470010
*                                                                       16480010
         SR    R0,R0                                                    16490010
         ICM   R0,3,SRTDNENT           NR OF ENTRIES                    16500010
         LTR   R0,R0                                                    16510010
         BNP   SORT801                 0 OR NEG NR OF ENTRIES           16520010
         CH    R0,=H'1'                                                 16530010
         BE    SORT900                 ONLY 1 ENTRY - NO SORT           16540010
*                                                                       16550010
*  EDIT ENTRY LENGTH                                                    16560010
*                                                                       16570010
         LH    R10,SRTDENTL            LENGTH OF AN ENTRY               16580010
         LTR   R10,R10                                                  16590010
         BNP   SORT802                 0 OR NEGATIVE LENGTH             16600010
         CH    R10,=H'256'                                              16610010
         BH    SORT803                 TOO LONG                         16620010
         LR    R15,R10                                                  16630010
         BCTR  R15,0                   GET LENGTH FOR SWITCHING ENTS    16640010
         STC   R15,SRTWKXC1+1          STORE IN ENTRY SWITCHING         16650010
         STC   R15,SRTWKXC2+1          INSTRUCTIONS                     16660010
         STC   R15,SRTWKXC3+1                                           16670010
         STC   R15,SRTWKXC4+1                                           16680010
*              GET ADDRESS OF LAST ENTRY IN THE TABLE                   16690010
         BCTR  R0,0                                                     16700010
         LR    R15,R10                                                  16710010
         MR    R14,R0                  LENGTH X NUM-1                   16720010
         LR    R8,R1                   FIRST IN THE TABLE TO CHECK      16730010
         LR    R11,R8                                                   16740010
         AR    R11,R15                 LAST IN TABLE TO CHECK           16750010
*                                                                       16760010
*  EDIT KEY LENGTH                                                      16770010
*                                                                       16780010
         LH    R15,SRTDKEYL                                             16790010
         LTR   R15,R15                                                  16800010
         BNP   SORT804                 0 OR NEG LENGTH                  16810010
         CR    R15,R10                 COMP TO ENTRY LENGTH             16820010
         BH    SORT805                 KEY LONGER THAN THE ENTRY        16830010
         BCTR  R15,0                   GET COMPARE LENGTH               16840010
         STC   R15,SRTWKCLO+1          STORE IN COMPARES                16850010
         STC   R15,SRTWKCHI+1                                           16860010
*                                                                       16870010
*  EDIT KEY DISPLACEMENT                                                16880010
*                                                                       16890010
         LH    R14,SRTDKEYD            PICK DISPLACEMENT                16900010
         LTR   R14,R14                                                  16910010
         BM    SORT806                 NEGATIVE LENGTH                  16920010
         AR    R15,R14                 ADD DISP TO KEY LENGTH           16930010
         LA    R15,1(,R15)             FOR BCTR ABOVE                   16940010
         CR    R15,R10                 COMP TO ENTRY LENGTH             16950010
         BH    SORT807                 OVERLAPPING KEY                  16960010
         STC   R14,SRTWKCLO+3          STUFF IN COMPARE DISPLACEMENTS   16970010
         STC   R14,SRTWKCLO+5          STUFF                            16980010
         STC   R14,SRTWKCHI+3          STUFF                            16990010
         STC   R14,SRTWKCHI+5          STUFF                            17000010
*********************************************************************** 17010010
*                                                                     * 17020010
*  MAIN LOOP    8 CONTAINS ADDRESS OF LOWEST ENTRY TO CHECK           * 17030010
*               9 CONTAINS ADDRESS OF NEXT ENTRY TO CHECK             * 17040010
*              10 CONTAINS LENGTH OF AN ENTRY                         * 17050010
*              11 CONTAINS ADDRESS OF HIGHEST ENTRY TO CHECK          * 17060010
*                                                                     * 17070010
*               7 CONTAINS ADDRESS OF LOWEST ENTRY FOUND              * 17080010
*              12 CONTAINS ADDRESS OF HIGHEST ENTR FOUND              * 17090010
*                                                                     * 17100010
*********************************************************************** 17110010
SORT100  DS    0H                                                       17120010
         CR    R8,R11                  NEXT LOW TO NEXT HIGH            17130010
         BNL   SORT900                                                  17140010
         LR    R9,R8                   NEXT CHECK EQ LOW TABLE ADDRES   17150010
         LR    R7,R9                   SET LOWEST EQ TO NEXT CHECK      17160010
         LR    R12,R9                  SAME FOR THE HIGHEST             17170010
SORT110  DS    0H                                                       17180010
         BXH   R9,R10,SORT200                                           17190013
         EX    R0,SRTWKCLO             ENT TO LOWEST FOUND SO FAR       17200010
         BL    SORT120                 IF LOWER SET ENT TO LOWEST       17210010
         BE    SORT110                 CONTINUE THE SCAN                17220010
         EX    R0,SRTWKCHI             ENT TO HIGHEST FOUND SO FAR      17230010
         BNH   SORT110                 CONTINUE THE SCAN                17240010
         LR    R12,R9                  HAH FOUND A HIGHER ONE           17250010
         B     SORT110                 CONTINUE SCAN                    17260010
SORT120  DS    0H                                                       17270010
         LR    R7,R9                   SET LOWEST TO THIS ENTRY         17280010
         B     SORT110                 AND CONTINUE SCAN                17290010
*********************************************************************** 17300010
*                                                                     * 17310010
*  SWITCH ENTRIES                                                     * 17320010
*        ADDRESSES OF ENTRIES WITH THE LOWEST AND HIGHEST KEYS ARE IN * 17330010
*        REGISTERS 7 AND 12 RESPECTIVELY                              * 17340010
*        THESE ENTRIES SHOULD BE PLACED IN THE SLOTS POINTED TO BY    * 17350010
*        REGISTERS 8 AND 11 RESPECTIVELY                              * 17360010
*        *** CAUTION ***                                              * 17370010
*        SINCE SWITCHING IS ACCOMPLISHED WITH XC'S,CARE MUST BE       * 17380010
*        EXERCISED TO PREVENT ZEROING OF ENTRIES                      * 17390010
*                                                                     * 17400010
*        AFTER GETTING THE HIGHEST AND LOWEST ENTRIES INTO SEQUENCE   * 17410010
*        THE LENGTH OF THE TABLE WILL BE REDUCED BY 2 ENTRIES         * 17420010
*                                                                     * 17430010
*********************************************************************** 17440010
SORT200  DS    0H                                                       17450010
         CR    R7,R12                  SAME RECORD BOTH HIGH AND LOW    17460010
         BE    SORT220                 YES - NO SWITCH                  17470010
         CR    R7,R8                   IS THE LOW ALREADY IN PLACE Q    17480010
         BE    SORT210                 YES GO TRY THE HIGHEST           17490010
         EX    R0,SRTWKXC1             SWITCH LOW PAIR                  17500010
         EX    R0,SRTWKXC2                                              17510010
         EX    R0,SRTWKXC1                                              17520010
         CR    R8,R12                  DID LAST SWITCH MOVE HIGHEST     17530010
         BNE   SORT210                 NO - GO TRY HIGH SWITCH          17540010
         LR    R12,R7                  RESET HIGHEST TO NEW LOC         17550010
SORT210  DS    0H                                                       17560010
         CR    R11,R12                 IS HIGHEST ALREADY IN PLACE      17570010
         BE    SORT220                 YES                              17580010
         EX    R0,SRTWKXC3             SWITCH HIGH PAIR                 17590010
         EX    R0,SRTWKXC4                                              17600010
         EX    R0,SRTWKXC3                                              17610010
SORT220  DS    0H                                                       17620010
         AR    R8,R10                  ADD ENTRY LENGTH TO NEXT LOW     17630010
         SR    R11,R10                 AND SUBTRACT FROM NEXT HIGH      17640010
         B     SORT100                 GO TO TEST FOR END               17650010
SORT801  DS    0H                                                       17660010
         LA    R2,1                                                     17670010
         B     SORT899                                                  17680010
SORT802  DS    0H                                                       17690010
         LA    R2,2                                                     17700010
         B     SORT899                                                  17710010
SORT803  DS    0H                                                       17720010
         LA    R2,3                                                     17730010
         B     SORT899                                                  17740010
SORT804  DS    0H                                                       17750010
         LA    R2,4                                                     17760010
         B     SORT899                                                  17770010
SORT805  DS    0H                                                       17780010
         LA    R2,5                                                     17790010
         B     SORT899                                                  17800010
SORT806  DS    0H                                                       17810010
         LA    R2,6                                                     17820010
         B     SORT899                                                  17830010
SORT807  DS    0H                                                       17840010
         LA    R2,7                                                     17850010
         B     SORT899                                                  17860010
SORT899  DS    0H                                                       17870010
         LA    R4,4                    SET RETURN CODE EQ 4             17880010
SORT900  DS    0H                                                       17890010
         LR    R1,R13                  ADDRESS TO BE FREED              17900010
         L     R13,4(,R13)             POINT TO CALLERS SAVE            17910010
         DROP  R13                     NO MORE REFS                     17920010
         LA    R0,SRTWKLEN             LENGTH TO FREE                   17930010
         FREEMAIN R,A=(1),LV=(0)       FREE WORK AREA                   17940010
         L     R14,12(,R13)            SET RETURN ADDRESS               17950010
         LR    R15,R4                  AND CODE                         17960010
         LR    R0,R2                   AND REASON                       17970010
         LM    R1,R12,24(R13)          RESTORE R1-R12                   17980010
         BR    R14                     RETURN  TO CALLER                17990010
*                                                                       18000010
*              NEXT 6 INSTRUCTIONS ARE MODELS THAT ARE MOVED            18010010
*              TO WORKING STORAGE FOR MODIFICATION AND EXECUTION        18020010
*                                                                       18030010
SORTINS  XC    0(0,R7),0(R8)           SWITCH LOWEST AND                18040010
         XC    0(0,R8),0(R7)           NEXT LOW                         18050010
         XC    0(0,R12),0(R11)         SWITCH HIGHEST AND               18060010
         XC    0(0,R11),0(R12)         NEXT HIGH                        18070010
         CLC   0(0,R9),0(R7)           ENT TO LOWEST FOUND SO FAR       18080010
         CLC   0(0,R9),0(R12)          ENT TO HIGHEST FOUND SO FAR      18090010
         LTORG ,                                                        18100010
*                                                                       18110010
SRTDSECT DSECT ,                                                        18120010
SRTDNENT DS    H                       NUMBER OF ENTRIES                18130010
SRTDENTL DS    H                       LENGTH OF AN ENTRY               18140010
SRTDKEYL DS    H                       LENGTH OF THE KEY                18150010
SRTDKEYD DS    H                       DISPLACEMENT OF KEY              18160010
SRTD     EQU   SRTDSECT,*-SRTDSECT                                      18170010
*                                                                       18180010
SRTWK    DSECT ,                                                        18190010
         DS    18A                     SAVE AREA                        18200010
SRTWKXC1 XC    0(0,R7),0(R8)           SWITCH LOWEST AND                18210010
SRTWKXC2 XC    0(0,R8),0(R7)           NEXT LOW                         18220010
SRTWKXC3 XC    0(0,R12),0(R11)         SWITCH HIGHEST AND               18230010
SRTWKXC4 XC    0(0,R11),0(R12)         NEXT HIGH                        18240010
SRTWKCLO CLC   0(0,R9),0(R7)           ENT TO LOWEST FOUND SO FAR       18250010
SRTWKCHI CLC   0(0,R9),0(R12)          ENT TO HIGHEST FOUND SO FAR      18260010
SRTWKXCS EQU   SRTWKXC1,*-SRTWKXC1     INSTRUCTIONS FOR MODIFICATION    18270010
*                                                                       18280010
         DS    (((((*-SRTWK)/256)+1)*256)-(*-SRTWK))X                   18290010
SRTWKLEN EQU   *-SRTWK                                                  18300010
R0       EQU   0                                                        18310000
R1       EQU   1                                                        18320000
R2       EQU   2                                                        18330000
R3       EQU   3                                                        18340000
R4       EQU   4                                                        18350000
R5       EQU   5                                                        18360000
R6       EQU   6                                                        18370000
R7       EQU   7                                                        18380000
R8       EQU   8                                                        18390000
R9       EQU   9                                                        18400000
R10      EQU   10                                                       18410000
R11      EQU   11                                                       18420000
R12      EQU   12                                                       18430000
R13      EQU   13                                                       18440000
R14      EQU   14                                                       18450000
R15      EQU   15                                                       18460000
         END                                                            18470000
