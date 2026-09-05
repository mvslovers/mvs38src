*********************************************************************** 00010001
*                                                                     * 00020001
* Module Name                                                         * 00030001
*    PRTTRK                                                           * 00040001
*                                                                     * 00050001
* Attributes                                                          * 00060001
*    RENT AUTHORIZED                                                  * 00070001
*                                                                     * 00080001
* Author                                                              * 00090001
*    Dave Kreiss                                                      * 00100001
*                                                                     * 00110001
* Function                                                            * 00120001
*    Print a range of tracks                                          * 00130001
*                                                                     * 00140001
* JCL                                                                 * 00150001
*    //PRTTRK  EXEC PGM=PRTTRK,PARM='parameters'                      * 00160001
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00170001
*    //SYSPRINT DD  SYSOUT=*                                          * 00180001
*    //ddname   DD  VOL=SER=vvvvvv,UNIT=uuuu,DISP=SHR                 * 00190001
*    //SYSIN    DD  *                                                 * 00200001
*                                                                     * 00210001
* DD Statements                                                       * 00220004
*    STEPLIB       Load library containing the module PRTTRK          * 00230001
*    SYSPRINT      Contains track dump                                * 00240001
*    SYSIN         Input control statement                            * 00250001
*    ddname        Input DD to alllocate volume containg the          * 00260001
*                  tracks to dump                                     * 00270001
*                                                                     * 00280001
* Control Statement Format                                            * 00290001
*    PRINT         Start in colummn 2 on                              * 00300001
*                  DDNAME and CCHH are seperated by a comma           * 00310001
*                  Prints the range of tracks specified.              * 00320005
*    VERIFY        Start in colummn 2 on                              * 00330002
*                  DDNAME and CCHH are seperated by a comma           * 00340002
*                  Reads the range of tracks specified to             * 00350002
*                  verify they are readable.                          * 00360002
*    MAP           Start in colummn 2 on                              * 00370005
*                  DDNAME and CCHH are seperated by a comma           * 00380005
*                  Prints map of the range of tracks specified.       * 00390005
*    DDNAME=ddname The DDNAME of volume to dump tracks                * 00400001
*                  This keyword is required.                          * 00410001
*    CCHH=(s,e)    The CCHH of the track or tracks to dump            * 00420001
*                  The start CCHH is eight hex digits                 * 00430001
*                  The end CCHH is eight hex digits                   * 00440001
*                  If only one track specify only start without       * 00450001
*                  parenthesis                                        * 00460001
*                  This keyword is required.                          * 00470001
*                                                                     * 00480001
* Example Control Statement                                           * 00490001
*    Dump IPL track from volume allocated to DDNAME DISK              * 00500001
*    //DISK     DD  VOL=SER=WORK00,UNIT=3380,DISP=SHR                 * 00510001
*    //SYSIN    DD  *                                                 * 00520004
*      PRINT DDNAME=DISK,CCHH=00000000                                * 00530001
*    /*                                                               * 00540001
*                                                                     * 00550001
*    Dump a series of tracks from volume allocated to DDNAME MVSRES   * 00560001
*    //MVSRES   DD  VOL=SER=MVSRES,UNIT=3390,DISP=SHR                 * 00570001
*    //SYSIN    DD  *                                                 * 00580004
*      PRINT    CCHH=(00010000,0003000E),DDNAME=MVSRES                * 00590001
*    /*                                                               * 00600001
*                                                                     * 00610005
*    Verify a 3390 MOD 1 allocated to DDNAME MVSRES                   * 00620005
*    //MVSRES   DD  VOL=SER=MVSRES,UNIT=3390,DISP=SHR                 * 00630005
*    //SYSIN    DD  *                                                 * 00640005
*      VERIFY CCHH=(00000000,0458000E),DDNAME=MVSRES                  * 00650005
*    /*                                                               * 00660005
*                                                                     * 00670005
*    Maps a track allocated to DDNAME MVSRES                          * 00680005
*    //MVSRES   DD  VOL=SER=MVSRES,UNIT=3390,DISP=SHR                 * 00690005
*    //SYSIN    DD  *                                                 * 00700005
*      MAP CCHH=(00000000,00000000),DDNAME=MVSRES                     * 00710005
*    /*                                                               * 00720005
*                                                                     * 00730001
* Parameters                                                          * 00740001
*    DEBUG         Prints dump of work areas for diagnostics          * 00750005
*    DEBUG(IOTRACE) Prints an I/O trace and other diagnostics         * 00760005
*                                                                     * 00770001
* Return Codes                                                        * 00780001
*    0              Tracks dumped                                     * 00790001
*    8              Errors from parsing of RDTRK                      * 00800005
*                                                                     * 00810001
*********************************************************************** 00820001
*                                                                     * 00830001
* Change Log:                                                         * 00840001
*   Date     AAA VV.RR Description                                    * 00850001
* 04/07/2020 DSK  1.01 Created                                        * 00860001
* 06/03/2020 DSK  1.02 VERIFY command                                 * 00870002
* 10/10/2020 DSK  1.03 Fix formatting and add run time                * 00880003
* 05/31/2021 DSK  1.04 Correct documentation                          * 00890004
* 01/22/2022 DSK  1.05 Validate begin and end CCHH                    * 00900005
*                      Add MAP command and IO trace                   * 00910005
* 01/30/2022 DSK  1.06 Allow multiple control statements              * 00920006
*********************************************************************** 00930000
         GBLC  &VER                                                     00940001
&VER     SETC  'V1.06'                                                  00950006
PRTTRK   CSECT                                                          00960000
         USING PRTTRK,R15                                               00970000
         B     START                   Bypass PGMID                     00980000
         DROP  R15                                                      00990000
         DC    AL1(L'PGMID)            Length of PGMID                  01000000
PGMID    DC    C'PRTTRK - &VER &SYSDATE &SYSTIME'                       01010001
START    DS    0H                                                       01020000
         STM   R14,R12,12(R13)         Save calling pgm's registers     01030000
         LR    R11,R15                 Base register                    01040000
         LA    R12,2048(,R11)                                           01050000
         LA    R12,2048(,R12)                                           01060000
         USING PRTTRK,R11,R12                                           01070000
         SR    R10,R10                 No RDTRK work area               01080001
         L     R9,0(,R1)               Save parameter address           01090000
         LA    R0,W#LEN                Work area length                 01100000
         GETMAIN R,LV=(0)              Get work area                    01110000
         LR    R3,R13                  Save save area address           01120000
         LR    R13,R1                  Address save area                01130000
         USING W#,R13                                                   01140000
         LR    R0,R13                  Work area address                01150000
         LA    R1,W#LEN                Work area length                 01160000
         SR    R15,R15                 Set up to clear                  01170000
         MVCL  R0,R14                  Clear work area                  01180000
         ST    R3,4(,R13)              Chain callers save area          01190000
         ST    R13,8(,R3)              Chain my save area               01200000
         BAL   R14,INIT                Initialization                   01210000
         LTR   R15,R15                 Was it successful?               01220000
         BNZ   EXIT                    No, exit                         01230000
         L     R0,=A(WORKLEN)          RDTRK work area length        06 01240006
         GETMAIN R,LV=(0)                                            06 01250006
         LR    R10,R1                                                06 01260006
         USING WORKAREA,R10                                          06 01270006
         BAL   R14,PRT                                               06 01280006
*********************************************************************** 01290000
*        Parse control statement                                      * 01300002
*********************************************************************** 01310000
PROC     DS    0H                                                       01320000
         GET   W#INDCB,W#INREC         Get record                       01330000
*                                                                    06 01340006
         LA    R0,1                    Count control statements      06 01350006
         A     R0,W#CSCNT                                            06 01360006
         ST    R0,W#CSCNT                                            06 01370006
         XC    W#TRKFMT,W#TRKFMT       Clear                         06 01380006
         XC    W#CCHHB,W#CCHHB          some                         06 01390006
         XC    W#CCHHE,W#CCHHE           parser                      06 01400006
         NI    W#FLG,255-W#FLGMAP         fields                     06 01410006
         NI    W#FLG,255-W#FLGVER                                    06 01420006
         NI    W#FLG,255-W#FLG1AD                                    06 01430006
         NI    W#FLG,255-W#FLG2AD                                    06 01440006
         NI    W#FLG,255-W#FLGDDN                                    06 01450006
         MVC   W#DDN,=CL8' '                                         06 01460006
*                                                                    06 01470006
         MVC   W#LINE+1(17),=C'Control statement'                       01480000
         BAL   R14,PRT                                                  01490000
         MVC   W#LINE+1(L'W#INREC),W#INREC Copy to print line           01500000
         BAL   R14,PRT                 Print a line                     01510000
         LA    R3,W#INREC                                               01520000
         LA    R4,72                                                    01530000
PROCCM10 DS    0H                                                    02 01540002
         CLI   0(R3),C' '                                               01550000
         BNE   PROCCM20                                              02 01560002
         LA    R3,1(,R3)                                                01570000
         BCT   R4,PROCCM10                                           02 01580002
         B     PROCIER                                                  01590000
PROCCM20 DS    0H                                                    02 01600002
         CH    R4,=H'+4'              Room for command               05 01610005
         BNH   PROCIER                No, error                      05 01620005
         CLC   =C'MAP ',0(R3)         MAP command                    05 01630005
         BE    PROCIM10               Yes, parse it                  05 01640005
         CH    R4,=H'+6'              Room for command               02 01650002
         BNH   PROCIER                No, error                      02 01660002
         CLC   =C'PRINT ',0(R3)       PRINT command                  02 01670002
         BE    PROCIP10               Yes, parse it                  02 01680002
         CH    R4,=H'+7'              Room for command               02 01690002
         BNH   PROCIER                No, error                      02 01700002
         CLC   =C'VERIFY ',0(R3)      VERIFY command                 02 01710002
         BE    PROCIV10               Yes, parse it                  02 01720002
         B     PROCIER                Unknown command                02 01730002
*        MAP command                                                 05 01740005
PROCIM10 DS    0H                                                    05 01750005
         LA    R3,4(,R3)               Get past MAP verb             05 01760005
         SH    R4,=H'+4'               Decrement length              05 01770005
         BAL   R14,PARP                Parse PRINT command           05 01780005
         LTR   R15,R15                 Sucessful parse?              05 01790005
         BNZ   PROCIER                 No, error                     05 01800005
         OI    W#FLG,W#FLGMAP          Set in MAP mode               05 01810005
         B     PROCCMD                 Process command               05 01820005
*        PRINT command                                                  01830000
PROCIP10 DS    0H                                                       01840000
         LA    R3,6(,R3)               Get past PRINT verb           02 01850002
         SH    R4,=H'+6'               Decrement length              02 01860002
         BAL   R14,PARP                Parse PRINT command           02 01870002
         LTR   R15,R15                 Sucessful parse?              02 01880002
         BNZ   PROCIER                 No, error                     02 01890002
         B     PROCCMD                 Process command               02 01900002
*        VERIFY command                                              02 01910002
PROCIV10 DS    0H                                                    02 01920002
         LA    R3,7(,R3)               Get past VERIFY verb          02 01930002
         SH    R4,=H'+7'               Decrement length              02 01940002
         BAL   R14,PARP                Parse VERIFY command          02 01950002
         LTR   R15,R15                 Sucessful parse?              02 01960002
         BNZ   PROCIER                 No, error                     02 01970002
         OI    W#FLG,W#FLGVER          Set in VERIFY mode            02 01980002
*********************************************************************** 01990000
*        INITIALIZE READ TRACK INTERFACE                              * 02000000
*********************************************************************** 02010000
PROCCMD  DS    0H                                                    02 02020002
         MVC   W#LINE+1(13),=C'End statement'                        02 02030002
         BAL   R14,PRT                                               02 02040002
         BAL   R14,PRT                                               02 02050002
         MVC   W#CCHH,W#CCHHB                                           02060000
*********************************************************************** 02070000
*        OPEN volume for read                                         * 02080001
*********************************************************************** 02090000
         RDTRKRQ OPEN,WORK=WORKAREA,CCHH=W#CCHH,DDNAME=W#DDN,          *02100000
               EPA=W#EPA,PARM=W#PARM                                    02110000
         LTR   R15,R15                                                  02120000
         BNZ   RDTRKERR                                                 02130000
         BAL   R14,INFO                                                 02140000
         LA    R1,W#CCHHB              Begin CCHH                    05 02150005
         BAL   R14,CHKP                Verify begin CCHH             05 02160005
         LTR   R15,R15                 Sucessful parse?              05 02170005
         BNZ   INVCCHHB                No, error                     05 02180005
         LA    R1,W#CCHHE              End CCHH                      05 02190005
         BAL   R14,CHKP                Verify end CCHH               05 02200005
         LTR   R15,R15                 Sucessful parse?              05 02210005
         BNZ   INVCCHHE                No, error                     05 02220005
*********************************************************************** 02230001
*        READ track(s)                                                * 02240001
*********************************************************************** 02250001
PROCRD   DS    0H                                                       02260000
         RDTRKRQ READ,WORK=WORKAREA,CCHH=W#CCHH,                       *02270000
               EPA=W#EPA,PARM=W#PARM                                    02280000
         LR    R3,R15                                                05 02290005
         TM    W#FLG,W#FLGIOT                                        05 02300005
         BNO   PROCNDTR                                              05 02310005
         CLI   WRKHAECB,0                                            05 02320005
         BE    PROCNDTR                                              05 02330005
         BAL   R14,PRT                                               05 02340005
         MVC   W#LINE+1(14),=C'Read HA and R0'                       05 02350005
         BAL   R14,PRT                                               05 02360005
         LA    R15,WRKHAIOB                                          05 02370005
         LA    R2,WRKCCWHA                                           05 02380005
         BAL   R14,IOTRACE                                           05 02390005
         BAL   R14,PRT                                               05 02400005
         CLI   WRKCTECB,0                                            05 02410005
         BE    PROCNDTR                                              05 02420005
         MVC   W#LINE+1(17),=C'Read track counts'                    05 02430005
         BAL   R14,PRT                                               05 02440005
         LA    R15,WRKCTIOB                                          05 02450005
         LA    R2,WRKCCWRC                                           05 02460005
         BAL   R14,IOTRACE                                           05 02470005
         BAL   R14,PRT                                               05 02480005
         CLI   WRKDTECB,0                                            05 02490005
         BE    PROCNDTR                                              05 02500005
         MVC   W#LINE+1(15),=C'Read track data'                      05 02510005
         BAL   R14,PRT                                               05 02520005
         LA    R15,WRKDTIOB                                          05 02530005
         LA    R2,WRKCCWKD                                           05 02540005
         BAL   R14,IOTRACE                                           05 02550005
         BAL   R14,PRT                                               05 02560005
PROCNDTR DS    0H                                                    05 02570005
         LTR   R15,R3                                                05 02580005
         BNZ   RDTRKERR                                                 02590000
         L     R1,W#TRKFMT                                              02600001
         LA    R1,1(,R1)                                                02610001
         ST    R1,W#TRKFMT                                              02620001
         TM    W#FLG,W#FLGMAP                                        05 02630005
         BO    PROCRDMP                                              05 02640005
         TM    W#FLG,W#FLGVER                                        05 02650005
         BO    PROCRDVR                                              05 02660005
         BAL   R14,FMTR                                                 02670000
         B     PROCRDNX                                              02 02680002
PROCRDMP DS    0H                                                    05 02690005
         BAL   R14,MAPTR                                             05 02700005
         B     PROCRDNX                                              05 02710005
PROCRDVR DS    0H                                                    02 02720002
         BAL   R14,VERTR                                             02 02730002
PROCRDNX DS    0H                                                    02 02740002
         TM    W#FLG,W#FLG1AD                                           02750000
         BNO   PROCCLS                                                  02760000
         CLC   W#CCHH,W#CCHHE                                           02770000
         BNL   PROCCLS                                                  02780000
         CLC   W#CCHH+2(2),WRKMAXTR                                     02790001
         BNL   PROCRDNC                                                 02800001
         LH    R1,W#CCHH+2                                              02810000
         LA    R1,1(,R1)                                                02820000
         STH   R1,W#CCHH+2                                              02830000
         B     PROCRD                                                   02840000
PROCRDNC DS    0H                                                       02850000
         LH    R1,W#CCHH                                                02860000
         LA    R1,1(,R1)                                                02870000
         STH   R1,W#CCHH                                                02880000
         XC    W#CCHH+2(2),W#CCHH+2                                     02890000
         B     PROCRD                                                   02900000
*********************************************************************** 02910000
*        CLOSE volume                                                 * 02920001
*********************************************************************** 02930000
PROCCLS  DS    0H                                                       02940000
         RDTRKRQ CLOSE,WORK=WORKAREA,                                  *02950000
               EPA=W#EPA,PARM=W#PARM                                    02960000
         LTR   R15,R15                                                  02970000
         BNZ   RDTRKERR                                                 02980000
*                                                                       02990001
         TM    W#FLG,W#FLGVER                                        05 03000005
         BNO   PROCCLSA                                              05 03010005
         STCK  W#ENDTME                Get current time              03 03020003
         LM    R0,R1,W#ENDTME          Calculate run time            03 03030003
         SL    R1,W#STRTME+4                                         03 03040003
         BNM   PROCCLS0                                              03 03050003
         SL    R0,=A(1)                                              03 03060003
PROCCLS0 DS    0H                                                    03 03070003
         SL    R0,W#STRTME                                           03 03080003
         BAL   R14,FCLK                Format run time               03 03090003
         MVC   W#LINE+31(L'W#FCLK),W#FCLK And off to print           03 03100003
         BAL   R14,PRT                                               03 03110003
*                                                                    03 03120003
PROCCLSA DS    0H                                                    05 03130005
         MVC   W#LINE+1(11),=C'Tracks read'                             03140001
         L     R0,W#TRKFMT                                              03150001
         CVD   R0,W#DWORD                                               03160001
         A     R0,W#TRKTOT                                           06 03170006
         ST    R0,W#TRKTOT                                           06 03180006
         MVC   W#LINE+18(12),=X'402020206B2020206B202120'            03 03190003
         ED    W#LINE+18(12),W#DWORD+3                               03 03200003
         BAL   R14,PRT                                                  03210001
*                                                                       03220001
         MVC   W#LINE+1(14),=C'Number of I/Os'                       02 03230002
         L     R0,WRKIOCNT                                              03240001
         CVD   R0,W#DWORD                                               03250001
         A     R0,W#IOTOT                                            06 03260006
         ST    R0,W#IOTOT                                            06 03270006
         MVC   W#LINE+18(12),=X'402020206B2020206B202120'            03 03280003
         ED    W#LINE+18(12),W#DWORD+3                               03 03290003
         BAL   R14,PRT                                                  03300001
         TM    W#FLG,W#FLGDBG                                           03310000
         BNO   PROCCLS1                                                 03320000
         BAL   R14,PRT                                                  03330001
         BAL   R14,DBG                                                  03340000
PROCCLS1 DS    0H                                                       03350000
         MVI   W#LINE,C'1'                                           06 03360006
         B     PROC                                                  06 03370006
*********************************************************************** 03380000
*        Errors                                                       * 03390001
*********************************************************************** 03400000
PROCIER  DS    0H                                                       03410000
         LA    R0,W#INREC                                               03420000
         SR    R3,R0                                                    03430000
         LA    R3,W#LINE+1(R3)                                          03440000
         MVC   0(19,R3),=C'* Invalid statement'                      06 03450006
         BAL   R14,PRT                                                  03460000
         LA    R15,8                                                    03470000
         B     EXIT                                                     03480000
*                                                                       03490000
RDTRKERR DS    0H                                                       03500000
         ST    R0,W#DWORD                                               03510000
         MVC   W#LINE+1(14),=C'RDTRK error=X'''                      02 03520002
         UNPK  W#LINE+15(9),W#DWORD(5)                                  03530000
         TR    W#LINE+15(8),P#HEXTBL-240                                03540000
         MVC   W#LINE+23(9),=C''' CCHH=X'''                          05 03550005
         UNPK  W#LINE+32(9),W#CCHH(5)                                05 03560005
         TR    W#LINE+32(8),P#HEXTBL-240                             05 03570005
         MVI   W#LINE+40,C''''                                       05 03580005
         L     R1,=A(P#RDERRS)                                       06 03590006
RDERR1   DS    0H                                                    02 03600002
         CLC   0(4,R1),W#DWORD                                       02 03610002
         BE    RDERR2                                                02 03620002
         LA    R1,36(,R1)                                            02 03630002
         CLI   0(R1),X'FF'                                           02 03640002
         BNE   RDERR1                                                02 03650002
RDERR2   DS    0H                                                    02 03660002
         MVC   W#LINE+42(32),4(R1)                                   05 03670005
         BAL   R14,PRT                                                  03680000
         OI    W#FLG,W#FLGDBG                                        02 03690002
         BAL   R14,CHKIO                                             02 03700002
         BAL   R14,PRT                                               02 03710002
         BAL   R14,DBG                                                  03720000
         LA    R15,8                                                    03730000
         B     EXIT                                                     03740000
*                                                                       03750001
EOF      DS    0H                                                       03760000
         LA    R15,0                                                 06 03770006
         ICM   R0,15,W#CSCNT                                         06 03780006
         BNZ   EXIT                                                  06 03790006
         MVC   W#LINE+1(17),=C'Missing statement'                    06 03800006
         BAL   R14,PRT                                                  03810000
         LA    R15,8                                                    03820000
         B     EXIT                                                  05 03830005
*                                                                    05 03840005
INVCCHHB DS    0H                                                    05 03850005
         MVC   W#LINE+1(18),=C'Invalid begin CCHH'                   05 03860005
         BAL   R14,PRT                                               05 03870005
         RDTRKRQ CLOSE,WORK=WORKAREA,                                05*03880005
               EPA=W#EPA,PARM=W#PARM                                 05 03890005
         LTR   R15,R15                                               05 03900005
         BNZ   RDTRKERR                                              05 03910005
         LA    R15,8                                                 05 03920005
         B     EXIT                                                  05 03930005
*                                                                    05 03940005
INVCCHHE DS    0H                                                    05 03950005
         MVC   W#LINE+1(16),=C'Invalid end CCHH'                     05 03960005
         BAL   R14,PRT                                               05 03970005
         RDTRKRQ CLOSE,WORK=WORKAREA,                                05*03980005
               EPA=W#EPA,PARM=W#PARM                                 05 03990005
         LTR   R15,R15                                               05 04000005
         BNZ   RDTRKERR                                              05 04010005
         LA    R15,8                                                 05 04020005
         B     EXIT                                                  05 04030005
*********************************************************************** 04040001
*        EXIT                                                         * 04050001
*********************************************************************** 04060001
EXIT     DS    0H                                                       04070000
         MVI   W#LINE,C' '                                           06 04080006
         LR    R2,R15                  Save return code                 04090000
         BAL   R14,PRT                                                  04100000
*                                                                    06 04110006
         ICM   R0,15,W#TRKTOT                                        06 04120006
         BZ    EXIT010                                               06 04130006
         MVC   W#LINE+1(17),=C'Total tracks read'                    06 04140006
         CVD   R0,W#DWORD                                            06 04150006
         MVC   W#LINE+18(12),=X'402020206B2020206B202120'            06 04160006
         ED    W#LINE+18(12),W#DWORD+3                               06 04170006
         BAL   R14,PRT                                               06 04180006
*                                                                    06 04190006
         MVC   W#LINE+1(10),=C'Total I/Os'                           06 04200006
         L     R0,W#IOTOT                                            06 04210006
         CVD   R0,W#DWORD                                            06 04220006
         MVC   W#LINE+18(12),=X'402020206B2020206B202120'            06 04230006
         ED    W#LINE+18(12),W#DWORD+3                               06 04240006
         BAL   R14,PRT                                               06 04250006
*                                                                    06 04260006
EXIT010  DS    0H                                                    06 04270006
         MVC   W#LINE+1(8),=C'Run time'                              06 04280006
         STCK  W#STPTME                                              06 04290006
         LM    R0,R1,W#STPTME                                        06 04300006
         SL    R1,W#STRTME+4                                         06 04310006
         BNM   EXIT020                                               06 04320006
         SL    R0,=A(1)                                              06 04330006
EXIT020  DS    0H                                                    06 04340006
         SL    R0,W#STRTME                                           06 04350006
         BAL   R14,FCLK                Format run time               06 04360006
         MVC   W#LINE+15(L'W#FCLK),W#FCLK And off to print           06 04370006
         BAL   R14,PRT                                               06 04380006
*                                                                    06 04390006
         MVC   W#LINE+1(11),=C'Return code'                             04400000
         CH    R2,=H'4095'                                              04410000
         BNL   EXIT030                                               06 04420006
         CVD   R2,W#DWORD                                               04430000
         MVC   W#LINE+24(6),=X'402020202120'                         06 04440006
         ED    W#LINE+24(6),W#DWORD+5                                06 04450006
         B     EXIT040                                               06 04460006
EXIT030  DS    0H                                                    06 04470006
         ST    R2,W#DWORD                                            00 04480006
         MVC   W#LINE+19(2),=C'X'''                                  06 04490006
         UNPK  W#LINE+21(9),W#DWORD(5)                               06 04500006
         TR    W#LINE+21(8),P#HEXTBL-240                             06 04510006
         MVI   W#LINE+29,C''''                                       06 04520006
EXIT040  DS    0H                                                    06 04530006
         BAL   R14,PRT                                                  04540000
         CLOSE (W#OTDCB,,W#INDCB),MF=(E,W#OPNLST)                       04550000
         LTR   R1,R10                  Address of work area             04560001
         BZ    EXIT050                 Skip if none acquired         06 04570006
         L     R0,=A(WORKLEN)          RDTRK work area length           04580001
         FREEMAIN R,A=(1),LV=(0)       Free RDTRK work area             04590001
EXIT050  DS    0H                                                    06 04600006
         LR    R1,R13                  Address of work area             04610000
         L     R13,4(,R13)             Restore callers R13              04620000
         LA    R0,W#LEN                Work area length                 04630000
         FREEMAIN R,A=(1),LV=(0)       Free work area                   04640000
         L     R14,12(,R13)            Restore R14                      04650000
         LR    R15,R2                  Restore return code              04660000
         LM    R0,R12,20(R13)          Restore rest of registers        04670001
         BR    R14                     Exit                             04680000
QUIT     DS    0H                                                       04690000
         LA    R15,16                  Failed return code               04700000
         B     EXIT                    Go cleanup                       04710000
*********************************************************************** 04720000
*                                                                     * 04730000
*        FORMAT TRACK                                                 * 04740001
*                                                                     * 04750000
*********************************************************************** 04760000
FMTR     DS    0H                                                       04770000
         ST    R14,W#FMTR14            Save linkage                     04780000
         MVC   W#LINE+1(20),=C'Formatting Track CC='                    04790001
         UNPK  W#LINE+21(5),W#CCHH(3)                                   04800001
         TR    W#LINE+21(4),P#HEXTBL-240                                04810001
         MVC   W#LINE+25(4),=C' HH='                                    04820001
         UNPK  W#LINE+29(5),W#CCHH+2(3)                                 04830001
         TR    W#LINE+29(4),P#HEXTBL-240                                04840001
         MVI   W#LINE+33,C' '                                           04850001
         BAL   R14,PRT                                                  04860000
*********************************************************************** 04870000
*        Format home address                                          * 04880000
*********************************************************************** 04890000
         MVC   W#LINE+4(18),=C'Home address Flag='                      04900000
         UNPK  W#LINE+22(3),WRKHAFL(2)                                  04910000
         TR    W#LINE+22(2),P#HEXTBL-240                                04920000
         MVC   W#LINE+24(4),=C' CC='                                    04930000
         UNPK  W#LINE+28(5),WRKHACC(3)                                  04940000
         TR    W#LINE+28(4),P#HEXTBL-240                                04950000
         MVC   W#LINE+32(4),=C' HH='                                    04960000
         UNPK  W#LINE+36(5),WRKHAHH(3)                                  04970000
         TR    W#LINE+36(4),P#HEXTBL-240                                04980000
         MVI   W#LINE+40,C' '                                           04990000
         BAL   R14,PRT                                                  05000000
*********************************************************************** 05010000
*        Format record zero                                           * 05020000
*********************************************************************** 05030000
         MVC   W#LINE+4(15),=C'Record zero CC='                         05040000
         UNPK  W#LINE+19(5),WRKR0CC(3)                                  05050000
         TR    W#LINE+19(4),P#HEXTBL-240                                05060000
         MVC   W#LINE+23(4),=C' HH='                                    05070000
         UNPK  W#LINE+27(5),WRKR0HH(3)                                  05080000
         TR    W#LINE+27(4),P#HEXTBL-240                                05090000
         MVI   W#LINE+31,C' '                                           05100000
         BAL   R14,PRT                                                  05110000
*********************************************************************** 05120001
*        Format track just read                                       * 05130001
*********************************************************************** 05140001
         BAL   R14,CHKIO                                             05 05150005
         LA    R2,WRKCOUNT            CCCC HHHH RR KK RRRR              05160000
         LA    R3,WORKAREA                                           05 05170005
         A     R3,=A(WRKBUF-WORKAREA)                                05 05180005
         SR    R4,R4                                                    05190000
         SR    R5,R5                                                    05200000
         SR    R6,R6                                                    05210000
FMT      DS    0H                                                       05220000
         LA    R6,1(,R6)                                                05230000
         MVC   W#LINE+4(9),=C'Count CC='                                05240000
         UNPK  W#LINE+13(5),0(3,R2)                                     05250000
         TR    W#LINE+13(4),P#HEXTBL-240                                05260000
         MVC   W#LINE+17(4),=C' HH='                                    05270000
         UNPK  W#LINE+21(5),2(3,R2)                                     05280000
         TR    W#LINE+21(4),P#HEXTBL-240                                05290000
         MVC   W#LINE+25(3),=C' R='                                     05300000
         UNPK  W#LINE+28(3),4(2,R2)                                     05310000
         TR    W#LINE+28(2),P#HEXTBL-240                                05320000
         MVC   W#LINE+30(12),=C' Key length='                           05330000
         UNPK  W#LINE+42(3),5(2,R2)                                     05340000
         TR    W#LINE+42(2),P#HEXTBL-240                                05350000
         MVC   W#LINE+44(13),=C' Data length='                          05360000
         UNPK  W#LINE+57(5),6(3,R2)                                     05370000
         TR    W#LINE+57(4),P#HEXTBL-240                                05380000
         MVI   W#LINE+61,C' '                                           05390000
         CLC   6(2,R2),=XL2'00'         EOF = ZERO DATA LENGTH          05400000
         BNE   FMTKEY                                                   05410000
         MVC   W#LINE+62(12),=C'(EOF marker)'                           05420000
FMTKEY   DS    0H                                                       05430000
         BAL   R14,PRT                                                  05440000
         CLI   5(R2),0                  KEY LENGTH ZERO                 05450000
         BE    FMTDATA                                                  05460000
         MVC   W#LINE+4(10),=C'Key length'                              05470000
         SR    R0,R0                                                    05480000
         IC    R0,5(,R2)                                                05490000
         AR    R4,R0                                                    05500000
         CVD   R0,W#DWORD                                               05510000
         MVC   W#LINE+14(4),=X'40202120'                                05520000
         ED    W#LINE+14(4),W#DWORD+6                                   05530000
         BAL   R14,PRT                                                  05540000
         LR    R1,R3                                                    05550000
         SR    R0,R0                                                    05560000
         IC    R0,5(,R2)                                                05570000
         BAL   R14,DMP                                                  05580000
FMTDATA  DS    0H                                                       05590000
         CLC   6(2,R2),=XL2'00'                                         05600000
         BE    FMTEND                                                   05610000
         MVC   W#LINE+4(11),=C'Data length'                             05620000
         SR    R0,R0                                                    05630000
         ICM   R0,3,6(R2)                                               05640000
         AR    R5,R0                                                    05650000
         CVD   R0,W#DWORD                                               05660000
         MVC   W#LINE+15(7),=X'4020206B202120'                          05670000
         ED    W#LINE+15(7),W#DWORD+5                                   05680000
         BAL   R14,PRT                                                  05690000
         LR    R1,R3                                                    05700000
         SR    R0,R0                                                    05710000
         IC    R0,5(,R2)                                                05720000
         AR    R1,R0                                                    05730000
         SR    R0,R0                                                    05740000
         ICM   R0,3,6(R2)                                               05750000
         BAL   R14,DMP                                                  05760000
FMTEND   DS    0H                                                       05770000
         BAL   R14,PRT                                                  05780000
         SR    R0,R0                                                    05790000
         IC    R0,5(,R2)                                                05800000
         AR    R3,R0                                                    05810000
         SR    R0,R0                                                    05820000
         ICM   R0,3,6(R2)                                               05830000
         AR    R3,R0                                                    05840000
         LA    R2,8(,R2)                                                05850000
         CLC   0(8,R2),=XL8'00'       End of counts                     05860000
         BE    ENDTRK                                                   05870000
         CLC   WRKCOUNT(8),0(R2)      We wrap around to start of track  05880000
         BNE   FMT                                                      05890000
*********************************************************************** 05900000
*        Print some statistics                                        * 05910000
*********************************************************************** 05920000
ENDTRK   DS    0H                                                       05930000
*                                                                       05940000
         MVC   W#LINE+1(16),=C'Records on track'                        05950000
         CVD   R6,W#DWORD                                               05960000
         MVC   W#LINE+20(7),=X'4020206B202120'                          05970000
         ED    W#LINE+20(7),W#DWORD+5                                   05980000
         BAL   R14,PRT                                                  05990000
*                                                                       06000000
         MVC   W#LINE+1(17),=C'Key data on track'                       06010000
         CVD   R4,W#DWORD                                               06020000
         MVC   W#LINE+20(7),=X'4020206B202120'                          06030000
         ED    W#LINE+20(7),W#DWORD+5                                   06040000
         BAL   R14,PRT                                                  06050000
*                                                                       06060000
         MVC   W#LINE+1(13),=C'Data on track'                           06070000
         CVD   R5,W#DWORD                                               06080000
         MVC   W#LINE+20(7),=X'4020206B202120'                          06090000
         ED    W#LINE+20(7),W#DWORD+5                                   06100000
         BAL   R14,PRT                                                  06110000
*                                                                       06120000
         LR    R2,R6                            NUMBER OF RECORDS       06130000
         MH    R2,=H'8'                         COUNT SIZE              06140000
         AH    R2,=H'13'                        HA AND R0 SIZE          06150000
         CVD   R2,W#DWORD                                               06160000
         MVC   W#LINE+1(12),=C'CKD overhead'                            06170000
         MVC   W#LINE+20(7),=X'4020206B202120'                          06180000
         ED    W#LINE+20(7),W#DWORD+5                                   06190000
         BAL   R14,PRT                                                  06200000
*                                                                       06210000
         MVC   W#LINE+1(14),=C'Total on track'                          06220000
         AR    R2,R4                            KEY SIZE                06230000
         AR    R2,R5                            DATA SIZE               06240000
         CVD   R2,W#DWORD                                               06250000
         MVC   W#LINE+20(7),=X'4020206B202120'                          06260000
         ED    W#LINE+20(7),W#DWORD+5                                   06270000
         MVC   W#LINE+29(22),=C'(HA+R0+Count+Key+Data)'                 06280000
         BAL   R14,PRT                                                  06290000
         BAL   R14,PRT                                                  06300000
         L     R14,W#FMTR14            Get return address               06310000
         BR    R14                     Return to caller                 06320000
******************************************************************** 02 06330002
*                                                                  * 02 06340002
*        Check for successful read                                 * 02 06350002
*                                                                  * 02 06360002
******************************************************************** 02 06370002
VERTR    DS    0H                                                    02 06380002
         ST    R14,W#VERR14            Save linkage                  02 06390002
         BAL   R14,CHKIO                                             02 06400002
         L     R0,W#TRKFMT                                           02 06410002
         C     R0,=A(1)                                              02 06420002
         BNE   VERTR10                                               02 06430002
         STCK  W#BGNTME                Start time                    02 06440002
         B     VERTR30                                               02 06450002
VERTR10  DS    0H                                                    02 06460002
         CVD   R0,W#DWORD                                            02 06470002
         NI    W#DWORD+5,X'0F'                                       02 06480002
         CP    W#DWORD+5(3),=P'+0'                                   02 06490002
         BNE   VERTR30                                               02 06500002
         MVC   W#LINE+4(7),=C'CCHH=X'''                              02 06510002
         UNPK  W#LINE+11(9),W#CCHH(5)                                02 06520002
         TR    W#LINE+11(8),P#HEXTBL-240                             02 06530002
         MVI   W#LINE+19,C''''                                       02 06540002
         CVD   R0,W#DWORD                                            02 06550002
         MVC   W#LINE+20(10),=X'40206B2020206B202120'                02 06560002
         ED    W#LINE+20(10),W#DWORD+4                               02 06570002
         STCK  W#ENDTME                Get current time              02 06580002
         LM    R0,R1,W#ENDTME          Calculate interval            02 06590002
         SL    R1,W#BGNTME+4                                         02 06600002
         BNM   VERTR20                                               02 06610002
         SL    R0,=A(1)                                              02 06620002
VERTR20  DS    0H                                                    02 06630002
         SL    R0,W#BGNTME                                           02 06640002
         BAL   R14,FCLK                Format interval               02 06650002
         MVC   W#LINE+31(L'W#FCLK),W#FCLK And off to print           02 06660002
         MVC   W#BGNTME,W#ENDTME       Next interval start time      02 06670002
         BAL   R14,PRT                                               02 06680002
VERTR30  DS    0H                                                    02 06690002
         L     R14,W#VERR14            Get return address            02 06700002
         BR    R14                     Return to caller              02 06710002
******************************************************************** 05 06720005
*                                                                  * 05 06730005
*        MAP track                                                 * 05 06740005
*                                                                  * 05 06750005
******************************************************************** 05 06760005
MAPTR    DS    0H                                                    05 06770005
         ST    R14,W#MAPR14            Save linkage                  05 06780005
         BAL   R14,CHKIO                                             05 06790005
         MVC   W#LINE+1(26),=C'Map of Track CC='                     05 06800005
         UNPK  W#LINE+17(5),W#CCHH(3)                                05 06810005
         TR    W#LINE+17(4),P#HEXTBL-240                             05 06820005
         MVC   W#LINE+21(4),=C' HH='                                 05 06830005
         UNPK  W#LINE+25(5),W#CCHH+2(3)                              05 06840005
         TR    W#LINE+25(4),P#HEXTBL-240                             05 06850005
         MVI   W#LINE+29,C' '                                        05 06860005
         BAL   R14,PRT                                               05 06870005
******************************************************************** 05 06880005
*        Format home address                                       * 05 06890005
******************************************************************** 05 06900005
         MVC   W#LINE+4(6),=C'HA CC='                                05 06910005
         UNPK  W#LINE+10(5),WRKHACC(3)                               05 06920005
         TR    W#LINE+10(4),P#HEXTBL-240                             05 06930005
         MVC   W#LINE+14(4),=C' HH='                                 05 06940005
         UNPK  W#LINE+18(5),WRKHAHH(3)                               05 06950005
         TR    W#LINE+18(4),P#HEXTBL-240                             05 06960005
         MVC   W#LINE+22(4),=C' FL='                                 05 06970005
         UNPK  W#LINE+26(3),WRKHAFL(2)                               05 06980005
         TR    W#LINE+26(2),P#HEXTBL-240                             05 06990005
         MVI   W#LINE+28,C' '                                        05 07000005
         BAL   R14,PRT                                               05 07010005
******************************************************************** 05 07020005
*        Format record zero                                        * 05 07030005
******************************************************************** 05 07040005
         MVC   W#LINE+4(6),=C'R0 CC='                                05 07050005
         UNPK  W#LINE+10(5),WRKR0CC(3)                               05 07060005
         TR    W#LINE+10(4),P#HEXTBL-240                             05 07070005
         MVC   W#LINE+14(4),=C' HH='                                 05 07080005
         UNPK  W#LINE+18(5),WRKR0HH(3)                               05 07090005
         TR    W#LINE+18(4),P#HEXTBL-240                             05 07100005
         MVI   W#LINE+22,C' '                                        05 07110005
         BAL   R14,PRT                                               05 07120005
         LA    R2,WRKCOUNT            CCCC HHHH RR KK RRRR           05 07130005
         SR    R4,R4                                                 05 07140005
         SR    R5,R5                                                 05 07150005
         SR    R6,R6                                                 05 07160005
MAPTRK   DS    0H                                                    05 07170005
         LA    R6,1(,R6)                                             05 07180005
         MVC   W#LINE+7(3),=C'CC='                                   05 07190005
         UNPK  W#LINE+10(5),0(3,R2)                                  05 07200005
         TR    W#LINE+10(4),P#HEXTBL-240                             05 07210005
         MVC   W#LINE+14(4),=C' HH='                                 05 07220005
         UNPK  W#LINE+18(5),2(3,R2)                                  05 07230005
         TR    W#LINE+18(4),P#HEXTBL-240                             05 07240005
         MVC   W#LINE+22(3),=C' R='                                  05 07250005
         UNPK  W#LINE+25(3),4(2,R2)                                  05 07260005
         TR    W#LINE+25(2),P#HEXTBL-240                             05 07270005
         MVC   W#LINE+27(4),=C' KL='                                 05 07280005
         UNPK  W#LINE+31(3),5(2,R2)                                  05 07290005
         TR    W#LINE+31(2),P#HEXTBL-240                             05 07300005
         MVC   W#LINE+33(4),=C' DL='                                 05 07310005
         UNPK  W#LINE+37(5),6(3,R2)                                  05 07320005
         TR    W#LINE+37(4),P#HEXTBL-240                             05 07330005
         MVI   W#LINE+41,C' '                                        05 07340005
         CLC   6(2,R2),=XL2'00'         EOF = ZERO DATA LENGTH       05 07350005
         BNE   FMTTRPR                                               05 07360005
         MVC   W#LINE+42(12),=C'(EOF marker)'                        05 07370005
FMTTRPR  DS    0H                                                    05 07380005
         BAL   R14,PRT                                               05 07390005
         SR    R0,R0                                                 05 07400005
         IC    R0,5(,R2)                                             05 07410005
         AR    R4,R0                                                 05 07420005
         SR    R0,R0                                                 05 07430005
         ICM   R0,3,6(R2)                                            05 07440005
         AR    R5,R0                                                 05 07450005
         LA    R2,8(,R2)                                             05 07460005
         CLC   0(8,R2),=XL8'00'       End of counts                  05 07470005
         BE    FMTTRND                                               05 07480005
         CLC   WRKCOUNT(8),0(R2)      Wrap around to start of track  05 07490005
         BNE   MAPTRK                                                05 07500005
FMTTRND  DS    0H                                                    05 07510005
         MVC   W#LINE+9(7),=C'Records'                               05 07520006
         CVD   R6,W#DWORD                                            05 07530005
         MVC   W#LINE+16(7),=X'4B20206B202120'                       05 07540006
         ED    W#LINE+16(7),W#DWORD+5                                05 07550006
         MVC   W#LINE+24(10),=C'Key length'                          05 07560006
         CVD   R4,W#DWORD                                            05 07570005
         MVC   W#LINE+34(7),=X'4B20206B202120'                       05 07580006
         ED    W#LINE+34(7),W#DWORD+5                                05 07590006
         MVC   W#LINE+42(11),=C'Data length'                         05 07600006
         CVD   R5,W#DWORD                                            05 07610005
         MVC   W#LINE+53(7),=X'4B20206B202120'                       05 07620006
         ED    W#LINE+53(7),W#DWORD+5                                05 07630006
         LR    R2,R6                            NUMBER OF RECORDS    05 07640005
         MH    R2,=H'8'                         COUNT SIZE           05 07650005
         AH    R2,=H'13'                        HA AND R0 SIZE       05 07660005
         CVD   R2,W#DWORD                                            05 07670005
         MVC   W#LINE+62(8),=C'Overhead'                             05 07680006
         MVC   W#LINE+70(7),=X'4B20206B202120'                       05 07690006
         ED    W#LINE+70(7),W#DWORD+5                                05 07700006
         MVC   W#LINE+78(5),=C'Total'                                05 07710006
         AR    R2,R4                            KEY SIZE             05 07720005
         AR    R2,R5                            DATA SIZE            05 07730005
         CVD   R2,W#DWORD                                            05 07740005
         MVC   W#LINE+83(7),=X'4B20206B202120'                       05 07750006
         ED    W#LINE+83(7),W#DWORD+5                                05 07760006
         BAL   R14,PRT                                               05 07770005
         BAL   R14,PRT                                               05 07780005
         L     R14,W#MAPR14            Get return address            05 07790005
         BR    R14                     Return to caller              05 07800005
******************************************************************** 02 07810002
*                                                                  * 02 07820002
*        Check for successful read                                 * 02 07830002
*                                                                  * 02 07840002
******************************************************************** 02 07850002
CHKIO    DS    0H                                                    02 07860002
         ST    R14,W#CHKR14            Save linkage                  02 07870002
         CLI   WRKCTECB,X'00'          I/O never started             02 07880002
         BE    CHKIO10                 Yes                           02 07890002
         CLI   WRKHAECB,X'7F'          I/O completed successful      02 07900002
         BE    CHKIO10                 Yes                           02 07910002
         TM    W#FLG,W#FLGDBG                                        02 07920002
         BNO   CHKIO10                                               02 07930002
         MVC   W#LINE+1(27),=C'Read home address I/O error'          02 07940002
         BAL   R14,PRT                                               02 07950002
         LA    R15,WRKHAIOB                                          05 07960005
         BAL   R14,IOERRMS                                           02 07970002
CHKIO10  DS    0H                                                    02 07980002
         CLI   WRKCTECB,X'00'          I/O never started             02 07990002
         BE    CHKIO20                 Yes                           02 08000002
         CLI   WRKCTECB,X'7F'          I/O completed successful      02 08010002
         BE    CHKIO20                 Yes                           02 08020002
         TM    W#FLG,W#FLGDBG                                        02 08030002
         BNO   CHKIO20                                               02 08040002
         MVC   W#LINE+1(20),=C'Read count I/O error'                 02 08050002
         BAL   R14,PRT                                               02 08060002
         LA    R15,WRKCTIOB                                          05 08070005
         BAL   R14,IOERRMS                                           02 08080002
CHKIO20  DS    0H                                                    02 08090002
         CLI   WRKDTECB,X'00'          I/O never started             02 08100002
         BE    CHKIO30                 Yes                           02 08110002
         CLI   WRKDTECB,X'7F'          I/O completed successful      02 08120002
         BE    CHKIO30                 Yes                           02 08130002
         TM    W#FLG,W#FLGDBG                                        02 08140002
         BNO   CHKIO30                                               02 08150002
         MVC   W#LINE+1(19),=C'Read data I/O error'                  02 08160002
         BAL   R14,PRT                                               02 08170002
         LA    R15,WRKDTIOB                                          05 08180005
         BAL   R14,IOERRMS                                           02 08190002
CHKIO30  DS    0H                                                    02 08200002
         L     R14,W#CHKR14            Get return address            02 08210002
         BR    R14                     Return to caller              02 08220002
*********************************************************************** 08230000
*                                                                     * 08240000
*        PARSE PRINT COMMAND                                          * 08250001
*                                                                     * 08260000
*********************************************************************** 08270000
PARP     DS    0H                                                       08280000
         ST    R14,W#PARP14            Save linkage                     08290000
*        Find PRINT/VERIFY keywords                                  02 08300002
PARPIP20 DS    0H                                                       08310000
         CLI   0(R3),C' '                                               08320000
         BNE   PARPIP30                                                 08330000
         LA    R3,1(,R3)                                                08340000
         BCT   R4,PARPIP20                                              08350000
         B     PARPIER                                                  08360000
PARPIP30 DS    0H                                                       08370000
         CH    R4,=H'+6'                                                08380000
         BL    PARPIER                                                  08390000
         CLC   =C'CCHH=',0(R3)                                          08400000
         BE    PARPIC10                                                 08410000
         CH    R4,=H'+8'                                                08420000
         BL    PARPIER                                                  08430000
         CLC   =C'DDNAME=',0(R3)                                        08440000
         BE    PARPID10                                                 08450000
         B     PARPIER                                                  08460000
*        CCHH=(cccchhhh,cccchhhh)                                    02 08470002
*        CCHH=cccchhhh                                               02 08480002
PARPIC10 DS    0H                                                       08490000
         TM    W#FLG,W#FLG1AD                                           08500000
         BO    PARPIER                                                  08510000
         OI    W#FLG,W#FLG1AD                                           08520000
         LA    R3,5(,R3)                                                08530000
         SH    R4,=H'+5'                                                08540000
         BNP   PARPIER                                                  08550000
         CLI   0(R3),C'('                                               08560000
         BNE   PARPIC20                                                 08570000
         OI    W#FLG,W#FLG2AD                                           08580000
         LA    R3,1(,R3)                                                08590000
         SH    R4,=H'+1'                                                08600000
         BNP   PARPIER                                                  08610000
PARPIC20 DS    0H                                                       08620000
         CH    R4,=H'+8'                                                08630000
         BL    PARPIER                                                  08640000
         LA    R0,8                                                     08650000
PARPIC30 DS    0H                                                       08660000
         IC    R1,0(,R3)                                                08670000
         N     R1,=A(X'F')                                              08680000
         CLI   0(R3),C'A'                                               08690000
         BL    PARPIER                                                  08700000
         CLI   0(R3),C'F'                                               08710000
         BNH   PARPIC40                                                 08720000
         CLI   0(R3),C'0'                                               08730000
         BL    PARPIER                                                  08740000
         CLI   0(R3),C'9'                                               08750000
         BH    PARPIER                                                  08760000
         B     PARPIC50                                                 08770000
PARPIC40 DS    0H                                                       08780000
         LA    R1,9(,R1)                                                08790000
PARPIC50 DS    0H                                                       08800000
         SLL   R15,4                                                    08810000
         OR    R15,R1                                                   08820000
         LA    R3,1(,R3)                                                08830000
         BCTR  R4,0                                                     08840000
         BCT   R0,PARPIC30                                              08850000
         ST    R15,W#CCHHB                                              08860000
         TM    W#FLG,W#FLG2AD                                           08870000
         BNO   PARPIC90                                                 08880000
         CH    R4,=H'+10'                                               08890000
         BL    PARPIER                                                  08900000
         CLI   0(R3),C','                                               08910000
         BNE   PARPIER                                                  08920000
         LA    R3,1(,R3)                                                08930000
         BCTR  R4,0                                                     08940000
         LA    R0,8                                                     08950000
PARPIC60 DS    0H                                                       08960000
         IC    R1,0(,R3)                                                08970000
         N     R1,=A(X'F')                                              08980000
         CLI   0(R3),C'A'                                               08990000
         BL    PARPIER                                                  09000000
         CLI   0(R3),C'F'                                               09010000
         BNH   PARPIC70                                                 09020000
         CLI   0(R3),C'0'                                               09030000
         BL    PARPIER                                                  09040000
         CLI   0(R3),C'9'                                               09050000
         BH    PARPIER                                                  09060000
         B     PARPIC80                                                 09070000
PARPIC70 DS    0H                                                       09080000
         LA    R1,9(,R1)                                                09090000
PARPIC80 DS    0H                                                       09100000
         SLL   R15,4                                                    09110000
         OR    R15,R1                                                   09120000
         LA    R3,1(,R3)                                                09130000
         BCTR  R4,0                                                     09140000
         BCT   R0,PARPIC60                                              09150000
         CLI   0(R3),C')'                                               09160000
         BNE   PARPIER                                                  09170000
         LA    R3,1(,R3)                                                09180000
         SH    R4,=H'+1'                                                09190000
         BNP   PARPIER                                                  09200000
         CL    R15,W#CCHHB                                              09210000
         BL    PARPIER                                                  09220000
         ST    R15,W#CCHHE                                              09230000
PARPIC90 DS    0H                                                       09240000
         CH    R4,=H'+1'                                                09250000
         BL    PARPIER                                                  09260000
         CLI   0(R3),C' '                                               09270000
         BE    PARPIEND                                                 09280000
         CLI   0(R3),C','                                               09290000
         BNE   PARPIER                                                  09300000
         LA    R3,1(,R3)                                                09310000
         SH    R4,=H'+1'                                                09320000
         BNP   PARPIER                                                  09330000
         B     PARPIP30                                                 09340000
*        DDNAME=xxxxxxxx                                             02 09350002
PARPID10 DS    0H                                                       09360000
         TM    W#FLG,W#FLGDDN                                           09370000
         BO    PARPIER                                                  09380000
         OI    W#FLG,W#FLGDDN                                           09390000
         LA    R3,7(,R3)                                                09400000
         SH    R4,=H'+7'                                                09410000
         MVC   W#DDN,=CL8' '                                            09420000
         LA    R1,W#DDN                                                 09430000
         LA    R0,8                                                     09440000
         CLI   0(R3),C'@'                                               09450000
         BE    PARPID40                                                 09460000
         CLI   0(R3),C'#'                                               09470000
         BE    PARPID40                                                 09480000
         CLI   0(R3),C'$'                                               09490000
         BE    PARPID40                                                 09500000
         B     PARPID30                                                 09510000
PARPID20 DS    0H                                                       09520000
         CLI   0(R3),C'0'                                               09530000
         BL    PARPID30                                                 09540000
         CLI   0(R3),C'9'                                               09550000
         BH    PARPIER                                                  09560000
         B     PARPID40                                                 09570000
PARPID30 DS    0H                                                       09580000
         CLI   0(R3),C'A'                                               09590000
         BL    PARPIER                                                  09600000
         CLI   0(R3),C'I'                                               09610000
         BNH   PARPID40                                                 09620000
         CLI   0(R3),C'J'                                               09630000
         BL    PARPIER                                                  09640000
         CLI   0(R3),C'R'                                               09650000
         BNH   PARPID40                                                 09660000
         CLI   0(R3),C'S'                                               09670000
         BL    PARPIER                                                  09680000
         CLI   0(R3),C'Z'                                               09690000
         BH    PARPID40                                                 09700000
PARPID40 DS    0H                                                       09710000
         MVC   0(1,R1),0(R3)                                            09720000
         LA    R1,1(,R1)                                                09730000
         LA    R3,1(,R3)                                                09740000
         SH    R4,=H'+1'                                                09750000
         BNP   PARPIER                                                  09760000
         CLI   0(R3),C' '                                               09770000
         BE    PARPIEND                                                 09780000
         CLI   0(R3),C','                                               09790000
         BE    PARPID50                                                 09800000
         BCT   R0,PARPID20                                              09810000
         B     PARPIER                                                  09820000
PARPID50 DS    0H                                                       09830000
         LA    R3,1(,R3)                                                09840000
         SH    R4,=H'+1'                                                09850000
         BNP   PARPIER                                                  09860000
         B     PARPIP30                                                 09870000
PARPIEND DS    0H                                                       09880000
         TM    W#FLG,W#FLG1AD                                           09890000
         BNO   PARPIER                                                  09900000
         TM    W#FLG,W#FLGDDN                                           09910000
         BNO   PARPIER                                                  09920000
         LA    R15,0                                                    09930000
         B     PARPXT                                                   09940000
PARPIER  DS    0H                                                       09950000
         LA    R15,8                   Set error return code            09960000
PARPXT   DS    0H                                                       09970000
         L     R14,W#PARP14            Get return address               09980000
         BR    R14                     Return to caller                 09990000
******************************************************************** 05 10000005
*                                                                  * 05 10010005
*        Validate a CCHH                                           * 05 10020005
*                                                                  * 05 10030005
******************************************************************** 05 10040005
CHKP     DS    0H                                                    05 10050005
         CLC   0(2,R1),WRKMAXCY        VALID CC?                     05 10060005
         BH    CHKPERR                 NO, ERROR                     05 10070005
         CLC   2(2,R1),WRKMAXTR        VALID HH?                     05 10080005
         BH    CHKPERR                 NO, ERROR                     05 10090005
         SR    R15,R15                                               05 10100005
         B     CHKPXT                                                05 10110005
CHKPERR  DS    0H                                                    05 10120005
         LA    R15,8                                                 05 10130005
CHKPXT   DS    0H                                                    05 10140005
         BR    R14                     Return to caller              05 10150005
*********************************************************************** 10160000
*                                                                     * 10170000
*        VOLUME INFORMATION                                           * 10180001
*                                                                     * 10190000
*********************************************************************** 10200000
INFO     DS    0H                                                       10210000
         ST    R14,W#INFO14            Save linkage                     10220000
         MVC   W#LINE+1(16),=C'Device Type Info'                        10230001
         BAL   R14,PRT                 Print                            10240000
*                                                                       10250000
         MVC   W#LINE+4(8),=C'VOL=SER='                                 10260000
         MVC   W#LINE+12(6),WRKJFCB+118 VOL=SER to print                10270000
         MVC   W#LINE+60(8),=C'DEVTYPE='                                10280000
         SR    R1,R1                                                    10290000
         IC    R1,WRKDEVAR+3           Get device type                  10300000
         LTR   R1,R1                   If zero skip it                  10310000
         BZ    DASDTPER                                                 10320000
         CH    R1,=AL2(P#DASD#)        If valid DASD device type     06 10330006
         BNH   DASDTP                                                   10340000
DASDTPER DS    0H                                                       10350000
         MVC   W#LINE+68(2),=C'X'''    Unknown format in HEX            10360000
         UNPK  W#LINE+70(3),WRKDEVAR+3(2)                               10370000
         TR    W#LINE+70(2),P#HEXTBL-240                                10380000
         MVI   W#LINE+72,C''''                                          10390000
         B     DASDTPND                                                 10400000
DASDTP   DS    0H                                                       10410000
         BCTR  R1,0                    Relative to zero                 10420000
         SLL   R1,3                    Times table entry size           10430000
         L     R14,=A(P#DASDNM)                                      06 10440006
         LA    R1,0(R1,R14)            Get specific device name      06 10450006
         MVC   W#LINE+68(7),1(R1)      Move to print                    10460000
         CLC   =C'3390',W#LINE+68                                    06 10470006
         BNE   DASDTPND                                              06 10480006
         L     R14,=A(P#3390NM)                                      06 10490006
         LA    R0,1                                                  06 10500006
         AH    R0,WRKMAXCY                                           06 10510006
TP3390   DS    0H                                                    06 10520006
         CLI   0(R14),X'FF'                                          06 10530006
         BE    DASDTPND                                              06 10540006
         C     R0,0(,R14)                                            06 10550006
         BE    TP3390MD                                              06 10560006
         LA    R14,8(,R14)                                           06 10570006
         B     TP3390                                                06 10580006
TP3390MD DS    0H                                                    06 10590006
         MVC   W#LINE+72(4),4(R14)                                   06 10600006
DASDTPND DS    0H                                                       10610000
         BAL   R14,PRT                 Print                            10620000
*                                                                       10630000
         LA    R1,1                    MAXCYL is relative 0             10640000
         AH    R1,WRKMAXCY                                              10650000
         LA    R14,1                                                    10660000
         AH    R14,WRKMAXTR            MAXHEAD is relative 0            10670000
         MR    R0,R14                                                   10680000
         CVD   R1,W#DWORD              Total tracks                     10690000
         MVC   W#LINE+4(6),=C'Tracks'                                   10700000
         MVC   W#LINE+23(12),=X'402020206B2020206B202120'               10710000
         ED    W#LINE+23(12),W#DWORD+3                                  10720000
         LA    R0,1                    MAXCYL is relative 0             10730000
         AH    R0,WRKMAXCY                                              10740000
         CVD   R0,W#DWORD              Total cylinders                  10750000
         MVC   W#LINE+60(4),=C'Cyls'                                    10760000
         MVC   W#LINE+81(10),=X'40206B2020206B202120'                   10770000
         ED    W#LINE+81(10),W#DWORD+4                                  10780000
         BAL   R14,PRT                 Print                            10790000
*                                                                       10800000
         BAL   R14,PRT                 Print                            10810000
         MVC   W#LINE+1(16),=C'Format Four Info'                        10820001
         BAL   R14,PRT                 Print                            10830000
*                                                                       10840000
         LA    R2,WRKFMT4                                               10850000
         USING DSCBFMT4,R2                                              10860000
         MVC   W#LINE+4(11),=C'Number cyls'                             10870000
         MVC   W#LINE+28(7),=X'4020206B202120'                          10880000
         SR    R0,R0                                                    10890000
         ICM   R0,3,DS4DEVCY                                            10900000
         CVD   R0,W#DWORD                                               10910000
         ED    W#LINE+28(7),W#DWORD+5                                   10920000
         MVC   W#LINE+60(14),=C'Tracks per cyl'                         10930000
         MVC   W#LINE+84(7),=X'4020206B202120'                          10940000
         SR    R0,R0                                                    10950000
         ICM   R0,3,DS4DEVTR                                            10960000
         CVD   R0,W#DWORD                                               10970000
         ED    W#LINE+84(7),W#DWORD+5                                   10980000
         BAL   R14,PRT                 Print                            10990000
*                                                                       11000000
         MVC   W#LINE+4(12),=C'Track length'                            11010000
         MVC   W#LINE+28(7),=X'4020206B202120'                          11020000
         SR    R0,R0                                                    11030000
         ICM   R0,3,DS4DEVTK                                            11040000
         CVD   R0,W#DWORD                                               11050000
         ED    W#LINE+28(7),W#DWORD+5                                   11060000
         MVC   W#LINE+60(18),=C'Non-keyed overhead'                     11070000
         MVC   W#LINE+84(7),=X'4020206B202120'                          11080000
         SR    R0,R0                                                    11090000
         ICM   R0,1,DS4DEVI                                             11100000
         CVD   R0,W#DWORD                                               11110000
         ED    W#LINE+84(7),W#DWORD+5                                   11120000
         BAL   R14,PRT                 Print                            11130000
*                                                                       11140000
         MVC   W#LINE+4(19),=C'Last keyed overhead'                     11150000
         MVC   W#LINE+28(7),=X'4020206B202120'                          11160000
         SR    R0,R0                                                    11170000
         ICM   R0,1,DS4DEVL                                             11180000
         CVD   R0,W#DWORD                                               11190000
         ED    W#LINE+28(7),W#DWORD+5                                   11200000
         MVC   W#LINE+60(22),=C'Non-keyed differential'                 11210000
         MVC   W#LINE+84(7),=X'4020206B202120'                          11220000
         SR    R0,R0                                                    11230000
         ICM   R0,1,DS4DEVK                                             11240000
         CVD   R0,W#DWORD                                               11250000
         ED    W#LINE+84(7),W#DWORD+5                                   11260000
         BAL   R14,PRT                 Print                            11270000
*                                                                       11280000
         MVC   W#LINE+4(16),=C'Device tolerance'                        11290000
         MVC   W#LINE+28(7),=X'4020206B202120'                          11300000
         SR    R0,R0                                                    11310000
         ICM   R0,3,DS4DEVTL                                            11320000
         CVD   R0,W#DWORD                                               11330000
         ED    W#LINE+28(7),W#DWORD+5                                   11340000
         MVC   W#LINE+60(15),=C'DSCBs per track'                        11350000
         MVC   W#LINE+84(7),=X'4020206B202120'                          11360000
         SR    R0,R0                                                    11370000
         ICM   R0,1,DS4DEVDT                                            11380000
         CVD   R0,W#DWORD                                               11390000
         ED    W#LINE+84(7),W#DWORD+5                                   11400000
         BAL   R14,PRT                 Print                            11410000
*                                                                       11420000
         MVC   W#LINE+4(20),=C'Dir blocks per track'                    11430000
         MVC   W#LINE+28(7),=X'4020206B202120'                          11440000
         SR    R0,R0                                                    11450000
         ICM   R0,1,DS4DEVDB                                            11460000
         CVD   R0,W#DWORD                                               11470000
         ED    W#LINE+28(7),W#DWORD+5                                   11480000
         BAL   R14,PRT                 Print                            11490000
         DROP  R2                                                       11500000
         BAL   R14,PRT                 Print                            11510000
         L     R14,W#INFO14            Get return address               11520000
         BR    R14                     Return to caller                 11530000
*********************************************************************** 11540000
*                                                                     * 11550000
*        DEBUG INFO                                                   * 11560001
*                                                                     * 11570000
*********************************************************************** 11580000
DBG      DS    0H                                                       11590000
         ST    R14,W#DBGR14            Save linkage                     11600000
         MVC   W#LINE+1(8),=C'WORKAREA'                              05 11610005
         LA    R1,WORKAREA                                           05 11620005
         L     R0,=A(WORKLEN)                                           11630000
         BAL   R14,DMPAD                                             05 11640005
         BAL   R14,PRT                                                  11650000
         MVC   W#LINE+1(8),=C'SAVEAREA'                              05 11660005
         LR    R1,R13                                                   11670000
         LA    R0,W#LEN                                                 11680000
         BAL   R14,DMPAD                                             05 11690005
         L     R14,W#DBGR14            Get return address               11700000
         BR    R14                     Return to caller                 11710000
*********************************************************************** 11720000
*                                                                     * 11730001
*        Format I/O error message                                     * 11740001
*                                                                     * 11750001
*********************************************************************** 11760000
IOERRMS  DS    0H                                                       11770000
         ST    R14,W#ERMS14                                             11780000
         MVC   W#LINE+1(16),=C'I/O error ECB=X'''                       11790000
         UNPK  W#LINE+17(3),WRKHAECB-WRKHAIOB(2,R15)                 05 11800005
         TR    W#LINE+17(2),P#HEXTBL-240                                11810000
         MVC   W#LINE+19(9),=C''' CCHH=X'''                          05 11820005
         UNPK  W#LINE+28(9),W#CCHH(5)                                05 11830005
         TR    W#LINE+28(8),P#HEXTBL-240                                11840000
         MVC   W#LINE+36(11),=C''' Status=X'''                          11850000
         UNPK  W#LINE+47(5),WRKHACCW+4-WRKHAIOB(3,R15)               05 11860005
         TR    W#LINE+47(4),P#HEXTBL-240                                11870000
         MVC   W#LINE+51(9),=C''' Seek=X'''                          05 11880005
         UNPK  W#LINE+60(11),WRKHASEK+3-WRKHAIOB(6,R15)              05 11890005
         TR    W#LINE+60(10),P#HEXTBL-240                            05 11900005
         MVI   W#LINE+70,C''''                                       05 11910005
         L     R1,=A(P#ECBERS)                                       06 11920006
ECBERR1  DS    0H                                                       11930000
         CLC   0(1,R1),WRKHAECB-WRKHAIOB(R15)                        05 11940005
         BE    ECBERR2                                                  11950000
         LA    R1,33(,R1)                                               11960000
         CLI   0(R1),X'FF'                                              11970000
         BNE   ECBERR1                                                  11980000
ECBERR2  DS    0H                                                       11990000
         MVC   W#LINE+72(32),1(R1)                                   05 12000005
         BAL   R14,PRT                                                  12010000
         L     R14,W#ERMS14                                             12020000
         BR    R14                                                      12030000
******************************************************************** 05 12040005
*                                                                  * 05 12050005
*        I/O trace                                                 * 05 12060005
*                                                                  * 05 12070005
******************************************************************** 05 12080005
IOTRACE  DS    0H                                                    05 12090005
         ST    R14,W#IOTR14                                          05 12100005
         MVC   W#LINE+1(16),=C'I/O trace CSW=X'''                    05 12110005
         UNPK  W#LINE+17(9),WRKHACSW-WRKHAIOB(5,R15)                 05 12120005
         TR    W#LINE+17(8),P#HEXTBL-240                             05 12130005
         MVI   W#LINE+25,C' '                                        05 12140005
         UNPK  W#LINE+26(9),WRKHACSW+4-WRKHAIOB(5,R15)               05 12150005
         TR    W#LINE+26(8),P#HEXTBL-240                             05 12160005
         MVC   W#LINE+34(10),=C''' Sense=X'''                        05 12170005
         UNPK  W#LINE+44(5),WRKHASNS-WRKHAIOB(3,R15)                 05 12180005
         TR    W#LINE+44(4),P#HEXTBL-240                             05 12190005
         MVC   W#LINE+48(9),=C''' CCWs=X'''                          05 12200005
         UNPK  W#LINE+57(9),WRKHACCW-WRKHAIOB(5,R15)                 05 12210005
         TR    W#LINE+57(8),P#HEXTBL-240                             05 12220005
         MVC   W#LINE+65(8),=C''' ECB=X'''                           05 12230005
         UNPK  W#LINE+73(9),WRKHAECB-WRKHAIOB(5,R15)                 05 12240005
         TR    W#LINE+73(8),P#HEXTBL-240                             05 12250005
         MVC   W#LINE+81(9),=C''' Seek=X'''                          05 12260005
         UNPK  W#LINE+90(11),WRKHASEK+3-WRKHAIOB(6,R15)              05 12270005
         TR    W#LINE+90(10),P#HEXTBL-240                            05 12280005
         MVI   W#LINE+100,C''''                                      05 12290005
         SR    R0,R0                                                 05 12300005
         ICM   R0,7,WRKHACSW+8                                       05 12310005
         ST    R0,W#DWORD                                            05 12320005
         BAL   R14,PRT                                               05 12330005
IOTRACE1 DS    0H                                                    05 12340005
         MVC   W#LINE+1(6),=C'CCW at'                                05 12350005
         ST    R2,W#DWORD+4                                          05 12360005
         UNPK  W#LINE+8(9),W#DWORD+4(5)                              05 12370005
         TR    W#LINE+8(8),P#HEXTBL-240                              05 12380005
         MVI   W#LINE+16,C'='                                        05 12390005
         UNPK  W#LINE+17(9),0(5,R2)                                  05 12400005
         UNPK  W#LINE+25(9),4(5,R2)                                  05 12410005
         TR    W#LINE+17(16),P#HEXTBL-240                            05 12420005
         MVI   W#LINE+33,C' '                                        05 12430005
         BAL   R14,PRT                                               05 12440005
         SR    R1,R1                                                 05 12450005
         ICM   R1,7,1(R2)                                            05 12460005
         SR    R0,R0                                                 05 12470005
         ICM   R0,3,6(R2)                                            05 12480005
         MVI   W#DMPFLG,W#DMPFLA                                     05 12490005
         BAL   R14,DMP                                               05 12500005
         TM    4(R2),CCWCC                                           05 12510005
         BNO   IOTRACE2                                              05 12520005
         LA    R2,8(,R2)                                             05 12530005
         B     IOTRACE1                                              05 12540005
IOTRACE2 DS    0H                                                    05 12550005
         L     R14,W#IOTR14                                          05 12560005
         BR    R14                                                   05 12570005
*********************************************************************** 12580005
*                                                                     * 12590000
*        INITIALIZATION                                               * 12600001
*                                                                     * 12610000
*********************************************************************** 12620000
INIT     DS    0H                                                       12630000
         ST    R14,W#INIT14            Save linkage                     12640000
         STCK  W#STRTME                                              03 12650003
         MVC   W#OPNLST,P#OPNLST       Prime OPEN list                  12660000
         MVC   W#INDCB,P#INDCB         Prime DCB                        12670000
         MVC   W#OTDCB,P#OTDCB         Prime DCB                        12680000
         MVI   W#LINE,C' '             Clear print line                 12690000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              12700000
         MVC   W#HD1,W#LINE            Clear heading 1                  12710000
         MVI   W#HD1,C'1'              Prime heading 1                  12720000
         MVC   W#HD1TTL,=C'Print Track'                                 12730000
         MVC   W#HD1PG,=C'Page'                                         12740000
         ZAP   W#LNCT,=P'+99'                                           12750000
         ZAP   W#PGCT,=P'+0'                                            12760000
         OPEN  (W#OTDCB,(OUTPUT),W#INDCB,(INPUT)),MF=(E,W#OPNLST)       12770000
         TM    W#OTDCB+48,16           OPEN successful?                 12780000
         BZ    INITER                  No, error                        12790000
         TM    W#INDCB+48,16           OPEN successful?                 12800000
         BZ    INITER                  No, error                        12810000
*                                                                       12820000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            12830000
         MVC   W#LINE+9(L'PGMID),PGMID Move version                     12840000
         BAL   R14,PRT                 Print a line                     12850000
*                                                                       12860000
         MVC   W#LINE+1(5),=C'PARM='   Move parameter info literal      12870000
         CLI   1(R9),0                 Any parameter?                   12880000
         BE    PRMPRT                  No, skip move                    12890000
         LH    R1,0(,R9)               Get parmeter length              12900000
         BCTR  R1,0                    Make machine length              12910000
         EX    R1,PRMMVC               Move parm to print line          12920000
         B     PRMPRT                  Skip move                        12930000
PRMMVC   MVC   W#LINE+6(0),2(R9)       Executed parm move               12940000
PRMPRT   DS    0H                                                       12950000
         BAL   R14,PRT                 Print a line                     12960000
         LH    R2,0(,R9)               Get PARM length                  12970000
         AH    R9,=H'+2'               Skip length                      12980000
         ST    R9,W#PRMBGN             Save PARM start                  12990000
PRMSCN   DS    0H                                                       13000000
         LTR   R2,R2                   End of PARM?                     13010000
         BZ    PRMEND                  Yes, PARM parsed                 13020000
         CLI   0(R9),C','              Seperator?                       13030000
         BNE   PRMCHK                  No, check values                 13040000
         AH    R9,=H'+1'               Skip comma                       13050000
         SH    R2,=H'+1'               Decrement length                 13060000
         B     PRMSCN                  Continue scan                    13070000
PRMCHK   DS    0H                                                       13080000
         CH    R2,=H'+5'               Long enough?                     13090000
         BL    PRMERR                  No, error                        13100000
         CLC   =C'DEBUG',0(R9)         DEBUG?                           13110000
         BE    PRMDBG                  Yes, handle it                   13120000
         B     PRMERR                  Error                            13130000
PRMDBG   DS    0H                                                       13140000
         OI    W#FLG,W#FLGDBG          Set DEBUG                        13150000
         AH    R9,=H'+5'               Skip value                       13160000
         SH    R2,=H'+5'               Decrement length                 13170000
         CH    R2,=H'+9'                                             05 13180005
         BL    PRMSCNC                                               05 13190005
         CLI   0(R9),C','                                            05 13200005
         BE    PRMSCNC                                               05 13210005
         CLC   =C'(IOTRACE)',0(R9)                                   05 13220005
         BNE   PRMSCNC                                               05 13230005
         OI    W#FLG,W#FLGIOT          Set IOTRACE                   05 13240005
         AH    R9,=H'+9'               Skip value                    05 13250005
         SH    R2,=H'+9'               Decrement length              05 13260005
         B     PRMSCNC                 Continue scan                    13270000
PRMSCNC  DS    0H                                                       13280000
         LTR   R2,R2                   End of PARM?                     13290000
         BZ    PRMEND                  Yes, PARM parsed                 13300000
         CLI   0(R9),C','              Delimiter?                       13310000
         BE    PRMSCN                  Yes, handle it                   13320000
PRMERR   DS    0H                                                       13330000
         LR    R1,R9                   Current position                 13340000
         S     R1,W#PRMBGN             Less start                       13350000
         LA    R1,W#LINE+6(R1)         Set location of error            13360000
         MVI   0(R1),C'*'              Mark where error is              13370000
         BAL   R14,PRT                 Print a line                     13380000
         MVC   W#LINE(19),=C' Parameters invalid'                       13390000
         BAL   R14,PRT                 Print a line                     13400000
         B     INITER                  Error                            13410000
PRMEND   DS    0H                                                       13420000
         SR    R15,R15                 Set successful return code       13430000
         B     INITXT                  Go exit                          13440000
INITER   DS    0H                                                       13450000
         LA    R15,8                   Set error return code            13460000
INITXT   DS    0H                                                       13470000
         L     R14,W#INIT14            Get return address               13480000
         BR    R14                     Return to caller                 13490000
******************************************************************** 02 13500002
*                                                                  * 02 13510002
* Input: R0:R1=Clock                                               * 02 13520002
*                                                                  * 02 13530002
******************************************************************** 02 13540002
FCLK     DS    0H                                                    02 13550002
         ST    R14,W#FCLR14          Save return address             02 13560002
         LR    R14,R0                Save high half of clock         02 13570002
         LR    R15,R1                Save low half of clock          02 13580002
*        Convert date                                                02 13590002
         SRDL  R14,25                DIVIDE TO GET DATE              02 13600002
         D     R14,=F'+10546875'      IN MICRO-SECONDS               02 13610002
         LA    R15,1(,R15)           DATE IS 1 BASED                 02 13620002
         SLL   R15,2                 MULTIPLY BY 4                   02 13630002
         LR    R0,R14                SAVE FOR LATER USE              02 13640002
         SLR   R14,R14               SET UP FOR DIVIDE               02 13650002
         D     R14,=F'+1461'         DIVIDE BY 365.25 * 100          02 13660002
         SRL   R14,2                 DIVIDE BY 4                     02 13670002
         LTR   R15,R15               YEAR ZERO ?                     02 13680002
         BNZ   FCLKA                 NO, CONTINUE                    02 13690002
         BCTR  R14,0                 DROP DAYS                       02 13700002
         B     FCLKB                 GO CONVERT DATE                 02 13710002
FCLKA    DS    0H                                                    02 13720002
         LA    R14,1(,R14)           ADD 1 TO DAYS                   02 13730002
         MH    R15,=H'+1000'         SHIFT YEAR (YY000)              02 13740002
FCLKB    DS    0H                                                    02 13750002
         ALR   R15,R14               ADD YEAR TO JULIAN DAYS         02 13760002
         CVD   R15,W#DWORD           SAVE JULIAN DATE                02 13770002
*        Convert time                                                02 13780002
         SLL   R1,7                  DUMP DATE                       02 13790002
         SRDL  R0,19                 DROP BELOW SECONDS              02 13800002
         D     R0,=A(1000000)        DIVIDE BY # MICRO SEC/SEC       02 13810002
         LR    R15,R0                SAVE MICRO SECONDS              02 13820002
         SLR   R0,R0                 CLEAR REMAINDER                 02 13830002
         D     R0,=A(60)             GET SECONDS                     02 13840002
         LR    R14,R0                SAVE SECONDS                    02 13850002
         SLR   R0,R0                 CLEAR REMAINDER                 02 13860002
         D     R0,=A(60)             GET MINUTES                     02 13870002
         MH    R0,=H'+100'           SHIFT SECONDS (MM00)            02 13880002
         ALR   R0,R14                ADD IN SECONDS                  02 13890002
         MH    R1,=H'+10000'         SHIFT HOURS (HH0000)            02 13900002
         ALR   R0,R1                 ADD TO GET HHMMSS               02 13910002
         CVD   R0,W#DWORD            SAVE TIME                       02 13920002
         MVC   W#FCLK1,=X'402020207A20207A2120'                      02 13930006
         ED    W#FCLK1,W#DWORD+4     EDIT TIME                       02 13940002
         CVD   R15,W#DWORD           CONVERT TIME                    02 13950002
         OI    W#DWORD+7,X'0F'       SIGN IT                         02 13960002
         UNPK  W#FCLK2,W#DWORD+4(4)  GET TIME TO RIGHT OF DECIMAL    02 13970002
         MVI   W#FCLK2,C'.'          SET DECIMAL POINT               02 13980002
         L     R14,W#FCLR14          Return address                  02 13990002
         BR    R14                   Exit                            02 14000002
*********************************************************************** 14010000
*                                                                     * 14020000
*        WRITE PRINT LINE                                             * 14030001
*                                                                     * 14040000
*********************************************************************** 14050000
PRT      DS    0H                                                       14060000
         ST    R14,W#PRTR14                                             14070000
         CP    W#LNCT,=P'+60'          End of page                      14080000
         BL    PRTCHK                  No, check if line fit in page    14090000
PRTHDRS  DS    0H                                                       14100000
*                                                                       14110006
         ZAP   W#JLWK13,=P'+1'         Prime work                       14120006
         ZAP   W#JLWK12,=P'+31'        Prime Dec                        14130006
         ZAP   W#JLWK11,=P'+30'        Prime Nov                        14140006
         ZAP   W#JLWK10,=P'+31'        Prime Oct                        14150006
         ZAP   W#JLWK09,=P'+30'        Prime Sep                        14160006
         ZAP   W#JLWK08,=P'+31'        Prime Aug                        14170006
         ZAP   W#JLWK07,=P'+31'        Prime Jul                        14180006
         ZAP   W#JLWK06,=P'+30'        Prime Jun                        14190006
         ZAP   W#JLWK05,=P'+31'        Prime May                        14200006
         ZAP   W#JLWK04,=P'+30'        Prime Apr                        14210006
         ZAP   W#JLWK03,=P'+31'        Prime Mar                        14220006
         ZAP   W#JLWK02,=P'+28'        Prime Feb                        14230006
         ZAP   W#JLWK01,=P'+31'        Prime Jan                        14240006
         TIME  BIN                     Get current date and time        14250006
         ST    R1,W#CURDTE             Save date                        14260006
         SRDL  R0,32                   Get double word time             14270006
         D     R0,=F'+6000'            Get minutes                      14280006
         LR    R15,R0                  Save secs tens and hundreths     14290006
         SLR   R0,R0                   Clear                            14300006
         D     R0,=F'+60'              Get hours / mins                 14310006
         MH    R0,=H'+10000'           Get minutes                      14320006
         AR    R15,R0                  Add to get MM:SS.TH              14330006
         M     R0,=F'+1000000'         Get hours                        14340006
         AR    R1,R15                  Get HH:MM:SS.TH                  14350006
         CVD   R1,W#DWORD              Get time to decimal              14360006
         MVC   W#TIMWRK,=X'402021207A20207A20204B2020'                  14370006
         ED    W#TIMWRK,W#DWORD+3      Edit time                        14380006
         MVC   W#HD1TOD,W#TIMWRK+2     Move time                        14390006
         ZAP   W#JLWK1,W#CURDTE+2(2)   Get julian date                  14400006
         ZAP   W#JLWK2,=P'+365'        Days/yr = 365                    14410006
         ZAP   W#JLWK02,=P'+28'        Feb = 28                         14420006
         MVO   W#DWORD,W#CURDTE+1(1)   Sign year                        14430006
         DP    W#DWORD,=P'+4'          Divide by 4                      14440006
         CP    W#DWORD+7(1),=P'+0'     Is it a leap year?               14450006
         BNZ   PRTHDR2                 No                               14460006
         ZAP   W#JLWK2,=P'+366'        Days/yr = 366                    14470006
         ZAP   W#JLWK02,=P'+29'        Feb = 29                         14480006
PRTHDR2  DS    0H                                                       14490006
         LA    R1,W#JLWK01             Point to Jan                     14500006
         SLR   R14,R14                 Set counter                      14510006
PRTHDR4  DS    0H                                                       14520006
         SP    W#JLWK1,0(2,R1)         Months displacement              14530006
         BNP   PRTHDR6                 If equal or less                 14540006
         AH    R1,=H'-2'               Point to next month              14550006
         AH    R14,=H'+3'              Up index                         14560006
         B     PRTHDR4                 Loop                             14570006
PRTHDR6  DS    0H                                                       14580006
         AP    W#JLWK1,0(2,R1)         Add days of month                14590006
         LA    R14,P#JULTBL(R14)       Address month                    14600006
         MVC   W#HD1DTE(3),0(R14)      Move month                       14610006
         OI    W#JLWK1+3,X'0F'         Display sign                     14620006
         UNPK  W#HD1DTE+4(2),W#JLWK1   Get days                         14630006
         CLI   W#HD1DTE+4,C'0'         First 9 days?                    14640006
         LA    R1,W#HD1DTE+6           Set pointer                      14650006
         BNE   PRTHDR7                 No                               14660006
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 Move units digit                14670006
         BCTR  R1,0                    Drop pointer                     14680006
PRTHDR7  DS    0H                                                       14690006
         MVC   0(4,R1),=C', 19'        Set up constant                  14700006
         TM    W#CURDTE,1              Year 2000?                       14710006
         BNO   PRTHDR8                 No, continue                     14720006
         MVC   2(2,R1),=C'20'          Year 2000                        14730006
PRTHDR8  DS    0H                                                       14740006
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     14750006
         MVC   4(2,R1),W#DWORD         Get year                         14760006
         AP    W#PGCT,=P'+1'           Count pages                      14770000
         MVC   W#HD1PG#,=X'40202120'   Page count mask                  14780000
         ED    W#HD1PG#,W#PGCT         Edit page count                  14790000
         PUT   W#OTDCB,W#HD1           Print heading 1                  14800000
         ZAP   W#LNCT,=P'+1'           Init line count                  14810000
         MVI   W#LINE,C'0'             Skip after heading               14820000
*                                                                       14830006
PRTCHK   DS    0H                                                       14840000
         CLI   W#LINE,C'+'             Overprint?                       14850000
         BE    PRTLINE                 Yes, don't count                 14860000
         CLI   W#LINE,C'1'             New line?                        14870000
         BE    PRTHDRS                 Yes, print header                14880000
         CLI   W#LINE,C' '             Write after advancing 1?         14890000
         BE    PRTLINE1                Yes, go check if fit             14900000
         CLI   W#LINE,C'0'             Write after advancing 2?         14910000
         BE    PRTLINE2                Yes, go check if fit             14920000
         CLI   W#LINE,C'-'             Write after advancing 3?         14930000
         BE    PRTLINE3                Yes, go check if fit             14940000
         B     PRTLINE                 Ignore any other ctl chars       14950000
PRTLINE1 DS    0H                                                       14960000
         AP    W#LNCT,=P'+1'           Add to line count                14970000
         B     PRTVFY                  Go see if it will fit            14980000
PRTLINE2 DS    0H                                                       14990000
         AP    W#LNCT,=P'+2'           Add to line count                15000000
         B     PRTVFY                  Go see if it will fit            15010000
PRTLINE3 DS    0H                                                       15020000
         AP    W#LNCT,=P'+3'           Add to line count                15030000
PRTVFY   DS    0H                                                       15040000
         CP    W#LNCT,=P'+60'          Overflow?                        15050000
         BH    PRTHDRS                 Yes, force header                15060000
PRTLINE  DS    0H                                                       15070000
         PUT   W#OTDCB,W#LINE          Print a line                     15080000
         MVI   W#LINE,C' '             Clear print line                 15090000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              15100000
         L     R14,W#PRTR14                                             15110000
         BR    R14                     Return to caller                 15120000
*********************************************************************** 15130000
*                                                                     * 15140000
*        DUMP WITH ADDRESS OF STORAGE DUMPED                          * 15150000
*                                                                     * 15160000
*********************************************************************** 15170000
DMPAD    DS    0H                                                       15180000
         ST    R14,W#DMPADR                                             15190000
         STM   R0,R15,W#DMPRGS         SAVE REGISTERS                   15200000
         ST    R1,W#DMPOFF                                              15210000
         LA    R2,W#LINE+L'W#LINE-1                                     15220000
         LA    R0,L'W#LINE-1                                            15230000
DMPAD10  DS    0H                                                       15240000
         CLI   0(R2),C' '                                               15250000
         BNE   DMPAD20                                                  15260000
         BCTR  R2,0                                                     15270000
         BCT   R0,DMPAD10                                               15280000
DMPAD20  DS    0H                                                       15290000
         MVC   2(2,R2),=C'at'                                           15300000
         AH    R2,=H'+5'               OUTPUT AREA ADDRESS              15310000
         LA    R1,W#DMPOFF             ADDRESS OF OFFSET TO DUMP        15320000
         LA    R15,4                   CONVERT 4 BYTES                  15330000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            15340000
         MVC   1(6,R2),=C'Length'                                    05 15350005
         UNPK  8(9,R2),W#DMPRGS(5)                                   05 15360005
         TR    8(8,R2),P#HEXTBL-240                                  05 15370005
         MVI   16(R2),C' '                                           05 15380005
         BAL   R14,PRT                 PRINT ADDRESS OF DATA            15390000
         LM    R0,R15,W#DMPRGS         SAVE REGISTERS                   15400000
         MVI   W#DMPFLG,W#DMPFLA                                     05 15410005
         BAL   R14,DMP                 DUMP STORAGE                     15420000
         L     R14,W#DMPADR                                             15430000
         BR    R14                     RETURN TO CALLER                 15440000
*********************************************************************** 15450000
*                                                                     * 15460000
*        DUMP DATA                                                    * 15470000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 15480000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 15490000
*                                                                     * 15500000
*********************************************************************** 15510000
DMP      DS    0H                                                       15520000
         STM   R0,R15,W#DMPRGS         Save registers                   15530000
         LR    R3,R1                   Get address to dump              15540000
         LR    R4,R0                   Get length                       15550000
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump             15560000
         NI    W#DMPFLG,255-W#DMPDUP                                 05 15570005
         OI    W#DMPFLG,W#DMP1ST       First line                    05 15580005
DMPDMPLP DS    0H                                                       15590000
         LTR   R4,R4                   Any data to dump?                15600000
         BZ    DMPHEXXT                No, all done                  05 15610005
         TM    W#DMPFLG,W#DMP1ST       First line?                      15620000
         BO    DMPALIN                 Yes, can't have same as above    15630000
         LA    R0,32                   Default length                   15640000
         CR    R4,R0                   Length longer than 32?           15650000
         BNH   DMPDUPCK                No, were at last line            15660000
         LR    R14,R3                  Get current input area           15670000
         SR    R14,R0                  Back to previous area            15680000
         CLC   0(32,R14),0(R3)         Duplicate of previous line       15690000
         BNE   DMPDUPCK                No, do lines same as             15700000
         SR    R4,R0                   Reduce length to do              15710000
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?           15720000
         BO    DMPNXTLN                Yes, we have first offset        15730000
         L     R14,W#DMPOFF            Get current offset               15740000
         ST    R14,W#DUP1ST            Save as first offset             15750000
         OI    W#DMPFLG,W#DMPDUP       Set duplicate                    15760000
         B     DMPNXTLN                Continue                         15770000
DMPDUPCK DS    0H                                                       15780000
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?           15790000
         BNO   DMPALIN                 No, no duplicate to report       15800000
         L     R1,W#DMPOFF             Get current offset               15810001
         SR    R1,R0                   Get last duplicate offset        15820001
         C     R1,W#DUP1ST             We have only 1 line as dup       15830001
         BNE   DMPDUP                  No, greater than one ine         15840001
         ST    R1,W#DMPOFF             Update offset back to single dup 15850001
         SR    R3,R0                   Dump line instead as same as     15860001
         AR    R4,R0                   Increase length                  15870001
         NI    W#DMPFLG,255-W#DMPDUP   Reset duplicate in progress      15880001
         B     DMPALIN                 Go dump this line                15890001
DMPDUP   DS    0H                                                       15900001
         MVC   W#LINE+10(5),=C'Lines'  Move literal                     15910001
         LA    R2,W#LINE+16            Output area address              15920001
         LA    R1,W#DUP1ST+1           Address of offset to dump        15930001
         LA    R15,3                   Convert 6 bytes                  15940001
         BAL   R14,DMPDSP              Convert it to display            15950000
         MVI   W#LINE+22,C'-'          Thru literal                     15960001
         L     R1,W#DMPOFF             Get current offset               15970000
         S     R1,=A(32)               Get last duplicate offset        15980000
         ST    R1,W#DUP1ST             Save for dumping                 15990000
         LA    R2,W#LINE+23            Output area address              16000001
         LA    R1,W#DUP1ST+1           Address of offset to dump        16010001
         LA    R15,3                   Convert 4 bytes                  16020001
         BAL   R14,DMPDSP              Convert it to display            16030000
         MVC   W#LINE+30(13),=C'same as above' move literal             16040001
         BAL   R14,PRT                 Print a line                     16050000
         NI    W#DMPFLG,255-W#DMPDUP   Reset duplicate in progress      16060000
DMPALIN  DS    0H                                                       16070000
         TM    W#DMPFLG,W#DMPFLA                                     05 16080005
         BNO   DMPALINA                                              05 16090005
         ST    R3,W#DWORD                                            05 16100005
         LA    R2,W#LINE+2                                           05 16110005
         LA    R1,W#DWORD                                            05 16120005
         LA    R15,4                                                 05 16130005
         BAL   R14,DMPDSP              Convert it to display         05 16140005
         LA    R2,W#LINE+13            Output area address           05 16150005
         B     DMPALINB                                              05 16160005
DMPALINA DS    0H                                                    05 16170005
         LA    R2,W#LINE+4             Output area address           05 16180005
DMPALINB DS    0H                                                    05 16190005
         LA    R1,W#DMPOFF+2           Address of offset to dump     05 16200005
         LA    R15,2                   Convert 4 bytes               05 16210005
         CLI   W#DMPOFF+1,0                                          05 16220005
         BE    DMPALIN1                                              05 16230005
         SH    R2,=H'+2'               Output area address           05 16240005
         LA    R1,W#DMPOFF+1           Address of offset to dump     05 16250005
         LA    R15,3                   Convert 6 bytes               05 16260005
DMPALIN1 DS    0H                                                       16270001
         BAL   R14,DMPDSP              Convert it to display            16280000
         LA    R2,2(,R2)               Skip 1 between offset & data     16290000
         LR    R1,R3                   Address of data                  16300000
         LA    R5,32                   Default length                   16310000
         CR    R4,R5                   Length longer than 32 ?          16320000
         BH    DMPDODMP                Yes, use 32                      16330000
         LR    R5,R4                   Use what is left                 16340000
DMPDODMP DS    0H                                                       16350000
         SR    R4,R5                   Reduce amount to do              16360000
         MVI   W#LINE+92,C'*'          Box in display portion           16370001
         BCTR  R5,0                    Make zero based                  16380000
         EX    R5,DMPMVC               Do move                          16390000
         L     R15,=A(P#DMPTBL)                                      06 16400006
         EX    R5,DMPTR                Translate out bad stuff          16410000
         LA    R5,1(,R5)               Restore length                   16420000
         MVI   W#LINE+125,C'*'         Complete box                     16430001
DMPDMPHX DS    0H                                                       16440000
         LA    R15,4                   4 bytes to process               16450000
         CR    R5,R15                  Length longer than 4?            16460000
         BH    DMPDMPIT                Yes, dump 4 bytes                16470000
         LR    R15,R5                  Use length left                  16480000
DMPDMPIT DS    0H                                                       16490000
         SR    R5,R15                  Reduce amount to do              16500000
         BAL   R14,DMPDSP              Convert data                     16510000
         LA    R2,1(,R2)               Skip 1 byte                      16520000
         LA    R0,W#LINE+55            Halfway point address         05 16530005
         CR    R0,R2                   At halfway point?                16540000
         BNE   DMPDMPNX                No, continue                     16550000
         LA    R2,1(,R2)               Skip 1 byte                      16560000
DMPDMPNX DS    0H                                                       16570000
         LTR   R5,R5                   Any left to do ?                 16580000
         BH    DMPDMPHX                Yes, go do it                    16590000
         BAL   R14,PRT                 Print a line                     16600000
DMPNXTLN DS    0H                                                       16610000
         L     R1,W#DMPOFF             Get offset in record             16620000
         LA    R1,32(,R1)              Add in length we will dump       16630000
         ST    R1,W#DMPOFF             Save offset in record            16640000
         LA    R3,32(,R3)              Next input area                  16650000
         NI    W#DMPFLG,255-W#DMP1ST   Not first line                   16660000
         B     DMPDMPLP                Loop thru until done             16670000
DMPHEXXT DS    0H                                                       16680000
         MVI   W#DMPFLG,0                                            05 16690005
         LM    R0,R15,W#DMPRGS         Restore callers regs             16700000
         BR    R14                     Exit . . .                       16710000
DMPMVC   MVC   W#LINE+93(0),0(R1)      <<< executed >>>                 16720001
DMPTR    TR    W#LINE+93(0),0(R15)     <<< executed >>>              06 16730006
*                                                                       16740000
*        Convert hex data to display                                    16750000
*                                                                       16760000
DMPDSP   DS    0H                                                       16770000
         UNPK  0(1,R2),0(1,R1)         Get first hex byte               16780000
         NI    0(R2),X'0F'             Remove zone                      16790000
         MVC   1(1,R2),0(R1)           Move second hex byte             16800000
         NI    1(R2),X'0F'             Remove its zone also             16810000
         TR    0(2,R2),=C'0123456789ABCDEF' Translate to hex            16820000
         LA    R2,2(,R2)               Point to next output area        16830000
         LA    R1,1(,R1)               Point to next input area         16840000
         BCT   R15,DMPDSP              Loop thru data                   16850000
         BR    R14                     Exit                             16860000
*                                                                       16870001
         DC    (((((*-PRTTRK)/32)+1)*32)-(*-PRTTRK))X'00'               16880001
*********************************************************************** 16890000
*                                                                     * 16900000
*        Constants                                                    * 16910001
*                                                                     * 16920000
*********************************************************************** 16930000
*                                                                    05 16940005
         LTORG ,                                                     05 16950005
*                                                                    05 16960005
P#HEXTBL DC    C'0123456789ABCDEF'                                      16970000
*                                                                       16980000
P#JULTBL DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  16990000
*                                                                       17000000
P#OPNLSB OPEN  (0,(INPUT),0,(OUTPUT)),MF=L                              17010000
P#OPNLST EQU   P#OPNLSB,*-P#OPNLSB                                      17020000
*                                                                       17030000
P#INDCBB DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=EOF                 17040000
P#INDCB  EQU   P#INDCBB,*-P#INDCBB                                      17050000
*                                                                       17060000
P#OTDCBB DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X17070000
               RECFM=FBA,LRECL=133                                      17080000
P#OTDCB  EQU   P#OTDCBB,*-P#OTDCBB                                      17090000
*                                                                       17100000
P#DMPTBL DC    CL256' '                                              05 17110005
         ORG   P#DMPTBL+X'4A' Cent                                   05 17120005
         DC    X'4A4B4C4D4E4F50'                                     05 17130005
         ORG   P#DMPTBL+X'5A' exclamation                            05 17140005
         DC    X'5A5B5C5D5E5F6061'                                   05 17150005
         ORG   P#DMPTBL+X'6A'                                        05 17160005
         DC    X'6A6B6C6D6E6F'                                       05 17170005
         ORG   P#DMPTBL+X'7A'                                        05 17180005
         DC    X'7A7B7C7D7E7F'                                       05 17190005
         ORG   P#DMPTBL+C'a'                                         05 17200005
         DC    C'abcdefghi'                                          05 17210005
         ORG   P#DMPTBL+C'j'                                         05 17220005
         DC    C'jklmnopqr'                                          05 17230005
         ORG   P#DMPTBL+C's'                                         05 17240005
         DC    C'stuvwxyz'                                           05 17250005
         ORG   P#DMPTBL+C'A'                                         05 17260005
         DC    C'ABCDEFGHI'                                          05 17270005
         ORG   P#DMPTBL+C'J'                                         05 17280005
         DC    C'JKLMNOPQR'                                          05 17290005
         ORG   P#DMPTBL+C'S'                                         05 17300005
         DC    C'STUVWXYZ'                                           05 17310005
         ORG   P#DMPTBL+C'0'                                         05 17320005
         DC    C'0123456789'                                         05 17330005
         ORG   ,                                                     05 17340005
*                                                                    06 17350006
*        Device name table                                           06 17360006
*                                                                    06 17370006
*              Device      Device                                    06 17380006
*                Type      Name                                      06 17390006
P#DASDNM DC    AL1(01),CL7'2311   '                                  06 17400006
         DC    AL1(02),CL7'2301   '                                  06 17410006
         DC    AL1(03),CL7'2303   '                                  06 17420006
         DC    AL1(04),CL7'9345   '                                  06 17430006
         DC    AL1(05),CL7'2321   '                                  06 17440006
         DC    AL1(06),CL7'2305-1 '                                  06 17450006
         DC    AL1(07),CL7'2305-2 '                                  06 17460006
         DC    AL1(08),CL7'2314   '                                  06 17470006
         DC    AL1(09),CL7'3330-1 '                                  06 17480006
         DC    AL1(10),CL7'3340   '                                  06 17490006
         DC    AL1(11),CL7'3350   '                                  06 17500006
         DC    AL1(12),CL7'3375   '                                  06 17510006
         DC    AL1(13),CL7'3330-11'                                  06 17520006
         DC    AL1(14),CL7'3380   '                                  06 17530006
         DC    AL1(15),CL7'3390   '                                  06 17540006
P#DASD#  EQU   (*-P#DASDNM)/8        Number of device name entries   06 17550006
*                                                                    06 17560006
*        3390 model table                                            06 17570006
*                                                                    06 17580006
*                Cyls       Model                                    06 17590006
*                                                                    06 17600006
P#3390NM DC    F'01113',CL4'-1   '                                      17610006
         DC    F'02226',CL4'-2   '                                      17620006
         DC    F'03339',CL4'-3   '                                      17630006
         DC    F'10017',CL4'-9   '                                      17640006
         DC    F'32760',CL4'-27  '                                      17650006
         DC    F'65520',CL4'-54  '                                      17660006
         DC    X'FF'                                                    17670006
*                                                                    06 17680006
*        ECB POST code table                                         06 17690006
*                                                                    06 17700006
P#ECBERS DC    X'41',CL32'Permanent error'                           06 17710006
         DC    X'42',CL32'Extent violation'                          06 17720006
         DC    X'48',CL32'I/O purged'                                06 17730006
         DC    X'4F',CL32'Error recovery entered'                    06 17740006
         DC    X'EF',CL32'End of file detected'                      06 17750006
         DC    X'FF',CL32'Unknown error'                             06 17760006
*                                                                    06 17770006
*        RDTRK error table                                           06 17780006
*                                                                    06 17790006
P#RDERRS DC    X'00000001',CL32'Unauthorized'                        06 17800006
         DC    X'00000002',CL32'Invalid work area'                   06 17810006
         DC    X'00000003',CL32'Invalid function call'               06 17820006
         DC    X'00000101',CL32'DEVTYPE failed'                      06 17830006
         DC    X'00000103',CL32'Read format 4 failed'                06 17840006
         DC    X'00000104',CL32'CC invalid'                          06 17850006
         DC    X'00000105',CL32'HH error'                            06 17860006
         DC    X'00000201',CL32'OPEN not completed'                  06 17870006
         DC    X'00000202',CL32'CC invalid'                          06 17880006
         DC    X'00000203',CL32'HH error'                            06 17890006
         DC    X'00000204',CL32'Read home address failed'            06 17900006
         DC    X'00000205',CL32'Read count failed'                   06 17910006
         DC    X'00000301',CL32'CLOSE of unopened DCB'               06 17920006
         DC    X'FF000000',CL32'Unknown error'                       06 17930006
*                                                                    05 17940005
         DC    (((((*-PRTTRK)/32)+1)*32)-(*-PRTTRK))X'00'               17950001
*********************************************************************** 17960000
*                                                                     * 17970000
*        Work Area                                                    * 17980001
*                                                                     * 17990000
*********************************************************************** 18000000
W#       DSECT                                                          18010000
W#SA     DS    18A                                                      18020000
W#DWORD  DS    D                                                        18030000
W#STRTME DS    D                                                     03 18040003
W#BGNTME DS    D                                                     02 18050002
W#ENDTME DS    D                                                     02 18060002
W#STPTME DS    D                                                     06 18070006
W#DMPRGS DS    16A                                                      18080000
W#DMPOFF DS    A                                                        18090000
W#DUP1ST DS    A                                                        18100000
W#DMPADR DS    A                                                        18110000
W#DMPFLG DS    X                                                        18120000
W#DMP1ST EQU   X'80'                                                    18130000
W#DMPDUP EQU   X'40'                                                    18140000
W#DMPFLA EQU   X'20'                                                 05 18150005
W#FLG    DS    X                                                        18160000
W#FLGDBG EQU   X'80'                                                    18170000
W#FLG1AD EQU   X'40'                                                    18180000
W#FLG2AD EQU   X'20'                                                    18190000
W#FLGDDN EQU   X'10'                                                    18200000
W#FLGVER EQU   X'08'                                                 02 18210002
W#FLGMAP EQU   X'04'                                                 05 18220005
W#FLGIOT EQU   X'02'                                                 05 18230005
W#PARM   DS    4A                                                       18240000
W#DDN    DS    CL8                                                      18250000
W#EPA    DS    A                                                        18260000
W#CCHH   DS    A                                                        18270000
W#CCHHB  DS    A                                                        18280000
W#CCHHE  DS    A                                                        18290000
W#TRKFMT DS    A                                                        18300001
W#CSCNT  DS    A                                                     06 18310006
W#TRKTOT DS    A                                                     06 18320006
W#IOTOT  DS    A                                                     06 18330006
W#PRMBGN DS    A                                                        18340000
W#INIT14 DS    A                                                        18350000
W#PRTR14 DS    A                                                        18360000
W#PARP14 DS    A                                                        18370000
W#INFO14 DS    A                                                        18380000
W#DBGR14 DS    A                                                        18390000
W#FMTR14 DS    A                                                        18400000
W#VERR14 DS    A                                                     02 18410002
W#MAPR14 DS    A                                                     05 18420005
W#CHKR14 DS    A                                                     02 18430002
W#FCLR14 DS    A                                                     02 18440002
W#ERMS14 DS    A                                                        18450000
W#IOTR14 DS    A                                                     05 18460005
W#INREC  DS    CL80                                                     18470000
W#FCLK1  DC    CL10' '               HH:MM:SS                        02 18480002
W#FCLK2  DC    CL7' '                .NNNNNN                         02 18490002
W#FCLK   EQU   W#FCLK1+2,15          Formatted clock                 02 18500002
W#LINE   DS    CL133                                                    18510000
W#CURDTE DS    A                                                        18520000
W#JLWK1  DS    A                                                        18530000
W#JLWK2  DS    P'+365'                                                  18540000
W#JLWK13 DS    P'+01'                                                   18550000
W#JLWK12 DS    P'+31'                                                   18560000
W#JLWK11 DS    P'+30'                                                   18570000
W#JLWK10 DS    P'+31'                                                   18580000
W#JLWK09 DS    P'+30'                                                   18590000
W#JLWK08 DS    P'+31'                                                   18600000
W#JLWK07 DS    P'+31'                                                   18610000
W#JLWK06 DS    P'+30'                                                   18620000
W#JLWK05 DS    P'+31'                                                   18630000
W#JLWK04 DS    P'+30'                                                   18640000
W#JLWK03 DS    P'+31'                                                   18650000
W#JLWK02 DS    P'+28'                                                   18660000
W#JLWK01 DS    P'+31'                                                   18670000
W#TIMWRK DS    X'402021204B20204B20204B2020'                            18680000
W#LNCT   DS    PL2'+99'                                                 18690000
W#PGCT   DS    PL2'+0'                                                  18700000
W#HD1    DS    CL133                                                    18710000
         ORG   W#HD1+1                                                  18720000
W#HD1DTE DS    C'            '                                          18730000
         DS    C' '                                                     18740000
W#HD1TOD DS    C'HH:MM:SS.TH'                                           18750006
         ORG   W#HD1+66-(11/2)                                          18760000
W#HD1TTL DS    C'Print Track'                                           18770000
         ORG   W#HD1+L'W#HD1-8                                          18780000
W#HD1PG  DS    C'Page'                                                  18790000
W#HD1PG# DS    C' 123'                                                  18800000
         DS    0D                                                       18810000
W#OPNLST DS    XL(L'P#OPNLST)                                           18820000
         DS    0D                                                       18830000
W#INDCB  DS    XL(L'P#INDCB)                                            18840000
         DS    0D                                                       18850000
W#OTDCB  DS    XL(L'P#OTDCB)                                            18860000
         DS    0D                                                       18870000
         DS    (((((*-W#)/256)+1)*256)-(*-W#))X                         18880000
W#LEN    EQU   *-W#                                                     18890000
*********************************************************************** 18900000
*        Read Track Work Area                                         * 18910001
*********************************************************************** 18920000
         RDTRKWA                                                        18930000
*                                                                       18940000
*                                                                       18950000
*                                                                       18960000
CCWDC    EQU   X'80'                   Data chaining                    18970000
CCWCC    EQU   X'40'                   Command chaining                 18980000
CCWSLI   EQU   X'20'                   Suppress incorrect length        18990000
CCWSKIP  EQU   X'10'                   Suppress data transfer           19000000
CCWPCI   EQU   X'08'                   Program controlled interrupt     19010000
CCWIDA   EQU   X'04'                   Channel indirect addressing      19020000
*                                                                       19030000
*                                                                       19040000
*                                                                       19050000
DSCBFMT4 DSECT ,                                                        19060000
         IECSDSL1 4                                                     19070000
*                                                                       19080000
*                                                                       19090000
*                                                                       19100000
R0       EQU   0                                                        19110000
R1       EQU   1                                                        19120000
R2       EQU   2                                                        19130000
R3       EQU   3                                                        19140000
R4       EQU   4                                                        19150000
R5       EQU   5                                                        19160000
R6       EQU   6                                                        19170000
R7       EQU   7                                                        19180000
R8       EQU   8                                                        19190000
R9       EQU   9                                                        19200000
R10      EQU   10                                                       19210000
R11      EQU   11                                                       19220000
R12      EQU   12                                                       19230000
R13      EQU   13                                                       19240000
R14      EQU   14                                                       19250000
R15      EQU   15                                                       19260000
         END                                                            19270000
