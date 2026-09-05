         MACRO ,                                                     31 00010034
&LBL     $TRC  ,                                                     31 00020034
&LBL     DS    0H                                                    31 00030034
         STM   R0,R15,W#DIAGRG         Save registers                31 00040034
         LA    R1,=CL8'&LBL'           Pass label                    31 00050034
         BAL   R14,DIAGTRC             Trace                         31 00060034
         LM    R0,R15,W#DIAGRG         Restore registers             31 00070034
         MEND  ,                                                     31 00080034
*********************************************************************** 00090000
*                                                                     * 00100000
* MODULE NAME                                                         * 00110000
*    COMPLMD                                                          * 00120000
*                                                                     * 00130000
* ATTRIBUTES                                                          * 00140000
*    NORENT                                                           * 00150000
*                                                                     * 00160000
* AUTHOR                                                              * 00170000
*    DAVE KREISS                                                      * 00180000
*                                                                     * 00190000
* FUNCTION                                                            * 00200000
*    COMPARES TWO LOAD MODULE CSECTS.  LOADLMD LOAD MODULE IS         * 00210000
*    USED TO LOAD BOTH CSECTS.  THEY ARE THEN COMPARED.               * 00220000
*                                                                     * 00230000
* JCL                                                                 * 00240000
*    //        EXEC PGM=COMPLMD,PARM='parameters'                     * 00250000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00260000
*    //SYSPRINT DD  SYSOUT=*                                          * 00270000
*    //PRINTDD  DD  SYSOUT=*                                          * 00280000
*    //OLDLIB   DD  DSN=load library,DISP=SHR                         * 00290000
*    //NEWLIB   DD  DSN=load library,DISP=SHR                         * 00300000
*    //DC       DD  DSN=PTF compare differences,DISP=SHR              * 00310018
*    //DIFIN    DD  DSN=difference table,DISP=SHR                     * 00320015
*    //DIFOUT   DD  DSN=additional difference table,DISP=SHR          * 00330018
*                                                                     * 00340000
* DD STATEMENTS                                                       * 00350000
*    STEPLIB       LOAD LIBRARY CONAINING THE MODULE LOADLMD.         * 00360000
*    SYSPRINT      COMPARE REPORT.                                    * 00370000
*    PRINTDD       DATA SET CONTAINING EITHER SUMMARY OR DETAIL       * 00380000
*                  INFORMATION.  SEE PARM=OPTION BELOW.               * 00390000
*                  THIS DD IS OPTIONAL.                               * 00400000
*    OLDLIB        DATA SET CONTAINING THE 'OLD' LOAD MODULE          * 00410000
*    NEWLIB        DATA SET CONTAINING THE 'NEW' LOAD MODULE          * 00420000
*    DC            OPTIONAL DATA SET CONTAINING ASSEMBLER DC          * 00430014
*                  STATEMENTS FOR ALL "NEW" MISMATCHES WHICH          * 00440014
*                  ARE ZERO.  THIS IS USED FOR MATCHING UP            * 00450014
*                  DS STATEMENTS WHICH HAVE RANDOM DATA DURING        * 00460018
*                  LOAD MODULE COMPARE.                               * 00470014
*    DIFIN         DIFFERENCE TABLE AS FOLLOWS:                       * 00480015
*                  SEQUENCE OF HEADER AND DIFFERENCES                 * 00490015
*                  HEADER                                             * 00500015
*                    CC1=>                                            * 00510015
*                    CC2-9=CSECT NAME                                 * 00520015
*                  DIFFERENCES                                        * 00530015
*                    CC1=CC6=OFFSET OF DIFFERENCE                     * 00540015
*                    CC70CC8=LENGTH OF DIFFERENCE                     * 00550015
*                  EXAMPLE:                                           * 00560015
*                    //DIFIN    DD  *                                 * 00570015
*                    >IEFBR14                                         * 00580015
*                    00000201                                         * 00590015
*                    >HASPACCT                                        * 00600015
*                    00015C04                                         * 00610015
*                    00016404                                         * 00620015
*    DIFOUT        OPTIONAL DATA SET CONTAINING ANY NEW DIFFERENCES   * 00630018
*                  WHICH CAN BE USED TO UPDATE THE DIFFERENCE TABLE   * 00640018
*                  USED IN ABOVE DIFIN FILE.                          * 00650018
*                                                                     * 00660000
* PARAMETERS                                                          * 00670000
*    ALL PARAMETERS ARE SEPERATED BY COMMAS.                          * 00680000
*    1ST PARAMETER LOAD MODULE NAME                                   * 00690000
*    2ND PARAMETER CSECT NAME                                         * 00700000
*    NEWLMD=       SPECIFIES NEW LOAD MODULE NAME.  THE DEFAULT       * 00710035
*                  IS THE SAME LOAD MODULE NAME AS IN 1ST PARM.       * 00720035
*    OPTION=       OPTION CAN BE DETAIL OR SUMMARY.                   * 00730000
*      DETAIL      GIVES DETAIL INFO ABOUT LOAD MODULE AND CSECT.     * 00740000
*                  THIS IS DEFAULT IF NO OPTION.                      * 00750000
*      SUMMARY     SUMMARY ONLY INFO ABOUT CSECT AND LOAD MODULE.     * 00760000
*    CLEARRLD=     CLEAR RELOCATABLE CONSTANTS OPTION                 * 00770002
*      YES         YES WILL CLEAR ALL RELOCATABLE CONSTANTS.          * 00780002
*                  USEFUL WHEN LOAD MODULES WITH MULTIPLE CSECTS      * 00790002
*                  CONTAIN CSECTS WHICH ARE DIFFERENT IN LENGTH.      * 00800002
*                  THIS IS DEFAULT IF CLEARRLD ISN'T SPECIFIED.       * 00810008
*      NO          NO WILL LEAVE RELOCATABLE CONSTANTS AS IS.         * 00820002
*    MAXERR=N      NUMBER OF ERRORS REPORTED BEFORE SUBSEQUENT        * 00830000
*                  ERRORS ARE NOT REPORTED.  DEFAULT IS 10.           * 00840000
*    DEBUG=        DEBUG CAN BE EITHER YES OR NO,  NO IS DEFAULT.     * 00850000
*      YES         PRODUCES SOME DEBUGGING INFO.                      * 00860000
*      NO          NO DEBUGGING INFO PRODUCED.                        * 00870000
*                  THIS IS DEFAULT IF NO DEBUG= SPECIFIED.            * 00880008
*    RC=5          CHANGE RC=4 TO 5 SO CAN SEE THIS AS MAX            * 00890029
*    LIST          LIST IGNORE CSECT DIFFERENCE TABLE (DIFIN).        * 00900029
*    OFFSET=       CSECT OFFSET. USED WHEN MULTIPLE CSECTS ARE        * 00910028
*                  ASSEMBLED IN A SOURCE MODULE.                      * 00920028
*                                                                     * 00930000
* SAMPLE JCL                                                          * 00940000
*    THIS SAMPLE COMPARES TWO VERSIONS OF THE CSECT AKJLKL01          * 00950000
*    IN AKJLKL01.                                                     * 00960000
*                                                                     * 00970000
*    //LOAD    EXEC PGM=LOADLMD,PARM=AKJLKL01                         * 00980000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00990000
*    //SYSPRINT DD  SYSOUT=*                                          * 01000000
*    //OLDLIB   DD  DSN=SYS1.CMDLIB,DISP=SHR                          * 01010000
*    //NEWLIB   DD  DSN=MVSSRC.BLD.CMDLIB,DISP=SHR                    * 01020000
*                                                                     * 01030000
*********************************************************************** 01040000
*                                                                     * 01050000
* CHANGE LOG:                                                         * 01060000
*   DATE     AAA VV.VV DESCRIPTION                                    * 01070000
* 06/06/2015 DSK 01.01 CREATED                                        * 01080000
* 07/10/2015 DSK 01.02 CLEAR RELOCATABLE CONSTANTS                    * 01090002
* 07/13/2015 DSK 01.03 ADD CHARACTER TO DIFFERENCES OUTPUT            * 01100003
* 07/14/2015 DSK 01.04 CHANGE FORMAT OF DIFFERENCES                   * 01110006
* 07/19/2015 DSK 01.05 FIX RETURN CODE                                * 01120005
* 07/21/2015 DSK 01.06 FIX TRANSLATION OF X'FA'-X'FF'                 * 01130007
* 08/04/2015 DSK 01.07 HANDLE DIFFERENT LENGTH DIFFERENCES            * 01140008
* 01/04/2016 DSK 01.08 REPORT LOADLMD REASON CODE IF FAILURE          * 01150009
*                      REPORT OLDLIB AND NEWLIB DATA SET NAMES        * 01160009
* 08/31/2016 DSK 01.09 Count differences that are x'00' in new        * 01170010
* 09/04/2016 DSK 01.10 Add DD DC for creating differences source      * 01180011
* 09/05/2016 DSK 01.11 Fix S0C7 when MAXERR reached                   * 01190012
* 09/24/2016 DSK 01.12 New longer than old character formatting       * 01200013
* 02/20/2017 DSK 01.13 Document DD statement DC                       * 01210014
* 03/01/2017 DSK 01.14 Add ignore table                               * 01220015
* 03/07/2017 DSK 01.15 Add PARM=LIST and increase DIFIN table to 5000 * 01230016
* 03/10/2017 DSK 01.16 Fix PARM= parsing                              * 01240017
* 03/21/2017 DSK 01.17 Add DIFOUT for any differences                 * 01250018
* 03/22/2017 DSK 01.18 Increase DIFIN table to 1500                   * 01260019
* 03/23/2017 DSK 01.19 Copy and merge existing DIFIN to DIFOUT        * 01270023
* 03/25/2017 DSK 01.20 Fix above                                      * 01280023
* 05/07/2017 DSK 01.21 OPTION=SUMMARY skips detailed difference       * 01290024
* 10/02/2017 DSK 01.22 Handle formatting 16 bytes different in row    * 01300025
* 03/03/2018 DSK 01.23 Skip message 'New zero diffs'                  * 01310025
* 05/29/2018 DSK 01.24 Show return code                               * 01320026
* 06/30/2018 DSK 01.25 Use RC=5 so highest is 5 if ASM has RC=4       * 01330027
* 02/13/2019 DSK 01.26 CSECT offset (PARM=OFFSET=)                    * 01340029
*                      Handle diff for extra CSECT bytes              * 01350029
* 04/14/2019 DSK 01.27 Fix unprintable translate table                * 01360030
* 08/06/2019 DSK 01.28 Merge contigious DIFIN generated records       * 01370032
* 12/18/2019 DSK 01.29 Format last DIFIN record                       * 01380032
* 12/20/2019 DSK 01.30 Add CSECT offset to report                     * 01390033
* 05/16/2020 DSK 01.31 Generate missing last DIFOUT record            * 01400034
* 10/22/2020 DSK 01.32 NEWLMD= parameter                              * 01410035
* 11/11/2020 DSK 01.33 Debug option to LOADLMD                        * 01420036
         LCLC   &VER                                                    01430000
