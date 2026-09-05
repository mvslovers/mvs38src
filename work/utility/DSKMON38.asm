         MACRO                                                          00010001
&LBL     $TRC  &ID                                                      00020001
&LBL     DS    0H                                                       00030001
         TM    W#FLG,W#FLGDBG                                           00040001
         BNO   TRC&SYSNDX                                               00050001
         STM   R0,R15,W#TRCREG                                          00060001
         AIF   (T'&ID EQ 'O').TRCLBL                                    00070001
         AIF   ('&ID' EQ '0H').TRCLBL                                   00080001
         LA    R9,=CL8'&ID'                                             00090001
         AGO   .TRCCAL                                                  00100001
.TRCLBL  ANOP  ,                                                        00110001
         LA    R9,=CL8'&LBL'                                            00120001
.TRCCAL  ANOP  ,                                                        00130001
         BAL   R8,TRC                                                   00140001
         LM    R0,R15,W#TRCREG                                          00150001
TRC&SYSNDX DS  0H                                                       00160001
         MEND                                                           00170001
         MACRO                                                          00180000
&LBL     MSG   &MSG,&MF=E,&MSGNO=0                                      00190000
         LCLA  &LEN                                                     00200000
         AIF   ('&MF' EQ 'L').LIST                                      00210000
         AIF   ('&MF(1)' EQ 'E').EXEC                                   00220000
         MNOTE 8,'MESSAGE MF INVALID'                                   00230000
         MEXIT                                                          00240000
.EXEC    ANOP                                                           00250000
         AIF   (K'&MF EQ 1).MFE                                         00260000
.MFELBL  ANOP                                                           00270000
         AIF   (T'&LBL EQ 'O').NOLB1                                    00280000
&LBL     DS    0H                                                       00290000
.NOLB1   ANOP                                                           00300000
         LA    R15,L'&MF(2).-1         Length of message                00310000
         LA    R1,&MF(2)               Message address                  00320000
         LA    R0,&MSGNO               Mesage number                    00330000
         BAL   R14,MSG                 Send message                     00340000
         MEXIT                                                          00350000
.MFE     ANOP                                                           00360000
         AIF   (K'&MSG LT 3).NOMSG                                      00370000
&LEN     SETA  K'&MSG-2                                                 00380000
         AIF   (T'&LBL EQ 'O').NOLB2                                    00390000
&LBL     DS    0H                                                       00400000
.NOLB2   ANOP                                                           00410000
         LA    R15,&LEN-1              Length of message                00420000
         LA    R1,=C&MSG               Message address                  00430000
         LA    R0,&MSGNO               Mesage number                    00440000
         BAL   R14,MSG                 Send message                     00450000
         MEXIT                                                          00460000
.LIST    ANOP                                                           00470000
         AIF   (K'&MSG LT 3).NOMSG                                      00480000
&LBL     DC    C&MSG                                                    00490000
         MEXIT                                                          00500000
.NOMSG   ANOP                                                           00510000
         MNOTE 8,'MESSAGE LENGTH INVALID'                               00520000
         MEND                                                           00530000
*                                                                       00540000
*                                                                       00550000
*                                                                       00560000
         MACRO ,                                                        00570000
&NM      DIAG  &R1,&R3,&I2                                              00580000
&NM      DC    0H'0',X'83',AL1(&R1*16+&R3),AL2(&I2)                     00590000
         MEND ,                                                         00600000
*                                                                       00610000
*        MAXRATES SMF segment                                           00620000
*                                                                       00630000
MAXDSECT DSECT                                                          00640000
MAXMIPS  DS    D                                                        00650000
MAXIOS   DS    D                                                        00660000
MAXENT   EQU   MAXDSECT,*-MAXDSECT                                      00670000
*                                                                       00680000
*        Instruction counts segment                                     00690000
*                                                                       00700000
INCDSECT DSECT                                                          00710000
INCINS   DS    0D                                                       00720000
INCINSCP DS    XL2            CPU #                                     00730000
INCINSCT DS    XL6            CPU instruction counter                   00740000
INCENT   EQU   INCDSECT,*-INCDSECT                                      00750000
NUMCP    EQU   8                                                        00760001
*********************************************************************** 00770000
*                                                                     * 00780000
*        Monitor                                                      * 00790000
*                                                                     * 00800000
*********************************************************************** 00810000
*                                                                     * 00820000
*         Commands:                                                   * 00830000
*                                                                     * 00840000
*                   STATUS      Display status.                       * 00850000
*                   DISABLE     Disable SMF recording.                * 00860000
*                   ENABLE      Enable SMF recording.                 * 00870000
*                   DEBUG       Toggle debugging.                     * 00880000
*                   DUMP        Take SDUMP.                           * 00890000
*                   STOP        Stop monitor address space.           * 00900000
*                   WTO ON/OFF  Enable/disable statistics WTO.        * 00910000
*                                                                     * 00920000
*         PARM:                                                       * 00930000
*                                                                     * 00940000
*                   SMF=        Specifies SMF record number from      * 00950000
*                               201 to 255.                           * 00960000
*                               Default is SMF=255.                   * 00970000
*                   INTERVAL=   Specifies record interval.            * 00980000
*                               Valid values are 05, 15, 30 and 60.   * 00990000
*                               Default is INTERVAL=60.               * 01000001
*                   DD=         Indicates recording to a DD specified * 01010000
*                               instead of the SMF dataset.           * 01020000
*                               If a null DD than no recording.       * 01030000
*                   DEBUG       Caused a dump of the record when      * 01040000
*                               the record is recorded.               * 01050000
*                   SNAP        Snaps the work area.                  * 01060000
*                   WTO=YES     Enable WTO of usage statistics.       * 01070000
*                                                                     * 01080000
*********************************************************************** 01090000
*                                                                     * 01100000
* History                                                             * 01110000
* 1.00 04/19/2019 Created.                                            * 01120000
* 1.01 05/15/2019 Add instruction counter section                     * 01130000
* 1.02 05/20/2019 Syncronize inteval on our interval                  * 01140000
* 1.03 07/08/2019 New F09 processor counter probe                     * 01150000
* 1.04 12/07/2019 Add WTO command and parm                            * 01160000
* 2.05 07/10/2020 MVS 3.8 version                                     * 01170001
* 2.06 08/21/2022 Add msg 31 Average MIPS                             * 01180003
* 2.07 06/19/2023 Highest rates Hercules message number changed       * 01181004
         LCLC &VER                                                      01190000
&VER     SETC 'V2.07'                                                   01200004
*                                                                     * 01210000
*********************************************************************** 01220000
MONITOR  CSECT                                                          01230000
         USING MONITOR,R15                                              01240000
         B     START                   BYPASS PGMID                     01250000
         DROP  R15                                                      01260000
         DC    AL1(PGMIDLN)            LENGTH OF PGMID                  01270000
PGMID    DC    C'MONITOR - &VER &SYSDATE &SYSTIME'                      01280000
PGMIDLN  EQU   *-PGMID                                                  01290000
*********************************************************************** 01300000
*        Initialization                                               * 01310000
*********************************************************************** 01320000
START    DS    0H                                                       01330000
         USING PSA,R0                                                   01340000
         SAVE  (14,12)                 SAVE REGISTERS                   01350000
         LR    R10,R15                 SET BASE REGISTER                01360000
         LA    R11,2048(,R10)                                           01370000
         LA    R11,2048(,R11)                                           01380000
         LA    R12,2048(,R11)                                           01390000
         LA    R12,2048(,R12)                                           01400000
         USING MONITOR,R10,R11,R12                                      01410000
         L     R2,0(,R1)               SAVE PARAMETER ADDRESS           01420000
         LR    R3,R13                  SAVE CALLERS SAVE AREA ADDRESS   01430000
         L     R0,=A(W#LEN)                                             01440000
         GETMAIN RU,LV=(0),BNDRY=PAGE  Get work area                    01450000
         LR    R13,R1                  ADDRESS SAVE AREA                01460000
         USING W#,R13                  ADDRESSABILITY TO WORK AREA      01470000
         LR    R0,R1                                                    01480000
         L     R1,=A(W#LEN)                                             01490000
         SR    R15,R15                                                  01500000
         MVCL  R0,R14                                                   01510000
         ST    R3,4(,R13)              CHAIN SAVE AREAS                 01520000
         ST    R13,8(,R3)              CHAIN SAVE AREAS                 01530000
         USING W#,R13                                                   01540000
         BAL   R14,INT                                                  01550000
         BAL   R14,PRBINC              Get instruction counts           01560000
         BAL   R14,CMDENA                                               01570000
         LA    R2,W#                                                    01580000
         MSG   'Initialization complete',MSGNO=001                      01590000
         B     CIBDEL                                                   01600000
*********************************************************************** 01610000
*        Determine operator's request                                 * 01620000
*********************************************************************** 01630000
CHKECBS  DS    0H                                                       01640001
         TM    W#STMECB,ECBPOST        STIMER POST                      01650001
         BNO   CHKNPST                                                  01660000
         BAL   R14,STM                                                  01670000
         BAL   R14,PRBINC              Get instruction counts           01680000
         TM    W#FLG,W#FLGINT          Recording interval               01690000
         BNO   CHKNPST                                                  01700000
         BAL   R14,BLDSMF                                               01710000
         CLI   W#DD,C' '                                                01720000
         BNH   CHKN4DD                                                  01730000
         MVC   W#SMFDCB,P#SMFDCB                                        01740000
         MVC   W#SMFDCB+DCBDDNAM-IHADCB,W#DD                            01750000
         OPEN  (W#SMFDCB,(EXTEND)),MF=(E,W#OPNLST)                      01760000
         TM    W#SMFDCB+DCBOFLGS-IHADCB,DCBOFOPN                        01770000
         BZ    SMFDDERR                                                 01780000
         PUT   W#SMFDCB,W#XXHDR                                         01790000
         TM    W#FLG,W#FLGDBG                                           01800000
         BNO   CHKNDBG                                                  01810000
         MSG   'SMF Record written.',MSGNO=012                          01820000
CHKNDBG  DS    0H                                                       01830000
         CLOSE (W#SMFDCB,LEAVE),MF=(E,W#OPNLST)                         01840000
         FREEPOOL W#SMFDCB                                              01850000
         B     CHKNDSTS                                                 01860000
CHKN4DD  DS    0H                                                       01870000
         CLI   W#DD,C' '               Do nothing                       01880000
         BE    CHKNDSTS                                                 01890000
         SMFWTM W#XXHDR                                                 01900000
         TM    W#FLG,W#FLGDBG                                           01910000
         BNO   CHKNDSTS                                                 01920000
         MSG   'SMF Recording complete.',MSGNO=035                      01930001
CHKNDSTS DS    0H                                                       01940000
         L     R0,W#RECCNT             COUNT                            01950000
         AH    R0,=H'1'                RECORDS                          01960000
         ST    R0,W#RECCNT             WRITTEN                          01970000
CHKNPST  DS    0H                                                       01980000
         EXTRACT W#EXTANS,'S',FIELDS=COMM,MF=(E,W#EXTLST)               01990001
         L     R1,W#EXTANS             LOAD COMMUNICATIONS LIST ADDR    02000000
         USING COMM,R1                                                  02010001
         L     R4,COMCIBPT             Get COMM buffer address          02020001
         DROP  R1                                                       02030001
         L     R3,W#WAITLS                                              02040001
         USING ECB,R3                                                   02050000
         TM    ECBCC,ECBPOST                                            02060000
         DROP  R3                                                       02070000
         BZ    JUSTWAIT                                                 02080000
         USING CIB,R4                  ESTABLISH ADDRESSABILITY         02090000
         CLI   CIBVERB,CIBSTART        START COMMAND?                   02100000
         BE    CIBDEL                  IF SO, DELETE CIB AND WAIT       02110000
         CLI   CIBVERB,CIBSTOP         STOP COMMAND?                    02120000
         BE    CIBEND                  IF SO, GO TO PROCESSOR           02130000
         CLI   CIBVERB,CIBMODFY        MODIFY COMMAND                   02140000
         BE    CIBMOD                  IF SO, GO TO PROCESSOR           02150000
         CLI   CIBVERB,0               Empty CIB?                       02160000
         BE    CIBDEL                  IF SO, DELETE CIB AND WAIT       02170000
         MVC   W#CIBMS,=C'Invalid CIB verb=X'''                         02180000
         UNPK  W#CIBVRB(3),CIBVERB(2)                                   02190000
         TR    W#CIBVRB(2),P#HEXTB-240                                  02200000
         MVI   W#CIBMSQ,C''''                                           02210000
         MSG   MF=(E,W#CIBMSG),MSGNO=101                                02220000
         B     CIBDEL                  DELETE CIB AND WAIT FOR NEXT 1   02230000
*********************************************************************** 02240000
*        CIB delete                                                   * 02250000
*********************************************************************** 02260000
CIBDEL   DS    0H                                                       02270001
         EXTRACT W#EXTANS,'S',FIELDS=COMM,MF=(E,W#EXTLST)               02280001
         L     R1,W#EXTANS             Get COMM address                 02290001
         USING COMM,R1                                                  02300000
         L     R4,COMCIBPT             Get COMM buffer address          02310001
         LA    R5,COMCIBPT             Get CIB buffer address address   02320000
         DROP  R1                                                       02330000
         LTR   R4,R4                                                    02340000
         BZ    CIBDELA                                                  02350000
         QEDIT ORIGIN=(R5),BLOCK=(R4) DELETE LATEST CIB                 02360000
         LTR   R15,R15                                                  02370000
         BZ    CIBDELA                                                  02380000
         MVC   W#QEFMS,=C'QEDIT DELETE failed, RC=X'''                  02390000
         ST    R15,W#DWORD                                              02400000
         UNPK  W#QEFMSR(9),W#DWORD(5)                                   02410000
         TR    W#QEFMSR(8),P#HEXTB-240                                  02420000
         MVI   W#QEFMSQ,C''''                                           02430000
         MSG   MF=(E,W#QEFMSG),MSGNO=203                                02440000
         LA    R15,8                                                    02450001
         B     STOP                    Terminate                        02460000
CIBDELA  DS    0H                                                       02470000
         QEDIT ORIGIN=(R5),CIBCTR=2    INDICATE NUMBER OF CIBS          02480000
         LTR   R15,R15                                                  02490000
         BZ    CIBDELB                                                  02500000
         MVC   W#QEFMS,=C'QEDIT LIMIT  failed, RC=X'''                  02510000
         ST    R15,W#DWORD                                              02520000
         UNPK  W#QEFMSR(9),W#DWORD(5)                                   02530000
         TR    W#QEFMSR(8),P#HEXTB-240                                  02540000
         MVI   W#QEFMSQ,C''''                                           02550000
         MSG   MF=(E,W#QEFMSG),MSGNO=204                                02560000
         LA    R15,8                                                    02570001
         B     STOP                    Terminate                        02580000
CIBDELB  DS    0H                                                       02590000
         EXTRACT W#EXTANS,'S',FIELDS=COMM,MF=(E,W#EXTLST)               02600001
         L     R1,W#EXTANS             Get COMM address                 02610001
         USING COMM,R1                                                  02620001
         L     R1,COMECBPT             Get COMM ECB address             02630001
         DROP  R1                                                       02640001
         ST    R1,W#WAITLS                                              02650001
JUSTWAIT DS    0H                                                       02660000
         LA    R0,W#STMECB                                              02670001
         ST    R0,W#WAITLS+4                                            02680000
         OI    W#WAITLS+4,X'80'                                         02690000
         WAIT  ECBLIST=W#WAITLS        WAIT for STIMER or opertor cmd   02700001
         B     CHKECBS                 GO DETERMINE INPUT REQUEST       02710000
*********************************************************************** 02720000
*        Normal termination request                                   * 02730000
*********************************************************************** 02740000
CIBEND   DS    0H                                                       02750000
         MSG   'STOP command acknowledged',MSGNO=002                    02760000
         LA    R15,0                                                    02770001
         B     STOP                                                     02780000
*********************************************************************** 02790000
*        Subsystem termination                                        * 02800000
*********************************************************************** 02810000
STOP     DS    0H                                                       02820000
         LR    R4,R15                                                   02830001
*                                                                       02840000
         L     R0,W#RECCNT                                              02850000
         CVD   R0,W#DWORD                                               02860000
         MVC   W#RECMS#,=X'40206B2020206B202120'                        02870000
         ED    W#RECMS#,W#DWORD+4                                       02880000
         MVC   W#RECMS,=C'Records written'                              02890000
         MSG   MF=(E,W#RECMSG),MSGNO=014                                02900000
*                                                                       02910000
         CVD   R4,W#DWORD                                               02920001
         MVC   W#RCMSRC,=X'4020206B202120'                              02930000
         ED    W#RCMSRC,W#DWORD+5                                       02940000
         MVC   W#RCMS,=C'Return code'                                   02950000
         MSG   MF=(E,W#RCMSG),MSGNO=015                                 02960000
*                                                                       02970000
         TM    W#PRTDCB+48,16                                           02980000
         BNO   STOPNC                                                   02990000
         CLOSE (W#PRTDCB),MF=(E,W#OPNLST)                               03000000
STOPNC   DS    0H                                                       03010000
         LR    R1,R13                  Get work area address            03020000
         L     R13,4(,R13)             Get callers save aera            03030000
         L     R0,=A(W#LEN)            Length of work area              03040000
         FREEMAIN R,LV=(0),A=(1)       Free work area                   03050000
         L     R14,12(,R13)            Restore register 14              03060000
         LR    R15,R4                  Set return code                  03070001
         LM    R0,R12,20(R13)          Restore rest of registers        03080000
         BR    R14                     Exit                             03090000
*********************************************************************** 03100000
*        Modify command processor                                     * 03110000
*********************************************************************** 03120000
CIBMOD   DS    0H                                                       03130001
         MVC   W#PARM,=CL100' '        CLEAR PARAMETERS                 03140000
         LH    R15,CIBDATLN            LOAD INPUT LENGTH                03150000
         BCTR  R15,0                   DECREMENT                        03160000
         EX    R15,CIBMVC              MOVE INPUT TO TEMPORARY AREA     03170000
*                                                                       03180000
         MVC   W#CMDMSP,W#PARM                                          03190000
         MVC   W#CMDMS,=C'Processing command:'                          03200000
         MSG   MF=(E,W#CMDMSG),MSGNO=016                                03210000
*                                                                       03220000
         LA    R15,W#PARM              Command address                  03230000
CIBMODSA DS    0H                                                       03240000
         CLI   0(R15),C' '             End of command?                  03250000
         BE    CIBMODSB                Yes, check command               03260000
         AH    R15,=H'1'               Scan for a blank                 03270000
         B     CIBMODSA                Loop through command buffer      03280000
CIBMODSB DS    0H                                                       03290000
         LA    R1,W#PARM+1             Command address +1               03300000
         SR    R15,R1                  Less end of command              03310000
*                                                                       03320000
         CH    R15,=H'7'               TOO LONG ?                       03330000
         BH    CIBMODER                 YES, ERROR                      03340000
         LA    R2,P#COMCNT             NUMBER OF COMMANDS               03350000
         LA    R3,P#COMTBL             ADDRESS TABLE                    03360000
CIBMODSC DS    0H                                                       03370000
         CH    R15,0(,R3)              IS COMMAND VERB LONG ENOUGH ?    03380000
         BL    CIBMODNE                 NO, GET NEXT ENTRY              03390000
         EX    R15,CMDCHK              IS THIS COMMAND ?                03400000
         BE    CIBMODCM                 YES, POCESS IT                  03410000
CIBMODNE DS    0H                                                       03420000
         LA    R3,P#COMLEN(,R3)        GET NEXT ENTRY IN TABLE          03430000
         BCT   R2,CIBMODSC             LOOP THRU COMMAND TABLE          03440000
         B     CIBMODER                ERROR                            03450000
CIBMODCM DS    0H                                                       03460000
         L     R15,12(,R3)             GET COMMAND ROUTINE ADDRESS      03470000
         BALR  R14,R15                 LINK TO ROUTINE                  03480000
         B     CIBDEL                  DELETE CIB                       03490000
CIBMODER DS    0H                                                       03500000
         MSG   'Invalid request',MSGNO=102                              03510000
         B     CIBDEL                  DELETE CIB                       03520000
*********************************************************************** 03530000
*        Command to display status                                    * 03540000
*********************************************************************** 03550000
CMDSTA   DS    0H                                                       03560000
         ST    R14,W#STAR14            SAVE RETURN                      03570000
         MSG   'Status:',MSGNO=003                                      03580001
         TM    W#FLG,W#FLGACT                                           03590000
         BO    CMDSTAAC                                                 03600000
         MSG   'Recording disabled',MSGNO=004                           03610000
         B     CMDSTASM                                                 03620000
CMDSTAAC DS    0H                                                       03630000
         MVC   W#STMMS,=C'Next interval at '                            03640000
         MSG   MF=(E,W#STMMSG),MSGNO=005                                03650000
CMDSTASM DS    0H                                                       03660000
         LA    R4,NUMCP                                                 03670001
         LA    R3,W#INSCTC                                              03680001
CMDSTALP DS    0H                                                       03690000
         LM    R0,R1,0(R3)                                              03700000
         LTR   R0,R0                                                    03710000
         BNZ   CMDSTAIM                                                 03720000
         LTR   R1,R1                                                    03730000
         BZ    CMDSTAEL                                                 03740000
CMDSTAIM DS    0H                                                       03750000
         LA    R15,NUMCP                                                03760001
         SR    R15,R4                                                   03770001
         STH   R15,W#DWORD                                              03780001
         MVC   W#INSMS,=C'CPU='                                         03790000
         UNPK  W#INSCPU,W#DWORD+1(2)                                    03800000
         TR    W#INSCPU(2),P#HEXTB-240                                  03810000
         MVI   W#INSCPU+2,C' '                                          03820000
         MVC   W#INSS,=C'Instructions='                                 03830000
         BAL   R14,EDTNUM                                               03840002
         MVC   W#INSCT,W#EDTNUM                                         03850001
         MSG   MF=(E,W#INSMSG),MSGNO=031                                03860001
CMDSTAEL DS    0H                                                       03870000
         AH    R3,=H'8'                                                 03880000
         BCT   R4,CMDSTALP                                              03890001
CMDSTAXT DS    0H                                                       03900000
         L     R14,W#STAR14            RESTORE RETURN                   03910000
         BR    R14                     EXIT                             03920000
*********************************************************************** 03930001
*        Command to display options                                   * 03940001
*********************************************************************** 03950001
CMDOPT   DS    0H                                                       03960001
         ST    R14,W#OPTR14            SAVE RETURN                      03970001
         MSG   'Options:',MSGNO=018                                     03980001
         TM    W#FLG,W#FLGDBG                                           03990001
         BNO   CMDOPTA                                                  04000001
         MSG   'DEBUG enabled',MSGNO=037                                04010001
CMDOPTA  DS    0H                                                       04020001
         CLI   W#DD,C' '                                                04030001
         BNH   CMDOPTB                                                  04040001
         MVC   W#DDMS,=C'Recording to DD '                              04050001
         MVC   W#DDDD,W#DD                                              04060001
         MSG   MF=(E,W#DDMSG),MSGNO=019                                 04070001
         B     CMDOPTD                                                  04080001
CMDOPTB  DS    0H                                                       04090001
         CLI   W#DD,C' '                                                04100001
         BNE   CMDOPTC                                                  04110001
         MVC   W#DDMS,=C'Not recording   '                              04120001
         MVC   W#DDDD,W#DD                                              04130001
         MSG   MF=(E,W#DDMSG),MSGNO=019                                 04140001
         B     CMDOPTD                                                  04150001
CMDOPTC  DS    0H                                                       04160001
         MSG   'Recording to SMF',MSGNO=020                             04170001
CMDOPTD  DS    0H                                                       04180001
         MVC   W#SMFMS,=C'SMF record '                                  04190001
         SR    R0,R0                                                    04200001
         IC    R0,W#SMFNO                                               04210001
         CVD   R0,W#DWORD                                               04220001
         UNPK  W#SMFMS#,W#DWORD+6(2)                                    04230001
         OI    W#SMFMS#+2,C'0'                                          04240001
         MSG   MF=(E,W#SMFMSG),MSGNO=006                                04250001
         MVC   W#INTMS,=C'Recording Interval='                          04260001
         TM    W#FLG,W#FLGI05                                           04270001
         BNO   CMDOPTE                                                  04280001
         MVC   W#INTMS#,=C'05'                                          04290001
         B     CMDOPTH                                                  04300001
CMDOPTE  DS    0H                                                       04310001
         TM    W#FLG,W#FLGI15                                           04320001
         BNO   CMDOPTF                                                  04330001
         MVC   W#INTMS#,=C'15'                                          04340001
         B     CMDOPTH                                                  04350001
CMDOPTF  DS    0H                                                       04360001
         TM    W#FLG,W#FLGI30                                           04370001
         BNO   CMDOPTG                                                  04380001
         MVC   W#INTMS#,=C'30'                                          04390001
         B     CMDOPTH                                                  04400001
CMDOPTG  DS    0H                                                       04410001
         MVC   W#INTMS#,=C'60'                                          04420001
CMDOPTH  DS    0H                                                       04430001
         MSG   MF=(E,W#INTMSG),MSGNO=017                                04440001
         TM    W#FLG1,W#FLG1WT                                          04450001
         BNO   CMDOPTI                                                  04460001
         MSG   'WTO usage enabled',MSGNO=021                            04470001
CMDOPTI  DS    0H                                                       04480001
CMDOPTXT DS    0H                                                       04490001
         L     R14,W#OPTR14            RESTORE RETURN                   04500001
         BR    R14                     EXIT                             04510001
*********************************************************************** 04520001
*        Command to disable recording                                 * 04530000
*********************************************************************** 04540000
CMDDIS   DS    0H                                                       04550000
         ST    R14,W#DISR14            SAVE RETURN                      04560000
         TM    W#FLG,W#FLGACT                                           04570000
         BZ    CMDDISIA                                                 04580000
         NI    W#FLG,255-W#FLGACT                                       04590000
         TTIMER CANCEL                                                  04600000
         MSG   'Recording disabled',MSGNO=004                           04610000
         B     CMDDISXT                                                 04620000
CMDDISIA DS    0H                                                       04630001
         MSG   'Recording already disabled',MSGNO=013                   04640000
CMDDISXT DS    0H                                                       04650000
         L     R14,W#DISR14            RESTORE RETURN                   04660000
         BR    R14                     EXIT                             04670000
*********************************************************************** 04680000
*        Command to enable recording                                  * 04690000
*********************************************************************** 04700000
CMDENA   DS    0H                                                       04710000
         ST    R14,W#ENAR14            SAVE RETURN                      04720000
         TM    W#FLG,W#FLGACT                                           04730000
         BO    CMDENAAC                                                 04740000
         OI    W#FLG,W#FLGACT                                           04750000
         BAL   R14,STM                                                  04760000
         B     CMDENAXT                                                 04770000
CMDENAAC DS    0H                                                       04780000
         MSG   'Recording already enabled',MSGNO=007                    04790000
CMDENAXT DS    0H                                                       04800001
         L     R14,W#ENAR14            RESTORE RETURN                   04810000
         BR    R14                     EXIT                             04820000
*********************************************************************** 04830000
*        Command to take a dump                                       * 04840000
*********************************************************************** 04850000
CMDDMP   ST    R14,W#ABER14            SAVE RETURN                      04860000
         MSG   'Abending',MSGNO=201                                     04870000
         DC    X'00ABEABE'                                              04880000
         L     R14,W#ABER14            RESTORE RETURN                   04890000
         BR    R14                     EXIT                             04900000
*********************************************************************** 04910000
*        Command to toggle debug                                      * 04920000
*********************************************************************** 04930000
CMDDBG   ST    R14,W#DBGR14            SAVE RETURN                      04940000
         TM    W#FLG,W#FLGDBG                                           04950000
         BO    CMDDBGOF                                                 04960000
         MSG   'DEBUG turned on',MSGNO=010                              04970000
         OI    W#FLG,W#FLGDBG                                           04980000
         B     CMDDBGXT                                                 04990000
CMDDBGOF DS    0H                                                       05000000
         MSG   'DEBUG turned off',MSGNO=011                             05010000
         NI    W#FLG,255-W#FLGDBG                                       05020000
CMDDBGXT DS    0H                                                       05030000
         L     R14,W#DBGR14            RESTORE RETURN                   05040000
         BR    R14                     EXIT                             05050000
*********************************************************************** 05060000
*        Command SNAP work area                                       * 05070000
*********************************************************************** 05080000
CMDSNP   ST    R14,W#SNPR14            SAVE RETURN                      05090000
         BAL   R14,PRT                 Print a line                     05100000
         MVC   W#LINE+1(15),=C'Work area at X'''                        05110000
         ST    R13,W#DWORD                                              05120000
         UNPK  W#LINE+16(9),W#DWORD(5)                                  05130000
         TR    W#LINE+16(8),P#HEXTB-240                                 05140000
         MVI   W#LINE+24,C''''                                          05150000
         MSG   MF=(E,MSG034),MSGNO=034                                  05160001
         TTIMER ,MIC,W#TOGOC           Get whats left to WAIT           05170001
         LR    R1,R13                  Work area address                05180000
         L     R0,=A(W#LEN)            Work area length                 05190000
         BAL   R14,DMP                 Dump work area                   05200000
         BAL   R14,PRT                 Print a line                     05210000
CMDSNPXT DS    0H                                                       05220000
         L     R14,W#SNPR14            RESTORE RETURN                   05230000
         BR    R14                     EXIT                             05240000
*********************************************************************** 05250000
*        Command to enable/disable WTO of statistics                  * 05260000
*********************************************************************** 05270000
CMDWTO   ST    R14,W#WTOR14            Save return                      05280000
         CLC   =C' ON',W#PARM+3        WTO ON entered                   05290000
         BE    CMDWTOON                Yes, turn it on                  05300000
         CLC   =C' OFF',W#PARM+3       WTO OFF entered                  05310000
         BE    CMDWTOOF                Yes, turn it off                 05320000
         MSG   'WTO option invalid',MSGNO=022                           05330000
         B     CMDWTOXT                Exit command                     05340000
CMDWTOON DS    0H                                                       05350000
         MSG   'WTO turned on',MSGNO=023                                05360000
         OI    W#FLG1,W#FLG1WT         Turn on WTO statistics           05370000
         B     CMDWTOXT                Exit command                     05380000
CMDWTOOF DS    0H                                                       05390000
         MSG   'WTO turned off',MSGNO=024                               05400000
         NI    W#FLG1,255-W#FLG1WT     Turn off WTO statistics          05410000
CMDWTOXT DS    0H                                                       05420000
         L     R14,W#WTOR14            Restore return                   05430000
         BR    R14                     Exit                             05440000
*********************************************************************** 05450000
*        Build SMF record                                             * 05460000
*********************************************************************** 05470000
BLDSMF   DS    0H                                                       05480001
         ST    R14,W#BLDR14            Save return                      05490000
         XC    W#XXHDR,W#XXHDR         Clear SMF record                 05500000
         LA    R0,L'W#XXHDR            Header length                    05510000
         STH   R0,W#XXLEN                                               05520000
         MVI   W#XXFLG,W#XXSUT+W#XXV4+W#XXESA+W#XXVXA+W#XXOS            05530000
         MVC   W#XXRTY,W#SMFNO         Record number                    05540000
         TIME  BIN                                                      05550000
         STCM  R0,15,W#XXTME                                            05560000
         ST    R1,W#DWORD                                               05570000
         SLL   R1,8                                                     05580000
         SRL   R1,8                                                     05590001
         STCM  R1,15,W#XXDTE           Record date                      05600000
         OI    W#XXDTE+3,X'0F'                                          05610000
         CLC   =X'01999365',W#DWORD    Date greater than 01999365       05620000
         BH    BLDSMFA                                                  05630000
         MVI   W#XXDTE,1               21st century                     05640000
BLDSMFA  DS    0H                                                       05650000
         MVC   W#BGNTME,W#XXTME                                         05660000
         MVC   W#BGNDTE,W#XXDTE                                         05670000
         L     R1,FLCCVT               CVT address                      05680000
         USING CVTMAP,R1                                                05690000
         L     R1,CVTSMCA                                               05700000
         USING SMCABASE,R1                                              05710000
         MVC   W#XXSID,SMCASID         Record system id                 05720000
         DROP  R1                                                       05730000
         MVC   W#XXSSI,P#SYSNM         record subsystem name            05740000
         LA    R0,2                    Sub type=2                       05750001
         STH   R0,W#XXSTY              Record sub type                  05760000
         BAL   R14,SMFMAX              Fill in the MIP/IO from MAXRATES 05770000
         BAL   R14,SMFINC              Fill in instruction counters     05780000
*        Dump SMF record                                                05790000
         TM    W#FLG,W#FLGDBG                                           05800000
         BNO   BLDSMFB                                                  05810000
         BAL   R14,PRT                                                  05820000
         MVC   W#LINE+1(19),=C'SMF xxx record dump'                     05830000
         SR    R0,R0                                                    05840000
         IC    R0,W#SMFNO                                               05850000
         CVD   R0,W#DWORD                                               05860000
         UNPK  W#LINE+5(3),W#DWORD+6(2)                                 05870000
         OI    W#LINE+7,C'0'                                            05880000
         ICM   R1,15,W#XXDTE         SMF date                           05890000
         BAL   R14,FDATE                                                05900000
         MVC   W#LINE+21(4),=C'Date'                                    05910000
         MVC   W#LINE+26(10),W#FMTDTE                                   05920000
         ICM   R1,15,W#XXTME         SMF time                           05930000
         BAL   R14,FTIME                                                05940000
         MVC   W#LINE+37(4),=C'Time'                                    05950000
         MVC   W#LINE+42(L'W#FMTTME),W#FMTTME                           05960000
         BAL   R14,PRT                                                  05970000
         LH    R0,W#XXLEN                                               05980000
         LA    R1,W#XXHDR                                               05990000
         BAL   R14,DMP                                                  06000000
         BAL   R14,PRT                                                  06010000
BLDSMFB  DS    0H                                                       06020000
         L     R14,W#BLDR14            RESTORE RETURN                   06030000
         BR    R14                     EXIT                             06040000
*********************************************************************** 06050000
*        Construct MAXRATES information section                       * 06060000
*********************************************************************** 06070000
SMFMAX   DS    0H                                                       06080000
         ST    R14,W#SMFMXE            Save return                      06090000
*                                                                       06100000
         LA    R1,L'P#CMDMR                                             06110000
         STCM  R1,7,W#DG8P3L           Save command length              06120000
         MVC   W#DG8P1(L'P#CMDMR),P#CMDMR                               06130000
         BAL   R14,HRCCMD              Issue Hercules command           06140000
*                                                                       06150004
* HHC02272I Highest observed MIPS and IO/s rates                        06160000
* HHC02272I From Mon Apr 01 10:44:09 2019 to Mon Apr 01 11:44:09 2019   06170000
* HHC02272I MIPS: 73.454514                                             06180000
* HHC02272I IO/s: 568                                                   06190000
* HHC02272I From Mon Apr 01 11:44:09 2019 to Mon Apr 01 11:45:04 2019   06200000
* HHC02272I MIPS: 2.438220                                              06210000
* HHC02272I IO/s: 36                                                    06220000
* HHC02272I Current interval is 60 minutes                              06230000
*                                                                       06240004
* Or in later Hercules release                                          06250004
*                                                                       06260004
* HHC02268I Highest observed MIPS and IO/s rates                        06270004
* HHC02268I From Mon Apr 01 10:44:09 2019 to Mon Apr 01 11:44:09 2019   06280004
* HHC02268I MIPS: 73.454514                                             06290004
* HHC02268I IO/s: 568                                                   06300004
* HHC02268I From Mon Apr 01 11:44:09 2019 to Mon Apr 01 11:45:04 2019   06310004
* HHC02268I MIPS: 2.438220                                              06320004
* HHC02268I IO/s: 36                                                    06330004
* HHC02268I Current interval is 60 minutes                              06340004
*                                                                       06350004
         LTR   R5,R5                   Hercules response length         06360000
         BZ    SMFMAXAZ                                                 06370000
         XC    W#IOS,W#IOS                                              06380000
         XC    W#MIPS,W#MIPS                                            06390000
         LA    R3,W#DG8P2              Response buffer                  06400000
SMFMAXAA DS    0H                                                       06410000
         LA    R0,L'W#LINE-1           Max message length               06420000
         LA    R1,W#LINE+1             Message buffer                   06430000
         LR    R15,R1                  Save start of this message       06440000
SMFMAXAB DS    0H                                                       06450000
         CLI   0(R3),X'25'             New line - issue message         06460000
         BE    SMFMAXAC                                                 06470001
         MVC   0(1,R1),0(R3)           Copy response to output          06480000
         AH    R1,=H'1'                Next output position             06490000
         AH    R3,=H'1'                Next response position           06500000
         SH    R5,=H'1'                                                 06510000
         BZ    SMFMAXAC                                                 06520000
         BCT   R0,SMFMAXAB                                              06530000
SMFMAXAC DS    0H                                                       06540000
         CLC   =C'HHC02268I MIPS:',W#LINE+1                             06550004
         BE    SMFMIPFD                                                 06560004
         CLC   =C'HHC02272I MIPS:',W#LINE+1                             06570000
         BNE   SMFMAXAF                                                 06580000
SMFMIPFD DS    0H                                                       06590004
         MVC   W#MIPS,W#LINE+17                                         06600000
         LA    R1,W#MIPS                                                06610000
         LA    R0,L'W#MIPS                                              06620000
SMFMAXAD DS    0H                                                       06630000
         CLI   0(R1),C'.'                                               06640000
         BNE   SMFMAXAE                                                 06650000
         OC    1(6,R1),=6C'0'                                           06660000
         LA    R0,1                                                     06670000
SMFMAXAE DS    0H                                                       06680000
         AH    R1,=H'1'                                                 06690000
         BCT   R0,SMFMAXAD                                              06700000
         LA    R1,W#MIPS                                                06710000
         BAL   R14,NNCVT                                                06720000
         STM   R0,R1,W#SMFMIP                                           06730000
SMFMAXAF DS    0H                                                       06740000
         CLC   =C'HHC02268I IO/s:',W#LINE+1                             06750004
         BE    SMFIOFD                                                  06760004
         CLC   =C'HHC02272I IO/s:',W#LINE+1                             06770000
         BNE   SMFMAXAG                                                 06780000
SMFIOFD  DS    0H                                                       06790004
         MVC   W#IOS,W#LINE+17                                          06800000
         LA    R1,W#IOS                                                 06810000
         BAL   R14,NNCVT                                                06820000
         STM   R0,R1,W#SMFIOS                                           06830000
SMFMAXAG DS    0H                                                       06840000
*        Verify MAXRATES interval                                       06850000
         CLC   =C'HHC02268I Current interval is ',W#LINE+1              06860004
         BE    SMFINTFD                                                 06870004
         CLC   =C'HHC02272I Current interval is ',W#LINE+1              06880000
         BNE   SMFMAXAL                                                 06890000
SMFINTFD DS    0H                                                       06900004
         OI    W#FLG1,W#FLG1SR          Start with need to set interval 06910000
         CLC   =C'05 ',W#LINE+31                                        06920000
         BNE   SMFMAXAH                                                 06930000
         TM    W#FLG,W#FLGI05                                           06940000
         BNO   SMFMAXAH                                                 06950000
         NI    W#FLG1,255-W#FLG1SR      Interval is ok                  06960000
SMFMAXAH DS    0H                                                       06970000
         CLC   =C'15 ',W#LINE+31                                        06980000
         BNE   SMFMAXAI                                                 06990000
         TM    W#FLG,W#FLGI15                                           07000000
         BNO   SMFMAXAI                                                 07010000
         NI    W#FLG1,255-W#FLG1SR      Interval is ok                  07020000
SMFMAXAI DS    0H                                                       07030000
         CLC   =C'30 ',W#LINE+31                                        07040000
         BNE   SMFMAXAJ                                                 07050000
         TM    W#FLG,W#FLGI30                                           07060000
         BNO   SMFMAXAJ                                                 07070000
         NI    W#FLG1,255-W#FLG1SR      Interval is ok                  07080000
SMFMAXAJ DS    0H                                                       07090000
         CLC   =C'60 ',W#LINE+31                                        07100000
         BNE   SMFMAXAK                                                 07110000
         TM    W#FLG,W#FLGI60                                           07120000
         BNO   SMFMAXAK                                                 07130000
         NI    W#FLG1,255-W#FLG1SR      Interval is ok                  07140000
SMFMAXAK DS    0H                                                       07150000
         ICM   R0,15,W#RECCNT           Syncronize interval now         07160000
         BNZ   SMFMAXAL                                                 07170000
         OI    W#FLG1,W#FLG1SR          Need to set interval            07180000
SMFMAXAL DS    0H                                                       07190000
         TM    W#FLG,W#FLGDBG                                           07200000
         BNO   SMFMAXAM                                                 07210000
         BAL   R14,PRT                 Print a line                     07220000
SMFMAXAM DS    0H                                                       07230000
         MVI   W#LINE,C' '             Clear line                       07240000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              07250000
         AH    R3,=H'1'                Skip new line character          07260000
         LTR   R5,R5                   End of response buffer           07270000
         BZ    SMFMAXAZ                                                 07280000
         BCT   R5,SMFMAXAA                                              07290000
SMFMAXAZ DS    0H                                                       07300000
*        Syncronize MAXRATES with our recording interval                07310000
         TM    W#FLG1,W#FLG1SR                                          07320000
         BNO   SMFMAXBJ                                                 07330001
         LA    R1,L'P#CMDMR+3            Command length                 07340000
         STCM  R1,7,W#DG8P3L             Save command length            07350000
         MVC   W#DG8P1(L'P#CMDMR),P#CMDMR Set MAXRATES command          07360000
         TM    W#FLG,W#FLGI05                                           07370000
         BNO   SMFMAXBA                                                 07380000
         MVC   W#DG8P1+L'P#CMDMR(4),=C' 05 ' Set interval               07390000
         B     SMFMAXBD                                                 07400000
SMFMAXBA DS    0H                                                       07410000
         TM    W#FLG,W#FLGI15                                           07420000
         BNO   SMFMAXBB                                                 07430000
         MVC   W#DG8P1+L'P#CMDMR(4),=C' 15 ' Set interval               07440000
         B     SMFMAXBD                                                 07450000
SMFMAXBB DS    0H                                                       07460000
         TM    W#FLG,W#FLGI30                                           07470000
         BNO   SMFMAXBC                                                 07480000
         MVC   W#DG8P1+L'P#CMDMR(4),=C' 30 ' Set interval               07490000
         B     SMFMAXBD                                                 07500000
SMFMAXBC DS    0H                                                       07510000
         TM    W#FLG,W#FLGI60                                           07520000
         BNO   SMFMAXBD                                                 07530000
         MVC   W#DG8P1+L'P#CMDMR(4),=C' 60 ' Set interval               07540000
SMFMAXBD DS    0H                                                       07550000
         BAL   R14,HRCCMD                Issue Hercules command         07560000
         LTR   R5,R5                     Hercules response length       07570000
         BZ    SMFMAXBJ                                                 07580000
         LA    R3,W#DG8P2                Response buffer                07590000
SMFMAXBE DS    0H                                                       07600000
         LA    R0,L'W#LINE-1             Max message length             07610000
         LA    R1,W#LINE+1               Message buffer                 07620000
         LR    R15,R1                    Save start of this message     07630000
SMFMAXBF DS    0H                                                       07640000
         CLI   0(R3),X'25'               New line - issue message       07650000
         BE    SMFMAXBG                                                 07660001
         MVC   0(1,R1),0(R3)             Copy response to output        07670000
         AH    R1,=H'1'                  Next output position           07680000
         AH    R3,=H'1'                  Next response position         07690000
         SH    R5,=H'1'                  End of response                07700000
         BZ    SMFMAXBG                                                 07710000
         BCT   R0,SMFMAXBF                                              07720000
SMFMAXBG DS    0H                                                       07730000
         TM    W#FLG,W#FLGDBG                                           07740000
         BNO   SMFMAXBH                                                 07750000
         BAL   R14,PRT                   Print a line                   07760000
SMFMAXBH DS    0H                                                       07770000
         MVI   W#LINE,C' '               Clear line                     07780000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              07790000
         AH    R3,=H'1'                  Skip new line character        07800000
         LTR   R5,R5                     End of response buffer         07810000
         BZ    SMFMAXBI                                                 07820000
         BCT   R5,SMFMAXBE                                              07830000
SMFMAXBI DS    0H                                                       07840000
         MSG   'MAXRATES interval syncronized',MSGNO=033                07850000
SMFMAXBJ DS    0H                                                       07860000
*                                                                       07870000
         MVC   W#MIPMS,=C'MIPs='                                        07880000
         MVC   W#MIPVAL,W#MIPS                                          07890000
         MVC   W#IOMS,=C'I/Os='                                         07900000
         MVC   W#IOVAL,W#IOS                                            07910000
         MSG   MF=(E,W#HRCMSG),MSGNO=030                                07920000
*                                                                       07930000
         LA    R1,L'W#XXHDR            Offset to MAXRATES section       07940000
         ST    R1,W#XXMOF              Save MAXRATES section offset     07950000
         LA    R1,L'MAXENT             Get MAXRATES section size        07960000
         STH   R1,W#XXMLN              Save MAXRATES section size       07970000
         LA    R0,1                    Get MAXRATES occurances          07980000
         STH   R0,W#XXMON              Save MAXRATES occurances         07990000
         LH    R0,W#XXLEN              Current record length            08000000
         AR    R0,R1                   Plus MAXRATES length             08010000
         STH   R0,W#XXLEN              New record length                08020000
         L     R1,W#XXMOF              MAXRATES section offset          08030000
         LA    R14,W#XXHDR(R1)         MAXRATES section address         08040000
         USING MAXENT,R14                                               08050000
         MVC   MAXMIPS,W#SMFMIP                                         08060000
         MVC   MAXIOS,W#SMFIOS                                          08070000
         DROP  R14                                                      08080000
         L     R14,W#SMFMXE            Restore return                   08090000
         BR    R14                     Exit                             08100000
*********************************************************************** 08110000
*        Issue Hercules command                                       * 08120000
*********************************************************************** 08130000
HRCCMD   DS    0H                                                       08140001
         ST    R14,W#HRCCME            Save return                      08150000
*                                                                       08160000
         SR    R1,R1                                                    08170000
         ICM   R1,7,W#DG8P3L           Save command length              08180000
         SH    R1,=H'1'                Machine length                   08190000
         TM    W#FLG,W#FLGDBG          If debug mode                    08200000
         BNO   HRCCMDB                                                  08210000
         MVC   W#LINE+1(8),=C'Command:'                                 08220001
         CH    R1,=AL2(31)             Does command fit                 08230001
         BL    HRCCMDA                                                  08240000
         LA    R1,31                   Truncate command in message      08250001
HRCCMDA  DS    0H                                                       08260000
         EX    R1,MVCCMDP              Move command                     08270000
         MSG   MF=(E,MSG036),MSGNO=036                                  08280001
HRCCMDB  DS    0H                                                       08290000
         LA    R0,W#DG8P2              Clear                            08300001
         LA    R1,L'W#DG8P2             out                             08310001
         SR    R14,R14                   response                       08320001
         SR    R15,R15                    buffer                        08330001
         MVCL  R0,R14                                                   08340001
         MVI   W#DG8P3,X'40'           Set return response in buffer    08350000
         MODESET MODE=SUP,KEY=ZERO     Into key 0 supervisor state      08360000
         USING PSA,R0                                                   08370000
         L     R3,PSAAOLD              Get ASCB address                 08380000
         DROP  R0                                                       08390000
         LR    R1,R13                  Get start address to fix         08400000
         L     R15,=A(W#LEN-1)         Get offset to it's end           08410000
         AR    R15,R1                  Get end address to fix           08420000
         XC    W#FIXECB,W#FIXECB       Clear ECB                        08430000
         LA    R0,W#FIXECB             ECB address                      08440000
         PGFIX R,                      FIX request                     *08450000
               A=(1),                  Start address                   *08460000
               EA=(15),                End address                     *08470000
               ECB=(0)                 ECB                              08480000
         WAIT  ECB=W#FIXECB            WAIT for fix                     08490000
         LRA   R2,W#DG8P1              DIAG 8 parameter 1 (command)     08500000
         LRA   R3,W#DG8P2              DIAG 8 parameter 2 (response)    08510000
         L     R4,W#DG8P3              DIAG 8 parameter 3 (flag/len)    08520000
         LA    R5,L'W#DG8P2            DIAG 8 parameter 4 (resp len)    08530000
         DIAG  R2,R4,8                 Issue Hercules command           08540000
         USING PSA,R0                                                   08550000
         L     R3,PSAAOLD              Get ASCB address                 08560000
         DROP  R0                                                       08570000
         LR    R1,R13                  Get start address to fix         08580000
         L     R15,=A(W#LEN-1)         Get offset to it's end           08590000
         AR    R15,R1                  Get end address to fix           08600000
         PGFREE R,                     FREE request                    *08610000
               A=(1),                  Start address                   *08620000
               EA=(15)                 End address                      08630000
         MODESET MODE=PROB,KEY=NZERO   Back to problem state/key        08640000
         LTR   R4,R4                   Hercules command fail            08650000
         BZ    HRCCMDC                                                  08660000
         MSG   'HCI0002E Command failed',MSGNO=205                      08670000
         LA    R15,8                   Error return code                08680000
         B     STOP **********************************************>>>   08690000
HRCCMDC  DS    0H                                                       08700000
*        R5 = command length                                            08710000
         L     R14,W#HRCCME            Restore return                   08720000
         BR    R14                     Exit                             08730000
*                                                                       08740000
*********************************************************************** 08750000
*        New Interval Instruction Count Probe                         * 08760000
*********************************************************************** 08770000
*                                                                     * 08780000
* Diagnose F09:                                                       * 08790000
*                                                                     * 08800000
*  Operand register r3 bits 32-47 specify the option code and         * 08810000
*  bits 48-63 specify the CPU Address for option code 1.              * 08820000
*  For option code 0, operand register r3 bits 48-63 are              * 08830000
*  ignored. Bits 0-31 of operand register r3 are also always          * 08840000
*  ignored. Any option code other than 0 or 1 causes                  * 08850000
*  a Specification Exception Program Interrupt to occur.              * 08860000
*                                                                     * 08870000
*  Option 0 = instruction count for entire system (all CPUs           * 08880000
*  together). Option 1 = instruction count for the specific           * 08890000
*  CPU identified in bits 48-63 of r3.                                * 08900000
*                                                                     * 08910000
*  The register and bits that the 64-bit instruction count            * 08920000
*  is returned in depends on: 1) whether z/Architecture mode          * 08930000
*  is active or not, and 2) whether the specified operand-1           * 08940000
*  r1 register number is even or odd.                                 * 08950000
*                                                                     * 08960000
*  If operand-1 register r1 is an even numbered register,             * 08970000
*  then the high-order bits 0-31 of the 64-bit instruction            * 08980000
*  count is returned in bits 32-63 of the even numbered               * 08990000
*  register, the low-order bits 32-63 the 64-bit instruction          * 09000000
*  count is returned in bits 32-63 of the r1+1 odd numbered           * 09010000
*  register and bits 0-31 of each register remain unmodified.         * 09020000
*                                                                     * 09030000
*                                                                     * 09040000
*  If operand-1 register r1 specifies an odd numbered                 * 09050000
*  register however, then the 64-bit instruction count is             * 09060000
*  returned in bits 0-63 of register r1 in z/Architecture             * 09070000
*  mode, whereas a Specification Exception Program Check              * 09080000
*  Interrupt occurs in both ESA/390 and System/370                    * 09090000
*  architecture modes as 64-bit registers don't exist in              * 09100000
*  either of those architectures.                                     * 09110000
*                                                                     * 09120000
*  Precluding a Specification Exception Program Interrupt,            * 09130000
*  Condition Code 0 is returned for option 0, whereas for             * 09140000
*  option 1, Condition Code 0 is only returned if the CPU             * 09150000
*  specified in bits 48-63 of the operand-3 register r3 is            * 09160000
*  currently valid and online. Otherwise if the specified             * 09170000
*  CPU is offline or does not exist in the configuration,             * 09180000
*  Condition Code 3 is returned and the r1 or r1 and r1+1             * 09190000
*  return value register(s) is/are not modified.                      * 09200000
*                                                                     * 09210000
*********************************************************************** 09220000
PRBINC   DS    0H                                                       09230001
         STM   R0,R15,W#PRBIRS         Save registers                   09240000
*        Get max CPUs                                                   09250000
         LA    R2,NUMCP                Maximum CPUs                     09260001
         USING PSA,R0                                                   09270000
*        Get current number of CPUs                                     09280000
         USING PSA,R0                                                   09290000
         L     R15,FLCCVT              Get CVT address                  09300000
         DROP  R0                                                       09310000
         USING CVT,R15                                                  09320000
         S     R15,=A(CVT-CVTFIX)      Get CVT prefix                   09330000
         USING CVTFIX,R15                                               09340000
         L     R15,CVTPCCAT            Get PCCA address                 09350000
         USING PCCAVT,R15                                               09360000
         SR    R1,R1                                                    09370000
PRBINCA  DS    0H                                                       09380000
         ICM   R0,15,PCCAT00P          If a PCCA                        09390001
         BZ    PRBINCB                                                  09400000
         AH    R1,=H'1'                Count processors                 09410000
PRBINCB  DS    0H                                                       09420000
         LA    R15,PCCAT01P            Get next PCCA slot               09430000
         BCT   R2,PRBINCA                                               09440000
         DROP  R15                                                      09450000
         STH   R1,W#CPUCT              Save number of CPUs              09460000
*        Probe for each CPU instruction counter                         09470000
         LA    R4,0                    CPU number                       09480001
PRBINCC  DS    0H                                                       09490000
         MODESET KEY=ZERO,MODE=SUP                                      09500000
         L     R0,=X'00010000'         Option 1 by processor            09510001
         AR    R0,R4                   CPU number                       09520001
         SR    R2,R2                   Clear counter                    09530001
         SR    R3,R3                   Clear counter                    09540001
         DIAG  R2,R0,X'F09'                                             09550000
         MODESET KEY=NZERO,MODE=PROB                                    09560000
         LR    R1,R4                   Processor number                 09570000
         SLL   R1,3                    Times 8                          09580000
         LA    R1,W#INSCTC(R1)                                          09590001
         STM   R2,R3,0(R1)             Save current instr count         09600000
         AH    R4,=H'1'                                                 09610001
         CH    R4,=AL2(NUMCP)                                           09620001
         BL    PRBINCC                                                  09630001
*                                                                       09640000
         LM    R0,R15,W#PRBIRS         Restore registers                09650000
         BR    R14                     Exit                             09660000
*********************************************************************** 09670000
*        Construct SMF Instruction Counters                           * 09680000
*********************************************************************** 09690000
SMFINC   DS    0H                                                       09700000
         STM   R0,R15,W#SMFIRS         Save registers                   09710000
*        Set instruction counter delta in previous counter table        09720000
         LA    R0,NUMCP                                                 09730001
         LA    R14,W#INSCTC            Current table                    09740001
         LA    R15,W#INSCTP            Previous table                   09750001
         SR    R6,R6                   Number of CP with count          09760001
SMFINCA  DS    0H                                                       09770000
         LM    R2,R3,0(R14)            Current entry                    09780001
         LTR   R2,R2                                                    09790001
         BNZ   SMFINCB                                                  09800000
         LTR   R3,R3                                                    09810001
         BZ    SMFINCE                                                  09820000
SMFINCB  DS    0H                                                       09830000
         LM    R4,R5,0(R15)            Previous entry                   09840001
         LTR   R4,R4                                                    09850001
         BNZ   SMFINCC                                                  09860000
         LTR   R5,R5                                                    09870001
         BZ    SMFINCE                                                  09880000
SMFINCC  DS    0H                                                       09890000
         AH    R6,=H'1'                Count active CP                  09900001
         SLR   R3,R5                                                    09910000
         BNM   SMFINCD                                                  09920000
         SH    R2,=H'1'                                                 09930000
SMFINCD  DS    0H                                                       09940000
         SR    R2,R4                                                    09950001
SMFINCE  DS    0H                                                       09960000
         STM   R2,R3,0(R15)            Save delta in previous entry     09970001
         AH    R14,=H'8'                                                09980000
         AH    R15,=H'8'                                                09990000
         BCT   R0,SMFINCA                                               10000000
         LTR   R6,R6                   Any active processors            10010001
         BNZ   SMFINCF                 Yes                              10020001
         MSG   'Incomplete instruction inverval',MSGNO=032              10030000
         LA    R15,W#XXBGN             SMF record start                 10040001
         AH    R15,W#XXLEN             Get instruction section address  10050001
         B     SMFINCI1                                                 10060001
SMFINCF  DS    0H                                                       10070000
*        Construct SMF instruction counter section                      10080000
         LA    R14,W#INSCTP            Delta instruction table          10090001
         LA    R15,W#XXBGN             SMF record start                 10100000
         AH    R15,W#XXLEN             Get instruction section address  10110000
         USING INCENT,R15                                               10120000
         LA    R0,NUMCP                                                 10130001
         SR    R1,R1                                                    10140000
SMFINCG  DS    0H                                                       10150000
         LM    R2,R3,0(R14)            Get delta counter                10160001
         LTR   R2,R2                                                    10170001
         BNZ   SMFINCH                                                  10180000
         LTR   R3,R3                                                    10190001
         BZ    SMFINCI                                                  10200000
SMFINCH  DS    0H                                                       10210000
         STM   R2,R3,INCINS            Six byte instrucion counter      10220000
         STH   R1,INCINS               Two byte CPU number              10230000
         AH    R15,=H'8'                                                10240000
SMFINCI  DS    0H                                                       10250000
         AH    R14,=H'8'               Next counter                     10260001
         AH    R1,=H'1'                Next CP number                   10270001
         BCT   R0,SMFINCG              Run table of counters            10280001
         DROP  R15                                                      10290000
SMFINCI1 DS    0H                                                       10300001
         LH    R1,W#XXLEN              Current record length            10310000
         LA    R14,W#XXBGN(R1)         Instruction section start        10320000
         SR    R15,R14                                                  10330000
         STCM  R1,15,W#XXIOF           Set instruction section offset   10340000
         LA    R0,8                    Get instruction section size     10350000
         STH   R0,W#XXILN              Instruction section length       10360000
         LR    R0,R15                  Get instruction section count    10370001
         SRL   R0,3                    Length / 8                       10380000
         STH   R0,W#XXION              Save instruction section count   10390000
         AH    R15,W#XXLEN             Add instruction section length   10400000
         STH   R15,W#XXLEN             New SMF record length            10410000
SMFINCJ  DS    0H                                                       10420000
*        Set previous counter to current counter                        10430000
         LA    R0,NUMCP                                                 10440001
         LA    R14,W#INSCTC                                             10450001
         LA    R15,W#INSCTP                                             10460001
SMFINCK  DS    0H                                                       10470000
         LM    R1,R2,0(R14)                                             10480000
         STM   R1,R2,0(R15)                                             10490000
         AH    R14,=H'8'                                                10500000
         AH    R15,=H'8'                                                10510000
         BCT   R0,SMFINCK                                               10520000
*        Report instruction counters                                    10530000
         LH    R6,W#XXION                                               10540001
         LTR   R6,R6                                                    10550001
         BZ    SMFINCN                                                  10560000
         L     R3,W#XXIOF                                               10570000
         LA    R3,W#XXBGN(R3)                                           10580000
         USING INCENT,R3                                                10590000
         SR    R4,R4                                                    10600000
         SR    R5,R5                                                    10610000
SMFINCL  DS    0H                                                       10620000
         MVC   W#INSMS,=C'CPU='                                         10630000
         UNPK  W#INSCPU,INCINSCP+1(2)                                   10640000
         TR    W#INSCPU(2),P#HEXTB-240                                  10650000
         MVI   W#INSCPU+2,C' '                                          10660000
         MVC   W#INSS,=C'Instructions='                                 10670000
         LM    R0,R1,INCINS                                             10680001
         N     R0,=A(X'0000FFFF')                                       10690001
         BAL   R14,EDTNUM                                               10700002
         MVC   W#INSCT,W#EDTNUM                                         10710001
         MSG   MF=(E,W#INSMSG),MSGNO=031                                10720001
         LM    R0,R1,INCINS                                             10730001
         N     R0,=A(X'0000FFFF')                                       10740001
         ALR   R5,R1                                                    10750001
         BC    12,SMFINCM                                               10760000
         AH    R4,=H'1'                                                 10770000
SMFINCM  DS    0H                                                       10780000
         AR    R4,R0                                                    10790001
         AH    R3,=H'8'                                                 10800000
         BCT   R6,SMFINCL                                               10810001
         MVC   W#INSMS(6),=C' Total'                                    10820000
         MVC   W#INSS,=C'Instructions='                                 10830000
         LR    R0,R4                                                    10840001
         LR    R1,R5                                                    10850001
         BAL   R14,EDTNUM                                               10860002
         MVC   W#INSCT,W#EDTNUM                                         10870001
         MSG   MF=(E,W#INSMSG),MSGNO=031                                10880000
*                                                                       10890003
         L     R0,=A(5*60*10000)     MIPS in 5 seconds                  10900003
         TM    W#FLG,W#FLGI05        5 second interval?                 10910003
         BO    SMFINCIN              Yes                                10920003
         L     R0,=A(15*60*10000)    MIPS in 15 seconds                 10930003
         TM    W#FLG,W#FLGI15        15 second interval?                10940003
         BO    SMFINCIN              Yes                                10950003
         L     R0,=A(30*60*10000)    MIPS in 30 seconds                 10960003
         TM    W#FLG,W#FLGI30        30 second interval?                10970003
         BO    SMFINCIN              Yes                                10980003
         L     R0,=A(60*60*10000)    MIPS in 60 seconds                 10990003
SMFINCIN DS    0H                                                       11000003
         LR    R14,R4                Get total instructions             11010003
         LR    R15,R5                                                   11020003
SMFINCM1 DS    0H                                                       11030003
         LTR   R14,R14               High word zero?                    11040003
         BNZ   SMFINCM2              No, divide by 2                    11050003
         LTR   R15,R15               Low word positive                  11060003
         BNM   SMFINCM3              Yes, get average MIPs              11070003
SMFINCM2 DS    0H                                                       11080003
         SRL   R0,1                  Divide interval by 2               11090003
         SRDL  R14,1                 Divide instructions by 2           11100003
         B     SMFINCM1              Try again                          11110003
SMFINCM3 DS    0H                                                       11120003
         DR    R14,R0                Get MIPS to 2 decimal places       11130003
         CVD   R15,W#DWORD                                              11140003
         MVC   W#INSMS(20),=C'       Average MIPS='                     11150003
         MVC   W#INSCT,=X'404040404040404040404020206B2021204B2020'     11160003
         ED    W#INSCT,W#DWORD+4                                        11170003
         MSG   MF=(E,W#INSMSG),MSGNO=031                                11180003
*                                                                       11190003
SMFINCN  DS    0H                                                       11200000
         DROP  R3                                                       11210000
*                                                                       11220000
SMFINCXT DS    0H                                                       11230000
         LM    R0,R15,W#SMFIRS         Restore registers                11240000
         BR    R14                     Exit                             11250000
*********************************************************************** 11260000
*        Number convert                                               * 11270000
*********************************************************************** 11280000
NNCVT    DS    0H                                                       11290000
         STM   R2,R7,W#NNCVTR                                           11300000
         LR    R2,R1                  Input number                      11310001
         SR    R0,R0                  Zero                              11320001
         SR    R1,R1                   result                           11330001
         LA    R15,12                 Size of number                    11340001
NNCVTA   DS    0H                                                       11350000
         CLI   0(R2),C','             Comma                             11360001
         BE    NNCVTB                 Yes, skip it                      11370001
         CLI   0(R2),C'.'             Period                            11380001
         BE    NNCVTB                 Yes, skip it                      11390001
         CLI   0(R2),C'0'             Not numeric                       11400001
         BL    NNCVTC                 Yes, done                         11410001
         LA    R3,10                  Get 10                            11420001
         MR    R0,R3                  Previous number * 10              11430001
         IC    R3,0(,R2)              Next digit                        11440001
         N     R3,=A(15)              Cleaned up                        11450001
         ALR   R1,R3                  Add to previous number            11460001
         BC    12,NNCVTB              If no carry                       11470001
         AL    R0,=F'1'               Add one (hopefully won't happen)  11480001
NNCVTB   DS    0H                                                       11490000
         AH    R2,=H'1'               Next character                    11500001
         BCT   R15,NNCVTA             Run all digits                    11510001
NNCVTC   DS    0H                                                       11520001
         LM    R2,R7,W#NNCVTR                                           11530000
         BR    R14                                                      11540000
*********************************************************************** 11550001
*        Convert 64 bit number to 15 digit edited number              * 11560001
*********************************************************************** 11570001
EDTNUM   DS    0H                                                       11580002
         CVD   R1,W#DWORD              Convert low word to decimal      11590001
         LTR   R1,R1                   Is low word negative             11600002
         BNM   EDTNUM10                No                               11610002
         SLL   R1,1                    Shift out                        11620002
         SRL   R1,1                     sign                            11630002
         CVD   R1,W#DWORD              Convert low word to decimal      11640002
         AP    W#DWORD,=P'+2147483648' Add X'80000000' for sign         11650002
EDTNUM10 DS    0H                                                       11660002
         LTR   R0,R0                                                    11670002
         BZ    EDTNUM30                                                 11680002
EDTNUM20 DS    0H                                                       11690002
         AP    W#DWORD,=P'+4294967296' Add X'100000000'                 11700002
         BCT   R0,EDTNUM20             Loop until nothing in hi reg     11710002
EDTNUM30 DS    0H                                                       11720002
         MVC   W#EDTNUM,=X'402020206B2020206B2020206B2020206B202120'    11730002
         ED    W#EDTNUM,W#DWORD        Edit 64 bit number to 15 digits  11740002
         BR    R14                                                      11750002
*********************************************************************** 11760000
*        Format SMF date                                              * 11770000
*********************************************************************** 11780000
FDATE    DS    0H                                                       11790000
         ST    R14,W#PDATE                                              11800000
         MVC   W#FMTDTE,=CL10' '                                        11810000
         CH    R1,=H'16'                                                11820000
         BL    FDDATEX                                                  11830000
         ST    R1,W#CURDTE                                              11840000
         ZAP   W#JLWK1,W#CURDTE+2(2)   GET JULIAN DATE                  11850000
         ZAP   W#JLWK2,=P'+365'        DAYS/YR = 365                    11860000
         ZAP   W#JLWK02,=P'+28'        FEB = 28                         11870000
         MVO   W#DWORD,W#CURDTE+1(1)   SIGN YEAR                        11880000
         DP    W#DWORD,=P'+4'          DIVIDE BY 4                      11890000
         CP    W#DWORD+7(1),=P'+0'     IS IT A LEAP YEAR ?              11900000
         BNZ   FDDATE2                  NO                              11910000
         ZAP   W#JLWK2,=P'+366'        DAYS/YR = 366                    11920000
         ZAP   W#JLWK02,=P'+29'        FEB = 29                         11930000
FDDATE2  DS    0H                                                       11940000
         LA    R1,W#JLWK01             POINT TO JANUARY                 11950000
         LA    R2,1                    SET MONTH                        11960000
FDDATE4  DS    0H                                                       11970000
         SP    W#JLWK1,0(2,R1)         MONTHS DISPLACEMENT              11980000
         BNP   FDDATE6                 IF EQUAL OR LESS THAN 0, BRANCH  11990000
         BCTR  R1,0                    POINT TO NEXT MONTH              12000000
         BCTR  R1,0                    POINT TO NEXT MONTH              12010000
         AH    R2,=H'1'                UP MONTH                         12020000
         B     FDDATE4                 LOOP                             12030000
FDDATE6  DS    0H                                                       12040000
         AP    W#JLWK1,0(2,R1)         ADD DAYS OF MONTH                12050000
         CVD   R2,W#DWORD              GET MONTH                        12060000
         OI    W#DWORD+7,X'0F'         DISPLAY SIGN                     12070000
         UNPK  W#DWORD(3),W#DWORD+6(2) UNPACK MONTH                     12080000
         MVC   W#FMTDTE+0(2),W#DWORD+1 MOVE MONTH                       12090000
         MVI   W#FMTDTE+2,C'/'                                          12100000
         OI    W#JLWK1+3,X'0F'         DISPLAY SIGN                     12110000
         UNPK  W#DWORD(3),W#JLWK1      UNPACK DAYS                      12120000
         MVC   W#FMTDTE+3(2),W#DWORD+1 MOVE DAYS                        12130000
         MVI   W#FMTDTE+5,C'/'                                          12140000
         UNPK  W#DWORD(3),W#CURDTE+1(2) UNPACK YEAR                     12150000
         MVC   W#FMTDTE+8(2),W#DWORD   MOVE YEAR                        12160000
         MVC   W#FMTDTE+6(2),=C'20'    Fake 20xxx                       12170000
FDDATEX  DS    0H                                                       12180000
         L     R14,W#PDATE                                              12190000
         BR    R14                                                      12200000
*********************************************************************** 12210000
*        Format SMF time                                              * 12220000
*********************************************************************** 12230000
FTIME    DS    0H                                                       12240000
         ST    R14,W#PTIME                                              12250000
         MVC   W#FMTTME,=CL12' '                                        12260000
         LTR   R1,R1                                                    12270000
         BZ    FTMEEX                                                   12280000
         SLR   R0,R0               ZERO REG FOR DIVIDE                  12290000
         D     R0,=F'+6000'        Get seconds 10ths and 100th          12300000
         LR    R15,R0              Save seconds 10ths and 100th         12310000
         SLR   R0,R0               Clear remainder                      12320000
         D     R0,=F'+60'          Get minutes                          12330000
         MH    R0,=H'+10000'       Shift minutes to MM0000              12340000
         ALR   R15,R0              Add in seconds 10ths and 100th       12350000
         CH    R1,=H'24'           Time greater than 1 day              12360000
         BL    FTMEHRS             No, use HH:MM:SS.TH format           12370000
         SLR   R14,R14             Zero for divide                      12380000
         D     R14,=F'+100'        Drop tenths and 100ths of sec        12390000
         SLR   R0,R0               Zero for divide                      12400000
         D     R0,=F'+24'          Convert hours to days                12410000
         MH    R1,=H'+100'         Shift days                           12420000
         AR    R1,R0               Add DD00 to HH                       12430000
         M     R0,=F'+10000'       Shift days and hours                 12440000
         ALR   R15,R1              Add days / hrs for DD HH:MM.SS       12450000
         CVD   R15,W#DWORD         Convert time to decimal              12460000
         MVC   W#FMTTME,=C'************'                                12470000
         B     FTMEEX              Exit                                 12480000
FTMEHRS  DS    0H                                                       12490000
         M     R0,=F'+1000000'     Shift hours to HH000000              12500000
         ALR   R15,R1              Add hours to get HH:MM:SS.TH         12510000
         CVD   R15,W#DWORD         Convert time to decimal              12520000
         UNPK  W#TMPTME,W#DWORD+3(5)                                    12530000
         OI    W#TMPTME+L'W#TMPTME-1,C'0'                               12540000
         MVI   W#FMTTME+0,C' '                                          12550000
         MVC   W#FMTTME+1(2),W#TMPTME+1                                 12560000
         MVI   W#FMTTME+3,C':'                                          12570000
         MVC   W#FMTTME+4(2),W#TMPTME+3                                 12580000
         MVI   W#FMTTME+6,C':'                                          12590000
         MVC   W#FMTTME+7(2),W#TMPTME+5                                 12600000
         MVI   W#FMTTME+9,C'.'                                          12610000
         MVC   W#FMTTME+10(2),W#TMPTME+7                                12620000
FTMEEX   DS    0H                  RETURN TO CALLER                     12630000
         L     R14,W#PTIME                                              12640000
         BR    R14                                                      12650000
*********************************************************************** 12660000
*        Enter key 0                                                  * 12670000
*********************************************************************** 12680000
KEY0     DS    0H                                                       12690000
         ST    R14,W#KY0R14            SAVE RETURN                      12700000
         MODESET KEY=ZERO,MODE=SUP     ENTER KEY ZERO                   12710000
         L     R14,W#KY0R14            RESTORE RETURN                   12720000
         BR    R14                     EXIT                             12730000
*********************************************************************** 12740000
*        Restore key                                                  * 12750000
*********************************************************************** 12760000
KEYN0    DS    0H                                                       12770000
         ST    R14,W#KYNR14            SAVE RETURN                      12780000
         MODESET KEY=NZERO,MODE=PROB   RESTORE KEY                      12790000
         L     R14,W#KYNR14            RESTORE RETURN                   12800000
         BR    R14                     EXIT                             12810000
*********************************************************************** 12820000
*        Set STIMER                                                   * 12830000
*********************************************************************** 12840000
STM      DS    0H                                                       12850001
         ST    R14,W#STMR14            SAVE RETURN                      12860000
         XC    W#STMECB,W#STMECB                                        12870001
         TIME  DEC                     GET TIME                         12880000
         SRDL  R0,28                   R0:R1=0000000h hmssthx           12890000
         LR    R15,R1                  R15=hmmssthx                     12900000
         SRL   R15,16                  R15=00000mms                     12910000
         N     R15,=X'00000FF0'        R15=00000mm0                     12920000
         XC    W#DWORD,W#DWORD                                          12930000
         ST    R15,W#DWORD+4                                            12940000
         OI    W#DWORD+7,15                                             12950000
         CVB   R15,W#DWORD             R15=current minute               12960000
         N     R1,=X'F0000000'         R1=h0000000                      12970000
         STM   R0,R1,W#DWORD           Time=hours and no mm ss or th    12980000
         OI    W#DWORD+7,15            Next STIMER                      12990000
         CH    R15,=H'05'                                               13000000
         BNL   STM0A                                                    13010000
         AP    W#DWORD,=P'+00050000' Next is 5 after                    13020000
         B     STM0L                                                    13030000
STM0A    DS    0H                                                       13040001
         CH    R15,=H'10'                                               13050000
         BNL   STM0B                                                    13060000
         AP    W#DWORD,=P'+00100000' Next is 10 after                   13070000
         B     STM0L                                                    13080000
STM0B    DS    0H                                                       13090001
         CH    R15,=H'15'                                               13100000
         BNL   STM0C                                                    13110000
         AP    W#DWORD,=P'+00150000' Next is 15 after                   13120000
         B     STM0L                                                    13130000
STM0C    DS    0H                                                       13140001
         CH    R15,=H'20'                                               13150000
         BNL   STM0D                                                    13160000
         AP    W#DWORD,=P'+00200000' Next is 20 after                   13170000
         B     STM0L                                                    13180000
STM0D    DS    0H                                                       13190001
         CH    R15,=H'25'                                               13200000
         BNL   STM0E                                                    13210000
         AP    W#DWORD,=P'+00250000' Next is 25 after                   13220000
         B     STM0L                                                    13230000
STM0E    DS    0H                                                       13240001
         CH    R15,=H'30'                                               13250000
         BNL   STM0F                                                    13260000
         AP    W#DWORD,=P'+00300000' Next is 30 after                   13270000
         B     STM0L                                                    13280000
STM0F    DS    0H                                                       13290001
         CH    R15,=H'35'                                               13300000
         BNL   STM0G                                                    13310000
         AP    W#DWORD,=P'+00350000' Next is 35 after                   13320000
         B     STM0L                                                    13330000
STM0G    DS    0H                                                       13340001
         CH    R15,=H'40'                                               13350000
         BNL   STM0H                                                    13360000
         AP    W#DWORD,=P'+00400000' Next is 40 after                   13370000
         B     STM0L                                                    13380000
STM0H    DS    0H                                                       13390001
         CH    R15,=H'45'                                               13400000
         BNL   STM0I                                                    13410000
         AP    W#DWORD,=P'+00450000' Next is 45 after                   13420000
         B     STM0L                                                    13430000
STM0I    DS    0H                                                       13440001
         CH    R15,=H'50'                                               13450000
         BNL   STM0J                                                    13460000
         AP    W#DWORD,=P'+00500000' Next is 50 after                   13470000
         B     STM0L                                                    13480000
STM0J    DS    0H                                                       13490001
         CH    R15,=H'55'                                               13500000
         BNL   STM0K                                                    13510000
         AP    W#DWORD,=P'+00550000' Next is 55 after                   13520000
         B     STM0L                                                    13530000
STM0K    DS    0H                                                       13540001
         AP    W#DWORD,=P'+01000000' Add 1 hour                         13550000
STM0L    DS    0H                                                       13560001
         CP    W#DWORD,=P'+24000000'                                    13570000
         BNE   STM0M                                                    13580000
         ZAP   W#DWORD,=P'+00000000'                                    13590000
STM0M    DS    0H                                                       13600001
         NI    W#FLG,255-W#FLGINT                                       13610000
         TM    W#FLG,W#FLGI05                                           13620000
         BNO   STM1A                                                    13630000
         OI    W#FLG,W#FLGINT          Recording interval               13640000
         B     STM1H                                                    13650000
STM1A    DS    0H                                                       13660001
         TM    W#FLG,W#FLGI15                                           13670000
         BNO   STM1E                                                    13680000
*        Set up recording interval for next 15 minute boundary          13690000
         CH    R15,=H'0'                                                13700000
         BNE   STM1B                                                    13710000
         OI    W#FLG,W#FLGINT          Recording interval               13720000
         B     STM1H                                                    13730000
STM1B    DS    0H                                                       13740001
         CH    R15,=H'15'                                               13750000
         BNE   STM1C                                                    13760001
         OI    W#FLG,W#FLGINT          Recording interval               13770000
         B     STM1H                                                    13780000
STM1C    DS    0H                                                       13790001
         CH    R15,=H'30'                                               13800000
         BNE   STM1D                                                    13810000
         OI    W#FLG,W#FLGINT          Recording interval               13820000
         B     STM1H                                                    13830000
STM1D    DS    0H                                                       13840001
         CH    R15,=H'45'                                               13850000
         BNE   STM1H                                                    13860000
         OI    W#FLG,W#FLGINT          Recording interval               13870000
         B     STM1H                                                    13880000
STM1E    DS    0H                                                       13890001
         TM    W#FLG,W#FLGI30                                           13900000
         BNO   STM1G                                                    13910000
*        Set up recording interval for next 30 minute boundary          13920000
         CH    R15,=H'0'                                                13930000
         BNE   STM1F                                                    13940000
         OI    W#FLG,W#FLGINT          Recording interval               13950000
         B     STM1H                                                    13960000
STM1F    DS    0H                                                       13970001
         CH    R15,=H'30'                                               13980000
         BNE   STM1H                                                    13990000
         OI    W#FLG,W#FLGINT          Recording interval               14000000
         B     STM1H                                                    14010000
STM1G    DS    0H                                                       14020001
         TM    W#FLG,W#FLGI60                                           14030000
         BNO   STM1H                                                    14040000
*        Set up recording interval for next hour                        14050000
         CH    R15,=H'0'                                                14060000
         BNE   STM1H                                                    14070000
         OI    W#FLG,W#FLGINT          Recording interval               14080000
STM1H    DS    0H                                                       14090001
*        Set STIMER                                                     14100000
         OI    W#DWORD+7,15            SET SIGN                         14110000
         UNPK  W#STMTM1,W#DWORD+3(5)                                    14120000
         MVC   W#STMTM2,=X'402021207A20207A20204B2020'                  14130000
         ED    W#STMTM2,W#DWORD+3      EDIT TIME                        14140000
         LA    R0,W#WAITRT                                              14150001
         STIMER REAL,(0),TOD=W#STMTM                                    14160000
         TTIMER ,MIC,W#TOGOB           Get whats left to WAIT           14170001
         TM    W#FLG,W#FLGDBG                                           14180000
         BNO   STM9                                                     14190000
         MVC   W#STMMS,=C'Next interval at '                            14200000
         MSG   MF=(E,W#STMMSG),MSGNO=005                                14210000
STM9     DS    0H                                                       14220001
         L     R14,W#STMR14            RESTORE RETURN                   14230000
         BR    R14                     EXIT                             14240000
*********************************************************************** 14250000
*        Send a message                                               * 14260000
*********************************************************************** 14270000
MSG      DS    0H                                                       14280000
         ST    R14,W#MSGR14            SAVE RETURN                      14290000
         CVD   R0,W#DWORD                                               14300000
         UNPK  W#MSGNN(3),W#DWORD+6(2)                                  14310000
         OI    W#MSGNN+2,C'0'                                           14320000
         CH    R0,=H'100'                                               14330000
         BNL   MSGA                                                     14340000
         MVI   W#MSGNN+3,C'I'                                           14350000
         B     MSGC                                                     14360000
MSGA     DS    0H                                                       14370000
         CH    R0,=H'200'                                               14380000
         BNL   MSGB                                                     14390000
         MVI   W#MSGNN+3,C'W'                                           14400000
         B     MSGC                                                     14410000
MSGB     DS    0H                                                       14420000
         MVI   W#MSGNN+3,C'E'                                           14430000
MSGC     DS    0H                                                       14440000
         MVI   W#MSGNN+4,C' '                                           14450000
         MVI   W#MSGTXT,C' '                                            14460000
         MVC   W#MSGTXT+1(L'W#MSGTXT-1),W#MSGTXT                        14470000
         EX    R15,MSGMOV              MOVE TO MESSAGE                  14480000
         LA    R15,14(,R15)            GET LENGTH                       14490000
         STH   R15,W#MSGLN             SAVE NEW MESSAGE LENGTH          14500000
         TM    W#PRTDCB+DCBOFLGS-IHADCB,DCBOFOPN                        14510000
         BO    MSGD                                                     14520000
         WTO   MF=(E,W#MSG)            SEND MESSAGE                     14530000
         B     MSGF                                                     14540000
MSGD     DS    0H                                                       14550000
         TM    W#FLG1,W#FLG1WT                                          14560000
         BNO   MSGE                                                     14570000
         WTO   MF=(E,W#MSG)            SEND MESSAGE                     14580000
MSGE     DS    0H                                                       14590000
*        Print message                                                  14600000
         TIME  BIN                                                      14610001
         BAL   R14,CVTTME                                               14620000
         MVI   W#LINE,C' '             Clear line                       14630000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              14640000
         MVC   W#LNEDTE,W#CVTMDY                                        14650001
         MVC   W#LNETME,W#CVTTOD                                        14660001
         MVC   W#LNEMSG,W#MSGPRT                                        14670001
         BAL   R14,PRT                                                  14680000
MSGF     DS    0H                                                       14690000
         L     R14,W#MSGR14            RESTORE RETURN                   14700000
         BR    R14                     EXIT                             14710000
*********************************************************************** 14720000
*        Initialization                                               * 14730000
*********************************************************************** 14740000
INT      DS    0H                                                       14750000
         ST    R14,W#INTR14            SAVE RETURN                      14760000
         ST    R2,W#PRMPRM                                              14770000
         MVC   W#SA,=C'DMON'           Mark save area                   14780001
         MVC   W#MSGID,P#SYSNM         GET MESSAGE ID                   14790000
         MVC   W#OPNLST,P#OPNLST                                        14800000
         MVC   W#PRTDCB,P#PRTDCB                                        14810000
         MVI   W#LINE,C' '             CLEAR CONTROL CHARACTER          14820000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              14830000
         MVC   W#HD1,W#LINE                                             14840000
         MVC   W#HD2,W#LINE                                             14850000
         MVI   W#HD1,C'1'                                               14860000
         MVC   W#HD1TTL,=C'M o n i t o r'                               14870000
         MVC   W#HD1PG,=C'Page'                                         14880000
         ZAP   W#LNCT,=P'+99'                                           14890000
         ZAP   W#PGCT,=P'+0'                                            14900000
         OPEN  (W#PRTDCB,(OUTPUT)),MF=(E,W#OPNLST)                      14910000
         TM    W#PRTDCB+DCBOFLGS-IHADCB,DCBOFOPN                        14920000
         BZ    PRTERR                                                   14930000
         MVI   W#SMFNO,SMFXX                                            14940000
*                                                                       14950000
         TIME  BIN                     GET CURRENT DATE AND TIME        14960001
         ST    R0,W#BGNTME                                              14970000
         LR    R15,R1                                                   14980000
         SLL   R15,8                                                    14990000
         SRL   R15,4                                                    15000000
         STCM  R15,15,W#BGNDTE                                          15010000
         OI    W#BGNDTE+3,X'0F'                                         15020000
         CLC   =X'01999365',W#BGNDTE   Date greater than 01999365       15030000
         BH    INTA                                                     15040000
         MVI   W#BGNDTE,1              21st century                     15050000
INTA     DS    0H                                                       15060000
         BAL   R14,CVTTME                                               15070000
         MVC   W#HD1TOD,W#CVTTOD       MOVE TIME                        15080000
         MVC   W#HD1DTE,W#CVTDTE       MOVE DATE                        15090000
*                                                                       15100000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            15110000
         MVC   W#LINE+9(L'PGMID),PGMID  Move version                    15120000
         BAL   R14,PRT             Print Version=                       15130000
         MVC   W#LINE+1(5),=C'Parm=' Move parameter info literal        15140000
         L     R3,W#PRMPRM                                              15150000
         CLI   1(R3),0             Any parameter?                       15160000
         BE    PRMPARS             No, skip move                        15170000
         LH    R1,0(,R3)           Get parmeter length                  15180000
         BCTR  R1,0                Make machine length                  15190000
         EX    R1,PRMMVC           Move parm to print line              15200000
PRMPARS  DS    0H                                                       15210000
         BAL   R14,PRT             Print PARM=                          15220000
         BAL   R14,PRM             Parse PARM=                          15230000
INITPROK DS    0H                                                       15240000
         L     R0,=A(STAERTN)                                           15250000
         ESTAE (0),                    ESTABLISH ABEND ENVIRONMENT     *15260000
               PARAM=0(R13),                                           *15270001
               TERM=YES,                                               *15280000
               MF=(E,W#ESTLST)                                          15290000
         TESTAUTH FCTN=1                                                15300000
         LTR   R15,R15                                                  15310000
         BZ    INTAUTH                                                  15320001
         MSG   'Not authorized',MSGNO=200                               15330000
         LA    R15,8                                                    15340001
         B     STOP                    TERMINATE NOW                    15350001
INTAUTH  DS    0H                                                       15360001
         MVC   W#WAITRT,WAITRTN        Copy STIMER exit routine         15370001
         ST    R13,W#WAITW#            Save work area address           15380001
INITFINI DS    0H                                                       15390001
         L     R14,W#INTR14            RESTORE RETURN                   15400000
         BR    R14                     EXIT                             15410000
INITERPR DS    0H                                                       15420000
         MSG   'Parameter invalid',MSGNO=103                            15430000
         LA    R15,8                                                    15440001
         B     STOP                    TERMINATE NOW                    15450000
PRTERR   DS    0H                                                       15460000
         MSG   'SYSPRINT OPEN failed',MSGNO=104                         15470000
         LA    R15,8                                                    15480001
         B     STOP                    TERMINATE NOW                    15490000
SMFDDERR DS    0H                                                       15500000
         MSG   'SMF DD OPEN failed',MSGNO=105                           15510000
         LA    R15,8                                                    15520001
         B     STOP                    TERMINATE NOW                    15530000
SMFDDERM DS    0H                                                       15540000
         MSG   'SMF DD not DISP=MOD',MSGNO=106                          15550000
         LA    R15,8                                                    15560001
         B     STOP                    TERMINATE NOW                    15570000
**********************************************************************  15580000
*        Parse PARM=                                                 *  15590000
**********************************************************************  15600000
PRM      DS    0H                                                       15610000
         ST    R14,W#PRMR14                                             15620000
         L     R3,W#PRMPRM                                              15630000
         LH    R2,0(,R3)                                                15640000
         AH    R3,=H'2'                                                 15650000
PRMSCN   DS    0H                                                       15660000
         CH    R2,=H'0'                                                 15670000
         BE    PRMEND                                                   15680000
         CLI   0(R3),C','                                               15690000
         BNE   PRMCHK                                                   15700000
         AH    R3,=H'1'                                                 15710000
         SH    R2,=H'1'                                                 15720000
         B     PRMSCN                                                   15730000
PRMCHK   DS    0H                                                       15740000
         CH    R2,=H'3'                                                 15750001
         BL    PRMERR                                                   15760000
         CLC   =C'DD=',0(R3)                                            15770000
         BE    PRMDD                                                    15780000
         CH    R2,=H'5'                                                 15790000
         BL    PRMERR                                                   15800000
         CLC   =C'DEBUG',0(R3)                                          15810000
         BE    PRMDBG                                                   15820000
         CH    R2,=H'7'                                                 15830000
         BL    PRMERR                                                   15840000
         CLC   =C'SMF=',0(R3)                                           15850000
         BE    PRMSMF                                                   15860000
         CLC   =C'WTO=',0(R3)                                           15870000
         BE    PRMWTO                                                   15880000
         CH    R2,=H'11'                                                15890000
         BL    PRMERR                                                   15900000
         CLC   =C'INTERVAL=',0(R3)                                      15910000
         BE    PRMINT                                                   15920000
         B     PRMERR                                                   15930000
PRMDD    DS    0H                                                       15940000
         MVC   W#DD,=CL8' '                                             15950001
         AH    R3,=H'3'                                                 15960000
         SH    R2,=H'3'                                                 15970000
         BZ    PRMDDE                                                   15980001
         LA    R0,8                                                     15990000
         LA    R1,W#DD                                                  16000000
PRMDDA   DS    0H                                                       16010000
         CLI   0(R3),C','                                               16020000
         BE    PRMDDE                                                   16030000
         CLI   0(R3),C'A'                                               16040000
         BNL   PRMDDB                                                   16050000
         CLI   0(R3),C'@'                                               16060000
         BE    PRMDDD                                                   16070000
         CLI   0(R3),C'#'                                               16080000
         BE    PRMDDD                                                   16090000
         CLI   0(R3),C'$'                                               16100000
         BE    PRMDDD                                                   16110000
         B     PRMERR                                                   16120000
PRMDDB   DS    0H                                                       16130000
         CLI   0(R3),C'Z'                                               16140000
         BNH   PRMDDD                                                   16150000
         CLI   0(R3),C'0'                                               16160000
         BL    PRMERR                                                   16170000
PRMDDC   DS    0H                                                       16180000
         CLI   0(R3),C'9'                                               16190000
         BH    PRMERR                                                   16200000
PRMDDD   DS    0H                                                       16210000
         MVC   0(1,R1),0(R3)                                            16220000
         AH    R1,=H'1'                                                 16230000
         AH    R3,=H'1'                                                 16240000
         SH    R2,=H'1'                                                 16250000
         BZ    PRMDDE                                                   16260000
         BCT   R0,PRMDDA                                                16270000
PRMDDE   DS    0H                                                       16280000
         CLI   W#DD,C' '                                                16290000
         BE    PRMSCNC                                                  16300000
         DEVTYPE W#DD,W#DEVTYP                                          16310000
         LTR   R15,R15                                                  16320000
         BNZ   SMFDDERR                                                 16330000
         B     PRMSCNC                                                  16340000
PRMDBG   DS    0H                                                       16350000
         OI    W#FLG,W#FLGDBG                                           16360000
         AH    R3,=H'5'                                                 16370000
         SH    R2,=H'5'                                                 16380000
         B     PRMSCNC                                                  16390000
PRMSMF   DS    0H                                                       16400000
         AH    R3,=H'4'                                                 16410001
         SH    R2,=H'4'                                                 16420001
         BZ    PRMERR                                                   16430001
         CLI   0(R3),C'2'                                               16440001
         BNE   PRMERR                                                   16450000
         CLI   1(R3),C'0'                                               16460001
         BL    PRMERR                                                   16470000
         CLI   1(R3),C'9'                                               16480001
         BH    PRMERR                                                   16490000
         CLI   2(R3),C'0'                                               16500001
         BL    PRMERR                                                   16510000
         CLI   2(R3),C'9'                                               16520001
         BH    PRMERR                                                   16530000
         PACK  W#DWORD,0(3,R3)                                          16540001
         CVB   R0,W#DWORD                                               16550000
         CH    R0,=H'201'                                               16560000
         BL    PRMERR                                                   16570000
         CH    R0,=H'255'                                               16580000
         BH    PRMERR                                                   16590000
         STC   R0,W#SMFNO                                               16600000
         AH    R3,=H'3'                                                 16610001
         SH    R2,=H'3'                                                 16620001
         B     PRMSCNC                                                  16630000
PRMINT   DS    0H                                                       16640000
         AH    R3,=H'9'                                                 16650001
         SH    R2,=H'9'                                                 16660001
         BZ    PRMERR                                                   16670001
         CLC   =C'05',0(R3)                                             16680001
         BE    PRMINT05                                                 16690000
         CLC   =C'15',0(R3)                                             16700001
         BE    PRMINT15                                                 16710000
         CLC   =C'30',0(R3)                                             16720001
         BE    PRMINT30                                                 16730000
         CLC   =C'60',0(R3)                                             16740001
         BNE   PRMERR                                                   16750000
         OI    W#FLG,W#FLGI60                                           16760000
         B     PRMINT99                                                 16770000
PRMINT05 DS    0H                                                       16780000
         OI    W#FLG,W#FLGI05                                           16790000
         B     PRMINT99                                                 16800000
PRMINT15 DS    0H                                                       16810000
         OI    W#FLG,W#FLGI15                                           16820000
         B     PRMINT99                                                 16830000
PRMINT30 DS    0H                                                       16840000
         OI    W#FLG,W#FLGI30                                           16850000
         B     PRMINT99                                                 16860000
PRMINT99 DS    0H                                                       16870000
         AH    R3,=H'2'                                                 16880001
         SH    R2,=H'2'                                                 16890001
         B     PRMSCNC                                                  16900000
PRMWTO   DS    0H                                                       16910000
         AH    R3,=H'4'                                                 16920001
         SH    R2,=H'4'                                                 16930001
         BZ    PRMERR                                                   16940001
         CH    R2,=H'3'                                                 16950001
         BL    PRMERR                                                   16960000
         CLC   =C'YES',0(R3)                                            16970001
         BNE   PRMERR                                                   16980000
         OI    W#FLG1,W#FLG1WT                                          16990000
         AH    R3,=H'3'                                                 17000001
         SH    R2,=H'3'                                                 17010001
         B     PRMSCNC                                                  17020000
PRMSCNC  DS    0H                                                       17030000
         CH    R2,=H'0'                                                 17040000
         BE    PRMEND                                                   17050000
         CLI   0(R3),C','                                               17060000
         BE    PRMSCN                                                   17070000
         B     PRMERR                                                   17080000
PRMEND   DS    0H                                                       17090000
         BAL   R14,CMDOPT                                               17100001
         L     R14,W#PRMR14                                             17110000
         BR    R14                     RETURN TO CALLER                 17120000
PRMERR   DS    0H                                                       17130000
         LR    R1,R3                                                    17140000
         S     R1,W#PRMPRM                                              17150000
         LA    R1,W#LINE+4(R1)                                          17160001
         MVI   0(R1),C'*'                                               17170000
         BAL   R14,PRT                                                  17180000
         MVC   W#LINE(19),=C' Parameters invalid'                       17190000
         BAL   R14,PRT                                                  17200000
         B     INITERPR                 NO, PARAMETER ERROR             17210000
**********************************************************************  17220000
*        Convert TIME BIN to formatted date and time                 *  17230000
**********************************************************************  17240000
CVTTME   DS    0H                                                       17250000
         ST    R14,W#CVTR14                                             17260000
         ST    R0,W#CURTME                                              17270000
         ST    R1,W#CURDTE                                              17280001
         ZAP   W#JLWK13,=P'+1'                                          17290000
         ZAP   W#JLWK12,=P'+31'                                         17300000
         ZAP   W#JLWK11,=P'+30'                                         17310000
         ZAP   W#JLWK10,=P'+31'                                         17320000
         ZAP   W#JLWK09,=P'+30'                                         17330000
         ZAP   W#JLWK08,=P'+31'                                         17340000
         ZAP   W#JLWK07,=P'+31'                                         17350000
         ZAP   W#JLWK06,=P'+30'                                         17360000
         ZAP   W#JLWK05,=P'+31'                                         17370000
         ZAP   W#JLWK04,=P'+30'                                         17380000
         ZAP   W#JLWK03,=P'+31'                                         17390000
         ZAP   W#JLWK02,=P'+28'                                         17400000
         ZAP   W#JLWK01,=P'+31'                                         17410000
         SRDL  R0,32                   GET DOUBLE WORD TIME             17420000
         D     R0,=F'+6000'            GET MINUTES                      17430000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     17440000
         SLR   R0,R0                   CLEAR                            17450000
         D     R0,=F'+60'              GET HOURS / MINS                 17460000
         MH    R0,=H'+10000'           GET MINUTES                      17470000
         AR    R15,R0                  ADD TO GET MM:SS.TH              17480000
         M     R0,=F'+1000000'         GET HOURS                        17490000
         AR    R1,R15                  GET HH:MM:SS.TH                  17500000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              17510000
         MVC   W#TIMWRK,=X'402021204B20204B20204B2020'                  17520000
         ED    W#TIMWRK,W#DWORD+3      EDIT TIME                        17530000
         MVC   W#CVTTOD(11),W#TIMWRK+2 MOVE TIME                        17540000
         ZAP   W#JLWK1,W#CURDTE+2(2)   GET JULIAN DATE                  17550000
         ZAP   W#JLWK2,=P'+365'        DAYS/YR = 365                    17560000
         ZAP   W#JLWK02,=P'+28'        FEB = 28                         17570000
         MVO   W#DWORD,W#CURDTE+1(1)   SIGN YEAR                        17580000
         DP    W#DWORD,=P'+4'          DIVIDE BY 4                      17590000
         CP    W#DWORD+7(1),=P'+0'     IS IT A LEAP YEAR ?              17600000
         BNZ   JULCVT2                  NO                              17610000
         ZAP   W#JLWK2,=P'+366'        DAYS/YR = 366                    17620000
         ZAP   W#JLWK02,=P'+29'        FEB = 29                         17630000
JULCVT2  DS    0H                                                       17640000
         LA    R1,W#JLWK01             POINT TO JANUARY                 17650000
         SLR   R2,R2                   SET COUNTER                      17660000
JULCVT4  DS    0H                                                       17670000
         SP    W#JLWK1,0(2,R1)         MONTHS DISPLACEMENT              17680000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, JRANCH  17690000
         BCTR  R1,0                    POINT TO NEXT MONTH              17700000
         BCTR  R1,0                    POINT TO NEXT MONTH              17710000
         LA    R2,1(,R2)               UP INDEX                         17720000
         B     JULCVT4                 LOOP                             17730000
JULCVT6  DS    0H                                                       17740000
         AP    W#JLWK1,0(2,R1)         ADD DAYS OF MONTH                17750000
         LA    R0,1(,R2)                                                17760000
         CVD   R0,W#DWORD                                               17770000
         OI    W#DWORD+7,15                                             17780000
         UNPK  W#CVTMDY(2),W#DWORD                                      17790000
         MVI   W#CVTMDY+2,C'/'                                          17800000
         MH    R2,=H'3'                                                 17810000
         LA    R2,P#JLTBL2(R2)         ADDRESS MONTH                    17820000
         MVC   W#CVTDTE(3),0(R2)       MOVE MONTH                       17830000
         MVI   W#CVTDTE+3,C' '                                          17840001
         OI    W#JLWK1+3,X'0F'         DISPLAY SIGN                     17850000
         UNPK  W#CVTDTE+4(2),W#JLWK1   GET DAYS                         17860000
         MVC   W#CVTMDY+3(2),W#CVTDTE+4                                 17870000
         MVI   W#CVTMDY+5,C'/'                                          17880001
         CLI   W#CVTDTE+4,C'0'         FIRST 9 DAYS ?                   17890000
         LA    R1,W#CVTDTE+6           SET POINTER                      17900000
         BNE   JULCVT7                  NO                              17910000
         MVC   W#CVTDTE+4(1),W#CVTDTE+5 MOVE UNITS DIGIT                17920000
         BCTR  R1,0                    DROP POINTER                     17930000
JULCVT7  DS    0H                                                       17940000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  17950000
         TM    W#CURDTE,1              YEAR 2000?                       17960000
         BNO   JULCVT8                  NO, CONTINUE                    17970000
         MVC   2(2,R1),=C'20'          Y2K                              17980000
JULCVT8  DS    0H                                                       17990000
         UNPK  W#DWORD(3),W#CURDTE+1(2) UNPACK YEAR                     18000000
         MVC   W#CVTMDY+6(4),2(R1)                                      18010001
         MVC   4(2,R1),W#DWORD         GET YEAR                         18020000
         L     R14,W#CVTR14                                             18030000
         BR    R14                     RETURN TO CALLER                 18040000
*********************************************************************** 18050001
*                                                                     * 18060001
*********************************************************************** 18070001
TRC      DS    0H                                                       18080001
         MVC   W#LINE+1(8),0(R9)                                        18090001
         BAL   R14,PRT                                                  18100001
         BR    R8                                                       18110001
**********************************************************************  18120000
*        Write print line                                            *  18130000
**********************************************************************  18140000
PRT      DS    0H                                                       18150000
         ST    R14,W#PRTR14                                             18160000
         CP    W#LNCT,=P'+60'          END OF PAGE                      18170000
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   18180000
PRTHDRS  DS    0H                                                       18190000
         AP    W#PGCT,=P'+1'           COUNT PAGES                      18200000
         MVC   W#HD1PG#,=X'40202120'   PAGE COUNT MASK                  18210000
         ED    W#HD1PG#,W#PGCT         EDIT PAGE COUNT                  18220000
         PUT   W#PRTDCB,W#HD1          PRINT HEADING 1                  18230000
         PUT   W#PRTDCB,W#HD2          PRINT HEADING 2                  18240000
         ZAP   W#LNCT,=P'+2'           INIT LINE COUNT                  18250000
         MVI   W#LINE,C'0'             SKIP AFTER HEADING               18260000
PRTCHK   DS    0H                                                       18270000
         CLI   W#LINE,C'+'             OVERPRINT ?                      18280000
         BE    PRTLINE                  YES, DON'T COUNT                18290000
         CLI   W#LINE,C'1'             NEW LINE ?                       18300000
         BE    PRTHDRS                  YES, PRINT HEADER               18310000
         CLI   W#LINE,C' '             WRITE AFTER ADVANCING 1?         18320000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            18330000
         CLI   W#LINE,C'0'             WRITE AFTER ADVANCING 1?         18340000
         BE    PRTLINE2                 YES, GO CHECK IF FIT            18350000
         CLI   W#LINE,C'-'             WRITE AFTER ADVANCING 1?         18360000
         BE    PRTLINE3                 YES, GO CHECK IF FIT            18370000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       18380000
PRTLINE1 DS    0H                                                       18390000
         AP    W#LNCT,=P'+1'           ADD TO LINE COUNT                18400000
         B     PRTVFY                  GO SEE IF IT WILL FIT            18410000
PRTLINE2 DS    0H                                                       18420000
         AP    W#LNCT,=P'+2'           ADD TO LINE COUNT                18430000
         B     PRTVFY                  GO SEE IF IT WILL FIT            18440000
PRTLINE3 DS    0H                                                       18450000
         AP    W#LNCT,=P'+3'           ADD TO LINE COUNT                18460000
PRTVFY   DS    0H                                                       18470000
         CP    W#LNCT,=P'+60'          OVERFLOW ?                       18480000
         BH    PRTHDRS                  YES, FORCE HEADER               18490000
PRTLINE  DS    0H                                                       18500000
         PUT   W#PRTDCB,W#LINE         PRINT A LINE                     18510000
         MVI   W#LINE,C' '             CLEAR CONTROL CHARACTER          18520000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              18530000
         L     R14,W#PRTR14                                             18540000
         BR    R14                     RETURN TO CALLER                 18550000
*********************************************************************** 18560000
*        Dump data                                                    * 18570000
*          Input: R0 = Length of data to dump                         * 18580000
*                 R1 = Address of data to dump                        * 18590000
*********************************************************************** 18600000
DMP      DS    0H                                                       18610000
         STM   R0,R15,W#DMPRGS         SAVE REGISTERS                   18620000
         LR    R3,R1                   GET ADDRESS TO DUMP              18630000
         LR    R4,R0                   GET LENGTH                       18640000
         XC    W#DMPOFF,W#DMPOFF       SAVE OFFSET FOR DUMP             18650000
         MVI   W#DMPFLG,W#DMP1ST       FIRST LINE                       18660000
DMPDMPLP DS    0H                                                       18670000
         LTR   R4,R4                   ANY DATA TO DUMP ?               18680000
         BZ    DMPHEXXT                 YES, ALL DONE                   18690000
         TM    W#DMPFLG,W#DMP1ST       FIRST LINE?                      18700000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   18710000
         LA    R0,32                   DEFAULT LENGTH                   18720000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          18730000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           18740000
         LR    R14,R3                  GET CURRENT INPUT AREA           18750000
         SR    R14,R0                  BACK TO PREVIOUS AREA            18760000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       18770000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            18780000
         SR    R4,R0                   REDUCE LENGTH TO DO              18790000
         TM    W#DMPFLG,W#DMPDUP       DUPLICATE IN PROGRESS?           18800000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       18810000
         L     R14,W#DMPOFF            GET CURRENT OFFSET               18820000
         ST    R14,W#DUP1ST            SAVE AS FIRST OFFSET             18830000
         OI    W#DMPFLG,W#DMPDUP       SET DUPLICATE                    18840000
         B     DMPNXTLN                CONTINUE                         18850000
DMPDUPCK DS    0H                                                       18860000
         TM    W#DMPFLG,W#DMPDUP       DUPLICATE IN PROGRESS?           18870000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      18880000
         MVC   W#LINE+7(5),=C'lines'   MOVE LITERAL                     18890000
         LA    R2,W#LINE+13            OUTPUT AREA ADDRESS              18900000
         LA    R1,W#DUP1ST+2           ADDRESS OF OFFSET TO DUMP        18910000
         LA    R15,2                   CONVERT 4 BYTES                  18920000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            18930000
         MVI   W#LINE+17,C'-'          THRU LITERAL                     18940000
         L     R1,W#DMPOFF             GET CURRENT OFFSET               18950000
         SH    R1,=H'32'               GET LAST DUPLICATE OFFSET        18960000
         ST    R1,W#DUP1ST             SAVE FOR DUMPING                 18970000
         LA    R2,W#LINE+18            OUTPUT AREA ADDRESS              18980000
         LA    R1,W#DUP1ST+2           ADDRESS OF OFFSET TO DUMP        18990000
         LA    R15,2                   CONVERT 4 BYTES                  19000000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            19010000
         MVC   W#LINE+23(13),=C'same as above' MOVE LITERAL             19020000
         BAL   R14,PRT                 PRINT A LINE                     19030000
         NI    W#DMPFLG,255-W#DMPDUP   RESET DUPLICATE IN PROGRESS      19040000
DMPALIN  DS    0H                                                       19050000
         LA    R2,W#LINE+1             OUTPUT AREA ADDRESS              19060000
         LA    R1,W#DMPOFF+2           ADDRESS OF OFFSET TO DUMP        19070000
         LA    R15,2                   CONVERT 4 BYTES                  19080000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            19090000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     19100000
         LR    R1,R3                   ADDRESS OF DATA                  19110000
         LA    R5,32                   DEFAULT LENGTH                   19120000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          19130000
         BH    DMPDODMP                 YES, USE 32                     19140000
         LR    R5,R4                   USE WHAT IS LEFT                 19150000
DMPDODMP DS    0H                                                       19160000
         SR    R4,R5                   REDUCE AMOUNT TO DO              19170000
         MVI   W#LINE+89,C'*'          BOX IN DISPLAY PORTION           19180000
         BCTR  R5,0                    MAKE ZERO BASED                  19190000
         EX    R5,DMPMVC               DO MOVE                          19200000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          19210000
         LA    R5,1(,R5)               RESTORE LENGTH                   19220000
         MVI   W#LINE+122,C'*'         COMPLETE BOX                     19230000
DMPDMPHX DS    0H                                                       19240000
         LA    R15,4                   4 BYTES TO PROCESS               19250000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           19260000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               19270000
         LR    R15,R5                  USE LENGTH LEFT                  19280000
DMPDMPIT DS    0H                                                       19290000
         SR    R5,R15                  REDUCE AMOUNT TO DO              19300000
         BAL   R14,DMPDSP              CONVERT DATA                     19310000
         LA    R2,1(,R2)               SKIP 1 BYTE                      19320000
         LA    R0,W#LINE+43            HALFWAY POINT ADDRESS            19330000
         CR    R0,R2                   AT HALFWAY POINT?                19340000
         BNE   DMPDMPNX                 NO, CONTINUE                    19350000
         LA    R2,1(,R2)               SKIP 1 BYTE                      19360000
DMPDMPNX DS    0H                                                       19370000
         LTR   R5,R5                   ANY LEFT TO DO ?                 19380000
         BH    DMPDMPHX                 YES, GO DO IT                   19390000
         BAL   R14,PRT                 PRINT A LINE                     19400000
DMPNXTLN DS    0H                                                       19410000
         L     R1,W#DMPOFF             GET OFFSET IN RECORD             19420000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       19430000
         ST    R1,W#DMPOFF             SAVE OFFSET IN RECORD            19440000
         LA    R3,32(,R3)              NEXT INPUT AREA                  19450000
         NI    W#DMPFLG,255-W#DMP1ST NOT FIRST LINE                     19460000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             19470000
DMPHEXXT DS    0H                                                       19480000
         LM    R0,R15,W#DMPRGS         RESTORE CALLERS REGS             19490000
         BR    R14                     EXIT                             19500000
*                                                                       19510000
*                                                                       19520000
*                                                                       19530000
DMPDSP   DS    0H                                                       19540000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               19550000
         NI    0(R2),X'0F'             REMOVE ZONE                      19560000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             19570000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             19580000
         TR    0(2,R2),=C'0123456789ABCDEF' TRANSLATE TO HEX            19590000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        19600000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         19610000
         BCT   R15,DMPDSP              LOOP THRU DATA                   19620000
         BR    R14                     EXIT                             19630000
         DROP  R11,R12,R13                                              19640000
*********************************************************************** 19650000
*        STAE routine                                                 * 19660000
*********************************************************************** 19670000
STAERTN  DS    0H                                                       19680000
         USING STAERTN,R15                                              19690000
         LM    R10,R12,STAEBASE        Reload base registers            19700001
         DROP  R15                                                      19710000
         USING MONITOR,R10,R11,R12                                      19720000
         LR    R5,R14                  Save return address              19730000
         L     R13,0(,R1)              Get work area address            19740001
         USING W#,R13                                                   19750000
         TM    W#FLG,W#FLGABE          Been here before                 19760000
         BNO   STAEBGN                 No, continue                     19770000
         LR    R14,R5                  RESTORE RETURN ADDRESS           19780000
         LA    R15,16                  SET NO RETRY                     19790000
         SLR   R0,R0                   SET NO RETRY ROUTINE ADDRESS     19800000
         BR    R14                     RETURN TO SUPERVISOR             19810000
STAEBGN  DS    0H                                                       19820000
         OI    W#FLG,W#FLGABE          Try to prevent recursion         19830000
         MVC   W#DMPTTL,=C'MONITOR Abend '                              19840000
         CH    R0,=H'12'               NO SDWA AVAILABLE ?              19850000
         BNE   STAESDWA                 NO, FORMAT SDUMP HEADER         19860000
         ST    R1,W#DWORD+4            SAVE COMPLETION CODE             19870000
         UNPK  W#DWORD(7),W#DWORD+4(4) SET UP TO CONVERT                19880000
         TR    W#DWORD(6),P#HEXTB-240  Convert A-F                      19890001
         CLC   W#DWORD(3),=C'000'      System abend                     19900001
         BE    STAENSDU                No, user abend                   19910001
         MVI   W#DMPABT,C'S'           Set system abend                 19920001
         MVC   W#DMPABC(3),W#DWORD     Move system code to msg          19930001
         B     STAENSDM                                                 19940001
STAENSDU DS    0H                                                       19950001
         MVI   W#DMPABT,C'U'           Set user abend                   19960001
         MVC   W#DMPABC,W#DWORD+3      Move user code to msg            19970001
STAENSDM DS    0H                                                       19980001
         MVC   W#DMPSDW,=C' No SDWA '                                   19990000
         MVC   W#DMPSDA,=6C' '                                          20000000
         B     STAEDMSG                                                 20010001
STAESDWA DS    0H                                                       20020000
         LR    R4,R1                   GET SDWA ADDRESS                 20030000
         USING SDWA,R4                 ADDRESSABILITY TO SDWA           20040000
         UNPK  W#DWORD(7),SDWACMPC(4)  CONVERT TO ZONED                 20050000
         TR    W#DWORD(6),P#HEXTB-240  Convert A-F                      20060001
         CLC   W#DWORD(3),=C'000'      System abend                     20070001
         BE    STAESDU                 No, user abend                   20080001
         MVI   W#DMPABT,C'S'           Set system abend                 20090001
         MVC   W#DMPABC(3),W#DWORD     Move system code to msg          20100001
         B     STAESDM                                                  20110001
STAESDU  DS    0H                                                       20120001
         MVI   W#DMPABT,C'U'           Set user abend                   20130001
         MVC   W#DMPABC,W#DWORD+3      Move user code to msg            20140001
STAESDM  DS    0H                                                       20150001
         MVC   W#DMPSDW,=C' SDWA at '                                   20160000
         ST    R4,W#DWORD              GET SDWA ADDRESS                 20170000
         UNPK  W#DMPSDA(7),W#DWORD+1(4) CONVERT ADDRESS                 20180000
         MVI   W#DMPSDA+6,C' '         CLEAR JUNK                       20190000
         TR    W#DMPSDA,P#HEXTB-240                                     20200000
STAEDMSG DS    0H                                                       20210001
         MSG   MF=(E,W#DMPHDR),MSGNO=008                                20220000
         MVI   W#DMPHD,L'W#DMPHDR                                       20230000
         MVC   W#SDPLST,P#SDPLST                                        20240000
         SDUMP HDRAD=W#DMPHD,                                          *20250000
               SDATA=(SQA,PSA,NUC,RGN,LPA,TRT,CSA,SUM),                *20260000
               MF=(E,W#SDPLST)                                          20270000
         LTR   R15,R15                 DID DUMP TAKE ?                  20280000
         BZ    STAEOK                   YES, CONTINUE                   20290000
         MVC   W#SDFMS,=C'SDUMP failed RC=X'''                          20300000
         STM   R15,R0,W#DWORD                                           20310000
         UNPK  W#SDFMSR(9),W#DWORD(5)                                   20320000
         TR    W#SDFMSR(8),P#HEXTB-240                                  20330000
         MVC   W#SDFMSQ,=C''' R0=X'''                                   20340000
         UNPK  W#SDFMS0(9),W#DWORD+4(5)                                 20350000
         TR    W#SDFMS0(8),P#HEXTB-240                                  20360000
         MVI   W#SDFMSZ,C''''                                           20370000
         MSG   MF=(E,W#SDFMSG),MSGNO=202                                20380000
         B     STAEXT                  CONTINUE                         20390000
STAEOK   DS    0H                                                       20400000
         MSG   'SDUMP initiated',MSGNO=009                              20410000
STAEXT   DS    0H                                                       20420000
         MVC   W#LINE(9),=C' SDWA at '                                  20430000
         ST    R4,W#DWORD              GET SDWA ADDRESS                 20440000
         UNPK  W#LINE+9(9),W#DWORD(5)  CONVERT ADDRESS                  20450000
         TR    W#LINE+9(8),P#HEXTB-240                                  20460000
         MVI   W#LINE+17,C' '          CLEAR JUNK                       20470000
         BAL   R14,PRT                                                  20480000
         LA    R1,SDWA                                                  20490000
         LA    R0,SDWAEND-SDWA                                          20500000
         BAL   R14,DMP                                                  20510000
         LR    R14,R5                  RESTORE RETURN ADDRESS           20520000
         LA    R15,16                  SET NO RETRY                     20530000
         SLR   R0,R0                   SET NO RETRY ROUTINE ADDRESS     20540000
         BR    R14                     RETURN TO SUPERVISOR             20550000
STAEBASE DC    A(MONITOR,MONITOR+4096,MONITOR+8192)                     20560000
         DROP  R4                                                       20570000
*********************************************************************** 20580000
*        Executed instructions                                        * 20590001
*********************************************************************** 20600000
         USING CIB,R4                                                   20610000
CIBMVC   MVC   W#PARM(0),CIBDATA       <<< EXECUTED >>>                 20620000
         DROP  R4                                                       20630000
CMDCHK   CLC   W#PARM(0),2(R3)         <<< EXECUTED >>>                 20640000
MVCCMDP  MVC   W#LINE+9(0),W#DG8P1     Move command to message          20650001
MSGMOV   MVC   W#MSGTXT(0),0(R1)       <<< EXECUTED >>>                 20660001
PRMMVC   MVC   W#LINE+6(0),2(R3)       <<< EXECUTED >>>                 20670001
DMPMVC   MVC   W#LINE+90(0),0(R1)      <<< EXECUTED >>>                 20680001
DMPTR    TR    W#LINE+90(0),P#DMPTBL   <<< EXECUTED >>>                 20690001
CODEEND  EQU   *                                                        20700001
         DC    (((((*-MONITOR)/256)+1)*256)-(*-MONITOR))X'CC'           20710001
         DROP  ,                                                        20720001
*********************************************************************** 20730001
*        Constants                                                    * 20740001
*********************************************************************** 20750001
*********************************************************************** 20760001
*        STIMER Expired Exit                                          * 20770001
*********************************************************************** 20780001
         DC    (((((*-MONITOR)/32)+1)*32)-(*-MONITOR))X'00'             20790001
WAITRTN  SAVE  (14,12)                 Save registers                   20800001
         USING WAITRTN,R15                                              20810001
         L     R2,WAITW#               W# address                       20820001
         DROP  R15                                                      20830001
         USING W#,R2                                                    20840001
         POST  W#STMECB                POST STIMER Expired              20850001
         DROP  R2                                                       20860001
         RETURN (14,12)                Return to control program        20870001
WAITW#   DS    0A                                                       20880001
WAITLEN  EQU   *-WAITRTN                                                20890001
P#SYSNM  DC    CL4'DMON'                                                20900000
P#CMDMR  DC    C'MAXRATES'                                              20910000
*                                                                       20920000
P#COMTBL DC    0D'+0'                                                   20930000
         DC    H'+0',CL8'STATUS  ',AL1(0,0),A(CMDSTA)                   20940000
P#COMLEN EQU   *-P#COMTBL                                               20950000
         DC    H'+2',CL8'DISABLE ',AL1(0,0),A(CMDDIS)                   20960000
         DC    H'+2',CL8'ENABLE  ',AL1(0,0),A(CMDENA)                   20970000
         DC    H'+4',CL8'DEBUG   ',AL1(0,0),A(CMDDBG)                   20980000
         DC    H'+3',CL8'SNAP    ',AL1(0,0),A(CMDSNP)                   20990000
         DC    H'+3',CL8'STOP    ',AL1(0,0),A(CIBEND)                   21000000
         DC    H'+3',CL8'DUMP    ',AL1(0,0),A(CMDDMP)                   21010000
         DC    H'+2',CL8'WTO     ',AL1(0,0),A(CMDWTO)                   21020000
         DC    H'+2',CL8'OPTIONS ',AL1(0,0),A(CMDOPT)                   21030001
P#COMCNT EQU   (*-P#COMTBL)/16                                          21040000
*                                                                       21050000
P#SDPLS  SDUMP HDRAD=*-*,                                              *21060000
               SDATA=(SQA,PSA,NUC,RGN,LPA,TRT,CSA,SUM),                *21070000
               MF=L                                                     21080000
P#SDPLST EQU   P#SDPLS,*-P#SDPLS                                        21090000
*                                                                       21100000
P#DMPTBL DC    CL256' '                                                 21110000
         ORG   P#DMPTBL+X'4A' Cent                                      21120000
         DC    X'4A4B4C4D4E4F50'                                        21130000
         ORG   P#DMPTBL+X'5A' exclamation                               21140000
         DC    X'5A5B5C5D5E5F6061'                                      21150000
         ORG   P#DMPTBL+X'6A'                                           21160000
         DC    X'6A6B6C6D6E6F'                                          21170000
         ORG   P#DMPTBL+X'7A'                                           21180000
         DC    X'7A7B7C7D7E7F'                                          21190000
         ORG   P#DMPTBL+C'a'                                            21200000
         DC    C'abcdefghi'                                             21210000
         ORG   P#DMPTBL+C'j'                                            21220000
         DC    C'jklmnopqr'                                             21230000
         ORG   P#DMPTBL+C's'                                            21240000
         DC    C'stuvwxyz'                                              21250000
         ORG   P#DMPTBL+C'A'                                            21260000
         DC    C'ABCDEFGHI'                                             21270000
         ORG   P#DMPTBL+C'J'                                            21280000
         DC    C'JKLMNOPQR'                                             21290000
         ORG   P#DMPTBL+C'S'                                            21300000
         DC    C'STUVWXYZ'                                              21310000
         ORG   P#DMPTBL+C'0'                                            21320000
         DC    C'0123456789'                                            21330000
         ORG   ,                                                        21340000
*                                                                       21350000
P#HEXTB  DC    C'0123456789ABCDEF'                                      21360000
P#JLTBL2 DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  21370000
*                                                                       21380000
P#OPNLSB OPEN  (0,(INPUT)),MF=L                                         21390000
P#OPNLST EQU   P#OPNLSB,*-P#OPNLSB                                      21400000
*                                                                       21410000
P#PRTDBG DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X21420000
               RECFM=FBA,LRECL=133                                      21430000
P#PRTDCB  EQU  P#PRTDBG,*-P#PRTDBG                                      21440000
*                                                                       21450000
P#SMFDBG DCB   DDNAME=XXXXXXXX,MACRF=PM,DSORG=PS,                      X21460000
               RECFM=VB,LRECL=32756                                     21470000
P#SMFDCB EQU   P#SMFDBG,*-P#SMFDBG                                      21480000
*                                                                       21490000
         LTORG ,                                                        21500000
DATAEND  EQU   *                                                        21510001
         DC    (((((*-MONITOR)/32)+1)*32)-(*-MONITOR))X'DD'             21520001
*********************************************************************** 21530000
*        Work areas                                                   * 21540000
*********************************************************************** 21550000
W#       DSECT ,                                                        21560000
W#SA     DS    18A                                                      21570000
W#TOGOB  DS    D                                                        21580001
W#TOGOC  DS    D                                                        21590001
W#TRCREG DS    16A                                                      21600001
W#DWORD  DS    D                                                        21610000
W#SMFMIP DS    D                                                        21620000
W#SMFIOS DS    D                                                        21630000
W#PRMPRM DS    A                                                        21640000
W#INTR14 DS    A                                                        21650000
W#PRMR14 DS    A                                                        21660000
W#STAR14 DS    A                                                        21670000
W#OPTR14 DS    A                                                        21680001
W#DISR14 DS    A                                                        21690000
W#ENAR14 DS    A                                                        21700000
W#ABER14 DS    A                                                        21710000
W#DBGR14 DS    A                                                        21720000
W#SNPR14 DS    A                                                        21730000
W#KY0R14 DS    A                                                        21740000
W#KYNR14 DS    A                                                        21750000
W#STMR14 DS    A                                                        21760000
W#MSGR14 DS    A                                                        21770000
W#BLDR14 DS    A                                                        21780000
W#WTOR14 DS    A                                                        21790000
W#NNCVTR DS    8A                                                       21800000
W#CVTR14 DS    A                                                        21810000
W#SMFMXE DS    A                                                        21820000
W#HRCCME DS    A                                                        21830000
W#FIXECB DS    A                                                        21840000
W#DEVTYP DS    2A                                                       21850000
W#PRTR14 DS    A                                                        21860000
W#DMPR14 DS    A                                                        21870000
W#PTIME  DS    A                                                        21880000
W#PDATE  DS    A                                                        21890000
W#STMID  DS    A                                                        21900000
W#EXTANS DS    A                                                        21910000
W#STMECB DS    A                                                        21920001
W#WAITLS DS    2A                                                       21930000
W#SMFIRS DS    16A                                                      21940000
W#PRBIRS DS    16A                                                      21950000
W#FLG    DS    X                                                        21960000
W#FLGACT EQU   X'80'                                                    21970000
W#FLGI05 EQU   X'40'                                                    21980000
W#FLGI15 EQU   X'20'                                                    21990000
W#FLGI30 EQU   X'10'                                                    22000000
W#FLGI60 EQU   X'08'                                                    22010000
W#FLGINT EQU   X'04'                                                    22020000
W#FLGABE EQU   X'02'                                                    22030000
W#FLGDBG EQU   X'01'                                                    22040000
*                                                                       22050000
W#FLG1   DS    X                                                        22060000
W#FLG1SR EQU   X'80'                                                    22070000
W#FLG1WT EQU   X'40'                                                    22080000
*                                                                       22090000
W#EXTLST EXTRACT 0,'S',FIELDS=COMM,MF=L                                 22100000
W#ESTLST ESTAE 0,MF=L                                                   22110000
*                                                                       22120000
W#EDTNUM DS    X'402020204B2020204B2020204B2020204B202120'              22130001
*                                                                       22140001
         DS    0D                                                       22150000
W#SDPLS  SDUMP HDRAD=*-*,                                              *22160000
               SDATA=(SQA,PSA,NUC,RGN,LPA,TRT,CSA,SUM),                *22170000
               MF=L                                                     22180000
W#SDPLST EQU   W#SDPLS,*-W#SDPLS                                        22190000
W#MIPS   DS    C'nnnn.nnnnnn '                                          22200000
W#IOS    DS    C'nnnn.nnnnnn '                                          22210000
*                                                                       22220000
W#STMTM1 DS    0CL9                                                     22230000
         DS    C                                                        22240000
W#STMTM  DS    C'HHMMSSTH'                                              22250000
*                                                                       22260000
W#STMMS  DS    C'Next recording at'                                     22270000
W#STMTM2 DS    X'402021207A20207A20204B2020'                            22280000
W#STMMSG EQU   W#STMMS,*-W#STMMS                                        22290000
*                                                                       22300000
W#SMFMS  DS    C'SMF record '                                           22310001
W#SMFMS# DS    C'000'                                                   22320000
W#SMFMSG EQU   W#SMFMS,*-W#SMFMS                                        22330000
*                                                                       22340000
W#INTMS  DS    C'Recording Interval='                                   22350001
W#INTMS# DS    C'00'                                                    22360000
W#INTMSG EQU   W#INTMS,*-W#INTMS                                        22370000
*                                                                       22380000
W#MIPMS  DS    C'MIPs='                                                 22390000
W#MIPVAL DS    CL(L'W#MIPS)                                             22400000
W#IOMS   DS    C'I/Os='                                                 22410000
W#IOVAL  DS    CL(L'W#IOS)                                              22420000
W#HRCMSG EQU   W#MIPMS,*-W#MIPMS                                        22430000
*                                                                       22440000
W#INSMS  DS    C'CPU='                                                  22450000
W#INSCPU DS    C'XX '                                                   22460000
W#INSS   DS    C'Instructions='                                         22470000
W#INSCT  DS    X'402020206B2020206B2020206B2020206B202120'              22480000
W#INSMSG EQU   W#INSMS,*-W#INSMS                                        22490000
*                                                                       22500000
W#CIBMS  DS    C'Invalid CIB verb=X'''                                  22510000
W#CIBVRB DS    C'XX'                                                    22520000
W#CIBMSQ DS    C''''                                                    22530000
W#CIBMSG EQU   W#CIBMS,*-W#CIBMS                                        22540000
*                                                                       22550000
W#RECMS  DS    C'Records written'                                       22560000
W#RECMS# DS    X'40206B2020206B202120'                                  22570000
W#RECMSG EQU   W#RECMS,*-W#RECMS                                        22580000
*                                                                       22590000
W#RCMS   DS    C'Return code'                                           22600000
W#RCMSRC DS    X'4020206B202120'                                        22610000
W#RCMSG  EQU   W#RCMS,*-W#RCMS                                          22620000
*                                                                       22630000
W#CMDMS  DS    C'Processing command:'                                   22640000
W#CMDMSP DS    CL32                                                     22650000
W#CMDMSG EQU   W#CMDMS,*-W#CMDMS                                        22660000
*                                                                       22670000
W#DDMS   DS    C'Recording to DD '                                      22680001
W#DDDD   DS    CL8                                                      22690000
W#DDMSG  EQU   W#DDMS,*-W#DDMS                                          22700000
*                                                                       22710000
W#DMPHD  DS    AL1(L'W#DMPHDR)                                          22720000
W#DMPTTL DS    C'MONITOR Abend '                                        22730000
W#DMPABT DS    C'X'                                                     22740001
W#DMPABC DS    C'000'                                                   22750001
W#DMPSDW DS    C' SDWA AT '                                             22760000
W#DMPSDA DS    C'123456'                                                22770000
W#DMPHDR EQU   W#DMPTTL,*-W#DMPTTL                                      22780000
*                                                                       22790000
W#QEFMS  DS    C'QEDIT xxxxxx failed, RC=X'''                           22800000
W#QEFMSR DS    C'XXXXXXXX'                                              22810000
W#QEFMSQ DS    C''''                                                    22820000
W#QEFMSG EQU   W#QEFMS,*-W#QEFMS                                        22830000
*                                                                       22840000
W#SDFMS  DS    C'SDUMP failed RC=X'''                                   22850000
W#SDFMSR DS    C'XXXXXXXX'                                              22860000
W#SDFMSQ DS    C''' R0=X'''                                             22870000
W#SDFMS0 DS    C'XXXXXXXX'                                              22880000
W#SDFMSZ DS    C''''                                                    22890000
W#SDFMSG EQU   W#SDFMS,*-W#SDFMS                                        22900000
*                                                                       22910000
W#PARM   DS    CL100                                                    22920000
*                                                                       22930000
W#MSG    DS    0A                                                       22940000
W#MSGLN  DS    2H                                                       22950000
W#MSGID  DS    CL4                                                      22960000
W#MSGNN  DS    C'nnnx '                                                 22970000
W#MSGTXT DS    CL100                                                    22980000
W#MSGPRT EQU   W#MSGID,*-W#MSGID                                        22990000
*                                                                       23000000
W#LINE   DS    CL133                                                    23010000
         ORG   W#LINE+1                                                 23020001
W#LNEDTE DS    C'mm/dd/yyyy'                                            23030001
         DS    C                                                        23040001
W#LNETME DS    C'hh:mm:ss.th'                                           23050001
         DS    C                                                        23060001
W#LNEMSG DS    CL109                                                    23070001
         ORG   ,                                                        23080001
MSG031   EQU   W#LINE+1,24                                              23090000
MSG034   EQU   W#LINE+1,24                                              23100001
MSG036   EQU   W#LINE+1,50                                              23110001
*                                                                       23120000
W#CURTME DS    A                                                        23130000
W#CURDTE DS    A                                                        23140000
W#JLWK1  DS    A                                                        23150000
W#JLWK2  DS    P'+365'                                                  23160000
W#JLWK13 DS    P'+01'                                                   23170000
W#JLWK12 DS    P'+31'                                                   23180000
W#JLWK11 DS    P'+30'                                                   23190000
W#JLWK10 DS    P'+31'                                                   23200000
W#JLWK09 DS    P'+30'                                                   23210000
W#JLWK08 DS    P'+31'                                                   23220000
W#JLWK07 DS    P'+31'                                                   23230000
W#JLWK06 DS    P'+30'                                                   23240000
W#JLWK05 DS    P'+31'                                                   23250000
W#JLWK04 DS    P'+30'                                                   23260000
W#JLWK03 DS    P'+31'                                                   23270000
W#JLWK02 DS    P'+28'                                                   23280000
W#JLWK01 DS    P'+31'                                                   23290000
W#TIMWRK DS    X'402021204B20204B20204B2020'                            23300000
W#CVTTOD DS    C'hh:mm:ss',C'.th'                                       23310000
W#CVTDTE DS    C'mmm 12, 2000'                                          23320000
W#CVTMDY DS    C'mm/dd/yyyy'                                            23330000
*                                                                       23340000
W#LNCT   DS    PL2'+99'                                                 23350000
W#PGCT   DS    PL2'+0'                                                  23360000
*                                                                       23370000
W#HD1    DS    CL133                                                    23380000
         ORG   W#HD1+1                                                  23390000
W#HD1DTE DS    C'            '                                          23400000
         DS    C' '                                                     23410000
W#HD1TOD DS    C'HH:MM:SS'                                              23420000
         ORG   W#HD1+66-(13/2)                                          23430000
W#HD1TTL DS    C'M o n i t o r'                                         23440000
         ORG   W#HD1+L'W#HD1-8                                          23450000
W#HD1PG  DS    C'Page'                                                  23460000
W#HD1PG# DS    C' 123'                                                  23470000
*                                                                       23480000
W#HD2    DS    CL133                                                    23490000
*                                                                       23500000
W#OPNLSB OPEN  (0,(INPUT)),MF=L                                         23510000
W#OPNLST EQU   W#OPNLSB,*-W#OPNLSB                                      23520000
*                                                                       23530000
W#PRTDCS DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X23540000
               RECFM=FBA,LRECL=133                                      23550000
W#PRTDCB EQU   W#PRTDCS,*-W#PRTDCS                                      23560000
*                                                                       23570000
W#DMPRGS DS    16A                                                      23580000
W#DMPOFF DS    A                                                        23590000
W#DUP1ST DS    A                                                        23600000
W#DMPFLG DS    X                                                        23610000
W#DMP1ST EQU   X'80'                                                    23620000
W#DMPDUP EQU   X'40'                                                    23630000
*                                                                       23640000
         DS    0D                                                       23650000
W#TMCVTT DS    XL8                                                      23660000
W#TMCVTD DS    XL4                                                      23670000
W#TMCVT0 DS    XL4                                                      23680000
W#TMCVT  EQU   W#TMCVTT,*-W#TMCVTT                                      23690000
*                                                                       23700000
W#TMWRK  DS    CL9                                                      23710000
*                                                                       23720000
W#TMPTME DS    C'0hhmmssth'                                             23730000
W#FMTTME DS    C' hh:mm:ss.th'                                          23740000
W#FMTDTE DS    C'mm/dd/yyyy'                                            23750000
W#DD     DS    CL8' '                                                   23760000
W#RECCNT DS    A                                                        23770000
W#BGNTME DS    BL4       TOD interval started                           23780000
W#BGNDTE DS    PL4       DATE interval started                          23790000
*                                                                       23800000
W#SMFDC  DCB   DDNAME=XXXXXXXX,MACRF=PM,DSORG=PS,                      X23810001
               RECFM=VB,LRECL=32756                                     23820000
W#SMFDCB EQU   W#SMFDC,*-W#SMFDC                                        23830000
*                                                                       23840000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           23850001
W#WAITRT DS    XL(WAITLEN)                                              23860001
W#WAITW# DS    A(0)                                                     23870001
*                                                                       23880001
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           23890001
******* DIAGNOSE 8 INTERFACE PARAMETERS PARAMETER 1 (R1) ************** 23900000
W#DG8P1  DS    CL64           COMMAND                                   23910001
*********************************************************************** 23920000
******* DIAGNOSE 8 INTERFACE PARAMETERS PARAMETER 2 (R1+1) ************ 23930000
W#DG8P2  DS    CL1024         COMMAND RESPONSE                          23940000
*********************************************************************** 23950000
******* DIAGNOSE 8 INTERFACE PARAMETERS PARAMETER 3 (R2) ************** 23960000
W#DG8P3  DS    X              FLAGS                                     23970000
W#DG8P3L DS    AL3            COMMAND LENGTH                            23980000
*********************************************************************** 23990000
W#CPUCTA DS    A                                                        24000000
W#CPUABG DS    H                                                        24010000
W#CPUAND DS    H                                                        24020000
W#CPUCT  DS    H         Number of processors                           24030000
SMFXX    EQU   255                                                      24040001
W#SMFNO  DS    AL1(SMFXX)                                               24050001
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           24060000
*********************************************************************** 24070000
*        SMF type xx record                                           * 24080000
*********************************************************************** 24090000
W#XXBGN  DS    0D                                                       24100000
W#XXLEN  DS    BL2       Record length                                  24110000
W#XXSEG  DS    BL2       Segment descriptor                             24120000
W#XXFLG  DS    BL1       Header flag                                    24130000
W#XXRRF  EQU   X'80'     New record format                              24140000
W#XXSUT  EQU   X'40'     Subtypes used                                  24150000
W#XXV4   EQU   X'10'     MVS/ESA Version 4                              24160000
W#XXESA  EQU   X'08'     MVS/ESA Version                                24170000
W#XXVXA  EQU   X'04'     MVS/XA Version                                 24180000
W#XXOS   EQU   X'02'     Operating system is OS/VS2                     24190000
W#XXBFY  EQU   X'01'     System running in PR/SM mode                   24200000
W#XXRTY  DS    BL1       Record type                                    24210000
W#XXTME  DS    BL4       TOD record written                             24220000
W#XXDTE  DS    PL4       Date record written                            24230000
W#XXSID  DS    CL4       System id                                      24240000
W#XXSSI  DS    CL4       Subsystem id                                   24250000
W#XXSTY  DS    BL2       Subtype                                        24260000
W#XXMOF  DS    BL4       Offset to Maxrates section                     24270000
W#XXMLN  DS    BL2       Length to Maxrates section                     24280000
W#XXMON  DS    BL2       Number to Maxrates section (1)                 24290000
W#XXIOF  DS    BL4       Offset to instruction counter section          24300000
W#XXILN  DS    BL2       Length to instruction counter section          24310000
W#XXION  DS    BL2       Number to instruction counter section          24320000
W#XXHDR  EQU   W#XXBGN,*-W#XXBGN                                        24330000
W#XXMXS  DS    XL(L'MAXENT) Maxrates Section                            24340000
W#XXIC   DS    (NUMCP)D  Instruction Counters Sections                  24350001
*                                                                       24360000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           24370000
W#INSCTP DS    (NUMCP)D  Previous instruction counters                  24380001
W#INSCTC DS    (NUMCP)D  Current iInstruction counters                  24390001
*                                                                       24400000
W#END    EQU   *                                                        24410001
         DS    (((((*-W#)/4096)+1)*4096)-(*-W#))X                       24420000
W#LEN    EQU   *-W#                                                     24430000
*********************************************************************** 24440000
*            Equates                                                  * 24450000
*********************************************************************** 24460000
R0       EQU   0                                                        24470000
R1       EQU   1                                                        24480000
R2       EQU   2                                                        24490000
R3       EQU   3                                                        24500000
R4       EQU   4                                                        24510000
R5       EQU   5                                                        24520000
R6       EQU   6                                                        24530000
R7       EQU   7                                                        24540000
R8       EQU   8                                                        24550000
R9       EQU   9                                                        24560000
R10      EQU   10                                                       24570000
R11      EQU   11                                                       24580000
R12      EQU   12                                                       24590000
R13      EQU   13                                                       24600000
R14      EQU   14                                                       24610000
R15      EQU   15                                                       24620000
*********************************************************************** 24630000
*        DSECTs                                                       * 24640000
*********************************************************************** 24650000
*                                                                       24660000
         IHAECB                                                         24670000
         CVT   DSECT=YES,PREFIX=YES,LIST=YES                            24680000
CVT      EQU   CVTMAP                                                   24690000
         IHAPSA                                                         24700000
         IHAPCCAT DSECT=YES                                             24710000
         IHAPCCA  DSECT=YES                                             24720000
         IHAPVT                                                         24730000
CIB      DSECT                                                          24740000
         IEZCIB                                                         24750000
COMM     DSECT                                                          24760000
         IEZCOM                                                         24770000
         IHASDWA                                                        24780000
         IEFJESCT                                                       24790000
         IEESMCA                                                        24800000
         DCBD     DSORG=PS                                              24810000
         END                                                            24820000
