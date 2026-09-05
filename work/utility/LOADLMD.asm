*********************************************************************** 00010000
*                                                                     * 00020000
* MODULE NAME                                                         * 00030000
*    LOADLMD                                                          * 00040000
*                                                                     * 00050000
* ATTRIBUTES                                                          * 00060000
*    RENT                                                             * 00070000
*                                                                     * 00080000
* AUTHOR                                                              * 00090000
*    DAVE KREISS                                                      * 00100000
*                                                                     * 00110000
* FUNCTION                                                            * 00120000
*    LOADS A CSECT FROM A LOAD MODULE INTO MEMORY.  RELOCATABLE       * 00130000
*    CONSTANTS ARE NOT RELOCATED.  OPTIONALLY RELOCATABLE CONSTANTS   * 00140000
*    CAN BE ZEROED.  THIS PREVENTS RELOCATABLE CONSTANTS WHICH        * 00150000
*    RESOLVE TO DIFFERENT ADDRESS DUE TO DIFFERENCES IN CSECT         * 00160000
*    LENGTHS FROM PRODUCING PSEUDO DIFFERENCES.                       * 00170000
*                                                                     * 00180000
*    IT CAN BE EXECUTED VIA JCL BUT IT'S REAL PURPOSE IS IN           * 00190000
*    COMPARING CSECTS.                                                * 00200000
*                                                                     * 00210000
*    THIS CODE IS A DERIVITIVE FROM THE DISASSEMBLER ON THE CBT       * 00220000
*    TAPE WEB SITE FILE 217.  THE ORIGINAL AUTHOR WAS R THORNTON.     * 00230000
*                                                                     * 00240000
* JCL                                                                 * 00250000
*    //        EXEC PGM=LOADLMD,PARM='parameters'                     * 00260000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00270000
*    //PRINTDD  DD  SYSOUT=*                                          * 00280000
*    //xxxxxxxx DD  DSN=load library,DISP=SHR                         * 00290000
*                                                                     * 00300000
* DD STATEMENTS                                                       * 00310000
*    STEPLIB       LOAD LIBRARY CONTAINING THE MODULE LOADLMD.        * 00320000
*    PRINTDD       DATA SET CONTAINING EITHER SUMMARY OR DETAIL       * 00330000
*                  INFORMATION.  SEE PARM=OPTION BELOW.               * 00340000
*                  THIS DD IS OPTIONAL.                               * 00350000
*    xxxxxxxx      DATA SET CONTAINING THE LOAD MODULE WHOSE          * 00360000
*                  CSECT IS TO BE LOADED.  xxxxxxxx IS ANY NAME       * 00370000
*                  AS SPECIFIED IN LIB=.  THE DEFAULT IS SYSLIB.      * 00380000
*                                                                     * 00390000
* PARAMETERS                                                          * 00400000
*    ALL PARAMETERS ARE SEPERATED BY COMMAS.                          * 00410000
*    1ST PARAMETER LOAD MODULE NAME                                   * 00420000
*    2ND PARAMETER CSECT NAME                                         * 00430000
*    LIB=xxxxxxxx  DD FOR DATA SET CONTAINING THE LOAD MODULE         * 00440000
*                  THE DEFAULT DD NAME IS SYSLIB.                     * 00450000
*    OPTION=       OPTION CAN BE DETAIL OR SUMMARY.                   * 00460000
*      DETAIL      GIVES DETAIL INFO ABOUT LOAD MODULE AND CSECT.     * 00470000
*                  THIS IS DEFAULT IF NO OPTION.                      * 00480000
*      SUMMARY     SUMMARY ONLY INFO ABOUT CSECT AND LOAD MODULE.     * 00490000
*      DEBUG       Debug info (dump control records).                 * 00500008
*    CLEARRLD=     CLEAR RELOCATABLE CONSTANTS OPTION                 * 00510000
*      YES         YES WILL CLEAR ALL RELOCATABLE CONSTANTS.          * 00520000
*                  USEFUL WHEN LOAD MODULES WITH MULTIPLE CSECTS      * 00530000
*                  CONTAIN CSECTS WHICH ARE DIFFERENT IN LENGTH.      * 00540000
*      NO          NO WILL LEAVE RELOCATABLE CONSTANTS AS IS.         * 00550000
*                  THIS IS DEFAULT IF NO CLEARRLD IS SPECIFIED.       * 00560000
*                                                                     * 00570000
* RETURNED INFORMATION                                                * 00580000
*    RETURN CODE                                                      * 00590000
*       0 = SUCCESSFULLY LOADED MODULE.  SEE R1 BELOW.                * 00600000
*       8 = PARAMETER ERROR.  SEE PRINTDD FOR ERROR MESSAGE.          * 00610000
*           TABLE OVERFLOW.  SEE PRINTDD FOR ERROR MESSAGE.           * 00620000
*       16 = LIB= DD STATMENT OPEN FAILED.                            * 00630000
*    R0 CONTAINS OFFSET OF CSECT IN LOAD MODULE IF RETURN CODE = 0    * 00640007
*    R1 CONTAINS ADDRESS OF MODULE BUFFER IF RETURN CODE = 0          * 00650007
*       IF RETURN CODE NOT ZERO R1 WILL BE ZERO.                      * 00660000
*       WORD 1 = LENGTH OF THE MODULE BUFFER                          * 00670000
*       WORD 2 = LENGTH OF THE MODULE                                 * 00680000
*       R1 +8  = BEGINNING OF MODULE                                  * 00690000
*                                                                     * 00700000
* NOTES:                                                              * 00710000
*    IF CALLED FROM A PROGRAM THE PARAMETERS PASSED MUST BE IDENTICAL * 00720000
*       TO THE PARAMETERS PASSED VIA EXEC PGM=                        * 00730000
*    IT IS THE RESPONSIBILITY OF CALLER TO FREE THE MODULE BUFFER     * 00740000
*       STORAGE USING THE LENGTH AT BUFFER +0.                        * 00750000
*                                                                     * 00760000
* SAMPLE JCL                                                          * 00770000
*    THIS SAMPLE LOADS INTO MEMORY THE CSECT ESRTABLE LOCATED IN      * 00780000
*    IEANUC01 FROM DDNAME NUC.  SUMMARY INFORMATION IS PRINTED        * 00790000
*    ON THE PRINTDD DD STATEMENT.                                     * 00800000
*    //LOAD    EXEC PGM=LOADLMD,PARM=('IEANUC01,ESRTABLE',            * 00810000
*    //             'LIB=NUC,OPTION=SUMMARY,CLEARRLD=YES')            * 00820000
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00830000
*    //PRINTDD  DD  SYSOUT=*                                          * 00840000
*    //NUC      DD  DSN=SYS1.NUCLEUS,DISP=SHR                         * 00850000
*                                                                     * 00860000
* SAMPLE OUTPUT TO PRINTDD                                            * 00870000
*    Program version=LOADLMD - 01.03 12/08/15 21.23                   * 00880002
*    LMOD=IEANUC01 CSECT=ESRTABLE LIB=NUC OPTION=SUMMARY CLEARRLD=YES * 00890000
*    LIB DSN=SYS1.NUCLEUS                                             * 00900002
*    Directory info for module IEANUC01                               * 00910000
*              TTR of module=002223                                   * 00920000
*              Concatenation=00                                       * 00930000
*              Alias indicator=52                                     * 00940000
*              TTR of 1st TXT record=002431                           * 00950000
*              TTR of NOTE/Scatter list=00242C                        * 00960000
*              Number NOTE entries=00                                 * 00970000
*              Attributes #1=06C2 SCTR EXEC                           * 00980000
*              Total length=083588                                    * 00990000
*              Length of 1st TXT record=17C8                          * 01000000
*              EPA=004FC0                                             * 01010000
*              Attributes #2=9800 SSI APF                             * 01020000
*              SCTR length=04E8                                       * 01030000
*              Translate table length=08DC                            * 01040000
*              ESD ID of 1st TXT=001A                                 * 01050000
*              ESD ID containing EPA=0059                             * 01060000
*              SSI info=60700187                                      * 01070000
*              Auth code=00                                           * 01080000
*                                                                     * 01090000
*********************************************************************** 01100000
*                                                                     * 01110000
* CHANGE LOG:                                                         * 01120000
*   DATE     AAA VV.VV DESCRIPTION                                    * 01130000
* 06/06/2015 DSK 01.01 CREATED                                        * 01140000
* 07/10/2015 DSK 01.02 CLEAR RELOCATABLE CONSTANTS                    * 01150001
* 12/08/2015 DSK 01.03 ADD LOAD LIBRARY DATA SET NAME                 * 01160002
* 01/04/2016 DSK 01.04 Handle empty load module, add error code in R1 * 01170003
* 07/09/2017 DSK 01.05 Clear V type labels for CLEARRLD=YES           * 01180005
* 05/17/2019 DSK 01.06 PAGEALG DD causes page aligned LOADs           * 01190006
* 12/20/2019 DSK 01.07 Pass back module offset in R0                  * 01200007
* 11/11/2020 DSK 01.08 Debug option to assist in debugging            * 01210008
         LCLC   &VER                                                    01220000