&VER     SETC   '01.33'                                                 01440036
*                                                                     * 01450000
*********************************************************************** 01460000
*                                                                     * 01470000
*                                                                     * 01480000
*                                                                     * 01490000
*********************************************************************** 01500000
COMPLMD  CSECT                                                          01510000
         USING COMPLMD,R15                                              01520000
         B     BEGIN                   BYPASS PROGRAM ID                01530000
         DROP  R15                                                      01540000
         DC    AL1(L'PGMID)            PROGRAM ID LENGTH                01550000
PGMID    DC    C'COMPLMD - Version &VER &SYSDATE &SYSTIME'              01560012
BEGIN    DC    0H'+0'                                                   01570000
         STM   R14,R12,12(R13)         STORE REGS IN HIGH SAVE AREA     01580000
         LR    R11,R15                 INITIALIZE BASE REG           07 01590008
         LA    R12,2048(,R11)          INITIALIZE BASE REG           07 01600008
         LA    R12,2048(,R12)          INITIALIZE BASE REG           07 01610008
         USING COMPLMD,R11,R12                                       07 01620008
         LA    R14,SAVEAREA            ADDRESS SAVE AREA                01630000
         ST    R13,4(,R14)             STORE LOW SAVE POINTER           01640000
         ST    R14,8(,R13)             STORE HIGH SAVE POINTER          01650000
         LR    R13,R14                 INITIALIZE SAVE POINTER          01660000
         L     R10,0(,R1)              PARAMETERS ADDRESS            07 01670008
         OPEN  (SYSPRINT,(OUTPUT))     OPEN SYSPRINT                    01680000
         TM    SYSPRINT+48,16          OPEN OK                          01690000
         BZ    QUIT                    NO, ERROR                        01700000
         TIME  BIN                     GET CURRENT DATE AND TIME        01710000
         ST    R1,CURDATE              SAVE DATE                        01720000
         SRDL  R0,32                   GET DOUBLE WORD TIME             01730000
         D     R0,=F'+6000'            GET MINUTES                      01740000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     01750000
         SLR   R0,R0                   CLEAR                            01760000
         D     R0,=F'+60'              GET HOURS / MINS                 01770000
         MH    R0,=H'+10000'           GET MINUTES                      01780000
         AR    R15,R0                  ADD TO GET MM:SS.TH              01790000
         M     R0,=F'+1000000'         GET HOURS                        01800000
         AR    R1,R15                  GET HH:MM:SS.TH                  01810000
         CVD   R1,DWORD                GET TIME TO DECIMAL              01820000
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   01830000
         ED    TIMWRK4,DWORD+3         EDIT TIME                        01840000
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        01850000
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  01860000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    01870000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         01880000
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        01890000
         DP    DWORD,=P'+4'            DIVIDE BY 4                      01900000
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              01910000
         BNZ   JULCVT2                  NO                              01920000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    01930000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         01940000
JULCVT2  DS    0H                                                       01950000
         LA    R1,JULTBL1              POINT TO JANUARY                 01960000
         SLR   R2,R2                   SET COUNTER                      01970000
JULCVT4  DS    0H                                                       01980000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              01990000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  02000000
         BCTR  R1,0                    POINT TO NEXT MONTH              02010000
         BCTR  R1,0                    POINT TO NEXT MONTH              02020000
         LA    R2,3(,R2)               UP INDEX                         02030000
         B     JULCVT4                 LOOP                             02040000
JULCVT6  DS    0H                                                       02050000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                02060000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    02070000
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       02080000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     02090000
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         02100000
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   02110000
         LA    R1,HD1DATE+6            SET POINTER                      02120000
         BNE   JULCVT7                  NO                              02130000
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 02140000
         BCTR  R1,0                    DROP POINTER                     02150000
JULCVT7  DS    0H                                                       02160000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  02170000
         TM    CURDATE,1               YEAR 2000?                       02180000
         BNO   JULCVT8                  NO, CONTINUE                    02190000
         MVC   2(2,R1),=C'20'          Y2K                              02200000
JULCVT8  DS    0H                                                       02210000
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      02220000
         MVC   4(2,R1),DWORD           GET YEAR                         02230000
         MVC   LINE+1(8),=C'Version='                                20 02240023
         MVC   LINE+9(L'PGMID),PGMID                                 20 02250023
         BAL   R14,PRT                 PRINT A LINE                  20 02260023
****************************************************************        02270000
*                                                              *        02280000
*        PROCESS THE PARM CONTAINING MODULE NAME AND CSECT     *        02290000
*                                                              *        02300000
****************************************************************        02310000
         MVC   LINE+1(5),=C'PARM='     MOVE PARAMETER INFO LITERAL      02320000
         CLI   1(R10),0                ANY PARAMETER?                07 02330008
         BE    PRPRINT                 NO, SKIP MOVE                    02340000
         LH    R1,0(,R10)              GET PARMETER LENGTH           07 02350008
         BCTR  R1,0                    MAKE MACHINE LENGTH              02360000
         EX    R1,PRMVC                MOVE PARM TO PRINT LINE          02370000
         B     PRPRINT                 SKIP EXECUTED MVC                02380000
PRMVC    MVC   LINE+6(0),2(R10)        EXECUTED PARM MOVE            07 02390008
PRPRINT  DS    0H                                                       02400000
         BAL   R14,PRT                 PRINT A LINE                     02410000
         LA    R1,2(,R10)              GET PARM FIELD ADDRESS        07 02420008
         ST    R1,PRMSTRT              SAVE PARAMETER START             02430000
         SR    R2,R2                   CLEAR LENGTH                     02440000
         ICM   R2,3,0(R10)             PICK UP PARM LENGTH           07 02450008
         BZ    PREND                   NO PARM INFO ENTERED             02460000
PRMSCN   DS    0H                                                       02470000
         LA    R0,8                    MAX LENGTH OF MEMBER NAME        02480000
         LA    R15,MBRNAME             MEMBER NAME FIELD                02490000
         MVC   MBRNAME,=CL8' '         CLEAR MEMBER NAME                02500000
PRMEMOV  DS    0H                                                       02510000
         CLI   0(R1),C','              GOT A COMMA                   16 02520017
         BE    PRCSNAM                 YES                           16 02530017
         LTR   R0,R0                   MEMBER NAME FULL              16 02540017
         BZ    PRERROR                 YES, ERROR                    16 02550017
         MVC   0(1,R15),0(R1)          PARM= BYTE TO MEMBER NAME     16 02560017
         LA    R1,1(,R1)               TO NEXT PARM= BYTE            16 02570017
         BCTR  R2,0                    SUBTRACT 1 FROM LENGTH           02580000
         LA    R15,1(,R15)             TO NEXT MEMBER NAME BYTE      16 02590017
         BCTR  R0,0                    SUBTRACT 1 FROM LENGTH           02600000
         LTR   R2,R2                   END OF PARM= DATA             16 02610017
         BE    PREND                   YES                              02620000
         B     PRMEMOV                 CONTINUE WITH MEMBER NAME     16 02630017
PRCSNAM  DS    0H                                                    16 02640017
         LA    R0,8                    CSECT NAME MAX LENGTH            02650000
         LA    R15,CSNAME              CSECT NAME FIELD                 02660000
         MVC   CSNAME,=CL8' '          CLEAR CSECT NAME                 02670000
         LA    R1,1(,R1)               STEP PAST COMMA                  02680000
         BCT   R2,PRCSMOV              HANDLE CSECT NAME             16 02690017
         B     PREND                   END OF SCAN                      02700000
PRCSMOV  DS    0H                                                    16 02710017
         CLI   0(R1),C','              GOT A COMMA                   16 02720017
         BE    PRMORPRM                YES                           16 02730017
         LTR   R0,R0                   CSECT NAME FULL               16 02740017
         BZ    PRERROR                 YES, ERROR                    16 02750017
         MVC   0(1,R15),0(R1)          PARM= BYTE TO CSECT NAME      16 02760017
         LA    R1,1(,R1)               TO NEXT PARM= BYTE            16 02770017
         BCTR  R2,0                    DEDUCT 1 FROM PARM= LENGTH    16 02780017
         LA    R15,1(,R15)             TO NEXT CSECT NAME BYTE       16 02790017
         BCTR  R0,0                    DEDUCT 1 FROM CSECT NAME LENG 16 02800017
         LTR   R2,R2                   ANY PARM= BYTES LEFT          16 02810017
         BZ    PREND                   NO                               02820000
         B     PRCSMOV                 CONTINUE WITH CSECT NAME      16 02830017
PRMORPRM DS    0H                                                       02840000
         LTR   R2,R2                   ANY MORE PARM LEFT TO PARSE      02850000
         BZ    PREND                   NO, WE ARE DONE WITH PARM        02860000
         CLI   0(R1),C','              SEPERATOR                        02870000
         BNE   PRKEYWD                 NO, CHECK FOR A KEYWORD          02880000
         LA    R1,1(,R1)               SKIP COMMA                       02890000
         BCTR  R2,0                    INCLUDE COMMA PARSED             02900000
         B     PRMORPRM                LOOK FOR MORE PARM KEYWORDS      02910000
PRKEYWD  DS    0H                                                       02920000
         CH    R2,=H'+4'               LONG ENOUGH?                  15 02930016
         BL    PRERROR                 No, error                     15 02940016
         CLC   =C'LIST',0(R1)          LIST?                         16 02950017
         BE    PRLST                   Yes, handle it                15 02960017
         CLC   =C'RC=5',0(R1)          Unequal RC=5?                 25 02970027
         BE    PRRC5                   Yes, handle it                25 02980027
         CH    R2,=H'+6'               LENGTH LEFT LONG ENOUGH FOR PARM 02990000
         BL    PRERROR                 NO, PARAMETER ERROR              03000000
         CLC   =C'DEBUG=',0(R1)        PARM DEBUG KEYWORD               03010000
         BE    PRDBG                   YES, HANDLE DEBUG VALUE          03020000
         CH    R2,=H'+8'               LENGTH LEFT LONG ENOUGH FOR PARM 03030000
         BL    PRERROR                 NO, PARAMETER ERROR              03040000
         CLC   =C'OPTION=',0(R1)       PARM OPTION KEYWORD              03050000
         BE    PROPT                   YES, HANDLE OPTION KEYWORD       03060000
         CLC   =C'MAXERR=',0(R1)       PARM MAXERR KEYWORD              03070000
         BE    PRMAX                   YES, HANDLE MAXERR KEYWORD       03080000
         CLC   =C'OFFSET=',0(R1)       OFFSET=?                      26 03090028
         BE    PROFF                   YES, HANDLE IT                26 03100028
         CLC   =C'NEWLMD=',0(R1)       NEWLMD=?                      32 03110035
         BE    PRNLM                   YES, HANDLE IT                32 03120035
         CH    R2,=H'+10'              LEN LEFT LONG ENOUGH FOR PARM 02 03130002
         BL    PRERROR                 NO, PARAMETER ERROR           02 03140002
         CLC   =C'CLEARRLD=',0(R1)     PARM CLEARRLD KEYWORD         02 03150002
         BE    PRCLR                   YES, CSECT NOT SPECIFIED      02 03160002
         B     PRERROR                 UNKNOWN KEYWORD, PARAMETER ERROR 03170000
PROPT    DS    0H                                                       03180000
         LA    R1,7(,R1)               SKIP OPTION=                     03190000
         SH    R2,=H'+7'               INCLUDE IN LENGTH PARSED         03200000
         BZ    PROPTDT1                NULL OPTION= SET DETAIL          03210000
         CLI   0(R1),C','              IS OPTION= NULL                  03220000
         BE    PROPTDT1                YES, SET DETAIL                  03230000
         CH    R2,=H'+6'               ENOUGH LEFT FOR DETAIL           03240000
         BL    PRERROR                 NO, PARAMETER ERROR              03250000
         CLC   =C'DETAIL',0(R1)        KEYWORD VALUE DETAIL             03260000
         BE    PROPTDTL                YES, SET DETAIL                  03270000
         CH    R2,=H'+7'               ENOUGH LEFT FOR SUMMARY          03280000
         BL    PRERROR                 NO, PARAMETER ERROR              03290000
         CLC   =C'SUMMARY',0(R1)       KEYWORD VALUE SUMMARY            03300000
         BE    PROPTSUM                YES, SET SUMMARY                 03310000
         B     PRERROR                 UNKNOWN KEYWORD VALUE, PARM ERR  03320000
PROPTSUM DS    0H                                                       03330000
         LA    R1,7(,R1)               SKIP DETAIL                      03340000
         SH    R2,=H'+7'               INCLUDE IN LENGTH PARSED         03350000
         OI    PRMOPT,PRMOPTSU         SET SUMMARY FLAG                 03360000
         B     PRMORPRM                LOOK FOR MORE KEYWORDS           03370000
PROPTDTL DS    0H                                                       03380000
         LA    R1,6(,R1)               SKIP SUMMARY                     03390000
         SH    R2,=H'+6'               INCLUDE IN LENGTH PARSED         03400000
PROPTDT1 DS    0H                                                       03410000
         NI    PRMOPT,255-PRMOPTSU     CLEAR SUMMARY FLAG               03420000
         B     PRMORPRM                LOOK FOR MORE KEYWORDS           03430000
PRLST    DS    0H                                                    15 03440016
         LA    R1,4(,R1)               SKIP LIST                     15 03450016
         SH    R2,=H'+4'               INCLUDE IN LENGTH PARSED      15 03460016
         OI    PRMOPT,PRMOPTLS         SET LIST                      15 03470016
         B     PRMORPRM                GO HANDLE MORE PARAMETERS     15 03480016
PRRC5    DS    0H                                                    25 03490027
         LA    R1,4(,R1)               Skip RC=5                     25 03500027
         SH    R2,=H'+4'               Include in length parsed      25 03510027
         OI    PRMOPT,PRMOPTR5         Set RC=5                      25 03520027
         B     PRMORPRM                Go handle more parameters     25 03530027
PRDBG    DS    0H                                                       03540000
         LA    R1,6(,R1)               SKIP DEBUG=                      03550000
         SH    R2,=H'+6'               INCLUDE IN LENGTH PARSED         03560000
         BZ    PRDBGNO1                NULL DEBUG= SET NO               03570000
         CLI   0(R1),C','              IS DEBUG= NULL                   03580000
         BE    PRDBGNO1                YES, SET NO                      03590000
         CH    R2,=H'+2'               ENOUGH LEFT FOR NO               03600000
         BL    PRERROR                 NO, PARAMETER ERROR              03610000
         CLC   =C'NO',0(R1)            KEYWORD VALUE NO                 03620000
         BE    PRDBGNO                 YES, SET NO                      03630000
         CH    R2,=H'+3'               ENOUGH LEFT FOR YES              03640000
         BL    PRERROR                 NO, PARAMETER ERROR              03650000
         CLC   =C'YES',0(R1)           KEYWORD VALUE YES                03660000
         BE    PRDBGYES                YES, SET YES                     03670000
         B     PRERROR                 UNKNOWN KEYWORD VALUE, PARM ERR  03680000
PRDBGNO  DS    0H                                                       03690000
         LA    R1,2(,R1)               SKIP NO                          03700000
         SH    R2,=H'+2'               INCLUDE IN LENGTH PARSED         03710000
PRDBGNO1 DS    0H                                                       03720000
         NI    PRMOPT,255-PRMOPTDB     RESET DEBUG FLAG                 03730000
         B     PRMORPRM                GO HANDLE MORE PARAMETERS        03740000
PRDBGYES DS    0H                                                       03750000
         LA    R1,3(,R1)               SKIP NO                          03760000
         SH    R2,=H'+3'               INCLUDE IN LENGTH PARSED         03770000
         OI    PRMOPT,PRMOPTDB         SET DEBUG                        03780000
         B     PRMORPRM                GO HANDLE MORE PARAMETERS        03790000
PRMAX    DS    0H                                                       03800000
         LA    R1,7(,R1)               SKIP MAXERR=                     03810000
         SH    R2,=H'+7'               INCLUDE IN LENGTH PARSED         03820000
         BZ    PRERROR                 IF NO MORE PARM ERROR            03830000
         SR    R0,R0                   ZERO MAX ERRORS                  03840000
PRMAX01  DS    0H                                                       03850000
         CLI   0(R1),C','              END OF MAX ERRORS                03860000
         BE    PRMAX02                 YES, CHECK VALUE                 03870000
         CLI   0(R1),C'0'              NUMERIC                          03880000
         BL    PRERROR                 NO, PARM ERROR                   03890000
         CLI   0(R1),C'9'              NUMERIC                          03900000
         BH    PRERROR                 NO, PARM ERROR                   03910000
         IC    R14,0(,R1)              GET DIGIT                        03920000
         N     R14,=A(15)              CLEAR ALL BUT NUMBER             03930000
         MH    R0,=H'+10'              SHIFT PREVIOUS DIGIT 1 PLACE     03940000
         AR    R0,R14                  ADD IN CURRENT DIGIT             03950000
         C     R0,=A(9999999)          EXCEED MAXIMIM                   03960000
         BH    PRERROR                 YES, ERROR                       03970000
         LA    R1,1(,R1)               SKIP DIGIT                       03980000
         SH    R2,=H'+1'               INCLUDE IN LENGTH PARSED         03990000
         BNZ   PRMAX01                 IF MORE PARM CONTINUE            04000000
PRMAX02  DS    0H                                                       04010000
         LTR   R0,R0                   ZERO MAX ERROR                   04020000
         BZ    PRERROR                 YES, PARAM ERROR                 04030000
         ST    R0,MAXRPTER             SAVE NEW MAX ERRORS              04040000
         B     PRMORPRM                GO HANDLE MORE PARAMETERS        04050000
PRCLR    DS    0H                                                    02 04060002
         LA    R1,9(,R1)               SKIP CLEARRLD=                02 04070002
         SH    R2,=H'+9'               INCLUDE IN LENGTH PARSED      02 04080002
         BZ    PRCLRNO1                NULL CLEARRLD= SET NO         02 04090002
         CLI   0(R1),C','              IS CLEARRLD= NULL             02 04100002
         BE    PRCLRNO1                YES, SET NO                   02 04110002
         CH    R2,=H'+2'               ENOUGH LEFT FOR NO            02 04120002
         BL    PRERROR                 NO, PARAMETER ERROR           02 04130002
         CLC   =C'NO',0(R1)            KEYWORD VALUE NO              02 04140002
         BE    PRCLRNO                 YES, SET DETAIL               02 04150002
         CH    R2,=H'+3'               ENOUGH LEFT FOR NO            02 04160002
         BL    PRERROR                 NO, PARAMETER ERROR           02 04170002
         CLC   =C'YES',0(R1)           KEYWORD VALUE YES             02 04180002
         BE    PRCLRYES                YES, SET YES                  02 04190002
         B     PRERROR                 UNKNOWN KEYWORD VALUE, ERROR  02 04200002
PRCLRYES DS    0H                                                    02 04210002
         LA    R1,3(,R1)               SKIP YES                      02 04220002
         SH    R2,=H'+3'               INCLUDE IN LENGTH PARSED      02 04230002
         OI    PRMOPT,PRMOPTZR         SET ZERO RELOCATABLE ADCONS   02 04240002
         B     PRMORPRM                LOOK FOR MORE KEYWORDS        02 04250002
PRCLRNO  DS    0H                                                    02 04260002
         LA    R1,2(,R1)               SKIP NO                       02 04270002
         SH    R2,=H'+2'               INCLUDE IN LENGTH PARSED      02 04280002
PRCLRNO1 DS    0H                                                    02 04290002
         NI    PRMOPT,255-PRMOPTZR     RESET CLEAR OPTION            02 04300002
         B     PRMORPRM                LOOK FOR MORE KEYWORDS        02 04310002
PROFF    DS    0H                                                    26 04320028
         LA    R1,7(,R1)                                             26 04330028
         SH    R2,=H'7'                                              26 04340028
         SR    R14,R14                                               26 04350028
PROFF1   DS    0H                                                    26 04360028
         CLI   0(R1),C','                                            26 04370028
         BE    PROFF4                                                26 04380028
         IC    R0,0(,R1)                                             26 04390028
         N     R0,=A(X'F')                                           26 04400028
         CLI   0(R1),C'A'                                            26 04410028
         BL    PRERROR                                               26 04420028
         CLI   0(R1),C'F'                                            26 04430028
         BNH   PROFF2                                                26 04440028
         CLI   0(R1),C'0'                                            26 04450028
         BL    PRERROR                                               26 04460028
         CLI   0(R1),C'9'                                            26 04470028
         BH    PRERROR                                               26 04480028
         B     PROFF3                                                26 04490028
PROFF2   DS    0H                                                    26 04500028
         AH    R0,=H'+9'                                             26 04510028
PROFF3   DS    0H                                                    26 04520028
         SLL   R14,4                                                 26 04530028
         AR    R14,R0                                                26 04540028
         CL    R14,=A(X'00FFFFFF')                                   26 04550028
         BH    PRERROR                                               26 04560028
         LA    R1,1(,R1)                                             26 04570028
         SH    R2,=H'1'                                              26 04580028
         BNZ   PROFF1                                                26 04590028
PROFF4   DS    0H                                                    26 04600028
         ST    R14,CSOFF                                             26 04610028
         B     PRMORPRM                LOOK FOR MORE KEYWORDS        26 04620028
*        NEWLMD=member of new loadlib                                32 04630035
PRNLM    DS    0H                                                    32 04640035
         LA    R1,7(,R1)               Skip NEWLMD=                  32 04650035
         SH    R2,=H'+7'               Imclide in length parsed      32 04660035
         BNP   PRERROR                 Missing member name           32 04670035
         LA    R14,NEWMBR              New load library member       32 04680035
         MVI   NEWMBR,C' '             Clear new member name         32 04690035
         MVC   NEWMBR+1(L'NEWMBR-1),NEWMBR                           32 04700035
         LA    R0,L'NEWMBR             Length of new member name     32 04710035
PRNLM010 DS    0H                                                    32 04720035
         CLI   0(R1),C' '              A blank?                      32 04730035
         BE    PRERROR                 Yes, error                    32 04740035
         MVC   0(1,R14),0(R1)          Copy new load module name     32 04750035
         LA    R1,1(,R1)               Next parm character           32 04760035
         LA    R14,1(,R14)             Next new member               32 04770035
         SH    R2,=H'+1'               Decrement parm length left    32 04780035
         BZ    PRNLM020                End of parm                   32 04790035
         CLI   0(R1),C','              End of member name            32 04800035
         BE    PRNLM020                Yes                           32 04810035
         BCT   R0,PRNLM010             Loop through member name      32 04820035
PRNLM020 DS    0H                                                    32 04830035
         B     PRMORPRM                Look for more keywords        32 04840035
PRERROR  DS    0H                                                       04850000
         S     R1,PRMSTRT              LESS START                       04860000
         LA    R1,LINE+6(R1)           SET LOCATION OF ERROR            04870000
         MVI   0(R1),C'*'              MARK WHERE ERROR IS              04880000
         BAL   R14,PRT                 PRINT A LINE                     04890000
         MVC   LINE+1(18),=C'Parameters invalid'                        04900000
         BAL   R14,PRT                 PRINT A LINE                     04910000
         B     QUIT                    EXIT WITH ERROR RETURN CODE      04920000
PRNOMBR  DS    0H                                                       04930000
         MVC   LINE+1(19),=C'Member not specified'                      04940000
         BAL   R14,PRT                 PRINT A LINE                     04950000
         B     QUIT                    EXIT WITH ERROR RETURN CODE      04960000
PREND    DS    0H                                                       04970000
         CLI   MBRNAME,C' '            ANY MEMBER NAME FOUND            04980000
         BE    PRNOMBR                 NO, ERROR                        04990000
         CLI   CSNAME,C' '             CSECT NAME SPECIFIED             05000000
         BNE   PRCSSET                 YES, CONTINUE                    05010000
         MVC   CSNAME,MBRNAME          CSECT NAME = LOAD MODULE NAME    05020000
PRCSSET  DS    0H                                                       05030000
* PRINT OPTIONS SELECTED                                                05040000
         MVC   LINE+1(5),=C'LMOD='     *                             15 05050016
         MVC   LINE+6(8),MBRNAME        *                            15 05060016
         MVC   LINE+15(6),=C'CSECT='    *                            15 05070016
         MVC   LINE+21(8),CSNAME        *                            15 05080016
         LA    R1,LINE+30               *                            32 05090035
         CLI   NEWMBR,C' '              *                            32 05100035
         BE    PRPRTOPT                 *                            32 05110035
         MVC   0(9,R1),=C'NEW LMOD='    *                            32 05120035
         MVC   9(8,R1),NEWMBR           *                            32 05130035
         LA    R1,18(,R1)               *                            32 05140035
PRPRTOPT DS    0H                       *                            32 05150035
         MVC   0(7,R1),=C'OPTION='      *                            32 05160035
         LA    R1,7(,R1)                *                            32 05170035
         TM    PRMOPT,PRMOPTSU          *                               05180000
         BNO   PRPRTDTL                 *                               05190000
         MVC   0(7,R1),=C'SUMMARY'      *                            32 05200035
         LA    R1,8(,R1)                *                            32 05210035
         B     PRPRTZR                  *                            02 05220002
PRPRTDTL DS    0H                       *                               05230000
         MVC   0(6,R1),=C'DETAIL'       *                            32 05240035
         LA    R1,7(,R1)                *                            32 05250035
PRPRTZR  DS    0H                       *                            02 05260002
         MVC   0(9,R1),=C'CLEARRLD='    *                            32 05270035
         LA    R1,9(,R1)                *                            32 05280035
         TM    PRMOPT,PRMOPTZR          *                            02 05290002
         BNO   PRPRTZRN                 *                            02 05300002
         MVC   0(3,R1),=C'YES'          *                            32 05310035
         LA    R1,4(,R1)                *                            32 05320035
         B     PRPRTMAX                 *                            02 05330002
PRPRTZRN DS    0H                       *                            15 05340016
         MVC   0(3,R1),=C'NO'           *                            32 05350035
         LA    R1,3(,R1)                *                            32 05360035
PRPRTMAX DS    0H                        * FORMAT OPTIONS            15 05370016
         MVC   0(7,R1),=C'MAXERR='      *                            32 05380035
         LA    R1,7(,R1)                *                            32 05390035
         L     R0,MAXRPTER              *                               05400000
         CVD   R0,DWORD                 *                            15 05410016
         OI    DWORD+7,15               *                               05420000
         UNPK  0(7,R1),DWORD+4(4)       *                            32 05430035
         LR    R15,R1                   *                            32 05440035
         LA    R1,8(,R1)                *                            32 05450035
         LA    R0,8                     *                            32 05460035
PRPRTER1 DS    0H                       *                               05470000
         CLI   0(R15),C'0'              *                            32 05480035
         BNE   PRPRTER2                 *                               05490000
         MVC   0(8,R15),1(R15)          *                            32 05500035
         BCTR  R1,0                     *                            32 05510035
         BCT   R0,PRPRTER1              *                            32 05520035
PRPRTER2 DS    0H                       *                               05530000
         MVC   0(7,R1),=C'OFFSET='      *                            26 05540028
         UNPK  7(7,R1),CSOFF+1(4)       *                            26 05550028
         TR    7(7,R1),HEXTBL-240       *                            26 05560028
         MVI   13(R1),C' '              *                            26 05570028
         LA    R1,14(,R1)               *                            26 05580028
         TM    PRMOPT,PRMOPTDB          *                               05590000
         BNO   PRPRTLST                 *                            15 05600016
         MVC   0(9,R1),=C'DEBUG=YES'    *                               05610000
         LA    R1,10(,R1)               *                            15 05620016
PRPRTLST DS    0H                       *                            15 05630016
         TM    PRMOPT,PRMOPTLS          *                            15 05640016
         BZ    PRPRTPRM                 *                            15 05650016
         MVC   0(4,R1),=C'LIST'         *                            15 05660016
         LA    R1,5(,R1)                *                            15 05670016
PRPRTPRM DS    0H                      *                                05680000
         BAL   R14,PRT                 PRINT A LINE                     05690000
* Report OLDLIB and NEWLIB data set names                            08 05700009
         RDJFCB (OLDLIB)               READ OLDLIB JFCB              08 05710009
         LTR   R15,R15                 SUCCESSFUL?                   08 05720009
         BZ    RPTDDOLD                YES, CONTINUE                 08 05730009
         MVC   LINE+1(17),=C'OLDLIB DD missing'                      08 05740009
         BAL   R14,PRT                 PRINT A LINE                  08 05750009
         LA    R2,8                    RETURN CODE IS 8              08 05760009
         B     EXIT                    EXIT                          08 05770009
RPTDDOLD DS    0H                                                    08 05780009
         MVC   LINE+1(8),=C'Old DSN='  SETUP PRINT                   08 05790009
         LA    R1,LIBJFCB              ADDRESS JFCB                  08 05800009
         USING JFCB,R1                                               08 05810009
         MVC   LINE+9(44),JFCBDSNM     OLDLIB DATASET NAME           08 05820009
         DROP  R1                                                    08 05830009
         BAL   R14,PRT                 PRINT A LINE                  08 05840009
         RDJFCB (NEWLIB)               READ OLDLIB JFCB              08 05850009
         LTR   R15,R15                 SUCCESSFUL?                   08 05860009
         BZ    RPTDDNEW                YES, CONTINUE                 08 05870009
         MVC   LINE+1(17),=C'NEWLIB DD missing'                      08 05880009
         BAL   R14,PRT                 PRINT A LINE                  08 05890009
         LA    R2,8                    RETURN CODE IS 8              08 05900009
         B     EXIT                    EXIT                          08 05910009
RPTDDNEW DS    0H                                                    08 05920009
         MVC   LINE+1(8),=C'New DSN='  SETUP PRINT                   08 05930009
         LA    R1,LIBJFCB              ADDRESS JFCB                  08 05940009
         USING JFCB,R1                                               08 05950009
         MVC   LINE+9(44),JFCBDSNM     NEWLIB DATASET NAME           08 05960009
         DROP  R1                                                    08 05970009
         BAL   R14,PRT                 PRINT A LINE                  08 05980009
*                                                                    08 05990009
         LOAD  EPLOC==CL8'LOADLMD'     LOAD MODULE LOADER               06000000
         ST    R0,LOADLMD              SAVE IT'S EPA                    06010000
* Handle difference table if present                                 14 06020015
         DEVTYPE =CL8'DIFIN',DWORD     Detect if DFINN DD present    14 06030015
         LTR   R15,R15                 Is DIFIN DD present?          14 06040015
         BNZ   DFINEND                 NO, SKIP OPEN                 14 06050015
         OPEN  (DIFIN,(INPUT))         OPEN DIFIN DCB                14 06060015
         LA    R2,DIFTBL               DIFFERENCE TABLE START        14 06070015
         USING DIFENT,R2                                             29 06080032
         TM    PRMOPT,PRMOPTLS         LIST REQUESTED?               15 06090016
         BZ    DFINRDHD                No                            15 06100016
         MVC   LINE+1(16),=C'Difference Table'                       14 06110015
         BAL   R14,PRT                 PRINT A LINE                  14 06120015
DFINRDHD DS    0H                                                    14 06130015
         GET   DIFIN                   READ DIF TABLE                14 06140015
         CLI   0(R1),C'>'              HEADER                        14 06150015
         BNE   DFINRDHD                NO, READ ANOTHER DIF          14 06160015
         CLC   CSNAME,1(R1)            OUR CSECT                     14 06170015
         BNE   DFINRDHD                NO, READ ANOTHER DIF          14 06180015
         TM    PRMOPT,PRMOPTLS         LIST REQUESTED?               15 06190016
         BZ    DFINRD                  No                            15 06200016
         MVC   LINE+1(80),0(R1)        PRINT HEADER                  14 06210015
         BAL   R14,PRT                 PRINT A LINE                  14 06220015
DFINRD   DS    0H                                                    14 06230015
         GET   DIFIN                   READ DIF TABLE                14 06240015
         CLI   0(R1),C'>'              ANOTHER HEADER                14 06250015
         BE    DFINRDED                YES, DONE                     14 06260015
         LR    R3,R1                   SAVE RECORD ADDRESS           14 06270015
         TM    PRMOPT,PRMOPTLS         LIST REQUESTED?               15 06280016
         BZ    DFINRDS1                No                            15 06290016
         MVC   LINE+1(80),0(R3)        MOVE DIF TO PRINT             14 06300015
         BAL   R14,PRT                 PRINT A LINE                  14 06310015
DFINRDS1 DS    0H                                                    15 06320016
         LR    R1,R3                   RECORD ADDRESS                14 06330015
         C     R2,=A(DIFTBLND)         TABLE OVERFLOWED              14 06340015
         BNL   DFINER1                 YES, ERROR                    14 06350015
         LA    R14,8                   LETS SCAN 8 HEX CHARACTERS    14 06360015
DFINRDHL DS    0H                                                    14 06370015
         IC    R0,0(,R1)               GET A DIGIT                   14 06380015
         N     R0,=A(15)               CLEAR OFF ZONE                14 06390015
         CLI   0(R1),C'A'              IS IT A HEX DIGIT             14 06400015
         BL    DFINER2                 NO, ERROR                     14 06410015
         CLI   0(R1),C'F'              IS IT A HEX DIGIT             14 06420015
         BH    DFINRDHN                NO, MAY BE NUMBER             14 06430015
         AH    R0,=H'+9'               ADD IN A-F OFFSET             14 06440015
         B     DFINRDHZ                GO HANDLE CONVERTED DIGIT     14 06450015
DFINRDHN DS    0H                                                    14 06460015
         CLI   0(R1),C'0'              IS IT A NUMBER                14 06470015
         BL    DFINER2                 NO, ERROR                     14 06480015
DFINRDHZ DS    0H                                                    14 06490015
         SLL   R15,4                   SHIFT LAST DIGIT              14 06500015
         AR    R15,R0                  ADD CURRENT DIGIT TO TOTAL    14 06510015
         LA    R1,1(,R1)               NEXT DIGIT                    14 06520015
         BCT   R14,DFINRDHL            LOOP THROUGH ALL DIGITS       14 06530015
         LR    R0,R15                  GET DIFF OFFSET+LENGTH        14 06540015
         SRL   R15,8                   SHIFT OUT LENGTH              14 06550015
         N     R0,=A(X'FF')            CLEAR OFFSET                  14 06560015
         BZ    DFINER2                 IF LENGTH ZERO ERROR          14 06570015
         BCTR  R0,0                    ZERO BASED FOR END            14 06580015
         AR    R0,R15                  GET END OFFSET                14 06590015
         STM   R15,R0,DIFENTST         SAVE START/END OFFSETS        29 06600032
         LA    R2,L'DIFENT(,R2)        NEXT DIFFERENCE ENTRY         29 06610032
         B     DFINRD                  READ ANOTHER DIF              14 06620015
         DROP  R2                                                    29 06630032
DFINER1  DS    0H                                                    14 06640015
         MVC   LINE+1(25),=C'Difference Table Overflow'              14 06650015
         B     DFINER                  PRINT ERROR                   14 06660015
DFINER2  DS    0H                                                    14 06670015
         LR    R2,R1                   SAVE ERROR POSITION           15 06680016
         TM    PRMOPT,PRMOPTLS         LIST REQUESTED?               15 06690016
         BO    DFINERS1                Yes                           15 06700016
         MVC   LINE+1(80),0(R3)        MOVE DIF TO PRINT             15 06710016
         BAL   R14,PRT                 PRINT A LINE                  15 06720016
DFINERS1 DS    0H                                                    15 06730016
         MVC   LINE+1(25),=C'Difference Table Error at'              14 06740015
         MVC   LINE+27(8),0(R2)        GIVE A LITTLE HINT OF ERROR   15 06750016
DFINER   DS    0H                                                    14 06760015
         BAL   R14,PRT                 PRINT A LINE                  14 06770015
         LA    R2,8                    RETURN CODE IS 8              14 06780015
         B     EXIT                    EXIT                          14 06790015
DFINRDED DS    0H                                                    14 06800015
         ST    R2,DIFTBLST             SAVE LAST ENTRY +1            14 06810015
         TM    PRMOPT,PRMOPTLS         LIST REQUESTED?               15 06820016
         BZ    DFINCL                  No                            15 06830016
         MVC   LINE+1(20),=C'Difference Table End'                   14 06840015
         BAL   R14,PRT                 PRINT A LINE                  14 06850015
DFINCL   DS    0H                                                    15 06860016
         CLOSE DIFIN                   CLOSE DIF FILE                14 06870015
DFINEND  DS    0H                                                    14 06880015
*                                                                    14 06890015
         DEVTYPE =CL8'DC',DWORD        Detect if DC DD present       10 06900011
         LTR   R15,R15                 Is DC DD present?             10 06910011
         BNZ   DCNOOPN                 No, skip OPEN                 10 06920011
         OI    FLAG,FLAGDC             Set DC DD present             10 06930011
         OPEN  (DCDCB,(OUTPUT))        OPEN DC DCB                   10 06940011
DCNOOPN  DS    0H                                                    10 06950011
*                                                                    17 06960018
         DEVTYPE =CL8'DIFOUT',DWORD    Detect if DIFOUT DD present   17 06970018
         LTR   R15,R15                 Is DIFOUT present?            17 06980018
         BNZ   DIFOUTNO                No, skip OPEN                 17 06990018
         OI    FLAG,FLAGDIF            Set DIFOUT DD present         17 07000018
         OPEN  (DIFOUT,(OUTPUT))       OPEN DIFOUT DCB               17 07010018
DIFOUTNO DS    0H                                                    17 07020018
PROC     DS    0H                                                       07030000
* FETCH ORIGINAL LOAD MODULE CSECT                                      07040000
         LA    R1,LODPRM                                             02 07050002
         MVI   LODPRM,C' '             CLEAR LOADLMD PARAMETERS         07060000
         MVC   LODPRM+1(L'LODPRM-1),LODPRM                              07070000
         LA    R0,8                                                  02 07080002
         LA    R15,MBRNAME                                           02 07090002
PROC0010 DS    0H                                                    02 07100002
         CLI   0(R15),C' '                                           02 07110002
         BE    PROC0020                                              02 07120002
         MVC   0(1,R1),0(R15)                                        02 07130002
         LA    R1,1(,R1)                                             02 07140002
         LA    R15,1(,R15)                                           02 07150002
         BCT   R0,PROC0010                                           02 07160002
PROC0020 DS    0H                                                    02 07170002
         MVI   0(R1),C','              SEPERATOR                     02 07180002
         LA    R1,1(,R1)                                             02 07190002
         LA    R0,8                                                  02 07200002
         LA    R15,CSNAME                                            02 07210002
PROC0030 DS    0H                                                    02 07220002
         CLI   0(R15),C' '                                           02 07230002
         BE    PROC0040                                              02 07240002
         MVC   0(1,R1),0(R15)                                        02 07250002
         LA    R1,1(,R1)                                             02 07260002
         LA    R15,1(,R15)                                           02 07270002
         BCT   R0,PROC0030                                           02 07280002
PROC0040 DS    0H                                                    02 07290002
         MVC   0(11,R1),=C',LIB=OLDLIB' LIBRARY DD NAME              02 07300002
         LR    R2,R1                                                 02 07310002
         LA    R1,11(,R1)                                            02 07320002
         TM    PRMOPT,PRMOPTDB         DEBUG specified               33 07330036
         BNO   PROC0045                No, check for SUMMARY         33 07340036
         MVC   0(13,R1),=C',OPTION=DEBUG' OPTION=DEBUG               33 07350036
         LA    R1,13(,R1)              Next option area              33 07360036
         B     PROC0050                                              33 07370036
PROC0045 DS    0H                                                    33 07380036
         TM    PRMOPT,PRMOPTSU         SUMMARY SPECIFIED                07390000
         BNO   PROC0050                NO, DEFAULT IS DETAIL         02 07400002
         MVC   0(15,R1),=C',OPTION=SUMMARY' OPTION=SUMMARY           02 07410002
         LA    R1,15(,R1)                                            02 07420002
PROC0050 DS    0H                                                    02 07430002
         TM    PRMOPT,PRMOPTZR         CLEARRLD=YES                  02 07440002
         BNO   PROC0060                NO, DEFAULT IS NO             02 07450002
         MVC   0(13,R1),=C',CLEARRLD=YES' CLEARRLE=YES               02 07460002
         LA    R1,13(,R1)                                            02 07470002
PROC0060 DS    0H                                                    02 07480002
         LA    R0,LODPRM                                             02 07490002
         SR    R1,R0                                                 02 07500002
         STH   R1,LODPRMLN             SAVE PARAMETER LENGTH         02 07510002
         TM    PRMOPT,PRMOPTDB         DEBUG ENABLED                    07520000
         BNO   PROC020                 NO, SKIP DEBUG INFO              07530000
         MVC   LINE+1(16),=C'Load old parm=X''' SET UP FORMAT OF PARM   07540000
         UNPK  LINE+17(5),LODPRMLN(3)  CONVERT LENGTH FROM HEX TO CHAR  07550000
         TR    LINE+17(4),HEXTBL-240   FIXUP A-F                        07560000
         MVC   LINE+21(4),=C''',C'''   PREFIX OF PARM                   07570000
         MVC   LINE+25(L'LODPRM),LODPRM MOVE PARAMETER                  07580000
         LA    R1,LINE+25              START OF PARAMETER               07590000
         AH    R1,LODPRMLN             ADD LENGTH                       07600000
         MVI   0(R1),C''''             TERMINATE PARMATER               07610000
         BAL   R14,PRT                 PRINT A LINE                     07620000
PROC020  DS    0H                                                       07630000
         LA    R1,LODPRMAD             GET PARAMETER ADDRESS            07640000
         L     R15,LOADLMD             GET LOADLMD EPA                  07650000
         BALR  R14,R15                 LOAD OLD LMOD                    07660000
         LTR   R15,R15                 WAS LOAD SUCCESSFUL              07670000
         BNZ   PROC800                 NO, ERROR                        07680000
         ST    R0,STARTOLD             Save old CSECT start offset   30 07690033
         LR    R9,R1                   SAVE ADDRESS OF CSECT PREFIX     07700000
* FETCH BUILD LOAD MODULE CSECT                                         07710000
         LA    R1,LODPRM                                             32 07720035
         MVI   LODPRM,C' '             CLEAR LOADLMD PARAMETERS      32 07730035
         MVC   LODPRM+1(L'LODPRM-1),LODPRM                           32 07740035
         LA    R0,8                                                  32 07750035
         LA    R15,MBRNAME                                           32 07760035
         CLI   NEWMBR,C' '                                           32 07770035
         BE    PROC0210                                              32 07780035
         LA    R15,NEWMBR                                            32 07790035
PROC0210 DS    0H                                                    32 07800035
         CLI   0(R15),C' '                                           32 07810035
         BE    PROC0220                                              32 07820035
         MVC   0(1,R1),0(R15)                                        32 07830035
         LA    R1,1(,R1)                                             32 07840035
         LA    R15,1(,R15)                                           32 07850035
         BCT   R0,PROC0210                                           32 07860035
PROC0220 DS    0H                                                    32 07870035
         MVI   0(R1),C','              SEPERATOR                     32 07880035
         LA    R1,1(,R1)                                             32 07890035
         LA    R0,8                                                  32 07900035
         LA    R15,CSNAME                                            32 07910035
PROC0230 DS    0H                                                    32 07920035
         CLI   0(R15),C' '                                           32 07930035
         BE    PROC0240                                              32 07940035
         MVC   0(1,R1),0(R15)                                        32 07950035
         LA    R1,1(,R1)                                             32 07960035
         LA    R15,1(,R15)                                           32 07970035
         BCT   R0,PROC0230                                           32 07980035
PROC0240 DS    0H                                                    32 07990035
         MVC   0(11,R1),=C',LIB=NEWLIB' LIBRARY DD NAME              32 08000035
         LA    R1,11(,R1)                                            32 08010035
         TM    PRMOPT,PRMOPTDB         DEBUG specified               33 08020036
         BNO   PROC0245                No, check for SUMMARY         33 08030036
         MVC   0(13,R1),=C',OPTION=DEBUG' OPTION=DEBUG               33 08040036
         LA    R1,13(,R1)              Next option area              33 08050036
         B     PROC0250                                              33 08060036
PROC0245 DS    0H                                                    33 08070036
         TM    PRMOPT,PRMOPTSU         SUMMARY SPECIFIED             32 08080035
         BNO   PROC0250                NO, DEFAULT IS DETAIL         32 08090035
         MVC   0(15,R1),=C',OPTION=SUMMARY' OPTION=SUMMARY           32 08100035
         LA    R1,15(,R1)                                            32 08110035
PROC0250 DS    0H                                                    32 08120035
         TM    PRMOPT,PRMOPTZR         CLEARRLD=YES                  32 08130035
         BNO   PROC0260                NO, DEFAULT IS NO             32 08140035
         MVC   0(13,R1),=C',CLEARRLD=YES' CLEARRLD=YES               32 08150035
         LA    R1,13(,R1)                                            32 08160035
PROC0260 DS    0H                                                    32 08170035
         LA    R0,LODPRM                                             32 08180035
         SR    R1,R0                                                 32 08190035
         STH   R1,LODPRMLN             SAVE PARAMETER LENGTH         32 08200035
         TM    PRMOPT,PRMOPTDB         DEBUG ENABLED                    08210000
         BNO   PROC030                 NO, SKIP DEBUG INFO              08220000
         MVC   LINE+1(16),=C'Load new parm=X''' SET UP FORMAT OF PARM   08230000
         UNPK  LINE+17(5),LODPRMLN(3)  CONVERT LENGTH FROM HEX TO CHAR  08240000
         TR    LINE+17(4),HEXTBL-240   FIXUP A-F                        08250000
         MVC   LINE+21(4),=C''',C'''   PREFIX OF PARM                   08260000
         MVC   LINE+25(L'LODPRM),LODPRM MOVE PARAMETER                  08270000
         LA    R1,LINE+25              START OF PARAMETER               08280000
         AH    R1,LODPRMLN             ADD LENGTH                       08290000
         MVI   0(R1),C''''             TERMINATE PARMATER               08300000
         BAL   R14,PRT                 PRINT A LINE                     08310000
PROC030  DS    0H                                                       08320000
         LA    R1,LODPRMAD             GET PARAMETER ADDRESS            08330000
         L     R15,LOADLMD             GET LOADLMD EPA                  08340000
         BALR  R14,R15                 LOAD NEW LMOD                    08350000
         LTR   R15,R15                 WAS LOAD SUCCESSFUL              08360000
         BNZ   PROC810                 NO, ERROR                        08370000
         LR    R8,R1                   SAVE ADDRESS OF CSECT PREFIX     08380000
         ST    R0,STARTNEW             Save new CSECT start offset   30 08390033
* PREPARE FOR COMPARE                                                   08400000
         LA    R4,8(,R9)               GET OLD CSECT ADDRESS            08410000
         L     R5,4(,R9)               GET OLD CSECT LENGTH             08420000
         LA    R6,8(,R8)               GET NEW CSECT ADDRESS            08430000
         L     R7,4(,R8)               GET NEW CSECT LENGTH             08440000
         MVC   LINE+1(10),=C'Old length' REPORT ON OLD CSECT LENGTH     08450000
         CVD   R5,DWORD                GET OLD LENGTH                   08460000
         MVC   LINE+20(12),=X'402020206B2020206B202120' EDIT MASK       08470000
         ED    LINE+20(12),DWORD+3     EDIT OLD LENGTH                  08480000
         MVC   LINE+33(2),=C'X'''      ALSO                             08490000
         UNPK  LINE+35(5),6(3,R9)       SHOW                            08500000
         TR    LINE+35(4),HEXTBL-240     OLD LENGTH                     08510000
         MVI   LINE+39,C''''              IN HEX                        08520000
         MVC   LINE+41(6),=C'Offset'   REPORT OLD CSECT OFFSET       30 08530033
         MVC   LINE+48(2),=C'X'''      OLD                           30 08540033
         UNPK  LINE+50(5),STARTOLD+2(3) OFFSET                       30 08550033
         TR    LINE+50(4),HEXTBL-240     IN                          30 08560033
         MVI   LINE+54,C''''              HEX                        30 08570033
         BAL   R14,PRT                 PRINT A LINE                     08580000
         MVC   LINE+1(10),=C'New length' REPORT ON NEW CSECT LENGTH     08590000
         CVD   R7,DWORD                GET NEW LENGTH                   08600000
         MVC   LINE+20(12),=X'402020206B2020206B202120' EDIT MASK       08610000
         ED    LINE+20(12),DWORD+3     EDIT NEW LENGTH                  08620000
         MVC   LINE+33(2),=C'X'''      ALSO                             08630000
         UNPK  LINE+35(5),6(3,R8)       SHOW                            08640000
         TR    LINE+35(4),HEXTBL-240     NEW LENGTH                     08650000
         MVI   LINE+39,C''''              IN HEX                        08660000
         MVC   LINE+41(6),=C'Offset'   REPORT NEW CSECT OFFSET       30 08670033
         MVC   LINE+48(2),=C'X'''      NEW                           30 08680033
         UNPK  LINE+50(5),STARTNEW+2(3) OFFSET                       30 08690033
         TR    LINE+50(4),HEXTBL-240     IN                          30 08700033
         MVI   LINE+54,C''''              HEX                        30 08710033
         CR    R5,R7                   ARE LENGTHS THE SAME             08720000
         BE    PROC040                 YES, CONTINUE                    08730000
         MVC   LINE+56(17),=C'Lengths different' THEY ARE DIFFERENT  30 08740033
PROC040  DS    0H                                                       08750000
         BAL   R14,PRT                 PRINT A LINE                     08760000
         L     R10,MAXRPTER            GET MAX ERRORS TO REPORT         08770000
         SR    R0,R0                   CLEAR NUMBER OF ERRORS        07 08780008
         ST    R0,SAVEOLD                                            07 08790008
         ST    R0,SAVENEW                                            07 08800008
PROC100  DS    0H                                                       08810023
         CLC   0(1,R4),0(R6)           COMPARE OLD TO NEW            04 08820004
         BE    PROC105                 THEY ARE THE SAME             04 08830004
         L     R1,4(,R9)               LENGTH                        14 08840015
         SR    R1,R5                   RELATIVE OFFSET OF ERROR      14 08850015
         BAL   R14,DIFF                Check for in ignore table     26 08860029
         LTR   R15,R15                 Found in ignore diff tbl      26 08870029
         BZ    PROC105                 Yes, treat as match           26 08880029
         CLI   0(R6),0                                               09 08890010
         BNE   PROC101                                               09 08900010
         L     R1,ZERERRS                                            07 08910010
         LA    R1,1(,R1)               ADD TO DIFFERENT COUNT        07 08920010
         ST    R1,ZERERRS                                            07 08930010
PROC101  DS    0H                                                    98 08940023
         L     R1,TOTERRS                                            07 08950008
         LA    R1,1(,R1)               ADD TO DIFFERENT COUNT        07 08960008
         ST    R1,TOTERRS                                            07 08970008
         TM    PRMOPT,PRMOPTSU         Summary?                      21 08980024
         BO    PROC120                 Yes, skip reporting           21 08990024
         LTR   R10,R10                 BEYOND MAX REPORTABLE ERORS   07 09000008
         BZ    PROC119                 YES, SKIP REPORTING           11 09010012
         BCTR  R10,0                   COUNT REPORTED ERRORS         04 09020004
         ICM   R0,15,SAVEOLD           FIRST NOT EQUAL               04 09030004
         BNZ   PROC110                 NO, CONTINUE                  04 09040004
         ST    R4,SAVEOLD              SAVE FIRST NOT EQUAL OLD      04 09050004
         ST    R6,SAVENEW              SAVE FIRST NOT EQUAL NEW      04 09060004
         B     PROC120                                               10 09070011
PROC105  DS    0H                                                    04 09080023
         ICM   R0,15,SAVEOLD                                         04 09090004
         BZ    PROC120                                               04 09100004
         B     PROC115                                               04 09110004
PROC110  DS    0H                                                    04 09120023
         LR    R0,R4                                                 04 09130004
         S     R0,SAVEOLD                                            04 09140004
         CH    R0,=H'+16'              LESS THAN 16 BYTES            22 09150024
         BL    PROC120                 YES, CONTINUE COMPARE         04 09160004
         LTR   R10,R10                 At max reportable errors      22 09170024
         BZ    PROC120                 Yes, skip                     22 09180024
         BAL   R14,FMT                 FORMAT DIFFERENCES            22 09190024
         ST    R4,SAVEOLD              SAVE FIRST NOT EQUAL OLD      22 09200024
         ST    R6,SAVENEW              SAVE FIRST NOT EQUAL NEW      22 09210024
         B     PROC120                                               22 09220024
PROC115  DS    0H                                                    04 09230023
         LTR   R10,R10                 At max reportable errors      11 09240012
         BZ    PROC120                 Yes, skip                     11 09250012
         BAL   R14,FMT                 FORMAT DIFFERENCES            04 09260004
         SR    R0,R0                                                 04 09270004
         ST    R0,SAVEOLD                                            04 09280004
         ST    R0,SAVENEW                                            04 09290004
         B     PROC120                                               20 09300023
PROC119  DS    0H                                                    11 09310023
         TM    FLAG,FLAGMAX                                          11 09320012
         BO    PROC120                                               11 09330012
         MVC   LINE+1(33),=C'Maximum reportable errors reached'      11 09340012
         BAL   R14,PRT                                               11 09350012
         OI    FLAG,FLAGMAX                                          11 09360012
PROC120  DS    0H                                                       09370023
         LA    R4,1(,R4)               SKIP MISS MATCH                  09380000
         SH    R5,=H'+1'               REDUCE LENGTH                    09390000
         LA    R6,1(,R6)               SKIP MISS MATCH                  09400000
         SH    R7,=H'+1'               REDUCE LENGTH                    09410000
         LTR   R5,R5                                                 05 09420005
         BNH   PROC700                                               05 09430032
         LTR   R7,R7                                                 05 09440005
         BH    PROC100                 NOT END OF NEW                   09450001
*                                                                    29 09460032
*        END OF LOAD MODULES                                         29 09470032
*                                                                    29 09480032
PROC700  DS    0H                                                    29 09490032
         TM    FLAG,FLAGDIF            DIFOUT OPEN                   29 09500032
         BNO   PROC730                 No, exit                      29 09510032
         ICM   R0,15,GENDIFST          Is there a last difference    31 09520034
         BZ    PROC705                 No, skip it                   31 09530034
         L     R3,GENDIFLN             Get length for GENDIF         31 09540034
         BAL   R14,GENDIF              Generate a DIFOUT record      31 09550034
PROC705  DS    0H                                                    31 09560034
         LA    R14,DIFTBL              Difference table              31 09570034
         USING DIFENT,R14                                            29 09580032
PROC710  DS    0H                                                    29 09590034
         C     R14,DIFTBLST            End of table                  29 09600032
         BH    PROC730                 Yes, were done here           29 09610032
         CLI   DIFENTND,X'FF'          DIFIN generated               29 09620032
         BE    PROC720                 Yes, skip entry               29 09630032
         STM   R14,R3,FMTSAV2          Save registers                29 09640032
         L     R0,DIFENTST             Start address                 29 09650032
         L     R3,DIFENTND             Get end offset                29 09660032
         SR    R3,R0                   Less start                    29 09670032
         LA    R3,1(,R3)               Relative to one               29 09680032
         BAL   R14,GENDIF              Write difference record       29 09690032
         LM    R14,R3,FMTSAV2          Restore registers             29 09700032
         MVI   DIFENTND,X'FF'          Mark DIFIN copied             29 09710032
PROC720  DS    0H                                                    29 09720034
         LA    R14,L'DIFENT(,R14)      Next dif entry                29 09730032
         B     PROC710                 Check next DIF entry          29 09740032
         DROP  R14                                                   29 09750032
PROC730  DS    0H                                                    29 09760034
         TM    PRMOPT,PRMOPTSU         Summary?                      21 09770024
         BO    PROC760                 Yes, skip reporting           29 09780032
         LTR   R10,R10                 At max reportable errors      11 09790012
         BZ    PROC760                 Yes, skip                     29 09800032
         ICM   R0,15,SAVEOLD           ANY UNQEUAL NOT REPORTED      04 09810004
         BZ    PROC740                 NO, CONTINUE                  29 09820032
         BAL   R14,FMT                 FORMAT DIFFERENCES            04 09830004
PROC740  DS    0H                                                    29 09840032
         LTR   R5,R5                                                 07 09850008
         BNH   PROC750                                               29 09860032
         BAL   R14,FMTOLD                                            07 09870008
PROC750  DS    0H                                                    29 09880032
         LTR   R7,R7                                                 07 09890008
         BNH   PROC760                                               29 09900032
         BAL   R14,FMTNEW                                            07 09910012
PROC760  DS    0H                                                    29 09920032
         L     R0,0(,R8)               GET LENGTH OF OLD                09930000
         LR    R1,R8                   GET ADDRESS OF OLD               09940000
         FREEMAIN R,A=(1),LV=(0)       FREE OLD STORAGE                 09950000
         L     R0,0(,R9)               GET LENGTH OF NEW                09960000
         LR    R1,R9                   GET ADDRESS OF NEW               09970000
         FREEMAIN R,A=(1),LV=(0)       FREE NEW STORAGE                 09980000
         B     PROC900                 WERE ALL DONE                    09990000
PROC800  DS    0H                                                       10000000
         LA    R14,=C'OLDLIB'          OLD IS IN ERROR               08 10010009
         B     PROC820                 REPORT ON LOAD FAILURE           10020000
PROC810  DS    0H                                                       10030000
         LA    R14,=C'NEWLIB'          NEW IS IN ERROR               08 10040009
PROC820  DS    0H                                                       10050000
         MVC   LINE+1(22),=C'LOADLMD failed for DD=' REPORT RC       08 10060009
         MVC   LINE+23(6),0(R14)       LIBERY                        08 10070009
         MVC   LINE+30(5),=C'RC=X'''   REPORT RC                     08 10080009
         ST    R15,DWORD               SAVE RETURN CODE              08 10090009
         UNPK  LINE+35(9),DWORD(5)     CONVERT RC HEX TO CHAR        08 10100009
         TR    LINE+35(8),HEXTBL-240   FIX UP A-F                    08 10110009
         MVC   LINE+43(11),=C''' Reason=X''' REPORT LOADLMD REASON   08 10120009
         ST    R1,DWORD                SAVE REASON CODE              08 10130009
         UNPK  LINE+54(9),DWORD(5)     CONVERT RC HEX TO CHAR        08 10140009
         TR    LINE+54(8),HEXTBL-240   FIX UP A-F                    08 10150009
         MVI   LINE+62,C''''           END OF RETURN CODE            08 10160009
         BAL   R14,PRT                 PRINT A LINE                     10170000
         LA    R2,8                    RETURN CODE IS 8                 10180000
         B     EXIT                    EXIT                             10190000
PROC900  DS    0H                                                       10200000
         MVC   LINE+1(11),=C'Differences' REPORT DIFFERENCES            10210000
         L     R0,TOTERRS                                            07 10220008
         CVD   R0,DWORD                CONVERT DIFFERENCES COUNT     07 10230008
         MVC   LINE+20(12),=X'402020206B2020206B202120' EDIT MASK       10240000
         ED    LINE+20(12),DWORD+3     EDIT DIFFERENCES COUNT           10250000
         BAL   R14,PRT                 PRINT A LINE                     10260000
* Handle ignored differences                                         14 10270015
         ICM   R0,15,IGNERRS           Any ignored differences?      14 10280015
         BZ    PROC901                 No, continue                  14 10290015
         MVC   LINE+1(13),=C'Ignored diffs'                          14 10300015
         CVD   R0,DWORD                Convert zero differences      14 10310015
         MVC   LINE+20(12),=X'402020206B2020206B202120' Edit mask    14 10320015
         ED    LINE+20(12),DWORD+3     Edit differences count        14 10330015
         BAL   R14,PRT                 Print a line                  14 10340015
PROC901  DS    0H                                                    14 10350015
         ICM   R0,15,ZERERRS           Any diffs zero in new?        09 10360010
         BZ    PROC905                 No, skip total                09 10370010
         C     R0,TOTERRS              All diffs zero in new?        09 10380010
         BNE   PROC903                 No, continue                  09 10390010
         MVC   LINE+1(14),=C'All diffs zero'                         09 10400010
         CVD   R0,DWORD                Convert zero differences      09 10410010
         MVC   LINE+20(12),=X'402020206B2020206B202120' Edit mask    09 10420010
         ED    LINE+20(12),DWORD+3     Edit differences count        09 10430010
         BAL   R14,PRT                 Print a line                  09 10440010
         B     PROC905                 Continue                      09 10450010
PROC903  DS    0H                                                    09 10460010
*23      MVC   LINE+1(14),=C'New zero diffs'                         09 10470025
*23      CVD   R0,DWORD                Convert zero differences      09 10480025
*23      MVC   LINE+20(12),=X'402020206B2020206B202120' Edit mask    09 10490025
*23      ED    LINE+20(12),DWORD+3     Edit differences count        09 10500025
*23      BAL   R14,PRT                 Print a line                  09 10510025
PROC905  DS    0H                                                    09 10520010
         CR    R5,R7                   LENGTHS DIFFERENT                10530000
         BNE   PROC910                 YES RETURN CODE IS 4             10540029
         ICM   R2,15,TOTERRS                                         07 10550008
         BZ    EXIT                    ZERO, WE HAVE RC=0               10560000
PROC910  DS    0H                                                       10570000
         LA    R2,4                    SET RETURN CODE TO 4             10580000
         TM    PRMOPT,PRMOPTR5         Return code=5 on differences? 25 10590027
         BZ    PROC915                 No, skip                      25 10600027
         LA    R2,5                    See this as highest if ASM=4  25 10610027
PROC915  DS    0H                                                       10620027
EXIT     DS    0H                                                       10630000
         MVC   LINE+1(11),=C'Return code'                            24 10640026
         CVD   R2,DWORD                Convert zero differences      24 10650026
         MVC   LINE+26(6),=X'402120202020' Edit mask                 24 10660026
         ED    LINE+26(6),DWORD+5      Edit RC like IEFACTRT         24 10670026
         BAL   R14,PRT                 Print a line                  24 10680026
         TM    FLAG,FLAGDC             Is DC DD present?             10 10690011
         BNO   DCNOC                   No, skip CLOSE                10 10700011
         CLOSE (DCDCB)                 CLOSE DC DCB                  10 10710011
DCNOC    DS    0H                                                    10 10720011
         TM    FLAG,FLAGDIF            Is DIFOUT DD present?         17 10730018
         BNO   DIFOUTNC                No, skip CLOSE                17 10740018
         CLOSE (DIFOUT)                CLOSE DIFOUT DCB              17 10750018
DIFOUTNC DS    0H                                                    17 10760018
         CLOSE (SYSPRINT)              CLOSE SYSPRINT                   10770000
         L     R13,4(,R13)             GET CALLERS SAVE AREA            10780000
         L     R14,12(,R13)            RESTORE R14                      10790000
         LR    R15,R2                  SET RETURN CODE                  10800000
         LM    R0,R12,20(R13)          RESTORE REST OF REGS             10810000
         BR    R14                     EXIT                             10820000
QUIT     DS    0H                                                       10830000
         L     R13,4(,R13)             GET CALLERS SAVE AREA            10840000
         LM    R14,R12,12(R13)         RESTORE CALLERS REGS             10850000
         LA    R15,16                  SET RETURN CODE TO 16            10860000
         BR    R14                     EXIT                             10870000
******************************************************************** 04 10880004
*                                                                  * 04 10890004
*                                                                  * 04 10900004
*                                                                  * 04 10910004
******************************************************************** 04 10920004
FMT      DS    0H                                                    04 10930004
         ST    R14,FMTR14              SAVE LINKAGE                  04 10940004
         BAL   R14,HDR                 Do headings if needed         26 10950029
         L     R1,SAVEOLD              GET ADDRESS OF MISMATCH       04 10960004
         SR    R1,R9                   LESS START                    04 10970004
         SH    R1,=H'+8'               INCLUDE PREFIX                04 10980004
         A     R1,CSOFF                Plus CSECT offset             26 10990028
         STH   R1,DWORD                SAVE OFFSET                   04 11000004
         UNPK  LINE+3(5),DWORD(3)      CONVERT OFFSET HEX TO CHAR    07 11010008
         TR    LINE+3(4),HEXTBL-240    GET A-F AS WELL               04 11020004
         LR    R3,R4                                                 10 11030011
         S     R3,SAVEOLD                                            10 11040011
         CVD   R3,DWORD                                              10 11050011
         OI    DWORD+7,15                                            04 11060004
         UNPK  LINE+7(3),DWORD+6(2)                                  04 11070004
         MVI   LINE+7,C'('                                           04 11080004
         MVI   LINE+10,C')'                                          04 11090004
         L     R1,SAVEOLD                                            04 11100004
         LA    R2,LINE+12                                            04 11110004
         LR    R15,R3                                                04 11120004
         BAL   R14,DMPDSP                                            04 11130004
         MVI   LINE+45,C'*'                                          04 11140004
         LR    R1,R3                                                 04 11150004
         BCTR  R1,0                                                  04 11160004
         L     R14,SAVEOLD                                           04 11170004
         EX    R1,FMTMVCO                                            04 11180004
         EX    R1,FMTTRO                                             04 11190004
         LA    R1,LINE+47(R1)                                        04 11200004
         MVI   0(R1),C'*'                                            04 11210004
*                                                                    04 11220004
         L     R1,SAVENEW                                            04 11230004
         LA    R2,LINE+66                                            04 11240004
         LR    R15,R3                                                04 11250004
         BAL   R14,DMPDSP                                            04 11260004
         MVI   LINE+99,C'*'                                          04 11270004
         LR    R1,R3                                                 04 11280004
         BCTR  R1,0                                                  04 11290004
         L     R14,SAVENEW                                           04 11300004
         EX    R1,FMTMVCN                                            04 11310004
         EX    R1,FMTTRN                                             04 11320004
         LA    R1,LINE+101(R1)                                       04 11330004
         MVI   0(R1),C'*'                                            04 11340004
*                                                                    04 11350004
         BAL   R14,PRT                 PRINT A LINE                  04 11360004
*        Generate DIFOUT for any differences if DIFOUT DD present    17 11370018
         TM    FLAG,FLAGDIF                                          17 11380018
         BNO   FMTDC                                                 17 11390018
         L     R0,SAVEOLD              Get start address             28 11400031
         SR    R0,R9                   Less CSECT start              28 11410031
         SH    R0,=H'+8'               Exclude header for length     28 11420031
*        Copy any preceeding DIFIN entries to DIFOUT                 19 11430023
         STM   R14,R3,FMTSAV1          Save registers                28 11440031
         ICM   R1,15,DIFTBLST          DIFFERENCE TABLE END          19 11450023
         BZ    FMTDFND                 IF ZERO NO TABLE              19 11460023
         LA    R14,DIFTBL              DIFFERENCE TABLE              19 11470023
         USING DIFENT,R14                                            29 11480032
FMTDFCK  DS    0H                                                    19 11490023
         CR    R14,R1                  END OF DIF TABLE              19 11500023
         BNL   FMTDFND                 YES, WERE DONE HERE           19 11510023
         CL    R0,DIFENTND             MISMATCH OFFSET AFTER ENTRY   29 11520032
         BNH   FMTDFNX                 YES, SKIP DIF ENTRY           19 11530023
         STM   R14,R3,FMTSAV2          Save registers                28 11540031
         L     R0,DIFENTST             Start address                 29 11550032
         L     R3,DIFENTND             Get end offset                29 11560032
         SR    R3,R0                   Less start                    28 11570031
         LA    R3,1(,R3)               Relative to one               28 11580031
         BAL   R14,GENDIF              Write difference record       28 11590031
         LM    R14,R3,FMTSAV2          Restore registers             28 11600031
         MVI   DIFENTND,X'FF'          Mark DIFIN copied             29 11610032
FMTDFNX  DS    0H                                                    19 11620023
         LA    R14,L'DIFENT(,R14)      NEXT DIF ENTRY                29 11630032
         B     FMTDFCK                 NEXT DIF                      20 11640023
         DROP  R14                                                   29 11650032
FMTDFND  DS    0H                                                    19 11660023
         LM    R14,R3,FMTSAV1          Restore registers             28 11670031
         BAL   R14,GENDIF              Write difference record       28 11680031
         B     FMTXT                                                 17 11690018
*        Generate DC for any differences if DC DD present            17 11700018
FMTDC    DS    0H                                                    17 11710018
         TM    FLAG,FLAGDC             Is DC DD present?             10 11720011
         BNO   FMTXT                   No, skip formatting           10 11730011
         MVC   LINE+9(3),=C'ORG'       *                             10 11740011
         MVC   LINE+15(8),CSNAME        *                            10 11750011
         LA    R1,LINE+15               *                            10 11760011
FMTDCDC1 DS    0H                       *                            10 11770011
         CLI   0(R1),C' '               *                            10 11780011
         BE    FMTDCDC2                 *                            10 11790011
         LA    R1,1(,R1)                *                            10 11800011
         B     FMTDCDC1                 *  Format                    10 11810011
FMTDCDC2 DS    0H                        * ORG                       10 11820011
         MVC   0(3,R1),=C'+X'''         *  statement                 10 11830011
         L     R0,SAVEOLD               *                            10 11840011
         SR    R0,R9                    *                            10 11850011
         SH    R0,=H'+8'                *                            10 11860011
         STH   R0,DWORD                 *                            10 11870011
         UNPK  3(5,R1),DWORD(3)         *                            10 11880011
         TR    3(4,R1),HEXTBL-240       *                            10 11890011
         MVI   7(R1),C''''              *                            10 11900011
         MVC   LINE+56(15),=C'FIX ~~~ DSKXXXX'                       10 11910011
         AP    DCCNT,=P'+1'             *                            10 11920011
         OI    DCCNT+1,X'0F'            *                            10 11930011
         UNPK  LINE+77(3),DCCNT         *                            10 11940011
         PUT   DCDCB,LINE              *                             10 11950011
         MVI   LINE,C' '               *                             10 11960011
         MVC   LINE+1(L'LINE-1),LINE    *                            10 11970011
         MVC   LINE(3),=C'A00'          *                            10 11980011
         UNPK  LINE+3(5),DWORD(3)       *                            10 11990011
         TR    LINE+3(4),HEXTBL-240     *                            10 12000011
         MVI   LINE+7,C' '              *                            10 12010011
         MVC   LINE+9(2),=C'DC'         *                            10 12020011
         MVC   LINE+15(2),=C'X'''       *  Format                    10 12030011
         L     R1,SAVEOLD                * DC                        10 12040011
         LA    R2,LINE+17               *  statement                 10 12050011
         LR    R15,R3                   *                            10 12060011
         BAL   R14,DMPDSP               *                            10 12070011
         LA    R1,0(R3,R3)              *                            10 12080011
         LA    R1,LINE+17(R1)           *                            10 12090011
         MVI   0(R1),C''''              *                            10 12100011
         MVC   LINE+56(15),=C'FIX ~~~ DSKXXXX'                       10 12110011
         AP    DCCNT,=P'+1'             *                            10 12120011
         OI    DCCNT+1,X'0F'            *                            10 12130011
         UNPK  LINE+77(3),DCCNT         *                            10 12140011
         PUT   DCDCB,LINE               *                            10 12150011
         MVI   LINE,C' '                *                            10 12160011
         MVC   LINE+1(L'LINE-1),LINE   *                             10 12170011
FMTXT    DS    0H                                                    10 12180011
         L     R14,FMTR14              RESTORE LINKAGE               04 12190004
         BR    R14                     RETURN TO CALLER              04 12200004
*                                                                    04 12210004
FMTMVCO  MVC   LINE+46(0),0(R14)                                     04 12220004
FMTTRO   TR    LINE+46(0),DMPTBLCH                                   04 12230004
FMTMVCN  MVC   LINE+100(0),0(R14)                                    04 12240004
FMTTRN   TR    LINE+100(0),DMPTBLCH                                  04 12250004
*                                                                    28 12260031
******************************************************************** 28 12270031
*                                                                  * 28 12280031
*        Generate DIFIN                                            * 28 12290031
*          R0=Start address of current difference                  * 28 12300031
*          R3=Length of current difference                         * 28 12310031
*                                                                  * 28 12320031
******************************************************************** 28 12330031
GENDIF   DS    0H                                                    28 12340034
         STM   R0,R15,GENDIFRG         Save registers                28 12350031
         LR    R2,R0                   Copy start address            28 12360031
         L     R14,GENDIFST            Get previous start            28 12370031
         A     R14,GENDIFLN            Add length                    28 12380031
         CR    R14,R2                  Previous end = current start  28 12390031
         BE    GENDIFCD                Yes, generate a difference    28 12400031
         ICM   R0,15,GENDIFLN          Get length                    28 12410031
         BZ    GENDIFSK                If zero skip                  28 12420031
         L     R15,GENDIFST            Get start address             28 12430031
         BAL   R14,WRTDIF              Write a difference            28 12440031
GENDIFSK DS    0H                                                    28 12450034
         ST    R2,GENDIFST             Update start                  28 12460031
         ST    R3,GENDIFLN             Update length                 28 12470031
         B     GENDIFXT                Exit                          28 12480031
GENDIFCD DS    0H                                                    28 12490034
         A     R3,GENDIFLN             Current and last config       28 12500031
         ST    R3,GENDIFLN             Save new length               28 12510031
         CH    R3,=H'255'              Length less than 255          28 12520031
         BL    GENDIFXT                Yes, wait for more diff       28 12530031
         LA    R0,255                  Do 255 contig differences     28 12540031
         L     R15,GENDIFST            Get start address             28 12550031
         BAL   R14,WRTDIF              Write a difference            28 12560031
         L     R3,GENDIFST             Increment start               28 12570031
         AH    R3,=H'+255'             by 255                        28 12580031
         ST    R3,GENDIFST             Save start                    28 12590031
         L     R3,GENDIFLN             Decrement length              28 12600031
         SH    R3,=H'+255'             by 255                        28 12610031
         ST    R3,GENDIFLN             Save new length               28 12620031
GENDIFXT DS    0H                                                    28 12630034
         LM    R0,R15,GENDIFRG         Restore registers             28 12640031
         BR    R14                                                   28 12650031
*                                                                    28 12660031
******************************************************************** 28 12670031
*                                                                  * 28 12680031
******************************************************************** 28 12690031
WRTDIF   DS    0H                                                    28 12700031
         ST    R14,WRTDIF14           Save return address            28 12710031
         STM   R15,R0,DWORD           Save address ane length        28 12720031
         CP    DIFCNT,=P'+0'          First difference               28 12730031
         BNE   WRTDIFNH               No, >CSECT written             28 12740031
         MVI   LINE,C'>'              CSECT id                       28 12750031
         MVC   LINE+1(8),CSNAME       CSECT name                     28 12760031
         PUT   DIFOUT,LINE            Write header                   28 12770031
         AP    DIFCNT,=P'+1'          Count DIFIN records            28 12780031
         MVI   LINE,C' '              Clear                          28 12790031
         MVC   LINE+1(L'LINE-1),LINE   output area                   28 12800031
WRTDIFNH DS    0H                                                    28 12810031
         UNPK  LINE(7),DWORD+1(4)     Get start address              28 12820031
         UNPK  LINE+6(3),DWORD+7(2)   Get length                     28 12830031
         TR    LINE(8),HEXTBL-240     Convert to display             28 12840031
         MVI   LINE+8,C' '            Cleanup                        28 12850031
         PUT   DIFOUT,LINE            Write a DIFIN record           28 12860031
         MVI   LINE,C' '              Clear                          28 12870031
         MVC   LINE+1(L'LINE-1),LINE   output area                   28 12880031
         AP    DIFCNT,=P'+1'          Count DIFIN records            28 12890031
         L     R14,WRTDIF14           Restore return address         28 12900031
         BR    R14                    Exit                           28 12910031
*                                                                    07 12920008
******************************************************************** 07 12930008
*                                                                  * 07 12940008
*                                                                  * 07 12950008
*                                                                  * 07 12960008
******************************************************************** 07 12970008
FMTOLD   DS    0H                                                    07 12980008
         ST    R14,FMTOLD14            SAVE LINKAGE                  07 12990008
FMTOLD10 DS    0H                                                    26 13000029
         L     R1,4(,R9)               Length                        26 13010029
         SR    R1,R5                   Relative offset of error      26 13020029
         BAL   R14,DIFF                Check for in ignore table     26 13030029
         LTR   R15,R15                 Found in ignore diff tbl      26 13040029
         BNZ   FMTOLD20                No, format it                 26 13050029
         LA    R4,1(,R4)               Next old byte                 26 13060029
         SH    R5,=H'+1'               Length left to do             26 13070029
         BP    FMTOLD10                Check next byte               26 13080029
         ST    R7,DWORD                                              26 13090029
         B     FMTOLD60                Exit                          26 13100029
FMTOLD20 DS    0H                                                    26 13110029
         LTR   R10,R10                                               26 13120029
         BNP   FMTOLD40                                              26 13130029
         BAL   R14,HDR                 Do headings if needed         26 13140029
         LR    R1,R4                   GET ADDRESS OF MISMATCH       07 13150008
         SR    R1,R9                   LESS START                    07 13160008
         SH    R1,=H'+8'               INCLUDE PREFIX                07 13170008
         A     R1,CSOFF                Plus CSECT offset             26 13180029
         STH   R1,DWORD                SAVE OFFSET                   07 13190008
         UNPK  LINE+3(5),DWORD(3)      CONVERT OFFSET HEX TO CHAR    07 13200008
         TR    LINE+3(4),HEXTBL-240    GET A-F AS WELL               07 13210008
         LR    R3,R5                                                 07 13220008
         CH    R3,=H'+16'                                            07 13230008
         BNH   FMTOLD30                                              07 13240008
         LA    R3,16                                                 07 13250008
FMTOLD30 DS    0H                                                    07 13260008
         CVD   R3,DWORD                                              07 13270008
         OI    DWORD+7,15                                            07 13280008
         UNPK  LINE+7(3),DWORD+6(2)                                  07 13290008
         MVI   LINE+7,C'('                                           07 13300008
         MVI   LINE+10,C')'                                          07 13310008
         LR    R1,R4                                                 07 13320008
         LA    R2,LINE+12                                            07 13330008
         LR    R15,R3                                                07 13340008
         BAL   R14,DMPDSP                                            07 13350008
         MVI   LINE+45,C'*'                                          07 13360008
         LR    R1,R3                                                 07 13370008
         BCTR  R1,0                                                  07 13380008
         LR    R14,R4                                                07 13390008
         EX    R1,FMTMVCO                                            07 13400008
         EX    R1,FMTTRO                                             07 13410008
         LA    R1,LINE+47(R1)                                        07 13420008
         MVI   0(R1),C'*'                                            07 13430008
         BAL   R14,PRT                 PRINT A LINE                  07 13440008
FMTOLD40 DS    0H                                                    07 13450008
         LR    R3,R5                                                 07 13460008
         CH    R3,=H'+16'                                            07 13470008
         BNH   FMTOLD50                                              07 13480008
         LA    R3,16                                                 07 13490008
FMTOLD50 DS    0H                                                    07 13500008
         L     R0,TOTERRS                                            07 13510008
         AR    R0,R3                                                 07 13520008
         ST    R0,TOTERRS                                            07 13530008
         SR    R10,R3                                                07 13540008
         LA    R4,16(,R4)                                            07 13550008
         SH    R5,=H'+16'                                            07 13560008
         BP    FMTOLD10                                              07 13570008
FMTOLD60 DS    0H                                                    26 13580029
         L     R14,FMTOLD14            RESTORE LINKAGE               07 13590008
         BR    R14                     RETURN TO CALLER              07 13600008
*                                                                    07 13610008
******************************************************************** 07 13620008
*                                                                  * 07 13630008
*                                                                  * 07 13640008
*                                                                  * 07 13650008
******************************************************************** 07 13660008
FMTNEW   DS    0H                                                    07 13670008
         ST    R14,FMTNEW14            SAVE LINKAGE                  07 13680008
FMTNEW10 DS    0H                                                    26 13690029
         L     R1,4(,R8)               Length                        26 13700029
         SR    R1,R7                   Relative offset of error      26 13710029
         BAL   R14,DIFF                Check for in ignore table     26 13720029
         LTR   R15,R15                 Found in ignore diff tbl      26 13730029
         BNZ   FMTNEW20                No, format it                 26 13740029
         LA    R6,1(,R6)               Next new byte                 26 13750029
         SH    R7,=H'+1'               Length left to do             26 13760029
         BP    FMTNEW10                Check next byte               26 13770029
         B     FMTNEW60                Exit                          26 13780029
FMTNEW20 DS    0H                                                    26 13790029
         LTR   R10,R10                                               26 13800029
         BNP   FMTNEW40                                              26 13810029
         BAL   R14,HDR                 Do headings if needed         26 13820029
         LR    R1,R6                   GET ADDRESS OF MISMATCH       07 13830008
         SR    R1,R8                   LESS START                    07 13840008
         SH    R1,=H'+8'               INCLUDE PREFIX                07 13850008
         A     R1,CSOFF                Plus CSECT offset             26 13860029
         STH   R1,DWORD                SAVE OFFSET                   07 13870008
         UNPK  LINE+3(5),DWORD(3)      CONVERT OFFSET HEX TO CHAR    07 13880008
         TR    LINE+3(4),HEXTBL-240    GET A-F AS WELL               07 13890008
         LR    R3,R7                                                 07 13900008
         CH    R3,=H'+16'                                            07 13910008
         BNH   FMTNEW30                                              07 13920008
         LA    R3,16                                                 07 13930008
FMTNEW30 DS    0H                                                    07 13940008
         CVD   R3,DWORD                                              07 13950008
         OI    DWORD+7,15                                            07 13960008
         UNPK  LINE+7(3),DWORD+6(2)                                  07 13970008
         MVI   LINE+7,C'('                                           07 13980008
         MVI   LINE+10,C')'                                          07 13990008
         LR    R1,R6                                                 07 14000008
         LA    R2,LINE+66                                            07 14010008
         LR    R15,R3                                                07 14020008
         BAL   R14,DMPDSP                                            07 14030008
         MVI   LINE+99,C'*'                                          07 14040008
         LR    R1,R3                                                 07 14050008
         BCTR  R1,0                                                  07 14060008
         LR    R14,R6                                                07 14070008
         EX    R1,FMTMVCN                                            12 14080013
         EX    R1,FMTTRN                                             12 14090013
         LA    R1,LINE+101(R1)                                       07 14100008
         MVI   0(R1),C'*'                                            07 14110008
         BAL   R14,PRT                 PRINT A LINE                  07 14120008
FMTNEW40 DS    0H                                                    07 14130008
         LR    R3,R7                                                 07 14140008
         CH    R3,=H'+16'                                            07 14150008
         BNH   FMTNEW50                                              07 14160008
         LA    R3,16                                                 07 14170008
FMTNEW50 DS    0H                                                    07 14180008
         L     R0,TOTERRS                                            07 14190008
         AR    R0,R3                                                 07 14200008
         ST    R0,TOTERRS                                            07 14210008
         SR    R10,R3                                                07 14220008
         LA    R6,16(,R6)                                            07 14230008
         SH    R7,=H'+16'                                            07 14240008
         BP    FMTNEW10                                              07 14250008
FMTNEW60 DS    0H                                                    26 14260029
         L     R14,FMTNEW14            RESTORE LINKAGE               07 14270008
         BR    R14                     RETURN TO CALLER              07 14280008
*                                                                    26 14290029
******************************************************************** 26 14300029
*                                                                  * 26 14310029
*        Difference header                                         * 26 14320029
*                                                                  * 26 14330029
******************************************************************** 26 14340029
HDR      DS    0H                                                    26 14350029
         TM    FLAG,FLAGHDR            HEADER DONE                   26 14360029
         BOR   R14                     NO, SKIP HEADER               26 14370029
         ST    R14,HDR14               SAVE LINKAGE                  26 14380029
         OI    FLAG,FLAGHDR            SET DID HEADER                26 14390029
         MVC   LINE+1(14),=C'Offset Len Old'                         26 14400029
         MVC   LINE+66(3),=C'New'                                    26 14410029
         BAL   R14,PRT                 PRINT HEADER                  26 14420029
         L     R14,HDR14               RESTORE LINKAGE               26 14430029
         BR    R14                     RETURN TO CALLER              26 14440029
*                                                                    26 14450029
******************************************************************** 26 14460029
*                                                                  * 26 14470029
*        Check  difference in ignore difference table              * 26 14480029
*          Entry                                                   * 26 14490029
*            R1=offset                                             * 26 14500029
*          Exit                                                    * 26 14510029
*            R15=0=in ignore table                                 * 26 14520029
*                4=not in ignore table                             * 26 14530029
*                                                                  * 26 14540029
******************************************************************** 26 14550029
DIFF     DS    0H                                                    26 14560029
         ST    R14,DIFF14              SAVE LINKAGE                  26 14570029
         ICM   R0,15,DIFTBLST          DIFFERENCE TABLE END          26 14580029
         BZ    DIFFDFND                IF ZERO NO TABLE              26 14590029
         LA    R14,DIFTBL              DIFFERENCE TABLE              26 14600029
         USING DIFENT,R14                                            29 14610032
DIFFDFCK DS    0H                                                    26 14620029
         CR    R14,R0                  END OF DIF TABLE              26 14630029
         BNL   DIFFDFND                YES, END OF TABLE             26 14640029
         C     R1,DIFENTST             ERROR OFFSET BEFORE ENTRY     29 14650032
         BL    DIFFDFNX                YES, SKIP DIF ENTRY           26 14660029
         C     R1,DIFENTND             ERROR OFFSET AFTERE ENTRY     29 14670032
         BH    DIFFDFNX                YES, SKIP DIF ENTRY           26 14680029
         L     R1,IGNERRS              GET IGNORED CCOUNT            26 14690029
         LA    R1,1(,R1)               ADD TO IGNORED COUNT          26 14700029
         ST    R1,IGNERRS              SAVE IGNORED COUNT            26 14710029
         SR    R15,R15                 Found difference in table     26 14720029
         B     DIFFXIT                 Exit                          26 14730029
DIFFDFNX DS    0H                                                    26 14740029
         LA    R14,8(,R14)             NEXT DIF ENTRY                26 14750029
         B     DIFFDFCK                NEXT DIF                      26 14760029
         DROP  R14                                                   29 14770032
DIFFDFND DS    0H                                                    26 14780029
         LA    R15,4                   Not found                     26 14790029
DIFFXIT  DS    0H                                                    26 14800029
         L     R14,DIFF14              RESTORE LINKAGE               26 14810029
         BR    R14                     RETURN TO CALLER              26 14820029
*                                                                    07 14830008
******************************************************************** 31 14840034
*                                                                  * 31 14850034
*        Trace                                                     * 31 14860034
*                                                                  * 31 14870034
******************************************************************** 31 14880034
DIAGTRC  DS    0H                                                    31 14890034
         LR    R2,R14                                                31 14900034
         MVC   W#DIAGLN,LINE                                         31 14910034
         MVI   LINE,C' '                                             31 14920034
         MVC   LINE+1(L'LINE-1),LINE                                 31 14930034
         MVC   LINE+1(8),0(R1)                                       31 14940034
         BAL   R14,PRT                                               31 14950034
         MVC   LINE,W#DIAGLN                                         31 14960034
         BR    R2                                                    31 14970034
**********************************************************************  14980000
*                                                                       14990000
*            WRITE PRINT LINE                                           15000000
*                                                                       15010000
**********************************************************************  15020000
PRT      DS    0H                                                       15030000
         ST    R14,PRTR14              SAVE LINKAGE                     15040000
         CP    LNCT,=P'+60'            END OF PAGE                      15050000
         BL    PRTCHK                  NO, CHECK IF LINE FIT IN PAGE    15060000
PRTHDRS  DS    0H                                                       15070000
         AP    PGCT,=P'+1'             COUNT PAGES                      15080000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  15090000
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  15100000
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  15110000
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  15120000
         MVI   LINE,C'0'               SKIP AFTER HEADING               15130000
PRTCHK   DS    0H                                                       15140000
         CLI   LINE,C'+'               OVERPRINT                        15150000
         BE    PRTLINE                 YES, DON'T COUNT                 15160000
         CLI   LINE,C'1'               NEW LINE                         15170000
         BE    PRTHDRS                 ES, PRINT HEADER                 15180000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1          15190000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            15200000
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 2          15210000
         BE    PRTLINE2                YES, GO CHECK IF FIT             15220000
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 3          15230000
         BE    PRTLINE3                YES, GO CHECK IF FIT             15240000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       15250000
PRTLINE1 DS    0H                                                       15260000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                15270000
         B     PRTVFY                  GO SEE IF IT WILL FIT            15280000
PRTLINE2 DS    0H                                                       15290000
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                15300000
         B     PRTVFY                  GO SEE IF IT WILL FIT            15310000
PRTLINE3 DS    0H                                                       15320000
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                15330000
PRTVFY   DS    0H                                                       15340000
         CP    LNCT,=P'+60'            OVERFLOW                         15350000
         BH    PRTHDRS                 YES, FORCE HEADER                15360000
PRTLINE  DS    0H                                                       15370000
         PUT   SYSPRINT,LINE           PRINT A LINE                     15380000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          15390000
         MVC   LINE+1(L'LINE-1),LINE   CLEAR PRINT LINE                 15400000
         L     R14,PRTR14              RESTORE LINKAGE                  15410000
         BR    R14                     RETURN TO CALLER                 15420000
******************************************************************** 31 15430034
*        DUMP WITH ADDRESS OF STORAGE DUMPED                       * 31 15440034
******************************************************************** 31 15450034
DMPAD    DS    0H                                                    31 15460034
         ST    R14,W#DMPADS                                          31 15470034
         STM   R0,R15,W#DMPRGS         SAVE REGISTERS                31 15480034
         ST    R1,W#DMPOFF                                           31 15490034
         LA    R2,LINE+L'LINE-1                                      31 15500034
         LA    R0,L'LINE-1                                           31 15510034
DMPAD010 DS    0H                                                    31 15520034
         CLI   0(R2),C' '                                            31 15530034
         BNE   DMPAD020                                              31 15540034
         BCTR  R2,0                                                  31 15550034
         BCT   R0,DMPAD010                                           31 15560034
DMPAD020 DS    0H                                                    31 15570034
         MVC   2(2,R2),=C'at'                                        31 15580034
         LA    R2,5(,R2)               OUTPUT AREA ADDRESS           31 15590034
         LA    R1,W#DMPOFF             ADDRESS OF OFFSET TO DUMP     31 15600034
         LA    R15,4                   CONVERT 4 BYTES               31 15610034
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY         31 15620034
         BAL   R14,PRT                 PRINT ADDRESS OF DATA         31 15630034
         LM    R0,R15,W#DMPRGS         SAVE REGISTERS                31 15640034
         BAL   R14,DMP                 DUMP STORAGE                  31 15650034
         L     R14,W#DMPADS                                          31 15660034
         BR    R14                     RETURN TO CALLER              31 15670034
******************************************************************** 31 15680034
*        DUMP DATA                                                 * 31 15690034
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP              * 31 15700034
*                     REG 1  = ADDRESS OF DATA TO DUMP             * 31 15710034
******************************************************************** 31 15720034
DMP      DS    0H                                                    31 15730034
         STM   R0,R15,W#DMPRGS         Save registers                31 15740034
         LR    R3,R1                   Get address to dump           31 15750034
         LR    R4,R0                   Get length                    31 15760034
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump          31 15770034
         MVI   W#DMPFLG,W#DMPFL1       First line                    31 15780034
DMPDMPLP DS    0H                                                    31 15790034
         LTR   R4,R4                   Any data to dump?             31 15800034
         BZ    DMPHEXXT                Ye, all done                  31 15810034
         TM    W#DMPFLG,W#DMPFL1       First line?                   31 15820034
         BO    DMPALIN                 Yes, can't have same as above 31 15830034
         LA    R0,32                   Default length                31 15840034
         CR    R4,R0                   Length longer than 32?        31 15850034
         BNH   DMPDUPCK                No, were at last line         31 15860034
         LR    R14,R3                  Get current input area        31 15870034
         SR    R14,R0                  Back to previous area         31 15880034
         CLC   0(32,R14),0(R3)         Duplicate of previous line    31 15890034
         BNE   DMPDUPCK                No, do lines same as          31 15900034
         SR    R4,R0                   Reduce length to do           31 15910034
         TM    W#DMPFLG,W#DMPFLD       Duplicate in progress?        31 15920034
         BO    DMPNXTLN                Yes, we have first offset     31 15930034
         L     R14,W#DMPOFF            Get current offset            31 15940034
         ST    R14,W#DMPDUP            Save as first offset          31 15950034
         OI    W#DMPFLG,W#DMPFLD       Set duplicate                 31 15960034
         B     DMPNXTLN                Continue                      31 15970034
DMPDUPCK DS    0H                                                    31 15980034
         TM    W#DMPFLG,W#DMPFLD       Duplicate in progress?        31 15990034
         BNO   DMPALIN                 No, no duplicate to report    31 16000034
         MVC   LINE+7(5),=C'lines'     Move literal                  31 16010034
         LA    R2,LINE+13              Output area address           31 16020034
         LA    R1,W#DMPDUP+2           Address of offset to dump     31 16030034
         LA    R15,2                   Convert 4 bytes               31 16040034
         BAL   R14,DMPDSP              Convert it to display         31 16050034
         MVI   LINE+17,C'-'            Thru literal                  31 16060034
         L     R1,W#DMPOFF             Get current offset            31 16070034
         S     R1,=A(32)               Get last duplicate offset     31 16080034
         ST    R1,W#DMPDUP             Save for dumping              31 16090034
         LA    R2,LINE+18              Output area address           31 16100034
         LA    R1,W#DMPDUP+2           Address of offset to dump     31 16110034
         LA    R15,2                   Convert 4 bytes               31 16120034
         BAL   R14,DMPDSP              Convert it to display         31 16130034
         MVC   LINE+23(13),=C'same as above' move literal            31 16140034
         BAL   R14,PRT                 Print a line                  31 16150034
         NI    W#DMPFLG,255-W#DMPFLD   Reset duplicate in progress   31 16160034
DMPALIN  DS    0H                                                    31 16170034
         LA    R2,LINE+1               Output area address           31 16180034
         LA    R1,W#DMPOFF+2           Address of offset to dump     31 16190034
         LA    R15,2                   Convert 4 bytes               31 16200034
         BAL   R14,DMPDSP              Convert it to display         31 16210034
         LA    R2,2(,R2)               Skip 1 between offset & data  31 16220034
         LR    R1,R3                   Address of data               31 16230034
         LA    R5,32                   Default length                31 16240034
         CR    R4,R5                   Length longer than 32 ?       31 16250034
         BH    DMPDODMP                Yes, use 32                   31 16260034
         LR    R5,R4                   Use what is left              31 16270034
DMPDODMP DS    0H                                                    31 16280034
         SR    R4,R5                   Reduce amount to do           31 16290034
         MVI   LINE+89,C'*'            Box in display portion        31 16300034
         BCTR  R5,0                    Make zero based               31 16310034
         EX    R5,DMPMVC               Do move                       31 16320034
         EX    R5,DMPTR                Translate out bad stuff       31 16330034
         LA    R5,1(,R5)               Restore length                31 16340034
         MVI   LINE+122,C'*'           Complete box                  31 16350034
DMPDMPHX DS    0H                                                    31 16360034
         LA    R15,4                   4 bytes to process            31 16370034
         CR    R5,R15                  Length longer than 4?         31 16380034
         BH    DMPDMPIT                Yes, dump 4 bytes             31 16390034
         LR    R15,R5                  Use length left               31 16400034
DMPDMPIT DS    0H                                                    31 16410034
         SR    R5,R15                  Reduce amount to do           31 16420034
         BAL   R14,DMPDSP              Convert data                  31 16430034
         LA    R2,1(,R2)               Skip 1 byte                   31 16440034
         LA    R0,LINE+43              Halfway point address         31 16450034
         CR    R0,R2                   At halfway point?             31 16460034
         BNE   DMPDMPNX                No, continue                  31 16470034
         LA    R2,1(,R2)               Skip 1 byte                   31 16480034
DMPDMPNX DS    0H                                                    31 16490034
         LTR   R5,R5                   Any left to do ?              31 16500034
         BH    DMPDMPHX                Yes, go do it                 31 16510034
         BAL   R14,PRT                 Print a line                  31 16520034
DMPNXTLN DS    0H                                                    31 16530034
         L     R1,W#DMPOFF             Get offset in record          31 16540034
         LA    R1,32(,R1)              Add in length we will dump    31 16550034
         ST    R1,W#DMPOFF             Save offset in record         31 16560034
         LA    R3,32(,R3)              Next input area               31 16570034
         NI    W#DMPFLG,255-W#DMPFL1   Not first line                31 16580034
         B     DMPDMPLP                Loop thru until done          31 16590034
DMPHEXXT DS    0H                                                    31 16600034
         LM    R0,R15,W#DMPRGS         Restore callers regs          31 16610034
         BR    R14                     Exit . . .                    31 16620034
DMPMVC   MVC   LINE+90(0),0(R1)        <<< executed >>>              31 16630034
DMPTR    TR    LINE+90(0),DMPTBLCH     <<< executed >>>              31 16640034
*                                                                       16650000
*                                                                       16660000
*                                                                       16670000
DMPDSP   DS    0H                                                       16680000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               16690000
         NI    0(R2),X'0F'             REMOVE ZONE                      16700000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             16710000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             16720000
         TR    0(2,R2),HEXTBL          TRANSLATE TO HEX              04 16730004
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        16740000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         16750000
         BCT   R15,DMPDSP              LOOP THRU DATA                   16760000
         BR    R14                     EXIT . . .                       16770000
         DC    0D'+0'                                                07 16780008
         LTORG ,                                                     07 16790008
         DC    0D'+0'                                                07 16800008
SAVEAREA DC    18A(0)                                                   16810000
DWORD    DC    D'+0'                                                    16820000
MAXRPTER DC    F'+10'                                                   16830000
TOTERRS  DC    F'+0'                                                 07 16840008
ZERERRS  DC    F'+0'                                                 09 16850010
IGNERRS  DC    F'+0'                                                 15 16860015
CSOFF    DC    F'0'                    CSECT offset                  26 16870028
FMTR14   DC    A(0)                                                  04 16880004
FMTOLD14 DC    A(0)                                                  07 16890008
FMTNEW14 DC    A(0)                                                  07 16900008
DIFF14   DC    A(0)                                                  26 16910029
HDR14    DC    A(0)                                                  26 16920029
FMTSAV1  DC    7A(0)                                                 28 16930031
FMTSAV2  DC    7A(0)                                                 28 16940031
SAVEOLD  DC    A(0)                                                  04 16950004
SAVENEW  DC    A(0)                                                  04 16960004
STARTOLD DC    A(0)                                                  30 16970033
STARTNEW DC    A(0)                                                  30 16980033
GENDIFRG DC    16A(0)                                                28 16990031
GENDIFST DC    A(0)                                                  28 17000031
GENDIFLN DC    A(0)                                                  28 17010031
WRTDIF14 DC    A(0)                                                  28 17020031
PRMSTRT  DC    A(0)                                                  07 17030008
PRTR14   DC    A(0)                                                  07 17040008
CURDATE  DC    A(0)                                                  07 17050008
JULWRK2  DC    A(0)                                                  07 17060008
DCCNT    DC    PL2'+0'                                               10 17070011
DIFCNT   DC    PL2'+0'                                               17 17080018
NEWMBR   DC    CL8' '                                                32 17090035
MBRNAME  DC    CL8' '                                                   17100000
CSNAME   DC    CL8' '                                                   17110000
LOADLMD  DC    A(0)                                                     17120000
LODPRMAD DC    A(LODPRMLN)                                              17130000
LODPRMLN DC    AL2(0)                                                   17140000
LODPRM   DC    CL80' '                                               07 17150008
PRMOPT   DC    AL1(PRMOPTZR)           DEFAULT OPTIONS               07 17160008
PRMOPTSU EQU   X'80'                                                    17170000
PRMOPTDB EQU   X'40'                                                    17180000
PRMOPTZR EQU   X'20'                   Zero relocatable adcons       02 17190002
PRMOPTLS EQU   X'10'                   List DIFIN statements         25 17200027
PRMOPTR5 EQU   X'08'                   Return code = 5               25 17210027
FLAG     DC    X'00'                                                 04 17220004
FLAGHDR  EQU   X'80'                                                 04 17230004
FLAGDC   EQU   X'40'                                                 10 17240011
FLAGMAX  EQU   X'20'                                                 11 17250012
FLAGDIF  EQU   X'10'                                                 17 17260018
LINE     DC    CL133' '                                                 17270000
JULWRK4  DC    P'+365'                                                  17280000
         DC    P'+01'                                                   17290000
         DC    P'+31'                                                   17300000
         DC    P'+30'                                                   17310000
         DC    P'+31'                                                   17320000
         DC    P'+30'                                                   17330000
         DC    P'+31'                                                   17340000
         DC    P'+31'                                                   17350000
         DC    P'+30'                                                   17360000
         DC    P'+31'                                                   17370000
         DC    P'+30'                                                   17380000
         DC    P'+31'                                                   17390000
JULWRK6  DC    P'+28'                                                   17400000
JULTBL1  DC    P'+31'                                                   17410000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  17420000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            17430000
LNCT     DC    PL2'+99'                                                 17440000
PGCT     DC    PL2'+0'                                                  17450000
HD1      DC    CL133'1'                                                 17460000
         ORG   HD1+1                                                    17470000
HD1DATE  DC    C'            '                                          17480000
         DC    C' '                                                     17490000
HD1TOD   DC    C'HH:MM:SS'                                              17500000
         DC    C' '                                                     17510002
HD1VER   DC    C'Ver &VER'                                              17520002
         ORG   HD1+66-(24/2)                                            17530000
HD1DATA  DC    C'Compare Load Module CSECT'                             17540000
         ORG   HD1+133-8                                                17550000
HD1PG    DC    C'Page'                                                  17560002
HD1PGCT  DC    C' 123'                                                  17570000
         DC    0D'+0'                                                07 17580008
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X17590000
               RECFM=FBA,LRECL=133                                      17600000
DIFIN    DCB   DDNAME=DIFIN,MACRF=GL,DSORG=PS,                       14X17610015
               RECFM=FB,LRECL=80,EODAD=DFINRDED                      14 17620015
DIFOUT   DCB   DDNAME=DIFOUT,MACRF=PM,DSORG=PS,                      17X17630018
               RECFM=FB,LRECL=80                                     17 17640018
OLDLIB   DCB   DSORG=PO,MACRF=R,DDNAME=OLDLIB,EXLST=EXLST,           08X17650009
               RECFM=U,NCP=1                                         08 17660009
NEWLIB   DCB   DSORG=PO,MACRF=R,DDNAME=NEWLIB,EXLST=EXLST,           08X17670009
               RECFM=U,NCP=1                                         08 17680009
DCDCB    DCB   DDNAME=DC,MACRF=PM,DSORG=PS,                          10X17690011
               RECFM=FB,LRECL=80                                     10 17700011
EXLST    DC    AL1(128+7),AL3(LIBJFCB)                               08 17710009
LIBJFCB  DC    0D'0',XL176'0'                                        08 17720009
HEXTBL   DC    C'0123456789ABCDEF'                                   07 17730008
DMPTBLCH DC    256C'.'                                               27 17740030
         ORG   DMPTBLCH+C' '                                         27 17750030
         DC    C' '                                                  27 17760030
         ORG   DMPTBLCH+X'4A' Cent                                      17770000
         DC    X'4A4B4C4D4E4F50' vert bar and ampersand                 17780000
         ORG   DMPTBLCH+X'5A' exclamation                               17790000
         DC    X'5A5B5C5D5E5F6061'                                      17800000
         ORG   DMPTBLCH+X'6A'                                           17810000
         DC    X'6A6B6C6D6E6F'                                          17820000
         ORG   DMPTBLCH+X'7A'                                           17830000
         DC    X'7A7B7C7D7E7F'                                          17840000
         ORG   DMPTBLCH+C'a'                                            17850000
         DC    C'abcdefghi'                                             17860000
         ORG   DMPTBLCH+C'j'                                            17870000
         DC    C'jklmnopqr'                                             17880000
         ORG   DMPTBLCH+C's'                                            17890000
         DC    C'stuvwxyz'                                              17900000
         ORG   DMPTBLCH+C'A'                                            17910000
         DC    C'ABCDEFGHI'                                             17920000
         ORG   DMPTBLCH+C'J'                                            17930000
         DC    C'JKLMNOPQR'                                             17940000
         ORG   DMPTBLCH+C'S'                                            17950000
         DC    C'STUVWXYZ'                                              17960000
         ORG   DMPTBLCH+C'0'                                            17970000
         DC    C'0123456789'                                         07 17980008
         ORG   ,                                                     07 17990008
*                                                                    31 18000034
W#DMPRGS DS    16A                                                   31 18010034
W#DMPOFF DS    A                                                     31 18020034
W#DMPDUP DS    A                                                     31 18030034
W#DMPADS DS    A                                                     31 18040034
W#DMPFLG DS    X                                                     31 18050034
W#DMPFL1 EQU   X'80'                                                 31 18060034
W#DMPFLD EQU   X'40'                                                 31 18070034
*                                                                    31 18080034
W#DIAGRG DC    16A(0)                                                31 18090034
W#DIAGLN DC    CL133' '                                              31 18100034
*                                                                    31 18110034
DIFTBLST DC    A(0)                                                  14 18120015
DIFTBL   DC    1500D'0'                                              18 18130019
DIFTBLND EQU   *                                                     14 18140015
*                                                                    29 18150032
*        Difference Table                                            29 18160032
*                                                                    29 18170032
DIFENTDS DSECT ,                                                     29 18180032
DIFENTST DS    F                       Start of difference           29 18190032
DIFENTND DS    F                       End of difference             29 18200032
DIFENT   EQU   DIFENTDS,*-DIFENTDS                                   29 18210032
****************************************************************     08 18220009
*                                                              *     08 18230009
*        SYSTEM DSECTS                                         *     08 18240009
*                                                              *     08 18250009
****************************************************************     08 18260009
JFCB     DSECT ,                                                     08 18270009
         IEFJFCBN ,                                                  08 18280009
R0       EQU   0                                                        18290000
R1       EQU   1                                                        18300000
R2       EQU   2                                                        18310000
R3       EQU   3                                                        18320000
R4       EQU   4                                                        18330000
R5       EQU   5                                                        18340000
R6       EQU   6                                                        18350000
R7       EQU   7                                                        18360000
R8       EQU   8                                                        18370000
R9       EQU   9                                                        18380000
R10      EQU   10                                                       18390000
R11      EQU   11                                                       18400000
R12      EQU   12                                                       18410000
R13      EQU   13                                                       18420000
R14      EQU   14                                                       18430000
R15      EQU   15                                                       18440000
         END                                                            18450000
