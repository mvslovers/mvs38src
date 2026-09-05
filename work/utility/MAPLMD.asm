*********************************************************************** 00010000
*                                                                     * 00020000
* MODULE NAME                                                         * 00030000
*    MAPLMD                                                           * 00040002
*                                                                     * 00050000
* ATTRIBUTES                                                          * 00060000
*    RENT                                                             * 00070002
*                                                                     * 00080000
* AUTHOR                                                              * 00090000
*    DAVE KREISS                                                      * 00100002
*                                                                     * 00110000
* FUNCTION                                                            * 00120002
*    LOADS A TABLE OF ALL CSECTS INCLUDING PRIVATE CSECTS.            * 00130002
*    IT CAN BE EXECUTED VIA JCL BUT IT'S REAL PURPOSE IS IN CREATING  * 00140002
*    A LIST OF CSECTS IN A LOAD MODULE.                               * 00150002
*                                                                     * 00160000
*    THIS CODE IS A DERIVITIVE FROM THE DISASSEMBLER ON THE CBT       * 00170002
*    TAPE WEB SITE FILE 217.  THE ORIGINAL AUTHOR WAS R THORNTON.     * 00180002
*                                                                     * 00190000
* JCL                                                                 * 00200002
*    //        EXEC PGM=MAPLMD,PARM='parameters'                      * 00210002
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00220002
*    //PRINTDD  DD  SYSOUT=*                                          * 00230003
*    //xxxxxxxx DD  DSN=load library,DISP=SHR                         * 00240002
*                                                                     * 00250000
* DD STATEMENTS                                                       * 00260002
*    STEPLIB       LOAD LIBRARY AINING THE MODULE MAPLMD.             * 00270002
*    PRINTDD       DATA SET CONTAINING EITHER SUMMARY OR DETAIL       * 00280002
*                  INFORMATION.  SEE PARM=OPTION BELOW.               * 00290004
*                  THIS DD IS OPTIONAL.                               * 00300003
*    xxxxxxxx      DATA SET CONTAINING THE LOAD MODULE WHOSE          * 00310002
*                  CSECT IS TO BE LOADED.  xxxxxxxx IS ANY NAME       * 00320002
*                  AS SPECIFIED IN LIB=.  THE DEFAULT IS SYSLIB.      * 00330002
*                                                                     * 00340000
* PARAMETERS                                                          * 00350002
*    ALL PARAMETERS ARE SEPERATED BY COMMAS.                          * 00360002
*    1ST PARAMETER LOAD MODULE NAME                                   * 00370002
*    LIB=xxxxxxxx  DD FOR DATA SET CONTAINING THE LOAD MODULE         * 00380002
*                  THE DEFAULT DD NAME IS SYSLIB.                     * 00390002
*    OPTION=       OPTION CAN BE DETAIL OR SUMMARY.                   * 00400002
*      DETAIL      GIVES DETAIL INFO ABOUT LOAD MODULE AND CSECT.     * 00410002
*                  THIS IS DEFAULT IF NO OPTION.                      * 00420002
*      SUMMARY     SUMMARY ONLY INFO ABOUT CSECT AND LOAD MODULE.     * 00430002
*                                                                     * 00440000
* SAMPLE JCL                                                          * 00450002
*    THIS SAMPLE LOADS INTO MEMORY THE CSECT ESRTABLE LOCATED IN      * 00460002
*    IEANUC01 FROM DDNAME NUC.  SUMMARY INFORMATION IS PRINTED        * 00470002
*    ON THE PRINTDD DD STATEMENT.                                     * 00480002
*    //LOAD    EXEC PGM=MAPLMD,PARM=('IEANUC01',                      * 00490002
*    //             'LIB=NUC,OPTION=SUMMARY')                         * 00500002
*    //STEPLIB  DD  DSN=HERC01.LOAD,DISP=SHR                          * 00510002
*    //PRINTDD  DD  SYSOUT=*                                          * 00520002
*    //NUC      DD  DSN=SYS1.NUCLEUS,DISP=SHR                         * 00530002
*                                                                     * 00540000
* SAMPLE OUTPUT                                                       * 00550002
*    LMOD=IEANUC01 LIB=NUC      OPTION=SUMMARY                        * 00560002
*    Directory info for module IEANUC01                               * 00570002
*              TTR of module=002223                                   * 00580002
*              Concatenation=00                                       * 00590002
*              Alias indicator=52                                     * 00600002
*              TTR of 1st TXT record=002431                           * 00610002
*              TTR of NOTE/Scatter list=00242C                        * 00620002
*              Number NOTE entries=00                                 * 00630002
*              Attributes #1=06C2 SCTR EXEC                           * 00640002
*              Total length=083588                                    * 00650002
*              Length of 1st TXT record=17C8                          * 00660002
*              EPA=004FC0                                             * 00670002
*              Attributes #2=9800 SSI APF                             * 00680002
*              SCTR length=04E8                                       * 00690002
*              Translate table length=08DC                            * 00700002
*              ESD ID of 1st TXT=001A                                 * 00710002
*              ESD ID containing EPA=0059                             * 00720002
*              SSI info=60700187                                      * 00730002
*              Auth code=00                                           * 00740002
*                                                                     * 00750009
* RETURN CODE                                                         * 00760009
*    Return code 0=Successful build of map                            * 00770009
*                  R0=Size of load module                             * 00780009
*                  R1=Address of map structure                        * 00790009
*    Return code 8=Errors detected                                    * 00800009
*                  R0=Error code (message also in PRINTDD)            * 00810009
*                     1=Parameter error                               * 00820009
*                     2=Member name not specified                     * 00830009
*                     3=Member not found in DD                        * 00840009
*                     4=Symbol table full: over 5000 entries          * 00850009
*                     5=Module has no text                            * 00860010
*                     6=Module has no symbols                         * 00870011
*                     7=Unknown control record                        * 00880011
*    Return code 16=LIB= DD statement not present                     * 00890009
*                                                                     * 00900009
* Map structure returned                                              * 00910009
*    First word is size of this structure including size.             * 00920009
*    Size is followed by multiple CSECT entries:                      * 00930009
*           CSECT name   8 bytes                                      * 00940009
*           CSECT length 3 bytes                                      * 00950009
*           CSECT offset 3 bytes                                      * 00960009
*                                                                     * 00970009
*********************************************************************** 00980000
*                                                                     * 00990000
* CHANGE LOG:                                                         * 01000000
*   DATE     AAA VV.VV DESCRIPTION                                    * 01010000
* 06/06/2015 DSK 01.01 CREATED                                        * 01020000
* 05/13/2016 DSK 01.02 Issue message when LIB DD missing              * 01030005
* 05/28/2016 DSK 01.03 Add CSECT address to returned information      * 01040006
* 03/04/2017 DSK 01.04 Handle null load module                        * 01050007
* 06/11/2021 DSK 01.05 SYNAD on SYSLIB                                * 01060008
* 01/04/2023 DSK 01.06 Fix loop if LIB= DD missing, R0=error code     * 01070009
* 07/02/2023 DSK 01.07 Handle module with no symbols and no text      * 01080010
         LCLC   &VER                                                    01090000
