         MACRO                                                          00000100
         HEXIT &TO,&FROM,&LEN                                           00000200
         UNPK  &TO.(&LEN*2+1),&FROM.(&LEN+1)                            00000300
         TR    &TO.(&LEN*2),HEXTBL-240                                  00000400
         MVC   &TO+&LEN*2,C' '                                          00000500
         MEND                                                           00000600
         MACRO                                                          00000700
&L       TRC                                                            00000800
&L       DS    0H                                                       00000900
         STM   R0,R15,TRCRGS                                            00001000
         MVC   LINE+1(8),=CL8'&L'                                       00001100
         BAL   R14,PRT                                                  00001200
         LM    R0,R15,TRCRGS                                            00001300
         MEND                                                           00001400
         MACRO                                                          00001500
&L       DS0H                                                           00001600
&L       DS    0H                                                       00001700
         STM   R0,R15,TRCRGS                                            00001800
         MVC   LINE+1(8),=CL8'&L'                                       00001900
         MVC   LINE+10(1),CONTINCM                                      00002000
         MVI   LINE+12,C'>'                                             00002100
         MVC   LINE+13(20),0(R3)                                        00002200
         MVI   LINE+33,C'<'                                             00002300
         BAL   R14,PRT                                                  00002400
*        MVC   LINE+1(8),=CL8'&L'                                       00002500
*        BAL   R14,PRT                                                  00002600
*        MVC   LINE+1(80),LONGSTMT                                      00002700
*        BAL   R14,PRT                                                  00002800
*        MVC   LINE+1(80),LONGSTMT+80                                   00002900
*        BAL   R14,PRT                                                  00003000
**       MVI   LINE+1,C'>'                                              00003100
**       MVC   LINE+2(20),0(R3)                                         00003200
**       MVI   LINE+22,C'<'                                             00003300
**       BAL   R14,PRT                                                  00003400
*        MVC   LINE+1(L'CARD),0(R2)                                     00003500
*        MVC   LINE+82(13),=C'Old statement'                            00003600
*        BAL   R14,PRT                                                  00003700
*        LR    R1,R3                                                    00003800
*        SR    R1,R2                                                    00003900
*        LA    R1,LINE+1(R1)                                            00004000
*        MVI   0(R1),C'*'                                               00004100
*        BAL   R14,PRT                                                  00004200
*        MVC   LINE+1(81),NEWSTMT                                       00004300
*        MVC   LINE+82(13),=C'New statement'                            00004400
*        BAL   R14,PRT                                                  00004500
*        LR    R1,R7                                                    00004600
*        S     R1,=A(NEWSTMT)                                           00004700
*        LA    R1,LINE+1(R1)                                            00004800
*        MVI   0(R1),C'*'                                               00004900
*        BAL   R14,PRT                                                  00005000
         LM    R0,R15,TRCRGS                                            00005100
         MEND                                                           00005200
*                                                                       00005300
* DETECTS MACRO REFERENCES BASED UPON THE PREFIX SPECIFIED              00005400
* OPTIONAL SYNONYM RESULTS IN THAT LABEL IS BASE OF DSECT               00005500
*                                                                       00005600
MACTBDS  DSECT ,                                                        00005700
MACTBNML DS    AL2                     MACRO PREFIX LENGTH              00005800
MACTBNM  DS    CL8                     MACRO PREFIX                     00005900
MACTBSYL DS    AL2                     MACRO PREFIX SYNONYM LENGTH      00006000
MACTBSY  DS    CL8                     MACRO PREFIX SYNONYM             00006100
MACTBNX  EQU   *                                                        00006200
MACTB    EQU   MACTBDS,*-MACTBDS                                        00006300
*                                                                       00006400
* DON'T CONVERT THESE LABELS.  WHEN SEEN THE LABEL IS LEFT UNCHANGED    00006500
*                                                                       00006600
SKPTBDS  DSECT ,                                                        00006700
SKPTBNML DS    AL2                     LABEL LENGTH                     00006800
SKPTBNM  DS    CL8                     LABEL NOT TO BE CONVERTED        00006900
SKPTBNX  EQU   *                                                        00007000
SKPTB    EQU   SKPTBDS,*-SKPTBDS                                        00007100
*                                                                       00007200
* INSERT CARD IMAGE BEFORE END STATEMENT.  USED TO GENERATE DSECTS.     00007300
* ? THE DSECT PREFIX IS USED TO DETERMINE IF THE DSECT IS REFERENCED    00007400
* THE DSECT USED FLAG IS TURNED ON DURING SOURCE PARSING WHEN           00007500
* A REFERENCE TO THE DSECT IS DETECTED.                                 00007600
*                                                                       00007700
INSTBDS  DSECT ,                                                        00007800
INSTBPFL DS    AL2                     PREFIX NAME LENGTH               00007900
INSTBPFX DS    CL8                     DSECT PREFIX                     00008000
INSTBUSD DS    CL1                     Y/N/D=DSECT USED OR NOT AND DONE 00008100
INSTBCRD DS    CL60                    INSERTED CARD                    00008200
INSTBNX  EQU   *                                                        00008300
INSTB    EQU   INSTBDS,*-INSTBDS                                        00008400
*                                                                       00008500
* CHANGE TABLE FOR EXAMPLE TYPICIAL CODE CONTAINS:                      00008600
*                 TM    UCB3TAPE(UCBPTR),B'10000000'                    00008700
*        UCB DSECT CONTAINS:                                            00008800
*        UCBTBYT3 DS  .....                                             00008900
*        UCB3TAPE EQU .....                                             00009000
*        TABLE ENTRY WAS SPECIFIED AS =UCB3TAPE=UCBTBYT3                00009100
*        UCB3TAPE IS AN EQUATE AND IS CHANGED UCBTBYT3 AND LATER        00009200
*        THE FIELD UCBTBYT3 IS UPDATED TO INCLUDE -UCB RESULTING IN:    00009300
*                 TM    UCBTBYT3-UCB(UCBPTR),B'10100000'                00009400
*        SPECIAL IMMEDIATE OPCODE CONVERSION MAKES ADDITIONAL CHANGES:  00009500
*                 TM    UCBTBYT3-UCB(UCBPTR),UCB3TAPE                   00009600
*        THERE ARE SPECIAL CASES WHICH AREN'T CAUGH AND MAY NEED SOME   00009700
*        TWEEKING.  FOR EXAMPLE:                                        00009800
*                 IF UCB3TAPE='1'B|UCB3DACC='1'B                        00009900
*             GENERATES                                                 00010000
*                 TM    UCB3TAPE(UCBPTR),B'10100000'                    00010100
*             B'10100000' IS REALLY BOTH UCB3TAPE AND UCB3DACC          00010200
*                                                                       00010300
CHGTBDS  DSECT ,                                                        00010400
CHGTBNML DS    AL2                     LABEL NAME LENGTH                00010500
CHGTBNM  DS    CL8                     LABEL NAME                       00010600
CHGTBNNL DS    AL2                     LABEL NEW NAME LENGTH            00010700
CHGTBNN  DS    CL16                    LABEL NEW NAME                   00010800
CHGTBNX  EQU   *                                                        00010900
CHGTB    EQU   CHGTBDS,*-CHGTBDS                                        00011000
*                                                                       00011100
* REGISTER EQUATE TABLE USED TO CONVERT ALL EQUATES TO RNN EQUATES      00011200
*        EXAMPLE: RTMADDR  EQU   @04                                    00011300
*        THE ABOVE EQUATE COMMENTED OUT AND                             00011400
*        ANY RTMADDR USAGE BECOMES R4 AND                               00011500
*                                                                       00011600
REGTBDS  DSECT ,                                                        00011700
REGNML   DS    AL2                     EQUATED REG NAME LENGTH          00011800
REGNM    DS    CL8                     EQUATE LABEL                     00011900
REGREG   DS    CL2                     EQUATED TO THIS REGISTER 0-15    00012000
REGTBNX  EQU   *                                                        00012100
REGTB    EQU   REGTBDS,*-REGTBDS                                        00012200
*                                                                       00012300
* @NMnnnnn delete and substitute table                                  00012400
*        EXAMPLE: @NM00049 EQU   CVTFIX+248                             00012500
*        THE ABOVE EQUATE COMMENTED OUT FOR THE TIME BEING              00012600
*        LATER SUBSTITUTION OF THE EQUATED VALUE CAN BE CODED           00012700
*                                                                       00012800
NMTBDS   DSECT ,                                                        00012900
NMTBNM   DS    CL8                     EQUATE LABEL ie: @NM00049        00013000
NMTBVLLN DS    CL2                     EQUATED VALUE LENGTH             00013100
NMTBVL   DS    CL20                    EQUATED VALUE IE: CVTFIX+248     00013200
NMTBUSD  DS    C                       Y=@NMNNNNN FOUND IN SOURCE       00013300
NMTBNX   EQU   *                                                        00013400
NMTB     EQU   NMTBDS,*-NMTBDS                                          00013500
*********************************************************************** 00013600
*                                                                     * 00013700
* MODULE NAME                                                         * 00013800
*    MACCVT                                                           * 00013900
*                                                                     * 00014000
* ATTRIBUTES                                                          * 00014100
*    NORENT                                                           * 00014200
*                                                                     * 00014300
* AUTHOR                                                              * 00014400
*    DAVE KREISS                                                      * 00014500
*                                                                     * 00014600
* NOTE                                                                * 00014700
*    This program grew far beyond it's original design and now        * 00014800
*    is what one would call highly unstructured and difficult to      * 00014900
*    maintain.  It however does handle for the most part the          * 00015000
*    conversion from PL/S generated assembly to a more maintainable   * 00015100
*    source code.  It has been used to convert all IEANUC01 modules   * 00015200
*    successfully (including successful IPL and testing).             * 00015300
*                                                                     * 00015400
* FUNCTION                                                            * 00015500
*    Creates updates to PL/S source code to change PL/S generated     * 00015600
*      inline style structure definitions to use common system        * 00015700
*      DSECTs.                                                        * 00015800
*    Changes the multitude register equated symbols to use a          * 00015900
*      standard R0 - R15 set of equates.                              * 00016000
*    Bit settings are also changed from the PL/S format to the        * 00016100
*      format used with the system DSECT flags.                       * 00016200
*                                                                     * 00016300
* JCL                                                                 * 00016400
*    //        EXEC PGM=MACCVT,PARM='parameters'                      * 00016500
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00016600
*    //FMID     DD  DSN=data set containing FMIDs list                * 00016700
*    //PTFID    DD  DSN=data set containing PTFID                     * 00016800
*    //SYSUT1   DD  DSN=input source file                             * 00016900
*    //SYSUT2   DD  DSN=output IEBUPDTE data set                      * 00017000
*    //SYSPRINT DD  SYSOUT=*                                          * 00017100
*    //SYSIN    DD  DSN=data set containing various control info      * 00017200
*                                                                     * 00017300
* DD STATEMENTS                                                       * 00017400
*    STEPLIB       LOAD LIBRARY CONAINING THE MODULE MACCVT.          * 00017500
*    SYSPRINT      UPDATE REPORT AND DIAGNOSTICS                      * 00017600
*    FMID          CONTAINS FMID TO CSECT TABLE USED TO GENERATE PTF. * 00017700
*                  COL 1-8=CSECT AND 9-15=FMID.                       * 00017800
*                  SAMPLE IS IN THIS LIBRARY MEMBER #MACCVTF          * 00017900
*                  EXAMPLE:                                           * 00018000
*    IEASMFEXEBB1102                                                  * 00018100
*    PTFID         DATA SET CONTAINING PTF ID TO BE ASSIGNED TO THIS  * 00018200
*                  CHANGE.  IT IS INCREMENTED AND UPDATED FOR NEXT    * 00018300
*                  STEP. THE STARTING PTF ID STARTS IN COLUMN 1 AND   * 00018400
*                  MUST HAVE NUMERICS IN 4-7 POSITION.                * 00018500
*    SYSUT1        INPUT SOURCE                                       * 00018600
*    SYSUT2        OUTPUT PTF CONTROL STATEMENTS                      * 00018700
*    SYSIN         CONTAINS CONTROL STATEMENTS DEFINED BELOW.         * 00018800
*                  SAMPLE IS IN THIS LIBRARY MEMBER #MACCVTX          * 00018900
*                  AN ADDITIONAL SAMPLE FOR PURELY REGISTER CONVERSIO * 00019000
*                  CONVERSION CAN BE FOUND IN MEMBER #MACCVTR         * 00019100
*                                                                     * 00019200
* PARM=                                                               * 00019300
*    DEBUG         *                                                  * 00019400
*    DEBUG(LIST)   *  CAUSES DIAGNOSTICS                              * 00019500
*    DEBUG(STATE)  *                                                  * 00019600
*    PTF=DSKnnnn   MARK WITH THIS PTF ID                              * 00019700
*    PTF=PTFID     USE PTFID DATA SET TO CREATE PTF IDS               * 00019800
*    PTF=DSKXXXX   MARK PTFID AND STORE MEMBER AS CSECT NAME.         * 00019900
*    NOREL         DON'T ADD -BASE TO DSECT REFRENCES.  USED IN       * 00020000
*                  CONJUNCTION WITH PL/S EQUATES.                     * 00020100
*                                                                     * 00020200
* CONTROL STATEMENTS                                                  * 00020300
* ------------------------------------------------------------------- * 00020400
** =label=label CHANGE LABEL1 TO LABEL2 AND ADD -prefix IF DEFINED    * 00020500
**                                                                    * 00020600
** CHANGE TABLE FOR EXAMPLE TYPICIAL CODE CONTAINS:                   * 00020700
**             TM    UCB3TAPE(UCBPTR),B'10000000'                     * 00020800
**        UCB DSECT CONTAINS:                                         * 00020900
**        UCBTBYT3 DS  .....                                          * 00021000
**        UCB3DACC EQU .....                                          * 00021100
**        UCB3TAPE EQU .....                                          * 00021200
**        TABLE ENTRY IS SPECIFIED AS:                                * 00021300
**        =UCB3TAPE=UCBTBYT3                                          * 00021400
**        FIRST UCB3TAPE IS CHANGED TO UCBTBYT3                       * 00021500
**        THEN -UCB IS ADDED AFTER UCBTBYT3 TO BE UCBTBYT3-UCB        * 00021600
**        THEN SINCE ONLY ONE BIT IS IN THE B' IMMEDIATE OPERAND      * 00021700
**        UCB3TAPE (ORIGINAL FIRST OPERAND) BECOMES THE IMMEDIATE     * 00021800
**        OPERAND RESULTING IN THE FOLLOWING:                         * 00021900
**             TM    UCBTBYT3-UCB(UCBPTR),UCB3TAPE                    * 00022000
**        EXAMPLE CONTROL CARDS:                                      * 00022100
** =UCB3TAPE=UCBTBYT3                                                 * 00022200
** =UCB3DACC=UCBTBYT3                                                 * 00022300
**                                                                    * 00022400
**  ENSURE LABELS WITH SIMILIAR NAMES ARE IN LONGER TO SHORTER ORDER  * 00022500
**  ORDER.  FOR EXAMPLE THIS ORDER MUST BE OBSERVED:                  * 00022600
**  =OUCBNSWI=OUCBSFL                                                 * 00022700
**  =OUCBNSW=OUCBSFL                                                  * 00022800
*                                                                     * 00022900
* ------------------------------------------------------------------- * 00023000
*                                                                     * 00023100
** +card image   INSERT THESE CARD IMAGES AT END BEFORE END STMT      * 00023200
**               EXCEPTION DSECTS ARE PLACED RIGHT AFTER THE          * 00023300
**               */*%INCLUDE SYSLIB comment                           * 00023400
**               2-61=DSECT 63-70=DSECT NAME                          * 00023500
**               IF 63-70 IS BLANK THE STATEMENT IS ALWAYS INSERTED   * 00023600
**               USED FOR EXAMPLE TO INSERT REGISTER EQUATES.         * 00023700
**        EXAMPLE CONTROL CARD:                                       * 00023800
** +         IHAASCB  ,                                           ASCB* 00023900
** +R0       EQU      0                                               * 00024000
*                                                                     * 00024100
* ------------------------------------------------------------------- * 00024200
*                                                                     * 00024300
** -label DON'T CONVERT THESE LABELS                                  * 00024400
**        EXAMPLE CONTROL CARD:                                         00024500
** -ASCBPTR                                                           * 00024600
*                                                                     * 00024700
* ------------------------------------------------------------------- * 00024800
*                                                                     * 00024900
** prefix=otherprefix                                                 * 00025000
** CONVERT THESE DSECT PREFIXS TO DSECT REFERENCES.  THE SECOND       * 00025100
** FIELD IS OPTIONAL AND RESULTS IN THAT LABEL BEING USED AS BASE     * 00025200
**        EXAMPLE CONTROL CARD:                                         00025300
*  ASVT                                                               * 00025400
*  CVTPTR=0                                                           * 00025500
*                                                                     * 00025600
* ------------------------------------------------------------------- * 00025700
*********************************************************************** 00025800
*                                                                     * 00025900
* CHANGE LOG:                                                         * 00026000
*   DATE     AAA VV.VV DESCRIPTION                                    * 00026100
* 10/26/2015 DSK 01.01 Created                                        * 00026200
* 02/01/2016 DSK 01.02 Register equates and bug fixes                 * 00026300
* 04/06/2016 DSK 01.03 Prevent coded lblxxx-lbl(rx) from being altered* 00026400
* 04/30/2016 DSK 01.04 =name=newname substitution incorrect           * 00026500
* 06/27/2016 DSK 01.05 Expand tables                                  * 00026600
* 02/10/2018 DSK 01.06 Expand @nm TABLE                               * 00026700
* 03/09/2018 DSK 01.07 List missing DSECTs detected                   * 00026710
         LCLC   &VER                                                    00026800
&VER     SETC   '01.07'                                                 00026810
*                                                                     * 00027000
*********************************************************************** 00027100
****************************************************************        00027200
*                                                              *        00027300
*   PROGRAM INITIALIZATION                                     *        00027400
*                                                              *        00027500
****************************************************************        00027600
MACCVT   CSECT                                                          00027700
         USING MACCVT,R15                                               00027800
         B     BEGIN                                                    00027900
         DROP  R15                                                      00028000
         DC    AL1(L'PGMID)                                             00028100
PGMID    DC    C'MACCVT - &VER &SYSDATE &SYSTIME'                       00028200
BEGIN    DC    0H'+0'                                                   00028300
         STM   R14,R12,12(R13)                                          00028400
         LR    R10,R15                                                  00028500
         LA    R11,2048(,R10)                                           00028600
         LA    R11,2048(,R11)                                           00028700
         LA    R12,2048(,R11)                                           00028800
         LA    R12,2048(,R12)                                           00028900
         USING MACCVT,R10,R11,R12                                       00029000
         L     R14,=A(SAVEAREA)                                         00029100
         ST    R13,4(,R14)                                              00029200
         ST    R14,8(,R13)                                              00029300
         LR    R13,R14                                                  00029400
         USING SAVEAREA,R13                                             00029500
         L     R9,0(,R1)                                                00029600
         OPEN  (SYSPRINT,(OUTPUT),SYSUT1,(INPUT),                      *00029700
               SYSIN,(INPUT))                                           00029800
         TM    SYSPRINT+48,16                                           00029900
         BZ    QUIT                                                     00030000
         TM    SYSIN+48,16                                              00030100
         BZ    QUIT                                                     00030200
         TM    SYSUT1+48,16                                             00030300
         BZ    QUIT                                                     00030400
         TIME  BIN                     GET CURRENT DATE AND TIME        00030500
         ST    R1,CURDATE              SAVE DATE                        00030600
         SRDL  R0,32                   GET DOUBLE WORD TIME             00030700
         D     R0,=F'+6000'            GET MINUTES                      00030800
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00030900
         SLR   R0,R0                   CLEAR                            00031000
         D     R0,=F'+60'              GET HOURS / MINS                 00031100
         MH    R0,=H'+10000'           GET MINUTES                      00031200
         AR    R15,R0                  ADD TO GET MM:SS.TH              00031300
         M     R0,=F'+1000000'         GET HOURS                        00031400
         AR    R1,R15                  GET HH:MM:SS.TH                  00031500
         CVD   R1,DWORD                GET TIME TO DECIMAL              00031600
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   00031700
         ED    TIMWRK4,DWORD+3         EDIT TIME                        00031800
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        00031900
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  00032000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    00032100
         ZAP   JULWRK6,=P'+28'         FEB = 28                         00032200
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        00032300
         DP    DWORD,=P'+4'            DIVIDE BY 4                      00032400
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              00032500
         BNZ   JULCVT2                  NO                              00032600
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    00032700
         ZAP   JULWRK6,=P'+29'         FEB = 29                         00032800
JULCVT2  DS    0H                                                       00032900
         LA    R1,JULTBL1              POINT TO JANUARY                 00033000
         SLR   R2,R2                   SET COUNTER                      00033100
JULCVT4  DS    0H                                                       00033200
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              00033300
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  00033400
         BCTR  R1,0                    POINT TO NEXT MONTH              00033500
         BCTR  R1,0                    POINT TO NEXT MONTH              00033600
         LA    R2,3(,R2)               UP INDEX                         00033700
         B     JULCVT4                 LOOP                             00033800
JULCVT6  DS    0H                                                       00033900
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                00034000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    00034100
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       00034200
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     00034300
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         00034400
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   00034500
         LA    R1,HD1DATE+6            SET POINTER                      00034600
         BNE   JULCVT7                  NO                              00034700
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 00034800
         BCTR  R1,0                    DROP POINTER                     00034900
JULCVT7  DS    0H                                                       00035000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  00035100
         TM    CURDATE,1               YEAR 2000?                       00035200
         BNO   JULCVT8                  NO, CONTINUE                    00035300
         MVC   2(2,R1),=C'20'          Y2K                              00035400
JULCVT8  DS    0H                                                       00035500
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      00035600
         MVC   4(2,R1),DWORD           GET YEAR                         00035700
         MVC   LINE+1(8),=C'Version='  Move version literal             00035800
         MVC   LINE+9(L'PGMID),PGMID   MOVE VERSION                     00035900
         BAL   R14,PRT                 PRINT A LINE                     00036000
         MVC   LINE+1(5),=C'PARM='     MOVE PARAMETER INFO LITERAL      00036100
         CLI   1(R9),0                 ANY PARAMETER?                   00036200
         BE    PRMPRT                  NO, SKIP MOVE                    00036300
         LH    R1,0(,R9)               GET PARMETER LENGTH              00036400
         BCTR  R1,0                    MAKE MACHINE LENGTH              00036500
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE          00036600
         B     PRMPRT                                                   00036700
PRMMVC   MVC   LINE+6(0),2(R9)         EXECUTED PARM MOVE               00036800
PRMPRT   DS    0H                                                       00036900
         BAL   R14,PRT                 PRINT A LINE                     00037000
         LH    R2,0(,R9)               GET PARM LENGTH                  00037100
         LA    R9,2(,R9)               SKIP LENGTH                      00037200
         ST    R9,PRMSTART             SAVE PARM START                  00037300
PRMSCN   DS    0H                                                       00037400
         LTR   R2,R2                   END OF PARM?                     00037500
         BZ    PRMEND                  YES, PARM PARSED                 00037600
         CLI   0(R9),C','              SEPERATOR?                       00037700
         BNE   PRMCHK                  NO, CHECK VALUES                 00037800
         LA    R9,1(,R9)               SKIP COMMA                       00037900
         BCTR  R2,0                    DECREMENT LENGTH                 00038000
         B     PRMSCN                  CONTINUE SCAN                    00038100
PRMCHK   DS    0H                                                       00038200
         CH    R2,=H'5'                LONG ENOUGH?                     00038300
         BL    PRMERR                  NO, ERROR                        00038400
         CLC   =C'DEBUG',0(R9)         DEBUG?                           00038500
         BE    PRMDBG                  YES, HANDLE IT                   00038600
         CLC   =C'PTF=',0(R9)          PTF=?                            00038700
         BE    PRMPTF                  YES, HANDLE IT                   00038800
         CLC   =C'NOREL',0(R9)         NOREL?                           00038900
         BE    PRMNOR                  YES, HANDLE IT                   00039000
         B     PRMERR                  ERROR                            00039100
PRMDBG   DS    0H                                                       00039200
         LA    R9,5(,R9)               SKIP VALUE                       00039300
         SH    R2,=H'5'                DECREMENT LENGTH                 00039400
         CLC   =C'(LIST)',0(R9)                                         00039500
         BE    PRMDBGL                                                  00039600
         CLC   =C'(STATE)',0(R9)                                        00039700
         BE    PRMDBGS                                                  00039800
         OI    FLAG,FLAGDBGA           SET DEBUG ALL                    00039900
         B     PRMSCNC                 CONTINUE SCAN                    00040000
PRMDBGL  DS    0H                                                       00040100
         LA    R9,6(,R9)               SKIP VALUE                       00040200
         SH    R2,=H'6'                DECREMENT LENGTH                 00040300
         OI    FLAG,FLAGDBGL           SET DEBUG LIST                   00040400
         B     PRMSCNC                 CONTINUE SCAN                    00040500
PRMDBGS  DS    0H                                                       00040600
         LA    R9,7(,R9)               SKIP VALUE                       00040700
         SH    R2,=H'7'                DECREMENT LENGTH                 00040800
         OI    FLAG,FLAGDBGS           SET DEBUG STATE                  00040900
         B     PRMSCNC                 CONTINUE SCAN                    00041000
PRMNOR   DS    0H                                                       00041100
         LA    R9,5(,R9)               SKIP VALUE                       00041200
         SH    R2,=H'5'                DECREMENT LENGTH                 00041300
         OI    FLAG,FLAGNORL           SET NORELATIVE                   00041400
         B     PRMSCNC                 CONTINUE SCAN                    00041500
PRMPTF   DS    0H                                                       00041600
         LA    R9,4(,R9)               SKIP VALUE                       00041700
         SH    R2,=H'4'                DECREMENT LENGTH                 00041800
PRMPTF10 DS    0H                                                       00041900
         LA    R0,L'PTFID                                               00042000
         LA    R1,PTFID                                                 00042100
         MVI   PTFID,C' '                                               00042200
         MVC   PTFID+1(L'PTFID-1),PTFID                                 00042300
PRMPTF20 DS    0H                                                       00042400
         CLI   0(R9),C','                                               00042500
         BE    PRMPTF30                                                 00042600
         CLI   0(R9),C'A'                                               00042700
         BL    PRMERR                                                   00042800
         CLI   0(R9),C'9'                                               00042900
         BH    PRMERR                                                   00043000
         MVC   0(1,R1),0(R9)                                            00043100
         LA    R9,1(,R9)                                                00043200
         LA    R1,1(,R1)                                                00043300
         SH    R2,=H'1'                                                 00043400
         BZ    PRMPTF30                                                 00043500
         SH    R0,=H'1'                                                 00043600
         B     PRMPTF20                                                 00043700
PRMPTF30 DS    0H                                                       00043800
         CLC   PTFID,=C'PTFID  '                                        00043900
         BNE   PRMSCNC                                                  00044000
         OPEN  (PTFIDDD,(INPUT))                                        00044100
         TM    PTFIDDD+48,16                                            00044200
         BNO   ERRPTFDD                                                 00044300
         GET   PTFIDDD,CARD                                             00044400
         CLOSE PTFIDDD                                                  00044500
         CLI   CARD,C' '                                                00044600
         BNH   ERRPTFID                                                 00044700
         CLI   CARD+1,C' '                                              00044800
         BNH   ERRPTFID                                                 00044900
         CLI   CARD+2,C' '                                              00045000
         BNH   ERRPTFID                                                 00045100
         CLI   CARD+3,C'0'                                              00045200
         BL    ERRPTFID                                                 00045300
         CLI   CARD+4,C'0'                                              00045400
         BL    ERRPTFID                                                 00045500
         CLI   CARD+5,C'0'                                              00045600
         BL    ERRPTFID                                                 00045700
         CLI   CARD+6,C'0'                                              00045800
         BL    ERRPTFID                                                 00045900
         PACK  DWORD,CARD+3(4)                                          00046000
         AP    DWORD,=P'+1'                                             00046100
         OI    DWORD+7,15                                               00046200
         UNPK  CARD+3(5),DWORD+5(3)                                     00046300
         MVC   CARD+3(4),CARD+4                                         00046400
         MVI   CARD+7,C' '                                              00046500
         MVC   PTFID,CARD                                               00046600
         MVI   UPDPTFID,C'Y'                                            00046700
         B     PRMSCNC                                                  00046800
PRMSCNC  DS    0H                                                       00046900
         LTR   R2,R2                   END OF PARM?                     00047000
         BZ    PRMEND                  YES, PARM PARSED                 00047100
         CLI   0(R9),C','              DELIMITER?                       00047200
         BE    PRMSCN                  YES, HANDLE IT                   00047300
PRMERR   DS    0H                                                       00047400
         LR    R1,R9                   CURRENT POSITION                 00047500
         S     R1,PRMSTART             LESS START                       00047600
         LA    R1,LINE+6(R1)           SET LOCATION OF ERROR            00047700
         MVI   0(R1),C'*'              MARK WHERE ERROR IS              00047800
         BAL   R14,PRT                 PRINT A LINE                     00047900
         MVC   LINE+1(18),=C'Parameters invalid'                        00048000
         BAL   R14,PRT                 PRINT A LINE                     00048100
         LA    R15,8                   ERROR RC                         00048200
         B     EXITRC                  ERROR                            00048300
PRMEND   DS    0H                                                       00048400
*********************************************************************** 00048500
* READ CONTROL CARDS                                                  * 00048600
*********************************************************************** 00048700
CTL      DS    0H                                                       00048800
         GET   SYSIN,CARD                                               00048900
         TM    FLAG,FLAGDBGL                                            00049000
         BNO   CTL010                                                   00049100
         MVC   LINE+1(L'CARD),CARD                                      00049200
         BAL   R14,PRT                                                  00049300
CTL010   DS    0H                                                       00049400
         CLI   CARD,C'*'               COMMENT                          00049500
         BE    CTL                                                      00049600
         LA    R9,CARD                                                  00049700
         CLI   CARD,C'-'               IGNORE LABEL                     00049800
         BE    CTLSKP                                                   00049900
         CLI   CARD,C'+'               INSERT AT END (MACRO DSECTS)     00050000
         BE    CTLINS                                                   00050100
         CLI   CARD,C'='               CHANGE LABEL1 TO LABEL2          00050200
         BE    CTLCHG                                                   00050300
*********************************************************************** 00050400
* prefix=otherprefix                                                  * 00050500
*********************************************************************** 00050600
         LA    R0,L'MACPRMNM           PREFIX (=PREFIX)                 00050700
         LA    R1,MACPRMNM                                              00050800
         MVI   MACPRMNM,C' '                                            00050900
         MVC   MACPRMNM+1(L'MACPRMNM-1),MACPRMNM                        00051000
         LA    R9,CARD                                                  00051100
CTLMAC10 DS    0H                                                       00051200
         CLI   0(R9),C'@'                                               00051300
         BE    CTLMAC15                                                 00051400
         CLI   0(R9),C'#'                                               00051500
         BE    CTLMAC15                                                 00051600
         CLI   0(R9),C'$'                                               00051700
         BE    CTLMAC15                                                 00051800
         CLI   0(R9),C'A'                                               00051900
         BL    CTLERR                                                   00052000
         CLI   0(R9),C'9'                                               00052100
         BH    CTLERR                                                   00052200
CTLMAC15 DS    0H                                                       00052300
         MVC   0(1,R1),0(R9)                                            00052400
         LA    R1,1(,R1)                                                00052500
         LA    R9,1(,R9)                                                00052600
         SH    R0,=H'1'                                                 00052700
         CLI   0(R9),C'='                                               00052800
         BE    CTLMAC20                                                 00052900
         CLI   0(R9),C' '                                               00053000
         BE    CTLMAC20                                                 00053100
         B     CTLMAC10                                                 00053200
CTLMAC20 DS    0H                                                       00053300
         L     R4,=A(MACTBL)                                            00053400
         USING MACTB,R4                                                 00053500
CTLMAC30 DS    0H                                                       00053600
         C     R4,MACTBPT                                               00053700
         BE    CTLMAC40                                                 00053800
         CLC   MACPRMNM,MACTBNM                                         00053900
         BE    CTLERR                                                   00054000
         LA    R4,MACTBNX                                               00054100
         C     R4,=A(MACTBND)                                           00054200
         BNL   CTLMACOE                                                 00054300
         B     CTLMAC30                                                 00054400
CTLMAC40 DS    0H                                                       00054500
         XC    MACTB,MACTB                                              00054600
         MVC   MACTBNM,MACPRMNM                                         00054700
         LA    R0,L'MACTBNM                                             00054800
         LA    R1,MACTBNM                                               00054900
         LA    R14,0                                                    00055000
CTLMAC50 DS    0H                                                       00055100
         CLI   0(R1),C' '                                               00055200
         BE    CTLMAC60                                                 00055300
         LA    R1,1(,R1)                                                00055400
         LA    R14,1(,R14)                                              00055500
         BCT   R0,CTLMAC50                                              00055600
CTLMAC60 DS    0H                                                       00055700
         BCTR  R14,0                                                    00055800
         STH   R14,MACTBNML                                             00055900
         LA    R15,MACTBNX                                              00056000
         ST    R15,MACTBPT                                              00056100
         CLI   0(R9),C'='                                               00056200
         BE    CTLMAC65                                                 00056300
         MVC   MACTBSY,MACTBNM                                          00056400
         MVC   MACTBSYL,MACTBNML                                        00056500
         B     CTL                                                      00056600
CTLMAC65 DS    0H                                                       00056700
         LA    R9,1(,R9)                                                00056800
         LA    R0,L'MACPRMNM                                            00056900
         LA    R1,MACPRMNM                                              00057000
         MVI   MACPRMNM,C' '                                            00057100
         MVC   MACPRMNM+1(L'MACPRMNM-1),MACPRMNM                        00057200
CTLMAC70 DS    0H                                                       00057300
         CLI   0(R9),C'@'                                               00057400
         BE    CTLMAC75                                                 00057500
         CLI   0(R9),C'#'                                               00057600
         BE    CTLMAC75                                                 00057700
         CLI   0(R9),C'$'                                               00057800
         BE    CTLMAC75                                                 00057900
         CLI   0(R9),C'A'                                               00058000
         BL    CTLERR                                                   00058100
         CLI   0(R9),C'9'                                               00058200
         BH    CTLERR                                                   00058300
CTLMAC75 DS    0H                                                       00058400
         MVC   0(1,R1),0(R9)                                            00058500
         LA    R1,1(,R1)                                                00058600
         LA    R9,1(,R9)                                                00058700
         SH    R0,=H'1'                                                 00058800
         CLI   0(R9),C' '                                               00058900
         BE    CTLMAC80                                                 00059000
         B     CTLMAC70                                                 00059100
CTLMAC80 DS    0H                                                       00059200
         MVC   MACTBSY,MACPRMNM                                         00059300
         LA    R0,L'MACTBSY                                             00059400
         LA    R1,MACTBSY                                               00059500
         LA    R14,0                                                    00059600
CTLMAC90 DS    0H                                                       00059700
         CLI   0(R1),C' '                                               00059800
         BE    CTLMACA0                                                 00059900
         LA    R1,1(,R1)                                                00060000
         LA    R14,1(,R14)                                              00060100
         BCT   R0,CTLMAC90                                              00060200
CTLMACA0 DS    0H                                                       00060300
         BCTR  R14,0                                                    00060400
         STH   R14,MACTBSYL                                             00060500
         B     CTL                                                      00060600
CTLMACOE DS    0H                                                       00060700
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00060800
         BAL   R14,PRT                 PRINT A LINE                     00060900
         MVC   LINE+1(21),=C'Prefix table overflow'                     00061000
         BAL   R14,PRT                 PRINT A LINE                     00061100
         LA    R15,8                   ERROR RC                         00061200
         B     EXITRC                  ERROR                            00061300
         DROP  R4                                                       00061400
*********************************************************************** 00061500
* -label DON'T CONVERT THESE LABELS                                   * 00061600
*********************************************************************** 00061700
CTLSKP   DS    0H                                                       00061800
         LA    R0,L'SKPPRMNM                                            00061900
         LA    R1,SKPPRMNM                                              00062000
         MVI   SKPPRMNM,C' '                                            00062100
         MVC   SKPPRMNM+1(L'SKPPRMNM-1),SKPPRMNM                        00062200
         LA    R9,CARD+1                                                00062300
CTLSKP10 DS    0H                                                       00062400
         CLI   0(R9),C'@'                                               00062500
         BE    CTLSKP15                                                 00062600
         CLI   0(R9),C'#'                                               00062700
         BE    CTLSKP15                                                 00062800
         CLI   0(R9),C'$'                                               00062900
         BE    CTLSKP15                                                 00063000
         CLI   0(R9),C'A'                                               00063100
         BL    CTLERR                                                   00063200
         CLI   0(R9),C'9'                                               00063300
         BH    CTLERR                                                   00063400
CTLSKP15 DS    0H                                                       00063500
         MVC   0(1,R1),0(R9)                                            00063600
         LA    R1,1(,R1)                                                00063700
         LA    R9,1(,R9)                                                00063800
         SH    R0,=H'1'                                                 00063900
         CLI   0(R9),C'='                                               00064000
         BE    CTLSKP20                                                 00064100
         CLI   0(R9),C' '                                               00064200
         BE    CTLSKP20                                                 00064300
         B     CTLSKP10                                                 00064400
CTLSKP20 DS    0H                                                       00064500
         L     R15,=A(SKPTBL)                                           00064600
         USING SKPTB,R15                                                00064700
CTLSKP30 DS    0H                                                       00064800
         C     R15,SKPTBPT                                              00064900
         BE    CTLSKP40                                                 00065000
         CLC   SKPPRMNM,SKPTBNM                                         00065100
         BE    CTLERR                                                   00065200
         LA    R15,SKPTBNX                                              00065300
         C     R15,=A(SKPTBND)                                          00065400
         BNL   CTLSKPOE                                                 00065500
         B     CTLSKP30                                                 00065600
CTLSKP40 DS    0H                                                       00065700
         XC    SKPTB,SKPTB                                              00065800
         MVC   SKPTBNM,SKPPRMNM                                         00065900
         LA    R0,L'SKPTBNM                                             00066000
         LA    R1,SKPTBNM                                               00066100
         LA    R14,0                                                    00066200
CTLSKP50 DS    0H                                                       00066300
         CLI   0(R1),C' '                                               00066400
         BE    CTLSKP60                                                 00066500
         LA    R1,1(,R1)                                                00066600
         LA    R14,1(,R14)                                              00066700
         BCT   R0,CTLSKP50                                              00066800
CTLSKP60 DS    0H                                                       00066900
         BCTR  R14,0                                                    00067000
         STH   R14,SKPTBNML                                             00067100
         LA    R15,SKPTBNX                                              00067200
         ST    R15,SKPTBPT                                              00067300
         B     CTL                                                      00067400
CTLSKPOE DS    0H                                                       00067500
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00067600
         BAL   R14,PRT                 PRINT A LINE                     00067700
         MVC   LINE+1(19),=C'Skip table overflow'                       00067800
         BAL   R14,PRT                 PRINT A LINE                     00067900
         LA    R15,8                   ERROR RC                         00068000
         B     EXITRC                  ERROR                            00068100
*********************************************************************** 00068200
* +card image  - INSERT THESE CARD IMAGES AT END BEFORE END STATEMENT * 00068300
*                2-61=DSECT 63-70=DSECT NAME                          * 00068400
*********************************************************************** 00068500
CTLINS   DS    0H                                                       00068600
         L     R15,INSTBPT                                              00068700
         USING INSTB,R15                                                00068800
         C     R15,=A(INSTBND)                                          00068900
         BNL   CTLINSOE                                                 00069000
         MVI   INSTBUSD,C'N'                                            00069100
         MVC   INSTBPFX,CARD+63                                         00069200
         LA    R0,L'INSTBPFX                                            00069300
         LA    R9,INSTBPFX                                              00069400
         LA    R14,0                                                    00069500
CTLINS50 DS    0H                                                       00069600
         CLI   0(R9),C' '                                               00069700
         BE    CTLINS60                                                 00069800
         LA    R9,1(,R9)                                                00069900
         LA    R14,1(,R14)                                              00070000
         BCT   R0,CTLINS50                                              00070100
CTLINS60 DS    0H                                                       00070200
         LTR   R14,R14                                                  00070300
         BNZ   CTLINS70                                                 00070400
         MVI   INSTBUSD,C'Y'                                            00070500
         LA    R14,256                                                  00070600
CTLINS70 DS    0H                                                       00070700
         BCTR  R14,0                                                    00070800
         STH   R14,INSTBPFL                                             00070900
         MVC   INSTBCRD,CARD+1                                          00071000
         LA    R15,INSTBNX                                              00071100
         ST    R15,INSTBPT                                              00071200
         B     CTL                                                      00071300
CTLINSOE DS    0H                                                       00071400
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00071500
         BAL   R14,PRT                 PRINT A LINE                     00071600
         MVC   LINE+1(21),=C'Insert table overflow'                     00071700
         BAL   R14,PRT                 PRINT A LINE                     00071800
         LA    R15,8                   ERROR RC                         00071900
         B     EXITRC                  ERROR                            00072000
         DROP  R15                                                      00072100
*********************************************************************** 00072200
* =label=label CHANGE LABEL1 TO LABEL2 AND ADD -prefix IF DEFINED     * 00072300
*********************************************************************** 00072400
CTLCHG   DS    0H                                                       00072500
         LA    R0,L'CHGLBLNM                                            00072600
         LA    R1,CHGLBLNM                                              00072700
         MVI   CHGLBLNM,C' '                                            00072800
         MVC   CHGLBLNM+1(L'CHGLBLNM-1),CHGLBLNM                        00072900
         LA    R9,CARD+1                                                00073000
CTLCHG10 DS    0H                                                       00073100
         CLI   0(R9),C'@'                                               00073200
         BE    CTLCHG15                                                 00073300
         CLI   0(R9),C'#'                                               00073400
         BE    CTLCHG15                                                 00073500
         CLI   0(R9),C'$'                                               00073600
         BE    CTLCHG15                                                 00073700
         CLI   0(R9),C'A'                                               00073800
         BL    CTLERR                                                   00073900
         CLI   0(R9),C'9'                                               00074000
         BH    CTLERR                                                   00074100
CTLCHG15 DS    0H                                                       00074200
         MVC   0(1,R1),0(R9)                                            00074300
         LA    R1,1(,R1)                                                00074400
         LA    R9,1(,R9)                                                00074500
         SH    R0,=H'1'                                                 00074600
         CLI   0(R9),C'='                                               00074700
         BE    CTLCHG20                                                 00074800
         B     CTLCHG10                                                 00074900
CTLCHG20 DS    0H                                                       00075000
         L     R4,=A(CHGTBL)                                            00075100
         USING CHGTB,R4                                                 00075200
CTLCHG30 DS    0H                                                       00075300
         C     R4,CHGTBPT                                               00075400
         BE    CTLCHG40                                                 00075500
         CLC   CHGLBLNM,CHGTBNM                                         00075600
         BE    CTLERR                                                   00075700
         LA    R4,CHGTBNX                                               00075800
         C     R4,=A(CHGTBND)                                           00075900
         BNL   CTLCHGOE                                                 00076000
         B     CTLCHG30                                                 00076100
CTLCHG40 DS    0H                                                       00076200
         XC    CHGTB,CHGTB                                              00076300
         MVC   CHGTBNM,CHGLBLNM                                         00076400
         LA    R0,L'CHGTBNM                                             00076500
         LA    R1,CHGTBNM                                               00076600
         LA    R14,0                                                    00076700
CTLCHG50 DS    0H                                                       00076800
         CLI   0(R1),C' '                                               00076900
         BE    CTLCHG60                                                 00077000
         LA    R1,1(,R1)                                                00077100
         LA    R14,1(,R14)                                              00077200
         BCT   R0,CTLCHG50                                              00077300
CTLCHG60 DS    0H                                                       00077400
         BCTR  R14,0                                                    00077500
         STH   R14,CHGTBNML                                             00077600
         LA    R15,CHGTBNX                                              00077700
         ST    R15,CHGTBPT                                              00077800
         CLI   0(R9),C'='                                               00077900
         BNE   CTLERR                                                   00078000
CTLCHG65 DS    0H                                                       00078100
         LA    R9,1(,R9)                                                00078200
         LA    R0,L'CHGLBLNN                                         04 00078300
         LA    R1,CHGLBLNN                                           04 00078400
         MVI   CHGLBLNN,C' '                                         04 00078500
         MVC   CHGLBLNN+1(L'CHGLBLNN-1),CHGLBLNN                     04 00078600
         B     CTLCHG71                                                 00078700
CTLCHG70 DS    0H                                                       00078800
         CLI   0(R9),C'9'                                               00078900
         BH    CTLERR                                                   00079000
         CLI   0(R9),C'0'                                               00079100
         BNL   CTLCHG75                                                 00079200
         CLI   0(R9),C'-'                                               00079300
         BE    CTLCHG75                                                 00079400
         CLI   0(R9),C'+'                                               00079500
         BE    CTLCHG75                                                 00079600
CTLCHG71 DS    0H                                                       00079700
         CLI   0(R9),C'@'                                               00079800
         BE    CTLCHG75                                                 00079900
         CLI   0(R9),C'#'                                               00080000
         BE    CTLCHG75                                                 00080100
         CLI   0(R9),C'$'                                               00080200
         BE    CTLCHG75                                                 00080300
         CLI   0(R9),C'A'                                               00080400
         BL    CTLERR                                                   00080500
         CLI   0(R9),C'Z'                                               00080600
         BH    CTLERR                                                   00080700
CTLCHG75 DS    0H                                                       00080800
         MVC   0(1,R1),0(R9)                                            00080900
         LA    R1,1(,R1)                                                00081000
         LA    R9,1(,R9)                                                00081100
         SH    R0,=H'1'                                                 00081200
         CLI   0(R9),C' '                                               00081300
         BE    CTLCHG80                                                 00081400
         B     CTLCHG70                                                 00081500
CTLCHG80 DS    0H                                                       00081600
         MVC   CHGTBNN,CHGLBLNN                                      04 00081700
         LA    R0,L'CHGTBNN                                             00081800
         LA    R1,CHGTBNN                                               00081900
         LA    R14,0                                                    00082000
CTLCHG90 DS    0H                                                       00082100
         CLI   0(R1),C' '                                               00082200
         BE    CTLCHGA0                                                 00082300
         LA    R1,1(,R1)                                                00082400
         LA    R14,1(,R14)                                              00082500
         BCT   R0,CTLCHG90                                              00082600
CTLCHGA0 DS    0H                                                       00082700
         BCTR  R14,0                                                    00082800
         STH   R14,CHGTBNNL                                             00082900
         B     CTL                                                      00083000
CTLCHGOE DS    0H                                                       00083100
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00083200
         BAL   R14,PRT                 PRINT A LINE                     00083300
         MVC   LINE+1(21),=C'Change table overflow'                     00083400
         BAL   R14,PRT                 PRINT A LINE                     00083500
         LA    R15,8                   ERROR RC                         00083600
         B     EXITRC                  ERROR                            00083700
         DROP  R4                                                       00083800
CTLERR   DS    0H                                                       00083900
         MVC   LINE+1(L'CARD),CARD                                      00084000
         BAL   R14,PRT                 PRINT A LINE                     00084100
         LR    R1,R9                   CURRENT POSITION                 00084200
         LA    R0,CARD                                                  00084300
         SR    R1,R0                   LESS START                       00084400
         LA    R1,LINE+1(R1)           SET LOCATION OF ERROR            00084500
         MVI   0(R1),C'*'              MARK WHERE ERROR IS              00084600
         BAL   R14,PRT                 PRINT A LINE                     00084700
         MVC   LINE+1(18),=C'Control card error'                        00084800
         BAL   R14,PRT                 PRINT A LINE                     00084900
         LA    R15,8                   ERROR RC                         00085000
         B     EXITRC                  ERROR                            00085100
CTLEOF   DS    0H                                                       00085200
         CLI   PTFID,C' '                                               00085300
         BH    PRMPTFOK                                                 00085400
         MVC   LINE+1(17),=C'No PTF= specified'                         00085500
         BAL   R14,PRT                 PRINT A LINE                     00085600
         LA    R15,8                   ERROR RC                         00085700
         B     EXITRC                  ERROR                            00085800
PRMPTFOK DS    0H                                                       00085900
         RDJFCB SYSUT1                                                  00086000
         LTR   R15,R15                                                  00086100
         BNZ   ERRRDJ1                                                  00086200
         LA    R1,UT1JFCB                                               00086300
         USING JFCB,R1                                                  00086400
         MVC   ELNM,JFCBELNM                                            00086500
         DROP  R1                                                       00086600
         CLI   ELNM,C' '                                                00086700
         BNH   SKPFMID                                                  00086800
         OPEN  (FMIDDD,(INPUT))                                         00086900
         TM    FMIDDD+48,16                                             00087000
         BNO   ERRFMDD                                                  00087100
GETFMID1 DS    0H                                                       00087200
         GET   FMIDDD,CARD                                              00087300
         CLC   ELNM,CARD                                                00087400
         BNE   GETFMID1                                                 00087500
         CLOSE FMIDDD                                                   00087600
         MVC   FMID,CARD+8                                              00087700
         MVC   LINE+1(10),=C'Processing'                                00087800
         MVC   LINE+12(8),ELNM                                          00087900
         MVC   LINE+21(6),=C'PTFID='                                    00088000
         MVC   LINE+27(7),PTFID                                         00088100
         MVC   LINE+36(5),=C'FMID='                                     00088200
         MVC   LINE+41(7),FMID                                          00088300
         BAL   R14,PRT                                                  00088400
SKPFMID  DS    0H                                                       00088500
*********************************************************************** 00088600
*                                                                     * 00088700
*        PREPASS OF SOURCE TO LOCATE EQU TO @NN EQUATES AND           * 00088800
*        BUILD TABLE OF EQUATES                                       * 00088900
*        ALSO ALL @NMNNNNNN EQUATE STATEMENTS ARE TABLED              * 00089000
*                                                                     * 00089100
*********************************************************************** 00089200
         MVI   PREPHASE,C'Y'                                            00089300
PRERD    DS    0H                                                       00089400
         GET   SYSUT1,CARD                                              00089500
         LA    R9,CARD+71              END OF STMT                      00089600
         LA    R3,CARD                 CURRENT STMT POINTER             00089700
         CLI   CARD,C'*'               SKIP COMMENTS                    00089800
         BE    PRERD                                                    00089900
         CLI   CARD,C' '               LABEL?                           00090000
         BE    PRERD                   NO, SKIP                         00090100
         CLC   =C'@NM0',0(R3)          @NM0NNNN EQUATE                  00090200
         BE    PRENM                                                    00090300
         CLC   =C'R0 ',0(R3)                                            00090400
         BE    PRERD                                                    00090500
         CLC   =C'R1 ',0(R3)                                            00090600
         BE    PRERD                                                    00090700
         CLC   =C'R2 ',0(R3)                                            00090800
         BE    PRERD                                                    00090900
         CLC   =C'R3 ',0(R3)                                            00091000
         BE    PRERD                                                    00091100
         CLC   =C'R4 ',0(R3)                                            00091200
         BE    PRERD                                                    00091300
         CLC   =C'R5 ',0(R3)                                            00091400
         BE    PRERD                                                    00091500
         CLC   =C'R6 ',0(R3)                                            00091600
         BE    PRERD                                                    00091700
         CLC   =C'R7 ',0(R3)                                            00091800
         BE    PRERD                                                    00091900
         CLC   =C'R8 ',0(R3)                                            00092000
         BE    PRERD                                                    00092100
         CLC   =C'R9 ',0(R3)                                            00092200
         BE    PRERD                                                    00092300
         CLC   =C'R10 ',0(R3)                                           00092400
         BE    PRERD                                                    00092500
         CLC   =C'R11 ',0(R3)                                           00092600
         BE    PRERD                                                    00092700
         CLC   =C'R12 ',0(R3)                                           00092800
         BE    PRERD                                                    00092900
         CLC   =C'R13 ',0(R3)                                           00093000
         BE    PRERD                                                    00093100
         CLC   =C'R14 ',0(R3)                                           00093200
         BE    PRERD                                                    00093300
         CLC   =C'R15 ',0(R3)                                           00093400
         BE    PRERD                                                    00093500
         BAL   R14,SCANBL              FIND BLANK END OF LABEL          00093600
         BNE   PRERD                   LINE WITH ONLY LABEL             00093700
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPCODE   00093800
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00093900
         CLC   =C'EQU ',0(R3)          IS OPCODE EQU                    00094000
         BNE   PRERD                   NO, SKIP IT                      00094100
         BAL   R14,SCANBL              FIND BLANK END OF OPCODE         00094200
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00094300
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPERANDS 00094400
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00094500
         CLC   =C'@00 ',0(R3)                                           00094600
         BE    PREFND                                                   00094700
         CLC   =C'@01 ',0(R3)                                           00094800
         BE    PREFND                                                   00094900
         CLC   =C'@02 ',0(R3)                                           00095000
         BE    PREFND                                                   00095100
         CLC   =C'@03 ',0(R3)                                           00095200
         BE    PREFND                                                   00095300
         CLC   =C'@04 ',0(R3)                                           00095400
         BE    PREFND                                                   00095500
         CLC   =C'@05 ',0(R3)                                           00095600
         BE    PREFND                                                   00095700
         CLC   =C'@06 ',0(R3)                                           00095800
         BE    PREFND                                                   00095900
         CLC   =C'@07 ',0(R3)                                           00096000
         BE    PREFND                                                   00096100
         CLC   =C'@08 ',0(R3)                                           00096200
         BE    PREFND                                                   00096300
         CLC   =C'@09 ',0(R3)                                           00096400
         BE    PREFND                                                   00096500
         CLC   =C'@10 ',0(R3)                                           00096600
         BE    PREFND                                                   00096700
         CLC   =C'@11 ',0(R3)                                           00096800
         BE    PREFND                                                   00096900
         CLC   =C'@12 ',0(R3)                                           00097000
         BE    PREFND                                                   00097100
         CLC   =C'@13 ',0(R3)                                           00097200
         BE    PREFND                                                   00097300
         CLC   =C'@14 ',0(R3)                                           00097400
         BE    PREFND                                                   00097500
         CLC   =C'@15 ',0(R3)                                           00097600
         BE    PREFND                                                   00097700
         CLC   =C'@00 ',CARD                                            00097800
         BE    PREFND                                                   00097900
         CLC   =C'@01 ',CARD                                            00098000
         BE    PREFND                                                   00098100
         CLC   =C'@02 ',CARD                                            00098200
         BE    PREFND                                                   00098300
         CLC   =C'@03 ',CARD                                            00098400
         BE    PREFND                                                   00098500
         CLC   =C'@04 ',CARD                                            00098600
         BE    PREFND                                                   00098700
         CLC   =C'@05 ',CARD                                            00098800
         BE    PREFND                                                   00098900
         CLC   =C'@06 ',CARD                                            00099000
         BE    PREFND                                                   00099100
         CLC   =C'@07 ',CARD                                            00099200
         BE    PREFND                                                   00099300
         CLC   =C'@08 ',CARD                                            00099400
         BE    PREFND                                                   00099500
         CLC   =C'@09 ',CARD                                            00099600
         BE    PREFND                                                   00099700
         CLC   =C'@10 ',CARD                                            00099800
         BE    PREFND                                                   00099900
         CLC   =C'@11 ',CARD                                            00100000
         BE    PREFND                                                   00100100
         CLC   =C'@12 ',CARD                                            00100200
         BE    PREFND                                                   00100300
         CLC   =C'@13 ',CARD                                            00100400
         BE    PREFND                                                   00100500
         CLC   =C'@14 ',CARD                                            00100600
         BE    PREFND                                                   00100700
         CLC   =C'@15 ',CARD                                            00100800
         BE    PREFND                                                   00100900
         B     PRERD                   NOT EQUATED TO @NN               00101000
PREFND   DS    0H                                                       00101100
         L     R1,REGTBPT                                               00101200
         USING REGTB,R1                                                 00101300
         C     R1,=A(REGTBND)                                           00101400
         BNL   PREEQER                TABLE OVERFLOW                    00101500
         MVC   REGNM,=CL8' '                                            00101600
         MVC   REGREG,=C'  '                                            00101700
         LA    R14,REGNM                                                00101800
         LA    R15,CARD                                                 00101900
PREEQU10 DS    0H                                                       00102000
         CLI   0(R15),C' '                                              00102100
         BE    PREEQU20                                                 00102200
         MVC   0(1,R14),0(R15)                                          00102300
         LA    R14,1(,R14)                                              00102400
         LA    R15,1(,R15)                                              00102500
         B     PREEQU10                                                 00102600
PREEQU20 DS    0H                                                       00102700
         S     R15,=A(CARD+1)                                           00102800
         STH   R15,REGNML                                               00102900
         CLI   0(R3),C'@'             EQU @XX                           00103000
         BE    PREEQU25                                                 00103100
         BCTR  R3,0                   HANDLE @XX EQU 00                 00103200
PREEQU25 DS    0H                                                       00103300
         CLI   1(R3),C'0'                                               00103400
         BE    PREEQU30                                                 00103500
         MVC   REGREG,1(R3)                                             00103600
         B     PREEQU40                                                 00103700
PREEQU30 DS    0H                                                       00103800
         MVC   REGREG(1),2(R3)                                          00103900
PREEQU40 DS    0H                                                       00104000
         LA    R1,REGTBNX                                               00104100
         ST    R1,REGTBPT                                               00104200
         TM    FLAG,FLAGDBGL                                            00104300
         BNO   PRERD                                                    00104400
         MVC   LINE+1(L'CARD),CARD                                      00104500
         MVC   LINE+90(15),=C'Register equate'                          00104600
         BAL   R14,PRT                                                  00104700
         B     PRERD                                                    00104800
         DROP  R1                                                       00104900
PRENM    DS    0H                                                       00105000
         BAL   R14,SCANBL              FIND BLANK END OF LABEL          00105100
         BNE   PRERD                   LINE WITH ONLY LABEL             00105200
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPCODE   00105300
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00105400
         CLC   =C'EQU ',0(R3)          IS OPCODE EQU                    00105500
         BNE   PRERD                   NO, SKIP IT                      00105600
         BAL   R14,SCANBL              FIND BLANK END OF OPCODE         00105700
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00105800
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPERANDS 00105900
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00106000
         LR    R4,R3                   SAVE START OF OPERAND            00106100
         BAL   R14,SCANBL              FIND BLANK END OF EQU OPERAND    00106200
         BNE   PRERD                   LINE FULL WITHOUT 3 FIELDS       00106300
         CLC   =C'@00 ',0(R3)                                           00106400
         BE    PREFND                                                   00106500
         L     R1,NMTBPT                                                00106600
         USING NMTB,R1                                                  00106700
         C     R1,=A(NMTBND)                                            00106800
         BNL   PRENMER                TABLE OVERFLOW                    00106900
         MVC   NMTBNM,CARD            ASSUME 8 BYTE @NMNNNNN            00107000
         MVI   NMTBVL,C' '            CLEAR VALUE                       00107100
         MVC   NMTBVL+1(L'NMTBVL-1),NMTBVL                              00107200
         LR    R14,R3                                                   00107300
         SR    R14,R4                                                   00107400
         CH    R14,=AL2(L'NMTBVL)                                       00107500
         BH    PRENME1                                                  00107600
         BCTR  R14,0                                                    00107700
         STH   R14,NMTBVLLN           SAVE LENGTH OF VALUE              00107800
         EX    R14,PRENMMV            MVC NMTBVL(0),0(R4)               00107900
         LA    R1,NMTBNX                                                00108000
         ST    R1,NMTBPT                                                00108100
         TM    FLAG,FLAGDBGL                                            00108200
         BNO   PRERD                                                    00108300
         MVC   LINE+1(L'CARD),CARD                                      00108400
         MVC   LINE+90(15),=C'Register equate'                          00108500
         BAL   R14,PRT                                                  00108600
         B     PRERD                                                    00108700
PRENMMV  MVC   NMTBVL(0),0(R4)                                          00108800
         DROP  R1                                                       00108900
PREEQER  DS    0H                                                       00109000
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00109100
         BAL   R14,PRT                 PRINT A LINE                     00109200
         MVC   LINE+1(22),=C'EQU @nn table overflow'                    00109300
         BAL   R14,PRT                 PRINT A LINE                     00109400
         LA    R15,8                   ERROR RC                         00109500
         B     EXITRC                  ERROR                            00109600
PRENMER  DS    0H                                                       00109700
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00109800
         BAL   R14,PRT                 PRINT A LINE                     00109900
         MVC   LINE+1(22),=C'@NM EQU table overflow'                    00110000
         BAL   R14,PRT                 PRINT A LINE                     00110100
         LA    R15,8                   ERROR RC                         00110200
         B     EXITRC                  ERROR                            00110300
PRENME1  DS    0H                                                       00110400
         MVC   LINE+1(L'CARD),CARD     CURRENT LINE                     00110500
         BAL   R14,PRT                 PRINT A LINE                     00110600
         MVC   LINE+1(22),=C'@NM EQU value to large'                    00110700
         BAL   R14,PRT                 PRINT A LINE                     00110800
         LA    R15,8                   ERROR RC                         00110900
         B     EXITRC                  ERROR                            00111000
PREEOD   DS    0H                                                       00111100
         MVI   PREPHASE,C'N'                                            00111200
         CLOSE SYSUT1                                                   00111300
         OPEN  SYSUT1                                                   00111400
         TM    FLAG,FLAGDBGL                                            00111500
         BNO   NODMPTB                                                  00111600
         MVC   LINE+1(6),=C'MACTBL'                                     00111700
         BAL   R14,PRT                                                  00111800
         L     R1,=A(MACTBL)                                            00111900
         L     R0,MACTBPT                                               00112000
         SR    R0,R1                                                    00112100
         BAL   R14,DMP                                                  00112200
         MVC   LINE+1(6),=C'SKPTBL'                                     00112300
         BAL   R14,PRT                                                  00112400
         L     R1,=A(SKPTBL)                                            00112500
         L     R0,SKPTBPT                                               00112600
         SR    R0,R1                                                    00112700
         BAL   R14,DMP                                                  00112800
         MVC   LINE+1(6),=C'INSTBL'                                     00112900
         BAL   R14,PRT                                                  00113000
         L     R1,=A(INSTBL)                                            00113100
         L     R0,INSTBPT                                               00113200
         SR    R0,R1                                                    00113300
         BAL   R14,DMP                                                  00113400
         MVC   LINE+1(6),=C'CHGTBL'                                     00113500
         BAL   R14,PRT                                                  00113600
         L     R1,=A(CHGTBL)                                            00113700
         L     R0,CHGTBPT                                               00113800
         SR    R0,R1                                                    00113900
         BAL   R14,DMP                                                  00114000
         MVC   LINE+1(6),=C'REGTBL'                                     00114100
         BAL   R14,PRT                                                  00114200
         L     R1,=A(REGTBL)                                            00114300
         L     R0,REGTBPT                                               00114400
         SR    R0,R1                                                    00114500
         BAL   R14,DMP                                                  00114600
         MVC   LINE+1(5),=C'NMTBL'                                      00114700
         BAL   R14,PRT                                                  00114800
         L     R1,=A(NMTBL)                                             00114900
         L     R0,NMTBPT                                                00115000
         SR    R0,R1                                                    00115100
         BAL   R14,DMP                                                  00115200
NODMPTB  DS    0H                                                       00115300
*********************************************************************** 00115400
*                                                                     * 00115500
*                                                                     * 00115600
*                                                                     * 00115700
*********************************************************************** 00115800
PROC     DS    0H                                                       00115900
         MVI   CHGSTMT,C' '                                             00116000
         GET   SYSUT1,CARD                                              00116100
         AP    RECIN,=P'+1'                                             00116200
         TM    FLAG,FLAGDBGL                                            00116300
         BNO   PROC010                                                  00116400
         MVC   LINE+1(L'CARD),CARD                                      00116500
         MVC   LINE+90(14),=C'Statement read'                           00116600
         BAL   R14,PRT                                                  00116700
PROC010  DS    0H                                                       00116800
         MVC   CURRCONT,CARD+71                                         00116900
         MVI   CARD+71,C' '            CLEAR CONTINUATION CHAR          00117000
         MVC   CURRSEQ,CARD+72                                          00117100
         MVC   CARD+72(8),=8C' '       CLEAR SEQUENCE FIELD             00117200
         CLI   CURRCONT,C' '                                            00117300
         BE    PROC011                                                  00117400
         AP    CONTCNT,=P'+1'                                           00117500
PROC011  DS    0H                                                       00117600
         LA    R2,CARD                                                  00117700
         CLI   CONTSTMT,C' '           PREV STMT CONTINUED              00117800
         BNE   PROCCS30                YES                              00117900
         CLI   CURRCONT,C' '           CURRENT STMT CONTINUED           00118000
         BE    PROC020                 NON-CONTINUED STATEMENT          00118100
*********************************************************************** 00118200
* FIRST OF SERIES OF CONTINUED STATEMENTS                             * 00118300
*********************************************************************** 00118400
         MVI   CONTINCM,C'N'                                            00118500
         LA    R0,LONGSTMT                                              00118600
         L     R1,=A(L'LONGSTMT)                                        00118700
         LA    R14,CARD                                                 00118800
         LA    R15,71                                                   00118900
         ICM   R15,8,=C' '                                              00119000
         MVCL  R0,R14                  COPY FIRST OF CONTINUED STMTS    00119100
         MVC   CONTSTMT,CURRCONT                                        00119200
         LA    R8,CONTSEQ                                               00119300
         MVC   0(8,R8),CURRSEQ                                          00119400
         LA    R8,L'CONTSEQ(,R8)                                        00119500
         LA    R3,LONGSTMT                                              00119600
         LR    R9,R3                                                    00119700
         A     R9,=A(L'LONGSTMT)                                        00119800
         LR    R2,R3                                                    00119900
         XC    QUOTLVL,QUOTLVL                                          00120000
         CLI   LONGSTMT,C' '           LABEL                            00120100
         BE    PROCCS10                                                 00120200
         BAL   R14,SCANBL              PAST LABEL                       00120300
         BNE   PROCEC03                LABEL WAY TO LONG                00120400
PROCCS10 DS    0H                                                       00120500
         BAL   R14,SCANNBL             GET START OF OPCODE              00120600
         BNE   PROCEC04                NO OPCODE                        00120700
         BAL   R14,SCANBL              END OF OPCODE                    00120800
         BNE   PROCEC05                OPCODE WAY TO LONG (OFF END)     00120900
         BAL   R14,SCANNBL             START OF OPERANDS                00121000
         BNE   PROCEC06                NO OPERANDS                      00121100
         LA    R4,LONGSTMT+71          LAST CHARACTER                   00121200
         B     PROCCS40                                                 00121300
*********************************************************************** 00121400
* REST OF SERIES OF CONTINUED STATEMENTS                              * 00121500
*********************************************************************** 00121600
PROCCS30 DS    0H                                                       00121700
         CLC   =CL15' ',CARD           FIRST 15 COLUMNS BLANK           00121800
         BNE   PROCEC01                NO, MUST BE BLANK                00121900
         C     R8,=A(CONTSEQZ)         END OF SAVED SEQUENCE NUMBERS    00122000
         BNL   PROCEC02                YES, ERROR                       00122100
         MVC   0(8,R8),CURRSEQ         SAVE CURRENT SEQUENCE NUMBER     00122200
         LA    R8,L'CONTSEQ(,R8)       NEXT SEQUENCE NUMBER             00122300
         MVC   0(70-15,R3),CARD+15     APPEND CURRENT STATEMENT         00122400
         LR    R2,R3                   START OF THIS CONTINUED PORTION  00122500
         LA    R4,70-15-1(,R3)         LAST CHARACTER                   00122600
*********************************************************************** 00122700
* SCAN TO END OF OPERANDS - REMOVE COMMENTS ON CONTINUED STATMENTS    * 00122800
*********************************************************************** 00122900
PROCCS40 DS    0H                                                       00123000
         LR    R1,R3                   IF CONTINUED STATMENT IS COMMENT 00123100
         CLI   CONTINCM,C'Y'           END OF OPERANDS AND IN COMMENT   00123200
         BE    PROCCS72                YES, CLEAR COMMENTS              00123300
         CLI   0(R3),C''''             QUOTE                            00123400
         BNE   PROCCS50                                                 00123500
         LA    R0,1                                                     00123600
         A     R0,QUOTLVL              COUNT QUOTES                     00123700
         ST    R0,QUOTLVL                                               00123800
         B     PROCCS62                                                 00123900
PROCCS50 DS    0H                                                       00124000
         CLI   0(R3),C','              COMMA                            00124100
         BNE   PROCCS61                                                 00124200
         TM    QUOTLVL+3,1             EVEN # QUOTES                    00124300
         BO    PROCCS62                NO, COMMA IN QUOTES IGNORE IT    00124400
         MVI   CONTINCM,C','           LAST SEEN CHARACTER IS COMMA     00124500
         B     PROCCS63                GO HANDLE NEXT CHARACTER         00124600
PROCCS61 DS    0H                                                       00124700
         CLI   0(R3),C' '              BLANK                            00124800
         BNE   PROCCS62                                                 00124900
         TM    QUOTLVL+3,1             EVEN # QUOTES                    00125000
         BO    PROCCS62                NO                               00125100
         CLI   CONTINCM,C','           LAST CHARACTER SEEN A COMMA      00125200
         BNE   PROCCS70                NO, REST OF STMTS ARE COMMENTS   00125300
         B     PROCCS71                CLEAR REST OF LINE               00125400
PROCCS62 DS    0H                                                       00125500
         MVI   CONTINCM,C'N'           LAST CHARACTER IS NOT A COMMA    00125600
PROCCS63 DS    0H                                                       00125700
         CR    R3,R4                                                    00125800
         BE    PROCCS73                END OF STATEMENT                 00125900
         LA    R3,1(,R3)                                                00126000
         B     PROCCS40                                                 00126100
PROCCS70 DS    0H                                                       00126200
         MVI   CONTINCM,C'Y'           WE ARE NOW IN COMMENTS           00126300
PROCCS71 DS    0H                                                       00126400
*        BLANK OUT ANY COMMENTS ON CONTINUED STATEMENTS                 00126500
         LA    R1,1(,R3)               NEXT CONTINUED STATEMENT HERE    00126600
PROCCS72 DS    0H                                                       00126700
         CR    R1,R4                   END OF STATEMENT                 00126800
         BNL   PROCCS73                YES, DONE BLANKING               00126900
         MVI   0(R1),C' '                                               00127000
         LA    R1,1(,R1)                                                00127100
         B     PROCCS72                                                 00127200
PROCCS73 DS    0H                                                       00127300
         CLI   CURRCONT,C' '           CURRENT STMT CONTINUED           00127400
         BNE   PROCEND                 YES, KEEP LOADING THEM           00127500
*********************************************************************** 00127600
* ALL STATEMENTS LOADED IN CONTIGIOUS MANNER NO COMMENTS              * 00127700
*********************************************************************** 00127800
         TM    FLAG,FLAGDBGS                                            00127900
         BNO   PROCCSD0                                                 00128000
*        PRINT REFORMATTED STATEMENT                                    00128100
         LA    R4,LONGSTMT                                              00128200
         MVC   LINE+1(71),0(R4)                                         00128300
         MVC   LINE+90(14),=C'Continued line'                           00128400
         BAL   R14,PRT                                                  00128500
         LA    R4,71(,R4)                                               00128600
PROCCSA0 DS    0H                                                       00128700
         CLI   0(R4),C' '                                               00128800
         BNE   PROCCSB0                                                 00128900
         CLC   0(71-15-1,R4),1(R4)                                      00129000
         BE    PROCCSC0                                                 00129100
PROCCSB0 DS    0H                                                       00129200
         MVC   LINE+17(71-15),0(R4)                                     00129300
         MVC   LINE+90(14),=C'Continued line'                           00129400
         BAL   R14,PRT                                                  00129500
         LA    R4,71-15(,R4)                                            00129600
         CR    R4,R9                                                    00129700
         BNL   PROCCSA0                                                 00129800
PROCCSC0 DS    0H                                                       00129900
PROCCSD0 DS    0H                                                       00130000
         B     PROCOP                                                   00130100
*********************************************************************** 00130200
* SINGLE CARD STATEMENT                                               * 00130300
*********************************************************************** 00130400
PROC020  DS    0H                                                       00130500
         LA    R8,CONTSEQ                                               00130600
         MVC   0(8,R8),CURRSEQ                                          00130700
         LA    R8,L'CONTSEQ(,R8)                                        00130800
         LA    R0,LONGSTMT                                              00130900
         L     R1,=A(L'LONGSTMT)                                        00131000
         LA    R14,CARD                                                 00131100
         LA    R15,71                                                   00131200
         ICM   R15,8,=C' '                                              00131300
         MVCL  R0,R14                  MOVE SINGLE STMT TO LONG STMT    00131400
         CLC   LONGSTMT+64(3),=C'DSK'                                   00131500
         BNE   PROC021                                                  00131600
         CLI   LONGSTMT+67,C'0'                                         00131700
         BL    PROC021                                                  00131800
         CLI   LONGSTMT+68,C'0'                                         00131900
         BL    PROC021                                                  00132000
         CLI   LONGSTMT+69,C'0'                                         00132100
         BL    PROC021                                                  00132200
         CLI   LONGSTMT+70,C'0'                                         00132300
         BL    PROC021                                                  00132400
         MVC   LONGSTMT+64(7),=CL15' ' CLEAR MY PREVIOUS PTFID          00132500
PROC021  DS    0H                                                       00132600
*********************************************************************** 00132700
* PROCESS SINGLE/REASSEMBLED CONTINUED STATEMENT                      * 00132800
*********************************************************************** 00132900
PROCOP   DS    0H                                                       00133000
         CLI   LONGSTMT,C'*'           SKIP COMMENTS                    00133100
         BE    PROCCM                                                   00133200
         CLI   LONGSTMT,C' '           LABEL?                           00133300
         BE    PROCOP00                NO, CONTINUE                     00133400
*********************************************************************** 00133500
* HANDLE LABEL IN COLUMN 1 EQUATES ONLY                               * 00133600
*   LABEL EQU OPERANDS (OPERANDS COULD BE QUOTED STRINGS WITH BLANK)  * 00133700
*********************************************************************** 00133800
PROCLB   DS    0H                                                       00133900
         LA    R2,LONGSTMT             START OF STATEMENT               00134000
         LR    R9,R2                                                    00134100
         A     R9,=A(L'LONGSTMT)       END OF STATEMENT                 00134200
         LR    R3,R2                   CURRENT STATEMENT POINTER        00134300
         BAL   R14,CHKLBL              LABEL MATCH                      00134400
         BNE   PROCLB30                NO, HANDLE SPECIAL EQUATES       00134500
         TM    FLAG,FLAGDBGS                                            00134600
         BNO   PROCLB20                                                 00134700
         MVC   LINE+1(L'CARD),0(R2)                                     00134800
         BAL   R14,PRT                                                  00134900
         LR    R1,R3                                                    00135000
         SR    R1,R2                                                    00135100
         LA    R1,LINE+1(R1)                                            00135200
         MVC   0(13,R1),=C'* Label match'                               00135300
         BAL   R14,PRT                                                  00135400
PROCLB20 DS    0H                                                       00135500
         BAL   R14,SCANBL              FIND BLANK END OF LABEL          00135600
         BNE   PROCEL01                LINE WITH ONLY LABEL             00135700
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPCODE   00135800
         BNE   PROCEL02                LINE FULL WITHOUT 3 FIELDS       00135900
         CLC   =C'EQU ',0(R3)          IS OPCODE EQU                    00136000
         BNE   PROCOP00                PREFIX AS LABEL ON INSTRUCTION   00136100
         BAL   R14,SCANBL              FIND BLANK END OF OPCODE         00136200
         BNE   PROCEL03                LINE FULL WITHOUT 3 FIELDS       00136300
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPERANDS 00136400
         BNE   PROCEL04                LINE FULL WITHOUT 3 FIELDS       00136500
         BAL   R14,SCANBL              FIND BLANK END OF OPERANDS       00136600
         BNE   PROCEL05                LINE FULL WITHOUT 3 FIELDS       00136700
         LA    R3,1(,R3)               PAST BLANK AFTER OPERAND END     00136800
         B     PROCLB60                THIS EQUATE BEING COMMENTED      00136900
*        HANDLE  PL/S EQUATES                                           00137000
PROCLB30 DS    0H                                                       00137100
         CLC   =C'@00 ',0(R3)                                           00137200
         BE    PROCLB40                                                 00137300
         CLC   =C'@01 ',0(R3)                                           00137400
         BE    PROCLB40                                                 00137500
         CLC   =C'@02 ',0(R3)                                           00137600
         BE    PROCLB40                                                 00137700
         CLC   =C'@03 ',0(R3)                                           00137800
         BE    PROCLB40                                                 00137900
         CLC   =C'@04 ',0(R3)                                           00138000
         BE    PROCLB40                                                 00138100
         CLC   =C'@05 ',0(R3)                                           00138200
         BE    PROCLB40                                                 00138300
         CLC   =C'@06 ',0(R3)                                           00138400
         BE    PROCLB40                                                 00138500
         CLC   =C'@07 ',0(R3)                                           00138600
         BE    PROCLB40                                                 00138700
         CLC   =C'@08 ',0(R3)                                           00138800
         BE    PROCLB40                                                 00138900
         CLC   =C'@09 ',0(R3)                                           00139000
         BE    PROCLB40                                                 00139100
         CLC   =C'@10 ',0(R3)                                           00139200
         BE    PROCLB40                                                 00139300
         CLC   =C'@11 ',0(R3)                                           00139400
         BE    PROCLB40                                                 00139500
         CLC   =C'@12 ',0(R3)                                           00139600
         BE    PROCLB40                                                 00139700
         CLC   =C'@13 ',0(R3)                                           00139800
         BE    PROCLB40                                                 00139900
         CLC   =C'@14 ',0(R3)                                           00140000
         BE    PROCLB40                                                 00140100
         CLC   =C'@15 ',0(R3)                                           00140200
         BE    PROCLB40                                                 00140300
*        LETS CHECK FOR EQUATE AND HANDLE IT'S SECOND OPERAND           00140400
         BAL   R14,SCANBL              FIND BLANK END OF LABEL          00140500
         BNE   PROCEL06                LINE WITH ONLY LABEL             00140600
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPCODE   00140700
         BNE   PROCEL07                LINE FULL WITHOUT 3 FIELDS       00140800
         CLC   =C'EQU ',0(R3)          IS OPCODE EQU                    00140900
         BNE   PROCOP00                NO, SKIP EQUATE PROCESSING       00141000
         BAL   R14,SCANBL              FIND BLANK END OF OPCODE         00141100
         BNE   PROCEL08                LINE FULL WITHOUT 3 FIELDS       00141200
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPERANDS 00141300
         BNE   PROCEL09                LINE FULL WITHOUT 3 FIELDS       00141400
         CLC   =C'@NM0',0(R2)          IS IT A @NMNNNNN EQU VALUE       00141500
         BE    PROCLB45                                                 00141600
         CLC   =C'@00 ',0(R3)                                           00141700
         BE    PROCLB50                                                 00141800
         CLC   =C'@01 ',0(R3)                                           00141900
         BE    PROCLB50                                                 00142000
         CLC   =C'@02 ',0(R3)                                           00142100
         BE    PROCLB50                                                 00142200
         CLC   =C'@03 ',0(R3)                                           00142300
         BE    PROCLB50                                                 00142400
         CLC   =C'@04 ',0(R3)                                           00142500
         BE    PROCLB50                                                 00142600
         CLC   =C'@05 ',0(R3)                                           00142700
         BE    PROCLB50                                                 00142800
         CLC   =C'@06 ',0(R3)                                           00142900
         BE    PROCLB50                                                 00143000
         CLC   =C'@07 ',0(R3)                                           00143100
         BE    PROCLB50                                                 00143200
         CLC   =C'@08 ',0(R3)                                           00143300
         BE    PROCLB50                                                 00143400
         CLC   =C'@09 ',0(R3)                                           00143500
         BE    PROCLB50                                                 00143600
         CLC   =C'@10 ',0(R3)                                           00143700
         BE    PROCLB50                                                 00143800
         CLC   =C'@11 ',0(R3)                                           00143900
         BE    PROCLB50                                                 00144000
         CLC   =C'@12 ',0(R3)                                           00144100
         BE    PROCLB50                                                 00144200
         CLC   =C'@13 ',0(R3)                                           00144300
         BE    PROCLB50                                                 00144400
         CLC   =C'@14 ',0(R3)                                           00144500
         BE    PROCLB50                                                 00144600
         CLC   =C'@15 ',0(R3)                                           00144700
         BE    PROCLB50                                                 00144800
         B     PROCOP00                WE MAY CHANGE EQU SECOND OPERAND 00144900
PROCLB40 DS    0H                                                       00145000
*        HANDLING @XX EQUATES                                           00145100
         BAL   R14,SCANBL              FIND BLANK END OF LABEL          00145200
         BNE   PROCEL10                LINE WITH ONLY LABEL             00145300
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPCODE   00145400
         BNE   PROCEL11                LINE FULL WITHOUT 3 FIELDS       00145500
         CLC   =C'EQU ',0(R3)          IS OPCODE EQU                    00145600
         BNE   PROCOP00                @XX AS LABEL ON NON EQUATE       00145700
         BAL   R14,SCANBL              FIND BLANK END OF OPCODE         00145800
         BNE   PROCEL12                LINE FULL WITHOUT 3 FIELDS       00145900
         BAL   R14,SCANNBL             FIND NON-BLANK START OF OPERANDS 00146000
         BNE   PROCEL13                LINE FULL WITHOUT 3 FIELDS       00146100
         LA    R3,3(,R3)               PAST @XX                         00146200
         CLC   =C'@00 ',0(R2)          @00 EQUATE                       00146300
         BNE   PROCLB60                                                 00146400
*        GENERATE DSECTS BEFORE EQUATES                                 00146500
*        IT APPEAR @00 IS BEST PLACE TO INSERT DSECTS                   00146600
         L     R4,=A(INSTBL)                                            00146700
         USING INSTB,R4                                                 00146800
PROCLB41 DS    0H                                                       00146900
         C     R4,INSTBPT                LAST MACRO                     00147000
         BNL   PROCLB60                                                 00147100
         CLI   INSTBUSD,C'Y'             MACRO NEEDED                   00147200
         BNE   PROCLB42                                                 00147300
         MVI   INSTBUSD,C'D'             MARK MACRO GENERATION DONE     00147400
         MVI   NEWCARD,C' '              CLEAR FOR STATEMENT            00147500
         MVC   NEWCARD+1(L'NEWCARD),NEWCARD                             00147600
         MVC   NEWCARD(L'INSTBCRD),INSTBCRD COPY MACRO STATEMENT        00147700
         MVI   NEWCARD+63,C' '           CLEAR BEFORE PTFID             00147800
         MVC   NEWCARD+64(L'PTFID),PTFID SET PTFID                      00147900
         AP    RECINS,=P'+1'                                            00148000
         MVI   NEWCARD+71,C' '           CLEAR CONTINUATION COLUMN      00148100
         MVC   NEWCARD+72(8),CURRSEQ     SEQUENCE NUMBER                00148200
         BAL   R14,PUT                                                  00148300
         PACK  DWORD,CURRSEQ             GET CURRENT SEQUENCE           00148400
         AP    DWORD,=P'+1'              ADD 1                          00148500
         OI    DWORD+7,X'0F'                                            00148600
         UNPK  NEWCARD+71(9),DWORD+3(5)  ADD SEQUENCE TO STATEMENT      00148700
         MVC   CURRSEQ,NEWCARD+72        UPDATE CURRENT SEQUENCE NUMBER 00148800
PROCLB42 DS    0H                                                       00148900
         LA    R4,INSTBNX                                               00149000
         B     PROCLB41                                                 00149100
         DROP  R4                                                       00149200
*        @NMNNNNN PL/S EQUATE                                           00149300
*        IF NOT REFERENCED IN SOURCE DELETE IT                          00149400
PROCLB45 DS    0H                                                       00149500
         L     R15,=A(NMTBL)                                            00149600
         USING NMTB,R15                                                 00149700
PROCLB46 DS    0H                                                       00149800
         CLC   NMTBNM,0(R3)            SYMBOL MATCH @NM ENTRY           00149900
         BE    PROCLB47                @NM EQUATE NAME FOUND IN SOURCE  00150000
         LA    R15,NMTBNX              NEXT ENTRY                       00150100
         C     R15,NMTBPT              AT END OF @NM ENTRIES            00150200
         BL    PROCLB46                NO, CONTINUE SEARCH              00150300
         B     PROCLB48                NOT FOUND                        00150400
PROCLB47 DS    0H                                                       00150500
         CLI   NMTBUSD,C'Y'            SYMBOL REFERENCED                00150600
         BE    PROCOP00                YES, KEEP THIS EQUATE            00150700
         DROP  R15                                                      00150800
PROCLB48 DS    0H                                                       00150900
         BAL   R14,SCANBL              FIND BLANK END OF LABEL          00151000
         BNE   PROCEL14                LINE REAL LONG LABEL             00151100
         B     PROCLB60                THIS EQUATE BEING COMMENTED      00151200
*        EQUATE TO REGISTER BEING COMMENTED OUT                         00151300
PROCLB50 DS    0H                                                       00151400
         LA    R3,4(,R3)               OVER @XX AS SECOND OPERAND       00151500
PROCLB60 DS    0H                                                       00151600
         LR    R14,R2                                                   00151700
         LR    R4,R3                                                    00151800
         SR    R4,R14                                                   00151900
         CH    R4,=AL2(72-10)                                           00152000
         BH    PROCEL15                LINE CAN'T BE COMMENTED OUT      00152100
         TM    FLAG,FLAGDBGS                                            00152200
         BNO   PROCOP65                                                 00152300
         MVC   LINE+1(80),0(R2)                                         00152400
         BAL   R14,PRT                                                  00152500
         LA    R1,LINE+1+9                                              00152600
         MVC   0(19,R1),=C'* Statement updated'                         00152700
         BAL   R14,PRT                                                  00152800
PROCOP65 DS    0H                                                       00152900
         MVI   NEWCARD,C' '            CLEAR NEW STATEMENT              00153000
         MVC   NEWCARD+1(L'NEWCARD),NEWCARD                             00153100
         BCTR  R4,0                                                     00153200
         EX    R4,CMTMVC               MVC   NEWCARD+9(0),0(R2)         00153300
         MVC   NEWCARD+72(8),CURRSEQ   SEQUENCE NUMBER                  00153400
         MVI   NEWCARD,C'*'            COMMENT OUT EQUATE STATEMENT     00153500
         MVC   NEWCARD+1(L'PTFID),PTFID                                 00153600
         MVI   NEWCARD+L'PTFID+1,C' '                                   00153700
         TM    FLAG,FLAGDBGL                                            00153800
         BNO   PROCLB70                                                 00153900
         MVC   LINE+1(80),NEWCARD                                       00154000
         MVC   LINE+90(17),=C'Updated statement'                        00154100
         BAL   R14,PRT                                                  00154200
PROCLB70 DS    0H                                                       00154300
         AP    RECCHG,=P'+1'                                            00154400
         BAL   R14,PUT                                                  00154500
         B     PROCEND                                                  00154600
CMTMVC   MVC   NEWCARD+9(0),0(R2)                                       00154700
*********************************************************************** 00154800
* SKIP OVER LABEL IF PRESENT                                          * 00154900
*********************************************************************** 00155000
PROCOP00 DS    0H                                                       00155100
         LA    R2,LONGSTMT             START OF STATEMENT               00155200
         LR    R9,R2                                                    00155300
         A     R9,=A(L'LONGSTMT)       END OF STATEMENT                 00155400
         LR    R3,R2                   CURRENT STATEMENT POINTER        00155500
         CLI   LONGSTMT,C' '           LABEL?                           00155600
         BE    PROCOP10                NO                               00155700
         BAL   R14,SCANBL              GET LABEL END                    00155800
         BNE   PROCEO01                ALL BLANK LINE SHOULDN'T OCCUR   00155900
PROCOP10 DS    0H                                                       00156000
         BAL   R14,SCANNBL             GET OPCODE START                 00156100
         BNE   PROCEO02                NO OPCODE                        00156200
*********************************************************************** 00156300
* HANDLE OPCODE                                                       * 00156400
*********************************************************************** 00156500
         LA    R0,L'OPCODE             SIZE OF OPCODE                04 00156600
         LA    R1,OPCODE               OPCODE SAVE AREA              04 00156700
         MVI   OPCODE,C' '             CLEAR OPCODE SAVE AREA        04 00156800
         MVC   OPCODE+1(L'OPCODE-1),OPCODE                           04 00156900
         LR    R15,R3                  START OF OPCODE IN STATEMENT     00157000
PROCOP11 DS    0H                                                       00157100
         MVC   0(1,R1),0(R15)          COPY OPCODE                      00157200
         LA    R1,1(,R1)               NEXT CHARACTER                   00157300
         LA    R15,1(,R15)             NEXT CHARACTER                   00157400
         CLI   0(R15),C' '             END OF OPCODE                    00157500
         BE    PROCOP12                YES                              00157600
         BCT   R0,PROCOP11             MOVE WHOLE OPCODE                00157700
PROCOP12 DS    0H                                                       00157800
         CLC   =C'END ',OPCODE                                          00157900
         BE    PROCIN                                                   00158000
**       CLC   =C'IPK ',OPCODE         IPK HAS NO OPERANDS              00158100
**       BE    PROCEND                                                  00158200
         CLC   =C'TITLE ',OPCODE       TITLE                            00158300
         BE    PROCEND                                                  00158400
**       CLC   =C'CSECT ',OPCODE       CSECT                            00158500
**       BE    PROCEND                                                  00158600
**       CLC   =C'IKJIDENT ',OPCODE    IKJIDENT                         00158700
**       BE    PROCOPIA                                                 00158800
**       CLC   =C'RESERVE ',OPCODE     RESERVE                          00158900
**       BE    PROCOPIA                                                 00159000
**       CLC   =C'GENCB ',OPCODE       GENCB                            00159100
**       BE    PROCOPIA                                                 00159200
**       CLC   =C'PGFIX ',OPCODE       PGFIX                            00159300
**       BE    PROCOPIA                                                 00159400
**       CLC   =C'PGFREE ',OPCODE      PGFREE                           00159500
**       BE    PROCOPIA                                                 00159600
**       CLC   =C'SETLOCK ',OPCODE     SETLOCK                          00159700
**       BE    PROCOPIA                                                 00159800
**       CLC   =C'CALLRTM ',OPCODE     CALLRTM                          00159900
**       BE    PROCOPIA                                                 00160000
**       CLC   =C'RECORD ',OPCODE      RECORD                           00160100
**       BE    PROCOPIA                                                 00160200
**       CLC   =C'BLDCPOOL ',OPCODE    BLDCPOOL                         00160300
**       BE    PROCOPIA                                                 00160400
         CLC   =C'SCHEDULE ',OPCODE    SCHEDULE                         00160500
         BE    PROCOIA0                YES, MARK IHASRB AS NEEDED       00160600
**       CLC   =C'SDUMP ',OPCODE       SDUMP                            00160700
**       BE    PROCOPIA                                                 00160800
         CLC   =C'SETFRR ',OPCODE      SETFRR                           00160900
         BE    PROCOIB0                YES, MARK IHAFRRS AS NEEDED      00161000
**       CLC   =C'IOSGEN ',OPCODE      IOSGEN                           00161100
**       BE    PROCOPIA                                                 00161200
**       CLC   =C'DCB ',OPCODE         IGNORE                           00161300
**       BE    PROCOPIA                                                 00161400
         MVI   SPEC2OP,C' '                                             00161500
         CLC   =C'OI ',OPCODE          SPECIAL OPCODE                   00161600
         BE    PROCOP15                                                 00161700
         CLC   =C'MVI',OPCODE          SPECIAL OPCODE                   00161800
         BE    PROCOP15                                                 00161900
         CLC   =C'NI ',OPCODE          SPECIAL OPCODE                   00162000
         BE    PROCOP15                                                 00162100
         CLC   =C'CLI',OPCODE          SPECIAL OPCODE                   00162200
         BE    PROCOP15                                                 00162300
         CLC   =C'TM ',OPCODE          SPECIAL OPCODE                   00162400
         BE    PROCOP15                                                 00162500
         CLC   =C'XI ',OPCODE          SPECIAL OPCODE                   00162600
         BE    PROCOP15                                                 00162700
         B     PROCOP16                                                 00162800
*********************************************************************** 00162900
* SPECIAL OPCODE PROCESSING                                           * 00163000
*********************************************************************** 00163100
*        SCHEDULE - REQUIRES IHASRB DSECT                               00163200
PROCOIA0 DS    0H                                                       00163300
         L     R1,=A(INSTBL)                                            00163400
         USING INSTB,R1                                                 00163500
PROCOIA1 DS    0H                                                       00163600
         CLC   =C' IHASRB ',INSTBCRD+8 SEARCH FOR IHASRB DSECT          00163700
         BE    PROCOIA3                                                 00163800
PROCOIA2 DS    0H                                                       00163900
         LA    R1,INSTBNX                                               00164000
         C     R1,INSTBPT                                               00164100
         BL    PROCOIA1                                                 00164200
         B     PROCOIA4                                                 00164300
PROCOIA3 DS    0H                                                       00164400
         MVI   INSTBUSD,C'Y'           MARK DSECT AS USED               00164500
         B     PROCOIA2                SEARCH REST OF TABLE             00164600
PROCOIA4 DS    0H                                                       00164700
         DROP  R1                                                       00164800
         B     PROCOP16                                                 00164900
*        SCHEDULE - REQUIRES IHASRB DSECT                               00165000
PROCOIB0 DS    0H                                                       00165100
         L     R1,=A(INSTBL)                                            00165200
         USING INSTB,R1                                                 00165300
PROCOIB1 DS    0H                                                       00165400
         CLC   =C' IHAFRRS ',INSTBCRD+8 SEARCH FOR IHAFRRS DSECT        00165500
         BE    PROCOIB3                                                 00165600
         CLC   =C' IHAPSA ',INSTBCRD+8 SEARCH FOR IHAPSA DSECT          00165700
         BE    PROCOIB3                                                 00165800
PROCOIB2 DS    0H                                                       00165900
         LA    R1,INSTBNX                                               00166000
         C     R1,INSTBPT                                               00166100
         BL    PROCOIB1                                                 00166200
         B     PROCOIB4                                                 00166300
PROCOIB3 DS    0H                                                       00166400
         MVI   INSTBUSD,C'Y'           MARK DSECT AS USED               00166500
         B     PROCOIB2                SEARCH REST OF TABLE             00166600
PROCOIB4 DS    0H                                                       00166700
         DROP  R1                                                       00166800
         B     PROCOP16                                                 00166900
PROCOP15 DS    0H                                                       00167000
*        SETUP FOR SPECIAL IMMEDIATE SECOND OPERAND                     00167100
*        PL/S USED IMMEDIATE VALUE AS FIRST OPERAND                     00167200
*        WE CHANGE THE FIRST OPERAND TO THE ACTUAL FIRST OPERAND        00167300
*        AND USE THE FIRST OPERAND AS IMMEDIATE VALUE (EXCEPT IN        00167400
*        THE CASE OF NI WHERE WE WILL change the immediate operand      00167500
*        T0 255-FIRST OPERAND                                           00167600
*        EXAMPLE: OI    SDWARCRD(GPR01P),B'10000000'                    00167700
*                 OI    SDWAACF2(R1),SDWARCRD                           00167800
         MVC   SPEC2OP,0(R3)           SET SPECIAL SECOND OPERAND       00167900
PROCOP16 DS    0H                                                       00168000
         MVI   OPER1TB,X'80'           READY FOR FIRST OPERAND          00168100
         BAL   R14,SCANBL              GET OPCODE END                   00168200
         BNE   PROCEO03                OPCODE TOO LONG OR AT END        00168300
         BAL   R14,SCANNBL             GET OPERAND 1 START              00168400
         BNE   PROCEND                 ALL BLANK AFTER OPCODE S/B OK    00168500
*********************************************************************** 00168600
* COPY LABEL AND OPCODE TO FIRST OPERAND                              * 00168700
*********************************************************************** 00168800
         LA    R0,NEWSTMT              NEW LONG STATEMENT               00168900
         L     R1,=A(L'NEWSTMT)        LENGTH OF NEW STATEMENT          00169000
         LR    R14,R2                  START OF STATEMENT               00169100
         LR    R15,R3                  OPERAND ADDRESS                  00169200
         SR    R15,R2                  LESS START OF STATEMENT          00169300
         LA    R7,NEWSTMT(R15)         GET CURRENT NEW STATEMENT ADDR   00169400
         ICM   R15,8,=C' '             CLEAR UNUSED TO BLANKS           00169500
         MVCL  R0,R14                  SAVE REST OF LINE                00169600
*********************************************************************** 00169700
* HANDLE LABEL SUBSTITUTION AND CHECK LABEL PREFIX                    * 00169800
*********************************************************************** 00169900
PROCOP20 DS    0H                                                       00170000
         SR    R4,R4                   NO LABEL MATCH                   00170100
*        SPECIAL KEYWORD PROCESSING                                     00170200
         CLC   =C'RELATED=',0(R3)      IGNORE ANY RELATED= KEYWORD      00170300
         BE    PROCOP25                                                 00170400
         CLC   =C'SETLOCK ',OPCODE     SETLOCK MACRO                    00170500
         BNE   PROCOPSE                                                 00170600
         CLC   =C'TYPE=',0(R3)         IGNORE TYPE= KEYWORD AND OPERAND 00170700
         BNE   PROCOPSE                                                 00170800
PROCOPS1 DS    0H                                                       00170900
         CLI   0(R3),C','              SCAN FOR A COMMA                 00171000
         BE    PROCOP80                ON TO NEXT OPERAND               00171100
         MVC   0(1,R7),0(R3)                                            00171200
         LA    R7,1(,R7)                                                00171300
         LA    R3,1(,R3)                                                00171400
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00171500
         BH    PROCEO04                YES                              00171600
         BL    PROCOPS2                                                 00171700
         CLI   CHGSTMT,C'Y'            END OF STATMENT DONE             00171800
         BNE   PROCEND                 YES, LINE COMPLETELY FULL        00171900
         B     PROCEO05                REPLACEMENT CARD OVERFLOW        00172000
PROCOPS2 DS    0H                                                       00172100
         CR    R3,R9                                                    00172200
         BH    PROCEO06                REPLACEMENT CARD OVERFLOW        00172300
         B     PROCOPS1                                                 00172400
PROCOPSE DS    0H                                                       00172500
         BAL   R14,REGCHK              REGISTER EQUATE SUBSTITUTION     00172600
         BNE   PROCOP22                                                 00172700
         TM    FLAG,FLAGDBGS                                            00172800
         BNO   PROCOP21                                                 00172900
         ST    R1,REGCHKR1                                              00173000
         MVC   LINE+1(L'CARD),0(R2)                                     00173100
         MVC   LINE+90(13),=C'Old statement'                            00173200
         BAL   R14,PRT                                                  00173300
         L     R1,REGCHKR1                                              00173400
         SR    R1,R2                                                    00173500
         LA    R1,LINE+1(R1)                                            00173600
         MVC   0(30,R1),=C'* Register equate substitution'              00173700
         BAL   R14,PRT                                                  00173800
PROCOP21 DS    0H                                                       00173900
         B     PROCOP42                                                 00174000
PROCOP22 DS    0H                                                       00174100
         CLC   =C'USING ',OPCODE       SKIP LABEL SUBSTITUTE FOR USING  00174200
         BE    PROCOP30                                                 00174300
         BAL   R14,SUBLBL              SUBSTITUTE OPERAND               00174400
         BNE   PROCOP23                                                 00174500
         TM    FLAG,FLAGDBGS                                            00174600
         BNO   PROCOP23                                                 00174700
         MVC   LINE+1(L'CARD),0(R2)                                     00174800
         MVC   LINE+90(13),=C'Old statement'                            00174900
         BAL   R14,PRT                                                  00175000
         LR    R1,R3                                                    00175100
         SR    R1,R2                                                    00175200
         LA    R1,LINE+1(R1)                                            00175300
         MVC   0(20,R1),=C'* Label substitution'                        00175400
         BAL   R14,PRT                                                  00175500
PROCOP23 DS    0H                                                       00175600
         BAL   R14,CHKLBL                                               00175700
         USING MACTB,R4                                                 00175800
         LTR   R4,R4                                                    00175900
         BZ    PROCOP30                                                 00176000
         TM    FLAG,FLAGDBGS                                            00176100
         BNO   PROCOP30                                                 00176200
         MVC   LINE+1(L'CARD),0(R2)                                     00176300
         MVC   LINE+90(13),=C'Old statement'                            00176400
         BAL   R14,PRT                                                  00176500
         LR    R1,R3                                                    00176600
         SR    R1,R2                                                    00176700
         LA    R1,LINE+1(R1)                                            00176800
         MVC   0(13,R1),=C'* Label match'                               00176900
         BAL   R14,PRT                                                  00177000
         B     PROCOP30                                                 00177100
*********************************************************************** 00177200
* SCAN OFF RELATED= VALUE                                             * 00177300
*********************************************************************** 00177400
PROCOP25 DS    0H                                                       00177500
         MVC   0(8,R7),0(R3)           MOVE RELATED= KEYWORD            00177600
         LA    R3,8(,R3)                                                00177700
         LA    R7,8(R7)                                                 00177800
         CLI   0(R3),C'('              RELATED=(                        00177900
         BE    SCANOP2A                                                 00178000
         CLI   0(R3),C''''             RELATED='                        00178100
         BE    SCANOP2A                                                 00178200
         B     SCANOP2G                                                 00178300
SCANOP2A DS    0H                                                       00178400
         MVC   RELDLM,0(R3)            SAVE DELIMITER                   00178500
         LA    R1,1                                                     00178600
         B     SCANOP2F                                                 00178700
SCANOP2B DS    0H                                                       00178800
         CLI   RELDLM,C''''            QUOTE DELIMITER?                 00178900
         BNE   SCANOP2C                                                 00179000
*        A SCAN OF SOURCE FINDS NO IMBEDDED QUOTES                      00179100
*        SO DOUBLE QUOTES AND IMBEDDED QUOTES ISN'T HANDLED             00179200
         CLI   0(R3),C''''             DO WE HAVE A QUOTE               00179300
         BNE   SCANOP2F                                                 00179400
         MVI   RELDLM,C' '                                              00179500
         CLI   1(R3),C' '              ENSURE DELIMITER NEXT            00179600
         BE    SCANOP2F                                                 00179700
         CLI   1(R3),C','              ENSURE DELIMITER NEXT            00179800
         BE    SCANOP2F                                                 00179900
         B     PROCER01                OOPS                             00180000
SCANOP2C DS    0H                                                       00180100
         CLI   RELDLM,C'('             DELIMITER WAS LEFT PAREN         00180200
         BNE   SCANOP2E                                                 00180300
         CLI   0(R3),C'('              ANOTHER ONE                      00180400
         BNE   SCANOP2D                                                 00180500
         LA    R1,1(,R1)               COUNT THEM                       00180600
         B     SCANOP2F                                                 00180700
SCANOP2D DS    0H                                                       00180800
         CLI   0(R3),C')'              RIGHT PAREN                      00180900
         BNE   SCANOP2F                                                 00181000
*        A SCAN FINDS RELATED=(X,(Y)) SO LEVELS OF () NEED HANDLING     00181100
*        ALSO FOUND ARE:                                                00181200
*           RELATED=X-X/Y(Z)                                            00181300
*           RELATED=(X,X(X),X(X,X))                                     00181400
*           RELATED=('X XX XXX,XX')                                     00181500
*           RELATED=('X XX',X,X(X))                                     00181600
         SH    R1,=H'+1'               PAIR UP LEFT AND RIGHT PARENS    00181700
         BNZ   SCANOP2F                                                 00181800
         MVI   RELDLM,C' '                                              00181900
         CLI   1(R3),C' '              ENSURE DELIMITER NEXT            00182000
         BE    SCANOP2F                                                 00182100
         CLI   1(R3),C','              ENSURE DELIMITER NEXT            00182200
         BE    SCANOP2F                                                 00182300
         B     PROCER02                OOPS                             00182400
SCANOP2E DS    0H                                                       00182500
         CLI   0(R3),C','                                               00182600
         BE    PROCOP30                                                 00182700
         CLI   0(R3),C' '                                               00182800
         BE    PROCOP30                                                 00182900
SCANOP2F DS    0H                                                       00183000
         MVC   0(1,R7),0(R3)                                            00183100
         LA    R3,1(,R3)                                                00183200
         LA    R7,1(,R7)                                                00183300
SCANOP2G DS    0H                                                       00183400
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00183500
         BNH   SCANOP2H                NO                               00183600
         CLI   CHGSTMT,C'Y'            Statement changed                00183700
         BE    PROCEO07                YES, REPLACEMENT CARD OVERFLOW   00183800
         B     PROCEND                                                  00183900
SCANOP2H DS    0H                                                       00184000
         CR    R3,R9                                                    00184100
         BNH   SCANOP2B                                                 00184200
         CLI   CHGSTMT,C'Y'                                             00184300
         BNE   PROCEND                                                  00184400
         B     PROCEO08                OPERAND RAN TO END OF STMT       00184500
*********************************************************************** 00184600
* COPY OPERAND LABEL                                                  * 00184700
*********************************************************************** 00184800
PROCOP30 DS    0H                                                       00184900
         CLI   0(R3),C'('                                               00185000
         BE    PROCOP40                                                 00185100
         CLI   0(R3),C')'                                               00185200
         BE    PROCOP40                                                 00185300
         CLI   0(R3),C','                                               00185400
         BE    PROCOP40                                                 00185500
         CLI   0(R3),C'+'                                               00185600
         BE    PROCOP40                                                 00185700
         CLI   0(R3),C'-'                                               00185800
         BE    PROCOP4A                                                 00185900
         CLI   0(R3),C'*'                                               00186000
         BE    PROCOP40                                                 00186100
         CLI   0(R3),C'/'                                               00186200
         BE    PROCOP40                                                 00186300
         CLI   0(R3),C'='                                               00186400
         BE    PROCOP40                                                 00186500
         CLI   0(R3),C' '                                               00186600
         BE    PROCOP40                                                 00186700
         MVC   0(1,R7),0(R3)                                            00186800
         LA    R3,1(,R3)                                                00186900
         LA    R7,1(,R7)                                                00187000
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00187100
         BH    PROCEO09                YES                              00187200
         CR    R3,R9                                                    00187300
         BNH   PROCOP30                                                 00187400
         CLI   CHGSTMT,C'Y'                                             00187500
         BNE   PROCEND                                                  00187600
         B     PROCEO10                OPERAND RAN TO END OF STMT       00187700
PROCOP4A DS    0H                                                       00187800
**       IGNORE LABEL FOLLOWED BY '-'                                   00187900
**       MVC   0(1,R7),0(R3)           COPY - AND SKIP TO NEXT OPERAND  00188000
**       LA    R7,1(,R7)                                                00188100
**       LA    R3,1(,R3)                                                00188200
**       B     PROCOP50                                                 00188300
*        LABEL FOLLOWED BY '-' CHECK TO SEE IF WHAT FOLLOWS IS          00188400
*        THE DSECT PREFIX.  IF SO LEAVE IT AS IS                        00188500
         LTR   R4,R4                   LABEL FOUND IN TABLE             00188600
         BZ    PROCOP50                NO, JUST MOVE ON                 00188700
         LA    R15,1(,R3)              PAST '-'                         00188800
         LA    R0,8                    LENGTH OF LABEL AFTER '-'        00188900
PROCOP4B DS    0H                                                       00189000
         CLI   0(R15),C','             FIND END OF LABEL                00189100
         BE    PROCOP4C                                                 00189200
         CLI   0(R15),C'('                                              00189300
         BE    PROCOP4C                                                 00189400
         CLI   0(R15),C' '                                              00189500
         BE    PROCOP4C                                                 00189600
         LA    R15,1(,R15)                                              00189700
         BCT   R0,PROCOP4B                                              00189800
         B     PROCOP40                LABEL TO LONG OR UNEXPECTED DLM  00189900
PROCOP4M CLC   1(,R3),MACTBSY                                           00190000
PROCOP4C DS    0H                                                       00190100
         CH    R0,=H'+8'               - FOLLOWED BY ( OR , OR BLANK    00190200
         BE    PROCOP40                YES, NO LABEL HERE               00190300
         LA    R1,7                                                     00190400
         SR    R1,R0                   MACHINE LENGTH OF LABEL          00190500
         CH    R1,MACTBSYL             SAME LENGTH AS DSECT START LABEL 00190600
         BNE   PROCOP40                NO, NOT SAME LABEL               00190700
         EX    R1,PROCOP4M             CLC   1(,R3),MACTBSY             00190800
         BNE   PROCOP40                LABEL NOT MATCHED                00190900
         MVC   0(1,R7),0(R3)           COPY '-' THEN GO COPY THIS LABEL 00191000
         BAL   R14,FLGDS               MARK DSECT REFERENCED            00191100
         B     PROCOP70                LABEL-DSECT FOUND, SKIP BY IT    00191200
*********************************************************************** 00191300
* UPDATE OPERAND WITH '-' AND DSECT PREFIX                            * 00191400
*********************************************************************** 00191500
PROCOP40 DS    0H                                                       00191600
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00191700
         BH    PROCEO11                YES                              00191800
         CR    R3,R9                                                    00191900
         BH    PROCEO12                ORIGINAL OFF END OF STATEMENT    00192000
         LTR   R4,R4                                                    00192100
         BZ    PROCOP50                                                 00192200
         MVI   CHGSTMT,C'Y'                                             00192300
         BAL   R14,FLGDS               MARK DSECT REFERENCED            00192400
*        UPDATE OPERAND                                                 00192500
         TM    FLAG,FLAGNORL           No relative options set          00192600
         BO    PROCOP42                Yes, don't add "-base"           00192700
         MVI   0(R7),C'-'                                               00192800
         LA    R7,1(,R7)                                                00192900
         LH    R1,MACTBSYL                                              00193000
         EX    R1,MVCOP1               MVC   0(,R7),MACTBSY             00193100
         LA    R7,1(R1,R7)                                              00193200
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00193300
         BH    PROCEO13                YES                              00193400
         B     PROCOP42                                                 00193500
MVCOP1   MVC   0(,R7),MACTBSY                                           00193600
PROCOP42 DS    0H                                                       00193700
         TM    FLAG,FLAGDBGS                                            00193800
         BNO   PROCOP50                                                 00193900
         MVC   LINE+1(80),NEWSTMT                                       00194000
         MVC   LINE+90(13),=C'New statement'                            00194100
         BAL   R14,PRT                                                  00194200
         LR    R1,R7                                                    00194300
         S     R1,=A(NEWSTMT)                                           00194400
         LA    R1,LINE+1(R1)                                            00194500
         MVC   0(19,R1),=C'* Statement updated'                         00194600
         BAL   R14,PRT                                                  00194700
*********************************************************************** 00194800
* COPY UNTIL NEXT OPERAND                                             * 00194900
*********************************************************************** 00195000
PROCOP50 DS    0H                                                       00195100
         MVC   0(1,R7),0(R3)                                            00195200
         CLI   0(R7),C' '              END OF OPERANDS                  00195300
         BE    PROCOPM0                                                 00195400
         CLI   0(R7),C','                                               00195500
         BE    PROCOP76                                                 00195600
         CLI   0(R7),C'+'                                               00195700
         BE    PROCOP80                                                 00195800
         CLI   0(R7),C'-'                                               00195900
         BE    PROCOP80                                                 00196000
         CLI   0(R7),C'*'                                               00196100
         BE    PROCOP80                                                 00196200
         CLI   0(R7),C'/'                                               00196300
         BE    PROCOP80                                                 00196400
         CLI   0(R7),C'('                                               00196500
         BE    PROCOP80                                                 00196600
         CLI   0(R7),C')'                                               00196700
         BE    PROCOP80                                                 00196800
         CLI   0(R7),C'='                                               00196900
         BE    PROCOP80                                                 00197000
PROCOP70 DS    0H                                                       00197100
         LA    R7,1(,R7)                                                00197200
         LA    R3,1(,R3)                                                00197300
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00197400
         BH    PROCEO14                YES                              00197500
         BL    PROCOP75                                                 00197600
         CLI   CHGSTMT,C'Y'            END OF STATMENT DONE             00197700
         BNE   PROCEND                 YES, LINE COMPLETELY FULL        00197800
         B     PROCEO15                REPLACEMENT CARD OVERFLOW        00197900
PROCOP75 DS    0H                                                       00198000
         CR    R3,R9                                                    00198100
         BH    PROCEO16                REPLACEMENT CARD OVERFLOW        00198200
         B     PROCOP50                                                 00198300
PROCOP76 DS    0H                                                       00198400
*        CHECK FOR SPECIAL IMMEDIATE OPERAND SUBSTITUTION               00198500
         ICM   R1,15,OPER1TB          WE HAVE A LABEL MATCH             00198600
         BNP   PROCOP80                                                 00198700
         CLI   SPEC2OP,C' '           SPECIAL IMMEDIATE OPCODE          00198800
         BE    PROCOP80                                                 00198900
         CLC   =C',B''',0(R3)         OPERAND = B'NNNNNNNN'             00199000
         BNE   PROCOP80                                                 00199100
         CLC   =C''' ',11(R3)                                           00199200
         BNE   PROCOP80                                                 00199300
*        ENSURE THERE IS ONLY ONE 0 BIT ON IN B'NNNNNNNN' EXCEPT FOR NI 00199400
*        ENSURE THERE IS ONLY ONE 1 BIT ON IN B'NNNNNNNN' FOR NI        00199500
         LA    R0,0                                                     00199600
         LA    R1,3(,R3)                                                00199700
         LA    R14,8                                                    00199800
PROCOP71 DS    0H                                                       00199900
         CLI   SPEC2OP,C'N'           SPECIAL NI CASE                   00200000
         BE    PROCOP7B               CHECK FOR ONLY ONE 1 BIT          00200100
         CLI   0(R1),C'0'                                               00200200
         BE    PROCOP7D                                                 00200300
         CLI   0(R1),C'1'                                               00200400
         BNE   PROCOP80                                                 00200500
         B     PROCOP7C                                                 00200600
PROCOP7B DS    0H                     CHECK FOR ONLY ONE 0 BIT          00200700
         CLI   0(R1),C'1'                                               00200800
         BE    PROCOP7D                                                 00200900
         CLI   0(R1),C'0'                                               00201000
         BNE   PROCOP80                                                 00201100
PROCOP7C DS    0H                                                       00201200
*        THIS HANDLES CASES LIKE:                                       00201300
*          PL/S   IF UCB3TAPE='1'B|UCB3DACC='1'B                        00201400
*          ASM    TM    UCB3TAPE(UCBPTR),B'10100000'                    00201500
         LTR   R0,R0                  TO MANY 0/1 BITS                  00201600
         BNZ   PROCOP80                                                 00201700
         LA    R0,1                                                     00201800
PROCOP7D DS    0H                                                       00201900
         LA    R1,1(,R1)                                                00202000
         BCT   R14,PROCOP71                                             00202100
         MVI   LINE+122,C'5'                                            00202200
*        NOW WE HAVE THE SPECIAL IMMEDIATE OPERAND SUBSTITUTION         00202300
         LA    R1,12(,R3)             RIGHT AFTER B'NNNNNNNN'           00202400
         LR    R15,R9                 END OF STATEMENT                  00202500
         BAL   R14,RESTSAV            SAVE REST OF STATEMENT            00202600
         L     R1,OPER1TB             1ST OPERAND LABEL ENTRY           00202700
         USING CHGTB,R1                                                 00202800
         CLI   SPEC2OP,C'N'           SPECIAL NI CASE                   00202900
         BNE   PROCOP77               NO, HANDLE NON-NI CASE            00203000
         MVC   1(4,R7),=C'255-'       START IMMEDIATE OPERAND WITH 255- 00203100
         MVC   5(8,R7),CHGTBNM        JUST COPY ALL OF SYMBOL S/B OK    00203200
         AH    R7,CHGTBNML            NEW SYMBOL LENGTH                 00203300
         LA    R7,6(,R7)              ADD FOR 255-, AND MACHINE LENGTH  00203400
         B     PROCOP78                                                 00203500
PROCOP77 DS    0H                                                       00203600
         MVC   1(8,R7),CHGTBNM        JUST COPY ALL OF SYMBOL S/B OK    00203700
         AH    R7,CHGTBNML            NEW SYMBOL LENGTH                 00203800
         LA    R7,2(,R7)              ADD FOR MACHINE LENGTH            00203900
         DROP  R1                                                       00204000
PROCOP78 DS    0H                                                       00204100
         LR    R1,R7                  AFTER NEW SYMBOL                  00204200
         L     R15,=A(NEWSTMT+L'NEWSTMT-1) END OF NEW STATEMENT         00204300
         BAL   R14,RESTRES            COPY REST OF STMT TO NEW STMT     00204400
         LA    R3,11(,R3)             ADD IN LENGTH OF B'NNNNNNNN'      00204500
         TM    FLAG,FLAGDBGS                                            00204600
         BNO   PROCOP79                                                 00204700
         MVC   LINE+1(81),NEWSTMT                                       00204800
         MVC   LINE+82(13),=C'New statement'                            00204900
         BAL   R14,PRT                                                  00205000
         LR    R1,R7                                                    00205100
         S     R1,=A(NEWSTMT)                                           00205200
         LA    R1,LINE+1(R1)                                            00205300
         MVC   0(32,R1),=C'* Immediate operand substitution'            00205400
         BAL   R14,PRT                                                  00205500
PROCOP79 DS    0H                                                       00205600
         MVI   SPEC2OP,C' '                                             00205700
*********************************************************************** 00205800
* SKIP OVER OPERAND DELIMITER                                         * 00205900
*********************************************************************** 00206000
PROCOP80 DS    0H                                                       00206100
         LA    R7,1(,R7)                                                00206200
         LA    R3,1(,R3)                                                00206300
         C     R7,=A(NEWSTMT+L'NEWSTMT-1) REPLACEMENT CARD OVERFLOW     00206400
         BH    PROCEO17                YES                              00206500
         BL    PROCOP85                                                 00206600
         CLI   CHGSTMT,C'Y'            STATEMENT ALTERED                00206700
         BNE   PROCEND                 YES, LINE COMPLETELY FULL        00206800
         B     PROCEO18                REPLACEMENT CARD OVERFLOW        00206900
PROCOP85 DS    0H                                                       00207000
         CR    R3,R9                                                    00207100
         BH    PROCEO19                REPLACEMENT CARD OVERFLOW        00207200
         B     PROCOP20                NEXT OPERAND                     00207300
*********************************************************************** 00207400
* END OF ALL OPERANDS                                                 * 00207500
*********************************************************************** 00207600
PROCOPM0 DS    0H                                                       00207700
         CLI   CHGSTMT,C'Y'            WE CHANGE ANY OF STATEMENT       00207800
         BNE   PROCEND                                                  00207900
PROCOPN0 DS    0H                                                       00208000
         LA    R4,CONTSEQ              START OF SAVED SEQUENCE NUMBERS  00208100
         LA    R0,NEWSTMT+63                                            00208200
         CR    R7,R0                   ROOM FOR PTFID ON FIRST STMT     00208300
         BL    PROCOPP0                YES                              00208400
*        NEW STATEMENT BEYOND COLUMN 64                                 00208500
         LA    R0,NEWSTMT+70                                            00208600
         CR    R7,R0                                                    00208700
         BH    PROCOPOA                                                 00208800
*        NEW STATEMENT FITS ON ONE CARD BUT NO ROOM FOR PTF ID          00208900
         MVC   NEWCARD,NEWSTMT                                          00209000
         MVI   NEWCARD+71,C'~'         CONTINUED                        00209100
         MVC   NEWCARD+72(8),0(R4)     SEQUENCE NUMBER                  00209200
         AP    CHGCONT,=P'+1'                                           00209300
         BAL   R14,PUT                                                  00209400
         MVI   NEWCARD,C' '                                             00209500
         MVC   NEWCARD+1(63),NEWCARD   ALL BUT PTFID ON                 00209600
         MVC   NEWCARD+64(L'PTFID),PTFID                                00209700
         PACK  DWORD,NEWCARD+72(8)                                      00209800
         AP    DWORD,=P'+1'                                             00209900
         OI    DWORD+7,X'0F'                                            00210000
         UNPK  NEWCARD+71(9),DWORD+3(5)                                 00210100
         MVI   NEWCARD+71,C' '                                          00210200
         AP    CHGCONT,=P'+1'                                           00210300
         BAL   R14,PUT                                                  00210400
         B     PROCOPR0                                                 00210500
*        NEW STATEMENT FITS ON MULTIPLE CARDS                           00210600
PROCOPOA DS    0H                                                       00210700
         MVC   NEWCARD(71),NEWSTMT                                      00210800
         MVI   NEWCARD+71,C'~'         CONTINUED                        00210900
         MVC   NEWCARD+72(8),0(R4)     SEQUENCE NUMBER                  00211000
         AP    CHGCONT,=P'+1'                                           00211100
         BAL   R14,PUT                                                  00211200
         AP    CHGCONT,=P'+1'                                           00211300
         LA    R2,NEWSTMT+71                                            00211400
PROCOPOB DS    0H                                                       00211500
         MVC   NEWCARD(15),=CL15' '                                     00211600
         MVC   NEWCARD+15(71-15),0(R2)                                  00211700
         LA    R2,71-15(,R2)                                            00211800
         CR    R2,R7                   END OF CONTINUED BUFFER          00211900
         BNL   PROCOPOC                YES, HANDLE LAST STATEMENT       00212000
         PACK  DWORD,NEWCARD+72(8)                                      00212100
         AP    DWORD,=P'+1'                                             00212200
         OI    DWORD+7,X'0F'                                            00212300
         UNPK  NEWCARD+71(9),DWORD+3(5)                                 00212400
         MVI   NEWCARD+71,C'B'         CONTINUED                        00212500
         AP    CHGCONT,=P'+1'                                           00212600
         BAL   R14,PUT                                                  00212700
         B     PROCOPOB                                                 00212800
PROCOPOC DS    0H                                                       00212900
         CLC   NEWCARD+63(8),=CL15' '  ROOM FOR PTFID                   00213000
         BNE   PROCOPOD                NO                               00213100
         MVC   NEWCARD+64(L'PTFID),PTFID                                00213200
         PACK  DWORD,NEWCARD+72(8)                                      00213300
         AP    DWORD,=P'+1'                                             00213400
         OI    DWORD+7,X'0F'                                            00213500
         UNPK  NEWCARD+71(9),DWORD+3(5)                                 00213600
         MVI   NEWCARD+71,C' '         LAST OF CONTINUED                00213700
         AP    CHGCONT,=P'+1'                                           00213800
         BAL   R14,PUT                                                  00213900
         B     PROCOPR0                                                 00214000
PROCOPOD DS    0H                                                       00214100
         PACK  DWORD,NEWCARD+72(8)                                      00214200
         AP    DWORD,=P'+1'                                             00214300
         OI    DWORD+7,X'0F'                                            00214400
         UNPK  NEWCARD+71(9),DWORD+3(5)                                 00214500
         MVI   NEWCARD+71,C'~'         CONTINUED                        00214600
         AP    CHGCONT,=P'+1'                                           00214700
         BAL   R14,PUT                                                  00214800
         MVC   NEWCARD+64(L'PTFID),PTFID                                00214900
         PACK  DWORD,NEWCARD+72(8)                                      00215000
         AP    DWORD,=P'+1'                                             00215100
         OI    DWORD+7,X'0F'                                            00215200
         UNPK  NEWCARD+71(9),DWORD+3(5)                                 00215300
         MVI   NEWCARD+71,C' '                                          00215400
         AP    CHGCONT,=P'+1'                                           00215500
         BAL   R14,PUT                                                  00215600
         B     PROCOPR0                                                 00215700
*        SINGLE STATEMENT WITH ROOM FOR PTFID                           00215800
PROCOPP0 DS    0H                                                       00215900
         MVC   NEWCARD,NEWSTMT                                          00216000
         MVI   NEWCARD+63,C' '                                          00216100
         MVC   NEWCARD+64(L'PTFID),PTFID                                00216200
         MVI   NEWCARD+71,C' '                                          00216300
         MVC   NEWCARD+72(8),0(R4)                                      00216400
         AP    RECCHG,=P'+1'                                            00216500
         BAL   R14,PUT                                                  00216600
PROCOPR0 DS    0H                                                       00216700
         LA    R4,L'CONTSEQ(,R4)                                        00216800
         CR    R4,R8                                                    00216900
         BNL   PROCEND                                                  00217000
         MVI   NEWCARD,C' '                                             00217100
         MVC   NEWCARD+1(L'NEWCARD-1),NEWCARD                           00217200
         MVI   NEWCARD,C'*'                                             00217300
         MVC   NEWCARD+1(L'PTFID),PTFID                                 00217400
         MVC   NEWCARD+72(8),0(R4)                                      00217500
         AP    CHGCONT,=P'+1'                                           00217600
         BAL   R14,PUT                                                  00217700
         B     PROCOPR0                                                 00217800
         DROP  R4                                                       00217900
*********************************************************************** 00218000
* COMMENT STATEMENT                                                   * 00218100
*********************************************************************** 00218200
PROCCM   DS    0H                                                       00218300
         CLC   =C'*/*%INCLUDE SYSLIB',0(R2)                             00218400
         BNE   PROCEND                                                  00218500
* INCLUDE DSECTS SPECIFIED IN */*%INCLUDE SYSLIB  (IHAASVT )            00218600
         MVI   INCLUDES,C'Y'                                            00218700
         L     R15,=A(INSTBL)                                           00218800
         USING INSTB,R15                                                00218900
PROCCM10 DS    0H                                                       00219000
         C     R15,INSTBPT                                              00219100
         BNL   PROCCM30                                                 00219200
         CLI   INSTBUSD,C'D'             ALREADY GENERATED              00219300
         BE    PROCCM40                                                 00219400
         MVI   INSTBUSD,C'Y'             MARK MACRO GENERATION NEEDED   00219500
         B     PROCCM40                                                 00219600
PROCCM20 DS    0H                                                       00219700
         LA    R15,INSTBNX                                              00219800
         B     PROCCM10                                                 00219900
PROCCM30 DS    0H                                                       00220000
         MVC   LINE+1(13),=C'Missing DSECT'                             00220100
         MVC   LINE+15(8),21(R2)                                        00220200
         BAL   R14,PRT                                                  00220300
         AP    MISDSCNT,=P'+1'                                          00220400
PROCCM40 DS    0H                                                       00220500
         B     PROCEND                                                  00220600
         DROP  R15                                                      00220700
*********************************************************************** 00220800
*                                                                     * 00220900
*********************************************************************** 00221000
PROCEND  DS    0H                                                       00221100
         MVC   CONTSTMT,CURRCONT                                        00221200
         MVC   PREVSEQ,CURRSEQ                                          00221300
         B     PROC                                                     00221400
*********************************************************************** 00221500
*                                                                     * 00221600
*********************************************************************** 00221700
PROCIN   DS    0H                                                       00221800
         CLI   PREPHASE,C'Y'                                            00221900
         BE    PREEOD                                                   00222000
         MVI   STMTEOF,C'Y'                                             00222100
         CP    RECOUT,=P'+0'                                            00222200
         BE    PROCIN20                                                 00222300
         LA    R1,PREVSEQ                                               00222400
         LA    R0,L'PREVSEQ                                             00222500
PROCIN05 DS    0H                                                       00222600
         CLI   0(R1),C'0'                                               00222700
         BL    PROCEI01                                                 00222800
         LA    R1,1(,R1)                                                00222900
         BCT   R0,PROCIN05                                              00223000
         L     R4,=A(INSTBL)                                            00223100
         USING INSTB,R4                                                 00223200
PROCIN10 DS    0H                                                       00223300
         C     R4,INSTBPT                                               00223400
         BNL   PROCIN20                                                 00223500
         CLI   INSTBUSD,C'Y'                                            00223600
         BNE   PROCIN15                                                 00223700
         MVI   NEWSTMT,C' '                                             00223800
         MVC   NEWSTMT+1(79),NEWSTMT                                    00223900
         MVC   NEWSTMT(L'INSTBCRD),INSTBCRD                             00224000
         PACK  DWORD,PREVSEQ                                            00224100
         AP    DWORD,=P'+1'                                             00224200
         OI    DWORD+7,X'0F'                                            00224300
         UNPK  PREVSEQW,DWORD+3(5)                                      00224400
         MVC   NEWSTMT+72(L'PREVSEQ),PREVSEQ                            00224500
         MVI   NEWSTMT+63,C' '                                          00224600
         MVC   NEWSTMT+64(L'PTFID),PTFID                                00224700
         CLC   PREVSEQ,CURRSEQ                                          00224800
         BNL   PROCEI02                                                 00224900
         AP    RECINS,=P'+1'                                            00225000
         MVC   NEWCARD,NEWSTMT                                          00225100
         BAL   R14,PUT                                                  00225200
PROCIN15 DS    0H                                                       00225300
         LA    R4,INSTBNX                                               00225400
         B     PROCIN10                                                 00225500
         DROP  R4                                                       00225600
PROCIN20 DS    0H                                                       00225700
         CP    RECOUT,=P'+0'                                            00225800
         BE    PROCIN30                                                 00225900
         CLI   ELNM,C' '                                                00226000
         BE    PROCIN30                                                 00226100
         LA    R1,UT2JFCB                                               00226200
         USING JFCB,R1                                                  00226300
         CLC   ELNM,JFCBELNM                                            00226400
         DROP  R1                                                       00226500
         BNE   PROCIN30                                                 00226600
         CLC   PTFID,=C'DSKXXXX'                                        00226700
         BE    PROCIN30                                                 00226800
         CLOSE SYSUT2                                                   00226900
         OPEN  (RENDCB,(UPDAT))                                         00227000
         MVC   RENPARMO,ELNM                                            00227100
         MVC   RENPARMN(7),PTFID                                        00227200
         MVI   RENPARMN+7,C' '                                          00227300
         STOW  RENDCB,RENPARMS,C                                        00227400
         LR    R2,R15                                                   00227500
         LR    R3,R0                                                    00227600
         CLOSE RENDCB                                                   00227700
         LTR   R2,R2                                                    00227800
         BZ    PROCIN25                                                 00227900
         CH    R2,=H'8'                                                 00228000
         BNE   ERRSTOW                                                  00228100
PROCIN25 DS    0H                                                       00228200
         CLI   UPDPTFID,C'Y'                                            00228300
         BNE   PROCIN30                                                 00228400
         OPEN  (PTFIDDD,(OUTPUT))                                       00228500
         MVI   CARD,C' '                                                00228600
         MVC   CARD+1(L'CARD-1),CARD                                    00228700
         MVC   CARD(7),PTFID                                            00228800
         PUT   PTFIDDD,CARD                                             00228900
         CLOSE PTFIDDD                                                  00229000
PROCIN30 DS    0H                                                       00229100
         B     EXIT                                                     00229200
*********************************************************************** 00229300
*        MARK DSECT REFERENCED                                        * 00229400
*********************************************************************** 00229500
         USING MACTB,R4                                                 00229600
FLGDS    DS    0H                                                       00229700
         L     R1,=A(INSTBL)                                            00229800
         USING INSTB,R1                                                 00229900
FLGDS10  DS    0H                                                       00230000
         CLC   INSTBPFL,MACTBSYL                                        00230100
         BH    FLGDS20                                                  00230200
         CLC   INSTBPFX,MACTBSY                                         00230300
         BNE   FLGDS20                                                  00230400
         CLI   INSTBUSD,C'D'           MACRO ALREADY GENERATED          00230500
         BE    FLGDS50                                               07 00230510
         MVI   INSTBUSD,C'Y'                                            00230700
FLGDS20  DS    0H                                                       00230800
         LA    R1,INSTBNX                                               00230900
         C     R1,INSTBPT                                               00231000
         BL    FLGDS10                                                  00231100
         MVI   NODCT,C'Y'                                            07 00231110
         MVC   LINE+110(11),=C'Miss DSECT='                          07 00231120
         MVC   LINE+121(8),MACTBSY                                   07 00231130
         L     R1,=A(NODCTTB)                                        07 00231140
FLGDS30  DS    0H                                                       00231300
         C     R1,NODCTPT                                            07 00231310
         BNL   FLGDS40                                               07 00231320
         CLC   MACTBSY,0(R1)                                         07 00231330
         BE    FLGDS50                                               07 00231340
         LA    R1,8(,R1)                                             07 00231350
         B     FLGDS30                                               07 00231360
FLGDS40  DS    0H                                                    07 00231370
         C     R1,=A(NODCTND)                                        07 00231380
         BNL   FLGDS50                                               07 00231390
         MVC   0(8,R1),MACTBSY                                       07 00231391
         LA    R1,8(,R1)                                             07 00231392
         ST    R1,NODCTPT                                            07 00231393
FLGDS50  DS    0H                                                    07 00231394
         BR    R14                                                      00231400
         DROP  R1                                                       00231500
         DROP  R4                                                       00231600
*********************************************************************** 00231700
* CHECK LABEL PREFIX IGNORING LABELS TO BE SKIPPED (-label CTL STMTS) * 00231800
*********************************************************************** 00231900
CHKLBL   DS    0H                                                       00232000
         ST    R14,CHKLBL14                                             00232100
         L     R4,=A(MACTBL)                                            00232200
         USING MACTB,R4                                                 00232300
CHKLBL10 DS    0H                                                       00232400
         C     R4,MACTBPT                                               00232500
         BNL   CHKLBL20                                                 00232600
         LH    R1,MACTBNML                                              00232700
         EX    R1,CHKLBLNM             CLC   0(,R3),MACTBNM             00232800
         BE    CHKLBL30                MACRO PREFIX MATCHED             00232900
         LA    R4,MACTBNX                                               00233000
         B     CHKLBL10                                                 00233100
CHKLBL20 DS    0H                                                       00233200
         SR    R4,R4                                                    00233300
         CR    R1,R14                  NOT EQUAL                        00233400
         L     R14,CHKLBL14                                             00233500
         BR    R14                     LABEL NOT MACRO PREFIX           00233600
CHKLBLNM CLC   0(,R3),MACTBNM                                           00233700
CHKLBL30 DS    0H                                                       00233800
         LA    R1,1(R1,R3)                                              00233900
CHKLBL40 DS    0H                                                       00234000
* IF LABEL OR PREFIX ENDS IN = THEN IT IS A KEYWORD NOT A LABEL         00234100
* FOR EXAMPLE MAC KYWD=XYZ - KYWD IS KEYWORD OF MACRO AND IGNORED       00234200
         CLI   0(R1),C'='                                               00234300
         BE    CHKLBL20                PREFIX/LABEL FOLLOWED BY =       00234400
         CLI   0(R1),C' '              END OF LABEL                     00234500
         BE    CHKLBL50                                                 00234600
         CLI   0(R1),C','              END OF LABEL                     00234700
         BE    CHKLBL50                                                 00234800
         CLI   0(R1),C'('              END OF LABEL                     00234900
         BE    CHKLBL50                                                 00235000
         CLI   0(R1),C'-'              END OF LABEL                     00235100
         BE    CHKLBL50                                                 00235200
         CLI   0(R1),C'+'              END OF LABEL                     00235300
         BE    CHKLBL50                                                 00235400
         LA    R1,1(,R1)                                                00235500
         B     CHKLBL40                                                 00235600
*        CHECK SYMBOL TO SEE IF IT IS ONE OF THE @NMNNNNN NAMES         00235700
*        FOUND AS AN EQUATE IF SO MARK IT AS REFERENCED                 00235800
CHKLBL50 DS    0H                                                       00235900
         L     R15,=A(NMTBL)                                            00236000
         LR    R0,R1                   CURRENT DELIMITER ADDRESS        00236100
         SR    R0,R3                   LESS SYMBOL START                00236200
         CH    R0,=H'+8'               ALL @NMNNNNN ARE 8 BYTES         00236300
         BNE   CHKLBL54                IF CURRENT SYMBOL LEN NOT 8      00236400
         USING NMTB,R15                                                 00236500
CHKLBL51 DS    0H                                                       00236600
         CLC   NMTBNM,0(R3)            SYMBOL MATCH @NM ENTRY           00236700
         BE    CHKLBL53                @NM EQUATE NAME FOUND IN SOURCE  00236800
CHKLBL52 DS    0H                                                       00236900
         LA    R15,NMTBNX              NEXT ENTRY                       00237000
         C     R15,NMTBPT              AT END OF @NM ENTRIES            00237100
         BL    CHKLBL51                NO, CONTINUE SEARCH              00237200
         B     CHKLBL54                NOT FOUND                        00237300
CHKLBL53 DS    0H                                                       00237400
         MVI   NMTBUSD,C'Y'            MARK SYMBOL FOUND                00237500
         DROP  R15                                                      00237600
CHKLBL54 DS    0H                                                       00237700
         L     R15,=A(SKPTBL)                                           00237800
         USING SKPTB,R15                                                00237900
CHKLBL60 DS    0H                                                       00238000
         LH    R1,SKPTBNML                                              00238100
         EX    R1,CHKLBLSK             CLC   0(,R3),SKPTBNM             00238200
         BE    CHKLBL20                MACRO NAME TO BE SKIPPED         00238300
         LA    R15,SKPTBNX                                              00238400
         C     R15,SKPTBPT                                              00238500
         BL    CHKLBL60                                                 00238600
         L     R14,CHKLBL14                                             00238700
         CR    R14,R14                 EQUAL                            00238800
         BR    R14                     LABEL PREFIX IS MATCHED          00238900
CHKLBLSK CLC   0(,R3),SKPTBNM                                           00239000
         DROP  R15                                                      00239100
         DROP  R4                                                       00239200
*********************************************************************** 00239300
* CHECK REGISTER EQUATE SUBSTITUTION                                  * 00239400
*********************************************************************** 00239500
REGCHK   DS    0H                                                       00239600
         ST    R14,REGCHK14                                             00239700
* FIRST LETS SEE IF LABEL IS A REG EQUATE AND SUBSTITUTE REAL RN        00239800
         L     R14,=A(REGTBL)                                           00239900
         USING REGTB,R14                                                00240000
REGCHK10 DS    0H                                                       00240100
         LH    R1,REGNML                                                00240200
         EX    R1,REGCHKCK             CLC   0(,R3),REGNM               00240300
         BE    REGCHK20                REGISTER EQUATE NAME MATCHED     00240400
REGCHK15 DS    0H                                                       00240500
         LA    R14,REGTBNX                                              00240600
         C     R14,REGTBPT                                              00240700
         BL    REGCHK10                                                 00240800
         CR    R1,R14                  SET NO SUBSTITUTION OCCURED      00240900
         B     REGCHK90                EXIT                             00241000
REGCHKCK CLC   0(,R3),REGNM                                             00241100
REGCHK20 DS    0H                                                       00241200
         LA    R1,1(R1,R3)             supposed end of equated symbol   00241300
         CLI   0(R1),C' '              TERMINATED WITH BLANK            00241400
         BE    REGCHK30                                                 00241500
         CLI   0(R1),C')'              TERMINATED WITH RIGHT PAREN      00241600
         BE    REGCHK30                                                 00241700
         CLI   0(R1),C','              TERMINATED WITH COMMA            00241800
         BNE   REGCHK15                GO CHECK NEXT SYMBOL             00241900
REGCHK30 DS    0H                                                       00242000
         LR    R0,R3                   WHERE RXX SUBSTITUTION OCCURED   00242100
         LR    R3,R1                   END OF RXX SUBSTITUTION          00242200
* SUBSTITUTE RN FOR REGISTER EQUATE IN NEW STATEMENT                    00242300
* ASSUMES RX LENGTH IS LESS THAN EQUATE SYMBOL LENGTH                   00242400
         MVI   0(R7),C'R'              NEW REGISTER EQUATE              00242500
         MVC   1(2,R7),REGREG          AND IT'S NUMBER                  00242600
         DROP  R14                                                      00242700
         CLI   2(R7),C' '              ONE DIGIT REGISTER               00242800
         BE    REGCHK40                YES                              00242900
         LA    R7,3(,R7)               NEW OUTPUT LOCATION 2 DIGIT REG  00243000
         B     REGCHK50                                                 00243100
REGCHK40 DS    0H                                                       00243200
         LA    R7,2(,R7)               NEW OUTPUT LOCATION 1 DIGIT REG  00243300
REGCHK50 DS    0H                                                       00243400
         LR    R1,R3                   AFTER OLD REGISTER EQUATE        00243500
         LR    R15,R9                  END OF STATEMENT                 00243600
         BAL   R14,RESTSAV             SAVE OFF REST OF STATEMENT       00243700
         LR    R1,R7                   WHERE NEW SUBSTITUTION ENDED     00243800
         L     R15,=A(NEWSTMT+L'NEWSTMT-1) END OF NEW STATEMENT         00243900
         BAL   R14,RESTRES             COPY SAVED STATMENT OVER NEW ONE 00244000
         LR    R1,R0                   PASS BACK POINT OF SUBSTITUTION  00244100
         MVI   CHGSTMT,C'Y'            MARK STATEMENT CHANGED           00244200
         CR    R0,R0                   SET EQUAL                        00244300
REGCHK90 DS    0H                                                       00244400
         L     R14,REGCHK14                                             00244500
         BR    R14                                                      00244600
*********************************************************************** 00244700
* CHECK LABEL BEING SUBSTITUTED AND SUBSTITUTE IT                     * 00244800
*********************************************************************** 00244900
SUBLBL   DS    0H                                                       00245000
         ST    R14,SUBLBL14                                             00245100
*        SCAN FOR LABEL SUBSTITUTION AND SUBSTITUTE IF FOUND            00245200
SUBLBL00 DS    0H                                                       00245300
         L     R14,=A(CHGTBL)                                           00245400
         USING CHGTB,R14                                                00245500
SUBLBL10 DS    0H                                                       00245600
         LH    R1,CHGTBNML                                              00245700
         EX    R1,SUBLBLNM             CLC   0(,R3),CHGTBNM             00245800
         BE    SUBLBL30                LABEL NAME MATCHED               00245900
         LA    R14,CHGTBNX                                              00246000
         C     R14,CHGTBPT                                              00246100
         BL    SUBLBL10                                                 00246200
         CR    R1,R14                                                   00246300
         B     SUBLBL90                LABEL NOT DELIMITED - NOMATCH    00246400
SUBLBLNM CLC   0(,R3),CHGTBNM                                           00246500
SUBLBL30 DS    0H                                                       00246600
         LA    R1,1(R1,R3)                                              00246700
         CLI   0(R1),C' '                                               00246800
         BE    SUBLBL40                                                 00246900
         CLI   0(R1),C'-'                                               00247000
         BE    SUBLBL40                                                 00247100
         CLI   0(R1),C'+'                                               00247200
         BE    SUBLBL40                                                 00247300
         CLI   0(R1),C'('                                               00247400
         BE    SUBLBL40                                                 00247500
         CLI   0(R1),C','                                               00247600
         BE    SUBLBL40                                                 00247700
         MVC   LINE+34(20),0(R1)                                        00247800
         B     SUBLBL90                LABEL NOT DELIMITED=NOMATCH      00247900
SUBLBL40 DS    0H                                                       00248000
         CLI   OPER1TB,X'80'                                            00248100
         BNE   SUBLBL50                                                 00248200
         ST    R14,OPER1TB                                              00248300
SUBLBL50 DS    0H                                                       00248400
         LR    R0,R14                                                   00248500
         DROP  R14                                                      00248600
         LR    R15,R9                  END OF LINE                      00248700
         BAL   R14,RESTSAV             SAVE REST OF ORIGINAL LINE       00248800
* SUBSTITUTE NEW LABEL                                                  00248900
         LR    R14,R0                                                   00249000
         USING CHGTB,R14                                                00249100
         LH    R15,CHGTBNNL            MACHINE LENGTH OF LABEL          00249200
         EX    R15,SUBLBLMN            MVC   0(,R3),CHGTBNN             00249300
*        FLAG DSECT USED                                                00249400
         L     R1,=A(INSTBL)                                            00249500
         USING INSTB,R1                                                 00249600
SUBLBL51 DS    0H                                                       00249700
         CLC   INSTBPFL,CHGTBNNL                                        00249800
         BH    SUBLBL52                                                 00249900
         CLC   INSTBPFX,CHGTBNN                                         00250000
         BNE   SUBLBL52                                                 00250100
         CLI   INSTBUSD,C'D'           MACRO ALREADY GENERATED          00250200
         BE    SUBLBL53                                                 00250300
         MVI   INSTBUSD,C'Y'                                            00250400
         B     SUBLBL53                                                 00250500
SUBLBL52 DS    0H                                                       00250600
         LA    R1,INSTBNX                                               00250700
         C     R1,INSTBPT                                               00250800
         BL    SUBLBL51                                                 00250900
         MVI   NODCT,C'Y'                                            07 00250910
SUBLBL53 DS    0H                                                       00251100
         DROP  R1                                                       00251200
         DROP  R14                                                      00251300
         LA    R1,1(R3,R15)            PAST SUBSTITUTED LABEL           00251400
         LR    R15,R9                  END OF LINE                      00251500
         BAL   R14,RESTRES             MOVE REST OF ORIGINAL LINE BACK  00251600
         MVI   CHGSTMT,C'Y'                                             00251700
         CR    R0,R0                   SET EQUAL                        00251800
SUBLBL90 DS    0H                                                       00251900
         L     R14,SUBLBL14                                             00252000
         BR    R14                                                      00252100
         USING CHGTB,R14                                                00252200
SUBLBLMN MVC   0(,R3),CHGTBNN          SUBSTITUTE LABEL                 00252300
         DROP  R14                                                      00252400
*********************************************************************** 00252500
*                                                                     * 00252600
*********************************************************************** 00252700
SCANBL   DS    0H                                                       00252800
         CLI   0(R3),C' '                                               00252900
         BER   R14                                                      00253000
         LA    R3,1(,R3)                                                00253100
         CR    R3,R9                                                    00253200
         BL    SCANBL                                                   00253300
         BR    R14                                                      00253400
*********************************************************************** 00253500
*        SAVE FROM R1 TO R15                                          * 00253600
*********************************************************************** 00253700
RESTSAV  DS    0H                                                       00253800
         STM   R14,R1,RESTREGS                                          00253900
*        MVC   LINE+1(8),=C'RESTREGS'                                   00254000
*        BAL   R14,PRT                                                  00254100
*        LA    R1,RESTREGS                                              00254200
*        LA    R0,16                                                    00254300
*        BAL   R14,DMP                                                  00254400
*        MVC   LINE+1(5),=C'INPUT'                                      00254500
*        BAL   R14,PRT                                                  00254600
*        L     R1,RESTR1                                                00254700
*        L     R0,RESTR15                                               00254800
*        SR    R0,R1                                                    00254900
*        BAL   R14,DMP                                                  00255000
         L     R0,=A(RESTSAVR)                                          00255100
         L     R1,=A(L'RESTSAVR)                                        00255200
         L     R14,RESTR1                                               00255300
         L     R15,RESTR15                                              00255400
         SR    R15,R14                                                  00255500
         BM    PROCES01                                                 00255600
         ICM   R15,8,=C' '                                              00255700
         MVCL  R0,R14                  SAVE REST OF LINE                00255800
*        MVC   LINE+1(8),=C'RESTSAVR'                                   00255900
*        BAL   R14,PRT                                                  00256000
*        L     R0,=A(L'RESTSAVR)                                        00256100
*        L     R1,=A(RESTSAVR)                                          00256200
*        BAL   R14,DMP                                                  00256300
         LM    R14,R1,RESTREGS                                          00256400
         BR    R14                     EXIT                             00256500
*********************************************************************** 00256600
*        RESTORE TO R1 TO R15                                         * 00256700
*********************************************************************** 00256800
RESTRES  DS    0H                                                       00256900
         STM   R14,R1,RESTREGS                                          00257000
         LR    R0,R1                   RESTORE REST OF LINE             00257100
         LR    R1,R15                                                   00257200
         SR    R1,R0                                                    00257300
         BM    PROCES02                                                 00257400
         L     R14,=A(RESTSAVR)                                         00257500
         LR    R15,R1                                                   00257600
         MVCL  R0,R14                                                   00257700
*        MVC   LINE+1(8),=C'RESTREGS'                                   00257800
*        BAL   R14,PRT                                                  00257900
*        LA    R1,RESTREGS                                              00258000
*        LA    R0,16                                                    00258100
*        MVC   LINE+1(6),=C'OUTPUT'                                     00258200
*        BAL   R14,PRT                                                  00258300
*        L     R1,RESTR1                                                00258400
*        L     R0,RESTR15                                               00258500
*        SR    R0,R1                                                    00258600
*        BAL   R14,DMP                                                  00258700
         LM    R14,R1,RESTREGS                                          00258800
         BR    R14                     EXIT                             00258900
*********************************************************************** 00259000
*                                                                     * 00259100
*********************************************************************** 00259200
SCANNBL  DS    0H                                                       00259300
         CLI   0(R3),C' '                                               00259400
         BNE   SCANNBLE                                                 00259500
         LA    R3,1(,R3)                                                00259600
         CR    R3,R9                                                    00259700
         BL    SCANNBL                                                  00259800
         CR    R3,R14                  NOT EQUAL = ALL BLANK            00259900
         BR    R14                                                      00260000
SCANNBLE DS    0H                                                       00260100
         CR    R3,R3                   EQUAL = NON-BLANK FOUND          00260200
         BR    R14                                                      00260300
*********************************************************************** 00260400
* ERRORS                                                              * 00260500
*********************************************************************** 00260600
ERRRDJ1  DS    0H                                                       00260700
         MVC   LINE+1(6),=C'SYSUT1'                                     00260800
         B     ERRRDJF                                                  00260900
ERRRDJ2  DS    0H                                                       00261000
         MVC   LINE+1(6),=C'SYSUT1'                                     00261100
ERRRDJF  DS    0H                                                       00261200
         MVC   LINE+8(12),=C'RDJFCB RC=X'''                             00261300
         ST    R15,DWORD                                                00261400
         UNPK  LINE+20(9),DWORD(5)                                      00261500
         TR    LINE+20(8),HEXTBL-240                                    00261600
         MVI   LINE+28,C''''                                            00261700
         BAL   R14,PRT                 PRINT A LINE                     00261800
         LA    R15,8                   ERROR RC                         00261900
         B     EXITRC                  ERROR                            00262000
ERRSTOW  DS    0H                                                       00262100
         MVC   LINE+1(12),=C'Rename RC=X'''                             00262200
         ST    R2,DWORD                                                 00262300
         UNPK  LINE+13(9),DWORD(5)                                      00262400
         TR    LINE+13(8),HEXTBL-240                                    00262500
         MVC   LINE+21(5),=C''' - '''                                   00262600
         ST    R3,DWORD                                                 00262700
         UNPK  LINE+26(9),DWORD(5)                                      00262800
         TR    LINE+26(8),HEXTBL-240                                    00262900
         MVI   LINE+34,C''''                                            00263000
         BAL   R14,PRT                 PRINT A LINE                     00263100
         MVC   LINE+1(12),=C'Rename parms'                              00263200
         BAL   R14,PRT                 PRINT A LINE                     00263300
         UNPK  LINE+01(9),RENPARMS+00(5)                                00263400
         UNPK  LINE+09(9),RENPARMS+04(5)                                00263500
         UNPK  LINE+17(9),RENPARMS+08(5)                                00263600
         UNPK  LINE+25(9),RENPARMS+12(5)                                00263700
         TR    LINE+1(32),HEXTBL-240                                    00263800
         MVI   LINE+33,C' '                                             00263900
         BAL   R14,PRT                                                  00264000
         LA    R15,8                   ERROR RC                         00264100
         B     EXITRC                  ERROR                            00264200
ERRMBR   DS    0H                                                       00264300
         MVC   LINE+1(24),=C'SYSUT1 DD not PDS member'                  00264400
         BAL   R14,PRT                 PRINT A LINE                     00264500
         LA    R15,8                   ERROR RC                         00264600
         B     EXITRC                  ERROR                            00264700
ERRPTFDD DS    0H                                                       00264800
         MVC   LINE+1(16),=C'PTFID DD missing'                          00264900
         BAL   R14,PRT                 PRINT A LINE                     00265000
         LA    R15,8                   ERROR RC                         00265100
         B     EXITRC                  ERROR                            00265200
ERRFMDD  DS    0H                                                       00265300
         MVC   LINE+1(15),=C'FMID DD missing'                           00265400
         BAL   R14,PRT                 PRINT A LINE                     00265500
         LA    R15,8                   ERROR RC                         00265600
         B     EXITRC                  ERROR                            00265700
ERRFMNM  DS    0H                                                       00265800
         MVC   LINE+1(21),=C'No FMID found for module'                  00265900
         MVC   LINE+24(8),ELNM                                          00266000
         BAL   R14,PRT                 PRINT A LINE                     00266100
         LA    R15,8                   ERROR RC                         00266200
         B     EXITRC                  ERROR                            00266300
ERRPTFEF DS    0H                                                       00266400
         MVC   LINE+15(7),=C'missing'                                   00266500
         B     ERRPTFER                                                 00266600
ERRPTFID DS    0H                                                       00266700
         MVC   LINE+15(7),CARD                                          00266800
ERRPTFER DS    0H                                                       00266900
         MVC   LINE+1(14),=C'PTFID invalid='                            00267000
         BAL   R14,PRT                 PRINT A LINE                     00267100
         LA    R15,8                   ERROR RC                         00267200
         B     EXITRC                  ERROR                            00267300
PROCEC01 DS    0H                                                       00267400
         MVC   ERRCOD,=C'C01'                                           00267500
         B     PROCERC                                                  00267600
PROCEC02 DS    0H                                                       00267700
         MVC   ERRCOD,=C'C02'                                           00267800
         B     PROCERC                                                  00267900
PROCEC03 DS    0H                                                       00268000
         MVC   ERRCOD,=C'C03'                                           00268100
         B     PROCERC                                                  00268200
PROCEC04 DS    0H                                                       00268300
         MVC   ERRCOD,=C'C04'                                           00268400
         B     PROCERC                                                  00268500
PROCEC05 DS    0H                                                       00268600
         MVC   ERRCOD,=C'C05'                                           00268700
         B     PROCERC                                                  00268800
PROCEC06 DS    0H                                                       00268900
         MVC   ERRCOD,=C'C06'                                           00269000
         B     PROCERC                                                  00269100
PROCEL01 DS    0H                                                       00269200
         MVC   ERRCOD,=C'L01'                                           00269300
         B     PROCER                                                   00269400
PROCEL02 DS    0H                                                       00269500
         MVC   ERRCOD,=C'L02'                                           00269600
         B     PROCER                                                   00269700
PROCEL03 DS    0H                                                       00269800
         MVC   ERRCOD,=C'L03'                                           00269900
         B     PROCER                                                   00270000
PROCEL04 DS    0H                                                       00270100
         MVC   ERRCOD,=C'L04'                                           00270200
         B     PROCER                                                   00270300
PROCEL05 DS    0H                                                       00270400
         MVC   ERRCOD,=C'L05'                                           00270500
         B     PROCER                                                   00270600
PROCEL06 DS    0H                                                       00270700
         MVC   ERRCOD,=C'L06'                                           00270800
         B     PROCER                                                   00270900
PROCEL07 DS    0H                                                       00271000
         MVC   ERRCOD,=C'L07'                                           00271100
         B     PROCER                                                   00271200
PROCEL08 DS    0H                                                       00271300
         MVC   ERRCOD,=C'L08'                                           00271400
         B     PROCER                                                   00271500
PROCEL09 DS    0H                                                       00271600
         MVC   ERRCOD,=C'L09'                                           00271700
         B     PROCER                                                   00271800
PROCEL10 DS    0H                                                       00271900
         MVC   ERRCOD,=C'L10'                                           00272000
         B     PROCER                                                   00272100
PROCEL11 DS    0H                                                       00272200
         MVC   ERRCOD,=C'L11'                                           00272300
         B     PROCER                                                   00272400
PROCEL12 DS    0H                                                       00272500
         MVC   ERRCOD,=C'L12'                                           00272600
         B     PROCER                                                   00272700
PROCEL13 DS    0H                                                       00272800
         MVC   ERRCOD,=C'L13'                                           00272900
         B     PROCER                                                   00273000
PROCEL14 DS    0H                                                       00273100
         MVC   ERRCOD,=C'L14'                                           00273200
         B     PROCER                                                   00273300
PROCEL15 DS    0H                                                       00273400
         MVC   ERRCOD,=C'L15'                                           00273500
         B     PROCER                                                   00273600
PROCEO01 DS    0H                                                       00273700
         MVC   ERRCOD,=C'O01'                                           00273800
         B     PROCER                                                   00273900
PROCEO02 DS    0H                                                       00274000
         MVC   ERRCOD,=C'O02'                                           00274100
         B     PROCER                                                   00274200
PROCEO03 DS    0H                                                       00274300
         MVC   ERRCOD,=C'O03'                                           00274400
         B     PROCER                                                   00274500
PROCEO04 DS    0H                                                       00274600
         MVC   ERRCOD,=C'O04'                                           00274700
         B     PROCER                                                   00274800
PROCEO05 DS    0H                                                       00274900
         MVC   ERRCOD,=C'O05'                                           00275000
         B     PROCER                                                   00275100
PROCEO06 DS    0H                                                       00275200
         MVC   ERRCOD,=C'O06'                                           00275300
         B     PROCER                                                   00275400
PROCEO07 DS    0H                                                       00275500
         MVC   ERRCOD,=C'O07'                                           00275600
         B     PROCER                                                   00275700
PROCEO08 DS    0H                                                       00275800
         MVC   ERRCOD,=C'O08'                                           00275900
         B     PROCER                                                   00276000
PROCEO09 DS    0H                                                       00276100
         MVC   ERRCOD,=C'O09'                                           00276200
         B     PROCER                                                   00276300
PROCEO10 DS    0H                                                       00276400
         MVC   ERRCOD,=C'O10'                                           00276500
         B     PROCER                                                   00276600
PROCEO11 DS    0H                                                       00276700
         MVC   ERRCOD,=C'O11'                                           00276800
         B     PROCER                                                   00276900
PROCEO12 DS    0H                                                       00277000
         MVC   ERRCOD,=C'O12'                                           00277100
         B     PROCER                                                   00277200
PROCEO13 DS    0H                                                       00277300
         MVC   ERRCOD,=C'O13'                                           00277400
         B     PROCER                                                   00277500
PROCEO14 DS    0H                                                       00277600
         MVC   ERRCOD,=C'O14'                                           00277700
         B     PROCER                                                   00277800
PROCEO15 DS    0H                                                       00277900
         MVC   ERRCOD,=C'O15'                                           00278000
         B     PROCER                                                   00278100
PROCEO16 DS    0H                                                       00278200
         MVC   ERRCOD,=C'O16'                                           00278300
         B     PROCER                                                   00278400
PROCEO17 DS    0H                                                       00278500
         MVC   ERRCOD,=C'O17'                                           00278600
         B     PROCER                                                   00278700
PROCEO18 DS    0H                                                       00278800
         MVC   ERRCOD,=C'O18'                                           00278900
         B     PROCER                                                   00279000
PROCEO19 DS    0H                                                       00279100
         MVC   ERRCOD,=C'O19'                                           00279200
         B     PROCER                                                   00279300
PROCEI01 DS    0H                                                       00279400
         MVC   ERRCOD,=C'I01'                                           00279500
         B     PROCERI                                                  00279600
PROCEI02 DS    0H                                                       00279700
         MVC   ERRCOD,=C'I02'                                           00279800
         B     PROCERI                                                  00279900
PROCES01 DS    0H                                                       00280000
         MVC   ERRCOD,=C'S01'                                           00280100
         B     PROCER                                                   00280200
PROCES02 DS    0H                                                       00280300
         MVC   ERRCOD,=C'S02'                                           00280400
         B     PROCER                                                   00280500
PROCER01 DS    0H                                                       00280600
         MVC   ERRCOD,=C'R01'                                           00280700
         B     PROCER                                                   00280800
PROCER02 DS    0H                                                       00280900
         MVC   ERRCOD,=C'R02'                                           00281000
         B     PROCER                                                   00281100
PROCERI  DS    0H                                                       00281200
         MVC   LINE+1(80),NEWSTMT                                       00281300
         LA    R3,72                                                    00281400
         B     PROCER1                                                  00281500
PROCERC  DS    0H                                                       00281600
         MVC   LINE+1(L'CARD),LONGSTMT                                  00281700
         LA    R3,72                                                    00281800
         B     PROCER1                                                  00281900
PROCER   DS    0H                                                       00282000
         MVC   LINE+1(L'CARD),0(R2)                                     00282100
         LR    R4,R3                                                    00282200
         SR    R3,R2                                                    00282300
PROCER1  DS    0H                                                       00282400
         MVC   LINE+90(8),=C'Error in'                                  00282500
         CLI   CONTSTMT,C' '                                            00282600
         BE    PROCER2                                                  00282700
         MVC   LINE+99(11),=C'(continued)'                              00282800
PROCER2  DS    0H                                                       00282900
         BAL   R14,PRT                                                  00283000
         MVI   LINE+1,C'>'                                              00283100
         MVC   LINE+2(20),0(R4)                                         00283200
         MVI   LINE+22,C'<'                                             00283300
         LA    R3,LINE+1(R3)                                            00283400
         C     R3,=A(LINE+80)                                           00283500
         BNH   PROCER2A                                                 00283600
         LA    R3,LINE+90                                               00283700
PROCER2A DS    0H                                                       00283800
         MVC   0(8,R3),=C'* Error='                                     00283900
         MVC   8(3,R3),ERRCOD                                           00284000
         BAL   R14,PRT                                                  00284100
         LR    R3,R2                                                    00284200
         A     R3,=A(L'LONGSTMT)                                        00284300
PROCER3  DS    0H                                                       00284400
         LA    R2,L'CARD(,R2)                                           00284500
         CR    R2,R3                                                    00284600
         BNL   PROCER5                                                  00284700
         CLI   0(R2),C' '                                               00284800
         BNE   PROCER4                                                  00284900
         CLC   1(79,R2),0(R2)                                           00285000
         BE    PROCER5                                                  00285100
PROCER4  DS    0H                                                       00285200
         MVC   LINE+1(L'CARD),0(R2)                                     00285300
         BAL   R14,PRT                                                  00285400
         B     PROCER3                                                  00285500
PROCER5  DS    0H                                                       00285600
         MVC   LINE+1(L'CARD),NEWSTMT                                   00285700
         MVC   LINE+90(9),=C'Error out'                                 00285800
         BAL   R14,PRT                                                  00285900
         LA    R2,NEWSTMT                                               00286000
         LR    R3,R2                                                    00286100
         A     R3,=A(L'NEWSTMT)                                         00286200
PROCER6  DS    0H                                                       00286300
         LA    R2,L'CARD(,R2)                                           00286400
         CR    R2,R3                                                    00286500
         BNL   PROCER8                                                  00286600
         CLI   0(R2),C' '                                               00286700
         BNE   PROCER7                                                  00286800
         CLC   1(79,R2),0(R2)                                           00286900
         BE    PROCER8                                                  00287000
PROCER7  DS    0H                                                       00287100
         MVC   LINE+1(L'CARD),0(R2)                                     00287200
         MVC   LINE+90(9),=C'Error out'                                 00287300
         BAL   R14,PRT                                                  00287400
         B     PROCER6                                                  00287500
PROCER8  DS    0H                                                       00287600
         AP    ERRCNT,=P'+1'                                            00287700
         CLI   STMTEOF,C'Y'                                             00287800
         BE    EXIT                                                     00287900
         B     PROCEND                                                  00288000
*********************************************************************** 00288100
*                                                                     * 00288200
*                                                                     * 00288300
*                                                                     * 00288400
*********************************************************************** 00288500
EXIT     DS    0H                                                       00288600
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          00288700
         MVC   LINE+1(L'LINE-1),LINE                                    00288800
         BAL   R14,PRT                 PRINT A LINE                  07 00288810
         CLI   NODCT,C'Y'                                            07 00288820
         BNE   EXITND30                                              07 00288830
         MVC   LINE+1(14),=C'Missing DSECTs'                         07 00288840
         BAL   R14,PRT                 PRINT A LINE                  07 00288850
         L     R2,=A(NODCTTB)                                        07 00288860
EXITND10 DS    0H                                                    07 00288870
         C     R2,NODCTPT                                            07 00288880
         BNL   EXITND20                                              07 00288890
         MVC   LINE+2(8),0(R2)                                       07 00288891
         BAL   R14,PRT                 PRINT A LINE                  07 00288892
         LA    R2,8(,R2)                                             07 00288893
         B     EXITND10                                              07 00288894
EXITND20 DS    0H                                                    07 00288895
         BAL   R14,PRT                 PRINT A LINE                  07 00288896
EXITND30 DS    0H                                                    07 00288897
         MVC   LINE+1(10),=C'Records in'                                00288900
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00289000
         ED    LINE+20(10),RECIN                                        00289100
         BAL   R14,PRT                 PRINT A LINE                     00289200
         MVC   LINE+1(15),=C'Records changed'                           00289300
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00289400
         ED    LINE+20(10),RECCHG                                       00289500
         BAL   R14,PRT                 PRINT A LINE                     00289600
         CP    CHGCONT,=P'+0'                                           00289700
         BE    EXITNCC                                                  00289800
         MVC   LINE+1(17),=C'Cont stmt changed'                         00289900
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00290000
         ED    LINE+20(10),CHGCONT                                      00290100
         BAL   R14,PRT                 PRINT A LINE                     00290200
EXITNCC  DS    0H                                                       00290300
         MVC   LINE+1(16),=C'Records inserted'                          00290400
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00290500
         ED    LINE+20(10),RECINS                                       00290600
         BAL   R14,PRT                 PRINT A LINE                     00290700
         MVC   LINE+1(17),=C'Continued records'                         00290800
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00290900
         ED    LINE+20(10),CONTCNT                                      00291000
         BAL   R14,PRT                 PRINT A LINE                     00291100
         MVC   LINE+1(11),=C'Records out'                               00291200
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00291300
         ED    LINE+20(10),RECOUT                                       00291400
         BAL   R14,PRT                 PRINT A LINE                     00291500
         MVC   LINE+1(14),=C'Missing DSECTs'                            00291600
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00291700
         ED    LINE+20(10),MISDSCNT                                     00291800
         BAL   R14,PRT                 PRINT A LINE                     00291900
         MVC   LINE+1(6),=C'Errors'                                     00292000
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00292100
         ED    LINE+20(10),ERRCNT                                       00292200
         BAL   R14,PRT                 PRINT A LINE                     00292300
         CLI   INCLUDES,C'Y'           FOUND ANY INCLUDES               00292400
         BE    EXITFIN                                                  00292500
         MVC   LINE+1(28),=C'No ''*/*%INCLUDE SYSLIB'' seen'            00292600
         BAL   R14,PRT                 PRINT A LINE                     00292700
EXITFIN  DS    0H                                                       00292800
         LA    R15,8                                                    00292900
         CP    ERRCNT,=P'+0'                                            00293000
         BNE   EXITRC                                                   00293100
         LA    R15,4                                                    00293200
         CP    RECOUT,=P'+0'                                            00293300
         BE    EXITRC                                                   00293400
         CLI   NODCT,C'Y'                                            07 00293410
         BE    EXITRC                                                   00293600
         CP    MISDSCNT,=P'+0'                                          00293700
         BNE   EXITRC                                                   00293800
         LA    R15,0                                                    00293900
EXITRC   DS    0H                                                       00294000
         LR    R2,R15                                                   00294100
         MVC   LINE+1(11),=C'Return code'                               00294200
         MVC   LINE+26(4),=X'40202120'                                  00294300
         CVD   R2,DWORD                                                 00294400
         ED    LINE+26(4),DWORD+6                                       00294500
         BAL   R14,PRT                 PRINT A LINE                     00294600
         CLOSE (SYSPRINT,,SYSUT1,,SYSUT2,,SYSIN)                        00294700
         L     R13,4(,R13)                                              00294800
         L     R14,12(,R13)            RESTORE R14                      00294900
         LR    R15,R2                  RESTORE RETURN CODE              00295000
         LM    R2,R12,28(R13)          RESTORE REST OF REGISTERS        00295100
         BR    R14                     EXIT                             00295200
QUIT     DS    0H                                                       00295300
         L     R13,4(,R13)                                              00295400
         LM    R14,R12,12(R13)                                          00295500
         LA    R15,16                                                   00295600
         BR    R14                                                      00295700
*********************************************************************** 00295800
*                                                                     * 00295900
*                                                                     * 00296000
*                                                                     * 00296100
*********************************************************************** 00296200
PUT      DS    0H                                                       00296300
         ST    R14,PUTR14                                               00296400
         CP    RECOUT,=P'+0'                                            00296500
         BNE   PUT050                                                   00296600
         OPEN  (SYSUT2,(OUTPUT))                                        00296700
         TM    SYSUT2+48,16                                             00296800
         BZ    QUIT                                                     00296900
         RDJFCB SYSUT2                                                  00297000
         LTR   R15,R15                                                  00297100
         BNZ   ERRRDJ2                                                  00297200
         CLC   PTFID,=C'DSKXXXX'                                        00297300
         BE    PUT030                                                   00297400
         MVC   LINE+1(16),=C'++PTF(xxxxxxx) .'                          00297500
         MVC   LINE+7(7),PTFID                                          00297600
         PUT   SYSUT2,LINE+1                                            00297700
         AP    RECOUT,=P'+1'                                            00297800
         TM    FLAG,FLAGDBGL                                            00297900
         BNO   PUT010                                                   00298000
         MVC   LINE+90(17),=C'Control statement'                        00298100
         BAL   R14,PRT                 PRINT A LINE                     00298200
PUT010   DS    0H                                                       00298300
         MVI   LINE,C' '                                                00298400
         MVC   LINE+1(L'LINE-1),LINE                                    00298500
         MVC   LINE+1(27),=C'++VER(Z038) FMID(xxxxxxx) .'               00298600
         MVC   LINE+18(7),FMID                                          00298700
         PUT   SYSUT2,LINE+1                                            00298800
         AP    RECOUT,=P'+1'                                            00298900
         TM    FLAG,FLAGDBGL                                            00299000
         BNO   PUT020                                                   00299100
         MVC   LINE+90(17),=C'Control statement'                        00299200
         BAL   R14,PRT                 PRINT A LINE                     00299300
PUT020   DS    0H                                                       00299400
         MVI   LINE,C' '                                                00299500
         MVC   LINE+1(L'LINE-1),LINE                                    00299600
         MVC   LINE+1(20),=C'++SRCUPD(xxxxxxxx) .'                      00299700
         MVC   LINE+10(8),ELNM                                          00299800
         PUT   SYSUT2,LINE+1                                            00299900
         AP    RECOUT,=P'+1'                                            00300000
         TM    FLAG,FLAGDBGL                                            00300100
         BNO   PUT030                                                   00300200
         MVC   LINE+90(17),=C'Control statement'                        00300300
         BAL   R14,PRT                 PRINT A LINE                     00300400
PUT030   DS    0H                                                       00300500
         MVI   LINE,C' '                                                00300600
         MVC   LINE+1(L'LINE-1),LINE                                    00300700
         MVC   LINE+1(15),=C'./ CHANGE NAME='                           00300800
         MVC   LINE+16(8),ELNM                                          00300900
         PUT   SYSUT2,LINE+1                                            00301000
         AP    RECOUT,=P'+1'                                            00301100
         TM    FLAG,FLAGDBGL                                            00301200
         BNO   PUT040                                                   00301300
         MVC   LINE+90(17),=C'Control statement'                        00301400
         BAL   R14,PRT                 PRINT A LINE                     00301500
PUT040   DS    0H                                                       00301600
         MVI   LINE,C' '                                                00301700
         MVC   LINE+1(L'LINE-1),LINE                                    00301800
PUT050   DS    0H                                                       00301900
         TM    FLAG,FLAGDBGL                                            00302000
         BNO   PUT070                                                   00302100
         MVC   LINE+1(L'NEWCARD),NEWCARD                                00302200
         MVC   LINE+90(17),=C'Updated statement'                        00302300
         BAL   R14,PRT                 PRINT A LINE                     00302400
PUT070   DS    0H                                                       00302500
         PUT   SYSUT2,NEWCARD                                           00302600
         AP    RECOUT,=P'+1'                                            00302700
         L     R14,PUTR14                                               00302800
         BR    R14                     RETURN TO CALLER                 00302900
**********************************************************************  00303000
*                                                                    *  00303100
*            WRITE PRINT LINE                                        *  00303200
*                                                                    *  00303300
**********************************************************************  00303400
PRT      DS    0H                                                       00303500
         ST    R14,PRTR14                                               00303600
         CP    LNCT,=P'+60'            END OF PAGE                      00303700
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   00303800
PRTHDRS  DS    0H                                                       00303900
         AP    PGCT,=P'+1'             COUNT PAGES                      00304000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  00304100
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  00304200
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  00304300
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  00304400
         MVI   LINE,C'0'               SKIP AFTER HEADING               00304500
PRTCHK   DS    0H                                                       00304600
         CLI   LINE,C'+'               OVERPRINT ?                      00304700
         BE    PRTLINE                  YES, DON'T COUNT                00304800
         CLI   LINE,C'1'               NEW LINE ?                       00304900
         BE    PRTHDRS                  YES, PRINT HEADER               00305000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         00305100
         BE    PRTLINE1                 YES, GO CHECK IF FIT            00305200
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         00305300
         BE    PRTLINE2                 YES, GO CHECK IF FIT            00305400
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         00305500
         BE    PRTLINE3                 YES, GO CHECK IF FIT            00305600
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       00305700
PRTLINE1 DS    0H                                                       00305800
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                00305900
         B     PRTVFY                  GO SEE IF IT WILL FIT            00306000
PRTLINE2 DS    0H                                                       00306100
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                00306200
         B     PRTVFY                  GO SEE IF IT WILL FIT            00306300
PRTLINE3 DS    0H                                                       00306400
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                00306500
PRTVFY   DS    0H                                                       00306600
         CP    LNCT,=P'+60'            OVERFLOW ?                       00306700
         BH    PRTHDRS                  YES, FORCE HEADER               00306800
PRTLINE  DS    0H                                                       00306900
         PUT   SYSPRINT,LINE           PRINT A LINE                     00307000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          00307100
         MVC   LINE+1(L'LINE-1),LINE                                    00307200
         L     R14,PRTR14                                               00307300
         BR    R14                     RETURN TO CALLER                 00307400
*********************************************************************** 00307500
*                                                                     * 00307600
*        DUMP DATA                                                    * 00307700
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 00307800
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 00307900
*                                                                     * 00308000
*********************************************************************** 00308100
DMP      DS    0H                                                       00308200
         STM   R0,R15,DMPREGS          SAVE REGISTERS                   00308300
         LR    R3,R1                   GET ADDRESS TO DUMP              00308400
         LR    R4,R0                   GET LENGTH                       00308500
         XC    DMPOFF,DMPOFF           SAVE OFFSET FOR DUMP             00308600
         MVI   DMPFLAG,DMPFIRST        FIRST LINE                       00308700
DMPDMPLP DS    0H                                                       00308800
         LTR   R4,R4                   ANY DATA TO DUMP ?               00308900
         BZ    DMPHEXXT                 YES, ALL DONE                   00309000
         TM    DMPFLAG,DMPFIRST        FIRST LINE?                      00309100
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   00309200
         LA    R0,32                   DEFAULT LENGTH                   00309300
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          00309400
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           00309500
         LR    R14,R3                  GET CURRENT INPUT AREA           00309600
         SR    R14,R0                  BACK TO PREVIOUS AREA            00309700
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       00309800
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            00309900
         SR    R4,R0                   REDUCE LENGTH TO DO              00310000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           00310100
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       00310200
         L     R14,DMPOFF              GET CURRENT OFFSET               00310300
         ST    R14,DUPFIRST            SAVE AS FIRST OFFSET             00310400
         OI    DMPFLAG,DMPDUP          SET DUPLICATE                    00310500
         B     DMPNXTLN                CONTINUE                         00310600
DMPDUPCK DS    0H                                                       00310700
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           00310800
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      00310900
         MVC   LINE+7(5),=C'Lines'     MOVE LITERAL                     00311000
         LA    R2,LINE+13              OUTPUT AREA ADDRESS              00311100
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        00311200
         LA    R15,2                   CONVERT 4 BYTES                  00311300
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            00311400
         MVI   LINE+17,C'-'            THRU LITERAL                     00311500
         L     R1,DMPOFF               GET CURRENT OFFSET               00311600
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        00311700
         ST    R1,DUPFIRST             SAVE FOR DUMPING                 00311800
         LA    R2,LINE+18              OUTPUT AREA ADDRESS              00311900
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        00312000
         LA    R15,2                   CONVERT 4 BYTES                  00312100
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            00312200
         MVC   LINE+23(13),=C'Same as above' MOVE LITERAL               00312300
         BAL   R14,PRT                 PRINT A LINE                     00312400
         NI    DMPFLAG,255-DMPDUP      RESET DUPLICATE IN PROGRESS      00312500
DMPALIN  DS    0H                                                       00312600
         ST    R3,DMPADR               SAVE ADDRESS                     00312700
         LA    R2,LINE+1               OUTPUT AREA ADDRESS              00312800
         LA    R1,DMPADR               ADDRESS OF ADDRESS               00312900
         LA    R15,4                   CONVERT 8 BYTES                  00313000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            00313100
         LA    R2,1(,R2)               SKIP 1 BETWEEN ADDRESS & OFFSET  00313200
         LA    R1,DMPOFF+2             ADDRESS OF OFFSET TO DUMP        00313300
         LA    R15,2                   CONVERT 4 BYTES                  00313400
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            00313500
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     00313600
         LR    R1,R3                   ADDRESS OF DATA                  00313700
         LA    R5,32                   DEFAULT LENGTH                   00313800
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          00313900
         BH    DMPDODMP                 YES, USE 32                     00314000
         LR    R5,R4                   USE WHAT IS LEFT                 00314100
DMPDODMP DS    0H                                                       00314200
         SR    R4,R5                   REDUCE AMOUNT TO DO              00314300
         MVI   LINE+89,C'*'            BOX IN DISPLAY PORTION           00314400
         BCTR  R5,0                    MAKE ZERO BASED                  00314500
         EX    R5,DMPMVC               DO MOVE                          00314600
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          00314700
         LA    R5,1(,R5)               RESTORE LENGTH                   00314800
         MVI   LINE+122,C'*'           COMPLETE BOX                     00314900
DMPDMPHX DS    0H                                                       00315000
         LA    R15,4                   4 BYTES TO PROCESS               00315100
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           00315200
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               00315300
         LR    R15,R5                  USE LENGTH LEFT                  00315400
DMPDMPIT DS    0H                                                       00315500
         SR    R5,R15                  REDUCE AMOUNT TO DO              00315600
         BAL   R14,DMPDSP              CONVERT DATA                     00315700
         LA    R2,1(,R2)               SKIP 1 BYTE                      00315800
         LA    R0,LINE+43              HALFWAY POINT ADDRESS            00315900
         CR    R0,R2                   AT HALFWAY POINT?                00316000
         BNE   DMPDMPNX                 NO, CONTINUE                    00316100
         LA    R2,1(,R2)               SKIP 1 BYTE                      00316200
DMPDMPNX DS    0H                                                       00316300
         LTR   R5,R5                   ANY LEFT TO DO ?                 00316400
         BH    DMPDMPHX                 YES, GO DO IT                   00316500
         BAL   R14,PRT                 PRINT A LINE                     00316600
DMPNXTLN DS    0H                                                       00316700
         L     R1,DMPOFF               GET OFFSET IN RECORD             00316800
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       00316900
         ST    R1,DMPOFF               SAVE OFFSET IN RECORD            00317000
         LA    R3,32(,R3)              NEXT INPUT AREA                  00317100
         NI    DMPFLAG,255-DMPFIRST    NOT FIRST LINE                   00317200
         B     DMPDMPLP                LOOP THRU UNTIL DONE             00317300
DMPHEXXT DS    0H                                                       00317400
         LM    R0,R15,DMPREGS          RESTORE CALLERS REGS             00317500
         BR    R14                     EXIT . . .                       00317600
DMPMVC   MVC   LINE+90(0),0(R1)        <<< EXECUTED >>>                 00317700
DMPTR    TR    LINE+90(0),DMPTBLCH     <<< EXECUTED >>>                 00317800
*                                                                       00317900
*                                                                       00318000
*                                                                       00318100
DMPDSP   DS    0H                                                       00318200
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               00318300
         NI    0(R2),X'0F'             REMOVE ZONE                      00318400
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             00318500
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             00318600
         TR    0(2,R2),HEXTBL          TRANSLATE TO HEX                 00318700
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        00318800
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         00318900
         BCT   R15,DMPDSP              LOOP THRU DATA                   00319000
         BR    R14                     EXIT . . .                       00319100
*********************************************************************** 00319200
*                                                                     * 00319300
*                                                                     * 00319400
*                                                                     * 00319500
*********************************************************************** 00319600
DMPTBLCH DC    CL256' '                                                 00319700
         ORG   DMPTBLCH+X'4A' Cent                                      00319800
         DC    X'4A4B4C4D4E4F50' vert bar and ampersand                 00319900
         ORG   DMPTBLCH+X'5A' exclamation                               00320000
         DC    X'5A5B5C5D5E5F6061'                                      00320100
         ORG   DMPTBLCH+X'6A'                                           00320200
         DC    X'6A6B6C6D6E6F'                                          00320300
         ORG   DMPTBLCH+X'7A'                                           00320400
         DC    X'7A7B7C7D7E7F'                                          00320500
         ORG   DMPTBLCH+C'a'                                            00320600
         DC    C'abcdefghi'                                             00320700
         ORG   DMPTBLCH+C'j'                                            00320800
         DC    C'jklmnopqr'                                             00320900
         ORG   DMPTBLCH+C's'                                            00321000
         DC    C'stuvwxyz'                                              00321100
         ORG   DMPTBLCH+C'A'                                            00321200
         DC    C'ABCDEFGHI'                                             00321300
         ORG   DMPTBLCH+C'J'                                            00321400
         DC    C'JKLMNOPQR'                                             00321500
         ORG   DMPTBLCH+C'S'                                            00321600
         DC    C'STUVWXYZ'                                              00321700
         ORG   DMPTBLCH+C'0'                                            00321800
         DC    C'0123456789'                                            00321900
         ORG                                                            00322000
HEXTBL   DC    C'0123456789ABCDEF'                                      00322100
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  00322200
         LTORG ,                                                        00322300
         DC (((((*-MACCVT)/4096)+1)*4096)-(*-MACCVT))X'DD'              00322400
*********************************************************************** 00322500
*                                                                     * 00322600
*                                                                     * 00322700
*                                                                     * 00322800
*********************************************************************** 00322900
SAVEAREA DC    18A(0)                                                   00323000
TRCRGS   DC    16A(0)                                                   00323100
DMPREGS  DC    16A(0)                                                   00323200
DMPOFF   DS    A                                                        00323300
DMPADR   DS    A                                                        00323400
DUPFIRST DS    A                                                        00323500
DMPFLAG  DC    X'00'                                                    00323600
DMPFIRST EQU   X'80'                                                    00323700
DMPDUP   EQU   X'40'                                                    00323800
DWORD    DC    D'+0'                                                    00323900
PRTR14   DC    A(0)                                                     00324000
PUTR14   DC    A(0)                                                     00324100
PRMSTART DC    A(0)                                                     00324200
FLAG     DC    X'00'                                                    00324300
FLAGDBGA EQU   X'C0'                                                    00324400
FLAGDBGL EQU   X'80'                                                    00324500
FLAGDBGS EQU   X'40'                                                    00324600
FLAGNORL EQU   X'20'                                                    00324700
LINE     DC    CL133' '                                                 00324800
CURDATE  DC    A(0)                                                     00324900
JULWRK2  DC    A(0)                                                     00325000
JULWRK4  DC    P'+365'                                                  00325100
         DC    P'+01'                                                   00325200
         DC    P'+31'                                                   00325300
         DC    P'+30'                                                   00325400
         DC    P'+31'                                                   00325500
         DC    P'+30'                                                   00325600
         DC    P'+31'                                                   00325700
         DC    P'+31'                                                   00325800
         DC    P'+30'                                                   00325900
         DC    P'+31'                                                   00326000
         DC    P'+30'                                                   00326100
         DC    P'+31'                                                   00326200
JULWRK6  DC    P'+28'                                                   00326300
JULTBL1  DC    P'+31'                                                   00326400
TIMWRK4  DC    X'402021204B20204B20204B2020'                            00326500
LNCT     DC    PL2'+99'                                                 00326600
PGCT     DC    PL2'+0'                                                  00326700
HD1      DC    CL133'1'                                                 00326800
         ORG   HD1+1                                                    00326900
HD1DATE  DC    C'            '                                          00327000
         DC    C' '                                                     00327100
HD1TOD   DC    C'HH:MM:SS'                                              00327200
         ORG   HD1+66-(15/2)                                            00327300
HD1DATA  DC    C'DSECT Converter'                                       00327400
         ORG   HD1+L'HD1-8                                              00327500
HD1PG    DC    C'Page'                                                  00327600
HD1PGCT  DC    C' 123'                                                  00327700
         ORG   ,                                                        00327800
SYSIN    DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=CTLEOF              00327900
FMIDDD   DCB   DDNAME=FMID,MACRF=GM,DSORG=PS,EODAD=ERRFMNM              00328000
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      *00328100
               RECFM=FBA,LRECL=133                                      00328200
SYSUT1   DCB   DDNAME=SYSUT1,MACRF=GM,DSORG=PS,EODAD=PROCIN,           *00328300
               RECFM=FB,LRECL=80,EXLST=UT1EXLST                         00328400
SYSUT2   DCB   DDNAME=SYSUT2,MACRF=PM,DSORG=PS,                        *00328500
               RECFM=FB,LRECL=80,EXLST=UT2EXLST                         00328600
RENDCB   DCB   DDNAME=SYSUT2,MACRF=(R,W),DSORG=PO                       00328700
PTFIDDD  DCB   DDNAME=PTFID,MACRF=(GM,PM),DSORG=PS,EODAD=ERRPTFEF,     *00328800
               RECFM=FB,LRECL=80                                        00328900
UT1EXLST DC    AL1(128+7),AL3(UT1JFCB)                                  00329000
UT2EXLST DC    AL1(128+7),AL3(UT2JFCB)                                  00329100
UT1JFCB  DC    24D'0'              JFCB AREA                            00329200
UT2JFCB  DC    24D'0'              JFCB AREA                            00329300
*********************************************************************** 00329400
*********************************************************************** 00329500
*********************************************************************** 00329600
MACTBPT  DC    A(MACTBL)                                                00329700
SKPTBPT  DC    A(SKPTBL)                                                00329800
INSTBPT  DC    A(INSTBL)                                                00329900
CHGTBPT  DC    A(CHGTBL)                                                00330000
REGTBPT  DC    A(REGTBL)                                                00330100
NMTBPT   DC    A(NMTBL)                                                 00330200
NODCTPT  DC    A(NODCTTB)                                            07 00330210
CHKLBL14 DC    A(0)                                                     00330300
SUBLBL14 DC    A(0)                                                     00330400
SUBLBLR1 DC    A(0)                                                     00330500
REGCHK14 DC    A(0)                                                     00330600
REGCHKR1 DC    A(0)                                                     00330700
RESTREGS DC    0A(0)                                                    00330800
RESTR14  DC    A(0)                                                     00330900
RESTR15  DC    A(0)                                                     00331000
RESTR0   DC    A(0)                                                     00331100
RESTR1   DC    A(0)                                                     00331200
OPER1TB  DC    A(0)                                                     00331300
RENPARMS DS    0CL16                                                    00331400
ELNM     DS    0CL8                                                     00331500
RENPARMO DC    CL8' '                                                   00331600
RENPARMN DC    CL8' '                                                   00331700
RECIN    DC    PL4'+0'                                                  00331800
RECOUT   DC    PL4'+0'                                                  00331900
RECCHG   DC    PL4'+0'                                                  00332000
CHGCONT  DC    PL4'+0'                                                  00332100
RECINS   DC    PL4'+0'                                                  00332200
MISDSCNT DC    PL4'+0'                                                  00332300
ERRCNT   DC    PL4'+0'                                                  00332400
CONTCNT  DC    PL4'+0'                                                  00332500
SPEC2OP  DC    C' '                                                     00332600
CONTINCM DC    C' '                                                     00332700
RELDLM   DC    C' '                                                     00332800
ERRCOD   DC    C'   '                                                   00332900
CARD     DC    CL80' '                                                  00333000
NEWCARD  DC    CL80' '                                                  00333100
PREVSEQW DS    0CL9                                                     00333200
         DC    CL1' '                                                   00333300
PREVSEQ  DC    CL8' '                                                   00333400
CURRSEQ  DC    CL8' '                                                   00333500
QUOTLVL  DC    A(0)                                                     00333600
CONTSTMT DC    C' '                                                     00333700
CURRCONT DC    C' '                                                     00333800
CHGSTMT  DC    C' '                                                     00333900
STMTEOF  DC    C' '                                                     00334000
UPDPTFID DC    C' '                                                     00334100
PREPHASE DC    C'Y'                                                     00334200
NODCT    DC    C'N'                                                  07 00334210
INCLUDES DC    C'N'                                                     00334400
PTFID    DC    CL7' '                                                   00334500
FMID     DC    CL7' '                                                   00334600
MACPRMNM DC    CL8' '                                                   00334700
SKPPRMNM DC    CL8' '                                                   00334800
CHGLBLNM DC    CL8' '                                                   00334900
CHGLBLNN DC    CL16' '                                               04 00335000
OPCODE   DC    CL8' '                                                04 00335100
CONTSEQ  DC    20CL8' '                                                 00335200
CONTSEQZ EQU   *                                                        00335300
LONGSTMT DS    CL1600                                                   00335400
NEWSTMT  DS    CL1600                                                   00335500
RESTSAVR DS    CL1600                                                   00335600
         DC    0D'0'                                                    00335700
MACTBL   DC    400XL(L'MACTB)'00'                                    05 00335800
MACTBND  EQU   *                                                        00335900
         DC    0D'0'                                                    00336000
SKPTBL   DC    200XL(L'SKPTB)'00'                                    05 00336100
SKPTBND  EQU   *                                                        00336200
         DC    0D'0'                                                    00336300
INSTBL   DC    200XL(L'INSTB)'00'                                    05 00336400
INSTBND  EQU   *                                                        00336500
         DC    0D'0'                                                    00336600
CHGTBL   DC    700XL(L'CHGTB)'00'                                    05 00336700
CHGTBND  EQU   *                                                        00336800
         DC    0D'0'                                                    00336900
REGTBL   DC    200XL(L'REGTB)'00'      IEAVNIP0 HAS 177!             05 00337000
REGTBND  EQU   *                                                        00337100
         DC    0D'0'                                                    00337200
NMTBL    DC    400XL(L'NMTB)'00'       IEAVTSDX HAS 259!             06 00337300
NMTBND   EQU   *                                                        00337400
         DC    0D'0'                                                 07 00337410
NODCTTB  DC    100XL8'00'                                            07 00337420
NODCTND  EQU   *                                                     07 00337430
R0       EQU   0                                                        00337500
R1       EQU   1                                                        00337600
R2       EQU   2                                                        00337700
R3       EQU   3                                                        00337800
R4       EQU   4                                                        00337900
R5       EQU   5                                                        00338000
R6       EQU   6                                                        00338100
R7       EQU   7                                                        00338200
R8       EQU   8                                                        00338300
R9       EQU   9                                                        00338400
R10      EQU   10                                                       00338500
R11      EQU   11                                                       00338600
R12      EQU   12                                                       00338700
R13      EQU   13                                                       00338800
R14      EQU   14                                                       00338900
R15      EQU   15                                                       00339000
JFCB     DSECT                                                          00339100
         IEFJFCBN                                                       00339200
         END                                                            00339300
