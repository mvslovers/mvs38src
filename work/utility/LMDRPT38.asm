*********************************************************************** 00000100
*                                                                     * 00000200
* MODULE NAME                                                         * 00000300
*    LMDRPT38                                                         * 00000400
*                                                                     * 00000500
* ATTRIBUTES                                                          * 00000600
*    NOT RENTRANT                                                     * 00000700
*                                                                     * 00000800
* AUTHOR                                                              * 00000900
*    DAVE KREISS                                                      * 00001000
*                                                                     * 00001100
* FUNCTION                                                            * 00001200
*    READS RECORDS PRODUCED BY LMDXRF38 AND PRODUCES REPORTS ABOUT    * 00001300
*    THE SETS OF ORIGINAL AND BUILD LIBRARIES.                        * 00001400
*                                                                     * 00001500
*    THE INPUT IS EXPECTED TO BE SORTED IN LIBRARY, LOAD MODULE AND   * 00001600
*    CSECT ORDER.                                                     * 00001700
*                                                                     * 00001800
*    THE LOADLMD MODULE MUST ALSO BE PRESENT IN THE STEPLIB IF THE    * 00001900
*    COMPARE PARAMETER IS PRESENT.                                    * 00002000
*                                                                     * 00002100
* JCL                                                                 * 00002200
*    //        EXEC PGM=LMDRPT38,PARM='parameters'                    * 00002300
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00002400
*    //SYSPRINT DD  SYSOUT=*                                          * 00002500
*    //ORG      DD                                                    * 00002600
*    //BLD      DD                                                    * 00002700
*    //Oxxxxxx  DD  DSN=old libraryies                                * 00002800
*    //Nxxxxxx  DD  DSN=new libraries                                 * 00002900
*    //CSV      DD  DSN=csv output data set                           * 00003000
*    //DIFIN    DD  DSN=difference table,DISP=SHR                     * 00003100
*    //SYSIN    DD  DSN=ignore table,disp=shr                         * 00003200
*                                                                     * 00003300
* DD STATEMENTS                                                       * 00003400
*    STEPLIB       LOAD LIBRARY CONTAINING THE MODULE LMDRPT38.       * 00003500
*    SYSPRINT      report data set.                                   * 00003600
*    ORG           DATA SET CONTAINING THE output of the runs of      * 00003700
*                  LMDXRF38 AGAINST THE ORIGINAL LIBRARIES.           * 00003800
*    BLD           DATA SET CONTAINING THE OUTPUT OF THE RUNS OF      * 00003900
*                  LMDXRF38 AGAINST THE BUILD LIBRARIES.              * 00004000
*    CSV           OPTIONAL DATA SET WHICH CONTAINS TOTALS BY         * 00004100
*                  LIBRARY FOR USE IN SPREAD SHEET REPORTING.         * 00004200
*    SYSIN         IGNORE CSECTS AS FOLLOWS:                          * 00004300
*                    CC1-8=CSECT NAME TO IGNORE                       * 00004400
*                  EXAMPLE:                                           * 00004500
*                    //SYSIN    DD  *                                 * 00004600
*                    IEFBR14                                          * 00004700
*    DIFIN         DIFFERENCE TABLE USED TO IGNORE SPECIFIC CSECT     * 00004800
*                  DIFFERENCES AS FOLLOWS:                            * 00004900
*                  SEQUENCE OF HEADER AND DIFFERENCES                 * 00005000
*                  HEADER                                             * 00005100
*                    CC1=>                                            * 00005200
*                    CC2-9=CSECT NAME                                 * 00005300
*                  DIFFERENCES (AS MANY AS NEEDED)                    * 00005400
*                    CC1=CC6=OFFSET OF DIFFERENCE                     * 00005500
*                    CC70CC8=LENGTH OF DIFFERENCE                     * 00005600
*                  EXAMPLE:                                           * 00005700
*                    //DIFIN    DD  *                                 * 00005800
*                    >IEFBR14                                         * 00005900
*                    00000201                                         * 00006000
*                    >HASPACCT                                        * 00006100
*                    00015C04                                         * 00006200
*                    00016404                                         * 00006300
*                                                                     * 00006400
*                                                                     * 00006500
* PARAMETERS                                                          * 00006600
*    DEBUG       - PRODUCES SOME DEBUGGING INFO                       * 00006700
*                  MOSTLY USED IN DEBUGGING THE SYSPRINT PARSING      * 00006800
*    ERRORS      - REPORTS ONLY ANY CSECT WITH ERRORS.                * 00006900
*    MISSING     - REPORTS ONLY MODULES PRESENT IN THE ORIGINAL       * 00007000
*                  LIBRARIES BUT MISSING IN THE BUILD LIBRARIES.      * 00007100
*    SUMMARY     - PRODUCES ONLY SUMMARIZATION TOTALS.                * 00007200
*    COMPARE     - INVOKES COMPARE OF ALL CSECTS WHICH HAVE THE       * 00007300
*                  SAME LENGTH.                                       * 00007400
*    CLEARRLD=   - PASS THIS CLEARRLD OPTION TO LOADLMD.              * 00007500
*    LIST        - LIST IGNORE TABLE (SYSIN) AND CSECT DIFFERENCE     * 00007600
*                  TABLE (DIFIN).                                     * 00007700
*    LIB=        - Specifify a library to report on                   * 00007800
*                                                                     * 00007900
* SAMPLE JCL                                                          * 00008000
*    //SORT1   EXEC PGM=SORT,PARM='MSG=AP'                            * 00008100
*    //SORTLIB  DD  DSN=SYS1.SORTLIB,DISP=SHR                         * 00008200
*    //SORTWK01 DD  SPACE=(CYL,5),UNIT=SORT                           * 00008300
*    //SORTWK02 DD  SPACE=(CYL,5),UNIT=SORT                           * 00008400
*    //SORTWK03 DD  SPACE=(CYL,5),UNIT=SORT                           * 00008500
*    //SORTIN   DD  DSN=bld xref data set,DISP=SHR                    * 00008600
*    //SORTOUT  DD  DSN=&BLD,DISP=(,PASS),                            * 00008700
*    //             DCB=(RECFM=FB,LRECL=80,BLKSIZE=4080),             * 00008800
*    //             SPACE=(CYL,(5,5)),UNIT=VIO                        * 00008900
*    //SYSOUT   DD  SYSOUT=*                                          * 00009000
*    //SYSIN    DD  *                                                 * 00009100
*     SORT FIELDS=(1,40,CH,A)                                         * 00009200
*    /*                                                               * 00009300
*    //SORT2   EXEC PGM=SORT,PARM='MSG=AP'                            * 00009400
*    //SORTLIB  DD  DSN=SYS1.SORTLIB,DISP=SHR                         * 00009500
*    //SORTWK01 DD  SPACE=(CYL,5),UNIT=SORT                           * 00009600
*    //SORTWK02 DD  SPACE=(CYL,5),UNIT=SORT                           * 00009700
*    //SORTWK03 DD  SPACE=(CYL,5),UNIT=SORT                           * 00009800
*    //SORTIN   DD  DSN=org xref data set,DISP=SHR                    * 00009900
*    //SORTOUT  DD  DSN=&ORG,DISP=(,PASS),                            * 00010000
*    //             DCB=(RECFM=FB,LRECL=80,BLKSIZE=4080),             * 00010100
*    //             SPACE=(CYL,(5,5)),UNIT=VIO                        * 00010200
*    //SYSOUT   DD  SYSOUT=*                                          * 00010300
*    //SYSIN    DD  *                                                 * 00010400
*     SORT FIELDS=(1,40,CH,A)                                         * 00010500
*    /*                                                               * 00010600
*    //SUMMARY EXEC PGM=LMDRPT38,PARM='SUMMARY,COMPARE'               * 00010700
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00010800
*    //SYSPRINT DD  SYSOUT=*                                          * 00010900
*    //ORG      DD  DSN=&ORG,DISP=(OLD,PASS)                          * 00011000
*    //BLD      DD  DSN=&BLD,DISP=(OLD,PASS)                          * 00011100
*    //ONUCLEUS DD  DSN=MVSSRC.ORG.NUCLEUS,DISP=SHR                   * 00011200
*    //BNUCLEUS DD  DSN=MVSSRC.NEW.NUCLEUS,DISP=SHR                   * 00011300
*    //CSV      DD  SYSOUT=*                                          * 00011400
*    //DIF      DD  DSN=MVSSRC.BLD.UTILITY.ASM(DIFIN),DISP=SHR        * 00011500
*                                                                     * 00011600
*********************************************************************** 00011700
*                                                                     * 00011800
* CHANGE LOG:                                                         * 00011900
*   DATE     AAA VV.VV DESCRIPTION                                    * 00012000
* 06/06/2015 DSK 01.01 CREATED                                        * 00012100
* 07/10/2015 DSK 01.02 CLEAR RELOCATABLE ELEMENTS                     * 00012200
* 12/08/2015 DSK 01.03 Ignore module table                            * 00012300
* 01/03/2016 DSK 01.04 Add total equal and misc ignore table          * 00012400
* 04/29/2016 DSK 01.05 Skip ignored CSECTS if not in build            * 00012500
* 05/29/2016 DSK 01.06 Add CLEARRLD=YES/NO option                     * 00012600
* 01/13/2017 DSK 01.07 Clean up report                                * 00012700
* 01/13/2017 DSK 01.08 Fix missing totals of only compare not equals  * 00012800
*                      Add CSV DD for spread sheet reporting          * 00012900
* 03/02/2017 DSK 01.09 Add difference ignore table                    * 00013000
* 03/05/2017 DSK 01.10 Add scan ignore table to extra LMOD and CSECT  * 00013100
* 03/07/2017 DSK 01.11 Add PARM=LIST and increase DIFIN table to 5000 * 00013200
* 03/10/2017 DSK 01.12 Fix junk left over from ignore table in print  * 00013300
* 03/23/2017 DSK 01.13 Compact DIFIN table and other nisc changes     * 00013400
* 03/28/2017 DSK 01.14 Handle mismatch between XREF file and modules  * 00013500
* 04/01/2017 DSK 01.15 Handle extra build LMOD/CSECT totaling         * 00013600
* 04/18/2017 DSK 01.16 Fix literal length                             * 00013700
* 09/08/2017 DSK 01.17 Check ignore name against CSECT an LMOD        * 00013800
* 04/09/2019 DSK 01.18 Add PARM= LIB=                                 * 00013900
* 05/17/2019 DSK 01.19 Don't require ignore table (SYSIN) DD          * 00014000
* 12/17/2019 DSK 01.20 Increase difference table                      * 00014100
* 12/18/2019 DSK 01.21 Ignored CSECT/LMOD counters                    * 00014200
         LCLC   &VER                                                    00014300
&VER     SETC   '01.21'                                                 00014400
*                                                                     * 00014500
*********************************************************************** 00014600
****************************************************************        00014700
*                                                              *        00014800
*   PROGRAM INITIALIZATION                                     *        00014900
*                                                              *        00015000
****************************************************************        00015100
LMDRPT38 CSECT ,                                                     07 00015200
         USING LMDRPT38,R15                                             00015300
         B     BEGIN                                                    00015400
         DROP  R15                                                      00015500
         DC    AL1(L'PGMID)                                             00015600
PGMID    DC    C'LMDRPT38 - &VER &SYSDATE &SYSTIME'                     00015700
BEGIN    DC    0H'+0'                                                   00015800
         STM   R14,R12,12(R13)                                          00015900
         LR    R10,R15                                               09 00016000
         LA    R11,2048(,R10)                                        09 00016100
         LA    R11,2048(,R11)                                        09 00016200
         LA    R12,2048(,R11)                                        09 00016300
         LA    R12,2048(,R12)                                        09 00016400
         USING LMDRPT38,R10,R11,R12                                  09 00016500
         LA    R14,SAVEAREA                                             00016600
         ST    R13,4(,R14)                                              00016700
         ST    R14,8(,R13)                                              00016800
         LR    R13,R14                                                  00016900
         L     R9,0(,R1)                                             09 00017000
         BAL   R14,INIT                                                 00017100
*                                                                       00017200
*                                                                       00017300
*                                                                       00017400
         BAL   R14,ORGGET                                               00017500
         MVC   PREVOLIB,ORGLIB                                          00017600
         MVC   PREVOMOD,ORGMOD                                          00017700
         BAL   R14,BLDGET                                               00017800
         MVC   PREVBLIB,ORGLIB                                          00017900
         MVC   PREVBMOD,ORGMOD                                          00018000
         B     PROC050                                                  00018100
*                                                                       00018200
*                                                                       00018300
*                                                                       00018400
PROC     DS    0H                                                       00018500
         BAL   R14,ORGGET                                               00018600
         BAL   R14,BLDGET                                               00018700
PROC010  DS    0H                                                       00018800
*                                                                       00018900
*        Library break                                                  00019000
*                                                                       00019100
         CLC   ORGLIB,PREVOLIB                                          00019200
         BE    PROC030                                                  00019300
         CLC   BLDLIB,PREVOLIB                                          00019400
         BH    PROC020                                                  00019500
         CLC   PREVOMOD,BLDMOD                                          00019600
         BE    CSBMIS                                                   00019700
         B     MDBMIS                                                   00019800
PROC020  DS    0H                                                       00019900
         BAL   R14,BRKMOD                                               00020000
         BAL   R14,BRKLIB                                               00020100
         B     PROC050                                                  00020200
PROC030  DS    0H                                                       00020300
         CLC   ORGMOD,PREVOMOD                                          00020400
         BE    PROC050                                                  00020500
*                                                                       00020600
*        Load Module break                                              00020700
*                                                                       00020800
         CLC   BLDLIB,PREVOLIB                                          00020900
         BH    PROC040                                                  00021000
         CLC   BLDMOD,PREVOMOD                                          00021100
         BH    PROC040                                                  00021200
         B     CSBMIS                                                   00021300
PROC040  DS    0H                                                       00021400
         BAL   R14,BRKMOD                                               00021500
PROC050  DS    0H                                                       00021600
         CLC   ORGLIB,BLDLIB                                            00021700
         BH    LBBMIS                                                   00021800
         BL    LBOMIS                                                   00021900
         CLC   ORGMOD,BLDMOD                                            00022000
         BH    MDBMIS                                                   00022100
         BL    MDOMIS                                                   00022200
         CLC   ORGCS,BLDCS                                              00022300
         BH    CSBMIS                                                   00022400
         BL    CSOMIS                                                   00022500
         CLC   ORGLEN,BLDLEN                                            00022600
         BNE   LENDIF                                                   00022700
*                                                                       00022800
*        Match CSECT length                                             00022900
*                                                                       00023000
         LA    R2,0                                                     00023100
         TM    FLAG,FLAGCMP     COMPARE                                 00023200
         BNO   PROC0690                                                 00023300
* FETCH ORIGINAL LOAD MODULE CSECT                                      00023400
         MVI   DMPPRM,C' '                                              00023500
         MVC   DMPPRM+1(L'DMPPRM-1),DMPPRM                              00023600
         LA    R1,DMPPRM                                             02 00023700
         LA    R15,ORGMOD       LMOD NAME                            02 00023800
         LA    R0,8                                                  02 00023900
PROC0601 DS    0H                                                    13 00024000
         CLI   0(R15),C' '                                           02 00024100
         BE    PROC0602                                              13 00024200
         MVC   0(1,R1),0(R15)                                        02 00024300
         LA    R1,1(,R1)                                             02 00024400
         LA    R15,1(,R15)                                           02 00024500
         BCT   R0,PROC0601                                           13 00024600
PROC0602 DS    0H                                                    13 00024700
         MVI   0(R1),C','                                            02 00024800
         LA    R1,1(,R1)                                             02 00024900
         LA    R15,ORGCS        CSECT NAME                           02 00025000
         LA    R0,8                                                  02 00025100
PROC0603 DS    0H                                                    13 00025200
         CLI   0(R15),C' '                                           02 00025300
         BE    PROC0604                                              13 00025400
         MVC   0(1,R1),0(R15)                                        02 00025500
         LA    R1,1(,R1)                                             02 00025600
         LA    R15,1(,R15)                                           02 00025700
         BCT   R0,PROC0603                                           13 00025800
PROC0604 DS    0H                                                    13 00025900
         MVC   0(6,R1),=C',LIB=O'                                    02 00026000
         LA    R2,5(,R1)                                             02 00026100
         LA    R1,6(,R1)                                             02 00026200
         LA    R15,ORGLIB       ORIGINAL LIBRARY                     02 00026300
         LA    R0,7                                                  02 00026400
PROC0605 DS    0H                                                    13 00026500
         CLI   0(R15),C' '                                           02 00026600
         BE    PROC0606                                              13 00026700
         MVC   0(1,R1),0(R15)                                        02 00026800
         LA    R1,1(,R1)                                             02 00026900
         LA    R15,1(,R15)                                           02 00027000
         BCT   R0,PROC0605                                           13 00027100
PROC0606 DS    0H                                                    13 00027200
         MVC   0(10,R1),=C',CLEARRLD='                               06 00027300
         TM    FLAG,FLAGCLRN                                         06 00027400
         BO    PROC0607                                              13 00027500
         MVC   10(3,R1),=C'YES'                                      06 00027600
         LA    R1,13(,R1)                                            06 00027700
         B     PROC0608                                              13 00027800
PROC0607 DS    0H                                                    13 00027900
         MVC   10(2,R1),=C'NO'                                       06 00028000
         LA    R1,12(,R1)                                            06 00028100
PROC0608 DS    0H                                                    13 00028200
         LA    R0,DMPPRM                                             02 00028300
         SR    R1,R0                                                 02 00028400
         STH   R1,DMPPRMLN                                           02 00028500
         TM    FLAG,FLAGDBG                                             00028600
         BNO   PROC0610                                              13 00028700
         MVC   LINE+1(3),=C'CO>'                                        00028800
         UNPK  LINE+4(5),DMPPRMLN(3)                                    00028900
         TR    LINE+4(4),HEXTBL-240                                     00029000
         MVI   LINE+8,C' '                                           09 00029100
         MVC   LINE+9(L'DMPPRM),DMPPRM                                  00029200
         BAL   R14,PRT                                                  00029300
PROC0610 DS    0H                                                    13 00029400
         LA    R1,DMPPRMAD                                              00029500
         L     R15,LOADLMD                                              00029600
         BALR  R14,R15                                                  00029700
         LTR   R15,R15                                                  00029800
         BNZ   PROC0681                                                 00029900
         LR    R9,R1                                                    00030000
* FETCH BUILD LOAD MODULE CSECT                                         00030100
         MVI   0(R2),C'B'                                            02 00030200
         TM    FLAG,FLAGDBG                                             00030300
         BNO   PROC0613                                              13 00030400
         MVC   LINE+1(3),=C'CB>'                                        00030500
         UNPK  LINE+4(5),DMPPRMLN(3)                                    00030600
         TR    LINE+4(4),HEXTBL-240                                     00030700
         MVI   LINE+8,C' '                                           09 00030800
         MVC   LINE+9(L'DMPPRM),DMPPRM                                  00030900
         BAL   R14,PRT                                                  00031000
PROC0613 DS    0H                                                    13 00031100
         LA    R1,DMPPRMAD                                              00031200
         L     R15,LOADLMD                                              00031300
         BALR  R14,R15                                                  00031400
         LTR   R15,R15                                                  00031500
         BNZ   PROC0682                                                 00031600
         LR    R8,R1                                                    00031700
         LA    R0,8(,R9)                                                00031800
         LA    R14,8(,R8)                                               00031900
         L     R1,4(,R9)               Length of OLD/Original        14 00032000
         L     R15,4(,R8)              Length of NEW/Build           14 00032100
         CR    R1,R15                  Mis-match between XREF file   14 00032200
         BNE   LENDIF                   and module loaded (sorta)    14 00032300
         LA    R2,0                                                     00032400
         ZAP   MODDFCT,=P'+0'          CLEAR DIFF IGNORED COUNT      09 00032500
PROC0620 DS    0H                                                    02 00032600
         CLCL  R0,R14                                                   00032700
         BE    PROC0630                                              13 00032800
*        Scan difference table if present                            09 00032900
         OC    DIFTBLST,DIFTBLST       DIFFERENCE TABLE PRESENT      09 00033000
         BZ    PROCDFND                IF ZERO NO TABLE              09 00033100
         STM   R14,R1,DIFSAVRG         SAVE REGISTERS                09 00033200
         L     R1,4(,R9)               LENGTH                        09 00033300
         SR    R1,R15                  RELATIVE OFFSET OF ERROR      13 00033400
         L     R14,=A(DIFTBL)          DIFFERENCE TABLE              09 00033500
PROCDFCM DS    0H                                                    09 00033600
         C     R14,DIFTBLST            END OF DIF TABLE              13 00033700
         BNL   PROCDFDN                YES, END OF TABLE             09 00033800
         CLC   ORGCS,0(R14)            CSECT FOUND IN DIFF TABLE     09 00033900
         LA    R14,8(,R14)             NEXT DIF ENTRY                13 00034000
         BE    PROCDFCK                Yes, found this entry         13 00034100
PROCDFES DS    0H                                                    13 00034200
         CLI   0(R14),X'0F'            NO MODULE > X'0FFFFF'         13 00034300
         BNL   PROCDFCM                YES, next module              13 00034400
         LA    R14,4(,R14)             Next entry                    13 00034500
         C     R14,DIFTBLST            END OF DIF TABLE              13 00034600
         BNL   PROCDFDN                YES, END OF TABLE             09 00034700
         B     PROCDFES                Scan all entries this module  13 00034800
PROCDFCK DS    0H                                                    09 00034900
         CLI   0(R14),X'0F'            NO MODULE > X'0FFFFF'         09 00035000
         BNL   PROCDFDN                YES, END OF MODULE            13 00035100
         L     R15,0(,R14)             Get offset and length         13 00035200
         LR    R0,R15                  GET DIFF OFFSET+LENGTH        13 00035300
         SRL   R15,8                   SHIFT OUT LENGTH              13 00035400
         N     R0,=A(X'FF')            Clean up offset               13 00035500
         BCTR  R0,0                    ZERO BASED FOR END            13 00035600
         AR    R0,R15                  GET END OFFSET                13 00035700
         CR    R1,R15                  ERROR OFFSET BEFORE ENTRY     13 00035800
         BL    PROCDFNX                YES, SKIP DIF ENTRY           09 00035900
         CR    R1,R0                   ERROR OFFSET AFTER ENTRY      13 00036000
         BH    PROCDFNX                YES, SKIP DIF ENTRY           09 00036100
         AP    MODDFCT,=P'+1'          ADD TO DIFF IGNORED COUNT     09 00036200
         LM    R14,R1,DIFSAVRG         RESTORE REGISTERS             09 00036300
         B     PROCDFSK                TREAT AS A MATCH              09 00036400
PROCDFNX DS    0H                                                    09 00036500
         LA    R14,4(,R14)             NEXT DIF ENTRY                13 00036600
         C     R14,DIFTBLST            END OF DIF TABLE              13 00036700
         BL    PROCDFCK                NEXT DIF                      13 00036800
PROCDFDN DS    0H                                                    09 00036900
         LM    R14,R1,DIFSAVRG         RESTORE REGISTERS             09 00037000
PROCDFND DS    0H                                                    09 00037100
         LA    R2,1(,R2)                                             02 00037200
PROCDFSK DS    0H                                                    13 00037300
         AH    R0,=H'+1'                                             02 00037400
         BCTR  R1,0                                                  02 00037500
         AH    R14,=H'+1'                                            02 00037600
         BCT   R15,PROC0620                                          02 00037700
PROC0630 DS    0H                                                    13 00037800
         LTR   R2,R2                                                    00037900
         BE    PROC0640                                              13 00038000
PROC0640 DS    0H                                                    13 00038100
         L     R0,0(,R8)                                                00038200
         LR    R1,R8                                                    00038300
         FREEMAIN R,A=(1),LV=(0)                                        00038400
         L     R0,0(,R9)                                                00038500
         LR    R1,R9                                                    00038600
         FREEMAIN R,A=(1),LV=(0)                                        00038700
         B     PROC0690                                                 00038800
PROC0681 DS    0H                                                       00038900
         MVC   LINE+1(3),=C'OLD'                                        00039000
         B     PROC0689                                                 00039100
PROC0682 DS    0H                                                       00039200
         MVC   LINE+1(3),=C'BLD'                                        00039300
PROC0689 DS    0H                                                       00039400
         LR    R2,R15                                                   00039500
         MVC   LINE+5(5),=C'PARM='                                      00039600
         MVC   LINE+10(L'DMPPRM),DMPPRM                                 00039700
         BAL   R14,PRT                                                  00039800
         MVC   LINE+1(13),=C'LOADLMD RC=X'''                            00039900
         ST    R2,DWORD                                                 00040000
         UNPK  LINE+14(9),DWORD(5)                                      00040100
         TR    LINE+14(8),HEXTBL-240                                    00040200
         MVI   LINE+22,C''''                                            00040300
         BAL   R14,PRT                                                  00040400
         LA    R2,8                                                     00040500
         B     EXIT                                                     00040600
PROC0690 DS    0H                                                       00040700
         MVC   LINEOLIB,ORGLIB                                          00040800
         MVC   LINEOMOD,ORGMOD                                          00040900
         MVC   LINEOCS,ORGCS                                            00041000
         MVC   LINEOLEN,ORGLEN                                          00041100
         MVC   LINEBLIB,BLDLIB                                          00041200
         MVC   LINEBMOD,BLDMOD                                          00041300
         MVC   LINEBCS,BLDCS                                            00041400
         MVC   LINEBLEN,BLDLEN                                          00041500
         MVI   LINESEP1,C'¦'                                            00041600
         MVI   LINESEP2,C'¦'                                            00041700
         LTR   R2,R2                                                    00041800
         BZ    PROC0692                                              09 00041900
* Check ignore table if there ignore difference                      03 00042000
         LA    R15,IGNTBL                                            03 00042100
PROC069A DS    0H                                                    03 00042200
         C     R15,IGNPTR                                            03 00042300
         BE    PROC069E                                              03 00042400
         CLC   BLDCS,0(R15)                                          03 00042500
         BE    PROC069B                                              03 00042600
         LA    R15,8(,R15)                                           03 00042700
         B     PROC069A                                              03 00042800
PROC069B DS    0H                                                    03 00042900
         AP    TOTBICT,=P'+1'   Same length not equal but ignored    03 00043000
         AP    MODIGCT,=P'+1'   Count LMOD missing CSECT ignored     15 00043100
         MVC   LINECMT(16),=C'Mismatch ignored'                      03 00043200
         MVC   LINECMT+17(9),=X'40202020206B202120'                  03 00043300
         CVD   R2,DWORD                                              03 00043400
         ED    LINECMT+17(9),DWORD+4                                 03 00043500
         MVI   LINECMT+17,C'('                                       03 00043600
         MVI   LINECMT+26,C')'                                       03 00043700
PROC069C DS    0H                                                    03 00043800
         CLI   LINECMT+18,C' '                                       03 00043900
         BNE   PROC069D                                              03 00044000
         MVC   LINECMT+18(9),LINECMT+19                              03 00044100
         B     PROC069C                                              03 00044200
PROC069D DS    0H                                                    03 00044300
         SR    R2,R2                                                 03 00044400
         B     PROC07B                                               04 00044500
*                                                                    03 00044600
PROC069E DS    0H                                                    03 00044700
         AP    MODBNCT,=P'+1'   Same length but don't compare equal     00044800
         MVC   LINECMT(18),=C'CSECTs don''t match'                      00044900
         MVC   LINECMT+19(9),=X'40202020206B202120'                  02 00045000
         CVD   R2,DWORD                                              02 00045100
         CP    DWORD,=P'+10'    Difference greater than 10           21 00045200
         BH    NEDIF16          Yes                                  21 00045300
         AP    NE1XCT,=P'+1'                                         21 00045400
         B     NEDIF19                                               21 00045500
NEDIF16  DS    0H                                                    21 00045600
         CP    DWORD,=P'+100'   Difference greater than 100          21 00045700
         BH    NEDIF17          Yes                                  21 00045800
         AP    NE10XCT,=P'+1'                                        21 00045900
         B     NEDIF19                                               21 00046000
NEDIF17  DS    0H                                                    21 00046100
         CP    DWORD,=P'+1000'  Difference greater than 1000         21 00046200
         BH    NEDIF18          Yes                                  21 00046300
         AP    NE100XCT,=P'+1'                                       21 00046400
         B     NEDIF19                                               21 00046500
NEDIF18  DS    0H                                                    21 00046600
         AP    NEBIGCT,=P'+1'                                        21 00046700
NEDIF19  DS    0H                                                    21 00046800
         ED    LINECMT+19(9),DWORD+4                                 02 00046900
         MVI   LINECMT+19,C'('                                       02 00047000
         MVI   LINECMT+28,C')'                                       02 00047100
PROC0691 DS    0H                                                    02 00047200
         CLI   LINECMT+20,C' '                                       02 00047300
         BNE   PROC07B                                               09 00047400
         MVC   LINECMT+20(9),LINECMT+21                              02 00047500
         B     PROC0691                                              02 00047600
PROC0692 DS    0H                                                    02 00047700
         CP    MODDFCT,=P'+0'                                        09 00047800
         BE    PROC07A                                               09 00047900
*        Compare equal and differences ignored non-zero              09 00048000
         AP    TOTDFCT,=P'+1'                                        09 00048100
         MVC   LINECMT(19),=C'Differences ignored'                   16 00048200
PROC07A  DS    0H                                                       00048300
         AP    MODBECT,=P'+1'   Compare equal                           00048400
PROC07B  DS    0H                                                       00048500
         TM    FLAG,FLAGSUM                                             00048600
         BNO   PROC070                                                  00048700
         MVI   LINE,C' '                                                00048800
         MVC   LINE+1(L'LINE-1),LINE                                    00048900
         B     PROC100                                                  00049000
PROC070  DS    0H                                                       00049100
         TM    FLAG,FLAGMIS                                             00049200
         BNO   PROC080                                                  00049300
         MVI   LINE,C' '                                                00049400
         MVC   LINE+1(L'LINE-1),LINE                                    00049500
         B     PROC100                                                  00049600
PROC080  DS    0H                                                       00049700
         TM    FLAG,FLAGERS     Report errors                        02 00049800
         BNO   PROC090          No, skip print                       02 00049900
         LTR   R2,R2            Failed compare                       02 00050000
         BNZ   PROC090          Yes, print it                        02 00050100
         MVI   LINE,C' '                                                00050200
         MVC   LINE+1(L'LINE-1),LINE                                    00050300
         B     PROC100                                                  00050400
PROC090  DS    0H                                                       00050500
         BAL   R14,PRT                                                  00050600
PROC100  DS    0H                                                       00050700
         AP    MODOCCT,=P'+1'   Original CSECT                          00050800
         AP    MODBCCT,=P'+1'   Build CSECT                             00050900
         B     PROC                                                     00051000
*                                                                       00051100
*        CSECT length differnce                                         00051200
*                                                                       00051300
LENDIF   DS    0H                                                       00051400
         MVC   LINEOLIB,ORGLIB                                          00051500
         MVC   LINEOMOD,ORGMOD                                          00051600
         MVC   LINEOCS,ORGCS                                            00051700
         MVC   LINEOLEN,ORGLEN                                          00051800
         MVC   LINEBLIB,BLDLIB                                          00051900
         MVC   LINEBMOD,BLDMOD                                          00052000
         MVC   LINEBCS,BLDCS                                            00052100
         MVC   LINEBLEN,BLDLEN                                          00052200
         MVI   LINESEP1,C'¦'                                            00052300
         MVI   LINESEP2,C'¦'                                            00052400
         MVC   LINECMT(17),=C'Length difference'                        00052500
         CLC   =C'******',ORGLEN                                        00052600
         BNE   LENDIF10                                                 00052700
         MVC   LINECMT+18(18),=C'(Not editable MOD)'                    00052800
         AP    MODOECT,=P'+1'   Original not editable                   00052900
         B     LENDIF15                                              02 00053000
LENDIF10 DS    0H                                                       00053100
         LA    R1,ORGLEN                                             21 00053200
         BAL   R14,HEXCVT                                            02 00053300
         LR    R2,R0                                                 02 00053400
         LA    R1,BLDLEN                                             21 00053500
         BAL   R14,HEXCVT                                            02 00053600
         MVI   LINECMT+18,C'('                                       02 00053700
         CR    R0,R2                                                 02 00053800
         BH    LENDIF11                                              02 00053900
         MVI   LINECMT+19,C'-'                                       02 00054000
         LA    R1,LINECMT+20                                         02 00054100
         SR    R2,R0                                                 02 00054200
         CVD   R2,DWORD                                              21 00054300
         B     LENDIF12                                              02 00054400
LENDIF11 DS    0H                                                    02 00054500
         SR    R0,R2                                                 02 00054600
         CVD   R0,DWORD                                              21 00054700
         LA    R1,LINECMT+19                                         02 00054800
LENDIF12 DS    0H                                                    02 00054900
         OI    DWORD+L'DWORD-1,X'0F'                                 21 00055000
         UNPK  0(7,R1),DWORD+4(4)                                    21 00055100
         MVI   7(R1),C')'                                            21 00055200
LENDIF13 DS    0H                                                    02 00055300
         CLI   0(R1),C'0'                                            02 00055400
         BNE   LENDIF15                                              02 00055500
         MVC   0(9,R1),1(R1)                                         21 00055600
         B     LENDIF13                                              02 00055700
LENDIF15 DS    0H                                                    02 00055800
         CP    DWORD,=P'+10'    Difference greater than 10           21 00055900
         BH    LENDIF16         Yes                                  21 00056000
         AP    LN1XCT,=P'+1'                                         21 00056100
         B     LENDIF19                                              21 00056200
LENDIF16 DS    0H                                                    21 00056300
         CP    DWORD,=P'+100'   Difference greater than 100          21 00056400
         BH    LENDIF17         Yes                                  21 00056500
         AP    LN10XCT,=P'+1'                                        21 00056600
         B     LENDIF19                                              21 00056700
LENDIF17 DS    0H                                                    21 00056800
         CP    DWORD,=P'+1000'  Difference greater than 1000         21 00056900
         BH    LENDIF18         Yes                                  21 00057000
         AP    LN100XCT,=P'+1'                                       21 00057100
         B     LENDIF19                                              21 00057200
LENDIF18 DS    0H                                                    21 00057300
         AP    LNBIGCT,=P'+1'                                        21 00057400
LENDIF19 DS    0H                                                    21 00057500
         TM    FLAG,FLAGSUM                                             00057600
         BNO   LENDIF20                                                 00057700
         MVI   LINE,C' '                                                00057800
         MVC   LINE+1(L'LINE-1),LINE                                    00057900
         B     LENDIF40                                                 00058000
LENDIF20 DS    0H                                                       00058100
         TM    FLAG,FLAGMIS                                             00058200
         BNO   LENDIF30                                                 00058300
         MVI   LINE,C' '                                                00058400
         MVC   LINE+1(L'LINE-1),LINE                                    00058500
         B     LENDIF40                                                 00058600
LENDIF30 DS    0H                                                       00058700
         BAL   R14,PRT                                                  00058800
LENDIF40 DS    0H                                                       00058900
         AP    MODOCCT,=P'+1'   Original CSECT                          00059000
         AP    MODBCCT,=P'+1'   Build CSECT                             00059100
         AP    MODBDCT,=P'+1'   Original CSECT length difference        00059200
         B     PROC                                                     00059300
*                                                                       00059400
*        Original CSECT not in Build                                    00059500
*                                                                       00059600
CSOMIS   DS    0H                                                       00059700
         MVC   LINEOLIB,ORGLIB                                          00059800
         MVC   LINEOMOD,ORGMOD                                          00059900
         MVC   LINEOCS,ORGCS                                            00060000
         MVC   LINEOLEN,ORGLEN                                          00060100
         MVI   LINESEP1,C'¦'                                            00060200
         MVI   LINESEP2,C'¦'                                            00060300
* Check ignore table if there ignore difference                      05 00060400
         LA    R15,IGNTBL                                            05 00060500
CSOMIS9A DS    0H                                                    05 00060600
         C     R15,IGNPTR                                            05 00060700
         BE    CSOMIS9C                                              05 00060800
         CLC   ORGCS,0(R15)                                          05 00060900
         BE    CSOMIS9B                                              05 00061000
         LA    R15,8(,R15)                                           05 00061100
         B     CSOMIS9A                                              05 00061200
CSOMIS9B DS    0H                                                    05 00061300
         AP    TOTBICT,=P'+1'   Mismatch ignored                     05 00061400
         AP    MODIGCT,=P'+1'   Count LMOD missing CSECT ignored     15 00061500
         AP    IMCCT,=P'+1'     Count ignored CSECTs missing         21 00061600
         MVC   LINECMT(21),=C'Missing CSECT ignored'                 05 00061700
         TM    FLAG,FLAGERS     Report errors                        05 00061800
         BO    CSOMIS9E         Yes, skip ignored error              05 00061900
         TM    FLAG,FLAGMIS     Missing report?                      05 00062000
         BO    CSOMIS9E         Yes, skip reporting error            05 00062100
         B     CSOMIS9D                                              05 00062200
CSOMIS9C DS    0H                                                    05 00062300
         AP    NCCT,=P'+1'      Count total missing CSECT            15 00062400
         MVC   LINECMT(19),=C'Missing build CSECT'                   15 00062500
CSOMIS9D DS    0H                                                    05 00062600
         TM    FLAG,FLAGSUM                                             00062700
         BNO   CSOMIS10                                                 00062800
CSOMIS9E DS    0H                                                    05 00062900
         MVI   LINE,C' '                                                00063000
         MVC   LINE+1(L'LINE-1),LINE                                    00063100
         B     CSOMIS20                                                 00063200
CSOMIS10 DS    0H                                                       00063300
         BAL   R14,PRT                                                  00063400
CSOMIS20 DS    0H                                                       00063500
         AP    MODOCCT,=P'+1'   Original CSECT                          00063600
         BAL   R14,ORGGET                                               00063700
         B     PROC010                                                  00063800
*                                                                       00063900
*        Build CSECT not in Original                                    00064000
*                                                                       00064100
CSBMIS   DS    0H                                                       00064200
         MVC   LINEBLIB,BLDLIB                                          00064300
         MVC   LINEBMOD,BLDMOD                                          00064400
         MVC   LINEBCS,BLDCS                                            00064500
         MVC   LINEBLEN,BLDLEN                                          00064600
         MVI   LINESEP1,C'¦'                                            00064700
         MVI   LINESEP2,C'¦'                                            00064800
         MVC   LINECMT(19),=C'Extra CSECT in LMOD'                      00064900
         TM    FLAG,FLAGSUM                                             00065000
         BNO   CSBMIS10                                                 00065100
         MVI   LINE,C' '                                                00065200
         MVC   LINE+1(L'LINE-1),LINE                                    00065300
         B     CSBMIS30                                                 00065400
CSBMIS10 DS    0H                                                       00065500
         TM    FLAG,FLAGMIS                                             00065600
         BNO   CSBMIS20                                                 00065700
         MVI   LINE,C' '                                                00065800
         MVC   LINE+1(L'LINE-1),LINE                                    00065900
         B     CSBMIS30                                                 00066000
CSBMIS20 DS    0H                                                       00066100
         BAL   R14,PRT                                                  00066200
CSBMIS30 DS    0H                                                       00066300
         AP    MODBCCT,=P'+1'   Build CSECT                             00066400
         AP    ECCT,=P'+1'                                              00066500
         BAL   R14,BLDGET                                               00066600
         B     PROC010                                                  00066700
*                                                                       00066800
*        Original Load Module missing from Build                        00066900
*                                                                       00067000
MDOMIS   DS    0H                                                       00067100
         MVC   LINEOLIB,ORGLIB                                          00067200
         MVC   LINEOMOD,ORGMOD                                          00067300
         MVC   LINEOCS,ORGCS                                            00067400
         MVC   LINEOLEN,ORGLEN                                          00067500
         MVI   LINESEP1,C'¦'                                            00067600
         MVI   LINESEP2,C'¦'                                            00067700
* Check ignore table if there ignore difference                      10 00067800
         LA    R15,IGNTBL                                            10 00067900
MDOMIS9A DS    0H                                                    10 00068000
         C     R15,IGNPTR                                            10 00068100
         BE    MDOMIS9C                                              10 00068200
         CLC   ORGCS,0(R15)                                          10 00068300
         BE    MDOMIS9B                                              10 00068400
         CLC   ORGMOD,0(R15)                                         17 00068500
         BE    MDOMIS9B                                              17 00068600
         LA    R15,8(,R15)                                           10 00068700
         B     MDOMIS9A                                              10 00068800
MDOMIS9B DS    0H                                                    10 00068900
         AP    TOTBICT,=P'+1'   Mismatch ignored                     10 00069000
         AP    MODIGCT,=P'+1'   Count LMOD missing CSECT ignored     15 00069100
         AP    IMMCT,=P'+1'     Count ignored LMODs missing          21 00069200
         MVC   LINECMT(20),=C'Missing LMOD ignored'                  10 00069300
         TM    FLAG,FLAGERS     Report errors                        10 00069400
         BO    MDOMIS9E         Yes, skip ignored error              10 00069500
         TM    FLAG,FLAGMIS     Missing report?                      10 00069600
         BO    MDOMIS9E         Yes, skip reporting error            10 00069700
         B     MDOMIS9D                                              10 00069800
MDOMIS9C DS    0H                                                    10 00069900
         AP    NMCT,=P'+1'                                           10 00070000
         AP    MODIGCT,=P'+1'   Count LMOD missing CSECT ignored     15 00070100
         MVC   LINECMT(18),=C'Missing build LMOD'                    10 00070200
MDOMIS9D DS    0H                                                    10 00070300
         TM    FLAG,FLAGSUM                                             00070400
         BNO   MDOMIS10                                                 00070500
MDOMIS9E DS    0H                                                    10 00070600
         MVI   LINE,C' '                                                00070700
         MVC   LINE+1(L'LINE-1),LINE                                    00070800
         B     MDOMIS20                                                 00070900
MDOMIS10 DS    0H                                                       00071000
         BAL   R14,PRT                                                  00071100
MDOMIS20 DS    0H                                                       00071200
         AP    MODOCCT,=P'+1'   Original CSECT                          00071300
         BAL   R14,ORGGET                                               00071400
         B     PROC010                                                  00071500
*                                                                       00071600
*        Build Load Module missing in Original                          00071700
*                                                                       00071800
MDBMIS   DS    0H                                                       00071900
         MVC   LINEBLIB,BLDLIB                                          00072000
         MVC   LINEBMOD,BLDMOD                                          00072100
         MVC   LINEBCS,BLDCS                                            00072200
         MVC   LINEBLEN,BLDLEN                                          00072300
         MVI   LINESEP1,C'¦'                                            00072400
         MVI   LINESEP2,C'¦'                                            00072500
* Check ignore table if there ignore difference                      10 00072600
         LA    R15,IGNTBL                                            10 00072700
MDBMIS9A DS    0H                                                    10 00072800
         C     R15,IGNPTR                                            10 00072900
         BE    MDBMIS9C                                              10 00073000
         CLC   BLDCS,0(R15)                                          10 00073100
         BE    MDBMIS9B                                              10 00073200
         LA    R15,8(,R15)                                           10 00073300
         B     MDBMIS9A                                              10 00073400
MDBMIS9B DS    0H                                                    10 00073500
         AP    TOTBICT,=P'+1'   Mismatch ignored                     10 00073600
         AP    MODIGCT,=P'+1'   Count LMOD missing CSECT ignored     15 00073700
         AP    IEMCT,=P'+1'     Count LMOD missingignored            21 00073800
         MVC   LINECMT(24),=C'Extra build LMOD ignored'              15 00073900
         TM    FLAG,FLAGERS     Report errors                        10 00074000
         BO    MDBMIS9E         Yes, skip ignored error              10 00074100
         TM    FLAG,FLAGMIS     Missing report?                      10 00074200
         BO    MDBMIS9E         Yes, skip reporting error            10 00074300
         B     MDBMIS9D                                              10 00074400
MDBMIS9C DS    0H                                                    10 00074500
         AP    EMCT,=P'+1'                                           10 00074600
         MVC   LINECMT(16),=C'Extra build LMOD'                      10 00074700
MDBMIS9D DS    0H                                                    10 00074800
         TM    FLAG,FLAGSUM                                             00074900
         BNO   MDBMIS10                                                 00075000
MDBMIS9E DS    0H                                                    10 00075100
         MVI   LINE,C' '                                                00075200
         MVC   LINE+1(L'LINE-1),LINE                                    00075300
         B     MDBMIS30                                                 00075400
MDBMIS10 DS    0H                                                       00075500
         TM    FLAG,FLAGMIS                                             00075600
         BNO   MDBMIS20                                                 00075700
         MVI   LINE,C' '                                                00075800
         MVC   LINE+1(L'LINE-1),LINE                                    00075900
         B     MDBMIS30                                                 00076000
MDBMIS20 DS    0H                                                       00076100
         BAL   R14,PRT                                                  00076200
MDBMIS30 DS    0H                                                       00076300
         AP    MODBCCT,=P'+1'   Build CSECT                             00076400
         BAL   R14,BLDGET                                               00076500
         B     PROC010                                                  00076600
*                                                                       00076700
*        Original Library not in Build                                  00076800
*                                                                       00076900
LBOMIS   DS    0H                                                       00077000
         MVC   LINEOLIB,ORGLIB                                          00077100
         MVC   LINEOMOD,ORGMOD                                          00077200
         MVC   LINEOCS,ORGCS                                            00077300
         MVC   LINEOLEN,ORGLEN                                          00077400
         MVI   LINESEP1,C'¦'                                            00077500
         MVI   LINESEP2,C'¦'                                            00077600
         MVC   LINECMT(25),=C'No matching build library'                00077700
         TM    FLAG,FLAGSUM                                             00077800
         BNO   LBOMIS10                                                 00077900
         MVI   LINE,C' '                                                00078000
         MVC   LINE+1(L'LINE-1),LINE                                    00078100
         B     LBOMIS20                                                 00078200
LBOMIS10 DS    0H                                                       00078300
         BAL   R14,PRT                                                  00078400
LBOMIS20 DS    0H                                                       00078500
         AP    MODOCCT,=P'+1'   Original CSECT                          00078600
         BAL   R14,ORGGET                                               00078700
         B     PROC010                                                  00078800
*                                                                       00078900
*        Build Library not in Original                                  00079000
*                                                                       00079100
LBBMIS   DS    0H                                                       00079200
         MVC   LINEBLIB,BLDLIB                                          00079300
         MVC   LINEBMOD,BLDMOD                                          00079400
         MVC   LINEBCS,BLDCS                                            00079500
         MVC   LINEBLEN,BLDLEN                                          00079600
         MVI   LINESEP1,C'¦'                                            00079700
         MVI   LINESEP2,C'¦'                                            00079800
         MVC   LINECMT(27),=C'No matching original library'             00079900
         TM    FLAG,FLAGSUM                                             00080000
         BNO   LBBMIS10                                                 00080100
         MVI   LINE,C' '                                                00080200
         MVC   LINE+1(L'LINE-1),LINE                                    00080300
         B     LBBMIS30                                                 00080400
LBBMIS10 DS    0H                                                       00080500
         TM    FLAG,FLAGMIS                                             00080600
         BNO   LBBMIS20                                                 00080700
         MVI   LINE,C' '                                                00080800
         MVC   LINE+1(L'LINE-1),LINE                                    00080900
         B     LBBMIS30                                                 00081000
LBBMIS20 DS    0H                                                       00081100
         BAL   R14,PRT                                                  00081200
LBBMIS30 DS    0H                                                       00081300
         AP    MODBCCT,=P'+1'   Build CSECT                             00081400
         BAL   R14,BLDGET                                               00081500
         B     PROC010                                                  00081600
*                                                                       00081700
*        Statistics                                                     00081800
*                                                                       00081900
TOTALS   DS    0H                                                       00082000
         BAL   R14,BRKMOD                                               00082100
         BAL   R14,BRKLIB                                               00082200
         MVC   LINEOLCT,=X'40206B2020206B202120'                        00082300
         ED    LINEOLCT,TOTOLCT                                         00082400
         MVC   LINEOMCT,=X'40206B2020206B202120'                        00082500
         ED    LINEOMCT,TOTOMCT                                         00082600
         MVC   LINEOCCT,=X'40206B2020206B202120'                        00082700
         ED    LINEOCCT,TOTOCCT                                         00082800
         MVC   LINEBLCT,=X'40206B2020206B202120'                        00082900
         ED    LINEBLCT,TOTBLCT                                         00083000
         CP    TOTOLCT,TOTBLCT                                          00083100
         BE    TOTALS10                                                 00083200
         MVI   LINEBLCD,C'*'                                            00083300
TOTALS10 DS    0H                                                       00083400
         MVC   LINEBMCT,=X'40206B2020206B202120'                        00083500
         ED    LINEBMCT,TOTBMCT                                         00083600
         CP    TOTOMCT,TOTBMCT                                          00083700
         BE    TOTALS20                                                 00083800
         MVI   LINEBMCD,C'*'                                            00083900
TOTALS20 DS    0H                                                       00084000
         MVC   LINEBCCT,=X'40206B2020206B202120'                        00084100
         ED    LINEBCCT,TOTBCCT                                         00084200
         CP    TOTOCCT,TOTBCCT                                          00084300
         BE    TOTALS30                                                 00084400
         MVI   LINEBCCD,C'*'                                            00084500
TOTALS30 DS    0H                                                       00084600
         MVC   LINEBDCT,=X'40206B2020206B202120'                        00084700
         ED    LINEBDCT,TOTBDCT                                         00084800
         MVC   LINEBNCT,=X'40206B2020206B202120'                        00084900
         ED    LINEBNCT,TOTBNCT                                         00085000
         CP    TOTOECT,=P'+0'                                           00085100
         BE    TOTALS40                                                 00085200
         MVC   LINECMT(12),=C'Not Editable'                             00085300
         MVC   LINECMT+12(10),=X'40206B2020206B202120'                  00085400
         ED    LINECMT+12(10),TOTOECT                                   00085500
TOTALS40 DS    0H                                                       00085600
         BAL   R14,PRT                                                  00085700
         BAL   R14,PRT                                                  00085800
*                                                                       00085900
         MVC   LINE+1(23),=C'Unequal difference 1-10'                21 00086000
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00086100
         ED    LINE+30(10),NE1XCT                                    21 00086200
         BAL   R14,PRT                                               21 00086300
         MVC   LINE+1(25),=C'Unequal difference 11-100'              21 00086400
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00086500
         ED    LINE+30(10),NE10XCT                                   21 00086600
         BAL   R14,PRT                                               21 00086700
         MVC   LINE+1(27),=C'Unequal difference 101-1000'            21 00086800
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00086900
         ED    LINE+30(10),NE100XCT                                  21 00087000
         BAL   R14,PRT                                               21 00087100
         MVC   LINE+1(28),=C'Unequal difference over 1000'           21 00087200
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00087400
         ED    LINE+30(10),NEBIGCT                                   21 00087500
         BAL   R14,PRT                                               21 00087600
*                                                                    21 00087700
         MVC   LINE+1(22),=C'Length difference 1-10'                 21 00087800
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00087900
         ED    LINE+30(10),LN1XCT                                    21 00088000
         BAL   R14,PRT                                               21 00088100
         MVC   LINE+1(24),=C'Length difference 11-100'               21 00088200
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00088300
         ED    LINE+30(10),LN10XCT                                   21 00088400
         BAL   R14,PRT                                               21 00088500
         MVC   LINE+1(26),=C'Length difference 101-1000'             21 00088600
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00088700
         ED    LINE+30(10),LN100XCT                                  21 00088800
         BAL   R14,PRT                                               21 00088900
         MVC   LINE+1(27),=C'Length difference over 1000'            21 00089000
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00089100
         ED    LINE+30(10),LNBIGCT                                   21 00089200
         BAL   R14,PRT                                               21 00089300
         BAL   R14,PRT                                               21 00089400
*                                                                       00089500
         MVC   LINE+1(14),=C'Missing CSECTs'                         10 00089600
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00089700
         ED    LINE+20(10),NCCT                                         00089800
         CP    IMCCT,=P'+0'     Ignored CSECTs missing zero          21 00089900
         BE    TOTALS43         Yes, skip printing it                21 00090000
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00090100
         ED    LINE+30(10),IMCCT                                     21 00090200
         MVC   LINE+41(7),=C'Ignored'                                21 00090300
TOTALS43 DS    0H                                                    21 00090400
         BAL   R14,PRT                                                  00090500
*                                                                       00090600
         MVC   LINE+1(12),=C'Extra CSECTs'                           10 00090700
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00090800
         ED    LINE+20(10),ECCT                                         00090900
         CP    IECCT,=P'+0'     Ignored CSECTs extra zero            21 00091000
         BE    TOTALS44         Yes, skip printing it                21 00091100
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00091200
         ED    LINE+30(10),IECCT                                     21 00091300
         MVC   LINE+41(7),=C'Ignored'                                21 00091400
TOTALS44 DS    0H                                                    21 00091500
         BAL   R14,PRT                                                  00091600
*                                                                       00091700
         MVC   LINE+1(13),=C'Missing LMODs'                             00091800
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00091900
         ED    LINE+20(10),NMCT                                         00092000
         CP    IMMCT,=P'+0'     Ignored LMODs missing zero           21 00092100
         BE    TOTALS46         Yes, skip printing it                21 00092200
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00092300
         ED    LINE+30(10),IMMCT                                     21 00092400
         MVC   LINE+41(7),=C'Ignored'                                21 00092500
TOTALS46 DS    0H                                                    21 00092600
         BAL   R14,PRT                                                  00092700
*                                                                       00092800
         MVC   LINE+1(11),=C'Extra LMODs'                               00092900
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00093000
         ED    LINE+20(10),EMCT                                         00093100
         CP    IEMCT,=P'+0'     Ignored LOMDs extra zero             21 00093200
         BE    TOTALS48         Yes, skip printing it                21 00093300
         MVC   LINE+30(10),=X'40206B2020206B202120'                  21 00093400
         ED    LINE+30(10),IEMCT                                     21 00093500
         MVC   LINE+41(7),=C'Ignored'                                21 00093600
TOTALS48 DS    0H                                                    21 00093700
         BAL   R14,PRT                                                  00093800
*                                                                       00093900
         CP    TOTOECT,=P'+0'                                           00094000
         BE    TOTALS50                                                 00094100
         MVC   LINE+1(12),=C'Not Editable'                              00094200
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00094300
         ED    LINE+20(10),TOTOECT                                      00094400
         BAL   R14,PRT                                                  00094500
TOTALS50 DS    0H                                                       00094600
         MVC   LINE+1(14),=C'Compared equal'                            00094700
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00094800
         ED    LINE+20(10),TOTBECT                                      00094900
         BAL   R14,PRT                                                  00095000
         MVC   LINE+1(18),=C'Module dif ignored'                     09 00095100
         MVC   LINE+20(10),=X'40206B2020206B202120'                  03 00095200
         ED    LINE+20(10),TOTBICT                                   03 00095300
         BAL   R14,PRT                                               03 00095400
         MVC   LINE+1(19),=C'Compare dif ignored'                    09 00095500
         MVC   LINE+20(10),=X'40206B2020206B202120'                  09 00095600
         ED    LINE+20(10),TOTDFCT                                   09 00095700
         BAL   R14,PRT                                               09 00095800
         MVC   LINE+1(12),=C' Total equal'                           04 00095900
         MVC   LINE+20(10),=X'40206B2020206B202120'                  04 00096000
         ZAP   DWORD,TOTBECT                                         04 00096100
         AP    DWORD,TOTBICT                                         04 00096200
         ED    LINE+20(10),DWORD+4                                   04 00096300
         BAL   R14,PRT                                                  00096400
         MVC   LINE+1(18),=C'Compared not equal'                        00096500
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00096600
         ED    LINE+20(10),TOTBNCT                                      00096700
         BAL   R14,PRT                                                  00096800
         MVC   LINE+1(16),=C'Length different'                          00096900
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00097000
         ED    LINE+20(10),TOTBDCT                                      00097100
         BAL   R14,PRT                                                  00097200
         MVC   LINE+1(16),=C' Total not equal'                       03 00097300
         MVC   LINE+20(10),=X'40206B2020206B202120'                  03 00097400
         ZAP   DWORD,TOTBNCT                                         03 00097500
         AP    DWORD,TOTBDCT                                         03 00097600
         ED    LINE+20(10),DWORD+4                                   03 00097700
         BAL   R14,PRT                                               03 00097800
         MVC   LINE+3(12),=C'Total CSECTs'                           04 00097900
         MVC   LINE+20(10),=X'40206B2020206B202120'                     00098000
         ED    LINE+20(10),TOTBCCT                                      00098100
         BAL   R14,PRT                                                  00098200
         LA    R2,0                RETURN CODE                          00098300
*                                                                       00098400
*        Termination                                                    00098500
*                                                                       00098600
EXIT     DS    0H                                                       00098700
         TM    FLAG1,FLAG1CSV          Is CSV DD OPEN?               08 00098800
         BNZ   EXITNOCS                No, skip OPEN                 08 00098900
         CLOSE (CSVDCB)                CLOSE CSV DCB                 08 00099000
EXITNOCS DS    0H                                                    08 00099100
         CLOSE (SYSPRINT,,ORG,,BLD),                                 19*00099200
               MF=(E,OPNLST)                                            00099300
         LR    R15,R2                                                   00099400
         L     R13,4(,R13)                                              00099500
         L     R14,12(,R13)                                             00099600
         LM    R0,R12,20(R13)                                           00099700
         BR    R14                                                      00099800
QUIT     DS    0H                                                       00099900
         L     R13,4(,R13)                                              00100000
         LM    R14,R12,12(R13)                                          00100100
         LA    R15,16                                                   00100200
         BR    R14                                                      00100300
*                                                                    02 00100400
*        Convert 6 byte character hex to binary                      02 00100500
*                                                                    02 00100600
HEXCVT   DS    0H                                                    02 00100700
         ST    R14,HEXCVT14                                          02 00100800
         SR    R0,R0                                                 02 00100900
         SR    R15,R15                                               02 00101000
         LA    R14,6                                                 02 00101100
HEXCVTNX DS    0H                                                    02 00101200
         IC    R15,0(,R1)                                            02 00101300
         N     R15,=A(15)                                            02 00101400
         CLI   0(R1),C'F'                                            02 00101500
         BH    HEXCVTND                                              02 00101600
         LA    R15,9(,R15)                                           02 00101700
HEXCVTND DS    0H                                                    02 00101800
         SLL   R0,4                                                  02 00101900
         AR    R0,R15                                                02 00102000
         LA    R1,1(,R1)                                             02 00102100
         BCT   R14,HEXCVTNX                                          02 00102200
         L     R14,HEXCVT14                                          02 00102300
         BR    R14                                                   02 00102400
*                                                                       00102500
*        Read Original record                                           00102600
*                                                                       00102700
ORGGET   DS    0H                                                       00102800
         ST    R14,ORGGET14                                             00102900
ORGGETRD DS    0H                                                       00103000
         TM    FLAG,FLAGEOFO                                            00103100
         BO    ORGEOF1                                                  00103200
         GET   ORG,ORGREC                                               00103300
         AP    ORGCT,=P'+1'                                             00103400
         TM    FLAG,FLAGDBG                                             00103500
         BNO   ORGGETCK                                                 00103600
         MVC   LINE+1(2),=C'O>'                                         00103700
         MVC   LINE+3(L'ORGREC),ORGREC                                  00103800
         BAL   R14,PRT                                                  00103900
ORGGETCK DS    0H                                                       00104000
         CLC   ORGTYP,=CL8'INCLUDE'                                     00104100
         BNE   ORGGETRD                                                 00104200
         CLI   LIB,C' '                LIB= specified                18 00104300
         BE    ORGGETXT                No, continue                  18 00104400
         CLC   ORGLIB,LIB              Library selected              18 00104500
         BNE   ORGGETRD                No, skip                      18 00104600
ORGGETXT DS    0H                                                    18 00104700
         L     R14,ORGGET14                                             00104800
         BR    R14                                                      00104900
*                                                                       00105000
ORGEOF   DS    0H                                                       00105100
         OI    FLAG,FLAGEOFO                                            00105200
         MVI   ORGREC,C'9'                                              00105300
         MVC   ORGREC+1(L'ORGREC-1),ORGREC                              00105400
         MVC   ORGTYP,=CL8'INCLUDE'                                     00105500
ORGEOF1  DS    0H                                                       00105600
         TM    FLAG,FLAGEOFB                                            00105700
         BO    TOTALS                                                   00105800
         B     ORGGETXT                                                 00105900
*                                                                       00106000
*        Read Build record                                              00106100
*                                                                       00106200
BLDGET   DS    0H                                                       00106300
         ST    R14,BLDGET14                                             00106400
BLDGETRD DS    0H                                                       00106500
         TM    FLAG,FLAGEOFB                                            00106600
         BO    BLDEOF1                                                  00106700
         GET   BLD,BLDREC                                               00106800
         AP    BLDCT,=P'+1'                                             00106900
         TM    FLAG,FLAGDBG                                             00107000
         BNO   BLDGETCK                                                 00107100
         MVC   LINE+1(2),=C'B>'                                         00107200
         MVC   LINE+3(L'BLDREC),BLDREC                                  00107300
         BAL   R14,PRT                                                  00107400
BLDGETCK DS    0H                                                       00107500
         CLC   BLDTYP,=CL8'INCLUDE'                                     00107600
         BNE   BLDGETRD                                                 00107700
         CLI   LIB,C' '                LIB= specified                18 00107800
         BE    BLDGETBR                No, continue                  18 00107900
         CLC   BLDLIB,LIB              Library selected              18 00108000
         BNE   BLDGETRD                No, skip                      18 00108100
BLDGETBR DS    0H                                                    18 00108200
         CLC   BLDLIB,PREVBLIB                                          00108300
         BE    CHKBBRK                                                  00108400
         AP    TOTBLCT,=P'+1'   Build library                           00108500
         MVC   PREVBLIB,BLDLIB                                          00108600
         AP    LIBBMCT,=P'+1'   Build LMOD                              00108700
         MVC   PREVBMOD,BLDMOD                                          00108800
         B     CHKOBRK                                                  00108900
CHKBBRK  DS    0H                                                       00109000
         CLC   BLDMOD,PREVBMOD                                          00109100
         BE    CHKOBRK                                                  00109200
         AP    LIBBMCT,=P'+1'   Build LMOD                              00109300
         CLC   ORGMOD,PREVBMOD  break in lmod and missing            15 00109400
         BNH   BLDGETNB         NO                                   15 00109500
         BAL   R14,BRKMOD                                            15 00109600
BLDGETNB DS    0H                                                    15 00109700
         MVC   PREVBMOD,BLDMOD                                          00109800
CHKOBRK  DS    0H                                                       00109900
         L     R14,BLDGET14                                             00110000
BLDGETXT DS    0H                                                       00110100
         BR    R14                                                      00110200
*                                                                       00110300
BLDEOF   DS    0H                                                       00110400
         OI    FLAG,FLAGEOFB                                            00110500
         MVI   BLDREC,C'9'                                              00110600
         MVC   BLDREC+1(L'BLDREC-1),BLDREC                              00110700
         MVC   BLDTYP,=CL8'INCLUDE'                                     00110800
BLDEOF1  DS    0H                                                       00110900
         TM    FLAG,FLAGEOFO                                            00111000
         BO    TOTALS                                                   00111100
         B     BLDGETXT                                                 00111200
*                                                                       00111300
*        Library Break                                                  00111400
*                                                                       00111500
BRKLIB   DS    0H                                                       00111600
         ST    R14,BRKLIB14                                             00111700
         TM    FLAG1,FLAG1CSV                                        08 00111800
         BNO   BRKLIB05                                              08 00111900
         CLI   ORGLIB,C'9'                                           08 00112000
         BE    BRKLIB05                                              08 00112100
         BAL   R14,LIBCSV                                            08 00112200
BRKLIB05 DS    0H                                                    08 00112300
         MVC   LINEOLIB,PREVOLIB                                     15 00112400
         MVC   LINEOMCT,=X'40206B2020206B202120'                        00112500
         ED    LINEOMCT,LIBOMCT                                         00112600
         MVC   LINEOCCT,=X'40206B2020206B202120'                        00112700
         ED    LINEOCCT,LIBOCCT                                         00112800
         MVC   LINEBMCT,=X'40206B2020206B202120'                        00112900
         ED    LINEBMCT,LIBBMCT                                         00113000
         CP    LIBOMCT,LIBBMCT                                          00113100
         BE    BRKLIB10                                                 00113200
         MVI   LINEBMCD,C'*'                                            00113300
BRKLIB10 DS    0H                                                       00113400
         MVC   LINEBCCT,=X'40206B2020206B202120'                        00113500
         ED    LINEBCCT,LIBBCCT                                         00113600
         CP    LIBOCCT,LIBBCCT                                          00113700
         BE    BRKLIB20                                                 00113800
         MVI   LINEBCCD,C'*'                                            00113900
BRKLIB20 DS    0H                                                       00114000
         MVC   LINEBDCT,=X'40206B2020206B202120'                        00114100
         ED    LINEBDCT,LIBBDCT                                         00114200
         MVC   LINEBNCT,=X'40206B2020206B202120'                        00114300
         ED    LINEBNCT,LIBBNCT                                         00114400
         CP    LIBOECT,=P'+0'                                           00114500
         BE    BRKLIB30                                                 00114600
         MVC   LINECMT(12),=C'Not Editable'                             00114700
         MVC   LINECMT+12(10),=X'40206B2020206B202120'                  00114800
         ED    LINECMT+12(10),LIBOECT                                   00114900
BRKLIB30 DS    0H                                                       00115000
         TM    FLAG,FLAGSUM                                             00115100
         BNO   BRKLIB40                                              15 00115200
         BAL   R14,PRT                                               15 00115300
         B     BRKLIBD0                                              15 00115400
BRKLIB40 DS    0H                                                       00115500
         MVI   LINESEP1,C'¦'                                         07 00115600
         MVI   LINESEP2,C'¦'                                         07 00115700
         BAL   R14,PRT                                                  00115800
         MVI   LINESEP1,C'¦'                                         07 00115900
         MVI   LINESEP2,C'¦'                                         07 00116000
         BAL   R14,PRT                                                  00116100
BRKLIBD0 DS    0H                                                       00116200
         AP    TOTOLCT,=P'+1'   Original library                        00116300
         MVC   PREVOLIB,ORGLIB                                          00116400
         AP    TOTOMCT,LIBOMCT  Original total LMOD                     00116500
         AP    TOTOCCT,LIBOCCT  Original total CSECT                    00116600
         AP    TOTOECT,LIBOECT  Original not editable                   00116700
         AP    TOTBMCT,LIBBMCT  Build total LMOD                        00116800
         AP    TOTBCCT,LIBBCCT  Build total CSECT                       00116900
         AP    TOTBDCT,LIBBDCT  Build total length difference           00117000
         AP    TOTBNCT,LIBBNCT  Build total CSECT don't match           00117100
         AP    TOTBECT,LIBBECT  Compared equal                          00117200
         ZAP   LIBOMCT,=P'+0'                                           00117300
         ZAP   LIBOCCT,=P'+0'                                           00117400
         ZAP   LIBOECT,=P'+0'                                           00117500
         ZAP   LIBBMCT,=P'+0'                                           00117600
         ZAP   LIBBCCT,=P'+0'                                           00117700
         ZAP   LIBBDCT,=P'+0'                                           00117800
         ZAP   LIBBNCT,=P'+0'                                           00117900
         ZAP   LIBBECT,=P'+0'                                           00118000
         L     R14,BRKLIB14                                             00118100
         BR    R14                                                      00118200
*                                                                       00118300
*        Load Module Break                                              00118400
*                                                                       00118500
BRKMOD   DS    0H                                                       00118600
         ST    R14,BRKMOD14                                             00118700
         MVC   LINEOLIB,PREVOLIB                                     15 00118800
         MVC   LINEOMOD,PREVOMOD                                     15 00118900
         CLC   ORGMOD,PREVBMOD                                       15 00119000
         BNH   BRKMOD05                                              15 00119100
         MVC   LINEOMOD,PREVBMOD                                     15 00119200
BRKMOD05 DS    0H                                                    15 00119300
         MVC   LINEOCCT,=X'40206B2020206B202120'                        00119400
         ED    LINEOCCT,MODOCCT                                         00119500
         MVC   LINEBCCT,=X'40206B2020206B202120'                        00119600
         ED    LINEBCCT,MODBCCT                                         00119700
         CP    MODOCCT,MODBCCT                                          00119800
         BE    BRKMOD10                                                 00119900
         MVI   LINEBCCD,C'*'                                            00120000
BRKMOD10 DS    0H                                                       00120100
         MVC   LINEBDCT,=X'40206B2020206B202120'                        00120200
         ED    LINEBDCT,MODBDCT                                         00120300
         MVC   LINEBNCT,=X'40206B2020206B202120'                        00120400
         ED    LINEBNCT,MODBNCT                                         00120500
         CP    MODIGCT,=P'+0'                                        15 00120600
         BE    BRKMOD15                                              15 00120700
         MVC   LINECMT(7),=C'Ignored'                                15 00120800
         MVC   LINECMT+7(10),=X'40206B2020206B202120'                15 00120900
         ED    LINECMT+7(10),MODIGCT                                 15 00121000
BRKMOD15 DS    0H                                                    15 00121100
         TM    FLAG,FLAGSUM                                             00121200
         BNO   BRKMOD20                                                 00121300
         MVI   LINE,C' '                                                00121400
         MVC   LINE+1(L'LINE-1),LINE                                    00121500
         B     BRKMODA0                                                 00121600
BRKMOD20 DS    0H                                                       00121700
         TM    FLAG,FLAGMIS                                             00121800
         BNO   BRKMOD50                                                 00121900
         CP    MODOCCT,MODBCCT                                          00122000
         BE    BRKMOD30                                                 00122100
         CP    MODIGCT,=P'+0'                                        15 00122200
         BE    BRKMOD25                                              15 00122300
         ZAP   DWORD,MODOCCT               Original CSECT count      15 00122400
         SP    DWORD,MODBCCT               Less build CSECT count    15 00122500
         OI    DWORD+L'DWORD-1,X'0F'       Absolute value            15 00122600
         SP    DWORD,MODIGCT               Less missing ingore count 15 00122700
         CP    DWORD,=P'+0'                All errors ignored        15 00122800
         BE    BRKMOD30                                              15 00122900
BRKMOD25 DS    0H                                                    15 00123000
         MVI   LINESEP1,C'¦'                                         07 00123100
         MVI   LINESEP2,C'¦'                                         07 00123200
         BAL   R14,PRT                                                  00123300
         MVI   LINESEP1,C'¦'                                         07 00123400
         MVI   LINESEP2,C'¦'                                         07 00123500
         BAL   R14,PRT                                                  00123600
         B     BRKMOD40                                                 00123700
BRKMOD30 DS    0H                                                       00123800
         MVI   LINE,C' '                                                00123900
         MVC   LINE+1(L'LINE-1),LINE                                    00124000
BRKMOD40 DS    0H                                                       00124100
         B     BRKMODA0                                                 00124200
BRKMOD50 DS    0H                                                       00124300
         TM    FLAG,FLAGERS                                             00124400
         BNO   BRKMOD90                                                 00124500
         CP    MODOCCT,MODBCCT                                          00124600
         BNE   BRKMOD55                                              15 00124700
         CP    MODBNCT,=P'+0'                                        08 00124800
         BNE   BRKMOD60                                              08 00124900
         CP    MODBDCT,=P'+0'                                           00125000
         BNE   BRKMOD60                                              15 00125100
         CP    MODIGCT,=P'+0'                                        15 00125200
         BE    BRKMOD70                                              15 00125300
BRKMOD55 DS    0H                                                    15 00125400
         ZAP   DWORD,MODOCCT               Original CSECT count      15 00125500
         SP    DWORD,MODBCCT               Less build CSECT count    15 00125600
         OI    DWORD+L'DWORD-1,X'0F'       Absolute value            15 00125700
         SP    DWORD,MODIGCT               Less missing ingore count 15 00125800
         CP    DWORD,=P'+0'                All errors ignored        15 00125900
         BE    BRKMOD70                                              15 00126000
BRKMOD60 DS    0H                                                       00126100
         MVI   LINESEP1,C'¦'                                         07 00126200
         MVI   LINESEP2,C'¦'                                         07 00126300
         BAL   R14,PRT                                                  00126400
         MVI   LINESEP1,C'¦'                                         07 00126500
         MVI   LINESEP2,C'¦'                                         07 00126600
         BAL   R14,PRT                                                  00126700
         B     BRKMOD80                                                 00126800
BRKMOD70 DS    0H                                                       00126900
         MVI   LINE,C' '                                                00127000
         MVC   LINE+1(L'LINE-1),LINE                                    00127100
BRKMOD80 DS    0H                                                       00127200
         B     BRKMODA0                                                 00127300
BRKMOD90 DS    0H                                                       00127400
         MVI   LINESEP1,C'¦'                                         07 00127500
         MVI   LINESEP2,C'¦'                                         07 00127600
         BAL   R14,PRT                                                  00127700
         MVI   LINESEP1,C'¦'                                         07 00127800
         MVI   LINESEP2,C'¦'                                         07 00127900
         BAL   R14,PRT                                                  00128000
BRKMODA0 DS    0H                                                       00128100
         AP    LIBOMCT,=P'+1'   Original LMOD                           00128200
         MVC   PREVOMOD,ORGMOD                                          00128300
         AP    LIBOCCT,MODOCCT  Original total CSECT                    00128400
         AP    LIBOECT,MODOECT  Original not editable                   00128500
         AP    LIBBCCT,MODBCCT  Build total CSECT                       00128600
         AP    LIBBDCT,MODBDCT  Build total length difference           00128700
         AP    LIBBNCT,MODBNCT  Build total CSECT don't match           00128800
         AP    LIBBECT,MODBECT  Compared equal                          00128900
         ZAP   MODOCCT,=P'+0'                                           00129000
         ZAP   MODOECT,=P'+0'                                           00129100
         ZAP   MODBCCT,=P'+0'                                           00129200
         ZAP   MODBDCT,=P'+0'                                           00129300
         ZAP   MODBNCT,=P'+0'                                           00129400
         ZAP   MODBECT,=P'+0'                                           00129500
         ZAP   MODIGCT,=P'+0'                                        15 00129600
         L     R14,BRKMOD14                                             00129700
         BR    R14                                                      00129800
*                                                                    08 00129900
*        Generate statistics on CSV format for each library          08 00130000
*                                                                    08 00130100
LIBCSV   DS    0H                                                    08 00130200
         ST    R14,LIBCSV14                                          08 00130300
         MVI   CSVREC,C' '                                           08 00130400
         MVC   CSVREC+1(L'CSVREC-1),CSVREC                           08 00130500
         MVI   CSVLIB,C'"'                                           08 00130600
         MVC   CSVLIB+1(8),ORGLIB                                    08 00130700
         MVI   CSVLIB+9,C'"'                                         08 00130800
         MVI   CSVSEP1,C','                                          08 00130900
         UNPK  CSVOMCT,LIBOMCT                                       08 00131000
         OI    CSVOMCT+6,C'0'                                        08 00131100
         MVI   CSVSEP2,C','                                          08 00131200
         UNPK  CSVOCCT,LIBOCCT                                       08 00131300
         OI    CSVOCCT+6,C'0'                                        08 00131400
         MVI   CSVSEP3,C','                                          08 00131500
         UNPK  CSVBMCT,LIBBMCT                                       08 00131600
         OI    CSVBMCT+6,C'0'                                        08 00131700
         MVI   CSVSEP4,C','                                          08 00131800
         UNPK  CSVBCCT,LIBBCCT                                       08 00131900
         OI    CSVBCCT+6,C'0'                                        08 00132000
         MVI   CSVSEP5,C','                                          08 00132100
         UNPK  CSVBDCT,LIBBDCT                                       08 00132200
         OI    CSVBDCT+6,C'0'                                        08 00132300
         MVI   CSVSEP6,C','                                          08 00132400
         UNPK  CSVBNCT,LIBBNCT                                       08 00132500
         OI    CSVBNCT+6,C'0'                                        08 00132600
         PUT   CSVDCB,CSVREC                                         08 00132700
         L     R14,LIBCSV14                                          08 00132800
         BR    R14                                                   08 00132900
**********************************************************************  00133000
*                                                                       00133100
*        INITIALIZATION                                                 00133200
*                                                                       00133300
**********************************************************************  00133400
INIT     DS    0H                                                       00133500
         ST    R14,INITR14                                              00133600
         OPEN  (SYSPRINT,(OUTPUT),ORG,(INPUT),BLD,(INPUT)),          19*00133700
               MF=(E,OPNLST)                                         19 00133800
         TM    SYSPRINT+48,16                                           00133900
         BZ    QUIT                                                     00134000
         TM    ORG+48,16                                                00134100
         BZ    QUIT                                                     00134200
         TM    BLD+48,16                                                00134300
         BZ    QUIT                                                     00134400
         TIME  BIN                     GET CURRENT DATE AND TIME        00134500
         ST    R1,CURDATE              SAVE DATE                        00134600
         SRDL  R0,32                   GET DOUBLE WORD TIME             00134700
         D     R0,=F'+6000'            GET MINUTES                      00134800
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     00134900
         SLR   R0,R0                   CLEAR                            00135000
         D     R0,=F'+60'              GET HOURS / MINS                 00135100
         MH    R0,=H'+10000'           GET MINUTES                      00135200
         AR    R15,R0                  ADD TO GET MM:SS.TH              00135300
         M     R0,=F'+1000000'         GET HOURS                        00135400
         AR    R1,R15                  GET HH:MM:SS.TH                  00135500
         CVD   R1,DWORD                GET TIME TO DECIMAL              00135600
         MVC   TIMWRK4,=X'402021204B20204B20204B2020'                   00135700
         ED    TIMWRK4,DWORD+3         EDIT TIME                        00135800
         MVC   HD1TOD(8),TIMWRK4+2     MOVE TIME                        00135900
         ZAP   JULWRK2,CURDATE+2(2)    GET JULIAN DATE                  00136000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    00136100
         ZAP   JULWRK6,=P'+28'         FEB = 28                         00136200
         MVO   DWORD,CURDATE+1(1)      SIGN YEAR                        00136300
         DP    DWORD,=P'+4'            DIVIDE BY 4                      00136400
         CP    DWORD+7(1),=P'+0'       IS IT A LEAP YEAR ?              00136500
         BNZ   JULCVT2                  NO                              00136600
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    00136700
         ZAP   JULWRK6,=P'+29'         FEB = 29                         00136800
JULCVT2  DS    0H                                                       00136900
         LA    R1,JULTBL1              POINT TO JANUARY                 00137000
         SLR   R2,R2                   SET COUNTER                      00137100
JULCVT4  DS    0H                                                       00137200
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              00137300
         BNP   JULCVT6                 IF EQUAL OR LESS THAN 0, BRANCH  00137400
         BCTR  R1,0                    POINT TO NEXT MONTH              00137500
         BCTR  R1,0                    POINT TO NEXT MONTH              00137600
         LA    R2,3(,R2)               UP INDEX                         00137700
         B     JULCVT4                 LOOP                             00137800
JULCVT6  DS    0H                                                       00137900
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                00138000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    00138100
         MVC   HD1DATE(3),0(R2)        MOVE MONTH                       00138200
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     00138300
         UNPK  HD1DATE+4(2),JULWRK2    GET DAYS                         00138400
         CLI   HD1DATE+4,C'0'          FIRST 9 DAYS ?                   00138500
         LA    R1,HD1DATE+6            SET POINTER                      00138600
         BNE   JULCVT7                  NO                              00138700
         MVC   HD1DATE+4(1),HD1DATE+5  MOVE UNITS DIGIT                 00138800
         BCTR  R1,0                    DROP POINTER                     00138900
JULCVT7  DS    0H                                                       00139000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  00139100
         TM    CURDATE,1               YEAR 2000?                       00139200
         BNO   JULCVT8                  NO, CONTINUE                    00139300
         MVC   2(2,R1),=C'20'          Y2K                              00139400
JULCVT8  DS    0H                                                       00139500
         UNPK  DWORD(3),CURDATE+1(2)   UNPACK YEAR                      00139600
         MVC   4(2,R1),DWORD           GET YEAR                         00139700
         MVC   LINE+1(16),=C'Program version='                       03 00139800
         MVC   LINE+17(L'PGMID),PGMID                                03 00139900
         BAL   R14,PRT                                               03 00140000
*                                                                       00140100
         MVC   LINE+1(5),=C'PARM='     MOVE PARAMETER INFO LITERAL      00140200
         CLI   1(R9),0                 ANY PARAMETER?                09 00140300
         BE    PRMPRT                  NO, SKIP MOVE                    00140400
         LH    R1,0(,R9)               GET PARMETER LENGTH           09 00140500
         BCTR  R1,0                    MAKE MACHINE LENGTH              00140600
         EX    R1,PRMMVC               MOVE PARM TO PRINT LINE          00140700
PRMPRT   DS    0H                                                       00140800
         BAL   R14,PRT                 PRINT A LINE                     00140900
         LH    R2,0(,R9)               GET PARM LENGTH               09 00141000
         LA    R9,2(,R9)               SKIP LENGTH                   09 00141100
         ST    R9,PRMSTART             SAVE PARM START               09 00141200
PRMSCN   DS    0H                                                       00141300
         LTR   R2,R2                   END OF PARM?                     00141400
         BZ    PRMEND                  YES, PARM PARSED                 00141500
         CLI   0(R9),C','              SEPERATOR?                    09 00141600
         BNE   PRMCHK                  NO, CHECK VALUES                 00141700
         LA    R9,1(,R9)               SKIP COMMA                    09 00141800
         BCTR  R2,0                    DECREMENT LENGTH                 00141900
         B     PRMSCN                  CONTINUE SCAN                    00142000
PRMCHK   DS    0H                                                       00142100
         CH    R2,=H'4'                LONG ENOUGH?                  11 00142200
         BL    PRMERR                  No, error                     11 00142300
         CLC   =C'LIST',0(R9)          LIST?                         11 00142400
         BE    PRMLST                  Yes, handle it                11 00142500
         CH    R2,=H'5'                LONG ENOUGH?                     00142600
         BL    PRMERR                  No, error                        00142700
         CLC   =C'DEBUG',0(R9)         DEBUG?                        09 00142800
         BE    PRMDBG                  Yes, handle it                   00142900
         CLC   =C'LIB=',0(R9)          LIB=?                         18 00143000
         BE    PRMLIB                  Yes, handle it                18 00143100
         CH    R2,=H'6'                LONG ENOUGH?                     00143200
         BL    PRMERR                  No, error                        00143300
         CLC   =C'ERRORS',0(R9)        ERRORS?                       09 00143400
         BE    PRMERS                  Yes, handle it                   00143500
         CH    R2,=H'7'                LONG ENOUGH?                     00143600
         BL    PRMERR                  No, error                        00143700
         CLC   =C'MISSING',0(R9)       MISSING?                      09 00143800
         BE    PRMMIS                  Yes, handle it                   00143900
         CLC   =C'SUMMARY',0(R9)       SUMMARY?                      09 00144000
         BE    PRMSUM                  Yes, handle it                   00144100
         CLC   =C'COMPARE',0(R9)       COMPARE?                      09 00144200
         BE    PRMCMP                  Yes, handle it                   00144300
         CH    R2,=H'11'               LONG ENOUGH?                  06 00144400
         BL    PRMERR                  No, error                     06 00144500
         CLC   =C'CLEARRLD=',0(R9)     CLEARRLD=?                    09 00144600
         BE    PRMCLR                  Yes, handle it                06 00144700
         B     PRMERR                  Error                            00144800
PRMLST   DS    0H                                                    11 00144900
         OI    FLAG1,FLAG1LST          SET LIST                      11 00145000
         LA    R9,4(,R9)               SKIP VALUE                    11 00145100
         SH    R2,=H'4'                DECREMENT LENGTH              11 00145200
         B     PRMSCNC                 CONTINUE SCAN                 11 00145300
PRMDBG   DS    0H                                                       00145400
         OI    FLAG,FLAGDBG            SET DEBUG                        00145500
         LA    R9,5(,R9)               SKIP VALUE                    09 00145600
         SH    R2,=H'5'                DECREMENT LENGTH                 00145700
         B     PRMSCNC                 CONTINUE SCAN                    00145800
PRMERS   DS    0H                                                       00145900
         OI    FLAG,FLAGERS            SET ERRORS                       00146000
         LA    R9,6(,R9)               SKIP VALUE                    09 00146100
         SH    R2,=H'6'                DECREMENT LENGTH                 00146200
         B     PRMSCNC                 CONTINUE SCAN                    00146300
PRMMIS   DS    0H                                                       00146400
         OI    FLAG,FLAGMIS            SET MISSING                      00146500
         LA    R9,7(,R9)               SKIP VALUE                    09 00146600
         SH    R2,=H'7'                DECREMENT LENGTH                 00146700
         B     PRMSCNC                 CONTINUE SCAN                    00146800
PRMSUM   DS    0H                                                       00146900
         OI    FLAG,FLAGSUM            SET SUMMARY                      00147000
         LA    R9,7(,R9)               SKIP VALUE                    09 00147100
         SH    R2,=H'7'                DECREMENT LENGTH                 00147200
         B     PRMSCNC                 CONTINUE SCAN                    00147300
PRMCMP   DS    0H                                                       00147400
         OI    FLAG,FLAGCMP            SET COMPARE                      00147500
         LA    R9,7(,R9)               SKIP VALUE                    09 00147600
         SH    R2,=H'7'                DECREMENT LENGTH                 00147700
         LOAD  EPLOC==CL8'LOADLMD'                                      00147800
         ST    R0,LOADLMD                                               00147900
         B     PRMSCNC                 CONTINUE SCAN                    00148000
PRMCLR   DS    0H                                                    06 00148100
         CLC   =C'YES',9(R9)           YES OPTION?                   09 00148200
         BE    PRMCLRY                 YES, HANDLE IT                06 00148300
         CLC   =C'NO',9(R9)            NO OPTION                     09 00148400
         BNE   PRMERR                  NO, ERROR                     06 00148500
         OI    FLAG,FLAGCLRN           SET CLEARRLD=NO               06 00148600
         LA    R9,11(,R9)              SKIP VALUE                    09 00148700
         SH    R2,=H'11'               DECREMENT LENGTH              06 00148800
         B     PRMSCNC                 CONTINUE SCAN                 06 00148900
PRMCLRY  DS    0H                                                    06 00149000
         NI    FLAG,255-FLAGCLRN       RESET CLEARRLD=NO             06 00149100
         LA    R9,12(,R9)              SKIP VALUE                    09 00149200
         SH    R2,=H'12'               DECREMENT LENGTH              06 00149300
         B     PRMSCNC                 CONTINUE SCAN                 06 00149400
PRMLIB   DS    0H                                                    18 00149500
         LA    R9,4(,R9)               SKIP VALUE                    18 00149600
         SH    R2,=H'4'                DECREMENT LENGTH              18 00149700
         MVC   LIB,=CL8' '             Clear select library          18 00149800
         LA    R15,LIB                 Library                       18 00149900
         LA    R0,L'LIB                Max length                    18 00150000
PRMLIB1  DS    0H                                                    18 00150100
         CLI   0(R9),C','              End of LIB                    18 00150200
         BE    PRMLIB2                 Yes                           18 00150300
         MVC   0(1,R15),0(R9)          Copy a character              18 00150400
         LA    R15,1(,R15)             Next character                18 00150500
         LA    R9,1(,R9)               Next character                18 00150600
         SH    R2,=H'1'                Less length of LB             18 00150700
         BZ    PRMLIB2                 End of PARM=                  18 00150800
         BCT   R0,PRMLIB1              Go through PARM               18 00150900
PRMLIB2  DS    0H                                                    18 00151000
         B     PRMSCNC                 CONTINUE SCAN                 18 00151100
PRMSCNC  DS    0H                                                       00151200
         LTR   R2,R2                   END OF PARM?                     00151300
         BZ    PRMEND                  YES, PARM PARSED                 00151400
         CLI   0(R9),C','              DELIMITER?                    09 00151500
         BE    PRMSCN                  YES, HANDLE IT                   00151600
PRMERR   DS    0H                                                       00151700
         LR    R1,R9                   CURRENT POSITION              09 00151800
         S     R1,PRMSTART             LESS START                       00151900
         LA    R1,LINE+6(R1)           SET LOCATION OF ERROR            00152000
         MVI   0(R1),C'*'              MARK WHERE ERROR IS              00152100
         BAL   R14,PRT                 PRINT A LINE                     00152200
         MVC   LINE(19),=C' Parameters invalid'                         00152300
         BAL   R14,PRT                 PRINT A LINE                     00152400
         B     QUIT                    ERROR                            00152500
PRMEND   DS    0H                                                       00152600
         BAL   R14,PRT                 PRINT A LINE                  11 00152700
         DEVTYPE =CL8'SYSIN',DWORD     Detect if SYSIN DD present    19 00152800
         LTR   R15,R15                 Is SYSIN DD present?          19 00152900
         BNZ   INITIGNZ                NO, SKIP OPEN                 19 00153000
         OPEN  (SYSIN,(INPUT))         OPEN SYSIN DCB                19 00153100
         L     R2,IGNPTR                                             03 00153200
INITIGN1 DS    0H                                                    03 00153300
         C     R2,=A(IGNTBL)                                         03 00153400
         BNE   INITIGN2                                              03 00153500
         TM    FLAG1,FLAG1LST          LIST?                         11 00153600
         BZ    INITIGN2                No, skip                      11 00153700
         MVC   LINE+1(12),=C'Ignore Table'                           12 00153800
         BAL   R14,PRT                 PRINT A LINE                  03 00153900
         MVC   LINE+1(17),=C'-CSECT-  Comments'                      12 00154000
         BAL   R14,PRT                 PRINT A LINE                  04 00154100
INITIGN2 DS    0H                                                    03 00154200
         GET   SYSIN                   GET MODULE IGNORE RECORD      12 00154300
         AP    IGNCT,=P'+1'            COUNT MODULE IGNORE RECORDS   12 00154400
         C     R2,=A(IGNTBLND)                                       03 00154500
         BNL   INITIGNE                                              03 00154600
         MVC   0(8,R2),0(R1)           COPY MODULE IGNORE TO TABLE   12 00154700
         LA    R2,8(,R2)                                             03 00154800
         TM    FLAG1,FLAG1LST          LIST?                         11 00154900
         BZ    INITIGN1                No, skip                      11 00155000
         MVC   LINE+1(80),0(R1)        COPY MODULE IGNORE TO PRINT   12 00155100
         BAL   R14,PRT                                               03 00155200
         B     INITIGN1                                              03 00155300
INITIGNE DS    0H                                                    03 00155400
         MVC   LINE+1(21),=C'Ignore Table overflow'                  12 00155500
         BAL   R14,PRT                 PRINT A LINE                  03 00155600
         B     QUIT                    ERROR                         03 00155700
INEOF    DS    0H                                                    03 00155800
         ST    R2,IGNPTR                                             03 00155900
         TM    FLAG1,FLAG1LST          LIST?                         11 00156000
         BZ    INITIGN9                No, skip                      11 00156100
         MVC   LINE+1(19),=C'End of Ignore Table'                    12 00156200
         BAL   R14,PRT                 PRINT A LINE                  04 00156300
         MVC   LINE(9),=X'40202020206B202120'                        12 00156400
         ED    LINE(9),IGNCT                                         12 00156500
         MVC   LINE+10(20),=C'Ignore Table entries'                  12 00156600
         BAL   R14,PRT                 PRINT A LINE                  12 00156700
         BAL   R14,PRT                 PRINT A LINE                  04 00156800
INITIGN9 DS    0H                                                    11 00156900
         TM    FLAG,FLAGDBG                                          19 00157000
         BNO   INITIGCL                                              19 00157100
         L     R0,IGNPTR                                             19 00157200
         S     R0,=A(IGNTBL)                                         19 00157300
         ST    R0,DWORD                                              19 00157400
         UNPK  LINE+1(9),DWORD(5)                                    19 00157500
         TR    LINE+1(8),HEXTBL-240                                  19 00157600
         MVC   LINE+9(18),=C' Ignore Table size'                     19 00157700
         BAL   R14,PRT                 PRINT A LINE                  19 00157800
INITIGCL DS    0H                                                    19 00157900
         CLOSE SYSIN                   CLOSE SYSIN                   19 00158000
         TM    SYSIN+23,1              BUFFER POOL FREED             19 00158100
         BO    INITIGNZ                YES, SKIP FREEPOOL            19 00158200
         FREEPOOL SYSIN                RELEASE BUFFERS               19 00158300
INITIGNZ DS    0H                                                    19 00158400
         DEVTYPE =CL8'CSV',DWORD       Detect if CSV DD present      08 00158500
         LTR   R15,R15                 Is DC DD present?             08 00158600
         BNZ   INITNOCS                No, skip OPEN                 08 00158700
         OI    FLAG1,FLAG1CSV          Set CSV DD present            08 00158800
         OPEN  (CSVDCB,(OUTPUT))       OPEN CSV DCB                  08 00158900
INITNOCS DS    0H                                                    08 00159000
* Handle difference table if present                                 09 00159100
         DEVTYPE =CL8'DIFIN',DWORD     Detect if DFINN DD present    09 00159200
         LTR   R15,R15                 Is DIFIN DD present?          09 00159300
         BNZ   DFINEND                 NO, SKIP OPEN                 09 00159400
         OPEN  (DIFIN,(INPUT))         OPEN DIFIN DCB                09 00159500
         L     R2,=A(DIFTBL)           DIFFERENCE TABLE START        09 00159600
         TM    FLAG1,FLAG1LST          LIST?                         11 00159700
         BZ    DFINRD                  No, skip                      11 00159800
         MVC   LINE+1(16),=C'Difference Table'                       09 00159900
         BAL   R14,PRT                 PRINT A LINE                  09 00160000
DFINRD   DS    0H                                                    09 00160100
         GET   DIFIN                   READ DIF TABLE                09 00160200
         AP    DIFCT,=P'+1'            COUNT MODULE DIFFERENCES RECS 12 00160300
         LR    R3,R1                   SAVE RECORD ADDRESS           09 00160400
         TM    FLAG1,FLAG1LST          LIST?                         11 00160500
         BZ    DFINRDS1                No, skip                      11 00160600
         MVC   LINE+1(80),0(R3)        MOVE DIF TO PRINT             09 00160700
         BAL   R14,PRT                 PRINT A LINE                  09 00160800
DFINRDS1 DS    0H                                                    11 00160900
         CLI   0(R3),C'>'              HEADER                        09 00161000
         BNE   DFINRDDF                NO, HANDLE DIF                09 00161100
         LA    R0,12(,R2)              CHECK FOR MINIMUM ROOM        13 00161200
         C     R0,=A(DIFTBLND)         TABLE OVERFLOWED              09 00161300
         BNL   DFINER1                 YES, ERROR                    09 00161400
         MVC   0(8,R2),1(R3)           HEADER = MODULE ID            09 00161500
         LA    R2,8(,R2)               NEXT ENTRY                    09 00161600
         B     DFINRD                  READ ANOTHER DIFF             09 00161700
DFINRDDF DS    0H                                                    09 00161800
         LR    R1,R3                   RECORD ADDRESS                09 00161900
         C     R2,=A(DIFTBLND)         TABLE OVERFLOWED              09 00162000
         BNL   DFINER1                 YES, ERROR                    09 00162100
         LA    R14,8                   LETS SCAN 8 HEX CHARACTERS    09 00162200
DFINRDHL DS    0H                                                    09 00162300
         IC    R0,0(,R1)               GET A DIGIT                   09 00162400
         N     R0,=A(15)               CLEAR OFF ZONE                09 00162500
         CLI   0(R1),C'A'              IS IT A HEX DIGIT             09 00162600
         BL    DFINER2                 NO, ERROR                     09 00162700
         CLI   0(R1),C'F'              IS IT A HEX DIGIT             09 00162800
         BH    DFINRDHN                NO, MAY BE NUMBER             09 00162900
         AH    R0,=H'+9'               ADD IN A-F OFFSET             09 00163000
         B     DFINRDHZ                GO HANDLE CONVERTED DIGIT     09 00163100
DFINRDHN DS    0H                                                    09 00163200
         CLI   0(R1),C'0'              IS IT A NUMBER                09 00163300
         BL    DFINER2                 NO, ERROR                     09 00163400
DFINRDHZ DS    0H                                                    09 00163500
         SLL   R15,4                   SHIFT LAST DIGIT              09 00163600
         AR    R15,R0                  ADD CURRENT DIGIT TO TOTAL    09 00163700
         LA    R1,1(,R1)               NEXT DIGIT                    09 00163800
         BCT   R14,DFINRDHL            LOOP THROUGH ALL DIGITS       09 00163900
         LR    R0,R15                  GET DIFF OFFSET+LENGTH        09 00164000
         N     R0,=A(X'FF')            CLEAR OFFSET                  09 00164100
         BZ    DFINER2                 IF LENGTH ZERO ERROR          09 00164200
         ST    R15,0(,R2)              SAVE START/LENGTH             13 00164300
         LA    R2,4(,R2)               NEXT DIFFERENCE ENTRY         13 00164400
         B     DFINRD                  READ ANOTHER DIF              09 00164500
DFINER1  DS    0H                                                    09 00164600
         MVC   LINE+1(25),=C'Difference Table Overflow'              09 00164700
         B     DFINER                  PRINT ERROR                   09 00164800
DFINER2  DS    0H                                                    09 00164900
         LR    R2,R1                   Save pointer to error         11 00165000
         TM    FLAG1,FLAG1LST          LIST?                         11 00165100
         BO    DFINER2A                No, skip                      11 00165200
         MVC   LINE+1(80),0(R3)        MOVE DIF TO PRINT             11 00165300
         BAL   R14,PRT                 PRINT A LINE                  11 00165400
DFINER2A DS    0H                                                    11 00165500
         MVC   LINE+1(25),=C'Difference Table Error at'              09 00165600
         MVC   LINE+27(8),0(R2)        GIVE A LITTLE HINT OF ERROR   11 00165700
DFINER   DS    0H                                                    09 00165800
         BAL   R14,PRT                 PRINT A LINE                  09 00165900
         B     QUIT                    EXIT                          09 00166000
DFINRDED DS    0H                                                    09 00166100
         ST    R2,DIFTBLST             SAVE LAST ENTRY +1            09 00166200
         TM    FLAG1,FLAG1LST          LIST?                         11 00166300
         BZ    DFINSZ                  No, skip                      19 00166400
         MVC   LINE+1(20),=C'Difference Table End'                   09 00166500
         BAL   R14,PRT                 PRINT A LINE                  09 00166600
         MVC   LINE(9),=X'40202020206B202120'                        12 00166700
         ED    LINE(9),DIFCT                                         12 00166800
         MVC   LINE+10(24),=C'Difference Table entries'              12 00166900
         BAL   R14,PRT                 PRINT A LINE                  12 00167000
         BAL   R14,PRT                 PRINT A LINE                  09 00167100
DFINSZ   DS    0H                                                    11 00167200
         TM    FLAG,FLAGDBG                                          19 00167300
         BNO   DFINCL                                                19 00167400
         L     R0,DIFTBLST                                           19 00167500
         S     R0,=A(DIFTBL)                                         19 00167600
         ST    R0,DWORD                                              19 00167700
         UNPK  LINE+1(9),DWORD(5)                                    19 00167800
         TR    LINE+1(8),HEXTBL-240                                  19 00167900
         MVC   LINE+9(22),=C' Difference Table size'                 19 00168000
         BAL   R14,PRT                 PRINT A LINE                  19 00168100
DFINCL   DS    0H                                                    11 00168200
         CLOSE DIFIN                   CLOSE DIF FILE                09 00168300
         TM    DIFIN+23,1              BUFFER POOL FREED             13 00168400
         BO    DFINEND                 YES, SKIP FREEPOOL            13 00168500
         FREEPOOL DIFIN                RELEASE BUFFERS               13 00168600
DFINEND  DS    0H                                                    09 00168700
         L     R14,INITR14                                              00168800
         BR    R14                                                      00168900
**********************************************************************  00169000
*                                                                       00169100
*            WRITE PRINT LINE                                           00169200
*                                                                       00169300
**********************************************************************  00169400
PRT      DS    0H                                                       00169500
         ST    R14,PRTR14                                               00169600
         CP    LNCT,=P'+60'            END OF PAGE                      00169700
         BL    PRTCHK                   NO, CHECK IF LINE FIT IN PAGE   00169800
PRTHDRS  DS    0H                                                       00169900
         AP    PGCT,=P'+1'             COUNT PAGES                      00170000
         MVC   HD1PGCT,=X'40202120'    PAGE COUNT MASK                  00170100
         ED    HD1PGCT,PGCT            EDIT PAGE COUNT                  00170200
         PUT   SYSPRINT,HD1            PRINT HEADING 1                  00170300
         PUT   SYSPRINT,HD2            PRINT HEADING 2                  00170400
         PUT   SYSPRINT,HD3            PRINT HEADING 3               07 00170500
         ZAP   LNCT,=P'+3'             INIT LINE COUNT               07 00170600
         MVI   LINE,C' '               SKIP AFTER HEADING               00170700
PRTCHK   DS    0H                                                       00170800
         CLI   LINE,C'+'               OVERPRINT ?                      00170900
         BE    PRTLINE                  YES, DON'T COUNT                00171000
         CLI   LINE,C'1'               NEW LINE ?                       00171100
         BE    PRTHDRS                  YES, PRINT HEADER               00171200
         CLI   LINE,C' '               WRITE AFTER ADVANCING 1?         00171300
         BE    PRTLINE1                 YES, GO CHECK IF FIT            00171400
         CLI   LINE,C'0'               WRITE AFTER ADVANCING 1?         00171500
         BE    PRTLINE2                 YES, GO CHECK IF FIT            00171600
         CLI   LINE,C'-'               WRITE AFTER ADVANCING 1?         00171700
         BE    PRTLINE3                 YES, GO CHECK IF FIT            00171800
         B     PRTLINE                 IGNORE ANY OTHER CTL CHARS       00171900
PRTLINE1 DS    0H                                                       00172000
         AP    LNCT,=P'+1'             ADD TO LINE COUNT                00172100
         B     PRTVFY                  GO SEE IF IT WILL FIT            00172200
PRTLINE2 DS    0H                                                       00172300
         AP    LNCT,=P'+2'             ADD TO LINE COUNT                00172400
         B     PRTVFY                  GO SEE IF IT WILL FIT            00172500
PRTLINE3 DS    0H                                                       00172600
         AP    LNCT,=P'+3'             ADD TO LINE COUNT                00172700
PRTVFY   DS    0H                                                       00172800
         CP    LNCT,=P'+60'            OVERFLOW ?                       00172900
         BH    PRTHDRS                  YES, FORCE HEADER               00173000
PRTLINE  DS    0H                                                       00173100
         PUT   SYSPRINT,LINE           PRINT A LINE                     00173200
         MVI   LINE,C' '               CLEAR CONTROL CHARACTER          00173300
         MVC   LINE+1(L'LINE-1),LINE                                    00173400
         L     R14,PRTR14                                               00173500
         BR    R14                     RETURN TO CALLER                 00173600
PRMMVC   MVC   LINE+6(0),2(R9)         EXECUTED PARM MOVE            09 00173700
         DROP  ,                                                        00173800
*                                                                       00173900
* Work areas                                                            00174000
*                                                                       00174100
SAVEAREA DC    18A(0)                                                   00174200
DWORD    DC    D'+0'                                                    00174300
DIFSAVRG DC    4A(0)                                                 09 00174400
INITR14  DC    A(0)                                                     00174500
PRTR14   DC    A(0)                                                     00174600
ORGGET14 DC    A(0)                                                     00174700
BLDGET14 DC    A(0)                                                     00174800
BRKMOD14 DC    A(0)                                                     00174900
BRKLIB14 DC    A(0)                                                     00175000
LIBCSV14 DC    A(0)                                                  08 00175100
HEXCVT14 DS    A(0)                                                  02 00175200
PRMSTART DC    A(0)                                                     00175300
CURDATE  DC    A(0)                                                     00175400
JULWRK2  DC    A(0)                                                     00175500
JULWRK4  DC    P'+365'                                                  00175600
         DC    P'+01'                                                   00175700
         DC    P'+31'                                                   00175800
         DC    P'+30'                                                   00175900
         DC    P'+31'                                                   00176000
         DC    P'+30'                                                   00176100
         DC    P'+31'                                                   00176200
         DC    P'+31'                                                   00176300
         DC    P'+30'                                                   00176400
         DC    P'+31'                                                   00176500
         DC    P'+30'                                                   00176600
         DC    P'+31'                                                   00176700
JULWRK6  DC    P'+28'                                                   00176800
JULTBL1  DC    P'+31'                                                   00176900
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  00177000
TIMWRK4  DC    X'402021204B20204B20204B2020'                            00177100
LNCT     DC    PL2'+99'                                                 00177200
PGCT     DC    PL2'+0'                                                  00177300
HD1      DC    CL133'1'                                                 00177400
         ORG   HD1+1                                                    00177500
HD1DATE  DC    C'            '                                          00177600
         DC    C' '                                                     00177700
HD1TOD   DC    C'HH:MM:SS'                                              00177800
         DC    C' '                                                     00177900
HD1VER   DC    C'Ver &VER'                                              00178000
         ORG   HD1+66-(35/2)                                            00178100
HD1DATA  DC    C'Original vs Build CSECT/LMOD Report'                   00178200
         ORG   HD1+133-8                                                00178300
HD1PG    DC    C'Page'                                                  00178400
HD1PGCT  DC    C' 123'                                                  00178500
HD2      DC    CL133' '                                                 00178600
         ORG   HD2+1                                                    00178700
         DC    C'----------------- Original ----------------¦--'     07 00178800
         DC    C'------------------ Build ---------------------'     07 00178900
         DC    C'--------¦'                                          07 00179000
         ORG   ,                                                     07 00179100
HD3      DC    CL133' '                                              07 00179200
         ORG   HD3+1                                                 07 00179300
         DC    C'  Library       LMOD      CSECT     Length ¦  '     07 00179400
         DC    C'  Library       LMOD      CSECT     Length    '        00179500
         DC    C' Not EQ ¦'                                          07 00179600
         ORG   ,                                                        00179700
CSVLIB   DC    C'"xxxxxxxx"'                                         08 00179800
CSVSEP1  DC    C','                                                  08 00179900
CSVOMCT  DC    C'1234567'                                            08 00180000
CSVSEP2  DC    C','                                                  08 00180100
CSVOCCT  DC    C'1234567'                                            08 00180200
CSVSEP3  DC    C','                                                  08 00180300
CSVBMCT  DC    C'1234567'                                            08 00180400
CSVSEP4  DC    C','                                                  08 00180500
CSVBCCT  DC    C'1234567'                                            08 00180600
CSVSEP5  DC    C','                                                  08 00180700
CSVBDCT  DC    C'1234567'                                            08 00180800
CSVSEP6  DC    C','                                                  08 00180900
CSVBNCT  DC    C'1234567'                                            08 00181000
CSVREC   EQU   CSVLIB,*-CSVLIB                                       08 00181100
         DC    0D'0'                                                    00181200
OPNLST   OPEN  (SYSPRINT,(OUTPUT),ORG,(INPUT),BLD,(INPUT)),MF=L      19 00181300
ORG      DCB   DDNAME=ORG,MACRF=GM,DSORG=PS,EODAD=ORGEOF                00181400
BLD      DCB   DDNAME=BLD,MACRF=GM,DSORG=PS,EODAD=BLDEOF                00181500
SYSPRINT DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X00181600
               RECFM=FBA,LRECL=133                                      00181700
SYSIN    DCB   DDNAME=SYSIN,MACRF=GL,DSORG=PS,EODAD=INEOF            12 00181800
DIFIN    DCB   DDNAME=DIFIN,MACRF=GL,DSORG=PS,                       09X00181900
               RECFM=FB,LRECL=80,EODAD=DFINRDED                      09 00182000
CSVDCB   DCB   DDNAME=CSV,MACRF=PM,DSORG=PS,                           X00182100
               RECFM=FB,LRECL=L'CSVREC                               08 00182200
HEXTBL   DC    C'0123456789ABCDEF'                                      00182300
*                                                                       00182400
*        Counters                                                       00182500
*                                                                       00182600
ORGCT    DC    PL4'+0'               Original records                   00182700
BLDCT    DC    PL4'+0'               Build records                      00182800
NCCT     DC    PL4'+0'               Missing CSECTS                     00182900
ECCT     DC    PL4'+0'               Extra CSECTS                       00183000
NMCT     DC    PL4'+0'               Missing LMODs                      00183100
EMCT     DC    PL4'+0'               Extra LMODs                        00183200
IMMCT    DC    PL4'+0'               Ignored missing CSECTs          21 00183300
IMCCT    DC    PL4'+0'               Ignored missing LMODs           21 00183400
IEMCT    DC    PL4'+0'               Ignored extra CSECTs            21 00183500
IECCT    DC    PL4'+0'               Ignored extra LMODs             21 00183600
LN1XCT   DC    PL4'+0'               1-10 length difference          21 00183700
LN10XCT  DC    PL4'+0'               11-100 length difference        21 00183800
LN100XCT DC    PL4'+0'               1001-1000 length difference     21 00183900
LNBIGCT  DC    PL4'+0'               Greater than 1000 length diff   21 00184000
NE1XCT   DC    PL4'+0'               1-10 unequal difference         21 00184100
NE10XCT  DC    PL4'+0'               11-100 unequal difference       21 00184200
NE100XCT DC    PL4'+0'               1001-1000 unequal difference    21 00184300
NEBIGCT  DC    PL4'+0'               Greater than 1000 unequal diff  21 00184400
*        Original Total                                                 00184500
TOTOLCT  DC    PL4'+0'               Library                            00184600
TOTOMCT  DC    PL4'+0'               LMOD                               00184700
TOTOCCT  DC    PL4'+0'               CSECT                              00184800
TOTOECT  DC    PL4'+0'               Not-editable                       00184900
*        Original Library                                               00185000
LIBOMCT  DC    PL4'+0'               LMOD                               00185100
LIBOCCT  DC    PL4'+0'               CSECT                              00185200
LIBOECT  DC    PL4'+0'               Not-editable                       00185300
*        Original LMOD                                                  00185400
MODOCCT  DC    PL4'+0'               CSECT                              00185500
MODOECT  DC    PL4'+0'               Not-editable                       00185600
*        Build Total                                                    00185700
TOTBLCT  DC    PL4'+0'               Library                            00185800
TOTBMCT  DC    PL4'+0'               LMOD                               00185900
TOTBCCT  DC    PL4'+0'               CSECT                              00186000
TOTBDCT  DC    PL4'+0'               Different length                   00186100
TOTBNCT  DC    PL4'+0'               Same length don't compare equal    00186200
TOTBECT  DC    PL4'+0'               Compared equal                     00186300
TOTBICT  DC    PL4'+0'               Compared not equal but ignored  03 00186400
TOTDFCT  DC    PL4'+0'               Compared not equal DIF ignored  09 00186500
*        Build Library                                                  00186600
LIBBMCT  DC    PL4'+0'               LMOD                               00186700
LIBBCCT  DC    PL4'+0'               CSECT                              00186800
LIBBDCT  DC    PL4'+0'               Different length                   00186900
LIBBNCT  DC    PL4'+0'               Same length don't compare equal    00187000
LIBBECT  DC    PL4'+0'               Compared equal                     00187100
*        Build LMOD                                                     00187200
MODBCCT  DC    PL4'+0'               CSECT                              00187300
MODBDCT  DC    PL4'+0'               Different length                   00187400
MODBNCT  DC    PL4'+0'               Same length don't compare equal    00187500
MODBECT  DC    PL4'+0'               Compared equal                     00187600
MODDFCT  DC    PL4'+0'               Compared not equal DIF ignored  09 00187700
MODIGCT  DC    PL4'+0'               Missing CSECTS ignored          15 00187800
*                                                                       00187900
*        Break controls                                                 00188000
*                                                                       00188100
PREVOLIB DC    CL8' '                                                   00188200
PREVBLIB DC    CL8' '                                                   00188300
PREVOMOD DC    CL8' '                                                   00188400
PREVBMOD DC    CL8' '                                                   00188500
FLAG     DC    X'00'                                                    00188600
FLAGERS  EQU   X'80'                                                    00188700
FLAGMIS  EQU   X'40'                                                    00188800
FLAGSUM  EQU   X'20'                                                    00188900
FLAGDBG  EQU   X'10'                                                    00189000
FLAGCMP  EQU   X'08'                                                    00189100
FLAGCLRN EQU   X'04'                                                 06 00189200
FLAGEOFO EQU   X'02'                                                    00189300
FLAGEOFB EQU   X'01'                                                    00189400
FLAG1    DC    X'00'                                                 08 00189500
FLAG1CSV EQU   X'80'                                                 08 00189600
FLAG1LST EQU   X'04'                                                 11 00189700
LIB      DC    CL8' '                                                18 00189800
IGNCT    DC    PL4'+0'                                               12 00189900
DIFCT    DC    PL4'+0'                                               12 00190000
*                                                                       00190100
*library  lmod      INCLUDE   csect     len                             00190200
*          1         2         3         4                              00190300
*0123456789012345678901234567890123456789012345678                      00190400
*xxxxxxxx xxxxxxxx  xxxxxxxx  xxxxxxxx  xxxxxx                          00190500
*CMDLIB   AKJLKL01  ATTR      RENT,REUS,REFR                            00190600
*CMDLIB   AKJLKL01  INCLUDE   AKJLKL01  0022A3                          00190700
*CMDLIB   AKJLKL01  ALIAS     IKJLKL01                                  00190800
*CMDLIB   AKJLKL01  ENTRY     AKJLKL01                                  00190900
*                                                                       00191000
ORGREC   DC    CL80' '                                                  00191100
         ORG   ORGREC                                                   00191200
ORGLIB   DS    CL8                                                      00191300
         DS    C                                                        00191400
ORGMOD   DS    CL8                                                      00191500
         DS    2C                                                       00191600
ORGTYP   DS    CL8                                                      00191700
         DS    2C                                                       00191800
ORGCS    DS    CL8                                                      00191900
         DS    2C                                                       00192000
ORGLEN   DS    CL6                                                      00192100
         ORG   ,                                                        00192200
*                                                                       00192300
*                                                                       00192400
*                                                                       00192500
BLDREC   DC    CL80' '                                                  00192600
         ORG   BLDREC                                                   00192700
BLDLIB   DS    CL8                                                      00192800
         DS    C                                                        00192900
BLDMOD   DS    CL8                                                      00193000
         DS    2C                                                       00193100
BLDTYP   DS    CL8                                                      00193200
         DS    2C                                                       00193300
BLDCS    DS    CL8                                                      00193400
         DS    2C                                                       00193500
BLDLEN   DS    CL6                                                      00193600
         ORG   ,                                                        00193700
*                                                                       00193800
*                                                                       00193900
*                                                                       00194000
LINE     DC    CL133' '                                                 00194100
         ORG   LINE                                                     00194200
LINEOLCT DS    0CL10                                                    00194300
         DS    CL2                                                      00194400
LINEOLIB DS    CL8                                                      00194500
         DS    C                                                        00194600
LINEOMCT DS    0CL10                                                    00194700
         DS    CL2                                                      00194800
LINEOMOD DS    CL8                                                      00194900
         DS    C                                                        00195000
LINEOCCT DS    0CL10                                                    00195100
         DS    CL2                                                      00195200
LINEOCS  DS    CL8                                                      00195300
         DS    C                                                        00195400
LINEONCT DS    0CL10                                                    00195500
         DS    CL4                                                      00195600
LINEOLEN DS    CL6,C                                                    00195700
*                                                                       00195800
LINESEP1 DS    C,C                                                      00195900
*                                                                       00196000
LINEBLCT DS    0CL10                                                    00196100
         DS    CL2                                                      00196200
LINEBLIB DS    CL8                                                      00196300
LINEBLCD DS    C                                                        00196400
LINEBMCT DS    0CL10                                                    00196500
         DS    CL2                                                      00196600
LINEBMOD DS    CL8                                                      00196700
LINEBMCD DS    C                                                        00196800
LINEBCCT DS    0CL10                                                    00196900
         DS    CL2                                                      00197000
LINEBCS  DS    CL8                                                      00197100
LINEBCCD DS    C                                                        00197200
LINEBDCT DS    0CL10                                                    00197300
         DS    CL4                                                      00197400
LINEBLEN DS    CL6,C                                                    00197500
LINEBNCT DS    CL10,C                                                   00197600
*                                                                       00197700
LINESEP2 DS    C,C                                                      00197800
*                                                                       00197900
LINECMT  DS    CL30                                                     00198000
         ORG ,                                                          00198100
*                                                                       00198200
LOADLMD  DC    A(0)                                                     00198300
DMPPRMAD DC    A(DMPPRMLN)                                              00198400
         DC    A(0)                                                     00198500
DMPPRMLN DC    AL2(0)                                                   00198600
DMPPRM   DC    C'LLLLLLLL,CCCCCCCC,LIB=XLLLLLL,CLEARRLD=YES        '    00198700
*                                                                       00198800
         LTORG ,                                                        00198900
*                                                                    03 00199000
IGNPTR   DC    A(IGNTBL)                                             03 00199100
DIFTBLST DC    A(0)                                                  09 00199200
IGNTBL   DC    100CL8' '                                             03 00199300
IGNTBLND EQU   *                                                     03 00199400
DIFTBL   DC    5000D'0'                                              20 00199500
DIFTBLND EQU   *                                                     09 00199600
R0       EQU   0                                                        00199700
R1       EQU   1                                                        00199800
R2       EQU   2                                                        00199900
R3       EQU   3                                                        00200000
R4       EQU   4                                                        00200100
R5       EQU   5                                                        00200200
R6       EQU   6                                                        00200300
R7       EQU   7                                                        00200400
R8       EQU   8                                                        00200500
R9       EQU   9                                                        00200600
R10      EQU   10                                                       00200700
R11      EQU   11                                                       00200800
R12      EQU   12                                                       00200900
R13      EQU   13                                                       00201000
R14      EQU   14                                                       00201100
R15      EQU   15                                                       00201200
         END                                                            00201300
