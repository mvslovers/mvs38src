         MACRO                                                          00010000
         BLKCVT &DATA,&NAME                                             00020000
         GBLA  &HEX                                                     00030000
         LCLC  &CH                                                      00040000
         LCLA  &N                                                       00050000
&HEX     SETA  0                                                        00060000
         AIF   ('&DATA'(1,1) NE '-').LOOP                               00070000
&N       SETA  1                                                        00080000
.LOOP    AIF   (&N GE K'&DATA).DONE                                     00090000
&N       SETA  &N+1                                                     00100000
&CH      SETC  '&DATA'(&N,1)                                            00110000
         AIF   ('&CH' GE '0').ZEROTO9                                   00120000
         AIF   ('&CH' EQ 'A').AX                                        00130000
         AIF   ('&CH' EQ 'B').BX                                        00140000
         AIF   ('&CH' EQ 'C').CX                                        00150000
         AIF   ('&CH' EQ 'D').DX                                        00160000
         AIF   ('&CH' EQ 'E').EX                                        00170000
         AIF   ('&CH' EQ 'F').FX                                        00180000
         MNOTE 12,'&DATA field not hex number'                          00190000
&HEX     SETA  0                                                        00200000
         MEXIT                                                          00210000
.ZEROTO9 ANOP                                                           00220000
&HEX     SETA  &HEX*16+&CH                                              00230000
         AGO   .LOOP                                                    00240000
.AX      ANOP                                                           00250000
&HEX     SETA  &HEX*16+X'A'                                             00260000
         AGO   .LOOP                                                    00270000
.BX      ANOP                                                           00280000
&HEX     SETA  &HEX*16+X'B'                                             00290000
         AGO   .LOOP                                                    00300000
.CX      ANOP                                                           00310000
&HEX     SETA  &HEX*16+X'C'                                             00320000
         AGO   .LOOP                                                    00330000
.DX      ANOP                                                           00340000
&HEX     SETA  &HEX*16+X'D'                                             00350000
         AGO   .LOOP                                                    00360000
.EX      ANOP                                                           00370000
&HEX     SETA  &HEX*16+X'E'                                             00380000
         AGO   .LOOP                                                    00390000
.FX      ANOP                                                           00400000
&HEX     SETA  &HEX*16+X'F'                                             00410000
         AGO   .LOOP                                                    00420000
.DONE    AIF   ('&DATA'(1,1) NE '-').MEND                               00430000
&HEX     SETA  0-&HEX                                                   00440000
.MEND    MEND                                                           00450000
         MACRO                                                          00460000
&LBL     BLKENT2 &TTL,&TYPE,&OFF,&LEN,&DIGIT=0,&NEWLIN=NO               00470000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             00480000
         LCLA  &IOFF,&ILEN,&MAX,&WRKOFF                                 00490000
         LCLC  &LENSAV,&LNSV                                            00500000
         AIF   ('&TYPE' EQ 'HEX').LBLHEX                                00510000
         AIF   (T'&LBL NE 'O').LBLERA1                                  00520000
.LBLHEX  ANOP                                                           00530000
&MAX     SETA  120                                                      00540000
         AIF   ('&NEWLIN' EQ 'yes').NEWLIN                              00550000
         AIF   ('&NEWLIN' NE 'YES').SAMLIN                              00560000
.NEWLIN  ANOP                                                           00570000
&SETOFF  SETA  0                                                        00580000
.SAMLIN  ANOP                                                           00590000
         DC    AL1(BLKCONST)       Constant                             00600000
&ILEN    SETA  K'&TTL-3                                                 00610000
&WRKOFF  SETA  &SETOFF+&ILEN+2                                          00620000
         AIF   ('&LEN'(1,1) LT '0').DONEW                               00630000
         BLKCVT &LEN                                                    00640000
&WRKOFF  SETA  &WRKOFF+&HEX+2                                           00650000
         AIF   (&WRKOFF LT &MAX).NONEW                                  00660000
.DONEW   ANOP                                                           00670000
&SETOFF  SETA  0                                                        00680000
.NONEW   ANOP                                                           00690000
         DC    AL1(&SETOFF)        Offset to output                     00700000
         DC    AL1(&ILEN)          Length                               00710000
&ILEN    SETA  &ILEN+1                                                  00720000
         DC    CL&ILEN&TTL         Character constant                   00730000
&SETOFF  SETA  &SETOFF+&ILEN+1                                          00740000
&ILEN    SETA  &ILEN-1                                                  00750000
&LENSAV  SETC  ''                                                       00760000
         AIF   (T'&LBL EQ 'O').NXTCHK                                   00770000
         AIF   ('&LBL' LT '1').LBLERA                                   00780000
         AIF   ('&LBL' GT '7').LBLERA                                   00790000
.NXTCHK  ANOP                                                           00800000
         AIF   ('&OFF' EQ '.NEXT').NEXT                                 00810000
         BLKCVT &OFF               Convert offset from hex              00820000
&IOFF    SETA  &HEX-&SEGOFF                                             00830000
         AGO   .LBLCHK                                                  00840000
.NEXT    ANOP                                                           00850000
&LENSAV  SETC  'X''8000''+'                                             00860000
&IOFF    SETA  0                                                        00870000
.LBLCHK  ANOP                                                           00880000
         AIF   (T'&LBL EQ 'O').LENDONE                                  00890000
&LENSAV  SETC  'X''8000''+X''&LBL.000''+'                               00900000
.LENDONE ANOP                                                           00910000
         AIF   ('&OFF' EQ '.NEXT').OFFDONE                              00920000
         AIF   (&HEX LT &SEGOFF).OFFLOW1 If before block start          00930000
         AIF   (&HEX GT &SEGEND).OFFHI1 If after block end              00940000
.OFFDONE ANOP                                                           00950000
         AIF   ('&TYPE' NE 'HEX').NOHEX If not hex                      00960000
         AIF   ('&DIGIT' NE '0' AND '&DIGIT' NE '1').BADDIG1            00970000
         DC    AL1(BLKHEX)         Hex field                            00980000
         DC    AL1(&SETOFF)        Offset to output                     00990000
         DC    AL2(&LENSAV&IOFF)   Field offset                         01000000
         DC    AL1(&DIGIT)         Digit offset                         01010000
         AGO   .DOLEN                                                   01020000
.NOHEX   AIF   ('&TYPE' NE 'CHAR').NOCHR If not character               01030000
         DC    AL1(BLKCHAR)        Character field                      01040000
         DC    AL1(&SETOFF)        Offset to output                     01050000
         DC    AL2(&LENSAV&IOFF)   Field offset                         01060000
         AGO   .DOLEN                                                   01070000
.NOCHR   AIF   ('&TYPE' NE 'TABLE').NOTYPE If not character             01080000
         DC    AL1(BLKTBL)         Table definition                     01090000
         DC    AL1(&SETOFF)        Offset to output                     01100000
         DC    AL4(&LEN)           Address of table definition          01110000
         MEXIT                                                          01120000
.DOLEN   ANOP                                                           01130000
         AIF   ('&LEN'(1,1) LT '0').CHRSCN1                             01140000
         BLKCVT &LEN               Validate length                      01150000
&ILEN    SETA  &HEX-1              Get machine length                   01160000
         DC    AL2(&ILEN)          Length                               01170000
         AGO   .SETOFF                                                  01180000
.CHRSCN1 ANOP  ,                                                        01190000
         AIF   ('&LEN'(1,1) EQ '(').GETLBL1                             01200000
         DC    SL2(&LEN)           Length                               01210000
         AGO   .LENEND                                                  01220000
.GETLBL1 ANOP                                                           01230000
         AIF   ('&LEN'(2,1) LT '1').LBLERA                              01240000
         AIF   ('&LEN'(2,1) GT '7').LBLERA                              01250000
         AIF   ('&LEN'(3,1) NE ')').LBLERA                              01260000
&LNSV    SETC  'W#L'.'&LEN'(2,1)                                        01270000
         DC    SL2(&LNSV)                                               01280000
.LENEND  ANOP                                                           01290000
&ILEN    SETA  1                   Fake length                          01300000
.SETOFF  ANOP                                                           01310000
&SETOFF  SETA  &SETOFF+&ILEN+2                                          01320000
         AIF   (&SETOFF GT &MAX).NEEDNEW                                01330000
         MEXIT                                                          01340000
.NOTYPE  MNOTE 8,'Type missing of invalid'                              01350000
         MEXIT                                                          01360000
.BADDIG1 MNOTE 8,'Digit not 0 or 1'                                     01370000
         MEXIT                                                          01380000
.OFFLOW1 MNOTE 8,'Offset to low'                                        01390000
         MEXIT                                                          01400000
.OFFHI1  MNOTE 8,'Offset to high'                                       01410000
         MEXIT                                                          01420000
.LBLERA  MNOTE 8,'Label must be 0, 1, 2 or 3'                           01430000
         MEXIT                                                          01440000
.LBLERA1 MNOTE 8,'Label only valid with TYPE HEX'                       01450000
         MEXIT                                                          01460000
.NEEDNEW MNOTE 4,'Need NEWLIN=YES, max output area exceeded'            01470000
         MEND                                                           01480000
         MACRO                                                          01490000
         BLKEND                                                         01500000
         DC    AL1(BLKEND)         End of block descriptor              01510000
         MEND                                                           01520000
         MACRO                                                          01530000
&LBL     BLKENT &TYPE,&OFF,&LEN,&DIGIT=0,&NEWLIN=NO                     01540000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             01550000
         LCLA  &IOFF,&ILEN,&MAX,&WRKOFF                                 01560000
         LCLC  &LENSAV,&LNSV                                            01570000
         AIF   ('&TYPE' EQ 'HEX').LBLHEX                                01580000
         AIF   (T'&LBL NE 'O').LBLERB1                                  01590000
.LBLHEX  ANOP                                                           01600000
&MAX     SETA  120                                                      01610000
         AIF   ('&NEWLIN' EQ 'YES').DONEW                               01620000
         AIF   ('&NEWLIN' EQ 'yes').DONEW                               01630000
         AIF   ('&TYPE' NE 'LABEL').NLB                                 01640000
&WRKOFF  SETA  &SETOFF+K'&OFF-1                                         01650000
         AGO   .CHK                                                     01660000
.NLB     ANOP                                                           01670000
         AIF   ('&LEN'(1,1) LT '0').DONEW                               01680000
         BLKCVT &LEN                                                    01690000
&WRKOFF  SETA  &SETOFF+&HEX+2                                           01700000
.CHK     ANOP                                                           01710000
         AIF   (&WRKOFF LT &MAX).NONEW                                  01720000
.DONEW   ANOP                                                           01730000
&SETOFF  SETA  0                                                        01740000
.NONEW   ANOP                                                           01750000
         AIF   ('&TYPE' NE 'LABEL').NOLABEL If not a label              01760000
         DC    AL1(BLKCONST)       Constant                             01770000
&ILEN    SETA  K'&OFF-3                                                 01780000
         DC    AL1(&SETOFF)        Offset to output                     01790000
         DC    AL1(&ILEN)          Length                               01800000
&ILEN    SETA  &ILEN+1                                                  01810000
         DC    CL&ILEN&OFF         Character constant                   01820000
&ILEN    SETA  &ILEN-1                                                  01830000
         AGO   .SETOFF                                                  01840000
.NOLABEL ANOP                                                           01850000
&LENSAV  SETC  ''                                                       01860000
         AIF   (T'&LBL EQ 'O').NXTCHK                                   01870000
         AIF   ('&LBL' LT '1').LBLERB                                   01880000
         AIF   ('&LBL' GT '7').LBLERB                                   01890000
.NXTCHK  ANOP                                                           01900000
         AIF   ('&OFF' EQ '.NEXT').NEXT                                 01910000
         BLKCVT &OFF               Convert offset from hex              01920000
&IOFF    SETA  &HEX-&SEGOFF                                             01930000
         AGO   .LBLCHK                                                  01940000
.NEXT    ANOP                                                           01950000
&LENSAV  SETC  'X''8000''+'                                             01960000
&IOFF    SETA  0                                                        01970000
.LBLCHK  ANOP                                                           01980000
         AIF   (T'&LBL EQ 'O').LENDONE                                  01990000
&LENSAV  SETC  'X''8000''+X''&LBL.000''+'                               02000000
.LENDONE ANOP                                                           02010000
         AIF   ('&OFF' EQ '.NEXT').OFFDONE                              02020000
         AIF   (&HEX LT &SEGOFF).OFFLOW2 If before block start          02030000
         AIF   (&HEX GT &SEGEND).OFFHI2 If after block end              02040000
.OFFDONE ANOP                                                           02050000
         AIF   ('&TYPE' NE 'HEX').NOHEX If not hex                      02060000
         AIF   ('&DIGIT' NE '0' AND '&DIGIT' NE '1').BADDIG2            02070000
         DC    AL1(BLKHEX)         Hex field                            02080000
         DC    AL1(&SETOFF)        Offset to output                     02090000
         DC    AL2(&LENSAV&IOFF)   Field offset                         02100000
         DC    AL1(&DIGIT)         Digit offset                         02110000
         AGO   .DOLEN                                                   02120000
.NOHEX   AIF   ('&TYPE' NE 'CHAR').NOTYPE If not character              02130000
         DC    AL1(BLKCHAR)        Character field                      02140000
         DC    AL1(&SETOFF)        Offset to output                     02150000
         DC    AL2(&LENSAV&IOFF)   Field offset                         02160000
.DOLEN   ANOP                                                           02170000
         AIF   ('&LEN'(1,1) LT '0').CHRSCN2                             02180000
         BLKCVT &LEN               Validate length                      02190000
&ILEN    SETA  &HEX-1              Get machine length                   02200000
         DC    AL2(&ILEN)          Length                               02210000
         AGO   .SETOFF                                                  02220000
.CHRSCN2 ANOP  ,                                                        02230000
         AIF   ('&LEN'(1,1) EQ '(').GETLBL2                             02240000
         DC    SL2(&LEN)           Length                               02250000
         AGO   .LENEND                                                  02260000
.GETLBL2 ANOP                                                           02270000
         AIF   ('&LEN'(2,1) LT '1').LBLERB                              02280000
         AIF   ('&LEN'(2,1) GT '7').LBLERB                              02290000
         AIF   ('&LEN'(3,1) NE ')').LBLERB                              02300000
&LNSV    SETC  'W#L'.'&LEN'(2,1)                                        02310000
         DC    SL2(&LNSV)                                               02320000
.LENEND  ANOP                                                           02330000
&ILEN    SETA  1                   Fake length                          02340000
.SETOFF  ANOP                                                           02350000
&SETOFF  SETA  &SETOFF+&ILEN+2                                          02360000
         AIF   (&SETOFF GT &MAX).NEEDNEX                                02370000
         MEXIT                                                          02380000
.NOTYPE  MNOTE 8,'Type missing of invalid'                              02390000
         MEXIT                                                          02400000
.BADDIG2 MNOTE 8,'Digit not 0 or 1'                                     02410000
         MEXIT                                                          02420000
.OFFLOW2 MNOTE 8,'Offset to low'                                        02430000
         MEXIT                                                          02440000
.OFFHI2  MNOTE 8,'Offset to high'                                       02450000
         MEXIT                                                          02460000
.LBLERB  MNOTE 8,'Label must be 0, 1, 2 or 3'                           02470000
         MEXIT                                                          02480000
.LBLERB1 MNOTE 8,'Label only valid with TYPE HEX'                       02490000
         MEXIT                                                          02500000
.NEEDNEX MNOTE 4,'Need NEWLIN=YES, max output area exceeded'            02510000
         MEND                                                           02520000
         MACRO                                                          02530000
&N       BLKBGN &OFF=,&LEN=                                             02540000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             02550000
         LCLC  &SEGSTR                                                  02560000
&SETOFF  SETA  0                                                        02570000
&N       DC    0D'0'                                                    02580000
         AIF   ('&OFF' EQ 'PASS').NOSIGN                                02590000
         BLKCVT &OFF,OFF                                                02600000
&SEGOFF  SETA  &HEX                                                     02610000
&SEGSTR  SETC  '&HEX'                                                   02620000
         AIF   (&HEX GE 0).NOSIGN                                       02630000
&SEGSTR  SETC  '-'.'&HEX'                                               02640000
.NOSIGN  ANOP                                                           02650000
         BLKCVT &LEN,LEN                                                02660000
         AIF   ('&OFF' EQ 'PASS').VAR                                   02670000
&SEGEND  SETA  &HEX+&SEGSTR                                             02680000
         DC    AL2(&SEGSTR)        Start offset                         02690000
         AGO   .NOVAR                                                   02700000
.VAR     ANOP                                                           02710000
         DC    AL2(X'8000'+&HEX)   Start offset                         02720000
.NOVAR   ANOP                                                           02730000
         DC    AL2(&HEX)           Block length                         02740000
.MEND    MEND                                                           02750000
*                                                                       02760000
*                                                                       02770000
*                                                                       02780000
         MACRO ,                                                        02790000
         BLKFLG &FLAG,&DESC,&OFF                                        02800000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             02810000
         LCLA  &WRKOFF,&ILEN                                            02820000
         LCLC  &FLG,&BLKID                                              02830000
         AIF   (N'&FLAG  EQ 1).FLGTM                                    02840000
         AIF   (K'&FLAG(1) NE 2).ERR1A                                  02850000
         AIF   (K'&FLAG NE 8).ERR1A                                     02860000
         AIF   ('&FLAG'(5,3) NE 'CLI').ERR1A                            02870000
&FLG     SETC  '&FLAG'(2,2)                                             02880000
         AIF   ('&FLG'(1,1) GT '9').ERR1B                               02890000
         AIF   ('&FLG'(1,1) GE '0').FLAGOK1                             02900000
         AIF   ('&FLG'(1,1) GT 'F').ERR1B                               02910000
         AIF   ('&FLG'(1,1) LT 'A').ERR1B                               02920000
.FLAGOK1 ANOP  ,                                                        02930000
         AIF   ('&FLG'(2,1) GT '9').ERR1B                               02940000
         AIF   ('&FLG'(2,1) GE '0').FLAGOK2                             02950000
         AIF   ('&FLG'(2,1) GT 'F').ERR1B                               02960000
         AIF   ('&FLG'(2,1) LT 'A').ERR1B                               02970000
.FLAGOK2 ANOP  ,                                                        02980000
&BLKID   SETC  'BLKFLAG+1'                                              02990000
         AGO   .FLAGOK                                                  03000000
.FLGTM   ANOP  ,                                                        03010000
&FLG     SETC  '&FLAG'                                                  03020000
&BLKID   SETC  'BLKFLAG'                                                03030000
         AIF   (K'&FLAG NE 2).ERR1                                      03040000
         AIF   ('&FLAG' EQ '80').FLAGOK                                 03050000
         AIF   ('&FLAG' EQ '40').FLAGOK                                 03060000
         AIF   ('&FLAG' EQ '20').FLAGOK                                 03070000
         AIF   ('&FLAG' EQ '10').FLAGOK                                 03080000
         AIF   ('&FLAG' EQ '08').FLAGOK                                 03090000
         AIF   ('&FLAG' EQ '04').FLAGOK                                 03100000
         AIF   ('&FLAG' EQ '02').FLAGOK                                 03110000
         AIF   ('&FLAG' EQ '01').FLAGOK                                 03120000
         AGO   .ERR1B                                                   03130000
.FLAGOK  ANOP  ,                                                        03140000
         AIF   (T'&DESC EQ 'O').ERR3                                    03150000
         AIF   (T'&OFF NE 'N').ERR41                                    03160000
&ILEN    SETA  K'&DESC-3                                                03170000
&WRKOFF  SETA  &OFF+&ILEN                                               03180000
         AIF   (&WRKOFF GT 132).ERR42                                   03190000
&SETOFF  SETA  &OFF                                                     03200000
         DC    AL1(&BLKID)         Flag definition                      03210000
         DC    AL1(&SETOFF)        Offset to output                     03220000
         DC    XL1'&FLG'           Flag string                          03230000
         DC    AL1(&ILEN)          Flag description length -1           03240000
&ILEN    SETA  &ILEN+1                                                  03250000
         DC    CL&ILEN&DESC        Flag description                     03260000
         AGO   .MEXIT                                                   03270000
.ERR1    ANOP  ,                                                        03280000
         MNOTE 8,'Flag (1st operand) not two characters'                03290000
         AGO   .MEXIT                                                   03300000
.ERR1A   ANOP  ,                                                        03310000
         MNOTE 8,'Flag (1st operand) not (xx,CLI)'                      03320000
         AGO   .MEXIT                                                   03330000
.ERR1B   ANOP  ,                                                        03340000
         MNOTE 8,'Flag (1st operand) invalid - &FLG'                    03350000
         AGO   .MEXIT                                                   03360000
.ERR3    ANOP  ,                                                        03370000
         MNOTE 8,'Description (2nd operand) requited'                   03380000
         AGO   .MEXIT                                                   03390000
.ERR41   ANOP  ,                                                        03400000
         MNOTE 8,'Print line offset (3rd operand) invalid'              03410000
         AGO   .MEXIT                                                   03420000
.ERR42   ANOP  ,                                                        03430000
         MNOTE 8,'Print line offset (3rd operand) to large &WRKOFF'     03440000
         AGO   .MEXIT                                                   03450000
.MEXIT   ANOP  ,                                                        03460000
         MEND  ,                                                        03470000
*********************************************************************** 03480000
*                                                                     * 03490000
* Module name                                                         * 03500000
*    FMTDIR24                                                         * 03510000
*                                                                     * 03520000
* Attributes                                                          * 03530000
*    None                                                             * 03540000
*                                                                     * 03550000
* Author                                                              * 03560000
*    Dave Kreiss                                                      * 03570000
*                                                                     * 03580000
* Function                                                            * 03590000
*    Format directory entries in a PDS                                * 03600000
*                                                                     * 03610000
* JCL                                                                 * 03620000
*    //FMT     EXEC PGM=FMTDIR24,PARM='Parameters'                    * 03630000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 03640000
*    //SYSPRINT DD  SYSOUT=*                                          * 03650000
*    //SYSUT1   DD  DSN=MVSSRC.BLD.MVSSRC,DISP=SHR                    * 03660000
*                                                                     * 03670000
* DD Statements                                                       * 03680000
*    STEPLIB       Load library containing program.                   * 03690000
*    SYSPRINT      Contains report of SSI removal process.            * 03700000
*    SYSUT1        Data set containng library.                        * 03710000
*                                                                     * 03720000
* Parameters                                                          * 03730000
*    All parameters are seperated by commas.                          * 03740000
*    DEBUG          Dumps the directory blocks as read.               * 03750000
*    DUMP           Dumps each directory entry.                       * 03760000
*    FORMAT         Formats each directory entry.                     * 03770000
*                                                                     * 03780000
* Return codes                                                        * 03790000
*    0              Successfully passed input soruce library,         * 03800000
*    8              An error occured see SYSPRINT.                    * 03810000
*                                                                     * 03820000
*********************************************************************** 03830000
*                                                                     * 03840000
* CHANGE LOG:                                                         * 03850000
*   Date     INT VV.RR Description                                    * 03860000
* 05/28/2020 DSK 01.00 Created                                        * 03870000
         LCLC   &VER                                                    03880000
&VER     SETC   '01.00'                                                 03890000
*                                                                     * 03900000
*********************************************************************** 03910000
FMTDIR24 CSECT                                                          03920000
         USING FMTDIR24,R15                                             03930000
         B     START                   Skip program id                  03940000
         DROP  R15                                                      03950000
         DC    AL1(L'PGMID)                                             03960000
PGMID    DC    C'FMTDIR24 - &VER &SYSDATE &SYSTIME'                     03970000
*********************************************************************** 03980000
*        Initialization                                               * 03990000
*********************************************************************** 04000000
START    STM   R14,R12,12(R13)         Save registers                   04010000
         LR    R12,R15                 Set base                         04020000
         USING FMTDIR24,R12                                             04030000
         LR    R15,R13                 Save callers save area addr      04040000
         L     R13,=A(SAVEAREA)        Our svae area                    04050000
         USING SAVEAREA,R13                                             04060000
         ST    R15,SAVEAREA+4          Save prev save area addr         04070000
         ST    R13,8(,R15)             Save my save area addr           04080000
         BAL   R14,INIT                Initialization                   04090000
         LTR   R15,R15                 Was it successful?               04100000
         BNZ   ERRORXIT                No, error message issued         04110000
*********************************************************************** 04120000
*        Preload directory since STOW will change directory blocks    * 04130000
*********************************************************************** 04140000
         LA    R2,INSTGDIR             Beginning of in storage dir      04150000
READDIR  DS    0H                                                       04160000
         READ  DIRDECB,SF,DIRDCB,DIRENT,MF=E Read directory block       04170000
         CHECK DIRDECB                 Check for I/O completion         04180000
         AP    DIRCNT,=P'+1'           Count blocks                     04190000
         TM    FLAG,FLAGDBG                                             04200000
         BNO   NDBG010                                                  04210000
           BAL   R14,PRT                                                04220000
           MVC   W#LINE+1(15),=C'Directory block'                       04230000
           MVC   W#LINE+16(10),=X'40206B2020206B202120' Edit mask       04240000
           ED    W#LINE+16(10),DIRCNT                                   04250000
           BAL   R14,PRT                                                04260000
           LA    R0,256                                                 04270000
           LA    R1,DIRENT                                              04280000
           BAL   R14,DMP                                                04290000
           BAL   R14,PRT                                                04300000
NDBG010  DS    0H                                                       04310000
         CP    DIROFL,=P'+0'           We overflow                      04320000
         BNE   READOVR                 Yes, just count                  04330000
         LA    R0,DIRENT               Start of directory block         04340000
         LH    R1,DIRENT               Length of that block             04350000
         LR    R3,R1                   Copy length                      04360000
         L     R15,=A(DIRTBLND)        End of in storage buffer         04370000
         LA    R14,0(R2,R3)            Get where this block ends        04380000
         CR    R14,R15                 Will if fit                      04390000
         BNL   READOVR                 No, lets mark error and continue 04400000
         MVCL  R2,R0                   Copy block to in storage buffer  04410000
         B     READDIR                 Next directory block             04420000
READOVR  DS    0H                                                       04430000
         AP    DIROFL,=P'+1'           Count those that didn't fit      04440000
         B     READDIR                 Next directory block             04450000
*********************************************************************** 04460000
*        Process in storage directory                                 * 04470000
*********************************************************************** 04480000
EOD      DS    0H                                                       04490000
         LR    R11,R2                  End of directory                 04500000
         CP    DIROFL,=P'+0'           In storage buffer overflowed     04510000
         BNE   READOVR                 Yes, issue error messages        04520000
         LA    R10,INSTGDIR            Beginning of instorage directory 04530000
NEXTBLK  DS    0H                                                       04540000
         CR    R10,R11                 We beyond the end                04550000
         BNL   ERRORPRS                Yes, something went wrong        04560000
         LH    R9,0(,R10)              Get no of bytes used in dir blk  04570000
         LA    R8,2                    Set offset to next dir entry     04580000
         AP    DIRUSD,=P'+1'           Count blocks                     04590000
GETMEM   DS    0H                                                       04600000
         AR    R10,R8                  Bump to next dir entry           04610000
         SR    R9,R8                   Calc remaining bytes to process  04620000
         LTR   R9,R9                   End of dir blk                   04630000
         BNH   NEXTBLK                 Yes, get another dir blk         04640000
*********************************************************************** 04650000
*        Process directory entry                                      * 04660000
*********************************************************************** 04670000
         USING DIR,R10                                                  04680000
         CLC   PDS2NAME,=8X'FF'        End of directory                 04690000
         BE    DIRDONE                 Yes                              04700000
         SR    R8,R8                                                    04710000
         IC    R8,PDS2INDC             Get number user data halfwords   04720000
         N     R8,=A(PDS2LUSR)         Clear bits except user data cnt  04730000
         SLL   R8,1                    Convert halfword count to bytes  04740000
         AH    R8,=AL2(PDS2USRD-PDS2NAME) Len of this directory entry   04750000
         AP    MBRCNT,=P'+1'           Count members                    04760000
         MVC   W#LINE+1(8),PDS2NAME    Move member name to print        04770000
* Hex representation                                                    04780000
         LA    R15,PDS2TTRP            Start of directory enry          04790000
         LA    R1,W#LINE+10            Where to format the directory    04800000
         LR    R0,R8                   Copy entry length                04810000
         SH    R0,=AL2(L'PDS2NAME)     Less member name length          04820000
         BZ    LSTEND                  Should not occur                 04830000
         LA    R14,=A(L'PDS2TTRP,L'PDS2INDC,0) TTR, length and rest     04840000
         L     R2,0(,R14)              Get TTR length                   04850000
LSTHDIR  DS    0H                                                       04860000
         UNPK  0(3,R1),0(2,R15)        Format one position              04870000
         TR    0(2,R1),P#HEXTBL-240    Finish convert                   04880000
         MVI   2(R1),C' '              Clear junk form convert          04890000
         AH    R15,=AL2(1)             Next entry position              04900000
         AH    R1,=AL2(2)              Next print position              04910000
         BCT   R2,LSTHNSKP             Loop through formatting          04920000
         AH    R1,=AL2(1)              Skip a position                  04930000
         AH    R14,=AL2(4)             Next length                      04940000
         L     R2,0(,R14)              Get that length                  04950000
LSTHNSKP DS    0H                                                       04960000
         C     R1,=A(W#LINE+130)       End of print line                04970000
         BNL   LSTEND                  Yes, thats all we format         04980000
         BCT   R0,LSTHDIR              Loop throught dir entry          04990000
* Character representation of user data                                 05000000
         LA    R15,PDS2USRD            Start of user data               05010000
         AH    R1,=AL2(2)              Start of character dump          05020000
         C     R1,=A(W#LINE+129)       End of print line                05030000
         BNL   LSTEND                  Yes, thats all we format         05040000
         LR    R0,R8                   Copy entry length                05050000
         SH    R0,=AL2(L'PDS2NAME+L'PDS2TTRP+L'PDS2INDC) User data len  05060000
         BNP   LSTEND                                                   05070000
         MVI   0(R1),C'*'                                               05080000
         AH    R1,=AL2(1)                                               05090000
LSTCDIR  DS    0H                                                       05100000
         MVC   0(1,R1),0(R15)          Format one position              05110000
         TR    0(1,R1),P#TBLCH         Eliminate non-pritables          05120000
         LA    R15,1(,R15)             Next entry position              05130000
         AH    R1,=AL2(1)              Next print position              05140000
         C     R1,=A(W#LINE+130)       End of print line                05150000
         BNL   LSTEND                  Yes, thats all we format         05160000
         BCT   R0,LSTCDIR              Loop through formatting          05170000
         MVI   0(R1),C'*'                                               05180000
LSTEND   DS    0H                                                       05190000
         MVC   W#LINE+1(8),PDS2NAME    Move member name to print        05200000
         BAL   R14,PRT                 Print a line                     05210000
MBRDONE  DS    0H                                                       05220000
         TM    FLAG,FLAGDMP                                             05230000
         BNO   NDBG020                                                  05240000
           BAL   R14,PRT                                                05250000
           MVC   W#LINE+7(30),=C'Directory entry (length=X''00'')'      05260000
           STC   R8,DWORD              Length in hex                    05270000
           UNPK  DWORD+1(3),DWORD(2)   To charactr form                 05280000
           TR    DWORD+1(2),P#HEXTBL-240                                05290000
           MVC   W#LINE+33(2),DWORD+1  Move length to messae            05300000
           BAL   R14,PRT                                                05310000
           LR    R0,R8                 Length                           05320000
           LA    R1,DIR                                                 05330000
           BAL   R14,DMP                                                05340000
           BAL   R14,PRT                                                05350000
NDBG020  DS    0H                                                       05360000
         TM    FLAG,FLAGFMT                                             05370000
         BNO   NDBG030                                                  05380000
           BAL   R14,DIRFMT                                             05390000
           BAL   R14,PRT                                                05400000
NDBG030  DS    0H                                                       05410000
         B     GETMEM                  Next member                      05420000
DIRDONE  DS    0H                                                       05430000
         MVC   W#LINE+1(7),=C'* EOF *'                                  05440000
         UNPK  W#LINE+10(7),PDS2TTRP(4)                                 05450000
         MVI   W#LINE+16,C' '                                           05460000
         TR    W#LINE+10(6),P#HEXTBL-240    Finish convert              05470000
         UNPK  W#LINE+17(3),PDS2INDC(2)                                 05480000
         MVI   W#LINE+19,C' '                                           05490000
         TR    W#LINE+17(2),P#HEXTBL-240    Finish convert              05500000
         BAL   R14,PRT                                                  05510000
         AH    R10,=AL2(L'PDS2NAME+L'PDS2TTRP+L'PDS2INDC)               05520000
*********************************************************************** 05530000
*        Termination                                                  * 05540000
*********************************************************************** 05550000
EXIT     DS    0H                                                       05560000
         MVC   W#LINE+1(16),=C'Directory blocks' Message                05570000
         MVC   W#LINE+21(10),=X'40206B2020206B202120' Edit mask         05580000
         ED    W#LINE+21(10),DIRCNT    Edit count                       05590000
         ZAP   DWORD,DIRCNT            Directory blocks read            05600000
         CVB   R0,DWORD                                                 05610000
         MH    R0,=AL2(256)            Times block size                 05620000
         SRL   R0,10                   Convert to K                     05630000
         CVD   R0,DWORD                Convert to packed                05640000
         MVC   W#LINE+31(10),=X'40206B2020206B202120' Edit mask         05650000
         ED    W#LINE+31(10),DWORD+4   Edit storage                     05660000
         MVC   W#LINE+41(18),=C'K (directory size)' Message             05670000
         BAL   R14,PRT                 Print a line                     05680000
*                                                                       05690000
         MVC   W#LINE+1(14),=C'Directory used' Message                  05700000
         MVC   W#LINE+21(10),=X'40206B2020206B202120' Edit mask         05710000
         ED    W#LINE+21(10),DIRUSD    Edit count                       05720000
         ZAP   DWORD,DIRUSD            Directory blocks used            05730000
         CVB   R0,DWORD                                                 05740000
         MH    R0,=AL2(256)            Times block size                 05750000
         SRL   R0,10                   Convert to K                     05760000
         CVD   R0,DWORD                Convert to packed                05770000
         MVC   W#LINE+31(10),=X'40206B2020206B202120' Edit mask         05780000
         ED    W#LINE+31(10),DWORD+4   Edit storage                     05790000
         MVC   W#LINE+41(18),=C'K (directory used)' Message             05800000
         BAL   R14,PRT                 Print a line                     05810000
*                                                                       05820000
         MVC   W#LINE+1(7),=C'Members' Message                          05830000
         MVC   W#LINE+21(10),=X'40206B2020206B202120' Edit mask         05840000
         ED    W#LINE+21(10),MBRCNT    Edit count                       05850000
         BAL   R14,PRT                 Print a line                     05860000
*                                                                       05870000
         CLOSE (DIRDCB),MF=(E,W#OPEN)                                   05880000
         CLOSE (SYSPRINT),MF=(E,W#OPEN)                                 05890000
         L     R13,SAVEAREA+4          Restore callers save area addr   05900000
         RETURN (14,12),RC=0           Exit program return code 0       05910000
*********************************************************************** 05920000
*        Errors                                                       * 05930000
*********************************************************************** 05940000
ERROROFL DS    0H                                                       05950000
         MVC   W#LINE+1(24),=C'Directory table overflow' Message        05960000
         BAL   R14,PRT                                                  05970000
         MVC   W#LINE+1(16),=C'Directory blocks' Message                05980000
         MVC   W#LINE+21(10),=X'40206B2020206B202120' Edit mask         05990000
         ED    W#LINE+21(10),DIRCNT    Edit count                       06000000
         BAL   R14,PRT                 Print a line                     06010000
         MVC   W#LINE+1(18),=C'Blocks in overflow' Message              06020000
         MVC   W#LINE+21(10),=X'40206B2020206B202120' Edit mask         06030000
         ED    W#LINE+21(10),DIROFL    Edit count                       06040000
         BAL   R14,PRT                 Print a line                     06050000
         LA    R15,8                   Return code                      06060000
         B     ERRORXIT                Error exit                       06070000
ERRORPRS DS    0H                                                       06080000
         MVC   W#LINE+1(37),=C'Error processing in storage directory'   06090000
         BAL   R14,PRT                 Print a line                     06100000
         LA    R15,8                   Return code                      06110000
         B     ERRORXIT                Error exit                       06120000
ERROR004 DS    0H                                                       06130000
         LA    R15,8                   Return code                      06140000
         B     ERRORXIT                Error exit                       06150000
ERROR083 DS    0H                                                       06160000
         MVC   W#LINE+1(17),=C'SYSUT1 DD missing' Message               06170000
         BAL   R14,PRT                 Print a line                     06180000
         LA    R15,8                   Return code                      06190000
ERRORXIT DS    0H                                                       06200000
         L     R13,SAVEAREA+4          Restore callers save area addr   06210000
         RETURN (14,12),RC=(15)        Exit program return code in R15  06220000
**********************************************************************  06230000
*                                                                    *  06240000
*        Format directory entry                                      *  06250000
*                                                                    *  06260000
**********************************************************************  06270000
DIRFMT   DS    0H                                                       06280000
         ST    R14,DIRFMT14            Save return address              06290000
         CLI   PDS2INDC,15                                              06300000
         BNE   DIRFMT10                                                 06310000
           LA    R2,DIR            Directory entry                      06320000
           L     R3,=A(SPFDESC)    Formatting layout                    06330000
           LR    R5,R8             Size of section                      06340000
           BAL   R14,FMT           Format directory entry               06350000
         B     DIRFMTXT                                                 06360000
DIRFMT10 DS    0H                                                       06370000
         TM    DIRDCB+DCBRECFM-IHADCB,DCBRECU Assume RECFM=U=Load lib   06380000
         BNO   DIRFMT80                                                 06390000
           LA    R2,DIR            Directory entry                      06400000
           L     R3,=A(LMDDESC)    Formatting layout                    06410000
           LR    R5,R8             Size of section                      06420000
           BAL   R14,FMT           Format directory entry               06430000
           LA    R14,DIR                                                06440000
           USING PDS2,R14                                               06450000
           LR    R4,R2                                                  06460000
           AH    R4,=AL2(PDSBCLN)  Basic section length                 06470000
           TM    PDS2ATR1,PDS2SCTR Scatter                              06480000
           BNO   DIRFMT20                                               06490000
           DROP  R14                                                    06500000
             LR    R0,R4           Get offset                           06510000
             SR    R0,R2            of section                          06520000
             L     R3,=A(LMDDESCS) Formatting layout                    06530000
             LR    R5,R8           Size of section                      06540000
             BAL   R14,FMT         Format directory entry               06550000
             AH    R4,=AL2(PDSS01LN) Scatter length                     06560000
DIRFMT20   DS    0H                                                     06570000
           LA    R14,DIR                                                06580000
           USING PDS2,R14                                               06590000
           TM    PDS2INDC,PDS2ALIS Scatter                              06600000
           BNO   DIRFMT30                                               06610000
           DROP  R14                                                    06620000
             LR    R0,R4           Get offset                           06630000
             SR    R0,R2            of section                          06640000
             L     R3,=A(LMDDESCA) Formatting layout                    06650000
             LR    R5,R8           Size of section                      06660000
             BAL   R14,FMT         Format directory entry               06670000
             AH    R4,=AL2(PDSS02LN) Alias length                       06680000
DIRFMT30   DS    0H                                                     06690000
           LA    R14,DIR                                                06700000
           USING PDS2,R14                                               06710000
           TM    PDS2FTB1,PDS2SSI  SSI                                  06720000
           BNO   DIRFMT40                                               06730000
           DROP  R14                                                    06740000
             AH    R4,=AL2(1)      Up to half                           06750000
             N     R4,=A(X'FFFE')   ward boundary                       06760000
             LR    R0,R4           Get offset                           06770000
             SR    R0,R2            of section                          06780000
             L     R3,=A(LMDDESCI) Formatting layout                    06790000
             LR    R5,R8           Size of section                      06800000
             BAL   R14,FMT         Format directory entry               06810000
             AH    R4,=AL2(PDSS03LN) SSI length                         06820000
DIRFMT40   DS    0H                                                     06830000
           LA    R14,DIR                                                06840000
           USING PDS2,R14                                               06850000
           TM    PDS2FTB1,PDSAPFLG APF                                  06860000
           BNO   DIRFMT50                                               06870000
           DROP  R14                                                    06880000
             LR    R0,R4           Get offset                           06890000
             SR    R0,R2            of section                          06900000
             L     R3,=A(LMDDESCP) Formatting layout                    06910000
             LR    R5,R8           Size of section                      06920000
             BAL   R14,FMT         Format directory entry               06930000
             AH    R4,=AL2(PDSS04LN) APF length                         06940000
DIRFMT50   DS    0H                                                     06950000
           LA    R14,DIR                                                06960000
           USING PDS2,R14                                               06970000
           TM    PDS2FTB1,PDS2BIG  Large Program                        06980000
           BNO   DIRFMT60                                               06990000
           DROP  R14                                                    07000000
             LR    R0,R4           Get offset                           07010000
             SR    R0,R2            of section                          07020000
             L     R3,=A(LMDDESCL) Formatting layout                    07030000
             LR    R5,R8           Size of section                      07040000
             BAL   R14,FMT         Format directory entry               07050000
             AH    R4,=AL2(PDSLPOLN) APF length                         07060000
DIRFMT60   DS    0H                                                     07070000
           LA    R14,DIR                                                07080000
           USING PDS2,R14                                               07090000
           TM    PDS2FTB1,PDS2XATR Extended Attribute                   07100000
           BNO   DIRFMT70                                               07110000
           DROP  R14                                                    07120000
             LR    R0,R4           Get offset                           07130000
             SR    R0,R2            of section                          07140000
             L     R3,=A(LMDDESCE) Formatting layout                    07150000
             LR    R5,R8           Size of section                      07160000
             BAL   R14,FMT         Format directory entry               07170000
DIRFMT70   DS    0H                                                     07180000
         B     DIRFMTXT                                                 07190000
DIRFMT80   DS    0H                Not load library directory           07200000
           CH    R0,=AL2(16)       Just SSI info present?               07210000
           BNE   DIRFMT90                                               07220000
             LA    R2,DIR          Directory entry                      07230000
             L     R3,=A(SSIDESC)  Formatting layout                    07240000
             LR    R5,R8           Length of dir entry                  07250000
             BAL   R14,FMT         Format directory entry               07260000
           B     DIRFMTXT                                               07270000
DIRFMT90   DS    0H                                                     07280000
             LR    R5,R8           Length of dir entry                  07290000
             L     R6,=A(BLKUSRD)  BLKENT2 start                        07300000
             SR    R7,R7                                                07310000
             IC    R7,17(,R6)      Length-1 from BLKENT2                07320000
             LA    R2,DIR          Directory entry                      07330000
             L     R3,=A(BASDESC)  Formatting layout                    07340000
             BAL   R14,FMT         Format directory entry               07350000
DIRFMTXT DS    0H                                                       07360000
         L     R14,DIRFMT14            Get return address               07370000
         BR    R14                     Exit initialization              07380000
**********************************************************************  07390000
*                                                                    *  07400000
*        Initialization                                              *  07410000
*                                                                    *  07420000
**********************************************************************  07430000
INIT     DS    0H                                                       07440000
         ST    R14,INITR14             Save return address              07450000
         L     R9,0(,R1)               Save parm address                07460000
         OPEN  (SYSPRINT,(OUTPUT)),MF=(E,W#OPEN) OPEN SYSPRINT          07470000
         TM    SYSPRINT+48,16          OPEN successful?                 07480000
         BZ    ERROR004                No, terminate                    07490000
         TIME  BIN                     Get current date and time        07500000
         ST    R1,CURDATE              Save date                        07510000
         SRDL  R0,32                   Get double word time             07520000
         D     R0,=F'+6000'            Get minutes                      07530000
         LR    R15,R0                  Save secs tens and hundreths     07540000
         SLR   R0,R0                   Clear                            07550000
         D     R0,=F'+60'              Get hours / mins                 07560000
         MH    R0,=H'+10000'           Get minutes                      07570000
         AR    R15,R0                  Add to get MM:SS.TH              07580000
         M     R0,=F'+1000000'         Get hours                        07590000
         AR    R1,R15                  Get HH:MM:SS.TH                  07600000
         CVD   R1,DWORD                Get time to decimal              07610000
         MVC   TIMWRK4,=X'402021207A20207A20204B2020'                   07620000
         ED    TIMWRK4,DWORD+3         Edit time                        07630000
         MVC   HD1TOD(8),TIMWRK4+2     Move time                        07640000
         ZAP   JULWRK2,CURDATE+2(2)    Get julian date                  07650000
         ZAP   JULWRK4,=P'+365'        Days/yr = 365                    07660000
         ZAP   JULWRK6,=P'+28'         Feb = 28                         07670000
         MVO   DWORD,CURDATE+1(1)      Sign year                        07680000
         DP    DWORD,=P'+4'            Divide by 4                      07690000
         CP    DWORD+7(1),=P'+0'       Is it a leap year?               07700000
         BNZ   INITJL2                 No                               07710000
         ZAP   JULWRK4,=P'+366'        Days/yr = 366                    07720000
         ZAP   JULWRK6,=P'+29'         Feb = 29                         07730000
INITJL2  DS    0H                                                       07740000
         LA    R1,JULTBL1              Point to January                 07750000
         SLR   R2,R2                   Set counter                      07760000
INITJL4  DS    0H                                                       07770000
         SP    JULWRK2,0(2,R1)         Months displacement              07780000
         BNP   INITJL6                 If equal or less than 0 done     07790000
         BCTR  R1,0                    Point to next month              07800000
         BCTR  R1,0                    Point to next month              07810000
         LA    R2,3(,R2)               Up index                         07820000
         B     INITJL4                 Loop                             07830000
INITJL6  DS    0H                                                       07840000
         AP    JULWRK2,0(2,R1)         Add days of month                07850000
         LA    R2,JULTBL2(R2)          Address month                    07860000
         MVC   HD1DATE(3),0(R2)        Move month                       07870000
         OI    JULWRK2+3,X'0F'         Display sign                     07880000
         UNPK  HD1DATE+4(2),JULWRK2    Get days                         07890000
         CLI   HD1DATE+4,C'0'          First 9 days?                    07900000
         LA    R1,HD1DATE+6            Set pointer                      07910000
         BNE   INITJL7                 No                               07920000
         MVC   HD1DATE+4(1),HD1DATE+5  Move units digit                 07930000
         BCTR  R1,0                    Drop pointer                     07940000
INITJL7  DS    0H                                                       07950000
         MVC   0(4,R1),=C', 19'        Set up constant                  07960000
         TM    CURDATE,1               Year 2000?                       07970000
         BNO   INITJL8                 No, continue                     07980000
         MVC   2(2,R1),=C'20'          Y2K                              07990000
INITJL8  DS    0H                                                       08000000
         UNPK  DWORD(3),CURDATE+1(2)   Unpack year                      08010000
         MVC   4(2,R1),DWORD           Get year                         08020000
*                                                                       08030000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            08040000
         MVC   W#LINE+9(L'PGMID),PGMID Move version                     08050000
         BAL   R14,PRT                 Print a line                     08060000
*                                                                       08070000
         MVC   W#LINE+1(5),=C'PARM='   Move parameter info literal      08080000
         CLI   1(R9),0                 Any parameter?                   08090000
         BE    PRMPRT                  No, skip move                    08100000
         LH    R1,0(,R9)               Get parmeter length              08110000
         BCTR  R1,0                    Make machine length              08120000
         EX    R1,PRMMVC               Move parm to print line          08130000
         B     PRMPRT                                                   08140000
PRMMVC   MVC   W#LINE+6(0),2(R9)       Executed parm move               08150000
PRMPRT   DS    0H                                                       08160000
         BAL   R14,PRT                 Print a line                     08170000
         LH    R2,0(,R9)               Get parm length                  08180000
         AH    R9,=H'+2'               Skip length                      08190000
         ST    R9,W#PRMBGN             Save parm start                  08200000
PRMSCN   DS    0H                                                       08210000
         LTR   R2,R2                   End of parm?                     08220000
         BZ    PRMEND                  Yes, parm parsed                 08230000
         CLI   0(R9),C','              Seperator?                       08240000
         BNE   PRMCHK                  No, check values                 08250000
         AH    R9,=H'+1'               Skip comma                       08260000
         SH    R2,=H'+1'               Decrement length                 08270000
         B     PRMSCN                  Continue scan                    08280000
PRMCHK   DS    0H                                                       08290000
         CH    R2,=H'+4'               Length large enough              08300000
         BL    PRMERR                  No, error                        08310000
         CLC   =C'DUMP',0(R9)          DUMP parameter                   08320000
         BE    PRMDMP                  Yes                              08330000
         CH    R2,=H'+5'               Length large enough              08340000
         BL    PRMERR                  No, error                        08350000
         CLC   =C'DEBUG',0(R9)         DEBUG parameter                  08360000
         BE    PRMDBG                  Yes                              08370000
         CH    R2,=H'+6'               Length large enough              08380000
         BL    PRMERR                  No, error                        08390000
         CLC   =C'FORMAT',0(R9)        FORMATparameter                  08400000
         BE    PRMFMT                  Yes                              08410000
         B     PRMERR                  Error                            08420000
PRMDMP   DS    0H                                                       08430000
         OI    FLAG,FLAGDMP            Set DUMP                         08440000
         AH    R9,=H'+4'               Get past parameter               08450000
         SH    R2,=H'+4'               Decrement length                 08460000
         B     PRMSCN                  Process next parameter           08470000
PRMDBG   DS    0H                                                       08480000
         OI    FLAG,FLAGDBG            Set DEBUG                        08490000
         AH    R9,=H'+5'               Get past parameter               08500000
         SH    R2,=H'+5'               Decrement length                 08510000
         B     PRMSCN                  Process next parameter           08520000
PRMFMT   DS    0H                                                       08530000
         OI    FLAG,FLAGFMT            Set FORMAT                       08540000
         AH    R9,=H'+6'               Get past parameter               08550000
         SH    R2,=H'+6'               Decrement length                 08560000
         B     PRMSCN                  Process next parameter           08570000
PRMERR   DS    0H                                                       08580000
         LR    R1,R9                   Current position                 08590000
         S     R1,W#PRMBGN             Less start                       08600000
         LA    R1,W#LINE+6(R1)         Set location of error            08610000
         MVI   0(R1),C'*'              Mark where error is              08620000
         BAL   R14,PRT                 Print a line                     08630000
         MVC   W#LINE(19),=C' Parameters invalid'                       08640000
         BAL   R14,PRT                 Print a line                     08650000
         B     INITER                  Error                            08660000
PRMEND   DS    0H                                                       08670000
         OPEN  (DIRDCB,(INPUT)),MF=(E,W#OPEN) OPEN directory            08680000
         TM    DIRDCB+48,X'10'         Valid OPEN                       08690000
         BNO   ERROR083                No, terminate                    08700000
         LA    R2,MYJFCB               Address of JFCB                  08710000
         USING JFCB,R2                                                  08720000
         RDJFCB DIRDCB,MF=(E,W#OPEN)   Read directory JFCB              08730000
         MVC   W#LINE+1(10),=C'Input DSN=' Message                      08740000
         MVC   W#LINE+11(44),JFCB      Set up info                      08750000
         LA    R0,45                   How far to scam                  08760000
         LA    R1,W#LINE+11            Start with begin of DSN          08770000
PRMEND10 DS    0H                                                       08780000
           CLI   0(R1),C' '            If found a blank done            08790000
           BE    PRMEND20                                               08800000
           AH    R1,=AL2(1)            Next DSN position                08810000
         BCT   R0,PRMEND10                                              08820000
PRMEND20 DS    0H                                                       08830000
         MVC   1(8,R1),=C'VOL=SER='    Message text                     08840000
         MVC   9(6,R1),JFCBVOLS        and volume serial                08850000
         BAL   R14,PRT                 Print line                       08860000
         SR    R15,R15                 Set successful return code       08870000
         B     INITXT                  Go exit                          08880000
INITER   DS    0H                                                       08890000
         LA    R15,8                   Set error return code            08900000
INITXT   DS    0H                                                       08910000
         L     R14,INITR14             Get return address               08920000
         BR    R14                     Exit initialization              08930000
**********************************************************************  08940000
*                                                                     * 08950000
*        DUMP DATA                                                    * 08960000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 08970000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 08980000
*                                                                     * 08990000
*********************************************************************** 09000000
DMP      DS    0H                                                       09010000
         STM   R0,R15,W#DMPRGS         SAVE REGISTERS                   09020000
         LR    R3,R1                   GET ADDRESS TO DUMP              09030000
         LR    R4,R0                   GET LENGTH                       09040000
         XC    W#DMPOFF,W#DMPOFF       SAVE OFFSET FOR DUMP             09050000
         MVI   W#DMPFLG,W#DMP1ST       FIRST LINE                       09060000
DMPDMPLP DS    0H                                                       09070000
         LTR   R4,R4                   ANY DATA TO DUMP ?               09080000
         BZ    DMPHEXXT                 YES, ALL DONE                   09090000
         TM    W#DMPFLG,W#DMP1ST       FIRST LINE?                      09100000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   09110000
         LA    R0,32                   DEFAULT LENGTH                   09120000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          09130000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           09140000
         LR    R14,R3                  GET CURRENT INPUT AREA           09150000
         SR    R14,R0                  BACK TO PREVIOUS AREA            09160000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       09170000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            09180000
         SR    R4,R0                   REDUCE LENGTH TO DO              09190000
         TM    W#DMPFLG,W#DMPDUP       DUPLICATE IN PROGRESS?           09200000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       09210000
         L     R14,W#DMPOFF            GET CURRENT OFFSET               09220000
         ST    R14,W#DUP1ST            SAVE AS FIRST OFFSET             09230000
         OI    W#DMPFLG,W#DMPDUP       SET DUPLICATE                    09240000
         B     DMPNXTLN                CONTINUE                         09250000
DMPDUPCK DS    0H                                                       09260000
         TM    W#DMPFLG,W#DMPDUP       DUPLICATE IN PROGRESS?           09270000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      09280000
         MVC   W#LINE+7(5),=C'lines'   MOVE LITERAL                     09290000
         LA    R2,W#LINE+13            OUTPUT AREA ADDRESS              09300000
         LA    R1,W#DUP1ST+2           ADDRESS OF OFFSET TO DUMP        09310000
         LA    R15,2                   CONVERT 4 BYTES                  09320000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            09330000
         MVI   W#LINE+17,C'-'          THRU LITERAL                     09340000
         L     R1,W#DMPOFF             GET CURRENT OFFSET               09350000
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        09360000
         ST    R1,W#DUP1ST             SAVE FOR DUMPING                 09370000
         LA    R2,W#LINE+18            OUTPUT AREA ADDRESS              09380000
         LA    R1,W#DUP1ST+2           ADDRESS OF OFFSET TO DUMP        09390000
         LA    R15,2                   CONVERT 4 BYTES                  09400000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            09410000
         MVC   W#LINE+23(13),=C'same as above' MOVE LITERAL             09420000
         BAL   R14,PRT                 PRINT A LINE                     09430000
         NI    W#DMPFLG,255-W#DMPDUP   RESET DUPLICATE IN PROGRESS      09440000
DMPALIN  DS    0H                                                       09450000
         LA    R2,W#LINE+1             OUTPUT AREA ADDRESS              09460000
         LA    R1,W#DMPOFF+2           ADDRESS OF OFFSET TO DUMP        09470000
         LA    R15,2                   CONVERT 4 BYTES                  09480000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            09490000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     09500000
         LR    R1,R3                   ADDRESS OF DATA                  09510000
         LA    R5,32                   DEFAULT LENGTH                   09520000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          09530000
         BH    DMPDODMP                 YES, USE 32                     09540000
         LR    R5,R4                   USE WHAT IS LEFT                 09550000
DMPDODMP DS    0H                                                       09560000
         SR    R4,R5                   REDUCE AMOUNT TO DO              09570000
         MVI   W#LINE+89,C'*'          BOX IN DISPLAY PORTION           09580000
         BCTR  R5,0                    MAKE ZERO BASED                  09590000
         EX    R5,DMPMVC               DO MOVE                          09600000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          09610000
         LA    R5,1(,R5)               RESTORE LENGTH                   09620000
         MVI   W#LINE+122,C'*'         COMPLETE BOX                     09630000
DMPDMPHX DS    0H                                                       09640000
         LA    R15,4                   4 BYTES TO PROCESS               09650000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           09660000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               09670000
         LR    R15,R5                  USE LENGTH LEFT                  09680000
DMPDMPIT DS    0H                                                       09690000
         SR    R5,R15                  REDUCE AMOUNT TO DO              09700000
         BAL   R14,DMPDSP              CONVERT DATA                     09710000
         LA    R2,1(,R2)               SKIP 1 BYTE                      09720000
         LA    R0,W#LINE+43            HALFWAY POINT ADDRESS            09730000
         CR    R0,R2                   AT HALFWAY POINT?                09740000
         BNE   DMPDMPNX                 NO, CONTINUE                    09750000
         LA    R2,1(,R2)               SKIP 1 BYTE                      09760000
DMPDMPNX DS    0H                                                       09770000
         LTR   R5,R5                   ANY LEFT TO DO ?                 09780000
         BH    DMPDMPHX                 YES, GO DO IT                   09790000
         BAL   R14,PRT                 PRINT A LINE                     09800000
DMPNXTLN DS    0H                                                       09810000
         L     R1,W#DMPOFF             GET OFFSET IN RECORD             09820000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       09830000
         ST    R1,W#DMPOFF             SAVE OFFSET IN RECORD            09840000
         LA    R3,32(,R3)              NEXT INPUT AREA                  09850000
         NI    W#DMPFLG,255-W#DMP1ST NOT FIRST LINE                     09860000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             09870000
DMPHEXXT DS    0H                                                       09880000
         LM    R0,R15,W#DMPRGS         RESTORE CALLERS REGS             09890000
         BR    R14                     EXIT . . .                       09900000
DMPMVC   MVC   W#LINE+90(0),0(R1)      <<< EXECUTED >>>                 09910000
DMPTR    TR    W#LINE+90(0),P#DMPTBL   <<< EXECUTED >>>                 09920000
*                                                                       09930000
*                                                                       09940000
*                                                                       09950000
DMPDSP   DS    0H                                                       09960000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               09970000
         NI    0(R2),X'0F'             REMOVE ZONE                      09980000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             09990000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             10000000
         TR    0(2,R2),P#HEXTBL        TRANSLATE TO HEX                 10010000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        10020000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         10030000
         BCT   R15,DMPDSP              LOOP THRU DATA                   10040000
         BR    R14                     EXIT . . .                       10050000
**********************************************************************  10060000
*                                                                    *  10070000
*        Print a line                                                *  10080000
*                                                                    *  10090000
**********************************************************************  10100000
PRT      DS    0H                                                       10110000
         ST    R14,PRTR14              Save return address              10120000
         CP    LNCT,=P'+60'            End of page                      10130000
         BL    PRTCHK                  No, check if line fit in page    10140000
PRTHDRS  DS    0H                                                       10150000
         AP    PGCT,=P'+1'             Count pages                      10160000
         MVC   HD1PGCT,=X'40202120'    Page count mask                  10170000
         ED    HD1PGCT,PGCT            Edit page count                  10180000
         PUT   SYSPRINT,HD1            Print heading 1                  10190000
         ZAP   LNCT,=P'+2'             Init line count                  10200000
         MVI   W#LINE,C'0'             Skip after heading               10210000
PRTCHK   DS    0H                                                       10220000
         CLI   W#LINE,C'+'             Overprint?                       10230000
         BE    PRTLINE                 Yes, don't count                 10240000
         CLI   W#LINE,C'1'             New page?                        10250000
         BE    PRTHDRS                 Yes, print header                10260000
         CLI   W#LINE,C' '             Write after advancing 1?         10270000
         BE    PRTLINE1                Yes, go check if fit             10280000
         CLI   W#LINE,C'0'             Write after advancing 2?         10290000
         BE    PRTLINE2                Yes, go check if fit             10300000
         CLI   W#LINE,C'-'             Write after advancing 3?         10310000
         BE    PRTLINE3                Yes, go check if fit             10320000
         B     PRTLINE                 Ignore any other ctl chars       10330000
PRTLINE1 DS    0H                                                       10340000
         AP    LNCT,=P'+1'             Add to line count                10350000
         B     PRTVFY                  Go see if it will fit            10360000
PRTLINE2 DS    0H                                                       10370000
         AP    LNCT,=P'+2'             Add to line count                10380000
         B     PRTVFY                  Go see if it will fit            10390000
PRTLINE3 DS    0H                                                       10400000
         AP    LNCT,=P'+3'             Add to line count                10410000
PRTVFY   DS    0H                                                       10420000
         CP    LNCT,=P'+60'            Overflow ?                       10430000
         BH    PRTHDRS                 Yes, force header                10440000
PRTLINE  DS    0H                                                       10450000
         PUT   SYSPRINT,W#LINE         Print a line                     10460000
         MVI   W#LINE,C' '             Clear control character          10470000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE Clear print line             10480000
         L     R14,PRTR14              Restore return address           10490000
         BR    R14                     Return to caller                 10500000
*********************************************************************** 10510000
*        Format Control Block                                         * 10520000
*          R5=Section length                                          * 10530000
*          R3=CBDEF                                                   * 10540000
*          R2=Data address                                            * 10550000
*          R0=Offset if OFF=PASS specified on BLKENT                  * 10560000
*             Requires BLKENT/2 all use .NEXT                         * 10570000
*********************************************************************** 10580000
FMT      DS    0H                                                       10590000
         STM   R0,R15,W#FREGS      Save registers                       10600000
         USING BLK,R3                                                   10610000
         TM    BLKFIRST,X'80'      OFF=PASS?                            10620000
         BO    FMTPASS             Yes, R0 has offset in buffer         10630000
         LH    R0,BLKFIRST         Control block start offset           10640000
FMTPASS  DS    0H                                                       10650000
         ST    R0,W#FBGNOF         Save it                              10660000
         ST    R2,W#FADDR          Save control block address           10670000
         AR    R2,R0               Add offset to address                10680000
         LA    R3,BLKHDNXT         Get next block field                 10690000
         LR    R4,R2               Start address for .NEXT              10700000
         AR    R5,R2               Get end address                      10710000
FMTCB    DS    0H                                                       10720000
         CLI   BLKTYPE,BLKHEX      Hex field?                           10730000
         BE    FMTHEX              Yes, do hex field                    10740000
         CLI   BLKTYPE,BLKCONST    Constant field                       10750000
         BE    FMTCONST            Yes, do constant (label)             10760000
         CLI   BLKTYPE,BLKCHAR     Character field                      10770000
         BE    FMTCHAR             Yes, do character field              10780000
         CLI   BLKTYPE,BLKFLAG     Flag definition                      10790000
         BE    FMTFLAG             Yes, do flag definition              10800000
         CLI   BLKTYPE,BLKFLAG+1   Flag definition                      10810000
         BE    FMTFLAG             Yes, do flag definition              10820000
         B     FMTEND              Must be block end, done              10830000
*        Character constant (label)                                     10840000
FMTCONST DS    0H                                                       10850000
         LA    R15,BLKDATA         Address of field                     10860000
         SR    R14,R14                                                  10870000
         IC    R14,BLKDTALN        Get length of field                  10880000
         SR    R1,R1                                                    10890000
         IC    R1,BLKOFF           Line offset                          10900000
         LA    R1,W#LINE+1+9(R1)   Add line start                       10910000
         EX    R14,FMTEMVC         Move character field                 10920000
         LA    R3,BLKDTANX(R14)    Next field definition                10930000
         B     FMTLOOP             Back for another field               10940000
FMTEMVC  MVC   0(0,R1),0(R15)      Move character field                 10950000
*        Character field                                                10960000
FMTCHAR  DS    0H                                                       10970000
         CLC   BLKDISP,=AL2(32768) .NEXT field (X'8000')?               10980000
         BE    FMTCHAR0            Yes, source address set              10990000
         LH    R4,BLKDISP          Offset of field                      11000000
         AR    R4,R2               Add address to offset                11010000
FMTCHAR0 DS    0H                                                       11020000
         BAL   R14,FMTOFF          Format field offset                  11030000
         CR    R4,R5               Beyond end of section                11040000
         BNL   FMTCHRNA            Yes, not available                   11050000
         SR    R14,R14                                                  11060000
         IC    R14,BLKCHRLN        Get length of field                  11070000
         CLI   BLKCHRSC,0          SCON used?                           11080000
         BE    FMTCHAR1            No, regular length                   11090000
         SR    R1,R1                                                    11100000
         IC    R1,BLKCHRSC         Get SCON base register               11110000
         SRL   R1,2                Base reg times 4                     11120000
         N     R1,=A(X'003C')      Clear non base reg stuff             11130000
         L     R1,W#FREGS(R1)      Get base register                    11140000
         LH    R0,BLKCHRSC         Get SCON displacement                11150000
         N     R0,=A(X'0FFF')      Clear base register                  11160000
         AR    R1,R0               Add to base register                 11170000
         SR    R14,R14                                                  11180000
         IC    R14,0(,R1)          Get length of data                   11190000
         BCTR  R14,0               Machine length                       11200000
FMTCHAR1 DS    0H                                                       11210000
         SR    R1,R1                                                    11220000
         IC    R1,BLKOFF           Line offset                          11230000
         LA    R1,W#LINE+1+9(R1)   Add line start                       11240000
         LA    R0,W#LINE+130                                            11250000
         SR    R0,R1                                                    11260000
         LR    R15,R14                                                  11270000
         CH    R15,=AL2(0)                                              11280000
         BL    FMTCHARB                                                 11290000
           CR    R14,R0                                                 11300000
           BL    FMTCHARA                                               11310000
             LR    R15,R0                                               11320000
FMTCHARA   DS    0H                                                     11330000
           EX    R15,FMTCMVC       Move field to line                   11340000
           EX    R15,FMTCTR        Remove unprintables                  11350000
FMTCHARB DS    0H                                                       11360000
         B     FMTCHAR2                                                 11370000
FMTCMVC  MVC   0(0,R1),0(R4)       Move character field                 11380000
FMTCTR   TR    0(0,R1),P#TBLCH     Remove unprintables                  11390000
FMTCHAR2 DS    0H                                                       11400000
         LA    R4,1(R4,R14)        Next field                           11410000
         LA    R3,BLKCHRNX         Next field definition                11420000
         B     FMTLOOP             Move character field                 11430000
*        Char field beyond end of section                               11440000
FMTCHRNA DS    0H                                                       11450000
         B     FMTEND                                                   11460000
         LA    R15,=C'n/a'         Field not available                  11470000
         LA    R14,3-1             Machine length                       11480000
         SR    R1,R1                                                    11490000
         IC    R1,BLKOFF           Line offset                          11500000
         LA    R1,W#LINE+1+9(R1)   Add line start                       11510000
         EX    R14,FMTEMVC         Move field to line                   11520000
         B     FMTCHAR2            Go finish off char                   11530000
*        Hex field                                                      11540000
FMTHEX   DS    0H                                                       11550000
         XC    W#FMTFLA,W#FMTFLA   Clear where flag might be            11560000
         CLC   BLKDISP,=AL2(32768) .NEXT field?                         11570000
         BE    FMTHEX0             Yes, source address set              11580000
         TM    BLKDISP,X'80'       NEXT based upon prev 1 byte length   11590000
         BNO   FMTHEXB             No, continue                         11600000
         SLR   R15,R15             Get a zero                           11610000
         IC    R15,BLKDISP         Flag and L index                     11620000
         SRL   R15,4               Shift index                          11630000
         N     R15,=A(X'0007')     Clear flag                           11640000
         SLR   R14,R14             Get a zero                           11650000
         ICM   R14,3,BLKDISP       Offset of field                      11660000
         N     R14,=A(X'0FFF')     Clear flag                           11670000
         LTR   R14,R14             If zero                              11680000
         BZ    FMTHEXA             It's a .NEXT                         11690000
         LR    R4,R14              Offset of field                      11700000
         AR    R4,R2               Add address to offset                11710000
FMTHEXA  DS    0H                                                       11720000
         IC    R0,0(,R4)           Get the length field                 11730000
         STC   R0,W#L(R15)         Save current field (length)          11740000
         B     FMTHEX0                                                  11750000
FMTHEXB  DS    0H                                                       11760000
         LH    R4,BLKDISP          Offset of field                      11770000
         AR    R4,R2               Add address to offset                11780000
FMTHEX0  DS    0H                                                       11790000
         ST    R4,W#FMTFLA         Save where flag might be             11800000
         BAL   R14,FMTOFF          Format field offset                  11810000
         CR    R4,R5               Beyond end of section                11820000
         BNL   FMTHEXNA            Yes, not available                   11830000
         CLI   BLKHEXSC,0          SCON used?                           11840000
         BE    FMTHEXL1            No, regular length                   11850000
         SR    R1,R1                                                    11860000
         IC    R1,BLKHEXSC         Get base register                    11870000
         SRL   R1,2                Base reg times 8                     11880000
         N     R1,=A(X'003C')      Clear not base reg stuff             11890000
         L     R1,W#FREGS(R1)      Get base register                    11900000
         SR    R0,R0                                                    11910000
         ICM   R0,3,BLKHEXSC       Get SCON                             11920000
         N     R0,=A(X'0FFF')      Clear base register                  11930000
         AR    R1,R0               Add to base register                 11940000
         SR    R14,R14                                                  11950000
         IC    R14,BLKOFF          Get offset into line                 11960000
         AH    R14,=AL2(1+9+1)     Add in start of formatting +1        11970000
         LA    R0,132              Get line length                      11980000
         SR    R0,R14              Get maximum length                   11990000
         SR    R14,R14                                                  12000000
         IC    R14,0(,R1)          Get length of data                   12010000
         CR    R14,R0              Is it greater than max length        12020000
         BNH   FMTHEXL0            No, go move it to line               12030000
         LR    R14,R0              Its to long, just move what fits     12040000
FMTHEXL0 DS    0H                                                       12050000
         LR    R1,R14              Place into R1                        12060000
         B     FMTHEXL2            Go process length                    12070000
FMTHEXL1 DS    0H                                                       12080000
         SR    R1,R1                                                    12090000
         IC    R1,BLKHEXLN         Get field length                     12100000
FMTHEXL2 DS    0H                                                       12110000
         LA    R0,1(,R1)           Machine to actual length             12120000
         SR    R1,R1                                                    12130000
         IC    R1,BLKOFF           Line offset                          12140000
         LA    R1,W#LINE+1+9(R1)   Add line start                       12150000
         LA    R14,W#FTEMP         Where to start from even digits      12160000
         CLI   BLKHEXOF,1          Do we want second digit              12170000
         BNE   FMTHEXF1            No, want first                       12180000
         LA    R14,W#FTEMP+1       Where to start from odd digits       12190000
FMTHEXF1 DS    0H                                                       12200000
         MVC   W#FTEMP+5(1),0(R4)  Get first byte                       12210000
         CH    R0,=AL2(2)          If only one left                     12220000
         BNH   FMTHEXF2            Don't copy last byte                 12230000
         MVC   W#FTEMP+6(1),1(R4)  Copy to prevent buffer overrun       12240000
FMTHEXF2 DS    0H                                                       12250000
         UNPK  W#FTEMP(5),W#FTEMP+5(3) Convert hex to character         12260000
         TR    W#FTEMP(4),P#HEXTBL-240 Finish convert                   12270000
         LA    R15,W#LINE+130                                           12280000
         CR    R1,R15                                                   12290000
         BNL   FMTHEXFA                                                 12300000
           MVC   0(1,R1),0(R14)    Copy first digit                     12310000
FMTHEXFA DS    0H                                                       12320000
         SH    R0,=AL2(1)          Count digit done                     12330000
         BZ    FMTHEXF3            If all done stop formatting          12340000
         CR    R1,R15                                                   12350000
         BNL   FMTHEXFB                                                 12360000
           MVC   1(1,R1),1(R14)    Move another hex digit               12370000
FMTHEXFB DS    0H                                                       12380000
         AH    R1,=AL2(2)          Next output area                     12390000
         AH    R4,=AL2(1)          Next input area                      12400000
         BCT   R0,FMTHEXF1         Loop thru area                       12410000
FMTHEXF3 DS    0H                                                       12420000
         LA    R3,BLKHEXNX         Next field definition                12430000
         B     FMTLOOP                                                  12440000
*        Hex field beyond end of section                                12450000
FMTHEXNA DS    0H                                                       12460000
         B     FMTEND                                                   12470000
         LA    R15,=C'n/a'         Field not available                  12480000
         LA    R14,3-1             Machine length                       12490000
         SR    R1,R1                                                    12500000
         IC    R1,BLKOFF           Line offset                          12510000
         LA    R1,W#LINE+1+9(R1)   Add line start                       12520000
         EX    R14,FMTEMVC         Move field to line                   12530000
         SR    R14,R14                                                  12540000
         IC    R14,BLKCHRLN        Get length of field                  12550000
         AR    R4,R14              add in length                        12560000
         B     FMTHEXF3            Go finish off hex                    12570000
*        Flag definition                                                12580000
FMTFLAG  DS    0H                                                       12590000
         ICM   R15,15,W#FMTFLA     A flag byte encountered?             12600000
         BZ    FMTFLAG9            No, skip this entry                  12610000
         SR    R14,R14                                                  12620000
         IC    R14,BLKFLG          Get bit to test                      12630000
         CLI   BLKTYPE,BLKFLAG+1   Flag definition                      12640000
         BE    FMTFLAG1            Yes, do flag compare                 12650000
         EX    R14,FMTFLAGT        Test flag                            12660000
         BNO   FMTFLAG9            If off skip this entry               12670000
         B     FMTFLAG2            Format this flag description         12680000
FMTFLAG1 DS    0H                                                       12690000
         EX    R14,FMTFLAGC        Compare flag                         12700000
         BNE   FMTFLAG9            If not equal skip this entry         12710000
FMTFLAG2 DS    0H                                                       12720000
         BAL   R14,PRT             Print a line                         12730000
         LA    R15,BLKFLGD         Address of field                     12740000
         SR    R14,R14                                                  12750000
         IC    R14,BLKFLGDL        Get length of field                  12760000
         SR    R1,R1                                                    12770000
         IC    R1,BLKOFF           Line offset                          12780000
         LA    R1,W#LINE+1+9(R1)   Add line start                       12790000
         EX    R14,FMTFMVC         Move character field                 12800000
FMTFLAG9 DS    0H                                                       12810000
         SR    R14,R14                                                  12820000
         IC    R14,BLKFLGDL        Get length of field                  12830000
         LA    R3,BLKFLGNX(R14)    Next field definition                12840000
         B     FMTLOOP             Move character field                 12850000
FMTFLAGT TM    0(R15),0            Test flag                            12860000
FMTFLAGC CLI   0(R15),0            Compare flag                         12870000
FMTFMVC  MVC   0(0,R1),0(R15)      Move bit description                 12880000
FMTLOOP  DS    0H                                                       12890000
         CLI   BLKTYPE,BLKEND      End of block definition              12900000
         BE    FMTEND              yes, were done formatting            12910000
         CLI   BLKOFF,0            New line requested                   12920000
         BNE   FMTCB               No, continue with next field         12930000
         BAL   R14,PRT             Print a line                         12940000
         B     FMTCB               Go handle next field                 12950000
FMTEND   DS    0H                                                       12960000
         CLI   W#LINE+10,C' '                                           12970000
         BNE   FMTEND1                                                  12980000
         CLC   W#LINE+11(120),W#LINE+10                                 12990000
         BNE   FMTEND1                                                  13000000
         MVI   W#LINE,C' '                                              13010000
         MVC   W#LINE+1(10),W#LINE Clear line woth offet only           13020000
         B     FMTEND2                                                  13030000
FMTEND1  DS    0H                                                       13040000
         BAL   R14,PRT             Print a line                         13050000
FMTEND2  DS    0H                                                       13060000
         LM    R0,R15,W#FREGS      Restore registers                    13070000
         BR    R14                 Return to caller                     13080000
*        Format offset as needed                                        13090000
FMTOFF   DS    0H                                                       13100000
         CLI   W#LINE+5+3,C' '     Have we've done offset?              13110000
         BNER  R14                 Yes, don't do again                  13120000
         LR    R15,R4              Get a current field address          13130000
         S     R15,W#FADDR         Get field displacement               13140000
         LPR   R0,R15              Get positive value                   13150000
         ST    R0,W#FDWD           Save displacement                    13160000
         UNPK  W#LINE+5(5),W#FDWD+2(3) Convert to character             13170000
         TR    W#LINE+6(3),P#HEXTBL-240 Finish convert                  13180000
         MVI   W#LINE+5,C' '       Clear extra info                     13190000
         MVI   W#LINE+9,C' '       Clear extra info                     13200000
         LA    R1,W#LINE+6         Where to start zero suppression      13210000
         LA    R0,2                Only handle 2 zeros                  13220000
FMTOFF1  DS    0H                                                       13230000
         CLI   0(R1),C'0'          Is there a leading zero              13240000
         BNE   FMTOFF2             No, we finished suppression          13250000
         MVI   0(R1),C' '          Clear leading zero                   13260000
         AH    R1,=AL2(1)          Next digit                           13270000
         BCT   R0,FMTOFF1          Suppress limit                       13280000
FMTOFF2  DS    0H                                                       13290000
         BCTR  R1,0                Back to previous spot                13300000
         LTR   R15,R15             Is value positive                    13310000
         MVI   0(R1),C'+'          Set positive indicator               13320000
         BNLR  R14                 Exit if +                            13330000
         MVI   0(R1),C'-'          Set negative indicator               13340000
         BR    R14                 Exit                                 13350000
**********************************************************************  13360000
*                                                                    *  13370000
*        Constants                                                   *  13380000
*                                                                    *  13390000
**********************************************************************  13400000
         LTORG                                                          13410000
P#HEXTBL DC    C'0123456789ABCDEF'                                      13420000
P#DMPTBL    DC CL256' '                                                 13430000
           ORG P#DMPTBL+X'4A' Cent                                      13440000
            DC X'4A4B4C4D4E4F50'                                        13450000
           ORG P#DMPTBL+X'5A' exclamation                               13460000
            DC X'5A5B5C5D5E5F6061'                                      13470000
           ORG P#DMPTBL+X'6A'                                           13480000
            DC X'6A6B6C6D6E6F'                                          13490000
           ORG P#DMPTBL+X'7A'                                           13500000
            DC X'7A7B7C7D7E7F'                                          13510000
           ORG P#DMPTBL+C'a'                                            13520000
            DC C'abcdefghi'                                             13530000
           ORG P#DMPTBL+C'j'                                            13540000
            DC C'jklmnopqr'                                             13550000
           ORG P#DMPTBL+C's'                                            13560000
            DC C'stuvwxyz'                                              13570000
           ORG P#DMPTBL+C'A'                                            13580000
            DC C'ABCDEFGHI'                                             13590000
           ORG P#DMPTBL+C'J'                                            13600000
            DC C'JKLMNOPQR'                                             13610000
           ORG P#DMPTBL+C'S'                                            13620000
            DC C'STUVWXYZ'                                              13630000
           ORG P#DMPTBL+C'0'                                            13640000
            DC C'0123456789'                                            13650000
           ORG ,                                                        13660000
P#TBLCH  DC     256C'.'             Non printable character table       13670000
         ORG    P#TBLCH+C' '                                            13680000
         DC     C' '                                                    13690000
         ORG    P#TBLCH+X'4A' Cent                                      13700000
         DC     X'4A4B4C4D4E4F50' vert bar and ampersand                13710000
         ORG    P#TBLCH+X'5A' exclamation                               13720000
         DC     X'5A5B5C5D5E5F6061'                                     13730000
         ORG    P#TBLCH+X'6A'                                           13740000
         DC     X'6A6B6C6D6E6F'                                         13750000
         ORG    P#TBLCH+X'7A'                                           13760000
         DC     X'7A7B7C7D7E7F'                                         13770000
         ORG    P#TBLCH+C'a'                                            13780000
         DC     C'abcdefghi'                                            13790000
         ORG    P#TBLCH+C'j'                                            13800000
         DC     C'jklmnopqr'                                            13810000
         ORG    P#TBLCH+C's'                                            13820000
         DC     C'stuvwxyz'                                             13830000
         ORG    P#TBLCH+C'A'                                            13840000
         DC     C'ABCDEFGHI'                                            13850000
         ORG    P#TBLCH+C'J'                                            13860000
         DC     C'JKLMNOPQR'                                            13870000
         ORG    P#TBLCH+C'S'                                            13880000
         DC     C'STUVWXYZ'                                             13890000
         ORG    P#TBLCH+C'0'                                            13900000
         DC     C'0123456789'                                           13910000
         ORG    ,                                                       13920000
*********************************************************************** 13930000
*                                                                     * 13940000
*        Tables                                                       * 13950000
*                                                                     * 13960000
*********************************************************************** 13970000
         DC    (((((*-FMTDIR24)/256)+1)*256)-(*-FMTDIR24))X'00'         13980000
* Basic Entry                                                           13990000
BASDESC  BLKBGN OFF=0,LEN=FFF                                           14000000
         BLKENT2 'PDS2NAME',CHAR,.NEXT,08,NEWLIN=YES                    14010000
         BLKENT LABEL,'      MEMBER NAME'                               14020000
         BLKENT2 'PDS2TTRP',HEX,.NEXT,06,NEWLIN=YES                     14030000
         BLKENT LABEL,'        TTR OF MEMBER'                           14040000
         BLKENT2 'PDS2INDC',HEX,.NEXT,02,NEWLIN=YES                     14050000
         BLKENT LABEL,'            INDICATOR BYTE'                      14060000
BLKUSRD  EQU     *                                                      14070000
         BLKENT2 'PDS2USRD',HEX,.NEXT,08,NEWLIN=YES                     14080000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14090000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14100000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14110000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14120000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14130000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14140000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14150000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14160000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14170000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14180000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14190000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14200000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14210000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14220000
         BLKENT2 '        ',HEX,.NEXT,04,NEWLIN=YES                     14230000
         BLKEND                                                         14240000
* SPF Statistics                                                        14250000
SPFDESC  BLKBGN OFF=0,LEN=FFF                                           14260000
         BLKENT2 'PDS2NAME',CHAR,.NEXT,08,NEWLIN=YES                    14270000
         BLKENT LABEL,'      MEMBER NAME'                               14280000
         BLKENT2 'PDS2TTRP',HEX,.NEXT,06,NEWLIN=YES                     14290000
         BLKENT LABEL,'        TTR OF MEMBER'                           14300000
         BLKENT2 'PDS2INDC',HEX,.NEXT,02,NEWLIN=YES                     14310000
         BLKENT LABEL,'            INDICATOR BYTE'                      14320000
         BLKENT2 'SPFUV   ',HEX,.NEXT,02,NEWLIN=YES                     14330000
         BLKENT LABEL,'            VERSION'                             14340000
         BLKENT2 'SPFUM   ',HEX,.NEXT,02,NEWLIN=YES                     14350000
         BLKENT LABEL,'            MODIFICATION LEVEL'                  14360000
         BLKENT2 'SPFUFLG ',HEX,.NEXT,02,NEWLIN=YES                     14370000
         BLKENT LABEL,'            FLAGS'                               14380000
         BLKENT2 'SPFUCHGS',HEX,.NEXT,02,NEWLIN=YES                     14390000
         BLKENT LABEL,'            '                                    14400000
         BLKENT2 'SPFUCRED',HEX,.NEXT,08,NEWLIN=YES                     14410000
         BLKENT LABEL,'      CREATED DATE'                              14420000
         BLKENT2 'SPFUCHGD',HEX,.NEXT,08,NEWLIN=YES                     14430000
         BLKENT LABEL,'      CHANGED DATE'                              14440000
         BLKENT2 'SPFUCHGT',HEX,.NEXT,04,NEWLIN=YES                     14450000
         BLKENT LABEL,'          CHANGED TIME'                          14460000
         BLKENT2 'SPFUSIZE',HEX,.NEXT,04,NEWLIN=YES                     14470000
         BLKENT LABEL,'          CURRENT SIZE'                          14480000
         BLKENT2 'SPFUINIT',HEX,.NEXT,04,NEWLIN=YES                     14490000
         BLKENT LABEL,'          INITIAL SIZE'                          14500000
         BLKENT2 'SPFUMOD ',HEX,.NEXT,04,NEWLIN=YES                     14510000
         BLKENT LABEL,'          MODIFIED'                              14520000
         BLKENT2 'SPFUUID ',CHAR,.NEXT,07,NEWLIN=YES                    14530000
         BLKENT LABEL,'       USER'                                     14540000
         BLKENT2 'Unused  ',HEX,.NEXT,06,NEWLIN=YES                     14550000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14560000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14570000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14580000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14590000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14600000
         BLKENT2 '        ',HEX,.NEXT,08,NEWLIN=YES                     14610000
         BLKENT2 '        ',HEX,.NEXT,02,NEWLIN=YES                     14620000
         BLKEND                                                         14630000
         DC     0D'+0'                                                  14640000
* Load Module Basic Section                                             14650000
LMDDESC  BLKBGN OFF=0,LEN=FFF                                           14660000
         BLKENT  LABEL,'Basic Section',NEWLIN=YES                       14670000
         BLKENT2 'PDS2NAME',CHAR,.NEXT,08,NEWLIN=YES                    14680000
         BLKENT LABEL,'      MEMBER NAME'                               14690000
         BLKENT2 'PDS2TTRP',HEX,.NEXT,06,NEWLIN=YES                     14700000
         BLKENT LABEL,'        TTR OF MEMBER'                           14710000
         BLKENT2 'PDS2INDC',HEX,.NEXT,02,NEWLIN=YES                     14720000
         BLKENT LABEL,'            INDICATOR BYTE'                      14730000
         BLKENT2 'PDS2TTRT',HEX,.NEXT,06,NEWLIN=YES                     14740000
         BLKENT LABEL,'        TTR OF FIRST BLOCK OF TEXT'              14750000
         BLKENT2 'PDS2ZERO',HEX,.NEXT,02,NEWLIN=YES                     14760000
         BLKENT LABEL,'            ZERO'                                14770000
         BLKENT2 'PDS2TTRN',HEX,.NEXT,06,NEWLIN=YES                     14780000
         BLKENT LABEL,'        TTR OF NOTE LIST/SCATTR'                 14790000
         BLKENT2 'PDS2NL  ',HEX,.NEXT,02,NEWLIN=YES                     14800000
         BLKENT LABEL,'            ENTRIES IN NOTE LIST'                14810000
         BLKENT2 'PDS2ATR1',HEX,.NEXT,02,NEWLIN=YES                     14820000
         BLKENT LABEL,'            FIRST PROGRAM ATTRIBUTE FLAG'        14830000
         BLKFLG 80,'80=PDS2RENT REENTERABLE',24                         14840000
         BLKFLG 40,'40=PDS2REUS REUSABLE',24                            14850000
         BLKFLG 20,'20=PDS2OVLY OVERLAY',24                             14860000
         BLKFLG 10,'10=PDS2TEST TESTRAN',24                             14870000
         BLKFLG 08,'08=PDS2LOAD ONLY LOADABLE',24                       14880000
         BLKFLG 04,'04=PDS2SCTR SCATTER',24  T                          14890000
         BLKFLG 02,'02=PDS2EXEC EXECUTABLE',24                          14900000
         BLKFLG 01,'01=PDS21BLK NO RLD AND ONLY ONE TEXT BLOCK',24      14910000
         BLKENT2 'PDS2ATR2',HEX,.NEXT,02,NEWLIN=YES                     14920000
         BLKENT LABEL,'            SECOND PROGRAM ATTRIBUTE FLAG'       14930000
         BLKFLG 80,'80=PDS2FLVL cannot be processed',24                 14940000
         BLKFLG 40,'40=PDS2ORG0 ORIGIN FIRST TEXT IS ZERO',24           14950000
         BLKFLG 20,'20=PDS2EP0  EPA IS ZERO',24                         14960000
         BLKFLG 10,'10=PDS2NRLD NO RLD ITEMS',24                        14970000
         BLKFLG 08,'08=PDS2NREP CANNOT BE REPROCESSED',24               14980000
         BLKFLG 04,'04=PDS2TSTN TESTRAN SYMBOLS',24                     14990000
         BLKFLG 02,'02=PDS2LEF  CREATED BY LINKAGE EDITOR F',24         15000000
         BLKFLG 01,'01=PDS2REFR REFRESHABLE PROGRAM',24                 15010000
         BLKENT2 'PDS2STOR',HEX,.NEXT,06,NEWLIN=YES                     15020000
         BLKENT LABEL,'        CONTIGUOUS MAIN STORAGE'                 15030000
         BLKENT2 'PDS2FTBL',HEX,.NEXT,04,NEWLIN=YES                     15040000
         BLKENT LABEL,'          LENGTH OF MODULE'                      15050000
         BLKENT2 'PDS2EPA ',HEX,.NEXT,06,NEWLIN=YES                     15060000
         BLKENT LABEL,'        EPA'                                     15070000
         BLKENT2 'PDS2FTB1',HEX,.NEXT,02,NEWLIN=YES                     15080000
         BLKENT LABEL,'            MVS FLAG BYTE 1'                     15090000
         BLKFLG 80,'80=PDSAOSLE PROCESSED BY LINKAGE EDITOR',24         15100000
         BLKFLG 40,'40=PDS2BIG  LARGE PROGRAM OBJECT EXTENSION',24      15110000
         BLKFLG 20,'20=PDS2PAGA PAGE ALIGNMENT',24                      15120000
         BLKFLG 10,'10=PDS2SSI  SSI INFORMATION',24                     15130000
         BLKFLG 08,'08=PDSAPFLG APF SECTION PRESENT',24                 15140000
         BLKFLG 04,'04=PDS2PGMO PROGRAM OBJECT',24                      15150000
         BLKFLG 02,'02=PDS2SIGN PROGRAM OBJECT IS SIGNED',24            15160000
         BLKFLG 01,'01=PDS2XATR PDS2XATTR SECTION',24                   15170000
         BLKENT2 'PDS2FTB2',HEX,.NEXT,02,NEWLIN=YES                     15180000
         BLKENT LABEL,'            MVS FLAG BYTE 2'                     15190000
         BLKFLG 80,'80=PDS2ALTP GENERATED BY THE BINDER',24             15200000
         BLKFLG 10,'10=PDSLRMOD PROGRAM RESIDENCE MODE',24              15210000
         BLKENT2 'PDS2FTB3',HEX,.NEXT,02,NEWLIN=YES                     15220000
         BLKENT LABEL,'            MVS FLAG BYTE 3'                     15230000
         BLKFLG 80,'80=PDS2NMIG PROGRAM OBJECT CANNOT BE CONVERTED',24  15240000
         BLKFLG 40,'40=PDS2PRIM FETCHOPT PRIME WAS SPECIFIED',24        15250000
         BLKFLG 20,'20=PDS2PACK FETCHOPT PACK WAS SPECIFIED',24         15260000
         BLKEND                                                         15270000
         DC     0D'+0'                                                  15280000
* Load Module Scatter Section (PDS2ATR1=PDS2SCTR)                       15290000
LMDDESCS BLKBGN OFF=PASS,LEN=FFF                                        15300000
         BLKENT  LABEL,'Scatter Section',NEWLIN=YES                     15310000
         BLKENT2 'PDS2SLSZ',HEX,.NEXT,04,NEWLIN=YES                     15320000
         BLKENT2 'PDS2TTSZ',HEX,.NEXT,04,NEWLIN=YES                     15330000
         BLKENT2 'PDS2ESDT',HEX,.NEXT,04,NEWLIN=YES                     15340000
         BLKENT2 'PDS2ESDC',HEX,.NEXT,04,NEWLIN=YES                     15350000
         BLKEND                                                         15360000
         DC     0D'+0'                                                  15370000
* Load Module Alias Section (PDS2INDC=PDS2ALIS)                         15380000
LMDDESCA BLKBGN OFF=PASS,LEN=FFF                                        15390000
         BLKENT  LABEL,'Alias Section',NEWLIN=YES                       15400000
         BLKENT2 'PDS2EPM ',HEX,.NEXT,06,NEWLIN=YES                     15410000
         BLKENT2 'PDS2MNM ',CHAR,.NEXT,08,NEWLIN=YES                    15420000
         BLKEND                                                         15430000
         DC     0D'+0'                                                  15440000
* Load Module SSI Section (PDS2FTB1=PDS2SSI)                            15450000
LMDDESCI BLKBGN OFF=PASS,LEN=FFF                                        15460000
         BLKENT  LABEL,'SSI Section',NEWLIN=YES                         15470000
         BLKENT2 'PDSSSIWD',HEX,.NEXT,08,NEWLIN=YES                     15480000
         BLKEND                                                         15490000
         DC     0D'+0'                                                  15500000
* Load Module APF Section (PDS2FTB1=PDSAPFLG)                           15510000
LMDDESCP BLKBGN OFF=PASS,LEN=FFF                                        15520000
         BLKENT  LABEL,'APF Section',NEWLIN=YES                         15530000
         BLKENT2 'PDSAPFCT',HEX,.NEXT,02,NEWLIN=YES                     15540000
         BLKENT LABEL,'            LENGTH OF APF CODE'                  15550000
         BLKENT2 'PDSAPFAC',HEX,.NEXT,02,NEWLIN=YES                     15560000
         BLKENT LABEL,'            APF CODE'                            15570000
         BLKEND                                                         15580000
         DC     0D'+0'                                                  15590000
* Load Module Large Program Section (PDS2FTB1=PDS2BIG)                  15600000
LMDDESCL BLKBGN OFF=PASS,LEN=FFF                                        15610000
         BLKENT  LABEL,'Large Program Section',NEWLIN=YES               15620000
         BLKENT2 'PDS2LLML',HEX,.NEXT,02,NEWLIN=YES                     15630000
         BLKENT2 'PDS2VSTR',HEX,.NEXT,08,NEWLIN=YES                     15640000
         BLKENT2 'PDS2MEPA',HEX,.NEXT,08,NEWLIN=YES                     15650000
         BLKENT2 'PDS2AEPA',HEX,.NEXT,08,NEWLIN=YES                     15660000
         BLKEND                                                         15670000
         DC     0D'+0'                                                  15680000
* Load Module Extended Attribute Section (PDS2FTB1=PDS2XATR)            15690000
LMDDESCE BLKBGN OFF=PASS,LEN=FFF                                        15700000
         BLKENT  LABEL,'Extended Attribute Section',NEWLIN=YES          15710000
         BLKENT2 'PDS2XAT1',HEX,.NEXT,02,NEWLIN=YES                     15720000
         BLKENT2 'PDS2XAT2',HEX,.NEXT,02,NEWLIN=YES                     15730000
         BLKENT2 'Reserved',HEX,.NEXT,02,NEWLIN=YES                     15740000
         BLKEND                                                         15750000
         DC     0D'+0'                                                  15760000
* Basic Entry                                                           15770000
SSIDESC  BLKBGN OFF=0,LEN=FFF                                           15780000
         BLKENT2 'PDS2NAME',CHAR,.NEXT,08,NEWLIN=YES                    15790000
         BLKENT LABEL,'      MEMBER NAME'                               15800000
         BLKENT2 'PDS2TTRP',HEX,.NEXT,06,NEWLIN=YES                     15810000
         BLKENT LABEL,'        TTR OF MEMBER'                           15820000
         BLKENT2 'PDS2INDC',HEX,.NEXT,02,NEWLIN=YES                     15830000
         BLKENT LABEL,'            INDICATOR BYTE'                      15840000
         BLKENT2 'PDSSSIWD',HEX,.NEXT,08,NEWLIN=YES                     15850000
         BLKENT LABEL,'      SSI INFORMATION WORD'                      15860000
         BLKEND                                                         15870000
         DC    (((((*-FMTDIR24)/256)+1)*256)-(*-FMTDIR24))X'00'         15880000
**********************************************************************  15890000
*                                                                    *  15900000
*        Work areas                                                  *  15910000
*                                                                    *  15920000
**********************************************************************  15930000
WORKAREA CSECT ,                                                        15940000
SAVEAREA DC    18A(0)                  Local save area                  15950000
DWORD    DC    D'+0'                   Doubleword                       15960000
INITR14  DC    A(0)                    Save linkage                     15970000
PRTR14   DC    A(0)                    Save linkage                     15980000
DIRFMT14 DC    A(0)                    Save linkage                     15990000
W#PRMBGN DC    A(0)                    Start of PARM=                   16000000
DIRCNT   DC    PL4'+0'                 Directory block count            16010000
DIRUSD   DC    PL4'+0'                 Directory block count used       16020000
DIROFL   DC    PL4'+0'                 Overflow directory block count   16030000
MBRCNT   DC    PL4'+0'                 Member count                     16040000
FLAG     DC    AL1(0)                  Flags                            16050000
FLAGDBG  EQU   X'80'                   DEBUG                            16060000
FLAGDMP  EQU   X'40'                   DUMP                             16070000
FLAGFMT  EQU   X'20'                   FORMAT                           16080000
*                                                                       16090000
STOWLIST DC    0D'0'                   List of member names for STOW    16100000
STOWMBR  DC    CL8' '                  Name of member                   16110000
STOWTTR  DC    XL3'0'                  TTR of first record              16120000
STOWSIZ  DC    X'00'                   Flag byte+size of user data      16130000
*                                                                       16140000
         DC    0D'0'                                                    16150000
DIRENT   DC    XL256'0'                Directory block                  16160000
*                                                                       16170000
W#OPEN   OPEN  (0),MF=L                                                 16180000
*                                                                       16190000
DIRDCB   DCB   BLKSIZE=256,DDNAME=SYSUT1,DEVD=DA,DSORG=PS,EODAD=EOD,   *16200000
               MACRF=(R),EXLST=DIRJFCB                                  16210000
*                                                                       16220000
         READ  DIRDECB,SF,,,'S',MF=L                                    16230000
*                                                                       16240000
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X16250000
               RECFM=FBA,LRECL=133                                      16260000
*                                                                       16270000
         DC    0A(0)                                                    16280000
DIRJFCB  DC    AL1(128+7),AL3(MYJFCB)  EXLST for RDJFCB                 16290000
*                                                                       16300000
MYJFCB   DC    XL176'0'                JFCB                             16310000
W#LINE   DC    CL133' '                Print line                       16320000
CURDATE  DC    A(0)                    Current date                     16330000
JULWRK2  DC    A(0)                    Conversion work area             16340000
*                                                                       16350000
JULWRK4  DC    P'+365'                 Julian to Gregorian table        16360000
         DC    P'+01'                                                   16370000
         DC    P'+31'                                                   16380000
         DC    P'+30'                                                   16390000
         DC    P'+31'                                                   16400000
         DC    P'+30'                                                   16410000
         DC    P'+31'                                                   16420000
         DC    P'+31'                                                   16430000
         DC    P'+30'                                                   16440000
         DC    P'+31'                                                   16450000
         DC    P'+30'                                                   16460000
         DC    P'+31'                                                   16470000
JULWRK6  DC    P'+28'                                                   16480000
JULTBL1  DC    P'+31'                                                   16490000
*                                                                       16500000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec' Month table      16510000
TIMWRK4  DC    X'402021204B20204B20204B2020' Edited time                16520000
LNCT     DC    PL2'+99'                Line counter                     16530000
PGCT     DC    PL2'+0'                 Page counter                     16540000
*                                                                       16550000
HD1      DC    CL133'1'                Heading line                     16560000
         ORG   HD1+1                                                    16570000
HD1DATE  DC    C'            '                                          16580000
         DC    C' '                                                     16590000
HD1TOD   DC    C'HH:MM:SS'                                              16600000
         DC    C' '                                                     16610000
         ORG   HD1+66-(20/2)                                            16620000
HD1DATA  DC    C'Format PDS Directory'                                  16630000
         ORG   HD1+L'HD1-8                                              16640000
HD1PG    DC    C'Page'                                                  16650000
HD1PGCT  DC    C' 123'                                                  16660000
*                                                                       16670000
W#DMPRGS DS    16A                                                      16680000
W#DMPOFF DS    A                                                        16690000
W#DUP1ST DS    A                                                        16700000
W#DMPFLG DS    X                                                        16710000
W#DMP1ST EQU   X'80'                                                    16720000
W#DMPDUP EQU   X'40'                                                    16730000
*                                                                       16740000
W#L      DC    0D'+0'                                                   16750000
W#L0     DC    AL1(0)                                                   16760000
W#L1     DC    AL1(0)                                                   16770000
W#L2     DC    AL1(0)                                                   16780000
W#L3     DC    AL1(0)                                                   16790000
W#L4     DC    AL1(0)                                                   16800000
W#L5     DC    AL1(0)                                                   16810000
W#L6     DC    AL1(0)                                                   16820000
W#L7     DC    AL1(0)                                                   16830000
W#FREGS  DC    16A(0)                                                   16840000
W#FMTFLA DC    A(0)                                                     16850000
W#FDWD   DC    D'0'                                                     16860000
W#FADDR  DC    A(0)                                                     16870000
W#FBGNOF DC    A(0)                                                     16880000
W#FTEMP  DC    CL9' '                                                   16890000
*                                                                       16900000
WORKEND  DC    0D'0'                   End of work areas                16910000
INSTGDIR DC    1024XL100'0'            In storage directory buffer      16920000
DIRTBLND EQU   *                       End of buffer                    16930000
         DC    (((((*-WORKAREA)/256)+1)*256)-(*-WORKAREA))X'00'         16940000
**********************************************************************  16950000
*                                                                    *  16960000
*        DSECTs and equates                                          *  16970000
*                                                                    *  16980000
**********************************************************************  16990000
*********************************************************************** 17000000
*                                                                     * 17010000
*        Special directory DSECT for SPF statistics                   * 17020000
*                                                                     * 17030000
*********************************************************************** 17040000
PDS2     DSECT ,              PDS2PTR                                   17050000
PDS2NAME DS    CL8            MEMBER NAME OR ALIAS NAME                 17060000
PDS2TTRP DS    CL3            TTR OF FIRST BLOCK OF NAMED MEMBER        17070000
PDS2LNRM EQU   X'00'          NORMAL CASE                               17080000
PDS2LLNK EQU   X'01'          IF DCB OPERAND IN BLDL MACRO INTRUCTION   17090000
*                             WAS SPECIFIED AS ZERO, NAME WAS FOUND IN  17100000
*                             LINK LIBRARY                              17110000
PDS2LJOB EQU   X'02'          IF DCB OPERAND IN BLDL MACRO INTRUCTION   17120000
*                             WAS SPECIFIED AS ZERO, NAME WAS FOUND IN  17130000
*                             JOB LIBRARY                               17140000
PDS2INDC DS    B              INDICATOR BYTE                            17150000
PDS2ALIS EQU   X'80'          NAME IN THE FIELD PDS2NAME IS AN ALIAS    17160000
PDS2NTTR EQU   X'40'+X'20'    NUMBER OF TTR'S IN THE USER DATA FIELD    17170000
PDS2LUSR EQU   X'10'+X'08'+X'04'+X'02'+X'01' LENGTH OF USER DATA FIELD  17180000
*                             IN HALF WORDS                             17190000
* End of shortest possible entry.  Start of load module attributes      17200000
PDS2USRD DS    0C             START OF VARIABLE LENGTH USER DATA FIELD  17210000
PDS2TTRT DS    CL3            TTR OF FIRST BLOCK OF TEXT                17220000
PDS2ZERO DS    C              ZERO                                      17230000
PDS2TTRN DS    CL3            TTR OF NOTE LIST OR SCATTER/TRANSLATION   17240000
*                             TABLE.  USED FOR PROGRAM IN SCATTER LOAD  17250000
*                             FORMAT OR OVERLAY STRUCTURE ONLY.         17260000
PDS2NL   DS    FL1            NUMBER OF ENTRIES IN NOTE LIST FOR        17270000
*                             PROGRAM IN OVERLAY STRUCTURE              17280000
PDS2ATR  DS    0BL2           TWO-BYTE PROGRAM ATTRIBUTE FIELD          17290000
PDS2ATR1 DS    B              FIRST BYTE OF PROGRAM ATTRIBUTE FIELD     17300000
PDS2RENT EQU   X'80'          REENTERABLE                               17310000
PDS2REUS EQU   X'40'          REUSABLE                                  17320000
PDS2OVLY EQU   X'20'          IN OVERLAY STRUCTURE                      17330000
PDS2TEST EQU   X'10'          PROGRAM TO BE TESTED - TESTRAN            17340000
PDS2LOAD EQU   X'08'          ONLY LOADABLE                             17350000
PDS2SCTR EQU   X'04'          SCATTER FORMAT                            17360000
PDS2EXEC EQU   X'02'          EXECUTABLE                                17370000
PDS21BLK EQU   X'01'          IF ZERO, PROGRAM CONTAINS MULTIPLE        17380000
*                             RECORDS WITH AT LEAST ONE BLOCK OF TEXT.  17390000
*                             IF ONE, PROGRAM CONTAINS NO RLD ITEMS AND 17400000
*                             ONLY ONE BLOCK OF TEXT.                   17410000
PDS2ATR2 DS    B              SECOND BYTE OF PROGRAM ATTRIBUTE FIELD    17420000
PDS2FLVL EQU   X'80'          If one, the program cannot be processed   17430000
*                             by the E level of the linkage editor      17440000
*                             from the early days of OS/360.            17450000
*                             IF OFF, THE PROGRAM CAN BE PROCESSED BY   17460000
*                             ANY LEVEL OF THE LINKAGE EDITOR OR THE    17470000
*                             BINDER.                                   17480000
PDS2ORG0 EQU   X'40'          ORIGIN OF FIRST BLOCK OF TEXT IS ZERO     17490000
PDS2EP0  EQU   X'20'          ENTRY POINT IS ZERO                       17500000
PDS2NRLD EQU   X'10'          PROGRAM CONTAINS NO RLD ITEMS             17510000
PDS2NREP EQU   X'08'          PROGRAM CANNOT BE REPROCESSED BY LINKAGE  17520000
*                             EDITOR OR BINDER.                         17530000
PDS2TSTN EQU   X'04'          PROGRAM CONTAINS TESTRAN SYMBOL CARDS     17540000
PDS2LEF  EQU   X'02'          PROGRAM CREATED BY LINKAGE EDITOR F       17550000
PDS2REFR EQU   X'01'          REFRESHABLE PROGRAM                       17560000
PDS2STOR DS    FL3            TOTAL CONTIGUOUS MAIN STORAGE REQUIREMENT 17570000
*                             OF PROGRAM                                17580000
PDS2FTBL DS    FL2            LENGTH OF FIRST BLOCK OF TEXT             17590000
PDS2EPA  DS    AL3            ENTRY POINT ADDRESS ASSOCIATED WITH       17600000
*                             MEMBER NAME OR WITH ALIAS NAME IF ALIAS   17610000
*                             INDICATOR IS ONE                          17620000
         DS    0AL3           LINKAGE EDITOR ASSIGNED ORIGIN OF FIRST   17630000
*                             BLOCK OF TEXT (OS/360 USE OF FIELD)       17640000
PDS2FTBO DS    0BL3           FLAG BYTES (MVS USE OF FIELD)             17650000
PDS2FTB1 DS    B              BYTE 1 OF PDS2FTBO                        17660000
PDSAOSLE EQU   X'80'          Program has been processed by OS/VS1 or   17670000
*                             OS/VS2 linkage editor or binder           17680000
PDS2BIG  EQU   X'40'          THE LARGE PROGRAM OBJECT EXTENSION        17690000
*                             EXISTS BECAUSE THIS PROGRAM REQUIRES AT   17700000
*                             LEAST 16 MB BYTES OF VIRTUAL STORAGE      17710000
PDS2PAGA EQU   X'20'          PAGE ALIGNMENT REQUIRED FOR PROGRAM       17720000
PDS2SSI  EQU   X'10'          SSI INFORMATION PRESENT                   17730000
PDSAPFLG EQU   X'08'          INFORMATION IN PDSAPF IS VALID            17740000
PDS2PGMO EQU   X'04'          PROGRAM OBJECT. THE PDS2FTB3              17750000
*                             FIELD IS VALID AND CONTAINS ADDITIONAL    17760000
*                             FLAGS                                     17770000
PDS2LFMT EQU   PDS2PGMO       ALTERNATE NAME FOR PDS2PGMO               17780000
PDS2SIGN EQU   X'02'          PROGRAM OBJECT IS SIGNED. VERIFIED ON     17790000
*                             LOAD IF DIRECTED BY SECURITY PRODUCT      17800000
PDS2XATR EQU   X'01'          PDS2XATTR SECTION                         17810000
PDS2FTB2 DS    B              BYTE 2 OF PDS2FTBO                        17820000
PDS2ALTP EQU   X'80'          ALTERNATE PRIMARY FLAG. IF ON (FOR A      17830000
*                             PRIMARY NAME), INDICATES THE PRIMARY      17840000
*                             NAME WAS GENERATED BY THE BINDER.         17850000
*                             CAN ONLY BE ON FOR PROGRAM OBJECT.        17860000
*                             CANNOT BE ON FOR ALIAS NAME               17870000
PDSLRMOD EQU   X'10'          PROGRAM RESIDENCE MODE                    17880000
PDSAAMOD EQU   X'08'+X'04'    ALIAS ENTRY POINT ADDRESSING MODE         17890000
*                             B'00' = AMODE 24                          17900000
*                             B'10' = AMODE 31                          17910000
*                             B'11' = AMODE ANY                         17920000
*                             B'01' = AMODE 64                          17930000
PDSMAMOD EQU   X'02'+X'01'    MAIN ENTRY POINT ADDRESSING MODE          17940000
*                             B'00' = AMODE 24                          17950000
*                             B'10' = AMODE 31                          17960000
*                             B'11' = AMODE ANY                         17970000
*                             B'01' = AMODE 64                          17980000
PDS2RLDS DS    0XL1           NUMBER OF RLD/CONTROL RECORDS WHICH       17990000
*                             FOLLOW THE FIRST BLOCK OF TEXT            18000000
PDS2FTB3 DS    B              BYTE 3 OF PDS2FTBO                        18010000
PDS2NMIG EQU   X'80'          THIS PROGRAM OBJECT CANNOT BE CONVERTED   18020000
*                             TO A LOAD MODULE                          18030000
PDS2PRIM EQU   X'40'          FETCHOPT PRIME WAS SPECIFIED              18040000
PDS2PACK EQU   X'20'          FETCHOPT PACK WAS SPECIFIED               18050000
PDSBCEND EQU   *              END OF BASIC SECTION                      18060000
PDSBCLN  EQU   PDSBCEND-PDS2 - LENGTH OF BASIC SECTION                  18070000
*        THE FOLLOWING SECTION IS FOR PROGRAMS WITH SCATTER LOAD        18080000
PDSS01   EQU   *              START OF SCATTER LOAD SECTION             18090000
PDS2SLSZ DS    FL2            NUMBER OF BYTES IN SCATTER LIST           18100000
PDS2TTSZ DS    FL2            NUMBER OF BYTES IN TRANSLATION TABLE      18110000
PDS2ESDT DS    CL2            IDENTIFICATION OF ESD ITEM (ESDID) OF     18120000
*                             CONTROL SECTION TO WHICH FIRST BLOCK OF   18130000
*                             TEXT BELONGS                              18140000
PDS2ESDC DS    CL2            IDENTIFICATION OF ESD ITEM (ESDID) OF     18150000
*                             CONTROL SECTION CONTAINING ENTRY POINT    18160000
PDSS01ND EQU   *              END OF SCATTER LOAD SECTION               18170000
PDSS01LN EQU   PDSS01ND-PDSS01 - LENGTH OF SCATTER LOAD SECTION         18180000
*        THE FOLLOWING SECTION IS FOR PROGRAMS WITH ALIAS NAMES         18190000
PDSS02   EQU   *              START OF ALIAS SECTION                    18200000
PDS2EPM  DS    AL3            ENTRY POINT FOR MEMBER NAME               18210000
PDS2MNM  DS    CL8            MEMBER NAME OF PROGRAM. WHEN THE          18220000
*                             FIRST FIELD (PDS2NAME) IS AN ALIAS NAME,  18230000
*                             THIS FIELD CONTAINS THE ORIGINAL NAME OF  18240000
*                             THE MEMBER EVEN AFTER THE MEMBER HAS      18250000
*                             BEEN RENAMED.                             18260000
PDSS02ND EQU   *              END OF ALIAS SECTION                      18270000
PDSS02LN EQU   PDSS02ND-PDSS02 - LENGTH OF ALIAS SECTION                18280000
*        THE FOLLOWING SECTION IS FOR SSI INFORMATION AND IS ON         18290000
*        A HALF-WORD BOUNDARY                                           18300000
PDSS03   DS    0H             FORCE HALF-WORD ALIGNMENT FOR SSI         18310000
*                             SECTION                                   18320000
PDSSSIWD DS    0CL4           SSI INFORMATION WORD                      18330000
PDSCHLVL DS    FL1            CHANGE LEVEL OF MEMBER                    18340000
PDSSSIFB DS    B              SSI FLAG BYTE                             18350000
PDSFORCE EQU   X'40'          A FORCE CONTROL CARD WAS USED WHEN        18360000
*                             EXECUTING THE IHGUAP PROGRAM              18370000
PDSUSRCH EQU   X'20'          A CHANGE WAS MADE TO MEMBER BY THE        18380000
*                             INSTALLATION, AS OPPOSED TO AN            18390000
*                             IBM-DISTRIBUTED CHANGE                    18400000
PDSEMFIX EQU   X'10'          SET WHEN AN EMERGENCY IBM-AUTHORIZED      18410000
*                             PROGRAM 'FIX' IS MADE, AS OPPOSED TO      18420000
*                             CHANGES THAT ARE INCLUDED IN AN           18430000
*                             IBM-DISTRIBUTED MAINTENANCE PACKAGE       18440000
PDSDEPCH EQU   X'08'          A CHANGE MADE TO THE MEMBER IS DEPENDENT  18450000
*                             UPON A CHANGE MADE TO SOME OTHER MEMBER   18460000
*                             IN THE SYSTEM                             18470000
PDSSYSGN EQU   X'04'+X'02'    FLAGS THAT INDICATE WHETHER A             18480000
*                             CHANGE TO THE MEMBER WILL NECESSITATE A   18490000
*                             PARTIAL OR COMPLETE REGENERATION OF THE   18500000
*                             SYSTEM                                    18510000
PDSNOSGN EQU   X'00'          NOT CRITICAL FOR SYSTEM GENERATION        18520000
PDSCMSGN EQU   X'02'          MAY REQUIRE COMPLETE REGENERATION         18530000
PDSPTSGN EQU   X'04'          MAY REQUIRE PARTIAL REGENERATION          18540000
PDSIBMMB EQU   X'01'          MEMBER IS SUPPLIED BY IBM                 18550000
PDSMBRSN DS    CL2            MEMBER SERIAL NUMBER                      18560000
PDSS03ND EQU   *              END OF SSI SECTION                        18570000
PDSS03LN EQU   PDSS03ND-PDSS03   LENGTH OF SSI SECTION                  18580000
*        THE FOLLOWING SECTION IS FOR APF INFORMATION                   18590000
PDSS04   EQU   *              START OF APF SECTION                      18600000
PDSAPF   DS    0CL2           PROGRAM AUTHORIZATION FACILITY (APF)      18610000
*                             FIELD                                     18620000
PDSAPFCT DS    FL1            LENGTH OF PROGRAM AUTHORIZATION CODE      18630000
*                             (PDSAPFAC) IN BYTES                       18640000
PDSAPFAC DS    C              PROGRAM AUTHORIZATION CODE                18650000
PDSS04ND EQU   *              END OF APF SECTION                        18660000
PDSS04LN EQU   PDSS04ND-PDSS04   LENGTH OF APF SECTION                  18670000
*        THE FOLLOWING SECTION IS FOR LARGE (16M OR LARGER) PROGRAM     18680000
*                      OBJECTS                                          18690000
PDSLPO   EQU   *              START OF LARGE PROGRAM OBJECT SECTION     18700000
PDSLLM   EQU   PDSLPO         ALTERNATE NAME FOR PDSLPO                 18710000
PDS2LPOL DS    FL1            LARGE PROGRAM OBJECT SECTION LENGTH       18720000
         ORG   PDS2LPOL                                                 18730000
PDS2LLML DS    FL1            ALTERNATE NAME FOR PDS2LLML               18740000
PDS2VSTR DS    FL4            VIRTUAL STORAGE REQUIREMENT FOR THIS      18750000
*                             PROGRAM                                   18760000
PDS2MEPA DS    FL4            MAIN ENTRY POINT OFFSET                   18770000
PDS2AEPA DS    FL4            ALIAS ENTRY POINT OFFSET. ONLY VALID      18780000
*                             IF THIS IS A DIRECTORY ENTRY FOR AN       18790000
*                             ALIAS                                     18800000
PDSLPOND EQU   *              END OF LARGE PROGRAM OBJECT SECTION       18810000
PDSLLMND EQU   PDSLPOND       ALTERNATE NAME FOR PDSLPOND               18820000
PDSLPOLN EQU   PDSLPOND-PDSLPO  LENGTH OF LLM SECTION                   18830000
PDSLLMLN EQU   PDSLPOLN       ALTERNATE NAME FOR PDSLPOLN               18840000
*        The following section is for extended attributes.              18850000
*        It is present only when bit PDS2XATR is on.                    18860000
PDS2XAT  EQU   *              Start of extended attributes              18870000
PDS2XAT0 DS    FL1            Extended attribute byte 0                 18880000
PDS2XATM EQU   X'0F'          Bits 4-7 of PDS2XAT0 identify the         18890000
*                             number of bytes (could be 0) starting     18900000
*                             at PDS2XATO                               18910000
PDS2XAT1 DS    FL1            Extended attribute byte 1                 18920000
PDS2LPRM EQU   X'80'          PARM > 100 chars allowed                  18930000
         DS    FL1            Reserved                                  18940000
PDS2XATO EQU   *              Start of optional fields. Number of       18950000
*                             bytes is in PDS2XAT0 masked by            18960000
*                             PDS2XATM                                  18970000
DIREND   EQU   *                                                        18980000
DIR      EQU   PDS2,*-PDS2                                              18990000
*********************************************************************** 19000000
*                                                                     * 19010000
*        Formatting field descriptor layout                           * 19020000
*                                                                     * 19030000
*********************************************************************** 19040000
BLK      DSECT                                                          19050000
BLKFIRST DS    AL2                 Start offset                         19060000
BLKSIZE  DS    AL2                 Block length                         19070000
BLKHDNXT EQU   *                                                        19080000
         ORG   BLK                                                      19090000
*        Common area                                                    19100000
BLKTYPE  DS    X                   Descriptor type                      19110000
BLKEND   EQU   0                   End of block                         19120000
BLKCHAR  EQU   4                   Character field                      19130000
BLKHEX   EQU   8                   Hex field                            19140000
BLKCONST EQU   12                  Constant                             19150000
BLKFLAG  EQU   16                  Flag bit                             19160000
*                                  BLKFLAG+1=Flag byte                  19170000
BLKBGN   DS    0X                  Common starting point                19180000
*        Character field                                                19190000
BLKOFF   DS    AL1                 Offset into output area              19200000
BLKDISP  DS    AL2                 Field displacement                   19210000
BLKCHRSC DS    AL1                 SCON of length if variable           19220000
BLKCHRLN DS    AL1                 Output length                        19230000
BLKCHRNX EQU   *                                                        19240000
         ORG   BLKBGN                                                   19250000
*        Hex field                                                      19260000
         DS    AL1                 Offset into output area              19270000
         DS    AL2                 Field displacement                   19280000
BLKHEXOF DS    AL1                 Input offset                         19290000
BLKHEXSC DS    AL1                 SCON of length if variable           19300000
BLKHEXLN DS    AL1                 Output length                        19310000
BLKHEXNX EQU   *                                                        19320000
         ORG   BLKBGN                                                   19330000
*        Character field                                                19340000
         DS    X                   Offset into output area              19350000
BLKDTALN DS    X                   Output length                        19360000
BLKDATA  DS    C                   Constant                             19370000
BLKDTANX EQU   *                                                        19380000
         ORG   BLKBGN                                                   19390000
*        Flag definition                                                19400000
         DS    X                   Offset into output area              19410000
BLKFLG   DS    X                   Flag bit                             19420000
BLKFLGDL DS    X                   Flag description length -1           19430000
BLKFLGD  DS    C                   Flag description                     19440000
BLKFLGNX EQU   *                                                        19450000
R0       EQU   0                                                        19460000
R1       EQU   1                                                        19470000
R2       EQU   2                                                        19480000
R3       EQU   3                                                        19490000
R4       EQU   4                                                        19500000
R5       EQU   5                                                        19510000
R6       EQU   6                                                        19520000
R7       EQU   7                                                        19530000
R8       EQU   8                                                        19540000
R9       EQU   9                                                        19550000
R10      EQU   10                                                       19560000
R11      EQU   11                                                       19570000
R12      EQU   12                                                       19580000
R13      EQU   13                                                       19590000
R14      EQU   14                                                       19600000
R15      EQU   15                                                       19610000
JFCB     DSECT                                                          19620000
         IEFJFCBN                                                       19630000
         DCBD DSORG=PO                                                  19640000
         END  FMTDIR24                                                  19650000
