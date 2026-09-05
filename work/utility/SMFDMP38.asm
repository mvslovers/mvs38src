*********************************************************************** 00010000
*                                                                     * 00020000
* Module name                                                         * 00030000
*    SMFDMP38                                                         * 00040000
*                                                                     * 00050000
* Attributes                                                          * 00060000
*    RENT                                                             * 00070000
*                                                                     * 00080000
* Authoe                                                              * 00090000
*    Dave Kreiss                                                      * 00100000
*                                                                     * 00110000
* Function                                                            * 00120000
*    Copies SMF data from any RECFM=VBS SMF data set with capability  * 00130000
*    to select SMF records by SMF record type.                        * 00140000
*                                                                     * 00150000
* JCL                                                                 * 00160000
*    //        EXEC PGM=SMFDMP38,PARM='parameters'                    * 00170000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00180000
*    //SYSPRINT DD  SYSOUT=*                                          * 00190000
*    //smfin    DD  DSN=input smf data set,DISP=SHR                   * 00200000
*    //smfout   DD  DSN=output smf data set,DISP=SHR                  * 00210000
*    //SYSIN    DD  *                                                 * 00220000
*                                                                     * 00230000
* DD Statements                                                       * 00240000
*    STEPLIB       Load library containing the load module SMFDMP38.  * 00250000
*    SYSPRINT      Summary of SMF  records read and written.          * 00260000
*    smfin         Input SMF data set as defined via SYSIN.           * 00270000
*    smfout        Output SMF data set as defined via SYSIN.          * 00280000
*    SYSIN         Control statements.                                * 00290000
*                  Control statment keywords must be preceded by      * 00300000
*                  1 or mor blanks starting in column 1.              * 00310000
*                  The INDD statement defines the input SMF data set. * 00320000
*                    INDD(smfin,OPTIONS(DUMP))                        * 00330000
*                      The input SMF data set DDNAME is specified     * 00340000
*                     in place of "smfin".                            * 00350000
*                      The  OPTIONS(DUMP) is optional.                * 00360000
*                  The OUTDD defines the output SMF data set and      * 00370000
*                  optionally the SMF record types to select.         * 00380000
*                    OUTDD(smfout,TYPE(n,n,n:n,n:n,...))              * 00390000
*                      The output SMF data set DDNAME is specified    * 00400000
*                     in place of "smfout".                           * 00410000
*                      The TYPE specifies the SMF records to select   * 00420000
*                     to the out SMF data set.                        * 00430000
*                      The SMF records can be either specified as     * 00440000
*                     a single SMF record type or a range of SMF      * 00450000
*                     record types.  Nultiple single and range        * 00460000
*                     selections may be specified.                    * 00470000
*                                                                     * 00480000
* Parameters                                                          * 00490000
*    Parameters are seperated by commas.                              * 00500000
*    DEBUG         DEBUG enables additional diagnostics relaged to    * 00510000
*                  the parsing of control statements.                 * 00520000
*                                                                     * 00530000
* Sample JCL                                                          * 00540000
*    This sample selects records 4, 255 and 70-74 from the input      * 00550000
*    DDNAME SMFIN - SYS1.MANX and writes those SMF records to the     * 00560000
*    output DDNAME SMFOUT.                                            * 00570000
*                                                                     * 00580000
*       //SMFDMP  EXEC PGM=SMFDMP38                                   * 00590000
*       //STEPLIB  DD  DSN=load library,DISP=SHR                      * 00600000
*       //SYSPRINT DD  SYSOUT=*                                       * 00610000
*       //SMFIN    DD  DSN=SYS1.MANX,DISP=SHR,                        * 00620000
*       //             DCB=(RECFM=VBS,LRECL=32760,BLKSIZE=23476)      * 00630000
*       //SMFOUT   DD  DSN=new smf data set,DISP=SHR,                 * 00640000
*       //             DCB=(RECFM=VBS,LRECL=32760,BLKSIZE=23476)      * 00650000
*       //SYSIN    DD  *                                              * 00660000
*           INDD(SMFIN,OPTIONS(DUMP))                                 * 00670000
*           OUTDD(SMFOUT,TYPE(4,255,70:74))                           * 00680000
*       /*                                                            * 00690000
*                                                                     * 00700000
* Note                                                                * 00710000
*    The DCB attributes shown in the sample may be needed for both    * 00720000
*    the input and output data sets.                                  * 00730000
*                                                                     * 00740000
*********************************************************************** 00750000
* Change log:                                                         * 00760000
*   Date   Int Ver   Description                                      * 00770000
* 07/31/20 DSK 1.01  Created                                          * 00780000
*********************************************************************** 00790000
SMFDMP38 CSECT                                                          00800000
         USING SMFDMP38,R15                                             00810000
         B     START                   Bypass PGMID                     00820000
         DROP  R15                                                      00830000
         DC    AL1(L'PGMID)            Length of PGMID                  00840000
PGMID    DC    C'SMFDMP38 - v1.01 &SYSDATE &SYSTIME'                    00850000
START    DS    0H                                                       00860000
         STM   R14,R12,12(R13)         Save calling pgm's registers     00870000
         LR    R11,R15                 Base register                    00880000
         LA    R12,2048(,R11)          Second                           00890000
         LA    R12,2048(,R12)           base register                   00900000
         USING SMFDMP38,R11,R12                                         00910000
         L     R4,0(,R1)               Save parameter address           00920001
         L     R0,=A(W#LEN)            Work area length                 00930000
         GETMAIN R,LV=(0)              Get work area                    00940000
         LR    R3,R13                  Save save area address           00950000
         LR    R13,R1                  Address save area                00960000
         LA    R10,2048(,R13)          Second                           00970000
         LA    R10,2048(,R10)           work area base register         00980000
         USING W#,R13,R10                                               00990000
         LR    R0,R13                  Work area address                01000000
         L     R1,=A(W#LEN)            Work area length                 01010000
         SR    R15,R15                 Set up to clear                  01020000
         MVCL  R0,R14                  Clear work area                  01030000
         ST    R3,4(,R13)              Chain callers save area          01040000
         ST    R13,8(,R3)              Chain my save area               01050000
         BAL   R14,INIT                Initialization                   01060000
         LTR   R15,R15                 Was it successful?               01070000
         BNZ   EXIT                    No, exit                         01080000
         LA    R9,W#BUFFER             Buffer address                   01090000
         USING SMFRCD,R9                                                01100000
*********************************************************************** 01110000
*        Process SMF records                                          * 01120000
*********************************************************************** 01130000
PROC     DS    0H                                                       01140000
         GET   W#SIDCB,W#BUFFER        Get record                       01150000
         AP    W#RECCT,=P'+1'          Count records read               01160000
* Record  Counts                                                        01170000
         SR    R1,R1                   Get SMF                          01180000
         IC    R1,SMFRTY                record type                     01190000
         SLL   R1,2                    Index into record read counters  01200000
         L     R0,W#RECIN(R1)          Get current count                01210000
         AH    R0,=H'1'                Add to it                        01220000
         ST    R0,W#RECIN(R1)          Save updated record count        01230000
* Low and High Record sizes                                             01240000
         LH    R0,SMFLEN               Get SMF record length            01250000
         L     R15,W#RECLO(R1)         Current smallest record          01260000
         LTR   R15,R15                 Is it zero                       01270000
         BZ    STAT010                 Yes, this is first keep size     01280000
         CR    R0,R15                  Is this smallest record seen     01290000
         BNL   STAT015                 No, skip save                    01300000
STAT010  DS    0H                                                       01310000
         ST    R0,W#RECLO(R1)          Save smallest record seen        01320000
STAT015  DS    0H                                                       01330000
         L     R15,W#RECHI(R1)         Current largest record           01340000
         CR    R0,R15                  Is this largest record seen      01350000
         BNH   STAT020                 No, skip save                    01360000
         ST    R0,W#RECHI(R1)                                           01370000
STAT020  DS    0H                      Save largest record seen         01380000
* Size of records                                                       01390000
         A     R0,W#FILSIZ(R1)         Add to sum of all types records  01400000
         ST    R0,W#FILSIZ(R1)         Save new size                    01410000
* Low and High Date/Time                                                01420000
         CLC   W#TOTLOD,SMFDTE         Lowest date seen                 01430000
         BH    GOTLO                   No, skip                         01440000
         BL    NOTLO                   Yes, save date                   01450000
         CLC   W#TOTLOT,SMFTME         Lowest time for equal date       01460000
         BL    NOTLO                   No, skip                         01470000
GOTLO    DS    0H                                                       01480000
         MVC   W#TOTLOD,SMFDTE         Save lowest date                 01490000
         MVC   W#TOTLOT,SMFTME         Save lowest time                 01500000
NOTLO    DS    0H                                                       01510000
         CLC   W#TOTHID,SMFDTE         Highest date seen                01520000
         BL    GOTHI                   No, skip                         01530000
         BH    NOTHI                   Yes, save date                   01540000
         CLC   W#TOTHIT,SMFTME         highest time for equal date      01550000
         BH    NOTHI                   No, skip                         01560000
GOTHI    DS    0H                                                       01570000
         MVC   W#TOTHID,SMFDTE         Save highest date                01580000
         MVC   W#TOTHIT,SMFTME         Save highest time                01590000
NOTHI    DS    0H                                                       01600000
* Select records                                                        01610000
         SR    R1,R1                   Get SMF                          01620000
         IC    R1,SMFRTY                record type                     01630000
         LA    R1,W#SMFREC(R1)         Index into selected type array   01640000
         CLI   0(R1),0                 Is this record type selected     01650000
         BE    PROC                    No, off to next record           01660000
* Count selected records                                                01670000
         SR    R1,R1                   Get SMF                          01680000
         IC    R1,SMFRTY                record type                     01690000
         SLL   R1,2                    Index into record out counters   01700000
         L     R0,W#RECOUT(R1)         Get current count                01710000
         AH    R0,=H'1'                Add to it                        01720000
         ST    R0,W#RECOUT(R1)         Save updated record count        01730000
         PUT   W#SODCB,SMFRCD          Put this record                  01740001
         TM    W#FLG,W#FLGDMP          DUMP requested                   01750001
         BNO   PROC                    No, done                         01760001
         MVC   W#LINE+1(14),=C'SMF xxx record'                          01770001
         SR    R0,R0                   Get SMF                          01780001
         IC    R0,SMFRTY                record type                     01790001
         CVD   R0,W#DWORD              Convert to packed                01800001
         OI    W#DWORD+7,15            Set sign                         01810001
         UNPK  W#DWORD(3),W#DWORD+6(2) Unpack SMF record number         01820001
         MVC   W#LINE+5(3),W#DWORD     Move to print                    01830001
         TM    SMFFLG,SMFFLGSU         Record have sub types            01840001
         BNO   ENDSUBTY                No, skip that                    01850001
         LH    R0,SMFSTP               Get sub type                     01860001
         CVD   R0,W#DWORD              Convert to packed                01870001
         MVC   W#LINE+23(6),=X'402020202120'                            01880001
         ED    W#LINE+23(6),W#DWORD+5  Edit 5 digit sub type            01890001
SUBTYCK  DS    0H                                                       01900001
         CLI   W#LINE+25,C' '          Non-zero digit                   01910001
         BNE   SUBTYMV                 Yes                              01920001
         MVC   W#LINE+25(4),W#LINE+26  Shift left                       01930001
         B     SUBTYCK                 Check again                      01940001
SUBTYMV  DS    0H                                                       01950001
         MVC   W#LINE+16(8),=C'Sub type'                                01960001
ENDSUBTY DS    0H                                                       01970001
         ICM   R1,15,SMFDTE            SMF date                         01980001
         BAL   R14,FDATE                                                01990001
         MVC   W#LINE+30(4),=C'Date'                                    02000001
         MVC   W#LINE+35(10),W#FMTDTE                                   02010001
         ICM   R1,15,SMFTME            SMF time                         02020001
         BAL   R14,FTIME                                                02030001
         MVC   W#LINE+46(4),=C'Time'                                    02040001
         MVC   W#LINE+50(L'W#FMTTME),W#FMTTME                           02050001
         MVC   W#LINE+63(13),=C'Record number'                          02060001
         MVC   W#LINE+76(10),=X'40206B2020206B202120'                   02070001
         ED    W#LINE+76(10),W#RECCT                                    02080001
         MVC   W#LINE+98(10),=C'System id='                             02090001
         MVC   W#LINE+108(4),SMFSID                                     02100001
         BAL   R14,PRT                 Print a line                     02110001
         LH    R0,SMFLEN                                                02120001
         LA    R1,SMFRCD                                                02130001
         BAL   R14,DMP                                                  02140001
         BAL   R14,PRT                 Print a line                     02150001
         B     PROC                    Handle next record               02160000
*********************************************************************** 02170000
*        End of input SMF file                                        * 02180000
*********************************************************************** 02190000
SMFEOF   DS    0H                                                       02200000
         CLOSE (W#SIDCB,,W#SODCB),MF=(E,W#OPNLST)                       02210000
*********************************************************************** 02220000
*        Summarize                                                    * 02230000
*********************************************************************** 02240000
         ZAP   W#SELREC,=P'+0'         Zero selected records count      02250000
         MVI   W#LINE,C'1'             New page                         02260000
         CLC   W#TOTLOD,=X'FFFFFFFF'   We process any record            02270000
         BE    EOFNONE                 No, skip high/low dates          02280000
         MVC   W#LINE+1(10),=C'Date range'                              02290000
         L     R1,W#TOTLOD             Lowest date seen                 02300000
         BAL   R14,FDATE               Format it                        02310000
         MVC   W#LINE+12(10),W#FMTDTE  Lowest date to print             02320000
         L     R1,W#TOTLOT             Lowest time seen                 02330000
         BAL   R14,FTIME               Format it                        02340000
         MVC   W#LINE+23(8),W#FMTTME+1 Lowest time to print             02350000
         OC    W#LINE+23(8),=C'00:00:00'                                02360000
         MVC   W#LINE+32(2),=C'to'                                      02370000
         L     R1,W#TOTHID             Highest date seen                02380000
         BAL   R14,FDATE               Format it                        02390000
         MVC   W#LINE+35(10),W#FMTDTE  Highest date to print            02400000
         L     R1,W#TOTHIT             Highest time seen                02410000
         BAL   R14,FTIME               Format it                        02420000
         MVC   W#LINE+46(8),W#FMTTME+1 Highest time to print            02430000
         OC    W#LINE+46(8),=C'00:00:00'                                02440000
         BAL   R14,PRT                 Print a line                     02450000
*                                                                       02460000
EOFNONE  DS    0H                                                       02470000
         MVC   W#LINE+1(10),=C'SMF Record'                              02480000
         MVC   W#LINE+31(4),=C'Read'                                    02490000
         MVC   W#LINE+37(8),=C'Selected'                                02500000
         MVC   W#LINE+47(8),=C'Smallest'                                02510000
         MVC   W#LINE+56(7),=C'Largest'                                 02520000
         MVC   W#LINE+68(4),=C'Size'                                    02530000
         MVI   W#LINE+78,C'%'                                           02540000
         MVC   W#LINE+80(11),=C'Description'                            02550000
         BAL   R14,PRT                 Print a line                     02560000
*        Get total file size                                            02570000
         SR    R2,R2                   Clear index into array           02580000
         SR    R3,R3                   Clear file size                  02590000
         LA    R0,256                  Number of SMF record types       02600000
TOTS010  DS    0H                                                       02610000
         A     R3,W#FILSIZ(R2)         Add to total size                02620000
         LA    R2,4(,R2)               Next record size slot            02630000
         BCT   R0,TOTS010              Loop through all counters        02640000
*                                                                       02650000
         SR    R2,R2                   Index into arrays                02660000
         MVC   W#MINREC,=X'7FFFFFFF'   Prime minimum seen               02670000
TOTS020  DS    0H                                                       02680000
         L     R0,W#RECIN(R2)          Get types record count           02690000
         LTR   R0,R0                   If zero                          02700000
         BZ    TOTS100                 Skip formatting                  02710000
         CVD   R0,W#DWORD              Convert to packed                02720000
         MVC   W#LINE+25(10),=X'40206B2020206B202120'                   02730000
         ED    W#LINE+25(10),W#DWORD+4 Edit records read                02740000
         L     R0,W#RECOUT(R2)         Get records selected to output   02750000
         CVD   R0,W#DWORD              Convert to packed                02760000
         AP    W#SELREC,W#DWORD        Add to total selected            02770000
         MVC   W#LINE+35(10),=X'40206B2020206B202120'                   02780000
         ED    W#LINE+35(10),W#DWORD+4 Edit records written             02790000
         L     R0,W#RECLO(R2)          Get smallest record this type    02800000
         C     R0,W#MINREC             Smallest record size seen        02810000
         BNL   TOTS030                 No, skip                         02820000
         ST    R0,W#MINREC             Save smallest seen so far        02830000
TOTS030  DS    0H                                                       02840000
         CVD   R0,W#DWORD              Convert to packed                02850000
         MVC   W#LINE+48(7),=X'4020206B202120'                          02860000
         ED    W#LINE+48(7),W#DWORD+5  Edit smallest record seen        02870000
         L     R0,W#RECHI(R2)          Get largest record this type     02880000
         C     R0,W#MAXREC             Largest record size seen         02890000
         BNH   TOTS040                 No, skip                         02900000
         ST    R0,W#MAXREC             Save largest seen so far         02910000
TOTS040  DS    0H                                                       02920000
         CVD   R0,W#DWORD              Convert to packed                02930000
         MVC   W#LINE+56(7),=X'4020206B202120'                          02940000
         ED    W#LINE+56(7),W#DWORD+5  Edit largest record seen         02950000
         L     R1,W#FILSIZ(R2)         Get total size of this type      02960000
         BAL   R14,SCLNUM              Format in a scaled format        02970000
         MVC   W#LINE+63(9),W#EDTNUM   Move size to print               02980000
         L     R1,W#FILSIZ(R2)         Get total size of this type      02990000
         M     R0,=A(1000)             Shift 3 decimal places           03000000
         LTR   R3,R3                   Total size zero                  03010000
         BZ    TOTS050                 Yes result is zero               03020000
         DR    R0,R3                   Get percent of total file        03030000
TOTS050  DS    0H                                                       03040000
         MVC   W#LINE+73(7),=X'40202021204B20'                          03050000
         CVD   R1,W#DWORD              Convert to packed                03060000
         ED    W#LINE+73(7),W#DWORD+5  Edit percent ot total file       03070000
         MVC   W#LINE+73(7),W#LINE+74  Shift left 1 position            03080000
         LR    R15,R2                  Get SMF record index             03090000
         SRL   R15,2                   Convert to SMF record ttype      03100000
         CVD   R15,W#DWORD             Convert to packed                03110000
         MVC   W#LINE+4(4),=X'40202120'                                 03120000
         ED    W#LINE+4(4),W#DWORD+6   Edit SMF record type             03130000
         LA    R1,SMFDESC              SMF record description table     03140000
TOTS060  DS    0H                                                       03150000
         ICM   R0,15,0(R1)             Get table SMF record type        03160000
         BM    TOTS080                 End of table                     03170000
         CR    R15,R0                  Find SMF type in table           03180000
         BNE   TOTS070                 No                               03190000
         LM    R14,R15,4(R1)           Get length and addr of desc      03200000
         BCTR  R14,0                   Make machine length              03210000
         EX    R14,SMFDSMVC            Move desc to print               03220000
         B     TOTS090                 Description found                03230000
TOTS070  DS    0H                                                       03240000
         LA    R1,12(,R1)              Next SMF description entry       03250000
         B     TOTS060                 Scan through table               03260000
TOTS080  DS    0H                                                       03270000
         MVC   W#LINE+80(17),=C'Vendor SMF Record'                      03280000
TOTS090  DS    0H                                                       03290000
         BAL   R14,PRT                 Print a line                     03300000
TOTS100  DS    0H                                                       03310000
         LA    R2,4(,R2)               Next SMF record type             03320000
         CH    R2,=AL2(4*256)          End of SMF record types          03330000
         BL    TOTS020                 No, continue reporting           03340001
         MVC   W#LINE+5(6),=C'Totals'                                   03350000
         MVC   W#LINE+25(10),=X'40206B2020206B202120'                   03360000
         ED    W#LINE+25(10),W#RECCT   Edit total records read          03370000
         MVC   W#LINE+35(10),=X'40206B2020206B202120'                   03380000
         ED    W#LINE+35(10),W#SELREC  Edit total records written       03390000
         L     R0,W#MINREC             Get smallest record seen         03400000
         CLC   W#MINREC,=X'FFFFFFFF'   Any records read                 03410000
         BNE   TOTS110                 Yes                              03420000
         SR    R0,R0                   Use zero                         03430000
TOTS110  DS    0H                                                       03440000
         CVD   R0,W#DWORD              Convert to packed                03450000
         MVC   W#LINE+48(7),=X'4020206B202120'                          03460000
         ED    W#LINE+48(7),W#DWORD+5  Edit smallest record             03470000
         L     R0,W#MAXREC             Get largest record seen          03480000
         CVD   R0,W#DWORD              Convert to packed                03490000
         MVC   W#LINE+56(7),=X'4020206B202120'                          03500000
         ED    W#LINE+56(7),W#DWORD+5  Edit largest record              03510000
         LR    R1,R3                   Get total size of file           03520000
         BAL   R14,SCLNUM              Format in a scaled format        03530000
         MVC   W#LINE+63(9),W#EDTNUM   Move largest to print            03540000
         BAL   R14,PRT                 Print a line                     03550000
         BAL   R14,PRT                 Print a line                     03560000
         LA    R15,0                   Return code zero                 03570000
EXIT     DS    0H                                                       03580000
         LR    R2,R15                  Save return code                 03590000
         CVD   R2,W#DWORD              Convert to packed                03600000
         MVC   W#LINE+11(6),=X'402020202120'                            03610000
         ED    W#LINE+11(6),W#DWORD+5  Edit return code                 03620000
         MVC   W#LINE+1(11),=C'Return code'                             03630000
         BAL   R14,PRT                 Print a line                     03640000
         CLOSE (W#OTDCB,,W#INDCB),MF=(E,W#OPNLST)                       03650000
         LR    R1,R13                  Address of work area             03660000
         L     R13,4(,R13)             Restore callers R13              03670000
         L     R0,=A(W#LEN)            Work area length                 03680000
         FREEMAIN R,A=(1),LV=(0)       Free work area                   03690000
         L     R14,12(,R13)            Restore R14                      03700000
         LR    R15,R2                  Restore return code              03710000
         LM    R2,R12,28(R13)          Restore rest of registers        03720000
         BR    R14                     Exit                             03730000
QUIT     DS    0H                                                       03740000
         LA    R15,16                  Failed return code               03750000
         B     EXIT                    Go cleanup                       03760000
*********************************************************************** 03770000
*        Format date                                                  * 03780000
*********************************************************************** 03790000
FDATE    DS    0H                                                       03800000
         ST    R14,W#PDATE             Save return address              03810000
         MVC   W#FMTDTE,=CL10' '       Clear date                       03820000
         ST    R1,W#CURDTE             Save requested date              03830000
         ZAP   W#JLWK1,W#CURDTE+2(2) GET JULIAN DATE                    03840000
         ZAP   W#JLWK2,=P'+365'                                         03850000
         ZAP   W#JLWK13,=P'+1'         Prime work                       03860000
         ZAP   W#JLWK12,=P'+31'        Prime Dec                        03870000
         ZAP   W#JLWK11,=P'+30'        Prime Nov                        03880000
         ZAP   W#JLWK10,=P'+31'        Prime Oct                        03890000
         ZAP   W#JLWK09,=P'+30'        Prime Sep                        03900000
         ZAP   W#JLWK08,=P'+31'        Prime Aug                        03910000
         ZAP   W#JLWK07,=P'+31'        Prime Jul                        03920000
         ZAP   W#JLWK06,=P'+30'        Prime Jun                        03930000
         ZAP   W#JLWK05,=P'+31'        Prime May                        03940000
         ZAP   W#JLWK04,=P'+30'        Prime Apr                        03950000
         ZAP   W#JLWK03,=P'+31'        Prime Mar                        03960000
         ZAP   W#JLWK02,=P'+28'        Prime Feb                        03970000
         ZAP   W#JLWK01,=P'+31'        Prime Jan                        03980000
         MVO   W#DWORD,W#CURDTE+1(1)   Shift left for sign              03990000
         OI    W#DWORD+7,X'0F'         Sign year                        04000000
         DP    W#DWORD,=P'+4'          Divide by 4                      04010000
         CP    W#DWORD+7(1),=P'+0'     Is it a leap year                04020000
         BNZ   FDDATE2                 no                               04030000
         ZAP   W#JLWK2,=P'+366'        Days/leap year = 366             04040000
         ZAP   W#JLWK02,=P'+29'        Feb = 29                         04050000
FDDATE2  DS    0H                                                       04060000
         LA    R1,W#JLWK01             Point to Jan                     04070000
         LA    R2,1                    First month                      04080000
FDDATE4  DS    0H                                                       04090000
         SP    W#JLWK1,0(2,R1)         Months displacement              04100000
         BNP   FDDATE6                 We have proper month/day         04110000
         AH    R1,=H'-2'               Next month                       04120000
         AH    R2,=H'+1'               Next month                       04130000
         B     FDDATE4                 Continue                         04140000
FDDATE6  DS    0H                                                       04150000
         AP    W#JLWK1,0(2,R1)         Add days of month                04160000
         CVD   R2,W#DWORD              Get month                        04170000
         OI    W#DWORD+7,X'0F'         Set display sign                 04180000
         UNPK  W#DWORD(3),W#DWORD+6(2) Unpack month                     04190000
         MVC   W#FMTDTE+0(2),W#DWORD+1 Move month                       04200000
         MVI   W#FMTDTE+2,C'/'                                          04210000
         OI    W#JLWK1+3,X'0F'         Set display sign                 04220000
         UNPK  W#DWORD(3),W#JLWK1      Unpack days                      04230000
         MVC   W#FMTDTE+3(2),W#DWORD+1 Move days                        04240000
         MVI   W#FMTDTE+5,C'/'                                          04250000
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     04260000
         MVC   W#FMTDTE+8(2),W#DWORD   Move year                        04270000
         MVC   W#FMTDTE+6(2),=C'20'    Fake 20xxx                       04280000
FDDATEX  DS    0H                                                       04290000
         L     R14,W#PDATE             Restore return address           04300000
         BR    R14                     Exit                             04310000
*********************************************************************** 04320000
*        Format time                                                  * 04330000
*********************************************************************** 04340000
FTIME    DS    0H                                                       04350000
         ST    R14,W#PTIME             Save return address              04360000
         MVC   W#FMTTME,=CL12' '       Clear formatted time             04370000
         LTR   R1,R1                   Is ime zero                      04380000
         BZ    FTMEEX                  Yes, leave it blank              04390000
         SLR   R0,R0                   Zero for divide                  04400000
         D     R0,=F'+6000'            Get seconds 10ths and 100th      04410000
         LR    R15,R0                  Save seconds 10ths and 100th     04420000
         SLR   R0,R0                   Clear remainder                  04430000
         D     R0,=F'+60'              Get minutes                      04440000
         MH    R0,=H'+10000'           Shift minutes to MM0000          04450000
         ALR   R15,R0                  Add in seconds 10ths and 100th   04460000
         CH    R1,=H'24'               Time greater than 1 day          04470000
         BL    FTMEHRS                 No, use HH:MM:SS.TH format       04480000
         SLR   R14,R14                 Zero for divide                  04490000
         D     R14,=F'+100'            Drop tenths and 100ths of sec    04500000
         SLR   R0,R0                   Zero for divide                  04510000
         D     R0,=F'+24'              Convert hours to days            04520000
         MH    R1,=H'+100'             Shift days                       04530000
         AR    R1,R0                   Add DD00 to HH                   04540000
         M     R0,=F'+10000'           Shift days and hours             04550000
         ALR   R15,R1                  Add days / hrs for DD HH:MM.SS   04560000
         CVD   R15,W#DWORD             Convert time to decimal          04570000
         MVC   W#FMTTME,=C'************'                                04580000
         B     FTMEEX                  Exit                             04590000
FTMEHRS  DS    0H                                                       04600000
         M     R0,=F'+1000000'         Shift hours to HH000000          04610000
         ALR   R15,R1                  Add hours to get HH:MM:SS.TH     04620000
         CVD   R15,W#DWORD             Convert time to decimal          04630000
         UNPK  W#TMPTME,W#DWORD+3(5)                                    04640000
         OI    W#TMPTME+L'W#TMPTME-1,C'0'                               04650000
         MVI   W#FMTTME+0,C' '                                          04660000
         MVC   W#FMTTME+1(2),W#TMPTME+1                                 04670000
         MVI   W#FMTTME+3,C':'                                          04680000
         MVC   W#FMTTME+4(2),W#TMPTME+3                                 04690000
         MVI   W#FMTTME+6,C':'                                          04700000
         MVC   W#FMTTME+7(2),W#TMPTME+5                                 04710000
         MVI   W#FMTTME+9,C'.'                                          04720000
         MVC   W#FMTTME+10(2),W#TMPTME+7                                04730000
FTMEEX   DS    0H                                                       04740000
         L     R14,W#PTIME             Restore return address           04750000
         BR    R14                     Exit                             04760000
*********************************************************************** 04770000
* Scale and format number                                             * 04780000
*********************************************************************** 04790000
SCLNUM   DS    0H                                                       04800000
         ST    R14,W#SCLR14            Save return address              04810000
         LA    R14,1024                1K                               04820000
         CR    R1,R14                  Is number less than 1K           04830000
         BH    SCKNUM10                No, scale value                  04840000
         MVC   W#EDTNUM(9),=X'40404020206B202120'                       04850000
         CVD   R1,W#DWORD              Convert to packed                04860000
         ED    W#EDTNUM(9),W#DWORD+5   Edit number                      04870000
         B     SCKNUM40                Exit                             04880000
SCKNUM10 DS    0H                                                       04890000
         MVI   W#SCALE,C'K'            Set scale                        04900000
         LR    R15,R1                  Save original value              04910000
         SR    R0,R0                   Clear high half                  04920000
         DR    R0,R14                  Convert bytes to K               04930000
         CR    R1,R14                  Is number larger than 1 Meg      04940000
         BL    SCKNUM20                No, edit number                  04950000
         MVI   W#SCALE,C'M'            Set scale                        04960000
         LR    R15,R1                  Save original value              04970000
         SR    R0,R0                   Clear high half                  04980000
         DR    R0,R14                  Convert K to M                   04990000
         CR    R1,R14                  Is number larger than 1 Gig      05000000
         BL    SCKNUM20                No, edit number                  05010000
         MVI   W#SCALE,C'G'            Set scale                        05020000
         LR    R15,R1                  Save original value              05030000
         SR    R0,R0                   Clear high half                  05040000
         DR    R0,R14                  Convert M to G                   05050000
SCKNUM20 DS    0H                                                       05060000
         LR    R1,R15                  Get current number               05070000
         MH    R1,=H'10'               Times 10 for 1 dec point         05080000
         SR    R0,R0                                                    05090000
         DR    R0,R14                  Scale again                      05100000
         MVC   W#EDTNUM,=X'40206B2021204B20' Edit mask                  05110000
SCKNUM30 DS    0H                                                       05120000
         CVD   R1,W#DWORD              Convert to packed                05130000
         ED    W#EDTNUM,W#DWORD+5      Edit number                      05140000
SCKNUM40 DS    0H                                                       05150000
         L     R14,W#SCLR14            Restore return address           05160000
         BR    R14                     Exit                             05170000
*********************************************************************** 05180000
*                                                                     * 05190000
*            INITIALIZATION                                           * 05200000
*                                                                     * 05210000
*********************************************************************** 05220000
INIT     DS    0H                                                       05230000
         ST    R14,W#INIT14            Save linkage                     05240000
         MVI   W#SMFREC,X'FF'                                           05250000
         MVC   W#SMFREC+1(L'W#SMFREC-1),W#SMFREC                        05260000
         ZAP   W#RECCT,=P'0'                                            05270000
         MVC   W#TOTLOD,=X'FFFFFFFF'                                    05280000
         MVC   W#TOTLOT,=X'FFFFFFFF'                                    05290000
         MVC   W#MINREC,=X'FFFFFFFF'                                    05300000
         MVC   W#OPNLST,P#OPNLST       Prime OPEN list                  05310000
         MVC   W#INDCB,P#INDCB         Prime DCB                        05320000
         MVC   W#OTDCB,P#OTDCB         Prime DCB                        05330000
         MVC   W#SIDCB,P#SIDCB         Prime DCB                        05340000
         MVC   W#SODCB,P#SODCB         Prime DCB                        05350000
         MVI   W#LINE,C' '             Clear print line                 05360000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              05370000
         MVC   W#HD1,W#LINE            Clear heading 1                  05380000
         MVI   W#HD1,C'1'              Prime heading 1                  05390000
         MVC   W#HD1TTL,=C'S M F   D U M P'                             05400000
         MVC   W#HD1PG,=C'Page'                                         05410000
         ZAP   W#LNCT,=P'+99'                                           05420000
         ZAP   W#PGCT,=P'+0'                                            05430000
         OPEN  (W#OTDCB,(OUTPUT),W#INDCB,(INPUT)),MF=(E,W#OPNLST)       05440000
         TM    W#OTDCB+DCBOFLGS-IHADCB,DCBOFOPN OPEN successful?        05450000
         BNO   INITER                  No, error                        05460000
         TM    W#INDCB+DCBOFLGS-IHADCB,DCBOFOPN OPEN successful?        05470000
         BNO   INITER                  No, error                        05480000
         ZAP   W#JLWK13,=P'+1'         Prime work                       05490000
         ZAP   W#JLWK12,=P'+31'        Prime Dec                        05500000
         ZAP   W#JLWK11,=P'+30'        Prime Nov                        05510000
         ZAP   W#JLWK10,=P'+31'        Prime Oct                        05520000
         ZAP   W#JLWK09,=P'+30'        Prime Sep                        05530000
         ZAP   W#JLWK08,=P'+31'        Prime Aug                        05540000
         ZAP   W#JLWK07,=P'+31'        Prime Jul                        05550000
         ZAP   W#JLWK06,=P'+30'        Prime Jun                        05560000
         ZAP   W#JLWK05,=P'+31'        Prime May                        05570000
         ZAP   W#JLWK04,=P'+30'        Prime Apr                        05580000
         ZAP   W#JLWK03,=P'+31'        Prime Mar                        05590000
         ZAP   W#JLWK02,=P'+28'        Prime Feb                        05600000
         ZAP   W#JLWK01,=P'+31'        Prime Jan                        05610000
         TIME  BIN                     Get current date and time        05620000
         ST    R1,W#CURDTE             Save date                        05630000
         SRDL  R0,32                   Get double word time             05640000
         D     R0,=F'+6000'            Get minutes                      05650000
         LR    R15,R0                  Save secs tens and hundreths     05660000
         SLR   R0,R0                   Clear                            05670000
         D     R0,=F'+60'              Get hours / mins                 05680000
         MH    R0,=H'+10000'           Get minutes                      05690000
         AR    R15,R0                  Add to get MM:SS.TH              05700000
         M     R0,=F'+1000000'         Get hours                        05710000
         AR    R1,R15                  Get HH:MM:SS.TH                  05720000
         CVD   R1,W#DWORD              Get time to decimal              05730000
         MVC   W#TIMWRK,=X'402021204B20204B20204B2020'                  05740000
         ED    W#TIMWRK,W#DWORD+3      Edit time                        05750000
         MVC   W#HD1TOD(8),W#TIMWRK+2  Move time                        05760000
         ZAP   W#JLWK1,W#CURDTE+2(2)   Get julian date                  05770000
         ZAP   W#JLWK2,=P'+365'        Days/yr = 365                    05780000
         ZAP   W#JLWK02,=P'+28'        Feb = 28                         05790000
         MVO   W#DWORD,W#CURDTE+1(1)   Sign year                        05800000
         DP    W#DWORD,=P'+4'          Divide by 4                      05810000
         CP    W#DWORD+7(1),=P'+0'     Is it a leap year?               05820000
         BNZ   JULCVT2                 No                               05830000
         ZAP   W#JLWK2,=P'+366'        Days/yr = 366                    05840000
         ZAP   W#JLWK02,=P'+29'        Feb = 29                         05850000
JULCVT2  DS    0H                                                       05860000
         LA    R1,W#JLWK01             Point to Jan                     05870000
         SLR   R2,R2                   Set counter                      05880000
JULCVT4  DS    0H                                                       05890000
         SP    W#JLWK1,0(2,R1)         Months displacement              05900000
         BNP   JULCVT6                 If equal or less                 05910000
         AH    R1,=H'-2'               Point to next month              05920000
         AH    R2,=H'+3'               Up index                         05930000
         B     JULCVT4                 Loop                             05940000
JULCVT6  DS    0H                                                       05950000
         AP    W#JLWK1,0(2,R1)         Add days of month                05960000
         LA    R2,P#JULTBL(R2)         Address month                    05970000
         MVC   W#HD1DTE(3),0(R2)       Move month                       05980000
         OI    W#JLWK1+3,X'0F'         Display sign                     05990000
         UNPK  W#HD1DTE+4(2),W#JLWK1   Get days                         06000000
         CLI   W#HD1DTE+4,C'0'         First 9 days?                    06010000
         LA    R1,W#HD1DTE+6           Set pointer                      06020000
         BNE   JULCVT7                 No                               06030000
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 Move units digit                06040000
         BCTR  R1,0                    Drop pointer                     06050000
JULCVT7  DS    0H                                                       06060000
         MVC   0(4,R1),=C', 19'        Set up constant                  06070000
         TM    W#CURDTE,1              Year 2000?                       06080000
         BNO   JULCVT8                 No, continue                     06090000
         MVC   2(2,R1),=C'20'          Year 2000                        06100000
JULCVT8  DS    0H                                                       06110000
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     06120000
         MVC   4(2,R1),W#DWORD         Get year                         06130000
*                                                                       06140000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            06150000
         MVC   W#LINE+9(L'PGMID),PGMID Move version                     06160000
         BAL   R14,PRT                 Print a line                     06170000
*                                                                       06180000
         LR    R3,R4                   Parm address                     06190001
         MVC   W#LINE+1(5),=C'PARM='   Move parameter info literal      06200000
         CLI   1(R3),0                 Any parameter?                   06210000
         BE    PRMPRT                  No, skip move                    06220000
         LH    R1,0(,R3)               Get parmeter length              06230000
         BCTR  R1,0                    Make machine length              06240000
         EX    R1,PRMMVC               Move parm to print line          06250000
         B     PRMPRT                  Skip move                        06260000
PRMMVC   MVC   W#LINE+6(0),2(R3)       Executed parm move               06270000
PRMPRT   DS    0H                                                       06280000
         BAL   R14,PRT                 Print a line                     06290000
         LH    R2,0(,R3)               Get PARM length                  06300000
         AH    R3,=H'+2'               Skip length                      06310000
         ST    R3,W#PRMBGN             Save PARM start                  06320000
PRMSCN   DS    0H                                                       06330000
         LTR   R2,R2                   End of PARM?                     06340000
         BZ    PRMEND                  Yes, PARM parsed                 06350000
         CLI   0(R3),C','              Seperator?                       06360000
         BNE   PRMCHK                  No, check values                 06370000
         AH    R3,=H'+1'               Skip comma                       06380000
         SH    R2,=H'+1'               Decrement length                 06390000
         B     PRMSCN                  Continue scan                    06400000
PRMCHK   DS    0H                                                       06410000
         CH    R2,=H'+4'               Long enough?                     06420001
         BL    PRMERR                  No, error                        06430001
         CLC   =C'DUMP',0(R3)          DUMP?                            06440001
         BE    PRMDMP                  Yes, handle it                   06450001
         CH    R2,=H'+5'               Long enough?                     06460000
         BL    PRMERR                  No, error                        06470000
         CLC   =C'DEBUG',0(R3)         DEBUG?                           06480000
         BE    PRMDBG                  Yes, handle it                   06490000
         B     PRMERR                  Error                            06500000
PRMDMP   DS    0H                                                       06510001
         OI    W#FLG,W#FLGDMP          Set DUMP                         06520001
         AH    R3,=H'+4'               Skip value                       06530001
         SH    R2,=H'+4'               Decrement length                 06540001
         B     PRMSCNC                 Continue scan                    06550001
PRMDBG   DS    0H                                                       06560001
         OI    W#FLG,W#FLGDBG          Set DEBUG                        06570001
         AH    R3,=H'+5'               Skip value                       06580001
         SH    R2,=H'+5'               Decrement length                 06590001
         B     PRMSCNC                 Continue scan                    06600000
PRMSCNC  DS    0H                                                       06610000
         LTR   R2,R2                   End of PARM?                     06620000
         BZ    PRMEND                  Yes, PARM parsed                 06630000
         CLI   0(R3),C','              Delimiter?                       06640000
         BE    PRMSCN                  Yes, handle it                   06650000
PRMERR   DS    0H                                                       06660000
         LR    R1,R3                   Current position                 06670000
         S     R1,W#PRMBGN             Less start                       06680000
         LA    R1,W#LINE+6(R1)         Set location of error            06690000
         MVI   0(R1),C'*'              Mark where error is              06700000
         BAL   R14,PRT                 Print a line                     06710000
         MVC   W#LINE(19),=C' Parameters invalid'                       06720000
         BAL   R14,PRT                 Print a line                     06730000
         B     INITER                  Error                            06740000
PRMEND   DS    0H                                                       06750000
         BAL   R14,PRT                 Print a line                     06760000
*********************************************************************** 06770000
*        INDD(SMF,OPTIONS(DUMP))                                      * 06780000
*        OUTDD(SMFDUMP,TYPE(N,N,N,N:N,N:N))                           * 06790000
*********************************************************************** 06800000
         MVC   W#LINE+1(18),=C'Control statements'                      06810000
         BAL   R14,PRT                 Print a line                     06820000
STMTIN   DS    0H                                                       06830000
         GET   W#INDCB,W#CARD                                           06840000
         MVC   W#LINE+1(L'W#CARD),W#CARD                                06850000
         BAL   R14,PRT                                                  06860000
         LA    R1,W#CARD                                                06870000
         LA    R0,L'W#CARD-8                                            06880000
         CLI   W#CARD,C'*'                                              06890000
         BE    STMTIN                                                   06900000
         CLI   W#CARD,C' '                                              06910000
         BNE   STMTER01                                                 06920000
STMT010  DS    0H                                                       06930000
         CLI   0(R1),C' '                                               06940000
         BNE   STMT020                                                  06950000
         LA    R1,1(,R1)                                                06960000
         BCT   R0,STMT010                                               06970000
         B     STMTER02                                                 06980000
STMT020  DS    0H                                                       06990000
         CLC   =C'INDD(',0(R1)                                          07000000
         BE    INDD010                                                  07010000
         CLC   =C'OUTDD(',0(R1)                                         07020000
         BE    OTDD010                                                  07030000
         B     STMTER03                                                 07040000
         BE    INDD010                                                  07050000
INDD010  DS    0H                                                       07060000
         LA    R1,5(,R1)                                                07070000
         SH    R0,=H'5'                                                 07080000
         BNP   STMTER04                                                 07090000
         LA    R15,W#SIDCB+DCBDDNAM-IHADCB                              07100000
         BAL   R14,PRSDD                                                07110000
         CLI   W#SIDCB+DCBDDNAM-IHADCB,C' '                             07120000
         BE    STMTER05                                                 07130000
         CLC   0(2,R1),=C') '                                           07140000
         BE    STMTIN                                                   07150000
         CLI   0(R1),C','                                               07160000
         BNE   STMTER06                                                 07170000
         LA    R1,1(,R1)                                                07180000
         SH    R0,=H'1'                                                 07190000
         BZ    STMTER07                                                 07200000
         CH    R0,=H'15'                                                07210000
         BL    STMTER08                                                 07220000
         CLC   =C'OPTIONS(DUMP)) ',0(R1)                                07230000
         BNE   STMTER09                                                 07240000
         B     STMTIN                                                   07250000
OTDD010  DS    0H                                                       07260000
         LA    R1,6(,R1)                                                07270000
         SH    R0,=H'6'                                                 07280000
         BNP   STMTER10                                                 07290000
         LA    R15,W#SODCB+DCBDDNAM-IHADCB                              07300000
         BAL   R14,PRSDD                                                07310000
         CLI   W#SODCB+DCBDDNAM-IHADCB,C' '                             07320000
         BE    STMTER11                                                 07330000
         CLC   0(2,R1),=C') '                                           07340000
         BE    STMTIN                                                   07350000
         CLI   0(R1),C','                                               07360000
         BNE   STMTER12                                                 07370000
         LA    R1,1(,R1)                                                07380000
         SH    R0,=H'1'                                                 07390000
         BZ    STMTER13                                                 07400000
         CH    R0,=H'5'                                                 07410000
         BL    STMTER14                                                 07420000
         CLC   =C'TYPE(',0(R1)                                          07430000
         BNE   STMTER15                                                 07440000
         OI    W#FLG,W#FLGSEL                                           07450000
         LA    R1,5(,R1)                                                07460000
         SH    R0,=H'5'                                                 07470000
         BL    STMTER16                                                 07480000
         XC    W#SMFREC,W#SMFREC                                        07490000
TYPE010  DS    0H                                                       07500000
         SR    R2,R2                                                    07510000
TYPE020  DS    0H                                                       07520000
         CLI   0(R1),C','                                               07530000
         BE    TYPE030                                                  07540000
         CLI   0(R1),C':'                                               07550000
         BE    TYPE030                                                  07560000
         CLI   0(R1),C')'                                               07570000
         BE    TYPE030                                                  07580000
         CLI   0(R1),C'0'                                               07590000
         BL    STMTER17                                                 07600000
         CLI   0(R1),C'9'                                               07610000
         BH    STMTER18                                                 07620000
         IC    R14,0(,R1)                                               07630000
         N     R14,=A(15)                                               07640000
         MH    R2,=H'10'                                                07650000
         AR    R2,R14                                                   07660000
         CH    R2,=H'255'                                               07670000
         BH    STMTER19                                                 07680000
         LA    R1,1(,R1)                                                07690000
         SH    R0,=H'1'                                                 07700000
         BCT   R0,TYPE020                                               07710000
         B     STMTER20                                                 07720000
TYPE030  DS    0H                                                       07730000
         LA    R2,W#SMFREC(R2)                                          07740000
         MVI   0(R2),X'FF'                                              07750000
         CLC   =C')) ',0(R1)                                            07760000
         BE    STMTIN                                                   07770000
         CLI   0(R1),C','                                               07780000
         BNE   TYPE035                                                  07790000
         LA    R1,1(,R1)                                                07800000
         SH    R0,=H'1'                                                 07810000
         BZ    STMTER32                                                 07820000
         B     TYPE010                                                  07830000
TYPE035  DS    0H                                                       07840000
         CLI   0(R1),C':'                                               07850000
         BNE   STMTER22                                                 07860000
         LA    R1,1(,R1)                                                07870000
         SH    R0,=H'1'                                                 07880000
         BZ    STMTER23                                                 07890000
         SR    R3,R3                                                    07900000
TYPE040  DS    0H                                                       07910000
         CLI   0(R1),C','                                               07920000
         BE    TYPE050                                                  07930000
         CLI   0(R1),C')'                                               07940000
         BE    TYPE050                                                  07950000
         CLI   0(R1),C'0'                                               07960000
         BL    STMTER24                                                 07970000
         CLI   0(R1),C'9'                                               07980000
         BH    STMTER25                                                 07990000
         IC    R14,0(,R1)                                               08000000
         N     R14,=A(15)                                               08010000
         MH    R3,=H'10'                                                08020000
         AR    R3,R14                                                   08030000
         CH    R3,=H'255'                                               08040000
         BH    STMTER26                                                 08050000
         LA    R1,1(,R1)                                                08060000
         BCT   R0,TYPE040                                               08070000
         B     STMTER27                                                 08080000
TYPE050  DS    0H                                                       08090000
         LA    R3,W#SMFREC(R3)                                          08100000
         LA    R2,1(,R2)                                                08110000
         CR    R3,R2                                                    08120000
         BL    STMTER28                                                 08130000
TYPE060  DS    0H                                                       08140000
         MVI   0(R2),X'FF'                                              08150000
         CR    R2,R3                                                    08160000
         BE    TYPE070                                                  08170000
         LA    R2,1(,R2)                                                08180000
         B     TYPE060                                                  08190000
TYPE070  DS    0H                                                       08200000
         CLC   =C')) ',0(R1)                                            08210000
         BE    STMTIN                                                   08220000
         LA    R1,1(,R1)                                                08230000
         BCT   R0,TYPE010                                               08240000
         B     STMTER33                                                 08250000
STMTER01 DS    0H                                                       08260000
         MVC   W#PRSERR,=C'01'                                          08270000
         B     STMTER                                                   08280000
STMTER02 DS    0H                                                       08290000
         MVC   W#PRSERR,=C'02'                                          08300000
         B     STMTER                                                   08310000
STMTER03 DS    0H                                                       08320000
         MVC   W#PRSERR,=C'03'                                          08330000
         B     STMTER                                                   08340000
STMTER04 DS    0H                                                       08350000
         MVC   W#PRSERR,=C'04'                                          08360000
         B     STMTER                                                   08370000
STMTER05 DS    0H                                                       08380000
         MVC   W#PRSERR,=C'05'                                          08390000
         B     STMTER                                                   08400000
STMTER06 DS    0H                                                       08410000
         MVC   W#PRSERR,=C'06'                                          08420000
         B     STMTER                                                   08430000
STMTER07 DS    0H                                                       08440000
         MVC   W#PRSERR,=C'07'                                          08450000
         B     STMTER                                                   08460000
STMTER08 DS    0H                                                       08470000
         MVC   W#PRSERR,=C'08'                                          08480000
         B     STMTER                                                   08490000
STMTER09 DS    0H                                                       08500000
         MVC   W#PRSERR,=C'09'                                          08510000
         B     STMTER                                                   08520000
STMTER10 DS    0H                                                       08530000
         MVC   W#PRSERR,=C'10'                                          08540000
         B     STMTER                                                   08550000
STMTER11 DS    0H                                                       08560000
         MVC   W#PRSERR,=C'11'                                          08570000
         B     STMTER                                                   08580000
STMTER12 DS    0H                                                       08590000
         MVC   W#PRSERR,=C'12'                                          08600000
         B     STMTER                                                   08610000
STMTER13 DS    0H                                                       08620000
         MVC   W#PRSERR,=C'13'                                          08630000
         B     STMTER                                                   08640000
STMTER14 DS    0H                                                       08650000
         MVC   W#PRSERR,=C'14'                                          08660000
         B     STMTER                                                   08670000
STMTER15 DS    0H                                                       08680000
         MVC   W#PRSERR,=C'15'                                          08690000
         B     STMTER                                                   08700000
STMTER16 DS    0H                                                       08710000
         MVC   W#PRSERR,=C'16'                                          08720000
         B     STMTER                                                   08730000
STMTER17 DS    0H                                                       08740000
         MVC   W#PRSERR,=C'17'                                          08750000
         B     STMTER                                                   08760000
STMTER18 DS    0H                                                       08770000
         MVC   W#PRSERR,=C'18'                                          08780000
         B     STMTER                                                   08790000
STMTER19 DS    0H                                                       08800000
         MVC   W#PRSERR,=C'19'                                          08810000
         B     STMTER                                                   08820000
STMTER20 DS    0H                                                       08830000
         MVC   W#PRSERR,=C'20'                                          08840000
         B     STMTER                                                   08850000
STMTER21 DS    0H                                                       08860000
         MVC   W#PRSERR,=C'21'                                          08870000
         B     STMTER                                                   08880000
STMTER22 DS    0H                                                       08890000
         MVC   W#PRSERR,=C'22'                                          08900000
         B     STMTER                                                   08910000
STMTER23 DS    0H                                                       08920000
         MVC   W#PRSERR,=C'23'                                          08930000
         B     STMTER                                                   08940000
STMTER24 DS    0H                                                       08950000
         MVC   W#PRSERR,=C'24'                                          08960000
         B     STMTER                                                   08970000
STMTER25 DS    0H                                                       08980000
         MVC   W#PRSERR,=C'25'                                          08990000
         B     STMTER                                                   09000000
STMTER26 DS    0H                                                       09010000
         MVC   W#PRSERR,=C'26'                                          09020000
         B     STMTER                                                   09030000
STMTER27 DS    0H                                                       09040000
         MVC   W#PRSERR,=C'27'                                          09050000
         B     STMTER                                                   09060000
STMTER28 DS    0H                                                       09070000
         MVC   W#PRSERR,=C'28'                                          09080000
         B     STMTER                                                   09090000
STMTER29 DS    0H                                                       09100000
         MVC   W#PRSERR,=C'29'                                          09110000
         B     STMTER                                                   09120000
STMTER30 DS    0H                                                       09130000
         MVC   W#PRSERR,=C'30'                                          09140000
         B     STMTER                                                   09150000
STMTER31 DS    0H                                                       09160000
         MVC   W#PRSERR,=C'31'                                          09170000
         B     STMTER                                                   09180000
STMTER32 DS    0H                                                       09190000
         MVC   W#PRSERR,=C'32'                                          09200000
         B     STMTER                                                   09210000
STMTER33 DS    0H                                                       09220000
         MVC   W#PRSERR,=C'33'                                          09230000
         B     STMTER                                                   09240000
STMTER   DS    0H                                                       09250000
         LA    R0,W#CARD                                                09260000
         SR    R1,R0                                                    09270000
         LA    R1,W#LINE+1(R1)                                          09280000
         MVC   0(27,R1),=C'* Invalid control statement'                 09290000
         TM    W#FLG,W#FLGDBG                                           09300000
         BNO   STMTERPR                                                 09310000
         MVI   28(R1),C'('                                              09320000
         MVC   29(2,R1),W#PRSERR                                        09330000
         MVI   31(R1),C')'                                              09340000
STMTERPR DS    0H                                                       09350000
         BAL   R14,PRT                                                  09360000
         B     INITER                                                   09370000
INEOF    DS    0H                                                       09380000
         MVC   W#LINE+1(22),=C'End control statements'                  09390000
         BAL   R14,PRT                 Print a line                     09400000
         BAL   R14,PRT                 Print a line                     09410000
         MVC   W#LINE+1(17),=C'Options in effect'                       09420000
         BAL   R14,PRT                 Print a line                     09430000
         MVC   W#LINE+2(13),=C'Input DDNAME='                           09440000
         MVC   W#LINE+15(8),W#SIDCB+DCBDDNAM-IHADCB                     09450000
         BAL   R14,PRT                 Print a line                     09460000
         MVC   W#LINE+2(14),=C'Output DDNAME='                          09470000
         MVC   W#LINE+16(8),W#SODCB+DCBDDNAM-IHADCB                     09480000
         BAL   R14,PRT                 Print a line                     09490000
         MVC   W#LINE+2(12),=C'SMF Records='                            09500000
         TM    W#FLG,W#FLGSEL                                           09510000
         BO    OPTSMF10                                                 09520000
         MVC   W#LINE+14(3),=C'All'                                     09530000
         B     OPTSMR50                                                 09540000
OPTSMF10 DS    0H                                                       09550000
         LA    R3,W#SMFREC                                              09560001
         ZAP   W#DWORD,=P'+0'                                           09570001
         LA    R4,W#LINE+14                                             09580000
OPTSMF20 DS    0H                                                       09590000
         CLI   0(R3),0                                                  09600000
         BE    OPTSMR40                                                 09610000
         LA    R0,W#LINE+L'W#LINE-10                                    09620000
         CR    R4,R0                                                    09630000
         BL    OPTSMR30                                                 09640000
         BAL   R14,PRT                 Print a line                     09650000
         LA    R4,W#LINE+14                                             09660000
OPTSMR30 DS    0H                                                       09670000
         MVC   W#WRKNUM,=X'40202120'                                    09680000
         ED    W#WRKNUM,W#DWORD+6                                       09690000
         MVC   0(4,R4),W#WRKNUM+1                                       09700000
         LA    R4,4(,R4)                                                09710000
OPTSMR40 DS    0H                                                       09720000
         LA    R3,1(,R3)                                                09730000
         AP    W#DWORD,=P'+1'                                           09740000
         CP    W#DWORD,=P'255'                                          09750000
         BNH   OPTSMF20                                                 09760000
OPTSMR50 DS    0H                                                       09770000
         CLI   W#LINE+16,C' '                                           09780000
         BE    OPTSMR60                                                 09790000
         BAL   R14,PRT                 Print a line                     09800000
OPTSMR60 DS    0H                                                       09810000
         MVC   W#LINE+1(14),=C'End of options'                          09820000
         BAL   R14,PRT                 Print a line                     09830000
         BAL   R14,PRT                 Print a line                     09840000
         OPEN  (W#SIDCB,(INPUT),W#SODCB,(OUTPUT)),MF=(E,W#OPNLST)       09850000
         TM    W#SIDCB+DCBOFLGS-IHADCB,DCBOFOPN OPEN successful?        09860000
         BNO   INITOPEI                No, error                        09870000
         TM    W#SODCB+DCBOFLGS-IHADCB,DCBOFOPN OPEN successful?        09880000
         BNO   INITOPEO                No, error                        09890000
         LA    R15,0                                                    09900000
         B     INITXT                                                   09910000
INITOPEI DS    0H                                                       09920000
         MVC   W#LINE+1(30),=C'SMF input data set OPEN failed'          09930000
         BAL   R14,PRT                 Print a line                     09940000
         B     INITER                                                   09950000
INITOPEO DS    0H                                                       09960000
         MVC   W#LINE+1(31),=C'SMF output data set OPEN failed'         09970000
         BAL   R14,PRT                 Print a line                     09980000
INITER   DS    0H                                                       09990000
         LA    R15,8                   Set error return code            10000000
INITXT   DS    0H                                                       10010000
         L     R14,W#INIT14            Get return address               10020000
         BR    R14                     Return to caller                 10030000
*********************************************************************** 10040000
*                                                                     * 10050000
*********************************************************************** 10060000
PRSDD    DS    0H                                                       10070000
         ST    R14,W#PRSD14                                             10080000
         CLI   0(R1),C','                                               10090000
         BE    PRSDD40                                                  10100000
         LA    R14,8                                                    10110000
         MVC   0(8,R15),=CL8' '                                         10120000
PRSDD10  DS    0H                                                       10130000
         CLI   0(R1),C','                                               10140000
         BE    PRSDD40                                                  10150000
         CLI   0(R1),C')'                                               10160000
         BE    PRSDD40                                                  10170000
         CLI   0(R1),C'#'                                               10180000
         BE    PRSDD30                                                  10190000
         CLI   0(R1),C'$'                                               10200000
         BE    PRSDD30                                                  10210000
         CLI   0(R1),C'@'                                               10220000
         BE    PRSDD30                                                  10230000
         CLI   0(R1),C'A'                                               10240000
         BL    STMTER30                                                 10250000
         CLI   0(R1),C'Z'                                               10260000
         BNH   PRSDD30                                                  10270000
PRSDD20  DS    0H                                                       10280000
         CLI   0(R1),C'0'                                               10290000
         BL    STMTER30                                                 10300000
         CLI   0(R1),C'9'                                               10310000
         BH    STMTER30                                                 10320000
PRSDD30  DS    0H                                                       10330000
         MVC   0(1,R15),0(R1)                                           10340000
         LA    R15,1(,R15)                                              10350000
         LA    R1,1(,R1)                                                10360000
         SH    R0,=H'1'                                                 10370000
         BZ    PRSDD40                                                  10380000
         SH    R14,=H'1'                                                10390000
         BNZ   PRSDD10                                                  10400000
PRSDD40  DS    0H                                                       10410000
         L     R14,W#PRSD14                                             10420000
         BR    R14                                                      10430000
*********************************************************************** 10440000
*                                                                     * 10450000
*            WRITE PRINT LINE                                         * 10460000
*                                                                     * 10470000
*********************************************************************** 10480000
PRT      DS    0H                                                       10490000
         ST    R14,W#PRTR14                                             10500000
         CP    W#LNCT,=P'+60'          End of page                      10510000
         BL    PRTCHK                  No, check if line fit in page    10520000
PRTHDRS  DS    0H                                                       10530000
         AP    W#PGCT,=P'+1'           Count pages                      10540000
         MVC   W#HD1PG#,=X'40202120'   Page count mask                  10550000
         ED    W#HD1PG#,W#PGCT         Edit page count                  10560000
         PUT   W#OTDCB,W#HD1           Print heading 1                  10570000
         ZAP   W#LNCT,=P'+1'           Init line count                  10580000
         MVI   W#LINE,C'0'             Skip after heading               10590000
PRTCHK   DS    0H                                                       10600000
         CLI   W#LINE,C'+'             Overprint?                       10610000
         BE    PRTLINE                 Yes, don't count                 10620000
         CLI   W#LINE,C'1'             New line?                        10630000
         BE    PRTHDRS                 Yes, print header                10640000
         CLI   W#LINE,C' '             Write after advancing 1?         10650000
         BE    PRTLINE1                Yes, go check if fit             10660000
         CLI   W#LINE,C'0'             Write after advancing 2?         10670000
         BE    PRTLINE2                Yes, go check if fit             10680000
         CLI   W#LINE,C'-'             Write after advancing 3?         10690000
         BE    PRTLINE3                Yes, go check if fit             10700000
         B     PRTLINE                 Ignore any other ctl chars       10710000
PRTLINE1 DS    0H                                                       10720000
         AP    W#LNCT,=P'+1'           Add to line count                10730000
         B     PRTVFY                  Go see if it will fit            10740000
PRTLINE2 DS    0H                                                       10750000
         AP    W#LNCT,=P'+2'           Add to line count                10760000
         B     PRTVFY                  Go see if it will fit            10770000
PRTLINE3 DS    0H                                                       10780000
         AP    W#LNCT,=P'+3'           Add to line count                10790000
PRTVFY   DS    0H                                                       10800000
         CP    W#LNCT,=P'+60'          Overflow?                        10810000
         BH    PRTHDRS                 Yes, force header                10820000
PRTLINE  DS    0H                                                       10830000
         PUT   W#OTDCB,W#LINE          Print a line                     10840000
         MVI   W#LINE,C' '             Clear print line                 10850000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              10860000
         L     R14,W#PRTR14                                             10870000
         BR    R14                     Return to caller                 10880000
*********************************************************************** 10890000
*                                                                     * 10900000
*        DUMP WITH ADDRESS OF STORAGE DUMPED                          * 10910000
*                                                                     * 10920000
*********************************************************************** 10930000
DMPAD    DS    0H                                                       10940000
         ST    R14,W#DMPADR                                             10950000
         STM   R0,R15,W#DMPRGS         Save registers                   10960000
         ST    R1,W#DMPOFF                                              10970000
         LA    R2,W#LINE+L'W#LINE-1                                     10980000
         LA    R0,L'W#LINE-1                                            10990000
DMPAD10  DS    0H                                                       11000000
         CLI   0(R2),C' '                                               11010000
         BNE   DMPAD20                                                  11020000
         BCTR  R2,0                                                     11030000
         BCT   R0,DMPAD10                                               11040000
DMPAD20  DS    0H                                                       11050000
         MVC   2(2,R2),=C'at'                                           11060000
         AH    R2,=H'+5'               Output area address              11070000
         LA    R1,W#DMPOFF             Address of offset to dump        11080000
         LA    R15,4                   Convert 4 bytes                  11090000
         BAL   R14,DMPDSP              Convert it to display            11100000
         BAL   R14,PRT                 Print address of data            11110000
         LM    R0,R15,W#DMPRGS         Save registers                   11120000
         BAL   R14,DMP                 Dump storage                     11130000
         L     R14,W#DMPADR                                             11140000
         BR    R14                     Return to caller                 11150000
*********************************************************************** 11160000
*                                                                     * 11170000
*        DUMP DATA                                                    * 11180000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 11190000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 11200000
*                                                                     * 11210000
*********************************************************************** 11220000
DMP      DS    0H                                                       11230000
         STM   R0,R15,W#DMPRGS         Save registers                   11240000
         LR    R3,R1                   Get address to dump              11250000
         LR    R4,R0                   Get length                       11260000
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump             11270000
         MVI   W#DMPFLG,W#DMP1ST       First line                       11280000
DMPDMPLP DS    0H                                                       11290000
         LTR   R4,R4                   Any data to dump?                11300000
         BZ    DMPHEXXT                Ye, all done                     11310000
         TM    W#DMPFLG,W#DMP1ST       First line?                      11320000
         BO    DMPALIN                 Yes, can't have same as above    11330000
         LA    R0,32                   Default length                   11340000
         CR    R4,R0                   Length longer than 32?           11350000
         BNH   DMPDUPCK                No, were at last line            11360000
         LR    R14,R3                  Get current input area           11370000
         SR    R14,R0                  Back to previous area            11380000
         CLC   0(32,R14),0(R3)         Duplicate of previous line       11390000
         BNE   DMPDUPCK                No, do lines same as             11400000
         SR    R4,R0                   Reduce length to do              11410000
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?           11420000
         BO    DMPNXTLN                Yes, we have first offset        11430000
         L     R14,W#DMPOFF            Get current offset               11440000
         ST    R14,W#DUP1ST            Save as first offset             11450000
         OI    W#DMPFLG,W#DMPDUP       Set duplicate                    11460000
         B     DMPNXTLN                Continue                         11470000
DMPDUPCK DS    0H                                                       11480000
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?           11490000
         BNO   DMPALIN                 No, no duplicate to report       11500000
         MVC   W#LINE+7(5),=C'lines'   Move literal                     11510000
         LA    R2,W#LINE+13            Output area address              11520000
         LA    R1,W#DUP1ST+2           Address of offset to dump        11530000
         LA    R15,2                   Convert 4 bytes                  11540000
         BAL   R14,DMPDSP              Convert it to display            11550000
         MVI   W#LINE+17,C'-'          Thru literal                     11560000
         L     R1,W#DMPOFF             Get current offset               11570000
         S     R1,=A(32)               Get last duplicate offset        11580000
         ST    R1,W#DUP1ST             Save for dumping                 11590000
         LA    R2,W#LINE+18            Output area address              11600000
         LA    R1,W#DUP1ST+2           Address of offset to dump        11610000
         LA    R15,2                   Convert 4 bytes                  11620000
         BAL   R14,DMPDSP              Convert it to display            11630000
         MVC   W#LINE+23(13),=C'same as above' move literal             11640000
         BAL   R14,PRT                 Print a line                     11650000
         NI    W#DMPFLG,255-W#DMPDUP   Reset duplicate in progress      11660000
DMPALIN  DS    0H                                                       11670000
         LA    R2,W#LINE+1             Output area address              11680000
         LA    R1,W#DMPOFF+2           Address of offset to dump        11690000
         LA    R15,2                   Convert 4 bytes                  11700000
         BAL   R14,DMPDSP              Convert it to display            11710000
         LA    R2,2(,R2)               Skip 1 between offset & data     11720000
         LR    R1,R3                   Address of data                  11730000
         LA    R5,32                   Default length                   11740000
         CR    R4,R5                   Length longer than 32 ?          11750000
         BH    DMPDODMP                Yes, use 32                      11760000
         LR    R5,R4                   Use what is left                 11770000
DMPDODMP DS    0H                                                       11780000
         SR    R4,R5                   Reduce amount to do              11790000
         MVI   W#LINE+89,C'*'          Box in display portion           11800000
         BCTR  R5,0                    Make zero based                  11810000
         EX    R5,DMPMVC               Do move                          11820000
         EX    R5,DMPTR                Translate out bad stuff          11830000
         LA    R5,1(,R5)               Restore length                   11840000
         MVI   W#LINE+122,C'*'         Complete box                     11850000
DMPDMPHX DS    0H                                                       11860000
         LA    R15,4                   4 bytes to process               11870000
         CR    R5,R15                  Length longer than 4?            11880000
         BH    DMPDMPIT                Yes, dump 4 bytes                11890000
         LR    R15,R5                  Use length left                  11900000
DMPDMPIT DS    0H                                                       11910000
         SR    R5,R15                  Reduce amount to do              11920000
         BAL   R14,DMPDSP              Convert data                     11930000
         LA    R2,1(,R2)               Skip 1 byte                      11940000
         LA    R0,W#LINE+43            Halfway point address            11950000
         CR    R0,R2                   At halfway point?                11960000
         BNE   DMPDMPNX                No, continue                     11970000
         LA    R2,1(,R2)               Skip 1 byte                      11980000
DMPDMPNX DS    0H                                                       11990000
         LTR   R5,R5                   Any left to do ?                 12000000
         BH    DMPDMPHX                Yes, go do it                    12010000
         BAL   R14,PRT                 Print a line                     12020000
DMPNXTLN DS    0H                                                       12030000
         L     R1,W#DMPOFF             Get offset in record             12040000
         LA    R1,32(,R1)              Add in length we will dump       12050000
         ST    R1,W#DMPOFF             Save offset in record            12060000
         LA    R3,32(,R3)              Next input area                  12070000
         NI    W#DMPFLG,255-W#DMP1ST   Not first line                   12080000
         B     DMPDMPLP                Loop thru until done             12090000
DMPHEXXT DS    0H                                                       12100000
         LM    R0,R15,W#DMPRGS         Restore callers regs             12110000
         BR    R14                     Exit . . .                       12120000
DMPMVC   MVC   W#LINE+90(0),0(R1)      <<< executed >>>                 12130000
DMPTR    TR    W#LINE+90(0),P#DMPTBL   <<< executed >>>                 12140000
*                                                                       12150000
*        Convert hex data to display                                    12160000
*                                                                       12170000
DMPDSP   DS    0H                                                       12180000
         UNPK  0(1,R2),0(1,R1)         Get first hex byte               12190000
         NI    0(R2),X'0F'             Remove zone                      12200000
         MVC   1(1,R2),0(R1)           Move second hex byte             12210000
         NI    1(R2),X'0F'             Remove its zone also             12220000
         TR    0(2,R2),=C'0123456789ABCDEF' Translate to hex            12230000
         LA    R2,2(,R2)               Point to next output area        12240000
         LA    R1,1(,R1)               Point to next input area         12250000
         BCT   R15,DMPDSP              Loop thru data                   12260000
         BR    R14                     Exit                             12270000
*********************************************************************** 12280000
*                                                                     * 12290000
*        CONSTANTS                                                    * 12300000
*                                                                     * 12310000
*********************************************************************** 12320000
SMFDSMVC MVC   W#LINE+80(0),0(R15)                                      12330000
P#DMPTBL DC    CL256' '                                                 12340000
         ORG   P#DMPTBL+X'4A' Cent                                      12350000
         DC    X'4A4B4C4D4E4F50'                                        12360000
         ORG   P#DMPTBL+X'5A' exclamation                               12370000
         DC    X'5A5B5C5D5E5F6061'                                      12380000
         ORG   P#DMPTBL+X'6A'                                           12390000
         DC    X'6A6B6C6D6E6F'                                          12400000
         ORG   P#DMPTBL+X'7A'                                           12410000
         DC    X'7A7B7C7D7E7F'                                          12420000
         ORG   P#DMPTBL+C'a'                                            12430000
         DC    C'abcdefghi'                                             12440000
         ORG   P#DMPTBL+C'j'                                            12450000
         DC    C'jklmnopqr'                                             12460000
         ORG   P#DMPTBL+C's'                                            12470000
         DC    C'stuvwxyz'                                              12480000
         ORG   P#DMPTBL+C'A'                                            12490000
         DC    C'ABCDEFGHI'                                             12500000
         ORG   P#DMPTBL+C'J'                                            12510000
         DC    C'JKLMNOPQR'                                             12520000
         ORG   P#DMPTBL+C'S'                                            12530000
         DC    C'STUVWXYZ'                                              12540000
         ORG   P#DMPTBL+C'0'                                            12550000
         DC    C'0123456789'                                            12560000
         ORG   ,                                                        12570000
*                                                                       12580000
P#JULTBL DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  12590000
*                                                                       12600000
P#OPNLSB OPEN  (0,(INPUT),0,(OUTPUT)),MF=L                              12610000
P#OPNLST EQU   P#OPNLSB,*-P#OPNLSB                                      12620000
*                                                                       12630000
P#INDCBB DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=INEOF               12640000
P#INDCB  EQU   P#INDCBB,*-P#INDCBB                                      12650000
*                                                                       12660000
P#OTDCBB DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X12670000
               RECFM=FBA,LRECL=133                                      12680000
P#OTDCB  EQU   P#OTDCBB,*-P#OTDCBB                                      12690000
*                                                                       12700000
P#SIDCBB DCB   DDNAME=SMFIN,MACRF=GM,DSORG=PS,EODAD=SMFEOF              12710000
*              RECFM=VBS,LRECL=32767,BLKSIZE=32760                      12720000
P#SIDCB  EQU   P#SIDCBB,*-P#SIDCBB                                      12730000
*                                                                       12740000
P#SODCBB DCB   DDNAME=SMFOUT,MACRF=PM,DSORG=PS,                        X12750001
               RECFM=VBS,LRECL=32767                                    12760000
P#SODCB  EQU   P#SODCBB,*-P#SODCBB                                      12770000
*                                                                       12780000
         LTORG ,                                                        12790000
SMFDESC  DC    A(000,L'SMFDS000,SMFDS000)                               12800000
         DC    A(002,L'SMFDS002,SMFDS002)                               12810000
         DC    A(003,L'SMFDS003,SMFDS003)                               12820000
         DC    A(004,L'SMFDS004,SMFDS004)                               12830000
         DC    A(005,L'SMFDS005,SMFDS005)                               12840000
         DC    A(006,L'SMFDS006,SMFDS006)                               12850000
         DC    A(007,L'SMFDS007,SMFDS007)                               12860000
         DC    A(008,L'SMFDS008,SMFDS008)                               12870000
         DC    A(009,L'SMFDS009,SMFDS009)                               12880000
         DC    A(010,L'SMFDS010,SMFDS010)                               12890000
         DC    A(011,L'SMFDS011,SMFDS011)                               12900000
         DC    A(014,L'SMFDS014,SMFDS014)                               12910000
         DC    A(015,L'SMFDS015,SMFDS015)                               12920000
         DC    A(016,L'SMFDS016,SMFDS016)                               12930000
         DC    A(017,L'SMFDS017,SMFDS017)                               12940000
         DC    A(018,L'SMFDS018,SMFDS018)                               12950000
         DC    A(019,L'SMFDS019,SMFDS019)                               12960000
         DC    A(020,L'SMFDS020,SMFDS020)                               12970000
         DC    A(021,L'SMFDS021,SMFDS021)                               12980000
         DC    A(022,L'SMFDS022,SMFDS022)                               12990000
         DC    A(023,L'SMFDS023,SMFDS023)                               13000000
         DC    A(024,L'SMFDS024,SMFDS024)                               13010000
         DC    A(025,L'SMFDS025,SMFDS025)                               13020000
         DC    A(026,L'SMFDS026,SMFDS026)                               13030000
         DC    A(028,L'SMFDS028,SMFDS028)                               13040000
         DC    A(030,L'SMFDS030,SMFDS030)                               13050000
         DC    A(031,L'SMFDS031,SMFDS031)                               13060000
         DC    A(032,L'SMFDS032,SMFDS032)                               13070000
         DC    A(033,L'SMFDS033,SMFDS033)                               13080000
         DC    A(034,L'SMFDS034,SMFDS034)                               13090000
         DC    A(035,L'SMFDS035,SMFDS035)                               13100000
         DC    A(036,L'SMFDS036,SMFDS036)                               13110000
         DC    A(037,L'SMFDS037,SMFDS037)                               13120000
         DC    A(039,L'SMFDS039,SMFDS039)                               13130000
         DC    A(040,L'SMFDS040,SMFDS040)                               13140000
         DC    A(041,L'SMFDS041,SMFDS041)                               13150000
         DC    A(042,L'SMFDS042,SMFDS042)                               13160000
         DC    A(043,L'SMFDS043,SMFDS043)                               13170000
         DC    A(045,L'SMFDS045,SMFDS045)                               13180000
         DC    A(047,L'SMFDS047,SMFDS047)                               13190000
         DC    A(048,L'SMFDS048,SMFDS048)                               13200000
         DC    A(049,L'SMFDS049,SMFDS049)                               13210000
         DC    A(050,L'SMFDS050,SMFDS050)                               13220000
         DC    A(052,L'SMFDS052,SMFDS052)                               13230000
         DC    A(053,L'SMFDS053,SMFDS053)                               13240000
         DC    A(054,L'SMFDS054,SMFDS054)                               13250000
         DC    A(055,L'SMFDS055,SMFDS055)                               13260000
         DC    A(056,L'SMFDS056,SMFDS056)                               13270000
         DC    A(057,L'SMFDS057,SMFDS057)                               13280000
         DC    A(058,L'SMFDS058,SMFDS058)                               13290000
         DC    A(059,L'SMFDS059,SMFDS059)                               13300000
         DC    A(060,L'SMFDS060,SMFDS060)                               13310000
         DC    A(061,L'SMFDS061,SMFDS061)                               13320000
         DC    A(062,L'SMFDS062,SMFDS062)                               13330000
         DC    A(063,L'SMFDS063,SMFDS063)                               13340000
         DC    A(064,L'SMFDS064,SMFDS064)                               13350000
         DC    A(065,L'SMFDS065,SMFDS065)                               13360000
         DC    A(066,L'SMFDS066,SMFDS066)                               13370000
         DC    A(067,L'SMFDS067,SMFDS067)                               13380000
         DC    A(068,L'SMFDS068,SMFDS068)                               13390000
         DC    A(069,L'SMFDS069,SMFDS069)                               13400000
         DC    A(070,L'SMFDS070,SMFDS070)                               13410000
         DC    A(071,L'SMFDS071,SMFDS071)                               13420000
         DC    A(072,L'SMFDS072,SMFDS072)                               13430000
         DC    A(073,L'SMFDS073,SMFDS073)                               13440000
         DC    A(074,L'SMFDS074,SMFDS074)                               13450000
         DC    A(075,L'SMFDS075,SMFDS075)                               13460000
         DC    A(076,L'SMFDS076,SMFDS076)                               13470000
         DC    A(077,L'SMFDS077,SMFDS077)                               13480000
         DC    A(078,L'SMFDS078,SMFDS078)                               13490000
         DC    A(079,L'SMFDS079,SMFDS079)                               13500000
         DC    A(080,L'SMFDS080,SMFDS080)                               13510000
         DC    A(081,L'SMFDS081,SMFDS081)                               13520000
         DC    A(082,L'SMFDS082,SMFDS082)                               13530000
         DC    A(082,L'SMFDS082,SMFDS082)                               13540000
         DC    A(083,L'SMFDS083,SMFDS083)                               13550000
         DC    A(084,L'SMFDS084,SMFDS084)                               13560000
         DC    A(085,L'SMFDS085,SMFDS085)                               13570000
         DC    A(088,L'SMFDS088,SMFDS088)                               13580000
         DC    A(089,L'SMFDS089,SMFDS089)                               13590000
         DC    A(090,L'SMFDS090,SMFDS090)                               13600000
         DC    A(091,L'SMFDS091,SMFDS091)                               13610000
         DC    A(092,L'SMFDS092,SMFDS092)                               13620000
         DC    A(094,L'SMFDS094,SMFDS094)                               13630000
         DC    A(096,L'SMFDS096,SMFDS096)                               13640000
         DC    A(097,L'SMFDS097,SMFDS097)                               13650000
         DC    A(099,L'SMFDS099,SMFDS099)                               13660000
         DC    A(100,L'SMFDS100,SMFDS100)                               13670000
         DC    A(101,L'SMFDS101,SMFDS101)                               13680000
         DC    A(102,L'SMFDS102,SMFDS102)                               13690000
         DC    A(103,L'SMFDS103,SMFDS103)                               13700000
         DC    A(108,L'SMFDS108,SMFDS108)                               13710000
         DC    A(109,L'SMFDS109,SMFDS109)                               13720000
         DC    A(110,L'SMFDS110,SMFDS110)                               13730000
         DC    A(113,L'SMFDS113,SMFDS113)                               13740000
         DC    A(115,L'SMFDS115,SMFDS115)                               13750000
         DC    A(116,L'SMFDS116,SMFDS116)                               13760000
         DC    A(117,L'SMFDS117,SMFDS117)                               13770000
         DC    A(118,L'SMFDS118,SMFDS118)                               13780000
         DC    A(119,L'SMFDS119,SMFDS119)                               13790000
         DC    A(120,L'SMFDS120,SMFDS120)                               13800000
         DC    A(122,L'SMFDS122,SMFDS122)                               13810000
         DC    A(125,L'SMFDS125,SMFDS125)                               13820000
         DC    A(126,L'SMFDS126,SMFDS126)                               13830000
         DC    X'FFFFFFFF'                                              13840000
SMFDS000 DC    C'IPL'                                                   13850000
SMFDS002 DC    C'Dump Header'                                           13860000
SMFDS003 DC    C'Dump Trailer'                                          13870000
SMFDS004 DC    C'Step Termination'                                      13880000
SMFDS005 DC    C'Job Termination'                                       13890000
SMFDS006 DC    C'JES Output Writer'                                     13900000
SMFDS007 DC    C'Data Lost'                                             13910000
SMFDS008 DC    C'I/O Configuration'                                     13920000
SMFDS009 DC    C'VARY Device ONLINE'                                    13930000
SMFDS010 DC    C'Allocation Recovery'                                   13940000
SMFDS011 DC    C'VARY Device OFFLINE'                                   13950000
SMFDS014 DC    C'INPUT or RDBACK Data Set Activity'                     13960000
SMFDS015 DC    C'OUTPUT, UPDAT, INOUT, or OUTIN Data Set Activity'      13970000
SMFDS016 DC    C'DFSORT Statistics'                                     13980000
SMFDS017 DC    C'Scratch Data Set Status'                               13990000
SMFDS018 DC    C'Rename Non-VSAM Data Set Status'                       14000000
SMFDS019 DC    C'Direct Access Volume'                                  14010000
SMFDS020 DC    C'Job Initiation'                                        14020000
SMFDS021 DC    C'Error Statistics by Volume'                            14030000
SMFDS022 DC    C'Configuration'                                         14040000
SMFDS023 DC    C'SMF Status'                                            14050000
SMFDS024 DC    C'JES2 Spool Offload'                                    14060000
SMFDS025 DC    C'JES3 Device Allocation'                                14070000
SMFDS026 DC    C'JES Job Purge'                                         14080000
SMFDS028 DC    C'NPM Statistics'                                        14090000
SMFDS030 DC    C'Common Address Space Work'                             14100000
SMFDS031 DC    C'TIOC Initialization'                                   14110000
SMFDS032 DC    C'TSO/E User Work Accounting'                            14120000
SMFDS033 DC    C'APPC/MVS TP Accounting'                                14130000
SMFDS034 DC    C'TS-Step Termination'                                   14140000
SMFDS035 DC    C'LOGOFF'                                                14150000
SMFDS036 DC    C'Integrated Catalog Facility Catalog'                   14160000
SMFDS037 DC    C'NetView Hardware Monitor'                              14170000
SMFDS039 DC    C'NetView (NLDM) Response Time'                          14180000
SMFDS040 DC    C'Dynamic DD'                                            14190000
SMFDS041 DC    C'DIV Objects and VLF Statistics'                        14200000
SMFDS042 DC    C'DFSMS Statistics and Configuration'                    14210000
SMFDS043 DC    C'JES Start'                                             14220000
SMFDS045 DC    C'JES Stop'                                              14230000
SMFDS047 DC    C'JES SIGNON/Start Line/LOGON'                           14240000
SMFDS048 DC    C'JES SIGNOFF/Stop Line/LOGOFF'                          14250000
SMFDS049 DC    C'JES Integrity'                                         14260000
SMFDS050 DC    C'VTAM Tuning Statistics'                                14270000
SMFDS052 DC    C'JES2 LOGON/Start Line (SNA only)'                      14280000
SMFDS053 DC    C'JES2 LOGOFF/Stop Line (SNA only)'                      14290000
SMFDS054 DC    C'JES2 Integrity (SNA only)'                             14300000
SMFDS055 DC    C'JES2 Network SIGNON'                                   14310000
SMFDS056 DC    C'JES2 Network Integrity'                                14320000
SMFDS057 DC    C'JES Networking Transmission'                           14330000
SMFDS058 DC    C'JES2 Network SIGNOFF'                                  14340000
SMFDS059 DC    C'MVS/BDT File-to-File Transmission'                     14350000
SMFDS060 DC    C'VSAM Volume Data Set Updated'                          14360000
SMFDS061 DC    C'Integrated Catalog Facility Define Activity'           14370000
SMFDS062 DC    C'VSAM Component or Cluster Opened'                      14380000
SMFDS063 DC    C'VSAM Catalog Entry Defined'                            14390000
SMFDS064 DC    C'VSAM Component or Cluster Status'                      14400000
SMFDS065 DC    C'Integrated Catalog Facility Delete Activity'           14410000
SMFDS066 DC    C'Integrated Catalog Facility Alter Activity'            14420000
SMFDS067 DC    C'VSAM Catalog Entry Deleted'                            14430000
SMFDS068 DC    C'VSAM Catalog Entry Renamed'                            14440000
SMFDS069 DC    C'VSAM Data Space Defined, Extended, or Deleted'         14450000
SMFDS070 DC    C'RMF Processor Activity'                                14460000
SMFDS071 DC    C'RMF Paging Activity'                                   14470000
SMFDS072 DC    C'RMF Workload Activity and Storage Data'                14480000
SMFDS073 DC    C'RMF Channel Path Activity'                             14490000
SMFDS074 DC    C'RMF Activity of Several Resources'                     14500000
SMFDS075 DC    C'RMF Page Data Set Activity'                            14510000
SMFDS076 DC    C'RMF Trace Activity'                                    14520000
SMFDS077 DC    C'RMF Enqueue Activity'                                  14530000
SMFDS078 DC    C'RMF Virtual Storage and I/O Queuing Activity'          14540000
SMFDS079 DC    C'RMF Monitor II Activity'                               14550000
SMFDS080 DC    C'Security Product Processing'                           14560000
SMFDS081 DC    C'RACF Initialization'                                   14570000
SMFDS082 DC    C'CUSP/ICSF Record'                                      14580000
SMFDS083 DC    C'RACF Audit Record For Data Sets'                       14590000
SMFDS084 DC    C'JES3 Monitoring Facility Data'                         14600000
SMFDS085 DC    C'Measuring OAM Transaction Performance'                 14610000
SMFDS088 DC    C'System Logger Data'                                    14620000
SMFDS089 DC    C'Usage Data'                                            14630000
SMFDS090 DC    C'System Status'                                         14640000
SMFDS091 DC    C'BatchPipes/MVS Statistics'                             14650000
SMFDS092 DC    C'File System Activity'                                  14660000
SMFDS094 DC    C'IBM Tape Library Dataserver Statistics'                14670000
SMFDS096 DC    C'Cross Memory Service Provider Charge Back'             14680000
SMFDS097 DC    C'Foreign Enclave Resource Data'                         14690000
SMFDS099 DC    C'System Resource Manager Decisions'                     14700000
SMFDS100 DC    C'DB2 Statistics'                                        14710000
SMFDS101 DC    C'DB2 Accounting'                                        14720000
SMFDS102 DC    C'DB2 Performance'                                       14730000
SMFDS103 DC    C'HTTP Server'                                           14740000
SMFDS108 DC    C'Domino Server Statistics'                              14750000
SMFDS109 DC    C'TCP/IP Statistics'                                     14760000
SMFDS110 DC    C'CICS/ESA Statistics'                                   14770000
SMFDS113 DC    C'Hardware capacity, reporting, and statistics'          14780000
SMFDS115 DC    C'MQSeries Statistics'                                   14790000
SMFDS116 DC    C'MQSeries Statistics'                                   14800000
SMFDS117 DC    C'WebSphere Message Broker'                              14810000
SMFDS118 DC    C'TCP/IP Statistics'                                     14820000
SMFDS119 DC    C'TCP/IP Statistics'                                     14830000
SMFDS120 DC    C'WebSphere Application Server Performance Statistics'   14840000
SMFDS122 DC    C'Tivoli Automated Tape Allocation Manager'              14850000
SMFDS125 DC    C'Generic Tracker for z/OS (GTZ)'                        14860000
SMFDS126 DC    C'Extended SMF records'                                  14870000
*********************************************************************** 14880000
*                                                                     * 14890000
*        WORK AREAS                                                   * 14900000
*                                                                     * 14910000
*********************************************************************** 14920000
W#       DSECT                                                          14930000
W#SA     DS    18A                                                      14940000
W#DMPRGS DS    16A                                                      14950000
W#DMPOFF DS    A                                                        14960000
W#DUP1ST DS    A                                                        14970000
W#DMPADR DS    A                                                        14980000
W#DMPFLG DS    X                                                        14990000
W#DMP1ST EQU   X'80'                                                    15000000
W#DMPDUP EQU   X'40'                                                    15010000
W#FLG    DS    X                                                        15020000
W#FLGDBG EQU   X'80'                                                    15030000
W#FLGDMP EQU   X'40'                                                    15040001
W#FLGSEL EQU   X'20'                                                    15050001
W#DWORD  DS    D                                                        15060000
W#PRMBGN DS    A                                                        15070000
W#INIT14 DS    A                                                        15080000
W#PRTR14 DS    A                                                        15090000
W#PRSD14 DS    A                                                        15100000
W#PDATE  DS    A                                                        15110000
W#PTIME  DS    A                                                        15120000
W#SCLR14 DS    A                                                        15130000
W#CURDTE DS    A                                                        15140000
W#JLWK1  DS    A                                                        15150000
W#JLWK2  DS    P'+365'                                                  15160000
W#JLWK13 DS    P'+01'                                                   15170000
W#JLWK12 DS    P'+31'                                                   15180000
W#JLWK11 DS    P'+30'                                                   15190000
W#JLWK10 DS    P'+31'                                                   15200000
W#JLWK09 DS    P'+30'                                                   15210000
W#JLWK08 DS    P'+31'                                                   15220000
W#JLWK07 DS    P'+31'                                                   15230000
W#JLWK06 DS    P'+30'                                                   15240000
W#JLWK05 DS    P'+31'                                                   15250000
W#JLWK04 DS    P'+30'                                                   15260000
W#JLWK03 DS    P'+31'                                                   15270000
W#JLWK02 DS    P'+28'                                                   15280000
W#JLWK01 DS    P'+31'                                                   15290000
W#TIMWRK DS    X'402021204B20204B20204B2020'                            15300000
W#LNCT   DS    PL2'+99'                                                 15310000
W#PGCT   DS    PL2'+0'                                                  15320000
W#HD1    DS    CL133                                                    15330000
         ORG   W#HD1+1                                                  15340000
W#HD1DTE DS    C'            '                                          15350000
         DS    C' '                                                     15360000
W#HD1TOD DS    C'HH:MM:SS'                                              15370000
         ORG   W#HD1+66-(15/2)                                          15380000
W#HD1TTL DS    C'S M F   D U M P'                                       15390000
         ORG   W#HD1+L'W#HD1-8                                          15400000
W#HD1PG  DS    C'Page'                                                  15410000
W#HD1PG# DS    C' 123'                                                  15420000
W#CARD   DS    CL80                                                     15430000
W#LINE   DS    CL133                                                    15440000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           15450000
W#OPNLST DS    XL(L'P#OPNLST)                                           15460000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           15470000
W#INDCB  DS    XL(L'P#INDCB)                                            15480000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           15490000
W#OTDCB  DS    XL(L'P#OTDCB)                                            15500000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           15510000
W#SIDCB  DS    XL(L'P#SIDCB)                                            15520000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           15530000
W#SODCB  DS    XL(L'P#SODCB)                                            15540000
W#PRSERR DS    CL2                                                      15550000
W#WRKNUM DS    X'40202120'                                              15560000
W#TMPTME DS    C'0hhmmssth'                                             15570000
W#FMTTME DS    C' hh:mm:ss.th'                                          15580000
W#FMTDTE DS    C'mm/dd/yyyy'                                            15590000
W#EDTNUM DS    X'40206B2021204B20'                                      15600000
W#SCALE  DS    C' '                                                     15610000
W#SMFREC DS    XL256                                                    15620000
W#RECCT  DS    PL4'+0'                                                  15630000
W#SELREC DS    PL4'+0'                                                  15640000
W#TOTLOD DS    A(X'FFFFFFFF')                                           15650000
W#TOTLOT DS    A(X'FFFFFFFF')                                           15660000
W#TOTHID DS    A(X'00000000')                                           15670000
W#TOTHIT DS    A(X'00000000')                                           15680000
W#MINREC DS    A(X'FFFFFFFF')                                           15690000
W#MAXREC DS    A(X'00000000')                                           15700000
W#RECIN  DS    256F'00'                                                 15710000
W#RECOUT DS    256F'00'                                                 15720000
W#RECLO  DS    256F'00'                                                 15730000
W#RECHI  DS    256F'00'                                                 15740000
W#FILSIZ DS    256F'00'                                                 15750000
         DS    (((((*-W#)/32)+1)*32)-(*-W#))X                           15760000
W#BUFFER DS    XL4096                  *                                15770000
         DS    XL4096                   *                               15780000
         DS    XL4096                   *                               15790000
         DS    XL4096                   *  32 K                         15800000
         DS    XL4096                   *  BUFFER                       15810000
         DS    XL4096                   *                               15820000
         DS    XL4096                   *                               15830000
         DS    XL4096                  *                                15840000
         DS    (((((*-W#)/4096)+1)*4096)-(*-W#))X                       15850000
W#LEN    EQU   *-W#                                                     15860000
*********************************************************************** 15870000
*        Common SMF Record Header                                     * 15880000
*********************************************************************** 15890000
SMFRCD   DSECT ,                                                        15900000
SMFLEN   DS    AL2                     Record length                    15910001
         DS    XL2                     Segment descriptor               15920001
SMFFLG   DS    XL1                     Header flag                      15930001
SMFFLGSU EQU   X'40'                   Sub types used                   15940001
SMFRTY   DS    XL1                     Record type                      15950001
SMFTME   DS    XL4                     Time record written              15960001
SMFDTE   DS    PL4                     Date record written              15970001
SMFSID   DS    CL4                     System id                        15980001
SMFWID   DS    CL4                     Subsystem id                     15990001
SMFSTP   DS    XL2                     Subtype                          16000001
*                                                                       16010000
*                                                                       16020000
*                                                                       16030000
R0       EQU   0                                                        16040000
R1       EQU   1                                                        16050000
R2       EQU   2                                                        16060000
R3       EQU   3                                                        16070000
R4       EQU   4                                                        16080000
R5       EQU   5                                                        16090000
R6       EQU   6                                                        16100000
R7       EQU   7                                                        16110000
R8       EQU   8                                                        16120000
R9       EQU   9                                                        16130000
R10      EQU   10                                                       16140000
R11      EQU   11                                                       16150000
R12      EQU   12                                                       16160000
R13      EQU   13                                                       16170000
R14      EQU   14                                                       16180000
R15      EQU   15                                                       16190000
         IHADCB DSORG=PS                                                16200000
         END                                                            16210000
