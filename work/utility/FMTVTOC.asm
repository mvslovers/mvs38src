         MACRO ,                                                        00010006
&LBL     $TRC  ,                                                        00020006
&LBL                       DS    0H                                     00030006
                           STM   R0,R15,W#DIAGRG  Save registers        00040006
                           BAL   R14,DIAGTRC      Trace                 00050006
                           LM    R0,R15,W#DIAGRG  Restore registers     00060006
         MEND  ,                                                        00070006
         MACRO                                                          00080000
         BLKCVT &DATA                                                   00090000
         GBLA  &HEX                                                     00100000
         LCLC  &CH                                                      00110000
         LCLA  &N                                                       00120000
&HEX     SETA  0                                                        00130000
         AIF   ('&DATA'(1,1) NE '-').LOOP                               00140000
&N       SETA  1                                                        00150000
.LOOP    AIF   (&N GE K'&DATA).DONE                                     00160000
&N       SETA  &N+1                                                     00170000
&CH      SETC  '&DATA'(&N,1)                                            00180000
         AIF   ('&CH' GE '0').ZEROTO9                                   00190000
         AIF   ('&CH' EQ 'A').AX                                        00200000
         AIF   ('&CH' EQ 'B').BX                                        00210000
         AIF   ('&CH' EQ 'C').CX                                        00220000
         AIF   ('&CH' EQ 'D').DX                                        00230000
         AIF   ('&CH' EQ 'E').EX                                        00240000
         AIF   ('&CH' EQ 'F').FX                                        00250000
         MNOTE 12,'&DATA field not hex number'                          00260000
&HEX     SETA  0                                                        00270000
         MEXIT                                                          00280000
.ZEROTO9 ANOP                                                           00290000
&HEX     SETA  &HEX*16+&CH                                              00300000
         AGO   .LOOP                                                    00310000
.AX      ANOP                                                           00320000
&HEX     SETA  &HEX*16+X'A'                                             00330000
         AGO   .LOOP                                                    00340000
.BX      ANOP                                                           00350000
&HEX     SETA  &HEX*16+X'B'                                             00360000
         AGO   .LOOP                                                    00370000
.CX      ANOP                                                           00380000
&HEX     SETA  &HEX*16+X'C'                                             00390000
         AGO   .LOOP                                                    00400000
.DX      ANOP                                                           00410000
&HEX     SETA  &HEX*16+X'D'                                             00420000
         AGO   .LOOP                                                    00430000
.EX      ANOP                                                           00440000
&HEX     SETA  &HEX*16+X'E'                                             00450000
         AGO   .LOOP                                                    00460000
.FX      ANOP                                                           00470000
&HEX     SETA  &HEX*16+X'F'                                             00480000
         AGO   .LOOP                                                    00490000
.DONE    AIF   ('&DATA'(1,1) NE '-').MEND                               00500000
&HEX     SETA  0-&HEX                                                   00510000
.MEND    MEND                                                           00520000
         MACRO                                                          00530000
         BLKEND                                                         00540000
         DC    AL1(BLKEND)         End of block descriptor              00550000
         MEND                                                           00560000
         MACRO                                                          00570000
&LBL     BLKENT &TYPE,&OFF,&LEN,&DIGIT=0,&NEWLIN=NO,&OFFSET=            00580000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             00590000
         LCLA  &IOFF,&ILEN,&MAX,&WRKOFF                                 00600000
         LCLC  &LENSAV,&LNSV                                            00610000
&MAX     SETA  120                                                      00620006
         AIF   ('&TYPE' EQ 'HEX').LBLHEX                                00630000
         AIF   ('&TYPE' EQ 'BIT').BIT                                   00640006
         AIF   (T'&LBL NE 'O').LBLER1                                   00650000
.LBLHEX  ANOP                                                           00660000
         AIF   ('&NEWLIN' EQ 'YES').DONEW                               00670000
         AIF   ('&TYPE' NE 'LABEL').NLB                                 00680000
         AIF   (T'&OFFSET EQ 'O').NOFF                                  00690000
&WRKOFF  SETA  &OFFSET+K'&OFF-10                                        00700000
         AIF   (&WRKOFF LT &MAX).OFFOK                                  00710000
         MNOTE 8,'OFFSET PUSHES LITERAL PAST LINE END'                  00720000
         MEXIT                                                          00730000
.OFFOK   ANOP                                                           00740000
&SETOFF  SETA  &OFFSET-11                                               00750000
         AGO   .NONEW                                                   00760000
.NOFF    ANOP                                                           00770000
&WRKOFF  SETA  &SETOFF+K'&OFF-1                                         00780000
         AGO   .CHK                                                     00790000
.NLB     ANOP                                                           00800000
         AIF   ('&LEN'(1,1) LT '0').NONEW                               00810000
         BLKCVT &LEN                                                    00820000
&WRKOFF  SETA  &SETOFF+&HEX+2                                           00830000
.CHK     ANOP                                                           00840000
         AIF   (&WRKOFF LT &MAX).NONEW                                  00850000
.DONEW   ANOP                                                           00860000
&SETOFF  SETA  0                                                        00870000
.NONEW   ANOP                                                           00880000
         AIF   ('&TYPE' NE 'LABEL').NOLABEL If not a label              00890000
         DC    AL1(BLKCONST)       Constant                             00900000
&ILEN    SETA  K'&OFF-3                                                 00910000
         DC    AL1(&SETOFF)        Offset to output                     00920000
         DC    AL1(&ILEN)          Length                               00930000
&ILEN    SETA  &ILEN+1                                                  00940000
         DC    CL&ILEN&OFF         Character constant                   00950000
&ILEN    SETA  &ILEN-1                                                  00960000
         AGO   .SETOFF                                                  00970000
.NOLABEL ANOP                                                           00980000
&LENSAV  SETC  ''                                                       00990000
         AIF   (T'&LBL EQ 'O').NXTCHK                                   01000000
         AIF   ('&LBL' LT '1').LBLER                                    01010000
         AIF   ('&LBL' GT '7').LBLER                                    01020000
.NXTCHK  ANOP                                                           01030000
         AIF   ('&OFF' EQ '.NEXT').NEXT                                 01040000
         BLKCVT &OFF               Convert offset from hex              01050000
&IOFF    SETA  &HEX-&SEGOFF                                             01060000
         AGO   .LBLCHK                                                  01070000
.NEXT    ANOP                                                           01080000
&LENSAV  SETC  'X''8000''+'                                             01090000
&IOFF    SETA  0                                                        01100000
.LBLCHK  ANOP                                                           01110000
         AIF   (T'&LBL EQ 'O').LENDONE                                  01120000
&LENSAV  SETC  'X''8000''+X''&LBL.000''+'                               01130000
.LENDONE ANOP                                                           01140000
         AIF   ('&OFF' EQ '.NEXT').OFFDONE                              01150000
         AIF   (&HEX LT &SEGOFF).OFFLOW If before block start           01160000
         AIF   (&HEX GT &SEGEND).OFFHI If after block end               01170000
.OFFDONE ANOP                                                           01180000
         AIF   ('&TYPE' NE 'HEX').NOHEX If not hex                      01190000
         AIF   ('&DIGIT' NE '0' AND '&DIGIT' NE '1').BADDIG             01200000
         DC    AL1(BLKHEX)         Hex field                            01210000
         DC    AL1(&SETOFF)        Offset to output                     01220000
         DC    AL2(&LENSAV&IOFF)   Field offset                         01230000
         DC    AL1(&DIGIT)         Digit offset                         01240000
         AGO   .DOLEN                                                   01250000
.NOHEX   AIF   ('&TYPE' NE 'CHAR').NOTYPE If not character              01260000
         DC    AL1(BLKCHAR)        Character field                      01270000
         DC    AL1(&SETOFF)        Offset to output                     01280000
         DC    AL2(&LENSAV&IOFF)   Field offset                         01290000
.DOLEN   ANOP                                                           01300000
         AIF   ('&LEN'(1,1) LT '0').CHRSCN                              01310000
         BLKCVT &LEN               Validate length                      01320000
&ILEN    SETA  &HEX-1              Get machine length                   01330000
         DC    AL2(&ILEN)          Length                               01340000
         AGO   .SETOFF                                                  01350000
.CHRSCN  ANOP  ,                                                        01360000
         AIF   ('&LEN'(1,1) EQ '(').GETLBL                              01370000
         DC    SL2(&LEN)           Length                               01380000
         AGO   .LENEND                                                  01390000
.GETLBL  ANOP                                                           01400000
         AIF   ('&LEN'(2,1) LT '1').LBLER                               01410000
         AIF   ('&LEN'(2,1) GT '7').LBLER                               01420000
         AIF   ('&LEN'(3,1) NE ')').LBLER                               01430000
&LNSV    SETC  'W#L'.'&LEN'(2,1)                                        01440000
         DC    SL2(&LNSV)                                               01450000
.LENEND  ANOP                                                           01460000
&ILEN    SETA  1                   Fake length                          01470000
.SETOFF  ANOP                                                           01480000
&SETOFF  SETA  &SETOFF+&ILEN+2                                          01490000
         AIF   (&SETOFF GT &MAX).NEEDNEW                                01500000
         MEXIT                                                          01510000
.*       BLKENT BIT,xx,offset,'desc',OFFSET=n,NEWLIN=YES                01520006
.BIT     ANOP                                                           01530006
         AIF   (T'&SYSLIST(2) EQ 'O').BITERR                            01540006
         AIF   (T'&SYSLIST(3) EQ 'O').BITOFER                           01550006
         AIF   (K'&SYSLIST(3) NE 2).BITERR                              01560006
         AIF   (T'&SYSLIST(4) EQ 'O').DESCERR                           01570006
         AIF   (T'&OFFSET EQ 'O').OFFERR                                01580006
         AIF   ('&NEWLIN' NE 'YES').NLERR                               01590006
&SETOFF  SETA  0                                                        01600006
&WRKOFF  SETA  &OFFSET+K'&SYSLIST(4)-2                                  01610006
         AIF   (&WRKOFF LT &MAX).BITDOF                                 01620006
         MNOTE 8,'OFFSET PUSHES DESCRIPTION PAST LINE END'              01630006
         MEXIT                                                          01640006
.BITDOF  ANOP  ,                                                        01650006
         DC    AL1(BLKBIT)         Bit field                            01660006
         DC    AL1(&OFFSET-11)     Description offset                   01670006
         BLKCVT &SYSLIST(2)                                             01680006
         DC    AL1(&HEX)           Hex value of bit                     01690006
&WRKOFF  SETA  &OFFSET+&SYSLIST(3)                                      01700006
         AIF   (&WRKOFF LT &MAX).BITOF                                  01710006
         MNOTE 8,'BIT OFFSET PAST LINE END'                             01720006
         MEXIT                                                          01730006
.BITOF   ANOP  ,                                                        01740006
         DC    AL1(&SYSLIST(3))    Offset for bit value                 01750006
&ILEN    SETA  K'&SYSLIST(4)-3                                          01760006
         DC    AL1(&ILEN)          Bit description length               01770006
&ILEN    SETA  &ILEN+1                                                  01780006
         DC    CL&ILEN&SYSLIST(4)  Description                          01790006
         MEXIT                                                          01800006
.NOTYPE  MNOTE 8,'Type missing of invalid'                              01810000
         MEXIT                                                          01820000
.BADDIG  MNOTE 8,'Digit not 0 or 1'                                     01830000
         MEXIT                                                          01840000
.OFFLOW  MNOTE 8,'Offset to low'                                        01850000
         MEXIT                                                          01860000
.OFFHI   MNOTE 8,'Offset to high'                                       01870000
         MEXIT                                                          01880000
.LBLER   MNOTE 8,'Label must be 0, 1, 2 or 3'                           01890000
         MEXIT                                                          01900000
.LBLER1  MNOTE 8,'Label only valid with TYPE HEX'                       01910000
         MEXIT                                                          01920000
.NEEDNEW MNOTE 4,'Need NEWLIN=YES, max output area exceeded'            01930000
         MEXIT                                                          01940006
.BITERR  MNOTE 8,'BIT requires second operand (bit value)'              01950006
         MEXIT                                                          01960006
.BITOFER MNOTE 8,'BIT requires third operand (offset to place bit)'     01970006
         MEXIT                                                          01980006
.DESCERR MNOTE 8,'BIT requires fourth operand (bit description)'        01990006
         MEXIT                                                          02000006
.OFFERR  MNOTE 8,'BIT requires OFFSET='                                 02010006
         MEXIT                                                          02020006
.NLERR   MNOTE 8,'BIT requires NEWLIN=YES'                              02030006
         MEND                                                           02040000
         MACRO                                                          02050000
&N       BLKBGN &OFF=,&LEN=                                             02060000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             02070000
         LCLC  &SEGSTR,&WRKOFF                                          02080000
&SETOFF  SETA  0                                                        02090000
&N       DC    0D'0'                                                    02100000
         BLKCVT &OFF                                                    02110000
&SEGOFF  SETA  &HEX                                                     02120000
&SEGSTR  SETC  '&HEX'                                                   02130000
         AIF   (&HEX GE 0).NOSIGN                                       02140000
&SEGSTR  SETC  '-'.'&HEX'                                               02150000
.NOSIGN  ANOP                                                           02160000
         BLKCVT &LEN                                                    02170000
&SEGEND  SETA  &HEX+&SEGSTR                                             02180000
         DC    AL2(&SEGSTR)        Start offset                         02190000
         DC    AL2(&HEX)           Block length                         02200000
.MEND    MEND                                                           02210000
*********************************************************************** 02220000
*                                                                     * 02230000
* Mocule Name                                                         * 02240000
*    FMTVTOCT - Format VTOC DSCBs                                     * 02250000
*                                                                     * 02260000
* Attributes                                                          * 02270000
*    RENT                                                             * 02280000
*                                                                     * 02290000
* Author                                                              * 02300000
*    Dave Kreiss                                                      * 02310000
*                                                                     * 02320000
* Function                                                            * 02330000
*    Format various VTOC DSCBs similiar to IEHLIST but in vertical    * 02340000
*    format.                                                          * 02350000
*                                                                     * 02360000
*********************************************************************** 02370000
*                                                                     * 02380000
* Sample JCL                                                          * 02390000
*    //LIST    EXEC PGM=FMTVTOC,PARM='volser,SELECT(F4,F5),DEBUG'     * 02400000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 02410000
*    //SYSPRINT DD  SUSOUT=*                                          * 02420000
*                                                                     * 02430000
* DD STATEMENTS                                                       * 02440000
*    STEPLIB       Load library containing FMTVTOC.                   * 02450000
*    SYSPRINT      Print output.                                      * 02460000
*                                                                     * 02470000
* RETURN CODES                                                        * 02480000
*    0             VTOV formatted                                     * 02490000
*    4             Operational errors (PARM invalid etc.)             * 02500000
*    8             Fatal errors                                       * 02510000
*                                                                     * 02520000
*********************************************************************** 02530000
*                                                                     * 02540000
* Parameters                                                          * 02550000
*    All parameters are seperated by commas.                          * 02560000
*    volser         First parameter and required.  A 1 - 6 character  * 02570000
*                   volume serial number.  Must be a supported DASD   * 02580000
*                   device.                                           * 02590000
*    SELECT=(x,..)  One of more of the DSCB identifiers to format.    * 02600000
*                   Valid values are F1, F2, F3, F4, F5 and F6.       * 02610000
*                   Optional parameter.                               * 02620000
*    DEBUG          Optional parameter which causes dump of selected  * 02630000
*                   DSCBs.                                            * 02640000
*                                                                     * 02650000
*********************************************************************** 02660000
*                                                                     * 02670000
* Change Log:                                                         * 02680000
*   Date     Int VV.VV Description                                    * 02690000
* 01/20/2020 DSK 01.01 Created                                          02700000
* 03/25/2020 DSK 01.02 Move description to accodomate dsname            02710005
* 05/16/2020 DSK 01.03 Add BIT field description to BLKENT              02720006
* 05/26/2020 DSK 01.04 Fix dynamic allocation errors use actual unit    02730007
* 08/24/2020 DSK 01.05 Correct Format 3 DSCB extents format             02740008
         LCLC   &VER                                                    02750000
&VER     SETC   '01.05'                                                 02760008
*********************************************************************** 02770000
*                                                                     * 02780000
*********************************************************************** 02790000
FMTVTOC  CSECT                                                          02800000
         USING FMTVTOC,R15                                              02810000
         B     BEGIN                   Bypass PGMID                     02820000
         DROP  R15                                                      02830000
         DC    AL1(PGMIDLN)            Length of PGMID                  02840000
PGMID    DC    C'FMTVTOC - &VER &SYSDATE &SYSTIME'                      02850000
PGMIDLN  EQU   *-PGMID                                                  02860000
BEGIN    DC    0H'0'                                                    02870000
*********************************************************************** 02880000
*        Initialization                                               * 02890000
*********************************************************************** 02900000
         STM   R14,R12,12(R13)         Save registers                   02910000
         LR    R11,R15                 Base                             02920000
         LA    R12,2048(,R11)           registers                       02930000
         LA    R12,2048(,R12)                                           02940000
         USING FMTVTOC,R11,R12                                          02950000
         L     R9,0(,R1)               Get parameter address            02960000
         GETMAIN R,LV=W#LEN                                             02970000
         LR    R14,R13                 Save callers save address        02980000
         LR    R13,R1                  Address my save address          02990000
         USING W#,R13                                                   03000000
         LR    R4,R1                   Clear                            03010000
         L     R5,=A(W#LEN)             work                            03020000
         SLR   R0,R0                     area                           03030000
         SLR   R1,R1                                                    03040000
         MVCL  R4,R0                                                    03050000
         ST    R13,8(,R14)             Chain my save                    03060000
         ST    R14,4(,R13)             Chain callers save               03070000
         BAL   R14,INIT                Setup (init, OPEN parse PARM)    03080000
         LTR   R15,R15                 Successful?                      03090000
         BNZ   DONE                    No, done                         03100000
         MVC   W#LINE+1(8),W#DEVNAM                                     03110007
         BAL   R14,PRT                                                  03120007
*********************************************************************** 03130000
*        Read DSCBs from VTOC                                         * 03140000
*********************************************************************** 03150000
*        OPEN VTOC                                                      03160000
         MVI   VTOCFUNC,1              OPEN VTOC                        03170000
         LA    R1,VTOCPARM             ADDRESS PARAMETERS               03180000
         L     R15,=A(UTS07)           ADDRESS OF ACCESS ROUTINE        03190000
         BALR  R14,R15                 CALL VTOC ACCESS ROUTINE TO OPEN 03200000
         CH    R15,=AL2(8)                                              03210000
         BE    UNSUPDEV                EIGHT.DEVICE ERROR               03220000
         CH    R15,=AL2(4)                                              03230000
         BE    NOUNIT                  FOUR.NO DD                       03240000
         LTR   R15,R15                 Any other error                  03250007
         BNZ   OPNERR                  Yes, exit                        03260007
*        Read format 4 DSCB (first DSCB)                                03270000
         MVI   VTOCFUNC,0              READ VTOC                        03280000
         LA    R1,VTOCPARM             ADDRESS PARAMETERS               03290000
         L     R15,=A(UTS07)           ADDRESS OF ACCESS ROUTINE        03300000
         BALR  R14,R15                 GET FORMAT 4 DSCB (FIRST DSCB)   03310000
         CH    R15,=AL2(8)                                              03320000
         BE    IOERR                   EIGHT.I/O ERROR                  03330000
         CH    R15,=AL2(4)                                              03340000
         BE    VTOCEOF                 FOUR.EOF                         03350000
         USING DSCB,R10                ADDRESSABILITY TO DSCB           03360000
         L     R10,ADOFDSCB            GET DSCB ADDRESS                 03370000
         LA    R10,8(,R10)             ADDRESS OF KEY                   03380000
         CLI   DS4IDFMT,C'4'           FORMAT 4 (VTOC DSCB) ?           03390000
         BNE   IOERR                    NO, ERROR                       03400000
         AP    W#F4CNT,=P'+1'                                           03410000
*        Set up heading info about volume                               03420006
         MVC   W#HD1VOL,VOLUMEID       Volume serial number             03430007
         LA    R2,W#HD1VOL+L'W#HD1VOL  Point after volume serial        03440006
INITTTLV DS    0H                                                       03450006
         BCTR  R2,0                    Back one character               03460006
         CLI   0(R2),C' '              Scan back through volume serial  03470006
         BE    INITTTLV                Loop til end found               03480006
         MVI   2(R2),C'('                                               03490006
         MVC   3(7,R2),W#DEVNAM        Device name                      03500007
         LA    R2,2(,R2)               Set up scan for end              03510006
INITTTL3 DS    0H                                                       03520006
         LA    R2,1(,R2)               Get next position                03530006
         CLI   0(R2),C' '              End of device name               03540006
         BNE   INITTTL3                No, continue                     03550006
         CLI   W#DEVTYP,X'0A'          3340                             03560006
         BE    INIT3340                Yes                              03570006
         CLI   W#DEVTYP,X'0E'          3380                             03580006
         BE    INIT3380                Yes                              03590006
         CLI   W#DEVTYP,X'0F'          3390                             03600006
         BE    INIT3390                Yes                              03610006
         BCTR  R2,0                    Back one                         03620006
         B     INITTTL9                                                 03630006
INIT3340 DS    0H                                                       03640006
         LA    R0,MDL3340#             Number of 3340 models            03650006
         LA    R15,MDL3340             3340 model table                 03660006
         B     INITTTL4                Scan model table                 03670006
INIT3380 DS    0H                                                       03680006
         LA    R0,MDL3380#             Number of 3380 models            03690006
         LA    R15,MDL3380             3380 model table                 03700006
         B     INITTTL4                Scan model table                 03710006
INIT3390 DS    0H                                                       03720006
         LA    R0,MDL3390#             Number of 3390 models            03730006
         LA    R15,MDL3390             3390 model table                 03740006
INITTTL4 DS    0H                                                       03750006
         CLC   DS4DEVSZ(2),0(R15)      Model based on ALT CYL           03760006
         BE    INITTTL5                Found match                      03770006
         LA    R15,MDL3390L(,R15)      Next entry                       03780006
         BCT   R0,INITTTL4             Loop table of known sizes        03790006
INITTTL5 DS    0H                                                       03800006
         MVC   0(4,R2),2(R15)          Get model if any                 03810006
         BCTR  R2,0                    Back one                         03820006
INITTTL9 DS    0H                                                       03830006
         LA    R2,1(,R2)               Next character                   03840006
         CLI   0(R2),C' '              Found blank                      03850006
         BNE   INITTTL9                No, look again                   03860006
         MVI   0(R2),C')'              End device name/model            03870006
         LA    R2,2(,R2)               Past end                         03880006
         MVC   0(L'W#UNIT,R2),W#UNIT   Add unit address                 03890006
         LA    R2,5(,R2)               Ready for more in title          03900006
*                                                                       03910006
         TM    W#FLG,W#FLGSEL                                           03920000
         BNO   VTCF4SEL                                                 03930000
         TM    W#FLG,W#FLGF4                                            03940000
         BNO   VTCREAD                                                  03950000
VTCF4SEL DS    0H                                                       03960000
         BAL   R14,DSCBDMP                                              03970000
         BAL   R14,DSCBAD                                               03980000
         MVC   W#LINE+1(13),=C'Format 4 DSCB'                           03990000
         BAL   R14,PRT                                                  04000000
         LA    R2,DSCB                                                  04010000
         L     R3,=A(F4)               Format definition                04020000
         LA    R5,DSCBLEN                                               04030000
         BAL   R14,FMT                                                  04040000
         BAL   R14,PRT                                                  04050000
*        Read rest of VTOC                                              04060000
VTCREAD  DS    0H                                                       04070000
         LA    R1,VTOCPARM             VTOC read parameters             04080000
         L     R15,=A(UTS07)           VTOC read routine                04090000
         BALR  R14,R15                 Read VTOC                        04100000
         CH    R15,=AL2(8)             Get an I/O error                 04110000
         BE    IOERR                   Yes, error                       04120000
         CH    R15,=AL2(4)             End of file                      04130000
         BE    VTOCEOF                 Yes, done reading VTOC           04140000
*        Process DSCBs                                                  04150000
         L     R10,ADOFDSCB            DSCB just read                   04160000
         LA    R10,8(,R10)             Skip CCHHR, key and data len     04170000
         CLI   DS4IDFMT,C'1'           Format 1 DSCB                    04180000
         BE    VTCF1                   Yes, process it                  04190000
         CLI   DS4IDFMT,C'2'           Format 2 DSCB                    04200000
         BE    VTCF2                   Yes, process it                  04210000
         CLI   DS4IDFMT,C'3'           Format 3 DSCB                    04220000
         BE    VTCF3                   Yes, process it                  04230000
         CLI   DS4IDFMT,C'5'           Format 5 DSCB                    04240000
         BE    VTCF5                   Yes, process it                  04250000
         CLI   DS4IDFMT,C'6'           Format 6 DSCB                    04260000
         BE    VTCF6                   Yes, process it                  04270000
         CLI   DS4IDFMT,C'7'           Format 7 DSCB                    04280006
         BE    VTCF7                   Yes, process it                  04290006
         CLI   DS4IDFMT,C'8'           Format 8 DSCB                    04300006
         BE    VTCF8                   Yes, process it                  04310006
         CLI   DS4IDFMT,C'9'           Format 9 DSCB                    04320006
         BE    VTCF9                   Yes, process it                  04330006
         CLI   DS4IDFMT,0              Empty DSCB                       04340000
         BE    VTCFRE                  Yes, process it                  04350000
         AP    W#FXCNT,=P'+1'                                           04360000
         MVC   W#LINE+1(4),=C'Unknown DSCB'                             04370000
         BAL   R14,PRT                                                  04380000
         LA    R1,DSCB                                                  04390000
         LA    R0,DSCBLEN                                               04400000
         BAL   R14,DMP                                                  04410000
         BAL   R14,PRT                                                  04420000
         B     VTCREAD                                                  04430000
*        Unknown  DSCB                                                  04440000
VTCFRE   DS    0H                                                       04450000
         AP    W#F0CNT,=P'+1'                                           04460000
         B     VTCREAD                                                  04470000
*        Format 1                                                       04480000
VTCF1    DS    0H                                                       04490000
         AP    W#F1CNT,=P'+1'                                           04500000
         TM    W#FLG,W#FLGSEL                                           04510000
         BNO   VTCF1SEL                                                 04520000
         TM    W#FLG,W#FLGF1                                            04530000
         BNO   VTCREAD                                                  04540000
VTCF1SEL DS    0H                                                       04550000
         BAL   R14,DSCBDMP                                              04560000
         BAL   R14,DSCBAD                                               04570000
         MVC   W#LINE+1(13),=C'Format 1 DSCB'                           04580000
         BAL   R14,PRT                                                  04590000
         LA    R2,DSCB                                                  04600000
         L     R3,=A(F1)               Format definition                04610000
         LA    R5,DSCBLEN                                               04620000
         BAL   R14,FMT                                                  04630000
         BAL   R14,PRT                                                  04640000
         B     VTCREAD                                                  04650000
*        Format 2                                                       04660000
VTCF2    DS    0H                                                       04670000
         AP    W#F2CNT,=P'+1'                                           04680000
         TM    W#FLG,W#FLGSEL                                           04690000
         BNO   VTCF2SEL                                                 04700000
         TM    W#FLG,W#FLGF2                                            04710000
         BNO   VTCREAD                                                  04720000
VTCF2SEL DS    0H                                                       04730000
         BAL   R14,DSCBDMP                                              04740000
         BAL   R14,DSCBAD                                               04750000
         MVC   W#LINE+1(13),=C'Format 2 DSCB'                           04760000
         BAL   R14,PRT                                                  04770000
         LA    R2,DSCB                                                  04780000
         L     R3,=A(F2)               Format definition                04790000
         LA    R5,DSCBLEN                                               04800000
         BAL   R14,FMT                                                  04810000
         BAL   R14,PRT                                                  04820000
         B     VTCREAD                                                  04830000
*        Format 3                                                       04840000
VTCF3    DS    0H                                                       04850000
         AP    W#F3CNT,=P'+1'                                           04860000
         TM    W#FLG,W#FLGSEL                                           04870000
         BNO   VTCF3SEL                                                 04880000
         TM    W#FLG,W#FLGF3                                            04890000
         BNO   VTCREAD                                                  04900000
VTCF3SEL DS    0H                                                       04910000
         BAL   R14,DSCBDMP                                              04920000
         BAL   R14,DSCBAD                                               04930000
         MVC   W#LINE+1(13),=C'Format 3 DSCB'                           04940000
         BAL   R14,PRT                                                  04950000
         LA    R2,DSCB                                                  04960000
         L     R3,=A(F3)               Format definition                04970000
         LA    R5,DSCBLEN                                               04980000
         BAL   R14,FMT                                                  04990000
         BAL   R14,PRT                                                  05000000
         B     VTCREAD                                                  05010000
*        Format 5                                                       05020000
VTCF5    DS    0H                                                       05030000
         AP    W#F5CNT,=P'+1'                                           05040000
         TM    W#FLG,W#FLGSEL                                           05050000
         BNO   VTCF5SEL                                                 05060004
         TM    W#FLG,W#FLGF5                                            05070000
         BNO   VTCREAD                                                  05080000
VTCF5SEL DS    0H                                                       05090000
         BAL   R14,DSCBDMP                                              05100000
         BAL   R14,DSCBAD                                               05110000
         MVC   W#LINE+1(13),=C'Format 5 DSCB'                           05120000
         BAL   R14,PRT                                                  05130000
         LA    R2,DSCB                                                  05140000
         L     R3,=A(F5)               Format definition                05150000
         LA    R5,DSCBLEN                                               05160000
         BAL   R14,FMT                                                  05170000
         BAL   R14,PRT                                                  05180000
         B     VTCREAD                                                  05190000
*        Format 6                                                       05200000
VTCF6    DS    0H                                                       05210000
         AP    W#F6CNT,=P'+1'                                           05220000
         TM    W#FLG,W#FLGSEL                                           05230000
         BNO   VTCF6SEL                                                 05240000
         TM    W#FLG,W#FLGF6                                            05250000
         BNO   VTCREAD                                                  05260000
VTCF6SEL DS    0H                                                       05270000
         BAL   R14,DSCBDMP                                              05280000
         BAL   R14,DSCBAD                                               05290000
         MVC   W#LINE+1(13),=C'Format 6 DSCB'                           05300000
         BAL   R14,PRT                                                  05310000
         LA    R2,DSCB                                                  05320000
         L     R3,=A(F6)               Format definition                05330000
         LA    R5,DSCBLEN                                               05340000
         BAL   R14,FMT                                                  05350000
         BAL   R14,PRT                                                  05360000
         B     VTCREAD                                                  05370000
*        Format 7                                                       05380006
VTCF7    DS    0H                                                       05390006
         AP    W#F7CNT,=P'+1'                                           05400006
         MVC   W#LINE+1(13),=C'Format 7 DSCB'                           05410006
         BAL   R14,PRT                                                  05420006
         LA    R1,DSCB                                                  05430006
         LA    R0,DSCBLEN                                               05440006
         BAL   R14,DMP                                                  05450006
         BAL   R14,PRT                                                  05460006
         B     VTCREAD                                                  05470006
*        Format 8                                                       05480006
VTCF8    DS    0H                                                       05490006
         AP    W#F8CNT,=P'+1'                                           05500006
         MVC   W#LINE+1(13),=C'Format 8 DSCB'                           05510006
         BAL   R14,PRT                                                  05520006
         LA    R1,DSCB                                                  05530006
         LA    R0,DSCBLEN                                               05540006
         BAL   R14,DMP                                                  05550006
         BAL   R14,PRT                                                  05560006
         B     VTCREAD                                                  05570006
*        Format 9                                                       05580006
VTCF9    DS    0H                                                       05590006
         AP    W#F9CNT,=P'+1'                                           05600006
         MVC   W#LINE+1(13),=C'Format 9 DSCB'                           05610006
         BAL   R14,PRT                                                  05620006
         LA    R1,DSCB                                                  05630006
         LA    R0,DSCBLEN                                               05640006
         BAL   R14,DMP                                                  05650006
         BAL   R14,PRT                                                  05660006
         B     VTCREAD                                                  05670006
*********************************************************************** 05680000
*        Termination                                                  * 05690000
*********************************************************************** 05700000
VTOCEOF  DS    0H                                                       05710000
         MVI   VTOCFUNC,2              CLOSE VTOC                       05720000
         LA    R1,VTOCPARM             ADDRESS VTOC PARAMETERS          05730000
         L     R15,=A(UTS07)           ADDRESS OF VTOC ACCESS           05740000
         BALR  R14,R15                 CLOSE VTOC                       05750000
         XC    VTCWRK,VTCWRK                                            05760000
         MVC   W#LINE+1(16),=C'VTOC End of file'                        05770000
         BAL   R14,PRT                                                  05780000
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    05790000
         ED    W#LINE+1(10),W#F0CNT                                     05800000
         MVC   W#LINE+12(22),=C'Format 0 DSCBs (empty)'                 05810006
         BAL   R14,PRT                                                  05820000
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    05830000
         ED    W#LINE+1(10),W#F1CNT                                     05840000
         MVC   W#LINE+12(25),=C'Format 1 DSCBs (data set)'              05850006
         BAL   R14,PRT                                                  05860000
         CP    W#F2CNT,=P'+0'                                           05870006
         BE    VTOCEOF3                                                 05880006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    05890000
         ED    W#LINE+1(10),W#F2CNT                                     05900000
         MVC   W#LINE+12(21),=C'Format 2 DSCBs (ISAM)'                  05910006
         BAL   R14,PRT                                                  05920000
VTOCEOF3 DS    0H                                                       05930006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    05940000
         ED    W#LINE+1(10),W#F3CNT                                     05950000
         MVC   W#LINE+12(24),=C'Format 3 DSCBs (extents)'               05960006
         BAL   R14,PRT                                                  05970000
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    05980000
         ED    W#LINE+1(10),W#F4CNT                                     05990000
         MVC   W#LINE+12(21),=C'Format 4 DSCBs (VTOC)'                  06000006
         BAL   R14,PRT                                                  06010000
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06020000
         ED    W#LINE+1(10),W#F5CNT                                     06030000
         MVC   W#LINE+12(27),=C'Format 5 DSCBs (free space)'            06040006
         BAL   R14,PRT                                                  06050000
         CP    W#F6CNT,=P'+0'                                           06060006
         BE    VTOCEOF7                                                 06070006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06080000
         ED    W#LINE+1(10),W#F6CNT                                     06090000
         MVC   W#LINE+12(25),=C'Format 6 DSCBs (obsolete)'              06100006
         BAL   R14,PRT                                                  06110000
VTOCEOF7 DS    0H                                                       06120006
         CP    W#F7CNT,=P'+0'                                           06130006
         BE    VTOCEOF8                                                 06140006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06150006
         ED    W#LINE+1(10),W#F7CNT                                     06160006
         MVC   W#LINE+12(26),=C'Format 7 DSCBs (free space)'            06170006
         BAL   R14,PRT                                                  06180006
VTOCEOF8 DS    0H                                                       06190006
         CP    W#F8CNT,=P'+0'                                           06200006
         BE    VTOCEOF9                                                 06210006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06220006
         ED    W#LINE+1(10),W#F8CNT                                     06230006
         MVC   W#LINE+12(24),=C'Format 8 DSCBs (data set)'              06240006
         BAL   R14,PRT                                                  06250006
VTOCEOF9 DS    0H                                                       06260006
         CP    W#F9CNT,=P'+0'                                           06270006
         BE    VTOCEOFX                                                 06280006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06290006
         ED    W#LINE+1(10),W#F9CNT                                     06300006
         MVC   W#LINE+12(24),=C'Format 9 DSCBs (metadata)'              06310006
         BAL   R14,PRT                                                  06320006
VTOCEOFX DS    0H                                                       06330006
         CP    W#FXCNT,=P'+0'                                           06340006
         BE    VTOCEOFT                                                 06350006
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06360000
         ED    W#LINE+1(10),W#FXCNT                                     06370000
         MVC   W#LINE+12(13),=C'Unknown DSCBs'                          06380000
         BAL   R14,PRT                                                  06390000
VTOCEOFT DS    0H                                                       06400006
         ZAP   W#DWORD,W#F0CNT                                          06410000
         AP    W#DWORD,W#F1CNT                                          06420000
         AP    W#DWORD,W#F2CNT                                          06430000
         AP    W#DWORD,W#F3CNT                                          06440000
         AP    W#DWORD,W#F4CNT                                          06450000
         AP    W#DWORD,W#F5CNT                                          06460000
         AP    W#DWORD,W#F6CNT                                          06470000
         AP    W#DWORD,W#F7CNT                                          06480006
         AP    W#DWORD,W#F8CNT                                          06490006
         AP    W#DWORD,W#F9CNT                                          06500006
         AP    W#DWORD,W#FXCNT                                          06510000
         MVC   W#LINE+1(10),=X'40206B2020206B202120'                    06520000
         ED    W#LINE+1(10),W#DWORD+4                                   06530000
         MVC   W#LINE+12(11),=C'Total DSCBs'                            06540000
         BAL   R14,PRT                                                  06550000
         SLR   R15,R15                                                  06560000
DONE     DS    0H                                                       06570000
         LR    R2,R15                                                   06580000
         MVC   W#LINE+1(11),=C'Return code'                             06590000
         MVC   W#LINE+12(7),=X'4020206B202120'                          06600000
         CVD   R2,W#DWORD                                               06610000
         ED    W#LINE+12(7),W#DWORD+5                                   06620000
         BAL   R14,PRT                                                  06630000
         TM    W#OTDCB+48,16                                            06640000
         BNO   DONE010                                                  06650000
         CLOSE (W#OTDCB),MF=(E,W#OPNLST)                                06660000
DONE010  DS    0H                                                       06670000
         LR    R1,R13                  ADDRESS FOR FREEMAIN             06680000
         L     R13,4(,R13)             GET PRIOR SAVE AREA ADDRESS      06690000
         FREEMAIN R,A=(1),LV=W#LEN                                      06700000
         LR    R15,R2                  PASS RC                          06710000
         RETURN (14,12),RC=(15)        EXIT                             06720000
*********************************************************************** 06730000
*        Format DSCB disk address                                     * 06740000
*********************************************************************** 06750000
DSCBAD   DS    0H                                                       06760000
         LA    R1,DSCB                                                  06770000
         SH    R1,=H'+8'                                                06780000
         MVC   W#LINE+15(6),=C'CCHHR='                                  06790006
         UNPK  W#LINE+21(5),0(3,R1)                                     06800006
         TR    W#LINE+21(5),HEXTBL-240                                  06810006
         MVI   W#LINE+25,C' '                                           06820006
         UNPK  W#LINE+26(5),2(3,R1)                                     06830006
         TR    W#LINE+26(4),HEXTBL-240                                  06840006
         MVI   W#LINE+30,C' '                                           06850006
         UNPK  W#LINE+31(3),4(2,R1)                                     06860006
         TR    W#LINE+31(2),HEXTBL-240                                  06870006
         MVI   W#LINE+33,C' '                                           06880006
         BR    R14                                                      06890000
*********************************************************************** 06900000
*        Diagnostic dump of DSCB if requested                         * 06910000
*********************************************************************** 06920000
DSCBDMP  DS    0H                                                       06930000
         MVI   W#LINE,C'1'                                              06940000
         TM    W#FLG,W#FLGDBG                                           06950000
         BNOR  R14                                                      06960000
         ST    R14,W#DSDM14                                             06970000
         MVC   W#LINE+1(4),=C'DSCB'                                     06980000
         LA    R1,DSCB                                                  06990000
         SH    R1,=H'+8'                                                07000000
         UNPK  W#LINE+6(11),0(6,R1)                                     07010000
         TR    W#LINE+6(11),HEXTBL-240                                  07020000
         MVI   W#LINE+16,C' '                                           07030000
         UNPK  W#LINE+17(3),5(2,R1)                                     07040000
         TR    W#LINE+17(2),HEXTBL-240                                  07050000
         MVI   W#LINE+19,C' '                                           07060000
         UNPK  W#LINE+20(5),6(3,R1)                                     07070000
         TR    W#LINE+20(4),HEXTBL-240                                  07080000
         MVI   W#LINE+24,C' '                                           07090000
         BAL   R14,PRT                                                  07100000
         LA    R1,DSCB                                                  07110000
         LA    R0,DSCBLEN                                               07120000
         BAL   R14,DMP                                                  07130000
         BAL   R14,PRT                                                  07140000
         L     R14,W#DSDM14                                             07150000
         BR    R14                                                      07160000
         DROP  R10                                                      07170006
*********************************************************************** 07180000
*        Initialize                                                   * 07190000
*********************************************************************** 07200000
INIT     DS    0H                                                       07210000
         ST    R14,W#INIT14                                             07220000
         ZAP   W#F0CNT,=P'+0'                                           07230000
         ZAP   W#F1CNT,=P'+0'                                           07240000
         ZAP   W#F2CNT,=P'+0'                                           07250000
         ZAP   W#F3CNT,=P'+0'                                           07260000
         ZAP   W#F4CNT,=P'+0'                                           07270000
         ZAP   W#F5CNT,=P'+0'                                           07280000
         ZAP   W#F6CNT,=P'+0'                                           07290000
         ZAP   W#F7CNT,=P'+0'                                           07300006
         ZAP   W#F8CNT,=P'+0'                                           07310006
         ZAP   W#F9CNT,=P'+0'                                           07320006
         ZAP   W#FXCNT,=P'+0'                                           07330000
         MVC   W#OPNLST,P#OPNLST       Prime OPEN list                  07340000
         MVC   W#OTDCB,P#OTDCB         Prime DCB                        07350000
         MVI   W#LINE,C' '             Clear print line                 07360000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              07370000
         MVC   W#HD1,W#LINE            Clear heading 1                  07380000
         MVI   W#HD1,C'1'              Prime heading 1                  07390000
         MVC   W#HD1TTL,=C'VTOC Format'                                 07400000
         MVC   W#HD1PG,=C'Page'                                         07410000
         ZAP   W#LNCT,=P'+99'                                           07420000
         ZAP   W#PGCT,=P'+0'                                            07430000
         OPEN  (W#OTDCB,(OUTPUT)),MF=(E,W#OPNLST)                       07440000
         TM    W#OTDCB+48,16           OPEN successful?                 07450000
         BZ    INITER                  No, error                        07460000
         ZAP   W#JLWK13,=P'+1'         Prime work                       07470000
         ZAP   W#JLWK12,=P'+31'        Prime Dec                        07480000
         ZAP   W#JLWK11,=P'+30'        Prime Nov                        07490000
         ZAP   W#JLWK10,=P'+31'        Prime Oct                        07500000
         ZAP   W#JLWK09,=P'+30'        Prime Sep                        07510000
         ZAP   W#JLWK08,=P'+31'        Prime Aug                        07520000
         ZAP   W#JLWK07,=P'+31'        Prime Jul                        07530000
         ZAP   W#JLWK06,=P'+30'        Prime Jun                        07540000
         ZAP   W#JLWK05,=P'+31'        Prime May                        07550000
         ZAP   W#JLWK04,=P'+30'        Prime Apr                        07560000
         ZAP   W#JLWK03,=P'+31'        Prime Mar                        07570000
         ZAP   W#JLWK02,=P'+28'        Prime Feb                        07580000
         ZAP   W#JLWK01,=P'+31'        Prime Jan                        07590000
         TIME  BIN                     Get current date and time        07600000
         ST    R1,W#CURDTE             Save date                        07610000
         SRDL  R0,32                   Get double word time             07620000
         D     R0,=F'+6000'            Get minutes                      07630000
         LR    R15,R0                  Save secs tens and hundreths     07640000
         SLR   R0,R0                   Clear                            07650000
         D     R0,=F'+60'              Get hours / mins                 07660000
         MH    R0,=H'+10000'           Get minutes                      07670000
         AR    R15,R0                  Add to get MM:SS.TH              07680000
         M     R0,=F'+1000000'         Get hours                        07690000
         AR    R1,R15                  Get HH:MM:SS.TH                  07700000
         CVD   R1,W#DWORD              Get time to decimal              07710000
         MVC   W#TIMWRK,=X'402021204B20204B20204B2020'                  07720000
         ED    W#TIMWRK,W#DWORD+3      Edit time                        07730000
         MVC   W#HD1TOD(8),W#TIMWRK+2  Move time                        07740000
         ZAP   W#JLWK1,W#CURDTE+2(2)   Get julian date                  07750000
         ZAP   W#JLWK2,=P'+365'        Days/yr = 365                    07760000
         ZAP   W#JLWK02,=P'+28'        Feb = 28                         07770000
         MVO   W#DWORD,W#CURDTE+1(1)   Sign year                        07780000
         DP    W#DWORD,=P'+4'          Divide by 4                      07790000
         CP    W#DWORD+7(1),=P'+0'     Is it a leap year ?              07800000
         BNZ   JULCVT2                 No                               07810000
         ZAP   W#JLWK2,=P'+366'        Days/yr = 366                    07820000
         ZAP   W#JLWK02,=P'+29'        Feb = 29                         07830000
JULCVT2  DS    0H                                                       07840000
         LA    R1,W#JLWK01             Point to Jan                     07850000
         SLR   R2,R2                   Set counter                      07860000
JULCVT4  DS    0H                                                       07870000
         SP    W#JLWK1,0(2,R1)         Months displacement              07880000
         BNP   JULCVT6                 If equal or less                 07890000
         SH    R1,=H'2'                Point to next month              07900000
         LA    R2,3(,R2)               Up index                         07910000
         B     JULCVT4                 Loop                             07920000
JULCVT6  DS    0H                                                       07930000
         AP    W#JLWK1,0(2,R1)         Add days of month                07940000
         LA    R2,P#MONTBL(R2)         Address month                    07950000
         MVC   W#HD1DTE(3),0(R2)       Move month                       07960000
         OI    W#JLWK1+3,X'0F'         Display sign                     07970000
         UNPK  W#HD1DTE+4(2),W#JLWK1   Get days                         07980000
         CLI   W#HD1DTE+4,C'0'         First 9 days ?                   07990000
         LA    R1,W#HD1DTE+6           Set pointer                      08000000
         BNE   JULCVT7                 No                               08010000
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 Move units digit                08020000
         BCTR  R1,0                    Drop pointer                     08030000
JULCVT7  DS    0H                                                       08040000
         MVC   0(4,R1),=C', 19'        Set up constant                  08050000
         TM    W#CURDTE,1              Year 2000?                       08060000
         BNO   JULCVT8                 No, continue                     08070000
         MVC   2(2,R1),=C'20'          Year 2000                        08080000
JULCVT8  DS    0H                                                       08090000
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     08100000
         MVC   4(2,R1),W#DWORD         Get year                         08110000
*                                                                       08120000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            08130000
         MVC   W#LINE+9(L'PGMID),PGMID Move version                     08140000
         BAL   R14,PRT                 Print a line                     08150000
*                                                                       08160000
         MVC   W#LINE+1(5),=C'PARM='     Move parameter info literal    08170000
         CLI   1(R9),0                 Any parameter?                   08180000
         BE    PRMPRT                  No, skip move                    08190000
         LH    R1,0(,R9)               Get parmeter length              08200000
         BCTR  R1,0                    Make machine length              08210000
         EX    R1,PRMMVC               Move parm to print line          08220000
PRMPRT   DS    0H                                                       08230000
         BAL   R14,PRT                                                  08240000
*                                                                       08250000
         LH    R2,0(,R9)               Get parameter length             08260000
         LTR   R2,R2                   Is there a parameter ?           08270000
         BZ    PRMERR                   No, parameter error             08280000
         LA    R9,2(,R9)               Address parameter                08290000
         ST    R9,W#PRMBGN                                              08300000
         MVI   VOLUMEID,C' '                                            08310000
         MVC   VOLUMEID+1(L'VOLUMEID-1),VOLUMEID                        08320000
         LA    R1,VOLUMEID                                              08330000
         SR    R14,R14                                                  08340000
PRMVOL10 DS    0H                                                       08350000
         CLI   0(R9),C','              End of vol ser ?                 08360000
         BE    PRMVOL20                Yes, process vol ser             08370000
         LA    R14,1(,R14)             Count characters in vol ser      08380000
         CH    R14,=AL2(6)             Vol ser too long ?               08390000
         BH    PRMERR                  Yes, error                       08400000
         MVC   0(1,R1),0(R9)                                            08410000
         LA    R1,1(,R1)               Up scan pointer                  08420000
         LA    R9,1(,R9)               Up scan pointer                  08430000
         SH    R2,=H'1'                Drop PARM length                 08440000
         BNZ   PRMVOL10                Go scan for comma                08450000
PRMVOL20 DS    0H                                                       08460000
         LTR   R0,R0                                                    08470000
         BZ    PRMERR                   Vol ser omitted                 08480000
PRMSCN   DS    0H                                                       08490000
         LTR   R2,R2                   End of PARM?                     08500000
         BE    PRMEND                  Yes, PARM parsed                 08510000
         CLI   0(R9),C','              Seperator?                       08520000
         BNE   PRMCHK                  No, check values                 08530000
         LA    R9,1(,R9)               Skip comma                       08540000
         SH    R2,=H'1'                Decrement length                 08550000
         B     PRMSCN                  Continue scan                    08560000
PRMCHK   DS    0H                                                       08570000
         CH    R2,=AL2(5)                                               08580000
         BL    PRMERR                                                   08590000
         CLC   =C'DEBUG',0(R9)                                          08600000
         BE    PRMDBG                                                   08610000
         CH    R2,=AL2(10)                                              08620000
         BL    PRMERR                                                   08630000
         CLC   =C'SELECT=(',0(R9)                                       08640000
         BE    PRMSEL                                                   08650000
         B     PRMERR                                                   08660000
PRMDBG   DS    0H                                                       08670000
         LA    R9,5(,R9)                                                08680000
         SH    R2,=AL2(5)                                               08690000
         OI    W#FLG,W#FLGDBG                                           08700000
         B     PRMSCNC                                                  08710000
PRMSEL   DS    0H                                                       08720000
         LA    R9,8(,R9)                                                08730000
         SH    R2,=AL2(8)                                               08740000
PRMSELSC DS    0H                                                       08750000
         CH    R2,=H'3'                                                 08760000
         BL    PRMERR                                                   08770000
         CLC   =C'F1',0(R9)                                             08780000
         BE    PRMSELF1                                                 08790000
         CLC   =C'F2',0(R9)                                             08800000
         BE    PRMSELF2                                                 08810000
         CLC   =C'F3',0(R9)                                             08820000
         BE    PRMSELF3                                                 08830000
         CLC   =C'F4',0(R9)                                             08840000
         BE    PRMSELF4                                                 08850000
         CLC   =C'F5',0(R9)                                             08860000
         BE    PRMSELF5                                                 08870000
         CLC   =C'F6',0(R9)                                             08880000
         BE    PRMSELF6                                                 08890000
         B     PRMERR                                                   08900000
PRMSELF1 DS    0H                                                       08910000
         OI    W#FLG,W#FLGF1+W#FLGSEL                                   08920000
         B     PRMSELNX                                                 08930000
PRMSELF2 DS    0H                                                       08940000
         OI    W#FLG,W#FLGF2+W#FLGSEL                                   08950000
         B     PRMSELNX                                                 08960000
PRMSELF3 DS    0H                                                       08970000
         OI    W#FLG,W#FLGF3+W#FLGSEL                                   08980000
         B     PRMSELNX                                                 08990000
PRMSELF4 DS    0H                                                       09000000
         OI    W#FLG,W#FLGF4+W#FLGSEL                                   09010000
         B     PRMSELNX                                                 09020000
PRMSELF5 DS    0H                                                       09030000
         OI    W#FLG,W#FLGF5+W#FLGSEL                                   09040000
         B     PRMSELNX                                                 09050000
PRMSELF6 DS    0H                                                       09060000
         OI    W#FLG,W#FLGF6+W#FLGSEL                                   09070000
PRMSELNX DS    0H                                                       09080000
         LA    R9,2(,R9)                                                09090000
         SH    R2,=H'2'                                                 09100000
         CLI   0(R9),C','                                               09110000
         BNE   PRMSELPA                                                 09120000
         LA    R9,1(,R9)                                                09130000
         SH    R2,=H'1'                                                 09140000
         B     PRMSELSC                                                 09150000
PRMSELPA DS    0H                                                       09160000
         CLI   0(R9),C')'                                               09170000
         BNE   PRMERR                                                   09180000
         LA    R9,1(,R9)                                                09190000
         SH    R2,=H'1'                                                 09200000
         B     PRMSCNC                                                  09210000
PRMSCNC  DS    0H                                                       09220000
         LTR   R2,R2                   End of PARM?                     09230000
         BZ    PRMEND                  Yes, PARM parsed                 09240000
         CLI   0(R9),C','              Delimiter?                       09250000
         BE    PRMSCN                  Yes, handle it                   09260000
         B     PRMERR                                                   09270000
PRMEND   DS    0H                                                       09280000
*        Get UCB for device info                                        09290000
         L     R9,CVTPTR               LOAD CVT ADDRESS                 09300000
         USING CVT,R9                  ESTABLISH ADDRESSABILITY         09310000
         TM    CVTDCB,X'88'            XA + CVOSEXT present             09320006
         BO    INITZOS                 Probably on z/OS                 09330006
         L     R3,40(,R9)      CVTILK2 LOAD UCB LOOKUP TABLE ADDR       09340006
         SLR   R9,R9                   CLEAR FOR INSERT                 09350000
         DROP  R9                      NOT NEEDED NOW                   09360000
UCBSCAN  DS    0H                                                       09370000
         CLC   =X'FFFF',0(R3)          CHECK END OF LIST                09380000
         BE    NOUNIT                  IF SO, INDICATE NOT FOUND        09390000
         ICM   R9,3,0(R3)              GET UCB ADDRESS                  09400000
         BZ    NEXTUCB                 IF SO, GET NEXT ENTRY            09410000
         CLI   2(R9),X'FF'             VALID UCB?                       09420000
         BNE   NEXTUCB                 IF NOT, GET NEXT ENTRY           09430000
         USING UCBCMSEG,R9             ESTABLISH ADDRESSABILITY         09440000
         CLI   UCBDVCLS,UCB3DACC       DASD DEVICE ?                    09450000
         BNE   NEXTUCB                  NO, TRY NEXT UCB                09460000
         TM    UCBSTAT,UCBONLI         IS VOLUME ONLINE ?               09470000
         BZ    NEXTUCB                  NO, TRY NEXT UCB                09480000
         CLC   VOLUMEID,UCBVOLI        VOLUME REQUESTED ?               09490000
         BE    UCBFOUND                                                 09500000
NEXTUCB  DS    0H                                                       09510000
         LA    R3,2(,R3)               BUMP TO NEXT ENTRY               09520000
         B     UCBSCAN                 AND TRY AGAIN                    09530000
UCBFOUND DS    0H                                                       09540000
         MVC   W#DEVTYP,UCBTYP+3                                        09550000
         TM    W#FLG,W#FLGDBG                                           09560000
         BNO   NODBG010                                                 09570000
         MVC   W#LINE+1(4),=C'UCB='                                     09580000
         ST    R9,W#DWORD                                               09590000
         UNPK  W#LINE+1+4(9),W#DWORD(5)                                 09600000
         TR    W#LINE+1+4(8),HEXTBL-240                                 09610000
         MVI   W#LINE+1+12,C' '                                         09620000
         BAL   R14,PRT                                                  09630000
         LR    R1,R9                                                    09640000
         LA    R0,48                                                    09650000
         BAL   R14,DMP                                                  09660000
NODBG010 DS    0H                                                       09670000
         UNPK  W#DWORD(5),UCBCHAN(3)                                    09680000
         MVC   W#UNIT,W#DWORD                                           09690000
         TR    W#UNIT,HEXTBL-240                                        09700000
         B     INITOPNS                                                 09710006
         DROP  R9                                                       09720003
INITZOS  DS    0H                                                       09730006
         MVI   W#DEVTYP,X'0F' ************ Force device type ********** 09740006
         MVC   W#UNIT,W#LINE  ************ Clear unit address ********* 09750006
INITOPNS DS    0H                                                       09760006
         LA    R15,DEVTB               Device type to device name       09770007
         LA    R0,DEVTB#               Number of entries                09780007
INITDEV1 DS    0H                                                       09790007
         CLC   W#DEVTYP,0(R15)         Check for this device type       09800007
         BE    INITDEV2                Found device type                09810007
         LA    R15,DEVTBLN(,R15)       Next entry                       09820007
         BCT   R0,INITDEV1             Loop through table               09830007
         B     INITUNSP                Unsupported device type          09840007
INITDEV2 DS    0H                                                       09850007
         MVC   W#DEVNAM(7),3(R15)      Save device name                 09860007
         MVI   W#DEVNAM+7,C' '                                          09870007
         B     INITOK                                                   09880000
*        Parsing error of PARM                                          09890000
PRMERR   DS    0H                                                       09900000
         LR    R1,R9                   Current position                 09910000
         S     R1,W#PRMBGN             Less start                       09920000
         LA    R1,W#LINE+6(R1)         Set location of error            09930000
         MVI   0(R1),C'*'              Mark where error is              09940000
         BAL   R14,PRT                 Print a line                     09950000
         MVC   W#LINE(19),=C' Parameters invalid'                       09960000
         BAL   R14,PRT                 Print a line                     09970000
         B     INITER                  Error                            09980000
*        Unsupported device type                                        09990007
INITUNSP DS    0H                                                       10000007
         MVC   W#LINE+1(L'DEVMSG),DEVMSG SET UP MESSAGE                 10010007
         BAL   R14,PRT                 Print a line                     10020007
         B     INITER                  Error                            10030007
INITOK   DS    0H                                                       10040000
         LA    R15,0                                                    10050000
         B     INITXT                                                   10060000
INITER   DS    0H                                                       10070000
         LA    R15,8                                                    10080000
         B     INITXT                                                   10090000
INITXT   DS    0H                                                       10100000
         L     R14,W#INIT14                                             10110000
         BR    R14                                                      10120000
*                                                                       10130000
*        Errors                                                         10140000
*                                                                       10150000
OPNERR   DS    0H                                                       10160007
         MVC   W#LINE+1(17),=C'OPEN failed RC=X'''                      10170007
         STM   R15,R0,W#DWORD                                           10180007
         UNPK  W#LINE+18(9),W#DWORD(5)                                  10190007
         TR    W#LINE+18(8),HEXTBL-240                                  10200007
         MVC   W#LINE+26(11),=C''' S99RSC=X'''                          10210007
         UNPK  W#LINE+37(9),W#DWORD+4(5)                                10220007
         TR    W#LINE+37(8),HEXTBL-240                                  10230007
         MVI   W#LINE+45,C''''                                          10240007
         BAL   R14,PRT                 PRINT                            10250007
         LA    R15,8                                                    10260007
         B     DONE                    GO END                           10270007
NOUNIT   DS    0H                                                       10280000
         MVC   W#LINE+1(L'UCBMSG),UCBMSG SET UP MESSAGE                 10290000
         BAL   R14,PRT                 PRINT                            10300000
         LA    R15,8                                                    10310000
         B     DONE                    GO END                           10320000
*        Unsupported device type                                        10330007
UNSUPDEV DS    0H                                                       10340007
         MVC   W#LINE+1(L'DEVMSG),DEVMSG SET UP MESSAGE                 10350007
         BAL   R14,PRT                 Print a line                     10360007
         LA    R15,8                                                    10370007
         B     DONE                    GO END                           10380007
F5ERR    DS    0H                                                       10390000
         MVC   W#LINE+1(L'F5MSG1),F5MSG1 SET UP MESSAGE                 10400000
         BAL   R14,PRT                 FORMAT 5 DSCB NOT FOUND msg      10410000
         MVC   W#LINE+1(L'F5MSG2),F5MSG2 SET UP MESSAGE                 10420000
         BAL   R14,PRT                 PRINT                            10430000
         LA    R15,8                                                    10440000
         B     DONE                    GO END                           10450000
IOERR    DS    0H                                                       10460000
         MVC   IOERMSG,=C'Permanent I/O error on VTOC on volume '       10470000
         MVC   IOERSER,VOLUMEID        GET VOL SER                      10480000
         MVC   IOERMSG1,=C' CCHHR='                                     10490000
         L     R1,ADOFDSCB             GET CCHHR ADDRESS                10500000
         UNPK  IOERLOCN(11),0(6,R1)    Make CCHHR viewable              10510000
         MVI   IOERLOCN+10,C' '        CLEAR OUT JUNK                   10520000
         TR    IOERLOCN(10),HEXTBL-240                                  10530000
         MVC   W#LINE+1(IOERMSGL),IOERMSG SET UP MESSAGE                10540000
         BAL   R14,PRT                 PRINT                            10550000
         LA    R15,8                                                    10560000
         B     DONE                    GO END                           10570000
*********************************************************************** 10580000
*        Format Control Block                                         * 10590000
*          R5=Section length                                          * 10600000
*          R3=CBDEF                                                   * 10610000
*          R2=Data address                                            * 10620000
*********************************************************************** 10630000
FMT      DS    0H                                                       10640000
         STM   R0,R15,W#FREGS      Save registers                       10650000
         USING BLK,R3                                                   10660000
         LH    R0,BLKFIRST         Control block start offset           10670000
         STH   R0,W#FBGNOF         Save it                              10680000
         ST    R2,W#FADDR          Save control block address           10690000
         AR    R2,R0               Add offset to address                10700000
         LA    R3,BLKHDNXT         Get next block field                 10710000
         LR    R4,R2               Start address for .NEXT              10720000
         AR    R5,R2               Offset end to address                10730000
         OI    W#FFLAG,W#FFLAG1    Set line starting                    10740000
FMTCB    DS    0H                                                       10750000
         CLI   BLKTYPE,BLKHEX      Hex field?                           10760000
         BE    FMTHEX              Yes, do hex field                    10770000
         CLI   BLKTYPE,BLKCONST    Constant field                       10780000
         BE    FMTCONST            Yes, do constant (label)             10790000
         CLI   BLKTYPE,BLKCHAR     Character field                      10800000
         BE    FMTCHAR             Yes, do character field              10810000
         CLI   BLKTYPE,BLKBIT      Bit field                            10820006
         BE    FMTBIT              Yes, do bit formatting               10830006
         B     FMTEND              Must be block end, done              10840000
*        Character constant (label)                                     10850000
FMTCONST DS    0H                                                       10860000
         LA    R15,BLKDATA         Address of field                     10870000
         SR    R14,R14                                                  10880000
         IC    R14,BLKDTALN        Get length of field                  10890000
         SR    R1,R1                                                    10900000
         IC    R1,BLKOFF           Line offset                          10910000
         LA    R1,W#LINE+1+9(R1)   Add line start                       10920000
         EX    R14,FMTEMVC         Move character field                 10930000
         LA    R3,BLKDTANX(R14)    Next field definition                10940000
         TM    W#FFLAG,W#FFLAG1    First constant?                      10950000
         BZ    FMTLOOP             No, we've formatted address          10960000
         CLI   BLKTYPE,BLKCONST    Constant field                       10970000
         BE    FMTLOOP             Yes, don't have offset yet           10980000
         NI    W#FFLAG,255-W#FFLAG1 Set address is being formatted      10990000
         BAL   R14,FMTOFF          Format field offset                  11000000
         B     FMTLOOP             Back for another field               11010000
FMTEMVC  MVC   0(0,R1),0(R15)      Move character field                 11020000
*        Character field                                                11030000
FMTCHAR  DS    0H                                                       11040000
         XC    W#FMTBTL,W#FMTBTL   Clear last Hex length                11050006
         CLC   BLKDISP,=AL2(32768) .NEXT field (X'8000')?               11060000
         BE    FMTCHAR0            Yes, source address set              11070000
         LH    R4,BLKDISP          Offset of field                      11080000
         AR    R4,R2               Add address to offset                11090000
FMTCHAR0 DS    0H                                                       11100000
         CR    R4,R5               Beyond end of section                11110000
         BNL   FMTCHRNA            Yes, not available                   11120000
         SR    R14,R14                                                  11130000
         IC    R14,BLKCHRLN        Get length of field                  11140000
         CLI   BLKCHRSC,0          SCON used?                           11150000
         BE    FMTCHAR1            No, regular length                   11160000
         SR    R1,R1                                                    11170000
         IC    R1,BLKCHRSC         Get SCON base register               11180000
         SRL   R1,2                Base reg times 4                     11190000
         N     R1,=X'0000003C'     Clear non base reg stuff             11200000
         L     R1,W#FREGS(R1)      Get base register                    11210000
         SR    R0,R0                                                    11220000
         ICM   R0,3,BLKCHRSC       Get SCON displacement                11230000
         N     R0,=X'00000FFF'     Clear base register                  11240000
         AR    R1,R0               Add to base register                 11250000
         SR    R14,R14                                                  11260000
         IC    R14,BLKOFF          Get offset into line                 11270000
         LA    R14,1+9+1(,R14)     Add in start of formatting +1        11280000
         LA    R0,132              Get line length                      11290000
         SR    R0,R14              Get maximum length                   11300000
         IC    R14,0(,R1)          Get length of data                   11310000
         CR    R14,R0              Is it greater than max length        11320000
         BNH   FMTCHAR1            No, go move it to line               11330000
         LR    R14,R0              Its to long, just move what fits     11340000
FMTCHAR1 DS    0H                                                       11350000
         SR    R1,R1                                                    11360000
         IC    R1,BLKOFF           Line offset                          11370000
         LA    R1,W#LINE+1+9(R1)   Add line start                       11380000
         EX    R14,FMTCMVC         Move field to line                   11390000
         EX    R14,FMTCTR          Remove unprintables                  11400000
FMTCHAR2 DS    0H                                                       11410000
         BAL   R14,FMTOFF          Format field offset                  11420000
         SR    R14,R14                                                  11430000
         IC    R14,BLKCHRLN        Get length of field                  11440000
         LA    R4,1(R4,R14)        Next field                           11450000
         LA    R3,BLKCHRNX         Next field definition                11460000
         B     FMTLOOP             Back for another field               11470000
FMTCMVC  MVC   0(0,R1),0(R4)       Move character field                 11480000
FMTCTR   TR    0(0,R1),P#TBLCH     Remove unprintables                  11490000
*        Field beyond end of section                                    11500000
FMTCHRNA DS    0H                                                       11510000
         LR    R0,R4               Save next                            11520000
         LA    R4,=C'n/a'          Field not available                  11530000
         LA    R14,3-1             Machine length                       11540000
         SR    R1,R1                                                    11550000
         IC    R1,BLKOFF           Line offset                          11560000
         LA    R1,W#LINE+1+9(R1)   Add line start                       11570000
         EX    R14,FMTCMVC         Move field to line                   11580000
         LR    R4,R0               Restore next                         11590000
         B     FMTCHAR2            Finish off this field                11600000
*        Hex field                                                      11610000
FMTHEX   DS    0H                                                       11620000
         CLC   BLKDISP,=AL2(32768) .NEXT field?                         11630000
         BE    FMTHEX0             Yes, source address set              11640000
         LH    R4,BLKDISP          Offset of field                      11650000
         AR    R4,R2               Add address to offset                11660000
FMTHEX0  DS    0H                                                       11670000
         CR    R4,R5               Beyond end of section                11680000
         BNL   FMTHEXNA            Yes, not available                   11690000
         CLI   BLKHEXSC,0          SCON used?                           11700000
         BE    FMTHEXL1            No, regular length                   11710000
         SR    R1,R1                                                    11720000
         IC    R1,BLKHEXSC         Get base register                    11730000
         SRL   R1,2                Base reg times 8                     11740000
         N     R1,=X'0000003C'      lear not base reg stuff             11750000
         L     R1,W#FREGS(R1)      Get base register                    11760000
         SR    R0,R0                                                    11770000
         ICM   R0,3,BLKCHRSC       Get SCON                             11780000
         N     R0,=X'00000FFF'     Clear base register                  11790000
         AR    R1,R0               Add to base register                 11800000
         SR    R14,R14                                                  11810000
         IC    R14,BLKOFF          Get offset into line                 11820000
         LA    R14,1+9+1(,R14)     Add in start of formatting +1        11830000
         LA    R0,132              Get line length                      11840000
         SR    R0,R14              Get maximum length                   11850000
         SR    R14,R14                                                  11860000
         IC    R14,0(,R1)          Get length of data                   11870000
         CR    R14,R0              Is it greater than max length        11880000
         BNH   FMTHEXL0            No, go move it to line               11890000
         LR    R14,R0              Its to long, just move what fits     11900000
FMTHEXL0 DS    0H                                                       11910000
         LR    R1,R14              Place into R1                        11920000
         B     FMTHEXL2            Go process length                    11930000
FMTHEXL1 DS    0H                                                       11940000
         SR    R1,R1                                                    11950000
         IC    R1,BLKHEXLN         Get field length                     11960000
FMTHEXL2 DS    0H                                                       11970000
         ST    R1,W#FMTBTL         Save length of HEX field             11980006
         LA    R0,1(,R1)           Machine to actual length             11990000
         SR    R1,R1                                                    12000000
         IC    R1,BLKOFF           Line offset                          12010000
         LA    R1,W#LINE+1+9(R1)   Add line start                       12020000
         LA    R14,W#FTEMP         Where to start from even digits      12030000
         LR    R15,R4              Start of field                       12040000
         ST    R15,W#FMTBTA        Save address of HEX field            12050006
         CLI   BLKHEXOF,1          Do we want second digit              12060000
         BNE   FMTHEXF1            No, want first                       12070000
         LA    R14,W#FTEMP+1       Where to start from odd digits       12080000
FMTHEXF1 DS    0H                                                       12090000
         MVC   W#FTEMP+5(1),0(R15) Get field byte                       12100000
         UNPK  W#FTEMP(3),W#FTEMP+5(2) Convert hex to character         12110000
         TR    W#FTEMP(2),HEXTBL-240  Finish convert                    12120000
         MVC   0(1,R1),0(R14)      Copy first digit                     12130000
         SH    R0,=H'1'            Count digit done                     12140000
         BZ    FMTHEXF3            If all done stop formatting          12150000
         MVC   1(1,R1),1(R14)      Move another hex digit               12160000
         LA    R1,2(,R1)           Next output area                     12170000
         LA    R15,1(,R15)         Next input area                      12180000
         BCT   R0,FMTHEXF1         Loop thru area                       12190000
FMTHEXF3 DS    0H                                                       12200000
         BAL   R14,FMTOFF          Format field offset                  12210000
         SR    R14,R14                                                  12220000
         IC    R14,BLKHEXLN        Get field length                     12230000
         LR    R0,R14              Save field length                    12240006
         LR    R1,R4               Save address                         12250006
         LA    R14,1(,R14)                                              12260000
         SRL   R14,1                                                    12270000
         AR    R4,R14              Next field                           12280000
         LA    R3,BLKHEXNX         Next field definition                12290000
*        BIT descriptions can only follow HEX field length 1            12300006
         B     FMTLOOP                                                  12310006
*        Field beyond end of section                                    12320000
FMTHEXNA DS    0H                                                       12330000
         LR    R0,R4               Save next                            12340000
         LA    R4,=C'n/a'          Field not available                  12350000
         LA    R14,3-1             Machine length                       12360000
         SR    R1,R1                                                    12370000
         IC    R1,BLKOFF           Line offset                          12380000
         LA    R1,W#LINE+1+9(R1)   Add line start                       12390000
         EX    R14,FMTCMVC         Move field to line                   12400000
         LR    R4,R0               Restore next                         12410000
         B     FMTHEXF3            Finish off this field                12420000
*                                                                       12430006
FMTBIT   DS    0H                                                       12440006
         BAL   R14,PRT             Print previous line                  12450006
         ICM   R15,15,W#FMTBTA     Previous field here if hex           12460006
         BZ    FMTBIT02            Previous field not hex               12470006
         L     R0,W#FMTBTL         HEX length                           12480006
         CH    R0,=H'+1'           HEX field length 2 (1 byte)          12490006
         BNE   FMTBIT02            Last hex field length not 2          12500006
FMTBIT01 DS    0H                                                       12510006
         CLI   BLKTYPE,BLKBIT      Bit definition                       12520006
         BNE   FMTCB               No, continue with next definition    12530006
*        Format bit description if it is on                             12540006
         L     R15,W#FMTBTA        Previous field here if hex           12550006
         IC    R1,BLKBITVA         Get bit to test                      12560006
         EX    R1,FMTBITTM         Test bit                             12570006
         BNO   FMTBIT02            Not on                               12580006
         SR    R1,R1                                                    12590006
         IC    R1,BLKBITOF         Line offset for bit value            12600006
         LA    R1,W#LINE+1+9(R1)   Where tto place bit                  12610006
         UNPK  W#FTEMP(3),BLKBITVA(2) Convert bit to character          12620006
         TR    W#FTEMP(2),HEXTBL-240  Finish convert                    12630006
         MVC   0(2,R1),W#FTEMP     Move bit to output area              12640006
         SR    R1,R1                                                    12650006
         IC    R1,BLKOFF           Line offset for description          12660006
         LA    R1,W#LINE+1+9(R1)   Where to place description           12670006
         SR    R14,R14                                                  12680006
         IC    R14,BLKBITLN        Get length of bit description        12690006
         EX    R14,FMTBITMV        Move character field                 12700006
         BAL   R14,PRT             Print a line                         12710006
FMTBIT02 DS    0H                                                       12720006
         SR    R14,R14                                                  12730006
         IC    R14,BLKBITLN        Get length of bit description        12740006
         LA    R3,BLKBITNX(R14)    Next field definition                12750006
         B     FMTBIT01            Back for another bit if any          12760006
FMTBITTM TM    0(R15),0            Test bit                             12770006
FMTBITMV MVC   0(0,R1),BLKBITDE    Move character field                 12780006
*                                                                       12790006
FMTLOOP  DS    0H                                                       12800000
         CLI   BLKTYPE,BLKEND      End of block definition              12810000
         BE    FMTEND              yes, were done formatting            12820000
         CLI   BLKOFF,0            New line requested                   12830000
         BNE   FMTCB               No, continue with next field         12840000
         BAL   R14,PRT             Print a line                         12850000
         B     FMTCB               Go handle next field                 12860000
FMTEND   DS    0H                                                       12870000
         BAL   R14,PRT             Print a line                         12880000
         LM    R0,R15,W#FREGS      Restore registers                    12890000
         BR    R14                 Return to caller                     12900000
*        Format offset as needed                                        12910000
FMTOFF   DS    0H                                                       12920000
         CLI   W#LINE+5+3,C' '     Have we've done offset?              12930000
         BNER  R14                 Yes, don't do again                  12940000
         LR    R15,R4              Get a current field address          12950000
         SR    R15,R2              Get field displacement               12960000
         LPR   R0,R15              Get positive value                   12970000
         ST    R0,W#FDWD           Save displacement                    12980000
         UNPK  W#LINE+5(5),W#FDWD+2(3) Convert to character             12990000
         TR    W#LINE+6(3),HEXTBL-240 Finish convert                    13000000
         MVI   W#LINE+9,C' '       Clear extra info                     13010000
         LA    R1,W#LINE+5         Where to start zero suppression      13020000
         LA    R0,3                Only handle 3 zeros                  13030000
FMTOFF1  DS    0H                                                       13040000
         CLI   0(R1),C'0'          Is there a leading zero              13050000
         BNE   FMTOFF2             No, we finished suppression          13060000
         MVI   0(R1),C' '          Clear leading zero                   13070000
         LA    R1,1(,R1)           Next digit                           13080000
         BCT   R0,FMTOFF1          Suppress limit                       13090000
FMTOFF2  DS    0H                                                       13100000
         BCTR  R1,0                Back to previous spot                13110000
         LTR   R15,R15             Is value positive                    13120000
         MVI   0(R1),C'+'          Set positive indicator               13130000
         BNLR  R14                 Exit if +                            13140000
         MVI   0(R1),C'-'          Set negative indicator               13150000
         BR    R14                 Exit                                 13160000
         DROP  R3                                                       13170000
*********************************************************************** 13180000
*            WRITE PRINT LINE                                         * 13190000
*********************************************************************** 13200000
PRT      DS    0H                                                       13210000
         ST    R14,W#PRTR14                                             13220000
         CP    W#LNCT,=P'+60'          End of page                      13230000
         BL    PRTCHK                  No, check if line fit in page    13240000
PRTHDRS  DS    0H                                                       13250000
         AP    W#PGCT,=P'+1'           Count pages                      13260000
         MVC   W#HD1PGC,=X'40202120'   Page count mask                  13270000
         ED    W#HD1PGC,W#PGCT         Edit page count                  13280000
         PUT   W#OTDCB,W#HD1           Print heading 1                  13290000
         ZAP   W#LNCT,=P'+1'           Init line count                  13300000
         MVI   W#LINE,C'0'             Skip after heading               13310000
PRTCHK   DS    0H                                                       13320000
         CLI   W#LINE,C'+'             Overprint?                       13330000
         BE    PRTLINE                 Yes, don't count                 13340000
         CLI   W#LINE,C'1'             New line?                        13350000
         BE    PRTHDRS                 Yes, print header                13360000
         CLI   W#LINE,C' '             Write after advancing 1?         13370000
         BE    PRTLINE1                Yes, go check if fit             13380000
         CLI   W#LINE,C'0'             Write after advancing 2?         13390000
         BE    PRTLINE2                Yes, go check if fit             13400000
         CLI   W#LINE,C'-'             Write after advancing 3?         13410000
         BE    PRTLINE3                Yes, go check if fit             13420000
         B     PRTLINE                 Ignore any other ctl chars       13430000
PRTLINE1 DS    0H                                                       13440000
         AP    W#LNCT,=P'+1'           Add to line count                13450000
         B     PRTVFY                  Go see if it will fit            13460000
PRTLINE2 DS    0H                                                       13470000
         AP    W#LNCT,=P'+2'           Add to line count                13480000
         B     PRTVFY                  Go see if it will fit            13490000
PRTLINE3 DS    0H                                                       13500000
         AP    W#LNCT,=P'+3'           Add to line count                13510000
PRTVFY   DS    0H                                                       13520000
         CP    W#LNCT,=P'+60'          Overflow?                        13530000
         BH    PRTHDRS                 Yes, force header                13540000
PRTLINE  DS    0H                                                       13550000
         PUT   W#OTDCB,W#LINE          Print a line                     13560000
         MVI   W#LINE,C' '             Clear print line                 13570000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              13580000
         L     R14,W#PRTR14                                             13590000
         BR    R14                     Return to caller                 13600000
*********************************************************************** 13610000
*        DUMP WITH ADDRESS OF STORAGE DUMPED                          * 13620000
*********************************************************************** 13630000
DMPAD    DS    0H                                                       13640000
         ST    R14,W#DMPADS                                             13650000
         STM   R0,R15,W#DMPRGS         SAVE REGISTERS                   13660000
         ST    R1,W#DMPOFF                                              13670000
         LA    R2,W#LINE+L'W#LINE-1                                     13680000
         LA    R0,L'W#LINE-1                                            13690000
DMPAD010 DS    0H                                                       13700000
         CLI   0(R2),C' '                                               13710000
         BNE   DMPAD020                                                 13720000
         BCTR  R2,0                                                     13730000
         BCT   R0,DMPAD010                                              13740000
DMPAD020 DS    0H                                                       13750000
         MVC   2(2,R2),=C'at'                                           13760000
         LA    R2,5(,R2)               OUTPUT AREA ADDRESS              13770000
         LA    R1,W#DMPOFF             ADDRESS OF OFFSET TO DUMP        13780000
         LA    R15,4                   CONVERT 4 BYTES                  13790000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            13800000
         BAL   R14,PRT                 PRINT ADDRESS OF DATA            13810000
         LM    R0,R15,W#DMPRGS         SAVE REGISTERS                   13820000
         BAL   R14,DMP                 DUMP STORAGE                     13830000
         L     R14,W#DMPADS                                             13840000
         BR    R14                     RETURN TO CALLER                 13850000
*********************************************************************** 13860000
*        DUMP DATA                                                    * 13870000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 13880000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 13890000
*********************************************************************** 13900000
DMP      DS    0H                                                       13910000
         STM   R0,R15,W#DMPRGS         Save registers                   13920000
         LR    R3,R1                   Get address to dump              13930000
         LR    R4,R0                   Get length                       13940000
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump             13950000
         MVI   W#DMPFLG,W#DMPFL1       First line                       13960000
DMPDMPLP DS    0H                                                       13970000
         LTR   R4,R4                   Any data to dump?                13980000
         BZ    DMPHEXXT                Ye, all done                     13990000
         TM    W#DMPFLG,W#DMPFL1       First line?                      14000000
         BO    DMPALIN                 Yes, can't have same as above    14010000
         LA    R0,32                   Default length                   14020000
         CR    R4,R0                   Length longer than 32?           14030000
         BNH   DMPDUPCK                No, were at last line            14040000
         LR    R14,R3                  Get current input area           14050000
         SR    R14,R0                  Back to previous area            14060000
         CLC   0(32,R14),0(R3)         Duplicate of previous line       14070000
         BNE   DMPDUPCK                No, do lines same as             14080000
         SR    R4,R0                   Reduce length to do              14090000
         TM    W#DMPFLG,W#DMPFLD       Duplicate in progress?           14100000
         BO    DMPNXTLN                Yes, we have first offset        14110000
         L     R14,W#DMPOFF            Get current offset               14120000
         ST    R14,W#DMPDUP            Save as first offset             14130000
         OI    W#DMPFLG,W#DMPFLD       Set duplicate                    14140000
         B     DMPNXTLN                Continue                         14150000
DMPDUPCK DS    0H                                                       14160000
         TM    W#DMPFLG,W#DMPFLD       Duplicate in progress?           14170000
         BNO   DMPALIN                 No, no duplicate to report       14180000
         MVC   W#LINE+7(5),=C'lines'   Move literal                     14190000
         LA    R2,W#LINE+13            Output area address              14200000
         LA    R1,W#DMPDUP+2           Address of offset to dump        14210000
         LA    R15,2                   Convert 4 bytes                  14220000
         BAL   R14,DMPDSP              Convert it to display            14230000
         MVI   W#LINE+17,C'-'          Thru literal                     14240000
         L     R1,W#DMPOFF             Get current offset               14250000
         S     R1,=A(32)               Get last duplicate offset        14260000
         ST    R1,W#DMPDUP             Save for dumping                 14270000
         LA    R2,W#LINE+18            Output area address              14280000
         LA    R1,W#DMPDUP+2           Address of offset to dump        14290000
         LA    R15,2                   Convert 4 bytes                  14300000
         BAL   R14,DMPDSP              Convert it to display            14310000
         MVC   W#LINE+23(13),=C'same as above' move literal             14320000
         BAL   R14,PRT                 Print a line                     14330000
         NI    W#DMPFLG,255-W#DMPFLD   Reset duplicate in progress      14340000
DMPALIN  DS    0H                                                       14350000
         LA    R2,W#LINE+1             Output area address              14360000
         LA    R1,W#DMPOFF+2           Address of offset to dump        14370000
         LA    R15,2                   Convert 4 bytes                  14380000
         BAL   R14,DMPDSP              Convert it to display            14390000
         LA    R2,2(,R2)               Skip 1 between offset & data     14400000
         LR    R1,R3                   Address of data                  14410000
         LA    R5,32                   Default length                   14420000
         CR    R4,R5                   Length longer than 32 ?          14430000
         BH    DMPDODMP                Yes, use 32                      14440000
         LR    R5,R4                   Use what is left                 14450000
DMPDODMP DS    0H                                                       14460000
         SR    R4,R5                   Reduce amount to do              14470000
         MVI   W#LINE+89,C'*'          Box in display portion           14480000
         BCTR  R5,0                    Make zero based                  14490000
         EX    R5,DMPMVC               Do move                          14500000
         EX    R5,DMPTR                Translate out bad stuff          14510000
         LA    R5,1(,R5)               Restore length                   14520000
         MVI   W#LINE+122,C'*'         Complete box                     14530000
DMPDMPHX DS    0H                                                       14540000
         LA    R15,4                   4 bytes to process               14550000
         CR    R5,R15                  Length longer than 4?            14560000
         BH    DMPDMPIT                Yes, dump 4 bytes                14570000
         LR    R15,R5                  Use length left                  14580000
DMPDMPIT DS    0H                                                       14590000
         SR    R5,R15                  Reduce amount to do              14600000
         BAL   R14,DMPDSP              Convert data                     14610000
         LA    R2,1(,R2)               Skip 1 byte                      14620000
         LA    R0,W#LINE+43            Halfway point address            14630000
         CR    R0,R2                   At halfway point?                14640000
         BNE   DMPDMPNX                No, continue                     14650000
         LA    R2,1(,R2)               Skip 1 byte                      14660000
DMPDMPNX DS    0H                                                       14670000
         LTR   R5,R5                   Any left to do ?                 14680000
         BH    DMPDMPHX                Yes, go do it                    14690000
         BAL   R14,PRT                 Print a line                     14700000
DMPNXTLN DS    0H                                                       14710000
         L     R1,W#DMPOFF             Get offset in record             14720000
         LA    R1,32(,R1)              Add in length we will dump       14730000
         ST    R1,W#DMPOFF             Save offset in record            14740000
         LA    R3,32(,R3)              Next input area                  14750000
         NI    W#DMPFLG,255-W#DMPFL1   Not first line                   14760000
         B     DMPDMPLP                Loop thru until done             14770000
DMPHEXXT DS    0H                                                       14780000
         LM    R0,R15,W#DMPRGS         Restore callers regs             14790000
         BR    R14                     Exit . . .                       14800000
DMPMVC   MVC   W#LINE+90(0),0(R1)      <<< executed >>>                 14810000
DMPTR    TR    W#LINE+90(0),P#TBLCH    <<< executed >>>                 14820000
*                                                                       14830000
*        Convert hex data to display                                    14840000
*                                                                       14850000
DMPDSP   DS    0H                                                       14860000
         UNPK  0(1,R2),0(1,R1)         Get first hex byte               14870000
         NI    0(R2),X'0F'             Remove zone                      14880000
         MVC   1(1,R2),0(R1)           Move second hex byte             14890000
         NI    1(R2),X'0F'             Remove its zone also             14900000
         TR    0(2,R2),=C'0123456789ABCDEF' Translate to hex            14910000
         LA    R2,2(,R2)               Point to next output area        14920000
         LA    R1,1(,R1)               Point to next input area         14930000
         BCT   R15,DMPDSP              Loop thru data                   14940000
         BR    R14                     Exit                             14950000
********************************************************************    14960006
*                                                                  *    14970006
*        Trace                                                     *    14980006
*                                                                  *    14990006
********************************************************************    15000006
DIAGTRC  DS    0H                                                       15010006
         LR    R2,R14                                                   15020006
         MVC   W#DIAGLN,W#LINE                                          15030006
         MVI   W#LINE,C' '                                              15040006
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              15050006
         SR    R14,R11                                                  15060006
         SH    R14,=H'+8'                                               15070006
         STH   R14,W#DWORD                                              15080006
         UNPK  W#LINE+2(5),W#DWORD(3)                                   15090006
         TR    W#LINE+2(4),HEXTBL-240                                   15100006
         MVI   W#LINE+6,C' '                                            15110006
         MVI   W#LINE+1,C'+'                                            15120006
         BAL   R14,PRT                                                  15130006
         MVC   W#LINE,W#DIAGLN                                          15140006
         BR    R2                                                       15150006
*                                                                       15160006
*                                                                       15170000
*                                                                       15180000
PRMMVC   MVC   W#LINE+6(0),2(R9)       Executed parm move               15190000
         DC    0D'0'                                                    15200000
CODEEND  EQU   *                                                        15210000
         DROP  R11                                                      15220000
         DROP  R12                                                      15230000
         DROP  R13                                                      15240000
*                                                                       15250000
*        CONSTANTS                                                      15260000
*                                                                       15270000
*               Some device type constants                              15280000
*        Disk        DevTyp     Cyl     Alt  Trk/Cyl    Track Size      15290000
*        2311             1     200       3       10         3,625      15300000
*        2301             2      25                8        20,483      15310000
*        2303             3      80               10         4,892      15320000
*        2302             4     246               46         4,984      15330000
*        2321             5     980               20         2,000      15340000
*        2305-1           6      48       6        8        14,136      15350000
*        2305-2           7      96      12        8        14,660      15360000
*        2314             8     200       3       20         7,294      15370000
*        3330-1           9     404       7       19        13,030      15380000
*        3340-35          A     348       1       12         8,368      15390000
*        3340-70          A*    696       2       12         8,368      15400000
*        3350             B     555       5       30        19,069      15410000
*        3375             C     959       1       12        35,616      15420000
*        3330-11          D     808       7       19        13,030      15430000
*        3380 A/B/D/J     E     885       1       15        47,476      15440000
*        3380-E           E*  1,770       2       15        47,476      15450000
*        3380-K           E*  2,655       3       15        47,476      15460000
*        3390-1           F   1,113       1       15        56,664      15470000
*        3390-2           F*  2,226       1       15        56,664      15480000
*        3390-3           F*  3,339       1       15        56,664      15490000
*        3390-9           F* 10,017       3       15        56,664      15500000
*        3390-27          F* 32,760       3       15        56,664      15510000
*        3390-54          F* 65,520       3       15        56,664      15520000
*                                                                       15530000
*                                                                       15540000
*              DEVTYP  TRK/CYL DEVNAME                                  15550000
DEVTB    DC    AL1(01),AL2(10),CL7'2311   '                             15560000
DEVTBLN  EQU   *-DEVTB                                                  15570000
         DC    AL1(02),AL2(08),CL7'2301   '                             15580000
         DC    AL1(03),AL2(10),CL7'2303   '                             15590000
         DC    AL1(04),AL2(46),CL7'2302   '                             15600000
         DC    AL1(05),AL2(20),CL7'2321   '                             15610000
         DC    AL1(06),AL2(08),CL7'2305-1 '                             15620000
         DC    AL1(07),AL2(08),CL7'2305-2 '                             15630000
         DC    AL1(08),AL2(20),CL7'2314   '                             15640000
         DC    AL1(09),AL2(19),CL7'3330-1 '                             15650000
         DC    AL1(10),AL2(12),CL7'3340   '                             15660000
         DC    AL1(11),AL2(30),CL7'3350   '                             15670000
         DC    AL1(12),AL2(12),CL7'3375   '                             15680000
         DC    AL1(13),AL2(19),CL7'3330-11'                             15690000
         DC    AL1(14),AL2(15),CL7'3380   '                             15700000
         DC    AL1(15),AL2(15),CL7'3390   '                             15710000
DEVTB#   EQU   (*-DEVTB)/DEVTBLN                                        15720000
*                                                                       15730000
*                CYL/VOL    MODEL                                       15740000
MDL3390  DC    AL2(01113),C'-1  '                                       15750000
MDL3390L EQU   *-MDL3390                                                15760000
         DC    AL2(02226),C'-2  '                                       15770000
         DC    AL2(03339),C'-3  '                                       15780000
         DC    AL2(10017),C'-9  '                                       15790000
         DC    AL2(32760),C'-27 '                                       15800000
         DC    AL2(65520),C'-54 '                                       15810000
MDL3390# EQU   (*-MDL3390)/MDL3390L                                     15820000
         DC    AL2(00000),C'    '                                       15830000
*                                                                       15840000
*                CYL/VOL    MODEL                                       15850000
MDL3340  DC    AL2(00348),C'-35 '                                       15860000
MDL3340L EQU   *-MDL3340                                                15870000
         DC    AL2(00696),C'-70 '                                       15880000
MDL3340# EQU   (*-MDL3340)/MDL3340L                                     15890000
         DC    AL2(00000),C'    '                                       15900000
*                                                                       15910000
*                CYL/VOL    MODEL                                       15920000
MDL3380  DC    AL2(01770),C'-E  '                                       15930000
MDL3380L EQU   *-MDL3380                                                15940000
         DC    AL2(02655),C'-K  '                                       15950000
MDL3380# EQU   (*-MDL3380)/MDL3380L                                     15960000
         DC    AL2(00000),C'    '                                       15970000
*                                                                       15980000
*  ERROR MESSAGES                                                       15990000
*                                                                       16000000
UCBMSG   DC    C'Volume not mounted or not DASD device type'            16010000
*                                                                       16020000
DEVMSG   DC    C'Volume mounted on unsupported device type'             16030000
*                                                                       16040000
F5MSG1   DC    C'Volume not mapped. Format 5 DSCB not found in VTOC'    16050000
*                                                                       16060000
F5MSG2   DC    C'but pointed to by format 4 DSCB'                       16070000
*                                                                       16080000
HEXTBL   DC    C'0123456789ABCDEF'                                      16090000
*                                                                       16100000
         LTORG ,                                                        16110000
*                                                                       16120000
P#TBLCH  DC    CL256' '                                                 16130000
         ORG   P#TBLCH+X'4A' Cent                                       16140000
         DC    X'4A4B4C4D4E4F50'                                        16150000
         ORG   P#TBLCH+X'5A' exclamation                                16160000
         DC    X'5A5B5C5D5E5F6061'                                      16170000
         ORG   P#TBLCH+X'6A'                                            16180000
         DC    X'6A6B6C6D6E6F'                                          16190000
         ORG   P#TBLCH+X'7A'                                            16200000
         DC    X'7A7B7C7D7E7F'                                          16210000
         ORG   P#TBLCH+C'a'                                             16220000
         DC    C'abcdefghi'                                             16230000
         ORG   P#TBLCH+C'j'                                             16240000
         DC    C'jklmnopqr'                                             16250000
         ORG   P#TBLCH+C's'                                             16260000
         DC    C'stuvwxyz'                                              16270000
         ORG   P#TBLCH+C'A'                                             16280000
         DC    C'ABCDEFGHI'                                             16290000
         ORG   P#TBLCH+C'J'                                             16300000
         DC    C'JKLMNOPQR'                                             16310000
         ORG   P#TBLCH+C'S'                                             16320000
         DC    C'STUVWXYZ'                                              16330000
         ORG   P#TBLCH+C'0'                                             16340000
         DC    C'0123456789'                                            16350000
         ORG                                                            16360000
*                                                                       16370000
P#MONTBL DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  16380000
*                                                                       16390000
         DC    0D'0'                                                    16400000
P#OPNLSB OPEN  (0,(OUTPUT)),MF=L                                        16410000
P#OPNLST EQU   P#OPNLSB,*-P#OPNLSB                                      16420000
         DC    0D'0'                                                    16430000
P#OTDCBB DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,RECFM=FBA,LRECL=133    16440000
P#OTDCB  EQU   P#OTDCBB,*-P#OTDCBB                                      16450000
*                                                                       16460000
         DC    0D'0'                                                    16470000
DATAEND  EQU   *                                                        16480000
         DC    (((((*-FMTVTOC)/256)+1)*256)-(*-FMTVTOC))X'00'           16490000
*********************************************************************** 16500000
*        Work areas                                                   * 16510000
*********************************************************************** 16520000
W#       DSECT                                                          16530000
         DS    18A                     SAVE AREA                        16540000
W#DWORD  DS    D                       DOUBLE WORD WORK                 16550000
W#INIT14 DS    A                                                        16560000
W#PRTR14 DS    A                                                        16570000
W#DSDM14 DS    A                                                        16580000
W#PRMBGN DS    A                                                        16590000
*                                                                       16600000
VTOCPARM DS    0A                      PARAMETERS TO VTOC AM            16610000
VTOCFUNC DS    A                       VTOC AM FUNCTION                 16620000
ADOFDSCB DS    A                       VTOC AM DSCB ADDRESS             16630000
VTCWRK   DS    A                       VTOC AM WORK                     16640000
VOLUMEID DS    CL6                     VOLUME SERIAL NUMBER             16650000
W#DEVNAM DS    CL8                                                      16660007
W#F0CNT  DS    PL4                                                      16670000
W#F1CNT  DS    PL4                                                      16680000
W#F2CNT  DS    PL4                                                      16690000
W#F3CNT  DS    PL4                                                      16700000
W#F4CNT  DS    PL4                                                      16710000
W#F5CNT  DS    PL4                                                      16720000
W#F6CNT  DS    PL4                                                      16730000
W#F7CNT  DS    PL4                                                      16740006
W#F8CNT  DS    PL4                                                      16750006
W#F9CNT  DS    PL4                                                      16760006
W#FXCNT  DS    PL4                                                      16770000
*                                                                       16780000
W#CURDTE DS    A                                                        16790000
W#JLWK1  DS    A                                                        16800000
W#JLWK2  DS    P'+365'                                                  16810000
W#JLWK13 DS    P'+01'                                                   16820000
W#JLWK12 DS    P'+31'                                                   16830000
W#JLWK11 DS    P'+30'                                                   16840000
W#JLWK10 DS    P'+31'                                                   16850000
W#JLWK09 DS    P'+30'                                                   16860000
W#JLWK08 DS    P'+31'                                                   16870000
W#JLWK07 DS    P'+31'                                                   16880000
W#JLWK06 DS    P'+30'                                                   16890000
W#JLWK05 DS    P'+31'                                                   16900000
W#JLWK04 DS    P'+30'                                                   16910000
W#JLWK03 DS    P'+31'                                                   16920000
W#JLWK02 DS    P'+28'                                                   16930000
W#JLWK01 DS    P'+31'                                                   16940000
W#TIMWRK DS    X'402021204B20204B20204B2020'                            16950000
W#LNCT   DS    PL2'+99'                                                 16960000
W#PGCT   DS    PL2'+0'                                                  16970000
*                                                                       16980000
W#HD1    DS    CL133                                                    16990000
         ORG   W#HD1+1                                                  17000000
W#HD1DTE DS    C'            '                                          17010000
         DS    C' '                                                     17020000
W#HD1TOD DS    C'HH:MM:SS'                                              17030000
         ORG   W#HD1+66-(29/2)                                          17040000
W#HD1TTL DS    C'VTOC Format'                                           17050000
         DS    C                                                        17060000
W#HD1VOL DS    CL6                                                      17070000
         DS    C                                                        17080000
         DS    C'(dddd-mm)'                                             17090000
         ORG   W#HD1+L'W#HD1-8                                          17100000
W#HD1PG  DS    C'Page'                                                  17110000
W#HD1PGC DS    C' 123'                                                  17120000
*                                                                       17130000
W#LINE   DS    CL133                                                    17140000
W#FLG    DS    X                                                        17150000
W#FLGDBG EQU   X'80'                                                    17160000
W#FLGF1  EQU   X'40'                                                    17170000
W#FLGF2  EQU   X'20'                                                    17180000
W#FLGF3  EQU   X'10'                                                    17190000
W#FLGF4  EQU   X'08'                                                    17200000
W#FLGF5  EQU   X'04'                                                    17210000
W#FLGF6  EQU   X'02'                                                    17220000
W#FLGSEL EQU   X'01'                                                    17230000
W#DEVTYP DS    X                                                        17240000
W#UNIT   DS    CL4                                                      17250000
*                                                                       17260000
         DS    0D                                                       17270000
W#OPNLST DS    XL(L'P#OPNLST)                                           17280000
         DS    0D                                                       17290000
W#OTDCB  DS    XL(L'P#OTDCB)                                            17300000
*                                                                       17310000
IOERMSG  DS    C'Permanent I/O error on VTOC on volume '                17320000
IOERSER  DS    CL6                                                      17330000
IOERMSG1 DS    C' CCHHR='                                               17340000
IOERLOCN DS    CL11                                                     17350000
IOERMSGL EQU   *-IOERMSG                                                17360000
*                                                                       17370000
W#DMPRGS DS    16A                                                      17380000
W#DMPOFF DS    A                                                        17390000
W#DMPDUP DS    A                                                        17400000
W#DMPADS DS    A                                                        17410000
W#DMPFLG DS    X                                                        17420000
W#DMPFL1 EQU   X'80'                                                    17430000
W#DMPFLD EQU   X'40'                                                    17440000
*                                                                       17450000
W#FDWD   DS    D                                                        17460000
W#FREGS  DS    16A                                                      17470000
W#FMTBTA DS    A                                                        17480006
W#FMTBTL DS    A                                                        17490006
W#FADDR  DS    A                                                        17500000
W#FBGNOF DS    H                                                        17510000
W#FTEMP  DS    CL9                                                      17520000
W#FFLAG  DS    X                                                        17530000
W#FFLAG1 EQU   X'80'                                                    17540000
*                                                                       17550000
W#DIAGRG DC    16A(0)                                                   17560006
W#DIAGLN DC    CL133' '                                                 17570006
*                                                                       17580006
         DS    0D                                                       17590000
WORKEND  EQU   *                                                        17600000
W#LEN    EQU   *-W#                                                     17610000
*********************************************************************** 17620000
*        Formatting field descriptor layout                           * 17630000
*********************************************************************** 17640000
BLK      DSECT                                                          17650000
BLKFIRST DS    AL2                 Start offset                         17660000
BLKSIZE  DS    AL2                 Block length                         17670000
BLKHDNXT EQU   *                                                        17680000
         ORG   BLK                                                      17690000
*        Common area                                                    17700000
BLKTYPE  DS    X                   Descriptor type                      17710000
BLKCHAR  EQU   1                   Character field                      17720000
BLKHEX   EQU   2                   Hex field                            17730000
BLKCONST EQU   3                   Constant                             17740000
BLKTBL   EQU   4                   Table entry                          17750000
BLKBIT   EQU   5                   Bit entry                            17760006
BLKEND   EQU   255                 End of block                         17770000
BLKBGN   DS    0X                  Common starting point                17780000
*        Character field                                                17790000
BLKOFF   DS    AL1                 Offset into output area              17800000
BLKDISP  DS    AL2                 Field displacement                   17810000
BLKCHRSC DS    AL1                 SCON of length if variable           17820000
BLKCHRLN DS    AL1                 Output length                        17830000
BLKCHRNX EQU   *                                                        17840000
         ORG   BLKBGN                                                   17850000
*        Hex field                                                      17860000
         DS    AL1                 Offset into output area              17870000
         DS    AL2                 Field displacement                   17880000
BLKHEXOF DS    AL1                 Input offset                         17890000
BLKHEXSC DS    AL1                 SCON of length if variable           17900000
BLKHEXLN DS    AL1                 Output length                        17910000
BLKHEXNX EQU   *                                                        17920000
         ORG   BLKBGN                                                   17930000
*        Constant                                                       17940000
         DS    X                   Offset into output area              17950000
BLKDTALN DS    X                   Output length                        17960000
BLKDATA  DS    C                   Constant                             17970000
BLKDTANX EQU   *                                                        17980000
         ORG   BLKBGN                                                   17990000
*        Table field                                                    18000000
BLKTBLOC DS    AL1                 Number of occurances                 18010000
         DS    AL2                 Field displacement                   18020000
BLKTBLA  DS    AL4                 Address of BLKBGN                    18030000
BLKTBLNX EQU   *                                                        18040000
         ORG   BLKBGN                                                   18050006
*        Bit field (use only with single field formatting)              18060006
*        BLKENT BIT,XX,offset for bit,desc,offset=desc offset           18070006
         DS    AL1                 Description offset                   18080006
BLKBITVA DS    X                   Hex value of bit                     18090006
BLKBITOF DS    X                   Offset for bit value                 18100006
BLKBITLN DS    X                   Bit description length               18110006
BLKBITDE DS    C                   Description                          18120006
BLKBITNX EQU   *                                                        18130006
DSCBFMT  CSECT ,                                                        18140000
********************************************************************    18150000
*                                                                  *    18160000
********************************************************************    18170000
F1       BLKBGN OFF=000,LEN=FFF                                         18180000
         BLKENT LABEL,'DS1DSNAM.....',NEWLIN=YES                        18190000
         BLKENT CHAR,.NEXT,2C         000                               18200000
         BLKENT LABEL,'Data set name',OFFSET=70                         18210005
         BLKENT LABEL,'DS1FMTID.....',NEWLIN=YES                        18220000
         BLKENT HEX,.NEXT,02          02C                               18230007
         BLKENT LABEL,'Format identifier',OFFSET=70                     18240005
         BLKENT LABEL,'DS1DSSN......',NEWLIN=YES                        18250000
         BLKENT CHAR,.NEXT,06         02D                               18260000
         BLKENT LABEL,'Data set serial number',OFFSET=70                18270005
         BLKENT LABEL,'DS1VOLSQ.....',NEWLIN=YES                        18280000
         BLKENT HEX,.NEXT,04          033                               18290000
         BLKENT LABEL,'Volume sequence number',OFFSET=70                18300005
         BLKENT LABEL,'DS1CREDT.....',NEWLIN=YES                        18310000
         BLKENT HEX,.NEXT,06          035                               18320000
         BLKENT LABEL,'Creation date',OFFSET=70                         18330005
         BLKENT LABEL,'DS1EXPDT.....',NEWLIN=YES                        18340000
         BLKENT HEX,.NEXT,06          038                               18350000
         BLKENT LABEL,'Expiration date',OFFSET=70                       18360005
         BLKENT LABEL,'DS1NOEPV.....',NEWLIN=YES                        18370000
         BLKENT HEX,.NEXT,02          03B                               18380000
         BLKENT LABEL,'Number of extents on volume',OFFSET=70           18390005
         BLKENT LABEL,'DS1NOBDB.....',NEWLIN=YES                        18400000
         BLKENT HEX,.NEXT,02          03C                               18410000
         BLKENT LABEL,'Number of bytes used in last',OFFSET=70          18420005
         BLKENT LABEL,'DS1FLAG1     ',NEWLIN=YES                        18430006
         BLKENT HEX,.NEXT,02          03D                               18440000
         BLKENT LABEL,'Flag 1',OFFSET=70                                18450006
         BLKENT BIT,80,14,'DS1COMPR',OFFSET=28,NEWLIN=YES               18460006
         BLKENT BIT,40,14,'DS1CPOIT',OFFSET=28,NEWLIN=YES               18470006
         BLKENT BIT,20,14,'DS1EXPBY',OFFSET=28,NEWLIN=YES               18480006
         BLKENT BIT,10,14,'DS1RECAL',OFFSET=28,NEWLIN=YES               18490006
         BLKENT BIT,08,14,'DS1LARGE',OFFSET=28,NEWLIN=YES               18500006
         BLKENT BIT,04,14,'DS4DIRF ',OFFSET=28,NEWLIN=YES               18510006
         BLKENT BIT,02,14,'DS1EATTR_OPT',OFFSET=28,NEWLIN=YES           18520006
         BLKENT BIT,01,14,'DS1EATTR_NO',OFFSET=28,NEWLIN=YES            18530006
         BLKENT LABEL,'DS1SYSCD.....',NEWLIN=YES                        18540000
         BLKENT CHAR,.NEXT,0D         03E                               18550000
         BLKENT LABEL,'System code',OFFSET=70                           18560005
         BLKENT LABEL,'DS1REFD......',NEWLIN=YES                        18570000
         BLKENT HEX,.NEXT,06          04B                               18580000
         BLKENT LABEL,'Date last referenced',OFFSET=70                  18590005
         BLKENT LABEL,'DS1SMSFG.....',NEWLIN=YES                        18600000
         BLKENT HEX,.NEXT,02          04E                               18610000
         BLKENT LABEL,'SMS indicators',OFFSET=70                        18620005
         BLKENT BIT,80,14,'DS1SMSDS',OFFSET=28,NEWLIN=YES               18630006
         BLKENT BIT,40,14,'DS1SMSUC',OFFSET=28,NEWLIN=YES               18640006
         BLKENT BIT,20,14,'DS1REBLK',OFFSET=28,NEWLIN=YES               18650006
         BLKENT BIT,10,14,'DS1CRSDB',OFFSET=28,NEWLIN=YES               18660006
         BLKENT BIT,08,14,'DS1PDSE ',OFFSET=28,NEWLIN=YES               18670006
         BLKENT BIT,04,14,'DS1STRP ',OFFSET=28,NEWLIN=YES               18680006
         BLKENT BIT,02,14,'DS1PDSEX',OFFSET=28,NEWLIN=YES               18690006
         BLKENT BIT,01,14,'DS1DSAE ',OFFSET=28,NEWLIN=YES               18700006
         BLKENT LABEL,'DS1SCXTF.....',NEWLIN=YES                        18710000
         BLKENT HEX,.NEXT,02          04F                               18720000
         BLKENT LABEL,'Secondary flag',OFFSET=70                        18730005
         BLKENT BIT,80,14,'DS1SCAVB',OFFSET=28,NEWLIN=YES               18740006
         BLKENT BIT,40,14,'DS1SCMB ',OFFSET=28,NEWLIN=YES               18750006
         BLKENT BIT,20,14,'DS1SCKB ',OFFSET=28,NEWLIN=YES               18760006
         BLKENT BIT,10,14,'DS1SCUB ',OFFSET=28,NEWLIN=YES               18770006
         BLKENT BIT,08,14,'DS1SCCP1',OFFSET=28,NEWLIN=YES               18780006
         BLKENT BIT,04,14,'DS1SCCP2',OFFSET=28,NEWLIN=YES               18790006
         BLKENT LABEL,'DS1SCXTV.....',NEWLIN=YES                        18800000
         BLKENT HEX,.NEXT,04          050                               18810000
         BLKENT LABEL,'Secondary value',OFFSET=70                       18820005
         BLKENT LABEL,'DS1DSORG.....',NEWLIN=YES                        18830000
         BLKENT HEX,.NEXT,04          052                               18840000
         BLKENT LABEL,'Data set organization',OFFSET=70                 18850005
         BLKENT LABEL,'DS1RECFM.....',NEWLIN=YES                        18860000
         BLKENT HEX,.NEXT,02          054                               18870000
         BLKENT LABEL,'Record format',OFFSET=70                         18880005
         BLKENT LABEL,'DS1OPTCD.....',NEWLIN=YES                        18890000
         BLKENT HEX,.NEXT,02          055                               18900000
         BLKENT LABEL,'Option code',OFFSET=70                           18910005
         BLKENT LABEL,'DS1BLKL......',NEWLIN=YES                        18920000
         BLKENT HEX,.NEXT,04          056                               18930000
         BLKENT LABEL,'Block length',OFFSET=70                          18940005
         BLKENT LABEL,'DS1LRECL.....',NEWLIN=YES                        18950000
         BLKENT HEX,.NEXT,04          058                               18960000
         BLKENT LABEL,'Record length',OFFSET=70                         18970005
         BLKENT LABEL,'DS1KEYL......',NEWLIN=YES                        18980000
         BLKENT HEX,.NEXT,02          05A                               18990000
         BLKENT LABEL,'Key length',OFFSET=70                            19000005
         BLKENT LABEL,'DS1RKP.......',NEWLIN=YES                        19010000
         BLKENT HEX,.NEXT,04          05B                               19020000
         BLKENT LABEL,'Relative key position',OFFSET=70                 19030005
         BLKENT LABEL,'DS1DSIND.....',NEWLIN=YES                        19040000
         BLKENT HEX,.NEXT,02          05D                               19050000
         BLKENT LABEL,'Data set indicators',OFFSET=70                   19060005
         BLKENT BIT,80,14,'DS1IND80',OFFSET=28,NEWLIN=YES               19070006
         BLKENT BIT,40,14,'DS1RACDF',OFFSET=28,NEWLIN=YES               19080006
         BLKENT BIT,20,14,'DS1IND20',OFFSET=28,NEWLIN=YES               19090006
         BLKENT BIT,10,14,'DS1SECTY',OFFSET=28,NEWLIN=YES               19100006
         BLKENT BIT,08,14,'DS1IND08',OFFSET=28,NEWLIN=YES               19110006
         BLKENT BIT,04,14,'DS1WRSEC',OFFSET=28,NEWLIN=YES               19120006
         BLKENT BIT,02,14,'DS1DSCHA',OFFSET=28,NEWLIN=YES               19130006
         BLKENT BIT,01,14,'DS1CHKPT',OFFSET=28,NEWLIN=YES               19140006
         BLKENT LABEL,'DS1SCALO.....',NEWLIN=YES                        19150000
         BLKENT HEX,.NEXT,08          05E                               19160000
         BLKENT LABEL,'Secondary allocation',OFFSET=70                  19170005
         BLKENT LABEL,'DS1LSTAR.....',NEWLIN=YES                        19180000
         BLKENT HEX,.NEXT,06          062                               19190000
         BLKENT LABEL,'Last used track and block on track',OFFSET=70    19200005
         BLKENT LABEL,'DS1TRBAL.....',NEWLIN=YES                        19210000
         BLKENT HEX,.NEXT,04          065                               19220000
         BLKENT LABEL,'Bytes remaining on last track used',OFFSET=70    19230005
         BLKENT LABEL,'Reserved.....',NEWLIN=YES                        19240000
         BLKENT HEX,.NEXT,04          067                               19250000
         BLKENT LABEL,'Reserved',OFFSET=70                              19260005
         BLKENT LABEL,'DS1EXT1......',NEWLIN=YES                        19270000
         BLKENT HEX,.NEXT,02                                            19280006
         BLKENT HEX,.NEXT,02                                            19290006
         BLKENT HEX,.NEXT,04                                            19300006
         BLKENT HEX,.NEXT,04                                            19310006
         BLKENT HEX,.NEXT,04                                            19320006
         BLKENT HEX,.NEXT,04                                            19330006
         BLKENT LABEL,'First extent description',OFFSET=70              19340005
         BLKENT LABEL,'DS1EXT2......',NEWLIN=YES                        19350000
         BLKENT HEX,.NEXT,02                                            19360006
         BLKENT HEX,.NEXT,02                                            19370006
         BLKENT HEX,.NEXT,04                                            19380006
         BLKENT HEX,.NEXT,04                                            19390006
         BLKENT HEX,.NEXT,04                                            19400006
         BLKENT HEX,.NEXT,04                                            19410006
         BLKENT LABEL,'Second extent description',OFFSET=70             19420005
         BLKENT LABEL,'DS1EXT3......',NEWLIN=YES                        19430000
         BLKENT HEX,.NEXT,02                                            19440006
         BLKENT HEX,.NEXT,02                                            19450006
         BLKENT HEX,.NEXT,04                                            19460006
         BLKENT HEX,.NEXT,04                                            19470006
         BLKENT HEX,.NEXT,04                                            19480006
         BLKENT HEX,.NEXT,04                                            19490006
         BLKENT LABEL,'Third extent description',OFFSET=70              19500005
         BLKENT LABEL,'DS1PTRDS.....',NEWLIN=YES                        19510000
         BLKENT HEX,.NEXT,04                                            19520006
         BLKENT HEX,.NEXT,04                                            19530006
         BLKENT HEX,.NEXT,02                                            19540006
         BLKENT LABEL,'Pointer to Format 2 or 3 DSCB',OFFSET=70         19550006
         BLKEND ,                                                       19560000
         DC    (((((*-DSCBFMT)/256)+1)*256)-(*-DSCBFMT))X'00'           19570000
********************************************************************    19580000
*                                                                  *    19590000
********************************************************************    19600000
F2       BLKBGN OFF=000,LEN=FFF                                         19610000
         BLKENT LABEL,'Key..........',NEWLIN=YES                        19620000
         BLKENT HEX,.NEXT,02          000                               19630000
         BLKENT LABEL,'Key identifier',OFFSET=70                        19640005
         BLKENT LABEL,'DS22MIND.....',NEWLIN=YES                        19650000
         BLKENT HEX,.NEXT,0E          001                               19660000
         BLKENT LABEL,'Address of 2nd level master index',OFFSET=70     19670005
         BLKENT LABEL,'DS2L2MEN.....',NEWLIN=YES                        19680000
         BLKENT HEX,.NEXT,0A          008                               19690000
         BLKENT LABEL,'Last 2nd level master index entry',OFFSET=70     19700005
         BLKENT LABEL,'DS23MIND.....',NEWLIN=YES                        19710000
         BLKENT HEX,.NEXT,0E          00D                               19720000
         BLKENT LABEL,'Address of 3rd level master index',OFFSET=70     19730005
         BLKENT LABEL,'DS2L3MIN.....',NEWLIN=YES                        19740000
         BLKENT HEX,.NEXT,0A          014                               19750000
         BLKENT LABEL,'Last 3rd level master index entry',OFFSET=70     19760005
         BLKENT LABEL,'Reserved.....',NEWLIN=YES                        19770000
         BLKENT HEX,.NEXT,16          019                               19780000
         BLKENT LABEL,'Reserved',OFFSET=70                              19790005
         BLKENT LABEL,'DS2LPDT......',NEWLIN=YES                        19800000
         BLKENT HEX,.NEXT,10          024                               19810000
         BLKENT LABEL,'Last prime track on last prime cyl',OFFSET=70    19820005
         BLKENT LABEL,'DS2FMTID.....',NEWLIN=YES                        19830000
         BLKENT HEX,.NEXT,02          02C                               19840007
         BLKENT LABEL,'Format identifier',OFFSET=70                     19850005
         BLKENT LABEL,'DS2NOLEV.....',NEWLIN=YES                        19860000
         BLKENT HEX,.NEXT,02          02D                               19870000
         BLKENT LABEL,'Number of index levels',OFFSET=70                19880005
         BLKENT LABEL,'DS2DVIND.....',NEWLIN=YES                        19890000
         BLKENT HEX,.NEXT,02          02E                               19900000
         BLKENT LABEL,'High level index development',OFFSET=70          19910005
         BLKENT LABEL,'DS21RCYL.....',NEWLIN=YES                        19920000
         BLKENT HEX,.NEXT,06          02F                               19930000
         BLKENT LABEL,'First data record in cylinder',OFFSET=70         19940005
         BLKENT LABEL,'DS2LTCYL.....',NEWLIN=YES                        19950000
         BLKENT HEX,.NEXT,04          032                               19960000
         BLKENT LABEL,'Last data track in cylinder',OFFSET=70           19970005
         BLKENT LABEL,'DS2CYLOV.....',NEWLIN=YES                        19980000
         BLKENT HEX,.NEXT,02          034                               19990000
         BLKENT LABEL,'Number of tracks for cylinder',OFFSET=70         20000005
         BLKENT LABEL,'DS2HIRIN.....',NEWLIN=YES                        20010000
         BLKENT HEX,.NEXT,02          035                               20020000
         BLKENT LABEL,'Highest R on high-level index track',OFFSET=70   20030007
         BLKENT LABEL,'DS2HIRPR.....',NEWLIN=YES                        20040000
         BLKENT HEX,.NEXT,02          036                               20050000
         BLKENT LABEL,'Highest R on prime data track',OFFSET=70         20060005
         BLKENT LABEL,'DS2HIROV.....',NEWLIN=YES                        20070000
         BLKENT HEX,.NEXT,02          037                               20080000
         BLKENT LABEL,'Highest R on overflow data track',OFFSET=70      20090005
         BLKENT LABEL,'DS2RSHTR.....',NEWLIN=YES                        20100000
         BLKENT HEX,.NEXT,02          038                               20110000
         BLKENT LABEL,'R of last data record on shared',OFFSET=70       20120005
         BLKENT LABEL,'DS2HIRTI.....',NEWLIN=YES                        20130000
         BLKENT HEX,.NEXT,02          039                               20140000
         BLKENT LABEL,'Highest R on unshared track of',OFFSET=70        20150005
         BLKENT LABEL,'DS2HIIOV.....',NEWLIN=YES                        20160000
         BLKENT HEX,.NEXT,02          03A                               20170000
         BLKENT LABEL,'Highest R for independent overflow',OFFSET=70    20180005
         BLKENT LABEL,'DS2TAGDT.....',NEWLIN=YES                        20190000
         BLKENT HEX,.NEXT,04          03B                               20200000
         BLKENT LABEL,'Tag deletion count',OFFSET=70                    20210005
         BLKENT LABEL,'DS2RORG3.....',NEWLIN=YES                        20220000
         BLKENT HEX,.NEXT,06          03D                               20230000
         BLKENT LABEL,'Non-first overflow reference count',OFFSET=70    20240005
         BLKENT LABEL,'DS2NOBYT.....',NEWLIN=YES                        20250000
         BLKENT HEX,.NEXT,04          040                               20260000
         BLKENT LABEL,'Number of bytes for highest-level',OFFSET=70     20270005
         BLKENT LABEL,'DS2NOTRK.....',NEWLIN=YES                        20280000
         BLKENT HEX,.NEXT,02          042                               20290000
         BLKENT LABEL,'Number of tracks for highest-level',OFFSET=70    20300005
         BLKENT LABEL,'DS2PRCTR.....',NEWLIN=YES                        20310000
         BLKENT HEX,.NEXT,08          043                               20320000
         BLKENT LABEL,'Prime record count',OFFSET=70                    20330005
         BLKENT LABEL,'DS2STIND.....',NEWLIN=YES                        20340000
         BLKENT HEX,.NEXT,02          047                               20350000
         BLKENT LABEL,'Status indicators',OFFSET=70                     20360005
         BLKENT LABEL,'DS2CYLAD.....',NEWLIN=YES                        20370000
         BLKENT HEX,.NEXT,0E          048                               20380000
         BLKENT LABEL,'Address of cylinder index',OFFSET=70             20390005
         BLKENT LABEL,'DS2ADLIN.....',NEWLIN=YES                        20400000
         BLKENT HEX,.NEXT,0E          04F                               20410000
         BLKENT LABEL,'Address of lowest level master index',OFFSET=70  20420005
         BLKENT LABEL,'DS2ADHIN.....',NEWLIN=YES                        20430000
         BLKENT HEX,.NEXT,0E          056                               20440000
         BLKENT LABEL,'Address of highest level master',OFFSET=70       20450005
         BLKENT LABEL,'DS2LPRAD.....',NEWLIN=YES                        20460000
         BLKENT HEX,.NEXT,10          05D                               20470000
         BLKENT LABEL,'Last prime data record address',OFFSET=70        20480005
         BLKENT LABEL,'DS2LTRAD.....',NEWLIN=YES                        20490000
         BLKENT HEX,.NEXT,0A          065                               20500000
         BLKENT LABEL,'Last track index entry address',OFFSET=70        20510005
         BLKENT LABEL,'DS2LCYAD.....',NEWLIN=YES                        20520000
         BLKENT HEX,.NEXT,0A          06A                               20530000
         BLKENT LABEL,'Last cylinder index entry address',OFFSET=70     20540005
         BLKENT LABEL,'DS2LMSAD.....',NEWLIN=YES                        20550000
         BLKENT HEX,.NEXT,0A          06F                               20560000
         BLKENT LABEL,'Last master index entry address',OFFSET=70       20570005
         BLKENT LABEL,'DS2LOVAD.....',NEWLIN=YES                        20580000
         BLKENT HEX,.NEXT,10          074                               20590000
         BLKENT LABEL,'Last independent overflow record',OFFSET=70      20600005
         BLKENT LABEL,'DS2BYOVL.....',NEWLIN=YES                        20610000
         BLKENT HEX,.NEXT,04          07C                               20620000
         BLKENT LABEL,'Bytes remaining on overflow track',OFFSET=70     20630005
         BLKENT LABEL,'DS2RORG2.....',NEWLIN=YES                        20640000
         BLKENT HEX,.NEXT,04          07E                               20650000
         BLKENT LABEL,'Tracks remaining in independent',OFFSET=70       20660005
         BLKENT LABEL,'DS2OVRCT.....',NEWLIN=YES                        20670000
         BLKENT HEX,.NEXT,04          080                               20680000
         BLKENT LABEL,'Overflow record count',OFFSET=70                 20690005
         BLKENT LABEL,'DS2RORG1.....',NEWLIN=YES                        20700000
         BLKENT HEX,.NEXT,04          082                               20710000
         BLKENT LABEL,'Cylinder overflow area count',OFFSET=70          20720005
         BLKENT LABEL,'DS2NIRT......',NEWLIN=YES                        20730000
         BLKENT HEX,.NEXT,06          084                               20740000
         BLKENT LABEL,'Dummy track index entry address',OFFSET=70       20750005
         BLKENT LABEL,'DS2PTRDS.....',NEWLIN=YES                        20760000
         BLKENT HEX,.NEXT,04                                            20770006
         BLKENT HEX,.NEXT,04                                            20780006
         BLKENT HEX,.NEXT,02                                            20790006
         BLKENT LABEL,'Pointer to Format 3 DSCB',OFFSET=70              20800006
         BLKEND ,                                                       20810000
         DC    (((((*-DSCBFMT)/256)+1)*256)-(*-DSCBFMT))X'00'           20820000
********************************************************************    20830000
*                                                                  *    20840000
********************************************************************    20850000
F3       BLKBGN OFF=000,LEN=FFF                                         20860000
         BLKENT LABEL,'Key..........',NEWLIN=YES                        20870000
         BLKENT HEX,.NEXT,08          000                               20880000
         BLKENT LABEL,'Key identifier',OFFSET=70                        20890005
         BLKENT LABEL,'DS3EXT1......',NEWLIN=YES                        20900000
         BLKENT HEX,.NEXT,02                                            20910008
         BLKENT HEX,.NEXT,02                                            20920008
         BLKENT HEX,.NEXT,04                                            20930008
         BLKENT HEX,.NEXT,04                                            20940008
         BLKENT HEX,.NEXT,04                                            20950008
         BLKENT HEX,.NEXT,04                                            20960008
         BLKENT LABEL,'Extent 1',OFFSET=70                              20970005
         BLKENT LABEL,'DS3EXT2......',NEWLIN=YES                        20980000
         BLKENT HEX,.NEXT,02                                            20990008
         BLKENT HEX,.NEXT,02                                            21000008
         BLKENT HEX,.NEXT,04                                            21010008
         BLKENT HEX,.NEXT,04                                            21020008
         BLKENT HEX,.NEXT,04                                            21030008
         BLKENT HEX,.NEXT,04                                            21040008
         BLKENT LABEL,'Extent 2',OFFSET=70                              21050005
         BLKENT LABEL,'DS3EXT3......',NEWLIN=YES                        21060000
         BLKENT HEX,.NEXT,02                                            21070008
         BLKENT HEX,.NEXT,02                                            21080008
         BLKENT HEX,.NEXT,04                                            21090008
         BLKENT HEX,.NEXT,04                                            21100008
         BLKENT HEX,.NEXT,04                                            21110008
         BLKENT HEX,.NEXT,04                                            21120008
         BLKENT LABEL,'Extent 3',OFFSET=70                              21130005
         BLKENT LABEL,'DS3EXT4......',NEWLIN=YES                        21140000
         BLKENT HEX,.NEXT,02                                            21150008
         BLKENT HEX,.NEXT,02                                            21160008
         BLKENT HEX,.NEXT,04                                            21170008
         BLKENT HEX,.NEXT,04                                            21180008
         BLKENT HEX,.NEXT,04                                            21190008
         BLKENT HEX,.NEXT,04                                            21200008
         BLKENT LABEL,'Extent 4',OFFSET=70                              21210005
         BLKENT LABEL,'DS3FMTID.....',NEWLIN=YES                        21220000
         BLKENT HEX,.NEXT,02          02C                               21230007
         BLKENT LABEL,'Format identifier',OFFSET=70                     21240005
         BLKENT LABEL,'DS3EXT5......',NEWLIN=YES                        21250000
         BLKENT HEX,.NEXT,02                                            21260008
         BLKENT HEX,.NEXT,02                                            21270008
         BLKENT HEX,.NEXT,04                                            21280008
         BLKENT HEX,.NEXT,04                                            21290008
         BLKENT HEX,.NEXT,04                                            21300008
         BLKENT HEX,.NEXT,04                                            21310008
         BLKENT LABEL,'Extent 5',OFFSET=70                              21320005
         BLKENT LABEL,'DS3EXT6......',NEWLIN=YES                        21330000
         BLKENT HEX,.NEXT,02                                            21340008
         BLKENT HEX,.NEXT,02                                            21350008
         BLKENT HEX,.NEXT,04                                            21360008
         BLKENT HEX,.NEXT,04                                            21370008
         BLKENT HEX,.NEXT,04                                            21380008
         BLKENT HEX,.NEXT,04                                            21390008
         BLKENT LABEL,'Extent 6',OFFSET=70                              21400005
         BLKENT LABEL,'DS3EXT7......',NEWLIN=YES                        21410000
         BLKENT HEX,.NEXT,02                                            21420008
         BLKENT HEX,.NEXT,02                                            21430008
         BLKENT HEX,.NEXT,04                                            21440008
         BLKENT HEX,.NEXT,04                                            21450008
         BLKENT HEX,.NEXT,04                                            21460008
         BLKENT HEX,.NEXT,04                                            21470008
         BLKENT LABEL,'Extent 7',OFFSET=70                              21480005
         BLKENT LABEL,'DS3EXT8......',NEWLIN=YES                        21490000
         BLKENT HEX,.NEXT,02                                            21500008
         BLKENT HEX,.NEXT,02                                            21510008
         BLKENT HEX,.NEXT,04                                            21520008
         BLKENT HEX,.NEXT,04                                            21530008
         BLKENT HEX,.NEXT,04                                            21540008
         BLKENT HEX,.NEXT,04                                            21550008
         BLKENT LABEL,'Extent 8',OFFSET=70                              21560005
         BLKENT LABEL,'DS3EXT9......',NEWLIN=YES                        21570000
         BLKENT HEX,.NEXT,02                                            21580008
         BLKENT HEX,.NEXT,02                                            21590008
         BLKENT HEX,.NEXT,04                                            21600008
         BLKENT HEX,.NEXT,04                                            21610008
         BLKENT HEX,.NEXT,04                                            21620008
         BLKENT HEX,.NEXT,04                                            21630008
         BLKENT LABEL,'Extent 9',OFFSET=70                              21640005
         BLKENT LABEL,'DS3EXT10.....',NEWLIN=YES                        21650000
         BLKENT HEX,.NEXT,02                                            21660008
         BLKENT HEX,.NEXT,02                                            21670008
         BLKENT HEX,.NEXT,04                                            21680008
         BLKENT HEX,.NEXT,04                                            21690008
         BLKENT HEX,.NEXT,04                                            21700008
         BLKENT HEX,.NEXT,04                                            21710008
         BLKENT LABEL,'Extent 10',OFFSET=70                             21720005
         BLKENT LABEL,'DS3EXT11.....',NEWLIN=YES                        21730000
         BLKENT HEX,.NEXT,02                                            21740008
         BLKENT HEX,.NEXT,02                                            21750008
         BLKENT HEX,.NEXT,04                                            21760008
         BLKENT HEX,.NEXT,04                                            21770008
         BLKENT HEX,.NEXT,04                                            21780008
         BLKENT HEX,.NEXT,04                                            21790008
         BLKENT LABEL,'Extent 11',OFFSET=70                             21800005
         BLKENT LABEL,'DS3EXT12.....',NEWLIN=YES                        21810000
         BLKENT HEX,.NEXT,02                                            21820008
         BLKENT HEX,.NEXT,02                                            21830008
         BLKENT HEX,.NEXT,04                                            21840008
         BLKENT HEX,.NEXT,04                                            21850008
         BLKENT HEX,.NEXT,04                                            21860008
         BLKENT HEX,.NEXT,04                                            21870008
         BLKENT LABEL,'Extent 12',OFFSET=70                             21880005
         BLKENT LABEL,'DS3EXT13.....',NEWLIN=YES                        21890000
         BLKENT HEX,.NEXT,02                                            21900008
         BLKENT HEX,.NEXT,02                                            21910008
         BLKENT HEX,.NEXT,04                                            21920008
         BLKENT HEX,.NEXT,04                                            21930008
         BLKENT HEX,.NEXT,04                                            21940008
         BLKENT HEX,.NEXT,04                                            21950008
         BLKENT LABEL,'Extent 13',OFFSET=70                             21960005
         BLKENT LABEL,'DS3PTRDS.....',NEWLIN=YES                        21970000
         BLKENT HEX,.NEXT,04                                            21980006
         BLKENT HEX,.NEXT,04                                            21990006
         BLKENT HEX,.NEXT,02                                            22000006
         BLKENT LABEL,'Reserved',OFFSET=70                              22010005
         BLKEND ,                                                       22020000
         DC    (((((*-DSCBFMT)/256)+1)*256)-(*-DSCBFMT))X'00'           22030000
********************************************************************    22040000
*                                                                  *    22050000
********************************************************************    22060000
F4       BLKBGN OFF=000,LEN=FFF                                         22070000
         BLKENT LABEL,'             ',NEWLIN=YES                        22080000
         BLKENT HEX,.NEXT,08          000                               22090000
         BLKENT HEX,.NEXT,08                                            22100000
         BLKENT HEX,.NEXT,08                                            22110000
         BLKENT HEX,.NEXT,08                                            22120000
         BLKENT LABEL,'Format 4 key',OFFSET=70                          22130005
         BLKENT LABEL,'             ',NEWLIN=YES                        22140000
         BLKENT HEX,.NEXT,08                                            22150000
         BLKENT HEX,.NEXT,08                                            22160000
         BLKENT HEX,.NEXT,08                                            22170000
         BLKENT HEX,.NEXT,08                                            22180000
         BLKENT LABEL,'             ',NEWLIN=YES                        22190000
         BLKENT HEX,.NEXT,08                                            22200000
         BLKENT HEX,.NEXT,08                                            22210000
         BLKENT HEX,.NEXT,08                                            22220000
         BLKENT LABEL,'DS4IDFMT.....',NEWLIN=YES                        22230000
         BLKENT HEX,.NEXT,02          02C                               22240007
         BLKENT LABEL,'Format identifier',OFFSET=70                     22250005
         BLKENT LABEL,'DS4HPCHR.....',NEWLIN=YES                        22260000
         BLKENT HEX,.NEXT,04          02D                               22270001
         BLKENT HEX,.NEXT,04                                            22280001
         BLKENT HEX,.NEXT,02                                            22290001
         BLKENT LABEL,'Highest addr Format 1 DSCB',OFFSET=70            22300005
         BLKENT LABEL,'DS4DSREC.....',NEWLIN=YES                        22310000
         BLKENT HEX,.NEXT,04          032                               22320000
         BLKENT LABEL,'Num available DSCBs',OFFSET=70                   22330005
         BLKENT LABEL,'DS4HCCHH.....',NEWLIN=YES                        22340000
         BLKENT HEX,.NEXT,04          034                               22350006
         BLKENT HEX,.NEXT,04                                            22360006
         BLKENT LABEL,'CCHH next alternate track',OFFSET=70             22370005
         BLKENT LABEL,'DS4NOATK.....',NEWLIN=YES                        22380000
         BLKENT HEX,.NEXT,04          038                               22390000
         BLKENT LABEL,'Remaining alternate tracks',OFFSET=70            22400007
         BLKENT LABEL,'DS4VTOCI.....',NEWLIN=YES                        22410000
         BLKENT HEX,.NEXT,02          03A                               22420000
         BLKENT LABEL,'VTOC indicators',OFFSET=70                       22430005
         BLKENT BIT,80,14,'DS4DOSBT',OFFSET=28,NEWLIN=YES               22440006
         BLKENT BIT,40,14,'DS4DVTOC',OFFSET=28,NEWLIN=YES               22450006
         BLKENT BIT,20,14,'DS4EFVLD',OFFSET=28,NEWLIN=YES               22460006
         BLKENT BIT,10,14,'DS4DSTKP',OFFSET=28,NEWLIN=YES               22470006
         BLKENT BIT,08,14,'DS4DOCVT',OFFSET=28,NEWLIN=YES               22480006
         BLKENT BIT,04,14,'DS4DIRF ',OFFSET=28,NEWLIN=YES               22490006
         BLKENT BIT,02,14,'DS4DICVT',OFFSET=28,NEWLIN=YES               22500006
         BLKENT BIT,01,14,'DS4IVTOC',OFFSET=28,NEWLIN=YES               22510006
         BLKENT LABEL,'DS4NOEXT.....',NEWLIN=YES                        22520000
         BLKENT HEX,.NEXT,02          03B                               22530000
         BLKENT LABEL,'Num extents in VTOC',OFFSET=70                   22540005
         BLKENT LABEL,'DS4SMSFG ....',NEWLIN=YES                        22550006
         BLKENT HEX,.NEXT,02          03C                               22560006
         BLKENT LABEL,'SMS indicators',OFFSET=70                        22570006
         BLKENT BIT,C0,14,'DS4SMS  ',OFFSET=28,NEWLIN=YES               22580006
         BLKENT LABEL,'DS4DEVAC ....',NEWLIN=YES                        22590006
         BLKENT HEX,.NEXT,02          03C                               22600006
         BLKENT LABEL,'Alternate cylinders',OFFSET=70                   22610006
         BLKENT LABEL,'DS4DEVCY.....',NEWLIN=YES                        22620000
         BLKENT HEX,.NEXT,04          03E                               22630000
         BLKENT LABEL,'Number cylinder on device',OFFSET=70             22640007
         BLKENT LABEL,'DS4DEVTR.....',NEWLIN=YES                        22650000
         BLKENT HEX,.NEXT,04          040                               22660000
         BLKENT LABEL,'Num tracks per cylinder',OFFSET=70               22670005
         BLKENT LABEL,'DS4DEVTK.....',NEWLIN=YES                        22680000
         BLKENT HEX,.NEXT,04          042                               22690000
         BLKENT LABEL,'Device track length',OFFSET=70                   22700005
         BLKENT LABEL,'DS4DEVI......',NEWLIN=YES                        22710000
         BLKENT HEX,.NEXT,02          044                               22720000
         BLKENT LABEL,'Non-last key rec ohead',OFFSET=70                22730005
         BLKENT LABEL,'DS4DEVL......',NEWLIN=YES                        22740000
         BLKENT HEX,.NEXT,02          045                               22750000
         BLKENT LABEL,'Last keyed rec overhead',OFFSET=70               22760005
         BLKENT LABEL,'DS4DEVK......',NEWLIN=YES                        22770000
         BLKENT HEX,.NEXT,02          046                               22780000
         BLKENT LABEL,'Non-keyed rec overhead',OFFSET=70                22790005
         BLKENT LABEL,'DS4DEVFG.....',NEWLIN=YES                        22800000
         BLKENT HEX,.NEXT,02          047                               22810000
         BLKENT LABEL,'Flag byte',OFFSET=70                             22820005
         BLKENT BIT,40,14,'DS4AMBJ ',OFFSET=28,NEWLIN=YES               22830006
         BLKENT BIT,20,14,'DS4DSF  ',OFFSET=28,NEWLIN=YES               22840006
         BLKENT BIT,10,14,'DS4DEVAV',OFFSET=28,NEWLIN=YES               22850006
         BLKENT LABEL,'DS4DEVTL.....',NEWLIN=YES                        22860000
         BLKENT HEX,.NEXT,04          048                               22870000
         BLKENT LABEL,'Device tolerance',OFFSET=70                      22880005
         BLKENT LABEL,'DS4DEVDT.....',NEWLIN=YES                        22890000
         BLKENT HEX,.NEXT,02          04A                               22900000
         BLKENT LABEL,'DSCBs per track',OFFSET=70                       22910005
         BLKENT LABEL,'DS4DEVDB.....',NEWLIN=YES                        22920000
         BLKENT HEX,.NEXT,02          04B                               22930000
         BLKENT LABEL,'Dir blocks/track',OFFSET=70                      22940005
         BLKENT LABEL,'DS4AMTIM.....',NEWLIN=YES                        22950000
         BLKENT HEX,.NEXT,08          04C                               22960001
         BLKENT HEX,.NEXT,08                                            22970001
         BLKENT LABEL,'VSAM time stamp',OFFSET=70                       22980005
         BLKENT LABEL,'DS4VSIND.....',NEWLIN=YES                        22990000
         BLKENT HEX,.NEXT,02          054                               23000000
         BLKENT LABEL,'VSAM indicators',OFFSET=70                       23010005
         BLKENT BIT,80,14,'VSAM CAT',OFFSET=28,NEWLIN=YES               23020006
         BLKENT BIT,40,14,'VSAM DB ',OFFSET=28,NEWLIN=YES               23030006
         BLKENT BIT,20,14,'DS4VVDSA',OFFSET=28,NEWLIN=YES               23040006
         BLKENT BIT,10,14,'DS4VVDSR',OFFSET=28,NEWLIN=YES               23050006
         BLKENT LABEL,'DS4VSCRA.....',NEWLIN=YES                        23060000
         BLKENT HEX,.NEXT,04          055                               23070000
         BLKENT LABEL,'Track address of CRA',OFFSET=70                  23080005
         BLKENT LABEL,'DS4R2TIM.....',NEWLIN=YES                        23090000
         BLKENT HEX,.NEXT,08          057                               23100001
         BLKENT HEX,.NEXT,08                                            23110001
         BLKENT LABEL,'VSAM volume/catalog match',OFFSET=70             23120005
         BLKENT LABEL,'             ',NEWLIN=YES                        23130000
         BLKENT HEX,.NEXT,0A          05F                               23140000
         BLKENT LABEL,'Reserved',OFFSET=70                              23150005
         BLKENT LABEL,'DS4F6PTR.....',NEWLIN=YES                        23160000
         BLKENT HEX,.NEXT,04          064                               23170001
         BLKENT HEX,.NEXT,04                                            23180001
         BLKENT HEX,.NEXT,02                                            23190001
         BLKENT LABEL,'First Format 6 DSCB',OFFSET=70                   23200005
         BLKENT LABEL,'DS4VTOCE.....',NEWLIN=YES                        23210000
         BLKENT HEX,.NEXT,02          069                               23220001
         BLKENT HEX,.NEXT,02                                            23230001
         BLKENT HEX,.NEXT,04                                            23240001
         BLKENT HEX,.NEXT,04                                            23250001
         BLKENT HEX,.NEXT,04                                            23260001
         BLKENT HEX,.NEXT,04                                            23270001
         BLKENT LABEL,'VTOC extent description',OFFSET=70               23280005
         BLKENT LABEL,'             ',NEWLIN=YES                        23290001
         BLKENT HEX,.NEXT,08          073                               23300002
         BLKENT HEX,.NEXT,08                                            23310002
         BLKENT HEX,.NEXT,04                                            23320006
         BLKENT LABEL,'Reserved',OFFSET=70                              23330005
         BLKENT LABEL,'DS4EFLVL.....',NEWLIN=YES                        23340006
         BLKENT HEX,.NEXT,02                                            23350006
         BLKENT LABEL,'Extended free space management',OFFSET=70        23360006
         BLKENT LABEL,'DS4EFPTR.....',NEWLIN=YES                        23370006
         BLKENT HEX,.NEXT,04                                            23380006
         BLKENT HEX,.NEXT,04                                            23390006
         BLKENT HEX,.NEXT,02                                            23400006
         BLKENT LABEL,'Pointer to extended free space',OFFSET=70        23410006
         BLKENT LABEL,'DS4MCU.......',NEWLIN=YES                        23420006
         BLKENT HEX,.NEXT,02                                            23430006
         BLKENT LABEL,'Minimum allocation size',OFFSET=70               23440006
         BLKENT LABEL,'DS4DCYL......',NEWLIN=YES                        23450006
         BLKENT HEX,.NEXT,08                                            23460006
         BLKENT LABEL,'Number of logical cylinders',OFFSET=70           23470006
         BLKENT LABEL,'DS4LCYL......',NEWLIN=YES                        23480006
         BLKENT HEX,.NEXT,04                                            23490006
         BLKENT LABEL,'First cylinder managed address',OFFSET=70        23500006
         BLKENT LABEL,'DS4DEVF2.....',NEWLIN=YES                        23510006
         BLKENT HEX,.NEXT,04                                            23520006
         BLKENT LABEL,'Device Flags Byte 2',OFFSET=70                   23530006
         BLKENT BIT,80,14,'DS4CYLMG',OFFSET=28,NEWLIN=YES               23540006
         BLKENT BIT,40,14,'DS4EADSCB',OFFSET=28,NEWLIN=YES              23550006
         BLKEND ,                                                       23560000
         DC    (((((*-DSCBFMT)/256)+1)*256)-(*-DSCBFMT))X'00'           23570000
********************************************************************    23580000
*                                                                  *    23590000
********************************************************************    23600000
F5       BLKBGN OFF=000,LEN=FFF                                         23610000
         BLKENT LABEL,'DS5KEYID.....',NEWLIN=YES                        23620000
         BLKENT HEX,.NEXT,08          000                               23630000
         BLKENT LABEL,'Key identifier',OFFSET=70                        23640005
         BLKENT LABEL,'DS5AVEXT.....',NEWLIN=YES                        23650000
         BLKENT HEX,.NEXT,04          004                               23660002
         BLKENT HEX,.NEXT,04                                            23670002
         BLKENT HEX,.NEXT,02                                            23680002
         BLKENT LABEL,'Available extent 1',OFFSET=70                    23690005
         BLKENT LABEL,'DS5EXT2......',NEWLIN=YES                        23700000
         BLKENT HEX,.NEXT,04          009                               23710002
         BLKENT HEX,.NEXT,04                                            23720002
         BLKENT HEX,.NEXT,02                                            23730002
         BLKENT LABEL,'Available extent 2',OFFSET=70                    23740005
         BLKENT LABEL,'DS5EXT3......',NEWLIN=YES                        23750000
         BLKENT HEX,.NEXT,04                                            23760002
         BLKENT HEX,.NEXT,04                                            23770002
         BLKENT HEX,.NEXT,02                                            23780002
         BLKENT LABEL,'Available extent 3',OFFSET=70                    23790005
         BLKENT LABEL,'DS5EXT4......',NEWLIN=YES                        23800000
         BLKENT HEX,.NEXT,04                                            23810002
         BLKENT HEX,.NEXT,04                                            23820002
         BLKENT HEX,.NEXT,02                                            23830002
         BLKENT LABEL,'Available extent 4',OFFSET=70                    23840005
         BLKENT LABEL,'DS5EXT5......',NEWLIN=YES                        23850000
         BLKENT HEX,.NEXT,04                                            23860002
         BLKENT HEX,.NEXT,04                                            23870002
         BLKENT HEX,.NEXT,02                                            23880002
         BLKENT LABEL,'Available extent 5',OFFSET=70                    23890005
         BLKENT LABEL,'DS5EXT6......',NEWLIN=YES                        23900000
         BLKENT HEX,.NEXT,04                                            23910002
         BLKENT HEX,.NEXT,04                                            23920002
         BLKENT HEX,.NEXT,02                                            23930002
         BLKENT LABEL,'Available extent 6',OFFSET=70                    23940005
         BLKENT LABEL,'DS5EXT7......',NEWLIN=YES                        23950000
         BLKENT HEX,.NEXT,04                                            23960002
         BLKENT HEX,.NEXT,04                                            23970002
         BLKENT HEX,.NEXT,02                                            23980002
         BLKENT LABEL,'Available extent 7',OFFSET=70                    23990005
         BLKENT LABEL,'DS5EXT8......',NEWLIN=YES                        24000000
         BLKENT HEX,.NEXT,04                                            24010002
         BLKENT HEX,.NEXT,04                                            24020002
         BLKENT HEX,.NEXT,02                                            24030002
         BLKENT LABEL,'Available extent 8',OFFSET=70                    24040005
         BLKENT LABEL,'DS5FMTID.....',NEWLIN=YES                        24050000
         BLKENT HEX,.NEXT,02          02C                               24060007
         BLKENT LABEL,'Format identifier',OFFSET=70                     24070005
         BLKENT LABEL,'DS5EXT9......',NEWLIN=YES                        24080000
         BLKENT HEX,.NEXT,04          02D                               24090002
         BLKENT HEX,.NEXT,04                                            24100002
         BLKENT HEX,.NEXT,02                                            24110002
         BLKENT LABEL,'Available extent 9',OFFSET=70                    24120005
         BLKENT LABEL,'DS5EXT10.....',NEWLIN=YES                        24130000
         BLKENT HEX,.NEXT,04                                            24140002
         BLKENT HEX,.NEXT,04                                            24150002
         BLKENT HEX,.NEXT,02                                            24160002
         BLKENT LABEL,'Available extent 10',OFFSET=70                   24170005
         BLKENT LABEL,'DS5EXT11.....',NEWLIN=YES                        24180000
         BLKENT HEX,.NEXT,04                                            24190002
         BLKENT HEX,.NEXT,04                                            24200002
         BLKENT HEX,.NEXT,02                                            24210002
         BLKENT LABEL,'Available extent 11',OFFSET=70                   24220005
         BLKENT LABEL,'DS5EXT12.....',NEWLIN=YES                        24230000
         BLKENT HEX,.NEXT,04                                            24240002
         BLKENT HEX,.NEXT,04                                            24250002
         BLKENT HEX,.NEXT,02                                            24260002
         BLKENT LABEL,'Available extent 12',OFFSET=70                   24270005
         BLKENT LABEL,'DS5EXT13.....',NEWLIN=YES                        24280000
         BLKENT HEX,.NEXT,04                                            24290002
         BLKENT HEX,.NEXT,04                                            24300002
         BLKENT HEX,.NEXT,02                                            24310002
         BLKENT LABEL,'Available extent 13',OFFSET=70                   24320005
         BLKENT LABEL,'DS5EXT14.....',NEWLIN=YES                        24330000
         BLKENT HEX,.NEXT,04                                            24340002
         BLKENT HEX,.NEXT,04                                            24350002
         BLKENT HEX,.NEXT,02                                            24360002
         BLKENT LABEL,'Available extent 14',OFFSET=70                   24370005
         BLKENT LABEL,'DS5EXT15.....',NEWLIN=YES                        24380000
         BLKENT HEX,.NEXT,04                                            24390002
         BLKENT HEX,.NEXT,04                                            24400002
         BLKENT HEX,.NEXT,02                                            24410002
         BLKENT LABEL,'Available extent 15',OFFSET=70                   24420005
         BLKENT LABEL,'DS5EXT16.....',NEWLIN=YES                        24430000
         BLKENT HEX,.NEXT,04                                            24440002
         BLKENT HEX,.NEXT,04                                            24450002
         BLKENT HEX,.NEXT,02                                            24460002
         BLKENT LABEL,'Available extent 16',OFFSET=70                   24470005
         BLKENT LABEL,'DS5EXT17.....',NEWLIN=YES                        24480000
         BLKENT HEX,.NEXT,04                                            24490002
         BLKENT HEX,.NEXT,04                                            24500002
         BLKENT HEX,.NEXT,02                                            24510002
         BLKENT LABEL,'Available extent 17',OFFSET=70                   24520005
         BLKENT LABEL,'DS5EXT18.....',NEWLIN=YES                        24530000
         BLKENT HEX,.NEXT,04                                            24540002
         BLKENT HEX,.NEXT,04                                            24550002
         BLKENT HEX,.NEXT,02                                            24560002
         BLKENT LABEL,'Available extent 18',OFFSET=70                   24570005
         BLKENT LABEL,'DS5EXT19.....',NEWLIN=YES                        24580000
         BLKENT HEX,.NEXT,04                                            24590002
         BLKENT HEX,.NEXT,04                                            24600002
         BLKENT HEX,.NEXT,02                                            24610002
         BLKENT LABEL,'Available extent 19',OFFSET=70                   24620005
         BLKENT LABEL,'DS5EXT20.....',NEWLIN=YES                        24630000
         BLKENT HEX,.NEXT,04                                            24640002
         BLKENT HEX,.NEXT,04                                            24650002
         BLKENT HEX,.NEXT,02                                            24660002
         BLKENT LABEL,'Available extent 20',OFFSET=70                   24670005
         BLKENT LABEL,'DS5EXT21.....',NEWLIN=YES                        24680000
         BLKENT HEX,.NEXT,04                                            24690002
         BLKENT HEX,.NEXT,04                                            24700002
         BLKENT HEX,.NEXT,02                                            24710002
         BLKENT LABEL,'Available extent 21',OFFSET=70                   24720005
         BLKENT LABEL,'DS5EXT22.....',NEWLIN=YES                        24730000
         BLKENT HEX,.NEXT,04                                            24740002
         BLKENT HEX,.NEXT,04                                            24750002
         BLKENT HEX,.NEXT,02                                            24760002
         BLKENT LABEL,'Available extent 22',OFFSET=70                   24770005
         BLKENT LABEL,'DS5EXT23.....',NEWLIN=YES                        24780000
         BLKENT HEX,.NEXT,04                                            24790002
         BLKENT HEX,.NEXT,04                                            24800002
         BLKENT HEX,.NEXT,02                                            24810002
         BLKENT LABEL,'Available extent 23',OFFSET=70                   24820005
         BLKENT LABEL,'DS5EXT24.....',NEWLIN=YES                        24830000
         BLKENT HEX,.NEXT,04                                            24840002
         BLKENT HEX,.NEXT,04                                            24850002
         BLKENT HEX,.NEXT,02                                            24860002
         BLKENT LABEL,'Available extent 24',OFFSET=70                   24870005
         BLKENT LABEL,'DS5EXT25.....',NEWLIN=YES                        24880000
         BLKENT HEX,.NEXT,04                                            24890002
         BLKENT HEX,.NEXT,04                                            24900002
         BLKENT HEX,.NEXT,02                                            24910002
         BLKENT LABEL,'Available extent 25',OFFSET=70                   24920005
         BLKENT LABEL,'DS5EXT26.....',NEWLIN=YES                        24930000
         BLKENT HEX,.NEXT,04                                            24940002
         BLKENT HEX,.NEXT,04                                            24950002
         BLKENT HEX,.NEXT,02                                            24960002
         BLKENT LABEL,'Available extent 26',OFFSET=70                   24970005
         BLKENT LABEL,'DS5PTRDS.....',NEWLIN=YES                        24980000
         BLKENT HEX,.NEXT,04          087                               24990002
         BLKENT HEX,.NEXT,04                                            25000002
         BLKENT HEX,.NEXT,02                                            25010002
         BLKENT LABEL,'Pointer to next Format 5 DSCB',OFFSET=70         25020005
         BLKEND ,                                                       25030000
         DC    (((((*-DSCBFMT)/256)+1)*256)-(*-DSCBFMT))X'00'           25040000
********************************************************************    25050000
*                                                                  *    25060000
********************************************************************    25070000
F6       BLKBGN OFF=000,LEN=FFF                                         25080000
         BLKENT LABEL,'DS6KEYID.....',NEWLIN=YES                        25090000
         BLKENT HEX,.NEXT,08          000                               25100000
         BLKENT LABEL,'Key identifier',OFFSET=70                        25110005
         BLKENT LABEL,'DS6AVEXT.....',NEWLIN=YES                        25120000
         BLKENT HEX,.NEXT,04          004                               25130002
         BLKENT HEX,.NEXT,04                                            25140002
         BLKENT HEX,.NEXT,02                                            25150002
         BLKENT LABEL,'Shared extent 1',OFFSET=70                       25160005
         BLKENT LABEL,'DS6EXT2......',NEWLIN=YES                        25170000
         BLKENT HEX,.NEXT,04          009                               25180002
         BLKENT HEX,.NEXT,04                                            25190002
         BLKENT HEX,.NEXT,02                                            25200002
         BLKENT LABEL,'Shared extent 2',OFFSET=70                       25210005
         BLKENT LABEL,'DS6EXT3......',NEWLIN=YES                        25220000
         BLKENT HEX,.NEXT,04                                            25230002
         BLKENT HEX,.NEXT,04                                            25240002
         BLKENT HEX,.NEXT,02                                            25250002
         BLKENT LABEL,'Shared extent 3',OFFSET=70                       25260005
         BLKENT LABEL,'DS6EXT4......',NEWLIN=YES                        25270000
         BLKENT HEX,.NEXT,04                                            25280002
         BLKENT HEX,.NEXT,04                                            25290002
         BLKENT HEX,.NEXT,02                                            25300002
         BLKENT LABEL,'Shared extent 4',OFFSET=70                       25310005
         BLKENT LABEL,'DS6EXT5......',NEWLIN=YES                        25320000
         BLKENT HEX,.NEXT,04                                            25330002
         BLKENT HEX,.NEXT,04                                            25340002
         BLKENT HEX,.NEXT,02                                            25350002
         BLKENT LABEL,'Shared extent 5',OFFSET=70                       25360005
         BLKENT LABEL,'DS6EXT6......',NEWLIN=YES                        25370000
         BLKENT HEX,.NEXT,04                                            25380002
         BLKENT HEX,.NEXT,04                                            25390002
         BLKENT HEX,.NEXT,02                                            25400002
         BLKENT LABEL,'Shared extent 6',OFFSET=70                       25410005
         BLKENT LABEL,'DS6EXT7......',NEWLIN=YES                        25420000
         BLKENT HEX,.NEXT,04                                            25430002
         BLKENT HEX,.NEXT,04                                            25440002
         BLKENT HEX,.NEXT,02                                            25450002
         BLKENT LABEL,'Shared extent 7',OFFSET=70                       25460005
         BLKENT LABEL,'DS6EXT8......',NEWLIN=YES                        25470000
         BLKENT HEX,.NEXT,04                                            25480002
         BLKENT HEX,.NEXT,04                                            25490002
         BLKENT HEX,.NEXT,02                                            25500002
         BLKENT LABEL,'Shared extent 8',OFFSET=70                       25510005
         BLKENT LABEL,'DS6FMTID.....',NEWLIN=YES                        25520000
         BLKENT HEX,.NEXT,02          02C                               25530007
         BLKENT LABEL,'Format identifier',OFFSET=70                     25540005
         BLKENT LABEL,'DS6EXT9......',NEWLIN=YES                        25550000
         BLKENT HEX,.NEXT,04          02D                               25560002
         BLKENT HEX,.NEXT,04                                            25570002
         BLKENT HEX,.NEXT,02                                            25580002
         BLKENT LABEL,'Shared extent 9',OFFSET=70                       25590005
         BLKENT LABEL,'DS6EXT10.....',NEWLIN=YES                        25600000
         BLKENT HEX,.NEXT,04                                            25610002
         BLKENT HEX,.NEXT,04                                            25620002
         BLKENT HEX,.NEXT,02                                            25630002
         BLKENT LABEL,'Shared extent 10',OFFSET=70                      25640005
         BLKENT LABEL,'DS6EXT11.....',NEWLIN=YES                        25650000
         BLKENT HEX,.NEXT,04                                            25660002
         BLKENT HEX,.NEXT,04                                            25670002
         BLKENT HEX,.NEXT,02                                            25680002
         BLKENT LABEL,'Shared extent 11',OFFSET=70                      25690005
         BLKENT LABEL,'DS6EXT12.....',NEWLIN=YES                        25700000
         BLKENT HEX,.NEXT,04                                            25710002
         BLKENT HEX,.NEXT,04                                            25720002
         BLKENT HEX,.NEXT,02                                            25730002
         BLKENT LABEL,'Shared extent 12',OFFSET=70                      25740005
         BLKENT LABEL,'DS6EXT13.....',NEWLIN=YES                        25750000
         BLKENT HEX,.NEXT,04                                            25760002
         BLKENT HEX,.NEXT,04                                            25770002
         BLKENT HEX,.NEXT,02                                            25780002
         BLKENT LABEL,'Shared extent 13',OFFSET=70                      25790005
         BLKENT LABEL,'DS6EXT14.....',NEWLIN=YES                        25800000
         BLKENT HEX,.NEXT,04                                            25810002
         BLKENT HEX,.NEXT,04                                            25820002
         BLKENT HEX,.NEXT,02                                            25830002
         BLKENT LABEL,'Shared extent 14',OFFSET=70                      25840005
         BLKENT LABEL,'DS6EXT15.....',NEWLIN=YES                        25850000
         BLKENT HEX,.NEXT,04                                            25860002
         BLKENT HEX,.NEXT,04                                            25870002
         BLKENT HEX,.NEXT,02                                            25880002
         BLKENT LABEL,'Shared extent 15',OFFSET=70                      25890005
         BLKENT LABEL,'DS6EXT16.....',NEWLIN=YES                        25900000
         BLKENT HEX,.NEXT,04                                            25910002
         BLKENT HEX,.NEXT,04                                            25920002
         BLKENT HEX,.NEXT,02                                            25930002
         BLKENT LABEL,'Shared extent 16',OFFSET=70                      25940005
         BLKENT LABEL,'DS6EXT17.....',NEWLIN=YES                        25950000
         BLKENT HEX,.NEXT,04                                            25960002
         BLKENT HEX,.NEXT,04                                            25970002
         BLKENT HEX,.NEXT,02                                            25980002
         BLKENT LABEL,'Shared extent 17',OFFSET=70                      25990005
         BLKENT LABEL,'DS6EXT18.....',NEWLIN=YES                        26000000
         BLKENT HEX,.NEXT,04                                            26010002
         BLKENT HEX,.NEXT,04                                            26020002
         BLKENT HEX,.NEXT,02                                            26030002
         BLKENT LABEL,'Shared extent 18',OFFSET=70                      26040005
         BLKENT LABEL,'DS6EXT19.....',NEWLIN=YES                        26050000
         BLKENT HEX,.NEXT,04                                            26060002
         BLKENT HEX,.NEXT,04                                            26070002
         BLKENT HEX,.NEXT,02                                            26080002
         BLKENT LABEL,'Shared extent 19',OFFSET=70                      26090005
         BLKENT LABEL,'DS6EXT20.....',NEWLIN=YES                        26100000
         BLKENT HEX,.NEXT,04                                            26110002
         BLKENT HEX,.NEXT,04                                            26120002
         BLKENT HEX,.NEXT,02                                            26130002
         BLKENT LABEL,'Shared extent 20',OFFSET=70                      26140005
         BLKENT LABEL,'DS6EXT21.....',NEWLIN=YES                        26150000
         BLKENT HEX,.NEXT,04                                            26160002
         BLKENT HEX,.NEXT,04                                            26170002
         BLKENT HEX,.NEXT,02                                            26180002
         BLKENT LABEL,'Shared extent 21',OFFSET=70                      26190005
         BLKENT LABEL,'DS6EXT22.....',NEWLIN=YES                        26200000
         BLKENT HEX,.NEXT,04                                            26210002
         BLKENT HEX,.NEXT,04                                            26220002
         BLKENT HEX,.NEXT,02                                            26230002
         BLKENT LABEL,'Shared extent 22',OFFSET=70                      26240005
         BLKENT LABEL,'DS6EXT23.....',NEWLIN=YES                        26250000
         BLKENT HEX,.NEXT,04                                            26260002
         BLKENT HEX,.NEXT,04                                            26270002
         BLKENT HEX,.NEXT,02                                            26280002
         BLKENT LABEL,'Shared extent 23',OFFSET=70                      26290005
         BLKENT LABEL,'DS6EXT24.....',NEWLIN=YES                        26300000
         BLKENT HEX,.NEXT,04                                            26310002
         BLKENT HEX,.NEXT,04                                            26320002
         BLKENT HEX,.NEXT,02                                            26330002
         BLKENT LABEL,'Shared extent 24',OFFSET=70                      26340005
         BLKENT LABEL,'DS6EXT25.....',NEWLIN=YES                        26350000
         BLKENT HEX,.NEXT,04                                            26360002
         BLKENT HEX,.NEXT,04                                            26370002
         BLKENT HEX,.NEXT,02                                            26380002
         BLKENT LABEL,'Shared extent 25',OFFSET=70                      26390005
         BLKENT LABEL,'DS6EXT26.....',NEWLIN=YES                        26400000
         BLKENT HEX,.NEXT,04                                            26410002
         BLKENT HEX,.NEXT,04                                            26420002
         BLKENT HEX,.NEXT,02                                            26430002
         BLKENT LABEL,'Shared extent 26',OFFSET=70                      26440005
         BLKENT LABEL,'DS6PTRDS.....',NEWLIN=YES                        26450000
         BLKENT HEX,.NEXT,04          087                               26460002
         BLKENT HEX,.NEXT,04                                            26470002
         BLKENT HEX,.NEXT,02                                            26480002
         BLKENT LABEL,'Pointer to next Format 6 DSCB',OFFSET=70         26490005
         BLKEND ,                                                       26500000
         DC    (((((*-DSCBFMT)/256)+1)*256)-(*-DSCBFMT))X'00'           26510000
*********************************************************************** 26520000
*                                                                       26530000
* FUNCTION:                                                             26540000
*        THIS SUBROUTINE READS THE VOLUME TABLE OF CONTENTS (VTOC)      26550000
*        FROM A DIRECT-ACCESS DEVICE AND PRESENTS IT TO THE CALLER      26560000
*        ONE RECORD (DSCB) AT A TIME.                                   26570000
*                                                                       26580000
* OPERATION:                                                            26590000
*        THIS ROUTINE IS A SPECIALIZED SEQUENTIAL ACCESS METHOD         26600000
*        FOR VTOC'S.  ITS ADVANTAGE OVER ORDINARY BSAM IS THAT IT READS 26610000
*        AN ENTIRE TRACK IN ONE REVOLUTION, THUS SAVING CONSIDERABLE    26620000
*        TIME.  THE ROUTINE HAS THREE CALL MODES;                       26630000
*                                                                       26640000
*        0 - READ.  RETURNS WITH THE CORE ADDRESS OF A DSCB IN THE 3RD  26650000
*              PARAMETER.  THE CORE CONSISTS OF 148 CONSECUTIVE BYTES,  26660000
*              CONTAINING THE COUNT (8 BYTES), KEY (44 BYTES), AND DATA 26670000
*              (96 BYTES) FOR ONE DSCB.  RETURN CODES (REGISTER 15)     26680000
*              ARE;                                                     26690000
*                      0 - NORMAL;                                      26700000
*                      4 - END OF FILE, NO DATA PRESENTED;              26710000
*                      8 - PERMANENT I/O ERROR.  THE KEY AND DATA AREAS 26720000
*                          WILL BE SET TO ZEROS; THE COUNT AREA WILL    26730000
*                          CONTAIN THE CORRECT CCHHR.  SINCE READING    26740000
*                          IS DONE A TRACK AT A TIME, ALL THE DSCB'S    26750000
*                          FOR THAT TRACK WILL BE MARKED IN ERROR.      26760000
*                          READING MAY CONTINUE ON TO THE NEXT TRACK.   26770000
*                                                                       26780000
*        1 - OPEN.  THE SECOND PARAMETER SHOULD POINT TO                26790000
*              A  6-BYTE FIELD CONTAINING THE VOLSER TO BE USED FOR THE 26800000
*              ALLOCATION.                                              26810000
*              RETURN CODES ( REG 15 )  ARE DIRECT FROM DYNAMIC ALLOC.  26820000
*                      0 - NORMAL;                                      26830000
*                      4 - UNABLE TO OPEN (PROBABLY MISSING DD CARD);   26840000
*                      8 - DD CARD DID NOT REFER TO A DIRECT-ACCESS     26850000
*                          DEVICE, OR DEVICE TYPE UNKNOWN.              26860000
*                                                                       26870000
*        2 - CLOSE.  NO ARGUMENTS ARE REQUIRED OR RETURNED.  RETURN     26880000
*              CODE ( REG 15 ) IS FROM DYNAMIC UNALLOCATION.            26890000
* ENTRY POINTS:                                                         26900000
*        ENTRY IS ALWAYS TO 'UTS07'.                                    26910000
*        ARGUMENTS ARE:                                                 26920000
*                      1 - A(FULL-WORD BINARY ENTRY TYPE);              26930000
*                      2 - A(PTR FOR DSCB);                             26940000
*                      3 - A(VOLSER).                                   26950000
* DATA SETS:                                                            26960000
*        READS VOLUME TABLE OF CONTENTS FROM ANY DIRECT-ACCESS          26970000
*        DEVICE.  USES EXCP TO EXECUTE A CHAINED CHANNEL PROGRAM TO     26980000
*        READ AN ENTIRE TRACK AT A TIME.                                26990000
*                                                                       27000000
* EXTERNAL ROUTINES:                                                    27010000
*        USES SUPERVISOR ROUTINE 'IECPCNVT' TO CONVERT                  27020000
*        A RELATIVE TRACK NUMBER TO AN ABSOLUTE ADDRESS.                27030000
*                                                                       27040000
* EXITS:                                                                27050000
*        RETURNS TO CALLER VIA R14 WITH RETURN                          27060000
*        CODE IN REGISTER 15.       (SEE ABOVE FOR RETURN CODE VALUES.) 27070000
*                                                                       27080000
* TABLES AND WORK AREAS:                                                27090000
*        USES AN AREA PROVIDED BY THE CALLER FOR                        27100000
*        ITS SAVEAREA AND FOR WORKING STORAGE IMMEDIATELY FOLLOWING     27110000
*        THE PRIOR SAVEAREA.  IT USES GETMAIN TO OBTAIN AN AREA FOR     27120000
*        THE DSCB'S TO BE READ INTO. IT IS FREED BY THE FINAL CALL.     27130000
*                                                                       27140000
* ATTRIBUTES:                                                           27150000
*        REENTRANT, REFRESHABLE.                                        27160000
*                                                                       27170000
*********************************************************************** 27180000
*********************************************************************** 27190000
* ENTER HERE AND PERFORM STANDARD REGISTER SAVE AREA HOUSEKEEPING.    * 27200000
*********************************************************************** 27210000
UTS07    CSECT                                                          27220000
         USING *,R15                   TEMPORARY BASE                   27230000
         B     VTOCBGN                 BYPASS ID                        27240000
         DROP  R15                     DROP TEMPORARY BASE              27250000
         DC    AL1(8)                  ID LENGTH                        27260000
VTOCID   DC    CL8'UTS07'                                               27270000
VTOCBGN  DC    0H'+0'                                                   27280000
         STM   R14,R12,12(R13)         SAVE REGISTERS                   27290000
         LR    R12,R15                 LOAD BASE REGISTER               27300000
         USING UTS07,R12               ESTABLISH BASE REGISTER 1        27310000
         LR    R11,R1                  SAVE PARAMETER REGISTER          27320000
         USING VTOCOM,R11              SET ADDRESSABILITY               27330000
         ICM   R14,B'1111',VTOCWRK     GET SAVE AREA                    27340000
         BNZ   RECHAIN                  IF ALREADY THERE SKIP GETMAIN   27350000
         GETMAIN R,LV=VTOCWLEN         GET WORK SPACE                   27360000
         LR    R14,R1                  LOAD TEMP SAVE AREA ADDRESS      27370000
RECHAIN  ST    R14,8(,R13)             LSA ADDR TO HSA SLOT             27380000
         ST    R13,4(,R14)             HSA ADDR TO LSA SLOT             27390000
         LR    R13,R14                 LOAD SAVE AREA REGISTER          27400000
         USING VTOCWORK,R13            SET ADDRESSABILITY FOR WORK AREA 27410000
         ST    R13,VTOCWRK             SAVE VTOC WORK AREA ADDRESS      27420000
*                                                                       27430000
*        POINT TO THE DCB FOR LATER REFERENCES                          27440000
*                                                                       27450000
         LA    R8,VTOCDCB              POINT TO IT                      27460000
         USING IHADCB,R8               SET ADDRESSABILITY               27470000
* SELECT MODE FROM CONTENTS AT ADDRESS IN REGISTER 1.                   27480000
         SR    R2,R2                   CLEAR THE REGISTER               27490000
         CLI   VTCEFUNC,3              EXCEED MAX FUNCTION ?            27500000
         BH    FUNCERR                  YES, ERROR                      27510000
         IC    R2,VTCEFUNC             GET CALL MODE                    27520000
         SLL   R2,2                    MODE TIMES 4                     27530000
         B     VTCROUTE(R2)            BRANCH ON MODE                   27540000
VTCROUTE B     GETDSB                  MODE 0, GET A DSCB               27550000
         B     OPEN                    MODE 1, OPEN A NEW VTOC          27560000
         B     CLOSE                   MODE 2, CLOSE                    27570000
         B     RETURN0                 MODE 3 NOT DEFINED, NO OP        27580000
*********************************************************************** 27590000
* EXIT                                                                * 27600000
*********************************************************************** 27610000
RETURN0  SR    R15,R15                 CLEAR THE RETURN CODE            27620000
RETURN   L     R13,4(,R13)             GET PRIOR SAVE AREA ADDRESS      27630000
RETURNX  RETURN (14,12),RC=(15)        RETURN                           27640000
*********************************************************************** 27650000
* MODE 0 - GET DSCB                                                   * 27660000
*********************************************************************** 27670000
* IF END-OF-FILE WAS REACHED, RETURN AT ONCE.                           27680000
GETDSB   LA    R15,4                   SET THE RETURN CODE, IN CASE     27690000
         TM    MODESW,EOFSW            TEST END-OF-FILE BIT             27700000
         BO    RETURN                  RETURN CODE 4 IF ON              27710000
* IF CHANNEL PROGRAM HAS BEEN STARTED, GO TO CHECK IT.  OTHERWISE,      27720000
* ASSUME THERE IS AT LEAST ONE FULL BUFFER.                             27730000
         TM    MODESW,XCPRUN           TEST IF EXCP ISSUED              27740000
         BO    XCPTEST                 BRANCH IF SO                     27750000
* SET BUFFER ADDRESS TO NEXT DSCB AND TEST IF LAST ON TRACK.  IF NOT,   27760000
* EXIT WITH ITS ADDRESS IN R1.                                          27770000
         L     R2,DSCBADR              LOAD BUFFER POINTER              27780000
         LA    R2,148(,R2)             ADVANCE TO NEXT DSCB             27790000
NDXSTORE ST    R2,DSCBADR              STORE UPDATED POINTER            27800000
         C     R2,DSCBLIM              TEST IF LAST DSCB IN BUFFER      27810000
         BNL   LASTDSCB                BRANCH IF SO                     27820000
         LR    R1,R2                   PASS ADDRESS TO USER             27830000
GETOUT   ST    R1,DSCBADDR             STORE IT FOR THE CALLER          27840000
         TM    MODESW,RDERR            TEST IF ERROR ON THIS TRACK      27850000
         BZ    RETURN0                 RETURN CODE 0 IF NOT             27860000
         LA    R15,8                   SET THE RETURN CODE              27870000
         B     RETURN                  RETURN CODE 8 IF ERROR           27880000
* IF THIS IS THE LAST DSCB, MOVE IT TO THE INTERNAL BUFFER AND START    27890000
* READING THE NEXT TRACK.                                               27900000
LASTDSCB MVC   BUFF(148),0(R2)         MOVE LAST DSCB                   27910000
         L     R3,TTRN                 LOAD RELATIVE TRACK NUMBER       27920000
         AL    R3,=X'00010000'         INCREMENT TO NEXT TRACK          27930000
         ST    R3,TTRN                                                  27940000
         BAL   R9,EXCP                 START CHANNEL PROGRAM            27950000
         LA    R1,BUFF                 LOAD DSCB ADDRESS FOR CALLER     27960000
         B     GETOUT                  TO RETURN                        27970000
*********************************************************************** 27980000
* WAIT FOR CHANNEL PROGRAM COMPLETION AND TEST THE OUTCOME.           * 27990000
*********************************************************************** 28000000
XCPTEST  WAIT  ECB=VTOCECB                                              28010000
         NI    MODESW,X'FF'-XCPRUN     TURN EXCP STARTED BIT OFF        28020000
         CLI   VTOCECB,X'7F'           TEST COMPLETION CODE             28030000
         BNE   PERMERR                 BRANCH IF ERROR                  28040000
SETDSCBA L     R2,DSCBSTRT             SET BUFFER POINTER TO 1ST DSCB   28050000
         B     NDXSTORE                                                 28060000
* PERMANENT ERROR FOR THIS TRACK.  ZERO THE DSCB'S AND FILL IN THE      28070000
* CCHHR PORTIONS OF THE COUNT AREAS.                                    28080000
PERMERR  OI    MODESW,RDERR            SIGNAL READ ERROR                28090000
         NI    IOBFLAG1,X'FB'          TURN OFF BIT 5 OF IOB FLAG       28100000
         NI    DCBIFLGS,X'3F'          TURN OFF BITS 0 AND 1            28110000
         L     R2,DSCBSTRT             LOAD ADDRESS OF FIRST DSCB       28120000
         LA    R3,1                    LOAD RECORD NUMBER               28130000
DSCBELUP XC    0(148,R2),0(R2)         ZERO DSCB BUFFER                 28140000
         MVC   0(4,R2),IOBSEEK+3       INSERT CCHH IN COUNT FIELD       28150000
         STC   R3,4(,R2)               INSERT R IN COUNT FIELD          28160000
         LA    R2,148(,R2)             POINT TO NEXT BUFFER             28170000
         LA    R3,1(,R3)               INCREMENT RECORD NUMBER          28180000
         C     R2,DSCBLIM              TEST FOR LAST BUFFER             28190000
         BNH   DSCBELUP                                                 28200000
*                                      I/O ERROR ON TRACK               28210000
         B     SETDSCBA                BRANCH TO RESET BUFFER POINTER   28220000
*********************************************************************** 28230000
* MODE 1 - OPEN                                                       * 28240000
*********************************************************************** 28250000
* ENTER WITH A DDNAME IN SECOND PARAMETER POSITION.  PERFORM CLOSE      28260000
* SUBROUTINE FIRST TO BE SURE EVERYTHING IS INITIALIZED.                28270000
OPEN     DS    0H                                                       28280000
         BAL   R9,CLOSESUB             CALL CLOSE SUBROUTINE            28290000
*                                                                       28300000
*        INITIALIZE THE DATA AREAS                                      28310000
*                                                                       28320000
*        FIRST THE DCB                                                  28330000
         MVC   VTOCDCB(DCBLEN),VTOCDCBM  SET UP THE DCB                 28340000
*        SET UP THE JFCB LISTS                                          28350000
         LA    R1,JEXLST               POINT TO THE EXIT LIST           28360000
         STCM  R1,B'0111',DCBEXLSA     PUT IT INTO THE DCB              28370000
         LA    R1,JFCBAREA             POINT TO THE JFCB AREA           28380000
         ST    R1,JEXLST               AND PUT THAT INTO THE EXIT LIST  28390000
         MVI   JEXLST,X'87'            END OF LIST, JFCB EXIT           28400000
         MVI   OPENLIST,X'80'          END OF THE OPEN LIST TOO         28410000
*        INITIALIZE THE IOB                                             28420000
         MVC   VTOCIOB(IOBCONL),IOBCONST START IT OUT                   28430000
         LA    R1,VTOCECB              GET THE ECB ADDRESS              28440000
         ST    R1,IOBECB               AND STORE IT INTO THE IOB        28450000
         ST    R8,IOBDCB               DCB ADDRESS IN THE IOB           28460000
*        INITIALIZE THE CAMLST                                          28470000
         MVC   DSCBFMT4(4),DSCBCON     SET UP THE FIRST WORD            28480000
         LA    R1,IOBSEEK+3            SEEK ADDRESS                     28490000
         ST    R1,DSCBFMT4+4           INTO THE CAMLST                  28500000
         LA    R1,VOLID                VOLUME SERIAL NUMBER             28510000
         ST    R1,DSCBFMT4+8           INTO THE CAMLST                  28520000
         LA    R1,FMT4                 DSCB AREA                        28530000
         ST    R1,DSCBFMT4+12          INTO THE CAMLST                  28540000
*********************************************************************** 28550000
*        ALLOCATE THE VTOC OF THE CHOSEN PACK                         * 28560000
*********************************************************************** 28570000
         LA    R1,VOLID                POINT TO THE VOLUME SERIAL       28580000
         ST    R1,VOLADDR              SAVE THE ADDRESS                 28590000
         LA    R1,6                    ALSO GET THE LENGTH              28600000
         STH   R1,VOLLEN               SAVE FOR DYNAMIC ALLOCATION      28610000
*        ALLOC DSN=VTOCNM,VOL=VOLADDR,UNIT='SYSALLDA',DISP=SHR,         28620000
*              DDNTO=DCBDDNAM,ERROR=S99FAIL                             28630000
         LA    R1,DYNSP1               LOAD ADDRESS OF PARAM LIST       28640000
         USING DYN1DS,R1               USE GENERATED DSECT              28650000
         LA    R15,DYN1RB              LOAD ADDRESS OF S99 RB           28660000
         USING S99RB,R15                                                28670000
         ST    R15,0(,R1)              AND STORE IN RB POINTER          28680000
         XC    4(DYN1LEN-4,R1),4(R1)   ZERO PARAMETER LIST              28690000
         MVI   S99RBLN,20              MOVE IN LIST LENGTH              28700000
         MVI   S99VERB,S99VRBAL        MOVE IN VERB CODE                28710000
         LA    R14,DYN1TUP             LOAD ADDRESS OF TU POINTERS      28720000
         ST    R14,S99TXTPP            STORE ADDRESS IN S99 RB          28730000
         LA    R15,DYN1TU              POINT TO SPACE FOR TEXT UNITS    28740000
         USING S99TUNIT,R15                                             28750000
*********************************************************************** 28760000
**   BUILD THE DSNAME TEXT UNIT                                      ** 28770000
*********************************************************************** 28780000
         LR    R0,R2                   SAVE CONTENTS OF REGISTER 2      28790000
         L     R14,VTOCNM              LOAD ADDRESS OF DSNAME           28800000
         LH    R2,VTOCNM+4             LOAD LENGTH OF DSNAME            28810000
         STH   R2,S99TULNG             STORE DSNAME LENGTH              28820000
         BCTR  R2,0                    DECREMENT FOR EXECUTE            28830000
         EX    R2,DYN1MVC              MOVE DSNAME                      28840000
         MVI   S99TUKEY+1,DALDSNAM     MOVE IN DSNAME KEY               28850000
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 28860000
         ST    R15,DYN1TUP+0           STORE TEXT UNIT ADDRESS          28870000
         LA    R15,50(,R15)            BUMP TEXT UNIT PTR TO NEXT SLOT  28880000
*********************************************************************** 28890000
**    DDNAME RETURN TEXT UNIT                                        ** 28900000
*********************************************************************** 28910000
         MVI   S99TUKEY+1,DALRTDDN     SET RETURN DDNAME KEY            28920000
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 28930000
         MVI   S99TULNG+1,8            SET LENGTH FIELD                 28940000
         MVC   S99TUPAR(8),=CL8' '     INITIALIZE FIELD TO BLANKS       28950000
         ST    R15,DYN1TUP+4           STORE TEXT UNIT ADDRESS          28960000
         LA    R15,14(,R15)            BUMP TEXT UNIT PTR TO NEXT SLOT  28970000
*********************************************************************** 28980000
**       UNIT NAME TEXT UNIT                                         ** 28990000
*********************************************************************** 29000000
         MVI   S99TUKEY+1,DALUNIT      SET TEXT UNIT KEY                29010000
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 29020000
         MVI   S99TULNG+1,8            MOVE IN LENGTH                   29030000
         MVC   S99TUPAR(8),UNITID      Passed unit name                 29040007
         ST    R15,DYN1TUP+8           STORE TEXT UNIT ADDRESS          29050000
         LA    R15,14(,R15)            BUMP TEXT UNIT PTR TO NEXT SLOT  29060000
*********************************************************************** 29070000
**       VOLUME SERIAL TEXT UNIT                                     ** 29080000
*********************************************************************** 29090000
         LH    R2,VOLADDR+4            LOAD LENGTH OF TEXT UNIT         29100000
         LTR   R2,R2                   TEST FOR ZERO                    29110000
         BZ    DYN1NVS                 IF NO TEXT UNIT, SKIP            29120000
         L     R14,VOLADDR             LOAD ADDRESS OF TEXT UNIT        29130000
         STH   R2,S99TULNG             STORE LENGTH OF TEXT UNIT        29140000
         BCTR  R2,0                    DECREMENT FOR EXECUTE            29150000
         EX    R2,DYN1MVC              MOVE IN TEXT UNIT                29160000
         MVI   S99TUKEY+1,DALVLSER     MOVE IN TEXT UNIT KEY            29170000
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 29180000
         ST    R15,DYN1TUP+12          STORE TEXT UNIT ADDRESS          29190000
DYN1NVS  LA    R15,14(,R15)            BUMP TEXT UNIT PTR TO NEXT SLOT  29200000
*********************************************************************** 29210000
**     DATA SET INITIAL STATUS                                       ** 29220000
*********************************************************************** 29230000
         MVC   S99TUKEY(8),=Y(DALSTATS,1,1,X'0800')                     29240000
         ST    R15,DYN1TUP+16          STORE TEXT UNIT ADDRESS          29250000
         LA    R15,8(,R15)             BUMP TEXT UNIT PTR TO NEXT SLOT  29260000
         MVI   DYN1TUP+16,X'80'        SET HIGH ORDER BIT ON TEXT PTRS  29270000
         MVI   DYN1RBP,X'80'           SET HIGH ORDER BIT ON RB PTR     29280000
         B     DYN1OMV                 SKIP NEXT INSTRUCTION            29290000
DYN1MVC  MVC   S99TUPAR(0),0(R14)      EXECUTED MOVE                    29300000
DYN1OMV  LR    R2,R0                   RESTORE CONTENTS OF REGISTER 2   29310000
         DROP  R1,R15                  DEACTIVATE ADDRESSABILITY        29320000
         LA    R14,4(,R1)              POINT TO REQUEST BLOCK           29330000
         DYNALLOC                      DYNAMIC ALLOCATION               29340000
         USING DYN1RB,R14              SET UP ADDRESSABILITY            29350000
**       NOTE  R14 HAS RB ADDRESS, R15 HAS SVC 99 RETURN CODE        ** 29360000
         LTR   R15,R15                 TEST RETURN CODE                 29370000
         BNZ   S99FAIL                 BRANCH IF NON ZERO               29380000
         MVC   DCBDDNAM(8),DYN1TU+54+2                                  29390000
         OI    MODESW,ALLOCSW          SET ALLOCATE FLAG ON             29400000
*********************************************************************** 29410000
* OPEN THE VTOC.                                                      * 29420000
*        FIRST READ THE JFCB TO SWITCH THE DSNAME TO HEX 04'S         * 29430000
*********************************************************************** 29440000
         RDJFCB ((R8)),MF=(E,OPENLIST) READ THE JFCB                    29450000
         LTR   R15,R15                 TEST THE RETURN CODE             29460000
         BNZ   ERRJFCB                 BAD NEWS                         29470000
         LA    R1,JFCBAREA             POINT TO THE JFCB                29480000
         USING JFCB,R1                 SET UP ADDRESSABILITY            29490000
         MVI   JFCBDSNM,X'04'          PUT IN THE FIRST ONE             29500000
         MVC   JFCBDSNM+1(L'JFCBDSNM-1),JFCBDSNM  PROPAGATE IT          29510000
         OI    JFCBTSDM,JFCNWRIT       DON'T REWRITE IT                 29520000
         DROP  R1                                                       29530000
         OPEN  ((R8),(INPUT)),MF=(E,OPENLIST),TYPE=J  OPEN THE VTOC     29540000
         TM    DCBOFLGS,DCBOFOPN       TEST IF OPEN WORKED              29550000
         BZ    OPENERR                 ERROR IF OPEN FAILED             29560000
* ISSUE AN OBTAIN FOR THE FIRST DSCB ON THE VTOC ( FORMAT 4 )           29570000
D3       STM   R2,R13,EXCPSAVE         SAVE OUR REGS                    29580000
         LA    R3,EXCPSAVE             POINT TO THE REGISTER SAVE AREA  29590006
         ICM   R0,B'1111',=X'00000100' FIRST DSCB                       29600000
         L     R1,DCBDEBAD             DEB ADDRESS                      29610000
         LA    R2,IOBSEEK              SAVE ADDRESS OF CCHHR            29620000
         L     R15,CVTPTR              GET ADDRESS OF CVT               29630000
         USING CVT,R15                 CVT ADDRESSABILITY               29640000
         L     R15,CVTPCNVT            GET ADDRESS OF CONVERT ROUTINE   29650000
         DROP  R15                     DROP CVT BASE                    29660000
         BALR  R14,R15                 GO TO CONVERT ROUTINE            29670000
         LM    R2,R13,0(R3)            GET MY REGS BACK                 29680000
         OBTAIN DSCBFMT4               GET FORMAT 4 DSCB                29690000
         LTR   R15,R15                 DID WE GET IT                    29700000
         BNZ   OBTERR                  NO - THEN ERROR, KEEP R15        29710000
         LA    R14,FMT4                                                 29720000
         USING DSCB,R14                                                 29730000
         CLI   DS4IDFMT,C'4'           MAKE SURE WE HAVE FORMAT 4       29740000
         BNE   NOTFMT4                 NO - THEN ERROR                  29750000
         IC    R15,DS4DEVDT            GET NUMBER OF DSCBS PER TRACK    29760000
         DROP  R14                                                      29770000
         ST    R15,NDSCBS              SAVE THE NUMBER OF DSCBS         29780000
         OC    NDSCBS,NDSCBS           MAKE SURE NOT ZERO               29790000
         BZ    DSCBNUM0                YES - GO TELL CALLER             29800000
*********************************************************************** 29810000
* OBTAIN CORE FOR CHANNEL PROGRAM AND DSCB BUFFERS.                   * 29820000
*********************************************************************** 29830000
         LA    R0,156                  CORE FOR ONE DSCB AND ITS CCW    29840000
         MH    R0,NDSCBS+2             TIMES NUMBER PER TRACK           29850000
         AH    R0,=H'15'               PLUS 1 CCW AND ROUNDING          29860000
         N     R0,=X'FFFFFFF8'         ROUND TO DOUBLE-WORD MULTIPLE    29870000
         ST    R0,CBSIZE               SAVE SIZE OF GOTTEN CORE         29880000
         GETMAIN  R,LV=(0)             GET TRACK BUFFERS                29890000
         ST    R1,CBADDR               SAVE ADDRESS OF GOTTEN CORE      29900000
         OI    MODESW,CBGOT            INDICATE CORE GOTTEN             29910000
* GENERATE CHANNEL PROGRAM.  IT CONSISTS OF A 'READ R0' ORDER WITH      29920000
* THE SKIP FLAG ON, FOLLOWED BY A 'READ COUNT-KEY-AND-DATA' ORDER FOR   29930000
* EACH DSCB.                                                            29940000
         L     R2,NDSCBS               NUMBER OF DSCB'S                 29950000
         SLL   R2,3                    TIMES   8                        29960000
         LA    R2,8(R2,R1)             PLUS 8 AND BASE = 1ST BUFFER     29970000
         ST    R2,DSCBSTRT             SAVE ADDRESS OF FIRST BUFFER     29980000
         ST    R1,IOBSTART             ADDRESS OF CHANNEL PROGRAM       29990000
         MVC   0(8,R1),INITCCW         INSERT FIRST CCW                 30000000
         LA    R3,8(,R1)               PLACE FOR NEXT CCW               30010000
         LA    R4,1                    BUFFER COUNTER                   30020000
CCWLOOP  MVC   0(8,R3),READCCW         INSERT READ CCW FOR ONE DSCB     30030000
         ST    R2,0(,R3)               SET ITS BUFFER ADDRESS           30040000
         MVI   0(R3),READCKD           RESTORE COMMAND CODE             30050000
         C     R4,NDSCBS               TEST BUFFER COUNTER              30060000
         BNL   LASTCCW                 BRANCH IF LAST BUFFER            30070000
         LA    R3,8(,R3)               INCREMENT CCW ADDRESS            30080000
         LA    R2,148(,R2)             INCREMENT BUFFER ADDRESS         30090000
         LA    R4,1(,R4)               INCREMENT BUFFER COUNTER         30100000
         B     CCWLOOP                 DO NEXT BUFFER                   30110000
LASTCCW  NI    4(R3),X'FF'-CC          TURN OFF COMMAND CHAIN BIT       30120000
         ST    R2,DSCBLIM              SAVE ADDRESS OF LAST DSCB BUFFER 30130000
* SET OTHER THINGS AND START PROGRAM TO FILL BUFFER.                    30140000
         SR    R0,R0                                                    30150000
         ST    R0,TTRN                 SET RELATIVE TRACK NUMBER TO 0   30160000
         NI    MODESW,X'FF'-XCPRUN-RDERR-EOFSW   SET FLAGS OFF          30170000
         BAL   R9,EXCP                 START CHANNEL PROGRAM            30180000
         B     RETURN0                 INDICATE SUCCESSFUL OPEN         30190000
*********************************************************************** 30200000
* MODE 2 - CLOSE                                                      * 30210000
*********************************************************************** 30220000
CLOSE    BAL   R9,CLOSESUB             CALL CLOSED CLOSE SUBROUTINE     30230000
         LR    R1,R13                  SAVE WORK AREA ADDRESS           30240000
         L     R13,4(,R13)             GET PRIOR SAVE AREA ADDRESS      30250000
         FREEMAIN R,A=(1),LV=VTOCWLEN  FREE WORK AREA                   30260000
         XC    VTOCWRK,VTOCWRK         SET NO SAVE AREA                 30270000
         SLR   R15,R15                 SET 0 RC                         30280000
         B     RETURNX                 EXIT                             30290000
* IF THE CHANNEL PROGRAM IS RUNNING, WAIT FOR IT BEFORE TAKING FURTHER  30300000
* ACTION.                                                               30310000
CLOSESUB DS    0H                                                       30320000
         TM    MODESW,XCPRUN           TEST IF CHANNEL PROGRAM RUNNING  30330000
         BZ    NOEXCP                  BRANCH IF NOT                    30340000
         WAIT  ECB=VTOCECB             WAIT UNTIL COMPLETE              30350000
         NI    MODESW,X'FF'-XCPRUN     TURN RUNNING SWITCH OFF          30360000
NOEXCP   DS    0H                                                       30370000
* CLOSE THE DCB.                                                        30380000
         TM    DCBOFLGS,DCBOFOPN       TEST IF DCB OPEN                 30390000
         BZ    NOCLOSE                 BRANCH IF NOT                    30400000
         CLOSE ((R8)),MF=(E,OPENLIST)  CLOSE THE VTOC                   30410000
NOCLOSE  DS    0H                                                       30420000
* FREE UP THE DDNAME AND VOLUME                                         30430000
         TM    MODESW,ALLOCSW          DID WE ALLOCATE A DEVICE         30440000
         BNO   NOALLOC                 NO  - THEN NOTHING TO FREEUP     30450000
         LA    R1,DCBDDNAM             POINT TO THE DDNAME              30460000
         ST    R1,DDNPDL               SAVE IT FOR FREE                 30470000
         LA    R1,8                    GET THE DDNAME LENGTH            30480000
         STH   R1,DDNPDL+4             SAVE IT FOR FREE                 30490000
*********************************************************************** 30500000
*  FREE UP THE FILE                                                   * 30510000
*********************************************************************** 30520000
*        FREE  UNALC,DDN=DDNPDL,ERROR=S99FAIL  FREE THE DDNAME          30530000
         DS    0H                                                       30540000
         LA    R1,DYNSP1               LOAD ADDRESS OF PARAM LIST       30550000
         USING DYN2DS,R1               USE GENERATED DSECT              30560000
         LA    R15,DYN2RB              LOAD ADDRESS OF S99 RB           30570000
         USING S99RB,R15                                                30580000
         ST    R15,0(,R1)              AND STORE IN RB POINTER          30590000
         XC    4(DYN2LEN-4,R1),4(R1)   ZERO PARAMETER LIST              30600000
         MVI   S99RBLN,20              MOVE IN LIST LENGTH              30610000
         MVI   S99VERB,S99VRBUN        MOVE IN VERB CODE                30620000
         LA    R14,DYN2TUP             LOAD ADDRESS OF TU POINTERS      30630000
         ST    R14,S99TXTPP            STORE ADDRESS IN S99 RB          30640000
         LA    R15,DYN2TU              POINT TO SPACE FOR TEXT UNITS    30650000
         USING S99TUNIT,R15                                             30660000
*********************************************************************** 30670000
**        FREE DDNAME TEXT UNIT                                      ** 30680000
*********************************************************************** 30690000
         LR    R0,R2                   SAVE CONTENTS OF REGISTER 2      30700000
         L     R14,DDNPDL              LOAD ADDRESS OF DDNAME           30710000
         LH    R2,DDNPDL+4             LOAD LENGTH OF DDNAME            30720000
         STH   R2,S99TULNG             STORE DDNAME LENGTH              30730000
         BCTR  R2,0                    DECREMENT FOR EXECUTE            30740000
         EX    R2,DYN2MVC              MOVE DDNAME                      30750000
         MVI   S99TUKEY+1,DUNDDNAM     MOVE IN DDNAME KEY               30760000
         MVI   S99TUNUM+1,1            SET NUMBER FIELD                 30770000
         ST    R15,DYN2TUP+0           STORE TEXT UNIT ADDRESS          30780000
         LA    R15,14(,R15)            BUMP TEXT UNIT PTR TO NEXT SLOT  30790000
*********************************************************************** 30800000
**     FREE EVEN IF PERMANENTLY ALLOCATED                            ** 30810000
*********************************************************************** 30820000
         MVI   S99TUKEY+1,DUNUNALC     SET TEXT UNIT KEY                30830000
         ST    R15,DYN2TUP+4           STORE TEXT UNIT ADDRESS          30840000
         LA    R15,4(,R15)             BUMP TEXT UNIT PTR TO NEXT SLOT  30850000
         MVI   DYN2TUP+4,X'80'         SET HIGH ORDER BIT ON TEXT PTRS  30860000
         MVI   DYN2RBP,X'80'           SET HIGH ORDER BIT ON RB PTR     30870000
         B     DYN2OMV                 SKIP NEXT INSTRUCTION            30880000
DYN2MVC  MVC   S99TUPAR(0),0(R14)      EXECUTED MOVE                    30890000
DYN2OMV  LR    R2,R0                   RESTORE CONTENTS OF REGISTER 2   30900000
         DROP  R1,R15                  DEACTIVATE ADDRESSABILITY        30910000
         DYNALLOC                      DYNAMIC ALLOCATION               30920000
         LA    R14,DYNSP1+4            LOAD REG 14 WITH ADDRESS OF RB   30930000
         USING DYN2RB,R14              SET UP ADDRESSABILITY            30940000
         LTR   R15,R15                 TEST RETURN CODE                 30950000
         BNZ   S99FAIL                 BRANCH IF NON ZERO               30960000
**       NOTE.  R14 POINTS TO REQUEST BLOCK, R15 HAS RETURN CODE     ** 30970000
         NI    MODESW,X'FF'-ALLOCSW    TURN OFF ALLOCATE SW             30980000
*********************************************************************** 30990000
* RELEASE CORE OBTAINED FOR DSCB BUFFERS.                             * 31000000
*********************************************************************** 31010000
NOALLOC  DS    0H                                                       31020000
         TM    MODESW,CBGOT            TEST IF CORE GOTTEN              31030000
         BZ    NOFREE                  BRANCH IF NOT                    31040000
         LM    R0,R1,CBSIZE            LOAD SIZE AND LOCATION           31050000
         FREEMAIN  R,LV=(0),A=(1)      FREE CORE                        31060000
         NI    MODESW,X'FF'-CBGOT      SET CORE GOTTEN BIT OFF          31070000
NOFREE   DS    0H                                                       31080000
         NI    MODESW,X'FF'-RDERR      CLEAR ERROR SWITCH               31090000
         BR    R9                                                       31100000
*********************************************************************** 31110000
* EXCP ROUTINE                                                        * 31120000
*********************************************************************** 31130000
* CONVERT RELATIVE TRACK ADDRESS IN 'TTRN' TO ABSOLUTE SEEK ADDRESS IN  31140000
* 'IOBSEEK', USING SUPERVISOR CONVERSION ROUTINE.                       31150000
EXCP     DS    0H                                                       31160000
         STM   R2,R13,EXCPSAVE         SAVE IMPORTANT REGISTERS         31170000
         LA    R3,EXCPSAVE             SAVE REGS FOR RESTORING AFTER CL 31180000
         L     R0,TTRN                 LOAD RELATIVE TRACK NUMBER       31190000
         L     R1,DCBDEBAD             LOAD DEB ADDRESS                 31200000
         LA    R2,IOBSEEK              LOAD ADDR TO RECEIVE MBBCCHHR    31210000
         L     R15,CVTPTR              GET ADDRESS OF CVT               31220000
         USING CVT,R15                 CVT ADDRESSABILITY               31230000
         L     R15,CVTPCNVT            GET ADDRESS OF CONVERT ROUTINE   31240000
         DROP  R15                     DROP CVT BASE                    31250000
         BALR  R14,R15                 CONVERT TTRN TO MBBCCHHR         31260000
*                                      THAT CLOBBERED BASE REG          31270000
         LM    R2,R13,0(R3)            RESTORE REGISTERS                31280000
         LTR   R15,R15                 TEST IF EXTENT VIOLATED (RC=4)   31290000
         BNZ   SETEOF                  IF SO, MEANS END-OF-FILE         31300000
         LA    R14,FMT4                                                 31310000
         USING DSCB,R14                                                 31320000
         CLC   DS4HPCHR,IOBSEEK+3      CHECK FOR THE LAST FMT1          31330000
         BL    SETEOF                  IF SO, PRETEND END-OF-FILE       31340000
         DROP  R14                                                      31350000
* ZERO ECB AND START CHANNEL PROGRAM.                                   31360000
         SR    R0,R0                                                    31370000
         ST    R0,VTOCECB              CLEAR ECB                        31380000
         NI    MODESW,X'FF'-RDERR      RESET ERROR SWITCH               31390000
         EXCP  VTOCIOB                 START CHANNEL PROGRAM            31400000
         OI    MODESW,XCPRUN           SET 'RUNNING' FLAG               31410000
         BR    R9                                                       31420000
* WHEN EXTENT IS VIOLATED, SET END-FILE AND EXIT VIA CLOSE ROUTINE.     31430000
SETEOF   OI    MODESW,EOFSW            SET END-OF-FILE BIT              31440000
         B     CLOSESUB                EXIT VIA CLOSE SUBROUTINE        31450000
*********************************************************************** 31460000
* DAIRFAIL ROUTINE                                                    * 31470000
*********************************************************************** 31480000
S99FAIL  LR    R10,R15                 SAVE THE RETURN CODE             31490000
*        S99FAIL MF=(E,S99FLIST,S99FLEN)  ISSUE THE APPROPRIATE MSG     31500000
S99FLEN  EQU   24                      LENGTH OF PARAMETER LIST         31510000
         L     R2,4(,R14)              S99ERROR                         31520007
         LA    R1,S99FLIST        LOAD DAIRFAIL PARAM LIST ADDRESS      31530000
         ST    R14,0(,R1)         STORE S99 RB ADDRESS                  31540000
         LA    R14,20(,R1)        LOAD ADDR RET CODE FLD                31550000
         ST    R15,0(,R14)        STORE RET CODE                        31560000
         ST    R14,4(,R1)         AND STORE ITS ADDRESS                 31570000
         LA    R14,=A(0)          LOAD ADDR OF FULLWORD OF 0            31580000
         ST    R14,8(,R1)         STORE IT.                             31590000
         LA    R14,=X'8032'       LOAD ADDRESS OF CALLERID              31600000
         ST    R14,12(,R1)         AND STORE IT                         31610000
         XC    16(4,R1),16(R1)    CLEAR CPPL POINTER                    31620000
         LINK  EP=IKJEFF18                                              31630000
         LR    R15,R10                 RELOAD THE RETURN CODE           31640000
         L     R1,4(,R13)              Callers save area                31650007
         ST    R2,20(,R1)              Save S99ERROR in R0              31660007
         B     RETURN                  AND THEN EXIT                    31670000
*********************************************************************** 31680000
*        VARIOUS OTHER ERROR ROUTINES                                 * 31690000
*********************************************************************** 31700000
FUNCERR  LA    R15,256                 FUNCTION CODE ERROR              31710000
         B     RETURN                                                   31720000
OPENERR  LA    R15,16                  ERROR OPENING VTOC               31730000
         B     RETURN                                                   31740000
OBTERR   LA    R15,20                  ERROR IN OBTAIN                  31750000
         B     RETURN                                                   31760000
NOTFMT4  LA    R15,24                  1ST DSCB NOT FMT4                31770000
         B     RETURN                                                   31780000
DSCBNUM0 LA    R15,28                  FMT4 HAS 0 DSCBS/TRK             31790000
         B     RETURN                                                   31800000
ERRJFCB  LA    R15,32                  RDJBCB IN ERROR                  31810000
         B     RETURN                                                   31820000
         DROP R11                                                       31830000
         DROP R12                                                       31840000
         DROP R13                                                       31850000
*********************************************************************** 31860000
* CONSTANTS, VARIABLES, ETC...                                        * 31870000
*********************************************************************** 31880000
INITCCW  CCW   READR0,0,CC+SLI+SKIP,8                                   31890000
READCCW  CCW   READCKD,0,CC,148                                         31900000
DSCBCON  CAMLST SEEK,0,0,0   FILLED IN WITH IOBSEEK+3, VOLID, FMT4      31910000
*********************************************************************** 31920000
* DATA CONTROL BLOCK                                                  * 31930000
*********************************************************************** 31940000
VTOCDCBM DCB   DDNAME=VTOCDD,MACRF=(E),EXLST=1                          31950000
DCBLEN   EQU   *-VTOCDCBM                                               31960000
*********************************************************************** 31970000
* IOB FOR CHANNEL PROGRAM                                             * 31980000
*********************************************************************** 31990000
IOBCONST DS    0D                                                       32000000
         DC    X'42000000'     COMMAND CHAIN, NOT RELATED               32010000
         DC    A(0)            ECB ADDRESS                              32020000
         DC    2F'0'                                                    32030000
         DC    A(0)            CHANNEL PROGRAM BEGINNING                32040000
         DC    A(0)            DCB ADDRESS                              32050000
         DC    X'03000000'                                              32060000
         DC    F'0'                                                     32070000
         DC    D'0'            INITIAL SEEK ADDRESS                     32080000
IOBCONL  EQU   *-IOBCONST                                               32090000
*********************************************************************** 32100000
* VTOC NAME FOR ALLOCATION                                            * 32110000
*********************************************************************** 32120000
VTOCNM   DC    A(VTOCNAME)                                              32130000
         DC    Y(12)                                                    32140000
VTOCNAME DC    CL12'FORMAT4.DSCB'   DATA SET NAME FOR VTOC              32150000
         LTORG                                                          32160000
         DC    (((((*-UTS07)/256)+1)*256)-(*-UTS07))X'00'               32170000
*********************************************************************** 32180000
* TAGS FOR CHANNEL COMMANDS AND FLAG BITS:                            * 32190000
*********************************************************************** 32200000
READR0   EQU   X'16'           READ RECORD 0                            32210000
READCKD  EQU   X'1E'           READ COUNT, KEY, AND DATA                32220000
CC       EQU   X'40'           COMMAND CHAIN FLAG                       32230000
SLI      EQU   X'20'           SUPPRESS LENGTH INDICATION FLAG          32240000
SKIP     EQU   X'10'           SKIP DATA TRANSFER FLAG                  32250000
*********************************************************************** 32260000
*        AREA USED BY VTOCREAD, PASSED VIA R13                        * 32270000
*********************************************************************** 32280000
VTOCWORK DSECT                                                          32290000
         DS    18F             SAVE AREA                                32300000
EXCPSAVE DS    18F             INTERNAL SAVE AREA                       32310000
CBSIZE   DS    2F              SIZE AND LOCATION OF GOTTEN CORE         32320000
CBADDR   EQU   CBSIZE+4                                                 32330000
NDSCBS   DS    F               NUMBER OF DSCB'S PER TRACK               32340000
DSCBSTRT DS    F               ADDRESS OF 1ST DSCB BUFFER               32350000
DSCBLIM  DS    F               ADDRESS OF LAST DSCB BUFFER              32360000
DSCBADR  DS    F               ADDRESS OF CURRENT DSCB                  32370000
TTRN     DS    F               RELATIVE TRACK NUMBER                    32380000
VOLADDR  DS    A               FAKE PDL FOR ALLOC MACRO - ADDRESS       32390000
VOLLEN   DS    H                       AND LENGTH OF VOLID              32400000
DDNPDL   DS    2F            SPACE FOR DDNAME PDL                       32410000
*********************************************************************** 32420000
* MODE SWITCH AND BIT DEFINITIONS                                     * 32430000
*********************************************************************** 32440000
MODESW   DC    X'00'                                                    32450000
CBGOT    EQU   X'80'           CORE GOTTEN FOR BUFFER                   32460000
XCPRUN   EQU   X'40'           CHANNEL PROGRAM STARTED BUT NOT CHECKED  32470000
RDERR    EQU   X'20'           PERMANENT I/O ERROR                      32480000
EOFSW    EQU   X'10'           END-OF-FILE SENSED                       32490000
ALLOCSW  EQU   X'08'           ALLOCATE VOLUME FLAG                     32500000
*********************************************************************** 32510000
*  VTOC DCB                                                           * 32520000
*********************************************************************** 32530000
VTOCDCB  DCB   DDNAME=VTOCDD,MACRF=(E),EXLST=1                          32540000
OPENLIST DS    2F                                                       32550000
*********************************************************************** 32560000
* IOB FOR CHANNEL PROGRAM                                             * 32570000
*********************************************************************** 32580000
VTOCIOB  DS    0D                                                       32590000
IOBFLAG1 DC    X'42000000'     COMMAND CHAIN, NOT RELATED               32600000
IOBECB   DC    A(VTOCECB)                                               32610000
         DC    2F'0'                                                    32620000
IOBSTART DC    A(0)            CHANNEL PROGRAM BEGINNING                32630000
IOBDCB   DC    A(VTOCDCB)                                               32640000
         DC    X'03000000'                                              32650000
         DC    F'0'                                                     32660000
IOBSEEK  DC    D'0'            INITIAL SEEK ADDRESS                     32670000
*********************************************************************** 32680000
* EVENT CONTROL BLOCK FOR CHANNEL PROGRAM:                            * 32690000
*********************************************************************** 32700000
VTOCECB  DC    F'0'            EVENT CONTROL BLOCK                      32710000
*********************************************************************** 32720000
* INTERNAL BUFFERS FOR DSCBS                                          * 32730000
*********************************************************************** 32740000
BUFF     DS    XL148                                                    32750000
FMT4     DS    XL44                                                     32760000
FMT4DSCB DS    XL96                    IECSDSL1 4                       32770000
FMT3     DS    0XL138                                                   32780000
FMT3DSCB DS    XL140                   IECSDSL1 3                       32790000
*********************************************************************** 32800000
* SEEK CAMLST                                                         * 32810000
*********************************************************************** 32820000
DSCBFMT4 CAMLST SEEK,IOBSEEK+3,VOLID,FMT4                               32830000
*********************************************************************** 32840000
*   WORK AREA FOR DYNAMIC ALLOCATION                                  * 32850000
*********************************************************************** 32860000
DYNSP1   DS    0F,CL144                DYNSPACE                         32870000
S99FLIST DS    XL(S99FLEN)                                              32880000
*********************************************************************** 32890000
*        JFCB EXIT LIST AND AREA                                      * 32900000
*********************************************************************** 32910000
JEXLST   DS    F                                                        32920000
JFCBAREA DS    XL176                                                    32930000
         DS    0D                                                       32940000
VTOCWLEN EQU   *-VTOCWORK                                               32950000
*********************************************************************** 32960000
*   COMMON AREA                                                       * 32970000
*********************************************************************** 32980000
VTOCOM   DSECT                                                          32990000
VTCEFUNC DC    A(0)                                                     33000000
DSCBADDR DC    A(0)                                                     33010000
VTOCWRK  DC    A(0)                                                     33020000
VOLID    DC    CL6' '                                                   33030000
UNITID   DC    CL8' '                                                   33040007
*********************************************************************** 33050000
*  DSECT TO MAP SVC 99 DATA                                           * 33060000
*********************************************************************** 33070000
DYN1DS   DSECT                         DSECT TO MAP SVC 99 DATA         33080000
DYN1RBP   DS   F                       SVC 99 REQ BLOCK POINTER         33090000
DYN1RB    DS   5F                      SVC 99 REQUEST BLOCK             33100000
DYN1TUP   DS   CL20                    SPACE FOR TEXT POINTERS          33110000
DYN1TU    DS   CL100                   SPACE FOR TEXT UNITS             33120000
DYN1LEN   EQU  *-DYN1RBP               LENGTH OF SPACE USED             33130000
*********************************************************************** 33140000
*  DSECT TO MAP SVC 99 DATA                                           * 33150000
*********************************************************************** 33160000
DYN2DS   DSECT                                                          33170000
DYN2RBP   DS   F                       SVC 99 REQ BLOCK POINTER         33180000
DYN2RB    DS   5F                      SVC 99 REQUEST BLOCK             33190000
DYN2TUP   DS   CL8                     SPACE FOR TEXT POINTERS          33200000
DYN2TU    DS   CL18                    SPACE FOR TEXT UNITS             33210000
DYN2LEN   EQU  *-DYN2RBP               LENGTH OF SPACE USED             33220000
*********************************************************************** 33230000
*        Register Equates                                             * 33240000
*********************************************************************** 33250000
R0       EQU   0                  SYSTEMS                               33260000
R1       EQU   1                  SYSTEMS                               33270000
R2       EQU   2                  WORK & TEMP                           33280000
R3       EQU   3                  WORK & TEMP                           33290000
R4       EQU   4                  WORK & TEMP                           33300000
R5       EQU   5                  WORK & TEMP                           33310000
R6       EQU   6                  BASE REGISTER FOR PROGRAM             33320000
R7       EQU   7                  BASE TABLE                            33330000
R8       EQU   8                  BASE THIS CSECT                       33340000
R9       EQU   9                  BASE UCB DSECT                        33350000
R10      EQU   10                 BASE DSCB DSECT                       33360000
R11      EQU   11                 BASE UCB TABLE DSECT                  33370000
R12      EQU   12                                                       33380000
R13      EQU   13                 SAVE                                  33390000
R14      EQU   14                 RETURN                                33400000
R15      EQU   15                 REGISTER ASSIGNMENTS                  33410000
*********************************************************************** 33420000
*        DSECTs                                                       * 33430000
*********************************************************************** 33440000
         CVT   LIST=NO,DSECT=YES                                        33450000
********************************************************************    33460000
DSCB     DSECT ,                                                        33470000
         IECSDSL1 1                                                     33480000
         ORG   DSCB                                                     33490000
********************************************************************    33500000
         IECSDSL1 2                                                     33510000
         ORG   DSCB                                                     33520000
********************************************************************    33530000
         IECSDSL1 3                                                     33540000
         ORG   DSCB                                                     33550000
********************************************************************    33560000
         DS    CL44                                                     33570000
         IECSDSL1 4                                                     33580000
         ORG   DSCB                                                     33590000
********************************************************************    33600000
         IECSDSL1 5                                                     33610000
         ORG   DSCB                                                     33620000
********************************************************************    33630000
         IECSDSL1 6                                                     33640000
DSCBLEN  EQU   *-DSCB                                                   33650000
********************************************************************    33660000
UCB      DSECT    ,                                                     33670000
         IEFUCBOB ,                                                     33680000
********************************************************************    33690000
         IEFZB4D0 ,                                                     33700000
********************************************************************    33710000
         IEFZB4D2 ,                                                     33720000
********************************************************************    33730000
         DCBD  DEVD=DA,DSORG=PS                                         33740000
********************************************************************    33750000
JFCB     DSECT    ,                                                     33760000
         IEFJFCBN ,                                                     33770000
********************************************************************    33780000
TIOT     DSECT    ,                                                     33790000
         IEFTIOT1 ,                                                     33800000
         IKJTCB   ,                                                     33810000
         END   FMTVTOC                                                  33820000
