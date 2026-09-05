*********************************************************************** 00010000
*                                                                     * 00020000
* MODULE NAME                                                         * 00030000
*    MVSASM38                                                         * 00040000
*                                                                     * 00050000
* ATTRIBUTES                                                          * 00060000
*    NONE                                                             * 00070000
*                                                                     * 00080000
* AUTHOR                                                              * 00090000
*    DAVE KREISS                                                      * 00100000
*                                                                     * 00110000
* FUNCTION                                                            * 00120000
*    CREATE INDIVIDUAL LISTING MEMBER FROM SMP APPLY/ACCEPT OUTPUT    * 00130000
*    FOR ASSEMBLIES PERFORMED BY SMP RUN.                             * 00140000
*    CAN ALSO BE USED AGAINST STAGE 1 ASSEMBLY RUN.                   * 00150005
*                                                                     * 00160000
* JCL                                                                 * 00170000
*    //GENLIST EXEC PGM=MVSASM38,PARM='PARAMETERS'                    * 00180001
*    //STEPLIB  DD  DSN=load library,DISP=SHR                         * 00190000
*    //SYSPRINT DD  SYSOUT=*                                          * 00200000
*    //SYSIN    DD  DSN=OUTPUT FROM APPLY/ACCEPT DATA SET             * 00210000
*    //LIST     DD  DSN=DATA SET CONTAINING INDIVIDUAL ASSEMBLIES     * 00220001
*                                                                     * 00230000
* DD STATEMENTS                                                       * 00240000
*    STEPLIB       LOAD LIBRARY AINING THE MODULE MVSLKD38.           * 00250000
*    SYSPRINT      CONTAINS VARIOUS STATUS INFORMATION                * 00260000
*    SYSIN         INPUT DATA SET CONTAINING OUTPUT FROM A SMP        * 00270000
*                  APPLY OR ACCEPT RUN.                               * 00280000
*    LIST          OUTPUT PDS WHICH IS USED TO CREATE MEMBERS         * 00290000
*                  CONTAINING INDIVIDUAL LOAD MODULE ASSEMBLIES.      * 00300001
*                                                                     * 00310000
* PARAMETERS                                                          * 00320000
*    ALL PARAMETERS ARE SEPERATED BY COMMAS.                          * 00330000
*    LOG            LOG ONLY SELECTED MODULES STATUS                  * 00340001
*    LOG(ALL)       LOG ALL MODULES STATUS                            * 00350001
*    STATUS         PRODUCES A STATUS LINE PER MODULE ENCOUNTERED     * 00360001
*    ERRORS         PRODUCES MEMBERS ONLY IF ERRORS ARE DETECTED      * 00370000
*    DEBUG          LISTS ALL INPUT FOR DEBUGGING                     * 00380005
*                                                                     * 00390004
* RETURN CODES                                                        * 00400004
*    0              NO ASSEMBLIES WITH RC GREATER THAN 4              * 00410004
*    4              ASSEMBLY WITH RC = 8 OR 12                        * 00420004
*    8              PARAMETER ERROR OR ASSEMBLY WITH RC > 12          * 00430004
*                                                                     * 00440000
* SAMPLE JCL                                                          * 00450000
*    //GENLST  EXEC PGM=MVSASM38,PARM='LOG'                           * 00460001
*    //STEPLIB  DD  DSN=MVSSRC.BLD.UTILITY.LOAD,DISP=SHR              * 00470003
*    //SYSPRINT DD  SYSOUT=*                                          * 00480001
*    //SYSIN    DD  DSN=MVSSRC.BLD.ASMPRINT,DISP=SHR                  * 00490003
*    //LIST     DD  DSN=MVSSRC.BLD.APPLY.LIST,DISP=SHR                * 00500001
*                                                                     * 00510001
**********************************************************************  00520000
*                                                                    *  00530002
* CHANGE LOG:                                                        *  00540002
*   DATE     AAA VV.VV DESCRIPTION                                   *  00550002
* 10/09/2014 DSK 01.01 Created                                       *  00560002
* 06/06/2016 DSK 01.02 Handle LRECL=133 listing (we truncate lines)  *  00570002
* 04/01/2017 DSK 01.03 Report input data set name                    *  00580003
* 05/09/2017 DSK 01.04 Add return code for assembly failures         *  00590004
*                      Delete TEMPNAME (need 2nd base reg)           *  00600004
* 12/25/2019 DSK 01.05 Add non-SMP source generation (stage 1 out)   *  00610005
* 01/02/2020 DSK 01.06 Flag assembly errors RC=8 or more             *  00620006
* 07/01/2023 DSK 01.07 Record new member over previous un-kept mbr   *  00630007
         LCLC   &VER                                                    00640002