&VER     SETC   '01.07'                                                 01100010
*                                                                     * 01110000
*********************************************************************** 01120000
MAPLMD   CSECT ,                                                        01130000
****************************************************************        01140000
*                                                              *        01150000
*   PROGRAM INITIALIZATION                                     *        01160000
*                                                              *        01170000
****************************************************************        01180000
         USING MAPLMD,R15                                               01190000
         B     BEGIN                   BYPASS PROGRAM ID                01200000
         DROP  R15                                                      01210000
         DC    AL1(L'PGMID)            PROGRAM ID LENGTH                01220000
PGMID    DC    C'MAPLMD - &VER &SYSDATE &SYSTIME'                       01230000
BEGIN    DC    0H'+0'                                                   01240000
         USING MAPLMD,R3,R4                                             01250000
         STM   R14,R12,12(R13)         STORE REGS IN HIGH SAVE AREA     01260000
         LR    R12,R1                  PARAMETERS ADDRESS               01270000
         LR    R3,R15                  INITIALIZE BASE REG              01280000
         LA    R4,4095(,R3)            INITIALIZE THE SECOND            01290000
         LA    R4,1(,R4)               BASE REGISTER                    01300000
****************************************************************        01310000
*                                                              *        01320000
*        INITIALIZE WORK AREA                                  *        01330000
*                                                              *        01340000
****************************************************************        01350000
         GETMAIN R,LV=WORKLEN          GET WORK AREA                    01360000
         LR    R9,R1                   SAVE WORK AREA ADDRESS           01370000
         LR    R14,R1                  SET UP                           01380000
         LA    R15,WORKLEN              UP                              01390000
         SR    R1,R1                     MVCL                           01400000
         MVCL  R14,R0                  CLEAR WORK AREA                  01410000
         ST    R9,8(,R13)              STORE LOW SAVE POINTER           01420000
         ST    R13,4(,R9)              STORE HIGH SAVE POINTER          01430000
         LR    R13,R9                  INITIALIZE SAVE POINTER          01440000
         USING WORKAREA,R13                                             01450000
         MVC   MEMBER,BLANX            * WORKAREA                       01460000
         ZAP   LINECT,=P'+99'          *                             07 01470011
         ZAP   W#PGCT,=P'+0'           *                             07 01480011
         MVI   PCC,C'1'                *                                01490000
         MVC   PRT,BLANX               *                                01500000
         MVC   W#HD1,BLANX             *                             07 01510011
         MVC   W#HD1TTL,=C'Map Load Module'                          07 01520011
         MVC   W#HD1PG,=C'Page'        *                             07 01530011
         MVC   BLDLNO,=H'1'            *                                01540000
         MVC   BLDLLEN,=H'58'          *                                01550000
         MVC   ENDSYM,=F'95000'        *                                01560000
         MVC   LIBDDN,=CL8'SYSLIB'     *                                01570000
         MVC   PRINTDCB,PRINTMDL       *                                01580000
         MVC   LIBDCB,LIBMDL           *                                01590000
         MVC   OPNLST,OPNMDL           *                                01600000
****************************************************************        01610000
*                                                              *        01620000
*        OPEN PRINT FILE                                       *        01630000
*                                                              *        01640000
****************************************************************        01650000
         DEVTYPE =CL8'PRINTDD',DEVTYPE DETECT IF PRINTDD IS PRESENT     01660000
         LTR   R15,R15                 IS PRINTDD PRESENT?              01670000
         BNZ   SKPOPN                  NO, SKIP OPEN                    01680000
         OPEN  (PRINTDD,(OUTPUT)),MF=(E,OPENLIST) OPEN PRINTDD          01690000
SKPOPN   DS    0H                                                       01700000
****************************************************************        01710000
*                                                              *        01720000
*        PROCESS THE PARM CONTAINING MODULE NAME AND OPTIONS   *        01730000
*                                                              *        01740000
****************************************************************        01750000
         L     R1,0(,R12)              GET PARM FIELD ADDRESS           01760000
         SR    R12,R12                 CLEAR LENGTH                     01770000
         ICM   R12,3,0(R1)             PICK UP PARM LENGTH              01780000
         BZ    PREND                   NO PARM INFO ENTERED             01790000
         LA    R1,2(,R1)               PARM DATA                        01800000
         ST    R1,PRMSTRT              SAVE START OF PARAMETERS         01810000
PRMSCN   DS    0H                                                       01820000
         LA    R11,8                   MAX LENGTH OF MEMBER NAME        01830000
         LA    R10,MEMBER              MEMBER NAME FIELD ADDRESS        01840000
PRMEMOV  DS    0H                                                       01850000
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO MEMBER NAME      01860000
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             01870000
         BCTR  R12,0                   SUBTRACT 1 FROM LENGTH           01880000
         LA    R10,1(,R10)             TO NEXT NAME BYTE                01890000
         BCTR  R11,0                   SUBTRACT 1 FROM LENGTH           01900000
         LTR   R12,R12                 END OF CONTROL DATA              01910001
         BE    PREND                   YES                              01920001
         CLI   0(R1),C','              GOT A COMMA                      01930000
         BE    PRMORPRM                YES                              01940001
         LTR   R11,R11                 NAME FULL                        01950000
         BNZ   PRMEMOV                 NO, CONTINUE                     01960000
         B     PRMERR                  YES, NAME TOO LONG               01970000
PRMORPRM DS    0H                                                       01980000
         LTR   R12,R12                 ANY MORE PARM LEFT TO PARSE      01990001
         BZ    PREND                   NO, WE ARE DONE WITH PARM        02000001
         CLI   0(R1),C','              SEPERATOR                        02010000
         BNE   PRKEYWD                 NO, CHECK FOR A KEYWORD          02020000
         LA    R1,1(,R1)               SKIP COMMA                       02030000
         BCTR  R12,0                   INCLUDE COMMA PARSED             02040000
         B     PRMORPRM                LOOK FOR MORE PARM KEYWORDS      02050000
PRKEYWD  DS    0H                                                       02060000
         CH    R12,=H'+5'              LENGTH LEFT LONG ENOUGH FOR PARM 02070000
         BL    PRMERR                  NO, PARAMETER ERROR              02080000
         CLC   =C'LIB=',0(R1)          PARM LIB KEYWORD                 02090000
         BE    PRLIB                   YES, HANDLE LIB VALUE            02100000
         CH    R12,=H'+8'              LENGTH LEFT LONG ENOUGH FOR PARM 02110000
         BL    PRMERR                  NO, PARAMETER ERROR              02120000
         CLC   =C'OPTION=',0(R1)       PARM OPTION KEYWORD              02130000
         BE    PROPT                   YES, HANDLE OPTION KEYWORD       02140000
         B     PRMERR                  UNKNOWN KEYWORD, PARAMETER ERROR 02150000
PRLIB    DS    0H                                                       02160000
         LA    R1,4(,R1)               SKIP LIB=                        02170000
         SH    R12,=H'+4'              INCLUDE IN LENGTH PARSED         02180000
         MVC   LIBDDN,BLANX            CLEAR CSECT NAME                 02190000
         LA    R11,8                   CSECT NAME MAX LENGTH            02200000
         LA    R10,LIBDDN              LIB DDNAME                       02210000
PRLIBMOV DS    0H                                                       02220000
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO DDNAME           02230000
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             02240000
         LA    R10,1(,R10)             TO NEXT NAME BYTE                02250000
         BCTR  R12,0                   DEDUCT 1 FROM CONTROL LENGTH     02260000
         BCTR  R11,0                   DEDUCT 1 FROM NAME LENGTH        02270000
         LTR   R12,R12                 ANY CONTROL BYTES LEFT           02280000
         BZ    PREND                   NO                               02290000
         CLI   0(R1),C','              NEXT CONTROL COMMA               02300000
         BE    PRMORPRM                YES                              02310000
         LTR   R11,R11                 ANY NAME BYTES LEFT              02320000
         BNZ   PRLIBMOV                YES, LOOP                        02330000
         B     PRMERR                  NAME TOO LONG, ERROR             02340000
PROPT    DS    0H                                                       02350000
         LA    R1,7(,R1)               SKIP OPTION=                     02360000
         SH    R12,=H'+7'              INCLUDE IN LENGTH PARSED         02370000
         BZ    PROPTDT1                NULL OPTION= SET DETAIL          02380000
         CLI   0(R1),C','              IS OPTION= NULL                  02390000
         BE    PROPTDT1                YES, SET DETAIL                  02400000
         CH    R12,=H'+6'              ENOUGH LEFT FOR DETAIL           02410000
         BL    PRMERR                  NO, PARAMETER ERROR              02420000
         CLC   =C'DETAIL',0(R1)        KEYWORD VALUE DETAIL             02430000
         BE    PROPTDTL                YES, SET DETAIL                  02440000
         CH    R12,=H'+7'              ENOUGH LEFT FOR SUMMARY          02450000
         BL    PRMERR                  NO, PARAMETER ERROR              02460000
         CLC   =C'SUMMARY',0(R1)       KEYWORD VALUE SUMMARY            02470000
         BE    PROPTSUM                YES, SET SUMMARY                 02480000
         B     PRMERR                  UNKNOWN KEYWORD VALUE, PARM ERR  02490000
PROPTSUM DS    0H                                                       02500000
         LA    R1,7(,R1)               SKIP DETAIL                      02510000
         SH    R12,=H'+7'              INCLUDE IN LENGTH PARSED         02520000
         OI    PRMOPT,PRMOPTSU         SET SUMMARY FLAG                 02530000
         B     PRMORPRM                LOOK FOR MORE KEYWORDS           02540000
PROPTDTL DS    0H                                                       02550000
         LA    R1,6(,R1)               SKIP SUMMARY                     02560000
         SH    R12,=H'+6'              INCLUDE IN LENGTH PARSED         02570000
PROPTDT1 DS    0H                                                       02580000
         NI    PRMOPT,255-PRMOPTSU     CLEAR SUMMARY FLAG               02590000
         B     PRMORPRM                LOOK FOR MORE KEYWORDS           02600000
PREND    DS    0H                                                       02610000
         CLC   MEMBER,BLANX            ANY MEMBER NAME FOUND            02620000
         BE    NOMBR                   NO, ERROR                        02630000
         MVC   PRT(5),=C'LMOD='        * SET                            02640000
         MVC   PRT+5(8),MEMBER         * UP                             02650000
         MVC   PRT+29(4),=C'LIB='      * OPTIONS                        02660000
         MVC   PRT+33(8),LIBDDN        * PASSED                         02670000
         MVC   PRT+42(7),=C'OPTION='   *                                02680000
         TM    PRMOPT,PRMOPTSU         *                                02690000
         BNO   PRPRTDTL                *                                02700000
         MVC   PRT+49(7),=C'SUMMARY'   *                                02710000
         B     PRPRTPRM                *                                02720000
PRPRTDTL DS    0H                      *                                02730000
         MVC   PRT+49(6),=C'DETAIL'    *                                02740000
PRPRTPRM DS    0H                                                       02750000
         BAL   R9,PRINT                PRINT                            02760000
****************************************************************        02770000
*                                                              *        02780000
*        OPEN LIBRARY DDNAME                                   *        02790000
*                                                              *        02800000
****************************************************************        02810000
         MVC   SYSLIB+40(8),LIBDDN     SETUP LIBRARY DCB DDNAME         02820000
         OPEN  (SYSLIB,(INPUT)),MF=(E,OPENLIST)                         02830000
         TM    SYSLIB+48,16            SYSLIB OPENED OK                 02840000
         BO    DOBLDL                  YES, CONTINUE                    02850005
         MVC   PRT(23),=C'DD=         Failed OPEN'                      02860005
         MVC   PRT+3(8),LIBDDN         DDNAME                           02870005
         BAL   R9,PRINT                GO PRINT MESSAGE                 02880005
         LA    R2,16                   SET RETURN CODE TO 16            02890005
         B     CLOSES                  STOP THE RUN                     02900005
****************************************************************        02910000
*                                                              *        02920000
* GET STORAGE FOR THE SYMBOL TABLE                             *        02930000
*                                                              *        02940000
****************************************************************        02950000
DOBLDL   DS    0H                                                       02960005
         BAL   R9,BLDL                 ISSUE BLDL AND PRINT             02970000
         MVI   CCAT,0                  INSURE TTR0                      02980000
         POINT SYSLIB,TTRMOD           POINT TO 1ST BLOCK OF MODULE     02990000
         GETMAIN R,LV=32768            GET BUFFER STORAGE               03000000
         ST    R1,BUFAD                SAVE BUFFER ADDRESS              03010000
         GETMAIN R,LV=95000            GET SYMBOL TABLE STORAGE         03020000
         ST    R1,SYMTBAD              SAVE SYMBOL TABLE ADDRESS        03030000
         ST    R1,CURRSYM              SAVE CURRENT SYMBOL ADDR         03040000
         A     R1,ENDSYM               COMPUTE END ADDR                 03050000
         ST    R1,ENDSYM               STORE TBL END ADDR               03060000
         MVC   PRT(21),=C'External Symbol Table'                        03070000
         BAL   R9,PRINTSM              PRINT                            03080000
         MVC   PRT(L'SYMHDR),SYMHDR    SYM TBL HEADER                   03090000
         BAL   R9,PRINTSM              PRINT                            03100000
****************************************************************        03110000
*                                                              *        03120000
* PROCESS DIRECTORY ENTRY                                      *        03130000
*                                                              *        03140000
****************************************************************        03150000
MAINLINE DS    0H                      MAINLINE ROUTINE                 03160000
         LA    R0,1                    Count reads                   05 03170008
         A     R0,READCT                                             05 03180008
         ST    R0,READCT                                             05 03190008
         L     R6,BUFAD                GET BUFFER ADDRESS               03200000
         LA    R9,SYSLIB               DCB ADDRESS                      03210000
         READ  DECB,SF,(R9),(6),'S',MF=E                                03220000
         CHECK DECB                    AWAIT COMPLETION                 03230000
         CLI   0(R6),X'20'             CESD RECORD                      03240000
         BNE   TESTOTHR                NO                               03250000
         BAL   R9,CESDREC              PROCESS CESD RECORDS             03260000
         B     MAINLINE                GO READ AGAIN                    03270000
TESTOTHR DS    0H                                                       03280000
         LA    R9,CNTLRECS             ASSUME CONTROL RECORD            03290000
         CLI   0(R6),1                 IT IS CONTROL                    03300000
         BE    PERFORM                 YES                              03310000
         CLI   0(R6),5                 IS IT CONTROL                    03320000
         BE    PERFORM                 YES                              03330000
         CLI   0(R6),13                IS IT CONTROL                    03340000
         BE    PERFORM                 YES                              03350000
         LA    R9,RLDRECS              ASSUME RLD RECORD                03360000
         CLI   0(R6),2                 IS IT RLD                        03370000
         BE    PERFORM                 YES                              03380000
         CLI   0(R6),6                 IS IT RLD                        03390000
         BE    PERFORM                 YES                              03400000
         CLI   0(R6),14                IS IT RLD                        03410000
         BE    PERFORM                 YES                              03420000
         LA    R9,CTRLRECS             ASSUME CONTROL AND RLD           03430000
         CLI   0(R6),3                 IS IT CTL AND RLD                03440000
         BE    PERFORM                 YES                              03450000
         CLI   0(R6),7                 IS IT CTL AND RLD                03460000
         BE    PERFORM                 YES                              03470000
         CLI   0(R6),15                IS IT CTL AND RLD                03480000
         BE    PERFORM                 YES                              03490000
         CLI   0(R6),X'80'             AMODE/RMODE data              07 03500011
         BE    MAINLINE                Yes, skip                     07 03510011
         CLI   0(R6),X'10'             Scatter/translation record    07 03520011
         BE    MAINLINE                Yes, skip                     07 03530011
         MVC   PRT(19),=C'Unknown record type'                       07 03540011
         LR    R12,R6                  Address of record type        07 03550011
         BAL   R9,HEXPRT1              Convert to display            07 03560011
         MVC   PRT+20(2),PRTABL        Move to print                 07 03570011
         BAL   R9,PRINT                Print message                 07 03580011
         LA    R1,SYSLIB               DCB address                   07 03590011
         USING IHADCB,R1                                             07 03600011
         LH    R0,DCBBLKSI             Get blkize                    07 03610011
         DROP  R1                                                    07 03620011
         L     R15,DECB+16             Satus area address            07 03630011
         SH    R0,14(,R15)             Less esiual count             07 03640011
         LR    R1,R6                                                 07 03650011
         MVC   PRTLINE+1(6),=C'Record'                               07 03660011
         BAL   R14,DMPAD                                             07 03670011
*        LA    R2,7                    Error reason 7                07 03680011
*        STCM  R2,7,TOTVIRT            Save reason code for R0       07 03690011
*        SR    R12,R12                 No table returned             07 03700011
*        LA    R2,8                    Set return code to 8          07 03710011
*        B     CLOSES                  Error                         07 03720011
         B     MAINLINE                GO READ AGAIN                 07 03730011
PERFORM  DS    0H                                                       03740000
         BALR  R9,R9                   PERFORM APPROPRIATE ROUTINE      03750000
         TM    PROCSW,PROCSWOK         MODULE PROCESSING DONE           03760000
         BZ    MAINLINE                NO, GO READ AGAIN                03770000
         B     ENDINIT                 GO COMPLETE PROCESSING           03780000
****************************************************************        03790000
*                                                              *        03800000
* PROCESS LOAD MODULE CONTROL RECORDS. THESE RECORDS PRECEDE   *        03810000
* TEXT RECORDS.                                                *        03820000
*                                                              *        03830000
****************************************************************        03840000
CNTLRECS DS    0H                      CONTROL RECORD PROCESSING        03850000
         ST    R9,CT9                  SAVE RETURN ADDR                 03860000
         TM    0(R6),X'08'             RECORD PRECEDES LAST RECORD      03870000
         BZ    CNCKTYP                 NO                               03880000
         OI    PROCSW,PROCSWOK         YES, SHOW PROCESSING COMPLETE    03890000
CNCKTYP  DS    0H                                                       03900000
         LA    R0,1                    Count reads                   05 03910008
         A     R0,READCT                                             05 03920008
         ST    R0,READCT                                             05 03930008
         READ  DECB,SF,,(6),MF=E       READ FOLLOWING TEXT RECORD       03940000
         CHECK DECB                    AWAIT COMPLETION                 03950000
CTXIT    DS    0H                                                       03960000
         L     R9,CT9                  GET RETURN ADDR                  03970000
         BR    R9                      EXIT                             03980000
****************************************************************        03990000
*                                                              *        04000000
* PROCESS RLD RECORDS. A TABLE OF RLD DATA IS BUILT.           *        04010000
*                                                              *        04020000
****************************************************************        04030000
RLDRECS  DS    0H                      RLD RECORD PROCESSING            04040000
         TM    0(R6),X'08'             LAST RECORD OF MODULE            04050000
         BZ    RLSV9                   NO                               04060000
         OI    PROCSW,PROCSWOK         SHOW PROCESSING COMPLETE         04070000
RLSV9    DS    0H                                                       04080000
         BR    R9                      EXIT                             04090000
****************************************************************        04100000
*                                                              *        04110000
* PROCESS CONTROL AND RLD RECORDS. THESE RECORDS CONTAIN BOTH  *        04120000
* RLD AND CONTROL INFORMATION, AND ARE PROCESSED BY BOTH       *        04130000
* THE RLDRECS AND CNTLRECS ROUTINES.                           *        04140000
*                                                              *        04150000
****************************************************************        04160000
CTRLRECS DS    0H                      CONTROL AND RLD RECORDS          04170000
         ST    R9,CR9                  SAVE RETURN ADDR                 04180000
         BAL   R9,RLDRECS              PROCESS RLD DATA                 04190000
         L     R6,BUFAD                RESET BUFFER ADDRESS             04200000
         BAL   R9,CNTLRECS             PROCESS CONTROL DATA             04210000
         L     R9,CR9                  GET RETURN ADDR                  04220000
         BR    R9                      EXIT                             04230000
****************************************************************        04240000
*                                                              *        04250000
* PROCESS COMPOSITE ESD RECORDS.                               *        04260000
*                                                              *        04270000
****************************************************************        04280000
CESDREC  DS    0H                      CESD RECORD PROCESSING           04290000
         ST    R9,CES9                 SAVE RETURN                      04300000
         L     R7,CURRSYM              GET SYMBOL TBL ADDR              04310000
         USING SYMTBL,R7                                                04320000
         LH    R10,4(,R6)              GET ESD ID OF 1ST ITEM           04330000
         LH    R8,6(,R6)               NBR BYTES OF ESD DATA            04340000
         SRL   R8,4                    COMPUTE NBR ENTRIES              04350000
         LA    R6,8(,R6)               STEP TO 1ST RECORD ESD ITEM      04360000
CESDNXT  DS    0H                                                       04370000
         C     R7,ENDSYM               END OF TABLE                     04380000
         BNL   SYMFULL                 YES, ERROR                       04390000
         MVC   EXTSYM,0(R6)            SYMBOL NAME                      04400000
         MVC   TYPSYM,8(R6)            TYPE                             04410000
         NI    TYPSYM,X'0F'            CLEAR BITS 0-3                   04420000
         MVC   SYMIND,8(R6)            INDICATOR BYTE                   04430000
         NI    SYMIND,X'0F'            CLEAR BITS 4-7                   04440000
         TM    8(R6),X'14'             POSSIBLE ENTAB/SEGTAB            04450000
         BNO   CEMVAD                  NO                               04460000
         TM    8(R6),X'03'             IS IT ENTAB/SEGTAB               04470000
         BNZ   CEMVAD                  NO                               04480000
         MVC   TYPSYM(2),=X'0F00'      SHOW ENTAB/SEGTAB                04490000
CEMVAD   DS    0H                                                       04500000
         MVC   SYMADDR,9(R6)           ADDRESS OF SYMBOL                04510000
         MVC   SYMSEG,12(R6)           SEGMENT WHERE DEFINED            04520000
         MVC   SYMLENG,13(R6)          LENGTH OR LR ESD ID              04530000
         STCM  R10,3,SYMESDID          ESD ID                           04540000
         MVC   PRT+6(8),EXTSYM         SYMBOL NAME                      04550000
         OC    PRT+5(8),BLANX          X'00' NAME BECOME BLANK          04560000
         MVC   PRT+22(2),=C'SD'        ASSUME SD                        04570000
         CLI   TYPSYM,0                IS IT SD                         04580000
         BE    CEPIND                  YES                              04590000
         CLI   TYPSYM,X'0D'            IS IT SD                         04600000
         BE    CEPIND                  YES                              04610000
         MVC   PRT+22(2),=C'LR'        ASSUME LR                        04620000
         CLI   TYPSYM,3                IS IT LR                         04630000
         BE    CEPIND                  YES                              04640000
         MVC   PRT+22(2),=C'ER'        ASSUME ER                        04650000
         CLI   TYPSYM,2                IS IT ER                         04660000
         BE    CEPIND                  YES                              04670000
         MVC   PRT+22(2),=C'PC'        ASSUME PC                        04680000
         CLI   TYPSYM,4                IS IT PC                         04690000
         BE    CEPIND                  YES                              04700000
         CLI   TYPSYM,X'0E'            IS IT PC                         04710000
         BE    CEPIND                  YES                              04720000
         MVC   PRT+22(2),=C'PR'        ASSUME PR                        04730000
         CLI   TYPSYM,6                IS IT PR                         04740000
         BE    CEPIND                  YES                              04750000
         MVC   PRT+22(2),=C'CM'        ASSUME CM                        04760000
         CLI   TYPSYM,5                IS IT CM                         04770000
         BE    CEPIND                  YES                              04780000
         MVC   PRT+22(2),=C'WX'        ASSUME WX                        04790000
         CLI   TYPSYM,X'0A'            IS IT WX                         04800000
         BE    CEPIND                  YES                              04810000
         MVC   PRT+20(4),=C'NULL'      ASSUME NULL                      04820000
         CLI   TYPSYM,7                IS IT NULL                       04830000
         BE    CEPIND                  YES                              04840000
         MVC   PRT+18(6),=C'E/STAB'    ASSUME ENTAB/SEGTAB              04850000
         CLI   TYPSYM,X'0F'            IS IT ENTAB/SEGTAB               04860000
         BE    CEPIND                  YES                              04870000
         MVI   PRT+18,C' '                                              04880000
         MVC   PRT+19(2),=C'X'''       UNIDENTIFIABLE TYPE              04890000
         LA    R12,TYPSYM              ADDRESS OF TYPE                  04900000
         BAL   R9,HEXPRT1              CONVERT                          04910000
         MVC   PRT+21(2),PRTABL        TYPE                             04920000
         MVI   PRT+23,C''''                                             04930000
CEPIND   DS    0H                                                       04940000
         LA    R12,SYMIND              ADDRESS OF INDICATOR             04950000
         BAL   R9,HEXPRT1              CONVERT                          04960000
         MVC   PRT+27(1),PRTABL        INDICATOR                        04970000
         LA    R12,SYMADDR             ADDRESS OF SYMBOL ADDR           04980000
         BAL   R9,HEXPRT3              CONVERT                          04990000
         MVC   PRT+30(6),PRTABL        SYMBOL ADDR                      05000000
         LA    R12,SYMSEG              ADDRESS OF SEGMENT NBR           05010000
         BAL   R9,HEXPRT1              CONVERT                          05020000
         MVC   PRT+39(2),PRTABL        SEGMENT NBR                      05030000
         CLI   TYPSYM,2                IS IT ER                         05040000
         BE    CEESD                   YES                              05050000
         CLI   TYPSYM,3                IS IT AN LR                      05060000
         BNE   CENOTLR                 NO                               05070000
         LA    R12,SYMLRID             ADDRESS OF LR ESD ID             05080000
         BAL   R9,HEXPRT2              CONVERT                          05090000
         MVC   PRT+43(4),PRTABL        LR ESD ID                        05100000
         B     CEESD                   CONTINUE                         05110000
CENOTLR  DS    0H                                                       05120000
         LA    R12,SYMLENG             ADDRESS OF LENGTH                05130000
         BAL   R9,HEXPRT3              CONVERT                          05140000
         MVC   PRT+49(6),PRTABL        SYMBOL LENGTH                    05150000
CEESD    DS    0H                                                       05160000
         LA    R12,SYMESDID            ADDRESS OF ESD ID                05170000
         BAL   R9,HEXPRT2              CONVERT                          05180000
         MVC   PRT+57(4),PRTABL        ESD ID                           05190000
         BAL   R9,PRINTSM              PRINT                            05200000
         LA    R7,L'SYMENT(,R7)        TO NEXT TBL ENTRY LOCATION       05210000
         LA    R10,1(,R10)             ADD 1 TO ESD COUNTER             05220000
         LA    R6,16(,R6)              TO NEXT ESD ITEM IN INPUT        05230000
         BCT   R8,CESDNXT              LOOP THRU INPUT RECORD           05240000
         ST    R7,CURRSYM              SAVE NEXT TABLE ADDR             05250000
         L     R9,CES9                 GET RETURN ADDR                  05260000
         BR    R9                      EXIT                             05270000
         DROP  R7                                                       05280000
****************************************************************        05290000
*                                                              *        05300000
* ISSUE BLDL FOR THE MAIN MODULE AND PRINT MODULE RELATED INFO *        05310000
*                                                              *        05320000
****************************************************************        05330000
BLDL     DS    0H                      ISSUE BLDL AND PRINT INFO        05340000
         ST    R9,BL9                  SAVE RETURN ADDR                 05350000
ISSBLDL  DS    0H                                                       05360000
         BLDL  SYSLIB,BLDLIST          ISSUE BLDL                       05370000
         LTR   R15,R15                 ANY ERRORS                       05380000
         BNZ   MISSMEM                 YES                              05390000
         LA    R1,MEMBER+35            END OF BASIC PORTION             05400000
         TM    ATTR2,X'10'             SSI PRESENT                      05410000
         BZ    BLREFA1                 NO                               05420000
         LA    R1,4(,R1)               ADD FOR SSI                      05430000
BLREFA1  DS    0H                                                       05440000
         TM    ALIASIND,X'80'          ALIAS                            05450000
         BZ    BLREFA2                 NO                               05460000
         LA    R1,11(,R1)              ADD FOR ALIAS                    05470000
BLREFA2  DS    0H                                                       05480000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   05490000
         BZ    BLREFA3                 NO                               05500000
         LA    R1,8(,R1)               ADD FOR SCATTER                  05510000
BLREFA3  DS    0H                                                       05520000
         STC   R1,DEVTYPE              SAVE OFFSET                      05530000
         TM    DEVTYPE,1               IS OFFSET ODD                    05540000
         BZ    ALIGN1                  NO, CONTINUE                     05550000
         LA    R1,1(,R1)               AUTHCODE IS ON EVEN BOUNDARY     05560000
ALIGN1   DS    0H                                                       05570000
         MVC   AUTHLEN(2),0(R1)        AUTH LENGTH AND CODE             05580000
         TM    ATTR2,X'10'             SSI PRESENT                      05590000
         BZ    BLCKALI                 NO                               05600000
         LA    R1,MEMBER+35            END OF BASIC PORTION             05610000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   05620000
         BZ    BLSSI2                  NO                               05630000
         TM    ALIASIND,X'80'          ALIAS                            05640000
         BO    BLFMTED                 YES, NO REFORMAT NEEDED          05650000
         LA    R1,8(,R1)               NO, STEP PAST SCATTER SECTION    05660000
         B     BLMVSSI                 GO MOVE SSI                      05670000
BLSSI2   DS    0H                                                       05680000
         TM    ALIASIND,X'80'          ALIAS                            05690000
         BZ    BLMVSSI                 NO                               05700000
         LA    R1,11(,R1)              YES, STEP PAST ALIAS SECTION     05710000
BLMVSSI  DS    0H                                                       05720000
         STC   R1,DEVTYPE              SAVE OFFSET                      05730000
         TM    DEVTYPE,1               IS OFFSET ODD                    05740000
         BZ    ALIGN2                  NO, CONTINUE                     05750000
         LA    R1,1(,R1)               SSI IS ON EVEN BOUNDARY          05760000
ALIGN2   DS    0H                                                       05770000
         MVC   SSI,0(R1)               MOVE SSI DATA                    05780000
BLCKALI  DS    0H                                                       05790000
         TM    ALIASIND,X'80'          ALIAS                            05800000
         BO    BLASC                   YES                              05810000
         B     BLFMTED                 FINISHED                         05820000
BLASC    DS    0H                                                       05830000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   05840000
         BO    BLFMTED                 YES, NO REFORMAT NEEDED          05850000
         MVC   ALMEM,MEMBER+38         MOVE ALIAS MEMBER                05860000
         MVC   ALEPA(3),MEMBER+35      YES, MOVE ALIAS DATA             05870000
BLFMTED  DS    0H                                                       05880000
         MVC   PRT(25),=C'Directory info for module'                    05890000
         MVC   PRT+26(8),MEMBER        MEMBER NAME TO PRINT             05900000
         BAL   R9,PRINT                PRINT                            05910000
         MVC   PRT+10(14),=C'TTR of module='                            05920000
         LA    R12,TTRMOD              ADDRESS OF TTR                   05930000
         BAL   R9,HEXPRT3              CONVERT                          05940000
         MVC   PRT+24(6),PRTABL        TTR TO PRINT                     05950000
         BAL   R9,PRINT                PRINT                            05960000
         MVC   PRT+10(14),=C'Concatenation='                            05970000
         LA    R12,CCAT                ADDRESS OF CONCATENATION NBR     05980000
         BAL   R9,HEXPRT1              CONVERT                          05990000
         MVC   PRT+24(2),PRTABL        CONCATENATION NBR                06000000
         BAL   R9,PRINT                PRINT                            06010000
         MVC   PRT+10(16),=C'Alias indicator='                          06020000
         LA    R12,ALIASIND            ADDRESS OF ALIAS INDICATOR       06030000
         BAL   R9,HEXPRT1              CONVERT                          06040000
         MVC   PRT+26(2),PRTABL        ALIAS INDICATOR                  06050000
         TM    ALIASIND,X'80'          IS IT AN ALIAS                   06060000
         BZ    BLALPRT                 NO                               06070000
         MVC   PRT+50(13),=C'*** Alias ***'                             06080000
BLALPRT  DS    0H                                                       06090000
         BAL   R9,PRINT                PRINT                            06100000
         MVC   PRT+10(22),=C'TTR of 1st TXT record='                    06110000
         LA    R12,TTR1TXT             ADDRESS OF TTR                   06120000
         BAL   R9,HEXPRT3              CONVERT                          06130000
         MVC   PRT+32(6),PRTABL        TTR OF 1ST TXT BLOCK             06140000
         BAL   R9,PRINT                PRINT                            06150000
         MVC   PRT+10(25),=C'TTR of NOTE/Scatter list='                 06160000
         LA    R12,TTRNS               ADDRESS OF TTR                   06170000
         BAL   R9,HEXPRT3              CONVERT                          06180000
         MVC   PRT+35(6),PRTABL        TTR OF NOTE/SCATTER              06190000
         BAL   R9,PRINT                PRINT                            06200000
         MVC   PRT+10(20),=C'Number NOTE entries='                      06210000
         LA    R12,NNOTE               ADDRESS OF NBR NOTES             06220000
         BAL   R9,HEXPRT1              CONVERT                          06230000
         MVC   PRT+30(2),PRTABL        NBR NOTE ENTRIES                 06240000
         BAL   R9,PRINT                PRINT                            06250000
         MVC   PRT+10(14),=C'Attributes #1='                            06260000
         LA    R12,ATTR1A              ADDRESS OF ATTRIBUTES            06270000
         BAL   R9,HEXPRT2              CONVERT                          06280000
         MVC   PRT+24(4),PRTABL        ATTRIBUTES 1                     06290000
         LA    R1,PRT+29               START OF ATTRIBUTES              06300000
         TM    ATTR1A,X'80'            RENT                             06310000
         BZ    BLAT1A                  NO                               06320000
         MVC   0(4,R1),=C'RENT'                                         06330000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06340000
BLAT1A   DS    0H                                                       06350000
         TM    ATTR1A,X'40'            REUS                             06360000
         BZ    BLAT1B                  NO                               06370000
         MVC   0(4,R1),=C'REUS'                                         06380000
BLAT1B   DS    0H                                                       06390000
         TM    ATTR1A,X'20'            OVLY                             06400000
         BZ    BLAT1C                  NO                               06410000
         MVC   0(4,R1),=C'OVLY'                                         06420000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06430000
BLAT1C   DS    0H                                                       06440000
         TM    ATTR1A,X'10'            TEST                             06450000
         BZ    BLAT1D                  NO                               06460000
         MVC   0(4,R1),=C'TEST'                                         06470000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06480000
BLAT1D   DS    0H                                                       06490000
         TM    ATTR1B,X'08'            OL                               06500000
         BZ    BLAT1E                  NO                               06510000
         MVC   0(2,R1),=C'OL'                                           06520000
         LA    R1,3(,R1)               NEXT ATTRIBUTE                   06530000
BLAT1E   DS    0H                                                       06540000
         TM    ATTR1A,X'04'            SCTR                             06550000
         BZ    BLAT1F                  NO                               06560000
         MVC   0(4,R1),=C'SCTR'                                         06570000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06580000
BLAT1F   DS    0H                                                       06590000
         TM    ATTR1A,X'02'            EXEC                             06600000
         BZ    BLAT1G                  NO                               06610000
         MVC   0(4,R1),=C'EXEC'                                         06620000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06630000
BLAT1G   DS    0H                                                       06640000
         TM    ATTR1B,X'08'            NOT EDITABLE                     06650000
         BZ    BLAT1H                  NO                               06660000
         MVC   0(2,R1),=C'NE'                                           06670000
         LA    R1,3(,R1)               NEXT ATTRIBUTE                   06680000
BLAT1H   DS    0H                                                       06690000
         TM    ATTR1B,X'01'            REFR                             06700000
         BZ    BLAT1PRT                NO                               06710000
         MVC   0(4,R1),=C'REFR'                                         06720000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06730000
BLAT1PRT DS    0H                                                       06740000
         BAL   R9,PRINT                PRINT                            06750000
         MVC   PRT+10(13),=C'Total length='                             06760000
         LA    R12,TOTVIRT             ADDRESS OF TOTAL LENGTH          06770000
         BAL   R9,HEXPRT3              CONVERT                          06780000
         MVC   PRT+23(6),PRTABL        TOTAL LENGTH OF MODULE           06790000
         BAL   R9,PRINT                PRINT                            06800000
         MVC   PRT+10(25),=C'Length of 1st TXT record='                 06810000
         LA    R12,LENG1               ADDRESS OF 1ST TXT LENG          06820000
         BAL   R9,HEXPRT2              CONVERT                          06830000
         MVC   PRT+35(4),PRTABL        LENGTH OF 1ST TXT BLOCK          06840000
         BAL   R9,PRINT                PRINT                            06850000
         MVC   PRT+10(4),=C'EPA='                                       06860000
         LA    R12,LKEPA               ADDRESS OF E.P. ADDR             06870000
         BAL   R9,HEXPRT3              CONVERT                          06880000
         MVC   PRT+14(6),PRTABL        E.P. ADDR                        06890000
         BAL   R9,PRINT                PRINT                            06900000
         MVC   PRT+10(14),=C'Attributes #2='                            06910000
         LA    R12,ATTR2               ADDRESS OF ATTRIBUTES 2          06920000
         BAL   R9,HEXPRT2              CONVERT                          06930000
         MVC   PRT+24(4),PRTABL        ATTRIBUTES 2                     06940000
         LA    R1,PRT+29               START OF ATTRIBUTES              06950000
         TM    ATTR2,X'20'             PAGE ALIGNMENT                   06960000
         BZ    BLAT3A                  NO                               06970000
         MVC   0(4,R1),=C'PAGE'                                         06980000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   06990000
BLAT3A   DS    0H                                                       07000000
         TM    ATTR2,X'10'             SSI PRESENT                      07010000
         BZ    BLAT3B                  NO                               07020000
         MVC   0(3,R1),=C'SSI'                                          07030000
         LA    R1,4(,R1)               NEXT ATTRIBUTE                   07040000
BLAT3B   DS    0H                                                       07050000
         TM    ATTR2,X'08'             APF PRESENT                      07060000
         BZ    BLAT3PRT                NO                               07070000
         MVC   0(3,R1),=C'APF'                                          07080000
         LA    R1,4(,R1)               NEXT ATTRIBUTE                   07090000
BLAT3PRT DS    0H                                                       07100000
         BAL   R9,PRINT                PRINT                            07110000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   07120000
         BZ    BLFAL                   NO                               07130000
         MVC   PRT+10(12),=C'SCTR length='                              07140000
         LA    R12,SCTRLEN             ADDRESS OF SCATTER LIST LENGTH   07150000
         BAL   R9,HEXPRT2              CONVERT                          07160000
         MVC   PRT+22(4),PRTABL        SCATTER LIST LENGTH              07170000
         BAL   R9,PRINT                PRINT                            07180000
         MVC   PRT+10(23),=C'Translate table length='                   07190000
         LA    R12,TTLEN               ADDRESS OF TRANS TBL LEN         07200000
         BAL   R9,HEXPRT2              CONVERT                          07210000
         MVC   PRT+33(4),PRTABL        TRANSLATION TABLE LENGTH         07220000
         BAL   R9,PRINT                PRINT                            07230000
         MVC   PRT+10(18),=C'ESD ID of 1st TXT='                        07240000
         LA    R12,SCESDID             ADDRESS OF ESD ID                07250000
         BAL   R9,HEXPRT2              CONVERT                          07260000
         MVC   PRT+28(4),PRTABL        ESD ID OF 1ST TXT                07270000
         BAL   R9,PRINT                PRINT                            07280000
         MVC   PRT+10(22),=C'ESD ID containing EPA='                    07290000
         LA    R12,SCEPESD             ADDRESS OF ESD ID                07300000
         BAL   R9,HEXPRT2              CONVERT                          07310000
         MVC   PRT+32(4),PRTABL        ADDRESS OF ESD ID OF CSECT W/EPA 07320000
         BAL   R9,PRINT                PRINT                            07330000
BLFAL    DS    0H                                                       07340000
         TM    ALIASIND,X'80'          ALIAS                            07350000
         BZ    BLFSSI                  NO                               07360000
         MVC   PRT+10(19),=C'EPA of this member='                       07370000
         LA    R12,ALEPA               ADDRESS OF EPA                   07380000
         BAL   R9,HEXPRT3              CONVERT                          07390000
         MVC   PRT+29(6),PRTABL        E.P. ADDR                        07400000
         BAL   R9,PRINT                                                 07410000
         MVC   PRT+10(17),=C'Real member name='                         07420000
         MVC   PRT+27(8),ALMEM         REAL MEMBER NAME                 07430000
         BAL   R9,PRINT                                                 07440000
BLFSSI   DS    0H                                                       07450000
         TM    ATTR2,X'10'             ANY SSI INFO                     07460000
         BZ    BLAUTHC                 NO                               07470000
         MVC   PRT+10(9),=C'SSI info='                                  07480000
         LA    R12,SSI                 ADDRESS OF SSI INFO              07490000
         BAL   R9,HEXPRT4              CONVERT                          07500000
         MVC   PRT+19(8),PRTABL        SSI INFO                         07510000
         BAL   R9,PRINT                PRINT                            07520000
BLAUTHC  DS    0H                                                       07530000
         TM    ATTR2,X'08'             APF PRESENT                      07540000
         BZ    BLNOAUTH                NO                               07550000
         MVC   PRT+10(10),=C'Auth code='                                07560000
         LA    R12,AUTHCOD             ADDRESS OF AUTH CODE             07570000
         BAL   R9,HEXPRT1              CONVERT                          07580000
         MVC   PRT+20(2),PRTABL        AUTH CODE                        07590000
         BAL   R9,PRINT                PRINT                            07600000
BLNOAUTH DS    0H                                                       07610000
         TM    ALIASIND,X'80'          ALIAS                            07620000
         BZ    BLXIT                   NO                               07630000
         MVC   PRT+5(26),=C'Real member directory info'                 07640000
         BAL   R9,PRINT                PRINT                            07650000
         MVC   MEMBER,ALMEM            REAL MEMBER NAME TO LIST         07660000
         B     ISSBLDL                 DO OVER FOR REAL MEMBER          07670000
BLXIT    DS    0H                                                       07680000
         L     R9,BL9                  GET RETURN ADDR                  07690000
         BR    R9                      EXIT                             07700000
****************************************************************        07710000
*                                                              *        07720000
* CREATE PRINTABLE HEX FROM HEX. ON ENTRY, REG 12 CONTAINS THE *        07730000
* ADDRESS OF THE DATA TO BE REFORMATTED. ENTRY POINT USED      *        07740000
* DETERMINES THE SIZE OF THE FIELD. OUTPUT DATA IS PLACED IN   *        07750000
* THE PRTABL FIELD, 2 CHARACTERS PER BYTE.                     *        07760000
*                                                              *        07770000
****************************************************************        07780000
HEXPRT1  DS    0H                                                       07790000
         UNPK  PRTABL(3),0(2,R12)      UNPACK HEX                       07800000
         B     HEXCLTR                 CONTINUE                         07810000
HEXPRT2  DS    0H                                                       07820000
         UNPK  PRTABL(5),0(3,R12)      UNPACK HEX                       07830000
         B     HEXCLTR                 CONTINUE                         07840000
HEXPRT3  DS    0H                                                       07850000
         UNPK  PRTABL(7),0(4,R12)      UNPACK HEX                       07860000
         B     HEXCLTR                 CONTINUE                         07870000
HEXPRT4  DS    0H                                                       07880000
         UNPK  PRTABL(9),0(5,R12)      UNPACK HEX                       07890000
HEXCLTR  DS    0H                                                       07900000
         TR    PRTABL(8),TRTBL-240     MAKE PRINTABLE                   07910000
         BR    R9                      EXIT                             07920000
****************************************************************        07930000
*                                                              *        07940000
* PRINT USING PRINTDD                                          *        07950000
*                                                              *        07960000
****************************************************************        07970000
PRINTSM  DS    0H                      PRINT ROUTINE                    07980000
         TM    PRMOPT,PRMOPTSU         SUMMARY ONLY                     07990000
         BO    CLRPRT                  NO                            07 08000011
PRINT    DS    0H                      PRINT ROUTINE                    08010000
         TM    PRINTDD+48,16           IS PRINTDD OPEN                  08020000
         BNO   CLRPRT                  NO                               08030000
         CP    LINECT,=P'+60'          End of page                   07 08040011
         BL    PRTCHK                  No, check if line fit in page 07 08050011
PRTHDRS  DS    0H                                                    07 08060011
         AP    W#PGCT,=P'+1'           Count pages                   07 08070011
         MVC   W#HD1PG#,=X'40202120'   Page count mask               07 08080011
         ED    W#HD1PG#,W#PGCT         Edit page count               07 08090011
         PUT   PRINTDD,W#HD1           Print heading 1               07 08100011
         ZAP   LINECT,=P'+1'           Init line count               07 08110011
         MVI   PCC,C' '                Skip after heading            07 08120011
PRTCHK   DS    0H                                                    07 08130011
         CLI   PCC,C'+'                Overprint?                    07 08140011
         BE    PRTLIN                  Yes, don't count              07 08150011
         CLI   PCC,C'1'                New line?                     07 08160011
         BE    PRTHDRS                 Yes, print header             07 08170011
         CLI   PCC,C' '                Write after advancing 1?      07 08180011
         BE    PRTLIN1                 Yes, go check if fit          07 08190011
         CLI   PCC,C'0'                Write after advancing 2?      07 08200011
         BE    PRTLIN2                 Yes, go check if fit          07 08210011
         CLI   PCC,C'-'                Write after advancing 3?      07 08220011
         BE    PRTLIN3                 Yes, go check if fit          07 08230011
         B     PRTLIN                  Ignore any other ctl chars    07 08240011
PRTLIN1  DS    0H                                                    07 08250011
         AP    LINECT,=P'+1'           Add to line count             07 08260011
         B     PRTVFY                  Go see if it will fit         07 08270011
PRTLIN2  DS    0H                                                    07 08280011
         AP    LINECT,=P'+2'           Add to line count             07 08290011
         B     PRTVFY                  Go see if it will fit         07 08300011
PRTLIN3  DS    0H                                                    07 08310011
         AP    LINECT,=P'+3'           Add to line count             07 08320011
PRTVFY   DS    0H                                                    07 08330011
         CP    LINECT,=P'+60'          Overflow?                     07 08340011
         BH    PRTHDRS                 Yes, force header             07 08350011
PRTLIN   DS    0H                                                    07 08360011
         PUT   PRINTDD,PRTLINE         Print a line                  07 08370011
CLRPRT   DS    0H                                                    07 08380011
         MVI   PCC,C' '                Clear CC                      07 08390011
         MVC   PRT,BLANX               Clear print line              07 08400011
         BR    R9                      Exit                          07 08410011
****************************************************************     07 08420011
*                                                              *     07 08430011
*        DUMP WITH ADDRESS OF STORAGE DUMPED                   *     07 08440011
*                                                              *     07 08450011
****************************************************************     07 08460011
DMPAD    DS    0H                                                    07 08470011
         ST    R14,W#DMPA14                                          07 08480011
         STM   R0,R15,W#DMPRGS         SAVE REGISTERS                07 08490011
         LR    R9,R0                                                 07 08500011
         ST    R1,W#DMPOFF                                           07 08510011
         LA    R2,PRTLINE+L'PRTLINE-1                                07 08520011
         LA    R0,L'PRTLINE-1                                        07 08530011
DMPAD010 DS    0H                                                    07 08540011
         CLI   0(R2),C' '                                            07 08550011
         BNE   DMPAD020                                              07 08560011
         BCTR  R2,0                                                  07 08570011
         BCT   R0,DMPAD010                                           07 08580011
DMPAD020 DS    0H                                                    07 08590011
         MVC   2(2,R2),=C'at'                                        07 08600011
         LA    R2,5(,R2)               OUTPUT AREA ADDRESS           07 08610011
         LA    R1,W#DMPOFF             ADDRESS OF OFFSET TO DUMP     07 08620011
         LA    R15,4                   CONVERT 4 BYTES               07 08630011
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY         07 08640011
         MVC   1(9,R2),=C'Length=X'''                                07 08650011
         ST    R9,W#DMPOFF                                           07 08660011
         LA    R1,W#DMPOFF                                           07 08670011
         LA    R2,10(,R2)                                            07 08680011
         LA    R15,4                   CONVERT 4 BYTES               07 08690011
         BAL   R14,DMPDSP              CONVERT IT TO DISPLAY         07 08700011
         MVI   0(R2),C''''                                           07 08710011
         BAL   R9,PRINT                PRINT ADDRESS OF DATA         07 08720011
         LM    R0,R15,W#DMPRGS         SAVE REGISTERS                07 08730011
         BAL   R14,DMP                 DUMP STORAGE                  07 08740011
         L     R14,W#DMPA14                                          07 08750011
         BR    R14                     RETURN TO CALLER              07 08760011
****************************************************************     07 08770011
*                                                              *     07 08780011
*        DUMP DATA                                             *     07 08790011
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP          *     07 08800011
*                     REG 1  = ADDRESS OF DATA TO DUMP         *     07 08810011
*                                                              *     07 08820011
****************************************************************     07 08830011
DMP      DS    0H                                                    07 08840011
         STM   R0,R15,W#DMPRGS         Save registers                07 08850011
         LR    R8,R1                   Get address to dump           07 08860011
         LR    R6,R0                   Get length                    07 08870011
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump          07 08880011
         MVI   W#DMPFLG,W#DMP1ST       First line                    07 08890011
DMPDMPLP DS    0H                                                    07 08900011
         LTR   R6,R6                   Any data to dump?             07 08910011
         BZ    DMPHEXXT                Yes, all done                 07 08920011
         TM    W#DMPFLG,W#DMP1ST       First line?                   07 08930011
         BO    DMPALIN                 Yes, can't have same as above 07 08940011
         LA    R0,32                   Default length                07 08950011
         CR    R6,R0                   Length longer than 32?        07 08960011
         BNH   DMPDUPCK                No, were at last line         07 08970011
         LR    R14,R8                  Get current input area        07 08980011
         SR    R14,R0                  Back to previous area         07 08990011
         CLC   0(32,R14),0(R8)         Duplicate of previous line    07 09000011
         BNE   DMPDUPCK                No, do lines same as          07 09010011
         SR    R6,R0                   Reduce length to do           07 09020011
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?        07 09030011
         BO    DMPNXTLN                Yes, we have first offset     07 09040011
         L     R14,W#DMPOFF            Get current offset            07 09050011
         ST    R14,W#DUP1ST            Save as first offset          07 09060011
         OI    W#DMPFLG,W#DMPDUP       Set duplicate                 07 09070011
         B     DMPNXTLN                Continue                      07 09080011
DMPDUPCK DS    0H                                                    07 09090011
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?        07 09100011
         BNO   DMPALIN                 No, no duplicate to report    07 09110011
         MVC   PRTLINE+7(5),=C'Lines'  Move literal                  07 09120011
         LA    R2,PRTLINE+13           Output area address           07 09130011
         LA    R1,W#DUP1ST+2           Address of offset to dump     07 09140011
         LA    R15,2                   Convert 4 bytes               07 09150011
         BAL   R14,DMPDSP              Convert it to display         07 09160011
         MVI   PRTLINE+17,C'-'         Thru literal                  07 09170011
         L     R1,W#DMPOFF             Get current offset            07 09180011
         S     R1,=A(32)               Get last duplicate offset     07 09190011
         ST    R1,W#DUP1ST             Save for dumping              07 09200011
         LA    R2,PRTLINE+18           Output area address           07 09210011
         LA    R1,W#DUP1ST+2           Address of offset to dump     07 09220011
         LA    R15,2                   Convert 4 bytes               07 09230011
         BAL   R14,DMPDSP              Convert it to display         07 09240011
         MVC   PRTLINE+23(13),=C'same as above' move literal         07 09250011
         BAL   R9,PRINT                Print a line                  07 09260011
         NI    W#DMPFLG,255-W#DMPDUP   Reset duplicate in progress   07 09270011
DMPALIN  DS    0H                                                    07 09280011
         LA    R2,PRTLINE+1            Output area address           07 09290011
         LA    R1,W#DMPOFF+2           Address of offset to dump     07 09300011
         LA    R15,2                   Convert 4 bytes               07 09310011
         BAL   R14,DMPDSP              Convert it to display         07 09320011
         LA    R2,2(,R2)               Skip 1 between offset & data  07 09330011
         LR    R1,R8                   Address of data               07 09340011
         LA    R7,32                   Default length                07 09350011
         CR    R6,R7                   Length longer than 32 ?       07 09360011
         BH    DMPDODMP                Yes, use 32                   07 09370011
         LR    R7,R6                   Use what is left              07 09380011
DMPDODMP DS    0H                                                    07 09390011
         SR    R6,R7                   Reduce amount to do           07 09400011
         MVI   PRTLINE+82,C'*'         Box in display portion        07 09410011
         BCTR  R7,0                    Make zero based               07 09420011
         EX    R7,DMPMVC               Do move                       07 09430011
         EX    R7,DMPTR                Translate out bad stuff       07 09440011
         LA    R7,1(,R7)               Restore length                07 09450011
         MVI   PRTLINE+114,C'*'        Complete box                  07 09460011
DMPDMPHX DS    0H                                                    07 09470011
         LA    R15,4                   4 bytes to process            07 09480011
         CR    R7,R15                  Length longer than 4?         07 09490011
         BH    DMPDMPIT                Yes, dump 4 bytes             07 09500011
         LR    R15,R7                  Use length left               07 09510011
DMPDMPIT DS    0H                                                    07 09520011
         SR    R7,R15                  Reduce amount to do           07 09530011
         BAL   R14,DMPDSP              Convert data                  07 09540011
         LA    R2,1(,R2)               Skip 1 byte                   07 09550011
         LA    R0,PRTLINE+43           Halfway point address         07 09560011
         CR    R0,R2                   At halfway point?             07 09570011
         BNE   DMPDMPNX                No, continue                  07 09580011
         LA    R2,1(,R2)               Skip 1 byte                   07 09590011
DMPDMPNX DS    0H                                                    07 09600011
         LTR   R7,R7                   Any left to do ?              07 09610011
         BH    DMPDMPHX                Yes, go do it                 07 09620011
         BAL   R9,PRINT                Print a line                  07 09630011
DMPNXTLN DS    0H                                                    07 09640011
         L     R1,W#DMPOFF             Get offset in record          07 09650011
         LA    R1,32(,R1)              Add in length we will dump    07 09660011
         ST    R1,W#DMPOFF             Save offset in record         07 09670011
         LA    R8,32(,R8)              Next input area               07 09680011
         NI    W#DMPFLG,255-W#DMP1ST   Not first line                07 09690011
         B     DMPDMPLP                Loop thru until done          07 09700011
DMPHEXXT DS    0H                                                    07 09710011
         LM    R0,R15,W#DMPRGS         Restore callers regs          07 09720011
         BR    R14                     Exit . . .                    07 09730011
DMPMVC   MVC   PRTLINE+83(0),0(R1)     <<< executed >>>              07 09740011
DMPTR    TR    PRTLINE+83(0),P#DMPTBL  <<< executed >>>              07 09750011
*                                                                    07 09760011
*        Convert hex data to display                                 07 09770011
*                                                                    07 09780011
DMPDSP   DS    0H                                                    07 09790011
         UNPK  0(1,R2),0(1,R1)         Get first hex byte            07 09800011
         NI    0(R2),X'0F'             Remove zone                   07 09810011
         MVC   1(1,R2),0(R1)           Move second hex byte          07 09820011
         NI    1(R2),X'0F'             Remove its zone also          07 09830011
         TR    0(2,R2),TRTBL           Translate to hex              07 09840011
         LA    R2,2(,R2)               Point to next output area     07 09850011
         LA    R1,1(,R1)               Point to next input area      07 09860011
         BCT   R15,DMPDSP              Loop thru data                07 09870011
         BR    R14                     Exit                          07 09880011
****************************************************************        09890000
*                                                              *        09900000
* MISCELLANEOUS ERROR MESSAGES.                                *        09910000
*                                                              *        09920000
****************************************************************        09930000
PRMERR   DS    0H                                                       09940000
         MVC   PRT(5),=C'PARM='        MOVE PARAMETER INFO LITERAL      09950000
         L     R14,PRMSTRT             PARM START                       09960000
         SR    R1,R14                  LESS START                       09970000
         LA    R2,PRT+5(R1)            SET LOCATION OF ERROR            09980000
         SH    R14,=H'+2'              BACK TO LENGTH                   09990000
         LH    R1,0(,R14)              GET LENGTH                       10000000
         BCTR  R1,0                    MAKE MACHINE LENGTH              10010000
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE          10020000
         BAL   R9,PRINT                PRINT A LINE                  07 10030011
         MVI   0(R2),C'*'              MARK WHERE ERROR IS              10040000
         BAL   R9,PRINT                PRINT A LINE                     10050000
         MVC   PRT(15),=C'Parameter error'                              10060000
         LA    R2,1                    Error reason 1                06 10070009
         B     ERREND                  GO PRINT                         10080000
PRMMVC   MVC   PRT+5(0),2(R14)         EXECUTED PARM MOVE               10090000
NOMBR    DS    0H                                                       10100000
         MVC   PRT(25),=C'Member name not specified'                    10110000
         LA    R2,2                    Error reason 2                06 10120009
         B     ERREND                  GO PRINT                         10130000
MISSMEM  DS    0H                                                       10140000
         MVC   PRT(8),MEMBER           LOAD MODULE NAME                 10150000
         MVC   PRT+9(12),=C'not found in'                               10160000
         MVC   PRT+22(8),LIBDDN        LIBRARY DD NAME                  10170000
         LA    R2,3                    Error reason 3                06 10180009
         B     ERREND                  GO PRINT                         10190000
SYMFULL  DS    0H                                                       10200000
         MVC   PRT(36),=C'Symbol table full: over 5000 entries'         10210000
         LA    R2,4                    Error reason 4                06 10220009
ERREND   DS    0H                                                       10230000
         STCM  R2,7,TOTVIRT            Save reason code for R0       06 10240009
         BAL   R9,PRINT                GO PRINT MESSAGE                 10250000
         SR    R12,R12                 No table returned             05 10260008
         LA    R2,8                    SET RETURN CODE TO 8             10270000
         B     CLOSES                  YES, STOP THE RUN                10280000
****************************************************************        10290000
*                                                              *        10300000
*        END OF PROCESSING                                     *        10310000
*                                                              *        10320000
****************************************************************        10330000
ENDINIT  DS    0H                                                       10340000
         L     R1,SYMTBAD              GET SYMBOL TABLE ADDRESS         10350000
         USING SYMTBL,R1                                                10360000
         SR    R2,R2                   COUNT OF CSECTS                  10370000
         C     R1,CURRSYM              END OF TABLE                  04 10380007
         BNL   SYMEMPTY                YES, EMPTY TABLE              07 10390010
SYMSCN   DS    0H                                                       10400000
         CLI   TYPSYM,0                IS IT SD                         10410000
         BE    SYMSCNCT                YES                              10420000
         CLI   TYPSYM,X'0D'            IS IT SD                         10430000
         BE    SYMSCNCT                YES                              10440000
         CLI   TYPSYM,4                IS IT PC                         10450000
         BE    SYMSCNCT                YES                              10460000
         CLI   TYPSYM,X'0E'            IS IT PC                         10470000
         BE    SYMSCNCT                YES                              10480000
         B     SYMSCNNX                NO                               10490000
SYMSCNCT DS    0H                                                       10500000
         LA    R2,1(,R2)               COUNT CSECTS                     10510000
SYMSCNNX DS    0H                                                       10520000
         LA    R1,L'SYMENT(,R1)        TO NEXT TBL ENTRY LOCATION       10530000
         C     R1,CURRSYM              END OF TABLE                     10540000
         BL    SYMSCN                  NO, CONTINUE SCAN                10550000
         B     SYMSCNND                End of symbol table           07 10560010
         DROP  R1                                                       10570000
SYMEMPTY DS    0H                                                    07 10580010
         MVC   PRT(21),=C'Module has no symbols'                     07 10590010
         BAL   R9,PRINT                Print message                 07 10600010
         LA    R2,6                    Error reason 6                07 10610011
         STCM  R2,7,TOTVIRT            Save reason code for R0       07 10620010
         LA    R2,8                    Set return code to 8          07 10630010
         B     CLOSES                                                07 10640010
SYMSCNND DS    0H                                                    04 10650007
         LTR   R12,R2                  ANY CSECTS                       10660000
         BZ    FREES                   NO, SKIP TABLE BUILD             10670000
         MH    R2,=AL2(CSENTLN)        LENGTH OF NEW CSECT ONLY TABLE   10680000
         LA    R2,4(,R2)               INCLUDE SIZE                     10690000
         GETMAIN R,LV=(R2)             GETMAIN NEW CSECT TABLE          10700000
         LR    R12,R1                  NEW CSECT TABLE ADDRESS          10710000
         ST    R2,0(,R12)              LENGTH OF CSECT TABLE            10720000
         L     R1,SYMTBAD              GET SYMBOL TABLE ADDRESS         10730000
         USING SYMTBL,R1                                                10740000
         LA    R15,4(,R12)             PAST LENGTH FOR FIRST CSECT      10750000
         USING CSTBL,R15                                                10760000
         C     R1,CURRSYM              END OF TABLE                  04 10770007
         BNL   FREES                   YES, EMPTY TABLE              04 10780007
SYMBLD   DS    0H                                                       10790000
         CLI   TYPSYM,0                IS IT SD                         10800000
         BE    SYMBLDEN                YES                              10810000
         CLI   TYPSYM,X'0D'            IS IT SD                         10820000
         BE    SYMBLDEN                YES                              10830000
         CLI   TYPSYM,4                IS IT PC                         10840000
         BE    SYMBLDEN                YES                              10850000
         CLI   TYPSYM,X'0E'            IS IT PC                         10860000
         BE    SYMBLDEN                YES                              10870000
         B     SYMBLDNX                NO                               10880000
SYMBLDEN DS    0H                                                       10890000
         MVC   CSNAME,EXTSYM                                            10900000
         MVC   CSLENG,SYMLENG          LENGTH                           10910000
         MVC   CSADDR,SYMADDR          ADDRESS                       03 10920006
         LA    R15,CSENTLN(,R15)       NEXT ENTRY                       10930000
SYMBLDNX DS    0H                                                       10940000
         LA    R1,L'SYMENT(,R1)        TO NEXT TBL ENTRY LOCATION       10950000
         C     R1,CURRSYM              END OF TABLE                     10960000
         BL    SYMBLD                  NO, CONTINUE BUILD               10970000
         DROP  R1                                                       10980000
         DROP  R15                                                      10990000
FREES    DS    0H                                                       11000000
         SR    R2,R2                   Return code 0                 05 11010008
CLOSES   DS    0H                                                    05 11020008
         L     R1,BUFAD                GET BUFFER ADDRESS               11030000
         LTR   R1,R1                   Buffer obtained?              05 11040008
         BZ    CLOSES05                No, skip free                 05 11050010
         FREEMAIN R,A=(1),LV=32768     FREE BUFFER                      11060000
         B     CLOSES10                                                 11070010
CLOSES05 DS    0H                                                    07 11080010
         MVC   PRT(18),=C'Module has no text'                        07 11090010
         BAL   R9,PRINT                Print message                 07 11100010
         LA    R2,5                    Error reason 5                07 11110010
         STCM  R2,7,TOTVIRT            Save reason code for R0       07 11120010
         LA    R2,8                    Set return code to 8          07 11130010
CLOSES10 DS    0H                                                    05 11140008
         L     R1,SYMTBAD              ADDRESS OF ESD SYMBOL TABLE      11150000
         LTR   R1,R1                   Symbol table obtained?        05 11160008
         BZ    CLOSES20                No, skip free                 06 11170009
         FREEMAIN R,A=(1),LV=95000     FREE SYMBOL TABLE                11180000
CLOSES20 DS    0H                                                    05 11190008
         CLOSE (SYSLIB),MF=(E,OPENLIST) CLOSE LIBRARY                   11200000
         TM    SYSLIB+23,1             BUFFER POOL FREED                11210000
         BO    CLOSES30                Yes, skip FREEPOOL            05 11220008
         FREEPOOL SYSLIB               RELEASE BUFFERS                  11230000
CLOSES30 DS    0H                                                    05 11240008
         TM    PRINTDD+48,16           IS PRINTDD OPEN                  11250000
         BNO   CLOSES40                No, skip CLOSE                05 11260008
         CLOSE (PRINTDD),MF=(E,OPENLIST) CLOSE PRINTDD                  11270000
         TM    PRINTDD+23,1            BUFFER POOL FREED                11280000
         BO    CLOSES40                Yes, skip FREEPOOL            05 11290008
         FREEPOOL PRINTDD              RELEASE BUFFERS                  11300000
CLOSES40 DS    0H                                                    05 11310008
         SLR   R10,R10                                               06 11320009
         ICM   R10,7,TOTVIRT           Pass back size of load module 06 11330009
         LR    R11,R13                 WORK AREA ADDRESS                11340000
         L     R13,4(,R13)             GET CALLER'S SAVE AREA           11350000
         FREEMAIN R,A=(11),LV=WORKLEN  FREE WORK ARA                    11360000
         L     R14,12(,R13)            RESTORE CALLER'S R14             11370000
         LR    R15,R2                  SET RETURN CODE IN R15           11380000
         LR    R0,R10                  Load module size/error code   06 11390009
         LR    R1,R12                  PASS BACK our R1                 11400000
         LM    R2,R12,28(R13)          RESTORE CALLER'S R2-R12          11410000
         BR    R14                     RETURN TO CALLER                 11420000
****************************************************************     05 11430008
*        SYSLIB SYNAD (error handler)                          *     05 11440008
****************************************************************     05 11450008
SYNADLIB DS    0H                                                    05 11460008
         LR    R9,R13                  Save 13                       05 11470008
         DROP  R13                                                   05 11480008
         USING WORKAREA,R9                                           05 11490008
         SYNADAF ACSMETH=BSAM,PARM1=(1),PARM2=(0)                    05 11500008
         MVC   PRT(9),=C'I/O error'                                  05 11510008
         MVC   PRT+10(60),68(R1)       Copy I/O error message        05 11520008
         SYNADRLS ,                    Release storage               05 11530008
         LR    R13,R9                  Restore R13                   05 11540008
         DROP  R9                                                    06 11550009
         USING WORKAREA,R13                                          05 11560008
         BAL   R9,PRINT                GO PRINT MESSAGE              05 11570008
         MVC   PRT(22),=C'TTR of module invalid:'                    05 11580008
         LA    R12,TTRMOD              Address of TTR                05 11590008
         BAL   R9,HEXPRT3              Convert to display            05 11600008
         MVC   PRT+23(6),PRTABL        TTR to print                  05 11610008
         MVC   PRT+30(6),=C'reads:'                                  05 11620008
         LA    R12,READCT              Address of READ counter       05 11630008
         BAL   R9,HEXPRT4              Convert to display            05 11640008
         MVC   PRT+37(8),PRTABL        Read counter to print         05 11650008
         BAL   R9,PRINT                GO PRINT MESSAGE              05 11660008
         SR    R12,R12                 No table                      05 11670008
         B     FREES                   Print and exit                05 11680008
         DROP  ,                                                     05 11690008
****************************************************************        11700000
*                                                              *        11710000
*        CONSTANTS                                             *        11720000
*                                                              *        11730000
****************************************************************        11740000
         DC    0D'+0'                                                   11750000
         LTORG ,                                                        11760000
SYMHDR   DC    C'      Symbol        Type Ind Address  Seg  Lrid  Lengt*11770000
               h ESDID'                                                 11780000
RLDHDR   DC    C'      Relptr Posptr     Type  Length    Dir  Address  *11790000
                         Name Type'                                     11800000
LBLHDR   DC    C'     Address Type Symbol   Len'                        11810000
*                                                                       11820000
BLANX    DC    CL121' '                CONSTANT BLANKS                  11830000
TRTBL    DC    C'0123456789ABCDEF'     TRANSLATE TBL                    11840000
LIBMDL   DCB   DSORG=PO,MACRF=R,DDNAME=SYSLIB,                         X11850000
               RECFM=U,NCP=1,EODAD=ENDINIT,SYNAD=SYNADLIB            05 11860008
PRINTMDL DCB   DSORG=PS,MACRF=PM,DDNAME=PRINTDD,                       X11870000
               RECFM=FBA,LRECL=121                                      11880000
OPNMDL   OPEN  (0),MF=L                                                 11890000
P#DMPTBL DC    CL256' '                                              07 11900011
         ORG   P#DMPTBL+X'4A' Cent                                   07 11910011
         DC    X'4A4B4C4D4E4F50'                                     07 11920011
         ORG   P#DMPTBL+X'5A' exclamation                            07 11930011
         DC    X'5A5B5C5D5E5F6061'                                   07 11940011
         ORG   P#DMPTBL+X'6A'                                        07 11950011
         DC    X'6A6B6C6D6E6F'                                       07 11960011
         ORG   P#DMPTBL+X'7A'                                        07 11970011
         DC    X'7A7B7C7D7E7F'                                       07 11980011
         ORG   P#DMPTBL+C'a'                                         07 11990011
         DC    C'abcdefghi'                                          07 12000011
         ORG   P#DMPTBL+C'j'                                         07 12010011
         DC    C'jklmnopqr'                                          07 12020011
         ORG   P#DMPTBL+C's'                                         07 12030011
         DC    C'stuvwxyz'                                           07 12040011
         ORG   P#DMPTBL+C'A'                                         07 12050011
         DC    C'ABCDEFGHI'                                          07 12060011
         ORG   P#DMPTBL+C'J'                                         07 12070011
         DC    C'JKLMNOPQR'                                          07 12080011
         ORG   P#DMPTBL+C'S'                                         07 12090011
         DC    C'STUVWXYZ'                                           07 12100011
         ORG   P#DMPTBL+C'0'                                         07 12110011
         DC    C'0123456789'                                         07 12120011
         ORG   ,                                                     07 12130011
         DC    0D'+0'                                                   12140000
****************************************************************        12150000
*                                                              *        12160000
*        WORK AREAS                                            *        12170000
*                                                              *        12180000
****************************************************************        12190000
WORKAREA DSECT ,                                                        12200000
SAVEAREA DC    18A(0)                                                   12210000
PRMSTRT  DC    F'0'                    PARAMETER ADDRESS                12220000
LINECT   DC    PL2'0'                  PRINT LINE COUNTER               12230000
W#PGCT   DS    PL2'+0'                                               07 12240011
START    DC    F'0'                    LKED ASSIGNED START ADDR OF CSEC 12250000
END      DC    F'0'                    CSECT END ADDRESS                12260000
LENGTH   DC    F'0'                    LENGTH OF SPECIFIED CSECT        12270000
PRMOPT   DC    X'00'                                                    12280000
PRMOPTSU EQU   X'80'                   OPTIONS=SUMMARY                  12290000
LIBDDN   DC    CL8'SYSLIB'                                              12300000
*                                                                       12310000
*                                                                       12320000
*                                                                       12330000
W#HD1    DS    CL121                                                 07 12340011
         ORG   W#HD1+(120/2)-(15/2)                                  07 12350011
W#HD1TTL DS    C'Map Load Module'                                    07 12360011
         ORG   W#HD1+L'W#HD1-8                                       07 12370011
W#HD1PG  DS    C'Page'                                               07 12380011
W#HD1PG# DS    C' 123'                                               07 12390011
*                                                                    07 12400011
PRTLINE  DS    0CL121                  PRINT LINE                       12410000
PCC      DC    C'1'                    CARRIAGE CONTROL                 12420000
PRT      DC    CL120' '                PRINT DATA                       12430000
*                                                                       12440000
*                                                                       12450000
*                                                                       12460000
         DC    0D'+0'                                                   12470000
BLDLIST  DS    XL62                    BLDL LIST                        12480000
         ORG   BLDLIST                                                  12490000
BLDLNO   DC    H'1'                    ONE ENTRY                        12500000
BLDLLEN  DC    H'58'                   LENGTH OF ENTRY                  12510000
MEMBER   DC    CL8' '                  MEMBER NAME                      12520000
TTRMOD   DC    XL3'000000'             TTR OF MODULE                    12530000
CCAT     DC    XL1'00'                 CONCATENATION NUMBER             12540000
         DC    XL1'00'                                                  12550000
ALIASIND DC    XL1'00'                 ALIAS AND MISC INDICATOR         12560000
*                           80=ALIAS                                    12570000
TTR1TXT  DC    XL3'000000'             TTR OF 1ST TXT RECORD            12580000
         DC    XL1'00'                                                  12590000
TTRNS    DC    XL3'000000'             TTR OF NOTE OR SCATTER LIST      12600000
NNOTE    DC    XL1'00'                 NBR ENTRIES IN NOTE LIST         12610000
ATTR1A   DC    XL1'00'                 MODULE ATTRIBUTES 1, BYTE 1      12620000
*                           80=RENT                                     12630000
*                           40=REUS                                     12640000
*                           20=OVERLAY                                  12650000
*                           10=UNDER TEST                               12660000
*                           08=ONLY LOADABLE                            12670000
*                           04=SCATTER FORMAT                           12680000
*                           02=EXECUTABLE                               12690000
*                           01=ONE TXT, NO RLD RECORDS                  12700000
ATTR1B   DC    XL1'00'                 ATTRIBUTES 1, BYTE 2             12710000
*                           80=CANNOT BE REPROCESSED BY LKED E          12720000
*                           40=ORIGIN OF 1ST TXT RECORD IS ZERO         12730000
*                           20=ASSIGNED ENTRY POINT ADDR IS ZERO        12740000
*                           10=CONTAINS NO RLD RECORD                   12750000
*                           08=CANNOT BE REPROCESSED BY LKED            12760000
*                           04=CONTAINS TESTRAN SYMBOLS                 12770000
*                           02=CREATED BY LKED                          12780000
*                           01=REFR                                     12790000
TOTVIRT  DC    XL3'000000'             TOTAL VIRTUAL STRG REQRD FOR MOD 12800000
LENG1    DC    XL2'0000'               LENGTH OF 1ST TEXT RECORD        12810000
LKEPA    DC    XL3'000000'             ASSIGNED ENTRY POINT ADDR        12820000
ATTR2    DC    XL1'00'                 ATTRIBUTES 2                     12830000
*                           80=PROCESSED BY OS/VS LKED                  12840000
*                           40=MODULE REQUIRES 16M OR MORE              12850000
*                           20=PAGE ALIGNMENT REQUIRED FOR MODULE       12860000
*                           10=SSI PRESENT                              12870000
*                           08=AUTH CODE INFO VALID                     12880000
*                           04=PROGRAM OBJECT                           12890000
*                           02=                                         12900000
*                           01=                                         12910000
ATTR2B   DC    XL1'00'                 ATTRIBUTES 2                     12920000
*                           80=PRIMARY NAME GENERATED                   12930000
*                           40=                                         12940000
*                           20=                                         12950000
*                           10=1=RMODE=ANY 0=RMODE=24                   12960000
*                           0C=ALIAS EPA ADDRESSING MODE                12970000
*                              00=AMODE=24                              12980000
*                              10=AMODE=31                              12990000
*                              01=AMODE=64                              13000000
*                              11=AMODE=ANY                             13010000
*                           03=MAIN EPA ADDRESSING MODE                 13020000
*                              00=AMODE=24                              13030000
*                              10=AMODE=31                              13040000
*                              01=AMODE=64                              13050000
*                              11=AMODE=ANY                             13060000
ATTR2C   DC    XL1'00'                 NUMBER OF RLD/CONTROL RECORDS    13070000
*                           80=PROGRAM OBJECT CAN'T BE CONVERTED        13080000
*                           40=FETCHOPT PRIME                           13090000
*                           20=FETCHOPT PACK                            13100000
SCTRLEN  DC    XL2'0000'               SCATTER LIST LENGTH              13110000
TTLEN    DC    XL2'0000'               TRANSLATION TABLE LENGTH         13120000
SCESDID  DC    XL2'0000'               CESD NBR FOR 1ST TXT RECD        13130000
SCEPESD  DC    XL2'0000'               CESD NBR FOR ENTRY POINT         13140000
ALEPA    DC    XL3'000000'             ENTRY POINT OF THE MEMBER NAME   13150000
ALMEM    DC    CL8' '                  REAL MEMBER NAME FOR ALIAS       13160000
SSI      DC    XL4'00000000'           SSI BYTES                        13170000
AUTHLEN  DC    XL1'00'                 AUTH CODE LENGTH                 13180000
AUTHCOD  DC    XL1'00'                 AUTH CODE                        13190000
         ORG   ,                                                        13200000
BLDLEND  EQU   *                                                        13210000
*                                                                       13220000
*                                                                       13230000
*                                                                       13240000
READCT   DC    F'0'                    READs to SYSLIB               05 13250008
BUFAD    DC    F'0'                    SYSLIB BUFFER ADDR               13260000
SYMTBAD  DC    F'0'                    SYMBOL TABLE ADDRESS             13270000
CURRSYM  DC    F'0'                    CURRENT SYM TBL ADDR             13280000
ENDSYM   DC    F'95000'                SYM TBL END ADDR                 13290000
PROCSW   DC    XL1'00'                 PROCESS INDICATOR                13300000
PROCSWOK EQU   X'40'                   MODULE PROCESSING DONE           13310000
PROCSWSK EQU   X'10'                   SKIP PRINT (SUMMARY)             13320000
CES9     DC    F'0'                    CESDREC RETURN ADDR              13330000
BL9      DC    F'0'                    BLDL RTN RETURN ADDR             13340000
CR9      DC    F'0'                    CTRLRECS RETURN ADDR             13350000
CT9      DC    F'0'                    CNTLRECS RETURN ADDR             13360000
PRTABL   DC    CL9' '                  HEX-PRINTABLE CONVERSION AREA    13370000
*                                                                       13380000
*                                                                       13390000
*                                                                       13400000
DEVTYPE  DC    D'0'                                                     13410000
OPENLIST OPEN  (0),MF=L                                                 13420000
OPNLST   EQU   OPENLIST,*-OPENLIST                                      13430000
         READ  DECB,SF,,,'S',MF=L                                       13440000
SYSLIB   DCB   DSORG=PO,MACRF=R,DDNAME=SYSLIB,                         X13450000
               RECFM=U,NCP=1,SYNAD=SYNADLIB                          05 13460008
LIBDCB   EQU   SYSLIB,*-SYSLIB                                          13470000
PRINTDD  DCB   DSORG=PS,MACRF=PM,DDNAME=PRINTDD,                       X13480000
               RECFM=FBA,LRECL=121                                      13490000
PRINTDCB EQU   PRINTDD,*-PRINTDD                                        13500000
*                                                                    07 13510011
W#DMPRGS DS    16A                                                   07 13520011
W#DMPA14 DS    A                                                     07 13530011
W#DMPOFF DS    A                                                     07 13540011
W#DUP1ST DS    A                                                     07 13550011
W#DMPFLG DS    X                                                     07 13560011
W#DMP1ST EQU   X'80'                                                 07 13570011
W#DMPDUP EQU   X'40'                                                 07 13580011
         DC    0D'+0'                                                   13590000
WORKLEN  EQU   *-WORKAREA                                               13600000
*                                                                       13610000
*                                                                       13620000
*                                                                       13630000
SYMTBL   DSECT ,                       EXTERNAL SYMBOL TABLE ENTRY      13640000
SYMENT   DS    0CL19                   19 BYTE ENTRIES                  13650000
EXTSYM   DS    CL8                     EXTERNAL SYMBOL NAME             13660000
TYPSYM   DS    XL1                     SYMBOL TYPE                      13670000
*                        00=SD (NAMED CSECT)                            13680000
*                        02=ER (EXTRN)                                  13690000
*                        03=LR (ENTRY)                                  13700000
*                        04=PC (UNNAMED CSECT)                          13710000
*                        05=CM (COM)                                    13720000
*                        06=PR (PSEUDO REGISTER)                        13730000
*                        07=NULL                                        13740000
*                        0A=WX (WXTRN)                                  13750000
*                        0D=SD (NAMED CSECT)                            13760000
*                        0E=PC (UNNAMED CSECT)                          13770000
*                        0F=ENTAB OR SEGTAB                             13780000
SYMIND   DS    XL1                     INDICATOR                        13790000
*                        BIT 0 = MAP                                    13800000
*                        BIT 1 = CHAIN                                  13810000
*                        BIT 2 = INSERT                                 13820000
*                        BIT 3 = DELETE/REPLACE                         13830000
SYMADDR  DS    XL3                     SYMBOL ADDRESS (0 FOR ER, WX, NU 13840000
SYMSEG   DS    XL1                     SEGMENT ID (0 FOR ER, WX, NULL)  13850000
SYMLRID  DS    0XL2                    ESD ID OF DEF FOR LR             13860000
SYMLENG  DS    XL3                     LENGTH FOR SD, PC, CM, PR        13870000
*                        0 FOR ER, WX, NULL                             13880000
SYMESDID DS    XL2                     ESD ID OF THIS ITEM              13890000
*                                                                       13900000
*                                                                       13910000
*                                                                       13920000
CSTBL    DSECT ,                       CSECT TABLE                      13930000
CSNAME   DS    CL8                     CSECT NAME                       13940000
CSLENG   DS    XL3                     LENGTH OF CSECT                  13950000
CSADDR   DS    XL3                     ADDRESS OF CSECT              03 13960006
CSENTLN  EQU   *-CSTBL                 LENGTH OF CSECT ENTRY            13970000
****************************************************************     07 13980011
*                                                              *     07 13990011
*        SYSTEM DSECTS                                         *     07 14000011
*                                                              *     07 14010011
****************************************************************     07 14020011
         DCBD DSORG=PO                                               07 14030011
****************************************************************        14040000
*                                                              *        14050000
*        EQUATES                                               *        14060000
*                                                              *        14070000
****************************************************************        14080000
R0       EQU   0                                                        14090000
R1       EQU   1                                                        14100000
R2       EQU   2                                                        14110000
R3       EQU   3                                                        14120000
R4       EQU   4                                                        14130011
R5       EQU   5                                                        14140000
R6       EQU   6                                                        14150000
R7       EQU   7                                                        14160000
R8       EQU   8                                                        14170000
R9       EQU   9                                                        14180000
R10      EQU   10                                                       14190000
R11      EQU   11                                                       14200000
R12      EQU   12                                                       14210000
R13      EQU   13                                                       14220000
R14      EQU   14                                                       14230000
R15      EQU   15                                                       14240000
         END   ,                                                        14250000
