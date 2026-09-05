*********************************************************************** 00010000
*                                                                     * 00020000
*  SUBMIT Controller - Submit job if selected                         * 00030000
*                                                                     * 00040000
*********************************************************************** 00050000
*                                                                     * 00060001
*  DD Statements                                                      * 00070001
*    STEPLIB       Load library containing load module.               * 00080001
*    SYSIN         Controller data set.                               * 00090001
*    SYSUT1        Job to submit.                                     * 00100001
*    SYSUT2        Internal reader.                                   * 00110001
*    SYSPRINT      Output listing.                                    * 00120001
*                                                                     * 00130000
*  Parameters                                                         * 00140000
*        PARM=jobid    1 to 8 character job name.                     * 00150000
*                      If this job is in the SYSIN data set with      * 00160000
*                      a selection of YES the job submit is done by   * 00170000
*                      copying the SYSUT1 to SYSUT2.                  * 00180000
*                      Must be first parameter in PARM=.              * 00190002
*        PARM=DEBUG    Enables debugging.                             * 00200002
*        PARM=OMIT=x   Omit option.                                   * 00210002
*                      Values are Y or N.                             * 00220002
*                      Y means if job not in list submit anyway.      * 00230002
*                      N means if job not in list skip submit.        * 00240002
*                      Default is Y.                                  * 00250002
*        Example:                                                     * 00260000
*                      PARM='JOBNAME,OMIT=N'                          * 00270002
*  Return codes                                                       * 00280000
*        0             The job was found in the SYSIN dataset or      * 00290002
*                      not in list and omit option was enabled.       * 00300002
*                      The job in SYSUT1 was copied to SYSUT2.        * 00310002
*        4             The job was found but not enabled.             * 00320000
*        8             An error was found.                            * 00330000
*                                                                     * 00340001
*  Sample JCL                                                         * 00350001
*        //        EXEC PGM=SUBNEXT,PARM='parameters'                 * 00360001
*        //STEPLIB  DD  DSN=load library,DISP=SHR                     * 00370001
*        //SYSIN    DD  DSN=submit controller data set                * 00380001
*        //SYSPRINT DD  SYSOUT=*                                      * 00390001
*        //SYSUT1   DD  DSN=job to submit data set                    * 00400001
*        //SYSUT2   DD  SYSOUT=(B,INTRDR)                             * 00410001
*                                                                     * 00420000
*  NOTES                                                              * 00430000
*        The SYSIN data set contains a list of jobs one per record.   * 00440000
*        Positions 1-8 are a job name.                                * 00450000
*        Positions 9-11 are YES if job can be submitted.              * 00460000
*        Rest is comments.                                            * 00470001
*                                                                     * 00480000
*********************************************************************** 00490000
*                                                                     * 00500000
* CHANGE LOG:                                                         * 00510000
* MM/DD/YY AAA VV.VV DESCRIPTION                                      * 00520000
* 01/13/20 DSK 1.01  Created                                          * 00530000
* 03/07/20 DSK 1.02  Add OMIT= PARM option.                           * 00540002
* 05/27/20 DSK 1.03  Fix SYSIN S001-4 BLKSIZE hard coded              * 00550003
         LCLC &VER                                                      00560000
&VER     SETC 'V1.03'                                                   00570003
*                                                                     * 00580000
*********************************************************************** 00590000
*        Initialize                                                   * 00600000
*********************************************************************** 00610000
SUBNEXT  CSECT                                                          00620000
         USING SUBNEXT,R15                                              00630000
         B     START                   Bypass PGMID                     00640000
         DROP  R15                                                      00650000
         DC    AL1(PGMIDLEN)           Length of PGMID                  00660000
