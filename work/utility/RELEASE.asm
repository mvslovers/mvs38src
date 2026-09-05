*---------------------------------------------------------------------* 00010000
*                                                                     * 00020000
*  MODULE HISTORY                                                     * 00030000
*                                                                     * 00040000
*---------------------------------------------------------------------* 00050000
*  01/06/77 CHANGES TO CHECK IF ANY UNUSED SPACE CAN BE RELEASED      * 00060000
*           BEFORE OPENING AND CLOSING THE DATASET TO PREVENT         * 00070000
*           ALTERATION OF THE LAST ACCESSED DATE AND TO IMPROVE       * 00080000
*           EFFICIENCY.                                               * 00090000
* 04/04/78  MODIFY TO ALLOW CONTINUING AFTER A DSN NOT FOUND.         * 00100000
* 09/11/78  FIX DSN NOT FOUND MESSAGE.                                * 00110000
* 09/25/79  FIX FOR MVS AND DIFFERENT DEVICE TYPES.                   * 00120000
* 12/18/79  CORRECT DISPLACEMENT TO TRACKS PER CYL IN FMT-4           * 00130000
*---------------------------------------------------------------------* 00140000
*.....................................................................* 00150000
*.                                                                   .* 00160000
*.   RELEASE                                                         .* 00170000
*.                                                                   .* 00180000
*.....................................................................* 00190000
*.                                                                   .* 00200000
*.   1.0  GENERAL DESCRIPTION                                        .* 00210000
*.                                                                   .* 00220000
*.   THIS TSO COMMAND WILL RELEASE WASTED SPACE FOR THE SPECIFIED    .* 00230000
*.   DATASETS.  IT PERFORMS THIS FUNCTION BY DYNAMICALLY             .* 00240000
*.   ALLOCATING THE DATASET WITH DISP=MOD AND RELEASE SPECIFIED IN   .* 00250000
*.   THE DAIR PARAMETER BLOCK.  IT THEN OPENS AND CLOSES THE DATASET .* 00260000
*.   TO RELEASE THE WASTED SPACE.                                    .* 00270000
*.                                                                   .* 00280000
*.....................................................................* 00290000
*.                                                                   .* 00300000
*.....................................................................* 00310000
*.                                                                   .* 00320000
*.   2.0  COMMAND SYNTAX                                             .* 00330000
*.                                                                   .* 00340000
*.    RELEASE  (DSNAME-LIST)                                         .* 00350000
*.                                                                   .* 00360000
*.     (DSNAME-LIST)                                                 .* 00370000
*.         -  SPECIFIES A SINGLE DSNAME OR A LIST OF DSNAMES.        .* 00380000
*.            TSO DATASET NAMING CONVENTIONS APPLY FOR THE           .* 00390000
*.            DSNAME.                                                .* 00400000
*.                                                                   .* 00410000
*.....................................................................* 00420000
*.                                                                   .* 00430000
*.....................................................................* 00440000
*.                                                                   .* 00450000
*.   3.0  PROGRAM STRUCTURE                                          .* 00460000
*.                                                                   .* 00470000
*.                                                                   .* 00480000
*.   3.0.1  INITIALIZATION                                           .* 00490000
*.                                                                   .* 00500000
*.   THIS SECTION BUILDS THE PARAMETER LISTS FOR PARSE, DAIR,        .* 00510000
*.   AND LOCINDEX AND LINKS TO PARSE TO EXAMINE THE COMMAND          .* 00520000
*.   BUFFER.  IF NO DSNAMES ARE SPECIFIED, THE PROGRAM IS ENDED.     .* 00530000
*.                                                                   .* 00540000
*.                                                                   .* 00550000
*.   3.0.2  DSNAME VALIDATION                                        .* 00560000
*.                                                                   .* 00570000
*.   THIS SECTION EXAMINES THE DSNAME AND ADDS THE USERID IF         .* 00580000
*.   NECESSARY.  IT THEN 'LOCATE'S THE DSNAME.  IF THE DATASET       .* 00590000
*.   IS CATALOGED, IT LINKS TO THE RELEASE ROUTINE.  IF IT IS NOT    .* 00600000
*.   CATALOGED ERROR MESSAGE IS ISSUED.                              .* 00610000
*.                                                                   .* 00620000
*.                                                                   .* 00630000
*.   3.0.3  RELEASE ROUTINE                                          .* 00640000
*.                                                                   .* 00650000
*.   THIS ROUTINE DYNAMICALLY ALLOCATES THE DATASET TO AN            .* 00660000
*.   AVAILABLE DDNAME WITH DISP=MOD AND RELEASE SPECIFIED IN THE     .* 00670000
*.   DAIR PARAMETER BLOCK.  THE DATASET IS THEN OPENED AND CLOSED    .* 00680000
*.   TO RELEASE THE WASTED SPACE.  IT IS THEN FREED USING A LINK     .* 00690000
*.   TO THE DAIR FREE ROUTINE.                                       .* 00700000
*.                                                                   .* 00710000
*.....................................................................* 00720000
RELEASE  CSECT                                                          00730000
R0       EQU   0                                                        00740000
R1       EQU   1                                                        00750000
R2       EQU   2                                                        00760000
R3       EQU   3                                                        00770000
R4       EQU   4                                                        00780000
R5       EQU   5                                                        00790000
R6       EQU   6                                                        00800000
R7       EQU   7                                                        00810000
R8       EQU   8                                                        00820000
R9       EQU   9                                                        00830000
R10      EQU   10                                                       00840000
R11      EQU   11                                                       00850000
R12      EQU   12                                                       00860000
R13      EQU   13                                                       00870000
R14      EQU   14                                                       00880000
R15      EQU   15                                                       00890000
*********************************************************************** 00900000
*                                                                     * 00910000
*********************************************************************** 00920000
         USING RELEASE,R15                                              00930000
         B     START                   BYPASS PGMID                     00940000
         DROP  R15                                                      00950000
         DC    AL1(L'PGMID)            LENGTH OF PGMID                  00960000
PGMID    DC    C'RELEASE &SYSDATE &SYSTIME'                             00970000
START    DS    0H                                                       00980000
         STM   R14,R12,12(R13)                                          00990000
         LR    R12,R15                                                  01000000
         USING RELEASE,R12                                              01010000
         LR    R5,R1               SAVE ADDR OF CPPL                    01020000
         USING CPPL,R5                                                  01030000
         LA    R0,LWORK            GET LENGTH OF WORK AREA              01040000
         GETMAIN R,LV=(0)                                               01050000
         LR    R3,R13                                                   01060000
         LR    R13,R1                                                   01070000
         USING SAVE,R13                                                 01080000
         ST    R3,4(,R13)                                               01090000
         ST    R13,8(,R3)                                               01100000
         MVI   SW,0                                                     01110000
         MVC   CAMLSTNM(64),CAMMODEL                                    01120000
         LA    R0,LOCAREA          POINT TO LOCATE WORK AREA            01130000
         ST    R0,CAMLSTNM+12      STORE ADDR IN CAMLST                 01140000
         ST    R0,SRCHCAM+12                                            01150000
         ST    R0,SEEKCAM+12                                            01160000
         LA    R0,DEVWORK                                               01170000
         ST    R0,DEVCAM+12                                             01180000
         LA    R0,WDSN             POINT TO DSNAME                      01190000
         ST    R0,CAMLSTNM+4                                            01200000
         ST    R0,SRCHCAM+4                                             01210000
         LA    R0,VTOCCHHR                                              01220000
         ST    R0,SEEKCAM+4                                             01230000
         LA    R0,DEVICE                                                01240000
         ST    R0,DEVCAM+4                                              01250000
         LA    R0,WVOLSER          POINT TO VOLSER AREA                 01260000
         ST    R0,SRCHCAM+8                                             01270000
         ST    R0,SEEKCAM+8                                             01280000
         ST    R0,DEVCAM+8                                              01290000
         LA    R3,WDAPL            GET ADDR OF DAPL                     01300000
         USING DAPL,R3                                                  01310000
         LA    R4,WPPL             GET ADDR OF PPL                      01320000
         USING PPL,R4                                                   01330000
         L     R0,CPPLCBUF                                              01340000
         ST    R0,PPLCBUF                                               01350000
         L     R0,CPPLUPT                                               01360000
         ST    R0,DAPLUPT                                               01370000
         ST    R0,PPLUPT                                                01380000
         L     R0,CPPLPSCB                                              01390000
         ST    R0,DAPLPSCB                                              01400000
         LR    R11,R0              SAVE ADDR OF USERID                  01410000
         USING PSCB,R11                                                 01420000
         SR    R0,R0                                                    01430000
         IC    R0,PSCBUSRL        SAVE LENGTH OF USERID                 01440000
         BCTR  R0,0                                                     01450000
         ST    R0,USRLN                                                 01460000
         L     R0,CPPLECT                                               01470000
         ST    R0,DAPLECT                                               01480000
         ST    R0,PPLECT                                                01490000
         LA    R0,CPECB                                                 01500000
         ST    R0,DAPLECB                                               01510000
         ST    R0,PPLECB                                                01520000
         XC    CPECB,CPECB                                              01530000
         L     R0,=A(PARSLIST)                                          01540000
         ST    R0,PPLPCL                                                01550000
         LA    R0,WPDL                                                  01560000
         ST    R0,PPLANS                                                01570000
         XC    PPLUWA,PPLUWA                                            01580000
         LR    R1,R4                                                    01590000
         LINK  EP=IKJPARS          LINK TO PARSE SERVICE ROUTINE        01600000
         LTR   R15,R15             PARSE ERROR?                         01610000
         BNZ   EOJ                  YES                                 01620000
         TM    PPLANS,X'FF'        PARSE ERROR?                         01630000
         BO    EOJ                  YES                                 01640000
         DROP  R4,R5                                                    01650000
         L     R4,WPDL             GET ADDR OF PDL                      01660000
         USING IKJPARMD,R4                                              01670000
         LA    R6,DSNLIST          GET ADDR OF DSNAME LIST              01680000
         TM    6(R6),X'80'         DSNAME SPECIFIED?                    01690000
         BZ    EOJ                  NO                                  01700000
         LA    R0,44                                                    01710000
         STH   R0,WDSNL            STORE LENGTH OF DSN BUFFER           01720000
*********************************************************************** 01730000
*                                                                     * 01740000
*********************************************************************** 01750000
GETDSNAM L     R7,0(,R6)           GET ADDR OF DSNAME                   01760000
         LH    R8,4(,R6)           GET LENGTH OF DSNAME                 01770000
         BCTR  R8,0                                                     01780000
         LA    R9,WDSN            POINT TO AREA TO MOVE DSNAME          01790000
         MVI   WDSN,C' '           BLANK DSN WORK AREA                  01800000
         MVC   WDSN+1(L'WDSN-1),WDSN                                    01810000
         TM    6(R6),X'40'         IS DSN CONTAINED IN QUOTES           01820000
         BO    MOVENAME             YES                                 01830000
         L     R1,USRLN                                                 01840000
         EX    R1,MVCUSRID         MOVE USERID TO DSN WORK AREA         01850000
         AR    R9,R1               BUMP PAST USERID                     01860000
         MVI   1(R9),C'.'          MOVE PERIOD TO DSN                   01870000
         LA    R9,2(,R9)           BUMP PAST                            01880000
MOVENAME EX    R8,MVCNAME          MOVE DSNAME TO WORK AREA             01890000
LOCDSN   LOCATE CAMLSTNM           LOCATE DSNAME                        01900000
         LTR   R15,R15             FOUND IT?                            01910000
         BNZ   NOTCTLG              NO, NOT CATALOGED                   01920000
         CLC   =C'SYSCTLG',WDSN    CHECK IF A CATLOG                    01930000
         BE    ACATLG              YES, ERROR                           01940000
         TM    LOCAREA+1,X'FE'     MULTIVOLUME DATASET                  01950000
         BM    MULTIVOL             YES                                 01960000
         CLI   LOCAREA+4,X'80'     DATASET ON TAPE?                     01970000
         BE    TAPEDSN              YES                                 01980000
         MVC   WVOLSER,LOCAREA+6      SAVE VOLSER                       01990000
         BAL   R9,VRLSE                                                 02000000
NEXTNAME L     R6,24(,R6)          GET POINTER TO NEXT DSNAME LIST      02010000
         C     R6,=X'FF000000'     END OF LIST                          02020000
         BE    EOJ                  YES                                 02030000
         B     GETDSNAM                                                 02040000
NOTCTLG  DS    0H   DSN NOT IN CATALOG                                  02050000
         BAL   R10,NOTFOUND   NASTY MESSAGE                             02060000
         B     NEXTNAME       TRY FOR SOME MORE                         02070000
*********************************************************************** 02080000
*                                                                     * 02090000
*********************************************************************** 02100000
ACATLG   DS    0H                                                       02110000
         MVI   MSG,C' '                                                 02120000
         MVC   MSG+1(L'MSG-1),MSG                                       02130000
         MVC   MSG(L'CTLGMSG),CTLGMSG                                   02140000
         MVC   MSG+L'CTLGMSG(44),WDSN                                   02150000
         LA    R0,L'MSG                                                 02160000
         LA    R1,MSG                                                   02170000
         SVC   93                                                       02180000
         B     NEXTNAME                                                 02190000
MULTIVOL DS    0H                                                       02200000
         MVI   MSG,C' '                                                 02210000
         MVC   MSG+1(L'MSG-1),MSG                                       02220000
         MVC   MSG(L'MULTIMSG),MULTIMSG                                 02230000
         MVC   MSG+L'MULTIMSG(44),WDSN                                  02240000
         LA    R0,L'MSG                                                 02250000
         LA    R1,MSG                                                   02260000
         SVC   93                                                       02270000
         B     NEXTNAME                                                 02280000
TAPEDSN  DS    0H                                                       02290000
         MVI   MSG,C' '                                                 02300000
         MVC   MSG+1(L'MSG-1),MSG                                       02310000
         MVC   MSG(L'TAPEMSG),TAPEMSG                                   02320000
         MVC   MSG+L'TAPEMSG(44),WDSN                                   02330000
         LA    R0,L'MSG                                                 02340000
         LA    R1,MSG                                                   02350000
         SVC   93                                                       02360000
         B     NEXTNAME                                                 02370000
VRLSE    DS    0H                                                       02380000
         OBTAIN DEVCAM                 GET FORMAT-4                     02390000
         LTR   R15,R15                 ANY ERRORS LIKE NOT MOUNTED      02400000
         BNZ   NOFMT4                  PROBIBLY.                        02410000
         CLI   DEVWORK,C'4'            WAS IT A REAL FORMAT-4           02420000
         BNE   NOFMT4                  WE HAVE PROBLEMS......           02430000
         OBTAIN SRCHCAM                 GET THE FORMAT-1                02440000
         LTR   R15,R15                                                  02450000
         BNZ   NOFMT1                   SOMETHING ALWAYS GOES RONG      02460000
         CLI   LOCAREA,C'1'             WAS IT A FORMAT-1               02470000
         BNE   NOFMT1                   GOOFED SOMEWHERE                02480000
         TM    LOCAREA+82-44,X'42'      IS DSORG PS OR PO               02490000
         BZ    BADDSORG                 NO - CANT RELEASE               02500000
         MVC   F1ALLOC,LOCAREA+94-44    SAVE ALLOCATION TYPE            02510000
         LA    R7,XTNTS                 POINT TO EXTENTS TABLE          02520000
         LH    R5,LOCAREA+98-44         LAST BLOCK POINTER              02530000
         CLI   LOCAREA+100-44,X'00'     R OF LAST TTR UNUSED Q          02540000
         BE    VXTNC                    YES                             02550000
         LA    R5,1(,R5)                ELSE COUNT ANOTHER TRACK        02560000
VXTNC    STH   R5,LASTTRK               SAVE LAST TRACK USED            02570000
         SR    R8,R8                                                    02580000
         IC    R8,LOCAREA+59-44         NR OF EXTENTS                   02590000
         SR    R4,R4                    TRACK ACCUMULATOR               02600000
         LA    R11,1                    EXTENT COUNTER                  02610000
         LTR   R8,R8                    ANY EXTENTS Q                   02620000
         BZR   R9                       NO EXTENTS - NO RELEASE         02630000
         LA    R10,LOCAREA+105-44          POINT TO FIRST EXTENT        02640000
VXTLOOP  DS    0H   LOOP THRU ACCUMULATING INFORMATION                  02650000
         MVC   0(10,R7),0(R10)          SAVE EXTENT INFO                02660000
         LA    R7,10(,R7)               BUMP EXTENT TABLE TO NEXT SLOT  02670000
         MVC   DBLWRD(2),6(R10)         HI-CYL                          02680000
         LH    R0,DBLWRD                                                02690000
         MVC   DBLWRD(2),8(R10)         HI-TRK                          02700000
         LH    R1,DBLWRD                                                02710000
         MVC   DBLWRD(2),2(R10)         LO-CYL                          02720000
         SH    R0,DBLWRD                                                02730000
         MVC   DBLWRD(2),4(R10)         LO-TRK                          02740000
         SH    R1,DBLWRD                                                02750000
         MH    R0,DEVTPERC              MAKE TRACKS                     02760000
         AR    R1,R0                    TRACKS IN THIS EXTENT           02770000
         LA    R4,1(R1,R4)              ACCUMULATE FOR GRAND TOTAL      02780000
         CR    R11,R8                   DONE LAST EXTENT Q              02790000
         BE    VTOTAL                   YES                             02800000
         LA    R11,1(,R11)              BUMP EXTENT COUNTER             02810000
         CH    R3,=H'4'                 FOURTH EXTENT                   02820000
         BE    VXT4                     YES - GO ADJUST                 02830000
         CH    R11,=H'8'                EIGHTH EXTENT Q                 02840000
         BE    VXT8                     YES - GO GET A FORMAT-3         02850000
         LA    R10,10(,R10)             BUMP TO NEXT EXTENT             02860000
         B     VXTLOOP                  CONTINUE ACCUMULATING           02870000
VXT4     DS    0H                                                       02880000
         MVC   VTOCCHHR(5),LOCAREA+91   POINT TO NEXT DSCB (F2 OR F3)   02890000
VXT4OBT  OBTAIN SEEKCAM                 GET A FORMAT-2 OR FORMAT-3      02900000
         CLI   LOCAREA+44,C'3'          FORMAT 3                        02910000
         BE    VXT4F3                   YES                             02920000
         MVC   VTOCCHHR(5),LOCAREA+145  MUST BE F2 - POINT TO F3        02930000
         B     VXT4OBT                  GO GET F3                       02940000
VXT4F3   DS    0H   FOUND A FORMAT 3                                    02950000
         LA    R10,LOCAREA+4            POINT TO FIRST EXTENT IN F3     02960000
         B     VXTLOOP                  KEEP ACCUMULATING               02970000
VXT8     DS    0H   EIGHTH EXTENT IN F3                                 02980000
         LA    R10,LOCAREA+45           SKIP X'F3' IN F3 DSCB           02990000
         B     VXTLOOP                  KEEP ACCUMULATING               03000000
VTOTAL   DS    0H   COMPUTE UNUSED SPACE                                03010000
         LH    R5,LASTTRK               GET LAST TT                     03020000
         SR    R4,R5                    GIVES UNUSED SPACE              03030000
         NI    F1ALLOC,X'C0'            MASK OUT BITS FROM ALLOCATION   03040000
         CLI   F1ALLOC,X'C0'            ALLOCATED BY CYLINDER Q         03050000
         BE    VXCYL                    YES - SEE IF A CYLINDER FREE    03060000
         LTR   R4,R4                    ANY UNUSED SPACE                03070000
         BNPR  R9                       NO UNUSED - NO RELEASE          03080000
         B     VALLOC                   GO DO YOUR THING                03090000
VXCYL    DS    0H   ALLOCATED BY CYLINDER                               03100000
         CH    R4,DEVTPERC              IS THERE A FREE CYLINDER Q      03110000
         BLR   R9                       NO FREE CYL - NO RELEASE        03120000
VALLOC   DS    0H   ALLOCATE THE DATASET TO BE RELEASED                 03130000
         LA    R7,WDA08            POINT TO DA08 BLOCK - ALLOCATE       03140000
         USING DAPB08,R7                                                03150000
         MVC   0(DAPB08L,R7),DA08MODL MOVE DA08 MODEL TO DAPB08         03160000
         LA    R0,WDSNL                                                 03170000
         ST    R0,DA08PDSN                                              03180000
         ST    R7,DAPLDAPB         STORE ADDR OF DAPB08 IN DAPL         03190000
LINKDAIR LR    R1,R3                                                    03200000
         LINK  EP=IKJDAIR          LINK TO DAIR SERVICE ROUTINE         03210000
         LTR   R15,R15             ALLOCATION ERROR?                    03220000
         BNZ   ALLOCERR             YES                                 03230000
         MVC   SYSRLSE,MDLDCB                                           03240000
         MVC   RLSEDSO(1),DA08DSO  MOVE DSORG TO DCB                    03250000
         MVC   RLSEDDN(8),DA08DDN  MOVE DDNAME TO DCB                   03260000
         DROP  R7                                                       03270000
         MVC   OCMF,MDLOCMF                                             03280000
         OPEN  (SYSRLSE,(OUTPUT)),MF=(E,OCMF)                           03290000
         CLOSE SYSRLSE,MF=(E,OCMF) RELEASE WASTED SPACE                 03300000
FREEIT   LA    R7,WDA18            GET ADDR OF DAPB18 - FREE BLOCK      03310000
         USING DAPB18,R7                                                03320000
         ST    R7,DAPLDAPB         STORE ADDR OF DAPB18 IN DAPL         03330000
         MVC   DAPB18(DAPB18L),DA18MODL BUILD DAPB18                    03340000
         MVC   DA18DDN(8),RLSEDDN                                       03350000
         LR    R1,R3                                                    03360000
         LINK  EP=IKJDAIR          LINK TO DAIR                         03370000
         DROP  R7                                                       03380000
         BR    R9                                                       03390000
*********************************************************************** 03400000
*                                                                     * 03410000
*********************************************************************** 03420000
NOFMT4   DS    0H     CANT FIND FORMAT 4 DSCB                           03430000
         BAL   R10,ALLOCERR            TELL EM ITS ALLOCATION ERR       03440000
         BR    R9                      AND LOOP FOR SOME MORE           03450000
*********************************************************************** 03460000
*                                                                     * 03470000
*********************************************************************** 03480000
NOFMT1   DS    0H   CANT FIND FORMAT 1 DSCB                             03490000
         BAL   R10,NOTFOUND   NASTY MESSAGE FOR USER                    03500000
         BR    R9             LOOP FOR SOME MORE                        03510000
*********************************************************************** 03520000
*                                                                     * 03530000
*********************************************************************** 03540000
BADDSORG OI    SW,X'80'                                                 03550000
ALLOCERR CH    R15,=H'16'                                               03560000
         BE    NOTIOT                                                   03570000
         MVI   MSG,X'40'                                                03580000
         MVC   MSG+1(71),MSG                                            03590000
         MVC   MSG(L'ALLOCMSG),ALLOCMSG                                 03600000
         MVC   MSG+L'ALLOCMSG(44),WDSN                                  03610000
         LA    R0,L'ALLOCMSG+44                                         03620000
         LA    R1,MSG                                                   03630000
         SVC   93                                                       03640000
         TM    SW,X'80'                                                 03650000
         BZR   R9                                                       03660000
         NI    SW,X'7F'                                                 03670000
         B     FREEIT                                                   03680000
NOTIOT   LA    R0,L'TIOTMSG                                             03690000
         LA    R1,TIOTMSG                                               03700000
         SVC   93                                                       03710000
         B     EOJ                                                      03720000
*********************************************************************** 03730000
*                                                                     * 03740000
*********************************************************************** 03750000
NOTFOUND DS    0H  CANT FIND IT BUB                                     03760000
         MVI   MSG,X'40'                                                03770000
         MVC   MSG+1(71),MSG                                            03780000
         MVC   MSG(L'FINDMSG),FINDMSG                                   03790000
         MVC   MSG+L'FINDMSG(44),WDSN                                   03800000
         LA    R0,L'MSG                                                 03810000
         LA    R1,MSG                                                   03820000
         SVC   93                                                       03830000
         BR    R10          RETURN TO CALLER                            03840000
*********************************************************************** 03850000
*                                                                     * 03860000
*********************************************************************** 03870000
EOJ      DS    0H                                                       03880000
         LR    R1,R13                                                   03890000
         L     R13,4(,R13)                                              03900000
         LA    R0,LWORK            GET LENGTH OF WORK AREA              03910000
         FREEMAIN R,A=(1),LV=(0)   FREE WORK AREA                       03920000
         LM    R14,R12,12(R13)                                          03930000
         SR    R15,R15                                                  03940000
         BR    R14                                                      03950000
MVCUSRID MVC   0(0,R9),0(R11)                                           03960000
MVCNAME  MVC   0(0,R9),0(R7)                                            03970000
*********************************************************************** 03980000
*                                                                     * 03990000
*********************************************************************** 04000000
         LTORG                                                          04010000
DEVICE   DC    44XL1'04'           DEV                                  04020000
ALLOCMSG DC    C'UNABLE TO RELEASE - '                                  04030000
TIOTMSG  DC    C'TOO MANY DATASETS ALLOCATED - USE FREE'                04040000
FINDMSG  DC    C'DSNAME NOT FOUND - '                                   04050000
CTLGMSG  DC    C'DSNAME A CATALOG - '                                   04060000
MULTIMSG DC    C'DSNAME MULTI-VOL - '                                   04070000
TAPEMSG  DC    C'DSNAME TAPE - '                                        04080000
*                                                                       04090000
DA08MODL DS    0F                                                       04100000
D8CD     DC    XL2'0008'           ALLOCATE                             04110000
D8FLG    DC    XL2'0000'                                                04120000
D8DARC   DC    XL2'0000'                                                04130000
D8CTRC   DC    XL2'0000'                                                04140000
D8PDSN   DC    A(0)          DSNAME BUFFER                              04150000
D8DDN    DC    CL8' '                                                   04160000
D8UNIT   DC    CL8' '                                                   04170000
D8SER    DC    CL8' '                                                   04180000
D8BLK    DC    F'0'                                                     04190000
D8PQTY   DC    F'0'                                                     04200000
D8SQTY   DC    F'0'                                                     04210000
D8DQTY   DC    F'0'                                                     04220000
D8MNM    DC    CL8' '                                                   04230000
D8PSWD   DC    CL8' '                                                   04240000
D8DSP1   DC    X'02'               MOD                                  04250000
D8DSP2   DC    X'08'               KEEP                                 04260000
D8DSP3   DC    X'08'               KEEP                                 04270000
D8CTL    DC    X'10'               RLSE                                 04280000
         DC    XL3'000000'                                              04290000
D8DSO    DC    X'00'                                                    04300000
D8ALN    DC    CL8' '                                                   04310000
*                                                                       04320000
DA18MODL DS    0F                                                       04330000
D18CD    DC    XL2'0018'           FREE                                 04340000
D18FLG   DC    H'0'                                                     04350000
D18DARC  DC    H'0'                                                     04360000
D18CTRC  DC    H'0'                                                     04370000
D18PDSN  DC    A(0)          DSNAME BUFFER                              04380000
D18DDN   DC    XL8'00'                                                  04390000
D18MNM   DC    CL8' '                                                   04400000
D18SCLS  DC    CL2' '                                                   04410000
D18DSP2  DC    X'08'               KEEP                                 04420000
D18CTL   DC    X'00'                                                    04430000
D18JBNM  DC    CL8' '                                                   04440000
*                                                                       04450000
CAMMODEL CAMLST NAME,*-*,,*-*            SEARCH CATALOG                 04460000
         CAMLST SEARCH,*-*,*-*,*-*       SEARCH FOR FORMAT-1            04470000
         CAMLST SEEK,*-*,*-*,*-*         SEEK FORMAT-2 OR FORMAT-3      04480000
         CAMLST SEARCH,*-*,*-*,*-*       SEARCH FOR FORMAT-4            04490000
*                                                                       04491000
MDLOCMF  OPEN  (0,(OUTPUT)),MF=L                                        04500000
MDLDCB   DCB   DSORG=PS,MACRF=WC,DDNAME=SYSRLSE                         04510000
*********************************************************************** 04520000
*                                                                     * 04530000
*********************************************************************** 04540000
PARSLIST IKJPARM                                                        04550000
DSNLIST  IKJPOSIT DSTHING,LIST                                          04560000
         IKJENDP                                                        04570000
*********************************************************************** 04580000
*                                                                     * 04590000
*********************************************************************** 04600000
WORKAREA DSECT                                                          04610000
SAVE     DS    18F                                                      04620000
DBLWRD   DS    D                                                        04630000
WPPL     DS    7A                  PPL                                  04640000
WDAPL    DS    5A                  DAPL                                 04650000
CPECB    DS    F                   ECB                                  04660000
WPDL     DS    F                   PDL                                  04670000
WDA08    DS    21F                 DAIR 08 BLOCK - ALLOCATE             04680000
WDA18    DS    10F                 DAIR 18 BLOCK - FREE                 04690000
CAMLSTNM DS    4F                  SEARCH CATALOG                       04700000
SRCHCAM  DS    4F                  SEARCH ON DSNAME                     04710000
SEEKCAM  DS    4F                  SEEK BY CCHHR                        04720000
DEVCAM   DS    4F                      SEEK DEVICE STATS                04730000
*                                                                       04740000
DEVWORK  DS    CL20                    SKIP THIS AREA                   04750000
DEVTPERC DS    H                       DEVICE TRACKS PER CYLINDER       04760000
         DS    CL118                   OVERFLOW AREA                    04770000
*                                                                       04780000
XTNTS    DS    16XL10              EXTENT TABLE                         04790000
LASTTRK  DS    H                   LAST TRACK OF DS USED                04800000
VTOCCHHR DS    XL5                       SEEK FOR F-1 OR F2             04810000
F1ALLOC  DS    C                        TYPE OF ALLOCATION              04820000
*                                                                       04830000
WINDEX   DS    CL44                                                     04840000
         DS    0F                                                       04850000
WDSNL    DS    H'44'                                                    04860000
WDSN     DS    CL44                DSNAME                               04870000
WVOLSER  DS    CL6                                                      04880000
         DS    0D                                                       04890000
LOCAREA  DS    265C                                                     04900000
*                                                                       04910000
OCMFPR   OPEN  (SYSRLSE,(OUTPUT)),MF=L                                  04920000
OCMF     EQU   OCMFPR,*-OCMFPR                                          04930000
*                                                                       04940000
SYSRLDCB DCB   DSORG=PS,MACRF=WC,DDNAME=SYSRLSE                         04950000
SYSRLSE  EQU   SYSRLDCB,*-SYSRLDCB                                      04960000
RLSEDDN  EQU   SYSRLSE+40                                               04970000
RLSEDSO  EQU   SYSRLSE+26                                               04980000
*                                                                       04990000
USRLN    DS    F                                                        05000000
MSG      DS    CL72                                                     05010000
SW       DS    X                                                        05020000
         DS    0D                                                       05030000
LWORK    EQU   *-WORKAREA                                               05040000
*********************************************************************** 05050000
*                                                                     * 05060000
*********************************************************************** 05070000
         IKJCPPL                                                        05080000
         IKJPPL                                                         05090000
         IKJPSCB                                                        05100000
         IKJDAPL                                                        05110000
         IKJDAP08                                                       05120000
DAPB08L  EQU   *-DAPB08                                                 05130000
         IKJDAP18                                                       05140000
DAPB18L  EQU   *-DAPB18                                                 05150000
         END                                                            05160000
