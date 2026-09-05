*********************************************************************** 00010000
*                                                                     * 00020000
*                                                                     * 00030000
*                                                                     * 00040000
*********************************************************************** 00050000
         MACRO                                                          00060000
&L       $TRC                                                           00070000
         AIF    (T'&L EQ 'O').NOLBL                                     00080000
&L       DS     0H                                                      00090000
.NOLBL   ANOP                                                           00100000
         BALR   R11,0                                                   00110000
         MEND                                                           00120000
IEWLFRNT CSECT                                                          00130000
         USING IEWLFRNT,R15                                             00140000
         B     START                   Bypass PGMID                     00150000
         DROP  R15                                                      00160000
         DC    AL1(L'PGMID)            Length of PGMID                  00170000
PGMID    DC    C'IEWLFRNT - &SYSDATE &SYSTIME'                          00180000
START    DS    0H                                                       00190000
         STM   R14,R12,12(R13)         Save calling pgm's registers     00200000
         LR    R12,R15                                                  00210000
         USING IEWLFRNT,R12                                             00220000
         LR    R10,R1                  Save parameter address           00230000
         LA    R0,W#LEN                Work area length                 00240000
         GETMAIN R,LV=(0)              Get work area                    00250000
         LR    R3,R13                  Save save area address           00260000
         LR    R13,R1                  Address save area                00270000
         USING W#,R13                                                   00280000
         LR    R0,R13                  Work area address                00290000
         LA    R1,W#LEN                Work area length                 00300000
         SR    R15,R15                 Set up to clear                  00310000
         MVCL  R0,R14                  Clear work area                  00320000
         ST    R3,4(,R13)              Chain callers save area          00330000
         ST    R13,8(,R3)              Chain my save area               00340000
*********************************************************************** 00350000
*                                                                     * 00360000
*********************************************************************** 00370000
PROC     $TRC                                                           00380000
         MVI   W#HITFLG,C'N'                                            00390000
         MVC   W#LINOLS,P#LINOLS       Prime OPEN list                  00400000
         MVC   W#LINDCB,P#LINDCB       Prime DCB                        00410000
         OPEN  (W#LINDCB,(INPUT)),MF=(E,W#LINOLS) OPEN SYSLIN           00420000
         TM    W#LINDCB+48,X'10'       OPEN ok?                         00430000
         BNO   PROC030                 No, error                        00440000
PROC005  $TRC                                                           00450000
         GET   W#LINDCB                                                 00460000
         LA    R0,10                                                    00470000
PROC010  $TRC                                                           00480000
         CLC   =C'INCLUDE SMPWRK3(IEFVGM10)',0(R1)                      00490000
         BE    PROC020                                                  00500000
         LA    R1,1(,R1)                                                00510000
         BCT   R0,PROC010                                               00520000
         B     PROC005                                                  00530000
PROC020  $TRC                                                           00540000
         MVI   W#HITFLG,C'Y'                                            00550000
         BAL   R14,INIT                Initialization                   00560000
         LTR   R15,R15                 Was it successful?               00570000
         BNZ   EXIT                    No, exit                         00580000
LINEOF   DS    0H                                                       00590000
PROC030  $TRC                                                           00600000
         CLOSE (W#LINDCB),MF=(E,W#LINOLS) CLOSE SYSLIN                  00610000
         CLI   W#HITFLG,C'Y'                                            00620000
         BNE   PROC040                                                  00630000
         WTO   'IEFVGM10 link found'                                    00640000
         XC    W#ECB,W#ECB                                              00650000
         MVC   W#WTORP,P#WTORP                                          00660000
         WTOR  'Pause',W#REPLY,L'W#REPLY,W#ECB,MF=(E,W#WTORP)           00670000
         WAIT  1,ECB=W#ECB             Wait for it                      00680000
         WTO   'Begin IEFVGM10 link'                                    00690000
PROC040  $TRC                                                           00700000
         LR    R1,R10                  Pass parameters to LINKEDIT      00710000
         LINK  EP=IEWL                 LINKEDIT                         00720000
         LR    R5,R15                  Save return code                 00730000
         CLI   W#HITFLG,C'Y'                                            00740000
         BNE   PROC050                                                  00750000
         WTO   'IEFVGM10 link ended'                                    00760000
         XC    W#ECB,W#ECB                                              00770000
         MVC   W#WTORP,P#WTORP                                          00780000
         WTOR  'Pause',W#REPLY,L'W#REPLY,W#ECB,MF=(E,W#WTORP)           00790000
         WAIT  1,ECB=W#ECB             Wait for it                      00800000
         MVC   W#LINOLS,P#LINOLS       Prime OPEN list                  00810000
         CLOSE (W#OTDCB),MF=(E,W#OPNLST) CLOSE SYSPRINT                 00820000
PROC050  $TRC                                                           00830000
         LR    R15,R5                  Restore return code              00840000
*********************************************************************** 00850000
*                                                                     * 00860000
*********************************************************************** 00870000
EXIT     $TRC                                                           00880000
         LR    R2,R15                  Return code                      00890000
         LR    R1,R13                  Address of work area             00900000
         L     R13,4(R13)              Restore callers R13              00910000
         LA    R0,W#LEN                Work area length                 00920000
         FREEMAIN R,LV=(0),A=(1)       Free work area                   00930000
         L     R14,12(,R13)            Restore R14                      00940000
         LR    R15,R2                  Restore return code              00950000
         LM    R2,R12,28(R13)          Restore rest of registers        00960000
         BR    R14                     Exit                             00970000
*********************************************************************** 00980000
*            INITIALIZATION                                           * 00990000
*********************************************************************** 01000000
INIT     $TRC                                                           01010000
         ST    R14,W#INIT14            Save linkage                     01020000
         MVC   W#OPNLST,P#OPNLST       Prime OPEN list                  01030000
         MVC   W#OTDCB,P#OTDCB         Prime DCB                        01040000
         MVI   W#LINE,C' '             Clear print line                 01050000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              01060000
         MVC   W#HD1,W#LINE            Clear heading 1                  01070000
         MVI   W#HD1,C'1'              Prime heading 1                  01080000
         MVC   W#HD1TTL,=C'I E W L   F R O N T'                         01090000
         MVC   W#HD1PG,=C'Page'                                         01100000
         ZAP   W#LNCT,=P'+99'                                           01110000
         ZAP   W#PGCT,=P'+0'                                            01120000
         OPEN  (W#OTDCB,(OUTPUT)),MF=(E,W#OPNLST)                       01130000
         TM    W#OTDCB+48,16           OPEN successful?                 01140000
         BZ    INITER                  No, error                        01150000
         ZAP   W#JLWK13,=P'+1'         Prime work                       01160000
         ZAP   W#JLWK12,=P'+31'        Prime Dec                        01170000
         ZAP   W#JLWK11,=P'+30'        Prime Nov                        01180000
         ZAP   W#JLWK10,=P'+31'        Prime Oct                        01190000
         ZAP   W#JLWK09,=P'+30'        Prime Sep                        01200000
         ZAP   W#JLWK08,=P'+31'        Prime Aug                        01210000
         ZAP   W#JLWK07,=P'+31'        Prime Jul                        01220000
         ZAP   W#JLWK06,=P'+30'        Prime Jun                        01230000
         ZAP   W#JLWK05,=P'+31'        Prime May                        01240000
         ZAP   W#JLWK04,=P'+30'        Prime Apr                        01250000
         ZAP   W#JLWK03,=P'+31'        Prime Mar                        01260000
         ZAP   W#JLWK02,=P'+28'        Prime Feb                        01270000
         ZAP   W#JLWK01,=P'+31'        Prime Jan                        01280000
         TIME  BIN                     Get current date and time        01290000
         ST    R1,W#CURDTE             Save date                        01300000
         SRDL  R0,32                   Get double word time             01310000
         D     R0,=F'+6000'            Get minutes                      01320000
         LR    R15,R0                  Save secs tens and hundreths     01330000
         SLR   R0,R0                   Clear                            01340000
         D     R0,=F'+60'              Get hours / mins                 01350000
         MH    R0,=H'+10000'           Get minutes                      01360000
         AR    R15,R0                  Add to get MM:SS.TH              01370000
         M     R0,=F'+1000000'         Get hours                        01380000
         AR    R1,R15                  Get HH:MM:SS.TH                  01390000
         CVD   R1,W#DWORD              Get time to decimal              01400000
         MVC   W#TIMWRK,=X'402021204B20204B20204B2020'                  01410000
         ED    W#TIMWRK,W#DWORD+3      Edit time                        01420000
         MVC   W#HD1TOD(8),W#TIMWRK+2  Move time                        01430000
         ZAP   W#JLWK1,W#CURDTE+2(2)   Get julian date                  01440000
         ZAP   W#JLWK2,=P'+365'        Days/yr = 365                    01450000
         ZAP   W#JLWK02,=P'+28'        Feb = 28                         01460000
         MVO   W#DWORD,W#CURDTE+1(1)   Sign year                        01470000
         DP    W#DWORD,=P'+4'          Divide by 4                      01480000
         CP    W#DWORD+7(1),=P'+0'     Is it a leap year ?              01490000
         BNZ   JULCVT2                 No                               01500000
         ZAP   W#JLWK2,=P'+366'        Days/yr = 366                    01510000
         ZAP   W#JLWK02,=P'+29'        Feb = 29                         01520000
JULCVT2  $TRC                                                           01530000
         LA    R1,W#JLWK01             Point to Jan                     01540000
         SLR   R2,R2                   Set counter                      01550000
JULCVT4  $TRC                                                           01560000
         SP    W#JLWK1,0(2,R1)         Months displacement              01570000
         BNP   JULCVT6                 If equal or less                 01580000
         SH    R1,=H'+2'               Point to next month              01590000
         LA    R2,3(,R3)               Up index                         01600000
         B     JULCVT4                 Loop                             01610000
JULCVT6  $TRC                                                           01620000
         AP    W#JLWK1,0(2,R1)         Add days of month                01630000
         LA    R2,P#JULTBL(R2)         Address month                    01640000
         MVC   W#HD1DTE(3),0(R2)       Move month                       01650000
         OI    W#JLWK1+3,X'0F'         Display sign                     01660000
         UNPK  W#HD1DTE+4(2),W#JLWK1   Get days                         01670000
         CLI   W#HD1DTE+4,C'0'         First 9 days ?                   01680000
         LA    R1,W#HD1DTE+6           Set pointer                      01690000
         BNE   JULCVT7                 No                               01700000
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 Move units digit                01710000
         BCTR  R1,0                    Drop pointer                     01720000
JULCVT7  $TRC                                                           01730000
         MVC   0(4,R1),=C', 19'        Set up constant                  01740000
         TM    W#CURDTE,1              Year 2000?                       01750000
         BNO   JULCVT8                 No, continue                     01760000
         MVC   2(2,R1),=C'20'          Year 2000                        01770000
JULCVT8  $TRC                                                           01780000
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     01790000
         MVC   4(2,R1),W#DWORD         Get year                         01800000
*                                                                       01810000
         MVC   W#LINE+1(8),=C'Version=' Move version literal            01820000
         MVC   W#LINE+9(L'PGMID),PGMID Move version                     01830000
         BAL   R14,PRT                 Print a line                     01840000
         SR    R15,R15                 Set successful return code       01850000
         B     INITXT                  Go exit                          01860000
INITER   $TRC                                                           01870000
         LA    R15,32                  Set error return code            01880000
INITXT   $TRC                                                           01890000
         L     R14,W#INIT14            Get return address               01900000
         BR    R14                     Return to caller                 01910000
                                                                        01920000
*********************************************************************** 01930000
*            WRITE PRINT LINE                                         * 01940000
*********************************************************************** 01950000
PRT      $TRC                                                           01960000
         ST    R14,W#PRTR14                                             01970000
         CP    W#LNCT,=P'+60'          End of page                      01980000
         BL    PRTCHK                  No, check if line fit in page    01990000
PRTHDRS  $TRC                                                           02000000
         AP    W#PGCT,=P'+1'           Count pages                      02010000
         MVC   W#HD1PG#,=X'40202120'   Page count mask                  02020000
         ED    W#HD1PG#,W#PGCT         Edit page count                  02030000
         PUT   W#OTDCB,W#HD1           Print heading 1                  02040000
         ZAP   W#LNCT,=P'+1'           Init line count                  02050000
         MVI   W#LINE,C'0'             Skip after heading               02060000
PRTCHK   $TRC                                                           02070000
         CLI   W#LINE,C'+'             Overprint?                       02080000
         BE    PRTLINE                 Yes, don't count                 02090000
         CLI   W#LINE,C'1'             New line?                        02100000
         BE    PRTHDRS                 Yes, print header                02110000
         CLI   W#LINE,C' '             Write after advancing 1?         02120000
         BE    PRTLINE1                Yes, go check if fit             02130000
         CLI   W#LINE,C'0'             Write after advancing 2?         02140000
         BE    PRTLINE2                Yes, go check if fit             02150000
         CLI   W#LINE,C'-'             Write after advancing 3?         02160000
         BE    PRTLINE3                Yes, go check if fit             02170000
         B     PRTLINE                 Ignore any other ctl chars       02180000
PRTLINE1 $TRC                                                           02190000
         AP    W#LNCT,=P'+1'           Add to line count                02200000
         B     PRTVFY                  Go see if it will fit            02210000
PRTLINE2 $TRC                                                           02220000
         AP    W#LNCT,=P'+2'           Add to line count                02230000
         B     PRTVFY                  Go see if it will fit            02240000
PRTLINE3 $TRC                                                           02250000
         AP    W#LNCT,=P'+3'           Add to line count                02260000
PRTVFY   $TRC                                                           02270000
         CP    W#LNCT,=P'+60'          Overflow?                        02280000
         BH    PRTHDRS                 Yes, force header                02290000
PRTLINE  $TRC                                                           02300000
         PUT   W#OTDCB,W#LINE          Print a line                     02310000
         MVI   W#LINE,C' '             Clear print line                 02320000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              02330000
         L     R14,W#PRTR14                                             02340000
         BR    R14                     Return to caller                 02350000
                                                                        02360000
*********************************************************************** 02370000
*        DUMP DATA                                                    * 02380000
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP                 * 02390000
*                     REG 1  = ADDRESS OF DATA TO DUMP                * 02400000
*********************************************************************** 02410000
DMP      $TRC                                                           02420000
         STM   R0,R15,W#DMPRGS         Save registers                   02430000
         LR    R3,R1                   Get address to dump              02440000
         LR    R4,R0                   Get length                       02450000
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump             02460000
         MVI   W#DMPFL,W#DMPFL1        First line                       02470000
DMPDMPLP $TRC                                                           02480000
         LTR   R4,R4                   Any data to dump?                02490000
         BZ    DMPHEXXT                Ye, all done                     02500000
         TM    W#DMPFL,W#DMPFL1        First line?                      02510000
         BO    DMPALIN                 Yes, can't have same as above    02520000
         LA    R0,32                   Default length                   02530000
         CR    R4,R0                   Length longer than 32?           02540000
         BNH   DMPDUPCK                No, were at last line            02550000
         LR    R14,R3                  Get current input area           02560000
         SR    R14,R0                  Back to previous area            02570000
         CLC   0(32,R14),0(R3)         Duplicate of previous line       02580000
         BNE   DMPDUPCK                No, do lines same as             02590000
         SR    R4,R0                   Reduce length to do              02600000
         TM    W#DMPFL,W#DMPDUP        Duplicate in progress?           02610000
         BO    DMPNXTLN                Yes, we have first offset        02620000
         L     R14,W#DMPOFF            Get current offset               02630000
         ST    R14,W#DUP1ST            Save as first offset             02640000
         OI    W#DMPFL,W#DMPDUP        Set duplicate                    02650000
         B     DMPNXTLN                Continue                         02660000
DMPDUPCK $TRC                                                           02670000
         TM    W#DMPFL,W#DMPDUP        Duplicate in progress?           02680000
         BNO   DMPALIN                 No, no duplicate to report       02690000
         MVC   W#LINE+7(5),=C'lines'   Move literal                     02700000
         LA    R2,W#LINE+13            Output area address              02710000
         LA    R1,W#DUP1ST+1           Address of offset to dump        02720000
         LA    R15,3                   Convert 4 bytes                  02730000
         BAL   R14,DMPDSP              Convert it to display            02740000
         MVI   W#LINE+19,C'-'          Thru literal                     02750000
         L     R1,W#DMPOFF             Get current offset               02760000
         SH    R1,=H'+32'              Get last duplicate offset        02770000
         ST    R1,W#DUP1ST             Save for dumping                 02780000
         LA    R2,W#LINE+20            Output area address              02790000
         LA    R1,W#DUP1ST+1           Address of offset to dump        02800000
         LA    R15,3                   Convert 4 bytes                  02810000
         BAL   R14,DMPDSP              Convert it to display            02820000
         MVC   W#LINE+27(13),=C'same as above' move literal             02830000
         BAL   R14,PRT                 Print a line                     02840000
         NI    W#DMPFL,255-W#DMPDUP    Reset duplicate in progress      02850000
DMPALIN  $TRC                                                           02860000
         LA    R2,W#LINE+1             Output area address              02870000
         LA    R1,W#DMPOFF+1           Address of offset to dump        02880000
         LA    R15,3                   Convert 4 bytes                  02890000
         BAL   R14,DMPDSP              Convert it to display            02900000
         LA    R2,2(,R2)               Skip 1 between offset & data     02910000
         LR    R1,R3                   Address of data                  02920000
         LA    R5,32                   Default length                   02930000
         CR    R4,R5                   Length longer than 32 ?          02940000
         BH    DMPDODMP                Yes, use 32                      02950000
         LR    R5,R4                   Use what is left                 02960000
DMPDODMP $TRC                                                           02970000
         SR    R4,R5                   Reduce amount to do              02980000
         MVI   W#LINE+89,C'*'          Box in display portion           02990000
         SH    R5,=H'+1'               Make zero based                  03000000
         EX    R5,DMPMVC               Do move                          03010000
         EX    R5,DMPTR                Translate out bad stuff          03020000
         LA    R5,1(,R5)               Restore length                   03030000
         MVI   W#LINE+122,C'*'         Complete box                     03040000
DMPDMPHX $TRC                                                           03050000
         LA    R15,4                   4 bytes to process               03060000
         CR    R5,R15                  Length longer than 4?            03070000
         BH    DMPDMPIT                Yes, dump 4 bytes                03080000
         LR    R15,R5                  Use length left                  03090000
DMPDMPIT $TRC                                                           03100000
         SR    R5,R15                  Reduce amount to do              03110000
         BAL   R14,DMPDSP              Convert data                     03120000
         LA    R2,1(,R2)               Skip 1 byte                      03130000
         LA    R0,W#LINE+45            Halfway point address            03140000
         CR    R0,R2                   At halfway point?                03150000
         BNE   DMPDMPNX                No, continue                     03160000
         LA    R2,1(,R2)               Skip 1 byte                      03170000
DMPDMPNX $TRC                                                           03180000
         LTR   R5,R5                   Any left to do ?                 03190000
         BH    DMPDMPHX                Yes, go do it                    03200000
         BAL   R14,PRT                 Print a line                     03210000
DMPNXTLN $TRC                                                           03220000
         L     R1,W#DMPOFF             Get offset in record             03230000
         LA    R1,32(,R1)              Add in length we will dump       03240000
         ST    R1,W#DMPOFF             Save offset in record            03250000
         LA    R3,32(,R3)              Next input area                  03260000
         NI    W#DMPFL,255-W#DMPFL1     not first line                  03270000
         B     DMPDMPLP                Loop thru until done             03280000
DMPHEXXT $TRC                                                           03290000
         LM    R0,R15,W#DMPRGS         Restore callers regs             03300000
         BR    R14                     Exit . . .                       03310000
DMPMVC   MVC   W#LINE+90(0),0(R1)      <<< executed >>>                 03320000
DMPTR    TR    W#LINE+90(0),P#DMPTBL   <<< executed >>>                 03330000
*                                                                       03340000
*        Convert hex data to display                                    03350000
*                                                                       03360000
DMPDSP   $TRC                                                           03370000
         UNPK  0(1,R2),0(1,R1)         Get first hex byte               03380000
         NI    0(R2),X'0F'             Remove zone                      03390000
         MVC   1(1,R2),0(R1)           Move second hex byte             03400000
         NI    1(R2),X'0F'             Remove its zone also             03410000
         TR    0(2,R2),=C'0123456789ABCDEF' Translate to hex            03420000
         LA    R2,2(,R2)               Point to next output area        03430000
         LA    R1,1(,R1)               Point to next input area         03440000
         BCT   R15,DMPDSP              Loop thru data                   03450000
         BR    R14                     Exit                             03460000
*********************************************************************** 03470000
*        CONSTANTS                                                    * 03480000
*********************************************************************** 03490000
P#DMPTBL DC    CL256' '                                                 03500000
         ORG   P#DMPTBL+X'4A' Cent                                      03510000
         DC    X'4A4B4C4D4E4F50'                                        03520000
         ORG   P#DMPTBL+X'5A' exclamation                               03530000
         DC    X'5A5B5C5D5E5F6061'                                      03540000
         ORG   P#DMPTBL+X'6A'                                           03550000
         DC    X'6A6B6C6D6E6F'                                          03560000
         ORG   P#DMPTBL+X'7A'                                           03570000
         DC    X'7A7B7C7D7E7F'                                          03580000
         ORG   P#DMPTBL+C'a'                                            03590000
         DC    C'abcdefghi'                                             03600000
         ORG   P#DMPTBL+C'j'                                            03610000
         DC    C'jklmnopqr'                                             03620000
         ORG   P#DMPTBL+C's'                                            03630000
         DC    C'stuvwxyz'                                              03640000
         ORG   P#DMPTBL+C'A'                                            03650000
         DC    C'ABCDEFGHI'                                             03660000
         ORG   P#DMPTBL+C'J'                                            03670000
         DC    C'JKLMNOPQR'                                             03680000
         ORG   P#DMPTBL+C'S'                                            03690000
         DC    C'STUVWXYZ'                                              03700000
         ORG   P#DMPTBL+C'0'                                            03710000
         DC    C'0123456789'                                            03720000
         ORG                                                            03730000
P#JULTBL DS    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  03740000
*                                                                       03750000
P#OPNLSB OPEN  (0,(OUTPUT)),MF=L                                        03760000
P#OPNLST EQU   P#OPNLSB,*-P#OPNLSB                                      03770000
*                                                                       03780000
P#OTDBB  DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,RECFM=FBA,LRECL=133    03790000
P#OTDCB  EQU   P#OTDBB,*-P#OTDBB                                        03800000
*                                                                       03810000
P#LINDBB DCB   DDNAME=SYSUT1,DSORG=PS,MACRF=GL,EODAD=LINEOF             03820000
P#LINDCB EQU   P#LINDBB,*-P#LINDBB                                      03830000
*                                                                       03840000
P#LINOLB OPEN (0,(OUTPUT)),MF=L                                         03850000
P#LINOLS EQU   P#LINOLB,*-P#LINOLB                                      03860000
*                                                                       03870000
P#WTORPB WTOR  'Pause',W#REPLY-W#REPLY,L'W#REPLY,W#ECB-W#ECB,MF=L       03880000
P#WTORP  EQU   P#WTORPB,*-P#WTORPB                                      03890000
*                                                                       03900000
         LTORG ,                                                        03910000
*********************************************************************** 03920000
*        WORK AREAS                                                   * 03930000
*********************************************************************** 03940000
W#       DSECT                                                          03950000
W#SA     DS    18A                                                      03960000
W#DMPRGS DS    16A                                                      03970000
W#DMPOFF DS    A                                                        03980000
W#DUP1ST DS    A                                                        03990000
W#DMPFL  DS    X                                                        04000000
W#DMPFL1 EQU   X'80'                                                    04010000
W#DMPDUP EQU   X'40'                                                    04020000
W#DWORD  DS    D                                                        04030000
W#INIT14 DS    A                                                        04040000
W#PRTR14 DS    A                                                        04050000
W#LINE   DS    CL133                                                    04060000
W#CURDTE DS    A                                                        04070000
W#JLWK1  DS    A                                                        04080000
W#JLWK2  DS    P'+365'                                                  04090000
W#JLWK13 DS    P'+01'                                                   04100000
W#JLWK12 DS    P'+31'                                                   04110000
W#JLWK11 DS    P'+30'                                                   04120000
W#JLWK10 DS    P'+31'                                                   04130000
W#JLWK09 DS    P'+30'                                                   04140000
W#JLWK08 DS    P'+31'                                                   04150000
W#JLWK07 DS    P'+31'                                                   04160000
W#JLWK06 DS    P'+30'                                                   04170000
W#JLWK05 DS    P'+31'                                                   04180000
W#JLWK04 DS    P'+30'                                                   04190000
W#JLWK03 DS    P'+31'                                                   04200000
W#JLWK02 DS    P'+28'                                                   04210000
W#JLWK01 DS    P'+31'                                                   04220000
W#TIMWRK DS    X'402021204B20204B20204B2020'                            04230000
W#LNCT   DS    PL2'+99'                                                 04240000
W#PGCT   DS    PL2'+0'                                                  04250000
W#HD1    DS    CL133                                                    04260000
         ORG   W#HD1+1                                                  04270000
W#HD1DTE DS    C'            '                                          04280000
         DS    C' '                                                     04290000
W#HD1TOD DS    C'HH:MM:SS'                                              04300000
         ORG   W#HD1+66-(20/2)                                          04310000
W#HD1TTL DS    C'I E W L   F R O N T'                                   04320000
         ORG   W#HD1+L'W#HD1-8                                          04330000
W#HD1PG  DS    C'Page'                                                  04340000
W#HD1PG# DS    C' 123'                                                  04350000
         DS    0D                                                       04360000
W#OPNLST DS    XL(L'P#OPNLST)                                           04370000
         DS    0D                                                       04380000
W#OTDCB  DS    XL(L'P#OTDCB)                                            04390000
*                                                                       04400000
*********************************************************************** 04410000
         DS    0D                                                       04420000
W#ECB    DS    A(0)                                                     04430000
*                                                                       04440000
         DS    0D                                                       04450000
W#REPLY  DS    CL32                                                     04460000
*                                                                       04470000
         DS    0D                                                       04480000
W#LINOLS DS    XL(L'P#LINOLS)                                           04490000
*                                                                       04500000
         DS    0D                                                       04510000
W#LINDCB DS    XL(L'P#LINDCB)                                           04520000
*                                                                       04530000
         DS    0D                                                       04540000
W#WTORP  DS    XL(L'P#WTORP)                                            04550000
*                                                                       04560000
         DS    0D                                                       04570000
W#HITFLG DS    C                                                        04580000
*                                                                       04590000
*********************************************************************** 04600000
         DS    0D                                                       04610000
W#LEN    EQU   *-W#                                                     04620000
*********************************************************************** 04630000
*                                                                     * 04640000
*********************************************************************** 04650000
          DCBD DSORG=PS                                                 04660000
*********************************************************************** 04670000
*                                                                     * 04680000
*********************************************************************** 04690000
R0       EQU   0                                                        04700000
R1       EQU   1                                                        04710000
R2       EQU   2                                                        04720000
R3       EQU   3                                                        04730000
R4       EQU   4                                                        04740000
R5       EQU   5                                                        04750000
R6       EQU   6                                                        04760000
R7       EQU   7                                                        04770000
R8       EQU   8                                                        04780000
R9       EQU   9                                                        04790000
R10      EQU   10                                                       04800000
R11      EQU   11                                                       04810000
R12      EQU   12                                                       04820000
R13      EQU   13                                                       04830000
R14      EQU   14                                                       04840000
R15      EQU   15                                                       04850000
         END   IEWLFRNT                                                 04860000
