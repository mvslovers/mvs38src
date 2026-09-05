*********************************************************************** 00010000
*                                                                     * 00020000
* Module name                                                         * 00030000
*    MVSASMSS                                                         * 00040000
*                                                                     * 00050000
* Attributes                                                          * 00060000
*    None                                                             * 00070000
*                                                                     * 00080000
* Author                                                              * 00090000
*    Dave Kreiss                                                      * 00100000
*                                                                     * 00110000
* Function                                                            * 00120000
*    Remove SSI information left over from original source.           * 00130000
*                                                                     * 00140000
* JCL                                                                 * 00150000
*    //CLEAN   EXEC PGM=MVSASMSS,PARM='Parameters'                    * 00160000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00170000
*    //SYSPRINT DD  SYSOUT=*                                          * 00180000
*    //SYSUT1   DD  DSN=MVSSRC.BLD.MVSSRC,DISP=SHR                    * 00190000
*                                                                     * 00200000
* DD Statements                                                       * 00210000
*    STEPLIB       Load library containing MVSASMSS.                  * 00220000
*    SYSPRINT      Contains report of SSI removal process.            * 00230000
*    SYSUT1        Data set containng source library.                 * 00240000
*                                                                     * 00250000
* Parameters                                                          * 00260000
*    All parameters are seperated by commas.                          * 00270000
*    DEBUG          Peoduces debuffing information.                   * 00280000
*    LIST           Reports the directory entry for each membere.     * 00290000
*    TEST           SSI information isn't removed.                    * 00300000
*                                                                     * 00310000
* Return codes                                                        * 00320000
*    0              Successfully passed input soruce library,         * 00330000
*    8              An error occured see SYSPRINT.                    * 00340000
*                                                                     * 00350000
* Sample JCL                                                          * 00360000
*    //CLEAN   EXEC PGM=MVSASMSS,PARM='LIST,TEST'                     * 00370000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00380000
*    //SYSPRINT DD  SYSOUT=*                                          * 00390000
*    //SYSUT1   DD  DSN=MVSSRC.BLD.MVSSRC,DISP=SHR                    * 00400000
*                                                                     * 00410000
*********************************************************************** 00420000
*                                                                     * 00430000
* CHANGE LOG:                                                         * 00440000
*   Date     INT VV.RR Description                                    * 00450000
* 05/28/2020 DSK 01.01 Created                                        * 00460000
         LCLC   &VER                                                    00470000