&VER     SETC   '01.08'                                                 01230008
*                                                                     * 01240000
*********************************************************************** 01250000
LOADLMD  CSECT ,                                                        01260000
****************************************************************        01270000
*                                                              *        01280000
*   PROGRAM INITIALIZATION                                     *        01290000
*                                                              *        01300000
****************************************************************        01310000
         USING LOADLMD,R15                                              01320000
         B     BEGIN                   BYPASS PROGRAM ID                01330000
         DROP  R15                                                      01340000
         DC    AL1(L'PGMID)            PROGRAM ID LENGTH                01350000
PGMID    DC    C'LOADLMD - &VER &SYSDATE &SYSTIME'                      01360000
BEGIN    DC    0H'+0'                                                   01370000
         USING LOADLMD,R3,R4                                            01380000
         STM   R14,R12,12(R13)         STORE REGS IN HIGH SAVE AREA     01390000
         LR    R12,R1                  PARAMETERS ADDRESS               01400000
         LR    R3,R15                  INITIALIZE BASE REG              01410000
         LA    R4,4095(,R3)            INITIALIZE THE SECOND            01420000
         LA    R4,1(,R4)               BASE REGISTER                    01430000
****************************************************************        01440000
*                                                              *        01450000
*        INITIALIZE WORK AREA                                  *        01460000
*                                                              *        01470000
****************************************************************        01480000
         GETMAIN R,LV=WORKLEN          GET WORK AREA                    01490000
         LR    R9,R1                   SAVE WORK AREA ADDRESS           01500000
         LR    R14,R1                  SET UP                           01510000
         LA    R15,WORKLEN              UP                              01520000
         SR    R1,R1                     MVCL                           01530000
         MVCL  R14,R0                  CLEAR WORK AREA                  01540000
         ST    R9,8(,R13)              STORE LOW SAVE POINTER           01550000
         ST    R13,4(,R9)              STORE HIGH SAVE POINTER          01560000
         LR    R13,R9                  INITIALIZE SAVE POINTER          01570000
         USING WORKAREA,R13                                             01580000
         MVC   CSECT,BLANX             * INITIALIZE                     01590000
         MVC   MEMBER,BLANX            * WORKAREA                       01600000
         MVC   ESDID,=X'0001'          * FIELDS                         01610000
         ZAP   LINECT,=P'+0'           *                                01620000
         MVI   PCC,C'1'                *                                01630000
         MVC   PRT,BLANX               *                                01640000
         MVC   BLDLNO,=H'1'            *                                01650000
         MVC   BLDLLEN,=H'58'          *                                01660000
         MVC   ENDSYM,=F'95000'        *                                01670000
         MVC   ENDRLD,=F'60000'        *                                01680000
         MVC   ENDATO,=F'1536'         *                                01690000
         MVC   SYMLEN,=AL2(L'SYMENT)   *                                01700000
         MVC   LIBDDN,=CL8'SYSLIB'     *                                01710000
         MVC   PRINTDCB,PRINTMDL       *                                01720000
         MVC   LIBDCB,LIBMDL           *                                01730000
         LA    R0,LIBJFCB              *                             03 01740002
         ST    R0,LIBEXLST             *                             03 01750002
         MVI   LIBEXLST,128+7          *                             03 01760002
         LA    R1,SYSLIB               *                             03 01770002
         USING IHADCB,R1               *                             03 01780002
         LA    R0,LIBEXLST             *                             03 01790002
         STCM  R0,7,DCBEXLSA           *                             03 01800002
         DROP  R1                      *                             03 01810002
         MVC   OPNLST,OPNMDL           *                                01820000
         ZAP   W#RECCT,=P'+0'          *                             08 01830008
****************************************************************        01840000
*                                                              *        01850000
*        OPEN PRINT FILE                                       *        01860000
*                                                              *        01870000
****************************************************************        01880000
         DEVTYPE =CL8'PRINTDD',DEVTYPE DETECT IF PRINTDD IS PRESENT     01890000
         LTR   R15,R15                 IS PRINTDD PRESENT?              01900000
         BNZ   SKPOPN                  NO, SKIP OPEN                    01910000
         OPEN  (PRINTDD,(OUTPUT)),MF=(E,OPENLIST) OPEN PRINTDD          01920000
         MVC   PRT(16),=C'Program version=' SETUP PRINT              03 01930002
         MVC   PRT+16(L'PGMID),PGMID   TO PRINT PROGRAM VERSION      03 01940002
         BAL   R9,PRINT                PRINT                         03 01950002
SKPOPN   DS    0H                                                       01960000
****************************************************************        01970000
*                                                              *        01980000
*        PROCESS THE PARM CONTAINING MODULE NAME AND CSECT     *        01990000
*                                                              *        02000000
****************************************************************        02010000
         L     R1,0(,R12)              GET PARM FIELD ADDRESS           02020000
         SR    R12,R12                 CLEAR LENGTH                     02030000
         ICM   R12,3,0(R1)             PICK UP PARM LENGTH              02040000
         BZ    PREND                   NO PARM INFO ENTERED             02050000
         LA    R1,2(,R1)               PARM DATA                        02060000
         ST    R1,PRMSTRT              SAVE START OF PARAMETERS         02070000
PRMSCN   DS    0H                                                       02080000
         LA    R11,8                   MAX LENGTH OF MEMBER NAME        02090000
         LA    R10,MEMBER              MEMBER NAME FIELD ADDRESS        02100000
PRMEMOV  DS    0H                                                       02110000
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO MEMBER NAME      02120000
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             02130000
         BCTR  R12,0                   SUBTRACT 1 FROM LENGTH           02140000
         LA    R10,1(,R10)             TO NEXT NAME BYTE                02150000
         BCTR  R11,0                   SUBTRACT 1 FROM LENGTH           02160000
         CLI   0(R1),C','              GOT A COMMA                      02170000
         BE    PRSETUP2                YES                              02180000
         LTR   R12,R12                 END OF CONTROL DATA              02190000
         BE    PREND                   YES                              02200000
         LTR   R11,R11                 NAME FULL                        02210000
         BNZ   PRMEMOV                 NO, CONTINUE                     02220000
         B     PRMERR                  YES, NAME TOO LONG               02230000
PRSETUP2 DS    0H                                                       02240000
         LA    R11,8                   CSECT NAME MAX LENGTH            02250000
         LA    R10,CSECT               CSECT NAME FIELD ADDRESS         02260000
PRSTEP2  DS    0H                                                       02270000
         LA    R1,1(,R1)               STEP PAST COMMA                  02280000
         BCT   R12,PRHKBK2             CHECK NEXT FOR COMMA             02290000
         B     PREND                   END OF SCAN                      02300000
PRHKBK2  DS    0H                                                       02310000
         CLI   0(R1),C','              CONTROL DATA IS BLANK            02320000
         BE    PRSTEP2                 YES                              02330000
         CH    R12,=H'+5'              LENGTH LEFT LONG ENOUGH FOR PARM 02340000
         BL    PRCSMOV                 NO, TREAT AS CSECT NAME          02350000
         CLC   =C'LIB=',0(R1)          PARM LIB KEYWORD                 02360000
         BE    PRLIB                   YES, CSECT NOT SPECIFIED         02370000
         CH    R12,=H'+8'              LENGTH LEFT LONG ENOUGH FOR PARM 02380000
         BL    PRCSMOV                 NO, TREAT AS CSECT NAME          02390000
         CLC   =C'OPTION=',0(R1)       PARM OPTION KEYWORD              02400000
         BE    PROPT                   YES, CSECT NOT SPECIFIED         02410000
         CH    R12,=H'+10'             LEN LEFT LONG ENOUGH FOR PARM 02 02420001
         BL    PRMERR                  NO, PARAMETER ERROR           02 02430001
         CLC   =C'CLEARRLD=',0(R1)     PARM CLEARRLD KEYWORD         02 02440001
         BE    PRCLR                   YES, CSECT NOT SPECIFIED      02 02450001
PRCSMOV  DS    0H                                                       02460000
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO CSECT NAME       02470000
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             02480000
         LA    R10,1(,R10)             TO NEXT NAME BYTE                02490000
         BCTR  R12,0                   DEDUCT 1 FROM CONTROL LENGTH     02500000
         BCTR  R11,0                   DEDUCT 1 FROM NAME LENGTH        02510000
         LTR   R12,R12                 ANY CONTROL BYTES LEFT           02520000
         BZ    PREND                   NO                               02530000
         CLI   0(R1),C','              NEXT CONTROL BYTE BLANK          02540000
         BE    PRMORPRM                YES                              02550000
         LTR   R11,R11                 ANY NAME BYTES LEFT              02560000
         BNZ   PRCSMOV                 YES, LOOP                        02570000
         B     PRMERR                  NAME TOO LONG, ERROR             02580000
PRMORPRM DS    0H                                                       02590000
         LTR   R12,R12                 ANY MORE PARM LEFT TO PARSE      02600000
         BZ    PREND                   NO, WE ARE DONE WITH PARM        02610000
         CLI   0(R1),C','              SEPERATOR                        02620000
         BNE   PRKEYWD                 NO, CHECK FOR A KEYWORD          02630000
         LA    R1,1(,R1)               SKIP COMMA                       02640000
         BCTR  R12,0                   INCLUDE COMMA PARSED             02650000
         B     PRMORPRM                LOOK FOR MORE PARM KEYWORDS      02660000
PRKEYWD  DS    0H                                                       02670000
         CH    R12,=H'+5'              LENGTH LEFT LONG ENOUGH FOR PARM 02680000
         BL    PRMERR                  NO, PARAMETER ERROR              02690000
         CLC   =C'LIB=',0(R1)          PARM LIB KEYWORD                 02700000
         BE    PRLIB                   YES, HANDLE LIB VALUE            02710000
         CH    R12,=H'+8'              LENGTH LEFT LONG ENOUGH FOR PARM 02720000
         BL    PRMERR                  NO, PARAMETER ERROR              02730000
         CLC   =C'OPTION=',0(R1)       PARM OPTION KEYWORD              02740000
         BE    PROPT                   YES, HANDLE OPTION KEYWORD       02750000
         CH    R12,=H'+10'             LEN LEFT LONG ENOUGH FOR PARM 02 02760001
         BL    PRMERR                  NO, PARAMETER ERROR           02 02770001
         CLC   =C'CLEARRLD=',0(R1)     PARM CLEARRLD KEYWORD         02 02780001
         BE    PRCLR                   YES, CSECT NOT SPECIFIED      02 02790001
         B     PRMERR                  UNKNOWN KEYWORD, PARAMETER ERROR 02800000
PRLIB    DS    0H                                                       02810000
         LA    R1,4(,R1)               SKIP LIB=                        02820000
         SH    R12,=H'+4'              INCLUDE IN LENGTH PARSED         02830000
         MVC   LIBDDN,BLANX            CLEAR CSECT NAME                 02840000
         LA    R11,8                   CSECT NAME MAX LENGTH            02850000
         LA    R10,LIBDDN              LIB DDNAME                       02860000
PRLIBMOV DS    0H                                                       02870000
         MVC   0(1,R10),0(R1)          CONTROL BYTE TO DDNAME           02880000
         LA    R1,1(,R1)               TO NEXT CONTROL BYTE             02890000
         LA    R10,1(,R10)             TO NEXT NAME BYTE                02900000
         BCTR  R12,0                   DEDUCT 1 FROM CONTROL LENGTH     02910000
         BCTR  R11,0                   DEDUCT 1 FROM NAME LENGTH        02920000
         LTR   R12,R12                 ANY CONTROL BYTES LEFT           02930000
         BZ    PREND                   NO                               02940000
         CLI   0(R1),C','              NEXT CONTROL COMMA               02950000
         BE    PRMORPRM                YES                              02960000
         LTR   R11,R11                 ANY NAME BYTES LEFT              02970000
         BNZ   PRLIBMOV                YES, LOOP                        02980000
         B     PRMERR                  NAME TOO LONG, ERROR             02990000
PROPT    DS    0H                                                       03000000
         LA    R1,7(,R1)               SKIP OPTION=                     03010000
         SH    R12,=H'+7'              INCLUDE IN LENGTH PARSED         03020000
         BZ    PROPTDT1                NULL OPTION= SET DETAIL          03030000
         CLI   0(R1),C','              IS OPTION= NULL                  03040000
         BE    PROPTDT1                YES, SET DETAIL                  03050000
         CH    R12,=H'+5'              Enough left for DEBUG         08 03060008
         BL    PRMERR                  NO, PARAMETER ERROR           08 03070008
         CLC   =C'DEBUG',0(R1)         DEBUG option                  08 03080008
         BE    PROPTDBG                Yes, set DEBUG                08 03090008
         CH    R12,=H'+6'              ENOUGH LEFT FOR DETAIL           03100000
         BL    PRMERR                  NO, PARAMETER ERROR              03110000
         CLC   =C'DETAIL',0(R1)        KEYWORD VALUE DETAIL             03120000
         BE    PROPTDTL                YES, SET DETAIL                  03130000
         CH    R12,=H'+7'              ENOUGH LEFT FOR SUMMARY          03140000
         BL    PRMERR                  NO, PARAMETER ERROR              03150000
         CLC   =C'SUMMARY',0(R1)       KEYWORD VALUE SUMMARY            03160000
         BE    PROPTSUM                YES, SET SUMMARY                 03170000
         B     PRMERR                  UNKNOWN KEYWORD VALUE, PARM ERR  03180000
PROPTSUM DS    0H                                                       03190000
         LA    R1,7(,R1)               SKIP DETAIL                      03200000
         SH    R12,=H'+7'              INCLUDE IN LENGTH PARSED         03210000
         OI    PRMOPT,PRMOPTSU         SET SUMMARY FLAG                 03220000
         B     PRMORPRM                LOOK FOR MORE KEYWORDS           03230000
PROPTDBG DS    0H                                                    08 03240008
         LA    R1,5(,R1)               Skip DEBUG                    08 03250008
         SH    R12,=H'+5'              Include in length parsed      08 03260008
         OI    PRMOPT,PRMOPTDB         Set DEBUG                     08 03270008
         B     PRMORPRM                Look for more keywords        08 03280008
PROPTDTL DS    0H                                                       03290000
         LA    R1,6(,R1)               SKIP SUMMARY                     03300000
         SH    R12,=H'+6'              INCLUDE IN LENGTH PARSED         03310000
PROPTDT1 DS    0H                                                       03320000
         NI    PRMOPT,255-PRMOPTSU     CLEAR SUMMARY FLAG               03330000
         B     PRMORPRM                LOOK FOR MORE KEYWORDS           03340000
PRCLR    DS    0H                                                    02 03350001
         LA    R1,9(,R1)               SKIP CLEARRLD=                02 03360001
         SH    R12,=H'+9'              INCLUDE IN LENGTH PARSED      02 03370001
         BZ    PRCLRNO1                NULL CLEARRLD= SET NO         02 03380001
         CLI   0(R1),C','              IS CLEARRLD= NULL             02 03390001
         BE    PRCLRNO1                YES, SET NO                   02 03400001
         CH    R12,=H'+2'              ENOUGH LEFT FOR NO            02 03410001
         BL    PRMERR                  NO, PARAMETER ERROR           02 03420001
         CLC   =C'NO',0(R1)            KEYWORD VALUE NO              02 03430001
         BE    PRCLRNO                 YES, SET DETAIL               02 03440001
         CH    R12,=H'+3'              ENOUGH LEFT FOR NO            02 03450001
         BL    PRMERR                  NO, PARAMETER ERROR           02 03460001
         CLC   =C'YES',0(R1)           KEYWORD VALUE YES             02 03470001
         BE    PRCLRYES                YES, SET YES                  02 03480001
         B     PRMERR                  UNKNOWN KEYWORD VALUE, ERROR  02 03490001
PRCLRYES DS    0H                                                    02 03500001
         LA    R1,3(,R1)               SKIP YES                      02 03510001
         SH    R12,=H'+3'              INCLUDE IN LENGTH PARSED      02 03520001
         OI    PRMOPT,PRMOPTZR         SET ZERO RELOCATABLE ADCONS   02 03530001
         B     PRMORPRM                LOOK FOR MORE KEYWORDS        02 03540001
PRCLRNO  DS    0H                                                    02 03550001
         LA    R1,2(,R1)               SKIP NO                       02 03560001
         SH    R12,=H'+2'              INCLUDE IN LENGTH PARSED      02 03570001
PRCLRNO1 DS    0H                                                    02 03580001
         NI    PRMOPT,255-PRMOPTZR     RESET CLEAR OPTION            02 03590001
         B     PRMORPRM                LOOK FOR MORE KEYWORDS        02 03600001
PREND    DS    0H                                                       03610000
         CLC   MEMBER,BLANX            ANY MEMBER NAME FOUND            03620000
         BE    NOMBR                   NO, ERROR                        03630000
         MVC   PRT(5),=C'LMOD='        * SET                            03640000
         MVC   PRT+5(8),MEMBER         * UP                             03650000
         MVC   PRT+14(6),=C'CSECT='    * AND                            03660000
         MVC   PRT+20(8),CSECT         * PRINT                          03670000
         MVC   PRT+29(4),=C'LIB='      * OPTIONS                        03680000
         MVC   PRT+33(8),LIBDDN        * PASSED                         03690000
         MVC   PRT+42(7),=C'OPTION='   *                                03700000
         TM    PRMOPT,PRMOPTDB         *                             08 03710008
         BNO   PRPRTSUM                *                             08 03720008
         MVC   PRT+49(5),=C'DEBUG'     *                             08 03730008
         B     PRPRTZR                 *                             08 03740008
PRPRTSUM DS    0H                      *                             08 03750008
         TM    PRMOPT,PRMOPTSU         *                                03760000
         BNO   PRPRTDTL                *                                03770000
         MVC   PRT+49(7),=C'SUMMARY'   *                                03780000
         B     PRPRTZR                 *                             02 03790001
PRPRTDTL DS    0H                      *                                03800000
         MVC   PRT+49(6),=C'DETAIL'    *                             02 03810001
PRPRTZR  DS    0H                                                    02 03820001
         MVC   PRT+57(9),=C'CLEARRLD=' *                             02 03830001
         TM    PRMOPT,PRMOPTZR         *                             02 03840001
         BNO   PRPRTZRN                *                             02 03850001
         MVC   PRT+66(3),=C'YES'       *                             02 03860001
         B     PRPRTPRM                *                             02 03870001
PRPRTZRN DS    0H                      *                             02 03880001
         MVC   PRT+66(2),=C'NO'        *                             02 03890001
PRPRTPRM DS    0H                                                    02 03900001
         DEVTYPE =CL8'PAGEALG',DEVTYPE DETECT IF PAGEALG IS PRESENT  06 03910006
         LTR   R15,R15                 Is PAGEALG DD present?        06 03920006
         BNZ   PRNOPA                  No, skip                      06 03930006
         OI    PRMOPT,PRMOPTPA         Set page aligned LOAD         06 03940006
         MVC   PRT+70(9),=C'PAGEALIGN' Indicate page alignment opt   06 03950006
PRNOPA   DS    0H                                                    06 03960006
         BAL   R9,PRINT                PRINT                            03970000
****************************************************************        03980000
*                                                              *        03990000
*        OPEN LIBRARY DDNAME                                   *        04000000
*                                                              *        04010000
****************************************************************        04020000
         MVC   SYSLIB+40(8),LIBDDN     SETUP LIBRARY DCB DDNAME         04030000
         OPEN  (SYSLIB,(INPUT)),MF=(E,OPENLIST)                         04040000
         TM    SYSLIB+48,16            SYSLIB OPENED OK                 04050000
         BZ    OPENERR                 NO, EXIT                      04 04060003
         RDJFCB SYSLIB,MF=(E,OPENLIST)                               03 04070002
         LTR   R15,R15                 SYSLIB RDJFCB OK              03 04080002
         BNZ   RDJFERR                 NO, EXIT                      04 04090003
         MVC   PRT(8),=C'LIB DSN='     SETUP PRINT                   03 04100002
         LA    R1,LIBJFCB              ADDRESS JFCB                  03 04110002
         USING JFCB,R1                                               03 04120002
         MVC   PRT+8(44),JFCBDSNM      LOAD LIBRARY NAME             03 04130002
         DROP  R1                                                    03 04140002
         BAL   R9,PRINT                PRINT                         03 04150002
****************************************************************        04160000
*                                                              *        04170000
* GET STORAGE FOR THE SYMBOL TABLE AND RLD TABLE               *        04180000
*                                                              *        04190000
****************************************************************        04200000
         BAL   R9,BLDL                 ISSUE BLDL AND PRINT             04210000
         MVI   CCAT,0                  INSURE TTR0                      04220000
         POINT SYSLIB,TTRMOD           POINT TO 1ST BLOCK OF MODULE     04230000
         GETMAIN R,LV=32768            GET BUFFER STORAGE               04240000
         ST    R1,BUFAD                SAVE BUFFER ADDRESS              04250000
         GETMAIN R,LV=95000            GET SYMBOL TABLE STORAGE         04260000
         ST    R1,SYMTBAD              SAVE SYMBOL TABLE ADDRESS        04270000
         ST    R1,CURRSYM              SAVE CURRENT SYMBOL ADDR         04280000
         MVI   0(R1),X'FF'             TABLE END INDIC                  04290000
         A     R1,ENDSYM               COMPUTE END ADDR                 04300000
         ST    R1,ENDSYM               STORE TBL END ADDR               04310000
         GETMAIN R,LV=60000            GET RLD TABLE STORAGE            04320000
         ST    R1,RLDTBL               SAVE RLD TABLE ADDRESS           04330000
         ST    R1,CURRLD               SAVE CURRENT RLD ADDR            04340000
         MVI   0(R1),X'FF'             TABLE END INDIC                  04350000
         A     R1,ENDRLD               COMPUTE END ADDR                 04360000
         ST    R1,ENDRLD               STORE TBL END ADDR               04370000
         MVC   PRT(21),=C'External Symbol Table'                        04380000
         BAL   R9,PRINTSM              PRINT                            04390000
         MVC   PRT(L'SYMHDR),SYMHDR    SYM TBL HEADER                   04400000
         BAL   R9,PRINTSM              PRINT                            04410000
****************************************************************        04420000
*                                                              *        04430000
* PROCESS DIRECTORY ENTRY                                      *        04440000
*                                                              *        04450000
****************************************************************        04460000
MAINLINE DS    0H                      MAINLINE ROUTINE                 04470000
         L     R6,BUFAD                GET BUFFER ADDRESS               04480000
         LA    R9,SYSLIB               DCB ADDRESS                      04490000
         READ  DECB,SF,(R9),(6),'S',MF=E                                04500000
         CHECK DECB                    AWAIT COMPLETION                 04510000
         AP    W#RECCT,=P'+1'                                        08 04520008
         CLI   0(R6),X'20'             CESD RECORD                      04530000
         BNE   TESTOTHR                NO                               04540000
         TM    PRMOPT,PRMOPTDB         ** DEBUG on                   08 04550008
         BNO   DOCESD                   *                            08 04560008
         MVC   PRT(11),=C'CESD record'  * Dump record                08 04570008
         MVC   PRT+11(10),=X'40206B2020206B202120'                   08 04580008
         ED    PRT+11(10),W#RECCT       *                            08 04590008
         BAL   R9,PRINTSM               *                            08 04600008
         LA    R1,SYSLIB                *                            08 04610008
         USING IHADCB,R1                *                            08 04620008
         LH    R0,DCBBLKSI              *                            08 04630008
         DROP  R1                       *                            08 04640008
         L     R15,DECB+16              * Status area address        08 04650008
         SH    R0,14(,R15)              * Resiual count              08 04660008
         LR    R1,R6                    *                            08 04670008
         BAL   R14,DMP                  *                            08 04680008
DOCESD   DS    0H                      **                            08 04690008
         BAL   R9,CESDREC              PROCESS CESD RECORDS             04700000
         B     MAINLINE                GO READ AGAIN                    04710000
TESTOTHR DS    0H                                                       04720000
         LA    R1,=C'CTL    '                                        08 04730008
         LA    R9,CNTLRECS             ASSUME CONTROL RECORD            04740000
         CLI   0(R6),1                 IT IS CONTROL                    04750000
         BE    PERFORM                 YES                              04760000
         CLI   0(R6),5                 IS IT CONTROL                    04770000
         BE    PERFORM                 YES                              04780000
         CLI   0(R6),13                IS IT CONTROL                    04790000
         BE    PERFORM                 YES                              04800000
         LA    R1,=C'RLD    '                                        08 04810008
         LA    R9,RLDRECS              ASSUME RLD RECORD                04820000
         CLI   0(R6),2                 IS IT RLD                        04830000
         BE    PERFORM                 YES                              04840000
         CLI   0(R6),6                 IS IT RLD                        04850000
         BE    PERFORM                 YES                              04860000
         CLI   0(R6),14                IS IT RLD                        04870000
         BE    PERFORM                 YES                              04880000
         LA    R1,=C'CTL/RLD'                                        08 04890008
         LA    R9,CTRLRECS             ASSUME CONTROL AND RLD           04900000
         CLI   0(R6),3                 IS IT CTL AND RLD                04910000
         BE    PERFORM                 YES                              04920000
         CLI   0(R6),7                 IS IT CTL AND RLD                04930000
         BE    PERFORM                 YES                              04940000
         CLI   0(R6),15                IS IT CTL AND RLD                04950000
         BE    PERFORM                 YES                              04960000
         B     MAINLINE                NONE OF THESE, SKIP              04970000
PERFORM  DS    0H                                                       04980000
         TM    PRMOPT,PRMOPTDB         ** DEBUG on                   08 04990008
         BNO   DMPCTL90                 *                            08 05000008
         ST    R9,W#SAVER9              * Dump record                08 05010008
         MVC   PRT(7),0(R1)             *                            08 05020008
         MVC   PRT+9(6),=C'record'      *                            08 05030008
         MVC   PRT+15(10),=X'40206B2020206B202120'                   08 05040008
         ED    PRT+15(10),W#RECCT       *                            08 05050008
         BAL   R9,PRINTSM               *                            08 05060008
         LA    R1,SYSLIB                *                            08 05070008
         USING IHADCB,R1                *                            08 05080008
         LH    R0,DCBBLKSI              *                            08 05090008
         DROP  R1                       *                            08 05100008
         L     R15,DECB+16              *  Status area address       08 05110008
         SH    R0,14(,R15)              *  Resiual count             08 05120008
         LR    R1,R6                    *                            08 05130008
         BAL   R14,DMP                  *                            08 05140008
         L     R9,W#SAVER9              *                            08 05150008
DMPCTL90 DS    0H                      **                            08 05160008
         TM    PROCSW,PROCSWFD         WAS CSECT FOUND                  05170000
         BZ    MISSCS                  NO, ERROR                        05180000
         BALR  R9,R9                   PERFORM APPROPRIATE ROUTINE      05190000
         TM    PROCSW,PROCSWOK         MODULE PROCESSING DONE           05200000
         BZ    MAINLINE                NO, GO READ AGAIN                05210000
         B     ENDINIT                 GO COMPLETE PROCESSING           05220000
****************************************************************        05230000
*                                                              *        05240000
* PROCESS LOAD MODULE CONTROL RECORDS. THESE RECORDS PRECEED   *     08 05250008
* TEXT RECORDS, WHICH ARE READ AND PLACED IN STORAGE IN CONTIG-*        05260000
* UOUS LOCATIONS.  THE TEXT WILL BE RETURNED TO CALLER.        *        05270000
*                                                              *        05280000
****************************************************************        05290000
CNTLRECS DS    0H                      CONTROL RECORD PROCESSING        05300000
         ST    R9,CT9                  SAVE RETURN ADDR                 05310000
         SR    R8,R8                   CLEAR WORK                       05320000
         ICM   R8,7,9(R6)              LKED ASGND ADDRESS OF TXT        05330000
         TM    0(R6),X'08'             RECORD PRECEDES LAST RECORD      05340000
         BZ    CNCKTYP                 NO                               05350000
         OI    PROCSW,PROCSWOK         YES, SHOW PROCESSING COMPLETE    05360000
CNCKTYP  DS    0H                                                       05370000
         TM    0(R6),X'02'             CONTROL AND RLD                  05380000
         BO    CNPASRLD                YES                              05390000
         LA    R12,16(,R6)             CSED ENTRY NUMBER ADDRESS        05400000
         B     CNCKESD                 CONTINUE                         05410000
CNPASRLD DS    0H                                                       05420000
         LH    R12,6(,R6)              GET RLD SECTION LENGTH           05430000
         LA    R12,16(R6,R12)          CSED ENTRY NUMBER ADDRESS        05440000
CNCKESD  DS    0H                                                       05450000
         LH    R11,4(,R6)              LENGTH OF CONTROL INFO SECTION   05460000
         SRL   R11,2                   COMPUTE NBR CNTL ENTRIES         05470000
         SR    R10,R10                 OFFSET TO 1ST BYTE               05480000
         SR    R9,R9                   LENGTH OF TEXT                   05490000
CNCKESD1 DS    0H                                                       05500000
         CLC   ESDID,0(R12)            THIS THE DESIRED ESD             05510000
         BE    CNFNDIT                 YES                              05520000
         AH    R10,2(,R12)             MAINTAIN OFFSET TO 1ST TEXT BYTE 05530000
         LA    R12,4(,R12)             TO NEXT CNTL ENTRY               05540000
         BCT   R11,CNCKESD1            LOOP THRU CNTL ENTRIES           05550000
         B     READTEXT                GO READ FOLLOWING TEXT           05560000
CNFNDIT  DS    0H                                                       05570000
         LH    R9,2(,R12)              GET TEXT LENGTH                  05580000
READTEXT DS    0H                                                       05590000
         READ  DECB,SF,,(6),MF=E       READ FOLLOWING TEXT RECORD       05600000
         CHECK DECB                    AWAIT COMPLETION                 05610000
         AP    W#RECCT,=P'+1'                                        08 05620008
         LTR   R9,R9                   DOES IT CONTAIN DESIRED TEXT     05630000
         BZ    CTXIT                   NO, SKIP IT                      05640000
         S     R8,START                (-) OFFSET IN MODULE             05650000
         AR    R8,R10                  ADD OFFSET OF PORTION IN RCD     05660000
*           R8 SHOULD NOW CONTAIN THE OFFSET WITHIN THE CSECT           05670000
*           THAT THIS BLOCK CONTAINS (TRICKY).                          05680000
         A     R10,BUFAD               ADDRESS OF 1ST TEXT BYTE         05690000
         A     R8,TXTSTRT              ADDRESS OF PLACE TO MOVE TEXT    05700000
         LR    R11,R9                  COPY LENGTH TO MOVE              05710000
         MVCL  R8,R10                  MOVE TEXT TO STORAGE             05720000
CTXIT    DS    0H                                                       05730000
         L     R9,CT9                  GET RETURN ADDR                  05740000
         BR    R9                      EXIT                             05750000
****************************************************************        05760000
*                                                              *        05770000
* PROCESS RLD RECORDS. A TABLE OF RLD DATA IS BUILT WHICH WILL *        05780000
* LATER BE USED TO BUILD PROGRAM LABELS AND ADCONS.            *        05790000
*                                                              *        05800000
****************************************************************        05810000
RLDRECS  DS    0H                      RLD RECORD PROCESSING            05820000
         TM    0(R6),X'08'             LAST RECORD OF MODULE            05830000
         BZ    RLSV9                   NO                               05840000
         OI    PROCSW,PROCSWOK         SHOW PROCESSING COMPLETE         05850000
RLSV9    DS    0H                                                       05860000
         ST    R9,RL9                  SAVE RETURN ADDR                 05870000
         TM    PROCSW,PROCSW1T         FIRST TIME                       05880000
         BO    RLDST                   NO, SKIP HEADERS                 05890000
         OI    PROCSW,PROCSW1T         SET HEADERS DONE                 05900000
         MVC   PRT(27),=C'Relocation Dictionary Table'                  05910000
         BAL   R9,PRINTSM              PRINT                            05920000
         MVC   PRT(L'RLDHDR),RLDHDR    RLD HEADER                       05930000
         BAL   R9,PRINTSM              PRINT RLD HEADER                 05940000
RLDST    DS    0H                                                       05950000
         LH    R8,6(,R6)               NBR BYTES OF RLD DATA            05960000
         LA    R6,16(,R6)              ADDRESS OF 1ST BYTE OF RLD DATA  05970000
         AR    R8,R6                   END OF RLD DATA ADDR             05980000
         L     R7,CURRLD               ADDRESS OF NEXT RLD TBL ENTRY    05990000
         USING RLDTBLD,R7                                               06000000
         LH    R10,0(,R6)              RELOCATION POINTER               06010000
         LH    R11,2(,R6)              POSITION POINTER                 06020000
         LA    R6,4(,R6)               PASS POINTERS                    06030000
RLDNXT   DS    0H                                                       06040000
         CLC   1(3,R6),START+1         RLD ADDR BELOW CSECT             06050000
         BL    RLDSTEP                 LOW, IGNORE                      06060000
         CLC   1(3,R6),END+1           RLD ADDR ABOVE CSECT             06070000
         BH    RLDSTEP                 HIGH, IGNORE                     06080000
         C     R7,ENDRLD               END OF RLD TBL                   06090000
         BE    RLDFULL                 YES, ERROR                       06100000
         STH   R10,RLDRP               SAVE RELOC PTR                   06110000
         STH   R11,RLDPP               POS PTR                          06120000
         PACK  RLDTYPE,0(1,R6)         INVERT FLAG BYTE                 06130000
         NI    RLDTYPE,X'0F'           CLEAR HI-ORDER                   06140000
         CLI   RLDTYPE,9               UNRESOLVED                       06150000
         BNE   RLDMOVLN                NO                               06160000
         MVI   RLDTYPE,8               YES, USE PREFERRED VALUE         06170000
RLDMOVLN DS    0H                                                       06180000
         MVC   RLDLEN,0(R6)            FLAG BYTE                        06190000
         NI    RLDLEN,X'0F'            CLEAR HI-ORDER                   06200000
         SR    R12,R12                 CLEAR WORK                       06210000
         IC    R12,RLDLEN              PICK UP BYTE                     06220000
         SRL   R12,2                   SHIFT OUT DIR, IND BITS          06230000
         LA    R12,1(,R12)             ADD 1 = LENGTH                   06240000
         STC   R12,RLDLEN              LENGTH CODE                      06250000
         MVI   RLDDIR,C'+'             ASSUME POS RELOC                 06260000
         TM    0(R6),2                 IS IT POSITIVE                   06270000
         BZ    RLADMV                  YES                              06280000
         MVI   RLDDIR,C'-'             NO, SHOW NEGATIVE                06290000
RLADMV   DS    0H                                                       06300000
         SR    R1,R1                   CLEAR WORK REG                   06310000
         ICM   R1,7,1(R6)              PICK UP ADDRESS                  06320000
         S     R1,START                RELATIVIZE WITHIN CSECT          06330000
         STCM  R1,7,RLDADDR            SAVE RELATIVE ADDRESS            06340000
         LA    R12,RLDRP               ADDRESS OF ELOC PTR              06350000
         BAL   R9,HEXPRT2              CONVERT                          06360000
         MVC   PRT+6(4),PRTABL         RELOC PTR                        06370000
         LA    R12,RLDPP               ADDRESS OF POS PTR               06380000
         BAL   R9,HEXPRT2              CONVERT                          06390000
         MVC   PRT+14(4),PRTABL        POS PTR                          06400000
         MVC   PRT+24(4),=C'ACON'      ASSUME A TYPE ADCON              06410000
         CLI   RLDTYPE,0               IS IT ADCON                      06420000
         BE    RLDLN                   YES                              06430000
         MVC   PRT+24(4),=C'VCON'      ASSUME VCON                      06440000
         CLI   RLDTYPE,1               IS IT VCON                       06450000
         BE    RLDLN                   YES                              06460000
         MVC   PRT+22(6),=C'PRDISP'    ASSUME PSEUDO REG DISPL          06470000
         CLI   RLDTYPE,2               IS IT P.R. DISPL                 06480000
         BE    RLDLN                   YES                              06490000
         MVC   PRT+22(6),=C'PRCUM'     ASSUME PSEUDO REG CUMUL DISPL    06500000
         CLI   RLDTYPE,3               IS IT P.R. CUM DISPL             06510000
         BE    RLDLN                   YES                              06520000
         MVC   PRT+21(10),=C'UNRESOLVED' ASSUME UNRESOLVED              06530000
         CLI   RLDTYPE,8               IS IT UNRESOLVED                 06540000
         BE    RLDLN                   YES                              06550000
         MVC   PRT+21(10),BLANX        CLEAR FIELD                      06560000
         MVC   PRT+22(2),=C'X'''       UNIDENTIFIABLE TYPE              06570000
         LA    R12,RLDTYPE             ADDRESS OF TYPE                  06580000
         BAL   R9,HEXPRT1              CONVERT                          06590000
         MVC   PRT+24(2),PRTABL        TYPE                             06600000
         MVI   PRT+26,C''''                                             06610000
RLDLN    DS    0H                                                       06620000
         MVC   PRT+35(1),RLDLEN        LENGTH                           06630000
         OI    PRT+35,C'0'             CLEAR ZONE                       06640000
         MVC   PRT+42(1),RLDDIR        RELOCATION DIRECTION             06650000
         LA    R12,RLDADDR             ADDRESS OF ADDRESS               06660000
         BAL   R9,HEXPRT3              CONVERT                          06670000
         MVC   PRT+46(6),PRTABL        ADDRESS                          06680000
         XC    RLDNAME(9),RLDNAME      CLEAR                            06690000
         LH    R15,RLDRP               GET RELOCATION POINTER           06700000
         BCTR  R15,R0                  DEDUCT 1                         06710000
         LTR   R15,R15                 TEST DIFFERENCE                  06720000
         BM    RLPRT                   NEG, ERROR                       06730000
         MH    R15,SYMLEN              TIMES SYM TBL ENTRY LENG         06740000
         A     R15,SYMTBAD             ADDRESS OF  ESD SYMBOL TBL ENTRY 06750000
         C     R15,CURRSYM             PAST END OF TABLE                06760000
         BH    RLPRT                   YES, ERROR                       06770000
         USING SYMTBL,R15                                               06780000
         MVC   RLDNAME,EXTSYM          ESD SYMBOL TO RLD TBL ENTRY      06790000
         MVC   RLDESDTP,TYPSYM         ESD TYPE TO RLD ENTRY            06800000
         DROP  R15                                                      06810000
         MVC   PRT+60(8),RLDNAME       NAME TO PRINT                    06820000
         MVC   PRT+71(2),=C'LR'        ASSUME LR                        06830000
         CLI   RLDESDTP,3              IS IT LR                         06840000
         BE    RLPRT                   YES                              06850000
         MVC   PRT+71(2),=C'SD'        ASSUME SD                        06860000
         CLI   RLDESDTP,0              IS IT SD                         06870000
         BE    RLPRT                   YES                              06880000
         CLI   RLDESDTP,X'0D'          IS IT SD                         06890000
         BE    RLPRT                   YES                              06900000
         MVC   PRT+71(2),=C'ER'        ASSUME ER                        06910000
         CLI   RLDESDTP,2              IS IT ER                         06920000
         BE    RLPRT                   YES                              06930000
         MVC   PRT+71(2),=C'PC'        ASSUME PC                        06940000
         CLI   RLDESDTP,4              IS IT PC                         06950000
         BE    RLPRT                   YES                              06960000
         CLI   RLDESDTP,X'0E'          IS IT PC                         06970000
         BE    RLPRT                   YES                              06980000
         MVC   PRT+71(2),=C'PR'        ASSUME PR                        06990000
         CLI   RLDESDTP,6              IS IT PR                         07000000
         BE    RLPRT                   YES                              07010000
         MVC   PRT+71(2),=C'CM'        ASSUME CM                        07020000
         CLI   RLDESDTP,5              IS IT CM                         07030000
         BE    RLPRT                   YES                              07040000
         MVC   PRT+71(2),=C'WX'        ASSUME WX                        07050000
         CLI   RLDESDTP,X'0A'          IS IT WX                         07060000
         BE    RLPRT                   YES                              07070000
         MVC   PRT+71(4),=C'NULL'      ASSUME NULL                      07080000
         CLI   RLDESDTP,7              IS IT NULL                       07090000
         BE    RLPRT                   YES                              07100000
         MVC   PRT+71(6),=C'E/STAB'    ASSUME E/STAB                    07110000
         CLI   RLDESDTP,X'0F'          IS IT E/STAB                     07120000
         BE    RLPRT                   YES                              07130000
         MVI   PRT+71,C' '                                              07140000
         MVC   PRT+72(2),=C'X'''       UNIDENTIFIABLE TYPE              07150000
         LA    R12,RLDESDTP            ADDRESS OF TYPE                  07160000
         BAL   R9,HEXPRT1              CONVERT                          07170000
         MVC   PRT+74(2),PRTABL        TYPE                             07180000
         MVI   PRT+76,C''''                                             07190000
RLPRT    DS    0H                                                       07200000
         BAL   R9,PRINTSM              PRINT                            07210000
         LA    R7,L'RLDENT(,R7)        TO NEXT TBL ENTRY                07220000
RLDSTEP  DS    0H                                                       07230000
         TM    PRMOPT,PRMOPTDB         ** DEBUG on                   08 07240008
         BNO   RLDDBG20                 *  Print the RLD entry       08 07250008
         MVC   PRT(9),=C'RLD entry'     *                            08 07260008
         LR    R12,R6                   *                            08 07270008
         BAL   R9,HEXPRT4               *                            08 07280008
         MVC   PRT+10(1),PRTABL         *                            08 07290008
         MVC   PRT+12(1),PRTABL+1       *                            08 07291008
         MVC   PRT+14(6),PRTABL+2       *                            08 07300008
         TM    0(R6),1                  *                            08 07310008
         BO    RLDDBG10                 *                            08 07320008
         LA    R12,4(,R6)               *                            08 07330008
         BAL   R9,HEXPRT4               *                            08 07340008
         MVC   PRT+21(4),PRTABL         *                            08 07350008
         MVC   PRT+26(4),PRTABL+4       *                            08 07360008
RLDDBG10 DS    0H                       *                            08 07370008
         BAL   R9,PRINTSM               *                            08 07380008
RLDDBG20 DS    0H                      **                            08 07390008
         TM    0(R6),1                 NEXT ITEM HAS REL AND POS PTRS   07400000
         BO    RLSAME                  NO                               07410000
         LH    R10,4(,R6)              PICK UP NEW REL PTR              07420000
         LH    R11,6(,R6)              PICK UP NEW POS PTR              07430000
         LA    R6,4(,R6)               STEP OVER 4 BYTES                07440000
RLSAME   DS    0H                                                       07450000
         LA    R6,4(,R6)               TO NEXT RLD ITEM                 07460000
         CR    R6,R8                   END OF RLD DATA                  07470000
         BL    RLDNXT                  NO                               07480000
         MVI   0(R7),X'FF'             SET TBL END INDIC                07490000
         ST    R7,CURRLD               SET NEW CURRENT ADDRESS          07500000
         L     R9,RL9                  GET RETURN ADDR                  07510000
         BR    R9                      EXIT                             07520000
         DROP  R7                                                       07530000
****************************************************************        07540000
*                                                              *        07550000
* PROCESS CONTROL AND RLD RECORDS. THESE RECORDS CONTAIN BOTH  *        07560000
* RLD AND CONTROL INFORMATION, AND ARE PROCESSED BY BOTH       *        07570000
* THE RLDRECS AND CNTLRECS ROUTINES.                           *        07580000
*                                                              *        07590000
****************************************************************        07600000
CTRLRECS DS    0H                      CONTROL AND RLD RECORDS          07610000
         ST    R9,CR9                  SAVE RETURN ADDR                 07620000
         BAL   R9,RLDRECS              PROCESS RLD DATA                 07630000
         L     R6,BUFAD                RESET BUFFER ADDRESS             07640000
         BAL   R9,CNTLRECS             PROCESS CONTROL DATA             07650000
         L     R9,CR9                  GET RETURN ADDR                  07660000
         BR    R9                      EXIT                             07670000
****************************************************************        07680000
*                                                              *        07690000
* PROCESS COMPOSITE ESD RECORDS. DATA FROM THESE RECORDS IS    *        07700000
* PLACED IN THE SYMBOL TABLE, AND IS USED TO CREATE PROGRAM    *        07710000
* ENTRY STATEMENTS, AND TO IDENTIFY THE NAMES OF EXTERNAL      *        07720000
* SYMBOLS USED BY THE PROGRAM.                                 *        07730000
*                                                              *        07740000
****************************************************************        07750000
CESDREC  DS    0H                      CESD RECORD PROCESSING           07760000
         ST    R9,CES9                 SAVE RETURN                      07770000
         L     R7,CURRSYM              GET SYMBOL TBL ADDR              07780000
         USING SYMTBL,R7                                                07790000
         LH    R10,4(,R6)              GET ESD ID OF 1ST ITEM           07800000
         LH    R8,6(,R6)               NBR BYTES OF ESD DATA            07810000
         SRL   R8,4                    COMPUTE NBR ENTRIES              07820000
         LA    R6,8(,R6)               STEP TO 1ST RECORD ESD ITEM      07830000
CESDNXT  DS    0H                                                       07840000
         C     R7,ENDSYM               END OF TABLE                     07850000
         BNL   SYMFULL                 YES, ERROR                       07860000
         MVC   EXTSYM,0(R6)            SYMBOL NAME                      07870000
         MVC   TYPSYM,8(R6)            TYPE                             07880000
         NI    TYPSYM,X'0F'            CLEAR BITS 0-3                   07890000
         MVC   SYMIND,8(R6)            INDICATOR BYTE                   07900000
         NI    SYMIND,X'0F'            CLEAR BITS 4-7                   07910000
         TM    8(R6),X'14'             POSSIBLE ENTAB/SEGTAB            07920000
         BNO   CEMVAD                  NO                               07930000
         TM    8(R6),X'03'             IS IT ENTAB/SEGTAB               07940000
         BNZ   CEMVAD                  NO                               07950000
         MVC   TYPSYM(2),=X'0F00'      SHOW ENTAB/SEGTAB                07960000
CEMVAD   DS    0H                                                       07970000
         MVC   SYMADDR,9(R6)           ADDRESS OF SYMBOL                07980000
         MVC   SYMSEG,12(R6)           SEGMENT WHERE DEFINED            07990000
         MVC   SYMLENG,13(R6)          LENGTH OR LR ESD ID              08000000
         STCM  R10,3,SYMESDID          ESD ID                           08010000
         MVC   PRT+6(8),EXTSYM         SYMBOL NAME                      08020000
         OC    PRT+6(8),BLANX          X'00' NAME BECOME BLANK       05 08030005
         MVC   PRT+22(2),=C'SD'        ASSUME SD                        08040000
         CLI   TYPSYM,0                IS IT SD                         08050000
         BE    CEPIND                  YES                              08060000
         CLI   TYPSYM,X'0D'            IS IT SD                         08070000
         BE    CEPIND                  YES                              08080000
         MVC   PRT+22(2),=C'LR'        ASSUME LR                        08090000
         CLI   TYPSYM,3                IS IT LR                         08100000
         BE    CEPIND                  YES                              08110000
         MVC   PRT+22(2),=C'ER'        ASSUME ER                        08120000
         CLI   TYPSYM,2                IS IT ER                         08130000
         BE    CEPIND                  YES                              08140000
         MVC   PRT+22(2),=C'PC'        ASSUME PC                        08150000
         CLI   TYPSYM,4                IS IT PC                         08160000
         BE    CEPIND                  YES                              08170000
         CLI   TYPSYM,X'0E'            IS IT PC                         08180000
         BE    CEPIND                  YES                              08190000
         MVC   PRT+22(2),=C'PR'        ASSUME PR                        08200000
         CLI   TYPSYM,6                IS IT PR                         08210000
         BE    CEPIND                  YES                              08220000
         MVC   PRT+22(2),=C'CM'        ASSUME CM                        08230000
         CLI   TYPSYM,5                IS IT CM                         08240000
         BE    CEPIND                  YES                              08250000
         MVC   PRT+22(2),=C'WX'        ASSUME WX                        08260000
         CLI   TYPSYM,X'0A'            IS IT WX                         08270000
         BE    CEPIND                  YES                              08280000
         MVC   PRT+20(4),=C'NULL'      ASSUME NULL                      08290000
         CLI   TYPSYM,7                IS IT NULL                       08300000
         BE    CEPIND                  YES                              08310000
         MVC   PRT+18(6),=C'E/STAB'    ASSUME ENTAB/SEGTAB              08320000
         CLI   TYPSYM,X'0F'            IS IT ENTAB/SEGTAB               08330000
         BE    CEPIND                  YES                              08340000
         MVI   PRT+18,C' '                                              08350000
         MVC   PRT+19(2),=C'X'''       UNIDENTIFIABLE TYPE              08360000
         LA    R12,TYPSYM              ADDRESS OF TYPE                  08370000
         BAL   R9,HEXPRT1              CONVERT                          08380000
         MVC   PRT+21(2),PRTABL        TYPE                             08390000
         MVI   PRT+23,C''''                                             08400000
CEPIND   DS    0H                                                       08410000
         LA    R12,SYMIND              ADDRESS OF INDICATOR             08420000
         BAL   R9,HEXPRT1              CONVERT                          08430000
         MVC   PRT+27(1),PRTABL        INDICATOR                        08440000
         LA    R12,SYMADDR             ADDRESS OF SYMBOL ADDR           08450000
         BAL   R9,HEXPRT3              CONVERT                          08460000
         MVC   PRT+30(6),PRTABL        SYMBOL ADDR                      08470000
         LA    R12,SYMSEG              ADDRESS OF SEGMENT NBR           08480000
         BAL   R9,HEXPRT1              CONVERT                          08490000
         MVC   PRT+39(2),PRTABL        SEGMENT NBR                      08500000
         CLI   TYPSYM,2                IS IT ER                         08510000
         BE    CEESD                   YES                              08520000
         CLI   TYPSYM,3                IS IT AN LR                      08530000
         BNE   CENOTLR                 NO                               08540000
         LA    R12,SYMLRID             ADDRESS OF LR ESD ID             08550000
         BAL   R9,HEXPRT2              CONVERT                          08560000
         MVC   PRT+43(4),PRTABL        LR ESD ID                        08570000
         B     CEESD                   CONTINUE                         08580000
CENOTLR  DS    0H                                                       08590000
         LA    R12,SYMLENG             ADDRESS OF LENGTH                08600000
         BAL   R9,HEXPRT3              CONVERT                          08610000
         MVC   PRT+49(6),PRTABL        SYMBOL LENGTH                    08620000
CEESD    DS    0H                                                       08630000
         LA    R12,SYMESDID            ADDRESS OF ESD ID                08640000
         BAL   R9,HEXPRT2              CONVERT                          08650000
         MVC   PRT+57(4),PRTABL        ESD ID                           08660000
         TM    PROCSW,PROCSWFD         FOUND CSECT                      08670000
         BO    CESDPT                  YES                              08680000
         CLI   TYPSYM,0                SD                               08690000
         BE    CECKCSB                 YES                              08700000
         CLI   TYPSYM,X'0D'            SD                               08710000
         BE    CECKCSB                 YES                              08720000
         CLI   TYPSYM,4                PC                               08730000
         BE    CECKCSB                 YES                              08740000
         CLI   TYPSYM,X'0E'            PC                               08750000
         BE    CECKCSB                 YES                              08760000
         B     CESDPT                  NO                               08770000
CECKCSB  DS    0H                                                       08780000
         CLC   CSECT,BLANX             ANY CSECT NAME ENTERED           08790000
         BNE   CECKNM                  YES                              08800000
         MVC   CSECT,EXTSYM            NAME TO CSECT                    08810000
         B     CSGOTCS                 CONTINUE                         08820000
CECKNM   DS    0H                                                       08830000
         CLI   TYPSYM,4                PC                               08840000
         BE    CESDPT                  YES                              08850000
         CLC   CSECT,EXTSYM            FOUND DESIRED NAME               08860000
         BNE   CESDPT                  NO                               08870000
         TM    PROCSW,PROCSWFD         ALREADY FOUND CSECT              08880000
         BZ    CSGOTCS                 NO                               08890000
         MVC   PRT+16(3),=C'DUP'       SHOW DUPL                        08900000
         B     CESDPT                  CONTINUE                         08910000
CSGOTCS  DS    0H                                                       08920000
         OI    PROCSW,PROCSWFD         SHOW CSECT FOUND                 08930000
         MVC   PRT+15(2),=C'**'        FLAG ON PRINTOUT                 08940000
         MVC   ESDID,SYMESDID          SAVE ESD ID FOUND                08950000
         MVC   START+1,SYMADDR         SAVE CSECT START ADDR            08960000
         MVC   LENGTH+1(3),SYMLENG     SAVE CSECT LENGTH                08970000
         L     R1,LENGTH               PICK UP LENGTH                   08980000
         A     R1,START                COMPUTE CSECT END ADDR           08990000
         ST    R1,END                  SAVE CSECT END ADDR              09000000
         L     R11,LENGTH              TEXT LENGTH                      09010000
         LA    R11,256(,R11)           ADD FOR SAFETY                   09020000
         LR    R0,R11                  Get module length             06 09030006
         TM    PRMOPT,PRMOPTPA         Page aligned LOAD active?     06 09040006
         BNO   SKIPPA                  No, skip alignment            06 09050006
         AL    R0,=X'00001000'         Round up to next page         06 09060006
         N     R0,=X'FFFFF000'         Round to page size            06 09070006
SKIPPA   DS    0H                                                    06 09080006
         GETMAIN R,LV=(0)              Get storage for text          06 09090006
         ST    R0,0(,R1)               Save length of buffer         06 09100006
         MVC   4(4,R1),LENGTH          ACTUAL TEXT LENGTH               09110000
         LA    R1,8(,R1)               SKIP PAST LENGTH                 09120000
         ST    R1,TXTSTRT              SAVE TEXT ADDR                   09130000
         SH    R11,=H'+256'            DEDUCT SAFETY FACTOR             09140000
         AR    R1,R11                  TXT END ADDR                     09150000
         ST    R1,TXTEND               SAVE TEXT END ADDR               09160000
         L     R0,TXTSTRT   ******************************************* 09170004
         L     R1,TXTEND    ******************************************* 09180004
         SR    R1,R0        ************* fill text buffer ************ 09190004
         SR    R15,R15      ************* with non-zeros   ************ 09200004
         ICM   R15,8,=X'AA' ******************************************* 09210004
         MVCL  R0,R14       ******************************************* 09220004
CESDPT   DS    0H                                                       09230000
         BAL   R9,PRINTSM              PRINT                            09240000
         LA    R7,L'SYMENT(,R7)        TO NEXT TBL ENTRY LOCATION       09250000
         LA    R10,1(,R10)             ADD 1 TO ESD COUNTER             09260000
         LA    R6,16(,R6)              TO NEXT ESD ITEM IN INPUT        09270000
         BCT   R8,CESDNXT              LOOP THRU INPUT RECORD           09280000
         MVI   0(R7),X'FF'             SET END OF TABLE INDIC           09290000
         ST    R7,CURRSYM              SAVE NEXT TABLE ADDR             09300000
         L     R9,CES9                 GET RETURN ADDR                  09310000
         BR    R9                      EXIT                             09320000
         DROP  R7                                                       09330000
****************************************************************        09340000
*                                                              *        09350000
* ISSUE BLDL FOR THE MAIN MODULE AND PRINT MODULE RELATED INFO *        09360000
*                                                              *        09370000
****************************************************************        09380000
BLDL     DS    0H                      ISSUE BLDL AND PRINT INFO        09390000
         ST    R9,BL9                  SAVE RETURN ADDR                 09400000
ISSBLDL  DS    0H                                                       09410000
         BLDL  SYSLIB,BLDLIST          ISSUE BLDL                       09420000
         LTR   R15,R15                 ANY ERRORS                       09430000
         BNZ   MISSMEM                 YES                              09440000
         LA    R1,MEMBER+35            END OF BASIC PORTION             09450000
         TM    ATTR2,X'10'             SSI PRESENT                      09460000
         BZ    BLREFA1                 NO                               09470000
         LA    R1,4(,R1)               ADD FOR SSI                      09480000
BLREFA1  DS    0H                                                       09490000
         TM    ALIASIND,X'80'          ALIAS                            09500000
         BZ    BLREFA2                 NO                               09510000
         LA    R1,11(,R1)              ADD FOR ALIAS                    09520000
BLREFA2  DS    0H                                                       09530000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   09540000
         BZ    BLREFA3                 NO                               09550000
         LA    R1,8(,R1)               ADD FOR SCATTER                  09560000
BLREFA3  DS    0H                                                       09570000
         STC   R1,DEVTYPE              SAVE OFFSET                      09580000
         TM    DEVTYPE,1               IS OFFSET ODD                    09590000
         BZ    ALIGN1                  NO, CONTINUE                     09600000
         LA    R1,1(,R1)               AUTHCODE IS ON EVEN BOUNDARY     09610000
ALIGN1   DS    0H                                                       09620000
         MVC   AUTHLEN(2),0(R1)        AUTH LENGTH AND CODE             09630000
         TM    ATTR2,X'10'             SSI PRESENT                      09640000
         BZ    BLCKALI                 NO                               09650000
         LA    R1,MEMBER+35            END OF BASIC PORTION             09660000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   09670000
         BZ    BLSSI2                  NO                               09680000
         TM    ALIASIND,X'80'          ALIAS                            09690000
         BO    BLFMTED                 YES, NO REFORMAT NEEDED          09700000
         LA    R1,8(,R1)               NO, STEP PAST SCATTER SECTION    09710000
         B     BLMVSSI                 GO MOVE SSI                      09720000
BLSSI2   DS    0H                                                       09730000
         TM    ALIASIND,X'80'          ALIAS                            09740000
         BZ    BLMVSSI                 NO                               09750000
         LA    R1,11(,R1)              YES, STEP PAST ALIAS SECTION     09760000
BLMVSSI  DS    0H                                                       09770000
         STC   R1,DEVTYPE              SAVE OFFSET                      09780000
         TM    DEVTYPE,1               IS OFFSET ODD                    09790000
         BZ    ALIGN2                  NO, CONTINUE                     09800000
         LA    R1,1(,R1)               SSI IS ON EVEN BOUNDARY          09810000
ALIGN2   DS    0H                                                       09820000
         MVC   SSI,0(R1)               MOVE SSI DATA                    09830000
BLCKALI  DS    0H                                                       09840000
         TM    ALIASIND,X'80'          ALIAS                            09850000
         BO    BLASC                   YES                              09860000
         B     BLFMTED                 FINISHED                         09870000
BLASC    DS    0H                                                       09880000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   09890000
         BO    BLFMTED                 YES, NO REFORMAT NEEDED          09900000
         MVC   ALMEM,MEMBER+38         MOVE ALIAS MEMBER                09910000
         MVC   ALEPA(3),MEMBER+35      YES, MOVE ALIAS DATA             09920000
BLFMTED  DS    0H                                                       09930000
         MVC   PRT(25),=C'Directory info for module'                    09940000
         MVC   PRT+26(8),MEMBER        MEMBER NAME TO PRINT             09950000
         BAL   R9,PRINT                PRINT                            09960000
         MVC   PRT+10(14),=C'TTR of module='                            09970000
         LA    R12,TTRMOD              ADDRESS OF TTR                   09980000
         BAL   R9,HEXPRT3              CONVERT                          09990000
         MVC   PRT+24(6),PRTABL        TTR TO PRINT                     10000000
         BAL   R9,PRINT                PRINT                            10010000
         MVC   PRT+10(14),=C'Concatenation='                            10020000
         LA    R12,CCAT                ADDRESS OF CONCATENATION NBR     10030000
         BAL   R9,HEXPRT1              CONVERT                          10040000
         MVC   PRT+24(2),PRTABL        CONCATENATION NBR                10050000
         BAL   R9,PRINT                PRINT                            10060000
         MVC   PRT+10(16),=C'Alias indicator='                          10070000
         LA    R12,ALIASIND            ADDRESS OF ALIAS INDICATOR       10080000
         BAL   R9,HEXPRT1              CONVERT                          10090000
         MVC   PRT+26(2),PRTABL        ALIAS INDICATOR                  10100000
         TM    ALIASIND,X'80'          IS IT AN ALIAS                   10110000
         BZ    BLALPRT                 NO                               10120000
         MVC   PRT+50(13),=C'*** Alias ***'                             10130000
BLALPRT  DS    0H                                                       10140000
         BAL   R9,PRINT                PRINT                            10150000
         MVC   PRT+10(22),=C'TTR of 1st TXT record='                    10160000
         LA    R12,TTR1TXT             ADDRESS OF TTR                   10170000
         BAL   R9,HEXPRT3              CONVERT                          10180000
         MVC   PRT+32(6),PRTABL        TTR OF 1ST TXT BLOCK             10190000
         BAL   R9,PRINT                PRINT                            10200000
         MVC   PRT+10(25),=C'TTR of NOTE/Scatter list='                 10210000
         LA    R12,TTRNS               ADDRESS OF TTR                   10220000
         BAL   R9,HEXPRT3              CONVERT                          10230000
         MVC   PRT+35(6),PRTABL        TTR OF NOTE/SCATTER              10240000
         BAL   R9,PRINT                PRINT                            10250000
         MVC   PRT+10(20),=C'Number NOTE entries='                      10260000
         LA    R12,NNOTE               ADDRESS OF NBR NOTES             10270000
         BAL   R9,HEXPRT1              CONVERT                          10280000
         MVC   PRT+30(2),PRTABL        NBR NOTE ENTRIES                 10290000
         BAL   R9,PRINT                PRINT                            10300000
         MVC   PRT+10(14),=C'Attributes #1='                            10310000
         LA    R12,ATTR1A              ADDRESS OF ATTRIBUTES            10320000
         BAL   R9,HEXPRT2              CONVERT                          10330000
         MVC   PRT+24(4),PRTABL        ATTRIBUTES 1                     10340000
         LA    R1,PRT+29               START OF ATTRIBUTES              10350000
         TM    ATTR1A,X'80'            RENT                             10360000
         BZ    BLAT1A                  NO                               10370000
         MVC   0(4,R1),=C'RENT'                                         10380000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   10390000
BLAT1A   DS    0H                                                       10400000
         TM    ATTR1A,X'40'            REUS                             10410000
         BZ    BLAT1B                  NO                               10420000
         MVC   0(4,R1),=C'REUS'                                         10430000
BLAT1B   DS    0H                                                       10440000
         TM    ATTR1A,X'20'            OVLY                             10450000
         BZ    BLAT1C                  NO                               10460000
         MVC   0(4,R1),=C'OVLY'                                         10470000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   10480000
BLAT1C   DS    0H                                                       10490000
         TM    ATTR1A,X'10'            TEST                             10500000
         BZ    BLAT1D                  NO                               10510000
         MVC   0(4,R1),=C'TEST'                                         10520000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   10530000
BLAT1D   DS    0H                                                       10540000
         TM    ATTR1B,X'08'            OL                               10550000
         BZ    BLAT1E                  NO                               10560000
         MVC   0(2,R1),=C'OL'                                           10570000
         LA    R1,3(,R1)               NEXT ATTRIBUTE                   10580000
BLAT1E   DS    0H                                                       10590000
         TM    ATTR1A,X'04'            SCTR                             10600000
         BZ    BLAT1F                  NO                               10610000
         MVC   0(4,R1),=C'SCTR'                                         10620000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   10630000
BLAT1F   DS    0H                                                       10640000
         TM    ATTR1A,X'02'            EXEC                             10650000
         BZ    BLAT1G                  NO                               10660000
         MVC   0(4,R1),=C'EXEC'                                         10670000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   10680000
BLAT1G   DS    0H                                                       10690000
         TM    ATTR1B,X'08'            NOT EDITABLE                     10700000
         BZ    BLAT1H                  NO                               10710000
         MVC   0(2,R1),=C'NE'                                           10720000
         LA    R1,3(,R1)               NEXT ATTRIBUTE                   10730000
BLAT1H   DS    0H                                                       10740000
         TM    ATTR1B,X'01'            REFR                             10750000
         BZ    BLAT1PRT                NO                               10760000
         MVC   0(4,R1),=C'REFR'                                         10770000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   10780000
BLAT1PRT DS    0H                                                       10790000
         BAL   R9,PRINT                PRINT                            10800000
         MVC   PRT+10(13),=C'Total length='                             10810000
         LA    R12,TOTVIRT             ADDRESS OF TOTAL LENGTH          10820000
         BAL   R9,HEXPRT3              CONVERT                          10830000
         MVC   PRT+23(6),PRTABL        TOTAL LENGTH OF MODULE           10840000
         BAL   R9,PRINT                PRINT                            10850000
         MVC   PRT+10(25),=C'Length of 1st TXT record='                 10860000
         LA    R12,LENG1               ADDRESS OF 1ST TXT LENG          10870000
         BAL   R9,HEXPRT2              CONVERT                          10880000
         MVC   PRT+35(4),PRTABL        LENGTH OF 1ST TXT BLOCK          10890000
         BAL   R9,PRINT                PRINT                            10900000
         MVC   PRT+10(4),=C'EPA='                                       10910000
         LA    R12,LKEPA               ADDRESS OF E.P. ADDR             10920000
         BAL   R9,HEXPRT3              CONVERT                          10930000
         MVC   PRT+14(6),PRTABL        E.P. ADDR                        10940000
         BAL   R9,PRINT                PRINT                            10950000
         MVC   PRT+10(14),=C'Attributes #2='                            10960000
         LA    R12,ATTR2               ADDRESS OF ATTRIBUTES 2          10970000
         BAL   R9,HEXPRT2              CONVERT                          10980000
         MVC   PRT+24(4),PRTABL        ATTRIBUTES 2                     10990000
         LA    R1,PRT+29               START OF ATTRIBUTES              11000000
         TM    ATTR2,X'20'             PAGE ALIGNMENT                   11010000
         BZ    BLAT3A                  NO                               11020000
         MVC   0(4,R1),=C'PAGE'                                         11030000
         LA    R1,5(,R1)               NEXT ATTRIBUTE                   11040000
BLAT3A   DS    0H                                                       11050000
         TM    ATTR2,X'10'             SSI PRESENT                      11060000
         BZ    BLAT3B                  NO                               11070000
         MVC   0(3,R1),=C'SSI'                                          11080000
         LA    R1,4(,R1)               NEXT ATTRIBUTE                   11090000
BLAT3B   DS    0H                                                       11100000
         TM    ATTR2,X'08'             APF PRESENT                      11110000
         BZ    BLAT3PRT                NO                               11120000
         MVC   0(3,R1),=C'APF'                                          11130000
         LA    R1,4(,R1)               NEXT ATTRIBUTE                   11140000
BLAT3PRT DS    0H                                                       11150000
         BAL   R9,PRINT                PRINT                            11160000
         TM    ATTR1A,X'04'            SCATTER FORMAT                   11170000
         BZ    BLFAL                   NO                               11180000
         MVC   PRT+10(12),=C'SCTR length='                              11190000
         LA    R12,SCTRLEN             ADDRESS OF SCATTER LIST LENGTH   11200000
         BAL   R9,HEXPRT2              CONVERT                          11210000
         MVC   PRT+22(4),PRTABL        SCATTER LIST LENGTH              11220000
         BAL   R9,PRINT                PRINT                            11230000
         MVC   PRT+10(23),=C'Translate table length='                   11240000
         LA    R12,TTLEN               ADDRESS OF TRANS TBL LEN         11250000
         BAL   R9,HEXPRT2              CONVERT                          11260000
         MVC   PRT+33(4),PRTABL        TRANSLATION TABLE LENGTH         11270000
         BAL   R9,PRINT                PRINT                            11280000
         MVC   PRT+10(18),=C'ESD ID of 1st TXT='                        11290000
         LA    R12,SCESDID             ADDRESS OF ESD ID                11300000
         BAL   R9,HEXPRT2              CONVERT                          11310000
         MVC   PRT+28(4),PRTABL        ESD ID OF 1ST TXT                11320000
         BAL   R9,PRINT                PRINT                            11330000
         MVC   PRT+10(22),=C'ESD ID containing EPA='                    11340000
         LA    R12,SCEPESD             ADDRESS OF ESD ID                11350000
         BAL   R9,HEXPRT2              CONVERT                          11360000
         MVC   PRT+32(4),PRTABL        ADDRESS OF ESD ID OF CSECT W/EPA 11370000
         BAL   R9,PRINT                PRINT                            11380000
BLFAL    DS    0H                                                       11390000
         TM    ALIASIND,X'80'          ALIAS                            11400000
         BZ    BLFSSI                  NO                               11410000
         MVC   PRT+10(19),=C'EPA of this member='                       11420000
         LA    R12,ALEPA               ADDRESS OF EPA                   11430000
         BAL   R9,HEXPRT3              CONVERT                          11440000
         MVC   PRT+29(6),PRTABL        E.P. ADDR                        11450000
         BAL   R9,PRINT                                                 11460000
         MVC   PRT+10(17),=C'Real member name='                         11470000
         MVC   PRT+27(8),ALMEM         REAL MEMBER NAME                 11480000
         BAL   R9,PRINT                                                 11490000
BLFSSI   DS    0H                                                       11500000
         TM    ATTR2,X'10'             ANY SSI INFO                     11510000
         BZ    BLAUTHC                 NO                               11520000
         MVC   PRT+10(9),=C'SSI info='                                  11530000
         LA    R12,SSI                 ADDRESS OF SSI INFO              11540000
         BAL   R9,HEXPRT4              CONVERT                          11550000
         MVC   PRT+19(8),PRTABL        SSI INFO                         11560000
         BAL   R9,PRINT                PRINT                            11570000
BLAUTHC  DS    0H                                                       11580000
         TM    ATTR2,X'08'             APF PRESENT                      11590000
         BZ    BLNOAUTH                NO                               11600000
         MVC   PRT+10(10),=C'Auth code='                                11610000
         LA    R12,AUTHCOD             ADDRESS OF AUTH CODE             11620000
         BAL   R9,HEXPRT1              CONVERT                          11630000
         MVC   PRT+20(2),PRTABL        AUTH CODE                        11640000
         BAL   R9,PRINT                PRINT                            11650000
BLNOAUTH DS    0H                                                       11660000
         TM    ALIASIND,X'80'          ALIAS                            11670000
         BZ    BLXIT                   NO                               11680000
         MVC   PRT+5(26),=C'Real member directory info'                 11690000
         BAL   R9,PRINT                PRINT                            11700000
         MVC   MEMBER,ALMEM            REAL MEMBER NAME TO LIST         11710000
         B     ISSBLDL                 DO OVER FOR REAL MEMBER          11720000
BLXIT    DS    0H                                                       11730000
         L     R9,BL9                  GET RETURN ADDR                  11740000
         BR    R9                      EXIT                             11750000
****************************************************************        11760000
*                                                              *        11770000
* CREATE PRINTABLE HEX FROM HEX. ON ENTRY, REG 12 CONTAINS THE *        11780000
* ADDRESS OF THE DATA TO BE REFORMATTED. ENTRY POINT USED      *        11790000
* DETERMINES THE SIZE OF THE FIELD. OUTPUT DATA IS PLACED IN   *        11800000
* THE PRTABL FIELD, 2 CHARACTERS PER BYTE.                     *        11810000
*                                                              *        11820000
****************************************************************        11830000
HEXPRT1  DS    0H                                                       11840000
         UNPK  PRTABL(3),0(2,R12)      UNPACK HEX                       11850000
         B     HEXCLTR                 CONTINUE                         11860000
HEXPRT2  DS    0H                                                       11870000
         UNPK  PRTABL(5),0(3,R12)      UNPACK HEX                       11880000
         B     HEXCLTR                 CONTINUE                         11890000
HEXPRT3  DS    0H                                                       11900000
         UNPK  PRTABL(7),0(4,R12)      UNPACK HEX                       11910000
         B     HEXCLTR                 CONTINUE                         11920000
HEXPRT4  DS    0H                                                       11930000
         UNPK  PRTABL(9),0(5,R12)      UNPACK HEX                       11940000
HEXCLTR  DS    0H                                                       11950000
         TR    PRTABL(8),TRTBL-240     MAKE PRINTABLE                   11960000
         BR    R9                      EXIT                             11970000
****************************************************************        11980000
*                                                              *        11990000
* PRINT USING PRINTDD                                          *        12000000
*                                                              *        12010000
****************************************************************        12020000
PRINTSM  DS    0H                      PRINT ROUTINE                    12030000
         TM    PRMOPT,PRMOPTSU         SUMMARY ONLY                     12040000
         BNO   PRINT                   NO                               12050000
         MVC   PRT,BLANX               CLEAR PRINT LINE                 12060000
         BR    R9                      EXIT                             12070000
PRINT    DS    0H                      PRINT ROUTINE                    12080000
         TM    PRINTDD+48,16           IS PRINTDD OPEN                  12090000
         BNO   CLRPRT                  NO                               12100000
         PUT   PRINTDD,PRTLINE         WRITE PRINT LINE                 12110000
CLRPRT   DS    0H                                                       12120000
         MVC   PRT,BLANX               CLEAR PRINT LINE                 12130000
         AP    LINECT,=P'+1'           INCR LINE COUNTER                12140000
         CLI   PCC,C' '                SINGLE SPACED                    12150000
         BE    SETSGL                  YES                              12160000
         AP    LINECT,=P'+1'           INCR LINE COUNTER                12170000
         CLI   PCC,C'0'                DOUBLE SPACED                    12180000
         BE    SETSGL                  YES                              12190000
         AP    LINECT,=P'+1'           INCR LINE COUNTER                12200000
         CLI   PCC,C'-'                TRIPLE SPACED                    12210000
         BE    SETSGL                  YES                              12220000
         ZAP   LINECT,=P'+0'           NO, MUST BE NEW PAGE             12230000
SETSGL   DS    0H                                                       12240000
         MVI   PCC,C' '                SET SINGLE SPACING               12250000
         CP    LINECT,=P'+58'          PAST END OF PAGE                 12260000
         BH    NEWPAGE                 YES                              12270000
         BR    R9                      EXIT                             12280000
NEWPAGE  DS    0H                                                       12290000
         MVI   PCC,C'1'                SET SKIP TO HOF                  12300000
         ZAP   LINECT,=P'+0'           RESET LINE COUNTER               12310000
         BR    R9                      EXIT                             12320000
****************************************************************        12330000
*                                                              *        12340000
* MISCELLANEOUS ERROR MESSAGES.                                *        12350000
*                                                              *        12360000
****************************************************************        12370000
PRMERR   DS    0H                                                       12380000
         MVC   PRT(5),=C'PARM='        MOVE PARAMETER INFO LITERAL      12390000
         L     R14,PRMSTRT             PARM START                       12400000
         SR    R1,R14                  LESS START                       12410000
         LA    R2,PRT+5(R1)            SET LOCATION OF ERROR            12420000
         SH    R14,=H'+2'              BACK TO LENGTH                   12430000
         LH    R1,0(,R14)              GET LENGTH                       12440000
         BCTR  R1,0                    MAKE MACHINE LENGTH              12450000
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE          12460000
         BAL   R9,PRINT                PRINT A LINE                     12470000
         MVI   0(R2),C'*'              MARK WHERE ERROR IS              12480000
         BAL   R9,PRINT                PRINT A LINE                     12490000
         MVC   PRT(15),=C'Parameter error'                              12500000
         LA    R12,1                   SET ERROR CODE                04 12510003
         B     ERREND                  GO PRINT                         12520000
PRMMVC   MVC   PRT+5(0),2(R14)         EXECUTED PARM MOVE               12530000
NOMBR    DS    0H                                                       12540000
         MVC   PRT(25),=C'Member name not specified'                    12550000
         LA    R12,2                   SET ERROR CODE                04 12560003
         B     ERREND                  GO PRINT                         12570000
OPENERR  DS    0H                                                    04 12580003
         MVC   PRT(15),=C'OPEN failed for'                           04 12590003
         MVC   PRT+16(8),LIBDDN        LIBRARY DD NAME               04 12600003
         BAL   R9,PRINT                GO PRINT MESSAGE              04 12610003
         LA    R12,3                   SET ERROR CODE                04 12620003
         LA    R2,16                   SET RETURN CODE TO 16         04 12630003
         B     CLOSES                  YES, STOP THE RUN             04 12640003
RDJFERR  DS    0H                                                    04 12650003
         MVC   PRT(17),=C'RDJFCB failed for'                         04 12660003
         MVC   PRT+18(8),LIBDDN        LIBRARY DD NAME               04 12670003
         BAL   R9,PRINT                GO PRINT MESSAGE              04 12680003
         LA    R12,4                   SET ERROR CODE                04 12690003
         LA    R2,16                   SET RETURN CODE TO 16         04 12700003
         B     CLOSES                  YES, STOP THE RUN             04 12710003
MISSMEM  DS    0H                                                       12720000
         MVC   PRT(8),MEMBER           LOAD MODULE NAME                 12730000
         MVC   PRT+9(12),=C'not found in'                               12740000
         MVC   PRT+22(8),LIBDDN        LIBRARY DD NAME                  12750000
         LA    R12,5                   SET ERROR CODE                04 12760003
         B     ERREND                  GO PRINT                         12770000
MISSCSEF DS    0H                                                    08 12780008
         MVC   PRT+32(5),=C'(EOF)'                                   08 12790008
MISSCS   DS    0H                                                       12800000
         MVC   PRT(8),CSECT            CSECT NAME                       12810000
         MVC   PRT+9(12),=C'not found in'                               12820000
         MVC   PRT+22(8),MEMBER        LOAD MODULE NAME                 12830000
         LA    R12,6                   SET ERROR CODE                04 12840003
         B     ERREND                  GO PRINT                         12850000
SYMFULL  DS    0H                                                       12860000
         MVC   PRT(36),=C'Symbol table full: over 5000 entries'         12870000
         LA    R12,7                   SET ERROR CODE                04 12880003
         B     ERREND                  GO PRINT                         12890000
RLDFULL  DS    0H                                                       12900000
         MVC   PRT(33),=C'RLD table full: over 3000 entries'            12910000
         LA    R12,8                   SET ERROR CODE                04 12920003
ERREND   DS    0H                                                       12930000
         BAL   R9,PRINT                GO PRINT MESSAGE                 12940000
         TM    PRMOPT,PRMOPTDB         ** DEBUG on                   08 12950008
         BNO   ERRDONE                  *                            08 12960008
         BAL   R9,PRINT                 *                            08 12970008
         MVC   PRT(7),=C'WORK at'       *                            08 12980008
         ST    R13,W#SAVER9             *                            08 12990008
         UNPK  PRT+8(9),W#SAVER9(5)     *                            08 13000008
         TR    PRT+8(8),TRTBL-240       *                            08 13010008
         MVI   PRT+16,C' '              *                            08 13020008
         BAL   R9,PRINTSM               *                            08 13030008
         LR    R1,R13                   *                            08 13040008
         LA    R0,WORKLEN               *                            08 13050008
         BAL   R14,DMP                  *                            08 13060008
ERRDONE  DS    0H                      **                            08 13070008
         LA    R2,8                    SET RETURN CODE TO 8             13080000
         B     CLOSES                  YES, STOP THE RUN                13090000
****************************************************************        13100000
*                                                              *        13110000
* COUNT THE ENTRIES IN THE ESD TABLE WHICH WILL RESULT IN      *        13120000
* ENTRIES IN THE LABEL TABLE.                                  *        13130000
*                                                              *        13140000
****************************************************************        13150000
ENDINIT  DS    0H                                                       13160000
         L     R6,SYMTBAD              GET ADDRESS OF ESD TABLE         13170000
         USING SYMTBL,R6                                                13180000
         LA    R7,4                    INITIAL LABEL COUNT VALUE        13190000
SYMCNT   DS    0H                                                       13200000
         CLI   0(R6),X'FF'             END OF ESD TBL                   13210000
         BE    RLDCNT                  YES                              13220000
         CLI   TYPSYM,3                IS ESD AN LR ENTRY               13230000
         BNE   SCSTP                   NO, IGNORE                       13240000
         CLC   SYMADDR,START+1         ADDR BELOW DESIRED CSECT         13250000
         BL    SCSTP                   YES, IGNORE                      13260000
         CLC   SYMADDR,END+1           ADDR ABOVE DESIRED CSECT         13270000
         BH    SCSTP                   YES, IGNORE                      13280000
         LA    R7,1(,R7)               ADD TO LABEL COUNT               13290000
         MVC   SYMLENG,=C'***'         FLAG AS USEABLE                  13300000
SCSTP    DS    0H                                                       13310000
         LA    R6,L'SYMENT(,R6)        TO NEXT ESD ENTRY                13320000
         B     SYMCNT                  PROCESS NEXT ESD ENTRY           13330000
         DROP  R6                                                       13340000
****************************************************************        13350000
*                                                              *        13360000
* COUNT THE ENTRIES IN THE RLD TABLE WHICH WILL RESULT IN      *        13370000
* ENTRIES IN THE LABEL TABLE.                                  *        13380000
*                                                              *        13390000
****************************************************************        13400000
RLDCNT   DS    0H                                                       13410000
         L     R6,RLDTBL               GET RLD TBL ADDR                 13420000
         USING RLDTBLD,R6                                               13430000
RLDCEND  DS    0H                                                       13440000
         CLI   0(R6),X'FF'             END OF RLD TABLE                 13450000
         BE    LBLGET                  YES                              13460000
         CLC   RLDRP,ESDID             ESDID SAME AS DESIRED CSECT      13470000
         BNE   RLDC1                   NO, EXTRN REF                    13480000
         LA    R7,1(,R7)               ADD 1 TO LABEL COUNT             13490000
RLDC1    DS    0H                                                       13500000
         LA    R7,1(,R7)               ADD 1 TO LABEL COUNT             13510000
         LA    R6,L'RLDENT(,R6)        TO NEXT RLD ENTRY                13520000
         B     RLDCEND                 LOOP THRU RLD TBL                13530000
         DROP  R6                                                       13540000
LBLGET   DS    0H                                                       13550000
         MH    R7,=AL2(L'LABEL)        COMPUTE LABEL TABLE SIZE         13560000
         L     R1,LENGTH               GET CSECT LENGTH                 13570000
         SRL   R1,2                    DIVIDE BY 4                      13580000
         MH    R1,=AL2(L'LABEL)        TIMES LABEL ENTRY LENGTH         13590000
         AR    R7,R1                   TOTAL LABEL TABLE LENGTH         13600000
         ST    R7,LBLTBLEN             SAVE LABEL TABLE LENGTH          13610000
****************************************************************        13620000
*                                                              *        13630000
* CREATE INITIAL ENTRIES IN THE LABEL TABLE USING DATA FROM    *        13640000
* THE ESD AND RLD TABLES.                                      *        13650000
*                                                              *        13660000
****************************************************************        13670000
         GETMAIN R,LV=(7)              GET LABEL TBL STORAGE            13680000
         ST    R1,LBLTBL               SAVE LABEL TBL ADDR              13690000
         ST    R1,CURRLBL              SAVE CURRENT LABEL ADDR          13700000
         AR    R1,R7                   COMPUTE LABEL TBL END ADDR       13710000
         ST    R1,ENDLBL               SAVE END OF LBL TBL ADDR         13720000
         L     R6,LBLTBL               GET ADDRESS OF LABEL TABLE       13730000
         USING LABELD,R6                                                13740000
         L     R7,SYMTBAD              GET ESD TBL ADDR                 13750000
         USING SYMTBL,R7                                                13760000
         OC    LKEPA,LKEPA             EPA ZERO                         13770000
         BE    LRENTS                  YES                              13780000
         SR    R1,R1                   CLEAR WORK                       13790000
         ICM   R1,7,LKEPA              PICK UP E.P. ADDR                13800000
         S     R1,START                RELATIVIZE IN CSECT              13810000
         BM    LRENTS                  NEG, ERROR                       13820000
         STCM  R1,7,LBLADR             SAVE OFFSET                      13830000
         MVI   LBLTYP,C'L'             SET LABEL TYPE IN ENTRY          13840000
         LA    R12,LBLADR              POINT TO OFFSET                  13850000
         BAL   R9,HEXPRT3              CONVERT TO PRINTABLE             13860000
         MVI   LBLNAME,C'A'            1ST CHAR OF LABEL IS 'A'         13870000
         MVC   LBLNAME+1(6),PRTABL     END OF LABEL IS OFFSET           13880000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              13890000
         ST    R6,CURRLBL              SAVE IT'S ADDRESS                13900000
LRENTS   DS    0H                                                       13910000
         CLI   0(R7),X'FF'             END OF ESD TBL                   13920000
         BE    RLDLBLS                 YES                              13930000
         CLC   SYMLENG,=C'***'         THIS DESIRED LR ENTRY            13940000
         BE    GOTLR                   YES                              13950000
LRESTP   DS    0H                                                       13960000
         LA    R7,L'SYMENT(,R7)        TO NEXT ESD ENTRY                13970000
         B     LRENTS                  LOOP THRU ESD TBL                13980000
GOTLR    DS    0H                                                       13990000
         SR    R12,R12                 CLEAR WORK REG                   14000000
         ICM   R12,7,SYMADDR           GET SYMBOL ADDR                  14010000
         S     R12,START               RELATIVIZE IN CSECT              14020000
         STCM  R12,7,LBLADR            SAVE RELATIVE ADDR               14030000
         MVC   LBLNAME,EXTSYM          SYMBOL NAME TO OUTPUT            14040000
         MVI   LBLTYP,C'L'             SHOW LABEL ENTRY                 14050000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL ENTRY              14060000
         ST    R6,CURRLBL              SAVE NEXT LABEL ENTRY ADDR       14070000
         B     LRESTP                  CONTINUE ESD PROCESSING          14080000
         DROP  R7                                                       14090000
RLDLBLS  DS    0H                                                       14100000
         L     R7,RLDTBL               GET RLD TBL ADDR                 14110000
         USING RLDTBLD,R7                                               14120000
RLDLBND  DS    0H                                                       14130000
         CLI   0(R7),X'FF'             END OF RLD TABLE                 14140000
         BE    PHASE1                  YES                              14150000
         CLC   RLDRP,ESDID             RLD ESDID = DESIRED CSECT ESDID  14160000
         BE    INTREFS                 YES, INTERNAL ADCON              14170000
         CLI   RLDTYPE,1               VCON                             14180000
         BE    EXTREFS                 YES                              14190000
         CLI   RLDTYPE,8               IS IT UNRESOLVED                 14200000
         BE    EXTREFS                 YES                              14210000
RLLSTP   DS    0H                                                       14220000
         LA    R7,L'RLDENT(R7)         TO NEXT RLD ENTRY                14230000
         B     RLDLBND                 LOOP THRU RLD TABLE              14240000
EXTREFS  DS    0H                                                       14250000
         CLI   RLDESDTP,X'0A'          W-CON                            14260000
         BNE   VCONLBL                 NO, BUILD V-CON                  14270000
         MVI   LBLTYP,C'W'             SHOW W-CON                       14280000
         B     FXTLBL                  CONTINUE LABEL ENTRY FORMAT      14290000
VCONLBL  DS    0H                                                       14300000
         MVI   LBLTYP,C'V'             SHOW V-CON                       14310000
FXTLBL   DS    0H                                                       14320000
         MVC   LBLNAME,RLDNAME         NAME TO LABEL ENTRY              14330000
FINLBL   DS    0H                                                       14340000
         MVC   LBLADR,RLDADDR          ADDRESS TO LABEL ENTRY           14350000
         MVC   LBLLEN,RLDLEN           LENGTH TO LABEL ENTRY            14360000
         LA    R6,L'LABEL(,R6)         TO NEXT LABEL TBL ENTRY          14370000
         ST    R6,CURRLBL              SAVE CURRENT LABEL TBL ADDR      14380000
         B     RLLSTP                  CONTINUE LABEL TABLE BUILD       14390000
INTREFS  DS    0H                                                       14400000
         CLI   RLDTYPE,0               A-CON                            14410000
         BNE   RLLSTP                  NO, IGNORE                       14420000
         MVI   LBLTYP,C'L'             SHOW LABEL ENTRY TYPE            14430000
         SR    R12,R12                 CLEAR WORK REG                   14440000
         ICM   R12,7,RLDADDR           GET RLD ADDR                     14450000
         A     R12,TXTSTRT             FIND LOC IN TEXT                 14460000
         MVC   LBLADR,1(R12)           MOVE TO LABEL ENTRY              14470000
         CLI   RLDLEN,4                ADCON IS 4-BYTES                 14480000
         BE    INTGOTL                 YES                              14490000
         MVC   LBLADR,0(R12)           TEXT TO LABEL ENTRY              14500000
         CLI   RLDLEN,3                ADCON IS 3-BYTES                 14510000
         BE    INTGOTL                 YES                              14520000
         MVC   LBLADR+1(2),0(R12)      TEXT TO LABEL ENTRY              14530000
         MVI   LBLADR,0                CLEAR 1ST BYTE                   14540000
         CLI   RLDLEN,2                ADCON IS 2-BYTES                 14550000
         BE    INTGOTL                 YES                              14560000
         XC    LBLADR,LBLADR           CLEAR LABEL ENTRY ADDR           14570000
         MVC   LBLADR+2(1),0(R12)      TEXT TO LABEL ENTRY              14580000
INTGOTL  DS    0H                                                       14590000
         SR    R12,R12                 CLEAR WORK                       14600000
         ICM   R12,7,LBLADR            GET ADDRESS                      14610000
         S     R12,START               RELATIVIZE IN CSECT              14620000
         BM    RLLSTP                  NEGATIVE, IGNORE                 14630000
         STCM  R12,7,LBLADR            STORE RELATIVE ADDRESS           14640000
         LA    R12,LBLADR              POINT TO ADDRESS                 14650000
         BAL   R9,HEXPRT3              CONVERT TO PRINTABLE             14660000
         MVI   LBLNAME,C'A'            SET LABEL ENTRY TYPE             14670000
         MVC   LBLNAME+1(6),PRTABL     LOW ORDER NAME POSITIONS         14680000
         MVI   LBLNAME+7,C' '          CLEAR LAST NAME BYTE             14690000
         MVC   L'LABEL(L'LABEL,R6),0(R6) COPY THIS ENTRY TO NEXT        14700000
         MVI   LBLLEN,0                SET LENGTH = 0                   14710000
         LA    R6,L'LABEL(,R6)         STEP TO NEXT                     14720000
         MVI   LBLTYP,C'A'             SHOW TYPE                        14730000
         B     FINLBL                  FINISH LABEL                     14740000
         DROP  R6                                                       14750000
         DROP  R7                                                       14760000
****************************************************************        14770000
*                                                              *        14780000
* PRINT THE LABEL TABLE                                        *        14790000
*                                                              *        14800000
****************************************************************        14810000
PHASE1   DS    0H                                                       14820000
         MVC   0(3,R6),=3X'FF'         SET END OF LABEL TABLE           14830000
         MVC   PRT(11),=C'Label Table'                                  14840000
         BAL   R9,PRINTSM              PRINT IT                         14850000
         MVC   PRT(L'LBLHDR),LBLHDR    LABEL HEADER                     14860000
         BAL   R9,PRINTSM              PRINT IT                         14870000
         L     R6,LBLTBL               GET LABEL TABLE ADDR             14880000
         USING LABELD,R6                                                14890000
LPEND    DS    0H                                                       14900000
         C     R6,CURRLBL              END OF TABLE                     14910000
         BNL   RLDZR                   YES                           02 14920001
         LA    R12,LBLADR              ADDRESS OF LABEL ADDRESS         14930000
         BAL   R9,HEXPRT3              CONVERT                          14940000
         MVC   PRT+6(6),PRTABL         ADDRESS TO PRINT                 14950000
         MVC   PRT+16(1),LBLTYP        TYPE TO PRINT                    14960000
         MVC   PRT+18(8),LBLNAME       SYMBOL TO PRINT                  14970000
         CLI   LBLLEN,0                ANY LENGTH                       14980000
         BE    LTPPRT                  NO                               14990000
         LA    R12,LBLLEN              GET ADDRESS OF LENGTH            15000000
         BAL   R9,HEXPRT1              CONVERT                          15010000
         MVC   PRT+28(2),PRTABL        LENGTH TO PRINT                  15020000
LTPPRT   DS    0H                                                       15030000
         BAL   R9,PRINTSM              PRINT TBL ENTRY                  15040000
         LA    R6,L'LABEL(,R6)         TO NEXT ENTRY                    15050000
         B     LPEND                   LOOP THRU TABLE                  15060000
         DROP  R6                                                    05 15070005
****************************************************************     02 15080001
*                                                              *     02 15090001
* ZERO ANY RELOCATABLE CONSTANTS IF REQUESTED                  *     02 15100001
*                                                              *     02 15110001
****************************************************************     02 15120001
RLDZR    DS    0H                                                    02 15130001
         TM    PRMOPT,PRMOPTZR         ZERO RELOCATABLES             02 15140001
         BNO   LBLZR090                NO, LEAVE THEM ASIS           05 15150005
         L     R7,RLDTBL               ADDRESS OF RLD TABLE          02 15160001
         USING RLDTBLD,R7                                            02 15170001
RLDZR010 DS    0H                                                    02 15180001
         C     R7,CURRLD               END OF RLD TABLE              02 15190001
         BNL   RLDZR090                YES, DONE                     02 15200001
         CLI   RLDTYPE,0               IS IT ADCON                   02 15210001
         BE    RLDZR020                YES                           02 15220001
         CLI   RLDTYPE,1               IS IT VCON                    02 15230001
         BE    RLDZR020                YES                           02 15240001
         CLI   RLDTYPE,8               IS IT UNRESOLVED              02 15250001
         BE    RLDZR020                YES, CLEAR IT ANYWAY          02 15260001
         B     RLDZR030                NEXT RLD ENTRY                02 15270001
RLDZR020 DS    0H                                                    02 15280001
         SR    R1,R1                   CLEAR FOR ADDRESS             02 15290001
         ICM   R1,7,RLDADDR            OFFSET OF RELOCATABLE ADCON   02 15300001
         A     R1,TXTSTRT              ADD TEXT START ADDRESS        02 15310001
         ICM   R15,1,RLDLEN            ADCON LENGTH                  02 15320001
         BZ    RLDZR030                IGNORE ZERO LEN IF ANY        02 15330001
         BCTR  R15,0                   MACHINE LENGTH                02 15340001
         EX    R15,RLDZRXC             CLEAR ADCON                   02 15350001
RLDZR030 DS    0H                                                    02 15360001
         LA    R7,L'RLDENT(,R7)        TO NEXT TBL ENTRY             02 15370001
         B     RLDZR010                PROCESS NEXT ENTRY            02 15380001
RLDZRXC  XC    0(,R1),0(R1)            <<< EXECUTED >>>              02 15390001
RLDZR090 DS    0H                                                    02 15400001
         DROP  R7                                                    02 15410001
****************************************************************     05 15420005
*                                                              *     05 15430005
* ZERO ANY VCON TYPE LABELS                                    *     05 15440005
*                                                              *     05 15450005
****************************************************************     05 15460005
         L     R7,LBLTBL               GET LABEL TABLE ADDR          05 15470005
         USING LABELD,R7                                             05 15480005
LBLZR010 DS    0H                                                    05 15490005
         C     R7,CURRLBL              END OF TABLE                  05 15500005
         BNL   LBLZR090                YES, DONE WITH CLEARING       05 15510005
         CLI   LBLTYP,C'V'             TYPE VCON?                    05 15520005
         BNE   LBLZR020                NO, SKIP IT                   05 15530005
         SR    R1,R1                   CLEAR FOR ADDRESS             05 15540005
         ICM   R1,7,LBLADR             OFFSET OF LABEL               05 15550005
         A     R1,TXTSTRT              ADD TEXT START ADDRESS        05 15560005
         ICM   R15,1,LBLLEN            GET LENGTH                    05 15570005
         BZ    LBLZR020                IGNORE ZERO LEN IF ANY        05 15580005
         BCTR  R15,0                   MACHINE LENGTH                05 15590005
         EX    R15,RLDZRXC             CLEAR ADCON                   05 15600005
LBLZR020 DS    0H                                                    05 15610005
         LA    R7,L'LABEL(,R7)         TO NEXT ENTRY                 05 15620005
         B     LBLZR010                LOOP THRU TABLE               05 15630005
         DROP  R7                                                    05 15640005
LBLZR090 DS    0H                                                    05 15650005
****************************************************************     05 15660005
*                                                              *     05 15670005
* FREE WORK AREAS                                              *     05 15680005
*                                                              *     05 15690005
****************************************************************     05 15700005
FREESTRG DS    0H                                                       15710000
         L     R12,RLDTBL              ADDRESS OF RLD TABLE             15720000
         FREEMAIN R,A=(12),LV=60000    FREE RLD TABLE                   15730000
         L     R0,LBLTBLEN             LABEL TABLE LENGTH               15740000
         L     R1,LBLTBL               LABEL TABLE ADDRESS              15750000
         FREEMAIN R,A=(1),LV=(0)       FREE LABEL TABLE                 15760000
         L     R1,BUFAD                GET BUFFER ADDRESS               15770000
         FREEMAIN R,A=(1),LV=32768     FREE BUFFER                      15780000
****************************************************************        15790000
*                                                              *        15800000
* PRINT THE TEXT FOR THE CSECT SELECTED                        *        15810000
*                                                              *        15820000
****************************************************************        15830000
         MVC   PRT(14),=C'Text for CSECT'                               15840000
         MVC   PRT+15(8),CSECT         CSECT NAME                       15850000
         MVC   PRT+24(9),=C'length of'                                  15860000
         L     R12,TXTSTRT             GET TEXT START ADDRESS           15870000
         SH    R12,=H'+4'              BACK TO LENGTH                   15880000
         BAL   R9,HEXPRT4              CONVERT                          15890000
         MVC   PRT+34(8),PRTABL        LENGTH TO PRINT                  15900000
         MVC   PRT+43(2),=C'at'                                         15910000
         LA    R12,TXTSTRT             GET TEXT START ADDRESS           15920000
         BAL   R9,HEXPRT4              CONVERT                          15930000
         MVC   PRT+46(8),PRTABL        LENGTH TO PRINT                  15940000
         BAL   R9,PRINTSM              PRINT TEXT HEADER                15950000
         L     R11,TXTSTRT             GET TEXT START ADDRESS           15960000
PNEXLIN  DS    0H                                                       15970000
         LA    R10,2                   GROUPS PER LINE                  15980000
         LA    R12,POFSET+1            ADDRESS OF OFFSET                15990000
         BAL   R9,HEXPRT3              CONVERT                          16000000
         MVC   PRT(6),PRTABL           OFFSET TO PRINT                  16010000
         MVC   PRT+85(32),0(R11)       TEXT TO PRINT                    16020000
         TR    PRT+85(32),PRTCHAR      TRANSLATE TO PRINTABLE           16030000
         LA    R8,PRT+9                ADDRESS OF 1ST PRINT WORD        16040000
         LA    R7,4                    4 WORDS PER GROUP                16050000
PGRP     DS    0H                                                       16060000
         LA    R12,0(,R11)             ADDRESS OF TEXT WORD             16070000
         BAL   R9,HEXPRT4              CONVERT                          16080000
         MVC   0(8,R8),PRTABL          TEXT TO PRINT WORD               16090000
         LA    R11,4(,R11)             TO NEXT TEXT WORD                16100000
         LA    R8,9(,R8)               TO NEXT PRINT LOC                16110000
         BCT   R7,PGRP                 DO 4 TIMES                       16120000
         LA    R8,2(,R8)               SPACE BETWEEN GROUPS             16130000
         LA    R7,4                    FOR 2ND GROUP                    16140000
         BCT   R10,PGRP                DO 4 MORE TIMES                  16150000
         BAL   R9,PRINTSM              PRINT THE LINE                   16160000
         L     R9,POFSET               GET OFFSET                       16170000
         LA    R9,32(,R9)              ADD 32 BYTES                     16180000
         ST    R9,POFSET               UPDATE OFFSET                    16190000
         C     R11,TXTEND              END OF TEXT                      16200000
         BL    PNEXLIN                 NO, CONTINUE                     16210000
****************************************************************        16220000
*                                                              *        16230000
* CREATE THE INITIAL CSECT INSTRUCTION, AND ANY ENTRY STATE-   *        16240000
* MENTS WHICH MAY BE INDICATED BY ESD TABLE ENTRIES.           *        16250000
*                                                              *        16260000
****************************************************************        16270000
         L     R7,SYMTBAD              GET ESD TBL ADDR                 16280000
         USING SYMTBL,R7                                                16290000
LREFSS   DS    0H                                                       16300000
         CLI   0(R7),X'FF'             END OF ESD TBL                   16310000
         BE    CKLDLB                  YES                              16320000
         CLC   SYMLENG,=C'***'         THIS DESIRED LR ENTRY            16330000
         BE    MAKEXT                  YES                              16340000
ESDTSTP  DS    0H                                                       16350000
         LA    R7,L'SYMENT(,R7)        TO NEXT ESD ENTRY                16360000
         B     LREFSS                  LOOP THRU ESD TBL                16370000
MAKEXT   DS    0H                                                       16380000
         B     ESDTSTP                 CONTINUE ESD PROCESSING          16390000
         DROP  R7                                                       16400000
CKLDLB   DS    0H                                                       16410000
         L     R12,SYMTBAD             ADDRESS OF ESD SYMBOL TABLE      16420000
         FREEMAIN R,A=(12),LV=95000    FREE SYMBOL TABLE                16430000
****************************************************************        16440000
*                                                              *        16450000
*        END OF PROCESSING                                     *        16460000
*                                                              *        16470000
****************************************************************        16480000
         L     R3,START                GET OFFSET IN MODULE          07 16490007
         L     R12,TXTSTRT             GET TEXT BUFFER                  16500000
         SH    R12,=H'+8'              BACK TO LENGTHS                  16510000
         SR    R2,R2                   RETURN CODE 0                    16520000
CLOSES   DS    0H                                                       16530000
         CLOSE (SYSLIB),MF=(E,OPENLIST) CLOSE LIBRARY                   16540000
         TM    SYSLIB+23,1             BUFFER POOL FREED                16550000
         BO    CLOSES10                YES, SKIP FREEPOOL               16560000
         FREEPOOL SYSLIB               RELEASE BUFFERS                  16570000
CLOSES10 DS    0H                                                       16580000
         TM    PRINTDD+48,16           IS PRINTDD OPEN                  16590000
         BNO   SKPCLS                  NO                               16600000
         CLOSE (PRINTDD),MF=(E,OPENLIST) CLOSE PRINTDD                  16610000
         TM    PRINTDD+23,1            BUFFER POOL FREED                16620000
         BO    SKPCLS                  YES, SKIP FREEPOOL               16630000
         FREEPOOL PRINTDD              RELEASE BUFFERS                  16640000
SKPCLS   DS    0H                                                       16650000
         LR    R11,R13                 WORK AREA ADDRESS                16660000
         L     R13,4(,R13)             GET CALLER'S SAVE AREA           16670000
         FREEMAIN R,A=(11),LV=WORKLEN  FREE WORK ARA                    16680000
         L     R14,12(,R13)            RESTORE CALLER'S R14             16690000
         LR    R15,R2                  SET RETURN CODE IN R15           16700000
         LR    R0,R3                   PASS OFFSET IN MODULE         07 16710007
         LR    R1,R12                  PASS BACK TEXT BUFFER IN R1      16720000
         LM    R2,R12,28(R13)          RESTORE CALLER'S R2-R12          16730000
         BR    R14                     RETURN TO CALLER                 16740000
******************************************************************** 08 16750008
*                                                                  * 08 16760008
*        DUMP DATA                                                 * 08 16770008
*              INPUT: REG 0  = LENGTH OF DATA TO DUMP              * 08 16780008
*                     REG 1  = ADDRESS OF DATA TO DUMP             * 08 16790008
*                                                                  * 08 16800008
******************************************************************** 08 16810008
DMP      DS    0H                                                    08 16820008
         STM   R0,R15,W#DMPRGS         Save registers                08 16830008
         LR    R7,R1                   Get address to dump           08 16840008
         LR    R8,R0                   Get length                    08 16850008
         XC    W#DMPOFF,W#DMPOFF       Save offset for dump          08 16860008
         MVI   W#DMPFLG,W#DMP1ST       First line                    08 16870008
DMPDMPLP DS    0H                                                    08 16880008
         LTR   R8,R8                   Any data to dump?             08 16890008
         BZ    DMPHEXXT                Yes, all done                 08 16900008
         TM    W#DMPFLG,W#DMP1ST       First line?                   08 16910008
         BO    DMPALIN                 Yes, can't have same as above 08 16920008
         LA    R0,32                   Default length                08 16930008
         CR    R8,R0                   Length longer than 32?        08 16940008
         BNH   DMPDUPCK                No, were at last line         08 16950008
         LR    R14,R7                  Get current input area        08 16960008
         SR    R14,R0                  Back to previous area         08 16970008
         CLC   0(32,R14),0(R7)         Duplicate of previous line    08 16980008
         BNE   DMPDUPCK                No, do lines same as          08 16990008
         SR    R8,R0                   Reduce length to do           08 17000008
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?        08 17010008
         BO    DMPNXTLN                Yes, we have first offset     08 17020008
         L     R14,W#DMPOFF            Get current offset            08 17030008
         ST    R14,W#DUP1ST            Save as first offset          08 17040008
         OI    W#DMPFLG,W#DMPDUP       Set duplicate                 08 17050008
         B     DMPNXTLN                Continue                      08 17060008
DMPDUPCK DS    0H                                                    08 17070008
         TM    W#DMPFLG,W#DMPDUP       Duplicate in progress?        08 17080008
         BNO   DMPALIN                 No, no duplicate to report    08 17090008
         MVC   PRT+7(5),=C'lines'      Move literal                  08 17100008
         LA    R2,PRT+13               Output area address           08 17110008
         LA    R1,W#DUP1ST+2           Address of offset to dump     08 17120008
         LA    R15,2                   Convert 4 bytes               08 17130008
         BAL   R14,DMPDSP              Convert it to display         08 17140008
         MVI   PRT+17,C'-'             Thru literal                  08 17150008
         L     R1,W#DMPOFF             Get current offset            08 17160008
         S     R1,=A(32)               Get last duplicate offset     08 17170008
         ST    R1,W#DUP1ST             Save for dumping              08 17180008
         LA    R2,PRT+18               Output area address           08 17190008
         LA    R1,W#DUP1ST+2           Address of offset to dump     08 17200008
         LA    R15,2                   Convert 4 bytes               08 17210008
         BAL   R14,DMPDSP              Convert it to display         08 17220008
         MVC   PRT+23(13),=C'same as above' move literal             08 17230008
         BAL   R9,PRINTSM              Print a line                  08 17240008
         NI    W#DMPFLG,255-W#DMPDUP   Reset duplicate in progress   08 17250008
DMPALIN  DS    0H                                                    08 17260008
         LA    R2,PRT+1                Output area address           08 17270008
         LA    R1,W#DMPOFF+2           Address of offset to dump     08 17280008
         LA    R15,2                   Convert 4 bytes               08 17290008
         BAL   R14,DMPDSP              Convert it to display         08 17300008
         LA    R2,2(,R2)               Skip 1 between offset & data  08 17310008
         LR    R1,R7                   Address of data               08 17320008
         LA    R5,32                   Default length                08 17330008
         CR    R8,R5                   Length longer than 32 ?       08 17340008
         BH    DMPDODMP                Yes, use 32                   08 17350008
         LR    R5,R8                   Use what is left              08 17360008
DMPDODMP DS    0H                                                    08 17370008
         SR    R8,R5                   Reduce amount to do           08 17380008
         MVI   PRT+80,C'*'             Box in display portion        08 17390008
         BCTR  R5,0                    Make zero based               08 17400008
         EX    R5,DMPMVC               Do move                       08 17410008
         EX    R5,DMPTR                Translate out bad stuff       08 17420008
         LA    R5,1(,R5)               Restore length                08 17430008
         LA    R15,PRT+81(R5)                                        08 17440008
         MVI   0(R15),C'*'             Complete box                  08 17450008
DMPDMPHX DS    0H                                                    08 17460008
         LA    R15,4                   4 bytes to process            08 17470008
         CR    R5,R15                  Length longer than 4?         08 17480008
         BH    DMPDMPIT                Yes, dump 4 bytes             08 17490008
         LR    R15,R5                  Use length left               08 17500008
DMPDMPIT DS    0H                                                    08 17510008
         SR    R5,R15                  Reduce amount to do           08 17520008
         BAL   R14,DMPDSP              Convert data                  08 17530008
         LA    R2,1(,R2)               Skip 1 byte                   08 17540008
         LA    R0,PRT+43               Halfway point address         08 17550008
         CR    R0,R2                   At halfway point?             08 17560008
         BNE   DMPDMPNX                No, continue                  08 17570008
         LA    R2,1(,R2)               Skip 1 byte                   08 17580008
DMPDMPNX DS    0H                                                    08 17590008
         LTR   R5,R5                   Any left to do ?              08 17600008
         BH    DMPDMPHX                Yes, go do it                 08 17610008
         BAL   R9,PRINTSM              Print a line                  08 17620008
DMPNXTLN DS    0H                                                    08 17630008
         L     R1,W#DMPOFF             Get offset in record          08 17640008
         LA    R1,32(,R1)              Add in length we will dump    08 17650008
         ST    R1,W#DMPOFF             Save offset in record         08 17660008
         LA    R7,32(,R7)              Next input area               08 17670008
         NI    W#DMPFLG,255-W#DMP1ST   Not first line                08 17680008
         B     DMPDMPLP                Loop thru until done          08 17690008
DMPHEXXT DS    0H                                                    08 17700008
         LM    R0,R15,W#DMPRGS         Restore callers regs          08 17710008
         BR    R14                     Exit . . .                    08 17720008
DMPMVC   MVC   PRT+81(0),0(R1)         <<< executed >>>              08 17730008
DMPTR    TR    PRT+81(0),PRTCHAR       <<< executed >>>              08 17740008
*                                                                    08 17750008
*        Convert hex data to display                                 08 17760008
*                                                                    08 17770008
DMPDSP   DS    0H                                                    08 17780008
         UNPK  0(1,R2),0(1,R1)         Get first hex byte            08 17790008
         NI    0(R2),X'0F'             Remove zone                   08 17800008
         MVC   1(1,R2),0(R1)           Move second hex byte          08 17810008
         NI    1(R2),X'0F'             Remove its zone also          08 17820008
         TR    0(2,R2),=C'0123456789ABCDEF' Translate to hex         08 17830008
         LA    R2,2(,R2)               Point to next output area     08 17840008
         LA    R1,1(,R1)               Point to next input area      08 17850008
         BCT   R15,DMPDSP              Loop thru data                08 17860008
         BR    R14                     Exit                          08 17870008
****************************************************************        17880000
*                                                              *        17890000
*        CONSTANTS                                             *        17900000
*                                                              *        17910000
****************************************************************        17920000
         DC    0D'+0'                                                   17930000
         LTORG ,                                                        17940000
SYMHDR   DC    C'      Symbol        Type Ind Address  Seg  Lrid  Lengt*17950000
               h ESDID'                                                 17960000
RLDHDR   DC    C'      Relptr Posptr     Type  Length    Dir  Address  *17970000
                         Name Type'                                     17980000
LBLHDR   DC    C'     Address Type Symbol   Len'                        17990000
*                                                                       18000000
BLANX    DC    CL121' '                CONSTANT BLANKS                  18010000
TRTBL    DC    C'0123456789ABCDEF'     TRANSLATE TBL                    18020000
PRTCHAR  DC    CL256' '                                                 18030000
         ORG   PRTCHAR+X'4A'           Cent                             18040000
         DC    X'4A4B4C4D4E4F50'                                        18050000
         ORG   PRTCHAR+X'5A'           Exclamation                      18060000
         DC    X'5A5B5C5D5E5F6061'                                      18070000
         ORG   PRTCHAR+X'6A'                                            18080000
         DC    X'6A6B6C6D6E6F'                                          18090000
         ORG   PRTCHAR+X'7A'                                            18100000
         DC    X'7A7B7C7D7E7F'                                          18110000
         ORG   PRTCHAR+C'a'                                             18120000
         DC    C'abcdefghi'                                             18130000
         ORG   PRTCHAR+C'j'                                             18140000
         DC    C'jklmnopqr'                                             18150000
         ORG   PRTCHAR+C's'                                             18160000
         DC    C'stuvwxyz'                                              18170000
         ORG   PRTCHAR+C'A'                                             18180000
         DC    C'ABCDEFGHI'                                             18190000
         ORG   PRTCHAR+C'J'                                             18200000
         DC    C'JKLMNOPQR'                                             18210000
         ORG   PRTCHAR+C'S'                                             18220000
         DC    C'STUVWXYZ'                                              18230000
         ORG   PRTCHAR+C'0'                                             18240000
         DC    C'0123456789'                                            18250000
         ORG   ,                                                        18260000
LIBMDL   DCB   DSORG=PO,MACRF=R,DDNAME=SYSLIB,EXLST=*-*,             03X18270002
               RECFM=U,NCP=1,EODAD=MISSCSEF                          04 18280008
PRINTMDL DCB   DSORG=PS,MACRF=PM,DDNAME=PRINTDD,                       X18290000
               RECFM=FBA,LRECL=121                                      18300000
OPNMDL   OPEN  (0),MF=L                                                 18310000
         DC    0D'+0'                                                   18320000
****************************************************************        18330000
*                                                              *        18340000
*        WORK AREAS                                            *        18350000
*                                                              *        18360000
****************************************************************        18370000
WORKAREA DSECT ,                                                        18380000
SAVEAREA DC    18A(0)                                                   18390000
PRMSTRT  DC    F'0'                    PARAMETER ADDRESS                18400000
CSECT    DC    CL8' '                  SPECIFIED CSECT NAME             18410000
ESDID    DC    X'0001'                 ESD ID OF SPECIFIED CSECT        18420000
LINECT   DC    PL2'0'                  PRINT LINE COUNTER               18430000
START    DC    F'0'                    LKED ASSIGNED START ADDR OF CSEC 18440000
END      DC    F'0'                    CSECT END ADDRESS                18450000
LENGTH   DC    F'0'                    LENGTH OF SPECIFIED CSECT        18460000
LBLTBLEN DC    F'0'                    LABEL TABLE LENGTH               18470000
LBLTBL   DC    F'0'                    ADDRESS OF LABEL TABLE           18480000
CURRLBL  DC    F'0'                    CURRENT LABEL ENTRY ADDR         18490000
ENDLBL   DC    F'0'                    ADDRESS OF END OF LABEL TBL      18500000
TXTSTRT  DC    F'0'                    ADDRESS OF TEXT STORAGE AREA     18510000
TXTEND   DC    F'0'                    ADDRESS OF END OF TEXT AREA      18520000
PRMOPT   DC    X'00'                                                    18530000
PRMOPTSU EQU   X'80'                   OPTIONS=SUMMARY                  18540000
PRMOPTZR EQU   X'40'                   Zero relocatable adcons       02 18550001
PRMOPTPA EQU   X'20'                   Page align buffer             06 18560006
PRMOPTDB EQU   X'10'                   Debug                         08 18570008
LIBDDN   DC    CL8'SYSLIB'                                              18580000
*                                                                       18590000
PRTLINE  DS    0CL121                  PRINT LINE                       18600000
PCC      DC    C'1'                    CARRIAGE CONTROL                 18610000
PRT      DC    CL120' '                PRINT DATA                       18620000
*                                                                       18630000
         DC    0D'+0'                                                   18640000
BLDLIST  DS    XL62                    BLDL LIST                        18650000
         ORG   BLDLIST                                                  18660000
BLDLNO   DC    H'1'                    ONE ENTRY                        18670000
BLDLLEN  DC    H'58'                   LENGTH OF ENTRY                  18680000
MEMBER   DC    CL8' '                  MEMBER NAME                      18690000
TTRMOD   DC    XL3'000000'             TTR OF MODULE                    18700000
CCAT     DC    XL1'00'                 CONCATENATION NUMBER             18710000
         DC    XL1'00'                                                  18720000
ALIASIND DC    XL1'00'                 ALIAS AND MISC INDICATOR         18730000
*                           80=ALIAS                                    18740000
TTR1TXT  DC    XL3'000000'             TTR OF 1ST TXT RECORD            18750000
         DC    XL1'00'                                                  18760000
TTRNS    DC    XL3'000000'             TTR OF NOTE OR SCATTER LIST      18770000
NNOTE    DC    XL1'00'                 NBR ENTRIES IN NOTE LIST         18780000
ATTR1A   DC    XL1'00'                 MODULE ATTRIBUTES 1, BYTE 1      18790000
*                           80=RENT                                     18800000
*                           40=REUS                                     18810000
*                           20=OVERLAY                                  18820000
*                           10=UNDER TEST                               18830000
*                           08=ONLY LOADABLE                            18840000
*                           04=SCATTER FORMAT                           18850000
*                           02=EXECUTABLE                               18860000
*                           01=ONE TXT, NO RLD RECORDS                  18870000
ATTR1B   DC    XL1'00'                 ATTRIBUTES 1, BYTE 2             18880000
*                           80=CANNOT BE REPROCESSED BY LKED E          18890000
*                           40=ORIGIN OF 1ST TXT RECORD IS ZERO         18900000
*                           20=ASSIGNED ENTRY POINT ADDR IS ZERO        18910000
*                           10=CONTAINS NO RLD RECORD                   18920000
*                           08=CANNOT BE REPROCESSED BY LKED            18930000
*                           04=CONTAINS TESTRAN SYMBOLS                 18940000
*                           02=CREATED BY LKED                          18950000
*                           01=REFR                                     18960000
TOTVIRT  DC    XL3'000000'             TOTAL VIRTUAL STRG REQRD FOR MOD 18970000
LENG1    DC    XL2'0000'               LENGTH OF 1ST TEXT RECORD        18980000
LKEPA    DC    XL3'000000'             ASSIGNED ENTRY POINT ADDR        18990000
ATTR2    DC    XL1'00'                 ATTRIBUTES 2                     19000000
*                           80=PROCESSED BY OS/VS LKED                  19010000
*                           40=MODULE REQUIRES 16M OR MORE              19020000
*                           20=PAGE ALIGNMENT REQUIRED FOR MODULE       19030000
*                           10=SSI PRESENT                              19040000
*                           08=AUTH CODE INFO VALID                     19050000
*                           04=PROGRAM OBJECT                           19060000
*                           02=                                         19070000
*                           01=                                         19080000
ATTR2B   DC    XL1'00'                 ATTRIBUTES 2                     19090000
*                           80=PRIMARY NAME GENERATED                   19100000
*                           40=                                         19110000
*                           20=                                         19120000
*                           10=1=RMODE=ANY 0=RMODE=24                   19130000
*                           0C=ALIAS EPA ADDRESSING MODE                19140000
*                              00=AMODE=24                              19150000
*                              10=AMODE=31                              19160000
*                              01=AMODE=64                              19170000
*                              11=AMODE=ANY                             19180000
*                           03=MAIN EPA ADDRESSING MODE                 19190000
*                              00=AMODE=24                              19200000
*                              10=AMODE=31                              19210000
*                              01=AMODE=64                              19220000
*                              11=AMODE=ANY                             19230000
ATTR2C   DC    XL1'00'                 NUMBER OF RLD/CONTROL RECORDS    19240000
*                           80=PROGRAM OBJECT CAN'T BE CONVERTED        19250000
*                           40=FETCHOPT PRIME                           19260000
*                           20=FETCHOPT PACK                            19270000
SCTRLEN  DC    XL2'0000'               SCATTER LIST LENGTH              19280000
TTLEN    DC    XL2'0000'               TRANSLATION TABLE LENGTH         19290000
SCESDID  DC    XL2'0000'               CESD NBR FOR 1ST TXT RECD        19300000
SCEPESD  DC    XL2'0000'               CESD NBR FOR ENTRY POINT         19310000
ALEPA    DC    XL3'000000'             ENTRY POINT OF THE MEMBER NAME   19320000
ALMEM    DC    CL8' '                  REAL MEMBER NAME FOR ALIAS       19330000
SSI      DC    XL4'00000000'           SSI BYTES                        19340000
AUTHLEN  DC    XL1'00'                 AUTH CODE LENGTH                 19350000
AUTHCOD  DC    XL1'00'                 AUTH CODE                        19360000
         ORG   ,                                                        19370000
BLDLEND  EQU   *                                                        19380000
*                                                                       19390000
*                                                                       19400000
*                                                                       19410000
BUFAD    DC    F'0'                    SYSLIB BUFFER ADDR               19420000
SYMTBAD  DC    F'0'                    SYMBOL TABLE ADDRESS             19430000
CURRSYM  DC    F'0'                    CURRENT SYM TBL ADDR             19440000
ENDSYM   DC    F'95000'                SYM TBL END ADDR                 19450000
RLDTBL   DC    F'0'                    ADDR OF RLD TABLE                19460000
CURRLD   DC    F'0'                    CURR RLD TBL ADDR                19470000
ENDRLD   DC    F'60000'                RLD TBL END ADDR                 19480000
ENDATO   DC    F'1536'                 DATA ONLY TBL LENGTH             19490000
PROCSW   DC    XL1'00'                 PROCESS INDICATOR                19500000
PROCSWFD EQU   X'80'                   SHOW CSECT FOUND                 19510000
PROCSWOK EQU   X'40'                   MODULE PROCESSING DONE           19520000
PROCSW1T EQU   X'20'                   FIRST TIME SWITCH                19530000
PROCSWSK EQU   X'10'                   SKIP PRINT (SUMMARY)             19540000
CES9     DC    F'0'                    CESDREC RETURN ADDR              19550000
BL9      DC    F'0'                    BLDL RTN RETURN ADDR             19560000
CR9      DC    F'0'                    CTRLRECS RETURN ADDR             19570000
CT9      DC    F'0'                    CNTLRECS RETURN ADDR             19580000
RL9      DC    F'0'                    RLDRECS RETURN ADDR              19590000
SYMLEN   DC    AL2(L'SYMENT)           LENGTH OF SYMTBL ENTRY        */ 19600000
PRTABL   DC    CL9' '                  HEX-PRINTABLE CONVERSION AREA    19610000
POFSET   DC    F'0'                    OFFSET FOR TEXT PRINT            19620000
*                                                                       19630000
*                                                                       19640000
*                                                                       19650000
DEVTYPE  DC    D'0'                                                     19660000
OPENLIST OPEN  (0),MF=L                                                 19670000
OPNLST   EQU   OPENLIST,*-OPENLIST                                      19680000
         READ  DECB,SF,,,'S',MF=L                                       19690000
SYSLIB   DCB   DSORG=PO,MACRF=R,DDNAME=SYSLIB,EXLST=*-*,             03X19700002
               RECFM=U,NCP=1                                            19710000
LIBDCB   EQU   SYSLIB,*-SYSLIB                                          19720000
PRINTDD  DCB   DSORG=PS,MACRF=PM,DDNAME=PRINTDD,                       X19730000
               RECFM=FBA,LRECL=121                                      19740000
PRINTDCB EQU   PRINTDD,*-PRINTDD                                        19750000
         DC    0A(0)                                                 03 19760002
LIBEXLST DC    AL1(128+7),AL3(LIBJFCB)                               03 19770002
LIBJFCB  DC    XL176'0'                                              03 19780002
*                                                                    08 19790008
W#SAVER9 DS    A                                                     08 19800008
W#DMPRGS DS    16A                                                   08 19810008
W#DMPOFF DS    A                                                     08 19820008
W#DUP1ST DS    A                                                     08 19830008
W#DMPADR DS    A                                                     08 19840008
W#DMPFLG DS    X                                                     08 19850008
W#DMP1ST EQU   X'80'                                                 08 19860008
W#DMPDUP EQU   X'40'                                                 08 19870008
W#RECCT  DS    PL4                                                   08 19880008
         DC    0D'+0'                                                   19890000
WORKLEN  EQU   *-WORKAREA                                               19900000
*                                                                       19910000
*                                                                       19920000
*                                                                       19930000
LABELD   DSECT ,                       LABEL TABLE ENTRY                19940000
LABEL    DS    0CL13                   13-BYTE ENTRIES                  19950000
LBLADR   DS    XL3                     RELATIVE ADDR IN TEXT            19960000
LBLTYP   DS    CL1                     TYPE: L=LABEL, A=ADCON, V=VCON,  19970000
LBLNAME  DS    CL8                     NAME (SYMBOL)                    19980000
LBLLEN   DS    XL1                     LENGTH IF A, V, OR W             19990000
*                                                                       20000000
*                                                                       20010000
*                                                                       20020000
RLDTBLD  DSECT ,                       RELOCATION DICTIONARY TABLE      20030000
RLDENT   DS    0CL20                   11 BYTE ENTRIES                  20040000
RLDRP    DS    XL2                     RELOCATION POINTER               20050000
RLDPP    DS    XL2                     POS PTR (SYMBOL CESD NBR)        20060000
RLDTYPE  DS    XL1                     TYPE                             20070000
*                    00=A-TYPE ADCON                                    20080000
*                    01=V-TYPE ADCON                                    20090000
*                    02=PSEUDO REGISTER DISPLACEMENT                    20100000
*                    03=PSEUDO REG CUMULATIVE DISPL                     20110000
*                    08=UNRESOLVED                                      20120000
RLDLEN   DS    XL1                     LENGTH OF CONSTANT               20130000
RLDDIR   DS    CL1                     RELOCATION DIRECTION, + OR       20140000
RLDADDR  DS    XL3                     LKED ASSGND ADDR OF CONSTANT     20150000
RLDNAME  DS    CL8                     NAME FROM ASSOC ESD              20160000
RLDESDTP DS    XL1                     TYPE FROM ASSOC ESD              20170000
         DS    XL1                                                      20180000
*                                                                       20190000
*                                                                       20200000
*                                                                       20210000
SYMTBL   DSECT ,                       EXTERNAL SYMBOL TABLE ENTRY      20220000
SYMENT   DS    0CL19                   19 BYTE ENTRIES                  20230000
EXTSYM   DS    CL8                     EXTERNAL SYMBOL NAME             20240000
TYPSYM   DS    XL1                     SYMBOL TYPE                      20250000
*                        00=SD (NAMED CSECT)                            20260000
*                        02=ER (EXTRN)                                  20270000
*                        03=LR (ENTRY)                                  20280000
*                        04=PC (UNNAMED CSECT)                          20290000
*                        05=CM (COM)                                    20300000
*                        06=PR (PSEUDO REGISTER)                        20310000
*                        07=NULL                                        20320000
*                        0A=WX (WXTRN)                                  20330000
*                        0D=SD (NAMED CSECT)                            20340000
*                        0E=PC (UNNAMED CSECT)                          20350000
*                        0F=ENTAB OR SEGTAB                             20360000
SYMIND   DS    XL1                     INDICATOR                        20370000
*                        BIT 0 = MAP                                    20380000
*                        BIT 1 = CHAIN                                  20390000
*                        BIT 2 = INSERT                                 20400000
*                        BIT 3 = DELETE/REPLACE                         20410000
SYMADDR  DS    XL3                     SYMBOL ADDRESS (0 FOR ER, WX, NU 20420000
SYMSEG   DS    XL1                     SEGMENT ID (0 FOR ER, WX, NULL)  20430000
SYMLRID  DS    0XL2                    ESD ID OF DEF FOR LR             20440000
SYMLENG  DS    XL3                     LENGTH FOR SD, PC, CM, PR        20450000
*                        0 FOR ER, WX, NULL                             20460000
SYMESDID DS    XL2                     ESD ID OF THIS ITEM              20470000
****************************************************************     03 20480002
*                                                              *     03 20490002
*        SYSTEM DSECTS                                         *     03 20500002
*                                                              *     03 20510002
****************************************************************     03 20520002
JFCB     DSECT ,                                                     03 20530002
         IEFJFCBN ,                                                  03 20540002
         DCBD DSORG=PO                                               03 20550002
****************************************************************        20560000
*                                                              *        20570000
*        EQUATES                                               *        20580000
*                                                              *        20590000
****************************************************************        20600000
R0       EQU   0                                                        20610000
R1       EQU   1                                                        20620000
R2       EQU   2                                                        20630000
R3       EQU   3                                                        20640000
R4       EQU   4                                                        20650000
R5       EQU   5                                                        20660000
R6       EQU   6                                                        20670000
R7       EQU   7                                                        20680000
R8       EQU   8                                                        20690000
R9       EQU   9                                                        20700000
R10      EQU   10                                                       20710000
R11      EQU   11                                                       20720000
R12      EQU   12                                                       20730000
R13      EQU   13                                                       20740000
R14      EQU   14                                                       20750000
R15      EQU   15                                                       20760000
         END   ,                                                        20770000
