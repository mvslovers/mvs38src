*********************************************************************** 00010001
*                                                                     * 00020001
*  COMMAND PROCESSOR TO UPDATE DSCB1 (AND DIRF FOR VTOC)              * 00030001
*                                                                     * 00040001
*********************************************************************** 00050001
*                                                                     * 00060001
*  PARAMETERS                                                         * 00070001
*       DATA SET NAME (MAY BE FORMAT 'FORMAT4.DSCB' OR 'F4')          * 00071007
*       PASSWORD(OPTION)                                              * 00080001
*                OFF - TURN OFF PASSWORD REQUIRED FLAGS               * 00090001
*                WRITE - REQUIRE PASSWORD FOR WRITE                   * 00100001
*                READ - REQUIRE PASSWORD FOR READ                     * 00110001
*                RACF - TURN ON RACF PROTECTED (DISCRETE PROFILE)     * 00120001
*                NORACF - TURN OFF RACF PROTECTION                    * 00130001
*       VOLUME(VOLSER)                                                * 00140001
*       UNIT(UNIT)                                                    * 00150001
*       BLKSIZE(BLKSIZE)                                              * 00160001
*       KEYLEN(KEYLENGTH)                                             * 00170001
*       LRECL(LRECL)                                                  * 00180001
*       OPTCD(OPTION)                                                 * 00190001
*                C - CHAINED SCHEDULING                               * 00200001
*                T - USER TOTALING                                    * 00210001
*                W - PERFORM VALIDATY CHECKING                        * 00220001
*                Q - CHARACTER CONVERSION                             * 00230001
*       RECFM(OPTION)                                                 * 00240001
*                A - ASA CONTROL CHARCTERS                            * 00250001
*                B - BLOCKED                                          * 00260001
*                F - FIXED                                            * 00270001
*                M - MACHINE CONTROL CHARCTERS                        * 00280001
*                S - STANDARD OR SPANNED                              * 00290001
*                T - TRACK OVERFLOW                                   * 00300001
*                U - UNDEFINED                                        * 00310001
*                V - VARIABLE                                         * 00320001
*                ZERO                                                 * 00330001
*       EXPDT(EXPIRATION DATE)                                        * 00340001
*       RETPD(RETENTION PERIOD)                                       * 00350001
*       REFDT(REFERENCED DATE)                                        * 00360001
*       CRTDT(CREATION DATE)                                          * 00370001
*       SECONDARY(SECONDARY ALLOCATION)                               * 00380001
*       ALLOCATION(OPTION)                                            * 00390001
*                CYL                                                  * 00400001
*                TRK                                                  * 00410001
*                BLOCK                                                * 00420001
*                ABSTR                                                * 00430001
*                CONTIG                                               * 00440001
*                MXIG                                                 * 00450001
*                ALX                                                  * 00460001
*                NOCMA - CONTIG MXIG ALX                              * 00470001
*                ROUND                                                * 00480001
*                NOROUND                                              * 00490001
*       DSORG(OPTION)                                                 * 00500001
*                IS                                                   * 00510001
*                ISU                                                  * 00520001
*                PS                                                   * 00530001
*                PSU                                                  * 00540001
*                DA                                                   * 00550001
*                DAU                                                  * 00560001
*                PO                                                   * 00570001
*                POU                                                  * 00580001
*                ZERO                                                 * 00590001
*       RKP(RECORD KEY POSITION)                                      * 00600001
*       NEWDSN(NEW DATA SET NAME)                                     * 00610001
*       LASTVOL(OPTION)                                               * 00620001
*                YES                                                  * 00630001
*                NO                                                   * 00640001
*       UPDATED(OPTION)                                               * 00650001
*                YES                                                  * 00660001
*                NO                                                   * 00670001
*       DIRF (UPDATE THE DIRF BIT IN THE FORMAT 4 DSCB)               * 00680002
*       DOSOFF (RESET THE DOS CONVERTED IN THE FORMAT 4 DSCB)         * 00690007
*       NOCONFIRM (DON'T ASK FOR UPDATE VTOC CONFIRMATION)            * 00700002
*                                                                     * 00710001
*  EXAMPLES                                                           * 00720001
*       DSCBUPDT 'DATA.SET.NAME' DSORG(ZERO) VOLUME(VOLSER)           * 00730001
*       DSCBUPDT 'FORMAT4.DSCB' DIRF VOLUME(VOLSER)                   * 00740001
*                                                                     * 00750001
*********************************************************************** 00760001
*                                                                     * 00770001
* CHANGE LOG:                                                         * 00780001
* MM/DD/YY AAA VV.VV DESCRIPTION                                      * 00790001
* ??/??/?? DSK 01.01 CREATED AT CB2                                   * 00800001
* 04/09/15 DSK 01.02 CORRECT PUTLINE, VALIDATE VTOC UPDATE            * 00810004
* 06/01/16 DSK 01.03 ADD NOCONFIRM TO SKIP CONFIRMATION OF UPDATE     * 00820004
* 05/25/20 DSK 01.04 DISPLAY ALL OF RETURN CODE ADD SVC 99 ERROR      * 00830004
* 05/27/20 DSK 01.05 WTO WHEN DIRF IS SET ON FOR VOLUME               * 00840005
* 06/06/20 DSK 01.06 F4 ABBREVIATION AND DIRF REQUIRES FORMAT4.DSCB   * 00850007
* 07/18/23 DSK 01.07 ADD UPDATE OF DOS CONVERTED FLAG FORMAT4.DSCB    * 00860007
*********************************************************************** 00870001
         LCLC   &VER                                                 04 00880004
&VER     SETC   '01.07'                                              06 00890007
DSCBUPDT CSECT ,                                                     01 00900001
R0       EQU   0                                                        00910000
R1       EQU   1                                                        00920000
R2       EQU   2                                                        00930000
R3       EQU   3                                                        00940000
R4       EQU   4                                                        00950000
R5       EQU   5                                                        00960000
R6       EQU   6                                                        00970000
R7       EQU   7                                                        00980000
R8       EQU   8                                                        00990000
R9       EQU   9                                                        01000000
R10      EQU   10                                                       01010000
R11      EQU   11                                                       01020000
R12      EQU   12                                                       01030000
R13      EQU   13                                                       01040000
R14      EQU   14                                                       01050000
R15      EQU   15                                                       01060000
         USING *,R15                   TEMPORARY ADDRESSABILITY         01070000
         B     START                   SKIP PAST PROGRAM ID             01080000
         DROP  R15                     DROP TEMP BASE                   01090000
         DC    AL1(L'PGMID)            LENGTH OF PGM ID                 01100000
PGMID    DC    C'DSCBUPDT &VER &SYSDATE &SYSTIME' PGM ID             04 01110004
START    DC    0H'+0'                  MAIN PROCESSING                  01120000
         SAVE  (14,12)                 SAVE SYSTEM REGISTERS            01130000
         LR    R11,R15                 SET IN BASE REGISTER             01140000
         LA    R12,2048(,R11)          SET UP SECOND                    01150000
         LA    R12,2048(,R12)           BASE REGISTER                   01160000
         USING DSCBUPDT,R11,R12        ESTABLISH BASE REGISTER          01170000
         LR    R2,R1                   PICKUP CPPL ADDRESS              01180000
         USING CPPL,R2                 ESTABLISH ADDRESSABILITY TO CPPL 01190000
         L     R1,=A(SAVE)             ADDRESS SAVEAREA              05 01200005
         USING SAVE,R13                                              05 01210005
         ST    R1,8(,R13)              CHAIN CALLERS SAVEARE TO MINE 01 01220001
         ST    R13,4(,R1)              CHAIN MY SAVEAREA TO SYSTEMS  01 01230001
         LR    R13,R1                  SAVEAREA ADDRESS                 01240000
         USING PSA,R0                  ADDRESSABILITY TO PSA            01250000
         L     R15,PSAAOLD             LOAD CURRENT ASCB ADDRESS        01260000
         USING ASCB,R15                ESTABLISH ADDRESSABILITY         01270000
         L     R14,ASCBOUCB            LOAD OUCB ADDRESS                01280001
         USING OUCB,R14                ESTABLISH ADDRESSABILITY         01290001
         CLI   ASCBOUCB,0              OUCB ABOVE LINE?              01 01300001
         BE    AMODE24A                NO, PRE XA SYSTEM             01 01310001
         L     R1,=A(X'80000000'+AMODE31A) SET UP FOR AMODE 31          01320000
         DC    X'0B01'  BSM   0,R1     SET ADDRESSING MODE 31        04 01330004
AMODE31A DS    0H                                                    01 01340001
         TM    OUCBYFL,OUCBLOG         IS THIS A TSO JOB?            01 01350001
         LA    R1,AMODE24B             SET UP RETURN TO AMODE 24     01 01360001
         DC    X'0B01'  BSM   0,R1     SET ADRESSING MODE 31         04 01370004
AMODE24A DS    0H                                                    01 01380001
         TM    OUCBYFL,OUCBLOG         IS THIS A TSO JOB?            01 01390001
AMODE24B DS    0H                                                    01 01400001
         BNO   ERRORXIT                 NO, EXIT                     01 01410001
         DROP  R15                                                   01 01420001
         DROP  R14                                                   01 01430001
         LA    R1,MYPPL                ADDRESS PPL FOR PARSING       01 01440001
         USING PPL,R1                  ADDRESSABILITY TO PPL            01450000
         MVC   PPLUPT,CPPLUPT          BUIDL PPL - UPT ADDRESS          01460000
         MVC   PPLECT,CPPLECT                    - ECT ADDRESS          01470000
         LA    R0,PARSECB                        - ECB                  01480000
         ST    R0,PPLECB                           ADDRESS              01490000
         LA    R15,ANSWER                        - ANSWER               01500000
         ST    R15,PPLANS                          ADDRESS              01510000
         MVC   PPLCBUF,CPPLCBUF                  - COMMAND BUFFER ADDR  01520000
         MVC   PPLPCL,=A(ZAPPARM)                - PCL ADDRESS          01530000
         ST    R11,PPLUWA                        - 1ST BASE IN WORKAREA 01540000
         DROP  R1                      DROP ADDRESSABILITY TO PPL       01550000
         DROP  R2                      DROP ADDRESSABILITY TO CPPL      01560000
         LA    R1,PGMID                PROGRAM ID                    05 01570005
         SR    R0,R0                   CLEAR FOR LENGTH              05 01580005
         IC    R0,PGMID-1              LENGTH OF PROGRAM ID          05 01590005
         BAL   R14,ANYMSG              ISSUE VERSION MESSAGE         05 01600005
         CALLTSSR EP=IKJPARS,MF=(E,MYPPL) CALL PARSE                 05 01610005
         LTR   R15,R15                 WAS PARSE SUCCESSFUL ?           01620000
         BZ    PARSOK                   YES, CONTINUE                   01630000
         LA    R1,PARSERMS             ADDRESS PARSE ERROR MESSAGE      01640000
         LA    R0,L'PARSERMS           GET MESSAGES LENGTH              01650000
         BAL   R14,PUTERRC             PUT PARSE ERROR MESSAGE W/RC     01660000
         B     ERRORXIT                GO EXIT . . .                    01670000
PARSOK   DS    0H                                                    01 01680001
         LA    R1,MYPPL                RESTORE ADDRESS TO PPL           01690000
         USING PPL,R1                  ADDRESSABILITY TO PPL            01700000
         L     R3,PPLANS               GET ADDRESS OF ANSWER AREA       01710000
         DROP  R1                      DROP ADDRESSABILITY TO PPL       01720000
         L     R4,0(,R3)               GET PARSE DESCRIPTOR LIST (PDL)  01730000
         USING ZAPPDL,R4               ADDRESSABILITY TO PDL            01740000
         L     R15,ZAPDSN              GET DATA SET NAME ADDRESS        01750000
         LH    R14,ZAPDSN+4            GET DSN LENGTH                   01760000
         BCTR  R14,0                   MAKE MACHINE LENGTH              01770000
         MVI   DSN,C' '                CLEAR OUT HOLD DSN               01780000
         MVC   DSN+1(L'DSN-1),DSN       TO BLANKS                       01790000
         EX    R14,MOVDSN              MOVE DATA SET NAME FROM CBUF     01800000
         CLC   =C'F4 ',DSN             SHORT FORMAT 4 ABBREVIATION   06 01810006
         BE    ISFMT4                  YES, USE IT                   06 01820006
         CLC   =C'FORMAT4.DSCB ',DSN                                 06 01830006
         BNE   NOTFMT4                  NO, CONTINUE                    01840000
ISFMT4   DS    0H                                                    06 01850006
         OI    UPDTFLAG,FMT4UPDT       INDICATE UPDATEING FORMAT 4 DSCB 01860000
         MVI   DSN,4                   SET UP DATA SET NAME             01870000
         MVC   DSN+1(43),DSN           SET DATA SET NAME                01880000
         ICM   R15,15,ZAPVOL           WAS VOL SER ENTERED?          01 01890001
         BNZ   NOTFMT4                                               01 01900001
         LA    R1,=C'FORMAT4.DSCB REQUIRES VOLUME'                   01 01910001
         LA    R0,28                   LENGTH OF MESSAGE             01 01920001
         BAL   R14,ANYMSG              PUT ERROR MESSAGE             01 01930001
         B     ERRORXIT                GO EXIT . . .                 01 01940001
NOTFMT4  DS    0H                                                    01 01950001
         MVC   UNIT(8),=CL8'SYSALLDA'  INITIALIZE UNIT NAME          01 01960001
         MVI   UNIT-1,8                LENGTH OF NAME                   01970000
         MVC   VOLSER,=CL6' '          CLEAR VOLUME SERIAL NUMBER       01980000
         LH    R15,ZAPVOL              WAS VOLUME SERIAL NUMBER ENTERED 01990000
         LTR   R15,R15                 IS IT PRESENT ?                  02000000
         BZ    NOVOLSER                 NO, DONT TRY TO GET IT          02010000
         L     R15,ZAPVOLUM            ADDRESS VOL SER                  02020000
         LH    R1,ZAPVOLUM+4           GET LENGTH OF VOLUME SERIAL NO   02030000
         STC   R1,VOLSER-1             SET VOL SER LENGTH            04 02040004
         BCTR  R1,0                    MAKE IT MACHINE LENGTH           02050000
         EX    R1,MOVVOL               MOVE VOLUME SERIAL NUMBER        02060000
         LH    R15,ZAPUNT              WAS UNIT NAME ENTERED            02070000
         LTR   R15,R15                 IS IT PRESENT ?                  02080000
         BZ    NOUNTNAM                 NO, DONT TRY TO GET IT          02090000
         MVC   UNIT,=CL8' '            CLEAR UNIT NAME                  02100000
         L     R15,ZAPUNTNM            ADDRESS UNIT NAME                02110000
         LH    R1,ZAPUNTNM+4           GET LENGTH OF UNIT NAME          02120000
         STC   R1,UNIT-1               UNIT NAME LENGTH              04 02130004
         BCTR  R1,0                    MAKE IT MACHINE LENGTH           02140000
         EX    R1,MOVUNT               MOVE VOLUME SERIAL NUMBER        02150000
NOUNTNAM DS    0H                                                    01 02160001
NOVOLSER DS    0H                                                    01 02170001
         ICM   R15,15,ZAPVOL           WAS VOL SER ENTERED?          01 02180001
         BNZ   HAVEVOL                  YES, DONT TRY TO FIND IT     01 02190001
         LOCATE LOCATLST               LOCATE VOLUME ON WHICH DSN IS    02200000
         LTR   R15,R15                 LOCATE OK ?                      02210000
         BZ    LOCOK                    YES, CONTINUE                   02220000
         CH    R15,=H'8'               DATA SET NOT FOUND?           06 02230006
         BE    DSNNFD                  YES, ISSUE THAT MESSAGE       06 02240006
         LA    R1,LOCERMS              ADDRESS ERROR MESSAGE            02250000
         LA    R0,L'LOCERMS            LENGTH OF MESSAGE                02260000
         BAL   R14,PUTERRC             PUT ERROR MESSAGE                02270000
         B     ERRORXIT                GO EXIT . . .                    02280000
DSNNFD   DS    0H                                                    06 02290006
         LA    R1,=C'DATA SET NOT FOUND'                             06 02300006
         LA    R0,18                   LENGTH OF MESSAGE             06 02310006
         BAL   R14,ANYMSG              PUT ERROR MESSAGE             06 02320006
         B     ERRORXIT                GO EXIT . . .                 06 02330006
LOCOK    DS    0H                                                    01 02340001
         MVC   VOLSER,DSCB+6           PICK OUT VSN FROM LOCATE      01 02350001
HAVEVOL  DS    0H                                                    01 02360001
         LA    R1,ALOCPRMS             ADDRESS ALLOCATE PARAMETER ADDR  02370000
         SVC   99                      ALLOCATE PASSFREE DD             02380000
         LTR   R15,R15                 ALLOCATE OK ?                    02390000
         BZ    ALLOCOK                  YES, CONTINUE                   02400000
         LA    R1,ALOCERMS             ADDRESS ERROR MESSAGE            02410000
         LA    R0,L'ALOCERMS           LENGTH OF MESSAGE                02420000
         BAL   R14,PUTERRC             PUT ERROR MESSAGE                02430000
         L     R15,RBERROR             GET DYNAMIC ALLOCATION ERROR  04 02440004
         LA    R1,SVC99EMS             ADDRESS ERROR MESSAGE         04 02450004
         LA    R0,L'SVC99EMS           LENGTH OF MESSAGE             04 02460004
         BAL   R14,PUTERRC             PUT ERROR MESSAGE             04 02470004
         B     ERRORXIT                GO EXIT . . .                    02480000
ALLOCOK  DS    0H                                                    01 02490001
         OBTAIN CAMLST                 FETCH DSCB                       02500000
         LTR   R15,R15                 OBTAIN OK ?                      02510000
         BZ    OBTAINOK                 YES, CONTINUE                   02520000
         LA    R1,OBTERMS              ADDRESS ERROR MESSAGE            02530000
         LA    R0,L'OBTERMS            LENGTH OF MESSAGE                02540000
         BAL   R14,PUTERRC             PUT ERROR MESSAGE                02550000
         B     ERRORXIT                GO EXIT . . .                    02560000
OBTAINOK DS    0H                                                    01 02570001
         MVC   MSG(4),=C'DSN='         SET UP LITERAL                   02580000
         L     R15,ZAPDSN              GET DATA SET NAME ADDRESS        02590000
         LH    R14,ZAPDSN+4            GET DSN LENGTH                   02600000
         BCTR  R14,0                   MAKE MACHINE LENGTH              02610000
         EX    R14,MSGDSNMV            MOVE DATA SET NAME FROM CBUF     02620000
         LA    R15,MSG+7(R14)          ADDRESS END OF DSN               02630000
         MVC   0(8,R15),=C'VOL=SER='   SET UP LITERAL                   02640000
         MVC   8(6,R15),VOLSER         MOVE IN VOL SER                  02650000
         BAL   R14,PUTMSG              PUT MESSAGE                      02660000
         TM    UPDTFLAG,FMT4UPDT       UPDATING VTOC ?                  02670000
         BO    DOFMT4                  YES, GO DO IT                 01 02680001
*                                                                    01 02690001
*********************************************************************** 02700000
*                                                                     * 02710000
*       UPDATE THE PASSWORD PROTECT BITS IF ENTERED                   * 02720000
*                                                                     * 02730000
*********************************************************************** 02740000
         LA    R3,DSCB                 ADDRESS DSCB                     02750000
         USING DS1FMTID,R3             ADDRESSABILITY TO FMT 1 DSCB     02760000
         CH    R15,ZAPOPTS             ANY PASSWORD UPDATE OPTIONS ?    02770000
         BZ    PWDEND                   NO, END OF PWD PROCESSING       02780000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                02790000
         MVC   MSG(10),=C'PROTECTION'  SET UP MESSAGE                   02800000
         LA    R10,MSG+11              INIT POINTER IN MESSAGE          02810000
         BAL   R14,FMTPWD              GO FORMAT CURRNT PWD OPTIONS     02820000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            02830000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            02840000
         LH    R1,PWDFLDS              GET INDEX                        02850000
         SLL   R1,2                    MAKE INDEX INTO BRANCH TABLE     02860000
         B     *(R1)                   DO OPTION                        02870000
         B     PWDOFF                  GO TURN PWD OFF                  02880000
         B     PWDREAD                 GO SET READ ONLY ON              02890000
         B     PWDRDWRT                GO SET READ/WRITE OPTION ON      02900000
         B     PWDRACF                 GO SET RACF OPTION ON            02910000
         B     PWDNRACF                GO SET RACF OPTION OFF           02920000
*                                                                    01 02930001
PWDOFF   DS    0H                                                    01 02940001
         NI    DS1DSIND,255-DS1IND10-DS1IND04 SET PASSWORD OPTIONS OFF  02950000
         B     PWDFMTNW                GO PRINT NEW OPTIONS             02960000
*                                                                    01 02970001
PWDREAD  DS    0H                                                    01 02980001
         NI    DS1DSIND,255-DS1IND10-DS1IND04 SET PASSWORD OPTIONS OFF  02990000
         OI    DS1DSIND,DS1IND10+DS1IND04 SET PASSWORD FOR WRITE ONLY   03000000
         B     PWDFMTNW                GO PRINT NEW OPTIONS             03010000
*                                                                    01 03020001
PWDRDWRT DS    0H                                                    01 03030001
         NI    DS1DSIND,255-DS1IND10-DS1IND04 SET PASSWORD OPTIONS OFF  03040000
         OI    DS1DSIND,DS1IND10       SET PASSWORD FOR READ/WRITE      03050000
         B     PWDFMTNW                GO PRINT NEW OPTIONS             03060000
*                                                                    01 03070001
PWDRACF  DS    0H                                                    01 03080001
         OI    DS1DSIND,DS1IND40       SET RACF OPTION ON               03090000
         B     PWDFMTNW                GO PRINT NEW OPTIONS             03100000
*                                                                    01 03110001
PWDNRACF DS    0H                                                    01 03120001
         NI    DS1DSIND,255-DS1IND40   SET RACF OPTIONS OFF             03130000
*                                                                    01 03140001
PWDFMTNW DS    0H                                                    01 03150001
         BAL   R14,FMTPWD              GO FORMAT NEW OPTIONS            03160000
         BAL   R14,PUTMSG              PRINT CHANGED LINE               03170000
PWDEND   DS    0H                                                    01 03180001
*                                                                    01 03190001
*********************************************************************** 03200000
*                                                                     * 03210000
*       UPDATE THE LAST VOLUME INDICATOR                              * 03220000
*                                                                     * 03230000
*********************************************************************** 03240000
         CH    R15,LASTVOL             ANY LAST VOLUME  OPTIONS ?       03250000
         BZ    LSTEND                   NO, END OF LAST VOL  PROCESSING 03260000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                03270000
         MVC   MSG(11),=C'LAST VOLUME' SET UP MESSAGE                   03280000
         LA    R10,MSG+12              INIT POINTER IN MESSAGE          03290000
         BAL   R14,FMTLST              GO FORMAT CURRNT LAST VOL IND    03300000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            03310000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            03320000
         LH    R1,LASTFLDS             GET INDEX                        03330000
         SLL   R1,2                    MAKE INDEX INTO BRANCH TABLE     03340000
         B     *(R1)                   DO OPTION                        03350000
         B     LSTYES                  GO TURN LAST VOL ON              03360000
         B     LSTNO                   GO TURN LAST VOL OFF             03370000
*                                                                    01 03380001
LSTYES   DS    0H                                                    01 03390001
         OI    DS1DSIND,DS1IND80       SET LAST VOLUME                  03400000
         B     LSTFMTNW                GO PRINT NEW OPTIONS             03410000
*                                                                    01 03420001
LSTNO    DS    0H                                                    01 03430001
         NI    DS1DSIND,255-DS1IND80   SET LAST VOL INDICATOR OFF       03440000
*                                                                    01 03450001
LSTFMTNW DS    0H                                                    01 03460001
         BAL   R14,FMTLST              GO FORMAT NEW OPTIONS            03470000
         BAL   R14,PUTMSG              PRINT CHANGED LINE               03480000
LSTEND   DS    0H                                                    01 03490001
*                                                                    01 03500001
*********************************************************************** 03510000
*                                                                     * 03520000
*       UPDATE CHANGED INDICATOR                                      * 03530000
*                                                                     * 03540000
*********************************************************************** 03550000
         CH    R15,DSUPDATE            ANY UPDATE OPTIONS ?             03560000
         BZ    UPDEND                   NO, UPDATE OPTIONS           01 03570001
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                03580000
         MVC   MSG(7),=C'UPDATED'      SET UP MESSAGE                   03590000
         LA    R10,MSG+8               INIT POINTER IN MESSAGE          03600000
         BAL   R14,FMTUPD              GO FORMAT CURRNT LAST VOL IND    03610000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            03620000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            03630000
         LH    R1,UPDFLDS              GET INDEX                        03640000
         SLL   R1,2                    MAKE INDEX INTO BRANCH TABLE     03650000
         B     *(R1)                   DO OPTION                        03660000
         B     UPDYES                  GO TURN UPDATED ON               03670000
         B     UPDNO                   GO TURN UPDATED OFF              03680000
*                                                                    01 03690001
UPDYES   DS    0H                                                    01 03700001
         OI    DS1DSIND,DS1IND02       SET UPDATED                      03710000
         B     UPDFMTNW                GO PRINT NEW OPTIONS             03720000
*                                                                    01 03730001
UPDNO    DS    0H                                                    01 03740001
         NI    DS1DSIND,255-DS1IND02   SET NOT UPDATED                  03750000
*                                                                    01 03760001
UPDFMTNW DS    0H                                                    01 03770001
         BAL   R14,FMTUPD              GO FORMAT NEW OPTIONS            03780000
         BAL   R14,PUTMSG              PRINT CHANGED LINE               03790000
UPDEND   DS    0H                                                    01 03800001
*                                                                    01 03810001
*********************************************************************** 03820000
*                                                                     * 03830000
*       UPDATE THE OPTION CODE FIELDS IF ENTERED                      * 03840000
*                                                                     * 03850000
*********************************************************************** 03860000
         SR    R15,R15                 ZERO WORK REGISTER               03870000
         CH    R15,OPTCD               IS OPTION CODE ENTERED ?         03880000
         BNL   NOPTCD                   NO, SKIP OPTION CODE PROCESSING 03890000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                03900000
         MVC   MSG(5),=CL8'OPTCD   '   SET UP MESSAGE                01 03910001
         LA    R10,MSG+6               INIT LINE POINTER                03920000
         BAL   R14,FMTOPC              FORMAT CURRENT OPTION CODE       03930000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            03940000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            03950000
         MVI   DS1OPTCD,0              ZERO OPTION CODE                 03960000
         CH    R15,CODEFLD0            IS OPTION CODE TO BE ZEROED ?    03970000
         BE    OPTCNEW                  YES, GO FORMAT NEW OPTCD        03980000
         CH    R15,CODEFLDC            IS OPTION CODE "C" ?             03990000
         BNL   CHKOPTT                  NO, MAKE NEXT TEST              04000000
         OI    DS1OPTCD,DCBOPTC        SET IN OPTION CODE "C"           04010000
CHKOPTT  DS    0H                                                    01 04020001
         CH    R15,CODEFLDT            IS OPTION CODE "T" ?             04030000
         BNL   CHKOPTW                  NO, MAKE NEXT TEST              04040000
         OI    DS1OPTCD,DCBOPTT        SET IN OPTION CODE "T"           04050000
CHKOPTW  DS    0H                                                    01 04060001
         CH    R15,CODEFLDW            IS OPTION CODE "W" ?             04070000
         BNL   CHKOPTQ                  NO, MAKE NEXT TEST              04080000
         OI    DS1OPTCD,DCBOPTW        SET IN OPTION CODE "W" ?         04090000
CHKOPTQ  DS    0H                                                    01 04100001
         CH    R15,CODEFLDQ            IS OPTION CODE "Q" ?             04110000
         BNL   OPTCNEW                  NO, MAKE NEXT TEST              04120000
         OI    DS1OPTCD,DCBOPTQ        SET IN OPTION CODE "Q"           04130000
OPTCNEW  DS    0H                                                    01 04140001
         BAL   R14,FMTOPC              FORMAT NEW OPTCOD                04150000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            04160000
NOPTCD   DS    0H                                                    01 04170001
*                                                                    01 04180001
*********************************************************************** 04190000
*                                                                     * 04200000
*       UPDATE THE RECFM FIELD IF ENTERED                             * 04210000
*                                                                     * 04220000
*********************************************************************** 04230000
         CH    R15,RECFM               IS RECFM ENTERED ?               04240000
         BNL   NORECFM                  NO, END OF RECFM PROCESSING     04250000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                04260000
         MVC   MSG(5),=CL8'RECFM   '   SET UP MESSAGE                01 04270001
         LA    R10,MSG+6               INIT LINE POINTER                04280000
         BAL   R14,FMTRFM              FORMAT CURRENT RECFM             04290000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            04300000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            04310000
         MVI   DS1RECFM,0              RESET RECFM                      04320000
         CH    R15,FORMFLD0            IS RECFM TO BE ZEROED ?          04330000
         BL    RFMFMTNW                 YES, GO EXIT                    04340000
         CH    R15,FORMFLDA            IS RECFM "A" ?                   04350000
         BNL   CHKRFMB                  NO, MAKE NEXT CHECK             04360000
         OI    DS1RECFM,DCBRECCA       SET "A" RECFM                    04370000
CHKRFMB  DS    0H                                                    01 04380001
         CH    R15,FORMFLDB            IS RECFM "B" ?                   04390000
         BNL   CHKRFMF                  NO, MAKE NEXT CHECK             04400000
         OI    DS1RECFM,DCBRECBR       SET "B" RECFM                    04410000
CHKRFMF  DS    0H                                                    01 04420001
         CH    R15,FORMFLDF            IS RECFM "F" ?                   04430000
         BNL   CHKRFMM                  NO, MAKE NEXT CHECK             04440000
         OI    DS1RECFM,DCBRECF        SET "F" RECFM                    04450000
CHKRFMM  DS    0H                                                    01 04460001
         CH    R15,FORMFLDM            IS RECFM "M" ?                   04470000
         BNL   CHKRFMS                  NO, MAKE NEXT CHECK             04480000
         OI    DS1RECFM,DCBRECCM       SET "M" RECFM                    04490000
CHKRFMS  DS    0H                                                    01 04500001
         CH    R15,FORMFLDS            IS RECFM "S" ?                   04510000
         BNL   CHKRFMT                  NO, MAKE NEXT CHECK             04520000
         OI    DS1RECFM,DCBRECSB       SET "S" RECFM                    04530000
CHKRFMT  DS    0H                                                    01 04540001
         CH    R15,FORMFLDT            IS RECFM "T" ?                   04550000
         BNL   CHKRFMU                  NO, MAKE NEXT CHECK             04560000
         OI    DS1RECFM,DCBRECTO       SET "T" RECFM                    04570000
CHKRFMU  DS    0H                                                    01 04580001
         CH    R15,FORMFLDU            IS RECFM "U" ?                   04590000
         BNL   CHKRFMV                  NO, MAKE NEXT CHECK             04600000
         OI    DS1RECFM,DCBRECU        SET "U" RECFM                    04610000
CHKRFMV  DS    0H                                                    01 04620001
         CH    R15,FORMFLDV            IS RECFM "V" ?                   04630000
         BNL   RFMFMTNW                 NO, MAKE GO FORMAT NEW          04640000
         OI    DS1RECFM,DCBRECV        SET "V" RECFM                    04650000
RFMFMTNW DS    0H                                                    01 04660001
         BAL   R14,FMTRFM              FORMAT NEW RECFM                 04670000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            04680000
NORECFM  DS    0H                                                    01 04690001
*                                                                    01 04700001
*********************************************************************** 04710000
*                                                                     * 04720000
*       UPDATE THE KEY LENGTH FIELD IF ENTERED                        * 04730000
*                                                                     * 04740000
*********************************************************************** 04750000
         CH    R15,KEYLEN              IS THERE A KEY LENGTH ?          04760000
         BNL   NOKEYLN                  NO, CHECK NEXT FIELD            04770000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                04780000
         MVC   MSG(5),=CL8'KEYLN   '   SET UP MESSAGE                01 04790001
         LA    R10,MSG+6               INIT LINE POINTER                04800000
         SLR   R1,R1                   ZERO WORK                        04810000
         IC    R1,DS1KEYL              GET KEY LENGTH                   04820000
         BAL   R14,FMTNUM              FORMAT CURRENT KEY LENGTH        04830000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            04840000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            04850000
         LA    R7,KEYLNFLD             ADDRESS KEYLEN                   04860000
         BAL   R14,CONVERT             CONVERT IT TO BINARY             04870000
         STC   R1,DS1KEYL              SAVE IT IN DSCB                  04880000
         BAL   R14,FMTNUM              FORMAT CURRENT KEY LENGTH        04890000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            04900000
NOKEYLN  DS    0H                                                    01 04910001
*                                                                    01 04920001
*********************************************************************** 04930000
*                                                                     * 04940000
*       UPDATE THE KEY LENGTH FIELD IF ENTERED                        * 04950000
*                                                                     * 04960000
*********************************************************************** 04970000
         CH    R15,RKP                 IS THERE A RKP ?                 04980000
         BNL   NORKP                    NO, CHECK NEXT FIELD            04990000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                05000000
         MVC   MSG(3),=CL8'RKP     '   SET UP MESSAGE                01 05010001
         LA    R10,MSG+4               INIT LINE POINTER                05020000
         SR    R1,R1                   ZERO WORK                        05030000
         ICM   R1,3,DS1RKP             GET KEY LENGTH                   05040000
         BAL   R14,FMTNUM              FORMAT CURRENT RKP               05050000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            05060000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            05070000
         LA    R7,RKPFLD               ADDRESS RKP                      05080000
         BAL   R14,CONVERT             CONVERT IT TO BINARY             05090000
         STCM  R1,3,DS1RKP             SAVE IT IN DSCB                  05100000
         BAL   R14,FMTNUM              FORMAT CURRENT KEY LENGTH        05110000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            05120000
NORKP    DS    0H                                                    01 05130001
*                                                                    01 05140001
*********************************************************************** 05150000
*                                                                     * 05160000
*       UPDATE THE BLOCK SIZE FIELD IF ENTERED                        * 05170000
*                                                                     * 05180000
*********************************************************************** 05190000
         CH    R15,BLKSIZE             IS THERE A BLKSIZE ENTERED ?     05200000
         BNL   NOBLKL                   NO, CHECK NEXT FIELD            05210000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                05220000
         MVC   MSG(7),=CL8'BLKSIZE '   SET UP MESSAGE                01 05230001
         LA    R10,MSG+8               INIT LINE POINTER                05240000
         LH    R1,DS1BLKL              GET BLKSIZE                      05250000
         BAL   R14,FMTNUM              FORMAT CURRENT BLKSIZE           05260000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            05270000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            05280000
         LA    R7,BLKSZFLD             ADDRESS BLOCK SIZE               05290000
         BAL   R14,CONVERT             CONVERT IT TO BINARY             05300000
         STH   R1,DS1BLKL              STORE IT IN DSCB                 05310000
         BAL   R14,FMTNUM              FORMAT CURRENT BLKSIZE           05320000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            05330000
NOBLKL   DS    0H                                                    01 05340001
*                                                                    01 05350001
*********************************************************************** 05360000
*                                                                     * 05370000
*       UPDATE THE RECORD SIZE IF ENTERED                             * 05380000
*                                                                     * 05390000
*********************************************************************** 05400000
         CH    R15,LRECL               IS THERE A LRECL ENTERED ?       05410000
         BNL   NORECL                   NO, CHECK NEXT FIELD            05420000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                05430000
         MVC   MSG(5),=CL8'LRECL   '   SET UP MESSAGE                01 05440001
         LA    R10,MSG+6               INIT LINE POINTER                05450000
         LH    R1,DS1LRECL             GET LRECL                        05460000
         BAL   R14,FMTNUM              FORMAT CURRENT LRECL             05470000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            05480000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            05490000
         LA    R7,RECLNFLD             ADDRESS BLOCK SIZE               05500000
         BAL   R14,CONVERT             CONVERT IT TO BINARY             05510000
         STH   R1,DS1LRECL             STORE IT IN DSCB                 05520000
         BAL   R14,FMTNUM              FORMAT CURRENT LRECL             05530000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            05540000
NORECL   DS    0H                                                    01 05550001
*                                                                    01 05560001
*********************************************************************** 05570000
*                                                                     * 05580000
*       UPDATE THE DSORG IF ENTERED                                   * 05590000
*                                                                     * 05600000
*********************************************************************** 05610000
         CH    R15,DSORG               IS THERE A DSORG ENTERED ?       05620000
         BZ    NODSORG                  NO, CHECK NEXT FIELD            05630000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                05640000
         MVC   MSG(5),=CL8'DSORG   '   SET UP MESSAGE                01 05650001
         LA    R10,MSG+6               INIT LINE POINTER                05660000
         BAL   R14,FMTDSO              FORMAT CURRENT DSORG             05670000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            05680000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            05690000
         LH    R1,DSORGKEY             GET INDEX                        05700000
         SLL   R1,2                    MAKE INDEX INTO BRANCH TABLE     05710000
         B     *(R1)                   GO TO SET DSORG ENTERED          05720000
         B     DSORGIS                 SET IN DSORG IS                  05730000
         B     DSORGISU                SET IN DSORG ISU                 05740000
         B     DSORGPS                 SET IN DSORG PS                  05750000
         B     DSORGPSU                SET IN DSORG PSU                 05760000
         B     DSORGDA                 SET IN DSORG DA                  05770000
         B     DSORGDAU                SET IN DSORG DAU                 05780000
         B     DSORGPO                 SET IN DSORG PO                  05790000
         B     DSORGPOU                SET IN DSORG POU                 05800000
         B     DSORG0                  SET IN DSORG ZEROING             05810000
DSORGISU DS    0H                                                    01 05820001
         OI    UPDTFLAG,TOUNMOVE       SET CHANGED TO UNMOVEABLE        05830000
DSORGIS  DS    0H                                                    01 05840001
         TM    DS1DSORG,DCBDSGIS       IS IT ISAM ?                     05850000
         BO    DSORGISP                 YES, GO CHANGE IT               05860000
         OI    UPDTFLAG,TOISAM         SET FROM DSORG XX TO IS          05870000
         TM    DS1DSORG,DCBDSGPO       IS IT PARTITIONED ?              05880000
         BNO   DSORGISP                 NO, DONT FLAG AS CHANGE FROM PO 05890000
         OI    UPDTFLAG,FROMPO         FLAG AS CHANGED FROM PO          05900000
DSORGISP DS    0H                                                    01 05910001
         BAL   R14,CHGDSOU             GO CHECK FOR TO/FROM UNMOVEABLE  05920000
         OI    DS1DSORG,DCBDSGIS       SET IN DSORG IS                  05930000
         B     DSORGNEW                GO FORMAT NEW DSORG              05940000
DSORGPSU DS    0H                                                    01 05950001
         OI    UPDTFLAG,TOUNMOVE       SET CHANGED TO UNMOVEABLE        05960000
DSORGPS  DS    0H                                                    01 05970001
         TM    DS1DSORG,DCBDSGIS       IS IT ISAM ?                     05980000
         BNO   DSORGPSI                 NO, DONT WORRY ABOUT ISAM       05990000
         OI    UPDTFLAG,FROMISAM       SAY CHANGED FROM ISAM            06000000
DSORGPSI DS    0H                                                    01 06010001
         TM    DS1DSORG,DCBDSGPO       IS IT PARTITIONED ?              06020000
         BNO   DSORGPSP                 NO, DONT WORRY ABOUT PO         06030000
         OI    UPDTFLAG,FROMPO         SAY CHANGED FROM PARTITIONED     06040000
DSORGPSP DS    0H                                                    01 06050001
         BAL   R14,CHGDSOU             GO CHECK FOR TO/FROM UNMOVEABLE  06060000
         OI    DS1DSORG,DCBDSGPS       SET IN DSORG PS                  06070000
         B     DSORGNEW                GO FORMAT NEW DSORG              06080000
DSORGDAU DS    0H                                                    01 06090001
         OI    UPDTFLAG,TOUNMOVE       SET CHANGED TO UNMOVEABLE        06100000
DSORGDA  DS    0H                                                    01 06110001
         TM    DS1DSORG,DCBDSGIS       IS IT ISAM ?                     06120000
         BNO   DSORGDAI                 NO, DONT WORRY ABOUT ISAM       06130000
         OI    UPDTFLAG,FROMISAM       SAY CHANGED FROM ISAM            06140000
DSORGDAI DS    0H                                                    01 06150001
         TM    DS1DSORG,DCBDSGPO       IS IT PARTITIONED ?              06160000
         BNO   DSORGDAP                 NO, DONT WORRY ABOUT PO         06170000
         OI    UPDTFLAG,FROMPO         SAY CHANGED FROM PARTITIONED     06180000
DSORGDAP DS    0H                                                    01 06190001
         BAL   R14,CHGDSOU             GO CHECK FOR TO/FROM UNMOVEABLE  06200000
         OI    DS1DSORG,DCBDSGDA       SET IN DSORG DA                  06210000
         B     DSORGNEW                GO FORMAT NEW DSORG              06220000
DSORGPOU DS    0H                                                    01 06230001
         OI    UPDTFLAG,TOUNMOVE       SET CHANGED TO UNMOVEABLE        06240000
DSORGPO  DS    0H                                                    01 06250001
         TM    DS1DSORG,DCBDSGPO       IS IT PARTITIONED ?              06260000
         BO    DSORGPOI                 YES, GO CHANGE IT               06270000
         OI    UPDTFLAG,TOPO           SAY CHANGED TO PARTITIONED       06280000
         TM    DS1DSORG,DCBDSGIS       IS IT ISAM ?                     06290000
         BNO   DSORGPOI                 NO, DONT WORRY ABOUT ISAM       06300000
         OI    UPDTFLAG,FROMISAM       SAY CHANGED FROM ISAM            06310000
DSORGPOI DS    0H                                                    01 06320001
         BAL   R14,CHGDSOU             GO CHECK FOR TO/FROM UNMOVEABLE  06330000
         OI    DS1DSORG,DCBDSGPO       SET IN DSORG PO                  06340000
         B     DSORGNEW                GO FORMAT NEW DSORG              06350000
DSORG0   DS    0H                                                    01 06360001
         TM    DS1DSORG,DCBDSGU        IS IT UNMOVEABLE ?               06370000
         BNO   DSORG0U                  NO, DONT WORRY ABOUT UNMOVE     06380000
         OI    UPDTFLAG,FRUNMOVE       SAY CHANGED FROM UNMOVEABLE      06390000
DSORG0U  DS    0H                                                    01 06400001
         TM    DS1DSORG,DCBDSGIS       IS IT ISAM ?                     06410000
         BNO   DSORG0I                  NO, DONT WORRY ABOUT ISAM       06420000
         OI    UPDTFLAG,FROMISAM       SAY CHANGED FROM ISAM            06430000
DSORG0I  DS    0H                                                    01 06440001
         TM    DS1DSORG,DCBDSGPO       IS IT PARTITIONED ?              06450000
         BNO   DSORG0P                  NO, DONT WORRY ABOUT PO         06460000
         OI    UPDTFLAG,FROMPO         SAY CHANGED FROM PARTITIONED     06470000
DSORG0P  DS    0H                                                    01 06480001
         MVI   DS1DSORG,0              MAKE DSORG ZERO                  06490000
DSORGNEW DS    0H                                                    01 06500001
         BAL   R14,FMTDSO              FORMAT CURRENT DSORG             06510000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            06520000
NODSORG  DS    0H                                                    01 06530001
*                                                                    01 06540001
*********************************************************************** 06550000
*                                                                     * 06560000
*       UPDATE THE TYPE OF ALLOCATION FLAGS                           * 06570000
*                                                                     * 06580000
*********************************************************************** 06590000
         CH    R15,ALLOC               IS THERE A ALLOCATION CHANGE ?   06600000
         BNL   NOALCFL                  NO, CHECK NEXT FIELD            06610000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                06620000
         MVC   MSG(10),=C'ALLOCATION'  SET UP MESSAGE                   06630000
         LA    R10,MSG+11              INIT LINE POINTER                06640000
         BAL   R14,FMTALC              FORMAT CURRENT ALLOCATION FLAGS  06650000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            06660000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            06670000
         LH    R1,ALOCTYPE             GET FIRST SUBFIELD               06680000
         SLL   R1,2                    MAKE INDEX                       06690000
         B     *+4(R1)                 TAKE OPTION ENETERD              06700000
         B     ALOCNXT1                FIRST SUBFIELD NOT USED          06710000
         B     ALOCCYL                 ALLOC BY CYLINDER                06720000
         B     ALOCTRK                 ALLOC BY TRACK                   06730000
         B     ALOCBLK                 ALLOC BY AVERAGE BLOCK SIZE      06740000
         B     ALOCABS                 ALLOC BY ABSOLUTE TRACK ADDRESS  06750000
*                                                                    01 06760001
ALOCCYL  DS    0H                                                    01 06770001
         NI    DS1SCALO,255-JFCBSPAC   RESET SPACE ALLOCATION TECHNIQUE 06780000
         OI    DS1SCALO,JFCBCYL        SET IN CYLINDER ALLOC            06790000
         B     ALOCNXT1                GO PROCESS NEXT SUBFIELD         06800000
*                                                                    01 06810001
ALOCTRK  DS    0H                                                    01 06820001
         NI    DS1SCALO,255-JFCBSPAC   RESET SPACE ALLOCATION TECHNIQUE 06830000
         OI    DS1SCALO,JFCBTRK        SET IN TRACK ALLOC               06840000
         B     ALOCNXT1                GO PROCESS NEXT SUBFIELD         06850000
*                                                                    01 06860001
ALOCBLK  DS    0H                                                    01 06870001
         NI    DS1SCALO,255-JFCBSPAC   RESET SPACE ALLOCATION TECHNIQUE 06880000
         OI    DS1SCALO,JFCBAVR        SET IN AVERAGE BLOCK ALLOC       06890000
         B     ALOCNXT1                GO PROCESS NEXT SUBFIELD         06900000
*                                                                    01 06910001
ALOCABS  DS    0H                                                    01 06920001
         MVI   DS1SCALO,JFCBABS        SET IN ABSOLUTE TRACK ALLOC      06930000
         B     ALOCEND                 GO PROCESS NEXT SUBFIELD         06940000
*                                                                    01 06950001
ALOCNXT1 DS    0H                                                    01 06960001
         LH    R1,ALOCSPC              GET SECOND SUBFIELD              06970000
         SLL   R1,2                    MAKE INDEX                       06980000
         B     *+4(R1)                 TAKE OPTION ENETERD              06990000
         B     ALOCNXT2                SECOND SUBFIELD NOT USED         07000000
         B     ALOCCNTG                ALLOC CONTIG                     07010000
         B     ALOCMXIG                ALLOC MXIG                       07020000
         B     ALOCALX                 ALLOC ALX                        07030000
         B     ALOCNCMA                RESET CONTIG MXIG ALX            07040000
*                                                                    01 07050001
ALOCCNTG DS    0H                                                    01 07060001
         NI    DS1SCALO,255-JFCONTIG+JFCMIXG+JFCALX RESET TYPE TECHNIQ  07070000
         OI    DS1SCALO,JFCONTIG       SET IN CONTIG ALLOC              07080000
         B     ALOCNXT2                GO PROCESS NEXT SUBFIELD         07090000
*                                                                    01 07100001
ALOCMXIG DS    0H                                                    01 07110001
         NI    DS1SCALO,255-JFCONTIG+JFCMIXG+JFCALX RESET TYPE TECHNIQ  07120000
         OI    DS1SCALO,JFCMIXG        SET IN MXIG ALLOC                07130000
         B     ALOCNXT2                GO PROCESS NEXT SUBFIELD         07140000
*                                                                    01 07150001
ALOCALX  DS    0H                                                    01 07160001
         NI    DS1SCALO,255-JFCONTIG+JFCMIXG+JFCALX RESET TYPE TECHNIQ  07170000
         OI    DS1SCALO,JFCALX         SET IN ALX ALLOC                 07180000
         B     ALOCNXT2                GO PROCESS NEXT SUBFIELD         07190000
*                                                                    01 07200001
ALOCNCMA DS    0H                                                    01 07210001
         NI    DS1SCALO,255-JFCONTIG+JFCMIXG+JFCALX RESET TYPE TECHNIQ  07220000
         B     ALOCNXT2                GO PROCESS NEXT SUBFIELD         07230000
*                                                                    01 07240001
ALOCNXT2 DS    0H                                                    01 07250001
         LH    R1,ALOCRND              GET THIRD SUBFIELD               07260000
         SLL   R1,2                    MAKE INDEX                       07270000
         B     *+4(R1)                 TAKE OPTION ENETERD              07280000
         B     ALOCEND                 THIRD SUBFIELD NOT USED          07290000
         B     ALOCROND                ALLOC USING ROUND                07300000
         B     ALOCNRND                RESET ROUND OPTION               07310000
*                                                                    01 07320001
ALOCROND DS    0H                                                    01 07330001
         OI    DS1SCALO,JFCROUND       SET IN ROUND                     07340000
         B     ALOCEND                 GO PROCESS NEXT SUBFIELD         07350000
*                                                                    01 07360001
ALOCNRND DS    0H                                                    01 07370001
         NI    DS1SCALO,255-JFCROUND   RESET ROUND                      07380000
         B     ALOCEND                 END OF ALLOCATION TYPE           07390000
*                                                                    01 07400001
ALOCEND  DS    0H                                                    01 07410001
         BAL   R14,FMTALC              FORMAT NEW ALLOCATION FLAGS      07420000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            07430000
NOALCFL  DS    0H                                                    01 07440001
*                                                                    01 07450001
*********************************************************************** 07460000
*                                                                     * 07470000
*       UPDATE THE SECONDARY ALLOCATION IF ENTERED                    * 07480000
*                                                                     * 07490000
*********************************************************************** 07500000
         CH    R15,SECONDRY            IS THERE A SECONDARY ?           07510000
         BNL   NOSEC                    NO, CHECK NEXT FIELD            07520000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                07530000
         MVC   MSG(9),=C'SECONDARY'    SET UP MESSAGE                   07540000
         LA    R10,MSG+10              INIT LINE POINTER                07550000
         SR    R1,R1                   ZERO WORK                        07560000
         ICM   R1,7,DS1SCALO+1         GET SECONDARY                    07570000
         BAL   R14,FMTNUM              FORMAT CURRENT SECONDARY         07580000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            07590000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            07600000
         LA    R7,SECALLOC             ADDRESS SECONDARY ALLOC          07610000
         BAL   R14,CONVERT             CONVERT IT TO BINARY             07620000
         STCM  R1,7,DS1SCALO+1         STORE IT IN DSCB                 07630000
         BAL   R14,FMTNUM              FORMAT CURRENT LRECL             07640000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            07650000
NOSEC    DS    0H                                                    01 07660001
*                                                                    01 07670001
*********************************************************************** 07680000
*                                                                     * 07690000
*       UPDATE THE RETENTION PERIOD IF ENTERED                        * 07700000
*                                                                     * 07710000
*********************************************************************** 07720000
         LH    R15,EXPRETOT            GET OPTION ENTERED               07730000
         SLA   R15,2                   MAKE IT AN INDEX                 07740000
         BZ    NOEXPDT                  IF ZERO NO CHANGE MADE          07750000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                07760000
         MVC   MSG(5),=CL8'EXPDT   '   SET UP MESSAGE                01 07770001
         LA    R10,MSG+6               INIT LINE POINTER                07780000
         SLR   R1,R1                   ZERO WORK                        07790000
         IC    R1,DS1EXPDT             GET YEAR                         07800000
         MH    R1,=H'+1000'            MULTIPLY BY 1000                 07810000
         SLR   R0,R0                   ZERO WORK                        07820000
         ICM   R0,3,DS1EXPDT+1         GET DAYS                         07830000
         AR    R1,R0                   ADD DAYS                         07840000
         MVI   EDITCHAR,C'/'           SEPERATOR BETWEEN YEAR AND DAYS  07850000
         BAL   R14,FMTNUM              FORMAT CURRENT EXPDT             07860000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            07870000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            07880000
         B     *(R15)                  TAKE OPTION ENTERED              07890000
         B     CHGEXPDT                CHANGE MADE BY EXPDT             07900000
         B     CHGRETPD                CHANGE MADE BY RETPD             07910000
*                                                                    01 07920001
CHGEXPDT DS    0H                                                    01 07930001
         LA    R2,2-1                  LENGTH OF YEAR                   07940000
         L     R1,DATEFLD              ADDRESS YEAR                     07950000
         BAL   R14,CONVERTA            CONVERT IT                       07960000
         STC   R1,DS1EXPDT             SAVE YEAR                        07970000
         LA    R2,3-1                  LENGTH OF JULIAN DATE            07980000
         L     R1,DATEFLD              GET ADDRESS OF                   07990000
         LA    R1,2(,R1)                JULIAN DAYS                     08000000
         BAL   R14,CONVERTA            CONVERT IT TO BINARY             08010000
         STCM  R1,3,DS1EXPDT+1         SAVE IN DSCB                     08020000
         B     NEWEXPDT                GO PRINT NEW EXPIRATION DATE     08030000
*                                                                    01 08040001
CHGRETPD DS    0H                                                    01 08050001
         TIME  BIN                      GET CURRENT DATE                08060000
         XC    DWORD,DWORD              CLEAR OUT WORK AREA          01 08070001
         ST    R1,DWORD+4               STORE DATE                   01 08080001
         CVB   R1,DWORD                 CONVERT IT TO BINARY         01 08090001
         LR    R15,R1                   FETCH CURRENT DATE              08100000
         SR    R14,R14                  SHIFT TO DOUBLE WORD NUMBER     08110000
         LA    R0,1000                  SET UP FOR DIVIDE TO GET YEAR   08120000
         DR    R14,R0                   GET YEAR AND JULIAN DATE        08130000
         ST    R15,CRYEAR               SAVE CURRENT YEAR               08140000
         ST    R14,DAYTOTAL             SAVE JULIAN DATE                08150000
         LA    R7,DAYSFLD               ADDRESS DAYS TO EXPIRATION      08160000
         BAL   R14,CONVERT              CONVERT TO BINARY               08170000
         LR    R15,R1                   LOAD IN WORK AREA               08180000
         A     R15,DAYTOTAL             ADD TO CURRENT DATE             08190000
         BCTR  R15,0                    DROP BY ONE DAY                 08200000
         SR    R14,R14                   FOR DIVISION                   08210000
         LA    R0,365                   DIVIDE TO                       08220000
         DR    R14,R0                    FIND OUT IF OVERFLOW           08230000
         A     R15,CRYEAR               ADD CURRENT YEAR                08240000
         CH    R15,=H'+99'              IS IT BEYOND YEAR 98 ?          08250000
         BNH   NOT99365                  NO, CONTINUE                   08260000
         LA    R14,364                  ELSE SET IN 99365               08270000
         LA    R15,99                    FOR NEW                        08280000
NOT99365 DS    0H                                                    01 08290001
         LA    R14,1(,R14)              RESTORE JULIAN DAYS             08300000
         STCM  R14,3,DS1EXPDT+1         SAVE JULIAN DAYS IN DSCB        08310000
         STC   R15,DS1EXPDT             STORE IN DSCB                   08320000
NEWEXPDT DS    0H                                                    01 08330001
         SLR   R1,R1                   ZERO WORK                        08340000
         IC    R1,DS1EXPDT             GET YEAR                         08350000
         MH    R1,=H'+1000'            MULTIPLY BY 1000                 08360000
         SLR   R0,R0                   ZERO WORK                        08370000
         ICM   R0,3,DS1EXPDT+1         GET DAYS                         08380000
         AR    R1,R0                   ADD DAYS                         08390000
         BAL   R14,FMTNUM              FORMAT CURRENT EXPDT             08400000
         MVI   EDITCHAR,C','           RESTORE NORMAL EDIT SEPERATOR    08410000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            08420000
NOEXPDT  DS    0H                                                    01 08430001
*                                                                    01 08440001
*********************************************************************** 08450000
*                                                                     * 08460000
*       UPDATE THE LAST REFERENCED DATE IF ENTERED                    * 08470000
*                                                                     * 08480000
*********************************************************************** 08490000
         LH    R15,REFDAT              GET OPTION ENTERED               08500000
         LTR   R15,R15                 IS IT ENTERED ?                  08510000
         BZ    NOREFD                   IF ZERO NO CHANGE MADE          08520000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                08530000
         MVC   MSG(5),=CL8'REFDT   '   SET UP MESSAGE                01 08540001
         LA    R10,MSG+6               INIT LINE POINTER                08550000
         SLR   R1,R1                   ZERO WORK                        08560000
         IC    R1,DS1REFD              GET YEAR                         08570000
         MH    R1,=H'+1000'            MULTIPLY BY 1000                 08580000
         SLR   R0,R0                   ZERO WORK                        08590000
         ICM   R0,3,DS1REFD+1          GET DAYS                         08600000
         AR    R1,R0                   ADD DAYS                         08610000
         MVI   EDITCHAR,C'/'           SEPERATOR BETWEEN YEAR AND DAYS  08620000
         BAL   R14,FMTNUM              FORMAT CURRENT EXPDT             08630000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            08640000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            08650000
         LA    R2,2-1                  LENGTH OF YEAR                   08660000
         L     R1,RDATFLD              ADDRESS YEAR                     08670000
         BAL   R14,CONVERTA            CONVERT IT                       08680000
         STC   R1,DS1REFD              SAVE YEAR                        08690000
         LA    R2,3-1                  LENGTH OF JULIAN DATE            08700000
         L     R1,RDATFLD              GET ADDRESS OF                   08710000
         LA    R1,2(,R1)                JULIAN DAYS                     08720000
         BAL   R14,CONVERTA            CONVERT IT TO BINARY             08730000
         STCM  R1,3,DS1REFD+1          SAVE IN DSCB                     08740000
         SLR   R1,R1                   ZERO WORK                        08750000
         IC    R1,DS1REFD              GET YEAR                         08760000
         MH    R1,=H'+1000'            MULTIPLY BY 1000                 08770000
         SLR   R0,R0                   ZERO WORK                        08780000
         ICM   R0,3,DS1REFD+1          GET DAYS                         08790000
         AR    R1,R0                   ADD DAYS                         08800000
         BAL   R14,FMTNUM              FORMAT CURRENT EXPDT             08810000
         MVI   EDITCHAR,C','           RESTORE NORMAL EDIT SEPERATOR    08820000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            08830000
NOREFD   DS    0H                                                    01 08840001
*                                                                    01 08850001
*********************************************************************** 08860000
*                                                                     * 08870000
*       UPDATE THE CREATION DATE IF ENTERED                           * 08880000
*                                                                     * 08890000
*********************************************************************** 08900000
         LH    R15,CRTDAT              GET OPTION ENTERED               08910000
         LTR   R15,R15                 IS IT ENTERED ?                  08920000
         BZ    NOCREDT                  IF ZERO NO CHANGE MADE          08930000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                08940000
         MVC   MSG(5),=CL8'CRDTE   '   SET UP MESSAGE                01 08950001
         LA    R10,MSG+6               INIT LINE POINTER                08960000
         SLR   R1,R1                   ZERO WORK                        08970000
         IC    R1,DS1CREDT             GET YEAR                         08980000
         MH    R1,=H'+1000'            MULTIPLY BY 1000                 08990000
         SLR   R0,R0                   ZERO WORK                        09000000
         ICM   R0,3,DS1CREDT+1         GET DAYS                         09010000
         AR    R1,R0                   ADD DAYS                         09020000
         MVI   EDITCHAR,C'/'           SEPERATOR BETWEEN YEAR AND DAYS  09030000
         BAL   R14,FMTNUM              FORMAT CURRENT EXPDT             09040000
         MVC   0(3,R10),=C'-->'        SET IN CHANGE LITERAL            09050000
         LA    R10,4(,R10)             UP POINTER IN MESSAGE            09060000
         LA    R2,2-1                  LENGTH OF YEAR                   09070000
         L     R1,CDATFLD              ADDRESS YEAR                     09080000
         BAL   R14,CONVERTA            CONVERT IT                       09090000
         STC   R1,DS1CREDT             SAVE YEAR                        09100000
         LA    R2,3-1                  LENGTH OF JULIAN DATE            09110000
         L     R1,CDATFLD              GET ADDRESS OF                   09120000
         LA    R1,2(,R1)                JULIAN DAYS                     09130000
         BAL   R14,CONVERTA            CONVERT IT TO BINARY             09140000
         STCM  R1,3,DS1CREDT+1         SAVE IN DSCB                     09150000
         SLR   R1,R1                   ZERO WORK                        09160000
         IC    R1,DS1CREDT             GET YEAR                         09170000
         MH    R1,=H'+1000'            MULTIPLY BY 1000                 09180000
         SLR   R0,R0                   ZERO WORK                        09190000
         ICM   R0,3,DS1CREDT+1         GET DAYS                         09200000
         AR    R1,R0                   ADD DAYS                         09210000
         BAL   R14,FMTNUM              FORMAT CURRENT EXPDT             09220000
         MVI   EDITCHAR,C','           RESTORE NORMAL EDIT SEPERATOR    09230000
         BAL   R14,PUTMSG              PRINT CHANGED MESSAGE            09240000
NOCREDT  DS    0H                                                    01 09250001
*                                                                    01 09260001
*********************************************************************** 09270000
*                                                                     * 09280000
*       UPDATE THE DATA SET NAME IF ENTERED                           * 09290000
*                                                                     * 09300000
*********************************************************************** 09310000
         LH    R15,NEWDSNKW            WAS NEW DSN ENTERED              09320000
         LTR   R15,R15                 IS IT PRESENT ?                  09330000
         BZ    CHKDSNND                 NO, SKIP PROCESSING             09340000
         L     R15,NEWDSN              GET DATA SET NAME ADDRESS        09350000
         LH    R14,NEWDSN+4            GET DSN LENGTH                   09360000
         BCTR  R14,0                   MAKE MACHINE LENGTH              09370000
         MVI   NDSN,C' '               CLEAR OUT HOLD DSN               09380000
         MVC   NDSN+1(L'NDSN-1),NDSN    TO BLANKS                       09390000
         EX    R14,MOVNDSN             MOVE DATA SET NAME FROM CBUF     09400000
         OBTAIN CHKNEWDS               FETCH DSCB                       09410000
         LA    R0,8                    RC NEEDED                        09420000
         CR    R15,R0                  IS DSN NOT ON VTOC ?             09430000
         BE    CHKDSNOK                 YES, CONTINUE                   09440000
         LTR   R15,R15                 DSN FOUND ?                      09450000
         BE    CHKDSNFD                 YES, SAY SO                     09460000
         LA    R1,NWEERMS              ADDRESS ERROR MESSAGE            09470000
         LA    R0,L'NWEERMS            LENGTH OF MESSAGE                09480000
         BAL   R14,PUTERRC             PUT ERROR MESSAGE                09490000
         B     ERRORXIT                GO EXIT . . .                    09500000
CHKDSNFD DS    0H                                                    01 09510001
         LA    R1,NWFERMS              ADDRESS ERROR MESSAGE            09520000
         LA    R0,L'NWFERMS            LENGTH OF MESSAGE                09530000
         BAL   R14,ANYMSG              PUT ERROR MESSAGE                09540000
         B     ERRORXIT                GO EXIT . . .                    09550000
CHKDSNOK DS    0H                                                    01 09560001
         MVC   MSG(7),=C'NEWDSN='      SET UP LITERAL                   09570000
         MVC   MSG+7(44),NDSN          GET DATA SET NAME ADDRESS        09580000
         BAL   R14,PUTMSG              PRINT MESSAGE                    09590000
         MVC   DSN,NDSN                POST CHANGE                      09600000
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                09610000
CHKDSNND DS    0H                                                    01 09620001
*                                                                    01 09630001
*********************************************************************** 09640000
*                                                                     * 09650000
*       VALIDATE AND WARN IF NECESSARY                                * 09660000
*                                                                     * 09670000
*********************************************************************** 09680000
         SLR   R6,R6                   ZERO                             09690000
         SLR   R7,R7                    WORK                            09700000
         SLR   R5,R5                     REGISTERS                      09710000
         ICM   R7,3,DS1BLKL            GET BLKSIZE                      09720000
         ICM   R5,3,DS1LRECL           GET LRECL                        09730000
         TM    DS1RECFM,DCBRECU        RECFM = U ?                      09740000
         BNO   VLDRECF                  NO, CHECK FOR RECFM F           09750000
         LTR   R5,R5                   IS LRECL ZERO ?                  09760000
         BZ    VLDKEYL                  YES, GO TEST KEYLEN             09770000
         LA    R1,ERR01MS              ADDRESS OF MESSAGE               09780000
         LA    R0,L'ERR01MS            LENGTH OF MESSAGE                09790000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             09800000
         B     VLDKEYL                 GO VALIDATE KEYLEN               09810000
VLDRECF  DS    0H                                                    01 09820001
         TM    DS1RECFM,DCBRECF        RECFM FIXED ?                    09830000
         BNO   VLDRECV                  GO VALIDATE RECFM V             09840000
         LTR   R5,R5                   IS LRECL = ZERO ?                09850000
         BNZ   VLDRECF1                 YES, SEND MESSAGE               09860000
         LA    R1,ERR02MS              ADDRESS OF MESSAGE               09870000
         LA    R0,L'ERR02MS            LENGTH OF MESSAGE                09880000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             09890000
VLDRECF1 DS    0H                                                    01 09900001
         LTR   R7,R7                   IS BLKSIZE ZERO ?                09910000
         BNZ   VLDRECF2                 YES, SEND MESSAGE               09920000
         LA    R1,ERR03MS              ADDRESS OF MESSAGE               09930000
         LA    R0,L'ERR03MS            LENGTH OF MESSAGE                09940000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             09950000
VLDRECF2 DS    0H                                                    01 09960001
         TM    DS1RECFM,DCBRECBR       RECFM F B ?                      09970000
         BO    VLDRECFB                 YES, GO VALIDATE RECFM FB       09980000
         CR    R7,R5                   IS LRECL EQUAL BLKSIZE ?         09990000
         BE    VLDKEYL                  YES, GO TEST KEYLEN             10000000
         LA    R1,ERR04MS              ADDRESS OF MESSAGE               10010000
         LA    R0,L'ERR04MS            LENGTH OF MESSAGE                10020000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10030000
         B     VLDKEYL                 GO VALIDATE KEYLEN               10040000
VLDRECFB DS    0H                                                    01 10050001
         CR    R7,R5                   IS BLKSIZE GREATER LRECL ?       10060000
         BNL   VLDRECF3                 NO, GO TEST BLKSIZE/LRECL       10070000
         LA    R1,ERR05MS              ADDRESS OF MESSAGE               10080000
         LA    R0,L'ERR05MS            LENGTH OF MESSAGE                10090000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10100000
VLDRECF3 DS    0H                                                    01 10110001
         LTR   R5,R5                   IS LRECL ZERO ?                  10120000
         BZ    VLDKEYL                  YES, MESSAGE ALREADY OUT        10130000
         LTR   R7,R7                   IS BLKSIZE ZERO ?                10140000
         BZ    VLDKEYL                  YES, MESSAGE ALREADY OUT        10150000
         DR    R6,R5                   IS BLKSIZE DIVISABLE BY LRECL    10160000
         LTR   R6,R6                   IS THERE A REMAINDER ?           10170000
         BZ    VLDKEYL                  NO, GO BALIDATE KEYLEN          10180000
         LA    R1,ERR06MS              ADDRESS OF MESSAGE               10190000
         LA    R0,L'ERR06MS            LENGTH OF MESSAGE                10200000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10210000
         B     VLDKEYL                 GO VALIDATE KEYLEN               10220000
VLDRECV  DS    0H                                                    01 10230001
         TM    DS1RECFM,DCBRECV        IS THIS RECFM V ?                10240000
         BO    VLDRECV1                 YES, GO VALIDATE RECFM V        10250000
         LA    R1,ERR07MS              ADDRESS OF MESSAGE               10260000
         LA    R0,L'ERR07MS            LENGTH OF MESSAGE                10270000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10280000
         B     VLDKEYL                 GO VALIDATE KEYLEN               10290000
VLDRECV1 DS    0H                                                    01 10300001
         LTR   R7,R7                   IS BLKSIZE ZERO ?                10310000
         BNZ   VLDRECV2                 NO, SKIP MESSAGE             01 10320001
         LA    R1,ERR08MS              ADDRESS OF MESSAGE               10330000
         LA    R0,L'ERR08MS            LENGTH OF MESSAGE                10340000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10350000
VLDRECV2 DS    0H                                                    01 10360001
         TM    DS1RECFM,DCBRECBR       IS RECFM VB ?                    10370000
         BO    VLDRECVB                 YES, GO VALIDATE RECFM VB    01 10380001
         LTR   R5,R5                   IS LRECL ZERO ?                  10390000
         BZ    VLDKEYL                  YES, GO VALIDATE KEYLEN         10400000
         LA    R1,ERR09MS              ADDRESS OF MESSAGE               10410000
         LA    R0,L'ERR09MS            LENGTH OF MESSAGE                10420000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10430000
         B     VLDKEYL                 GO VALIDATE KEYLEN               10440000
VLDRECVB DS    0H                                                    01 10450001
         LTR   R5,R5                   IS LRECL ZERO ?                  10460000
         BNZ   VLDRECV3                 YES, SEND MESSAGE               10470000
         LA    R1,ERR10MS              ADDRESS OF MESSAGE               10480000
         LA    R0,L'ERR10MS            LENGTH OF MESSAGE                10490000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10500000
         B     VLDKEYL                 GO VALIDATE KEYLEN               10510000
VLDRECV3 DS    0H                                                    01 10520001
         TM    DS1RECFM,DCBRECSB       IS THIS VBS RECFM ?              10530000
         BO    VLDKEYL                  YES, GO VALIDATE KEYLEN         10540000
         LA    R5,3(,R5)               GET LRECL + 3                    10550000
         CR    R7,R5                   IS BLKSIZE AT LEAST 4 > LRECL    10560000
         BH    VLDKEYL                  YES, GO VALIDATE KEYLEN         10570000
         LA    R1,ERR11MS              ADDRESS OF MESSAGE               10580000
         LA    R0,L'ERR11MS            LENGTH OF MESSAGE                10590000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10600000
         B     VLDKEYL                 GO VALIDATE KEYLEN               10610000
VLDKEYL  DS    0H                                                    01 10620001
         SLR   R6,R6                   ZERO                             10630000
         SLR   R7,R7                    WORK                            10640000
         SLR   R5,R5                     REGISTERS                      10650000
         ICM   R6,3,DS1RKP             GET RKP                          10660000
         IC    R7,DS1KEYL              GET KEYLN                        10670000
         ICM   R5,3,DS1LRECL           GET LRECL                        10680000
         AR    R6,R7                   ADD RKP TO KEYLEN                10690000
         CR    R6,R5                   DOES KEY EXTEND BEYOND LRECL ?   10700000
         BNH   VLDDSORG                 NO, NEXT TEST                   10710000
         LA    R1,ERR12MS              ADDRESS OF MESSAGE               10720000
         LA    R0,L'ERR12MS            LENGTH OF MESSAGE                10730000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10740000
VLDDSORG DS    0H                                                    01 10750001
         TM    DS1DSORG,DCBDSGIS+DCBDSGPO+DCBDSGPS+DCBDSGDA             10760000
         BNZ   VLDFRIS                  IF A VALID DSORG CONTINUE       10770000
         LA    R1,ERR19MS              ADDRESS OF MESSAGE               10780000
         LA    R0,L'ERR19MS            LENGTH OF MESSAGE                10790000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10800000
VLDFRIS  DS    0H                                                    01 10810001
         TM    UPDTFLAG,FROMISAM       IS DSORG CHANGED FROM ISAM ?     10820000
         BNO   VLDTTOIS                 NO, GO CHECK TO IS CHANGE       10830000
         LA    R1,ERR13MS              ADDRESS OF MESSAGE               10840000
         LA    R0,L'ERR13MS            LENGTH OF MESSAGE                10850000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10860000
VLDTTOIS DS    0H                                                    01 10870001
         TM    UPDTFLAG,TOISAM         IS DSORG CHANGED TO ISAM ?       10880000
         BNO   VLDFRPO                  NO, GO CHECK FROM PO CHANGE     10890000
         LA    R1,ERR14MS              ADDRESS OF MESSAGE               10900000
         LA    R0,L'ERR14MS            LENGTH OF MESSAGE                10910000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10920000
VLDFRPO  DS    0H                                                    01 10930001
         TM    UPDTFLAG,FROMPO         IS DSORG CHANGED FROM PO ?       10940000
         BNO   VLDTOPO                  NO, GO CHECK TO PO CHANGE       10950000
         LA    R1,ERR15MS              ADDRESS OF MESSAGE               10960000
         LA    R0,L'ERR15MS            LENGTH OF MESSAGE                10970000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             10980000
VLDTOPO  DS    0H                                                    01 10990001
         TM    UPDTFLAG,TOPO           IS DSORG CHANGED TO PO ?         11000000
         BNO   VLDDSU                   NO, GO CHECK UNMOVEABLE         11010000
         LA    R1,ERR16MS              ADDRESS OF MESSAGE               11020000
         LA    R0,L'ERR16MS            LENGTH OF MESSAGE                11030000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             11040000
VLDDSU   DS    0H                                                    01 11050001
         TM    UPDTFLAG,TOUNMOVE+FRUNMOVE IS IT STILL UNMOVEABLE ?      11060000
         BO    VLDDSEND                 YES, OK                         11070000
         TM    UPDTFLAG,TOUNMOVE       IS IT CHANGED TO UNMOVEABLE ?    11080000
         BZ    VLDDSFRU                 NO, CHECK FOR FROM              11090000
         LA    R1,ERR17MS              ADDRESS OF MESSAGE               11100000
         LA    R0,L'ERR17MS            LENGTH OF MESSAGE                11110000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             11120000
         B     VLDDSEND                END OF DSORG UNMOVE TEST         11130000
VLDDSFRU DS    0H                                                    01 11140001
         TM    UPDTFLAG,FRUNMOVE       IS IT CHANGED FROM UNMOVEABLE ?  11150000
         BZ    VLDDSEND                 NO, END OF DSORG UNMOVE TEST    11160000
         LA    R1,ERR18MS              ADDRESS OF MESSAGE               11170000
         LA    R0,L'ERR18MS            LENGTH OF MESSAGE                11180000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             11190000
VLDDSEND DS    0H                                                    01 11200001
         TM    DS1SCALO,JFCBSPAC       ALOC BY TRK, CYL, AVG BLK ?      11210000
         BNZ   VLDALCND                 YES, OK                         11220000
         TM    DS1SCALO,255-JFCBSPAC   MXIG ALX ROUND CONTIG ?          11230000
         BZ    VLDABSEC                 NO, OK                          11240000
         LA    R1,ERR20MS              ADDRESS OF MESSAGE               11250000
         LA    R0,L'ERR20MS            LENGTH OF MESSAGE                11260000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             11270000
VLDABSEC DS    0H                                                    01 11280001
         OC    DS1SCALO+1(3),DS1SCALO+1 IS THERE A SECONDARY ?          11290000
         BE    VLDALCND                  NO, OK                         11300000
         LA    R1,ERR21MS              ADDRESS OF MESSAGE               11310000
         LA    R0,L'ERR21MS            LENGTH OF MESSAGE                11320000
         BAL   R14,WARNMSG             SEND WARNING MESSAGE             11330000
VLDALCND DS    0H                                                    01 11340001
         ICM   R15,3,DIRF              DIRF?                         01 11350001
         BZ    VLDDRFND                 NO, NO DIRF OPTION           01 11360001
         TM    UPDTFLAG,FMT4UPDT       FORMAT4.DSCB ENTERED          06 11370006
         BNO   F4MISERR                DIRF AND NO DSN=FORMAT4.DSCB  06 11380006
         LA    R1,=CL8'DIRF    '       ADDRESS OF MESSAGE            01 11390001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11400001
VLDDRFND DS    0H                                                    01 11410001
         ICM   R15,3,DOSOFF            SET DOS FLAG OFF              07 11420007
         BZ    VLDDOSND                 NO, NO DOS OPTION            07 11430007
         TM    UPDTFLAG,FMT4UPDT       FORMAT4.DSCB ENTERED          07 11440007
         BNO   F4MISER1                DOSOFF & NO DSN=FORMAT4.DSCB  07 11450007
         LA    R1,=CL8'DOS OFF '       ADDRESS OF MESSAGE            07 11460007
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          07 11470007
VLDDOSND DS    0H                                                    07 11480007
         B     DSCBWRT                 WRITE DSCB                       11490000
F4MISERR DS    0H                                                    06 11500006
         LA    R1,NF4ERMS              ADDRESS ERROR MESSAGE         06 11510006
         LA    R0,L'NF4ERMS            LENGTH OF MESSAGE             06 11520006
         BAL   R14,ANYMSG              PUT ERROR MESSAGE             06 11530006
         B     ERRORXIT                GO EXIT . . .                 06 11540006
F4MISER1 DS    0H                                                    07 11550007
         LA    R1,NF4ERMS1             ADDRESS ERROR MESSAGE         07 11560007
         LA    R0,L'NF4ERMS1           LENGTH OF MESSAGE             07 11570007
         BAL   R14,ANYMSG              PUT ERROR MESSAGE             07 11580007
         B     ERRORXIT                GO EXIT . . .                 07 11590007
*                                                                    01 11600001
*********************************************************************** 11610000
*                                                                     * 11620000
*       UPDATE THE VTOC DSCB IF ANY CHANGES                           * 11630000
*                                                                     * 11640000
*********************************************************************** 11650000
DOFMT4   DS    0H                                                    01 11660001
         LA    R3,DSCB                 ADDRESS DSCB                  01 11670001
         USING DS4IDFMT,R3             ADDRESSABILITY TO FMT 4 DSCB     11680000
         ICM   R0,3,ZAPOPTS            ANY PASSWORD UPDATE OPTIONS?  01 11690001
         BZ    FMT4NPWD                 NO, NO PASSWORD OPTION       01 11700001
         LA    R1,=CL8'PASSWORD'       ADDRESS OF MESSAGE            01 11710001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11720001
FMT4NPWD DS    0H                                                    01 11730001
         ICM   R0,3,LASTVOL            ANY LAST VOLUME OPTIONS?      01 11740001
         BZ    FMT4NLVL                 NO, NO LAST VOLUME           01 11750001
         LA    R1,=CL8'LASTVOL '       ADDRESS OF MESSAGE            01 11760001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11770001
FMT4NLVL DS    0H                                                    01 11780001
         ICM   R0,3,DSUPDATE           ANY CHANGE INDICATOR          01 11790001
         BZ    FMT4NCI                  NO, NO CHANGE INDICATOR      01 11800001
         LA    R1,=CL8'UPDATED '       ADDRESS OF MESSAGE            01 11810001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11820001
FMT4NCI  DS    0H                                                    01 11830001
         ICM   R0,3,OPTCD              IS OPTION CODE ENTERED?       01 11840001
         BNL   FMT4NOP                  NO, NO OPTION CODE           01 11850001
         LA    R1,=CL8'OPTCD   '       ADDRESS OF MESSAGE            01 11860001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11870001
FMT4NOP  DS    0H                                                    01 11880001
         ICM   R0,3,RECFM              IS RECFM ENTERED?             01 11890001
         BNL   FMT4NRFM                 NO, NO RECFM                 01 11900001
         LA    R1,=CL8'RECFM   '       ADDRESS OF MESSAGE            01 11910001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11920001
FMT4NRFM DS    0H                                                    01 11930001
         ICM   R0,3,KEYLEN             IS THERE A KEY LENGTH?        01 11940001
         BNL   FNT4NKL                  NO, NO KEY LENGTH            01 11950001
         LA    R1,=CL8'KEYLN   '       ADDRESS OF MESSAGE            01 11960001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 11970001
FNT4NKL  DS    0H                                                    01 11980001
         ICM   R0,3,RKP                IS THERE A RKP?               01 11990001
         BNL   FMT4NRKP                 NO, NO RKP                   01 12000001
         LA    R1,=CL8'RKP     '       ADDRESS OF MESSAGE            01 12010001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12020001
FMT4NRKP DS    0H                                                    01 12030001
         ICM   R0,3,BLKSIZE            IS THERE A BLKSIZE ENTERED?   01 12040001
         BNL   FMT4NBLK                 NO, NO BLKSIZE               01 12050001
         LA    R1,=CL8'BLKSIZE '       ADDRESS OF MESSAGE            01 12060001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12070001
FMT4NBLK DS    0H                                                    01 12080001
         ICM   R0,3,LRECL              IS THERE A LRECL ENTERED?     01 12090001
         BNL   FNT4NLR                  NO, NO LRECL                 01 12100001
         LA    R1,=CL8'LRECL   '       ADDRESS OF MESSAGE            01 12110001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12120001
FNT4NLR  DS    0H                                                    01 12130001
         ICM   R0,3,DSORG              IS THERE A DSORG ENTERED?     01 12140001
         BZ    FMT4NDS                  NO, NO DSORG                 01 12150001
         LA    R1,=CL8'DSORG   '       ADDRESS OF MESSAGE            01 12160001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12170001
FMT4NDS  DS    0H                                                    01 12180001
         ICM   R0,3,ALLOC              IS THERE A ALLOCATION CHANGE? 01 12190001
         BNL   FMT4NALC                 NO, NO ALLOCATION            01 12200001
         LA    R1,=CL8'ALLOCATE'       ADDRESS OF MESSAGE            01 12210001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12220001
FMT4NALC DS    0H                                                    01 12230001
         ICM   R0,3,SECONDRY           IS THERE A SECONDARY?         01 12240001
         BNL   FMT4NSEC                 NO, NO SECONDARY             01 12250001
         LA    R1,=CL8'SECONDAR'       ADDRESS OF MESSAGE            01 12260001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12270001
FMT4NSEC DS    0H                                                    01 12280001
         ICM   R0,3,EXPRETOT           GET OPTION ENTERED            01 12290001
         BZ    FMT4NEX                  NO, NO EXPIRE DATE           01 12300001
         LA    R1,=CL8'EXPDT   '       ADDRESS OF MESSAGE            01 12310001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12320001
FMT4NEX  DS    0H                                                    01 12330001
         ICM   R0,3,REFDAT             GET OPTION ENTERED            01 12340001
         BZ    FMT4NREF                 NO, NO REFERENCED DATE       01 12350001
         LA    R1,=CL8'REFDT   '       ADDRESS OF MESSAGE            01 12360001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12370001
FMT4NREF DS    0H                                                    01 12380001
         ICM   R0,3,CRTDAT             GET OPTION ENTERED            01 12390001
         BZ    FMT4NCRE                 NO, NO CREATE DATE           01 12400001
         LA    R1,=CL8'CRDTE   '       ADDRESS OF MESSAGE            01 12410001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12420001
FMT4NCRE DS    0H                                                    01 12430001
         ICM   R0,3,NEWDSNKW           WAS NEW DSN ENTERED           01 12440001
         BZ    FMT4NREN                 NO, NO NEW DSN               01 12450001
         LA    R1,=CL8'NEWDSN  '       ADDRESS OF MESSAGE            01 12460001
         BAL   R14,FMT4WARN            SEND WARNING MESSAGE          01 12470001
FMT4NREN DS    0H                                                    01 12480001
*********************************************************************** 12490000
*                                                                     * 12500000
*       UPDATE THE DIRF BIT IN THE FORMAT 4 DSCB IF NECESSARY         * 12510000
*                                                                     * 12520000
*********************************************************************** 12530000
         LH    R15,DIRF                WAS DIRF UPDATE REQUESTED?    02 12540002
         LTR   R15,R15                 IS IT PRESENT ?                  12550000
         BZ    DSCBDOSQ                 NO, SKIP PROCESSING          07 12560007
         LA    R1,=C'DIRF BIT SET'     WARNING MESSAGE                  12570000
         LA    R0,12                   LENGTH                           12580000
         BAL   R14,WARNMSG             PRINT MESSAGE                    12590000
         OI    DS4VTOCI,DS4DIRF        SET DIRF BIT                     12600007
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED                12610000
         OI    UPDTFLG2,UPDTDIRF       SET DIRF UPDATED IN FMT4 DSCB 05 12620005
DSCBDOSQ DS    0H                                                    07 12630007
         ICM   R15,3,DOSOFF            WAS DOS OFF REQUESTED?        07 12640007
         BZ    DSCBWRT                  NO, SKIP PROCESSING          07 12650007
         LA    R1,=C'DOS FLAG OFF'     WARNING MESSAGE               07 12660007
         LA    R0,12                   LENGTH                        07 12670007
         BAL   R14,WARNMSG             PRINT MESSAGE                 07 12680007
         NI    DS4VTOCI,255-DS4DOCVT   RESET DOC CONVERTED BIT       07 12690007
         OI    UPDTFLAG,UPDATE         SET FIELD UPDATED             07 12700007
         OI    UPDTFLG2,UPDTDOS        SET DOS UPDATED IN FMT4 DSCB  07 12710007
         USING DS1FMTID,R3             ADDRESSABILITY TO FMT 1 DSCB     12720000
*                                                                    01 12730001
*********************************************************************** 12740000
*                                                                     * 12750000
*       REWRITE THE FORMAT ONE DSCB AFTER UPDATE                      * 12760000
*                                                                     * 12770000
*********************************************************************** 12780000
DSCBWRT  DS    0H                                                    01 12790001
         SR    R2,R2                   CLEAR                         02 12800002
         ICM   R2,3,NOCONF             GET NOCONFIRM SPECIFICATION   02 12810002
         DROP  R4                      DROP PDL                      02 12820002
         IKJRLSA 0(,R4)                RELEASE PARSE WORK AREAS      01 12830001
         TM    UPDTFLAG,UPDATE         ANY FIELDS UPDATED ?             12840000
         BZ    NOUP                     NO, SKIP REWRITE                12850000
         LTR   R2,R2                   NOCONFIRM SPECIFIED?          02 12860002
         BNZ   UPDTVTOC                 YES, SKIP CONFIRMATION       02 12870002
         LA    R2,4                    SET NUMBER OF COMFIRM MESSAGES   12880000
CONFIRM  DS    0H                                                    01 12890001
         BCT   R2,CONFCNT              IF NOT 3 RETRIES CONTINUE        12900000
         B     CONFAIL                 SAY NOT UPDATED                  12910000
CONFCNT  DS    0H                                                    01 12920001
         LA    R1,CONFMSG              ADDRESS MESSAGE                  12930000
         LA    R0,L'CONFMSG            LENGTH IF IT                     12940000
         BAL   R14,ANYMSG              CONFIRM MESSAGE                  12950000
         LA    R14,MYPPL               ADDRESS PPL FOR GETLINE          12960000
         USING PPL,R14                 ADDRESSABILITY TO PPL            12970000
         L     R15,PPLUPT              UPT ADDRESS                   01 12980001
         L     R0,PPLECT               ECT ADDRESS                   01 12990001
         DROP  R14                     DROP ADDRESSABILITY TO PPL    01 13000001
         GETLINE PARM=GETBLOCK,                                        X13010000
               INPUT=(TERM,LOGICAL),                                   X13020000
               TERMGET=(EDIT,WAIT),                                    X13030000
               UPT=(R15),                                            01X13040001
               ECT=(R0),                                             01X13050001
               ECB=GPECB,                                              X13060000
               MF=(E,IOPL)                                              13070000
         LA    R14,GETBLOCK            ADDRESS GETLINE BLOCK            13080000
         USING GTPB,R14                ADDRESSABILITY TO GETLINE BLOCK  13090000
         L     R14,GTPBIBUF            ADDRESS BUFFER                   13100000
         DROP  R14                     GETLINE BLOCK NOT NEEDED ANYMORE 13110000
         LH    R0,0(,R14)              GET LENGTH OF DATA               13120000
         LTR   R0,R0                   LENGTH ZERO ?                    13130000
         BZ    CONFIRM                  YES, NO RESPONSE                13140000
         OI    4(R14),C' '             UPPERCASE IT                     13150000
         CLI   4(R14),C'Y'             IS IT YES ?                      13160000
         BE    UPDTVTOC                 YES, GO UPDATE                  13170000
         CLI   4(R14),C'N'             IS IT NO ?                       13180000
         BNE   CONFIRM                 RETRY  MESSAGE                   13190000
CONFAIL  DS    0H                                                    01 13200001
         LA    R1,FAILUPMS             MESSAGE ADDRESS                  13210000
         LA    R0,L'FAILUPMS           MESSAGE LENGTH                   13220000
         BAL   R14,ANYMSG              PUT MESSAGE                      13230000
NOUP     DS    0H                                                    01 13240001
         LA    R1,NOTUPDMS             MESSAGE ADDRESS                  13250000
         LA    R0,L'NOTUPDMS           MESSAGE LENGTH                   13260000
         BAL   R14,ANYMSG              PUT MESSAGE                      13270000
         L     R13,4(,R13)             RESTORE SAVE AREA ADDRESS        13280000
         RETURN (14,12),RC=8                                            13290000
UPDTVTOC DS    0H                                                    01 13300001
         LA    R1,OPENLST              ADDRESS OPEN PARAMETERS          13310000
         RDJFCB ,MF=(E,(1))            READ JFCB                        13320000
         LA    R2,JFCB                 ADDRESS JBCB                     13330000
         USING JFCBDSCT,R2             ADDRESSABILITY TO JFCB           13340000
         OI    JFCBTSDM,JFCNWRIT       SET DO NOT WRITE BACK JFCB       13350000
         MVC   JFCBDSNM,FMT4           CHANGE DATASET NAME TO FORMAT 4  13360000
         DROP  R2                      DROP ADDRESSABILITY TO JFCB      13370000
         LA    R1,OPENLST              ADDRESS OPEN PARAMETERS          13380000
         OPEN  TYPE=J,MF=(E,(1))       OPEN VTOC                        13390000
         LA    R2,VTOCDCB              ADDRESS DCB                      13400000
         USING IHADCB,R2               ADDRESSABILITY TO DCB            13410000
         TM    DCBOFLGS,DCBOFOPN       OPEN SUCCESSFULL ?               13420000
         DROP  R2                      DROP DCB ADDRESSABILITY          13430000
         BNZ   OPENOK                   YES, CONTINUE                   13440000
         LA    R1,OPENERMS             ADDRESS ERRRT MESSAGE            13450000
         LA    R0,L'OPENERMS           LENGTH OF ERROR MESSAGE          13460000
         BAL   R14,ANYMSG              PUT ERROR MESSAGE                13470000
         B     ERRORXIT                EXIT . . .                       13480000
OPENOK   DS    0H                                                    01 13490001
         MVC   SECTOR,DSCB+96          PICK UP ADDRESS OF FMT1 DSCB     13500000
         EXCP  IOB                     WRITE BACK UPDATED DSCB          13510000
         WAIT  ECB=ECB                 WAIT FOR COMPLETION OF IO        13520000
         TM    ECB,X'7F'               UPDATE OK ?                      13530000
         BO    UPDATOK                  YES, CONTINUE                   13540000
         LA    R1,IOERMS               ADDRESS OF ERROR MESSAGE         13550000
         LA    R0,L'IOERMS             LENGTH OF MESSAGE                13560000
         L     R15,ECB                 GET ECB COMPLETION CODE       04 13570004
         BAL   R14,PUTERRC             PUT ERROR MESSAGE             01 13580001
         B     CLOSVTOC                GO CLOSE VTOC DCB                13590000
UPDATOK  DS    0H                                                    01 13600001
         LA    R1,UPDTMS               ADDRESS OF SUCCESSFUL MESSAGE    13610000
         LA    R0,L'UPDTMS             LENGTH OF MESSAGE                13620000
         BAL   R14,ANYMSG              PUT SUCCESSFUL MESSAGE           13630000
         TM    UPDTFLG2,UPDTDIRF       DIRF UPDATED IN FMT4 DSCB     05 13640005
         BNO   CHK4DOS                 NO, SKIP MESSAGE              07 13650007
         MVC   DIRFMSG+36(8),VOLSER    VOLUME ID IN WTO              05 13660005
DIRFMSG  WTO   'DSCBUPDT DIRF SET ON VOLUME XXXXXXXX'                05 13670005
CHK4DOS  DS    0H                                                    07 13680007
         TM    UPDTFLG2,UPDTDOS        DOS UPDATED IN FMT4 DSCB      07 13690007
         BNO   CLOSVTOC                NO, SKIP MESSAGE              07 13700007
         MVC   DOSMSG+37(8),VOLSER     VOLUME ID IN WTO              07 13710007
DOSMSG   WTO   'DSCBUPDT DOS RESET ON VOLUME XXXXXXXX'               07 13720007
CLOSVTOC DS    0H                                                    01 13730001
         CLOSE VTOCDCB                 CLOSE VTOC                       13740000
         SLR   R15,R15                 SET ZERO RETURN CODE             13750000
         L     R13,4(,R13)             RESTORE SYSTEMS SAVEAREA ADDR    13760000
         RETURN (14,12),RC=(15)        EXIT . . .                       13770000
*                                                                    01 13780001
ERRORXIT DS    0H                                                    01 13790001
         L     R13,4(,R13)             RESTORE SYSTEMS SAVEAREA ADDR    13800000
         RETURN (14,12),RC=12          EXIT . . .                       13810000
*                                                                    01 13820001
*********************************************************************** 13830000
*                                                                     * 13840000
*            S U B R O U T I N E S                                    * 13850000
*                                                                     * 13860000
*********************************************************************** 13870000
CONVERT  DS    0H                                                    01 13880001
         LH    R2,4(,R7)               GET LENGTH OF EBCDIC FIELD       13890000
         BCTR  R2,0                    MAKE MACHINE LENGTH              13900000
         L     R1,0(,R7)               GET ADDRESS OF FIELD             13910000
CONVERTA DS    0H                                                    01 13920001
         EX    R2,PACDEC               CONVERT INTEGER TO PACKED DEC    13930000
         CVB   R1,DWORD                CONVERT INTEGER TO BINARY     01 13940001
         BR    R14                                                      13950000
PACDEC   PACK  DWORD(8),0(1,R1)                                      01 13960001
*                                                                    01 13970001
*                                                                    01 13980001
*                                                                    01 13990001
CHGDSOU  DS    0H                                                    01 14000001
         TM    DS1DSORG,DCBDSGU        IS DATA SET UNMOVEABLE ?         14010000
         BNO   CHGDSOFR                 NO, CHECK FOR CHANGE FROM UNMOV 14020000
         OI    UPDTFLAG,FRUNMOVE       SAY IT WAS UNMOVEABLE            14030000
CHGDSOFR DS    0H                                                    01 14040001
         MVI   DS1DSORG,0              ZERO DSORG                       14050000
         TM    UPDTFLAG,TOUNMOVE       IS IT A CHANGE TO UNMOVEABLE ?   14060000
         BNOR  R14                      NO, EXIT . . .                  14070000
         OI    DS1DSORG,DCBDSGU        SET IN UNMOVEABLE                14080000
         BR    R14                     EXIT . . .                       14090000
*                                                                    01 14100001
*                                                                    01 14110001
*                                                                    01 14120001
FMTPWD   DS    0H                                                    01 14130001
         TM    DS1DSIND,DS1IND40       RACF DEFINED ?                   14140000
         BZ    FMTPWDOP                 NO, NOT DEFINED IN RACF         14150000
         MVC   0(12,R10),=C'RACF DEFINED'                               14160000
         LA    R10,13(,R10)             UP LINE POINTER                 14170000
FMTPWDOP DS    0H                                                    01 14180001
         TM    DS1DSIND,DS1IND10       PASSWORD PROTECTED?           01 14190001
         BZ    FMTPWDO                  NO, IT IS OFF                   14200000
         TM    DS1DSIND,DS1IND04       READ ONLY ?                      14210000
         BO    FMTPWDW                  YES, GO FORMAT MESSAGE          14220000
         MVC   0(15,R10),=C'PSWD READ/WRITE'                            14230000
         LA    R10,16(,R10)            UP LINE POINTER                  14240000
         BR    R14                     EXIT . . .                       14250000
FMTPWDW  DS    0H                                                    01 14260001
         MVC   0(10,R10),=C'PSWD WRITE'                                 14270000
         LA    R10,11(,R10)             UP LINE POINTER                 14280000
         BR    R14                     EXIT . . .                       14290000
FMTPWDO  DS    0H                                                    01 14300001
         MVC   0(13,R10),=C'NOT PSWD PROT'                              14310000
         LA    R10,14(,R10)             UP LINE POINTER                 14320000
         BR    R14                     EXIT . . .                       14330000
*                                                                    01 14340001
*                                                                    01 14350001
*                                                                    01 14360001
FMTLST   DS    0H                                                    01 14370001
         TM    DS1DSIND,DS1IND80       LAST VOLUME INDICATOR ON ?       14380000
         BZ    FMTLSTNO                 NO, NOT LAST VOLUME             14390000
         MVC   0(3,R10),=C'YES'                                         14400000
         LA    R10,4(,R10)             UP LINE POINTER                  14410000
         BR    R14                     EXIT . . .                       14420000
FMTLSTNO DS    0H                                                    01 14430001
         MVC   0(2,R10),=C'NO'                                       01 14440001
         LA    R10,3(,R10)             UP LINE POINTER                  14450000
         BR    R14                     EXIT . . .                       14460000
*                                                                    01 14470001
*                                                                    01 14480001
*                                                                    01 14490001
FMTUPD   DS    0H                                                    01 14500001
         TM    DS1DSIND,DS1IND02       OPENED FOR UPDATE ?              14510000
         BZ    FMTUPDNO                 NO, SAY SO                      14520000
         MVC   0(3,R10),=C'YES'                                         14530000
         LA    R10,4(,R10)             UP LINE POINTER                  14540000
         BR    R14                     EXIT . . .                       14550000
FMTUPDNO DS    0H                                                    01 14560001
         MVC   0(2,R10),=C'NO'                                       01 14570001
         LA    R10,3(,R10)             UP LINE POINTER                  14580000
         BR    R14                     EXIT . . .                       14590000
*                                                                    01 14600001
FMTALC   DS    0H                                                    01 14610001
         CLI   DS1SCALO,JFCBABS        ABSTR ?                          14620000
         BNE   FMTALCC                  NO, IT IS OFF                   14630000
         MVC   0(5,R10),=C'ABSTR'      SET UP ABSTR                     14640000
         LA    R10,6(,R10)             UP LINE POINTER                  14650000
         BR    R14                     EXIT . . .                       14660000
FMTALCC  DS    0H                                                    01 14670001
         TM    DS1SCALO,JFCBCYL        CYL ?                            14680000
         BNO   FMTALCT                  NO, IT ISNT                     14690000
         MVC   0(3,R10),=C'CYL'        SET UP CYL                       14700000
         LA    R10,4(,R10)             UP LINE POINTER                  14710000
         B     FMTALCTP                GO CHECK TYPE                    14720000
FMTALCT  DS    0H                                                    01 14730001
         TM    DS1SCALO,JFCBTRK        TRK ?                            14740000
         BZ    FMTALCB                  NO, IT ISNT                     14750000
         MVC   0(3,R10),=C'TRK'        SET UP CYL                       14760000
         LA    R10,4(,R10)             UP LINE POINTER                  14770000
         B     FMTALCTP                GO CHECK TYPE                    14780000
FMTALCB  DS    0H                                                    01 14790001
         TM    DS1SCALO,JFCBAVR        SVERAGE BLOCK LENGTH ?           14800000
         BZ    FMTALCTP                 NO, IT ISNT                     14810000
         MVC   0(5,R10),=C'BLOCK'      SET UP BLOCK                     14820000
         LA    R10,6(,R10)             UP LINE POINTER                  14830000
FMTALCTP DS    0H                                                    01 14840001
         TM    DS1SCALO,JFCONTIG       CONTIG SPACE ALLOCATED ?         14850000
         BZ    FMTALCM                  NO, IT ISNT                     14860000
         MVC   0(6,R10),=C'CONTIG'     SET UP CONTIG                    14870000
         LA    R10,7(,R10)             UP LINE POINTER                  14880000
         B     FMTALCRD                GO CHECK ROUND                   14890000
FMTALCM  DS    0H                                                    01 14900001
         TM    DS1SCALO,JFCMIXG        MXIG REQUEST ?                   14910000
         BZ    FMTALCA                  NO, IT ISNT                     14920000
         MVC   0(4,R10),=C'MXIG'       SET UP MXIG                      14930000
         LA    R10,5(,R10)             UP LINE POINTER                  14940000
         B     FMTALCRD                CO CHECK ROUND                   14950000
FMTALCA  DS    0H                                                    01 14960001
         TM    DS1SCALO,JFCALX         ALX REQUEST ?                    14970000
         BZ    FMTALCRD                 NO, IT ISNT                     14980000
         MVC   0(3,R10),=C'ALX'        SET UP ALX                       14990000
         LA    R10,4(,R10)             UP LINE POINTER                  15000000
FMTALCRD DS    0H                                                    01 15010001
         TM    DS1SCALO,JFCROUND       ROUND REQUEST ?                  15020000
         BZR   R14                      NO, IT ISNT                     15030000
         MVC   0(5,R10),=C'ROUND'      SET UP BLOCK                     15040000
         LA    R10,6(,R10)             UP LINE POINTER                  15050000
         BR    R14                     EXIT . . .                       15060000
*                                                                    01 15070001
*                                                                    01 15080001
*                                                                    01 15090001
FMTOPC   DS    0H                                                    01 15100001
         CLI   DS1OPTCD,0              IS OPTION CODE ZERO ?            15110000
         BNE   FMTOPCC                  NO, CONTINUE                    15120000
         MVI   0(R10),C'0'             SET UP MESSAGE                   15130000
         LA    R10,2(,R10)             UP POINTER                       15140000
         BR    R14                     EXIT . .                         15150000
FMTOPCC  DS    0H                                                    01 15160001
         TM    DS1OPTCD,DCBOPTC        OPTCODE C ?                      15170000
         BZ    FMTOPCT                  NO, SKIP MESSAGE                15180000
         MVI   0(R10),C'C'             SET UP MESSAGE                   15190000
         LA    R10,1(,R10)             UP POINTER                       15200000
FMTOPCT  DS    0H                                                    01 15210001
         TM    DS1OPTCD,DCBOPTT        OPTCODE T ?                      15220000
         BZ    FMTOPCW                  NO, SKIP MESSAGE                15230000
         MVI   0(R10),C'T'             SET UP MESSAGE                   15240000
         LA    R10,1(,R10)             UP POINTER                       15250000
FMTOPCW  DS    0H                                                    01 15260001
         TM    DS1OPTCD,DCBOPTW        OPTCODE W ?                      15270000
         BZ    FMTOPCQ                  NO, SKIP MESSAGE                15280000
         MVI   0(R10),C'W'             SET UP MESSAGE                   15290000
         LA    R10,1(,R10)             UP POINTER                       15300000
FMTOPCQ  DS    0H                                                    01 15310001
         TM    DS1OPTCD,DCBOPTQ        OPTCODE Q ?                      15320000
         BZ    FMTOPCND                 NO, SKIP MESSAGE                15330000
         MVI   0(R10),C'Q'             SET UP MESSAGE                   15340000
         LA    R10,1(,R10)             UP POINTER                       15350000
FMTOPCND DS    0H                                                    01 15360001
         LA    R10,1(,R10)             ADD 1 FOR SPACING                15370000
         BR    R14                     EXIT . . .                       15380000
*                                                                    01 15390001
*                                                                    01 15400001
*                                                                    01 15410001
FMTRFM   DS    0H                                                    01 15420001
         CLI   DS1RECFM,0              IS RECORD FORMAT ZERO ?          15430000
         BNE   FMTRFM1                  NO, CONTINUE                    15440000
         MVI   0(R10),C'0'             SET UP MESSAGE                   15450000
         LA    R10,2(,R10)             UP POINTER                       15460000
         BR    R14                     EXIT . .                         15470000
FMTRFM1  DS    0H                                                    01 15480001
         TM    DS1RECFM,DCBRECU        RECFM U ?                        15490000
         BO    FMTRFMU                  YES, GO SET UP U                15500000
         TM    DS1RECFM,DCBRECF        RECFM F ?                        15510000
         BZ    FMTRFMV                  NO, SKIP MESSAGE                15520000
         MVI   0(R10),C'F'             SET UP MESSAGE                   15530000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15540000
FMTRFMV  DS    0H                                                    01 15550001
         TM    DS1RECFM,DCBRECV        RECFM V ?                        15560000
         BZ    FMTRFMB                  NO, SKIP MESSAGE                15570000
         MVI   0(R10),C'V'             SET UP MESSAGE                   15580000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15590000
FMTRFMB  DS    0H                                                    01 15600001
         TM    DS1RECFM,DCBRECBR       RECFM B ?                        15610000
         BZ    FMTRFMC                  NO, SKIP MESSAGE                15620000
         MVI   0(R10),C'B'             SET UP MESSAGE                   15630000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15640000
         B     FMTRFMC                 GO FORMAT COMMON RECFM           15650000
FMTRFMU  DS    0H                                                    01 15660001
         MVI   0(R10),C'U'             SET UP MESSAGE                   15670000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15680000
FMTRFMC  DS    0H                                                    01 15690001
         TM    DS1RECFM,DCBRECCA       RECFM A ?                        15700000
         BZ    FMTRFMM                  NO, SKIP MESSAGE                15710000
         MVI   0(R10),C'A'             SET UP MESSAGE                   15720000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15730000
FMTRFMM  DS    0H                                                    01 15740001
         TM    DS1RECFM,DCBRECCM       RECFM M ?                        15750000
         BZ    FMTRFMS                  NO, SKIP MESSAGE                15760000
         MVI   0(R10),C'M'             SET UP MESSAGE                   15770000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15780000
FMTRFMS  DS    0H                                                    01 15790001
         TM    DS1RECFM,DCBRECSB       RECFM S ?                        15800000
         BZ    FMTRFMT                  NO, SKIP MESSAGE                15810000
         MVI   0(R10),C'S'             SET UP MESSAGE                   15820000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15830000
FMTRFMT  DS    0H                                                    01 15840001
         TM    DS1RECFM,DCBRECTO       RECFM T ?                        15850000
         BZ    FMTRFMND                 NO, SKIP MESSAGE                15860000
         MVI   0(R10),C'T'             SET UP MESSAGE                   15870000
         LA    R10,1(,R10)             UP MESSAGE POINTER               15880000
FMTRFMND DS    0H                                                    01 15890001
         LA    R10,1(,R10)             ADD 1 FOR SPACING                15900000
         BR    R14                     EXIT . . .                       15910000
*                                                                    01 15920001
*                                                                    01 15930001
*                                                                    01 15940001
FMTNUM   DS    0H                                                    01 15950001
         CVD   R1,DWORD                GET NUMERIC VALUE             01 15960001
         LA    R1,EDITNUM+L'EDITNUM-1  ADDRESS IF ZERO                  15970000
         MVC   EDITNUM,=X'4020206B202120'                               15980000
         MVC   EDITNUM+3(1),EDITCHAR   SET UP EDIT CHARACTER            15990000
         CLI   EDITCHAR,C'/'           IS THIS A DATE EDIT ?            16000000
         BNE   FMTNUMZ                  NO, ZERO SUPRESS                16010000
         MVI   EDITNUM+1,X'21'         FORCE SIG DIGIT                  16020000
         LA    R1,EDITNUM+1            ADDRESS IF NO SIG DIGIT          16030000
FMTNUMZ  DS    0H                                                    01 16040001
         EDMK  EDITNUM,DWORD+5         EDIT NUMBER                   01 16050001
         LR    R0,R1                   SAVE ADDR OF SIGNIFICANT DIGIT   16060000
         LR    R2,R1                   SAVE ADDR OF SIGNIFICANT DIGIT   16070000
         LA    R1,EDITNUM+L'EDITNUM-1  ADDRESS FOR LEN CALCULATION      16080000
         SR    R1,R0                   GET LENGTH OF NUMBER             16090000
         EX    R1,FMTNUMVC             MOVE NUMBER                      16100000
         LA    R10,2(R1,R10)           UP TO NEXT AVAILABLE PSN IN MSG  16110000
         BR    R14                     EXIT . . .                       16120000
FMTNUMVC MVC   0(,R10),0(R2)           MOVE NUMBER                      16130000
*                                                                    01 16140001
*                                                                    01 16150001
*                                                                    01 16160001
FMTDSO   DS    0H                                                    01 16170001
         CLI   DS1DSORG,0              IS IT ZERO ?                     16180000
         BNE   FMTDSOIS                 NO, NEXT                        16190000
         MVI   0(R10),C'0'             SET IN ZERO                      16200000
         LA    R10,2(,R10)             UP POINTER                       16210000
         BR    R14                     EXIT . .  .                      16220000
FMTDSOIS DS    0H                                                    01 16230001
         TM    DS1DSORG,DCBDSGIS       IS IT ISAM ?                     16240000
         BNO   FMTDSOPS                 NO, NEXT                        16250000
         MVC   0(2,R10),=C'IS'         SET IN IS                        16260000
         LA    R10,2(,R10)             UP POINTER                       16270000
         B     FMTDSOU                 GO TEST FOR UMOVEABLE            16280000
FMTDSOPS DS    0H                                                    01 16290001
         TM    DS1DSORG,DCBDSGPS       IS IT PS ?                       16300000
         BNO   FMTDSODA                 NO, NEXT                        16310000
         MVC   0(2,R10),=C'PS'         SET IN PS                        16320000
         LA    R10,2(,R10)             UP POINTER                       16330000
         B     FMTDSOU                 GO TEST FOR UMOVEABLE            16340000
FMTDSODA DS    0H                                                    01 16350001
         TM    DS1DSORG,DCBDSGDA       IS IT DA ?                       16360000
         BNO   FMTDSOPO                 NO, NEXT                        16370000
         MVC   0(2,R10),=C'DA'         SET IN PS                        16380000
         LA    R10,2(,R10)             UP POINTER                       16390000
         B     FMTDSOU                 GO TEST FOR UMOVEABLE            16400000
FMTDSOPO DS    0H                                                    01 16410001
         TM    DS1DSORG,DCBDSGPO       IS IT PO ?                       16420000
         BNO   FMTDSOU                  NO, NEXT                        16430000
         MVC   0(2,R10),=C'PO'         SET IN PO                        16440000
         LA    R10,2(,R10)             UP POINTER                       16450000
FMTDSOU  DS    0H                                                    01 16460001
         TM    DS1DSORG,DCBDSGU        IS IT U ?                        16470000
         BNO   FMTDSOND                 NO, NEXT                        16480000
         MVI   0(R10),C'U'             SET IN U                      01 16490001
         LA    R10,1(,R10)             UP POINTER                       16500000
FMTDSOND DS    0H                                                    01 16510001
         LA    R10,1(,R10)             UP POINTER                       16520000
         BR    R14                     EXIT . .  .                      16530000
*                                                                    01 16540001
*                                                                    01 16550001
*                                                                    01 16560001
PUTERRC  DS    0H                                                    01 16570001
         ST    R15,DWORD               SAVE RETURN CODE              04 16580004
         LR    R15,R1                  START OF MESSAGE              06 16590006
         AR    R15,R0                  END OF MESSAGE +1             06 16600006
         SH    R15,=H'+9'              GET RETURN CODE POSITION      06 16610006
         UNPK  HEXNUM(9),DWORD(5)      CONVERT TO DISPLAY            04 16620004
         TR    HEXNUM(8),HEXTBL-240    FIX HEX DIGITS                04 16630004
         MVC   0(8,R15),HEXNUM         MOVE DISPLAY RC               06 16640006
         B     ANYMSG                  PRINT MESSAGE                    16650000
*                                                                    01 16660001
*                                                                    01 16670001
*                                                                    01 16680001
FMT4WARN DS    0H                                                    01 16690001
         MVC   MSG(12),=C'**WARNING** ' SET UP WARNING               01 16700001
         MVC   MSG+12(8),0(R1)         MOVE KEYWORD                  01 16710001
         MVC   MSG+21(7),=C'IGNORED'   TELL IT IS IGNORED            01 16720001
         B     PUTMSG                  GO ISSUE MESSAGE              01 16730001
WARNMSG  DS    0H                                                    01 16740001
         MVC   MSG(12),=C'**WARNING** ' SET UP WARNING                  16750000
         LR    R15,R0                  SET UP LENGTH                    16760000
         BCTR  R15,0                   GET MACHINE LENGTH               16770000
         EX    R15,MOVEMSG             MOVE MESSAGE                     16780000
PUTMSG   DS    0H                                                    01 16790001
         LA    R1,MSG                  ADDRESS MESSAGE                  16800000
         LA    R0,L'MSG                GET LENGTH                       16810000
ANYMSG   DS    0H                                                    01 16820001
         ST    R14,MSGR14              SAVE LINKAGE                  01 16830001
         LR    R14,R0                  GET LENGTH                       16840000
         AH    R0,=H'+5'               ADD FOR HEADER AND 1 BLANK       16850000
         STH   R0,PUTLINE              MESSAGE LENGTH                   16860000
         BCTR  R14,0                   MAKE MACHINE                     16870000
         EX    R14,MSGMOVE             MOVE MESSAGE                     16880000
         LA    R14,MYPPL               ADDRESS PPL FOR PUTLINE       01 16890001
         USING PPL,R14                 ADDRESSABILITY TO PPL         01 16900001
         L     R15,PPLUPT              UPT ADDRESS                   01 16910001
         L     R0,PPLECT               ECT ADDRESS                   01 16920001
         DROP  R14                     DROP ADDRESSABILITY TO PPL    01 16930001
         PUTLINE PARM=PUTBLOCK,                                        X16940000
               UPT=(R15),                                            01X16950001
               ECT=(R0),                                             01X16960001
               ECB=GPECB,                                              X16970000
               OUTPUT=(PUTLINE,TERM,SINGLE,DATA),                      X16980000
               MF=(E,IOPL)                                              16990000
         MVI   MSG,C' '                CLEAR OUT                        17000000
         MVC   MSG+1(L'MSG-1),MSG       MESSAGE AREA                    17010000
         L     R14,MSGR14              RESTORE LINKAGE                  17020000
         BR    R14                     EXIT . . .                       17030000
MOVEMSG  MVC   MSG+12(0),0(R1)         <<< EXECUTED >>>                 17040000
MSGMOVE  MVC   PUTDATA(0),0(R1)        <<< EXECUTED >>>                 17050000
*                                                                    01 17060001
*********************************************************************** 17070000
*     MAXIMUM VALUE PARSE VALIDITY CHECK EXIT ROUTINE FOR BUFL AND    * 17080000
*     BLKSIZE                                                         * 17090000
*           THIS ROUTINE PERFORMS LIMIT CHECKING ON VALUES SUPPLIED   * 17100000
*           FOR BUFL  AND BLKSIZE MAXIMUM VALUE IS 32,760             * 17110000
*           IF THE LIMIT IS EXCEEDED PARSE WILL PROMPT THE USER       * 17120000
*           OTHERWISE THE VALUE WILL BE ACCEPTED                      * 17130000
*********************************************************************** 17140000
BLKCK    DS    0H                                                    01 17150001
         SAVE  (14,12)                 SAVE REGISTERS                   17160000
         L     R11,4(,R1)              GET UWA (BASE REGISTER           17170000
         LA    R12,2048(,R11)          RESET UP                         17180000
         LA    R12,2048(,R12)           2ND BASE                        17190000
         LA    R14,EXITSAVE            SET UP SAVE AREA                 17200000
         ST    R13,4(,R14)             SAVE CALLERS SAVE AREA           17210000
         ST    R14,8(,R13)             SAVE MY SAVE AREA                17220000
         LR    R13,R14                 SET UP SAVE AREA ADDRESS      01 17230001
         L     R7,0(,R1)               ADDRESS ENTERED FIELD            17240000
         BAL   R14,CONVERT             CONVERT IT TO BINARY             17250000
         CH    R1,=H'+32760'           IS IT GREATER THAN 32760 ?       17260000
         BNH   BLKCKOK                  NO, FIELD OK                    17270000
         LA    R15,4                   SET ERROR RC                     17280000
         B     BLKCKXIT                GO EXIT                          17290000
BLKCKOK  DS    0H                                                    01 17300001
         SR    R15,R15                 SET ALL OK RC                    17310000
BLKCKXIT DS    0H                                                    01 17320001
         L     R13,4(,R13)             RESTORE SAVE AREA                17330000
         RETURN (14,12),RC=(15)                                         17340000
*                                                                    01 17350001
*********************************************************************** 17360000
*     MAXIMUM VALUE PARSE VALIDITY CHECK EXIT ROUTINE FOR KEYLEN      * 17370000
*     AND BUFNO SUBFIELDS                                             * 17380000
*           THIS ROUTINE PERFORMS LIMIT CHECKING ON VALUES SUPPLIED   * 17390000
*           FOR KEYLEN OR BUFNO,MAXIMUM VALUE IS 255                  * 17400000
*           IF THE LIMIT IS EXCEEDED PARSE WILL PROMPT THE USER       * 17410000
*           OTHERWISE THE VALUE WILL BE ACCEPTED                      * 17420000
*********************************************************************** 17430000
KEYCK    DS    0H                                                    01 17440001
         SAVE  (14,12)                 SAVE REGISTERS                   17450000
         L     R11,4(,R1)              GET UWA (BASE REGISTER           17460000
         LA    R12,2048(,R11)          RESET UP                         17470000
         LA    R12,2048(,R12)           2ND BASE                        17480000
         LA    R14,EXITSAVE            SET UP SAVE AREA                 17490000
         ST    R13,4(,R14)             SAVE CALLERS SAVE AREA           17500000
         ST    R14,8(,R13)             SAVE MY SAVE AREA                17510000
         LR    R13,R14                 SET UP SAVE AREA ADDRESS      01 17520001
         L     R7,0(,R1)               ADDRESS ENTERED FIELD            17530000
         BAL   R14,CONVERT             CONVERT FIELD TO BINARY          17540000
         CH    R1,=H'+255'             IS IT GREATER THAN 255 ?         17550000
         BNH   KEYCKOK                  NO, CONTINUE                    17560000
         LA    R15,4                   SET ERROR RC                     17570000
         B     KEYCKXIT                GO EXIT                          17580000
KEYCKOK  DS    0H                                                    01 17590001
         SR    R15,R15                 SET OK RC                        17600000
KEYCKXIT DS    0H                                                    01 17610001
         L     R13,4(,R13)             RESTORE SAVE AREA                17620000
         RETURN (14,12),RC=(15)                                         17630000
*                                                                    01 17640001
*********************************************************************** 17650000
*     PARSE VALIDITY CHECK ROUTINE FOR EXPDT                          * 17660000
*           THIS ROUTINE PERFORMS CHECKING ON VALUES SUPPLIED         * 17670000
*           FOR EXPDT   THE VALUE MUST BE 5 CHARACTERS                * 17680000
*           DAYS MUST NOT EXCEED 366                                  * 17690000
*           IF LESS THAN 5 OR DAYS IS GREATER THAN 366, PARSE WILL    * 17700000
*           PROMPT THE USER                                           * 17710000
*           OTHERWISE THE VALUE WILL BE ACCEPTED                      * 17720000
*********************************************************************** 17730000
EXPDTCK  DS    0H                                                    01 17740001
         SAVE  (14,12)                 SAVE REGISTERS                   17750000
         L     R11,4(,R1)              GET UWA (BASE REGISTER           17760000
         LA    R12,2048(,R11)          RESET UP                         17770000
         LA    R12,2048(,R12)           2ND BASE                        17780000
         LA    R14,EXITSAVE            SET UP SAVE AREA                 17790000
         ST    R13,4(,R14)             SAVE CALLERS SAVE AREA           17800000
         ST    R14,8(,R13)             SAVE MY SAVE AREA                17810000
         LR    13,14                   SET UP SAVE AREA ADDRESS         17820000
         L     R7,0(,R1)               ADDRESS ENTERED FIELD            17830000
EXPCKDYS DS    0H                                                    01 17840001
         LA    R0,5                    GET LENGTH NECESSARY             17850000
         CH    R0,4(,R7)               IS LENGTH 5 ?                    17860000
         BNE   EXPCKERR                 NO, ERROR                       17870000
         LA    R2,2                    LENGTH OF DAYS (MACHINE)         17880000
         LR    R1,R2                   DISPLACEMENT                     17890000
         A     R1,0(,R7)               ADDRESS DAYS                     17900000
         BAL   R14,CONVERTA            CONVERT DAYS TO BINARY           17910000
         CH    R1,=H'+366'             DOES IT EXCEED 366 ?             17920000
         BNH   EXPCKOK                  NO, OK                          17930000
EXPCKERR DS    0H                                                    01 17940001
         LA    R15,4                   SET ERROR RC                     17950000
         B     EXPCKXIT                GO EXIT                          17960000
EXPCKOK  DS    0H                                                    01 17970001
         SR    R15,R15                 SET OK RC                        17980000
EXPCKXIT DS    0H                                                    01 17990001
         L     R13,4(,R13)             RESTORE SAVE AREA                18000000
         RETURN (14,12),RC=(15)                                         18010000
*                                                                    01 18020001
         LTORG ,                                                     05 18030005
         DC    (((((*-DSCBUPDT)/4096)+1)*4096)-(*-DSCBUPDT))X'CC'    05 18040005
*                                                                    05 18050005
******************************************************************** 05 18060005
*                                                                  * 05 18070005
*        WORK AREAS                                                * 05 18080005
*                                                                  * 05 18090005
******************************************************************** 05 18100005
*                                                                    05 18110005
SAVE     DC    18A(0)                  SAVEAREA                         18120000
SIDEQ    EQU   X'31'                                                    18130000
TIC      EQU   X'08'                                                    18140000
WRTKYDTA EQU   X'0D'                                                    18150000
UPDTCCWS CCW   SIDEQ,SECTOR,X'60',L'SECTOR CCW STRING                   18160000
         CCW   TIC,UPDTCCWS,0,0                FOR REWRITE              18170000
         CCW   WRTKYDTA,DSN,0,96+44            OF FORMAT 1 DSCB         18180000
ECB      DC    X'7F000000'             EVENT CONTROL BLOCK              18190000
         DC    A(0)                                                     18200000
IOB      DC    X'42000000'             I O B                            18210000
         DC    A(ECB)                                                   18220000
         DC    2A(0)                                                    18230000
         DC    A(UPDTCCWS)                                              18240000
         DC    A(VTOCDCB)                                               18250000
         DC    2A(0)                                                    18260000
DISKADDR DC    2A(0)                                                    18270000
         ORG   DISKADDR+3                                               18280000
SECTOR   DC    XL5'0'                  ADDRESS OF FMT 1 DSCB TO UPDATE  18290000
FMT4     DC    44X'04'                 VTOC DSNAME                      18300000
EXLST    DC    X'87',AL3(JFCB)         READ JFCB EXIT LIST              18310000
JFCB     DC    44A(0)                  AREA FOR JFCB TO BE READ INTO    18320000
OPENLST  OPEN  (VTOCDCB,(OUTPUT)),MF=L OPEN PARAMETERS                  18330000
ALOCVOL  DC    X'0010'                 VOLUME SERIAL SPECIFICATION      18340000
         DC    AL2(1)                  NUMBER OF VOLUMES TO ALLOCATE    18350000
         DC    AL2(L'VOLSER)           LENGTH OF VOLUME SERIAL NUMBER   18360000
VOLSER   DC    CL6' '                  VOLUME SERIAL NUMBER             18370000
NDSCB    DC    265X'0'                                                  18380000
NDSN     DC    CL44' '                                                  18390000
DSN      DC    CL44' '                 HOLD DATA SET NAME               18400000
DSCB     DC    265X'0'                 DSCB AREA                        18410000
CAMLST   CAMLST SEARCH,DSN,VOLSER,DSCB SEARCH FOR FORMAT 1 DSCB         18420000
CHKNEWDS CAMLST SEARCH,NDSN,VOLSER,NDSCB SEARCH FOR FORMAT 1 DSCB       18430000
LOCATLST CAMLST NAME,DSN,,DSCB         GET VOLUME SERIAL FOR OBTAIN     18440000
FLAGS    DC    AL1(0)                  SAVED OPTIONS                    18450000
ANSWER   DC    A(0)                    ANSWER AREA FOR PARSE            18460000
PARSECB  DC    A(0)                    PARSES ECB                       18470000
MYPPL    DC    7A(0)                   PPL                              18480000
ALOCPRMS DC    AL1(128),AL3(ALLOCATE)  ALLOCATE PARAMETERS              18490000
ALLOCATE DC    AL1(20)                 LENGTH OF PARAMETERS             18500000
         DC    AL1(1)                  VERB (ALLOCATE BY DSNAME)        18510000
         DC    X'2000'                 DONT ALOC IF MOUNT NEEDED        18520000
RBERROR  DC    A(0)                    ERROR CODES RETURN AREA       04 18530004
         DC    AL1(128),AL3(ALCPRM)    ADDRESS OF PARAMETER LIST        18540000
         DC    2A(0)                   RESERVED AND ERROR CODES         18550000
ALCPRM   DC    A(ALOCDDN)              PARAMETERS - DDNAME SPEC         18560000
         DC    A(ALOCVOL)                         - VOLUME SPEC         18570000
         DC    A(ALOCDISP)                        - DISP SPEC           18580000
         DC    A(VTOCFREE)                        - FREE=CLOSE          18590000
         DC    AL1(128),AL3(ALOCUNIT)             - UNIT SPEC           18600000
ALOCDDN  DC    X'0001'                 ALLOC DDNAME SPECIFICATION       18610000
         DC    AL2(1)                  NUMBER OF DDNAMES TO ALLOCATE    18620000
         DC    AL2(L'DDNAME)           LENGTH OF DDNAME                 18630000
DDNAME   DC    CL8'VTOCUPDT'           DDNAME                           18640000
ALOCDISP DC    X'0004'                 ALLOC DATA SET DISP              18650000
         DC    AL2(1)                  NUMBER OF DISP PARAMETERS        18660000
         DC    AL2(L'DISP)             LENGTH OF DISPOSITION            18670000
DISP     DC    X'08'                   DISP=SHR                         18680000
         DC    0H'+0'                                                   18690000
ALOCUNIT DC    X'0015'                 ALLOC UNIT NAME SPECIFICATION    18700000
         DC    AL2(1)                  NUMBER OF UNITS                  18710000
         DC    AL2(L'UNIT)             LENGTH OF UNIT                   18720000
UNIT     DC    C'3350',CL4' '          UNIT NAME                        18730000
VTOCFREE DC    X'001C'                 CLOSE=FREE                       18740000
         DC    X'0000'                                                  18750000
VTOCDCB  DCB   MACRF=E,EXLST=EXLST,DEVD=DA,DDNAME=VTOCUPDT              18760000
HEXTBL   DC    C'0123456789ABCDEF'                                   01 18770001
IOERMS   DC    C'I/O ERROR REWRITING DSCB ECB=X''XXXXXXXX'''         04 18780004
PARSERMS DC    C'PARSE FAILURE RC=X''XXXXXXXX'''                     04 18790004
LOCERMS  DC    C'LOCATE FAILED RC=X''XXXXXXXX'''                     04 18800004
ALOCERMS DC    C'UNABLE TO ALLOCATE VOLUME RC=X''XXXXXXXX'''         04 18810004
SVC99EMS DC    C'DYNAMIC ALLOCATION ERROR=X''XXXXXXXX'''             04 18820004
OBTERMS  DC    C'UNABLE TO OBTAIN DSCB RC=X''XXXXXXXX'''             04 18830004
NWFERMS  DC    C'NEW DATA SET NAME ALREADY EXISTS ON VOLUME'            18840000
NWEERMS  DC    C'ERROR OBTAINING NEW DSN FROM VTOC RC=X''XXXXXXXX''' 04 18850004
OPENERMS DC    C'UNABLE TO OPEN VTOC'                                   18860000
UPDTMS   DC    C'DSCB UPDATED SUCCESSFULLY'                             18870000
CONFMSG  DC    C'CONFIRM DSCB UPDATE ENTER Y OR N'                      18880000
FAILUPMS DC    C'UPDATE CONFIRMATION DENIED'                            18890000
NOTUPDMS DC    C'DSCB NOT UPDATED'                                      18900000
ERR01MS  DC    C'LRECL NOT EQUAL ZERO FOR RECFM U'                      18910000
ERR02MS  DC    C'BLKSIZE EQUAL ZERO FOR RECFM F/FB'                     18920000
ERR03MS  DC    C'LRECL EQUAL ZERO FOR RECFM F/FB'                       18930000
ERR04MS  DC    C'LRECL NOT EQUAL BLKSIZE FOR RECFM F'                   18940000
ERR05MS  DC    C'LRECL GREATER THAN BLKSIZE FOR RECFM FB'               18950000
ERR06MS  DC    C'BLKSIZE NOT EVENLY DIVISIBLE BY LRECL FOR RECFM FB'    18960000
ERR07MS  DC    C'RECFM NOT F,V OR U'                                    18970000
ERR08MS  DC    C'BLKSIZE EQUAL ZERO FOR RECFM V/VB'                     18980000
ERR09MS  DC    C'LRECL NOT EQUAL ZERO FOR RECFM V'                      18990000
ERR10MS  DC    C'LRECL EQUAL ZERO FOR RECFM VB/VBS'                     19000000
ERR11MS  DC    C'BLKSIZE NOT 4 GREATER THAN LRECL FOR RECFM VB'      01 19010001
ERR12MS  DC    C'KEY EXTENDS BEYOND LRECL'                              19020000
ERR13MS  DC    C'DSORG CHANGED FROM IS'                                 19030000
ERR14MS  DC    C'DSORG CHANGED TO IS'                                   19040000
ERR15MS  DC    C'DSORG CHANGED FROM PO'                                 19050000
ERR16MS  DC    C'DSORG CHANGED TO PO'                                   19060000
ERR17MS  DC    C'DSORG CHANGED TO UNMOVEABLE'                           19070000
ERR18MS  DC    C'DSORG CHANGED FROM UNMOVEABLE'                         19080000
ERR19MS  DC    C'DSORG NOT IS, PS, DA OR PO'                            19090000
ERR20MS  DC    C'CONTIG, MXIG, ALX OR ROUND NOT VALID WITH ABSTR'       19100000
ERR21MS  DC    C'SECONDARY ALLOCATION NOT VALID WITH ABSTR'             19110000
NF4ERMS  DC    C'DIRF REQUIRES DSN=FORMAT4.DSCB'                     06 19120006
NF4ERMS1 DC    C'DOSOFF REQUIRES DSN=FORMAT4.DSCB'                   07 19130007
MOVDSN   MVC   DSN(0),0(R15)            <<< EXECUTED >>>                19140000
MOVNDSN  MVC   NDSN(0),0(R15)           <<< EXECUTED >>>                19150000
MOVVOL   MVC   VOLSER(0),0(R15)         <<< EXECUTED >>>                19160000
MOVUNT   MVC   UNIT(0),0(R15)           <<< EXECUTED >>>                19170000
MSGDSNMV MVC   MSG+4(0),0(R15)          <<< EXECUTED >>>                19180000
EXITSAVE DC    18A(0)                                                   19190000
DWORD    DC    D'+0'                                                 01 19200001
CRYEAR   DC    A(0)                                                     19210000
DAYTOTAL DC    A(0)                                                     19220000
EDITNUM  DC    X'4020206B202120'                                        19230000
HEXNUM   DC    CL9' '                                                04 19240004
EDITCHAR DC    C','                                                     19250000
MSG      DC    CL79' '                                                  19260000
UPDTFLAG DC    X'00'                                                    19270000
UPDATE   EQU   X'01'                   DSCB UPDATED                     19280000
TOISAM   EQU   X'02'                   CHANGED FROM DSORG XX TO IS      19290000
FROMISAM EQU   X'04'                   CHANGED FROM DSORG IS TO XX      19300000
TOPO     EQU   X'08'                   CHANGED FROM DSORG XX TO PO      19310000
FROMPO   EQU   X'10'                   CHANGED FROM DSORG PO TO XX      19320000
TOUNMOVE EQU   X'20'                   CHANGED TO UNMOVEABLE            19330000
FRUNMOVE EQU   X'40'                   CHANGED FROM UNMOVEABLE          19340000
FMT4UPDT EQU   X'80'                   FMT4 TO BE UPDATED               19350000
UPDTFLG2 DC    X'00'                                                 05 19360005
UPDTDIRF EQU   X'80'                   DIRF UPDATED                  05 19370005
UPDTDOS  EQU   X'80'                   DOS UPDATED                   07 19380007
MSGR14   DC    A(0)                    MSG ROUTINE RETURN SAVE          19390000
GPECB    DC    A(0)                    PUTLINE ECB                      19400000
IOPL     DC    4A(0)                   I/O PARAMETER LIST               19410000
PUTBLOCK PUTLINE MF=L                                                   19420000
PUTLINE  DC    H'+0'                   LENGTH OF LINE + HEADER          19430000
         DC    H'+0'                   RESERVED                         19440000
         DC    C' '                    BLANK FOR MESSAGE ID STRIPPING   19450000
PUTDATA  DC    CL80' '                 MESSAGE                          19460000
GETBLOCK PUTLINE MF=L                                                   19470000
         DC    (((((*-DSCBUPDT)/256)+1)*256)-(*-DSCBUPDT))X'DD'      05 19480005
*                                                                    01 19490001
*********************************************************************   19500000
*                                                                   *   19510000
*        T S O   PARSE  PARAMETERS                                  *   19520000
*                                                                   *   19530000
*********************************************************************   19540000
*                                                                    01 19550001
ZAPPARM  IKJPARM  DSECT=ZAPPDL                                          19560000
ZAPDSN   IKJPOSIT DSNAME,USID,PROMPT='DATASET NAME'                     19570000
*                                                                    01 19580001
ZAPOPTS  IKJKEYWD                                                       19590000
         IKJNAME  'PASSWORD',SUBFLD=PWDOPTS                             19600000
*                                                                    01 19610001
ZAPVOL   IKJKEYWD                                                       19620000
         IKJNAME  'VOLUME',SUBFLD=ZAPVOLSF                              19630000
*                                                                    01 19640001
ZAPUNT   IKJKEYWD                                                       19650000
         IKJNAME  'UNIT',SUBFLD=ZAPUNTSF                                19660000
*                                                                    01 19670001
BLKSIZE  IKJKEYWD                                                       19680000
         IKJNAME  'BLKSIZE',SUBFLD=SIZE                                 19690000
*                                                                    01 19700001
KEYLEN   IKJKEYWD                                                       19710000
         IKJNAME  'KEYLEN',SUBFLD=KEYLNGTH                              19720000
*                                                                    01 19730001
LRECL    IKJKEYWD                                                       19740000
         IKJNAME  'LRECL',SUBFLD=RECLNGTH                               19750000
*                                                                    01 19760001
OPTCD    IKJKEYWD                                                       19770000
         IKJNAME  'OPTCD',SUBFLD=CODE                                   19780000
*                                                                    01 19790001
RECFM    IKJKEYWD                                                       19800000
         IKJNAME  'RECFM',SUBFLD=FORMAT                                 19810000
*                                                                    01 19820001
EXPRETOT IKJKEYWD                                                       19830000
         IKJNAME  'EXPDT',SUBFLD=DATE                                   19840000
         IKJNAME  'RETPD',SUBFLD=DAYS                                   19850000
*                                                                    01 19860001
REFDAT   IKJKEYWD                                                       19870000
         IKJNAME  'REFDT',SUBFLD=REFDATE                                19880000
*                                                                    01 19890001
CRTDAT   IKJKEYWD                                                       19900000
         IKJNAME  'CRTDT',SUBFLD=CRTDATE                                19910000
*                                                                    01 19920001
SECONDRY IKJKEYWD                                                       19930000
         IKJNAME  'SECONDARY',SUBFLD=SECSUB                             19940000
*                                                                    01 19950001
ALLOC    IKJKEYWD                                                       19960000
         IKJNAME  'ALLOCATION',SUBFLD=ALCSUB                            19970000
*                                                                    01 19980001
DSORG    IKJKEYWD                                                       19990000
         IKJNAME  'DSORG',SUBFLD=DSORGSF                                20000000
*                                                                    01 20010001
RKP      IKJKEYWD                                                       20020000
         IKJNAME  'RKP',SUBFLD=RKPLEN                                   20030000
*                                                                    01 20040001
NEWDSNKW IKJKEYWD                                                       20050000
         IKJNAME  'NEWDSN',SUBFLD=NEWDSNSF                              20060000
*                                                                    01 20070001
LASTVOL  IKJKEYWD                                                       20080000
         IKJNAME  'LASTVOL',SUBFLD=LASTOPTS                             20090000
*                                                                    01 20100001
DSUPDATE IKJKEYWD                                                       20110000
         IKJNAME  'UPDATED',SUBFLD=UPDOPTS                              20120000
*                                                                    01 20130001
DIRF     IKJKEYWD                                                       20140000
         IKJNAME  'DIRF'                                                20150000
*                                                                    07 20160007
DOSOFF   IKJKEYWD ,                                                  07 20170007
         IKJNAME  'DOSOFF'                                           07 20180007
*                                                                    02 20190002
NOCONF   IKJKEYWD ,                                                  02 20200002
         IKJNAME  'NOCONFIRM'                                        02 20210002
*                                                                    01 20220001
PWDOPTS  IKJSUBF                                                        20230000
PWDFLDS  IKJKEYWD                                                       20240000
         IKJNAME  'OFF'                                                 20250000
         IKJNAME  'WRITE'                                               20260000
         IKJNAME  'READ'                                                20270000
         IKJNAME  'RACF'                                                20280000
         IKJNAME  'NORACF'                                              20290000
*                                                                    01 20300001
ZAPVOLSF IKJSUBF                                                        20310000
ZAPVOLUM IKJIDENT 'VOLUME',                                            X20320000
               MAXLNTH=6,                                              X20330000
               FIRST=ALPHANUM,OTHER=ALPHANUM,                          X20340000
               PROMPT='VOLUME SERIAL NUMBER',                          X20350000
               HELP='VOLUME ON WHICH DATA SET RESIDES'                  20360000
*                                                                    01 20370001
ZAPUNTSF IKJSUBF                                                        20380000
ZAPUNTNM IKJIDENT 'UNIT',                                              X20390000
               MAXLNTH=8,                                              X20400000
               FIRST=ALPHANUM,OTHER=ALPHANUM,                          X20410000
               PROMPT='UNIT NAME',                                     X20420000
               HELP='UNIT ON WHICH DATA SET RESIDES'                    20430000
*                                                                    01 20440001
SIZE     IKJSUBF                                                        20450000
BLKSZFLD IKJIDENT 'BLOCKSIZE',                                         X20460000
               MAXLNTH=5,                                              X20470000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X20480000
               PROMPT='BLOCKSIZE',                                     X20490000
               VALIDCK=BLKCK,                                          X20500000
               HELP='DECIMAL NUMBER FROM 0 TO 32760'                    20510000
*                                                                    01 20520001
KEYLNGTH IKJSUBF                                                        20530000
KEYLNFLD IKJIDENT 'KEY LENGTH',                                        X20540000
               MAXLNTH=3,                                              X20550000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X20560000
               PROMPT='KEY LENGTH',                                    X20570000
               VALIDCK=KEYCK,                                          X20580000
               HELP='DECIMAL NUMBER FROM 0 TO 255'                      20590000
*                                                                    01 20600001
RECLNGTH IKJSUBF                                                        20610000
RECLNFLD IKJIDENT 'LOGICAL RECORD LENGTH',                             X20620000
               MAXLNTH=5,                                              X20630000
               FIRST=ALPHANUM,OTHER=NUMERIC,                           X20640000
               PROMPT='LOGICAL RECORD LENGTH',                         X20650000
               VALIDCK=BLKCK,                                          X20660000
               HELP='DECIMAL NUMBER FROM 0 TO 32760'                    20670000
*                                                                    01 20680001
DATE     IKJSUBF                                                        20690000
DATEFLD  IKJIDENT 'EXPIRATION DATE',                                   X20700000
               MAXLNTH=5,                                              X20710000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X20720000
               PROMPT='EXPIRATION DATE',                               X20730000
               VALIDCK=EXPDTCK,                                        X20740000
               HELP='A JULIAN DATE IN YYDDD FORMAT'                     20750000
*                                                                    01 20760001
DAYS     IKJSUBF                                                        20770000
DAYSFLD  IKJIDENT 'RETENTION PERIOD',                                  X20780000
               MAXLNTH=4,                                              X20790000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X20800000
               PROMPT='RETENTION PERIOD',                              X20810000
               HELP='A DECIMAL NUMBER FROM 0 TO 9999'                   20820000
*                                                                    01 20830001
REFDATE  IKJSUBF                                                        20840000
RDATFLD  IKJIDENT 'LAST REFERENCE DATE',                               X20850000
               MAXLNTH=5,                                              X20860000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X20870000
               PROMPT='LAST REFERENCE DATE',                           X20880000
               VALIDCK=EXPDTCK,                                        X20890000
               HELP='A JULIAN DATE IN YYDDD FORMAT'                     20900000
*                                                                    01 20910001
CRTDATE  IKJSUBF                                                        20920000
CDATFLD  IKJIDENT 'CREATION DATE',                                     X20930000
               MAXLNTH=5,                                              X20940000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X20950000
               PROMPT='CREATION DATE',                                 X20960000
               VALIDCK=EXPDTCK,                                        X20970000
               HELP='A JULIAN DATE IN YYDDD FORMAT'                     20980000
*                                                                    01 20990001
CODE     IKJSUBF                                                        21000000
CODEFLDC IKJKEYWD                                                       21010000
         IKJNAME    'C'                                                 21020000
CODEFLDT IKJKEYWD                                                       21030000
         IKJNAME    'T'                                                 21040000
CODEFLDW IKJKEYWD                                                       21050000
         IKJNAME    'W'                                                 21060000
CODEFLDQ IKJKEYWD                                                       21070000
         IKJNAME    'Q'                                                 21080000
CODEFLD0 IKJKEYWD                                                       21090000
         IKJNAME    'ZERO'                                              21100000
*                                                                    01 21110001
FORMAT   IKJSUBF                                                        21120000
FORMFLDA IKJKEYWD                                                       21130000
         IKJNAME    'A'                                                 21140000
FORMFLDB IKJKEYWD                                                       21150000
         IKJNAME    'B'                                                 21160000
FORMFLDF IKJKEYWD                                                       21170000
         IKJNAME    'F'                                                 21180000
FORMFLDM IKJKEYWD                                                       21190000
         IKJNAME    'M'                                                 21200000
FORMFLDS IKJKEYWD                                                       21210000
         IKJNAME    'S'                                                 21220000
FORMFLDT IKJKEYWD                                                       21230000
         IKJNAME    'T'                                                 21240000
FORMFLDU IKJKEYWD                                                       21250000
         IKJNAME    'U'                                                 21260000
FORMFLDV IKJKEYWD                                                       21270000
         IKJNAME    'V'                                                 21280000
FORMFLD0 IKJKEYWD                                                       21290000
         IKJNAME    'ZERO'                                              21300000
*                                                                    01 21310001
SECSUB   IKJSUBF                                                        21320000
SECALLOC IKJIDENT 'NUMBER',FIRST=NUMERIC,OTHER=NUMERIC                  21330000
*                                                                    01 21340001
DSORGSF  IKJSUBF                                                        21350000
DSORGKEY IKJKEYWD                                                       21360000
         IKJNAME 'IS'                                                   21370000
         IKJNAME 'ISU'                                                  21380000
         IKJNAME 'PS'                                                   21390000
         IKJNAME 'PSU'                                                  21400000
         IKJNAME 'DA'                                                   21410000
         IKJNAME 'DAU'                                                  21420000
         IKJNAME 'PO'                                                   21430000
         IKJNAME 'POU'                                                  21440000
         IKJNAME 'ZERO'                                                 21450000
*                                                                    01 21460001
RKPLEN   IKJSUBF                                                        21470000
RKPFLD   IKJIDENT 'RELATIVE KEY POSITION',                             X21480000
               MAXLNTH=5,                                              X21490000
               FIRST=NUMERIC,OTHER=NUMERIC,                            X21500000
               PROMPT='RELATIVE KEY POSITION (RKP)',                   X21510000
               VALIDCK=BLKCK,                                          X21520000
               HELP='DECIMAL NUMBER FROM 0 TO 32760'                    21530000
*                                                                    01 21540001
ALCSUB   IKJSUBF                                                        21550000
ALOCTYPE IKJKEYWD                                                       21560000
         IKJNAME 'CYL'                                                  21570000
         IKJNAME 'TRK'                                                  21580000
         IKJNAME 'BLOCK'                                                21590000
         IKJNAME 'ABSTR'                                                21600000
ALOCSPC  IKJKEYWD                                                       21610000
         IKJNAME 'CONTIG'                                               21620000
         IKJNAME 'MXIG'                                                 21630000
         IKJNAME 'ALX'                                                  21640000
         IKJNAME 'NOCMA'                                                21650000
ALOCRND  IKJKEYWD                                                       21660000
         IKJNAME 'ROUND'                                                21670000
         IKJNAME 'NOROUND'                                              21680000
*                                                                    01 21690001
NEWDSNSF IKJSUBF                                                        21700000
NEWDSN   IKJPOSIT DSNAME,USID,PROMPT='NEW DATASET NAME'                 21710000
*                                                                    01 21720001
LASTOPTS IKJSUBF                                                        21730000
LASTFLDS IKJKEYWD                                                       21740000
         IKJNAME  'YES'                                                 21750000
         IKJNAME  'NO'                                                  21760000
*                                                                    01 21770001
UPDOPTS  IKJSUBF                                                        21780000
UPDFLDS  IKJKEYWD                                                       21790000
         IKJNAME  'YES'                                                 21800000
         IKJNAME  'NO'                                                  21810000
*                                                                    01 21820001
         IKJENDP                                                        21830000
*                                                                    01 21840001
         IKJCPPL                                                        21850000
*                                                                    01 21860001
         IKJPPL                                                         21870000
*                                                                    01 21880001
DSCBDSCT DSECT                                                          21890000
         IECSDSL1 (1)                                                   21900000
FMT4DSCT DSECT                                                          21910000
         IECSDSL1 (4)                                                   21920000
*                                                                    01 21930001
         DCBD   DSORG=PS,DEVD=DA                                        21940000
*                                                                    01 21950001
JFCBDSCT DSECT                                                          21960000
         IEFJFCBN                                                       21970000
*                                                                    01 21980001
         CVT   DSECT=YES                                                21990000
*                                                                    01 22000001
         IHAPSA                                                         22010000
*                                                                    01 22020001
         IKJPSCB                                                        22030000
*                                                                    01 22040001
         IKJTCB                                                         22050000
*                                                                    01 22060001
         IHAASCB                                                        22070000
*                                                                    01 22080001
         IRAOUCB                                                        22090000
*                                                                    01 22100001
         IEZJSCB                                                        22110000
*                                                                    01 22120001
         IKJGTPB                                                        22130000
*                                                                    01 22140001
         END                                                            22150000
