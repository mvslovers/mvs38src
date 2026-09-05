*********************************************************************** 00010000
*                                                                     * 00020000
*                                                                     * 00030000
*                                                                     * 00040000
*********************************************************************** 00050000
MVSASMBR CSECT                                                          00060000
         USING MVSASMBR,R15                                             00070000
         B     BEGIN                                                    00080000
         DROP  R15                                                      00090000
         DC    AL1(L'PGMID)                                             00100000
PGMID    DC    C'MVSASMBR - &SYSDATE &SYSTIME'                          00110000
BEGIN    DC    0H'+0'                                                   00120000
         STM   R14,R12,12(R13)                                          00130000
         LR    R11,R15                                                  00140000
         LA    R12,2048(,R11)                                           00150000
         LA    R12,2048(,R12)                                           00160000
         USING MVSASMBR,R11,R12                                         00170000
         LA    R14,SAVEAREA                                             00180000
         ST    R13,4(,R14)                                              00190000
         ST    R14,8(,R13)                                              00200000
         LR    R13,R14                                                  00210000
         L     R10,0(,R1)                                               00220000
         OPEN  (SYSPRINT,(OUTPUT),SYSIN,(INPUT),SYSUT2,(OUTPUT),       800230000
               LIST,(INPUT))                                            00240000
         TM    SYSPRINT+48,16                                           00250000
         BZ    QUIT                                                     00260000
         TM    SYSIN+48,16                                              00270000
         BZ    QUIT                                                     00280000
         TM    LIST+48,16                                               00290000
         BZ    QUIT                                                     00300000
         TM    SYSUT2+48,16                                             00310000
         BZ    QUIT                                                     00320000
         TIME  BIN                     GET CURRENT DATE AND TIME        00330000
         ST    R1,CURDATE              SAVE DATE                        00340000
         SRDL  R0,32                   GET DOUBLE WORD TIME             00350000
         D     R0,=F'+6000'            GET MINUTES                      00360000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00370000
         SLR   R0,R0                   CLEAR                            00380000
         D     R0,=F'+60'              GET HOURS / MINS                 00390000
         MH    R0,=H'+10000'           GET MINUTES                      00400000
         AR    R15,R0                  ADD TO GET MM:SS.TH              00410000
         M     R0,=F'+1000000'         GET HOURS                        00420000
         AR    R1,R15                  GET HH:MM:SS.TH                  00430000
         CVD   R1,DWORD                GET TIME TO DECIMAL              00440000
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   00450000
         ED    TIMWRK4,DWORD+3         EDIT TIME                        00460000
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        00470000
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  00480000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    00490000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         00500000
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        00510000
         DP    DWORD,=P'+4'            DIVIDE BY 4                      00520000
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              00530000
         BNZ   JULCVT2                  NO                              00540000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    00550000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         00560000
JULCVT2  DS    0H                                                       00570000
         LA    R1,JULTBL1              POINT TO JANUARY                 00580000
         SLR   R2,R2                   SET COUNTER                      00590000
JULCVT4  DS    0H                                                       00600000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              00610000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  00620000
         BCTR  R1,0                    POINT TO NEXT MONTH              00630000
         BCTR  R1,0                    POINT TO NEXT MONTH              00640000
         LA    R2,3(,R2)               UP INDEX                         00650000
         B     JULCVT4                 LOOP                             00660000
JULCVT6  DS    0H                                                       00670000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                00680000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    00690000
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       00700000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     00710000
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         00720000
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   00730000
         LA    R1,HD1DATE+6            SET POINTER                      00740000
         BNE   JULCVT7                  NO                              00750000
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 00760000
         BCTR  R1,0                    DROP POINTER                     00770000
JULCVT7  DS    0H                                                       00780000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  00790000
         TM    CURDATE,1               YEAR 2000?                       00800000
         BNO   JULCVT8                  NO, CONTINUE                    00810000
         MVC   2(2,R1),=C'20'          Y2K                              00820000
JULCVT8  DS    0H                                                       00830000
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      00840000
         MVC   4(2,R1),DWORD           GET YEAR                         00850000
         CLI   1(R10),4                                                 00860000
         BNE   PRMERR                                                   00870000
         LA    R1,2(R10)                                                00880000
         LA    R15,4                                                    00890000
         BAL   R14,CVTHEX                                               00900000
         LTR   R15,R15                                                  00910000
         BNE   PRMERR                                                   00920000
         ST    R0,BASEVAL                                               00930000
         MVC   LINE+1(13),=C'BEGIN PHASE 1'                             00940000
         BAL   R14,PRT                                                  00950000
*********************************************************************** 00960000
*                                                                     * 00970000
*----+----1----+----2----+----3----+----4----+----5----+----6---      * 00980000
*AAAAAAAA MVC   2123(131,@06),2122(@06)          84B  84A ??????      * 00990000
*                                                                     * 01000000
*AAAAAAAA MVC   2123(131,@06),2122(@06)         XXXX XXXX ??????      * 01010000
*                                                                     * 01020000
*********************************************************************** 01030000
SCAN     DS    0H                                                       01040000
         GET   SYSIN,CARD                                               01050000
         CLC   =C'??????',CARD+57                                       01060000
         BNE   SCAN                                                     01070000
         CLI   CARD+48,C' '                                             01080000
         BE    SCN2ND                                                   01090000
         LA    R1,CARD+48                                               01100000
         LA    R15,3                                                    01110000
         BAL   R14,CVTHEX                                               01120000
         LTR   R15,R15                                                  01130000
         BNE   INVBR1                                                   01140000
         A     R0,BASEVAL                                               01150000
         ST    R0,DWORD                                                 01160000
         UNPK  NEWOFF,DWORD+2(3)                                        01170000
         TR    NEWOFF(4),HEXTBL-240                                     01180000
         BAL   R14,TBLIT                                                01190000
SCN2ND   DS    0H                                                       01200000
         CLI   CARD+53,C' '                                             01210000
         BE    SCAN                                                     01220000
         LA    R1,CARD+53                                               01230000
         LA    R15,3                                                    01240000
         BAL   R14,CVTHEX                                               01250000
         LTR   R15,R15                                                  01260000
         BNE   INVBR2                                                   01270000
         A     R0,BASEVAL                                               01280000
         ST    R0,DWORD                                                 01290000
         UNPK  NEWOFF,DWORD+2(3)                                        01300000
         TR    NEWOFF(4),HEXTBL-240                                     01310000
         BAL   R14,TBLIT                                                01320000
         B     SCAN                                                     01330000
*********************************************************************** 01340000
*                                                                     * 01350000
*                                                                     * 01360000
*                                                                     * 01370000
*********************************************************************** 01380000
PREPROC  DS    0H                                                       01390000
         MVC   LINE+1(13),=C'BEGIN PHASE 2'                             01400000
         BAL   R14,PRT                                                  01410000
         MVI   PHASE,C'2'                                               01420000
PREGET   DS    0H                                                       01430000
         GET   LIST,LINE                                                01440000
         LA    R1,TBL                                                   01450000
PRESCN   DS    0H                                                       01460000
         C     R1,TBLEND                                                01470000
         BE    PREGET                                                   01480000
         CLC   LINE+3(4),0(R1)                                          01490000
         BE    PREHIT                                                   01500000
PRENXT   DS    0H                                                       01510000
         LA    R1,12(,R1)                                               01520000
         B     PRESCN                                                   01530000
PREHIT   DS    0H                                                       01540000
         CLC   LINE+41(3),=C'Q00'                                       01550000
         BE    PRENXT                                                   01560000
         MVC   4(8,R1),LINE+41                                          01570000
         B     PREGET                                                   01580000
EOFLST   DS    0H                                                       01590000
         MVI   LINE,C' '                                                01600000
         MVC   LINE+1(L'LINE-1),LINE                                    01610000
         MVC   LINE+1(13),=C'BEGIN PHASE 3'                             01620000
         BAL   R14,PRT                                                  01630000
         MVI   PHASE,C'3'                                               01640000
         CLOSE (SYSIN)                                                  01650000
         OPEN  (SYSIN,(INPUT))                                          01660000
*********************************************************************** 01670000
*                                                                     * 01680000
*                                                                     * 01690000
*                                                                     * 01700000
*********************************************************************** 01710000
PROC     DS    0H                                                       01720000
         MVI   CARD,C' '                                                01730000
         MVC   CARD+1(L'CARD-1),CARD                                    01740000
         GET   SYSIN,CARD                                               01750000
         CLC   =C'??????',CARD+57                                       01760000
         BNE   PUTIT                                                    01770000
         CLI   CARD+48,C' '                                             01780000
         BE    CHK2ND                                                   01790000
         LA    R1,CARD+48                                               01800000
         LA    R15,3                                                    01810000
         BAL   R14,CVTHEX                                               01820000
         LTR   R15,R15                                                  01830000
         BNE   INVBR1                                                   01840000
         A     R0,BASEVAL                                               01850000
         ST    R0,DWORD                                                 01860000
         UNPK  NEWOFF,DWORD+2(3)                                        01870000
         TR    NEWOFF(4),HEXTBL-240                                     01880000
         MVC   CARD+82(4),NEWOFF                                        01890000
         BAL   R14,TBLIT                                                01900000
         MVC   CARD+88(8),4(R1)                                         01910000
CHK2ND   DS    0H                                                       01920000
         CLI   CARD+53,C' '                                             01930000
         BE    PUTIT                                                    01940000
         LA    R1,CARD+53                                               01950000
         LA    R15,3                                                    01960000
         BAL   R14,CVTHEX                                               01970000
         LTR   R15,R15                                                  01980000
         BNE   INVBR2                                                   01990000
         A     R0,BASEVAL                                               02000000
         ST    R0,DWORD                                                 02010000
         UNPK  NEWOFF,DWORD+2(3)                                        02020000
         TR    NEWOFF(4),HEXTBL-240                                     02030000
         MVC   CARD+99(4),NEWOFF                                        02040000
         BAL   R14,TBLIT                                                02050000
         MVC   CARD+105(8),4(R1)                                        02060000
PUTIT    DS    0H                                                       02070000
         PUT   SYSUT2,CARD                                              02080000
         B     PROC                                                     02090000
*********************************************************************** 02100000
*                                                                     * 02110000
*********************************************************************** 02120000
TBLIT    DS    0H                                                       02130000
         ST    R14,TBLITR14                                             02140000
         LA    R1,TBL                                                   02150000
TBLITA   DS    0H                                                       02160000
         C     R1,TBLTOP                                                02170000
         BNL   TBLOFL                                                   02180000
         C     R1,TBLEND                                                02190000
         BE    TBLITB                                                   02200000
         CLC   0(4,R1),NEWOFF                                           02210000
         BE    TBLITC                                                   02220000
         LA    R1,12(,R1)                                               02230000
         B     TBLITA                                                   02240000
TBLITB   DS    0H                                                       02250000
         MVC   0(4,R1),NEWOFF                                           02260000
         LA    R1,12(,R1)                                               02270000
         ST    R1,TBLEND                                                02280000
TBLITC   DS    0H                                                       02290000
         L     R14,TBLITR14                                             02300000
         BR    R14                                                      02310000
*********************************************************************** 02320000
*                                                                     * 02330000
* R1=INPUT HEX DIGITS                                                 * 02340000
* R15=NUM DIGITS                                                      * 02350000
* R0=RESULT                                                           * 02360000
* R15=0=OK 8=ERROR                                                    * 02370000
*                                                                     * 02380000
*********************************************************************** 02390000
CVTHEX   DS    0H                                                       02400000
         ST    R14,CVTHEX14                                             02410000
         LA    R0,0                                                     02420000
CVTHEX1  DS    0H                                                       02430000
         IC    R14,0(,R1)                                               02440000
         N     R14,=A(15)                                               02450000
         CLI   0(R1),C'A'                                               02460000
         BL    CVTHEX8                                                  02470000
         CLI   0(R1),C'F'                                               02480000
         BH    CVTHEX2                                                  02490000
         LA    R14,9(,R14)                                              02500000
         B     CVTHEX3                                                  02510000
CVTHEX2  DS    0H                                                       02520000
         CLI   0(R1),C'0'                                               02530000
         BL    CVTHEX8                                                  02540000
         CLI   0(R1),C'9'                                               02550000
         BH    CVTHEX8                                                  02560000
CVTHEX3  DS    0H                                                       02570000
         SLL   R0,4                                                     02580000
         AR    R0,R14                                                   02590000
         LA    R1,1(,R1)                                                02600000
         BCT   R15,CVTHEX1                                              02610000
         B     CVTHEX9                                                  02620000
CVTHEX8  DS    0H                                                       02630000
         LA    R15,8                                                    02640000
CVTHEX9  DS    0H                                                       02650000
         L     R14,CVTHEX14                                             02660000
         BR    R14                                                      02670000
*********************************************************************** 02680000
*                                                                     * 02690000
*                                                                     * 02700000
*                                                                     * 02710000
*********************************************************************** 02720000
PRMERR   DS    0H                                                       02730000
         MVC   LINE+1(19),=C'PARM=NOT 4 DIGITS HEX'                     02740000
         BAL   R14,PRT                                                  02750000
         B     ERRXIT                                                   02760000
INVBR1   DS    0H                                                       02770000
         MVC   LINE+1(20),=C'INVALID DISPLACEMENT 1'                    02780000
         BAL   R14,PRT                                                  02790000
         B     ERRCRD                                                   02800000
INVBR2   DS    0H                                                       02810000
         MVC   LINE+1(20),=C'INVALID DISPLACEMENT 2'                    02820000
         BAL   R14,PRT                                                  02830000
         B     ERRCRD                                                   02840000
TBLOFL   DS    0H                                                       02850000
         MVC   LINE+1(12),=C'TABLE OVERFLOW'                            02860000
         BAL   R14,PRT                                                  02870000
         B     ERRXIT                                                   02880000
ERRCRD   DS    0H                                                       02890000
         MVC   LINE+1(80),CARD                                          02900000
         BAL   R14,PRT                                                  02910000
ERRXIT   DS    0H                                                       02920000
         LA    R15,8                                                    02930000
         B     EXIT                                                     02940000
EOFIN    DS    0H                                                       02950000
         CLI   PHASE,C'1'                                               02960000
         BE    PREPROC                                                  02970000
         BAL   R14,PRT                                                  02980000
         LA    R2,TBL                                                   02990000
         SR    R3,R3                                                    03000000
         SR    R4,R4                                                    03010000
TRMTP    DS    0H                                                       03020000
         C     R2,TBLEND                                                03030000
         BE    TRMTE                                                    03040000
         LA    R3,1(,R3)                                                03050000
         CLI   4(R2),C' '                                               03060000
         BNE   TRMNXT                                                   03070000
         LA    R4,1(,R4)                                                03080000
         MVC   LINE+1(4),0(R2)                                          03090000
         MVC   LINE+7(8),4(R2)                                          03100000
         BAL   R14,PRT                                                  03110000
TRMNXT   DS    0H                                                       03120000
         LA    R2,12(,R2)                                               03130000
         B     TRMTP                                                    03140000
TRMTE    DS    0H                                                       03150000
         MVC   LINE+1(22),=C'DISPLACEMENT UNMATCHES'                    03160000
         MVC   LINE+25(12),=X'402020206B2020206B202120'                 03170000
         CVD   R4,DWORD                                                 03180000
         ED    LINE+25(12),DWORD+3                                      03190000
         BAL   R14,PRT                                                  03200000
         MVC   LINE+1(20),=C'DISPLACEMENT MATCHED'                      03210000
         MVC   LINE+25(12),=X'402020206B2020206B202120'                 03220000
         LR    R0,R4                                                    03230000
         SR    R0,R3                                                    03240000
         CVD   R0,DWORD                                                 03250000
         ED    LINE+25(12),DWORD+3                                      03260000
         BAL   R14,PRT                                                  03270000
         MVC   LINE+1(18),=C'DISPLACEMENT FOUND'                        03280000
         MVC   LINE+25(12),=X'402020206B2020206B202120'                 03290000
         CVD   R3,DWORD                                                 03300000
         ED    LINE+25(12),DWORD+3                                      03310000
         BAL   R14,PRT                                                  03320000
         LA    R15,0                                                    03330000
EXIT     DS    0H                                                       03340000
         LR    R2,R15                                                   03350000
         CLOSE (SYSPRINT,,SYSIN,,SYSUT2)                                03360000
         L     R13,4(,R13)                                              03370000
         L     R14,12(,R13)                                             03380000
         LR    R15,R2                                                   03390000
         LM    R1,R12,20(R13)                                           03400000
         BR    R14                                                      03410000
QUIT     DS    0H                                                       03420000
         L     R13,4(,R13)                                              03430000
         LM    R14,R12,12(R13)                                          03440000
         LA    R15,16                                                   03450000
         BR    R14                                                      03460000
**********************************************************************  03470000
*                                                                       03480000
*            WRITE PRINT LINE                                           03490000
*                                                                       03500000
**********************************************************************  03510000
PRT      DS    0H                                                       03520000
         ST    R14,PRTR14                                               03530000
         CP    LNCT,=P'+60'            END OF PAGE                      03540000
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   03550000
PRTHDRS  DS    0H                                                       03560000
         AP    PGCT,=P'+1'             COUNT PAGES                      03570000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  03580000
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  03590000
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  03600000
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  03610000
         MVI   LINE,C'0'               SKIP AFTER HEADING               03620000
PRTCHK   DS    0H                                                       03630000
         CLI   LINE,C'+'               OVERPRINT ?                      03640000
         BE    PRTLINE                  YES, DON'T COUNT                03650000
         CLI   LINE,C'1'               NEW LINE ?                       03660000
         BE    PRTHDRS                  YES, PRINT HEADER               03670000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         03680000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            03690000
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         03700000
         BE    PRTLINE2                 YES, GO CHECK IF FIT            03710000
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         03720000
         BE    PRTLINE3                 YES, GO CHECK IF FIT            03730000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       03740000
PRTLINE1 DS    0H                                                       03750000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                03760000
         B     PRTVFY                  GO SEE IF IT WILL FIT            03770000
PRTLINE2 DS    0H                                                       03780000
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                03790000
         B     PRTVFY                  GO SEE IF IT WILL FIT            03800000
PRTLINE3 DS    0H                                                       03810000
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                03820000
PRTVFY   DS    0H                                                       03830000
         CP    LNCT,=P'+60'            OVERFLOW ?                       03840000
         BH    PRTHDRS                  YES, FORCE HEADER               03850000
PRTLINE  DS    0H                                                       03860000
         PUT   SYSPRINT,LINE           PRINT A LINE                     03870000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          03880000
         MVC   LINE+1(L'LINE-1),LINE                                    03890000
         L     R14,PRTR14                                               03900000
         BR    R14                     RETURN TO CALLER                 03910000
**********************************************************************  03920000
*                                                                     * 03930000
*        DUMP DATA                                                    * 03940000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 03950000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 03960000
*                                                                     * 03970000
*********************************************************************** 03980000
DMP      DS    0H                                                       03990000
         STM   R0,R15,DMPREGS          SAVE REGISTERS                   04000000
         LR    R3,R1                   GET ADDRESS TO DUMP              04010000
         LR    R4,R0                   GET LENGTH                       04020000
         XC    DMPOFF,DMPOFF           SAVE OFFSET FOR DUMP             04030000
         MVI   DMPFLAG,DMPFIRST        FIRST LINE                       04040000
DMPDMPLP DS    0H                                                       04050000
         LTR   R4,R4                   ANY DATA TO DUMP ?               04060000
         BZ    DMPHEXXT                 YES, ALL DONE                   04070000
         TM    DMPFLAG,DMPFIRST        FIRST LINE?                      04080000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   04090000
         LA    R0,32                   DEFAULT LENGTH                   04100000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          04110000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           04120000
         LR    R14,R3                  GET CURRENT INPUT AREA           04130000
         SR    R14,R0                  BACK TO PREVIOUS AREA            04140000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       04150000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            04160000
         SR    R4,R0                   REDUCE LENGTH TO DO              04170000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           04180000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       04190000
         L     R14,DMPOFF              GET CURRENT OFFSET               04200000
         ST    R14,DUPFIRST            SAVE AS FIRST OFFSET             04210000
         OI    DMPFLAG,DMPDUP          SET DUPLICATE                    04220000
         B     DMPNXTLN                CONTINUE                         04230000
DMPDUPCK DS    0H                                                       04240000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           04250000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      04260000
         MVC   LINE+7(5),=C'LINES'     MOVE LITERAL                     04270000
         LA    R2,LINE+13              OUTPUT AREA ADDRESS              04280000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        04290000
         LA    R15,2                   CONVERT 4 BYTES                  04300000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            04310000
         MVI   LINE+17,C'-'            THRU LITERAL                     04320000
         L     R1,DMPOFF               GET CURRENT OFFSET               04330000
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        04340000
         ST    R1,DUPFIRST             SAVE FOR DUMPING                 04350000
         LA    R2,LINE+18              OUTPUT AREA ADDRESS              04360000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        04370000
         LA    R15,2                   CONVERT 4 BYTES                  04380000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            04390000
         MVC   LINE+23(13),=C'SAME AS ABOVE' MOVE LITERAL               04400000
         BAL   R14,PRT                 PRINT A LINE                     04410000
         NI    DMPFLAG,255-DMPDUP      RESET DUPLICATE IN PROGRESS      04420000
DMPALIN  DS    0H                                                       04430000
         ST    R3,W#DADR           SAVE ADDRESS                         04440000
         LA    R2,LINE+1           OUTPUT AREA ADDRESS                  04450000
         LA    R1,W#DADR           ADDRESS OF ADDRESS                   04460000
         LA    R15,4               CONVERT 8 BYTES                      04470000
         BAL   R14,DMPDSP          CONVERT IT TO DISPLAY                04480000
         LA    R2,1(,R2)           SKIP 1 BETWEEN ADDRESS & OFFSET      04490000
         LA    R1,DMPOFF+2             ADDRESS OF OFFSET TO DUMP        04500000
         LA    R15,2                   CONVERT 4 BYTES                  04510000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            04520000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     04530000
         LR    R1,R3                   ADDRESS OF DATA                  04540000
         LA    R5,32                   DEFAULT LENGTH                   04550000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          04560000
         BH    DMPDODMP                 YES, USE 32                     04570000
         LR    R5,R4                   USE WHAT IS LEFT                 04580000
DMPDODMP DS    0H                                                       04590000
         SR    R4,R5                   REDUCE AMOUNT TO DO              04600000
         MVI   LINE+89,C'*'            BOX IN DISPLAY PORTION           04610000
         BCTR  R5,0                    MAKE ZERO BASED                  04620000
         EX    R5,DMPMVC               DO MOVE                          04630000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          04640000
         LA    R5,1(,R5)               RESTORE LENGTH                   04650000
         MVI   LINE+122,C'*'           COMPLETE BOX                     04660000
DMPDMPHX DS    0H                                                       04670000
         LA    R15,4                   4 BYTES TO PROCESS               04680000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           04690000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               04700000
         LR    R15,R5                  USE LENGTH LEFT                  04710000
DMPDMPIT DS    0H                                                       04720000
         SR    R5,R15                  REDUCE AMOUNT TO DO              04730000
         BAL   R14,DMPDSP              CONVERT DATA                     04740000
         LA    R2,1(,R2)               SKIP 1 BYTE                      04750000
         LA    R0,LINE+43              HALFWAY POINT ADDRESS            04760000
         CR    R0,R2                   AT HALFWAY POINT?                04770000
         BNE   DMPDMPNX                 NO, CONTINUE                    04780000
         LA    R2,1(,R2)               SKIP 1 BYTE                      04790000
DMPDMPNX DS    0H                                                       04800000
         LTR   R5,R5                   ANY LEFT TO DO ?                 04810000
         BH    DMPDMPHX                 YES, GO DO IT                   04820000
         BAL   R14,PRT                 PRINT A LINE                     04830000
DMPNXTLN DS    0H                                                       04840000
         L     R1,DMPOFF               GET OFFSET IN RECORD             04850000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       04860000
         ST    R1,DMPOFF               SAVE OFFSET IN RECORD            04870000
         LA    R3,32(,R3)              NEXT INPUT AREA                  04880000
         NI    DMPFLAG,255-DMPFIRST    NOT FIRST LINE                   04890000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             04900000
DMPHEXXT DS    0H                                                       04910000
         LM    R0,R15,DMPREGS          RESTORE CALLERS REGS             04920000
         BR    R14                     EXIT . . .                       04930000
DMPMVC   MVC   LINE+90(0),0(R1)        <<< EXECUTED >>>                 04940000
DMPTR    TR    LINE+90(0),DMPTBLCH     <<< EXECUTED >>>                 04950000
*                                                                       04960000
*                                                                       04970000
*                                                                       04980000
DMPDSP   DS    0H                                                       04990000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               05000000
         NI    0(R2),X'0F'             REMOVE ZONE                      05010000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             05020000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             05030000
         TR    0(2,R2),=C'0123456789ABCDEF' TRANSLATE TO HEX            05040000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        05050000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         05060000
         BCT   R15,DMPDSP              LOOP THRU DATA                   05070000
         BR    R14                     EXIT . . .                       05080000
*                                                                       05090000
*                                                                       05100000
*                                                                       05110000
         LTORG ,                                                        05120000
SAVEAREA DC    18A(0)                                                   05130000
DMPREGS  DC    16A(0)                                                   05140000
TRCREGS  DC    16A(0)                                                   05150000
DMPOFF   DS    A                                                        05160000
W#DADR   DS    A                                                        05170000
DUPFIRST DS    A                                                        05180000
DMPFLAG  DC    X'00'                                                    05190000
DMPFIRST EQU   X'80'                                                    05200000
DMPDUP   EQU   X'40'                                                    05210000
PHASE    DC    C'1'                                                     05220000
DMPTBLCH DC    CL256' '                                                 05230000
         ORG   DMPTBLCH+X'4A' Cent                                      05240000
         DC    X'4A4B4C4D4E4F50' vert bar and ampersand                 05250000
         ORG   DMPTBLCH+X'5A' exclamation                               05260000
         DC    X'5A5B5C5D5E5F6061'                                      05270000
         ORG   DMPTBLCH+X'6A'                                           05280000
         DC    X'6A6B6C6D6E6F'                                          05290000
         ORG   DMPTBLCH+X'7A'                                           05300000
         DC    X'7A7B7C7D7E7F'                                          05310000
         ORG   DMPTBLCH+C'a'                                            05320000
         DC    C'abcdefghi'                                             05330000
         ORG   DMPTBLCH+C'j'                                            05340000
         DC    C'jklmnopqr'                                             05350000
         ORG   DMPTBLCH+C's'                                            05360000
         DC    C'stuvwxyz'                                              05370000
         ORG   DMPTBLCH+C'A'                                            05380000
         DC    C'ABCDEFGHI'                                             05390000
         ORG   DMPTBLCH+C'J'                                            05400000
         DC    C'JKLMNOPQR'                                             05410000
         ORG   DMPTBLCH+C'S'                                            05420000
         DC    C'STUVWXYZ'                                              05430000
         ORG   DMPTBLCH+C'0'                                            05440000
         DC    C'0123456789'                                            05450000
         ORG                                                            05460000
HEXTBL   DC    C'0123456789ABCDEF'                                      05470000
DWORD    DC    D'+0'                                                    05480000
PRTR14   DC    A(0)                                                     05490000
CVTHEX14 DC    A(0)                                                     05500000
TBLITR14 DC    A(0)                                                     05510000
TBLTOP   DC    A(TBLZ)                                                  05520000
TBLEND   DC    A(TBL)                                                   05530000
BASEVAL  DC    A(0)                                                     05540000
LINE     DC    CL133' '                                                 05550000
CARD     DC    CL133' '                                                 05560000
NEWOFF   DC    C'OOOOJ'                                                 05570000
CURDATE  DC    A(0)                                                     05580000
JULWRK2  DC    A(0)                                                     05590000
JULWRK4  DC    P'+365'                                                  05600000
         DC    P'+01'                                                   05610000
         DC    P'+31'                                                   05620000
         DC    P'+30'                                                   05630000
         DC    P'+31'                                                   05640000
         DC    P'+30'                                                   05650000
         DC    P'+31'                                                   05660000
         DC    P'+31'                                                   05670000
         DC    P'+30'                                                   05680000
         DC    P'+31'                                                   05690000
         DC    P'+30'                                                   05700000
         DC    P'+31'                                                   05710000
JULWRK6  DC    P'+28'                                                   05720000
JULTBL1  DC    P'+31'                                                   05730000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  05740000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            05750000
LNCT     DC    PL2'+99'                                                 05760000
PGCT     DC    PL2'+0'                                                  05770000
HD1      DC    CL133'1'                                                 05780000
         ORG   HD1+1                                                    05790000
HD1DATE  DC    C'            '                                          05800000
         DC    C' '                                                     05810000
HD1TOD   DC    C'HH:MM:SS'                                              05820000
         ORG   HD1+66-(28/2)                                            05830000
HD1DATA  DC    CL28'ASSEMBLY BASE REGISTER CONVERTER'                   05840000
         ORG   HD1+L'HD1-8                                              05850000
HD1PG    DC    C'Page'                                                  05860000
HD1PGCT  DC    C' 123'                                                  05870000
SYSIN    DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=EOFIN               05880000
LIST     DCB   DDNAME=LIST,MACRF=GM,DSORG=PS,EODAD=EOFLST               05890000
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X05900000
               RECFM=FBA,LRECL=133                                      05910000
SYSUT2   DCB   DDNAME=SYSUT2,MACRF=PM,DSORG=PS,                        X05920000
               RECFM=FB,LRECL=133                                       05930000
         DC    0D'0'                                                    05940000
TBL      DC    5000CL12' '                                              05950000
TBLZ     EQU   *                                                        05960000
R0       EQU   0                                                        05970000
R1       EQU   1                                                        05980000
R2       EQU   2                                                        05990000
R3       EQU   3                                                        06000000
R4       EQU   4                                                        06010000
R5       EQU   5                                                        06020000
R6       EQU   6                                                        06030000
R7       EQU   7                                                        06040000
R8       EQU   8                                                        06050000
R9       EQU   9                                                        06060000
R10      EQU   10                                                       06070000
R11      EQU   11                                                       06080000
R12      EQU   12                                                       06090000
R13      EQU   13                                                       06100000
R14      EQU   14                                                       06110000
R15      EQU   15                                                       06120000
         END                                                            06130000
