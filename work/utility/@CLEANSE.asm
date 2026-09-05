*********************************************************************** 00010015
*                                                                     * 00020015
* Module name                                                         * 00030015
*    @CLEANSE                                                         * 00040015
*                                                                     * 00050015
* Attributes                                                          * 00060015
*    None                                                             * 00070015
*                                                                     * 00080015
* Authoe                                                              * 00090015
*    Dave Kreiss                                                      * 00100015
*                                                                     * 00110015
* Function                                                            * 00120015
*    Clean up output of disassembler.                                 * 00130015
*                                                                     * 00140015
* JCL                                                                 * 00150015
*    //        EXEC PGM=@CLEANSE,PARM='parameters'                    * 00160015
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00170015
*    //SYSPRINT DD  SYSOUT=*                                          * 00180015
*    //SYSUT1   DD  DSN=input source                                  * 00190015
*    //SYSUT2   DD  DSN=output source                                 * 00200015
*    //SYSPRINT DD  *                                                 * 00210015
*                                                                     * 00220015
* DD Statements                                                       * 00230015
*    STEPLIB       Load library containing the load module.           * 00240015
*    SYSPRINT      Summary of cleanse operation.                      * 00250015
*    SYSUT1        Input source file.                                 * 00260015
*    SYSUT2        Output source file.                                * 00270015
*    insdd         DDs containing inserted records - see PARM=INS=    * 00280015
*                                                                     * 00290015
* Parameters                                                          * 00300015
*    Parameters are seperated by commas.                              * 00310015
*    DEBUG         DEBUG enables diagnostics.                         * 00320015
*    IMBED(n)      Delete n ASMDREG source statements.                * 00330015
*    NOREGS        Suppress generation of R0-R15 equates.             * 00340015
*    KEEPDIS       Keep disassembled code (CC49 on)                   * 00350016
*    INS=          Can take two forms:                                * 00360015
*                  INS=n,'record' - only last used                    * 00370015
*                  INS=n,insdd - can have multiple                    * 00380015
*                  n=line number                                      * 00390015
*                  'record' the quoted string is inserted at line n.  * 00400015
*                  The statements in the specified DD is inserted     * 00410015
*                  at line n.                                         * 00420015
*    DEL=(n,n..)   Delete line numbers n etc.                         * 00430015
*                                                                     * 00440015
*********************************************************************** 00450015
* Change log:                                                         * 00460015
*   Date   Int Ver   Description                                      * 00470015
* 10/11/14 DSK 1.01  Created                                          * 00480015
* 09/07/20 DSK 1.02                                                   * 00490015
* 07/31/20 DSK 1.03  Document, add PARM=DEL=                          * 00500015
*********************************************************************** 00510015
*                                                                       00520013
*                                                                       00530013
*                                                                       00540013
INSTBLDS DSECT                                                          00550013
INSTBLNO DS    PL8                                                      00560013
INSTBLDD DS    CL8                                                      00570013
INSTBL   EQU   INSTBLDS,*-INSTBLDS                                      00580013
@CLEANSE CSECT                                                          00590000
*********************************************************************** 00600015
*********************************************************************** 00610015
**       Initialization                                              ** 00620015
*********************************************************************** 00630015
*********************************************************************** 00640015
         USING @CLEANSE,R15                                             00650000
         B     BEGIN                                                    00660000
         DROP  R15                                                      00670000
         DC    AL1(L'PGMID)                                             00680000
PGMID    DC    C'@CLEANSE - V1.03 &SYSDATE &SYSTIME'                    00690015
BEGIN    DC    0H'+0'                                                   00700000
         STM   R14,R12,12(R13)                                          00710000
         LR    R11,R15                                                  00720000
         LA    R12,2048(,R11)                                           00730000
         LA    R12,2048(,R12)                                           00740000
         USING @CLEANSE,R11,R12                                         00750000
         LA    R14,SAVEAREA                                             00760000
         ST    R13,4(,R14)                                              00770000
         ST    R14,8(,R13)                                              00780000
         LR    R13,R14                                                  00790000
         L     R10,0(,R1)                                               00800000
         OPEN  (SYSPRINT,(OUTPUT),SYSUT1,(INPUT),SYSUT2,(OUTPUT))       00810000
         TM    SYSPRINT+48,16                                           00820000
         BZ    QUIT                                                     00830000
         TM    SYSUT1+48,16                                             00840000
         BZ    QUIT                                                     00850000
         TM    SYSUT2+48,16                                             00860000
         BZ    QUIT                                                     00870000
         TIME  BIN                     GET CURRENT DATE AND TIME        00880000
         ST    R1,CURDATE              SAVE DATE                        00890000
         SRDL  R0,32                   GET DOUBLE WORD TIME             00900000
         D     R0,=F'+6000'            GET MINUTES                      00910000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00920000
         SLR   R0,R0                   CLEAR                            00930000
         D     R0,=F'+60'              GET HOURS / MINS                 00940000
         MH    R0,=H'+10000'           GET MINUTES                      00950000
         AR    R15,R0                  ADD TO GET MM:SS.TH              00960000
         M     R0,=F'+1000000'         GET HOURS                        00970000
         AR    R1,R15                  GET HH:MM:SS.TH                  00980000
         CVD   R1,DWORD                GET TIME TO DECIMAL              00990000
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   01000000
         ED    TIMWRK4,DWORD+3         EDIT TIME                        01010000
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        01020000
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  01030000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    01040000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         01050000
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        01060000
         DP    DWORD,=P'+4'            DIVIDE BY 4                      01070000
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              01080000
         BNZ   JULCVT2                  NO                              01090000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    01100000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         01110000
JULCVT2  DS    0H                                                       01120000
         LA    R1,JULTBL1              POINT TO JANUARY                 01130000
         SLR   R2,R2                   SET COUNTER                      01140000
JULCVT4  DS    0H                                                       01150000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              01160000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  01170000
         BCTR  R1,0                    POINT TO NEXT MONTH              01180000
         BCTR  R1,0                    POINT TO NEXT MONTH              01190000
         LA    R2,3(,R2)               UP INDEX                         01200000
         B     JULCVT4                 LOOP                             01210000
JULCVT6  DS    0H                                                       01220000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                01230000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    01240000
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       01250000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     01260000
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         01270000
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   01280000
         LA    R1,HD1DATE+6            SET POINTER                      01290000
         BNE   JULCVT7                  NO                              01300000
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 01310000
         BCTR  R1,0                    DROP POINTER                     01320000
JULCVT7  DS    0H                                                       01330000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  01340000
         TM    CURDATE,1               YEAR 2000?                       01350000
         BNO   JULCVT8                  NO, CONTINUE                    01360000
         MVC   2(2,R1),=C'20'          Y2K                              01370000
JULCVT8  DS    0H                                                       01380000
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      01390000
         MVC   4(2,R1),DWORD           GET YEAR                         01400000
         MVC   LINE+1(8),=C'Version='  Move version literal             01410000
         MVC   LINE+9(L'PGMID),PGMID   Move version                     01420000
         BAL   R14,PRT                 PRINT A LINE                     01430000
*********************************************************************** 01440015
*        Parse PARM=                                                  * 01450015
*********************************************************************** 01460015
         MVC   LINE+1(5),=C'PARM='     MOVE PARAMETER INFO LITERAL      01470000
         CLI   1(R10),0                ANY PARAMETER?                   01480000
         BE    PRMPRT                  NO, SKIP MOVE                    01490000
         LH    R1,0(,R10)              GET PARMETER LENGTH              01500000
         BCTR  R1,0                    MAKE MACHINE LENGTH              01510000
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE          01520000
         B     PRMPRT                                                   01530000
PRMMVC   MVC   LINE+6(0),2(R10)        EXECUTED PARM MOVE               01540000
PRMPRT   DS    0H                                                       01550000
         BAL   R14,PRT                 PRINT A LINE                     01560000
         LH    R2,0(,R10)              GET PARM LENGTH                  01570000
         LA    R10,2(,R10)             SKIP LENGTH                      01580000
         ST    R10,PRMSTART            SAVE PARM START                  01590000
PRMSCN   DS    0H                                                       01600000
         LTR   R2,R2                   END OF PARM?                     01610000
         BZ    PRMEND                  YES, PARM PARSED                 01620000
         CLI   0(R10),C','             SEPERATOR?                       01630000
         BNE   PRMCHK                  NO, CHECK VALUES                 01640000
         LA    R10,1(,R10)             SKIP COMMA                       01650000
         BCTR  R2,0                    DECREMENT LENGTH                 01660000
         B     PRMSCN                  CONTINUE SCAN                    01670000
PRMCHK   DS    0H                                                       01680000
         CH    R2,=H'5'                LONG ENOUGH?                     01690000
         BL    PRMERR                  No, error                        01700000
         CLC   =C'DEBUG',0(R10)        DEBUG?                           01710000
         BE    PRMDBG                  Yes, handle it                   01720000
         CLC   =C'IMBED',0(R10)        IMBED?                           01730000
         BE    PRMIMB                  Yes, handle it                   01740000
         CLC   =C'INS=',0(R10)         INSERT?                          01750000
         BE    PRMINS                  Yes, handle it                   01760000
         CH    R2,=H'6'                LONG ENOUGH?                     01770000
         BL    PRMERR                  No, error                        01780000
         CLC   =C'NOREGS',0(R10)       NOREGS?                          01790000
         BE    PRMNRG                  Yes, handle it                   01800000
         CLC   =C'DEL=(',0(R10)        DELETE?                          01810015
         BE    PRMDEL                  Yes, handle it                   01820015
         CH    R2,=H'7'                LONG ENOUGH?                     01830016
         BL    PRMERR                  No, error                        01840016
         CLC   =C'KEEPDIS',0(R10)      KEEPDIS?                         01850016
         BE    PRMKDI                  Yes, handle it                   01860016
         B     PRMERR                  Error                            01870000
*********************************************************************** 01880015
*        DEBUG                                                        * 01890015
*********************************************************************** 01900015
PRMDBG   DS    0H                                                       01910000
         OI    FLAG,FLAGDBG            SET DEBUG                        01920000
         LA    R10,5(,R10)             SKIP VALUE                       01930000
         SH    R2,=H'5'                DECREMENT LENGTH                 01940000
         B     PRMSCNC                 CONTINUE SCAN                    01950000
*********************************************************************** 01960015
*        NOREGS                                                       * 01970015
*********************************************************************** 01980015
PRMNRG   DS    0H                                                       01990000
         OI    FLAG,FLAGNRG            SET DEBUG                        02000000
         LA    R10,6(,R10)             SKIP VALUE                       02010000
         SH    R2,=H'6'                DECREMENT LENGTH                 02020000
         B     PRMSCNC                 CONTINUE SCAN                    02030000
*********************************************************************** 02040016
*        KEEPDIS                                                      * 02050016
*********************************************************************** 02060016
PRMKDI   DS    0H                                                       02070016
         OI    FLAG,FLAGKDI            SET KEEPDIS                      02080016
         LA    R10,7(,R10)             SKIP VALUE                       02090016
         SH    R2,=H'7'                DECREMENT LENGTH                 02100016
         B     PRMSCNC                 CONTINUE SCAN                    02110016
*********************************************************************** 02120015
*        IMBED(n)                                                     * 02130015
*********************************************************************** 02140015
PRMIMB   DS    0H                                                       02150000
         OI    FLAG,FLAGIMB            SET IMBED                        02160000
         LA    R10,5(,R10)             SKIP VALUE                       02170000
         SH    R2,=H'5'                DECREMENT LENGTH                 02180000
         BZ    PRMSCNC                                                  02190000
         CLI   0(R10),C','                                              02200000
         BE    PRMSCNC                                                  02210000
         CLI   0(R10),C'('                                              02220000
         BNE   PRMERR                                                   02230000
         LA    R10,1(,R10)             SKIP VALUE                       02240000
         SH    R2,=H'1'                DECREMENT LENGTH                 02250000
         BZ    PRMERR                                                   02260000
         CLI   0(R10),C'0'                                              02270000
         BL    PRMERR                                                   02280000
         IC    R0,0(,R10)                                               02290000
         N     R0,=A(15)                                                02300000
PRMIMB02 DS    0H                                                       02310000
         LA    R10,1(,R10)             SKIP VALUE                       02320000
         SH    R2,=H'1'                DECREMENT LENGTH                 02330000
         BZ    PRMERR                                                   02340000
         CLI   0(R10),C')'                                              02350000
         BE    PRMIMB04                                                 02360000
         CLI   0(R10),C'0'                                              02370000
         BL    PRMERR                                                   02380000
         IC    R1,0(,R10)                                               02390000
         N     R1,=A(15)                                                02400000
         MH    R0,=H'10'                                                02410000
         AR    R0,R1                                                    02420000
         B     PRMIMB02                                                 02430000
PRMIMB04 DS    0H                                                       02440000
         LA    R10,1(,R10)             SKIP VALUE                       02450000
         SH    R2,=H'1'                DECREMENT LENGTH                 02460000
         ST    R0,IMBNO                                                 02470000
         B     PRMSCNC                 CONTINUE SCAN                    02480000
*********************************************************************** 02490015
*        INS=                                                         * 02500015
*********************************************************************** 02510015
PRMINS   DS    0H                                                       02520000
         LA    R10,4(,R10)             SKIP VALUE                       02530000
         SH    R2,=H'4'                DECREMENT LENGTH                 02540000
         SR    R0,R0                                                    02550000
PRMINS10 DS    0H                                                       02560000
         CLI   0(R10),C'0'                                              02570000
         BL    PRMERR                                                   02580000
         IC    R15,0(R10)                                               02590000
         N     R15,=A(15)                                               02600000
         MH    R0,=H'10'                                                02610000
         AR    R0,R15                                                   02620000
         LA    R10,1(,R10)             SKIP VALUE                       02630000
         SH    R2,=H'1'                DECREMENT LENGTH                 02640000
         BZ    PRMERR                                                   02650000
         CLI   0(R10),C','                                              02660000
         BNE   PRMINS10                                                 02670000
         LTR   R0,R0                                                    02680000
         BZ    PRMERR                                                   02690000
         CVD   R0,DWORD                                                 02700000
         LA    R10,1(,R10)             SKIP VALUE                       02710000
         SH    R2,=H'1'                DECREMENT LENGTH                 02720000
         BZ    PRMERR                                                   02730000
         CLI   0(R10),C''''                                             02740000
         BNE   PRMINS40                                                 02750000
         MVC   INSNO,DWORD                                              02760000
         LA    R10,1(,R10)             SKIP VALUE                       02770000
         SH    R2,=H'1'                DECREMENT LENGTH                 02780000
         BZ    PRMERR                                                   02790000
         LA    R1,INSREC                                                02800000
PRMINS20 DS    0H                                                       02810000
         CLI   0(R10),C''''                                             02820000
         BE    PRMINS30                                                 02830000
         MVC   0(1,R1),0(R10)                                           02840000
         LA    R1,1(,R1)                                                02850000
         LA    R10,1(,R10)             SKIP VALUE                       02860000
         SH    R2,=H'1'                DECREMENT LENGTH                 02870000
         BNZ   PRMINS20                                                 02880000
         B     PRMERR                                                   02890000
PRMINS30 DS    0H                                                       02900000
         LA    R10,1(,R10)             SKIP VALUE                       02910000
         SH    R2,=H'1'                DECREMENT LENGTH                 02920000
         B     PRMSCNC                 CONTINUE SCAN                    02930000
PRMINS40 DS    0H                                                       02940000
         CLI   0(R10),C','                                              02950000
         BE    PRMERR                                                   02960000
         L     R1,INSTBLPT                                              02970000
         USING INSTBL,R1                                                02980000
         MVC   INSTBLNO,DWORD                                           02990000
         MVC   INSTBLDD,=CL8' '                                         03000000
         LA    R15,INSTBLDD                                             03010000
         LA    R0,8                                                     03020000
PRMINS50 DS    0H                                                       03030000
         MVC   0(,R15),0(R10)                                           03040000
         LA    R15,1(,R15)                                              03050000
         LA    R10,1(,R10)             SKIP VALUE                       03060000
         SH    R2,=H'1'                DECREMENT LENGTH                 03070000
         BZ    PRMINS60                                                 03080000
         CLI   0(R10),C','                                              03090000
         BE    PRMINS60                                                 03100000
         BCT   R0,PRMINS50                                              03110000
         B     PRMERR                                                   03120000
PRMINS60 DS    0H                                                       03130000
         LA    R1,L'INSTBL(,R1)                                         03140000
         ST    R1,INSTBLPT                                              03150000
         DROP  R1                                                       03160000
         B     PRMSCNC                 CONTINUE SCAN                    03170000
*********************************************************************** 03180015
*        DEL=(                                                        * 03190015
*********************************************************************** 03200015
PRMDEL   DS    0H                                                       03210015
         LA    R10,5(,R10)             SKIP VALUE                       03220015
         SH    R2,=H'5'                DECREMENT LENGTH                 03230015
         OI    FLAG,FLAGDEL                                             03240015
         SR    R0,R0                                                    03250015
         LA    R1,DELNO                                                 03260015
PRMDEL10 DS    0H                                                       03270015
         CLI   0(R10),C'0'                                              03280015
         BL    PRMERR                                                   03290015
         IC    R15,0(,R10)                                              03300015
         N     R15,=A(15)                                               03310015
         MH    R0,=H'10'                                                03320015
         AR    R0,R15                                                   03330015
         LA    R10,1(,R10)             SKIP VALUE                       03340015
         SH    R2,=H'1'                DECREMENT LENGTH                 03350015
         BZ    PRMERR                                                   03360015
         CLI   0(R10),C')'                                              03370015
         BE    PRMDEL20                                                 03380015
         CLI   0(R10),C','                                              03390015
         BNE   PRMDEL10                                                 03400015
PRMDEL20 DS    0H                                                       03410015
         LTR   R0,R0                                                    03420015
         BZ    PRMERR                                                   03430015
         CVD   R0,DWORD                                                 03440015
         ZAP   0(L'DELNO,R1),DWORD                                      03450015
         LA    R1,L'DELNO(,R1)                                          03460015
         ZAP   0(L'DELNO,R1),=P'+0'                                     03470015
         CLI   0(R10),C')'                                              03480015
         BE    PRMDEL30                                                 03490015
         LA    R10,1(,R10)             SKIP VALUE                       03500015
         SH    R2,=H'1'                DECREMENT LENGTH                 03510015
         BZ    PRMERR                                                   03520015
         SR    R0,R0                                                    03530015
         B     PRMDEL10                                                 03540015
PRMDEL30 DS    0H                                                       03550015
         LA    R10,1(,R10)             SKIP VALUE                       03560015
         SH    R2,=H'1'                DECREMENT LENGTH                 03570015
         B     PRMSCNC                 CONTINUE SCAN                    03580015
PRMSCNC  DS    0H                                                       03590000
         LTR   R2,R2                   END OF PARM?                     03600000
         BZ    PRMEND                  YES, PARM PARSED                 03610000
         CLI   0(R10),C','             DELIMITER?                       03620000
         BE    PRMSCN                  YES, HANDLE IT                   03630000
PRMERR   DS    0H                                                       03640000
         LR    R1,R10                  CURRENT POSITION                 03650000
         S     R1,PRMSTART             LESS START                       03660000
         LA    R1,LINE+6(R1)           SET LOCATION OF ERROR            03670000
         MVI   0(R1),C'*'              MARK WHERE ERROR IS              03680000
         BAL   R14,PRT                 PRINT A LINE                     03690000
         MVC   LINE(19),=C' Parameters invalid'                         03700000
         BAL   R14,PRT                 PRINT A LINE                     03710000
         LA    R15,8                   ERROR RC                         03720000
         B     EXITRC                  ERROR                            03730000
PRMEND   DS    0H                                                       03740000
*********************************************************************** 03750015
*        Print OPTIONS                                                * 03760015
*********************************************************************** 03770015
         MVC   LINE+1(8),=C'OPTIONS='                                   03780000
         LA    R1,LINE+9                                                03790000
         TM    FLAG,FLAGIMB                                             03800000
         BNO   PRMEND10                                                 03810000
         MVC   0(8,R1),=C'IMBED(0)'                                     03820000
         MVC   6(1,R1),IMBNO+3                                          03830000
         OI    6(R1),C'0'                                               03840000
         LA    R1,9(,R1)                                                03850000
         B     PRMEND20                                                 03860000
PRMEND10 DS    0H                                                       03870000
         MVC   0(10,R1),=C'IMBED(OFF)'                                  03880000
         LA    R1,11(,R1)                                               03890000
PRMEND20 DS    0H                                                       03900000
         TM    FLAG,FLAGDBG                                             03910000
         BNO   PRMEND30                                                 03920000
         MVC   0(9,R1),=C'DEBUG(ON)'                                    03930000
         LA    R1,10(,R1)                                               03940000
         B     PRMEND40                                                 03950000
PRMEND30 DS    0H                                                       03960000
         MVC   0(10,R1),=C'DEBUG(OFF)'                                  03970000
         LA    R1,11(,R1)                                               03980000
PRMEND40 DS    0H                                                       03990000
         TM    FLAG,FLAGKDI                                             04000016
         BNO   PRMEND50                                                 04010016
         MVC   0(7,R1),=C'KEEPDIS'                                      04020016
         LA    R1,8(,R1)                                                04030016
PRMEND50 DS    0H                                                       04040016
         BAL   R14,PRT                 PRINT A LINE                     04050000
         TM    FLAG,FLAGDEL                                             04060015
         BNO   PRMENDN9                                                 04070015
         LA    R2,DELNO                                                 04080015
         MVC   LINE+9(5),=C'DEL=('                                      04090015
         LA    R15,LINE+14                                              04100015
PRMENDN1 DS    0H                                                       04110015
         CP    0(L'DELNO,R2),=P'+0'                                     04120015
         BE    PRMENDN8                                                 04130015
         MVC   0(6,R15),=X'402020202120'                                04140015
         LA    R1,5(,R15)                                               04150015
         EDMK  0(6,R15),0(R2)                                           04160015
         MVC   0(7,R15),0(R1)                                           04170015
         LA    R0,6(,R15)                                               04180015
         SR    R0,R1                                                    04190015
         AR    R15,R0                                                   04200015
         MVI   0(R15),C','                                              04210015
         LA    R15,1(,R15)                                              04220015
         LA    R2,L'DELNO(,R2)                                          04230015
         B     PRMENDN1                                                 04240015
PRMENDN8 DS    0H                                                       04250015
         BCTR  R15,0                                                    04260015
         MVI   0(R15),C')'                                              04270015
         BAL   R14,PRT                 PRINT A LINE                     04280015
PRMENDN9 DS    0H                                                       04290015
*********************************************************************** 04300013
*********************************************************************** 04310015
**       Mainline                                                    ** 04320015
*********************************************************************** 04330013
*********************************************************************** 04340015
PROC     DS    0H                                                       04350000
         GET   SYSUT1,CARD                                              04360000
         AP    RECIN,=P'+1'                                             04370000
         LA    R9,LINE+1+L'CARD+1+15                                    04380015
* Flower box                                                            04390000
         CP    RECIN,=P'+1'                                             04400000
         BNE   PROC090                                                  04410000
         MVC   SAVCARD,CARD                                             04420013
PROC050  DS    0H                                                       04430000
         MVC   CARD(71),=36C'*='                                        04440000
PROC060  DS    0H                                                       04450000
         AP    RECINS,=P'+1'                                            04460000
         LA    R0,CARD                                                  04470000
         BAL   R14,ASM                                                  04480000
         TM    FLAG,FLAGDBG                                             04490000
         BNO   PROC080                                                  04500000
         MVC   SAVLINE,LINE                                             04510000
         MVI   LINE,C' '                                                04520000
         MVC   LINE+1(L'LINE-1),LINE                                    04530000
         MVC   LINE+1(L'CARD),CARD                                      04540000
         MVC   LINE+1+L'CARD+1(14),=C'** Inserted **'                   04550000
         BAL   R14,PRT                 PRINT A LINE                     04560000
         MVC   LINE,SAVLINE                                             04570000
PROC080  DS    0H                                                       04580000
         CP    RECINS,=P'4'                                             04590000
         BH    PROC085                                                  04600013
         BE    PROC050                                                  04610000
         MVI   CARD+2,C' '                                              04620000
         MVC   CARD+3(66),CARD+2                                        04630000
         B     PROC060                                                  04640000
PROC085  DS    0H                                                       04650013
         MVC   CARD,SAVCARD                                             04660013
PROC090  DS    0H                                                       04670000
* DELETE TITLE                                                          04680000
         CLC   =C' TITLE ',CARD+8                                       04690000
         BE    PROCDEL                                                  04700000
* Delete comments                                                       04710000
         CLI   CARD,C'*'                                                04720000
         BE    PROCDEL                                                  04730000
* If PARM=IMBED then delete first n ASMDREG                             04740000
         CLC   =C' ASMDREG ',CARD+8                                     04750000
         BNE   PROC110                                                  04760000
         TM    FLAG,FLAGIMB                                             04770000
         BNO   PROC100                                                  04780000
         ICM   R0,15,IMBNO                                              04790000
         BZ    PROC100                                                  04800013
         SH    R0,=H'1'                                                 04810000
         ST    R0,IMBNO                                                 04820000
         BNZ   PROCDEL                                                  04830000
PROC100  DS    0H                                                       04840000
         TM    FLAG,FLAGNRG                                             04850000
         BO    PROC104                                                  04860000
* Insert R0-R15 equates                                                 04870000
         MVC   CARD(19),=C'R0       EQU   0   '                         04880000
         AP    RECCHG,=P'+1'                                            04890000
         TM    FLAG,FLAGDBG                                             04900000
         BNO   PROC101                                                  04910000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    04920000
         MVC   0(3,R9),=C'Reg'                                          04930015
         LA    R9,4(,R6)                                                04940015
PROC101  DS    0H                                                       04950000
         BAL   R14,PUT                                                  04960000
         LA    R2,C'0'                                                  04970000
         LA    R3,9                                                     04980000
PROC102  DS    0H                                                       04990000
         LA    R2,1(,R2)                                                05000000
         STC   R2,CARD+1                                                05010000
         STC   R2,CARD+15                                               05020000
         BAL   R14,PUTRX                                                05030000
         BCT   R3,PROC102                                               05040000
         LA    R2,C'0'                                                  05050000
         LA    R3,6                                                     05060000
         MVI   CARD+1,C'1'                                              05070000
         MVI   CARD+15,C'1'                                             05080000
PROC103  DS    0H                                                       05090000
         STC   R2,CARD+2                                                05100000
         STC   R2,CARD+16                                               05110000
         BAL   R14,PUTRX                                                05120000
         LA    R2,1(,R2)                                                05130000
         BCT   R3,PROC103                                               05140000
PROC104  DS    0H                                                       05150000
         B     PROC                                                     05160000
PROC110  DS    0H                                                       05170000
* If PARM=IMBED then delete first END                                   05180000
         CLC   =C' END ',CARD+8                                         05190000
         BNE   PROC120                                                  05200000
         TM    FLAG,FLAGIMB                                             05210000
         BNO   PROC210                                                  05220000
         ICM   R0,15,IMBNO                                              05230000
         BNZ   PROCDEL                                                  05240000
         B     PROC210                                                  05250000
PROC120  DS    0H                                                       05260000
         TM    FLAG,FLAGDEL                                             05270015
         BNO   PROCDNO9                                                 05280015
         LA    R1,DELNO                                                 05290015
PROCDNO1 DS    0H                                                       05300015
         CP    0(L'DELNO,R1),=P'+0'                                     05310015
         BE    PROCDNO9                                                 05320015
         CP    RECIN,0(L'DELNO,R1)                                      05330015
         BE    PROCDNO2                                                 05340015
         LA    R1,L'DELNO(,R1)                                          05350015
         B     PROCDNO1                                                 05360015
PROCDNO2 DS    0H                                                       05370015
         MVC   0(7,R9),=C'By DEL='                                      05380015
         LA    R9,8(,R6)                                                05390015
         B     PROCDEL                                                  05400015
PROCDNO9 DS    0H                                                       05410015
* IF SPKA AND NO OPERANDS SET TO SPKA 0                                 05420000
         CLC   =C' SPKA           ',CARD+8                              05430000
         BNE   PROC121                                                  05440000
         MVC   CARD+8(16),=C' SPKA  0        '                          05450000
         AP    RECCHG,=P'+1'                                            05460000
         TM    FLAG,FLAGDBG                                             05470000
         BNO   PROC210                                                  05480000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    05490000
         MVC   0(4,R9),=C'SPKA'                                         05500015
         LA    R9,5(,R6)                                                05510015
         B     PROC210                                                  05520000
PROC121  DS    0H                                                       05530000
* IF SPKA  16  change to SPKA  1*16                                     05540000
         CLC   =C' SPKA  16       ',CARD+8                              05550000
         BNE   PROC122                                                  05560000
         MVC   CARD+8(16),=C' SPKA  1*16     '                          05570000
         AP    RECCHG,=P'+1'                                            05580000
         TM    FLAG,FLAGDBG                                             05590000
         BNO   PROC210                                                  05600000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    05610000
         MVC   0(4,R9),=C'SPKA'                                         05620015
         LA    R9,5(,R6)                                                05630015
         B     PROC210                                                  05640000
PROC122  DS    0H                                                       05650000
* IF SPKA  80  change to SPKA  5*16                                     05660000
         CLC   =C' SPKA  80       ',CARD+8                              05670012
         BNE   PROC123                                                  05680000
         MVC   CARD+8(16),=C' SPKA  5*16     '                          05690000
         AP    RECCHG,=P'+1'                                            05700000
         TM    FLAG,FLAGDBG                                             05710000
         BNO   PROC210                                                  05720000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    05730000
         MVC   0(4,R9),=C'SPKA'                                         05740015
         LA    R9,5(,R6)                                                05750015
         B     PROC210                                                  05760000
PROC123  DS    0H                                                       05770000
* IF LPSW AND NO OPERANDS SET TO LPSW 0                                 05780000
         CLC   =C' LPSW           ',CARD+8                              05790000
         BNE   PROC124                                                  05800000
         MVC   CARD+8(16),=C' LPSW  0        '                          05810000
         AP    RECCHG,=P'+1'                                            05820000
         TM    FLAG,FLAGDBG                                             05830000
         BNO   PROC210                                                  05840000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    05850000
         MVC   0(4,R9),=C'LPSW'                                         05860015
         LA    R9,5(,R6)                                                05870015
         B     PROC210                                                  05880000
PROC124  DS    0H                                                       05890000
* IF SPACE DELETE IT                                                    05900000
         CLC   =C' SPACE          ',CARD+8                              05910000
         BE    PROCDEL                                                  05920000
*        Shift left two spaces BC and BCR operands                      05930014
         CLC   =C' BC      ',CARD+8                                     05940014
         BE    PROC124A                                                 05950014
         CLC   =C' BCR     ',CARD+8                                     05960014
         BNE   PROC124B                                                 05970014
PROC124A DS    0H                                                       05980014
         MVC   CARD+15(45),CARD+17                                      05990014
PROC124B DS    0H                                                       06000014
* Change BC    x, to Bxx                                                06010000
* Change BCR   x, to BxxR                                               06020000
         CLC   =C' BC    1,',CARD+8                                     06030000
         BNE   PROC125                                                  06040000
         MVC   CARD+8(9),=C' BO      '                                  06050000
         B     PROC140                                                  06060000
PROC125  DS    0H                                                       06070000
         CLC   =C' BC    2,',CARD+8                                     06080000
         BNE   PROC126                                                  06090000
         MVC   CARD+8(9),=C' BH      '                                  06100000
         B     PROC140                                                  06110000
PROC126  DS    0H                                                       06120000
         CLC   =C' BC    4,',CARD+8                                     06130000
         BNE   PROC127                                                  06140000
         MVC   CARD+8(9),=C' BL      '                                  06150000
         B     PROC140                                                  06160000
PROC127  DS    0H                                                       06170000
         CLC   =C' BC    7,',CARD+8                                     06180000
         BNE   PROC128                                                  06190000
         MVC   CARD+8(9),=C' BNE     '                                  06200000
         B     PROC140                                                  06210000
PROC128  DS    0H                                                       06220000
         CLC   =C' BC    8,',CARD+8                                     06230000
         BNE   PROC129                                                  06240000
         MVC   CARD+8(9),=C' BE      '                                  06250000
         B     PROC140                                                  06260000
PROC129  DS    0H                                                       06270000
         CLC   =C' BC    11,',CARD+8                                    06280000
         BNE   PROC130                                                  06290000
         MVC   CARD+8(10),=C' BNL      '                                06300000
         B     PROC140                                                  06310000
PROC130  DS    0H                                                       06320000
         CLC   =C' BC    13,',CARD+8                                    06330000
         BNE   PROC131                                                  06340000
         MVC   CARD+8(10),=C' BNH      '                                06350000
         B     PROC140                                                  06360000
PROC131  DS    0H                                                       06370000
         CLC   =C' BC    14,',CARD+8                                    06380000
         BNE   PROC132                                                  06390000
         MVC   CARD+8(10),=C' BNO      '                                06400000
         B     PROC140                                                  06410000
PROC132  DS    0H                                                       06420000
         CLC   =C' BCR   1,',CARD+8                                     06430000
         BNE   PROC133                                                  06440000
         MVC   CARD+8(9),=C' BOR     '                                  06450000
         B     PROC140                                                  06460000
PROC133  DS    0H                                                       06470000
         CLC   =C' BCR   2,',CARD+8                                     06480000
         BNE   PROC134                                                  06490000
         MVC   CARD+8(9),=C' BHR     '                                  06500000
         B     PROC140                                                  06510000
PROC134  DS    0H                                                       06520000
         CLC   =C' BCR   4,',CARD+8                                     06530000
         BNE   PROC135                                                  06540000
         MVC   CARD+8(9),=C' BLR     '                                  06550000
         B     PROC140                                                  06560000
PROC135  DS    0H                                                       06570000
         CLC   =C' BCR   7,',CARD+8                                     06580000
         BNE   PROC136                                                  06590000
         MVC   CARD+8(9),=C' BNER    '                                  06600000
         B     PROC140                                                  06610000
PROC136  DS    0H                                                       06620000
         CLC   =C' BCR   8,',CARD+8                                     06630000
         BNE   PROC137                                                  06640000
         MVC   CARD+8(9),=C' BER     '                                  06650000
         B     PROC140                                                  06660000
PROC137  DS    0H                                                       06670000
         CLC   =C' BCR   11,',CARD+8                                    06680000
         BNE   PROC138                                                  06690000
         MVC   CARD+8(10),=C' BNLR     '                                06700000
         B     PROC140                                                  06710000
PROC138  DS    0H                                                       06720000
         CLC   =C' BCR   13,',CARD+8                                    06730000
         BNE   PROC139                                                  06740000
         MVC   CARD+8(10),=C' BNHR     '                                06750000
         B     PROC140                                                  06760000
PROC139  DS    0H                                                       06770000
         CLC   =C' BCR   14,',CARD+8                                    06780000
         BNE   PROC210                                                  06790000
         MVC   CARD+8(10),=C' BNOR     '                                06800000
PROC140  DS    0H                                                       06810000
         MVC   CARD+15(20),CARD+16                                      06820000
         CLI   CARD+15,C' '                                             06830000
         BNE   PROC141                                                  06840000
         MVC   CARD+15(20),CARD+16                                      06850000
         CLI   CARD+15,C' '                                             06860000
         BNE   PROC141                                                  06870000
         MVC   CARD+15(20),CARD+16                                      06880000
         CLI   CARD+15,C' '                                             06890000
         BNE   PROC141                                                  06900000
         MVC   CARD+15(20),CARD+16                                      06910000
PROC141  DS    0H                                                       06920000
         AP    RECCHG,=P'+1'                                            06930000
         TM    FLAG,FLAGDBG                                             06940000
         BNO   PROC210                                                  06950000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    06960000
         MVC   0(5,R9),=C'Branch'                                       06970015
         LA    R9,6(,R6)                                                06980015
PROC210  DS    0H                                                       06990000
* CLEAR COMMENT                                                         07000000
         CLC   =C' DC ',CARD+8                                          07010000
         BE    PROC220                                                  07020000
         SR    R15,R15                                                  07030016
         LA    R1,CARD+16                                               07040016
         LA    R0,71-16                                                 07050016
         TM    FLAG,FLAGKDI                                             07060016
         BNO   PROC210A                                                 07070016
         LA    R0,49-16                                                 07080016
PROC210A DS    0H                                                       07090016
         CLI   0(R1),C' '                                               07100016
         BE    PROC210B                                                 07110016
         CLI   0(R1),C''''                                              07120016
         BE    PROC220                                                  07130016
         LA    R1,1(,R1)                                                07140016
         BCT   R0,PROC210A                                              07150016
         B     PROC220                                                  07160016
PROC210B DS    0H                                                       07170016
         CLI   0(R1),C' '                                               07180016
         BE    PROC210C                                                 07190016
         MVI   0(R1),C' '                                               07200016
         LA    R15,1(,R15)                                              07210016
PROC210C DS    0H                                                       07220016
         LA    R1,1(,R1)                                                07230016
         BCT   R0,PROC210B                                              07240016
         LTR   R15,R15                                                  07250016
         BZ    PROC220                                                  07260016
         AP    RECCHG,=P'+1'                                            07270000
         TM    FLAG,FLAGDBG                                             07280000
         BNO   PROC220                                                  07290000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    07300000
         MVC   0(7,R9),=C'Comment'                                      07310015
         LA    R9,8(,R6)                                                07320015
PROC220  DS    0H                                                       07330000
         CLC   =C' DC ',CARD+8                                          07340000
         BE    PROC230                                                  07350000
* change FRx to Rx and CRx to Rx                                        07360000
         LA    R1,CARD+15                                               07370000
         LA    R0,30                                                    07380000
         LA    R15,0                                                    07390000
PROC221  DS    0H                                                       07400000
         CLC   =C'FR',0(R1)                                             07410000
         BNE   PROC222                                                  07420000
         CLI   2(R1),C'0'                                               07430000
         BL    PROC223                                                  07440000
         MVC   0(30,R1),1(R1)                                           07450000
         B     PROC223                                                  07460000
PROC222  DS    0H                                                       07470000
         CLC   =C'CR',0(R1)                                             07480000
         BNE   PROC223                                                  07490000
         CLI   2(R1),C'0'                                               07500000
         BL    PROC223                                                  07510000
         MVC   0(30,R1),1(R1)                                           07520000
PROC223  DS    0H                                                       07530000
         LA    R1,1(,R1)                                                07540000
         BCT   R0,PROC221                                               07550000
         LTR   R15,R15                                                  07560000
         BZ    PROC230                                                  07570000
         AP    RECCHG,=P'+1'                                            07580000
         TM    FLAG,FLAGDBG                                             07590000
         BNO   PROC230                                                  07600000
         MVC   LINE+1+L'CARD+1(13),=C'** Changed **'                    07610000
         MVC   0(3,R9),=C'Reg'                                          07620015
         LA    R9,4(,R6)                                                07630015
PROC230  DS    0H                                                       07640000
         ZAP   DWORD,RECOUT                                             07650000
         AP    DWORD,=P'+1'                                             07660000
         CP    DWORD,INSNO                                              07670000
         BNE   PROC231                                                  07680000
         LA    R0,INSREC                                                07690000
         BAL   R14,ASM                                                  07700000
         TM    FLAG,FLAGDBG                                             07710000
         BNO   PROC240                                                  07720000
         MVC   SAVLINE,LINE                                             07730000
         MVI   LINE,C' '                                                07740000
         MVC   LINE+1(L'LINE-1),LINE                                    07750000
         MVC   LINE+1(L'CARD),INSREC                                    07760000
         MVC   LINE+1+L'CARD+1(14),=C'** Inserted **'                   07770000
         BAL   R14,PRT                 PRINT A LINE                     07780000
         MVC   LINE,SAVLINE                                             07790000
         B     PROC240                                                  07800000
PROC231  DS    0H                                                       07810000
         LA    R2,INSTB                                                 07820000
         USING INSTBL,R2                                                07830000
PROC232  DS    0H                                                       07840000
         C     R2,INSTBLPT                                              07850000
         BNL   PROC240                                                  07860000
         CP    RECOUT,INSTBLNO                                          07870000
         BNE   PROC233                                                  07880000
         BAL   R14,INS                                                  07890000
PROC233  DS    0H                                                       07900000
         LA    R2,L'INSTBL(,R2)                                         07910000
         B     PROC232                                                  07920000
         DROP  R2                                                       07930000
PROC240  DS    0H                                                       07940000
         BAL   R14,PUT                                                  07950000
         B     PROC                                                     07960000
PROCDEL  DS    0H                                                       07970000
         AP    RECDEL,=P'+1'                                            07980000
         TM    FLAG,FLAGDBG                                             07990000
         BNO   PROC                                                     08000000
         MVC   LINE+1(L'CARD),CARD                                      08010000
         MVC   LINE+1+L'CARD+1(13),=C'** Deleted **'                    08020000
         BAL   R14,PRT                 PRINT A LINE                     08030000
         B     PROC                                                     08040000
*********************************************************************** 08050015
*********************************************************************** 08060015
**       Termination                                                 ** 08070015
*********************************************************************** 08080015
*********************************************************************** 08090015
EXIT     DS    0H                                                       08100000
         MVC   LINE+1(10),=C'Records in'                                08110000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     08120000
         ED    LINE+20(10),RECIN                                        08130000
         BAL   R14,PRT                 PRINT A LINE                     08140000
         MVC   LINE+1(15),=C'Records changed'                           08150012
         MVC   LINE+20(10),=X'40206B2020206B202120'                     08160000
         ED    LINE+20(10),RECCHG                                       08170000
         BAL   R14,PRT                 PRINT A LINE                     08180000
         MVC   LINE+1(16),=C'Records inserted'                          08190000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     08200000
         ED    LINE+20(10),RECINS                                       08210000
         BAL   R14,PRT                 PRINT A LINE                     08220000
         MVC   LINE+1(14),=C'Records deleted'                           08230000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     08240000
         ED    LINE+20(10),RECDEL                                       08250000
         BAL   R14,PRT                 PRINT A LINE                     08260000
         MVC   LINE+1(11),=C'Records out'                               08270000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     08280000
         ED    LINE+20(10),RECOUT                                       08290000
         BAL   R14,PRT                 PRINT A LINE                     08300000
         LA    R15,0                                                    08310000
EXITRC   DS    0H                                                       08320000
         LR    R2,R15                                                   08330000
         CLOSE (SYSPRINT,,SYSUT1,,SYSUT2)                               08340000
         L     R13,4(,R13)                                              08350000
         L     R14,12(,R13)            RESTORE R14                      08360000
         LR    R15,R2                  RESTORE RETURN CODE              08370000
         LM    R2,R12,28(R13)          RESTORE REST OF REGISTERS        08380000
         BR    R14                     EXIT                             08390000
QUIT     DS    0H                                                       08400000
         L     R13,4(,R13)                                              08410000
         LM    R14,R12,12(R13)                                          08420000
         LA    R15,16                                                   08430000
         BR    R14                                                      08440000
*********************************************************************** 08450013
*                                                                     * 08460013
*********************************************************************** 08470013
PUTRX    DS    0H                                                       08480000
         AP    RECINS,=P'+1'                                            08490000
         TM    FLAG,FLAGDBG                                             08500000
         BNO   PUT                                                      08510000
         MVC   LINE+1+L'CARD+1(14),=C'** Inserted **'                   08520000
         MVC   0(3,R9),=C'Reg'                                          08530015
         LA    R9,4(,R6)                                                08540015
PUT      DS    0H                                                       08550000
         ST    R14,PUTR14                                               08560000
         LA    R0,CARD                                                  08570000
         BAL   R14,ASM                                                  08580000
         TM    FLAG,FLAGDBG                                             08590000
         BNO   PUTXT                                                    08600000
         MVC   LINE+1(L'CARD),CARD                                      08610000
         BAL   R14,PRT                 PRINT A LINE                     08620000
PUTXT    DS    0H                                                       08630000
         L     R14,PUTR14                                               08640000
         BR    R14                     RETURN TO CALLER                 08650000
*********************************************************************** 08660013
*                                                                     * 08670013
*********************************************************************** 08680013
         USING INSTBL,R2                                                08690000
INS      DS    0H                                                       08700000
         ST    R14,INSR14                                               08710000
         MVC   INSDD+40(8),INSTBLDD                                     08720000
         OPEN  (INSDD,(INPUT))                                          08730000
         TM    INSDD+48,16                                              08740000
         BZ    INSERR                                                   08750000
INSGET   DS    0H                                                       08760000
         GET   INSDD,INSTBREC                                           08770000
         AP    RECINS,=P'+1'                                            08780000
         LA    R0,INSTBREC                                              08790000
         BAL   R14,ASM                                                  08800000
         TM    FLAG,FLAGDBG                                             08810000
         BNO   INSGET                                                   08820000
         MVC   SAVLINE,LINE                                             08830000
         MVI   LINE,C' '                                                08840000
         MVC   LINE+1(L'LINE-1),LINE                                    08850000
         MVC   LINE+1(L'CARD),INSTBREC                                  08860000
         MVC   LINE+1+L'CARD+1(14),=C'** Inserted **'                   08870000
         BAL   R14,PRT                 PRINT A LINE                     08880000
         MVC   LINE,SAVLINE                                             08890000
         B     INSGET                                                   08900000
INSEOF   DS    0H                                                       08910000
         CLOSE (INSDD)                                                  08920000
INSXT    DS    0H                                                       08930000
         L     R14,INSR14                                               08940000
         BR    R14                     RETURN TO CALLER                 08950000
INSERR   DS    0H                                                       08960000
         MVC   LINE+1(26),=C'Insert DD=xxxxxxxx missing'                08970000
         MVC   LINE+11(8),INSTBLDD                                      08980000
         BAL   R14,PRT                 PRINT A LINE                     08990000
         LA    R15,8                                                    09000000
         B     EXITRC                                                   09010000
         DROP  R2                                                       09020000
*********************************************************************** 09030013
*                                                                     * 09040013
*********************************************************************** 09050013
ASM      DS    0H                                                       09060000
         ST    R14,ASMR14                                               09070000
         AP    RECOUT,=P'+1'                                            09080000
         LR    R1,R0                                                    09090000
         UNPK  DWORD(7),RECOUT                                          09100000
         MVC   72(7,R1),DWORD                                           09110000
         OI    78(R1),C'0'                                              09120000
         MVI   79(R1),C'0'                                              09130000
         LA    R15,80                                                   09140012
ASM010   DS    0H                      Cleanup any hex zeros            09150012
         CLI   0(R1),0                                                  09160012
         BNE   ASM020                                                   09170012
         OI    0(R1),C' '                                               09180012
ASM020   DS    0H                                                       09190012
         LA    R1,1(,R1)                                                09200012
         BCT   R15,ASM010                                               09210012
         PUT   SYSUT2,(0)                                               09220000
         L     R14,ASMR14                                               09230000
         BR    R14                     RETURN TO CALLER                 09240000
*********************************************************************** 09250013
*                                                                     * 09260013
*            WRITE PRINT LINE                                         * 09270013
*                                                                     * 09280013
*********************************************************************** 09290013
PRT      DS    0H                                                       09300000
         ST    R14,PRTR14                                               09310000
         CP    LNCT,=P'+60'            END OF PAGE                      09320000
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   09330000
PRTHDRS  DS    0H                                                       09340000
         AP    PGCT,=P'+1'             COUNT PAGES                      09350000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  09360000
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  09370000
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  09380000
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  09390000
         MVI   LINE,C'0'               SKIP AFTER HEADING               09400000
PRTCHK   DS    0H                                                       09410000
         CLI   LINE,C'+'               OVERPRINT ?                      09420000
         BE    PRTLINE                  YES, DON'T COUNT                09430000
         CLI   LINE,C'1'               NEW LINE ?                       09440000
         BE    PRTHDRS                  YES, PRINT HEADER               09450000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         09460000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            09470000
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         09480000
         BE    PRTLINE2                 YES, GO CHECK IF FIT            09490000
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         09500000
         BE    PRTLINE3                 YES, GO CHECK IF FIT            09510000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       09520000
PRTLINE1 DS    0H                                                       09530000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                09540000
         B     PRTVFY                  GO SEE IF IT WILL FIT            09550000
PRTLINE2 DS    0H                                                       09560000
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                09570000
         B     PRTVFY                  GO SEE IF IT WILL FIT            09580000
PRTLINE3 DS    0H                                                       09590000
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                09600000
PRTVFY   DS    0H                                                       09610000
         CP    LNCT,=P'+60'            OVERFLOW ?                       09620000
         BH    PRTHDRS                  YES, FORCE HEADER               09630000
PRTLINE  DS    0H                                                       09640000
         PUT   SYSPRINT,LINE           PRINT A LINE                     09650000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          09660000
         MVC   LINE+1(L'LINE-1),LINE                                    09670000
         L     R14,PRTR14                                               09680000
         BR    R14                     RETURN TO CALLER                 09690000
*********************************************************************** 09700013
*                                                                     * 09710000
*        DUMP DATA                                                    * 09720000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 09730000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 09740000
*                                                                     * 09750000
*********************************************************************** 09760000
DMP      DS    0H                                                       09770000
         STM   R0,R15,DMPREGS          SAVE REGISTERS                   09780000
         LR    R3,R1                   GET ADDRESS TO DUMP              09790000
         LR    R4,R0                   GET LENGTH                       09800000
         XC    DMPOFF,DMPOFF           SAVE OFFSET FOR DUMP             09810000
         MVI   DMPFLAG,DMPFIRST        FIRST LINE                       09820000
DMPDMPLP DS    0H                                                       09830000
         LTR   R4,R4                   ANY DATA TO DUMP ?               09840000
         BZ    DMPHEXXT                 YES, ALL DONE                   09850000
         TM    DMPFLAG,DMPFIRST        FIRST LINE?                      09860000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   09870000
         LA    R0,32                   DEFAULT LENGTH                   09880000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          09890000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           09900000
         LR    R14,R3                  GET CURRENT INPUT AREA           09910000
         SR    R14,R0                  BACK TO PREVIOUS AREA            09920000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       09930000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            09940000
         SR    R4,R0                   REDUCE LENGTH TO DO              09950000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           09960000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       09970000
         L     R14,DMPOFF              GET CURRENT OFFSET               09980000
         ST    R14,DUPFIRST            SAVE AS FIRST OFFSET             09990000
         OI    DMPFLAG,DMPDUP          SET DUPLICATE                    10000000
         B     DMPNXTLN                CONTINUE                         10010000
DMPDUPCK DS    0H                                                       10020000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           10030000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      10040000
         MVC   LINE+7(5),=C'Lines'     MOVE LITERAL                     10050000
         LA    R2,LINE+13              OUTPUT AREA ADDRESS              10060000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        10070000
         LA    R15,2                   CONVERT 4 BYTES                  10080000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            10090000
         MVI   LINE+17,C'-'            THRU LITERAL                     10100000
         L     R1,DMPOFF               GET CURRENT OFFSET               10110000
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        10120000
         ST    R1,DUPFIRST             SAVE FOR DUMPING                 10130000
         LA    R2,LINE+18              OUTPUT AREA ADDRESS              10140000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        10150000
         LA    R15,2                   CONVERT 4 BYTES                  10160000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            10170000
         MVC   LINE+23(13),=C'Same as above' MOVE LITERAL               10180000
         BAL   R14,PRT                 PRINT A LINE                     10190000
         NI    DMPFLAG,255-DMPDUP      RESET DUPLICATE IN PROGRESS      10200000
DMPALIN  DS    0H                                                       10210000
         ST    R3,W#DADR           Save address                         10220000
         LA    R2,LINE+1           Output area address                  10230000
         LA    R1,W#DADR           Address of address                   10240000
         LA    R15,4               Convert 8 bytes                      10250000
         BAL   R14,DMPDSP          Convert it to display                10260013
         LA    R2,1(,R2)           Skip 1 between address & offset      10270000
         LA    R1,DMPOFF+2             ADDRESS OF OFFSET TO DUMP        10280000
         LA    R15,2                   CONVERT 4 BYTES                  10290000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            10300000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     10310000
         LR    R1,R3                   ADDRESS OF DATA                  10320000
         LA    R5,32                   DEFAULT LENGTH                   10330000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          10340000
         BH    DMPDODMP                 YES, USE 32                     10350000
         LR    R5,R4                   USE WHAT IS LEFT                 10360000
DMPDODMP DS    0H                                                       10370000
         SR    R4,R5                   REDUCE AMOUNT TO DO              10380000
         MVI   LINE+89,C'*'            BOX IN DISPLAY PORTION           10390000
         BCTR  R5,0                    MAKE ZERO BASED                  10400000
         EX    R5,DMPMVC               DO MOVE                          10410000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          10420000
         LA    R5,1(,R5)               RESTORE LENGTH                   10430000
         MVI   LINE+122,C'*'           COMPLETE BOX                     10440000
DMPDMPHX DS    0H                                                       10450000
         LA    R15,4                   4 BYTES TO PROCESS               10460000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           10470000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               10480000
         LR    R15,R5                  USE LENGTH LEFT                  10490000
DMPDMPIT DS    0H                                                       10500000
         SR    R5,R15                  REDUCE AMOUNT TO DO              10510000
         BAL   R14,DMPDSP              CONVERT DATA                     10520000
         LA    R2,1(,R2)               SKIP 1 BYTE                      10530000
         LA    R0,LINE+43              HALFWAY POINT ADDRESS            10540000
         CR    R0,R2                   AT HALFWAY POINT?                10550000
         BNE   DMPDMPNX                 NO, CONTINUE                    10560000
         LA    R2,1(,R2)               SKIP 1 BYTE                      10570000
DMPDMPNX DS    0H                                                       10580000
         LTR   R5,R5                   ANY LEFT TO DO ?                 10590000
         BH    DMPDMPHX                 YES, GO DO IT                   10600000
         BAL   R14,PRT                 PRINT A LINE                     10610000
DMPNXTLN DS    0H                                                       10620000
         L     R1,DMPOFF               GET OFFSET IN RECORD             10630000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       10640000
         ST    R1,DMPOFF               SAVE OFFSET IN RECORD            10650000
         LA    R3,32(,R3)              NEXT INPUT AREA                  10660000
         NI    DMPFLAG,255-DMPFIRST    NOT FIRST LINE                   10670000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             10680000
DMPHEXXT DS    0H                                                       10690000
         LM    R0,R15,DMPREGS          RESTORE CALLERS REGS             10700000
         BR    R14                     EXIT . . .                       10710000
DMPMVC   MVC   LINE+90(0),0(R1)        <<< EXECUTED >>>                 10720000
DMPTR    TR    LINE+90(0),DMPTBLCH     <<< EXECUTED >>>                 10730000
*                                                                       10740000
*                                                                       10750000
*                                                                       10760000
DMPDSP   DS    0H                                                       10770000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               10780000
         NI    0(R2),X'0F'             REMOVE ZONE                      10790000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             10800000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             10810000
         TR    0(2,R2),=C'0123456789ABCDEF' TRANSLATE TO HEX            10820000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        10830000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         10840000
         BCT   R15,DMPDSP              LOOP THRU DATA                   10850000
         BR    R14                     EXIT . . .                       10860000
*********************************************************************** 10870013
*                                                                     * 10880013
*********************************************************************** 10890013
SAVEAREA DC    18A(0)                                                   10900000
DMPREGS  DC    16A(0)                                                   10910000
DMPOFF   DS    A                                                        10920000
W#DADR   DS    A                                                        10930000
DUPFIRST DS    A                                                        10940000
DMPFLAG  DC    X'00'                                                    10950000
DMPFIRST EQU   X'80'                                                    10960000
DMPDUP   EQU   X'40'                                                    10970000
DMPTBLCH DC    CL256' '                                                 10980000
         ORG   DMPTBLCH+X'4A' Cent                                      10990000
         DC    X'4A4B4C4D4E4F50' vert bar and ampersand                 11000000
         ORG   DMPTBLCH+X'5A' exclamation                               11010000
         DC    X'5A5B5C5D5E5F6061'                                      11020000
         ORG   DMPTBLCH+X'6A'                                           11030000
         DC    X'6A6B6C6D6E6F'                                          11040000
         ORG   DMPTBLCH+X'7A'                                           11050000
         DC    X'7A7B7C7D7E7F'                                          11060000
         ORG   DMPTBLCH+C'a'                                            11070000
         DC    C'abcdefghi'                                             11080000
         ORG   DMPTBLCH+C'j'                                            11090000
         DC    C'jklmnopqr'                                             11100000
         ORG   DMPTBLCH+C's'                                            11110000
         DC    C'stuvwxyz'                                              11120000
         ORG   DMPTBLCH+C'A'                                            11130000
         DC    C'ABCDEFGHI'                                             11140000
         ORG   DMPTBLCH+C'J'                                            11150000
         DC    C'JKLMNOPQR'                                             11160000
         ORG   DMPTBLCH+C'S'                                            11170000
         DC    C'STUVWXYZ'                                              11180000
         ORG   DMPTBLCH+C'0'                                            11190000
         DC    C'0123456789'                                            11200000
         ORG                                                            11210000
DWORD    DC    D'+0'                                                    11220000
PRTR14   DC    A(0)                                                     11230000
PUTR14   DC    A(0)                                                     11240000
INSR14   DC    A(0)                                                     11250000
ASMR14   DC    A(0)                                                     11260000
PRMSTART DC    A(0)                                                     11270000
RECIN    DC    PL4'+0'                                                  11280000
RECOUT   DC    PL4'+0'                                                  11290000
RECCHG   DC    PL4'+0'                                                  11300000
RECDEL   DC    PL4'+0'                                                  11310000
RECINS   DC    PL4'+0'                                                  11320000
FLAG     DC    X'00'                                                    11330000
FLAGIMB  EQU   X'80'                                                    11340000
FLAGDBG  EQU   X'40'                                                    11350000
FLAGNRG  EQU   X'20'                                                    11360000
FLAGDEL  EQU   X'10'                                                    11370015
FLAGKDI  EQU   X'08'                                                    11380016
IMBNO    DC    A(2)                                                     11390000
         DC    0D'0'                                                    11400013
INSNO    DC    PL8'-1'                                                  11410013
INSREC   DC    CL80' '                                                  11420000
DELNO    DC    50PL3'+0'                                                11430015
LINE     DC    CL133' '                                                 11440000
SAVLINE  DC    CL133' '                                                 11450000
CARD     DC    CL80' '                                                  11460000
SAVCARD  DC    CL80' '                                                  11470013
CURDATE  DC    A(0)                                                     11480000
JULWRK2  DC    A(0)                                                     11490000
JULWRK4  DC    P'+365'                                                  11500000
         DC    P'+01'                                                   11510000
         DC    P'+31'                                                   11520000
         DC    P'+30'                                                   11530000
         DC    P'+31'                                                   11540000
         DC    P'+30'                                                   11550000
         DC    P'+31'                                                   11560000
         DC    P'+31'                                                   11570000
         DC    P'+30'                                                   11580000
         DC    P'+31'                                                   11590000
         DC    P'+30'                                                   11600000
         DC    P'+31'                                                   11610000
JULWRK6  DC    P'+28'                                                   11620000
JULTBL1  DC    P'+31'                                                   11630000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  11640000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            11650000
LNCT     DC    PL2'+99'                                                 11660000
PGCT     DC    PL2'+0'                                                  11670000
HD1      DC    CL133'1'                                                 11680000
         ORG   HD1+1                                                    11690000
HD1DATE  DC    C'            '                                          11700000
         DC    C' '                                                     11710000
HD1TOD   DC    C'HH:MM:SS'                                              11720000
         ORG   HD1+66-(20/2)                                            11730013
HD1DATA  DC    C'Disassembler Cleanser'                                 11740000
         ORG   HD1+L'HD1-8                                              11750013
HD1PG    DC    C'Page'                                                  11760000
HD1PGCT  DC    C' 123'                                                  11770000
         ORG   ,                                                        11780000
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X11790000
               RECFM=FBA,LRECL=133                                      11800000
SYSUT1   DCB   DDNAME=SYSUT1,MACRF=GM,DSORG=PS,EODAD=EXIT,             X11810000
               RECFM=FB,LRECL=80                                        11820000
SYSUT2   DCB   DDNAME=SYSUT2,MACRF=PM,DSORG=PS,                        X11830000
               RECFM=FB,LRECL=80                                        11840000
INSDD    DCB   DDNAME=xxxxxxxx,MACRF=GM,DSORG=PS,EODAD=INSEOF,         X11850000
               RECFM=FB,LRECL=80                                        11860000
INSTBREC DC    CL80' '                                                  11870000
INSTBLPT DC    A(INSTB)                                                 11880000
         DC    0D'0'                                                    11890000
INSTB    DC    100XL(L'INSTBL)'00'                                      11900000
         DC    0D'0'                                                    11910000
*********************************************************************** 11920013
*                                                                     * 11930013
*********************************************************************** 11940013
R0       EQU   0                                                        11950000
R1       EQU   1                                                        11960000
R2       EQU   2                                                        11970000
R3       EQU   3                                                        11980000
R4       EQU   4                                                        11990000
R5       EQU   5                                                        12000000
R6       EQU   6                                                        12010000
R7       EQU   7                                                        12020000
R8       EQU   8                                                        12030000
R9       EQU   9                                                        12040000
R10      EQU   10                                                       12050000
R11      EQU   11                                                       12060000
R12      EQU   12                                                       12070000
R13      EQU   13                                                       12080000
R14      EQU   14                                                       12090000
R15      EQU   15                                                       12100000
         END                                                            12110000
