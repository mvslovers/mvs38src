*********************************************************************** 00010000
*                                                                     * 00020000
* MODULE NAME                                                         * 00030000
*    LMDXRF38                                                         * 00040000
*                                                                     * 00050000
* ATTRIBUTES                                                          * 00060000
*    NOT RENTRANT                                                     * 00070000
*                                                                     * 00080000
* AUTHOR                                                              * 00090000
*    DAVE KREISS                                                      * 00100000
*                                                                     * 00110000
* FUNCTION                                                            * 00120000
*    READS DIRECTORY OF A DISTRIBUTION OR TARGET LIBRARY AND          * 00130000
*    PRODUCES RECORDS WHICH REPRESENT EACH LOAD MODULE AND ALL        * 00140008
*    ITS CSECTS.                                                      * 00150008
*                                                                     * 00160000
* JCL                                                                 * 00170000
*    //        EXEC PGM=LMDXRF38,PARM='parameters'                    * 00180000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00190000
*    //SYSLIB   DD  DSN=library,DISP=SHR                              * 00200008
*    //PRINTDD  DD  SYSOUT=*                                          * 00210005
*    //SYSUT2   DD  DSN=output data set,DISP=...                      * 00220008
*                                                                     * 00230000
* DD STATEMENTS                                                       * 00240000
*    STEPLIB       LOAD LIBRARY CONTAINING THE MODULE MAPLMD.         * 00250003
*    PRINTDD       DATA SET CONTAINING STATUS REPORT FROM MAPLMD.     * 00260005
*    SYSUT2        DATA SET CONTAINING DATA USED BY LMDRPT38.         * 00270003
*    SYSLIB        DATA SET CONTAINING LOAD MODULES.                  * 00280007
*                                                                     * 00290000
*  PARAMETERS:                                                        * 00300000
*    DEBUG       - PRODUCES SOME DEBUGGING INFO.                      * 00310000
*    LIB=ddname  - GENERATE THIS LIBTATY NAME INSTEAD FROM DSNAME.    * 00320010
*                                                                     * 00330000
*  Sample JCL:                                                        * 00340000
*    //XRF     EXEC PGM=LMDXRF38,PARM='DEBUG'                         * 00350005
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00360000
*    //SYSLIB   DD  DSN=MVSSRC.NEW.AOSD0,DISP=SHR                     * 00370007
*    //PRINTDD  DD  SYSOUT=*                                          * 00380005
*    //SYSUT2   DD  output data set                                   * 00390000
*                                                                     * 00400000
*                                                                     * 00410000
*********************************************************************** 00420000
*                                                                     * 00430000
* CHANGE LOG:                                                         * 00440000
*   DATE     AAA VV.VV DESCRIPTION                                    * 00450000
* 06/06/2015 DSK 01.01 CREATED                                        * 00460000
* 07/10/2015 DSK 01.02 USE MAPLMD TO GET LOAD MODULE MAP INFORMATION  * 00470005
* 05/24/2016 DSK 01.03 ADD PROBABLE OFFSET IN HEX AND DECIMAL         * 00480008
* 05/29/2016 DSK 01.04 ADD ACTUAL MODULE ADDRESS                      * 00490009
* 07/26/2017 DSK 01.05 ADD LIB= PARAMETER                             * 00500010
* 07/02/2023 DSK 01.06 Add reason code to MAPLMD error message        * 00510011
         LCLC   &VER                                                    00520000