PGMID    DC    C'SUBNEXT - &VER &SYSDATE &SYSTIME'                      00670000
PGMIDLEN EQU   *-PGMID                                                  00680000
START    DS    0H                                                       00690000
         STM   R14,R12,12(R13)         Save calling pgm's registers     00700000
         LR    R12,R15                                                  00710000
         USING SUBNEXT,R12                                              00720000
         L     R9,0(,R1)               Save parameter address           00730000
         LR    R3,R13                  Save save area address           00740000
         L     R13,=A(W#)              Address save area                00750000
         USING W#,R13                                                   00760000
         ST    R3,4(,R13)              Chain callers save area          00770000
         ST    R13,8(,R3)              Chain my save area               00780000
         BAL   R14,INIT                Initialization                   00790000
         LTR   R3,R15                  Was it successful?               00800000
         BNZ   QUIT                    No, exit                         00810000
*********************************************************************** 00820000
*        Get jobs selected                                            * 00830000
*********************************************************************** 00840000
FINDJOB  DS    0H                                                       00850000
         GET   W#INDCB,W#INREC         Get record                       00860000
         TM    W#FLG,W#FLGDBG                                           00870000
         BNO   FINDNDB                                                  00880000
         MVC   W#LINE+1(8),=C'SYSIN ->'                                 00890000
         MVC   W#LINE+9(80),W#INREC                                     00900000
         BAL   R14,PRT                                                  00910000
FINDNDB  DS    0H                                                       00920000
         CLC   W#JOBID,W#INREC                                          00930000
         BNE   FINDJOB                                                  00940000
         CLC   =C'YES',W#INREC+8                                        00950000
         BNE   FINDSKP                                                  00960000
SUBMIT   DS    0H                                                    02 00970002
         MVC   W#LINE+1(14),=C'Submitting....'                          00980000
         BAL   R14,PRT                                                  00990000
         OPEN  (W#SODCB,(OUTPUT),W#SIDCB,(INPUT))                       01000000
         TM    W#SIDCB+48,16           OPEN successful?                 01010000
         BZ    SUBERR1                 No, error                        01020000
         TM    W#SODCB+48,16           OPEN successful?                 01030000
         BZ    SUBERR2                 No, error                        01040000
SUBREAD  DS    0H                                                       01050000
         GET   W#SIDCB                                                  01060000
         TM    W#FLG,W#FLGDBG                                           01070000
         BNO   SUBNDB                                                   01080000
         LR    R2,R1                                                    01090000
         MVC   W#LINE+1(9),=C'SYSUT1 ->'                                01100000
         MVC   W#LINE+10(80),0(R2)                                      01110000
         BAL   R14,PRT                                                  01120000
         LR    R1,R2                                                    01130000
SUBNDB   DS    0H                                                       01140000
         LR    R0,R1                                                    01150000
         AP    W#SUBCT,=P'+1'                                           01160000
         PUT   W#SODCB,(0)                                              01170000
         B     SUBREAD                                                  01180000
SUBEOF   DS    0H                                                       01190000
         CLOSE (W#SIDCB,,W#SODCB)                                       01200000
         MVC   W#LINE(10),=X'40206B2020206B202120'                      01210000
         ED    W#LINE(10),W#SUBCT                                       01220000
         MVC   W#LINE+11(17),=C'Records submitted'                      01230000
         BAL   R14,PRT                                                  01240000
         SR    R3,R3                                                    01250000
         B     EXIT                                                     01260000
*********************************************************************** 01270000
*        Errors                                                       * 01280000
*********************************************************************** 01290000
FINDSKP  DS    0H                                                       01300000
         MVC   W#LINE+1(22),=C'Job submission skipped'                  01310000
         BAL   R14,PRT                                                  01320000
         LA    R3,4                                                     01330000
         B     EXIT                                                     01340000
FINDNFD  DS    0H                                                       01350000
         MVC   W#LINE+1(31),=C'Job not found (Omitted jobs are'      02 01360002
         TM    W#FLG,W#FLGOMT                                        02 01370002
         BO    FINDNFSU                                              02 01380002
         MVC   W#LINE+33(14),=C'not submitted)'                      02 01390002
         BAL   R14,PRT                                                  01400000
         B     FINDSKP                                               02 01410002
FINDNFSU DS    0H                                                    02 01420002
         MVC   W#LINE+33(10),=C'submitted)'                          02 01430002
         BAL   R14,PRT                                               02 01440002
         B     SUBMIT                                                02 01450002
SUBERR1  DS    0H                                                       01460000
         MVC   W#LINE+1(18),=C'SYSUT1 OPEN failed'                      01470000
         BAL   R14,PRT                                                  01480000
         LA    R3,8                                                     01490000
         B     EXIT                                                     01500000
SUBERR2  DS    0H                                                       01510000
         MVC   W#LINE+1(18),=C'SYSUT2 OPEN failed'                      01520000
         BAL   R14,PRT                                                  01530000
         LA    R3,8                                                     01540000
*********************************************************************** 01550000
*        Termination                                                  * 01560000
*********************************************************************** 01570000
EXIT     DS    0H                                                       01580000
         MVC   W#LINE+1(12),=C'Return code='                            01590000
         CVD   R3,W#DWORD                                               01600000
         UNPK  W#LINE+13(3),W#DWORD+6(2)                                01610000
         OI    W#LINE+15,C'0'                                           01620000
         BAL   R14,PRT                                                  01630000
QUIT     DS    0H                                                       01640000
         CLOSE (W#OTDCB,,W#INDCB)                                       01650000
         L     R13,4(R13)              Restore callers R13              01660000
         L     R14,12(,R13)            Restore R14                      01670000
         LR    R15,R3                  Restore return code              01680000
         LM    R2,R12,28(R13)          Restore rest of registers        01690000
         BR    R14                     Exit                             01700000
*********************************************************************** 01710000
*        Initialization                                               * 01720000
*********************************************************************** 01730000
INIT     DS    0H                                                       01740000
         ST    R14,W#INIT14            Save linkage                     01750000
         MVI   W#FLG,W#FLGOMT          Default sub jobs not in list  02 01760002
         OPEN  (W#OTDCB,(OUTPUT),W#INDCB,(INPUT))                       01770000
         TM    W#OTDCB+48,16           OPEN successful?                 01780000
         BZ    INITER                  No, error                        01790000
         TM    W#INDCB+48,16           OPEN successful?                 01800000
         BZ    INITER                  No, error                        01810000
         TIME  BIN                     Get current date and time        01820000
         ST    R1,W#CURDTE             Save date                        01830000
         SRDL  R0,32                   Get double word time             01840000
         D     R0,=F'+6000'            Get minutes                      01850000
         LR    R15,R0                  Save secs tens and hundreths     01860000
         SLR   R0,R0                   Clear                            01870000
         D     R0,=F'+60'              Get hours / mins                 01880000
         MH    R0,=H'+10000'           Get minutes                      01890000
         AR    R15,R0                  Add to get MM:SS.TH              01900000
         M     R0,=F'+1000000'         Get hours                        01910000
         AR    R1,R15                  Get HH:MM:SS.TH                  01920000
         CVD   R1,W#DWORD              Get time to decimal              01930000
         MVC   W#TMWRK4,=X'402021204B20204B20204B2020'                  01940000
         ED    W#TMWRK4,W#DWORD+3      Edit time                        01950000
         MVC   W#HD1TOD(8),W#TMWRK4+2  Move time                        01960000
         ZAP   W#JLWK1,W#CURDTE+2(2)   Get julian date                  01970000
         ZAP   W#JLWK2,=P'+365'        Days/yr = 365                    01980000
         ZAP   W#JLWK02,=P'+28'        Feb = 28                         01990000
         MVO   W#DWORD,W#CURDTE+1(1)   Sign year                        02000000
         DP    W#DWORD,=P'+4'          Divide by 4                      02010000
         CP    W#DWORD+7(1),=P'+0'     Is it a leap year ?              02020000
         BNZ   JULCVT2                 No                               02030000
         ZAP   W#JLWK2,=P'+366'        Days/yr = 366                    02040000
         ZAP   W#JLWK02,=P'+29'        Feb = 29                         02050000
JULCVT2  DS    0H                                                       02060000
         LA    R1,W#JLWK01             Point to Jan                     02070000
         SLR   R2,R2                   Set counter                      02080000
JULCVT4  DS    0H                                                       02090000
         SP    W#JLWK1,0(2,R1)         Months displacement              02100000
         BNP   JULCVT6                 If equal or less                 02110000
         AH    R1,=H'-2'               Point to next month              02120000
         AH    R2,=H'+3'               Up index                         02130000
         B     JULCVT4                 Loop                             02140000
JULCVT6  DS    0H                                                       02150000
         AP    W#JLWK1,0(2,R1)         Add days of month                02160000
         LA    R2,JULTBL2(R2)          Address month                    02170000
         MVC   W#HD1DTE(3),0(R2)       Move month                       02180000
         OI    W#JLWK1+3,X'0F'         Display sign                     02190000
         UNPK  W#HD1DTE+4(2),W#JLWK1   Get days                         02200000
         CLI   W#HD1DTE+4,C'0'         First 9 days ?                   02210000
         LA    R1,W#HD1DTE+6           Set pointer                      02220000
         BNE   JULCVT7                 No                               02230000
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 Move units digit                02240000
         BCTR  R1,0                    Drop pointer                     02250000
JULCVT7  DS    0H                                                       02260000
         MVC   0(4,R1),=C', 19'        Set up constant                  02270000
         TM    W#CURDTE,1              Year 2000?                       02280000
         BNO   JULCVT8                 No, continue                     02290000
         MVC   2(2,R1),=C'20'          Year 2000                        02300000
JULCVT8  DS    0H                                                       02310000
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     02320000
         MVC   4(2,R1),W#DWORD         Get year                         02330000
*                                                                       02340000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            02350000
         MVC   W#LINE+9(L'PGMID),PGMID Move version                     02360000
         BAL   R14,PRT                 Print a line                     02370000
*                                                                       02380000
         MVC   W#LINE+1(5),=C'PARM='   Move parameter info literal      02390000
         CLI   1(R9),0                 Any parameter?                   02400000
         BE    PRMPRT                  No, skip move                    02410000
         LH    R1,0(,R9)               Get parmeter length              02420000
         BCTR  R1,0                    Make machine length              02430000
         EX    R1,PRMMVC               Move parm to print line          02440000
PRMPRT   DS    0H                                                       02450000
         BAL   R14,PRT                 Print a line                     02460000
*                                                                       02470000
         LH    R2,0(,R9)               Get PARM length                  02480000
         AH    R9,=H'+2'               Skip length                      02490000
         ST    R9,W#PRMBGN             Save PARM start                  02500000
         LTR   R2,R2                   End of PARM?                     02510000
         BZ    PRMEND                  Yes, PARM parsed                 02520000
         LA    R1,W#JOBID                                               02530000
         LA    R0,L'W#JOBID                                             02540000
PRMID    DS    0H                                                       02550000
         CLI   0(R9),C','                                               02560000
         BE    PRMNXT                                                   02570000
         MVC   0(1,R1),0(R9)                                            02580000
         AH    R9,=H'+1'                                                02590000
         SH    R2,=H'+1'                                                02600000
         BZ    PRMEND                                                   02610000
         AH    R1,=H'1'                                                 02620000
         BCT   R0,PRMID                                                 02630000
         LTR   R2,R2                                                    02640000
         BZ    PRMEND                                                   02650000
         CLI   0(R9),C','                                               02660000
         BNE   PRMERR                                                   02670000
PRMNXT   DS    0H                                                       02680000
         AH    R9,=H'+1'                                                02690000
         SH    R2,=H'+1'                                                02700000
         BZ    PRMEND                                                   02710000
PRMSCN   DS    0H                                                    02 02720002
         LTR   R2,R2                   End of PARM?                  02 02730002
         BE    PRMEND                  Yes, PARM parsed              02 02740002
         CLI   0(R9),C','              Seperator?                    02 02750002
         BNE   PRMCHK                  No, check values              02 02760002
         AH    R9,=H'+1'               Skip comma                    02 02770002
         SH    R2,=H'+1'               Decrement length              02 02780002
         B     PRMSCN                  Continue scan                 02 02790002
PRMCHK   DS    0H                                                    02 02800002
         CH    R2,=H'+5'                                                02810000
         BL    PRMERR                                                02 02820002
         CLC   =C'DEBUG',0(R9)                                          02830000
         BE    PRMDBG                                                02 02840002
         CH    R2,=H'+6'                                             02 02850002
         BL    PRMERR                                                02 02860002
         CLC   =C'OMIT=',0(R9)                                       02 02870002
         BE    PRMOMT                                                02 02880002
         B     PRMERR                                                02 02890002
PRMDBG   DS    0H                                                    02 02900002
         AH    R9,=H'+5'                                             02 02910002
         SH    R2,=H'+5'                                             02 02920002
         OI    W#FLG,W#FLGDBG                                        02 02930002
         B     PRMSCNC                 Continue scan                 02 02940002
PRMOMT   DS    0H                                                    02 02950002
         AH    R9,=H'+5'                                             02 02960002
         SH    R2,=H'+5'                                             02 02970002
         CLI   0(R9),C'Y'                                            02 02980002
         BE    PRMOMTY                                               02 02990002
         CLI   0(R9),C'N'                                            02 03000002
         BNE   PRMERR                                                02 03010002
         NI    W#FLG,255-W#FLGOMT                                    02 03020002
         B     PRMOMTXT                                              02 03030002
PRMOMTY  DS    0H                                                    02 03040002
         OI    W#FLG,W#FLGOMT                                        02 03050002
PRMOMTXT DS    0H                                                    02 03060002
         AH    R9,=H'+1'                                             02 03070002
         SH    R2,=H'+1'                                             02 03080002
         B     PRMSCNC                 Continue scan                 02 03090002
PRMSCNC  DS    0H                                                    02 03100002
         LTR   R2,R2                   End of PARM?                  02 03110002
         BE    PRMEND                  Yes, PARM parsed              02 03120002
         CLI   0(R9),C','              Delimiter?                    02 03130002
         BE    PRMSCN                  Yes, handle it                02 03140002
PRMERR   DS    0H                                                       03150000
         LR    R1,R9                   Current position                 03160000
         S     R1,W#PRMBGN             Less start                       03170000
         LA    R1,W#LINE+6(R1)         Set location of error            03180000
         MVI   0(R1),C'*'              Mark where error is              03190000
         BAL   R14,PRT                 Print a line                     03200000
         MVC   W#LINE(19),=C' Parameters invalid'                       03210000
         BAL   R14,PRT                 Print a line                     03220000
         B     INITER                  Error                            03230000
PRMEND   DS    0H                                                       03240000
         CLI   W#JOBID,C' '                                             03250000
         BE    INITNOID                                                 03260000
         SR    R15,R15                 Set successful return code       03270000
         B     INITXT                  Go exit                          03280000
INITNOID DS    0H                                                       03290000
         MVC   W#LINE(19),=C' No jobid specified'                       03300000
         BAL   R14,PRT                 Print a line                     03310000
INITER   DS    0H                                                       03320000
         LA    R15,8                   Set error return code            03330000
INITXT   DS    0H                                                       03340000
         L     R14,W#INIT14            Get return address               03350000
         BR    R14                     Return to caller                 03360000
*********************************************************************** 03370000
*        Write Print Line                                             * 03380000
*********************************************************************** 03390000
PRT      DS    0H                                                       03400000
         ST    R14,W#PRTR14                                             03410000
         CP    W#LNCT,=P'+60'          End of page                      03420000
         BL    PRTCHK                  No, check if line fit in page    03430000
PRTHDRS  DS    0H                                                       03440000
         AP    W#PGCT,=P'+1'           Count pages                      03450000
         MVC   W#HD1PGC,=X'40202120'   Page count mask                  03460000
         ED    W#HD1PGC,W#PGCT         Edit page count                  03470000
         PUT   W#OTDCB,W#HD1           Print heading 1                  03480000
         ZAP   W#LNCT,=P'+1'           Init line count                  03490000
         MVI   W#LINE,C' '             Skip after heading               03500000
PRTCHK   DS    0H                                                       03510000
         CLI   W#LINE,C'+'             Overprint?                       03520000
         BE    PRTLINE                 Yes, don't count                 03530000
         CLI   W#LINE,C'1'             New line?                        03540000
         BE    PRTHDRS                 Yes, print header                03550000
         CLI   W#LINE,C' '             Write after advancing 1?         03560000
         BE    PRTLINE1                Yes, go check if fit             03570000
         CLI   W#LINE,C'0'             Write after advancing 2?         03580000
         BE    PRTLINE2                Yes, go check if fit             03590000
         CLI   W#LINE,C'-'             Write after advancing 3?         03600000
         BE    PRTLINE3                Yes, go check if fit             03610000
         B     PRTLINE                 Ignore any other ctl chars       03620000
PRTLINE1 DS    0H                                                       03630000
         AP    W#LNCT,=P'+1'           Add to line count                03640000
         B     PRTVFY                  Go see if it will fit            03650000
PRTLINE2 DS    0H                                                       03660000
         AP    W#LNCT,=P'+2'           Add to line count                03670000
         B     PRTVFY                  Go see if it will fit            03680000
PRTLINE3 DS    0H                                                       03690000
         AP    W#LNCT,=P'+3'           Add to line count                03700000
PRTVFY   DS    0H                                                       03710000
         CP    W#LNCT,=P'+60'          Overflow?                        03720000
         BH    PRTHDRS                 Yes, force header                03730000
PRTLINE  DS    0H                                                       03740000
         PUT   W#OTDCB,W#LINE          Print a line                     03750000
         MVI   W#LINE,C' '             Clear print line                 03760000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              03770000
         L     R14,W#PRTR14                                             03780000
         BR    R14                     Return to caller                 03790000
*********************************************************************** 03800000
*        Constants                                                    * 03810000
*********************************************************************** 03820000
PRMMVC   MVC   W#LINE+6(0),2(R9)       Executed parm move               03830000
         DROP  ,                                                        03840000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  03850000
*                                                                       03860000
         LTORG ,                                                        03870000
         DC    (((((*-SUBNEXT)/256)+1)*256)-(*-SUBNEXT))X'CC'           03880000
*********************************************************************** 03890000
*        Work Areas                                                   * 03900000
*********************************************************************** 03910000
W#       CSECT                                                          03920000
W#SA     DC    18A(0)                                                   03930000
W#JOBID  DC    CL8' '                                                   03940000
W#DWORD  DC    D'0'                                                     03950000
W#PRMBGN DC    A(0)                                                     03960000
W#INIT14 DC    A(0)                                                     03970000
W#PRTR14 DC    A(0)                                                     03980000
W#FLG    DC    X'00'                                                    03990000
W#FLGDBG EQU   X'80'                                                    04000000
W#FLGOMT EQU   X'40'                                                 02 04010002
W#SUBCT  DC    PL4'+0'                                                  04020000
W#INREC  DC    CL80' '                                                  04030000
W#LINE   DC    CL133' '                                                 04040000
W#CURDTE DC    A(0)                                                     04050000
W#JLWK1  DC    A(0)                                                     04060000
W#JLWK2  DC    P'+365'                                                  04070000
W#JLWK13 DC    P'+01'                                                   04080000
W#JLWK12 DC    P'+31'                                                   04090000
W#JLWK11 DC    P'+30'                                                   04100000
W#JLWK10 DC    P'+31'                                                   04110000
W#JLWK09 DC    P'+30'                                                   04120000
W#JLWK08 DC    P'+31'                                                   04130000
W#JLWK07 DC    P'+31'                                                   04140000
W#JLWK06 DC    P'+30'                                                   04150000
W#JLWK05 DC    P'+31'                                                   04160000
W#JLWK04 DC    P'+30'                                                   04170000
W#JLWK03 DC    P'+31'                                                   04180000
W#JLWK02 DC    P'+28'                                                   04190000
W#JLWK01 DC    P'+31'                                                   04200000
W#TMWRK4 DC    X'402021204B20204B20204B2020'                            04210000
W#LNCT   DC    PL2'+99'                                                 04220000
W#PGCT   DC    PL2'+0'                                                  04230000
W#HD1    DC    CL133'1'                                                 04240000
         ORG   W#HD1+1                                                  04250000
W#HD1DTE DC    C'            '                                          04260000
         DC    C' '                                                     04270000
W#HD1TOD DC    C'HH:MM:SS'                                              04280000
         ORG   W#HD1+66-(17/2)                                          04290000
         DC    C'Submit Controller'                                     04300000
         ORG   W#HD1+L'W#HD1-8                                          04310000
W#HD1PG  DC    C'Page'                                                  04320000
W#HD1PGC DC    C' 123'                                                  04330000
         DC    0D'0'                                                    04340000
*                                                                       04350000
W#INDCB  DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,                         X04360000
               RECFM=FB,LRECL=80,EODAD=FINDNFD                          04370003
*                                                                       04380000
         DC    0D'0'                                                    04390000
W#OTDCB  DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X04400000
               RECFM=FBA,LRECL=133                                      04410000
*                                                                       04420000
         DC    0D'0'                                                    04430000
W#SIDCB  DCB   DDNAME=SYSUT1,MACRF=GL,DSORG=PS,                        X04440000
               RECFM=FB,LRECL=80,EODAD=SUBEOF                           04450000
*                                                                       04460000
         DC    0D'0'                                                    04470000
W#SODCB  DCB   DDNAME=SYSUT2,MACRF=PM,DSORG=PS,                        X04480000
               RECFM=FB,LRECL=80                                        04490000
         DC    (((((*-W#)/256)+1)*256)-(*-W#))X'DD'                     04500000
W#LEN    EQU   *-W#                                                     04510000
R0       EQU   0                                                        04520000
R1       EQU   1                                                        04530000
R2       EQU   2                                                        04540000
R3       EQU   3                                                        04550000
R4       EQU   4                                                        04560000
R5       EQU   5                                                        04570000
R6       EQU   6                                                        04580000
R7       EQU   7                                                        04590000
R8       EQU   8                                                        04600000
R9       EQU   9                                                        04610000
R10      EQU   10                                                       04620000
R11      EQU   11                                                       04630000
R12      EQU   12                                                       04640000
R13      EQU   13                                                       04650000
R14      EQU   14                                                       04660000
R15      EQU   15                                                       04670000
         END                                                            04680000