&VER     SETC   '01.07'                                            1.07 00650007
*                                                                    *  00660002
**********************************************************************  00670000
****************************************************************        00680002
*                                                              *        00690002
*   PROGRAM INITIALIZATION                                     *        00700002
*                                                              *        00710002
****************************************************************        00720002
MVSASM38 CSECT                                                          00730000
         USING MVSASM38,R15                                             00740000
         B     MAINBGN                                                  00750000
         DROP  R15                                                      00760000
         DC    AL1(L'MAINID)                                            00770000
MAINID   DC    C'MVSASM38 - &VER &SYSDATE &SYSTIME'                     00780002
MAINBGN  DC    0H'+0'                                                   00790000
         STM   R14,R12,12(R13)                                          00800000
         LR    R12,R15                                                  00810000
         LA    R11,2048                                              04 00820004
         LA    R11,2048(R11,R12)                                     04 00830004
         USING MVSASM38,R12,R11                                      04 00840004
         L     R10,=A(W#SA)                                             00850000
         USING W#SA,R10                                                 00860000
         ST    R13,4(,R10)                                              00870000
         ST    R10,8(,R13)                                              00880000
         LR    R13,R10                                                  00890000
         L     R2,0(,R1)                                                00900000
         ST    R2,W#PARMAD                                              00910000
         OPEN  (W#PRTDD,(OUTPUT),SYSIN,(INPUT))                         00920000
         TM    W#PRTDD+48,16                                            00930000
         BZ    MAINQUIT                                                 00940000
         TM    SYSIN+48,16                                              00950000
         BZ    MAINQUIT                                                 00960000
         TIME  BIN                     GET CURRENT DATE AND TIME        00970000
         ST    R1,W#CURDTE             SAVE DATE                        00980000
         SRDL  R0,32                   GET DOUBLE WORD TIME             00990000
         D     R0,=F'+6000'            GET MINUTES                      01000000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     01010000
         SLR   R0,R0                   CLEAR                            01020000
         D     R0,=F'+60'              GET HOURS / MINS                 01030000
         MH    R0,=H'+10000'           GET MINUTES                      01040000
         AR    R15,R0                  ADD TO GET MM:SS.TH              01050000
         M     R0,=F'+1000000'         GET HOURS                        01060000
         AR    R1,R15                  GET HH:MM:SS.TH                  01070000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              01080000
         MVC   W#TMWK4,=X'402021207A20207A20204B2020'                   01090000
         ED    W#TMWK4,W#DWORD+3       EDIT TIME                        01100000
         MVC   W#HD1TOD(8),W#TMWK4+2   MOVE TIME                        01110000
         ZAP   JULWRK2,W#CURDTE+2(2)   GET JULIAN DATE                  01120000
         ZAP   JULWRK4,=P'+365'        DAYS/YR = 365                    01130000
         ZAP   JULWRK6,=P'+28'         FEB = 28                         01140000
         MVO   W#DWORD,W#CURDTE+1(1)   SIGN YEAR                        01150000
         DP    W#DWORD,=P'+4'          DIVIDE BY 4                      01160000
         CP    W#DWORD+7(1),=P'+0'     IS IT A LEAP YEAR ?              01170000
         BNZ   MAINJC2                  NO                              01180000
         ZAP   JULWRK4,=P'+366'        DAYS/YR = 366                    01190000
         ZAP   JULWRK6,=P'+29'         FEB = 29                         01200000
MAINJC2  DS    0H                                                       01210000
         LA    R1,JULTBL1              POINT TO JANUARY                 01220000
         SLR   R2,R2                   SET COUNTER                      01230000
MAINJC4  DS    0H                                                       01240000
         SP    JULWRK2,0(2,R1)         MONTHS DISPLACEMENT              01250000
         BNP   MAINJC6                 IF EQUAL OR LESS THAN 0, BRANCH  01260000
         BCTR  R1,0                    POINT TO NEXT MONTH              01270000
         BCTR  R1,0                    POINT TO NEXT MONTH              01280000
         LA    R2,3(,R2)               UP INDEX                         01290000
         B     MAINJC4                 LOOP                             01300000
MAINJC6  DS    0H                                                       01310000
         AP    JULWRK2,0(2,R1)         ADD DAYS OF MONTH                01320000
         LA    R2,JULTBL2(R2)          ADDRESS MONTH                    01330000
         MVC   W#HD1DTE(3),0(R2)       MOVE MONTH                       01340000
         OI    JULWRK2+3,X'0F'         DISPLAY SIGN                     01350000
         UNPK  W#HD1DTE+4(2),JULWRK2   GET DAYS                         01360000
         CLI   W#HD1DTE+4,C'0'         FIRST 9 DAYS ?                   01370000
         LA    R1,W#HD1DTE+6           SET POINTER                      01380000
         BNE   MAINJC7                  NO                              01390000
         MVC   W#HD1DTE+4(1),W#HD1DTE+5 MOVE UNITS DIGIT                01400000
         BCTR  R1,0                    DROP POINTER                     01410000
MAINJC7  DS    0H                                                       01420000
         MVC   0(4,R1),=C', 19'        SET UP CONSTANT                  01430000
         TM    W#CURDTE,1              YEAR 2000?                       01440000
         BNO   MAINJC8                  NO, CONTINUE                    01450000
         MVC   2(2,R1),=C'20'          Y2K                              01460000
MAINJC8  DS    0H                                                       01470000
         UNPK  W#DWORD(3),W#CURDTE+1(2) UNPACK YEAR                     01480000
         MVC   4(2,R1),W#DWORD         GET YEAR                         01490000
         MVC   W#LINE+1(15),=C'Program version'                         01500000
         MVC   W#LINE+17(L'MAINID),MAINID                               01510000
         BAL   R14,MAINPRT                                              01520000
         L     R9,W#PARMAD                                              01530000
         MVC   W#LINE+1(5),=C'Parm='                                    01540000
         CLI   1(R9),0                                                  01550000
         BE    MAINPRPA                                                 01560000
         LH    R1,0(,R9)                                                01570000
         BCTR  R1,0                                                     01580000
         EX    R1,MAINPRMV                                              01590000
         B     MAINPRPA                                                 01600000
MAINPRMV MVC   W#LINE+6(0),2(R9)                                        01610000
MAINPRPA DS    0H                                                       01620000
         BAL   R14,MAINPRT                                              01630000
         LH    R2,0(,R9)                                                01640000
         LA    R9,2(,R9)                                                01650000
MAINPRSC DS    0H                                                       01660000
         LTR   R2,R2                                                    01670000
         BE    MAINPRZ                                                  01680000
         CLI   0(R9),C','                                               01690000
         BNE   MAINPRCK                                                 01700000
MAINPRCO DS    0H                                                       01710000
         LA    R9,1(,R9)                                                01720000
         BCTR  R2,0                                                     01730000
         B     MAINPRSC                                                 01740000
MAINPRCK DS    0H                                                       01750000
         CH    R2,=H'+3'                                                01760000
         BL    MAINPRER                                                 01770000
         CLC   =C'LOG',0(R9)                                            01780000
         BE    MAINPRLG                                                 01790000
         CH    R2,=H'+5'                                           1.05 01800005
         BL    MAINPRER                                            1.05 01810005
         CLC   =C'DEBUG',0(R9)                                     1.05 01820005
         BE    MAINPRDB                                            1.05 01830005
         CH    R2,=H'+6'                                                01840000
         BL    MAINPRER                                                 01850000
         CLC   =C'STATUS',0(R9)                                         01860000
         BE    MAINPRST                                                 01870000
         CLC   =C'ERRORS',0(R9)                                         01880000
         BE    MAINPRRR                                                 01890000
         B     MAINPRER                                                 01900000
MAINPRLG DS    0H                                                       01910000
         OI    W#FLAG2,W#FLG2LG                                         01920000
         LA    R9,3(,R9)                                                01930000
         SH    R2,=H'+3'                                                01940000
         CH    R2,=H'+5'                                                01950000
         BL    MAINPRSC                                                 01960000
         CLC   =C'(ALL)',0(R9)                                          01970000
         BNE   MAINPRSC                                                 01980000
         OI    W#FLAG2,W#FLG2LA                                         01990000
         LA    R9,5(,R9)                                                02000000
         SH    R2,=H'+5'                                                02010000
         B     MAINPRSC                                                 02020000
MAINPRDB DS    0H                                                  1.05 02030005
         OI    W#FLAG2,W#FLG2DB                                    1.05 02040005
         LA    R9,5(,R9)                                           1.05 02050005
         SH    R2,=H'+5'                                           1.05 02060005
         B     MAINPRSC                                            1.05 02070005
MAINPRST DS    0H                                                       02080000
         OI    W#FLAG2,W#FLG2ST                                         02090000
         LA    R9,6(,R9)                                                02100000
         SH    R2,=H'+6'                                                02110000
         B     MAINPRSC                                                 02120000
MAINPRRR DS    0H                                                       02130000
         OI    W#FLAG2,W#FLG2RR                                         02140000
         LA    R9,6(,R9)                                                02150000
         SH    R2,=H'+6'                                                02160000
         B     MAINPRSC                                                 02170000
MAINPRNX DS    0H                                                       02180000
         LTR   R2,R2                                                    02190000
         BE    MAINPRZ                                                  02200000
         CLI   0(R9),C','                                               02210000
         BE    MAINPRCO                                                 02220000
         B     MAINPRER                                                 02230000
MAINPRZ  DS    0H                                                       02240000
         RDJFCB SYSIN                                                03 02250003
         LA    R15,INJFCB                                            03 02260003
         USING JFCB,R15                                              03 02270003
         MVC   W#LINE+1(10),=C'Input DSN='                           03 02280003
         MVC   W#LINE+11(44),JFCBDSNM                                03 02290003
         TM    JFCBIND1,JFCPDS                                       03 02300003
         BNO   PROCJFM9                                              03 02310003
         LA    R1,W#LINE+11+L'JFCBDSNM-1                             03 02320003
PROCJFM1 DS    0H                                                    03 02330003
         CLI   0(R1),C' '                                            03 02340003
         BNE   PROCJFM2                                              03 02350003
         BCT   R1,PROCJFM1                                           03 02360003
PROCJFM2 DS    0H                                                    03 02370003
         MVI   1(R1),C'('                                            03 02380003
         MVC   2(8,R1),JFCBELNM                                      03 02390003
         LA    R1,2(,R1)                                             03 02400003
PROCJFM3 DS    0H                                                    03 02410003
         CLI   0(R1),C' '                                            03 02420003
         BE    PROCJFM4                                              03 02430003
         LA    R1,1(,R1)                                             03 02440003
         B     PROCJFM3                                              03 02450003
PROCJFM4 DS    0H                                                    03 02460003
         MVI   0(R1),C')'                                            03 02470003
PROCJFM9 DS    0H                                                    03 02480003
         DROP  R15                                                   03 02490003
         BAL   R14,MAINPRT                                           03 02500003
         TM    W#FLAG2,W#FLG2LA                                         02510000
         BNO   MAINPRZ1                                                 02520000
         MVC   W#LINE+1(34),=C'Begin Assembler Listing processing'      02530000
         BAL   R14,MAINPRT                                              02540000
MAINPRZ1 DS    0H                                                       02550000
         TM    W#FLAG2,W#FLG2ST                                         02560000
         BO    MAINPRZ2                                                 02570000
         OPEN  (OUTDCB,(OUTPUT))                                        02580000
         TM    OUTDCB+48,16                                             02590000
         BZ    MAINQUIT                                                 02600000
         NOTE  OUTDCB                                              1.07 02610007
         ST    R1,W#CURTTR                                         1.07 02620007
         TM    W#FLAG2,W#FLG2DB                                    1.07 02630007
         BNO   MAINPRZN                                            1.07 02640007
         MVC   W#LINE+1(6),=C'TTR=X'''                             1.07 02650007
         UNPK  W#LINE+7(9),W#CURTTR(5)                             1.07 02660007
         TR    W#LINE+7(8),W#HX2CHR-240                            1.07 02670007
         MVI   W#LINE+15,C''''                                     1.07 02680007
         BAL   R14,MAINPRT                                         1.07 02690007
MAINPRZN DS    0H                                                  1.07 02700007
         L     R9,=A(MAINBUF)                                        03 02710003
MAINPRZ2 DS    0H                                                       02720000
         L     R8,=A(MODLIST)                                           02730000
         LA    R7,MODLIST#                                              02740000
         LR    R6,R8                                                    02750000
MAINPROC DS    0H                                                       02760000
         BAL   R14,MAINRD                                               02770000
         CLC   =C'EXTERNAL SYMBOL DICTIONARY ',MAINREC+48               02780000
         BE    MAINAS                                                   02790000
*0         1         2         3         4         5         6          02800000
*0123456789012345678901234567890123456789012345678901234567890123456    02810000
* HMA2400    ASSEMBLY SUCCESSFUL - MOD=IFNX1J - LIBRARY=MVSSRC          02820000
*0         1         2         3         4         5         6          02830000
         CLC   =C'HMA2401    ASSEMBLY SUCCESSFUL - MOD=',MAINREC+1      02840000
         BE    MAINMOD0                                                 02850000
         CLC   =C'HMA2400    ASSEMBLY SUCCESSFUL - MOD=',MAINREC+1      02860000
         BNE   MAINNASM                                                 02870000
MAINMOD0 DS    0H                                                       02880000
         LTR   R7,R7                                                    02890000
         BZ    MAINMOFL                                                 02900000
         MVC   0(8,R8),=CL8' '                                          02910000
         LA    R0,8                                                     02920000
         LA    R1,MAINREC+38                                            02930000
         LR    R15,R8                                                   02940000
MAINMOD1 DS    0H                                                       02950000
         MVC   0(1,R15),0(R1)                                           02960000
         LA    R1,1(,R1)                                                02970000
         LA    R15,1(,R15)                                              02980000
         CLI   0(R1),C' '                                               02990000
         BE    MAINMOD2                                                 03000000
         BCT   R0,MAINMOD1                                              03010000
MAINMOD2 DS    0H                                                       03020000
         TM    W#FLAG2,W#FLG2LA                                         03030000
         BNO   MAINMOD3                                                 03040000
         MVC   W#LINE+1(21),=C'Assembly detected for'                   03050000
         MVC   W#LINE+23(8),0(R8)                                       03060000
         BAL   R14,MAINPRT                                              03070000
MAINMOD3 DS    0H                                                       03080000
         LA    R8,8(,R8)                                                03090000
         BCTR  R7,0                                                     03100000
MAINNASM DS    0H                                                       03110000
*0123456789012345678901234567890123456789012345678901234567890123456    03120000
* HMA2050    APPLY PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04     03130000
* HMA2050    ACCEPT PROCESSING COMPLETED - HIGHEST RETURN CODE IS 04    03140000
         CLC   =C'HMA2050',MAINREC+1                                    03150000
         BNE   MAINSM3                                                  03160000
         CLC   =C'APPLY',MAINREC+12                                     03170000
         BE    MAINSM1                                                  03180000
         CLC   =C'ACCEPT',MAINREC+12                                    03190000
         BE    MAINSM2                                                  03200000
         BNE   MAINSM3                                                  03210000
MAINSM1  DS    0H                                                       03220000
         MVC   SMPRC,MAINREC+64                                         03230000
         B     MAINSM3                                                  03240000
MAINSM2  DS    0H                                                       03250000
         MVC   SMPRC,MAINREC+65                                         03260000
MAINSM3  DS    0H                                                       03270000
*0         1         2         3         4         5         6          03280000
*0123456789012345678901234567890123456789012345678901234567890123456    03290000
* EBB1102  APPLIED   FUNCTION  EBB1102                                  03300000
* EBB1102  ACCEPTED  FUNCTION  EBB1102                                  03310000
         CLC   =C'APPLIED   FUNCTION',MAINREC+10                        03320000
         BNE   MAINSM4                                                  03330000
         MVC   SMPFUN,MAINREC+1                                         03340000
         TM    W#FLAG2,W#FLG2LA                                         03350000
         BNO   MAINSM4                                                  03360000
         MVC   W#LINE+1(23),=C'Begin xxxxxxx APPLY RC='                 03370000
         MVC   W#LINE+7(7),SMPFUN                                       03380000
         MVC   W#LINE+24(2),SMPRC                                       03390000
         BAL   R14,MAINPRT                                              03400000
         OI    W#FLAG2,W#FLG2AP        APPLY detected              1.07 03410007
MAINSM4  DS    0H                                                       03420000
         CLC   =C'ACCEPTED  FUNCTION',MAINREC+10                        03430000
         BNE   MAINSM5                                                  03440000
         MVC   SMPFUN,MAINREC+1                                         03450000
         TM    W#FLAG2,W#FLG2LA                                         03460000
         BNO   MAINSM5                                                  03470000
         MVC   W#LINE+1(24),=C'Begin xxxxxxx ACCEPT RC='                03480000
         MVC   W#LINE+7(7),SMPFUN                                       03490000
         MVC   W#LINE+25(2),SMPRC                                       03500000
         BAL   R14,MAINPRT                                              03510000
         OI    W#FLAG2,W#FLG2AC        ACCEPT detected             1.07 03520007
MAINSM5  DS    0H                                                       03530000
         B     MAINPROC                                                 03540000
*        Begin assembler listing                                        03550000
MAINAS   DS    0H                                                       03560000
         TM    W#FLAG2,W#FLG2DB                                    1.05 03570005
         BNO   MAINASN1                                            1.05 03580005
         MVC   W#LINE+1(14),=C'Begin assembly'                     1.05 03590005
         BAL   R14,MAINPRT                                         1.05 03600005
MAINASN1 DS    0H                                                  1.05 03610005
         MVC   MAINMOD,=CL8' '                                          03620000
         ZAP   MAINCSCT,=P'+0'                                          03630000
         NI    W#FLAG2,255-W#FLG2SE                                     03640000
MAINAS01 DS    0H                                                       03650000
         BAL   R14,MAINWR                                               03660000
         BAL   R14,MAINRD                                               03670000
*        CLC   =C'TOTAL RECORDS PRINTED ',MAINREC+1                     03680000
*        BE    MAINAE1                                                  03690000
*        CLC   =C'EXTERNAL SYMBOL DICTIONARY ',MAINREC+48               03700000
*        BE    MAINAE2                                                  03710000
         CLC   =C'SYMBOL   TYPE  ID   ADDR  LENGTH LDID',MAINREC+1      03720000
         BNE   MAINAS01                                                 03730000
MAINAS02 DS    0H                                                       03740000
*-SYMBOL   TYPE  ID   ADDR  LENGTH LDID                                 03750000
*0IFNX1J00  SD  0001 000000 000C0D                                      03760000
*           or                                                          03770000
*0          PC  0001 000000 001A1D                                      03780000
*-  LOC  OBJECT CODE    ADDR1 ADDR2  STMT                               03790000
         BAL   R14,MAINWR                                               03800000
         BAL   R14,MAINRD                                               03810000
*        CLC   =C'TOTAL RECORDS PRINTED ',MAINREC+1                     03820000
*        BE    MAINAE3                                                  03830000
*        CLC   =C'EXTERNAL SYMBOL DICTIONARY ',MAINREC+48               03840000
*        BE    MAINAE4                                                  03850000
         CLC   =C' SD  ',MAINREC+10                                     03860000
         BE    MAINAS03                                                 03870000
         CLC   =C'  LOC  OBJECT CODE    ADDR1 ADDR2  STMT',MAINREC+1    03880000
         BNE   MAINAS02                                                 03890000
         MVC   W#1STCS,=CL8'No SD'                                      03900000
         B     MAINAS04                                                 03910000
MAINAS03 DS    0H                                                       03920000
         MVC   W#1STCS,MAINREC+1                                        03930000
MAINAS04 DS    0H                                                       03940000
         CR    R6,R8                   End of SMP  asm list        1.05 03950005
         BL    MAINAS08                No, continue                1.05 03960005
         C     R6,=A(MODLIST)          If SMP ASSEMBLY found       1.05 03970005
         BNE   MAINAE9                 Error, asm with no SMP msg  1.05 03980005
         MVC   MAINMOD,W#1STCS         No SMP generate listing     1.05 03990005
         OI    W#FLAG2,W#FLG2NS                                    1.05 04000005
         B     MAINAS09                                            1.05 04010005
MAINAS08 DS    0H                                                  1.05 04020005
         MVC   MAINMOD,0(R6)                                            04030000
         LA    R6,8(,R6)                                                04040000
MAINAS09 DS    0H                                                  1.05 04050005
         TM    W#FLAG2,W#FLG2LA                                         04060000
         BNO   MAINAS1A                                                 04070000
         MVC   W#LINE+1(12),=C'Mod name(1)='                            04080000
         MVC   W#LINE+13(8),MAINMOD                                     04090000
         MVC   W#LINE+23(8),W#1STCS                                     04100000
         BAL   R14,MAINPRT                                              04110000
MAINAS1A DS    0H                                                       04120000
         LA    R0,8                                                     04130000
         LA    R1,MAINMOD                                               04140000
MAINAS1B DS    0H                                                       04150000
         CLI   0(R1),C'A'                                               04160000
         BL    MAINAS1C                                                 04170000
         LA    R1,1(,R1)                                                04180000
         BCT   R0,MAINAS1B                                              04190000
         B     MAINAS1D                                                 04200000
MAINAS1C DS    0H                                                       04210000
         CLI   0(R1),C' '                                               04220000
         BNE   MAINAS1D                                                 04230000
         LA    R1,1(,R1)                                                04240000
         BCT   R0,MAINAS1C                                              04250000
MAINAS1D DS    0H                                                       04260000
         AP    MAINMDCT,=P'+1'                                          04270000
         LTR   R0,R0                                                    04280000
         BZ    MAINAS1E                                                 04290000
         AP    MODERRCT,=P'+1'                                          04300000
         MVI   MAINMOD,C'@'                                             04310000
         UNPK  MAINMOD+1(7),MAINMDCT+1(4)                               04320000
         OI    MAINMOD+7,C'0'                                           04330000
         TM    W#FLAG2,W#FLG2LG                                         04340000
         BNO   MAINAS1E                                                 04350000
         MVC   W#LINE+50(10),=C'Name error'                             04360000
MAINAS1E DS    0H                                                       04370000
         TM    W#FLAG2,W#FLG2LA                                         04380000
         BNO   MAINAS2                                                  04390000
         MVC   W#LINE+1(12),=C'Mod name(2)='                            04400000
         MVC   W#LINE+13(8),MAINMOD                                     04410000
         BAL   R14,MAINPRT                                              04420000
MAINAS2  DS    0H                                                       04430000
         BAL   R14,MAINWR                                               04440000
         BAL   R14,MAINRD                                               04450000
*        CLC   =C'EXTERNAL SYMBOL DICTIONARY ',MAINREC+48               04460000
*        BE    MAINAE5                                                  04470000
*        CLC   =C'TOTAL RECORDS PRINTED ',MAINREC+1                     04480000
*        BE    MAINAE6                                                  04490000
         CLC   =C'HIGHEST SEVERITY WAS ',MAINREC+1                      04500000
         BNE   MAINAS2                                                  04510000
         MVC   MAINRC,MAINREC+23                                        04520000
         OC    MAINRC,=C'000'                                           04530000
         CLC   MAINRC,=C'000'                                           04540000
         BE    MAINAS20                                                 04550000
         CLC   MAINRC,=C'004'                                           04560000
         BE    MAINAS21                                                 04570000
         CLC   MAINRC,=C'008'                                           04580000
         BE    MAINAS22                                                 04590000
         CLC   MAINRC,=C'012'                                           04600000
         BE    MAINAS23                                                 04610000
         CLC   MAINRC,=C'016'                                           04620000
         BE    MAINAS24                                                 04630000
         B     MAINAS25                                                 04640000
MAINAS20 DS    0H                                                       04650000
         AP    MAIN0CT,=P'+1'                                           04660000
         B     MAINAS3                                                  04670000
MAINAS21 DS    0H                                                       04680000
         AP    MAIN4CT,=P'+1'                                           04690000
         B     MAINAS3                                                  04700000
MAINAS22 DS    0H                                                       04710000
         AP    MAIN8CT,=P'+1'                                           04720000
         B     MAINAS3                                                  04730000
MAINAS23 DS    0H                                                       04740000
         AP    MAIN12CT,=P'+1'                                          04750000
         B     MAINAS3                                                  04760000
MAINAS24 DS    0H                                                       04770000
         AP    MAIN16CT,=P'+1'                                          04780000
         B     MAINAS3                                                  04790000
MAINAS25 DS    0H                                                       04800000
         AP    MAINXXCT,=P'+1'                                          04810000
MAINAS3  DS    0H                                                       04820000
         BAL   R14,MAINWR                                               04830000
         BAL   R14,MAINRD                                               04840000
*        CLC   =C'EXTERNAL SYMBOL DICTIONARY ',MAINREC+48               04850000
*        BE    MAINAE7                                                  04860000
*        CLC   =C'HIGHEST SEVERITY WAS ',MAINREC+1                      04870000
*        BE    MAINAE8                                                  04880000
         CLC   =C'TOTAL RECORDS PRINTED ',MAINREC+1                     04890000
         BNE   MAINAS3                                                  04900000
         BAL   R14,MAINWR                                               04910000
         CLI   MAINMOD,C' '                                             04920000
         BNE   MAINAS4                                                  04930000
         AP    MODERRCT,=P'+1'                                          04940000
         MVI   MAINMOD,C'@'                                             04950000
         UNPK  MAINMOD+1(7),MAINMDCT+1(4)                               04960000
         OI    MAINMOD+7,C'0'                                           04970000
         TM    W#FLAG2,W#FLG2LG                                         04980000
         BNO   MAINAS4                                                  04990000
         MVC   W#LINE+60(8),=C'Name err'                                05000000
MAINAS4  DS    0H                                                       05010000
         TM    W#FLAG2,W#FLG2RR                                         05020000
         BNO   MAINAS5                                                  05030000
         CLC   MAINRC,=C'000'                                           05040000
         BE    MAINAS6                                                  05050000
         CLC   MAINRC,=C'004'                                           05060000
         BE    MAINAS6                                                  05070000
MAINAS5  DS    0H                                                       05080000
         AP    SELECTMD,=P'+1'                                          05090000
         AP    SELECTCT,MAINCSCT                                        05100000
         OI    W#FLAG2,W#FLG2SE                                         05110000
MAINAS6  DS    0H                                                       05120000
         TM    W#FLAG2,W#FLG2LG                                         05130000
         BNO   MAINAS9                                                  05140000
         MVC   W#LINE+2(8),MAINMOD                                      05150000
         MVC   W#LINE+12(7),SMPFUN                                      05160000
         MVC   W#LINE+20(12),=X'402020206B2020206B202120'               05170000
         ED    W#LINE+20(12),MAINCSCT                                   05180000
         MVC   W#LINE+34(3),=C'RC='                                     05190000
         MVC   W#LINE+37(3),MAINRC                                      05200000
         MVC   W#LINE+70(8),W#1STCS                                     05210000
         TM    W#FLAG2,W#FLG2SE                                         05220000
         BNO   MAINAS7                                                  05230000
         MVC   W#LINE+41(8),=C'Selected'                                05240000
MAINAS7  DS    0H                                                       05250000
         CLC   MAINRC,=C'008'                                      1.06 05260006
         BL    MAINAS7A                                            1.06 05270006
         MVI   W#LINE+50,C'*'                                      1.06 05280006
MAINAS7A DS    0H                                                  1.06 05290006
         TM    W#FLAG2,W#FLG2LA                                         05300000
         BO    MAINAS8                                                  05310000
         TM    W#FLAG2,W#FLG2SE                                         05320000
         BNO   MAINAS9                                                  05330000
MAINAS8  DS    0H                                                       05340000
         BAL   R14,MAINPRT                                              05350000
MAINAS9  DS    0H                                                       05360000
         MVI   W#LINE,C' '                                              05370000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              05380000
         TM    W#FLAG2,W#FLG2ST                                         05390000
         BO    MAINAS12                                                 05400000
         C     R9,=A(MAINBUF)                                           05410000
         BE    MAINAS10                                                 05420000
         LR    R0,R9                                                    05430000
         S     R0,=A(MAINBUF)                                           05440000
         LH    R2,OUTDCB+62                                             05450000
         STH   R0,OUTDCB+62                                             05460000
         WRITE OUTDECB1,SF,OUTDCB,MAINBUF                               05470000
         CHECK OUTDECB1                                                 05480000
         STH   R2,OUTDCB+62                                             05490000
MAINAS10 DS    0H                                                       05500000
         L     R9,=A(MAINBUF)                                        03 05510003
         MVC   STOWMBR,MAINMOD                                          05520000
         TM    W#FLAG2,W#FLG2SE                                         05530000
         BO    MAINAS11                                                 05540000
*        Member not select but we wrote it.  Forget it by pointing 1.07 05550007
*        back to the start of that member.                         1.07 05560007
         L     R1,W#CURTTR             Get this member start       1.07 05570007
         POINT OUTDCB,(1)              Reposition to that TTR      1.07 05580007
         TM    W#FLAG2,W#FLG2DB                                    1.07 05590007
         BNO   MAINAS1N                                            1.07 05600007
         MVC   W#LINE+1(6),=C'TTR=X'''                             1.07 05610007
         UNPK  W#LINE+7(9),W#CURTTR(5)                             1.07 05620007
         TR    W#LINE+7(8),W#HX2CHR-240                            1.07 05630007
         MVI   W#LINE+15,C''''                                     1.07 05640007
         BAL   R14,MAINPRT                                         1.07 05650007
MAINAS1N DS    0H                                                  1.07 05660007
         B     MAINAS12                                            1.07 05670007
MAINAS11 DS    0H                                                       05680000
         STOW  OUTDCB,STOWLIST,R                                        05690000
         CH    R15,=H'+8'                                            04 05700004
         BE    MAINAS12                                              04 05710004
         LTR   R15,R15                                               04 05720004
         BNZ   STOWERRR                                              04 05730004
         NOTE  OUTDCB                  Last members last TTR 00    1.07 05740007
         AL    R1,=A(1)                POINT to after this memver  1.07 05750007
         ST    R1,W#CURTTR             Save that TTR 01            1.07 05760007
         TM    W#FLAG2,W#FLG2DB                                    1.07 05770007
         BNO   MAINAS12                                            1.07 05780007
         MVC   W#LINE+1(6),=C'TTR=X'''                             1.07 05790007
         UNPK  W#LINE+7(9),W#CURTTR(5)                             1.07 05800007
         TR    W#LINE+7(8),W#HX2CHR-240                            1.07 05810007
         MVI   W#LINE+15,C''''                                     1.07 05820007
         BAL   R14,MAINPRT                                         1.07 05830007
MAINAS12 DS    0H                                                       05840000
         B     MAINPROC                                                 05850000
*                                                                       05860000
*                                                                       05870000
*                                                                       05880000
MAINEOF  DS    0H                                                       05890000
         CLOSE (SYSIN)                                                  05900000
         FREEPOOL SYSIN                                                 05910000
         LA    R2,0                                                     05920000
MAINEND  DS    0H                                                       05930000
         TM    W#FLAG2,W#FLG2ST                                         05940000
         BO    MAINEND1                                              04 05950004
         CLOSE (OUTDCB)                                                 05960000
MAINEND1 DS    0H                                                       05970000
         BAL   R14,MAINPRT                                              05980000
         CP    MAIN0CT,=P'+0'                                           05990000
         BE    MAINEND2                                                 06000000
         MVC   W#LINE+2(17),=C'ASM return code 0'                       06010000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06020000
         ED    W#LINE+30(12),MAIN0CT                                    06030000
         BAL   R14,MAINPRT                                              06040000
MAINEND2 DS    0H                                                       06050000
         CP    MAIN4CT,=P'+0'                                           06060000
         BE    MAINEND3                                                 06070000
         MVC   W#LINE+2(17),=C'ASM return code 4'                       06080000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06090000
         ED    W#LINE+30(12),MAIN4CT                                    06100000
         BAL   R14,MAINPRT                                              06110000
MAINEND3 DS    0H                                                       06120000
         CP    MAIN8CT,=P'+0'                                           06130000
         BE    MAINEND4                                                 06140000
         MVC   W#LINE+2(17),=C'ASM return code 8'                       06150000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06160000
         ED    W#LINE+30(12),MAIN8CT                                    06170000
         BAL   R14,MAINPRT                                              06180000
         LA    R0,4                                                  04 06190004
         CR    R2,R0                                                 04 06200004
         BNL   MAINEND4                                              04 06210004
         LR    R2,R0                                                 04 06220004
MAINEND4 DS    0H                                                       06230000
         CP    MAIN12CT,=P'+0'                                          06240000
         BE    MAINEND5                                                 06250000
         MVC   W#LINE+2(18),=C'ASM return code 12'                      06260000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06270000
         ED    W#LINE+30(12),MAIN12CT                                   06280000
         BAL   R14,MAINPRT                                              06290000
         LA    R0,4                                                  04 06300004
         CR    R2,R0                                                 04 06310004
         BNL   MAINEND5                                              04 06320004
         LR    R2,R0                                                 04 06330004
MAINEND5 DS    0H                                                       06340000
         CP    MAIN16CT,=P'+0'                                          06350000
         BE    MAINEND6                                                 06360000
         MVC   W#LINE+2(18),=C'ASM return code 16'                      06370000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06380000
         ED    W#LINE+30(12),MAIN16CT                                   06390000
         BAL   R14,MAINPRT                                              06400000
         LA    R0,8                                                  04 06410004
         CR    R2,R0                                                 04 06420004
         BNL   MAINEND6                                              04 06430004
         LR    R2,R0                                                 04 06440004
MAINEND6 DS    0H                                                       06450000
         CP    MAINXXCT,=P'+0'                                          06460000
         BE    MAINEND7                                                 06470000
         MVC   W#LINE+2(17),=C'ASM return code ?'                       06480000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06490000
         ED    W#LINE+30(12),MAINXXCT                                   06500000
         BAL   R14,MAINPRT                                              06510000
         LA    R0,8                                                  04 06520004
         CR    R2,R0                                                 04 06530004
         BNL   MAINEND7                                              04 06540004
         LR    R2,R0                                                 04 06550004
MAINEND7 DS    0H                                                       06560000
         MVC   W#LINE+2(16),=C'Modules detected'                        06570000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06580000
         ED    W#LINE+30(12),MAINMDCT                                   06590000
         BAL   R14,MAINPRT                                              06600000
         CP    MODERRCT,=P'+0'                                          06610000
         BE    MAINEND8                                                 06620000
         MVC   W#LINE+2(13),=C'Invalid names'                           06630000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06640000
         ED    W#LINE+30(12),MODERRCT                                   06650000
         BAL   R14,MAINPRT                                              06660000
         CP    MODFIXCT,=P'+0'                                          06670000
         BE    MAINEND8                                                 06680000
         MVC   W#LINE+2(11),=C'Fixed names'                             06690000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06700000
         ED    W#LINE+30(12),MODFIXCT                                   06710000
         BAL   R14,MAINPRT                                              06720000
MAINEND8 DS    0H                                                       06730000
         MVC   W#LINE+2(13),=C'Print records'                           06740000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06750000
         ED    W#LINE+30(12),MAININCT                                   06760000
         BAL   R14,MAINPRT                                              06770000
         MVC   W#LINE+2(22),=C'Assembler List records'                  06780000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06790000
         ED    W#LINE+30(12),MAINOTCT                                   06800000
         BAL   R14,MAINPRT                                              06810000
         TM    W#FLAG2,W#FLG2RR                                         06820000
         BNO   MAINEND9                                                 06830000
         MVC   W#LINE+2(16),=C'Modules selected'                        06840000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06850000
         ED    W#LINE+30(12),SELECTMD                                   06860000
         BAL   R14,MAINPRT                                              06870000
         MVC   W#LINE+2(21),=C'List records selected'                   06880000
         MVC   W#LINE+30(12),=X'402020206B2020206B202120'               06890000
         ED    W#LINE+30(12),SELECTCT                                   06900000
         BAL   R14,MAINPRT                                              06910000
MAINEND9 DS    0H                                                       06920000
         TM    W#FLAG2,W#FLG2NS                                    1.05 06930005
         BNO   MAINENDA                                            1.05 06940005
         MVC   W#LINE+2(20),=C'SMP run not detected'               1.05 06950005
         BAL   R14,MAINPRT                                         1.05 06960005
         B     MAINENDD                                            1.07 06970007
MAINENDA DS    0H                                                  1.07 06980007
         TM    W#FLAG2,W#FLG2AP        APPLY function              1.07 06990007
         BNO   MAINENDB                No                          1.07 07000007
         MVC   W#LINE+2(5),=C'APPLY'                               1.07 07010007
         B     MAINENDC                                            1.07 07020007
MAINENDB DS    0H                                                  1.07 07030007
         TM    W#FLAG2,W#FLG2AC        ACCEPT function             1.07 07040007
         BNO   MAINENDC                No                          1.07 07050007
         MVC   W#LINE+2(6),=C'ACCEPT'                              1.07 07060007
MAINENDC DS    0H                                                  1.07 07070007
         MVC   W#LINE+9(7),SMPFUN      Get SMP function            1.07 07080007
         MVC   W#LINE+17(3),=C'RC='                                1.07 07090007
         MVC   W#LINE+20(2),SMPRC      Get SMP return code         1.07 07100007
         BAL   R14,MAINPRT             Print them                  1.07 07110007
MAINENDD DS    0H                                                  1.07 07120007
         MVC   W#LINE+1(18),=C'End processing RC='                      07130000
         ST    R2,W#DWORD                                               07140000
         UNPK  W#LINE+19(9),W#DWORD(5)                                  07150000
         TR    W#LINE+19(8),W#HX2CHR-240                                07160000
         MVI   W#LINE+19+8,C' '                                         07170000
         BAL   R14,MAINPRT                                              07180000
         CLOSE (W#PRTDD)                                                07190000
         FREEPOOL W#PRTDD                                               07200000
         L     R13,4(,R13)                                              07210000
         L     R14,12(,R13)                                             07220000
         LR    R15,R2                                                   07230000
         LM    R0,R12,20(R13)                                           07240000
         BR    R14                                                      07250000
*                                                                       07260000
*                                                                       07270000
*                                                                       07280000
MAINPRER DS    0H                                                       07290000
         MVC   W#LINE+1(33),=C'PARM= contained invalid parameter'       07300000
         B     MAINQUIT                                                 07310000
*                                                                       07320000
*                                                                       07330000
*                                                                       07340000
MAINAE1  DS    0H                                                       07350000
         MVI   W#LINE+28,C'1'                                      1.05 07360005
         B     MAINAER                                                  07370000
MAINAE2  DS    0H                                                       07380000
         MVI   W#LINE+28,C'2'                                      1.05 07390005
         B     MAINAER                                                  07400000
MAINAE3  DS    0H                                                       07410000
         MVI   W#LINE+28,C'3'                                      1.05 07420005
         B     MAINAER                                                  07430000
MAINAE4  DS    0H                                                       07440000
         MVI   W#LINE+28,C'4'                                      1.05 07450005
         B     MAINAER                                                  07460000
MAINAE5  DS    0H                                                       07470000
         MVI   W#LINE+28,C'5'                                      1.05 07480005
         B     MAINAER                                                  07490000
MAINAE6  DS    0H                                                       07500000
         MVI   W#LINE+28,C'6'                                      1.05 07510005
         B     MAINAER                                                  07520000
MAINAE7  DS    0H                                                       07530000
         MVI   W#LINE+28,C'7'                                      1.05 07540005
         B     MAINAER                                                  07550000
MAINAE8  DS    0H                                                       07560000
         MVI   W#LINE+28,C'8'                                      1.05 07570005
         B     MAINAER                                                  07580000
MAINAE9  DS    0H                                                       07590000
         MVI   W#LINE+28,C'9'                                      1.05 07600005
         B     MAINAER                                                  07610000
MAINAER  DS    0H                                                       07620000
         MVC   W#LINE+1(26),=C'Unexpected end of module -'         1.05 07630005
         MVC   W#LINE+31(12),=X'402020206B2020206B202120'               07640000
         ED    W#LINE+31(12),MAININCT                                   07650000
         BAL   R14,MAINPRT                                              07660000
         MVC   W#LINE+1(132),MAINREC+1                                  07670000
         B     MAINQUIT                                                 07680000
*                                                                    04 07690004
*                                                                    04 07700004
*                                                                    04 07710004
STOWERRD DS    0H                                                    04 07720004
         MVC   W#LINE+1(15),=C'STOW (DELETE)  '                      04 07730004
         B     STOWERR                                               04 07740004
STOWERRR DS    0H                                                    04 07750004
         MVC   W#LINE+1(15),=C'STOW (REPLACE) '                      04 07760004
STOWERR  DS    0H                                                    04 07770004
         MVC   W#LINE+17(8),STOWMBR                                  04 07780004
         MVC   W#LINE+26(6),=C'R15=X'''                              04 07790004
         ST    R15,W#DWORD                                           04 07800004
         UNPK  W#LINE+32(9),W#DWORD(5)                               04 07810004
         TR    W#LINE+32(8),W#HX2CHR-240                             04 07820004
         MVI   W#LINE+40,C''''                                       04 07830004
         MVC   W#LINE+42(5),=C'R0=X'''                               04 07840004
         ST    R0,W#DWORD                                            04 07850004
         UNPK  W#LINE+47(9),W#DWORD(5)                               04 07860004
         TR    W#LINE+47(8),W#HX2CHR-240                             04 07870004
         MVI   W#LINE+55,C''''                                       04 07880004
         B     MAINQUIT                                              04 07890004
*                                                                       07900000
*                                                                       07910000
*                                                                       07920000
MAINMOFL DS    0H                                                       07930000
         MVC   W#LINE+1(24),=C'MOD list table overflow'                 07940000
         B     MAINQUIT                                                 07950000
*                                                                       07960000
*                                                                       07970000
*                                                                       07980000
MAINQUIT DS    0H                                                       07990000
         BAL   R14,MAINPRT                                              08000000
         LA    R2,8                                                     08010000
         B     MAINEND                                                  08020000
*                                                                       08030000
*                                                                       08040000
*                                                                       08050000
MAINPRT  DS    0H                                                       08060000
         ST    R14,MAINPR14                                             08070000
         L     R15,=A(PRINT)                                            08080000
         BALR  R14,R15                                                  08090000
         L     R14,MAINPR14                                             08100000
         BR    R14                                                      08110000
*                                                                       08120000
*                                                                       08130000
*                                                                       08140000
MAINRD   DS    0H                                                       08150000
         ST    R14,MAINRD14                                             08160000
         MVI   MAINREC,C' '                                             08170000
         MVC   MAINREC+1(L'MAINREC-1),MAINREC                           08180000
         GET   SYSIN,MAINREC                                            08190000
         AP    MAININCT,=P'+1'                                          08200000
         TM    W#FLAG2,W#FLG2DB                                    1.05 08210005
         BNO   MAINRDND                                            1.05 08220005
         MVC   W#LINE+2(7),=C'Read-->'                             1.05 08230005
         MVC   W#LINE+9(80),MAINREC+1                              1.05 08240005
         BAL   R14,MAINPRT                                         1.05 08250005
MAINRDND DS    0H                                                  1.05 08260005
         L     R14,MAINRD14                                             08270000
         BR    R14                                                      08280000
*                                                                       08290000
*                                                                       08300000
*                                                                       08310000
MAINWR   DS    0H                                                       08320000
         ST    R14,MAINWR14                                             08330000
         AP    MAINOTCT,=P'+1'                                          08340000
         AP    MAINCSCT,=P'+1'                                          08350000
         TM    W#FLAG2,W#FLG2ST                                         08360000
         BO    MAINWR1                                                  08370000
         MVC   0(121,R9),MAINREC                                        08380000
         LA    R9,121(,R9)                                              08390000
         C     R9,=A(MAINBUFN)                                          08400000
         BL    MAINWR1                                                  08410000
         WRITE OUTDECB2,SF,OUTDCB,MAINBUF                               08420000
         CHECK OUTDECB2                                                 08430000
         L     R9,=A(MAINBUF)                                        03 08440003
MAINWR1  DS    0H                                                       08450000
         L     R14,MAINWR14                                             08460000
         BR    R14                                                      08470000
*                                                                       08480000
*                                                                       08490000
*                                                                       08500000
         LTORG ,                                                        08510000
JULWRK2  DC    A(0)                                                     08520000
JULWRK4  DC    P'+365'                                                  08530000
         DC    P'+01'                                                   08540000
         DC    P'+31'                                                   08550000
         DC    P'+30'                                                   08560000
         DC    P'+31'                                                   08570000
         DC    P'+30'                                                   08580000
         DC    P'+31'                                                   08590000
         DC    P'+31'                                                   08600000
         DC    P'+30'                                                   08610000
         DC    P'+31'                                                   08620000
         DC    P'+30'                                                   08630000
         DC    P'+31'                                                   08640000
JULWRK6  DC    P'+28'                                                   08650000
JULTBL1  DC    P'+31'                                                   08660000
JULTBL2  DC    C'JanFebMarAprMayJunJulAugSepOctNovDec'                  08670000
SYSIN    DCB   DDNAME=SYSIN,MACRF=GM,DSORG=PS,EODAD=MAINEOF,         03*08680003
               EXLST=INEXLST                                         03 08690003
INEXLST  DC    0A(0)                                                 03 08700003
         DC    AL1(128+7),AL3(INJFCB)                                03 08710003
INJFCB   DC    44A(0)                                                03 08720003
OUTDCB   DCB   DDNAME=LIST,DSORG=PO,MACRF=W,                           *08730000
               RECFM=FBA,LRECL=121,BLKSIZE=231*121 27951 (3390 1/2 TRK) 08740000
STOWLIST DC    0A(0)                   List of member names for STOW    08750000
STOWMBR  DC    CL8' '                  Name of member                   08760000
         DC    XL3'0'                  TTR of first record              08770000
*                                      (created by STOW)                08780000
         DC    X'00'                   C byte, no user TTRNs,           08790000
*                                      no user data                     08800000
MAINPR14 DC    A(0)                                                     08810000
MAINRD14 DC    A(0)                                                     08820000
MAINWR14 DC    A(0)                                                     08830000
MAININCT DC    PL5'+0'                                                  08840000
MAINOTCT DC    PL5'+0'                                                  08850000
MAINCSCT DC    PL5'+0'                                                  08860000
MAINMDCT DC    PL5'+0'                                                  08870000
MODERRCT DC    PL5'+0'                                                  08880000
MODFIXCT DC    PL5'+0'                                                  08890000
MAIN0CT  DC    PL5'+0'                                                  08900000
MAIN4CT  DC    PL5'+0'                                                  08910000
MAIN8CT  DC    PL5'+0'                                                  08920000
MAIN12CT DC    PL5'+0'                                                  08930000
MAIN16CT DC    PL5'+0'                                                  08940000
MAINXXCT DC    PL5'+0'                                                  08950000
SELECTMD DC    PL5'+0'                                                  08960000
SELECTCT DC    PL5'+0'                                                  08970000
SMPRC    DC    CL2' '                                                   08980000
SMPFUN   DC    CL7' '                                                   08990000
MAINRC   DC    CL3' '                                                   09000000
MAINMOD  DC    CL8' '                                                   09010000
MAINREC  DC    CL121' '                                                 09020000
         DC    CL12' '  IN CASE LRECL=133                            03 09030003
MAINBUF  DS    231CL121                                                 09040000
MAINBUFN EQU   *                                                        09050000
*                                                                       09060000
*        Common area                                                    09070000
*                                                                       09080000
W#       CSECT                                                          09090000
W#SA     DC    18A(0)                                                   09100000
W#SA1    DC    18A(0)                                                   09110000
W#SA2    DC    18A(0)                                                   09120000
W#SA3    DC    18A(0)                                                   09130000
W#SA4    DC    18A(0)                                                   09140000
W#SA5    DC    18A(0)                                                   09150000
W#SA6    DC    18A(0)                                                   09160000
W#SA7    DC    18A(0)                                                   09170000
W#DWORD  DC    D'+0'                                                    09180000
W#CURTTR DC    A(0)                                                1.07 09190007
W#CURDTE DC    A(0)                                                     09200000
W#1STCS  DC    CL8' '                                                   09210000
W#TMWK4  DC    X'402021204B20204B20204B2020'                            09220000
W#HX2CHR DC    C'0123456789ABCDEF'                                      09230000
W#PARMAD DC    A(0)                                                     09240000
W#FLAG   DC    AL1(0)                                                   09250000
W#FLAG2  DC    AL1(0)                                                   09260000
W#FLG2LG EQU   X'80'                                                    09270000
W#FLG2LA EQU   X'40'                                                    09280000
W#FLG2ST EQU   X'20'                                                    09290000
W#FLG2SE EQU   X'02'                                                    09300000
W#FLG2RR EQU   X'10'                                                    09310000
W#FLG2DB EQU   X'08'                                               1.05 09320005
W#FLG2NS EQU   X'04'                                               1.05 09330005
W#FLG2AP EQU   X'02'                                               1.07 09340007
W#FLG2AC EQU   X'01'                                               1.07 09350007
W#LNCT   DC    PL2'+99'                                                 09360000
W#PGCT   DC    PL2'+0'                                                  09370000
W#LINE   DC    CL133' '                                                 09380000
W#HD1    DC    CL133'1'                                                 09390000
         ORG   W#HD1+1                                                  09400000
W#HD1DTE DC    C'            '                                          09410000
         DC    C' '                                                     09420000
W#HD1TOD DC    C'HH:MM:SS'                                              09430000
         DC    C'  '                                                    09440000
W#HD1RPT DC    C'                '                                      09450000
         ORG   W#HD1+66-(22/2)                                          09460000
W#HD1TTL DC    C'SMP Assembly Extractor'                                09470000
         ORG   W#HD1+L'W#HD1-4-4                                        09480000
W#HD1PG  DC    C'Page'                                                  09490000
W#HD1PCT DC    C' 123'                                                  09500000
W#HD2    DC    CL133' '                                                 09510000
W#PRTDD  DCB   DDNAME=SYSPRINT,MACRF=PM,DSORG=PS,                      X09520000
               RECFM=FBA,LRECL=133                                      09530000
         DC    CL8'<-----W#'                                            09540000
MODLIST  CSECT                                                          09550000
         DC    4000CL8' '                                               09560000
MODLIST# EQU   (*-MODLIST)/8                                            09570000
         DROP  ,                                                        09580000
**********************************************************************  09590000
*                                                                       09600000
*            WRITE PRINT LINE                                           09610000
*                                                                       09620000
**********************************************************************  09630000
PRINT    CSECT                                                          09640000
         USING PRINT,R15                                                09650000
         B     PRINTBGN                                                 09660000
         DROP  R15                                                      09670000
         DC    AL1(L'PRINTID)                                           09680000
PRINTID  DC    C'PRINT &SYSDATE &SYSTIME'                               09690000
PRINTBGN DS    0H                                                       09700000
         STM   R14,R12,12(R13)         SAVE CALLERS REGS                09710000
         LR    R12,R15                 TRANSFER BASE REG                09720000
         USING PRINT,R12                                                09730000
         USING W#,R10                                                   09740000
         LA    R14,18*4(,R13)                                           09750000
         ST    R13,4(,R14)                                              09760000
         ST    R14,8(,R13)                                              09770000
         LR    R13,R14                                                  09780000
         CP    W#LNCT,=P'+60'          END OF PAGE                      09790000
         BL    PRINTCHK                 NO, CHECK IF LINE FIT IN PAGE   09800000
PRINTHDS DS    0H                                                       09810000
         AP    W#PGCT,=P'+1'           COUNT PAGES                      09820000
         MVC   W#HD1PCT,=X'40202120'   PAGE COUNT MASK                  09830000
         ED    W#HD1PCT,W#PGCT         EDIT PAGE COUNT                  09840000
         PUT   W#PRTDD,W#HD1           PRINT HEADING 1                  09850000
         PUT   W#PRTDD,W#HD2           PRINT HEADING 1                  09860000
         ZAP   W#LNCT,=P'+2'           INIT LINE COUNT                  09870000
         MVI   W#LINE,C'0'             SKIP AFTER HEADING               09880000
PRINTCHK DS    0H                                                       09890000
         CLI   W#LINE,C'+'             OVERPRINT ?                      09900000
         BE    PRINTLN                  YES, DON'T COUNT                09910000
         CLI   W#LINE,C'1'             NEW LINE ?                       09920000
         BE    PRINTHDS                 YES, PRINT HEADER               09930000
         CLI   W#LINE,C' '             WRITE AFTER ADVANCING 1?         09940000
         BE    PRINTLN1                 YES, GO CHECK IF FIT            09950000
         CLI   W#LINE,C'0'             WRITE AFTER ADVANCING 1?         09960000
         BE    PRINTLN2                 YES, GO CHECK IF FIT            09970000
         CLI   W#LINE,C'-'             WRITE AFTER ADVANCING 1?         09980000
         BE    PRINTLN3                 YES, GO CHECK IF FIT            09990000
         B     PRINTLN                 IGNORE ANY OTHER CTL CHARS       10000000
PRINTLN1 DS    0H                                                       10010000
         AP    W#LNCT,=P'+1'           ADD TO LINE COUNT                10020000
         B     PRINTVFY                GO SEE IF IT WILL FIT            10030000
PRINTLN2 DS    0H                                                       10040000
         AP    W#LNCT,=P'+2'           ADD TO LINE COUNT                10050000
         B     PRINTVFY                GO SEE IF IT WILL FIT            10060000
PRINTLN3 DS    0H                                                       10070000
         AP    W#LNCT,=P'+3'           ADD TO LINE COUNT                10080000
PRINTVFY DS    0H                                                       10090000
         CP    W#LNCT,=P'+60'          OVERFLOW ?                       10100000
         BH    PRINTHDS                 YES, FORCE HEADER               10110000
PRINTLN  DS    0H                                                       10120000
         CLC   =C'Begin ',W#LINE+1                                      10130000
         BE    PRINTLN4                                                 10140000
         CLC   =C'End ',W#LINE+1                                        10150000
         BNE   PRINTLN5                                                 10160000
PRINTLN4 DS    0H                                                       10170000
         MVC   PRTSAV,W#LINE                                            10180000
         TIME  BIN                     GET CURRENT DATE AND TIME        10190000
         ST    R1,W#CURDTE             SAVE DATE                        10200000
         SRDL  R0,32                   GET DOUBLE WORD TIME             10210000
         D     R0,=F'+6000'            GET MINUTES                      10220000
         LR    R15,R0                  SAVE SECS TENS AND HUNDRETHS     10230000
         SLR   R0,R0                   CLEAR                            10240000
         D     R0,=F'+60'              GET HOURS / MINS                 10250000
         MH    R0,=H'+10000'           GET MINUTES                      10260000
         AR    R15,R0                  ADD TO GET MM:SS.TH              10270000
         M     R0,=F'+1000000'         GET HOURS                        10280000
         AR    R1,R15                  GET HH:MM:SS.TH                  10290000
         CVD   R1,W#DWORD              GET TIME TO DECIMAL              10300000
         MVC   W#TMWK4,=X'402120207A20207A20204B2020'                   10310000
         ED    W#TMWK4,W#DWORD+3   EDIT TIME                            10320000
         MVC   W#LINE+1(11),W#TMWK4+2 MOVE TIME                         10330000
         MVI   W#LINE+12,C' '                                           10340000
         MVC   W#LINE+13(132-12),PRTSAV+1                               10350000
PRINTLN5 DS    0H                                                       10360000
         PUT   W#PRTDD,W#LINE          PRINT A LINE                     10370000
         MVI   W#LINE,C' '             CLEAR CONTROL CHARACTER          10380000
         MVC   W#LINE+1(L'W#LINE-1),W#LINE                              10390000
         L     R13,4(,R13)             POINT TO CALLERS SAVE            10400000
         L     R14,R12(,R13)           SET RETURN ADDRESS               10410000
         LA    R15,0                   SET RETURN CODE                  10420000
         LM    R14,12,12(R13)          RESTORE REGS                     10430000
         BR    R14                     RETURN TO CALLER                 10440000
         LTORG ,                                                        10450000
PRTSAV   DC    CL133' '                                                 10460000
*                                                                       10470000
*                                                                       10480000
*                                                                       10490000
R0       EQU   0                                                        10500000
R1       EQU   1                                                        10510000
R2       EQU   2                                                        10520000
R3       EQU   3                                                        10530000
R4       EQU   4                                                        10540000
R5       EQU   5                                                        10550000
R6       EQU   6                                                        10560000
R7       EQU   7                                                        10570000
R8       EQU   8                                                        10580000
R9       EQU   9                                                        10590000
R10      EQU   10                                                       10600000
R11      EQU   11                                                       10610000
R12      EQU   12                                                       10620000
R13      EQU   13                                                       10630000
R14      EQU   14                                                       10640000
R15      EQU   15                                                       10650000
JFCB     DSECT ,                                                     03 10660003
         IEFJFCBN ,                                                  03 10670003
         END   MVSASM38                                                 10680000
