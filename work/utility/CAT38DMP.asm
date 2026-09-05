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
         BLKEND                                                         00470000
         DC    AL1(BLKEND)         End of block descriptor              00480000
         MEND                                                           00490000
         MACRO                                                          00500000
&LBL     BLKENT &TYPE,&OFF,&LEN,&DIGIT=0,&NEWLIN=NO,&OFFSET=            00510000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             00520000
         LCLA  &IOFF,&ILEN,&MAX,&WRKOFF                                 00530000
         LCLC  &LENSAV,&LNSV                                            00540000
         AIF   ('&TYPE' EQ 'HEX').LBLHEX                                00550000
         AIF   (T'&LBL NE 'O').LBLER1                                   00560000
.LBLHEX  ANOP                                                           00570000
&MAX     SETA  120                                                      00580000
         AIF   ('&NEWLIN' EQ 'YES').DONEW                               00590000
         AIF   ('&TYPE' NE 'LABEL').NLB                                 00600000
         AIF   (T'&OFFSET EQ 'O').NOFF                                  00610000
&WRKOFF  SETA  &OFFSET+K'&OFF-10                                        00620000
         AIF   (&WRKOFF LT &MAX).OFFOK                                  00630000
         MNOTE 8,'OFFSET PUSHES LITERAL PAST LINE END'                  00640000
         MEXIT                                                          00650000
.OFFOK   ANOP                                                           00660000
&SETOFF  SETA  &OFFSET-11                                               00670000
         AGO   .NONEW                                                   00680000
.NOFF    ANOP                                                           00690000
&WRKOFF  SETA  &SETOFF+K'&OFF-1                                         00700000
         AGO   .CHK                                                     00710000
.NLB     ANOP                                                           00720000
         AIF   ('&LEN'(1,1) LT '0').NONEW                               00730000
         BLKCVT &LEN                                                    00740000
&WRKOFF  SETA  &SETOFF+&HEX+2                                           00750000
.CHK     ANOP                                                           00760000
         AIF   (&WRKOFF LT &MAX).NONEW                                  00770000
.DONEW   ANOP                                                           00780000
&SETOFF  SETA  0                                                        00790000
.NONEW   ANOP                                                           00800000
         AIF   ('&TYPE' NE 'LABEL').NOLABEL If not a label              00810000
         DC    AL1(BLKCONST)       Constant                             00820000
&ILEN    SETA  K'&OFF-3                                                 00830000
         DC    AL1(&SETOFF)        Offset to output                     00840000
         DC    AL1(&ILEN)          Length                               00850000
&ILEN    SETA  &ILEN+1                                                  00860000
         DC    CL&ILEN&OFF         Character constant                   00870000
&ILEN    SETA  &ILEN-1                                                  00880000
         AGO   .SETOFF                                                  00890000
.NOLABEL ANOP                                                           00900000
&LENSAV  SETC  ''                                                       00910000
         AIF   (T'&LBL EQ 'O').NXTCHK                                   00920000
         AIF   ('&LBL' LT '1').LBLER                                    00930000
         AIF   ('&LBL' GT '7').LBLER                                    00940000
.NXTCHK  ANOP                                                           00950000
         AIF   ('&OFF' EQ '.NEXT').NEXT                                 00960000
         BLKCVT &OFF               Convert offset from hex              00970000
&IOFF    SETA  &HEX-&SEGOFF                                             00980000
         AGO   .LBLCHK                                                  00990000
.NEXT    ANOP                                                           01000000
&LENSAV  SETC  'X''8000''+'                                             01010000
&IOFF    SETA  0                                                        01020000
.LBLCHK  ANOP                                                           01030000
         AIF   (T'&LBL EQ 'O').LENDONE                                  01040000
&LENSAV  SETC  'X''8000''+X''&LBL.000''+'                               01050000
.LENDONE ANOP                                                           01060000
         AIF   ('&OFF' EQ '.NEXT').OFFDONE                              01070000
         AIF   (&HEX LT &SEGOFF).OFFLOW If before block start           01080000
         AIF   (&HEX GT &SEGEND).OFFHI If after block end               01090000
.OFFDONE ANOP                                                           01100000
         AIF   ('&TYPE' NE 'HEX').NOHEX If not hex                      01110000
         AIF   ('&DIGIT' NE '0' AND '&DIGIT' NE '1').BADDIG             01120000
         DC    AL1(BLKHEX)         Hex field                            01130000
         DC    AL1(&SETOFF)        Offset to output                     01140000
         DC    AL2(&LENSAV&IOFF)   Field offset                         01150000
         DC    AL1(&DIGIT)         Digit offset                         01160000
         AGO   .DOLEN                                                   01170000
.NOHEX   AIF   ('&TYPE' NE 'CHAR').NOTYPE If not character              01180000
         DC    AL1(BLKCHAR)        Character field                      01190000
         DC    AL1(&SETOFF)        Offset to output                     01200000
         DC    AL2(&LENSAV&IOFF)   Field offset                         01210000
.DOLEN   ANOP                                                           01220000
         AIF   ('&LEN'(1,1) LT '0').CHRSCN                              01230000
         BLKCVT &LEN               Validate length                      01240000
&ILEN    SETA  &HEX-1              Get machine length                   01250000
         DC    AL2(&ILEN)          Length                               01260000
         AGO   .SETOFF                                                  01270000
.CHRSCN  ANOP  ,                                                        01280000
         AIF   ('&LEN'(1,1) EQ '(').GETLBL                              01290000
         DC    SL2(&LEN)           Length                               01300000
         AGO   .LENEND                                                  01310000
.GETLBL  ANOP                                                           01320000
         AIF   ('&LEN'(2,1) LT '1').LBLER                               01330000
         AIF   ('&LEN'(2,1) GT '7').LBLER                               01340000
         AIF   ('&LEN'(3,1) NE ')').LBLER                               01350000
&LNSV    SETC  'W#L'.'&LEN'(2,1)                                        01360000
         DC    SL2(&LNSV)                                               01370000
.LENEND  ANOP                                                           01380000
&ILEN    SETA  1                   Fake length                          01390000
.SETOFF  ANOP                                                           01400000
&SETOFF  SETA  &SETOFF+&ILEN+2                                          01410000
         AIF   (&SETOFF GT &MAX).NEEDNEW                                01420000
         MEXIT                                                          01430000
.NOTYPE  MNOTE 8,'Type missing of invalid'                              01440000
         MEXIT                                                          01450000
.BADDIG  MNOTE 8,'Digit not 0 or 1'                                     01460000
         MEXIT                                                          01470000
.OFFLOW  MNOTE 8,'Offset to low'                                        01480000
         MEXIT                                                          01490000
.OFFHI   MNOTE 8,'Offset to high'                                       01500000
         MEXIT                                                          01510000
.LBLER   MNOTE 8,'Label must be 0, 1, 2 or 3'                           01520000
         MEXIT                                                          01530000
.LBLER1  MNOTE 8,'Label only valid with TYPE HEX'                       01540000
         MEXIT                                                          01550000
.NEEDNEW MNOTE 4,'Need NEWLIN=YES, max output area exceeded'            01560000
         MEND                                                           01570000
         MACRO                                                          01580000
&N       BLKBGN &OFF=,&LEN=                                             01590000
         GBLA  &SEGOFF,&HEX,&SETOFF,&SEGEND                             01600000
         LCLC  &SEGSTR                                                  01610000
&SETOFF  SETA  0                                                        01620000
&N       DC    0D'0'                                                    01630000
         AIF   ('&OFF' EQ 'PASS').VAR                                   01640000
         BLKCVT &OFF,OFF                                                01650000
&SEGOFF  SETA  &HEX                                                     01660000
&SEGSTR  SETC  '&HEX'                                                   01670000
         AIF   (&HEX GE 0).NOSIGN                                       01680000
&SEGSTR  SETC  '-'.'&HEX'                                               01690000
         AGO   .NOSIGN                                                  01700000
.VAR     ANOP                                                           01710000
&SEGSTR  SETC  'X''8000'''                                              01720000
.NOSIGN  ANOP                                                           01730000
         BLKCVT &LEN,LEN                                                01740000
         AIF   ('&OFF' EQ 'PASS').VAR1                                  01750000
&SEGEND  SETA  &HEX+&SEGSTR                                             01760000
         AGO   .VAR2                                                    01770000
.VAR1    ANOP                                                           01780000
&SEGEND  SETA  &HEX                                                     01790000
.VAR2    ANOP                                                           01800000
         DC    AL2(&SEGSTR)        Start offset                         01810000
         DC    AL2(&HEX)           Block length                         01820000
.MEND    MEND                                                           01830000
*********************************************************************** 01840000
*                                                                     * 01850000
* Module CAT38DMP                                                     * 01860000
*                                                                     * 01870000
* Generate formatted and dump of MVS 3.8 VSAM catalog records.        * 01880000
*                                                                     * 01890000
*********************************************************************** 01900000
*                                                                     * 01910000
* DD Statements                                                       * 01920000
*    STEPLIB       Load library containing load module.               * 01930000
*                  Must be APF authorized and PGM must be AC(1).      * 01940000
*    SYSVSAM       Catalog data set is specified here.                * 01950000
*    SYSPRINT      Output listing.                                    * 01960000
*                                                                     * 01970000
* Parameters                                                          * 01980000
*    All parameters are seperated by commas.                          * 01990000
*    DUMP          Dump catalog records.                              * 02000000
*    FORMAT        Format catalog records.                            * 02010000
*    START=n       Starting catalog record to process.                * 02020000
*                  The n is the starting catalog record number.       * 02030000
*                  Default is 1.                                      * 02040000
*                  Example:START=10                                   * 02050000
*    COUNT=n       Number of catalog records to process.              * 02060000
*                  The n is the number of caalog records.             * 02070000
*                  Default is all records.                            * 02080000
*                  Example:COUNT=1                                    * 02090000
*    TYPE=(t,t..)  Specify record types.                              * 02100000
*                  Specify one or multiple record types to process.   * 02110000
*                  Default is all records.                            * 02120000
*                  Example:TYPE=(A,D,C,I) or TYPE=U                   * 02130000
*    CATALOG=YES   The VSAM object is a CATALOG.                      * 02140000
*                                                                     * 02150000
* Sample JCL                                                          * 02160000
*    //STEP    EXEC PGM=CAT38DMP,PARM='FORMAT,TYPE=(C,D,I)'           * 02170000
*    //STEPLIB  DD  DSN=loadlib,DISP=SHR                              * 02180000
*    //SYSVSAM  DD  DSN=catalog,DISP=SHR                              * 02190000
*    //SYSPRINT DD  SYSOUT=*                                          * 02200000
*                                                                     * 02210000
*********************************************************************** 02220000
*                                                                     * 02230000
* Known catalog record types                                          * 02240000
*         Type     Description                                        * 02250000
*           A      Non-VSAM                                           * 02260000
*           C      Cluster                                            * 02270000
*           D      Data                                               * 02280000
*           E      Cluster Extention                                  * 02290000
*           F      Free                                               * 02300000
*           I      Index                                              * 02310000
*           L      Catalog Control Record                             * 02320000
*           U      User Catalog                                       * 02330000
*           V      Volume                                             * 02340000
*           W      Volume Extension                                   * 02350000
*           X      Alias                                              * 02360000
*                                                                     * 02370000
*********************************************************************** 02380000
* Change log:                                                         * 02390000
*   Date   Int Ver   Description                                      * 02400000
* 02/16/20 DSK 1.01  Created                                          * 02410000
*********************************************************************** 02420000
CAT38DMP CSECT                                                          02430000
         USING CAT38DMP,R15                                             02440000
         B     BEGIN                                                    02450000
         DROP  R15                                                      02460000
         DC    AL1(L'PGMID)                                             02470000
PGMID    DC    C'CAT38DMP V1.01 &SYSDATE &SYSTIME'                      02480000
BEGIN    DC    0H'+0'                                                   02490000
         STM   R14,R12,12(R13)                                          02500000
         LR    R11,R15                                                  02510000
         LA    R12,2048(,R11)                                           02520000
         LA    R12,2048(,R12)                                           02530000
         USING CAT38DMP,R11,R12                                         02540000
         L     R14,=A(W#SA)                                             02550000
         ST    R13,4(,R14)                                              02560000
         ST    R14,8(,R13)                                              02570000
         LR    R13,R14                                                  02580000
         USING W#SA,R13                                                 02590000
         L     R15,=A(INIT)                                             02600000
         BALR  R14,R15                                                  02610000
**********************************************************************  02620000
*                                                                    *  02630000
**********************************************************************  02640000
PROC     DS    0H                                                       02650000
         L     R2,W#RPLSAV                                              02660000
         TM    DMPFLG1,DMPDIAG                                          02670001
         BNO   PROCNDG1                                                 02680001
         MVC   LINE+1(10),=C'Before GET'                                02690001
         BAL   R14,PRT                                                  02700001
         BAL   R14,DIAG                                                 02710001
PROCNDG1 DS    0H                                                       02720001
         USING IFGRPL,R2                                                02730000
         MODESET KEY=ZERO                                               02740000
         GET   RPL=(2)                                                  02750000
         MODESET KEY=NZERO                                              02760000
         TM    DMPFLG1,DMPDIAG                                          02770001
         BNO   PROCNDG2                                                 02780001
         MVC   LINE+1(9),=C'After GET'                                  02790001
         BAL   R14,PRT                                                  02800001
         BAL   R14,DIAG                                                 02810001
PROCNDG2 DS    0H                                                       02820001
         CLI   RPLERRCD,RPLEODER       IF END OF DATA                   02830000
         BE    EXIT                                                     02840000
         L     R1,RPLFDBWD                                              02850000
         SR    R0,R0                                                    02860000
         IC    R0,RPLERRCD                                              02870000
         SR    R15,R15                                                  02880000
         IC    R15,RPLRTNCD                                             02890000
         LTR   R15,R15                                                  02900000
         BNZ   ERRGET                                                   02910000
         AP    W#RECRD,=P'+1'                                           02920000
         SHOWCB FIELDS=RECLEN,    DISPLAY THE LENGTH OF THE RECORD     *02930000
               AREA=RECLEN,                                            *02940000
               LENGTH=L'RECLEN,                                        *02950000
               RPL=(2)                                                  02960000
         DROP  R2                                                       02970000
         LTR   R15,R15                                                  02980000
         BNZ   ERRSHRLN                                                 02990000
*                                                                       03000000
         L     R8,SAREA                                                 03010000
         USING CATRCD,R8                                                03020000
         NI    DMPFLAG,255-DMPUNKRC                                     03030000
         CLI   RCDID,C'D'                                               03040000
         BE    PROCCTD                                                  03050000
         CLI   RCDID,C'I'                                               03060000
         BE    PROCCTI                                                  03070000
         CLI   RCDID,C'C'                                               03080000
         BE    PROCCTC                                                  03090000
         CLI   RCDID,C'L'                                               03100000
         BE    PROCCTL                                                  03110000
         CLI   RCDID,C'E'                                               03120000
         BE    PROCCTE                                                  03130000
         CLI   RCDID,C'V'                                               03140000
         BE    PROCCTV                                                  03150000
         CLI   RCDID,C'W'                                               03160000
         BE    PROCCTW                                                  03170000
         CLI   RCDID,C'F'                                               03180000
         BE    PROCCTF                                                  03190000
         CLI   RCDID,C'X'                                               03200000
         BE    PROCCTX                                                  03210000
         CLI   RCDID,C'U'                                               03220000
         BE    PROCCTU                                                  03230000
         CLI   RCDID,C'A'                                               03240000
         BE    PROCCTA                                                  03250000
         CLI   RCDID,0                                                  03260000
         BE    PROCCT00                                                 03270000
         B     PROCCT                                                   03280000
PROCCTA  DS    0H                                                       03290000
         LA    R9,W#RECA                                                03300000
         B     PROCCTND                                                 03310000
PROCCTC  DS    0H                                                       03320000
         LA    R9,W#RECC                                                03330000
         B     PROCCTND                                                 03340000
PROCCTD  DS    0H                                                       03350000
         LA    R9,W#RECD                                                03360000
         B     PROCCTND                                                 03370000
PROCCTE  DS    0H                                                       03380000
         LA    R9,W#RECE                                                03390000
         B     PROCCTND                                                 03400000
PROCCTF  DS    0H                                                       03410000
         LA    R9,W#RECF                                                03420000
         B     PROCCTND                                                 03430000
PROCCTI  DS    0H                                                       03440000
         LA    R9,W#RECI                                                03450000
         B     PROCCTND                                                 03460000
PROCCTL  DS    0H                                                       03470000
         LA    R9,W#RECL                                                03480000
         B     PROCCTND                                                 03490000
PROCCTU  DS    0H                                                       03500000
         LA    R9,W#RECU                                                03510000
         B     PROCCTND                                                 03520000
PROCCTV  DS    0H                                                       03530000
         LA    R9,W#RECV                                                03540000
         B     PROCCTND                                                 03550000
PROCCTW  DS    0H                                                       03560000
         LA    R9,W#RECW                                                03570000
         B     PROCCTND                                                 03580000
PROCCTX  DS    0H                                                       03590000
         LA    R9,W#RECX                                                03600000
         B     PROCCTND                                                 03610000
PROCCT00 DS    0H                                                       03620000
         LA    R9,W#REC00                                               03630000
         B     PROCCTND                                                 03640000
PROCCT   DS    0H                                                       03650000
         LA    R9,W#REC                                                 03660000
         OI    DMPFLAG,DMPUNKRC                                         03670000
PROCCTND DS    0H                                                       03680000
         USING REC,R9                                                   03690000
         AP    RECCT,=P'+1'                                             03700000
*                                                                       03710000
         ICM   R5,15,W#CURRCI                                           03720000
         BZ    PROCPRT                                                  03730000
         SH    R5,=H'1'                                                 03740000
         ST    R5,W#CURRCI                                              03750000
         B     PROC                                                     03760000
PROCPRT  DS    0H                                                       03770000
         ICM   R0,15,W#CINUM                                            03780000
         BZ    PROC                                                     03790000
         BCTR  R0,0                                                     03800000
         ST    R0,W#CINUM                                               03810000
*                                                                       03820000
         TM    DMPFLAG,DMPBYTYP                                         03830000
         BNO   PROCSEL                                                  03840000
         LA    R1,SELTYPES                                              03850000
         LA    R0,L'SELTYPES                                            03860000
PROCSTY  DS    0H                                                       03870000
         CLI   0(R1),C' '                                               03880000
         BE    PROC                                                     03890000
         CLC   RCDID,0(R1)                                              03900000
         BE    PROCSEL                                                  03910000
         LA    R1,1(,R1)                                                03920000
         BCT   R0,PROCSTY                                               03930000
         B     PROC                                                     03940000
*                                                                       03950000
PROCSEL  DS    0H                                                       03960000
         TM    DMPFLAG,DMPDMP+DMPFMT                                    03970000
         BZ    PROC                                                     03980000
         MVC   LINE+1(4),=C'****'                                       03990000
         MVC   LINE+7(6),=C'RBA X'''                                    04000000
         L     R2,W#RPLSAV                                              04010000
         USING IFGRPL,R2                                                04020000
         UNPK  LINE+13(9),RPLDDDD(5)                                    04030000
         DROP  R2                                                       04040000
         TR    LINE+13(8),P#FMTTBL-240                                  04050000
         MVC   LINE+21(7),=C''' LRECL'                                  04060000
         L     R0,RECLEN                                                04070000
         CVD   R0,W#DWORD                                               04080000
         MVC   LINE+28(8),=X'4020206B202120'                            04090000
         ED    LINE+28(8),W#DWORD+5                                     04100000
         LA    R0,6                                                     04110000
PROCLRRJ DS    0H                                                       04120000
         CLI   LINE+29,C' '                                             04130000
         BNE   PROCLRND                                                 04140000
         MVC   LINE+29(8),LINE+30                                       04150000
         BCT   R0,PROCLRRJ                                              04160000
PROCLRND DS    0H                                                       04170000
         TM    DMPFLAG,DMPUNKRC                                         04180000
         BO    PROCINVR                                                 04190000
         MVC   LINE+37(L'RECID),RECID                                   04200000
         B     PROCRCHD                                                 04210000
PROCINVR DS    0H                                                       04220000
         MVC   LINE+37(15),=C'Unknown Type=X'''                         04230000
         UNPK  LINE+52(3),RCDID(2)                                      04240000
         TR    LINE+52(2),P#FMTTBL-240                                  04250000
         MVI   LINE+54,C''''                                            04260000
PROCRCHD DS    0H                                                       04270000
         BAL   R14,PRT                                                  04280000
         TM    DMPFLAG,DMPDMP                                           04290000
         BNO   PROCNODM                                                 04300000
         L     R0,RECLEN                                                04310000
         L     R1,SAREA                                                 04320000
         BAL   R14,DMP                                                  04330000
         BAL   R14,PRT                                                  04340000
PROCNODM DS    0H                                                       04350000
         AP    RECSE,=P'+1'                                             04360000
         TM    DMPFLAG,DMPFMT                                           04370000
         BNO   PROC                                                     04380000
         CLI   RCDID,0                                                  04390000
         BE    PROC00                                                   04400000
* Format header                                                         04410000
         LA    R2,CATRCD                                                04420000
         MVC   LINE+10(6),=C'CATRCD'                                    04430000
         BAL   R14,PRTHD           Print a line                         04440000
         LA    R3,CHD              Formatting layout                    04450000
         BAL   R14,FMT             Format catalog record header         04460000
* Format record type                                                    04470000
         SR    R6,R6                                                    04480000
         ICM   R6,3,RCDSIZ                                              04490000
         ICM   R15,15,RECRT                                             04500000
         BNZR  R15                                                      04510000
* Dump record                                                           04520000
         LA    R2,CTGRBASE                                              04530000
         MVC   LINE+10(21),=C'Record dump length=X'''                   04540000
         STH   R6,W#DWORD                                               04550000
         UNPK  LINE+31(5),W#DWORD(3)                                    04560000
         TR    LINE+31(4),P#FMTTBL-240                                  04570000
         MVI   LINE+35,C''''                                            04580000
         BAL   R14,PRTHD           Print section header                 04590000
         LR    R0,R6               Segment length                       04600000
         LA    R1,CTGRBASE         Segment address                      04610000
         BAL   R14,DMPOF                                                04620000
         BAL   R14,PRT                                                  04630000
         B     PROC                                                     04640000
**********************************************************************  04650000
*                                                                    *  04660000
**********************************************************************  04670000
PROC00   DS    0H                                                       04680000
         LA    R2,CATRCD                                                04690000
         MVC   LINE+10(L'RECID),RECID                                   04700000
         BAL   R14,PRTHD           Print record header                  04710000
         LA    R0,TYP00LEN                                              04720000
         L     R3,=A(TYP00)                                             04730000
         LA    R2,CATRCD                                                04740000
         BAL   R14,FMT             Format catalog record                04750000
         BAL   R14,PRT             Print line                           04760000
         B     PROC                                                     04770000
**********************************************************************  04780000
*                                                                    *  04790000
**********************************************************************  04800000
PROCA    DS    0H                                                       04810000
         LA    R2,CTGRBASE                                              04820000
         MVC   LINE+10(L'RECID),RECID                                   04830000
         BAL   R14,PRTHD           Print section header                 04840000
         LA    R0,TYPALEN                                               04850000
         L     R3,=A(TYPA)                                              04860000
         LA    R2,CATRCD                                                04870000
         BAL   R14,FMT             Format catalog header                04880000
*                                                                       04890000
         SR    R4,R4                                                    04900000
         IC    R4,NREPLF                                                04910000
         LA    R2,CATRCD(R4)                                            04920000
         MVC   LINE+10(10),=C'GOP Header'                               04930000
         BAL   R14,PRTHD           Print section header                 04940000
         L     R3,=A(GOPH)                                              04950000
         LA    R2,CATRCD                                                04960000
         LR    R0,R4                                                    04970000
         BAL   R14,FMT             Format catalog section               04980000
*                                                                       04990000
         LA    R6,CATRCD+(REPGOPT-REPCNTRL)(R4)                         05000000
         LR    R1,R4                                                    05010000
         SR    R4,R4                                                    05020000
         IC    R4,CATRCD+(REPCNT-REPCNTRL)(R1)                          05030000
         LTR   R4,R4                                                    05040000
         BZ    PROCAV                                                   05050000
         USING REPCNTRL,R6                                              05060000
PROCAGOP DS    0H                                                       05070000
         LR    R2,R6                                                    05080000
         SR    R1,R1                                                    05090000
         IC    R1,REPCNT                                                05100000
         SR    R1,R4                                                    05110000
         LA    R1,1(,R1)                                                05120000
         CVD   R1,W#DWORD                                               05130000
         MVC   LINE+9(4),=X'40202120'                                   05140000
         ED    LINE+9(4),W#DWORD+6                                      05150000
         MVC   LINE+10(3),=C'GOP'                                       05160000
         BAL   R14,PRTHD           Print section header                 05170000
         L     R3,=A(GOP)                                               05180000
         LA    R2,CATRCD                                                05190000
         LR    R0,R6                                                    05200000
         SR    R0,R2                                                    05210000
         BAL   R14,FMT             Format catalog section               05220000
         LA    R6,L'CATGOPT(,R6)                                        05230000
         BCT   R4,PROCAGOP                                              05240000
PROCAV   DS    0H                                                       05250000
         DROP  R6                                                       05260000
         BAL   R14,PRT             Print line                           05270000
         B     PROC                                                     05280000
**********************************************************************  05290000
*                                                                    *  05300000
**********************************************************************  05310000
PROCC    DS    0H                                                       05320000
         LA    R2,CTGRBASE                                              05330000
         MVC   LINE+10(L'RECID),RECID                                   05340000
         BAL   R14,PRTHD           Print section header                 05350000
         LA    R0,TYPCLEN                                               05360000
         L     R3,=A(TYPC)                                              05370000
         LA    R2,CATRCD                                                05380000
         BAL   R14,FMT             Format catalog header                05390000
*                                                                       05400000
         SR    R4,R4                                                    05410000
         IC    R4,NREPLF                                                05420000
         LA    R2,CATRCD(R4)                                            05430000
         MVC   LINE+10(10),=C'GOP Header'                               05440000
         BAL   R14,PRTHD           Print section header                 05450000
         L     R3,=A(GOPH)                                              05460000
         LA    R2,CATRCD                                                05470000
         LR    R0,R4                                                    05480000
         BAL   R14,FMT             Format catalog section               05490000
*                                                                       05500000
         LA    R6,CATRCD+(REPGOPT-REPCNTRL)(R4)                         05510000
         LR    R1,R4                                                    05520000
         SR    R4,R4                                                    05530000
         IC    R4,CATRCD+(REPCNT-REPCNTRL)(R1)                          05540000
         LTR   R4,R4                                                    05550000
         BZ    PROCCV                                                   05560000
         USING REPCNTRL,R6                                              05570000
PROCCGOP DS    0H                                                       05580000
         LR    R2,R6                                                    05590000
         SR    R1,R1                                                    05600000
         IC    R1,REPCNT                                                05610000
         SR    R1,R4                                                    05620000
         LA    R1,1(,R1)                                                05630000
         CVD   R1,W#DWORD                                               05640000
         MVC   LINE+9(4),=X'40202120'                                   05650000
         ED    LINE+9(4),W#DWORD+6                                      05660000
         MVC   LINE+10(3),=C'GOP'                                       05670000
         BAL   R14,PRTHD           Print section header                 05680000
         L     R3,=A(GOP)                                               05690000
         LA    R2,CATRCD                                                05700000
         LR    R0,R6                                                    05710000
         SR    R0,R2                                                    05720000
         BAL   R14,FMT             Format catalog section               05730000
         LA    R6,L'CATGOPT(,R6)                                        05740000
         BCT   R4,PROCCGOP                                              05750000
PROCCV   DS    0H                                                       05760000
         DROP  R6                                                       05770000
         BAL   R14,PRT             Print line                           05780000
         B     PROC                                                     05790000
**********************************************************************  05800000
*                                                                    *  05810000
**********************************************************************  05820000
PROCD    DS    0H                                                       05830000
         LA    R2,CTGRBASE                                              05840000
         MVC   LINE+10(L'RECID),RECID                                   05850000
         BAL   R14,PRTHD           Print section header                 05860000
         LA    R0,TYPDLEN                                               05870000
         L     R3,=A(TYPD)                                              05880000
         LA    R2,CATRCD                                                05890000
         BAL   R14,FMT             Format catalog header                05900000
*                                                                       05910000
         SR    R4,R4                                                    05920000
         IC    R4,NREPLF                                                05930000
         LA    R2,CATRCD(R4)                                            05940000
         MVC   LINE+10(10),=C'GOP Header'                               05950000
         BAL   R14,PRTHD           Print section header                 05960000
         L     R3,=A(GOPH)                                              05970000
         LA    R2,CATRCD                                                05980000
         LR    R0,R4                                                    05990000
         BAL   R14,FMT             Format catalog section               06000000
*                                                                       06010000
         LA    R6,CATRCD+(REPGOPT-REPCNTRL)(R4)                         06020000
         LR    R1,R4                                                    06030000
         SR    R4,R4                                                    06040000
         IC    R4,CATRCD+(REPCNT-REPCNTRL)(R1)                          06050000
         LTR   R4,R4                                                    06060000
         BZ    PROCDV                                                   06070000
         USING REPCNTRL,R6                                              06080000
PROCDGOP DS    0H                                                       06090000
         LR    R2,R6                                                    06100000
         SR    R1,R1                                                    06110000
         IC    R1,REPCNT                                                06120000
         SR    R1,R4                                                    06130000
         LA    R1,1(,R1)                                                06140000
         CVD   R1,W#DWORD                                               06150000
         MVC   LINE+9(4),=X'40202120'                                   06160000
         ED    LINE+9(4),W#DWORD+6                                      06170000
         MVC   LINE+10(3),=C'GOP'                                       06180000
         BAL   R14,PRTHD           Print section header                 06190000
         L     R3,=A(GOP)                                               06200000
         LA    R2,CATRCD                                                06210000
         LR    R0,R6                                                    06220000
         SR    R0,R2                                                    06230000
         BAL   R14,FMT             Format catalog section               06240000
         LA    R6,L'CATGOPT(,R6)                                        06250000
         BCT   R4,PROCDGOP                                              06260000
PROCDV   DS    0H                                                       06270000
         BAL   R14,DMPRC                                                06280000
         B     PROC                                                     06290000
**********************************************************************  06300000
*                                                                    *  06310000
**********************************************************************  06320000
PROCE    DS    0H                                                       06330000
         LA    R2,CTGRBASE                                              06340000
         MVC   LINE+10(L'RECID),RECID                                   06350000
         BAL   R14,PRTHD           Print section header                 06360000
         LA    R0,TYPDLEN                                               06370000
*                                                                       06380000
         SR    R4,R4                                                    06390000
         IC    R4,NREPLF                                                06400000
         LA    R2,CATRCD(R4)                                            06410000
         MVC   LINE+10(10),=C'GOP Header'                               06420000
         BAL   R14,PRTHD           Print section header                 06430000
         L     R3,=A(GOPH)                                              06440000
         LA    R2,CATRCD                                                06450000
         LR    R0,R4                                                    06460000
         BAL   R14,FMT             Format catalog section               06470000
*                                                                       06480000
         LA    R6,CATRCD+(REPGOPT-REPCNTRL)(R4)                         06490000
         LR    R1,R4                                                    06500000
         SR    R4,R4                                                    06510000
         IC    R4,CATRCD+(REPCNT-REPCNTRL)(R1)                          06520000
         LTR   R4,R4                                                    06530000
         BZ    PROCEV                                                   06540000
         USING REPCNTRL,R6                                              06550000
PROCEGOP DS    0H                                                       06560000
         LR    R2,R6                                                    06570000
         SR    R1,R1                                                    06580000
         IC    R1,REPCNT                                                06590000
         SR    R1,R4                                                    06600000
         LA    R1,1(,R1)                                                06610000
         CVD   R1,W#DWORD                                               06620000
         MVC   LINE+9(4),=X'40202120'                                   06630000
         ED    LINE+9(4),W#DWORD+6                                      06640000
         MVC   LINE+10(3),=C'GOP'                                       06650000
         BAL   R14,PRTHD           Print section header                 06660000
         L     R3,=A(GOP)                                               06670000
         LA    R2,CATRCD                                                06680000
         LR    R0,R6                                                    06690000
         SR    R0,R2                                                    06700000
         BAL   R14,FMT             Format catalog section               06710000
         LA    R6,L'CATGOPT(,R6)                                        06720000
         BCT   R4,PROCEGOP                                              06730000
PROCEV   DS    0H                                                       06740000
         DROP  R6                                                       06750000
         LR    R2,R6                                                    06760000
         MVC   LINE+10(16),=C'Volume extension'                         06770000
         BAL   R14,PRTHD           Print section header                 06780000
         L     R3,=A(TYPEVE)                                            06790000
         LA    R2,CATRCD                                                06800000
         LR    R0,R6                                                    06810000
         SR    R0,R2                                                    06820000
         BAL   R14,FMT             Format volume extension              06830000
         USING UPENTVOL,R6                                              06840000
         SR    R4,R4                                                    06850000
         IC    R4,UPRLRP           Number of variable fields (3)        06860000
         SR    R5,R5                                                    06870000
         IC    R5,UPRLRP+1         Volume extension length              06880000
         DROP  R6                                                       06890000
         LA    R6,0(R5,R6)         Low key extension address            06900000
         MVC   LINE+10(17),=C'Low key extension'                        06910000
         BAL   R14,PRTHD           Print section header                 06920000
         ICM   R0,3,0(R6)                                               06930000
         L     R3,=A(TYPEELK)                                           06940000
         BNZ   PROCELK                                                  06950000
         L     R3,=A(VARFLD)                                            06960000
PROCELK  DS    0H                                                       06970000
         LA    R2,CATRCD                                                06980000
         LR    R0,R6                                                    06990000
         SR    R0,R2                                                    07000000
         BAL   R14,FMT             Format volume extension              07010000
         LH    R5,0(,R6)                                                07020000
         LA    R6,2(R5,R6)         Length of length                     07030000
         MVC   LINE+10(18),=C'High key extension'                       07040000
         BAL   R14,PRTHD           Print section header                 07050000
         ICM   R0,3,0(R6)                                               07060000
         L     R3,=A(TYPEEHK)                                           07070000
         BNZ   PROCEHK                                                  07080000
         L     R3,=A(VARFLD)                                            07090000
PROCEHK  DS    0H                                                       07100000
         LA    R2,CATRCD                                                07110000
         LR    R0,R6                                                    07120000
         SR    R0,R2                                                    07130000
         BAL   R14,FMT             Format volume extension              07140000
         LH    R5,0(,R6)                                                07150000
         LA    R6,2(R5,R6)         Length of length                     07160000
         MVC   LINE+10(16),=C'Extent extension'                         07170000
         BAL   R14,PRTHD           Print section header                 07180000
         L     R3,=A(TYPEEEX)                                           07190000
         LA    R2,CATRCD                                                07200000
         LR    R0,R6                                                    07210000
         SR    R0,R2                                                    07220000
         BAL   R14,FMT             Format volume extension              07230000
         BAL   R14,PRT             Print line                           07240000
         B     PROC                                                     07250000
**********************************************************************  07260000
*                                                                    *  07270000
**********************************************************************  07280000
PROCI    DS    0H                                                       07290000
         LA    R2,CTGRBASE                                              07300000
         MVC   LINE+10(L'RECID),RECID                                   07310000
         BAL   R14,PRTHD           Print section header                 07320000
         LA    R0,TYPILEN                                               07330000
         L     R3,=A(TYPI)                                              07340000
         LA    R2,CATRCD                                                07350000
         BAL   R14,FMT             Format catalog header                07360000
*                                                                       07370000
         SR    R4,R4                                                    07380000
         IC    R4,NREPLF                                                07390000
         LA    R2,CATRCD(R4)                                            07400000
         MVC   LINE+10(10),=C'GOP Header'                               07410000
         BAL   R14,PRTHD           Print section header                 07420000
         L     R3,=A(GOPH)                                              07430000
         LA    R2,CATRCD                                                07440000
         LR    R0,R4                                                    07450000
         BAL   R14,FMT             Format catalog section               07460000
*                                                                       07470000
         LA    R6,CATRCD+(REPGOPT-REPCNTRL)(R4)                         07480000
         LR    R1,R4                                                    07490000
         SR    R4,R4                                                    07500000
         IC    R4,CATRCD+(REPCNT-REPCNTRL)(R1)                          07510000
         LTR   R4,R4                                                    07520000
         BZ    PROCIV                                                   07530000
         USING REPCNTRL,R6                                              07540000
PROCIGOP DS    0H                                                       07550000
         LR    R2,R6                                                    07560000
         SR    R1,R1                                                    07570000
         IC    R1,REPCNT                                                07580000
         SR    R1,R4                                                    07590000
         LA    R1,1(,R1)                                                07600000
         CVD   R1,W#DWORD                                               07610000
         MVC   LINE+9(4),=X'40202120'                                   07620000
         ED    LINE+9(4),W#DWORD+6                                      07630000
         MVC   LINE+10(3),=C'GOP'                                       07640000
         BAL   R14,PRTHD           Print section header                 07650000
         L     R3,=A(GOP)                                               07660000
         LA    R2,CATRCD                                                07670000
         LR    R0,R6                                                    07680000
         SR    R0,R2                                                    07690000
         BAL   R14,FMT             Format catalog section               07700000
         LA    R6,L'CATGOPT(,R6)                                        07710000
         BCT   R4,PROCIGOP                                              07720000
PROCIV   DS    0H                                                       07730000
         DROP  R6                                                       07740000
         BAL   R14,PRT             Print line                           07750000
         B     PROC                                                     07760000
         DROP  R8                                                       07770000
         DROP  R9                                                       07780000
**********************************************************************  07790000
*                                                                    *  07800000
**********************************************************************  07810000
EXIT     DS    0H                                                       07820000
         BAL   R14,PRT                                                  07830000
         MVC   LINE+49(4),=C'Read'                                      07840000
         MVC   LINE+56(8),=C'Selected'                                  07850000
         BAL   R14,PRT                                                  07860000
         LA    R9,W#RECCTR                                              07870000
         USING REC,R9                                                   07880000
         ZAP   W#DWORD,=P'+0'                                           07890000
EXITCT   DS    0H                                                       07900000
         MVC   LINE+1(L'RECID),RECID                                    07910000
         MVC   LINE+43(10),=X'40206B2020206B202120'                     07920000
         ED    LINE+43(10),RECCT                                        07930000
         MVC   LINE+54(10),=X'40206B2020206B202120'                     07940000
         ED    LINE+54(10),RECSE                                        07950000
         AP    W#DWORD,RECSE                                            07960000
         BAL   R14,PRT                                                  07970000
         LA    R9,L'REC(,R9)                                            07980000
         LA    R0,W#RECEND                                              07990000
         CR    R9,R0                                                    08000000
         BL    EXITCT                                                   08010000
         MVC   LINE+1(20),=C'Catalog records read'                      08020000
         MVC   LINE+43(10),=X'40206B2020206B202120'                     08030000
         ED    LINE+43(10),W#RECRD                                      08040000
         MVC   LINE+54(10),=X'40206B2020206B202120'                     08050000
         ED    LINE+54(10),W#DWORD+4                                    08060000
         BAL   R14,PRT                                                  08070000
         CLOSE (SYSPRINT)                                               08080000
         L     R2,W#ACBSAV                                              08090000
         CLOSE ((R2))                                                   08100000
         LTR   R15,R15                                                  08110000
         BNZ   ERRCLS                                                   08120000
         L     R13,4(,R13)                                              08130000
         LM    R14,R12,12(R13)                                          08140000
         LA    R15,0                                                    08150000
         BR    R14                                                      08160000
**********************************************************************  08170000
*                                                                    *  08180000
**********************************************************************  08190000
ERRGNACB DS    0H                                                       08200000
         MVC   LINE+1(10),=C'GEN CB ACB'                                08210000
         B     ERRRC                                                    08220000
ERRGNRPL DS    0H                                                       08230000
         MVC   LINE+1(10),=C'GEN CB RPL'                                08240000
         B     ERRRC                                                    08250000
ERROPN   DS    0H                                                       08260000
         MVC   LINE+1(4),=C'OPEN'                                       08270000
         B     ERRRC                                                    08280000
ERRRDJF  DS    0H                                                       08290000
         MVC   LINE+1(6),=C'RDJFCB'                                     08300000
         B     ERRRC                                                    08310000
ERRCSI   DS    0H                                                       08320000
         MVC   LINE+1(3),=C'CSI'                                        08330000
         B     ERRRC                                                    08340000
ERRGET   DS    0H                                                       08350000
         STM   R15,R1,W#GETSAV                                          08360000
         BAL   R14,DIAG                                                 08370000
         LM    R15,R1,W#GETSAV                                          08380000
         MVC   LINE+1(3),=C'GET'                                        08390000
         BAL   R14,RPLER                                                08400000
         B     EXITRC8                                                  08410000
ERRCLS   DS    0H                                                       08420000
         MVC   LINE+1(4),=C'CLOSE'                                      08430000
         B     ERRRC                                                    08440000
ERRSHRLN DS    0H                                                       08450000
         MVC   LINE+1(10),=C'SHOW CB LN'                                08460000
         B     ERRRC                                                    08470000
ERRAUTH  DS    0H                                                       08480000
         MVC   LINE+1(12),=C'Unauthorized'                              08490000
         BAL   R14,PRT                                                  08500000
         B     EXITRC8                                                  08510000
PRMERR   DS    0H                                                       08520000
         S     R9,W#PRMBGN                                              08530000
         LA    R1,LINE+6(R9)                                            08540000
         MVC   0(14,R1),=C'* Invalid parm'                              08550000
         BAL   R14,PRT                                                  08560000
         B     EXITRC8                                                  08570000
ERRRC    DS    0H                                                       08580000
         BAL   R14,RCMSG                                                08590000
         B     EXITRC8                                                  08600000
EXITRC8  DS    0H                                                       08610000
         LA    R2,8                                                     08620000
         MVC   LINE+1(13),=C'Return code=8'                             08630000
         BAL   R14,PRT                                                  08640000
         L     R13,4(,R13)                                              08650000
         L     R14,12(,R13)                                             08660000
         LR    R15,R2                                                   08670000
         LM    R2,R12,28(R13)                                           08680000
         BR    R14                                                      08690000
**********************************************************************  08700000
*                                                                    *  08710000
**********************************************************************  08720000
DIAG     DS    0H                                                       08730000
         ST    R14,W#DIAG14                                             08740000
         MVC   LINE+1(3),=C'RPL'                                        08750000
         LA    R0,RPLLENG-IFGRPL                                        08760000
         L     R1,W#RPLSAV                                              08770000
         BAL   R14,DMPAD                                                08780000
         BAL   R14,PRT                                                  08790000
*                                                                       08800000
         MVC   LINE+1(3),=C'PLH'                                        08810000
         MODESET KEY=ZERO,MODE=SUP                                      08820001
         LA    R0,PLHEND-IDAPLHD                                        08830000
         L     R1,W#RPLSAV                                              08840000
         USING IFGRPL,R1                                                08850000
         ICM   R1,15,RPLPLHPT                                           08860001
         BZ    DIAG005                                                  08870001
         DROP  R1                                                       08880000
         BAL   R14,EVAL                                                 08890000
         BZ    DIAG010                                                  08900000
DIAG005  DS    0H                                                       08910001
         MVC   LINE+5(3),=C'n/a'                                        08920000
         BAL   R14,PRT                                                  08930000
         B     DIAG020                                                  08940000
DIAG010  DS    0H                                                       08950000
         BAL   R14,DMPAD                                                08960000
DIAG020  DS    0H                                                       08970000
         BAL   R14,PRT                                                  08980000
*                                                                       08990000
         MODESET KEY=NZERO,MODE=PROB                                    09000001
         MVC   LINE+1(3),=C'ACB'                                        09010000
         LA    R0,ACBLEN-IFGACB                                         09020000
         L     R1,W#ACBSAV                                              09030000
         BAL   R14,DMPAD                                                09040000
         BAL   R14,PRT                                                  09050000
*                                                                       09060000
         MVC   LINE+1(4),=C'WORK'                                       09070000
         LA    R0,WORKEND-WORK                                          09080000
         LA    R1,WORK                                                  09090000
         BAL   R14,DMPAD                                                09100000
         BAL   R14,PRT                                                  09110000
         L     R14,W#DIAG14                                             09120000
         BR    R14                                                      09130000
**********************************************************************  09140000
*        Validate address                                            *  09150000
*              R1= STARTING ADDRESS               Passed in          *  09160000
*              R2= ENDING ADDRESS                 Set to zero        *  09170000
*              R4= TCB ADDRESS                    Set to key 0       *  09180000
*              R13= SAVE AREA ADDRESS                                *  09190000
*              R14= RETURN ADDRESS                                   *  09200000
*              R15= ENTRY POINT ADDRESS           IEA0VL01           *  09210000
*              CC=  zero=ok                                          *  09220000
**********************************************************************  09230000
EVAL     DS    0H                                                       09240000
         STM   R0,R15,W#EVALRG                                          09250000
         SR    R2,R2                                                    09260000
         LA    R4,=X'00'                                                09270000
         LA    R1,TCBPKF-TCB                                            09280000
         SR    R4,R1                                                    09290000
         USING PSA,R0                                                   09300000
         L     R15,FLCCVT                                               09310000
         DROP  R0                                                       09320000
         USING CVT,R15                                                  09330000
         L     R15,CVT0VL01                                             09340000
         DROP  R15                                                      09350000
         BALR  R14,R15                                                  09360001
         LM    R0,R15,W#EVALRG                                          09370000
         BR    R14                                                      09380000
**********************************************************************  09390000
*                                                                    *  09400000
**********************************************************************  09410000
RCMSG    DS    0H                                                       09420000
         ST    R14,W#RCMS14                                             09430000
         MVC   LINE+12(3),=C'RC='                                       09440000
         ST    R15,W#DWORD                                              09450000
         UNPK  LINE+15(9),W#DWORD(5)                                    09460000
         TR    LINE+15(8),P#FMTTBL-240                                  09470000
         MVC   LINE+23(4),=C' R0='                                      09480000
         ST    R0,W#DWORD                                               09490000
         UNPK  LINE+27(9),W#DWORD(5)                                    09500000
         TR    LINE+27(8),P#FMTTBL-240                                  09510000
         MVC   LINE+35(4),=C' R1='                                      09520000
         ST    R1,W#DWORD                                               09530000
         UNPK  LINE+39(9),W#DWORD(5)                                    09540000
         TR    LINE+39(8),P#FMTTBL-240                                  09550000
         MVI   LINE+47,C' '                                             09560000
         BAL   R14,PRT                                                  09570000
         L     R14,W#RCMS14                                             09580000
         BR    R14                                                      09590000
**********************************************************************  09600000
*                                                                    *  09610000
**********************************************************************  09620000
RPLER    DS    0H                                                       09630000
         ST    R14,W#RPLE14                                             09640000
         MVC   LINE+1(3),=C'RC='                                        09650000
         ST    R15,W#DWORD                                              09660000
         UNPK  LINE+4(9),W#DWORD(5)                                     09670000
         TR    LINE+4(8),P#FMTTBL-240                                   09680000
         MVC   LINE+12(4),=C' R0='                                      09690000
         ST    R0,W#DWORD                                               09700000
         UNPK  LINE+16(9),W#DWORD(5)                                    09710000
         TR    LINE+16(8),P#FMTTBL-240                                  09720000
         MVC   LINE+24(4),=C' R1='                                      09730000
         ST    R1,W#DWORD                                               09740000
         UNPK  LINE+28(9),W#DWORD(5)                                    09750000
         TR    LINE+28(8),P#FMTTBL-240                                  09760000
         MVI   LINE+36,C' '                                             09770000
         CH    R15,=H'4'                                                09780000
         L     R1,=A(ERRRC4)                                            09790000
         BE    RPLER010                                                 09800000
         CH    R15,=H'8'                                                09810000
         L     R1,=A(ERRRC8)                                            09820000
         BNE   RPLER040                                                 09830000
RPLER010 DS    0H                                                       09840000
         ICM   R14,15,0(R1)                                             09850000
         BM    RPLER030                                                 09860000
         C     R0,0(,R1)                                                09870000
         BE    RPLER030                                                 09880000
         LA    R1,12(,R1)                                               09890000
         B     RPLER010                                                 09900000
RPLER030 DS    0H                                                       09910000
         LM    R14,R15,4(R1)                                            09920000
         BCTR  R15,0                                                    09930000
         EX    R15,RPLERMVC                                             09940000
RPLER040 DS    0H                                                       09950000
         BAL   R14,PRT                                                  09960000
         L     R14,W#RPLE14                                             09970000
         BR    R14                                                      09980000
RPLERMVC MVC   LINE+37(0),0(R14)                                        09990000
**********************************************************************  10000000
*        Print rest of Catalog record                                *  10010000
**********************************************************************  10020000
         USING CATRCD,R8                                                10030000
DMPRC    DS    0H                                                       10040000
         ST    R14,W#DMPRCE                                             10050000
DMPRCV   DS    0H                                                       10060000
         SR    R1,R1                                                    10070000
         ICM   R1,3,RCDSIZ                                              10080000
         LA    R1,CATRCD(R1)                                            10090000
         CR    R6,R1                                                    10100000
         BNL   DMPRCEND                                                 10110000
         LR    R2,R6                                                    10120000
         MVC   LINE+10(17),=C'Catalog extension'                        10130000
         MVC   LINE+28(9),=C'Length=X'''                                10140000
         UNPK  LINE+37(3),1(2,R6)                                       10150000
         TR    LINE+37(2),P#FMTTBL-240                                  10160000
         MVI   LINE+39,C''''                                            10170000
         BAL   R14,PRTHD           Print section header                 10180000
         SR    R0,R0                                                    10190000
         IC    R0,1(,R6)           Extension length                     10200000
         LR    R1,R6               Extension address                    10210000
         BAL   R14,DMPOF           Dump at offset                       10220000
         SR    R1,R1                                                    10230000
         IC    R1,1(,R6)           Extension size                       10240000
         SR    R4,R4                                                    10250000
         ICM   R4,1,0(R6)          Number of variable extensions        10260000
         BZ    DMPRCVNX            Yes, skip if none                    10270000
DMPRCVEX DS    0H                                                       10280000
         AR    R6,R1                                                    10290000
         LR    R2,R6                                                    10300000
         MVC   LINE+10(14),=C'Variable field'                           10310000
         MVC   LINE+25(9),=C'length=X'''                                10320000
         UNPK  LINE+34(5),0(3,R6)                                       10330000
         TR    LINE+34(4),P#FMTTBL-240                                  10340000
         MVI   LINE+38,C''''                                            10350000
         BAL   R14,PRTHD           Print section header                 10360000
         LA    R0,2                Include length of length             10370000
         AH    R0,0(,R6)           Extension length                     10380000
         LR    R1,R6               Extension address                    10390000
         BAL   R14,DMPOF           Dump at offset                       10400000
         LH    R1,0(,R6)           Extension length                     10410000
         LA    R1,2(,R1)                                                10420000
         BCT   R4,DMPRCVEX                                              10430000
DMPRCVNX DS    0H                                                       10440000
         AR    R6,R1                                                    10450000
         B     DMPRCV                                                   10460000
DMPRCEND DS    0H                                                       10470000
         BAL   R14,PRT             Print line                           10480000
         L     R14,W#DMPRCE                                             10490000
         BR    R14                 Return to caller                     10500000
         DROP  R8                                                       10510000
**********************************************************************  10520000
*        Print Cell Header (unformatted cell)                        *  10530000
**********************************************************************  10540000
PRTHDU   DS    0H                                                       10550000
         ST    R14,W#PRTU14                                             10560000
         LA    R1,LINE+L'LINE-1                                         10570000
         LA    R0,L'LINE                                                10580000
PRTHDU10 DS    0H                                                       10590000
         CLI   0(R1),C' '                                               10600000
         BNE   PRTHDU20                                                 10610000
         LTR   R0,R0                                                    10620000
         BZ    PRTHDU20                                                 10630000
         BCTR  R0,0                                                     10640000
         BCTR  R1,0                                                     10650000
         B     PRTHDU10                                                 10660000
PRTHDU20 DS    0H                                                       10670000
         MVC   2(12,R1),=C'at offset X'''                               10680000
         LR    R0,R2                                                    10690000
         SR    R0,R8                                                    10700000
         ST    R0,W#DWORD                                               10710000
         UNPK  14(5,R1),W#DWORD+2(3)                                    10720000
         TR    14(4,R1),P#FMTTBL-240                                    10730000
         MVC   18(15,R1),=C''' (unformatted)'                           10740000
         BAL   R14,PRT                                                  10750000
         L     R14,W#PRTU14                                             10760000
         BR    R14                     RETURN TO CALLER                 10770000
**********************************************************************  10780000
*        Print Cell Header                                              10790000
**********************************************************************  10800000
PRTHD    DS    0H                                                       10810000
         ST    R14,W#PRTH14                                             10820000
         LA    R1,LINE+L'LINE-1                                         10830000
         LA    R0,L'LINE                                                10840000
PRTHD10  DS    0H                                                       10850000
         CLI   0(R1),C' '                                               10860000
         BNE   PRTHD20                                                  10870000
         LTR   R0,R0                                                    10880000
         BZ    PRTHD20                                                  10890000
         BCTR  R0,0                                                     10900000
         BCTR  R1,0                                                     10910000
         B     PRTHD10                                                  10920000
PRTHD20  DS    0H                                                       10930000
         MVC   2(12,R1),=C'at offset X'''                               10940000
         LR    R0,R2                                                    10950000
         SR    R0,R8                                                    10960000
         ST    R0,W#DWORD                                               10970000
         UNPK  14(5,R1),W#DWORD+2(3)                                    10980000
         TR    14(4,R1),P#FMTTBL-240                                    10990000
         MVI   18(R1),C''''                                             11000000
         BAL   R14,PRT                                                  11010000
         L     R14,W#PRTH14                                             11020000
         BR    R14                     RETURN TO CALLER                 11030000
*********************************************************************** 11040000
*        Format Control Block                                         * 11050000
*          R3=CBDEF                                                   * 11060000
*          R2=Data address                                            * 11070000
*********************************************************************** 11080000
FMT      DS    0H                                                       11090000
         STM   R0,R15,W#FREGS      Save registers                       11100000
         USING BLK,R3                                                   11110000
         TM    BLKFIRST,X'80'      OFF=PASS?                            11120000
         BO    FMTPASS             Yes, R0 has offset in buffer         11130000
         LH    R0,BLKFIRST         Control block start offset           11140000
FMTPASS  DS    0H                                                       11150000
         ST    R2,W#FADDR          Save control block address           11160000
         AR    R2,R0               Add offset to address                11170000
         LA    R3,BLKHDNXT         Get next block field                 11180000
         LR    R4,R2               Start address for .NEXT              11190000
FMTCB    DS    0H                                                       11200000
         CLI   BLKTYPE,BLKHEX      Hex field?                           11210000
         BE    FMTHEX              Yes, do hex field                    11220000
         CLI   BLKTYPE,BLKCONST    Constant field                       11230000
         BE    FMTCONST            Yes, do constant (label)             11240000
         CLI   BLKTYPE,BLKCHAR     Character field                      11250000
         BE    FMTCHAR             Yes, do character field              11260000
         B     FMTEND              Must JE block end, done              11270000
*        Character constant (label)                                     11280000
FMTCONST DS    0H                                                       11290000
         LA    R15,BLKDATA         Address of field                     11300000
         SLR   R14,R14             Get a zero                           11310000
         IC    R14,BLKDTALN        Get length of field                  11320000
         SLR   R1,R1               Get a zero                           11330000
         IC    R1,BLKOFF           Line offset                          11340000
         LA    R1,LINE+1+9(R1)     Add line start                       11350000
         EX    R14,FMTEMVC         Move character field                 11360000
         LA    R3,BLKDTANX(R14)    Next field definition                11370000
         B     FMTLOOP             Back for another field               11380000
FMTEMVC  MVC   0(0,R1),0(R15)      Move character field                 11390000
*        Character field                                                11400000
FMTCHAR  DS    0H                                                       11410000
         CLC   BLKDISP,=AL2(32768) .NEXT field (X'8000')?               11420000
         BE    FMTCHAR0            Yes, source address set              11430000
         LH    R4,BLKDISP          Offset of field                      11440000
         AR    R4,R2               Add address to offset                11450000
FMTCHAR0 DS    0H                                                       11460000
         BAL   R14,FMTOFF          Format field offset                  11470000
         SLR   R14,R14             Get a zero                           11480000
         IC    R14,BLKCHRLN        Get length of field                  11490000
         CLI   BLKCHRSC,0          SCON used?                           11500000
         BE    FMTCHAR1            No, regular length                   11510000
         IC    R1,BLKCHRSC         Get SCON base register               11520000
         SRL   R1,2                Base reg times 8                     11530000
         N     R1,=X'0000003C'     Clear non base reg stuff             11540000
         L     R1,W#FREGS(R1)      Get base register                    11550000
         ICM   R0,3,BLKCHRSC       Get SCON displacement                11560000
         N     R0,=X'00000FFF'     Clear base register                  11570000
         AR    R1,R0               Add to base register                 11580000
         IC    R14,0(,R1)          Get actual length                    11590000
         BCTR  R14,0               Machine length                       11600000
FMTCHAR1 DS    0H                                                       11610000
         SLR   R1,R1               Get a zero                           11620000
         IC    R1,BLKOFF           Line offset                          11630000
         LA    R1,LINE+1+9(R1)     Add line start                       11640000
         LA    R0,LINE+130                                              11650000
         SR    R0,R1                                                    11660000
         LTR   R15,R14                                                  11670000
         BM    FMTCHAR2                                                 11680000
         CR    R15,R0                                                   11690000
         BL    FMTCHAR3                                                 11700000
         LR    R15,R0                                                   11710000
FMTCHAR3 DS    0H                                                       11720000
         EX    R15,FMTCMVC         Move field to line                   11730000
         EX    R15,FMTCTR          Remove unprintables                  11740000
FMTCHAR2 DS    0H                                                       11750000
         LA    R4,1(R4,R14)        Next field                           11760000
         LA    R3,BLKCHRNX         Next field definition                11770000
         B     FMTLOOP             Move character field                 11780000
FMTCMVC  MVC   0(0,R1),0(R4)       Move character field                 11790000
FMTCTR   TR    0(0,R1),P#TBLCH     Remove unprintables                  11800000
*        Hex field                                                      11810000
FMTHEX   DS    0H                                                       11820000
         CLC   BLKDISP,=AL2(32768) .NEXT field?                         11830000
         BE    FMTHEX0             Yes, source address set              11840000
         TM    BLKDISP,X'80'       NEXT based upon prev 1 byte length   11850000
         BNO   FMTHEXB             No, continue                         11860000
         SLR   R15,R15             Get a zero                           11870000
         IC    R15,BLKDISP         Flag and L index                     11880000
         SRL   R15,4               Shift index                          11890000
         N     R15,=A(X'7')        Clear flag                           11900000
         SLR   R14,R14             Get a zero                           11910000
         ICM   R14,3,BLKDISP       Offset of field                      11920000
         N     R14,=A(X'FFF')      Clear flag                           11930000
         LTR   R14,R14             If zero                              11940000
         BZ    FMTHEXA             It's a .NEXT                         11950000
         LR    R4,R14              Offset of field                      11960000
         AR    R4,R2               Add address to offset                11970000
FMTHEXA  DS    0H                                                       11980000
         IC    R0,0(,R4)           Get the length field                 11990000
         STC   R0,L1-1(R15)        Save current field (length)          12000000
         B     FMTHEX0                                                  12010000
FMTHEXB  DS    0H                                                       12020000
         LH    R4,BLKDISP          Offset of field                      12030000
         AR    R4,R2               Add address to offset                12040000
FMTHEX0  DS    0H                                                       12050000
         BAL   R14,FMTOFF          Format field offset                  12060000
         CLI   BLKHEXSC,0          SCON used?                           12070000
         BE    FMTHEXL1            No, regular length                   12080000
         IC    R1,BLKHEXSC         Get base register                    12090000
         SRL   R1,2                Base reg times 8                     12100000
         N     R1,=X'0000003C'     Clear not base reg stuff             12110000
         L     R1,W#FREGS(R1)      Get base register                    12120000
         SLR   R0,R0               Clear                                12130000
         ICM   R0,3,BLKHEXSC       Get SCON                             12140000
         N     R0,=A(X'FFF')       Clear base register                  12150000
         AR    R1,R0               Add to base register                 12160000
         SLR   R0,R0               Get a zero                           12170000
         IC    R0,0(,R1)           Get actual length                    12180000
         AR    R0,R0                                                    12190000
         LTR   R0,R0                                                    12200000
         BZ    FMTHEXF3                                                 12210000
         B     FMTHEXL2            No process length                    12220000
FMTHEXL1 DS    0H                                                       12230000
         SLR   R0,R0               Get a zero                           12240000
         IC    R0,BLKHEXLN         Get field length                     12250000
         AH    R0,=H'1'            Machine to actual length             12260000
FMTHEXL2 DS    0H                                                       12270000
         SLR   R1,R1               Get a zero                           12280000
         IC    R1,BLKOFF           Line offset                          12290000
         LA    R1,LINE+1+9(R1)     Add line start                       12300000
         LA    R14,W#FTEMP         Where to start from even digits      12310000
         CLI   BLKHEXOF,1          Do we want second digit              12320000
         BNE   FMTHEXF1            No, want first                       12330000
         LA    R14,W#FTEMP+1       Where to start from odd digits       12340000
FMTHEXF1 DS    0H                                                       12350000
         MVC   W#FTEMP+5(1),0(R4)  Get first byte                       12360000
         CH    R0,=H'2'            If only one left                     12370000
         BNH   FMTHEXF2            Don't copy last byte                 12380000
         MVC   W#FTEMP+6(1),1(R4)  Copy to prevent buffer overrun       12390000
FMTHEXF2 DS    0H                                                       12400000
         UNPK  W#FTEMP(5),W#FTEMP+5(3) Convert hex to character         12410000
         TR    W#FTEMP(4),P#FMTTBL-240 Finish off conversion            12420000
         LA    R15,LINE+130                                             12430000
         CR    R1,R15                                                   12440000
         BNL   FMTHEXF4                                                 12450000
         MVC   0(1,R1),0(R14)      Copy first digit                     12460000
FMTHEXF4 DS    0H                                                       12470000
         SH    R0,=H'1'            Count digit done                     12480000
         BZ    FMTHEXF3            If all done stop formatting          12490000
         CR    R1,R15                                                   12500000
         BNL   FMTHEXF5                                                 12510000
         MVC   1(1,R1),1(R14)      Move another hex digit               12520000
FMTHEXF5 DS    0H                                                       12530000
         LA    R1,2(,R1)           Next output area                     12540000
         LA    R4,1(,R4)           Next input area                      12550000
         BCT   R0,FMTHEXF1         Loop thru area                       12560000
FMTHEXF3 DS    0H                                                       12570000
         LA    R3,BLKHEXNX         Next field definition                12580000
FMTLOOP  DS    0H                                                       12590000
         CLI   BLKTYPE,BLKEND      End of block definition              12600000
         BE    FMTEND              yes, were done formatting            12610000
         CLI   BLKOFF,0            New line requested                   12620000
         BNE   FMTCB               No, continue with next field         12630000
         BAL   R14,PRT             Print a line                         12640000
         B     FMTCB               Go handle next field                 12650000
FMTEND   DS    0H                                                       12660000
         BAL   R14,PRT             Print a line                         12670000
         LM    R0,R15,W#FREGS      Restore registers                    12680000
         BR    R14                 Return to caller                     12690000
*                                                                       12700000
*        Format offset as needed                                        12710000
*                                                                       12720000
FMTOFF   DS    0H                                                       12730000
         CLI   LINE+5+3,C' '       Have we've done offset?              12740000
         BNER  R14                 Yes, don't do again                  12750000
         LR    R15,R4              Get a current field address          12760000
         S     R15,W#FADDR         Get field displacement               12770000
         LPR   R0,R15              Get positive value                   12780000
         ST    R0,W#FDWD           Save displacement                    12790000
         UNPK  LINE+5(5),W#FDWD+2(3) Convert to character               12800000
         TR    LINE+6(3),P#FMTTBL-240 Finish off conversion             12810000
         MVI   LINE+5,C' '         Clear extra info                     12820000
         MVI   LINE+9,C' '         Clear extra info                     12830000
         LA    R1,LINE+6           Where to start zero suppression      12840000
         LA    R0,2                Only handle 2 zeros                  12850000
FMTOFF1  DS    0H                                                       12860000
         CLI   0(R1),C'0'          Is there a leading zero              12870000
         BNE   FMTOFF2             No, we finished suppression          12880000
         MVI   0(R1),C' '          Clear leading zero                   12890000
         LA    R1,1(,R1)           Next digit                           12900000
         BCT   R0,FMTOFF1          Suppress limit                       12910000
FMTOFF2  DS    0H                                                       12920000
         BCTR  R1,0                Back to previous spot                12930000
         LTR   R15,R15             Is value positive                    12940000
         MVI   0(R1),C'+'          Set positive indicator               12950000
         BNLR  R14                 Exit if +                            12960000
         MVI   0(R1),C'-'          Set negative indicator               12970000
         BR    R14                 Exit                                 12980000
         DROP  R3                                                       12990000
**********************************************************************  13000000
*            WRITE PRINT LINE                                        *  13010000
**********************************************************************  13020000
PRT      DS    0H                                                       13030000
         ST    R14,W#PRT14                                              13040000
         CP    LNCT,=P'+60'            END OF PAGE                      13050000
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   13060000
PRTHDRS  DS    0H                                                       13070000
         AP    PGCT,=P'+1'             COUNT PAGES                      13080000
         MVC   HD1PGCT,=X'4020206B202120' PAGE COUNT MASK               13090000
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  13100000
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  13110000
         ZAP   LNCT,=P'+1'             INIT LINE COUNT                  13120000
         MVI   LINE,C'0'               SKIP AFTER HEADING               13130000
PRTCHK   DS    0H                                                       13140000
         CLI   LINE,C'+'               OVERPRINT ?                      13150000
         BE    PRTLINE                  YES, DON'T COUNT                13160000
         CLI   LINE,C'1'               NEW LINE ?                       13170000
         BE    PRTHDRS                  YES, PRINT HEADER               13180000
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         13190000
         BE    PRTLINE1                 YES, GO CHECK IF FIT            13200000
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         13210000
         BE    PRTLINE2                 YES, GO CHECK IF FIT            13220000
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         13230000
         BE    PRTLINE3                 YES, GO CHECK IF FIT            13240000
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       13250000
PRTLINE1 DS    0H                                                       13260000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                13270000
         B     PRTVFY                  GO SEE IF IT WILL FIT            13280000
PRTLINE2 DS    0H                                                       13290000
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                13300000
         B     PRTVFY                  GO SEE IF IT WILL FIT            13310000
PRTLINE3 DS    0H                                                       13320000
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                13330000
PRTVFY   DS    0H                                                       13340000
         CP    LNCT,=P'+60'            OVERFLOW ?                       13350000
         BH    PRTHDRS                  YES, FORCE HEADER               13360000
PRTLINE  DS    0H                                                       13370000
         PUT   SYSPRINT,LINE           PRINT A LINE                     13380000
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          13390000
         MVC   LINE+1(L'LINE-1),LINE                                    13400000
         L     R14,W#PRT14                                              13410000
         BR    R14                     RETURN TO CALLER                 13420000
*********************************************************************** 13430000
*        DUMP WITH ADDRESS OF STORAGE DUMPED                          * 13440000
*********************************************************************** 13450000
DMPAD    DS    0H                                                       13460000
         STM   R14,R2,W#DMPRGS         Save registers                   13470000
         LA    R2,LINE+L'LINE-1                                         13480000
         LA    R0,L'LINE-1                                              13490000
DMPAD10  DS    0H                                                       13500000
         CLI   0(R2),C' '                                               13510000
         BNE   DMPAD20                                                  13520000
         BCTR  R2,0                                                     13530000
         BCT   R0,DMPAD10                                               13540000
DMPAD20  DS    0H                                                       13550000
         MVC   2(2,R2),=C'at'                                           13560000
         AH    R2,=H'+5'               Output area address              13570000
         LA    R1,W#DMPR1              Address of address               13580000
         LA    R15,4                   Convert 4 bytes                  13590000
         BAL   R14,DMPDSP              Convert it to display            13600000
         BAL   R14,PRT                 Print address of data            13610000
         LM    R14,R2,W#DMPRGS         Restore registers                13620000
         BAL   R14,DMP                 Dump storage                     13630000
         LM    R14,R2,W#DMPRGS         Restore registers                13640000
         BR    R14                     Return to caller                 13650000
**********************************************************************  13660000
*        DUMP DATA                                                    * 13670000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 13680000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 13690000
*********************************************************************** 13700000
DMPOF    DS    0H                                                       13710000
         LR    R15,R1                                                   13720000
         SR    R15,R8                                                   13730000
         ST    R15,OFFSET              SAVE OFFSET FOR DUMP             13740000
         B     DMPBGN                                                   13750000
DMP      DS    0H                                                       13760000
         XC    OFFSET,OFFSET           ZERO OFFSET FOR DUMP             13770000
DMPBGN   DS    0H                                                       13780000
         STM   R0,R15,DMPREGS          SAVE REGISTERS                   13790000
         LR    R3,R1                   GET ADDRESS TO DUMP              13800000
         LR    R4,R0                   GET LENGTH                       13810000
         OI    DMPFLAG,DMPFIRST        FIRST LINE                       13820000
DMPDMPLP DS    0H                                                       13830000
         LTR   R4,R4                   ANY DATA TO DUMP ?               13840000
         BZ    DMPHEXXT                 YES, ALL DONE                   13850000
         TM    DMPFLAG,DMPFIRST        FIRST LINE?                      13860000
         BO    DMPALIN                  YES, CAN'T HAVE SAME AS ABOVE   13870000
         LA    R0,32                   DEFAULT LENGTH                   13880000
         CR    R4,R0                   LENGTH LONGER THAN 32 ?          13890000
         BNH   DMPDUPCK                 NO, WERE AT LAST LINE           13900000
         LR    R14,R3                  GET CURRENT INPUT AREA           13910000
         SR    R14,R0                  BACK TO PREVIOUS AREA            13920000
         CLC   0(32,R14),0(R3)         DUPLICATE OF PREVIOUS LINE       13930000
         BNE   DMPDUPCK                 NO, DO LINES SAME AS            13940000
         SR    R4,R0                   REDUCE LENGTH TO DO              13950000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           13960000
         BO    DMPNXTLN                 YES, WE HAVE FIRST OFFSET       13970000
         L     R14,OFFSET              GET CURRENT OFFSET               13980000
         ST    R14,DUPFIRST            SAVE AS FIRST OFFSET             13990000
         OI    DMPFLAG,DMPDUP          SET DUPLICATE                    14000000
         B     DMPNXTLN                CONTINUE                         14010000
DMPDUPCK DS    0H                                                       14020000
         TM    DMPFLAG,DMPDUP          DUPLICATE IN PROGRESS?           14030000
         BNO   DMPALIN                  NO, NO DUPLICATE TO REPORT      14040000
         MVC   LINE+7(5),=C'Lines'     MOVE LITERAL                     14050000
         LA    R2,LINE+13              OUTPUT AREA ADDRESS              14060000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        14070000
         LA    R15,2                   CONVERT 4 BYTES                  14080000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            14090000
         MVI   LINE+17,C'-'            THRU LITERAL                     14100000
         L     R1,OFFSET               GET CURRENT OFFSET               14110000
         S     R1,=A(32)               GET LAST DUPLICATE OFFSET        14120000
         ST    R1,DUPFIRST             SAVE FOR DUMPING                 14130000
         LA    R2,LINE+18              OUTPUT AREA ADDRESS              14140000
         LA    R1,DUPFIRST+2           ADDRESS OF OFFSET TO DUMP        14150000
         LA    R15,2                   CONVERT 4 BYTES                  14160000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            14170000
         MVC   LINE+23(13),=C'Same as above' MOVE LITERAL               14180000
         BAL   R14,PRT                 PRINT A LINE                     14190000
         NI    DMPFLAG,255-DMPDUP      RESET DUPLICATE IN PROGRESS      14200000
DMPALIN  DS    0H                                                       14210000
         LA    R2,LINE+1               OUTPUT AREA ADDRESS              14220000
         LA    R1,OFFSET+2             ADDRESS OF OFFSET TO DUMP        14230000
         LA    R15,2                   CONVERT 4 BYTES                  14240000
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY            14250000
         LA    R2,2(,R2)               SKIP 1 BETWEEN OFFSET & DATA     14260000
         LR    R1,R3                   ADDRESS OF DATA                  14270000
         LA    R5,32                   DEFAULT LENGTH                   14280000
         CR    R4,R5                   LENGTH LONGER THAN 32 ?          14290000
         BH    DMPDODMP                 YES, USE 32                     14300000
         LR    R5,R4                   USE WHAT IS LEFT                 14310000
DMPDODMP DS    0H                                                       14320000
         SR    R4,R5                   REDUCE AMOUNT TO DO              14330000
         MVI   LINE+81,C'*'            BOX IN DISPLAY PORTION           14340000
         BCTR  R5,0                    MAKE ZERO BASED                  14350000
         EX    R5,DMPMVC               DO MOVE                          14360000
         EX    R5,DMPTR                TRANSLATE OUT BAD STUFF          14370000
         LA    R5,1(,R5)               RESTORE LENGTH                   14380000
         MVI   LINE+114,C'*'           COMPLETE BOX                     14390000
DMPDMPHX DS    0H                                                       14400000
         LA    R15,4                   4 BYTES TO PROCESS               14410000
         CR    R5,R15                  LENGTH LONGER THAN 4 ?           14420000
         BH    DMPDMPIT                 YES, DUMP 4 BYTES               14430000
         LR    R15,R5                  USE LENGTH LEFT                  14440000
DMPDMPIT DS    0H                                                       14450000
         SR    R5,R15                  REDUCE AMOUNT TO DO              14460000
         BAL   R14,DMPDSP              CONVERT DATA                     14470000
         LA    R2,1(,R2)               SKIP 1 BYTE                      14480000
         LA    R0,LINE+43              HALFWAY POINT ADDRESS            14490000
         CR    R0,R2                   AT HALFWAY POINT?                14500000
         BNE   DMPDMPNX                 NO, CONTINUE                    14510000
         LA    R2,1(,R2)               SKIP 1 BYTE                      14520000
DMPDMPNX DS    0H                                                       14530000
         LTR   R5,R5                   ANY LEFT TO DO ?                 14540000
         BH    DMPDMPHX                 YES, GO DO IT                   14550000
         BAL   R14,PRT                 PRINT A LINE                     14560000
DMPNXTLN DS    0H                                                       14570000
         L     R1,OFFSET               GET OFFSET IN RECORD             14580000
         LA    R1,32(,R1)              ADD IN LENGTH WE WILL DUMP       14590000
         ST    R1,OFFSET               SAVE OFFSET IN RECORD            14600000
         LA    R3,32(,R3)              NEXT INPUT AREA                  14610000
         NI    DMPFLAG,255-DMPFIRST    NOT FIRST LINE                   14620000
         B     DMPDMPLP                LOOP THRU UNTIL DONE             14630000
DMPHEXXT DS    0H                                                       14640000
         LM    R0,R15,DMPREGS          RESTORE CALLERS REGS             14650000
         BR    R14                     EXIT . . .                       14660000
DMPMVC   MVC   LINE+82(0),0(R1)        <<< EXECUTED >>>                 14670000
DMPTR    TR    LINE+82(0),P#TBLCH      <<< EXECUTED >>>                 14680000
*                                                                       14690000
*                                                                       14700000
*                                                                       14710000
DMPDSP   DS    0H                                                       14720000
         UNPK  0(1,R2),0(1,R1)         GET FIRST HEX BYTE               14730000
         NI    0(R2),X'0F'             REMOVE ZONE                      14740000
         MVC   1(1,R2),0(R1)           MOVE SECOND HEX BYTE             14750000
         NI    1(R2),X'0F'             REMOVE ITS ZONE ALSO             14760000
         TR    0(2,R2),P#FMTTBL        TRANSLATE TO HEX                 14770000
         LA    R2,2(,R2)               POINT TO NEXT OUTPUT AREA        14780000
         LA    R1,1(,R1)               POINT TO NEXT INPUT AREA         14790000
         BCT   R15,DMPDSP              LOOP THRU DATA                   14800000
         BR    R14                     EXIT . . .                       14810000
         LTORG                                                          14820000
P#FMTTBL DC    C'0123456789ABCDEF' Hex conversion table                 14830000
P#TBLCH  DC    256C'.'             Non printable character table        14840000
         ORG   P#TBLCH+C' '                                             14850000
         DC    C' '                                                     14860000
         ORG   P#TBLCH+X'4A' Cent                                       14870000
         DC    X'4A',C'.<(+|',X'50'                                     14880000
         ORG   P#TBLCH+C'!'                                             14890000
         DC    C'!$*);¬-/'                                              14900000
         ORG   P#TBLCH+C'¦'                                             14910000
         DC    C'¦,%_>?'                                                14920000
         ORG   P#TBLCH+C':'                                             14930000
         DC    C':#@',X'7D',C'="'                                       14940000
         ORG   P#TBLCH+C'a'                                             14950000
         DC    C'abcdefghi'                                             14960000
         ORG   P#TBLCH+C'j'                                             14970000
         DC    C'jklmnopqr'                                             14980000
         ORG   P#TBLCH+C's'                                             14990000
         DC    C'stuvwxyz'                                              15000000
         ORG   P#TBLCH+C'A'                                             15010000
         DC    C'ABCDEFGHI'                                             15020000
         ORG   P#TBLCH+C'J'                                             15030000
         DC    C'JKLMNOPQR'                                             15040000
         ORG   P#TBLCH+C'S'                                             15050000
         DC    C'STUVWXYZ'                                              15060000
         ORG   P#TBLCH+C'0'                                             15070000
         DC    C'0123456789'                                            15080000
         ORG   ,                                                        15090000
*                                                                       15100000
*        Cat header                                                     15110000
*                                                                       15120000
         DC     0D'+0'                                                  15130000
CHD      BLKBGN OFF=0,LEN=F0                                            15140000
         BLKENT LABEL,'RCDKEYTY',   000                                *15150000
               NEWLIN=YES                                               15160000
         BLKENT  HEX,00,02                                              15170000
         BLKENT LABEL,'Record Type',OFFSET=70                           15180000
         BLKENT LABEL,'RCDCINO ',   001                                *15190000
               NEWLIN=YES                                               15200000
         BLKENT  HEX,.NEXT,06                                           15210000
         BLKENT LABEL,'CI Number',OFFSET=70                             15220000
         BLKENT LABEL,'RCDRELID',   004                                *15230000
               NEWLIN=YES                                               15240000
         BLKENT  HEX,.NEXT,02                                           15250000
         BLKENT LABEL,'Release',OFFSET=70                               15260000
         BLKENT LABEL,'RCDCRAVL',   005                                *15270000
               NEWLIN=YES                                               15280000
         BLKENT  HEX,.NEXT,0C                                           15290000
         BLKENT LABEL,'Recovery Volume Serial',OFFSET=70                15300000
         BLKENT LABEL,'RCDCRACI',   00B                                *15310000
               NEWLIN=YES                                               15320000
         BLKENT  HEX,.NEXT,06                                           15330000
         BLKENT LABEL,'Recovery CI Number',OFFSET=70                    15340000
         BLKENT LABEL,'RCDCRADT',   00E                                *15350000
               NEWLIN=YES                                               15360000
         BLKENT  HEX,.NEXT,08                                           15370000
         BLKENT LABEL,'Recovery Device Type',OFFSET=70                  15380000
         BLKENT LABEL,'RCDRACTS',   012                                *15390000
               NEWLIN=YES                                               15400000
         BLKENT  HEX,.NEXT,08                                           15410000
         BLKENT LABEL,'Recovery Time Stamp',OFFSET=70                   15420000
         BLKENT LABEL,'RCDDICTS',   016                                *15430000
               NEWLIN=YES                                               15440000
         BLKENT  HEX,.NEXT,08                                           15450000
         BLKENT LABEL,'Creation Time Stamp',OFFSET=70                   15460000
         BLKENT LABEL,'        ',   01A                                *15470000
               NEWLIN=YES                                               15480000
         BLKENT  HEX,.NEXT,08                                           15490000
         BLKENT LABEL,'Reserved',OFFSET=70                              15500000
         BLKENT LABEL,'        ',   01E                                *15510000
               NEWLIN=YES                                               15520000
         BLKENT  HEX,.NEXT,08                                           15530000
         BLKENT LABEL,'Creation Time Stamp',OFFSET=70                   15540000
         BLKENT LABEL,'        ',   022                                *15550000
               NEWLIN=YES                                               15560000
         BLKENT  HEX,.NEXT,08                                           15570000
         BLKENT LABEL,'Reserved',OFFSET=70                              15580000
         BLKENT LABEL,'        ',   026                                *15590000
               NEWLIN=YES                                               15600000
         BLKENT  HEX,.NEXT,08                                           15610000
         BLKENT LABEL,'Reserved',OFFSET=70                              15620000
         BLKENT LABEL,'        ',   02A                                *15630000
               NEWLIN=YES                                               15640000
         BLKENT  HEX,.NEXT,04                                           15650000
         BLKENT LABEL,'Reserved',OFFSET=70                              15660000
         BLKENT LABEL,'RCDID   ',   02C                                *15670000
               NEWLIN=YES                                               15680000
         BLKENT  HEX,.NEXT,02                                           15690000
         BLKENT  LABEL,'-'                                              15700000
         BLKENT  CHAR,02C,01                                            15710000
         BLKENT LABEL,'Record Id',OFFSET=70                             15720000
         BLKENT LABEL,'RCDSIZ  ',   02D                                *15730000
               NEWLIN=YES                                               15740000
         BLKENT  HEX,.NEXT,04                                           15750000
         BLKENT LABEL,'Record Size',OFFSET=70                           15760000
         BLKENT LABEL,'NREPCV  ',   02F                                *15770000
               NEWLIN=YES                                               15780000
         BLKENT  HEX,.NEXT,02                                           15790000
         BLKENT LABEL,'Variable Size',OFFSET=70                         15800000
         BLKENT LABEL,'NREPLF  ',   030                                *15810000
               NEWLIN=YES                                               15820000
         BLKENT  HEX,.NEXT,02                                           15830000
         BLKENT LABEL,'Fixed Fields (GOP) Start',OFFSET=70              15840000
         BLKEND ,                                                       15850000
*                                                                       15860000
*        Type 'A'                                                       15870000
*                                                                       15880000
         DC     0D'+0'                                                  15890000
TYPA     BLKBGN OFF=31,LEN=F0                                           15900000
         BLKENT LABEL,'CNAME   ',   031                                *15910000
               NEWLIN=YES                                               15920000
         BLKENT  CHAR,.NEXT,2C                                          15930000
         BLKENT LABEL,'Data set name',OFFSET=70                         15940000
         BLKENT LABEL,'COWNID  ',   05D                                *15950000
               NEWLIN=YES                                               15960000
         BLKENT  HEX,.NEXT,10                                           15970000
         BLKENT LABEL,'Owner',OFFSET=70                                 15980000
         BLKENT LABEL,'CCRE    ',   065                                *15990000
               NEWLIN=YES                                               16000000
         BLKENT  HEX,.NEXT,06                                           16010000
         BLKENT LABEL,'Creation date',OFFSET=70                         16020000
         BLKENT LABEL,'CEXP    ',   068                                *16030000
               NEWLIN=YES                                               16040000
         BLKENT  HEX,.NEXT,06                                           16050000
         BLKENT LABEL,'Expiration date',OFFSET=70                       16060000
         BLKEND ,                                                       16070000
*                                                                       16080000
*        Type 'C'                                                       16090000
*                                                                       16100000
         DC     0D'+0'                                                  16110000
TYPC     BLKBGN OFF=31,LEN=F0                                           16120000
         BLKENT LABEL,'CNAME   ',   031                                *16130000
               NEWLIN=YES                                               16140000
         BLKENT  CHAR,.NEXT,2C                                          16150000
         BLKENT LABEL,'Data set name',OFFSET=70                         16160000
         BLKENT LABEL,'COWNID  ',   05D                                *16170000
               NEWLIN=YES                                               16180000
         BLKENT  HEX,.NEXT,10                                           16190000
         BLKENT LABEL,'Owner',OFFSET=70                                 16200000
         BLKENT LABEL,'CCRE    ',   065                                *16210000
               NEWLIN=YES                                               16220000
         BLKENT  HEX,.NEXT,06                                           16230000
         BLKENT LABEL,'Creation date',OFFSET=70                         16240000
         BLKENT LABEL,'CEXP    ',   068                                *16250000
               NEWLIN=YES                                               16260000
         BLKENT  HEX,.NEXT,06                                           16270000
         BLKENT LABEL,'Expiration date',OFFSET=70                       16280000
         BLKENT LABEL,'CATTR1  ',   06B                                *16290000
               NEWLIN=YES                                               16300000
         BLKENT  HEX,.NEXT,02                                           16310000
         BLKENT LABEL,'Data set attribute 1',OFFSET=70                  16320000
         BLKEND ,                                                       16330000
*                                                                       16340000
*        Type 'D'                                                       16350000
*                                                                       16360000
         DC     0D'+0'                                                  16370000
TYPD     BLKBGN OFF=31,LEN=F0                                           16380000
         BLKENT LABEL,'CNAME   ',   031                                *16390000
               NEWLIN=YES                                               16400000
         BLKENT  CHAR,.NEXT,2C                                          16410000
         BLKENT LABEL,'Data set name',OFFSET=70                         16420000
         BLKENT LABEL,'COWNID  ',   05D                                *16430000
               NEWLIN=YES                                               16440000
         BLKENT  HEX,.NEXT,10                                           16450000
         BLKENT LABEL,'Owner',OFFSET=70                                 16460000
         BLKENT LABEL,'CCRE    ',   065                                *16470000
               NEWLIN=YES                                               16480000
         BLKENT  HEX,.NEXT,06                                           16490000
         BLKENT LABEL,'Creation date',OFFSET=70                         16500000
         BLKENT LABEL,'CEXP    ',   068                                *16510000
               NEWLIN=YES                                               16520000
         BLKENT  HEX,.NEXT,06                                           16530000
         BLKENT LABEL,'Expiration date',OFFSET=70                       16540000
         BLKENT LABEL,'CATTR1  ',   06B                                *16550000
               NEWLIN=YES                                               16560000
         BLKENT  HEX,.NEXT,02                                           16570000
         BLKENT LABEL,'Data set attribute 1',OFFSET=70                  16580000
         BLKENT LABEL,'CATTR2  ',   06C                                *16590000
               NEWLIN=YES                                               16600000
         BLKENT  HEX,.NEXT,02                                           16610000
         BLKENT LABEL,'Data set attribute 2',OFFSET=70                  16620000
         BLKENT LABEL,'COPEN   ',   06D                                *16630000
               NEWLIN=YES                                               16640000
         BLKENT  HEX,.NEXT,02                                           16650000
         BLKENT LABEL,'Data set attribute 2',OFFSET=70                  16660000
         BLKENT LABEL,'CBUF    ',   06E                                *16670000
               NEWLIN=YES                                               16680000
         BLKENT  HEX,.NEXT,08                                           16690000
         BLKENT LABEL,'Buffer size',OFFSET=70                           16700000
         BLKENT LABEL,'CPRIM   ',   072                                *16710000
               NEWLIN=YES                                               16720000
         BLKENT  HEX,.NEXT,06                                           16730000
         BLKENT LABEL,'Primary allocation',OFFSET=70                    16740000
         BLKENT LABEL,'CSEC    ',   075                                *16750000
               NEWLIN=YES                                               16760000
         BLKENT  HEX,.NEXT,06                                           16770000
         BLKENT LABEL,'Secondary allocation',OFFSET=70                  16780000
         BLKENT LABEL,'CSORT   ',   078                                *16790000
               NEWLIN=YES                                               16800000
         BLKENT  HEX,.NEXT,02                                           16810000
         BLKENT LABEL,'Allocation type',OFFSET=70                       16820000
         BLKENT LABEL,'CHIU    ',   079                                *16830000
               NEWLIN=YES                                               16840000
         BLKENT  HEX,.NEXT,08                                           16850000
         BLKENT LABEL,'High used RBA',OFFSET=70                         16860000
         BLKENT LABEL,'CHIA    ',   07D                                *16870000
               NEWLIN=YES                                               16880000
         BLKENT  HEX,.NEXT,08                                           16890000
         BLKENT LABEL,'High allocated RBA',OFFSET=70                    16900000
         BLKENT LABEL,'CLRECL  ',   081                                *16910000
               NEWLIN=YES                                               16920000
         BLKENT  HEX,.NEXT,08                                           16930000
         BLKENT LABEL,'Record length',OFFSET=70                         16940000
         BLKENT LABEL,'CDOSUINF',   085                                *16950000
               NEWLIN=YES                                               16960000
         BLKENT  HEX,.NEXT,04                                           16970000
         BLKENT LABEL,'User information DOS/US',OFFSET=70               16980000
         BLKENT LABEL,'CEXT    ',   087                                *16990000
               NEWLIN=YES                                               17000000
         BLKENT  HEX,.NEXT,10                                           17010000
         BLKENT LABEL,'EXCP exit',OFFSET=70                             17020000
         BLKEND ,                                                       17030000
*                                                                       17040000
*        Type 'I'                                                       17050000
*                                                                       17060000
         DC     0D'+0'                                                  17070000
TYPI     BLKBGN OFF=31,LEN=F0                                           17080000
         BLKENT LABEL,'CNAME   ',   031                                *17090000
               NEWLIN=YES                                               17100000
         BLKENT  CHAR,.NEXT,2C                                          17110000
         BLKENT LABEL,'Data set name',OFFSET=70                         17120000
         BLKENT LABEL,'COWNID  ',   05D                                *17130000
               NEWLIN=YES                                               17140000
         BLKENT  HEX,.NEXT,10                                           17150000
         BLKENT LABEL,'Owner',OFFSET=70                                 17160000
         BLKENT LABEL,'CCRE    ',   065                                *17170000
               NEWLIN=YES                                               17180000
         BLKENT  HEX,.NEXT,06                                           17190000
         BLKENT LABEL,'Creation date',OFFSET=70                         17200000
         BLKENT LABEL,'CEXP    ',   068                                *17210000
               NEWLIN=YES                                               17220000
         BLKENT  HEX,.NEXT,06                                           17230000
         BLKENT LABEL,'Expiration date',OFFSET=70                       17240000
         BLKENT LABEL,'CATTR1  ',   06B                                *17250000
               NEWLIN=YES                                               17260000
         BLKENT  HEX,.NEXT,02                                           17270000
         BLKENT LABEL,'Data set attribute 1',OFFSET=70                  17280000
         BLKENT LABEL,'CATTR2  ',   06C                                *17290000
               NEWLIN=YES                                               17300000
         BLKENT  HEX,.NEXT,02                                           17310000
         BLKENT LABEL,'Data set attribute 2',OFFSET=70                  17320000
         BLKENT LABEL,'COPEN   ',   06D                                *17330000
               NEWLIN=YES                                               17340000
         BLKENT  HEX,.NEXT,02                                           17350000
         BLKENT LABEL,'Data set attribute 2',OFFSET=70                  17360000
         BLKENT LABEL,'CBUF    ',   06E                                *17370000
               NEWLIN=YES                                               17380000
         BLKENT  HEX,.NEXT,08                                           17390000
         BLKENT LABEL,'Buffer size',OFFSET=70                           17400000
         BLKENT LABEL,'CPRIM   ',   072                                *17410000
               NEWLIN=YES                                               17420000
         BLKENT  HEX,.NEXT,06                                           17430000
         BLKENT LABEL,'Primary allocation',OFFSET=70                    17440000
         BLKENT LABEL,'CSEC    ',   075                                *17450000
               NEWLIN=YES                                               17460000
         BLKENT  HEX,.NEXT,06                                           17470000
         BLKENT LABEL,'Secondary allocation',OFFSET=70                  17480000
         BLKENT LABEL,'CSORT   ',   078                                *17490000
               NEWLIN=YES                                               17500000
         BLKENT  HEX,.NEXT,02                                           17510000
         BLKENT LABEL,'Allocation type',OFFSET=70                       17520000
         BLKENT LABEL,'CHIU    ',   079                                *17530000
               NEWLIN=YES                                               17540000
         BLKENT  HEX,.NEXT,08                                           17550000
         BLKENT LABEL,'High used RBA',OFFSET=70                         17560000
         BLKENT LABEL,'CHIA    ',   07D                                *17570000
               NEWLIN=YES                                               17580000
         BLKENT  HEX,.NEXT,08                                           17590000
         BLKENT LABEL,'High allocated RBA',OFFSET=70                    17600000
         BLKENT LABEL,'CLRECL  ',   081                                *17610000
               NEWLIN=YES                                               17620000
         BLKENT  HEX,.NEXT,08                                           17630000
         BLKENT LABEL,'Record length',OFFSET=70                         17640000
         BLKENT LABEL,'CDOSUINF',   085                                *17650000
               NEWLIN=YES                                               17660000
         BLKENT  HEX,.NEXT,04                                           17670000
         BLKENT LABEL,'User information DOS/US',OFFSET=70               17680000
         BLKENT LABEL,'CEXT    ',   087                                *17690000
               NEWLIN=YES                                               17700000
         BLKENT  HEX,.NEXT,10                                           17710000
         BLKENT LABEL,'EXCP exit',OFFSET=70                             17720000
         BLKEND ,                                                       17730000
*                                                                       17740000
*        Type X'00'                                                     17750000
*                                                                       17760000
         DC     0D'+0'                                                  17770000
TYP00    BLKBGN OFF=0,LEN=F0                                            17780000
         BLKENT LABEL,'DSname  ',                                      *17790000
               NEWLIN=YES                                               17800000
         BLKENT  CHAR,.NEXT,2C                                          17810000
         BLKENT LABEL,'Data set name',OFFSET=70                         17820000
         BLKENT LABEL,'RCDID   ',                                      *17830000
               NEWLIN=YES                                               17840000
         BLKENT  HEX,.NEXT,02                                           17850000
         BLKENT LABEL,'Record Id',OFFSET=70                             17860000
         BLKENT LABEL,'CI num  ',                                      *17870000
               NEWLIN=YES                                               17880000
         BLKENT  HEX,.NEXT,02                                           17890000
         BLKENT LABEL,'CI Number',OFFSET=70                             17900000
         BLKEND ,                                                       17910000
*                                                                       17920000
*        GOP Hdr                                                        17930000
*                                                                       17940000
         DC     0D'+0'                                                  17950000
GOPH     BLKBGN OFF=PASS,LEN=F0                                         17960000
         BLKENT LABEL,'EXTGOCI ',   08F                                *17970000
               NEWLIN=YES                                               17980000
         BLKENT  HEX,.NEXT,06                                           17990000
         BLKENT LABEL,'Extension CI',OFFSET=70                          18000000
         BLKENT LABEL,'        ',   092                                *18010000
               NEWLIN=YES                                               18020000
         BLKENT  HEX,.NEXT,04                                           18030000
         BLKENT LABEL,'Reserved',OFFSET=70                              18040000
         BLKENT LABEL,'REPCNT  ',   094                                *18050000
               NEWLIN=YES                                               18060000
         BLKENT  HEX,.NEXT,02                                           18070000
         BLKENT LABEL,'Number of GOPs',OFFSET=70                        18080000
         BLKEND ,                                                       18090000
*                                                                       18100000
*        GOP                                                            18110000
*                                                                       18120000
         DC     0D'+0'                                                  18130000
GOP      BLKBGN OFF=PASS,LEN=F0                                         18140000
         BLKENT LABEL,'CATGOCI ',   095                                *18150000
               NEWLIN=YES                                               18160000
         BLKENT  HEX,.NEXT,06                                           18170000
         BLKENT LABEL,'        ',OFFSET=70                              18180000
         BLKENT LABEL,'CATGOGC1',   098                                *18190000
               NEWLIN=YES                                               18200000
         BLKENT  HEX,.NEXT,02                                           18210000
         BLKENT LABEL,'        ',OFFSET=70                              18220000
         BLKENT LABEL,'CATGOSEQ',   099                                *18230000
               NEWLIN=YES                                               18240000
         BLKENT  HEX,.NEXT,02                                           18250000
         BLKENT LABEL,'        ',OFFSET=70                              18260000
         BLKEND ,                                                       18270000
*                                                                       18280000
*        Type E Volume Extension                                        18290000
*                                                                       18300000
         DC     0D'+0'                                                  18310000
TYPEVE   BLKBGN OFF=PASS,LEN=F0                                         18320000
         BLKENT LABEL,'UPRLRP  ',                                      *18330000
               NEWLIN=YES                                               18340000
         BLKENT  HEX,.NEXT,04                                           18350000
         BLKENT LABEL,'        ',OFFSET=70                              18360000
         BLKENT LABEL,'UPDEVT  ',                                      *18370000
               NEWLIN=YES                                               18380000
         BLKENT  HEX,.NEXT,08                                           18390000
         BLKENT LABEL,'Device type',OFFSET=70                           18400000
         BLKENT LABEL,'UPVOL   ',                                      *18410000
               NEWLIN=YES                                               18420000
         BLKENT  CHAR,.NEXT,06                                          18430000
         BLKENT LABEL,'Volume serial number',OFFSET=70                  18440000
         BLKENT LABEL,'UPFLSQ  ',                                      *18450000
               NEWLIN=YES                                               18460000
         BLKENT  HEX,.NEXT,04                                           18470000
         BLKENT LABEL,'File sequence',OFFSET=70                         18480000
         BLKENT LABEL,'UPVLFLG ',                                      *18490000
               NEWLIN=YES                                               18500000
         BLKENT  HEX,.NEXT,02                                           18510000
         BLKENT LABEL,'Flags',OFFSET=70                                 18520000
         BLKENT LABEL,'UPNOEXT ',                                      *18530000
               NEWLIN=YES                                               18540000
         BLKENT  HEX,.NEXT,02                                           18550000
         BLKENT LABEL,'Number extents',OFFSET=70                        18560000
         BLKENT LABEL,'UPHKBA  ',                                      *18570000
               NEWLIN=YES                                               18580000
         BLKENT  HEX,.NEXT,08                                           18590000
         BLKENT LABEL,'High key RBA',OFFSET=70                          18600000
         BLKENT LABEL,'UPHUBA  ',                                      *18610000
               NEWLIN=YES                                               18620000
         BLKENT  HEX,.NEXT,08                                           18630000
         BLKENT LABEL,'High used RBA',OFFSET=70                         18640000
         BLKENT LABEL,'UPHABA  ',                                      *18650000
               NEWLIN=YES                                               18660000
         BLKENT  HEX,.NEXT,08                                           18670000
         BLKENT LABEL,'High allocated RBA',OFFSET=70                    18680000
         BLKENT LABEL,'UPPHYB  ',                                      *18690000
               NEWLIN=YES                                               18700000
         BLKENT  HEX,.NEXT,08                                           18710000
         BLKENT LABEL,'Physical block size',OFFSET=70                   18720000
         BLKENT LABEL,'UPNBTK  ',                                      *18730000
               NEWLIN=YES                                               18740000
         BLKENT  HEX,.NEXT,04                                           18750000
         BLKENT LABEL,'Blocks per track',OFFSET=70                      18760000
         BLKENT LABEL,'UPNTKA  ',                                      *18770000
               NEWLIN=YES                                               18780000
         BLKENT  HEX,.NEXT,04                                           18790000
         BLKENT LABEL,'Tracks allocated',OFFSET=70                      18800000
         BLKENT LABEL,'UPITEX  ',                                      *18810000
               NEWLIN=YES                                               18820000
         BLKENT  HEX,.NEXT,02                                           18830000
         BLKENT LABEL,'Flag',OFFSET=70                                  18840000
         BLKENT LABEL,'UPSSDS  ',                                      *18850000
               NEWLIN=YES                                               18860000
         BLKENT  HEX,.NEXT,04                                           18870000
         BLKENT LABEL,'Directory sequence number',OFFSET=70             18880000
         BLKEND ,                                                       18890000
*                                                                       18900000
*        Type E Low Key Extension                                       18910000
*                                                                       18920000
         DC     0D'+0'                                                  18930000
TYPEELK  BLKBGN OFF=PASS,LEN=F0                                         18940000
         BLKENT LABEL,'VARLEN  ',                                      *18950000
               NEWLIN=YES                                               18960000
         BLKENT  HEX,.NEXT,04                                           18970000
         BLKENT LABEL,'Length',OFFSET=70                                18980000
         BLKENT LABEL,'VARFLD  ',                                      *18990000
               NEWLIN=YES                                               19000000
         BLKENT  HEX,.NEXT,02                                           19010000
         BLKENT LABEL,'Low key',OFFSET=70                               19020000
         BLKEND ,                                                       19030000
*                                                                       19040000
*        Type E High Key Extension                                      19050000
*                                                                       19060000
         DC     0D'+0'                                                  19070000
TYPEEHK  BLKBGN OFF=PASS,LEN=F0                                         19080000
         BLKENT LABEL,'VARLEN  ',                                      *19090000
               NEWLIN=YES                                               19100000
         BLKENT  HEX,.NEXT,04                                           19110000
         BLKENT LABEL,'Length',OFFSET=70                                19120000
         BLKENT LABEL,'VARFLD  ',                                      *19130000
               NEWLIN=YES                                               19140000
         BLKENT  HEX,.NEXT,02                                           19150000
         BLKENT LABEL,'High key',OFFSET=70                              19160000
         BLKEND ,                                                       19170000
*                                                                       19180000
*        Type E Extent Extension                                        19190000
*                                                                       19200000
         DC     0D'+0'                                                  19210000
TYPEEEX  BLKBGN OFF=PASS,LEN=F0                                         19220000
         BLKENT LABEL,'EXTILEN ',                                      *19230000
               NEWLIN=YES                                               19240000
         BLKENT  HEX,.NEXT,04                                           19250000
         BLKENT LABEL,'Length',OFFSET=70                                19260000
         BLKENT LABEL,'EXTSS   ',                                      *19270000
               NEWLIN=YES                                               19280000
         BLKENT  HEX,.NEXT,04                                           19290000
         BLKENT LABEL,'Sequence number',OFFSET=70                       19300000
         BLKENT LABEL,'EXTCC1  ',                                      *19310000
               NEWLIN=YES                                               19320000
         BLKENT  HEX,.NEXT,04                                           19330000
         BLKENT LABEL,'Starting CC of extent',OFFSET=70                 19340000
         BLKENT LABEL,'EXTHH1  ',                                      *19350000
               NEWLIN=YES                                               19360000
         BLKENT  HEX,.NEXT,04                                           19370000
         BLKENT LABEL,'Starting HH of extent',OFFSET=70                 19380000
         BLKENT LABEL,'EXTCC2  ',                                      *19390000
               NEWLIN=YES                                               19400000
         BLKENT  HEX,.NEXT,04                                           19410000
         BLKENT LABEL,'Ending CC of extent',OFFSET=70                   19420000
         BLKENT LABEL,'EXTHH2  ',                                      *19430000
               NEWLIN=YES                                               19440000
         BLKENT  HEX,.NEXT,04                                           19450000
         BLKENT LABEL,'Ending HH of extent',OFFSET=70                   19460000
         BLKENT LABEL,'EXTTT   ',                                      *19470000
               NEWLIN=YES                                               19480000
         BLKENT  HEX,.NEXT,04                                           19490000
         BLKENT LABEL,'Tracks in extent',OFFSET=70                      19500000
         BLKENT LABEL,'EXTDDDD1',                                      *19510000
               NEWLIN=YES                                               19520000
         BLKENT  HEX,.NEXT,08                                           19530000
         BLKENT LABEL,'Low RBA of extent',OFFSET=70                     19540000
         BLKENT LABEL,'EXTDDDD2',                                      *19550000
               NEWLIN=YES                                               19560000
         BLKENT  HEX,.NEXT,08                                           19570000
         BLKENT LABEL,'High RBA of extent',OFFSET=70                    19580000
         BLKEND ,                                                       19590000
*                                                                       19600000
*        Variable information                                           19610000
*                                                                       19620000
         DC     0D'+0'                                                  19630000
VARFLD   BLKBGN OFF=PASS,LEN=F0                                         19640000
         BLKENT LABEL,'VARLEN  ',                                      *19650000
               NEWLIN=YES                                               19660000
         BLKENT  HEX,.NEXT,04                                           19670000
         BLKENT LABEL,'Variable length',OFFSET=70                       19680000
         BLKEND ,                                                       19690000
**********************************************************************  19700000
*        Initialization                                              *  19710000
**********************************************************************  19720000
INIT     DS    0H                                                       19730000
         ST    R14,W#INIT14                                             19740000
         LR    R8,R15                                                   19750000
         USING INIT,R8                                                  19760000
         L     R9,0(,R1)                                                19770000
         OPEN  (SYSPRINT,(OUTPUT))                                      19780000
         TM    SYSPRINT+48,16                                           19790000
         BZ    EXITRC8                                                  19800000
         TIME  BIN                     GET CURRENT DATE AND TIME        19810000
         ST    R1,CURDATE              SAVE DATE                        19820000
         SRDL  R0,32                   GET DOUBLE WORD TIME             19830000
         D     R0,=F'+6000'            GET MINUTES                      19840000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     19850000
         SLR   R0,R0                   CLEAR                            19860000
         D     R0,=F'+60'              GET HOURS / MINS                 19870000
         MH    R0,=H'+10000'           GET MINUTES                      19880000
         AR    R15,R0                  ADD TO GET MM:SS.TH              19890000
         M     R0,=F'+1000000'         GET HOURS                        19900000
         AR    R1,R15                  GET HH:MM:SS.TH                  19910000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              19920000
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   19930000
         ED    TIMWRK4,W#DWORD+3       EDIT TIME                        19940000
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        19950000
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  19960000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    19970000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         19980000
         MVO   W#DWORD,CURDATE+1(1)    SIGN YEAR                        19990000
         DP    W#DWORD,=P'+4'          DIVIDE BY 4                      20000000
         CP    W#DWORD+7(1),=P'+0'     IS IT A LEAP YEAR ?              20010000
         BNZ   JULCVT2                  NO                              20020000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    20030000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         20040000
JULCVT2  DS    0H                                                       20050000
         LA    R1,JULTBL1              POINT TO JANUARY                 20060000
         SLR   R2,R2                   SET COUNTER                      20070000
JULCVT4  DS    0H                                                       20080000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              20090000
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  20100000
         BCTR  R1,0                    POINT TO NEXT MONTH              20110000
         BCTR  R1,0                    POINT TO NEXT MONTH              20120000
         LA    R2,3(,R2)               UP INDEX                         20130000
         B     JULCVT4                 LOOP                             20140000
JULCVT6  DS    0H                                                       20150000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                20160000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    20170000
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       20180000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     20190000
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         20200000
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   20210000
         LA    R1,HD1DATE+6            SET POINTER                      20220000
         BNE   JULCVT7                  NO                              20230000
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 20240000
         BCTR  R1,0                    DROP POINTER                     20250000
JULCVT7  DS    0H                                                       20260000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  20270000
         TM    CURDATE,1               YEAR 2000?                       20280000
         BNO   JULCVT8                  NO, CONTINUE                    20290000
         MVC   2(2,R1),=C'20'          Y2K                              20300000
JULCVT8  DS    0H                                                       20310000
         UNPK  W#DWORD(3),CURDATE+1(2) UNPACK YEAR                      20320000
         MVC   4(2,R1),W#DWORD         GET YEAR                         20330000
* PARSE PARM=                                                           20340000
         MVC   LINE+1(5),=C'PARM='                                      20350000
         SLR   R15,R15                                                  20360000
         ICM   R15,3,0(R9)                                              20370000
         BZ    PRMNOP                                                   20380000
         BCTR  R15,0                                                    20390000
         B     PRMDOMVC                                                 20400000
PRMMVC   MVC   LINE+6(0),2(R9)                                          20410000
PRMDOMVC DS    0H                                                       20420000
         EX    R15,PRMMVC                                               20430000
PRMNOP   DS    0H                                                       20440000
         BAL   R14,PRT                                                  20450000
         LH    R2,0(,R9)                                                20460000
         LA    R9,2(,R9)                                                20470000
         ST    R9,W#PRMBGN                                              20480000
PRMSCN   DS    0H                                                       20490000
         LTR   R2,R2                                                    20500000
         BE    PRMEND                                                   20510000
         CLI   0(R9),C','                                               20520000
         BNE   PRMCHK                                                   20530000
         LA    R9,1(,R9)                                                20540000
         SH    R2,=H'1'                                                 20550000
         B     PRMSCN                                                   20560000
PRMCHK   DS    0H                                                       20570000
         CH    R2,=H'2'                                                 20580000
         BL    PRMERR                                                   20590000
         CH    R2,=H'4'                                                 20600000
         BL    PRMERR                                                   20610000
         CLC   =C'DUMP',0(R9)                                           20620000
         BE    PRMDMP                                                   20630000
         CLC   =C'DIAG',0(R9)                                           20640001
         BE    PRMDIA                                                   20650001
         CH    R2,=H'5'                                                 20660000
         BL    PRMERR                                                   20670000
         CLC   =C'DEBUG',0(R9)                                          20680000
         BE    PRMDBG                                                   20690000
         CH    R2,=H'6'                                                 20700000
         BL    PRMERR                                                   20710000
         CLC   =C'FORMAT',0(R9)                                         20720000
         BE    PRMFMT                                                   20730000
         CLC   =C'TYPE=',0(R9)                                          20740000
         BE    PRMTY                                                    20750000
         CH    R2,=H'7'                                                 20760000
         BL    PRMERR                                                   20770000
         CLC   =C'START=',0(R9)                                         20780000
         BE    PRMST                                                    20790000
         CLC   =C'COUNT=',0(R9)                                         20800000
         BE    PRMCT                                                    20810000
         CH    R2,=H'11'                                                20820000
         BL    PRMERR                                                   20830000
         CLC   =C'CATALOG=YES',0(R9)                                    20840000
         BE    PRMCAT                                                   20850000
         B     PRMERR                                                   20860000
PRMDMP   DS    0H                                                       20870000
         OI    DMPFLAG,DMPDMP                                           20880000
         LA    R9,4(,R9)                                                20890000
         SH    R2,=H'4'                                                 20900000
         B     PRMSCNC                                                  20910000
PRMDIA   DS    0H                                                       20920001
         OI    DMPFLG1,DMPDIAG                                          20930001
         LA    R9,4(,R9)                                                20940001
         SH    R2,=H'4'                                                 20950001
         B     PRMSCNC                                                  20960001
PRMFMT   DS    0H                                                       20970000
         OI    DMPFLAG,DMPFMT                                           20980000
         LA    R9,6(,R9)                                                20990000
         SH    R2,=H'6'                                                 21000000
         B     PRMSCNC                                                  21010000
PRMDBG   DS    0H                                                       21020000
         OI    DMPFLAG,DMPDBG                                           21030000
         LA    R9,5(,R9)                                                21040000
         SH    R2,=H'5'                                                 21050000
         B     PRMSCNC                                                  21060000
PRMST    DS    0H                                                       21070000
         LA    R9,6(,R9)                                                21080000
         SH    R2,=H'6'                                                 21090000
         SLR   R14,R14                                                  21100000
         LA    R0,8                                                     21110000
PRMST1   DS    0H                                                       21120000
         CLI   0(R9),C'0'                                               21130000
         BL    PRMERR                                                   21140000
         CLI   0(R9),C'9'                                               21150000
         BH    PRMERR                                                   21160000
         SR    R15,R15                                                  21170000
         IC    R15,0(,R9)                                               21180000
         N     R15,=A(X'F')                                             21190000
         MH    R14,=H'10'                                               21200000
         AR    R14,R15                                                  21210000
         LA    R9,1(,R9)                                                21220000
         SH    R2,=H'1'                                                 21230000
         BZ    PRMST2                                                   21240000
         CLI   0(R9),C','                                               21250000
         BE    PRMST2                                                   21260000
         LA    R1,1(,R1)                                                21270000
         BCT   R0,PRMST1                                                21280000
PRMST2   DS    0H                                                       21290000
         CH    R14,=H'1'                                                21300000
         BL    PRMERR                                                   21310000
         ST    R14,W#CIBGN                                              21320000
         B     PRMSCNC                                                  21330000
PRMCT    DS    0H                                                       21340000
         LA    R9,6(,R9)                                                21350000
         SH    R2,=H'6'                                                 21360000
         SLR   R14,R14                                                  21370000
         LA    R0,8                                                     21380000
PRMCT1   DS    0H                                                       21390000
         CLI   0(R9),C'0'                                               21400000
         BL    PRMERR                                                   21410000
         CLI   0(R9),C'9'                                               21420000
         BH    PRMERR                                                   21430000
         SR    R15,R15                                                  21440000
         IC    R15,0(,R9)                                               21450000
         N     R15,=A(X'F')                                             21460000
         MH    R14,=H'10'                                               21470000
         AR    R14,R15                                                  21480000
         LA    R9,1(,R9)                                                21490000
         SH    R2,=H'1'                                                 21500000
         BZ    PRMCT2                                                   21510000
         CLI   0(R9),C','                                               21520000
         BE    PRMCT2                                                   21530000
         LA    R1,1(,R1)                                                21540000
         BCT   R0,PRMCT1                                                21550000
PRMCT2   DS    0H                                                       21560000
         ST    R14,W#CINUM                                              21570000
         B     PRMSCNC                                                  21580000
PRMTY    DS    0H                                                       21590000
         LA    R9,5(,R9)                                                21600000
         SH    R2,=H'5'                                                 21610000
         LA    R1,SELTYPES                                              21620000
         LA    R0,L'SELTYPES                                            21630000
PRMTY1   DS    0H                                                       21640000
         CLI   0(R1),C' '                                               21650000
         BE    PRMTY2                                                   21660000
         LA    R1,1(,R1)                                                21670000
         BCT   R0,PRMTY1                                                21680000
         B     PRMERR                                                   21690000
PRMTY2   DS    0H                                                       21700000
         CLI   0(R9),C'('                                               21710000
         BE    PRMTY3                                                   21720000
         CLI   0(R9),C','                                               21730000
         BE    PRMSCNC                                                  21740000
         MVC   0(1,R1),0(R9)                                            21750000
         OI    DMPFLAG,DMPBYTYP                                         21760000
         LA    R9,1(,R9)                                                21770000
         SH    R2,=H'1'                                                 21780000
         B     PRMSCNC                                                  21790000
PRMTY3   DS    0H                                                       21800000
         LA    R9,1(,R9)                                                21810000
         SH    R2,=H'1'                                                 21820000
         BZ    PRMERR                                                   21830000
PRMTY4   DS    0H                                                       21840000
         CLI   0(R9),C')'                                               21850000
         BE    PRMTY5                                                   21860000
         LTR   R0,R0                                                    21870000
         BZ    PRMERR                                                   21880000
         MVC   0(1,R1),0(R9)                                            21890000
         OI    DMPFLAG,DMPBYTYP                                         21900000
         BCTR  R0,0                                                     21910000
         LA    R1,1(,R1)                                                21920000
         LA    R9,1(,R9)                                                21930000
         BCT   R2,PRMTY4                                                21940000
         B     PRMSCNC                                                  21950000
PRMTY5   DS    0H                                                       21960000
         LA    R9,1(,R9)                                                21970000
         BCTR  R2,0                                                     21980000
         B     PRMSCNC                                                  21990000
PRMCAT   DS    0H                                                       22000000
         OI    DMPFLAG,DMPCAT                                           22010000
         LA    R9,11(,R9)                                               22020000
         SH    R2,=H'11'                                                22030000
         B     PRMSCNC                                                  22040000
PRMSCNC  DS    0H                                                       22050000
         LTR   R2,R2                                                    22060000
         BE    PRMEND                                                   22070000
         CLI   0(R9),C','                                               22080000
         BE    PRMSCN                                                   22090000
         B     PRMERR                                                   22100000
PRMEND   DS    0H                                                       22110000
         TESTAUTH FCTN=1               Are we authorized                22120000
         LTR   R15,R15                                                  22130000
         BNZ   ERRAUTH                                                  22140000
* Generate VSAM ACB                                                     22150000
         TM    DMPFLAG,DMPCAT          Catalog ACB requeste             22160000
         BO    INITCATA                Yes, gen tha ACB                 22170000
         GENCB BLK=ACB,                CREATE AN ACB                   *22180000
               AM=VSAM,                FOR VSAM                        *22190000
               BUFND=16,               NUMBER OF DATA BUFFERS          *22200000
               BUFNI=16,               NUMBER OF INDEX BUFFERS         *22210000
               DDNAME=(*,DDNAME),      A(DDNAME)                       *22220000
               MACRF=(DIR,             DIRECT ACCESS                   *22230000
               SEQ,                    SEQUENTIAL ACCESS               *22240000
               IN,                     INPUT ONLY                      *22250000
               ADR),                   IN ADDRESS ORDER                *22260000
               MAREA=(S,MAREA),        MESSAGE AREA                    *22270000
               MLEN=L'MAREA,           L(MESSAGE AREA)                 *22280000
               STRNO=1,                NUMBER OF STRINGS               *22290000
               MF=(G,GENACB,GENACBLN)  WHERE TO BUILD GENCB             22300000
         B     INITACBE                                                 22310000
INITCATA DS    0H                                                       22320000
         GENCB BLK=ACB,                CREATE AN ACB                   *22330000
               AM=VSAM,                FOR VSAM                        *22340000
               CATALOG=YES,            AND A CATALOG                   *22350000
               BUFND=16,               NUMBER OF DATA BUFFERS          *22360000
               BUFNI=16,               NUMBER OF INDEX BUFFERS         *22370000
               DDNAME=(*,DDNAME),      A(DDNAME)                       *22380000
               MACRF=(DIR,             DIRECT ACCESS                   *22390000
               SEQ,                    SEQUENTIAL ACCESS               *22400000
               IN,                     INPUT ONLY                      *22410000
               ADR),                   IN ADDRESS ORDER                *22420000
               MAREA=(S,MAREA),        MESSAGE AREA                    *22430000
               MLEN=L'MAREA,           L(MESSAGE AREA)                 *22440000
               STRNO=1,                NUMBER OF STRINGS               *22450000
               MF=(G,GENACB,GENACBLC)  WHERE TO BUILD GENCB             22460000
INITACBE DS    0H                                                       22470000
         LTR   R15,R15                                                  22480000
         BNZ   ERRGNACB                                                 22490000
         LR    R4,R1                   COPY A(ACB)                      22500000
         ST    R4,W#ACBSAV                                              22510000
         USING IFGACB,R4                                                22520000
* Generate VSAM RPL                                                     22530000
         OI    ACBINFL1,ACBBYPSS                                        22540000
         GENCB BLK=RPL,                CREATE AN RPL                   *22550000
               AM=VSAM,                FOR VSAM                        *22560000
               ACB=(S,IFGACB),         A(ACB)                          *22570000
               ARG=(S,SARG),           A(ARG)                          *22580000
               AREA=(S,SAREA),         A(AREA)                         *22590000
               AREALEN=L'SAREA,        L(AREA)                         *22600000
               MSGAREA=(S,SMSGA),      A(MESSAGE AREA FOR PHYSICAL ERR)*22610000
               MSGLEN=L'SMSGA,         L(MESSAGE AREA FOR PHYSICAL ERR)*22620000
               OPTCD=(SEQ,             SEQUENTIAL                      *22630000
               FWD,                    FORWORD                         *22640000
               SYN,                    ISSUE SYNCHRONOUSLY             *22650000
               NUP,                    NOT UPDATE                      *22660000
               LOC,                    LOCATE MODE                     *22670000
               ADR),                   IN ADDRESS ORDER                *22680000
               MF=(G,GENRPL,GENRPLLN)  WHERE TO BUILD GENCB             22690000
         LTR   R15,R15                                                  22700000
         BNZ   ERRGNRPL                                                 22710000
         ST    R1,W#RPLSAV                                              22720000
         MODESET KEY=ZERO                                               22730000
         OPEN  ((R4))                                                   22740000
         LR    R2,R15                                                   22750000
         LR    R3,R0                                                    22760000
         MODESET KEY=NZERO                                              22770000
         LR    R0,R3                                                    22780000
         SLR   R1,R1                                                    22790000
         IC    R1,ACBERFLG                                              22800000
         DROP  R4                                                       22810000
         LTR   R15,R2                                                   22820000
         BZ    OPNOK                                                    22830000
         C     R15,=A(4)                                                22840000
         BNE   ERROPN                                                   22850000
         MVC   LINE+1(9),=C'Warn OPEN'                                  22860000
         BAL   R14,RCMSG                                                22870000
OPNOK    DS    0H                                                       22880000
         RDJFCB JFCBDCB                                                 22890000
         LTR   R15,R15                                                  22900000
         BNZ   ERRRDJF                                                  22910000
         MVC   LINE+1(4),=C'DSN='                                       22920000
         MVC   LINE+5(L'DSNAME),DSNAME                                  22930000
         BAL   R14,PRT                                                  22940000
         BAL   R14,PRT                                                  22950000
         L     R5,W#CIBGN                                               22960000
         BCTR  R5,0                                                     22970000
         ST    R5,W#CURRCI                                              22980000
         L     R14,W#INIT14                                             22990000
         BR    R14                                                      23000000
         LTORG ,                                                        23010000
CODEEND  DC     0D'+0'                                                  23020000
ERRRC4   DC    A(RPLDVOL,MSGDVOL,L'MSGDVOL)                             23030000
         DC    A(RPLMOKEY,MSGMOKEY,L'MSGMOKEY)                          23040000
         DC    A(RPLWTBFR,MSGWTBFR,L'MSGWTBFR)                          23050000
         DC    A(RPLIXEND,MSGIXEND,L'MSGIXEND)                          23060000
         DC    A(RPLNOMSS,MSGNOMSS,L'MSGNOMSS)                          23070000
         DC    A(RPLCIWNG,MSGCIWNG,L'MSGCIWNG)                          23080000
         DC    A(RPLASYER,MSGASYER,L'MSGASYER)                          23090000
         DC    A(RPLDSERR,MSGDSERR,L'MSGDSERR)                          23100000
         DC    A(RPLDBPER,MSGDBPER,L'MSGDBPER)                          23110000
         DC    A(RPLDTOKN,MSGDTOKN,L'MSGDTOKN)                          23120000
         DC    A(RPLUPCAT,MSGUPCAT,L'MSGUPCAT)                          23130000
         DC    A(X'FFFFFFFF',UNKNMSG,L'UNKNMSG)                         23140000
ERRRC8   DC    A(RPLEODER,MSGEODER,L'MSGEODER)                          23150000
         DC    A(RPLDUP,MSGDUP,L'MSGDUP)                                23160000
         DC    A(RPLSEQCK,MSGSEQCK,L'MSGSEQCK)                          23170000
         DC    A(RPLNOREC,MSGNOREC,L'MSGNOREC)                          23180000
         DC    A(RPLEXCL,MSGEXCL,L'MSGEXCL)                             23190000
         DC    A(RPLNOMNT,MSGNOMNT,L'MSGNOMNT)                          23200000
         DC    A(RPLNOEXT,MSGNOEXT,L'MSGNOEXT)                          23210000
         DC    A(RPLINRBA,MSGINRBA,L'MSGINRBA)                          23220000
         DC    A(RPLNOKR,MSGNOKR,L'MSGNOKR)                             23230000
         DC    A(RPLNOVRT,MSGNOVRT,L'MSGNOVRT)                          23240000
         DC    A(RPLINBUF,MSGINBUF,L'MSGINBUF)                          23250000
         DC    A(RPLINTRM,MSGINTRM,L'MSGINTRM)                          23260000
         DC    A(RPLPTERM,MSGPTERM,L'MSGPTERM)                          23270000
         DC    A(RPLNOPLH,MSGNOPLH,L'MSGNOPLH)                          23280000
         DC    A(RPLINACC,MSGINACC,L'MSGINACC)                          23290000
         DC    A(RPLINKEY,MSGINKEY,L'MSGINKEY)                          23300000
         DC    A(RPLINADR,MSGINADR,L'MSGINADR)                          23310000
         DC    A(RPLERSER,MSGERSER,L'MSGERSER)                          23320000
         DC    A(RPLINLOC,MSGINLOC,L'MSGINLOC)                          23330000
         DC    A(RPLNOPTR,MSGNOPTR,L'MSGNOPTR)                          23340000
         DC    A(RPLINUPD,MSGINUPD,L'MSGINUPD)                          23350000
         DC    A(RPLKEYCH,MSGKEYCH,L'MSGKEYCH)                          23360000
         DC    A(RPLDLCER,MSGDLCER,L'MSGDLCER)                          23370000
         DC    A(RPLINVP,MSGINVP,L'MSGINVP)                             23380000
         DC    A(RPLINLEN,MSGINLEN,L'MSGINLEN)                          23390000
         DC    A(RPLKEYLC,MSGKEYLC,L'MSGKEYLC)                          23400000
         DC    A(RPLINLRQ,MSGINLRQ,L'MSGINLRQ)                          23410000
         DC    A(RPLINTCB,MSGINTCB,L'MSGINTCB)                          23420000
         DC    A(RPLUEXCL,MSGUEXCL,L'MSGUEXCL)                          23430000
         DC    A(RPLIXHHP,MSGIXHHP,L'MSGIXHHP)                          23440000
         DC    A(RPLSRLOC,MSGSRLOC,L'MSGSRLOC)                          23450000
         DC    A(RPLARSRK,MSGARSRK,L'MSGARSRK)                          23460000
         DC    A(RPLSRISG,MSGSRISG,L'MSGSRISG)                          23470000
         DC    A(RPLNBRCD,MSGNBRCD,L'MSGNBRCD)                          23480000
         DC    A(RPLNXPTR,MSGNXPTR,L'MSGNXPTR)                          23490000
         DC    A(RPLNOBFR,MSGNOBFR,L'MSGNOBFR)                          23500000
         DC    A(RPLINCNV,MSGINCNV,L'MSGINCNV)                          23510000
         DC    A(RPLINMSS,MSGINMSS,L'MSGINMSS)                          23520000
         DC    A(RPLPLERR,MSGPLERR,L'MSGPLERR)                          23530000
         DC    A(RPLACQER,MSGACQER,L'MSGACQER)                          23540000
         DC    A(RPLSTGER,MSGSTGER,L'MSGSTGER)                          23550000
         DC    A(RPLVOLER,MSGVOLER,L'MSGVOLER)                          23560000
         DC    A(RPLCTGER,MSGCTGER,L'MSGCTGER)                          23570000
         DC    A(RPLEOVER,MSGEOVER,L'MSGEOVER)                          23580000
         DC    A(RPLNO241,MSGNO241,L'MSGNO241)                          23590000
         DC    A(RPLIRRNO,MSGIRRNO,L'MSGIRRNO)                          23600000
         DC    A(RPLRRADR,MSGRRADR,L'MSGRRADR)                          23610000
         DC    A(RPLPAACI,MSGPAACI,L'MSGPAACI)                          23620000
         DC    A(RPLPUTBK,MSGPUTBK,L'MSGPUTBK)                          23630000
         DC    A(RPLINVEQ,MSGINVEQ,L'MSGINVEQ)                          23640000
         DC    A(RPLNOSPL,MSGNOSPL,L'MSGNOSPL)                          23650000
         DC    A(RPLPMLCK,MSGPMLCK,L'MSGPMLCK)                          23660000
         DC    A(RPLAMBLR,MSGAMBLR,L'MSGAMBLR)                          23670000
         DC    A(RPLESRER,MSGESRER,L'MSGESRER)                          23680000
         DC    A(RPLMOIB,MSGMOIB,L'MSGMOIB)                             23690000
         DC    A(RPLINVMD,MSGINVMD,L'MSGINVMD)                          23700000
         DC    A(RPLDELCH,MSGDELCH,L'MSGDELCH)                          23710000
         DC    A(RPLUPENV,MSGUPENV,L'MSGUPENV)                          23720000
         DC    A(RPLUPERR,MSGUPERR,L'MSGUPERR)                          23730000
         DC    A(RPLINVSI,MSGINVSI,L'MSGINVSI)                          23740000
         DC    A(RPLINCTK,MSGINCTK,L'MSGINCTK)                          23750000
         DC    A(RPLNOCON,MSGNOCON,L'MSGNOCON)                          23760000
         DC    A(RPLCHEFL,MSGCHEFL,L'MSGCHEFL)                          23770000
         DC    A(RPLUSTAT,MSGUSTAT,L'MSGUSTAT)                          23780000
         DC    A(RPLRQPUR,MSGRQPUR,L'MSGRQPUR)                          23790000
         DC    A(RPLUNEXP,MSGUNEXP,L'MSGUNEXP)                          23800000
         DC    A(RPLINNDX,MSGINNDX,L'MSGINNDX)                          23810000
         DC    A(RPLSVR14,MSGSVR14,L'MSGSVR14)                          23820000
         DC    A(RPLCMSCE,MSGCMSCE,L'MSGCMSCE)                          23830000
         DC    A(RPLCMSDE,MSGCMSDE,L'MSGCMSDE)                          23840000
         DC    A(RPLSUSPE,MSGSUSPE,L'MSGSUSPE)                          23850000
         DC    A(RPLRST14,MSGRST14,L'MSGRST14)                          23860000
         DC    A(RPLVCTKI,MSGVCTKI,L'MSGVCTKI)                          23870000
         DC    A(RPLINVDT,MSGINVDT,L'MSGINVDT)                          23880000
         DC    A(RPLER252,MSGER252,L'MSGER252)                          23890000
         DC    A(RPLER253,MSGER253,L'MSGER253)                          23900000
         DC    A(RPLERQUS,MSGERQUS,L'MSGERQUS)                          23910000
         DC    A(X'FFFFFFFF',UNKNMSG,L'UNKNMSG)                         23920000
UNKNMSG  DC    C'Unknown reason code'                                   23930000
MSGDVOL  DC    C'EOV called'                                            23940000
MSGMOKEY DC    C'Duplicate key follows'                                 23950000
MSGWTBFR DC    C'Write buffer is suggested'                             23960000
MSGIXEND DC    C'New control area sequence set record too short'        23970000
MSGNOMSS DC    C'Data set is not on virtual DASD for MNTACQ/ACQRANGE re*23980000
               quest'                                                   23990000
MSGCIWNG DC    C'A CI split busy condition has been detected for read-o*24000000
               nly addressed access'                                    24010000
MSGASYER DC    C'A deferred request is ASY and cannot be restarted by T*24020000
               ERMRPL'                                                  24030000
MSGDSERR DC    C'Possible data set error condition detected by TERMRPL' 24040000
MSGDBPER DC    C'Error in PLH data BUFC pointer detected by TERMRPL'    24050000
MSGDTOKN DC    C'EOV called to retrieve or update the dictionary token *24060000
               in the catalog'                                          24070000
MSGUPCAT DC    C'EOV called to update the catalog statistics'           24080000
*                                                                       24090000
MSGEODER DC    C'End of data detected'                                  24100000
MSGDUP   DC    C'Duplicate record or duplicate record for AIX with uniq*24110000
               ue key option'                                           24120000
MSGSEQCK DC    C'Key sequence error'                                    24130000
MSGNOREC DC    C'No record found'                                       24140000
MSGEXCL  DC    C'Control interval exclusive use conflict'               24150000
MSGNOMNT DC    C'Record on nonmountable volume'                         24160000
MSGNOEXT DC    C'Not able to extend data set'                           24170000
MSGINRBA DC    C'Invalid RBA'                                           24180000
MSGNOKR  DC    C'No key range defined for PUT record'                   24190000
MSGNOVRT DC    C'Virtual storage not available'                         24200000
MSGINBUF DC    C'Record area too small'                                 24210000
MSGINTRM DC    C'Invalid attributes, RPL options'                       24220000
MSGPTERM DC    C'The previous request was TERMRPL'                      24230000
MSGNOPLH DC    C'Placeholder not available'                             24240000
MSGINACC DC    C'Access type not allowed by MACRF or password'          24250000
MSGINKEY DC    C'Keyed request for ESDS GETIX/PUTIX to ESDS/RRDS'       24260000
MSGINADR DC    C'ADR/CNV PUT add to KSDS or CI insert for a RRDS'       24270000
MSGERSER DC    C'Invalid erase request or erase via path for ESDS'      24280000
MSGINLOC DC    C'Invalid locate mode request'                           24290000
MSGNOPTR DC    C'Sequential GET request without being positioned or cha*24300002
               nged from addressed to keyed without being positioned'   24310002
MSGINUPD DC    C'UPD/ERASE no GET for update PUTIX without preceding GE*24330000
               TIX'                                                     24340000
MSGKEYCH DC    C'Key change attempted'                                  24350000
MSGDLCER DC    C'Record length change on addressed update or on RRDS up*24360000
               date'                                                    24370000
MSGINVP  DC    C'Invalid RPL options'                                   24380000
MSGINLEN DC    C'Record length too large or too small or RECLEN not equ*24390000
               al to record (slot) size spec for RRDS'                  24400000
MSGKEYLC DC    C'Generic key length too large or zero'                  24410000
MSGINLRQ DC    C'Invalid request type or option during load or request *24420000
               other than PUT insert for RRDS loading'                  24430000
MSGINTCB DC    C'Invalid TCB'                                           24440000
MSGUEXCL DC    C'JRNAD cancel code'                                     24450000
MSGIXHHP DC    C'Invalid index CI horizontal pointer'                   24460000
MSGSRLOC DC    C'Attempt to read spanned record in locate mode'         24470000
MSGARSRK DC    C'ADR retrieval of spanned record of KSDS attempted'     24480000
MSGSRISG DC    C'Inconsistent spanned record'                           24490000
MSGNBRCD DC    C'Pointer in AIX with no base record'                    24500000
MSGNXPTR DC    C'Maximum number of AIX record pointers exceeded'        24510000
MSGNOBFR DC    C'No buffers'                                            24520000
MSGINCNV DC    C'Invalid data CI or CI split busy and addressed access *24530000
               for output'                                              24540000
MSGINMSS DC    C'Invalid options specified for CNVTAD/MNTACQ/ACQRANGE r*24550000
               equest'                                                  24560000
MSGPLERR DC    C'User parameter list errors detected'                   24570000
MSGACQER DC    C'Acquire immediate error returned by SVC 126'           24580000
MSGSTGER DC    C'Staging failure'                                       24590000
MSGVOLER DC    C'RBA/volume error'                                      24600000
MSGCTGER DC    C'Catalog errors returned'                               24610000
MSGEOVER DC    C'End of volume initialize failure for SVC 55 for WAIT o*24620000
               n AMBXN'                                                 24630000
MSGNO241 DC    C'Storage in subpooL 241 not available'                  24640000
MSGIRRNO DC    C'Invalid relative record number'                        24650000
MSGRRADR DC    C'Addressed request for RRDS'                            24660000
MSGPAACI DC    C'ADR or CNV access thru path attempted'                 24670000
MSGPUTBK DC    C'PUT insert not allowed in backward mode'               24680000
MSGINVEQ DC    C'Invalid ENDREQ issued (301 prevented)'                 24690000
MSGNOSPL DC    C'Unable to split index'                                 24700000
MSGPMLCK DC    C'Invalid parameter list for SVC 109'                    24710000
MSGAMBLR DC    C'Invalid AMBL detected'                                 24720000
MSGESRER DC    C'Unrecognizable return code from SVC 109'               24730000
MSGMOIB  DC    C'MRKBFR out for invalid buffer'                         24740000
MSGINVMD DC    C'(1) XM caller is not in supervisor state or (2) SRB/XM*24750000
                caller is not synchronous with shared resources'        24760000
MSGDELCH DC    C'Record length changed during decompress'               24770000
MSGUPENV DC    C'Environment changed by user UPAD routine'              24780000
MSGUPERR DC    C'UPAD error'                                            24790000
MSGINVSI DC    C'SHR(3 or 4) validity check'                            24800000
MSGINCTK DC    C'Invalid connect token'                                 24810000
MSGNOCON DC    C'No connectivity to cache'                              24820000
MSGCHEFL DC    C'Cache structure failure'                               24830000
MSGUSTAT DC    C'Resources in unknown state'                            24840000
MSGRQPUR DC    C'Request was purged'                                    24850000
MSGUNEXP DC    C'Unexpected cache return code'                          24860000
MSGINNDX DC    C'Invalid vector index'                                  24870000
MSGSVR14 DC    C'Register 14 stack size not large enough'               24880000
MSGCMSCE DC    C'Severe error returned from CMS for a compress call'    24890000
MSGCMSDE DC    C'Severe error returned from CMS for a decompress call'  24900000
MSGSUSPE DC    C'Severe error returned from suspend macro'              24910000
MSGRST14 DC    C'Register 14 return offset negative'                    24920000
MSGVCTKI DC    C'Invalid vector token'                                  24930000
MSGINVDT DC    C'No valid dictionary token exists data cannot be decomp*24940000
               ressed'                                                  24950000
MSGER252 DC    C'Record mode access invalid for a LDS'                  24960000
MSGER253 DC    C'Verify function invalid for a LDS'                     24970000
MSGERQUS DC    C'Activities on data set not quiesced before CLOSE'      24980000
         DC    (((((*-CAT38DMP)/4096)+1)*4096)-(*-CAT38DMP))X'00'       24990000
*                                                                       25000000
*                                                                       25010000
*                                                                       25020000
WORK     CSECT ,                                                        25030000
W#SA     DC    18A(0)                                                   25040000
W#DWORD  DC    D'+0'                                                    25050000
W#INIT14 DC    A(0)                                                     25060000
W#DMPRCE DC    A(0)                                                     25070000
W#PRT14  DC    A(0)                                                     25080000
W#RCMS14 DC    A(0)                                                     25090000
W#PRTH14 DC    A(0)                                                     25100000
W#PRTU14 DC    A(0)                                                     25110000
W#DIAG14 DC    A(0)                                                     25120000
W#GETSAV DC    3A(0)                                                    25130000
W#RPLE14 DC    A(0)                                                     25140000
W#EVALRG DC    16A(0)                                                   25150000
W#CIBGN  DC    A(1)                                                     25160000
W#CURRCI DC    A(0)                                                     25170000
W#ACBSAV DC    A(0)                                                     25180000
W#RPLSAV DC    A(0)                                                     25190000
W#CINUM  DC    F'-1'                                                    25200000
W#PRMBGN DC    A(10)                                                    25210000
DMPREGS  DC    16A(0)                                                   25220000
W#DMPRGS DS    0A                    **                                 25230000
W#DMPR14 DS    A                      *                                 25240000
W#DMPR15 DS    A                      * Keep                            25250000
W#DMPR0  DS    A                      *  together                       25260000
W#DMPR1  DS    A                      *                                 25270000
W#DMPR2  DS    A                     **                                 25280000
OFFSET   DS    A                                                        25290000
DUPFIRST DS    A                                                        25300000
*                                                                       25310001
DMPFLAG  DC    X'00'                                                    25320000
DMPFIRST EQU   X'80'                                                    25330000
DMPDUP   EQU   X'40'                                                    25340000
DMPDBG   EQU   X'20'                                                    25350000
DMPFMT   EQU   X'10'                                                    25360000
DMPDMP   EQU   X'08'                                                    25370000
DMPBYTYP EQU   X'04'                                                    25380000
DMPCAT   EQU   X'02'                                                    25390000
DMPUNKRC EQU   X'01'                                                    25400000
*                                                                       25410001
DMPFLG1  DC    X'00'                                                    25420001
DMPDIAG  EQU   X'80'                                                    25430001
*                                                                       25440001
W#RECRD  DC    PL4'+0'                                                  25450000
SELTYPES DC    CL26' '                                                  25460000
DDNAME   DC    CL8'SYSVSAM'                                             25470000
*                                                                       25480001
         DC    0D'+0'                                                   25490000
GENACB   DC    XL(GENACBLC)'0'                                          25500001
         ORG   GENACB                                                   25510001
         DC    XL(GENACBLN)'0'                                          25520001
         ORG   ,                                                        25530001
*                                                                       25540001
MAREA    DC    XL128'0'                                                 25550000
SARG     DC    A(0)                                                     25560000
SAREA    DC    A(0)                                                     25570000
RECLEN   DC    A(0)                                                     25580000
SMSGA    DC    XL128'0'                                                 25590000
*                                                                       25600001
         DC    0D'+0'                                                   25610000
GENRPL   DC    XL(GENRPLLN)'0'                                          25620001
*                                                                       25630001
LINE     DC    CL133' '                                                 25640000
CURDATE  DC    A(0)                                                     25650000
JULWRK2  DC    A(0)                                                     25660000
*                                                                       25670001
JULWRK4  DC    P'+365'                                                  25680000
         DC    P'+01'                                                   25690000
         DC    P'+31'                                                   25700000
         DC    P'+30'                                                   25710000
         DC    P'+31'                                                   25720000
         DC    P'+30'                                                   25730000
         DC    P'+31'                                                   25740000
         DC    P'+31'                                                   25750000
         DC    P'+30'                                                   25760000
         DC    P'+31'                                                   25770000
         DC    P'+30'                                                   25780000
         DC    P'+31'                                                   25790000
JULWRK6  DC    P'+28'                                                   25800000
JULTBL1  DC    P'+31'                                                   25810000
*                                                                       25820001
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  25830000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            25840000
LNCT     DC    PL2'+99'                                                 25850000
PGCT     DC    PL3'+0'                                                  25860000
*                                                                       25870001
HD1      DC    CL133'1'                                                 25880000
         ORG   HD1+1                                                    25890000
HD1DATE  DC    C'            '                                          25900000
         DC    C' '                                                     25910000
HD1TOD   DC    C'HH:MM:SS'                                              25920000
         ORG   HD1+66-(24/2)                                            25930000
HD1DATA  DC    C'VSAM Catalog Record Dump'                              25940000
         ORG   HD1+L'HD1-11                                             25950000
HD1PG    DC    C'Page'                                                  25960000
HD1PGCT  DC    C' 12,345'                                               25970000
         ORG                                                            25980000
*                                                                       25990001
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X26000000
               RECFM=FBA,LRECL=133                                      26010000
JFCBDCB  DCB   DDNAME=SYSVSAM,MACRF=R,DSORG=PS,EXLST=INLIST             26020000
INLIST   DC    0A(0)               EXIT LIST INPUT FILE                 26030000
         DC    AL1(128+7),AL3(INJFCB)  JBCB AREA ADDRESS                26040000
*                                                                       26050000
*        J. F. C. B.                                                    26060000
*                                                                       26070000
INJFCB   DC    0A(0)               JFCB AREA                            26080000
DSNAME   DC    CL44' '                                                  26090000
ELNAME   DC    CL8' '                                                   26100000
JFCBTSDM DC    B'0'                                                     26110000
         DC    XL19'0'                                                  26120000
JFCBMASK DC    8X'0'                                                    26130000
JFCBCRDT DC    XL3'0'                                                   26140000
JFCBXPDT DC    XL3'0'                                                   26150000
JFCBIND1 DC    X'0'                                                     26160000
JFCBIND2 DC    X'0'                                                     26170000
         DC    6X'0'                                                    26180000
JFCBDEN  DC    X'0'                                                     26190000
         DC    5X'0'                                                    26200000
RECFM    DC    B'0'                                                     26210000
         DC    B'0'                                                     26220000
BLKSZ    DC    H'+0'                                                    26230000
LRECL    DC    H'+0'                                                    26240000
         DC    XL11'0'                                                  26250000
NOVOLSER DC    X'0'                                                     26260000
VOLSERS  DC    5CL6' '                                                  26270000
         DC    XL28'0'                                                  26280000
*                                                                       26290000
*                                                                       26300000
*                                                                       26310000
W#FREGS  DC    16A(0)                                                   26320000
W#FDWD   DC    D'0'                                                     26330000
W#FADDR  DC    A(0)                                                     26340000
W#FTEMP  DC    CL9' '                                                   26350000
W#FFLAG  DC    X'00'                                                    26360000
W#FFLAG1 EQU   X'80'                                                    26370000
*                                                                       26380001
L        DC    0D'+0'                                                   26390000
L0       DC    AL1(0)                                                   26400000
L1       DC    AL1(0)                                                   26410000
L2       DC    AL1(0)                                                   26420000
L3       DC    AL1(0)                                                   26430000
L4       DC    AL1(0)                                                   26440000
L5       DC    AL1(0)                                                   26450000
L6       DC    AL1(0)                                                   26460000
L7       DC    AL1(0)                                                   26470000
*                                                                       26480000
*                                                                       26490000
*                                                                       26500000
W#RECCTR DC    0F'0'                                                    26510000
W#RECA   DC    0F'0'                                                    26520000
         DC    PL4'+0'                                                  26530000
         DC    PL4'+0'                                                  26540000
         DC    A(PROCA)                                                 26550000
         DC    CL40'Type A (Non-VSAM)'                                  26560000
*                                                                       26570000
W#RECC   DC    0F'0'                                                    26580000
         DC    PL4'+0'                                                  26590000
         DC    PL4'+0'                                                  26600000
         DC    A(PROCC)                                                 26610000
         DC    CL40'Type C (Cluster)'                                   26620000
*                                                                       26630000
W#RECD   DC    0F'0'                                                    26640000
         DC    PL4'+0'                                                  26650000
         DC    PL4'+0'                                                  26660000
         DC    A(PROCD)                                                 26670000
         DC    CL40'Type D (Data)'                                      26680000
*                                                                       26690000
W#RECE   DC    0F'0'                                                    26700000
         DC    PL4'+0'                                                  26710000
         DC    PL4'+0'                                                  26720000
         DC    A(PROCE)                                                 26730000
         DC    CL40'Type E (Cluster Extention)'                         26740000
*                                                                       26750000
W#RECF   DC    0F'0'                                                    26760000
         DC    PL4'+0'                                                  26770000
         DC    PL4'+0'                                                  26780000
         DC    A(0)                                                     26790000
         DC    CL40'Type F (Free)'                                      26800000
*                                                                       26810000
W#RECI   DC    0F'0'                                                    26820000
         DC    PL4'+0'                                                  26830000
         DC    PL4'+0'                                                  26840000
         DC    A(PROCI)                                                 26850000
         DC    CL40'Type I (Index)'                                     26860000
*                                                                       26870000
W#RECL   DC    0F'0'                                                    26880000
         DC    PL4'+0'                                                  26890000
         DC    PL4'+0'                                                  26900000
         DC    A(0)                                                     26910000
         DC    CL40'Type L (Catalog Control Record)'                    26920000
*                                                                       26930000
W#RECU   DC    0F'0'                                                    26940000
         DC    PL4'+0'                                                  26950000
         DC    PL4'+0'                                                  26960000
         DC    A(0)                                                     26970000
         DC    CL40'Type U (User Catalog)'                              26980000
*                                                                       26990000
W#RECV   DC    0F'0'                                                    27000000
         DC    PL4'+0'                                                  27010000
         DC    PL4'+0'                                                  27020000
         DC    A(0)                                                     27030000
         DC    CL40'Type V (Volume)'                                    27040000
*                                                                       27050000
W#RECW   DC    0F'0'                                                    27060000
         DC    PL4'+0'                                                  27070000
         DC    PL4'+0'                                                  27080000
         DC    A(0)                                                     27090000
         DC    CL40'Type W (Volume Extension)'                          27100000
*                                                                       27110000
W#RECX   DC    0F'0'                                                    27120000
         DC    PL4'+0'                                                  27130000
         DC    PL4'+0'                                                  27140000
         DC    A(0)                                                     27150000
         DC    CL40'Type X (Alias)'                                     27160000
*                                                                       27170000
W#REC00  DC    0F'0'                                                    27180000
         DC    PL4'+0'                                                  27190000
         DC    PL4'+0'                                                  27200000
         DC    A(0)                                                     27210000
         DC    CL40'Type X''00'''                                       27220000
*                                                                       27230000
W#REC    DC    0F'0'                                                    27240000
         DC    PL4'+0'                                                  27250000
         DC    PL4'+0'                                                  27260000
         DC    A(0)                                                     27270000
         DC    CL40'Type Unknown'                                       27280000
*                                                                       27290000
W#RECEND EQU   *                                                        27300000
WORKEND  DC    0D'0'                                                    27310000
         DC    (((((*-WORK)/4096)+1)*4096)-(*-WORK))X'00'               27320000
*                                                                       27330000
*                                                                       27340000
*                                                                       27350000
RECDS    DSECT                                                          27360000
RECCT    DS    PL4                                                      27370000
RECSE    DS    PL4                                                      27380000
RECRT    DS    A(0)                                                     27390000
RECID    DS    CL40                                                     27400000
REC      EQU   RECDS,*-RECDS                                            27410000
*                                                                       27420000
*        Formatting field descriptor layout                             27430000
*                                                                       27440000
BLK      DSECT                                                          27450000
BLKFIRST DS    AL2                 Start offset                         27460000
BLKSIZE  DS    AL2                 Block length                         27470000
BLKHDNXT EQU   *                                                        27480000
         ORG   BLK                                                      27490000
*        Common area                                                    27500000
BLKTYPE  DS    X                   Descriptor type                      27510000
BLKEND   EQU   0                   End of block                         27520000
BLKCHAR  EQU   4                   Character field                      27530000
BLKHEX   EQU   8                   Hex field                            27540000
BLKCONST EQU   12                  Constant                             27550000
BLKBGN   DS    0X                  Common starting point                27560000
*        Character field                                                27570000
BLKOFF   DS    AL1                 Offset into output area              27580000
BLKDISP  DS    AL2                 Field displacement                   27590000
BLKCHRSC DS    AL1                 SCON of length if variable           27600000
BLKCHRLN DS    AL1                 Output length                        27610000
BLKCHRNX EQU   *                                                        27620000
         ORG   BLKBGN                                                   27630000
*        Hex field                                                      27640000
         DS    AL1                 Offset into output area              27650000
         DS    AL2                 Field displacement                   27660000
BLKHEXOF DS    AL1                 Input offset                         27670000
BLKHEXSC DS    AL1                 SCON of length if variable           27680000
BLKHEXLN DS    AL1                 Output length                        27690000
BLKHEXNX EQU   *                                                        27700000
         ORG   BLKBGN                                                   27710000
*        Character field                                                27720000
         DS    X                   Offset into output area              27730000
BLKDTALN DS    X                   Output length                        27740000
BLKDATA  DS    C                   Constant                             27750000
BLKDTANX EQU   *                                                        27760000
*                                                                       27770000
*                                                                       27780000
*                                                                       27790000
R0       EQU   0                                                        27800000
R1       EQU   1                                                        27810000
R2       EQU   2                                                        27820000
R3       EQU   3                                                        27830000
R4       EQU   4                                                        27840000
R5       EQU   5                                                        27850000
R6       EQU   6                                                        27860000
R7       EQU   7                                                        27870000
R8       EQU   8                                                        27880000
R9       EQU   9                                                        27890000
R10      EQU   10                                                       27900000
R11      EQU   11                                                       27910000
R12      EQU   12                                                       27920000
R13      EQU   13                                                       27930000
R14      EQU   14                                                       27940000
R15      EQU   15                                                       27950000
*                                                                       27960000
*                                                                       27970000
*                                                                       27980000
CATRCD   DSECT                                                          27990000
CATDSN   DS    0CL44      000  000   Data set name                      28000000
RCDKEYTY DS    X          000  000   RECORD KEY TYPE                    28010000
RCDCINO  DS    XL3        001  001   CONTROL NUMBER                     28020000
RCDRELID DS    X          004  004   RELEASE INDICATOR (X'01')          28030000
RCDCRAVL DS    CL6        005  005   VOL SER                            28040000
RCDCRACI DS    XL3        011  00B   RECOVERABLE CATALOG (CRA CI NO)    28050000
RCDCRADT DS    XL4        014  00E   DEVICE TYPE                        28060000
RCDRACTS DS    XL4        018  012   CRA CREATION TIME STAMP            28070000
RCDDICTS DS    XL4        022  016   D/I TIMESTAMP                      28080000
         DS    XL4        026  01A                                      28090000
         DS    XL4        030  01E   CREATION TIME STAMP                28100000
         DS    XL10       034  022                                      28110000
RCDID    DS    C          044  02C   RECORD ID                          28120000
RCDSIZ   DS    XL2        045  02D   RECORD SIZE                        28130000
TYP00LEN EQU   *-CATRCD                                                 28140000
NREPCV   DS    X          047  02F   VARIABLE SIZE                      28150000
NREPLF   DS    X          048  030   FIXED FIELDS START OF GOPS         28160000
*                                                                       28170000
*                                                                       28180000
*                                                                       28190000
CTGRBASE DS    0X     00  049  031                                      28200000
CNAME    DS    CL44   00  049  031                                      28210000
COWNID   DS    CL8    44  093  05D                                      28220000
CCRE     DS    XL3    52  101  065                                      28230000
CEXP     DS    XL3    55  104  068                                      28240000
TYPALEN  EQU   *-CATRCD                                                 28250000
CATTR    DS    0XL3   58  107  06B                                      28260000
CATTR1   DS    X      58  107  06B                                      28270000
TYPCLEN  EQU   *-CATRCD                                                 28280000
CATTR2   DS    X      59  108  06C                                      28290000
COPEN    DS    X      60  109  06D                                      28300000
CBUF     DS    XL4    61  110  06E                                      28310000
CSPACPRM DS    0X     65  114  072                                      28320000
CPRIM    DS    XL3    65  114  072                                      28330000
CSEC     DS    XL3    68  117  075                                      28340000
CSORT    DS    X      71  120  078                                      28350000
CHIU     DS    XL4    72  121  079                                      28360000
CHIA     DS    XL4    76  125  07D                                      28370000
CLRECL   DS    XL4    80  129  081                                      28380000
CDOSUINF DS    XL2    84  133  085                                      28390000
CEXT     DS    CL8    86  135  087                                      28400000
TYPDLEN  EQU   *-CATRCD                                                 28410000
TYPILEN  EQU   *-CATRCD                                                 28420000
CLENG    EQU   *-CTGRBASE                                               28430000
*                                                                       28440000
*                                                                       28450000
*                                                                       28460000
REPCNTRL DSECT                                                          28470000
EXTRCDPT DS    0XL6                                                     28480000
EXTGOCI  DS    XL3                   EXTENTION CI                       28490000
         DS    XL2                                                      28500000
REPCNT   DS    X                     NUMBER OF GOPS                     28510000
REPGOPT  DS    0X                                                       28520000
*                                                                       28530000
*                                                                       28540000
*                                                                       28550000
GOPT     DSECT ,                                                        28560000
CATGOPT  DS    0XL5                                                     28570000
CATGOCI  DS    0XL3                                                     28580000
         DS    X                                                        28590000
CATGODSP DS    XL2                   DISPLACEMENT TO GOP                28600000
CATGOFLG EQU   CATGOCI                                                  28610000
CATGOGC1 DS    X                     GROUP CODE                         28620000
CATGOEXT EQU   CATGOGC1 =80                                             28630000
CATGODEL EQU   CATGOGC1 =40                                             28640000
CATGOSEQ DS    X                     SEQUENCE NUMBER                    28650000
*                                                                       28660000
*                                                                       28670000
*                                                                       28680000
UPENTVOL DSECT ,          0                                             28690000
UPVOLFIX DS    0XL39      UPENTVOL                                      28700000
UPRLRP   DS    XL2        UPVOLFIX                                      28710000
UPDEVT   DS    XL4        UPVOLFIX+2   DEVICE TYPE                      28720000
UPVOL    DS    CL6        UPVOLFIX+6   VOL SER                          28730000
UPFLSQ   DS    XL2        UPVOLFIX+12  FILE SEQUENCE                    28740000
UPVLFLG  DS    X          UPVOLFIX+14                                   28750000
UPVLPR   EQU   B'10000000'             PRIME VOL                        28760000
UPVLCN   EQU   B'01000000'             CANDIDATE                        28770000
UPVLOV   EQU   B'00100000'             OVERFLOW                         28780000
UPNOEXT  DS    X          UPVOLFIX+15  NO EXTENTS                       28790000
UPHKBA   DS    XL4        UPVOLFIX+16  HI KEY                           28800000
UPHUBA   DS    XL4        UPVOLFIX+20  HI USED                          28810000
UPHABA   DS    XL4        UPVOLFIX+24  HI ALLOCATED                     28820000
UPPHYB   DS    XL4        UPVOLFIX+28  PHYSICAL BLOCK SIZE              28830000
UPNBTK   DS    XL2        UPVOLFIX+32  BLOCKS PER TRACK                 28840000
UPNTKA   DS    XL2        UPVOLFIX+34  TRACK ALLOCATED                  28850000
UPITEX   DS    X          UPVOLFIX+36                                   28860000
UPSSDT   EQU   B'10000000'                                              28870000
UPEXTNP  EQU   B'01000000'             PRE-FORMATTED                    28880000
UPSSDS   DS    XL2        UPVOLFIX+37  DATA SET DIRECTORY SEQ. NO       28890000
UPVOLVAR DS    0X         UPENTVOL+39  VOLUME VARIABLE INFORMATION      28900000
UPLKLN   DS    XL2        UPVOLVAR     VOLUME VARIABLE LENGTH           28910000
*                         VARFIELD                                      28920000
*                         VARLEN                                        28930000
*                                                                       28940000
*    UPRLRP - Length (Occurance)                                        28950000
*    |    Variable field                                                28960000
*    |    |  Length                                                     28970000
*    |    |  |    Variable field                                        28980000
*    |    |  |    |  Length (EXTILEN)                                   28990000
*    |    |  |    |  |                                                  29000000
*    |    |  |    |  |                                                  29010000
*    0000 |  0000 |  0014                                               29020000
*    0001 00 0001 3F 0014                                               29030000
*    0001 40 0001 FF 0014                                               29040000
*                                                                       29050000
*                                                                       29060000
EXTINF1  DSECT ,     00   0                                             29070000
EXTILEN  DS    XL2   00   EXTINF1      LENGTH OF EXTENT DESCRIPTORS     29080000
EXTINFO  DS    0XL6  02   EXTINF1+2                                     29090000
EXTSS    DS    XL2   02   EXTINFO      SPACE DESCRIPTOR SEQUENCE NO     29100000
EXTST    DS    0XL4  04   EXTINFO+2                                     29110000
EXTCC1   DS    XL2   04   EXTST        STARTING CC OF EXTENT            29120000
EXTHH1   DS    XL2   06   EXTST+2      STARTING HH OF EXTENT            29130000
EXTEND   DS    0XL4  08   EXTINFO+6                                     29140000
EXTCC2   DS    XL2   08   EXTEND       ENDING CC OF EXTENT              29150000
EXTHH2   DS    XL2   0A   EXTEND+2     ENDING HH OF EXTENT              29160000
EXTTT    DS    XL2   0C   EXTINFO+10   TOTAL TRACKS IN EXTENT           29170000
EXTDDDD1 DS    XL4   0E   EXTINFO+12   LOW RBA OF EXTENT                29180000
EXTDDDD2 DS    XL4   12   EXTINFO+16   HIGH RBA OF EXTENT               29190000
*                                                                       29200000
*                                                                       29210000
*                                                                       29220000
         IFGACB   AM=VSAM              MVS VSAM ACB                     29230000
ACBLEN   EQU      *                                                     29240000
         IFGRPL   AM=VSAM              MVS VSAM RPL                     29250000
RPLLENG  EQU      *                                                     29260000
         IDARMRCD ,                    MVS VSAM RPL FEEDBACK CODES      29270000
         IDAPLH   ,                    MVS VSAM PLH                     29280000
         IHAPSA   ,                    PSA                              29290000
         CVT      DSECT=YES            CVT                              29300000
         IKJTCB   ,                    TCB                              29310000
*        UNDEFINED RPL ERROR CODES                                      29320000
RPLNOMSS EQU   4095                                                     29330000
RPLASYER EQU   4095                                                     29340000
RPLDSERR EQU   4095                                                     29350000
RPLDBPER EQU   4095                                                     29360000
RPLDTOKN EQU   4095                                                     29370000
RPLUPCAT EQU   4095                                                     29380000
RPLINTRM EQU   4095                                                     29390000
RPLPTERM EQU   4095                                                     29400000
RPLUEXCL EQU   4095                                                     29410000
RPLIXHHP EQU   4095                                                     29420000
RPLINMSS EQU   4095                                                     29430000
RPLPLERR EQU   4095                                                     29440000
RPLACQER EQU   4095                                                     29450000
RPLSTGER EQU   4095                                                     29460000
RPLVOLER EQU   4095                                                     29470000
RPLCTGER EQU   4095                                                     29480000
RPLEOVER EQU   4095                                                     29490000
RPLNO241 EQU   4095                                                     29500000
RPLNOSPL EQU   4095                                                     29510000
RPLPMLCK EQU   4095                                                     29520000
RPLAMBLR EQU   4095                                                     29530000
RPLESRER EQU   4095                                                     29540000
RPLMOIB  EQU   4095                                                     29550000
RPLINVMD EQU   4095                                                     29560000
RPLDELCH EQU   4095                                                     29570000
RPLUPENV EQU   4095                                                     29580000
RPLUPERR EQU   4095                                                     29590000
RPLINVSI EQU   4095                                                     29600000
RPLINCTK EQU   4095                                                     29610000
RPLNOCON EQU   4095                                                     29620000
RPLCHEFL EQU   4095                                                     29630000
RPLUSTAT EQU   4095                                                     29640000
RPLRQPUR EQU   4095                                                     29650000
RPLUNEXP EQU   4095                                                     29660000
RPLINNDX EQU   4095                                                     29670000
RPLSVR14 EQU   4095                                                     29680000
RPLCMSCE EQU   4095                                                     29690000
RPLCMSDE EQU   4095                                                     29700000
RPLSUSPE EQU   4095                                                     29710000
RPLRST14 EQU   4095                                                     29720000
RPLVCTKI EQU   4095                                                     29730000
RPLINVDT EQU   4095                                                     29740000
RPLER252 EQU   4095                                                     29750000
RPLER253 EQU   4095                                                     29760000
RPLERQUS EQU   4095                                                     29770000
         END                                                            29780000