&VER     SETC   '01.06'                                                 00530011
*                                                                     * 00540000
*********************************************************************** 00550000
****************************************************************        00560000
*                                                              *        00570000
*   PROGRAM INITIALIZATION                                     *        00580000
*                                                              *        00590000
****************************************************************        00600000
LMDXRF38 CSECT ,                                                        00610000
         USING LMDXRF38,R15                                             00620000
         B     BEGIN                                                    00630000
         DROP  R15                                                      00640000
         DC    AL1(L'PGMID)                                             00650000
PGMID    DC    C'LMDXRF38 - &VER &SYSDATE &SYSTIME'                     00660000
BEGIN    DC    0H'+0'                                                   00670000
         STM   R14,R12,12(R13)                                          00680000
         LR    R11,R15                                                  00690000
         LA    R12,2048(,R11)                                           00700000
         LA    R12,2048(,R12)                                           00710000
         USING LMDXRF38,R11,R12                                         00720000
         LA    R14,SAVEAREA                                             00730000
         ST    R13,4(,R14)                                              00740000
         ST    R14,8(,R13)                                              00750000
         LR    R13,R14                                                  00760000
         L     R10,0(,R1)                                               00770000
         BAL   R14,INIT                                                 00780000
*                                                                       00790000
         LOAD  EPLOC==CL8'MAPLMD'                                       00800000
         ST    R0,MAPLMD                                                00810005
*                                                                       00820000
         RDJFCB DIRDCB                                                  00830000
         CLI   LIB,C' '                                              05 00840010
         BNE   LIB50                                                 05 00850010
         LA    R0,44                                                    00860000
         LA    R1,DSNAME                                                00870000
         SR    R15,R15                                                  00880000
LIB10    DS    0H                                                       00890000
         CLI   0(R1),C' '                                               00900000
         BE    LIB30                                                    00910000
         CLI   0(R1),C'.'                                               00920000
         BNE   LIB20                                                    00930000
         LA    R15,1(,R1)                                               00940000
LIB20    DS    0H                                                       00950000
         LA    R1,1(,R1)                                                00960000
         BCT   R0,LIB10                                                 00970000
LIB30    DS    0H                                                       00980000
         LTR   R15,R15                                                  00990000
         BNZ   LIB40                                                    01000000
         MVC   LINE+1(18),=C'Invalid //LIB DSN='                        01010000
         MVC   LINE+19(44),DSNAME                                       01020000
         BAL   R14,PRT                                                  01030000
         LA    R15,8                                                    01040000
         B     EXITRC                                                   01050000
LIB40    DS    0H                                                       01060000
         MVC   LIB,0(R15)                                               01070000
LIB50    DS    0H                                                    05 01080010
         MVC   LINE+1(8),=C'Library='                                   01090000
         MVC   LINE+9(44),DSNAME                                        01100000
         BAL   R14,PRT                                                  01110000
         TM    FLAG,FLAGDBG                                             01120000
         BNO   LIBRD                                                    01130000
         MVC   LINE+1(6),=C'->LIB='                                     01140000
         MVC   LINE+7(8),LIB                                            01150000
         BAL   R14,PRT                                                  01160000
LIBRD    DS    0H                                                       01170000
         READ  DIRDECB,SF,DIRDCB,DIRENT                                 01180000
         CHECK DIRDECB                                                  01190000
         LA    R10,DIRENT                                               01200000
         LH    R9,DIRENT                                                01210000
         LA    R8,2                                                     01220000
LIBMBR   DS    0H                                                       01230000
         AR    R10,R8                                                   01240000
         SR    R9,R8                                                    01250000
         LTR   R9,R9                                                    01260000
         BNH   LIBRD                                                    01270000
         CLC   0(8,R10),=8X'FF'                                         01280000
         BE    LIBEOF                                                   01290000
         IC    R8,11(,R10)                                              01300000
         N     R8,=A(X'1F')                                             01310000
         SLL   R8,1                                                     01320000
         LA    R8,12(,R8)                                               01330000
         MVC   MEMBER,0(R10)                                            01340000
         AP    MBRCT,=P'+1'                                             01350000
         CLC   =CL8'SYSCATLG',MEMBER                                    01360000
         BNE   LIBNSYSC                                                 01370000
         CLC   =CL8'NUCLEUS',LIB                                        01380000
         BNE   LIBNSYSC                                                 01390000
         AP    MBRSKCT,=P'+1'                                           01400000
         TM    FLAG,FLAGDBG                                             01410000
         BNO   LIBMBR                                                   01420000
         MVC   LINE+1(13),=C'-> Processing'                             01430000
         MVC   LINE+15(8),MEMBER          '                             01440000
         MVC   LINE+24(9),=C'(skipped)'                                 01450000
         BAL   R14,PRT                                                  01460000
         B     LIBMBR                                                   01470000
LIBNSYSC DS    0H                                                       01480000
         TM    11(R10),X'80'           ALIAS ENTRY?                     01490000
         BNO   LIBNALIA                                                 01500000
         AP    MBRSKCT,=P'+1'                                           01510000
         TM    FLAG,FLAGDBG                                             01520000
         BNO   LIBMBR                                                   01530000
         MVC   LINE+1(13),=C'-> Processing'                             01540000
         MVC   LINE+15(8),MEMBER          '                             01550000
         MVC   LINE+24(17),=C'(skipped - alias)'                        01560000
         BAL   R14,PRT                                                  01570000
         B     LIBMBR                                                   01580000
LIBNALIA DS    0H                                                       01590000
         TM    FLAG,FLAGDBG                                             01600000
         BNO   LIBCTL                                                   01610000
         MVC   LINE+1(13),=C'-> Processing'                             01620000
         MVC   LINE+15(8),MEMBER          '                             01630000
         BAL   R14,PRT                                                  01640000
LIBCTL   DS    0H                                                       01650000
         AP    MBRPRCT,=P'+1'                                           01660000
* INVOKE MAPLMD                                                         01670000
         MVC   PRM,MEMBER                                               01680000
         LA    R1,PRMAD                                                 01690000
         L     R15,MAPLMD                                               01700005
         BALR  R14,R15                                                  01710000
* PROCESS MAPLMD RETURN CODE                                            01720000
         LTR   R15,R15                                                  01730001
         BZ    MAPOK                                                    01740001
         ST    R15,DWORD                                                01750001
         MVC   LINE+1(16),=C'-> MAPLMD  RC=X'''                         01760001
         UNPK  LINE+17(9),DWORD(5)                                      01770001
         TR    LINE+17(8),HEXTBL-240                                    01780001
         MVI   LINE+25,C''''                                            01790001
         ST    R0,DWORD                                              06 01800011
         MVC   LINE+27(5),=C'R0=X'''                                 06 01810011
         UNPK  LINE+32(9),DWORD(5)                                   06 01820011
         TR    LINE+32(8),HEXTBL-240                                 06 01830011
         MVI   LINE+40,C''''                                         06 01840011
         MVC   LINE+42(7),=C'MEMBER='                                06 01850011
         MVC   LINE+49(8),MEMBER                                     06 01860011
         BAL   R14,PRT                                                  01870001
         LA    R15,16                                                   01880002
         B     EXITRC                                                   01890001
MAPOK    DS    0H                                                       01900001
         LTR   R2,R1                                                    01910001
         BNZ   MAPIT                                                    01920001
         MVC   LINE+1(22),=C'-> MAPLMD R1=0 MEMBER='                    01930001
         MVC   LINE+23(8),MEMBER                                        01940001
         BAL   R14,PRT                                                  01950001
         B     LIBMBR                                                   01960001
* PROCESS MAP                                                           01970000
MAPIT    DS    0H                                                       01980001
         AP    LMDCNT,=P'+1'                                            01990002
         LR    R3,R2                                                    02000000
         L     R4,0(,R3)                                                02010000
         AR    R4,R3                                                    02020000
         LA    R3,4(,R3)                                                02030000
         USING CSTBL,R3                                                 02040000
BLDCTL   DS    0H                                                       02050001
         AP    CSCNT,=P'+1'                                             02060001
         MVC   LINE+1(8),LIB                                            02070000
         MVC   LINE+10(8),MEMBER                                        02080000
         MVC   LINE+20(8),=CL8'INCLUDE'                                 02090000
         MVC   LINE+30(8),CSNAME                                        02100000
         MVC   DWORD(3),CSLENG                                          02110000
         UNPK  LINE+40(7),DWORD(4)                                      02120001
         TR    LINE+40(6),HEXTBL-240                                    02130001
         MVI   LINE+46,C' '                                             02140000
         MVC   DWORD(3),CSADDR                                       04 02150009
         UNPK  LINE+47(7),DWORD(4)                                   04 02160009
         TR    LINE+47(6),HEXTBL-240                                 03 02170008
         MVI   LINE+53,C' '                                          03 02180008
         SR    R0,R0                                                 04 02190009
         ICM   R0,7,CSADDR                                           04 02200009
         CVD   R0,DWORD                                              04 02210009
         OI    DWORD+7,X'0F'                                         04 02220009
         UNPK  LINE+54(7),DWORD+4(4)                                 04 02230009
         BAL   R14,CTL                                               04 02240009
         SR    R0,R0                                                 03 02250008
         ICM   R0,7,CSLENG                                           03 02260008
         AH    R0,=H'+7'                                             03 02270008
         N     R0,=X'FFFFFFF8'                                       03 02280008
         AR    R6,R0                                                 03 02290008
         LA    R3,CSENTLN(,R3)                                          02300000
         CR    R3,R4                                                    02310000
         BL    BLDCTL                                                   02320000
         L     R0,0(,R2)                                                02330000
         FREEMAIN R,A=(R2),LV=(0)                                       02340001
         B     LIBMBR                                                   02350000
LIBEOF   DS    0H                                                       02360000
         MVC   LINE+1(14),=C'SYSLIB members'                            02370006
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02380000
         ED    LINE+20(10),MBRCT                                        02390000
         BAL   R14,PRT                                                  02400000
         MVC   LINE+1(15),=C'Members skipped'                           02410000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02420000
         ED    LINE+20(10),MBRSKCT                                      02430000
         BAL   R14,PRT                                                  02440000
         MVC   LINE+1(17),=C'Members processed'                         02450000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02460000
         ED    LINE+20(10),MBRPRCT                                      02470000
         BAL   R14,PRT                                                  02480000
         MVC   LINE+1(6),=C'CSECTS'                                     02490000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02500000
         ED    LINE+20(10),CSCNT                                        02510000
         BAL   R14,PRT                                                  02520000
         MVC   LINE+1(12),=C'Load Modules'                              02530000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02540000
         ED    LINE+20(10),LMDCNT                                       02550000
         BAL   R14,PRT                                                  02560000
         MVC   LINE+1(11),=C'LMD records'                               02570000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02580000
         ED    LINE+20(10),UT2CNT                                       02590000
         BAL   R14,PRT                                                  02600000
         CP    LMDNECNT,=P'+0'                                          02610000
         BE    END010                                                   02620000
         MVC   LINE+1(12),=C'Not Editable'                              02630000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     02640000
         ED    LINE+20(10),LMDNECNT                                     02650000
         BAL   R14,PRT                                                  02660000
END010   DS    0H                                                       02670000
         L     R15,RC                                                   02680000
EXITRC   DS    0H                                                       02690000
         LR    R2,R15                                                   02700000
         CLOSE (REPORT,,DIRDCB,,SYSUT2)                                 02710000
         L     R13,4(,R13)                                              02720000
         L     R14,12(,R13)                                             02730000
         LR    R15,R2                                                   02740000
         LM    R2,R12,28(R13)                                           02750000
         BR    R14                                                      02760000
*                                                                       02770000
*                                                                       02780000
*                                                                       02790000
QUIT     DS    0H                                                       02800000
         L     R13,4(,R13)                                              02810000
         LM    R14,R12,12(R13)                                          02820000
         LA    R15,16                                                   02830000
         BR    R14                                                      02840000
*********************************************************************** 02850000
*                                                                     * 02860000
*        Write CSECT information                                      * 02870000
*                                                                     * 02880000
*********************************************************************** 02890000
CTL      DS    0H                                                       02900000
         ST    R14,CTLR14                                               02910000
         AP    UT2CNT,=P'+1'                                            02920000
         PUT   SYSUT2,LINE+1                                            02930000
         TM    FLAG,FLAGDBG                                             02940000
         BNO   CTL010                                                   02950000
         BAL   R14,PRT                                                  02960000
CTL010   DS    0H                                                       02970000
         MVI   LINE,C' '                                                02980000
         MVC   LINE+1(L'LINE-1),LINE                                    02990000
         L     R14,CTLR14                                               03000000
         BR    R14                                                      03010000
*********************************************************************** 03020000
*                                                                     * 03030000
*        Initialization                                               * 03040000
*                                                                     * 03050000
*********************************************************************** 03060000
INIT     DS    0H                                                       03070000
         ST    R14,INITR14                                              03080000
         OPEN  (SYSUT2,(OUTPUT),DIRDCB,(INPUT),REPORT,(OUTPUT))         03090002
         TM    REPORT+48,16                                             03100002
         BZ    QUIT                                                     03110002
         TM    SYSUT2+48,16                                             03120002
         BZ    QUIT                                                     03130002
         TM    DIRDCB+48,X'10'                                          03140002
         BZ    QUIT                                                     03150002
         TIME  BIN                     GET CURRENT DATE AND TIME        03160000
         ST    R1,CURDATE              SAVE DATE                        03170000
         SRDL  R0,32                   GET DOUBLE WORD TIME             03180000
         D     R0,=F'+6000'            GET MINUTES                      03190000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     03200000
         SLR   R0,R0                   CLEAR                            03210000
         D     R0,=F'+60'              GET HOURS / MINS                 03220000
         MH    R0,=H'+10000'           GET MINUTES                      03230000
         AR    R15,R0                  ADD TO GET MM:SS.TH              03240000
         M     R0,=F'+1000000'         GET HOURS                        03250000
         AR    R1,R15                  GET HH:MM:SS.TH                  03260000
         CVD   R1,DWORD                GET TIME TO DECIMAL              03270000
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   03280000
         ED    TIMWRK4,DWORD+3         EDIT TIME                        03290000
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        03300000
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  03310000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    03320000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         03330000
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        03340000
         DP    DWORD,=P'+4'            DIVIDE BY 4                      03350000
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              03360000
         BNZ   JULCVT2                  NO                              03370000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    03380000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         03390000
JULCVT2  DS    0H                                                       03400000
         LA    R1,JULTBL1              POINT TO JANUARY                 03410000
         SLR   R2,R2                   SET COUNTER                      03420000
JULCVT4  DS    0H                                                       03430000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              03440000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  03450000
         BCTR  R1,0                    POINT TO NEXT MONTH              03460000
         BCTR  R1,0                    POINT TO NEXT MONTH              03470000
         LA    R2,3(,R2)               UP INDEX                         03480000
         B     JULCVT4                 LOOP                             03490000
JULCVT6  DS    0H                                                       03500000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                03510000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    03520000
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       03530000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     03540000
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         03550000
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   03560000
         LA    R1,HD1DATE+6            SET POINTER                      03570000
         BNE   JULCVT7                  NO                              03580000
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 03590000
         BCTR  R1,0                    DROP POINTER                     03600000
JULCVT7  DS    0H                                                       03610000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  03620000
         TM    CURDATE,1               YEAR 2000?                       03630000
         BNO   JULCVT8                  NO, CONTINUE                    03640000
         MVC   2(2,R1),=C'20'          Y2K                              03650000
JULCVT8  DS    0H                                                       03660000
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      03670000
         MVC   4(2,R1),DWORD           GET YEAR                         03680000
         MVC   LINE+1(8),=C'Version='  Move version literal             03690000
         MVC   LINE+9(L'PGMID),PGMID   Move version                     03700000
         BAL   R14,PRT                 PRINT A LINE                     03710000
         MVC   LINE+1(5),=C'PARM='     MOVE PARAMETER INFO LITERAL      03720000
         CLI   1(R10),0                ANY PARAMETER?                   03730000
         BE    PRMPRT                  NO, SKIP MOVE                    03740000
         LH    R1,0(,R10)              GET PARMETER LENGTH              03750000
         BCTR  R1,0                    MAKE MACHINE LENGTH              03760000
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE          03770000
         B     PRMPRT                                                   03780000
PRMMVC   MVC   LINE+6(0),2(R10)        EXECUTED PARM MOVE               03790000
PRMPRT   DS    0H                                                       03800000
         BAL   R14,PRT                 PRINT A LINE                     03810000
         LH    R2,0(,R10)              GET PARM LENGTH                  03820000
         LA    R10,2(,R10)             SKIP LENGTH                      03830000
         ST    R10,PRMSTART            SAVE PARM START                  03840000
PRMSCN   DS    0H                                                       03850000
         LTR   R2,R2                   END OF PARM?                     03860000
         BZ    PRMEND                  YES, PARM PARSED                 03870000
         CLI   0(R10),C','             SEPERATOR?                       03880000
         BNE   PRMCHK                  NO, CHECK VALUES                 03890000
         LA    R10,1(,R10)             SKIP COMMA                       03900000
         BCTR  R2,0                    DECREMENT LENGTH                 03910000
         B     PRMSCN                  CONTINUE SCAN                    03920000
PRMCHK   DS    0H                                                       03930000
         CH    R2,=H'+5'                                                03940000
         BL    PRMERR                                                   03950000
         CLC   =C'DEBUG',0(R10)        DEBUG?                           03960000
         BE    PRMDBG                  Yes, handle it                   03970000
         CLC   =C'LIB=',0(R10)         LIB=?                         05 03980010
         BE    PRMLIB                  Yes, handle it                05 03990010
         B     PRMERR                  Error                            04000000
PRMDBG   DS    0H                                                       04010000
         OI    FLAG,FLAGDBG            SET DEBUG                        04020000
         LA    R10,5(,R10)             SKIP VALUE                       04030000
         SH    R2,=H'5'                DECREMENT LENGTH                 04040000
         B     PRMSCNC                 CONTINUE SCAN                    04050000
PRMLIB   DS    0H                                                    05 04060010
         LA    R10,4(,R10)             Skip LIB=                     05 04070010
         SH    R2,=H'4'                Decrement length              05 04080010
         LA    R0,8                    LIB= maximum length           05 04090010
         LA    R14,LIB                 Library name area             05 04100010
PRMLIB1  DS    0H                                                    05 04110010
         CLI   0(R10),C','             Eend of LIB= value?           05 04120010
         BE    PRMLIB2                 Yes, check for none entered   05 04130010
         MVC   0(1,R14),0(R10)         Copy valie to library         05 04140010
         LA    R10,1(,R10)             Next PARM=                    05 04150010
         SH    R2,=H'1'                Decrement length              05 04160010
         BZ    PRMSCNC                 End of PARM=                  05 04170010
         LA    R14,1(,R14)             Next library                  05 04180010
         BCT   R0,PRMLIB1              Look at only 8 characters     05 04190010
PRMLIB2  DS    0H                                                    05 04200010
         CLI   LIB,C' '                Anything in library?          05 04210010
         BE    PRMERR                  No, error                     05 04220010
         B     PRMSCNC                 Continue PARM= scan           05 04230010
PRMSCNC  DS    0H                                                       04240000
         LTR   R2,R2                   END OF PARM?                     04250000
         BZ    PRMEND                  YES, PARM PARSED                 04260000
         CLI   0(R10),C','             DELIMITER?                       04270000
         BE    PRMSCN                  YES, HANDLE IT                   04280000
PRMERR   DS    0H                                                       04290000
         LR    R1,R10                  CURRENT POSITION                 04300000
         S     R1,PRMSTART             LESS START                       04310000
         LA    R1,LINE+6(R1)           SET LOCATION OF ERROR            04320000
         MVI   0(R1),C'*'              MARK WHERE ERROR IS              04330000
         BAL   R14,PRT                 PRINT A LINE                     04340000
         MVC   LINE(19),=C' Parameters invalid'                         04350000
         BAL   R14,PRT                 PRINT A LINE                     04360000
         LA    R15,8                   ERROR RC                         04370000
         B     EXITRC                  ERROR                            04380000
PRMEND   DS    0H                                                       04390000
         L     R14,INITR14                                              04400000
         BR    R14                     RETURN TO CALLER                 04410000
*********************************************************************** 04420000
*                                                                     * 04430000
*            WRITE PRINT LINE                                         * 04440000
*                                                                     * 04450000
*********************************************************************** 04460000
PRT      DS    0H                                                       04470000
         ST    R14,PRTR14                                               04480000
         CP    LNCT,=P'+60'            END OF PAGE                      04490000
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   04500000
PRTHDRS  DS    0H                                                       04510000
         AP    PGCT,=P'+1'             COUNT PAGES                      04520000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  04530000
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  04540000
         PUT   REPORT,HD1              PRINT HEADING 1                  04550000
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  04560000
         MVI   LINE,C'0'               SKIP AFTER HEADING               04570000
PRTCHK   DS    0H                                                       04580000
         CLI   LINE,C'+'               OVERPRINT ?                      04590000
         BE    PRTLINE                  YES, DON'T COUNT                04600000
         CLI   LINE,C'1'               NEW LINE ?                       04610000
         BE    PRTHDRS                  YES, PRINT HEADER               04620000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         04630000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            04640000
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         04650000
         BE    PRTLINE2                 YES, GO CHECK IF FIT            04660000
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         04670000
         BE    PRTLINE3                 YES, GO CHECK IF FIT            04680000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       04690000
PRTLINE1 DS    0H                                                       04700000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                04710000
         B     PRTVFY                  GO SEE IF IT WILL FIT            04720000
PRTLINE2 DS    0H                                                       04730000
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                04740000
         B     PRTVFY                  GO SEE IF IT WILL FIT            04750000
PRTLINE3 DS    0H                                                       04760000
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                04770000
PRTVFY   DS    0H                                                       04780000
         CP    LNCT,=P'+60'            OVERFLOW ?                       04790000
         BH    PRTHDRS                  YES, FORCE HEADER               04800000
PRTLINE  DS    0H                                                       04810000
         PUT   REPORT,LINE             PRINT A LINE                     04820000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          04830000
         MVC   LINE+1(L'LINE-1),LINE                                    04840000
         L     R14,PRTR14                                               04850000
         BR    R14                     RETURN TO CALLER                 04860000
*********************************************************************** 04870000
*                                                                     * 04880000
*        DUMP DATA                                                    * 04890000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 04900000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 04910000
*                                                                     * 04920000
*********************************************************************** 04930000
DMP      DS    0H                                                       04940000
         STM   R0,R15,DMPREGS          SAVE REGISTERS                   04950000
         LR    R3,R1                   GET ADDRESS TO DUMP              04960000
         LR    R4,R0                   GET LENGTH                       04970000
         XC    DMPOFF,DMPOFF           SAVE OFFSET FOR DUMP             04980000
         MVI   DMPFLAG,DMPFIRST        FIRST LINE                       04990000
DMPDMPLP DS    0H                                                       05000000
         LTR   R4,R4                   ANY DATA TO DUMP ?               05010000
         BZ    DMPHEXXT                 YES, ALL DONE                   05020000
         TM    DMPFLAG,DMPFIRST        FIRST LINE?                      05030000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   05040000
         LA    R0,32                   DEFAULT LENGTH                   05050000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          05060000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           05070000
         LR    R14,R3                  GET CURRENT INPUT AREA           05080000
         SR    R14,R0                  BACK TO PREVIOUS AREA            05090000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       05100000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            05110000
         SR    R4,R0                   REDUCE LENGTH TO DO              05120000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           05130000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       05140000
         L     R14,DMPOFF              GET CURRENT OFFSET               05150000
         ST    R14,DUPFIRST            SAVE AS FIRST OFFSET             05160000
         OI    DMPFLAG,DMPDUP          SET DUPLICATE                    05170000
         B     DMPNXTLN                CONTINUE                         05180000
DMPDUPCK DS    0H                                                       05190000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           05200000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      05210000
         MVC   LINE+7(5),=C'Lines'     MOVE LITERAL                     05220000
         LA    R2,LINE+13              OUTPUT AREA ADDRESS              05230000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        05240000
         LA    R15,2                   CONVERT 4 BYTES                  05250000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            05260000
         MVI   LINE+17,C'-'            THRU LITERAL                     05270000
         L     R1,DMPOFF               GET CURRENT OFFSET               05280000
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        05290000
         ST    R1,DUPFIRST             SAVE FOR DUMPING                 05300000
         LA    R2,LINE+18              OUTPUT AREA ADDRESS              05310000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        05320000
         LA    R15,2                   CONVERT 4 BYTES                  05330000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            05340000
         MVC   LINE+23(13),=C'Same as above' MOVE LITERAL               05350000
         BAL   R14,PRT                 PRINT A LINE                     05360000
         NI    DMPFLAG,255-DMPDUP      RESET DUPLICATE IN PROGRESS      05370000
DMPALIN  DS    0H                                                       05380000
         ST    R3,DWORD                Save address                     05390005
         LA    R2,LINE+1               OUTPUT AREA ADDRESS              05400000
         LA    R1,DWORD                ADDRESS OF ADDRESS               05410005
         LA    R15,4                   CONVERT 8 BYTES                  05420000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            05430000
         LA    R2,1(,R2)               SKIP 1 BETWEEN ADDRESS & OFFSET  05440000
         LA    R1,DMPOFF+2             ADDRESS OF OFFSET TO DUMP        05450000
         LA    R15,2                   CONVERT 4 BYTES                  05460000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            05470000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     05480000
         LR    R1,R3                   ADDRESS OF DATA                  05490000
         LA    R5,32                   DEFAULT LENGTH                   05500000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          05510000
         BH    DMPDODMP                 YES, USE 32                     05520000
         LR    R5,R4                   USE WHAT IS LEFT                 05530000
DMPDODMP DS    0H                                                       05540000
         SR    R4,R5                   REDUCE AMOUNT TO DO              05550000
         MVI   LINE+89,C'*'            BOX IN DISPLAY PORTION           05560000
         BCTR  R5,0                    MAKE ZERO BASED                  05570000
         EX    R5,DMPMVC               DO MOVE                          05580000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          05590000
         LA    R5,1(,R5)               RESTORE LENGTH                   05600000
         MVI   LINE+122,C'*'           COMPLETE BOX                     05610000
DMPDMPHX DS    0H                                                       05620000
         LA    R15,4                   4 BYTES TO PROCESS               05630000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           05640000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               05650000
         LR    R15,R5                  USE LENGTH LEFT                  05660000
DMPDMPIT DS    0H                                                       05670000
         SR    R5,R15                  REDUCE AMOUNT TO DO              05680000
         BAL   R14,DMPDSP              CONVERT DATA                     05690000
         LA    R2,1(,R2)               SKIP 1 BYTE                      05700000
         LA    R0,LINE+43              HALFWAY POINT ADDRESS            05710000
         CR    R0,R2                   AT HALFWAY POINT?                05720000
         BNE   DMPDMPNX                 NO, CONTINUE                    05730000
         LA    R2,1(,R2)               SKIP 1 BYTE                      05740000
DMPDMPNX DS    0H                                                       05750000
         LTR   R5,R5                   ANY LEFT TO DO ?                 05760000
         BH    DMPDMPHX                 YES, GO DO IT                   05770000
         BAL   R14,PRT                 PRINT A LINE                     05780000
DMPNXTLN DS    0H                                                       05790000
         L     R1,DMPOFF               GET OFFSET IN RECORD             05800000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       05810000
         ST    R1,DMPOFF               SAVE OFFSET IN RECORD            05820000
         LA    R3,32(,R3)              NEXT INPUT AREA                  05830000
         NI    DMPFLAG,255-DMPFIRST    NOT FIRST LINE                   05840000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             05850000
DMPHEXXT DS    0H                                                       05860000
         LM    R0,R15,DMPREGS          RESTORE CALLERS REGS             05870000
         BR    R14                     EXIT . . .                       05880000
DMPMVC   MVC   LINE+90(0),0(R1)        <<< EXECUTED >>>                 05890000
DMPTR    TR    LINE+90(0),DMPTBLCH     <<< EXECUTED >>>                 05900000
*                                                                       05910000
*                                                                       05920000
*                                                                       05930000
DMPDSP   DS    0H                                                       05940000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               05950000
         NI    0(R2),X'0F'             REMOVE ZONE                      05960000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             05970000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             05980000
         TR    0(2,R2),=C'0123456789ABCDEF' TRANSLATE TO HEX            05990000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        06000000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         06010000
         BCT   R15,DMPDSP              LOOP THRU DATA                   06020000
         BR    R14                     EXIT . . .                       06030000
*                                                                       06040002
*                                                                       06050002
*                                                                       06060002
         LTORG ,                                                        06070000
DMPTBLCH DC    CL256' '                                                 06080002
         ORG   DMPTBLCH+X'4A' Cent                                      06090002
         DC    X'4A4B4C4D4E4F50' vert bar and ampersand                 06100002
         ORG   DMPTBLCH+X'5A' exclamation                               06110002
         DC    X'5A5B5C5D5E5F6061'                                      06120002
         ORG   DMPTBLCH+X'6A'                                           06130002
         DC    X'6A6B6C6D6E6F'                                          06140002
         ORG   DMPTBLCH+X'7A'                                           06150002
         DC    X'7A7B7C7D7E7F'                                          06160002
         ORG   DMPTBLCH+C'a'                                            06170002
         DC    C'abcdefghi'                                             06180002
         ORG   DMPTBLCH+C'j'                                            06190002
         DC    C'jklmnopqr'                                             06200002
         ORG   DMPTBLCH+C's'                                            06210002
         DC    C'stuvwxyz'                                              06220002
         ORG   DMPTBLCH+C'A'                                            06230002
         DC    C'ABCDEFGHI'                                             06240002
         ORG   DMPTBLCH+C'J'                                            06250002
         DC    C'JKLMNOPQR'                                             06260002
         ORG   DMPTBLCH+C'S'                                            06270002
         DC    C'STUVWXYZ'                                              06280002
         ORG   DMPTBLCH+C'0'                                            06290002
         DC    C'0123456789'                                            06300002
         ORG                                                            06310002
HEXTBL   DC    C'0123456789ABCDEF'                                      06320002
*                                                                       06330000
*                                                                       06340000
*                                                                       06350000
SAVEAREA DC    18A(0)                                                   06360000
DMPREGS  DC    16A(0)                                                   06370000
DMPOFF   DS    A                                                        06380000
DUPFIRST DS    A                                                        06390000
DMPFLAG  DC    X'00'                                                    06400000
DMPFIRST EQU   X'80'                                                    06410000
DMPDUP   EQU   X'40'                                                    06420000
DWORD    DC    D'+0'                                                    06430000
INITR14  DS    A(0)                                                     06440000
CTLR14   DC    A(0)                                                     06450000
PRTR14   DC    A(0)                                                     06460000
RC       DC    A(0)                                                     06470000
PRMSTART DC    A(0)                                                     06480000
LMDNECNT DC    PL4'+0'                                                  06490000
LMDCNT   DC    PL4'+0'                                                  06500000
CSCNT    DC    PL4'+0'                                                  06510000
UT2CNT   DC    PL4'+0'                                                  06520000
MBRCT    DC    PL4'+0'                                                  06530000
MBRSKCT  DC    PL4'+0'                                                  06540000
MBRPRCT  DC    PL4'+0'                                                  06550000
FLAG     DC    X'00'                                                    06560000
FLAGDBG  EQU   X'80'                                                    06570000
LINE     DC    CL133' '                                                 06580000
CURDATE  DC    A(0)                                                     06590000
JULWRK2  DC    A(0)                                                     06600000
JULWRK4  DC    P'+365'                                                  06610000
         DC    P'+01'                                                   06620000
         DC    P'+31'                                                   06630000
         DC    P'+30'                                                   06640000
         DC    P'+31'                                                   06650000
         DC    P'+30'                                                   06660000
         DC    P'+31'                                                   06670000
         DC    P'+31'                                                   06680000
         DC    P'+30'                                                   06690000
         DC    P'+31'                                                   06700000
         DC    P'+30'                                                   06710000
         DC    P'+31'                                                   06720000
JULWRK6  DC    P'+28'                                                   06730000
JULTBL1  DC    P'+31'                                                   06740000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  06750000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            06760000
LNCT     DC    PL2'+99'                                                 06770000
PGCT     DC    PL2'+0'                                                  06780000
HD1      DC    CL133'1'                                                 06790000
         ORG   HD1+1                                                    06800000
HD1DATE  DC    C'            '                                          06810000
         DC    C' '                                                     06820000
HD1TOD   DC    C'HH:MM:SS'                                              06830000
         DC    C' '                                                     06840004
HD1VER   DC    C'Ver &VER'                                              06850004
         ORG   HD1+66-(35/2)                                            06860000
HD1DATA  DC    C'Load Module to CSECT Cross Reference'                  06870000
         ORG   HD1+133-8                                                06880000
HD1PG    DC    C'Page'                                                  06890000
HD1PGCT  DC    C' 123'                                                  06900000
         ORG   ,                                                        06910000
REPORT   DCB   DDNAME=REPORT,MACRF=PM,DSORG=PS,                        *06920002
               RECFM=FBA,LRECL=133                                      06930000
SYSUT2   DCB   DDNAME=SYSUT2,MACRF=PM,DSORG=PS,                        *06940002
               RECFM=FB,LRECL=80                                        06950000
DIRDCB   DCB   DDNAME=SYSLIB,MACRF=R,DSORG=PS,DEVD=DA,                 *06960002
               RECFM=F,BLKSIZE=256,EXLST=EXLST,EODAD=LIBEOF             06970002
LIB      DC    CL8' '                                                   06980000
*                                                                       06990000
MAPLMD   DC    A(0)                                                     07000005
PRMAD    DC    A(PRMLN)                                                 07010002
PRMLN    DC    AL2(8)                                                   07020002
PRM      DC    CL8' '                                                   07030002
*                                                                       07040000
MEMBER   DC    CL8' '                                                   07050000
DIRENT   DC    32D'+0'                                                  07060000
*                                                                       07070000
EXLST    DC    AL1(128+7),AL3(INJFCB)                                   07080000
*                                                                       07090000
*        J. F. C. B.                                                    07100000
*                                                                       07110000
INJFCB   DC    0D'0'                                                    07120000
         DC    XL176'00'                                                07130000
         ORG   INJFCB                                                   07140000
DSNAME   DS    CL44                                                     07150000
ELNAME   DS    CL8                                                      07160000
JFCBTSDM DS    B                                                        07170000
         DS    XL19                                                     07180000
JFCBMASK DS    8X                                                       07190000
JFCBCRDT DS    XL3                                                      07200000
JFCBXPDT DS    XL3                                                      07210000
JFCBIND1 DS    X                                                        07220000
JFCBIND2 DS    X                                                        07230000
         DS    6X                                                       07240000
JFCBDEN  DS    X                                                        07250000
         DS    5X                                                       07260000
RECFM    DS    B                                                        07270000
         DS    B                                                        07280000
BLKSIZE  DS    H                                                        07290000
LRECL    DS    H                                                        07300000
         DS    XL11                                                     07310000
NOVOLSER DS    X                                                        07320000
VOLSERS  DS    5CL6                                                     07330000
         ORG   ,                                                        07340000
*                                                                       07350000
*                                                                       07360000
*                                                                       07370000
CSTBL    DSECT ,                       CSECT TABLE                      07380000
CSNAME   DS    CL8                     CSECT NAME                       07390000
CSLENG   DS    XL3                     LENGTH OF CSECT                  07400000
CSADDR   DS    XL3                     ADDRESS OF CSECT              04 07410009
CSENTLN  EQU   *-CSTBL                 LENGTH OF CSECT ENTRY            07420000
R0       EQU   0                                                        07430000
R1       EQU   1                                                        07440000
R2       EQU   2                                                        07450000
R3       EQU   3                                                        07460000
R4       EQU   4                                                        07470000
R5       EQU   5                                                        07480000
R6       EQU   6                                                        07490000
R7       EQU   7                                                        07500000
R8       EQU   8                                                        07510000
R9       EQU   9                                                        07520000
R10      EQU   10                                                       07530000
R11      EQU   11                                                       07540000
R12      EQU   12                                                       07550000
R13      EQU   13                                                       07560000
R14      EQU   14                                                       07570000
R15      EQU   15                                                       07580000
         END                                                            07590000