&VER     SETC   '01.01'                                                 00480000
*                                                                     * 00490000
*********************************************************************** 00500000
MVSASMSS CSECT                                                          00510000
         USING MVSASMSS,R15                                             00520000
         B     START                   Skip program id                  00530000
         DROP  R15                                                      00540000
         DC    AL1(L'PGMID)                                             00550000
PGMID    DC    C'MVSASMSS - RESET SSI &VER &SYSDATE &SYSTIME'           00560000
*********************************************************************** 00570000
*        Initialization                                               * 00580000
*********************************************************************** 00590000
START    STM   R14,R12,12(R13)         Save registers                   00600000
         LR    R12,R15                 Set base                         00610000
         USING MVSASMSS,R12                                             00620000
         ST    R13,SAVEAREA+4          Save prev save area addr         00630000
         LR    R15,R13                 Save callers save area addr      00640000
         LA    R13,SAVEAREA            My save area addr                00650000
         ST    R13,8(,R15)             Save my save area addr           00660000
         BAL   R14,INIT                Initialization                   00670000
         LTR   R15,R15                 Was it successful?               00680000
         BNZ   ERRORXIT                No, error message issued         00690000
*********************************************************************** 00700000
*        Preload directory since STOW will change directory blocks    * 00710000
*********************************************************************** 00720000
         LA    R2,INSTGDIR             Beginning of in storage dir      00730000
READDIR  DS    0H                                                       00740000
         READ  DIRDECB,SF,DIRDCB,DIRENT Read directory block            00750000
         CHECK DIRDECB                 Check for I/O completion         00760000
         AP    DIRCNT,=P'+1'           Count blocks                     00770000
         TM    FLAG,FLAGOFL            We overflow                      00780000
         BO    READOVR                 Yes, just count                  00790000
         LA    R0,DIRENT               Start of directory block         00800000
         LH    R1,DIRENT               Length of that block             00810000
         LR    R3,R1                   Copy length                      00820000
         L     R15,=A(DIREND)          End of in storage buffer         00830000
         LA    R14,0(R2,R3)            Get where this block ends        00840000
         CR    R14,R15                 Will if fit                      00850000
         BNL   READOFL                 No, lets mark error and continue 00860000
         MVCL  R2,R0                   Copy block to in storage buffer  00870000
         B     READDIR                 Next directory block             00880000
READOFL  DS    0H                                                       00890000
         OI    FLAG,FLAGOFL            Mark overflowed buffer           00900000
READOVR  DS    0H                                                       00910000
         AP    DIROFL,=P'+1'           Count those that didn't fit      00920000
         B     READDIR                 Next directory block             00930000
*********************************************************************** 00940000
*        Process in storage directory                                 * 00950000
*********************************************************************** 00960000
EOD      DS    0H                                                       00970000
         TM    FLAG,FLAGOFL            In storage buffer overflowed     00980000
         BO    ERROROFL                Yes, issue error messages        00990000
         LR    R11,R2                  Last used position in table      01000000
         LA    R10,INSTGDIR            Beginning of instorage directory 01010000
NEXTBLK  DS    0H                                                       01020000
         CR    R10,R11                 We beyond the end                01030000
         BNL   ERRORPRS                Yses, something went wrong       01040000
         LH    R9,0(,R10)              Get no of bytes used in dir blk  01050000
         LA    R8,2                    Set offset to next dir entry     01060000
GETMEM   DS    0H                                                       01070000
         AR    R10,R8                  Bump to next dir entry           01080000
         SR    R9,R8                   Calc remaining bytes to process  01090000
         LTR   R9,R9                   End of dir blk                   01100000
         BNH   NEXTBLK                 Yes, get another dir blk         01110000
         CLC   0(8,R10),=8X'FF'        End of directory                 01120000
         BE    EXIT                    Yes, done                        01130000
         IC    R8,11(,R10)             Get number user data halfwords   01140000
         N     R8,=F'31'               Clear bits except user data cnt  01150000
         SLL   R8,1                    Convert halfword count to bytes  01160000
         LA    R8,12(,R8)              Calc offset to next dir entry    01170000
         AP    MBRCNT,=P'+1'           Count members                    01180000
         TM    FLAG,FLAGLST            LIST requested                   01190000
         BNO   LSTEND                  No, skip it                      01200000
         MVC   LINE+1(8),0(R10)        Move member name to print        01210000
         LA    R15,8(,R10)             Start of directory enry          01220000
         LA    R1,LINE+30              Where to format the directory    01230000
         LR    R0,R8                   Copy entry length                01240000
         SH    R0,=H'8'                Less member length               01250000
         BZ    LSTEND                  Should not occur                 01260000
         LA    R14,=A(3,1,0)           TTR, flag and rest lengths       01270000
         L     R2,0(,R14)              Get ttr length                   01280000
LSTDIR   DS    0H                                                       01290000
         UNPK  0(3,R1),0(2,R15)        Format one position              01300000
         TR    0(2,R1),HEXTBL-240      Make hex visible                 01310000
         MVI   2(R1),C' '              Clear junk form convert          01320000
         LA    R15,1(,R15)             Next entry position              01330000
         LA    R1,2(,R1)               Next print position              01340000
         BCT   R2,LSTNSKP              Loop through formatting          01350000
         LA    R1,1(,R1)               Skip a position                  01360000
         LA    R14,4(,R14)             Next length                      01370000
         L     R2,0(,R14)              Get that length                  01380000
LSTNSKP  DS    0H                                                       01390000
         C     R1,=A(LINE+130)         End of print line                01400000
         BNL   LSTEND                  Yes, thats all we format         01410000
         BCT   R0,LSTDIR               Loop throught dir entry          01420000
LSTEND   DS    0H                                                       01430000
         CH    R8,=H'+16'              Length of dir entry with SSI     01440000
         BNE   NOSSI                   No, SSI not here                 01450000
         AP    MBRSSI,=P'+1'           Count members with SSI           01460000
         TM    FLAG,FLAGTST            Are we just testing              01470000
         BNO   RESET                   No, go reset                     01480000
         MVC   LINE+1(8),0(R10)        Move member name to print        01490000
         MVC   LINE+10(11),=C'SSI present' Message                      01500000
         BAL   R14,PRT                 Print a line                     01510000
         B     MBRDONE                 Done with member                 01520000
RESET    DS    0H                                                       01530000
         MVC   STOWMBR(11),0(R10)      Member name+TTR                  01540000
         MVI   STOWSIZ,0               No user data                     01550000
         STOW  DIRDCB,STOWLIST,R       Replace directory entry          01560000
         LTR   R15,R15                 STOW successful                  01570000
         BNZ   STOWERR                 No, error                        01580000
         MVC   LINE+1(8),0(R10)        Move member name to print        01590000
         MVC   LINE+10(9),=C'SSI reset' Message                         01600000
         BAL   R14,PRT                 Print a line                     01610000
         B     MBRDONE                 Done with member                 01620000
NOSSI    DS    0H                                                       01630000
         MVC   LINE+1(8),0(R10)        Move member name to print        01640000
         MVC   LINE+10(14),=C'No SSI present' Message                   01650000
         BAL   R14,PRT                 Print a line                     01660000
         AP    MBRNSSI,=P'+1'          Count members without SSI        01670000
MBRDONE  DS    0H                                                       01680000
         B     GETMEM                  Next member                      01690000
*********************************************************************** 01700000
*        Termination                                                  * 01710000
*********************************************************************** 01720000
EXIT     DS    0H                                                       01730000
         MVC   LINE+1(16),=C'Directory blocks' Message                  01740000
         MVC   LINE+21(10),=X'40206B2020206B202120' Edit mask           01750000
         ED    LINE+21(10),DIRCNT      Edit count                       01760000
         S     R11,INSTGDIR            Get storage used                 01770000
         SRL   R11,10                  Convert to K                     01780000
         CVD   R10,DWORD               Convert to packed                01790000
         MVC   LINE+31(10),=X'40206B2020206B202120' Edit mask           01800000
         ED    LINE+31(10),DWORD+4     Edit storage                     01810000
         MVC   LINE+41(18),=C'K (directory size)' Message               01820000
         BAL   R14,PRT                 Print a line                     01830000
         MVC   LINE+1(13),=C'Members W/SSI' Message                     01840000
         MVC   LINE+21(10),=X'40206B2020206B202120' Edit mask           01850000
         ED    LINE+21(10),MBRSSI      Edit count                       01860000
         BAL   R14,PRT                 Print a line                     01870000
         MVC   LINE+1(15),=C'Members W/O SSI' Message                   01880000
         MVC   LINE+21(10),=X'40206B2020206B202120' Edit mask           01890000
         ED    LINE+21(10),MBRNSSI     Edit count                       01900000
         BAL   R14,PRT                 Print a line                     01910000
         MVC   LINE+1(7),=C'Members'   Message                          01920000
         MVC   LINE+21(10),=X'40206B2020206B202120' Edit mask           01930000
         ED    LINE+21(10),MBRCNT      Edit count                       01940000
         BAL   R14,PRT                 Print a line                     01950000
         CLOSE (DIRDCB,,SYSPRINT)      CLOSE files                      01960000
         L     R13,SAVEAREA+4          Restore callers save area addr   01970000
         RETURN (14,12),RC=0           Exit program return code 0       01980000
*********************************************************************** 01990000
*        Errors                                                       * 02000000
*********************************************************************** 02010000
STOWERR  DS    0H                                                       02020000
         MVC   LINE+1(13),=C'STOW (UPDATE)' Message                     02030000
         MVC   LINE+17(8),STOWMBR      Member                           02040000
         MVC   LINE+26(6),=C'R15=X'''  Message                          02050000
         ST    R15,DWORD               Get R15                          02060000
         UNPK  LINE+32(9),DWORD(5)     Unpack for display               02070000
         TR    LINE+32(8),HEXTBL-240   Convert hex digits               02080000
         MVI   LINE+40,C''''           Clear junk                       02090000
         MVC   LINE+42(5),=C'R0=X'''   Messaege                         02100000
         ST    R0,DWORD                Get R0                           02110000
         UNPK  LINE+47(9),DWORD(5)     Unpack for display               02120000
         TR    LINE+47(8),HEXTBL-240   Convert hex digits               02130000
         MVI   LINE+55,C''''           Clear junk                       02140000
         BAL   R14,PRT                 Print a line                     02150000
         LA    R15,8                   Return code                      02160000
         B     ERRORXIT                Error exit                       02170000
ERROROFL DS    0H                                                       02180000
         MVC   LINE+1(24),=C'Directory table overflow' Message          02190000
         BAL   R14,PRT                                                  02200000
         MVC   LINE+1(16),=C'Directory blocks' Message                  02210000
         MVC   LINE+21(10),=X'40206B2020206B202120' Edit mask           02220000
         ED    LINE+21(10),DIRCNT      Edit count                       02230000
         BAL   R14,PRT                 Print a line                     02240000
         MVC   LINE+1(18),=C'Blocks in overflow' Message                02250000
         MVC   LINE+21(10),=X'40206B2020206B202120' Edit mask           02260000
         ED    LINE+21(10),DIROFL      Edit count                       02270000
         BAL   R14,PRT                 Print a line                     02280000
         LA    R15,8                   Return code                      02290000
         B     ERRORXIT                Error exit                       02300000
ERRORPRS DS    0H                                                       02310000
         MVC   LINE+1(37),=C'Error processing in storage directory'     02320000
         BAL   R14,PRT                 Print a line                     02330000
         LA    R15,8                   Return code                      02340000
         B     ERRORXIT                Error exit                       02350000
ERROR004 DS    0H                                                       02360000
         LA    R15,8                   Return code                      02370000
         B     ERRORXIT                Error exit                       02380000
ERROR083 DS    0H                                                       02390000
         MVC   LINE+1(17),=C'SYSUT1 DD missing' Message                 02400000
         BAL   R14,PRT                 Print a line                     02410000
         LA    R15,8                   Return code                      02420000
ERRORXIT DS    0H                                                       02430000
         L     R13,SAVEAREA+4          Restore callers save area addr   02440000
         RETURN (14,12),RC=(15)        Exit program return code in R15  02450000
**********************************************************************  02460000
*                                                                    *  02470000
*        Initialization                                              *  02480000
*                                                                    *  02490000
**********************************************************************  02500000
INIT     DS    0H                                                       02510000
         ST    R14,INITR14             Save return address              02520000
         L     R9,0(,R1)               Save parm address                02530000
         OPEN  (SYSPRINT,(OUTPUT))     OPEN SYSPRINT                    02540000
         TM    SYSPRINT+48,16          OPEN successful?                 02550000
         BZ    ERROR004                No, terminate                    02560000
         TIME  BIN                     Get current date and time        02570000
         ST    R1,CURDATE              Save date                        02580000
         SRDL  R0,32                   Get double word time             02590000
         D     R0,=F'+6000'            Get minutes                      02600000
         LR    R15,R0                  Save secs tens and hundreths     02610000
         SLR   R0,R0                   Clear                            02620000
         D     R0,=F'+60'              Get hours / mins                 02630000
         MH    R0,=H'+10000'           Get minutes                      02640000
         AR    R15,R0                  Add to get MM:SS.TH              02650000
         M     R0,=F'+1000000'         Get hours                        02660000
         AR    R1,R15                  Get HH:MM:SS.TH                  02670000
         CVD   R1,DWORD                Get time to decimal              02680000
         MVC   TIMWRK4,=X'402021207A20207A20204B2020'                   02690000
         ED    TIMWRK4,DWORD+3         Edit time                        02700000
         MVC   HD1TOD(8),TIMWRK4+2     Move time                        02710000
         ZAP   JULWRK2,CURDATE+2(2)    Get julian date                  02720000
         ZAP   JULWRK4,=P'+365'        Days/yr = 365                    02730000
         ZAP   JULWRK6,=P'+28'         Feb = 28                         02740000
         MVO   DWORD,CURDATE+1(1)      Sign year                        02750000
         DP    DWORD,=P'+4'            Divide by 4                      02760000
         CP    DWORD+7(1),=P'+0'       Is it a leap year?               02770000
         BNZ   INITJL2                 No                               02780000
         ZAP   JULWRK4,=P'+366'        Days/yr = 366                    02790000
         ZAP   JULWRK6,=P'+29'         Feb = 29                         02800000
INITJL2  DS    0H                                                       02810000
         LA    R1,JULTBL1              Point to January                 02820000
         SLR   R2,R2                   Set counter                      02830000
INITJL4  DS    0H                                                       02840000
         SP    JULWRK2,0(2,R1)         Months displacement              02850000
         BNP   INITJL6                 If equal or less than 0 done     02860000
         BCTR  R1,0                    Point to next month              02870000
         BCTR  R1,0                    Point to next month              02880000
         LA    R2,3(,R2)               Up index                         02890000
         B     INITJL4                 Loop                             02900000
INITJL6  DS    0H                                                       02910000
         AP    JULWRK2,0(2,R1)         Add days of month                02920000
         LA    R2,JULTBL2(R2)          Address month                    02930000
         MVC   HD1DATE(3),0(R2)        Move month                       02940000
         OI    JULWRK2+3,X'0F'         Display sign                     02950000
         UNPK  HD1DATE+4(2),JULWRK2    Get days                         02960000
         CLI   HD1DATE+4,C'0'          First 9 days?                    02970000
         LA    R1,HD1DATE+6            Set pointer                      02980000
         BNE   INITJL7                 No                               02990000
         MVC   HD1DATE+4(1),HD1DATE+5  Move units digit                 03000000
         BCTR  R1,0                    Drop pointer                     03010000
INITJL7  DS    0H                                                       03020000
         MVC   0(4,R1),=C', 19'        Set up constant                  03030000
         TM    CURDATE,1               Year 2000?                       03040000
         BNO   INITJL8                 No, continue                     03050000
         MVC   2(2,R1),=C'20'          Y2K                              03060000
INITJL8  DS    0H                                                       03070000
         UNPK  DWORD(3),CURDATE+1(2)   Unpack year                      03080000
         MVC   4(2,R1),DWORD           Get year                         03090000
*                                                                       03100000
         MVC   LINE+1(8),=C'Version='  Move version literal             03110000
         MVC   LINE+9(L'PGMID),PGMID   Move version                     03120000
         BAL   R14,PRT                 Print a line                     03130000
*                                                                       03140000
         MVC   LINE+1(5),=C'PARM='     Move parameter info literal      03150000
         CLI   1(R9),0                 Any parameter?                   03160000
         BE    PRMPRT                  No, skip move                    03170000
         LH    R1,0(,R9)               Get parmeter length              03180000
         BCTR  R1,0                    Make machine length              03190000
         EX    R1,PRMMVC               Move parm to print line          03200000
         B     PRMPRT                  Skip move                        03210000
PRMMVC   MVC   LINE+6(0),2(R9)         Executed parm move               03220000
PRMPRT   DS    0H                                                       03230000
         BAL   R14,PRT                 Print a line                     03240000
         LH    R2,0(,R9)               Get parm length                  03250000
         AH    R9,=H'+2'               Skip length                      03260000
         ST    R9,W#PRMBGN             Save parm start                  03270000
PRMSCN   DS    0H                                                       03280000
         LTR   R2,R2                   End of parm?                     03290000
         BZ    PRMEND                  Yes, parm parsed                 03300000
         CLI   0(R9),C','              Seperator?                       03310000
         BNE   PRMCHK                  No, check values                 03320000
         AH    R9,=H'+1'               Skip comma                       03330000
         SH    R2,=H'+1'               Decrement length                 03340000
         B     PRMSCN                  Continue scan                    03350000
PRMCHK   DS    0H                                                       03360000
         CH    R2,=H'+4'               Length large enough              03370000
         BL    PRMERR                  No, error                        03380000
         CLC   =C'LIST',0(R9)          LIST parameter                   03390000
         BE    PRMLST                  Yes                              03400000
         CLC   =C'TEST',0(R9)          LIST parameter                   03410000
         BE    PRMLST                  Yes                              03420000
         CH    R2,=H'+5'               Length large enough              03430000
         BL    PRMERR                  No, error                        03440000
         CLC   =C'DEBUG',0(R9)         DEBUG parameter                  03450000
         BNE   PRMDBG                  Yes                              03460000
         B     PRMERR                  Error                            03470000
PRMLST   DS    0H                                                       03480000
         OI    FLAG,FLAGLST            Set LIST                         03490000
         AH    R9,=H'+4'               Get past parameter               03500000
         SH    R2,=H'+4'               Decrement length                 03510000
         BZ    PRMEND                  If end of parameters             03520000
         B     PRMSCN                  Process next parameter           03530000
PRMTST   DS    0H                                                       03540000
         OI    FLAG,FLAGTST            Set TEST                         03550000
         AH    R9,=H'+4'               Get past parameter               03560000
         SH    R2,=H'+4'               Decrement length                 03570000
         BZ    PRMEND                  If end of parameters             03580000
         B     PRMSCN                  Process next parameter           03590000
PRMDBG   DS    0H                                                       03600000
         OI    FLAG,FLAGDBG            Set DEBUG                        03610000
         AH    R9,=H'+5'               Get past parameter               03620000
         SH    R2,=H'+5'               Decrement length                 03630000
         BZ    PRMEND                  If end of parameters             03640000
         B     PRMSCN                  Process next parameter           03650000
PRMERR   DS    0H                                                       03660000
         LR    R1,R9                   Current position                 03670000
         S     R1,W#PRMBGN             Less start                       03680000
         LA    R1,LINE+6(R1)           Set location of error            03690000
         MVI   0(R1),C'*'              Mark where error is              03700000
         BAL   R14,PRT                 Print a line                     03710000
         MVC   LINE(19),=C' Parameters invalid'                         03720000
         BAL   R14,PRT                 Print a line                     03730000
         B     INITER                  Error                            03740000
PRMEND   DS    0H                                                       03750000
         OPEN  (DIRDCB,(UPDATE))       OPEN files                       03760000
         TM    DIRDCB+48,X'10'         Valid OPEN                       03770000
         BNO   ERROR083                No, terminate                    03780000
         LA    R2,MYJFCB               Address of JFCB                  03790000
         USING JFCB,R2                                                  03800000
         RDJFCB DIRDCB                 Read directory JFCB              03810000
         MVC   LINE+1(10),=C'Input DSN=' Message                        03820000
         MVC   LINE+11(44),JFCB        Set up info                      03830000
         BAL   R14,PRT                 Print line                       03840000
         SR    R15,R15                 Set successful return code       03850000
         B     INITXT                  Go exit                          03860000
INITER   DS    0H                                                       03870000
         LA    R15,8                   Set error return code            03880000
INITXT   DS    0H                                                       03890000
         L     R14,INITR14             Get return address               03900000
         BR    R14                     Exit initialization              03910000
**********************************************************************  03920000
*                                                                    *  03930000
*        Print a line                                                *  03940000
*                                                                    *  03950000
**********************************************************************  03960000
PRT      DS    0H                                                       03970000
         ST    R14,PRTR14              Save return address              03980000
         CP    LNCT,=P'+60'            End of page                      03990000
         BL    PRTCHK                  No, check if line fit in page    04000000
PRTHDRS  DS    0H                                                       04010000
         AP    PGCT,=P'+1'             Count pages                      04020000
         MVC   HD1PGCT,=X'40202120'    Page count mask                  04030000
         ED    HD1PGCT,PGCT            Edit page count                  04040000
         PUT   SYSPRINT,HD1            Print heading 1                  04050000
         ZAP   LNCT,=P'+2'             Init line count                  04060000
         MVI   LINE,C'0'               Skip after heading               04070000
PRTCHK   DS    0H                                                       04080000
         CLI   LINE,C'+'               Overprint?                       04090000
         BE    PRTLINE                 Yes, don't count                 04100000
         CLI   LINE,C'1'               New page?                        04110000
         BE    PRTHDRS                 Yes, print header                04120000
         CLI   LINE,C' '               Write after advancing 1?         04130000
         BE    PRTLINE1                Yes, go check if fit             04140000
         CLI   LINE,C'0'               Write after advancing 2?         04150000
         BE    PRTLINE2                Yes, go check if fit             04160000
         CLI   LINE,C'-'               Write after advancing 3?         04170000
         BE    PRTLINE3                Yes, go check if fit             04180000
         B     PRTLINE                 Ignore any other ctl chars       04190000
PRTLINE1 DS    0H                                                       04200000
         AP    LNCT,=P'+1'             Add to line count                04210000
         B     PRTVFY                  Go see if it will fit            04220000
PRTLINE2 DS    0H                                                       04230000
         AP    LNCT,=P'+2'             Add to line count                04240000
         B     PRTVFY                  Go see if it will fit            04250000
PRTLINE3 DS    0H                                                       04260000
         AP    LNCT,=P'+3'             Add to line count                04270000
PRTVFY   DS    0H                                                       04280000
         CP    LNCT,=P'+60'            Overflow ?                       04290000
         BH    PRTHDRS                 Yes, force header                04300000
PRTLINE  DS    0H                                                       04310000
         PUT   SYSPRINT,LINE           Print a line                     04320000
         MVI   LINE,C' '               Clear control character          04330000
         MVC   LINE+1(L'LINE-1),LINE   Clear print line                 04340000
         L     R14,PRTR14              Restore return address           04350000
         BR    R14                     Return to caller                 04360000
**********************************************************************  04370000
*                                                                    *  04380000
*        Constants                                                   *  04390000
*                                                                    *  04400000
**********************************************************************  04410000
         LTORG                                                          04420000
HEXTBL   DC    C'0123456789ABCDEF'     Hex to display table             04430000
**********************************************************************  04440000
*                                                                    *  04450000
*        Work areas                                                  *  04460000
*                                                                    *  04470000
**********************************************************************  04480000
         DC    0D'0'                                                    04490000
SAVEAREA DC    18A(0)                  Local save area                  04500000
DWORD    DC    D'+0'                   Doubleword                       04510000
INITR14  DC    A(0)                    Save linkage                     04520000
PRTR14   DC    A(0)                    Save linkage                     04530000
W#PRMBGN DC    A(0)                    Start of PARM=                   04540000
DIRCNT   DC    PL4'+0'                 Directory block count            04550000
DIROFL   DC    PL4'+0'                 Overflow directory block count   04560000
MBRCNT   DC    PL4'+0'                 Member count                     04570000
MBRSSI   DC    PL4'+0'                 Members with SSI                 04580000
MBRNSSI  DC    PL4'+0'                 Members with out SSI             04590000
FLAG     DC    AL1(0)                  Flags                            04600000
FLAGDBG  EQU   X'80'                   DEBUG                            04610000
FLAGLST  EQU   X'40'                   LIST                             04620000
FLAGTST  EQU   X'20'                   TEST                             04630000
FLAGOFL  EQU   X'10'                   Overflowed buffer                04640000
*                                                                       04650000
STOWLIST DC    0D'0'                   List of member names for STOW    04660000
STOWMBR  DC    CL8' '                  Name of member                   04670000
STOWTTR  DC    XL3'0'                  TTR of first record              04680000
STOWSIZ  DC    X'00'                   Flag byte+size of user data      04690000
*                                                                       04700000
         DC    0D'0'                                                    04710000
DIRENT   DC    XL256'0'                Directory block                  04720000
*                                                                       04730000
DIRDCB   DCB   BLKSIZE=256,DDNAME=SYSUT1,DEVD=DA,DSORG=PS,EODAD=EOD,   *04740000
               MACRF=(R,W),EXLST=DIRJFCB                                04750000
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X04760000
               RECFM=FBA,LRECL=133                                      04770000
*                                                                       04780000
         DC    0A(0)                                                    04790000
DIRJFCB  DC    AL1(128+7),AL3(MYJFCB)  EXLST for RDJFCB                 04800000
*                                                                       04810000
MYJFCB   DC    XL176'0'                JFCB                             04820000
LINE     DC    CL133' '                Print line                       04830000
CURDATE  DC    A(0)                    Current date                     04840000
JULWRK2  DC    A(0)                    Conversion work area             04850000
*                                                                       04860000
JULWRK4  DC    P'+365'                 Julian to Gregorian table        04870000
         DC    P'+01'                                                   04880000
         DC    P'+31'                                                   04890000
         DC    P'+30'                                                   04900000
         DC    P'+31'                                                   04910000
         DC    P'+30'                                                   04920000
         DC    P'+31'                                                   04930000
         DC    P'+31'                                                   04940000
         DC    P'+30'                                                   04950000
         DC    P'+31'                                                   04960000
         DC    P'+30'                                                   04970000
         DC    P'+31'                                                   04980000
JULWRK6  DC    P'+28'                                                   04990000
JULTBL1  DC    P'+31'                                                   05000000
*                                                                       05010000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec' Month table      05020000
TIMWRK4  DC    X'402021204B20204B20204B2020' Edited time                05030000
LNCT     DC    PL2'+99'                Line counter                     05040000
PGCT     DC    PL2'+0'                 Page counter                     05050000
*                                                                       05060000
HD1      DC    CL133'1'                Heading line                     05070000
         ORG   HD1+1                                                    05080000
HD1DATE  DC    C'            '                                          05090000
         DC    C' '                                                     05100000
HD1TOD   DC    C'HH:MM:SS'                                              05110000
         DC    C' '                                                     05120000
         ORG   HD1+66-(16/2)                                            05130000
HD1DATA  DC    C'Remove SSI info'                                       05140000
         ORG   HD1+L'HD1-8                                              05150000
HD1PG    DC    C'Page'                                                  05160000
HD1PGCT  DC    C' 123'                                                  05170000
*                                                                       05180000
WORKEND  DC    0D'0'                   End of work areas                05190000
INSTGDIR DC    1024XL100'0'            In storage directory buffer      05200000
DIREND   EQU   *                       End of buffer                    05210000
**********************************************************************  05220000
*                                                                    *  05230000
*        DSECTs and equates                                          *  05240000
*                                                                    *  05250000
**********************************************************************  05260000
R0       EQU   0                                                        05270000
R1       EQU   1                                                        05280000
R2       EQU   2                                                        05290000
R3       EQU   3                                                        05300000
R4       EQU   4                                                        05310000
R5       EQU   5                                                        05320000
R6       EQU   6                                                        05330000
R7       EQU   7                                                        05340000
R8       EQU   8                                                        05350000
R9       EQU   9                                                        05360000
R10      EQU   10                                                       05370000
R11      EQU   11                                                       05380000
R12      EQU   12                                                       05390000
R13      EQU   13                                                       05400000
R14      EQU   14                                                       05410000
R15      EQU   15                                                       05420000
JFCB     DSECT                                                          05430000
         IEFJFCBN                                                       05440000
         END                                                            05450000
