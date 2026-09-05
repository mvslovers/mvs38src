         TITLE 'Disk Data Set Statistics'                               00010001
         MACRO                                                          00020002
&LBL     OUTPT   &OP1,&OP2,&LN=                                         00030002
         LCLC   &REG                                                    00040002
         AIF   (T'&LBL EQ 'O').NOLBL                                    00050002
&LBL     DS    0H                                                       00060002
.NOLBL   ANOP ,                                                         00070002
         AIF   (T'&LN EQ 'O').USELEN                                    00080002
         AIF   ('&LN' EQ '(R15)').TYPE                                  00090002
         AIF   ('&LN'(1,1) EQ '(').REGL                                 00100002
         LA    R15,&LN            Length of string                      00110002
         AGO   .TYPE                                                    00120002
.REGL    ANOP ,                                                         00130002
&REG     SETC  '&LN'(2,K'&LN-2)                                         00140002
         LR    R15,&REG           Length of string                      00150002
         AGO   .TYPE                                                    00160002
.USELEN  ANOP  ,                                                        00170002
         LA    R15,L'&OP2         Length of string                      00180002
.TYPE    ANOP  ,                                                        00190002
         AIF   ('&OP1' EQ '(R0)').R0SET                                 00200002
         AIF   ('&OP1'(1,1) EQ '(').REGN                                00210002
         L     R0,&OP1            Number to be output                   00220002
         AGO   .R0SET                                                   00230002
.REGN    ANOP ,                                                         00240002
&REG     SETC  '&OP1'(2,K'&OP1-2)                                       00250002
         LR    R0,&REG            Number to be output                   00260002
.R0SET   ANOP ,                                                         00270002
         AIF   ('&OP2' EQ '(R1)').CALL                                  00280002
         AIF   ('&OP2'(1,1) EQ '(').REG2                                00290002
         L     R1,=A(&OP2)        String to follow                      00300002
         AGO   .CALL                                                    00310002
.REG2    ANOP ,                                                         00320002
&REG     SETC  '&OP2'(2,K'&OP2-2)                                       00330002
         LR    R1,&REG            String to follow                      00340002
.CALL    ANOP ,                                                         00350002
         BAL   R14,OUTNUM         Output routine                        00360002
         AGO   .MEND                                                    00370002
.MEND    MEND  ,                                                        00380002
*                                                                       00390002
*        TTR to MBBCCHHR Conversion                                     00400002
*                                                                       00410002
         MACRO ,                                                        00420002
&LBL     TTRMBB &TTR=,&MBB=W#DWORD,&ERRET=                              00430002
         AIF   (T'&LBL EQ 'O').NOLBL                                    00440002
&LBL     DS    0H                                                       00450002
.NOLBL   ANOP ,                                                         00460002
         STM   R14,R12,12(R13)    Save registers                        00470002
         ICM   R1,15,&TTR         TTR                                   00480002
         SLDL  R0,24              Shift TTR into r0                     00490002
         SLL   R0,8               Adjust                                00500002
         L     R1,DCBDEBAD        DEB address                           00510002
         N     R1,=X'00FFFFFF'    Clean DEB address                     00520002
         LA    R2,&MBB            Result address                        00530002
         LR    R3,R13             Save savearea register                00540002
         L     R15,CVTPTR         CVT pointer                           00550002
         USING CVT,R15                                                  00560002
         L     R15,CVTPCNVT       TTRN to MBBCCHHR routine address      00570002
         DROP  R15                                                      00580002
         BALR  R14,R15            Convert TTR to MBBCCHHR               00590002
         LR    R13,R3             Restore save area address             00600002
         ST    R15,16(,R13)       Save return code                      00610002
         LM    R14,R12,12(R13)    Restore registers                     00620002
         AIF   (T'&ERRET EQ 'O').NOERR                                  00630002
         LTR   R15,R15            Successful convert                    00640002
         BNZ   &ERRET             No, error                             00650002
.NOERR   ANOP ,                                                         00660002
         MEND  ,                                                        00670002
*                                                                       00680002
*        MBBCCHHRR to TTR0 Conversion                                   00690002
*                                                                       00700002
         MACRO ,                                                        00710002
&LBL     MBBTTR  &MBB,&TTR=W#TEMP,&ERRET=                               00720002
         LCLC    &L                                                     00730002
&L       SETC    '&SYSNDX'                                              00740002
         AIF   (T'&LBL EQ 'O').NOLBL                                    00750002
&LBL     DS    0H                                                       00760002
.NOLBL   ANOP ,                                                         00770002
         STM   R14,R12,12(R13)    Save registers                        00780002
         L     R1,DCBDEBAD        DEB address                           00790002
         N     R1,=X'00FFFFFF'    Clean DEB address                     00800002
         LA    R2,&MBB            MBBCCHHR address                      00810002
         LR    R3,R13             Save savearea register                00820002
         L     R15,CVTPTR         CVT pointer                           00830002
         USING CVT,R15                                                  00840002
         L     R15,CVTPRLTV       MBBCCHHR to TTR0 routine address      00850002
         DROP  R15                                                      00860002
         BALR  R14,R15            Convert MBBCCHHR to TTR0              00870002
         LR    R13,R3             Restore save area address             00880002
         STM   R15,R0,16(R13)     Save return code/TTR0                 00890002
         LM    R14,R12,12(R13)    Restore registers                     00900002
         AIF   (T'&ERRET EQ 'O').NOERR                                  00910002
         LTR   R15,R15            Successful convert                    00920002
         BNZ   &ERRET             No, error                             00930002
.NOERR   ANOP ,                                                         00940002
         ST    R0,&TTR            Save TTR0                             00950002
         MEND                                                           00960002
*                                                                       00970002
*        Hex Formatter like C1.C2.C3 . . .                              00980002
*                                                                       00990002
         MACRO                                                          01000002
&LBL     HEXES   &SRC,&NUM,&OUT                                         01010002
         LCLC    &LB1,&LB2,&LB3                                         01020002
         AIF     (T'&LBL EQ 'O').NOLBL                                  01030002
&LBL     DS      0H                                                     01040002
.NOLBL   ANOP                                                           01050002
&LB1     SETC    'HX1'.'&SYSNDX'                                        01060002
&LB2     SETC    'HX2'.'&SYSNDX'                                        01070002
&LB3     SETC    'HX3'.'&SYSNDX'                                        01080002
         LA      R0,&NUM          Number of hex digits                  01090002
         LA      R15,&OUT         Output area                           01100002
         LA      R14,&SRC         Input area                            01110002
&LB1     DS      0H                                                     01120002
         UNPK    0(3,R15),0(2,R14) Hex to display                       01130002
         TR      0(2,R15),P#HEXTBL-240 Convert hex A-F                  01140002
         BCT     R0,&LB2          Loop through digits                   01150002
         MVI     2(R15),C' '      Clean up last hex digits              01160002
         B       &LB3             Done                                  01170002
&LB2     DS      0H                                                     01180002
         MVI     2(R15),C'.'      Seperator                             01190002
         AH      R15,=H'3'        Next output                           01200002
         AH      R14,=H'1'        Next input                            01210002
         B       &LB1             Do next hex digits                    01220002
&LB3     DS      0H                                                     01230002
         MEND                                                           01240002
********************************************************************    01250002
* System DSECTs                                                    *    01260002
********************************************************************    01270002
DS1      DSECT ,                  Format 1 DSECT                        01280002
         IECSDSL1 (1)                                                   01290002
********************************************************************    01300002
         DCBD  DSORG=PS,DEVD=DA   DCB DSECT                             01310002
********************************************************************    01320002
         IEZDEB LIST=YES          DEB DSECT                             01330002
********************************************************************    01340002
         IEFUCBOB ,               UCB DSECT                             01350002
********************************************************************    01360002
         CVT   DSECT=YES,LIST=YES CVT DSECT                             01370002
*********************************************************************** 01380001
*                                                                     * 01390001
*   Compute Data Set Useage Statistics for Disk Data Sets             * 01400001
*                                                                     * 01410001
*   Programmer:  A. Bruce Leland                                      * 01420001
*                                                                     * 01430001
*   Description:  This program formats information on any disk data   * 01440001
*        set.  It reads through the entire data set and outputs disk  * 01450001
*        track usage, block size and other statistics.                * 01460001
*                                                                     * 01470001
*   Operation:                                                        * 01480001
*       A.  The program gets the input data set name and volume       * 01490001
*           serial number via RDJFCB.                                 * 01500001
*                                                                     * 01510001
*       B.  The program inputs the format 1 DSCB to determine other   * 01520001
*           data set characteristics.                                 * 01530001
*                                                                     * 01540001
*       C.  The program opens the input file, then formats and        * 01550001
*           outputs DEB and DSCB information.                         * 01560001
*                                                                     * 01570001
*       D.  PARM=                                                     * 01580001
*              DIR     Lists all members in directory.                * 01590001
*              NOGAS   Bypass gas scan and reporting.                 * 01600001
*              LABEL   Bypass all data set usage collection.          * 01610001
*              SKIPE   Continues if I/O errors encountered.           * 01620001
*              DEBUG   Diagnostics.                                   * 01630001
*              NOHDR   Skips output headings.                         * 01640001
*              LIST=n  Lists the first n records of gas members.      * 01650001
*                      Default=1 and n can be 0-9.                    * 01660001
*                                                                     * 01670001
*       E.  Additional processing:                                    * 01680001
*                                                                     * 01690001
*           1. For DSORG=PS, none.                                    * 01700001
*                                                                     * 01710001
*           2. For DSORG=DA, None.                                    * 01720001
*                                                                     * 01730001
*           3. For DSORG=PO, the program compares directory TTR's     * 01740001
*              against actual disk addresses to determine the TTRs    * 01750001
*              of gas members (the program also outputs the first     * 01760001
*              80 characters of any gas member).  Statistics are      * 01770001
*              maintained on the size of gas and real members and     * 01780001
*              the number of alias members.                           * 01790001
*              If any aliases are in the data set, a check is made    * 01800001
*              to see that corresponding real entries also exist.     * 01810001
*                                                                     * 01820001
*********************************************************************** 01830001
*                                                                     * 01840001
* Change Log:                                                         * 01850001
*   Date     Int VV.RR Description                                    * 01860001
* 08/02/2022 DSK 01.01 Added dump of missing members.                 * 01870001
*                      Add PARM=DIR to list dir, parse PARM better.   * 01880001
*                      No more abends - return code 16.               * 01890001
* 08/22/2022 DSK 01.02 Rework HEXES macro.                            * 01900001
* 02/11/2023 DSK 02.01 Rework for re-enrant RMODE 31.                 * 01910001
*                      PARM=LIST=n controlling lines of gas to list.  * 01920001
* 05/28/2022 DSK 02.02 MVS 3.8 version.                               * 01930003
* 07/08/2023 DSK 02.03 Fix alias matching and member overlap message  * 01940003
* 07/10/2023 DSK 02.04 Handle EOF properly                            * 01950004
* 07/15/2023 DSK 02.05 Set return code based upon severity of error   * 01960005
*********************************************************************** 01970001
         LCLC   &VER                                                    01980002
&VER     SETC   '02.05'                                                 01990005
*                                                                       02000001
*        Output Numeric Message                                         02010001
*                                                                       02020001
*                                                                       02030001
********************************************************************    02040001
* Program entry point                                              *    02050001
********************************************************************    02060001
STATS    CSECT ,                                                        02070001
         USING STATS,R15                                                02080002
         B     BEGIN              Skip program id                       02090002
         DROP  R15                                                      02100002
         DC    AL1(L'PGMID)                                             02110001
PGMID    DC    C'UTL19 - &VER &SYSDATE &SYSTIME'                        02120001
BEGIN    DS    0H                                                       02130002
********************************************************************    02140001
* Initialization                                                   *    02150001
********************************************************************    02160001
         SAVE  (14,12)                                                  02170002
         LR    R6,R15             Base address                          02180002
         LA    R11,2048(,R6)      Second                                02190002
         LA    R11,2048(,R11)      base address                         02200002
         LA    R12,2048(,R11)     Third                                 02210002
         LA    R12,2048(,R12)      base address                         02220002
         USING STATS,R6,R11,R12                                         02230002
         LR    R7,R1              Save parameters address               02240001
         LR    R3,R13             Save callers save area addr           02250001
         LA    R0,W#LEN                                                 02260002
         GETMAIN R,LV=(0)         Get work area                         02270002
         LR    R13,R1             Get work area address                 02280001
         USING W#,R13                                                   02290001
         LR    R0,R1              Clear                                 02300001
         LA    R1,W#LEN            work                                 02310002
         SR    R15,R15              area                                02320001
         MVCL  R0,R14                to X'00'                           02330001
         ST    R3,4(,R13)         Save callers in my save area          02340001
         ST    R13,8(,R3)         Save my save area in callers          02350001
         L     R0,=A(L'BUF)                                             02360002
         GETMAIN R,LV=(0)         Get buffer storage                    02370002
         LR    R10,R1             Buffer pointer                        02380001
         USING BUF,R10                                                  02390001
         L     R0,=A(MBRTBLN)                                           02400002
         GETMAIN R,LV=(0)         Get member table                      02410002
         LR    R9,R1              Member table pointer                  02420001
         USING MBRTBL,R9                                                02430001
         LR    R0,R1              Clear                                 02440001
         L     R1,=A(MBRTBLN)      member                               02450001
         SR    R15,R15              table                               02460001
         MVCL  R0,R14                to X'00'                           02470001
*                                                                       02480001
         MVC   W#MINBLK,=X'7F000000' Initialize min length block        02490001
         MVC   W#MINGAS,=X'7F000000' Initialize min bytes in gas mbrs   02500001
         MVC   W#MINREL,=X'7F000000' Initialize min bytes in real mbrs  02510001
         MVC   W#MINR,=X'7F000000' Initialize min records/track         02520001
         MVC   W#MINBYT,=X'7F000000' Initialize min bytes per track     02530001
         MVI   W#FLAG1,W#F1GAS    Default                               02540001
*                                                                       02550001
         LA    R0,W#IOBSEK+3      Initialize W#CCW1A                    02560001
         LA    R1,5                CCW   X'31',W#IOBSEK+3,X'60',5       02570002
         STM   R0,R1,W#CCW1A                                            02580001
         MVI   W#CCW1A,X'31'       SEARCH ID EQUAL (CCHHR)              02590001
         MVI   W#CCW1A+4,X'60'                                          02600001
*                                                                       02610001
         LA    R0,W#CCW1A         Initialize W#CCW2A                    02620001
         LA    R1,1                CCW   X'08',*-8,X'60',1              02630002
         STM   R0,R1,W#CCW2A                                            02640001
         MVI   W#CCW2A,X'08'       TIC                                  02650001
         MVI   W#CCW2A+4,X'60'                                          02660001
*                                                                       02670001
         LA    R0,W#IOBSEK+3      Initialize W#CCW3A                    02680001
         LA    R1,8                CCW   X'92',W#IOBSEK+3,X'20',8       02690002
         STM   R0,R1,W#CCW3A                                            02700001
         MVI   W#CCW3A,X'92'       MT READ NEXT COUNT                   02710001
         MVI   W#CCW3A+4,X'20'                                          02720001
*                                                                       02730001
         LA    R0,W#SECTNM        Initialize W#CCW0                     02740001
         LA    R1,1                CCW   X'23',W#SECTNM,X'60',1         02750002
         STM   R0,R1,W#CCW0                                             02760001
         MVI   W#CCW0,X'23'        SET SECTOR                           02770001
         MVI   W#CCW0+4,X'60'                                           02780001
*                                                                       02790001
         LA    R0,W#IOBSEK+3      Initialize W#CCW1                     02800001
         LA    R1,5                CCW   X'31',W#IOBSEK+3,X'60',5       02810002
         STM   R0,R1,W#CCW1                                             02820001
         MVI   W#CCW1,X'31'        SEARCH ID EQUAL (CCHHR)              02830001
         MVI   W#CCW1+4,X'60'                                           02840001
*                                                                       02850001
         LA    R0,W#CCW1          Initialize W#CCW2                     02860001
         LA    R1,1                CCW   X'08',*-8,X'60',1              02870002
         STM   R0,R1,W#CCW2                                             02880001
         MVI   W#CCW2,X'08'        TIC                                  02890001
         MVI   W#CCW2+4,X'60'                                           02900001
*                                                                       02910001
         LA    R0,BUF             Initialize W#CCW3                     02920001
         L     R1,=A(L'BUF)        CCW   X'06',BUF-BUF,X'60',L'BUF      02930001
         STM   R0,R1,W#CCW3                                             02940001
         MVI   W#CCW3,X'06'        READ DATA                            02950001
         MVI   W#CCW3+4,X'60'                                           02960001
*                                                                       02970001
         LA    R0,W#IOBSEK+3      Initialize W#CCW4                     02980001
         LA    R1,8                CCW   X'92',W#IOBSEK+3,X'60',8       02990002
         STM   R0,R1,W#CCW4                                             03000001
         MVI   W#CCW4,X'92'        MT READ NEXT COUNT                   03010001
         MVI   W#CCW4+4,X'60'                                           03020001
*                                                                       03030001
         LA    R0,W#SECTNM        Initialize W#CCW5                     03040001
         LA    R1,1                CCW   X'22',W#SECTNM,X'20',1         03050002
         STM   R0,R1,W#CCW5                                             03060001
         MVI   W#CCW5,X'22'        READ SECTOR NUMBER                   03070001
         MVI   W#CCW5+4,X'20'                                           03080001
*                                                                       03090001
         MVI  W#IOB,X'C2'         Initialize W#IOB                      03100001
         LA   R0,W#ECB            Initialize W#IOBECB                   03110001
         ST   R0,W#IOBECB                                               03120001
         LA   R0,W#CCW1           Initialize W#IOBCCW                   03130001
         ST   R0,W#IOBCCW                                               03140001
         LA   R0,W#INDCB          Initialize W#IOBDCB                   03150001
         ST   R0,W#IOBDCB                                               03160001
*                                                                       03170001
         MVI   W#OUTLIN,C' '      Clear output line                     03180001
         MVC   W#OUTLIN+1(L'W#OUTLIN-1),W#OUTLIN                        03190001
         MVI   W#WRKLN1,C' '      Clear output line                     03200001
         MVC   W#WRKLN1+1(L'W#WRKLN1-1),W#WRKLN1                        03210001
         MVC   W#WRKLN2,W#WRKLN1  Clear output line                     03220001
         MVC   W#WRKLN3,W#WRKLN1  Clear output line                     03230001
         MVC   W#WRKLN4,W#WRKLN1  Clear output line                     03240001
         MVC   W#WRKLN5,W#WRKLN1  Clear output line                     03250001
         MVC   W#WRKLN6,W#WRKLN1  Clear output line                     03260001
         MVC   W#WRKLN7,W#WRKLN1  Clear output line                     03270001
         MVC   W#WRKLN8,W#WRKLN1  Clear output line                     03280001
         MVC   W#WRKLN9,W#WRKLN1  Clear output line                     03290001
         MVC   W#GASLS#,=A(1)     LIST=1 default                        03300001
*                                                                       03310001
         MVC   W#INDCB,P#INDCB    Init IN DCB                           03320001
         LA    R8,W#INDCB         IN DCB address                        03330001
         USING IHADCB,R8                                                03340001
         LA    R0,W#EXLST         Init IN DCB EXLST                     03350001
         ST    R0,DCBEXLST                                              03360001
         MVC   W#OUTDCB,P#OUTDCB  Init OUT DCB                          03370001
*                                                                       03380001
         MVC   W#OPNLST,P#OPNLST  Init OPEN parameter list              03390001
         OPEN  (W#OUTDCB,(OUTPUT)),MF=(E,W#OPNLST)                      03400002
         TM    W#OUTDCB+(DCBOFLGS-IHADCB),DCBOFOPN OPEN successful?     03410002
         BNO   ENDRC16            No, error                             03420002
*                                                                       03430001
         MVI   W#LINE,C' '        Clear print line                      03440001
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              03450001
         MVC   W#HD1,W#LINE       Clear heading 1                       03460001
         MVI   W#HD1,C'1'         Prime heading 1                       03470001
         MVC   W#HD1TTL,=C'Disk Data Set Statistics'                    03480002
         MVC   W#HD1PG,=C'Page'                                         03490001
         ZAP   W#LNCT,=P'+99'                                           03500001
         ZAP   W#PGCT,=P'+0'                                            03510001
         ZAP   W#JLWK13,=P'+1'    Prime work                            03520002
         ZAP   W#JLWK12,=P'+31'   Prime Dec                             03530002
         ZAP   W#JLWK11,=P'+30'   Prime Nov                             03540002
         ZAP   W#JLWK10,=P'+31'   Prime Oct                             03550002
         ZAP   W#JLWK09,=P'+30'   Prime Sep                             03560002
         ZAP   W#JLWK08,=P'+31'   Prime Aug                             03570002
         ZAP   W#JLWK07,=P'+31'   Prime Jul                             03580002
         ZAP   W#JLWK06,=P'+30'   Prime Jun                             03590002
         ZAP   W#JLWK05,=P'+31'   Prime May                             03600002
         ZAP   W#JLWK04,=P'+30'   Prime Apr                             03610002
         ZAP   W#JLWK03,=P'+31'   Prime Mar                             03620002
         ZAP   W#JLWK02,=P'+28'   Prime Feb                             03630002
         ZAP   W#JLWK01,=P'+31'   Prime Jan                             03640002
         TIME  BIN                Get current date and time             03650001
         ST    R1,W#CURDTE        Save date                             03660002
         SRDL  R0,32              Get double word time                  03670001
         D     R0,=F'+6000'       Get minutes                           03680001
         LR    R15,R0             Save secs tens and hundreths          03690001
         SLR   R0,R0              Clear                                 03700001
         D     R0,=F'+60'         Get hours / mins                      03710001
         MH    R0,=H'+10000'      Get minutes                           03720001
         AR    R15,R0             Add to get MM:SS.TH                   03730001
         M     R0,=F'+1000000'    Get hours                             03740001
         AR    R1,R15             Get HH:MM:SS.TH                       03750001
         CVD   R1,W#DWORD         Get time to decimal                   03760001
         MVC   W#TIMWK4,=X'402021204B20204B20204B2020'                  03770002
         ED    W#TIMWK4,W#DWORD+3 Edit time                             03780002
         MVC   W#HD1TOD(8),W#TIMWK4+2 Move time                         03790002
         ZAP   W#JLWK1,W#CURDTE+2(2) Get julian date                    03800002
         ZAP   W#JLWK2,=P'+365' Days/yr = 365                           03810002
         ZAP   W#JLWK02,=P'+28' Feb = 28                                03820002
         MVO   W#DWORD,W#CURDTE+1(1) Sign year                          03830002
         DP    W#DWORD,=P'+4'     Divide by 4                           03840001
         CP    W#DWORD+7(1),=P'+0' Is it a leap year ?                  03850001
         BNZ   JULCVT2            No                                    03860002
         ZAP   W#JLWK2,=P'+366' Days/yr = 366                           03870002
         ZAP   W#JLWK02,=P'+29' Feb = 29                                03880002
JULCVT2  DS    0H                                                       03890001
         LA    R1,W#JLWK01        Point to Jan                          03900002
         SLR   R2,R2              Set counter                           03910001
JULCVT4  DS    0H                                                       03920001
         SP    W#JLWK1,0(2,R1)    Months displacement                   03930002
         BNP   JULCVT6            If equal or less                      03940002
         SH    R1,=H'2'           Point to next month                   03950002
         AH    R2,=H'3'           Up index                              03960002
         B     JULCVT4            Loop                                  03970002
JULCVT6  DS    0H                                                       03980001
         AP    W#JLWK1,0(2,R1)    Add days of month                     03990002
         LA    R2,P#JLTBL2(R2)    Address month                         04000002
         MVC   W#HD1DTE(3),0(R2) Move month                             04010002
         OI    W#JLWK1+3,X'0F'    Display sign                          04020002
         UNPK  W#HD1DTE+4(2),W#JLWK1 Get days                           04030002
         CLI   W#HD1DTE+4,C'0'    First 9 days ?                        04040002
         LA    R1,W#HD1DTE+6      Set pointer                           04050002
         BNE   JULCVT7            No                                    04060002
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 Move units digit                04070002
         BCTR  R1,0               Drop pointer                          04080001
JULCVT7  DS    0H                                                       04090001
         MVC   0(4,R1),=C', 19'   Set up constant                       04100001
         TM    W#CURDTE,1         Year 2000?                            04110002
         BNO   JULCVT8            No, continue                          04120002
         MVC   2(2,R1),=C'20'     Year 2000                             04130001
JULCVT8  DS    0H                                                       04140001
         UNPK  W#DWORD(3),W#CURDTE+1(2) Unpack year                     04150002
         MVC   4(2,R1),W#DWORD    Get year                              04160001
*                                                                       04170001
         MVC   W#LINE+1(L'PROGRAM),PROGRAM                              04180001
         MVC   W#LINE+1+L'PROGRAM+1(L'PGMID),PGMID                      04190001
         BAL   R14,PRT            Program name and purpose              04200002
*                                                                       04210001
         MVC   W#LINE+1(L'ABL),ABL Author                               04220001
         BAL   R14,PRT            Print a line                          04230002
*                                                                       04240001
********************************************************************    04250001
* Parse PARM=DIR,NOGAS,LABEL,SKIPE,DEBUG,NOHDR                     *    04260001
********************************************************************    04270001
         L     R15,0(,R7)         Parm address                          04280001
         LH    R14,0(,R15)        Get length of parameters              04290001
         MVC   W#LINE+1(5),=C'PARM=' Move parameter info literal        04300001
         LTR   R14,R14                                                  04310002
         BZ    PARMPRT            If PARM= omitted                      04320002
         BCTR  R14,0              Make machine length                   04330002
         MVC   W#LINE+6(0),2(R15) Executed parm move                    04340002
         EX    R14,*-6            Move parm to print line               04350002
PARMPRT  DS    0H                                                       04360002
         BAL   R14,PRT            Print a line                          04370002
*                                                                       04380001
         L     R1,0(,R7)          Parm address                          04390001
         LH    R0,0(,R1)          Get length of parameters              04400001
         LTR   R0,R0              Is length zero?                       04410001
         BZ    OPENIT             Yes, branch                           04420002
         LA    R1,2(,R1)          Past PARM= length                     04430001
PARMSC   DS    0H                                                       04440001
         CH    R0,=H'3'           Length ok?                            04450002
         BL    PARMNG             No, skip check                        04460002
         CLC   =C'DIR',0(R1)      Is directory listed desired?          04470001
         BNE   PARMNG             No, branch                            04480002
         OI    W#FLAG1,W#F1DIR    Turn on list directory                04490001
         AH    R1,=H'3'           Past parm                             04500002
         SH    R0,=H'3'           Reduce length                         04510002
         B     PARMZ              Next parm                             04520002
PARMNG   DS    0H                                                       04530001
         CH    R0,=H'5'           Length ok?                            04540002
         BL    PARML              No, skip check                        04550002
         CLC   =C'NOGAS',0(R1)    Are no gas records desired?           04560001
         BNE   PARML              No, branch                            04570002
         NI    W#FLAG1,255-W#F1GAS Turn off gas records                 04580001
         AH    R1,=H'5'           Past parm                             04590002
         SH    R0,=H'5'           Reduce length                         04600002
         B     PARMZ              Next parm                             04610002
PARML    DS    0H                                                       04620001
         CH    R0,=H'5'           Length ok?                            04630002
         BL    PARMI              No, skip check                        04640002
         CLC   =C'LABEL',0(R1)    Label information only?               04650001
         BNE   PARMI              No, branch                            04660002
         OI    W#FLAG1,W#F1LBL    Set the labels only flag              04670001
         AH    R1,=H'5'           Past parm                             04680002
         SH    R0,=H'5'           Reduce length                         04690002
         B     PARMZ              Next parm                             04700002
PARMI    DS    0H                                                       04710001
         CH    R0,=H'5'           Length ok?                            04720002
         BL    PARMD              No, skip check                        04730002
         CLC   =C'SKIPE',0(R1)    Skip I/O error checking?              04740001
         BNE   PARMD              No, branch                            04750002
         OI    W#FLAG1,W#F1SKER   Set the skip I/O error flag           04760001
         AH    R1,=H'5'           Past parm                             04770002
         SH    R0,=H'5'           Reduce length                         04780002
         B     PARMZ              Next parm                             04790002
PARMD    DS    0H                                                       04800001
         CH    R0,=H'5'           Length ok?                            04810002
         BL    PARMH              No, skip check                        04820002
         CLC   =C'DEBUG',0(R1)    Debugging info?                       04830001
         BNE   PARMH              No, branch                            04840002
         OI    W#FLAG1,W#F1DBG    Set debugging flag                    04850001
         AH    R1,=H'5'           Past parm                             04860002
         SH    R0,=H'5'           Reduce length                         04870002
PARMH    DS    0H                                                       04880001
         CH    R0,=H'5'           Length ok?                            04890002
         BL    PARMLS             No, skip check                        04900002
         CLC   =C'NOHDR',0(R1)    Skip headings?                        04910001
         BNE   PARMLS             No, branch                            04920002
         OI    W#FLAG2,W#F2NOHD   Set no headings                       04930001
         AH    R1,=H'5'           Past parm                             04940002
         SH    R0,=H'5'           Reduce length                         04950002
PARMLS   DS    0H                                                       04960001
         CH    R0,=H'6'           Length ok?                            04970002
         BL    PARMZ              No, skip check                        04980002
         CLC   =C'LIST=',0(R1)    List gas member lines?                04990001
         BNE   PARMZ              No, branch                            05000002
         AH    R1,=H'5'           Past parm                             05010002
         SH    R0,=H'5'           Reduce length                         05020002
         CLI   0(R1),C'0'         Numeric                               05030001
         BL    PARMERR            No, error                             05040002
         SR    R15,R15                                                  05050002
         IC    R15,0(,R1)         Get digit                             05060002
         N     R15,=X'0000000F'   Clear zone                            05070002
         ST    R15,W#GASLS#       Save number of lines                  05080001
         AH    R1,=H'1'           Past parm                             05090002
         SH    R0,=H'1'           Reduce length                         05100002
PARMZ    DS    0H                                                       05110001
         LTR   R0,R0              End of parms                          05120001
         BZ    OPENIT             Yes                                   05130002
         CLI   0(R1),C','         Comma between parameters?             05140001
         BNE   PARMERR            No, error                             05150002
         AH    R1,=H'1'           Next parm                             05160002
         BCT   R0,PARMSC          Next PARM= character                  05170002
         B     OPENIT             PARM= scanned                         05180002
PARMERR  DS    0H                                                       05190001
         LR    R2,R1              Save where error is                   05200001
         L     R15,0(,R7)         Parm address                          05210001
         SR    R2,R15             Less start                            05220001
         LA    R1,W#LINE+4(R2)    Get location of error                 05230001
         MVC   0(13,R1),=C'* PARM= error'                               05240001
         BAL   R14,PRT            Print a line                          05250002
         B     ENDRC16            Exit with the error                   05260002
********************************************************************    05270001
* OPEN IN and data set attributes                                  *    05280001
********************************************************************    05290001
OPENIT   DS    0H                                                       05300001
         BAL   R14,OPENIN         OPEN the input file                   05310002
         BAL   R14,PRT            Print a line                          05320002
*                                                                       05330001
         MVC   W#LINE+1(4),=CL4'DSN='                                   05340001
         MVC   W#LINE+1+4(44),JFCBDSNM Data set name                    05350002
         BAL   R14,PRT            Print DSN                             05360002
*                                                                       05370001
         LA    R1,W#LINE+1                                              05380001
         MVC   0(12,R1),=CL12'DCB=(RECFM=*'                             05390001
         AH    R1,=H'11'                                                05400002
         TM    FM1RECFM,DCBRECU   RECFM=U?                              05410002
         BNO   DCBINFA            No, branch                            05420002
         MVI   0(R1),C'U'                                               05430001
         B     DCBINFC                                                  05440002
DCBINFA  DS    0H                                                       05450001
         TM    FM1RECFM,DCBRECF   RECFM=F?                              05460002
         BNO   DCBINFB            No, branch                            05470002
         MVI   0(R1),C'F'                                               05480001
         B     DCBINFC                                                  05490002
DCBINFB  DS    0H                                                       05500001
         TM    FM1RECFM,DCBRECV   RECFM=V?                              05510002
         BNO   DCBINFC            No, branch                            05520002
         MVI   0(R1),C'V'                                               05530001
DCBINFC  DS    0H                                                       05540001
         AH    R1,=H'1'                                                 05550002
         TM    FM1RECFM,DCBRECBR  RECFM=.B?                             05560002
         BNO   DCBINFD            No, branch                            05570002
         MVI   0(R1),C'B'                                               05580001
         AH    R1,=H'1'                                                 05590002
DCBINFD  DS    0H                                                       05600001
         TM    FM1RECFM,DCBRECTO  RECFM=.T?                             05610002
         BNO   DCBINFE            No, branch                            05620002
         MVI   0(R1),C'T'                                               05630001
         AH    R1,=H'1'                                                 05640002
DCBINFE  DS    0H                                                       05650001
         TM    FM1RECFM,DCBRECCA  RECFM=.A?                             05660002
         BNO   DCBINFF            No, branch                            05670002
         MVI   0(R1),C'A'                                               05680001
         AH    R1,=H'1'                                                 05690002
DCBINFF  DS    0H                                                       05700001
         TM    FM1RECFM,DCBRECCM  RECFM=.M?                             05710002
         BNO   DCBINFH            No, branch                            05720002
         MVI   0(R1),C'M'                                               05730001
         AH    R1,=H'1'                                                 05740002
DCBINFH  DS    0H                                                       05750001
         TM    FM1RECFM,DCBRECU   RECFM=U?                              05760002
         BO    DCBINFJ            Yes, no LRECL message                 05770002
         MVC   0(7,R1),=CL7',LRECL='                                    05780001
         AH    R1,=H'7'                                                 05790002
         LH    R15,FM1LRECL                                             05800001
         CVD   R15,W#DWORD                                              05810001
         UNPK  W#DWORD(5),W#DWORD+5(3)                                  05820001
         LA    R15,W#DWORD-1                                            05830001
DCBINFZ  DS    0H                                                       05840001
         AH    R15,=H'1'          Scan                                  05850002
         CLI   0(R15),C'0'         past last                            05860001
         BE    DCBINFZ              leading zero                        05870002
         OI    W#DWORD+4,C'0'                                           05880001
DCBINFI  DS    0H                                                       05890001
         MVC   0(1,R1),0(R15)     Move in each character                05900001
         AH    R1,=H'1'                                                 05910002
         AH    R15,=H'1'                                                05920002
         TM    0(R15),C'0'        Next character numeric?               05930001
         BO    DCBINFI            No, branch                            05940002
DCBINFJ  DS    0H                                                       05950001
         MVC   0(9,R1),=CL9',BLKSIZE='                                  05960001
         AH    R1,=H'9'                                                 05970002
         LH    R15,FM1BLKSI                                             05980001
         CVD   R15,W#DWORD                                              05990001
         UNPK  W#DWORD(5),W#DWORD+5(3)                                  06000001
         LA    R15,W#DWORD-1                                            06010001
DCBINFK  DS    0H                                                       06020001
         AH    R15,=H'1'          Scan                                  06030002
         CLI   0(R15),C'0'         past last                            06040001
         BE    DCBINFK              leading zero                        06050002
         OI    W#DWORD+4,C'0'                                           06060001
DCBINFL  DS    0H                                                       06070001
         MVC   0(1,R1),0(R15)     Move in each character                06080001
         AH    R1,=H'1'                                                 06090002
         AH    R15,=H'1'                                                06100002
         TM    0(R15),C'0'        Next character numeric?               06110001
         BO    DCBINFL            No, branch                            06120002
         MVC   0(7,R1),=CL7',DSORG='                                    06130001
         AH    R1,=H'7'                                                 06140002
         TM    FM1DSORG,DS1DSGPS  PS?                                   06150001
         BNO   DCBINFM            No, branch                            06160002
         MVC   0(2,R1),=CL2'PS'                                         06170001
DCBINFM  DS    0H                                                       06180001
         TM    FM1DSORG,DS1DSGPO  PO?                                   06190001
         BNO   DCBINFN            No, branch                            06200002
         MVC   0(2,R1),=CL2'PO'                                         06210001
DCBINFN  DS    0H                                                       06220001
         TM    FM1DSORG,DS1DSGDA  DA?                                   06230001
         BNO   DCBINFO            No, branch                            06240002
         MVC   0(2,R1),=CL2'DA'                                         06250001
DCBINFO  DS    0H                                                       06260001
         TM    FM1DSORG,DS1DSGU   Un moveable?                          06270001
         BNO   DCBINFQ            No, branch                            06280002
         MVI   2(R1),C'U'                                               06290001
         AH    R1,=H'1'                                                 06300002
DCBINFQ  DS    0H                                                       06310001
         MVI   2(R1),C')'                                               06320001
         BAL   R14,PRT            Print DCB info                        06330002
*                                                                       06340001
         L     R2,DCBDEBAD        Get DEB address                       06350001
         N     R2,=X'00FFFFFF'    Clean DEB address                     06360002
         USING DEBBASIC,R2                                              06370001
         LA    R5,DEBBASND        First extent in DEB                   06380001
         USING DEBDASD,R5                                               06390001
         L     R14,W#NUMEXT       Number of extents                     06400001
         SR    R0,R0                                                    06410001
DCBINFR  DS    0H                                                       06420001
         AH    R0,DEBNMTRK        Tracks in extent                      06430001
         LA    R5,DEBNMTRK+2      Next extent in DEB                    06440002
         BCT   R14,DCBINFR        Repeat for each extent                06450002
         DROP  R5                                                       06460001
         ST    R0,W#TOTTRK        Save tracs total                      06470001
         LH    R1,FM1LSTAR        Last TT used                          06480001
         SR    R0,R1              Available space + 0.5 tracks          06490001
         BCTR  R0,0               Subtract one more                     06500001
         ST    R0,W#FRETRK                                              06510001
         MVC   W#TEMP,FM1LSTAR                                          06520001
         TTRMBB TTR=W#TEMP,MBB=W#LSTADR Save the last used mbbcchhr     06530001
         OUTPT W#TOTTRK,NUMTRKS                                         06540001
         OUTPT W#FRETRK,FRETRKS                                         06550001
         SR    R0,R0                                                    06560002
         ICM   R0,3,FM1TRBAL                                            06570002
         OUTPT (R0),TRBALS        Bytes left on last used track         06580001
         OUTPT W#NUMEXT,NUMEXTS                                         06590001
         L     R3,W#NUMEXT                                              06600001
         SR    R1,R1                                                    06610002
         IC    R1,DEBPROTG        Task protection key                   06620002
         SRL   R1,4                                                     06630001
         IC    R1,P#HEXTBL(R1)                                          06640001
         MVC   W#LINE+1(L'PROTECT),PROTECT                              06650001
         STC   R1,W#LINE+1                                              06660001
         BAL   R14,PRT            Print a line                          06670002
*                                                                       06680001
         MVC   W#LINE+1(L'SCALOS),SCALOS                                06690001
         TM    FM1SCALO,X'C0'     Cylinder alloc?                       06700002
         BNO   DCBINFS            No, branch                            06710002
         MVC   W#LINE+2+L'SCALOS(9),=CL9'cylinders'                     06720001
         B     ALLOCS                                                   06730002
DCBINFS  DS    0H                                                       06740001
         BNZ   DCBINFT            Abs. tracks                           06750002
         MVC   W#LINE+2+L'SCALOS(15),=CL15'absolute tracks'             06760001
         B     ALLOCS                                                   06770002
DCBINFT  DS    0H                                                       06780001
         TM    FM1SCALO,X'40'     Tracks?                               06790002
         BNO   DCBINFU            No, branch                            06800002
         MVC   W#LINE+2+L'SCALOS(6),=CL6'tracks'                        06810001
         B     ALLOCS                                                   06820002
DCBINFU  DS    0H                                                       06830001
         MVC   W#LINE+2+L'SCALOS(6),=CL6'blocks'                        06840001
         TM    FM1SCALO,X'01'     Round to CYL?                         06850001
         BNO   ALLOCS             No, branch                            06860002
         MVC   W#LINE+9+L'SCALOS(12),=CL12'(with round)' Yes            06870001
ALLOCS   DS    0H                                                       06880001
         BAL   R14,PRT            Print a line                          06890002
*                                                                       06900001
         MVC   W#TEMP+1(3),FM1SAQU Secondary allocation quantity        06910001
         MVI   W#TEMP,X'00'                                             06920001
         CLC   W#TEMP,=F'0'       Any secondaries allowed?              06930001
         BNE   SECS               Yes, branch                           06940002
         MVC   W#LINE+1(L'NOSEC),NOSEC                                  06950001
         BAL   R14,PRT            Print a line                          06960002
         B     ALLSECS                                                  06970002
SECS     DS    0H                                                       06980001
         OUTPT W#TEMP,EXTENTS                                           06990001
*                                                                       07000001
ALLSECS  DS    0H                                                       07010001
         MVC   W#LINE+1(L'LSTAR),LSTAR                                  07020001
         HEXES W#LSTADR,8,W#LINE+1+12                                   07030001
         MVC   W#LINE+1+36(3),=C'TTR'                                   07040001
         HEXES FM1LSTAR,3,W#LINE+1+40                                   07050001
         BAL   R14,PRT            Last used MBBCCHHR                    07060002
         BAL   R14,PRT            Print a line                          07070002
*                                                                       07080001
         MVC   W#LINE+1(L'EXTHDR),EXTHDR                                07090001
         BAL   R14,PRT            Print a line                          07100002
         MVC   W#LINE+1(L'EXTUND),EXTUND                                07110001
         BAL   R14,PRT            Print a line                          07120002
*                                                                       07130001
         LA    R4,1               Extent number                         07140002
         LA    R5,DEBBASND        First extent in DEB                   07150001
         USING DEBDASD,R5                                               07160001
FMTEXT   DS    0H                                                       07170001
         CVD   R4,W#DWORD         Extent number                         07180001
         UNPK  W#DWORD(5),W#DWORD+5(3)                                  07190001
         MVC   W#LINE+1+1(2),W#DWORD+3                                  07200001
         CLI   W#LINE+1+1,C'0'                                          07210001
         BNE   FMTEXT01                                                 07220002
         MVI   W#LINE+1+1,C' '                                          07230001
FMTEXT01 DS    0H                                                       07240001
         OI    W#LINE+1+2,C'0'                                          07250001
         L     R1,DEBUCBAD        Get UCB address                       07260001
         N     R1,=X'00FFFFFF'    Purify UCB address                    07270002
         USING UCBOB,R1                                                 07280001
         UNPK  W#LINE+1+7(5),UCBCHAN(3) Volume device address           07290001
         MVC   W#LINE+1+48(6),UCBVOLI Volume serial number              07300001
         DROP  R1                                                       07310001
         TR    W#LINE+1+7(4),P#HEXTBL-240                               07320001
         MVI   W#LINE+1+11,C' '                                         07330001
         HEXES DEBSTRCC,4,W#LINE+1+13 Extent start CCHH                 07340001
         HEXES DEBENDCC,4,W#LINE+1+27 Extent end CCHH                   07350001
         LH    R1,DEBNMTRK        Tracks in extent                      07360002
         CVD   R1,W#DWORD                                               07370001
         UNPK  W#DWORD(5),W#DWORD+5(3)                                  07380001
         MVC   W#LINE+1+41(5),W#DWORD                                   07390001
         LA    R1,W#LINE+1+41                                           07400001
FMTEXT02 DS    0H                                                       07410001
         CLI   0(R1),C'0'         Next digit zero?                      07420001
         BNE   FMTEXT03           Yes, contine blanking leading zeros   07430002
         MVI   0(R1),X'40'        Replace current digit with blank      07440001
         AH    R1,=H'1'                                                 07450002
         B     FMTEXT02           Yes, contine blanking leading zeros   07460002
FMTEXT03 DS    0H                                                       07470001
         OI    W#LINE+1+45,C'0'   Make the zone printable               07480001
         BAL   R14,PRT            Print a line                          07490002
         AH    R4,=H'1'           Next extent number                    07500002
         LA    R5,DEBNMTRK+2      Nexten in DEB                         07510002
         BCT   R3,FMTEXT                                                07520002
         DROP  R2                                                       07530001
         DROP  R5                                                       07540001
         BAL   R14,PRT            Print a line                          07550002
*                                                                       07560001
         SR    R0,R0                                                    07570001
         IC    R0,FM1KEYL                                               07580001
         LTR   R0,R0              Key length zero?                      07590001
         BZ    DSORGTST           Yes, skip message                     07600002
         OUTPT (R0),KEYLEN        Print KEYLEN and RKP                  07610001
         SR    R0,R0                                                    07620002
         ICM   R0,3,FM1RKP                                              07630002
         OUTPT (R0),KEYPOS                                              07640001
         BAL   R14,PRT            Print a line                          07650002
*                                                                       07660001
DSORGTST DS    0H                                                       07670001
         TM    W#FLAG1,W#F1LBL    Label information only desired?       07680001
         BO    ENDUP              Yes, do not do any reads              07690002
         TM    FM1DSORG,DS1DSGPO  PO?                                   07700001
         BO    PO                 Yes, go handle PDS                    07710002
********************************************************************    07720001
* PS or DA data set                                                *    07730001
********************************************************************    07740001
INPUTS   DS    0H                                                       07750001
         BAL   R14,STAT           Read each block and collect stats     07760002
         LTR   R15,R15            End of file?                          07770001
         BZ    INPUTS             No, continue reading                  07780002
         LR    R2,R15             Save for later                        07790001
         MVC   W#LINE+1(L'EOFSS),EOFSS                                  07800001
         BAL   R14,PRT            Print a line                          07810002
*                                                                       07820001
         L     R0,W#RDTOT                                               07830001
         LTR   R0,R0              Any records read?                     07840001
         BP    ENDPSPO            Yes, normal data set                  07850002
         MVC   W#LINE+1(L'NULL),NULL No records in the data set         07860001
         BAL   R14,PRT            Print a line                          07870002
         B     ENDUP              Quit                                  07880002
********************************************************************    07890001
* PO data set                                                      *    07900001
********************************************************************    07910001
PO       DS    0H                                                       07920001
         L     R5,MBRTBL          High water mark                       07930001
         OI    W#FLAG1,W#F1ERRD   Turn on the in directory flag         07940001
         CLI   FM1NOBDB,0         Last directory block in use?          07950001
         BE    NEXTMBR            No, branch                            07960002
         SR    R0,R0                                                    07970002
         IC    R0,FM1NOBDB        Number of bytes in use                07980002
         OUTPT (R0),NOBDBS                                              07990001
NEXTMBR  DS    0H                                                       08000001
         BAL   R14,MEMBERS        Get the next member                   08010002
         LA    R14,MBRRCTB        Jump table address                    08020002
         AR    R14,R15            Add return code                       08030001
         BR    R14                Branch table                          08040001
MBRRCTB  B     GOODMBR            Successful                            08050002
         B     MBREOF             EOF in directory                      08060002
         B     LASTUSED           Last used entry found                 08070002
         B     NOTDIREC           Not a directory record                08080002
*                                                                       08090001
GOODMBR  DS    0H                                                       08100001
         LR    R2,R1              Save directory address                08110001
         USING PDS2,R2                                                  08120001
         TM    W#FLAG1,W#F1DBG                                          08130002
         BNO   DBG0010                                                  08140002
         MVC   W#LINE+1(15),=C'Directory entry'                         08150002
         L     R0,W#DIRPTR+4      Directory entry length                08160002
         BAL   R14,DMPAD                                                08170002
DBG0010  DS    0H                                                       08180002
         CLC   W#TBLCNT,=A((MBRTBLN-L'TBLMENT)/L'TBLMENT) Past end      08190001
         BL    GOODMBR0           No, room to add to table              08200002
         MVC   W#LINE+1(L'MANYENT),MANYENT                              08210001
         BAL   R14,PRT            Print a line                          08220002
         B     ENDRC16                                                  08230002
GOODMBR0 DS    0H                                                       08240001
         LA    R15,W#ALSCNT       Alias counter                         08250001
         TM    PDS2INDC,PDS2ALIS  Alias entry?                          08260001
         BO    GOODMBR1           Yes, branch                           08270002
         LA    R15,W#RELCNT       Real counter                          08280001
GOODMBR1 DS    0H                                                       08290001
         L     R14,0(,R15)        Get counter                           08300001
         AH    R14,=H'1'          Increment W#ALSCNT or W#RELCNT        08310002
         ST    R14,0(,R15)        Save counter                          08320001
         TTRMBB TTR=PDS2TTRP,MBB=W#DWORD,ERRET=POBADAS                  08330001
         LA    R3,MBRTBL                                                08340001
         SH    R3,=AL2(L'TBLMENT)                                       08350002
         USING TBLMENT,R3                                               08360001
TBLINC   DS    0H                                                       08370001
         AH    R3,=AL2(L'TBLMENT)                                       08380002
         CLI   TBLMNAME,0         Empty table entry?                    08390001
         BE    INSERT             Yes, branch                           08400002
         CLC   TBLMCHR,W#DWORD    Is it this entry?                     08410001
         BNE   TBLINC             No, check next entry                  08420002
         TM    PDS2INDC,PDS2ALIS  Alias entry?                          08430001
         BO    NEXTMBR            Yes, get next member                  08440002
         MVC   TBLMNAME,PDS2NAME  No, use the real member name          08450001
         NI    TBLMFLG,255-TBLMFLGA Reset alias                      03 08460003
         B     NEXTMBR            Get next member                       08470002
INSERT   DS    0H                                                       08480001
         MVC   TBLMNAME,PDS2NAME  Directory mamber name                 08490001
         MVC   TBLMCHR,W#DWORD    Insert the MBBCCHHR                   08500001
         TM    PDS2INDC,PDS2ALIS  Alias entry?                          08510001
         BNO   INSERT1            No                                    08520002
         OI    TBLMFLG,TBLMFLGA   Set alias                             08530001
INSERT1  DS    0H                                                       08540001
         L     R0,W#TBLCNT                                              08550001
         AH    R0,=H'1'           Count entries                         08560002
         ST    R0,W#TBLCNT                                              08570001
         TM    W#FLAG1,W#F1DBG                                          08580002
         BNO   DBG0020                                                  08590002
         MVC   W#LINE+1(7),=C'TBLMENT'                                  08600002
         LA    R1,TBLMENT                                               08610002
         LA    R0,L'TBLMENT                                             08620002
         BAL   R14,DMPAD                                                08630002
DBG0020  DS    0H                                                       08640002
         LA    R5,TBLMENT+L'TBLMENT High-water mark                     08650001
         B     NEXTMBR                                                  08660002
POBADAS  DS    0H                                                       08670001
         MVC   W#LINE+1(29),=C'*** WARNING *** TTR in member'           08680001
         MVC   W#LINE+1+30(8),PDS2NAME                                  08690001
         HEXES PDS2TTRP,3,W#LINE+1+39 Directory TTR                     08700001
         MVC   W#LINE+1+48(17),=C'(beyond DS1LSTAR)'                    08710001
         BAL   R14,PRT            Print a line                          08720002
         OI    W#FLAG1,W#F1ERR    Set error                             08730001
         CLC   W#RC,=A(8)         Have higher return code set        05 08740005
         BNL   RCSET010           Yes, leave it                      05 08750005
         MVC   W#RC,=A(8)         Set return code                    05 08760005
RCSET010 DS    0H                                                    05 08770005
         B     NEXTMBR            Get next member                       08780002
         DROP  R3                                                       08790001
         DROP  R2                                                       08800001
********************************************************************    08810001
* End of directory                                                 *    08820001
********************************************************************    08830001
NOTDIREC DS    0H                                                       08840001
         SR    R15,R15            Simulated EOF (good read)             08850001
MBREOF   DS    0H                                                       08860001
         L     R0,W#RDTOT         End of file in directory              08870001
         ST    R0,W#DIRUSD        Used count                            08880001
         ST    R0,W#DIRALC        Allocated count                       08890001
         B     PRESORT                                                  08900002
LASTUSED DS    0H                                                       08910001
         L     R0,W#RDTOT         End used entries in directory         08920001
         ST    R0,W#DIRUSD                                              08930001
RPTEXCP  DS    0H                                                       08940001
         BAL   R14,STAT           Read and collect statistics           08950002
         LTR   R15,R15                                                  08960001
         BZ    RPTEXCP                                                  08970002
         L     R0,W#RDTOT                                               08980001
         ST    R0,W#DIRALC        Allocated count                       08990001
PRESORT  DS    0H                                                       09000001
         NI    W#FLAG1,255-W#F1ERRD Turn off the in directory flag      09010001
         ST    R15,W#TEMP         Save for later                        09020001
         SR    R0,R0                                                    09030001
         ST    R0,W#RDTOT         Reinitialize W#RDTOT                  09040001
         ST    R0,W#MAXBLK        Reinitialize W#MAXBLK                 09050001
         ST    R0,W#BYTCNT        Reinitialize W#BYTCNT                 09060001
         MVC   W#MINBLK,=X'7F000000' Reinitialize minblk                09070001
********************************************************************    09080001
* Sort the member array by MBBCCHHR                                *    09090001
********************************************************************    09100001
         C     R5,MBRTBL          Any members?                          09110001
         BZ    NULLPDS            No, branch                            09120002
         TM    W#FLAG1,W#F1DBG                                          09130002
         BNO   DBG0040                                                  09140002
         MVC   W#LINE+1(16),=C'Unsorted entries'                        09150002
         BAL   R14,PRT          Print a line                            09160002
         LA    R2,MBRTBL                                                09170002
         USING TBLMENT,R2                                               09180002
DBG0030  DS    0H                                                       09190002
         CR    R2,R5                                                    09200002
         BNL   DBG0040                                                  09210002
         MVC   W#LINE+1(7),=C'TBLMENT'                                  09220002
         LA    R0,L'TBLMENT                                             09230002
         LA    R1,TBLMENT                                               09240002
         BAL   R14,DMPAD                                                09250002
         AH    R2,=AL2(L'TBLMENT)                                       09260002
         B     DBG0030                                                  09270002
         DROP  R2                                                       09280002
DBG0040  DS    0H                                                       09290002
*                                                                       09300001
         LR    R1,R5                                                    09310001
         LA    R2,MBRTBL                                                09320001
         SR    R1,R2                                                    09330001
         SR    R0,R0                                                    09340001
         LA    R2,L'TBLMENT       Entry length                          09350002
         DR    R0,R2                                                    09360001
         STH   R1,W#SRNENT        Number of entries                     09370001
         LA    R0,L'TBLMENT       Entry length                          09380002
         STH   R0,W#SRENTL        Length of an entry                    09390001
         LA    R0,L'TBLMCHR       Key length                            09400001
         STH   R0,W#SRKEYL        Length of the key                     09410001
         LA    R0,TBLMCHR-TBLMENT Key offset                            09420001
         STH   R0,W#SRKEYD        Displacement of key                   09430001
         LA    R0,MBRTBL          Table address                         09440001
         LA    R1,W#SRNENT        Sort parameters                       09450001
         STM   R0,R1,W#SRTPRM     Save parameters to sort               09460001
         TM    W#FLAG1,W#F1DBG                                          09470002
         BNO   DBG0050                                                  09480002
         MVC   W#LINE+1(15),=C'SORT parameters'                         09490002
         LA    R1,W#SRTPRM                                              09500002
         LA    R0,16                                                    09510002
         BAL   R14,DMPAD                                                09520002
DBG0050  DS    0H                                                       09530002
         LA    R1,W#SRTPRM        Address sort parameters               09540001
         L     R15,=A(SORT)       Sort routine address                  09550001
         BALR  R14,R15            Call sort                             09560002
         LTR   R15,R15            Successful sort                       09570001
         BZ    SORTED             Yes                                   09580002
         MVC   W#LINE+1+1(8),=C'SORT RC='                               09590001
         ST    R15,W#DWORD                                              09600001
         UNPK  W#LINE+1+09(9),W#DWORD(5)                                09610001
         TR    W#LINE+1+09(8),P#HEXTBL-240                              09620001
         MVC   W#LINE+1+17(4),=C' R0='                                  09630001
         ST    R0,W#DWORD                                               09640001
         UNPK  W#LINE+1+21(9),W#DWORD(5)                                09650001
         TR    W#LINE+1+21(8),P#HEXTBL-240                              09660001
         MVC   W#LINE+1+29(4),=C' R1='                                  09670001
         ST    R1,W#DWORD                                               09680001
         UNPK  W#LINE+1+33(9),W#DWORD(5)                                09690001
         TR    W#LINE+1+33(8),P#HEXTBL-240                              09700001
         MVI   W#LINE+1+41,C' '                                         09710001
         BAL   R14,PRT            Print a line                          09720002
         B     ENDDIAG                                                  09730002
SORTED   DS    0H                                                       09740001
         TM    W#FLAG1,W#F1DBG                                          09750002
         BNO   DBG0060                                                  09760002
         MVC   W#LINE+1+1(8),=C'SORT RC='                               09770002
         ST    R15,W#DWORD                                              09780002
         UNPK  W#LINE+1+09(9),W#DWORD(5)                                09790002
         TR    W#LINE+1+09(8),P#HEXTBL-240                              09800002
         MVC   W#LINE+1+17(4),=C' R0='                                  09810002
         ST    R0,W#DWORD                                               09820002
         UNPK  W#LINE+1+21(9),W#DWORD(5)                                09830002
         TR    W#LINE+1+21(8),P#HEXTBL-240                              09840002
         MVC   W#LINE+1+29(4),=C' R1='                                  09850002
         ST    R1,W#DWORD                                               09860002
         UNPK  W#LINE+1+33(9),W#DWORD(5)                                09870002
         TR    W#LINE+1+33(8),P#HEXTBL-240                              09880002
         MVI   W#LINE+1+41,C' '                                         09890002
         BAL   R14,PRT          Print a line                            09900002
DBG0060  DS    0H                                                       09910002
         TM    W#FLAG1,W#F1DBG                                          09920002
         BNO   DBG0080                                                  09930002
         MVC   W#LINE+1(14),=C'Sorted entries'                          09940002
         BAL   R14,PRT          Print a line                            09950002
         LA    R2,MBRTBL                                                09960002
         USING TBLMENT,R2                                               09970002
DBG0070  DS    0H                                                       09980002
         CR    R2,R5                                                    09990002
         BNL   DBG0080                                                  10000002
         MVC   W#LINE+1(7),=C'TBLMENT'                                  10010002
         LA    R0,L'TBLMENT                                             10020002
         LA    R1,TBLMENT                                               10030002
         BAL   R14,DMPAD                                                10040002
         AH    R2,=AL2(L'TBLMENT)                                       10050002
         B     DBG0070                                                  10060002
         DROP  R2                                                       10070002
DBG0080  DS    0H                                                       10080002
*                                                                       10090001
         LR    R2,R5              End plus one                          10100001
         SH    R2,=AL2(L'TBLMENT) Last member                           10110002
         USING TBLMENT,R2                                               10120001
         MVC   W#LINE+1(L'LASTMEMS),LASTMEMS                            10130001
         MVC   W#LINE+1(8),TBLMNAME Last member in the pds              10140001
         LA    R1,W#LINE+1        Member name                           10150001
         LA    R15,W#LINE+2+L'LASTMEMS Where to put hex value           10160001
         BAL   R14,MBRCK          Check for unprintables in name        10170002
         DROP  R2                                                       10180001
         BAL   R14,PRT            Print a line                          10190002
NULLPDS  DS    0H                                                       10200001
         USING TBLMENT,R2                                               10210001
         L     R15,W#TEMP         Restore the return code               10220001
         LA    R2,MBRTBL                                                10230001
         B     NXTONE                                                   10240002
NXTREAL  DS    0H                                                       10250001
         AH    R2,=AL2(L'TBLMENT) Last member was real                  10260002
NXTONE   DS    0H                                                       10270001
         CR    R2,R5              End of member table                   10280001
         BNL   LASTMTCH           Yes                                   10290002
         L     R0,W#BYTCNT        Last member was gas                   10300001
         ST    R0,W#SAVTOT        Save for later                        10310001
         CH    R15,=H'8'          End of data set?                   03 10320003
         BE    LASTMTCH           Yes, branch                           10330002
         OI    W#FLAG1,W#F1ERRR   Set flag for actual member            10340001
         MVC   W#SAVMBR,TBLMNAME                                        10350001
         CLC   TBLMCHR,W#IOBSEK   Next MBBCCHHR in the table?           10360001
         BE    REALRD             Yes, branch to read loop              10370002
         BH    DOGAS              No, higher a gas member               10380002
         MVC   W#LINE+1(L'TTRTOLOW),TTRTOLOW                            10390001
         MVC   W#LINE+1+16(8),TBLMNAME                                  10400001
         LA    R1,W#LINE+1+16     Member name                           10410001
         LA    R15,W#LINE+2+L'TTRTOLOW Where to put hex value           10420001
         BAL   R14,MBRCK          Check for unprintables in name        10430002
         MBBTTR TBLMCHR,W#TEMP    Convert MBBCCHHR to TTRN              10440001
         HEXES W#TEMP,3,W#LINE+1+32                                     10450001
         MBBTTR W#IOBSEK,W#TEMP   Convert MBBCCHHR to TTRN              10460001
         HEXES W#TEMP,3,W#LINE+1+77                                  03 10470003
         BAL   R14,PRT            Print a line                          10480002
         L     R1,W#DIRERR        Directory error count                 10490001
         AH    R1,=H'1'                                                 10500002
         ST    R1,W#DIRERR                                              10510001
         B     NXTREAL            Skip on by this one                   10520002
********************************************************************    10530001
* Read gas member                                                  *    10540001
********************************************************************    10550001
DOGAS    DS    0H                                                       10560001
         CLC   W#LSTADR,W#CURMBB  Past the DS1LSTAR marker?          04 10570004
         BE    LASTMTCH           Yes                                04 10580004
         L     R1,W#GASCNT        A gas member                          10590001
         AH    R1,=H'1'                                                 10600002
         ST    R1,W#GASCNT        Add one to the gas member count       10610001
         NI    W#FLAG1,255-W#F1ERRR Turn off the actual member flag     10620001
         TM    W#FLAG1,W#F1GAS    Gas records desired?                  10630001
         BNO   GASRD              No, branch                            10640002
         MBBTTR W#IOBSEK,W#TEMP   Convert MBBCCHHR to TTRN              10650001
         MVC   W#OUTLIN(L'GASMEM),GASMEM W#OUTLIN has gas message       10660001
         HEXES W#TEMP,3,W#OUTLIN+16 Format gas member start TTR         10670001
         HEXES W#IOBSEK,8,W#OUTLIN+44 MBBCCHHR                          10680001
         XC    W#GASLIN,W#GASLIN  Start of gas records                  10690001
GASRD    DS    0H                                                       10700001
         BAL   R14,STAT           Read gas member                       10710002
         LTR   R15,R15            End of gas member                     10720001
         BNZ   GASRDEF            Yes, handle reporting                 10730002
         L     R1,W#GASREC        Get gas block count                   10740001
         AH    R1,=H'1'           Add one to the gas block count        10750002
         ST    R1,W#GASREC        Save gas block count                  10760001
         TM    W#FLAG1,W#F1GAS    Gas records desired?                  10770001
         BNO   GASRD              No, no gas member lines               10780002
         TM    FM1RECFM,DCBRECU   RECFM=U?                              10790002
         BO    GASRD              Yes, no gas member lines              10800002
         TM    FM1RECFM,DCBRECV   RECFM=V?                              10810002
         BO    GASRD              Yes, no gas member lines              10820002
         ICM   R1,3,FM1LRECL      Is LRECL zero                         10830001
         BZ    GASRD              Yes, no gas member lines              10840002
         L     R0,W#LS            Get length of block                   10850001
         LA    R14,BUF            Buffer address                        10860001
DODATA   DS    0H                                                       10870001
         CLC   W#GASLIN,W#GASLS#  End of lines to list                  10880001
         BNL   GASRD              Yes, just read                        10890002
         L     R15,W#GASLIN       Increment                             10900001
         AH    R15,=H'1'           gas records                          10910002
         ST    R15,W#GASLIN         prepared                            10920001
         MH    R15,=AL2(L'W#WRKLN1) Index into W#WRKLN1-9               10930002
         LA    R15,W#WRKLN1-L'W#WRKLN1(R15) Current line                10940001
         LH    R1,FM1LRECL        Get LRECL                             10950001
         CR    R0,R1              Last record smaller than LRECL        10960001
         BNL   DODATA1            No                                    10970002
         LR    R1,R0              Use whats left in block               10980001
DODATA1  DS    0H                                                       10990001
         CH    R1,=AL2(L'W#WRKLN1) Max length to list exceeded?         11000002
         BNH   DODATA2            No                                    11010002
         LA    R1,L'W#WRKLN1      Limit output length to 80 bytes       11020002
DODATA2  DS    0H                                                       11030001
         BCTR  R1,0               Machine length                        11040001
         MVC   0(,R15),0(R14)     Copy line to gas member line          11050001
         EX    R1,*-6                                                   11060002
         TR    0(L'W#WRKLN1,R15),P#DMPTBL Blank any non-printables      11070001
         AH    R14,FM1LRECL       Next record in block                  11080001
         SH    R0,FM1LRECL        Less one record processed             11090001
         BP    DODATA             If more to do                         11100002
         B     GASRD              Next block                            11110002
*        EOF gas member                                                 11120001
GASRDEF  DS    0H                                                       11130001
         ST    R15,W#GASRC        Save return code                   05 11140005
         L     R0,W#BYTCNT                                              11150001
         S     R0,W#SAVTOT        Gas bytes this member                 11160001
         L     R1,W#GASBYT                                              11170001
         AR    R1,R0                                                    11180001
         ST    R1,W#GASBYT        Total gas bytes                       11190001
         C     R0,W#MAXGAS                                              11200001
         BNH   GASRDEF1                                                 11210002
         ST    R0,W#MAXGAS        Max bytes/gas member                  11220001
GASRDEF1 DS    0H                                                       11230001
         C     R0,W#MINGAS                                              11240001
         BNL   GASRDEF2                                                 11250002
         ST    R0,W#MINGAS        Min bytes/gas member                  11260001
GASRDEF2 DS    0H                                                       11270001
         TM    W#FLAG1,W#F1GAS    Gas records desired?                  11280001
         BNO   GASRDEF4           No, no gas reporting                  11290002
         L     R0,W#BYTCNT        Gas member total size                 11300001
         S     R0,W#SAVTOT        Less start member size                11310001
         CVD   R0,W#DWORD                                               11320001
         MVC   W#OUTLIN+29(12),=X'402020206B2020206B202120'             11330001
         ED    W#OUTLIN+29(12),W#DWORD+3                                11340001
         MVC   W#LINE+1(L'W#OUTLIN),W#OUTLIN                            11350001
         BAL   R14,PRT            Print gas member line                 11360002
         MVC   W#OUTLIN,W#LINE    Clear work line                       11370001
         ICM   R4,15,W#GASLIN     Any gas lines                         11380001
         BZ    GASRDEF4           No                                    11390002
         LA    R3,W#WRKLN1        First gas record                      11400001
GASRDEF3 DS    0H                                                       11410001
         MVC   W#LINE+1(L'W#WRKLN1),0(R3) Copy record to print          11420001
         BAL   R14,PRT            Print record                          11430002
         MVC   0(L'W#WRKLN1,R3),W#LINE Clear member line                11440001
         AH    R3,=AL2(L'W#WRKLN1) Next line                            11450002
         BCT   R4,GASRDEF3        Print gas member record               11460002
GASRDEF4 DS    0H                                                       11470001
         L     R15,W#GASRC        Restore return code                05 11480005
         B     NXTONE                                                   11490002
*                                                                       11500001
REALRD   DS    0H                                                       11510001
         BAL   R14,STAT           Real member                           11520002
         LTR   R15,R15            End of file?                          11530001
         BZ    REALRD             No, continue looping                  11540002
         TM    W#FLAG1,W#F1DIR                                          11550001
         BNO   REALRD1                                                  11560002
         MVC   W#LINE+1(8),TBLMNAME                                     11570001
         MVC   W#LINE+1+9(6),=C'at TTR'                                 11580001
         MBBTTR TBLMCHR,W#TEMP    Convert MBBCCHHR to TTRN              11590001
         HEXES W#TEMP,3,W#LINE+1+16                                     11600001
         MVC   W#LINE+1+25(4),=C'size'                                  11610001
         L     R0,W#BYTCNT                                              11620001
         S     R0,W#SAVTOT                                              11630001
         CVD   R0,W#DWORD                                               11640001
         MVC   W#LINE+1+29(12),=X'402020206B2020206B202120'             11650001
         ED    W#LINE+1+29(12),W#DWORD+3                                11660001
         HEXES TBLMCHR,8,W#LINE+45 MBBCCHHR                             11670001
         LA    R1,W#LINE+1        Member name                           11680001
         LA    R15,W#LINE+45+25   Where to put hex value                11690001
         BAL   R14,MBRCK          Check for unprintables in name        11700002
         BAL   R14,PRT            Print a line                          11710002
REALRD1  DS    0H                                                       11720001
         L     R0,W#BYTCNT                                              11730001
         S     R0,W#SAVTOT                                              11740001
         L     R1,W#RELBYT                                              11750001
         AR    R1,R0                                                    11760001
         ST    R1,W#RELBYT        Total bytes for real members          11770001
         C     R0,W#MAXREL                                              11780001
         BNH   REALRD2                                                  11790002
         ST    R0,W#MAXREL        Max bytes/real member                 11800001
REALRD2  DS    0H                                                       11810001
         C     R0,W#MINREL                                              11820001
         BNL   REALRD3                                                  11830002
         ST    R0,W#MINREL        Min bytes/real member                 11840001
REALRD3  DS    0H                                                       11850001
         B     NXTREAL                                                  11860002
*                                                                       11870001
LASTMTCH DS    0H                                                       11880001
         MVC   W#LINE+1(15),=C'"EOF"    at TTR'                         11890001
         HEXES FM1LSTAR,3,W#LINE+1+16                                   11900001
         TTRMBB TTR=FM1LSTAR,MBB=W#DWORD Convert to MBBCCHHR         03 11910003
         HEXES W#DWORD,8,W#LINE+45 MBBCCHHR to print                 03 11920003
         BAL   R14,PRT            Print a line                          11930002
         CLI   TBLMNAME,0         End of table                          11940001
         BE    ENDPO              Yes                                   11950002
LASTMTCL DS    0H                 List members missing                  11960001
         MVC   W#LINE+1(L'TTRTOFAR),TTRTOFAR                            11970001
         MVC   W#LINE+1+16(8),TBLMNAME                                  11980001
         LA    R1,W#LINE+1+16     Member name                           11990001
         LA    R15,W#LINE+2+L'TTRTOFAR Where to put hex value           12000001
         BAL   R14,MBRCK          Check for unprintables in name        12010002
         MBBTTR TBLMCHR,W#TEMP    Convert MBBCCHHR to TTRN              12020001
         HEXES W#TEMP,3,W#LINE+1+32                                     12030001
         HEXES FM1LSTAR,3,W#LINE+1+62                                   12040001
         BAL   R14,PRT            Print a line                          12050002
         L     R0,W#DIRERR        Count directory errors                12060001
         AH    R0,=H'1'                                                 12070002
         ST    R0,W#DIRERR                                              12080001
         AH    R2,=AL2(L'TBLMENT)                                       12090002
         CLI   TBLMNAME,0         End of table                          12100001
         BNE   LASTMTCL           No                                    12110002
         OI    W#FLAG1,W#F1ERR    Indicate error                        12120001
         CLC   W#RC,=A(8)         Have higher return code set        05 12130005
         BNL   RCSET020           Yes, leave it                      05 12140005
         MVC   W#RC,=A(8)         Set return code                    05 12150005
RCSET020 DS    0H                                                    05 12160005
         DROP  R2                                                       12170001
*                                                                       12180001
ENDPO    DS    0H                 List members missing                  12190001
         L     R1,W#ALSCNT                                              12200001
         LTR   R1,R1                                                    12210001
         BZ    ENDPSPO                                                  12220002
         CLC   W#RELCNT,W#TBLCNT  Any alias without real?               12230001
         BE    ENDPSPO            No, done                              12240002
*                                                                       12250001
         BAL   R14,PRT            Print a line                          12260002
         BAL   R14,REREAD                                               12270002
ALIASCK  DS    0H                                                       12280001
         BAL   R14,MEMBERS        Get next directory enty               12290002
         LTR   R15,R15            ENd of directory?                     12300001
         BNZ   ENDPSPO            Yes                                   12310002
         USING PDS2,R1                                                  12320001
         TM    PDS2INDC,PDS2ALIS  Alias entry?                          12330001
         BNO   ALIASCK            No, get the next directory entry      12340002
         TTRMBB TTR=PDS2TTRP,MBB=W#DWORD Convert to TTR                 12350001
         LA    R2,MBRTBL          Table entry                           12360001
         SH    R2,=AL2(L'TBLMENT) Back one                              12370002
         USING TBLMENT,R2                                               12380001
ALIASCK1 DS    0H                                                       12390001
         AH    R2,=AL2(L'TBLMENT) Next table entry                      12400002
         CR    R2,R5              End of table?                         12410001
         BNL   ALIASCK2           Alias with no real                    12420002
         CLC   TBLMCHR,W#DWORD    Corresponding table entry?            12430001
         BNE   ALIASCK1           No, try the next one                  12440002
         TM    TBLMFLG,TBLMFLGA   Alias in the table?                   12450001
         BNO   ALIASCK3           No, branch alias has real member      12460002
ALIASCK2 DS    0H                                                       12470001
         MVC   W#LINE+1(L'ALNOREAL),ALNOREAL                            12480001
         MVC   W#LINE+1+16(8),PDS2NAME Member to error message          12490001
         HEXES PDS2TTRP,3,W#LINE+1+32                                03 12500003
         LA    R1,W#LINE+1+16     Member name                           12510001
         LA    R15,W#LINE+2+L'ALNOREAL Where to put hex value           12520001
         BAL   R14,MBRCK          Check for unprintables in name        12530002
         DROP  R1                                                       12540001
         L     R1,W#DIRERR        Directory error count                 12550001
         AH    R1,=H'1'                                                 12560002
         ST    R1,W#DIRERR                                              12570001
         L     R1,W#ALSERR        Alias error count                     12580001
         AH    R1,=H'1'                                                 12590002
         ST    R1,W#ALSERR                                              12600001
         OI    W#FLAG1,W#F1ERR    Indicate error                        12610001
         BAL   R14,PRT            Alias with no real                    12620002
         CLC   W#RC,=A(4)         Have higher return code set        05 12630005
         BNL   RCSET030           Yes, leave it                      05 12640005
         MVC   W#RC,=A(4)         Set return code                    05 12650005
RCSET030 DS    0H                                                    05 12660005
ALIASCK3 DS    0H                                                       12670001
         B     ALIASCK                                                  12680002
         DROP  R2                                                       12690001
*                                                                       12700001
ENDPSPO  DS    0H                                                       12710001
         BAL   R14,PRT            Print a line                          12720002
         CLC   =X'7F000000',W#MINR                                      12730002
         BNE   ENDPSPO1                                                 12740002
         XC    W#MINR,W#MINR                                            12750002
ENDPSPO1 DS    0H                                                       12760002
         OUTPT W#MINR,MINRS                                             12770001
         L     R15,W#TRKUSD                                             12780001
         SRL   R15,1                                                    12790001
         A     R15,W#ALLREC       (W#ALLREC + W#TRKUSD/2) / W#TRKUSD    12800001
         SR    R14,R14                                                  12810001
         D     R14,W#TRKUSD       Average records per track             12820001
         LR    R0,R15                                                   12830001
         OUTPT (R0),AVGRS                                               12840001
         OUTPT W#MAXR,MAXRS                                             12850001
         BAL   R14,PRT            Print a line                          12860002
         L     R15,W#TRKUSD                                             12870001
         SRL   R15,1                                                    12880001
         A     R15,W#TRKBYT       (W#TRKBYT + W#TRKUSD/2) / W#TRKUSD    12890001
         SR    R14,R14                                                  12900001
         D     R14,W#TRKUSD       Average bytes per track               12910001
         ST    R15,W#AVGBTR                                             12920001
         CLC   =X'7F000000',W#MINBYT                                    12930002
         BNE   ENDPSPO2                                                 12940002
         XC    W#MINBYT,W#MINBYT                                        12950002
ENDPSPO2 DS    0H                                                       12960002
         OUTPT W#MINBYT,MINBYTES  Min bytes/track                       12970001
         OUTPT W#AVGBTR,AVGBYTES  Avg bytes/track                       12980001
         OUTPT W#MAXBYT,MAXBYTES  Max bytes/track                       12990001
         BAL   R14,PRT            Print a line                          13000002
         OUTPT W#TRKBYT,TOTBYTS   Total data bytes on all tracks        13010001
         OUTPT W#GASBYT,GASBYTS   Gas data bytes on all tracks          13020001
         BAL   R14,PRT            Print a line                          13030002
         CLC   W#TOTERR,=F'0'                                           13040001
         BE    NOIOERR                                                  13050002
         OUTPT W#TOTERR,ERRORS    Read errors                           13060001
         BAL   R14,PRT            Print a line                          13070002
NOIOERR  DS    0H                                                       13080001
         CLC   =X'7F000000',W#MINBLK                                    13090002
         BNE   ENDPSPO3                                                 13100002
         XC    W#MINBLK,W#MINBLK                                        13110002
ENDPSPO3 DS    0H                                                       13120002
         OUTPT W#MINBLK,MINBLKS                                         13130001
         LA    R14,1              Take max of W#RDTOT and 1             13140002
         C     R14,W#RDTOT                                              13150001
         BH    NOIOERR2                                                 13160002
         L     R14,W#RDTOT                                              13170001
NOIOERR2 DS    0H                                                       13180001
         L     R1,W#RDTOT                                               13190001
         SRL   R1,1                                                     13200001
         A     R1,W#BYTCNT                                              13210001
         SR    R0,R0                                                    13220001
         DR    R0,R14             Avg blk= (W#BYTCNT + W#RDTOT/2) /     13230001
         LR    R0,R1              Max( W#RDTOT, 1)                      13240001
         OUTPT (R0),AVGBLKS                                             13250001
         OUTPT W#MAXBLK,MAXBLKS                                         13260001
         BAL   R14,PRT            Print a line                          13270002
         OUTPT W#RDTOT,NUMBLKS                                          13280001
         TM    FM1DSORG,DS1DSGPO  DSORG=PO?                             13290001
         BNO   ENDUP              No, done                              13300002
*                                                                       13310001
         OUTPT W#GASREC,GASBLKS                                         13320001
         OUTPT W#EOFCNT,ENDMBR                                          13330001
         OUTPT W#GASCNT,GASMBR                                          13340001
         L     R0,W#GASCNT                                              13350001
         LTR   R0,R0                                                    13360001
         BZ    NOGASMSG                                                 13370002
         BAL   R14,PRT            Print a line                          13380002
         CLC   =X'7F000000',W#MINGAS                                    13390002
         BNE   ENDPSPO4                                                 13400002
         XC    W#MINGAS,W#MINGAS                                        13410002
ENDPSPO4 DS    0H                                                       13420002
         OUTPT W#MINGAS,MINGASS   MIN BYTES PER GAS MEMBER              13430001
         L     R15,W#GASCNT                                             13440001
         SRL   R15,1                                                    13450001
         A     R15,W#GASBYT                                             13460001
         SR    R14,R14                                                  13470001
         D     R14,W#GASCNT                                             13480001
         LR    R0,R15                                                   13490001
         OUTPT (R0),AVGGASS       Avg bytes per gas member              13500001
         OUTPT W#MAXGAS,MAXGASS   Max bytes per gas member              13510001
         BAL   R14,PRT            Print a line                          13520002
         L     R1,W#GASBYT                                              13530001
         LA    R15,100                                                  13540002
         MR    R0,R15                                                   13550001
         AH    R1,=H'5'                                                 13560002
         L     R14,W#AVGBTR                                             13570001
         DR    R0,R14             Tracks=(W#GASBYT*100+5)/W#AVGBTR      13580001
         SR    R0,R0                                                    13590001
         LA    R15,10                                                   13600002
         DR    R0,R15                                                   13610001
         CVD   R1,W#DWORD                                               13620001
         MVC   W#LINE+1(13),=X'4020206B2020206B2021204B20'              13630001
         LA    R1,W#LINE+11                                             13640001
         EDMK  W#LINE+1(13),W#DWORD+3                                   13650001
         MVC   W#LINE+1(13),0(R1)                                       13660001
         LA    R0,W#LINE+16                                             13670001
         SR    R0,R1                                                    13680001
         LA    R1,W#LINE                                                13690001
         AR    R1,R0                                                    13700001
         MVC   0(L'GASTRK,R1),GASTRK                                    13710001
         BAL   R14,PRT            Output gas track total                13720002
*                                                                       13730001
NOGASMSG DS    0H                                                       13740001
         BAL   R14,PRT            Print a line                          13750002
         L     R0,W#EOFCNT                                              13760001
         S     R0,W#GASCNT                                              13770001
         BNP   NOREAL                                                   13780002
         ST    R0,W#TEMP                                                13790001
         CLC   =X'7F000000',W#MINREL                                    13800002
         BNE   ENDPSPO5                                                 13810002
         XC    W#MINREL,W#MINREL                                        13820002
ENDPSPO5 DS    0H                                                       13830002
         OUTPT W#MINREL,MINRELS   Min bytes per real member             13840001
         L     R15,W#TEMP                                               13850001
         SRL   R15,1                                                    13860001
         A     R15,W#RELBYT                                             13870001
         SR    R14,R14                                                  13880001
         D     R14,W#TEMP                                               13890001
         LR    R0,R15                                                   13900001
         OUTPT (R0),AVGRELS       Avg bytes per member                  13910001
         OUTPT W#MAXREL,MAXRELS   Max bytes per member                  13920001
         B     SOMEARE                                                  13930002
NOREAL   DS    0H                                                       13940001
         MVC   W#LINE+1(L'NOREALS),NOREALS                              13950001
         BAL   R14,PRT            Print a line                          13960002
SOMEARE  DS    0H                                                       13970001
         BAL   R14,PRT            Print a line                          13980002
*                                                                       13990001
         L     R2,DCBDEBAD        Get DEB address                       14000001
         N     R2,=X'00FFFFFF'    Clean DEB address                     14010002
         USING DEBBASIC,R2                                              14020001
         LA    R1,DEBBASND        First extent in DEB                   14030001
         USING DEBDASD,R1                                               14040001
         MVC   W#LINE+1(17),=C'Directory ends at'                       14050001
*        TRKADDR ABSTOREL,        Calculate relative track              14060002
*              DEBSTRCC,          CCHH to convert                       14070002
*              REG=(R14,R15)      Result and work registers             14080002
         ICM   R14,B'1100',DEBSTRCC+2 Get 12 bits of cylinder           14090002
         SRL   R14,4              Position for other 16 bits            14100002
         ICM   R14,B'0011',DEBSTRCC Get low order 16 bits.              14110002
         MH    R14,=H'15'         Multiply by tracks/cyl.               14120002
         ICM   R15,B'1000',DEBSTRCC+3 Get low order byte (cH)           14130002
         SLL   R15,4              Isolate four H bits                   14140002
         SRL   R15,28             Shift to low order four bits          14150002
         ALR   R14,R15            Add tracks to tracks in cylinders     14160002
*                                                                       14170002
         L     R15,DEBUCBAD       Get UCB address                       14180001
         N     R15,=X'00FFFFFF'   Purify UCB address                    14190002
         DROP  R2                                                       14200001
         DROP  R1                                                       14210001
*        TRKCALC FUNCTN=TRKCAP,   Request track capacity for directory  14220002
*              UCB=(R15),         UCB address                           14230002
*              RKDD==X'01080100', R=1 Key length=8 Data length=256      14240002
*              REGSAVE=YES,       Preserve registers                    14250002
*              MF=(E,W#TRKCLC)    Parameter list                        14260002
         LA    R1,W#TRKCLC        LOAD PARAMETER REG 1                  14270002
         ST    R15,0(,R1)         ADDR OF DEVTAB OR UCB IN LIST         14280002
         MVI   4(R1),B'10000100'  FLAGS TO LIST                         14290002
         L     R15,=X'01080100'   MOVE RKDD                             14300002
         ST    R15,8(,R1)         TO LIST                               14310002
         L     R15,16             ADDRESS OF CVT                        14320002
         L     R15,232(,R15)      ADDRESS OF SECTOR CONV RTN            14330002
         BAL   R14,12(,R15)       USE STAR ENTRY ON CALL                14340002
         LM    R1,R12,24(R13)     RESTORE REGS 1-12                     14350002
         L     R14,12(,R13)       RESTORE REG 14                        14360002
*                                                                       14370002
         LR    R3,R0              Save blocks per track                 14380001
         SR    R0,R0              Clear for divide                      14390001
         L     R1,W#DIRALC        Get allocated directory blocks        14400001
         DR    R0,R3              Get tracks allocated                  14410001
         AH    R0,=H'1'           Relative to 1                         14420002
         LR    R2,R0              Save last record of directory         14430001
         AR    R1,R14             Add to tracks in dir to start track   14440001
*        TRKADDR RELTOABS,        Convert to absolute CCHH              14450002
*              W#TEMP,            Converted CCHH                        14460002
*              REG=(R0)           Work registers 2nd is relative track  14470002
         SLR   R0,R0               Prepare for divide                   14480002
         D     R0,=F'15'           Div by tracks/cylinder: 0cccCCCC     14490002
         SLL   R0,12               0000000H->0000H000                   14500002
         SLDL  R0,16               0000H000 0cccCCCC->H0000ccc CCCC0000 14510002
         LR    R15,R0              Save H0000ccc                        14520002
         SLL   R0,4                H0000ccc->0000ccc0                   14530002
         SRL   R15,28              H0000ccc->0000000H                   14540002
         OR    R0,R15              0000ccc0->0000cccH                   14550002
         OR    R0,R1               CCCCcccH    OR remainder in          14560002
         STCM  R0,15,W#TEMP        Store converted value                14570002
*                                                                       14580002
         XC    W#DWORD,W#DWORD    Clear for CCHH to MBBCCHHR            14590001
         MVC   W#DWORD+3(4),W#TEMP Get CCHH                             14600001
         STC   R2,W#DWORD+7       Save last record on track             14610001
         HEXES W#DWORD,8,W#LINE+19 Directory end CCHH                   14620001
         MBBTTR W#DWORD           Convert to TTR                        14630001
         MVI   W#LINE+43,C'('                                           14640001
         HEXES W#TEMP,3,W#LINE+44 Directory end TTR                     14650001
         MVI   W#LINE+52,C')'                                           14660001
         BAL   R14,PRT            Print a line                          14670002
         OUTPT (R3),DIRBLKTR                                            14680001
         OUTPT W#DIRALC,ALLBLK                                          14690001
         OUTPT W#DIRUSD,USEBLK                                          14700001
         L     R1,W#RELCNT                                              14710001
         A     R1,W#ALSCNT                                              14720001
         ST    R1,W#MINBLK                                              14730001
         OUTPT W#MINBLK,USENAME                                         14740001
         ICM   R1,15,W#MBRUNP                                           14750001
         BZ    NOUNPMBR                                                 14760002
         OUTPT W#MBRUNP,MBRUNP                                          14770001
NOUNPMBR DS    0H                                                       14780001
         ICM   R1,15,W#ALSCNT                                           14790001
         BZ    NOALIAS                                                  14800002
         OUTPT W#ALSCNT,ALSNAME                                         14810001
         ICM   R1,15,W#ALSERR                                           14820001
         BZ    NOALIAS                                                  14830002
         OUTPT W#ALSERR,ALSERRS                                         14840001
NOALIAS  DS    0H                                                       14850001
         ICM   R0,15,W#DIRERR     Any directory errors                  14860001
         BE    ENDUP              No                                    14870002
         MVC   W#LINE+1(L'DIRBADMS),DIRBADMS                            14880001
         MVC   W#LINE+1+L'DIRBADMS(12),=X'402020206B2020206B202120'     14890001
         LA    R1,W#LINE+1+L'DIRBADMS+11                                14900001
         CVD   R0,W#DWORD                                               14910001
         EDMK  W#LINE+1+L'DIRBADMS(12),W#DWORD+3                        14920001
         MVC   W#LINE+1+L'DIRBADMS+1(12),0(R1)                          14930001
         BAL   R14,PRT            Print a line                          14940002
*                                                                       14950001
ENDUP    DS    0H                                                       14960001
         MVC   W#OPNLST,P#OPNLST  Init OPEN parameter list              14970001
         CLOSE W#INDCB,MF=(E,W#OPNLST)                                  14980002
********************************************************************    14990001
* Clean up                                                         *    15000001
********************************************************************    15010001
         B     ENDCLOSE                                              05 15020005
ENDDIAG  DS    0H                                                       15030001
         MVC   W#LINE+1(2),=C'W#'                                       15040001
         LA    R0,W#LEN                                                 15050002
         LA    R1,W#                                                    15060001
         BAL   R14,DMPAD                                                15070002
ENDRC16  DS    0H                                                    05 15080005
         CLC   W#RC,=A(16)        Have higher return code set        05 15090005
         BNL   ENDCLOSE           Yes, leave it                      05 15100005
         MVC   W#RC,=A(16)        Set return code                    05 15110005
ENDCLOSE DS    0H                                                       15120001
         L     R2,W#RC              Return code                      05 15130005
         TM    W#OUTDCB+(DCBOFLGS-IHADCB),DCBOFOPN OPEN successful?     15140002
         BNO   ENDCLOS2                                                 15150002
         LA    R1,=C'Return code'                                       15160002
         LA    R15,11                                                   15170002
         LR    R0,R2                                                    15180002
         OUTPT (R0),(R1),LN=(R15) Print return code message             15190002
         MVC   W#OPNLST,P#OPNLST  Init open parameter list              15200002
         CLOSE W#OUTDCB,MF=(E,W#OPNLST) CLOSE print                     15210002
ENDCLOS2 DS    0H                                                       15220002
         LTR   R1,R10                                                   15230002
         BZ    ENDCLOS3                                                 15240002
         L     R0,=A(L'BUF)                                             15250002
         FREEMAIN R,LV=(0),A=(1)                                        15260002
ENDCLOS3 DS    0H                                                       15270002
         LTR   R1,R9                                                    15280002
         BZ    ENDCLOS4                                                 15290002
         L     R0,=A(MBRTBLN)                                           15300002
         FREEMAIN R,LV=(0),A=(1)                                        15310002
ENDCLOS4 DS    0H                                                       15320002
         LR    R1,R13             Work area address                     15330001
         L     R13,4(,R13)        Callers save area                     15340001
         LA    R0,W#LEN                                                 15350002
         FREEMAIN R,LV=(0),A=(1)                                        15360002
         LR    R15,R2             Set return code                       15370001
         RETURN (14,12),RC=(15)                                         15380001
********************************************************************    15390001
* Checks for unprintables in member name and add to message        *    15400001
********************************************************************    15410001
MBRCK    DS    0H                                                       15420001
         MVC   W#DWORD,0(R1)      Copy member name                      15430001
         TR    W#DWORD,P#DMPTBL   Remove unprintables                   15440001
         CLC   W#DWORD,0(R1)      Any unprintables?                  04 15450004
         BER   R14                No, exit                              15460001
         MVC   0(16,R15),=C'member in hex X''' Add to message        04 15470004
         UNPK  16(9,R15),0(5,R1)  Get member name                       15480001
         UNPK  24(9,R15),4(5,R1)   in hex                               15490001
         TR    16(16,R15),P#HEXTBL-240 Convert alpha digits             15500001
         MVI   32(R15),C''''      Terminate the X'                      15510001
         LA    R15,34(,R15)       Next output area                   04 15520004
         MVC   0(8,R1),W#DWORD    Replace unprintables                  15530001
         L     R0,W#MBRUNP        Get unprintable member name counter   15540001
         AH    R0,=H'1'           Count unprintable member names        15550002
         ST    R0,W#MBRUNP        Save unprintable member name counter  15560001
         BR    R14                                                      15570001
********************************************************************    15580001
* Issues EXCPs and gathers statistics                              *    15590001
********************************************************************    15600001
STAT     DS    0H                                                       15610001
         ST    R14,W#STAT14                                             15620001
STATBGN  DS    0H                                                       15630001
         BAL   R14,EXCP                                                 15640002
         LA    R14,STATRCTB       Jump table address                    15650002
         AR    R14,R15            Add return code                       15660001
         BR    R14                Branch table                          15670001
STATRCTB B     STATRC0            Good read                             15680002
         B     STATRC4            End of file or end of member          15690002
         B     STATRC8            End of data set                       15700002
         B     STATRCC            I/O error                             15710002
*        I/O error                                                      15720001
STATRCC  DS    0H                                                       15730001
         L     R14,W#TOTERR                                             15740001
         AH    R14,=H'1'          Update number of consecutive errors   15750002
         ST    R14,W#TOTERR                                             15760001
         L     R14,W#CONERR                                             15770001
         AH    R14,=H'1'          Update number of consecutive errors   15780002
         ST    R14,W#CONERR                                             15790001
         TM    W#FLAG1,W#F1SKER   Skipping I/O error check?             15800001
         BO    STATRCC1           Yes, allow thru                       15810002
         CH    R0,=H'10'          Allow only 10 consecutive errors      15820002
         BL    STATRCC1                                                 15830002
         MVC   W#LINE+1(L'TOOMANY),TOOMANY Too many consecutive errors  15840001
         BAL   R14,PRT            Print a line                          15850002
         B     ENDRC16                                                  15860002
STATRCC1 DS    0H                                                       15870001
         MVC   W#LINE+1(L'IOERROR),IOERROR                              15880001
         HEXES W#SAVECB,1,W#LINE+1+31 ECB error code                    15890001
         HEXES W#CURMBB+3,5,W#LINE+1+40 Current disk CCHHR              15900001
         MBBTTR W#IOBSEK,W#TEMP   Convert MBBCCHHR to TTRN              15910001
         HEXES W#TEMP,3,W#LINE+1+59                                     15920001
         BAL   R14,PRT            Print a line                          15930002
         TM    FM1DSORG,DS1DSGPO  PDS?                                  15940001
         BNO   STATBER            No, branch                            15950002
         TM    W#FLAG1,W#F1ERRD   Error in the directory?               15960001
         BO    STATDER            Yes, branch                           15970002
         TM    W#FLAG1,W#F1ERRR   Actual member?                        15980001
         BNO   STATGER            No, branch                            15990002
         MVC   W#LINE+1(L'CURRMBR),CURRMBR                              16000001
         MVC   W#LINE+1(8),W#SAVMBR                                     16010001
         LA    R1,W#LINE+1        Member name                           16020001
         LA    R15,W#LINE+2+L'CURRMBR Where to put hex value            16030001
         BAL   R14,MBRCK          Check for unprintables in name        16040002
         BAL   R14,PRT            Output the current member name        16050002
         B     STATRC4A                                                 16060002
STATGER  DS    0H                                                       16070001
         MVC   W#LINE+1(L'GASERRS),GASERRS Error in reading gas data    16080001
         BAL   R14,PRT            Print a line                          16090002
         B     STATRC4A                                                 16100002
STATDER  DS    0H                                                       16110001
         MVC   W#LINE+1(L'DIRERRS),DIRERRS Dir I/O error (ignore block) 16120001
         BAL   R14,PRT            Print a line                          16130002
STATBER  DS    0H                                                       16140001
         OUTPT W#RDTOT,BLKNUMS    Read error message                    16150001
         B     STATBGN            Continue using the next block         16160002
*        End of data set                                                16170001
STATRC8  DS    0H                 End of data set                       16180001
         B     STATNXT1           Finish up processing                  16190002
*        End of file or end of member                                   16200001
STATRC4  DS    0H                                                       16210001
         XC    W#CONERR,W#CONERR  End of member                         16220001
STATRC4A DS    0H                                                       16230001
         LA    R15,4              Treat as an end of member condition   16240002
         L     R1,W#EOFCNT                                              16250001
         AH    R1,=H'1'           End of member counter                 16260002
         ST    R1,W#EOFCNT                                              16270001
         CLC   W#MBCH,W#CURMBB    New track                             16280001
         BNE   STATXIT                                                  16290002
         L     R1,W#LASTR                                               16300001
         AH    R1,=H'1'                                                 16310002
         ST    R1,W#LASTR         Update the record count               16320001
         B     STATXIT                                                  16330002
*        Good read                                                      16340001
STATRC0  DS    0H                                                       16350001
         XC    W#CONERR,W#CONERR  Good read                             16360001
         L     R1,W#RDTOT                                               16370001
         AH    R1,=H'1'                                                 16380002
         ST    R1,W#RDTOT         Count of blocks read                  16390001
         L     R1,W#LS            Current blksize                       16400001
         LR    R0,R1              Save for later                        16410001
         C     R1,W#MINBLK                                              16420001
         BH    STATRC0A                                                 16430002
         ST    R1,W#MINBLK        Minimum length block read             16440001
STATRC0A DS    0H                                                       16450001
         C     R1,W#MAXBLK                                              16460001
         BL    STATRC0B                                                 16470002
         ST    R1,W#MAXBLK        Maximum length block read             16480001
STATRC0B DS    0H                                                       16490001
         A     R1,W#BYTCNT                                              16500001
         ST    R1,W#BYTCNT        Total number of bytes read            16510001
         CLC   W#MBCH,W#CURMBB    Same MBBCCHH?                         16520001
         BNE   STATNXT            No, branch                            16530002
         A     R0,W#CRUBYT                                              16540001
         ST    R0,W#CRUBYT        Accumulate track byte count           16550001
         L     R1,W#LASTR                                               16560001
         AH    R1,=H'1'                                                 16570002
         ST    R1,W#LASTR         Accumulate record count/track         16580001
         B     STATXIT                                                  16590002
*        Next track                                                     16600001
STATNXT  DS    0H                                                       16610001
         L     R1,W#TRKUSD        Switch tracks                         16620001
         AH    R1,=H'1'                                                 16630002
         ST    R1,W#TRKUSD        Actual tracks used                    16640001
STATNXT1 DS    0H                                                       16650001
         MVC   W#MBCH,W#CURMBB    Save current track number             16660001
         L     R0,W#CRUBYT                                              16670001
         L     R1,W#LS                                                  16680001
         ST    R1,W#CRUBYT                                              16690001
         L     R1,W#TRKBYT                                              16700001
         AR    R1,R0                                                    16710001
         ST    R1,W#TRKBYT        Count of all characters read          16720001
         L     R1,W#LASTR                                               16730001
         LA    R14,1                                                    16740002
         ST    R14,W#LASTR                                              16750001
         L     R14,W#ALLREC                                             16760001
         AR    R14,R1                                                   16770001
         ST    R14,W#ALLREC       Count of all reads                    16780001
         LTR   R0,R0              First entry here?                     16790001
         BNP   STATNXT3           Yes, branch                           16800002
         C     R0,W#MINBYT                                              16810001
         BNL   STATNXT2                                                 16820002
         ST    R0,W#MINBYT        Min bytes/track                       16830001
STATNXT2 DS    0H                                                       16840001
         C     R1,W#MINR                                                16850001
         BNL   STATNXT3                                                 16860002
         ST    R1,W#MINR          Min record number/track               16870001
STATNXT3 DS    0H                                                       16880001
         C     R0,W#MAXBYT                                              16890001
         BNH   STATNXT4                                                 16900002
         ST    R0,W#MAXBYT        Max bytes/track                       16910001
STATNXT4 DS    0H                                                       16920001
         C     R1,W#MAXR                                                16930001
         BNH   STATXIT                                                  16940002
         ST    R1,W#MAXR          Max record number/track               16950001
*        Exit                                                           16960001
STATXIT  DS    0H                                                       16970001
         L     R14,W#STAT14                                             16980001
         BR    R14                                                      16990001
********************************************************************    17000001
* Directory read routine                                           *    17010001
********************************************************************    17020001
MEMBERS  DS    0H                                                       17030001
         ST    R14,W#MEMB14                                             17040001
         LM    R15,R1,W#DIRPTR    Pick up addr, incr, limit             17050001
         LTR   R1,R1              Initialized?                          17060001
         BNZ   DEBLOCK            Yes, branch                           17070002
         BAL   R14,REREAD         OPEN IN for input of the directory    17080002
GETBLK   DS    0H                                                       17090001
         BAL   R14,STAT           Get a directory block                 17100002
         LTR   R15,R15            End of file?                          17110001
         BP    MBRDONE            Yes, end of file indication           17120002
         CLC   W#LS,=A(256)       Good directory block?                 17130001
         BNE   NODIRBLK           No, branch                            17140002
         LA    R0,2               Increment is 2 first                  17150002
         LH    R1,BUF             Length halfword                       17160001
         AR    R1,R10             Limit                                 17170001
         BCTR  R1,0                                                     17180001
         LA    R15,BUF            Start                                 17190001
DEBLOCK  DS    0H                                                       17200001
         BXH   R15,R0,GETBLK                                            17210002
         USING PDS2,R15                                                 17220001
         IC    R0,PDS2INDC        Get length + flags                    17230001
         N     R0,=A(PDS2LUSR)    Get length bits                       17240001
         AR    R0,R0              Length * 2                            17250001
         AH    R0,=H'12'           +  12                                17260002
         STM   R15,R1,W#DIRPTR    Save for later                        17270001
         CLI   PDS2NAME,X'FF'     Last member                           17280001
         BNE   RETDIR             No, branch                            17290002
         LA    R15,8              Last member used indication           17300002
         B     MBRDONE                                                  17310002
RETDIR   DS    0H                                                       17320001
         TM    W#FLAG1,W#F1DBG                                          17330001
         BNO   DIREXIT                                                  17340002
         UNPK  W#LINE+1+00(9),PDS2NAME(5) Hex to display                17350001
         UNPK  W#LINE+1+08(9),PDS2NAME+4(5) Hex to display              17360001
         TR    W#LINE+1+00(16),P#HEXTBL-240 Convert hex A-F             17370001
         MVI   W#LINE+1+16,C' '   Clean up last hex digit               17380001
         SH    R0,=H'8'           Length less member name               17390002
         LA    R1,W#LINE+1+17     Start of output                       17400001
         LA    R15,PDS2TTRP       After directory member name           17410001
         DROP  R15                                                      17420001
DMPDIR   DS    0H                                                       17430001
         UNPK  0(3,R1),0(2,R15)   Hex to display                        17440001
         TR    0(2,R1),P#HEXTBL-240 Convert hex A-F                     17450001
         AH    R1,=H'2'           Next output                           17460002
         AH    R15,=H'1'          Next input                            17470002
         BCT   R0,DMPDIR          Dump the directory entry              17480002
         MVI   0(R1),C' '         Clean up last hex digit               17490001
         BAL   R14,PRT            Print a line                          17500002
DIREXIT  DS    0H                                                       17510001
         L     R1,W#DIRPTR        Address of member name (returned)     17520001
         SR    R15,R15            Good read indication                  17530001
         B     MBRDONE                                                  17540002
NODIRBLK DS    0H                                                       17550001
         MVC   W#LINE+1(L'EOFSIMS),EOFSIMS Record length is not 256     17560001
         BAL   R14,PRT            Print a line                          17570002
         OUTPT W#LS,BLOCKLEN      Output current lrecl                  17580001
         LA    R15,12             Error indication                      17590002
MBRDONE  DS    0H                                                       17600001
         L     R14,W#MEMB14       Return address                        17610001
         BR    R14                                                      17620001
********************************************************************    17630001
* OPENs the file with ddname IN                                    *    17640001
********************************************************************    17650001
OPENIN   DS    0H                                                       17660001
         ST    R14,W#EXCP14       Sve return address                    17670001
         MVC   W#OPNLST,P#OPNLST  Init OPEN parameter list              17680001
         OPEN  (W#INDCB,INPUT),MF=(E,W#OPNLST) OPEN IN DDNAME           17690002
         TM    DCBOFLGS,DCBOFOPN                                        17700002
         BO    OPENIN1                                                  17710002
         MVC   W#LINE+1(L'OPNFAIL),OPNFAIL                              17720002
         BAL   R14,PRT            Print error message                   17730002
         B     ENDRC16            Fatal error                           17740002
OPENIN1  DS    0H                                                       17750002
         LA    R0,W#JFCB          Initialize                            17760001
         ST    R0,W#EXLST          EXLST for                            17770001
         MVI   W#EXLST,X'87'        RDJFCB                              17780001
         MVC   W#OPNLST,P#OPNLST  Init OPEN parameter list              17790001
         RDJFCB (W#INDCB),MF=(E,W#OPNLST) Get JFCB for DSN              17800001
         LTR   R15,R15                                                  17810002
         BZ    OPENIN2                                                  17820002
         MVC   W#LINE+1(L'RDJFAIL),RDJFAIL                              17830002
         ST    R15,W#DWORD                                              17840002
         UNPK   W#LINE+1+L'RDJFAIL(9),W#DWORD(5)                        17850002
         TR     W#LINE+1+L'RDJFAIL(8),P#HEXTBL-240                      17860002
         MVI    W#LINE+1+L'RDJFAIL+8,C' '                               17870002
         BAL   R14,PRT            Print error message                   17880002
         B     ENDRC16            Fatal error                           17890002
OPENIN2  DS    0H                                                       17900002
         MVC   W#FMT1,P#FMT1      Initialize                            17910001
         LA    R15,JFCBDSNM        CAMLST                               17920001
         LA    R0,JFCBVOLS          parameters                          17930001
         LA    R1,W#F1DSCB                                              17940001
         STM   R15,R1,W#FMT1+4                                          17950001
         OBTAIN W#FMT1            Read in the format 1 DSCB             17960001
         LTR   R15,R15                                                  17970002
         BZ    OPENIN3                                                  17980002
         MVC   W#LINE+1(L'SRCFAIL),SRCFAIL                              17990002
         ST    R15,W#DWORD                                              18000002
         UNPK   W#LINE+1+L'SRCFAIL(9),W#DWORD(5)                        18010002
         TR     W#LINE+1+L'SRCFAIL(8),P#HEXTBL-240                      18020002
         MVI    W#LINE+1+L'SRCFAIL+8,C' '                               18030002
         BAL   R14,PRT            Print error message                   18040002
         B     ENDRC16            Fatal error                           18050002
OPENIN3  DS    0H                                                       18060002
         B     REREAD10                                                 18070002
********************************************************************    18080001
* Entry to reread the OPEN data set (DDNAME is IN)                 *    18090001
********************************************************************    18100001
REREAD   DS    0H                                                       18110001
         ST    R14,W#EXCP14       Save return address                   18120001
REREAD10 DS    0H                                                       18130001
         L     R1,DCBDEBAD        Get DEB address                       18140001
         N     R1,=X'00FFFFFF'    Clean DEB address                     18150002
         USING DEBBASIC,R1                                              18160001
         SR    R14,R14                                                  18170002
         IC    R14,DEBNMEXT       Number of extents                     18180002
         ST    R14,W#NUMEXT       Save number of extents                18190001
         LA    R14,DEBBASND-(DEBNMTRK+2-DEBDASD) First ext - 1 ext      18200002
         DROP  R1                                                       18210001
         ST    R14,W#CUREXT       Save current extent pointer           18220001
         MVI   W#IOBSEK,X'00'     Reset the extent number               18230001
         LA    R15,4              Early exit flag                       18240002
         B     FIRSTONE           Do the initial extent                 18250002
********************************************************************    18260001
* For each extent, initialize CCHHR, sector number and read in the *    18270001
* length of the first record.                                      *    18280001
********************************************************************    18290001
EACHXTNT DS    0H                                                       18300001
         SR    R1,R1                                                    18310002
         IC    R1,W#IOBSEK        Get extent we are processing          18320002
         AH    R1,=H'1'           Next extent                           18330002
         STC   R1,W#IOBSEK        Save next extent number               18340001
         C     R1,W#NUMEXT        Past last extent?                     18350001
         BNL   EXCP070            Yes, no end of data set recorded      18360002
*                                                                       18370001
FIRSTONE DS    0H                                                       18380001
         ST    R15,W#EXCP15       Save return code                      18390001
         L     R1,W#CUREXT                                              18400001
         USING DEBDASD,R1                                               18410001
         LA    R1,DEBNMTRK+2      Get next extent entry                 18420002
         MVC   W#IOBSEK+3(4),DEBSTRCC Extent start                      18430001
         ST    R1,W#CUREXT        Save current extent pointer           18440001
         DROP  R1                                                       18450001
         MVI   W#IOBSEK+7,0                                             18460001
         MVI   W#SECTNM,0         Set sector number=zero                18470001
         LA    R1,W#CCW1A                                               18480001
         ST    R1,W#IOBCCW                                              18490001
         EXCP  W#IOB                                                    18500001
         WAIT  ECB=W#ECB                                                18510001
         CLI   W#ECB,X'7F'        Good read?                            18520001
         BE    READOK             Yes, branch                           18530002
         MVC   W#LINE+1(L'FIRSTRD),FIRSTRD                              18540001
         MVC   W#LINE+1+L'FIRSTRD+1(6),=C'ECB=X'''                      18550001
         UNPK  W#LINE+1+L'FIRSTRD+7(9),W#ECB(5)                         18560001
         TR    W#LINE+1+L'FIRSTRD+7(8),P#HEXTBL-240                     18570001
         MVI   W#LINE+1+L'FIRSTRD+15,C''''                              18580001
         BAL   R14,PRT            Print a line                          18590002
         B     ENDDIAG                                                  18600002
READOK   DS    0H                                                       18610001
         LA    R1,W#CCW1                                                18620001
         ST    R1,W#IOBCCW                                              18630001
         MVC   W#CCW3+6(2),W#DATALN Get length for next read            18640001
         MVI   W#IOBSEK+7,1       Set R=1                               18650001
         L     R15,W#EXCP15       Restore return code                   18660001
         LTR   R15,R15            Early exit desired?                   18670001
         BZ    EXCP010            No, issue the EXCP again              18680002
         L     R14,W#EXCP14       Return from OPENIN, REREAD or after   18690001
         BR    R14                EOF and extent violation              18700001
********************************************************************    18710001
* Entry for each EXCP to be performed                              *    18720001
********************************************************************    18730001
EXCP     DS    0H                                                       18740001
         ST    R14,W#EXCP14       Save return address                   18750001
EXCP010  DS    0H                                                       18760001
         CLI   W#ECB,X'42'        Extent violation last time?           18770001
         BE    EACHXTNT           Yes, do the next extent               18780002
         MVC   W#CURMBB,W#IOBSEK  Save the disk address of this record  18790001
         SR    R0,R0                                                    18800002
         ICM   R0,3,W#DATALN      Get data length                       18810002
         ST    R0,W#LS            Save the block length for this read   18820001
         EXCP  W#IOB              Read a block                          18830001
         WAIT  ECB=W#ECB          WAIT for I/O to complete              18840001
         SR    R15,R15            Good read flag                        18850001
         CLI   W#ECB,X'42'        Extent violation (next time)?         18860001
         BE    EXCP080            Yes, quit                             18870002
         CLC   W#LSTADR,W#CURMBB  Past the DS1LSTAR marker?             18880001
         BNH   EXCP070            Yes, end of file and data set         18890002
         CLI   W#ECB,X'7F'        Good read?                            18900001
         BE    EXCP080            Yes, quit                             18910002
         CLI   W#ECB,X'41'        Permanent error?                      18920001
         BE    EXCP020            Yes, branch                           18930002
         BAL   R14,PRT            Print a line                          18940002
         MVC   W#LINE+1(L'BADERROR),BADERROR                            18950001
         MVC   W#LINE+1(L'BADERROR),BADERROR                            18960001
         MVC   W#LINE+1+L'BADERROR+1(6),=C'ECB=X'''                     18970001
         UNPK  W#LINE+1+L'BADERROR+7(9),W#ECB(5)                        18980001
         TR    W#LINE+1+L'BADERROR+7(8),P#HEXTBL-240                    18990001
         MVI   W#LINE+1+L'BADERROR+15,C''''                             19000001
         BAL   R14,PRT            Print a line                          19010002
         B     EXCP030            Bad error ECB not hex 41 42 7F        19020002
EXCP020  DS    0H                                                       19030001
         TM    W#IOBCSW+4,X'01'   Actually EOF?                         19040001
         BO    EXCP040                                                  19050002
         CLC   W#IOBCSW+4(4),=X'00200000' Null member or data set?      19060001
         BE    EXCP040            Yes, branch                           19070002
         BAL   R14,PRT            Print a line                          19080002
         MVC   W#LINE+1(L'PERMERR),PERMERR                              19090001
         MVC   W#LINE+1(L'PERMERR),PERMERR                              19100001
         MVC   W#LINE+1+L'PERMERR+1(6),=C'ECB=X'''                      19110001
         UNPK  W#LINE+1+L'PERMERR+7(9),W#ECB(5)                         19120001
         TR    W#LINE+1+L'PERMERR+7(8),P#HEXTBL-240                     19130001
         MVI   W#LINE+1+L'PERMERR+15,C''''                              19140001
         BAL   R14,PRT            Print a line                          19150002
EXCP030  DS    0H                                                       19160001
         LA    R15,12             Permanent error not end of file       19170002
         MVC   W#SAVECB,W#ECB     Save ECB code for later               19180001
         B     EXCP050                                                  19190002
* EOF                                                                   19200001
EXCP040  DS    0H                                                       19210001
         TM    FM1DSORG,DS1DSGPS+DS1DSGDA DSORG=PS or DA?               19220001
         BNZ   EXCP070            Yes, end of file and data set         19230002
         LA    R15,4              End of member flag                    19240002
         CLC   =H'0',W#DATALN     Next block length = 0?                19250001
         BNE   EXCP080            No, branch                            19260002
EXCP050  DS    0H                                                       19270001
         ST    R15,W#EXCP15       Save return code                      19280001
         LA    R1,W#CCW1A         Need to reissue the initialization    19290001
         ST    R1,W#IOBCCW                                              19300001
         EXCP  W#IOB              Read length and address next block    19310001
         WAIT  ECB=W#ECB                                                19320001
         L     R15,W#EXCP15       Read error (12) or end of member (4)  19330001
         LA    R1,W#CCW1                                                19340001
         ST    R1,W#IOBCCW                                              19350001
         MVC   W#CCW3+6(2),W#DATALN Satalength for next excp            19360001
         CLI   W#ECB,X'42'        Extent violation?                     19370001
         BE    EACHXTNT           Yes, do the next extent early exit    19380002
         CLI   W#ECB,X'7F'        Good read?                            19390001
         BE    EXCP080            Yes, quit                             19400002
         CLI   W#ECB,X'41'        Permanent error?                      19410001
         BE    EXCP060            Yes, check EOF                        19420002
         BAL   R14,PRT            Print a line                          19430002
         MVC   W#LINE+1(L'BADERROR),BADERROR                            19440001
         MVC   W#LINE+1(L'BADERROR),BADERROR                            19450001
         MVC   W#LINE+1(L'BADERROR),BADERROR                            19460001
         MVC   W#LINE+1+L'BADERROR+1(6),=C'ECB=X'''                     19470001
         UNPK  W#LINE+1+L'BADERROR+7(9),W#ECB(5)                        19480001
         TR    W#LINE+1+L'BADERROR+7(8),P#HEXTBL-240                    19490001
         MVI   W#LINE+1+L'BADERROR+15,C''''                             19500001
         BAL   R14,PRT            Print a line                          19510002
         B     ENDDIAG                                                  19520002
EXCP060  DS    0H                                                       19530001
         TM    W#IOBCSW+4,X'01'   Null member (another EOF)?            19540001
         BO    EXCP080                                                  19550002
         BAL   R14,PRT            Print a line                          19560002
         MVC   W#LINE+1(L'PERMERR),PERMERR                              19570001
         MVC   W#LINE+1(L'PERMERR),PERMERR                              19580001
         MVC   W#LINE+1(L'PERMERR),PERMERR                              19590001
         MVC   W#LINE+1+L'PERMERR+1(6),=C'ECB=X'''                      19600001
         UNPK  W#LINE+1+L'PERMERR+7(9),W#ECB(5)                         19610001
         TR    W#LINE+1+L'PERMERR+7(8),P#HEXTBL-240                     19620001
         MVI   W#LINE+1+L'PERMERR+15,C''''                              19630001
         BAL   R14,PRT            Print a line                          19640002
         B     ENDDIAG                                                  19650002
EXCP070  DS    0H                                                       19660001
         LA    R15,8              End of file and data set flag         19670002
EXCP080  DS    0H                                                       19680001
         L     R14,W#EXCP14       Return address                        19690001
         BR    R14                                                      19700001
********************************************************************    19710001
* Output routine                                                   *    19720001
*   R0 Contains number to be formatted at front of line            *    19730001
*   R1 Contains the address of the string to output                *    19740001
*   R15 Contains the length of the string                          *    19750001
********************************************************************    19760001
OUTNUM   DS    0H                                                       19770001
         ST    R14,W#OUTN14                                             19780001
         BCTR  R15,0              Machine length                        19790001
         LR    R14,R1                                                   19800001
         MVC   W#LINE+1(12),=X'402020206B2020206B202120'                19810001
         LA    R1,W#LINE+12                                             19820001
         CVD   R0,W#DWORD                                               19830001
         EDMK  W#LINE+1(12),W#DWORD+3                                   19840001
         MVC   W#LINE+1(12),0(R1)                                       19850001
         LA    R0,W#LINE+15                                             19860001
         SR    R0,R1                                                    19870001
         LA    R1,W#LINE                                                19880001
         AR    R1,R0                                                    19890001
         MVC   0(,R1),0(R14)      <<Executed>>                          19900001
         EX    R15,*-6            Move in the string                    19910002
         BAL   R14,PRT            Print a line                          19920002
         L     R14,W#OUTN14       Return                                19930001
         BR    R14                                                      19940001
*********************************************************************** 19950001
* Write print line                                                    * 19960001
*********************************************************************** 19970001
PRT      DS    0H                                                       19980001
         ST    R14,W#PRTR14       Save return                           19990001
         TM    W#FLAG2,W#F2NOHD   No headings?                          20000001
         BO    PRTLINE            Yes, skip the check for headings.     20010002
         CP    W#LNCT,=P'+60'     End of page                           20020001
         BL    PRTCHK             No, check if line fit in page         20030002
PRTHDRS  DS    0H                                                       20040001
         AP    W#PGCT,=P'+1'      Count pages                           20050001
         MVC   W#HD1PG#,=X'40202120' Page count mask                    20060002
         ED    W#HD1PG#,W#PGCT    Edit page count                       20070002
         PUT   W#OUTDCB,W#HD1     Print heading 1                       20080001
         ZAP   W#LNCT,=P'+1'      Init line count                       20090001
         MVI   W#LINE,C'0'        Skip after heading                    20100001
PRTCHK   DS    0H                                                       20110001
         CLI   W#LINE,C'+'        Overprint?                            20120001
         BE    PRTLINE            Yes, don't count                      20130002
         CLI   W#LINE,C'1'        New line?                             20140001
         BE    PRTHDRS            Yes, print header                     20150002
         CLI   W#LINE,C' '        Write after advancing 1?              20160001
         BE    PRTLINE1           Yes, go check if fit                  20170002
         CLI   W#LINE,C'0'        Write after advancing 2?              20180001
         BE    PRTLINE2           Yes, go check if fit                  20190002
         CLI   W#LINE,C'-'        Write after advancing 3?              20200001
         BE    PRTLINE3           Yes, go check if fit                  20210002
         B     PRTLINE            Ignore any other ctl chars            20220002
PRTLINE1 DS    0H                                                       20230001
         AP    W#LNCT,=P'+1'      Add to line count                     20240001
         B     PRTVFY             Go see if it will fit                 20250002
PRTLINE2 DS    0H                                                       20260001
         AP    W#LNCT,=P'+2'      Add to line count                     20270001
         B     PRTVFY             Go see if it will fit                 20280002
PRTLINE3 DS    0H                                                       20290001
         AP    W#LNCT,=P'+3'      Add to line count                     20300001
PRTVFY   DS    0H                                                       20310001
         CP    W#LNCT,=P'+60'     Overflow?                             20320001
         BH    PRTHDRS            Yes, force header                     20330002
PRTLINE  DS    0H                                                       20340001
         PUT   W#OUTDCB,W#LINE    Print a line                          20350001
         MVI   W#LINE,C' '        Clear print line                      20360001
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              20370001
         L     R14,W#PRTR14       Restore return                        20380001
         BR    R14                Return to caller                      20390001
**********************************************************************  20400001
* Dump with address of storage dumped                                *  20410001
**********************************************************************  20420001
DMPAD    DS    0H                                                       20430001
         ST    R14,W#DMPA14                                             20440002
         STM   R0,R15,W#DMPRGS    Save registers                        20450002
         ST    R1,W#DMPOFF                                              20460001
         LA    R2,W#LINE+L'W#LINE-1                                     20470001
         LA    R0,L'W#LINE-1                                            20480002
DMPAD1   DS    0H                                                       20490002
         CLI   0(R2),C' '                                               20500002
         BE    DMPAD2                                                   20510002
         SH    R2,=H'1'                                                 20520002
         BCT   R0,DMPAD1                                                20530002
DMPAD2   DS    0H                                                       20540002
         MVC   2(2,R2),=C'at'                                           20550001
         AH    R2,=H'5'           Output area address                   20560002
         LA    R1,W#DMPOFF        Address of offset to dump             20570001
         LA    R15,4              Convert 4 bytes                       20580002
         BAL   R14,DMPDSP         Convert it to display                 20590002
         BAL   R14,PRT            Print address of data                 20600002
         LM    R0,R15,W#DMPRGS    Save registers                        20610002
         BAL   R14,DMP            Dump storage                          20620002
         L     R14,W#DMPA14                                             20630002
         BR    R14                Return to caller                      20640001
*********************************************************************** 20650001
* Dump data                                                           * 20660001
*       Input: R0 = Length of data to dump                            * 20670001
*              R1 = Address of data to dump                           * 20680001
*********************************************************************** 20690001
DMP      DS    0H                                                       20700001
         STM   R0,R15,W#DMPRGS    Save registers                        20710002
         LR    R3,R1              Get address to dump                   20720001
         LR    R4,R0              Get length                            20730001
         XC    W#DMPOFF,W#DMPOFF  Save offset for dump                  20740001
         MVI   W#DMPFLG,W#DMPFL1  First line                            20750002
DMPDMPLP DS    0H                                                       20760001
         LTR   R4,R4              Any data to dump?                     20770001
         BZ    DMPHEXXT           Yes, all done                         20780002
         TM    W#DMPFLG,W#DMPFL1  First line?                           20790002
         BO    DMPALIN            Yes, can't have same as above         20800002
         LA    R0,32              Default length                        20810002
         CR    R4,R0              Length longer than 32?                20820001
         BNH   DMPDUPCK           No, were at last line                 20830002
         LR    R14,R3             Get current input area                20840001
         SR    R14,R0             Back to previous area                 20850001
         CLC   0(32,R14),0(R3)    Duplicate of previous line            20860001
         BNE   DMPDUPCK           No, do lines same as                  20870002
         SR    R4,R0              Reduce length to do                   20880001
         TM    W#DMPFLG,W#DMPFLD Duplicate in progress?                 20890002
         BO    DMPNXTLN           Yes, we have first offset             20900002
         L     R14,W#DMPOFF       Get current offset                    20910001
         ST    R14,W#DUP1ST       Save as first offset                  20920002
         OI    W#DMPFLG,W#DMPFLD Set duplicate                          20930002
         B     DMPNXTLN           Continue                              20940002
DMPDUPCK DS    0H                                                       20950001
         TM    W#DMPFLG,W#DMPFLD Duplicate in progress?                 20960002
         BNO   DMPALIN            No, no duplicate to report            20970002
         MVC   W#LINE+7(5),=C'lines' Move literal                       20980001
         LA    R2,W#LINE+13       Output area address                   20990001
         LA    R1,W#DUP1ST+2      Address of offset to dump             21000002
         LA    R15,2              Convert 4 bytes                       21010002
         BAL   R14,DMPDSP         Convert it to display                 21020002
         MVI   W#LINE+17,C'-'     Thru literal                          21030001
         L     R1,W#DMPOFF        Get current offset                    21040001
         S     R1,=A(32)          Get last duplicate offset             21050001
         ST    R1,W#DUP1ST        Save for dumping                      21060002
         LA    R2,W#LINE+18       Output area address                   21070001
         LA    R1,W#DUP1ST+2      Address of offset to dump             21080002
         LA    R15,2              Convert 4 bytes                       21090002
         BAL   R14,DMPDSP         Convert it to display                 21100002
         MVC   W#LINE+23(13),=C'same as above' move literal             21110001
         BAL   R14,PRT            Print a line                          21120002
         NI    W#DMPFLG,255-W#DMPFLD Reset duplicate in progress        21130002
DMPALIN  DS    0H                                                       21140001
         LA    R2,W#LINE+1        Output area address                   21150001
         LA    R1,W#DMPOFF+2      Address of offset to dump             21160001
         LA    R15,2              Convert 4 bytes                       21170002
         BAL   R14,DMPDSP         Convert it to display                 21180002
         AH    R2,=H'2'           Skip 1 between offset & data          21190002
         LR    R1,R3              Address of data                       21200001
         LA    R5,32              Default length                        21210002
         CR    R4,R5              Length longer than 32 ?               21220001
         BH    DMPDODMP           Yes, use 32                           21230002
         LR    R5,R4              Use what is left                      21240001
DMPDODMP DS    0H                                                       21250001
         SR    R4,R5              Reduce amount to do                   21260001
         MVI   W#LINE+89,C'*'     Box in display portion                21270001
         BCTR  R5,0               Make zero based                       21280001
         EX    R5,DMPMVC          Do move                               21290002
         EX    R5,DMPTR           Translate out bad stuff               21300002
         AH    R5,=H'1'           Restore length                        21310002
         MVI   W#LINE+122,C'*'    Complete box                          21320001
DMPDMPHX DS    0H                                                       21330001
         LA    R15,4              4 bytes to process                    21340002
         CR    R5,R15             Length longer than 4?                 21350001
         BH    DMPDMPIT           Yes, dump 4 bytes                     21360002
         LR    R15,R5             Use length left                       21370001
DMPDMPIT DS    0H                                                       21380001
         SR    R5,R15             Reduce amount to do                   21390001
         BAL   R14,DMPDSP         Convert data                          21400002
         AH    R2,=H'1'           Skip 1 byte                           21410002
         LA    R0,W#LINE+43       Halfway point address                 21420001
         CR    R0,R2              At halfway point?                     21430001
         BNE   DMPDMPNX           No, continue                          21440002
         AH    R2,=H'1'           Skip 1 byte                           21450002
DMPDMPNX DS    0H                                                       21460001
         LTR   R5,R5              Any left to do ?                      21470001
         BH    DMPDMPHX           Yes, go do it                         21480002
         BAL   R14,PRT            Print a line                          21490002
DMPNXTLN DS    0H                                                       21500001
         L     R1,W#DMPOFF        Get offset in record                  21510001
         AH    R1,=H'32'          Add in length we will dump            21520002
         ST    R1,W#DMPOFF        Save offset in record                 21530001
         AH    R3,=H'32'          Next input area                       21540002
         NI    W#DMPFLG,255-W#DMPFL1 Not first line                     21550002
         B     DMPDMPLP           Loop thru until done                  21560002
DMPHEXXT DS    0H                                                       21570001
         LM    R0,R15,W#DMPRGS    Restore callers regs                  21580002
         BR    R14                Exit . . .                            21590001
DMPMVC   MVC   W#LINE+90(0),0(R1) <<< executed >>>                      21600001
DMPTR    TR    W#LINE+90(0),P#DMPTBL <<< executed >>>                   21610001
*********************************************************************** 21620001
* Convert hex data to display                                         * 21630001
*********************************************************************** 21640001
DMPDSP   DS    0H                                                       21650001
         UNPK  0(1,R2),0(1,R1)    Get first hex byte                    21660001
         NI    0(R2),X'0F'        Remove zone                           21670001
         MVC   1(1,R2),0(R1)      Move second hex byte                  21680001
         NI    1(R2),X'0F'        Remove its zone also                  21690001
         TR    0(2,R2),P#HEXTBL   Translate to hex                      21700001
         AH    R2,=H'2'           Point to next output area             21710002
         AH    R1,=H'1'           Point to next input area              21720002
         BCT   R15,DMPDSP         Loop thru data                        21730002
         BR    R14                Exit                                  21740001
CODEEND  DC    0H'0'                                                    21750001
         DC    (((((*-STATS)/32)+1)*32)-(*-STATS))X'00'                 21760002
********************************************************************    21770001
* Constants                                                        *    21780001
********************************************************************    21790001
         LTORG ,                                                        21800001
*                                                                       21810001
P#HEXTBL DC    CL16'0123456789ABCDEF'                                   21820001
*                                                                       21830001
P#JLTBL2 DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  21840002
*                                                                       21850001
         DC    0D'0'                                                    21860001
P#OPNLSB OPEN  0,MF=L                                                   21870002
P#OPNLST EQU   P#OPNLSB,*-P#OPNLSB                                      21880001
*                                                                       21890001
         DC    0D'0'                                                    21900001
P#FMT1B  CAMLST SEARCH,JFCBDSNM-JFCBDSNM,                              *21910001
               JFCBVOLS-JFCBVOLS,                                      *21920001
               W#F1DSCB-W#F1DSCB                                        21930001
P#FMT1   EQU   P#FMT1B,*-P#FMT1B                                        21940001
*                                                                       21950001
         DC    0D'0'                                                    21960001
P#OUT    DCB   DDNAME=OUT,DSORG=PS,MACRF=PM,                           *21970001
               RECFM=FBA,LRECL=133                                      21980001
P#OUTDCB EQU   P#OUT,*-P#OUT                                            21990001
*                                                                       22000001
         DC    0D'0'                                                    22010001
P#IN     DCB   DDNAME=IN,DSORG=PS,MACRF=E,EXLST=W#EXLST-W#EXLST         22020001
P#INDCB  EQU   P#IN,*-P#IN                                              22030001
*                                                                       22040002
P#DMPTBL DC    CL256' '                                                 22050002
         ORG   P#DMPTBL+X'4A'     Cent                                  22060002
         DC    X'4A4B4C4D4E4F50'                                        22070002
         ORG   P#DMPTBL+X'5A'     Exclamation                           22080002
         DC    X'5A5B5C5D5E5F6061'                                      22090002
         ORG   P#DMPTBL+X'6A'                                           22100002
         DC    X'6A6B6C6D6E6F'                                          22110002
         ORG   P#DMPTBL+X'7A'                                           22120002
         DC    X'7A7B7C7D7E7F'                                          22130002
         ORG   P#DMPTBL+C'a'                                            22140002
         DC    C'abcdefghi'                                             22150002
         ORG   P#DMPTBL+C'j'                                            22160002
         DC    C'jklmnopqr'                                             22170002
         ORG   P#DMPTBL+C's'                                            22180002
         DC    C'stuvwxyz'                                              22190002
         ORG   P#DMPTBL+C'A'                                            22200002
         DC    C'ABCDEFGHI'                                             22210002
         ORG   P#DMPTBL+C'J'                                            22220002
         DC    C'JKLMNOPQR'                                             22230002
         ORG   P#DMPTBL+C'S'                                            22240002
         DC    C'STUVWXYZ'                                              22250002
         ORG   P#DMPTBL+C'0'                                            22260002
         DC    C'0123456789'                                            22270002
         ORG   ,                                                        22280002
*                                                                       22290001
PROTECT  DC    C'x Is the protection key'                               22300002
LSTAR    DC    C'DS1LSTAR is'                                           22310002
EXTHDR   DC    C'Extent  UCB  CC.CC.HH.HH   CC.CC.HH.HH  Tracks  Volume*22320002
               '                                                        22330002
EXTUND   DC    C'------  ---  -----------   -----------  ------  ------*22340002
               '                                                        22350002
NULL     DC    C'Data set is empty'                                     22360002
GASMEM   DC    C'"Gas"    at TTR tt.tt.rr size'                         22370002
GASTRK   DC    C'Tracks regained by compressing'                        22380002
LASTMEMS DC    C'xxxxxxxx is the last real member in the data set'      22390002
CURRMBR  DC    C'xxxxxxxx is the member (end of member simulated)'      22400002
GASERRS  DC    C'*** WARNING *** error in a gas member (EOF simulated)' 22410002
DIRERRS  DC    C'*** WARNING *** Read error in the directory'           22420002
EOFSIMS  DC    C'*** WARNING *** Bad directory record (length error)'   22430002
PERMERR  DC    C'*** WARNING *** Permanent error'                       22440002
BADERROR DC    C'*** WARNING *** Read error'                            22450002
SCALOS   DC    C'Data set is allocated in'                              22460002
NOSEC    DC    C'No secondary allocation quantity in the label'         22470002
EOFSS    DC    C'End of file'                                           22480002
MANYENT  DC    C'*** WARNING *** More than 20,000 members'              22490002
TTRTOLOW DC    C'*** WARNING *** xxxxxxxx at TTR tt.tt.rr overlaps prio*22500003
               r member ending at TTR tt.tt.rr'                      03 22510003
TTRTOFAR DC    C'*** WARNING *** xxxxxxxx at TTR tt.tt.rr past DS1LSTAR*22520002
                at TTR tt.tt.rr'                                        22530002
ALNOREAL DC    C'*** WARNING *** xxxxxxxx at TTR xx.xx.xx is an alias b*22540003
               ut has no real entry'                                 03 22550003
DIRBADMS DC    C'*** WARNING *** Number of directory errors'            22560002
TOOMANY  DC    C'*** WARNING *** More than 10 consecutive I/O errors'   22570002
IOERROR  DC    C'*** WARNING *** Read error ECB=xx CCHHR cc.cc.hh.hh.rr*22580002
                TTR'                                                    22590002
OPNFAIL  DC    C'*** WARNING *** OPEN for IN DDNAME failed'             22600002
SRCFAIL  DC    C'*** WARNING *** OBTAIN for IN DDNAME failed RC='       22610002
RDJFAIL  DC    C'*** WARNING *** RDJFCB for IN DDNAME failed RC='       22620002
FIRSTRD  DC    C'*** WARNING *** First read of an extent failed'        22630002
PROGRAM  DC    C'STATDS - Disk Data Set Statistics Program - '          22640002
ABL      DC    C'            Written by  A. Bruce Leland'               22650002
NOREALS  DC    C'No real members in this partitioned data set'          22660002
         DC    (((((*-STATS)/4096)+1)*4096)-(*-STATS))X'00'             22670002
********************************************************************    22680002
* End base registers coverage                                      *    22690002
********************************************************************    22700002
MINRS    DC    C'Is the minimum number of records per track'            22710002
AVGRS    DC    C'Is the average number of records per track'            22720002
MAXRS    DC    C'Is the maximum number of records per track'            22730002
MINBYTES DC    C'Is the minimum number of data bytes per track'         22740002
AVGBYTES DC    C'Is the average number of data bytes per track'         22750002
MAXBYTES DC    C'Is the maximum number of data bytes per track'         22760002
MINGASS  DC    C'Is the minimum number of bytes in any gas member'      22770002
AVGGASS  DC    C'Is the average number of bytes in a gas member'        22780002
MAXGASS  DC    C'Is the maximum number of bytes in any gas member'      22790002
MINRELS  DC    C'Is the minimum number of bytes in any real member'     22800002
AVGRELS  DC    C'Is the average number of bytes in a real member'       22810002
MAXRELS  DC    C'Is the maximum number of bytes in any real member'     22820002
MINBLKS  DC    C'Is the shortest block length'                          22830002
AVGBLKS  DC    C'Is the average block length'                           22840002
MAXBLKS  DC    C'Is the maximum block length'                           22850002
TOTBYTS  DC    C'Total data bytes in this data set'                     22860002
GASBYTS  DC    C'"Gas" data bytes in this data set'                     22870002
NUMBLKS  DC    C'Total data blocks are recorded'                        22880002
GASBLKS  DC    C'Of these are gas blocks'                               22890002
ERRORS   DC    C'*** WARNING *** Read errors occured'                   22900002
ENDMBR   DC    C'End of member (file marks) are recorded'               22910002
GASMBR   DC    C'Of these are for gas members'                          22920002
ALLBLK   DC    C'Directory blocks are allocated'                        22930002
USEBLK   DC    C'Of these in use'                                       22940002
USENAME  DC    C'Member names in the directory'                         22950002
ALSNAME  DC    C'Of these are aliases'                                  22960002
ALSERRS  DC    C'Aliases with no real members'                          22970002
MBRUNP   DC    C'Members with with unprintables in member name'         22980002
NUMTRKS  DC    C'Tracks are allocated for this data set'                22990002
EXTENTS  DC    C'Is the secondary allocation quantity'                  23000002
FRETRKS  DC    C'Tracks are not in use'                                 23010002
NUMEXTS  DC    C'Extents in data set'                                   23020002
NOBDBS   DC    C'Bytes are used in last PDS directory block'            23030002
TRBALS   DC    C'Bytes are available on the last used track'            23040002
BLOCKLEN DC    C'Is the block length  (end of directory simulated)'     23050002
BLKNUMS  DC    C'Is the block number (block ignored)'                   23060002
KEYLEN   DC    C'Is the key length'                                     23070002
KEYPOS   DC    C'Is the relative key position'                          23080002
DIRBLKTR DC    C'Directory blocks per track'                            23090002
DATAEND  DC    0X'0'                                                    23100001
         DC    (((((*-STATS)/256)+1)*256)-(*-STATS))X'00'               23110002
********************************************************************    23120001
* Work areas                                                       *    23130001
********************************************************************    23140001
W#       DSECT ,                                                        23150001
W#SA     DC    9D'0'              Save area                             23160001
*                                                                       23170001
W#CCW1A  CCW   X'31',W#IOBSEK+3,X'60',5  Search id equal (CCHHR)        23180001
W#CCW2A  CCW   X'08',*-8,X'60',1         TIC                            23190001
W#CCW3A  CCW   X'92',W#IOBSEK+3,X'20',8  MT read next count             23200001
*                                                                       23210001
W#CCW0   CCW   X'23',W#SECTNM,X'60',1    Set sector                     23220001
W#CCW1   CCW   X'31',W#IOBSEK+3,X'60',5  Search id equal (CCHHR)        23230001
W#CCW2   CCW   X'08',*-8,X'60',1         TIC                            23240001
W#CCW3   CCW   X'06',BUF-BUF,X'60',L'BUF Read data                      23250001
W#CCW4   CCW   X'92',W#IOBSEK+3,X'60',8  MT read next count             23260001
W#CCW5   CCW   X'22',W#SECTNM,X'20',1    Read sector number             23270001
*                                                                       23280001
         DC    0D'0'                                                    23290001
W#IOB    DC    XL4'C2000000'                                            23300001
W#IOBECB DC    A(W#ECB)           ECB address                           23310001
W#IOBCSW DC    XL8'0'                                                   23320001
W#IOBCCW DC    A(W#CCW1)          CCW address                           23330001
W#IOBDCB DC    A(W#INDCB)         DCB address                           23340001
         DC    XL8'0'                                                   23350001
W#IOBSEK DC    XL8'0'             Next MBBCCHHR address                 23360001
W#KEYLN  DC    X'0'               Next keylength                        23370001
W#DATALN DC    XL2'0'             Next record length                    23380001
W#SECTNM DC    X'0'               Next sector number                    23390001
*                                                                       23400001
W#ECB    DC    F'0'               EXCP ECB                              23410001
*                                                                       23420001
W#EXLST  DC    0A(0),X'87',AL3(W#JFCB) RDJFCB EXLST                     23430001
*                                                                       23440001
         DS    0D'0'                                                    23450001
W#OPNLST DS    XL(L'P#OPNLST)     OPEN/CLOSE/RDJFCB parameter list      23460001
*                                                                       23470001
         DS    0D'0'                                                    23480001
W#OUTDCB DS    XL(L'P#OUTDCB)     OUT DCB                               23490001
*                                                                       23500001
         DS    0D'0'                                                    23510001
W#INDCB  DS    XL(L'P#INDCB)      IN DCB                                23520001
*                                                                       23530001
         DS    0D'0'                                                    23540001
W#FMT1   DS    XL(L'P#FMT1)       CAMLST search                         23550001
*                                                                       23560001
*#TRKCLC TRKCALC FUNCTN=TRKCAP,UCB=0,MF=L                               23570002
W#TRKCLC DC    A(0)               DVCT OR UCB ADDR, OR DEVTYPE          23580002
         DC    X'00'              FLAG BYTE                             23590002
         DC    X'00'              RESERVED                              23600002
         DC    AL2(0)             TRACK BALANCE                         23610002
         DC    AL1(0)             RECORD NUMBER                         23620002
         DC    AL1(0)             KEY LENGTH                            23630002
         DC    AL2(0)             DATA LENGTH                           23640002
*                                                                       23650001
W#DWORD  DS    D                                                        23660002
W#RC     DS    A(0)                                                  05 23670005
W#GASRC  DS    A(0)                                                  05 23680005
W#DIRPTR DC    3A(0)              Savearea for R15, R0 and R1           23690001
W#LS     DC    F'0'               Length of the current record          23700001
W#TEMP   DC    F'0'               Work storage                          23710001
W#LASTR  DC    F'0'               Current number of records/trk         23720001
W#OUTN14 DC    A(0)               Savearea for return address           23730001
W#MEMB14 DC    A(0)               Savearea for return address           23740001
W#EXCP14 DC    A(0)               Return register for EXCP              23750001
W#EXCP15 DC    A(0)               Exit flag register savearea           23760001
W#STAT14 DC    A(0)               Return register for STAT              23770001
W#CUREXT DC    F'0'               Address of the current extent         23780001
W#NUMEXT DC    F'0'               Total extents in the data set         23790001
W#RDTOT  DC    F'0'               Total records read                    23800001
W#MINBLK DC    X'7F000000'        Minimum length block                  23810001
W#MAXBLK DC    F'0'               Maximum length block                  23820001
W#BYTCNT DC    F'0'               Total bytes read                      23830001
W#GASBYT DC    F'0'               Total bytes in gas members            23840001
W#RELBYT DC    F'0'               Total bytes in real members           23850001
W#MINGAS DC    X'7F000000'        Min bytes in gas members              23860001
W#MAXGAS DC    F'0'               Max bytes in gas members              23870001
W#MINREL DC    X'7F000000'        Min bytes in real members             23880001
W#MAXREL DC    F'0'               Max bytes in real members             23890001
W#SAVTOT DC    F'0'               Starting byte count hold              23900001
W#MAXR   DC    F'0'               Maximum records/track                 23910001
W#MINR   DC    X'7F000000'        Minimum records/track                 23920001
W#TRKBYT DC    F'0'               Sum of all blocksizes                 23930001
W#CONERR DC    F'0'               Number of consecutive errors          23940001
W#TOTERR DC    F'0'               Total read errors                     23950001
W#DIRERR DC    F'0'               Directory errors                      23960001
W#ALSERR DC    F'0'               Alias errors                          23970001
W#ALLREC DC    F'0'               Sum of all records read               23980001
W#CRUBYT DC    F'0'               Current track byte count              23990001
W#MAXBYT DC    F'0'               Maximum bytes/track                   24000001
W#MINBYT DC    X'7F000000'        Minimum bytes/track                   24010001
W#TRKUSD DC    F'0'               Actual count of tracks used           24020001
W#EOFCNT DC    F'0'               Count of end of files                 24030001
W#GASCNT DC    F'0'               Number of gas members                 24040001
W#GASREC DC    F'0'               Number of gas records                 24050001
W#AVGBTR DC    F'0'               Average bytes per track               24060001
W#FRETRK DC    F'0'               Free tracks                           24070001
W#TOTTRK DC    F'0'               Total tracks                          24080001
W#ALSCNT DC    F'0'               Aliases in the directory              24090001
W#RELCNT DC    F'0'               Real entries in the directory         24100001
W#TBLCNT DC    F'0'               Member table entries                  24110001
W#MBRUNP DC    F'0'               Members with unprintable name         24120001
W#DIRALC DC    F'0'               Directory blocks allocated            24130001
W#DIRUSD DC    F'0'               Directory blocks used                 24140001
W#GASLS# DC    F'0'               Number of gas member lines to list    24150001
W#GASLIN DC    F'0'               Number of gas member lines to list    24160001
*                                                                       24170001
W#FLAG1  DC    X'01'              Flag byte                             24180001
W#F1GAS  EQU   X'01'              Gas records desired (default)         24190001
W#F1LBL  EQU   X'02'              Labels only (no data read)            24200001
W#F1SKER EQU   X'04'              Skip I/O error counting               24210001
W#F1DIR  EQU   X'08'              List directory                        24220001
W#F1DBG  EQU   X'10'              Debugging                             24230001
W#F1ERR  EQU   X'20'              Error has occured                     24240001
W#F1ERRR EQU   X'40'              Error in actual member flag           24250001
W#F1ERRD EQU   X'80'              Error in directory records            24260001
*                                                                       24270001
W#FLAG2  DC    X'00'              Flag byte                             24280001
W#F2NOHD EQU   X'01'              Skip writing headings at page break   24290001
*                                                                       24300001
W#SAVECB DC    X'0'               Save area for ECB                     24310001
W#SAVMBR DC    CL8' '             Member name                           24320001
W#LSTADR DC    XL8'0'             Last MBBCCHHR address                 24330001
W#CURMBB DC    XL8'0'             Current MBBCCHHR address              24340001
W#MBCH   DC    XL7'0'             Save area for MBBCCHH                 24350001
W#OUTLIN DC    CL90' '                                                  24360001
W#WRKLN1 DC    CL80' '                                                  24370001
W#WRKLN2 DC    CL80' '                                                  24380001
W#WRKLN3 DC    CL80' '                                                  24390001
W#WRKLN4 DC    CL80' '                                                  24400001
W#WRKLN5 DC    CL80' '                                                  24410001
W#WRKLN6 DC    CL80' '                                                  24420001
W#WRKLN7 DC    CL80' '                                                  24430001
W#WRKLN8 DC    CL80' '                                                  24440001
W#WRKLN9 DC    CL80' '                                                  24450001
*                                                                       24460001
W#SRTPRM DS    2A                 Address of table/sort parmeters       24470001
*                                                                       24480001
W#SRNENT DS    H                  Number of entries                     24490001
W#SRENTL DS    H                  Length of an entry                    24500001
W#SRKEYL DS    H                  Length of the key                     24510001
W#SRKEYD DS    H                  Displacement of key                   24520001
*                                                                       24530001
W#DMPRGS DS    16A                                                      24540002
W#DMPOFF DS    A                                                        24550002
W#DUP1ST DS    A                                                        24560002
W#DMPA14 DS    A                                                        24570002
W#DMPFLG DS    X                                                        24580002
W#DMPFL1 EQU   X'80'                                                    24590002
W#DMPFLD EQU   X'40'                                                    24600002
*                                                                       24610001
W#PRTR14 DS    A                                                        24620002
W#LINE   DS    CL133                                                    24630002
W#CURDTE DS    A                                                        24640002
W#JLWK1  DS    A                                                        24650002
W#JLWK2  DS    P'+365'                                                  24660002
W#JLWK13 DS    P'+01'                                                   24670002
W#JLWK12 DS    P'+31'                                                   24680002
W#JLWK11 DS    P'+30'                                                   24690002
W#JLWK10 DS    P'+31'                                                   24700002
W#JLWK09 DS    P'+30'                                                   24710002
W#JLWK08 DS    P'+31'                                                   24720002
W#JLWK07 DS    P'+31'                                                   24730002
W#JLWK06 DS    P'+30'                                                   24740002
W#JLWK05 DS    P'+31'                                                   24750002
W#JLWK04 DS    P'+30'                                                   24760002
W#JLWK03 DS    P'+31'                                                   24770002
W#JLWK02 DS    P'+28'                                                   24780002
W#JLWK01 DS    P'+31'                                                   24790002
W#TIMWK4 DS    X'402021204B20204B20204B2020'                            24800002
W#LNCT   DS    PL2'+99'                                                 24810002
W#PGCT   DS    PL2'+0'                                                  24820002
W#HD1    DS    CL133                                                    24830002
         ORG   W#HD1+1                                                  24840002
W#HD1DTE DS    C'            '                                          24850002
         DS    C' '                                                     24860002
W#HD1TOD DS    C'HH:MM:SS'                                              24870002
         ORG   W#HD1+66-(24/2)                                          24880002
W#HD1TTL DS    C'Disk Data Set Statistics'                              24890002
         ORG   W#HD1+L'W#HD1-8                                          24900002
W#HD1PG  DS    C'Page'                                                  24910002
W#HD1PG# DS    C' 123'                                                  24920002
*                                                                       24930001
W#F1DSCB DS    0D,XL148                                                 24940002
FM1NOBDB EQU   W#F1DSCB+DS1NOBDB-DS1FMTID                               24950001
FM1DSORG EQU   W#F1DSCB+DS1DSORG-DS1FMTID                               24960001
FM1RECFM EQU   W#F1DSCB+DS1RECFM-DS1FMTID                               24970001
FM1BLKSI EQU   W#F1DSCB+DS1BLKL-DS1FMTID                                24980001
FM1LRECL EQU   W#F1DSCB+DS1LRECL-DS1FMTID                               24990001
FM1KEYL  EQU   W#F1DSCB+DS1KEYL-DS1FMTID                                25000001
FM1RKP   EQU   W#F1DSCB+DS1RKP-DS1FMTID                                 25010001
FM1SCALO EQU   W#F1DSCB+DS1SCALO-DS1FMTID                               25020001
FM1SAQU  EQU   W#F1DSCB+DS1SCALO+1-DS1FMTID                             25030002
FM1LSTAR EQU   W#F1DSCB+DS1LSTAR-DS1FMTID                               25040001
FM1TRBAL EQU   W#F1DSCB+DS1TRBAL-DS1FMTID                               25050001
*                                                                       25060001
W#JFCB   DS    0D                                                       25070002
         IEFJFCBN LIST=YES        JFCB area                             25080001
         DC    (((((*-W#)/256)+1)*256)-(*-W#))X'00'                     25090001
W#LEN    EQU   *-W#                                                     25100001
*                                                                       25110001
********************************************************************    25120001
* Local DSECTs                                                     *    25130001
********************************************************************    25140001
*                                                                       25150001
*        PDS Directory layout                                           25160001
*                                                                       25170001
PDS2     DSECT ,                                                        25180001
PDS2NAME DS    CL8                Member name or alias name             25190001
PDS2TTRP DS    CL3                TTR first block of member             25200001
PDS2INDC DS    B                  Indicator byte                        25210001
PDS2ALIS EQU   X'80'              An alias                              25220001
PDS2NTTR EQU   X'60'              Number of TTRs in user data           25230001
PDS2LUSR EQU   X'1F'              Length of user data in half words     25240001
PDS2USRD DS    0C                 Start of user data                    25250001
*                                                                       25260001
*        Member table layout                                            25270001
*                                                                       25280001
TBLMDS   DSECT ,                                                        25290001
TBLMNAME DS    CL8                Member name                           25300001
TBLMCHR  DS    0XL8               MBBCCHHR of member                    25310001
TBLMM    DS    XL1                M                                     25320001
TBLMBB   DS    XL2                BB                                    25330001
TBLMCC   DS    XL2                CC                                    25340001
TBLMHH   DS    XL2                HH                                    25350001
TBLMR    DS    XL1                R                                     25360001
TBLMFLG  DS    X                  Flags                                 25370001
TBLMFLGA EQU   X'80'              Member is an alias                    25380001
TBLMENT  EQU   TBLMDS,*-TBLMDS                                          25390001
*                                                                       25400001
*        DASD buffer                                                    25410001
*                                                                       25420001
BUFDS    DSECT ,                                                        25430001
         DS    32767X                                                   25440001
BUF      EQU   BUFDS,*-BUFDS                                            25450001
*                                                                       25460001
*        Member table                                                   25470001
*                                                                       25480001
MBRTBL   DSECT ,                                                        25490001
         DS    20000XL(L'TBLMENT)                                       25500001
         DS    XL(L'TBLMENT)                                            25510001
MBRTBLN  EQU   *-MBRTBL                                                 25520001
*********************************************************************** 25530001
*********************************************************************** 25540001
** SORT                                                              ** 25550001
**    Parameters are the table address and table description         ** 25560001
**    See DSECT SRTD for description of table description            ** 25570001
*********************************************************************** 25580001
*********************************************************************** 25590001
SORT     CSECT                                                          25600001
         USING SORT,R15                                                 25610002
         B     SORTIN00           Bypass program id                     25620002
         DROP  R15                                                      25630002
         DC    AL1(L'SORTID)      Length of program id                  25640001
SORTID   DC    C'SORT - &SYSDATE &SYSTIME' Program id                   25650001
********************************************************************    25660001
* Initialization                                                   *    25670001
********************************************************************    25680001
SORTIN00 DS    0H                                                       25690001
         STM   R14,R12,12(R13)    Save calling pgm's registers          25700001
         LR    R12,R15            Copy entry address to base            25710001
         USING SORT,R12                                                 25720001
         LR    R2,R1              Parameters address                    25730001
         USING PRMS,R2                                                  25740001
         LA    R0,WRKLENG         Get length of work area               25750002
         LR    R3,R13             Save callers save area address        25760001
         GETMAIN R,LV=(0)         Get work area                         25770002
         LR    R13,R1             Work area address                     25780001
         USING WRK,R13            Address work area                     25790001
         LR    R14,R13            Copy work area address                25800001
         LA    R15,WRKLENG        Get length of work area               25810002
         LA    R1,0               Clear length                          25820002
         MVCL  R14,R0             Clear work area                       25830001
         ST    R3,4(,R13)         Chain callers save area               25840001
         ST    R13,8(,R3)         Chain my save area                    25850001
         LM    R3,R4,PRMTBLA      Table address/SORT parameters         25860001
         DROP  R2                                                       25870001
         USING SRTD,R4                                                  25880001
         LH    R9,SRTDNENT        pass back sorted entries              25890002
         LH    R1,SRTDENTL        Get entry length                      25900002
         LTR   R1,R1              Is length zero?                       25910001
         BZ    SORTER01           Yes, error                            25920002
         ST    R1,WRKENTLN        Store entry length                    25930001
         SH    R1,=H'1'           Get execute length                    25940002
         ST    R1,WRKENTEX        Store entry execute length            25950001
         LH    R1,SRTDKEYD        Get key offset                        25960002
         ST    R1,WRKKEYOF        Store key offset                      25970001
         LH    R1,SRTDKEYL        Get key length                        25980002
         ST    R1,WRKKEYLN        Store key length                      25990001
         LTR   R0,R1              Copy key length                       26000001
         BZ    SORTER02           If key length zero                    26010002
         SH    R0,=H'1'           Get execute length                    26020002
         ST    R0,WRKKEYEX        Store key execute length              26030001
         A     R1,WRKKEYOF        End of key offset                     26040001
         C     R1,WRKENTLN        Key extend beyond entry length        26050001
         BH    SORTER03           Yes, error                            26060002
         LH    R1,SRTDNENT                                              26070002
         LTR   R1,R1              Is number of entries zero             26080001
         BZ    SORTER04           Yes, error                            26090002
         ST    R1,WRKRECNO        Number of entries                     26100001
         XR    R0,R0              Clear                                 26110001
         L     R1,WRKRECNO        Number of entries                     26120001
         D     R0,=F'9'           Interval index                        26130001
         ST    R1,WRKINTIX        Save interval index                   26140001
         LA    R0,1               Start high interval with 1            26150002
         DROP  R4                                                       26160001
SORTIN20 DS    0H                                                       26170001
         ST    R0,WRKHIINT        Store high interval                   26180001
         CR    R0,R1              Do we have highest interval           26190001
         BH    SORT0100           Yes                                   26200002
         MH    R0,=H'3'           Multiply by 3                         26210002
         AH    R0,=H'1'           And add 1                             26220002
         B     SORTIN20                                                 26230002
********************************************************************    26240001
* SORT                                                             *    26250001
********************************************************************    26260001
SORT0100 DS    0H                                                       26270001
         ICM   R1,15,WRKHIINT     Get high interval                     26280001
         BNP   SORTXT10           Done if greater than zero             26290002
         AH    R1,=H'1'           Add one                               26300002
         ST    R1,WRKIIX          Save I                                26310001
SORT0200 DS    0H                                                       26320001
         CLC   WRKIIX,WRKRECNO    Is I > number of records              26330001
         BH    SORT0500           Yes, redo interval                    26340002
         L     R15,WRKENTEX       Entry length                          26350001
         LR    R7,R3              Table start address                   26360001
         M     R0,WRKENTLN        Multiply by entry length              26370001
         S     R1,WRKENTLN        Relative to zero                      26380001
         AR    R7,R1              Entry address                         26390001
         EX    R15,SORTMOV1       Copy to temp entry 1                  26400002
         MVC   WRKJIX,WRKIIX      J = I                                 26410001
         L     R1,WRKJIX          Load replace index                    26420001
         S     R1,WRKHIINT        Subtract interval                     26430001
         ST    R1,WRKKIX          Save K index                          26440001
SORT0300 DS    0H                                                       26450001
         CLC   WRKJIX,WRKHIINT    Is J > high interval                  26460001
         BNH   SORT0400           No, end                               26470002
         LR    R7,R3              Table address                         26480001
         L     R1,WRKKIX          I index                               26490001
         M     R0,WRKENTLN        Multiply I by entry length            26500001
         S     R1,WRKENTLN        Relative to zero                      26510001
         AR    R7,R1              Entry address                         26520001
         LA    R11,WRKTEMP1       Address of temp entry 1               26530001
         L     R15,WRKENTEX       Execute entry length                  26540001
         EX    R15,SORTMOV3       Move temp entry 1 to temp entry 3     26550002
         LA    R11,WRKTEMP3       Point to temp entry 3                 26560001
         A     R11,WRKKEYOF       Get key address                       26570001
         LR    R6,R7              Entry key address                     26580001
         EX    R15,SORTMOV2       Copy to temp entry 2                  26590002
         LA    R6,WRKTEMP2        Point to temp entry 2                 26600001
         A     R6,WRKKEYOF        Get key address                       26610001
         L     R15,WRKKEYLN       Key execute length                    26620001
         EX    R15,SORTASC        Compare temp entry 1/temp entry 2     26630002
         BNH   SORT0400           If not higher done                    26640002
         LR    R7,R3              Table address                         26650001
         L     R1,WRKJIX          Replace index                         26660001
         M     R0,WRKENTLN        Multiply by entry length              26670001
         S     R1,WRKENTLN        Relative to zero                      26680001
         AR    R7,R1              Entry address                         26690001
         LR    R8,R3              Table address                         26700001
         L     R1,WRKKIX          Replace index                         26710001
         M     R0,WRKENTLN        Multiply by entry length              26720001
         S     R1,WRKENTLN        Relative to zero                      26730001
         AR    R8,R1              Entry address                         26740001
         L     R15,WRKENTEX       Record execute length                 26750001
         EX    R15,SORTMOVS       Swap records                          26760002
         L     R1,WRKJIX          Get J index                           26770001
         S     R1,WRKHIINT        Less high interval                    26780001
         ST    R1,WRKJIX          Save J index                          26790001
         L     R1,WRKJIX          Load up J index                       26800001
         S     R1,WRKHIINT        Less high interval                    26810001
         ST    R1,WRKKIX          Save it                               26820001
         B     SORT0300                                                 26830002
SORT0400 DS    0H                                                       26840001
         LR    R7,R3              Table address                         26850001
         L     R1,WRKJIX          Replace index                         26860001
         M     R0,WRKENTLN        Multiply by entry length              26870001
         S     R1,WRKENTLN        Relative to zero                      26880001
         AR    R7,R1              Entry address                         26890001
         L     R15,WRKENTEX       Record execute length                 26900001
         EX    R15,SORTMOVB       Copy to temp record                   26910002
         L     R1,WRKIIX          Get high index                        26920001
         AH    R1,=H'1'           Add one                               26930002
         ST    R1,WRKIIX          Save high index                       26940001
         B     SORT0200           Loop round                            26950002
SORT0500 DS    0H                                                       26960001
         L     R1,WRKHIINT        Get the high interval                 26970001
         XR    R0,R0              Clear for divide                      26980001
         D     R0,=F'3'           Divide by three                       26990001
         ST    R1,WRKHIINT        Save high interval                    27000001
         B     SORT0100                                                 27010002
********************************************************************    27020001
* Exit                                                             *    27030001
********************************************************************    27040001
SORTER01 DS    0H                                                       27050001
         LA    R3,1               Entry length zero                     27060002
         B     SORTER             Exit with error                       27070002
SORTER02 DS    0H                                                       27080001
         LA    R3,2               Key length zero                       27090002
         B     SORTER             Exit with error                       27100002
SORTER03 DS    0H                                                       27110001
         LA    R3,3               Key end beyond record end             27120002
         B     SORTER             Exit with error                       27130002
SORTER04 DS    0H                                                       27140001
         LA    R3,4               Number of entries zero                27150002
         B     SORTER             Exit with error                       27160002
SORTER   DS    0H                                                       27170001
         LA    R2,8               Set rc to 8                           27180002
         B     SORTXT20           Exit with error                       27190002
SORTXT10 DS    0H                                                       27200001
         LA    R3,0               Zero reason code                      27210002
         LA    R2,0               Set rc to 0                           27220002
SORTXT20 DS    0H                                                       27230001
         LA    R0,WRKLENG         Get length of work area               27240002
         LR    R1,R13             Work area address                     27250001
         L     R13,4(,R13)        Restore callers R13                   27260001
         FREEMAIN R,LV=(0),A=(1)                                        27270002
         L     R14,12(,R13)       Restore R14                           27280001
         LR    R15,R2             Set rc                                27290001
         LR    R1,R3              Reason code                           27300001
         LR    R0,R9              Instruction count if enabled          27310001
         LM    R2,R12,28(R13)     Restore rest of registers             27320001
         BR    R14                Exit                                  27330001
*                                                                       27340001
SORTASC  CLC   0(,R6),0(R11)      Executed compare                      27350001
SORTMOV1 MVC   WRKTEMP1(0),0(R7)  Executed move                         27360001
SORTMOV2 MVC   WRKTEMP2(0),0(R6)  Executed move                         27370001
SORTMOV3 MVC   WRKTEMP3(0),0(R11) Executed move                         27380001
SORTMOVB MVC   0(,R7),WRKTEMP1    Executed move                         27390001
SORTMOVS MVC   0(,R7),0(R8)       Executed move                         27400001
*                                                                       27410001
         DC    (((((*-SORT)/32)+1)*32)-(*-SORT))X'00'                   27420002
*                                                                       27430001
********************************************************************    27440001
* Constants                                                        *    27450001
********************************************************************    27460001
         LTORG ,                                                        27470001
         DC    (((((*-SORT)/256)+1)*256)-(*-SORT))X'00'                 27480002
*                                                                       27490001
********************************************************************    27500001
* Work Areas                                                       *    27510001
********************************************************************    27520001
WRK      DSECT ,                                                        27530001
         DS    18A                Save area                             27540001
WRKRECNO DS    F                  Entries in table                      27550001
WRKENTLN DS    F                  Entry length                          27560001
WRKENTEX DS    F                  Entry execute length                  27570001
WRKKEYOF DS    F                  Key offset                            27580001
WRKKEYLN DS    F                  Key length                            27590001
WRKKEYEX DS    F                  Key execute length                    27600001
WRKHIINT DS    F                  High Interval Number                  27610001
WRKINTIX DS    F                  Number of records / 9                 27620001
WRKIIX   DS    F                  Current index                         27630001
WRKJIX   DS    F                  Adjust index                          27640001
WRKKIX   DS    F                  Temp index                            27650001
WRKTEMP1 DS    CL255              Temporary entry 1                     27660001
WRKTEMP2 DS    CL255              Temporary entry 2                     27670001
WRKTEMP3 DS    CL255              Temporary entry 3                     27680001
*                                                                       27690001
         DS    (((((*-WRK)/256)+1)*256)-(*-WRK))X                       27700001
WRKLENG  EQU   *-WRK                                                    27710001
*                                                                       27720001
********************************************************************    27730001
* Parameters                                                       *    27740001
********************************************************************    27750001
PRMS     DSECT ,                                                        27760001
PRMTBLA  DS    F                  Address of table                      27770001
PRMSRT   DS    F                  Address of SORT parameters            27780001
*                                                                       27790001
********************************************************************    27800001
* Sort Parms                                                       *    27810001
********************************************************************    27820001
SRTDSECT DSECT ,                                                        27830001
SRTDNENT DS    H                  Number of entries                     27840001
SRTDENTL DS    H                  Length of an entry                    27850001
SRTDKEYL DS    H                  Length of the key                     27860001
SRTDKEYD DS    H                  Displacement of key                   27870001
SRTD     EQU   SRTDSECT,*-SRTDSECT                                      27880001
********************************************************************    27890001
* Equates                                                          *    27900001
********************************************************************    27910001
R0       EQU   0                                                        27920001
R1       EQU   1                                                        27930001
R2       EQU   2                                                        27940001
R3       EQU   3                                                        27950001
R4       EQU   4                                                        27960001
R5       EQU   5                                                        27970001
R6       EQU   6                                                        27980001
R7       EQU   7                                                        27990001
R8       EQU   8                                                        28000001
R9       EQU   9                                                        28010001
R10      EQU   10                                                       28020001
R11      EQU   11                                                       28030001
R12      EQU   12                                                       28040001
R13      EQU   13                                                       28050001
R14      EQU   14                                                       28060001
R15      EQU   15                                                       28070001
         END   STATS                                                    28080001
